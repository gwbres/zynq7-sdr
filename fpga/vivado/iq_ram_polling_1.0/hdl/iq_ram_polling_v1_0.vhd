library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity iq_ram_polling_v1_0 is
generic (
		C_S00_AXI_DATA_WIDTH		: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH		: integer	:= 5;
		DATA				: integer	:= 16;
		ADDR				: integer	:= 13
);
port (
		s00_axi_aclk			: in std_logic;
		s00_axi_aresetn			: in std_logic;
		s00_axi_awaddr			: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot			: in std_logic_vector(2 downto 0);
		s00_axi_awvalid			: in std_logic;
		s00_axi_awready			: out std_logic;
		s00_axi_wdata			: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb			: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid			: in std_logic;
		s00_axi_wready			: out std_logic;
		s00_axi_bresp			: out std_logic_vector(1 downto 0);
		s00_axi_bvalid			: out std_logic;
		s00_axi_bready			: in std_logic;
		s00_axi_araddr			: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot			: in std_logic_vector(2 downto 0);
		s00_axi_arvalid			: in std_logic;
		s00_axi_arready			: out std_logic;
		s00_axi_rdata			: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp			: out std_logic_vector(1 downto 0);
		s00_axi_rvalid			: out std_logic;
		s00_axi_rready			: in std_logic;
		data_en				: in std_logic;
		data_i				: in std_logic_vector(DATA-1 downto 0);
		data_q				: in std_logic_vector(DATA-1 downto 0);
		irq				: out std_logic
);
end entity;

architecture arch_imp of iq_ram_polling_v1_0 is

component iq_ram_polling_v1_0_S00_AXI is
generic (
	C_S_AXI_DATA_WIDTH	: integer	:= 32;
	C_S_AXI_ADDR_WIDTH	: integer	:= 5;
	ADDR			: integer	:= 13
);
port (
	S_AXI_ACLK	: in std_logic;
	S_AXI_ARESETN	: in std_logic;
	S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
	S_AXI_AWVALID	: in std_logic;
	S_AXI_AWREADY	: out std_logic;
	S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
	S_AXI_WVALID	: in std_logic;
	S_AXI_WREADY	: out std_logic;
	S_AXI_BRESP	: out std_logic_vector(1 downto 0);
	S_AXI_BVALID	: out std_logic;
	S_AXI_BREADY	: in std_logic;
	S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
	S_AXI_ARVALID	: in std_logic;
	S_AXI_ARREADY	: out std_logic;
	S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	S_AXI_RRESP	: out std_logic_vector(1 downto 0);
	S_AXI_RVALID	: out std_logic;
	S_AXI_RREADY	: in std_logic;
	start_acq	: out std_logic;
	decim		: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	mux		: in std_logic_vector(1 downto 0);
	addr_b		: out std_logic_vector(ADDR-1 downto 0);
	data_b		: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
);
end component iq_ram_polling_v1_0_S00_AXI;


component iq_ctrl is
generic (
	DATA_SIZE	: integer := 16;
	ADDR_SIZE	: integer := 13;
	AXI_SIZE	: integer := 32
);
port (
	clk		: in std_logic;
	rst		: in std_logic;
	mux		: out std_logic_vector(1 downto 0);
	new_sample	: in std_logic;
	data_i_in	: in std_logic_vector(DATA_SIZE-1 downto 0);
	data_q_in	: in std_logic_vector(DATA_SIZE-1 downto 0);
	we_a		: out std_logic;
	data_a		: out std_logic_vector(AXI_SIZE-1 downto 0);
	addr_a		: out std_logic_vector(ADDR_SIZE-1 downto 0);
	irq		: out std_logic
);
end component;

component iq_decim is
generic (
	DATA_SIZE	: integer := 16;
	AXI_SIZE	: integer := 32
);
port (
	clk		: in std_logic;
	rst		: in std_logic;
	start_acq	: in std_logic;
	decim_in	: in std_logic_vector(AXI_SIZE-1 downto 0);
	data_en		: in std_logic;
	data_i_in	: in std_logic_vector(DATA_SIZE-1 downto 0);
	data_q_in	: in std_logic_vector(DATA_SIZE-1 downto 0);
	new_sample	: out std_logic;
	data_i_out	: out std_logic_vector(DATA_SIZE-1 downto 0);
	data_q_out	: out std_logic_vector(DATA_SIZE-1 downto 0)
);
end component;

