	----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:53:31 03/22/2011 
-- Design Name: 
-- Module Name:    PWMGen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.std_logic_1164.all;

use WORK.AVRuCPackage.all;
use WORK.SynthCtrlPack.all; -- Synthesis control
use WORK.SynchronizerCompPack.all; -- Component declarations for the synchronizers 

entity PwmGen is
	generic(ControlRegAddress : std_logic_vector(15 downto 0)); 
    Port ( 
	 	                -- AVR Control
                    ireset     : in  std_logic;
                    cp2	       : in  std_logic;
                    adr        : in  std_logic_vector(15 downto 0);
                    dbus_in    : in  std_logic_vector(7 downto 0);

                    iore       : in  std_logic;
                    iowe       : in  std_logic;

                    -- External connection
						  count : in  std_logic_vector;
							pwm : out  std_logic
			  );
end PwmGen;

architecture RTL of PwmGen is
	signal OC0_PWM0_En			       : std_logic;
	signal OC0_PWM0_Int  		       : std_logic_vector(dbus_in'range);
	
	signal SetPoint : std_logic_vector(count'range);
	signal pwm_Int : std_logic;
	
begin
	OC0_PWM0_En <= '1' when (adr=ControlRegAddress and iowe='1') else '0'; -- Hijacks unused external SRAM space	
	pwm <= pwm_Int;

--out_en <= (PORTx_Sel or DDRx_Sel or PINx_Sel) and iore;


	-- Store writes into control registers
	process(cp2,ireset)
	begin
		if (ireset='0') then                 -- Reset
			OC0_PWM0_Int <= (others => '0'); 
			SetPoint <= x"0";
		elsif (cp2='1' and cp2'event) then -- Clock
			if OC0_PWM0_En='1' and iowe='1' then -- Clocked & our address
				OC0_PWM0_Int <= dbus_in;
				SetPoint <= dbus_in;
			end if;
		end if;
	end process;

	-- Store writes into control registers
	process(cp2,ireset)
	begin
		if (ireset='0') then                 -- Reset
			pwm_Int <= '0'; 
		elsif (cp2='1' and cp2'event) then -- Clock
			if count>SetPoint then -- Clocked & our address
				pwm_Int <= '1';
			else
				pwm_Int <= '0';
			end if;
		end if;
	end process;


end RTL;