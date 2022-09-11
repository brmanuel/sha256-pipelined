
package utilities;

    
    function logic [31:0] rotate_right(input logic [31:0] in, int shift_amount);
	return {in,in} >> shift_amount;
    endfunction 

endpackage // utilities
    
