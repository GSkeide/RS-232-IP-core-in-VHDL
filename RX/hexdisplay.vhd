library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hexdisplay is
    port(
        clk : in std_logic;
        dataUt : in std_logic_vector(7 downto 0);
        sekund_BCD  : in std_logic_vector(7 downto 0);
        minutt_BCD  : in std_logic_vector(7 downto 0);
        timer_BCD   : in std_logic_vector(7 downto 0);
        modus : in std_logic;
        antall_bits : in integer range 0 to 10;
        typeID : in std_logic_vector(1 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out std_logic_vector(6 downto 0)
    );
end entity hexdisplay;



architecture Behavioral of hexdisplay is

    signal stortimer, litentimer,
           storminutt, litenminutt,
           storsekund, litensekund : std_logic_vector(6 downto 0);
           


    component ROM_7_seg is
        port(
            adresse : in  std_logic_vector(3 downto 0);
            HEX     : out std_logic_vector(6 downto 0)
        );
    end component ROM_7_seg;

begin -- lagd en enkel sju seg så endrer verdien til displayet ved endring av dataUt asynkront til klokkesignalet.

    stortimerseg : component ROM_7_seg
        port map(
            adresse => timer_bcd(7 downto 4),
            HEX     => stortimer
        );
        litentimerseg : component ROM_7_seg
            port map(
                adresse => timer_bcd(3 downto 0),
                HEX     => litentimer
            );
        storminuttseg : component ROM_7_seg
             port map(
                 adresse => minutt_bcd(7 downto 4),
                 HEX     => storminutt
                );
        litenminuttseg : component ROM_7_seg
            port map(
                 adresse => minutt_bcd(3 downto 0),
                 HEX     => litenminutt
            );
            storsekundseg : component ROM_7_seg
                port map(
                    adresse => sekund_bcd(7 downto 4),
                    HEX     => storsekund
                   );
           litensekundseg : component ROM_7_seg
               port map(
                    adresse => sekund_bcd(3 downto 0),
                    HEX     => litensekund
               );
    
    process(clk)
    begin
        if modus = '1' then --HEX ved klokkemodus
            HEX7 <= "1111111"; -- 7 og 6 er ikke i bruk
            HEX6 <= "1111111";
            if typeID = "01" then
            HEX0 <= litensekund;
            HEX1 <= storsekund;
            elsif typeID = "10" then
            Hex2 <= litenminutt;
            HEX3 <= storminutt;
            elsif typeID = "11" then
            HEX4 <= litentimer;
            HEX5 <= stortimer;
            end if;
        elsif modus = '0' then -- HEX ved normalt modus
            if dataUt(0) = '0' then
                Hex0 <= "1000000"; -- vis 0 på hex
            else
                HEX0 <= "1111001"; -- vis 1 på hex
               end if;

            if dataUt(1) = '0' then
                Hex1 <= "1000000";
            else
                HEX1 <= "1111001";
            end if;

            if dataUt(2) = '0' then
                Hex2 <= "1000000";
            else
                HEX2 <= "1111001";
            end if;

            if dataUt(3) = '0' then
                Hex3 <= "1000000";
            else
                HEX3 <= "1111001";
            end if;

            if dataUt(4) = '0' then
                Hex4 <= "1000000";
            else
                HEX4 <= "1111001";
            end if;
            if antall_bits > 5 then
                if dataUt(5) = '0' then
                    Hex5 <= "1000000";
                else
                    HEX5 <= "1111001";
                end if;

                if antall_bits > 6 then
                    if dataUt(6) = '0' then
                        Hex6 <= "1000000";
                    else
                        HEX6 <= "1111001";
                    end if;

                    if antall_bits > 7 then
                        if dataUt(7) = '0' then
                            Hex7 <= "1000000";
                        else
                            HEX7 <= "1111001";
                        end if;
                    else
                    HEX7 <= "1111111";
                    end if;
                else
                HEX6 <= "1111111";
                end if;
            else
            HEX5 <= "1111111";
            end if;
        end if;
        
end process;
end architecture;

