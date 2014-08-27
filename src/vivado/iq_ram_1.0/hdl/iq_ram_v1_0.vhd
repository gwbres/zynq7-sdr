library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity iq_ram_v1_0 is
generic (
  C_S00_AXI_DATA_WIDTH : integer := 32;
  C_S00_AXI_ADDR_WIDTH : integer := 5;
  I2S_DATA_WIDTH : integer := 16;
  RAM_ADDR_WIDTH : integer := 13
);
port (
  -- axi lite
  s00_axi_aclk : in std_logic;
  s00_axi_aresetn : in std_logic;
  s00_axi_awaddr : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
  s00_axi_awprot : in std_logic_vector(2 downto 0);
  s00_axi_awvalid : in std_logic;
  s00_axi_awready : out std_logic;
  s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
  s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
  s00_axi_wvalid : in std_logic;
  s00_axi_wready : out std_logic;
  s00_axi_bresp	: out std_logic_vector(1 downto 0);
  s00_axi_bvalid : out std_logic;
  s00_axi_bready : in std_logic;
  s00_axi_araddr : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
  s00_axi_arprot : in std_logic_vector(2 downto 0);
  s00_axi_arvalid : in std_logic;
  s00_axi_arready : out std_logic;
  s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
  s00_axi_rresp	: out std_logic_vector(1 downto 0);
  s00_axi_rvalid : out std_logic;
  s00_axi_rready : in std_logic;
  -- D
  data_en : in std_logic;
  data_i : in std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
  data_q : in std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
  -- IRQ
  irq : out std_logic
);
end entity iq_ram_v1_0;

architecture rtl of iq_ram_v1_0 is

component iq_ram_v1_0_S00_AXI is
generic (
  C_S_AXI_DATA_WIDTH : integer	:= 32;
  C_S_AXI_ADDR_WIDTH : integer	:= 5;
  RAM_ADDR_WIDTH : integer := 13
);
port (
  -- axi lite
  S_AXI_ACLK	: in std_logic;
  S_AXI_ARESETN	: in std_logic;
  S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
  S_AXI_AWVALID	: in std_logic;
  S_AXI_AWREADY	: out std_logic;
  S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
  S_AXI_WVALID	: in std_logic;
  S_AXI_WREADY	: out std_logic;
  S_AXI_BRESP	: out std_logic_vector(1 downto 0);
  S_AXI_BVALID	: out std_logic;
  S_AXI_BREADY	: in std_logic;
  S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
  S_AXI_ARVALID	: in std_logic;
  S_AXI_ARREADY	: out std_logic;
  S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_RRESP	: out std_logic_vector(1 downto 0);
  S_AXI_RVALID	: out std_logic;
  S_AXI_RREADY	: in std_logic;
  -- flow
  start : out std_logic;
  decimation : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  ram_status : in std_logic_vector(1 downto 0);
  -- ram
  ram_ptr : out std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
  ram_data : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
);
end component iq_ram_v1_0_S00_AXI;

component dual_port_ram is
generic (
  DATA : integer := 72;
  ADDR : integer := 10
);
port (
  clk_a : in std_logic;
  clk_b : in std_logic;
  we_a  : in std_logic;
  addr_a: in std_logic_vector(ADDR-1 downto 0);
  din_a : in std_logic_vector(DATA-1 downto 0);
  dout_a : out std_logic_vector(DATA-1 downto 0);
  we_b  : in std_logic;
  addr_b: in std_logic_vector(ADDR-1 downto 0);
  din_b : in std_logic_vector(DATA-1 downto 0);
  dout_b: out std_logic_vector(DATA-1 downto 0)
);
end component dual_port_ram;

component iq_decim is
generic (
  I2S_DATA_WIDTH : integer := 16;
  AXI_DATA_WIDTH : integer := 32
);
port (
  clk : in std_logic;
  rst : in std_logic;
  start_acq : in std_logic;
  decim_in : in std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
  data_en : in std_logic;
  data_i_in : in std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
  data_q_in : in std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
  new_sample : out std_logic;
  data_i_out : out std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
  data_q_out : out std_logic_vector(I2S_DATA_WIDTH-1 downto 0)
);
end component iq_decim;

