library ieee;
	use	ieee.std_logic_1164.all;
	use	ieee.numeric_std.all;

library work;
    use work.cnn_types.all;
    use work.params.all;

entity cnn is
    generic (
		IMAGE_WIDTH 	: integer	:=	322;
		IN_SIZE 		: integer	:=	8;
		OUT_SIZE 		: integer	:=	8;
		CLK_PROC_FREQ 	: integer 	:=  50000000
	);

    port (
        clk_proc 	: in    std_logic;
        reset_n 	: in    std_logic;
        in_data 	: in    std_logic_vector((IN_SIZE-1) downto 0);
        in_fv 		: in    std_logic;
        in_dv 		: in    std_logic;
        out_data    : out   std_logic_vector (OUT_SIZE - 1 downto 0);
        out_dv      : out   std_logic;
        out_fv      : out   std_logic
        );
end cnn;

architecture rtl of cnn is
    --------------------------------------------------------------------------------
    -- COMPONENTS
    --------------------------------------------------------------------------------
    component cnn_process
    generic(
        PIXEL_SIZE    :   integer ;
        IMAGE_WIDTH   :   integer
    );

    port(
        clk	          : in  std_logic;
        reset_n	      : in  std_logic;
        enable        : in  std_logic;
        in_data       : in  std_logic_vector (PIXEL_SIZE - 1 downto 0);
        select_i      : in  std_logic_vector (31 downto 0);
        in_dv         : in  std_logic;
        in_fv         : in  std_logic;
        out_data      : out std_logic_vector (PIXEL_SIZE - 1 downto 0);
        out_dv        : out std_logic;
        out_fv        : out std_logic
        );
    end component;

    component cnn_slave
    end component;

    --------------------------------------------------------------------------------
    -- SIGNALS & CONSTANTS
    --------------------------------------------------------------------------------
    signal enable_s             : std_logic;
    signal select_s             : std_logic_vector (31 downto 0);


    --------------------------------------------------------------------------------
    -- STRUCTURAL DESCRIPTION
    --------------------------------------------------------------------------------
    begin

        proc_inst : cnn_process
        generic map (
            PIXEL_SIZE    => IN_SIZE,
            IMAGE_WIDTH   => IMAGE_WIDTH
        )

        port map (
            clk 	      => clk_proc,
            reset_n 	  => reset_n,
            enable        => '1',
            in_data       => in_data,
            select_i      => "00000000000000000000000000000001",
            in_dv         => in_dv,
            in_fv         => in_fv,
            out_data      => out_data,
            out_dv        => out_dv,
            out_fv        => out_fv
        );

    end rtl;
