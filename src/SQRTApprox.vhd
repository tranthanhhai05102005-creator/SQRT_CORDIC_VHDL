library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SQRTApprox is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        start  : in  std_logic;
        a      : in  signed(15 downto 0);
        sqrt_a : out signed(15 downto 0);
        done   : out std_logic;
        error  : out std_logic
    );
end entity;

architecture struct of SQRTApprox is
    signal ld_a, ld_init, ld_calc : std_logic;
    signal ld_norm_up, ld_norm_down, ld_correct, inc_i : std_logic;
    signal a_lt_0_25, a_ge_1_0, i_done, is_zero, is_neg : std_logic;
begin
    DP: entity work.SQRT_Datapath
        port map (
            clk=>clk, rst=>rst,
            ld_a=>ld_a, ld_init=>ld_init, ld_calc=>ld_calc,
            ld_norm_up=>ld_norm_up, ld_norm_down=>ld_norm_down,
            ld_correct=>ld_correct, inc_i=>inc_i,
            a_in=>a,
            a_lt_0_25=>a_lt_0_25, a_ge_1_0=>a_ge_1_0,
            i_done=>i_done, is_zero=>is_zero, is_neg=>is_neg,
            sqrt_out=>sqrt_a
        );

    CU: entity work.SQRT_CU
        port map (
            clk=>clk, rst=>rst, start=>start,
            a_lt_0_25=>a_lt_0_25, a_ge_1_0=>a_ge_1_0,
            i_done=>i_done, is_zero=>is_zero, is_neg=>is_neg,
            ld_a=>ld_a, ld_init=>ld_init, ld_calc=>ld_calc,
            ld_norm_up=>ld_norm_up, ld_norm_down=>ld_norm_down,
            ld_correct=>ld_correct, inc_i=>inc_i,
            done=>done, error=>error
        );
end architecture;