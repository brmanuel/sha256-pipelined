module sha_256 #(
		    parameter  LENGTH = 256,
   		    localparam NCHUNKS = (LENGTH >> 9) + 1,
   		    localparam ROUNDED_LENGTH = 512 * NCHUNKS
		    )(
		      input logic	       clk,
		      input logic	       in_valid,
		      input logic [LENGTH-1:0] word,
		      output logic [255:0]     hash,
		      output logic	       out_valid
		      );
    
    localparam				       h0 = 32'h6a09e667;
    localparam				       h1 = 32'hbb67ae85;
    localparam				       h2 = 32'h3c6ef372;
    localparam				       h3 = 32'ha54ff53a;
    localparam				       h4 = 32'h510e527f;
    localparam				       h5 = 32'h9b05688c;
    localparam				       h6 = 32'h1f83d9ab;
    localparam				       h7 = 32'h5be0cd19;

    // Pre-processing (Padding):
    // begin with the original message of length L bits
    // append a single '1' bit
    // append K '0' bits, where K is the minimum number >= 0 such that (L + 1 + K + 64) is a multiple of 512
    // append L as a 64-bit big-endian integer, making the total post-processed length a multiple of 512 bits
    localparam				       padlength = ROUNDED_LENGTH - LENGTH - 1 - 64;
    logic [NCHUNKS-1:0][511:0]		       padded_word;
    logic [padlength-1:0]		       padding;
    logic [63:0]			       length;
    assign padding = 'b0;
    assign length = LENGTH;
    assign padded_word = {word, 1'b1, padding, length};
    
    
    // process each of the NCHUNKS on separate hardware, allowing pipelining
    logic [NCHUNKS:0][7:0][31:0]	       intermediate_hashes;
    logic [NCHUNKS:0]			       intermediate_hash_valid;
    assign intermediate_hashes[0] = {h0, h1, h2, h3, h4, h5, h6, h7};
    
    always_ff @(posedge clk) begin
        intermediate_hash_valid[0] <= in_valid;
    end
    
    genvar g_chunk;
    generate
        for (g_chunk = 0; g_chunk < NCHUNKS; g_chunk++) begin : chunk
            // computation of chunk i+1 depends on computation of chunk i
            // inner loop iteration i+1 depends on results of iteration i
            // best utilization can be achieved by computing many sha-256 hashes in pipelined manner
            
            
            compute_chunk compute_chunk_inst (
					      .clk(clk),
					      .current_hash(intermediate_hashes[g_chunk]),
					      .in_valid(intermediate_hash_valid[g_chunk]),
					      .chunk(padded_word[g_chunk]),
					      .next_hash(intermediate_hashes[g_chunk+1]),
					      .out_valid(intermediate_hash_valid[g_chunk+1])
					      );
        end
    endgenerate
    
    // Produce the final hash value (big-endian):
    assign out_valid = intermediate_hash_valid[NCHUNKS];
    assign hash = intermediate_hashes[NCHUNKS];
    
endmodule



