Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity top_ALU is
    Generic (
        ADDR_WIDTH : integer := 2;
        DATA_WIDTH : integer := 8
    );
    Port (
        clk     : in    STD_LOGIC;
        rst     : in    STD_LOGIC;
        addr    : in    STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
        en      : in    STD_LOGIC;
        rd_wr   : in    STD_LOGIC;
        wr_data : in    STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        rd_data : out   STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        res_out : out   STD_LOGIC_VECTOR((DATA_WIDTH*2)-1 downto 0)
        -- res_out width in the instruction video is 15:0,
        -- but to better make use of the versitility offered by
        -- using generics, we will make the output width based
        -- on the generic value as well.
    );
end top_ALU;


architecture arc_top_ALU of top_ALU is

    type std_vector_array is array (natural range<>) of std_logic_vector(wr_data'range);

    signal REG_BANK : std_vector_array(3 downto 0);
    signal wr_en  : std_logic_vector((2**ADDR_WIDTH)-1 downto 0);

    alias A_DATA    : std_logic_vector(wr_data'range) is REG_BANK(0);
    alias B_DATA    : std_logic_vector(wr_data'range) is REG_BANK(1);
    alias OPER      : std_logic_vector(wr_data'range) is REG_BANK(2);
    alias EXECUTE   : std_logic_vector(wr_data'range) is REG_BANK(3);

begin

    ALU_instance: entity work.ALU
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            A       => A_DATA,
            B       => B_DATA,
            EXECUTE => EXECUTE,
            rst     => rst,
            clk     => clk,
            res     => res_out
        );

        decoder: process(addr) is
        begin
            wr_en <= (others => '0');
            wr_en(to_integer(unsigned(addr))) <= en and (not rd_wr);
        end process decoder;

        synch: process(clk, rst) is
        begin
            if (rst = '1') then
                REG_BANK <= (others => (others => '0'));
                rd_data <= (others => '0');
            elsif (rising_edge(clk))
                
                for i in wr_en'range loop
                    if wr_en(i) = '1' then
                        REG_BANK(i) <= wr_data;
                    end if;
                end loop;
                -- Need to make sure this passes synthesis
                if (en = '1' and rd_wr = '1') then
                    rd_data <= REG_BANK(to_integer(unsigned(addr)));
                end if;

            end if;
        end process synch;

end architecture arc_top_ALU;