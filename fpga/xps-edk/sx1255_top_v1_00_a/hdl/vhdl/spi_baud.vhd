library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_baud is
port
(
        --AXI
        Clk: in std_logic;
        Rst: in std_logic;
        ps_val:in std_logic_vector(4 downto 0);
        -- CLK Divisee
        tick: out std_logic
);
end entity;

architecture rtl of spi_baud is

signal prescale_int: integer range 0 to 32;

begin

prescale_int <= to_integer(unsigned(ps_val));

process(Clk,Rst)
variable count: integer range 0 to 32;
begin
if Rst = '1' then
	count := 0;
	tick <= '0';
elsif rising_edge(Clk) then
      	if(count = prescale_int - 1) then
            count := 0;
            tick <= '1';
	else
            count := count+1;
            tick <= '0';
        end if; 
end if; --rst
end process;

end rtl;
