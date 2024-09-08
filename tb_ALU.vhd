Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity tb_ALU is
end tb_ALU;

architecture arc_tb_ALU of ALU is
    constant DATA_WIDTH : integer := 8;
    constant ADDR_WIDTH : integer := 2;
    constant DATA_RANGE : range := DATA_WIDTH-1 downto 0;
    constant ADDR_RANGE : range := ADDR_WIDTH-1 downto 0;
    constant TEST_RANGE : range := 0 to 9;
    
    type std_ctrl_array is array (natural range<>) of std_logic_vector(DATA_RANGE);
    --aaray type with elements of std_logic_vector
    type int_operands_array is array (natural range<>) of integer(2**(DATA_WIDTH-1) -1 downto -1 * 2**(DATA_WIDTH-1));
    -- range is limited to integers represented by 8 bits in 2's complement
    signal A  : int_operands_array(TEST_RANGE);
    signal B  : int_operands_array(TEST_RANGE);
    signal op : std_ctrl_array(TEST_RANGE);
    
    alias zero  : std_logic_vector(DATA_RANGE) is "00000000";
    alias zero  : std_logic_vector(DATA_RANGE) is "00000000";
    alias sum   : std_logic_vector(DATA_RANGE) is "00000001";
    alias sub   : std_logic_vector(DATA_RANGE) is "00000010";
    alias mult  : std_logic_vector(DATA_RANGE) is "00000011";
    alias div   : std_logic_vector(DATA_RANGE) is "00000100";
    alias junk0 : std_logic_vector(DATA_RANGE) is "00000101";
    alias junk1 : std_logic_vector(DATA_RANGE) is "00000110";
    alias junk2 : std_logic_vector(DATA_RANGE) is "00000111";
    alias junkA : std_logic_vector(DATA_RANGE) is "11111111";   

    signal clk,rst,rd_wr : std_logic := '1';
    signal addr: std_logic_vector(ADDR_RANGE) :="00"
    signal enable: std_logic := '0';
    signal wr_data: std_logic_vector(DATA_RANGE) := (other => '0');
    signal rd_data:std_logic_vector(DATA_RANGE);    
    signal res_out: STD_LOGIC_VECTOR((DATA_WIDTH*2)-1 downto 0);
    signal prev_res: STD_LOGIC_VECTOR((DATA_WIDTH*2)-1 downto 0); 

begin

    
    A <= (1,2,6,8,6,8,9,0,10,-20);
    B <= (1,2,0,4,6,20,3,5,-10,2);
    op<=(zero,sum,div,mult,div,sub,div,mult,div,mult);

    DUT: entity work.top_ALU
    Generic map (
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    Port map (
        clk     => clk,        
        rst     => rst,   
        addr    => addr, 
        en      => en,     
        rd_wr   => rd_wr,   
        wr_data => wr_data,
        rd_data => rd_data,
        res_out => res_out
    );
    
    clk <= not clk after 5 ns; -- This where we generate our 100MHz clock signal.


    stim: process is
    begin

        -- Let reset stay active for 3cc.
        rst <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        -- Deassert reset.
        rst     <= '0';
        en      <= '1';
        rd_wr   <= '0';
        wait until rising_edge(clk);
        
        test_loop: for i in TEST_RANGE loop
            addr <= "00"; -- Address of A
            wr_data <= std_logic_vector(to_signed(A(i), DATA_WIDTH)); -- Convert integer to std_logic_vector
            wait until rising_edge(clk);
            addr <= "01"; -- Address of B
            wr_data <= std_logic_vector(to_signed(B(i), DATA_WIDTH)); -- Convert integer to std_logic_vector
            wait until rising_edge(clk);
            addr <= "10"; -- Address of op
            wr_data <= op(i);
            wait until rising_edge(clk);
            addr <= "11"; -- Address of execute
            wr_data <= (0 => '1', others => '0');
            wait until rising_edge(clk);
            wait until rising_edge(clk);

            -- Check the result
            case op(i) is
                when zero =>
                    assert res_out = std_logic_vector(to_signed(0, DATA_WIDTH*2))
                        report "Zero operation failed!" severity warning;
                when sum =>
                    assert res_out = std_logic_vector(to_signed(A(i) + B(i), DATA_WIDTH*2))
                        report "Sum operation failed!" severity warning;
                when sub =>
                    assert res_out = std_logic_vector(to_signed(A(i) - B(i), DATA_WIDTH*2))
                        report "Sub operation failed!" severity warning;
                when mult =>
                    assert res_out = std_logic_vector(to_signed(A(i) * B(i), DATA_WIDTH*2))
                        report "Mult operation failed!" severity warning;
                when div =>
                    if (B(i) = 0) then
                        assert res_out = x"DEAD";
                            report "Div operation failed!" severity warning;
                    else
                        assert res_out = std_logic_vector(to_signed(A(i) / B(i), DATA_WIDTH*2))
                            report "Div operation failed!" severity warning;
                    end if;
                when others =>
                     
            end case;

        end loop test_loop;



        wait; -- wait FOREVER!
    end process stim;







end architecture arc_tb_ALU;
