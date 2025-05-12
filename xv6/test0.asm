
_test0:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
//그냥 mlfq 테스트 코드
//안돌아감
#include "types.h"
#include "user.h"

void workload(int n) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 10             	sub    $0x10,%esp
  int i;
  volatile int x = 0;
   a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++)
  11:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  18:	eb 29                	jmp    43 <workload+0x43>
    x += i % 3;
  1a:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  1d:	ba 56 55 55 55       	mov    $0x55555556,%edx
  22:	89 c8                	mov    %ecx,%eax
  24:	f7 ea                	imul   %edx
  26:	89 c8                	mov    %ecx,%eax
  28:	c1 f8 1f             	sar    $0x1f,%eax
  2b:	29 c2                	sub    %eax,%edx
  2d:	89 d0                	mov    %edx,%eax
  2f:	01 c0                	add    %eax,%eax
  31:	01 d0                	add    %edx,%eax
  33:	29 c1                	sub    %eax,%ecx
  35:	89 ca                	mov    %ecx,%edx
  37:	8b 45 f8             	mov    -0x8(%ebp),%eax
  3a:	01 d0                	add    %edx,%eax
  3c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++)
  3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  43:	8b 45 fc             	mov    -0x4(%ebp),%eax
  46:	3b 45 08             	cmp    0x8(%ebp),%eax
  49:	7c cf                	jl     1a <workload+0x1a>
}
  4b:	90                   	nop
  4c:	90                   	nop
  4d:	c9                   	leave  
  4e:	c3                   	ret    

0000004f <main>:

