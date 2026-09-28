library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sender is
    port(
        clock_50 : in std_logic;
        KEY : in std_logic_vector(3 downto 0);
        LEDR : out std_logic_vector(17 downto 0);
        SW : in std_logic_vector(17 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0);
        EX_IO : inout std_logic_vector(6 downto 0)
    );
end entity sender;


architecture Behavioral of sender is
    type tilstand_type is (Vent, Startbit, modusbit, modusbit2, Skift_ut, Stoppbit, overflytt);
    signal tilstand : tilstand_type := Vent;
    signal send_enable : std_logic;
    signal rst_clk : std_logic;
   signal dataIn : std_logic_vector(7 downto 0) := (others => '1');
    signal startPulse : std_logic; 
    signal dataOut : std_logic := '1';
    signal start_baudgen : std_logic := '0';
    signal baud_value : integer range 0 to 1000000;
    signal txReady : std_logic := '1';
    signal bit_per_melding : integer range 0 to 10;
    signal modus : std_logic;
    signal sekund_bcd : std_logic_vector(7 downto 0);
    signal minutt_bcd : std_logic_vector(7 downto 0);
    signal timer_bcd : std_logic_vector(7 downto 0);
    signal activeLeds : std_logic_vector(16 downto 0);
    signal klokke_std : std_logic_vector(16 downto 0);
    signal klokkiterator : std_logic_vector(1 downto 0) := "01";

    component antall_bit is
        port(
            clk : in std_logic;
            rst : in std_logic;
            dataIn : in std_logic_vector(7 downto 0);
            klokke_std : in std_logic_vector(16 downto 0);
            startPulse : in std_logic;
            bit_antall : in std_logic_vector(1 downto 0);
            modus : in std_logic;
            ActiveLeds : out std_logic_vector(16 downto 0);
            bit_per_melding : out integer range 0 to 10
        );
    end component antall_bit;

    component O1_Reset_Synchronizer is
        port(
        clk : in std_logic;
        areset_n : in std_logic;
        reset_clk : out std_logic
        );
        end component O1_Reset_Synchronizer;

        component baudrate is
            Port (
                clk          : in  STD_LOGIC;
                rst_clk           : in  STD_LOGIC;
                start_baudgen     : in STD_LOGIC;
                baud_rate_divider : in std_logic_vector(2 downto 0);
                baud_value : out integer range 0 to 1000000;
                send_enable       : out STD_LOGIC
            );
        end component baudrate;

        component L4_klokke_GS is
            port (
                clk : in  std_logic;
                rst_n : in std_logic;
                HEX0, HEX1, HEX2, HEX3, HEX4, HEX5: out std_logic_vector(6 downto 0);
                klokke_std : out std_logic_vector(16 downto 0);
                sekund_bcd : out std_logic_vector(7 downto 0);
                minutt_bcd : out std_logic_vector(7 downto 0);
                timer_bcd : out std_logic_vector(7 downto 0)
            );
        end component L4_klokke_GS;

        
