----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:23:06 05/24/2024 
-- Design Name: 
-- Module Name:    EPS09 - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EPS09 is
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           DISABLE : in  STD_LOGIC;
           DIN1 : in  STD_LOGIC;
           DIN2 : in  STD_LOGIC;
           BINGO : out  STD_LOGIC;
           DOUT16 : out  STD_LOGIC_VECTOR (15 downto 0);
           DOUT_BYTE : out  STD_LOGIC);
end EPS09;

architecture Behavioral of EPS09 is

------       signals here        -------

type type_state1 is (IDLE, TRIGGERED, TRIGGERING);
type type_state2 is (CHEKING, NOT_MIRROR, MIRROR);
signal MIRROR_16, MIRROR_8 : type_state2 :=CHEKING;
signal RESET_STATE : type_state1 :=IDLE;
signal CNT : integer range 0 to 100 :=0;
signal CNT_16, MIRROR_16_CNT, MIRROR_8_CNT  : integer range 0 to 15 := 0;
signal IN1, IN2 : std_logic_vector (15 downto 0);
signal REG, BINGO_OUT : std_logic;
signal DOUT16_OUT : std_logic_vector (15 downto 0);
signal BINGO_OUT : std_logic := '0';
signal DOUT16_OUT : std_logic := 'Z';

begin

if CLK'event and CLK=1 then
	case RESET_STATE is
		
		when IDLE =>
			if RESET = '0';
				RESET_STATE <= TRIGGERING;
				CNT <= 0;
			end if
		
		when TRIGGERING =>
			if RESET = '0' then
				CNT <= CNT + 1;
			else
				if (CNT >= 5 and CNT <=7) then              ---- clock time set to 100 to 140 ns (if clock cycle time equal to 20 ns)
					RESET_STATUS <= TRIGGERED;
					CNT_16 <= 0;	                        ---- CNT_16 sets for counting to take 16 bit serial from DIN1 and DIN2
                    MIRROR_16 <= CHEKING;				    ---- set the cheking status of mirror_16 to cheking mode	
                    MIRROR_16_CNT <= 0;	                    ---- MIRROR_16_CNT sets for counting to check mirror_16 state
                    MIRROR_8 <= CHEKING;				    ---- set the cheking status of mirror_8 to cheking mode	
                    MIRROR_8_CNT <= 0
                else 
					RESET_STATUS <= IDLE;
					CNT <= 0;
				end if
			end if
		when TRIGGERED =>
			if RESET = '0' then
				RESET_STATUS <= IDLE;
				CNT <= 0;
			else                                             --- if reset happen correctly, do the next steps:
				if CNT_16 < 15 then                          --- save DIN1 and DIN2 to internal signals IN1 and IN2   
					IN1(0) <= DIN1;
					IN1(15 downto 1) <= IN1(14 downto 0);    
					IN2(0) <= DIN2;
					IN2(15 downto 1) <= IN2(14 downto 0);
					CNT_16 <= CNT_16 + 1;   
				else                                        --- if all DIN1 and DIN2 readed and saved do the next:
------ cheking if IN1 and IN2 is MIRROR or not:

                    if MIRROR_16 = CHEKING then
                        if MIRROR_16_CNT < 15 then
                            if IN1(0) = IN2(0) then
                                MIRROR_16 <= NOT_MIRROR;
                            else
                                REG <= IN1(15);
                                IN1(15 downto 1) <= IN1(14 downto 0);
                                IN1(0) <= REG;
                                REG <= IN2(15);
                                IN2(15 downto 1) <= IN2(14 downto 0);
                                IN2(0) <= REG;
                            end if;
                        else
                            MIRROR_16 <= MIRROR;
                        end if;
                    end if;
                        
--- cheking the 8 mirror of DIN1:

                    if MIRROR_8 = CHEKING then
                        if MIRROR_8_CNT < 7 then
                            if IN1(0) = IN1(8) then
                                MIRROR_8 <= NOT_MIRROR;
                                MIRROR_8_CNT <= 0;
                            else
                                REG <= IN1(15);
                                IN1(15 downto 9) <= IN1(14 downto 8);
                                IN1(8) <= REG;
                                REG <= IN1(7);
                                IN1(7 downto 1) <= IN1(6 downto 0);
                                IN1(0) <= REG;
                            end if;
                        else
                            MIRROR_8 <= MIRROR;
                        end if;
                    end if;

--- cheking the 8 mirror of DIN2:

 -------- ********** you should do the second check for second din2

                    if MIRROR_8 != MIRROR then
                        if MIRROR_8 = CHEKING then
                            if MIRROR_8_CNT < 7 then
                                if IN2(0) = IN2(8) then
                                    MIRROR_8 <= NOT_MIRROR;
                                    MIRROR_8_CNT <= 0;
                                else
                                    REG <= IN2(15);
                                    IN2(15 downto 9) <= IN2(14 downto 8);
                                    IN2(8) <= REG;
                                    REG <= IN2(7);
                                    IN2(7 downto 1) <= IN2(6 downto 0);
                                    IN2(0) <= REG;
                                end if;
                            else
                                MIRROR_8 <= MIRROR;
                            end if;
                        end if;
                    end if;


end Behavioral;