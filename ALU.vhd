Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Generic (
        DATA_WIDTH : integer := 8
        );
    Port ( 
        A       : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        B       : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        OPER    : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        EXECUTE : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        rst     : in  STD_LOGIC;
        clk     : in  STD_LOGIC;
        res     : out STD_LOGIC_VECTOR((DATA_WIDTH*2)-1 downto 0)
        );
end ALU;


architecture arc_ALU of ALU is

    signal res_int : integer;

begin

    synch: process(rst, clk) is
    begin
        if (rst = '1') then
            res <= (others => '0');
        elsif (rising_edge(clk)) then
            res <= std_logic_vector(to_signed(res_int, res_value'length));
        end if;
    end process synch;


    calculations: process(rst, EXECUTE) is
        variable a_int, b_int : integer;
    begin
        if (rst = '1') then
            res_int <= 0;
        elsif (EXECUTE(0) = '0') then
            res_int <= res_int;
        else
            
            a_int := to_integer(signed(A));
            b_int := to_integer(signed(B));

            case OPER(2 downto 0) is
                when "000" =>
                    res_int <= 0;
                when "001" =>
                    res_int <= a_int + b_int;
                when "010" =>
                    res_int <= a_int - b_int;
                when "011" =>
                    res_int <= a_int * b_int;
                when "100" =>
                    if (b_int /= 0) then
                        res_int <= a_int / b_int;
                    else
                        res_int <= x"dead";
                    end if;
                when others =>
                    res_int <= res_int;
            end case;
        end if;
    end process calculations;


end architecture arc_ALU;