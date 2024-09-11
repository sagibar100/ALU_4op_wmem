Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity tb_ALU is
    Generic (
        ADDR_WIDTH : integer := 2;
        DATA_WIDTH : integer := 8
    );
end entity tb_ALU;

architecture arc_tb_ALU of tb_ALU is
    -- constant DATA_WIDTH : integer := 8;
    -- constant ADDR_WIDTH : integer := 2;
    constant DATA       : std_logic_vector(DATA_WIDTH -1 downto 0) := (others => '0');
    constant ADDRESS    : std_logic_vector(ADDR_WIDTH -1 downto 0) := (others => '0');
    constant TEST       : std_logic_vector(0 to 12) := (others => '0');
    
    type std_ctrl_array is array (natural range<>) of std_logic_vector(DATA'range);
    --array type with elements of std_logic_vector
    type int_operands_array is array (natural range<>) of integer range 2**(DATA_WIDTH-1) -1 downto -1 * 2**(DATA_WIDTH-1);
    -- range is limited to integers represented by 8 bits in 2's complement
    signal A  : int_operands_array(TEST'range);
    signal B  : int_operands_array(TEST'range);
    signal op : std_ctrl_array(TEST'range);
    
    constant zero  : std_logic_vector(DATA'range) := "00000000";
    constant sum   : std_logic_vector(DATA'range) := "00000001";
    constant sub   : std_logic_vector(DATA'range) := "00000010";
    constant mult  : std_logic_vector(DATA'range) := "00000011";
    constant div   : std_logic_vector(DATA'range) := "00000100";
    constant junk0 : std_logic_vector(DATA'range) := "00000101";
    constant junk1 : std_logic_vector(DATA'range) := "00000110";
    constant junk2 : std_logic_vector(DATA'range) := "00000111";
    constant junkA : std_logic_vector(DATA'range) := "11111111";
    
    constant dead : unsigned((DATA_WIDTH*2)-1 downto 0) := x"DEAD";

    signal clk,rst,rd_wr : std_logic := '1';
    signal addr: std_logic_vector(ADDRESS'range) := "00";
    signal en: std_logic := '0';
    signal wr_data: std_logic_vector(DATA'range) := (others => '0');
    signal rd_data:std_logic_vector(DATA'range);    
    signal res_out: STD_LOGIC_VECTOR((DATA_WIDTH*2)-1 downto 0);
    signal prev_res: STD_LOGIC_VECTOR((DATA_WIDTH*2)-1 downto 0); 

begin

    
    A <= (1,2,6,8,6,8,9,0,10,-20,7,8,9);
    B <= (1,2,0,4,6,20,3,5,-10,2,5,4,-1);
    op<=(zero,sum,div,mult,div,sub,div,mult,div,mult,junk0,sum,junk1);

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
        
        test_loop: for i in TEST'range loop
            prev_res <= res_out;
            addr <= "11"; -- Address of execute
            wr_data <= "00000000"; -- Deassert execute
            wait until rising_edge(clk);
             
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
            wr_data <= "00000001"; -- Execute
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            
            if(op(i) = zero) then
                assert res_out = std_logic_vector(to_signed(0, DATA_WIDTH*2))
                    report "Zero operation failed!" severity warning;
            elsif(op(i) = sum) then
                assert res_out = std_logic_vector(to_signed(A(i) + B(i), DATA_WIDTH*2))
                    report "Sum operation failed!" severity warning;
            elsif(op(i) = sub) then
                assert res_out = std_logic_vector(to_signed(A(i) - B(i), DATA_WIDTH*2))
                    report "Sub operation failed!" severity warning;
            elsif(op(i) = mult) then
                assert res_out = std_logic_vector(to_signed(A(i) * B(i), DATA_WIDTH*2))
                    report "Mult operation failed!" severity warning;
            elsif(op(i) = div) then
                if(B(i) = 0) then
                    assert res_out = std_logic_vector(dead)
                        report "Div operation failed!" severity warning;
                else
                    assert res_out = std_logic_vector(to_signed(A(i) / B(i), DATA_WIDTH*2))
                        report "Div operation failed!" severity warning;
                end if;
            else
                assert res_out = prev_res
                        report "OTHERS operation failed!" severity warning;
            end if;

        end loop test_loop;

        report "All tests passed!" severity note;


        wait; -- wait FOREVER!
    end process stim;







end architecture arc_tb_ALU;
