
_userpolicytest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int main() {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  printf(1, "Setting scheduling policy to MLFQ (1)\n");
  11:	83 ec 08             	sub    $0x8,%esp
  14:	68 f8 07 00 00       	push   $0x7f8
  19:	6a 01                	push   $0x1
  1b:	e8 1f 04 00 00       	call   43f <printf>
  20:	83 c4 10             	add    $0x10,%esp
  int res = setSchedPolicy(1);
  23:	83 ec 0c             	sub    $0xc,%esp
  26:	6a 01                	push   $0x1
  28:	e8 2e 03 00 00       	call   35b <setSchedPolicy>
  2d:	83 c4 10             	add    $0x10,%esp
  30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (res == 0) {
  33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  37:	75 14                	jne    4d <main+0x4d>
    printf(1, "setSchedPolicy 성공!\n");
  39:	83 ec 08             	sub    $0x8,%esp
  3c:	68 1f 08 00 00       	push   $0x81f
  41:	6a 01                	push   $0x1
  43:	e8 f7 03 00 00       	call   43f <printf>
  48:	83 c4 10             	add    $0x10,%esp
  4b:	eb 12                	jmp    5f <main+0x5f>
  } else {
    printf(1, "setSchedPolicy 실패...\n");
  4d:	83 ec 08             	sub    $0x8,%esp
  50:	68 37 08 00 00       	push   $0x837
  55:	6a 01                	push   $0x1
  57:	e8 e3 03 00 00       	call   43f <printf>
  5c:	83 c4 10             	add    $0x10,%esp
  }
  exit();
  5f:	e8 57 02 00 00       	call   2bb <exit>

00000064 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  64:	55                   	push   %ebp
  65:	89 e5                	mov    %esp,%ebp
  67:	57                   	push   %edi
  68:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  6c:	8b 55 10             	mov    0x10(%ebp),%edx
  6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  72:	89 cb                	mov    %ecx,%ebx
  74:	89 df                	mov    %ebx,%edi
  76:	89 d1                	mov    %edx,%ecx
  78:	fc                   	cld    
  79:	f3 aa                	rep stos %al,%es:(%edi)
  7b:	89 ca                	mov    %ecx,%edx
  7d:	89 fb                	mov    %edi,%ebx
  7f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  82:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  85:	90                   	nop
  86:	5b                   	pop    %ebx
  87:	5f                   	pop    %edi
  88:	5d                   	pop    %ebp
  89:	c3                   	ret    

0000008a <strcpy>:



char*
strcpy(char *s, char *t)
{
  8a:	55                   	push   %ebp
  8b:	89 e5                	mov    %esp,%ebp
  8d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  90:	8b 45 08             	mov    0x8(%ebp),%eax
  93:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  96:	90                   	nop
  97:	8b 55 0c             	mov    0xc(%ebp),%edx
  9a:	8d 42 01             	lea    0x1(%edx),%eax
  9d:	89 45 0c             	mov    %eax,0xc(%ebp)
  a0:	8b 45 08             	mov    0x8(%ebp),%eax
  a3:	8d 48 01             	lea    0x1(%eax),%ecx
  a6:	89 4d 08             	mov    %ecx,0x8(%ebp)
  a9:	0f b6 12             	movzbl (%edx),%edx
  ac:	88 10                	mov    %dl,(%eax)
  ae:	0f b6 00             	movzbl (%eax),%eax
  b1:	84 c0                	test   %al,%al
  b3:	75 e2                	jne    97 <strcpy+0xd>
    ;
  return os;
  b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  b8:	c9                   	leave  
  b9:	c3                   	ret    

000000ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ba:	55                   	push   %ebp
  bb:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  bd:	eb 08                	jmp    c7 <strcmp+0xd>
    p++, q++;
  bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  c3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  c7:	8b 45 08             	mov    0x8(%ebp),%eax
  ca:	0f b6 00             	movzbl (%eax),%eax
  cd:	84 c0                	test   %al,%al
  cf:	74 10                	je     e1 <strcmp+0x27>
  d1:	8b 45 08             	mov    0x8(%ebp),%eax
  d4:	0f b6 10             	movzbl (%eax),%edx
  d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  da:	0f b6 00             	movzbl (%eax),%eax
  dd:	38 c2                	cmp    %al,%dl
  df:	74 de                	je     bf <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  e1:	8b 45 08             	mov    0x8(%ebp),%eax
  e4:	0f b6 00             	movzbl (%eax),%eax
  e7:	0f b6 d0             	movzbl %al,%edx
  ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  ed:	0f b6 00             	movzbl (%eax),%eax
  f0:	0f b6 c8             	movzbl %al,%ecx
  f3:	89 d0                	mov    %edx,%eax
  f5:	29 c8                	sub    %ecx,%eax
}
  f7:	5d                   	pop    %ebp
  f8:	c3                   	ret    

000000f9 <strlen>:

uint
strlen(char *s)
{
  f9:	55                   	push   %ebp
  fa:	89 e5                	mov    %esp,%ebp
  fc:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 106:	eb 04                	jmp    10c <strlen+0x13>
 108:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 10c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 10f:	8b 45 08             	mov    0x8(%ebp),%eax
 112:	01 d0                	add    %edx,%eax
 114:	0f b6 00             	movzbl (%eax),%eax
 117:	84 c0                	test   %al,%al
 119:	75 ed                	jne    108 <strlen+0xf>
    ;
  return n;
 11b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 11e:	c9                   	leave  
 11f:	c3                   	ret    

00000120 <memset>:

void*
memset(void *dst, int c, uint n)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 123:	8b 45 10             	mov    0x10(%ebp),%eax
 126:	50                   	push   %eax
 127:	ff 75 0c             	push   0xc(%ebp)
 12a:	ff 75 08             	push   0x8(%ebp)
 12d:	e8 32 ff ff ff       	call   64 <stosb>
 132:	83 c4 0c             	add    $0xc,%esp
  return dst;
 135:	8b 45 08             	mov    0x8(%ebp),%eax
}
 138:	c9                   	leave  
 139:	c3                   	ret    

0000013a <strchr>:

char*
strchr(const char *s, char c)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	83 ec 04             	sub    $0x4,%esp
 140:	8b 45 0c             	mov    0xc(%ebp),%eax
 143:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 146:	eb 14                	jmp    15c <strchr+0x22>
    if(*s == c)
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	0f b6 00             	movzbl (%eax),%eax
 14e:	38 45 fc             	cmp    %al,-0x4(%ebp)
 151:	75 05                	jne    158 <strchr+0x1e>
      return (char*)s;
 153:	8b 45 08             	mov    0x8(%ebp),%eax
 156:	eb 13                	jmp    16b <strchr+0x31>
  for(; *s; s++)
 158:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 15c:	8b 45 08             	mov    0x8(%ebp),%eax
 15f:	0f b6 00             	movzbl (%eax),%eax
 162:	84 c0                	test   %al,%al
 164:	75 e2                	jne    148 <strchr+0xe>
  return 0;
 166:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16b:	c9                   	leave  
 16c:	c3                   	ret    

0000016d <gets>:

char*
gets(char *buf, int max)
{
 16d:	55                   	push   %ebp
 16e:	89 e5                	mov    %esp,%ebp
 170:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 173:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 17a:	eb 42                	jmp    1be <gets+0x51>
    cc = read(0, &c, 1);
 17c:	83 ec 04             	sub    $0x4,%esp
 17f:	6a 01                	push   $0x1
 181:	8d 45 ef             	lea    -0x11(%ebp),%eax
 184:	50                   	push   %eax
 185:	6a 00                	push   $0x0
 187:	e8 47 01 00 00       	call   2d3 <read>
 18c:	83 c4 10             	add    $0x10,%esp
 18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 192:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 196:	7e 33                	jle    1cb <gets+0x5e>
      break;
    buf[i++] = c;
 198:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19b:	8d 50 01             	lea    0x1(%eax),%edx
 19e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1a1:	89 c2                	mov    %eax,%edx
 1a3:	8b 45 08             	mov    0x8(%ebp),%eax
 1a6:	01 c2                	add    %eax,%edx
 1a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ac:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ae:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1b2:	3c 0a                	cmp    $0xa,%al
 1b4:	74 16                	je     1cc <gets+0x5f>
 1b6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ba:	3c 0d                	cmp    $0xd,%al
 1bc:	74 0e                	je     1cc <gets+0x5f>
  for(i=0; i+1 < max; ){
 1be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c1:	83 c0 01             	add    $0x1,%eax
 1c4:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1c7:	7f b3                	jg     17c <gets+0xf>
 1c9:	eb 01                	jmp    1cc <gets+0x5f>
      break;
 1cb:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	01 d0                	add    %edx,%eax
 1d4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1da:	c9                   	leave  
 1db:	c3                   	ret    

000001dc <stat>:

int
stat(char *n, struct stat *st)
{
 1dc:	55                   	push   %ebp
 1dd:	89 e5                	mov    %esp,%ebp
 1df:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e2:	83 ec 08             	sub    $0x8,%esp
 1e5:	6a 00                	push   $0x0
 1e7:	ff 75 08             	push   0x8(%ebp)
 1ea:	e8 0c 01 00 00       	call   2fb <open>
 1ef:	83 c4 10             	add    $0x10,%esp
 1f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1f9:	79 07                	jns    202 <stat+0x26>
    return -1;
 1fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 200:	eb 25                	jmp    227 <stat+0x4b>
  r = fstat(fd, st);
 202:	83 ec 08             	sub    $0x8,%esp
 205:	ff 75 0c             	push   0xc(%ebp)
 208:	ff 75 f4             	push   -0xc(%ebp)
 20b:	e8 03 01 00 00       	call   313 <fstat>
 210:	83 c4 10             	add    $0x10,%esp
 213:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 216:	83 ec 0c             	sub    $0xc,%esp
 219:	ff 75 f4             	push   -0xc(%ebp)
 21c:	e8 c2 00 00 00       	call   2e3 <close>
 221:	83 c4 10             	add    $0x10,%esp
  return r;
 224:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 227:	c9                   	leave  
 228:	c3                   	ret    

00000229 <atoi>:

int
atoi(const char *s)
{
 229:	55                   	push   %ebp
 22a:	89 e5                	mov    %esp,%ebp
 22c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 22f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 236:	eb 25                	jmp    25d <atoi+0x34>
    n = n*10 + *s++ - '0';
 238:	8b 55 fc             	mov    -0x4(%ebp),%edx
 23b:	89 d0                	mov    %edx,%eax
 23d:	c1 e0 02             	shl    $0x2,%eax
 240:	01 d0                	add    %edx,%eax
 242:	01 c0                	add    %eax,%eax
 244:	89 c1                	mov    %eax,%ecx
 246:	8b 45 08             	mov    0x8(%ebp),%eax
 249:	8d 50 01             	lea    0x1(%eax),%edx
 24c:	89 55 08             	mov    %edx,0x8(%ebp)
 24f:	0f b6 00             	movzbl (%eax),%eax
 252:	0f be c0             	movsbl %al,%eax
 255:	01 c8                	add    %ecx,%eax
 257:	83 e8 30             	sub    $0x30,%eax
 25a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 25d:	8b 45 08             	mov    0x8(%ebp),%eax
 260:	0f b6 00             	movzbl (%eax),%eax
 263:	3c 2f                	cmp    $0x2f,%al
 265:	7e 0a                	jle    271 <atoi+0x48>
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	0f b6 00             	movzbl (%eax),%eax
 26d:	3c 39                	cmp    $0x39,%al
 26f:	7e c7                	jle    238 <atoi+0xf>
  return n;
 271:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 274:	c9                   	leave  
 275:	c3                   	ret    

00000276 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 276:	55                   	push   %ebp
 277:	89 e5                	mov    %esp,%ebp
 279:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 282:	8b 45 0c             	mov    0xc(%ebp),%eax
 285:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 288:	eb 17                	jmp    2a1 <memmove+0x2b>
    *dst++ = *src++;
 28a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 28d:	8d 42 01             	lea    0x1(%edx),%eax
 290:	89 45 f8             	mov    %eax,-0x8(%ebp)
 293:	8b 45 fc             	mov    -0x4(%ebp),%eax
 296:	8d 48 01             	lea    0x1(%eax),%ecx
 299:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 29c:	0f b6 12             	movzbl (%edx),%edx
 29f:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2a1:	8b 45 10             	mov    0x10(%ebp),%eax
 2a4:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a7:	89 55 10             	mov    %edx,0x10(%ebp)
 2aa:	85 c0                	test   %eax,%eax
 2ac:	7f dc                	jg     28a <memmove+0x14>
  return vdst;
 2ae:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b1:	c9                   	leave  
 2b2:	c3                   	ret    

000002b3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b3:	b8 01 00 00 00       	mov    $0x1,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <exit>:
SYSCALL(exit)
 2bb:	b8 02 00 00 00       	mov    $0x2,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <wait>:
SYSCALL(wait)
 2c3:	b8 03 00 00 00       	mov    $0x3,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <pipe>:
SYSCALL(pipe)
 2cb:	b8 04 00 00 00       	mov    $0x4,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <read>:
SYSCALL(read)
 2d3:	b8 05 00 00 00       	mov    $0x5,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <write>:
SYSCALL(write)
 2db:	b8 10 00 00 00       	mov    $0x10,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <close>:
SYSCALL(close)
 2e3:	b8 15 00 00 00       	mov    $0x15,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <kill>:
SYSCALL(kill)
 2eb:	b8 06 00 00 00       	mov    $0x6,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <exec>:
SYSCALL(exec)
 2f3:	b8 07 00 00 00       	mov    $0x7,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <open>:
SYSCALL(open)
 2fb:	b8 0f 00 00 00       	mov    $0xf,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <mknod>:
SYSCALL(mknod)
 303:	b8 11 00 00 00       	mov    $0x11,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <unlink>:
SYSCALL(unlink)
 30b:	b8 12 00 00 00       	mov    $0x12,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <fstat>:
SYSCALL(fstat)
 313:	b8 08 00 00 00       	mov    $0x8,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <link>:
SYSCALL(link)
 31b:	b8 13 00 00 00       	mov    $0x13,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <mkdir>:
SYSCALL(mkdir)
 323:	b8 14 00 00 00       	mov    $0x14,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <chdir>:
SYSCALL(chdir)
 32b:	b8 09 00 00 00       	mov    $0x9,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <dup>:
SYSCALL(dup)
 333:	b8 0a 00 00 00       	mov    $0xa,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <getpid>:
SYSCALL(getpid)
 33b:	b8 0b 00 00 00       	mov    $0xb,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <sbrk>:
SYSCALL(sbrk)
 343:	b8 0c 00 00 00       	mov    $0xc,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <sleep>:
SYSCALL(sleep)
 34b:	b8 0d 00 00 00       	mov    $0xd,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <uptime>:
SYSCALL(uptime)
 353:	b8 0e 00 00 00       	mov    $0xe,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 35b:	b8 16 00 00 00       	mov    $0x16,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <getpinfo>:
SYSCALL(getpinfo)
 363:	b8 17 00 00 00       	mov    $0x17,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 36b:	55                   	push   %ebp
 36c:	89 e5                	mov    %esp,%ebp
 36e:	83 ec 18             	sub    $0x18,%esp
 371:	8b 45 0c             	mov    0xc(%ebp),%eax
 374:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 377:	83 ec 04             	sub    $0x4,%esp
 37a:	6a 01                	push   $0x1
 37c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 37f:	50                   	push   %eax
 380:	ff 75 08             	push   0x8(%ebp)
 383:	e8 53 ff ff ff       	call   2db <write>
 388:	83 c4 10             	add    $0x10,%esp
}
 38b:	90                   	nop
 38c:	c9                   	leave  
 38d:	c3                   	ret    

0000038e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 38e:	55                   	push   %ebp
 38f:	89 e5                	mov    %esp,%ebp
 391:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 394:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 39b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 39f:	74 17                	je     3b8 <printint+0x2a>
 3a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3a5:	79 11                	jns    3b8 <printint+0x2a>
    neg = 1;
 3a7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b1:	f7 d8                	neg    %eax
 3b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b6:	eb 06                	jmp    3be <printint+0x30>
  } else {
    x = xx;
 3b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3cb:	ba 00 00 00 00       	mov    $0x0,%edx
 3d0:	f7 f1                	div    %ecx
 3d2:	89 d1                	mov    %edx,%ecx
 3d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d7:	8d 50 01             	lea    0x1(%eax),%edx
 3da:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3dd:	0f b6 91 9c 0a 00 00 	movzbl 0xa9c(%ecx),%edx
 3e4:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ee:	ba 00 00 00 00       	mov    $0x0,%edx
 3f3:	f7 f1                	div    %ecx
 3f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3fc:	75 c7                	jne    3c5 <printint+0x37>
  if(neg)
 3fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 402:	74 2d                	je     431 <printint+0xa3>
    buf[i++] = '-';
 404:	8b 45 f4             	mov    -0xc(%ebp),%eax
 407:	8d 50 01             	lea    0x1(%eax),%edx
 40a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 40d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 412:	eb 1d                	jmp    431 <printint+0xa3>
    putc(fd, buf[i]);
 414:	8d 55 dc             	lea    -0x24(%ebp),%edx
 417:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41a:	01 d0                	add    %edx,%eax
 41c:	0f b6 00             	movzbl (%eax),%eax
 41f:	0f be c0             	movsbl %al,%eax
 422:	83 ec 08             	sub    $0x8,%esp
 425:	50                   	push   %eax
 426:	ff 75 08             	push   0x8(%ebp)
 429:	e8 3d ff ff ff       	call   36b <putc>
 42e:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 431:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 435:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 439:	79 d9                	jns    414 <printint+0x86>
}
 43b:	90                   	nop
 43c:	90                   	nop
 43d:	c9                   	leave  
 43e:	c3                   	ret    

0000043f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 43f:	55                   	push   %ebp
 440:	89 e5                	mov    %esp,%ebp
 442:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 445:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 44c:	8d 45 0c             	lea    0xc(%ebp),%eax
 44f:	83 c0 04             	add    $0x4,%eax
 452:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 455:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 45c:	e9 59 01 00 00       	jmp    5ba <printf+0x17b>
    c = fmt[i] & 0xff;
 461:	8b 55 0c             	mov    0xc(%ebp),%edx
 464:	8b 45 f0             	mov    -0x10(%ebp),%eax
 467:	01 d0                	add    %edx,%eax
 469:	0f b6 00             	movzbl (%eax),%eax
 46c:	0f be c0             	movsbl %al,%eax
 46f:	25 ff 00 00 00       	and    $0xff,%eax
 474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 477:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 47b:	75 2c                	jne    4a9 <printf+0x6a>
      if(c == '%'){
 47d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 481:	75 0c                	jne    48f <printf+0x50>
        state = '%';
 483:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 48a:	e9 27 01 00 00       	jmp    5b6 <printf+0x177>
      } else {
        putc(fd, c);
 48f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 492:	0f be c0             	movsbl %al,%eax
 495:	83 ec 08             	sub    $0x8,%esp
 498:	50                   	push   %eax
 499:	ff 75 08             	push   0x8(%ebp)
 49c:	e8 ca fe ff ff       	call   36b <putc>
 4a1:	83 c4 10             	add    $0x10,%esp
 4a4:	e9 0d 01 00 00       	jmp    5b6 <printf+0x177>
      }
    } else if(state == '%'){
 4a9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ad:	0f 85 03 01 00 00    	jne    5b6 <printf+0x177>
      if(c == 'd'){
 4b3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4b7:	75 1e                	jne    4d7 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4bc:	8b 00                	mov    (%eax),%eax
 4be:	6a 01                	push   $0x1
 4c0:	6a 0a                	push   $0xa
 4c2:	50                   	push   %eax
 4c3:	ff 75 08             	push   0x8(%ebp)
 4c6:	e8 c3 fe ff ff       	call   38e <printint>
 4cb:	83 c4 10             	add    $0x10,%esp
        ap++;
 4ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d2:	e9 d8 00 00 00       	jmp    5af <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4d7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4db:	74 06                	je     4e3 <printf+0xa4>
 4dd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4e1:	75 1e                	jne    501 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e6:	8b 00                	mov    (%eax),%eax
 4e8:	6a 00                	push   $0x0
 4ea:	6a 10                	push   $0x10
 4ec:	50                   	push   %eax
 4ed:	ff 75 08             	push   0x8(%ebp)
 4f0:	e8 99 fe ff ff       	call   38e <printint>
 4f5:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4fc:	e9 ae 00 00 00       	jmp    5af <printf+0x170>
      } else if(c == 's'){
 501:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 505:	75 43                	jne    54a <printf+0x10b>
        s = (char*)*ap;
 507:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50a:	8b 00                	mov    (%eax),%eax
 50c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 50f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 513:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 517:	75 25                	jne    53e <printf+0xff>
          s = "(null)";
 519:	c7 45 f4 51 08 00 00 	movl   $0x851,-0xc(%ebp)
        while(*s != 0){
 520:	eb 1c                	jmp    53e <printf+0xff>
          putc(fd, *s);
 522:	8b 45 f4             	mov    -0xc(%ebp),%eax
 525:	0f b6 00             	movzbl (%eax),%eax
 528:	0f be c0             	movsbl %al,%eax
 52b:	83 ec 08             	sub    $0x8,%esp
 52e:	50                   	push   %eax
 52f:	ff 75 08             	push   0x8(%ebp)
 532:	e8 34 fe ff ff       	call   36b <putc>
 537:	83 c4 10             	add    $0x10,%esp
          s++;
 53a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 53e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 541:	0f b6 00             	movzbl (%eax),%eax
 544:	84 c0                	test   %al,%al
 546:	75 da                	jne    522 <printf+0xe3>
 548:	eb 65                	jmp    5af <printf+0x170>
        }
      } else if(c == 'c'){
 54a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 54e:	75 1d                	jne    56d <printf+0x12e>
        putc(fd, *ap);
 550:	8b 45 e8             	mov    -0x18(%ebp),%eax
 553:	8b 00                	mov    (%eax),%eax
 555:	0f be c0             	movsbl %al,%eax
 558:	83 ec 08             	sub    $0x8,%esp
 55b:	50                   	push   %eax
 55c:	ff 75 08             	push   0x8(%ebp)
 55f:	e8 07 fe ff ff       	call   36b <putc>
 564:	83 c4 10             	add    $0x10,%esp
        ap++;
 567:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56b:	eb 42                	jmp    5af <printf+0x170>
      } else if(c == '%'){
 56d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 571:	75 17                	jne    58a <printf+0x14b>
        putc(fd, c);
 573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 576:	0f be c0             	movsbl %al,%eax
 579:	83 ec 08             	sub    $0x8,%esp
 57c:	50                   	push   %eax
 57d:	ff 75 08             	push   0x8(%ebp)
 580:	e8 e6 fd ff ff       	call   36b <putc>
 585:	83 c4 10             	add    $0x10,%esp
 588:	eb 25                	jmp    5af <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 58a:	83 ec 08             	sub    $0x8,%esp
 58d:	6a 25                	push   $0x25
 58f:	ff 75 08             	push   0x8(%ebp)
 592:	e8 d4 fd ff ff       	call   36b <putc>
 597:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 59a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59d:	0f be c0             	movsbl %al,%eax
 5a0:	83 ec 08             	sub    $0x8,%esp
 5a3:	50                   	push   %eax
 5a4:	ff 75 08             	push   0x8(%ebp)
 5a7:	e8 bf fd ff ff       	call   36b <putc>
 5ac:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5b6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ba:	8b 55 0c             	mov    0xc(%ebp),%edx
 5bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5c0:	01 d0                	add    %edx,%eax
 5c2:	0f b6 00             	movzbl (%eax),%eax
 5c5:	84 c0                	test   %al,%al
 5c7:	0f 85 94 fe ff ff    	jne    461 <printf+0x22>
    }
  }
}
 5cd:	90                   	nop
 5ce:	90                   	nop
 5cf:	c9                   	leave  
 5d0:	c3                   	ret    

000005d1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5d1:	55                   	push   %ebp
 5d2:	89 e5                	mov    %esp,%ebp
 5d4:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5d7:	8b 45 08             	mov    0x8(%ebp),%eax
 5da:	83 e8 08             	sub    $0x8,%eax
 5dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e0:	a1 b8 0a 00 00       	mov    0xab8,%eax
 5e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e8:	eb 24                	jmp    60e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ed:	8b 00                	mov    (%eax),%eax
 5ef:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5f2:	72 12                	jb     606 <free+0x35>
 5f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5fa:	77 24                	ja     620 <free+0x4f>
 5fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ff:	8b 00                	mov    (%eax),%eax
 601:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 604:	72 1a                	jb     620 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 606:	8b 45 fc             	mov    -0x4(%ebp),%eax
 609:	8b 00                	mov    (%eax),%eax
 60b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 611:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 614:	76 d4                	jbe    5ea <free+0x19>
 616:	8b 45 fc             	mov    -0x4(%ebp),%eax
 619:	8b 00                	mov    (%eax),%eax
 61b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 61e:	73 ca                	jae    5ea <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 620:	8b 45 f8             	mov    -0x8(%ebp),%eax
 623:	8b 40 04             	mov    0x4(%eax),%eax
 626:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 62d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 630:	01 c2                	add    %eax,%edx
 632:	8b 45 fc             	mov    -0x4(%ebp),%eax
 635:	8b 00                	mov    (%eax),%eax
 637:	39 c2                	cmp    %eax,%edx
 639:	75 24                	jne    65f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 63b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63e:	8b 50 04             	mov    0x4(%eax),%edx
 641:	8b 45 fc             	mov    -0x4(%ebp),%eax
 644:	8b 00                	mov    (%eax),%eax
 646:	8b 40 04             	mov    0x4(%eax),%eax
 649:	01 c2                	add    %eax,%edx
 64b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 651:	8b 45 fc             	mov    -0x4(%ebp),%eax
 654:	8b 00                	mov    (%eax),%eax
 656:	8b 10                	mov    (%eax),%edx
 658:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65b:	89 10                	mov    %edx,(%eax)
 65d:	eb 0a                	jmp    669 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	8b 10                	mov    (%eax),%edx
 664:	8b 45 f8             	mov    -0x8(%ebp),%eax
 667:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 669:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66c:	8b 40 04             	mov    0x4(%eax),%eax
 66f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 676:	8b 45 fc             	mov    -0x4(%ebp),%eax
 679:	01 d0                	add    %edx,%eax
 67b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 67e:	75 20                	jne    6a0 <free+0xcf>
    p->s.size += bp->s.size;
 680:	8b 45 fc             	mov    -0x4(%ebp),%eax
 683:	8b 50 04             	mov    0x4(%eax),%edx
 686:	8b 45 f8             	mov    -0x8(%ebp),%eax
 689:	8b 40 04             	mov    0x4(%eax),%eax
 68c:	01 c2                	add    %eax,%edx
 68e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 691:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 694:	8b 45 f8             	mov    -0x8(%ebp),%eax
 697:	8b 10                	mov    (%eax),%edx
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	89 10                	mov    %edx,(%eax)
 69e:	eb 08                	jmp    6a8 <free+0xd7>
  } else
    p->s.ptr = bp;
 6a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6a6:	89 10                	mov    %edx,(%eax)
  freep = p;
 6a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ab:	a3 b8 0a 00 00       	mov    %eax,0xab8
}
 6b0:	90                   	nop
 6b1:	c9                   	leave  
 6b2:	c3                   	ret    

