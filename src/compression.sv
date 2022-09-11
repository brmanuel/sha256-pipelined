

module compression (
  		    input logic		     clk,
		    input logic		     in_valid,
		    input logic [7:0][31:0]  hash_in,
		    input logic [31:0]	     ki,
		    input logic [31:0]	     wi,
		    output logic [7:0][31:0] hash_out,
		    output logic	     out_valid
		    );

    import utilities::*;

    
    logic [31:0]			     a,b,c,d,e,f,g,h, S1, ch, temp1, S0, maj, temp2;
    
    always_ff @(posedge clk) begin
       	out_valid <= in_valid; 
    end
    
    assign a = hash_in[7];
    assign b = hash_in[6];
    assign c = hash_in[5];
    assign d = hash_in[4];
    assign e = hash_in[3];
    assign f = hash_in[2];
    assign g = hash_in[1];
    assign h = hash_in[0];
    
    always_comb begin
    	S1 = rotate_right(e, 6) ^ rotate_right(e, 11) ^ rotate_right(e, 25);
        ch = (e & f) ^ (~e & g);
        temp1 =  h + S1 + ch + ki + wi;
        S0 =  rotate_right(a, 2) ^ rotate_right(a, 13) ^ rotate_right(a, 22);
        maj =  (a & b) ^ (a & c) ^ (b & c);
        temp2 =  S0 + maj;
    end

    assign hash_out = {
    		       temp1 + temp2, a, b, c, d + temp1, e, f, g
		       };

    
endmodule // compression
