------------------------------------------------------------------------
-- Company: University of Essex
-- Engineer: Yun
--
-- Design Name: CE339 VGA Shape Display System
-- Module Name: reset_counter
-- Project Name: Movable VGA Object with Reset Counter
-- Target Devices: Digilent Basys3 (Artix-7 FPGA)
-- Tool Versions: Vivado
--
-- Description:
-- Counts the number of clean reset pulses.
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reset_counter is
    Port (
        clock       : in  STD_LOGIC;
        resetPulse  : in  STD_LOGIC;
        resetCount  : out INTEGER range 0 to 9999
    );
end reset_counter;

architecture Behavioral of reset_counter is

    signal countValue : INTEGER range 0 to 9999 := 0;

begin

    process(clock)
    begin
        if rising_edge(clock) then
        --increments once per clean pluse
            if resetPulse = '1' then
                if countValue < 9999 then
                    countValue <= countValue + 1;
                end if;
            end if;
        end if;
    end process;

    resetCount <= countValue;

end Behavioral;

