----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.09.2021 19:37:09
-- Design Name: 
-- Module Name: uart_receiver - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity uart_receiver is
    
	Generic (
			g_clkfreq: integer := 100_000_000;
			g_baudrate: integer := 115_200
			);
	
	Port ( clk : in STD_LOGIC;
           i_rx : in STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_done_tick : out STD_LOGIC);

end uart_receiver;

architecture Behavioral of uart_receiver is

constant bit_timer_lim: integer := g_clkfreq/g_baudrate;

type state_type is (S_IDLE, S_START, S_DATA, S_STOP);

signal state: state_type := S_IDLE;
signal bit_timer: integer range 0 to bit_timer_lim := 0;
signal bit_counter: integer range 0 to 7 := 0;
signal shift_reg: std_logic_vector (7 downto 0) := (others => '0');

begin

process(clk) begin

	if (rising_edge(clk)) then
		
		case state is 
			
			when S_IDLE =>
				o_done_tick <= '0';
				bit_timer <= 0;
				bit_counter <= 0;
				if (i_rx = '0') then
					state <= S_START;
				end if;
			
			when S_START =>
				if (bit_timer = (bit_timer_lim/2)-1) then
					state <= S_DATA;
					bit_timer <= 0;
				else
					bit_timer <= bit_timer + 1;
				end if;
			
			when S_DATA =>
				if (bit_timer = bit_timer_lim - 1) then
					if (bit_counter = 7) then
						state <= S_STOP;
						bit_counter <= 0;
						bit_timer <= 0;
					end if;
					
					shift_reg <= i_rx & shift_reg(7 downto 1);
					bit_timer <= 0;
					bit_counter <= bit_counter + 1;
				else
					bit_timer <= bit_timer + 1;
				end if;
			
			when S_STOP =>
				if (bit_timer = bit_timer_lim - 1) then
					state <= S_IDLE;
					bit_timer <= 0;
					o_done_tick <= '1';
				else
					bit_timer <= bit_timer + 1;
				end if;
		
		end case;


	end if;

end process;
o_data <= shift_reg;


end Behavioral;
