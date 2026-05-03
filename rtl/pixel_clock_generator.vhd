------------------------------------------------------------------------
-- Company: University of Essex
-- Engineer: Yun
--
-- Design Name: CE339 VGA Shape Display System
-- Module Name: pixel_clock_generator
-- Project Name: Movable VGA Object with Reset Counter
-- Target Devices: Digilent Basys3 (Artix-7 FPGA)
-- Tool Versions: Vivado
--
-- Description:
-- Generates a 25 MHz pixel clock from the 100 MHz board clock.
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity pixel_clock_generator is
    generic (
        DIVIDE_BY : integer := 4
    );
    Port (
        clk_in  : in  STD_LOGIC;
        clk_out : out STD_LOGIC
    );
end pixel_clock_generator;
architecture Behavioral of pixel_clock_generator is
    signal clk_reg   : STD_LOGIC := '0';
    signal count_reg : integer range 0 to (DIVIDE_BY / 2) - 1 := 0;
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
        -- divide 100MHz clock to 25MHz
            if count_reg = (DIVIDE_BY / 2) - 1 then
                count_reg <= 0;
                clk_reg   <= not clk_reg;
            else
                count_reg <= count_reg + 1;
            end if;
        end if;
    end process;
    clk_out <= clk_reg;
end Behavioral;
