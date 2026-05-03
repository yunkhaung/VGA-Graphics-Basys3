------------------------------------------------------------------------
-- Company: University of Essex
-- Engineer: Yun
--
-- Design Name: CE339 VGA Shape Display System
-- Module Name: button_cleaner
-- Project Name: Movable VGA Object with Reset Counter
-- Target Devices: Digilent Basys3 (Artix-7 FPGA)
-- Tool Versions: Vivado
--
-- Description:
-- Debounces a push button and produces a single clean pulse on a
-- stable rising edge. This is used for the centre button so reset
-- does not trigger twice from one press.
--
-- Revision:
-- Revision 0.01 - File Created
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity button_cleaner is
    generic (
        DEBOUNCE_COUNT_MAX : integer := 300000
    );
    Port (
        clock       : in  STD_LOGIC;
        rawButton   : in  STD_LOGIC;
        cleanPulse  : out STD_LOGIC
    );
end button_cleaner;

architecture Behavioral of button_cleaner is

    signal sync0         : STD_LOGIC := '0';
    signal sync1         : STD_LOGIC := '0';

    signal lastSample    : STD_LOGIC := '0';
    signal stableButton  : STD_LOGIC := '0';
    signal prevStable    : STD_LOGIC := '0';

    signal debounceCount : integer range 0 to DEBOUNCE_COUNT_MAX := 0;
    signal pulseReg      : STD_LOGIC := '0';

begin

    process(clock)
    begin
        if rising_edge(clock) then
            -- 2-stage synchroniser first
            sync0 <= rawButton;
            sync1 <= sync0;

            pulseReg <= '0';

            -- check whether sampled button is stable
            if sync1 = lastSample then
                if debounceCount < DEBOUNCE_COUNT_MAX then
                    debounceCount <= debounceCount + 1;
                end if;
            else
                debounceCount <= 0;
            end if;

            lastSample <= sync1;

            -- once stable for long enough, accept the new state
            if debounceCount = DEBOUNCE_COUNT_MAX then
                stableButton <= lastSample;
            end if;

            -- generate one pulse on clean rising edge
            if stableButton = '1' and prevStable = '0' then
                pulseReg <= '1';
            end if;

            prevStable <= stableButton;
        end if;
    end process;

    cleanPulse <= pulseReg;

end Behavioral;

