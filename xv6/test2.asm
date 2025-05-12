
_test2:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#define NUM_PROCS 4
#define ITER 20



int workload(int n) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  volatile int x = 0;
  11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for (i = 0; i < n; i++) {
  18:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1f:	eb 34                	jmp    55 <workload+0x55>
    x += i % 3;
  21:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  24:	ba 56 55 55 55       	mov    $0x55555556,%edx
  29:	89 c8                	mov    %ecx,%eax
  2b:	f7 ea                	imul   %edx
  2d:	89 c8                	mov    %ecx,%eax
  2f:	c1 f8 1f             	sar    $0x1f,%eax
  32:	29 c2                	sub    %eax,%edx
  34:	89 d0                	mov    %edx,%eax
  36:	01 c0                	add    %eax,%eax
  38:	01 d0                	add    %edx,%eax
  3a:	29 c1                	sub    %eax,%ecx
  3c:	89 ca                	mov    %ecx,%edx
  3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  41:	01 d0                	add    %edx,%eax
  43:	89 45 f4             	mov    %eax,-0xc(%ebp)
    j += x + i;
  46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  49:	8b 45 fc             	mov    -0x4(%ebp),%eax
  4c:	01 d0                	add    %edx,%eax
  4e:	01 45 f8             	add    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++) {
  51:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  55:	8b 45 fc             	mov    -0x4(%ebp),%eax
  58:	3b 45 08             	cmp    0x8(%ebp),%eax
  5b:	7c c4                	jl     21 <workload+0x21>
  }
  return j;
  5d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  60:	c9                   	leave  
  61:	c3                   	ret    

00000062 <main>:

