--************************************************************************************************
-- Pwm Up Down Counter
-- Designed by Ivan Hamilton (ivan@chimerical.com.au)
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


--use WORK.AVRuCPackage.all;
--use WORK.SynthCtrlPack.all; -- Synthesis control
--use WORK.SynchronizerCompPack.all; -- Component declarations for the synchronizers 

entity UpDownCounter is
	generic(
		IoAddress : std_logic_vector(15 downto 0)
	); 
	port ( 
		-- AVR Control
		ireset     : in  std_logic;
		cp2        : in  std_logic;
		adr        : in  std_logic_vector(15 downto 0);
		dbus_in    : in  std_logic_vector(7 downto 0);
		iore       : in  std_logic;
		iowe       : in  std_logic;
		-- Counter Output
		count : out  std_logic_vector
	);
end UpDownCounter;

architecture RTL of UpDownCounter is
	signal count_Int      :  std_logic_vector(count'range); --internal counter
	signal count_Down     :  std_logic; -- Direction of counting

	signal tempValue      :  std_logic_vector(count'range); -- new max value, copied at bottom
	signal maxValue       :  std_logic_vector(count'range); -- max value, become active at next bottom
	signal activeMaxValue :  std_logic_vector(count'range); -- max / turn around value - current cycle

begin
	-- Map external connection to internal signal
	count <= count_Int;

	-- Increment/Decrement the counter
	StepCount:process(cp2,ireset)
	begin
		if (ireset='0') then -- Reset
			count_Int <= (others=>'0');
			count_Down <= '0';
			activeMaxValue <= (others=>'0');
		elsif (cp2='1' and cp2'event) then -- Rising clock
			if (count_Down='0') then
				if (count_Int >= activeMaxValue) then
					count_Down <= '1'; --Change count direction
				else
					count_Int <= count_Int+1;
				end if;
			else
				if (count_Int = "0") then
					count_Down <= '0'; --Change count direction
					activeMaxValue <= maxValue;  --Load new max value
				else
					count_Int <= count_Int-1;
				end if;
			end if;
		end if;
	end process;

	LoadFromDbus:process(cp2,ireset)
	variable
		newVal:std_logic_vector(count'range);
	begin
		if (ireset='0') then -- Reset
			maxValue <= (others=>'0');
			tempValue <= (others=>'0');
		elsif (cp2='1' and cp2'event) then -- Rising clock
			if (adr=IoAddress) and iowe='1' then -- Non loading write
				tempValue <= tempValue(tempValue'high-dbus_in'length downto 0) & dbus_in;
			elsif (adr=IoAddress+1) and iowe='1' then -- Loading write
				newVal:= tempValue(tempValue'high-dbus_in'length downto 0) & dbus_in;
				tempValue <= newVal;
				maxValue <= newVal;
			end if;
		end if;
	end process;

end RTL;