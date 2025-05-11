
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
  14:	68 00 08 00 00       	push   $0x800
  19:	6a 01                	push   $0x1
  1b:	e8 27 04 00 00       	call   447 <printf>
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
  3c:	68 27 08 00 00       	push   $0x827
  41:	6a 01                	push   $0x1
  43:	e8 ff 03 00 00       	call   447 <printf>
  48:	83 c4 10             	add    $0x10,%esp
  4b:	eb 12                	jmp    5f <main+0x5f>
  } else {
    printf(1, "setSchedPolicy 실패...\n");
  4d:	83 ec 08             	sub    $0x8,%esp
  50:	68 3f 08 00 00       	push   $0x83f
  55:	6a 01                	push   $0x1
  57:	e8 eb 03 00 00       	call   447 <printf>
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

0000036b <yield>:
SYSCALL(yield)
 36b:	b8 18 00 00 00       	mov    $0x18,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 373:	55                   	push   %ebp
 374:	89 e5                	mov    %esp,%ebp
 376:	83 ec 18             	sub    $0x18,%esp
 379:	8b 45 0c             	mov    0xc(%ebp),%eax
 37c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 37f:	83 ec 04             	sub    $0x4,%esp
 382:	6a 01                	push   $0x1
 384:	8d 45 f4             	lea    -0xc(%ebp),%eax
 387:	50                   	push   %eax
 388:	ff 75 08             	push   0x8(%ebp)
 38b:	e8 4b ff ff ff       	call   2db <write>
 390:	83 c4 10             	add    $0x10,%esp
}
 393:	90                   	nop
 394:	c9                   	leave  
 395:	c3                   	ret    

00000396 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 396:	55                   	push   %ebp
 397:	89 e5                	mov    %esp,%ebp
 399:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 39c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3a3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3a7:	74 17                	je     3c0 <printint+0x2a>
 3a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3ad:	79 11                	jns    3c0 <printint+0x2a>
    neg = 1;
 3af:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b9:	f7 d8                	neg    %eax
 3bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3be:	eb 06                	jmp    3c6 <printint+0x30>
  } else {
    x = xx;
 3c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3d3:	ba 00 00 00 00       	mov    $0x0,%edx
 3d8:	f7 f1                	div    %ecx
 3da:	89 d1                	mov    %edx,%ecx
 3dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3df:	8d 50 01             	lea    0x1(%eax),%edx
 3e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3e5:	0f b6 91 a4 0a 00 00 	movzbl 0xaa4(%ecx),%edx
 3ec:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f6:	ba 00 00 00 00       	mov    $0x0,%edx
 3fb:	f7 f1                	div    %ecx
 3fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 400:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 404:	75 c7                	jne    3cd <printint+0x37>
  if(neg)
 406:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 40a:	74 2d                	je     439 <printint+0xa3>
    buf[i++] = '-';
 40c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40f:	8d 50 01             	lea    0x1(%eax),%edx
 412:	89 55 f4             	mov    %edx,-0xc(%ebp)
 415:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 41a:	eb 1d                	jmp    439 <printint+0xa3>
    putc(fd, buf[i]);
 41c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 41f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 422:	01 d0                	add    %edx,%eax
 424:	0f b6 00             	movzbl (%eax),%eax
 427:	0f be c0             	movsbl %al,%eax
 42a:	83 ec 08             	sub    $0x8,%esp
 42d:	50                   	push   %eax
 42e:	ff 75 08             	push   0x8(%ebp)
 431:	e8 3d ff ff ff       	call   373 <putc>
 436:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 439:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 43d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 441:	79 d9                	jns    41c <printint+0x86>
}
 443:	90                   	nop
 444:	90                   	nop
 445:	c9                   	leave  
 446:	c3                   	ret    

