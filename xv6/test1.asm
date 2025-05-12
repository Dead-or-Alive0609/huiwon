
_test1:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "pstat.h"

#define WORK 50000000
#define SLEEP_TIME 50

void workload(int n) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++) j += i * j + 1;
  11:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  18:	eb 11                	jmp    2b <workload+0x2b>
  1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1d:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  21:	83 c0 01             	add    $0x1,%eax
  24:	01 45 f8             	add    %eax,-0x8(%ebp)
  27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2e:	3b 45 08             	cmp    0x8(%ebp),%eax
  31:	7c e7                	jl     1a <workload+0x1a>
}
  33:	90                   	nop
  34:	90                   	nop
  35:	c9                   	leave  
  36:	c3                   	ret    

00000037 <main>:

int main(void) {
  37:	f3 0f 1e fb          	endbr32 
  3b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  3f:	83 e4 f0             	and    $0xfffffff0,%esp
  42:	ff 71 fc             	pushl  -0x4(%ecx)
  45:	55                   	push   %ebp
  46:	89 e5                	mov    %esp,%ebp
  48:	51                   	push   %ecx
  49:	81 ec 24 0c 00 00    	sub    $0xc24,%esp
  struct pstat ps;

  printf(1, "==== MLFQ TEST (과제 1번 전용) ====\n");
  4f:	83 ec 08             	sub    $0x8,%esp
  52:	68 b0 0b 00 00       	push   $0xbb0
  57:	6a 01                	push   $0x1
  59:	e8 8a 07 00 00       	call   7e8 <printf>
  5e:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(1);
  61:	83 ec 0c             	sub    $0xc,%esp
  64:	6a 01                	push   $0x1
  66:	e8 89 06 00 00       	call   6f4 <setSchedPolicy>
  6b:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < 3; i++) {
  6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  75:	e9 08 02 00 00       	jmp    282 <main+0x24b>
    int pid = fork();
  7a:	e8 cd 05 00 00       	call   64c <fork>
  7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (pid < 0) {
  82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  86:	79 1a                	jns    a2 <main+0x6b>
      printf(1, "fork 실패! i=%d\n", i);
  88:	83 ec 04             	sub    $0x4,%esp
  8b:	ff 75 f4             	pushl  -0xc(%ebp)
  8e:	68 da 0b 00 00       	push   $0xbda
  93:	6a 01                	push   $0x1
  95:	e8 4e 07 00 00       	call   7e8 <printf>
  9a:	83 c4 10             	add    $0x10,%esp
      continue;
  9d:	e9 dc 01 00 00       	jmp    27e <main+0x247>
    }
    if (pid == 0) {
  a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  a6:	0f 85 d2 01 00 00    	jne    27e <main+0x247>
      if (i == 0) {
  ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  b0:	75 3f                	jne    f1 <main+0xba>
        workload(WORK); sleep(SLEEP_TIME);
  b2:	83 ec 0c             	sub    $0xc,%esp
  b5:	68 80 f0 fa 02       	push   $0x2faf080
  ba:	e8 41 ff ff ff       	call   0 <workload>
  bf:	83 c4 10             	add    $0x10,%esp
  c2:	83 ec 0c             	sub    $0xc,%esp
  c5:	6a 32                	push   $0x32
  c7:	e8 18 06 00 00       	call   6e4 <sleep>
  cc:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
  cf:	83 ec 0c             	sub    $0xc,%esp
  d2:	68 00 e1 f5 05       	push   $0x5f5e100
  d7:	e8 24 ff ff ff       	call   0 <workload>
  dc:	83 c4 10             	add    $0x10,%esp
  df:	83 ec 0c             	sub    $0xc,%esp
  e2:	6a 32                	push   $0x32
  e4:	e8 fb 05 00 00       	call   6e4 <sleep>
  e9:	83 c4 10             	add    $0x10,%esp
  ec:	e9 88 01 00 00       	jmp    279 <main+0x242>
      } else if (i == 1) {
  f1:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  f5:	0f 85 96 00 00 00    	jne    191 <main+0x15a>
        workload(WORK); sleep(SLEEP_TIME);
  fb:	83 ec 0c             	sub    $0xc,%esp
  fe:	68 80 f0 fa 02       	push   $0x2faf080
 103:	e8 f8 fe ff ff       	call   0 <workload>
 108:	83 c4 10             	add    $0x10,%esp
 10b:	83 ec 0c             	sub    $0xc,%esp
 10e:	6a 32                	push   $0x32
 110:	e8 cf 05 00 00       	call   6e4 <sleep>
 115:	83 c4 10             	add    $0x10,%esp
        workload(WORK); sleep(SLEEP_TIME);
 118:	83 ec 0c             	sub    $0xc,%esp
 11b:	68 80 f0 fa 02       	push   $0x2faf080
 120:	e8 db fe ff ff       	call   0 <workload>
 125:	83 c4 10             	add    $0x10,%esp
 128:	83 ec 0c             	sub    $0xc,%esp
 12b:	6a 32                	push   $0x32
 12d:	e8 b2 05 00 00       	call   6e4 <sleep>
 132:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
 135:	83 ec 0c             	sub    $0xc,%esp
 138:	68 00 e1 f5 05       	push   $0x5f5e100
 13d:	e8 be fe ff ff       	call   0 <workload>
 142:	83 c4 10             	add    $0x10,%esp
 145:	83 ec 0c             	sub    $0xc,%esp
 148:	6a 32                	push   $0x32
 14a:	e8 95 05 00 00       	call   6e4 <sleep>
 14f:	83 c4 10             	add    $0x10,%esp
        workload(WORK); sleep(SLEEP_TIME);
 152:	83 ec 0c             	sub    $0xc,%esp
 155:	68 80 f0 fa 02       	push   $0x2faf080
 15a:	e8 a1 fe ff ff       	call   0 <workload>
 15f:	83 c4 10             	add    $0x10,%esp
 162:	83 ec 0c             	sub    $0xc,%esp
 165:	6a 32                	push   $0x32
 167:	e8 78 05 00 00       	call   6e4 <sleep>
 16c:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 3); sleep(SLEEP_TIME);
 16f:	83 ec 0c             	sub    $0xc,%esp
 172:	68 80 d1 f0 08       	push   $0x8f0d180
 177:	e8 84 fe ff ff       	call   0 <workload>
 17c:	83 c4 10             	add    $0x10,%esp
 17f:	83 ec 0c             	sub    $0xc,%esp
 182:	6a 32                	push   $0x32
 184:	e8 5b 05 00 00       	call   6e4 <sleep>
 189:	83 c4 10             	add    $0x10,%esp
 18c:	e9 e8 00 00 00       	jmp    279 <main+0x242>
      } else {
        workload(WORK); sleep(SLEEP_TIME);
 191:	83 ec 0c             	sub    $0xc,%esp
 194:	68 80 f0 fa 02       	push   $0x2faf080
 199:	e8 62 fe ff ff       	call   0 <workload>
 19e:	83 c4 10             	add    $0x10,%esp
 1a1:	83 ec 0c             	sub    $0xc,%esp
 1a4:	6a 32                	push   $0x32
 1a6:	e8 39 05 00 00       	call   6e4 <sleep>
 1ab:	83 c4 10             	add    $0x10,%esp
        workload(WORK); sleep(SLEEP_TIME);
 1ae:	83 ec 0c             	sub    $0xc,%esp
 1b1:	68 80 f0 fa 02       	push   $0x2faf080
 1b6:	e8 45 fe ff ff       	call   0 <workload>
 1bb:	83 c4 10             	add    $0x10,%esp
 1be:	83 ec 0c             	sub    $0xc,%esp
 1c1:	6a 32                	push   $0x32
 1c3:	e8 1c 05 00 00       	call   6e4 <sleep>
 1c8:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
 1cb:	83 ec 0c             	sub    $0xc,%esp
 1ce:	68 00 e1 f5 05       	push   $0x5f5e100
 1d3:	e8 28 fe ff ff       	call   0 <workload>
 1d8:	83 c4 10             	add    $0x10,%esp
 1db:	83 ec 0c             	sub    $0xc,%esp
 1de:	6a 32                	push   $0x32
 1e0:	e8 ff 04 00 00       	call   6e4 <sleep>
 1e5:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 3); sleep(SLEEP_TIME);
 1e8:	83 ec 0c             	sub    $0xc,%esp
 1eb:	68 80 d1 f0 08       	push   $0x8f0d180
 1f0:	e8 0b fe ff ff       	call   0 <workload>
 1f5:	83 c4 10             	add    $0x10,%esp
 1f8:	83 ec 0c             	sub    $0xc,%esp
 1fb:	6a 32                	push   $0x32
 1fd:	e8 e2 04 00 00       	call   6e4 <sleep>
 202:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
 205:	83 ec 0c             	sub    $0xc,%esp
 208:	68 00 e1 f5 05       	push   $0x5f5e100
 20d:	e8 ee fd ff ff       	call   0 <workload>
 212:	83 c4 10             	add    $0x10,%esp
 215:	83 ec 0c             	sub    $0xc,%esp
 218:	6a 32                	push   $0x32
 21a:	e8 c5 04 00 00       	call   6e4 <sleep>
 21f:	83 c4 10             	add    $0x10,%esp
        workload(WORK); sleep(SLEEP_TIME);
 222:	83 ec 0c             	sub    $0xc,%esp
 225:	68 80 f0 fa 02       	push   $0x2faf080
 22a:	e8 d1 fd ff ff       	call   0 <workload>
 22f:	83 c4 10             	add    $0x10,%esp
 232:	83 ec 0c             	sub    $0xc,%esp
 235:	6a 32                	push   $0x32
 237:	e8 a8 04 00 00       	call   6e4 <sleep>
 23c:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
 23f:	83 ec 0c             	sub    $0xc,%esp
 242:	68 00 e1 f5 05       	push   $0x5f5e100
 247:	e8 b4 fd ff ff       	call   0 <workload>
 24c:	83 c4 10             	add    $0x10,%esp
 24f:	83 ec 0c             	sub    $0xc,%esp
 252:	6a 32                	push   $0x32
 254:	e8 8b 04 00 00       	call   6e4 <sleep>
 259:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 3); sleep(SLEEP_TIME);
 25c:	83 ec 0c             	sub    $0xc,%esp
 25f:	68 80 d1 f0 08       	push   $0x8f0d180
 264:	e8 97 fd ff ff       	call   0 <workload>
 269:	83 c4 10             	add    $0x10,%esp
 26c:	83 ec 0c             	sub    $0xc,%esp
 26f:	6a 32                	push   $0x32
 271:	e8 6e 04 00 00       	call   6e4 <sleep>
 276:	83 c4 10             	add    $0x10,%esp
      }
      exit();
 279:	e8 d6 03 00 00       	call   654 <exit>
  for (int i = 0; i < 3; i++) {
 27e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 282:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 286:	0f 8e ee fd ff ff    	jle    7a <main+0x43>
    }
  }

  for (int i = 0; i < 3; i++) wait();
 28c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 293:	eb 09                	jmp    29e <main+0x267>
 295:	e8 c2 03 00 00       	call   65c <wait>
 29a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 29e:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 2a2:	7e f1                	jle    295 <main+0x25e>

  printf(1, "\n==== getpinfo 결과 ====\n");
 2a4:	83 ec 08             	sub    $0x8,%esp
 2a7:	68 ed 0b 00 00       	push   $0xbed
 2ac:	6a 01                	push   $0x1
 2ae:	e8 35 05 00 00       	call   7e8 <printf>
 2b3:	83 c4 10             	add    $0x10,%esp
  if (getpinfo(&ps) < 0) {
 2b6:	83 ec 0c             	sub    $0xc,%esp
 2b9:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
 2bf:	50                   	push   %eax
 2c0:	e8 37 04 00 00       	call   6fc <getpinfo>
 2c5:	83 c4 10             	add    $0x10,%esp
 2c8:	85 c0                	test   %eax,%eax
 2ca:	79 17                	jns    2e3 <main+0x2ac>
    printf(1, "getpinfo 실패\n");
 2cc:	83 ec 08             	sub    $0x8,%esp
 2cf:	68 09 0c 00 00       	push   $0xc09
 2d4:	6a 01                	push   $0x1
 2d6:	e8 0d 05 00 00       	call   7e8 <printf>
 2db:	83 c4 10             	add    $0x10,%esp
    exit();
 2de:	e8 71 03 00 00       	call   654 <exit>
  }

  for (int i = 0; i < NPROC; i++) {
 2e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 2ea:	e9 c9 00 00 00       	jmp    3b8 <main+0x381>
    if (ps.inuse[i] && ps.pid[i] > 2) {
 2ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2f2:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 2f9:	85 c0                	test   %eax,%eax
 2fb:	0f 84 b3 00 00 00    	je     3b4 <main+0x37d>
 301:	8b 45 ec             	mov    -0x14(%ebp),%eax
 304:	83 c0 40             	add    $0x40,%eax
 307:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 30e:	83 f8 02             	cmp    $0x2,%eax
 311:	0f 8e 9d 00 00 00    	jle    3b4 <main+0x37d>
      printf(1, "[pid %d] 현재 Q: Q%d\n", ps.pid[i], ps.priority[i]);
 317:	8b 45 ec             	mov    -0x14(%ebp),%eax
 31a:	83 e8 80             	sub    $0xffffff80,%eax
 31d:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 324:	8b 45 ec             	mov    -0x14(%ebp),%eax
 327:	83 c0 40             	add    $0x40,%eax
 32a:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 331:	52                   	push   %edx
 332:	50                   	push   %eax
 333:	68 1a 0c 00 00       	push   $0xc1a
 338:	6a 01                	push   $0x1
 33a:	e8 a9 04 00 00       	call   7e8 <printf>
 33f:	83 c4 10             	add    $0x10,%esp
      printf(1, "큐 이동 경로:\n");
 342:	83 ec 08             	sub    $0x8,%esp
 345:	68 32 0c 00 00       	push   $0xc32
 34a:	6a 01                	push   $0x1
 34c:	e8 97 04 00 00       	call   7e8 <printf>
 351:	83 c4 10             	add    $0x10,%esp
      for (int q = 3; q >= 0; q--) {
 354:	c7 45 e8 03 00 00 00 	movl   $0x3,-0x18(%ebp)
 35b:	eb 51                	jmp    3ae <main+0x377>
        printf(1, " Q%d: ticks=%d, wait=%d\n", q, ps.ticks[i][q], ps.wait_ticks[i][q]);
 35d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 360:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 367:	8b 45 e8             	mov    -0x18(%ebp),%eax
 36a:	01 d0                	add    %edx,%eax
 36c:	05 00 02 00 00       	add    $0x200,%eax
 371:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 378:	8b 45 ec             	mov    -0x14(%ebp),%eax
 37b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
 382:	8b 45 e8             	mov    -0x18(%ebp),%eax
 385:	01 c8                	add    %ecx,%eax
 387:	05 00 01 00 00       	add    $0x100,%eax
 38c:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 393:	83 ec 0c             	sub    $0xc,%esp
 396:	52                   	push   %edx
 397:	50                   	push   %eax
 398:	ff 75 e8             	pushl  -0x18(%ebp)
 39b:	68 46 0c 00 00       	push   $0xc46
 3a0:	6a 01                	push   $0x1
 3a2:	e8 41 04 00 00       	call   7e8 <printf>
 3a7:	83 c4 20             	add    $0x20,%esp
      for (int q = 3; q >= 0; q--) {
 3aa:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
 3ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 3b2:	79 a9                	jns    35d <main+0x326>
  for (int i = 0; i < NPROC; i++) {
 3b4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 3b8:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
 3bc:	0f 8e 2d ff ff ff    	jle    2ef <main+0x2b8>
      }
    }
  }

  printf(1, "\n==== MLFQ 테스트 종료 ====\n");
 3c2:	83 ec 08             	sub    $0x8,%esp
 3c5:	68 60 0c 00 00       	push   $0xc60
 3ca:	6a 01                	push   $0x1
 3cc:	e8 17 04 00 00       	call   7e8 <printf>
 3d1:	83 c4 10             	add    $0x10,%esp
  exit();
 3d4:	e8 7b 02 00 00       	call   654 <exit>

000003d9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3d9:	55                   	push   %ebp
 3da:	89 e5                	mov    %esp,%ebp
 3dc:	57                   	push   %edi
 3dd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3de:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3e1:	8b 55 10             	mov    0x10(%ebp),%edx
 3e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e7:	89 cb                	mov    %ecx,%ebx
 3e9:	89 df                	mov    %ebx,%edi
 3eb:	89 d1                	mov    %edx,%ecx
 3ed:	fc                   	cld    
 3ee:	f3 aa                	rep stos %al,%es:(%edi)
 3f0:	89 ca                	mov    %ecx,%edx
 3f2:	89 fb                	mov    %edi,%ebx
 3f4:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3f7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3fa:	90                   	nop
 3fb:	5b                   	pop    %ebx
 3fc:	5f                   	pop    %edi
 3fd:	5d                   	pop    %ebp
 3fe:	c3                   	ret    

000003ff <strcpy>:



char*
strcpy(char *s, char *t)
{
 3ff:	f3 0f 1e fb          	endbr32 
 403:	55                   	push   %ebp
 404:	89 e5                	mov    %esp,%ebp
 406:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 409:	8b 45 08             	mov    0x8(%ebp),%eax
 40c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 40f:	90                   	nop
 410:	8b 55 0c             	mov    0xc(%ebp),%edx
 413:	8d 42 01             	lea    0x1(%edx),%eax
 416:	89 45 0c             	mov    %eax,0xc(%ebp)
 419:	8b 45 08             	mov    0x8(%ebp),%eax
 41c:	8d 48 01             	lea    0x1(%eax),%ecx
 41f:	89 4d 08             	mov    %ecx,0x8(%ebp)
 422:	0f b6 12             	movzbl (%edx),%edx
 425:	88 10                	mov    %dl,(%eax)
 427:	0f b6 00             	movzbl (%eax),%eax
 42a:	84 c0                	test   %al,%al
 42c:	75 e2                	jne    410 <strcpy+0x11>
    ;
  return os;
 42e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 431:	c9                   	leave  
 432:	c3                   	ret    

00000433 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 433:	f3 0f 1e fb          	endbr32 
 437:	55                   	push   %ebp
 438:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 43a:	eb 08                	jmp    444 <strcmp+0x11>
    p++, q++;
 43c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 440:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 444:	8b 45 08             	mov    0x8(%ebp),%eax
 447:	0f b6 00             	movzbl (%eax),%eax
 44a:	84 c0                	test   %al,%al
 44c:	74 10                	je     45e <strcmp+0x2b>
 44e:	8b 45 08             	mov    0x8(%ebp),%eax
 451:	0f b6 10             	movzbl (%eax),%edx
 454:	8b 45 0c             	mov    0xc(%ebp),%eax
 457:	0f b6 00             	movzbl (%eax),%eax
 45a:	38 c2                	cmp    %al,%dl
 45c:	74 de                	je     43c <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
 461:	0f b6 00             	movzbl (%eax),%eax
 464:	0f b6 d0             	movzbl %al,%edx
 467:	8b 45 0c             	mov    0xc(%ebp),%eax
 46a:	0f b6 00             	movzbl (%eax),%eax
 46d:	0f b6 c0             	movzbl %al,%eax
 470:	29 c2                	sub    %eax,%edx
 472:	89 d0                	mov    %edx,%eax
}
 474:	5d                   	pop    %ebp
 475:	c3                   	ret    

00000476 <strlen>:

uint
strlen(char *s)
{
 476:	f3 0f 1e fb          	endbr32 
 47a:	55                   	push   %ebp
 47b:	89 e5                	mov    %esp,%ebp
 47d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 480:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 487:	eb 04                	jmp    48d <strlen+0x17>
 489:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 48d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 490:	8b 45 08             	mov    0x8(%ebp),%eax
 493:	01 d0                	add    %edx,%eax
 495:	0f b6 00             	movzbl (%eax),%eax
 498:	84 c0                	test   %al,%al
 49a:	75 ed                	jne    489 <strlen+0x13>
    ;
  return n;
 49c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 49f:	c9                   	leave  
 4a0:	c3                   	ret    

000004a1 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4a1:	f3 0f 1e fb          	endbr32 
 4a5:	55                   	push   %ebp
 4a6:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 4a8:	8b 45 10             	mov    0x10(%ebp),%eax
 4ab:	50                   	push   %eax
 4ac:	ff 75 0c             	pushl  0xc(%ebp)
 4af:	ff 75 08             	pushl  0x8(%ebp)
 4b2:	e8 22 ff ff ff       	call   3d9 <stosb>
 4b7:	83 c4 0c             	add    $0xc,%esp
  return dst;
 4ba:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4bd:	c9                   	leave  
 4be:	c3                   	ret    

000004bf <strchr>:

char*
strchr(const char *s, char c)
{
 4bf:	f3 0f 1e fb          	endbr32 
 4c3:	55                   	push   %ebp
 4c4:	89 e5                	mov    %esp,%ebp
 4c6:	83 ec 04             	sub    $0x4,%esp
 4c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4cc:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4cf:	eb 14                	jmp    4e5 <strchr+0x26>
    if(*s == c)
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	0f b6 00             	movzbl (%eax),%eax
 4d7:	38 45 fc             	cmp    %al,-0x4(%ebp)
 4da:	75 05                	jne    4e1 <strchr+0x22>
      return (char*)s;
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	eb 13                	jmp    4f4 <strchr+0x35>
  for(; *s; s++)
 4e1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4e5:	8b 45 08             	mov    0x8(%ebp),%eax
 4e8:	0f b6 00             	movzbl (%eax),%eax
 4eb:	84 c0                	test   %al,%al
 4ed:	75 e2                	jne    4d1 <strchr+0x12>
  return 0;
 4ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4f4:	c9                   	leave  
 4f5:	c3                   	ret    

000004f6 <gets>:

char*
gets(char *buf, int max)
{
 4f6:	f3 0f 1e fb          	endbr32 
 4fa:	55                   	push   %ebp
 4fb:	89 e5                	mov    %esp,%ebp
 4fd:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 500:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 507:	eb 42                	jmp    54b <gets+0x55>
    cc = read(0, &c, 1);
 509:	83 ec 04             	sub    $0x4,%esp
 50c:	6a 01                	push   $0x1
 50e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 511:	50                   	push   %eax
 512:	6a 00                	push   $0x0
 514:	e8 53 01 00 00       	call   66c <read>
 519:	83 c4 10             	add    $0x10,%esp
 51c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 51f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 523:	7e 33                	jle    558 <gets+0x62>
      break;
    buf[i++] = c;
 525:	8b 45 f4             	mov    -0xc(%ebp),%eax
 528:	8d 50 01             	lea    0x1(%eax),%edx
 52b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 52e:	89 c2                	mov    %eax,%edx
 530:	8b 45 08             	mov    0x8(%ebp),%eax
 533:	01 c2                	add    %eax,%edx
 535:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 539:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 53b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 53f:	3c 0a                	cmp    $0xa,%al
 541:	74 16                	je     559 <gets+0x63>
 543:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 547:	3c 0d                	cmp    $0xd,%al
 549:	74 0e                	je     559 <gets+0x63>
  for(i=0; i+1 < max; ){
 54b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54e:	83 c0 01             	add    $0x1,%eax
 551:	39 45 0c             	cmp    %eax,0xc(%ebp)
 554:	7f b3                	jg     509 <gets+0x13>
 556:	eb 01                	jmp    559 <gets+0x63>
      break;
 558:	90                   	nop
      break;
  }
  buf[i] = '\0';
 559:	8b 55 f4             	mov    -0xc(%ebp),%edx
 55c:	8b 45 08             	mov    0x8(%ebp),%eax
 55f:	01 d0                	add    %edx,%eax
 561:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 564:	8b 45 08             	mov    0x8(%ebp),%eax
}
 567:	c9                   	leave  
 568:	c3                   	ret    

00000569 <stat>:

int
stat(char *n, struct stat *st)
{
 569:	f3 0f 1e fb          	endbr32 
 56d:	55                   	push   %ebp
 56e:	89 e5                	mov    %esp,%ebp
 570:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 573:	83 ec 08             	sub    $0x8,%esp
 576:	6a 00                	push   $0x0
 578:	ff 75 08             	pushl  0x8(%ebp)
 57b:	e8 14 01 00 00       	call   694 <open>
 580:	83 c4 10             	add    $0x10,%esp
 583:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 586:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 58a:	79 07                	jns    593 <stat+0x2a>
    return -1;
 58c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 591:	eb 25                	jmp    5b8 <stat+0x4f>
  r = fstat(fd, st);
 593:	83 ec 08             	sub    $0x8,%esp
 596:	ff 75 0c             	pushl  0xc(%ebp)
 599:	ff 75 f4             	pushl  -0xc(%ebp)
 59c:	e8 0b 01 00 00       	call   6ac <fstat>
 5a1:	83 c4 10             	add    $0x10,%esp
 5a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 5a7:	83 ec 0c             	sub    $0xc,%esp
 5aa:	ff 75 f4             	pushl  -0xc(%ebp)
 5ad:	e8 ca 00 00 00       	call   67c <close>
 5b2:	83 c4 10             	add    $0x10,%esp
  return r;
 5b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5b8:	c9                   	leave  
 5b9:	c3                   	ret    

000005ba <atoi>:

int
atoi(const char *s)
{
 5ba:	f3 0f 1e fb          	endbr32 
 5be:	55                   	push   %ebp
 5bf:	89 e5                	mov    %esp,%ebp
 5c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 5c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5cb:	eb 25                	jmp    5f2 <atoi+0x38>
    n = n*10 + *s++ - '0';
 5cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5d0:	89 d0                	mov    %edx,%eax
 5d2:	c1 e0 02             	shl    $0x2,%eax
 5d5:	01 d0                	add    %edx,%eax
 5d7:	01 c0                	add    %eax,%eax
 5d9:	89 c1                	mov    %eax,%ecx
 5db:	8b 45 08             	mov    0x8(%ebp),%eax
 5de:	8d 50 01             	lea    0x1(%eax),%edx
 5e1:	89 55 08             	mov    %edx,0x8(%ebp)
 5e4:	0f b6 00             	movzbl (%eax),%eax
 5e7:	0f be c0             	movsbl %al,%eax
 5ea:	01 c8                	add    %ecx,%eax
 5ec:	83 e8 30             	sub    $0x30,%eax
 5ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5f2:	8b 45 08             	mov    0x8(%ebp),%eax
 5f5:	0f b6 00             	movzbl (%eax),%eax
 5f8:	3c 2f                	cmp    $0x2f,%al
 5fa:	7e 0a                	jle    606 <atoi+0x4c>
 5fc:	8b 45 08             	mov    0x8(%ebp),%eax
 5ff:	0f b6 00             	movzbl (%eax),%eax
 602:	3c 39                	cmp    $0x39,%al
 604:	7e c7                	jle    5cd <atoi+0x13>
  return n;
 606:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 609:	c9                   	leave  
 60a:	c3                   	ret    

0000060b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 60b:	f3 0f 1e fb          	endbr32 
 60f:	55                   	push   %ebp
 610:	89 e5                	mov    %esp,%ebp
 612:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 615:	8b 45 08             	mov    0x8(%ebp),%eax
 618:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 61b:	8b 45 0c             	mov    0xc(%ebp),%eax
 61e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 621:	eb 17                	jmp    63a <memmove+0x2f>
    *dst++ = *src++;
 623:	8b 55 f8             	mov    -0x8(%ebp),%edx
 626:	8d 42 01             	lea    0x1(%edx),%eax
 629:	89 45 f8             	mov    %eax,-0x8(%ebp)
 62c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62f:	8d 48 01             	lea    0x1(%eax),%ecx
 632:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 635:	0f b6 12             	movzbl (%edx),%edx
 638:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 63a:	8b 45 10             	mov    0x10(%ebp),%eax
 63d:	8d 50 ff             	lea    -0x1(%eax),%edx
 640:	89 55 10             	mov    %edx,0x10(%ebp)
 643:	85 c0                	test   %eax,%eax
 645:	7f dc                	jg     623 <memmove+0x18>
  return vdst;
 647:	8b 45 08             	mov    0x8(%ebp),%eax
}
 64a:	c9                   	leave  
 64b:	c3                   	ret    

0000064c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 64c:	b8 01 00 00 00       	mov    $0x1,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <exit>:
SYSCALL(exit)
 654:	b8 02 00 00 00       	mov    $0x2,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <wait>:
SYSCALL(wait)
 65c:	b8 03 00 00 00       	mov    $0x3,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <pipe>:
SYSCALL(pipe)
 664:	b8 04 00 00 00       	mov    $0x4,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <read>:
SYSCALL(read)
 66c:	b8 05 00 00 00       	mov    $0x5,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <write>:
SYSCALL(write)
 674:	b8 10 00 00 00       	mov    $0x10,%eax
 679:	cd 40                	int    $0x40
 67b:	c3                   	ret    

0000067c <close>:
SYSCALL(close)
 67c:	b8 15 00 00 00       	mov    $0x15,%eax
 681:	cd 40                	int    $0x40
 683:	c3                   	ret    

00000684 <kill>:
SYSCALL(kill)
 684:	b8 06 00 00 00       	mov    $0x6,%eax
 689:	cd 40                	int    $0x40
 68b:	c3                   	ret    

0000068c <exec>:
SYSCALL(exec)
 68c:	b8 07 00 00 00       	mov    $0x7,%eax
 691:	cd 40                	int    $0x40
 693:	c3                   	ret    

00000694 <open>:
SYSCALL(open)
 694:	b8 0f 00 00 00       	mov    $0xf,%eax
 699:	cd 40                	int    $0x40
 69b:	c3                   	ret    

0000069c <mknod>:
SYSCALL(mknod)
 69c:	b8 11 00 00 00       	mov    $0x11,%eax
 6a1:	cd 40                	int    $0x40
 6a3:	c3                   	ret    

000006a4 <unlink>:
SYSCALL(unlink)
 6a4:	b8 12 00 00 00       	mov    $0x12,%eax
 6a9:	cd 40                	int    $0x40
 6ab:	c3                   	ret    

000006ac <fstat>:
SYSCALL(fstat)
 6ac:	b8 08 00 00 00       	mov    $0x8,%eax
 6b1:	cd 40                	int    $0x40
 6b3:	c3                   	ret    

000006b4 <link>:
SYSCALL(link)
 6b4:	b8 13 00 00 00       	mov    $0x13,%eax
 6b9:	cd 40                	int    $0x40
 6bb:	c3                   	ret    

000006bc <mkdir>:
SYSCALL(mkdir)
 6bc:	b8 14 00 00 00       	mov    $0x14,%eax
 6c1:	cd 40                	int    $0x40
 6c3:	c3                   	ret    

000006c4 <chdir>:
SYSCALL(chdir)
 6c4:	b8 09 00 00 00       	mov    $0x9,%eax
 6c9:	cd 40                	int    $0x40
 6cb:	c3                   	ret    

000006cc <dup>:
SYSCALL(dup)
 6cc:	b8 0a 00 00 00       	mov    $0xa,%eax
 6d1:	cd 40                	int    $0x40
 6d3:	c3                   	ret    

000006d4 <getpid>:
SYSCALL(getpid)
 6d4:	b8 0b 00 00 00       	mov    $0xb,%eax
 6d9:	cd 40                	int    $0x40
 6db:	c3                   	ret    

000006dc <sbrk>:
SYSCALL(sbrk)
 6dc:	b8 0c 00 00 00       	mov    $0xc,%eax
 6e1:	cd 40                	int    $0x40
 6e3:	c3                   	ret    

000006e4 <sleep>:
SYSCALL(sleep)
 6e4:	b8 0d 00 00 00       	mov    $0xd,%eax
 6e9:	cd 40                	int    $0x40
 6eb:	c3                   	ret    

000006ec <uptime>:
SYSCALL(uptime)
 6ec:	b8 0e 00 00 00       	mov    $0xe,%eax
 6f1:	cd 40                	int    $0x40
 6f3:	c3                   	ret    

000006f4 <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 6f4:	b8 16 00 00 00       	mov    $0x16,%eax
 6f9:	cd 40                	int    $0x40
 6fb:	c3                   	ret    

000006fc <getpinfo>:
SYSCALL(getpinfo)
 6fc:	b8 17 00 00 00       	mov    $0x17,%eax
 701:	cd 40                	int    $0x40
 703:	c3                   	ret    

00000704 <yield>:
SYSCALL(yield)
 704:	b8 18 00 00 00       	mov    $0x18,%eax
 709:	cd 40                	int    $0x40
 70b:	c3                   	ret    

0000070c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 70c:	f3 0f 1e fb          	endbr32 
 710:	55                   	push   %ebp
 711:	89 e5                	mov    %esp,%ebp
 713:	83 ec 18             	sub    $0x18,%esp
 716:	8b 45 0c             	mov    0xc(%ebp),%eax
 719:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 71c:	83 ec 04             	sub    $0x4,%esp
 71f:	6a 01                	push   $0x1
 721:	8d 45 f4             	lea    -0xc(%ebp),%eax
 724:	50                   	push   %eax
 725:	ff 75 08             	pushl  0x8(%ebp)
 728:	e8 47 ff ff ff       	call   674 <write>
 72d:	83 c4 10             	add    $0x10,%esp
}
 730:	90                   	nop
 731:	c9                   	leave  
 732:	c3                   	ret    

00000733 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 733:	f3 0f 1e fb          	endbr32 
 737:	55                   	push   %ebp
 738:	89 e5                	mov    %esp,%ebp
 73a:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 73d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 744:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 748:	74 17                	je     761 <printint+0x2e>
 74a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 74e:	79 11                	jns    761 <printint+0x2e>
    neg = 1;
 750:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 757:	8b 45 0c             	mov    0xc(%ebp),%eax
 75a:	f7 d8                	neg    %eax
 75c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 75f:	eb 06                	jmp    767 <printint+0x34>
  } else {
    x = xx;
 761:	8b 45 0c             	mov    0xc(%ebp),%eax
 764:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 767:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 76e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 771:	8b 45 ec             	mov    -0x14(%ebp),%eax
 774:	ba 00 00 00 00       	mov    $0x0,%edx
 779:	f7 f1                	div    %ecx
 77b:	89 d1                	mov    %edx,%ecx
 77d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 780:	8d 50 01             	lea    0x1(%eax),%edx
 783:	89 55 f4             	mov    %edx,-0xc(%ebp)
 786:	0f b6 91 f0 0e 00 00 	movzbl 0xef0(%ecx),%edx
 78d:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 791:	8b 4d 10             	mov    0x10(%ebp),%ecx
 794:	8b 45 ec             	mov    -0x14(%ebp),%eax
 797:	ba 00 00 00 00       	mov    $0x0,%edx
 79c:	f7 f1                	div    %ecx
 79e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7a5:	75 c7                	jne    76e <printint+0x3b>
  if(neg)
 7a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7ab:	74 2d                	je     7da <printint+0xa7>
    buf[i++] = '-';
 7ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b0:	8d 50 01             	lea    0x1(%eax),%edx
 7b3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7b6:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7bb:	eb 1d                	jmp    7da <printint+0xa7>
    putc(fd, buf[i]);
 7bd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	01 d0                	add    %edx,%eax
 7c5:	0f b6 00             	movzbl (%eax),%eax
 7c8:	0f be c0             	movsbl %al,%eax
 7cb:	83 ec 08             	sub    $0x8,%esp
 7ce:	50                   	push   %eax
 7cf:	ff 75 08             	pushl  0x8(%ebp)
 7d2:	e8 35 ff ff ff       	call   70c <putc>
 7d7:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 7da:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e2:	79 d9                	jns    7bd <printint+0x8a>
}
 7e4:	90                   	nop
 7e5:	90                   	nop
 7e6:	c9                   	leave  
 7e7:	c3                   	ret    

000007e8 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7e8:	f3 0f 1e fb          	endbr32 
 7ec:	55                   	push   %ebp
 7ed:	89 e5                	mov    %esp,%ebp
 7ef:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7f9:	8d 45 0c             	lea    0xc(%ebp),%eax
 7fc:	83 c0 04             	add    $0x4,%eax
 7ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 802:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 809:	e9 59 01 00 00       	jmp    967 <printf+0x17f>
    c = fmt[i] & 0xff;
 80e:	8b 55 0c             	mov    0xc(%ebp),%edx
 811:	8b 45 f0             	mov    -0x10(%ebp),%eax
 814:	01 d0                	add    %edx,%eax
 816:	0f b6 00             	movzbl (%eax),%eax
 819:	0f be c0             	movsbl %al,%eax
 81c:	25 ff 00 00 00       	and    $0xff,%eax
 821:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 824:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 828:	75 2c                	jne    856 <printf+0x6e>
      if(c == '%'){
 82a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 82e:	75 0c                	jne    83c <printf+0x54>
        state = '%';
 830:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 837:	e9 27 01 00 00       	jmp    963 <printf+0x17b>
      } else {
        putc(fd, c);
 83c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 83f:	0f be c0             	movsbl %al,%eax
 842:	83 ec 08             	sub    $0x8,%esp
 845:	50                   	push   %eax
 846:	ff 75 08             	pushl  0x8(%ebp)
 849:	e8 be fe ff ff       	call   70c <putc>
 84e:	83 c4 10             	add    $0x10,%esp
 851:	e9 0d 01 00 00       	jmp    963 <printf+0x17b>
      }
    } else if(state == '%'){
 856:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 85a:	0f 85 03 01 00 00    	jne    963 <printf+0x17b>
      if(c == 'd'){
 860:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 864:	75 1e                	jne    884 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 866:	8b 45 e8             	mov    -0x18(%ebp),%eax
 869:	8b 00                	mov    (%eax),%eax
 86b:	6a 01                	push   $0x1
 86d:	6a 0a                	push   $0xa
 86f:	50                   	push   %eax
 870:	ff 75 08             	pushl  0x8(%ebp)
 873:	e8 bb fe ff ff       	call   733 <printint>
 878:	83 c4 10             	add    $0x10,%esp
        ap++;
 87b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 87f:	e9 d8 00 00 00       	jmp    95c <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 884:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 888:	74 06                	je     890 <printf+0xa8>
 88a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 88e:	75 1e                	jne    8ae <printf+0xc6>
        printint(fd, *ap, 16, 0);
 890:	8b 45 e8             	mov    -0x18(%ebp),%eax
 893:	8b 00                	mov    (%eax),%eax
 895:	6a 00                	push   $0x0
 897:	6a 10                	push   $0x10
 899:	50                   	push   %eax
 89a:	ff 75 08             	pushl  0x8(%ebp)
 89d:	e8 91 fe ff ff       	call   733 <printint>
 8a2:	83 c4 10             	add    $0x10,%esp
        ap++;
 8a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8a9:	e9 ae 00 00 00       	jmp    95c <printf+0x174>
      } else if(c == 's'){
 8ae:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8b2:	75 43                	jne    8f7 <printf+0x10f>
        s = (char*)*ap;
 8b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8b7:	8b 00                	mov    (%eax),%eax
 8b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8bc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8c4:	75 25                	jne    8eb <printf+0x103>
          s = "(null)";
 8c6:	c7 45 f4 82 0c 00 00 	movl   $0xc82,-0xc(%ebp)
        while(*s != 0){
 8cd:	eb 1c                	jmp    8eb <printf+0x103>
          putc(fd, *s);
 8cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d2:	0f b6 00             	movzbl (%eax),%eax
 8d5:	0f be c0             	movsbl %al,%eax
 8d8:	83 ec 08             	sub    $0x8,%esp
 8db:	50                   	push   %eax
 8dc:	ff 75 08             	pushl  0x8(%ebp)
 8df:	e8 28 fe ff ff       	call   70c <putc>
 8e4:	83 c4 10             	add    $0x10,%esp
          s++;
 8e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 8eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ee:	0f b6 00             	movzbl (%eax),%eax
 8f1:	84 c0                	test   %al,%al
 8f3:	75 da                	jne    8cf <printf+0xe7>
 8f5:	eb 65                	jmp    95c <printf+0x174>
        }
      } else if(c == 'c'){
 8f7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8fb:	75 1d                	jne    91a <printf+0x132>
        putc(fd, *ap);
 8fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	0f be c0             	movsbl %al,%eax
 905:	83 ec 08             	sub    $0x8,%esp
 908:	50                   	push   %eax
 909:	ff 75 08             	pushl  0x8(%ebp)
 90c:	e8 fb fd ff ff       	call   70c <putc>
 911:	83 c4 10             	add    $0x10,%esp
        ap++;
 914:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 918:	eb 42                	jmp    95c <printf+0x174>
      } else if(c == '%'){
 91a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 91e:	75 17                	jne    937 <printf+0x14f>
        putc(fd, c);
 920:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 923:	0f be c0             	movsbl %al,%eax
 926:	83 ec 08             	sub    $0x8,%esp
 929:	50                   	push   %eax
 92a:	ff 75 08             	pushl  0x8(%ebp)
 92d:	e8 da fd ff ff       	call   70c <putc>
 932:	83 c4 10             	add    $0x10,%esp
 935:	eb 25                	jmp    95c <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 937:	83 ec 08             	sub    $0x8,%esp
 93a:	6a 25                	push   $0x25
 93c:	ff 75 08             	pushl  0x8(%ebp)
 93f:	e8 c8 fd ff ff       	call   70c <putc>
 944:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 947:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 94a:	0f be c0             	movsbl %al,%eax
 94d:	83 ec 08             	sub    $0x8,%esp
 950:	50                   	push   %eax
 951:	ff 75 08             	pushl  0x8(%ebp)
 954:	e8 b3 fd ff ff       	call   70c <putc>
 959:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 95c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 963:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 967:	8b 55 0c             	mov    0xc(%ebp),%edx
 96a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96d:	01 d0                	add    %edx,%eax
 96f:	0f b6 00             	movzbl (%eax),%eax
 972:	84 c0                	test   %al,%al
 974:	0f 85 94 fe ff ff    	jne    80e <printf+0x26>
    }
  }
}
 97a:	90                   	nop
 97b:	90                   	nop
 97c:	c9                   	leave  
 97d:	c3                   	ret    

0000097e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 97e:	f3 0f 1e fb          	endbr32 
 982:	55                   	push   %ebp
 983:	89 e5                	mov    %esp,%ebp
 985:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 988:	8b 45 08             	mov    0x8(%ebp),%eax
 98b:	83 e8 08             	sub    $0x8,%eax
 98e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 991:	a1 0c 0f 00 00       	mov    0xf0c,%eax
 996:	89 45 fc             	mov    %eax,-0x4(%ebp)
 999:	eb 24                	jmp    9bf <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 99b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99e:	8b 00                	mov    (%eax),%eax
 9a0:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 9a3:	72 12                	jb     9b7 <free+0x39>
 9a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9ab:	77 24                	ja     9d1 <free+0x53>
 9ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b0:	8b 00                	mov    (%eax),%eax
 9b2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9b5:	72 1a                	jb     9d1 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ba:	8b 00                	mov    (%eax),%eax
 9bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9c5:	76 d4                	jbe    99b <free+0x1d>
 9c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ca:	8b 00                	mov    (%eax),%eax
 9cc:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9cf:	73 ca                	jae    99b <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d4:	8b 40 04             	mov    0x4(%eax),%eax
 9d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e1:	01 c2                	add    %eax,%edx
 9e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e6:	8b 00                	mov    (%eax),%eax
 9e8:	39 c2                	cmp    %eax,%edx
 9ea:	75 24                	jne    a10 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 9ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ef:	8b 50 04             	mov    0x4(%eax),%edx
 9f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f5:	8b 00                	mov    (%eax),%eax
 9f7:	8b 40 04             	mov    0x4(%eax),%eax
 9fa:	01 c2                	add    %eax,%edx
 9fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ff:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a02:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a05:	8b 00                	mov    (%eax),%eax
 a07:	8b 10                	mov    (%eax),%edx
 a09:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0c:	89 10                	mov    %edx,(%eax)
 a0e:	eb 0a                	jmp    a1a <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 a10:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a13:	8b 10                	mov    (%eax),%edx
 a15:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a18:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a1d:	8b 40 04             	mov    0x4(%eax),%eax
 a20:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a27:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2a:	01 d0                	add    %edx,%eax
 a2c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a2f:	75 20                	jne    a51 <free+0xd3>
    p->s.size += bp->s.size;
 a31:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a34:	8b 50 04             	mov    0x4(%eax),%edx
 a37:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a3a:	8b 40 04             	mov    0x4(%eax),%eax
 a3d:	01 c2                	add    %eax,%edx
 a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a42:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a45:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a48:	8b 10                	mov    (%eax),%edx
 a4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4d:	89 10                	mov    %edx,(%eax)
 a4f:	eb 08                	jmp    a59 <free+0xdb>
  } else
    p->s.ptr = bp;
 a51:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a54:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a57:	89 10                	mov    %edx,(%eax)
  freep = p;
 a59:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5c:	a3 0c 0f 00 00       	mov    %eax,0xf0c
}
 a61:	90                   	nop
 a62:	c9                   	leave  
 a63:	c3                   	ret    

