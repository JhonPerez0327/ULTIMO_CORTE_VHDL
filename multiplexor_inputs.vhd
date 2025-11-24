library IEEE;
use IEEE.std_logic_1164.all;

entity multiplexor_inputs is
    port (
        address  : in  std_logic_vector(7 downto 0);
        -- 16 puertos de entrada de 8 bits cada uno
        port_in_00 : in std_logic_vector(7 downto 0);
        port_in_01 : in std_logic_vector(7 downto 0);
        port_in_02 : in std_logic_vector(7 downto 0);
        port_in_03 : in std_logic_vector(7 downto 0);
        port_in_04 : in std_logic_vector(7 downto 0);
        port_in_05 : in std_logic_vector(7 downto 0);
        port_in_06 : in std_logic_vector(7 downto 0);
        port_in_07 : in std_logic_vector(7 downto 0);
        port_in_08 : in std_logic_vector(7 downto 0);
        port_in_09 : in std_logic_vector(7 downto 0);
        port_in_10 : in std_logic_vector(7 downto 0);
        port_in_11 : in std_logic_vector(7 downto 0);
        port_in_12 : in std_logic_vector(7 downto 0);
        port_in_13 : in std_logic_vector(7 downto 0);
        port_in_14 : in std_logic_vector(7 downto 0);
        port_in_15 : in std_logic_vector(7 downto 0);
        -- Salida del multiplexor
        data_out : out std_logic_vector(7 downto 0)
    );
end multiplexor_inputs;

architecture arch of multiplexor_inputs is
begin
    
    -- Multiplexor para seleccionar el puerto de entrada según la dirección
    -- Direcciones: x"F0" a x"FF"
    mux : process(address, port_in_00, port_in_01, port_in_02, port_in_03,
                  port_in_04, port_in_05, port_in_06, port_in_07,
                  port_in_08, port_in_09, port_in_10, port_in_11,
                  port_in_12, port_in_13, port_in_14, port_in_15)
    begin
        case address is
            when x"F0" => data_out <= port_in_00;
            when x"F1" => data_out <= port_in_01;
            when x"F2" => data_out <= port_in_02;
            when x"F3" => data_out <= port_in_03;
            when x"F4" => data_out <= port_in_04;
            when x"F5" => data_out <= port_in_05;
            when x"F6" => data_out <= port_in_06;
            when x"F7" => data_out <= port_in_07;
            when x"F8" => data_out <= port_in_08;
            when x"F9" => data_out <= port_in_09;
            when x"FA" => data_out <= port_in_10;
            when x"FB" => data_out <= port_in_11;
            when x"FC" => data_out <= port_in_12;
            when x"FD" => data_out <= port_in_13;
            when x"FE" => data_out <= port_in_14;
            when x"FF" => data_out <= port_in_15;
            when others => data_out <= x"00";
        end case;
    end process;
    
end arch;