int main(void) {
  62:	f3 0f 1e fb          	endbr32 
  66:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  6a:	83 e4 f0             	and    $0xfffffff0,%esp
  6d:	ff 71 fc             	pushl  -0x4(%ecx)
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	56                   	push   %esi
  74:	53                   	push   %ebx
  75:	51                   	push   %ecx
  76:	81 ec 3c 0c 00 00    	sub    $0xc3c,%esp
  struct pstat st;
  int pids[NUM_PROCS];

  printf(1, "\n==== [TEST2: MLFQ w/o tracking] ====\n");
  7c:	83 ec 08             	sub    $0x8,%esp
  7f:	68 40 0b 00 00       	push   $0xb40
  84:	6a 01                	push   $0x1
  86:	e8 ee 06 00 00       	call   779 <printf>
  8b:	83 c4 10             	add    $0x10,%esp

  if (setSchedPolicy(2) < 0) {
  8e:	83 ec 0c             	sub    $0xc,%esp
  91:	6a 02                	push   $0x2
  93:	e8 ed 05 00 00       	call   685 <setSchedPolicy>
  98:	83 c4 10             	add    $0x10,%esp
  9b:	85 c0                	test   %eax,%eax
  9d:	79 17                	jns    b6 <main+0x54>
    printf(1, "setSchedPolicy(2) failed!\n");
  9f:	83 ec 08             	sub    $0x8,%esp
  a2:	68 67 0b 00 00       	push   $0xb67
  a7:	6a 01                	push   $0x1
  a9:	e8 cb 06 00 00       	call   779 <printf>
  ae:	83 c4 10             	add    $0x10,%esp
    exit();
  b1:	e8 2f 05 00 00       	call   5e5 <exit>
  }

  for (int i = 0; i < NUM_PROCS; i++) {
  b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  bd:	e9 9b 00 00 00       	jmp    15d <main+0xfb>
    int pid = fork();
  c2:	e8 16 05 00 00       	call   5dd <fork>
  c7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if (pid == 0) {
  ca:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  ce:	75 7c                	jne    14c <main+0xea>
      // 자식 프로세스
      for (int t = 0; t < ITER; t++) {
  d0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  d7:	eb 68                	jmp    141 <main+0xdf>
        workload((i + 1) * 2000000);  // Q 강등 유도용
  d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  dc:	83 c0 01             	add    $0x1,%eax
  df:	69 c0 80 84 1e 00    	imul   $0x1e8480,%eax,%eax
  e5:	83 ec 0c             	sub    $0xc,%esp
  e8:	50                   	push   %eax
  e9:	e8 12 ff ff ff       	call   0 <workload>
  ee:	83 c4 10             	add    $0x10,%esp
        sleep(10);  // yield() 유도
  f1:	83 ec 0c             	sub    $0xc,%esp
  f4:	6a 0a                	push   $0xa
  f6:	e8 7a 05 00 00       	call   675 <sleep>
  fb:	83 c4 10             	add    $0x10,%esp
        if (t % 5 == 0 && getpid() % 2 == 0) sleep(0);  // 일부러 섞기
  fe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 101:	ba 67 66 66 66       	mov    $0x66666667,%edx
 106:	89 c8                	mov    %ecx,%eax
 108:	f7 ea                	imul   %edx
 10a:	d1 fa                	sar    %edx
 10c:	89 c8                	mov    %ecx,%eax
 10e:	c1 f8 1f             	sar    $0x1f,%eax
 111:	29 c2                	sub    %eax,%edx
 113:	89 d0                	mov    %edx,%eax
 115:	89 c2                	mov    %eax,%edx
 117:	c1 e2 02             	shl    $0x2,%edx
 11a:	01 c2                	add    %eax,%edx
 11c:	89 c8                	mov    %ecx,%eax
 11e:	29 d0                	sub    %edx,%eax
 120:	85 c0                	test   %eax,%eax
 122:	75 19                	jne    13d <main+0xdb>
 124:	e8 3c 05 00 00       	call   665 <getpid>
 129:	83 e0 01             	and    $0x1,%eax
 12c:	85 c0                	test   %eax,%eax
 12e:	75 0d                	jne    13d <main+0xdb>
 130:	83 ec 0c             	sub    $0xc,%esp
 133:	6a 00                	push   $0x0
 135:	e8 3b 05 00 00       	call   675 <sleep>
 13a:	83 c4 10             	add    $0x10,%esp
      for (int t = 0; t < ITER; t++) {
 13d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
 141:	83 7d e0 13          	cmpl   $0x13,-0x20(%ebp)
 145:	7e 92                	jle    d9 <main+0x77>
      }
      exit();
 147:	e8 99 04 00 00       	call   5e5 <exit>
    } else {
      pids[i] = pid;
 14c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 14f:	8b 55 cc             	mov    -0x34(%ebp),%edx
 152:	89 94 85 bc f3 ff ff 	mov    %edx,-0xc44(%ebp,%eax,4)
  for (int i = 0; i < NUM_PROCS; i++) {
 159:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 15d:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
 161:	0f 8e 5b ff ff ff    	jle    c2 <main+0x60>
    }
  }

  sleep(300);  // 충분한 실행 시간
 167:	83 ec 0c             	sub    $0xc,%esp
 16a:	68 2c 01 00 00       	push   $0x12c
 16f:	e8 01 05 00 00       	call   675 <sleep>
 174:	83 c4 10             	add    $0x10,%esp

  if (getpinfo(&st) < 0) {
 177:	83 ec 0c             	sub    $0xc,%esp
 17a:	8d 85 cc f3 ff ff    	lea    -0xc34(%ebp),%eax
 180:	50                   	push   %eax
 181:	e8 07 05 00 00       	call   68d <getpinfo>
 186:	83 c4 10             	add    $0x10,%esp
 189:	85 c0                	test   %eax,%eax
 18b:	79 17                	jns    1a4 <main+0x142>
    printf(1, "getpinfo 실패\n");
 18d:	83 ec 08             	sub    $0x8,%esp
 190:	68 82 0b 00 00       	push   $0xb82
 195:	6a 01                	push   $0x1
 197:	e8 dd 05 00 00       	call   779 <printf>
 19c:	83 c4 10             	add    $0x10,%esp
    exit();
 19f:	e8 41 04 00 00       	call   5e5 <exit>
  }

  printf(1, "\n=== [RESULT: TEST2 - policy 2] ===\n");
 1a4:	83 ec 08             	sub    $0x8,%esp
 1a7:	68 94 0b 00 00       	push   $0xb94
 1ac:	6a 01                	push   $0x1
 1ae:	e8 c6 05 00 00       	call   779 <printf>
 1b3:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
 1b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 1bd:	e9 46 01 00 00       	jmp    308 <main+0x2a6>
    for (int j = 0; j < NUM_PROCS; j++) {
 1c2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 1c9:	e9 2c 01 00 00       	jmp    2fa <main+0x298>
      if (st.inuse[i] && st.pid[i] == pids[j]) {
 1ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1d1:	8b 84 85 cc f3 ff ff 	mov    -0xc34(%ebp,%eax,4),%eax
 1d8:	85 c0                	test   %eax,%eax
 1da:	0f 84 16 01 00 00    	je     2f6 <main+0x294>
 1e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1e3:	83 c0 40             	add    $0x40,%eax
 1e6:	8b 94 85 cc f3 ff ff 	mov    -0xc34(%ebp,%eax,4),%edx
 1ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
 1f0:	8b 84 85 bc f3 ff ff 	mov    -0xc44(%ebp,%eax,4),%eax
 1f7:	39 c2                	cmp    %eax,%edx
 1f9:	0f 85 f7 00 00 00    	jne    2f6 <main+0x294>
        printf(1, "▶ Process %d (PID %d): 최종 Q → Q%d\n", j + 1, st.pid[i], st.priority[i]);
 1ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
 202:	83 e8 80             	sub    $0xffffff80,%eax
 205:	8b 94 85 cc f3 ff ff 	mov    -0xc34(%ebp,%eax,4),%edx
 20c:	8b 45 dc             	mov    -0x24(%ebp),%eax
 20f:	83 c0 40             	add    $0x40,%eax
 212:	8b 84 85 cc f3 ff ff 	mov    -0xc34(%ebp,%eax,4),%eax
 219:	8b 4d d8             	mov    -0x28(%ebp),%ecx
 21c:	83 c1 01             	add    $0x1,%ecx
 21f:	83 ec 0c             	sub    $0xc,%esp
 222:	52                   	push   %edx
 223:	50                   	push   %eax
 224:	51                   	push   %ecx
 225:	68 bc 0b 00 00       	push   $0xbbc
 22a:	6a 01                	push   $0x1
 22c:	e8 48 05 00 00       	call   779 <printf>
 231:	83 c4 20             	add    $0x20,%esp
        printf(1, "   ticks      : [Q0:%d Q1:%d Q2:%d Q3:%d]\n",
 234:	8b 45 dc             	mov    -0x24(%ebp),%eax
 237:	c1 e0 04             	shl    $0x4,%eax
 23a:	8d 5d e8             	lea    -0x18(%ebp),%ebx
 23d:	01 d8                	add    %ebx,%eax
 23f:	2d 10 08 00 00       	sub    $0x810,%eax
 244:	8b 18                	mov    (%eax),%ebx
 246:	8b 45 dc             	mov    -0x24(%ebp),%eax
 249:	c1 e0 04             	shl    $0x4,%eax
 24c:	8d 4d e8             	lea    -0x18(%ebp),%ecx
 24f:	01 c8                	add    %ecx,%eax
 251:	2d 14 08 00 00       	sub    $0x814,%eax
 256:	8b 08                	mov    (%eax),%ecx
 258:	8b 45 dc             	mov    -0x24(%ebp),%eax
 25b:	c1 e0 04             	shl    $0x4,%eax
 25e:	8d 55 e8             	lea    -0x18(%ebp),%edx
 261:	01 d0                	add    %edx,%eax
 263:	2d 18 08 00 00       	sub    $0x818,%eax
 268:	8b 10                	mov    (%eax),%edx
 26a:	8b 45 dc             	mov    -0x24(%ebp),%eax
 26d:	83 c0 40             	add    $0x40,%eax
 270:	c1 e0 04             	shl    $0x4,%eax
 273:	8d 75 e8             	lea    -0x18(%ebp),%esi
 276:	01 f0                	add    %esi,%eax
 278:	2d 1c 0c 00 00       	sub    $0xc1c,%eax
 27d:	8b 00                	mov    (%eax),%eax
 27f:	83 ec 08             	sub    $0x8,%esp
 282:	53                   	push   %ebx
 283:	51                   	push   %ecx
 284:	52                   	push   %edx
 285:	50                   	push   %eax
 286:	68 e8 0b 00 00       	push   $0xbe8
 28b:	6a 01                	push   $0x1
 28d:	e8 e7 04 00 00       	call   779 <printf>
 292:	83 c4 20             	add    $0x20,%esp
               st.ticks[i][0], st.ticks[i][1], st.ticks[i][2], st.ticks[i][3]);
        printf(1, "   wait_ticks : [Q0:%d Q1:%d Q2:%d Q3:%d]\n\n",
 295:	8b 45 dc             	mov    -0x24(%ebp),%eax
 298:	c1 e0 04             	shl    $0x4,%eax
 29b:	8d 75 e8             	lea    -0x18(%ebp),%esi
 29e:	01 f0                	add    %esi,%eax
 2a0:	2d 10 04 00 00       	sub    $0x410,%eax
 2a5:	8b 18                	mov    (%eax),%ebx
 2a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
 2aa:	c1 e0 04             	shl    $0x4,%eax
 2ad:	8d 75 e8             	lea    -0x18(%ebp),%esi
 2b0:	01 f0                	add    %esi,%eax
 2b2:	2d 14 04 00 00       	sub    $0x414,%eax
 2b7:	8b 08                	mov    (%eax),%ecx
 2b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
 2bc:	c1 e0 04             	shl    $0x4,%eax
 2bf:	8d 75 e8             	lea    -0x18(%ebp),%esi
 2c2:	01 f0                	add    %esi,%eax
 2c4:	2d 18 04 00 00       	sub    $0x418,%eax
 2c9:	8b 10                	mov    (%eax),%edx
 2cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
 2ce:	83 e8 80             	sub    $0xffffff80,%eax
 2d1:	c1 e0 04             	shl    $0x4,%eax
 2d4:	8d 75 e8             	lea    -0x18(%ebp),%esi
 2d7:	01 f0                	add    %esi,%eax
 2d9:	2d 1c 0c 00 00       	sub    $0xc1c,%eax
 2de:	8b 00                	mov    (%eax),%eax
 2e0:	83 ec 08             	sub    $0x8,%esp
 2e3:	53                   	push   %ebx
 2e4:	51                   	push   %ecx
 2e5:	52                   	push   %edx
 2e6:	50                   	push   %eax
 2e7:	68 14 0c 00 00       	push   $0xc14
 2ec:	6a 01                	push   $0x1
 2ee:	e8 86 04 00 00       	call   779 <printf>
 2f3:	83 c4 20             	add    $0x20,%esp
    for (int j = 0; j < NUM_PROCS; j++) {
 2f6:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
 2fa:	83 7d d8 03          	cmpl   $0x3,-0x28(%ebp)
 2fe:	0f 8e ca fe ff ff    	jle    1ce <main+0x16c>
  for (int i = 0; i < NPROC; i++) {
 304:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
 308:	83 7d dc 3f          	cmpl   $0x3f,-0x24(%ebp)
 30c:	0f 8e b0 fe ff ff    	jle    1c2 <main+0x160>
               st.wait_ticks[i][2], st.wait_ticks[i][3]);
      }
    }
  }

  for (int i = 0; i < NUM_PROCS; i++) kill(pids[i]);
 312:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 319:	eb 1a                	jmp    335 <main+0x2d3>
 31b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 31e:	8b 84 85 bc f3 ff ff 	mov    -0xc44(%ebp,%eax,4),%eax
 325:	83 ec 0c             	sub    $0xc,%esp
 328:	50                   	push   %eax
 329:	e8 e7 02 00 00       	call   615 <kill>
 32e:	83 c4 10             	add    $0x10,%esp
 331:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
 335:	83 7d d4 03          	cmpl   $0x3,-0x2c(%ebp)
 339:	7e e0                	jle    31b <main+0x2b9>
  for (int i = 0; i < NUM_PROCS; i++) wait();
 33b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 342:	eb 09                	jmp    34d <main+0x2eb>
 344:	e8 a4 02 00 00       	call   5ed <wait>
 349:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 34d:	83 7d d0 03          	cmpl   $0x3,-0x30(%ebp)
 351:	7e f1                	jle    344 <main+0x2e2>

  printf(1, "==== 종료 ====\n");
 353:	83 ec 08             	sub    $0x8,%esp
 356:	68 40 0c 00 00       	push   $0xc40
 35b:	6a 01                	push   $0x1
 35d:	e8 17 04 00 00       	call   779 <printf>
 362:	83 c4 10             	add    $0x10,%esp
  exit();
 365:	e8 7b 02 00 00       	call   5e5 <exit>

0000036a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 36a:	55                   	push   %ebp
 36b:	89 e5                	mov    %esp,%ebp
 36d:	57                   	push   %edi
 36e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 36f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 372:	8b 55 10             	mov    0x10(%ebp),%edx
 375:	8b 45 0c             	mov    0xc(%ebp),%eax
 378:	89 cb                	mov    %ecx,%ebx
 37a:	89 df                	mov    %ebx,%edi
 37c:	89 d1                	mov    %edx,%ecx
 37e:	fc                   	cld    
 37f:	f3 aa                	rep stos %al,%es:(%edi)
 381:	89 ca                	mov    %ecx,%edx
 383:	89 fb                	mov    %edi,%ebx
 385:	89 5d 08             	mov    %ebx,0x8(%ebp)
 388:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 38b:	90                   	nop
 38c:	5b                   	pop    %ebx
 38d:	5f                   	pop    %edi
 38e:	5d                   	pop    %ebp
 38f:	c3                   	ret    

00000390 <strcpy>:



char*
strcpy(char *s, char *t)
{
 390:	f3 0f 1e fb          	endbr32 
 394:	55                   	push   %ebp
 395:	89 e5                	mov    %esp,%ebp
 397:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3a0:	90                   	nop
 3a1:	8b 55 0c             	mov    0xc(%ebp),%edx
 3a4:	8d 42 01             	lea    0x1(%edx),%eax
 3a7:	89 45 0c             	mov    %eax,0xc(%ebp)
 3aa:	8b 45 08             	mov    0x8(%ebp),%eax
 3ad:	8d 48 01             	lea    0x1(%eax),%ecx
 3b0:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3b3:	0f b6 12             	movzbl (%edx),%edx
 3b6:	88 10                	mov    %dl,(%eax)
 3b8:	0f b6 00             	movzbl (%eax),%eax
 3bb:	84 c0                	test   %al,%al
 3bd:	75 e2                	jne    3a1 <strcpy+0x11>
    ;
  return os;
 3bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3c2:	c9                   	leave  
 3c3:	c3                   	ret    

000003c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3c4:	f3 0f 1e fb          	endbr32 
 3c8:	55                   	push   %ebp
 3c9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3cb:	eb 08                	jmp    3d5 <strcmp+0x11>
    p++, q++;
 3cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3d5:	8b 45 08             	mov    0x8(%ebp),%eax
 3d8:	0f b6 00             	movzbl (%eax),%eax
 3db:	84 c0                	test   %al,%al
 3dd:	74 10                	je     3ef <strcmp+0x2b>
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	0f b6 10             	movzbl (%eax),%edx
 3e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	38 c2                	cmp    %al,%dl
 3ed:	74 de                	je     3cd <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 3ef:	8b 45 08             	mov    0x8(%ebp),%eax
 3f2:	0f b6 00             	movzbl (%eax),%eax
 3f5:	0f b6 d0             	movzbl %al,%edx
 3f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fb:	0f b6 00             	movzbl (%eax),%eax
 3fe:	0f b6 c0             	movzbl %al,%eax
 401:	29 c2                	sub    %eax,%edx
 403:	89 d0                	mov    %edx,%eax
}
 405:	5d                   	pop    %ebp
 406:	c3                   	ret    

00000407 <strlen>:

uint
strlen(char *s)
{
 407:	f3 0f 1e fb          	endbr32 
 40b:	55                   	push   %ebp
 40c:	89 e5                	mov    %esp,%ebp
 40e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 411:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 418:	eb 04                	jmp    41e <strlen+0x17>
 41a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 41e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 421:	8b 45 08             	mov    0x8(%ebp),%eax
 424:	01 d0                	add    %edx,%eax
 426:	0f b6 00             	movzbl (%eax),%eax
 429:	84 c0                	test   %al,%al
 42b:	75 ed                	jne    41a <strlen+0x13>
    ;
  return n;
 42d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 430:	c9                   	leave  
 431:	c3                   	ret    

00000432 <memset>:

void*
memset(void *dst, int c, uint n)
{
 432:	f3 0f 1e fb          	endbr32 
 436:	55                   	push   %ebp
 437:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 439:	8b 45 10             	mov    0x10(%ebp),%eax
 43c:	50                   	push   %eax
 43d:	ff 75 0c             	pushl  0xc(%ebp)
 440:	ff 75 08             	pushl  0x8(%ebp)
 443:	e8 22 ff ff ff       	call   36a <stosb>
 448:	83 c4 0c             	add    $0xc,%esp
  return dst;
 44b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 44e:	c9                   	leave  
 44f:	c3                   	ret    

00000450 <strchr>:

char*
strchr(const char *s, char c)
{
 450:	f3 0f 1e fb          	endbr32 
 454:	55                   	push   %ebp
 455:	89 e5                	mov    %esp,%ebp
 457:	83 ec 04             	sub    $0x4,%esp
 45a:	8b 45 0c             	mov    0xc(%ebp),%eax
 45d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 460:	eb 14                	jmp    476 <strchr+0x26>
    if(*s == c)
 462:	8b 45 08             	mov    0x8(%ebp),%eax
 465:	0f b6 00             	movzbl (%eax),%eax
 468:	38 45 fc             	cmp    %al,-0x4(%ebp)
 46b:	75 05                	jne    472 <strchr+0x22>
      return (char*)s;
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	eb 13                	jmp    485 <strchr+0x35>
  for(; *s; s++)
 472:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 476:	8b 45 08             	mov    0x8(%ebp),%eax
 479:	0f b6 00             	movzbl (%eax),%eax
 47c:	84 c0                	test   %al,%al
 47e:	75 e2                	jne    462 <strchr+0x12>
  return 0;
 480:	b8 00 00 00 00       	mov    $0x0,%eax
}
 485:	c9                   	leave  
 486:	c3                   	ret    

00000487 <gets>:

char*
gets(char *buf, int max)
{
 487:	f3 0f 1e fb          	endbr32 
 48b:	55                   	push   %ebp
 48c:	89 e5                	mov    %esp,%ebp
 48e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 498:	eb 42                	jmp    4dc <gets+0x55>
    cc = read(0, &c, 1);
 49a:	83 ec 04             	sub    $0x4,%esp
 49d:	6a 01                	push   $0x1
 49f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4a2:	50                   	push   %eax
 4a3:	6a 00                	push   $0x0
 4a5:	e8 53 01 00 00       	call   5fd <read>
 4aa:	83 c4 10             	add    $0x10,%esp
 4ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b4:	7e 33                	jle    4e9 <gets+0x62>
      break;
    buf[i++] = c;
 4b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b9:	8d 50 01             	lea    0x1(%eax),%edx
 4bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4bf:	89 c2                	mov    %eax,%edx
 4c1:	8b 45 08             	mov    0x8(%ebp),%eax
 4c4:	01 c2                	add    %eax,%edx
 4c6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ca:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4cc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d0:	3c 0a                	cmp    $0xa,%al
 4d2:	74 16                	je     4ea <gets+0x63>
 4d4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d8:	3c 0d                	cmp    $0xd,%al
 4da:	74 0e                	je     4ea <gets+0x63>
  for(i=0; i+1 < max; ){
 4dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4df:	83 c0 01             	add    $0x1,%eax
 4e2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4e5:	7f b3                	jg     49a <gets+0x13>
 4e7:	eb 01                	jmp    4ea <gets+0x63>
      break;
 4e9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4ed:	8b 45 08             	mov    0x8(%ebp),%eax
 4f0:	01 d0                	add    %edx,%eax
 4f2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4f5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f8:	c9                   	leave  
 4f9:	c3                   	ret    

000004fa <stat>:

int
stat(char *n, struct stat *st)
{
 4fa:	f3 0f 1e fb          	endbr32 
 4fe:	55                   	push   %ebp
 4ff:	89 e5                	mov    %esp,%ebp
 501:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 504:	83 ec 08             	sub    $0x8,%esp
 507:	6a 00                	push   $0x0
 509:	ff 75 08             	pushl  0x8(%ebp)
 50c:	e8 14 01 00 00       	call   625 <open>
 511:	83 c4 10             	add    $0x10,%esp
 514:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 517:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51b:	79 07                	jns    524 <stat+0x2a>
    return -1;
 51d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 522:	eb 25                	jmp    549 <stat+0x4f>
  r = fstat(fd, st);
 524:	83 ec 08             	sub    $0x8,%esp
 527:	ff 75 0c             	pushl  0xc(%ebp)
 52a:	ff 75 f4             	pushl  -0xc(%ebp)
 52d:	e8 0b 01 00 00       	call   63d <fstat>
 532:	83 c4 10             	add    $0x10,%esp
 535:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 538:	83 ec 0c             	sub    $0xc,%esp
 53b:	ff 75 f4             	pushl  -0xc(%ebp)
 53e:	e8 ca 00 00 00       	call   60d <close>
 543:	83 c4 10             	add    $0x10,%esp
  return r;
 546:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 549:	c9                   	leave  
 54a:	c3                   	ret    

0000054b <atoi>:

int
atoi(const char *s)
{
 54b:	f3 0f 1e fb          	endbr32 
 54f:	55                   	push   %ebp
 550:	89 e5                	mov    %esp,%ebp
 552:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 555:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 55c:	eb 25                	jmp    583 <atoi+0x38>
    n = n*10 + *s++ - '0';
 55e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 561:	89 d0                	mov    %edx,%eax
 563:	c1 e0 02             	shl    $0x2,%eax
 566:	01 d0                	add    %edx,%eax
 568:	01 c0                	add    %eax,%eax
 56a:	89 c1                	mov    %eax,%ecx
 56c:	8b 45 08             	mov    0x8(%ebp),%eax
 56f:	8d 50 01             	lea    0x1(%eax),%edx
 572:	89 55 08             	mov    %edx,0x8(%ebp)
 575:	0f b6 00             	movzbl (%eax),%eax
 578:	0f be c0             	movsbl %al,%eax
 57b:	01 c8                	add    %ecx,%eax
 57d:	83 e8 30             	sub    $0x30,%eax
 580:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 583:	8b 45 08             	mov    0x8(%ebp),%eax
 586:	0f b6 00             	movzbl (%eax),%eax
 589:	3c 2f                	cmp    $0x2f,%al
 58b:	7e 0a                	jle    597 <atoi+0x4c>
 58d:	8b 45 08             	mov    0x8(%ebp),%eax
 590:	0f b6 00             	movzbl (%eax),%eax
 593:	3c 39                	cmp    $0x39,%al
 595:	7e c7                	jle    55e <atoi+0x13>
  return n;
 597:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 59a:	c9                   	leave  
 59b:	c3                   	ret    

0000059c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 59c:	f3 0f 1e fb          	endbr32 
 5a0:	55                   	push   %ebp
 5a1:	89 e5                	mov    %esp,%ebp
 5a3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 5a6:	8b 45 08             	mov    0x8(%ebp),%eax
 5a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 5af:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5b2:	eb 17                	jmp    5cb <memmove+0x2f>
    *dst++ = *src++;
 5b4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5b7:	8d 42 01             	lea    0x1(%edx),%eax
 5ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c0:	8d 48 01             	lea    0x1(%eax),%ecx
 5c3:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5c6:	0f b6 12             	movzbl (%edx),%edx
 5c9:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5cb:	8b 45 10             	mov    0x10(%ebp),%eax
 5ce:	8d 50 ff             	lea    -0x1(%eax),%edx
 5d1:	89 55 10             	mov    %edx,0x10(%ebp)
 5d4:	85 c0                	test   %eax,%eax
 5d6:	7f dc                	jg     5b4 <memmove+0x18>
  return vdst;
 5d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5db:	c9                   	leave  
 5dc:	c3                   	ret    

000005dd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5dd:	b8 01 00 00 00       	mov    $0x1,%eax
 5e2:	cd 40                	int    $0x40
 5e4:	c3                   	ret    

000005e5 <exit>:
SYSCALL(exit)
 5e5:	b8 02 00 00 00       	mov    $0x2,%eax
 5ea:	cd 40                	int    $0x40
 5ec:	c3                   	ret    

000005ed <wait>:
SYSCALL(wait)
 5ed:	b8 03 00 00 00       	mov    $0x3,%eax
 5f2:	cd 40                	int    $0x40
 5f4:	c3                   	ret    

000005f5 <pipe>:
SYSCALL(pipe)
 5f5:	b8 04 00 00 00       	mov    $0x4,%eax
 5fa:	cd 40                	int    $0x40
 5fc:	c3                   	ret    

000005fd <read>:
SYSCALL(read)
 5fd:	b8 05 00 00 00       	mov    $0x5,%eax
 602:	cd 40                	int    $0x40
 604:	c3                   	ret    

00000605 <write>:
SYSCALL(write)
 605:	b8 10 00 00 00       	mov    $0x10,%eax
 60a:	cd 40                	int    $0x40
 60c:	c3                   	ret    

0000060d <close>:
SYSCALL(close)
 60d:	b8 15 00 00 00       	mov    $0x15,%eax
 612:	cd 40                	int    $0x40
 614:	c3                   	ret    

00000615 <kill>:
SYSCALL(kill)
 615:	b8 06 00 00 00       	mov    $0x6,%eax
 61a:	cd 40                	int    $0x40
 61c:	c3                   	ret    

0000061d <exec>:
SYSCALL(exec)
 61d:	b8 07 00 00 00       	mov    $0x7,%eax
 622:	cd 40                	int    $0x40
 624:	c3                   	ret    

00000625 <open>:
SYSCALL(open)
 625:	b8 0f 00 00 00       	mov    $0xf,%eax
 62a:	cd 40                	int    $0x40
 62c:	c3                   	ret    

0000062d <mknod>:
SYSCALL(mknod)
 62d:	b8 11 00 00 00       	mov    $0x11,%eax
 632:	cd 40                	int    $0x40
 634:	c3                   	ret    

00000635 <unlink>:
SYSCALL(unlink)
 635:	b8 12 00 00 00       	mov    $0x12,%eax
 63a:	cd 40                	int    $0x40
 63c:	c3                   	ret    

0000063d <fstat>:
SYSCALL(fstat)
 63d:	b8 08 00 00 00       	mov    $0x8,%eax
 642:	cd 40                	int    $0x40
 644:	c3                   	ret    

00000645 <link>:
SYSCALL(link)
 645:	b8 13 00 00 00       	mov    $0x13,%eax
 64a:	cd 40                	int    $0x40
 64c:	c3                   	ret    

0000064d <mkdir>:
SYSCALL(mkdir)
 64d:	b8 14 00 00 00       	mov    $0x14,%eax
 652:	cd 40                	int    $0x40
 654:	c3                   	ret    

00000655 <chdir>:
SYSCALL(chdir)
 655:	b8 09 00 00 00       	mov    $0x9,%eax
 65a:	cd 40                	int    $0x40
 65c:	c3                   	ret    

0000065d <dup>:
SYSCALL(dup)
 65d:	b8 0a 00 00 00       	mov    $0xa,%eax
 662:	cd 40                	int    $0x40
 664:	c3                   	ret    

00000665 <getpid>:
SYSCALL(getpid)
 665:	b8 0b 00 00 00       	mov    $0xb,%eax
 66a:	cd 40                	int    $0x40
 66c:	c3                   	ret    

0000066d <sbrk>:
SYSCALL(sbrk)
 66d:	b8 0c 00 00 00       	mov    $0xc,%eax
 672:	cd 40                	int    $0x40
 674:	c3                   	ret    

00000675 <sleep>:
SYSCALL(sleep)
 675:	b8 0d 00 00 00       	mov    $0xd,%eax
 67a:	cd 40                	int    $0x40
 67c:	c3                   	ret    

0000067d <uptime>:
SYSCALL(uptime)
 67d:	b8 0e 00 00 00       	mov    $0xe,%eax
 682:	cd 40                	int    $0x40
 684:	c3                   	ret    

00000685 <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 685:	b8 16 00 00 00       	mov    $0x16,%eax
 68a:	cd 40                	int    $0x40
 68c:	c3                   	ret    

0000068d <getpinfo>:
SYSCALL(getpinfo)
 68d:	b8 17 00 00 00       	mov    $0x17,%eax
 692:	cd 40                	int    $0x40
 694:	c3                   	ret    

00000695 <yield>:
SYSCALL(yield)
 695:	b8 18 00 00 00       	mov    $0x18,%eax
 69a:	cd 40                	int    $0x40
 69c:	c3                   	ret    

0000069d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 69d:	f3 0f 1e fb          	endbr32 
 6a1:	55                   	push   %ebp
 6a2:	89 e5                	mov    %esp,%ebp
 6a4:	83 ec 18             	sub    $0x18,%esp
 6a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 6aa:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6ad:	83 ec 04             	sub    $0x4,%esp
 6b0:	6a 01                	push   $0x1
 6b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6b5:	50                   	push   %eax
 6b6:	ff 75 08             	pushl  0x8(%ebp)
 6b9:	e8 47 ff ff ff       	call   605 <write>
 6be:	83 c4 10             	add    $0x10,%esp
}
 6c1:	90                   	nop
 6c2:	c9                   	leave  
 6c3:	c3                   	ret    

000006c4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6c4:	f3 0f 1e fb          	endbr32 
 6c8:	55                   	push   %ebp
 6c9:	89 e5                	mov    %esp,%ebp
 6cb:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6d5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6d9:	74 17                	je     6f2 <printint+0x2e>
 6db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6df:	79 11                	jns    6f2 <printint+0x2e>
    neg = 1;
 6e1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6eb:	f7 d8                	neg    %eax
 6ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6f0:	eb 06                	jmp    6f8 <printint+0x34>
  } else {
    x = xx;
 6f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
 702:	8b 45 ec             	mov    -0x14(%ebp),%eax
 705:	ba 00 00 00 00       	mov    $0x0,%edx
 70a:	f7 f1                	div    %ecx
 70c:	89 d1                	mov    %edx,%ecx
 70e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 711:	8d 50 01             	lea    0x1(%eax),%edx
 714:	89 55 f4             	mov    %edx,-0xc(%ebp)
 717:	0f b6 91 c8 0e 00 00 	movzbl 0xec8(%ecx),%edx
 71e:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 722:	8b 4d 10             	mov    0x10(%ebp),%ecx
 725:	8b 45 ec             	mov    -0x14(%ebp),%eax
 728:	ba 00 00 00 00       	mov    $0x0,%edx
 72d:	f7 f1                	div    %ecx
 72f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 732:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 736:	75 c7                	jne    6ff <printint+0x3b>
  if(neg)
 738:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 73c:	74 2d                	je     76b <printint+0xa7>
    buf[i++] = '-';
 73e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 741:	8d 50 01             	lea    0x1(%eax),%edx
 744:	89 55 f4             	mov    %edx,-0xc(%ebp)
 747:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 74c:	eb 1d                	jmp    76b <printint+0xa7>
    putc(fd, buf[i]);
 74e:	8d 55 dc             	lea    -0x24(%ebp),%edx
 751:	8b 45 f4             	mov    -0xc(%ebp),%eax
 754:	01 d0                	add    %edx,%eax
 756:	0f b6 00             	movzbl (%eax),%eax
 759:	0f be c0             	movsbl %al,%eax
 75c:	83 ec 08             	sub    $0x8,%esp
 75f:	50                   	push   %eax
 760:	ff 75 08             	pushl  0x8(%ebp)
 763:	e8 35 ff ff ff       	call   69d <putc>
 768:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 76b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 76f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 773:	79 d9                	jns    74e <printint+0x8a>
}
 775:	90                   	nop
 776:	90                   	nop
 777:	c9                   	leave  
 778:	c3                   	ret    

00000779 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 779:	f3 0f 1e fb          	endbr32 
 77d:	55                   	push   %ebp
 77e:	89 e5                	mov    %esp,%ebp
 780:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 783:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 78a:	8d 45 0c             	lea    0xc(%ebp),%eax
 78d:	83 c0 04             	add    $0x4,%eax
 790:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 793:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 79a:	e9 59 01 00 00       	jmp    8f8 <printf+0x17f>
    c = fmt[i] & 0xff;
 79f:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a5:	01 d0                	add    %edx,%eax
 7a7:	0f b6 00             	movzbl (%eax),%eax
 7aa:	0f be c0             	movsbl %al,%eax
 7ad:	25 ff 00 00 00       	and    $0xff,%eax
 7b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7b9:	75 2c                	jne    7e7 <printf+0x6e>
      if(c == '%'){
 7bb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7bf:	75 0c                	jne    7cd <printf+0x54>
        state = '%';
 7c1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7c8:	e9 27 01 00 00       	jmp    8f4 <printf+0x17b>
      } else {
        putc(fd, c);
 7cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d0:	0f be c0             	movsbl %al,%eax
 7d3:	83 ec 08             	sub    $0x8,%esp
 7d6:	50                   	push   %eax
 7d7:	ff 75 08             	pushl  0x8(%ebp)
 7da:	e8 be fe ff ff       	call   69d <putc>
 7df:	83 c4 10             	add    $0x10,%esp
 7e2:	e9 0d 01 00 00       	jmp    8f4 <printf+0x17b>
      }
    } else if(state == '%'){
 7e7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7eb:	0f 85 03 01 00 00    	jne    8f4 <printf+0x17b>
      if(c == 'd'){
 7f1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7f5:	75 1e                	jne    815 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 7f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fa:	8b 00                	mov    (%eax),%eax
 7fc:	6a 01                	push   $0x1
 7fe:	6a 0a                	push   $0xa
 800:	50                   	push   %eax
 801:	ff 75 08             	pushl  0x8(%ebp)
 804:	e8 bb fe ff ff       	call   6c4 <printint>
 809:	83 c4 10             	add    $0x10,%esp
        ap++;
 80c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 810:	e9 d8 00 00 00       	jmp    8ed <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 815:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 819:	74 06                	je     821 <printf+0xa8>
 81b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 81f:	75 1e                	jne    83f <printf+0xc6>
        printint(fd, *ap, 16, 0);
 821:	8b 45 e8             	mov    -0x18(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	6a 00                	push   $0x0
 828:	6a 10                	push   $0x10
 82a:	50                   	push   %eax
 82b:	ff 75 08             	pushl  0x8(%ebp)
 82e:	e8 91 fe ff ff       	call   6c4 <printint>
 833:	83 c4 10             	add    $0x10,%esp
        ap++;
 836:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 83a:	e9 ae 00 00 00       	jmp    8ed <printf+0x174>
      } else if(c == 's'){
 83f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 843:	75 43                	jne    888 <printf+0x10f>
        s = (char*)*ap;
 845:	8b 45 e8             	mov    -0x18(%ebp),%eax
 848:	8b 00                	mov    (%eax),%eax
 84a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 84d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 851:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 855:	75 25                	jne    87c <printf+0x103>
          s = "(null)";
 857:	c7 45 f4 52 0c 00 00 	movl   $0xc52,-0xc(%ebp)
        while(*s != 0){
 85e:	eb 1c                	jmp    87c <printf+0x103>
          putc(fd, *s);
 860:	8b 45 f4             	mov    -0xc(%ebp),%eax
 863:	0f b6 00             	movzbl (%eax),%eax
 866:	0f be c0             	movsbl %al,%eax
 869:	83 ec 08             	sub    $0x8,%esp
 86c:	50                   	push   %eax
 86d:	ff 75 08             	pushl  0x8(%ebp)
 870:	e8 28 fe ff ff       	call   69d <putc>
 875:	83 c4 10             	add    $0x10,%esp
          s++;
 878:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	0f b6 00             	movzbl (%eax),%eax
 882:	84 c0                	test   %al,%al
 884:	75 da                	jne    860 <printf+0xe7>
 886:	eb 65                	jmp    8ed <printf+0x174>
        }
      } else if(c == 'c'){
 888:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 88c:	75 1d                	jne    8ab <printf+0x132>
        putc(fd, *ap);
 88e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 891:	8b 00                	mov    (%eax),%eax
 893:	0f be c0             	movsbl %al,%eax
 896:	83 ec 08             	sub    $0x8,%esp
 899:	50                   	push   %eax
 89a:	ff 75 08             	pushl  0x8(%ebp)
 89d:	e8 fb fd ff ff       	call   69d <putc>
 8a2:	83 c4 10             	add    $0x10,%esp
        ap++;
 8a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8a9:	eb 42                	jmp    8ed <printf+0x174>
      } else if(c == '%'){
 8ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8af:	75 17                	jne    8c8 <printf+0x14f>
        putc(fd, c);
 8b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8b4:	0f be c0             	movsbl %al,%eax
 8b7:	83 ec 08             	sub    $0x8,%esp
 8ba:	50                   	push   %eax
 8bb:	ff 75 08             	pushl  0x8(%ebp)
 8be:	e8 da fd ff ff       	call   69d <putc>
 8c3:	83 c4 10             	add    $0x10,%esp
 8c6:	eb 25                	jmp    8ed <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8c8:	83 ec 08             	sub    $0x8,%esp
 8cb:	6a 25                	push   $0x25
 8cd:	ff 75 08             	pushl  0x8(%ebp)
 8d0:	e8 c8 fd ff ff       	call   69d <putc>
 8d5:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8db:	0f be c0             	movsbl %al,%eax
 8de:	83 ec 08             	sub    $0x8,%esp
 8e1:	50                   	push   %eax
 8e2:	ff 75 08             	pushl  0x8(%ebp)
 8e5:	e8 b3 fd ff ff       	call   69d <putc>
 8ea:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8f4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8f8:	8b 55 0c             	mov    0xc(%ebp),%edx
 8fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fe:	01 d0                	add    %edx,%eax
 900:	0f b6 00             	movzbl (%eax),%eax
 903:	84 c0                	test   %al,%al
 905:	0f 85 94 fe ff ff    	jne    79f <printf+0x26>
    }
  }
}
 90b:	90                   	nop
 90c:	90                   	nop
 90d:	c9                   	leave  
 90e:	c3                   	ret    

0000090f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 90f:	f3 0f 1e fb          	endbr32 
 913:	55                   	push   %ebp
 914:	89 e5                	mov    %esp,%ebp
 916:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 919:	8b 45 08             	mov    0x8(%ebp),%eax
 91c:	83 e8 08             	sub    $0x8,%eax
 91f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 922:	a1 e4 0e 00 00       	mov    0xee4,%eax
 927:	89 45 fc             	mov    %eax,-0x4(%ebp)
 92a:	eb 24                	jmp    950 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 92c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92f:	8b 00                	mov    (%eax),%eax
 931:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 934:	72 12                	jb     948 <free+0x39>
 936:	8b 45 f8             	mov    -0x8(%ebp),%eax
 939:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 93c:	77 24                	ja     962 <free+0x53>
 93e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 941:	8b 00                	mov    (%eax),%eax
 943:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 946:	72 1a                	jb     962 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 948:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94b:	8b 00                	mov    (%eax),%eax
 94d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 950:	8b 45 f8             	mov    -0x8(%ebp),%eax
 953:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 956:	76 d4                	jbe    92c <free+0x1d>
 958:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95b:	8b 00                	mov    (%eax),%eax
 95d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 960:	73 ca                	jae    92c <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 962:	8b 45 f8             	mov    -0x8(%ebp),%eax
 965:	8b 40 04             	mov    0x4(%eax),%eax
 968:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 96f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 972:	01 c2                	add    %eax,%edx
 974:	8b 45 fc             	mov    -0x4(%ebp),%eax
 977:	8b 00                	mov    (%eax),%eax
 979:	39 c2                	cmp    %eax,%edx
 97b:	75 24                	jne    9a1 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 97d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 980:	8b 50 04             	mov    0x4(%eax),%edx
 983:	8b 45 fc             	mov    -0x4(%ebp),%eax
 986:	8b 00                	mov    (%eax),%eax
 988:	8b 40 04             	mov    0x4(%eax),%eax
 98b:	01 c2                	add    %eax,%edx
 98d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 990:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 993:	8b 45 fc             	mov    -0x4(%ebp),%eax
 996:	8b 00                	mov    (%eax),%eax
 998:	8b 10                	mov    (%eax),%edx
 99a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99d:	89 10                	mov    %edx,(%eax)
 99f:	eb 0a                	jmp    9ab <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 9a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a4:	8b 10                	mov    (%eax),%edx
 9a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a9:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ae:	8b 40 04             	mov    0x4(%eax),%eax
 9b1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bb:	01 d0                	add    %edx,%eax
 9bd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9c0:	75 20                	jne    9e2 <free+0xd3>
    p->s.size += bp->s.size;
 9c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c5:	8b 50 04             	mov    0x4(%eax),%edx
 9c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9cb:	8b 40 04             	mov    0x4(%eax),%eax
 9ce:	01 c2                	add    %eax,%edx
 9d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d9:	8b 10                	mov    (%eax),%edx
 9db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9de:	89 10                	mov    %edx,(%eax)
 9e0:	eb 08                	jmp    9ea <free+0xdb>
  } else
    p->s.ptr = bp;
 9e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9e8:	89 10                	mov    %edx,(%eax)
  freep = p;
 9ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ed:	a3 e4 0e 00 00       	mov    %eax,0xee4
}
 9f2:	90                   	nop
 9f3:	c9                   	leave  
 9f4:	c3                   	ret    

000009f5 <morecore>:

static Header*
morecore(uint nu)
{
 9f5:	f3 0f 1e fb          	endbr32 
 9f9:	55                   	push   %ebp
 9fa:	89 e5                	mov    %esp,%ebp
 9fc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9ff:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a06:	77 07                	ja     a0f <morecore+0x1a>
    nu = 4096;
 a08:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a0f:	8b 45 08             	mov    0x8(%ebp),%eax
 a12:	c1 e0 03             	shl    $0x3,%eax
 a15:	83 ec 0c             	sub    $0xc,%esp
 a18:	50                   	push   %eax
 a19:	e8 4f fc ff ff       	call   66d <sbrk>
 a1e:	83 c4 10             	add    $0x10,%esp
 a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a24:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a28:	75 07                	jne    a31 <morecore+0x3c>
    return 0;
 a2a:	b8 00 00 00 00       	mov    $0x0,%eax
 a2f:	eb 26                	jmp    a57 <morecore+0x62>
  hp = (Header*)p;
 a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3a:	8b 55 08             	mov    0x8(%ebp),%edx
 a3d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a43:	83 c0 08             	add    $0x8,%eax
 a46:	83 ec 0c             	sub    $0xc,%esp
 a49:	50                   	push   %eax
 a4a:	e8 c0 fe ff ff       	call   90f <free>
 a4f:	83 c4 10             	add    $0x10,%esp
  return freep;
 a52:	a1 e4 0e 00 00       	mov    0xee4,%eax
}
 a57:	c9                   	leave  
 a58:	c3                   	ret    

00000a59 <malloc>:

void*
malloc(uint nbytes)
{
 a59:	f3 0f 1e fb          	endbr32 
 a5d:	55                   	push   %ebp
 a5e:	89 e5                	mov    %esp,%ebp
 a60:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a63:	8b 45 08             	mov    0x8(%ebp),%eax
 a66:	83 c0 07             	add    $0x7,%eax
 a69:	c1 e8 03             	shr    $0x3,%eax
 a6c:	83 c0 01             	add    $0x1,%eax
 a6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a72:	a1 e4 0e 00 00       	mov    0xee4,%eax
 a77:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a7e:	75 23                	jne    aa3 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 a80:	c7 45 f0 dc 0e 00 00 	movl   $0xedc,-0x10(%ebp)
 a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8a:	a3 e4 0e 00 00       	mov    %eax,0xee4
 a8f:	a1 e4 0e 00 00       	mov    0xee4,%eax
 a94:	a3 dc 0e 00 00       	mov    %eax,0xedc
    base.s.size = 0;
 a99:	c7 05 e0 0e 00 00 00 	movl   $0x0,0xee0
 aa0:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa6:	8b 00                	mov    (%eax),%eax
 aa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aae:	8b 40 04             	mov    0x4(%eax),%eax
 ab1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ab4:	77 4d                	ja     b03 <malloc+0xaa>
      if(p->s.size == nunits)
 ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab9:	8b 40 04             	mov    0x4(%eax),%eax
 abc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 abf:	75 0c                	jne    acd <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac4:	8b 10                	mov    (%eax),%edx
 ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac9:	89 10                	mov    %edx,(%eax)
 acb:	eb 26                	jmp    af3 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad0:	8b 40 04             	mov    0x4(%eax),%eax
 ad3:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ad6:	89 c2                	mov    %eax,%edx
 ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adb:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae1:	8b 40 04             	mov    0x4(%eax),%eax
 ae4:	c1 e0 03             	shl    $0x3,%eax
 ae7:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aed:	8b 55 ec             	mov    -0x14(%ebp),%edx
 af0:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 af6:	a3 e4 0e 00 00       	mov    %eax,0xee4
      return (void*)(p + 1);
 afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afe:	83 c0 08             	add    $0x8,%eax
 b01:	eb 3b                	jmp    b3e <malloc+0xe5>
    }
    if(p == freep)
 b03:	a1 e4 0e 00 00       	mov    0xee4,%eax
 b08:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b0b:	75 1e                	jne    b2b <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 b0d:	83 ec 0c             	sub    $0xc,%esp
 b10:	ff 75 ec             	pushl  -0x14(%ebp)
 b13:	e8 dd fe ff ff       	call   9f5 <morecore>
 b18:	83 c4 10             	add    $0x10,%esp
 b1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b22:	75 07                	jne    b2b <malloc+0xd2>
        return 0;
 b24:	b8 00 00 00 00       	mov    $0x0,%eax
 b29:	eb 13                	jmp    b3e <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b34:	8b 00                	mov    (%eax),%eax
 b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b39:	e9 6d ff ff ff       	jmp    aab <malloc+0x52>
  }
}
 b3e:	c9                   	leave  
 b3f:	c3                   	ret    
