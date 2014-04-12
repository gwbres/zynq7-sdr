library ieee;
use ieee.std_logic_1164.all;


entity zynq_led is
generic (
	AXI_SIZE		: integer := 32
);
port (
	-- AXi
	clk			: in std_logic;
	rst			: in std_logic;
	axi_addr		: in std_logic_vector(AXI_SIZE-1 downto 0);
	axi_wrdata		: in std_logic_vector(AXI_SIZE-1 downto 0);
	axi_rddata		: out std_logic_vector(AXI_SIZE-1 downto 0);
	axi_cs			: in std_logic_vector(1 downto 0);
	axi_rnw			: in std_logic;
	axi_wrack		: out std_logic;
	axi_rdack		: out std_logic;
	axi_error		: out std_logic;
	-- appli
	leds			: out std_logic_vector(7 downto 0)
);
end entity;


architecture rtl of zynq_led is 

type rg is (IDLE, WRITE, STATUS, ID);
signal REG                      : rg := IDLE;

constant WRITE_REG		: std_logic_vector(AXI_SIZE-1 downto 0) := X"00000004";
constant ID_REQUEST_REG         : std_logic_vector(AXI_SIZE-1 downto 0) := X"0000000C";
constant STATUS_REG             : std_logic_vector(AXI_SIZE-1 downto 0) := X"00000008";
signal read_s                   : std_logic_vector(AXI_SIZE-1 downto 0);
signal leds_s			: std_logic_vector(7 downto 0);

begin

	axi_rddata <= read_s;
	REG <= WRITE when axi_addr = WRITE_REG
		else STATUS when axi_addr = STATUS_REG
		else ID when axi_addr = ID_REQUEST_REG
		else IDLE;
	leds <= leds_s;

AXI_MUX: process(clk,rst)
begin
        if rst = '1' then
                axi_wrack <= '0';
                axi_rdack <= '0';
                axi_error <= '0';
                read_s <= (others => '0');
                -- appli
		leds_s <= (others => '0');
        elsif rising_edge(clk) then
                read_s <= read_s;
                axi_error <= '0';
                axi_rdack <= '0';
                axi_wrack <= '0';
                -- appli		
		leds_s <= leds_s;
                if axi_cs(0) = '1' and axi_rnw = '0' then
                        axi_wrack <= '1';
                        case REG is
                                when WRITE =>
                                	leds_s <= axi_wrdata(7 downto 0);
				when IDLE =>
                                when OTHERS =>
			end case;
                elsif axi_cs(0) = '1' and axi_rnw = '1' then
                        axi_rdack <= '1';
                        case REG is
                                when STATUS =>
                                        read_s <= (AXI_SIZE-1 downto 8 => '0')&leds_s;
                                when ID =>
                                        read_s<= X"7e400000";
                                when IDLE =>
                                when OTHERS =>
                        end case;
                end if;
        end if;
end process AXI_MUX;

end rtl;