00000447 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 447:	55                   	push   %ebp
 448:	89 e5                	mov    %esp,%ebp
 44a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 44d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 454:	8d 45 0c             	lea    0xc(%ebp),%eax
 457:	83 c0 04             	add    $0x4,%eax
 45a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 45d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 464:	e9 59 01 00 00       	jmp    5c2 <printf+0x17b>
    c = fmt[i] & 0xff;
 469:	8b 55 0c             	mov    0xc(%ebp),%edx
 46c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 46f:	01 d0                	add    %edx,%eax
 471:	0f b6 00             	movzbl (%eax),%eax
 474:	0f be c0             	movsbl %al,%eax
 477:	25 ff 00 00 00       	and    $0xff,%eax
 47c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 47f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 483:	75 2c                	jne    4b1 <printf+0x6a>
      if(c == '%'){
 485:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 489:	75 0c                	jne    497 <printf+0x50>
        state = '%';
 48b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 492:	e9 27 01 00 00       	jmp    5be <printf+0x177>
      } else {
        putc(fd, c);
 497:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 49a:	0f be c0             	movsbl %al,%eax
 49d:	83 ec 08             	sub    $0x8,%esp
 4a0:	50                   	push   %eax
 4a1:	ff 75 08             	push   0x8(%ebp)
 4a4:	e8 ca fe ff ff       	call   373 <putc>
 4a9:	83 c4 10             	add    $0x10,%esp
 4ac:	e9 0d 01 00 00       	jmp    5be <printf+0x177>
      }
    } else if(state == '%'){
 4b1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4b5:	0f 85 03 01 00 00    	jne    5be <printf+0x177>
      if(c == 'd'){
 4bb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4bf:	75 1e                	jne    4df <printf+0x98>
        printint(fd, *ap, 10, 1);
 4c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4c4:	8b 00                	mov    (%eax),%eax
 4c6:	6a 01                	push   $0x1
 4c8:	6a 0a                	push   $0xa
 4ca:	50                   	push   %eax
 4cb:	ff 75 08             	push   0x8(%ebp)
 4ce:	e8 c3 fe ff ff       	call   396 <printint>
 4d3:	83 c4 10             	add    $0x10,%esp
        ap++;
 4d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4da:	e9 d8 00 00 00       	jmp    5b7 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4df:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4e3:	74 06                	je     4eb <printf+0xa4>
 4e5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4e9:	75 1e                	jne    509 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ee:	8b 00                	mov    (%eax),%eax
 4f0:	6a 00                	push   $0x0
 4f2:	6a 10                	push   $0x10
 4f4:	50                   	push   %eax
 4f5:	ff 75 08             	push   0x8(%ebp)
 4f8:	e8 99 fe ff ff       	call   396 <printint>
 4fd:	83 c4 10             	add    $0x10,%esp
        ap++;
 500:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 504:	e9 ae 00 00 00       	jmp    5b7 <printf+0x170>
      } else if(c == 's'){
 509:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 50d:	75 43                	jne    552 <printf+0x10b>
        s = (char*)*ap;
 50f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 512:	8b 00                	mov    (%eax),%eax
 514:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 517:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 51b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51f:	75 25                	jne    546 <printf+0xff>
          s = "(null)";
 521:	c7 45 f4 59 08 00 00 	movl   $0x859,-0xc(%ebp)
        while(*s != 0){
 528:	eb 1c                	jmp    546 <printf+0xff>
          putc(fd, *s);
 52a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52d:	0f b6 00             	movzbl (%eax),%eax
 530:	0f be c0             	movsbl %al,%eax
 533:	83 ec 08             	sub    $0x8,%esp
 536:	50                   	push   %eax
 537:	ff 75 08             	push   0x8(%ebp)
 53a:	e8 34 fe ff ff       	call   373 <putc>
 53f:	83 c4 10             	add    $0x10,%esp
          s++;
 542:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 546:	8b 45 f4             	mov    -0xc(%ebp),%eax
 549:	0f b6 00             	movzbl (%eax),%eax
 54c:	84 c0                	test   %al,%al
 54e:	75 da                	jne    52a <printf+0xe3>
 550:	eb 65                	jmp    5b7 <printf+0x170>
        }
      } else if(c == 'c'){
 552:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 556:	75 1d                	jne    575 <printf+0x12e>
        putc(fd, *ap);
 558:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55b:	8b 00                	mov    (%eax),%eax
 55d:	0f be c0             	movsbl %al,%eax
 560:	83 ec 08             	sub    $0x8,%esp
 563:	50                   	push   %eax
 564:	ff 75 08             	push   0x8(%ebp)
 567:	e8 07 fe ff ff       	call   373 <putc>
 56c:	83 c4 10             	add    $0x10,%esp
        ap++;
 56f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 573:	eb 42                	jmp    5b7 <printf+0x170>
      } else if(c == '%'){
 575:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 579:	75 17                	jne    592 <printf+0x14b>
        putc(fd, c);
 57b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57e:	0f be c0             	movsbl %al,%eax
 581:	83 ec 08             	sub    $0x8,%esp
 584:	50                   	push   %eax
 585:	ff 75 08             	push   0x8(%ebp)
 588:	e8 e6 fd ff ff       	call   373 <putc>
 58d:	83 c4 10             	add    $0x10,%esp
 590:	eb 25                	jmp    5b7 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 592:	83 ec 08             	sub    $0x8,%esp
 595:	6a 25                	push   $0x25
 597:	ff 75 08             	push   0x8(%ebp)
 59a:	e8 d4 fd ff ff       	call   373 <putc>
 59f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a5:	0f be c0             	movsbl %al,%eax
 5a8:	83 ec 08             	sub    $0x8,%esp
 5ab:	50                   	push   %eax
 5ac:	ff 75 08             	push   0x8(%ebp)
 5af:	e8 bf fd ff ff       	call   373 <putc>
 5b4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5b7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5be:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5c2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5c8:	01 d0                	add    %edx,%eax
 5ca:	0f b6 00             	movzbl (%eax),%eax
 5cd:	84 c0                	test   %al,%al
 5cf:	0f 85 94 fe ff ff    	jne    469 <printf+0x22>
    }
  }
}
 5d5:	90                   	nop
 5d6:	90                   	nop
 5d7:	c9                   	leave  
 5d8:	c3                   	ret    

