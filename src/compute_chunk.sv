
module compute_chunk (
		      input logic	       clk,
		      input logic [7:0][31:0]  current_hash,
		      input logic	       in_valid,
		      input logic [511:0]      chunk,
		      output logic [7:0][31:0] next_hash,
		      output logic	       out_valid
		      );

    import utilities::*;

    logic [64:0][7:0][31:0]		       input_hashes;		       
    logic [64:0][7:0][31:0]		       intermediate_hashes;
    logic [64:0]			       intermediate_hash_valid;
    
    // create a 64-entry message schedule array w[0..63] of 32-bit words
    // copy chunk into first 16 words w[0..15] of the message schedule array
    // Extend the first 16 words into the remaining 48 words w[16..63] of the message schedule array:
    logic [0:63][31:0]			       w;
    logic [16:63][31:0]			       s0;
    logic [16:63][31:0]			       s1;
    
    // Initialize array of round constants:
    logic [0:63][31:0]			       k;
    assign k = {
		32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 
		32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
   		32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 
		32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
   		32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 
		32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
   		32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 
		32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
   		32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 
		32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
   		32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 
		32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
   		32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 
		32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
   		32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 
		32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
		};
    
    
    always_comb begin
	w[0:15] = chunk;
        for (int i = 16; i < 64; i++) begin
            s0[i] = rotate_right(w[i-15], 7) ^ rotate_right(w[i-15], 18) ^ (w[i-15] >> 3);
            s1[i] = rotate_right(w[i-2], 17) ^ rotate_right(w[i-2], 19) ^ (w[i-2] >> 10);
            w[i] = w[i-16] + s0[i] + w[i-7] + s1[i];
	end
    end

    always_ff @(posedge clk) begin
        intermediate_hash_valid[0] <= in_valid;
        intermediate_hashes[0] 	   <= current_hash;
	input_hashes[0] 	   <= current_hash;
	for (int i = 1; i <= 64; i++) begin
	    input_hashes[i] <= input_hashes[i-1];
	end
    end
    
    genvar g_loop;
    generate
        for (g_loop = 0; g_loop < 64; g_loop++) begin
            
            compression comp(
			     .clk(clk),
			     .in_valid(intermediate_hash_valid[g_loop]),
			     .hash_in(intermediate_hashes[g_loop]),
			     .ki(k[g_loop]),
			     .wi(w[g_loop]),
			     .hash_out(intermediate_hashes[g_loop+1]),
			     .out_valid(intermediate_hash_valid[g_loop+1])
			     );
            
        end
    endgenerate
    
    assign out_valid = intermediate_hash_valid[64];
    assign next_hash = input_hashes[64] + intermediate_hashes[64];
    
endmodule
