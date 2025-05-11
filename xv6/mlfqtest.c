#include "types.h"
#include "user.h"
#include "pstat.h"

#define TICK 40000

// workload 함수: n번 반복하면서 CPU 점유
void workload(int n) {
  volatile int j = 1;
  for (int i = 0; i < n; i++) {
    j += (i % 100) * (j % 1000) + 1;
  }
}

// priority 추적용 함수
void print_priority_change(char* label, int pid, int* prev_priority, struct pstat* before, struct pstat* after) {
  for (int i = 0; i < NPROC; i++) {
    if (after->inuse[i] && after->pid[i] == pid) {
      if (after->priority[i] != *prev_priority) {
        printf(1, "[%s: pid %d] Q%d → Q%d\n", label, pid, *prev_priority, after->priority[i]);
        *prev_priority = after->priority[i];
      }
      break;
    }
  }
}

// 실험용 자식 프로세스 실행
void run_test(char *label, int delays[], int count) {
  struct pstat before, after;
  int pid = getpid();
  int q = 3;  // 시작은 Q3

  getpinfo(&before);

  for (int i = 0; i < count; i++) {
    workload(delays[i]);
    getpinfo(&after);
    print_priority_change(label, pid, &q, &before, &after);
    before = after;
  }

  printf(1, "[%s: pid %d] 종료됨\n", label, pid);
  exit();
}

int main() {
  setSchedPolicy(1);  // MLFQ 설정

  if (fork() == 0) {
    int delays[] = {8*TICK, 8*TICK, 8*TICK};  // P1: Q3 → Q2 → Q3
    run_test("P1", delays, 3);
  }

  if (fork() == 0) {
    int delays[] = {8*TICK, 16*TICK, 32*TICK, 16*TICK, 8*TICK};  // P2: Q3→Q2→Q1→Q2→Q3
    run_test("P2", delays, 5);
  }

  if (fork() == 0) {
    int delays[] = {8*TICK, 16*TICK, 32*TICK, 64*TICK, 32*TICK, 16*TICK, 8*TICK};  // P3: Q3→Q2→Q1→Q0→Q1→Q2→Q3
    run_test("P3", delays, 7);
  }

  wait(); wait(); wait();  // 자식 종료 대기

  struct pstat ps;
  getpinfo(&ps);

  for (int i = 0; i < NPROC; i++) {
    if (ps.inuse[i]) {
      printf(1, "\n[pid %d] Final priority: %d\n", ps.pid[i], ps.priority[i]);
      for (int j = 0; j < 4; j++) {
        printf(1, " Q%d → ticks: %d, wait_ticks: %d\n", j, ps.ticks[i][j], ps.wait_ticks[i][j]);
      }
    }
  }

  printf(1, "[parent] done. exiting...\n");
  exit();
}
