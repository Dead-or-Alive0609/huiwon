// mlfqstat.c
#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

int main() {
  struct pstat ps;
  if (getpinfo(&ps) != 0) {
    printf(1, "getpinfo failed\n");
    exit();
  }

  for (int i = 0; i < NPROC; i++) {
    if (ps.inuse[i]) {
      printf(1, "pid %d | state %d | prio %d | ticks = [%d %d %d %d] | wait = [%d %d %d %d]\n",
        ps.pid[i], ps.state[i], ps.priority[i],
        ps.ticks[i][0], ps.ticks[i][1], ps.ticks[i][2], ps.ticks[i][3],
        ps.wait_ticks[i][0], ps.wait_ticks[i][1], ps.wait_ticks[i][2], ps.wait_ticks[i][3]);
    }
  }

  exit();
}
