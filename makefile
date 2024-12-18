TOP_MOD = test_DA_fir
VERILATOR = $(VERILATOR_ROOT)/home/user/verilator/verilator/bin/verilator
SRC = src/ROM.sv src/DA_fir.sv
V_FLAGS = --binary --Wno-fatal --trace --timing --top-module $(TOP_MOD)

all:
	$(VERILATOR) $(V_FLAGS) $(SRC)
	./obj_dir/V$(TOP_MOD)
	
trace:
	make all
	gtkwave test.wcd