------------------------------------------------------------------------
-- Company: University of Essex
-- Engineer: Yun
--
-- Design Name: CE339 VGA Shape Display System
-- Module Name: basys3_vga_system
-- Project Name: Movable VGA Object with Reset Counter
-- Target Devices: Digilent Basys3 (Artix-7 FPGA)
-- Tool Versions: Vivado
--
-- Description:
-- Top-level module for the CE339 VGA assignment.
-- Connects the pixel clock generator, VGA timing module, movement
-- controller, pixel generator, button cleaner, reset counter,
-- and 7-segment driver together.
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity basys3_vga_system is
    Port (
        clock             : in  STD_LOGIC;

        --buttons for movement and reset
        centerButton      : in  STD_LOGIC;
        upButton          : in  STD_LOGIC;
        leftButton        : in  STD_LOGIC;
        rightButton       : in  STD_LOGIC;
        downButton        : in  STD_LOGIC;

        -- VGA outputs 
        hSync             : out STD_LOGIC;
        vSync             : out STD_LOGIC;
        VGARed            : out STD_LOGIC_VECTOR(3 downto 0);
        VGABlue           : out STD_LOGIC_VECTOR(3 downto 0);
        VGAGreen          : out STD_LOGIC_VECTOR(3 downto 0);

        -- 7 seg display 
        anodes            : out STD_LOGIC_VECTOR(3 downto 0);
        segments          : out STD_LOGIC_VECTOR(6 downto 0);
        decimalPoint      : out STD_LOGIC
    );
end basys3_vga_system;

architecture Behavioral of basys3_vga_system is

   -- pixel clk for 100MHz to 25MHz
    signal pixelClock    : STD_LOGIC;
    signal videoOn       : STD_LOGIC;
    signal currentPixelX : INTEGER;
    signal currentPixelY : INTEGER;

    -- position of moving object 
    signal objectX       : INTEGER;
    signal objectY       : INTEGER;

    -- clean reset pulse (fixed button bouncing) 
    signal resetPulse    : STD_LOGIC;
    
    --counts the amount of times btnC is pressed
    signal resetCount    : INTEGER range 0 to 9999;
    
    -- used to change bg color each reset
    signal bgColorIndex  : INTEGER range 0 to 9;

begin

    -- to cycle to 10 colors 
    bgColorIndex <= resetCount mod 10;
    
    -- cleaned button so it triggers once per press
    resetButtonCleaner_inst : entity work.button_cleaner
        generic map (
            DEBOUNCE_COUNT_MAX => 300000
        )
        port map (
            clock      => clock,
            rawButton  => centerButton,
            cleanPulse => resetPulse
        );
    
    -- 25MHz for VGA
    pixelClockGen_inst : entity work.pixel_clock_generator
        generic map (
            DIVIDE_BY => 4
        )
        port map (
            clk_in  => clock,
            clk_out => pixelClock
        );
 
    -- handles VGA sync and pixel coordinates
    vgaTiming_inst : entity work.vga_timing
        generic map (
            H_VISIBLE     => 640,
            H_FRONT_PORCH => 8,
            H_SYNC_PULSE  => 96,
            H_BACK_PORCH  => 56,
            V_VISIBLE     => 480,
            V_FRONT_PORCH => 2,
            V_SYNC_PULSE  => 2,
            V_BACK_PORCH  => 40
        )
        port map (
            pixel_clk => pixelClock,
            hsync     => hSync,
            vsync     => vSync,
            video_on  => videoOn,
            pixel_x   => currentPixelX,
            pixel_y   => currentPixelY
        );

    -- moves object based on button input
    movementController_inst : entity work.movement_controller
        generic map (
            SCREEN_WIDTH     => 640,
            SCREEN_HEIGHT    => 480,
            OBJECT_WIDTH     => 100,
            OBJECT_HEIGHT    => 100,
            STEP_SIZE        => 4,
            MOVE_COUNTER_MAX => 500000
        )
        port map (
            clock       => clock,
            resetPulse  => resetPulse,
            upButton    => upButton,
            downButton  => downButton,
            leftButton  => leftButton,
            rightButton => rightButton,
            objectX     => objectX,
            objectY     => objectY
        );
    
    -- draws circle, square and background
    pixelGen_inst : entity work.pixel_generator
        generic map (
            SQUARE_WIDTH    => 100,
            SQUARE_HEIGHT   => 100,
            CIRCLE_OFFSET_X => 50,
            CIRCLE_OFFSET_Y => 50,
            CIRCLE_RADIUS   => 50
        )
        port map (
            video_on      => videoOn,
            currentPixelX => currentPixelX,
            currentPixelY => currentPixelY,
            objectX       => objectX,
            objectY       => objectY,
            bgColorIndex  => bgColorIndex,
            VGARed        => VGARed,
            VGABlue       => VGABlue,
            VGAGreen      => VGAGreen
        );
   
   -- counts reset
    resetCounter_inst : entity work.reset_counter
        port map (
            clock      => clock,
            resetPulse => resetPulse,
            resetCount => resetCount
        );

    -- display reset count on 7-seg
    sevenSegDriver_inst : entity work.seven_seg_driver
        generic map (
            REFRESH_COUNTER_MAX => 100000
        )
        port map (
            clock        => clock,
            numberToShow => resetCount,
            anodes       => anodes,
            segments     => segments,
            decimalPoint => decimalPoint
        );

end Behavioral;

