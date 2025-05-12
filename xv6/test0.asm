
_test0:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
//그냥 mlfq 테스트 코드
//안돌아감
#include "types.h"
#include "user.h"

void workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  int i;
  volatile int x = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++)
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 29                	jmp    3f <workload+0x3f>
    x += i % 3;
  16:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  19:	ba 56 55 55 55       	mov    $0x55555556,%edx
  1e:	89 c8                	mov    %ecx,%eax
  20:	f7 ea                	imul   %edx
  22:	89 c8                	mov    %ecx,%eax
  24:	c1 f8 1f             	sar    $0x1f,%eax
  27:	29 c2                	sub    %eax,%edx
  29:	89 d0                	mov    %edx,%eax
  2b:	01 c0                	add    %eax,%eax
  2d:	01 d0                	add    %edx,%eax
  2f:	29 c1                	sub    %eax,%ecx
  31:	89 ca                	mov    %ecx,%edx
  33:	8b 45 f8             	mov    -0x8(%ebp),%eax
  36:	01 d0                	add    %edx,%eax
  38:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++)
  3b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  42:	3b 45 08             	cmp    0x8(%ebp),%eax
  45:	7c cf                	jl     16 <workload+0x16>
}
  47:	90                   	nop
  48:	90                   	nop
  49:	c9                   	leave  
  4a:	c3                   	ret    

0000004b <main>:

