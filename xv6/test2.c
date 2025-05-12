#include "types.h"
#include "user.h"
#include "pstat.h"

#define NUM_PROCS 4
#define ITER 20



int workload(int n) {
  int i, j = 0;
  volatile int x = 0;
  for (i = 0; i < n; i++) {
    x += i % 3;
    j += x + i;
  }
  return j;
}

int main(void) {
  struct pstat st;
  int pids[NUM_PROCS];

  printf(1, "\n==== [TEST2: MLFQ w/o tracking] ====\n");

  if (setSchedPolicy(2) < 0) {
    printf(1, "setSchedPolicy(2) failed!\n");
    exit();
  }

  for (int i = 0; i < NUM_PROCS; i++) {
    int pid = fork();
    if (pid == 0) {
      // 자식 프로세스
      for (int t = 0; t < ITER; t++) {
        workload((i + 1) * 2000000);  // Q 강등 유도용
        sleep(10);  // yield() 유도
        if (t % 5 == 0 && getpid() % 2 == 0) sleep(0);  // 일부러 섞기
      }
      exit();
    } else {
      pids[i] = pid;
    }
  }

  sleep(300);  // 충분한 실행 시간

  if (getpinfo(&st) < 0) {
    printf(1, "getpinfo 실패\n");
    exit();
  }

  printf(1, "\n=== [RESULT: TEST2 - policy 2] ===\n");
  for (int i = 0; i < NPROC; i++) {
    for (int j = 0; j < NUM_PROCS; j++) {
      if (st.inuse[i] && st.pid[i] == pids[j]) {
        printf(1, "▶ Process %d (PID %d): 최종 Q → Q%d\n", j + 1, st.pid[i], st.priority[i]);
        printf(1, "   ticks      : [Q0:%d Q1:%d Q2:%d Q3:%d]\n",
               st.ticks[i][0], st.ticks[i][1], st.ticks[i][2], st.ticks[i][3]);
        printf(1, "   wait_ticks : [Q0:%d Q1:%d Q2:%d Q3:%d]\n\n",
               st.wait_ticks[i][0], st.wait_ticks[i][1],
               st.wait_ticks[i][2], st.wait_ticks[i][3]);
      }
    }
  }

  for (int i = 0; i < NUM_PROCS; i++) kill(pids[i]);
  for (int i = 0; i < NUM_PROCS; i++) wait();

  printf(1, "==== 종료 ====\n");
  exit();
}