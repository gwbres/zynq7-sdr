library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity spi_send_recv is
generic (
        CPOL    : std_logic := '0';
        CPHA    : std_logic := '0';
        SPI_SIZE   : integer := 8
);
port (
        -- AXI
        Clk   : in  std_logic;
        Rst   : in  std_logic;
        -- SPI 
        cs_o    : out std_logic;
        sck_o: out std_logic;
        mosi_o  : out std_logic;
        miso_i  : in std_logic;

          ---CPU To Slave
        send_req_i  : in std_logic;
        data_i  : in std_logic_vector(SPI_SIZE-1 downto 0);

          --- Slave To CPU
          data_o  : out std_logic_vector(SPI_SIZE-1 downto 0);
        -- BAUD RATE
             tick_i  : in std_logic
);

end entity;


architecture rtl of spi_send_recv is

type state_type is (spi_idle, write, read, cs_high);
signal state_reg, state_next : state_type;
signal n_reg, n_next: unsigned (4 downto 0);

signal cs_reg, cs_next : std_logic;
signal sck_reg, sck_next : std_logic;
signal mosi_reg, mosi_next : std_logic;
signal r_data_reg, r_data_next : std_logic_vector(SPI_SIZE-1 downto 0);
signal t_data_reg, t_data_next : std_logic_vector(SPI_SIZE-1 downto 0);
signal led_reg, led_next : std_logic;

begin

-- change state
process(Clk, Rst)
begin
 if Rst = '1' then
    state_reg <= spi_idle;
    n_reg <= (others => '0');
    r_data_reg <= (others => '0');
    t_data_reg <= (others => '0');
    cs_reg <= '1';
    sck_reg <= CPOL;
    mosi_reg <= '0';
 elsif rising_edge(Clk) then
    state_reg <= state_next;
    sck_reg <= sck_next;
    mosi_reg <= mosi_next;
    r_data_reg <= r_data_next;
    t_data_reg <= t_data_next;
    n_reg <= n_next;
    cs_reg <= cs_next;
 end if;
 end process;

 -- next state logic & data path functional units/routing
process(state_reg, n_reg, tick_i, sck_reg, mosi_reg,
        data_i, send_req_i, miso_i,
        cs_reg, r_data_reg, t_data_reg)
begin

cs_next <= cs_reg;
cs_next <= cs_reg;
state_next <= state_reg;
sck_next <= sck_reg;
mosi_next <= mosi_reg;
r_data_next <= r_data_reg;
t_data_next <= t_data_reg;
n_next <= n_reg;
case state_reg is
        when spi_idle =>
        if send_req_i = '1' then
                 cs_next <= '0';
                 state_next <= write;
                 r_data_next <= (others => '0');
                 t_data_next <= data_i;
                 n_next <= (others => '0');
         else
                 cs_next <= '1';
                 sck_next <= CPOL;
         end if;
        when write =>
          if (tick_i = '1') then
                  mosi_next <= t_data_reg(SPI_SIZE-1);
                  t_data_next <= t_data_reg(SPI_SIZE-2 downto 0)&'0';
                  state_next <= read;
                  if CPHA = '0' then
                      sck_next <= CPOL;
                  else
                      sck_next <= not(sck_reg);
                  end if;
           end if;
        when read =>
          if (tick_i = '1') then
               sck_next <= not (sck_reg);
               r_data_next <= r_data_reg(SPI_SIZE-2 downto 0)&miso_i;
               if (n_reg = SPI_SIZE-1) then
                     n_next <= (others => '0');
                     state_next <= cs_high;
               else
                     state_next <= write;
                     n_next <= n_reg + 1;
               end if;
            end if;

        when cs_high =>
            if (tick_i = '1') then
                cs_next <= '1';
                state_next <= spi_idle;
            end if;

        end case;
mosi_o <= mosi_reg;
sck_o <= sck_reg;
cs_o  <= cs_reg;
data_o <= r_data_reg;

end process;
end rtl;
                                                      