begin
    
    startPulse <= KEY(0);
    LEDR(16 downto 0) <= ActiveLeds(16 downto 0); -- leds blir kontrollert av antall_bit.vhd
    EX_IO(0) <= dataOut;
    modus <= sw(17);

    klokke : component L4_klokke_GS
        port map(
            clk        => clock_50,
            rst_n      => rst_clk,
            HEX0 => HEX0,
            HEX1 => HEX1, 
            HEX2 => HEX2, 
            HEX3 => HEX3,
             HEX4 => HEX4,
              HEX5 => HEX5,
            klokke_std => klokke_std,
            sekund_bcd => sekund_bcd,
            minutt_bcd => minutt_bcd,
            timer_bcd  => timer_bcd
        );
    

    antall_bits_og_led_kontroll : antall_bit
        port map(
            clk             => clock_50,
            rst             => rst_clk,
            dataIn          => dataIn,
            klokke_std      => klokke_std,
            startPulse      => startPulse,
            bit_antall      => SW(11 downto 10),
            modus           => modus,
            ActiveLeds      => ActiveLeds,
            bit_per_melding => bit_per_melding
        );
    

    reset_sync : O1_Reset_Synchronizer
    port map (
        clk => clock_50,
        areset_n => KEY(3),
        reset_clk => rst_clk
    );
    
    baud_rate :  baudrate
    Port map (
        clk          => clock_50,
        rst_clk           => rst_clk,
        start_baudgen     => start_baudgen,
        baud_rate_divider => SW(16 downto 14),
        baud_value => baud_value,
        send_enable       => send_enable
    );



    process(clock_50)
        variable bit_cnt : integer := 0; -- range 0 to 8 er ikke nødvendig selv om programmet sier det.
        
    begin
        if rising_edge(clock_50) then
            if rst_clk = '0' then
                txReady <= '1';
                dataOut <= '1';
                bit_cnt := 0;
                tilstand <= Vent;
                dataIn <= (others => '1');
                start_baudgen <= '0';

                
            else
                
                    case tilstand is
                        when Vent =>

                            txReady <= '1';      -- idle, klart til sending av data
                            dataOut <= '1';      -- Idle status for rs 232 protokoll, dataout = 1 betyr ingen data
                            bit_cnt := 0;

                            if modus = '0' then
                               if startPulse = '0' then -- KEY(0) starter programmet etter du har satt switchene til ønsket bit
                                   dataIn <= SW(7 downto 0); -- bare sw(7 downto 0) blir iterert gjennom
                                   tilstand <= startbit;
                                   start_baudgen <= '1';
                               else 
                                   start_baudgen <= '0'; -- baudgen i reset når data ikke blir sendt
                               end if;

                             elsif modus = '1' then -- ved klokkemodus
                                
                                if klokkiterator = "01" then
                                   dataIn <= sekund_bcd;

                                elsif klokkiterator = "10" then
                                    dataIn <= minutt_bcd;
                                elsif klokkiterator = "11" then
                                    dataIn <= timer_bcd;
                                end if;
                                tilstand <= startbit; -- noter, ved normalt modus = 0, så er klokkiterator lik 00, klokkiterator er modusbit for å identifisere type data som blir sendt.
                                start_baudgen <= '1';
                            end if;
                            

                        when startbit =>
                            bit_cnt := 0;
                            if send_enable = '1' then
                            dataOut <= '0';      -- Signaliserer start av data sending til mottaker
                            txReady <= '0';      
                            tilstand <= modusbit;
                            end if;

                            -- modusbit var originalt 1 tilstand, men det ble mye lettere og redigere og feilsøke med 2 tilstander.
                    when modusbit =>
                        if send_enable = '1' then 

                            if modus = '0' then
                                dataOut <= '0';
                                tilstand <= modusbit2;

                            else
                                    if klokkiterator = "01" then -- sekund signal 1
                                            dataOut <= '0';
                                            tilstand <= modusbit2;

                                    elsif klokkiterator = "10" then -- minutt signal 1
                                            dataOut <= '1';
                                            tilstand <= modusbit2;

                                    elsif klokkiterator = "11" then -- timer signal 1
                                            dataOut <= '1';
                                            tilstand <= modusbit2;
                                    end if;
                            end if;

                        end if;

                    when modusbit2 =>
                        if send_enable = '1' then

                            if modus = '0' then
                                dataOut <= '0';
                                tilstand <= skift_ut;
                            else
                                    if klokkiterator = "01" then -- sekund signal 2
                                        dataOut <= '1';
                                        tilstand <= skift_ut;
                                    

                                    elsif klokkiterator = "10" then -- minutt signal 2
                                            dataOut <= '0';
                                            tilstand <= skift_ut;

                                    elsif klokkiterator = "11" then -- timer signal 2
                                            dataOut <= '1';
                                            tilstand <= skift_ut;
                                    end if;
                            end if;
                        end if;
                            
                    when Skift_ut => -- tilstanden er i 8 baudrater, før var den i 9 baudrater som skapte myeeee problem
                            if send_enable = '1' then
                                txReady <= '0';      
                                if bit_cnt < bit_per_melding-1 then
                                    dataOut <= dataIn(bit_cnt);
                                    bit_cnt := bit_cnt + 1;
                                elsif bit_cnt = bit_per_melding-1 then
                                    dataOut <= dataIn(bit_cnt);
                                    tilstand <= Stoppbit;
                                end if;
                            end if;

                            
                        when Stoppbit =>
                            bit_cnt := 0;

                            if send_enable = '1' then
                                dataOut <= '1';      -- signaliser slutt av data
                                txReady <= '0'; 
                                tilstand <= overflytt;    -- siste tilstand
                                    
                            end if;

                        when overflytt => -- transisjonstilstand, som også endres klokkiterator fra sekund til minutt, eller minutt til timer, osv.
                            dataOut <= '1';
                            txReady <= '0';
                            if send_enable = '1' then
                            if modus = '1' then -- hadde denne if setningen i modusbit2, men ha den her gjør det enklere å feilsøke i signaltap
                                if klokkiterator = "01" then -- bruk av vector gjør det enklere å feilsøke i signaltap
                                    klokkiterator <= "10";
                                elsif klokkiterator = "10" then
                                        klokkiterator <= "11";
                                elsif klokkiterator = "11" then
                                        klokkiterator <= "01";
                                end if;
                            end if;
                            tilstand <= Vent;
                            start_baudgen <= '0';
                        end if;


                    end case;
                end if;
            end if;
        
    end process;
end architecture Behavioral;

