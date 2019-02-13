#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"

vluint64_t main_time = 0;  // Current simulation time (64-bit unsigned)
double sc_time_stamp() {
    return main_time;      // Called by $time in Verilog
                           // Note does conversion to real, to match SystemC
}

int main(int argc, char** argv, char** env) {

  Vtop* top = new Vtop;
  Verilated::commandArgs(argc, argv);
  
  //trace
  VerilatedVcdC* tfp = NULL;
  const char* flag = Verilated::commandArgsPlusMatch("trace");
  if (flag && 0==strcmp(flag, "+trace")) {
    Verilated::traceEverOn(true);
    VL_PRINTF("Enabling waves into logs/vlt_dump.vcd...\n");
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    Verilated::mkdir("logs");
    tfp->open("logs/vlt_dump.vcd");
  }
  
    top->rst_n = 0;
    top->clk = 0;

    int done = 0;
    
    while (!(done|Verilated::gotFinish())) {
        main_time++;

        if ((main_time % 10) == 3) {
            top->clk = 1;
        }
        if ((main_time % 10) == 8) {
            top->clk = 0;
        }
        if (main_time > 1 && main_time < 10) {
            top->rst_n = 0;	    
	    top->raddr = 0;
	    top->waddr = 0;
	    top->wen   = 0xF;
	    top->din   = 0;	    
	} else {
            top->rst_n = !0;
        }
	
        if ((main_time % 10) == 3) {
	  top->raddr += 1;
	  if (top->raddr == 255)
	    done = 1;
	}	
	
        top->eval();

        if (tfp) tfp->dump (main_time);
	
	// Read outputs
        VL_PRINTF ("[%" VL_PRI64 "d] clk=%x rstn=%x\n",
                   main_time, top->clk, top->rst_n);
	
    }

    // Final model cleanup
    top->final();

    if (tfp) { tfp->close(); tfp = NULL; }

    //  Coverage analysis (since test passed)
#if VM_COVERAGE
    Verilated::mkdir("logs");
    VerilatedCov::write("logs/coverage.dat");
#endif

    // Destroy model
    delete top; top = NULL;

    exit(0);
}
