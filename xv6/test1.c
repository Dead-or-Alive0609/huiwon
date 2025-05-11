#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

#define TICKS1 40000000     // Process 1 - Q3 → Q2 → Q3
#define TICKS2 80000000     // Process 2 - Q3 → Q2 → Q1 → Q2 → Q3
#define TICKS3 160000000    // Process 3 - Q3 → Q2 → Q1 → Q0 → Q1 → Q2 → Q3

void workload(int ticks) {
  int i, j = 0;
  for (i = 0; i < ticks; i++) {
    j = j * j + 1;
  }
}

void print_info(struct pstat *st, int pid, int snapshot) {
  for (int i = 0; i < NPROC; i++) {
    if (st->inuse[i] && st->pid[i] == pid) {
      printf(1, "\n[snapshot %d] pid %d, priority: %d\n", snapshot, pid, st->priority[i]);
      for (int q = 3; q >= 0; q--) {
        printf(1, " Q%d → ticks: %d, wait_ticks: %d\n",
               q, st->ticks[i][q], st->wait_ticks[i][q]);
      }
      break;
    }
  }
}

int main(int argc, char *argv[]) {
  struct pstat st;
  int pid1, pid2, pid3;

  setSchedPolicy(1);

  pid1 = fork();
  if (pid1 == 0) {
    workload(TICKS1);
    exit();
  }

  pid2 = fork();
  if (pid2 == 0) {
    workload(TICKS2);
    exit();
  }

  pid3 = fork();
  if (pid3 == 0) {
    workload(TICKS3);
    exit();
  }

  // 💡 자식들이 충분히 실행되도록 시간 확보 + 스냅샷 출력 반복
  for (int i = 0; i < 8; i++) {
    sleep(500); // 충분히 trap 발생할 시간 확보
    if (getpinfo(&st) == 0) {
      print_info(&st, pid1, i);
      print_info(&st, pid2, i);
      print_info(&st, pid3, i);
    }
  }

  // 자식 종료 대기
  wait();
  wait();
  wait();

  printf(1, "\n[parent] done. exiting...\n");
  exit();
}
