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
use ieee.std_logic_unsigned.all;

use WORK.AVRuCPackage.all;
use WORK.SynthCtrlPack.all; -- Synthesis control
use WORK.SynchronizerCompPack.all; -- Component declarations for the synchronizers 

entity BusReg_AVR is
	generic(
		controlRegAddress : std_logic_vector(15 downto 0)
	); 
	port ( 
		-- AVR Control
                        ireset     : in std_logic;
                        cp2	       : in std_logic;
                        adr        : in std_logic_vector(15 downto 0);
                        dbus_in    : in std_logic_vector(7 downto 0);
                        dbus_out   : out std_logic_vector(7 downto 0);
                        iore       : in std_logic;
                        iowe       : in std_logic;
                        out_en     : out std_logic; 



          --Clock and reset
						ireset      => core_ireset,
						cp2         => core_cp2,
					    -- Bus masters
                        busmin		=> busmin,
						busmwait	=> busmwait,
						-- Memory Address,Data and Control
						ramadr     => mem_ramadr,
						ramdout    => mem_ram_dbus_in,
                        ramre      => mem_ramre,
                        ramwe      => mem_ramwe,
						cpuwait    => slv_cpuwait
						);



		-- External connection
		readValue : in  std_logic_vector;
		readEnable : out  std_logic;

		writeValue : out  std_logic_vector;
		writeEnable : in std_logic
	);
end BusReg_AVR;

architecture RTL of BusReg_AVR is
	signal syncWrite			       : std_logic;
	signal nonSyncWrite			       : std_logic;
	signal syncRead			       : std_logic;
	signal nonSyncRead			       : std_logic;
	
	signal tempRead : std_logic_vector(readValue'range);
	signal tempWrite : std_logic_vector(writeValue'range);

	signal currentWrite : std_logic_vector(writeValue'range);
	signal dbus_read: std_logic_vector(7 downto 0);
	
begin
	syncWrite <= '1' when (adr=ControlRegAddress and iowe='1') else '0'; -- Hijacks unused external SRAM space	
	nonSyncWrite <= '1' when (adr=ControlRegAddress+1 and iowe='1') else '0'; -- Hijacks unused external SRAM space	

	syncRead <= '1' when (adr=ControlRegAddress and iore='1') else '0'; -- Hijacks unused external SRAM space	
	nonSyncRead <= '1' when (adr=ControlRegAddress+1 and iore='1') else '0'; -- Hijacks unused external SRAM space	
	
	dbus_read <= tempRead(7 downto 0);

	writeValue <= currentWrite;

	-- Store writes into control registers
	process(cp2,ireset)
	begin
		if (ireset='0') then -- Reset
			tempRead <= (others => '0'); 
			tempWrite <= x"0";
		elsif (cp2='1' and cp2'event) then -- Clock
			if (syncWrite='1') then -- sync write
				tempWrite <= tempWrite(tempWrite'left-8 downto 0) & dbus_in;
				currentWrite <= tempWrite;
			elsif (nonSyncWrite='1') then -- non sync write
				tempWrite <= tempWrite(tempWrite'left-8 downto 0) & dbus_in;
			elsif (syncRead='1') then -- non sync write
				tempRead <= readValue;
			elsif (nonSyncRead='1') then -- non sync write
				tempRead <= b"00000000" & tempWrite(tempWrite'left downto 8);

			end if;
		end if;
	end process;

end RTL;