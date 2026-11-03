library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SQRTApprox_tb is
end entity;

architecture bhv of SQRTApprox_tb is
    signal clk    : std_logic := '0';
    signal rst    : std_logic := '0';
    signal start  : std_logic := '0';
    signal a      : signed(15 downto 0) := (others => '0');
    signal sqrt_a : signed(15 downto 0);
    signal done   : std_logic;
    signal error  : std_logic;
    constant CLK_PERIOD : time := 10 ns;
begin
    uut: entity work.SQRTApprox
        port map (clk=>clk, rst=>rst, start=>start,
                  a=>a, sqrt_a=>sqrt_a, done=>done, error=>error);

    clk <= not clk after CLK_PERIOD/2;

    stim_proc: process
    begin
        -- 1. KHOI DONG 
        rst <= '1'; wait for 150 ns;
        wait until rising_edge(clk);
        wait for 1 ns;
        rst <= '0'; 
        wait for 50 ns;

        -- sqrt(0.25): a=4096, expect sqrt_a~8192 (0.5 in Q2.14)
        wait until rising_edge(clk);
        wait for 1 ns;
        a <= to_signed(4096, 16); start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        wait until done = '1'; 
        report "sqrt(0.25): " & integer'image(to_integer(sqrt_a));
        wait for 50 ns;

        -- sqrt(1.0): a=16384, expect sqrt_a~16384 (1.0 in Q2.14)
        wait until rising_edge(clk);
        wait for 1 ns;
        a <= to_signed(16384, 16); start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        wait until done = '1'; 
        report "sqrt(1.0) : " & integer'image(to_integer(sqrt_a));
        wait for 50 ns;

        -- sqrt(1.44): a=23593, expect sqrt_a~19661 (1.2 in Q2.14)
        wait until rising_edge(clk);
        wait for 1 ns;
        a <= to_signed(23593, 16); start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        wait until done = '1'; 
        report "sqrt(1.44): " & integer'image(to_integer(sqrt_a));
        wait for 50 ns;

        -- sqrt(0.5): a=8192, expect sqrt_a~11585 (0.707 in Q2.14)
        wait until rising_edge(clk);
        wait for 1 ns;
        a <= to_signed(8192, 16); start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        wait until done = '1'; 
        report "sqrt(0.5) : " & integer'image(to_integer(sqrt_a));
        wait for 50 ns;

        -- sqrt(0): a=0, expect sqrt_a=0
        wait until rising_edge(clk);
        wait for 1 ns;
        a <= to_signed(0, 16); start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        wait until done = '1'; 
        report "sqrt(0.0) : " & integer'image(to_integer(sqrt_a));

        wait for 100 ns;
        report "=== DONE ==="; 
        wait;
    end process;
end architecture;
