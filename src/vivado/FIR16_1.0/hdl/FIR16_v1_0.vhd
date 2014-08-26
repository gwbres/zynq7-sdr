library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity FIR16_v1_0 is
generic (
  C_S00_AXI_DATA_WIDTH : integer := 32;
  C_S00_AXI_ADDR_WIDTH : integer := 4;
  USE_CORE_CLOCK : boolean := true;
  DECIM_FACTOR : natural := 50;
  NB_COEFF : natural := 36;
  COEFF_WIDTH : natural := 8;
  DATA_IN_WIDTH : natural := 16;
  DATA_OUT_WIDTH : natural := 32
);
port (
  -- axi lite
  s00_axi_aclk : in std_logic;
  s00_axi_aresetn : in std_logic;
  s00_axi_awaddr : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
  s00_axi_awprot : in std_logic_vector(2 downto 0);
  s00_axi_awvalid : in std_logic;
  s00_axi_awready : out std_logic;
  s00_axi_wdata : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
  s00_axi_wstrb : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
  s00_axi_wvalid : in std_logic;
  s00_axi_wready : out std_logic;
  s00_axi_bresp : out std_logic_vector(1 downto 0);
  s00_axi_bvalid : out std_logic;
  s00_axi_bready : in std_logic;
  s00_axi_araddr : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
  s00_axi_arprot : in std_logic_vector(2 downto 0);
  s00_axi_arvalid : in std_logic;
  s00_axi_arready : out std_logic;
  s00_axi_rdata : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
  s00_axi_rresp : out std_logic_vector(1 downto 0);
  s00_axi_rvalid : out std_logic;
  s00_axi_rready : in std_logic;
  -- ext ctrl
  ext_clock : in std_logic;
  ext_reset : in std_logic; 
  -- data in 
  data_i_in : in std_logic_vector(DATA_IN_WIDTH-1 downto 0);
  data_q_in : in std_logic_vector(DATA_IN_WIDTH-1 downto 0);
  data_en_in : in std_logic;
  -- data out 
  data_i_out : out std_logic_vector(DATA_OUT_WIDTH-1 downto 0);
  data_q_out : out std_logic_vector(DATA_OUT_WIDTH-1 downto 0);
  data_en_out : out std_logic
);
end entity FIR16_v1_0;

architecture rtl of FIR16_v1_0 is

signal rst : std_logic;
signal processing_clk_s, processing_rst_s : std_logic;
signal coeff_en_s : std_logic;
signal coeff_val_s : std_logic_vector(15 downto 0);
signal coeff_val2_s : std_logic_vector(COEFF_WIDTH-1 downto 0);
signal coeff_addr_s : std_logic_vector(9 downto 0);

component FIR16_v1_0_S00_AXI is
generic (
  C_S_AXI_DATA_WIDTH : integer := 32;
  C_S_AXI_ADDR_WIDTH : integer := 4
);
port (
  -- AXI
  S_AXI_ACLK : in std_logic;
  S_AXI_ARESETN	: in std_logic;
  S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_AWPROT : in std_logic_vector(2 downto 0);
  S_AXI_AWVALID	: in std_logic;
  S_AXI_AWREADY	: out std_logic;
  S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
  S_AXI_WVALID : in std_logic;
  S_AXI_WREADY : out std_logic;
  S_AXI_BRESP : out std_logic_vector(1 downto 0);
  S_AXI_BVALID : out std_logic;
  S_AXI_BREADY : in std_logic;
  S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_ARPROT : in std_logic_vector(2 downto 0);
  S_AXI_ARVALID	: in std_logic;
  S_AXI_ARREADY	: out std_logic;
  S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_RRESP : out std_logic_vector(1 downto 0);
  S_AXI_RVALID : out std_logic;
  S_AXI_RREADY : in std_logic;
  -- FIR
  coeff_en_o : out std_logic;
  coeff_val_o : out std_logic_vector(15 downto 0);
  coeff_addr_o : out std_logic_vector(9 downto 0)
);
end component FIR16_v1_0_S00_AXI;

