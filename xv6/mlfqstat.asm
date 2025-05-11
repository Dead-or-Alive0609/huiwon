
_mlfqstat:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

int main() {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	81 ec 38 0c 00 00    	sub    $0xc38,%esp
  struct pstat ps;
  if (getpinfo(&ps) != 0) {
  17:	83 ec 0c             	sub    $0xc,%esp
  1a:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
  20:	50                   	push   %eax
  21:	e8 65 04 00 00       	call   48b <getpinfo>
  26:	83 c4 10             	add    $0x10,%esp
  29:	85 c0                	test   %eax,%eax
  2b:	74 17                	je     44 <main+0x44>
    printf(1, "getpinfo failed\n");
  2d:	83 ec 08             	sub    $0x8,%esp
  30:	68 28 09 00 00       	push   $0x928
  35:	6a 01                	push   $0x1
  37:	e8 33 05 00 00       	call   56f <printf>
  3c:	83 c4 10             	add    $0x10,%esp
    exit();
  3f:	e8 9f 03 00 00       	call   3e3 <exit>
  }

  for (int i = 0; i < NPROC; i++) {
  44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  4b:	e9 2d 01 00 00       	jmp    17d <main+0x17d>
    if (ps.inuse[i]) {
  50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  53:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
  5a:	85 c0                	test   %eax,%eax
  5c:	0f 84 17 01 00 00    	je     179 <main+0x179>
      printf(1, "pid %d | state %d | prio %d | ticks = [%d %d %d %d] | wait = [%d %d %d %d]\n",
  62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  65:	c1 e0 04             	shl    $0x4,%eax
  68:	8d 40 e8             	lea    -0x18(%eax),%eax
  6b:	01 e8                	add    %ebp,%eax
  6d:	2d f8 03 00 00       	sub    $0x3f8,%eax
  72:	8b 38                	mov    (%eax),%edi
  74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  77:	c1 e0 04             	shl    $0x4,%eax
  7a:	8d 40 e8             	lea    -0x18(%eax),%eax
  7d:	01 e8                	add    %ebp,%eax
  7f:	2d fc 03 00 00       	sub    $0x3fc,%eax
  84:	8b 00                	mov    (%eax),%eax
  86:	89 85 d4 f3 ff ff    	mov    %eax,-0xc2c(%ebp)
  8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8f:	c1 e0 04             	shl    $0x4,%eax
  92:	8d 50 e8             	lea    -0x18(%eax),%edx
  95:	8d 04 2a             	lea    (%edx,%ebp,1),%eax
  98:	2d 00 04 00 00       	sub    $0x400,%eax
  9d:	8b 08                	mov    (%eax),%ecx
  9f:	89 8d d0 f3 ff ff    	mov    %ecx,-0xc30(%ebp)
  a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  a8:	83 e8 80             	sub    $0xffffff80,%eax
  ab:	c1 e0 04             	shl    $0x4,%eax
  ae:	8d 58 e8             	lea    -0x18(%eax),%ebx
  b1:	8d 04 2b             	lea    (%ebx,%ebp,1),%eax
  b4:	2d 04 0c 00 00       	sub    $0xc04,%eax
  b9:	8b 30                	mov    (%eax),%esi
  bb:	89 b5 cc f3 ff ff    	mov    %esi,-0xc34(%ebp)
  c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  c4:	c1 e0 04             	shl    $0x4,%eax
  c7:	8d 50 e8             	lea    -0x18(%eax),%edx
  ca:	8d 04 2a             	lea    (%edx,%ebp,1),%eax
  cd:	2d f8 07 00 00       	sub    $0x7f8,%eax
  d2:	8b 18                	mov    (%eax),%ebx
  d4:	89 9d c8 f3 ff ff    	mov    %ebx,-0xc38(%ebp)
  da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  dd:	c1 e0 04             	shl    $0x4,%eax
  e0:	8d 50 e8             	lea    -0x18(%eax),%edx
  e3:	8d 04 2a             	lea    (%edx,%ebp,1),%eax
  e6:	2d fc 07 00 00       	sub    $0x7fc,%eax
  eb:	8b 10                	mov    (%eax),%edx
  ed:	89 95 c4 f3 ff ff    	mov    %edx,-0xc3c(%ebp)
  f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  f6:	c1 e0 04             	shl    $0x4,%eax
  f9:	8d 40 e8             	lea    -0x18(%eax),%eax
  fc:	01 e8                	add    %ebp,%eax
  fe:	2d 00 08 00 00       	sub    $0x800,%eax
 103:	8b 30                	mov    (%eax),%esi
 105:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 108:	83 c0 40             	add    $0x40,%eax
 10b:	c1 e0 04             	shl    $0x4,%eax
 10e:	8d 40 e8             	lea    -0x18(%eax),%eax
 111:	01 e8                	add    %ebp,%eax
 113:	2d 04 0c 00 00       	sub    $0xc04,%eax
 118:	8b 18                	mov    (%eax),%ebx
 11a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 11d:	83 e8 80             	sub    $0xffffff80,%eax
 120:	8b 8c 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%ecx
 127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 12a:	05 c0 00 00 00       	add    $0xc0,%eax
 12f:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 136:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 139:	83 c0 40             	add    $0x40,%eax
 13c:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 143:	83 ec 0c             	sub    $0xc,%esp
 146:	57                   	push   %edi
 147:	ff b5 d4 f3 ff ff    	push   -0xc2c(%ebp)
 14d:	ff b5 d0 f3 ff ff    	push   -0xc30(%ebp)
 153:	ff b5 cc f3 ff ff    	push   -0xc34(%ebp)
 159:	ff b5 c8 f3 ff ff    	push   -0xc38(%ebp)
 15f:	ff b5 c4 f3 ff ff    	push   -0xc3c(%ebp)
 165:	56                   	push   %esi
 166:	53                   	push   %ebx
 167:	51                   	push   %ecx
 168:	52                   	push   %edx
 169:	50                   	push   %eax
 16a:	68 3c 09 00 00       	push   $0x93c
 16f:	6a 01                	push   $0x1
 171:	e8 f9 03 00 00       	call   56f <printf>
 176:	83 c4 40             	add    $0x40,%esp
  for (int i = 0; i < NPROC; i++) {
 179:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 17d:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 181:	0f 8e c9 fe ff ff    	jle    50 <main+0x50>
        ps.ticks[i][0], ps.ticks[i][1], ps.ticks[i][2], ps.ticks[i][3],
        ps.wait_ticks[i][0], ps.wait_ticks[i][1], ps.wait_ticks[i][2], ps.wait_ticks[i][3]);
    }
  }

  exit();
 187:	e8 57 02 00 00       	call   3e3 <exit>

0000018c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	57                   	push   %edi
 190:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 191:	8b 4d 08             	mov    0x8(%ebp),%ecx
 194:	8b 55 10             	mov    0x10(%ebp),%edx
 197:	8b 45 0c             	mov    0xc(%ebp),%eax
 19a:	89 cb                	mov    %ecx,%ebx
 19c:	89 df                	mov    %ebx,%edi
 19e:	89 d1                	mov    %edx,%ecx
 1a0:	fc                   	cld    
 1a1:	f3 aa                	rep stos %al,%es:(%edi)
 1a3:	89 ca                	mov    %ecx,%edx
 1a5:	89 fb                	mov    %edi,%ebx
 1a7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1aa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1ad:	90                   	nop
 1ae:	5b                   	pop    %ebx
 1af:	5f                   	pop    %edi
 1b0:	5d                   	pop    %ebp
 1b1:	c3                   	ret    

000001b2 <strcpy>:



char*
strcpy(char *s, char *t)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1be:	90                   	nop
 1bf:	8b 55 0c             	mov    0xc(%ebp),%edx
 1c2:	8d 42 01             	lea    0x1(%edx),%eax
 1c5:	89 45 0c             	mov    %eax,0xc(%ebp)
 1c8:	8b 45 08             	mov    0x8(%ebp),%eax
 1cb:	8d 48 01             	lea    0x1(%eax),%ecx
 1ce:	89 4d 08             	mov    %ecx,0x8(%ebp)
 1d1:	0f b6 12             	movzbl (%edx),%edx
 1d4:	88 10                	mov    %dl,(%eax)
 1d6:	0f b6 00             	movzbl (%eax),%eax
 1d9:	84 c0                	test   %al,%al
 1db:	75 e2                	jne    1bf <strcpy+0xd>
    ;
  return os;
 1dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1e0:	c9                   	leave  
 1e1:	c3                   	ret    

000001e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1e5:	eb 08                	jmp    1ef <strcmp+0xd>
    p++, q++;
 1e7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1eb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	0f b6 00             	movzbl (%eax),%eax
 1f5:	84 c0                	test   %al,%al
 1f7:	74 10                	je     209 <strcmp+0x27>
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	0f b6 10             	movzbl (%eax),%edx
 1ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 202:	0f b6 00             	movzbl (%eax),%eax
 205:	38 c2                	cmp    %al,%dl
 207:	74 de                	je     1e7 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 209:	8b 45 08             	mov    0x8(%ebp),%eax
 20c:	0f b6 00             	movzbl (%eax),%eax
 20f:	0f b6 d0             	movzbl %al,%edx
 212:	8b 45 0c             	mov    0xc(%ebp),%eax
 215:	0f b6 00             	movzbl (%eax),%eax
 218:	0f b6 c8             	movzbl %al,%ecx
 21b:	89 d0                	mov    %edx,%eax
 21d:	29 c8                	sub    %ecx,%eax
}
 21f:	5d                   	pop    %ebp
 220:	c3                   	ret    

00000221 <strlen>:

uint
strlen(char *s)
{
 221:	55                   	push   %ebp
 222:	89 e5                	mov    %esp,%ebp
 224:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 227:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 22e:	eb 04                	jmp    234 <strlen+0x13>
 230:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 234:	8b 55 fc             	mov    -0x4(%ebp),%edx
 237:	8b 45 08             	mov    0x8(%ebp),%eax
 23a:	01 d0                	add    %edx,%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	84 c0                	test   %al,%al
 241:	75 ed                	jne    230 <strlen+0xf>
    ;
  return n;
 243:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 246:	c9                   	leave  
 247:	c3                   	ret    

00000248 <memset>:

void*
memset(void *dst, int c, uint n)
{
 248:	55                   	push   %ebp
 249:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 24b:	8b 45 10             	mov    0x10(%ebp),%eax
 24e:	50                   	push   %eax
 24f:	ff 75 0c             	push   0xc(%ebp)
 252:	ff 75 08             	push   0x8(%ebp)
 255:	e8 32 ff ff ff       	call   18c <stosb>
 25a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 25d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 260:	c9                   	leave  
 261:	c3                   	ret    

00000262 <strchr>:

char*
strchr(const char *s, char c)
{
 262:	55                   	push   %ebp
 263:	89 e5                	mov    %esp,%ebp
 265:	83 ec 04             	sub    $0x4,%esp
 268:	8b 45 0c             	mov    0xc(%ebp),%eax
 26b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 26e:	eb 14                	jmp    284 <strchr+0x22>
    if(*s == c)
 270:	8b 45 08             	mov    0x8(%ebp),%eax
 273:	0f b6 00             	movzbl (%eax),%eax
 276:	38 45 fc             	cmp    %al,-0x4(%ebp)
 279:	75 05                	jne    280 <strchr+0x1e>
      return (char*)s;
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	eb 13                	jmp    293 <strchr+0x31>
  for(; *s; s++)
 280:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 284:	8b 45 08             	mov    0x8(%ebp),%eax
 287:	0f b6 00             	movzbl (%eax),%eax
 28a:	84 c0                	test   %al,%al
 28c:	75 e2                	jne    270 <strchr+0xe>
  return 0;
 28e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 293:	c9                   	leave  
 294:	c3                   	ret    

00000295 <gets>:

char*
gets(char *buf, int max)
{
 295:	55                   	push   %ebp
 296:	89 e5                	mov    %esp,%ebp
 298:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 29b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2a2:	eb 42                	jmp    2e6 <gets+0x51>
    cc = read(0, &c, 1);
 2a4:	83 ec 04             	sub    $0x4,%esp
 2a7:	6a 01                	push   $0x1
 2a9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2ac:	50                   	push   %eax
 2ad:	6a 00                	push   $0x0
 2af:	e8 47 01 00 00       	call   3fb <read>
 2b4:	83 c4 10             	add    $0x10,%esp
 2b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2be:	7e 33                	jle    2f3 <gets+0x5e>
      break;
    buf[i++] = c;
 2c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c3:	8d 50 01             	lea    0x1(%eax),%edx
 2c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2c9:	89 c2                	mov    %eax,%edx
 2cb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ce:	01 c2                	add    %eax,%edx
 2d0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2d4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2d6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2da:	3c 0a                	cmp    $0xa,%al
 2dc:	74 16                	je     2f4 <gets+0x5f>
 2de:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2e2:	3c 0d                	cmp    $0xd,%al
 2e4:	74 0e                	je     2f4 <gets+0x5f>
  for(i=0; i+1 < max; ){
 2e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e9:	83 c0 01             	add    $0x1,%eax
 2ec:	39 45 0c             	cmp    %eax,0xc(%ebp)
 2ef:	7f b3                	jg     2a4 <gets+0xf>
 2f1:	eb 01                	jmp    2f4 <gets+0x5f>
      break;
 2f3:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	01 d0                	add    %edx,%eax
 2fc:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
}
 302:	c9                   	leave  
 303:	c3                   	ret    

00000304 <stat>:

int
stat(char *n, struct stat *st)
{
 304:	55                   	push   %ebp
 305:	89 e5                	mov    %esp,%ebp
 307:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 30a:	83 ec 08             	sub    $0x8,%esp
 30d:	6a 00                	push   $0x0
 30f:	ff 75 08             	push   0x8(%ebp)
 312:	e8 0c 01 00 00       	call   423 <open>
 317:	83 c4 10             	add    $0x10,%esp
 31a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 31d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 321:	79 07                	jns    32a <stat+0x26>
    return -1;
 323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 328:	eb 25                	jmp    34f <stat+0x4b>
  r = fstat(fd, st);
 32a:	83 ec 08             	sub    $0x8,%esp
 32d:	ff 75 0c             	push   0xc(%ebp)
 330:	ff 75 f4             	push   -0xc(%ebp)
 333:	e8 03 01 00 00       	call   43b <fstat>
 338:	83 c4 10             	add    $0x10,%esp
 33b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 33e:	83 ec 0c             	sub    $0xc,%esp
 341:	ff 75 f4             	push   -0xc(%ebp)
 344:	e8 c2 00 00 00       	call   40b <close>
 349:	83 c4 10             	add    $0x10,%esp
  return r;
 34c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 34f:	c9                   	leave  
 350:	c3                   	ret    

00000351 <atoi>:

int
atoi(const char *s)
{
 351:	55                   	push   %ebp
 352:	89 e5                	mov    %esp,%ebp
 354:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 357:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 35e:	eb 25                	jmp    385 <atoi+0x34>
    n = n*10 + *s++ - '0';
 360:	8b 55 fc             	mov    -0x4(%ebp),%edx
 363:	89 d0                	mov    %edx,%eax
 365:	c1 e0 02             	shl    $0x2,%eax
 368:	01 d0                	add    %edx,%eax
 36a:	01 c0                	add    %eax,%eax
 36c:	89 c1                	mov    %eax,%ecx
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
 371:	8d 50 01             	lea    0x1(%eax),%edx
 374:	89 55 08             	mov    %edx,0x8(%ebp)
 377:	0f b6 00             	movzbl (%eax),%eax
 37a:	0f be c0             	movsbl %al,%eax
 37d:	01 c8                	add    %ecx,%eax
 37f:	83 e8 30             	sub    $0x30,%eax
 382:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	0f b6 00             	movzbl (%eax),%eax
 38b:	3c 2f                	cmp    $0x2f,%al
 38d:	7e 0a                	jle    399 <atoi+0x48>
 38f:	8b 45 08             	mov    0x8(%ebp),%eax
 392:	0f b6 00             	movzbl (%eax),%eax
 395:	3c 39                	cmp    $0x39,%al
 397:	7e c7                	jle    360 <atoi+0xf>
  return n;
 399:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 39c:	c9                   	leave  
 39d:	c3                   	ret    

0000039e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 39e:	55                   	push   %ebp
 39f:	89 e5                	mov    %esp,%ebp
 3a1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 3a4:	8b 45 08             	mov    0x8(%ebp),%eax
 3a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3b0:	eb 17                	jmp    3c9 <memmove+0x2b>
    *dst++ = *src++;
 3b2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3b5:	8d 42 01             	lea    0x1(%edx),%eax
 3b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
 3bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3be:	8d 48 01             	lea    0x1(%eax),%ecx
 3c1:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 3c4:	0f b6 12             	movzbl (%edx),%edx
 3c7:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 3c9:	8b 45 10             	mov    0x10(%ebp),%eax
 3cc:	8d 50 ff             	lea    -0x1(%eax),%edx
 3cf:	89 55 10             	mov    %edx,0x10(%ebp)
 3d2:	85 c0                	test   %eax,%eax
 3d4:	7f dc                	jg     3b2 <memmove+0x14>
  return vdst;
 3d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3d9:	c9                   	leave  
 3da:	c3                   	ret    

000003db <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3db:	b8 01 00 00 00       	mov    $0x1,%eax
 3e0:	cd 40                	int    $0x40
 3e2:	c3                   	ret    

000003e3 <exit>:
SYSCALL(exit)
 3e3:	b8 02 00 00 00       	mov    $0x2,%eax
 3e8:	cd 40                	int    $0x40
 3ea:	c3                   	ret    

000003eb <wait>:
SYSCALL(wait)
 3eb:	b8 03 00 00 00       	mov    $0x3,%eax
 3f0:	cd 40                	int    $0x40
 3f2:	c3                   	ret    

000003f3 <pipe>:
SYSCALL(pipe)
 3f3:	b8 04 00 00 00       	mov    $0x4,%eax
 3f8:	cd 40                	int    $0x40
 3fa:	c3                   	ret    

000003fb <read>:
SYSCALL(read)
 3fb:	b8 05 00 00 00       	mov    $0x5,%eax
 400:	cd 40                	int    $0x40
 402:	c3                   	ret    

00000403 <write>:
SYSCALL(write)
 403:	b8 10 00 00 00       	mov    $0x10,%eax
 408:	cd 40                	int    $0x40
 40a:	c3                   	ret    

0000040b <close>:
SYSCALL(close)
 40b:	b8 15 00 00 00       	mov    $0x15,%eax
 410:	cd 40                	int    $0x40
 412:	c3                   	ret    

00000413 <kill>:
SYSCALL(kill)
 413:	b8 06 00 00 00       	mov    $0x6,%eax
 418:	cd 40                	int    $0x40
 41a:	c3                   	ret    

0000041b <exec>:
SYSCALL(exec)
 41b:	b8 07 00 00 00       	mov    $0x7,%eax
 420:	cd 40                	int    $0x40
 422:	c3                   	ret    

00000423 <open>:
SYSCALL(open)
 423:	b8 0f 00 00 00       	mov    $0xf,%eax
 428:	cd 40                	int    $0x40
 42a:	c3                   	ret    

0000042b <mknod>:
SYSCALL(mknod)
 42b:	b8 11 00 00 00       	mov    $0x11,%eax
 430:	cd 40                	int    $0x40
 432:	c3                   	ret    

00000433 <unlink>:
SYSCALL(unlink)
 433:	b8 12 00 00 00       	mov    $0x12,%eax
 438:	cd 40                	int    $0x40
 43a:	c3                   	ret    

0000043b <fstat>:
SYSCALL(fstat)
 43b:	b8 08 00 00 00       	mov    $0x8,%eax
 440:	cd 40                	int    $0x40
 442:	c3                   	ret    

00000443 <link>:
SYSCALL(link)
 443:	b8 13 00 00 00       	mov    $0x13,%eax
 448:	cd 40                	int    $0x40
 44a:	c3                   	ret    

0000044b <mkdir>:
SYSCALL(mkdir)
 44b:	b8 14 00 00 00       	mov    $0x14,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	ret    

00000453 <chdir>:
SYSCALL(chdir)
 453:	b8 09 00 00 00       	mov    $0x9,%eax
 458:	cd 40                	int    $0x40
 45a:	c3                   	ret    

0000045b <dup>:
SYSCALL(dup)
 45b:	b8 0a 00 00 00       	mov    $0xa,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	ret    

00000463 <getpid>:
SYSCALL(getpid)
 463:	b8 0b 00 00 00       	mov    $0xb,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret    

0000046b <sbrk>:
SYSCALL(sbrk)
 46b:	b8 0c 00 00 00       	mov    $0xc,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret    

00000473 <sleep>:
SYSCALL(sleep)
 473:	b8 0d 00 00 00       	mov    $0xd,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret    

0000047b <uptime>:
SYSCALL(uptime)
 47b:	b8 0e 00 00 00       	mov    $0xe,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	ret    

00000483 <setSchedPolicy>:
SYSCALL(setSchedPolicy) 
 483:	b8 16 00 00 00       	mov    $0x16,%eax
 488:	cd 40                	int    $0x40
 48a:	c3                   	ret    

0000048b <getpinfo>:
SYSCALL(getpinfo)
 48b:	b8 17 00 00 00       	mov    $0x17,%eax
 490:	cd 40                	int    $0x40
 492:	c3                   	ret    

00000493 <yield>:
SYSCALL(yield)
 493:	b8 18 00 00 00       	mov    $0x18,%eax
 498:	cd 40                	int    $0x40
 49a:	c3                   	ret    

0000049b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 49b:	55                   	push   %ebp
 49c:	89 e5                	mov    %esp,%ebp
 49e:	83 ec 18             	sub    $0x18,%esp
 4a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a4:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4a7:	83 ec 04             	sub    $0x4,%esp
 4aa:	6a 01                	push   $0x1
 4ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4af:	50                   	push   %eax
 4b0:	ff 75 08             	push   0x8(%ebp)
 4b3:	e8 4b ff ff ff       	call   403 <write>
 4b8:	83 c4 10             	add    $0x10,%esp
}
 4bb:	90                   	nop
 4bc:	c9                   	leave  
 4bd:	c3                   	ret    

000004be <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4be:	55                   	push   %ebp
 4bf:	89 e5                	mov    %esp,%ebp
 4c1:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4cb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4cf:	74 17                	je     4e8 <printint+0x2a>
 4d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4d5:	79 11                	jns    4e8 <printint+0x2a>
    neg = 1;
 4d7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4de:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e1:	f7 d8                	neg    %eax
 4e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e6:	eb 06                	jmp    4ee <printint+0x30>
  } else {
    x = xx;
 4e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 4eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4fb:	ba 00 00 00 00       	mov    $0x0,%edx
 500:	f7 f1                	div    %ecx
 502:	89 d1                	mov    %edx,%ecx
 504:	8b 45 f4             	mov    -0xc(%ebp),%eax
 507:	8d 50 01             	lea    0x1(%eax),%edx
 50a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 50d:	0f b6 91 e0 0b 00 00 	movzbl 0xbe0(%ecx),%edx
 514:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 518:	8b 4d 10             	mov    0x10(%ebp),%ecx
 51b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 51e:	ba 00 00 00 00       	mov    $0x0,%edx
 523:	f7 f1                	div    %ecx
 525:	89 45 ec             	mov    %eax,-0x14(%ebp)
 528:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 52c:	75 c7                	jne    4f5 <printint+0x37>
  if(neg)
 52e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 532:	74 2d                	je     561 <printint+0xa3>
    buf[i++] = '-';
 534:	8b 45 f4             	mov    -0xc(%ebp),%eax
 537:	8d 50 01             	lea    0x1(%eax),%edx
 53a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 53d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 542:	eb 1d                	jmp    561 <printint+0xa3>
    putc(fd, buf[i]);
 544:	8d 55 dc             	lea    -0x24(%ebp),%edx
 547:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54a:	01 d0                	add    %edx,%eax
 54c:	0f b6 00             	movzbl (%eax),%eax
 54f:	0f be c0             	movsbl %al,%eax
 552:	83 ec 08             	sub    $0x8,%esp
 555:	50                   	push   %eax
 556:	ff 75 08             	push   0x8(%ebp)
 559:	e8 3d ff ff ff       	call   49b <putc>
 55e:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 561:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 565:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 569:	79 d9                	jns    544 <printint+0x86>
}
 56b:	90                   	nop
 56c:	90                   	nop
 56d:	c9                   	leave  
 56e:	c3                   	ret    

0000056f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 56f:	55                   	push   %ebp
 570:	89 e5                	mov    %esp,%ebp
 572:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 575:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 57c:	8d 45 0c             	lea    0xc(%ebp),%eax
 57f:	83 c0 04             	add    $0x4,%eax
 582:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 585:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 58c:	e9 59 01 00 00       	jmp    6ea <printf+0x17b>
    c = fmt[i] & 0xff;
 591:	8b 55 0c             	mov    0xc(%ebp),%edx
 594:	8b 45 f0             	mov    -0x10(%ebp),%eax
 597:	01 d0                	add    %edx,%eax
 599:	0f b6 00             	movzbl (%eax),%eax
 59c:	0f be c0             	movsbl %al,%eax
 59f:	25 ff 00 00 00       	and    $0xff,%eax
 5a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5ab:	75 2c                	jne    5d9 <printf+0x6a>
      if(c == '%'){
 5ad:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5b1:	75 0c                	jne    5bf <printf+0x50>
        state = '%';
 5b3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5ba:	e9 27 01 00 00       	jmp    6e6 <printf+0x177>
      } else {
        putc(fd, c);
 5bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c2:	0f be c0             	movsbl %al,%eax
 5c5:	83 ec 08             	sub    $0x8,%esp
 5c8:	50                   	push   %eax
 5c9:	ff 75 08             	push   0x8(%ebp)
 5cc:	e8 ca fe ff ff       	call   49b <putc>
 5d1:	83 c4 10             	add    $0x10,%esp
 5d4:	e9 0d 01 00 00       	jmp    6e6 <printf+0x177>
      }
    } else if(state == '%'){
 5d9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5dd:	0f 85 03 01 00 00    	jne    6e6 <printf+0x177>
      if(c == 'd'){
 5e3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5e7:	75 1e                	jne    607 <printf+0x98>
        printint(fd, *ap, 10, 1);
 5e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ec:	8b 00                	mov    (%eax),%eax
 5ee:	6a 01                	push   $0x1
 5f0:	6a 0a                	push   $0xa
 5f2:	50                   	push   %eax
 5f3:	ff 75 08             	push   0x8(%ebp)
 5f6:	e8 c3 fe ff ff       	call   4be <printint>
 5fb:	83 c4 10             	add    $0x10,%esp
        ap++;
 5fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 602:	e9 d8 00 00 00       	jmp    6df <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 607:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 60b:	74 06                	je     613 <printf+0xa4>
 60d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 611:	75 1e                	jne    631 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 613:	8b 45 e8             	mov    -0x18(%ebp),%eax
 616:	8b 00                	mov    (%eax),%eax
 618:	6a 00                	push   $0x0
 61a:	6a 10                	push   $0x10
 61c:	50                   	push   %eax
 61d:	ff 75 08             	push   0x8(%ebp)
 620:	e8 99 fe ff ff       	call   4be <printint>
 625:	83 c4 10             	add    $0x10,%esp
        ap++;
 628:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 62c:	e9 ae 00 00 00       	jmp    6df <printf+0x170>
      } else if(c == 's'){
 631:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 635:	75 43                	jne    67a <printf+0x10b>
        s = (char*)*ap;
 637:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63a:	8b 00                	mov    (%eax),%eax
 63c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 63f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 643:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 647:	75 25                	jne    66e <printf+0xff>
          s = "(null)";
 649:	c7 45 f4 88 09 00 00 	movl   $0x988,-0xc(%ebp)
        while(*s != 0){
 650:	eb 1c                	jmp    66e <printf+0xff>
          putc(fd, *s);
 652:	8b 45 f4             	mov    -0xc(%ebp),%eax
 655:	0f b6 00             	movzbl (%eax),%eax
 658:	0f be c0             	movsbl %al,%eax
 65b:	83 ec 08             	sub    $0x8,%esp
 65e:	50                   	push   %eax
 65f:	ff 75 08             	push   0x8(%ebp)
 662:	e8 34 fe ff ff       	call   49b <putc>
 667:	83 c4 10             	add    $0x10,%esp
          s++;
 66a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 66e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 671:	0f b6 00             	movzbl (%eax),%eax
 674:	84 c0                	test   %al,%al
 676:	75 da                	jne    652 <printf+0xe3>
 678:	eb 65                	jmp    6df <printf+0x170>
        }
      } else if(c == 'c'){
 67a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 67e:	75 1d                	jne    69d <printf+0x12e>
        putc(fd, *ap);
 680:	8b 45 e8             	mov    -0x18(%ebp),%eax
 683:	8b 00                	mov    (%eax),%eax
 685:	0f be c0             	movsbl %al,%eax
 688:	83 ec 08             	sub    $0x8,%esp
 68b:	50                   	push   %eax
 68c:	ff 75 08             	push   0x8(%ebp)
 68f:	e8 07 fe ff ff       	call   49b <putc>
 694:	83 c4 10             	add    $0x10,%esp
        ap++;
 697:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69b:	eb 42                	jmp    6df <printf+0x170>
      } else if(c == '%'){
 69d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6a1:	75 17                	jne    6ba <printf+0x14b>
        putc(fd, c);
 6a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a6:	0f be c0             	movsbl %al,%eax
 6a9:	83 ec 08             	sub    $0x8,%esp
 6ac:	50                   	push   %eax
 6ad:	ff 75 08             	push   0x8(%ebp)
 6b0:	e8 e6 fd ff ff       	call   49b <putc>
 6b5:	83 c4 10             	add    $0x10,%esp
 6b8:	eb 25                	jmp    6df <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ba:	83 ec 08             	sub    $0x8,%esp
 6bd:	6a 25                	push   $0x25
 6bf:	ff 75 08             	push   0x8(%ebp)
 6c2:	e8 d4 fd ff ff       	call   49b <putc>
 6c7:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6cd:	0f be c0             	movsbl %al,%eax
 6d0:	83 ec 08             	sub    $0x8,%esp
 6d3:	50                   	push   %eax
 6d4:	ff 75 08             	push   0x8(%ebp)
 6d7:	e8 bf fd ff ff       	call   49b <putc>
 6dc:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 6e6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6ea:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f0:	01 d0                	add    %edx,%eax
 6f2:	0f b6 00             	movzbl (%eax),%eax
 6f5:	84 c0                	test   %al,%al
 6f7:	0f 85 94 fe ff ff    	jne    591 <printf+0x22>
    }
  }
}
 6fd:	90                   	nop
 6fe:	90                   	nop
 6ff:	c9                   	leave  
 700:	c3                   	ret    

00000701 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 701:	55                   	push   %ebp
 702:	89 e5                	mov    %esp,%ebp
 704:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 707:	8b 45 08             	mov    0x8(%ebp),%eax
 70a:	83 e8 08             	sub    $0x8,%eax
 70d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 710:	a1 fc 0b 00 00       	mov    0xbfc,%eax
 715:	89 45 fc             	mov    %eax,-0x4(%ebp)
 718:	eb 24                	jmp    73e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 71a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71d:	8b 00                	mov    (%eax),%eax
 71f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 722:	72 12                	jb     736 <free+0x35>
 724:	8b 45 f8             	mov    -0x8(%ebp),%eax
 727:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72a:	77 24                	ja     750 <free+0x4f>
 72c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72f:	8b 00                	mov    (%eax),%eax
 731:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 734:	72 1a                	jb     750 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 736:	8b 45 fc             	mov    -0x4(%ebp),%eax
 739:	8b 00                	mov    (%eax),%eax
 73b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 73e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 741:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 744:	76 d4                	jbe    71a <free+0x19>
 746:	8b 45 fc             	mov    -0x4(%ebp),%eax
 749:	8b 00                	mov    (%eax),%eax
 74b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 74e:	73 ca                	jae    71a <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 750:	8b 45 f8             	mov    -0x8(%ebp),%eax
 753:	8b 40 04             	mov    0x4(%eax),%eax
 756:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 75d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 760:	01 c2                	add    %eax,%edx
 762:	8b 45 fc             	mov    -0x4(%ebp),%eax
 765:	8b 00                	mov    (%eax),%eax
 767:	39 c2                	cmp    %eax,%edx
 769:	75 24                	jne    78f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 76b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76e:	8b 50 04             	mov    0x4(%eax),%edx
 771:	8b 45 fc             	mov    -0x4(%ebp),%eax
 774:	8b 00                	mov    (%eax),%eax
 776:	8b 40 04             	mov    0x4(%eax),%eax
 779:	01 c2                	add    %eax,%edx
 77b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	8b 00                	mov    (%eax),%eax
 786:	8b 10                	mov    (%eax),%edx
 788:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78b:	89 10                	mov    %edx,(%eax)
 78d:	eb 0a                	jmp    799 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 78f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 792:	8b 10                	mov    (%eax),%edx
 794:	8b 45 f8             	mov    -0x8(%ebp),%eax
 797:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 799:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79c:	8b 40 04             	mov    0x4(%eax),%eax
 79f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a9:	01 d0                	add    %edx,%eax
 7ab:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7ae:	75 20                	jne    7d0 <free+0xcf>
    p->s.size += bp->s.size;
 7b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b3:	8b 50 04             	mov    0x4(%eax),%edx
 7b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b9:	8b 40 04             	mov    0x4(%eax),%eax
 7bc:	01 c2                	add    %eax,%edx
 7be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c7:	8b 10                	mov    (%eax),%edx
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	89 10                	mov    %edx,(%eax)
 7ce:	eb 08                	jmp    7d8 <free+0xd7>
  } else
    p->s.ptr = bp;
 7d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7d6:	89 10                	mov    %edx,(%eax)
  freep = p;
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	a3 fc 0b 00 00       	mov    %eax,0xbfc
}
 7e0:	90                   	nop
 7e1:	c9                   	leave  
 7e2:	c3                   	ret    

000007e3 <morecore>:

static Header*
morecore(uint nu)
{
 7e3:	55                   	push   %ebp
 7e4:	89 e5                	mov    %esp,%ebp
 7e6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7e9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7f0:	77 07                	ja     7f9 <morecore+0x16>
    nu = 4096;
 7f2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7f9:	8b 45 08             	mov    0x8(%ebp),%eax
 7fc:	c1 e0 03             	shl    $0x3,%eax
 7ff:	83 ec 0c             	sub    $0xc,%esp
 802:	50                   	push   %eax
 803:	e8 63 fc ff ff       	call   46b <sbrk>
 808:	83 c4 10             	add    $0x10,%esp
 80b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 80e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 812:	75 07                	jne    81b <morecore+0x38>
    return 0;
 814:	b8 00 00 00 00       	mov    $0x0,%eax
 819:	eb 26                	jmp    841 <morecore+0x5e>
  hp = (Header*)p;
 81b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 821:	8b 45 f0             	mov    -0x10(%ebp),%eax
 824:	8b 55 08             	mov    0x8(%ebp),%edx
 827:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 82a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82d:	83 c0 08             	add    $0x8,%eax
 830:	83 ec 0c             	sub    $0xc,%esp
 833:	50                   	push   %eax
 834:	e8 c8 fe ff ff       	call   701 <free>
 839:	83 c4 10             	add    $0x10,%esp
  return freep;
 83c:	a1 fc 0b 00 00       	mov    0xbfc,%eax
}
 841:	c9                   	leave  
 842:	c3                   	ret    

00000843 <malloc>:

void*
malloc(uint nbytes)
{
 843:	55                   	push   %ebp
 844:	89 e5                	mov    %esp,%ebp
 846:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 849:	8b 45 08             	mov    0x8(%ebp),%eax
 84c:	83 c0 07             	add    $0x7,%eax
 84f:	c1 e8 03             	shr    $0x3,%eax
 852:	83 c0 01             	add    $0x1,%eax
 855:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 858:	a1 fc 0b 00 00       	mov    0xbfc,%eax
 85d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 860:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 864:	75 23                	jne    889 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 866:	c7 45 f0 f4 0b 00 00 	movl   $0xbf4,-0x10(%ebp)
 86d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 870:	a3 fc 0b 00 00       	mov    %eax,0xbfc
 875:	a1 fc 0b 00 00       	mov    0xbfc,%eax
 87a:	a3 f4 0b 00 00       	mov    %eax,0xbf4
    base.s.size = 0;
 87f:	c7 05 f8 0b 00 00 00 	movl   $0x0,0xbf8
 886:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 889:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88c:	8b 00                	mov    (%eax),%eax
 88e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	8b 40 04             	mov    0x4(%eax),%eax
 897:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 89a:	77 4d                	ja     8e9 <malloc+0xa6>
      if(p->s.size == nunits)
 89c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89f:	8b 40 04             	mov    0x4(%eax),%eax
 8a2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8a5:	75 0c                	jne    8b3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8aa:	8b 10                	mov    (%eax),%edx
 8ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8af:	89 10                	mov    %edx,(%eax)
 8b1:	eb 26                	jmp    8d9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b6:	8b 40 04             	mov    0x4(%eax),%eax
 8b9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8bc:	89 c2                	mov    %eax,%edx
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c7:	8b 40 04             	mov    0x4(%eax),%eax
 8ca:	c1 e0 03             	shl    $0x3,%eax
 8cd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8d6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8dc:	a3 fc 0b 00 00       	mov    %eax,0xbfc
      return (void*)(p + 1);
 8e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e4:	83 c0 08             	add    $0x8,%eax
 8e7:	eb 3b                	jmp    924 <malloc+0xe1>
    }
    if(p == freep)
 8e9:	a1 fc 0b 00 00       	mov    0xbfc,%eax
 8ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8f1:	75 1e                	jne    911 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8f3:	83 ec 0c             	sub    $0xc,%esp
 8f6:	ff 75 ec             	push   -0x14(%ebp)
 8f9:	e8 e5 fe ff ff       	call   7e3 <morecore>
 8fe:	83 c4 10             	add    $0x10,%esp
 901:	89 45 f4             	mov    %eax,-0xc(%ebp)
 904:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 908:	75 07                	jne    911 <malloc+0xce>
        return 0;
 90a:	b8 00 00 00 00       	mov    $0x0,%eax
 90f:	eb 13                	jmp    924 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	89 45 f0             	mov    %eax,-0x10(%ebp)
 917:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91a:	8b 00                	mov    (%eax),%eax
 91c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 91f:	e9 6d ff ff ff       	jmp    891 <malloc+0x4e>
  }
}
 924:	c9                   	leave  
 925:	c3                   	ret    
