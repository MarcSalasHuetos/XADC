----------------------------------------------------------------------------------
-- Engineer: Marc Salas Huetos
-- Create Date: 08/26/2020 08:41:07 AM 
-- Design Name: Clk_d_500kHz 
-- Module Name: Clk_d_500kHz - Behavioral
-- Target Devices: NEXYS A7 DIGILENT BOARD ARTIX-7 design
-- Description: Controller FSM computation 
-- Revision: 26/08/2020
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity Clk_d_500kHz is
    port ( 
        clk_sys     : in std_logic;
        rst_sys     : in std_logic;
        clk_500kHz  : out std_logic -- 500Khz frequency clock cicle
    );
end Clk_d_500kHz;

architecture Behavioral of Clk_d_500kHz is

    signal reg_counter_clk      : unsigned(7 downto 0); -- counter register 
    signal reg_clk_500kHz       : std_logic := '0'; -- clock register
begin
    process(clk_sys,rst_sys)
    begin
        if (rst_sys = '1') then 
            reg_counter_clk <= (others => '0');
        elsif(clk_sys'event and clk_sys = '1') then -- if the reset is not pressed 
            if reg_counter_clk >= "11001000" then -- if the regiser is 200
                reg_clk_500kHz <= '1'; -- clock cicle to 1
                reg_counter_clk <= (others => '0');
            else -- if it's not 200
                reg_clk_500kHz <= '0';
                reg_counter_clk <= reg_counter_clk + 1; -- count +1
            end if;
        end if;
    end process;
    clk_500kHz <= reg_clk_500kHz;
end Behavioral;
