


test: tests/sha_256_Tb.sv src/sha_256.sv src/compute_chunk.sv src/compression.sv src/utilities.sv
	iverilog -o build/sha-256 -g2012 -v \
	src/utilities.sv tests/sha_256_Tb.sv src/sha_256.sv \
	src/compute_chunk.sv src/compression.sv
	vvp build/sha-256
