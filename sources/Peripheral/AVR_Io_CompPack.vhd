--************************************************************************************************
-- Component declarations for AVR IO cores
-- Designed by Ivan Hamilton
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use WORK.AVRuCPackage.all;

package AVR_Io_CompPack is

	component QuadCounter is
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
	end component;

	component PwmComparator is
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
	end component;

	component UpDownCounter is
		generic(
			IoAddress : std_logic_vector(15 downto 0)); 
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
	end component;

end AVR_Io_CompPack;