component dual_port_ram is
generic (
	DATA		: integer := 72;
	ADDR		: integer := 13
);
port (
	clk_a		: in std_logic;
	clk_b		: in std_logic;
	we_a		: in std_logic;
	addr_a		: in std_logic_vector(ADDR-1 downto 0);
	din_a		: in std_logic_vector(DATA-1 downto 0);
	dout_a		: out std_logic_vector(DATA-1 downto 0);
	we_b		: in std_logic;
	addr_b		: in std_logic_vector(ADDR-1 downto 0);
	din_b		: in std_logic_vector(DATA-1 downto 0);
	dout_b		: out std_logic_vector(DATA-1 downto 0)
);
end component;

signal rst		: std_logic;
signal decim_s		: std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal mux_s		: std_logic_vector(1 downto 0);
signal we_a_s		: std_logic;
signal addr_a_s		: std_logic_vector(ADDR-1 downto 0);
signal addr_b_s		: std_logic_vector(ADDR-1 downto 0);
signal data_a_s		: std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal data_b_s		: std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal data_i_o_s	: std_logic_vector(DATA-1 downto 0);
signal data_q_o_s	: std_logic_vector(DATA-1 downto 0);
signal new_sample_s	: std_logic;
signal start_acq_s	: std_logic;

begin
	
	rst <= not s00_axi_aresetn;

iq_ram_polling_v1_0_S00_AXI_inst : iq_ram_polling_v1_0_S00_AXI
generic map (
	C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
	C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
)
port map (
	S_AXI_ACLK	=> s00_axi_aclk,
	S_AXI_ARESETN	=> s00_axi_aresetn,
	S_AXI_AWADDR	=> s00_axi_awaddr,
	S_AXI_AWPROT	=> s00_axi_awprot,
	S_AXI_AWVALID	=> s00_axi_awvalid,
	S_AXI_AWREADY	=> s00_axi_awready,
	S_AXI_WDATA	=> s00_axi_wdata,
	S_AXI_WSTRB	=> s00_axi_wstrb,
	S_AXI_WVALID	=> s00_axi_wvalid,
	S_AXI_WREADY	=> s00_axi_wready,
	S_AXI_BRESP	=> s00_axi_bresp,
	S_AXI_BVALID	=> s00_axi_bvalid,
	S_AXI_BREADY	=> s00_axi_bready,
	S_AXI_ARADDR	=> s00_axi_araddr,
	S_AXI_ARPROT	=> s00_axi_arprot,
	S_AXI_ARVALID	=> s00_axi_arvalid,
	S_AXI_ARREADY	=> s00_axi_arready,
	S_AXI_RDATA	=> s00_axi_rdata,
	S_AXI_RRESP	=> s00_axi_rresp,
	S_AXI_RVALID	=> s00_axi_rvalid,
	S_AXI_RREADY	=> s00_axi_rready,
	start_acq	=> start_acq_s,
	decim		=> decim_s,
	mux		=> mux_s,
	addr_b		=> addr_b_s,
	data_b		=> data_b_s
);

ctrl_p: iq_ctrl
generic map (
	DATA_SIZE	=> DATA,
	ADDR_SIZE	=> ADDR,
	AXI_SIZE	=> C_S00_AXI_DATA_WIDTH
)
port map (
	clk		=> s00_axi_aclk,
	rst		=> rst,
	mux		=> mux_s,
	new_sample	=> new_sample_s,
	data_i_in	=> data_i_o_s,
	data_q_in	=> data_q_o_s,
	we_a		=> we_a_s,
	data_a		=> data_a_s,
	addr_a		=> addr_a_s,
	irq		=> irq
);

decim_p: iq_decim
generic map (
	DATA_SIZE 	=> DATA,
	AXI_SIZE	=> C_S00_AXI_DATA_WIDTH
)
port map (
	clk		=> s00_axi_aclk,
	rst		=> rst,
	start_acq	=> start_acq_s,
	decim_in	=> decim_s,
	data_en		=> data_en,
	data_i_in	=> data_i,
	data_q_in	=> data_q,
	new_sample	=> new_sample_s,
	data_i_out	=> data_i_o_s,
	data_q_out	=> data_q_o_s
);

ram: dual_port_ram
generic map (
	DATA		=> C_S00_AXI_DATA_WIDTH,
	ADDR		=> ADDR
)
port map (
	clk_a		=> s00_axi_aclk,
	clk_b		=> s00_axi_aclk,
	we_a		=> we_a_s,
	addr_a		=> addr_a_s,
	din_a		=> data_a_s,
	dout_a		=> open,
	we_b		=> '0',
	addr_b		=> addr_b_s,
	din_b		=> (others => '0'),
	dout_b		=> data_b_s
);


end arch_imp;
