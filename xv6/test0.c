#include "types.h"
#include "user.h"
#include "pstat.h"

#define NUM_PROCS 3
#define WORK_UNIT 10000000

void workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++) {
    j += i * j + 1;
  }
}

int main(void) {
  setSchedPolicy(1); // MLFQ 정책 적용

  printf(1, "\n[TEST0] MLFQ tick 증가 및 DEMOTE 동작 테스트 시작\n");

  for (int i = 0; i < NUM_PROCS; i++) {
    int pid = fork();
    if (pid < 0) {
      printf(1, "fork 실패\n");
      exit();
    }

    if (pid == 0) {
      // child
      while (1) {
        workload(WORK_UNIT); // CPU 사용
        sleep(1);            // yield 유도 (DEMOTE 확인용)
      }
    }
  }

  // 부모는 대기
  for (int i = 0; i < NUM_PROCS; i++) {
    wait();
  }

  printf(1, "\n[TEST0 종료] Ctrl-a x로 QEMU 종료\n");
  exit();
}
