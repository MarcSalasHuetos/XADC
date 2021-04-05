----------------------------------------------------------------------------------
-- Engineer: Marc Salas Huetos
-- Create Date: 24.07.2020 09:55:07
-- Design Name: XADC_Single_Channel_Mixed
-- Module Name: SI_CH_XADC - Mixed
-- Target Devices: NEXYS A7 DIGILENT BOARD ARTIX-7 design
-- Description: Single channel XADC 
-- Revision: 26/08/2020
-- Revision 0.02 - File Created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Perform unsigned and calculus
--library UNISIM;
--use UNISIM.VComponents.all;
entity SI_CH_XADC is
    port( 
        clk_sys     : in std_logic; 
        rst_sys     : in std_logic;
        vp_11       : in std_logic; -- Analog input positive (Placed In LVCMOS33)
        vn_11       : in std_logic; -- Analog input negative (Placed In LVCMOS33)
        f_val       : out std_logic_vector(11 downto 0); -- Digitalized bipolar -0.5 to 0.5 V with resolution of 244 uV 
        av_pre_sig  : out std_logic
    );
end SI_CH_XADC;

architecture Mixed of SI_CH_XADC is
    component xadc_wiz_0 is
        port(
            daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
            den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
            di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
            dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
            do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
            drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
            dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
            reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
            convst_in       : in  STD_LOGIC;                         -- Convert Start Input
            vauxp11         : in  STD_LOGIC;                         -- Auxiliary Channel 11 (THIS WORKS)
            vauxn11         : in  STD_LOGIC;
            busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
            channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
            eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
            eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
            alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
            vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair (DOESN'T WORK AT DIGILENT BOARD)
            vn_in           : in  STD_LOGIC
        );
    end component;
    
    component XADC_CONT is
        port( 
            clk_sys     : in std_logic;
            rst_sys     : in std_logic;
            bsy         : in std_logic; -- busy input to avoid false sequences
            eoc         : in std_logic; -- end of cicle 
            do_bus      : in std_logic_vector(15 downto 0); -- readable bus (11 downto 4) data values
            den         : out std_logic; -- initialization of sequence
            analog_val  : out std_logic_vector(11 downto 0); -- zoh analog value
            av_pre_sig  : out std_logic -- new available value clock cicle
        );
    end component;
    
    component Clk_d_500kHz is
        port ( 
            clk_sys     : in std_logic;
            rst_sys     : in std_logic;
            clk_500kHz  : out std_logic
        );
    end component;
    
    signal daddr_in_sig     : std_logic_vector(6 downto 0);
    signal den_in_sig       : std_logic;
    signal di_in_sig        : std_logic_vector(15 downto 0);
    signal dwe_in_sig       : std_logic;
    signal do_out_sig       : std_logic_vector(15 downto 0);
    signal drdy_out_sig     : std_logic;
    signal busy_out_sig     : std_logic;
    signal channel_out_sig  : std_logic_vector(4 downto 0);
    signal eoc_out_sig      : std_logic;
    signal eos_out_sig      : std_logic;
    signal alarm_out_sig    : std_logic;
    signal vp_sig           : std_logic;
    signal vn_sig           : std_logic;
    signal analog_val_sig   : std_logic_vector(11 downto 0);
    signal clk_500kHz_sig   : std_logic;
    
begin
    
    daddr_in_sig <= "001"&x"B"; -- Reading the register of VAUX11 
    dwe_in_sig <= '0'; -- Placed to '0' to perform always a read sequence
    di_in_sig <= (others => '0');
    f_val <= analog_val_sig; 

    -- Connection of blocks.
    ADC : xadc_wiz_0 port map(
        daddr_in    => daddr_in_sig,
        den_in      => den_in_sig,
        di_in       => di_in_sig,
        dwe_in      => dwe_in_sig,
        do_out      => do_out_sig,
        drdy_out    => drdy_out_sig,
        dclk_in     => clk_sys,
        reset_in    => rst_sys,
        convst_in   => clk_500kHz_sig,
        vauxp11     => vp_11,
        vauxn11     => vn_11,
        busy_out    => busy_out_sig,
        channel_out => channel_out_sig,
        eoc_out     => eoc_out_sig,
        eos_out     => eos_out_sig,
        alarm_out   => alarm_out_sig,
        vp_in       => vp_sig,
        vn_in       => vp_sig
    );

    CONT : XADC_CONT port map( 
        clk_sys     => clk_sys,
        rst_sys     => rst_sys,
        bsy         => busy_out_sig,
        eoc         => eoc_out_sig,
        do_bus      => do_out_sig,
        den         => den_in_sig,
        analog_val  => analog_val_sig,
        av_pre_sig  => av_pre_sig
    );
    
    C500KHz : Clk_d_500kHz port map( 
        clk_sys     => clk_sys,
        rst_sys     => rst_sys,
        clk_500kHz  => clk_500kHz_sig
    );

end Mixed;
