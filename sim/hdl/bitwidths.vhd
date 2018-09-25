library ieee;
  use	ieee.std_logic_1164.all;
  use	ieee.numeric_std.all;
  use  ieee.math_real.all;
package bitwidths is
  constant GENERAL_BITWIDTH	: integer :=8;
  constant SUM_WIDTH     : integer := 3*GENERAL_BITWIDTH;
end bitwidths;