component fir16bitsNT is
generic (
  COEFF_SIZE : natural := 8;
  DECIM_FACTOR : natural := 50;
  NB_COEFF : natural := 36;
  DATA_OUT_SIZE : natural := 32;
  DATA_IN_SIZE : natural := 16
);
port (
  processing_rst_i : in std_logic;
  processing_clk_i : in std_logic;
  reset : in std_logic;
  clk : in std_logic;
  coeff_data_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
  coeff_addr_i : in std_logic_vector(9 downto 0);
  coeff_en_i : in std_logic;
  data_i_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
  data_q_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
  data_en_i : in std_logic;
  data_i_o : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
  data_q_o : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
  data_en_o : out std_logic
);
end component fir16bitsNT;

begin
  
  rst <= not s00_axi_aresetn;

core_clk : if USE_CORE_CLOCK = true generate
  processing_clk_s <= s00_axi_aclk;
  processing_rst_s <= not s00_axi_aresetn;
end generate core_clk;

external_clk : if USE_CORE_CLOCK = false generate
  processing_clk_s <= ext_clock;
  processing_rst_s <= ext_reset;
end generate external_clk;

coeff_same : if COEFF_WIDTH = 16 generate
  coeff_val2_s <= coeff_val_s;
end generate coeff_same;

coeff_diff : if COEFF_WIDTH = 16 generate
  coeff_val2_s <= coeff_val_s(COEFF_WIDTH-1 downto 0);
end generate coeff_diff;

fir1_inst: fir16bitsNT
generic map (
  DECIM_FACTOR => DECIM_FACTOR,
  NB_COEFF => NB_COEFF,
  COEFF_SIZE => COEFF_WIDTH,
  DATA_OUT_SIZE => DATA_OUT_WIDTH,
  DATA_IN_SIZE => DATA_IN_WIDTH
)
port map (
  reset => rst,
  clk => s00_axi_aclk,
  processing_rst_i => processing_rst_s,
  processing_clk_i => processing_clk_s,
  coeff_data_i => coeff_val2_s,
  coeff_addr_i => coeff_addr_s,
  coeff_en_i => coeff_en_s,
  data_i_i => data_i_in,
  data_q_i => data_q_in,
  data_en_i => data_en_in,
  data_i_o => data_i_out,
  data_q_o => data_q_out,
  data_en_o => data_en_out
);

FIR16_v1_0_S00_AXI_inst : FIR16_v1_0_S00_AXI
generic map (
  C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
  C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
)
port map (
  -- AXI
  S_AXI_ACLK => s00_axi_aclk,
  S_AXI_ARESETN	=> s00_axi_aresetn,
  S_AXI_AWADDR	=> s00_axi_awaddr,
  S_AXI_AWPROT	=> s00_axi_awprot,
  S_AXI_AWVALID	=> s00_axi_awvalid,
  S_AXI_AWREADY	=> s00_axi_awready,
  S_AXI_WDATA	=> s00_axi_wdata,
  S_AXI_WSTRB	=> s00_axi_wstrb,
  S_AXI_WVALID	=> s00_axi_wvalid,
  S_AXI_WREADY	=> s00_axi_wready,
  S_AXI_BRESP	=> s00_axi_bresp,
  S_AXI_BVALID	=> s00_axi_bvalid,
  S_AXI_BREADY	=> s00_axi_bready,
  S_AXI_ARADDR	=> s00_axi_araddr,
  S_AXI_ARPROT	=> s00_axi_arprot,
  S_AXI_ARVALID	=> s00_axi_arvalid,
  S_AXI_ARREADY	=> s00_axi_arready,
  S_AXI_RDATA	=> s00_axi_rdata,
  S_AXI_RRESP	=> s00_axi_rresp,
  S_AXI_RVALID	=> s00_axi_rvalid,
  S_AXI_RREADY	=> s00_axi_rready,
  -- FIR
  coeff_en_o => coeff_en_s,
  coeff_val_o => coeff_val_s,
  coeff_addr_o => coeff_addr_s
);

end rtl;
