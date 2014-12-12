library IEEE;
use IEEE.std_logic_1164.all;

entity spi is
generic (
  SPI_DATA_WIDTH : integer := 8;
  CPOL : std_logic := '0';
  CPHA : std_logic := '0'
);
port (
    -- pl
    clk : in std_logic;
    rst : in std_logic;
    -- spi
    prs_val : in std_logic_vector(4 downto 0);
    spi_start : in std_logic;
    spi_i : in std_logic_vector(SPI_DATA_WIDTH-1 downto 0);
    spi_o : out std_logic_vector(SPI_DATA_WIDTH-1 downto 0);
    miso : in std_logic;
    mosi : out std_logic;
    cs : out std_logic;
    sck : out std_logic
);
end entity spi;

architecture rtl of spi is

    signal tick_s: std_logic;
begin

    SPI_BAUD_GENERATOR: entity work.spi_baud
    port map ( 
	clk => clk, 
	rst => rst, 
	ps_val => prs_val, 
	tick => tick_s 
    );

    SPI_SEND_REC: entity work.spi_send_recv
    generic map(
	CPOL => CPOL,
	CPHA => CPHA,
	SPI_DATA_WIDTH => SPI_DATA_WIDTH
    )
    port map (
	clk => clk,
	rst => rst,
	cs_o => cs,
	sck_o => sck,
	mosi_o => mosi,
	miso_i => miso,
	send_req_i => spi_start,
	data_i => spi_i,
	data_o => spi_o,
	tick_i => tick_s
    );
end rtl;
