----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.09.2021 19:31:16
-- Design Name: 
-- Module Name: uart_transmitter - Behavioral
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


entity uart_transmitter is
    
	Generic (
			g_clock_freq: integer := 100_000_000;
			g_baud_rate: integer := 115_200;
			g_stop_bit: integer := 2
	);
	
	Port ( clk : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           i_tx_start : in STD_LOGIC;
           o_tx : out STD_LOGIC;
		   o_tx_process: out STD_LOGIC;
           o_tx_done_tick : out STD_LOGIC);
end uart_transmitter;

architecture Behavioral of uart_transmitter is

constant bit_timer_lim: integer := g_clock_freq/g_baud_rate;
constant stop_bit_timer_lim: integer := (g_clock_freq/g_baud_rate)*g_stop_bit;

type state_type is (S_IDLE, S_START, S_DATA, S_STOP);

signal state: state_type := S_IDLE;
signal bit_timer: integer range 0 to stop_bit_timer_lim := 0;
signal shift_reg: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal bit_counter: integer range 0 to 7 := 0;

begin

process(clk) begin

	if (rising_edge(clk)) then

		case state is 
			
			when S_IDLE =>
				o_tx <= '1';
				o_tx_done_tick <= '0';
				o_tx_process <= '0';
				bit_counter <= 0;
				if (i_tx_start = '1') then
					state <= S_START;
					o_tx <= '0';
					shift_reg <= i_data;
				end if;
			
			when S_START =>
				o_tx           <= '0';
				o_tx_done_tick <= '0';
				o_tx_process   <= '0';
				
				if(bit_timer = bit_timer_lim-1) then
					state                 <= S_DATA;
					bit_timer             <= 0;
					o_tx_process  		  <= '1';
					o_tx                  <= shift_reg(0);
					shift_reg(6 downto 0) <= shift_reg(7 downto 1);
					shift_reg(7)          <= shift_reg(0);
				else
					bit_timer             <= bit_timer + 1;
				end if;
			
			when S_DATA =>
				o_tx_done_tick <= '0';
				
				
				if(bit_counter = 7) then
					if (bit_timer = bit_timer_lim-1) then
						state          <= S_STOP;
						bit_counter    <= 0;
						bit_timer      <= 0;
						o_tx_process   <= '0';
					else
						bit_timer <= bit_timer + 1;
					end if;
					
				else
					if (bit_timer = bit_timer_lim-1) then
						o_tx                  <= shift_reg(0);
						shift_reg(6 downto 0) <= shift_reg(7 downto 1);
					    shift_reg(7)          <= shift_reg(0);
						bit_counter           <= bit_counter + 1;
						bit_timer <= 0;
					else
						bit_timer <= bit_timer + 1;
					end if;
				end if;
				
			
			when S_STOP =>
				if (bit_timer = stop_bit_timer_lim-1) then
					state          <= S_IDLE;
					o_tx_done_tick <= '1';
					bit_timer <= 0;
				else
					bit_timer <= bit_timer + 1;
				end if;
				
		end case;
		
	end if;

end process;
		
end Behavioral;
