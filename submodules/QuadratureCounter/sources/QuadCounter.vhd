library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity QuadCounter is
		generic ( 
			IoAddress : std_logic_vector(15 downto 0);
			COUNTER_BIT_WIDTH : integer := 16;
			COUNTER_INVALID_BIT_WIDTH : integer := 16
			);
		port (
			-- AVR Control
			ireset     : in  std_logic;
			cp2        : in  std_logic;
			adr        : in  std_logic_vector(15 downto 0);
			iore       : in  std_logic;
			dbus_out   : out std_logic_vector (7 downto 0);
			out_en     : out std_logic;
			iowe       : in  std_logic;
			dbus_in    : in  std_logic_vector(7 downto 0);
			-- Counter Input
			A, B       : in  std_logic
	);
end QuadCounter;
     
architecture RTL of QuadCounter is
	--3 stage A&B sampling (2 for stability, 1 for transition analysis)
	signal A_delayed, B_delayed : std_logic_vector(2 downto 0);

	signal counter_Int : std_logic_vector(COUNTER_BIT_WIDTH-1 downto 0); --Internal counter
	signal counterInvalid_Int: std_logic_vector(COUNTER_INVALID_BIT_WIDTH-1 downto 0); --Internal counter

	signal count_enable : std_logic; -- signal that clocks counts
	signal count_invalid : std_logic; -- signal that clocks invalid transitions
	signal count_direction : std_logic; -- signal that has direction during counts
	
	signal tempValue : std_logic_vector(COUNTER_BIT_WIDTH-1 downto 0);
	
	signal dbus_out_Int  : std_logic_vector(dbus_out'range);
begin
dbus_out <= dbus_out_Int;
	--counter <= counter_Int;
	--counterInvalid <= counterInvalid_Int;

	count_enable <= A_delayed(1) XOR A_delayed(2) XOR B_delayed(1) XOR B_delayed(2); --A changed or B changed, but not both (both would be invalid).
	count_invalid <= (A_delayed(1) XOR A_delayed(2)) AND (B_delayed(1) XOR B_delayed(2)); --A changed AND B changed (invalid).
	count_direction <= A_delayed(1) XOR B_delayed(2);

	CaptureInputProcess : process (cp2, ireset)
	begin
		if ireset = '0' then --Reset
			A_delayed <= (others => A); 
			B_delayed <= (others => B); 
		elsif  (cp2='1' and cp2'event)  then --Clock
			A_delayed <= A_delayed(1 downto 0) & A;
			B_delayed <= B_delayed(1 downto 0) & B;
		end if;
	end process;

	CountProcess: process (cp2, ireset)
	begin
		if ireset = '0' then
			counter_Int <= (others => '0'); 
			counterInvalid_Int <= (others => '0'); 
		elsif  (cp2='1' and cp2'event)  then --Clock
			if  (count_invalid='1')  then -- Count invalid
				counterInvalid_Int <= counterInvalid_Int + 1;
			elsif  (count_enable='1')  then -- Count
				if  (count_direction='1')  then -- Count Up
					counter_Int <= counter_Int + '1';
				else -- Count Down
					counter_Int <= counter_Int - '1';
				end if;
			end if;
		end if;
	end process;


	out_en <= '1' when ((adr=IoAddress or adr=IoAddress+1) and (iore='1'))  else '0';

	LoadToDbus:process(cp2,ireset)
	variable
		newVal : std_logic_vector(tempValue'range);
	begin
		if (ireset='0') then -- Reset
			tempValue <= (others=>'0');
			dbus_out_Int <= (others=>'0');
		elsif (cp2='1' and cp2'event) then -- Rising clock
			if (adr=IoAddress) and iore='1' then -- Loading read
				newVal := counter_Int;
				tempValue <= newVal;
				dbus_out_Int <= newVal(7 downto 0);
			elsif (adr=IoAddress+1) and iore='1' then -- Non loading write
				newVal := "00000000" & tempValue(tempValue'left downto 8);
				tempValue <= newVal;
				dbus_out_Int <= newVal(7 downto 0);
			end if;
		end if;
	end process;

end RTL;
