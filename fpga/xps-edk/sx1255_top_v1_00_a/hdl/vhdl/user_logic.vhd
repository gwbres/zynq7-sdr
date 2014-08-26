
-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

--USER libraries added here
library sx1255_top_v1_00_a;
use sx1255_top_v1_00_a.spi_baud;
use sx1255_top_v1_00_a.spi_send_recv;
use sx1255_top_v1_00_a.spi;
use sx1255_top_v1_00_a.sx1255_axi;
use sx1255_top_v1_00_a.i2s;
use sx1255_top_v1_00_a.sx1255;
        
------------------------------------------------------------------------------

entity user_logic is
  generic
  (

        DATA_SIZE: integer :=16;
        INTERNAL_DATA_SIZE: integer :=9;
        AXI_SIZE: integer := 32;
        SPI_SIZE: integer := 8;
        I2S_SIZE: integer := 8;


    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_NUM_REG                      : integer              := 1;
    C_SLV_DWIDTH                   : integer              := 32
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (

    -- IQ RECU
        i_in: out std_logic;
        q_in: out std_logic;
        data_i: out std_logic_vector(DATA_SIZE-1 downto 0);
        data_q: out std_logic_vector(DATA_SIZE-1 downto 0);
        data_en: out std_logic;
        --I2S IQ EMMISSION
        ck_out: in std_logic;
        q_out: in std_logic;
        i_out: in std_logic;
        i2s_ws: in std_logic;
        --SPI
        MOSI: out std_logic;
        MISO: in std_logic;
        CS: out std_logic;
        SCLK: out std_logic;


    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Resetn                  : in  std_logic;
    Bus2IP_Addr                    : in  std_logic_vector(0 to 31);
    Bus2IP_CS                      : in  std_logic_vector(0 to 1);
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

  component sx1255 is 
  generic
(
        DATA_SIZE: integer :=16;
        INTERNAL_DATA_SIZE: integer :=9;
        AXI_SIZE: integer := 32;
        SPI_SIZE: integer := 8;
        I2S_SIZE: integer := 8
);
port
(
        -- Ctrl
        AXI_Clk: in std_logic;
        AXI_Reset: in std_logic;
        -- AXI
        AXI_Addr: in std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_WrData: in std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_RdData: out std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_CS: in std_logic_vector(1 downto 0);
        AXI_RNW: in std_logic;
        AXI_WrAck: out std_logic;
        AXI_RdAck: out std_logic;
        AXI_Error: out std_logic;
        -- IQ RECU
        i_in: out std_logic;
        q_in: out std_logic;
        data_i_o: out std_logic_vector(DATA_SIZE-1 downto 0);
        data_q_o: out std_logic_vector(DATA_SIZE-1 downto 0);
        data_en_o: out std_logic;
        --I2S IQ EMMISSION
        ck_out: in std_logic;
        q_out: in std_logic;
        i_out: in std_logic;
        i2s_ws: in std_logic;
	--SPI
        MOSI: out std_logic;
        MISO: in std_logic;
        CS: out std_logic;
        SCLK: out std_logic
);
end component;

  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg_write_sel              : std_logic_vector(0 to 0);
  signal slv_reg_read_sel               : std_logic_vector(0 to 0);
  signal slv_ip2bus_data                : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;
  signal Bus_addr : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal Bus_reset: std_logic;
  signal Bus_cs: std_logic_vector(1 downto 0);


begin

  Bus_addr( 31 downto 0) <= Bus2IP_addr(0 to 31);
  Bus_reset <= not Bus2IP_Resetn;
  Bus_cs(1 downto 0) <= Bus2IP_CS(0 to 1);

  SX1255_INST: sx1255 
  generic map
  (
        DATA_SIZE => DATA_SIZE,
        INTERNAL_DATA_SIZE => INTERNAL_DATA_SIZE,
        AXI_SIZE => C_SLV_DWIDTH,
        SPI_SIZE => SPI_SIZE,
        I2S_SIZE => I2S_SIZE
  )
 port map
  (
   -- Ctrl
        AXI_Clk => Bus2IP_Clk,
        AXI_Reset => Bus_reset,
        -- AXI
        AXI_Addr => Bus_addr,
        AXI_WrData => Bus2IP_Data,
        AXI_RdData => IP2Bus_Data,
        AXI_CS => Bus_CS,
        AXI_RNW => Bus2IP_RNW, 
        AXI_WrAck => IP2Bus_WrAck,
        AXI_RdAck => IP2Bus_RdAck,
        AXI_Error => IP2Bus_Error,
        -- IQ RECU
        i_in => i_in,
        q_in => q_in,
        data_i_o => data_i,
        data_q_o => data_q,
        data_en_o => data_en,
        --I2S IQ EMMISSION
        ck_out => ck_out,
        q_out => q_out,
        i_out => i_out,
        i2s_ws => i2s_ws,
        --SPI
        MOSI => MOSI,
        MISO => MISO,
        CS => CS,
        SCLK => SCLK
   );
 
  slv_reg_write_sel <= Bus2IP_WrCE(0 downto 0);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 downto 0);
  slv_write_ack     <= Bus2IP_WrCE(0);
  slv_read_ack      <= Bus2IP_RdCE(0);


  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  --IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
    --              (others => '0');

  --IP2Bus_WrAck <= slv_write_ack;
  --IP2Bus_RdAck <= slv_read_ack;
 -- IP2Bus_Error <= '0';

end IMP;
