
_test2:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "user.h"
#include "pstat.h"

#define NUM_PROCS 4

int workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++)
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 11                	jmp    27 <workload+0x27>
    j += i * j + 1;
  16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  19:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f8             	add    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++)
  23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	7c e7                	jl     16 <workload+0x16>
  return j;
  2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  32:	c9                   	leave  
  33:	c3                   	ret    

00000034 <main>:

int main(void) {
  34:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  38:	83 e4 f0             	and    $0xfffffff0,%esp
  3b:	ff 71 fc             	push   -0x4(%ecx)
  3e:	55                   	push   %ebp
  3f:	89 e5                	mov    %esp,%ebp
  41:	53                   	push   %ebx
  42:	51                   	push   %ecx
  43:	81 ec 20 0c 00 00    	sub    $0xc20,%esp
  struct pstat st;
  int pids[NUM_PROCS];
  int i;

  printf(1, "\n==== [TEST2: MLFQ w/o tracking] ====\n");
  49:	83 ec 08             	sub    $0x8,%esp
  4c:	68 cc 0a 00 00       	push   $0xacc
  51:	6a 01                	push   $0x1
  53:	e8 ba 06 00 00       	call   712 <printf>
  58:	83 c4 10             	add    $0x10,%esp

  if (setSchedPolicy(2) < 0) {
  5b:	83 ec 0c             	sub    $0xc,%esp
  5e:	6a 02                	push   $0x2
  60:	e8 c9 05 00 00       	call   62e <setSchedPolicy>
  65:	83 c4 10             	add    $0x10,%esp
  68:	85 c0                	test   %eax,%eax
  6a:	79 17                	jns    83 <main+0x4f>
    printf(1, "setSchedPolicy failed!\n");
  6c:	83 ec 08             	sub    $0x8,%esp
  6f:	68 f3 0a 00 00       	push   $0xaf3
  74:	6a 01                	push   $0x1
  76:	e8 97 06 00 00       	call   712 <printf>
  7b:	83 c4 10             	add    $0x10,%esp
    exit();
  7e:	e8 0b 05 00 00       	call   58e <exit>
  }

  for (i = 0; i < NUM_PROCS; i++) {
  83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8a:	e9 9b 00 00 00       	jmp    12a <main+0xf6>
    int pid = fork();
  8f:	e8 f2 04 00 00       	call   586 <fork>
  94:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid == 0) {
  97:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  9b:	75 67                	jne    104 <main+0xd0>
      // 자식 프로세스
      while (1) {
        // 점점 더 무거운 workload
        if (i == 0)
  9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a1:	75 12                	jne    b5 <main+0x81>
          workload(1000000);   // Q3 예상
  a3:	83 ec 0c             	sub    $0xc,%esp
  a6:	68 40 42 0f 00       	push   $0xf4240
  ab:	e8 50 ff ff ff       	call   0 <workload>
  b0:	83 c4 10             	add    $0x10,%esp
  b3:	eb 40                	jmp    f5 <main+0xc1>
        else if (i == 1)
  b5:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  b9:	75 12                	jne    cd <main+0x99>
          workload(4000000);   // Q2 예상
  bb:	83 ec 0c             	sub    $0xc,%esp
  be:	68 00 09 3d 00       	push   $0x3d0900
  c3:	e8 38 ff ff ff       	call   0 <workload>
  c8:	83 c4 10             	add    $0x10,%esp
  cb:	eb 28                	jmp    f5 <main+0xc1>
        else if (i == 2)
  cd:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  d1:	75 12                	jne    e5 <main+0xb1>
          workload(10000000);  // Q1 예상
  d3:	83 ec 0c             	sub    $0xc,%esp
  d6:	68 80 96 98 00       	push   $0x989680
  db:	e8 20 ff ff ff       	call   0 <workload>
  e0:	83 c4 10             	add    $0x10,%esp
  e3:	eb 10                	jmp    f5 <main+0xc1>
        else
          workload(15000000);  // Q0 예상 (하지만 yield 없음은 위험)
  e5:	83 ec 0c             	sub    $0xc,%esp
  e8:	68 c0 e1 e4 00       	push   $0xe4e1c0
  ed:	e8 0e ff ff ff       	call   0 <workload>
  f2:	83 c4 10             	add    $0x10,%esp

        sleep(3);  // 모든 프로세스가 최소한 CPU 양보하도록
  f5:	83 ec 0c             	sub    $0xc,%esp
  f8:	6a 03                	push   $0x3
  fa:	e8 1f 05 00 00       	call   61e <sleep>
  ff:	83 c4 10             	add    $0x10,%esp
        if (i == 0)
 102:	eb 99                	jmp    9d <main+0x69>
      }
    } else {
      pids[i] = pid;
 104:	8b 45 f4             	mov    -0xc(%ebp),%eax
 107:	8b 55 ec             	mov    -0x14(%ebp),%edx
 10a:	89 94 85 dc f3 ff ff 	mov    %edx,-0xc24(%ebp,%eax,4)
      printf(1, "[parent] 자식 프로세스 pid[%d] = %d\n", i, pid);
 111:	ff 75 ec             	push   -0x14(%ebp)
 114:	ff 75 f4             	push   -0xc(%ebp)
 117:	68 0c 0b 00 00       	push   $0xb0c
 11c:	6a 01                	push   $0x1
 11e:	e8 ef 05 00 00       	call   712 <printf>
 123:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < NUM_PROCS; i++) {
 126:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 12a:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 12e:	0f 8e 5b ff ff ff    	jle    8f <main+0x5b>
    }
  }

  sleep(3000);  // 충분히 돌아갈 시간 확보
 134:	83 ec 0c             	sub    $0xc,%esp
 137:	68 b8 0b 00 00       	push   $0xbb8
 13c:	e8 dd 04 00 00       	call   61e <sleep>
 141:	83 c4 10             	add    $0x10,%esp

  if (getpinfo(&st) < 0) {
 144:	83 ec 0c             	sub    $0xc,%esp
 147:	8d 85 ec f3 ff ff    	lea    -0xc14(%ebp),%eax
 14d:	50                   	push   %eax
 14e:	e8 e3 04 00 00       	call   636 <getpinfo>
 153:	83 c4 10             	add    $0x10,%esp
 156:	85 c0                	test   %eax,%eax
 158:	79 17                	jns    171 <main+0x13d>
    printf(1, "getpinfo failed\n");
 15a:	83 ec 08             	sub    $0x8,%esp
 15d:	68 37 0b 00 00       	push   $0xb37
 162:	6a 01                	push   $0x1
 164:	e8 a9 05 00 00       	call   712 <printf>
 169:	83 c4 10             	add    $0x10,%esp
    exit();
 16c:	e8 1d 04 00 00       	call   58e <exit>
  }

  printf(1, "\n[결과] 각 프로세스의 우선순위 및 큐별 tick 정보:\n\n");
 171:	83 ec 08             	sub    $0x8,%esp
 174:	68 48 0b 00 00       	push   $0xb48
 179:	6a 01                	push   $0x1
 17b:	e8 92 05 00 00       	call   712 <printf>
 180:	83 c4 10             	add    $0x10,%esp

  for (i = 0; i < NPROC; i++) {
 183:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 18a:	e9 46 01 00 00       	jmp    2d5 <main+0x2a1>
    if (st.inuse[i]) {
 18f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 192:	8b 84 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%eax
 199:	85 c0                	test   %eax,%eax
 19b:	0f 84 30 01 00 00    	je     2d1 <main+0x29d>
      for (int j = 0; j < NUM_PROCS; j++) {
 1a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 1a8:	e9 1a 01 00 00       	jmp    2c7 <main+0x293>
        if (st.pid[i] == pids[j]) {
 1ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b0:	83 c0 40             	add    $0x40,%eax
 1b3:	8b 94 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%edx
 1ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1bd:	8b 84 85 dc f3 ff ff 	mov    -0xc24(%ebp,%eax,4),%eax
 1c4:	39 c2                	cmp    %eax,%edx
 1c6:	0f 85 f7 00 00 00    	jne    2c3 <main+0x28f>
          printf(1, "▶ 프로세스 %d (PID %d): 현재 큐 → Q%d\n", j + 1, st.pid[i], st.priority[i]);
 1cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cf:	83 e8 80             	sub    $0xffffff80,%eax
 1d2:	8b 94 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%edx
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	83 c0 40             	add    $0x40,%eax
 1df:	8b 84 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%eax
 1e6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
 1e9:	83 c1 01             	add    $0x1,%ecx
 1ec:	83 ec 0c             	sub    $0xc,%esp
 1ef:	52                   	push   %edx
 1f0:	50                   	push   %eax
 1f1:	51                   	push   %ecx
 1f2:	68 90 0b 00 00       	push   $0xb90
 1f7:	6a 01                	push   $0x1
 1f9:	e8 14 05 00 00       	call   712 <printf>
 1fe:	83 c4 20             	add    $0x20,%esp
          printf(1, "   ticks       : Q0:%d  Q1:%d  Q2:%d  Q3:%d\n",
 201:	8b 45 f4             	mov    -0xc(%ebp),%eax
 204:	c1 e0 04             	shl    $0x4,%eax
 207:	8d 40 f8             	lea    -0x8(%eax),%eax
 20a:	01 e8                	add    %ebp,%eax
 20c:	2d 00 08 00 00       	sub    $0x800,%eax
 211:	8b 18                	mov    (%eax),%ebx
 213:	8b 45 f4             	mov    -0xc(%ebp),%eax
 216:	c1 e0 04             	shl    $0x4,%eax
 219:	8d 40 f8             	lea    -0x8(%eax),%eax
 21c:	01 e8                	add    %ebp,%eax
 21e:	2d 04 08 00 00       	sub    $0x804,%eax
 223:	8b 08                	mov    (%eax),%ecx
 225:	8b 45 f4             	mov    -0xc(%ebp),%eax
 228:	c1 e0 04             	shl    $0x4,%eax
 22b:	8d 40 f8             	lea    -0x8(%eax),%eax
 22e:	01 e8                	add    %ebp,%eax
 230:	2d 08 08 00 00       	sub    $0x808,%eax
 235:	8b 10                	mov    (%eax),%edx
 237:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23a:	83 c0 40             	add    $0x40,%eax
 23d:	c1 e0 04             	shl    $0x4,%eax
 240:	8d 40 f8             	lea    -0x8(%eax),%eax
 243:	01 e8                	add    %ebp,%eax
 245:	2d 0c 0c 00 00       	sub    $0xc0c,%eax
 24a:	8b 00                	mov    (%eax),%eax
 24c:	83 ec 08             	sub    $0x8,%esp
 24f:	53                   	push   %ebx
 250:	51                   	push   %ecx
 251:	52                   	push   %edx
 252:	50                   	push   %eax
 253:	68 c4 0b 00 00       	push   $0xbc4
 258:	6a 01                	push   $0x1
 25a:	e8 b3 04 00 00       	call   712 <printf>
 25f:	83 c4 20             	add    $0x20,%esp
                 st.ticks[i][0], st.ticks[i][1], st.ticks[i][2], st.ticks[i][3]);
          printf(1, "   wait_ticks  : Q0:%d  Q1:%d  Q2:%d  Q3:%d\n\n",
 262:	8b 45 f4             	mov    -0xc(%ebp),%eax
 265:	c1 e0 04             	shl    $0x4,%eax
 268:	8d 40 f8             	lea    -0x8(%eax),%eax
 26b:	01 e8                	add    %ebp,%eax
 26d:	2d 00 04 00 00       	sub    $0x400,%eax
 272:	8b 18                	mov    (%eax),%ebx
 274:	8b 45 f4             	mov    -0xc(%ebp),%eax
 277:	c1 e0 04             	shl    $0x4,%eax
 27a:	8d 40 f8             	lea    -0x8(%eax),%eax
 27d:	01 e8                	add    %ebp,%eax
 27f:	2d 04 04 00 00       	sub    $0x404,%eax
 284:	8b 08                	mov    (%eax),%ecx
 286:	8b 45 f4             	mov    -0xc(%ebp),%eax
 289:	c1 e0 04             	shl    $0x4,%eax
 28c:	8d 40 f8             	lea    -0x8(%eax),%eax
 28f:	01 e8                	add    %ebp,%eax
 291:	2d 08 04 00 00       	sub    $0x408,%eax
 296:	8b 10                	mov    (%eax),%edx
 298:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29b:	83 e8 80             	sub    $0xffffff80,%eax
 29e:	c1 e0 04             	shl    $0x4,%eax
 2a1:	8d 40 f8             	lea    -0x8(%eax),%eax
 2a4:	01 e8                	add    %ebp,%eax
 2a6:	2d 0c 0c 00 00       	sub    $0xc0c,%eax
 2ab:	8b 00                	mov    (%eax),%eax
 2ad:	83 ec 08             	sub    $0x8,%esp
 2b0:	53                   	push   %ebx
 2b1:	51                   	push   %ecx
 2b2:	52                   	push   %edx
 2b3:	50                   	push   %eax
 2b4:	68 f4 0b 00 00       	push   $0xbf4
 2b9:	6a 01                	push   $0x1
 2bb:	e8 52 04 00 00       	call   712 <printf>
 2c0:	83 c4 20             	add    $0x20,%esp
      for (int j = 0; j < NUM_PROCS; j++) {
 2c3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 2c7:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 2cb:	0f 8e dc fe ff ff    	jle    1ad <main+0x179>
  for (i = 0; i < NPROC; i++) {
 2d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2d5:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 2d9:	0f 8e b0 fe ff ff    	jle    18f <main+0x15b>
        }
      }
    }
  }

  for (i = 0; i < NUM_PROCS; i++)
 2df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2e6:	eb 1a                	jmp    302 <main+0x2ce>
    kill(pids[i]);
 2e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2eb:	8b 84 85 dc f3 ff ff 	mov    -0xc24(%ebp,%eax,4),%eax
 2f2:	83 ec 0c             	sub    $0xc,%esp
 2f5:	50                   	push   %eax
 2f6:	e8 c3 02 00 00       	call   5be <kill>
 2fb:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < NUM_PROCS; i++)
 2fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 302:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 306:	7e e0                	jle    2e8 <main+0x2b4>
  for (i = 0; i < NUM_PROCS; i++)
 308:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 30f:	eb 09                	jmp    31a <main+0x2e6>
    wait();
 311:	e8 80 02 00 00       	call   596 <wait>
  for (i = 0; i < NUM_PROCS; i++)
 316:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 31a:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 31e:	7e f1                	jle    311 <main+0x2dd>

  printf(1, "==== 종료 ====\n");
 320:	83 ec 08             	sub    $0x8,%esp
 323:	68 22 0c 00 00       	push   $0xc22
 328:	6a 01                	push   $0x1
 32a:	e8 e3 03 00 00       	call   712 <printf>
 32f:	83 c4 10             	add    $0x10,%esp
  exit();
 332:	e8 57 02 00 00       	call   58e <exit>

00000337 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 337:	55                   	push   %ebp
 338:	89 e5                	mov    %esp,%ebp
 33a:	57                   	push   %edi
 33b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 33c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 33f:	8b 55 10             	mov    0x10(%ebp),%edx
 342:	8b 45 0c             	mov    0xc(%ebp),%eax
 345:	89 cb                	mov    %ecx,%ebx
 347:	89 df                	mov    %ebx,%edi
 349:	89 d1                	mov    %edx,%ecx
 34b:	fc                   	cld    
 34c:	f3 aa                	rep stos %al,%es:(%edi)
 34e:	89 ca                	mov    %ecx,%edx
 350:	89 fb                	mov    %edi,%ebx
 352:	89 5d 08             	mov    %ebx,0x8(%ebp)
 355:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 358:	90                   	nop
 359:	5b                   	pop    %ebx
 35a:	5f                   	pop    %edi
 35b:	5d                   	pop    %ebp
 35c:	c3                   	ret    

0000035d <strcpy>:



char*
strcpy(char *s, char *t)
{
 35d:	55                   	push   %ebp
 35e:	89 e5                	mov    %esp,%ebp
 360:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 363:	8b 45 08             	mov    0x8(%ebp),%eax
 366:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 369:	90                   	nop
 36a:	8b 55 0c             	mov    0xc(%ebp),%edx
 36d:	8d 42 01             	lea    0x1(%edx),%eax
 370:	89 45 0c             	mov    %eax,0xc(%ebp)
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	8d 48 01             	lea    0x1(%eax),%ecx
 379:	89 4d 08             	mov    %ecx,0x8(%ebp)
 37c:	0f b6 12             	movzbl (%edx),%edx
 37f:	88 10                	mov    %dl,(%eax)
 381:	0f b6 00             	movzbl (%eax),%eax
 384:	84 c0                	test   %al,%al
 386:	75 e2                	jne    36a <strcpy+0xd>
    ;
  return os;
 388:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 38b:	c9                   	leave  
 38c:	c3                   	ret    

0000038d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 38d:	55                   	push   %ebp
 38e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 390:	eb 08                	jmp    39a <strcmp+0xd>
    p++, q++;
 392:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 396:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	0f b6 00             	movzbl (%eax),%eax
 3a0:	84 c0                	test   %al,%al
 3a2:	74 10                	je     3b4 <strcmp+0x27>
 3a4:	8b 45 08             	mov    0x8(%ebp),%eax
 3a7:	0f b6 10             	movzbl (%eax),%edx
 3aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ad:	0f b6 00             	movzbl (%eax),%eax
 3b0:	38 c2                	cmp    %al,%dl
 3b2:	74 de                	je     392 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	0f b6 00             	movzbl (%eax),%eax
 3ba:	0f b6 d0             	movzbl %al,%edx
 3bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c0:	0f b6 00             	movzbl (%eax),%eax
 3c3:	0f b6 c8             	movzbl %al,%ecx
 3c6:	89 d0                	mov    %edx,%eax
 3c8:	29 c8                	sub    %ecx,%eax
}
 3ca:	5d                   	pop    %ebp
 3cb:	c3                   	ret    

000003cc <strlen>:

uint
strlen(char *s)
{
 3cc:	55                   	push   %ebp
 3cd:	89 e5                	mov    %esp,%ebp
 3cf:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3d2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3d9:	eb 04                	jmp    3df <strlen+0x13>
 3db:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3df:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3e2:	8b 45 08             	mov    0x8(%ebp),%eax
 3e5:	01 d0                	add    %edx,%eax
 3e7:	0f b6 00             	movzbl (%eax),%eax
 3ea:	84 c0                	test   %al,%al
 3ec:	75 ed                	jne    3db <strlen+0xf>
    ;
  return n;
 3ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f1:	c9                   	leave  
 3f2:	c3                   	ret    

000003f3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3f3:	55                   	push   %ebp
 3f4:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3f6:	8b 45 10             	mov    0x10(%ebp),%eax
 3f9:	50                   	push   %eax
 3fa:	ff 75 0c             	push   0xc(%ebp)
 3fd:	ff 75 08             	push   0x8(%ebp)
 400:	e8 32 ff ff ff       	call   337 <stosb>
 405:	83 c4 0c             	add    $0xc,%esp
  return dst;
 408:	8b 45 08             	mov    0x8(%ebp),%eax
}
 40b:	c9                   	leave  
 40c:	c3                   	ret    

0000040d <strchr>:

char*
strchr(const char *s, char c)
{
 40d:	55                   	push   %ebp
 40e:	89 e5                	mov    %esp,%ebp
 410:	83 ec 04             	sub    $0x4,%esp
 413:	8b 45 0c             	mov    0xc(%ebp),%eax
 416:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 419:	eb 14                	jmp    42f <strchr+0x22>
    if(*s == c)
 41b:	8b 45 08             	mov    0x8(%ebp),%eax
 41e:	0f b6 00             	movzbl (%eax),%eax
 421:	38 45 fc             	cmp    %al,-0x4(%ebp)
 424:	75 05                	jne    42b <strchr+0x1e>
      return (char*)s;
 426:	8b 45 08             	mov    0x8(%ebp),%eax
 429:	eb 13                	jmp    43e <strchr+0x31>
  for(; *s; s++)
 42b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
 432:	0f b6 00             	movzbl (%eax),%eax
 435:	84 c0                	test   %al,%al
 437:	75 e2                	jne    41b <strchr+0xe>
  return 0;
 439:	b8 00 00 00 00       	mov    $0x0,%eax
}
 43e:	c9                   	leave  
 43f:	c3                   	ret    

00000440 <gets>:

char*
gets(char *buf, int max)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 446:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 44d:	eb 42                	jmp    491 <gets+0x51>
    cc = read(0, &c, 1);
 44f:	83 ec 04             	sub    $0x4,%esp
 452:	6a 01                	push   $0x1
 454:	8d 45 ef             	lea    -0x11(%ebp),%eax
 457:	50                   	push   %eax
 458:	6a 00                	push   $0x0
 45a:	e8 47 01 00 00       	call   5a6 <read>
 45f:	83 c4 10             	add    $0x10,%esp
 462:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 465:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 469:	7e 33                	jle    49e <gets+0x5e>
      break;
    buf[i++] = c;
 46b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46e:	8d 50 01             	lea    0x1(%eax),%edx
 471:	89 55 f4             	mov    %edx,-0xc(%ebp)
 474:	89 c2                	mov    %eax,%edx
 476:	8b 45 08             	mov    0x8(%ebp),%eax
 479:	01 c2                	add    %eax,%edx
 47b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 47f:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 481:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 485:	3c 0a                	cmp    $0xa,%al
 487:	74 16                	je     49f <gets+0x5f>
 489:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 48d:	3c 0d                	cmp    $0xd,%al
 48f:	74 0e                	je     49f <gets+0x5f>
  for(i=0; i+1 < max; ){
 491:	8b 45 f4             	mov    -0xc(%ebp),%eax
 494:	83 c0 01             	add    $0x1,%eax
 497:	39 45 0c             	cmp    %eax,0xc(%ebp)
 49a:	7f b3                	jg     44f <gets+0xf>
 49c:	eb 01                	jmp    49f <gets+0x5f>
      break;
 49e:	90                   	nop
      break;
  }
  buf[i] = '\0';
 49f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4a2:	8b 45 08             	mov    0x8(%ebp),%eax
 4a5:	01 d0                	add    %edx,%eax
 4a7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4ad:	c9                   	leave  
 4ae:	c3                   	ret    

000004af <stat>:

int
stat(char *n, struct stat *st)
{
 4af:	55                   	push   %ebp
 4b0:	89 e5                	mov    %esp,%ebp
 4b2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4b5:	83 ec 08             	sub    $0x8,%esp
 4b8:	6a 00                	push   $0x0
 4ba:	ff 75 08             	push   0x8(%ebp)
 4bd:	e8 0c 01 00 00       	call   5ce <open>
 4c2:	83 c4 10             	add    $0x10,%esp
 4c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4cc:	79 07                	jns    4d5 <stat+0x26>
    return -1;
 4ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4d3:	eb 25                	jmp    4fa <stat+0x4b>
  r = fstat(fd, st);
 4d5:	83 ec 08             	sub    $0x8,%esp
 4d8:	ff 75 0c             	push   0xc(%ebp)
 4db:	ff 75 f4             	push   -0xc(%ebp)
 4de:	e8 03 01 00 00       	call   5e6 <fstat>
 4e3:	83 c4 10             	add    $0x10,%esp
 4e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4e9:	83 ec 0c             	sub    $0xc,%esp
 4ec:	ff 75 f4             	push   -0xc(%ebp)
 4ef:	e8 c2 00 00 00       	call   5b6 <close>
 4f4:	83 c4 10             	add    $0x10,%esp
  return r;
 4f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4fa:	c9                   	leave  
 4fb:	c3                   	ret    

000004fc <atoi>:

int
atoi(const char *s)
{
 4fc:	55                   	push   %ebp
 4fd:	89 e5                	mov    %esp,%ebp
 4ff:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 502:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 509:	eb 25                	jmp    530 <atoi+0x34>
    n = n*10 + *s++ - '0';
 50b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 50e:	89 d0                	mov    %edx,%eax
 510:	c1 e0 02             	shl    $0x2,%eax
 513:	01 d0                	add    %edx,%eax
 515:	01 c0                	add    %eax,%eax
 517:	89 c1                	mov    %eax,%ecx
 519:	8b 45 08             	mov    0x8(%ebp),%eax
 51c:	8d 50 01             	lea    0x1(%eax),%edx
 51f:	89 55 08             	mov    %edx,0x8(%ebp)
 522:	0f b6 00             	movzbl (%eax),%eax
 525:	0f be c0             	movsbl %al,%eax
 528:	01 c8                	add    %ecx,%eax
 52a:	83 e8 30             	sub    $0x30,%eax
 52d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 530:	8b 45 08             	mov    0x8(%ebp),%eax
 533:	0f b6 00             	movzbl (%eax),%eax
 536:	3c 2f                	cmp    $0x2f,%al
 538:	7e 0a                	jle    544 <atoi+0x48>
 53a:	8b 45 08             	mov    0x8(%ebp),%eax
 53d:	0f b6 00             	movzbl (%eax),%eax
 540:	3c 39                	cmp    $0x39,%al
 542:	7e c7                	jle    50b <atoi+0xf>
  return n;
 544:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 547:	c9                   	leave  
 548:	c3                   	ret    

00000549 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 549:	55                   	push   %ebp
 54a:	89 e5                	mov    %esp,%ebp
 54c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 555:	8b 45 0c             	mov    0xc(%ebp),%eax
 558:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 55b:	eb 17                	jmp    574 <memmove+0x2b>
    *dst++ = *src++;
 55d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 560:	8d 42 01             	lea    0x1(%edx),%eax
 563:	89 45 f8             	mov    %eax,-0x8(%ebp)
 566:	8b 45 fc             	mov    -0x4(%ebp),%eax
 569:	8d 48 01             	lea    0x1(%eax),%ecx
 56c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 56f:	0f b6 12             	movzbl (%edx),%edx
 572:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 574:	8b 45 10             	mov    0x10(%ebp),%eax
 577:	8d 50 ff             	lea    -0x1(%eax),%edx
 57a:	89 55 10             	mov    %edx,0x10(%ebp)
 57d:	85 c0                	test   %eax,%eax
 57f:	7f dc                	jg     55d <memmove+0x14>
  return vdst;
 581:	8b 45 08             	mov    0x8(%ebp),%eax
}
 584:	c9                   	leave  
 585:	c3                   	ret    

00000586 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 586:	b8 01 00 00 00       	mov    $0x1,%eax
 58b:	cd 40                	int    $0x40
 58d:	c3                   	ret    

0000058e <exit>:
SYSCALL(exit)
 58e:	b8 02 00 00 00       	mov    $0x2,%eax
 593:	cd 40                	int    $0x40
 595:	c3                   	ret    

00000596 <wait>:
SYSCALL(wait)
 596:	b8 03 00 00 00       	mov    $0x3,%eax
 59b:	cd 40                	int    $0x40
 59d:	c3                   	ret    

0000059e <pipe>:
SYSCALL(pipe)
 59e:	b8 04 00 00 00       	mov    $0x4,%eax
 5a3:	cd 40                	int    $0x40
 5a5:	c3                   	ret    

000005a6 <read>:
SYSCALL(read)
 5a6:	b8 05 00 00 00       	mov    $0x5,%eax
 5ab:	cd 40                	int    $0x40
 5ad:	c3                   	ret    

000005ae <write>:
SYSCALL(write)
 5ae:	b8 10 00 00 00       	mov    $0x10,%eax
 5b3:	cd 40                	int    $0x40
 5b5:	c3                   	ret    

000005b6 <close>:
SYSCALL(close)
 5b6:	b8 15 00 00 00       	mov    $0x15,%eax
 5bb:	cd 40                	int    $0x40
 5bd:	c3                   	ret    

000005be <kill>:
SYSCALL(kill)
 5be:	b8 06 00 00 00       	mov    $0x6,%eax
 5c3:	cd 40                	int    $0x40
 5c5:	c3                   	ret    

000005c6 <exec>:
SYSCALL(exec)
 5c6:	b8 07 00 00 00       	mov    $0x7,%eax
 5cb:	cd 40                	int    $0x40
 5cd:	c3                   	ret    

000005ce <open>:
SYSCALL(open)
 5ce:	b8 0f 00 00 00       	mov    $0xf,%eax
 5d3:	cd 40                	int    $0x40
 5d5:	c3                   	ret    

000005d6 <mknod>:
SYSCALL(mknod)
 5d6:	b8 11 00 00 00       	mov    $0x11,%eax
 5db:	cd 40                	int    $0x40
 5dd:	c3                   	ret    

000005de <unlink>:
SYSCALL(unlink)
 5de:	b8 12 00 00 00       	mov    $0x12,%eax
 5e3:	cd 40                	int    $0x40
 5e5:	c3                   	ret    

000005e6 <fstat>:
SYSCALL(fstat)
 5e6:	b8 08 00 00 00       	mov    $0x8,%eax
 5eb:	cd 40                	int    $0x40
 5ed:	c3                   	ret    

000005ee <link>:
SYSCALL(link)
 5ee:	b8 13 00 00 00       	mov    $0x13,%eax
 5f3:	cd 40                	int    $0x40
 5f5:	c3                   	ret    

000005f6 <mkdir>:
SYSCALL(mkdir)
 5f6:	b8 14 00 00 00       	mov    $0x14,%eax
 5fb:	cd 40                	int    $0x40
 5fd:	c3                   	ret    

000005fe <chdir>:
SYSCALL(chdir)
 5fe:	b8 09 00 00 00       	mov    $0x9,%eax
 603:	cd 40                	int    $0x40
 605:	c3                   	ret    

00000606 <dup>:
SYSCALL(dup)
 606:	b8 0a 00 00 00       	mov    $0xa,%eax
 60b:	cd 40                	int    $0x40
 60d:	c3                   	ret    

0000060e <getpid>:
SYSCALL(getpid)
 60e:	b8 0b 00 00 00       	mov    $0xb,%eax
 613:	cd 40                	int    $0x40
 615:	c3                   	ret    

00000616 <sbrk>:
SYSCALL(sbrk)
 616:	b8 0c 00 00 00       	mov    $0xc,%eax
 61b:	cd 40                	int    $0x40
 61d:	c3                   	ret    

0000061e <sleep>:
SYSCALL(sleep)
 61e:	b8 0d 00 00 00       	mov    $0xd,%eax
 623:	cd 40                	int    $0x40
 625:	c3                   	ret    

00000626 <uptime>:
SYSCALL(uptime)
 626:	b8 0e 00 00 00       	mov    $0xe,%eax
 62b:	cd 40                	int    $0x40
 62d:	c3                   	ret    

0000062e <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 62e:	b8 16 00 00 00       	mov    $0x16,%eax
 633:	cd 40                	int    $0x40
 635:	c3                   	ret    

00000636 <getpinfo>:
SYSCALL(getpinfo)
 636:	b8 17 00 00 00       	mov    $0x17,%eax
 63b:	cd 40                	int    $0x40
 63d:	c3                   	ret    

0000063e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 63e:	55                   	push   %ebp
 63f:	89 e5                	mov    %esp,%ebp
 641:	83 ec 18             	sub    $0x18,%esp
 644:	8b 45 0c             	mov    0xc(%ebp),%eax
 647:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 64a:	83 ec 04             	sub    $0x4,%esp
 64d:	6a 01                	push   $0x1
 64f:	8d 45 f4             	lea    -0xc(%ebp),%eax
 652:	50                   	push   %eax
 653:	ff 75 08             	push   0x8(%ebp)
 656:	e8 53 ff ff ff       	call   5ae <write>
 65b:	83 c4 10             	add    $0x10,%esp
}
 65e:	90                   	nop
 65f:	c9                   	leave  
 660:	c3                   	ret    

00000661 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 661:	55                   	push   %ebp
 662:	89 e5                	mov    %esp,%ebp
 664:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 667:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 66e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 672:	74 17                	je     68b <printint+0x2a>
 674:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 678:	79 11                	jns    68b <printint+0x2a>
    neg = 1;
 67a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 681:	8b 45 0c             	mov    0xc(%ebp),%eax
 684:	f7 d8                	neg    %eax
 686:	89 45 ec             	mov    %eax,-0x14(%ebp)
 689:	eb 06                	jmp    691 <printint+0x30>
  } else {
    x = xx;
 68b:	8b 45 0c             	mov    0xc(%ebp),%eax
 68e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 698:	8b 4d 10             	mov    0x10(%ebp),%ecx
 69b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 69e:	ba 00 00 00 00       	mov    $0x0,%edx
 6a3:	f7 f1                	div    %ecx
 6a5:	89 d1                	mov    %edx,%ecx
 6a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6aa:	8d 50 01             	lea    0x1(%eax),%edx
 6ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6b0:	0f b6 91 a4 0e 00 00 	movzbl 0xea4(%ecx),%edx
 6b7:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6be:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6c1:	ba 00 00 00 00       	mov    $0x0,%edx
 6c6:	f7 f1                	div    %ecx
 6c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6cf:	75 c7                	jne    698 <printint+0x37>
  if(neg)
 6d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6d5:	74 2d                	je     704 <printint+0xa3>
    buf[i++] = '-';
 6d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6da:	8d 50 01             	lea    0x1(%eax),%edx
 6dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6e0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6e5:	eb 1d                	jmp    704 <printint+0xa3>
    putc(fd, buf[i]);
 6e7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ed:	01 d0                	add    %edx,%eax
 6ef:	0f b6 00             	movzbl (%eax),%eax
 6f2:	0f be c0             	movsbl %al,%eax
 6f5:	83 ec 08             	sub    $0x8,%esp
 6f8:	50                   	push   %eax
 6f9:	ff 75 08             	push   0x8(%ebp)
 6fc:	e8 3d ff ff ff       	call   63e <putc>
 701:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 704:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 708:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 70c:	79 d9                	jns    6e7 <printint+0x86>
}
 70e:	90                   	nop
 70f:	90                   	nop
 710:	c9                   	leave  
 711:	c3                   	ret    

00000712 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 712:	55                   	push   %ebp
 713:	89 e5                	mov    %esp,%ebp
 715:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 718:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 71f:	8d 45 0c             	lea    0xc(%ebp),%eax
 722:	83 c0 04             	add    $0x4,%eax
 725:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 728:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 72f:	e9 59 01 00 00       	jmp    88d <printf+0x17b>
    c = fmt[i] & 0xff;
 734:	8b 55 0c             	mov    0xc(%ebp),%edx
 737:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73a:	01 d0                	add    %edx,%eax
 73c:	0f b6 00             	movzbl (%eax),%eax
 73f:	0f be c0             	movsbl %al,%eax
 742:	25 ff 00 00 00       	and    $0xff,%eax
 747:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 74a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 74e:	75 2c                	jne    77c <printf+0x6a>
      if(c == '%'){
 750:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 754:	75 0c                	jne    762 <printf+0x50>
        state = '%';
 756:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 75d:	e9 27 01 00 00       	jmp    889 <printf+0x177>
      } else {
        putc(fd, c);
 762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 765:	0f be c0             	movsbl %al,%eax
 768:	83 ec 08             	sub    $0x8,%esp
 76b:	50                   	push   %eax
 76c:	ff 75 08             	push   0x8(%ebp)
 76f:	e8 ca fe ff ff       	call   63e <putc>
 774:	83 c4 10             	add    $0x10,%esp
 777:	e9 0d 01 00 00       	jmp    889 <printf+0x177>
      }
    } else if(state == '%'){
 77c:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 780:	0f 85 03 01 00 00    	jne    889 <printf+0x177>
      if(c == 'd'){
 786:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 78a:	75 1e                	jne    7aa <printf+0x98>
        printint(fd, *ap, 10, 1);
 78c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78f:	8b 00                	mov    (%eax),%eax
 791:	6a 01                	push   $0x1
 793:	6a 0a                	push   $0xa
 795:	50                   	push   %eax
 796:	ff 75 08             	push   0x8(%ebp)
 799:	e8 c3 fe ff ff       	call   661 <printint>
 79e:	83 c4 10             	add    $0x10,%esp
        ap++;
 7a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a5:	e9 d8 00 00 00       	jmp    882 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7aa:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ae:	74 06                	je     7b6 <printf+0xa4>
 7b0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7b4:	75 1e                	jne    7d4 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b9:	8b 00                	mov    (%eax),%eax
 7bb:	6a 00                	push   $0x0
 7bd:	6a 10                	push   $0x10
 7bf:	50                   	push   %eax
 7c0:	ff 75 08             	push   0x8(%ebp)
 7c3:	e8 99 fe ff ff       	call   661 <printint>
 7c8:	83 c4 10             	add    $0x10,%esp
        ap++;
 7cb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7cf:	e9 ae 00 00 00       	jmp    882 <printf+0x170>
      } else if(c == 's'){
 7d4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7d8:	75 43                	jne    81d <printf+0x10b>
        s = (char*)*ap;
 7da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7dd:	8b 00                	mov    (%eax),%eax
 7df:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ea:	75 25                	jne    811 <printf+0xff>
          s = "(null)";
 7ec:	c7 45 f4 34 0c 00 00 	movl   $0xc34,-0xc(%ebp)
        while(*s != 0){
 7f3:	eb 1c                	jmp    811 <printf+0xff>
          putc(fd, *s);
 7f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f8:	0f b6 00             	movzbl (%eax),%eax
 7fb:	0f be c0             	movsbl %al,%eax
 7fe:	83 ec 08             	sub    $0x8,%esp
 801:	50                   	push   %eax
 802:	ff 75 08             	push   0x8(%ebp)
 805:	e8 34 fe ff ff       	call   63e <putc>
 80a:	83 c4 10             	add    $0x10,%esp
          s++;
 80d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 811:	8b 45 f4             	mov    -0xc(%ebp),%eax
 814:	0f b6 00             	movzbl (%eax),%eax
 817:	84 c0                	test   %al,%al
 819:	75 da                	jne    7f5 <printf+0xe3>
 81b:	eb 65                	jmp    882 <printf+0x170>
        }
      } else if(c == 'c'){
 81d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 821:	75 1d                	jne    840 <printf+0x12e>
        putc(fd, *ap);
 823:	8b 45 e8             	mov    -0x18(%ebp),%eax
 826:	8b 00                	mov    (%eax),%eax
 828:	0f be c0             	movsbl %al,%eax
 82b:	83 ec 08             	sub    $0x8,%esp
 82e:	50                   	push   %eax
 82f:	ff 75 08             	push   0x8(%ebp)
 832:	e8 07 fe ff ff       	call   63e <putc>
 837:	83 c4 10             	add    $0x10,%esp
        ap++;
 83a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 83e:	eb 42                	jmp    882 <printf+0x170>
      } else if(c == '%'){
 840:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 844:	75 17                	jne    85d <printf+0x14b>
        putc(fd, c);
 846:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 849:	0f be c0             	movsbl %al,%eax
 84c:	83 ec 08             	sub    $0x8,%esp
 84f:	50                   	push   %eax
 850:	ff 75 08             	push   0x8(%ebp)
 853:	e8 e6 fd ff ff       	call   63e <putc>
 858:	83 c4 10             	add    $0x10,%esp
 85b:	eb 25                	jmp    882 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 85d:	83 ec 08             	sub    $0x8,%esp
 860:	6a 25                	push   $0x25
 862:	ff 75 08             	push   0x8(%ebp)
 865:	e8 d4 fd ff ff       	call   63e <putc>
 86a:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 86d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 870:	0f be c0             	movsbl %al,%eax
 873:	83 ec 08             	sub    $0x8,%esp
 876:	50                   	push   %eax
 877:	ff 75 08             	push   0x8(%ebp)
 87a:	e8 bf fd ff ff       	call   63e <putc>
 87f:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 882:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 889:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 88d:	8b 55 0c             	mov    0xc(%ebp),%edx
 890:	8b 45 f0             	mov    -0x10(%ebp),%eax
 893:	01 d0                	add    %edx,%eax
 895:	0f b6 00             	movzbl (%eax),%eax
 898:	84 c0                	test   %al,%al
 89a:	0f 85 94 fe ff ff    	jne    734 <printf+0x22>
    }
  }
}
 8a0:	90                   	nop
 8a1:	90                   	nop
 8a2:	c9                   	leave  
 8a3:	c3                   	ret    

