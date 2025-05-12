
_test1:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "pstat.h"

#define WORK 50000000
#define SLEEP_TIME 50

void workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++) j += i * j + 1;
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 11                	jmp    27 <workload+0x27>
  16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  19:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f8             	add    %eax,-0x8(%ebp)
  23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	7c e7                	jl     16 <workload+0x16>
}
  2f:	90                   	nop
  30:	90                   	nop
  31:	c9                   	leave  
  32:	c3                   	ret    

00000033 <main>:

int main(void) {
  33:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  37:	83 e4 f0             	and    $0xfffffff0,%esp
  3a:	ff 71 fc             	push   -0x4(%ecx)
  3d:	55                   	push   %ebp
  3e:	89 e5                	mov    %esp,%ebp
  40:	51                   	push   %ecx
  41:	81 ec 24 0c 00 00    	sub    $0xc24,%esp
  struct pstat ps;

  printf(1, "==== MLFQ TEST (과제 1번 전용) ====\n");
  47:	83 ec 08             	sub    $0x8,%esp
  4a:	68 64 0b 00 00       	push   $0xb64
  4f:	6a 01                	push   $0x1
  51:	e8 56 07 00 00       	call   7ac <printf>
  56:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(1);
  59:	83 ec 0c             	sub    $0xc,%esp
  5c:	6a 01                	push   $0x1
  5e:	e8 65 06 00 00       	call   6c8 <setSchedPolicy>
  63:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < 3; i++) {
  66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  6d:	e9 08 02 00 00       	jmp    27a <main+0x247>
    int pid = fork();
  72:	e8 a9 05 00 00       	call   620 <fork>
  77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (pid < 0) {
  7a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  7e:	79 1a                	jns    9a <main+0x67>
      printf(1, "fork 실패! i=%d\n", i);
  80:	83 ec 04             	sub    $0x4,%esp
  83:	ff 75 f4             	push   -0xc(%ebp)
  86:	68 8e 0b 00 00       	push   $0xb8e
  8b:	6a 01                	push   $0x1
  8d:	e8 1a 07 00 00       	call   7ac <printf>
  92:	83 c4 10             	add    $0x10,%esp
      continue;
  95:	e9 dc 01 00 00       	jmp    276 <main+0x243>
    }
    if (pid == 0) {
  9a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  9e:	0f 85 d2 01 00 00    	jne    276 <main+0x243>
      if (i == 0) {
  a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a8:	75 3f                	jne    e9 <main+0xb6>
        workload(WORK); sleep(SLEEP_TIME);
  aa:	83 ec 0c             	sub    $0xc,%esp
  ad:	68 80 f0 fa 02       	push   $0x2faf080
  b2:	e8 49 ff ff ff       	call   0 <workload>
  b7:	83 c4 10             	add    $0x10,%esp
  ba:	83 ec 0c             	sub    $0xc,%esp
  bd:	6a 32                	push   $0x32
  bf:	e8 f4 05 00 00       	call   6b8 <sleep>
  c4:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
  c7:	83 ec 0c             	sub    $0xc,%esp
  ca:	68 00 e1 f5 05       	push   $0x5f5e100
  cf:	e8 2c ff ff ff       	call   0 <workload>
  d4:	83 c4 10             	add    $0x10,%esp
  d7:	83 ec 0c             	sub    $0xc,%esp
  da:	6a 32                	push   $0x32
  dc:	e8 d7 05 00 00       	call   6b8 <sleep>
  e1:	83 c4 10             	add    $0x10,%esp
  e4:	e9 88 01 00 00       	jmp    271 <main+0x23e>
      } else if (i == 1) {
  e9:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  ed:	0f 85 96 00 00 00    	jne    189 <main+0x156>
        workload(WORK); sleep(SLEEP_TIME);
  f3:	83 ec 0c             	sub    $0xc,%esp
  f6:	68 80 f0 fa 02       	push   $0x2faf080
  fb:	e8 00 ff ff ff       	call   0 <workload>
 100:	83 c4 10             	add    $0x10,%esp
 103:	83 ec 0c             	sub    $0xc,%esp
 106:	6a 32                	push   $0x32
 108:	e8 ab 05 00 00       	call   6b8 <sleep>
 10d:	83 c4 10             	add    $0x10,%esp
        workload(WORK); sleep(SLEEP_TIME);
 110:	83 ec 0c             	sub    $0xc,%esp
 113:	68 80 f0 fa 02       	push   $0x2faf080
 118:	e8 e3 fe ff ff       	call   0 <workload>
 11d:	83 c4 10             	add    $0x10,%esp
 120:	83 ec 0c             	sub    $0xc,%esp
 123:	6a 32                	push   $0x32
 125:	e8 8e 05 00 00       	call   6b8 <sleep>
 12a:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
 12d:	83 ec 0c             	sub    $0xc,%esp
 130:	68 00 e1 f5 05       	push   $0x5f5e100
 135:	e8 c6 fe ff ff       	call   0 <workload>
 13a:	83 c4 10             	add    $0x10,%esp
 13d:	83 ec 0c             	sub    $0xc,%esp
 140:	6a 32                	push   $0x32
 142:	e8 71 05 00 00       	call   6b8 <sleep>
 147:	83 c4 10             	add    $0x10,%esp
        workload(WORK); sleep(SLEEP_TIME);
 14a:	83 ec 0c             	sub    $0xc,%esp
 14d:	68 80 f0 fa 02       	push   $0x2faf080
 152:	e8 a9 fe ff ff       	call   0 <workload>
 157:	83 c4 10             	add    $0x10,%esp
 15a:	83 ec 0c             	sub    $0xc,%esp
 15d:	6a 32                	push   $0x32
 15f:	e8 54 05 00 00       	call   6b8 <sleep>
 164:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 3); sleep(SLEEP_TIME);
 167:	83 ec 0c             	sub    $0xc,%esp
 16a:	68 80 d1 f0 08       	push   $0x8f0d180
 16f:	e8 8c fe ff ff       	call   0 <workload>
 174:	83 c4 10             	add    $0x10,%esp
 177:	83 ec 0c             	sub    $0xc,%esp
 17a:	6a 32                	push   $0x32
 17c:	e8 37 05 00 00       	call   6b8 <sleep>
 181:	83 c4 10             	add    $0x10,%esp
 184:	e9 e8 00 00 00       	jmp    271 <main+0x23e>
      } else {
        workload(WORK); sleep(SLEEP_TIME);
 189:	83 ec 0c             	sub    $0xc,%esp
 18c:	68 80 f0 fa 02       	push   $0x2faf080
 191:	e8 6a fe ff ff       	call   0 <workload>
 196:	83 c4 10             	add    $0x10,%esp
 199:	83 ec 0c             	sub    $0xc,%esp
 19c:	6a 32                	push   $0x32
 19e:	e8 15 05 00 00       	call   6b8 <sleep>
 1a3:	83 c4 10             	add    $0x10,%esp
        workload(WORK); sleep(SLEEP_TIME);
 1a6:	83 ec 0c             	sub    $0xc,%esp
 1a9:	68 80 f0 fa 02       	push   $0x2faf080
 1ae:	e8 4d fe ff ff       	call   0 <workload>
 1b3:	83 c4 10             	add    $0x10,%esp
 1b6:	83 ec 0c             	sub    $0xc,%esp
 1b9:	6a 32                	push   $0x32
 1bb:	e8 f8 04 00 00       	call   6b8 <sleep>
 1c0:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
 1c3:	83 ec 0c             	sub    $0xc,%esp
 1c6:	68 00 e1 f5 05       	push   $0x5f5e100
 1cb:	e8 30 fe ff ff       	call   0 <workload>
 1d0:	83 c4 10             	add    $0x10,%esp
 1d3:	83 ec 0c             	sub    $0xc,%esp
 1d6:	6a 32                	push   $0x32
 1d8:	e8 db 04 00 00       	call   6b8 <sleep>
 1dd:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 3); sleep(SLEEP_TIME);
 1e0:	83 ec 0c             	sub    $0xc,%esp
 1e3:	68 80 d1 f0 08       	push   $0x8f0d180
 1e8:	e8 13 fe ff ff       	call   0 <workload>
 1ed:	83 c4 10             	add    $0x10,%esp
 1f0:	83 ec 0c             	sub    $0xc,%esp
 1f3:	6a 32                	push   $0x32
 1f5:	e8 be 04 00 00       	call   6b8 <sleep>
 1fa:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
 1fd:	83 ec 0c             	sub    $0xc,%esp
 200:	68 00 e1 f5 05       	push   $0x5f5e100
 205:	e8 f6 fd ff ff       	call   0 <workload>
 20a:	83 c4 10             	add    $0x10,%esp
 20d:	83 ec 0c             	sub    $0xc,%esp
 210:	6a 32                	push   $0x32
 212:	e8 a1 04 00 00       	call   6b8 <sleep>
 217:	83 c4 10             	add    $0x10,%esp
        workload(WORK); sleep(SLEEP_TIME);
 21a:	83 ec 0c             	sub    $0xc,%esp
 21d:	68 80 f0 fa 02       	push   $0x2faf080
 222:	e8 d9 fd ff ff       	call   0 <workload>
 227:	83 c4 10             	add    $0x10,%esp
 22a:	83 ec 0c             	sub    $0xc,%esp
 22d:	6a 32                	push   $0x32
 22f:	e8 84 04 00 00       	call   6b8 <sleep>
 234:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 2); sleep(SLEEP_TIME);
 237:	83 ec 0c             	sub    $0xc,%esp
 23a:	68 00 e1 f5 05       	push   $0x5f5e100
 23f:	e8 bc fd ff ff       	call   0 <workload>
 244:	83 c4 10             	add    $0x10,%esp
 247:	83 ec 0c             	sub    $0xc,%esp
 24a:	6a 32                	push   $0x32
 24c:	e8 67 04 00 00       	call   6b8 <sleep>
 251:	83 c4 10             	add    $0x10,%esp
        workload(WORK * 3); sleep(SLEEP_TIME);
 254:	83 ec 0c             	sub    $0xc,%esp
 257:	68 80 d1 f0 08       	push   $0x8f0d180
 25c:	e8 9f fd ff ff       	call   0 <workload>
 261:	83 c4 10             	add    $0x10,%esp
 264:	83 ec 0c             	sub    $0xc,%esp
 267:	6a 32                	push   $0x32
 269:	e8 4a 04 00 00       	call   6b8 <sleep>
 26e:	83 c4 10             	add    $0x10,%esp
      }
      exit();
 271:	e8 b2 03 00 00       	call   628 <exit>
  for (int i = 0; i < 3; i++) {
 276:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 27a:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 27e:	0f 8e ee fd ff ff    	jle    72 <main+0x3f>
    }
  }

  for (int i = 0; i < 3; i++) wait();
 284:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 28b:	eb 09                	jmp    296 <main+0x263>
 28d:	e8 9e 03 00 00       	call   630 <wait>
 292:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 296:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 29a:	7e f1                	jle    28d <main+0x25a>

  printf(1, "\n==== getpinfo 결과 ====\n");
 29c:	83 ec 08             	sub    $0x8,%esp
 29f:	68 a1 0b 00 00       	push   $0xba1
 2a4:	6a 01                	push   $0x1
 2a6:	e8 01 05 00 00       	call   7ac <printf>
 2ab:	83 c4 10             	add    $0x10,%esp
  if (getpinfo(&ps) < 0) {
 2ae:	83 ec 0c             	sub    $0xc,%esp
 2b1:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
 2b7:	50                   	push   %eax
 2b8:	e8 13 04 00 00       	call   6d0 <getpinfo>
 2bd:	83 c4 10             	add    $0x10,%esp
 2c0:	85 c0                	test   %eax,%eax
 2c2:	79 17                	jns    2db <main+0x2a8>
    printf(1, "getpinfo 실패\n");
 2c4:	83 ec 08             	sub    $0x8,%esp
 2c7:	68 bd 0b 00 00       	push   $0xbbd
 2cc:	6a 01                	push   $0x1
 2ce:	e8 d9 04 00 00       	call   7ac <printf>
 2d3:	83 c4 10             	add    $0x10,%esp
    exit();
 2d6:	e8 4d 03 00 00       	call   628 <exit>
  }

  for (int i = 0; i < NPROC; i++) {
 2db:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 2e2:	e9 c9 00 00 00       	jmp    3b0 <main+0x37d>
    if (ps.inuse[i] && ps.pid[i] > 2) {
 2e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2ea:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 2f1:	85 c0                	test   %eax,%eax
 2f3:	0f 84 b3 00 00 00    	je     3ac <main+0x379>
 2f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2fc:	83 c0 40             	add    $0x40,%eax
 2ff:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 306:	83 f8 02             	cmp    $0x2,%eax
 309:	0f 8e 9d 00 00 00    	jle    3ac <main+0x379>
      printf(1, "[pid %d] 현재 Q: Q%d\n", ps.pid[i], ps.priority[i]);
 30f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 312:	83 e8 80             	sub    $0xffffff80,%eax
 315:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 31c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 31f:	83 c0 40             	add    $0x40,%eax
 322:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 329:	52                   	push   %edx
 32a:	50                   	push   %eax
 32b:	68 ce 0b 00 00       	push   $0xbce
 330:	6a 01                	push   $0x1
 332:	e8 75 04 00 00       	call   7ac <printf>
 337:	83 c4 10             	add    $0x10,%esp
      printf(1, "큐 이동 경로:\n");
 33a:	83 ec 08             	sub    $0x8,%esp
 33d:	68 e6 0b 00 00       	push   $0xbe6
 342:	6a 01                	push   $0x1
 344:	e8 63 04 00 00       	call   7ac <printf>
 349:	83 c4 10             	add    $0x10,%esp
      for (int q = 3; q >= 0; q--) {
 34c:	c7 45 e8 03 00 00 00 	movl   $0x3,-0x18(%ebp)
 353:	eb 51                	jmp    3a6 <main+0x373>
        printf(1, " Q%d: ticks=%d, wait=%d\n", q, ps.ticks[i][q], ps.wait_ticks[i][q]);
 355:	8b 45 ec             	mov    -0x14(%ebp),%eax
 358:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 35f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 362:	01 d0                	add    %edx,%eax
 364:	05 00 02 00 00       	add    $0x200,%eax
 369:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 370:	8b 45 ec             	mov    -0x14(%ebp),%eax
 373:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
 37a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 37d:	01 c8                	add    %ecx,%eax
 37f:	05 00 01 00 00       	add    $0x100,%eax
 384:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 38b:	83 ec 0c             	sub    $0xc,%esp
 38e:	52                   	push   %edx
 38f:	50                   	push   %eax
 390:	ff 75 e8             	push   -0x18(%ebp)
 393:	68 fa 0b 00 00       	push   $0xbfa
 398:	6a 01                	push   $0x1
 39a:	e8 0d 04 00 00       	call   7ac <printf>
 39f:	83 c4 20             	add    $0x20,%esp
      for (int q = 3; q >= 0; q--) {
 3a2:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
 3a6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 3aa:	79 a9                	jns    355 <main+0x322>
  for (int i = 0; i < NPROC; i++) {
 3ac:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 3b0:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
 3b4:	0f 8e 2d ff ff ff    	jle    2e7 <main+0x2b4>
      }
    }
  }

  printf(1, "\n==== MLFQ 테스트 종료 ====\n");
 3ba:	83 ec 08             	sub    $0x8,%esp
 3bd:	68 14 0c 00 00       	push   $0xc14
 3c2:	6a 01                	push   $0x1
 3c4:	e8 e3 03 00 00       	call   7ac <printf>
 3c9:	83 c4 10             	add    $0x10,%esp
  exit();
 3cc:	e8 57 02 00 00       	call   628 <exit>

000003d1 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3d1:	55                   	push   %ebp
 3d2:	89 e5                	mov    %esp,%ebp
 3d4:	57                   	push   %edi
 3d5:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3d9:	8b 55 10             	mov    0x10(%ebp),%edx
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	89 cb                	mov    %ecx,%ebx
 3e1:	89 df                	mov    %ebx,%edi
 3e3:	89 d1                	mov    %edx,%ecx
 3e5:	fc                   	cld    
 3e6:	f3 aa                	rep stos %al,%es:(%edi)
 3e8:	89 ca                	mov    %ecx,%edx
 3ea:	89 fb                	mov    %edi,%ebx
 3ec:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3ef:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3f2:	90                   	nop
 3f3:	5b                   	pop    %ebx
 3f4:	5f                   	pop    %edi
 3f5:	5d                   	pop    %ebp
 3f6:	c3                   	ret    

000003f7 <strcpy>:



char*
strcpy(char *s, char *t)
{
 3f7:	55                   	push   %ebp
 3f8:	89 e5                	mov    %esp,%ebp
 3fa:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3fd:	8b 45 08             	mov    0x8(%ebp),%eax
 400:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 403:	90                   	nop
 404:	8b 55 0c             	mov    0xc(%ebp),%edx
 407:	8d 42 01             	lea    0x1(%edx),%eax
 40a:	89 45 0c             	mov    %eax,0xc(%ebp)
 40d:	8b 45 08             	mov    0x8(%ebp),%eax
 410:	8d 48 01             	lea    0x1(%eax),%ecx
 413:	89 4d 08             	mov    %ecx,0x8(%ebp)
 416:	0f b6 12             	movzbl (%edx),%edx
 419:	88 10                	mov    %dl,(%eax)
 41b:	0f b6 00             	movzbl (%eax),%eax
 41e:	84 c0                	test   %al,%al
 420:	75 e2                	jne    404 <strcpy+0xd>
    ;
  return os;
 422:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 425:	c9                   	leave  
 426:	c3                   	ret    

00000427 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 427:	55                   	push   %ebp
 428:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 42a:	eb 08                	jmp    434 <strcmp+0xd>
    p++, q++;
 42c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 430:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 434:	8b 45 08             	mov    0x8(%ebp),%eax
 437:	0f b6 00             	movzbl (%eax),%eax
 43a:	84 c0                	test   %al,%al
 43c:	74 10                	je     44e <strcmp+0x27>
 43e:	8b 45 08             	mov    0x8(%ebp),%eax
 441:	0f b6 10             	movzbl (%eax),%edx
 444:	8b 45 0c             	mov    0xc(%ebp),%eax
 447:	0f b6 00             	movzbl (%eax),%eax
 44a:	38 c2                	cmp    %al,%dl
 44c:	74 de                	je     42c <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 44e:	8b 45 08             	mov    0x8(%ebp),%eax
 451:	0f b6 00             	movzbl (%eax),%eax
 454:	0f b6 d0             	movzbl %al,%edx
 457:	8b 45 0c             	mov    0xc(%ebp),%eax
 45a:	0f b6 00             	movzbl (%eax),%eax
 45d:	0f b6 c8             	movzbl %al,%ecx
 460:	89 d0                	mov    %edx,%eax
 462:	29 c8                	sub    %ecx,%eax
}
 464:	5d                   	pop    %ebp
 465:	c3                   	ret    

00000466 <strlen>:

uint
strlen(char *s)
{
 466:	55                   	push   %ebp
 467:	89 e5                	mov    %esp,%ebp
 469:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 46c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 473:	eb 04                	jmp    479 <strlen+0x13>
 475:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 479:	8b 55 fc             	mov    -0x4(%ebp),%edx
 47c:	8b 45 08             	mov    0x8(%ebp),%eax
 47f:	01 d0                	add    %edx,%eax
 481:	0f b6 00             	movzbl (%eax),%eax
 484:	84 c0                	test   %al,%al
 486:	75 ed                	jne    475 <strlen+0xf>
    ;
  return n;
 488:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 48b:	c9                   	leave  
 48c:	c3                   	ret    

0000048d <memset>:

void*
memset(void *dst, int c, uint n)
{
 48d:	55                   	push   %ebp
 48e:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 490:	8b 45 10             	mov    0x10(%ebp),%eax
 493:	50                   	push   %eax
 494:	ff 75 0c             	push   0xc(%ebp)
 497:	ff 75 08             	push   0x8(%ebp)
 49a:	e8 32 ff ff ff       	call   3d1 <stosb>
 49f:	83 c4 0c             	add    $0xc,%esp
  return dst;
 4a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4a5:	c9                   	leave  
 4a6:	c3                   	ret    

000004a7 <strchr>:

char*
strchr(const char *s, char c)
{
 4a7:	55                   	push   %ebp
 4a8:	89 e5                	mov    %esp,%ebp
 4aa:	83 ec 04             	sub    $0x4,%esp
 4ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4b3:	eb 14                	jmp    4c9 <strchr+0x22>
    if(*s == c)
 4b5:	8b 45 08             	mov    0x8(%ebp),%eax
 4b8:	0f b6 00             	movzbl (%eax),%eax
 4bb:	38 45 fc             	cmp    %al,-0x4(%ebp)
 4be:	75 05                	jne    4c5 <strchr+0x1e>
      return (char*)s;
 4c0:	8b 45 08             	mov    0x8(%ebp),%eax
 4c3:	eb 13                	jmp    4d8 <strchr+0x31>
  for(; *s; s++)
 4c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4c9:	8b 45 08             	mov    0x8(%ebp),%eax
 4cc:	0f b6 00             	movzbl (%eax),%eax
 4cf:	84 c0                	test   %al,%al
 4d1:	75 e2                	jne    4b5 <strchr+0xe>
  return 0;
 4d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4d8:	c9                   	leave  
 4d9:	c3                   	ret    

000004da <gets>:

char*
gets(char *buf, int max)
{
 4da:	55                   	push   %ebp
 4db:	89 e5                	mov    %esp,%ebp
 4dd:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4e7:	eb 42                	jmp    52b <gets+0x51>
    cc = read(0, &c, 1);
 4e9:	83 ec 04             	sub    $0x4,%esp
 4ec:	6a 01                	push   $0x1
 4ee:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4f1:	50                   	push   %eax
 4f2:	6a 00                	push   $0x0
 4f4:	e8 47 01 00 00       	call   640 <read>
 4f9:	83 c4 10             	add    $0x10,%esp
 4fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 503:	7e 33                	jle    538 <gets+0x5e>
      break;
    buf[i++] = c;
 505:	8b 45 f4             	mov    -0xc(%ebp),%eax
 508:	8d 50 01             	lea    0x1(%eax),%edx
 50b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 50e:	89 c2                	mov    %eax,%edx
 510:	8b 45 08             	mov    0x8(%ebp),%eax
 513:	01 c2                	add    %eax,%edx
 515:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 519:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 51b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 51f:	3c 0a                	cmp    $0xa,%al
 521:	74 16                	je     539 <gets+0x5f>
 523:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 527:	3c 0d                	cmp    $0xd,%al
 529:	74 0e                	je     539 <gets+0x5f>
  for(i=0; i+1 < max; ){
 52b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52e:	83 c0 01             	add    $0x1,%eax
 531:	39 45 0c             	cmp    %eax,0xc(%ebp)
 534:	7f b3                	jg     4e9 <gets+0xf>
 536:	eb 01                	jmp    539 <gets+0x5f>
      break;
 538:	90                   	nop
      break;
  }
  buf[i] = '\0';
 539:	8b 55 f4             	mov    -0xc(%ebp),%edx
 53c:	8b 45 08             	mov    0x8(%ebp),%eax
 53f:	01 d0                	add    %edx,%eax
 541:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 544:	8b 45 08             	mov    0x8(%ebp),%eax
}
 547:	c9                   	leave  
 548:	c3                   	ret    

00000549 <stat>:

int
stat(char *n, struct stat *st)
{
 549:	55                   	push   %ebp
 54a:	89 e5                	mov    %esp,%ebp
 54c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 54f:	83 ec 08             	sub    $0x8,%esp
 552:	6a 00                	push   $0x0
 554:	ff 75 08             	push   0x8(%ebp)
 557:	e8 0c 01 00 00       	call   668 <open>
 55c:	83 c4 10             	add    $0x10,%esp
 55f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 562:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 566:	79 07                	jns    56f <stat+0x26>
    return -1;
 568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 56d:	eb 25                	jmp    594 <stat+0x4b>
  r = fstat(fd, st);
 56f:	83 ec 08             	sub    $0x8,%esp
 572:	ff 75 0c             	push   0xc(%ebp)
 575:	ff 75 f4             	push   -0xc(%ebp)
 578:	e8 03 01 00 00       	call   680 <fstat>
 57d:	83 c4 10             	add    $0x10,%esp
 580:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 583:	83 ec 0c             	sub    $0xc,%esp
 586:	ff 75 f4             	push   -0xc(%ebp)
 589:	e8 c2 00 00 00       	call   650 <close>
 58e:	83 c4 10             	add    $0x10,%esp
  return r;
 591:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 594:	c9                   	leave  
 595:	c3                   	ret    

00000596 <atoi>:

int
atoi(const char *s)
{
 596:	55                   	push   %ebp
 597:	89 e5                	mov    %esp,%ebp
 599:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 59c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5a3:	eb 25                	jmp    5ca <atoi+0x34>
    n = n*10 + *s++ - '0';
 5a5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5a8:	89 d0                	mov    %edx,%eax
 5aa:	c1 e0 02             	shl    $0x2,%eax
 5ad:	01 d0                	add    %edx,%eax
 5af:	01 c0                	add    %eax,%eax
 5b1:	89 c1                	mov    %eax,%ecx
 5b3:	8b 45 08             	mov    0x8(%ebp),%eax
 5b6:	8d 50 01             	lea    0x1(%eax),%edx
 5b9:	89 55 08             	mov    %edx,0x8(%ebp)
 5bc:	0f b6 00             	movzbl (%eax),%eax
 5bf:	0f be c0             	movsbl %al,%eax
 5c2:	01 c8                	add    %ecx,%eax
 5c4:	83 e8 30             	sub    $0x30,%eax
 5c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5ca:	8b 45 08             	mov    0x8(%ebp),%eax
 5cd:	0f b6 00             	movzbl (%eax),%eax
 5d0:	3c 2f                	cmp    $0x2f,%al
 5d2:	7e 0a                	jle    5de <atoi+0x48>
 5d4:	8b 45 08             	mov    0x8(%ebp),%eax
 5d7:	0f b6 00             	movzbl (%eax),%eax
 5da:	3c 39                	cmp    $0x39,%al
 5dc:	7e c7                	jle    5a5 <atoi+0xf>
  return n;
 5de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5e1:	c9                   	leave  
 5e2:	c3                   	ret    

000005e3 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 5e3:	55                   	push   %ebp
 5e4:	89 e5                	mov    %esp,%ebp
 5e6:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 5e9:	8b 45 08             	mov    0x8(%ebp),%eax
 5ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5f5:	eb 17                	jmp    60e <memmove+0x2b>
    *dst++ = *src++;
 5f7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5fa:	8d 42 01             	lea    0x1(%edx),%eax
 5fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
 600:	8b 45 fc             	mov    -0x4(%ebp),%eax
 603:	8d 48 01             	lea    0x1(%eax),%ecx
 606:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 609:	0f b6 12             	movzbl (%edx),%edx
 60c:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 60e:	8b 45 10             	mov    0x10(%ebp),%eax
 611:	8d 50 ff             	lea    -0x1(%eax),%edx
 614:	89 55 10             	mov    %edx,0x10(%ebp)
 617:	85 c0                	test   %eax,%eax
 619:	7f dc                	jg     5f7 <memmove+0x14>
  return vdst;
 61b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 61e:	c9                   	leave  
 61f:	c3                   	ret    

00000620 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 620:	b8 01 00 00 00       	mov    $0x1,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <exit>:
SYSCALL(exit)
 628:	b8 02 00 00 00       	mov    $0x2,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <wait>:
SYSCALL(wait)
 630:	b8 03 00 00 00       	mov    $0x3,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <pipe>:
SYSCALL(pipe)
 638:	b8 04 00 00 00       	mov    $0x4,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <read>:
SYSCALL(read)
 640:	b8 05 00 00 00       	mov    $0x5,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <write>:
SYSCALL(write)
 648:	b8 10 00 00 00       	mov    $0x10,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <close>:
SYSCALL(close)
 650:	b8 15 00 00 00       	mov    $0x15,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <kill>:
SYSCALL(kill)
 658:	b8 06 00 00 00       	mov    $0x6,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <exec>:
SYSCALL(exec)
 660:	b8 07 00 00 00       	mov    $0x7,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <open>:
SYSCALL(open)
 668:	b8 0f 00 00 00       	mov    $0xf,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <mknod>:
SYSCALL(mknod)
 670:	b8 11 00 00 00       	mov    $0x11,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <unlink>:
SYSCALL(unlink)
 678:	b8 12 00 00 00       	mov    $0x12,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <fstat>:
SYSCALL(fstat)
 680:	b8 08 00 00 00       	mov    $0x8,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <link>:
SYSCALL(link)
 688:	b8 13 00 00 00       	mov    $0x13,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <mkdir>:
SYSCALL(mkdir)
 690:	b8 14 00 00 00       	mov    $0x14,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <chdir>:
SYSCALL(chdir)
 698:	b8 09 00 00 00       	mov    $0x9,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret    

000006a0 <dup>:
SYSCALL(dup)
 6a0:	b8 0a 00 00 00       	mov    $0xa,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret    

000006a8 <getpid>:
SYSCALL(getpid)
 6a8:	b8 0b 00 00 00       	mov    $0xb,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret    

000006b0 <sbrk>:
SYSCALL(sbrk)
 6b0:	b8 0c 00 00 00       	mov    $0xc,%eax
 6b5:	cd 40                	int    $0x40
 6b7:	c3                   	ret    

000006b8 <sleep>:
SYSCALL(sleep)
 6b8:	b8 0d 00 00 00       	mov    $0xd,%eax
 6bd:	cd 40                	int    $0x40
 6bf:	c3                   	ret    

000006c0 <uptime>:
SYSCALL(uptime)
 6c0:	b8 0e 00 00 00       	mov    $0xe,%eax
 6c5:	cd 40                	int    $0x40
 6c7:	c3                   	ret    

000006c8 <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 6c8:	b8 16 00 00 00       	mov    $0x16,%eax
 6cd:	cd 40                	int    $0x40
 6cf:	c3                   	ret    

000006d0 <getpinfo>:
SYSCALL(getpinfo)
 6d0:	b8 17 00 00 00       	mov    $0x17,%eax
 6d5:	cd 40                	int    $0x40
 6d7:	c3                   	ret    

000006d8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6d8:	55                   	push   %ebp
 6d9:	89 e5                	mov    %esp,%ebp
 6db:	83 ec 18             	sub    $0x18,%esp
 6de:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6e4:	83 ec 04             	sub    $0x4,%esp
 6e7:	6a 01                	push   $0x1
 6e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6ec:	50                   	push   %eax
 6ed:	ff 75 08             	push   0x8(%ebp)
 6f0:	e8 53 ff ff ff       	call   648 <write>
 6f5:	83 c4 10             	add    $0x10,%esp
}
 6f8:	90                   	nop
 6f9:	c9                   	leave  
 6fa:	c3                   	ret    

000006fb <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6fb:	55                   	push   %ebp
 6fc:	89 e5                	mov    %esp,%ebp
 6fe:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 701:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 708:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 70c:	74 17                	je     725 <printint+0x2a>
 70e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 712:	79 11                	jns    725 <printint+0x2a>
    neg = 1;
 714:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 71b:	8b 45 0c             	mov    0xc(%ebp),%eax
 71e:	f7 d8                	neg    %eax
 720:	89 45 ec             	mov    %eax,-0x14(%ebp)
 723:	eb 06                	jmp    72b <printint+0x30>
  } else {
    x = xx;
 725:	8b 45 0c             	mov    0xc(%ebp),%eax
 728:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 72b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 732:	8b 4d 10             	mov    0x10(%ebp),%ecx
 735:	8b 45 ec             	mov    -0x14(%ebp),%eax
 738:	ba 00 00 00 00       	mov    $0x0,%edx
 73d:	f7 f1                	div    %ecx
 73f:	89 d1                	mov    %edx,%ecx
 741:	8b 45 f4             	mov    -0xc(%ebp),%eax
 744:	8d 50 01             	lea    0x1(%eax),%edx
 747:	89 55 f4             	mov    %edx,-0xc(%ebp)
 74a:	0f b6 91 a4 0e 00 00 	movzbl 0xea4(%ecx),%edx
 751:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 755:	8b 4d 10             	mov    0x10(%ebp),%ecx
 758:	8b 45 ec             	mov    -0x14(%ebp),%eax
 75b:	ba 00 00 00 00       	mov    $0x0,%edx
 760:	f7 f1                	div    %ecx
 762:	89 45 ec             	mov    %eax,-0x14(%ebp)
 765:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 769:	75 c7                	jne    732 <printint+0x37>
  if(neg)
 76b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 76f:	74 2d                	je     79e <printint+0xa3>
    buf[i++] = '-';
 771:	8b 45 f4             	mov    -0xc(%ebp),%eax
 774:	8d 50 01             	lea    0x1(%eax),%edx
 777:	89 55 f4             	mov    %edx,-0xc(%ebp)
 77a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 77f:	eb 1d                	jmp    79e <printint+0xa3>
    putc(fd, buf[i]);
 781:	8d 55 dc             	lea    -0x24(%ebp),%edx
 784:	8b 45 f4             	mov    -0xc(%ebp),%eax
 787:	01 d0                	add    %edx,%eax
 789:	0f b6 00             	movzbl (%eax),%eax
 78c:	0f be c0             	movsbl %al,%eax
 78f:	83 ec 08             	sub    $0x8,%esp
 792:	50                   	push   %eax
 793:	ff 75 08             	push   0x8(%ebp)
 796:	e8 3d ff ff ff       	call   6d8 <putc>
 79b:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 79e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a6:	79 d9                	jns    781 <printint+0x86>
}
 7a8:	90                   	nop
 7a9:	90                   	nop
 7aa:	c9                   	leave  
 7ab:	c3                   	ret    

000007ac <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7ac:	55                   	push   %ebp
 7ad:	89 e5                	mov    %esp,%ebp
 7af:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7b2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7b9:	8d 45 0c             	lea    0xc(%ebp),%eax
 7bc:	83 c0 04             	add    $0x4,%eax
 7bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7c9:	e9 59 01 00 00       	jmp    927 <printf+0x17b>
    c = fmt[i] & 0xff;
 7ce:	8b 55 0c             	mov    0xc(%ebp),%edx
 7d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d4:	01 d0                	add    %edx,%eax
 7d6:	0f b6 00             	movzbl (%eax),%eax
 7d9:	0f be c0             	movsbl %al,%eax
 7dc:	25 ff 00 00 00       	and    $0xff,%eax
 7e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7e4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7e8:	75 2c                	jne    816 <printf+0x6a>
      if(c == '%'){
 7ea:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ee:	75 0c                	jne    7fc <printf+0x50>
        state = '%';
 7f0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7f7:	e9 27 01 00 00       	jmp    923 <printf+0x177>
      } else {
        putc(fd, c);
 7fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ff:	0f be c0             	movsbl %al,%eax
 802:	83 ec 08             	sub    $0x8,%esp
 805:	50                   	push   %eax
 806:	ff 75 08             	push   0x8(%ebp)
 809:	e8 ca fe ff ff       	call   6d8 <putc>
 80e:	83 c4 10             	add    $0x10,%esp
 811:	e9 0d 01 00 00       	jmp    923 <printf+0x177>
      }
    } else if(state == '%'){
 816:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 81a:	0f 85 03 01 00 00    	jne    923 <printf+0x177>
      if(c == 'd'){
 820:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 824:	75 1e                	jne    844 <printf+0x98>
        printint(fd, *ap, 10, 1);
 826:	8b 45 e8             	mov    -0x18(%ebp),%eax
 829:	8b 00                	mov    (%eax),%eax
 82b:	6a 01                	push   $0x1
 82d:	6a 0a                	push   $0xa
 82f:	50                   	push   %eax
 830:	ff 75 08             	push   0x8(%ebp)
 833:	e8 c3 fe ff ff       	call   6fb <printint>
 838:	83 c4 10             	add    $0x10,%esp
        ap++;
 83b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 83f:	e9 d8 00 00 00       	jmp    91c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 844:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 848:	74 06                	je     850 <printf+0xa4>
 84a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 84e:	75 1e                	jne    86e <printf+0xc2>
        printint(fd, *ap, 16, 0);
 850:	8b 45 e8             	mov    -0x18(%ebp),%eax
 853:	8b 00                	mov    (%eax),%eax
 855:	6a 00                	push   $0x0
 857:	6a 10                	push   $0x10
 859:	50                   	push   %eax
 85a:	ff 75 08             	push   0x8(%ebp)
 85d:	e8 99 fe ff ff       	call   6fb <printint>
 862:	83 c4 10             	add    $0x10,%esp
        ap++;
 865:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 869:	e9 ae 00 00 00       	jmp    91c <printf+0x170>
      } else if(c == 's'){
 86e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 872:	75 43                	jne    8b7 <printf+0x10b>
        s = (char*)*ap;
 874:	8b 45 e8             	mov    -0x18(%ebp),%eax
 877:	8b 00                	mov    (%eax),%eax
 879:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 87c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 880:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 884:	75 25                	jne    8ab <printf+0xff>
          s = "(null)";
 886:	c7 45 f4 36 0c 00 00 	movl   $0xc36,-0xc(%ebp)
        while(*s != 0){
 88d:	eb 1c                	jmp    8ab <printf+0xff>
          putc(fd, *s);
 88f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 892:	0f b6 00             	movzbl (%eax),%eax
 895:	0f be c0             	movsbl %al,%eax
 898:	83 ec 08             	sub    $0x8,%esp
 89b:	50                   	push   %eax
 89c:	ff 75 08             	push   0x8(%ebp)
 89f:	e8 34 fe ff ff       	call   6d8 <putc>
 8a4:	83 c4 10             	add    $0x10,%esp
          s++;
 8a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 8ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ae:	0f b6 00             	movzbl (%eax),%eax
 8b1:	84 c0                	test   %al,%al
 8b3:	75 da                	jne    88f <printf+0xe3>
 8b5:	eb 65                	jmp    91c <printf+0x170>
        }
      } else if(c == 'c'){
 8b7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8bb:	75 1d                	jne    8da <printf+0x12e>
        putc(fd, *ap);
 8bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8c0:	8b 00                	mov    (%eax),%eax
 8c2:	0f be c0             	movsbl %al,%eax
 8c5:	83 ec 08             	sub    $0x8,%esp
 8c8:	50                   	push   %eax
 8c9:	ff 75 08             	push   0x8(%ebp)
 8cc:	e8 07 fe ff ff       	call   6d8 <putc>
 8d1:	83 c4 10             	add    $0x10,%esp
        ap++;
 8d4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8d8:	eb 42                	jmp    91c <printf+0x170>
      } else if(c == '%'){
 8da:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8de:	75 17                	jne    8f7 <printf+0x14b>
        putc(fd, c);
 8e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8e3:	0f be c0             	movsbl %al,%eax
 8e6:	83 ec 08             	sub    $0x8,%esp
 8e9:	50                   	push   %eax
 8ea:	ff 75 08             	push   0x8(%ebp)
 8ed:	e8 e6 fd ff ff       	call   6d8 <putc>
 8f2:	83 c4 10             	add    $0x10,%esp
 8f5:	eb 25                	jmp    91c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8f7:	83 ec 08             	sub    $0x8,%esp
 8fa:	6a 25                	push   $0x25
 8fc:	ff 75 08             	push   0x8(%ebp)
 8ff:	e8 d4 fd ff ff       	call   6d8 <putc>
 904:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 907:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 90a:	0f be c0             	movsbl %al,%eax
 90d:	83 ec 08             	sub    $0x8,%esp
 910:	50                   	push   %eax
 911:	ff 75 08             	push   0x8(%ebp)
 914:	e8 bf fd ff ff       	call   6d8 <putc>
 919:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 91c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 923:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 927:	8b 55 0c             	mov    0xc(%ebp),%edx
 92a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92d:	01 d0                	add    %edx,%eax
 92f:	0f b6 00             	movzbl (%eax),%eax
 932:	84 c0                	test   %al,%al
 934:	0f 85 94 fe ff ff    	jne    7ce <printf+0x22>
    }
  }
}
 93a:	90                   	nop
 93b:	90                   	nop
 93c:	c9                   	leave  
 93d:	c3                   	ret    

0000093e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 93e:	55                   	push   %ebp
 93f:	89 e5                	mov    %esp,%ebp
 941:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 944:	8b 45 08             	mov    0x8(%ebp),%eax
 947:	83 e8 08             	sub    $0x8,%eax
 94a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 94d:	a1 c0 0e 00 00       	mov    0xec0,%eax
 952:	89 45 fc             	mov    %eax,-0x4(%ebp)
 955:	eb 24                	jmp    97b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 957:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95a:	8b 00                	mov    (%eax),%eax
 95c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 95f:	72 12                	jb     973 <free+0x35>
 961:	8b 45 f8             	mov    -0x8(%ebp),%eax
 964:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 967:	77 24                	ja     98d <free+0x4f>
 969:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96c:	8b 00                	mov    (%eax),%eax
 96e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 971:	72 1a                	jb     98d <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 973:	8b 45 fc             	mov    -0x4(%ebp),%eax
 976:	8b 00                	mov    (%eax),%eax
 978:	89 45 fc             	mov    %eax,-0x4(%ebp)
 97b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 981:	76 d4                	jbe    957 <free+0x19>
 983:	8b 45 fc             	mov    -0x4(%ebp),%eax
 986:	8b 00                	mov    (%eax),%eax
 988:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 98b:	73 ca                	jae    957 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 98d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 990:	8b 40 04             	mov    0x4(%eax),%eax
 993:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 99a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99d:	01 c2                	add    %eax,%edx
 99f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a2:	8b 00                	mov    (%eax),%eax
 9a4:	39 c2                	cmp    %eax,%edx
 9a6:	75 24                	jne    9cc <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ab:	8b 50 04             	mov    0x4(%eax),%edx
 9ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b1:	8b 00                	mov    (%eax),%eax
 9b3:	8b 40 04             	mov    0x4(%eax),%eax
 9b6:	01 c2                	add    %eax,%edx
 9b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bb:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c1:	8b 00                	mov    (%eax),%eax
 9c3:	8b 10                	mov    (%eax),%edx
 9c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c8:	89 10                	mov    %edx,(%eax)
 9ca:	eb 0a                	jmp    9d6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cf:	8b 10                	mov    (%eax),%edx
 9d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d9:	8b 40 04             	mov    0x4(%eax),%eax
 9dc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e6:	01 d0                	add    %edx,%eax
 9e8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9eb:	75 20                	jne    a0d <free+0xcf>
    p->s.size += bp->s.size;
 9ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f0:	8b 50 04             	mov    0x4(%eax),%edx
 9f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f6:	8b 40 04             	mov    0x4(%eax),%eax
 9f9:	01 c2                	add    %eax,%edx
 9fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fe:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a01:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a04:	8b 10                	mov    (%eax),%edx
 a06:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a09:	89 10                	mov    %edx,(%eax)
 a0b:	eb 08                	jmp    a15 <free+0xd7>
  } else
    p->s.ptr = bp;
 a0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a10:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a13:	89 10                	mov    %edx,(%eax)
  freep = p;
 a15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a18:	a3 c0 0e 00 00       	mov    %eax,0xec0
}
 a1d:	90                   	nop
 a1e:	c9                   	leave  
 a1f:	c3                   	ret    

00000a20 <morecore>:

static Header*
morecore(uint nu)
{
 a20:	55                   	push   %ebp
 a21:	89 e5                	mov    %esp,%ebp
 a23:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a26:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a2d:	77 07                	ja     a36 <morecore+0x16>
    nu = 4096;
 a2f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a36:	8b 45 08             	mov    0x8(%ebp),%eax
 a39:	c1 e0 03             	shl    $0x3,%eax
 a3c:	83 ec 0c             	sub    $0xc,%esp
 a3f:	50                   	push   %eax
 a40:	e8 6b fc ff ff       	call   6b0 <sbrk>
 a45:	83 c4 10             	add    $0x10,%esp
 a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a4b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a4f:	75 07                	jne    a58 <morecore+0x38>
    return 0;
 a51:	b8 00 00 00 00       	mov    $0x0,%eax
 a56:	eb 26                	jmp    a7e <morecore+0x5e>
  hp = (Header*)p;
 a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a61:	8b 55 08             	mov    0x8(%ebp),%edx
 a64:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6a:	83 c0 08             	add    $0x8,%eax
 a6d:	83 ec 0c             	sub    $0xc,%esp
 a70:	50                   	push   %eax
 a71:	e8 c8 fe ff ff       	call   93e <free>
 a76:	83 c4 10             	add    $0x10,%esp
  return freep;
 a79:	a1 c0 0e 00 00       	mov    0xec0,%eax
}
 a7e:	c9                   	leave  
 a7f:	c3                   	ret    

00000a80 <malloc>:

void*
malloc(uint nbytes)
{
 a80:	55                   	push   %ebp
 a81:	89 e5                	mov    %esp,%ebp
 a83:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a86:	8b 45 08             	mov    0x8(%ebp),%eax
 a89:	83 c0 07             	add    $0x7,%eax
 a8c:	c1 e8 03             	shr    $0x3,%eax
 a8f:	83 c0 01             	add    $0x1,%eax
 a92:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a95:	a1 c0 0e 00 00       	mov    0xec0,%eax
 a9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 aa1:	75 23                	jne    ac6 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 aa3:	c7 45 f0 b8 0e 00 00 	movl   $0xeb8,-0x10(%ebp)
 aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aad:	a3 c0 0e 00 00       	mov    %eax,0xec0
 ab2:	a1 c0 0e 00 00       	mov    0xec0,%eax
 ab7:	a3 b8 0e 00 00       	mov    %eax,0xeb8
    base.s.size = 0;
 abc:	c7 05 bc 0e 00 00 00 	movl   $0x0,0xebc
 ac3:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac9:	8b 00                	mov    (%eax),%eax
 acb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad1:	8b 40 04             	mov    0x4(%eax),%eax
 ad4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ad7:	77 4d                	ja     b26 <malloc+0xa6>
      if(p->s.size == nunits)
 ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adc:	8b 40 04             	mov    0x4(%eax),%eax
 adf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ae2:	75 0c                	jne    af0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae7:	8b 10                	mov    (%eax),%edx
 ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aec:	89 10                	mov    %edx,(%eax)
 aee:	eb 26                	jmp    b16 <malloc+0x96>
      else {
        p->s.size -= nunits;
 af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af3:	8b 40 04             	mov    0x4(%eax),%eax
 af6:	2b 45 ec             	sub    -0x14(%ebp),%eax
 af9:	89 c2                	mov    %eax,%edx
 afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afe:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b04:	8b 40 04             	mov    0x4(%eax),%eax
 b07:	c1 e0 03             	shl    $0x3,%eax
 b0a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b10:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b13:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b19:	a3 c0 0e 00 00       	mov    %eax,0xec0
      return (void*)(p + 1);
 b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b21:	83 c0 08             	add    $0x8,%eax
 b24:	eb 3b                	jmp    b61 <malloc+0xe1>
    }
    if(p == freep)
 b26:	a1 c0 0e 00 00       	mov    0xec0,%eax
 b2b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b2e:	75 1e                	jne    b4e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b30:	83 ec 0c             	sub    $0xc,%esp
 b33:	ff 75 ec             	push   -0x14(%ebp)
 b36:	e8 e5 fe ff ff       	call   a20 <morecore>
 b3b:	83 c4 10             	add    $0x10,%esp
 b3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b45:	75 07                	jne    b4e <malloc+0xce>
        return 0;
 b47:	b8 00 00 00 00       	mov    $0x0,%eax
 b4c:	eb 13                	jmp    b61 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b51:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b57:	8b 00                	mov    (%eax),%eax
 b59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b5c:	e9 6d ff ff ff       	jmp    ace <malloc+0x4e>
  }
}
 b61:	c9                   	leave  
 b62:	c3                   	ret    
