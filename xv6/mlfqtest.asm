
_mlfqtest:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "pstat.h"

#define TICK 40000

// workload 함수: n번 반복하면서 CPU 점유
void workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 10             	sub    $0x10,%esp
  volatile int j = 1;
   7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for (int i = 0; i < n; i++) {
   e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  15:	eb 55                	jmp    6c <workload+0x6c>
    j += (i % 100) * (j % 1000) + 1;
  17:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  1a:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  1f:	89 c8                	mov    %ecx,%eax
  21:	f7 ea                	imul   %edx
  23:	89 d0                	mov    %edx,%eax
  25:	c1 f8 05             	sar    $0x5,%eax
  28:	89 ca                	mov    %ecx,%edx
  2a:	c1 fa 1f             	sar    $0x1f,%edx
  2d:	29 d0                	sub    %edx,%eax
  2f:	89 c3                	mov    %eax,%ebx
  31:	6b c3 64             	imul   $0x64,%ebx,%eax
  34:	89 cb                	mov    %ecx,%ebx
  36:	29 c3                	sub    %eax,%ebx
  38:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  3b:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  40:	89 c8                	mov    %ecx,%eax
  42:	f7 ea                	imul   %edx
  44:	89 d0                	mov    %edx,%eax
  46:	c1 f8 06             	sar    $0x6,%eax
  49:	89 ca                	mov    %ecx,%edx
  4b:	c1 fa 1f             	sar    $0x1f,%edx
  4e:	29 d0                	sub    %edx,%eax
  50:	69 d0 e8 03 00 00    	imul   $0x3e8,%eax,%edx
  56:	89 c8                	mov    %ecx,%eax
  58:	29 d0                	sub    %edx,%eax
  5a:	0f af c3             	imul   %ebx,%eax
  5d:	8d 50 01             	lea    0x1(%eax),%edx
  60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  63:	01 d0                	add    %edx,%eax
  65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < n; i++) {
  68:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  6f:	3b 45 08             	cmp    0x8(%ebp),%eax
  72:	7c a3                	jl     17 <workload+0x17>
  }
}
  74:	90                   	nop
  75:	90                   	nop
  76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  79:	c9                   	leave  
  7a:	c3                   	ret    

0000007b <print_priority_change>:

// priority 추적용 함수
void print_priority_change(char* label, int pid, int* prev_priority, struct pstat* before, struct pstat* after) {
  7b:	55                   	push   %ebp
  7c:	89 e5                	mov    %esp,%ebp
  7e:	83 ec 18             	sub    $0x18,%esp
  for (int i = 0; i < NPROC; i++) {
  81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  88:	eb 75                	jmp    ff <print_priority_change+0x84>
    if (after->inuse[i] && after->pid[i] == pid) {
  8a:	8b 45 18             	mov    0x18(%ebp),%eax
  8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  90:	8b 04 90             	mov    (%eax,%edx,4),%eax
  93:	85 c0                	test   %eax,%eax
  95:	74 64                	je     fb <print_priority_change+0x80>
  97:	8b 45 18             	mov    0x18(%ebp),%eax
  9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  9d:	83 c2 40             	add    $0x40,%edx
  a0:	8b 04 90             	mov    (%eax,%edx,4),%eax
  a3:	39 45 0c             	cmp    %eax,0xc(%ebp)
  a6:	75 53                	jne    fb <print_priority_change+0x80>
      if (after->priority[i] != *prev_priority) {
  a8:	8b 45 18             	mov    0x18(%ebp),%eax
  ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ae:	83 ea 80             	sub    $0xffffff80,%edx
  b1:	8b 14 90             	mov    (%eax,%edx,4),%edx
  b4:	8b 45 10             	mov    0x10(%ebp),%eax
  b7:	8b 00                	mov    (%eax),%eax
  b9:	39 c2                	cmp    %eax,%edx
  bb:	74 4a                	je     107 <print_priority_change+0x8c>
        printf(1, "[%s: pid %d] Q%d → Q%d\n", label, pid, *prev_priority, after->priority[i]);
  bd:	8b 45 18             	mov    0x18(%ebp),%eax
  c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  c3:	83 ea 80             	sub    $0xffffff80,%edx
  c6:	8b 14 90             	mov    (%eax,%edx,4),%edx
  c9:	8b 45 10             	mov    0x10(%ebp),%eax
  cc:	8b 00                	mov    (%eax),%eax
  ce:	83 ec 08             	sub    $0x8,%esp
  d1:	52                   	push   %edx
  d2:	50                   	push   %eax
  d3:	ff 75 0c             	push   0xc(%ebp)
  d6:	ff 75 08             	push   0x8(%ebp)
  d9:	68 88 0b 00 00       	push   $0xb88
  de:	6a 01                	push   $0x1
  e0:	e8 e9 06 00 00       	call   7ce <printf>
  e5:	83 c4 20             	add    $0x20,%esp
        *prev_priority = after->priority[i];
  e8:	8b 45 18             	mov    0x18(%ebp),%eax
  eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ee:	83 ea 80             	sub    $0xffffff80,%edx
  f1:	8b 14 90             	mov    (%eax,%edx,4),%edx
  f4:	8b 45 10             	mov    0x10(%ebp),%eax
  f7:	89 10                	mov    %edx,(%eax)
      }
      break;
  f9:	eb 0c                	jmp    107 <print_priority_change+0x8c>
  for (int i = 0; i < NPROC; i++) {
  fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  ff:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 103:	7e 85                	jle    8a <print_priority_change+0xf>
    }
  }
}
 105:	eb 01                	jmp    108 <print_priority_change+0x8d>
      break;
 107:	90                   	nop
}
 108:	90                   	nop
 109:	c9                   	leave  
 10a:	c3                   	ret    

0000010b <run_test>:

