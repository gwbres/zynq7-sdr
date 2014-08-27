library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity i2s is
generic (
  I2S_DATA_WIDTH   : integer := 8
);
port (
  clk : in std_logic;      
  rst : in std_logic;      
  -- i2s
  i2s_clk_i : in std_logic;
  i2s_i_i : in std_logic;
  i2s_q_i : in std_logic;
  i2s_ws_i : in std_logic;
  --IQ DATA
  data_i_o : out std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
  data_q_o : out std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
  data_en_o : out std_logic
);
end i2s;

architecture Behavioral of i2s is
        signal data_i_s, data_q_s : std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
        signal new_data_i_s, new_data_q_s : std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
        signal data_out_i_s, data_out_q_s : std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
        signal new_data_en_s, data_out_en_s : std_logic;
        signal data_i_next, data_q_next : std_logic_vector(I2S_DATA_WIDTH-1 downto 0);
        signal ws_changed_s, ws_changed_next, ws_prev_s: std_logic;
        signal delay_en_s : std_logic_vector(2 downto 0);
begin
        data_i_o <= data_out_i_s;
        data_q_o <= data_out_q_s;
        data_en_o <= data_out_en_s;
ws_changed_next <= '1' when i2s_ws_i /= ws_prev_s else '0';
        data_i_next <= data_i_s(I2S_DATA_WIDTH - 2 downto 0)&i2s_i_i;
        data_q_next <= data_q_s(I2S_DATA_WIDTH - 2 downto 0)&i2s_q_i;

        proc_synchrone_i2s: process(i2s_clk_i,rst)
        begin
                if rst = '1' then
                        ws_prev_s <= '0';
                        ws_changed_s <= '0';
                        data_i_s <= (others => '0');
                        data_q_s <= (others => '0');
                elsif rising_edge(i2s_clk_i) then
                        -- ws part --
                        ws_prev_s <= i2s_ws_i;
                        ws_changed_s <= ws_changed_next;
                        -- data part --
                        data_i_s <= data_i_next;
                        data_q_s <= data_q_next;
                end if;
        end process;

        latch_data: process(i2s_clk_i,rst)
        begin
                if rst = '1' then
                        new_data_i_s <= (others => '0');
                        new_data_q_s <= (others => '0');
                        new_data_en_s <= '0';
                elsif rising_edge(i2s_clk_i) then
                        new_data_en_s <= '0';
                        new_data_i_s <= new_data_i_s;
                        new_data_q_s <= new_data_q_s;
                        if ws_changed_s = '1' then
                                new_data_i_s <= data_i_s;
                                new_data_q_s <= data_q_s;
                                new_data_en_s <= '1';
                       end if;
                end if;
        end process;

        change_clk_domain : process(Clk,rst)
        begin
                if rst = '1' then
                        data_out_i_s <= (others => '0');
                        data_out_q_s <= (others => '0');
                        data_out_en_s <= '0';
                        delay_en_s <= (others => '0');
                elsif rising_edge(clk) then
                        data_out_i_s <= data_out_i_s;
                        data_out_q_s <= data_out_q_s;
                        data_out_en_s <= '0';
                        delay_en_s <= delay_en_s(1 downto 0)&new_data_en_s;
                        if delay_en_s(2) = '0' and delay_en_s(1) = '1' then
                                data_out_i_s <= new_data_i_s;
                                data_out_q_s <= new_data_q_s;
                                data_out_en_s <= '1';
                        end if;
                end if;
        end process;

end Behavioral;
