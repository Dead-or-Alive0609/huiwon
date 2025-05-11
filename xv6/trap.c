#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"
#include "i8254.h"
//외부선언 추가
extern struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    // 현재 실행 중인 프로세스의 tick 증가
    struct proc *curproc = myproc();
    if (curproc && curproc->state == RUNNING) {
      int q = curproc->priority;
      curproc->ticks[q]++;
    }
    
    acquire(&ptable.lock);
    //// RUNNABLE 상태인 다른 프로세스들의 wait_ticks 증가
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
      if (p->state == RUNNABLE && p != curproc) {
        int q = p->priority;
        if ( q >=0 && q< MLFQ_LEVELS){
          p->wait_ticks[q]++;
        }
        
      }
    }
    //priority boost 조건 확인 (policy == 1일 때만)
    if (mycpu()->sched_policy == 1) {
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p -> state != RUNNABLE) continue;
        int q = p->priority;
        //Q0 -> Q1
        if (q == 0 && p->wait_ticks[0] >= 500) {
          p->priority = 1;
          p->wait_ticks[0] = 0;
          enqueue(&mlfq[1], p);
        }
  
        // Q1 -> Q2
        if (q == 1 && p->wait_ticks[1] >= 160){
          p->priority = 2;  
          p->wait_ticks[1] = 0;
          enqueue(&mlfq[2], p);
        }
        //Q2 ->Q3
        else if (q == 2 && p->wait_ticks[2] >= 80){
          p->priority = 3;
          p->wait_ticks[2] = 0;
          enqueue(&mlfq[3], p);
        }
        
      }
    }
    release(&ptable.lock);

 
  
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 0xB:
    i8254_intr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}