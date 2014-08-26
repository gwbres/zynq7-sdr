library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

library iq_ram_top_v1_00_a;
use iq_ram_top_v1_00_a.iq_ram;
use iq_ram_top_v1_00_a.dual_port_ram;
use iq_ram_top_v1_00_a.iq_ctrl;
use iq_ram_top_v1_00_a.iq_axi;

entity user_logic is
  generic
  (
    C_NUM_REG                      : integer              := 8;
    C_SLV_DWIDTH                   : integer              := 32
  );
  port
  (
    -- IQ SX1255
    data_en			   : in std_logic;
    data_i			   : in std_logic_vector(15 downto 0);
    data_q			   : in std_logic_vector(15 downto 0);
    -- INT CPU
    iRQ				   : out std_logic;
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Resetn                  : in  std_logic;
    Bus2IP_Addr			   : in std_logic_vector(0 to 31);
    Bus2IP_CS	                   : in  std_logic_vector(0 to 1);
    Bus2IP_RNW                     : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    Bus2IP_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
    Bus2IP_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    Bus2IP_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    IP2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Resetn : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is
  
  signal slv_reg_write_sel              : std_logic_vector(7 downto 0);
  signal slv_reg_read_sel               : std_logic_vector(7 downto 0);
  signal slv_ip2bus_data                : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

component iq_ram is
generic(
        DATA_SIZE       : integer := 16;
        ADDR_SIZE	: integer := 13;
	AXI_SIZE        : integer := 32
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
        -- IQ SX1255
        data_en         : in std_logic;
        data_i          : in std_logic_vector(DATA_SIZE-1 downto 0);
        data_q          : in std_logic_vector(DATA_SIZE-1 downto 0);
	-- INT CPU
	iRQ		: out std_logic
);
end component;

  signal reset             		 : std_logic;
  signal addr				 : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal cs				 : std_logic_vector(1 downto 0);  
  	 
begin

reset <= not Bus2IP_Resetn;
addr(C_SLV_DWIDTH-1 downto 0) <= Bus2IP_Addr(0 to C_SLV_DWIDTH-1);
cs(1 downto 0) <= Bus2IP_CS(0 to 1);

IQ_RAM_INST: iq_ram
generic map (
        DATA_SIZE       => 16,
        ADDR_SIZE   => 13,
        AXI_SIZE        => C_SLV_DWIDTH
)
port map  (
	 -- AXi
        clk             => Bus2IP_Clk,
        rst             => reset,
        axi_addr        => addr,
        axi_wrdata      => Bus2IP_Data,
        axi_rddata      => IP2Bus_Data,
        axi_cs          => cs,
        axi_rnw         => Bus2IP_RNW,
        axi_wrack       => IP2Bus_WrAck,
        axi_rdack       => IP2Bus_RdAck,
        axi_error       => IP2Bus_Error,
        -- IQ SX1255
        data_en         => data_en,
        data_i          => data_i,
        data_q          => data_q,
        -- INT CPU
	iRQ 		=> iRQ
);

  --slv_reg_write_sel <= Bus2IP_WrCE(7 downto 0);
  --slv_reg_read_sel  <= Bus2IP_RdCE(7 downto 0);
  --slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2) or Bus2IP_WrCE(3) or Bus2IP_WrCE(4) or Bus2IP_WrCE(5) or Bus2IP_WrCE(6) or Bus2IP_WrCE(7);
  --slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2) or Bus2IP_RdCE(3) or Bus2IP_RdCE(4) or Bus2IP_RdCE(5) or Bus2IP_RdCE(6) or Bus2IP_RdCE(7);

  --IP2Bus_WrAck <= slv_write_ack;
  --IP2Bus_RdAck <= slv_read_ack;
  --IP2Bus_Error <= '0';

end IMP;
