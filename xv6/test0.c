//그냥 mlfq 테스트 코드
//안돌아감
#include "types.h"
#include "user.h"

void workload(int n) {
  int i;
  volatile int x = 0;
  for (i = 0; i < n; i++)
    x += i % 3;
}

int main() {
  setSchedPolicy(1); // policy 1: MLFQ

  for (int i = 0; i < 3; i++) {
    int pid = fork();
    if (pid == 0) {
      for (int j = 0; j < 100; j++) {
        workload(10000000);
        sleep(1);
      }
      exit();
    }
  }

  for (int i = 0; i < 3; i++)
    wait();

  exit();
}
