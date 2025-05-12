#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

#define N 4

int workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++)
    j += i * j + 1;
  return j;
}

int get_proc_index(int pid, struct pstat *st) {
  for (int i = 0; i < NPROC; i++) {
    if (st->inuse[i] && st->pid[i] == pid)
      return i;
  }
  return -1;
}

void child_with_yield() {
  for (int i = 0; i < 4; i++) {
    workload(1000000); // 더 가볍게 하여 yield 효과 살림
    yield();
  }
  sleep(100); // 더 오래 대기하여 상태 보존 보장
  exit();
}

void child_no_yield() {
  for (int i = 0; i < 200; i++) {
    workload(100000); // 총 tick 소모 유도
  }
  sleep(200); // 더 긴 sleep으로 tick 누적 보장
  exit();
}

int main(void) {
  int pids[N];
  struct pstat st;

  printf(1, "setSchedPolicy(3)\n");
  setSchedPolicy(3);

  if ((pids[0] = fork()) == 0) child_with_yield(); // P1
  if ((pids[1] = fork()) == 0) child_with_yield(); // P2
  if ((pids[2] = fork()) == 0) child_no_yield();  // P3
  if ((pids[3] = fork()) == 0) child_no_yield();  // P4

  sleep(800); // 모든 프로세스가 충분히 실행되도록 대기

  getpinfo(&st);

  for (int i = 0; i < N; i++) {
    int idx = get_proc_index(pids[i], &st);
    if (idx == -1) {
      printf(1, "[P%d] not found in pstat!\n", i + 1);
      continue;
    }

    int prio = st.priority[idx];
    if (i < 2) {
      if (prio == 3)
        printf(1, "[P%d] priority = Q3 → OK (yield)\n", i + 1);
      else
        printf(1, "[P%d] priority = Q%d → FAIL (should be Q3)\n", i + 1, prio);
    } else {
      if (prio == 0)
        printf(1, "[P%d] priority = Q0 → OK (no yield)\n", i + 1);
      else
        printf(1, "[P%d] priority = Q%d → FAIL (should be Q0)\n", i + 1, prio);
    }
  }

  printf(1, "Confirm all tasks go down to Q0.\n");
  printf(1, "Should have correct wait times as expected\n");

  for (int i = 0; i < N; i++) wait();
  exit();
}
