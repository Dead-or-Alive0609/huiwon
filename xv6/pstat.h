#ifndef _PSTAT_H_
#define _PSTAT_H_

#include "param.h"

struct pstat {
  int inuse[NPROC];           // 1 if used
  int pid[NPROC];             // process ID
  int priority[NPROC];        // current priority level (0~3)
  int state[NPROC];           // RUNNING, SLEEPING 등
  int ticks[NPROC][4];        // 실행 시간
  int wait_ticks[NPROC][4];   // 대기 시간
};

#endif 
