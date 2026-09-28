library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity O1_Reset_Synchronizer is
port(
clk : in std_logic;
areset_n : in std_logic;
reset_clk : out std_logic
);
end entity O1_Reset_Synchronizer;


architecture RTL of O1_Reset_Synchronizer is
    signal dff : std_logic;
begin
    p_reset : process(clk, areset_n)
    begin
        if (areset_n) = '0' then
            dff <= '0';
            reset_clk <= '0';
        elsif (rising_edge(clk)) then
            dff <= '1';
            reset_clk <= dff;
        end if;
        end process;

end architecture RTL;