000005d9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5d9:	55                   	push   %ebp
 5da:	89 e5                	mov    %esp,%ebp
 5dc:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5df:	8b 45 08             	mov    0x8(%ebp),%eax
 5e2:	83 e8 08             	sub    $0x8,%eax
 5e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e8:	a1 c0 0a 00 00       	mov    0xac0,%eax
 5ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f0:	eb 24                	jmp    616 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f5:	8b 00                	mov    (%eax),%eax
 5f7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5fa:	72 12                	jb     60e <free+0x35>
 5fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ff:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 602:	77 24                	ja     628 <free+0x4f>
 604:	8b 45 fc             	mov    -0x4(%ebp),%eax
 607:	8b 00                	mov    (%eax),%eax
 609:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 60c:	72 1a                	jb     628 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 611:	8b 00                	mov    (%eax),%eax
 613:	89 45 fc             	mov    %eax,-0x4(%ebp)
 616:	8b 45 f8             	mov    -0x8(%ebp),%eax
 619:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61c:	76 d4                	jbe    5f2 <free+0x19>
 61e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 621:	8b 00                	mov    (%eax),%eax
 623:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 626:	73 ca                	jae    5f2 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 628:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62b:	8b 40 04             	mov    0x4(%eax),%eax
 62e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 635:	8b 45 f8             	mov    -0x8(%ebp),%eax
 638:	01 c2                	add    %eax,%edx
 63a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63d:	8b 00                	mov    (%eax),%eax
 63f:	39 c2                	cmp    %eax,%edx
 641:	75 24                	jne    667 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 643:	8b 45 f8             	mov    -0x8(%ebp),%eax
 646:	8b 50 04             	mov    0x4(%eax),%edx
 649:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64c:	8b 00                	mov    (%eax),%eax
 64e:	8b 40 04             	mov    0x4(%eax),%eax
 651:	01 c2                	add    %eax,%edx
 653:	8b 45 f8             	mov    -0x8(%ebp),%eax
 656:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 659:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	8b 10                	mov    (%eax),%edx
 660:	8b 45 f8             	mov    -0x8(%ebp),%eax
 663:	89 10                	mov    %edx,(%eax)
 665:	eb 0a                	jmp    671 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	8b 10                	mov    (%eax),%edx
 66c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 671:	8b 45 fc             	mov    -0x4(%ebp),%eax
 674:	8b 40 04             	mov    0x4(%eax),%eax
 677:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 67e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 681:	01 d0                	add    %edx,%eax
 683:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 686:	75 20                	jne    6a8 <free+0xcf>
    p->s.size += bp->s.size;
 688:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68b:	8b 50 04             	mov    0x4(%eax),%edx
 68e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 691:	8b 40 04             	mov    0x4(%eax),%eax
 694:	01 c2                	add    %eax,%edx
 696:	8b 45 fc             	mov    -0x4(%ebp),%eax
 699:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 69c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69f:	8b 10                	mov    (%eax),%edx
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	89 10                	mov    %edx,(%eax)
 6a6:	eb 08                	jmp    6b0 <free+0xd7>
  } else
    p->s.ptr = bp;
 6a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ab:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ae:	89 10                	mov    %edx,(%eax)
  freep = p;
 6b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b3:	a3 c0 0a 00 00       	mov    %eax,0xac0
}
 6b8:	90                   	nop
 6b9:	c9                   	leave  
 6ba:	c3                   	ret    

000006bb <morecore>:

