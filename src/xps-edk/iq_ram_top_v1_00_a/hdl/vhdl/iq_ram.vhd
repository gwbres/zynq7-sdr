library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity iq_ram is 
generic (
	DATA_SIZE 	: integer := 16;
	ADDR_SIZE	: integer := 13;
	AXI_SIZE	: integer := 32
);
port (
        -- AXi
        clk             : in std_logic;
        rst             : in std_logic;
        axi_addr        : in std_logic_vector(AXI_SIZE-1 downto 0);
        axi_wrdata      : in std_logic_vector(AXI_SIZE-1 downto 0);
        axi_rddata      : out std_logic_vector(AXI_SIZE-1 downto 0);
        axi_cs          : in std_logic_vector(1 downto 0);
        axi_rnw         : in std_logic;
        axi_wrack       : out std_logic;
        axi_rdack       : out std_logic;
        axi_error       : out std_logic;
	-- iQ SX1255
	data_en		: in std_logic;
	data_i		: in std_logic_vector(DATA_SIZE-1 downto 0);	
	data_q		: in std_logic_vector(DATA_SIZE-1 downto 0);
  	-- int CPU
	iRQ		: out std_logic
);
end entity;


architecture rtl of iq_ram is


component iq_ctrl is
generic (
        DATA_SIZE       : integer := 16;
        ADDR_SIZE   	: integer := 13;
	AXI_SIZE	: integer := 32
);
port (
        clk             : in std_logic;
        rst             : in std_logic;
	mux		: out std_logic_vector(1 downto 0);
	new_sample	: in std_logic;
	data_i_in	: in std_logic_vector(DATA_SIZE-1 downto 0);
	data_q_in	: in std_logic_vector(DATA_SIZE-1 downto 0);
	we_a		: out std_logic;
	data_a		: out std_logic_vector((2*DATA_SIZE)-1 downto 0);
	addr_a		: out std_logic_vector(ADDR_SIZE-1 downto 0);
	irq		: out std_logic
);
end component;

component iq_decim is 
generic (
	DATA_SIZE	: integer := 16;
	AXI_SIZE	: integer := 32
);
port (
	clk		: in std_logic;
	rst		: in std_logic;
	start_acq 	: in std_logic;
	decim_in	: in std_logic_vector(AXI_SIZE-1 downto 0);
	data_en		: in std_logic;
	data_i_in	: in std_logic_vector(DATA_SIZE-1 downto 0);
	data_q_in	: in std_logic_vector(DATA_SIZE-1 downto 0);
	new_sample	: out std_logic;
	data_i_out	: out std_logic_vector(DATA_SIZE-1 downto 0);
	data_q_out  	: out std_logic_vector(DATA_SIZE-1 downto 0)
);
end component;

component iq_axi is
generic (
        AXI_SIZE	: integer:= 32;
        ADDR_SIZE	: integer := 13
);
port(
        -- AXi
        clk             : in std_logic;
        rst             : in std_logic;
        axi_addr        : in std_logic_vector(AXI_SIZE-1 downto 0);
        axi_wrdata      : in std_logic_vector(AXI_SIZE-1 downto 0);
        axi_rddata      : out std_logic_vector(AXI_SIZE-1 downto 0);
        axi_cs          : in std_logic_vector(1 downto 0);
        axi_rnw         : in std_logic;
        axi_wrack       : out std_logic;
        axi_rdack       : out std_logic;
        axi_error       : out std_logic;
        -- iQ FLOW
        start_acq       : out std_logic;
	decim		: out std_logic_vector(AXI_SIZE-1 downto 0);
	mux 		: in std_logic_vector(1 downto 0);
        -- RAM
        addr_b          : out std_logic_vector(ADDR_SIZE-1 downto 0);
        data_b	        : in std_logic_vector(AXI_SIZE-1 downto 0)
);
end component;

component dual_port_ram is
generic (
	DATA    : integer := 32;
        ADDR    : integer := 13
);
  port (
        clk_a : in std_logic;
        clk_b : in std_logic;
        -- PORT A
        we_a  : in std_logic;
        addr_a: in std_logic_vector(ADDR-1 downto 0);
        din_a : in std_logic_vector(DATA-1 downto 0);
        dout_a : out std_logic_vector(DATA-1 downto 0);
        -- PORT B
        we_b  : in std_logic;
        addr_b: in std_logic_vector(ADDR-1 downto 0);
        din_b : in std_logic_vector(DATA-1 downto 0);
        dout_b: out std_logic_vector(DATA-1 downto 0)
);
end component;

signal start_acq_s 	: std_logic;
signal we_a_s		: std_logic;
signal addr_a_s		: std_logic_vector(ADDR_SIZE-1 downto 0);
signal data_a_s		: std_logic_vector(AXI_SIZE-1 downto 0);
signal addr_b_s		: std_logic_vector(ADDR_SIZE-1 downto 0);
signal din_b_s		: std_logic_vector(AXI_SIZE-1 downto 0);
signal data_b_s		: std_logic_vector(AXI_SIZE-1 downto 0);
signal mux_s		: std_logic_vector(1 downto 0);
signal decim_s		: std_logic_vector(AXI_SIZE-1 downto 0);
signal new_sample_s	: std_logic;
signal data_i_s		: std_logic_vector(DATA_SIZE-1 downto 0);
signal data_q_s		: std_logic_vector(DATA_SiZE-1 downto 0);

begin



CTRL: iq_ctrl
generic map ( 
	DATA_SIZE => DATA_SIZE,
	ADDR_SIZE => ADDR_SIZE,
	AXI_SIZE => AXI_SIZE
)
port map (
	-- Ctrl
	clk => clk,
	rst => rst,
	mux => mux_s,
	new_sample => new_sample_s,
	data_i_in => data_i_s,
	data_q_in => data_q_s,
	we_a => we_a_s,
	data_a => data_a_s,
	addr_a => addr_a_s,
	irq => irq
);

DECIM: iq_decim
generic map(
	DATA_SIZE => DATA_SIZE,
	AXI_SIZE => AXI_SIZE
)
port map (
	clk => clk,
	rst => rst,
	start_acq => start_acq_s,
	decim_in => decim_s,
	data_en => data_en,
	data_i_in => data_i,
	data_q_in => data_q,
	new_sample => new_sample_s,
	data_i_out => data_i_s,
	data_q_out => data_q_s
);

AXI: iq_axi 
generic map (
	AXI_SIZE => AXI_SIZE,
	ADDR_SIZE => ADDR_SIZE
)
port map (
	-- AXi
	clk => clk,
	rst => rst,
	axi_addr => axi_addr,
	axi_wrdata => axi_wrdata,
	axi_rddata => axi_rddata,
	axi_cs => axi_cs,	
	axi_rnw => axi_rnw,
	axi_wrack => axi_wrack,
	axi_rdack => axi_rdack,
	axi_error => axi_error,
	-- IQ Ctrl
	start_acq => start_acq_s,
	decim => decim_s,
	mux 	=> mux_s,
	-- RAM
	addr_b => addr_b_s,
	data_b => data_b_s
);

din_b_s <= (others => '0');

RAM: dual_port_ram
generic map (
	DATA => AXI_SIZE,
	ADDR => ADDR_SIZE
)
port map (
	clk_a => clk,
	clk_b => clk,
	-- PORT A
	we_a => we_a_s,	
	addr_a => addr_a_s,
	din_a => data_a_s,
	dout_a => open,
	-- PORT B
	we_b => '0',
	addr_b => addr_b_s,
	din_b => din_b_s,
	dout_b => data_b_s
);

end rtl;
