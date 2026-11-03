library ieee;
use ieee.std_logic_1164.all;

entity SQRT_CU is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        start        : in  std_logic;
        a_lt_0_25    : in  std_logic;
        a_ge_1_0     : in  std_logic;
        i_done       : in  std_logic;
        is_zero      : in  std_logic;
        is_neg       : in  std_logic;
        ld_a         : out std_logic;
        ld_init      : out std_logic;
        ld_calc      : out std_logic;
        ld_norm_up   : out std_logic;
        ld_norm_down : out std_logic;
        ld_correct   : out std_logic;
        inc_i        : out std_logic;
        done         : out std_logic;
        error        : out std_logic
    );
end entity;

architecture rtl of SQRT_CU is
    type state_type is (S_IDLE, S_CHECK, S_NORM, S_UP, S_DOWN, S_INIT, S_CALC, S_INC, S_CORR, S_DONE);
    signal state : state_type := S_IDLE;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            state <= S_IDLE;
        elsif rising_edge(clk) then
            case state is
                when S_IDLE  => if start = '1' then state <= S_CHECK; end if;
                when S_CHECK =>
                    if is_zero = '1' or is_neg = '1' then state <= S_DONE;
                    else state <= S_NORM; end if;
                when S_NORM  =>
                    if    a_lt_0_25 = '1' then state <= S_UP;
                    elsif a_ge_1_0  = '1' then state <= S_DOWN;
                    else                       state <= S_INIT; end if;
                when S_UP    => state <= S_NORM;
                when S_DOWN  => state <= S_NORM;
                when S_INIT  => state <= S_CALC;
                when S_CALC  => state <= S_INC;
                when S_INC   =>
                    if i_done = '1' then state <= S_CORR;
                    else                 state <= S_CALC; end if;
                when S_CORR  => state <= S_DONE;
                when S_DONE  => state <= S_IDLE;
                when others  => state <= S_IDLE;
            end case;
        end if;
    end process;

    ld_a         <= '1' when state = S_IDLE  and start = '1' else '0';
    ld_norm_up   <= '1' when state = S_UP    else '0';
    ld_norm_down <= '1' when state = S_DOWN  else '0';
    ld_init      <= '1' when state = S_INIT  else '0';
    ld_calc      <= '1' when state = S_CALC  else '0';
    inc_i        <= '1' when state = S_INC and i_done = '0' else '0';
    ld_correct   <= '1' when state = S_CORR  else '0';
    done         <= '1' when state = S_DONE  else '0';
    error        <= '1' when state = S_CHECK and is_neg = '1' else '0';
end architecture;