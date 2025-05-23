#include <iostream>
#include <unordered_map>
#include <functional>
#include <cstdint>
#include "VysyxSoCFull.h"
#include "verilated_vcd_c.h"
#include "VysyxSoCFull___024root.h"
#include <getopt.h>
#include "mem.h"
#include "sdb.h"
#include "cpu.h"
#include "device.h"
#include "ftrace.h"
VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;
VysyxSoCFull* top = NULL;
std::unordered_map<std::string, std::function<int(char*)>> sdb_map;
CPU_status cpu;
#ifdef CONFIG_ITRACE
char inst_buf[128] = {};
extern "C" void disassemble(char *str, int size, uint64_t pc, uint8_t *code,
                            int nbyte);
#endif

int inst_num = 0;
int trace_enable = 0;

void cpu_update(){
  for (int i = 0; i < 32; i++) {
    cpu.gpr[i] = (top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__mreg__DOT__rf)[i];
  }
  cpu.pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
}

void sim_init()
{
    top = new VysyxSoCFull;
    Verilated::traceEverOn(true);
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    
    top->trace(tfp, 0);
    tfp->open("dump.vcd");
}

void sim_close()
{
    top->final();
    delete top;
    delete tfp;
    delete contextp;
}

void step_and_dump_wave() {
  top->eval();
if(trace_enable){
    contextp->timeInc(1);
    tfp->dump(contextp->time());
  }
}
void single_cycle() {
  top->clock = 1; step_and_dump_wave();
  top->clock = 0; step_and_dump_wave();
}

void reset(int n) {
  top->reset = 1;
  while (n -- > 0) single_cycle();
  top->reset = 0;
}

bool mem_en = false;
bool mem_wen = false;
uint32_t pc;
uint32_t inst;
int exec_once(){
  
  //top->inst = inst;
  if(trace_enable != 1 && pc >= 0x80000000)
    trace_enable = 1;
  inst_num++; 
  mem_en = true;
  mem_wen = true;
  top->clock = 1; step_and_dump_wave();
  mem_en = false;
  mem_wen = false;
  pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;              
  inst = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst;
  top->clock = 0; step_and_dump_wave();
   
  //mem_en = false;
  #ifdef CONFIG_DEVICE
  device_updata();
  #endif
#ifdef CONFIG_ITRACE
  if(top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__lsu_finish){
    disassemble(inst_buf, 128, (uint64_t)pc, (uint8_t *)(&inst), 4);
    //printf("%08x\n", inst);
    printf("0x%x\t0x%08x\t%s\t\n", top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc, inst, inst_buf);
  }
  
#endif
  //cpu_display();
#ifdef CONFIG_FTRACE
  if(top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__lsu_finish)
    ftrace(inst, pc, top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__exu_upc);
#endif
#ifdef CONFIG_DIFFTEST
  //printf("result=0x%x\n", top->result);
  cpu_update();
  extern int difftest_step();
  extern bool npc_is_ref_skip_next;
  extern bool npc_is_ref_skip;
  npc_is_ref_skip_next = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__is_diff_skip;
  if(top->reset){
    npc_is_ref_skip_next = 1;
    npc_is_ref_skip = 1;
  }
  if(top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__lsu_finish&& (difftest_step()==-1)) return -1;
#endif
  int is_exit;
  if(top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__is_exit){
    if(cpu.gpr[10] == 1)
      return -1;
    else 
      return 1;
  }
  return 0;
}

int cmd_c(char* args) {
  int i;
  while (1) {
    if ((i = exec_once()) != 0)
      return i;
  }
}
int cmd_si(char* args) {
  if(args == nullptr){
    return exec_once();
  }else{
    int j;
    char *num = strtok(args, " ");
    int n = atoi(num);
    for (int i =0; i<n; i++) {
      if((j = exec_once()) != 0)
        return j;
    }
  }
  return 0;
}
int cmd_info(char* args) {
  for (int i = 0; i < 32; i++) {
    printf("x[%d] = 0x%x ", i, (top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__mreg__DOT__rf)[i]);
    //std::cout << std::format("x{} = 0x{:x} ", i,
                             //top->rootp->top__DOT__register__DOT__rf[i]);
  }
  std::cout << '\n';
  return 0;
}
int cmd_q(char* args) { return 1; }
int cmd_x(char* args){
  if(args == nullptr) 
  {
    printf("请输入打印地址\n");
    return 0;
  }
  char* endptr;
  uint32_t addr = strtol(strtok(args, " "), &endptr, 0);
  printf("0x%08x\n", (uint32_t)vmem_read(addr, 4));
  return 0;
}


void sdb_init(){
  sdb_map["si"] = cmd_si;
  sdb_map["c"] = cmd_c;
  sdb_map["info"] = cmd_info;
  sdb_map["q"] = cmd_q;
  sdb_map["x"] = cmd_x;
}
int batch = 0;
int run(){
  char args[32];
  char* cmd;
  char* strend;
  std::string line;
  #ifdef CONFIG_DIFFTEST
  extern bool npc_is_ref_skip;
  npc_is_ref_skip = true;
  #endif
  #ifdef CONFIG_DEVICE
  extern void sdl_clear_event_queue();
  sdl_clear_event_queue();
  #endif
  if(batch == 1){
    int result = cmd_c(NULL);
    if (result == 1)
        return 0;
    else if(result == -1)
        return -1;
  }
  else{
    std::cout << "<< ";
    while (getline(std::cin, line)) {
      strcpy(args, line.c_str());
      strend = args + strlen(args);
      cmd = strtok(args, " ");
      char *sdb_args= cmd + strlen(cmd) + 1;
      if(sdb_args >= strend) sdb_args = nullptr;
      int result = sdb_map[cmd](sdb_args);
      if (result == 1)
        return 0;
      else if(result == -1)
        return -1;
      std::cout << "<< ";
    }
  }
  
}