static Header*
morecore(uint nu)
{
 6bb:	55                   	push   %ebp
 6bc:	89 e5                	mov    %esp,%ebp
 6be:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6c1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6c8:	77 07                	ja     6d1 <morecore+0x16>
    nu = 4096;
 6ca:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6d1:	8b 45 08             	mov    0x8(%ebp),%eax
 6d4:	c1 e0 03             	shl    $0x3,%eax
 6d7:	83 ec 0c             	sub    $0xc,%esp
 6da:	50                   	push   %eax
 6db:	e8 63 fc ff ff       	call   343 <sbrk>
 6e0:	83 c4 10             	add    $0x10,%esp
 6e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6e6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ea:	75 07                	jne    6f3 <morecore+0x38>
    return 0;
 6ec:	b8 00 00 00 00       	mov    $0x0,%eax
 6f1:	eb 26                	jmp    719 <morecore+0x5e>
  hp = (Header*)p;
 6f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fc:	8b 55 08             	mov    0x8(%ebp),%edx
 6ff:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 702:	8b 45 f0             	mov    -0x10(%ebp),%eax
 705:	83 c0 08             	add    $0x8,%eax
 708:	83 ec 0c             	sub    $0xc,%esp
 70b:	50                   	push   %eax
 70c:	e8 c8 fe ff ff       	call   5d9 <free>
 711:	83 c4 10             	add    $0x10,%esp
  return freep;
 714:	a1 c0 0a 00 00       	mov    0xac0,%eax
}
 719:	c9                   	leave  
 71a:	c3                   	ret    

0000071b <malloc>:

void*
malloc(uint nbytes)
{
 71b:	55                   	push   %ebp
 71c:	89 e5                	mov    %esp,%ebp
 71e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 721:	8b 45 08             	mov    0x8(%ebp),%eax
 724:	83 c0 07             	add    $0x7,%eax
 727:	c1 e8 03             	shr    $0x3,%eax
 72a:	83 c0 01             	add    $0x1,%eax
 72d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 730:	a1 c0 0a 00 00       	mov    0xac0,%eax
 735:	89 45 f0             	mov    %eax,-0x10(%ebp)
 738:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 73c:	75 23                	jne    761 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 73e:	c7 45 f0 b8 0a 00 00 	movl   $0xab8,-0x10(%ebp)
 745:	8b 45 f0             	mov    -0x10(%ebp),%eax
 748:	a3 c0 0a 00 00       	mov    %eax,0xac0
 74d:	a1 c0 0a 00 00       	mov    0xac0,%eax
 752:	a3 b8 0a 00 00       	mov    %eax,0xab8
    base.s.size = 0;
 757:	c7 05 bc 0a 00 00 00 	movl   $0x0,0xabc
 75e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 761:	8b 45 f0             	mov    -0x10(%ebp),%eax
 764:	8b 00                	mov    (%eax),%eax
 766:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 769:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76c:	8b 40 04             	mov    0x4(%eax),%eax
 76f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 772:	77 4d                	ja     7c1 <malloc+0xa6>
      if(p->s.size == nunits)
 774:	8b 45 f4             	mov    -0xc(%ebp),%eax
 777:	8b 40 04             	mov    0x4(%eax),%eax
 77a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 77d:	75 0c                	jne    78b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 77f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 782:	8b 10                	mov    (%eax),%edx
 784:	8b 45 f0             	mov    -0x10(%ebp),%eax
 787:	89 10                	mov    %edx,(%eax)
 789:	eb 26                	jmp    7b1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	8b 40 04             	mov    0x4(%eax),%eax
 791:	2b 45 ec             	sub    -0x14(%ebp),%eax
 794:	89 c2                	mov    %eax,%edx
 796:	8b 45 f4             	mov    -0xc(%ebp),%eax
 799:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 79c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79f:	8b 40 04             	mov    0x4(%eax),%eax
 7a2:	c1 e0 03             	shl    $0x3,%eax
 7a5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7ae:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b4:	a3 c0 0a 00 00       	mov    %eax,0xac0
      return (void*)(p + 1);
 7b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bc:	83 c0 08             	add    $0x8,%eax
 7bf:	eb 3b                	jmp    7fc <malloc+0xe1>
    }
    if(p == freep)
 7c1:	a1 c0 0a 00 00       	mov    0xac0,%eax
 7c6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7c9:	75 1e                	jne    7e9 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7cb:	83 ec 0c             	sub    $0xc,%esp
 7ce:	ff 75 ec             	push   -0x14(%ebp)
 7d1:	e8 e5 fe ff ff       	call   6bb <morecore>
 7d6:	83 c4 10             	add    $0x10,%esp
 7d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e0:	75 07                	jne    7e9 <malloc+0xce>
        return 0;
 7e2:	b8 00 00 00 00       	mov    $0x0,%eax
 7e7:	eb 13                	jmp    7fc <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f2:	8b 00                	mov    (%eax),%eax
 7f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7f7:	e9 6d ff ff ff       	jmp    769 <malloc+0x4e>
  }
}
 7fc:	c9                   	leave  
 7fd:	c3                   	ret    
