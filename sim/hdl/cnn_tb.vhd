library ieee;
	use	ieee.std_logic_1164.all;
	use	ieee.numeric_std.all;

library std;
    use std.textio.all;

library work;
	use work.cnn_types.all;
    use work.params.all;

entity cnn_tb is
    generic(selection :integer);
end cnn_tb;

architecture tb of cnn_tb is
    --------------------------------------------------------------------------------
    -- C.U.T
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

    --------------------------------------------------------------------------------
    -- SIGNALS & CONSTANTS
    --------------------------------------------------------------------------------
    constant CONST_PIXEL_SIZE    :   integer  := 8;
    constant CONST_IMAGE_WIDTH   :   integer  := 322;
    constant CLK_PROC_PERIOD     :   TIME     := 1 ns;

    signal   sig_clk_proc        :   std_logic;
    signal   sig_reset_n         :   std_logic;
    signal   sig_enable          :   std_logic;
    signal   sig_in_data         :   std_logic_vector (CONST_PIXEL_SIZE - 1 downto 0);
    signal   sig_select_i        :   std_logic_vector (31 downto 0);
    signal   sig_in_dv           :   std_logic;
    signal   sig_in_fv           :   std_logic;
    signal   sig_out_data        :   std_logic_vector (CONST_PIXEL_SIZE - 1 downto 0);
    signal   sig_out_dv          :   std_logic;
    signal   sig_out_fv          :   std_logic;

    file in_data_file   : text is in  "/home/kamel/dev/demo-dloc/img/sample.img";
	file out_data_file  : text is out "/home/kamel/dev/demo-dloc/img/featureSim" & INTEGER'IMAGE(Selection) & ".pgm";
	signal endtb        : std_logic := '0';

    begin
        ---------------------------------------------------------
		--	C.U.T  INSTANTIATION
		---------------------------------------------------------
        cut_inst :  cnn_process
        generic map (
            PIXEL_SIZE    => CONST_PIXEL_SIZE,
            IMAGE_WIDTH   => CONST_IMAGE_WIDTH
        )

        port map (
            clk 	      => sig_clk_proc,
            reset_n 	  => sig_reset_n,
            enable        => sig_enable,
            select_i      => sig_select_i,
            in_data       => sig_in_data,
            in_dv         => sig_in_dv,
            in_fv         => sig_in_fv,
            out_data      => sig_out_data,
            out_dv        => sig_out_dv,
            out_fv        => sig_out_fv
        );

        ---------------------------------------------------------
		--	STIMULUS
		---------------------------------------------------------

        -- Clock
		clk_stim : process
			begin
				sig_clk_proc <= '0';
				wait for clk_proc_period / 2;
				sig_clk_proc <= '1';
				wait for clk_proc_period / 2;
                if(endtb='1') then
                    wait;
                end if;
		    end process;

		--	Initial Reset
		sig_enable 	<=	'1' ;
        -- Output mux
		sig_select_i 	<=	std_logic_vector(to_unsigned(selection,32));

        -- In flow
        stim_proc: process
		    variable in_line          : line;
		    variable in_pixelFromFile : INTEGER;
		    variable in_pixel_ok      : BOOLEAN;

	    begin

           sig_in_dv <= '0';
           sig_in_fv <= '0';
           sig_in_data <= (others=>'0');
           sig_reset_n <= '0';
           wait for clk_proc_period * 2;
           sig_reset_n <= '1';

		    sig_in_dv <= '1';
		    sig_in_fv <= '1';
		    while not endfile(in_data_file) loop
		    	readline(in_data_file, in_line);

		    	read(in_line, in_pixelFromFile, in_pixel_ok);
		    	while in_pixel_ok loop
		    		sig_in_data <= std_logic_vector(to_unsigned(in_pixelFromFile, CONST_PIXEL_SIZE));
		    		wait for clk_proc_period;
		    		read(in_line, in_pixelFromFile, in_pixel_ok);
		    	end loop;

		    end loop;

		    sig_in_dv <= '0';
		    sig_in_fv <= '0';
		    wait;
	end process;

	out_process: process
		variable out_line : line;
		variable x        : integer := 0;

	begin
        endtb <= '0';
		write(out_line, string'("P2"));
		writeline(out_data_file, out_line);

		write(out_line, string'("69 69"));
		writeline(out_data_file, out_line);

		write(out_line, string'("255"));
		writeline(out_data_file, out_line);

        wait until sig_out_fv = '1';
		while sig_out_fv='1' loop
			wait until sig_clk_proc='1';
				if(sig_out_dv='1') then
					write(out_line, to_integer(unsigned(sig_out_data)));
					write(out_line, string'(" "));
					x := x + 1;
					if(x>=79) then
						writeline(out_data_file, out_line);
						x := 0;
					end if;
				end if;
			end loop;
            endtb <= '1';
            assert false report "end of out" severity note;
            wait;

	end process;
    end tb;
