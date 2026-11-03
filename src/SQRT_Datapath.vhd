library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sqrt_package.all;

entity SQRT_Datapath is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        ld_a         : in  std_logic;
        ld_init      : in  std_logic;
        ld_calc      : in  std_logic;
        ld_norm_up   : in  std_logic;
        ld_norm_down : in  std_logic;
        ld_correct   : in  std_logic;
        inc_i        : in  std_logic;
        a_in         : in  signed(15 downto 0);
        a_lt_0_25    : out std_logic;
        a_ge_1_0     : out std_logic;
        i_done       : out std_logic;
        is_zero      : out std_logic;
        is_neg       : out std_logic;
        sqrt_out     : out signed(15 downto 0)
    );
end entity;

architecture rtl of SQRT_Datapath is

    signal slv_a    : std_logic_vector(15 downto 0);
    signal slv_x    : std_logic_vector(15 downto 0);
    signal slv_y    : std_logic_vector(15 downto 0);
    signal slv_sqrt : std_logic_vector(15 downto 0);

    signal reg_a    : signed(15 downto 0);
    signal reg_x    : signed(15 downto 0);
    signal reg_y    : signed(15 downto 0);
    signal reg_sqrt : signed(15 downto 0);


    signal reg_scale : integer range -15 to 15 := 0;
    signal reg_i     : integer range  1 to 20  := 1;
    signal reg_rep   : std_logic               := '0';


    signal en_a    : std_logic;
    signal en_x    : std_logic;
    signal en_y    : std_logic;
    signal en_sqrt : std_logic;


    signal next_a    : signed(15 downto 0);
    signal next_x    : signed(15 downto 0);
    signal next_y    : signed(15 downto 0);
    signal next_sqrt : signed(15 downto 0);

    signal next_x_calc : signed(15 downto 0);
    signal next_y_calc : signed(15 downto 0);

    signal mx_comb : signed(31 downto 0);
    signal cx_comb : signed(15 downto 0);

begin

    reg_a    <= signed(slv_a);
    reg_x    <= signed(slv_x);
    reg_y    <= signed(slv_y);
    reg_sqrt <= signed(slv_sqrt);

    sqrt_out  <= reg_sqrt;
    is_zero   <= '1' when a_in  =  0       else '0';
    is_neg    <= '1' when a_in  <  0       else '0';
    a_lt_0_25 <= '1' when reg_a <  FP_0_25 else '0';
    a_ge_1_0  <= '1' when reg_a >= FP_1_0  else '0';
    i_done    <= '1' when reg_i >  N_ITER   else '0';

    en_a   <= ld_a or ld_norm_up or ld_norm_down;

    next_a <= a_in                  when ld_a        = '1' else
              shift_left (reg_a, 2) when ld_norm_up  = '1' else
              shift_right(reg_a, 2);                    

    REG_A_INST : entity work.regn
        generic map (DATA_WIDTH => 16)
        port map (
            clk => clk,
            rst => rst,
            en  => en_a,
            d   => std_logic_vector(next_a),
            q   => slv_a
        );

    next_x_calc <= reg_x + shift_right(reg_y, reg_i) when reg_y < 0 else
                   reg_x - shift_right(reg_y, reg_i);

    en_x   <= ld_init or ld_calc;
    next_x <= reg_a + FP_0_25 when ld_init = '1' else next_x_calc;

    REG_X_INST : entity work.regn
        generic map (DATA_WIDTH => 16)
        port map (
            clk => clk,
            rst => rst,
            en  => en_x,
            d   => std_logic_vector(next_x),
            q   => slv_x
        );

    next_y_calc <= reg_y + shift_right(reg_x, reg_i) when reg_y < 0 else
                   reg_y - shift_right(reg_x, reg_i);

    en_y   <= ld_init or ld_calc;
    next_y <= reg_a - FP_0_25 when ld_init = '1' else next_y_calc;

    REG_Y_INST : entity work.regn
        generic map (DATA_WIDTH => 16)
        port map (
            clk => clk,
            rst => rst,
            en  => en_y,
            d   => std_logic_vector(next_y),
            q   => slv_y
        );

    mx_comb <= reg_x * FP_INV_K;
    cx_comb <= mx_comb(29 downto 14);      

    en_sqrt   <= ld_a or ld_correct;
    next_sqrt <= (others => '0')                  when ld_a      = '1'  else
                 shift_left (cx_comb,  reg_scale) when reg_scale  > 0   else
                 shift_right(cx_comb, -reg_scale) when reg_scale  < 0   else
                 cx_comb;                     

    REG_SQRT_INST : entity work.regn
        generic map (DATA_WIDTH => 16)
        port map (
            clk => clk,
            rst => rst,
            en  => en_sqrt,
            d   => std_logic_vector(next_sqrt),
            q   => slv_sqrt
        );

    process(clk, rst)
    begin
        if rst = '1' then
            reg_scale <= 0;
            reg_i     <= 1;
            reg_rep   <= '0';
        elsif rising_edge(clk) then

            if    ld_a        = '1' then reg_scale <= 0;
            elsif ld_norm_up  = '1' then reg_scale <= reg_scale - 1;
            elsif ld_norm_down = '1' then reg_scale <= reg_scale + 1;
            end if;

            if ld_init = '1' then
                reg_i   <= 1;
                reg_rep <= '0';
            elsif inc_i = '1' then
                if reg_i = 4 and reg_rep = '0' then
                    reg_rep <= '1';        
                else
                    reg_i   <= reg_i + 1;
                    reg_rep <= '0';
                end if;
            end if;

        end if;
    end process;

end architecture;