// 실험용 자식 프로세스 실행
void run_test(char *label, int delays[], int count) {
 10b:	55                   	push   %ebp
 10c:	89 e5                	mov    %esp,%ebp
 10e:	57                   	push   %edi
 10f:	56                   	push   %esi
 110:	81 ec 00 10 00 00    	sub    $0x1000,%esp
 116:	83 0c 24 00          	orl    $0x0,(%esp)
 11a:	81 ec 10 08 00 00    	sub    $0x810,%esp
  struct pstat before, after;
  int pid = getpid();
 120:	e8 9d 05 00 00       	call   6c2 <getpid>
 125:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int q = 3;  // 시작은 Q3
 128:	c7 85 ec e7 ff ff 03 	movl   $0x3,-0x1814(%ebp)
 12f:	00 00 00 

  getpinfo(&before);
 132:	83 ec 0c             	sub    $0xc,%esp
 135:	8d 85 f0 f3 ff ff    	lea    -0xc10(%ebp),%eax
 13b:	50                   	push   %eax
 13c:	e8 a9 05 00 00       	call   6ea <getpinfo>
 141:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < count; i++) {
 144:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 14b:	eb 70                	jmp    1bd <run_test+0xb2>
    workload(delays[i]);
 14d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 150:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 157:	8b 45 0c             	mov    0xc(%ebp),%eax
 15a:	01 d0                	add    %edx,%eax
 15c:	8b 00                	mov    (%eax),%eax
 15e:	83 ec 0c             	sub    $0xc,%esp
 161:	50                   	push   %eax
 162:	e8 99 fe ff ff       	call   0 <workload>
 167:	83 c4 10             	add    $0x10,%esp
    getpinfo(&after);
 16a:	83 ec 0c             	sub    $0xc,%esp
 16d:	8d 85 f0 e7 ff ff    	lea    -0x1810(%ebp),%eax
 173:	50                   	push   %eax
 174:	e8 71 05 00 00       	call   6ea <getpinfo>
 179:	83 c4 10             	add    $0x10,%esp
    print_priority_change(label, pid, &q, &before, &after);
 17c:	83 ec 0c             	sub    $0xc,%esp
 17f:	8d 85 f0 e7 ff ff    	lea    -0x1810(%ebp),%eax
 185:	50                   	push   %eax
 186:	8d 85 f0 f3 ff ff    	lea    -0xc10(%ebp),%eax
 18c:	50                   	push   %eax
 18d:	8d 85 ec e7 ff ff    	lea    -0x1814(%ebp),%eax
 193:	50                   	push   %eax
 194:	ff 75 f0             	push   -0x10(%ebp)
 197:	ff 75 08             	push   0x8(%ebp)
 19a:	e8 dc fe ff ff       	call   7b <print_priority_change>
 19f:	83 c4 20             	add    $0x20,%esp
    before = after;
 1a2:	8d 85 f0 f3 ff ff    	lea    -0xc10(%ebp),%eax
 1a8:	8d 95 f0 e7 ff ff    	lea    -0x1810(%ebp),%edx
 1ae:	b9 00 03 00 00       	mov    $0x300,%ecx
 1b3:	89 c7                	mov    %eax,%edi
 1b5:	89 d6                	mov    %edx,%esi
 1b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for (int i = 0; i < count; i++) {
 1b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c0:	3b 45 10             	cmp    0x10(%ebp),%eax
 1c3:	7c 88                	jl     14d <run_test+0x42>
  }

  printf(1, "[%s: pid %d] 종료됨\n", label, pid);
 1c5:	ff 75 f0             	push   -0x10(%ebp)
 1c8:	ff 75 08             	push   0x8(%ebp)
 1cb:	68 a2 0b 00 00       	push   $0xba2
 1d0:	6a 01                	push   $0x1
 1d2:	e8 f7 05 00 00       	call   7ce <printf>
 1d7:	83 c4 10             	add    $0x10,%esp
  exit();
 1da:	e8 63 04 00 00       	call   642 <exit>

000001df <main>:
}