000006b3 <morecore>:

static Header*
morecore(uint nu)
{
 6b3:	55                   	push   %ebp
 6b4:	89 e5                	mov    %esp,%ebp
 6b6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6b9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6c0:	77 07                	ja     6c9 <morecore+0x16>
    nu = 4096;
 6c2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6c9:	8b 45 08             	mov    0x8(%ebp),%eax
 6cc:	c1 e0 03             	shl    $0x3,%eax
 6cf:	83 ec 0c             	sub    $0xc,%esp
 6d2:	50                   	push   %eax
 6d3:	e8 6b fc ff ff       	call   343 <sbrk>
 6d8:	83 c4 10             	add    $0x10,%esp
 6db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6de:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6e2:	75 07                	jne    6eb <morecore+0x38>
    return 0;
 6e4:	b8 00 00 00 00       	mov    $0x0,%eax
 6e9:	eb 26                	jmp    711 <morecore+0x5e>
  hp = (Header*)p;
 6eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f4:	8b 55 08             	mov    0x8(%ebp),%edx
 6f7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fd:	83 c0 08             	add    $0x8,%eax
 700:	83 ec 0c             	sub    $0xc,%esp
 703:	50                   	push   %eax
 704:	e8 c8 fe ff ff       	call   5d1 <free>
 709:	83 c4 10             	add    $0x10,%esp
  return freep;
 70c:	a1 b8 0a 00 00       	mov    0xab8,%eax
}
 711:	c9                   	leave  
 712:	c3                   	ret    

