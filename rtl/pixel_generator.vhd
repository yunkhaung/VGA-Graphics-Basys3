------------------------------------------------------------------------
-- Company: University of Essex
-- Engineer: Yun
--
-- Design Name: CE339 VGA Shape Display System
-- Module Name: pixel_generator
-- Project Name: Movable VGA Object with Reset Counter
-- Target Devices: Digilent Basys3 (Artix-7 FPGA)
-- Tool Versions: Vivado
--
-- Description:
-- Draws the blue square and yellow circle on a changing background.
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity pixel_generator is
    generic (
        SQUARE_WIDTH    : integer := 100;
        SQUARE_HEIGHT   : integer := 100;
        CIRCLE_OFFSET_X : integer := 50;
        CIRCLE_OFFSET_Y : integer := 50;
        CIRCLE_RADIUS   : integer := 50
    );
    Port (
        video_on      : in  STD_LOGIC;
        currentPixelX : in  INTEGER;
        currentPixelY : in  INTEGER;
        objectX       : in  INTEGER;
        objectY       : in  INTEGER;
        bgColorIndex  : in  INTEGER range 0 to 9;
        VGARed        : out STD_LOGIC_VECTOR(3 downto 0);
        VGABlue       : out STD_LOGIC_VECTOR(3 downto 0);
        VGAGreen      : out STD_LOGIC_VECTOR(3 downto 0)
    );
end pixel_generator;
architecture Behavioral of pixel_generator is
    signal squareOn      : STD_LOGIC;
    signal circleOn      : STD_LOGIC;
    signal circleCenterX : INTEGER;
    signal circleCenterY : INTEGER;
    signal dx            : INTEGER;
    signal dy            : INTEGER;
begin

    --centre of circle relative to square
    circleCenterX <= objectX + CIRCLE_OFFSET_X;
    circleCenterY <= objectY + CIRCLE_OFFSET_Y;
    
    --square boundaries
    squareOn <= '1' when (
                    currentPixelX >= objectX and
                    currentPixelX <  objectX + SQUARE_WIDTH and
                    currentPixelY >= objectY and
                    currentPixelY <  objectY + SQUARE_HEIGHT
               ) else '0';
               
    --distance from centre           
    dx <= currentPixelX - circleCenterX;
    dy <= currentPixelY - circleCenterY;
    
    --circle equation
    circleOn <= '1' when ((dx * dx + dy * dy) <= (CIRCLE_RADIUS * CIRCLE_RADIUS)) else '0';
    process(video_on, squareOn, circleOn, bgColorIndex)
    begin
        if video_on = '0' then
            VGARed   <= "0000";
            VGABlue  <= "0000";
            VGAGreen <= "0000";
        elsif circleOn = '1' then
            -- yellow
            VGARed   <= "1111";
            VGABlue  <= "0000";
            VGAGreen <= "1111";
        elsif squareOn = '1' then
            -- blue square
            VGARed   <= "0000";
            VGABlue  <= "1111";
            VGAGreen <= "0000";
        else
            case bgColorIndex is
                when 0 =>
                    -- charcoal
                    VGARed   <= "0001";
                    VGABlue  <= "0001";
                    VGAGreen <= "0001";
                when 1 =>
                    -- deep navy
                    VGARed   <= "0000";
                    VGABlue  <= "0011";
                    VGAGreen <= "0001";
                when 2 =>
                    -- forest green
                    VGARed   <= "0000";
                    VGABlue  <= "0001";
                    VGAGreen <= "0011";
                when 3 =>
                    -- plum
                    VGARed   <= "0011";
                    VGABlue  <= "0010";
                    VGAGreen <= "0001";
                when 4 =>
                    -- teal
                    VGARed   <= "0000";
                    VGABlue  <= "0011";
                    VGAGreen <= "0011";
                when 5 =>
                    -- slate
                    VGARed   <= "0010";
                    VGABlue  <= "0010";
                    VGAGreen <= "0011";
                when 6 =>
                    -- warm brown
                    VGARed   <= "0100";
                    VGABlue  <= "0001";
                    VGAGreen <= "0010";
                when 7 =>
                    -- dark olive
                    VGARed   <= "0011";
                    VGABlue  <= "0001";
                    VGAGreen <= "0011";
                when 8 =>
                    -- muted purple-blue
                    VGARed   <= "0010";
                    VGABlue  <= "0100";
                    VGAGreen <= "0010";
                when others =>
                    -- dark steel blue
                    VGARed   <= "0001";
                    VGABlue  <= "0100";
                    VGAGreen <= "0010";
            end case;
        end if;
    end process;
end Behavioral;
