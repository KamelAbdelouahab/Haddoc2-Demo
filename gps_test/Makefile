-include Makefile.local

PROCNAME = cnn
TBNAME = $(PROCNAME)_tb
OUTDIR = simbuild
GHDL = ghdl
GHDLFLAGS =-fexplicit --mb-comments --ieee=synopsys

QUARTUS_LIB = altera/13.1/quartus/eda/sim_lib/
USEALTERA_MF = 0

ifeq ($(USEALTERA_MF),1)
  SRC += altera_mf_components.vhd
  SRC += altera_mf.vhd
  GHDLFLAGS += --work=altera_mf
  vpath %.vhd ${QUARTUS_LIB}
endif

SRC += bitwidths.vhd
SRC += cnn_types.vhd
SRC += params.vhd
SRC += to_signedPixel.vhd
SRC += display_mux.vhd
SRC += taps.vhd
SRC += neighExtractor.vhd
SRC += convElement.vhd
SRC += sumElement_single.vhd
SRC += sumElement.vhd
SRC += poolH.vhd
SRC += poolV.vhd
SRC += maxPool.vhd
SRC += firstLayer.vhd
SRC += convLayer.vhd
SRC += poolLayer.vhd
SRC += cnn_process.vhd
SRC += cnn_slave.vhd
SRC += cnn.vhd
SRC += cnn_tb.vhd

vpath %.vhd ../test
vpath %.vhd ../haddocLib
vpath %.vhd .
vpath %.vhd ${QUARTUS_LIB}

OBJECTS := $(addprefix $(OUTDIR)/, $(notdir $(SRC:.vhd=.o)))

all: run

Makefile: cnn.proc
	gpproc generatetb

$(OUTDIR)/%.stim: %.png
	@test -d $(OUTDIR) || mkdir -p $(OUTDIR)
	gpproc convert -i $< -o $@

$(OUTDIR)/%.o: %.vhd
	@test -d $(OUTDIR) || mkdir -p $(OUTDIR)
	$(GHDL) -a --workdir=$(OUTDIR) $(GHDLFLAGS) $<

$(OUTDIR)/$(TBNAME): $(OBJECTS)
	cd $(OUTDIR) && $(GHDL) -e $(GHDLFLAGS) $(TBNAME)

#GHDLRUNFLAGS += --stop-time=500ns # uncomment to limit simulation time
run : $(OUTDIR)/$(TBNAME) $(OUTDIR)/in.stim 
	cd $(OUTDIR) && $(GHDL) -r $(TBNAME) $(GHDLRUNFLAGS) --vcd=$(PROCNAME).vcd

view: run
	gtkwave $(OUTDIR)/$(PROCNAME).vcd

.PHONY: clean
clean:
	rm -rf $(OUTDIR)

