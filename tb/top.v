localparam depth=256;
localparam memfile = "firmware/default.hex";

module top
  (
   // Declare some signals so we can see how I/O works
   input 		     clk,
   input 		     rst_n,

   input [31:0] 	     din,
   input [$clog2(depth)-1:0] waddr,
   input [3:0] 		     wen,
   input [$clog2(depth)-1:0] raddr, 

   output [31:0] 	     dout
   );

   // Connect up the outputs, using some trivial logic
   wire [31:0] 		     _din   = ~rst_n ? '0 : din;
   wire [3:0] 		     _wen   = ~rst_n ? '0 : wen;
   wire [$clog2(depth)-1:0]  _waddr = ~rst_n ? '0 : waddr;
   wire [$clog2(depth)-1:0]  _raddr = ~rst_n ? '0 : raddr;   

   // And an example sub module. The submodule will print stuff.
   ram 
     #(.depth   (depth),
       .memfile (memfile))
   ram (/*AUTOINST*/
        // Inputs
        .clk   (clk),
	.din   (_din),
	.wen   (_wen),
	.waddr (_waddr),
	.raddr (_raddr),
	.dout  (dout));
   
   // Print some stuff as an example
   initial begin
      $display("[%0t] Model running...\n", $time);
   end

endmodule
