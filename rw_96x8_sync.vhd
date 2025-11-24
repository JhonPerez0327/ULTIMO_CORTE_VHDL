library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rw_96x8_sync is
    port (
        address  : in  std_logic_vector(7 downto 0);
        data_in  : in  std_logic_vector(7 downto 0);
        writen    : in  std_logic;
        clock    : in  std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
end rw_96x8_sync;

architecture arch of rw_96x8_sync is
    
    -- Tipo y señal de array para la memoria RAM
    -- Rango de 128 a 223 (96 posiciones)
    type rw_type is array (128 to 223) of std_logic_vector(7 downto 0);
    signal RW : rw_type;
    
    -- Señal interna de habilitación
    signal EN : std_logic;
    
begin
    
    -- Proceso para generar la señal enable
    -- Solo habilita cuando la dirección está en el rango 128-223
    enable : process(address)
    begin
        if ((to_integer(unsigned(address)) >= 128) and 
            (to_integer(unsigned(address)) <= 223)) then
            EN <= '1';
        else
            EN <= '0';
        end if;
    end process;
    
    -- Proceso de memoria sincrónica con lectura/escritura
    memory : process(clock)
    begin
        if (clock'event and clock='1') then
            if (EN='1' and writen='1') then
                -- Escritura en RAM
                RW(to_integer(unsigned(address))) <= data_in;
            elsif (EN='1' and writen='0') then
                -- Lectura de RAM
                data_out <= RW(to_integer(unsigned(address)));
            end if;
        end if;
    end process;
    
end arch;