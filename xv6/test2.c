#include "types.h"
#include "user.h"
#include "pstat.h"


#define NUM_PROCS 4

int workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++)
    j += i * j + 1;
  return j;
}

int main(void) {
  struct pstat st;
  int pids[NUM_PROCS];
  int i;

  printf(1, "\n==== [TEST2: MLFQ w/o tracking] ====\n");

  if (setSchedPolicy(2) < 0) {
    printf(1, "setSchedPolicy failed!\n");
    exit();
  }

  for (i = 0; i < NUM_PROCS; i++) {
    int pid = fork();
    if (pid == 0) {
      // 자식 프로세스
      int iter = 0;
      while (1) {
        iter++;
        // 점점 더 무거운 workload
        if (i == 0)
          workload(1000000);  // 1번: Q3 유지
        else if (i == 1)
          workload(4000000);  // 2번: Q2 예상
        else if (i == 2)
          workload(10000000); // 3번: Q1 예상
        else
          workload(50000000); // 4번: no yield, Q0

        // i < 3 까지만 yield 호출 → Q0까지는 안감
        if (i < 3)
          sleep(3);
      }
    } else {
      // 부모는 pid 저장
      pids[i] = pid;
      printf(1, "[parent] 자식 프로세스 pid[%d] = %d\n", i, pid);

    }
  }

  // 충분히 실행할 시간 대기
  sleep(3000);

  if (getpinfo(&st) < 0) {
    printf(1, "getpinfo failed\n");
    exit();
  }

  // 결과 출력
  printf(1, "\n[결과] 각 프로세스의 우선순위 및 큐별 tick 정보:\n\n");

  for (i = 0; i < NPROC; i++) {
    if (st.inuse[i]) {
      for (int j = 0; j < NUM_PROCS; j++) {
        if (st.pid[i] == pids[j]) {
          printf(1, "▶ 프로세스 %d (PID %d): 현재 큐 → Q%d\n", j + 1, st.pid[i], st.priority[i]);
          printf(1, "   ticks       : Q0:%d  Q1:%d  Q2:%d  Q3:%d\n",
                 st.ticks[i][0], st.ticks[i][1], st.ticks[i][2], st.ticks[i][3]);
          printf(1, "   wait_ticks  : Q0:%d  Q1:%d  Q2:%d  Q3:%d\n\n",
                 st.wait_ticks[i][0], st.wait_ticks[i][1], st.wait_ticks[i][2], st.wait_ticks[i][3]);
        }
      }
    }
  }

  // 자식 프로세스 정리
  for (i = 0; i < NUM_PROCS; i++)
    kill(pids[i]);
  for (i = 0; i < NUM_PROCS; i++)
    wait();

  printf(1, "==== 종료 ====\n");
  exit();
}
