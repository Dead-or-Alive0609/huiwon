#include "types.h"
#include "user.h"
#include "pstat.h"

#define WORK 50000000
#define SLEEP_TIME 50

void workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++) j += i * j + 1;
}

int main(void) {
  struct pstat ps;

  printf(1, "==== MLFQ TEST (과제 1번 전용) ====\n");
  setSchedPolicy(1);

  for (int i = 0; i < 3; i++) {
    int pid = fork();
    if (pid < 0) {
      printf(1, "fork 실패! i=%d\n", i);
      continue;
    }
    if (pid == 0) {
      if (i == 0) {
        workload(WORK); sleep(SLEEP_TIME);
        workload(WORK * 2); sleep(SLEEP_TIME);
      } else if (i == 1) {
        workload(WORK); sleep(SLEEP_TIME);
        workload(WORK); sleep(SLEEP_TIME);
        workload(WORK * 2); sleep(SLEEP_TIME);
        workload(WORK); sleep(SLEEP_TIME);
        workload(WORK * 3); sleep(SLEEP_TIME);
      } else {
        workload(WORK); sleep(SLEEP_TIME);
        workload(WORK); sleep(SLEEP_TIME);
        workload(WORK * 2); sleep(SLEEP_TIME);
        workload(WORK * 3); sleep(SLEEP_TIME);
        workload(WORK * 2); sleep(SLEEP_TIME);
        workload(WORK); sleep(SLEEP_TIME);
        workload(WORK * 2); sleep(SLEEP_TIME);
        workload(WORK * 3); sleep(SLEEP_TIME);
      }
      exit();
    }
  }

  for (int i = 0; i < 3; i++) wait();

  printf(1, "\n==== getpinfo 결과 ====\n");
  if (getpinfo(&ps) < 0) {
    printf(1, "getpinfo 실패\n");
    exit();
  }

  for (int i = 0; i < NPROC; i++) {
    if (ps.inuse[i] && ps.pid[i] > 2) {
      printf(1, "[pid %d] 현재 Q: Q%d\n", ps.pid[i], ps.priority[i]);
      printf(1, "큐 이동 경로:\n");
      for (int q = 3; q >= 0; q--) {
        printf(1, " Q%d: ticks=%d, wait=%d\n", q, ps.ticks[i][q], ps.wait_ticks[i][q]);
      }
    }
  }

  printf(1, "\n==== MLFQ 테스트 종료 ====\n");
  exit();
}
