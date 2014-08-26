library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity iq_axi is
generic (
	AXI_SIZE	: integer:= 32;
	ADDR_SIZE	: integer := 13
);
port(
	-- AXi
	clk		: in std_logic;
	rst		: in std_logic;
	axi_addr	: in std_logic_vector(AXI_SIZE-1 downto 0);
	axi_wrdata	: in std_logic_vector(AXI_SIZE-1 downto 0);
	axi_rddata	: out std_logic_vector(AXI_SIZE-1 downto 0);
	axi_cs		: in std_logic_vector(1 downto 0);
	axi_rnw		: in std_logic;
	axi_wrack	: out std_logic;
	axi_rdack	: out std_logic;
	axi_error	: out std_logic;
	-- iQ CTRL
	start_acq	: out std_logic;
	decim		: out std_logic_vector(AXI_SIZE-1 downto 0);
	mux		: in std_logic_vector(1 downto 0);
	-- RAM
	addr_b		: out std_logic_vector(ADDR_SIZE-1 downto 0);
	data_b		: in std_logic_vector(AXI_SIZE-1 downto 0)
);
end entity;

architecture rtl of iq_axi is

type rg is (IDLE, START,RESET, READ, STATUS, DECIMATE, ID);
signal REG			: rg := IDLE;

constant START_ACQUISITION_REG 	: std_logic_vector := X"00000004";
constant STATUS_REG		: std_logic_vector := X"00000008";
constant DECIM_FACTOR_REG	: std_logic_vector := X"0000001C";
constant RESET_RAM_ADDRESS_REG  : std_logic_vector := X"00000018"; 
constant READ_RAM_REG		: std_logic_vector := X"00000014";
constant ID_REQUEST_REG		: std_logic_vector := X"0000000C";
constant FULL			: integer := (2**ADDR_SIZE)-1;
constant HALF_FULL		: integer := ((2**ADDR_SIZE)/2)-1;
signal addr_int			: integer range 0 to (2**ADDR_SIZE)-1; 
signal start_acq_s		: std_logic;
signal read_s			: std_logic_vector(AXI_SIZE-1 downto 0);
signal decim_s			: std_logic_vector(AXI_SIZE-1 downto 0);
signal axi_rise			: std_logic;


begin

REG <= START when axi_addr = START_ACQUISITION_REG 
	else RESET when axi_addr = RESET_RAM_ADDRESS_REG
	else READ when axi_addr = READ_RAM_REG
	else ID when axi_addr = ID_REQUEST_REG
	else DECIMATE when axi_addr = DECIM_FACTOR_REG
	else STATUS when axi_addr = STATUS_REG
	else IDLE;

	addr_b <= std_logic_vector(to_unsigned(addr_int,ADDR_SIZE));
	start_acq <= start_acq_s;
	axi_rddata <= read_s;
	decim <= decim_s;

rise_p: process (clk, rst)
variable signal_old		: std_logic;
begin
	if rst = '1' then
		axi_rise <= '0';
		signal_old := '0';
	elsif rising_edge(clk) then
		if signal_old = '0' and axi_cs(0) = '1' then
			axi_rise <= '1';
		else
			axi_rise <= '0';
		end if;
		signal_old := axi_cs(0);
	end if;
end process rise_p;

AXI_MUX: process(clk,rst)
begin
	if rst = '1' then
		axi_wrack <= '0';
		axi_rdack <= '0';
		axi_error <= '0';
		read_s <= (others => '0');
		-- appli
		start_acq_s <= '0';
		addr_int <= HALF_FULL;
		decim_s <= (31 downto 8 => '0')&"00110010"; -- 50 as default 
	elsif rising_edge(clk) then
		read_s <= read_s;
		axi_error <= '0';
		axi_rdack <= '0';
		axi_wrack <= '0';
		-- appli
		start_acq_s <= start_acq_s;
		addr_int <= addr_int;
		decim_s <= decim_s;
		if axi_rise = '1' and axi_rnw = '0' then
			axi_wrack <= '1';
			case REG is
				when RESET =>
					addr_int <= 0;	
				when START =>
					start_acq_s <= axi_wrdata(0);
				when DECIMATE =>
					decim_s <= axi_wrdata;
				when IDLE =>
				when OTHERS =>
	
			end case;
		elsif axi_rise = '1' and axi_rnw = '1' then
			axi_rdack <= '1';
			case REG is
				when STATUS =>
					read_s <= (AXI_SIZE-1 downto 2 => '0')&mux;
				when READ =>
					read_s <= data_b;
					if addr_int = FULL then
						addr_int <= 0;
					else	
						addr_int <= addr_int +1;
					end if;
				when ID =>
					read_s <= X"6AC00000";
				when IDLE =>
				when OTHERS =>
					
			end case;
		end if;
	end if;
end process AXI_MUX;

end rtl;
