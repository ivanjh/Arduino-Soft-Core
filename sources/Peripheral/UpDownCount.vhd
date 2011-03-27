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
use IEEE.std_logic_unsigned.all;


use WORK.AVRuCPackage.all;
use WORK.SynthCtrlPack.all; -- Synthesis control
use WORK.SynchronizerCompPack.all; -- Component declarations for the synchronizers 

entity UpDownCount is
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
           count : out  std_logic_vector
           );
end UpDownCount;

architecture RTL of UpDownCount is
	signal count_Int :  std_logic_vector(count'range); --internal count
	signal activeMaxValue :  std_logic_vector(count'range); -- max / turn around value - current cycle
	signal count_Down :  std_logic;  -- Direction of counting
	signal maxValue :  std_logic_vector(count'range); -- max value, become active at next bottom
	signal tempMaxValue :  std_logic_vector(count'range); -- new max value, copied at bottom
	

	constant baseAddress : std_logic_vector(15 downto 0) := x"0123";

begin
	-- Map external connections to internal signals
	count <= count_Int;

	-- Increment/Decrement the counter
	StepCount:process(cp2,ireset)
	begin
		if (ireset='0') then                 -- Reset
			count_Int <= x"0";
			count_Down <= '0';
			activeMaxValue <= x"0";
		elsif (cp2='1' and cp2'event) then -- Clock
			if (count_Down='0') then
				if (count_Int >= activeMaxValue) then
					count_Down <= '1';
				else
					count_Int <= count_Int+1;
				end if;
			else
				if (count_Int = "0") then
					count_Down <= '0';
					activeMaxValue <= maxValue;  --Load new max value
				else
					count_Int <= count_Int-1;
				end if;
			end if;
		end if;
	end process;		


	LoadFromDbus:process(cp2,ireset)
	begin
		if (ireset='0') then                 -- Reset
			maxValue <= x"0";
			tempMaxValue <= x"0";
		elsif (cp2='1' and cp2'event) then   -- Clock
			if (adr=baseAddress) and iowe='1' then  -- Clock enable
				tempMaxValue <= tempMaxValue(tempMaxValue'high-dbus_in'length downto 0) & dbus_in;
				--tempMaxValue <= tempMaxValue(3 downto 0) & dbus_in;
			elsif (adr=baseAddress+1) and iowe='1' then  -- Clock enable
				tempMaxValue <= tempMaxValue(tempMaxValue'high-dbus_in'length downto 0) & dbus_in;
				maxValue <= tempMaxValue;
			end if;
		end if;
	end process;		

end RTL;
