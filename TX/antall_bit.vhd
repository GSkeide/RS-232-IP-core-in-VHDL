library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity antall_bit is
    port(
        clk : in std_logic;
        rst :  in std_logic;
        dataIn : in std_logic_vector(7 downto 0);
        klokke_std : in std_logic_vector(16 downto 0);
        startPulse : in std_logic;
        bit_antall : in std_logic_vector(1 downto 0);
        modus : in std_logic;
        ActiveLeds : out std_logic_vector(16 downto 0);
        bit_per_melding : out integer range 0 to 10
        
    );
end entity antall_bit;

architecture RTL of antall_bit is
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                activeLeds <= "00000000000000000";
            else
if modus = '0' then
    if startPulse = '0' then
       
        if bit_antall = "01" then
            bit_per_melding <= 5;
            activeLeds <= "000000000" & "000" & dataIn(4 downto 0);

        elsif bit_antall = "10" then
            bit_per_melding <= 6;
            activeLeds <= "000000000" & "00" & dataIn(5 downto 0);

        elsif bit_antall = "11" then
                bit_per_melding <= 7;
                activeLeds <= "000000000" & "0" & dataIn(6 downto 0);

        else 
            bit_per_melding <= 8;
            activeLeds <= "000000000" & dataIn(7 downto 0);

        end if;
    end if;
elsif modus = '1' then
        bit_per_melding <= 8;
        activeLeds <= klokke_std(16 downto 0); -- viser klokke på led
    
   
end if;
end if;
end if;

end process;
    
end architecture RTL;

