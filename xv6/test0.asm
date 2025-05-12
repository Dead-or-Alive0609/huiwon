
_test0:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "pstat.h"

#define NUM_PROCS 3
#define WORK_UNIT 10000000

void workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++) {
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 11                	jmp    27 <workload+0x27>
    j += i * j + 1;
  16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  19:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f8             	add    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++) {
  23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	7c e7                	jl     16 <workload+0x16>
  }
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
  41:	83 ec 14             	sub    $0x14,%esp
  setSchedPolicy(1); // MLFQ 정책 적용
  44:	83 ec 0c             	sub    $0xc,%esp
  47:	6a 01                	push   $0x1
  49:	e8 98 03 00 00       	call   3e6 <setSchedPolicy>
  4e:	83 c4 10             	add    $0x10,%esp

  printf(1, "\n[TEST0] MLFQ tick 증가 및 DEMOTE 동작 테스트 시작\n");
  51:	83 ec 08             	sub    $0x8,%esp
  54:	68 84 08 00 00       	push   $0x884
  59:	6a 01                	push   $0x1
  5b:	e8 6a 04 00 00       	call   4ca <printf>
  60:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NUM_PROCS; i++) {
  63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  6a:	eb 4e                	jmp    ba <main+0x87>
    int pid = fork();
  6c:	e8 cd 02 00 00       	call   33e <fork>
  71:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid < 0) {
  74:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  78:	79 17                	jns    91 <main+0x5e>
      printf(1, "fork 실패\n");
  7a:	83 ec 08             	sub    $0x8,%esp
  7d:	68 c2 08 00 00       	push   $0x8c2
  82:	6a 01                	push   $0x1
  84:	e8 41 04 00 00       	call   4ca <printf>
  89:	83 c4 10             	add    $0x10,%esp
      exit();
  8c:	e8 b5 02 00 00       	call   346 <exit>
    }

    if (pid == 0) {
  91:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  95:	75 1f                	jne    b6 <main+0x83>
      // child
      while (1) {
        workload(WORK_UNIT); // CPU 사용
  97:	83 ec 0c             	sub    $0xc,%esp
  9a:	68 80 96 98 00       	push   $0x989680
  9f:	e8 5c ff ff ff       	call   0 <workload>
  a4:	83 c4 10             	add    $0x10,%esp
        sleep(1);            // yield 유도 (DEMOTE 확인용)
  a7:	83 ec 0c             	sub    $0xc,%esp
  aa:	6a 01                	push   $0x1
  ac:	e8 25 03 00 00       	call   3d6 <sleep>
  b1:	83 c4 10             	add    $0x10,%esp
        workload(WORK_UNIT); // CPU 사용
  b4:	eb e1                	jmp    97 <main+0x64>
  for (int i = 0; i < NUM_PROCS; i++) {
  b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  ba:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  be:	7e ac                	jle    6c <main+0x39>
      }
    }
  }

  // 부모는 대기
  for (int i = 0; i < NUM_PROCS; i++) {
  c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  c7:	eb 09                	jmp    d2 <main+0x9f>
    wait();
  c9:	e8 80 02 00 00       	call   34e <wait>
  for (int i = 0; i < NUM_PROCS; i++) {
  ce:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  d2:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
  d6:	7e f1                	jle    c9 <main+0x96>
  }

  printf(1, "\n[TEST0 종료] Ctrl-a x로 QEMU 종료\n");
  d8:	83 ec 08             	sub    $0x8,%esp
  db:	68 d0 08 00 00       	push   $0x8d0
  e0:	6a 01                	push   $0x1
  e2:	e8 e3 03 00 00       	call   4ca <printf>
  e7:	83 c4 10             	add    $0x10,%esp
  exit();
  ea:	e8 57 02 00 00       	call   346 <exit>

000000ef <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  ef:	55                   	push   %ebp
  f0:	89 e5                	mov    %esp,%ebp
  f2:	57                   	push   %edi
  f3:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  f7:	8b 55 10             	mov    0x10(%ebp),%edx
  fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  fd:	89 cb                	mov    %ecx,%ebx
  ff:	89 df                	mov    %ebx,%edi
 101:	89 d1                	mov    %edx,%ecx
 103:	fc                   	cld    
 104:	f3 aa                	rep stos %al,%es:(%edi)
 106:	89 ca                	mov    %ecx,%edx
 108:	89 fb                	mov    %edi,%ebx
 10a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 10d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 110:	90                   	nop
 111:	5b                   	pop    %ebx
 112:	5f                   	pop    %edi
 113:	5d                   	pop    %ebp
 114:	c3                   	ret    

00000115 <strcpy>:



char*
strcpy(char *s, char *t)
{
 115:	55                   	push   %ebp
 116:	89 e5                	mov    %esp,%ebp
 118:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 11b:	8b 45 08             	mov    0x8(%ebp),%eax
 11e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 121:	90                   	nop
 122:	8b 55 0c             	mov    0xc(%ebp),%edx
 125:	8d 42 01             	lea    0x1(%edx),%eax
 128:	89 45 0c             	mov    %eax,0xc(%ebp)
 12b:	8b 45 08             	mov    0x8(%ebp),%eax
 12e:	8d 48 01             	lea    0x1(%eax),%ecx
 131:	89 4d 08             	mov    %ecx,0x8(%ebp)
 134:	0f b6 12             	movzbl (%edx),%edx
 137:	88 10                	mov    %dl,(%eax)
 139:	0f b6 00             	movzbl (%eax),%eax
 13c:	84 c0                	test   %al,%al
 13e:	75 e2                	jne    122 <strcpy+0xd>
    ;
  return os;
 140:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 143:	c9                   	leave  
 144:	c3                   	ret    

00000145 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 145:	55                   	push   %ebp
 146:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 148:	eb 08                	jmp    152 <strcmp+0xd>
    p++, q++;
 14a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 152:	8b 45 08             	mov    0x8(%ebp),%eax
 155:	0f b6 00             	movzbl (%eax),%eax
 158:	84 c0                	test   %al,%al
 15a:	74 10                	je     16c <strcmp+0x27>
 15c:	8b 45 08             	mov    0x8(%ebp),%eax
 15f:	0f b6 10             	movzbl (%eax),%edx
 162:	8b 45 0c             	mov    0xc(%ebp),%eax
 165:	0f b6 00             	movzbl (%eax),%eax
 168:	38 c2                	cmp    %al,%dl
 16a:	74 de                	je     14a <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	0f b6 00             	movzbl (%eax),%eax
 172:	0f b6 d0             	movzbl %al,%edx
 175:	8b 45 0c             	mov    0xc(%ebp),%eax
 178:	0f b6 00             	movzbl (%eax),%eax
 17b:	0f b6 c8             	movzbl %al,%ecx
 17e:	89 d0                	mov    %edx,%eax
 180:	29 c8                	sub    %ecx,%eax
}
 182:	5d                   	pop    %ebp
 183:	c3                   	ret    

00000184 <strlen>:

uint
strlen(char *s)
{
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 18a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 191:	eb 04                	jmp    197 <strlen+0x13>
 193:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 197:	8b 55 fc             	mov    -0x4(%ebp),%edx
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
 19d:	01 d0                	add    %edx,%eax
 19f:	0f b6 00             	movzbl (%eax),%eax
 1a2:	84 c0                	test   %al,%al
 1a4:	75 ed                	jne    193 <strlen+0xf>
    ;
  return n;
 1a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1a9:	c9                   	leave  
 1aa:	c3                   	ret    

000001ab <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ab:	55                   	push   %ebp
 1ac:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1ae:	8b 45 10             	mov    0x10(%ebp),%eax
 1b1:	50                   	push   %eax
 1b2:	ff 75 0c             	push   0xc(%ebp)
 1b5:	ff 75 08             	push   0x8(%ebp)
 1b8:	e8 32 ff ff ff       	call   ef <stosb>
 1bd:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c3:	c9                   	leave  
 1c4:	c3                   	ret    

000001c5 <strchr>:

char*
strchr(const char *s, char c)
{
 1c5:	55                   	push   %ebp
 1c6:	89 e5                	mov    %esp,%ebp
 1c8:	83 ec 04             	sub    $0x4,%esp
 1cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ce:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1d1:	eb 14                	jmp    1e7 <strchr+0x22>
    if(*s == c)
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
 1d6:	0f b6 00             	movzbl (%eax),%eax
 1d9:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1dc:	75 05                	jne    1e3 <strchr+0x1e>
      return (char*)s;
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	eb 13                	jmp    1f6 <strchr+0x31>
  for(; *s; s++)
 1e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ea:	0f b6 00             	movzbl (%eax),%eax
 1ed:	84 c0                	test   %al,%al
 1ef:	75 e2                	jne    1d3 <strchr+0xe>
  return 0;
 1f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1f6:	c9                   	leave  
 1f7:	c3                   	ret    

000001f8 <gets>:

char*
gets(char *buf, int max)
{
 1f8:	55                   	push   %ebp
 1f9:	89 e5                	mov    %esp,%ebp
 1fb:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 205:	eb 42                	jmp    249 <gets+0x51>
    cc = read(0, &c, 1);
 207:	83 ec 04             	sub    $0x4,%esp
 20a:	6a 01                	push   $0x1
 20c:	8d 45 ef             	lea    -0x11(%ebp),%eax
 20f:	50                   	push   %eax
 210:	6a 00                	push   $0x0
 212:	e8 47 01 00 00       	call   35e <read>
 217:	83 c4 10             	add    $0x10,%esp
 21a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 21d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 221:	7e 33                	jle    256 <gets+0x5e>
      break;
    buf[i++] = c;
 223:	8b 45 f4             	mov    -0xc(%ebp),%eax
 226:	8d 50 01             	lea    0x1(%eax),%edx
 229:	89 55 f4             	mov    %edx,-0xc(%ebp)
 22c:	89 c2                	mov    %eax,%edx
 22e:	8b 45 08             	mov    0x8(%ebp),%eax
 231:	01 c2                	add    %eax,%edx
 233:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 237:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 239:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 23d:	3c 0a                	cmp    $0xa,%al
 23f:	74 16                	je     257 <gets+0x5f>
 241:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 245:	3c 0d                	cmp    $0xd,%al
 247:	74 0e                	je     257 <gets+0x5f>
  for(i=0; i+1 < max; ){
 249:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24c:	83 c0 01             	add    $0x1,%eax
 24f:	39 45 0c             	cmp    %eax,0xc(%ebp)
 252:	7f b3                	jg     207 <gets+0xf>
 254:	eb 01                	jmp    257 <gets+0x5f>
      break;
 256:	90                   	nop
      break;
  }
  buf[i] = '\0';
 257:	8b 55 f4             	mov    -0xc(%ebp),%edx
 25a:	8b 45 08             	mov    0x8(%ebp),%eax
 25d:	01 d0                	add    %edx,%eax
 25f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 262:	8b 45 08             	mov    0x8(%ebp),%eax
}
 265:	c9                   	leave  
 266:	c3                   	ret    

00000267 <stat>:

int
stat(char *n, struct stat *st)
{
 267:	55                   	push   %ebp
 268:	89 e5                	mov    %esp,%ebp
 26a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 26d:	83 ec 08             	sub    $0x8,%esp
 270:	6a 00                	push   $0x0
 272:	ff 75 08             	push   0x8(%ebp)
 275:	e8 0c 01 00 00       	call   386 <open>
 27a:	83 c4 10             	add    $0x10,%esp
 27d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 280:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 284:	79 07                	jns    28d <stat+0x26>
    return -1;
 286:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 28b:	eb 25                	jmp    2b2 <stat+0x4b>
  r = fstat(fd, st);
 28d:	83 ec 08             	sub    $0x8,%esp
 290:	ff 75 0c             	push   0xc(%ebp)
 293:	ff 75 f4             	push   -0xc(%ebp)
 296:	e8 03 01 00 00       	call   39e <fstat>
 29b:	83 c4 10             	add    $0x10,%esp
 29e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2a1:	83 ec 0c             	sub    $0xc,%esp
 2a4:	ff 75 f4             	push   -0xc(%ebp)
 2a7:	e8 c2 00 00 00       	call   36e <close>
 2ac:	83 c4 10             	add    $0x10,%esp
  return r;
 2af:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2b2:	c9                   	leave  
 2b3:	c3                   	ret    

000002b4 <atoi>:

int
atoi(const char *s)
{
 2b4:	55                   	push   %ebp
 2b5:	89 e5                	mov    %esp,%ebp
 2b7:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2c1:	eb 25                	jmp    2e8 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2c6:	89 d0                	mov    %edx,%eax
 2c8:	c1 e0 02             	shl    $0x2,%eax
 2cb:	01 d0                	add    %edx,%eax
 2cd:	01 c0                	add    %eax,%eax
 2cf:	89 c1                	mov    %eax,%ecx
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
 2d4:	8d 50 01             	lea    0x1(%eax),%edx
 2d7:	89 55 08             	mov    %edx,0x8(%ebp)
 2da:	0f b6 00             	movzbl (%eax),%eax
 2dd:	0f be c0             	movsbl %al,%eax
 2e0:	01 c8                	add    %ecx,%eax
 2e2:	83 e8 30             	sub    $0x30,%eax
 2e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e8:	8b 45 08             	mov    0x8(%ebp),%eax
 2eb:	0f b6 00             	movzbl (%eax),%eax
 2ee:	3c 2f                	cmp    $0x2f,%al
 2f0:	7e 0a                	jle    2fc <atoi+0x48>
 2f2:	8b 45 08             	mov    0x8(%ebp),%eax
 2f5:	0f b6 00             	movzbl (%eax),%eax
 2f8:	3c 39                	cmp    $0x39,%al
 2fa:	7e c7                	jle    2c3 <atoi+0xf>
  return n;
 2fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ff:	c9                   	leave  
 300:	c3                   	ret    

00000301 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 301:	55                   	push   %ebp
 302:	89 e5                	mov    %esp,%ebp
 304:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 307:	8b 45 08             	mov    0x8(%ebp),%eax
 30a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 30d:	8b 45 0c             	mov    0xc(%ebp),%eax
 310:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 313:	eb 17                	jmp    32c <memmove+0x2b>
    *dst++ = *src++;
 315:	8b 55 f8             	mov    -0x8(%ebp),%edx
 318:	8d 42 01             	lea    0x1(%edx),%eax
 31b:	89 45 f8             	mov    %eax,-0x8(%ebp)
 31e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 321:	8d 48 01             	lea    0x1(%eax),%ecx
 324:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 327:	0f b6 12             	movzbl (%edx),%edx
 32a:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 32c:	8b 45 10             	mov    0x10(%ebp),%eax
 32f:	8d 50 ff             	lea    -0x1(%eax),%edx
 332:	89 55 10             	mov    %edx,0x10(%ebp)
 335:	85 c0                	test   %eax,%eax
 337:	7f dc                	jg     315 <memmove+0x14>
  return vdst;
 339:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33c:	c9                   	leave  
 33d:	c3                   	ret    

0000033e <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 33e:	b8 01 00 00 00       	mov    $0x1,%eax
 343:	cd 40                	int    $0x40
 345:	c3                   	ret    

00000346 <exit>:
SYSCALL(exit)
 346:	b8 02 00 00 00       	mov    $0x2,%eax
 34b:	cd 40                	int    $0x40
 34d:	c3                   	ret    

0000034e <wait>:
SYSCALL(wait)
 34e:	b8 03 00 00 00       	mov    $0x3,%eax
 353:	cd 40                	int    $0x40
 355:	c3                   	ret    

00000356 <pipe>:
SYSCALL(pipe)
 356:	b8 04 00 00 00       	mov    $0x4,%eax
 35b:	cd 40                	int    $0x40
 35d:	c3                   	ret    

0000035e <read>:
SYSCALL(read)
 35e:	b8 05 00 00 00       	mov    $0x5,%eax
 363:	cd 40                	int    $0x40
 365:	c3                   	ret    

00000366 <write>:
SYSCALL(write)
 366:	b8 10 00 00 00       	mov    $0x10,%eax
 36b:	cd 40                	int    $0x40
 36d:	c3                   	ret    

0000036e <close>:
SYSCALL(close)
 36e:	b8 15 00 00 00       	mov    $0x15,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret    

00000376 <kill>:
SYSCALL(kill)
 376:	b8 06 00 00 00       	mov    $0x6,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <exec>:
SYSCALL(exec)
 37e:	b8 07 00 00 00       	mov    $0x7,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <open>:
SYSCALL(open)
 386:	b8 0f 00 00 00       	mov    $0xf,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <mknod>:
SYSCALL(mknod)
 38e:	b8 11 00 00 00       	mov    $0x11,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret    

00000396 <unlink>:
SYSCALL(unlink)
 396:	b8 12 00 00 00       	mov    $0x12,%eax
 39b:	cd 40                	int    $0x40
 39d:	c3                   	ret    

0000039e <fstat>:
SYSCALL(fstat)
 39e:	b8 08 00 00 00       	mov    $0x8,%eax
 3a3:	cd 40                	int    $0x40
 3a5:	c3                   	ret    

000003a6 <link>:
SYSCALL(link)
 3a6:	b8 13 00 00 00       	mov    $0x13,%eax
 3ab:	cd 40                	int    $0x40
 3ad:	c3                   	ret    

000003ae <mkdir>:
SYSCALL(mkdir)
 3ae:	b8 14 00 00 00       	mov    $0x14,%eax
 3b3:	cd 40                	int    $0x40
 3b5:	c3                   	ret    

000003b6 <chdir>:
SYSCALL(chdir)
 3b6:	b8 09 00 00 00       	mov    $0x9,%eax
 3bb:	cd 40                	int    $0x40
 3bd:	c3                   	ret    

000003be <dup>:
SYSCALL(dup)
 3be:	b8 0a 00 00 00       	mov    $0xa,%eax
 3c3:	cd 40                	int    $0x40
 3c5:	c3                   	ret    

000003c6 <getpid>:
SYSCALL(getpid)
 3c6:	b8 0b 00 00 00       	mov    $0xb,%eax
 3cb:	cd 40                	int    $0x40
 3cd:	c3                   	ret    

000003ce <sbrk>:
SYSCALL(sbrk)
 3ce:	b8 0c 00 00 00       	mov    $0xc,%eax
 3d3:	cd 40                	int    $0x40
 3d5:	c3                   	ret    

000003d6 <sleep>:
SYSCALL(sleep)
 3d6:	b8 0d 00 00 00       	mov    $0xd,%eax
 3db:	cd 40                	int    $0x40
 3dd:	c3                   	ret    

000003de <uptime>:
SYSCALL(uptime)
 3de:	b8 0e 00 00 00       	mov    $0xe,%eax
 3e3:	cd 40                	int    $0x40
 3e5:	c3                   	ret    

000003e6 <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 3e6:	b8 16 00 00 00       	mov    $0x16,%eax
 3eb:	cd 40                	int    $0x40
 3ed:	c3                   	ret    

000003ee <getpinfo>:
SYSCALL(getpinfo)
 3ee:	b8 17 00 00 00       	mov    $0x17,%eax
 3f3:	cd 40                	int    $0x40
 3f5:	c3                   	ret    

000003f6 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3f6:	55                   	push   %ebp
 3f7:	89 e5                	mov    %esp,%ebp
 3f9:	83 ec 18             	sub    $0x18,%esp
 3fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ff:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 402:	83 ec 04             	sub    $0x4,%esp
 405:	6a 01                	push   $0x1
 407:	8d 45 f4             	lea    -0xc(%ebp),%eax
 40a:	50                   	push   %eax
 40b:	ff 75 08             	push   0x8(%ebp)
 40e:	e8 53 ff ff ff       	call   366 <write>
 413:	83 c4 10             	add    $0x10,%esp
}
 416:	90                   	nop
 417:	c9                   	leave  
 418:	c3                   	ret    

00000419 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 419:	55                   	push   %ebp
 41a:	89 e5                	mov    %esp,%ebp
 41c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 41f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 426:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 42a:	74 17                	je     443 <printint+0x2a>
 42c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 430:	79 11                	jns    443 <printint+0x2a>
    neg = 1;
 432:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 439:	8b 45 0c             	mov    0xc(%ebp),%eax
 43c:	f7 d8                	neg    %eax
 43e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 441:	eb 06                	jmp    449 <printint+0x30>
  } else {
    x = xx;
 443:	8b 45 0c             	mov    0xc(%ebp),%eax
 446:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 449:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 450:	8b 4d 10             	mov    0x10(%ebp),%ecx
 453:	8b 45 ec             	mov    -0x14(%ebp),%eax
 456:	ba 00 00 00 00       	mov    $0x0,%edx
 45b:	f7 f1                	div    %ecx
 45d:	89 d1                	mov    %edx,%ecx
 45f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 462:	8d 50 01             	lea    0x1(%eax),%edx
 465:	89 55 f4             	mov    %edx,-0xc(%ebp)
 468:	0f b6 91 64 0b 00 00 	movzbl 0xb64(%ecx),%edx
 46f:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 473:	8b 4d 10             	mov    0x10(%ebp),%ecx
 476:	8b 45 ec             	mov    -0x14(%ebp),%eax
 479:	ba 00 00 00 00       	mov    $0x0,%edx
 47e:	f7 f1                	div    %ecx
 480:	89 45 ec             	mov    %eax,-0x14(%ebp)
 483:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 487:	75 c7                	jne    450 <printint+0x37>
  if(neg)
 489:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 48d:	74 2d                	je     4bc <printint+0xa3>
    buf[i++] = '-';
 48f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 492:	8d 50 01             	lea    0x1(%eax),%edx
 495:	89 55 f4             	mov    %edx,-0xc(%ebp)
 498:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 49d:	eb 1d                	jmp    4bc <printint+0xa3>
    putc(fd, buf[i]);
 49f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a5:	01 d0                	add    %edx,%eax
 4a7:	0f b6 00             	movzbl (%eax),%eax
 4aa:	0f be c0             	movsbl %al,%eax
 4ad:	83 ec 08             	sub    $0x8,%esp
 4b0:	50                   	push   %eax
 4b1:	ff 75 08             	push   0x8(%ebp)
 4b4:	e8 3d ff ff ff       	call   3f6 <putc>
 4b9:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4bc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4c4:	79 d9                	jns    49f <printint+0x86>
}
 4c6:	90                   	nop
 4c7:	90                   	nop
 4c8:	c9                   	leave  
 4c9:	c3                   	ret    

000004ca <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4ca:	55                   	push   %ebp
 4cb:	89 e5                	mov    %esp,%ebp
 4cd:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4d0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4d7:	8d 45 0c             	lea    0xc(%ebp),%eax
 4da:	83 c0 04             	add    $0x4,%eax
 4dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4e7:	e9 59 01 00 00       	jmp    645 <printf+0x17b>
    c = fmt[i] & 0xff;
 4ec:	8b 55 0c             	mov    0xc(%ebp),%edx
 4ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4f2:	01 d0                	add    %edx,%eax
 4f4:	0f b6 00             	movzbl (%eax),%eax
 4f7:	0f be c0             	movsbl %al,%eax
 4fa:	25 ff 00 00 00       	and    $0xff,%eax
 4ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 502:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 506:	75 2c                	jne    534 <printf+0x6a>
      if(c == '%'){
 508:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 50c:	75 0c                	jne    51a <printf+0x50>
        state = '%';
 50e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 515:	e9 27 01 00 00       	jmp    641 <printf+0x177>
      } else {
        putc(fd, c);
 51a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51d:	0f be c0             	movsbl %al,%eax
 520:	83 ec 08             	sub    $0x8,%esp
 523:	50                   	push   %eax
 524:	ff 75 08             	push   0x8(%ebp)
 527:	e8 ca fe ff ff       	call   3f6 <putc>
 52c:	83 c4 10             	add    $0x10,%esp
 52f:	e9 0d 01 00 00       	jmp    641 <printf+0x177>
      }
    } else if(state == '%'){
 534:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 538:	0f 85 03 01 00 00    	jne    641 <printf+0x177>
      if(c == 'd'){
 53e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 542:	75 1e                	jne    562 <printf+0x98>
        printint(fd, *ap, 10, 1);
 544:	8b 45 e8             	mov    -0x18(%ebp),%eax
 547:	8b 00                	mov    (%eax),%eax
 549:	6a 01                	push   $0x1
 54b:	6a 0a                	push   $0xa
 54d:	50                   	push   %eax
 54e:	ff 75 08             	push   0x8(%ebp)
 551:	e8 c3 fe ff ff       	call   419 <printint>
 556:	83 c4 10             	add    $0x10,%esp
        ap++;
 559:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 55d:	e9 d8 00 00 00       	jmp    63a <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 562:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 566:	74 06                	je     56e <printf+0xa4>
 568:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 56c:	75 1e                	jne    58c <printf+0xc2>
        printint(fd, *ap, 16, 0);
 56e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 571:	8b 00                	mov    (%eax),%eax
 573:	6a 00                	push   $0x0
 575:	6a 10                	push   $0x10
 577:	50                   	push   %eax
 578:	ff 75 08             	push   0x8(%ebp)
 57b:	e8 99 fe ff ff       	call   419 <printint>
 580:	83 c4 10             	add    $0x10,%esp
        ap++;
 583:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 587:	e9 ae 00 00 00       	jmp    63a <printf+0x170>
      } else if(c == 's'){
 58c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 590:	75 43                	jne    5d5 <printf+0x10b>
        s = (char*)*ap;
 592:	8b 45 e8             	mov    -0x18(%ebp),%eax
 595:	8b 00                	mov    (%eax),%eax
 597:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 59a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 59e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a2:	75 25                	jne    5c9 <printf+0xff>
          s = "(null)";
 5a4:	c7 45 f4 f9 08 00 00 	movl   $0x8f9,-0xc(%ebp)
        while(*s != 0){
 5ab:	eb 1c                	jmp    5c9 <printf+0xff>
          putc(fd, *s);
 5ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b0:	0f b6 00             	movzbl (%eax),%eax
 5b3:	0f be c0             	movsbl %al,%eax
 5b6:	83 ec 08             	sub    $0x8,%esp
 5b9:	50                   	push   %eax
 5ba:	ff 75 08             	push   0x8(%ebp)
 5bd:	e8 34 fe ff ff       	call   3f6 <putc>
 5c2:	83 c4 10             	add    $0x10,%esp
          s++;
 5c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5cc:	0f b6 00             	movzbl (%eax),%eax
 5cf:	84 c0                	test   %al,%al
 5d1:	75 da                	jne    5ad <printf+0xe3>
 5d3:	eb 65                	jmp    63a <printf+0x170>
        }
      } else if(c == 'c'){
 5d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5d9:	75 1d                	jne    5f8 <printf+0x12e>
        putc(fd, *ap);
 5db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5de:	8b 00                	mov    (%eax),%eax
 5e0:	0f be c0             	movsbl %al,%eax
 5e3:	83 ec 08             	sub    $0x8,%esp
 5e6:	50                   	push   %eax
 5e7:	ff 75 08             	push   0x8(%ebp)
 5ea:	e8 07 fe ff ff       	call   3f6 <putc>
 5ef:	83 c4 10             	add    $0x10,%esp
        ap++;
 5f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f6:	eb 42                	jmp    63a <printf+0x170>
      } else if(c == '%'){
 5f8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5fc:	75 17                	jne    615 <printf+0x14b>
        putc(fd, c);
 5fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 601:	0f be c0             	movsbl %al,%eax
 604:	83 ec 08             	sub    $0x8,%esp
 607:	50                   	push   %eax
 608:	ff 75 08             	push   0x8(%ebp)
 60b:	e8 e6 fd ff ff       	call   3f6 <putc>
 610:	83 c4 10             	add    $0x10,%esp
 613:	eb 25                	jmp    63a <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 615:	83 ec 08             	sub    $0x8,%esp
 618:	6a 25                	push   $0x25
 61a:	ff 75 08             	push   0x8(%ebp)
 61d:	e8 d4 fd ff ff       	call   3f6 <putc>
 622:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 625:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 628:	0f be c0             	movsbl %al,%eax
 62b:	83 ec 08             	sub    $0x8,%esp
 62e:	50                   	push   %eax
 62f:	ff 75 08             	push   0x8(%ebp)
 632:	e8 bf fd ff ff       	call   3f6 <putc>
 637:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 63a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 641:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 645:	8b 55 0c             	mov    0xc(%ebp),%edx
 648:	8b 45 f0             	mov    -0x10(%ebp),%eax
 64b:	01 d0                	add    %edx,%eax
 64d:	0f b6 00             	movzbl (%eax),%eax
 650:	84 c0                	test   %al,%al
 652:	0f 85 94 fe ff ff    	jne    4ec <printf+0x22>
    }
  }
}
 658:	90                   	nop
 659:	90                   	nop
 65a:	c9                   	leave  
 65b:	c3                   	ret    

0000065c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 65c:	55                   	push   %ebp
 65d:	89 e5                	mov    %esp,%ebp
 65f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 662:	8b 45 08             	mov    0x8(%ebp),%eax
 665:	83 e8 08             	sub    $0x8,%eax
 668:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66b:	a1 80 0b 00 00       	mov    0xb80,%eax
 670:	89 45 fc             	mov    %eax,-0x4(%ebp)
 673:	eb 24                	jmp    699 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 67d:	72 12                	jb     691 <free+0x35>
 67f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 682:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 685:	77 24                	ja     6ab <free+0x4f>
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68a:	8b 00                	mov    (%eax),%eax
 68c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 68f:	72 1a                	jb     6ab <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 00                	mov    (%eax),%eax
 696:	89 45 fc             	mov    %eax,-0x4(%ebp)
 699:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 69f:	76 d4                	jbe    675 <free+0x19>
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 00                	mov    (%eax),%eax
 6a6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6a9:	73 ca                	jae    675 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ae:	8b 40 04             	mov    0x4(%eax),%eax
 6b1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bb:	01 c2                	add    %eax,%edx
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	39 c2                	cmp    %eax,%edx
 6c4:	75 24                	jne    6ea <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c9:	8b 50 04             	mov    0x4(%eax),%edx
 6cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cf:	8b 00                	mov    (%eax),%eax
 6d1:	8b 40 04             	mov    0x4(%eax),%eax
 6d4:	01 c2                	add    %eax,%edx
 6d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6df:	8b 00                	mov    (%eax),%eax
 6e1:	8b 10                	mov    (%eax),%edx
 6e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e6:	89 10                	mov    %edx,(%eax)
 6e8:	eb 0a                	jmp    6f4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ed:	8b 10                	mov    (%eax),%edx
 6ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f7:	8b 40 04             	mov    0x4(%eax),%eax
 6fa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	01 d0                	add    %edx,%eax
 706:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 709:	75 20                	jne    72b <free+0xcf>
    p->s.size += bp->s.size;
 70b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70e:	8b 50 04             	mov    0x4(%eax),%edx
 711:	8b 45 f8             	mov    -0x8(%ebp),%eax
 714:	8b 40 04             	mov    0x4(%eax),%eax
 717:	01 c2                	add    %eax,%edx
 719:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 71f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 722:	8b 10                	mov    (%eax),%edx
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	89 10                	mov    %edx,(%eax)
 729:	eb 08                	jmp    733 <free+0xd7>
  } else
    p->s.ptr = bp;
 72b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 731:	89 10                	mov    %edx,(%eax)
  freep = p;
 733:	8b 45 fc             	mov    -0x4(%ebp),%eax
 736:	a3 80 0b 00 00       	mov    %eax,0xb80
}
 73b:	90                   	nop
 73c:	c9                   	leave  
 73d:	c3                   	ret    

