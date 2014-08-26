library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fir16bitsNT is 
	generic (
		COEFF_SIZE : natural := 8;
		DECIM_FACTOR: natural := 50;
		NB_COEFF : natural := 36;
		DATA_OUT_SIZE : natural := 32;
		DATA_IN_SIZE : natural := 16
	);
	port 
	(
		-- Syscon signals
		processing_rst_i		 : in std_logic;
		processing_clk_i		   : in std_logic;
		reset		 : in std_logic;
		clk : in std_logic;
		-- filter coeffs
		coeff_data_i : std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_addr_i : std_logic_vector(9 downto 0);
		coeff_en_i : std_logic;
		-- input data
		data_i_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i: std_logic;
		-- for the next component
		data_q_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_i_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o : out std_logic
	);
end entity;

---------------------------------------------------------------------------
Architecture fir16bitsNT_1 of fir16bitsNT is
---------------------------------------------------------------------------
	
	--compter	
	signal cpt_overflow_s : std_logic;
	signal counter_ram_s : std_logic_vector(9 downto 0);
	-- coeff for write 
	signal coeff_addr_s : std_logic_vector(9 downto 0);
	signal coeff_en_s : std_logic;
	signal coeff_val_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	-- data reception
	signal enable_s, enable2_s : std_logic;
	signal data_i_s : std_logic_vector(DATA_IN_SIZE-1 downto 0);
	signal data_q_s : std_logic_vector(DATA_IN_SIZE-1 downto 0);
	-- coeff for read
	signal ram_val_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	
	-- data output
	signal data_out_i_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal data_out_q_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal data_en_s : std_logic;
	
	-- result
	signal result_en_s : std_logic;
	signal result_i_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal result_q_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal start_proc_s: std_logic;
	signal enable_accum_s: std_logic;
begin

	data_i_o <= data_out_i_s;
	data_q_o <= data_out_q_s;
	data_en_o <= data_en_s;
	
	-- add one clk delay 
	process(processing_clk_i, processing_rst_i)
	begin
		if processing_rst_i = '1' then
			data_i_s <= (others => '0');
			data_q_s <= (others => '0');
			enable_s <= '0';
		elsif rising_edge(processing_clk_i) then
			data_i_s <= data_i_s;
			data_q_s <= data_q_s;
			enable_s <= '0';
			if data_en_i = '1' then
				enable_s <= '1';
				data_i_s <= data_i_i;
				data_q_s <= data_q_i;
			end if;
		end if;
	end process;

	enable2_s <= enable_s and enable_accum_s;
	
	process(processing_clk_i, processing_rst_i)
	begin
		if processing_rst_i = '1' then
			enable_accum_s <= '0';
		elsif rising_edge(processing_clk_i) then
			enable_accum_s <= enable_accum_s;
			if start_proc_s = '1' then
				enable_accum_s <= '1';
			end if;
			if result_en_s = '1' then
				enable_accum_s <= '0';
			end if;
		end if;
	end process;

	-- output one IQ data from one of NB_FIR 
	-- blocks
	process(processing_clk_i, processing_rst_i)
	begin
		if processing_rst_i = '1' then
			data_out_i_s <= (others => '0');
			data_out_q_s <= (others => '0');
			data_en_s <= '0';
		elsif rising_edge(processing_clk_i) then
			data_out_i_s <= data_out_i_s;
			data_out_q_s <= data_out_q_s;
			data_en_s <= '0';
			if result_en_s = '1' then
				data_out_i_s <= result_i_s;
				data_out_q_s <= result_q_s;
				data_en_s <= '1';
			end if;
		end if;
	end process;
	
	fir1_inst : entity work.fir16NT_direct
	generic map (
		COEFF_SIZE => COEFF_SIZE,
		DATA_OUT_SIZE => DATA_OUT_SIZE,
		DATA_SIZE => DATA_IN_SIZE
	)
	port map
	(
		-- Syscon signals
		reset		=> processing_rst_i,
		clk			=> processing_clk_i,
		-- input datas
		coeff_i => ram_val_s,
		enable_accum_i => enable_accum_s,
		data_i_i => data_i_s,
		data_q_i => data_q_s,
		data_en_i => enable2_s,
		reset_accum_i => cpt_overflow_s,
		-- for the output
		data_i_o	=> result_i_s,
		data_q_o	=> result_q_s,
		data_en_o	=> result_en_s
	);

	-- donne l'offset pour les RAMS
	cpt_ram : entity work.fir16NT_cpt
	generic map(
		NB_BITS => 10,
		MAX_VAL => NB_COEFF
	)
	port map (
		-- Syscon signals
		reset_i 	=> processing_rst_i,
		clk_i		=> processing_clk_i,
		enable_counter_i => enable_accum_s,
		-- input datas
		cpt_en		=> data_en_i,
		cpt_overflow_o	=> cpt_overflow_s,
		cpt_val_o	=> counter_ram_s
	);	

	-- donne le demarrage de la convolution
	cpt_start : entity work.fir16NT_cpt
	generic map(
		NB_BITS => 10,
		MAX_VAL => DECIM_FACTOR
	)
	port map (
		-- Syscon signals
		reset_i 	=> processing_rst_i,
		clk_i		=> processing_clk_i,
		enable_counter_i => '1',
		-- input datas
		cpt_en		=> data_en_i,
		cpt_overflow_o	=> start_proc_s,
		cpt_val_o	=> open
	);	

	ram1 : entity work.fir16NT_ram
	generic map (
		DATA => COEFF_SIZE,
		ADDR => 10
	)
	port map (
		clk_a => clk,
		clk_b => processing_clk_i,
		reset => processing_rst_i,
		-- input datas
		we_a => coeff_en_i,
		addr_a => coeff_addr_i,
		din_a => coeff_data_i,
		-- output
		we_b => '0',
		addr_b => counter_ram_s,
		din_b => (others => '0'),
		dout_b => ram_val_s  
	);

end architecture fir16bitsNT_1;

