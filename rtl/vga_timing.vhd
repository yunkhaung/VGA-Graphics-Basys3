------------------------------------------------------------------------
-- Company: University of Essex
-- Engineer: Yun
--
-- Design Name: CE339 VGA Shape Display System
-- Module Name: vga_timing
-- Project Name: Movable VGA Object with Reset Counter
-- Target Devices: Digilent Basys3 (Artix-7 FPGA)
-- Tool Versions: Vivado
--
-- Description:
-- Generates VGA timing signals for 640x480 @ 60 Hz.
-- Produces horizontal sync, vertical sync, visible video enable,
-- and the current pixel coordinates.
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity vga_timing is
    generic (
        H_VISIBLE      : integer := 640;
        H_FRONT_PORCH  : integer := 16;
        H_SYNC_PULSE   : integer := 96;
        H_BACK_PORCH   : integer := 48;
        V_VISIBLE      : integer := 480;
        V_FRONT_PORCH  : integer := 10;
        V_SYNC_PULSE   : integer := 2;
        V_BACK_PORCH   : integer := 33
    );
    Port (
        pixel_clk : in  STD_LOGIC;
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC;
        video_on  : out STD_LOGIC;
        pixel_x   : out INTEGER;
        pixel_y   : out INTEGER
    );
end vga_timing;
architecture Behavioral of vga_timing is
    constant H_TOTAL : integer := H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
    constant V_TOTAL : integer := V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;
    signal h_count : integer range 0 to H_TOTAL - 1 := 0;
    signal v_count : integer range 0 to V_TOTAL - 1 := 0;
begin
    process(pixel_clk)
    begin
        if rising_edge(pixel_clk) then
        
        --horizontal counter
            if h_count = H_TOTAL - 1 then
                h_count <= 0;
                
                --move to next row
                if v_count = V_TOTAL - 1 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;
    --sync signals (active low) 
    hsync <= '0' when (
                h_count >= (H_VISIBLE + H_FRONT_PORCH) and
                h_count <  (H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE)
             ) else '1';
    vsync <= '0' when (
                v_count >= (V_VISIBLE + V_FRONT_PORCH) and
                v_count <  (V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE)
             ) else '1';
    -- visible area
    video_on <= '1' when (h_count < H_VISIBLE and v_count < V_VISIBLE) else '0';
    pixel_x <= h_count;
    pixel_y <= v_count;
end Behavioral;