int main() {
 1df:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 1e3:	83 e4 f0             	and    $0xfffffff0,%esp
 1e6:	ff 71 fc             	push   -0x4(%ecx)
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	51                   	push   %ecx
 1ed:	81 ec 54 0c 00 00    	sub    $0xc54,%esp
  setSchedPolicy(1);  // MLFQ 설정
 1f3:	83 ec 0c             	sub    $0xc,%esp
 1f6:	6a 01                	push   $0x1
 1f8:	e8 e5 04 00 00       	call   6e2 <setSchedPolicy>
 1fd:	83 c4 10             	add    $0x10,%esp

  if (fork() == 0) {
 200:	e8 35 04 00 00       	call   63a <fork>
 205:	85 c0                	test   %eax,%eax
 207:	75 37                	jne    240 <main+0x61>
    int delays[] = {8*TICK, 8*TICK, 8*TICK};  // P1: Q3 → Q2 → Q3
 209:	c7 85 e4 f3 ff ff 00 	movl   $0x4e200,-0xc1c(%ebp)
 210:	e2 04 00 
 213:	c7 85 e8 f3 ff ff 00 	movl   $0x4e200,-0xc18(%ebp)
 21a:	e2 04 00 
 21d:	c7 85 ec f3 ff ff 00 	movl   $0x4e200,-0xc14(%ebp)
 224:	e2 04 00 
    run_test("P1", delays, 3);
 227:	83 ec 04             	sub    $0x4,%esp
 22a:	6a 03                	push   $0x3
 22c:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
 232:	50                   	push   %eax
 233:	68 ba 0b 00 00       	push   $0xbba
 238:	e8 ce fe ff ff       	call   10b <run_test>
 23d:	83 c4 10             	add    $0x10,%esp
  }

  if (fork() == 0) {
 240:	e8 f5 03 00 00       	call   63a <fork>
 245:	85 c0                	test   %eax,%eax
 247:	75 4b                	jne    294 <main+0xb5>
    int delays[] = {8*TICK, 16*TICK, 32*TICK, 16*TICK, 8*TICK};  // P2: Q3→Q2→Q1→Q2→Q3
 249:	c7 85 d0 f3 ff ff 00 	movl   $0x4e200,-0xc30(%ebp)
 250:	e2 04 00 
 253:	c7 85 d4 f3 ff ff 00 	movl   $0x9c400,-0xc2c(%ebp)
 25a:	c4 09 00 
 25d:	c7 85 d8 f3 ff ff 00 	movl   $0x138800,-0xc28(%ebp)
 264:	88 13 00 
 267:	c7 85 dc f3 ff ff 00 	movl   $0x9c400,-0xc24(%ebp)
 26e:	c4 09 00 
 271:	c7 85 e0 f3 ff ff 00 	movl   $0x4e200,-0xc20(%ebp)
 278:	e2 04 00 
    run_test("P2", delays, 5);
 27b:	83 ec 04             	sub    $0x4,%esp
 27e:	6a 05                	push   $0x5
 280:	8d 85 d0 f3 ff ff    	lea    -0xc30(%ebp),%eax
 286:	50                   	push   %eax
 287:	68 bd 0b 00 00       	push   $0xbbd
 28c:	e8 7a fe ff ff       	call   10b <run_test>
 291:	83 c4 10             	add    $0x10,%esp
  }

  if (fork() == 0) {
 294:	e8 a1 03 00 00       	call   63a <fork>
 299:	85 c0                	test   %eax,%eax
 29b:	75 5f                	jne    2fc <main+0x11d>
    int delays[] = {8*TICK, 16*TICK, 32*TICK, 64*TICK, 32*TICK, 16*TICK, 8*TICK};  // P3: Q3→Q2→Q1→Q0→Q1→Q2→Q3
 29d:	c7 85 b4 f3 ff ff 00 	movl   $0x4e200,-0xc4c(%ebp)
 2a4:	e2 04 00 
 2a7:	c7 85 b8 f3 ff ff 00 	movl   $0x9c400,-0xc48(%ebp)
 2ae:	c4 09 00 
 2b1:	c7 85 bc f3 ff ff 00 	movl   $0x138800,-0xc44(%ebp)
 2b8:	88 13 00 
 2bb:	c7 85 c0 f3 ff ff 00 	movl   $0x271000,-0xc40(%ebp)
 2c2:	10 27 00 
 2c5:	c7 85 c4 f3 ff ff 00 	movl   $0x138800,-0xc3c(%ebp)
 2cc:	88 13 00 
 2cf:	c7 85 c8 f3 ff ff 00 	movl   $0x9c400,-0xc38(%ebp)
 2d6:	c4 09 00 
 2d9:	c7 85 cc f3 ff ff 00 	movl   $0x4e200,-0xc34(%ebp)
 2e0:	e2 04 00 
    run_test("P3", delays, 7);
 2e3:	83 ec 04             	sub    $0x4,%esp
 2e6:	6a 07                	push   $0x7
 2e8:	8d 85 b4 f3 ff ff    	lea    -0xc4c(%ebp),%eax
 2ee:	50                   	push   %eax
 2ef:	68 c0 0b 00 00       	push   $0xbc0
 2f4:	e8 12 fe ff ff       	call   10b <run_test>
 2f9:	83 c4 10             	add    $0x10,%esp
  }

  wait(); wait(); wait();  // 자식 종료 대기
 2fc:	e8 49 03 00 00       	call   64a <wait>
 301:	e8 44 03 00 00       	call   64a <wait>
 306:	e8 3f 03 00 00       	call   64a <wait>

  struct pstat ps;
  getpinfo(&ps);
 30b:	83 ec 0c             	sub    $0xc,%esp
 30e:	8d 85 f0 f3 ff ff    	lea    -0xc10(%ebp),%eax
 314:	50                   	push   %eax
 315:	e8 d0 03 00 00       	call   6ea <getpinfo>
 31a:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROC; i++) {
 31d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 324:	e9 a1 00 00 00       	jmp    3ca <main+0x1eb>
    if (ps.inuse[i]) {
 329:	8b 45 f4             	mov    -0xc(%ebp),%eax
 32c:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
 333:	85 c0                	test   %eax,%eax
 335:	0f 84 8b 00 00 00    	je     3c6 <main+0x1e7>
      printf(1, "\n[pid %d] Final priority: %d\n", ps.pid[i], ps.priority[i]);
 33b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 33e:	83 e8 80             	sub    $0xffffff80,%eax
 341:	8b 94 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%edx
 348:	8b 45 f4             	mov    -0xc(%ebp),%eax
 34b:	83 c0 40             	add    $0x40,%eax
 34e:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
 355:	52                   	push   %edx
 356:	50                   	push   %eax
 357:	68 c3 0b 00 00       	push   $0xbc3
 35c:	6a 01                	push   $0x1
 35e:	e8 6b 04 00 00       	call   7ce <printf>
 363:	83 c4 10             	add    $0x10,%esp
      for (int j = 0; j < 4; j++) {
 366:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 36d:	eb 51                	jmp    3c0 <main+0x1e1>
        printf(1, " Q%d → ticks: %d, wait_ticks: %d\n", j, ps.ticks[i][j], ps.wait_ticks[i][j]);
 36f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 372:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 379:	8b 45 f0             	mov    -0x10(%ebp),%eax
 37c:	01 d0                	add    %edx,%eax
 37e:	05 00 02 00 00       	add    $0x200,%eax
 383:	8b 94 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%edx
 38a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
 394:	8b 45 f0             	mov    -0x10(%ebp),%eax
 397:	01 c8                	add    %ecx,%eax
 399:	05 00 01 00 00       	add    $0x100,%eax
 39e:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
 3a5:	83 ec 0c             	sub    $0xc,%esp
 3a8:	52                   	push   %edx
 3a9:	50                   	push   %eax
 3aa:	ff 75 f0             	push   -0x10(%ebp)
 3ad:	68 e4 0b 00 00       	push   $0xbe4
 3b2:	6a 01                	push   $0x1
 3b4:	e8 15 04 00 00       	call   7ce <printf>
 3b9:	83 c4 20             	add    $0x20,%esp
      for (int j = 0; j < 4; j++) {
 3bc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 3c0:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 3c4:	7e a9                	jle    36f <main+0x190>
  for (int i = 0; i < NPROC; i++) {
 3c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3ca:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 3ce:	0f 8e 55 ff ff ff    	jle    329 <main+0x14a>
      }
    }
  }

  printf(1, "[parent] done. exiting...\n");
 3d4:	83 ec 08             	sub    $0x8,%esp
 3d7:	68 08 0c 00 00       	push   $0xc08
 3dc:	6a 01                	push   $0x1
 3de:	e8 eb 03 00 00       	call   7ce <printf>
 3e3:	83 c4 10             	add    $0x10,%esp
  exit();
 3e6:	e8 57 02 00 00       	call   642 <exit>

000003eb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3eb:	55                   	push   %ebp
 3ec:	89 e5                	mov    %esp,%ebp
 3ee:	57                   	push   %edi
 3ef:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3f3:	8b 55 10             	mov    0x10(%ebp),%edx
 3f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f9:	89 cb                	mov    %ecx,%ebx
 3fb:	89 df                	mov    %ebx,%edi
 3fd:	89 d1                	mov    %edx,%ecx
 3ff:	fc                   	cld    
 400:	f3 aa                	rep stos %al,%es:(%edi)
 402:	89 ca                	mov    %ecx,%edx
 404:	89 fb                	mov    %edi,%ebx
 406:	89 5d 08             	mov    %ebx,0x8(%ebp)
 409:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 40c:	90                   	nop
 40d:	5b                   	pop    %ebx
 40e:	5f                   	pop    %edi
 40f:	5d                   	pop    %ebp
 410:	c3                   	ret    

00000411 <strcpy>:



char*
strcpy(char *s, char *t)
{
 411:	55                   	push   %ebp
 412:	89 e5                	mov    %esp,%ebp
 414:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 417:	8b 45 08             	mov    0x8(%ebp),%eax
 41a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 41d:	90                   	nop
 41e:	8b 55 0c             	mov    0xc(%ebp),%edx
 421:	8d 42 01             	lea    0x1(%edx),%eax
 424:	89 45 0c             	mov    %eax,0xc(%ebp)
 427:	8b 45 08             	mov    0x8(%ebp),%eax
 42a:	8d 48 01             	lea    0x1(%eax),%ecx
 42d:	89 4d 08             	mov    %ecx,0x8(%ebp)
 430:	0f b6 12             	movzbl (%edx),%edx
 433:	88 10                	mov    %dl,(%eax)
 435:	0f b6 00             	movzbl (%eax),%eax
 438:	84 c0                	test   %al,%al
 43a:	75 e2                	jne    41e <strcpy+0xd>
    ;
  return os;
 43c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 43f:	c9                   	leave  
 440:	c3                   	ret    

00000441 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 441:	55                   	push   %ebp
 442:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 444:	eb 08                	jmp    44e <strcmp+0xd>
    p++, q++;
 446:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 44a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 44e:	8b 45 08             	mov    0x8(%ebp),%eax
 451:	0f b6 00             	movzbl (%eax),%eax
 454:	84 c0                	test   %al,%al
 456:	74 10                	je     468 <strcmp+0x27>
 458:	8b 45 08             	mov    0x8(%ebp),%eax
 45b:	0f b6 10             	movzbl (%eax),%edx
 45e:	8b 45 0c             	mov    0xc(%ebp),%eax
 461:	0f b6 00             	movzbl (%eax),%eax
 464:	38 c2                	cmp    %al,%dl
 466:	74 de                	je     446 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 468:	8b 45 08             	mov    0x8(%ebp),%eax
 46b:	0f b6 00             	movzbl (%eax),%eax
 46e:	0f b6 d0             	movzbl %al,%edx
 471:	8b 45 0c             	mov    0xc(%ebp),%eax
 474:	0f b6 00             	movzbl (%eax),%eax
 477:	0f b6 c8             	movzbl %al,%ecx
 47a:	89 d0                	mov    %edx,%eax
 47c:	29 c8                	sub    %ecx,%eax
}
 47e:	5d                   	pop    %ebp
 47f:	c3                   	ret    

00000480 <strlen>:

uint
strlen(char *s)
{
 480:	55                   	push   %ebp
 481:	89 e5                	mov    %esp,%ebp
 483:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 486:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 48d:	eb 04                	jmp    493 <strlen+0x13>
 48f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 493:	8b 55 fc             	mov    -0x4(%ebp),%edx
 496:	8b 45 08             	mov    0x8(%ebp),%eax
 499:	01 d0                	add    %edx,%eax
 49b:	0f b6 00             	movzbl (%eax),%eax
 49e:	84 c0                	test   %al,%al
 4a0:	75 ed                	jne    48f <strlen+0xf>
    ;
  return n;
 4a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4a5:	c9                   	leave  
 4a6:	c3                   	ret    

000004a7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4a7:	55                   	push   %ebp
 4a8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 4aa:	8b 45 10             	mov    0x10(%ebp),%eax
 4ad:	50                   	push   %eax
 4ae:	ff 75 0c             	push   0xc(%ebp)
 4b1:	ff 75 08             	push   0x8(%ebp)
 4b4:	e8 32 ff ff ff       	call   3eb <stosb>
 4b9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4bf:	c9                   	leave  
 4c0:	c3                   	ret    

000004c1 <strchr>:

char*
strchr(const char *s, char c)
{
 4c1:	55                   	push   %ebp
 4c2:	89 e5                	mov    %esp,%ebp
 4c4:	83 ec 04             	sub    $0x4,%esp
 4c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ca:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4cd:	eb 14                	jmp    4e3 <strchr+0x22>
    if(*s == c)
 4cf:	8b 45 08             	mov    0x8(%ebp),%eax
 4d2:	0f b6 00             	movzbl (%eax),%eax
 4d5:	38 45 fc             	cmp    %al,-0x4(%ebp)
 4d8:	75 05                	jne    4df <strchr+0x1e>
      return (char*)s;
 4da:	8b 45 08             	mov    0x8(%ebp),%eax
 4dd:	eb 13                	jmp    4f2 <strchr+0x31>
  for(; *s; s++)
 4df:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4e3:	8b 45 08             	mov    0x8(%ebp),%eax
 4e6:	0f b6 00             	movzbl (%eax),%eax
 4e9:	84 c0                	test   %al,%al
 4eb:	75 e2                	jne    4cf <strchr+0xe>
  return 0;
 4ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4f2:	c9                   	leave  
 4f3:	c3                   	ret    

000004f4 <gets>:

char*
gets(char *buf, int max)
{
 4f4:	55                   	push   %ebp
 4f5:	89 e5                	mov    %esp,%ebp
 4f7:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 501:	eb 42                	jmp    545 <gets+0x51>
    cc = read(0, &c, 1);
 503:	83 ec 04             	sub    $0x4,%esp
 506:	6a 01                	push   $0x1
 508:	8d 45 ef             	lea    -0x11(%ebp),%eax
 50b:	50                   	push   %eax
 50c:	6a 00                	push   $0x0
 50e:	e8 47 01 00 00       	call   65a <read>
 513:	83 c4 10             	add    $0x10,%esp
 516:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 519:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 51d:	7e 33                	jle    552 <gets+0x5e>
      break;
    buf[i++] = c;
 51f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 522:	8d 50 01             	lea    0x1(%eax),%edx
 525:	89 55 f4             	mov    %edx,-0xc(%ebp)
 528:	89 c2                	mov    %eax,%edx
 52a:	8b 45 08             	mov    0x8(%ebp),%eax
 52d:	01 c2                	add    %eax,%edx
 52f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 533:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 535:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 539:	3c 0a                	cmp    $0xa,%al
 53b:	74 16                	je     553 <gets+0x5f>
 53d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 541:	3c 0d                	cmp    $0xd,%al
 543:	74 0e                	je     553 <gets+0x5f>
  for(i=0; i+1 < max; ){
 545:	8b 45 f4             	mov    -0xc(%ebp),%eax
 548:	83 c0 01             	add    $0x1,%eax
 54b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 54e:	7f b3                	jg     503 <gets+0xf>
 550:	eb 01                	jmp    553 <gets+0x5f>
      break;
 552:	90                   	nop
      break;
  }
  buf[i] = '\0';
 553:	8b 55 f4             	mov    -0xc(%ebp),%edx
 556:	8b 45 08             	mov    0x8(%ebp),%eax
 559:	01 d0                	add    %edx,%eax
 55b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 55e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 561:	c9                   	leave  
 562:	c3                   	ret    

00000563 <stat>:

int
stat(char *n, struct stat *st)
{
 563:	55                   	push   %ebp
 564:	89 e5                	mov    %esp,%ebp
 566:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 569:	83 ec 08             	sub    $0x8,%esp
 56c:	6a 00                	push   $0x0
 56e:	ff 75 08             	push   0x8(%ebp)
 571:	e8 0c 01 00 00       	call   682 <open>
 576:	83 c4 10             	add    $0x10,%esp
 579:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 57c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 580:	79 07                	jns    589 <stat+0x26>
    return -1;
 582:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 587:	eb 25                	jmp    5ae <stat+0x4b>
  r = fstat(fd, st);
 589:	83 ec 08             	sub    $0x8,%esp
 58c:	ff 75 0c             	push   0xc(%ebp)
 58f:	ff 75 f4             	push   -0xc(%ebp)
 592:	e8 03 01 00 00       	call   69a <fstat>
 597:	83 c4 10             	add    $0x10,%esp
 59a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 59d:	83 ec 0c             	sub    $0xc,%esp
 5a0:	ff 75 f4             	push   -0xc(%ebp)
 5a3:	e8 c2 00 00 00       	call   66a <close>
 5a8:	83 c4 10             	add    $0x10,%esp
  return r;
 5ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5ae:	c9                   	leave  
 5af:	c3                   	ret    

000005b0 <atoi>:

int
atoi(const char *s)
{
 5b0:	55                   	push   %ebp
 5b1:	89 e5                	mov    %esp,%ebp
 5b3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 5b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5bd:	eb 25                	jmp    5e4 <atoi+0x34>
    n = n*10 + *s++ - '0';
 5bf:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5c2:	89 d0                	mov    %edx,%eax
 5c4:	c1 e0 02             	shl    $0x2,%eax
 5c7:	01 d0                	add    %edx,%eax
 5c9:	01 c0                	add    %eax,%eax
 5cb:	89 c1                	mov    %eax,%ecx
 5cd:	8b 45 08             	mov    0x8(%ebp),%eax
 5d0:	8d 50 01             	lea    0x1(%eax),%edx
 5d3:	89 55 08             	mov    %edx,0x8(%ebp)
 5d6:	0f b6 00             	movzbl (%eax),%eax
 5d9:	0f be c0             	movsbl %al,%eax
 5dc:	01 c8                	add    %ecx,%eax
 5de:	83 e8 30             	sub    $0x30,%eax
 5e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5e4:	8b 45 08             	mov    0x8(%ebp),%eax
 5e7:	0f b6 00             	movzbl (%eax),%eax
 5ea:	3c 2f                	cmp    $0x2f,%al
 5ec:	7e 0a                	jle    5f8 <atoi+0x48>
 5ee:	8b 45 08             	mov    0x8(%ebp),%eax
 5f1:	0f b6 00             	movzbl (%eax),%eax
 5f4:	3c 39                	cmp    $0x39,%al
 5f6:	7e c7                	jle    5bf <atoi+0xf>
  return n;
 5f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5fb:	c9                   	leave  
 5fc:	c3                   	ret    

000005fd <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 5fd:	55                   	push   %ebp
 5fe:	89 e5                	mov    %esp,%ebp
 600:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 603:	8b 45 08             	mov    0x8(%ebp),%eax
 606:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 609:	8b 45 0c             	mov    0xc(%ebp),%eax
 60c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 60f:	eb 17                	jmp    628 <memmove+0x2b>
    *dst++ = *src++;
 611:	8b 55 f8             	mov    -0x8(%ebp),%edx
 614:	8d 42 01             	lea    0x1(%edx),%eax
 617:	89 45 f8             	mov    %eax,-0x8(%ebp)
 61a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61d:	8d 48 01             	lea    0x1(%eax),%ecx
 620:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 623:	0f b6 12             	movzbl (%edx),%edx
 626:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 628:	8b 45 10             	mov    0x10(%ebp),%eax
 62b:	8d 50 ff             	lea    -0x1(%eax),%edx
 62e:	89 55 10             	mov    %edx,0x10(%ebp)
 631:	85 c0                	test   %eax,%eax
 633:	7f dc                	jg     611 <memmove+0x14>
  return vdst;
 635:	8b 45 08             	mov    0x8(%ebp),%eax
}
 638:	c9                   	leave  
 639:	c3                   	ret    

0000063a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 63a:	b8 01 00 00 00       	mov    $0x1,%eax
 63f:	cd 40                	int    $0x40
 641:	c3                   	ret    

00000642 <exit>:
SYSCALL(exit)
 642:	b8 02 00 00 00       	mov    $0x2,%eax
 647:	cd 40                	int    $0x40
 649:	c3                   	ret    

0000064a <wait>:
SYSCALL(wait)
 64a:	b8 03 00 00 00       	mov    $0x3,%eax
 64f:	cd 40                	int    $0x40
 651:	c3                   	ret    

00000652 <pipe>:
SYSCALL(pipe)
 652:	b8 04 00 00 00       	mov    $0x4,%eax
 657:	cd 40                	int    $0x40
 659:	c3                   	ret    

0000065a <read>:
SYSCALL(read)
 65a:	b8 05 00 00 00       	mov    $0x5,%eax
 65f:	cd 40                	int    $0x40
 661:	c3                   	ret    

00000662 <write>:
SYSCALL(write)
 662:	b8 10 00 00 00       	mov    $0x10,%eax
 667:	cd 40                	int    $0x40
 669:	c3                   	ret    

0000066a <close>:
SYSCALL(close)
 66a:	b8 15 00 00 00       	mov    $0x15,%eax
 66f:	cd 40                	int    $0x40
 671:	c3                   	ret    

00000672 <kill>:
SYSCALL(kill)
 672:	b8 06 00 00 00       	mov    $0x6,%eax
 677:	cd 40                	int    $0x40
 679:	c3                   	ret    

0000067a <exec>:
SYSCALL(exec)
 67a:	b8 07 00 00 00       	mov    $0x7,%eax
 67f:	cd 40                	int    $0x40
 681:	c3                   	ret    

00000682 <open>:
SYSCALL(open)
 682:	b8 0f 00 00 00       	mov    $0xf,%eax
 687:	cd 40                	int    $0x40
 689:	c3                   	ret    

0000068a <mknod>:
SYSCALL(mknod)
 68a:	b8 11 00 00 00       	mov    $0x11,%eax
 68f:	cd 40                	int    $0x40
 691:	c3                   	ret    

00000692 <unlink>:
SYSCALL(unlink)
 692:	b8 12 00 00 00       	mov    $0x12,%eax
 697:	cd 40                	int    $0x40
 699:	c3                   	ret    

0000069a <fstat>:
SYSCALL(fstat)
 69a:	b8 08 00 00 00       	mov    $0x8,%eax
 69f:	cd 40                	int    $0x40
 6a1:	c3                   	ret    

000006a2 <link>:
SYSCALL(link)
 6a2:	b8 13 00 00 00       	mov    $0x13,%eax
 6a7:	cd 40                	int    $0x40
 6a9:	c3                   	ret    

000006aa <mkdir>:
SYSCALL(mkdir)
 6aa:	b8 14 00 00 00       	mov    $0x14,%eax
 6af:	cd 40                	int    $0x40
 6b1:	c3                   	ret    

000006b2 <chdir>:
SYSCALL(chdir)
 6b2:	b8 09 00 00 00       	mov    $0x9,%eax
 6b7:	cd 40                	int    $0x40
 6b9:	c3                   	ret    

000006ba <dup>:
SYSCALL(dup)
 6ba:	b8 0a 00 00 00       	mov    $0xa,%eax
 6bf:	cd 40                	int    $0x40
 6c1:	c3                   	ret    

000006c2 <getpid>:
SYSCALL(getpid)
 6c2:	b8 0b 00 00 00       	mov    $0xb,%eax
 6c7:	cd 40                	int    $0x40
 6c9:	c3                   	ret    

000006ca <sbrk>:
SYSCALL(sbrk)
 6ca:	b8 0c 00 00 00       	mov    $0xc,%eax
 6cf:	cd 40                	int    $0x40
 6d1:	c3                   	ret    

000006d2 <sleep>:
SYSCALL(sleep)
 6d2:	b8 0d 00 00 00       	mov    $0xd,%eax
 6d7:	cd 40                	int    $0x40
 6d9:	c3                   	ret    

000006da <uptime>:
SYSCALL(uptime)
 6da:	b8 0e 00 00 00       	mov    $0xe,%eax
 6df:	cd 40                	int    $0x40
 6e1:	c3                   	ret    

000006e2 <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 6e2:	b8 16 00 00 00       	mov    $0x16,%eax
 6e7:	cd 40                	int    $0x40
 6e9:	c3                   	ret    

000006ea <getpinfo>:
SYSCALL(getpinfo)
 6ea:	b8 17 00 00 00       	mov    $0x17,%eax
 6ef:	cd 40                	int    $0x40
 6f1:	c3                   	ret    

000006f2 <yield>:
SYSCALL(yield)
 6f2:	b8 18 00 00 00       	mov    $0x18,%eax
 6f7:	cd 40                	int    $0x40
 6f9:	c3                   	ret    

000006fa <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6fa:	55                   	push   %ebp
 6fb:	89 e5                	mov    %esp,%ebp
 6fd:	83 ec 18             	sub    $0x18,%esp
 700:	8b 45 0c             	mov    0xc(%ebp),%eax
 703:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 706:	83 ec 04             	sub    $0x4,%esp
 709:	6a 01                	push   $0x1
 70b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 70e:	50                   	push   %eax
 70f:	ff 75 08             	push   0x8(%ebp)
 712:	e8 4b ff ff ff       	call   662 <write>
 717:	83 c4 10             	add    $0x10,%esp
}
 71a:	90                   	nop
 71b:	c9                   	leave  
 71c:	c3                   	ret    

0000071d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 71d:	55                   	push   %ebp
 71e:	89 e5                	mov    %esp,%ebp
 720:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 723:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 72a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 72e:	74 17                	je     747 <printint+0x2a>
 730:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 734:	79 11                	jns    747 <printint+0x2a>
    neg = 1;
 736:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 73d:	8b 45 0c             	mov    0xc(%ebp),%eax
 740:	f7 d8                	neg    %eax
 742:	89 45 ec             	mov    %eax,-0x14(%ebp)
 745:	eb 06                	jmp    74d <printint+0x30>
  } else {
    x = xx;
 747:	8b 45 0c             	mov    0xc(%ebp),%eax
 74a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 74d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 754:	8b 4d 10             	mov    0x10(%ebp),%ecx
 757:	8b 45 ec             	mov    -0x14(%ebp),%eax
 75a:	ba 00 00 00 00       	mov    $0x0,%edx
 75f:	f7 f1                	div    %ecx
 761:	89 d1                	mov    %edx,%ecx
 763:	8b 45 f4             	mov    -0xc(%ebp),%eax
 766:	8d 50 01             	lea    0x1(%eax),%edx
 769:	89 55 f4             	mov    %edx,-0xc(%ebp)
 76c:	0f b6 91 d4 0e 00 00 	movzbl 0xed4(%ecx),%edx
 773:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 777:	8b 4d 10             	mov    0x10(%ebp),%ecx
 77a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 77d:	ba 00 00 00 00       	mov    $0x0,%edx
 782:	f7 f1                	div    %ecx
 784:	89 45 ec             	mov    %eax,-0x14(%ebp)
 787:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 78b:	75 c7                	jne    754 <printint+0x37>
  if(neg)
 78d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 791:	74 2d                	je     7c0 <printint+0xa3>
    buf[i++] = '-';
 793:	8b 45 f4             	mov    -0xc(%ebp),%eax
 796:	8d 50 01             	lea    0x1(%eax),%edx
 799:	89 55 f4             	mov    %edx,-0xc(%ebp)
 79c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7a1:	eb 1d                	jmp    7c0 <printint+0xa3>
    putc(fd, buf[i]);
 7a3:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a9:	01 d0                	add    %edx,%eax
 7ab:	0f b6 00             	movzbl (%eax),%eax
 7ae:	0f be c0             	movsbl %al,%eax
 7b1:	83 ec 08             	sub    $0x8,%esp
 7b4:	50                   	push   %eax
 7b5:	ff 75 08             	push   0x8(%ebp)
 7b8:	e8 3d ff ff ff       	call   6fa <putc>
 7bd:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 7c0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c8:	79 d9                	jns    7a3 <printint+0x86>
}
 7ca:	90                   	nop
 7cb:	90                   	nop
 7cc:	c9                   	leave  
 7cd:	c3                   	ret    

000007ce <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7ce:	55                   	push   %ebp
 7cf:	89 e5                	mov    %esp,%ebp
 7d1:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7db:	8d 45 0c             	lea    0xc(%ebp),%eax
 7de:	83 c0 04             	add    $0x4,%eax
 7e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7eb:	e9 59 01 00 00       	jmp    949 <printf+0x17b>
    c = fmt[i] & 0xff;
 7f0:	8b 55 0c             	mov    0xc(%ebp),%edx
 7f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f6:	01 d0                	add    %edx,%eax
 7f8:	0f b6 00             	movzbl (%eax),%eax
 7fb:	0f be c0             	movsbl %al,%eax
 7fe:	25 ff 00 00 00       	and    $0xff,%eax
 803:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 806:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 80a:	75 2c                	jne    838 <printf+0x6a>
      if(c == '%'){
 80c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 810:	75 0c                	jne    81e <printf+0x50>
        state = '%';
 812:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 819:	e9 27 01 00 00       	jmp    945 <printf+0x177>
      } else {
        putc(fd, c);
 81e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 821:	0f be c0             	movsbl %al,%eax
 824:	83 ec 08             	sub    $0x8,%esp
 827:	50                   	push   %eax
 828:	ff 75 08             	push   0x8(%ebp)
 82b:	e8 ca fe ff ff       	call   6fa <putc>
 830:	83 c4 10             	add    $0x10,%esp
 833:	e9 0d 01 00 00       	jmp    945 <printf+0x177>
      }
    } else if(state == '%'){
 838:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 83c:	0f 85 03 01 00 00    	jne    945 <printf+0x177>
      if(c == 'd'){
 842:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 846:	75 1e                	jne    866 <printf+0x98>
        printint(fd, *ap, 10, 1);
 848:	8b 45 e8             	mov    -0x18(%ebp),%eax
 84b:	8b 00                	mov    (%eax),%eax
 84d:	6a 01                	push   $0x1
 84f:	6a 0a                	push   $0xa
 851:	50                   	push   %eax
 852:	ff 75 08             	push   0x8(%ebp)
 855:	e8 c3 fe ff ff       	call   71d <printint>
 85a:	83 c4 10             	add    $0x10,%esp
        ap++;
 85d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 861:	e9 d8 00 00 00       	jmp    93e <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 866:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 86a:	74 06                	je     872 <printf+0xa4>
 86c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 870:	75 1e                	jne    890 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 872:	8b 45 e8             	mov    -0x18(%ebp),%eax
 875:	8b 00                	mov    (%eax),%eax
 877:	6a 00                	push   $0x0
 879:	6a 10                	push   $0x10
 87b:	50                   	push   %eax
 87c:	ff 75 08             	push   0x8(%ebp)
 87f:	e8 99 fe ff ff       	call   71d <printint>
 884:	83 c4 10             	add    $0x10,%esp
        ap++;
 887:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 88b:	e9 ae 00 00 00       	jmp    93e <printf+0x170>
      } else if(c == 's'){
 890:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 894:	75 43                	jne    8d9 <printf+0x10b>
        s = (char*)*ap;
 896:	8b 45 e8             	mov    -0x18(%ebp),%eax
 899:	8b 00                	mov    (%eax),%eax
 89b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 89e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8a6:	75 25                	jne    8cd <printf+0xff>
          s = "(null)";
 8a8:	c7 45 f4 23 0c 00 00 	movl   $0xc23,-0xc(%ebp)
        while(*s != 0){
 8af:	eb 1c                	jmp    8cd <printf+0xff>
          putc(fd, *s);
 8b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b4:	0f b6 00             	movzbl (%eax),%eax
 8b7:	0f be c0             	movsbl %al,%eax
 8ba:	83 ec 08             	sub    $0x8,%esp
 8bd:	50                   	push   %eax
 8be:	ff 75 08             	push   0x8(%ebp)
 8c1:	e8 34 fe ff ff       	call   6fa <putc>
 8c6:	83 c4 10             	add    $0x10,%esp
          s++;
 8c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 8cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d0:	0f b6 00             	movzbl (%eax),%eax
 8d3:	84 c0                	test   %al,%al
 8d5:	75 da                	jne    8b1 <printf+0xe3>
 8d7:	eb 65                	jmp    93e <printf+0x170>
        }
      } else if(c == 'c'){
 8d9:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8dd:	75 1d                	jne    8fc <printf+0x12e>
        putc(fd, *ap);
 8df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8e2:	8b 00                	mov    (%eax),%eax
 8e4:	0f be c0             	movsbl %al,%eax
 8e7:	83 ec 08             	sub    $0x8,%esp
 8ea:	50                   	push   %eax
 8eb:	ff 75 08             	push   0x8(%ebp)
 8ee:	e8 07 fe ff ff       	call   6fa <putc>
 8f3:	83 c4 10             	add    $0x10,%esp
        ap++;
 8f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8fa:	eb 42                	jmp    93e <printf+0x170>
      } else if(c == '%'){
 8fc:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 900:	75 17                	jne    919 <printf+0x14b>
        putc(fd, c);
 902:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 905:	0f be c0             	movsbl %al,%eax
 908:	83 ec 08             	sub    $0x8,%esp
 90b:	50                   	push   %eax
 90c:	ff 75 08             	push   0x8(%ebp)
 90f:	e8 e6 fd ff ff       	call   6fa <putc>
 914:	83 c4 10             	add    $0x10,%esp
 917:	eb 25                	jmp    93e <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 919:	83 ec 08             	sub    $0x8,%esp
 91c:	6a 25                	push   $0x25
 91e:	ff 75 08             	push   0x8(%ebp)
 921:	e8 d4 fd ff ff       	call   6fa <putc>
 926:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 929:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 92c:	0f be c0             	movsbl %al,%eax
 92f:	83 ec 08             	sub    $0x8,%esp
 932:	50                   	push   %eax
 933:	ff 75 08             	push   0x8(%ebp)
 936:	e8 bf fd ff ff       	call   6fa <putc>
 93b:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 93e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 945:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 949:	8b 55 0c             	mov    0xc(%ebp),%edx
 94c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94f:	01 d0                	add    %edx,%eax
 951:	0f b6 00             	movzbl (%eax),%eax
 954:	84 c0                	test   %al,%al
 956:	0f 85 94 fe ff ff    	jne    7f0 <printf+0x22>
    }
  }
}
 95c:	90                   	nop
 95d:	90                   	nop
 95e:	c9                   	leave  
 95f:	c3                   	ret    

00000960 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 960:	55                   	push   %ebp
 961:	89 e5                	mov    %esp,%ebp
 963:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 966:	8b 45 08             	mov    0x8(%ebp),%eax
 969:	83 e8 08             	sub    $0x8,%eax
 96c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 96f:	a1 f0 0e 00 00       	mov    0xef0,%eax
 974:	89 45 fc             	mov    %eax,-0x4(%ebp)
 977:	eb 24                	jmp    99d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 979:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97c:	8b 00                	mov    (%eax),%eax
 97e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 981:	72 12                	jb     995 <free+0x35>
 983:	8b 45 f8             	mov    -0x8(%ebp),%eax
 986:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 989:	77 24                	ja     9af <free+0x4f>
 98b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98e:	8b 00                	mov    (%eax),%eax
 990:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 993:	72 1a                	jb     9af <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 995:	8b 45 fc             	mov    -0x4(%ebp),%eax
 998:	8b 00                	mov    (%eax),%eax
 99a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 99d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9a3:	76 d4                	jbe    979 <free+0x19>
 9a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a8:	8b 00                	mov    (%eax),%eax
 9aa:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9ad:	73 ca                	jae    979 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b2:	8b 40 04             	mov    0x4(%eax),%eax
 9b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bf:	01 c2                	add    %eax,%edx
 9c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c4:	8b 00                	mov    (%eax),%eax
 9c6:	39 c2                	cmp    %eax,%edx
 9c8:	75 24                	jne    9ee <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9cd:	8b 50 04             	mov    0x4(%eax),%edx
 9d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d3:	8b 00                	mov    (%eax),%eax
 9d5:	8b 40 04             	mov    0x4(%eax),%eax
 9d8:	01 c2                	add    %eax,%edx
 9da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9dd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e3:	8b 00                	mov    (%eax),%eax
 9e5:	8b 10                	mov    (%eax),%edx
 9e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ea:	89 10                	mov    %edx,(%eax)
 9ec:	eb 0a                	jmp    9f8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f1:	8b 10                	mov    (%eax),%edx
 9f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fb:	8b 40 04             	mov    0x4(%eax),%eax
 9fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a08:	01 d0                	add    %edx,%eax
 a0a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a0d:	75 20                	jne    a2f <free+0xcf>
    p->s.size += bp->s.size;
 a0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a12:	8b 50 04             	mov    0x4(%eax),%edx
 a15:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a18:	8b 40 04             	mov    0x4(%eax),%eax
 a1b:	01 c2                	add    %eax,%edx
 a1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a20:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a23:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a26:	8b 10                	mov    (%eax),%edx
 a28:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2b:	89 10                	mov    %edx,(%eax)
 a2d:	eb 08                	jmp    a37 <free+0xd7>
  } else
    p->s.ptr = bp;
 a2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a32:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a35:	89 10                	mov    %edx,(%eax)
  freep = p;
 a37:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3a:	a3 f0 0e 00 00       	mov    %eax,0xef0
}
 a3f:	90                   	nop
 a40:	c9                   	leave  
 a41:	c3                   	ret    

