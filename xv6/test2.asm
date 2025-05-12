
_test2:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
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
  4c:	68 dc 0a 00 00       	push   $0xadc
  51:	6a 01                	push   $0x1
  53:	e8 cb 06 00 00       	call   723 <printf>
  58:	83 c4 10             	add    $0x10,%esp

  if (setSchedPolicy(2) < 0) {
  5b:	83 ec 0c             	sub    $0xc,%esp
  5e:	6a 02                	push   $0x2
  60:	e8 da 05 00 00       	call   63f <setSchedPolicy>
  65:	83 c4 10             	add    $0x10,%esp
  68:	85 c0                	test   %eax,%eax
  6a:	79 17                	jns    83 <main+0x4f>
    printf(1, "setSchedPolicy failed!\n");
  6c:	83 ec 08             	sub    $0x8,%esp
  6f:	68 03 0b 00 00       	push   $0xb03
  74:	6a 01                	push   $0x1
  76:	e8 a8 06 00 00       	call   723 <printf>
  7b:	83 c4 10             	add    $0x10,%esp
    exit();
  7e:	e8 1c 05 00 00       	call   59f <exit>
  }

  for (i = 0; i < NUM_PROCS; i++) {
  83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8a:	e9 ac 00 00 00       	jmp    13b <main+0x107>
    int pid = fork();
  8f:	e8 03 05 00 00       	call   597 <fork>
  94:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid == 0) {
  97:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  9b:	75 78                	jne    115 <main+0xe1>
      // 자식 프로세스
      int iter = 0;
  9d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      while (1) {
        iter++;
  a4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
        // 점점 더 무거운 workload
        if (i == 0)
  a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  ac:	75 12                	jne    c0 <main+0x8c>
          workload(1000000);  // 1번: Q3 유지
  ae:	83 ec 0c             	sub    $0xc,%esp
  b1:	68 40 42 0f 00       	push   $0xf4240
  b6:	e8 45 ff ff ff       	call   0 <workload>
  bb:	83 c4 10             	add    $0x10,%esp
  be:	eb 40                	jmp    100 <main+0xcc>
        else if (i == 1)
  c0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  c4:	75 12                	jne    d8 <main+0xa4>
          workload(4000000);  // 2번: Q2 예상
  c6:	83 ec 0c             	sub    $0xc,%esp
  c9:	68 00 09 3d 00       	push   $0x3d0900
  ce:	e8 2d ff ff ff       	call   0 <workload>
  d3:	83 c4 10             	add    $0x10,%esp
  d6:	eb 28                	jmp    100 <main+0xcc>
        else if (i == 2)
  d8:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  dc:	75 12                	jne    f0 <main+0xbc>
          workload(10000000); // 3번: Q1 예상
  de:	83 ec 0c             	sub    $0xc,%esp
  e1:	68 80 96 98 00       	push   $0x989680
  e6:	e8 15 ff ff ff       	call   0 <workload>
  eb:	83 c4 10             	add    $0x10,%esp
  ee:	eb 10                	jmp    100 <main+0xcc>
        else
          workload(50000000); // 4번: no yield, Q0
  f0:	83 ec 0c             	sub    $0xc,%esp
  f3:	68 80 f0 fa 02       	push   $0x2faf080
  f8:	e8 03 ff ff ff       	call   0 <workload>
  fd:	83 c4 10             	add    $0x10,%esp

        // i < 3 까지만 yield 호출 → Q0까지는 안감
        if (i < 3)
 100:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 104:	7f 9e                	jg     a4 <main+0x70>
          sleep(3);
 106:	83 ec 0c             	sub    $0xc,%esp
 109:	6a 03                	push   $0x3
 10b:	e8 1f 05 00 00       	call   62f <sleep>
 110:	83 c4 10             	add    $0x10,%esp
        iter++;
 113:	eb 8f                	jmp    a4 <main+0x70>
      }
    } else {
      // 부모는 pid 저장
      pids[i] = pid;
 115:	8b 45 f4             	mov    -0xc(%ebp),%eax
 118:	8b 55 e8             	mov    -0x18(%ebp),%edx
 11b:	89 94 85 d8 f3 ff ff 	mov    %edx,-0xc28(%ebp,%eax,4)
      printf(1, "[parent] 자식 프로세스 pid[%d] = %d\n", i, pid);
 122:	ff 75 e8             	push   -0x18(%ebp)
 125:	ff 75 f4             	push   -0xc(%ebp)
 128:	68 1c 0b 00 00       	push   $0xb1c
 12d:	6a 01                	push   $0x1
 12f:	e8 ef 05 00 00       	call   723 <printf>
 134:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < NUM_PROCS; i++) {
 137:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 13b:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 13f:	0f 8e 4a ff ff ff    	jle    8f <main+0x5b>

    }
  }

  // 충분히 실행할 시간 대기
  sleep(3000);
 145:	83 ec 0c             	sub    $0xc,%esp
 148:	68 b8 0b 00 00       	push   $0xbb8
 14d:	e8 dd 04 00 00       	call   62f <sleep>
 152:	83 c4 10             	add    $0x10,%esp

  if (getpinfo(&st) < 0) {
 155:	83 ec 0c             	sub    $0xc,%esp
 158:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 15e:	50                   	push   %eax
 15f:	e8 e3 04 00 00       	call   647 <getpinfo>
 164:	83 c4 10             	add    $0x10,%esp
 167:	85 c0                	test   %eax,%eax
 169:	79 17                	jns    182 <main+0x14e>
    printf(1, "getpinfo failed\n");
 16b:	83 ec 08             	sub    $0x8,%esp
 16e:	68 47 0b 00 00       	push   $0xb47
 173:	6a 01                	push   $0x1
 175:	e8 a9 05 00 00       	call   723 <printf>
 17a:	83 c4 10             	add    $0x10,%esp
    exit();
 17d:	e8 1d 04 00 00       	call   59f <exit>
  }

  // 결과 출력
  printf(1, "\n[결과] 각 프로세스의 우선순위 및 큐별 tick 정보:\n\n");
 182:	83 ec 08             	sub    $0x8,%esp
 185:	68 58 0b 00 00       	push   $0xb58
 18a:	6a 01                	push   $0x1
 18c:	e8 92 05 00 00       	call   723 <printf>
 191:	83 c4 10             	add    $0x10,%esp

  for (i = 0; i < NPROC; i++) {
 194:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 19b:	e9 46 01 00 00       	jmp    2e6 <main+0x2b2>
    if (st.inuse[i]) {
 1a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a3:	8b 84 85 e8 f3 ff ff 	mov    -0xc18(%ebp,%eax,4),%eax
 1aa:	85 c0                	test   %eax,%eax
 1ac:	0f 84 30 01 00 00    	je     2e2 <main+0x2ae>
      for (int j = 0; j < NUM_PROCS; j++) {
 1b2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 1b9:	e9 1a 01 00 00       	jmp    2d8 <main+0x2a4>
        if (st.pid[i] == pids[j]) {
 1be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c1:	83 c0 40             	add    $0x40,%eax
 1c4:	8b 94 85 e8 f3 ff ff 	mov    -0xc18(%ebp,%eax,4),%edx
 1cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1ce:	8b 84 85 d8 f3 ff ff 	mov    -0xc28(%ebp,%eax,4),%eax
 1d5:	39 c2                	cmp    %eax,%edx
 1d7:	0f 85 f7 00 00 00    	jne    2d4 <main+0x2a0>
          printf(1, "▶ 프로세스 %d (PID %d): 현재 큐 → Q%d\n", j + 1, st.pid[i], st.priority[i]);
 1dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e0:	83 e8 80             	sub    $0xffffff80,%eax
 1e3:	8b 94 85 e8 f3 ff ff 	mov    -0xc18(%ebp,%eax,4),%edx
 1ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ed:	83 c0 40             	add    $0x40,%eax
 1f0:	8b 84 85 e8 f3 ff ff 	mov    -0xc18(%ebp,%eax,4),%eax
 1f7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 1fa:	83 c1 01             	add    $0x1,%ecx
 1fd:	83 ec 0c             	sub    $0xc,%esp
 200:	52                   	push   %edx
 201:	50                   	push   %eax
 202:	51                   	push   %ecx
 203:	68 a0 0b 00 00       	push   $0xba0
 208:	6a 01                	push   $0x1
 20a:	e8 14 05 00 00       	call   723 <printf>
 20f:	83 c4 20             	add    $0x20,%esp
          printf(1, "   ticks       : Q0:%d  Q1:%d  Q2:%d  Q3:%d\n",
 212:	8b 45 f4             	mov    -0xc(%ebp),%eax
 215:	c1 e0 04             	shl    $0x4,%eax
 218:	8d 40 f8             	lea    -0x8(%eax),%eax
 21b:	01 e8                	add    %ebp,%eax
 21d:	2d 04 08 00 00       	sub    $0x804,%eax
 222:	8b 18                	mov    (%eax),%ebx
 224:	8b 45 f4             	mov    -0xc(%ebp),%eax
 227:	c1 e0 04             	shl    $0x4,%eax
 22a:	8d 40 f8             	lea    -0x8(%eax),%eax
 22d:	01 e8                	add    %ebp,%eax
 22f:	2d 08 08 00 00       	sub    $0x808,%eax
 234:	8b 08                	mov    (%eax),%ecx
 236:	8b 45 f4             	mov    -0xc(%ebp),%eax
 239:	c1 e0 04             	shl    $0x4,%eax
 23c:	8d 40 f8             	lea    -0x8(%eax),%eax
 23f:	01 e8                	add    %ebp,%eax
 241:	2d 0c 08 00 00       	sub    $0x80c,%eax
 246:	8b 10                	mov    (%eax),%edx
 248:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24b:	83 c0 40             	add    $0x40,%eax
 24e:	c1 e0 04             	shl    $0x4,%eax
 251:	8d 40 f8             	lea    -0x8(%eax),%eax
 254:	01 e8                	add    %ebp,%eax
 256:	2d 10 0c 00 00       	sub    $0xc10,%eax
 25b:	8b 00                	mov    (%eax),%eax
 25d:	83 ec 08             	sub    $0x8,%esp
 260:	53                   	push   %ebx
 261:	51                   	push   %ecx
 262:	52                   	push   %edx
 263:	50                   	push   %eax
 264:	68 d4 0b 00 00       	push   $0xbd4
 269:	6a 01                	push   $0x1
 26b:	e8 b3 04 00 00       	call   723 <printf>
 270:	83 c4 20             	add    $0x20,%esp
                 st.ticks[i][0], st.ticks[i][1], st.ticks[i][2], st.ticks[i][3]);
          printf(1, "   wait_ticks  : Q0:%d  Q1:%d  Q2:%d  Q3:%d\n\n",
 273:	8b 45 f4             	mov    -0xc(%ebp),%eax
 276:	c1 e0 04             	shl    $0x4,%eax
 279:	8d 40 f8             	lea    -0x8(%eax),%eax
 27c:	01 e8                	add    %ebp,%eax
 27e:	2d 04 04 00 00       	sub    $0x404,%eax
 283:	8b 18                	mov    (%eax),%ebx
 285:	8b 45 f4             	mov    -0xc(%ebp),%eax
 288:	c1 e0 04             	shl    $0x4,%eax
 28b:	8d 40 f8             	lea    -0x8(%eax),%eax
 28e:	01 e8                	add    %ebp,%eax
 290:	2d 08 04 00 00       	sub    $0x408,%eax
 295:	8b 08                	mov    (%eax),%ecx
 297:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29a:	c1 e0 04             	shl    $0x4,%eax
 29d:	8d 40 f8             	lea    -0x8(%eax),%eax
 2a0:	01 e8                	add    %ebp,%eax
 2a2:	2d 0c 04 00 00       	sub    $0x40c,%eax
 2a7:	8b 10                	mov    (%eax),%edx
 2a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ac:	83 e8 80             	sub    $0xffffff80,%eax
 2af:	c1 e0 04             	shl    $0x4,%eax
 2b2:	8d 40 f8             	lea    -0x8(%eax),%eax
 2b5:	01 e8                	add    %ebp,%eax
 2b7:	2d 10 0c 00 00       	sub    $0xc10,%eax
 2bc:	8b 00                	mov    (%eax),%eax
 2be:	83 ec 08             	sub    $0x8,%esp
 2c1:	53                   	push   %ebx
 2c2:	51                   	push   %ecx
 2c3:	52                   	push   %edx
 2c4:	50                   	push   %eax
 2c5:	68 04 0c 00 00       	push   $0xc04
 2ca:	6a 01                	push   $0x1
 2cc:	e8 52 04 00 00       	call   723 <printf>
 2d1:	83 c4 20             	add    $0x20,%esp
      for (int j = 0; j < NUM_PROCS; j++) {
 2d4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 2d8:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
 2dc:	0f 8e dc fe ff ff    	jle    1be <main+0x18a>
  for (i = 0; i < NPROC; i++) {
 2e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2e6:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 2ea:	0f 8e b0 fe ff ff    	jle    1a0 <main+0x16c>
      }
    }
  }

  // 자식 프로세스 정리
  for (i = 0; i < NUM_PROCS; i++)
 2f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2f7:	eb 1a                	jmp    313 <main+0x2df>
    kill(pids[i]);
 2f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fc:	8b 84 85 d8 f3 ff ff 	mov    -0xc28(%ebp,%eax,4),%eax
 303:	83 ec 0c             	sub    $0xc,%esp
 306:	50                   	push   %eax
 307:	e8 c3 02 00 00       	call   5cf <kill>
 30c:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < NUM_PROCS; i++)
 30f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 313:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 317:	7e e0                	jle    2f9 <main+0x2c5>
  for (i = 0; i < NUM_PROCS; i++)
 319:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 320:	eb 09                	jmp    32b <main+0x2f7>
    wait();
 322:	e8 80 02 00 00       	call   5a7 <wait>
  for (i = 0; i < NUM_PROCS; i++)
 327:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 32b:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 32f:	7e f1                	jle    322 <main+0x2ee>

  printf(1, "==== 종료 ====\n");
 331:	83 ec 08             	sub    $0x8,%esp
 334:	68 32 0c 00 00       	push   $0xc32
 339:	6a 01                	push   $0x1
 33b:	e8 e3 03 00 00       	call   723 <printf>
 340:	83 c4 10             	add    $0x10,%esp
  exit();
 343:	e8 57 02 00 00       	call   59f <exit>

00000348 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 348:	55                   	push   %ebp
 349:	89 e5                	mov    %esp,%ebp
 34b:	57                   	push   %edi
 34c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 34d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 350:	8b 55 10             	mov    0x10(%ebp),%edx
 353:	8b 45 0c             	mov    0xc(%ebp),%eax
 356:	89 cb                	mov    %ecx,%ebx
 358:	89 df                	mov    %ebx,%edi
 35a:	89 d1                	mov    %edx,%ecx
 35c:	fc                   	cld    
 35d:	f3 aa                	rep stos %al,%es:(%edi)
 35f:	89 ca                	mov    %ecx,%edx
 361:	89 fb                	mov    %edi,%ebx
 363:	89 5d 08             	mov    %ebx,0x8(%ebp)
 366:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 369:	90                   	nop
 36a:	5b                   	pop    %ebx
 36b:	5f                   	pop    %edi
 36c:	5d                   	pop    %ebp
 36d:	c3                   	ret    

0000036e <strcpy>:



char*
strcpy(char *s, char *t)
{
 36e:	55                   	push   %ebp
 36f:	89 e5                	mov    %esp,%ebp
 371:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 374:	8b 45 08             	mov    0x8(%ebp),%eax
 377:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 37a:	90                   	nop
 37b:	8b 55 0c             	mov    0xc(%ebp),%edx
 37e:	8d 42 01             	lea    0x1(%edx),%eax
 381:	89 45 0c             	mov    %eax,0xc(%ebp)
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	8d 48 01             	lea    0x1(%eax),%ecx
 38a:	89 4d 08             	mov    %ecx,0x8(%ebp)
 38d:	0f b6 12             	movzbl (%edx),%edx
 390:	88 10                	mov    %dl,(%eax)
 392:	0f b6 00             	movzbl (%eax),%eax
 395:	84 c0                	test   %al,%al
 397:	75 e2                	jne    37b <strcpy+0xd>
    ;
  return os;
 399:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 39c:	c9                   	leave  
 39d:	c3                   	ret    

0000039e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 39e:	55                   	push   %ebp
 39f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3a1:	eb 08                	jmp    3ab <strcmp+0xd>
    p++, q++;
 3a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	0f b6 00             	movzbl (%eax),%eax
 3b1:	84 c0                	test   %al,%al
 3b3:	74 10                	je     3c5 <strcmp+0x27>
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	0f b6 10             	movzbl (%eax),%edx
 3bb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3be:	0f b6 00             	movzbl (%eax),%eax
 3c1:	38 c2                	cmp    %al,%dl
 3c3:	74 de                	je     3a3 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
 3c8:	0f b6 00             	movzbl (%eax),%eax
 3cb:	0f b6 d0             	movzbl %al,%edx
 3ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d1:	0f b6 00             	movzbl (%eax),%eax
 3d4:	0f b6 c8             	movzbl %al,%ecx
 3d7:	89 d0                	mov    %edx,%eax
 3d9:	29 c8                	sub    %ecx,%eax
}
 3db:	5d                   	pop    %ebp
 3dc:	c3                   	ret    

000003dd <strlen>:

uint
strlen(char *s)
{
 3dd:	55                   	push   %ebp
 3de:	89 e5                	mov    %esp,%ebp
 3e0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3e3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3ea:	eb 04                	jmp    3f0 <strlen+0x13>
 3ec:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	01 d0                	add    %edx,%eax
 3f8:	0f b6 00             	movzbl (%eax),%eax
 3fb:	84 c0                	test   %al,%al
 3fd:	75 ed                	jne    3ec <strlen+0xf>
    ;
  return n;
 3ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 402:	c9                   	leave  
 403:	c3                   	ret    

00000404 <memset>:

void*
memset(void *dst, int c, uint n)
{
 404:	55                   	push   %ebp
 405:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 407:	8b 45 10             	mov    0x10(%ebp),%eax
 40a:	50                   	push   %eax
 40b:	ff 75 0c             	push   0xc(%ebp)
 40e:	ff 75 08             	push   0x8(%ebp)
 411:	e8 32 ff ff ff       	call   348 <stosb>
 416:	83 c4 0c             	add    $0xc,%esp
  return dst;
 419:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41c:	c9                   	leave  
 41d:	c3                   	ret    

0000041e <strchr>:

char*
strchr(const char *s, char c)
{
 41e:	55                   	push   %ebp
 41f:	89 e5                	mov    %esp,%ebp
 421:	83 ec 04             	sub    $0x4,%esp
 424:	8b 45 0c             	mov    0xc(%ebp),%eax
 427:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 42a:	eb 14                	jmp    440 <strchr+0x22>
    if(*s == c)
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
 42f:	0f b6 00             	movzbl (%eax),%eax
 432:	38 45 fc             	cmp    %al,-0x4(%ebp)
 435:	75 05                	jne    43c <strchr+0x1e>
      return (char*)s;
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	eb 13                	jmp    44f <strchr+0x31>
  for(; *s; s++)
 43c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 440:	8b 45 08             	mov    0x8(%ebp),%eax
 443:	0f b6 00             	movzbl (%eax),%eax
 446:	84 c0                	test   %al,%al
 448:	75 e2                	jne    42c <strchr+0xe>
  return 0;
 44a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 44f:	c9                   	leave  
 450:	c3                   	ret    

00000451 <gets>:

char*
gets(char *buf, int max)
{
 451:	55                   	push   %ebp
 452:	89 e5                	mov    %esp,%ebp
 454:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 457:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 45e:	eb 42                	jmp    4a2 <gets+0x51>
    cc = read(0, &c, 1);
 460:	83 ec 04             	sub    $0x4,%esp
 463:	6a 01                	push   $0x1
 465:	8d 45 ef             	lea    -0x11(%ebp),%eax
 468:	50                   	push   %eax
 469:	6a 00                	push   $0x0
 46b:	e8 47 01 00 00       	call   5b7 <read>
 470:	83 c4 10             	add    $0x10,%esp
 473:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 476:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 47a:	7e 33                	jle    4af <gets+0x5e>
      break;
    buf[i++] = c;
 47c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47f:	8d 50 01             	lea    0x1(%eax),%edx
 482:	89 55 f4             	mov    %edx,-0xc(%ebp)
 485:	89 c2                	mov    %eax,%edx
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	01 c2                	add    %eax,%edx
 48c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 490:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 492:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 496:	3c 0a                	cmp    $0xa,%al
 498:	74 16                	je     4b0 <gets+0x5f>
 49a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 49e:	3c 0d                	cmp    $0xd,%al
 4a0:	74 0e                	je     4b0 <gets+0x5f>
  for(i=0; i+1 < max; ){
 4a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a5:	83 c0 01             	add    $0x1,%eax
 4a8:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4ab:	7f b3                	jg     460 <gets+0xf>
 4ad:	eb 01                	jmp    4b0 <gets+0x5f>
      break;
 4af:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4b3:	8b 45 08             	mov    0x8(%ebp),%eax
 4b6:	01 d0                	add    %edx,%eax
 4b8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4be:	c9                   	leave  
 4bf:	c3                   	ret    

000004c0 <stat>:

int
stat(char *n, struct stat *st)
{
 4c0:	55                   	push   %ebp
 4c1:	89 e5                	mov    %esp,%ebp
 4c3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4c6:	83 ec 08             	sub    $0x8,%esp
 4c9:	6a 00                	push   $0x0
 4cb:	ff 75 08             	push   0x8(%ebp)
 4ce:	e8 0c 01 00 00       	call   5df <open>
 4d3:	83 c4 10             	add    $0x10,%esp
 4d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4dd:	79 07                	jns    4e6 <stat+0x26>
    return -1;
 4df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4e4:	eb 25                	jmp    50b <stat+0x4b>
  r = fstat(fd, st);
 4e6:	83 ec 08             	sub    $0x8,%esp
 4e9:	ff 75 0c             	push   0xc(%ebp)
 4ec:	ff 75 f4             	push   -0xc(%ebp)
 4ef:	e8 03 01 00 00       	call   5f7 <fstat>
 4f4:	83 c4 10             	add    $0x10,%esp
 4f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4fa:	83 ec 0c             	sub    $0xc,%esp
 4fd:	ff 75 f4             	push   -0xc(%ebp)
 500:	e8 c2 00 00 00       	call   5c7 <close>
 505:	83 c4 10             	add    $0x10,%esp
  return r;
 508:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 50b:	c9                   	leave  
 50c:	c3                   	ret    

0000050d <atoi>:

int
atoi(const char *s)
{
 50d:	55                   	push   %ebp
 50e:	89 e5                	mov    %esp,%ebp
 510:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 513:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 51a:	eb 25                	jmp    541 <atoi+0x34>
    n = n*10 + *s++ - '0';
 51c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 51f:	89 d0                	mov    %edx,%eax
 521:	c1 e0 02             	shl    $0x2,%eax
 524:	01 d0                	add    %edx,%eax
 526:	01 c0                	add    %eax,%eax
 528:	89 c1                	mov    %eax,%ecx
 52a:	8b 45 08             	mov    0x8(%ebp),%eax
 52d:	8d 50 01             	lea    0x1(%eax),%edx
 530:	89 55 08             	mov    %edx,0x8(%ebp)
 533:	0f b6 00             	movzbl (%eax),%eax
 536:	0f be c0             	movsbl %al,%eax
 539:	01 c8                	add    %ecx,%eax
 53b:	83 e8 30             	sub    $0x30,%eax
 53e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 541:	8b 45 08             	mov    0x8(%ebp),%eax
 544:	0f b6 00             	movzbl (%eax),%eax
 547:	3c 2f                	cmp    $0x2f,%al
 549:	7e 0a                	jle    555 <atoi+0x48>
 54b:	8b 45 08             	mov    0x8(%ebp),%eax
 54e:	0f b6 00             	movzbl (%eax),%eax
 551:	3c 39                	cmp    $0x39,%al
 553:	7e c7                	jle    51c <atoi+0xf>
  return n;
 555:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 558:	c9                   	leave  
 559:	c3                   	ret    

0000055a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 55a:	55                   	push   %ebp
 55b:	89 e5                	mov    %esp,%ebp
 55d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 560:	8b 45 08             	mov    0x8(%ebp),%eax
 563:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 566:	8b 45 0c             	mov    0xc(%ebp),%eax
 569:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 56c:	eb 17                	jmp    585 <memmove+0x2b>
    *dst++ = *src++;
 56e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 571:	8d 42 01             	lea    0x1(%edx),%eax
 574:	89 45 f8             	mov    %eax,-0x8(%ebp)
 577:	8b 45 fc             	mov    -0x4(%ebp),%eax
 57a:	8d 48 01             	lea    0x1(%eax),%ecx
 57d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 580:	0f b6 12             	movzbl (%edx),%edx
 583:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 585:	8b 45 10             	mov    0x10(%ebp),%eax
 588:	8d 50 ff             	lea    -0x1(%eax),%edx
 58b:	89 55 10             	mov    %edx,0x10(%ebp)
 58e:	85 c0                	test   %eax,%eax
 590:	7f dc                	jg     56e <memmove+0x14>
  return vdst;
 592:	8b 45 08             	mov    0x8(%ebp),%eax
}
 595:	c9                   	leave  
 596:	c3                   	ret    

00000597 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 597:	b8 01 00 00 00       	mov    $0x1,%eax
 59c:	cd 40                	int    $0x40
 59e:	c3                   	ret    

0000059f <exit>:
SYSCALL(exit)
 59f:	b8 02 00 00 00       	mov    $0x2,%eax
 5a4:	cd 40                	int    $0x40
 5a6:	c3                   	ret    

000005a7 <wait>:
SYSCALL(wait)
 5a7:	b8 03 00 00 00       	mov    $0x3,%eax
 5ac:	cd 40                	int    $0x40
 5ae:	c3                   	ret    

000005af <pipe>:
SYSCALL(pipe)
 5af:	b8 04 00 00 00       	mov    $0x4,%eax
 5b4:	cd 40                	int    $0x40
 5b6:	c3                   	ret    

000005b7 <read>:
SYSCALL(read)
 5b7:	b8 05 00 00 00       	mov    $0x5,%eax
 5bc:	cd 40                	int    $0x40
 5be:	c3                   	ret    

000005bf <write>:
SYSCALL(write)
 5bf:	b8 10 00 00 00       	mov    $0x10,%eax
 5c4:	cd 40                	int    $0x40
 5c6:	c3                   	ret    

000005c7 <close>:
SYSCALL(close)
 5c7:	b8 15 00 00 00       	mov    $0x15,%eax
 5cc:	cd 40                	int    $0x40
 5ce:	c3                   	ret    

000005cf <kill>:
SYSCALL(kill)
 5cf:	b8 06 00 00 00       	mov    $0x6,%eax
 5d4:	cd 40                	int    $0x40
 5d6:	c3                   	ret    

000005d7 <exec>:
SYSCALL(exec)
 5d7:	b8 07 00 00 00       	mov    $0x7,%eax
 5dc:	cd 40                	int    $0x40
 5de:	c3                   	ret    

000005df <open>:
SYSCALL(open)
 5df:	b8 0f 00 00 00       	mov    $0xf,%eax
 5e4:	cd 40                	int    $0x40
 5e6:	c3                   	ret    

000005e7 <mknod>:
SYSCALL(mknod)
 5e7:	b8 11 00 00 00       	mov    $0x11,%eax
 5ec:	cd 40                	int    $0x40
 5ee:	c3                   	ret    

000005ef <unlink>:
SYSCALL(unlink)
 5ef:	b8 12 00 00 00       	mov    $0x12,%eax
 5f4:	cd 40                	int    $0x40
 5f6:	c3                   	ret    

000005f7 <fstat>:
SYSCALL(fstat)
 5f7:	b8 08 00 00 00       	mov    $0x8,%eax
 5fc:	cd 40                	int    $0x40
 5fe:	c3                   	ret    

000005ff <link>:
SYSCALL(link)
 5ff:	b8 13 00 00 00       	mov    $0x13,%eax
 604:	cd 40                	int    $0x40
 606:	c3                   	ret    

00000607 <mkdir>:
SYSCALL(mkdir)
 607:	b8 14 00 00 00       	mov    $0x14,%eax
 60c:	cd 40                	int    $0x40
 60e:	c3                   	ret    

0000060f <chdir>:
SYSCALL(chdir)
 60f:	b8 09 00 00 00       	mov    $0x9,%eax
 614:	cd 40                	int    $0x40
 616:	c3                   	ret    

00000617 <dup>:
SYSCALL(dup)
 617:	b8 0a 00 00 00       	mov    $0xa,%eax
 61c:	cd 40                	int    $0x40
 61e:	c3                   	ret    

0000061f <getpid>:
SYSCALL(getpid)
 61f:	b8 0b 00 00 00       	mov    $0xb,%eax
 624:	cd 40                	int    $0x40
 626:	c3                   	ret    

00000627 <sbrk>:
SYSCALL(sbrk)
 627:	b8 0c 00 00 00       	mov    $0xc,%eax
 62c:	cd 40                	int    $0x40
 62e:	c3                   	ret    

0000062f <sleep>:
SYSCALL(sleep)
 62f:	b8 0d 00 00 00       	mov    $0xd,%eax
 634:	cd 40                	int    $0x40
 636:	c3                   	ret    

00000637 <uptime>:
SYSCALL(uptime)
 637:	b8 0e 00 00 00       	mov    $0xe,%eax
 63c:	cd 40                	int    $0x40
 63e:	c3                   	ret    

0000063f <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 63f:	b8 16 00 00 00       	mov    $0x16,%eax
 644:	cd 40                	int    $0x40
 646:	c3                   	ret    

00000647 <getpinfo>:
SYSCALL(getpinfo)
 647:	b8 17 00 00 00       	mov    $0x17,%eax
 64c:	cd 40                	int    $0x40
 64e:	c3                   	ret    

0000064f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 64f:	55                   	push   %ebp
 650:	89 e5                	mov    %esp,%ebp
 652:	83 ec 18             	sub    $0x18,%esp
 655:	8b 45 0c             	mov    0xc(%ebp),%eax
 658:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 65b:	83 ec 04             	sub    $0x4,%esp
 65e:	6a 01                	push   $0x1
 660:	8d 45 f4             	lea    -0xc(%ebp),%eax
 663:	50                   	push   %eax
 664:	ff 75 08             	push   0x8(%ebp)
 667:	e8 53 ff ff ff       	call   5bf <write>
 66c:	83 c4 10             	add    $0x10,%esp
}
 66f:	90                   	nop
 670:	c9                   	leave  
 671:	c3                   	ret    

00000672 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 672:	55                   	push   %ebp
 673:	89 e5                	mov    %esp,%ebp
 675:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 678:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 67f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 683:	74 17                	je     69c <printint+0x2a>
 685:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 689:	79 11                	jns    69c <printint+0x2a>
    neg = 1;
 68b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 692:	8b 45 0c             	mov    0xc(%ebp),%eax
 695:	f7 d8                	neg    %eax
 697:	89 45 ec             	mov    %eax,-0x14(%ebp)
 69a:	eb 06                	jmp    6a2 <printint+0x30>
  } else {
    x = xx;
 69c:	8b 45 0c             	mov    0xc(%ebp),%eax
 69f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6af:	ba 00 00 00 00       	mov    $0x0,%edx
 6b4:	f7 f1                	div    %ecx
 6b6:	89 d1                	mov    %edx,%ecx
 6b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bb:	8d 50 01             	lea    0x1(%eax),%edx
 6be:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6c1:	0f b6 91 b4 0e 00 00 	movzbl 0xeb4(%ecx),%edx
 6c8:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d2:	ba 00 00 00 00       	mov    $0x0,%edx
 6d7:	f7 f1                	div    %ecx
 6d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e0:	75 c7                	jne    6a9 <printint+0x37>
  if(neg)
 6e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6e6:	74 2d                	je     715 <printint+0xa3>
    buf[i++] = '-';
 6e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6eb:	8d 50 01             	lea    0x1(%eax),%edx
 6ee:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6f1:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6f6:	eb 1d                	jmp    715 <printint+0xa3>
    putc(fd, buf[i]);
 6f8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6fe:	01 d0                	add    %edx,%eax
 700:	0f b6 00             	movzbl (%eax),%eax
 703:	0f be c0             	movsbl %al,%eax
 706:	83 ec 08             	sub    $0x8,%esp
 709:	50                   	push   %eax
 70a:	ff 75 08             	push   0x8(%ebp)
 70d:	e8 3d ff ff ff       	call   64f <putc>
 712:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 715:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 719:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 71d:	79 d9                	jns    6f8 <printint+0x86>
}
 71f:	90                   	nop
 720:	90                   	nop
 721:	c9                   	leave  
 722:	c3                   	ret    

00000723 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 723:	55                   	push   %ebp
 724:	89 e5                	mov    %esp,%ebp
 726:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 729:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 730:	8d 45 0c             	lea    0xc(%ebp),%eax
 733:	83 c0 04             	add    $0x4,%eax
 736:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 739:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 740:	e9 59 01 00 00       	jmp    89e <printf+0x17b>
    c = fmt[i] & 0xff;
 745:	8b 55 0c             	mov    0xc(%ebp),%edx
 748:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74b:	01 d0                	add    %edx,%eax
 74d:	0f b6 00             	movzbl (%eax),%eax
 750:	0f be c0             	movsbl %al,%eax
 753:	25 ff 00 00 00       	and    $0xff,%eax
 758:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 75b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 75f:	75 2c                	jne    78d <printf+0x6a>
      if(c == '%'){
 761:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 765:	75 0c                	jne    773 <printf+0x50>
        state = '%';
 767:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 76e:	e9 27 01 00 00       	jmp    89a <printf+0x177>
      } else {
        putc(fd, c);
 773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 776:	0f be c0             	movsbl %al,%eax
 779:	83 ec 08             	sub    $0x8,%esp
 77c:	50                   	push   %eax
 77d:	ff 75 08             	push   0x8(%ebp)
 780:	e8 ca fe ff ff       	call   64f <putc>
 785:	83 c4 10             	add    $0x10,%esp
 788:	e9 0d 01 00 00       	jmp    89a <printf+0x177>
      }
    } else if(state == '%'){
 78d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 791:	0f 85 03 01 00 00    	jne    89a <printf+0x177>
      if(c == 'd'){
 797:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 79b:	75 1e                	jne    7bb <printf+0x98>
        printint(fd, *ap, 10, 1);
 79d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a0:	8b 00                	mov    (%eax),%eax
 7a2:	6a 01                	push   $0x1
 7a4:	6a 0a                	push   $0xa
 7a6:	50                   	push   %eax
 7a7:	ff 75 08             	push   0x8(%ebp)
 7aa:	e8 c3 fe ff ff       	call   672 <printint>
 7af:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b6:	e9 d8 00 00 00       	jmp    893 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7bb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7bf:	74 06                	je     7c7 <printf+0xa4>
 7c1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7c5:	75 1e                	jne    7e5 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ca:	8b 00                	mov    (%eax),%eax
 7cc:	6a 00                	push   $0x0
 7ce:	6a 10                	push   $0x10
 7d0:	50                   	push   %eax
 7d1:	ff 75 08             	push   0x8(%ebp)
 7d4:	e8 99 fe ff ff       	call   672 <printint>
 7d9:	83 c4 10             	add    $0x10,%esp
        ap++;
 7dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e0:	e9 ae 00 00 00       	jmp    893 <printf+0x170>
      } else if(c == 's'){
 7e5:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7e9:	75 43                	jne    82e <printf+0x10b>
        s = (char*)*ap;
 7eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ee:	8b 00                	mov    (%eax),%eax
 7f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7f3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7fb:	75 25                	jne    822 <printf+0xff>
          s = "(null)";
 7fd:	c7 45 f4 44 0c 00 00 	movl   $0xc44,-0xc(%ebp)
        while(*s != 0){
 804:	eb 1c                	jmp    822 <printf+0xff>
          putc(fd, *s);
 806:	8b 45 f4             	mov    -0xc(%ebp),%eax
 809:	0f b6 00             	movzbl (%eax),%eax
 80c:	0f be c0             	movsbl %al,%eax
 80f:	83 ec 08             	sub    $0x8,%esp
 812:	50                   	push   %eax
 813:	ff 75 08             	push   0x8(%ebp)
 816:	e8 34 fe ff ff       	call   64f <putc>
 81b:	83 c4 10             	add    $0x10,%esp
          s++;
 81e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 822:	8b 45 f4             	mov    -0xc(%ebp),%eax
 825:	0f b6 00             	movzbl (%eax),%eax
 828:	84 c0                	test   %al,%al
 82a:	75 da                	jne    806 <printf+0xe3>
 82c:	eb 65                	jmp    893 <printf+0x170>
        }
      } else if(c == 'c'){
 82e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 832:	75 1d                	jne    851 <printf+0x12e>
        putc(fd, *ap);
 834:	8b 45 e8             	mov    -0x18(%ebp),%eax
 837:	8b 00                	mov    (%eax),%eax
 839:	0f be c0             	movsbl %al,%eax
 83c:	83 ec 08             	sub    $0x8,%esp
 83f:	50                   	push   %eax
 840:	ff 75 08             	push   0x8(%ebp)
 843:	e8 07 fe ff ff       	call   64f <putc>
 848:	83 c4 10             	add    $0x10,%esp
        ap++;
 84b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 84f:	eb 42                	jmp    893 <printf+0x170>
      } else if(c == '%'){
 851:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 855:	75 17                	jne    86e <printf+0x14b>
        putc(fd, c);
 857:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 85a:	0f be c0             	movsbl %al,%eax
 85d:	83 ec 08             	sub    $0x8,%esp
 860:	50                   	push   %eax
 861:	ff 75 08             	push   0x8(%ebp)
 864:	e8 e6 fd ff ff       	call   64f <putc>
 869:	83 c4 10             	add    $0x10,%esp
 86c:	eb 25                	jmp    893 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 86e:	83 ec 08             	sub    $0x8,%esp
 871:	6a 25                	push   $0x25
 873:	ff 75 08             	push   0x8(%ebp)
 876:	e8 d4 fd ff ff       	call   64f <putc>
 87b:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 87e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 881:	0f be c0             	movsbl %al,%eax
 884:	83 ec 08             	sub    $0x8,%esp
 887:	50                   	push   %eax
 888:	ff 75 08             	push   0x8(%ebp)
 88b:	e8 bf fd ff ff       	call   64f <putc>
 890:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 893:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 89a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 89e:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a4:	01 d0                	add    %edx,%eax
 8a6:	0f b6 00             	movzbl (%eax),%eax
 8a9:	84 c0                	test   %al,%al
 8ab:	0f 85 94 fe ff ff    	jne    745 <printf+0x22>
    }
  }
}
 8b1:	90                   	nop
 8b2:	90                   	nop
 8b3:	c9                   	leave  
 8b4:	c3                   	ret    

000008b5 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b5:	55                   	push   %ebp
 8b6:	89 e5                	mov    %esp,%ebp
 8b8:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8bb:	8b 45 08             	mov    0x8(%ebp),%eax
 8be:	83 e8 08             	sub    $0x8,%eax
 8c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c4:	a1 d0 0e 00 00       	mov    0xed0,%eax
 8c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8cc:	eb 24                	jmp    8f2 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d1:	8b 00                	mov    (%eax),%eax
 8d3:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8d6:	72 12                	jb     8ea <free+0x35>
 8d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8de:	77 24                	ja     904 <free+0x4f>
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 00                	mov    (%eax),%eax
 8e5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8e8:	72 1a                	jb     904 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ed:	8b 00                	mov    (%eax),%eax
 8ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8f8:	76 d4                	jbe    8ce <free+0x19>
 8fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fd:	8b 00                	mov    (%eax),%eax
 8ff:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 902:	73 ca                	jae    8ce <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 904:	8b 45 f8             	mov    -0x8(%ebp),%eax
 907:	8b 40 04             	mov    0x4(%eax),%eax
 90a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 911:	8b 45 f8             	mov    -0x8(%ebp),%eax
 914:	01 c2                	add    %eax,%edx
 916:	8b 45 fc             	mov    -0x4(%ebp),%eax
 919:	8b 00                	mov    (%eax),%eax
 91b:	39 c2                	cmp    %eax,%edx
 91d:	75 24                	jne    943 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 91f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 922:	8b 50 04             	mov    0x4(%eax),%edx
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	8b 00                	mov    (%eax),%eax
 92a:	8b 40 04             	mov    0x4(%eax),%eax
 92d:	01 c2                	add    %eax,%edx
 92f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 932:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 935:	8b 45 fc             	mov    -0x4(%ebp),%eax
 938:	8b 00                	mov    (%eax),%eax
 93a:	8b 10                	mov    (%eax),%edx
 93c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93f:	89 10                	mov    %edx,(%eax)
 941:	eb 0a                	jmp    94d <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 943:	8b 45 fc             	mov    -0x4(%ebp),%eax
 946:	8b 10                	mov    (%eax),%edx
 948:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 94d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 950:	8b 40 04             	mov    0x4(%eax),%eax
 953:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 95a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95d:	01 d0                	add    %edx,%eax
 95f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 962:	75 20                	jne    984 <free+0xcf>
    p->s.size += bp->s.size;
 964:	8b 45 fc             	mov    -0x4(%ebp),%eax
 967:	8b 50 04             	mov    0x4(%eax),%edx
 96a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96d:	8b 40 04             	mov    0x4(%eax),%eax
 970:	01 c2                	add    %eax,%edx
 972:	8b 45 fc             	mov    -0x4(%ebp),%eax
 975:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 978:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97b:	8b 10                	mov    (%eax),%edx
 97d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 980:	89 10                	mov    %edx,(%eax)
 982:	eb 08                	jmp    98c <free+0xd7>
  } else
    p->s.ptr = bp;
 984:	8b 45 fc             	mov    -0x4(%ebp),%eax
 987:	8b 55 f8             	mov    -0x8(%ebp),%edx
 98a:	89 10                	mov    %edx,(%eax)
  freep = p;
 98c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98f:	a3 d0 0e 00 00       	mov    %eax,0xed0
}
 994:	90                   	nop
 995:	c9                   	leave  
 996:	c3                   	ret    

00000997 <morecore>:

static Header*
morecore(uint nu)
{
 997:	55                   	push   %ebp
 998:	89 e5                	mov    %esp,%ebp
 99a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 99d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9a4:	77 07                	ja     9ad <morecore+0x16>
    nu = 4096;
 9a6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9ad:	8b 45 08             	mov    0x8(%ebp),%eax
 9b0:	c1 e0 03             	shl    $0x3,%eax
 9b3:	83 ec 0c             	sub    $0xc,%esp
 9b6:	50                   	push   %eax
 9b7:	e8 6b fc ff ff       	call   627 <sbrk>
 9bc:	83 c4 10             	add    $0x10,%esp
 9bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9c2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9c6:	75 07                	jne    9cf <morecore+0x38>
    return 0;
 9c8:	b8 00 00 00 00       	mov    $0x0,%eax
 9cd:	eb 26                	jmp    9f5 <morecore+0x5e>
  hp = (Header*)p;
 9cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d8:	8b 55 08             	mov    0x8(%ebp),%edx
 9db:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e1:	83 c0 08             	add    $0x8,%eax
 9e4:	83 ec 0c             	sub    $0xc,%esp
 9e7:	50                   	push   %eax
 9e8:	e8 c8 fe ff ff       	call   8b5 <free>
 9ed:	83 c4 10             	add    $0x10,%esp
  return freep;
 9f0:	a1 d0 0e 00 00       	mov    0xed0,%eax
}
 9f5:	c9                   	leave  
 9f6:	c3                   	ret    

000009f7 <malloc>:

void*
malloc(uint nbytes)
{
 9f7:	55                   	push   %ebp
 9f8:	89 e5                	mov    %esp,%ebp
 9fa:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9fd:	8b 45 08             	mov    0x8(%ebp),%eax
 a00:	83 c0 07             	add    $0x7,%eax
 a03:	c1 e8 03             	shr    $0x3,%eax
 a06:	83 c0 01             	add    $0x1,%eax
 a09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a0c:	a1 d0 0e 00 00       	mov    0xed0,%eax
 a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a18:	75 23                	jne    a3d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a1a:	c7 45 f0 c8 0e 00 00 	movl   $0xec8,-0x10(%ebp)
 a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a24:	a3 d0 0e 00 00       	mov    %eax,0xed0
 a29:	a1 d0 0e 00 00       	mov    0xed0,%eax
 a2e:	a3 c8 0e 00 00       	mov    %eax,0xec8
    base.s.size = 0;
 a33:	c7 05 cc 0e 00 00 00 	movl   $0x0,0xecc
 a3a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a40:	8b 00                	mov    (%eax),%eax
 a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a48:	8b 40 04             	mov    0x4(%eax),%eax
 a4b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a4e:	77 4d                	ja     a9d <malloc+0xa6>
      if(p->s.size == nunits)
 a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a53:	8b 40 04             	mov    0x4(%eax),%eax
 a56:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a59:	75 0c                	jne    a67 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5e:	8b 10                	mov    (%eax),%edx
 a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a63:	89 10                	mov    %edx,(%eax)
 a65:	eb 26                	jmp    a8d <malloc+0x96>
      else {
        p->s.size -= nunits;
 a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6a:	8b 40 04             	mov    0x4(%eax),%eax
 a6d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a70:	89 c2                	mov    %eax,%edx
 a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a75:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7b:	8b 40 04             	mov    0x4(%eax),%eax
 a7e:	c1 e0 03             	shl    $0x3,%eax
 a81:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a87:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a8a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a90:	a3 d0 0e 00 00       	mov    %eax,0xed0
      return (void*)(p + 1);
 a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a98:	83 c0 08             	add    $0x8,%eax
 a9b:	eb 3b                	jmp    ad8 <malloc+0xe1>
    }
    if(p == freep)
 a9d:	a1 d0 0e 00 00       	mov    0xed0,%eax
 aa2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 aa5:	75 1e                	jne    ac5 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 aa7:	83 ec 0c             	sub    $0xc,%esp
 aaa:	ff 75 ec             	push   -0x14(%ebp)
 aad:	e8 e5 fe ff ff       	call   997 <morecore>
 ab2:	83 c4 10             	add    $0x10,%esp
 ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ab8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 abc:	75 07                	jne    ac5 <malloc+0xce>
        return 0;
 abe:	b8 00 00 00 00       	mov    $0x0,%eax
 ac3:	eb 13                	jmp    ad8 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ace:	8b 00                	mov    (%eax),%eax
 ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ad3:	e9 6d ff ff ff       	jmp    a45 <malloc+0x4e>
  }
}
 ad8:	c9                   	leave  
 ad9:	c3                   	ret    
