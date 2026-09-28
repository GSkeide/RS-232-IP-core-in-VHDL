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
-- Generated on "11/18/2024 11:17:25"
                                                            
-- Vhdl Test Bench template for design  :  mottaker
-- 
-- Simulation tool : Questa Intel FPGA (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY mottaker_vhd_tst IS
END mottaker_vhd_tst;
ARCHITECTURE mottaker_arch OF mottaker_vhd_tst IS
-- constants     
constant periode : time := 20 ns;                                            
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL dataUt : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL dataValidUt : STD_LOGIC;
SIGNAL error : STD_LOGIC;
SIGNAL inndata : STD_LOGIC;
SIGNAL rst_n : STD_LOGIC;
COMPONENT mottaker
	PORT (
	clk : IN STD_LOGIC;
	dataUt : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	dataValidUt : OUT STD_LOGIC;
	error : OUT STD_LOGIC;
	inndata : IN STD_LOGIC;
	rst_n : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : mottaker
	PORT MAP (
-- list connections between master ports and signals

	clk => clk,
	dataUt => dataUt,
	dataValidUt => dataValidUt,
	error => error,
	inndata => inndata,
	rst_n => rst_n
	);
init : PROCESS                                               
BEGIN                                                        
	-- code that executes only once  
	rst_n <= '1', '0' after 14*50*periode;
	inndata <= '1','1' after 1*50*periode, '1' after 2*50*periode, '0' after 3*50*periode, '1' after 4*50*periode, '0' after 5*50*periode, '0' after 6*50*periode,'1' after 7*50*periode, '0' after 8*50*periode, '0' after 9*50*periode, '1' after 10*50*periode, '0' after 11*50*periode, '1' after 12*50*periode, '1' after 13*50*periode;
	
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
END mottaker_arch;