00000a42 <morecore>:

static Header*
morecore(uint nu)
{
 a42:	55                   	push   %ebp
 a43:	89 e5                	mov    %esp,%ebp
 a45:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a48:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a4f:	77 07                	ja     a58 <morecore+0x16>
    nu = 4096;
 a51:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a58:	8b 45 08             	mov    0x8(%ebp),%eax
 a5b:	c1 e0 03             	shl    $0x3,%eax
 a5e:	83 ec 0c             	sub    $0xc,%esp
 a61:	50                   	push   %eax
 a62:	e8 63 fc ff ff       	call   6ca <sbrk>
 a67:	83 c4 10             	add    $0x10,%esp
 a6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a6d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a71:	75 07                	jne    a7a <morecore+0x38>
    return 0;
 a73:	b8 00 00 00 00       	mov    $0x0,%eax
 a78:	eb 26                	jmp    aa0 <morecore+0x5e>
  hp = (Header*)p;
 a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a83:	8b 55 08             	mov    0x8(%ebp),%edx
 a86:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8c:	83 c0 08             	add    $0x8,%eax
 a8f:	83 ec 0c             	sub    $0xc,%esp
 a92:	50                   	push   %eax
 a93:	e8 c8 fe ff ff       	call   960 <free>
 a98:	83 c4 10             	add    $0x10,%esp
  return freep;
 a9b:	a1 f0 0e 00 00       	mov    0xef0,%eax
}
 aa0:	c9                   	leave  
 aa1:	c3                   	ret    

