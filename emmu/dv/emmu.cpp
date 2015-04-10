#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vdv_emmu__Syms.h"

int main(int argc, char **argv, char **env)
{
  Verilated::commandArgs(argc, argv);

  uint64_t t;

  //VCD stuff
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  //char *vcdFileName;
  Vdv_emmu* top = new Vdv_emmu;
  top->trace(tfp, 99);
  tfp->open("test.vcd"/*vcdFileName*/);
  
  //Init values
  top->clk   = 0;
  top->reset = 1;
  top->go    = 0;
  
  while(t<100000) {
    if (t==100) top->reset = 0;
    if (t==10000) top->go = 1;
    top->eval();
    top->clk = !top->clk;
    tfp->dump((vluint64_t)t);
    t++;
  }
  tfp->close();
}
