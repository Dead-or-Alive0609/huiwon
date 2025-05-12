
_test3:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "user.h"
#include "pstat.h"

#define N 4

int workload(int n) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++)
  11:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  18:	eb 11                	jmp    2b <workload+0x2b>
    j += i * j + 1;
  1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1d:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  21:	83 c0 01             	add    $0x1,%eax
  24:	01 45 f8             	add    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++)
  27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2e:	3b 45 08             	cmp    0x8(%ebp),%eax
  31:	7c e7                	jl     1a <workload+0x1a>
  return j;
  33:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  36:	c9                   	leave  
  37:	c3                   	ret    

00000038 <get_proc_index>:

int get_proc_index(int pid, struct pstat *st) {
  38:	f3 0f 1e fb          	endbr32 
  3c:	55                   	push   %ebp
  3d:	89 e5                	mov    %esp,%ebp
  3f:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  42:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  49:	eb 27                	jmp    72 <get_proc_index+0x3a>
    if (st->inuse[i] && st->pid[i] == pid)
  4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  4e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  51:	8b 04 90             	mov    (%eax,%edx,4),%eax
  54:	85 c0                	test   %eax,%eax
  56:	74 16                	je     6e <get_proc_index+0x36>
  58:	8b 45 0c             	mov    0xc(%ebp),%eax
  5b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  5e:	83 c2 40             	add    $0x40,%edx
  61:	8b 04 90             	mov    (%eax,%edx,4),%eax
  64:	39 45 08             	cmp    %eax,0x8(%ebp)
  67:	75 05                	jne    6e <get_proc_index+0x36>
      return i;
  69:	8b 45 fc             	mov    -0x4(%ebp),%eax
  6c:	eb 0f                	jmp    7d <get_proc_index+0x45>
  for (int i = 0; i < NPROC; i++) {
  6e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  72:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
  76:	7e d3                	jle    4b <get_proc_index+0x13>
  }
  return -1;
  78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  7d:	c9                   	leave  
  7e:	c3                   	ret    

0000007f <child_with_yield>:

void child_with_yield() {
  7f:	f3 0f 1e fb          	endbr32 
  83:	55                   	push   %ebp
  84:	89 e5                	mov    %esp,%ebp
  86:	83 ec 18             	sub    $0x18,%esp
  for (int i = 0; i < 4; i++) {
  89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  90:	eb 16                	jmp    a8 <child_with_yield+0x29>
    workload(1000000); // 더 가볍게 하여 yield 효과 살림
  92:	68 40 42 0f 00       	push   $0xf4240
  97:	e8 64 ff ff ff       	call   0 <workload>
  9c:	83 c4 04             	add    $0x4,%esp
    yield();
  9f:	e8 5a 05 00 00       	call   5fe <yield>
  for (int i = 0; i < 4; i++) {
  a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  a8:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  ac:	7e e4                	jle    92 <child_with_yield+0x13>
  }
  sleep(100); // 더 오래 대기하여 상태 보존 보장
  ae:	83 ec 0c             	sub    $0xc,%esp
  b1:	6a 64                	push   $0x64
  b3:	e8 26 05 00 00       	call   5de <sleep>
  b8:	83 c4 10             	add    $0x10,%esp
  exit();
  bb:	e8 8e 04 00 00       	call   54e <exit>

000000c0 <child_no_yield>:
}

void child_no_yield() {
  c0:	f3 0f 1e fb          	endbr32 
  c4:	55                   	push   %ebp
  c5:	89 e5                	mov    %esp,%ebp
  c7:	83 ec 18             	sub    $0x18,%esp
  for (int i = 0; i < 200; i++) {
  ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  d1:	eb 11                	jmp    e4 <child_no_yield+0x24>
    workload(100000); // 총 tick 소모 유도
  d3:	68 a0 86 01 00       	push   $0x186a0
  d8:	e8 23 ff ff ff       	call   0 <workload>
  dd:	83 c4 04             	add    $0x4,%esp
  for (int i = 0; i < 200; i++) {
  e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  e4:	81 7d f4 c7 00 00 00 	cmpl   $0xc7,-0xc(%ebp)
  eb:	7e e6                	jle    d3 <child_no_yield+0x13>
  }
  sleep(200); // 더 긴 sleep으로 tick 누적 보장
  ed:	83 ec 0c             	sub    $0xc,%esp
  f0:	68 c8 00 00 00       	push   $0xc8
  f5:	e8 e4 04 00 00       	call   5de <sleep>
  fa:	83 c4 10             	add    $0x10,%esp
  exit();
  fd:	e8 4c 04 00 00       	call   54e <exit>

00000102 <main>:
}

int main(void) {
 102:	f3 0f 1e fb          	endbr32 
 106:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 10a:	83 e4 f0             	and    $0xfffffff0,%esp
 10d:	ff 71 fc             	pushl  -0x4(%ecx)
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	51                   	push   %ecx
 114:	81 ec 24 0c 00 00    	sub    $0xc24,%esp
  int pids[N];
  struct pstat st;

  printf(1, "setSchedPolicy(3)\n");
 11a:	83 ec 08             	sub    $0x8,%esp
 11d:	68 ac 0a 00 00       	push   $0xaac
 122:	6a 01                	push   $0x1
 124:	e8 b9 05 00 00       	call   6e2 <printf>
 129:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(3);
 12c:	83 ec 0c             	sub    $0xc,%esp
 12f:	6a 03                	push   $0x3
 131:	e8 b8 04 00 00       	call   5ee <setSchedPolicy>
 136:	83 c4 10             	add    $0x10,%esp

  if ((pids[0] = fork()) == 0) child_with_yield(); // P1
 139:	e8 08 04 00 00       	call   546 <fork>
 13e:	89 45 d8             	mov    %eax,-0x28(%ebp)
 141:	8b 45 d8             	mov    -0x28(%ebp),%eax
 144:	85 c0                	test   %eax,%eax
 146:	75 05                	jne    14d <main+0x4b>
 148:	e8 32 ff ff ff       	call   7f <child_with_yield>
  if ((pids[1] = fork()) == 0) child_with_yield(); // P2
 14d:	e8 f4 03 00 00       	call   546 <fork>
 152:	89 45 dc             	mov    %eax,-0x24(%ebp)
 155:	8b 45 dc             	mov    -0x24(%ebp),%eax
 158:	85 c0                	test   %eax,%eax
 15a:	75 05                	jne    161 <main+0x5f>
 15c:	e8 1e ff ff ff       	call   7f <child_with_yield>
  if ((pids[2] = fork()) == 0) child_no_yield();  // P3
 161:	e8 e0 03 00 00       	call   546 <fork>
 166:	89 45 e0             	mov    %eax,-0x20(%ebp)
 169:	8b 45 e0             	mov    -0x20(%ebp),%eax
 16c:	85 c0                	test   %eax,%eax
 16e:	75 05                	jne    175 <main+0x73>
 170:	e8 4b ff ff ff       	call   c0 <child_no_yield>
  if ((pids[3] = fork()) == 0) child_no_yield();  // P4
 175:	e8 cc 03 00 00       	call   546 <fork>
 17a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 17d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 180:	85 c0                	test   %eax,%eax
 182:	75 05                	jne    189 <main+0x87>
 184:	e8 37 ff ff ff       	call   c0 <child_no_yield>

  sleep(800); // 모든 프로세스가 충분히 실행되도록 대기
 189:	83 ec 0c             	sub    $0xc,%esp
 18c:	68 20 03 00 00       	push   $0x320
 191:	e8 48 04 00 00       	call   5de <sleep>
 196:	83 c4 10             	add    $0x10,%esp

  getpinfo(&st);
 199:	83 ec 0c             	sub    $0xc,%esp
 19c:	8d 85 d8 f3 ff ff    	lea    -0xc28(%ebp),%eax
 1a2:	50                   	push   %eax
 1a3:	e8 4e 04 00 00       	call   5f6 <getpinfo>
 1a8:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < N; i++) {
 1ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1b2:	e9 d1 00 00 00       	jmp    288 <main+0x186>
    int idx = get_proc_index(pids[i], &st);
 1b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ba:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
 1be:	83 ec 08             	sub    $0x8,%esp
 1c1:	8d 95 d8 f3 ff ff    	lea    -0xc28(%ebp),%edx
 1c7:	52                   	push   %edx
 1c8:	50                   	push   %eax
 1c9:	e8 6a fe ff ff       	call   38 <get_proc_index>
 1ce:	83 c4 10             	add    $0x10,%esp
 1d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (idx == -1) {
 1d4:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
 1d8:	75 1e                	jne    1f8 <main+0xf6>
      printf(1, "[P%d] not found in pstat!\n", i + 1);
 1da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dd:	83 c0 01             	add    $0x1,%eax
 1e0:	83 ec 04             	sub    $0x4,%esp
 1e3:	50                   	push   %eax
 1e4:	68 bf 0a 00 00       	push   $0xabf
 1e9:	6a 01                	push   $0x1
 1eb:	e8 f2 04 00 00       	call   6e2 <printf>
 1f0:	83 c4 10             	add    $0x10,%esp
      continue;
 1f3:	e9 8c 00 00 00       	jmp    284 <main+0x182>
    }

    int prio = st.priority[idx];
 1f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1fb:	83 e8 80             	sub    $0xffffff80,%eax
 1fe:	8b 84 85 d8 f3 ff ff 	mov    -0xc28(%ebp,%eax,4),%eax
 205:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (i < 2) {
 208:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
 20c:	7f 3c                	jg     24a <main+0x148>
      if (prio == 3)
 20e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
 212:	75 1b                	jne    22f <main+0x12d>
        printf(1, "[P%d] priority = Q3 → OK (yield)\n", i + 1);
 214:	8b 45 f4             	mov    -0xc(%ebp),%eax
 217:	83 c0 01             	add    $0x1,%eax
 21a:	83 ec 04             	sub    $0x4,%esp
 21d:	50                   	push   %eax
 21e:	68 dc 0a 00 00       	push   $0xadc
 223:	6a 01                	push   $0x1
 225:	e8 b8 04 00 00       	call   6e2 <printf>
 22a:	83 c4 10             	add    $0x10,%esp
 22d:	eb 55                	jmp    284 <main+0x182>
      else
        printf(1, "[P%d] priority = Q%d → FAIL (should be Q3)\n", i + 1, prio);
 22f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 232:	83 c0 01             	add    $0x1,%eax
 235:	ff 75 e8             	pushl  -0x18(%ebp)
 238:	50                   	push   %eax
 239:	68 00 0b 00 00       	push   $0xb00
 23e:	6a 01                	push   $0x1
 240:	e8 9d 04 00 00       	call   6e2 <printf>
 245:	83 c4 10             	add    $0x10,%esp
 248:	eb 3a                	jmp    284 <main+0x182>
    } else {
      if (prio == 0)
 24a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 24e:	75 1b                	jne    26b <main+0x169>
        printf(1, "[P%d] priority = Q0 → OK (no yield)\n", i + 1);
 250:	8b 45 f4             	mov    -0xc(%ebp),%eax
 253:	83 c0 01             	add    $0x1,%eax
 256:	83 ec 04             	sub    $0x4,%esp
 259:	50                   	push   %eax
 25a:	68 30 0b 00 00       	push   $0xb30
 25f:	6a 01                	push   $0x1
 261:	e8 7c 04 00 00       	call   6e2 <printf>
 266:	83 c4 10             	add    $0x10,%esp
 269:	eb 19                	jmp    284 <main+0x182>
      else
        printf(1, "[P%d] priority = Q%d → FAIL (should be Q0)\n", i + 1, prio);
 26b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26e:	83 c0 01             	add    $0x1,%eax
 271:	ff 75 e8             	pushl  -0x18(%ebp)
 274:	50                   	push   %eax
 275:	68 58 0b 00 00       	push   $0xb58
 27a:	6a 01                	push   $0x1
 27c:	e8 61 04 00 00       	call   6e2 <printf>
 281:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < N; i++) {
 284:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 288:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 28c:	0f 8e 25 ff ff ff    	jle    1b7 <main+0xb5>
    }
  }

  printf(1, "Confirm all tasks go down to Q0.\n");
 292:	83 ec 08             	sub    $0x8,%esp
 295:	68 88 0b 00 00       	push   $0xb88
 29a:	6a 01                	push   $0x1
 29c:	e8 41 04 00 00       	call   6e2 <printf>
 2a1:	83 c4 10             	add    $0x10,%esp
  printf(1, "Should have correct wait times as expected\n");
 2a4:	83 ec 08             	sub    $0x8,%esp
 2a7:	68 ac 0b 00 00       	push   $0xbac
 2ac:	6a 01                	push   $0x1
 2ae:	e8 2f 04 00 00       	call   6e2 <printf>
 2b3:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < N; i++) wait();
 2b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 2bd:	eb 09                	jmp    2c8 <main+0x1c6>
 2bf:	e8 92 02 00 00       	call   556 <wait>
 2c4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 2c8:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 2cc:	7e f1                	jle    2bf <main+0x1bd>
  exit();
 2ce:	e8 7b 02 00 00       	call   54e <exit>

000002d3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
 2d6:	57                   	push   %edi
 2d7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2db:	8b 55 10             	mov    0x10(%ebp),%edx
 2de:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e1:	89 cb                	mov    %ecx,%ebx
 2e3:	89 df                	mov    %ebx,%edi
 2e5:	89 d1                	mov    %edx,%ecx
 2e7:	fc                   	cld    
 2e8:	f3 aa                	rep stos %al,%es:(%edi)
 2ea:	89 ca                	mov    %ecx,%edx
 2ec:	89 fb                	mov    %edi,%ebx
 2ee:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2f1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2f4:	90                   	nop
 2f5:	5b                   	pop    %ebx
 2f6:	5f                   	pop    %edi
 2f7:	5d                   	pop    %ebp
 2f8:	c3                   	ret    

000002f9 <strcpy>:



char*
strcpy(char *s, char *t)
{
 2f9:	f3 0f 1e fb          	endbr32 
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 309:	90                   	nop
 30a:	8b 55 0c             	mov    0xc(%ebp),%edx
 30d:	8d 42 01             	lea    0x1(%edx),%eax
 310:	89 45 0c             	mov    %eax,0xc(%ebp)
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	8d 48 01             	lea    0x1(%eax),%ecx
 319:	89 4d 08             	mov    %ecx,0x8(%ebp)
 31c:	0f b6 12             	movzbl (%edx),%edx
 31f:	88 10                	mov    %dl,(%eax)
 321:	0f b6 00             	movzbl (%eax),%eax
 324:	84 c0                	test   %al,%al
 326:	75 e2                	jne    30a <strcpy+0x11>
    ;
  return os;
 328:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 32b:	c9                   	leave  
 32c:	c3                   	ret    

0000032d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 32d:	f3 0f 1e fb          	endbr32 
 331:	55                   	push   %ebp
 332:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 334:	eb 08                	jmp    33e <strcmp+0x11>
    p++, q++;
 336:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 33a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 33e:	8b 45 08             	mov    0x8(%ebp),%eax
 341:	0f b6 00             	movzbl (%eax),%eax
 344:	84 c0                	test   %al,%al
 346:	74 10                	je     358 <strcmp+0x2b>
 348:	8b 45 08             	mov    0x8(%ebp),%eax
 34b:	0f b6 10             	movzbl (%eax),%edx
 34e:	8b 45 0c             	mov    0xc(%ebp),%eax
 351:	0f b6 00             	movzbl (%eax),%eax
 354:	38 c2                	cmp    %al,%dl
 356:	74 de                	je     336 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 358:	8b 45 08             	mov    0x8(%ebp),%eax
 35b:	0f b6 00             	movzbl (%eax),%eax
 35e:	0f b6 d0             	movzbl %al,%edx
 361:	8b 45 0c             	mov    0xc(%ebp),%eax
 364:	0f b6 00             	movzbl (%eax),%eax
 367:	0f b6 c0             	movzbl %al,%eax
 36a:	29 c2                	sub    %eax,%edx
 36c:	89 d0                	mov    %edx,%eax
}
 36e:	5d                   	pop    %ebp
 36f:	c3                   	ret    

00000370 <strlen>:

uint
strlen(char *s)
{
 370:	f3 0f 1e fb          	endbr32 
 374:	55                   	push   %ebp
 375:	89 e5                	mov    %esp,%ebp
 377:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 37a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 381:	eb 04                	jmp    387 <strlen+0x17>
 383:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 387:	8b 55 fc             	mov    -0x4(%ebp),%edx
 38a:	8b 45 08             	mov    0x8(%ebp),%eax
 38d:	01 d0                	add    %edx,%eax
 38f:	0f b6 00             	movzbl (%eax),%eax
 392:	84 c0                	test   %al,%al
 394:	75 ed                	jne    383 <strlen+0x13>
    ;
  return n;
 396:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 399:	c9                   	leave  
 39a:	c3                   	ret    

0000039b <memset>:

void*
memset(void *dst, int c, uint n)
{
 39b:	f3 0f 1e fb          	endbr32 
 39f:	55                   	push   %ebp
 3a0:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3a2:	8b 45 10             	mov    0x10(%ebp),%eax
 3a5:	50                   	push   %eax
 3a6:	ff 75 0c             	pushl  0xc(%ebp)
 3a9:	ff 75 08             	pushl  0x8(%ebp)
 3ac:	e8 22 ff ff ff       	call   2d3 <stosb>
 3b1:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3b7:	c9                   	leave  
 3b8:	c3                   	ret    

000003b9 <strchr>:

char*
strchr(const char *s, char c)
{
 3b9:	f3 0f 1e fb          	endbr32 
 3bd:	55                   	push   %ebp
 3be:	89 e5                	mov    %esp,%ebp
 3c0:	83 ec 04             	sub    $0x4,%esp
 3c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c6:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3c9:	eb 14                	jmp    3df <strchr+0x26>
    if(*s == c)
 3cb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ce:	0f b6 00             	movzbl (%eax),%eax
 3d1:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3d4:	75 05                	jne    3db <strchr+0x22>
      return (char*)s;
 3d6:	8b 45 08             	mov    0x8(%ebp),%eax
 3d9:	eb 13                	jmp    3ee <strchr+0x35>
  for(; *s; s++)
 3db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	0f b6 00             	movzbl (%eax),%eax
 3e5:	84 c0                	test   %al,%al
 3e7:	75 e2                	jne    3cb <strchr+0x12>
  return 0;
 3e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3ee:	c9                   	leave  
 3ef:	c3                   	ret    

000003f0 <gets>:

char*
gets(char *buf, int max)
{
 3f0:	f3 0f 1e fb          	endbr32 
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
 3f7:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 401:	eb 42                	jmp    445 <gets+0x55>
    cc = read(0, &c, 1);
 403:	83 ec 04             	sub    $0x4,%esp
 406:	6a 01                	push   $0x1
 408:	8d 45 ef             	lea    -0x11(%ebp),%eax
 40b:	50                   	push   %eax
 40c:	6a 00                	push   $0x0
 40e:	e8 53 01 00 00       	call   566 <read>
 413:	83 c4 10             	add    $0x10,%esp
 416:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 419:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 41d:	7e 33                	jle    452 <gets+0x62>
      break;
    buf[i++] = c;
 41f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 422:	8d 50 01             	lea    0x1(%eax),%edx
 425:	89 55 f4             	mov    %edx,-0xc(%ebp)
 428:	89 c2                	mov    %eax,%edx
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	01 c2                	add    %eax,%edx
 42f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 433:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 435:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 439:	3c 0a                	cmp    $0xa,%al
 43b:	74 16                	je     453 <gets+0x63>
 43d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 441:	3c 0d                	cmp    $0xd,%al
 443:	74 0e                	je     453 <gets+0x63>
  for(i=0; i+1 < max; ){
 445:	8b 45 f4             	mov    -0xc(%ebp),%eax
 448:	83 c0 01             	add    $0x1,%eax
 44b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 44e:	7f b3                	jg     403 <gets+0x13>
 450:	eb 01                	jmp    453 <gets+0x63>
      break;
 452:	90                   	nop
      break;
  }
  buf[i] = '\0';
 453:	8b 55 f4             	mov    -0xc(%ebp),%edx
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	01 d0                	add    %edx,%eax
 45b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 461:	c9                   	leave  
 462:	c3                   	ret    

00000463 <stat>:

int
stat(char *n, struct stat *st)
{
 463:	f3 0f 1e fb          	endbr32 
 467:	55                   	push   %ebp
 468:	89 e5                	mov    %esp,%ebp
 46a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 46d:	83 ec 08             	sub    $0x8,%esp
 470:	6a 00                	push   $0x0
 472:	ff 75 08             	pushl  0x8(%ebp)
 475:	e8 14 01 00 00       	call   58e <open>
 47a:	83 c4 10             	add    $0x10,%esp
 47d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 480:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 484:	79 07                	jns    48d <stat+0x2a>
    return -1;
 486:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 48b:	eb 25                	jmp    4b2 <stat+0x4f>
  r = fstat(fd, st);
 48d:	83 ec 08             	sub    $0x8,%esp
 490:	ff 75 0c             	pushl  0xc(%ebp)
 493:	ff 75 f4             	pushl  -0xc(%ebp)
 496:	e8 0b 01 00 00       	call   5a6 <fstat>
 49b:	83 c4 10             	add    $0x10,%esp
 49e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4a1:	83 ec 0c             	sub    $0xc,%esp
 4a4:	ff 75 f4             	pushl  -0xc(%ebp)
 4a7:	e8 ca 00 00 00       	call   576 <close>
 4ac:	83 c4 10             	add    $0x10,%esp
  return r;
 4af:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4b2:	c9                   	leave  
 4b3:	c3                   	ret    

000004b4 <atoi>:

int
atoi(const char *s)
{
 4b4:	f3 0f 1e fb          	endbr32 
 4b8:	55                   	push   %ebp
 4b9:	89 e5                	mov    %esp,%ebp
 4bb:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4c5:	eb 25                	jmp    4ec <atoi+0x38>
    n = n*10 + *s++ - '0';
 4c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4ca:	89 d0                	mov    %edx,%eax
 4cc:	c1 e0 02             	shl    $0x2,%eax
 4cf:	01 d0                	add    %edx,%eax
 4d1:	01 c0                	add    %eax,%eax
 4d3:	89 c1                	mov    %eax,%ecx
 4d5:	8b 45 08             	mov    0x8(%ebp),%eax
 4d8:	8d 50 01             	lea    0x1(%eax),%edx
 4db:	89 55 08             	mov    %edx,0x8(%ebp)
 4de:	0f b6 00             	movzbl (%eax),%eax
 4e1:	0f be c0             	movsbl %al,%eax
 4e4:	01 c8                	add    %ecx,%eax
 4e6:	83 e8 30             	sub    $0x30,%eax
 4e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4ec:	8b 45 08             	mov    0x8(%ebp),%eax
 4ef:	0f b6 00             	movzbl (%eax),%eax
 4f2:	3c 2f                	cmp    $0x2f,%al
 4f4:	7e 0a                	jle    500 <atoi+0x4c>
 4f6:	8b 45 08             	mov    0x8(%ebp),%eax
 4f9:	0f b6 00             	movzbl (%eax),%eax
 4fc:	3c 39                	cmp    $0x39,%al
 4fe:	7e c7                	jle    4c7 <atoi+0x13>
  return n;
 500:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 503:	c9                   	leave  
 504:	c3                   	ret    

00000505 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 505:	f3 0f 1e fb          	endbr32 
 509:	55                   	push   %ebp
 50a:	89 e5                	mov    %esp,%ebp
 50c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
 512:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 515:	8b 45 0c             	mov    0xc(%ebp),%eax
 518:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 51b:	eb 17                	jmp    534 <memmove+0x2f>
    *dst++ = *src++;
 51d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 520:	8d 42 01             	lea    0x1(%edx),%eax
 523:	89 45 f8             	mov    %eax,-0x8(%ebp)
 526:	8b 45 fc             	mov    -0x4(%ebp),%eax
 529:	8d 48 01             	lea    0x1(%eax),%ecx
 52c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 52f:	0f b6 12             	movzbl (%edx),%edx
 532:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 534:	8b 45 10             	mov    0x10(%ebp),%eax
 537:	8d 50 ff             	lea    -0x1(%eax),%edx
 53a:	89 55 10             	mov    %edx,0x10(%ebp)
 53d:	85 c0                	test   %eax,%eax
 53f:	7f dc                	jg     51d <memmove+0x18>
  return vdst;
 541:	8b 45 08             	mov    0x8(%ebp),%eax
}
 544:	c9                   	leave  
 545:	c3                   	ret    

00000546 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 546:	b8 01 00 00 00       	mov    $0x1,%eax
 54b:	cd 40                	int    $0x40
 54d:	c3                   	ret    

0000054e <exit>:
SYSCALL(exit)
 54e:	b8 02 00 00 00       	mov    $0x2,%eax
 553:	cd 40                	int    $0x40
 555:	c3                   	ret    

00000556 <wait>:
SYSCALL(wait)
 556:	b8 03 00 00 00       	mov    $0x3,%eax
 55b:	cd 40                	int    $0x40
 55d:	c3                   	ret    

0000055e <pipe>:
SYSCALL(pipe)
 55e:	b8 04 00 00 00       	mov    $0x4,%eax
 563:	cd 40                	int    $0x40
 565:	c3                   	ret    

00000566 <read>:
SYSCALL(read)
 566:	b8 05 00 00 00       	mov    $0x5,%eax
 56b:	cd 40                	int    $0x40
 56d:	c3                   	ret    

0000056e <write>:
SYSCALL(write)
 56e:	b8 10 00 00 00       	mov    $0x10,%eax
 573:	cd 40                	int    $0x40
 575:	c3                   	ret    

00000576 <close>:
SYSCALL(close)
 576:	b8 15 00 00 00       	mov    $0x15,%eax
 57b:	cd 40                	int    $0x40
 57d:	c3                   	ret    

0000057e <kill>:
SYSCALL(kill)
 57e:	b8 06 00 00 00       	mov    $0x6,%eax
 583:	cd 40                	int    $0x40
 585:	c3                   	ret    

00000586 <exec>:
SYSCALL(exec)
 586:	b8 07 00 00 00       	mov    $0x7,%eax
 58b:	cd 40                	int    $0x40
 58d:	c3                   	ret    

0000058e <open>:
SYSCALL(open)
 58e:	b8 0f 00 00 00       	mov    $0xf,%eax
 593:	cd 40                	int    $0x40
 595:	c3                   	ret    

00000596 <mknod>:
SYSCALL(mknod)
 596:	b8 11 00 00 00       	mov    $0x11,%eax
 59b:	cd 40                	int    $0x40
 59d:	c3                   	ret    

0000059e <unlink>:
SYSCALL(unlink)
 59e:	b8 12 00 00 00       	mov    $0x12,%eax
 5a3:	cd 40                	int    $0x40
 5a5:	c3                   	ret    

000005a6 <fstat>:
SYSCALL(fstat)
 5a6:	b8 08 00 00 00       	mov    $0x8,%eax
 5ab:	cd 40                	int    $0x40
 5ad:	c3                   	ret    

000005ae <link>:
SYSCALL(link)
 5ae:	b8 13 00 00 00       	mov    $0x13,%eax
 5b3:	cd 40                	int    $0x40
 5b5:	c3                   	ret    

000005b6 <mkdir>:
SYSCALL(mkdir)
 5b6:	b8 14 00 00 00       	mov    $0x14,%eax
 5bb:	cd 40                	int    $0x40
 5bd:	c3                   	ret    

000005be <chdir>:
SYSCALL(chdir)
 5be:	b8 09 00 00 00       	mov    $0x9,%eax
 5c3:	cd 40                	int    $0x40
 5c5:	c3                   	ret    

000005c6 <dup>:
SYSCALL(dup)
 5c6:	b8 0a 00 00 00       	mov    $0xa,%eax
 5cb:	cd 40                	int    $0x40
 5cd:	c3                   	ret    

000005ce <getpid>:
SYSCALL(getpid)
 5ce:	b8 0b 00 00 00       	mov    $0xb,%eax
 5d3:	cd 40                	int    $0x40
 5d5:	c3                   	ret    

000005d6 <sbrk>:
SYSCALL(sbrk)
 5d6:	b8 0c 00 00 00       	mov    $0xc,%eax
 5db:	cd 40                	int    $0x40
 5dd:	c3                   	ret    

000005de <sleep>:
SYSCALL(sleep)
 5de:	b8 0d 00 00 00       	mov    $0xd,%eax
 5e3:	cd 40                	int    $0x40
 5e5:	c3                   	ret    

000005e6 <uptime>:
SYSCALL(uptime)
 5e6:	b8 0e 00 00 00       	mov    $0xe,%eax
 5eb:	cd 40                	int    $0x40
 5ed:	c3                   	ret    

000005ee <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 5ee:	b8 16 00 00 00       	mov    $0x16,%eax
 5f3:	cd 40                	int    $0x40
 5f5:	c3                   	ret    

000005f6 <getpinfo>:
SYSCALL(getpinfo)
 5f6:	b8 17 00 00 00       	mov    $0x17,%eax
 5fb:	cd 40                	int    $0x40
 5fd:	c3                   	ret    

000005fe <yield>:
SYSCALL(yield)
 5fe:	b8 18 00 00 00       	mov    $0x18,%eax
 603:	cd 40                	int    $0x40
 605:	c3                   	ret    

00000606 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 606:	f3 0f 1e fb          	endbr32 
 60a:	55                   	push   %ebp
 60b:	89 e5                	mov    %esp,%ebp
 60d:	83 ec 18             	sub    $0x18,%esp
 610:	8b 45 0c             	mov    0xc(%ebp),%eax
 613:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 616:	83 ec 04             	sub    $0x4,%esp
 619:	6a 01                	push   $0x1
 61b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 61e:	50                   	push   %eax
 61f:	ff 75 08             	pushl  0x8(%ebp)
 622:	e8 47 ff ff ff       	call   56e <write>
 627:	83 c4 10             	add    $0x10,%esp
}
 62a:	90                   	nop
 62b:	c9                   	leave  
 62c:	c3                   	ret    

0000062d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 62d:	f3 0f 1e fb          	endbr32 
 631:	55                   	push   %ebp
 632:	89 e5                	mov    %esp,%ebp
 634:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 637:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 63e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 642:	74 17                	je     65b <printint+0x2e>
 644:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 648:	79 11                	jns    65b <printint+0x2e>
    neg = 1;
 64a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 651:	8b 45 0c             	mov    0xc(%ebp),%eax
 654:	f7 d8                	neg    %eax
 656:	89 45 ec             	mov    %eax,-0x14(%ebp)
 659:	eb 06                	jmp    661 <printint+0x34>
  } else {
    x = xx;
 65b:	8b 45 0c             	mov    0xc(%ebp),%eax
 65e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 661:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 668:	8b 4d 10             	mov    0x10(%ebp),%ecx
 66b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 66e:	ba 00 00 00 00       	mov    $0x0,%edx
 673:	f7 f1                	div    %ecx
 675:	89 d1                	mov    %edx,%ecx
 677:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67a:	8d 50 01             	lea    0x1(%eax),%edx
 67d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 680:	0f b6 91 9c 0e 00 00 	movzbl 0xe9c(%ecx),%edx
 687:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 68b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 68e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 691:	ba 00 00 00 00       	mov    $0x0,%edx
 696:	f7 f1                	div    %ecx
 698:	89 45 ec             	mov    %eax,-0x14(%ebp)
 69b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 69f:	75 c7                	jne    668 <printint+0x3b>
  if(neg)
 6a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6a5:	74 2d                	je     6d4 <printint+0xa7>
    buf[i++] = '-';
 6a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6aa:	8d 50 01             	lea    0x1(%eax),%edx
 6ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6b0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6b5:	eb 1d                	jmp    6d4 <printint+0xa7>
    putc(fd, buf[i]);
 6b7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bd:	01 d0                	add    %edx,%eax
 6bf:	0f b6 00             	movzbl (%eax),%eax
 6c2:	0f be c0             	movsbl %al,%eax
 6c5:	83 ec 08             	sub    $0x8,%esp
 6c8:	50                   	push   %eax
 6c9:	ff 75 08             	pushl  0x8(%ebp)
 6cc:	e8 35 ff ff ff       	call   606 <putc>
 6d1:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6d4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6dc:	79 d9                	jns    6b7 <printint+0x8a>
}
 6de:	90                   	nop
 6df:	90                   	nop
 6e0:	c9                   	leave  
 6e1:	c3                   	ret    

000006e2 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6e2:	f3 0f 1e fb          	endbr32 
 6e6:	55                   	push   %ebp
 6e7:	89 e5                	mov    %esp,%ebp
 6e9:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6ec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6f3:	8d 45 0c             	lea    0xc(%ebp),%eax
 6f6:	83 c0 04             	add    $0x4,%eax
 6f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6fc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 703:	e9 59 01 00 00       	jmp    861 <printf+0x17f>
    c = fmt[i] & 0xff;
 708:	8b 55 0c             	mov    0xc(%ebp),%edx
 70b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 70e:	01 d0                	add    %edx,%eax
 710:	0f b6 00             	movzbl (%eax),%eax
 713:	0f be c0             	movsbl %al,%eax
 716:	25 ff 00 00 00       	and    $0xff,%eax
 71b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 71e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 722:	75 2c                	jne    750 <printf+0x6e>
      if(c == '%'){
 724:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 728:	75 0c                	jne    736 <printf+0x54>
        state = '%';
 72a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 731:	e9 27 01 00 00       	jmp    85d <printf+0x17b>
      } else {
        putc(fd, c);
 736:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 739:	0f be c0             	movsbl %al,%eax
 73c:	83 ec 08             	sub    $0x8,%esp
 73f:	50                   	push   %eax
 740:	ff 75 08             	pushl  0x8(%ebp)
 743:	e8 be fe ff ff       	call   606 <putc>
 748:	83 c4 10             	add    $0x10,%esp
 74b:	e9 0d 01 00 00       	jmp    85d <printf+0x17b>
      }
    } else if(state == '%'){
 750:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 754:	0f 85 03 01 00 00    	jne    85d <printf+0x17b>
      if(c == 'd'){
 75a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 75e:	75 1e                	jne    77e <printf+0x9c>
        printint(fd, *ap, 10, 1);
 760:	8b 45 e8             	mov    -0x18(%ebp),%eax
 763:	8b 00                	mov    (%eax),%eax
 765:	6a 01                	push   $0x1
 767:	6a 0a                	push   $0xa
 769:	50                   	push   %eax
 76a:	ff 75 08             	pushl  0x8(%ebp)
 76d:	e8 bb fe ff ff       	call   62d <printint>
 772:	83 c4 10             	add    $0x10,%esp
        ap++;
 775:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 779:	e9 d8 00 00 00       	jmp    856 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 77e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 782:	74 06                	je     78a <printf+0xa8>
 784:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 788:	75 1e                	jne    7a8 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 78a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78d:	8b 00                	mov    (%eax),%eax
 78f:	6a 00                	push   $0x0
 791:	6a 10                	push   $0x10
 793:	50                   	push   %eax
 794:	ff 75 08             	pushl  0x8(%ebp)
 797:	e8 91 fe ff ff       	call   62d <printint>
 79c:	83 c4 10             	add    $0x10,%esp
        ap++;
 79f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a3:	e9 ae 00 00 00       	jmp    856 <printf+0x174>
      } else if(c == 's'){
 7a8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7ac:	75 43                	jne    7f1 <printf+0x10f>
        s = (char*)*ap;
 7ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b1:	8b 00                	mov    (%eax),%eax
 7b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7be:	75 25                	jne    7e5 <printf+0x103>
          s = "(null)";
 7c0:	c7 45 f4 d8 0b 00 00 	movl   $0xbd8,-0xc(%ebp)
        while(*s != 0){
 7c7:	eb 1c                	jmp    7e5 <printf+0x103>
          putc(fd, *s);
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	0f b6 00             	movzbl (%eax),%eax
 7cf:	0f be c0             	movsbl %al,%eax
 7d2:	83 ec 08             	sub    $0x8,%esp
 7d5:	50                   	push   %eax
 7d6:	ff 75 08             	pushl  0x8(%ebp)
 7d9:	e8 28 fe ff ff       	call   606 <putc>
 7de:	83 c4 10             	add    $0x10,%esp
          s++;
 7e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	0f b6 00             	movzbl (%eax),%eax
 7eb:	84 c0                	test   %al,%al
 7ed:	75 da                	jne    7c9 <printf+0xe7>
 7ef:	eb 65                	jmp    856 <printf+0x174>
        }
      } else if(c == 'c'){
 7f1:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7f5:	75 1d                	jne    814 <printf+0x132>
        putc(fd, *ap);
 7f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fa:	8b 00                	mov    (%eax),%eax
 7fc:	0f be c0             	movsbl %al,%eax
 7ff:	83 ec 08             	sub    $0x8,%esp
 802:	50                   	push   %eax
 803:	ff 75 08             	pushl  0x8(%ebp)
 806:	e8 fb fd ff ff       	call   606 <putc>
 80b:	83 c4 10             	add    $0x10,%esp
        ap++;
 80e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 812:	eb 42                	jmp    856 <printf+0x174>
      } else if(c == '%'){
 814:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 818:	75 17                	jne    831 <printf+0x14f>
        putc(fd, c);
 81a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 81d:	0f be c0             	movsbl %al,%eax
 820:	83 ec 08             	sub    $0x8,%esp
 823:	50                   	push   %eax
 824:	ff 75 08             	pushl  0x8(%ebp)
 827:	e8 da fd ff ff       	call   606 <putc>
 82c:	83 c4 10             	add    $0x10,%esp
 82f:	eb 25                	jmp    856 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 831:	83 ec 08             	sub    $0x8,%esp
 834:	6a 25                	push   $0x25
 836:	ff 75 08             	pushl  0x8(%ebp)
 839:	e8 c8 fd ff ff       	call   606 <putc>
 83e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 844:	0f be c0             	movsbl %al,%eax
 847:	83 ec 08             	sub    $0x8,%esp
 84a:	50                   	push   %eax
 84b:	ff 75 08             	pushl  0x8(%ebp)
 84e:	e8 b3 fd ff ff       	call   606 <putc>
 853:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 856:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 85d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 861:	8b 55 0c             	mov    0xc(%ebp),%edx
 864:	8b 45 f0             	mov    -0x10(%ebp),%eax
 867:	01 d0                	add    %edx,%eax
 869:	0f b6 00             	movzbl (%eax),%eax
 86c:	84 c0                	test   %al,%al
 86e:	0f 85 94 fe ff ff    	jne    708 <printf+0x26>
    }
  }
}
 874:	90                   	nop
 875:	90                   	nop
 876:	c9                   	leave  
 877:	c3                   	ret    

00000878 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 878:	f3 0f 1e fb          	endbr32 
 87c:	55                   	push   %ebp
 87d:	89 e5                	mov    %esp,%ebp
 87f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 882:	8b 45 08             	mov    0x8(%ebp),%eax
 885:	83 e8 08             	sub    $0x8,%eax
 888:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88b:	a1 b8 0e 00 00       	mov    0xeb8,%eax
 890:	89 45 fc             	mov    %eax,-0x4(%ebp)
 893:	eb 24                	jmp    8b9 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 895:	8b 45 fc             	mov    -0x4(%ebp),%eax
 898:	8b 00                	mov    (%eax),%eax
 89a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 89d:	72 12                	jb     8b1 <free+0x39>
 89f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a5:	77 24                	ja     8cb <free+0x53>
 8a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8aa:	8b 00                	mov    (%eax),%eax
 8ac:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8af:	72 1a                	jb     8cb <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b4:	8b 00                	mov    (%eax),%eax
 8b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8bf:	76 d4                	jbe    895 <free+0x1d>
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8c9:	73 ca                	jae    895 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ce:	8b 40 04             	mov    0x4(%eax),%eax
 8d1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8db:	01 c2                	add    %eax,%edx
 8dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e0:	8b 00                	mov    (%eax),%eax
 8e2:	39 c2                	cmp    %eax,%edx
 8e4:	75 24                	jne    90a <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 8e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e9:	8b 50 04             	mov    0x4(%eax),%edx
 8ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ef:	8b 00                	mov    (%eax),%eax
 8f1:	8b 40 04             	mov    0x4(%eax),%eax
 8f4:	01 c2                	add    %eax,%edx
 8f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ff:	8b 00                	mov    (%eax),%eax
 901:	8b 10                	mov    (%eax),%edx
 903:	8b 45 f8             	mov    -0x8(%ebp),%eax
 906:	89 10                	mov    %edx,(%eax)
 908:	eb 0a                	jmp    914 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 90a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90d:	8b 10                	mov    (%eax),%edx
 90f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 912:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 914:	8b 45 fc             	mov    -0x4(%ebp),%eax
 917:	8b 40 04             	mov    0x4(%eax),%eax
 91a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 921:	8b 45 fc             	mov    -0x4(%ebp),%eax
 924:	01 d0                	add    %edx,%eax
 926:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 929:	75 20                	jne    94b <free+0xd3>
    p->s.size += bp->s.size;
 92b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92e:	8b 50 04             	mov    0x4(%eax),%edx
 931:	8b 45 f8             	mov    -0x8(%ebp),%eax
 934:	8b 40 04             	mov    0x4(%eax),%eax
 937:	01 c2                	add    %eax,%edx
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 93f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 942:	8b 10                	mov    (%eax),%edx
 944:	8b 45 fc             	mov    -0x4(%ebp),%eax
 947:	89 10                	mov    %edx,(%eax)
 949:	eb 08                	jmp    953 <free+0xdb>
  } else
    p->s.ptr = bp;
 94b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 951:	89 10                	mov    %edx,(%eax)
  freep = p;
 953:	8b 45 fc             	mov    -0x4(%ebp),%eax
 956:	a3 b8 0e 00 00       	mov    %eax,0xeb8
}
 95b:	90                   	nop
 95c:	c9                   	leave  
 95d:	c3                   	ret    

0000095e <morecore>:

static Header*
morecore(uint nu)
{
 95e:	f3 0f 1e fb          	endbr32 
 962:	55                   	push   %ebp
 963:	89 e5                	mov    %esp,%ebp
 965:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 968:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 96f:	77 07                	ja     978 <morecore+0x1a>
    nu = 4096;
 971:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 978:	8b 45 08             	mov    0x8(%ebp),%eax
 97b:	c1 e0 03             	shl    $0x3,%eax
 97e:	83 ec 0c             	sub    $0xc,%esp
 981:	50                   	push   %eax
 982:	e8 4f fc ff ff       	call   5d6 <sbrk>
 987:	83 c4 10             	add    $0x10,%esp
 98a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 98d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 991:	75 07                	jne    99a <morecore+0x3c>
    return 0;
 993:	b8 00 00 00 00       	mov    $0x0,%eax
 998:	eb 26                	jmp    9c0 <morecore+0x62>
  hp = (Header*)p;
 99a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a3:	8b 55 08             	mov    0x8(%ebp),%edx
 9a6:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ac:	83 c0 08             	add    $0x8,%eax
 9af:	83 ec 0c             	sub    $0xc,%esp
 9b2:	50                   	push   %eax
 9b3:	e8 c0 fe ff ff       	call   878 <free>
 9b8:	83 c4 10             	add    $0x10,%esp
  return freep;
 9bb:	a1 b8 0e 00 00       	mov    0xeb8,%eax
}
 9c0:	c9                   	leave  
 9c1:	c3                   	ret    

000009c2 <malloc>:

void*
malloc(uint nbytes)
{
 9c2:	f3 0f 1e fb          	endbr32 
 9c6:	55                   	push   %ebp
 9c7:	89 e5                	mov    %esp,%ebp
 9c9:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9cc:	8b 45 08             	mov    0x8(%ebp),%eax
 9cf:	83 c0 07             	add    $0x7,%eax
 9d2:	c1 e8 03             	shr    $0x3,%eax
 9d5:	83 c0 01             	add    $0x1,%eax
 9d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9db:	a1 b8 0e 00 00       	mov    0xeb8,%eax
 9e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9e7:	75 23                	jne    a0c <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 9e9:	c7 45 f0 b0 0e 00 00 	movl   $0xeb0,-0x10(%ebp)
 9f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f3:	a3 b8 0e 00 00       	mov    %eax,0xeb8
 9f8:	a1 b8 0e 00 00       	mov    0xeb8,%eax
 9fd:	a3 b0 0e 00 00       	mov    %eax,0xeb0
    base.s.size = 0;
 a02:	c7 05 b4 0e 00 00 00 	movl   $0x0,0xeb4
 a09:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0f:	8b 00                	mov    (%eax),%eax
 a11:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a17:	8b 40 04             	mov    0x4(%eax),%eax
 a1a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a1d:	77 4d                	ja     a6c <malloc+0xaa>
      if(p->s.size == nunits)
 a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a22:	8b 40 04             	mov    0x4(%eax),%eax
 a25:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a28:	75 0c                	jne    a36 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2d:	8b 10                	mov    (%eax),%edx
 a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a32:	89 10                	mov    %edx,(%eax)
 a34:	eb 26                	jmp    a5c <malloc+0x9a>
      else {
        p->s.size -= nunits;
 a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a39:	8b 40 04             	mov    0x4(%eax),%eax
 a3c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a3f:	89 c2                	mov    %eax,%edx
 a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a44:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4a:	8b 40 04             	mov    0x4(%eax),%eax
 a4d:	c1 e0 03             	shl    $0x3,%eax
 a50:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a56:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a59:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5f:	a3 b8 0e 00 00       	mov    %eax,0xeb8
      return (void*)(p + 1);
 a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a67:	83 c0 08             	add    $0x8,%eax
 a6a:	eb 3b                	jmp    aa7 <malloc+0xe5>
    }
    if(p == freep)
 a6c:	a1 b8 0e 00 00       	mov    0xeb8,%eax
 a71:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a74:	75 1e                	jne    a94 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a76:	83 ec 0c             	sub    $0xc,%esp
 a79:	ff 75 ec             	pushl  -0x14(%ebp)
 a7c:	e8 dd fe ff ff       	call   95e <morecore>
 a81:	83 c4 10             	add    $0x10,%esp
 a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a8b:	75 07                	jne    a94 <malloc+0xd2>
        return 0;
 a8d:	b8 00 00 00 00       	mov    $0x0,%eax
 a92:	eb 13                	jmp    aa7 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a97:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9d:	8b 00                	mov    (%eax),%eax
 a9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 aa2:	e9 6d ff ff ff       	jmp    a14 <malloc+0x52>
  }
}
 aa7:	c9                   	leave  
 aa8:	c3                   	ret    