00000713 <malloc>:

void*
malloc(uint nbytes)
{
 713:	55                   	push   %ebp
 714:	89 e5                	mov    %esp,%ebp
 716:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 719:	8b 45 08             	mov    0x8(%ebp),%eax
 71c:	83 c0 07             	add    $0x7,%eax
 71f:	c1 e8 03             	shr    $0x3,%eax
 722:	83 c0 01             	add    $0x1,%eax
 725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 728:	a1 b8 0a 00 00       	mov    0xab8,%eax
 72d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 730:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 734:	75 23                	jne    759 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 736:	c7 45 f0 b0 0a 00 00 	movl   $0xab0,-0x10(%ebp)
 73d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 740:	a3 b8 0a 00 00       	mov    %eax,0xab8
 745:	a1 b8 0a 00 00       	mov    0xab8,%eax
 74a:	a3 b0 0a 00 00       	mov    %eax,0xab0
    base.s.size = 0;
 74f:	c7 05 b4 0a 00 00 00 	movl   $0x0,0xab4
 756:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 759:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75c:	8b 00                	mov    (%eax),%eax
 75e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 761:	8b 45 f4             	mov    -0xc(%ebp),%eax
 764:	8b 40 04             	mov    0x4(%eax),%eax
 767:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 76a:	77 4d                	ja     7b9 <malloc+0xa6>
      if(p->s.size == nunits)
 76c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76f:	8b 40 04             	mov    0x4(%eax),%eax
 772:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 775:	75 0c                	jne    783 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 777:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77a:	8b 10                	mov    (%eax),%edx
 77c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77f:	89 10                	mov    %edx,(%eax)
 781:	eb 26                	jmp    7a9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 783:	8b 45 f4             	mov    -0xc(%ebp),%eax
 786:	8b 40 04             	mov    0x4(%eax),%eax
 789:	2b 45 ec             	sub    -0x14(%ebp),%eax
 78c:	89 c2                	mov    %eax,%edx
 78e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 791:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 794:	8b 45 f4             	mov    -0xc(%ebp),%eax
 797:	8b 40 04             	mov    0x4(%eax),%eax
 79a:	c1 e0 03             	shl    $0x3,%eax
 79d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7a6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ac:	a3 b8 0a 00 00       	mov    %eax,0xab8
      return (void*)(p + 1);
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	83 c0 08             	add    $0x8,%eax
 7b7:	eb 3b                	jmp    7f4 <malloc+0xe1>
    }
    if(p == freep)
 7b9:	a1 b8 0a 00 00       	mov    0xab8,%eax
 7be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7c1:	75 1e                	jne    7e1 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7c3:	83 ec 0c             	sub    $0xc,%esp
 7c6:	ff 75 ec             	push   -0x14(%ebp)
 7c9:	e8 e5 fe ff ff       	call   6b3 <morecore>
 7ce:	83 c4 10             	add    $0x10,%esp
 7d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7d8:	75 07                	jne    7e1 <malloc+0xce>
        return 0;
 7da:	b8 00 00 00 00       	mov    $0x0,%eax
 7df:	eb 13                	jmp    7f4 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ea:	8b 00                	mov    (%eax),%eax
 7ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ef:	e9 6d ff ff ff       	jmp    761 <malloc+0x4e>
  }
}
 7f4:	c9                   	leave  
 7f5:	c3                   	ret    
