library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sx1255_top_v1_0 is
generic (
	C_S00_AXI_DATA_WIDTH	: integer	:= 32;
	C_S00_AXI_ADDR_WIDTH	: integer	:= 5;
	DATA			: integer 	:= 16
);
port (
	-- axi lite
	s00_axi_aclk	: in std_logic;
	s00_axi_aresetn	: in std_logic;
	s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
	s00_axi_awprot	: in std_logic_vector(2 downto 0);
	s00_axi_awvalid	: in std_logic;
	s00_axi_awready	: out std_logic;
	s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
	s00_axi_wvalid	: in std_logic;
	s00_axi_wready	: out std_logic;
	s00_axi_bresp	: out std_logic_vector(1 downto 0);
	s00_axi_bvalid	: out std_logic;
	s00_axi_bready	: in std_logic;
	s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
	s00_axi_arprot	: in std_logic_vector(2 downto 0);
	s00_axi_arvalid	: in std_logic;
	s00_axi_arready	: out std_logic;
	s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	s00_axi_rresp	: out std_logic_vector(1 downto 0);
	s00_axi_rvalid	: out std_logic;
	s00_axi_rready	: in std_logic;
	-- spi
	MISO		: in std_logic;
	MOSI		: out std_logic;
	CS		: out std_logic;
	SCLK		: out std_logic;
	-- i2s
	i2s_clk		: in std_logic;
	i2s_i_in	: in std_logic;
	i2s_q_in	: in std_logic;
	i2s_ws		: in std_logic;
	I		: out std_logic;
	Q		: out std_logic;
	-- IQ Flow
	data_en		: out std_logic;
	data_i		: out std_logic_vector(DATA-1 downto 0);
	data_q		: out std_logic_vector(DATA-1 downto 0)
);
end sx1255_top_v1_0;

architecture rtl of sx1255_top_v1_0 is


signal rst			: std_logic;
constant INTERNAL_DATA_SIZE	: integer := 9;
signal spi_req			: std_logic;
signal ps_val_s			: std_logic_vector(4 downto 0);
signal spi_data_o_s		: std_logic_vector(DATA-1 downto 0);
signal spi_data_i_s		: std_logic_vector(DATA-1 downto 0);
signal data_i_o_s		: std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);
signal data_q_o_s		: std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);
signal spi_busy_s		: std_logic;
signal spi_cs_s			: std_logic;


component sx1255_top_v1_0_S00_AXI is
generic (
	C_S_AXI_DATA_WIDTH	: integer	:= 32;
	C_S_AXI_ADDR_WIDTH	: integer	:= 5;
	DATA			: integer 	:= 16
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
	spi_start	: out std_logic;
	spi_data_o	: out std_logic_vector(DATA-1 downto 0);
	spi_data_i	: in std_logic_vector(DATA-1 downto 0);
	spi_busy	: in std_logic;
	ps_val		: out std_logic_vector(4 downto 0);
	q_in		: out std_logic;
	i_in		: out std_logic	
);
end component sx1255_top_v1_0_S00_AXI;


component i2s is
generic (
	I2S_SIZE		: integer := 8
);
port (
	clk			: in std_logic;
	rst			: in std_logic;
	i2s_clk_i		: in std_logic;
	i2s_i_i			: in std_logic;
	i2s_q_i			: in std_logic;
	i2s_ws_i		: in std_logic;
	data_i_o		: out std_logic_vector(I2S_SIZE-1 downto 0);
	data_q_o		: out std_logic_vector(I2S_SIZE-1 downto 0);
	data_en_o		: out std_logic
);
end component;

component spi is
generic (
	SPI_SIZE		: integer := 8;
	CPOL			: std_logic := '0';
	CPHA			: std_logic := '0'
);
port (
	clk			: in std_logic;
	rst			: in std_logic;
	ps_val			: in std_logic_vector(4 downto 0);
	data_to_slave		: in std_logic_vector(SPI_SIZE-1 downto 0);
	send_req		: in std_logic;
	data_from_slave		: out std_logic_vector(SPI_SIZE-1 downto 0);
	MISO			: in std_logic;
	MOSI			: out std_logic;
	CS			: out std_logic;
	SCLK			: out std_logic
);
end component;


begin

	rst <= not s00_axi_aresetn;
	CS <= spi_cs_s;
	spi_busy_s <= not spi_cs_s;

	data_i <= (DATA-1 downto INTERNAL_DATA_SIZE => data_i_o_s(INTERNAL_DATA_SIZE-1))&data_i_o_s;
	data_q <= (DATA-1 downto INTERNAL_DATA_SIZE => data_q_o_s(INTERNAL_DATA_SIZE-1))&data_q_o_s;

sx1255_top_v1_0_S00_AXI_inst : sx1255_top_v1_0_S00_AXI
generic map (
	C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
	C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
	DATA			=> DATA
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
	spi_start	=> spi_req,
	spi_data_o	=> spi_data_o_s,
	spi_data_i	=> spi_data_i_s,
	spi_busy	=> spi_busy_s,
	ps_val		=> ps_val_s,
	q_in		=> Q,
	i_in		=> I
);

spi_inst: spi
generic map (
	SPI_SIZE 	=> DATA,
	CPOL		=> '0',
	CPHA		=> '0'
)
port map (
	clk 		=> s00_axi_aclk,
	rst 		=> rst,
	ps_val		=> ps_val_s,
	data_to_slave	=> spi_data_o_s,
	send_req	=> spi_req,
	data_from_slave => spi_data_i_s,
	MISO		=> MISO,
	MOSI		=> MOSI,
	CS		=> spi_cs_s,
	SCLK		=> SCLK
);

i2s_inst: i2s
generic map(
	I2S_SIZE	=> INTERNAL_DATA_SIZE
)
port map (
	clk		=> s00_axi_aclk,
	rst		=> rst,
	i2s_clk_i	=> i2s_clk,
	i2s_i_i		=> i2s_i_in,
	i2s_q_i		=> i2s_q_in,
	i2s_ws_i	=> i2s_ws,
	data_i_o	=> data_i_o_s,
	data_q_o	=> data_q_o_s,
	data_en_o	=> data_en
);

end rtl;
