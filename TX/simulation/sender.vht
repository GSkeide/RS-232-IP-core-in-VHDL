-- Copyright (C) 2024  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "11/12/2024 12:03:04"
                                                            
-- Vhdl Test Bench template for design  :  sender
-- 
-- Simulation tool : Questa Intel FPGA (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY sender_vhd_tst IS
END sender_vhd_tst;
ARCHITECTURE sender_arch OF sender_vhd_tst IS
-- constants      
constant periode : time := 20 ns;                                             
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL dataIn : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL dataOut : STD_LOGIC;
SIGNAL rst_n : STD_LOGIC;
SIGNAL startPulse : STD_LOGIC;
SIGNAL txReady : STD_LOGIC;
COMPONENT sender
	PORT (
	clk : IN STD_LOGIC;
	dataIn : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	dataOut : OUT STD_LOGIC;
	rst_n : IN STD_LOGIC;
	startPulse : IN STD_LOGIC;
	txReady : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : sender
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	dataIn => dataIn,
	dataOut => dataOut,
	rst_n => rst_n,
	startPulse => startPulse,
	txReady => txReady
	);
	init : PROCESS                                               
		-- variable declarations                                     
		BEGIN                                                        
				-- code that executes only once  
				rst_n <= '1', '0' after 20*50*periode;
				dataIn <= "10010010";
				startPulse <= '1', '0' after 3*50*periode, '1' after 5*50*periode;
		WAIT;                                                       
		END PROCESS init;   
    
		
		p_clk : process
		begin
			clk <= '0';
			loop
					wait for periode/2;
					clk <= not clk;
			end loop;
			wait;
		end process;                                            
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        -- code executes for every event on sensitivity list  
WAIT;                                                        
END PROCESS always;                                          
END sender_arch;