int main() {
  4f:	f3 0f 1e fb          	endbr32 
  53:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  57:	83 e4 f0             	and    $0xfffffff0,%esp
  5a:	ff 71 fc             	pushl  -0x4(%ecx)
  5d:	55                   	push   %ebp
  5e:	89 e5                	mov    %esp,%ebp
  60:	51                   	push   %ecx
  61:	83 ec 14             	sub    $0x14,%esp
  setSchedPolicy(1); // policy 1: MLFQ
  64:	83 ec 0c             	sub    $0xc,%esp
  67:	6a 01                	push   $0x1
  69:	e8 91 03 00 00       	call   3ff <setSchedPolicy>
  6e:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < 3; i++) {
  71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  78:	eb 47                	jmp    c1 <main+0x72>
    int pid = fork();
  7a:	e8 d8 02 00 00       	call   357 <fork>
  7f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid == 0) {
  82:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  86:	75 35                	jne    bd <main+0x6e>
      for (int j = 0; j < 100; j++) {
  88:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8f:	eb 21                	jmp    b2 <main+0x63>
        workload(10000000);
  91:	83 ec 0c             	sub    $0xc,%esp
  94:	68 80 96 98 00       	push   $0x989680
  99:	e8 62 ff ff ff       	call   0 <workload>
  9e:	83 c4 10             	add    $0x10,%esp
        sleep(1);
  a1:	83 ec 0c             	sub    $0xc,%esp
  a4:	6a 01                	push   $0x1
  a6:	e8 44 03 00 00       	call   3ef <sleep>
  ab:	83 c4 10             	add    $0x10,%esp
      for (int j = 0; j < 100; j++) {
  ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  b2:	83 7d f0 63          	cmpl   $0x63,-0x10(%ebp)
  b6:	7e d9                	jle    91 <main+0x42>
      }
      exit();
  b8:	e8 a2 02 00 00       	call   35f <exit>
  for (int i = 0; i < 3; i++) {
  bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  c1:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  c5:	7e b3                	jle    7a <main+0x2b>
    }
  }

  for (int i = 0; i < 3; i++)
  c7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ce:	eb 09                	jmp    d9 <main+0x8a>
    wait();
  d0:	e8 92 02 00 00       	call   367 <wait>
  for (int i = 0; i < 3; i++)
  d5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  d9:	83 7d ec 02          	cmpl   $0x2,-0x14(%ebp)
  dd:	7e f1                	jle    d0 <main+0x81>

  exit();
  df:	e8 7b 02 00 00       	call   35f <exit>

000000e4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  e7:	57                   	push   %edi
  e8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ec:	8b 55 10             	mov    0x10(%ebp),%edx
  ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  f2:	89 cb                	mov    %ecx,%ebx
  f4:	89 df                	mov    %ebx,%edi
  f6:	89 d1                	mov    %edx,%ecx
  f8:	fc                   	cld    
  f9:	f3 aa                	rep stos %al,%es:(%edi)
  fb:	89 ca                	mov    %ecx,%edx
  fd:	89 fb                	mov    %edi,%ebx
  ff:	89 5d 08             	mov    %ebx,0x8(%ebp)
 102:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 105:	90                   	nop
 106:	5b                   	pop    %ebx
 107:	5f                   	pop    %edi
 108:	5d                   	pop    %ebp
 109:	c3                   	ret    

0000010a <strcpy>:



char*
strcpy(char *s, char *t)
{
 10a:	f3 0f 1e fb          	endbr32 
 10e:	55                   	push   %ebp
 10f:	89 e5                	mov    %esp,%ebp
 111:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 114:	8b 45 08             	mov    0x8(%ebp),%eax
 117:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 11a:	90                   	nop
 11b:	8b 55 0c             	mov    0xc(%ebp),%edx
 11e:	8d 42 01             	lea    0x1(%edx),%eax
 121:	89 45 0c             	mov    %eax,0xc(%ebp)
 124:	8b 45 08             	mov    0x8(%ebp),%eax
 127:	8d 48 01             	lea    0x1(%eax),%ecx
 12a:	89 4d 08             	mov    %ecx,0x8(%ebp)
 12d:	0f b6 12             	movzbl (%edx),%edx
 130:	88 10                	mov    %dl,(%eax)
 132:	0f b6 00             	movzbl (%eax),%eax
 135:	84 c0                	test   %al,%al
 137:	75 e2                	jne    11b <strcpy+0x11>
    ;
  return os;
 139:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13c:	c9                   	leave  
 13d:	c3                   	ret    

0000013e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13e:	f3 0f 1e fb          	endbr32 
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 145:	eb 08                	jmp    14f <strcmp+0x11>
    p++, q++;
 147:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	0f b6 00             	movzbl (%eax),%eax
 155:	84 c0                	test   %al,%al
 157:	74 10                	je     169 <strcmp+0x2b>
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	0f b6 10             	movzbl (%eax),%edx
 15f:	8b 45 0c             	mov    0xc(%ebp),%eax
 162:	0f b6 00             	movzbl (%eax),%eax
 165:	38 c2                	cmp    %al,%dl
 167:	74 de                	je     147 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 169:	8b 45 08             	mov    0x8(%ebp),%eax
 16c:	0f b6 00             	movzbl (%eax),%eax
 16f:	0f b6 d0             	movzbl %al,%edx
 172:	8b 45 0c             	mov    0xc(%ebp),%eax
 175:	0f b6 00             	movzbl (%eax),%eax
 178:	0f b6 c0             	movzbl %al,%eax
 17b:	29 c2                	sub    %eax,%edx
 17d:	89 d0                	mov    %edx,%eax
}
 17f:	5d                   	pop    %ebp
 180:	c3                   	ret    

00000181 <strlen>:

uint
strlen(char *s)
{
 181:	f3 0f 1e fb          	endbr32 
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 18b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 192:	eb 04                	jmp    198 <strlen+0x17>
 194:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 198:	8b 55 fc             	mov    -0x4(%ebp),%edx
 19b:	8b 45 08             	mov    0x8(%ebp),%eax
 19e:	01 d0                	add    %edx,%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	84 c0                	test   %al,%al
 1a5:	75 ed                	jne    194 <strlen+0x13>
    ;
  return n;
 1a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1aa:	c9                   	leave  
 1ab:	c3                   	ret    

000001ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ac:	f3 0f 1e fb          	endbr32 
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1b3:	8b 45 10             	mov    0x10(%ebp),%eax
 1b6:	50                   	push   %eax
 1b7:	ff 75 0c             	pushl  0xc(%ebp)
 1ba:	ff 75 08             	pushl  0x8(%ebp)
 1bd:	e8 22 ff ff ff       	call   e4 <stosb>
 1c2:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1c5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c8:	c9                   	leave  
 1c9:	c3                   	ret    

000001ca <strchr>:

char*
strchr(const char *s, char c)
{
 1ca:	f3 0f 1e fb          	endbr32 
 1ce:	55                   	push   %ebp
 1cf:	89 e5                	mov    %esp,%ebp
 1d1:	83 ec 04             	sub    $0x4,%esp
 1d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1da:	eb 14                	jmp    1f0 <strchr+0x26>
    if(*s == c)
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	0f b6 00             	movzbl (%eax),%eax
 1e2:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1e5:	75 05                	jne    1ec <strchr+0x22>
      return (char*)s;
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ea:	eb 13                	jmp    1ff <strchr+0x35>
  for(; *s; s++)
 1ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	0f b6 00             	movzbl (%eax),%eax
 1f6:	84 c0                	test   %al,%al
 1f8:	75 e2                	jne    1dc <strchr+0x12>
  return 0;
 1fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1ff:	c9                   	leave  
 200:	c3                   	ret    

00000201 <gets>:

char*
gets(char *buf, int max)
{
 201:	f3 0f 1e fb          	endbr32 
 205:	55                   	push   %ebp
 206:	89 e5                	mov    %esp,%ebp
 208:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 212:	eb 42                	jmp    256 <gets+0x55>
    cc = read(0, &c, 1);
 214:	83 ec 04             	sub    $0x4,%esp
 217:	6a 01                	push   $0x1
 219:	8d 45 ef             	lea    -0x11(%ebp),%eax
 21c:	50                   	push   %eax
 21d:	6a 00                	push   $0x0
 21f:	e8 53 01 00 00       	call   377 <read>
 224:	83 c4 10             	add    $0x10,%esp
 227:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 22a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 22e:	7e 33                	jle    263 <gets+0x62>
      break;
    buf[i++] = c;
 230:	8b 45 f4             	mov    -0xc(%ebp),%eax
 233:	8d 50 01             	lea    0x1(%eax),%edx
 236:	89 55 f4             	mov    %edx,-0xc(%ebp)
 239:	89 c2                	mov    %eax,%edx
 23b:	8b 45 08             	mov    0x8(%ebp),%eax
 23e:	01 c2                	add    %eax,%edx
 240:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 244:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 246:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24a:	3c 0a                	cmp    $0xa,%al
 24c:	74 16                	je     264 <gets+0x63>
 24e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 252:	3c 0d                	cmp    $0xd,%al
 254:	74 0e                	je     264 <gets+0x63>
  for(i=0; i+1 < max; ){
 256:	8b 45 f4             	mov    -0xc(%ebp),%eax
 259:	83 c0 01             	add    $0x1,%eax
 25c:	39 45 0c             	cmp    %eax,0xc(%ebp)
 25f:	7f b3                	jg     214 <gets+0x13>
 261:	eb 01                	jmp    264 <gets+0x63>
      break;
 263:	90                   	nop
      break;
  }
  buf[i] = '\0';
 264:	8b 55 f4             	mov    -0xc(%ebp),%edx
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	01 d0                	add    %edx,%eax
 26c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 26f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 272:	c9                   	leave  
 273:	c3                   	ret    

00000274 <stat>:

int
stat(char *n, struct stat *st)
{
 274:	f3 0f 1e fb          	endbr32 
 278:	55                   	push   %ebp
 279:	89 e5                	mov    %esp,%ebp
 27b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27e:	83 ec 08             	sub    $0x8,%esp
 281:	6a 00                	push   $0x0
 283:	ff 75 08             	pushl  0x8(%ebp)
 286:	e8 14 01 00 00       	call   39f <open>
 28b:	83 c4 10             	add    $0x10,%esp
 28e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 291:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 295:	79 07                	jns    29e <stat+0x2a>
    return -1;
 297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 29c:	eb 25                	jmp    2c3 <stat+0x4f>
  r = fstat(fd, st);
 29e:	83 ec 08             	sub    $0x8,%esp
 2a1:	ff 75 0c             	pushl  0xc(%ebp)
 2a4:	ff 75 f4             	pushl  -0xc(%ebp)
 2a7:	e8 0b 01 00 00       	call   3b7 <fstat>
 2ac:	83 c4 10             	add    $0x10,%esp
 2af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b2:	83 ec 0c             	sub    $0xc,%esp
 2b5:	ff 75 f4             	pushl  -0xc(%ebp)
 2b8:	e8 ca 00 00 00       	call   387 <close>
 2bd:	83 c4 10             	add    $0x10,%esp
  return r;
 2c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c3:	c9                   	leave  
 2c4:	c3                   	ret    

000002c5 <atoi>:

int
atoi(const char *s)
{
 2c5:	f3 0f 1e fb          	endbr32 
 2c9:	55                   	push   %ebp
 2ca:	89 e5                	mov    %esp,%ebp
 2cc:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2cf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d6:	eb 25                	jmp    2fd <atoi+0x38>
    n = n*10 + *s++ - '0';
 2d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2db:	89 d0                	mov    %edx,%eax
 2dd:	c1 e0 02             	shl    $0x2,%eax
 2e0:	01 d0                	add    %edx,%eax
 2e2:	01 c0                	add    %eax,%eax
 2e4:	89 c1                	mov    %eax,%ecx
 2e6:	8b 45 08             	mov    0x8(%ebp),%eax
 2e9:	8d 50 01             	lea    0x1(%eax),%edx
 2ec:	89 55 08             	mov    %edx,0x8(%ebp)
 2ef:	0f b6 00             	movzbl (%eax),%eax
 2f2:	0f be c0             	movsbl %al,%eax
 2f5:	01 c8                	add    %ecx,%eax
 2f7:	83 e8 30             	sub    $0x30,%eax
 2fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2fd:	8b 45 08             	mov    0x8(%ebp),%eax
 300:	0f b6 00             	movzbl (%eax),%eax
 303:	3c 2f                	cmp    $0x2f,%al
 305:	7e 0a                	jle    311 <atoi+0x4c>
 307:	8b 45 08             	mov    0x8(%ebp),%eax
 30a:	0f b6 00             	movzbl (%eax),%eax
 30d:	3c 39                	cmp    $0x39,%al
 30f:	7e c7                	jle    2d8 <atoi+0x13>
  return n;
 311:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 314:	c9                   	leave  
 315:	c3                   	ret    

00000316 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 316:	f3 0f 1e fb          	endbr32 
 31a:	55                   	push   %ebp
 31b:	89 e5                	mov    %esp,%ebp
 31d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 320:	8b 45 08             	mov    0x8(%ebp),%eax
 323:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 326:	8b 45 0c             	mov    0xc(%ebp),%eax
 329:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 32c:	eb 17                	jmp    345 <memmove+0x2f>
    *dst++ = *src++;
 32e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 331:	8d 42 01             	lea    0x1(%edx),%eax
 334:	89 45 f8             	mov    %eax,-0x8(%ebp)
 337:	8b 45 fc             	mov    -0x4(%ebp),%eax
 33a:	8d 48 01             	lea    0x1(%eax),%ecx
 33d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 340:	0f b6 12             	movzbl (%edx),%edx
 343:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 345:	8b 45 10             	mov    0x10(%ebp),%eax
 348:	8d 50 ff             	lea    -0x1(%eax),%edx
 34b:	89 55 10             	mov    %edx,0x10(%ebp)
 34e:	85 c0                	test   %eax,%eax
 350:	7f dc                	jg     32e <memmove+0x18>
  return vdst;
 352:	8b 45 08             	mov    0x8(%ebp),%eax
}
 355:	c9                   	leave  
 356:	c3                   	ret    

00000357 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 357:	b8 01 00 00 00       	mov    $0x1,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <exit>:
SYSCALL(exit)
 35f:	b8 02 00 00 00       	mov    $0x2,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <wait>:
SYSCALL(wait)
 367:	b8 03 00 00 00       	mov    $0x3,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	ret    

0000036f <pipe>:
SYSCALL(pipe)
 36f:	b8 04 00 00 00       	mov    $0x4,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <read>:
SYSCALL(read)
 377:	b8 05 00 00 00       	mov    $0x5,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <write>:
SYSCALL(write)
 37f:	b8 10 00 00 00       	mov    $0x10,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <close>:
SYSCALL(close)
 387:	b8 15 00 00 00       	mov    $0x15,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <kill>:
SYSCALL(kill)
 38f:	b8 06 00 00 00       	mov    $0x6,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <exec>:
SYSCALL(exec)
 397:	b8 07 00 00 00       	mov    $0x7,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <open>:
SYSCALL(open)
 39f:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <mknod>:
SYSCALL(mknod)
 3a7:	b8 11 00 00 00       	mov    $0x11,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <unlink>:
SYSCALL(unlink)
 3af:	b8 12 00 00 00       	mov    $0x12,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <fstat>:
SYSCALL(fstat)
 3b7:	b8 08 00 00 00       	mov    $0x8,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <link>:
SYSCALL(link)
 3bf:	b8 13 00 00 00       	mov    $0x13,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <mkdir>:
SYSCALL(mkdir)
 3c7:	b8 14 00 00 00       	mov    $0x14,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <chdir>:
SYSCALL(chdir)
 3cf:	b8 09 00 00 00       	mov    $0x9,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <dup>:
SYSCALL(dup)
 3d7:	b8 0a 00 00 00       	mov    $0xa,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <getpid>:
SYSCALL(getpid)
 3df:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <sbrk>:
SYSCALL(sbrk)
 3e7:	b8 0c 00 00 00       	mov    $0xc,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <sleep>:
SYSCALL(sleep)
 3ef:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <uptime>:
SYSCALL(uptime)
 3f7:	b8 0e 00 00 00       	mov    $0xe,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 3ff:	b8 16 00 00 00       	mov    $0x16,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <getpinfo>:
SYSCALL(getpinfo)
 407:	b8 17 00 00 00       	mov    $0x17,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <yield>:
SYSCALL(yield)
 40f:	b8 18 00 00 00       	mov    $0x18,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 417:	f3 0f 1e fb          	endbr32 
 41b:	55                   	push   %ebp
 41c:	89 e5                	mov    %esp,%ebp
 41e:	83 ec 18             	sub    $0x18,%esp
 421:	8b 45 0c             	mov    0xc(%ebp),%eax
 424:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 427:	83 ec 04             	sub    $0x4,%esp
 42a:	6a 01                	push   $0x1
 42c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 42f:	50                   	push   %eax
 430:	ff 75 08             	pushl  0x8(%ebp)
 433:	e8 47 ff ff ff       	call   37f <write>
 438:	83 c4 10             	add    $0x10,%esp
}
 43b:	90                   	nop
 43c:	c9                   	leave  
 43d:	c3                   	ret    

0000043e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 43e:	f3 0f 1e fb          	endbr32 
 442:	55                   	push   %ebp
 443:	89 e5                	mov    %esp,%ebp
 445:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 448:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 44f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 453:	74 17                	je     46c <printint+0x2e>
 455:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 459:	79 11                	jns    46c <printint+0x2e>
    neg = 1;
 45b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 462:	8b 45 0c             	mov    0xc(%ebp),%eax
 465:	f7 d8                	neg    %eax
 467:	89 45 ec             	mov    %eax,-0x14(%ebp)
 46a:	eb 06                	jmp    472 <printint+0x34>
  } else {
    x = xx;
 46c:	8b 45 0c             	mov    0xc(%ebp),%eax
 46f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 472:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 479:	8b 4d 10             	mov    0x10(%ebp),%ecx
 47c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 47f:	ba 00 00 00 00       	mov    $0x0,%edx
 484:	f7 f1                	div    %ecx
 486:	89 d1                	mov    %edx,%ecx
 488:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48b:	8d 50 01             	lea    0x1(%eax),%edx
 48e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 491:	0f b6 91 28 0b 00 00 	movzbl 0xb28(%ecx),%edx
 498:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 49c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 49f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a2:	ba 00 00 00 00       	mov    $0x0,%edx
 4a7:	f7 f1                	div    %ecx
 4a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4b0:	75 c7                	jne    479 <printint+0x3b>
  if(neg)
 4b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b6:	74 2d                	je     4e5 <printint+0xa7>
    buf[i++] = '-';
 4b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4bb:	8d 50 01             	lea    0x1(%eax),%edx
 4be:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c1:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4c6:	eb 1d                	jmp    4e5 <printint+0xa7>
    putc(fd, buf[i]);
 4c8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ce:	01 d0                	add    %edx,%eax
 4d0:	0f b6 00             	movzbl (%eax),%eax
 4d3:	0f be c0             	movsbl %al,%eax
 4d6:	83 ec 08             	sub    $0x8,%esp
 4d9:	50                   	push   %eax
 4da:	ff 75 08             	pushl  0x8(%ebp)
 4dd:	e8 35 ff ff ff       	call   417 <putc>
 4e2:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4e5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ed:	79 d9                	jns    4c8 <printint+0x8a>
}
 4ef:	90                   	nop
 4f0:	90                   	nop
 4f1:	c9                   	leave  
 4f2:	c3                   	ret    

000004f3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4f3:	f3 0f 1e fb          	endbr32 
 4f7:	55                   	push   %ebp
 4f8:	89 e5                	mov    %esp,%ebp
 4fa:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4fd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 504:	8d 45 0c             	lea    0xc(%ebp),%eax
 507:	83 c0 04             	add    $0x4,%eax
 50a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 50d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 514:	e9 59 01 00 00       	jmp    672 <printf+0x17f>
    c = fmt[i] & 0xff;
 519:	8b 55 0c             	mov    0xc(%ebp),%edx
 51c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 51f:	01 d0                	add    %edx,%eax
 521:	0f b6 00             	movzbl (%eax),%eax
 524:	0f be c0             	movsbl %al,%eax
 527:	25 ff 00 00 00       	and    $0xff,%eax
 52c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 52f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 533:	75 2c                	jne    561 <printf+0x6e>
      if(c == '%'){
 535:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 539:	75 0c                	jne    547 <printf+0x54>
        state = '%';
 53b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 542:	e9 27 01 00 00       	jmp    66e <printf+0x17b>
      } else {
        putc(fd, c);
 547:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 54a:	0f be c0             	movsbl %al,%eax
 54d:	83 ec 08             	sub    $0x8,%esp
 550:	50                   	push   %eax
 551:	ff 75 08             	pushl  0x8(%ebp)
 554:	e8 be fe ff ff       	call   417 <putc>
 559:	83 c4 10             	add    $0x10,%esp
 55c:	e9 0d 01 00 00       	jmp    66e <printf+0x17b>
      }
    } else if(state == '%'){
 561:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 565:	0f 85 03 01 00 00    	jne    66e <printf+0x17b>
      if(c == 'd'){
 56b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 56f:	75 1e                	jne    58f <printf+0x9c>
        printint(fd, *ap, 10, 1);
 571:	8b 45 e8             	mov    -0x18(%ebp),%eax
 574:	8b 00                	mov    (%eax),%eax
 576:	6a 01                	push   $0x1
 578:	6a 0a                	push   $0xa
 57a:	50                   	push   %eax
 57b:	ff 75 08             	pushl  0x8(%ebp)
 57e:	e8 bb fe ff ff       	call   43e <printint>
 583:	83 c4 10             	add    $0x10,%esp
        ap++;
 586:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 58a:	e9 d8 00 00 00       	jmp    667 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 58f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 593:	74 06                	je     59b <printf+0xa8>
 595:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 599:	75 1e                	jne    5b9 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 59b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 59e:	8b 00                	mov    (%eax),%eax
 5a0:	6a 00                	push   $0x0
 5a2:	6a 10                	push   $0x10
 5a4:	50                   	push   %eax
 5a5:	ff 75 08             	pushl  0x8(%ebp)
 5a8:	e8 91 fe ff ff       	call   43e <printint>
 5ad:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b4:	e9 ae 00 00 00       	jmp    667 <printf+0x174>
      } else if(c == 's'){
 5b9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5bd:	75 43                	jne    602 <printf+0x10f>
        s = (char*)*ap;
 5bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c2:	8b 00                	mov    (%eax),%eax
 5c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5c7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5cf:	75 25                	jne    5f6 <printf+0x103>
          s = "(null)";
 5d1:	c7 45 f4 ba 08 00 00 	movl   $0x8ba,-0xc(%ebp)
        while(*s != 0){
 5d8:	eb 1c                	jmp    5f6 <printf+0x103>
          putc(fd, *s);
 5da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5dd:	0f b6 00             	movzbl (%eax),%eax
 5e0:	0f be c0             	movsbl %al,%eax
 5e3:	83 ec 08             	sub    $0x8,%esp
 5e6:	50                   	push   %eax
 5e7:	ff 75 08             	pushl  0x8(%ebp)
 5ea:	e8 28 fe ff ff       	call   417 <putc>
 5ef:	83 c4 10             	add    $0x10,%esp
          s++;
 5f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f9:	0f b6 00             	movzbl (%eax),%eax
 5fc:	84 c0                	test   %al,%al
 5fe:	75 da                	jne    5da <printf+0xe7>
 600:	eb 65                	jmp    667 <printf+0x174>
        }
      } else if(c == 'c'){
 602:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 606:	75 1d                	jne    625 <printf+0x132>
        putc(fd, *ap);
 608:	8b 45 e8             	mov    -0x18(%ebp),%eax
 60b:	8b 00                	mov    (%eax),%eax
 60d:	0f be c0             	movsbl %al,%eax
 610:	83 ec 08             	sub    $0x8,%esp
 613:	50                   	push   %eax
 614:	ff 75 08             	pushl  0x8(%ebp)
 617:	e8 fb fd ff ff       	call   417 <putc>
 61c:	83 c4 10             	add    $0x10,%esp
        ap++;
 61f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 623:	eb 42                	jmp    667 <printf+0x174>
      } else if(c == '%'){
 625:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 629:	75 17                	jne    642 <printf+0x14f>
        putc(fd, c);
 62b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 62e:	0f be c0             	movsbl %al,%eax
 631:	83 ec 08             	sub    $0x8,%esp
 634:	50                   	push   %eax
 635:	ff 75 08             	pushl  0x8(%ebp)
 638:	e8 da fd ff ff       	call   417 <putc>
 63d:	83 c4 10             	add    $0x10,%esp
 640:	eb 25                	jmp    667 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 642:	83 ec 08             	sub    $0x8,%esp
 645:	6a 25                	push   $0x25
 647:	ff 75 08             	pushl  0x8(%ebp)
 64a:	e8 c8 fd ff ff       	call   417 <putc>
 64f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 652:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 655:	0f be c0             	movsbl %al,%eax
 658:	83 ec 08             	sub    $0x8,%esp
 65b:	50                   	push   %eax
 65c:	ff 75 08             	pushl  0x8(%ebp)
 65f:	e8 b3 fd ff ff       	call   417 <putc>
 664:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 667:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 66e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 672:	8b 55 0c             	mov    0xc(%ebp),%edx
 675:	8b 45 f0             	mov    -0x10(%ebp),%eax
 678:	01 d0                	add    %edx,%eax
 67a:	0f b6 00             	movzbl (%eax),%eax
 67d:	84 c0                	test   %al,%al
 67f:	0f 85 94 fe ff ff    	jne    519 <printf+0x26>
    }
  }
}
 685:	90                   	nop
 686:	90                   	nop
 687:	c9                   	leave  
 688:	c3                   	ret    

00000689 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 689:	f3 0f 1e fb          	endbr32 
 68d:	55                   	push   %ebp
 68e:	89 e5                	mov    %esp,%ebp
 690:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 693:	8b 45 08             	mov    0x8(%ebp),%eax
 696:	83 e8 08             	sub    $0x8,%eax
 699:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69c:	a1 44 0b 00 00       	mov    0xb44,%eax
 6a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6a4:	eb 24                	jmp    6ca <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a9:	8b 00                	mov    (%eax),%eax
 6ab:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6ae:	72 12                	jb     6c2 <free+0x39>
 6b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b6:	77 24                	ja     6dc <free+0x53>
 6b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bb:	8b 00                	mov    (%eax),%eax
 6bd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6c0:	72 1a                	jb     6dc <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c5:	8b 00                	mov    (%eax),%eax
 6c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d0:	76 d4                	jbe    6a6 <free+0x1d>
 6d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d5:	8b 00                	mov    (%eax),%eax
 6d7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6da:	73 ca                	jae    6a6 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6df:	8b 40 04             	mov    0x4(%eax),%eax
 6e2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ec:	01 c2                	add    %eax,%edx
 6ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f1:	8b 00                	mov    (%eax),%eax
 6f3:	39 c2                	cmp    %eax,%edx
 6f5:	75 24                	jne    71b <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 6f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fa:	8b 50 04             	mov    0x4(%eax),%edx
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	8b 00                	mov    (%eax),%eax
 702:	8b 40 04             	mov    0x4(%eax),%eax
 705:	01 c2                	add    %eax,%edx
 707:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	8b 00                	mov    (%eax),%eax
 712:	8b 10                	mov    (%eax),%edx
 714:	8b 45 f8             	mov    -0x8(%ebp),%eax
 717:	89 10                	mov    %edx,(%eax)
 719:	eb 0a                	jmp    725 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 71b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71e:	8b 10                	mov    (%eax),%edx
 720:	8b 45 f8             	mov    -0x8(%ebp),%eax
 723:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	8b 40 04             	mov    0x4(%eax),%eax
 72b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 732:	8b 45 fc             	mov    -0x4(%ebp),%eax
 735:	01 d0                	add    %edx,%eax
 737:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 73a:	75 20                	jne    75c <free+0xd3>
    p->s.size += bp->s.size;
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8b 50 04             	mov    0x4(%eax),%edx
 742:	8b 45 f8             	mov    -0x8(%ebp),%eax
 745:	8b 40 04             	mov    0x4(%eax),%eax
 748:	01 c2                	add    %eax,%edx
 74a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 750:	8b 45 f8             	mov    -0x8(%ebp),%eax
 753:	8b 10                	mov    (%eax),%edx
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	89 10                	mov    %edx,(%eax)
 75a:	eb 08                	jmp    764 <free+0xdb>
  } else
    p->s.ptr = bp;
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 762:	89 10                	mov    %edx,(%eax)
  freep = p;
 764:	8b 45 fc             	mov    -0x4(%ebp),%eax
 767:	a3 44 0b 00 00       	mov    %eax,0xb44
}
 76c:	90                   	nop
 76d:	c9                   	leave  
 76e:	c3                   	ret    

