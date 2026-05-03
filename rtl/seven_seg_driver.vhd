------------------------------------------------------------------------
-- Company: University of Essex
-- Engineer: Yun
--
-- Design Name: CE339 VGA Shape Display System
-- Module Name: seven_seg_driver
-- Project Name: Movable VGA Object with Reset Counter
-- Target Devices: Digilent Basys3 (Artix-7 FPGA)
-- Tool Versions: Vivado
--
-- Description:
-- Drives the 4-digit seven-segment display on the Basys3 board.
-- The display is multiplexed and shows a decimal value from 0 to 9999.
-- Segments and anodes are active low on the Basys3.
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity seven_seg_driver is
    generic (
        REFRESH_COUNTER_MAX : integer := 100000
    );
    Port (
        clock        : in  STD_LOGIC;
        numberToShow : in  INTEGER range 0 to 9999;
        anodes       : out STD_LOGIC_VECTOR(3 downto 0);
        segments     : out STD_LOGIC_VECTOR(6 downto 0);
        decimalPoint : out STD_LOGIC
    );
end seven_seg_driver;
architecture Behavioral of seven_seg_driver is
    signal refreshCounter : integer range 0 to REFRESH_COUNTER_MAX := 0;
    signal activeDigit    : integer range 0 to 3 := 0;
    signal digit0         : integer range 0 to 9;
    signal digit1         : integer range 0 to 9;
    signal digit2         : integer range 0 to 9;
    signal digit3         : integer range 0 to 9;
    signal currentDigit   : integer range 0 to 9 := 0;
begin

    --split number into digits 
    digit0 <= numberToShow mod 10;
    digit1 <= (numberToShow / 10) mod 10;
    digit2 <= (numberToShow / 100) mod 10;
    digit3 <= (numberToShow / 1000) mod 10;
    process(clock)
    begin
        if rising_edge(clock) then
            if refreshCounter = REFRESH_COUNTER_MAX then
                refreshCounter <= 0;
                if activeDigit = 3 then
                    activeDigit <= 0;
                else
                    activeDigit <= activeDigit + 1;
                end if;
            else
                refreshCounter <= refreshCounter + 1;
            end if;
        end if;
    end process;
    process(activeDigit, digit0, digit1, digit2, digit3)
    begin
        case activeDigit is
            when 0 =>
                anodes <= "1110";
                currentDigit <= digit0;
            when 1 =>
                anodes <= "1101";
                currentDigit <= digit1;
            when 2 =>
                anodes <= "1011";
                currentDigit <= digit2;
            when others =>
                anodes <= "0111";
                currentDigit <= digit3;
        end case;
    end process;
    process(currentDigit)
    begin
        case currentDigit is
            when 0 => segments <= "1000000";
            when 1 => segments <= "1111001";
            when 2 => segments <= "0100100";
            when 3 => segments <= "0110000";
            when 4 => segments <= "0011001";
            when 5 => segments <= "0010010";
            when 6 => segments <= "0000010";
            when 7 => segments <= "1111000";
            when 8 => segments <= "0000000";
            when 9 => segments <= "0010000";
            when others => segments <= "1111111";
        end case;
    end process;
    decimalPoint <= '1';
end Behavioral;