int main() {
  4b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  4f:	83 e4 f0             	and    $0xfffffff0,%esp
  52:	ff 71 fc             	push   -0x4(%ecx)
  55:	55                   	push   %ebp
  56:	89 e5                	mov    %esp,%ebp
  58:	51                   	push   %ecx
  59:	83 ec 14             	sub    $0x14,%esp
  setSchedPolicy(1); // policy 1: MLFQ
  5c:	83 ec 0c             	sub    $0xc,%esp
  5f:	6a 01                	push   $0x1
  61:	e8 6d 03 00 00       	call   3d3 <setSchedPolicy>
  66:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < 3; i++) {
  69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  70:	eb 47                	jmp    b9 <main+0x6e>
    int pid = fork();
  72:	e8 b4 02 00 00       	call   32b <fork>
  77:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid == 0) {
  7a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  7e:	75 35                	jne    b5 <main+0x6a>
      for (int j = 0; j < 100; j++) {
  80:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  87:	eb 21                	jmp    aa <main+0x5f>
        workload(10000000);
  89:	83 ec 0c             	sub    $0xc,%esp
  8c:	68 80 96 98 00       	push   $0x989680
  91:	e8 6a ff ff ff       	call   0 <workload>
  96:	83 c4 10             	add    $0x10,%esp
        sleep(1);
  99:	83 ec 0c             	sub    $0xc,%esp
  9c:	6a 01                	push   $0x1
  9e:	e8 20 03 00 00       	call   3c3 <sleep>
  a3:	83 c4 10             	add    $0x10,%esp
      for (int j = 0; j < 100; j++) {
  a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  aa:	83 7d f0 63          	cmpl   $0x63,-0x10(%ebp)
  ae:	7e d9                	jle    89 <main+0x3e>
      }
      exit();
  b0:	e8 7e 02 00 00       	call   333 <exit>
  for (int i = 0; i < 3; i++) {
  b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  b9:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  bd:	7e b3                	jle    72 <main+0x27>
    }
  }

  for (int i = 0; i < 3; i++)
  bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  c6:	eb 09                	jmp    d1 <main+0x86>
    wait();
  c8:	e8 6e 02 00 00       	call   33b <wait>
  for (int i = 0; i < 3; i++)
  cd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  d1:	83 7d ec 02          	cmpl   $0x2,-0x14(%ebp)
  d5:	7e f1                	jle    c8 <main+0x7d>

  exit();
  d7:	e8 57 02 00 00       	call   333 <exit>

000000dc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  dc:	55                   	push   %ebp
  dd:	89 e5                	mov    %esp,%ebp
  df:	57                   	push   %edi
  e0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  e4:	8b 55 10             	mov    0x10(%ebp),%edx
  e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  ea:	89 cb                	mov    %ecx,%ebx
  ec:	89 df                	mov    %ebx,%edi
  ee:	89 d1                	mov    %edx,%ecx
  f0:	fc                   	cld    
  f1:	f3 aa                	rep stos %al,%es:(%edi)
  f3:	89 ca                	mov    %ecx,%edx
  f5:	89 fb                	mov    %edi,%ebx
  f7:	89 5d 08             	mov    %ebx,0x8(%ebp)
  fa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  fd:	90                   	nop
  fe:	5b                   	pop    %ebx
  ff:	5f                   	pop    %edi
 100:	5d                   	pop    %ebp
 101:	c3                   	ret    

00000102 <strcpy>:



char*
strcpy(char *s, char *t)
{
 102:	55                   	push   %ebp
 103:	89 e5                	mov    %esp,%ebp
 105:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 10e:	90                   	nop
 10f:	8b 55 0c             	mov    0xc(%ebp),%edx
 112:	8d 42 01             	lea    0x1(%edx),%eax
 115:	89 45 0c             	mov    %eax,0xc(%ebp)
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	8d 48 01             	lea    0x1(%eax),%ecx
 11e:	89 4d 08             	mov    %ecx,0x8(%ebp)
 121:	0f b6 12             	movzbl (%edx),%edx
 124:	88 10                	mov    %dl,(%eax)
 126:	0f b6 00             	movzbl (%eax),%eax
 129:	84 c0                	test   %al,%al
 12b:	75 e2                	jne    10f <strcpy+0xd>
    ;
  return os;
 12d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 130:	c9                   	leave  
 131:	c3                   	ret    

00000132 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 132:	55                   	push   %ebp
 133:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 135:	eb 08                	jmp    13f <strcmp+0xd>
    p++, q++;
 137:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 13b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	0f b6 00             	movzbl (%eax),%eax
 145:	84 c0                	test   %al,%al
 147:	74 10                	je     159 <strcmp+0x27>
 149:	8b 45 08             	mov    0x8(%ebp),%eax
 14c:	0f b6 10             	movzbl (%eax),%edx
 14f:	8b 45 0c             	mov    0xc(%ebp),%eax
 152:	0f b6 00             	movzbl (%eax),%eax
 155:	38 c2                	cmp    %al,%dl
 157:	74 de                	je     137 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	0f b6 00             	movzbl (%eax),%eax
 15f:	0f b6 d0             	movzbl %al,%edx
 162:	8b 45 0c             	mov    0xc(%ebp),%eax
 165:	0f b6 00             	movzbl (%eax),%eax
 168:	0f b6 c8             	movzbl %al,%ecx
 16b:	89 d0                	mov    %edx,%eax
 16d:	29 c8                	sub    %ecx,%eax
}
 16f:	5d                   	pop    %ebp
 170:	c3                   	ret    

00000171 <strlen>:

uint
strlen(char *s)
{
 171:	55                   	push   %ebp
 172:	89 e5                	mov    %esp,%ebp
 174:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 177:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 17e:	eb 04                	jmp    184 <strlen+0x13>
 180:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 184:	8b 55 fc             	mov    -0x4(%ebp),%edx
 187:	8b 45 08             	mov    0x8(%ebp),%eax
 18a:	01 d0                	add    %edx,%eax
 18c:	0f b6 00             	movzbl (%eax),%eax
 18f:	84 c0                	test   %al,%al
 191:	75 ed                	jne    180 <strlen+0xf>
    ;
  return n;
 193:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 196:	c9                   	leave  
 197:	c3                   	ret    

00000198 <memset>:

void*
memset(void *dst, int c, uint n)
{
 198:	55                   	push   %ebp
 199:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 19b:	8b 45 10             	mov    0x10(%ebp),%eax
 19e:	50                   	push   %eax
 19f:	ff 75 0c             	push   0xc(%ebp)
 1a2:	ff 75 08             	push   0x8(%ebp)
 1a5:	e8 32 ff ff ff       	call   dc <stosb>
 1aa:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1b0:	c9                   	leave  
 1b1:	c3                   	ret    

000001b2 <strchr>:

char*
strchr(const char *s, char c)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	83 ec 04             	sub    $0x4,%esp
 1b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bb:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1be:	eb 14                	jmp    1d4 <strchr+0x22>
    if(*s == c)
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	0f b6 00             	movzbl (%eax),%eax
 1c6:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1c9:	75 05                	jne    1d0 <strchr+0x1e>
      return (char*)s;
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ce:	eb 13                	jmp    1e3 <strchr+0x31>
  for(; *s; s++)
 1d0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	0f b6 00             	movzbl (%eax),%eax
 1da:	84 c0                	test   %al,%al
 1dc:	75 e2                	jne    1c0 <strchr+0xe>
  return 0;
 1de:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1e3:	c9                   	leave  
 1e4:	c3                   	ret    

000001e5 <gets>:

char*
gets(char *buf, int max)
{
 1e5:	55                   	push   %ebp
 1e6:	89 e5                	mov    %esp,%ebp
 1e8:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1f2:	eb 42                	jmp    236 <gets+0x51>
    cc = read(0, &c, 1);
 1f4:	83 ec 04             	sub    $0x4,%esp
 1f7:	6a 01                	push   $0x1
 1f9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1fc:	50                   	push   %eax
 1fd:	6a 00                	push   $0x0
 1ff:	e8 47 01 00 00       	call   34b <read>
 204:	83 c4 10             	add    $0x10,%esp
 207:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 20a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 20e:	7e 33                	jle    243 <gets+0x5e>
      break;
    buf[i++] = c;
 210:	8b 45 f4             	mov    -0xc(%ebp),%eax
 213:	8d 50 01             	lea    0x1(%eax),%edx
 216:	89 55 f4             	mov    %edx,-0xc(%ebp)
 219:	89 c2                	mov    %eax,%edx
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	01 c2                	add    %eax,%edx
 220:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 224:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 226:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 22a:	3c 0a                	cmp    $0xa,%al
 22c:	74 16                	je     244 <gets+0x5f>
 22e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 232:	3c 0d                	cmp    $0xd,%al
 234:	74 0e                	je     244 <gets+0x5f>
  for(i=0; i+1 < max; ){
 236:	8b 45 f4             	mov    -0xc(%ebp),%eax
 239:	83 c0 01             	add    $0x1,%eax
 23c:	39 45 0c             	cmp    %eax,0xc(%ebp)
 23f:	7f b3                	jg     1f4 <gets+0xf>
 241:	eb 01                	jmp    244 <gets+0x5f>
      break;
 243:	90                   	nop
      break;
  }
  buf[i] = '\0';
 244:	8b 55 f4             	mov    -0xc(%ebp),%edx
 247:	8b 45 08             	mov    0x8(%ebp),%eax
 24a:	01 d0                	add    %edx,%eax
 24c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 24f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 252:	c9                   	leave  
 253:	c3                   	ret    

00000254 <stat>:

int
stat(char *n, struct stat *st)
{
 254:	55                   	push   %ebp
 255:	89 e5                	mov    %esp,%ebp
 257:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25a:	83 ec 08             	sub    $0x8,%esp
 25d:	6a 00                	push   $0x0
 25f:	ff 75 08             	push   0x8(%ebp)
 262:	e8 0c 01 00 00       	call   373 <open>
 267:	83 c4 10             	add    $0x10,%esp
 26a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 26d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 271:	79 07                	jns    27a <stat+0x26>
    return -1;
 273:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 278:	eb 25                	jmp    29f <stat+0x4b>
  r = fstat(fd, st);
 27a:	83 ec 08             	sub    $0x8,%esp
 27d:	ff 75 0c             	push   0xc(%ebp)
 280:	ff 75 f4             	push   -0xc(%ebp)
 283:	e8 03 01 00 00       	call   38b <fstat>
 288:	83 c4 10             	add    $0x10,%esp
 28b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 28e:	83 ec 0c             	sub    $0xc,%esp
 291:	ff 75 f4             	push   -0xc(%ebp)
 294:	e8 c2 00 00 00       	call   35b <close>
 299:	83 c4 10             	add    $0x10,%esp
  return r;
 29c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 29f:	c9                   	leave  
 2a0:	c3                   	ret    

000002a1 <atoi>:

int
atoi(const char *s)
{
 2a1:	55                   	push   %ebp
 2a2:	89 e5                	mov    %esp,%ebp
 2a4:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2a7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2ae:	eb 25                	jmp    2d5 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2b3:	89 d0                	mov    %edx,%eax
 2b5:	c1 e0 02             	shl    $0x2,%eax
 2b8:	01 d0                	add    %edx,%eax
 2ba:	01 c0                	add    %eax,%eax
 2bc:	89 c1                	mov    %eax,%ecx
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
 2c1:	8d 50 01             	lea    0x1(%eax),%edx
 2c4:	89 55 08             	mov    %edx,0x8(%ebp)
 2c7:	0f b6 00             	movzbl (%eax),%eax
 2ca:	0f be c0             	movsbl %al,%eax
 2cd:	01 c8                	add    %ecx,%eax
 2cf:	83 e8 30             	sub    $0x30,%eax
 2d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
 2d8:	0f b6 00             	movzbl (%eax),%eax
 2db:	3c 2f                	cmp    $0x2f,%al
 2dd:	7e 0a                	jle    2e9 <atoi+0x48>
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	0f b6 00             	movzbl (%eax),%eax
 2e5:	3c 39                	cmp    $0x39,%al
 2e7:	7e c7                	jle    2b0 <atoi+0xf>
  return n;
 2e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ec:	c9                   	leave  
 2ed:	c3                   	ret    

000002ee <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2ee:	55                   	push   %ebp
 2ef:	89 e5                	mov    %esp,%ebp
 2f1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 2fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 300:	eb 17                	jmp    319 <memmove+0x2b>
    *dst++ = *src++;
 302:	8b 55 f8             	mov    -0x8(%ebp),%edx
 305:	8d 42 01             	lea    0x1(%edx),%eax
 308:	89 45 f8             	mov    %eax,-0x8(%ebp)
 30b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 30e:	8d 48 01             	lea    0x1(%eax),%ecx
 311:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 314:	0f b6 12             	movzbl (%edx),%edx
 317:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 319:	8b 45 10             	mov    0x10(%ebp),%eax
 31c:	8d 50 ff             	lea    -0x1(%eax),%edx
 31f:	89 55 10             	mov    %edx,0x10(%ebp)
 322:	85 c0                	test   %eax,%eax
 324:	7f dc                	jg     302 <memmove+0x14>
  return vdst;
 326:	8b 45 08             	mov    0x8(%ebp),%eax
}
 329:	c9                   	leave  
 32a:	c3                   	ret    

0000032b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 32b:	b8 01 00 00 00       	mov    $0x1,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <exit>:
SYSCALL(exit)
 333:	b8 02 00 00 00       	mov    $0x2,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <wait>:
SYSCALL(wait)
 33b:	b8 03 00 00 00       	mov    $0x3,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <pipe>:
SYSCALL(pipe)
 343:	b8 04 00 00 00       	mov    $0x4,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <read>:
SYSCALL(read)
 34b:	b8 05 00 00 00       	mov    $0x5,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <write>:
SYSCALL(write)
 353:	b8 10 00 00 00       	mov    $0x10,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <close>:
SYSCALL(close)
 35b:	b8 15 00 00 00       	mov    $0x15,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <kill>:
SYSCALL(kill)
 363:	b8 06 00 00 00       	mov    $0x6,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <exec>:
SYSCALL(exec)
 36b:	b8 07 00 00 00       	mov    $0x7,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <open>:
SYSCALL(open)
 373:	b8 0f 00 00 00       	mov    $0xf,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <mknod>:
SYSCALL(mknod)
 37b:	b8 11 00 00 00       	mov    $0x11,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <unlink>:
SYSCALL(unlink)
 383:	b8 12 00 00 00       	mov    $0x12,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <fstat>:
SYSCALL(fstat)
 38b:	b8 08 00 00 00       	mov    $0x8,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <link>:
SYSCALL(link)
 393:	b8 13 00 00 00       	mov    $0x13,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret    

0000039b <mkdir>:
SYSCALL(mkdir)
 39b:	b8 14 00 00 00       	mov    $0x14,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret    

000003a3 <chdir>:
SYSCALL(chdir)
 3a3:	b8 09 00 00 00       	mov    $0x9,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	ret    

000003ab <dup>:
SYSCALL(dup)
 3ab:	b8 0a 00 00 00       	mov    $0xa,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	ret    

000003b3 <getpid>:
SYSCALL(getpid)
 3b3:	b8 0b 00 00 00       	mov    $0xb,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	ret    

000003bb <sbrk>:
SYSCALL(sbrk)
 3bb:	b8 0c 00 00 00       	mov    $0xc,%eax
 3c0:	cd 40                	int    $0x40
 3c2:	c3                   	ret    

000003c3 <sleep>:
SYSCALL(sleep)
 3c3:	b8 0d 00 00 00       	mov    $0xd,%eax
 3c8:	cd 40                	int    $0x40
 3ca:	c3                   	ret    

000003cb <uptime>:
SYSCALL(uptime)
 3cb:	b8 0e 00 00 00       	mov    $0xe,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	ret    

000003d3 <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 3d3:	b8 16 00 00 00       	mov    $0x16,%eax
 3d8:	cd 40                	int    $0x40
 3da:	c3                   	ret    

000003db <getpinfo>:
SYSCALL(getpinfo)
 3db:	b8 17 00 00 00       	mov    $0x17,%eax
 3e0:	cd 40                	int    $0x40
 3e2:	c3                   	ret    

000003e3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3e3:	55                   	push   %ebp
 3e4:	89 e5                	mov    %esp,%ebp
 3e6:	83 ec 18             	sub    $0x18,%esp
 3e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ec:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3ef:	83 ec 04             	sub    $0x4,%esp
 3f2:	6a 01                	push   $0x1
 3f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3f7:	50                   	push   %eax
 3f8:	ff 75 08             	push   0x8(%ebp)
 3fb:	e8 53 ff ff ff       	call   353 <write>
 400:	83 c4 10             	add    $0x10,%esp
}
 403:	90                   	nop
 404:	c9                   	leave  
 405:	c3                   	ret    

00000406 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 406:	55                   	push   %ebp
 407:	89 e5                	mov    %esp,%ebp
 409:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 40c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 413:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 417:	74 17                	je     430 <printint+0x2a>
 419:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 41d:	79 11                	jns    430 <printint+0x2a>
    neg = 1;
 41f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 426:	8b 45 0c             	mov    0xc(%ebp),%eax
 429:	f7 d8                	neg    %eax
 42b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 42e:	eb 06                	jmp    436 <printint+0x30>
  } else {
    x = xx;
 430:	8b 45 0c             	mov    0xc(%ebp),%eax
 433:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 436:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 43d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 440:	8b 45 ec             	mov    -0x14(%ebp),%eax
 443:	ba 00 00 00 00       	mov    $0x0,%edx
 448:	f7 f1                	div    %ecx
 44a:	89 d1                	mov    %edx,%ecx
 44c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44f:	8d 50 01             	lea    0x1(%eax),%edx
 452:	89 55 f4             	mov    %edx,-0xc(%ebp)
 455:	0f b6 91 dc 0a 00 00 	movzbl 0xadc(%ecx),%edx
 45c:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 460:	8b 4d 10             	mov    0x10(%ebp),%ecx
 463:	8b 45 ec             	mov    -0x14(%ebp),%eax
 466:	ba 00 00 00 00       	mov    $0x0,%edx
 46b:	f7 f1                	div    %ecx
 46d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 470:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 474:	75 c7                	jne    43d <printint+0x37>
  if(neg)
 476:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 47a:	74 2d                	je     4a9 <printint+0xa3>
    buf[i++] = '-';
 47c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47f:	8d 50 01             	lea    0x1(%eax),%edx
 482:	89 55 f4             	mov    %edx,-0xc(%ebp)
 485:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 48a:	eb 1d                	jmp    4a9 <printint+0xa3>
    putc(fd, buf[i]);
 48c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 48f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 492:	01 d0                	add    %edx,%eax
 494:	0f b6 00             	movzbl (%eax),%eax
 497:	0f be c0             	movsbl %al,%eax
 49a:	83 ec 08             	sub    $0x8,%esp
 49d:	50                   	push   %eax
 49e:	ff 75 08             	push   0x8(%ebp)
 4a1:	e8 3d ff ff ff       	call   3e3 <putc>
 4a6:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4a9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4b1:	79 d9                	jns    48c <printint+0x86>
}
 4b3:	90                   	nop
 4b4:	90                   	nop
 4b5:	c9                   	leave  
 4b6:	c3                   	ret    

000004b7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4b7:	55                   	push   %ebp
 4b8:	89 e5                	mov    %esp,%ebp
 4ba:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4bd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4c4:	8d 45 0c             	lea    0xc(%ebp),%eax
 4c7:	83 c0 04             	add    $0x4,%eax
 4ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4d4:	e9 59 01 00 00       	jmp    632 <printf+0x17b>
    c = fmt[i] & 0xff;
 4d9:	8b 55 0c             	mov    0xc(%ebp),%edx
 4dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4df:	01 d0                	add    %edx,%eax
 4e1:	0f b6 00             	movzbl (%eax),%eax
 4e4:	0f be c0             	movsbl %al,%eax
 4e7:	25 ff 00 00 00       	and    $0xff,%eax
 4ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4ef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f3:	75 2c                	jne    521 <printf+0x6a>
      if(c == '%'){
 4f5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4f9:	75 0c                	jne    507 <printf+0x50>
        state = '%';
 4fb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 502:	e9 27 01 00 00       	jmp    62e <printf+0x177>
      } else {
        putc(fd, c);
 507:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 50a:	0f be c0             	movsbl %al,%eax
 50d:	83 ec 08             	sub    $0x8,%esp
 510:	50                   	push   %eax
 511:	ff 75 08             	push   0x8(%ebp)
 514:	e8 ca fe ff ff       	call   3e3 <putc>
 519:	83 c4 10             	add    $0x10,%esp
 51c:	e9 0d 01 00 00       	jmp    62e <printf+0x177>
      }
    } else if(state == '%'){
 521:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 525:	0f 85 03 01 00 00    	jne    62e <printf+0x177>
      if(c == 'd'){
 52b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 52f:	75 1e                	jne    54f <printf+0x98>
        printint(fd, *ap, 10, 1);
 531:	8b 45 e8             	mov    -0x18(%ebp),%eax
 534:	8b 00                	mov    (%eax),%eax
 536:	6a 01                	push   $0x1
 538:	6a 0a                	push   $0xa
 53a:	50                   	push   %eax
 53b:	ff 75 08             	push   0x8(%ebp)
 53e:	e8 c3 fe ff ff       	call   406 <printint>
 543:	83 c4 10             	add    $0x10,%esp
        ap++;
 546:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54a:	e9 d8 00 00 00       	jmp    627 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 54f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 553:	74 06                	je     55b <printf+0xa4>
 555:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 559:	75 1e                	jne    579 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 55b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55e:	8b 00                	mov    (%eax),%eax
 560:	6a 00                	push   $0x0
 562:	6a 10                	push   $0x10
 564:	50                   	push   %eax
 565:	ff 75 08             	push   0x8(%ebp)
 568:	e8 99 fe ff ff       	call   406 <printint>
 56d:	83 c4 10             	add    $0x10,%esp
        ap++;
 570:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 574:	e9 ae 00 00 00       	jmp    627 <printf+0x170>
      } else if(c == 's'){
 579:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 57d:	75 43                	jne    5c2 <printf+0x10b>
        s = (char*)*ap;
 57f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 582:	8b 00                	mov    (%eax),%eax
 584:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 587:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 58b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 58f:	75 25                	jne    5b6 <printf+0xff>
          s = "(null)";
 591:	c7 45 f4 6e 08 00 00 	movl   $0x86e,-0xc(%ebp)
        while(*s != 0){
 598:	eb 1c                	jmp    5b6 <printf+0xff>
          putc(fd, *s);
 59a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59d:	0f b6 00             	movzbl (%eax),%eax
 5a0:	0f be c0             	movsbl %al,%eax
 5a3:	83 ec 08             	sub    $0x8,%esp
 5a6:	50                   	push   %eax
 5a7:	ff 75 08             	push   0x8(%ebp)
 5aa:	e8 34 fe ff ff       	call   3e3 <putc>
 5af:	83 c4 10             	add    $0x10,%esp
          s++;
 5b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b9:	0f b6 00             	movzbl (%eax),%eax
 5bc:	84 c0                	test   %al,%al
 5be:	75 da                	jne    59a <printf+0xe3>
 5c0:	eb 65                	jmp    627 <printf+0x170>
        }
      } else if(c == 'c'){
 5c2:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5c6:	75 1d                	jne    5e5 <printf+0x12e>
        putc(fd, *ap);
 5c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5cb:	8b 00                	mov    (%eax),%eax
 5cd:	0f be c0             	movsbl %al,%eax
 5d0:	83 ec 08             	sub    $0x8,%esp
 5d3:	50                   	push   %eax
 5d4:	ff 75 08             	push   0x8(%ebp)
 5d7:	e8 07 fe ff ff       	call   3e3 <putc>
 5dc:	83 c4 10             	add    $0x10,%esp
        ap++;
 5df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e3:	eb 42                	jmp    627 <printf+0x170>
      } else if(c == '%'){
 5e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5e9:	75 17                	jne    602 <printf+0x14b>
        putc(fd, c);
 5eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ee:	0f be c0             	movsbl %al,%eax
 5f1:	83 ec 08             	sub    $0x8,%esp
 5f4:	50                   	push   %eax
 5f5:	ff 75 08             	push   0x8(%ebp)
 5f8:	e8 e6 fd ff ff       	call   3e3 <putc>
 5fd:	83 c4 10             	add    $0x10,%esp
 600:	eb 25                	jmp    627 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 602:	83 ec 08             	sub    $0x8,%esp
 605:	6a 25                	push   $0x25
 607:	ff 75 08             	push   0x8(%ebp)
 60a:	e8 d4 fd ff ff       	call   3e3 <putc>
 60f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 615:	0f be c0             	movsbl %al,%eax
 618:	83 ec 08             	sub    $0x8,%esp
 61b:	50                   	push   %eax
 61c:	ff 75 08             	push   0x8(%ebp)
 61f:	e8 bf fd ff ff       	call   3e3 <putc>
 624:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 627:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 62e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 632:	8b 55 0c             	mov    0xc(%ebp),%edx
 635:	8b 45 f0             	mov    -0x10(%ebp),%eax
 638:	01 d0                	add    %edx,%eax
 63a:	0f b6 00             	movzbl (%eax),%eax
 63d:	84 c0                	test   %al,%al
 63f:	0f 85 94 fe ff ff    	jne    4d9 <printf+0x22>
    }
  }
}
 645:	90                   	nop
 646:	90                   	nop
 647:	c9                   	leave  
 648:	c3                   	ret    

00000649 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 649:	55                   	push   %ebp
 64a:	89 e5                	mov    %esp,%ebp
 64c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 64f:	8b 45 08             	mov    0x8(%ebp),%eax
 652:	83 e8 08             	sub    $0x8,%eax
 655:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 658:	a1 f8 0a 00 00       	mov    0xaf8,%eax
 65d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 660:	eb 24                	jmp    686 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 662:	8b 45 fc             	mov    -0x4(%ebp),%eax
 665:	8b 00                	mov    (%eax),%eax
 667:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 66a:	72 12                	jb     67e <free+0x35>
 66c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 672:	77 24                	ja     698 <free+0x4f>
 674:	8b 45 fc             	mov    -0x4(%ebp),%eax
 677:	8b 00                	mov    (%eax),%eax
 679:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 67c:	72 1a                	jb     698 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 67e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 681:	8b 00                	mov    (%eax),%eax
 683:	89 45 fc             	mov    %eax,-0x4(%ebp)
 686:	8b 45 f8             	mov    -0x8(%ebp),%eax
 689:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 68c:	76 d4                	jbe    662 <free+0x19>
 68e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 691:	8b 00                	mov    (%eax),%eax
 693:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 696:	73 ca                	jae    662 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 698:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69b:	8b 40 04             	mov    0x4(%eax),%eax
 69e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a8:	01 c2                	add    %eax,%edx
 6aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ad:	8b 00                	mov    (%eax),%eax
 6af:	39 c2                	cmp    %eax,%edx
 6b1:	75 24                	jne    6d7 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b6:	8b 50 04             	mov    0x4(%eax),%edx
 6b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bc:	8b 00                	mov    (%eax),%eax
 6be:	8b 40 04             	mov    0x4(%eax),%eax
 6c1:	01 c2                	add    %eax,%edx
 6c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c6:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 00                	mov    (%eax),%eax
 6ce:	8b 10                	mov    (%eax),%edx
 6d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d3:	89 10                	mov    %edx,(%eax)
 6d5:	eb 0a                	jmp    6e1 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6da:	8b 10                	mov    (%eax),%edx
 6dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6df:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	8b 40 04             	mov    0x4(%eax),%eax
 6e7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f1:	01 d0                	add    %edx,%eax
 6f3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6f6:	75 20                	jne    718 <free+0xcf>
    p->s.size += bp->s.size;
 6f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fb:	8b 50 04             	mov    0x4(%eax),%edx
 6fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 701:	8b 40 04             	mov    0x4(%eax),%eax
 704:	01 c2                	add    %eax,%edx
 706:	8b 45 fc             	mov    -0x4(%ebp),%eax
 709:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 70c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70f:	8b 10                	mov    (%eax),%edx
 711:	8b 45 fc             	mov    -0x4(%ebp),%eax
 714:	89 10                	mov    %edx,(%eax)
 716:	eb 08                	jmp    720 <free+0xd7>
  } else
    p->s.ptr = bp;
 718:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 71e:	89 10                	mov    %edx,(%eax)
  freep = p;
 720:	8b 45 fc             	mov    -0x4(%ebp),%eax
 723:	a3 f8 0a 00 00       	mov    %eax,0xaf8
}
 728:	90                   	nop
 729:	c9                   	leave  
 72a:	c3                   	ret    

