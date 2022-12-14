
module sha_256_Tb;

    localparam length = 8;

    logic      clk;
    logic      in_valid;
    logic [length-1:0] word;
    logic [255:0]      hash;
    logic	       out_valid;

    
    sha_256 #(
	      .LENGTH(length)
	      ) dut (
		     .clk(clk),
		     .in_valid(in_valid),
		     .word(word),
		     .hash(hash),
		     .out_valid(out_valid)
		     );

    
    // clock
    always #10 clk = ~clk;

    initial begin
	
	$dumpfile("build/sha_256_Tb.vcd");
	$dumpvars(0, sha_256_Tb);


	clk  = 1'b0;
	
	word = {8'h61};
	//word = {8'h61};

	in_valid = 1'b1;
    
    end    


    always @(posedge clk) begin
	if (out_valid) begin
	    $displayh(hash);
	    $finish;
	end
    end
    
endmodule
