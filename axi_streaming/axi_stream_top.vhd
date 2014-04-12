library ieee;
use ieee.std_logic_1164.all;


entity axi_stream_top is
generic (
	AXI_SIZE		: integer := 32;
	XFER_LEN		: integer := 8
);
port (
	 -- axi CTRL
	ACLK			: in std_logic;
	ARESETN			: in std_logic;
	 -- axi SLAVE
	S_AXIS_TREADY		: out std_logic;
	S_AXIS_TDATA		: in std_logic_vector(AXI_SIZE-1 downto 0);
	S_AXIS_TLAST		: in std_logic;
	S_AXIS_TVALID		: in std_logic;
	 -- axi MASTER
	M_AXIS_TREADY		: in std_logic; 
	M_AXIS_TDATA		: out std_logic_vector(AXI_SIZE-1 downto 0);
	M_AXIS_TLAST		: out std_logic;
	M_AXIS_TKEEP		: out std_logic_vector(3 downto 0);
	M_AXIS_TVALID		: out std_logic;
	 -- appli
	gpio_write		: out std_logic;
	gpio_read		: out std_logic;
	debug			: out std_logic_vector(7 downto 0)
);

attribute SIGIS			: string;
attribute SIGIS of ACLK		: signal is "clk";

end axi_stream_top;


architecture rtl of axi_stream_top is

signal count_read		: integer range 0 to XFER_LEN;
signal count_write		: integer range 0 to XFER_LEN;

type fsm_read is (IDLE, READ);
type fsm_write is (IDLE, WRITE);
signal read_state		: fsm_read;
signal write_state		: fsm_write;

signal data_o			: std_logic_vector(AXI_SIZE-1 downto 0);
signal rst			: std_logic;


begin

rst <= not aresetn;

gpio_write <= '1' when write_state = WRITE
	else '0';
gpio_read <= '1' when read_state = READ
	else '0';

s_axis_tready <= '1' when read_state = READ else '0';
m_axis_tvalid <= '1' when write_state = WRITE else '0';

m_axis_tlast <= '1' when ( write_state = WRITE and count_write = 0 )
		else '0';

m_axis_tkeep <= X"F";
m_axis_tdata <= data_o;

streaming_p: process(aclk, rst) 
begin
	if rising_edge(aclk) then
		if rst = '1' then
			read_state <= IDLE;
			write_state <= IDLE;
			count_read <= XFER_LEN;
			count_write <= XFER_LEN;
			-- appli
			debug <= (others => '0');
			data_o <= (others => '0');
		else
			case read_state is
				when IDLE =>
					if s_axis_tvalid = '1' then
						read_state <= READ;
					else	
						count_read <= XFER_LEN;
						read_state <= IDLE;
				when READ =>
					if s_axis_tvalid = '1' then
						debug <= s_axis_tdata(7 downto 0);
						if count_read = 0 then
							read_state <= IDLE;
						else
							count_read <= count_read -1;
							read_state <= READ;
						end if;
					end if;
				when OTHERS =>
					read_state <= IDLE;
			end case;

			case write_state is
				when IDLE =>
					if m_axis_tready = '1' then
						write_state <= WRITE;
					else
						count_write <= XFER_LEN;
						write_state <= IDLE;
					end if;
				when WRITE =>
					if m_axis_tready = '1' then
						data_o <= "10101010";
						if count_write = 0 then
							write_state <= IDLE;
						else
							count_write <= count_write -1;
							write_state <= WRITE;
						end if;
					end if;
				when OTHERS =>
					write_state <= IDLE;
			end case;
		end if;
	end if;
end process streaming_p;

end rtl;
