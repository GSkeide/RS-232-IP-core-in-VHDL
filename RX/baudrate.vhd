library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity baudrate is
    Port (
        clk          : in  STD_LOGIC;
        rst_clk           : in  STD_LOGIC;
        start_baudgen     : in STD_LOGIC;
        baud_rate_divider : in std_logic_vector(2 downto 0);
        baud_value : out integer range 0 to 1000000;
        send_enable       : out STD_LOGIC
    );
end baudrate;

architecture Behavioral of baudrate is
    signal baud_rate_count : integer range 0 to 1000000 := 0;
    signal baud_rate_value : integer range 0 to 1000000 := 9600;
    signal send_enable_temp : std_logic := '0';
begin

    process(baud_rate_divider)
    begin
        case baud_rate_divider is
            when "000" => baud_rate_value <= 4800;
            when "001" => baud_rate_value <= 9600;
            when "010" => baud_rate_value <= 19200;
            when "011" => baud_rate_value <= 34800;
            when "100" => baud_rate_value <= 57600;
            when "101" => baud_rate_value <= 74880;
            when "110" => baud_rate_value <= 115200;
            when "111" => baud_rate_value <= 1000000;
            when others => baud_rate_value <= 9600;
        end case;
    end process;
baud_value <= 50000000/baud_rate_value;

    process(clk)
    begin  
        
        if rising_edge(clk) then
            
            if rst_clk = '0' then
                baud_rate_count <= 0;
                send_enable_temp <= '0';
            else
                if baud_rate_count = 50000000/baud_rate_value -1 then
                    baud_rate_count <= 0;
                    send_enable_temp <= '1';
                else
                    if start_baudgen = '1' then
                    baud_rate_count <= baud_rate_count + 1;
                    else
                        baud_rate_count <= 0;
                    end if;
                    send_enable_temp <= '0';
                end if;
            end if;
        end if;
    end process;

    send_enable <= send_enable_temp;
end Behavioral;
