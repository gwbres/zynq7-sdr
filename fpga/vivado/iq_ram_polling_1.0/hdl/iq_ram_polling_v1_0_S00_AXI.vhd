library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity iq_ram_polling_v1_0_S00_AXI is
generic (
	C_S_AXI_DATA_WIDTH	: integer	:= 32;
	C_S_AXI_ADDR_WIDTH	: integer	:= 5;
	DATA			: integer	:= 16;
	ADDR			: integer	:= 13
);
port (
	S_AXI_ACLK		: in std_logic;
	S_AXI_ARESETN		: in std_logic;
	S_AXI_AWADDR		: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	S_AXI_AWPROT		: in std_logic_vector(2 downto 0);
	S_AXI_AWVALID		: in std_logic;
	S_AXI_AWREADY		: out std_logic;
	S_AXI_WDATA		: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	S_AXI_WSTRB		: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
	S_AXI_WVALID		: in std_logic;
	S_AXI_WREADY		: out std_logic;
	S_AXI_BRESP		: out std_logic_vector(1 downto 0);
	S_AXI_BVALID		: out std_logic;
	S_AXI_BREADY		: in std_logic;
	S_AXI_ARADDR		: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	S_AXI_ARPROT		: in std_logic_vector(2 downto 0);
	S_AXI_ARVALID		: in std_logic;
	S_AXI_ARREADY		: out std_logic;
	S_AXI_RDATA		: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	S_AXI_RRESP		: out std_logic_vector(1 downto 0);
	S_AXI_RVALID		: out std_logic;
	S_AXI_RREADY		: in std_logic;
	start_acq		: out std_logic;
	decim			: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	mux			: in std_logic_vector(1 downto 0);
	addr_b			: out std_logic_vector(ADDR-1 downto 0);
	data_b			: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
);
end iq_ram_polling_v1_0_S00_AXI;

architecture rtl of iq_ram_polling_v1_0_S00_AXI is

signal axi_awaddr		: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_awready		: std_logic;
signal axi_wready		: std_logic;
signal axi_bresp		: std_logic_vector(1 downto 0);
signal axi_bvalid		: std_logic;
signal axi_araddr		: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_arready		: std_logic;
signal axi_rdata		: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal axi_rresp		: std_logic_vector(1 downto 0);
signal axi_rvalid		: std_logic;

type   rd_fsm			is (IDLE, STATUS, READ_IQ, ID, RESET_PTR);
type   wr_fsm			is (IDLE, START, DECIMATE);
signal read_state		: rd_fsm;
signal write_state		: wr_fsm;

constant START_REG		: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "00000";
constant STATUS_REG		: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "00100";
constant READ_IQ_REG		: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "01000";
constant DECIM_REG		: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "01100";
constant RESET_PTR_REG		: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "10000";
constant ID_REG			: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := "10100";

signal read_s			: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal axi_rd_req		: std_logic;
signal axi_wr_req		: std_logic;

signal start_acq_s		: std_logic;
signal decim_s			: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal addr_int			: integer range 0 to (2**ADDR)-1;
constant FULL			: integer := (2**ADDR)-1;
constant HALF_FULL		: integer := ((2**ADDR)/2)-1;

begin
	
	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	
	S_AXI_ARREADY	<= axi_arready;
	
	S_AXI_RDATA	<= axi_rdata;
	axi_rdata 	<= read_s;

	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;

	axi_wr_req 	<= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	axi_rd_req 	<= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;
	
	write_state 	<= START when S_AXI_AWADDR = START_REG
					else DECIMATE when S_AXI_AWADDR = DECIM_REG
					else IDLE;
	
	read_state	<= STATUS when S_AXI_ARADDR = STATUS_REG
					else READ_IQ when S_AXI_ARADDR = READ_IQ_REG
					else ID when S_AXI_ARADDR = ID_REG
					else RESET_PTR when S_AXI_ARADDR = RESET_PTR_REG
					else IDLE;

	start_acq	<= start_acq_s;
	decim		<= decim_s;
	addr_b		<= std_logic_vector(to_unsigned(addr_int, ADDR));

axi_wr_p: process(s_axi_aclk, s_axi_aresetn)
begin
	if s_axi_aresetn = '0' then
		start_acq_s <= '0';
		decim_s <= (C_S_AXI_DATA_WIDTH-1 downto 8 => '0')&"00110010"; -- 50 as default;
	elsif rising_edge(s_axi_aclk) then
		start_acq_s <= start_acq_s;
		decim_s <= decim_s;
		if axi_wr_req = '1' then
			case write_state is 
				WHEN START =>
					start_acq_s <= S_AXI_WDATA(0);
				WHEN DECIMATE =>
					decim_s <= S_AXI_WDATA;
				WHEN OTHERS =>
			end case;
		end if;
	end if;
end process axi_wr_p;

axi_rd_p: process(s_axi_aclk, s_axi_aresetn)
begin
	if s_axi_aresetn = '0' then
		read_s <= (others => '0');
		addr_int <= HALF_FULL;
	elsif rising_edge(s_axi_aclk) then
		read_s <= read_s;
		addr_int <= addr_int;
		if axi_rd_req = '1' then
			case read_state is 
				WHEN STATUS =>	
					read_s <= (C_S_AXI_DATA_WIDTH-1 downto 2 => '0')&mux;
				WHEN READ_IQ =>
					read_s <= data_b;
					if addr_int < FULL-1 then
						addr_int <= addr_int +1;
					else
						addr_int <= 0;
					end if;
				WHEN RESET_PTR =>
					addr_int <= 0;
				WHEN ID =>
					read_s <= X"43C40000";
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
