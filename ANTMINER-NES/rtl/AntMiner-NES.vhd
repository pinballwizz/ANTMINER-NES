---------------------------------------------------------------------------------
--                         NES - Antminer S9
--                      Code from Brian Bennett
--
--                        Modified for Antminer S9 
--                           by pinballwiz 
--                             30/06/2026
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5 : Add coin
--   2 : Start 2 players
--   1 : Start 1 player
--   Ctrl	     : Fire 1
--   X   	     : Fire 2
--   Up Arrow    : Move Up
--   Down Arrow  : Move Down
--   RIGHT arrow : Move Right
--   LEFT arrow  : Move Left
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity NES_antminer is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
	rxd     	: in std_logic;
	txd     	: out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
	led         : out std_logic_vector(7 downto 0);
	aled        : out std_logic_vector(3 downto 0);
	dipsw       : in std_logic_vector(7 downto 0)
 );
end NES_antminer;
------------------------------------------------------------------------------
architecture struct of NES_antminer is

 signal clock_100       : std_logic;
 signal clock_24        : std_logic;
 signal clock_9         : std_logic;
 --
 signal video_r         : std_logic_vector(3 downto 0);
 signal video_g         : std_logic_vector(3 downto 0);
 signal video_b         : std_logic_vector(3 downto 0);
 --
 signal h_sync          : std_logic;
 signal v_sync	        : std_logic;
 signal h_blank          : std_logic;
 signal v_blank	        : std_logic;
 --
 signal reset           : std_logic;
 --
 signal audio_pwm       : std_logic;
 --
 signal SW_LEFT         : std_logic;
 signal SW_RIGHT        : std_logic;
 signal SW_UP           : std_logic;
 signal SW_DOWN         : std_logic;
 signal SW_FIRE         : std_logic;
 signal SW_BOMB         : std_logic;
 signal SW_COIN         : std_logic;
 signal P1_START        : std_logic;
 signal P2_START        : std_logic;
 -- 
 signal INP1            : std_logic_vector(7 downto 0);
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(9 downto 0);
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
component NES_clocks
port(
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_out3          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
---------------------------------------------------------------------------
begin

 reset <= not I_RESET;
 aled(3 downto 0) <= "1111"; -- turn unused onboard leds off
---------------------------------------------------------------------------
-- Clocks

Clocks: NES_clocks
    port map (
        clk_in1   => clock_50,
        clk_out1  => clock_100,
        clk_out2  => clock_24,
        clk_out3  => clock_9
    );
---------------------------------------------------------------------------
-- Inputs

SW_LEFT    <= joy_BBBBFRLDU(2);
SW_RIGHT   <= joy_BBBBFRLDU(3);
SW_UP      <= joy_BBBBFRLDU(0);
SW_DOWN    <= joy_BBBBFRLDU(1);
SW_FIRE    <= joy_BBBBFRLDU(4);
SW_BOMB    <= joy_BBBBFRLDU(8);
SW_COIN    <= joy_BBBBFRLDU(7);
P1_START   <= joy_BBBBFRLDU(5);
P2_START   <= joy_BBBBFRLDU(6);

INP1 <= not SW_RIGHT & not SW_LEFT & not SW_DOWN & not SW_UP & not SW_COIN & not P1_START & not SW_FIRE & not SW_BOMB;

---------------------------------------------------------------------------
-- Main

nes_top : entity work.nes_top
  port map (
 CLK_100MHZ => clock_100,
 BTN_SOUTH  => reset, -- sys reset
 BTN_EAST   => '0', -- cpu reset
 RXD        => rxd,
 TXD        => txd,
 SW         => "0000", -- audio channels mute
 VGA_HSYNC  => O_HSYNC,
 VGA_VSYNC  => O_VSYNC,
 VGA_RED    => video_r,
 VGA_GREEN  => video_g,
 VGA_BLUE   => video_b,
 AUDIO      => audio_pwm,
 joypad_cfg => INP1,
 joypad_cfg_upd => clock_24,
 AD         => AD
 );
 ----------------------------------------------------------------------------
 -- Video Out 

O_VIDEO_R <= video_r(3 downto 1); 
O_VIDEO_G <= video_g(3 downto 1); 
O_VIDEO_B <= video_b(3 downto 2); 
-----------------------------------------------------------------------------
 -- Audio Out 

O_AUDIO_L <= audio_pwm; 
O_AUDIO_R <= audio_pwm;
-----------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_9,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
-----------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk         => clock_9,
  kbdint      => kbd_intr,
  kbdscancode => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU  => joy_BBBBFRLDU 
);
-----------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(7 downto 0) <= not AD(14 downto 7);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
-----------------------------------------------------------------------------
end struct;