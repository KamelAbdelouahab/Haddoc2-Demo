library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library std;
use std.textio.all;

entity cnn_tb is
end cnn_tb;

architecture rtl of cnn_tb is
component cnn
	generic (
		IMAGE_WIDTH   : integer;
		CLK_PROC_FREQ : integer;
		IN_SIZE       : integer;
		OUT_SIZE      : integer
	);
	port (
		clk_proc : in std_logic;
		reset_n  : in std_logic;

		------------------------- in flow -----------------------
		in_data  : in std_logic_vector(IN_SIZE-1 downto 0);
		in_fv    : in std_logic;
		in_dv    : in std_logic;

		------------------------ out flow -----------------------
		out_data : out std_logic_vector(OUT_SIZE-1 downto 0);
		out_fv   : out std_logic;
		out_dv   : out std_logic
	);
end component;


	----------------- clk_proc clock constant ---------------
	constant clk_proc_FREQ   : INTEGER := 1000000;
	constant clk_proc_period : TIME := 1 ns;

	-------------------- in flow constant -------------------
	constant IN_SIZE         : INTEGER := 8;

	-------------------- out flow constant ------------------
	constant OUT_SIZE        : INTEGER := 8;

	------------------ clk_proc clock signal ----------------
	signal clk_proc       : std_logic;

	--------------------- in flow signals -------------------
	signal cnn_in_dv_s    : std_logic;
	signal cnn_in_fv_s    : std_logic;
	signal cnn_in_data_s  : std_logic_vector (IN_SIZE-1 downto 0);

	-------------------- out flow signals -------------------
	signal cnn_out_dv_s   : std_logic;
	signal cnn_out_fv_s   : std_logic;
	signal cnn_out_data_s : std_logic_vector (OUT_SIZE-1 downto 0);

	------------------ reset_n reset signal -----------------
	signal reset_n        : std_logic;

	------------------- test bench specific -----------------
	signal starttb        : std_logic;
	signal endtb          : std_logic;

    file in_data_file : text is in "in.stim";
    file out_data_file : text is out "out.pgm";

begin
	cnn_inst : cnn
    generic map (
		CLK_PROC_FREQ => 10000000,
		IMAGE_WIDTH   => 322,
		IN_SIZE       => 8,
		OUT_SIZE      => 8
	)
    port map (
		clk_proc => clk_proc,
		reset_n  => reset_n,
		in_data  => cnn_in_data_s,
		in_fv    => cnn_in_fv_s,
		in_dv    => cnn_in_dv_s,
		out_data => cnn_out_data_s,
		out_fv   => cnn_out_fv_s,
		out_dv   => cnn_out_dv_s
	);

	clk_proc_gen_process : process
	begin
		clk_proc <= '1';
		wait for clk_proc_period / 2;
		clk_proc <= '0';
		wait for clk_proc_period / 2;
		if(endtb='1') then
                    wait;
		end if;
	end process;

	rst_proc: process
	begin
		reset_n <= '0';
		starttb <= '0';
		wait for clk_proc_period;
		reset_n <= '1';
		wait for clk_proc_period;
		starttb <= '1';
		wait;
	end process;

    -- Stimuli for in flow
    stim_proc: process
		variable in_line : line;
		variable in_pixelFromFile : INTEGER;
		variable in_pixel_ok : BOOLEAN;

	begin
		cnn_in_dv_s <= '0';
		cnn_in_fv_s <= '0';
		cnn_in_data_s <= (others=>'0');

		wait until starttb = '1';
		wait until rising_edge(clk_proc);
		wait until rising_edge(clk_proc);

		cnn_in_dv_s <= '1';
		cnn_in_fv_s <= '1';

		while not endfile(in_data_file) loop
			readline(in_data_file, in_line);
			read(in_line, in_pixelFromFile, in_pixel_ok);
			while in_pixel_ok loop
				cnn_in_data_s <= std_logic_vector(to_unsigned(in_pixelFromFile, IN_SIZE));
				wait until rising_edge(clk_proc);
				read(in_line, in_pixelFromFile, in_pixel_ok);
			end loop;
		end loop;

		cnn_in_dv_s <= '0';
		cnn_in_fv_s <= '0';

		wait;
	end process;

    -- Data save for out flow
    out_process: process
		variable out_line : line;
		variable x : integer := 0;

	begin
		endtb <= '0';
		write(out_line, string'("P2"));
		writeline(out_data_file, out_line);

		write(out_line, string'("320 320"));  -- change this to modify size of output picture
		writeline(out_data_file, out_line);

		write(out_line, string'("255"));
		writeline(out_data_file, out_line);

		wait until cnn_out_fv_s = '1';
		while cnn_out_fv_s='1' loop
			wait until rising_edge(clk_proc);
			if(cnn_out_dv_s='1') then
				write(out_line, to_integer(unsigned(cnn_out_data_s)));
				write(out_line, string'(" "));
				x := x + 1;
				if(x>=320) then
					writeline(out_data_file, out_line);
					x := 0;
				end if;
			end if;
		end loop;
		writeline(out_data_file, out_line);
		endtb <= '1';
		assert false report "end of out" severity note;
		wait;
	end process;

end rtl;
