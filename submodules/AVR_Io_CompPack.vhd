--************************************************************************************************
-- Component declarations for AVR IO cores
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use WORK.AVRuCPackage.all;

package AVR_Io_CompPack is

	component PwmComparator is
		generic(
			IoAddress : std_logic_vector(15 downto 0)
		); 
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
	end component;

	component QuadCounter is
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
	end component;

	-- Example Core - core9 
	COMPONENT papilio_core_template
		PORT(
			-- begin Signals required by AVR8 for this core, do not modify.
			nReset 		: in  STD_LOGIC;
			clk 			: in  STD_LOGIC;
			adr 			: in  STD_LOGIC_VECTOR (15 downto 0);
			dbus_in 		: in  STD_LOGIC_VECTOR (7 downto 0);
			dbus_out 	: out  STD_LOGIC_VECTOR (7 downto 0);
			iore 			: in  STD_LOGIC;
			iowe 			: in  STD_LOGIC;
			out_en		: out STD_LOGIC;
			-- end Signals required by AVR8 for this core, do not modify.

			--Define signals that you want to go in or out of the peripheral. These are usually going to be connected to extenal pins of the Papilio board.
			--Two Output Signals
			output_sig	: out std_logic_vector (1 downto 0);

			--Two Input Signals
			input_sig		: in std_logic_vector (1 downto 0)
		);
	END COMPONENT;

end AVR_Io_CompPack;
