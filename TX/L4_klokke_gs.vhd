library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity L4_klokke_GS is
    port (
        clk : in  std_logic;
        rst_n : in std_logic;
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5: out std_logic_vector(6 downto 0);
        klokke_std : out std_logic_vector(16 downto 0);
        sekund_bcd : out std_logic_vector(7 downto 0);
        minutt_bcd : out std_logic_vector(7 downto 0);
        timer_bcd : out std_logic_vector(7 downto 0)
    );
end entity L4_klokke_GS;

architecture RTL of L4_klokke_GS is
    
    component Enable_gen
        port (
            clk     : in std_logic;
            resetn       : in std_logic;
            velg_enable   : in std_logic_vector(2 downto 0);
            Enable       : out std_logic
        );
    end component;
    component bin2bcd
        port (
            bin_in  : in  std_logic_vector(6 downto 0);
            bcd_out : out std_logic_vector(7 downto 0)
        );
    end component;
    component ROM_7_seg is
        port(
            adresse : in  std_logic_vector(3 downto 0);
            HEX     : out std_logic_vector(6 downto 0)
        );
    end component ROM_7_seg;

    signal enable_signal : std_logic;
    signal sekund : integer range 0 to 63 := 0;
    signal minutt : integer range 0 to 63 := 0;
    signal timer : integer range 0 to 23 := 0;
    signal sekund_std : std_logic_vector(5 downto 0);
    signal minutt_std : std_logic_vector(5 downto 0);
    signal timer_std : std_logic_vector(4 downto 0);
    signal sekund_bc : std_logic_vector(7 downto 0);
    signal minutt_bc : std_logic_vector(7 downto 0);
    signal timer_bc : std_logic_vector(7 downto 0);

begin

    sekund_std <= std_logic_vector(to_unsigned(sekund, 6));
    minutt_std <= std_logic_vector(to_unsigned(minutt, 6));
    timer_std <= std_logic_vector(to_unsigned(timer, 5));
    klokke_std <= timer_std & minutt_std & sekund_std; -- lagrer dette for å bli brukt i komponent for styring av led
    sekund_bcd <= sekund_bc;
    minutt_bcd <= minutt_bc;
    timer_bcd <= timer_bc;


    enable_gen_inst : Enable_gen
        port map (
            clk     => clk,
            resetn       => rst_n,
            velg_enable  => "000", -- hardkodet til å telle en gang i sekund, om ønskelig så kan dette endres til 3 switcher for å øke hastighet.
            Enable       => enable_signal
        );
        
        bin2bcd_sekund : bin2bcd
        port map (
            bin_in     => "0" & sekund_std,
            bcd_out    => sekund_bc
        );
        bin2bcd_minutt : bin2bcd
        port map (
            bin_in     => "0" & minutt_std,
            bcd_out    => minutt_bc
        );
        bin2bcd_timer : bin2bcd
        port map (
            bin_in     => "00" & timer_std,
            bcd_out    => timer_bc
        );

        stortimerseg : component ROM_7_seg
            port map(
                adresse => timer_bc(7 downto 4),
                HEX     => HEX5
            );
            litentimerseg : component ROM_7_seg
                port map(
                    adresse => timer_bc(3 downto 0),
                    HEX     => HEX4
                );
            storminuttseg : component ROM_7_seg
                 port map(
                     adresse => minutt_bc(7 downto 4),
                     HEX     => HEX3
                    );
            litenminuttseg : component ROM_7_seg
                port map(
                     adresse => minutt_bc(3 downto 0),
                     HEX     => HEX2
                );
                storsekundseg : component ROM_7_seg
                    port map(
                        adresse => sekund_bc(7 downto 4),
                        HEX     => HEX1
                       );
               litensekundseg : component ROM_7_seg
                   port map(
                        adresse => sekund_bc(3 downto 0),
                        HEX     => HEX0
                   );
        

    teller : process(clk) -- selve telleren
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                sekund <= 0;
                minutt <= 0;
                timer <= 0;

            elsif enable_signal = '1' then
                sekund <= sekund + 1;
                   if sekund = 59 then
                    sekund <= 0;
                    minutt <= minutt + 1;
                       if minutt = 59 then
                            timer <= timer + 1;
                            minutt <= 0;
                                if timer = 23 AND minutt = 59 AND sekund = 59 then
                                    timer <= 0;
                                end if;
                       end if;
                   end if;
            end if;
        end if;
        
    end process teller;
    
end architecture RTL;