component iq_ctrl is
generic (
  I2S_DATA_WIDTH : integer := 16;
  RAM_ADDR_WIDTH : integer := 13;
  AXI_DATA_WIDTH : integer := 32
);
port (
  clk : in std_logic;
  rst : in std_logic;
  mux : out std_logic_vector(1 downto 0);
  new_sample : in std_logic;
  data_i_in : in std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
  data_q_in : in std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
  we_a : out std_logic;
  data_a : out std_logic_vector((2*I2S_DATA_WIDTH)-1 downto 0);
  addr_a : out std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
  irq : out std_logic
);
end component iq_ctrl;

signal start_s, rst, we_a_s, new_sample_s : std_logic;
signal addr_a_s, addr_b_s : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
signal data_a_s, data_b_s : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal ram_status_s : std_logic_vector(1 downto 0);
signal data_i_s, data_q_s : std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
signal decim_s : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);

begin
	
  rst <= not s00_axi_aresetn;

iq_ram_v1_0_S00_AXI_inst : iq_ram_v1_0_S00_AXI
generic map (
  C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
  C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH,
  RAM_ADDR_WIDTH => RAM_ADDR_WIDTH
)
port map (
  S_AXI_ACLK => s00_axi_aclk,
  S_AXI_ARESETN	=> s00_axi_aresetn,
  S_AXI_AWADDR => s00_axi_awaddr,
  S_AXI_AWPROT	=> s00_axi_awprot,
  S_AXI_AWVALID	=> s00_axi_awvalid,
  S_AXI_AWREADY	=> s00_axi_awready,
  S_AXI_WDATA => s00_axi_wdata,
  S_AXI_WSTRB => s00_axi_wstrb,
  S_AXI_WVALID => s00_axi_wvalid,
  S_AXI_WREADY => s00_axi_wready,
  S_AXI_BRESP => s00_axi_bresp,
  S_AXI_BVALID	=> s00_axi_bvalid,
  S_AXI_BREADY	=> s00_axi_bready,
  S_AXI_ARADDR	=> s00_axi_araddr,
  S_AXI_ARPROT => s00_axi_arprot,
  S_AXI_ARVALID	=> s00_axi_arvalid,
  S_AXI_ARREADY	=> s00_axi_arready,
  S_AXI_RDATA => s00_axi_rdata,
  S_AXI_RRESP => s00_axi_rresp,
  S_AXI_RVALID => s00_axi_rvalid,
  S_AXI_RREADY => s00_axi_rready,
  -- flow
  start => start_s,
  decimation => decim_s,
  ram_status => ram_status_s,
  -- ram
  ram_ptr => addr_b_s,
  ram_data => data_b_s
);

IQ_DECIM_FLOW: iq_decim
generic map (
  I2S_DATA_WIDTH => I2S_DATA_WIDTH,
  AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH
)
port map (
  clk => s00_axi_aclk,
  rst => rst,
  start_acq => start_s,
  decim_in => decim_s,
  data_en => data_en,
  data_i_in => data_i,
  data_q_in => data_q,
  new_sample => new_sample_s,
  data_i_out => data_i_s,
  data_q_out => data_q_s
);

IQ_FLOW: iq_ctrl
generic map (
  I2S_DATA_WIDTH => I2S_DATA_WIDTH,
  RAM_ADDR_WIDTH => RAM_ADDR_WIDTH,
  AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH
)
port map (
  clk => s00_axi_aclk,
  rst => rst,
  mux => ram_status_s,
  new_sample => new_sample_s,
  data_i_in => data_i_s,
  data_q_in => data_q_s,
  we_a => we_a_s,
  data_a => data_a_s,
  addr_a => addr_a_s,
  irq => irq
);

RAM_INST: dual_port_ram
generic map (
  DATA => C_S00_AXI_DATA_WIDTH,
  ADDR => RAM_ADDR_WIDTH
)
port map (
  clk_a => s00_axi_aclk,
  clk_b => s00_axi_aclk,
  we_a => we_a_s,
  addr_a => addr_a_s,
  din_a => data_a_s,
  dout_a => open,
  we_b => '0',
  addr_b => addr_b_s,
  din_b => (others => '0'),
  dout_b => data_b_s
);
end rtl;
