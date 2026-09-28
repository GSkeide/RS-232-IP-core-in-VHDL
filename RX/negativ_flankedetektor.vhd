library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity negativ_flankedetektor is
    port(
        CLk : in std_logic;
        reset_clk : in std_logic;
        sig_inn : std_logic;
        sig_inn_ne : out std_logic
        
    );
end entity negativ_flankedetektor;


architecture RTL of negativ_flankedetektor is
    signal vippeA : std_logic;
    
begin
    p_sync_flanke : process(CLk)
    begin
        if rising_edge(CLk) then
            if reset_clk = '0' then
                vippeA <= '1';
                sig_inn_ne <= '0';
            else
                vippeA <= sig_inn;
                sig_inn_ne <= vippeA and (not sig_inn);
            end if; 
        end if;
    end process;
end architecture RTL;
