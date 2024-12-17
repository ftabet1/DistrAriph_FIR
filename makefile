TOP_MOD = test
VERILATOR = /home/user/verilator/verilator/bin/verilator
SRC = src/test.sv
V_FLAGS = --binary --Wno-fatal --trace --timing --top-module $(TOP_MOD)

all:
	$(VERILATOR) $(V_FLAGS) $(SRC)
	./obj_dir/V$(TOP_MOD)
	
trace:
	make all
	gtkwave test.wcd