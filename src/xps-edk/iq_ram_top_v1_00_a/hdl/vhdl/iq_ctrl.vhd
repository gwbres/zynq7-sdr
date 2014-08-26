library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity iq_ctrl is
generic (
	DATA_SIZE		: integer := 16;
	ADDR_SIZE		: integer := 13;
	AXI_SIZE		: integer := 32
);
port (
	clk			: in std_logic;
	rst			: in std_logic;
	mux			: out std_logic_vector(1 downto 0);
	new_sample		: in std_logic;
	data_i_in		: in std_logic_vector(DATA_SIZE-1 downto 0);
	data_q_in		: in std_logic_vector(DATA_SIZE-1 downto 0);
	we_a			: out std_logic;
	data_a			: out std_logic_vector((2*DATA_SIZE)-1 downto 0);
	addr_a			: out std_logic_vector(ADDR_SIZE-1 downto 0);
	irq			: out std_logic
);
end entity;


architecture rtl of iq_ctrl is

constant INTERNAL_SIZE		: integer := 9;
constant HALF_FULL		: integer := ((2**ADDR_SIZE)/2)-1;
constant FULL			: integer := (2**ADDR_SIZE)-1;
signal addr_int			: integer range 0 to (2**ADDR_SIZE)-1;
signal i9_s			: std_logic_vector(INTERNAL_SIZE-1 downto 0);
signal q9_s			: std_logic_vector(INTERNAL_SIZE-1 downto 0);
signal i8_s			: std_logic_vector((DATA_SIZE/2)-1 downto 0);
signal q8_s			: std_logic_vector((DATA_SIZE/2)-1 downto 0);
signal iq16_s			: std_logic_vector(DATA_SIZE-1 downto 0);
signal iq16_p			: std_logic_vector(DATA_SIZE-1 downto 0);
signal iq32_s			: std_logic_vector((2*DATA_SIZE)-1 downto 0);
signal cnt_sample		: std_logic;
signal wr_rise			: std_logic;
signal mux_s			: std_logic_vector(1 downto 0);

begin

	i9_s <= data_i_in(INTERNAL_SIZE-1 downto 0);
	q9_s <= data_q_in(INTERNAL_SIZE-1 downto 0);
	i8_s <= i9_s(INTERNAL_SIZE-1 downto 1);
	q8_s <= q9_s(INTERNAL_SIZE-1 downto 1);
	iq32_s <= iq16_s&iq16_p;
	data_a <= iq32_s;

	addr_a <= std_logic_vector(to_unsigned(addr_int, ADDR_SIZE));
	we_a <= wr_rise;

	irq <= '1' when (addr_int = HALF_FULL or addr_int = FULL)
		else '0';
	
b16_to_32p: process(clk, rst, new_sample)
begin
	if rst = '1' then
		iq16_s <= (others => '0');
		iq16_p <= (others => '0');
	elsif rising_edge(clk) then
		iq16_s <= iq16_s;
		iq16_p <= iq16_p;
		if new_sample = '1' then
			if cnt_sample = '1' then
				iq16_s <= i8_s&q8_s;
			else
				iq16_p <= i8_s&q8_s;
			end if;
		end if;
	end if;
end process b16_to_32p;
			
we_p: process(clk, rst)
begin
	if rst = '1' then
		wr_rise <= '0';
	elsif rising_edge(clk) then
		wr_rise <= '0';
		if cnt_sample = '1' and new_sample = '1' then
			wr_rise <= '1';
		end if;
	end if;
end process we_p;

cnter_p: process(clk, rst)
begin
	if rst = '1' then
		cnt_sample <= '0';
	elsif rising_edge(clk) then
		cnt_sample <= cnt_sample;
		if new_sample = '1' then
			cnt_sample <= not cnt_sample;
		end if;
	end if;
end process cnter_p;

wr_ptr_p: process(clk, rst)
begin
	if rst = '1' then
		addr_int <= 0;
	elsif rising_edge(clk) then
		addr_int <= addr_int;
		if new_sample = '1' then
			if cnt_sample = '1' then
				if addr_int = FULL then
					addr_int <= 0;
				else
					addr_int <= addr_int +1;
				end if;
			end if;
		end if;
	end if;
end process wr_ptr_p;

mux_p: process(clk, rst)
begin
	if rst = '1' then
		mux_s <= (others => '0');
	elsif rising_edge(clk) then
		mux_s <= mux_s;
		if new_sample = '1' then
			if ((addr_int > 0) and (addr_int < HALF_FULL)) then
				mux <= "00";
			elsif ((addr_int >= HALF_FULL) and (addr_int <= FULL)) then
				mux <= "01";
			else
				mux <= "00";
			end if;
		end if;
	end if;
end process mux_p;
end rtl;
