#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

int workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++) {
    j += i * j + 1;
  }
  return j;
}

int main(int argc, char *argv[]) {
 
 // 테스트 코드 추가하기

}