0000073e <morecore>:

static Header*
morecore(uint nu)
{
 73e:	55                   	push   %ebp
 73f:	89 e5                	mov    %esp,%ebp
 741:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 744:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 74b:	77 07                	ja     754 <morecore+0x16>
    nu = 4096;
 74d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 754:	8b 45 08             	mov    0x8(%ebp),%eax
 757:	c1 e0 03             	shl    $0x3,%eax
 75a:	83 ec 0c             	sub    $0xc,%esp
 75d:	50                   	push   %eax
 75e:	e8 6b fc ff ff       	call   3ce <sbrk>
 763:	83 c4 10             	add    $0x10,%esp
 766:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 769:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 76d:	75 07                	jne    776 <morecore+0x38>
    return 0;
 76f:	b8 00 00 00 00       	mov    $0x0,%eax
 774:	eb 26                	jmp    79c <morecore+0x5e>
  hp = (Header*)p;
 776:	8b 45 f4             	mov    -0xc(%ebp),%eax
 779:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 77c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77f:	8b 55 08             	mov    0x8(%ebp),%edx
 782:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 785:	8b 45 f0             	mov    -0x10(%ebp),%eax
 788:	83 c0 08             	add    $0x8,%eax
 78b:	83 ec 0c             	sub    $0xc,%esp
 78e:	50                   	push   %eax
 78f:	e8 c8 fe ff ff       	call   65c <free>
 794:	83 c4 10             	add    $0x10,%esp
  return freep;
 797:	a1 80 0b 00 00       	mov    0xb80,%eax
}
 79c:	c9                   	leave  
 79d:	c3                   	ret    

