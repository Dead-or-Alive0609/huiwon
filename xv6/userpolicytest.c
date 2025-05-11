#include "types.h"
#include "user.h"

int main() {
  printf(1, "Setting scheduling policy to MLFQ (1)\n");
  int res = setSchedPolicy(1);
  if (res == 0) {
    printf(1, "setSchedPolicy 성공!\n");
  } else {
    printf(1, "setSchedPolicy 실패...\n");
  }
  exit();
}
