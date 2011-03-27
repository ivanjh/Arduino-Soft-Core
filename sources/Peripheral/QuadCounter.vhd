library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity QuadCounter is
	generic ( 
		COUNTER_BIT_WIDTH : integer := 8;
		COUNTER_INVALID_BIT_WIDTH : integer := 8
		);
	port (
		ireset : in std_logic; 
		clk : in std_logic; 
		A, B : in std_logic; 
		counter : out std_logic_vector(COUNTER_BIT_WIDTH-1 downto 0);
		counterInvalid : out std_logic_vector(COUNTER_INVALID_BIT_WIDTH-1 downto 0)
	);
end QuadCounter;
     
architecture RTL of QuadCounter is
	--3 stage A&B sampling (2 for stability, 1 for transition analysis)
	signal A_delayed, B_delayed : std_logic_vector(2 downto 0);

	signal counter_Int : std_logic_vector(counter'range); --Internal counter
	signal counterInvalid_Int: std_logic_vector(counterInvalid'range); --Internal counter

	signal count_enable : std_logic; -- signal that clocks counts
	signal count_invalid : std_logic; -- signal that clocks invalid transitions
	signal count_direction : std_logic; -- signal that has direction during counts
begin
	counter <= counter_Int;
	counterInvalid <= counterInvalid_Int;

	count_enable <= A_delayed(1) XOR A_delayed(2) XOR B_delayed(1) XOR B_delayed(2); --A changed or B changed, but not both (both would be invalid).
	count_invalid <= (A_delayed(1) XOR A_delayed(2)) AND (B_delayed(1) XOR B_delayed(2)); --A changed AND B changed (invalid).
	count_direction <= A_delayed(1) XOR B_delayed(2);

	CaptureInputProcess : process (clk, ireset)
	begin
		if ireset = '0' then --Reset
			A_delayed <= (others => A); 
			B_delayed <= (others => B); 
		elsif  (clk='1' and clk'event)  then --Clock
			A_delayed <= A_delayed(1 downto 0) & A;
			B_delayed <= B_delayed(1 downto 0) & B;
		end if;
	end process;

	CountProcess: process (clk, ireset)
	begin
		if ireset = '0' then
			counter_Int <= (others => '0'); 
			counterInvalid_Int <= (others => '0'); 
		elsif  (clk='1' and clk'event)  then --Clock
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

end RTL;