000008a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a4:	55                   	push   %ebp
 8a5:	89 e5                	mov    %esp,%ebp
 8a7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8aa:	8b 45 08             	mov    0x8(%ebp),%eax
 8ad:	83 e8 08             	sub    $0x8,%eax
 8b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b3:	a1 c0 0e 00 00       	mov    0xec0,%eax
 8b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8bb:	eb 24                	jmp    8e1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c0:	8b 00                	mov    (%eax),%eax
 8c2:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8c5:	72 12                	jb     8d9 <free+0x35>
 8c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8cd:	77 24                	ja     8f3 <free+0x4f>
 8cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d2:	8b 00                	mov    (%eax),%eax
 8d4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8d7:	72 1a                	jb     8f3 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	8b 00                	mov    (%eax),%eax
 8de:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e7:	76 d4                	jbe    8bd <free+0x19>
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	8b 00                	mov    (%eax),%eax
 8ee:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8f1:	73 ca                	jae    8bd <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f6:	8b 40 04             	mov    0x4(%eax),%eax
 8f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 900:	8b 45 f8             	mov    -0x8(%ebp),%eax
 903:	01 c2                	add    %eax,%edx
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	8b 00                	mov    (%eax),%eax
 90a:	39 c2                	cmp    %eax,%edx
 90c:	75 24                	jne    932 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 90e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 911:	8b 50 04             	mov    0x4(%eax),%edx
 914:	8b 45 fc             	mov    -0x4(%ebp),%eax
 917:	8b 00                	mov    (%eax),%eax
 919:	8b 40 04             	mov    0x4(%eax),%eax
 91c:	01 c2                	add    %eax,%edx
 91e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 921:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 924:	8b 45 fc             	mov    -0x4(%ebp),%eax
 927:	8b 00                	mov    (%eax),%eax
 929:	8b 10                	mov    (%eax),%edx
 92b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92e:	89 10                	mov    %edx,(%eax)
 930:	eb 0a                	jmp    93c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 932:	8b 45 fc             	mov    -0x4(%ebp),%eax
 935:	8b 10                	mov    (%eax),%edx
 937:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 93c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93f:	8b 40 04             	mov    0x4(%eax),%eax
 942:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 949:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94c:	01 d0                	add    %edx,%eax
 94e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 951:	75 20                	jne    973 <free+0xcf>
    p->s.size += bp->s.size;
 953:	8b 45 fc             	mov    -0x4(%ebp),%eax
 956:	8b 50 04             	mov    0x4(%eax),%edx
 959:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95c:	8b 40 04             	mov    0x4(%eax),%eax
 95f:	01 c2                	add    %eax,%edx
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 967:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96a:	8b 10                	mov    (%eax),%edx
 96c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96f:	89 10                	mov    %edx,(%eax)
 971:	eb 08                	jmp    97b <free+0xd7>
  } else
    p->s.ptr = bp;
 973:	8b 45 fc             	mov    -0x4(%ebp),%eax
 976:	8b 55 f8             	mov    -0x8(%ebp),%edx
 979:	89 10                	mov    %edx,(%eax)
  freep = p;
 97b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97e:	a3 c0 0e 00 00       	mov    %eax,0xec0
}
 983:	90                   	nop
 984:	c9                   	leave  
 985:	c3                   	ret    

