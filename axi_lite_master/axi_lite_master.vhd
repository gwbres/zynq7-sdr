library ieee;
use ieee.std_logic_1164.all;

entity axi_lite_master is
generic (
	AXI_SIZE		: integer := 32
);
port (
	-- AXi CTRL
	clk			: in std_logic;
	aresetn			: in std_logic;
	-- AXi BUS
	axi_rdreq		: out std_logic;
	axi_wrreq		: out std_logic;
	axi_addr		: out std_logic_vector(AXI_SIZE-1 downto 0);
	axi_wrdata		: out std_logic_vector(AXI_SIZE-1 downto 0);
	axi_rddata		: in std_logic_vector(AXI_SIZE-1 downto 0);
	axi_be			: out std_logic_vector(3 downto 0);
	axi_src_rdy		: in std_logic;
	axi_dst_rdy		: in std_logic;
	axi_cmdack		: in std_logic;
	axi_cmplt		: in std_logic;
	axi_error		: in std_logic;
	-- application
	write_req		: in std_logic;
	read_req		: in std_logic

);
end entity;

architecture rtl of axi_lite_master is 

type fsm is (IDLE, READ, WRITE);
signal state 			: fsm;

signal addr_s 			: std_logic_vector(AXI_SIZE-1 downto 0);
signal be_s			: std_logic_vector(3 downto 0);
signal data_o_s			: std_logic_vector(AXI_SIZE-1 downto 0);
signal data_i_s			: std_logic_vector(AXI_SIZE-1 downto 0);

constant REG			: std_logic_vector(AXI_SIZE-1 downto 0) := X"7E400004";

begin

axi_addr <= addr_s;
axi_be <= be_s;
rst <= not aresetn;
axi_wrdata <= data_o_s;

state_p: process(clk, rst, write_req, read_req)
begin

	if rising_edge(clk) then
		if rst = '1' then
			state <= IDLE;
			axi_wrreq <= '0';
			axi_rdreq <= '0';
			addr_s <= (others => '0');
			be_s <= (others => '0');
			data_o_s <= (others => '0');
		else
			case state is 
				when IDLE =>
					if write_req = '1' and read_req = '0' then
						state <= WRITE;
					elsif read_req = '1' and write_req = '0' then
						state <= READ;
					else
						addr_s <= (others => '0');
						axi_wrreq <= '0';
						axi_rdreq <= '0';
						data_o_s <= (others => '0');
						data_i_s <= (others => '0');
						state <= IDLE;
					end if;

				when WRITE =>
					if axi_cmplt = '1' and axi_dst_rdy = '0' or axi_error = '1' then
						addr_s <= (others => '0');
						axi_wrreq <= '0';
						be_s <= (others => '0');
						data_o_s <= (others => '0');
						state <= IDLE;
					else
						axi_wrreq <= '1';
						addr_s <= REG;
						data_o_s <= X"FFFFFFFF";
						be_s <= X"F";
						state <= WRITE;
					end if;
				
				when READ => 
					if axi_cmplt = '1' and axi_src_rdy = '0' or axi_error = '1' then
						axi_rdreq <= '0';
						addr_s <= (others => '0');
						data_i_s <= axi_rddata;
						state <= IDLE;
					else
						axi_rdreq <= '1';
						addr_s <= REG;
						state <= READ;
					end if;	
				when OTHERS =>
						state <= IDLE;
			end case;
		end if;
	end if;
end process axi_master;

end rtl;
