--************************************************************************************************
-- Pwm Output Compare
-- Designed by Ivan Hamilton (ivan@chimerical.com.au)
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity PwmComparator is
	generic(
		IoAddress : std_logic_vector(15 downto 0)); 
	port ( 
		-- IO Bus
		ireset   : in  std_logic;
		cp2      : in  std_logic;
		adr      : in  std_logic_vector(15 downto 0);
		dbus_in  : in  std_logic_vector(7 downto 0);
		iore     : in  std_logic;
		iowe     : in  std_logic;
		-- Counter Input
		input : in  std_logic_vector;
		-- Compare Output 
		output : out  std_logic
	);
end PwmComparator;

architecture RTL of PwmComparator is
	signal tempValue :  std_logic_vector(input'range);
	signal SetPoint : std_logic_vector(input'range);
begin
	-- Create output
	process(cp2,ireset)
	begin
		if (ireset='0') then -- Reset
			output <= '0'; 
		elsif (cp2='1' and cp2'event) then -- Rising clock
			if input>SetPoint then
				output <= '1';
			else
				output <= '0';
			end if;
		end if;
	end process;

	LoadFromDbus:process(cp2,ireset)
	variable
		newVal : std_logic_vector(input'range);
	begin
		if (ireset='0') then -- Reset
			SetPoint <= (others=>'1');
			tempValue <= (others=>'0');
		elsif (cp2='1' and cp2'event) then -- Rising clock
			if (adr=IoAddress) and iowe='1' then -- Non loading write
				tempValue <= tempValue(tempValue'high-dbus_in'length downto 0) & dbus_in;
			elsif (adr=IoAddress+1) and iowe='1' then -- Loading write
				newVal:= tempValue(tempValue'high-dbus_in'length downto 0) & dbus_in;
				tempValue <= newVal;
				SetPoint <= newVal;
			end if;
		end if;
	end process;

end RTL;