00000986 <morecore>:

static Header*
morecore(uint nu)
{
 986:	55                   	push   %ebp
 987:	89 e5                	mov    %esp,%ebp
 989:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 98c:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 993:	77 07                	ja     99c <morecore+0x16>
    nu = 4096;
 995:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 99c:	8b 45 08             	mov    0x8(%ebp),%eax
 99f:	c1 e0 03             	shl    $0x3,%eax
 9a2:	83 ec 0c             	sub    $0xc,%esp
 9a5:	50                   	push   %eax
 9a6:	e8 6b fc ff ff       	call   616 <sbrk>
 9ab:	83 c4 10             	add    $0x10,%esp
 9ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9b1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9b5:	75 07                	jne    9be <morecore+0x38>
    return 0;
 9b7:	b8 00 00 00 00       	mov    $0x0,%eax
 9bc:	eb 26                	jmp    9e4 <morecore+0x5e>
  hp = (Header*)p;
 9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c7:	8b 55 08             	mov    0x8(%ebp),%edx
 9ca:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d0:	83 c0 08             	add    $0x8,%eax
 9d3:	83 ec 0c             	sub    $0xc,%esp
 9d6:	50                   	push   %eax
 9d7:	e8 c8 fe ff ff       	call   8a4 <free>
 9dc:	83 c4 10             	add    $0x10,%esp
  return freep;
 9df:	a1 c0 0e 00 00       	mov    0xec0,%eax
}
 9e4:	c9                   	leave  
 9e5:	c3                   	ret    