00000aa2 <malloc>:

void*
malloc(uint nbytes)
{
 aa2:	55                   	push   %ebp
 aa3:	89 e5                	mov    %esp,%ebp
 aa5:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 aa8:	8b 45 08             	mov    0x8(%ebp),%eax
 aab:	83 c0 07             	add    $0x7,%eax
 aae:	c1 e8 03             	shr    $0x3,%eax
 ab1:	83 c0 01             	add    $0x1,%eax
 ab4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 ab7:	a1 f0 0e 00 00       	mov    0xef0,%eax
 abc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 abf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ac3:	75 23                	jne    ae8 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 ac5:	c7 45 f0 e8 0e 00 00 	movl   $0xee8,-0x10(%ebp)
 acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 acf:	a3 f0 0e 00 00       	mov    %eax,0xef0
 ad4:	a1 f0 0e 00 00       	mov    0xef0,%eax
 ad9:	a3 e8 0e 00 00       	mov    %eax,0xee8
    base.s.size = 0;
 ade:	c7 05 ec 0e 00 00 00 	movl   $0x0,0xeec
 ae5:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aeb:	8b 00                	mov    (%eax),%eax
 aed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af3:	8b 40 04             	mov    0x4(%eax),%eax
 af6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 af9:	77 4d                	ja     b48 <malloc+0xa6>
      if(p->s.size == nunits)
 afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afe:	8b 40 04             	mov    0x4(%eax),%eax
 b01:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b04:	75 0c                	jne    b12 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b09:	8b 10                	mov    (%eax),%edx
 b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b0e:	89 10                	mov    %edx,(%eax)
 b10:	eb 26                	jmp    b38 <malloc+0x96>
      else {
        p->s.size -= nunits;
 b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b15:	8b 40 04             	mov    0x4(%eax),%eax
 b18:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b1b:	89 c2                	mov    %eax,%edx
 b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b20:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b26:	8b 40 04             	mov    0x4(%eax),%eax
 b29:	c1 e0 03             	shl    $0x3,%eax
 b2c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b32:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b35:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b3b:	a3 f0 0e 00 00       	mov    %eax,0xef0
      return (void*)(p + 1);
 b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b43:	83 c0 08             	add    $0x8,%eax
 b46:	eb 3b                	jmp    b83 <malloc+0xe1>
    }
    if(p == freep)
 b48:	a1 f0 0e 00 00       	mov    0xef0,%eax
 b4d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b50:	75 1e                	jne    b70 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b52:	83 ec 0c             	sub    $0xc,%esp
 b55:	ff 75 ec             	push   -0x14(%ebp)
 b58:	e8 e5 fe ff ff       	call   a42 <morecore>
 b5d:	83 c4 10             	add    $0x10,%esp
 b60:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b67:	75 07                	jne    b70 <malloc+0xce>
        return 0;
 b69:	b8 00 00 00 00       	mov    $0x0,%eax
 b6e:	eb 13                	jmp    b83 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b73:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b79:	8b 00                	mov    (%eax),%eax
 b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b7e:	e9 6d ff ff ff       	jmp    af0 <malloc+0x4e>
  }
}
 b83:	c9                   	leave  
 b84:	c3                   	ret    