0000076f <morecore>:

static Header*
morecore(uint nu)
{
 76f:	f3 0f 1e fb          	endbr32 
 773:	55                   	push   %ebp
 774:	89 e5                	mov    %esp,%ebp
 776:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 779:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 780:	77 07                	ja     789 <morecore+0x1a>
    nu = 4096;
 782:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 789:	8b 45 08             	mov    0x8(%ebp),%eax
 78c:	c1 e0 03             	shl    $0x3,%eax
 78f:	83 ec 0c             	sub    $0xc,%esp
 792:	50                   	push   %eax
 793:	e8 4f fc ff ff       	call   3e7 <sbrk>
 798:	83 c4 10             	add    $0x10,%esp
 79b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 79e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7a2:	75 07                	jne    7ab <morecore+0x3c>
    return 0;
 7a4:	b8 00 00 00 00       	mov    $0x0,%eax
 7a9:	eb 26                	jmp    7d1 <morecore+0x62>
  hp = (Header*)p;
 7ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b4:	8b 55 08             	mov    0x8(%ebp),%edx
 7b7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bd:	83 c0 08             	add    $0x8,%eax
 7c0:	83 ec 0c             	sub    $0xc,%esp
 7c3:	50                   	push   %eax
 7c4:	e8 c0 fe ff ff       	call   689 <free>
 7c9:	83 c4 10             	add    $0x10,%esp
  return freep;
 7cc:	a1 44 0b 00 00       	mov    0xb44,%eax
}
 7d1:	c9                   	leave  
 7d2:	c3                   	ret    

