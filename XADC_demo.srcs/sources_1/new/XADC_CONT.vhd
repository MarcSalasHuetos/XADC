----------------------------------------------------------------------------------
-- Engineer: Marc Salas Huetos
-- Create Date: 24.07.2020 09:55:07
-- Design Name: XADC_Single_Channel_Controller_FSM
-- Module Name: XADC_CONT - Behavioral
-- Target Devices: NEXYS A7 DIGILENT BOARD ARTIX-7 design
-- Description: Single channel XADC 
-- Revision: 26/08/2020
-- Revision 0.02 - File Created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;
entity XADC_CONT is
    port( 
        clk_sys     : in std_logic;
        rst_sys     : in std_logic;
        bsy         : in std_logic; -- busy input to avoid false sequences
        eoc         : in std_logic; -- end of cicle
        do_bus      : in std_logic_vector(15 downto 0); -- readable bus (11 downto 4) data values
        den         : out std_logic; -- initialization of sequence
        analog_val  : out std_logic_vector(11 downto 0); -- zoh analog value
        av_pre_sig  : out std_logic
    );
end XADC_CONT;

architecture Behavioral of XADC_CONT is

TYPE State_type IS (init_seq,wait_bsy,read_init,wait_eoc,read_reg,new_value); -- definition of state types
    signal state, next_state : state_type;
    
    signal reg_a_val    : unsigned(11 downto 0); -- registers defined actual and previous values
    signal reg_a_val_p  : unsigned(11 downto 0); 

begin
    
    analog_val <= std_logic_vector(reg_a_val_p(11 downto 0)); -- analog value zoh
    
    SR_flip_flop : process (clk_sys,rst_sys) -- flip flop process
    begin
        if (rst_sys = '1') then
            reg_a_val_p <= (others => '0'); -- reset of register
        elsif (clk_sys'event and clk_sys = '1') then
            reg_a_val_p <= reg_a_val; -- memory reload register kept
        end if ;
    end process SR_flip_flop ;
    
    SYNC_PROCESS : process (clk_sys,rst_sys) -- syncronous process of FSM
    begin 
        if rst_sys = '1' then -- in reset state return to init_seq state              
            state <= init_seq;
        elsif clk_sys'event and clk_sys = '1' then -- if not follow the next state defined is the actual state
            state <= next_state;
        end if;
    end process SYNC_PROCESS;
    
    OUTPUT_DECODE : process(state) -- output decoder process of FSM
    begin
        case state is
            when init_seq => 
                den <= '0';
                av_pre_sig <= '0';
                reg_a_val <= reg_a_val_p;
            when wait_bsy => 
                den <= '0';
                av_pre_sig <= '0';
                reg_a_val <= reg_a_val_p;
            when read_init =>
                den <= '1'; -- only in read_init state the den value will be set to '1' during one clock cicle
                av_pre_sig <= '0';
                reg_a_val <= reg_a_val_p;
            when wait_eoc =>
                den <= '0';
                av_pre_sig <= '0';
                reg_a_val <= reg_a_val_p;
            when read_reg =>
                den <= '0';
                av_pre_sig <= '1';
                reg_a_val <= unsigned(do_bus(15 downto 4)); -- read the 12 first bits of the information bus
            when new_value =>
                den <= '0';
                av_pre_sig <= '0';
                reg_a_val <= reg_a_val_p;
            when others =>
                den <= '0';
                av_pre_sig <= '0'; -- Available pre-signal value ready to compute in the analog_val register
                reg_a_val <= reg_a_val_p;
        end case;
    end process OUTPUT_DECODE;
    
    NEXT_STATE_DECODE : process(state,bsy,eoc) -- next_state decoder process of FSM
    begin
        case state is
            when init_seq =>
                if bsy = '1' then 
                    next_state <= wait_bsy;
                else
                    next_state <= init_seq;
                end if;
            when wait_bsy =>
                if bsy = '0' then 
                    next_state <= read_init;
                else
                    next_state <= wait_bsy;
                end if;
            when read_init =>
                    next_state <= wait_eoc;
            when wait_eoc =>
                if eoc = '1' then
                    next_state <= read_reg;
                else
                    next_state <= wait_eoc;
                end if;
            when read_reg =>
                next_state <= new_value;
            when new_value =>
                next_state <= read_init;
            when others =>
                next_state <= init_seq;
        end case;
    end process NEXT_STATE_DECODE;
    
end Behavioral;
