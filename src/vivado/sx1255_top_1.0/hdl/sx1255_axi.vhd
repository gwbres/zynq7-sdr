library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity sx1255_axi is
generic
(
        AXI_SIZE: integer := 32;
        DATA_SIZE: integer := 16
);
port
(
        --AXI BUS
        AXI_Clk: in std_logic;
        AXI_Reset: in std_logic;
        --AXI DATA
        AXI_Addr: in std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_WrData: in std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_RdData: out std_logic_vector(AXI_SIZE-1 downto 0);
        AXI_CS: in std_logic_vector(1 downto 0);
	AXI_RNW: in std_logic;
        AXI_WrAck: out std_logic;
        AXI_RdAck: out std_logic;
        AXI_Error: out std_logic;
        --SPI
        spi_start: out std_logic;
	spi_data_o: out std_logic_vector(DATA_SIZE-1 downto 0);
        spi_data_i: in std_logic_vector(DATA_SIZE-1 downto 0);
        spi_busy: in std_logic;
        ps_val: out std_logic_vector(4 downto 0);
        --I2S
        q_in: out std_logic;
        i_in: out std_logic
);
end entity;


architecture rtl of sx1255_axi is

type rg is (IDLE,SPI_WRITE,SPI_READ,SPI_STATUS,ID_REQUEST,IQ_TRANSMIT,PSCALER);
signal REG: rg := IDLE;
signal spi_data_s: std_logic_vector(DATA_SIZE-1 downto 0);
signal ps_val_s: std_logic_vector(4 downto 0);
signal iq_s: std_logic_vector(1 downto 0);
signal read_data_s: std_logic_vector(AXI_SIZE-1 downto 0);

constant SPI_WRITE_REG: std_logic_vector(31 downto 0):= X"00000000";
constant SPI_READ_REG: std_logic_vector(31 downto 0) := X"00000004";
constant SPI_STATUS_REG: std_logic_vector(31 downto 0):= X"00000008";
constant IQ_TRANSMIT_REG: std_logic_vector(31 downto 0)  := X"00000010";
constant PSCALER_REG: std_logic_vector(31 downto 0)  := X"00000014";
constant ID_REQUEST_REG: std_logic_vector(31 downto 0) := X"00000018";

begin

i_in <= iq_s(0);
q_in <= iq_s(1);
ps_val <= ps_val_s;
spi_data_o <= spi_data_s;
AXI_RdData <= read_data_s;

REG <= SPI_WRITE when AXI_Addr = SPI_WRITE_REG
        else SPI_READ when AXI_Addr = SPI_READ_REG
        else SPI_STATUS when AXI_Addr = SPI_STATUS_REG
        else ID_REQUEST when AXI_Addr = ID_REQUEST_REG
        else PSCALER when AXI_Addr = PSCALER_REG
        else IQ_TRANSMIT when AXI_Addr = IQ_TRANSMIT_REG
        else IDLE;


AXI_MUX: process(AXI_Clk,AXI_Reset)
  begin
  if AXI_Reset = '1' then
        spi_data_s <= ( others => '0' );
        spi_start <= '0';
        AXI_WrAck <= '0';
        AXI_Rdack <= '0';
        AXI_Error <= '0';
        read_data_s <= (others => '0');
        ps_val_s <= B"00100";
   elsif rising_edge(AXI_Clk) then
      		ps_val_s <= ps_val_s;
		spi_start <= '0';
		iq_s <= "00";
		spi_data_s <= spi_data_s;	 
		read_data_s <= read_data_s;
		AXI_Error <= '0';
		AXI_WrAck <= '0';
		AXI_RdAck <= '0';
	if ( AXI_CS(0) = '1' and AXI_RNW = '0' ) then 	  	
	   AXI_WrAck <= '1';
	   case REG is
		when SPI_WRITE =>
                        spi_start <= '1';
                        spi_data_s <= AXI_WrData(DATA_SIZE-1 downto 0);
                when PSCALER =>
                        ps_val_s <= AXI_WrData(4 downto 0);
                when IQ_TRANSMIT =>
			iq_s <= AXI_WrData(1 downto 0);
 		when others =>
			read_data_s <= (others => '0');
			spi_data_s <= spi_data_s;
			ps_val_s <= ps_val_s;
            end case;
	
	elsif (AXI_CS(0) = '1' and AXI_RNW = '1') then
               AXI_RdAck <= '1'; 
	   case REG is 
		when SPI_READ =>
                        read_data_s(DATA_SIZE-1 downto 0) <= spi_data_i;
		when SPI_STATUS =>
                        read_data_s <= (AXI_SIZE-1 downto 1 => '0')&spi_busy;
                when ID_REQUEST =>
                        read_data_s <= X"78C00000";
		when others => 
			read_data_s <= (others => '0');
			spi_data_s <= spi_data_s;
			ps_val_s <= ps_val_s;	
	  end case;
        end if;
end if;
end process AXI_MUX;

end rtl;
                                                        
