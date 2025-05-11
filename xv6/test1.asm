
_test1:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:

#define TICKS1 40000000     // Process 1 - Q3 → Q2 → Q3
#define TICKS2 80000000     // Process 2 - Q3 → Q2 → Q1 → Q2 → Q3
#define TICKS3 160000000    // Process 3 - Q3 → Q2 → Q1 → Q0 → Q1 → Q2 → Q3

void workload(int ticks) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < ticks; i++) {
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 10                	jmp    26 <workload+0x26>
    j = j * j + 1;
  16:	8b 45 f8             	mov    -0x8(%ebp),%eax
  19:	0f af c0             	imul   %eax,%eax
  1c:	83 c0 01             	add    $0x1,%eax
  1f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for (i = 0; i < ticks; i++) {
  22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  26:	8b 45 fc             	mov    -0x4(%ebp),%eax
  29:	3b 45 08             	cmp    0x8(%ebp),%eax
  2c:	7c e8                	jl     16 <workload+0x16>
  }
}
  2e:	90                   	nop
  2f:	90                   	nop
  30:	c9                   	leave  
  31:	c3                   	ret    

00000032 <print_info>:

void print_info(struct pstat *st, int pid, int snapshot) {
  32:	55                   	push   %ebp
  33:	89 e5                	mov    %esp,%ebp
  35:	53                   	push   %ebx
  36:	83 ec 14             	sub    $0x14,%esp
  for (int i = 0; i < NPROC; i++) {
  39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  40:	e9 b1 00 00 00       	jmp    f6 <print_info+0xc4>
    if (st->inuse[i] && st->pid[i] == pid) {
  45:	8b 45 08             	mov    0x8(%ebp),%eax
  48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  4b:	8b 04 90             	mov    (%eax,%edx,4),%eax
  4e:	85 c0                	test   %eax,%eax
  50:	0f 84 9c 00 00 00    	je     f2 <print_info+0xc0>
  56:	8b 45 08             	mov    0x8(%ebp),%eax
  59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  5c:	83 c2 40             	add    $0x40,%edx
  5f:	8b 04 90             	mov    (%eax,%edx,4),%eax
  62:	39 45 0c             	cmp    %eax,0xc(%ebp)
  65:	0f 85 87 00 00 00    	jne    f2 <print_info+0xc0>
      printf(1, "\n[snapshot %d] pid %d, priority: %d\n", snapshot, pid, st->priority[i]);
  6b:	8b 45 08             	mov    0x8(%ebp),%eax
  6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  71:	83 ea 80             	sub    $0xffffff80,%edx
  74:	8b 04 90             	mov    (%eax,%edx,4),%eax
  77:	83 ec 0c             	sub    $0xc,%esp
  7a:	50                   	push   %eax
  7b:	ff 75 0c             	push   0xc(%ebp)
  7e:	ff 75 10             	push   0x10(%ebp)
  81:	68 d4 09 00 00       	push   $0x9d4
  86:	6a 01                	push   $0x1
  88:	e8 8e 05 00 00       	call   61b <printf>
  8d:	83 c4 20             	add    $0x20,%esp
      for (int q = 3; q >= 0; q--) {
  90:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
  97:	eb 51                	jmp    ea <print_info+0xb8>
        printf(1, " Q%d → ticks: %d, wait_ticks: %d\n",
  99:	8b 45 08             	mov    0x8(%ebp),%eax
  9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  9f:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  a9:	01 ca                	add    %ecx,%edx
  ab:	81 c2 00 02 00 00    	add    $0x200,%edx
  b1:	8b 14 90             	mov    (%eax,%edx,4),%edx
  b4:	8b 45 08             	mov    0x8(%ebp),%eax
  b7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  ba:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
  c1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  c4:	01 d9                	add    %ebx,%ecx
  c6:	81 c1 00 01 00 00    	add    $0x100,%ecx
  cc:	8b 04 88             	mov    (%eax,%ecx,4),%eax
  cf:	83 ec 0c             	sub    $0xc,%esp
  d2:	52                   	push   %edx
  d3:	50                   	push   %eax
  d4:	ff 75 f0             	push   -0x10(%ebp)
  d7:	68 fc 09 00 00       	push   $0x9fc
  dc:	6a 01                	push   $0x1
  de:	e8 38 05 00 00       	call   61b <printf>
  e3:	83 c4 20             	add    $0x20,%esp
      for (int q = 3; q >= 0; q--) {
  e6:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  ee:	79 a9                	jns    99 <print_info+0x67>
               q, st->ticks[i][q], st->wait_ticks[i][q]);
      }
      break;
  f0:	eb 0f                	jmp    101 <print_info+0xcf>
  for (int i = 0; i < NPROC; i++) {
  f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  f6:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
  fa:	0f 8e 45 ff ff ff    	jle    45 <print_info+0x13>
    }
  }
}
 100:	90                   	nop
 101:	90                   	nop
 102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 105:	c9                   	leave  
 106:	c3                   	ret    

00000107 <main>:

int main(int argc, char *argv[]) {
 107:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 10b:	83 e4 f0             	and    $0xfffffff0,%esp
 10e:	ff 71 fc             	push   -0x4(%ecx)
 111:	55                   	push   %ebp
 112:	89 e5                	mov    %esp,%ebp
 114:	51                   	push   %ecx
 115:	81 ec 14 0c 00 00    	sub    $0xc14,%esp
  struct pstat st;
  int pid1, pid2, pid3;

  setSchedPolicy(1);
 11b:	83 ec 0c             	sub    $0xc,%esp
 11e:	6a 01                	push   $0x1
 120:	e8 0a 04 00 00       	call   52f <setSchedPolicy>
 125:	83 c4 10             	add    $0x10,%esp

  pid1 = fork();
 128:	e8 5a 03 00 00       	call   487 <fork>
 12d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (pid1 == 0) {
 130:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 134:	75 15                	jne    14b <main+0x44>
    workload(TICKS1);
 136:	83 ec 0c             	sub    $0xc,%esp
 139:	68 00 5a 62 02       	push   $0x2625a00
 13e:	e8 bd fe ff ff       	call   0 <workload>
 143:	83 c4 10             	add    $0x10,%esp
    exit();
 146:	e8 44 03 00 00       	call   48f <exit>
  }

  pid2 = fork();
 14b:	e8 37 03 00 00       	call   487 <fork>
 150:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (pid2 == 0) {
 153:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 157:	75 15                	jne    16e <main+0x67>
    workload(TICKS2);
 159:	83 ec 0c             	sub    $0xc,%esp
 15c:	68 00 b4 c4 04       	push   $0x4c4b400
 161:	e8 9a fe ff ff       	call   0 <workload>
 166:	83 c4 10             	add    $0x10,%esp
    exit();
 169:	e8 21 03 00 00       	call   48f <exit>
  }

  pid3 = fork();
 16e:	e8 14 03 00 00       	call   487 <fork>
 173:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if (pid3 == 0) {
 176:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 17a:	75 15                	jne    191 <main+0x8a>
    workload(TICKS3);
 17c:	83 ec 0c             	sub    $0xc,%esp
 17f:	68 00 68 89 09       	push   $0x9896800
 184:	e8 77 fe ff ff       	call   0 <workload>
 189:	83 c4 10             	add    $0x10,%esp
    exit();
 18c:	e8 fe 02 00 00       	call   48f <exit>
  }

  // 💡 자식들이 충분히 실행되도록 시간 확보 + 스냅샷 출력 반복
  for (int i = 0; i < 8; i++) {
 191:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 198:	eb 72                	jmp    20c <main+0x105>
    sleep(500); // 충분히 trap 발생할 시간 확보
 19a:	83 ec 0c             	sub    $0xc,%esp
 19d:	68 f4 01 00 00       	push   $0x1f4
 1a2:	e8 78 03 00 00       	call   51f <sleep>
 1a7:	83 c4 10             	add    $0x10,%esp
    if (getpinfo(&st) == 0) {
 1aa:	83 ec 0c             	sub    $0xc,%esp
 1ad:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 1b3:	50                   	push   %eax
 1b4:	e8 7e 03 00 00       	call   537 <getpinfo>
 1b9:	83 c4 10             	add    $0x10,%esp
 1bc:	85 c0                	test   %eax,%eax
 1be:	75 48                	jne    208 <main+0x101>
      print_info(&st, pid1, i);
 1c0:	83 ec 04             	sub    $0x4,%esp
 1c3:	ff 75 f4             	push   -0xc(%ebp)
 1c6:	ff 75 f0             	push   -0x10(%ebp)
 1c9:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 1cf:	50                   	push   %eax
 1d0:	e8 5d fe ff ff       	call   32 <print_info>
 1d5:	83 c4 10             	add    $0x10,%esp
      print_info(&st, pid2, i);
 1d8:	83 ec 04             	sub    $0x4,%esp
 1db:	ff 75 f4             	push   -0xc(%ebp)
 1de:	ff 75 ec             	push   -0x14(%ebp)
 1e1:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 1e7:	50                   	push   %eax
 1e8:	e8 45 fe ff ff       	call   32 <print_info>
 1ed:	83 c4 10             	add    $0x10,%esp
      print_info(&st, pid3, i);
 1f0:	83 ec 04             	sub    $0x4,%esp
 1f3:	ff 75 f4             	push   -0xc(%ebp)
 1f6:	ff 75 e8             	push   -0x18(%ebp)
 1f9:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 1ff:	50                   	push   %eax
 200:	e8 2d fe ff ff       	call   32 <print_info>
 205:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 8; i++) {
 208:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 20c:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
 210:	7e 88                	jle    19a <main+0x93>
    }
  }

  // 자식 종료 대기
  wait();
 212:	e8 80 02 00 00       	call   497 <wait>
  wait();
 217:	e8 7b 02 00 00       	call   497 <wait>
  wait();
 21c:	e8 76 02 00 00       	call   497 <wait>

  printf(1, "\n[parent] done. exiting...\n");
 221:	83 ec 08             	sub    $0x8,%esp
 224:	68 20 0a 00 00       	push   $0xa20
 229:	6a 01                	push   $0x1
 22b:	e8 eb 03 00 00       	call   61b <printf>
 230:	83 c4 10             	add    $0x10,%esp
  exit();
 233:	e8 57 02 00 00       	call   48f <exit>

00000238 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 238:	55                   	push   %ebp
 239:	89 e5                	mov    %esp,%ebp
 23b:	57                   	push   %edi
 23c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 23d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 240:	8b 55 10             	mov    0x10(%ebp),%edx
 243:	8b 45 0c             	mov    0xc(%ebp),%eax
 246:	89 cb                	mov    %ecx,%ebx
 248:	89 df                	mov    %ebx,%edi
 24a:	89 d1                	mov    %edx,%ecx
 24c:	fc                   	cld    
 24d:	f3 aa                	rep stos %al,%es:(%edi)
 24f:	89 ca                	mov    %ecx,%edx
 251:	89 fb                	mov    %edi,%ebx
 253:	89 5d 08             	mov    %ebx,0x8(%ebp)
 256:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 259:	90                   	nop
 25a:	5b                   	pop    %ebx
 25b:	5f                   	pop    %edi
 25c:	5d                   	pop    %ebp
 25d:	c3                   	ret    

0000025e <strcpy>:



char*
strcpy(char *s, char *t)
{
 25e:	55                   	push   %ebp
 25f:	89 e5                	mov    %esp,%ebp
 261:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 264:	8b 45 08             	mov    0x8(%ebp),%eax
 267:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 26a:	90                   	nop
 26b:	8b 55 0c             	mov    0xc(%ebp),%edx
 26e:	8d 42 01             	lea    0x1(%edx),%eax
 271:	89 45 0c             	mov    %eax,0xc(%ebp)
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	8d 48 01             	lea    0x1(%eax),%ecx
 27a:	89 4d 08             	mov    %ecx,0x8(%ebp)
 27d:	0f b6 12             	movzbl (%edx),%edx
 280:	88 10                	mov    %dl,(%eax)
 282:	0f b6 00             	movzbl (%eax),%eax
 285:	84 c0                	test   %al,%al
 287:	75 e2                	jne    26b <strcpy+0xd>
    ;
  return os;
 289:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 28c:	c9                   	leave  
 28d:	c3                   	ret    

0000028e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 291:	eb 08                	jmp    29b <strcmp+0xd>
    p++, q++;
 293:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 297:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	0f b6 00             	movzbl (%eax),%eax
 2a1:	84 c0                	test   %al,%al
 2a3:	74 10                	je     2b5 <strcmp+0x27>
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	0f b6 10             	movzbl (%eax),%edx
 2ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ae:	0f b6 00             	movzbl (%eax),%eax
 2b1:	38 c2                	cmp    %al,%dl
 2b3:	74 de                	je     293 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	0f b6 d0             	movzbl %al,%edx
 2be:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c1:	0f b6 00             	movzbl (%eax),%eax
 2c4:	0f b6 c8             	movzbl %al,%ecx
 2c7:	89 d0                	mov    %edx,%eax
 2c9:	29 c8                	sub    %ecx,%eax
}
 2cb:	5d                   	pop    %ebp
 2cc:	c3                   	ret    

000002cd <strlen>:

uint
strlen(char *s)
{
 2cd:	55                   	push   %ebp
 2ce:	89 e5                	mov    %esp,%ebp
 2d0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2d3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2da:	eb 04                	jmp    2e0 <strlen+0x13>
 2dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	01 d0                	add    %edx,%eax
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	84 c0                	test   %al,%al
 2ed:	75 ed                	jne    2dc <strlen+0xf>
    ;
  return n;
 2ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2f2:	c9                   	leave  
 2f3:	c3                   	ret    

000002f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2f4:	55                   	push   %ebp
 2f5:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 2f7:	8b 45 10             	mov    0x10(%ebp),%eax
 2fa:	50                   	push   %eax
 2fb:	ff 75 0c             	push   0xc(%ebp)
 2fe:	ff 75 08             	push   0x8(%ebp)
 301:	e8 32 ff ff ff       	call   238 <stosb>
 306:	83 c4 0c             	add    $0xc,%esp
  return dst;
 309:	8b 45 08             	mov    0x8(%ebp),%eax
}
 30c:	c9                   	leave  
 30d:	c3                   	ret    

0000030e <strchr>:

char*
strchr(const char *s, char c)
{
 30e:	55                   	push   %ebp
 30f:	89 e5                	mov    %esp,%ebp
 311:	83 ec 04             	sub    $0x4,%esp
 314:	8b 45 0c             	mov    0xc(%ebp),%eax
 317:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 31a:	eb 14                	jmp    330 <strchr+0x22>
    if(*s == c)
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	0f b6 00             	movzbl (%eax),%eax
 322:	38 45 fc             	cmp    %al,-0x4(%ebp)
 325:	75 05                	jne    32c <strchr+0x1e>
      return (char*)s;
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	eb 13                	jmp    33f <strchr+0x31>
  for(; *s; s++)
 32c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	0f b6 00             	movzbl (%eax),%eax
 336:	84 c0                	test   %al,%al
 338:	75 e2                	jne    31c <strchr+0xe>
  return 0;
 33a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 33f:	c9                   	leave  
 340:	c3                   	ret    

00000341 <gets>:

char*
gets(char *buf, int max)
{
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
 344:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 347:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 34e:	eb 42                	jmp    392 <gets+0x51>
    cc = read(0, &c, 1);
 350:	83 ec 04             	sub    $0x4,%esp
 353:	6a 01                	push   $0x1
 355:	8d 45 ef             	lea    -0x11(%ebp),%eax
 358:	50                   	push   %eax
 359:	6a 00                	push   $0x0
 35b:	e8 47 01 00 00       	call   4a7 <read>
 360:	83 c4 10             	add    $0x10,%esp
 363:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 36a:	7e 33                	jle    39f <gets+0x5e>
      break;
    buf[i++] = c;
 36c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 36f:	8d 50 01             	lea    0x1(%eax),%edx
 372:	89 55 f4             	mov    %edx,-0xc(%ebp)
 375:	89 c2                	mov    %eax,%edx
 377:	8b 45 08             	mov    0x8(%ebp),%eax
 37a:	01 c2                	add    %eax,%edx
 37c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 380:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 382:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 386:	3c 0a                	cmp    $0xa,%al
 388:	74 16                	je     3a0 <gets+0x5f>
 38a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 38e:	3c 0d                	cmp    $0xd,%al
 390:	74 0e                	je     3a0 <gets+0x5f>
  for(i=0; i+1 < max; ){
 392:	8b 45 f4             	mov    -0xc(%ebp),%eax
 395:	83 c0 01             	add    $0x1,%eax
 398:	39 45 0c             	cmp    %eax,0xc(%ebp)
 39b:	7f b3                	jg     350 <gets+0xf>
 39d:	eb 01                	jmp    3a0 <gets+0x5f>
      break;
 39f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3a3:	8b 45 08             	mov    0x8(%ebp),%eax
 3a6:	01 d0                	add    %edx,%eax
 3a8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3ae:	c9                   	leave  
 3af:	c3                   	ret    

000003b0 <stat>:

int
stat(char *n, struct stat *st)
{
 3b0:	55                   	push   %ebp
 3b1:	89 e5                	mov    %esp,%ebp
 3b3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b6:	83 ec 08             	sub    $0x8,%esp
 3b9:	6a 00                	push   $0x0
 3bb:	ff 75 08             	push   0x8(%ebp)
 3be:	e8 0c 01 00 00       	call   4cf <open>
 3c3:	83 c4 10             	add    $0x10,%esp
 3c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3cd:	79 07                	jns    3d6 <stat+0x26>
    return -1;
 3cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3d4:	eb 25                	jmp    3fb <stat+0x4b>
  r = fstat(fd, st);
 3d6:	83 ec 08             	sub    $0x8,%esp
 3d9:	ff 75 0c             	push   0xc(%ebp)
 3dc:	ff 75 f4             	push   -0xc(%ebp)
 3df:	e8 03 01 00 00       	call   4e7 <fstat>
 3e4:	83 c4 10             	add    $0x10,%esp
 3e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3ea:	83 ec 0c             	sub    $0xc,%esp
 3ed:	ff 75 f4             	push   -0xc(%ebp)
 3f0:	e8 c2 00 00 00       	call   4b7 <close>
 3f5:	83 c4 10             	add    $0x10,%esp
  return r;
 3f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3fb:	c9                   	leave  
 3fc:	c3                   	ret    

000003fd <atoi>:

int
atoi(const char *s)
{
 3fd:	55                   	push   %ebp
 3fe:	89 e5                	mov    %esp,%ebp
 400:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 403:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 40a:	eb 25                	jmp    431 <atoi+0x34>
    n = n*10 + *s++ - '0';
 40c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 40f:	89 d0                	mov    %edx,%eax
 411:	c1 e0 02             	shl    $0x2,%eax
 414:	01 d0                	add    %edx,%eax
 416:	01 c0                	add    %eax,%eax
 418:	89 c1                	mov    %eax,%ecx
 41a:	8b 45 08             	mov    0x8(%ebp),%eax
 41d:	8d 50 01             	lea    0x1(%eax),%edx
 420:	89 55 08             	mov    %edx,0x8(%ebp)
 423:	0f b6 00             	movzbl (%eax),%eax
 426:	0f be c0             	movsbl %al,%eax
 429:	01 c8                	add    %ecx,%eax
 42b:	83 e8 30             	sub    $0x30,%eax
 42e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	0f b6 00             	movzbl (%eax),%eax
 437:	3c 2f                	cmp    $0x2f,%al
 439:	7e 0a                	jle    445 <atoi+0x48>
 43b:	8b 45 08             	mov    0x8(%ebp),%eax
 43e:	0f b6 00             	movzbl (%eax),%eax
 441:	3c 39                	cmp    $0x39,%al
 443:	7e c7                	jle    40c <atoi+0xf>
  return n;
 445:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 448:	c9                   	leave  
 449:	c3                   	ret    

0000044a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 44a:	55                   	push   %ebp
 44b:	89 e5                	mov    %esp,%ebp
 44d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 456:	8b 45 0c             	mov    0xc(%ebp),%eax
 459:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 45c:	eb 17                	jmp    475 <memmove+0x2b>
    *dst++ = *src++;
 45e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 461:	8d 42 01             	lea    0x1(%edx),%eax
 464:	89 45 f8             	mov    %eax,-0x8(%ebp)
 467:	8b 45 fc             	mov    -0x4(%ebp),%eax
 46a:	8d 48 01             	lea    0x1(%eax),%ecx
 46d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 470:	0f b6 12             	movzbl (%edx),%edx
 473:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 475:	8b 45 10             	mov    0x10(%ebp),%eax
 478:	8d 50 ff             	lea    -0x1(%eax),%edx
 47b:	89 55 10             	mov    %edx,0x10(%ebp)
 47e:	85 c0                	test   %eax,%eax
 480:	7f dc                	jg     45e <memmove+0x14>
  return vdst;
 482:	8b 45 08             	mov    0x8(%ebp),%eax
}
 485:	c9                   	leave  
 486:	c3                   	ret    

00000487 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 487:	b8 01 00 00 00       	mov    $0x1,%eax
 48c:	cd 40                	int    $0x40
 48e:	c3                   	ret    

0000048f <exit>:
SYSCALL(exit)
 48f:	b8 02 00 00 00       	mov    $0x2,%eax
 494:	cd 40                	int    $0x40
 496:	c3                   	ret    

00000497 <wait>:
SYSCALL(wait)
 497:	b8 03 00 00 00       	mov    $0x3,%eax
 49c:	cd 40                	int    $0x40
 49e:	c3                   	ret    

0000049f <pipe>:
SYSCALL(pipe)
 49f:	b8 04 00 00 00       	mov    $0x4,%eax
 4a4:	cd 40                	int    $0x40
 4a6:	c3                   	ret    

000004a7 <read>:
SYSCALL(read)
 4a7:	b8 05 00 00 00       	mov    $0x5,%eax
 4ac:	cd 40                	int    $0x40
 4ae:	c3                   	ret    

000004af <write>:
SYSCALL(write)
 4af:	b8 10 00 00 00       	mov    $0x10,%eax
 4b4:	cd 40                	int    $0x40
 4b6:	c3                   	ret    

000004b7 <close>:
SYSCALL(close)
 4b7:	b8 15 00 00 00       	mov    $0x15,%eax
 4bc:	cd 40                	int    $0x40
 4be:	c3                   	ret    

000004bf <kill>:
SYSCALL(kill)
 4bf:	b8 06 00 00 00       	mov    $0x6,%eax
 4c4:	cd 40                	int    $0x40
 4c6:	c3                   	ret    

000004c7 <exec>:
SYSCALL(exec)
 4c7:	b8 07 00 00 00       	mov    $0x7,%eax
 4cc:	cd 40                	int    $0x40
 4ce:	c3                   	ret    

000004cf <open>:
SYSCALL(open)
 4cf:	b8 0f 00 00 00       	mov    $0xf,%eax
 4d4:	cd 40                	int    $0x40
 4d6:	c3                   	ret    

000004d7 <mknod>:
SYSCALL(mknod)
 4d7:	b8 11 00 00 00       	mov    $0x11,%eax
 4dc:	cd 40                	int    $0x40
 4de:	c3                   	ret    

000004df <unlink>:
SYSCALL(unlink)
 4df:	b8 12 00 00 00       	mov    $0x12,%eax
 4e4:	cd 40                	int    $0x40
 4e6:	c3                   	ret    

000004e7 <fstat>:
SYSCALL(fstat)
 4e7:	b8 08 00 00 00       	mov    $0x8,%eax
 4ec:	cd 40                	int    $0x40
 4ee:	c3                   	ret    

000004ef <link>:
SYSCALL(link)
 4ef:	b8 13 00 00 00       	mov    $0x13,%eax
 4f4:	cd 40                	int    $0x40
 4f6:	c3                   	ret    

000004f7 <mkdir>:
SYSCALL(mkdir)
 4f7:	b8 14 00 00 00       	mov    $0x14,%eax
 4fc:	cd 40                	int    $0x40
 4fe:	c3                   	ret    

000004ff <chdir>:
SYSCALL(chdir)
 4ff:	b8 09 00 00 00       	mov    $0x9,%eax
 504:	cd 40                	int    $0x40
 506:	c3                   	ret    

00000507 <dup>:
SYSCALL(dup)
 507:	b8 0a 00 00 00       	mov    $0xa,%eax
 50c:	cd 40                	int    $0x40
 50e:	c3                   	ret    

0000050f <getpid>:
SYSCALL(getpid)
 50f:	b8 0b 00 00 00       	mov    $0xb,%eax
 514:	cd 40                	int    $0x40
 516:	c3                   	ret    

00000517 <sbrk>:
SYSCALL(sbrk)
 517:	b8 0c 00 00 00       	mov    $0xc,%eax
 51c:	cd 40                	int    $0x40
 51e:	c3                   	ret    

0000051f <sleep>:
SYSCALL(sleep)
 51f:	b8 0d 00 00 00       	mov    $0xd,%eax
 524:	cd 40                	int    $0x40
 526:	c3                   	ret    

00000527 <uptime>:
SYSCALL(uptime)
 527:	b8 0e 00 00 00       	mov    $0xe,%eax
 52c:	cd 40                	int    $0x40
 52e:	c3                   	ret    

0000052f <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 52f:	b8 16 00 00 00       	mov    $0x16,%eax
 534:	cd 40                	int    $0x40
 536:	c3                   	ret    

00000537 <getpinfo>:
SYSCALL(getpinfo)
 537:	b8 17 00 00 00       	mov    $0x17,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	ret    

0000053f <yield>:
SYSCALL(yield)
 53f:	b8 18 00 00 00       	mov    $0x18,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	ret    

00000547 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 547:	55                   	push   %ebp
 548:	89 e5                	mov    %esp,%ebp
 54a:	83 ec 18             	sub    $0x18,%esp
 54d:	8b 45 0c             	mov    0xc(%ebp),%eax
 550:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 553:	83 ec 04             	sub    $0x4,%esp
 556:	6a 01                	push   $0x1
 558:	8d 45 f4             	lea    -0xc(%ebp),%eax
 55b:	50                   	push   %eax
 55c:	ff 75 08             	push   0x8(%ebp)
 55f:	e8 4b ff ff ff       	call   4af <write>
 564:	83 c4 10             	add    $0x10,%esp
}
 567:	90                   	nop
 568:	c9                   	leave  
 569:	c3                   	ret    

0000056a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 56a:	55                   	push   %ebp
 56b:	89 e5                	mov    %esp,%ebp
 56d:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 570:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 577:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 57b:	74 17                	je     594 <printint+0x2a>
 57d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 581:	79 11                	jns    594 <printint+0x2a>
    neg = 1;
 583:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 58a:	8b 45 0c             	mov    0xc(%ebp),%eax
 58d:	f7 d8                	neg    %eax
 58f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 592:	eb 06                	jmp    59a <printint+0x30>
  } else {
    x = xx;
 594:	8b 45 0c             	mov    0xc(%ebp),%eax
 597:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 59a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5a7:	ba 00 00 00 00       	mov    $0x0,%edx
 5ac:	f7 f1                	div    %ecx
 5ae:	89 d1                	mov    %edx,%ecx
 5b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b3:	8d 50 01             	lea    0x1(%eax),%edx
 5b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5b9:	0f b6 91 cc 0c 00 00 	movzbl 0xccc(%ecx),%edx
 5c0:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ca:	ba 00 00 00 00       	mov    $0x0,%edx
 5cf:	f7 f1                	div    %ecx
 5d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d8:	75 c7                	jne    5a1 <printint+0x37>
  if(neg)
 5da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5de:	74 2d                	je     60d <printint+0xa3>
    buf[i++] = '-';
 5e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e3:	8d 50 01             	lea    0x1(%eax),%edx
 5e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5e9:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5ee:	eb 1d                	jmp    60d <printint+0xa3>
    putc(fd, buf[i]);
 5f0:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f6:	01 d0                	add    %edx,%eax
 5f8:	0f b6 00             	movzbl (%eax),%eax
 5fb:	0f be c0             	movsbl %al,%eax
 5fe:	83 ec 08             	sub    $0x8,%esp
 601:	50                   	push   %eax
 602:	ff 75 08             	push   0x8(%ebp)
 605:	e8 3d ff ff ff       	call   547 <putc>
 60a:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 60d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 611:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 615:	79 d9                	jns    5f0 <printint+0x86>
}
 617:	90                   	nop
 618:	90                   	nop
 619:	c9                   	leave  
 61a:	c3                   	ret    

0000061b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 61b:	55                   	push   %ebp
 61c:	89 e5                	mov    %esp,%ebp
 61e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 621:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 628:	8d 45 0c             	lea    0xc(%ebp),%eax
 62b:	83 c0 04             	add    $0x4,%eax
 62e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 631:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 638:	e9 59 01 00 00       	jmp    796 <printf+0x17b>
    c = fmt[i] & 0xff;
 63d:	8b 55 0c             	mov    0xc(%ebp),%edx
 640:	8b 45 f0             	mov    -0x10(%ebp),%eax
 643:	01 d0                	add    %edx,%eax
 645:	0f b6 00             	movzbl (%eax),%eax
 648:	0f be c0             	movsbl %al,%eax
 64b:	25 ff 00 00 00       	and    $0xff,%eax
 650:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 653:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 657:	75 2c                	jne    685 <printf+0x6a>
      if(c == '%'){
 659:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65d:	75 0c                	jne    66b <printf+0x50>
        state = '%';
 65f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 666:	e9 27 01 00 00       	jmp    792 <printf+0x177>
      } else {
        putc(fd, c);
 66b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66e:	0f be c0             	movsbl %al,%eax
 671:	83 ec 08             	sub    $0x8,%esp
 674:	50                   	push   %eax
 675:	ff 75 08             	push   0x8(%ebp)
 678:	e8 ca fe ff ff       	call   547 <putc>
 67d:	83 c4 10             	add    $0x10,%esp
 680:	e9 0d 01 00 00       	jmp    792 <printf+0x177>
      }
    } else if(state == '%'){
 685:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 689:	0f 85 03 01 00 00    	jne    792 <printf+0x177>
      if(c == 'd'){
 68f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 693:	75 1e                	jne    6b3 <printf+0x98>
        printint(fd, *ap, 10, 1);
 695:	8b 45 e8             	mov    -0x18(%ebp),%eax
 698:	8b 00                	mov    (%eax),%eax
 69a:	6a 01                	push   $0x1
 69c:	6a 0a                	push   $0xa
 69e:	50                   	push   %eax
 69f:	ff 75 08             	push   0x8(%ebp)
 6a2:	e8 c3 fe ff ff       	call   56a <printint>
 6a7:	83 c4 10             	add    $0x10,%esp
        ap++;
 6aa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ae:	e9 d8 00 00 00       	jmp    78b <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6b3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6b7:	74 06                	je     6bf <printf+0xa4>
 6b9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6bd:	75 1e                	jne    6dd <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c2:	8b 00                	mov    (%eax),%eax
 6c4:	6a 00                	push   $0x0
 6c6:	6a 10                	push   $0x10
 6c8:	50                   	push   %eax
 6c9:	ff 75 08             	push   0x8(%ebp)
 6cc:	e8 99 fe ff ff       	call   56a <printint>
 6d1:	83 c4 10             	add    $0x10,%esp
        ap++;
 6d4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d8:	e9 ae 00 00 00       	jmp    78b <printf+0x170>
      } else if(c == 's'){
 6dd:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e1:	75 43                	jne    726 <printf+0x10b>
        s = (char*)*ap;
 6e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e6:	8b 00                	mov    (%eax),%eax
 6e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f3:	75 25                	jne    71a <printf+0xff>
          s = "(null)";
 6f5:	c7 45 f4 3c 0a 00 00 	movl   $0xa3c,-0xc(%ebp)
        while(*s != 0){
 6fc:	eb 1c                	jmp    71a <printf+0xff>
          putc(fd, *s);
 6fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 701:	0f b6 00             	movzbl (%eax),%eax
 704:	0f be c0             	movsbl %al,%eax
 707:	83 ec 08             	sub    $0x8,%esp
 70a:	50                   	push   %eax
 70b:	ff 75 08             	push   0x8(%ebp)
 70e:	e8 34 fe ff ff       	call   547 <putc>
 713:	83 c4 10             	add    $0x10,%esp
          s++;
 716:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 71a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71d:	0f b6 00             	movzbl (%eax),%eax
 720:	84 c0                	test   %al,%al
 722:	75 da                	jne    6fe <printf+0xe3>
 724:	eb 65                	jmp    78b <printf+0x170>
        }
      } else if(c == 'c'){
 726:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 72a:	75 1d                	jne    749 <printf+0x12e>
        putc(fd, *ap);
 72c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72f:	8b 00                	mov    (%eax),%eax
 731:	0f be c0             	movsbl %al,%eax
 734:	83 ec 08             	sub    $0x8,%esp
 737:	50                   	push   %eax
 738:	ff 75 08             	push   0x8(%ebp)
 73b:	e8 07 fe ff ff       	call   547 <putc>
 740:	83 c4 10             	add    $0x10,%esp
        ap++;
 743:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 747:	eb 42                	jmp    78b <printf+0x170>
      } else if(c == '%'){
 749:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74d:	75 17                	jne    766 <printf+0x14b>
        putc(fd, c);
 74f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 752:	0f be c0             	movsbl %al,%eax
 755:	83 ec 08             	sub    $0x8,%esp
 758:	50                   	push   %eax
 759:	ff 75 08             	push   0x8(%ebp)
 75c:	e8 e6 fd ff ff       	call   547 <putc>
 761:	83 c4 10             	add    $0x10,%esp
 764:	eb 25                	jmp    78b <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 766:	83 ec 08             	sub    $0x8,%esp
 769:	6a 25                	push   $0x25
 76b:	ff 75 08             	push   0x8(%ebp)
 76e:	e8 d4 fd ff ff       	call   547 <putc>
 773:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 776:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 779:	0f be c0             	movsbl %al,%eax
 77c:	83 ec 08             	sub    $0x8,%esp
 77f:	50                   	push   %eax
 780:	ff 75 08             	push   0x8(%ebp)
 783:	e8 bf fd ff ff       	call   547 <putc>
 788:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 78b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 792:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 796:	8b 55 0c             	mov    0xc(%ebp),%edx
 799:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79c:	01 d0                	add    %edx,%eax
 79e:	0f b6 00             	movzbl (%eax),%eax
 7a1:	84 c0                	test   %al,%al
 7a3:	0f 85 94 fe ff ff    	jne    63d <printf+0x22>
    }
  }
}
 7a9:	90                   	nop
 7aa:	90                   	nop
 7ab:	c9                   	leave  
 7ac:	c3                   	ret    

000007ad <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ad:	55                   	push   %ebp
 7ae:	89 e5                	mov    %esp,%ebp
 7b0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b3:	8b 45 08             	mov    0x8(%ebp),%eax
 7b6:	83 e8 08             	sub    $0x8,%eax
 7b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bc:	a1 e8 0c 00 00       	mov    0xce8,%eax
 7c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c4:	eb 24                	jmp    7ea <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c9:	8b 00                	mov    (%eax),%eax
 7cb:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7ce:	72 12                	jb     7e2 <free+0x35>
 7d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d6:	77 24                	ja     7fc <free+0x4f>
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7e0:	72 1a                	jb     7fc <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e5:	8b 00                	mov    (%eax),%eax
 7e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ed:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f0:	76 d4                	jbe    7c6 <free+0x19>
 7f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f5:	8b 00                	mov    (%eax),%eax
 7f7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7fa:	73 ca                	jae    7c6 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ff:	8b 40 04             	mov    0x4(%eax),%eax
 802:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 809:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80c:	01 c2                	add    %eax,%edx
 80e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 811:	8b 00                	mov    (%eax),%eax
 813:	39 c2                	cmp    %eax,%edx
 815:	75 24                	jne    83b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 817:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81a:	8b 50 04             	mov    0x4(%eax),%edx
 81d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	8b 40 04             	mov    0x4(%eax),%eax
 825:	01 c2                	add    %eax,%edx
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	8b 00                	mov    (%eax),%eax
 832:	8b 10                	mov    (%eax),%edx
 834:	8b 45 f8             	mov    -0x8(%ebp),%eax
 837:	89 10                	mov    %edx,(%eax)
 839:	eb 0a                	jmp    845 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 83b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83e:	8b 10                	mov    (%eax),%edx
 840:	8b 45 f8             	mov    -0x8(%ebp),%eax
 843:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	8b 40 04             	mov    0x4(%eax),%eax
 84b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 852:	8b 45 fc             	mov    -0x4(%ebp),%eax
 855:	01 d0                	add    %edx,%eax
 857:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 85a:	75 20                	jne    87c <free+0xcf>
    p->s.size += bp->s.size;
 85c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85f:	8b 50 04             	mov    0x4(%eax),%edx
 862:	8b 45 f8             	mov    -0x8(%ebp),%eax
 865:	8b 40 04             	mov    0x4(%eax),%eax
 868:	01 c2                	add    %eax,%edx
 86a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 870:	8b 45 f8             	mov    -0x8(%ebp),%eax
 873:	8b 10                	mov    (%eax),%edx
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	89 10                	mov    %edx,(%eax)
 87a:	eb 08                	jmp    884 <free+0xd7>
  } else
    p->s.ptr = bp;
 87c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 882:	89 10                	mov    %edx,(%eax)
  freep = p;
 884:	8b 45 fc             	mov    -0x4(%ebp),%eax
 887:	a3 e8 0c 00 00       	mov    %eax,0xce8
}
 88c:	90                   	nop
 88d:	c9                   	leave  
 88e:	c3                   	ret    

0000088f <morecore>:

static Header*
morecore(uint nu)
{
 88f:	55                   	push   %ebp
 890:	89 e5                	mov    %esp,%ebp
 892:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 895:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 89c:	77 07                	ja     8a5 <morecore+0x16>
    nu = 4096;
 89e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a5:	8b 45 08             	mov    0x8(%ebp),%eax
 8a8:	c1 e0 03             	shl    $0x3,%eax
 8ab:	83 ec 0c             	sub    $0xc,%esp
 8ae:	50                   	push   %eax
 8af:	e8 63 fc ff ff       	call   517 <sbrk>
 8b4:	83 c4 10             	add    $0x10,%esp
 8b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8ba:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8be:	75 07                	jne    8c7 <morecore+0x38>
    return 0;
 8c0:	b8 00 00 00 00       	mov    $0x0,%eax
 8c5:	eb 26                	jmp    8ed <morecore+0x5e>
  hp = (Header*)p;
 8c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d0:	8b 55 08             	mov    0x8(%ebp),%edx
 8d3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d9:	83 c0 08             	add    $0x8,%eax
 8dc:	83 ec 0c             	sub    $0xc,%esp
 8df:	50                   	push   %eax
 8e0:	e8 c8 fe ff ff       	call   7ad <free>
 8e5:	83 c4 10             	add    $0x10,%esp
  return freep;
 8e8:	a1 e8 0c 00 00       	mov    0xce8,%eax
}
 8ed:	c9                   	leave  
 8ee:	c3                   	ret    

000008ef <malloc>:

void*
malloc(uint nbytes)
{
 8ef:	55                   	push   %ebp
 8f0:	89 e5                	mov    %esp,%ebp
 8f2:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f5:	8b 45 08             	mov    0x8(%ebp),%eax
 8f8:	83 c0 07             	add    $0x7,%eax
 8fb:	c1 e8 03             	shr    $0x3,%eax
 8fe:	83 c0 01             	add    $0x1,%eax
 901:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 904:	a1 e8 0c 00 00       	mov    0xce8,%eax
 909:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 910:	75 23                	jne    935 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 912:	c7 45 f0 e0 0c 00 00 	movl   $0xce0,-0x10(%ebp)
 919:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91c:	a3 e8 0c 00 00       	mov    %eax,0xce8
 921:	a1 e8 0c 00 00       	mov    0xce8,%eax
 926:	a3 e0 0c 00 00       	mov    %eax,0xce0
    base.s.size = 0;
 92b:	c7 05 e4 0c 00 00 00 	movl   $0x0,0xce4
 932:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 935:	8b 45 f0             	mov    -0x10(%ebp),%eax
 938:	8b 00                	mov    (%eax),%eax
 93a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 940:	8b 40 04             	mov    0x4(%eax),%eax
 943:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 946:	77 4d                	ja     995 <malloc+0xa6>
      if(p->s.size == nunits)
 948:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94b:	8b 40 04             	mov    0x4(%eax),%eax
 94e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 951:	75 0c                	jne    95f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 953:	8b 45 f4             	mov    -0xc(%ebp),%eax
 956:	8b 10                	mov    (%eax),%edx
 958:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95b:	89 10                	mov    %edx,(%eax)
 95d:	eb 26                	jmp    985 <malloc+0x96>
      else {
        p->s.size -= nunits;
 95f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 962:	8b 40 04             	mov    0x4(%eax),%eax
 965:	2b 45 ec             	sub    -0x14(%ebp),%eax
 968:	89 c2                	mov    %eax,%edx
 96a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	8b 40 04             	mov    0x4(%eax),%eax
 976:	c1 e0 03             	shl    $0x3,%eax
 979:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 982:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 985:	8b 45 f0             	mov    -0x10(%ebp),%eax
 988:	a3 e8 0c 00 00       	mov    %eax,0xce8
      return (void*)(p + 1);
 98d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 990:	83 c0 08             	add    $0x8,%eax
 993:	eb 3b                	jmp    9d0 <malloc+0xe1>
    }
    if(p == freep)
 995:	a1 e8 0c 00 00       	mov    0xce8,%eax
 99a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99d:	75 1e                	jne    9bd <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 99f:	83 ec 0c             	sub    $0xc,%esp
 9a2:	ff 75 ec             	push   -0x14(%ebp)
 9a5:	e8 e5 fe ff ff       	call   88f <morecore>
 9aa:	83 c4 10             	add    $0x10,%esp
 9ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b4:	75 07                	jne    9bd <malloc+0xce>
        return 0;
 9b6:	b8 00 00 00 00       	mov    $0x0,%eax
 9bb:	eb 13                	jmp    9d0 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c6:	8b 00                	mov    (%eax),%eax
 9c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9cb:	e9 6d ff ff ff       	jmp    93d <malloc+0x4e>
  }
}
 9d0:	c9                   	leave  
 9d1:	c3                   	ret    
