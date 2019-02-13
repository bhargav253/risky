module ram
  /* verilator lint_off VARHIDDEN */
  #(parameter depth=256,
    parameter memfile = "")
   /* verilator lint_on VARHIDDEN */   
   (
   input wire 			  clk,
   input wire [31:0] 		  din,
   input wire [$clog2(depth)-1:0] waddr,
   input wire [3:0] 		  wen,
   input wire [$clog2(depth)-1:0] raddr,
   
   output reg [31:0] 		  dout
   );

   reg [31:0] 			  mem [0:depth-1] /* verilator public */; 

   always @(posedge clk) begin
      if (!wen[0]) mem[waddr][7:0]   <= din[7:0];
      if (!wen[1]) mem[waddr][15:8]  <= din[15:8];
      if (!wen[2]) mem[waddr][23:16] <= din[23:16];
      if (!wen[3]) mem[waddr][31:24] <= din[31:24];
      dout <= mem[raddr];
   end

   generate
      initial
	if(|memfile) begin
	   $display("Preloading %m from %s", memfile);
	   $readmemh(memfile, mem);
	end
   endgenerate

endmodule
