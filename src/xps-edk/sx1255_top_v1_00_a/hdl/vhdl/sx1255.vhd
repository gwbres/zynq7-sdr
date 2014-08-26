library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sx1255 is
generic
(
        DATA_SIZE: integer :=16;
        INTERNAL_DATA_SIZE: integer :=9;
        AXI_SIZE: integer := 32;
        SPI_SIZE: integer := 8;
        I2S_SIZE: integer := 8
);
port
(
        -- Ctrl
        AXI_Clk: in std_logic;
        AXI_Reset: in std_logic;
        -- AXI
        AXI_Addr: in std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_WrData: in std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_RdData: out std_logic_vector(AXI_SIZE-1 downto 0);
		  AXI_CS: in std_logic_vector(1 downto 0);
		  AXI_RNW: in std_logic;
        AXI_WrAck: out std_logic;
        AXI_RdAck: out std_logic;
        AXI_Error: out std_logic;
        -- IQ RECU
        i_in: out std_logic;
        q_in: out std_logic;
        data_i_o: out std_logic_vector(DATA_SIZE-1 downto 0);
        data_q_o: out std_logic_vector(DATA_SIZE-1 downto 0);
        data_en_o: out std_logic;
        --I2S IQ EMMISSION
        ck_out: in std_logic;
        q_out: in std_logic;
        i_out: in std_logic;
        i2s_ws: in std_logic;
        --SPI
        MOSI: out std_logic;
        MISO: in std_logic;
        CS: out std_logic;
        SCLK: out std_logic
);
end entity;


architecture main of sx1255 is

signal data_from_slave_s: std_logic_vector(DATA_SIZE-1 downto 0);

signal ps_val_s: std_logic_vector(4 downto 0);
signal spi_start_s: std_logic;
signal spi_data_o_s: std_logic_vector(DATA_SIZE-1 downto 0);
signal inv_spi_cs_s: std_logic;
signal spi_cs_s: std_logic;
signal data_i_o_s: std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);
signal data_q_o_s:std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);

component sx1255_axi is
generic(
        AXI_SIZE: integer := 32;
        DATA_SIZE: integer := 16
);
port (
        --AXI BUS
        AXI_Clk:                          in std_logic;
        AXI_Reset:                        in std_logic;
        --AXI DATA
        AXI_Addr: in std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_WrData: in std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_RdData: out std_logic_vector(AXI_SIZE-1 downto 0);
		  AXI_CS: in std_logic_vector(1 downto 0);
		  AXI_RNW: in std_logic;
        AXI_WrAck: out std_logic;
        AXI_RdAck: out std_logic;
        AXI_Error: out std_logic;
        --SPI
        spi_start: out std_logic;
        spi_data_o: out std_logic_vector(DATA_SIZE-1 downto 0);
        spi_data_i: in std_logic_vector(DATA_SIZE-1 downto 0);
        spi_busy: in std_logic;
        ps_val: out std_logic_vector(4 downto 0);
        --I2S
        q_in: out std_logic;
        i_in: out std_logic
);
end component;


component spi is
generic (
          SPI_SIZE: integer := 8;
          CPOL    : std_logic := '0';
          CPHA    : std_logic := '0'
);
port (
        --AXI BUS
        Clk: in std_logic;
        Rst: in std_logic;
        --CPU baud rate select 
        ps_val: in std_logic_vector(4 downto 0);
        --data to slave
        data_to_slave         : in    std_logic_vector(SPI_SIZE-1 downto 0);
        send_req: in std_logic;
        --slave to CPU
        data_from_slave        : out   std_logic_vector(SPI_SIZE-1 downto 0);
        --SPI
        MISO:                   in std_logic;
        MOSI:                   out std_logic;
        CS:                out std_logic;
        SCLK:                   out std_logic
);
end component;
component i2s is
generic (
I2S_SIZE   : integer := 8
);
port (
 -- Control
        clk                     : in    std_logic;      -- Main clock
        rst                     : in    std_logic;      -- Main reset
        -- I2S
        i2s_clk_i       : in std_logic;
        i2s_i_i         : in    std_logic;
        i2s_q_i         : in    std_logic;
        i2s_ws_i        : in    std_logic;
        --IQ DATA
        data_i_o        : out std_logic_vector(I2S_SIZE-1 downto 0);
        data_q_o        : out std_logic_vector(I2S_SIZE-1 downto 0);
        data_en_o       : out std_logic
);
end component;

begin

CS <= spi_cs_s;
inv_spi_cs_s <= not spi_cs_s;
data_i_o <=
(DATA_SIZE-1 downto INTERNAL_DATA_SIZE => data_i_o_s(INTERNAL_DATA_SIZE -1))
                & data_i_o_s;
        data_q_o <=
                (DATA_SIZE-1 downto INTERNAL_DATA_SIZE => data_q_o_s(INTERNAL_DATA_SIZE -1))
                & data_q_o_s;


AXI_CTRL: sx1255_axi
generic map (
        AXI_SIZE => AXI_SIZE,
        DATA_SIZE => DATA_SIZE
)
port map (
        --AXI BUS
        AXI_Clk => AXI_Clk,
        AXI_Reset => AXI_Reset,
        --AXI DATA
        AXI_Addr => AXI_Addr,
        AXI_WrData => AXI_WrData,
        AXI_RdData => AXI_RdData,
		  AXI_CS => AXI_CS,
		  AXI_RNW => AXI_RNW,
        AXI_WrAck => AXI_WrAck,
        AXI_RdAck => AXI_RdAck,
        AXI_Error => AXI_Error,
        --SPI
        spi_start    => spi_start_s,
        spi_data_o   => spi_data_o_s,
        spi_data_i => data_from_slave_s,
        spi_busy   => inv_spi_cs_s,
        ps_val     => ps_val_s,
        --I2S
        q_in              => q_in,
        i_in              =>i_in
);

SPI_CTRL: spi
generic map (
              SPI_SIZE => DATA_SIZE,
              CPOL => '0',
              CPHA => '0'
)
port map (
        Clk => AXI_Clk,
        Rst => AXI_Reset,
        --CPU baud rate select 
        ps_val => ps_val_s,
        --data to slave
        data_to_slave => spi_data_o_s,
        send_req => spi_start_s,
        --slave to CPU
        data_from_slave => data_from_slave_s,
        MISO            => MISO,
        MOSI           => MOSI,
        CS             => spi_cs_s,
        SCLK           => SCLK
);

I2S_CTRL: i2s
generic map(
        I2S_SIZE   => INTERNAL_DATA_SIZE
)
port map (
         -- Control
        clk => AXI_Clk,
        rst => AXI_Reset,
        -- I2S
        i2s_clk_i => ck_out,
        i2s_i_i   => i_out,
        i2s_q_i   => q_out,
        i2s_ws_i  => i2s_ws,
        --IQ DATA
        data_i_o => data_i_o_s,
        data_q_o => data_q_o_s,
        data_en_o => data_en_o
);


end main;
