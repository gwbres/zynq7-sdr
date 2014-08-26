library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fir16NT_proc is 
	generic (
		COEFF_SIZE		: natural := 16;
		--DATA_SIZE			: natural := 18;
		DATA_OUT_SIZE : natural := 39;
		DATA_SIZE		: natural := 8
	);
	port 
	(
		-- Syscon signals
		reset			: in std_logic;
		clk				: in std_logic;
		-- input datas
		clear_accum_i : in std_logic;
		coeff_i			: in std_logic_vector(COEFF_SIZE-1 downto 0);
		data_i_i		: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i		: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i		: in std_logic;
		reset_accum_i	: in std_logic;
		-- output result
		data_i_o		: out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_q_o		: out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o		: out std_logic
	);
end entity;

---------------------------------------------------------------------------
Architecture fir16NT_proc_1 of fir16NT_proc is
---------------------------------------------------------------------------
	constant TEMP_DATA_SIZE : natural := DATA_SIZE+COEFF_SIZE;
	type state_type is (idle, process_q);
	signal process_state : state_type;
	signal coeff_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal reset_accum_s, reset_accum2_s: std_logic;
	signal store_i, store_q : std_logic;
	signal tmp_val_resc_s : std_logic_vector((DATA_OUT_SIZE-1) downto 0);
	signal accum_i_en_s, accum_q_en_s: std_logic;
	signal accum_i_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal accum_q_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal accum_i_tmp, accum_q_tmp : std_logic_vector((DATA_OUT_SIZE-1) downto 0);
	signal accum_i_final, accum_q_final : std_logic_vector((DATA_OUT_SIZE-1) downto 0);
	-- multiplications
	signal mult_coeff_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal mult_data_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal mult_out_s : std_logic_vector(TEMP_DATA_SIZE-1 downto 0);
begin
	data_i_o <= accum_i_final;
	data_q_o <= accum_q_final;
	
	process(clk, reset)
	begin
		if reset = '1' then
			coeff_s <= (others => '0');
		elsif rising_edge(clk) then
				coeff_s <= coeff_i;
				reset_accum_s <= reset_accum_i;
				reset_accum2_s <= reset_accum_s;
		end if;
	end process;
	
	process_bloc : process(clk, reset)
	begin
		if reset = '1' then
			process_state <= idle;
			accum_i_en_s <= '0';
			accum_q_en_s <= '0';
			mult_coeff_s <= (others => '0');
			mult_data_s <= (others => '0');
		elsif rising_edge(clk) then
			mult_coeff_s <= mult_coeff_s;
			mult_data_s <= mult_data_s;
			
			accum_i_en_s <= '0';
			accum_q_en_s <= '0';
			case process_state is
			when idle =>
				if data_en_i = '1' then
					mult_coeff_s <= coeff_s;
					mult_data_s <= data_i_i;
					process_state <= process_q;
					accum_i_en_s <= '1';
				end if;
			when process_q =>
					mult_coeff_s <= coeff_s;
					mult_data_s <= data_q_i;
					process_state <= idle;
					accum_q_en_s <= '1';
			end case;
		end if;
	end process;
	
	mult_out_s <= std_logic_vector(signed(mult_coeff_s) * signed(mult_data_s));
	tmp_val_resc_s <= 
		(DATA_OUT_SIZE-1 downto (TEMP_DATA_SIZE) => mult_out_s(TEMP_DATA_SIZE-1))&mult_out_s;
	
	accum_i_tmp <= std_logic_vector(unsigned(accum_i_s)+ unsigned(tmp_val_resc_s));
	accum_q_tmp <= std_logic_vector(unsigned(accum_q_s)+unsigned(tmp_val_resc_s));

	final_block : process(clk, reset)
	begin
		if reset = '1' then
			accum_i_final <= (others => '0');
			accum_q_final <= (others => '0');
			data_en_o <= '0';
		elsif rising_edge(clk) then
			data_en_o <= '0';
			accum_i_final <= accum_i_final;
			accum_q_final <= accum_q_final;
			if (accum_q_en_s and reset_accum_s) = '1' then
				accum_i_final <= accum_i_s;
				accum_q_final <= accum_q_tmp;
				data_en_o <= '1';
			end if;
		end if;
	end process;
	
	accum_i_bloc : process(clk, reset)
	begin
		if reset = '1' then
			accum_i_s <= (others => '0');
		elsif rising_edge(clk) then
			accum_i_s <= accum_i_s;
			if accum_i_en_s = '1' then
				accum_i_s <= accum_i_tmp;
			end if;
			if reset_accum_s = '1' then
				accum_i_s <= (others => '0');
			end if;
		end if;
	end process;

	accum_q_bloc : process(clk, reset)
	begin
		if reset = '1' then
			accum_q_s <= (others =>  '0');
		elsif rising_edge(clk) then
			accum_q_s <= accum_q_s;
			if accum_q_en_s = '1' then
				accum_q_s <= accum_q_tmp;
			end if;
			if reset_accum2_s = '1' then
				accum_q_s <= (others => '0');
			end if;
		end if;
	end process;
	
end architecture fir16NT_proc_1;

