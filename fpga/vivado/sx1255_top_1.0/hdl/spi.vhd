library IEEE;
use IEEE.std_logic_1164.all;

entity spi is
generic
(
        SPI_SIZE: integer := 8;
        CPOL    : std_logic := '0';
        CPHA    : std_logic := '0'
);
port
(
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

        MISO:                   in std_logic;
        MOSI:                   out std_logic;
        CS:                out std_logic;
        SCLK:                   out std_logic
);
end entity;


architecture main of spi is

-- prescale clock pour la comm
component spi_baud is
port
(
        --AXI
        Clk: in std_logic;
        Rst: in std_logic;
        --BaudRate
        ps_val:         in std_logic_vector(4 downto 0);
        tick:                   out std_logic
);
end component;

component spi_send_recv is
generic
(
        CPOL    : std_logic := '0';
        CPHA    : std_logic := '0';
        SPI_SIZE   : integer := 8
);
port
(
        -- AXI BUS
        Clk   : in  std_logic;
        Rst   : in  std_logic;
        -- SPI 
        cs_o    : out std_logic;
        sck_o: out std_logic;
        mosi_o  : out std_logic;
        miso_i  : in std_logic;

                  -- CPU To Slave
        send_req_i  : in std_logic;
        data_i  : in std_logic_vector(SPI_SIZE-1 downto 0);
          -- Slave To CPU
        data_o  : out std_logic_vector(SPI_SIZE-1 downto 0);
       -- BAUD RATE
                  tick_i  : in std_logic
);
end component;

signal tick_s: std_logic;

begin

SPI_BAUD_GENERATOR: spi_baud
port map ( Clk => Clk,
           Rst => Rst,
           ps_val => ps_val,
        tick => tick_s );

SPI_SEND_REC: spi_send_recv
generic map(
       CPOL    => CPOL,
       CPHA    => CPHA,
       SPI_SIZE  => SPI_SIZE
)
port map (
        -- AXI
        Clk   => Clk,
        Rst   => Rst,
        -- SPI 
        cs_o    => CS,
        sck_o  => SCLK,
        mosi_o  => MOSI,
        miso_i  => MISO,

        -- CPU To Slave
        send_req_i  => send_req,
        data_i  => data_to_slave,

              -- Slave To CPU
         data_o  => data_from_slave,
        -- BAUD RATE
        tick_i  => tick_s
);

end main;
                                                                                 