000009e6 <malloc>:

void*
malloc(uint nbytes)
{
 9e6:	55                   	push   %ebp
 9e7:	89 e5                	mov    %esp,%ebp
 9e9:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ec:	8b 45 08             	mov    0x8(%ebp),%eax
 9ef:	83 c0 07             	add    $0x7,%eax
 9f2:	c1 e8 03             	shr    $0x3,%eax
 9f5:	83 c0 01             	add    $0x1,%eax
 9f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9fb:	a1 c0 0e 00 00       	mov    0xec0,%eax
 a00:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a07:	75 23                	jne    a2c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a09:	c7 45 f0 b8 0e 00 00 	movl   $0xeb8,-0x10(%ebp)
 a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a13:	a3 c0 0e 00 00       	mov    %eax,0xec0
 a18:	a1 c0 0e 00 00       	mov    0xec0,%eax
 a1d:	a3 b8 0e 00 00       	mov    %eax,0xeb8
    base.s.size = 0;
 a22:	c7 05 bc 0e 00 00 00 	movl   $0x0,0xebc
 a29:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2f:	8b 00                	mov    (%eax),%eax
 a31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a37:	8b 40 04             	mov    0x4(%eax),%eax
 a3a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a3d:	77 4d                	ja     a8c <malloc+0xa6>
      if(p->s.size == nunits)
 a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a42:	8b 40 04             	mov    0x4(%eax),%eax
 a45:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a48:	75 0c                	jne    a56 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4d:	8b 10                	mov    (%eax),%edx
 a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a52:	89 10                	mov    %edx,(%eax)
 a54:	eb 26                	jmp    a7c <malloc+0x96>
      else {
        p->s.size -= nunits;
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	8b 40 04             	mov    0x4(%eax),%eax
 a5c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a5f:	89 c2                	mov    %eax,%edx
 a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a64:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6a:	8b 40 04             	mov    0x4(%eax),%eax
 a6d:	c1 e0 03             	shl    $0x3,%eax
 a70:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a76:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a79:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7f:	a3 c0 0e 00 00       	mov    %eax,0xec0
      return (void*)(p + 1);
 a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a87:	83 c0 08             	add    $0x8,%eax
 a8a:	eb 3b                	jmp    ac7 <malloc+0xe1>
    }
    if(p == freep)
 a8c:	a1 c0 0e 00 00       	mov    0xec0,%eax
 a91:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a94:	75 1e                	jne    ab4 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a96:	83 ec 0c             	sub    $0xc,%esp
 a99:	ff 75 ec             	push   -0x14(%ebp)
 a9c:	e8 e5 fe ff ff       	call   986 <morecore>
 aa1:	83 c4 10             	add    $0x10,%esp
 aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aab:	75 07                	jne    ab4 <malloc+0xce>
        return 0;
 aad:	b8 00 00 00 00       	mov    $0x0,%eax
 ab2:	eb 13                	jmp    ac7 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	8b 00                	mov    (%eax),%eax
 abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ac2:	e9 6d ff ff ff       	jmp    a34 <malloc+0x4e>
  }
}
 ac7:	c9                   	leave  
 ac8:	c3                   	ret    