0000079e <malloc>:

void*
malloc(uint nbytes)
{
 79e:	55                   	push   %ebp
 79f:	89 e5                	mov    %esp,%ebp
 7a1:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7a4:	8b 45 08             	mov    0x8(%ebp),%eax
 7a7:	83 c0 07             	add    $0x7,%eax
 7aa:	c1 e8 03             	shr    $0x3,%eax
 7ad:	83 c0 01             	add    $0x1,%eax
 7b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7b3:	a1 80 0b 00 00       	mov    0xb80,%eax
 7b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7bf:	75 23                	jne    7e4 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7c1:	c7 45 f0 78 0b 00 00 	movl   $0xb78,-0x10(%ebp)
 7c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cb:	a3 80 0b 00 00       	mov    %eax,0xb80
 7d0:	a1 80 0b 00 00       	mov    0xb80,%eax
 7d5:	a3 78 0b 00 00       	mov    %eax,0xb78
    base.s.size = 0;
 7da:	c7 05 7c 0b 00 00 00 	movl   $0x0,0xb7c
 7e1:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e7:	8b 00                	mov    (%eax),%eax
 7e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ef:	8b 40 04             	mov    0x4(%eax),%eax
 7f2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7f5:	77 4d                	ja     844 <malloc+0xa6>
      if(p->s.size == nunits)
 7f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fa:	8b 40 04             	mov    0x4(%eax),%eax
 7fd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 800:	75 0c                	jne    80e <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 802:	8b 45 f4             	mov    -0xc(%ebp),%eax
 805:	8b 10                	mov    (%eax),%edx
 807:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80a:	89 10                	mov    %edx,(%eax)
 80c:	eb 26                	jmp    834 <malloc+0x96>
      else {
        p->s.size -= nunits;
 80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 811:	8b 40 04             	mov    0x4(%eax),%eax
 814:	2b 45 ec             	sub    -0x14(%ebp),%eax
 817:	89 c2                	mov    %eax,%edx
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 822:	8b 40 04             	mov    0x4(%eax),%eax
 825:	c1 e0 03             	shl    $0x3,%eax
 828:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 82b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 831:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 834:	8b 45 f0             	mov    -0x10(%ebp),%eax
 837:	a3 80 0b 00 00       	mov    %eax,0xb80
      return (void*)(p + 1);
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	83 c0 08             	add    $0x8,%eax
 842:	eb 3b                	jmp    87f <malloc+0xe1>
    }
    if(p == freep)
 844:	a1 80 0b 00 00       	mov    0xb80,%eax
 849:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 84c:	75 1e                	jne    86c <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 84e:	83 ec 0c             	sub    $0xc,%esp
 851:	ff 75 ec             	push   -0x14(%ebp)
 854:	e8 e5 fe ff ff       	call   73e <morecore>
 859:	83 c4 10             	add    $0x10,%esp
 85c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 85f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 863:	75 07                	jne    86c <malloc+0xce>
        return 0;
 865:	b8 00 00 00 00       	mov    $0x0,%eax
 86a:	eb 13                	jmp    87f <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 872:	8b 45 f4             	mov    -0xc(%ebp),%eax
 875:	8b 00                	mov    (%eax),%eax
 877:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 87a:	e9 6d ff ff ff       	jmp    7ec <malloc+0x4e>
  }
}
 87f:	c9                   	leave  
 880:	c3                   	ret    
