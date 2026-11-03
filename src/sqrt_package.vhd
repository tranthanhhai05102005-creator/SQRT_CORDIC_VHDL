library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sqrt_package is
    constant DATA_WIDTH    : integer := 16;
    constant FRACTION_BITS : integer := 14;
    constant INT_WIDTH     : integer := 16;
    constant FP_0_25  : signed(15 downto 0) := to_signed(4096,  16);
    constant FP_0_5   : signed(15 downto 0) := to_signed(8192,  16);
    constant FP_1_0   : signed(15 downto 0) := to_signed(16384, 16);
    constant FP_INV_K : signed(15 downto 0) := to_signed(19784, 16);
    constant N_ITER   : integer := 15;
end package;