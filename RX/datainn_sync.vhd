library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datainn_sync is
    port(
        clk : in std_logic;
        rst : in std_logic;
        dataInn : in std_logic;
        dataInn_synced : out std_logic
    );
end entity datainn_sync;


architecture RTL of datainn_sync is
    signal dataInn_sync_1 : std_logic := '1';
    signal dataInn_sync_2 : std_logic := '1';
begin
    process(clk) -- kunne bli lagt inn som komponent, men jeg synes det er bedre å bare ha den her
    begin
        if rising_edge(clk) then
            if rst = '0' then
                dataInn_sync_1 <= '1';
                dataInn_sync_2 <= '1';
            else
                dataInn_sync_1 <= dataInn;
                dataInn_sync_2 <= dataInn_sync_1;
            end if;
        end if;
    end process;
    dataInn_synced <= dataInn_sync_2;
end architecture RTL;
