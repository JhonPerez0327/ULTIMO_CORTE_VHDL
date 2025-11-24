library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory is
    port (
        -- Entradas desde la FPGA
        switches     : in  std_logic_vector(7 downto 0);  -- Switches de la FPGA para address
        dip_switches : in  std_logic_vector(7 downto 0);  -- DIP switches para data_in
        writen_sw    : in  std_logic;                      -- Switch para controlar writen
        reset_sw     : in  std_logic;                      -- Switch para reset
        clock        : in  std_logic;                      -- Clock de la FPGA
        -- Salidas a los displays de 7 segmentos
        display_0    : out std_logic_vector(6 downto 0);  -- Display 0 (nibble bajo address)
        display_1    : out std_logic_vector(6 downto 0);  -- Display 1 (nibble alto address)
        display_2    : out std_logic_vector(6 downto 0);  -- Display 2 (nibble bajo data_out)
        display_3    : out std_logic_vector(6 downto 0);  -- Display 3 (nibble alto data_out)
        -- Salidas de los port_out (opcional - conectar a LEDs)
        port_out_00 : out std_logic_vector(7 downto 0);
        port_out_01 : out std_logic_vector(7 downto 0)
    );
end memory;

architecture structural of memory is
    
    -- Declaración del decodificador de 7 segmentos
    component systemd
        port (
            A  : in  std_logic_vector(3 downto 0);
            D0 : out std_logic_vector(6 downto 0)
        );
    end component;
    
    -- Declaración de componentes de memoria
    component rom_128x8_sync
        port (
            address  : in  std_logic_vector(7 downto 0);
            clock    : in  std_logic;
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component rw_96x8_sync
        port (
            address  : in  std_logic_vector(7 downto 0);
            data_in  : in  std_logic_vector(7 downto 0);
            writen   : in  std_logic;
            clock    : in  std_logic;
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component output_ports
        port (
            address  : in  std_logic_vector(7 downto 0);
            data_in  : in  std_logic_vector(7 downto 0);
            writen   : in  std_logic;
            clock    : in  std_logic;
            reset    : in  std_logic;
            port_out_00 : out std_logic_vector(7 downto 0);
            port_out_01 : out std_logic_vector(7 downto 0)
        );
    end component;
    
    -- Señales internas del sistema de memoria
    signal address      : std_logic_vector(7 downto 0);
    signal data_in      : std_logic_vector(7 downto 0);
    signal data_out     : std_logic_vector(7 downto 0);
    signal writen       : std_logic;
    signal reset        : std_logic;
    
    -- Señales internas para las salidas de ROM y RAM
    signal rom_data_out : std_logic_vector(7 downto 0);
    signal rw_data_out  : std_logic_vector(7 downto 0);
    
    -- Señales para los port_in (palabras A y B)
    signal port_in_00   : std_logic_vector(7 downto 0);  -- Palabra A (switches)
    signal port_in_01   : std_logic_vector(7 downto 0);  -- Palabra B (dip_switches)
    
    -- Señales para los nibbles que van a los displays
    signal address_low  : std_logic_vector(3 downto 0);
    signal address_high : std_logic_vector(3 downto 0);
    signal data_low     : std_logic_vector(3 downto 0);
    signal data_high    : std_logic_vector(3 downto 0);
    
begin
    
    -- Conectar las entradas de la FPGA a las señales internas
    address      <= switches;
    data_in      <= dip_switches;
    writen       <= writen_sw;
    reset        <= reset_sw;
    
    -- Conectar switches y dip_switches a port_in (palabras A y B)
    port_in_00   <= switches;      -- Palabra A
    port_in_01   <= dip_switches;  -- Palabra B
    
    -- Dividir address y data_out en nibbles para los displays
    address_low  <= address(3 downto 0);    -- Nibble bajo de address
    address_high <= address(7 downto 4);    -- Nibble alto de address
    data_low     <= data_out(3 downto 0);   -- Nibble bajo de data_out
    data_high    <= data_out(7 downto 4);   -- Nibble alto de data_out
    
    -- Instanciación de la memoria ROM
    U1 : rom_128x8_sync
        port map (
            address  => address,
            clock    => clock,
            data_out => rom_data_out
        );
    
    -- Instanciación de la memoria RAM
    U2 : rw_96x8_sync
        port map (
            address  => address,
            data_in  => data_in,
            writen   => writen,
            clock    => clock,
            data_out => rw_data_out
        );
    
    -- Instanciación de los puertos de salida
    U3 : output_ports
        port map (
            address  => address,
            data_in  => data_in,
            writen   => writen,
            clock    => clock,
            reset    => reset,
            port_out_00 => port_out_00,
            port_out_01 => port_out_01
   
        );
    
    -- Instanciación de los decodificadores de 7 segmentos
    -- Display 0: Nibble bajo de address
    DECODER_0 : systemd
        port map (
            A  => address_low,
            D0 => display_0
        );
    
    -- Display 1: Nibble alto de address
    DECODER_1 : systemd
        port map (
            A  => address_high,
            D0 => display_1
        );
    
    -- Display 2: Nibble bajo de data_out
    DECODER_2 : systemd
        port map (
            A  => data_low,
            D0 => display_2
        );
    
    -- Display 3: Nibble alto de data_out
    DECODER_3 : systemd
        port map (
            A  => data_high,
            D0 => display_3
        );
    
    -- Multiplexor para el bus data_out
    MUX1 : process(address, rom_data_out, rw_data_out, port_in_00, port_in_01)
    begin
        if ((to_integer(unsigned(address)) >= 0) and 
            (to_integer(unsigned(address)) <= 127)) then
            data_out <= rom_data_out;
            
        elsif ((to_integer(unsigned(address)) >= 128) and 
               (to_integer(unsigned(address)) <= 223)) then
            data_out <= rw_data_out;
            
        elsif (address = x"F0") then data_out <= port_in_00;  -- Palabra A (switches)
        elsif (address = x"F1") then data_out <= port_in_01;  -- Palabra B (dip_switches)
        elsif (address = x"F2") then data_out <= x"00";
        elsif (address = x"F3") then data_out <= x"00";
        elsif (address = x"F4") then data_out <= x"00";
        elsif (address = x"F5") then data_out <= x"00";
        elsif (address = x"F6") then data_out <= x"00";
        elsif (address = x"F7") then data_out <= x"00";
        elsif (address = x"F8") then data_out <= x"00";
        elsif (address = x"F9") then data_out <= x"00";
        elsif (address = x"FA") then data_out <= x"00";
        elsif (address = x"FB") then data_out <= x"00";
        elsif (address = x"FC") then data_out <= x"00";
        elsif (address = x"FD") then data_out <= x"00";
        elsif (address = x"FE") then data_out <= x"00";
        elsif (address = x"FF") then data_out <= x"00";
        
        else data_out <= x"00";
        end if;
    end process;
    
end structural;