library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity iq_ram_v1_0_S00_AXI is
generic (
  C_S_AXI_DATA_WIDTH : integer := 32;
  C_S_AXI_ADDR_WIDTH : integer := 5;
  RAM_ADDR_WIDTH : integer := 13
);
port (	
  -- axi lite
  S_AXI_ACLK : in std_logic;
  S_AXI_ARESETN : in std_logic;
  S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_AWPROT : in std_logic_vector(2 downto 0);
  S_AXI_AWVALID	: in std_logic;
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
  S_AXI_ARVALID	: in std_logic;
  S_AXI_ARREADY : out std_logic;
  S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_RRESP : out std_logic_vector(1 downto 0);
  S_AXI_RVALID : out std_logic;
  S_AXI_RREADY : in std_logic;
  -- flow
  start : out std_logic;
  decimation : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  ram_status : in std_logic_vector(1 downto 0);
  -- RAM
  ram_ptr : out std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
  ram_data : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
);
end iq_ram_v1_0_S00_AXI;

architecture rtl of iq_ram_v1_0_S00_AXI is

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

type rd_fsm is (IDLE, READ_IQ, RAM_STATE, RESET_PTR, ID);
type wr_fsm is (IDLE, FLOW_CTRL, DECIM);
signal read_state : rd_fsm;
signal write_state : wr_fsm;

constant FLOW_CTRL_REG : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "00000";
constant RAM_STATUS_REG : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "00100";
constant READ_IQ_REG : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "01000";
constant DECIM_REG : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "01100";
constant RESET_PTR_REG : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "10000";
constant ID_REG : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "10100";

signal read_s, decim_s : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal axi_rd_req : std_logic;
signal axi_wr_req : std_logic;
signal start_s : std_logic;
signal addr_p : integer range 0 to (2**RAM_ADDR_WIDTH)-1;

begin
	
  S_AXI_AWREADY	<= axi_awready;
  S_AXI_WREADY <= axi_wready;
  S_AXI_BRESP <= axi_bresp;
  S_AXI_BVALID <= axi_bvalid;
  S_AXI_ARREADY	<= axi_arready;
  S_AXI_RDATA <= axi_rdata;
  axi_rdata <= read_s;
  S_AXI_RRESP <= axi_rresp;
  S_AXI_RVALID <= axi_rvalid;
  axi_wr_req <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;
  axi_rd_req <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);	
  
  write_state <=  FLOW_CTRL when S_AXI_AWADDR = FLOW_CTRL_REG
    else DECIM when S_AXI_AWADDR = DECIM_REG
    else IDLE;
	
  read_state <= READ_IQ when S_AXI_ARADDR = READ_IQ_REG
    else RAM_STATE when S_AXI_ARADDR = RAM_STATUS_REG
    else RESET_PTR when S_AXI_ARADDR = RESET_PTR_REG
    else ID when S_AXI_ARADDR = ID_REG
    else IDLE;
  
  start <= start_s;
  decimation <= decim_s;
  ram_ptr <= std_logic_vector(to_unsigned(addr_p, RAM_ADDR_WIDTH));

axi_wr_p: process(s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    start_s <= '0';
    decim_s <= (C_S_AXI_DATA_WIDTH-1 downto 8 => '0')&"00110010"; -- 50 as default
  elsif rising_edge(s_axi_aclk) then
    start_s <= start_s;
    decim_s <= decim_s;
    if axi_wr_req = '1' then
      case write_state is
	WHEN FLOW_CTRL =>
	  start_s <= s_axi_wdata(0);
	WHEN DECIM =>
	  decim_s <= s_axi_wdata;
	WHEN OTHERS =>
      end case;
    end if;
  end if;
end process axi_wr_p;

axi_rd_p: process(s_axi_aclk, s_axi_aresetn)
begin
  if s_axi_aresetn = '0' then
    read_s <= (others => '0');
    addr_p <= 0;
  elsif rising_edge(s_axi_aclk) then
    read_s <= read_s;
    addr_p <= addr_p;
    if axi_rd_req = '1' then
      case read_state is
	WHEN RAM_STATE =>
	  read_s <= (C_S_AXI_DATA_WIDTH-1 downto 2 => '0')&ram_status;
	WHEN READ_IQ =>
	  read_s <= ram_data;
	  if addr_p < ((2**RAM_ADDR_WIDTH)-1) then
	    addr_p <= addr_p +1;
	  else
	    addr_p <= 0;
	  end if;
	WHEN RESET_PTR =>
	  addr_p <= 0;
	WHEN ID =>
	  read_s <= X"43D20000";
	WHEN OTHERS =>
      end case;
    end if;
  end if;
end process axi_rd_p;

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
