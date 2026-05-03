------------------------------------------------------------------------
-- Company: University of Essex
-- Engineer: Yun
--
-- Design Name: CE339 VGA Shape Display System
-- Module Name: movement_controller
-- Project Name: Movable VGA Object with Reset Counter
-- Target Devices: Digilent Basys3 (Artix-7 FPGA)
-- Tool Versions: Vivado
--
-- Description:
-- Controls the object position using the Basys3 directional buttons.
-- The object moves using a slower tick so movement is easier to control.
-- A clean reset pulse cycles through a list of predefined positions.
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity movement_controller is
    generic (
        SCREEN_WIDTH      : integer := 640;
        SCREEN_HEIGHT     : integer := 480;
        OBJECT_WIDTH      : integer := 100;
        OBJECT_HEIGHT     : integer := 100;

        STEP_SIZE         : integer := 4;
        MOVE_COUNTER_MAX  : integer := 500000
    );
    Port (
        clock       : in  STD_LOGIC;
        resetPulse  : in  STD_LOGIC;
        upButton    : in  STD_LOGIC;
        downButton  : in  STD_LOGIC;
        leftButton  : in  STD_LOGIC;
        rightButton : in  STD_LOGIC;

        objectX     : out INTEGER;
        objectY     : out INTEGER
    );
end movement_controller;

architecture Behavioral of movement_controller is
    --current object position 
    signal currentObjectX : integer range 0 to SCREEN_WIDTH  - OBJECT_WIDTH  := 270;
    signal currentObjectY : integer range 0 to SCREEN_HEIGHT - OBJECT_HEIGHT := 190;

    --slow down movement
    signal moveCounter    : integer range 0 to MOVE_COUNTER_MAX := 0;
    signal moveTick       : STD_LOGIC := '0';
    --used to cycle preset reset positons
    signal positionIndex  : integer range 0 to 14 := 0;

begin

    process(clock)
    begin
        if rising_edge(clock) then

            -- slower movement tick so object does not fly across the screen
            if moveCounter = MOVE_COUNTER_MAX then
                moveCounter <= 0;
                moveTick    <= '1';
            else
                moveCounter <= moveCounter + 1;
                moveTick    <= '0';
            end if;

            -- cycle through preset valid positions on each clean reset pulse
            if resetPulse = '1' then
                case positionIndex is
                    when 0  => currentObjectX <= 50;  currentObjectY <= 50;
                    when 1  => currentObjectX <= 200; currentObjectY <= 50;
                    when 2  => currentObjectX <= 400; currentObjectY <= 50;
                    when 3  => currentObjectX <= 100; currentObjectY <= 150;
                    when 4  => currentObjectX <= 300; currentObjectY <= 150;
                    when 5  => currentObjectX <= 450; currentObjectY <= 150;
                    when 6  => currentObjectX <= 50;  currentObjectY <= 250;
                    when 7  => currentObjectX <= 200; currentObjectY <= 250;
                    when 8  => currentObjectX <= 400; currentObjectY <= 250;
                    when 9  => currentObjectX <= 100; currentObjectY <= 350;
                    when 10 => currentObjectX <= 300; currentObjectY <= 350;
                    when 11 => currentObjectX <= 450; currentObjectY <= 350;
                    when 12 => currentObjectX <= 150; currentObjectY <= 100;
                    when 13 => currentObjectX <= 350; currentObjectY <= 200;
                    when others => currentObjectX <= 250; currentObjectY <= 300;
                end case;
                
                if positionIndex = 14 then --cycle index
                    positionIndex <= 0;
                else
                    positionIndex <= positionIndex + 1;
                end if;

            elsif moveTick = '1' then
                -- vertical movement
                if upButton = '1' and downButton = '0' then
                    if currentObjectY >= STEP_SIZE then
                        currentObjectY <= currentObjectY - STEP_SIZE;
                    end if;

                elsif downButton = '1' and upButton = '0' then
                    if currentObjectY <= SCREEN_HEIGHT - OBJECT_HEIGHT - STEP_SIZE then
                        currentObjectY <= currentObjectY + STEP_SIZE;
                    end if;
                end if;

                -- horizontal movement
                if leftButton = '1' and rightButton = '0' then
                    if currentObjectX >= STEP_SIZE then
                        currentObjectX <= currentObjectX - STEP_SIZE;
                    end if;

                elsif rightButton = '1' and leftButton = '0' then
                    if currentObjectX <= SCREEN_WIDTH - OBJECT_WIDTH - STEP_SIZE then
                        currentObjectX <= currentObjectX + STEP_SIZE;
                    end if;
                end if;
            end if;
        end if;
    end process;

    objectX <= currentObjectX;
    objectY <= currentObjectY;

end Behavioral;

