library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mottaker is
    port(
            clock_50 : in std_logic;
            KEY : in std_logic_vector(3 downto 0);
            LEDR : out std_logic_vector(17 downto 0);
            SW : in std_logic_vector(17 downto 0);
            EX_IO : inout std_logic_vector(6 downto 0);
            HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out std_logic_vector(6 downto 0)
        );
end entity mottaker;

architecture Behavioral of mottaker is
    type tilstand_type is (Vent, mottak, halvperiode,  IDfase, slutt_bit, feil );
    signal tilstand : tilstand_type := Vent;
    signal send_enable : std_logic;
    signal halv_baud_cnt : integer range 0 to 1000000 := 0;
    signal dataUt : std_logic_vector(7 downto 0) := (others => '1');
    signal typeID : std_logic_vector(1 downto 0) := (others => '1');
    signal inndata : std_logic;
    signal rst_clk : std_logic;
    signal dataInn_synced : std_logic := '1';
    signal error : std_logic := '0';
    signal dataValidUt : std_logic := '0';
    signal fall_flanke : std_logic := '0';
    signal start_baudgen : std_logic := '0';
    signal baud_value : integer range 0 to 1000000;
    signal bit_per_melding : integer range 0 to 10;
    signal startPulse : std_logic := '1';
    signal modus : std_logic;
    signal sekund_bcd : std_logic_vector(7 downto 0) := (others => '0');
    signal minutt_bcd : std_logic_vector(7 downto 0) := (others => '0');
    signal timer_bcd : std_logic_vector(7 downto 0) := (others => '0');
    signal dataNorm : std_logic_vector(7 downto 0) := (others => '0'); -- ikke nødvendig men jeg har den for å være konsistens i handling av data. dette er da utdata ved modus=0.

    component antall_bit is
        port(
            clk : in std_logic;
            startPulse : in std_logic;
            bit_antall : in std_logic_vector(1 downto 0);
            modus : in std_logic;
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
        component negativ_flankedetektor
            port(
                clk   : in  std_logic;
                reset_clk  : in  std_logic;
                sig_inn    : in  std_logic;
                sig_inn_ne : out std_logic
            );
        end component negativ_flankedetektor;

        component datainn_sync is
            port(
                clk : in std_logic;
                rst : in std_logic;
                dataInn : in std_logic;
                dataInn_synced : out std_logic
            );
        end component datainn_sync;

        component hexdisplay is
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
        end component hexdisplay;
begin
    EX_IO(6) <= 'Z';
    inndata <= EX_IO(6);
    modus <= SW(17);
    LEDR(0) <= error;
    LEDR(2) <= dataValidUt;
    -- LEDR(17 downto 10) <= sekund_bcd(7 downto 0);

    antall_bit_kontroll : antall_bit
        port map(
            clk             => clock_50,
            startPulse      => startPulse,
            bit_antall      => SW(11 downto 10),
            modus           => modus,
            bit_per_melding => bit_per_melding
        );
    
   
    FF : negativ_flankedetektor
        port map(
            clk   => clock_50,
            reset_clk  => rst_clk,
            sig_inn    => dataInn_synced,
            sig_inn_ne => fall_flanke
        );
    reset_sync : O1_Reset_Synchronizer
    port map (
        clk => clock_50,
        areset_n => KEY(3),
        reset_clk => rst_clk
    );

    baud_rate :  baudrate
    Port map (
        clk          => clOCK_50,
        rst_clk           => rst_clk,
        start_baudgen     => start_baudgen,
        baud_rate_divider => SW(16 downto 14),
        baud_value => baud_value,
        send_enable       => send_enable
    );
    data_sync : datainn_sync 
        port map(
            clk => clock_50,
            rst  => rst_clk,
            dataInn => inndata,
            dataInn_synced => dataInn_synced
        );

        sju_seg_kontroll : component hexdisplay
            port map(
                clk         => clock_50,
                dataUt      => dataNorm,
                sekund_BCD  => sekund_BCD,
                minutt_BCD  => minutt_BCD,
                timer_BCD  => timer_BCD,
                modus       => modus,
                antall_bits => bit_per_melding,
                typeID      => typeID,
                HEX0        => HEX0,
                HEX1        => HEX1,
                HEX2        => HEX2,
                HEX3        => HEX3,
                HEX4        => HEX4,
                HEX5        => HEX5,
                HEX6        => HEX6,
                HEX7        => HEX7
            );



    process(clock_50)
        variable IDcnt : integer range 0 to 2 := 0;
        variable bit_cnt : integer := 0;
        
    begin
        if rising_edge(clock_50) then
            if rst_clk = '0' then
                dataUt <= (others => '1');
                dataValidUt <= '0';
                error <= '0';
                tilstand <= Vent;
                startPulse <= '1';
                IDcnt := 0;
                bit_cnt := 0;
                halv_baud_cnt <= 0;
            else
                case tilstand is -- fall flanke, dataInn_synced, send_enable, start_baudgen, data_received(7downto0), bit_cnt
                        when Vent => -- venter på startbit
                            bit_cnt := 0;
                            halv_baud_cnt <= 0;
                            IDcnt := 0;
                            start_baudgen <= '0';
                            if fall_flanke='1' then  -- start bit oppdaget
                                tilstand <= halvperiode; 
                                startPulse <= '0';
                            end if;

                        when halvperiode =>
                            startPulse <= '1';
                            halv_baud_cnt <= halv_baud_cnt + 1;
                            if halv_baud_cnt >= baud_value then
                                tilstand <= IDfase;
                            elsif halv_baud_cnt = baud_value/2 then
                                start_baudgen <= '1'; -- baudgen startes etter en halv periode
                                
                                if dataInn_synced = '1' then -- sjekker start bit validitet
                                    tilstand <= feil;
                                end if;
                            end if;


                        when IDfase =>
                            if send_enable = '1' then
                                typeID(1-IDcnt) <= dataInn_synced;
                                IDcnt := IDcnt + 1;
                                if IDcnt = 2 then
                                    tilstand <= mottak;
                                end if;
                            end if;

                        when mottak => -- iterer gjennom data
                            
                            if send_enable = '1' then
                                dataValidUt <= '0';
                                Error <= '0';
                                if bit_cnt < (bit_per_melding - 1) then
                                    dataUt(bit_cnt) <= dataInn_synced;
                                    bit_cnt := bit_cnt + 1;
                                elsif bit_cnt = (bit_per_melding - 1) then
                                    dataUt(bit_Cnt) <= dataInn_synced;
                                    tilstand <= slutt_bit;
                                end if;
                            end if;


                        when slutt_bit => -- 
                            if send_enable = '1' then
                                if dataInn_synced = '1' then
                                    if modus = '1' then
                                        if typeID = "01" then
                                            sekund_bcd <= dataUt;
                                        elsif typeID = "10" then
                                            minutt_bcd <= dataUt;
                                        elsif typeID = "11" then
                                            timer_bcd <= dataUt;
                                        end if;
                                    elsif modus = '0' then
                                        if typeID = "00" then
                                            dataNorm <= dataUt; -- 
                                        end if;
                                     end if;

                                        dataValidUt <= '1';
                                        ERROR <= '0';
                                        tilstand <= vent;
                                        start_baudgen <= '0';
                                    else 
                                        dataValidUt <= '0';
                                        ERROR <= '1';
                                        tilstand <= feil;
                                    end if;
                                end if;


                        when feil =>
                            if send_enable = '1' then
                            dataValidUt <= '0';
                            error <= '1';
                            start_baudgen <= '0';
                            tilstand <= vent;
                            end if;
                    end case;
                end if;
            end if;
    end process;
end architecture Behavioral;
