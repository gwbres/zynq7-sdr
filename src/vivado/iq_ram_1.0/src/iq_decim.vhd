library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity iq_decim is
generic (
	I2S_DATA_WIDTH		: integer := 16;
	AXI_DATA_WIDTH		: integer := 32
);
port (
	clk			: in std_logic;
	rst			: in std_logic;
	start_acq		: in std_logic;
	decim_in		: in std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	data_en			: in std_logic;
	data_i_in		: in std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
	data_q_in		: in std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
	new_sample		: out std_logic;
	data_i_out		: out std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
	data_q_out		: out std_logic_vector(I2S_DATA_WIDTH-1 downto 0)
);
end entity;

architecture rtl of iq_decim is


signal decim_max		: integer range 0 to (2**(AXI_DATA_WIDTH-2))-1;
signal cnt_sample		: integer range 0 to (2**(AXI_DATA_WIDTH-2))-1;
signal data_i_s, data_q_s	: std_logic_vector(I2S_DATA_WIDTH-1 downto 0);

begin
	decim_max <= to_integer(unsigned(decim_in));
	data_i_out <= data_i_s;
	data_q_out <= data_q_s;

decim_p: process(clk, rst)
begin
	if rst = '1' then
		cnt_sample <= 0;
	elsif rising_edge(clk) then
		cnt_sample <= cnt_sample;
		if start_acq = '1' then
			if data_en = '1' then
				if cnt_sample < decim_max-1 then
					cnt_sample <= cnt_sample +1;
				else
					cnt_sample <= 0;
				end if;
			end if;
		end if;
	end if;
end process decim_p;

data_p: process(clk, rst)
begin
	if rst = '1' then
		data_i_s <= (others => '0');
		data_q_s <= (others => '0');
		new_sample <= '0';
	elsif rising_edge(clk) then
		data_i_s <= data_i_s;
		data_q_s <= data_q_s;
		new_sample <= '0';
		if data_en = '1' and cnt_sample = 0 then
			new_sample <= '1';
			data_i_s <= data_i_in;
			data_q_s <= data_q_in;
		end if;
	end if;
end process data_p;

end rtl;