0000072b <morecore>:

static Header*
morecore(uint nu)
{
 72b:	55                   	push   %ebp
 72c:	89 e5                	mov    %esp,%ebp
 72e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 731:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 738:	77 07                	ja     741 <morecore+0x16>
    nu = 4096;
 73a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 741:	8b 45 08             	mov    0x8(%ebp),%eax
 744:	c1 e0 03             	shl    $0x3,%eax
 747:	83 ec 0c             	sub    $0xc,%esp
 74a:	50                   	push   %eax
 74b:	e8 6b fc ff ff       	call   3bb <sbrk>
 750:	83 c4 10             	add    $0x10,%esp
 753:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 756:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 75a:	75 07                	jne    763 <morecore+0x38>
    return 0;
 75c:	b8 00 00 00 00       	mov    $0x0,%eax
 761:	eb 26                	jmp    789 <morecore+0x5e>
  hp = (Header*)p;
 763:	8b 45 f4             	mov    -0xc(%ebp),%eax
 766:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 769:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76c:	8b 55 08             	mov    0x8(%ebp),%edx
 76f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 772:	8b 45 f0             	mov    -0x10(%ebp),%eax
 775:	83 c0 08             	add    $0x8,%eax
 778:	83 ec 0c             	sub    $0xc,%esp
 77b:	50                   	push   %eax
 77c:	e8 c8 fe ff ff       	call   649 <free>
 781:	83 c4 10             	add    $0x10,%esp
  return freep;
 784:	a1 f8 0a 00 00       	mov    0xaf8,%eax
}
 789:	c9                   	leave  
 78a:	c3                   	ret    