00000a64 <morecore>:

static Header*
morecore(uint nu)
{
 a64:	f3 0f 1e fb          	endbr32 
 a68:	55                   	push   %ebp
 a69:	89 e5                	mov    %esp,%ebp
 a6b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a6e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a75:	77 07                	ja     a7e <morecore+0x1a>
    nu = 4096;
 a77:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a7e:	8b 45 08             	mov    0x8(%ebp),%eax
 a81:	c1 e0 03             	shl    $0x3,%eax
 a84:	83 ec 0c             	sub    $0xc,%esp
 a87:	50                   	push   %eax
 a88:	e8 4f fc ff ff       	call   6dc <sbrk>
 a8d:	83 c4 10             	add    $0x10,%esp
 a90:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a93:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a97:	75 07                	jne    aa0 <morecore+0x3c>
    return 0;
 a99:	b8 00 00 00 00       	mov    $0x0,%eax
 a9e:	eb 26                	jmp    ac6 <morecore+0x62>
  hp = (Header*)p;
 aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 aa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa9:	8b 55 08             	mov    0x8(%ebp),%edx
 aac:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab2:	83 c0 08             	add    $0x8,%eax
 ab5:	83 ec 0c             	sub    $0xc,%esp
 ab8:	50                   	push   %eax
 ab9:	e8 c0 fe ff ff       	call   97e <free>
 abe:	83 c4 10             	add    $0x10,%esp
  return freep;
 ac1:	a1 0c 0f 00 00       	mov    0xf0c,%eax
}
 ac6:	c9                   	leave  
 ac7:	c3                   	ret    

