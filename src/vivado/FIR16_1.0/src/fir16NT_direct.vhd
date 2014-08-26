library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fir16NT_direct is 
	generic (
		DATA_OUT_SIZE: natural := 32;
		COEFF_SIZE: natural := 16;
		DATA_SIZE : natural := 8
	);
	port 
	(
		-- Syscon signals
		reset		 : in std_logic;
		clk		   : in std_logic;
		-- input data
		coeff_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		data_en_i : in std_logic;
		enable_accum_i : in std_logic;
		data_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		reset_accum_i : in std_logic;
		-- for the next component
		data_q_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_i_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o : out std_logic
	);
end entity;

---------------------------------------------------------------------------
Architecture fir16NT_direct_1 of fir16NT_direct is
---------------------------------------------------------------------------
	-- temporary signals
	signal result_en_s : std_logic;
	signal result_i_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal result_q_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	-- output signals
	signal data_out_i_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal data_out_q_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal enable_accum_s : std_logic;
	signal reset_accum_s : std_logic;
	signal tt : std_logic;
begin
	data_i_o <= data_out_i_s;
	data_q_o <= data_out_q_s;
	
	process(clk, reset)
	begin
		if reset = '1' then
			data_out_i_s <= (others => '0');
			data_out_q_s <= (others => '0');
			data_en_o <= '0';
			reset_accum_s <= '0';
		elsif rising_edge(clk) then
			reset_accum_s <= reset_accum_i;
			data_out_i_s <= data_out_i_s;
			data_out_q_s <= data_out_q_s;
			data_en_o <= '0';
			if result_en_s = '1' then
				data_out_i_s <= result_i_s(DATA_OUT_SIZE-1 downto 0);
				data_out_q_s <= result_q_s(DATA_OUT_SIZE-1 downto 0);
				data_en_o <= '1';
			end if;
		end if;
	end process;
	
	tt <= data_en_i and enable_accum_i;
	enable_accum_s <= not(enable_accum_i);

	fir_proc_inst : entity work.fir16NT_proc
	generic map (
		COEFF_SIZE => COEFF_SIZE,
		DATA_OUT_SIZE => DATA_OUT_SIZE,
		DATA_SIZE => DATA_SIZE
	)
	port map (
		-- Syscon signals
		reset		=> reset,
		clk			=> clk,
		-- input datas
		clear_accum_i => enable_accum_s,
		coeff_i => coeff_i,
		data_i_i => data_i_i,
		data_q_i => data_q_i,
		data_en_i => tt,--data_en_i,
		reset_accum_i => reset_accum_s,
		-- for the output
		data_i_o	=> result_i_s,
		data_q_o	=> result_q_s,
		data_en_o	=> result_en_s
	);

end architecture fir16NT_direct_1;

