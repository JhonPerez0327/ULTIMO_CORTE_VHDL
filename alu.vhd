library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        A       : in  std_logic_vector(7 downto 0);
        B       : in  std_logic_vector(7 downto 0);
        ALU_Sel : in  std_logic_vector(2 downto 0);
        Result  : out std_logic_vector(7 downto 0);
        NZVC    : out std_logic_vector(3 downto 0)
    );
end alu;

architecture arch of alu is
begin
    ALU_PROCESS : process (A, B, ALU_Sel)
        variable Sum_uns : unsigned(8 downto 0);
        variable Sub_uns : unsigned(8 downto 0);
    begin
        
        if (ALU_Sel = "000") then  -- SUMA (del PDF)
            -- Sum Calculation
            Sum_uns := unsigned('0' & A) + unsigned('0' & B);
            Result <= std_logic_vector(Sum_uns(7 downto 0));
            
            -- Negative Flag (N)
            NZVC(3) <= Sum_uns(7);
            
            -- Zero Flag (Z)
            if (Sum_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';
            else
                NZVC(2) <= '0';
            end if;
            
            -- Overflow Flag (V)
            if ((A(7)='0' and B(7)='0' and Sum_uns(7)='1') or
                (A(7)='1' and B(7)='1' and Sum_uns(7)='0')) then
                NZVC(1) <= '1';
            else
                NZVC(1) <= '0';
            end if;
            
            -- Carry Flag (C)
            NZVC(0) <= Sum_uns(8);
            
        elsif (ALU_Sel = "001") then  -- RESTA (A - B)
            -- Subtraction Calculation
            Sub_uns := unsigned('0' & A) - unsigned('0' & B);
            Result <= std_logic_vector(Sub_uns(7 downto 0));
            
            -- Negative Flag (N)
            NZVC(3) <= Sub_uns(7);
            
            -- Zero Flag (Z)
            if (Sub_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';
            else
                NZVC(2) <= '0';
            end if;
            
            -- Overflow Flag (V) para resta
            -- Overflow ocurre cuando: POS - NEG = NEG  o  NEG - POS = POS
            if ((A(7)='0' and B(7)='1' and Sub_uns(7)='1') or
                (A(7)='1' and B(7)='0' and Sub_uns(7)='0')) then
                NZVC(1) <= '1';
            else
                NZVC(1) <= '0';
            end if;
            
            -- Carry Flag (C) - en resta indica "borrow"
            NZVC(0) <= Sub_uns(8);
        
        else
            -- Operación no definida
            Result <= x"00";
            NZVC <= "0000";
        end if;
        
    end process;
end arch;