000007d3 <malloc>:

void*
malloc(uint nbytes)
{
 7d3:	f3 0f 1e fb          	endbr32 
 7d7:	55                   	push   %ebp
 7d8:	89 e5                	mov    %esp,%ebp
 7da:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7dd:	8b 45 08             	mov    0x8(%ebp),%eax
 7e0:	83 c0 07             	add    $0x7,%eax
 7e3:	c1 e8 03             	shr    $0x3,%eax
 7e6:	83 c0 01             	add    $0x1,%eax
 7e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7ec:	a1 44 0b 00 00       	mov    0xb44,%eax
 7f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7f8:	75 23                	jne    81d <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 7fa:	c7 45 f0 3c 0b 00 00 	movl   $0xb3c,-0x10(%ebp)
 801:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804:	a3 44 0b 00 00       	mov    %eax,0xb44
 809:	a1 44 0b 00 00       	mov    0xb44,%eax
 80e:	a3 3c 0b 00 00       	mov    %eax,0xb3c
    base.s.size = 0;
 813:	c7 05 40 0b 00 00 00 	movl   $0x0,0xb40
 81a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 825:	8b 45 f4             	mov    -0xc(%ebp),%eax
 828:	8b 40 04             	mov    0x4(%eax),%eax
 82b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 82e:	77 4d                	ja     87d <malloc+0xaa>
      if(p->s.size == nunits)
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	8b 40 04             	mov    0x4(%eax),%eax
 836:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 839:	75 0c                	jne    847 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 83b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83e:	8b 10                	mov    (%eax),%edx
 840:	8b 45 f0             	mov    -0x10(%ebp),%eax
 843:	89 10                	mov    %edx,(%eax)
 845:	eb 26                	jmp    86d <malloc+0x9a>
      else {
        p->s.size -= nunits;
 847:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84a:	8b 40 04             	mov    0x4(%eax),%eax
 84d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 850:	89 c2                	mov    %eax,%edx
 852:	8b 45 f4             	mov    -0xc(%ebp),%eax
 855:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 858:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85b:	8b 40 04             	mov    0x4(%eax),%eax
 85e:	c1 e0 03             	shl    $0x3,%eax
 861:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	8b 55 ec             	mov    -0x14(%ebp),%edx
 86a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 86d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 870:	a3 44 0b 00 00       	mov    %eax,0xb44
      return (void*)(p + 1);
 875:	8b 45 f4             	mov    -0xc(%ebp),%eax
 878:	83 c0 08             	add    $0x8,%eax
 87b:	eb 3b                	jmp    8b8 <malloc+0xe5>
    }
    if(p == freep)
 87d:	a1 44 0b 00 00       	mov    0xb44,%eax
 882:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 885:	75 1e                	jne    8a5 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 887:	83 ec 0c             	sub    $0xc,%esp
 88a:	ff 75 ec             	pushl  -0x14(%ebp)
 88d:	e8 dd fe ff ff       	call   76f <morecore>
 892:	83 c4 10             	add    $0x10,%esp
 895:	89 45 f4             	mov    %eax,-0xc(%ebp)
 898:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 89c:	75 07                	jne    8a5 <malloc+0xd2>
        return 0;
 89e:	b8 00 00 00 00       	mov    $0x0,%eax
 8a3:	eb 13                	jmp    8b8 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ae:	8b 00                	mov    (%eax),%eax
 8b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8b3:	e9 6d ff ff ff       	jmp    825 <malloc+0x52>
  }
}
 8b8:	c9                   	leave  
 8b9:	c3                   	ret    
