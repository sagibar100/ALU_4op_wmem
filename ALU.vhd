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
    alias Sel_op is OPER(7 downto 0);

begin

    synch: process(rst, clk) is
    begin
        if (rst = '1') then
            res <= (others => '0');
        elsif (rising_edge(clk)) then
            res <= std_logic_vector(to_signed(res_int, res'length));
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

            case Sel_op is
                when "00000000" =>
                    res_int <= 0;
                when "00000001" =>
                    res_int <= a_int + b_int;
                when "00000010" =>
                    res_int <= a_int - b_int;
                when "00000011" =>
                    res_int <= a_int * b_int;
                when "00000100" =>
                    if (b_int /= 0) then
                        res_int <= a_int / b_int;
                    else
                        res_int <= 16#dead#;
                    end if;
                when others =>
                    res_int <= res_int;
            end case;
        end if;
    end process calculations;


end architecture arc_ALU;