0000078b <malloc>:

void*
malloc(uint nbytes)
{
 78b:	55                   	push   %ebp
 78c:	89 e5                	mov    %esp,%ebp
 78e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 791:	8b 45 08             	mov    0x8(%ebp),%eax
 794:	83 c0 07             	add    $0x7,%eax
 797:	c1 e8 03             	shr    $0x3,%eax
 79a:	83 c0 01             	add    $0x1,%eax
 79d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7a0:	a1 f8 0a 00 00       	mov    0xaf8,%eax
 7a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7ac:	75 23                	jne    7d1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7ae:	c7 45 f0 f0 0a 00 00 	movl   $0xaf0,-0x10(%ebp)
 7b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b8:	a3 f8 0a 00 00       	mov    %eax,0xaf8
 7bd:	a1 f8 0a 00 00       	mov    0xaf8,%eax
 7c2:	a3 f0 0a 00 00       	mov    %eax,0xaf0
    base.s.size = 0;
 7c7:	c7 05 f4 0a 00 00 00 	movl   $0x0,0xaf4
 7ce:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	8b 40 04             	mov    0x4(%eax),%eax
 7df:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7e2:	77 4d                	ja     831 <malloc+0xa6>
      if(p->s.size == nunits)
 7e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e7:	8b 40 04             	mov    0x4(%eax),%eax
 7ea:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7ed:	75 0c                	jne    7fb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f2:	8b 10                	mov    (%eax),%edx
 7f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f7:	89 10                	mov    %edx,(%eax)
 7f9:	eb 26                	jmp    821 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	8b 40 04             	mov    0x4(%eax),%eax
 801:	2b 45 ec             	sub    -0x14(%ebp),%eax
 804:	89 c2                	mov    %eax,%edx
 806:	8b 45 f4             	mov    -0xc(%ebp),%eax
 809:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 80c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80f:	8b 40 04             	mov    0x4(%eax),%eax
 812:	c1 e0 03             	shl    $0x3,%eax
 815:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 818:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 81e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 821:	8b 45 f0             	mov    -0x10(%ebp),%eax
 824:	a3 f8 0a 00 00       	mov    %eax,0xaf8
      return (void*)(p + 1);
 829:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82c:	83 c0 08             	add    $0x8,%eax
 82f:	eb 3b                	jmp    86c <malloc+0xe1>
    }
    if(p == freep)
 831:	a1 f8 0a 00 00       	mov    0xaf8,%eax
 836:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 839:	75 1e                	jne    859 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 83b:	83 ec 0c             	sub    $0xc,%esp
 83e:	ff 75 ec             	push   -0x14(%ebp)
 841:	e8 e5 fe ff ff       	call   72b <morecore>
 846:	83 c4 10             	add    $0x10,%esp
 849:	89 45 f4             	mov    %eax,-0xc(%ebp)
 84c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 850:	75 07                	jne    859 <malloc+0xce>
        return 0;
 852:	b8 00 00 00 00       	mov    $0x0,%eax
 857:	eb 13                	jmp    86c <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 859:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	8b 00                	mov    (%eax),%eax
 864:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 867:	e9 6d ff ff ff       	jmp    7d9 <malloc+0x4e>
  }
}
 86c:	c9                   	leave  
 86d:	c3                   	ret    