00000ac8 <malloc>:

void*
malloc(uint nbytes)
{
 ac8:	f3 0f 1e fb          	endbr32 
 acc:	55                   	push   %ebp
 acd:	89 e5                	mov    %esp,%ebp
 acf:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ad2:	8b 45 08             	mov    0x8(%ebp),%eax
 ad5:	83 c0 07             	add    $0x7,%eax
 ad8:	c1 e8 03             	shr    $0x3,%eax
 adb:	83 c0 01             	add    $0x1,%eax
 ade:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 ae1:	a1 0c 0f 00 00       	mov    0xf0c,%eax
 ae6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ae9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 aed:	75 23                	jne    b12 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 aef:	c7 45 f0 04 0f 00 00 	movl   $0xf04,-0x10(%ebp)
 af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 af9:	a3 0c 0f 00 00       	mov    %eax,0xf0c
 afe:	a1 0c 0f 00 00       	mov    0xf0c,%eax
 b03:	a3 04 0f 00 00       	mov    %eax,0xf04
    base.s.size = 0;
 b08:	c7 05 08 0f 00 00 00 	movl   $0x0,0xf08
 b0f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b15:	8b 00                	mov    (%eax),%eax
 b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1d:	8b 40 04             	mov    0x4(%eax),%eax
 b20:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b23:	77 4d                	ja     b72 <malloc+0xaa>
      if(p->s.size == nunits)
 b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b28:	8b 40 04             	mov    0x4(%eax),%eax
 b2b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b2e:	75 0c                	jne    b3c <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b33:	8b 10                	mov    (%eax),%edx
 b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b38:	89 10                	mov    %edx,(%eax)
 b3a:	eb 26                	jmp    b62 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3f:	8b 40 04             	mov    0x4(%eax),%eax
 b42:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b45:	89 c2                	mov    %eax,%edx
 b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b50:	8b 40 04             	mov    0x4(%eax),%eax
 b53:	c1 e0 03             	shl    $0x3,%eax
 b56:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b5f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b65:	a3 0c 0f 00 00       	mov    %eax,0xf0c
      return (void*)(p + 1);
 b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b6d:	83 c0 08             	add    $0x8,%eax
 b70:	eb 3b                	jmp    bad <malloc+0xe5>
    }
    if(p == freep)
 b72:	a1 0c 0f 00 00       	mov    0xf0c,%eax
 b77:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b7a:	75 1e                	jne    b9a <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 b7c:	83 ec 0c             	sub    $0xc,%esp
 b7f:	ff 75 ec             	pushl  -0x14(%ebp)
 b82:	e8 dd fe ff ff       	call   a64 <morecore>
 b87:	83 c4 10             	add    $0x10,%esp
 b8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b91:	75 07                	jne    b9a <malloc+0xd2>
        return 0;
 b93:	b8 00 00 00 00       	mov    $0x0,%eax
 b98:	eb 13                	jmp    bad <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba3:	8b 00                	mov    (%eax),%eax
 ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ba8:	e9 6d ff ff ff       	jmp    b1a <malloc+0x52>
  }
}
 bad:	c9                   	leave  
 bae:	c3                   	ret    
