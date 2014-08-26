library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FIR16_v1_0_S00_AXI is
generic (
  C_S_AXI_DATA_WIDTH : integer := 32;
  C_S_AXI_ADDR_WIDTH : integer := 4
);
port (
  -- axi lite
  S_AXI_ACLK : in std_logic;
  S_AXI_ARESETN : in std_logic;
  S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_AWPROT : in std_logic_vector(2 downto 0);
  S_AXI_AWVALID : in std_logic;
  S_AXI_AWREADY : out std_logic;
  S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
  S_AXI_WVALID : in std_logic;
  S_AXI_WREADY : out std_logic;
  S_AXI_BRESP : out std_logic_vector(1 downto 0);
  S_AXI_BVALID : out std_logic;
  S_AXI_BREADY : in std_logic;
  S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_ARPROT : in std_logic_vector(2 downto 0);
  S_AXI_ARVALID : in std_logic;
  S_AXI_ARREADY : out std_logic;
  S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_RRESP : out std_logic_vector(1 downto 0);
  S_AXI_RVALID : out std_logic;
  S_AXI_RREADY : in std_logic;
  -- FIR
  coeff_en_o : out std_logic;
  coeff_val_o : out std_logic_vector(15 downto 0);
  coeff_addr_o : out std_logic_vector(9 downto 0)
);
end FIR16_v1_0_S00_AXI;

architecture rtl of FIR16_v1_0_S00_AXI is

signal axi_awaddr : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_awready : std_logic;
signal axi_wready : std_logic;
signal axi_bresp : std_logic_vector(1 downto 0);
signal axi_bvalid : std_logic;
signal axi_araddr : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_arready : std_logic;
signal axi_rdata : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal axi_rresp : std_logic_vector(1 downto 0);
signal axi_rvalid : std_logic;

type rd_fsm is (IDLE, ID);
type wr_fsm is (IDLE, CHG_COEFF, RAZ_ADDR);
signal read_state : rd_fsm;
signal write_state : wr_fsm;

constant RAZ_REG : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "0000";
constant COEFF_REG : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "0100";
constant ID_REG : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "1000";

signal read_s : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal axi_rd_req : std_logic;
signal axi_wr_req : std_logic;
signal coeff_addr_s : std_logic_vector(9 downto 0);
signal coeff_val_s : std_logic_vector(15 downto 0);
signal coeff_en_s : std_logic;
signal coeff_addr_uns_s : natural range 0 to (2**9)-1;

begin
	
  S_AXI_AWREADY <= axi_awready;
  S_AXI_WREADY <= axi_wready;
  S_AXI_BRESP <= axi_bresp;
  S_AXI_BVALID <= axi_bvalid;
  S_AXI_ARREADY <= axi_arready;   
  S_AXI_RDATA <= axi_rdata;
  axi_rdata <= read_s;
  S_AXI_RRESP <= axi_rresp;
  S_AXI_RVALID<= axi_rvalid;

  axi_wr_req <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;
  axi_rd_req <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);
	
  coeff_en_o <= coeff_en_s;
  coeff_val_o <= coeff_val_s;
  coeff_addr_o <= coeff_addr_s;

  write_state <= CHG_COEFF when S_AXI_AWADDR = COEFF_REG
    else RAZ_ADDR when S_AXI_AWADDR = RAZ_REG
    else IDLE;
	
  read_state <= ID when S_AXI_ARADDR = ID_REG
    else IDLE;

axi_write_p: process(s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    coeff_addr_s <= (others => '0');
    coeff_val_s <= (others => '0');
    coeff_en_s <= '0';
    coeff_addr_uns_s <= 0;
  elsif rising_edge(s_axi_aclk) then
    coeff_addr_s <= coeff_addr_s;
    coeff_val_s <= coeff_val_s;
    coeff_addr_uns_s <= coeff_addr_uns_s;
    coeff_en_s <= '0';
    if axi_wr_req = '1' then
      case write_state is 
	WHEN CHG_COEFF =>
	  coeff_en_s <= '1';
	  coeff_val_s <= S_AXI_WDATA(15 downto 0);
	  coeff_addr_uns_s <= coeff_addr_uns_s +1;
	  coeff_addr_s <= std_logic_vector(to_unsigned(coeff_addr_uns_s,10));
	WHEN RAZ_ADDR =>
	  coeff_addr_s <= (others => '0');	
	WHEN OTHERS =>
      end case;
    end if;
  end if;
end process axi_write_p;

axi_read_p: process(s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    read_s <= (others => '0');
  elsif rising_edge(s_axi_aclk) then
    read_s <= read_s;
    if axi_rd_req = '1' then
      case read_state is 
	WHEN ID =>
	  read_s <= X"43D00000";
	WHEN OTHERS =>
      end case;
    end if;
  end if;
end process axi_read_p;

awready_p: process (s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    axi_awready <= '0';
  elsif rising_edge(s_axi_aclk) then
    if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
      axi_awready <= '1';
    else
      axi_awready <= '0';
    end if;
  end if;
end process awready_p;

awaddr_p: process(s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    axi_awaddr <= (others => '0');
  elsif rising_edge(s_axi_aclk) then
    axi_awaddr <= axi_awaddr;
    if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
      axi_awaddr <= S_AXI_AWADDR;
    end if;
  end if;
end process awaddr_p; 

wready_p: process (s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    axi_wready <= '0';
  elsif rising_edge(s_axi_aclk) then
    if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
      axi_wready <= '1';
    else
      axi_wready <= '0';
    end if;
  end if;
end process wready_p; 

bresp_p: process (s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    axi_bvalid <= '0';
    axi_bresp <= "00";
  elsif rising_edge(s_axi_aclk) then
    if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0') then
      axi_bvalid <= '1';
      axi_bresp  <= "00"; 
    elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then  
      axi_bvalid <= '0';                           
    end if;
  end if;
end process bresp_p; 

araddr_p: process (s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    axi_arready <= '0';
    axi_araddr <= (others => '1');
  elsif rising_edge(s_axi_aclk) then
    if (axi_arready = '0' and S_AXI_ARVALID = '1') then
      axi_arready <= '1';
      axi_araddr  <= S_AXI_ARADDR;           
    else
      axi_araddr <= axi_araddr;
      axi_arready <= '0';
    end if;
  end if;
end process araddr_p; 

rresp_p: process (s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    axi_rvalid <= '0';
    axi_rresp <= "00";
  elsif rising_edge(s_axi_aclk) then
    if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
      axi_rvalid <= '1';
      axi_rresp  <= "00"; -- 'OK'
    elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
      axi_rvalid <= '0';
    end if;            
  end if;
end process rresp_p;

end rtl;
