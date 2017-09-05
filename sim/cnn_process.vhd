-- This file has been automatically generated from file caffe/deploy/test.prototxt, on 2017-08-28 at 15:48:10

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.bitwidths.all;
use work.cnn_types.all;
use work.params.all;

entity cnn_process is
    generic(
        PIXEL_SIZE: integer := PIXEL_CONST;
        IMAGE_WIDTH: integer := CONV1_IMAGE_WIDTH
    );
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        enable: in std_logic;
        select_i: in std_logic_vector(31 downto 0);
        in_data: in std_logic_vector(PIXEL_SIZE-1 downto 0);
        in_dv: in std_logic;
        in_fv: in std_logic;
        out_data: out std_logic_vector(PIXEL_SIZE-1 downto 0);
        out_dv: out std_logic;
        out_fv: out std_logic
    );
end entity;

architecture STRUCTURAL of cnn_process is

  -- COMPONENTS

  component to_signedPixel is
    generic(
        PIXEL_SIZE: integer
    );
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        enable: in std_logic;
        in_data: in std_logic_vector(0 to PIXEL_SIZE-1);
        in_dv: in std_logic;
        in_fv: in std_logic;
        out_data: out std_logic_vector(0 to PIXEL_SIZE-1);
        out_dv: out std_logic;
        out_fv: out std_logic
    );
  end component;

  component firstLayer is
    generic(
        PIXEL_SIZE: integer;
        IMAGE_WIDTH: integer;
        KERNEL_SIZE: integer;
        NB_OUT_FLOWS: integer;
        KERNEL_VALUE: pixel_matrix;
        KERNEL_NORM: pixel_array;
        BIAS_VALUE: pixel_array
    );
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        enable: in std_logic;
        in_data: in std_logic_vector(0 to PIXEL_SIZE-1);
        in_dv: in std_logic;
        in_fv: in std_logic;
        out_data: out pixel_array(0 to NB_OUT_FLOWS-1);
        out_dv: out std_logic_vector(0 to NB_OUT_FLOWS-1);
        out_fv: out std_logic_vector(0 to NB_OUT_FLOWS-1)
    );
  end component;

  component convLayer is
    generic(
        PIXEL_SIZE: integer;
        IMAGE_WIDTH: integer;
        KERNEL_SIZE: integer;
        NB_IN_FLOWS: integer;
        NB_OUT_FLOWS: integer;
        KERNEL_VALUE: pixel_matrix;
        KERNEL_NORM: pixel_array;
        BIAS_VALUE: pixel_array
    );
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        enable: in std_logic;
        in_data: in pixel_array(0 to NB_IN_FLOWS-1);
        in_dv: in std_logic_vector(0 to NB_IN_FLOWS-1);
        in_fv: in std_logic_vector(0 to NB_IN_FLOWS-1);
        out_data: out pixel_array(0 to NB_OUT_FLOWS-1);
        out_dv: out std_logic_vector(0 to NB_OUT_FLOWS-1);
        out_fv: out std_logic_vector(0 to NB_OUT_FLOWS-1)
    );
  end component;

  component poolLayer is
    generic(
        PIXEL_SIZE: integer;
        IMAGE_WIDTH: integer;
        KERNEL_SIZE: integer;
        NB_OUT_FLOWS: integer
    );
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        enable: in std_logic;
        in_data: in pixel_array(0 to NB_OUT_FLOWS-1);
        in_dv: in std_logic_vector(0 to NB_OUT_FLOWS-1);
        in_fv: in std_logic_vector(0 to NB_OUT_FLOWS-1);
        out_data: out pixel_array(0 to NB_OUT_FLOWS-1);
        out_dv: out std_logic_vector(0 to NB_OUT_FLOWS-1);
        out_fv: out std_logic_vector(0 to NB_OUT_FLOWS-1)
    );
  end component;

  component fcLayer is
    generic(
        PIXEL_SIZE: integer;
        IMAGE_WIDTH: integer;
        FEATURE_SIZE: integer;
        NB_IN_FLOWS: integer;
        NB_OUT_FLOWS: integer;
        KERNEL_VALUE: pixel_matrix;
        KERNEL_NORM: pixel_array;
        BIAS_VALUE: pixel_array
    );
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        enable: in std_logic;
        in_data: in pixel_array(0 to NB_IN_FLOWS-1);
        in_dv: in std_logic_vector(0 to NB_OUT_FLOWS-1);
        in_fv: in std_logic_vector(0 to NB_OUT_FLOWS-1);
        out_data: out pixel_array(0 to NB_OUT_FLOWS-1);
        out_dv: out std_logic_vector(0 to NB_OUT_FLOWS-1);
        out_fv: out std_logic_vector(0 to NB_OUT_FLOWS-1)
    );
  end component;

  component display_mux is
    generic(
        PIXEL_SIZE: integer;
        NB_IN_FLOWS: integer
    );
    port(
        in_data: in pixel_array(0 to NB_IN_FLOWS-1);
        in_dv: in std_logic_vector(0 to NB_IN_FLOWS-1);
        in_fv: in std_logic_vector(0 to NB_IN_FLOWS-1);
        sel: in std_logic_vector(31 downto 0);
        out_data: out std_logic_vector(PIXEL_SIZE-1 downto 0);
        out_dv: out std_logic;
        out_fv: out std_logic
    );
  end component;

  -- SIGNALS

  signal signed_data : std_logic_vector(0 to PIXEL_SIZE-1);
  signal signed_dv : std_logic;
  signal signed_fv : std_logic;

  signal conv1_data : pixel_array(0 to CONV1_OUT_SIZE-1);
  signal conv1_dv : std_logic_vector(0 to CONV1_OUT_SIZE-1);
  signal conv1_fv : std_logic_vector(0 to CONV1_OUT_SIZE-1);


  -- STRUCTURAL DESCRIPTION

begin
  spixel: to_signedPixel
    generic map(
      PIXEL_SIZE => PIXEL_SIZE
    )
    port map(
      clk => clk,
      reset_n => reset_n,
      enable => enable,
      in_data => in_data,
      in_dv => in_dv,
      in_fv => in_fv,
      out_data => signed_data,
      out_dv => signed_dv,
      out_fv => signed_fv
    );

  conv1: firstLayer
    generic map(
      PIXEL_SIZE => PIXEL_SIZE,
      IMAGE_WIDTH => CONV1_IMAGE_WIDTH,
      KERNEL_SIZE => CONV1_KERNEL_SIZE,
      NB_OUT_FLOWS => CONV1_OUT_SIZE,
      KERNEL_VALUE => CONV1_KERNEL_VALUE,
      KERNEL_NORM => CONV1_KERNEL_NORM,
      BIAS_VALUE => CONV1_BIAS_VALUE
    )
    port map(
      clk => clk,
      reset_n => reset_n,
      enable => enable,
      in_data => signed_data,
      in_dv => signed_dv,
      in_fv => signed_fv,
      out_data => conv1_data,
      out_dv => conv1_dv,
      out_fv => conv1_fv
    );

  display_mux_inst: display_mux
    generic map(
      PIXEL_SIZE => PIXEL_SIZE,
      NB_IN_FLOWS => CONV1_OUT_SIZE
    )
    port map(
      in_data => conv1_data,
      in_dv => conv1_dv,
      in_fv => conv1_fv,
      sel => select_i,
      out_data => out_data,
      out_dv => out_dv,
      out_fv => out_fv
    );

end architecture;
