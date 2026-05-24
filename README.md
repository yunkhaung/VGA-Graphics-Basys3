# VGA Graphics System on Basys3
### Interactive VHDL-Based VGA Display with Real-Time Object Control

![Platform](https://img.shields.io/badge/FPGA-Artix--7-red) ![HDL](https://img.shields.io/badge/HDL-VHDL-purple) ![Tools](https://img.shields.io/badge/Tools-Vivado-green) ![Resolution](https://img.shields.io/badge/VGA-640×480_@_60Hz-blue) ![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

A real-time VGA graphics system implemented on the Digilent Basys3 Artix-7 FPGA using VHDL. The system renders a movable composite object (square + circle) on a 640×480 display, controlled via push buttons, with dynamic background colour cycling and 7-segment reset counter display.

> Built as CE339 High Level Digital Design Assignment — University of Essex (2025–2026)

---

## Features

- 640×480 @ 60Hz VGA output via 25MHz pixel clock (divided from 100MHz)
- Movable composite object: blue square with overlaid yellow circle
- Circle rendered using `dx² + dy² ≤ r²` with colour priority over square
- Dynamic background cycles through **10 colours** on each reset
- Object spawns at a new predefined position on each reset (15 positions)
- Button debouncer generates clean single-cycle reset pulse
- 7-segment display shows reset count (0–9999)
- Fully modular VHDL architecture with generics throughout

---

## Hardware

| Component | Details |
|-----------|---------|
| FPGA | Digilent Basys3 Artix-7 (xc7a35tcpg236-1) |
| Display | VGA monitor via 12-bit RGB (4-bit per channel) |
| Input | 5× push buttons (directional + centre reset) |
| Output | hSync, vSync, RGB, 7-segment display |
| Tools | Vivado 2021.2 |

---

## System Architecture

```
[100MHz Clock] → [Pixel Clock Generator] → [25MHz] → [VGA Timing Module]
                                                              ↓
                                                    pixel_x, pixel_y, video_on
                                                              ↓
[Buttons] → [Button Cleaner] → resetPulse → [Movement Controller] → objectX, objectY
                                    ↓
                            [Reset Counter] → resetCount → bgColorIndex (mod 10)
                                                              ↓
                                                    [Pixel Generator] → RGB out
                                                              ↓
                                                    [7-Seg Driver] → display
```

---

## Module Breakdown

| Module | Description |
|--------|-------------|
| `basys3_vga_system.vhd` | Top-level — connects all components |
| `pixel_clock_generator.vhd` | Divides 100MHz → 25MHz pixel clock |
| `vga_timing.vhd` | Generates hSync, vSync, video_on, pixel coordinates |
| `pixel_generator.vhd` | Renders square, circle, and background colour |
| `movement_controller.vhd` | Updates object position from button inputs |
| `button_cleaner.vhd` | 2-stage synchroniser + debouncer → clean pulse |
| `reset_counter.vhd` | Counts reset events (0–9999) |
| `seven_seg_driver.vhd` | Multiplexed 4-digit 7-segment display driver |

---

## Repository Structure

```
/rtl
  basys3_vga_system.vhd      -- top-level module
  pixel_clock_generator.vhd  -- 100MHz → 25MHz
  vga_timing.vhd             -- sync signals + pixel coordinates
  pixel_generator.vhd        -- shape and colour rendering
  movement_controller.vhd    -- button-driven position control
  button_cleaner.vhd         -- debouncer + single pulse generator
  reset_counter.vhd          -- reset event counter
  seven_seg_driver.vhd       -- 7-segment display driver

/constraints
  basys3_vga.xdc             -- Basys3 pin assignments
```

---

## Build & Flash Guide

### FPGA (Vivado 2021.2)
1. Create new project targeting `xc7a35tcpg236-1`
2. Add all `.vhd` files from `/rtl/` as design sources
3. Add `.xdc` from `/constraints/` as constraint source
4. Set `basys3_vga_system` as top module
5. Run Synthesis → Implementation → Generate Bitstream
6. Program Basys3 via Hardware Manager

### Pin Assignments (key signals)
| Signal | Pin | Description |
|--------|-----|-------------|
| clock | W5 | 100MHz system clock |
| centerButton | U18 | Reset / colour cycle |
| upButton | T18 | Move up |
| downButton | U17 | Move down |
| leftButton | W19 | Move left |
| rightButton | T17 | Move right |
| hSync | P19 | VGA horizontal sync |
| vSync | R19 | VGA vertical sync |

---

## Design Notes

**Circle rendering** uses the standard equation `dx² + dy² ≤ r²` evaluated per pixel, with the circle centre offset to the middle of the square bounding box. Colour priority ensures the circle always renders above the square.

**Button debouncing** uses a 2-stage flip-flop synchroniser followed by a counter that must reach `DEBOUNCE_COUNT_MAX` (300,000 cycles = 3ms at 100MHz) before accepting a new stable state. This prevents multiple reset triggers from a single button press.

**Reset position cycling** uses a `positionIndex` signal cycling through 15 predefined coordinates rather than a random generator — chosen for predictable hardware behaviour while still providing visual variety.

---

## Author

**Yun Nadi Kyaw Khaung**  
Electronics Engineering, University of Essex (2025–2026)  
[GitHub](https://github.com/yunkhaung)
