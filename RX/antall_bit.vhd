library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity antall_bit is
    port(
        clk : in std_logic;
        startPulse : in std_logic;
        bit_antall : in std_logic_vector(1 downto 0);
        modus : in std_logic;
        bit_per_melding : out integer range 0 to 10
        
    );
end entity antall_bit;

architecture RTL of antall_bit is
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
if modus = '0' then
    if startPulse = '0' then
       
        if bit_antall = "01" then
            bit_per_melding <= 5;

        elsif bit_antall = "10" then
            bit_per_melding <= 6;

        elsif bit_antall = "11" then
                bit_per_melding <= 7;

        else 
            bit_per_melding <= 8;

        end if;
    end if;
elsif modus = '1' then
        bit_per_melding <= 8;
    
   
end if;

end if;

end process;
    
end architecture RTL;

