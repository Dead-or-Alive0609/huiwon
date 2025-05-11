
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc f0 bc 11 80       	mov    $0x8011bcf0,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 49 38 10 80       	mov    $0x80103849,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 a0 aa 10 80       	push   $0x8010aaa0
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 50 50 00 00       	call   801050ce <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 47 11 80 fc 	movl   $0x801146fc,0x8011474c
80100088:	46 11 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 47 11 80 fc 	movl   $0x801146fc,0x80114750
80100092:	46 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 00 11 80 	movl   $0x80110034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 47 11 80    	mov    0x80114750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 a7 aa 10 80       	push   $0x8010aaa7
801000c2:	50                   	push   %eax
801000c3:	e8 a9 4e 00 00       	call   80104f71 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 47 11 80       	mov    0x80114750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 47 11 80       	mov    %eax,0x80114750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 46 11 80       	mov    $0x801146fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 00 11 80       	push   $0x80110000
80100101:	e8 ea 4f 00 00       	call   801050f0 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 47 11 80       	mov    0x80114750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 00 11 80       	push   $0x80110000
80100140:	e8 19 50 00 00       	call   8010515e <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 56 4e 00 00       	call   80104fad <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 47 11 80       	mov    0x8011474c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 00 11 80       	push   $0x80110000
801001c1:	e8 98 4f 00 00       	call   8010515e <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 d5 4d 00 00       	call   80104fad <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 ae aa 10 80       	push   $0x8010aaae
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 f9 26 00 00       	call   8010292b <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 10 4e 00 00       	call   8010505f <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 bf aa 10 80       	push   $0x8010aabf
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 ae 26 00 00       	call   8010292b <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 c7 4d 00 00       	call   8010505f <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 c6 aa 10 80       	push   $0x8010aac6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 56 4d 00 00       	call   80105011 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 25 4e 00 00       	call   801050f0 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 47 11 80    	mov    0x80114750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 47 11 80       	mov    0x80114750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 47 11 80       	mov    %eax,0x80114750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 00 11 80       	push   $0x80110000
80100336:	e8 23 4e 00 00       	call   8010515e <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 4a 11 80       	mov    0x80114a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 4a 11 80       	push   $0x80114a00
80100410:	e8 db 4c 00 00       	call   801050f0 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 cd aa 10 80       	push   $0x8010aacd
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec d6 aa 10 80 	movl   $0x8010aad6,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 4a 11 80       	push   $0x80114a00
8010059e:	e8 bb 4b 00 00       	call   8010515e <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 4a 11 80 00 	movl   $0x0,0x80114a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 1b 2a 00 00       	call   80102fde <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 dd aa 10 80       	push   $0x8010aadd
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 f1 aa 10 80       	push   $0x8010aaf1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 ad 4b 00 00       	call   801051b0 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 f3 aa 10 80       	push   $0x8010aaf3
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 49 11 80 01 	movl   $0x1,0x801149ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 74 83 00 00       	call   80108a19 <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 21 83 00 00       	call   80108a19 <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 28 83 00 00       	call   80108a84 <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 49 11 80       	mov    0x801149ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 f8 66 00 00       	call   80106e90 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 eb 66 00 00       	call   80106e90 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 de 66 00 00       	call   80106e90 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 ce 66 00 00       	call   80106e90 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 4a 11 80       	push   $0x80114a00
801007eb:	e8 00 49 00 00       	call   801050f0 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
8010085b:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100889:	a1 e4 49 11 80       	mov    0x801149e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008c7:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 49 11 80    	mov    %edx,0x801149e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 49 11 80    	mov    %dl,-0x7feeb6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100920:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100932:	a3 e4 49 11 80       	mov    %eax,0x801149e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 49 11 80       	push   $0x801149e0
8010093f:	e8 13 42 00 00       	call   80104b57 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 4a 11 80       	push   $0x80114a00
80100962:	e8 f7 47 00 00       	call   8010515e <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 ae 43 00 00       	call   80104d23 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 4a 11 80       	push   $0x80114a00
8010099a:	e8 51 47 00 00       	call   801050f0 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 96 35 00 00       	call   80103f42 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 4a 11 80       	push   $0x80114a00
801009bb:	e8 9e 47 00 00       	call   8010515e <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 4a 11 80       	push   $0x80114a00
801009e3:	68 e0 49 11 80       	push   $0x801149e0
801009e8:	e8 80 40 00 00       	call   80104a6d <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801009f6:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 49 11 80    	mov    %edx,0x801149e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 49 11 80       	mov    %eax,0x801149e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 4a 11 80       	push   $0x80114a00
80100a66:	e8 f3 46 00 00       	call   8010515e <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 4a 11 80       	push   $0x80114a00
80100aa2:	e8 49 46 00 00       	call   801050f0 <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 4a 11 80       	push   $0x80114a00
80100ae4:	e8 75 46 00 00       	call   8010515e <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 49 11 80 00 	movl   $0x0,0x801149ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 f7 aa 10 80       	push   $0x8010aaf7
80100b17:	68 00 4a 11 80       	push   $0x80114a00
80100b1c:	e8 ad 45 00 00       	call   801050ce <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 4a 11 80 86 	movl   $0x80100a86,0x80114a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 4a 11 80 78 	movl   $0x80100978,0x80114a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 ff aa 10 80 	movl   $0x8010aaff,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 4a 11 80 01 	movl   $0x1,0x80114a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 98 1f 00 00       	call   80102b12 <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 b4 33 00 00       	call   80103f42 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 8a 29 00 00       	call   80103520 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 fa 29 00 00       	call   801035ac <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 15 ab 10 80       	push   $0x8010ab15
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 76 72 00 00       	call   80107e8c <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 c9 75 00 00       	call   80108285 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 b6 74 00 00       	call   801081b8 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 69 28 00 00       	call   801035ac <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 14 75 00 00       	call   80108285 <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 52 77 00 00       	call   801084e7 <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 e6 47 00 00       	call   801055b4 <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 b9 47 00 00       	call   801055b4 <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 65 78 00 00       	call   80108686 <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 c9 77 00 00       	call   80108686 <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 6c             	add    $0x6c,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 5e 46 00 00       	call   80105569 <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 5b 70 00 00       	call   80107fa9 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 f2 74 00 00       	call   8010844e <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 b2 74 00 00       	call   8010844e <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 f4 25 00 00       	call   801035ac <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 21 ab 10 80       	push   $0x8010ab21
80100fcd:	68 a0 4a 11 80       	push   $0x80114aa0
80100fd2:	e8 f7 40 00 00       	call   801050ce <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 4a 11 80       	push   $0x80114aa0
80100feb:	e8 00 41 00 00       	call   801050f0 <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 4a 11 80 	movl   $0x80114ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 4a 11 80       	push   $0x80114aa0
80101018:	e8 41 41 00 00       	call   8010515e <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 54 11 80       	mov    $0x80115434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 4a 11 80       	push   $0x80114aa0
8010103b:	e8 1e 41 00 00       	call   8010515e <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 4a 11 80       	push   $0x80114aa0
80101058:	e8 93 40 00 00       	call   801050f0 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 28 ab 10 80       	push   $0x8010ab28
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 4a 11 80       	push   $0x80114aa0
8010108e:	e8 cb 40 00 00       	call   8010515e <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 4a 11 80       	push   $0x80114aa0
801010a9:	e8 42 40 00 00       	call   801050f0 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 30 ab 10 80       	push   $0x8010ab30
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 4a 11 80       	push   $0x80114aa0
801010e9:	e8 70 40 00 00       	call   8010515e <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 4a 11 80       	push   $0x80114aa0
80101137:	e8 22 40 00 00       	call   8010515e <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 48 2a 00 00       	call   80103ba3 <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 b3 23 00 00       	call   80103520 <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 2b 24 00 00       	call   801035ac <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 3c 2b 00 00       	call   80103d50 <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 3a ab 10 80       	push   $0x8010ab3a
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 81 29 00 00       	call   80103c4e <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 0e 22 00 00       	call   80103520 <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 34 22 00 00       	call   801035ac <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 43 ab 10 80       	push   $0x8010ab43
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 53 ab 10 80       	push   $0x8010ab53
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 29 40 00 00       	call   80105425 <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 24 3f 00 00       	call   80105366 <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 09 23 00 00       	call   80103759 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 54 11 80       	mov    0x80115458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 3d 22 00 00       	call   80103759 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 54 11 80       	mov    0x80115440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 54 11 80    	mov    0x80115440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 60 ab 10 80       	push   $0x8010ab60
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 54 11 80       	push   $0x80115440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 54 11 80       	mov    0x80115458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 76 ab 10 80       	push   $0x8010ab76
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 f5 20 00 00       	call   80103759 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 89 ab 10 80       	push   $0x8010ab89
80101690:	68 60 54 11 80       	push   $0x80115460
80101695:	e8 34 3a 00 00       	call   801050ce <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 54 11 80       	add    $0x80115460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 90 ab 10 80       	push   $0x8010ab90
801016c6:	50                   	push   %eax
801016c7:	e8 a5 38 00 00       	call   80104f71 <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 54 11 80       	push   $0x80115440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 54 11 80       	mov    0x80115458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 54 11 80    	mov    0x80115454,%edi
801016fa:	8b 35 50 54 11 80    	mov    0x80115450,%esi
80101700:	8b 1d 4c 54 11 80    	mov    0x8011544c,%ebx
80101706:	8b 0d 48 54 11 80    	mov    0x80115448,%ecx
8010170c:	8b 15 44 54 11 80    	mov    0x80115444,%edx
80101712:	a1 40 54 11 80       	mov    0x80115440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 98 ab 10 80       	push   $0x8010ab98
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 54 11 80       	mov    0x80115454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 c8 3b 00 00       	call   80105366 <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 a3 1f 00 00       	call   80103759 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 54 11 80    	mov    0x80115448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 eb ab 10 80       	push   $0x8010abeb
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 54 11 80       	mov    0x80115454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 79 3b 00 00       	call   80105425 <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 9f 1e 00 00       	call   80103759 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 54 11 80       	push   $0x80115460
801018dc:	e8 0f 38 00 00       	call   801050f0 <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 54 11 80 	movl   $0x80115494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 54 11 80       	push   $0x80115460
8010192a:	e8 2f 38 00 00       	call   8010515e <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 fd ab 10 80       	push   $0x8010abfd
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 54 11 80       	push   $0x80115460
801019a3:	e8 b6 37 00 00       	call   8010515e <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 54 11 80       	push   $0x80115460
801019be:	e8 2d 37 00 00       	call   801050f0 <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 54 11 80       	push   $0x80115460
801019dd:	e8 7c 37 00 00       	call   8010515e <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 0d ac 10 80       	push   $0x8010ac0d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 91 35 00 00       	call   80104fad <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 54 11 80       	mov    0x80115454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 5f 39 00 00       	call   80105425 <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 13 ac 10 80       	push   $0x8010ac13
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 47 35 00 00       	call   8010505f <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 22 ac 10 80       	push   $0x8010ac22
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 cc 34 00 00       	call   80105011 <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 4d 34 00 00       	call   80104fad <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 54 11 80       	push   $0x80115460
80101b81:	e8 6a 35 00 00       	call   801050f0 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 54 11 80       	push   $0x80115460
80101b9a:	e8 bf 35 00 00       	call   8010515e <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 2b 34 00 00       	call   80105011 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 54 11 80       	push   $0x80115460
80101bf1:	e8 fa 34 00 00       	call   801050f0 <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 54 11 80       	push   $0x80115460
80101c10:	e8 49 35 00 00       	call   8010515e <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 1e 1a 00 00       	call   80103759 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 2a ac 10 80       	push   $0x8010ac2a
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 2e 34 00 00       	call   80105425 <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 de 32 00 00       	call   80105425 <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 04 16 00 00       	call   80103759 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 f4 32 00 00       	call   801054bb <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 3d ac 10 80       	push   $0x8010ac3d
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 4f ac 10 80       	push   $0x8010ac4f
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 5e ac 10 80       	push   $0x8010ac5e
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 eb 31 00 00       	call   80105511 <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 6b ac 10 80       	push   $0x8010ac6b
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 61 30 00 00       	call   80105425 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 4a 30 00 00       	call   80105425 <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 18 1b 00 00       	call   80103f42 <myproc>
8010242a:	8b 40 68             	mov    0x68(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <inb>:
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
80102557:	83 ec 14             	sub    $0x14,%esp
8010255a:	8b 45 08             	mov    0x8(%ebp),%eax
8010255d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102561:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102565:	89 c2                	mov    %eax,%edx
80102567:	ec                   	in     (%dx),%al
80102568:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010256b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010256f:	c9                   	leave  
80102570:	c3                   	ret    

80102571 <insl>:
{
80102571:	55                   	push   %ebp
80102572:	89 e5                	mov    %esp,%ebp
80102574:	57                   	push   %edi
80102575:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102576:	8b 55 08             	mov    0x8(%ebp),%edx
80102579:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010257c:	8b 45 10             	mov    0x10(%ebp),%eax
8010257f:	89 cb                	mov    %ecx,%ebx
80102581:	89 df                	mov    %ebx,%edi
80102583:	89 c1                	mov    %eax,%ecx
80102585:	fc                   	cld    
80102586:	f3 6d                	rep insl (%dx),%es:(%edi)
80102588:	89 c8                	mov    %ecx,%eax
8010258a:	89 fb                	mov    %edi,%ebx
8010258c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010258f:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102592:	90                   	nop
80102593:	5b                   	pop    %ebx
80102594:	5f                   	pop    %edi
80102595:	5d                   	pop    %ebp
80102596:	c3                   	ret    

80102597 <outb>:
{
80102597:	55                   	push   %ebp
80102598:	89 e5                	mov    %esp,%ebp
8010259a:	83 ec 08             	sub    $0x8,%esp
8010259d:	8b 45 08             	mov    0x8(%ebp),%eax
801025a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801025a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025a7:	89 d0                	mov    %edx,%eax
801025a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025b4:	ee                   	out    %al,(%dx)
}
801025b5:	90                   	nop
801025b6:	c9                   	leave  
801025b7:	c3                   	ret    

801025b8 <outsl>:
{
801025b8:	55                   	push   %ebp
801025b9:	89 e5                	mov    %esp,%ebp
801025bb:	56                   	push   %esi
801025bc:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025bd:	8b 55 08             	mov    0x8(%ebp),%edx
801025c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025c3:	8b 45 10             	mov    0x10(%ebp),%eax
801025c6:	89 cb                	mov    %ecx,%ebx
801025c8:	89 de                	mov    %ebx,%esi
801025ca:	89 c1                	mov    %eax,%ecx
801025cc:	fc                   	cld    
801025cd:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025cf:	89 c8                	mov    %ecx,%eax
801025d1:	89 f3                	mov    %esi,%ebx
801025d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025d6:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025d9:	90                   	nop
801025da:	5b                   	pop    %ebx
801025db:	5e                   	pop    %esi
801025dc:	5d                   	pop    %ebp
801025dd:	c3                   	ret    

801025de <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025de:	55                   	push   %ebp
801025df:	89 e5                	mov    %esp,%ebp
801025e1:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025e4:	90                   	nop
801025e5:	68 f7 01 00 00       	push   $0x1f7
801025ea:	e8 65 ff ff ff       	call   80102554 <inb>
801025ef:	83 c4 04             	add    $0x4,%esp
801025f2:	0f b6 c0             	movzbl %al,%eax
801025f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025fb:	25 c0 00 00 00       	and    $0xc0,%eax
80102600:	83 f8 40             	cmp    $0x40,%eax
80102603:	75 e0                	jne    801025e5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102605:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102609:	74 11                	je     8010261c <idewait+0x3e>
8010260b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010260e:	83 e0 21             	and    $0x21,%eax
80102611:	85 c0                	test   %eax,%eax
80102613:	74 07                	je     8010261c <idewait+0x3e>
    return -1;
80102615:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010261a:	eb 05                	jmp    80102621 <idewait+0x43>
  return 0;
8010261c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102621:	c9                   	leave  
80102622:	c3                   	ret    

80102623 <ideinit>:

void
ideinit(void)
{
80102623:	55                   	push   %ebp
80102624:	89 e5                	mov    %esp,%ebp
80102626:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102629:	83 ec 08             	sub    $0x8,%esp
8010262c:	68 73 ac 10 80       	push   $0x8010ac73
80102631:	68 c0 70 11 80       	push   $0x801170c0
80102636:	e8 93 2a 00 00       	call   801050ce <initlock>
8010263b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010263e:	a1 d0 a9 11 80       	mov    0x8011a9d0,%eax
80102643:	83 e8 01             	sub    $0x1,%eax
80102646:	83 ec 08             	sub    $0x8,%esp
80102649:	50                   	push   %eax
8010264a:	6a 0e                	push   $0xe
8010264c:	e8 c1 04 00 00       	call   80102b12 <ioapicenable>
80102651:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102654:	83 ec 0c             	sub    $0xc,%esp
80102657:	6a 00                	push   $0x0
80102659:	e8 80 ff ff ff       	call   801025de <idewait>
8010265e:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102661:	83 ec 08             	sub    $0x8,%esp
80102664:	68 f0 00 00 00       	push   $0xf0
80102669:	68 f6 01 00 00       	push   $0x1f6
8010266e:	e8 24 ff ff ff       	call   80102597 <outb>
80102673:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010267d:	eb 24                	jmp    801026a3 <ideinit+0x80>
    if(inb(0x1f7) != 0){
8010267f:	83 ec 0c             	sub    $0xc,%esp
80102682:	68 f7 01 00 00       	push   $0x1f7
80102687:	e8 c8 fe ff ff       	call   80102554 <inb>
8010268c:	83 c4 10             	add    $0x10,%esp
8010268f:	84 c0                	test   %al,%al
80102691:	74 0c                	je     8010269f <ideinit+0x7c>
      havedisk1 = 1;
80102693:	c7 05 f8 70 11 80 01 	movl   $0x1,0x801170f8
8010269a:	00 00 00 
      break;
8010269d:	eb 0d                	jmp    801026ac <ideinit+0x89>
  for(i=0; i<1000; i++){
8010269f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026a3:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026aa:	7e d3                	jle    8010267f <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026ac:	83 ec 08             	sub    $0x8,%esp
801026af:	68 e0 00 00 00       	push   $0xe0
801026b4:	68 f6 01 00 00       	push   $0x1f6
801026b9:	e8 d9 fe ff ff       	call   80102597 <outb>
801026be:	83 c4 10             	add    $0x10,%esp
}
801026c1:	90                   	nop
801026c2:	c9                   	leave  
801026c3:	c3                   	ret    

801026c4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026c4:	55                   	push   %ebp
801026c5:	89 e5                	mov    %esp,%ebp
801026c7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026ce:	75 0d                	jne    801026dd <idestart+0x19>
    panic("idestart");
801026d0:	83 ec 0c             	sub    $0xc,%esp
801026d3:	68 77 ac 10 80       	push   $0x8010ac77
801026d8:	e8 cc de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026dd:	8b 45 08             	mov    0x8(%ebp),%eax
801026e0:	8b 40 08             	mov    0x8(%eax),%eax
801026e3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e8:	76 0d                	jbe    801026f7 <idestart+0x33>
    panic("incorrect blockno");
801026ea:	83 ec 0c             	sub    $0xc,%esp
801026ed:	68 80 ac 10 80       	push   $0x8010ac80
801026f2:	e8 b2 de ff ff       	call   801005a9 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026f7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801026fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102701:	8b 50 08             	mov    0x8(%eax),%edx
80102704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102707:	0f af c2             	imul   %edx,%eax
8010270a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010270d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102711:	75 07                	jne    8010271a <idestart+0x56>
80102713:	b8 20 00 00 00       	mov    $0x20,%eax
80102718:	eb 05                	jmp    8010271f <idestart+0x5b>
8010271a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010271f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102722:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102726:	75 07                	jne    8010272f <idestart+0x6b>
80102728:	b8 30 00 00 00       	mov    $0x30,%eax
8010272d:	eb 05                	jmp    80102734 <idestart+0x70>
8010272f:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102734:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102737:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010273b:	7e 0d                	jle    8010274a <idestart+0x86>
8010273d:	83 ec 0c             	sub    $0xc,%esp
80102740:	68 77 ac 10 80       	push   $0x8010ac77
80102745:	e8 5f de ff ff       	call   801005a9 <panic>

  idewait(0);
8010274a:	83 ec 0c             	sub    $0xc,%esp
8010274d:	6a 00                	push   $0x0
8010274f:	e8 8a fe ff ff       	call   801025de <idewait>
80102754:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	6a 00                	push   $0x0
8010275c:	68 f6 03 00 00       	push   $0x3f6
80102761:	e8 31 fe ff ff       	call   80102597 <outb>
80102766:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276c:	0f b6 c0             	movzbl %al,%eax
8010276f:	83 ec 08             	sub    $0x8,%esp
80102772:	50                   	push   %eax
80102773:	68 f2 01 00 00       	push   $0x1f2
80102778:	e8 1a fe ff ff       	call   80102597 <outb>
8010277d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102783:	0f b6 c0             	movzbl %al,%eax
80102786:	83 ec 08             	sub    $0x8,%esp
80102789:	50                   	push   %eax
8010278a:	68 f3 01 00 00       	push   $0x1f3
8010278f:	e8 03 fe ff ff       	call   80102597 <outb>
80102794:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010279a:	c1 f8 08             	sar    $0x8,%eax
8010279d:	0f b6 c0             	movzbl %al,%eax
801027a0:	83 ec 08             	sub    $0x8,%esp
801027a3:	50                   	push   %eax
801027a4:	68 f4 01 00 00       	push   $0x1f4
801027a9:	e8 e9 fd ff ff       	call   80102597 <outb>
801027ae:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b4:	c1 f8 10             	sar    $0x10,%eax
801027b7:	0f b6 c0             	movzbl %al,%eax
801027ba:	83 ec 08             	sub    $0x8,%esp
801027bd:	50                   	push   %eax
801027be:	68 f5 01 00 00       	push   $0x1f5
801027c3:	e8 cf fd ff ff       	call   80102597 <outb>
801027c8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027cb:	8b 45 08             	mov    0x8(%ebp),%eax
801027ce:	8b 40 04             	mov    0x4(%eax),%eax
801027d1:	c1 e0 04             	shl    $0x4,%eax
801027d4:	83 e0 10             	and    $0x10,%eax
801027d7:	89 c2                	mov    %eax,%edx
801027d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027dc:	c1 f8 18             	sar    $0x18,%eax
801027df:	83 e0 0f             	and    $0xf,%eax
801027e2:	09 d0                	or     %edx,%eax
801027e4:	83 c8 e0             	or     $0xffffffe0,%eax
801027e7:	0f b6 c0             	movzbl %al,%eax
801027ea:	83 ec 08             	sub    $0x8,%esp
801027ed:	50                   	push   %eax
801027ee:	68 f6 01 00 00       	push   $0x1f6
801027f3:	e8 9f fd ff ff       	call   80102597 <outb>
801027f8:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	8b 00                	mov    (%eax),%eax
80102800:	83 e0 04             	and    $0x4,%eax
80102803:	85 c0                	test   %eax,%eax
80102805:	74 35                	je     8010283c <idestart+0x178>
    outb(0x1f7, write_cmd);
80102807:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010280a:	0f b6 c0             	movzbl %al,%eax
8010280d:	83 ec 08             	sub    $0x8,%esp
80102810:	50                   	push   %eax
80102811:	68 f7 01 00 00       	push   $0x1f7
80102816:	e8 7c fd ff ff       	call   80102597 <outb>
8010281b:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010281e:	8b 45 08             	mov    0x8(%ebp),%eax
80102821:	83 c0 5c             	add    $0x5c,%eax
80102824:	83 ec 04             	sub    $0x4,%esp
80102827:	68 80 00 00 00       	push   $0x80
8010282c:	50                   	push   %eax
8010282d:	68 f0 01 00 00       	push   $0x1f0
80102832:	e8 81 fd ff ff       	call   801025b8 <outsl>
80102837:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010283a:	eb 17                	jmp    80102853 <idestart+0x18f>
    outb(0x1f7, read_cmd);
8010283c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010283f:	0f b6 c0             	movzbl %al,%eax
80102842:	83 ec 08             	sub    $0x8,%esp
80102845:	50                   	push   %eax
80102846:	68 f7 01 00 00       	push   $0x1f7
8010284b:	e8 47 fd ff ff       	call   80102597 <outb>
80102850:	83 c4 10             	add    $0x10,%esp
}
80102853:	90                   	nop
80102854:	c9                   	leave  
80102855:	c3                   	ret    

80102856 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102856:	55                   	push   %ebp
80102857:	89 e5                	mov    %esp,%ebp
80102859:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	68 c0 70 11 80       	push   $0x801170c0
80102864:	e8 87 28 00 00       	call   801050f0 <acquire>
80102869:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010286c:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102871:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102874:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102878:	75 15                	jne    8010288f <ideintr+0x39>
    release(&idelock);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 c0 70 11 80       	push   $0x801170c0
80102882:	e8 d7 28 00 00       	call   8010515e <release>
80102887:	83 c4 10             	add    $0x10,%esp
    return;
8010288a:	e9 9a 00 00 00       	jmp    80102929 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010288f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102892:	8b 40 58             	mov    0x58(%eax),%eax
80102895:	a3 f4 70 11 80       	mov    %eax,0x801170f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010289a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289d:	8b 00                	mov    (%eax),%eax
8010289f:	83 e0 04             	and    $0x4,%eax
801028a2:	85 c0                	test   %eax,%eax
801028a4:	75 2d                	jne    801028d3 <ideintr+0x7d>
801028a6:	83 ec 0c             	sub    $0xc,%esp
801028a9:	6a 01                	push   $0x1
801028ab:	e8 2e fd ff ff       	call   801025de <idewait>
801028b0:	83 c4 10             	add    $0x10,%esp
801028b3:	85 c0                	test   %eax,%eax
801028b5:	78 1c                	js     801028d3 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ba:	83 c0 5c             	add    $0x5c,%eax
801028bd:	83 ec 04             	sub    $0x4,%esp
801028c0:	68 80 00 00 00       	push   $0x80
801028c5:	50                   	push   %eax
801028c6:	68 f0 01 00 00       	push   $0x1f0
801028cb:	e8 a1 fc ff ff       	call   80102571 <insl>
801028d0:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d6:	8b 00                	mov    (%eax),%eax
801028d8:	83 c8 02             	or     $0x2,%eax
801028db:	89 c2                	mov    %eax,%edx
801028dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e0:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e5:	8b 00                	mov    (%eax),%eax
801028e7:	83 e0 fb             	and    $0xfffffffb,%eax
801028ea:	89 c2                	mov    %eax,%edx
801028ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ef:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028f1:	83 ec 0c             	sub    $0xc,%esp
801028f4:	ff 75 f4             	push   -0xc(%ebp)
801028f7:	e8 5b 22 00 00       	call   80104b57 <wakeup>
801028fc:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801028ff:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102904:	85 c0                	test   %eax,%eax
80102906:	74 11                	je     80102919 <ideintr+0xc3>
    idestart(idequeue);
80102908:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010290d:	83 ec 0c             	sub    $0xc,%esp
80102910:	50                   	push   %eax
80102911:	e8 ae fd ff ff       	call   801026c4 <idestart>
80102916:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102919:	83 ec 0c             	sub    $0xc,%esp
8010291c:	68 c0 70 11 80       	push   $0x801170c0
80102921:	e8 38 28 00 00       	call   8010515e <release>
80102926:	83 c4 10             	add    $0x10,%esp
}
80102929:	c9                   	leave  
8010292a:	c3                   	ret    

8010292b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010292b:	55                   	push   %ebp
8010292c:	89 e5                	mov    %esp,%ebp
8010292e:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102931:	8b 15 f8 70 11 80    	mov    0x801170f8,%edx
80102937:	8b 45 08             	mov    0x8(%ebp),%eax
8010293a:	8b 40 04             	mov    0x4(%eax),%eax
8010293d:	83 ec 04             	sub    $0x4,%esp
80102940:	52                   	push   %edx
80102941:	50                   	push   %eax
80102942:	68 92 ac 10 80       	push   $0x8010ac92
80102947:	e8 a8 da ff ff       	call   801003f4 <cprintf>
8010294c:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	83 c0 0c             	add    $0xc,%eax
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	50                   	push   %eax
80102959:	e8 01 27 00 00       	call   8010505f <holdingsleep>
8010295e:	83 c4 10             	add    $0x10,%esp
80102961:	85 c0                	test   %eax,%eax
80102963:	75 0d                	jne    80102972 <iderw+0x47>
    panic("iderw: buf not locked");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 ac ac 10 80       	push   $0x8010acac
8010296d:	e8 37 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	8b 00                	mov    (%eax),%eax
80102977:	83 e0 06             	and    $0x6,%eax
8010297a:	83 f8 02             	cmp    $0x2,%eax
8010297d:	75 0d                	jne    8010298c <iderw+0x61>
    panic("iderw: nothing to do");
8010297f:	83 ec 0c             	sub    $0xc,%esp
80102982:	68 c2 ac 10 80       	push   $0x8010acc2
80102987:	e8 1d dc ff ff       	call   801005a9 <panic>
  if(b->dev != 0 && !havedisk1)
8010298c:	8b 45 08             	mov    0x8(%ebp),%eax
8010298f:	8b 40 04             	mov    0x4(%eax),%eax
80102992:	85 c0                	test   %eax,%eax
80102994:	74 16                	je     801029ac <iderw+0x81>
80102996:	a1 f8 70 11 80       	mov    0x801170f8,%eax
8010299b:	85 c0                	test   %eax,%eax
8010299d:	75 0d                	jne    801029ac <iderw+0x81>
    panic("iderw: ide disk 1 not present");
8010299f:	83 ec 0c             	sub    $0xc,%esp
801029a2:	68 d7 ac 10 80       	push   $0x8010acd7
801029a7:	e8 fd db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ac:	83 ec 0c             	sub    $0xc,%esp
801029af:	68 c0 70 11 80       	push   $0x801170c0
801029b4:	e8 37 27 00 00       	call   801050f0 <acquire>
801029b9:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029bc:	8b 45 08             	mov    0x8(%ebp),%eax
801029bf:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029c6:	c7 45 f4 f4 70 11 80 	movl   $0x801170f4,-0xc(%ebp)
801029cd:	eb 0b                	jmp    801029da <iderw+0xaf>
801029cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d2:	8b 00                	mov    (%eax),%eax
801029d4:	83 c0 58             	add    $0x58,%eax
801029d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dd:	8b 00                	mov    (%eax),%eax
801029df:	85 c0                	test   %eax,%eax
801029e1:	75 ec                	jne    801029cf <iderw+0xa4>
    ;
  *pp = b;
801029e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e6:	8b 55 08             	mov    0x8(%ebp),%edx
801029e9:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029eb:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801029f0:	39 45 08             	cmp    %eax,0x8(%ebp)
801029f3:	75 23                	jne    80102a18 <iderw+0xed>
    idestart(b);
801029f5:	83 ec 0c             	sub    $0xc,%esp
801029f8:	ff 75 08             	push   0x8(%ebp)
801029fb:	e8 c4 fc ff ff       	call   801026c4 <idestart>
80102a00:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a03:	eb 13                	jmp    80102a18 <iderw+0xed>
    sleep(b, &idelock);
80102a05:	83 ec 08             	sub    $0x8,%esp
80102a08:	68 c0 70 11 80       	push   $0x801170c0
80102a0d:	ff 75 08             	push   0x8(%ebp)
80102a10:	e8 58 20 00 00       	call   80104a6d <sleep>
80102a15:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	8b 00                	mov    (%eax),%eax
80102a1d:	83 e0 06             	and    $0x6,%eax
80102a20:	83 f8 02             	cmp    $0x2,%eax
80102a23:	75 e0                	jne    80102a05 <iderw+0xda>
  }


  release(&idelock);
80102a25:	83 ec 0c             	sub    $0xc,%esp
80102a28:	68 c0 70 11 80       	push   $0x801170c0
80102a2d:	e8 2c 27 00 00       	call   8010515e <release>
80102a32:	83 c4 10             	add    $0x10,%esp
}
80102a35:	90                   	nop
80102a36:	c9                   	leave  
80102a37:	c3                   	ret    

80102a38 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a3b:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a40:	8b 55 08             	mov    0x8(%ebp),%edx
80102a43:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a45:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a4a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a4d:	5d                   	pop    %ebp
80102a4e:	c3                   	ret    

80102a4f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a4f:	55                   	push   %ebp
80102a50:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a52:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a57:	8b 55 08             	mov    0x8(%ebp),%edx
80102a5a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a5c:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a61:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a64:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a67:	90                   	nop
80102a68:	5d                   	pop    %ebp
80102a69:	c3                   	ret    

80102a6a <ioapicinit>:

void
ioapicinit(void)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a70:	c7 05 fc 70 11 80 00 	movl   $0xfec00000,0x801170fc
80102a77:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a7a:	6a 01                	push   $0x1
80102a7c:	e8 b7 ff ff ff       	call   80102a38 <ioapicread>
80102a81:	83 c4 04             	add    $0x4,%esp
80102a84:	c1 e8 10             	shr    $0x10,%eax
80102a87:	25 ff 00 00 00       	and    $0xff,%eax
80102a8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a8f:	6a 00                	push   $0x0
80102a91:	e8 a2 ff ff ff       	call   80102a38 <ioapicread>
80102a96:	83 c4 04             	add    $0x4,%esp
80102a99:	c1 e8 18             	shr    $0x18,%eax
80102a9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a9f:	0f b6 05 d4 a9 11 80 	movzbl 0x8011a9d4,%eax
80102aa6:	0f b6 c0             	movzbl %al,%eax
80102aa9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102aac:	74 10                	je     80102abe <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aae:	83 ec 0c             	sub    $0xc,%esp
80102ab1:	68 f8 ac 10 80       	push   $0x8010acf8
80102ab6:	e8 39 d9 ff ff       	call   801003f4 <cprintf>
80102abb:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102abe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ac5:	eb 3f                	jmp    80102b06 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aca:	83 c0 20             	add    $0x20,%eax
80102acd:	0d 00 00 01 00       	or     $0x10000,%eax
80102ad2:	89 c2                	mov    %eax,%edx
80102ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad7:	83 c0 08             	add    $0x8,%eax
80102ada:	01 c0                	add    %eax,%eax
80102adc:	83 ec 08             	sub    $0x8,%esp
80102adf:	52                   	push   %edx
80102ae0:	50                   	push   %eax
80102ae1:	e8 69 ff ff ff       	call   80102a4f <ioapicwrite>
80102ae6:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aec:	83 c0 08             	add    $0x8,%eax
80102aef:	01 c0                	add    %eax,%eax
80102af1:	83 c0 01             	add    $0x1,%eax
80102af4:	83 ec 08             	sub    $0x8,%esp
80102af7:	6a 00                	push   $0x0
80102af9:	50                   	push   %eax
80102afa:	e8 50 ff ff ff       	call   80102a4f <ioapicwrite>
80102aff:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b02:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b09:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b0c:	7e b9                	jle    80102ac7 <ioapicinit+0x5d>
  }
}
80102b0e:	90                   	nop
80102b0f:	90                   	nop
80102b10:	c9                   	leave  
80102b11:	c3                   	ret    

80102b12 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b12:	55                   	push   %ebp
80102b13:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b15:	8b 45 08             	mov    0x8(%ebp),%eax
80102b18:	83 c0 20             	add    $0x20,%eax
80102b1b:	89 c2                	mov    %eax,%edx
80102b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b20:	83 c0 08             	add    $0x8,%eax
80102b23:	01 c0                	add    %eax,%eax
80102b25:	52                   	push   %edx
80102b26:	50                   	push   %eax
80102b27:	e8 23 ff ff ff       	call   80102a4f <ioapicwrite>
80102b2c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b32:	c1 e0 18             	shl    $0x18,%eax
80102b35:	89 c2                	mov    %eax,%edx
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	83 c0 08             	add    $0x8,%eax
80102b3d:	01 c0                	add    %eax,%eax
80102b3f:	83 c0 01             	add    $0x1,%eax
80102b42:	52                   	push   %edx
80102b43:	50                   	push   %eax
80102b44:	e8 06 ff ff ff       	call   80102a4f <ioapicwrite>
80102b49:	83 c4 08             	add    $0x8,%esp
}
80102b4c:	90                   	nop
80102b4d:	c9                   	leave  
80102b4e:	c3                   	ret    

80102b4f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b4f:	55                   	push   %ebp
80102b50:	89 e5                	mov    %esp,%ebp
80102b52:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b55:	83 ec 08             	sub    $0x8,%esp
80102b58:	68 2a ad 10 80       	push   $0x8010ad2a
80102b5d:	68 00 71 11 80       	push   $0x80117100
80102b62:	e8 67 25 00 00       	call   801050ce <initlock>
80102b67:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b6a:	c7 05 34 71 11 80 00 	movl   $0x0,0x80117134
80102b71:	00 00 00 
  freerange(vstart, vend);
80102b74:	83 ec 08             	sub    $0x8,%esp
80102b77:	ff 75 0c             	push   0xc(%ebp)
80102b7a:	ff 75 08             	push   0x8(%ebp)
80102b7d:	e8 2a 00 00 00       	call   80102bac <freerange>
80102b82:	83 c4 10             	add    $0x10,%esp
}
80102b85:	90                   	nop
80102b86:	c9                   	leave  
80102b87:	c3                   	ret    

80102b88 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b88:	55                   	push   %ebp
80102b89:	89 e5                	mov    %esp,%ebp
80102b8b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b8e:	83 ec 08             	sub    $0x8,%esp
80102b91:	ff 75 0c             	push   0xc(%ebp)
80102b94:	ff 75 08             	push   0x8(%ebp)
80102b97:	e8 10 00 00 00       	call   80102bac <freerange>
80102b9c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b9f:	c7 05 34 71 11 80 01 	movl   $0x1,0x80117134
80102ba6:	00 00 00 
}
80102ba9:	90                   	nop
80102baa:	c9                   	leave  
80102bab:	c3                   	ret    

80102bac <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bac:	55                   	push   %ebp
80102bad:	89 e5                	mov    %esp,%ebp
80102baf:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb5:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc2:	eb 15                	jmp    80102bd9 <freerange+0x2d>
    kfree(p);
80102bc4:	83 ec 0c             	sub    $0xc,%esp
80102bc7:	ff 75 f4             	push   -0xc(%ebp)
80102bca:	e8 1b 00 00 00       	call   80102bea <kfree>
80102bcf:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bdc:	05 00 10 00 00       	add    $0x1000,%eax
80102be1:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102be4:	73 de                	jae    80102bc4 <freerange+0x18>
}
80102be6:	90                   	nop
80102be7:	90                   	nop
80102be8:	c9                   	leave  
80102be9:	c3                   	ret    

80102bea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bea:	55                   	push   %ebp
80102beb:	89 e5                	mov    %esp,%ebp
80102bed:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf3:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bf8:	85 c0                	test   %eax,%eax
80102bfa:	75 18                	jne    80102c14 <kfree+0x2a>
80102bfc:	81 7d 08 00 c0 11 80 	cmpl   $0x8011c000,0x8(%ebp)
80102c03:	72 0f                	jb     80102c14 <kfree+0x2a>
80102c05:	8b 45 08             	mov    0x8(%ebp),%eax
80102c08:	05 00 00 00 80       	add    $0x80000000,%eax
80102c0d:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102c12:	76 0d                	jbe    80102c21 <kfree+0x37>
    panic("kfree");
80102c14:	83 ec 0c             	sub    $0xc,%esp
80102c17:	68 2f ad 10 80       	push   $0x8010ad2f
80102c1c:	e8 88 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c21:	83 ec 04             	sub    $0x4,%esp
80102c24:	68 00 10 00 00       	push   $0x1000
80102c29:	6a 01                	push   $0x1
80102c2b:	ff 75 08             	push   0x8(%ebp)
80102c2e:	e8 33 27 00 00       	call   80105366 <memset>
80102c33:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c36:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c3b:	85 c0                	test   %eax,%eax
80102c3d:	74 10                	je     80102c4f <kfree+0x65>
    acquire(&kmem.lock);
80102c3f:	83 ec 0c             	sub    $0xc,%esp
80102c42:	68 00 71 11 80       	push   $0x80117100
80102c47:	e8 a4 24 00 00       	call   801050f0 <acquire>
80102c4c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c55:	8b 15 38 71 11 80    	mov    0x80117138,%edx
80102c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c63:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102c68:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c6d:	85 c0                	test   %eax,%eax
80102c6f:	74 10                	je     80102c81 <kfree+0x97>
    release(&kmem.lock);
80102c71:	83 ec 0c             	sub    $0xc,%esp
80102c74:	68 00 71 11 80       	push   $0x80117100
80102c79:	e8 e0 24 00 00       	call   8010515e <release>
80102c7e:	83 c4 10             	add    $0x10,%esp
}
80102c81:	90                   	nop
80102c82:	c9                   	leave  
80102c83:	c3                   	ret    

80102c84 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c84:	55                   	push   %ebp
80102c85:	89 e5                	mov    %esp,%ebp
80102c87:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c8a:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c8f:	85 c0                	test   %eax,%eax
80102c91:	74 10                	je     80102ca3 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c93:	83 ec 0c             	sub    $0xc,%esp
80102c96:	68 00 71 11 80       	push   $0x80117100
80102c9b:	e8 50 24 00 00       	call   801050f0 <acquire>
80102ca0:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca3:	a1 38 71 11 80       	mov    0x80117138,%eax
80102ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102caf:	74 0a                	je     80102cbb <kalloc+0x37>
    kmem.freelist = r->next;
80102cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb4:	8b 00                	mov    (%eax),%eax
80102cb6:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102cbb:	a1 34 71 11 80       	mov    0x80117134,%eax
80102cc0:	85 c0                	test   %eax,%eax
80102cc2:	74 10                	je     80102cd4 <kalloc+0x50>
    release(&kmem.lock);
80102cc4:	83 ec 0c             	sub    $0xc,%esp
80102cc7:	68 00 71 11 80       	push   $0x80117100
80102ccc:	e8 8d 24 00 00       	call   8010515e <release>
80102cd1:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cd7:	c9                   	leave  
80102cd8:	c3                   	ret    

80102cd9 <inb>:
{
80102cd9:	55                   	push   %ebp
80102cda:	89 e5                	mov    %esp,%ebp
80102cdc:	83 ec 14             	sub    $0x14,%esp
80102cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ce6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cea:	89 c2                	mov    %eax,%edx
80102cec:	ec                   	in     (%dx),%al
80102ced:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cf4:	c9                   	leave  
80102cf5:	c3                   	ret    

80102cf6 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cf6:	55                   	push   %ebp
80102cf7:	89 e5                	mov    %esp,%ebp
80102cf9:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cfc:	6a 64                	push   $0x64
80102cfe:	e8 d6 ff ff ff       	call   80102cd9 <inb>
80102d03:	83 c4 04             	add    $0x4,%esp
80102d06:	0f b6 c0             	movzbl %al,%eax
80102d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d0f:	83 e0 01             	and    $0x1,%eax
80102d12:	85 c0                	test   %eax,%eax
80102d14:	75 0a                	jne    80102d20 <kbdgetc+0x2a>
    return -1;
80102d16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d1b:	e9 23 01 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d20:	6a 60                	push   $0x60
80102d22:	e8 b2 ff ff ff       	call   80102cd9 <inb>
80102d27:	83 c4 04             	add    $0x4,%esp
80102d2a:	0f b6 c0             	movzbl %al,%eax
80102d2d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d30:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d37:	75 17                	jne    80102d50 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d39:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d3e:	83 c8 40             	or     $0x40,%eax
80102d41:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d46:	b8 00 00 00 00       	mov    $0x0,%eax
80102d4b:	e9 f3 00 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d53:	25 80 00 00 00       	and    $0x80,%eax
80102d58:	85 c0                	test   %eax,%eax
80102d5a:	74 45                	je     80102da1 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d5c:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d61:	83 e0 40             	and    $0x40,%eax
80102d64:	85 c0                	test   %eax,%eax
80102d66:	75 08                	jne    80102d70 <kbdgetc+0x7a>
80102d68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d6b:	83 e0 7f             	and    $0x7f,%eax
80102d6e:	eb 03                	jmp    80102d73 <kbdgetc+0x7d>
80102d70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d73:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d79:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102d7e:	0f b6 00             	movzbl (%eax),%eax
80102d81:	83 c8 40             	or     $0x40,%eax
80102d84:	0f b6 c0             	movzbl %al,%eax
80102d87:	f7 d0                	not    %eax
80102d89:	89 c2                	mov    %eax,%edx
80102d8b:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d90:	21 d0                	and    %edx,%eax
80102d92:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d97:	b8 00 00 00 00       	mov    $0x0,%eax
80102d9c:	e9 a2 00 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102da1:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102da6:	83 e0 40             	and    $0x40,%eax
80102da9:	85 c0                	test   %eax,%eax
80102dab:	74 14                	je     80102dc1 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dad:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102db4:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102db9:	83 e0 bf             	and    $0xffffffbf,%eax
80102dbc:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  }

  shift |= shiftcode[data];
80102dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc4:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102dc9:	0f b6 00             	movzbl (%eax),%eax
80102dcc:	0f b6 d0             	movzbl %al,%edx
80102dcf:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dd4:	09 d0                	or     %edx,%eax
80102dd6:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  shift ^= togglecode[data];
80102ddb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dde:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102de3:	0f b6 00             	movzbl (%eax),%eax
80102de6:	0f b6 d0             	movzbl %al,%edx
80102de9:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dee:	31 d0                	xor    %edx,%eax
80102df0:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  c = charcode[shift & (CTL | SHIFT)][data];
80102df5:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dfa:	83 e0 03             	and    $0x3,%eax
80102dfd:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102e04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e07:	01 d0                	add    %edx,%eax
80102e09:	0f b6 00             	movzbl (%eax),%eax
80102e0c:	0f b6 c0             	movzbl %al,%eax
80102e0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e12:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e17:	83 e0 08             	and    $0x8,%eax
80102e1a:	85 c0                	test   %eax,%eax
80102e1c:	74 22                	je     80102e40 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e1e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e22:	76 0c                	jbe    80102e30 <kbdgetc+0x13a>
80102e24:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e28:	77 06                	ja     80102e30 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e2a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e2e:	eb 10                	jmp    80102e40 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e30:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e34:	76 0a                	jbe    80102e40 <kbdgetc+0x14a>
80102e36:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e3a:	77 04                	ja     80102e40 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e3c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e40:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e43:	c9                   	leave  
80102e44:	c3                   	ret    

80102e45 <kbdintr>:

void
kbdintr(void)
{
80102e45:	55                   	push   %ebp
80102e46:	89 e5                	mov    %esp,%ebp
80102e48:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e4b:	83 ec 0c             	sub    $0xc,%esp
80102e4e:	68 f6 2c 10 80       	push   $0x80102cf6
80102e53:	e8 7e d9 ff ff       	call   801007d6 <consoleintr>
80102e58:	83 c4 10             	add    $0x10,%esp
}
80102e5b:	90                   	nop
80102e5c:	c9                   	leave  
80102e5d:	c3                   	ret    

80102e5e <inb>:
{
80102e5e:	55                   	push   %ebp
80102e5f:	89 e5                	mov    %esp,%ebp
80102e61:	83 ec 14             	sub    $0x14,%esp
80102e64:	8b 45 08             	mov    0x8(%ebp),%eax
80102e67:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e6b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e6f:	89 c2                	mov    %eax,%edx
80102e71:	ec                   	in     (%dx),%al
80102e72:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e75:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e79:	c9                   	leave  
80102e7a:	c3                   	ret    

80102e7b <outb>:
{
80102e7b:	55                   	push   %ebp
80102e7c:	89 e5                	mov    %esp,%ebp
80102e7e:	83 ec 08             	sub    $0x8,%esp
80102e81:	8b 45 08             	mov    0x8(%ebp),%eax
80102e84:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e87:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e8b:	89 d0                	mov    %edx,%eax
80102e8d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e90:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e94:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e98:	ee                   	out    %al,(%dx)
}
80102e99:	90                   	nop
80102e9a:	c9                   	leave  
80102e9b:	c3                   	ret    

80102e9c <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e9c:	55                   	push   %ebp
80102e9d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e9f:	8b 15 40 71 11 80    	mov    0x80117140,%edx
80102ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ea8:	c1 e0 02             	shl    $0x2,%eax
80102eab:	01 c2                	add    %eax,%edx
80102ead:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb0:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102eb7:	83 c0 20             	add    $0x20,%eax
80102eba:	8b 00                	mov    (%eax),%eax
}
80102ebc:	90                   	nop
80102ebd:	5d                   	pop    %ebp
80102ebe:	c3                   	ret    

80102ebf <lapicinit>:

void
lapicinit(void)
{
80102ebf:	55                   	push   %ebp
80102ec0:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ec2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ec7:	85 c0                	test   %eax,%eax
80102ec9:	0f 84 0c 01 00 00    	je     80102fdb <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ecf:	68 3f 01 00 00       	push   $0x13f
80102ed4:	6a 3c                	push   $0x3c
80102ed6:	e8 c1 ff ff ff       	call   80102e9c <lapicw>
80102edb:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ede:	6a 0b                	push   $0xb
80102ee0:	68 f8 00 00 00       	push   $0xf8
80102ee5:	e8 b2 ff ff ff       	call   80102e9c <lapicw>
80102eea:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eed:	68 20 00 02 00       	push   $0x20020
80102ef2:	68 c8 00 00 00       	push   $0xc8
80102ef7:	e8 a0 ff ff ff       	call   80102e9c <lapicw>
80102efc:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102eff:	68 80 96 98 00       	push   $0x989680
80102f04:	68 e0 00 00 00       	push   $0xe0
80102f09:	e8 8e ff ff ff       	call   80102e9c <lapicw>
80102f0e:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f11:	68 00 00 01 00       	push   $0x10000
80102f16:	68 d4 00 00 00       	push   $0xd4
80102f1b:	e8 7c ff ff ff       	call   80102e9c <lapicw>
80102f20:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f23:	68 00 00 01 00       	push   $0x10000
80102f28:	68 d8 00 00 00       	push   $0xd8
80102f2d:	e8 6a ff ff ff       	call   80102e9c <lapicw>
80102f32:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f35:	a1 40 71 11 80       	mov    0x80117140,%eax
80102f3a:	83 c0 30             	add    $0x30,%eax
80102f3d:	8b 00                	mov    (%eax),%eax
80102f3f:	c1 e8 10             	shr    $0x10,%eax
80102f42:	25 fc 00 00 00       	and    $0xfc,%eax
80102f47:	85 c0                	test   %eax,%eax
80102f49:	74 12                	je     80102f5d <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f4b:	68 00 00 01 00       	push   $0x10000
80102f50:	68 d0 00 00 00       	push   $0xd0
80102f55:	e8 42 ff ff ff       	call   80102e9c <lapicw>
80102f5a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f5d:	6a 33                	push   $0x33
80102f5f:	68 dc 00 00 00       	push   $0xdc
80102f64:	e8 33 ff ff ff       	call   80102e9c <lapicw>
80102f69:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f6c:	6a 00                	push   $0x0
80102f6e:	68 a0 00 00 00       	push   $0xa0
80102f73:	e8 24 ff ff ff       	call   80102e9c <lapicw>
80102f78:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7b:	6a 00                	push   $0x0
80102f7d:	68 a0 00 00 00       	push   $0xa0
80102f82:	e8 15 ff ff ff       	call   80102e9c <lapicw>
80102f87:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f8a:	6a 00                	push   $0x0
80102f8c:	6a 2c                	push   $0x2c
80102f8e:	e8 09 ff ff ff       	call   80102e9c <lapicw>
80102f93:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f96:	6a 00                	push   $0x0
80102f98:	68 c4 00 00 00       	push   $0xc4
80102f9d:	e8 fa fe ff ff       	call   80102e9c <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa5:	68 00 85 08 00       	push   $0x88500
80102faa:	68 c0 00 00 00       	push   $0xc0
80102faf:	e8 e8 fe ff ff       	call   80102e9c <lapicw>
80102fb4:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb7:	90                   	nop
80102fb8:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fbd:	05 00 03 00 00       	add    $0x300,%eax
80102fc2:	8b 00                	mov    (%eax),%eax
80102fc4:	25 00 10 00 00       	and    $0x1000,%eax
80102fc9:	85 c0                	test   %eax,%eax
80102fcb:	75 eb                	jne    80102fb8 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fcd:	6a 00                	push   $0x0
80102fcf:	6a 20                	push   $0x20
80102fd1:	e8 c6 fe ff ff       	call   80102e9c <lapicw>
80102fd6:	83 c4 08             	add    $0x8,%esp
80102fd9:	eb 01                	jmp    80102fdc <lapicinit+0x11d>
    return;
80102fdb:	90                   	nop
}
80102fdc:	c9                   	leave  
80102fdd:	c3                   	ret    

80102fde <lapicid>:

int
lapicid(void)
{
80102fde:	55                   	push   %ebp
80102fdf:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102fe1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fe6:	85 c0                	test   %eax,%eax
80102fe8:	75 07                	jne    80102ff1 <lapicid+0x13>
    return 0;
80102fea:	b8 00 00 00 00       	mov    $0x0,%eax
80102fef:	eb 0d                	jmp    80102ffe <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102ff1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ff6:	83 c0 20             	add    $0x20,%eax
80102ff9:	8b 00                	mov    (%eax),%eax
80102ffb:	c1 e8 18             	shr    $0x18,%eax
}
80102ffe:	5d                   	pop    %ebp
80102fff:	c3                   	ret    

80103000 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103003:	a1 40 71 11 80       	mov    0x80117140,%eax
80103008:	85 c0                	test   %eax,%eax
8010300a:	74 0c                	je     80103018 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010300c:	6a 00                	push   $0x0
8010300e:	6a 2c                	push   $0x2c
80103010:	e8 87 fe ff ff       	call   80102e9c <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp
}
80103018:	90                   	nop
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
}
8010301e:	90                   	nop
8010301f:	5d                   	pop    %ebp
80103020:	c3                   	ret    

80103021 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103021:	55                   	push   %ebp
80103022:	89 e5                	mov    %esp,%ebp
80103024:	83 ec 14             	sub    $0x14,%esp
80103027:	8b 45 08             	mov    0x8(%ebp),%eax
8010302a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010302d:	6a 0f                	push   $0xf
8010302f:	6a 70                	push   $0x70
80103031:	e8 45 fe ff ff       	call   80102e7b <outb>
80103036:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103039:	6a 0a                	push   $0xa
8010303b:	6a 71                	push   $0x71
8010303d:	e8 39 fe ff ff       	call   80102e7b <outb>
80103042:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103045:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010304c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010304f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103054:	8b 45 0c             	mov    0xc(%ebp),%eax
80103057:	c1 e8 04             	shr    $0x4,%eax
8010305a:	89 c2                	mov    %eax,%edx
8010305c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010305f:	83 c0 02             	add    $0x2,%eax
80103062:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103065:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103069:	c1 e0 18             	shl    $0x18,%eax
8010306c:	50                   	push   %eax
8010306d:	68 c4 00 00 00       	push   $0xc4
80103072:	e8 25 fe ff ff       	call   80102e9c <lapicw>
80103077:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010307a:	68 00 c5 00 00       	push   $0xc500
8010307f:	68 c0 00 00 00       	push   $0xc0
80103084:	e8 13 fe ff ff       	call   80102e9c <lapicw>
80103089:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010308c:	68 c8 00 00 00       	push   $0xc8
80103091:	e8 85 ff ff ff       	call   8010301b <microdelay>
80103096:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103099:	68 00 85 00 00       	push   $0x8500
8010309e:	68 c0 00 00 00       	push   $0xc0
801030a3:	e8 f4 fd ff ff       	call   80102e9c <lapicw>
801030a8:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ab:	6a 64                	push   $0x64
801030ad:	e8 69 ff ff ff       	call   8010301b <microdelay>
801030b2:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030bc:	eb 3d                	jmp    801030fb <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030be:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030c2:	c1 e0 18             	shl    $0x18,%eax
801030c5:	50                   	push   %eax
801030c6:	68 c4 00 00 00       	push   $0xc4
801030cb:	e8 cc fd ff ff       	call   80102e9c <lapicw>
801030d0:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801030d6:	c1 e8 0c             	shr    $0xc,%eax
801030d9:	80 cc 06             	or     $0x6,%ah
801030dc:	50                   	push   %eax
801030dd:	68 c0 00 00 00       	push   $0xc0
801030e2:	e8 b5 fd ff ff       	call   80102e9c <lapicw>
801030e7:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030ea:	68 c8 00 00 00       	push   $0xc8
801030ef:	e8 27 ff ff ff       	call   8010301b <microdelay>
801030f4:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801030f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030fb:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030ff:	7e bd                	jle    801030be <lapicstartap+0x9d>
  }
}
80103101:	90                   	nop
80103102:	90                   	nop
80103103:	c9                   	leave  
80103104:	c3                   	ret    

80103105 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103108:	8b 45 08             	mov    0x8(%ebp),%eax
8010310b:	0f b6 c0             	movzbl %al,%eax
8010310e:	50                   	push   %eax
8010310f:	6a 70                	push   $0x70
80103111:	e8 65 fd ff ff       	call   80102e7b <outb>
80103116:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103119:	68 c8 00 00 00       	push   $0xc8
8010311e:	e8 f8 fe ff ff       	call   8010301b <microdelay>
80103123:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103126:	6a 71                	push   $0x71
80103128:	e8 31 fd ff ff       	call   80102e5e <inb>
8010312d:	83 c4 04             	add    $0x4,%esp
80103130:	0f b6 c0             	movzbl %al,%eax
}
80103133:	c9                   	leave  
80103134:	c3                   	ret    

80103135 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103138:	6a 00                	push   $0x0
8010313a:	e8 c6 ff ff ff       	call   80103105 <cmos_read>
8010313f:	83 c4 04             	add    $0x4,%esp
80103142:	8b 55 08             	mov    0x8(%ebp),%edx
80103145:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103147:	6a 02                	push   $0x2
80103149:	e8 b7 ff ff ff       	call   80103105 <cmos_read>
8010314e:	83 c4 04             	add    $0x4,%esp
80103151:	8b 55 08             	mov    0x8(%ebp),%edx
80103154:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103157:	6a 04                	push   $0x4
80103159:	e8 a7 ff ff ff       	call   80103105 <cmos_read>
8010315e:	83 c4 04             	add    $0x4,%esp
80103161:	8b 55 08             	mov    0x8(%ebp),%edx
80103164:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103167:	6a 07                	push   $0x7
80103169:	e8 97 ff ff ff       	call   80103105 <cmos_read>
8010316e:	83 c4 04             	add    $0x4,%esp
80103171:	8b 55 08             	mov    0x8(%ebp),%edx
80103174:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103177:	6a 08                	push   $0x8
80103179:	e8 87 ff ff ff       	call   80103105 <cmos_read>
8010317e:	83 c4 04             	add    $0x4,%esp
80103181:	8b 55 08             	mov    0x8(%ebp),%edx
80103184:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103187:	6a 09                	push   $0x9
80103189:	e8 77 ff ff ff       	call   80103105 <cmos_read>
8010318e:	83 c4 04             	add    $0x4,%esp
80103191:	8b 55 08             	mov    0x8(%ebp),%edx
80103194:	89 42 14             	mov    %eax,0x14(%edx)
}
80103197:	90                   	nop
80103198:	c9                   	leave  
80103199:	c3                   	ret    

8010319a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010319a:	55                   	push   %ebp
8010319b:	89 e5                	mov    %esp,%ebp
8010319d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031a0:	6a 0b                	push   $0xb
801031a2:	e8 5e ff ff ff       	call   80103105 <cmos_read>
801031a7:	83 c4 04             	add    $0x4,%esp
801031aa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b0:	83 e0 04             	and    $0x4,%eax
801031b3:	85 c0                	test   %eax,%eax
801031b5:	0f 94 c0             	sete   %al
801031b8:	0f b6 c0             	movzbl %al,%eax
801031bb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c1:	50                   	push   %eax
801031c2:	e8 6e ff ff ff       	call   80103135 <fill_rtcdate>
801031c7:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031ca:	6a 0a                	push   $0xa
801031cc:	e8 34 ff ff ff       	call   80103105 <cmos_read>
801031d1:	83 c4 04             	add    $0x4,%esp
801031d4:	25 80 00 00 00       	and    $0x80,%eax
801031d9:	85 c0                	test   %eax,%eax
801031db:	75 27                	jne    80103204 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031dd:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e0:	50                   	push   %eax
801031e1:	e8 4f ff ff ff       	call   80103135 <fill_rtcdate>
801031e6:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031e9:	83 ec 04             	sub    $0x4,%esp
801031ec:	6a 18                	push   $0x18
801031ee:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f1:	50                   	push   %eax
801031f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f5:	50                   	push   %eax
801031f6:	e8 d2 21 00 00       	call   801053cd <memcmp>
801031fb:	83 c4 10             	add    $0x10,%esp
801031fe:	85 c0                	test   %eax,%eax
80103200:	74 05                	je     80103207 <cmostime+0x6d>
80103202:	eb ba                	jmp    801031be <cmostime+0x24>
        continue;
80103204:	90                   	nop
    fill_rtcdate(&t1);
80103205:	eb b7                	jmp    801031be <cmostime+0x24>
      break;
80103207:	90                   	nop
  }

  // convert
  if(bcd) {
80103208:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010320c:	0f 84 b4 00 00 00    	je     801032c6 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103212:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103215:	c1 e8 04             	shr    $0x4,%eax
80103218:	89 c2                	mov    %eax,%edx
8010321a:	89 d0                	mov    %edx,%eax
8010321c:	c1 e0 02             	shl    $0x2,%eax
8010321f:	01 d0                	add    %edx,%eax
80103221:	01 c0                	add    %eax,%eax
80103223:	89 c2                	mov    %eax,%edx
80103225:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103228:	83 e0 0f             	and    $0xf,%eax
8010322b:	01 d0                	add    %edx,%eax
8010322d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103230:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103233:	c1 e8 04             	shr    $0x4,%eax
80103236:	89 c2                	mov    %eax,%edx
80103238:	89 d0                	mov    %edx,%eax
8010323a:	c1 e0 02             	shl    $0x2,%eax
8010323d:	01 d0                	add    %edx,%eax
8010323f:	01 c0                	add    %eax,%eax
80103241:	89 c2                	mov    %eax,%edx
80103243:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103246:	83 e0 0f             	and    $0xf,%eax
80103249:	01 d0                	add    %edx,%eax
8010324b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010324e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103251:	c1 e8 04             	shr    $0x4,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	89 d0                	mov    %edx,%eax
80103258:	c1 e0 02             	shl    $0x2,%eax
8010325b:	01 d0                	add    %edx,%eax
8010325d:	01 c0                	add    %eax,%eax
8010325f:	89 c2                	mov    %eax,%edx
80103261:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103264:	83 e0 0f             	and    $0xf,%eax
80103267:	01 d0                	add    %edx,%eax
80103269:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010326c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010326f:	c1 e8 04             	shr    $0x4,%eax
80103272:	89 c2                	mov    %eax,%edx
80103274:	89 d0                	mov    %edx,%eax
80103276:	c1 e0 02             	shl    $0x2,%eax
80103279:	01 d0                	add    %edx,%eax
8010327b:	01 c0                	add    %eax,%eax
8010327d:	89 c2                	mov    %eax,%edx
8010327f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103282:	83 e0 0f             	and    $0xf,%eax
80103285:	01 d0                	add    %edx,%eax
80103287:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010328a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010328d:	c1 e8 04             	shr    $0x4,%eax
80103290:	89 c2                	mov    %eax,%edx
80103292:	89 d0                	mov    %edx,%eax
80103294:	c1 e0 02             	shl    $0x2,%eax
80103297:	01 d0                	add    %edx,%eax
80103299:	01 c0                	add    %eax,%eax
8010329b:	89 c2                	mov    %eax,%edx
8010329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a0:	83 e0 0f             	and    $0xf,%eax
801032a3:	01 d0                	add    %edx,%eax
801032a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ab:	c1 e8 04             	shr    $0x4,%eax
801032ae:	89 c2                	mov    %eax,%edx
801032b0:	89 d0                	mov    %edx,%eax
801032b2:	c1 e0 02             	shl    $0x2,%eax
801032b5:	01 d0                	add    %edx,%eax
801032b7:	01 c0                	add    %eax,%eax
801032b9:	89 c2                	mov    %eax,%edx
801032bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032be:	83 e0 0f             	and    $0xf,%eax
801032c1:	01 d0                	add    %edx,%eax
801032c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032c6:	8b 45 08             	mov    0x8(%ebp),%eax
801032c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032cc:	89 10                	mov    %edx,(%eax)
801032ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032d1:	89 50 04             	mov    %edx,0x4(%eax)
801032d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032d7:	89 50 08             	mov    %edx,0x8(%eax)
801032da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032dd:	89 50 0c             	mov    %edx,0xc(%eax)
801032e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032e3:	89 50 10             	mov    %edx,0x10(%eax)
801032e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032e9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ec:	8b 45 08             	mov    0x8(%ebp),%eax
801032ef:	8b 40 14             	mov    0x14(%eax),%eax
801032f2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032f8:	8b 45 08             	mov    0x8(%ebp),%eax
801032fb:	89 50 14             	mov    %edx,0x14(%eax)
}
801032fe:	90                   	nop
801032ff:	c9                   	leave  
80103300:	c3                   	ret    

80103301 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103301:	55                   	push   %ebp
80103302:	89 e5                	mov    %esp,%ebp
80103304:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103307:	83 ec 08             	sub    $0x8,%esp
8010330a:	68 35 ad 10 80       	push   $0x8010ad35
8010330f:	68 60 71 11 80       	push   $0x80117160
80103314:	e8 b5 1d 00 00       	call   801050ce <initlock>
80103319:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010331c:	83 ec 08             	sub    $0x8,%esp
8010331f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103322:	50                   	push   %eax
80103323:	ff 75 08             	push   0x8(%ebp)
80103326:	e8 a3 e0 ff ff       	call   801013ce <readsb>
8010332b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010332e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103331:	a3 94 71 11 80       	mov    %eax,0x80117194
  log.size = sb.nlog;
80103336:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103339:	a3 98 71 11 80       	mov    %eax,0x80117198
  log.dev = dev;
8010333e:	8b 45 08             	mov    0x8(%ebp),%eax
80103341:	a3 a4 71 11 80       	mov    %eax,0x801171a4
  recover_from_log();
80103346:	e8 b3 01 00 00       	call   801034fe <recover_from_log>
}
8010334b:	90                   	nop
8010334c:	c9                   	leave  
8010334d:	c3                   	ret    

8010334e <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010334e:	55                   	push   %ebp
8010334f:	89 e5                	mov    %esp,%ebp
80103351:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103354:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010335b:	e9 95 00 00 00       	jmp    801033f5 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103360:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103369:	01 d0                	add    %edx,%eax
8010336b:	83 c0 01             	add    $0x1,%eax
8010336e:	89 c2                	mov    %eax,%edx
80103370:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103375:	83 ec 08             	sub    $0x8,%esp
80103378:	52                   	push   %edx
80103379:	50                   	push   %eax
8010337a:	e8 82 ce ff ff       	call   80100201 <bread>
8010337f:	83 c4 10             	add    $0x10,%esp
80103382:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103388:	83 c0 10             	add    $0x10,%eax
8010338b:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
80103392:	89 c2                	mov    %eax,%edx
80103394:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103399:	83 ec 08             	sub    $0x8,%esp
8010339c:	52                   	push   %edx
8010339d:	50                   	push   %eax
8010339e:	e8 5e ce ff ff       	call   80100201 <bread>
801033a3:	83 c4 10             	add    $0x10,%esp
801033a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ac:	8d 50 5c             	lea    0x5c(%eax),%edx
801033af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b2:	83 c0 5c             	add    $0x5c,%eax
801033b5:	83 ec 04             	sub    $0x4,%esp
801033b8:	68 00 02 00 00       	push   $0x200
801033bd:	52                   	push   %edx
801033be:	50                   	push   %eax
801033bf:	e8 61 20 00 00       	call   80105425 <memmove>
801033c4:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033c7:	83 ec 0c             	sub    $0xc,%esp
801033ca:	ff 75 ec             	push   -0x14(%ebp)
801033cd:	e8 68 ce ff ff       	call   8010023a <bwrite>
801033d2:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033d5:	83 ec 0c             	sub    $0xc,%esp
801033d8:	ff 75 f0             	push   -0x10(%ebp)
801033db:	e8 a3 ce ff ff       	call   80100283 <brelse>
801033e0:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033e3:	83 ec 0c             	sub    $0xc,%esp
801033e6:	ff 75 ec             	push   -0x14(%ebp)
801033e9:	e8 95 ce ff ff       	call   80100283 <brelse>
801033ee:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033f5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801033fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033fd:	0f 8c 5d ff ff ff    	jl     80103360 <install_trans+0x12>
  }
}
80103403:	90                   	nop
80103404:	90                   	nop
80103405:	c9                   	leave  
80103406:	c3                   	ret    

80103407 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103407:	55                   	push   %ebp
80103408:	89 e5                	mov    %esp,%ebp
8010340a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010340d:	a1 94 71 11 80       	mov    0x80117194,%eax
80103412:	89 c2                	mov    %eax,%edx
80103414:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103419:	83 ec 08             	sub    $0x8,%esp
8010341c:	52                   	push   %edx
8010341d:	50                   	push   %eax
8010341e:	e8 de cd ff ff       	call   80100201 <bread>
80103423:	83 c4 10             	add    $0x10,%esp
80103426:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342c:	83 c0 5c             	add    $0x5c,%eax
8010342f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103432:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103435:	8b 00                	mov    (%eax),%eax
80103437:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  for (i = 0; i < log.lh.n; i++) {
8010343c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103443:	eb 1b                	jmp    80103460 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103445:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010344b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010344f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103452:	83 c2 10             	add    $0x10,%edx
80103455:	89 04 95 6c 71 11 80 	mov    %eax,-0x7fee8e94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010345c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103460:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103465:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103468:	7c db                	jl     80103445 <read_head+0x3e>
  }
  brelse(buf);
8010346a:	83 ec 0c             	sub    $0xc,%esp
8010346d:	ff 75 f0             	push   -0x10(%ebp)
80103470:	e8 0e ce ff ff       	call   80100283 <brelse>
80103475:	83 c4 10             	add    $0x10,%esp
}
80103478:	90                   	nop
80103479:	c9                   	leave  
8010347a:	c3                   	ret    

8010347b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010347b:	55                   	push   %ebp
8010347c:	89 e5                	mov    %esp,%ebp
8010347e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103481:	a1 94 71 11 80       	mov    0x80117194,%eax
80103486:	89 c2                	mov    %eax,%edx
80103488:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010348d:	83 ec 08             	sub    $0x8,%esp
80103490:	52                   	push   %edx
80103491:	50                   	push   %eax
80103492:	e8 6a cd ff ff       	call   80100201 <bread>
80103497:	83 c4 10             	add    $0x10,%esp
8010349a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010349d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a0:	83 c0 5c             	add    $0x5c,%eax
801034a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034a6:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
801034ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034af:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034b8:	eb 1b                	jmp    801034d5 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034bd:	83 c0 10             	add    $0x10,%eax
801034c0:	8b 0c 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%ecx
801034c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034cd:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801034da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034dd:	7c db                	jl     801034ba <write_head+0x3f>
  }
  bwrite(buf);
801034df:	83 ec 0c             	sub    $0xc,%esp
801034e2:	ff 75 f0             	push   -0x10(%ebp)
801034e5:	e8 50 cd ff ff       	call   8010023a <bwrite>
801034ea:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ed:	83 ec 0c             	sub    $0xc,%esp
801034f0:	ff 75 f0             	push   -0x10(%ebp)
801034f3:	e8 8b cd ff ff       	call   80100283 <brelse>
801034f8:	83 c4 10             	add    $0x10,%esp
}
801034fb:	90                   	nop
801034fc:	c9                   	leave  
801034fd:	c3                   	ret    

801034fe <recover_from_log>:

static void
recover_from_log(void)
{
801034fe:	55                   	push   %ebp
801034ff:	89 e5                	mov    %esp,%ebp
80103501:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103504:	e8 fe fe ff ff       	call   80103407 <read_head>
  install_trans(); // if committed, copy from log to disk
80103509:	e8 40 fe ff ff       	call   8010334e <install_trans>
  log.lh.n = 0;
8010350e:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
80103515:	00 00 00 
  write_head(); // clear the log
80103518:	e8 5e ff ff ff       	call   8010347b <write_head>
}
8010351d:	90                   	nop
8010351e:	c9                   	leave  
8010351f:	c3                   	ret    

80103520 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103526:	83 ec 0c             	sub    $0xc,%esp
80103529:	68 60 71 11 80       	push   $0x80117160
8010352e:	e8 bd 1b 00 00       	call   801050f0 <acquire>
80103533:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103536:	a1 a0 71 11 80       	mov    0x801171a0,%eax
8010353b:	85 c0                	test   %eax,%eax
8010353d:	74 17                	je     80103556 <begin_op+0x36>
      sleep(&log, &log.lock);
8010353f:	83 ec 08             	sub    $0x8,%esp
80103542:	68 60 71 11 80       	push   $0x80117160
80103547:	68 60 71 11 80       	push   $0x80117160
8010354c:	e8 1c 15 00 00       	call   80104a6d <sleep>
80103551:	83 c4 10             	add    $0x10,%esp
80103554:	eb e0                	jmp    80103536 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103556:	8b 0d a8 71 11 80    	mov    0x801171a8,%ecx
8010355c:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103561:	8d 50 01             	lea    0x1(%eax),%edx
80103564:	89 d0                	mov    %edx,%eax
80103566:	c1 e0 02             	shl    $0x2,%eax
80103569:	01 d0                	add    %edx,%eax
8010356b:	01 c0                	add    %eax,%eax
8010356d:	01 c8                	add    %ecx,%eax
8010356f:	83 f8 1e             	cmp    $0x1e,%eax
80103572:	7e 17                	jle    8010358b <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103574:	83 ec 08             	sub    $0x8,%esp
80103577:	68 60 71 11 80       	push   $0x80117160
8010357c:	68 60 71 11 80       	push   $0x80117160
80103581:	e8 e7 14 00 00       	call   80104a6d <sleep>
80103586:	83 c4 10             	add    $0x10,%esp
80103589:	eb ab                	jmp    80103536 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010358b:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103590:	83 c0 01             	add    $0x1,%eax
80103593:	a3 9c 71 11 80       	mov    %eax,0x8011719c
      release(&log.lock);
80103598:	83 ec 0c             	sub    $0xc,%esp
8010359b:	68 60 71 11 80       	push   $0x80117160
801035a0:	e8 b9 1b 00 00       	call   8010515e <release>
801035a5:	83 c4 10             	add    $0x10,%esp
      break;
801035a8:	90                   	nop
    }
  }
}
801035a9:	90                   	nop
801035aa:	c9                   	leave  
801035ab:	c3                   	ret    

801035ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035ac:	55                   	push   %ebp
801035ad:	89 e5                	mov    %esp,%ebp
801035af:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035b9:	83 ec 0c             	sub    $0xc,%esp
801035bc:	68 60 71 11 80       	push   $0x80117160
801035c1:	e8 2a 1b 00 00       	call   801050f0 <acquire>
801035c6:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035c9:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035ce:	83 e8 01             	sub    $0x1,%eax
801035d1:	a3 9c 71 11 80       	mov    %eax,0x8011719c
  if(log.committing)
801035d6:	a1 a0 71 11 80       	mov    0x801171a0,%eax
801035db:	85 c0                	test   %eax,%eax
801035dd:	74 0d                	je     801035ec <end_op+0x40>
    panic("log.committing");
801035df:	83 ec 0c             	sub    $0xc,%esp
801035e2:	68 39 ad 10 80       	push   $0x8010ad39
801035e7:	e8 bd cf ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801035ec:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035f1:	85 c0                	test   %eax,%eax
801035f3:	75 13                	jne    80103608 <end_op+0x5c>
    do_commit = 1;
801035f5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035fc:	c7 05 a0 71 11 80 01 	movl   $0x1,0x801171a0
80103603:	00 00 00 
80103606:	eb 10                	jmp    80103618 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103608:	83 ec 0c             	sub    $0xc,%esp
8010360b:	68 60 71 11 80       	push   $0x80117160
80103610:	e8 42 15 00 00       	call   80104b57 <wakeup>
80103615:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103618:	83 ec 0c             	sub    $0xc,%esp
8010361b:	68 60 71 11 80       	push   $0x80117160
80103620:	e8 39 1b 00 00       	call   8010515e <release>
80103625:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103628:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010362c:	74 3f                	je     8010366d <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010362e:	e8 f6 00 00 00       	call   80103729 <commit>
    acquire(&log.lock);
80103633:	83 ec 0c             	sub    $0xc,%esp
80103636:	68 60 71 11 80       	push   $0x80117160
8010363b:	e8 b0 1a 00 00       	call   801050f0 <acquire>
80103640:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103643:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364a:	00 00 00 
    wakeup(&log);
8010364d:	83 ec 0c             	sub    $0xc,%esp
80103650:	68 60 71 11 80       	push   $0x80117160
80103655:	e8 fd 14 00 00       	call   80104b57 <wakeup>
8010365a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	68 60 71 11 80       	push   $0x80117160
80103665:	e8 f4 1a 00 00       	call   8010515e <release>
8010366a:	83 c4 10             	add    $0x10,%esp
  }
}
8010366d:	90                   	nop
8010366e:	c9                   	leave  
8010366f:	c3                   	ret    

80103670 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103670:	55                   	push   %ebp
80103671:	89 e5                	mov    %esp,%ebp
80103673:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367d:	e9 95 00 00 00       	jmp    80103717 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103682:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368b:	01 d0                	add    %edx,%eax
8010368d:	83 c0 01             	add    $0x1,%eax
80103690:	89 c2                	mov    %eax,%edx
80103692:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103697:	83 ec 08             	sub    $0x8,%esp
8010369a:	52                   	push   %edx
8010369b:	50                   	push   %eax
8010369c:	e8 60 cb ff ff       	call   80100201 <bread>
801036a1:	83 c4 10             	add    $0x10,%esp
801036a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036aa:	83 c0 10             	add    $0x10,%eax
801036ad:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801036b4:	89 c2                	mov    %eax,%edx
801036b6:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036bb:	83 ec 08             	sub    $0x8,%esp
801036be:	52                   	push   %edx
801036bf:	50                   	push   %eax
801036c0:	e8 3c cb ff ff       	call   80100201 <bread>
801036c5:	83 c4 10             	add    $0x10,%esp
801036c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ce:	8d 50 5c             	lea    0x5c(%eax),%edx
801036d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d4:	83 c0 5c             	add    $0x5c,%eax
801036d7:	83 ec 04             	sub    $0x4,%esp
801036da:	68 00 02 00 00       	push   $0x200
801036df:	52                   	push   %edx
801036e0:	50                   	push   %eax
801036e1:	e8 3f 1d 00 00       	call   80105425 <memmove>
801036e6:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036e9:	83 ec 0c             	sub    $0xc,%esp
801036ec:	ff 75 f0             	push   -0x10(%ebp)
801036ef:	e8 46 cb ff ff       	call   8010023a <bwrite>
801036f4:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801036f7:	83 ec 0c             	sub    $0xc,%esp
801036fa:	ff 75 ec             	push   -0x14(%ebp)
801036fd:	e8 81 cb ff ff       	call   80100283 <brelse>
80103702:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	ff 75 f0             	push   -0x10(%ebp)
8010370b:	e8 73 cb ff ff       	call   80100283 <brelse>
80103710:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103713:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103717:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010371c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010371f:	0f 8c 5d ff ff ff    	jl     80103682 <write_log+0x12>
  }
}
80103725:	90                   	nop
80103726:	90                   	nop
80103727:	c9                   	leave  
80103728:	c3                   	ret    

80103729 <commit>:

static void
commit()
{
80103729:	55                   	push   %ebp
8010372a:	89 e5                	mov    %esp,%ebp
8010372c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010372f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	7e 1e                	jle    80103756 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103738:	e8 33 ff ff ff       	call   80103670 <write_log>
    write_head();    // Write header to disk -- the real commit
8010373d:	e8 39 fd ff ff       	call   8010347b <write_head>
    install_trans(); // Now install writes to home locations
80103742:	e8 07 fc ff ff       	call   8010334e <install_trans>
    log.lh.n = 0;
80103747:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
8010374e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103751:	e8 25 fd ff ff       	call   8010347b <write_head>
  }
}
80103756:	90                   	nop
80103757:	c9                   	leave  
80103758:	c3                   	ret    

80103759 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103759:	55                   	push   %ebp
8010375a:	89 e5                	mov    %esp,%ebp
8010375c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010375f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103764:	83 f8 1d             	cmp    $0x1d,%eax
80103767:	7f 12                	jg     8010377b <log_write+0x22>
80103769:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010376e:	8b 15 98 71 11 80    	mov    0x80117198,%edx
80103774:	83 ea 01             	sub    $0x1,%edx
80103777:	39 d0                	cmp    %edx,%eax
80103779:	7c 0d                	jl     80103788 <log_write+0x2f>
    panic("too big a transaction");
8010377b:	83 ec 0c             	sub    $0xc,%esp
8010377e:	68 48 ad 10 80       	push   $0x8010ad48
80103783:	e8 21 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103788:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378d:	85 c0                	test   %eax,%eax
8010378f:	7f 0d                	jg     8010379e <log_write+0x45>
    panic("log_write outside of trans");
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 5e ad 10 80       	push   $0x8010ad5e
80103799:	e8 0b ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 71 11 80       	push   $0x80117160
801037a6:	e8 45 19 00 00       	call   801050f0 <acquire>
801037ab:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b5:	eb 1d                	jmp    801037d4 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ba:	83 c0 10             	add    $0x10,%eax
801037bd:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801037c4:	89 c2                	mov    %eax,%edx
801037c6:	8b 45 08             	mov    0x8(%ebp),%eax
801037c9:	8b 40 08             	mov    0x8(%eax),%eax
801037cc:	39 c2                	cmp    %eax,%edx
801037ce:	74 10                	je     801037e0 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d4:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037d9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037dc:	7c d9                	jl     801037b7 <log_write+0x5e>
801037de:	eb 01                	jmp    801037e1 <log_write+0x88>
      break;
801037e0:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037e1:	8b 45 08             	mov    0x8(%ebp),%eax
801037e4:	8b 40 08             	mov    0x8(%eax),%eax
801037e7:	89 c2                	mov    %eax,%edx
801037e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ec:	83 c0 10             	add    $0x10,%eax
801037ef:	89 14 85 6c 71 11 80 	mov    %edx,-0x7fee8e94(,%eax,4)
  if (i == log.lh.n)
801037f6:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037fe:	75 0d                	jne    8010380d <log_write+0xb4>
    log.lh.n++;
80103800:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103805:	83 c0 01             	add    $0x1,%eax
80103808:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  b->flags |= B_DIRTY; // prevent eviction
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 00                	mov    (%eax),%eax
80103812:	83 c8 04             	or     $0x4,%eax
80103815:	89 c2                	mov    %eax,%edx
80103817:	8b 45 08             	mov    0x8(%ebp),%eax
8010381a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010381c:	83 ec 0c             	sub    $0xc,%esp
8010381f:	68 60 71 11 80       	push   $0x80117160
80103824:	e8 35 19 00 00       	call   8010515e <release>
80103829:	83 c4 10             	add    $0x10,%esp
}
8010382c:	90                   	nop
8010382d:	c9                   	leave  
8010382e:	c3                   	ret    

8010382f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010382f:	55                   	push   %ebp
80103830:	89 e5                	mov    %esp,%ebp
80103832:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103835:	8b 55 08             	mov    0x8(%ebp),%edx
80103838:	8b 45 0c             	mov    0xc(%ebp),%eax
8010383b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010383e:	f0 87 02             	lock xchg %eax,(%edx)
80103841:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103844:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103847:	c9                   	leave  
80103848:	c3                   	ret    

80103849 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103849:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010384d:	83 e4 f0             	and    $0xfffffff0,%esp
80103850:	ff 71 fc             	push   -0x4(%ecx)
80103853:	55                   	push   %ebp
80103854:	89 e5                	mov    %esp,%ebp
80103856:	51                   	push   %ecx
80103857:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
8010385a:	e8 ff 50 00 00       	call   8010895e <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010385f:	83 ec 08             	sub    $0x8,%esp
80103862:	68 00 00 40 80       	push   $0x80400000
80103867:	68 00 c0 11 80       	push   $0x8011c000
8010386c:	e8 de f2 ff ff       	call   80102b4f <kinit1>
80103871:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103874:	e8 ff 46 00 00       	call   80107f78 <kvmalloc>
  mpinit_uefi();
80103879:	e8 a6 4e 00 00       	call   80108724 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010387e:	e8 3c f6 ff ff       	call   80102ebf <lapicinit>
  seginit();       // segment descriptors
80103883:	e8 88 41 00 00       	call   80107a10 <seginit>
  picinit();    // disable pic
80103888:	e8 9d 01 00 00       	call   80103a2a <picinit>
  ioapicinit();    // another interrupt controller
8010388d:	e8 d8 f1 ff ff       	call   80102a6a <ioapicinit>
  consoleinit();   // console hardware
80103892:	e8 68 d2 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
80103897:	e8 0d 35 00 00       	call   80106da9 <uartinit>
  pinit();         // process table
8010389c:	e8 c2 05 00 00       	call   80103e63 <pinit>
  tvinit();        // trap vectors
801038a1:	e8 0c 2f 00 00       	call   801067b2 <tvinit>
  binit();         // buffer cache
801038a6:	e8 bb c7 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801038ab:	e8 0f d7 ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801038b0:	e8 6e ed ff ff       	call   80102623 <ideinit>
  startothers();   // start other processors
801038b5:	e8 8a 00 00 00       	call   80103944 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038ba:	83 ec 08             	sub    $0x8,%esp
801038bd:	68 00 00 00 a0       	push   $0xa0000000
801038c2:	68 00 00 40 80       	push   $0x80400000
801038c7:	e8 bc f2 ff ff       	call   80102b88 <kinit2>
801038cc:	83 c4 10             	add    $0x10,%esp
  pci_init();
801038cf:	e8 e3 52 00 00       	call   80108bb7 <pci_init>
  arp_scan();
801038d4:	e8 1a 60 00 00       	call   801098f3 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038d9:	e8 d1 07 00 00       	call   801040af <userinit>

  mpmain();        // finish this processor's setup
801038de:	e8 1a 00 00 00       	call   801038fd <mpmain>

801038e3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038e3:	55                   	push   %ebp
801038e4:	89 e5                	mov    %esp,%ebp
801038e6:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038e9:	e8 a2 46 00 00       	call   80107f90 <switchkvm>
  seginit();
801038ee:	e8 1d 41 00 00       	call   80107a10 <seginit>
  lapicinit();
801038f3:	e8 c7 f5 ff ff       	call   80102ebf <lapicinit>
  mpmain();
801038f8:	e8 00 00 00 00       	call   801038fd <mpmain>

801038fd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038fd:	55                   	push   %ebp
801038fe:	89 e5                	mov    %esp,%ebp
80103900:	53                   	push   %ebx
80103901:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103904:	e8 a6 05 00 00       	call   80103eaf <cpuid>
80103909:	89 c3                	mov    %eax,%ebx
8010390b:	e8 9f 05 00 00       	call   80103eaf <cpuid>
80103910:	83 ec 04             	sub    $0x4,%esp
80103913:	53                   	push   %ebx
80103914:	50                   	push   %eax
80103915:	68 79 ad 10 80       	push   $0x8010ad79
8010391a:	e8 d5 ca ff ff       	call   801003f4 <cprintf>
8010391f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103922:	e8 01 30 00 00       	call   80106928 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103927:	e8 9e 05 00 00       	call   80103eca <mycpu>
8010392c:	05 a0 00 00 00       	add    $0xa0,%eax
80103931:	83 ec 08             	sub    $0x8,%esp
80103934:	6a 01                	push   $0x1
80103936:	50                   	push   %eax
80103937:	e8 f3 fe ff ff       	call   8010382f <xchg>
8010393c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010393f:	e8 5f 0d 00 00       	call   801046a3 <scheduler>

80103944 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103944:	55                   	push   %ebp
80103945:	89 e5                	mov    %esp,%ebp
80103947:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394a:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103951:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103956:	83 ec 04             	sub    $0x4,%esp
80103959:	50                   	push   %eax
8010395a:	68 38 f5 10 80       	push   $0x8010f538
8010395f:	ff 75 f0             	push   -0x10(%ebp)
80103962:	e8 be 1a 00 00       	call   80105425 <memmove>
80103967:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396a:	c7 45 f4 00 a7 11 80 	movl   $0x8011a700,-0xc(%ebp)
80103971:	eb 79                	jmp    801039ec <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103973:	e8 52 05 00 00       	call   80103eca <mycpu>
80103978:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397b:	74 67                	je     801039e4 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010397d:	e8 02 f3 ff ff       	call   80102c84 <kalloc>
80103982:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103988:	83 e8 04             	sub    $0x4,%eax
8010398b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010398e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103994:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103999:	83 e8 08             	sub    $0x8,%eax
8010399c:	c7 00 e3 38 10 80    	movl   $0x801038e3,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a2:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801039a7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b0:	83 e8 0c             	sub    $0xc,%eax
801039b3:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c1:	0f b6 00             	movzbl (%eax),%eax
801039c4:	0f b6 c0             	movzbl %al,%eax
801039c7:	83 ec 08             	sub    $0x8,%esp
801039ca:	52                   	push   %edx
801039cb:	50                   	push   %eax
801039cc:	e8 50 f6 ff ff       	call   80103021 <lapicstartap>
801039d1:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d4:	90                   	nop
801039d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039de:	85 c0                	test   %eax,%eax
801039e0:	74 f3                	je     801039d5 <startothers+0x91>
801039e2:	eb 01                	jmp    801039e5 <startothers+0xa1>
      continue;
801039e4:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039e5:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
801039ec:	a1 d0 a9 11 80       	mov    0x8011a9d0,%eax
801039f1:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039f7:	05 00 a7 11 80       	add    $0x8011a700,%eax
801039fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039ff:	0f 82 6e ff ff ff    	jb     80103973 <startothers+0x2f>
      ;
  }
}
80103a05:	90                   	nop
80103a06:	90                   	nop
80103a07:	c9                   	leave  
80103a08:	c3                   	ret    

80103a09 <outb>:
{
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	83 ec 08             	sub    $0x8,%esp
80103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a15:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a19:	89 d0                	mov    %edx,%eax
80103a1b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a1e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a22:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a26:	ee                   	out    %al,(%dx)
}
80103a27:	90                   	nop
80103a28:	c9                   	leave  
80103a29:	c3                   	ret    

80103a2a <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103a2a:	55                   	push   %ebp
80103a2b:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a2d:	68 ff 00 00 00       	push   $0xff
80103a32:	6a 21                	push   $0x21
80103a34:	e8 d0 ff ff ff       	call   80103a09 <outb>
80103a39:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103a3c:	68 ff 00 00 00       	push   $0xff
80103a41:	68 a1 00 00 00       	push   $0xa1
80103a46:	e8 be ff ff ff       	call   80103a09 <outb>
80103a4b:	83 c4 08             	add    $0x8,%esp
}
80103a4e:	90                   	nop
80103a4f:	c9                   	leave  
80103a50:	c3                   	ret    

80103a51 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103a51:	55                   	push   %ebp
80103a52:	89 e5                	mov    %esp,%ebp
80103a54:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103a57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103a67:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a6a:	8b 10                	mov    (%eax),%edx
80103a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103a71:	e8 67 d5 ff ff       	call   80100fdd <filealloc>
80103a76:	8b 55 08             	mov    0x8(%ebp),%edx
80103a79:	89 02                	mov    %eax,(%edx)
80103a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7e:	8b 00                	mov    (%eax),%eax
80103a80:	85 c0                	test   %eax,%eax
80103a82:	0f 84 c8 00 00 00    	je     80103b50 <pipealloc+0xff>
80103a88:	e8 50 d5 ff ff       	call   80100fdd <filealloc>
80103a8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a90:	89 02                	mov    %eax,(%edx)
80103a92:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a95:	8b 00                	mov    (%eax),%eax
80103a97:	85 c0                	test   %eax,%eax
80103a99:	0f 84 b1 00 00 00    	je     80103b50 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103a9f:	e8 e0 f1 ff ff       	call   80102c84 <kalloc>
80103aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103aab:	0f 84 a2 00 00 00    	je     80103b53 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab4:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103abb:	00 00 00 
  p->writeopen = 1;
80103abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac1:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ac8:	00 00 00 
  p->nwrite = 0;
80103acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ace:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ad5:	00 00 00 
  p->nread = 0;
80103ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adb:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ae2:	00 00 00 
  initlock(&p->lock, "pipe");
80103ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae8:	83 ec 08             	sub    $0x8,%esp
80103aeb:	68 8d ad 10 80       	push   $0x8010ad8d
80103af0:	50                   	push   %eax
80103af1:	e8 d8 15 00 00       	call   801050ce <initlock>
80103af6:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103af9:	8b 45 08             	mov    0x8(%ebp),%eax
80103afc:	8b 00                	mov    (%eax),%eax
80103afe:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103b04:	8b 45 08             	mov    0x8(%ebp),%eax
80103b07:	8b 00                	mov    (%eax),%eax
80103b09:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b10:	8b 00                	mov    (%eax),%eax
80103b12:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103b16:	8b 45 08             	mov    0x8(%ebp),%eax
80103b19:	8b 00                	mov    (%eax),%eax
80103b1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b1e:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103b21:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b24:	8b 00                	mov    (%eax),%eax
80103b26:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b2f:	8b 00                	mov    (%eax),%eax
80103b31:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b38:	8b 00                	mov    (%eax),%eax
80103b3a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b41:	8b 00                	mov    (%eax),%eax
80103b43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b46:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103b49:	b8 00 00 00 00       	mov    $0x0,%eax
80103b4e:	eb 51                	jmp    80103ba1 <pipealloc+0x150>
    goto bad;
80103b50:	90                   	nop
80103b51:	eb 01                	jmp    80103b54 <pipealloc+0x103>
    goto bad;
80103b53:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103b54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b58:	74 0e                	je     80103b68 <pipealloc+0x117>
    kfree((char*)p);
80103b5a:	83 ec 0c             	sub    $0xc,%esp
80103b5d:	ff 75 f4             	push   -0xc(%ebp)
80103b60:	e8 85 f0 ff ff       	call   80102bea <kfree>
80103b65:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103b68:	8b 45 08             	mov    0x8(%ebp),%eax
80103b6b:	8b 00                	mov    (%eax),%eax
80103b6d:	85 c0                	test   %eax,%eax
80103b6f:	74 11                	je     80103b82 <pipealloc+0x131>
    fileclose(*f0);
80103b71:	8b 45 08             	mov    0x8(%ebp),%eax
80103b74:	8b 00                	mov    (%eax),%eax
80103b76:	83 ec 0c             	sub    $0xc,%esp
80103b79:	50                   	push   %eax
80103b7a:	e8 1c d5 ff ff       	call   8010109b <fileclose>
80103b7f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103b82:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b85:	8b 00                	mov    (%eax),%eax
80103b87:	85 c0                	test   %eax,%eax
80103b89:	74 11                	je     80103b9c <pipealloc+0x14b>
    fileclose(*f1);
80103b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b8e:	8b 00                	mov    (%eax),%eax
80103b90:	83 ec 0c             	sub    $0xc,%esp
80103b93:	50                   	push   %eax
80103b94:	e8 02 d5 ff ff       	call   8010109b <fileclose>
80103b99:	83 c4 10             	add    $0x10,%esp
  return -1;
80103b9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ba1:	c9                   	leave  
80103ba2:	c3                   	ret    

80103ba3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103ba3:	55                   	push   %ebp
80103ba4:	89 e5                	mov    %esp,%ebp
80103ba6:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bac:	83 ec 0c             	sub    $0xc,%esp
80103baf:	50                   	push   %eax
80103bb0:	e8 3b 15 00 00       	call   801050f0 <acquire>
80103bb5:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103bb8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103bbc:	74 23                	je     80103be1 <pipeclose+0x3e>
    p->writeopen = 0;
80103bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc1:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103bc8:	00 00 00 
    wakeup(&p->nread);
80103bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80103bce:	05 34 02 00 00       	add    $0x234,%eax
80103bd3:	83 ec 0c             	sub    $0xc,%esp
80103bd6:	50                   	push   %eax
80103bd7:	e8 7b 0f 00 00       	call   80104b57 <wakeup>
80103bdc:	83 c4 10             	add    $0x10,%esp
80103bdf:	eb 21                	jmp    80103c02 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103be1:	8b 45 08             	mov    0x8(%ebp),%eax
80103be4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103beb:	00 00 00 
    wakeup(&p->nwrite);
80103bee:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf1:	05 38 02 00 00       	add    $0x238,%eax
80103bf6:	83 ec 0c             	sub    $0xc,%esp
80103bf9:	50                   	push   %eax
80103bfa:	e8 58 0f 00 00       	call   80104b57 <wakeup>
80103bff:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103c02:	8b 45 08             	mov    0x8(%ebp),%eax
80103c05:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c0b:	85 c0                	test   %eax,%eax
80103c0d:	75 2c                	jne    80103c3b <pipeclose+0x98>
80103c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c12:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103c18:	85 c0                	test   %eax,%eax
80103c1a:	75 1f                	jne    80103c3b <pipeclose+0x98>
    release(&p->lock);
80103c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1f:	83 ec 0c             	sub    $0xc,%esp
80103c22:	50                   	push   %eax
80103c23:	e8 36 15 00 00       	call   8010515e <release>
80103c28:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103c2b:	83 ec 0c             	sub    $0xc,%esp
80103c2e:	ff 75 08             	push   0x8(%ebp)
80103c31:	e8 b4 ef ff ff       	call   80102bea <kfree>
80103c36:	83 c4 10             	add    $0x10,%esp
80103c39:	eb 10                	jmp    80103c4b <pipeclose+0xa8>
  } else
    release(&p->lock);
80103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3e:	83 ec 0c             	sub    $0xc,%esp
80103c41:	50                   	push   %eax
80103c42:	e8 17 15 00 00       	call   8010515e <release>
80103c47:	83 c4 10             	add    $0x10,%esp
}
80103c4a:	90                   	nop
80103c4b:	90                   	nop
80103c4c:	c9                   	leave  
80103c4d:	c3                   	ret    

80103c4e <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103c4e:	55                   	push   %ebp
80103c4f:	89 e5                	mov    %esp,%ebp
80103c51:	53                   	push   %ebx
80103c52:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103c55:	8b 45 08             	mov    0x8(%ebp),%eax
80103c58:	83 ec 0c             	sub    $0xc,%esp
80103c5b:	50                   	push   %eax
80103c5c:	e8 8f 14 00 00       	call   801050f0 <acquire>
80103c61:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103c64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c6b:	e9 ad 00 00 00       	jmp    80103d1d <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103c70:	8b 45 08             	mov    0x8(%ebp),%eax
80103c73:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c79:	85 c0                	test   %eax,%eax
80103c7b:	74 0c                	je     80103c89 <pipewrite+0x3b>
80103c7d:	e8 c0 02 00 00       	call   80103f42 <myproc>
80103c82:	8b 40 24             	mov    0x24(%eax),%eax
80103c85:	85 c0                	test   %eax,%eax
80103c87:	74 19                	je     80103ca2 <pipewrite+0x54>
        release(&p->lock);
80103c89:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	50                   	push   %eax
80103c90:	e8 c9 14 00 00       	call   8010515e <release>
80103c95:	83 c4 10             	add    $0x10,%esp
        return -1;
80103c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c9d:	e9 a9 00 00 00       	jmp    80103d4b <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80103ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca5:	05 34 02 00 00       	add    $0x234,%eax
80103caa:	83 ec 0c             	sub    $0xc,%esp
80103cad:	50                   	push   %eax
80103cae:	e8 a4 0e 00 00       	call   80104b57 <wakeup>
80103cb3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103cbc:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc2:	83 ec 08             	sub    $0x8,%esp
80103cc5:	50                   	push   %eax
80103cc6:	52                   	push   %edx
80103cc7:	e8 a1 0d 00 00       	call   80104a6d <sleep>
80103ccc:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd2:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103cdb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ce1:	05 00 02 00 00       	add    $0x200,%eax
80103ce6:	39 c2                	cmp    %eax,%edx
80103ce8:	74 86                	je     80103c70 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ced:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103cfc:	8d 48 01             	lea    0x1(%eax),%ecx
80103cff:	8b 55 08             	mov    0x8(%ebp),%edx
80103d02:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103d08:	25 ff 01 00 00       	and    $0x1ff,%eax
80103d0d:	89 c1                	mov    %eax,%ecx
80103d0f:	0f b6 13             	movzbl (%ebx),%edx
80103d12:	8b 45 08             	mov    0x8(%ebp),%eax
80103d15:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103d19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d20:	3b 45 10             	cmp    0x10(%ebp),%eax
80103d23:	7c aa                	jl     80103ccf <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103d25:	8b 45 08             	mov    0x8(%ebp),%eax
80103d28:	05 34 02 00 00       	add    $0x234,%eax
80103d2d:	83 ec 0c             	sub    $0xc,%esp
80103d30:	50                   	push   %eax
80103d31:	e8 21 0e 00 00       	call   80104b57 <wakeup>
80103d36:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d39:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3c:	83 ec 0c             	sub    $0xc,%esp
80103d3f:	50                   	push   %eax
80103d40:	e8 19 14 00 00       	call   8010515e <release>
80103d45:	83 c4 10             	add    $0x10,%esp
  return n;
80103d48:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d4e:	c9                   	leave  
80103d4f:	c3                   	ret    

80103d50 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103d50:	55                   	push   %ebp
80103d51:	89 e5                	mov    %esp,%ebp
80103d53:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103d56:	8b 45 08             	mov    0x8(%ebp),%eax
80103d59:	83 ec 0c             	sub    $0xc,%esp
80103d5c:	50                   	push   %eax
80103d5d:	e8 8e 13 00 00       	call   801050f0 <acquire>
80103d62:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d65:	eb 3e                	jmp    80103da5 <piperead+0x55>
    if(myproc()->killed){
80103d67:	e8 d6 01 00 00       	call   80103f42 <myproc>
80103d6c:	8b 40 24             	mov    0x24(%eax),%eax
80103d6f:	85 c0                	test   %eax,%eax
80103d71:	74 19                	je     80103d8c <piperead+0x3c>
      release(&p->lock);
80103d73:	8b 45 08             	mov    0x8(%ebp),%eax
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	50                   	push   %eax
80103d7a:	e8 df 13 00 00       	call   8010515e <release>
80103d7f:	83 c4 10             	add    $0x10,%esp
      return -1;
80103d82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d87:	e9 be 00 00 00       	jmp    80103e4a <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8f:	8b 55 08             	mov    0x8(%ebp),%edx
80103d92:	81 c2 34 02 00 00    	add    $0x234,%edx
80103d98:	83 ec 08             	sub    $0x8,%esp
80103d9b:	50                   	push   %eax
80103d9c:	52                   	push   %edx
80103d9d:	e8 cb 0c 00 00       	call   80104a6d <sleep>
80103da2:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103da5:	8b 45 08             	mov    0x8(%ebp),%eax
80103da8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dae:	8b 45 08             	mov    0x8(%ebp),%eax
80103db1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103db7:	39 c2                	cmp    %eax,%edx
80103db9:	75 0d                	jne    80103dc8 <piperead+0x78>
80103dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbe:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dc4:	85 c0                	test   %eax,%eax
80103dc6:	75 9f                	jne    80103d67 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103dc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dcf:	eb 48                	jmp    80103e19 <piperead+0xc9>
    if(p->nread == p->nwrite)
80103dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dda:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103de3:	39 c2                	cmp    %eax,%edx
80103de5:	74 3c                	je     80103e23 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103de7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dea:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103df0:	8d 48 01             	lea    0x1(%eax),%ecx
80103df3:	8b 55 08             	mov    0x8(%ebp),%edx
80103df6:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103dfc:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e01:	89 c1                	mov    %eax,%ecx
80103e03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e09:	01 c2                	add    %eax,%edx
80103e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0e:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103e13:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103e15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1c:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e1f:	7c b0                	jl     80103dd1 <piperead+0x81>
80103e21:	eb 01                	jmp    80103e24 <piperead+0xd4>
      break;
80103e23:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103e24:	8b 45 08             	mov    0x8(%ebp),%eax
80103e27:	05 38 02 00 00       	add    $0x238,%eax
80103e2c:	83 ec 0c             	sub    $0xc,%esp
80103e2f:	50                   	push   %eax
80103e30:	e8 22 0d 00 00       	call   80104b57 <wakeup>
80103e35:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	50                   	push   %eax
80103e3f:	e8 1a 13 00 00       	call   8010515e <release>
80103e44:	83 c4 10             	add    $0x10,%esp
  return i;
80103e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103e4a:	c9                   	leave  
80103e4b:	c3                   	ret    

80103e4c <readeflags>:
{
80103e4c:	55                   	push   %ebp
80103e4d:	89 e5                	mov    %esp,%ebp
80103e4f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e52:	9c                   	pushf  
80103e53:	58                   	pop    %eax
80103e54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103e57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103e5a:	c9                   	leave  
80103e5b:	c3                   	ret    

80103e5c <sti>:
{
80103e5c:	55                   	push   %ebp
80103e5d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103e5f:	fb                   	sti    
}
80103e60:	90                   	nop
80103e61:	5d                   	pop    %ebp
80103e62:	c3                   	ret    

80103e63 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103e63:	55                   	push   %ebp
80103e64:	89 e5                	mov    %esp,%ebp
80103e66:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103e69:	83 ec 08             	sub    $0x8,%esp
80103e6c:	68 94 ad 10 80       	push   $0x8010ad94
80103e71:	68 40 72 11 80       	push   $0x80117240
80103e76:	e8 53 12 00 00       	call   801050ce <initlock>
80103e7b:	83 c4 10             	add    $0x10,%esp

  //MLFQ 큐 4개 초기화
  for (int i = 0; i < MLFQ_LEVELS; i++) {
80103e7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e85:	eb 1e                	jmp    80103ea5 <pinit+0x42>
    initqueue(&mlfq[i]);
80103e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8a:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
80103e90:	05 80 9a 11 80       	add    $0x80119a80,%eax
80103e95:	83 ec 0c             	sub    $0xc,%esp
80103e98:	50                   	push   %eax
80103e99:	e8 77 0d 00 00       	call   80104c15 <initqueue>
80103e9e:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < MLFQ_LEVELS; i++) {
80103ea1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ea5:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80103ea9:	7e dc                	jle    80103e87 <pinit+0x24>
  }
}
80103eab:	90                   	nop
80103eac:	90                   	nop
80103ead:	c9                   	leave  
80103eae:	c3                   	ret    

80103eaf <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103eaf:	55                   	push   %ebp
80103eb0:	89 e5                	mov    %esp,%ebp
80103eb2:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103eb5:	e8 10 00 00 00       	call   80103eca <mycpu>
80103eba:	2d 00 a7 11 80       	sub    $0x8011a700,%eax
80103ebf:	c1 f8 02             	sar    $0x2,%eax
80103ec2:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
80103ec8:	c9                   	leave  
80103ec9:	c3                   	ret    

80103eca <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103eca:	55                   	push   %ebp
80103ecb:	89 e5                	mov    %esp,%ebp
80103ecd:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ed0:	e8 77 ff ff ff       	call   80103e4c <readeflags>
80103ed5:	25 00 02 00 00       	and    $0x200,%eax
80103eda:	85 c0                	test   %eax,%eax
80103edc:	74 0d                	je     80103eeb <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103ede:	83 ec 0c             	sub    $0xc,%esp
80103ee1:	68 9c ad 10 80       	push   $0x8010ad9c
80103ee6:	e8 be c6 ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103eeb:	e8 ee f0 ff ff       	call   80102fde <lapicid>
80103ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ef3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103efa:	eb 2d                	jmp    80103f29 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eff:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103f05:	05 00 a7 11 80       	add    $0x8011a700,%eax
80103f0a:	0f b6 00             	movzbl (%eax),%eax
80103f0d:	0f b6 c0             	movzbl %al,%eax
80103f10:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103f13:	75 10                	jne    80103f25 <mycpu+0x5b>
      return &cpus[i];
80103f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f18:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103f1e:	05 00 a7 11 80       	add    $0x8011a700,%eax
80103f23:	eb 1b                	jmp    80103f40 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103f25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f29:	a1 d0 a9 11 80       	mov    0x8011a9d0,%eax
80103f2e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103f31:	7c c9                	jl     80103efc <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103f33:	83 ec 0c             	sub    $0xc,%esp
80103f36:	68 c2 ad 10 80       	push   $0x8010adc2
80103f3b:	e8 69 c6 ff ff       	call   801005a9 <panic>
}
80103f40:	c9                   	leave  
80103f41:	c3                   	ret    

80103f42 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f42:	55                   	push   %ebp
80103f43:	89 e5                	mov    %esp,%ebp
80103f45:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103f48:	e8 0e 13 00 00       	call   8010525b <pushcli>
  c = mycpu();
80103f4d:	e8 78 ff ff ff       	call   80103eca <mycpu>
80103f52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f58:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f61:	e8 42 13 00 00       	call   801052a8 <popcli>
  return p;
80103f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f69:	c9                   	leave  
80103f6a:	c3                   	ret    

80103f6b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f6b:	55                   	push   %ebp
80103f6c:	89 e5                	mov    %esp,%ebp
80103f6e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f71:	83 ec 0c             	sub    $0xc,%esp
80103f74:	68 40 72 11 80       	push   $0x80117240
80103f79:	e8 72 11 00 00       	call   801050f0 <acquire>
80103f7e:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f81:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f88:	eb 11                	jmp    80103f9b <allocproc+0x30>
    if(p->state == UNUSED){
80103f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8d:	8b 40 0c             	mov    0xc(%eax),%eax
80103f90:	85 c0                	test   %eax,%eax
80103f92:	74 2a                	je     80103fbe <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f94:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80103f9b:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80103fa2:	72 e6                	jb     80103f8a <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103fa4:	83 ec 0c             	sub    $0xc,%esp
80103fa7:	68 40 72 11 80       	push   $0x80117240
80103fac:	e8 ad 11 00 00       	call   8010515e <release>
80103fb1:	83 c4 10             	add    $0x10,%esp
  return 0;
80103fb4:	b8 00 00 00 00       	mov    $0x0,%eax
80103fb9:	e9 ef 00 00 00       	jmp    801040ad <allocproc+0x142>
      goto found;
80103fbe:	90                   	nop

found:
  p->state = EMBRYO;
80103fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc2:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103fc9:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103fce:	8d 50 01             	lea    0x1(%eax),%edx
80103fd1:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fda:	89 42 10             	mov    %eax,0x10(%edx)

  //추가
  p->priority = 3;  // Q3에서 시작
80103fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe0:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)

  for (int i = 0; i < MLFQ_LEVELS; i++) {
80103fe7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103fee:	eb 24                	jmp    80104014 <allocproc+0xa9>
    p->ticks[i] = 0;
80103ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ff6:	83 c2 20             	add    $0x20,%edx
80103ff9:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    p->wait_ticks[i] = 0;
80104000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104003:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104006:	83 c2 24             	add    $0x24,%edx
80104009:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  for (int i = 0; i < MLFQ_LEVELS; i++) {
80104010:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104014:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104018:	7e d6                	jle    80103ff0 <allocproc+0x85>
  }
  
  release(&ptable.lock);
8010401a:	83 ec 0c             	sub    $0xc,%esp
8010401d:	68 40 72 11 80       	push   $0x80117240
80104022:	e8 37 11 00 00       	call   8010515e <release>
80104027:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010402a:	e8 55 ec ff ff       	call   80102c84 <kalloc>
8010402f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104032:	89 42 08             	mov    %eax,0x8(%edx)
80104035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104038:	8b 40 08             	mov    0x8(%eax),%eax
8010403b:	85 c0                	test   %eax,%eax
8010403d:	75 11                	jne    80104050 <allocproc+0xe5>
    p->state = UNUSED;
8010403f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104042:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104049:	b8 00 00 00 00       	mov    $0x0,%eax
8010404e:	eb 5d                	jmp    801040ad <allocproc+0x142>
  }
  sp = p->kstack + KSTACKSIZE;
80104050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104053:	8b 40 08             	mov    0x8(%eax),%eax
80104056:	05 00 10 00 00       	add    $0x1000,%eax
8010405b:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010405e:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104065:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104068:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010406b:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
8010406f:	ba 6c 67 10 80       	mov    $0x8010676c,%edx
80104074:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104077:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104079:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
8010407d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104080:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104083:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104089:	8b 40 1c             	mov    0x1c(%eax),%eax
8010408c:	83 ec 04             	sub    $0x4,%esp
8010408f:	6a 14                	push   $0x14
80104091:	6a 00                	push   $0x0
80104093:	50                   	push   %eax
80104094:	e8 cd 12 00 00       	call   80105366 <memset>
80104099:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010409c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409f:	8b 40 1c             	mov    0x1c(%eax),%eax
801040a2:	ba 27 4a 10 80       	mov    $0x80104a27,%edx
801040a7:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801040aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801040ad:	c9                   	leave  
801040ae:	c3                   	ret    

801040af <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801040af:	55                   	push   %ebp
801040b0:	89 e5                	mov    %esp,%ebp
801040b2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801040b5:	e8 b1 fe ff ff       	call   80103f6b <allocproc>
801040ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801040bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c0:	a3 a0 9e 11 80       	mov    %eax,0x80119ea0
  if((p->pgdir = setupkvm()) == 0){
801040c5:	e8 c2 3d 00 00       	call   80107e8c <setupkvm>
801040ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040cd:	89 42 04             	mov    %eax,0x4(%edx)
801040d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d3:	8b 40 04             	mov    0x4(%eax),%eax
801040d6:	85 c0                	test   %eax,%eax
801040d8:	75 0d                	jne    801040e7 <userinit+0x38>
    panic("userinit: out of memory?");
801040da:	83 ec 0c             	sub    $0xc,%esp
801040dd:	68 d2 ad 10 80       	push   $0x8010add2
801040e2:	e8 c2 c4 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801040e7:	ba 2c 00 00 00       	mov    $0x2c,%edx
801040ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ef:	8b 40 04             	mov    0x4(%eax),%eax
801040f2:	83 ec 04             	sub    $0x4,%esp
801040f5:	52                   	push   %edx
801040f6:	68 0c f5 10 80       	push   $0x8010f50c
801040fb:	50                   	push   %eax
801040fc:	e8 47 40 00 00       	call   80108148 <inituvm>
80104101:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104107:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010410d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104110:	8b 40 18             	mov    0x18(%eax),%eax
80104113:	83 ec 04             	sub    $0x4,%esp
80104116:	6a 4c                	push   $0x4c
80104118:	6a 00                	push   $0x0
8010411a:	50                   	push   %eax
8010411b:	e8 46 12 00 00       	call   80105366 <memset>
80104120:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104126:	8b 40 18             	mov    0x18(%eax),%eax
80104129:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010412f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104132:	8b 40 18             	mov    0x18(%eax),%eax
80104135:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010413b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413e:	8b 50 18             	mov    0x18(%eax),%edx
80104141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104144:	8b 40 18             	mov    0x18(%eax),%eax
80104147:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010414b:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010414f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104152:	8b 50 18             	mov    0x18(%eax),%edx
80104155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104158:	8b 40 18             	mov    0x18(%eax),%eax
8010415b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010415f:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104166:	8b 40 18             	mov    0x18(%eax),%eax
80104169:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104173:	8b 40 18             	mov    0x18(%eax),%eax
80104176:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010417d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104180:	8b 40 18             	mov    0x18(%eax),%eax
80104183:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010418a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418d:	83 c0 6c             	add    $0x6c,%eax
80104190:	83 ec 04             	sub    $0x4,%esp
80104193:	6a 10                	push   $0x10
80104195:	68 eb ad 10 80       	push   $0x8010adeb
8010419a:	50                   	push   %eax
8010419b:	e8 c9 13 00 00       	call   80105569 <safestrcpy>
801041a0:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801041a3:	83 ec 0c             	sub    $0xc,%esp
801041a6:	68 f4 ad 10 80       	push   $0x8010adf4
801041ab:	e8 6d e3 ff ff       	call   8010251d <namei>
801041b0:	83 c4 10             	add    $0x10,%esp
801041b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b6:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801041b9:	83 ec 0c             	sub    $0xc,%esp
801041bc:	68 40 72 11 80       	push   $0x80117240
801041c1:	e8 2a 0f 00 00       	call   801050f0 <acquire>
801041c6:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801041c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041cc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  enqueue(&mlfq[3], p);  // 
801041d3:	83 ec 08             	sub    $0x8,%esp
801041d6:	ff 75 f4             	push   -0xc(%ebp)
801041d9:	68 98 9d 11 80       	push   $0x80119d98
801041de:	e8 71 0a 00 00       	call   80104c54 <enqueue>
801041e3:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801041e6:	83 ec 0c             	sub    $0xc,%esp
801041e9:	68 40 72 11 80       	push   $0x80117240
801041ee:	e8 6b 0f 00 00       	call   8010515e <release>
801041f3:	83 c4 10             	add    $0x10,%esp
}
801041f6:	90                   	nop
801041f7:	c9                   	leave  
801041f8:	c3                   	ret    

801041f9 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801041f9:	55                   	push   %ebp
801041fa:	89 e5                	mov    %esp,%ebp
801041fc:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
801041ff:	e8 3e fd ff ff       	call   80103f42 <myproc>
80104204:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010420a:	8b 00                	mov    (%eax),%eax
8010420c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010420f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104213:	7e 2e                	jle    80104243 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104215:	8b 55 08             	mov    0x8(%ebp),%edx
80104218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421b:	01 c2                	add    %eax,%edx
8010421d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104220:	8b 40 04             	mov    0x4(%eax),%eax
80104223:	83 ec 04             	sub    $0x4,%esp
80104226:	52                   	push   %edx
80104227:	ff 75 f4             	push   -0xc(%ebp)
8010422a:	50                   	push   %eax
8010422b:	e8 55 40 00 00       	call   80108285 <allocuvm>
80104230:	83 c4 10             	add    $0x10,%esp
80104233:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104236:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010423a:	75 3b                	jne    80104277 <growproc+0x7e>
      return -1;
8010423c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104241:	eb 4f                	jmp    80104292 <growproc+0x99>
  } else if(n < 0){
80104243:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104247:	79 2e                	jns    80104277 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104249:	8b 55 08             	mov    0x8(%ebp),%edx
8010424c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424f:	01 c2                	add    %eax,%edx
80104251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104254:	8b 40 04             	mov    0x4(%eax),%eax
80104257:	83 ec 04             	sub    $0x4,%esp
8010425a:	52                   	push   %edx
8010425b:	ff 75 f4             	push   -0xc(%ebp)
8010425e:	50                   	push   %eax
8010425f:	e8 26 41 00 00       	call   8010838a <deallocuvm>
80104264:	83 c4 10             	add    $0x10,%esp
80104267:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010426a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010426e:	75 07                	jne    80104277 <growproc+0x7e>
      return -1;
80104270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104275:	eb 1b                	jmp    80104292 <growproc+0x99>
  }
  curproc->sz = sz;
80104277:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010427a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010427d:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010427f:	83 ec 0c             	sub    $0xc,%esp
80104282:	ff 75 f0             	push   -0x10(%ebp)
80104285:	e8 1f 3d 00 00       	call   80107fa9 <switchuvm>
8010428a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010428d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104292:	c9                   	leave  
80104293:	c3                   	ret    

80104294 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104294:	55                   	push   %ebp
80104295:	89 e5                	mov    %esp,%ebp
80104297:	57                   	push   %edi
80104298:	56                   	push   %esi
80104299:	53                   	push   %ebx
8010429a:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010429d:	e8 a0 fc ff ff       	call   80103f42 <myproc>
801042a2:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801042a5:	e8 c1 fc ff ff       	call   80103f6b <allocproc>
801042aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
801042ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801042b1:	75 0a                	jne    801042bd <fork+0x29>
    return -1;
801042b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042b8:	e9 98 01 00 00       	jmp    80104455 <fork+0x1c1>
  }

  for (int i = 0; i < MLFQ_LEVELS; i++) {
801042bd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801042c4:	eb 24                	jmp    801042ea <fork+0x56>
    np->ticks[i] = 0;
801042c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801042c9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042cc:	83 c2 20             	add    $0x20,%edx
801042cf:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    np->wait_ticks[i] = 0;
801042d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801042d9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042dc:	83 c2 24             	add    $0x24,%edx
801042df:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  for (int i = 0; i < MLFQ_LEVELS; i++) {
801042e6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801042ea:	83 7d e0 03          	cmpl   $0x3,-0x20(%ebp)
801042ee:	7e d6                	jle    801042c6 <fork+0x32>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801042f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042f3:	8b 10                	mov    (%eax),%edx
801042f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042f8:	8b 40 04             	mov    0x4(%eax),%eax
801042fb:	83 ec 08             	sub    $0x8,%esp
801042fe:	52                   	push   %edx
801042ff:	50                   	push   %eax
80104300:	e8 23 42 00 00       	call   80108528 <copyuvm>
80104305:	83 c4 10             	add    $0x10,%esp
80104308:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010430b:	89 42 04             	mov    %eax,0x4(%edx)
8010430e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104311:	8b 40 04             	mov    0x4(%eax),%eax
80104314:	85 c0                	test   %eax,%eax
80104316:	75 30                	jne    80104348 <fork+0xb4>
    kfree(np->kstack);
80104318:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010431b:	8b 40 08             	mov    0x8(%eax),%eax
8010431e:	83 ec 0c             	sub    $0xc,%esp
80104321:	50                   	push   %eax
80104322:	e8 c3 e8 ff ff       	call   80102bea <kfree>
80104327:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010432a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010432d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104334:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104337:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010433e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104343:	e9 0d 01 00 00       	jmp    80104455 <fork+0x1c1>
  }
  np->sz = curproc->sz;
80104348:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010434b:	8b 10                	mov    (%eax),%edx
8010434d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104350:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104352:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104355:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104358:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010435b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010435e:	8b 48 18             	mov    0x18(%eax),%ecx
80104361:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104364:	8b 40 18             	mov    0x18(%eax),%eax
80104367:	89 c2                	mov    %eax,%edx
80104369:	89 cb                	mov    %ecx,%ebx
8010436b:	b8 13 00 00 00       	mov    $0x13,%eax
80104370:	89 d7                	mov    %edx,%edi
80104372:	89 de                	mov    %ebx,%esi
80104374:	89 c1                	mov    %eax,%ecx
80104376:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104378:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010437b:	8b 40 18             	mov    0x18(%eax),%eax
8010437e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104385:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010438c:	eb 3b                	jmp    801043c9 <fork+0x135>
    if(curproc->ofile[i])
8010438e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104391:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104394:	83 c2 08             	add    $0x8,%edx
80104397:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010439b:	85 c0                	test   %eax,%eax
8010439d:	74 26                	je     801043c5 <fork+0x131>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010439f:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801043a5:	83 c2 08             	add    $0x8,%edx
801043a8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043ac:	83 ec 0c             	sub    $0xc,%esp
801043af:	50                   	push   %eax
801043b0:	e8 95 cc ff ff       	call   8010104a <filedup>
801043b5:	83 c4 10             	add    $0x10,%esp
801043b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
801043bb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801043be:	83 c1 08             	add    $0x8,%ecx
801043c1:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801043c5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801043c9:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801043cd:	7e bf                	jle    8010438e <fork+0xfa>
  np->cwd = idup(curproc->cwd);
801043cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043d2:	8b 40 68             	mov    0x68(%eax),%eax
801043d5:	83 ec 0c             	sub    $0xc,%esp
801043d8:	50                   	push   %eax
801043d9:	e8 d2 d5 ff ff       	call   801019b0 <idup>
801043de:	83 c4 10             	add    $0x10,%esp
801043e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
801043e4:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801043e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043ea:	8d 50 6c             	lea    0x6c(%eax),%edx
801043ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
801043f0:	83 c0 6c             	add    $0x6c,%eax
801043f3:	83 ec 04             	sub    $0x4,%esp
801043f6:	6a 10                	push   $0x10
801043f8:	52                   	push   %edx
801043f9:	50                   	push   %eax
801043fa:	e8 6a 11 00 00       	call   80105569 <safestrcpy>
801043ff:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104402:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104405:	8b 40 10             	mov    0x10(%eax),%eax
80104408:	89 45 d4             	mov    %eax,-0x2c(%ebp)

  acquire(&ptable.lock);
8010440b:	83 ec 0c             	sub    $0xc,%esp
8010440e:	68 40 72 11 80       	push   $0x80117240
80104413:	e8 d8 0c 00 00       	call   801050f0 <acquire>
80104418:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010441b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010441e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  np->priority = 3;                // 기본 priority 지정
80104425:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104428:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  enqueue(&mlfq[3], np);
8010442f:	83 ec 08             	sub    $0x8,%esp
80104432:	ff 75 d8             	push   -0x28(%ebp)
80104435:	68 98 9d 11 80       	push   $0x80119d98
8010443a:	e8 15 08 00 00       	call   80104c54 <enqueue>
8010443f:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104442:	83 ec 0c             	sub    $0xc,%esp
80104445:	68 40 72 11 80       	push   $0x80117240
8010444a:	e8 0f 0d 00 00       	call   8010515e <release>
8010444f:	83 c4 10             	add    $0x10,%esp

  return pid;
80104452:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
80104455:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104458:	5b                   	pop    %ebx
80104459:	5e                   	pop    %esi
8010445a:	5f                   	pop    %edi
8010445b:	5d                   	pop    %ebp
8010445c:	c3                   	ret    

8010445d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010445d:	55                   	push   %ebp
8010445e:	89 e5                	mov    %esp,%ebp
80104460:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104463:	e8 da fa ff ff       	call   80103f42 <myproc>
80104468:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010446b:	a1 a0 9e 11 80       	mov    0x80119ea0,%eax
80104470:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104473:	75 0d                	jne    80104482 <exit+0x25>
    panic("init exiting");
80104475:	83 ec 0c             	sub    $0xc,%esp
80104478:	68 f6 ad 10 80       	push   $0x8010adf6
8010447d:	e8 27 c1 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104482:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104489:	eb 3f                	jmp    801044ca <exit+0x6d>
    if(curproc->ofile[fd]){
8010448b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010448e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104491:	83 c2 08             	add    $0x8,%edx
80104494:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104498:	85 c0                	test   %eax,%eax
8010449a:	74 2a                	je     801044c6 <exit+0x69>
      fileclose(curproc->ofile[fd]);
8010449c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010449f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044a2:	83 c2 08             	add    $0x8,%edx
801044a5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044a9:	83 ec 0c             	sub    $0xc,%esp
801044ac:	50                   	push   %eax
801044ad:	e8 e9 cb ff ff       	call   8010109b <fileclose>
801044b2:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801044b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044bb:	83 c2 08             	add    $0x8,%edx
801044be:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801044c5:	00 
  for(fd = 0; fd < NOFILE; fd++){
801044c6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801044ca:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801044ce:	7e bb                	jle    8010448b <exit+0x2e>
    }
  }

  begin_op();
801044d0:	e8 4b f0 ff ff       	call   80103520 <begin_op>
  iput(curproc->cwd);
801044d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044d8:	8b 40 68             	mov    0x68(%eax),%eax
801044db:	83 ec 0c             	sub    $0xc,%esp
801044de:	50                   	push   %eax
801044df:	e8 67 d6 ff ff       	call   80101b4b <iput>
801044e4:	83 c4 10             	add    $0x10,%esp
  end_op();
801044e7:	e8 c0 f0 ff ff       	call   801035ac <end_op>
  curproc->cwd = 0;
801044ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044ef:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801044f6:	83 ec 0c             	sub    $0xc,%esp
801044f9:	68 40 72 11 80       	push   $0x80117240
801044fe:	e8 ed 0b 00 00       	call   801050f0 <acquire>
80104503:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104506:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104509:	8b 40 14             	mov    0x14(%eax),%eax
8010450c:	83 ec 0c             	sub    $0xc,%esp
8010450f:	50                   	push   %eax
80104510:	e8 ff 05 00 00       	call   80104b14 <wakeup1>
80104515:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104518:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
8010451f:	eb 3a                	jmp    8010455b <exit+0xfe>
    if(p->parent == curproc){
80104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104524:	8b 40 14             	mov    0x14(%eax),%eax
80104527:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010452a:	75 28                	jne    80104554 <exit+0xf7>
      p->parent = initproc;
8010452c:	8b 15 a0 9e 11 80    	mov    0x80119ea0,%edx
80104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104535:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453b:	8b 40 0c             	mov    0xc(%eax),%eax
8010453e:	83 f8 05             	cmp    $0x5,%eax
80104541:	75 11                	jne    80104554 <exit+0xf7>
        wakeup1(initproc);
80104543:	a1 a0 9e 11 80       	mov    0x80119ea0,%eax
80104548:	83 ec 0c             	sub    $0xc,%esp
8010454b:	50                   	push   %eax
8010454c:	e8 c3 05 00 00       	call   80104b14 <wakeup1>
80104551:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104554:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
8010455b:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80104562:	72 bd                	jb     80104521 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104564:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104567:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010456e:	e8 8b 03 00 00       	call   801048fe <sched>
  panic("zombie exit");
80104573:	83 ec 0c             	sub    $0xc,%esp
80104576:	68 03 ae 10 80       	push   $0x8010ae03
8010457b:	e8 29 c0 ff ff       	call   801005a9 <panic>

80104580 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104580:	55                   	push   %ebp
80104581:	89 e5                	mov    %esp,%ebp
80104583:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104586:	e8 b7 f9 ff ff       	call   80103f42 <myproc>
8010458b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010458e:	83 ec 0c             	sub    $0xc,%esp
80104591:	68 40 72 11 80       	push   $0x80117240
80104596:	e8 55 0b 00 00       	call   801050f0 <acquire>
8010459b:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010459e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045a5:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801045ac:	e9 a4 00 00 00       	jmp    80104655 <wait+0xd5>
      if(p->parent != curproc)
801045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b4:	8b 40 14             	mov    0x14(%eax),%eax
801045b7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801045ba:	0f 85 8d 00 00 00    	jne    8010464d <wait+0xcd>
        continue;
      havekids = 1;
801045c0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801045c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ca:	8b 40 0c             	mov    0xc(%eax),%eax
801045cd:	83 f8 05             	cmp    $0x5,%eax
801045d0:	75 7c                	jne    8010464e <wait+0xce>
        // Found one.
        pid = p->pid;
801045d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d5:	8b 40 10             	mov    0x10(%eax),%eax
801045d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801045db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045de:	8b 40 08             	mov    0x8(%eax),%eax
801045e1:	83 ec 0c             	sub    $0xc,%esp
801045e4:	50                   	push   %eax
801045e5:	e8 00 e6 ff ff       	call   80102bea <kfree>
801045ea:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801045ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801045f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fa:	8b 40 04             	mov    0x4(%eax),%eax
801045fd:	83 ec 0c             	sub    $0xc,%esp
80104600:	50                   	push   %eax
80104601:	e8 48 3e 00 00       	call   8010844e <freevm>
80104606:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104616:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010461d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104620:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104627:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010462e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104631:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104638:	83 ec 0c             	sub    $0xc,%esp
8010463b:	68 40 72 11 80       	push   $0x80117240
80104640:	e8 19 0b 00 00       	call   8010515e <release>
80104645:	83 c4 10             	add    $0x10,%esp
        return pid;
80104648:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010464b:	eb 54                	jmp    801046a1 <wait+0x121>
        continue;
8010464d:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010464e:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104655:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
8010465c:	0f 82 4f ff ff ff    	jb     801045b1 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104662:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104666:	74 0a                	je     80104672 <wait+0xf2>
80104668:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010466b:	8b 40 24             	mov    0x24(%eax),%eax
8010466e:	85 c0                	test   %eax,%eax
80104670:	74 17                	je     80104689 <wait+0x109>
      release(&ptable.lock);
80104672:	83 ec 0c             	sub    $0xc,%esp
80104675:	68 40 72 11 80       	push   $0x80117240
8010467a:	e8 df 0a 00 00       	call   8010515e <release>
8010467f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104687:	eb 18                	jmp    801046a1 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104689:	83 ec 08             	sub    $0x8,%esp
8010468c:	68 40 72 11 80       	push   $0x80117240
80104691:	ff 75 ec             	push   -0x14(%ebp)
80104694:	e8 d4 03 00 00       	call   80104a6d <sleep>
80104699:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010469c:	e9 fd fe ff ff       	jmp    8010459e <wait+0x1e>
  }
}
801046a1:	c9                   	leave  
801046a2:	c3                   	ret    

801046a3 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801046a3:	55                   	push   %ebp
801046a4:	89 e5                	mov    %esp,%ebp
801046a6:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801046a9:	e8 1c f8 ff ff       	call   80103eca <mycpu>
801046ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
801046b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801046b4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801046bb:	00 00 00 

  for (;;) {
    sti();
801046be:	e8 99 f7 ff ff       	call   80103e5c <sti>
    acquire(&ptable.lock);
801046c3:	83 ec 0c             	sub    $0xc,%esp
801046c6:	68 40 72 11 80       	push   $0x80117240
801046cb:	e8 20 0a 00 00       	call   801050f0 <acquire>
801046d0:	83 c4 10             	add    $0x10,%esp

    int found = 0;
801046d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    // MLFQ 정책인 경우
    if (mycpu()->sched_policy == 1) {
801046da:	e8 eb f7 ff ff       	call   80103eca <mycpu>
801046df:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801046e5:	83 f8 01             	cmp    $0x1,%eax
801046e8:	0f 85 64 01 00 00    	jne    80104852 <scheduler+0x1af>
      for(int level =3; level >= 0; level--)  {
801046ee:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
801046f5:	e9 4f 01 00 00       	jmp    80104849 <scheduler+0x1a6>
        while (!isempty(&mlfq[level])) {
          p = dequeue(&mlfq[level]);
801046fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046fd:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
80104703:	05 80 9a 11 80       	add    $0x80119a80,%eax
80104708:	83 ec 0c             	sub    $0xc,%esp
8010470b:	50                   	push   %eax
8010470c:	e8 bd 05 00 00       	call   80104cce <dequeue>
80104711:	83 c4 10             	add    $0x10,%esp
80104714:	89 45 f4             	mov    %eax,-0xc(%ebp)
          if ( !p || p->state != RUNNABLE)
80104717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010471b:	0f 84 fc 00 00 00    	je     8010481d <scheduler+0x17a>
80104721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104724:	8b 40 0c             	mov    0xc(%eax),%eax
80104727:	83 f8 03             	cmp    $0x3,%eax
8010472a:	74 05                	je     80104731 <scheduler+0x8e>
8010472c:	e9 ec 00 00 00       	jmp    8010481d <scheduler+0x17a>
          continue;

          found = 1;
80104731:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

          c->proc = p;
80104738:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010473b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010473e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
80104744:	83 ec 0c             	sub    $0xc,%esp
80104747:	ff 75 f4             	push   -0xc(%ebp)
8010474a:	e8 5a 38 00 00       	call   80107fa9 <switchuvm>
8010474f:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
80104752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104755:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

          swtch(&c->scheduler, p->context);
8010475c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104762:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104765:	83 c2 04             	add    $0x4,%edx
80104768:	83 ec 08             	sub    $0x8,%esp
8010476b:	50                   	push   %eax
8010476c:	52                   	push   %edx
8010476d:	e8 69 0e 00 00       	call   801055db <swtch>
80104772:	83 c4 10             	add    $0x10,%esp
          switchkvm();
80104775:	e8 16 38 00 00       	call   80107f90 <switchkvm>

          c->proc = 0;
8010477a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010477d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104784:	00 00 00 

          // time slice 기반으로 demotion 판단
          int time_slice[4] = {0,32,16,8};  // Q0는 FIFO
80104787:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
8010478e:	c7 45 dc 20 00 00 00 	movl   $0x20,-0x24(%ebp)
80104795:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
8010479c:	c7 45 e4 08 00 00 00 	movl   $0x8,-0x1c(%ebp)
          if (level > 0 && p->ticks[level] >= time_slice[level]) {
801047a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801047a7:	7e 55                	jle    801047fe <scheduler+0x15b>
801047a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
801047af:	83 c2 20             	add    $0x20,%edx
801047b2:	8b 14 90             	mov    (%eax,%edx,4),%edx
801047b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047b8:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
801047bc:	39 c2                	cmp    %eax,%edx
801047be:	7c 3e                	jl     801047fe <scheduler+0x15b>
            p->ticks[level] = 0;        // 현재 큐 실행 시간 초기화
801047c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801047c6:	83 c2 20             	add    $0x20,%edx
801047c9:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
            p->priority = level - 1;    // 우선순위 강등
801047d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047d3:	8d 50 ff             	lea    -0x1(%eax),%edx
801047d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d9:	89 50 7c             	mov    %edx,0x7c(%eax)
            enqueue(&mlfq[p->priority], p);  // 아래 큐에 넣기
801047dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047df:	8b 40 7c             	mov    0x7c(%eax),%eax
801047e2:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
801047e8:	05 80 9a 11 80       	add    $0x80119a80,%eax
801047ed:	83 ec 08             	sub    $0x8,%esp
801047f0:	ff 75 f4             	push   -0xc(%ebp)
801047f3:	50                   	push   %eax
801047f4:	e8 5b 04 00 00       	call   80104c54 <enqueue>
801047f9:	83 c4 10             	add    $0x10,%esp
801047fc:	eb 41                	jmp    8010483f <scheduler+0x19c>
          } else {
            enqueue(&mlfq[level], p);   // 다시 현재 큐로
801047fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104801:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
80104807:	05 80 9a 11 80       	add    $0x80119a80,%eax
8010480c:	83 ec 08             	sub    $0x8,%esp
8010480f:	ff 75 f4             	push   -0xc(%ebp)
80104812:	50                   	push   %eax
80104813:	e8 3c 04 00 00       	call   80104c54 <enqueue>
80104818:	83 c4 10             	add    $0x10,%esp
          }
          break;
8010481b:	eb 22                	jmp    8010483f <scheduler+0x19c>
        while (!isempty(&mlfq[level])) {
8010481d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104820:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
80104826:	05 80 9a 11 80       	add    $0x80119a80,%eax
8010482b:	83 ec 0c             	sub    $0xc,%esp
8010482e:	50                   	push   %eax
8010482f:	e8 01 04 00 00       	call   80104c35 <isempty>
80104834:	83 c4 10             	add    $0x10,%esp
80104837:	85 c0                	test   %eax,%eax
80104839:	0f 84 bb fe ff ff    	je     801046fa <scheduler+0x57>
        }
        if (found) break;
8010483f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104843:	75 0c                	jne    80104851 <scheduler+0x1ae>
      for(int level =3; level >= 0; level--)  {
80104845:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
80104849:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010484d:	79 ce                	jns    8010481d <scheduler+0x17a>
8010484f:	eb 01                	jmp    80104852 <scheduler+0x1af>
        if (found) break;
80104851:	90                   	nop
      }
    }
    if (!found && mycpu()->sched_policy != 1) {
80104852:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104856:	0f 85 8d 00 00 00    	jne    801048e9 <scheduler+0x246>
8010485c:	e8 69 f6 ff ff       	call   80103eca <mycpu>
80104861:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104867:	83 f8 01             	cmp    $0x1,%eax
8010486a:	74 7d                	je     801048e9 <scheduler+0x246>
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010486c:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104873:	eb 6b                	jmp    801048e0 <scheduler+0x23d>
        if (p->state != RUNNABLE)
80104875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104878:	8b 40 0c             	mov    0xc(%eax),%eax
8010487b:	83 f8 03             	cmp    $0x3,%eax
8010487e:	75 58                	jne    801048d8 <scheduler+0x235>
          continue;
        found = 1;
80104880:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        c->proc = p;
80104887:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010488a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010488d:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
80104893:	83 ec 0c             	sub    $0xc,%esp
80104896:	ff 75 f4             	push   -0xc(%ebp)
80104899:	e8 0b 37 00 00       	call   80107fa9 <switchuvm>
8010489e:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
801048a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a4:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&c->scheduler, p->context);
801048ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ae:	8b 40 1c             	mov    0x1c(%eax),%eax
801048b1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801048b4:	83 c2 04             	add    $0x4,%edx
801048b7:	83 ec 08             	sub    $0x8,%esp
801048ba:	50                   	push   %eax
801048bb:	52                   	push   %edx
801048bc:	e8 1a 0d 00 00       	call   801055db <swtch>
801048c1:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801048c4:	e8 c7 36 00 00       	call   80107f90 <switchkvm>

        c->proc = 0;
801048c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048cc:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801048d3:	00 00 00 
801048d6:	eb 01                	jmp    801048d9 <scheduler+0x236>
          continue;
801048d8:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801048d9:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801048e0:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
801048e7:	72 8c                	jb     80104875 <scheduler+0x1d2>
      }
    }
    release(&ptable.lock);
801048e9:	83 ec 0c             	sub    $0xc,%esp
801048ec:	68 40 72 11 80       	push   $0x80117240
801048f1:	e8 68 08 00 00       	call   8010515e <release>
801048f6:	83 c4 10             	add    $0x10,%esp
  for (;;) {
801048f9:	e9 c0 fd ff ff       	jmp    801046be <scheduler+0x1b>

801048fe <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801048fe:	55                   	push   %ebp
801048ff:	89 e5                	mov    %esp,%ebp
80104901:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104904:	e8 39 f6 ff ff       	call   80103f42 <myproc>
80104909:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
8010490c:	83 ec 0c             	sub    $0xc,%esp
8010490f:	68 40 72 11 80       	push   $0x80117240
80104914:	e8 12 09 00 00       	call   8010522b <holding>
80104919:	83 c4 10             	add    $0x10,%esp
8010491c:	85 c0                	test   %eax,%eax
8010491e:	75 0d                	jne    8010492d <sched+0x2f>
    panic("sched ptable.lock");
80104920:	83 ec 0c             	sub    $0xc,%esp
80104923:	68 0f ae 10 80       	push   $0x8010ae0f
80104928:	e8 7c bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
8010492d:	e8 98 f5 ff ff       	call   80103eca <mycpu>
80104932:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104938:	83 f8 01             	cmp    $0x1,%eax
8010493b:	74 0d                	je     8010494a <sched+0x4c>
    panic("sched locks");
8010493d:	83 ec 0c             	sub    $0xc,%esp
80104940:	68 21 ae 10 80       	push   $0x8010ae21
80104945:	e8 5f bc ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
8010494a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494d:	8b 40 0c             	mov    0xc(%eax),%eax
80104950:	83 f8 04             	cmp    $0x4,%eax
80104953:	75 0d                	jne    80104962 <sched+0x64>
    panic("sched running");
80104955:	83 ec 0c             	sub    $0xc,%esp
80104958:	68 2d ae 10 80       	push   $0x8010ae2d
8010495d:	e8 47 bc ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104962:	e8 e5 f4 ff ff       	call   80103e4c <readeflags>
80104967:	25 00 02 00 00       	and    $0x200,%eax
8010496c:	85 c0                	test   %eax,%eax
8010496e:	74 0d                	je     8010497d <sched+0x7f>
    panic("sched interruptible");
80104970:	83 ec 0c             	sub    $0xc,%esp
80104973:	68 3b ae 10 80       	push   $0x8010ae3b
80104978:	e8 2c bc ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010497d:	e8 48 f5 ff ff       	call   80103eca <mycpu>
80104982:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104988:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010498b:	e8 3a f5 ff ff       	call   80103eca <mycpu>
80104990:	8b 40 04             	mov    0x4(%eax),%eax
80104993:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104996:	83 c2 1c             	add    $0x1c,%edx
80104999:	83 ec 08             	sub    $0x8,%esp
8010499c:	50                   	push   %eax
8010499d:	52                   	push   %edx
8010499e:	e8 38 0c 00 00       	call   801055db <swtch>
801049a3:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801049a6:	e8 1f f5 ff ff       	call   80103eca <mycpu>
801049ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049ae:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801049b4:	90                   	nop
801049b5:	c9                   	leave  
801049b6:	c3                   	ret    

801049b7 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801049b7:	55                   	push   %ebp
801049b8:	89 e5                	mov    %esp,%ebp
801049ba:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801049bd:	83 ec 0c             	sub    $0xc,%esp
801049c0:	68 40 72 11 80       	push   $0x80117240
801049c5:	e8 26 07 00 00       	call   801050f0 <acquire>
801049ca:	83 c4 10             	add    $0x10,%esp
  struct proc *curproc = myproc();
801049cd:	e8 70 f5 ff ff       	call   80103f42 <myproc>
801049d2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  // MLFQ 정책일 경우 RUNNABLE 상태일 때 큐에 다시 넣기
  if (mycpu()->sched_policy == 1) {
801049d5:	e8 f0 f4 ff ff       	call   80103eca <mycpu>
801049da:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801049e0:	83 f8 01             	cmp    $0x1,%eax
801049e3:	75 20                	jne    80104a05 <yield+0x4e>
    enqueue(&mlfq[curproc->priority], curproc);
801049e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e8:	8b 40 7c             	mov    0x7c(%eax),%eax
801049eb:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
801049f1:	05 80 9a 11 80       	add    $0x80119a80,%eax
801049f6:	83 ec 08             	sub    $0x8,%esp
801049f9:	ff 75 f4             	push   -0xc(%ebp)
801049fc:	50                   	push   %eax
801049fd:	e8 52 02 00 00       	call   80104c54 <enqueue>
80104a02:	83 c4 10             	add    $0x10,%esp
  }
  curproc->state = RUNNABLE;
80104a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a08:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104a0f:	e8 ea fe ff ff       	call   801048fe <sched>
  release(&ptable.lock);
80104a14:	83 ec 0c             	sub    $0xc,%esp
80104a17:	68 40 72 11 80       	push   $0x80117240
80104a1c:	e8 3d 07 00 00       	call   8010515e <release>
80104a21:	83 c4 10             	add    $0x10,%esp
}
80104a24:	90                   	nop
80104a25:	c9                   	leave  
80104a26:	c3                   	ret    

80104a27 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104a27:	55                   	push   %ebp
80104a28:	89 e5                	mov    %esp,%ebp
80104a2a:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104a2d:	83 ec 0c             	sub    $0xc,%esp
80104a30:	68 40 72 11 80       	push   $0x80117240
80104a35:	e8 24 07 00 00       	call   8010515e <release>
80104a3a:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104a3d:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104a42:	85 c0                	test   %eax,%eax
80104a44:	74 24                	je     80104a6a <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104a46:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104a4d:	00 00 00 
    iinit(ROOTDEV);
80104a50:	83 ec 0c             	sub    $0xc,%esp
80104a53:	6a 01                	push   $0x1
80104a55:	e8 1e cc ff ff       	call   80101678 <iinit>
80104a5a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104a5d:	83 ec 0c             	sub    $0xc,%esp
80104a60:	6a 01                	push   $0x1
80104a62:	e8 9a e8 ff ff       	call   80103301 <initlog>
80104a67:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104a6a:	90                   	nop
80104a6b:	c9                   	leave  
80104a6c:	c3                   	ret    

80104a6d <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104a6d:	55                   	push   %ebp
80104a6e:	89 e5                	mov    %esp,%ebp
80104a70:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104a73:	e8 ca f4 ff ff       	call   80103f42 <myproc>
80104a78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104a7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a7f:	75 0d                	jne    80104a8e <sleep+0x21>
    panic("sleep");
80104a81:	83 ec 0c             	sub    $0xc,%esp
80104a84:	68 4f ae 10 80       	push   $0x8010ae4f
80104a89:	e8 1b bb ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104a8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104a92:	75 0d                	jne    80104aa1 <sleep+0x34>
    panic("sleep without lk");
80104a94:	83 ec 0c             	sub    $0xc,%esp
80104a97:	68 55 ae 10 80       	push   $0x8010ae55
80104a9c:	e8 08 bb ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104aa1:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104aa8:	74 1e                	je     80104ac8 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104aaa:	83 ec 0c             	sub    $0xc,%esp
80104aad:	68 40 72 11 80       	push   $0x80117240
80104ab2:	e8 39 06 00 00       	call   801050f0 <acquire>
80104ab7:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104aba:	83 ec 0c             	sub    $0xc,%esp
80104abd:	ff 75 0c             	push   0xc(%ebp)
80104ac0:	e8 99 06 00 00       	call   8010515e <release>
80104ac5:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acb:	8b 55 08             	mov    0x8(%ebp),%edx
80104ace:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad4:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104adb:	e8 1e fe ff ff       	call   801048fe <sched>

  // Tidy up.
  p->chan = 0;
80104ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae3:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104aea:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104af1:	74 1e                	je     80104b11 <sleep+0xa4>
    release(&ptable.lock);
80104af3:	83 ec 0c             	sub    $0xc,%esp
80104af6:	68 40 72 11 80       	push   $0x80117240
80104afb:	e8 5e 06 00 00       	call   8010515e <release>
80104b00:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104b03:	83 ec 0c             	sub    $0xc,%esp
80104b06:	ff 75 0c             	push   0xc(%ebp)
80104b09:	e8 e2 05 00 00       	call   801050f0 <acquire>
80104b0e:	83 c4 10             	add    $0x10,%esp
  }
}
80104b11:	90                   	nop
80104b12:	c9                   	leave  
80104b13:	c3                   	ret    

80104b14 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104b14:	55                   	push   %ebp
80104b15:	89 e5                	mov    %esp,%ebp
80104b17:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b1a:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
80104b21:	eb 27                	jmp    80104b4a <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104b23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b26:	8b 40 0c             	mov    0xc(%eax),%eax
80104b29:	83 f8 02             	cmp    $0x2,%eax
80104b2c:	75 15                	jne    80104b43 <wakeup1+0x2f>
80104b2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b31:	8b 40 20             	mov    0x20(%eax),%eax
80104b34:	39 45 08             	cmp    %eax,0x8(%ebp)
80104b37:	75 0a                	jne    80104b43 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104b39:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b3c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b43:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
80104b4a:	81 7d fc 74 9a 11 80 	cmpl   $0x80119a74,-0x4(%ebp)
80104b51:	72 d0                	jb     80104b23 <wakeup1+0xf>
}
80104b53:	90                   	nop
80104b54:	90                   	nop
80104b55:	c9                   	leave  
80104b56:	c3                   	ret    

80104b57 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104b57:	55                   	push   %ebp
80104b58:	89 e5                	mov    %esp,%ebp
80104b5a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104b5d:	83 ec 0c             	sub    $0xc,%esp
80104b60:	68 40 72 11 80       	push   $0x80117240
80104b65:	e8 86 05 00 00       	call   801050f0 <acquire>
80104b6a:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104b6d:	83 ec 0c             	sub    $0xc,%esp
80104b70:	ff 75 08             	push   0x8(%ebp)
80104b73:	e8 9c ff ff ff       	call   80104b14 <wakeup1>
80104b78:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104b7b:	83 ec 0c             	sub    $0xc,%esp
80104b7e:	68 40 72 11 80       	push   $0x80117240
80104b83:	e8 d6 05 00 00       	call   8010515e <release>
80104b88:	83 c4 10             	add    $0x10,%esp
}
80104b8b:	90                   	nop
80104b8c:	c9                   	leave  
80104b8d:	c3                   	ret    

80104b8e <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104b8e:	55                   	push   %ebp
80104b8f:	89 e5                	mov    %esp,%ebp
80104b91:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104b94:	83 ec 0c             	sub    $0xc,%esp
80104b97:	68 40 72 11 80       	push   $0x80117240
80104b9c:	e8 4f 05 00 00       	call   801050f0 <acquire>
80104ba1:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ba4:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104bab:	eb 48                	jmp    80104bf5 <kill+0x67>
    if(p->pid == pid){
80104bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb0:	8b 40 10             	mov    0x10(%eax),%eax
80104bb3:	39 45 08             	cmp    %eax,0x8(%ebp)
80104bb6:	75 36                	jne    80104bee <kill+0x60>
      p->killed = 1;
80104bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc5:	8b 40 0c             	mov    0xc(%eax),%eax
80104bc8:	83 f8 02             	cmp    $0x2,%eax
80104bcb:	75 0a                	jne    80104bd7 <kill+0x49>
        p->state = RUNNABLE;
80104bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104bd7:	83 ec 0c             	sub    $0xc,%esp
80104bda:	68 40 72 11 80       	push   $0x80117240
80104bdf:	e8 7a 05 00 00       	call   8010515e <release>
80104be4:	83 c4 10             	add    $0x10,%esp
      return 0;
80104be7:	b8 00 00 00 00       	mov    $0x0,%eax
80104bec:	eb 25                	jmp    80104c13 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bee:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104bf5:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80104bfc:	72 af                	jb     80104bad <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104bfe:	83 ec 0c             	sub    $0xc,%esp
80104c01:	68 40 72 11 80       	push   $0x80117240
80104c06:	e8 53 05 00 00       	call   8010515e <release>
80104c0b:	83 c4 10             	add    $0x10,%esp
  return -1;
80104c0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c13:	c9                   	leave  
80104c14:	c3                   	ret    

80104c15 <initqueue>:
//큐 초기화
void initqueue(struct queue *q) {
80104c15:	55                   	push   %ebp
80104c16:	89 e5                	mov    %esp,%ebp
  q->front = 0;
80104c18:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1b:	c7 80 00 01 00 00 00 	movl   $0x0,0x100(%eax)
80104c22:	00 00 00 
  q->rear = 0;
80104c25:	8b 45 08             	mov    0x8(%ebp),%eax
80104c28:	c7 80 04 01 00 00 00 	movl   $0x0,0x104(%eax)
80104c2f:	00 00 00 
}
80104c32:	90                   	nop
80104c33:	5d                   	pop    %ebp
80104c34:	c3                   	ret    

80104c35 <isempty>:

// 큐가 비었는지 확인
int isempty(struct queue *q) {
80104c35:	55                   	push   %ebp
80104c36:	89 e5                	mov    %esp,%ebp
  return q->front == q->rear;
80104c38:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3b:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
80104c41:	8b 45 08             	mov    0x8(%ebp),%eax
80104c44:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104c4a:	39 c2                	cmp    %eax,%edx
80104c4c:	0f 94 c0             	sete   %al
80104c4f:	0f b6 c0             	movzbl %al,%eax
}
80104c52:	5d                   	pop    %ebp
80104c53:	c3                   	ret    

80104c54 <enqueue>:

// 큐에 중복없이 프로세스 추가
void enqueue(struct queue *q, struct proc *p) {
80104c54:	55                   	push   %ebp
80104c55:	89 e5                	mov    %esp,%ebp
80104c57:	83 ec 10             	sub    $0x10,%esp
  //이미 들어있는지 검사
  for (int i = q->front; i < q->rear; i++) {
80104c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5d:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
80104c63:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104c66:	eb 1f                	jmp    80104c87 <enqueue+0x33>
    if (q->q[i % QUEUE_SIZE] == p)
80104c68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c6b:	99                   	cltd   
80104c6c:	c1 ea 1a             	shr    $0x1a,%edx
80104c6f:	01 d0                	add    %edx,%eax
80104c71:	83 e0 3f             	and    $0x3f,%eax
80104c74:	29 d0                	sub    %edx,%eax
80104c76:	89 c2                	mov    %eax,%edx
80104c78:	8b 45 08             	mov    0x8(%ebp),%eax
80104c7b:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104c7e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80104c81:	74 48                	je     80104ccb <enqueue+0x77>
  for (int i = q->front; i < q->rear; i++) {
80104c83:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104c87:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8a:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104c90:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80104c93:	7c d3                	jl     80104c68 <enqueue+0x14>
      return; //중복 방지
  }
  q->q[q->rear % QUEUE_SIZE] = p;
80104c95:	8b 45 08             	mov    0x8(%ebp),%eax
80104c98:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104c9e:	99                   	cltd   
80104c9f:	c1 ea 1a             	shr    $0x1a,%edx
80104ca2:	01 d0                	add    %edx,%eax
80104ca4:	83 e0 3f             	and    $0x3f,%eax
80104ca7:	29 d0                	sub    %edx,%eax
80104ca9:	89 c1                	mov    %eax,%ecx
80104cab:	8b 45 08             	mov    0x8(%ebp),%eax
80104cae:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cb1:	89 14 88             	mov    %edx,(%eax,%ecx,4)
  q->rear++;
80104cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb7:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104cbd:	8d 50 01             	lea    0x1(%eax),%edx
80104cc0:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc3:	89 90 04 01 00 00    	mov    %edx,0x104(%eax)
80104cc9:	eb 01                	jmp    80104ccc <enqueue+0x78>
      return; //중복 방지
80104ccb:	90                   	nop
}
80104ccc:	c9                   	leave  
80104ccd:	c3                   	ret    

80104cce <dequeue>:

// 큐에서 프로세스 꺼내기
struct proc* dequeue(struct queue *q) {
80104cce:	55                   	push   %ebp
80104ccf:	89 e5                	mov    %esp,%ebp
80104cd1:	83 ec 10             	sub    $0x10,%esp
  if (isempty(q))
80104cd4:	ff 75 08             	push   0x8(%ebp)
80104cd7:	e8 59 ff ff ff       	call   80104c35 <isempty>
80104cdc:	83 c4 04             	add    $0x4,%esp
80104cdf:	85 c0                	test   %eax,%eax
80104ce1:	74 07                	je     80104cea <dequeue+0x1c>
    return 0;
80104ce3:	b8 00 00 00 00       	mov    $0x0,%eax
80104ce8:	eb 37                	jmp    80104d21 <dequeue+0x53>
  struct proc *p = q->q[q->front % QUEUE_SIZE];
80104cea:	8b 45 08             	mov    0x8(%ebp),%eax
80104ced:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
80104cf3:	99                   	cltd   
80104cf4:	c1 ea 1a             	shr    $0x1a,%edx
80104cf7:	01 d0                	add    %edx,%eax
80104cf9:	83 e0 3f             	and    $0x3f,%eax
80104cfc:	29 d0                	sub    %edx,%eax
80104cfe:	89 c2                	mov    %eax,%edx
80104d00:	8b 45 08             	mov    0x8(%ebp),%eax
80104d03:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104d06:	89 45 fc             	mov    %eax,-0x4(%ebp)
  q->front++;
80104d09:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0c:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
80104d12:	8d 50 01             	lea    0x1(%eax),%edx
80104d15:	8b 45 08             	mov    0x8(%ebp),%eax
80104d18:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
  return p;
80104d1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d21:	c9                   	leave  
80104d22:	c3                   	ret    

80104d23 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d23:	55                   	push   %ebp
80104d24:	89 e5                	mov    %esp,%ebp
80104d26:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d29:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
80104d30:	e9 da 00 00 00       	jmp    80104e0f <procdump+0xec>
    if(p->state == UNUSED)
80104d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d38:	8b 40 0c             	mov    0xc(%eax),%eax
80104d3b:	85 c0                	test   %eax,%eax
80104d3d:	0f 84 c4 00 00 00    	je     80104e07 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d46:	8b 40 0c             	mov    0xc(%eax),%eax
80104d49:	83 f8 05             	cmp    $0x5,%eax
80104d4c:	77 23                	ja     80104d71 <procdump+0x4e>
80104d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d51:	8b 40 0c             	mov    0xc(%eax),%eax
80104d54:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104d5b:	85 c0                	test   %eax,%eax
80104d5d:	74 12                	je     80104d71 <procdump+0x4e>
      state = states[p->state];
80104d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d62:	8b 40 0c             	mov    0xc(%eax),%eax
80104d65:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104d6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d6f:	eb 07                	jmp    80104d78 <procdump+0x55>
    else
      state = "???";
80104d71:	c7 45 ec 66 ae 10 80 	movl   $0x8010ae66,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d7b:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d81:	8b 40 10             	mov    0x10(%eax),%eax
80104d84:	52                   	push   %edx
80104d85:	ff 75 ec             	push   -0x14(%ebp)
80104d88:	50                   	push   %eax
80104d89:	68 6a ae 10 80       	push   $0x8010ae6a
80104d8e:	e8 61 b6 ff ff       	call   801003f4 <cprintf>
80104d93:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d99:	8b 40 0c             	mov    0xc(%eax),%eax
80104d9c:	83 f8 02             	cmp    $0x2,%eax
80104d9f:	75 54                	jne    80104df5 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da4:	8b 40 1c             	mov    0x1c(%eax),%eax
80104da7:	8b 40 0c             	mov    0xc(%eax),%eax
80104daa:	83 c0 08             	add    $0x8,%eax
80104dad:	89 c2                	mov    %eax,%edx
80104daf:	83 ec 08             	sub    $0x8,%esp
80104db2:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104db5:	50                   	push   %eax
80104db6:	52                   	push   %edx
80104db7:	e8 f4 03 00 00       	call   801051b0 <getcallerpcs>
80104dbc:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104dbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104dc6:	eb 1c                	jmp    80104de4 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dcb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104dcf:	83 ec 08             	sub    $0x8,%esp
80104dd2:	50                   	push   %eax
80104dd3:	68 73 ae 10 80       	push   $0x8010ae73
80104dd8:	e8 17 b6 ff ff       	call   801003f4 <cprintf>
80104ddd:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104de0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104de4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104de8:	7f 0b                	jg     80104df5 <procdump+0xd2>
80104dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ded:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104df1:	85 c0                	test   %eax,%eax
80104df3:	75 d3                	jne    80104dc8 <procdump+0xa5>
    }
    cprintf("\n");
80104df5:	83 ec 0c             	sub    $0xc,%esp
80104df8:	68 77 ae 10 80       	push   $0x8010ae77
80104dfd:	e8 f2 b5 ff ff       	call   801003f4 <cprintf>
80104e02:	83 c4 10             	add    $0x10,%esp
80104e05:	eb 01                	jmp    80104e08 <procdump+0xe5>
      continue;
80104e07:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e08:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
80104e0f:	81 7d f0 74 9a 11 80 	cmpl   $0x80119a74,-0x10(%ebp)
80104e16:	0f 82 19 ff ff ff    	jb     80104d35 <procdump+0x12>
  }
}
80104e1c:	90                   	nop
80104e1d:	90                   	nop
80104e1e:	c9                   	leave  
80104e1f:	c3                   	ret    

80104e20 <setSchedPolicy>:
//추가
int
setSchedPolicy(int policy)
{
80104e20:	55                   	push   %ebp
80104e21:	89 e5                	mov    %esp,%ebp
80104e23:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)  // 정책 번호 범위 확인
80104e26:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104e2a:	78 06                	js     80104e32 <setSchedPolicy+0x12>
80104e2c:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104e30:	7e 07                	jle    80104e39 <setSchedPolicy+0x19>
    return -1;
80104e32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e37:	eb 1d                	jmp    80104e56 <setSchedPolicy+0x36>
  
  pushcli(); //인터럽트 끄기
80104e39:	e8 1d 04 00 00       	call   8010525b <pushcli>
  mycpu()->sched_policy = policy;
80104e3e:	e8 87 f0 ff ff       	call   80103eca <mycpu>
80104e43:	8b 55 08             	mov    0x8(%ebp),%edx
80104e46:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli(); //인터럽트 켜기
80104e4c:	e8 57 04 00 00       	call   801052a8 <popcli>
  return 0;
80104e51:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e56:	c9                   	leave  
80104e57:	c3                   	ret    

80104e58 <getpinfo>:


int
getpinfo(struct pstat *ps)
{
80104e58:	55                   	push   %ebp
80104e59:	89 e5                	mov    %esp,%ebp
80104e5b:	53                   	push   %ebx
80104e5c:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e5f:	83 ec 0c             	sub    $0xc,%esp
80104e62:	68 40 72 11 80       	push   $0x80117240
80104e67:	e8 84 02 00 00       	call   801050f0 <acquire>
80104e6c:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROC; i++) {
80104e6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e76:	e9 d2 00 00 00       	jmp    80104f4d <getpinfo+0xf5>
    p = &ptable.proc[i];
80104e7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e7e:	89 d0                	mov    %edx,%eax
80104e80:	c1 e0 02             	shl    $0x2,%eax
80104e83:	01 d0                	add    %edx,%eax
80104e85:	c1 e0 05             	shl    $0x5,%eax
80104e88:	83 c0 30             	add    $0x30,%eax
80104e8b:	05 40 72 11 80       	add    $0x80117240,%eax
80104e90:	83 c0 04             	add    $0x4,%eax
80104e93:	89 45 ec             	mov    %eax,-0x14(%ebp)

    ps->inuse[i] = (p->state != UNUSED);
80104e96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e99:	8b 40 0c             	mov    0xc(%eax),%eax
80104e9c:	85 c0                	test   %eax,%eax
80104e9e:	0f 95 c0             	setne  %al
80104ea1:	0f b6 c8             	movzbl %al,%ecx
80104ea4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eaa:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
80104ead:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104eb0:	8b 50 10             	mov    0x10(%eax),%edx
80104eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104eb9:	83 c1 40             	add    $0x40,%ecx
80104ebc:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = p->priority;
80104ebf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ec2:	8b 50 7c             	mov    0x7c(%eax),%edx
80104ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104ecb:	83 e9 80             	sub    $0xffffff80,%ecx
80104ece:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
80104ed1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ed4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ed7:	89 c1                	mov    %eax,%ecx
80104ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80104edc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104edf:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80104ee5:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < MLFQ_LEVELS; j++) {
80104ee8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104eef:	eb 52                	jmp    80104f43 <getpinfo+0xeb>
      ps->ticks[i][j] = p->ticks[j];
80104ef1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ef4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ef7:	83 c2 20             	add    $0x20,%edx
80104efa:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104efd:	8b 45 08             	mov    0x8(%ebp),%eax
80104f00:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104f03:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104f0a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f0d:	01 d9                	add    %ebx,%ecx
80104f0f:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104f15:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
80104f18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f1e:	83 c2 24             	add    $0x24,%edx
80104f21:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104f24:	8b 45 08             	mov    0x8(%ebp),%eax
80104f27:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104f2a:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104f31:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f34:	01 d9                	add    %ebx,%ecx
80104f36:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104f3c:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < MLFQ_LEVELS; j++) {
80104f3f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104f43:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104f47:	7e a8                	jle    80104ef1 <getpinfo+0x99>
  for (int i = 0; i < NPROC; i++) {
80104f49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f4d:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104f51:	0f 8e 24 ff ff ff    	jle    80104e7b <getpinfo+0x23>
    }
  }

  release(&ptable.lock);
80104f57:	83 ec 0c             	sub    $0xc,%esp
80104f5a:	68 40 72 11 80       	push   $0x80117240
80104f5f:	e8 fa 01 00 00       	call   8010515e <release>
80104f64:	83 c4 10             	add    $0x10,%esp
  return 0;
80104f67:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f6f:	c9                   	leave  
80104f70:	c3                   	ret    

80104f71 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104f71:	55                   	push   %ebp
80104f72:	89 e5                	mov    %esp,%ebp
80104f74:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104f77:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7a:	83 c0 04             	add    $0x4,%eax
80104f7d:	83 ec 08             	sub    $0x8,%esp
80104f80:	68 a3 ae 10 80       	push   $0x8010aea3
80104f85:	50                   	push   %eax
80104f86:	e8 43 01 00 00       	call   801050ce <initlock>
80104f8b:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f91:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f94:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104f97:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa3:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104faa:	90                   	nop
80104fab:	c9                   	leave  
80104fac:	c3                   	ret    

80104fad <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104fad:	55                   	push   %ebp
80104fae:	89 e5                	mov    %esp,%ebp
80104fb0:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb6:	83 c0 04             	add    $0x4,%eax
80104fb9:	83 ec 0c             	sub    $0xc,%esp
80104fbc:	50                   	push   %eax
80104fbd:	e8 2e 01 00 00       	call   801050f0 <acquire>
80104fc2:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104fc5:	eb 15                	jmp    80104fdc <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104fca:	83 c0 04             	add    $0x4,%eax
80104fcd:	83 ec 08             	sub    $0x8,%esp
80104fd0:	50                   	push   %eax
80104fd1:	ff 75 08             	push   0x8(%ebp)
80104fd4:	e8 94 fa ff ff       	call   80104a6d <sleep>
80104fd9:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fdf:	8b 00                	mov    (%eax),%eax
80104fe1:	85 c0                	test   %eax,%eax
80104fe3:	75 e2                	jne    80104fc7 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104fee:	e8 4f ef ff ff       	call   80103f42 <myproc>
80104ff3:	8b 50 10             	mov    0x10(%eax),%edx
80104ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff9:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fff:	83 c0 04             	add    $0x4,%eax
80105002:	83 ec 0c             	sub    $0xc,%esp
80105005:	50                   	push   %eax
80105006:	e8 53 01 00 00       	call   8010515e <release>
8010500b:	83 c4 10             	add    $0x10,%esp
}
8010500e:	90                   	nop
8010500f:	c9                   	leave  
80105010:	c3                   	ret    

80105011 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105011:	55                   	push   %ebp
80105012:	89 e5                	mov    %esp,%ebp
80105014:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105017:	8b 45 08             	mov    0x8(%ebp),%eax
8010501a:	83 c0 04             	add    $0x4,%eax
8010501d:	83 ec 0c             	sub    $0xc,%esp
80105020:	50                   	push   %eax
80105021:	e8 ca 00 00 00       	call   801050f0 <acquire>
80105026:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105029:	8b 45 08             	mov    0x8(%ebp),%eax
8010502c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105032:	8b 45 08             	mov    0x8(%ebp),%eax
80105035:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010503c:	83 ec 0c             	sub    $0xc,%esp
8010503f:	ff 75 08             	push   0x8(%ebp)
80105042:	e8 10 fb ff ff       	call   80104b57 <wakeup>
80105047:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010504a:	8b 45 08             	mov    0x8(%ebp),%eax
8010504d:	83 c0 04             	add    $0x4,%eax
80105050:	83 ec 0c             	sub    $0xc,%esp
80105053:	50                   	push   %eax
80105054:	e8 05 01 00 00       	call   8010515e <release>
80105059:	83 c4 10             	add    $0x10,%esp
}
8010505c:	90                   	nop
8010505d:	c9                   	leave  
8010505e:	c3                   	ret    

8010505f <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010505f:	55                   	push   %ebp
80105060:	89 e5                	mov    %esp,%ebp
80105062:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80105065:	8b 45 08             	mov    0x8(%ebp),%eax
80105068:	83 c0 04             	add    $0x4,%eax
8010506b:	83 ec 0c             	sub    $0xc,%esp
8010506e:	50                   	push   %eax
8010506f:	e8 7c 00 00 00       	call   801050f0 <acquire>
80105074:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80105077:	8b 45 08             	mov    0x8(%ebp),%eax
8010507a:	8b 00                	mov    (%eax),%eax
8010507c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010507f:	8b 45 08             	mov    0x8(%ebp),%eax
80105082:	83 c0 04             	add    $0x4,%eax
80105085:	83 ec 0c             	sub    $0xc,%esp
80105088:	50                   	push   %eax
80105089:	e8 d0 00 00 00       	call   8010515e <release>
8010508e:	83 c4 10             	add    $0x10,%esp
  return r;
80105091:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105094:	c9                   	leave  
80105095:	c3                   	ret    

80105096 <readeflags>:
{
80105096:	55                   	push   %ebp
80105097:	89 e5                	mov    %esp,%ebp
80105099:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010509c:	9c                   	pushf  
8010509d:	58                   	pop    %eax
8010509e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801050a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050a4:	c9                   	leave  
801050a5:	c3                   	ret    

801050a6 <cli>:
{
801050a6:	55                   	push   %ebp
801050a7:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801050a9:	fa                   	cli    
}
801050aa:	90                   	nop
801050ab:	5d                   	pop    %ebp
801050ac:	c3                   	ret    

801050ad <sti>:
{
801050ad:	55                   	push   %ebp
801050ae:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801050b0:	fb                   	sti    
}
801050b1:	90                   	nop
801050b2:	5d                   	pop    %ebp
801050b3:	c3                   	ret    

801050b4 <xchg>:
{
801050b4:	55                   	push   %ebp
801050b5:	89 e5                	mov    %esp,%ebp
801050b7:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801050ba:	8b 55 08             	mov    0x8(%ebp),%edx
801050bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801050c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050c3:	f0 87 02             	lock xchg %eax,(%edx)
801050c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801050c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050cc:	c9                   	leave  
801050cd:	c3                   	ret    

801050ce <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801050ce:	55                   	push   %ebp
801050cf:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801050d1:	8b 45 08             	mov    0x8(%ebp),%eax
801050d4:	8b 55 0c             	mov    0xc(%ebp),%edx
801050d7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801050da:	8b 45 08             	mov    0x8(%ebp),%eax
801050dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050e3:	8b 45 08             	mov    0x8(%ebp),%eax
801050e6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050ed:	90                   	nop
801050ee:	5d                   	pop    %ebp
801050ef:	c3                   	ret    

801050f0 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050f0:	55                   	push   %ebp
801050f1:	89 e5                	mov    %esp,%ebp
801050f3:	53                   	push   %ebx
801050f4:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050f7:	e8 5f 01 00 00       	call   8010525b <pushcli>
  if(holding(lk)){
801050fc:	8b 45 08             	mov    0x8(%ebp),%eax
801050ff:	83 ec 0c             	sub    $0xc,%esp
80105102:	50                   	push   %eax
80105103:	e8 23 01 00 00       	call   8010522b <holding>
80105108:	83 c4 10             	add    $0x10,%esp
8010510b:	85 c0                	test   %eax,%eax
8010510d:	74 0d                	je     8010511c <acquire+0x2c>
    panic("acquire");
8010510f:	83 ec 0c             	sub    $0xc,%esp
80105112:	68 ae ae 10 80       	push   $0x8010aeae
80105117:	e8 8d b4 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010511c:	90                   	nop
8010511d:	8b 45 08             	mov    0x8(%ebp),%eax
80105120:	83 ec 08             	sub    $0x8,%esp
80105123:	6a 01                	push   $0x1
80105125:	50                   	push   %eax
80105126:	e8 89 ff ff ff       	call   801050b4 <xchg>
8010512b:	83 c4 10             	add    $0x10,%esp
8010512e:	85 c0                	test   %eax,%eax
80105130:	75 eb                	jne    8010511d <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105132:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105137:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010513a:	e8 8b ed ff ff       	call   80103eca <mycpu>
8010513f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105142:	8b 45 08             	mov    0x8(%ebp),%eax
80105145:	83 c0 0c             	add    $0xc,%eax
80105148:	83 ec 08             	sub    $0x8,%esp
8010514b:	50                   	push   %eax
8010514c:	8d 45 08             	lea    0x8(%ebp),%eax
8010514f:	50                   	push   %eax
80105150:	e8 5b 00 00 00       	call   801051b0 <getcallerpcs>
80105155:	83 c4 10             	add    $0x10,%esp
}
80105158:	90                   	nop
80105159:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010515c:	c9                   	leave  
8010515d:	c3                   	ret    

8010515e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010515e:	55                   	push   %ebp
8010515f:	89 e5                	mov    %esp,%ebp
80105161:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105164:	83 ec 0c             	sub    $0xc,%esp
80105167:	ff 75 08             	push   0x8(%ebp)
8010516a:	e8 bc 00 00 00       	call   8010522b <holding>
8010516f:	83 c4 10             	add    $0x10,%esp
80105172:	85 c0                	test   %eax,%eax
80105174:	75 0d                	jne    80105183 <release+0x25>
    panic("release");
80105176:	83 ec 0c             	sub    $0xc,%esp
80105179:	68 b6 ae 10 80       	push   $0x8010aeb6
8010517e:	e8 26 b4 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80105183:	8b 45 08             	mov    0x8(%ebp),%eax
80105186:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010518d:	8b 45 08             	mov    0x8(%ebp),%eax
80105190:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105197:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010519c:	8b 45 08             	mov    0x8(%ebp),%eax
8010519f:	8b 55 08             	mov    0x8(%ebp),%edx
801051a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801051a8:	e8 fb 00 00 00       	call   801052a8 <popcli>
}
801051ad:	90                   	nop
801051ae:	c9                   	leave  
801051af:	c3                   	ret    

801051b0 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801051b0:	55                   	push   %ebp
801051b1:	89 e5                	mov    %esp,%ebp
801051b3:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801051b6:	8b 45 08             	mov    0x8(%ebp),%eax
801051b9:	83 e8 08             	sub    $0x8,%eax
801051bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801051bf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801051c6:	eb 38                	jmp    80105200 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801051c8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801051cc:	74 53                	je     80105221 <getcallerpcs+0x71>
801051ce:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801051d5:	76 4a                	jbe    80105221 <getcallerpcs+0x71>
801051d7:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801051db:	74 44                	je     80105221 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801051dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ea:	01 c2                	add    %eax,%edx
801051ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051ef:	8b 40 04             	mov    0x4(%eax),%eax
801051f2:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801051f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051f7:	8b 00                	mov    (%eax),%eax
801051f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801051fc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105200:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105204:	7e c2                	jle    801051c8 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105206:	eb 19                	jmp    80105221 <getcallerpcs+0x71>
    pcs[i] = 0;
80105208:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010520b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105212:	8b 45 0c             	mov    0xc(%ebp),%eax
80105215:	01 d0                	add    %edx,%eax
80105217:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010521d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105221:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105225:	7e e1                	jle    80105208 <getcallerpcs+0x58>
}
80105227:	90                   	nop
80105228:	90                   	nop
80105229:	c9                   	leave  
8010522a:	c3                   	ret    

8010522b <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010522b:	55                   	push   %ebp
8010522c:	89 e5                	mov    %esp,%ebp
8010522e:	53                   	push   %ebx
8010522f:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105232:	8b 45 08             	mov    0x8(%ebp),%eax
80105235:	8b 00                	mov    (%eax),%eax
80105237:	85 c0                	test   %eax,%eax
80105239:	74 16                	je     80105251 <holding+0x26>
8010523b:	8b 45 08             	mov    0x8(%ebp),%eax
8010523e:	8b 58 08             	mov    0x8(%eax),%ebx
80105241:	e8 84 ec ff ff       	call   80103eca <mycpu>
80105246:	39 c3                	cmp    %eax,%ebx
80105248:	75 07                	jne    80105251 <holding+0x26>
8010524a:	b8 01 00 00 00       	mov    $0x1,%eax
8010524f:	eb 05                	jmp    80105256 <holding+0x2b>
80105251:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105259:	c9                   	leave  
8010525a:	c3                   	ret    

8010525b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010525b:	55                   	push   %ebp
8010525c:	89 e5                	mov    %esp,%ebp
8010525e:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105261:	e8 30 fe ff ff       	call   80105096 <readeflags>
80105266:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105269:	e8 38 fe ff ff       	call   801050a6 <cli>
  if(mycpu()->ncli == 0)
8010526e:	e8 57 ec ff ff       	call   80103eca <mycpu>
80105273:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105279:	85 c0                	test   %eax,%eax
8010527b:	75 14                	jne    80105291 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
8010527d:	e8 48 ec ff ff       	call   80103eca <mycpu>
80105282:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105285:	81 e2 00 02 00 00    	and    $0x200,%edx
8010528b:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105291:	e8 34 ec ff ff       	call   80103eca <mycpu>
80105296:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010529c:	83 c2 01             	add    $0x1,%edx
8010529f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801052a5:	90                   	nop
801052a6:	c9                   	leave  
801052a7:	c3                   	ret    

801052a8 <popcli>:

void
popcli(void)
{
801052a8:	55                   	push   %ebp
801052a9:	89 e5                	mov    %esp,%ebp
801052ab:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801052ae:	e8 e3 fd ff ff       	call   80105096 <readeflags>
801052b3:	25 00 02 00 00       	and    $0x200,%eax
801052b8:	85 c0                	test   %eax,%eax
801052ba:	74 0d                	je     801052c9 <popcli+0x21>
    panic("popcli - interruptible");
801052bc:	83 ec 0c             	sub    $0xc,%esp
801052bf:	68 be ae 10 80       	push   $0x8010aebe
801052c4:	e8 e0 b2 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801052c9:	e8 fc eb ff ff       	call   80103eca <mycpu>
801052ce:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801052d4:	83 ea 01             	sub    $0x1,%edx
801052d7:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801052dd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052e3:	85 c0                	test   %eax,%eax
801052e5:	79 0d                	jns    801052f4 <popcli+0x4c>
    panic("popcli");
801052e7:	83 ec 0c             	sub    $0xc,%esp
801052ea:	68 d5 ae 10 80       	push   $0x8010aed5
801052ef:	e8 b5 b2 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801052f4:	e8 d1 eb ff ff       	call   80103eca <mycpu>
801052f9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052ff:	85 c0                	test   %eax,%eax
80105301:	75 14                	jne    80105317 <popcli+0x6f>
80105303:	e8 c2 eb ff ff       	call   80103eca <mycpu>
80105308:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010530e:	85 c0                	test   %eax,%eax
80105310:	74 05                	je     80105317 <popcli+0x6f>
    sti();
80105312:	e8 96 fd ff ff       	call   801050ad <sti>
}
80105317:	90                   	nop
80105318:	c9                   	leave  
80105319:	c3                   	ret    

8010531a <stosb>:
{
8010531a:	55                   	push   %ebp
8010531b:	89 e5                	mov    %esp,%ebp
8010531d:	57                   	push   %edi
8010531e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010531f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105322:	8b 55 10             	mov    0x10(%ebp),%edx
80105325:	8b 45 0c             	mov    0xc(%ebp),%eax
80105328:	89 cb                	mov    %ecx,%ebx
8010532a:	89 df                	mov    %ebx,%edi
8010532c:	89 d1                	mov    %edx,%ecx
8010532e:	fc                   	cld    
8010532f:	f3 aa                	rep stos %al,%es:(%edi)
80105331:	89 ca                	mov    %ecx,%edx
80105333:	89 fb                	mov    %edi,%ebx
80105335:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105338:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010533b:	90                   	nop
8010533c:	5b                   	pop    %ebx
8010533d:	5f                   	pop    %edi
8010533e:	5d                   	pop    %ebp
8010533f:	c3                   	ret    

80105340 <stosl>:
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
80105343:	57                   	push   %edi
80105344:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105345:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105348:	8b 55 10             	mov    0x10(%ebp),%edx
8010534b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010534e:	89 cb                	mov    %ecx,%ebx
80105350:	89 df                	mov    %ebx,%edi
80105352:	89 d1                	mov    %edx,%ecx
80105354:	fc                   	cld    
80105355:	f3 ab                	rep stos %eax,%es:(%edi)
80105357:	89 ca                	mov    %ecx,%edx
80105359:	89 fb                	mov    %edi,%ebx
8010535b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010535e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105361:	90                   	nop
80105362:	5b                   	pop    %ebx
80105363:	5f                   	pop    %edi
80105364:	5d                   	pop    %ebp
80105365:	c3                   	ret    

80105366 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105366:	55                   	push   %ebp
80105367:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105369:	8b 45 08             	mov    0x8(%ebp),%eax
8010536c:	83 e0 03             	and    $0x3,%eax
8010536f:	85 c0                	test   %eax,%eax
80105371:	75 43                	jne    801053b6 <memset+0x50>
80105373:	8b 45 10             	mov    0x10(%ebp),%eax
80105376:	83 e0 03             	and    $0x3,%eax
80105379:	85 c0                	test   %eax,%eax
8010537b:	75 39                	jne    801053b6 <memset+0x50>
    c &= 0xFF;
8010537d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105384:	8b 45 10             	mov    0x10(%ebp),%eax
80105387:	c1 e8 02             	shr    $0x2,%eax
8010538a:	89 c2                	mov    %eax,%edx
8010538c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010538f:	c1 e0 18             	shl    $0x18,%eax
80105392:	89 c1                	mov    %eax,%ecx
80105394:	8b 45 0c             	mov    0xc(%ebp),%eax
80105397:	c1 e0 10             	shl    $0x10,%eax
8010539a:	09 c1                	or     %eax,%ecx
8010539c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010539f:	c1 e0 08             	shl    $0x8,%eax
801053a2:	09 c8                	or     %ecx,%eax
801053a4:	0b 45 0c             	or     0xc(%ebp),%eax
801053a7:	52                   	push   %edx
801053a8:	50                   	push   %eax
801053a9:	ff 75 08             	push   0x8(%ebp)
801053ac:	e8 8f ff ff ff       	call   80105340 <stosl>
801053b1:	83 c4 0c             	add    $0xc,%esp
801053b4:	eb 12                	jmp    801053c8 <memset+0x62>
  } else
    stosb(dst, c, n);
801053b6:	8b 45 10             	mov    0x10(%ebp),%eax
801053b9:	50                   	push   %eax
801053ba:	ff 75 0c             	push   0xc(%ebp)
801053bd:	ff 75 08             	push   0x8(%ebp)
801053c0:	e8 55 ff ff ff       	call   8010531a <stosb>
801053c5:	83 c4 0c             	add    $0xc,%esp
  return dst;
801053c8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053cb:	c9                   	leave  
801053cc:	c3                   	ret    

801053cd <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801053cd:	55                   	push   %ebp
801053ce:	89 e5                	mov    %esp,%ebp
801053d0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801053d3:	8b 45 08             	mov    0x8(%ebp),%eax
801053d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801053d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801053dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801053df:	eb 30                	jmp    80105411 <memcmp+0x44>
    if(*s1 != *s2)
801053e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e4:	0f b6 10             	movzbl (%eax),%edx
801053e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053ea:	0f b6 00             	movzbl (%eax),%eax
801053ed:	38 c2                	cmp    %al,%dl
801053ef:	74 18                	je     80105409 <memcmp+0x3c>
      return *s1 - *s2;
801053f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f4:	0f b6 00             	movzbl (%eax),%eax
801053f7:	0f b6 d0             	movzbl %al,%edx
801053fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053fd:	0f b6 00             	movzbl (%eax),%eax
80105400:	0f b6 c8             	movzbl %al,%ecx
80105403:	89 d0                	mov    %edx,%eax
80105405:	29 c8                	sub    %ecx,%eax
80105407:	eb 1a                	jmp    80105423 <memcmp+0x56>
    s1++, s2++;
80105409:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010540d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105411:	8b 45 10             	mov    0x10(%ebp),%eax
80105414:	8d 50 ff             	lea    -0x1(%eax),%edx
80105417:	89 55 10             	mov    %edx,0x10(%ebp)
8010541a:	85 c0                	test   %eax,%eax
8010541c:	75 c3                	jne    801053e1 <memcmp+0x14>
  }

  return 0;
8010541e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105423:	c9                   	leave  
80105424:	c3                   	ret    

80105425 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105425:	55                   	push   %ebp
80105426:	89 e5                	mov    %esp,%ebp
80105428:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010542b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010542e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105431:	8b 45 08             	mov    0x8(%ebp),%eax
80105434:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105437:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010543a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010543d:	73 54                	jae    80105493 <memmove+0x6e>
8010543f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105442:	8b 45 10             	mov    0x10(%ebp),%eax
80105445:	01 d0                	add    %edx,%eax
80105447:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010544a:	73 47                	jae    80105493 <memmove+0x6e>
    s += n;
8010544c:	8b 45 10             	mov    0x10(%ebp),%eax
8010544f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105452:	8b 45 10             	mov    0x10(%ebp),%eax
80105455:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105458:	eb 13                	jmp    8010546d <memmove+0x48>
      *--d = *--s;
8010545a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010545e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105462:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105465:	0f b6 10             	movzbl (%eax),%edx
80105468:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010546b:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010546d:	8b 45 10             	mov    0x10(%ebp),%eax
80105470:	8d 50 ff             	lea    -0x1(%eax),%edx
80105473:	89 55 10             	mov    %edx,0x10(%ebp)
80105476:	85 c0                	test   %eax,%eax
80105478:	75 e0                	jne    8010545a <memmove+0x35>
  if(s < d && s + n > d){
8010547a:	eb 24                	jmp    801054a0 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
8010547c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010547f:	8d 42 01             	lea    0x1(%edx),%eax
80105482:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105485:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105488:	8d 48 01             	lea    0x1(%eax),%ecx
8010548b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010548e:	0f b6 12             	movzbl (%edx),%edx
80105491:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105493:	8b 45 10             	mov    0x10(%ebp),%eax
80105496:	8d 50 ff             	lea    -0x1(%eax),%edx
80105499:	89 55 10             	mov    %edx,0x10(%ebp)
8010549c:	85 c0                	test   %eax,%eax
8010549e:	75 dc                	jne    8010547c <memmove+0x57>

  return dst;
801054a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054a3:	c9                   	leave  
801054a4:	c3                   	ret    

801054a5 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801054a5:	55                   	push   %ebp
801054a6:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801054a8:	ff 75 10             	push   0x10(%ebp)
801054ab:	ff 75 0c             	push   0xc(%ebp)
801054ae:	ff 75 08             	push   0x8(%ebp)
801054b1:	e8 6f ff ff ff       	call   80105425 <memmove>
801054b6:	83 c4 0c             	add    $0xc,%esp
}
801054b9:	c9                   	leave  
801054ba:	c3                   	ret    

801054bb <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801054bb:	55                   	push   %ebp
801054bc:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801054be:	eb 0c                	jmp    801054cc <strncmp+0x11>
    n--, p++, q++;
801054c0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801054c8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801054cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054d0:	74 1a                	je     801054ec <strncmp+0x31>
801054d2:	8b 45 08             	mov    0x8(%ebp),%eax
801054d5:	0f b6 00             	movzbl (%eax),%eax
801054d8:	84 c0                	test   %al,%al
801054da:	74 10                	je     801054ec <strncmp+0x31>
801054dc:	8b 45 08             	mov    0x8(%ebp),%eax
801054df:	0f b6 10             	movzbl (%eax),%edx
801054e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801054e5:	0f b6 00             	movzbl (%eax),%eax
801054e8:	38 c2                	cmp    %al,%dl
801054ea:	74 d4                	je     801054c0 <strncmp+0x5>
  if(n == 0)
801054ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054f0:	75 07                	jne    801054f9 <strncmp+0x3e>
    return 0;
801054f2:	b8 00 00 00 00       	mov    $0x0,%eax
801054f7:	eb 16                	jmp    8010550f <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801054f9:	8b 45 08             	mov    0x8(%ebp),%eax
801054fc:	0f b6 00             	movzbl (%eax),%eax
801054ff:	0f b6 d0             	movzbl %al,%edx
80105502:	8b 45 0c             	mov    0xc(%ebp),%eax
80105505:	0f b6 00             	movzbl (%eax),%eax
80105508:	0f b6 c8             	movzbl %al,%ecx
8010550b:	89 d0                	mov    %edx,%eax
8010550d:	29 c8                	sub    %ecx,%eax
}
8010550f:	5d                   	pop    %ebp
80105510:	c3                   	ret    

80105511 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105511:	55                   	push   %ebp
80105512:	89 e5                	mov    %esp,%ebp
80105514:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105517:	8b 45 08             	mov    0x8(%ebp),%eax
8010551a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010551d:	90                   	nop
8010551e:	8b 45 10             	mov    0x10(%ebp),%eax
80105521:	8d 50 ff             	lea    -0x1(%eax),%edx
80105524:	89 55 10             	mov    %edx,0x10(%ebp)
80105527:	85 c0                	test   %eax,%eax
80105529:	7e 2c                	jle    80105557 <strncpy+0x46>
8010552b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010552e:	8d 42 01             	lea    0x1(%edx),%eax
80105531:	89 45 0c             	mov    %eax,0xc(%ebp)
80105534:	8b 45 08             	mov    0x8(%ebp),%eax
80105537:	8d 48 01             	lea    0x1(%eax),%ecx
8010553a:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010553d:	0f b6 12             	movzbl (%edx),%edx
80105540:	88 10                	mov    %dl,(%eax)
80105542:	0f b6 00             	movzbl (%eax),%eax
80105545:	84 c0                	test   %al,%al
80105547:	75 d5                	jne    8010551e <strncpy+0xd>
    ;
  while(n-- > 0)
80105549:	eb 0c                	jmp    80105557 <strncpy+0x46>
    *s++ = 0;
8010554b:	8b 45 08             	mov    0x8(%ebp),%eax
8010554e:	8d 50 01             	lea    0x1(%eax),%edx
80105551:	89 55 08             	mov    %edx,0x8(%ebp)
80105554:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105557:	8b 45 10             	mov    0x10(%ebp),%eax
8010555a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010555d:	89 55 10             	mov    %edx,0x10(%ebp)
80105560:	85 c0                	test   %eax,%eax
80105562:	7f e7                	jg     8010554b <strncpy+0x3a>
  return os;
80105564:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105567:	c9                   	leave  
80105568:	c3                   	ret    

80105569 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105569:	55                   	push   %ebp
8010556a:	89 e5                	mov    %esp,%ebp
8010556c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010556f:	8b 45 08             	mov    0x8(%ebp),%eax
80105572:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105575:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105579:	7f 05                	jg     80105580 <safestrcpy+0x17>
    return os;
8010557b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010557e:	eb 32                	jmp    801055b2 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105580:	90                   	nop
80105581:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105585:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105589:	7e 1e                	jle    801055a9 <safestrcpy+0x40>
8010558b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010558e:	8d 42 01             	lea    0x1(%edx),%eax
80105591:	89 45 0c             	mov    %eax,0xc(%ebp)
80105594:	8b 45 08             	mov    0x8(%ebp),%eax
80105597:	8d 48 01             	lea    0x1(%eax),%ecx
8010559a:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010559d:	0f b6 12             	movzbl (%edx),%edx
801055a0:	88 10                	mov    %dl,(%eax)
801055a2:	0f b6 00             	movzbl (%eax),%eax
801055a5:	84 c0                	test   %al,%al
801055a7:	75 d8                	jne    80105581 <safestrcpy+0x18>
    ;
  *s = 0;
801055a9:	8b 45 08             	mov    0x8(%ebp),%eax
801055ac:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801055af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055b2:	c9                   	leave  
801055b3:	c3                   	ret    

801055b4 <strlen>:

int
strlen(const char *s)
{
801055b4:	55                   	push   %ebp
801055b5:	89 e5                	mov    %esp,%ebp
801055b7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801055ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801055c1:	eb 04                	jmp    801055c7 <strlen+0x13>
801055c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055ca:	8b 45 08             	mov    0x8(%ebp),%eax
801055cd:	01 d0                	add    %edx,%eax
801055cf:	0f b6 00             	movzbl (%eax),%eax
801055d2:	84 c0                	test   %al,%al
801055d4:	75 ed                	jne    801055c3 <strlen+0xf>
    ;
  return n;
801055d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055d9:	c9                   	leave  
801055da:	c3                   	ret    

801055db <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801055db:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055df:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055e3:	55                   	push   %ebp
  pushl %ebx
801055e4:	53                   	push   %ebx
  pushl %esi
801055e5:	56                   	push   %esi
  pushl %edi
801055e6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055e7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055e9:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055eb:	5f                   	pop    %edi
  popl %esi
801055ec:	5e                   	pop    %esi
  popl %ebx
801055ed:	5b                   	pop    %ebx
  popl %ebp
801055ee:	5d                   	pop    %ebp
  ret
801055ef:	c3                   	ret    

801055f0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055f0:	55                   	push   %ebp
801055f1:	89 e5                	mov    %esp,%ebp
801055f3:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801055f6:	e8 47 e9 ff ff       	call   80103f42 <myproc>
801055fb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801055fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105601:	8b 00                	mov    (%eax),%eax
80105603:	39 45 08             	cmp    %eax,0x8(%ebp)
80105606:	73 0f                	jae    80105617 <fetchint+0x27>
80105608:	8b 45 08             	mov    0x8(%ebp),%eax
8010560b:	8d 50 04             	lea    0x4(%eax),%edx
8010560e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105611:	8b 00                	mov    (%eax),%eax
80105613:	39 c2                	cmp    %eax,%edx
80105615:	76 07                	jbe    8010561e <fetchint+0x2e>
    return -1;
80105617:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010561c:	eb 0f                	jmp    8010562d <fetchint+0x3d>
  *ip = *(int*)(addr);
8010561e:	8b 45 08             	mov    0x8(%ebp),%eax
80105621:	8b 10                	mov    (%eax),%edx
80105623:	8b 45 0c             	mov    0xc(%ebp),%eax
80105626:	89 10                	mov    %edx,(%eax)
  return 0;
80105628:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010562d:	c9                   	leave  
8010562e:	c3                   	ret    

8010562f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010562f:	55                   	push   %ebp
80105630:	89 e5                	mov    %esp,%ebp
80105632:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105635:	e8 08 e9 ff ff       	call   80103f42 <myproc>
8010563a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010563d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105640:	8b 00                	mov    (%eax),%eax
80105642:	39 45 08             	cmp    %eax,0x8(%ebp)
80105645:	72 07                	jb     8010564e <fetchstr+0x1f>
    return -1;
80105647:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010564c:	eb 41                	jmp    8010568f <fetchstr+0x60>
  *pp = (char*)addr;
8010564e:	8b 55 08             	mov    0x8(%ebp),%edx
80105651:	8b 45 0c             	mov    0xc(%ebp),%eax
80105654:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105659:	8b 00                	mov    (%eax),%eax
8010565b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010565e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105661:	8b 00                	mov    (%eax),%eax
80105663:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105666:	eb 1a                	jmp    80105682 <fetchstr+0x53>
    if(*s == 0)
80105668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566b:	0f b6 00             	movzbl (%eax),%eax
8010566e:	84 c0                	test   %al,%al
80105670:	75 0c                	jne    8010567e <fetchstr+0x4f>
      return s - *pp;
80105672:	8b 45 0c             	mov    0xc(%ebp),%eax
80105675:	8b 10                	mov    (%eax),%edx
80105677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567a:	29 d0                	sub    %edx,%eax
8010567c:	eb 11                	jmp    8010568f <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
8010567e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105685:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105688:	72 de                	jb     80105668 <fetchstr+0x39>
  }
  return -1;
8010568a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010568f:	c9                   	leave  
80105690:	c3                   	ret    

80105691 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105691:	55                   	push   %ebp
80105692:	89 e5                	mov    %esp,%ebp
80105694:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105697:	e8 a6 e8 ff ff       	call   80103f42 <myproc>
8010569c:	8b 40 18             	mov    0x18(%eax),%eax
8010569f:	8b 50 44             	mov    0x44(%eax),%edx
801056a2:	8b 45 08             	mov    0x8(%ebp),%eax
801056a5:	c1 e0 02             	shl    $0x2,%eax
801056a8:	01 d0                	add    %edx,%eax
801056aa:	83 c0 04             	add    $0x4,%eax
801056ad:	83 ec 08             	sub    $0x8,%esp
801056b0:	ff 75 0c             	push   0xc(%ebp)
801056b3:	50                   	push   %eax
801056b4:	e8 37 ff ff ff       	call   801055f0 <fetchint>
801056b9:	83 c4 10             	add    $0x10,%esp
}
801056bc:	c9                   	leave  
801056bd:	c3                   	ret    

801056be <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801056be:	55                   	push   %ebp
801056bf:	89 e5                	mov    %esp,%ebp
801056c1:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801056c4:	e8 79 e8 ff ff       	call   80103f42 <myproc>
801056c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801056cc:	83 ec 08             	sub    $0x8,%esp
801056cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056d2:	50                   	push   %eax
801056d3:	ff 75 08             	push   0x8(%ebp)
801056d6:	e8 b6 ff ff ff       	call   80105691 <argint>
801056db:	83 c4 10             	add    $0x10,%esp
801056de:	85 c0                	test   %eax,%eax
801056e0:	79 07                	jns    801056e9 <argptr+0x2b>
    return -1;
801056e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e7:	eb 3b                	jmp    80105724 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801056e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056ed:	78 1f                	js     8010570e <argptr+0x50>
801056ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f2:	8b 00                	mov    (%eax),%eax
801056f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056f7:	39 d0                	cmp    %edx,%eax
801056f9:	76 13                	jbe    8010570e <argptr+0x50>
801056fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056fe:	89 c2                	mov    %eax,%edx
80105700:	8b 45 10             	mov    0x10(%ebp),%eax
80105703:	01 c2                	add    %eax,%edx
80105705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105708:	8b 00                	mov    (%eax),%eax
8010570a:	39 c2                	cmp    %eax,%edx
8010570c:	76 07                	jbe    80105715 <argptr+0x57>
    return -1;
8010570e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105713:	eb 0f                	jmp    80105724 <argptr+0x66>
  *pp = (char*)i;
80105715:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105718:	89 c2                	mov    %eax,%edx
8010571a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010571d:	89 10                	mov    %edx,(%eax)
  return 0;
8010571f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105724:	c9                   	leave  
80105725:	c3                   	ret    

80105726 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105726:	55                   	push   %ebp
80105727:	89 e5                	mov    %esp,%ebp
80105729:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010572c:	83 ec 08             	sub    $0x8,%esp
8010572f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105732:	50                   	push   %eax
80105733:	ff 75 08             	push   0x8(%ebp)
80105736:	e8 56 ff ff ff       	call   80105691 <argint>
8010573b:	83 c4 10             	add    $0x10,%esp
8010573e:	85 c0                	test   %eax,%eax
80105740:	79 07                	jns    80105749 <argstr+0x23>
    return -1;
80105742:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105747:	eb 12                	jmp    8010575b <argstr+0x35>
  return fetchstr(addr, pp);
80105749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574c:	83 ec 08             	sub    $0x8,%esp
8010574f:	ff 75 0c             	push   0xc(%ebp)
80105752:	50                   	push   %eax
80105753:	e8 d7 fe ff ff       	call   8010562f <fetchstr>
80105758:	83 c4 10             	add    $0x10,%esp
}
8010575b:	c9                   	leave  
8010575c:	c3                   	ret    

8010575d <syscall>:
[SYS_yield] = sys_yield,
};

void
syscall(void)
{
8010575d:	55                   	push   %ebp
8010575e:	89 e5                	mov    %esp,%ebp
80105760:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105763:	e8 da e7 ff ff       	call   80103f42 <myproc>
80105768:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010576b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576e:	8b 40 18             	mov    0x18(%eax),%eax
80105771:	8b 40 1c             	mov    0x1c(%eax),%eax
80105774:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105777:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010577b:	7e 2f                	jle    801057ac <syscall+0x4f>
8010577d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105780:	83 f8 18             	cmp    $0x18,%eax
80105783:	77 27                	ja     801057ac <syscall+0x4f>
80105785:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105788:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010578f:	85 c0                	test   %eax,%eax
80105791:	74 19                	je     801057ac <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105796:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010579d:	ff d0                	call   *%eax
8010579f:	89 c2                	mov    %eax,%edx
801057a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a4:	8b 40 18             	mov    0x18(%eax),%eax
801057a7:	89 50 1c             	mov    %edx,0x1c(%eax)
801057aa:	eb 2c                	jmp    801057d8 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801057ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057af:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801057b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b5:	8b 40 10             	mov    0x10(%eax),%eax
801057b8:	ff 75 f0             	push   -0x10(%ebp)
801057bb:	52                   	push   %edx
801057bc:	50                   	push   %eax
801057bd:	68 dc ae 10 80       	push   $0x8010aedc
801057c2:	e8 2d ac ff ff       	call   801003f4 <cprintf>
801057c7:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801057ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057cd:	8b 40 18             	mov    0x18(%eax),%eax
801057d0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057d7:	90                   	nop
801057d8:	90                   	nop
801057d9:	c9                   	leave  
801057da:	c3                   	ret    

801057db <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057db:	55                   	push   %ebp
801057dc:	89 e5                	mov    %esp,%ebp
801057de:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057e1:	83 ec 08             	sub    $0x8,%esp
801057e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057e7:	50                   	push   %eax
801057e8:	ff 75 08             	push   0x8(%ebp)
801057eb:	e8 a1 fe ff ff       	call   80105691 <argint>
801057f0:	83 c4 10             	add    $0x10,%esp
801057f3:	85 c0                	test   %eax,%eax
801057f5:	79 07                	jns    801057fe <argfd+0x23>
    return -1;
801057f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057fc:	eb 4f                	jmp    8010584d <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801057fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105801:	85 c0                	test   %eax,%eax
80105803:	78 20                	js     80105825 <argfd+0x4a>
80105805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105808:	83 f8 0f             	cmp    $0xf,%eax
8010580b:	7f 18                	jg     80105825 <argfd+0x4a>
8010580d:	e8 30 e7 ff ff       	call   80103f42 <myproc>
80105812:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105815:	83 c2 08             	add    $0x8,%edx
80105818:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010581c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010581f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105823:	75 07                	jne    8010582c <argfd+0x51>
    return -1;
80105825:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582a:	eb 21                	jmp    8010584d <argfd+0x72>
  if(pfd)
8010582c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105830:	74 08                	je     8010583a <argfd+0x5f>
    *pfd = fd;
80105832:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105835:	8b 45 0c             	mov    0xc(%ebp),%eax
80105838:	89 10                	mov    %edx,(%eax)
  if(pf)
8010583a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010583e:	74 08                	je     80105848 <argfd+0x6d>
    *pf = f;
80105840:	8b 45 10             	mov    0x10(%ebp),%eax
80105843:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105846:	89 10                	mov    %edx,(%eax)
  return 0;
80105848:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010584d:	c9                   	leave  
8010584e:	c3                   	ret    

8010584f <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010584f:	55                   	push   %ebp
80105850:	89 e5                	mov    %esp,%ebp
80105852:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105855:	e8 e8 e6 ff ff       	call   80103f42 <myproc>
8010585a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010585d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105864:	eb 2a                	jmp    80105890 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105869:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010586c:	83 c2 08             	add    $0x8,%edx
8010586f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105873:	85 c0                	test   %eax,%eax
80105875:	75 15                	jne    8010588c <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010587d:	8d 4a 08             	lea    0x8(%edx),%ecx
80105880:	8b 55 08             	mov    0x8(%ebp),%edx
80105883:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588a:	eb 0f                	jmp    8010589b <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010588c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105890:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105894:	7e d0                	jle    80105866 <fdalloc+0x17>
    }
  }
  return -1;
80105896:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010589b:	c9                   	leave  
8010589c:	c3                   	ret    

8010589d <sys_dup>:

int
sys_dup(void)
{
8010589d:	55                   	push   %ebp
8010589e:	89 e5                	mov    %esp,%ebp
801058a0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801058a3:	83 ec 04             	sub    $0x4,%esp
801058a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058a9:	50                   	push   %eax
801058aa:	6a 00                	push   $0x0
801058ac:	6a 00                	push   $0x0
801058ae:	e8 28 ff ff ff       	call   801057db <argfd>
801058b3:	83 c4 10             	add    $0x10,%esp
801058b6:	85 c0                	test   %eax,%eax
801058b8:	79 07                	jns    801058c1 <sys_dup+0x24>
    return -1;
801058ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bf:	eb 31                	jmp    801058f2 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801058c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c4:	83 ec 0c             	sub    $0xc,%esp
801058c7:	50                   	push   %eax
801058c8:	e8 82 ff ff ff       	call   8010584f <fdalloc>
801058cd:	83 c4 10             	add    $0x10,%esp
801058d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058d7:	79 07                	jns    801058e0 <sys_dup+0x43>
    return -1;
801058d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058de:	eb 12                	jmp    801058f2 <sys_dup+0x55>
  filedup(f);
801058e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e3:	83 ec 0c             	sub    $0xc,%esp
801058e6:	50                   	push   %eax
801058e7:	e8 5e b7 ff ff       	call   8010104a <filedup>
801058ec:	83 c4 10             	add    $0x10,%esp
  return fd;
801058ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058f2:	c9                   	leave  
801058f3:	c3                   	ret    

801058f4 <sys_read>:

int
sys_read(void)
{
801058f4:	55                   	push   %ebp
801058f5:	89 e5                	mov    %esp,%ebp
801058f7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058fa:	83 ec 04             	sub    $0x4,%esp
801058fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105900:	50                   	push   %eax
80105901:	6a 00                	push   $0x0
80105903:	6a 00                	push   $0x0
80105905:	e8 d1 fe ff ff       	call   801057db <argfd>
8010590a:	83 c4 10             	add    $0x10,%esp
8010590d:	85 c0                	test   %eax,%eax
8010590f:	78 2e                	js     8010593f <sys_read+0x4b>
80105911:	83 ec 08             	sub    $0x8,%esp
80105914:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105917:	50                   	push   %eax
80105918:	6a 02                	push   $0x2
8010591a:	e8 72 fd ff ff       	call   80105691 <argint>
8010591f:	83 c4 10             	add    $0x10,%esp
80105922:	85 c0                	test   %eax,%eax
80105924:	78 19                	js     8010593f <sys_read+0x4b>
80105926:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105929:	83 ec 04             	sub    $0x4,%esp
8010592c:	50                   	push   %eax
8010592d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105930:	50                   	push   %eax
80105931:	6a 01                	push   $0x1
80105933:	e8 86 fd ff ff       	call   801056be <argptr>
80105938:	83 c4 10             	add    $0x10,%esp
8010593b:	85 c0                	test   %eax,%eax
8010593d:	79 07                	jns    80105946 <sys_read+0x52>
    return -1;
8010593f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105944:	eb 17                	jmp    8010595d <sys_read+0x69>
  return fileread(f, p, n);
80105946:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105949:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010594c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594f:	83 ec 04             	sub    $0x4,%esp
80105952:	51                   	push   %ecx
80105953:	52                   	push   %edx
80105954:	50                   	push   %eax
80105955:	e8 80 b8 ff ff       	call   801011da <fileread>
8010595a:	83 c4 10             	add    $0x10,%esp
}
8010595d:	c9                   	leave  
8010595e:	c3                   	ret    

8010595f <sys_write>:

int
sys_write(void)
{
8010595f:	55                   	push   %ebp
80105960:	89 e5                	mov    %esp,%ebp
80105962:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105965:	83 ec 04             	sub    $0x4,%esp
80105968:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010596b:	50                   	push   %eax
8010596c:	6a 00                	push   $0x0
8010596e:	6a 00                	push   $0x0
80105970:	e8 66 fe ff ff       	call   801057db <argfd>
80105975:	83 c4 10             	add    $0x10,%esp
80105978:	85 c0                	test   %eax,%eax
8010597a:	78 2e                	js     801059aa <sys_write+0x4b>
8010597c:	83 ec 08             	sub    $0x8,%esp
8010597f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105982:	50                   	push   %eax
80105983:	6a 02                	push   $0x2
80105985:	e8 07 fd ff ff       	call   80105691 <argint>
8010598a:	83 c4 10             	add    $0x10,%esp
8010598d:	85 c0                	test   %eax,%eax
8010598f:	78 19                	js     801059aa <sys_write+0x4b>
80105991:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105994:	83 ec 04             	sub    $0x4,%esp
80105997:	50                   	push   %eax
80105998:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010599b:	50                   	push   %eax
8010599c:	6a 01                	push   $0x1
8010599e:	e8 1b fd ff ff       	call   801056be <argptr>
801059a3:	83 c4 10             	add    $0x10,%esp
801059a6:	85 c0                	test   %eax,%eax
801059a8:	79 07                	jns    801059b1 <sys_write+0x52>
    return -1;
801059aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059af:	eb 17                	jmp    801059c8 <sys_write+0x69>
  return filewrite(f, p, n);
801059b1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059b4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ba:	83 ec 04             	sub    $0x4,%esp
801059bd:	51                   	push   %ecx
801059be:	52                   	push   %edx
801059bf:	50                   	push   %eax
801059c0:	e8 cd b8 ff ff       	call   80101292 <filewrite>
801059c5:	83 c4 10             	add    $0x10,%esp
}
801059c8:	c9                   	leave  
801059c9:	c3                   	ret    

801059ca <sys_close>:

int
sys_close(void)
{
801059ca:	55                   	push   %ebp
801059cb:	89 e5                	mov    %esp,%ebp
801059cd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801059d0:	83 ec 04             	sub    $0x4,%esp
801059d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059d6:	50                   	push   %eax
801059d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059da:	50                   	push   %eax
801059db:	6a 00                	push   $0x0
801059dd:	e8 f9 fd ff ff       	call   801057db <argfd>
801059e2:	83 c4 10             	add    $0x10,%esp
801059e5:	85 c0                	test   %eax,%eax
801059e7:	79 07                	jns    801059f0 <sys_close+0x26>
    return -1;
801059e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ee:	eb 27                	jmp    80105a17 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801059f0:	e8 4d e5 ff ff       	call   80103f42 <myproc>
801059f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059f8:	83 c2 08             	add    $0x8,%edx
801059fb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a02:	00 
  fileclose(f);
80105a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a06:	83 ec 0c             	sub    $0xc,%esp
80105a09:	50                   	push   %eax
80105a0a:	e8 8c b6 ff ff       	call   8010109b <fileclose>
80105a0f:	83 c4 10             	add    $0x10,%esp
  return 0;
80105a12:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a17:	c9                   	leave  
80105a18:	c3                   	ret    

80105a19 <sys_fstat>:

int
sys_fstat(void)
{
80105a19:	55                   	push   %ebp
80105a1a:	89 e5                	mov    %esp,%ebp
80105a1c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a1f:	83 ec 04             	sub    $0x4,%esp
80105a22:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a25:	50                   	push   %eax
80105a26:	6a 00                	push   $0x0
80105a28:	6a 00                	push   $0x0
80105a2a:	e8 ac fd ff ff       	call   801057db <argfd>
80105a2f:	83 c4 10             	add    $0x10,%esp
80105a32:	85 c0                	test   %eax,%eax
80105a34:	78 17                	js     80105a4d <sys_fstat+0x34>
80105a36:	83 ec 04             	sub    $0x4,%esp
80105a39:	6a 14                	push   $0x14
80105a3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a3e:	50                   	push   %eax
80105a3f:	6a 01                	push   $0x1
80105a41:	e8 78 fc ff ff       	call   801056be <argptr>
80105a46:	83 c4 10             	add    $0x10,%esp
80105a49:	85 c0                	test   %eax,%eax
80105a4b:	79 07                	jns    80105a54 <sys_fstat+0x3b>
    return -1;
80105a4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a52:	eb 13                	jmp    80105a67 <sys_fstat+0x4e>
  return filestat(f, st);
80105a54:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5a:	83 ec 08             	sub    $0x8,%esp
80105a5d:	52                   	push   %edx
80105a5e:	50                   	push   %eax
80105a5f:	e8 1f b7 ff ff       	call   80101183 <filestat>
80105a64:	83 c4 10             	add    $0x10,%esp
}
80105a67:	c9                   	leave  
80105a68:	c3                   	ret    

80105a69 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105a69:	55                   	push   %ebp
80105a6a:	89 e5                	mov    %esp,%ebp
80105a6c:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a6f:	83 ec 08             	sub    $0x8,%esp
80105a72:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a75:	50                   	push   %eax
80105a76:	6a 00                	push   $0x0
80105a78:	e8 a9 fc ff ff       	call   80105726 <argstr>
80105a7d:	83 c4 10             	add    $0x10,%esp
80105a80:	85 c0                	test   %eax,%eax
80105a82:	78 15                	js     80105a99 <sys_link+0x30>
80105a84:	83 ec 08             	sub    $0x8,%esp
80105a87:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a8a:	50                   	push   %eax
80105a8b:	6a 01                	push   $0x1
80105a8d:	e8 94 fc ff ff       	call   80105726 <argstr>
80105a92:	83 c4 10             	add    $0x10,%esp
80105a95:	85 c0                	test   %eax,%eax
80105a97:	79 0a                	jns    80105aa3 <sys_link+0x3a>
    return -1;
80105a99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9e:	e9 68 01 00 00       	jmp    80105c0b <sys_link+0x1a2>

  begin_op();
80105aa3:	e8 78 da ff ff       	call   80103520 <begin_op>
  if((ip = namei(old)) == 0){
80105aa8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105aab:	83 ec 0c             	sub    $0xc,%esp
80105aae:	50                   	push   %eax
80105aaf:	e8 69 ca ff ff       	call   8010251d <namei>
80105ab4:	83 c4 10             	add    $0x10,%esp
80105ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105abe:	75 0f                	jne    80105acf <sys_link+0x66>
    end_op();
80105ac0:	e8 e7 da ff ff       	call   801035ac <end_op>
    return -1;
80105ac5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aca:	e9 3c 01 00 00       	jmp    80105c0b <sys_link+0x1a2>
  }

  ilock(ip);
80105acf:	83 ec 0c             	sub    $0xc,%esp
80105ad2:	ff 75 f4             	push   -0xc(%ebp)
80105ad5:	e8 10 bf ff ff       	call   801019ea <ilock>
80105ada:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ae4:	66 83 f8 01          	cmp    $0x1,%ax
80105ae8:	75 1d                	jne    80105b07 <sys_link+0x9e>
    iunlockput(ip);
80105aea:	83 ec 0c             	sub    $0xc,%esp
80105aed:	ff 75 f4             	push   -0xc(%ebp)
80105af0:	e8 26 c1 ff ff       	call   80101c1b <iunlockput>
80105af5:	83 c4 10             	add    $0x10,%esp
    end_op();
80105af8:	e8 af da ff ff       	call   801035ac <end_op>
    return -1;
80105afd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b02:	e9 04 01 00 00       	jmp    80105c0b <sys_link+0x1a2>
  }

  ip->nlink++;
80105b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b0e:	83 c0 01             	add    $0x1,%eax
80105b11:	89 c2                	mov    %eax,%edx
80105b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b16:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b1a:	83 ec 0c             	sub    $0xc,%esp
80105b1d:	ff 75 f4             	push   -0xc(%ebp)
80105b20:	e8 e8 bc ff ff       	call   8010180d <iupdate>
80105b25:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105b28:	83 ec 0c             	sub    $0xc,%esp
80105b2b:	ff 75 f4             	push   -0xc(%ebp)
80105b2e:	e8 ca bf ff ff       	call   80101afd <iunlock>
80105b33:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105b36:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b39:	83 ec 08             	sub    $0x8,%esp
80105b3c:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b3f:	52                   	push   %edx
80105b40:	50                   	push   %eax
80105b41:	e8 f3 c9 ff ff       	call   80102539 <nameiparent>
80105b46:	83 c4 10             	add    $0x10,%esp
80105b49:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b50:	74 71                	je     80105bc3 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105b52:	83 ec 0c             	sub    $0xc,%esp
80105b55:	ff 75 f0             	push   -0x10(%ebp)
80105b58:	e8 8d be ff ff       	call   801019ea <ilock>
80105b5d:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b63:	8b 10                	mov    (%eax),%edx
80105b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b68:	8b 00                	mov    (%eax),%eax
80105b6a:	39 c2                	cmp    %eax,%edx
80105b6c:	75 1d                	jne    80105b8b <sys_link+0x122>
80105b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b71:	8b 40 04             	mov    0x4(%eax),%eax
80105b74:	83 ec 04             	sub    $0x4,%esp
80105b77:	50                   	push   %eax
80105b78:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b7b:	50                   	push   %eax
80105b7c:	ff 75 f0             	push   -0x10(%ebp)
80105b7f:	e8 02 c7 ff ff       	call   80102286 <dirlink>
80105b84:	83 c4 10             	add    $0x10,%esp
80105b87:	85 c0                	test   %eax,%eax
80105b89:	79 10                	jns    80105b9b <sys_link+0x132>
    iunlockput(dp);
80105b8b:	83 ec 0c             	sub    $0xc,%esp
80105b8e:	ff 75 f0             	push   -0x10(%ebp)
80105b91:	e8 85 c0 ff ff       	call   80101c1b <iunlockput>
80105b96:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b99:	eb 29                	jmp    80105bc4 <sys_link+0x15b>
  }
  iunlockput(dp);
80105b9b:	83 ec 0c             	sub    $0xc,%esp
80105b9e:	ff 75 f0             	push   -0x10(%ebp)
80105ba1:	e8 75 c0 ff ff       	call   80101c1b <iunlockput>
80105ba6:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105ba9:	83 ec 0c             	sub    $0xc,%esp
80105bac:	ff 75 f4             	push   -0xc(%ebp)
80105baf:	e8 97 bf ff ff       	call   80101b4b <iput>
80105bb4:	83 c4 10             	add    $0x10,%esp

  end_op();
80105bb7:	e8 f0 d9 ff ff       	call   801035ac <end_op>

  return 0;
80105bbc:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc1:	eb 48                	jmp    80105c0b <sys_link+0x1a2>
    goto bad;
80105bc3:	90                   	nop

bad:
  ilock(ip);
80105bc4:	83 ec 0c             	sub    $0xc,%esp
80105bc7:	ff 75 f4             	push   -0xc(%ebp)
80105bca:	e8 1b be ff ff       	call   801019ea <ilock>
80105bcf:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105bd9:	83 e8 01             	sub    $0x1,%eax
80105bdc:	89 c2                	mov    %eax,%edx
80105bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be1:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105be5:	83 ec 0c             	sub    $0xc,%esp
80105be8:	ff 75 f4             	push   -0xc(%ebp)
80105beb:	e8 1d bc ff ff       	call   8010180d <iupdate>
80105bf0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105bf3:	83 ec 0c             	sub    $0xc,%esp
80105bf6:	ff 75 f4             	push   -0xc(%ebp)
80105bf9:	e8 1d c0 ff ff       	call   80101c1b <iunlockput>
80105bfe:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c01:	e8 a6 d9 ff ff       	call   801035ac <end_op>
  return -1;
80105c06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c0b:	c9                   	leave  
80105c0c:	c3                   	ret    

80105c0d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c0d:	55                   	push   %ebp
80105c0e:	89 e5                	mov    %esp,%ebp
80105c10:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c13:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c1a:	eb 40                	jmp    80105c5c <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1f:	6a 10                	push   $0x10
80105c21:	50                   	push   %eax
80105c22:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c25:	50                   	push   %eax
80105c26:	ff 75 08             	push   0x8(%ebp)
80105c29:	e8 a8 c2 ff ff       	call   80101ed6 <readi>
80105c2e:	83 c4 10             	add    $0x10,%esp
80105c31:	83 f8 10             	cmp    $0x10,%eax
80105c34:	74 0d                	je     80105c43 <isdirempty+0x36>
      panic("isdirempty: readi");
80105c36:	83 ec 0c             	sub    $0xc,%esp
80105c39:	68 f8 ae 10 80       	push   $0x8010aef8
80105c3e:	e8 66 a9 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105c43:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c47:	66 85 c0             	test   %ax,%ax
80105c4a:	74 07                	je     80105c53 <isdirempty+0x46>
      return 0;
80105c4c:	b8 00 00 00 00       	mov    $0x0,%eax
80105c51:	eb 1b                	jmp    80105c6e <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c56:	83 c0 10             	add    $0x10,%eax
80105c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c5f:	8b 50 58             	mov    0x58(%eax),%edx
80105c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c65:	39 c2                	cmp    %eax,%edx
80105c67:	77 b3                	ja     80105c1c <isdirempty+0xf>
  }
  return 1;
80105c69:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c6e:	c9                   	leave  
80105c6f:	c3                   	ret    

80105c70 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c70:	55                   	push   %ebp
80105c71:	89 e5                	mov    %esp,%ebp
80105c73:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c76:	83 ec 08             	sub    $0x8,%esp
80105c79:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c7c:	50                   	push   %eax
80105c7d:	6a 00                	push   $0x0
80105c7f:	e8 a2 fa ff ff       	call   80105726 <argstr>
80105c84:	83 c4 10             	add    $0x10,%esp
80105c87:	85 c0                	test   %eax,%eax
80105c89:	79 0a                	jns    80105c95 <sys_unlink+0x25>
    return -1;
80105c8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c90:	e9 bf 01 00 00       	jmp    80105e54 <sys_unlink+0x1e4>

  begin_op();
80105c95:	e8 86 d8 ff ff       	call   80103520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c9a:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c9d:	83 ec 08             	sub    $0x8,%esp
80105ca0:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105ca3:	52                   	push   %edx
80105ca4:	50                   	push   %eax
80105ca5:	e8 8f c8 ff ff       	call   80102539 <nameiparent>
80105caa:	83 c4 10             	add    $0x10,%esp
80105cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cb4:	75 0f                	jne    80105cc5 <sys_unlink+0x55>
    end_op();
80105cb6:	e8 f1 d8 ff ff       	call   801035ac <end_op>
    return -1;
80105cbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc0:	e9 8f 01 00 00       	jmp    80105e54 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105cc5:	83 ec 0c             	sub    $0xc,%esp
80105cc8:	ff 75 f4             	push   -0xc(%ebp)
80105ccb:	e8 1a bd ff ff       	call   801019ea <ilock>
80105cd0:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105cd3:	83 ec 08             	sub    $0x8,%esp
80105cd6:	68 0a af 10 80       	push   $0x8010af0a
80105cdb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cde:	50                   	push   %eax
80105cdf:	e8 cd c4 ff ff       	call   801021b1 <namecmp>
80105ce4:	83 c4 10             	add    $0x10,%esp
80105ce7:	85 c0                	test   %eax,%eax
80105ce9:	0f 84 49 01 00 00    	je     80105e38 <sys_unlink+0x1c8>
80105cef:	83 ec 08             	sub    $0x8,%esp
80105cf2:	68 0c af 10 80       	push   $0x8010af0c
80105cf7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cfa:	50                   	push   %eax
80105cfb:	e8 b1 c4 ff ff       	call   801021b1 <namecmp>
80105d00:	83 c4 10             	add    $0x10,%esp
80105d03:	85 c0                	test   %eax,%eax
80105d05:	0f 84 2d 01 00 00    	je     80105e38 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d0b:	83 ec 04             	sub    $0x4,%esp
80105d0e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d11:	50                   	push   %eax
80105d12:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d15:	50                   	push   %eax
80105d16:	ff 75 f4             	push   -0xc(%ebp)
80105d19:	e8 ae c4 ff ff       	call   801021cc <dirlookup>
80105d1e:	83 c4 10             	add    $0x10,%esp
80105d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d28:	0f 84 0d 01 00 00    	je     80105e3b <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105d2e:	83 ec 0c             	sub    $0xc,%esp
80105d31:	ff 75 f0             	push   -0x10(%ebp)
80105d34:	e8 b1 bc ff ff       	call   801019ea <ilock>
80105d39:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d43:	66 85 c0             	test   %ax,%ax
80105d46:	7f 0d                	jg     80105d55 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105d48:	83 ec 0c             	sub    $0xc,%esp
80105d4b:	68 0f af 10 80       	push   $0x8010af0f
80105d50:	e8 54 a8 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d58:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d5c:	66 83 f8 01          	cmp    $0x1,%ax
80105d60:	75 25                	jne    80105d87 <sys_unlink+0x117>
80105d62:	83 ec 0c             	sub    $0xc,%esp
80105d65:	ff 75 f0             	push   -0x10(%ebp)
80105d68:	e8 a0 fe ff ff       	call   80105c0d <isdirempty>
80105d6d:	83 c4 10             	add    $0x10,%esp
80105d70:	85 c0                	test   %eax,%eax
80105d72:	75 13                	jne    80105d87 <sys_unlink+0x117>
    iunlockput(ip);
80105d74:	83 ec 0c             	sub    $0xc,%esp
80105d77:	ff 75 f0             	push   -0x10(%ebp)
80105d7a:	e8 9c be ff ff       	call   80101c1b <iunlockput>
80105d7f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d82:	e9 b5 00 00 00       	jmp    80105e3c <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105d87:	83 ec 04             	sub    $0x4,%esp
80105d8a:	6a 10                	push   $0x10
80105d8c:	6a 00                	push   $0x0
80105d8e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d91:	50                   	push   %eax
80105d92:	e8 cf f5 ff ff       	call   80105366 <memset>
80105d97:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d9a:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d9d:	6a 10                	push   $0x10
80105d9f:	50                   	push   %eax
80105da0:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105da3:	50                   	push   %eax
80105da4:	ff 75 f4             	push   -0xc(%ebp)
80105da7:	e8 7f c2 ff ff       	call   8010202b <writei>
80105dac:	83 c4 10             	add    $0x10,%esp
80105daf:	83 f8 10             	cmp    $0x10,%eax
80105db2:	74 0d                	je     80105dc1 <sys_unlink+0x151>
    panic("unlink: writei");
80105db4:	83 ec 0c             	sub    $0xc,%esp
80105db7:	68 21 af 10 80       	push   $0x8010af21
80105dbc:	e8 e8 a7 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105dc8:	66 83 f8 01          	cmp    $0x1,%ax
80105dcc:	75 21                	jne    80105def <sys_unlink+0x17f>
    dp->nlink--;
80105dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105dd5:	83 e8 01             	sub    $0x1,%eax
80105dd8:	89 c2                	mov    %eax,%edx
80105dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddd:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105de1:	83 ec 0c             	sub    $0xc,%esp
80105de4:	ff 75 f4             	push   -0xc(%ebp)
80105de7:	e8 21 ba ff ff       	call   8010180d <iupdate>
80105dec:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105def:	83 ec 0c             	sub    $0xc,%esp
80105df2:	ff 75 f4             	push   -0xc(%ebp)
80105df5:	e8 21 be ff ff       	call   80101c1b <iunlockput>
80105dfa:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e00:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e04:	83 e8 01             	sub    $0x1,%eax
80105e07:	89 c2                	mov    %eax,%edx
80105e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e10:	83 ec 0c             	sub    $0xc,%esp
80105e13:	ff 75 f0             	push   -0x10(%ebp)
80105e16:	e8 f2 b9 ff ff       	call   8010180d <iupdate>
80105e1b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e1e:	83 ec 0c             	sub    $0xc,%esp
80105e21:	ff 75 f0             	push   -0x10(%ebp)
80105e24:	e8 f2 bd ff ff       	call   80101c1b <iunlockput>
80105e29:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e2c:	e8 7b d7 ff ff       	call   801035ac <end_op>

  return 0;
80105e31:	b8 00 00 00 00       	mov    $0x0,%eax
80105e36:	eb 1c                	jmp    80105e54 <sys_unlink+0x1e4>
    goto bad;
80105e38:	90                   	nop
80105e39:	eb 01                	jmp    80105e3c <sys_unlink+0x1cc>
    goto bad;
80105e3b:	90                   	nop

bad:
  iunlockput(dp);
80105e3c:	83 ec 0c             	sub    $0xc,%esp
80105e3f:	ff 75 f4             	push   -0xc(%ebp)
80105e42:	e8 d4 bd ff ff       	call   80101c1b <iunlockput>
80105e47:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e4a:	e8 5d d7 ff ff       	call   801035ac <end_op>
  return -1;
80105e4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e54:	c9                   	leave  
80105e55:	c3                   	ret    

80105e56 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e56:	55                   	push   %ebp
80105e57:	89 e5                	mov    %esp,%ebp
80105e59:	83 ec 38             	sub    $0x38,%esp
80105e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e5f:	8b 55 10             	mov    0x10(%ebp),%edx
80105e62:	8b 45 14             	mov    0x14(%ebp),%eax
80105e65:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e69:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e6d:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e71:	83 ec 08             	sub    $0x8,%esp
80105e74:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e77:	50                   	push   %eax
80105e78:	ff 75 08             	push   0x8(%ebp)
80105e7b:	e8 b9 c6 ff ff       	call   80102539 <nameiparent>
80105e80:	83 c4 10             	add    $0x10,%esp
80105e83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e8a:	75 0a                	jne    80105e96 <create+0x40>
    return 0;
80105e8c:	b8 00 00 00 00       	mov    $0x0,%eax
80105e91:	e9 90 01 00 00       	jmp    80106026 <create+0x1d0>
  ilock(dp);
80105e96:	83 ec 0c             	sub    $0xc,%esp
80105e99:	ff 75 f4             	push   -0xc(%ebp)
80105e9c:	e8 49 bb ff ff       	call   801019ea <ilock>
80105ea1:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ea4:	83 ec 04             	sub    $0x4,%esp
80105ea7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105eaa:	50                   	push   %eax
80105eab:	8d 45 de             	lea    -0x22(%ebp),%eax
80105eae:	50                   	push   %eax
80105eaf:	ff 75 f4             	push   -0xc(%ebp)
80105eb2:	e8 15 c3 ff ff       	call   801021cc <dirlookup>
80105eb7:	83 c4 10             	add    $0x10,%esp
80105eba:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ebd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ec1:	74 50                	je     80105f13 <create+0xbd>
    iunlockput(dp);
80105ec3:	83 ec 0c             	sub    $0xc,%esp
80105ec6:	ff 75 f4             	push   -0xc(%ebp)
80105ec9:	e8 4d bd ff ff       	call   80101c1b <iunlockput>
80105ece:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105ed1:	83 ec 0c             	sub    $0xc,%esp
80105ed4:	ff 75 f0             	push   -0x10(%ebp)
80105ed7:	e8 0e bb ff ff       	call   801019ea <ilock>
80105edc:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105edf:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ee4:	75 15                	jne    80105efb <create+0xa5>
80105ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105eed:	66 83 f8 02          	cmp    $0x2,%ax
80105ef1:	75 08                	jne    80105efb <create+0xa5>
      return ip;
80105ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef6:	e9 2b 01 00 00       	jmp    80106026 <create+0x1d0>
    iunlockput(ip);
80105efb:	83 ec 0c             	sub    $0xc,%esp
80105efe:	ff 75 f0             	push   -0x10(%ebp)
80105f01:	e8 15 bd ff ff       	call   80101c1b <iunlockput>
80105f06:	83 c4 10             	add    $0x10,%esp
    return 0;
80105f09:	b8 00 00 00 00       	mov    $0x0,%eax
80105f0e:	e9 13 01 00 00       	jmp    80106026 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f13:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1a:	8b 00                	mov    (%eax),%eax
80105f1c:	83 ec 08             	sub    $0x8,%esp
80105f1f:	52                   	push   %edx
80105f20:	50                   	push   %eax
80105f21:	e8 10 b8 ff ff       	call   80101736 <ialloc>
80105f26:	83 c4 10             	add    $0x10,%esp
80105f29:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f30:	75 0d                	jne    80105f3f <create+0xe9>
    panic("create: ialloc");
80105f32:	83 ec 0c             	sub    $0xc,%esp
80105f35:	68 30 af 10 80       	push   $0x8010af30
80105f3a:	e8 6a a6 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105f3f:	83 ec 0c             	sub    $0xc,%esp
80105f42:	ff 75 f0             	push   -0x10(%ebp)
80105f45:	e8 a0 ba ff ff       	call   801019ea <ilock>
80105f4a:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f50:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f54:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105f58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5b:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f5f:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f66:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105f6c:	83 ec 0c             	sub    $0xc,%esp
80105f6f:	ff 75 f0             	push   -0x10(%ebp)
80105f72:	e8 96 b8 ff ff       	call   8010180d <iupdate>
80105f77:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105f7a:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f7f:	75 6a                	jne    80105feb <create+0x195>
    dp->nlink++;  // for ".."
80105f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f84:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f88:	83 c0 01             	add    $0x1,%eax
80105f8b:	89 c2                	mov    %eax,%edx
80105f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f90:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105f94:	83 ec 0c             	sub    $0xc,%esp
80105f97:	ff 75 f4             	push   -0xc(%ebp)
80105f9a:	e8 6e b8 ff ff       	call   8010180d <iupdate>
80105f9f:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa5:	8b 40 04             	mov    0x4(%eax),%eax
80105fa8:	83 ec 04             	sub    $0x4,%esp
80105fab:	50                   	push   %eax
80105fac:	68 0a af 10 80       	push   $0x8010af0a
80105fb1:	ff 75 f0             	push   -0x10(%ebp)
80105fb4:	e8 cd c2 ff ff       	call   80102286 <dirlink>
80105fb9:	83 c4 10             	add    $0x10,%esp
80105fbc:	85 c0                	test   %eax,%eax
80105fbe:	78 1e                	js     80105fde <create+0x188>
80105fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc3:	8b 40 04             	mov    0x4(%eax),%eax
80105fc6:	83 ec 04             	sub    $0x4,%esp
80105fc9:	50                   	push   %eax
80105fca:	68 0c af 10 80       	push   $0x8010af0c
80105fcf:	ff 75 f0             	push   -0x10(%ebp)
80105fd2:	e8 af c2 ff ff       	call   80102286 <dirlink>
80105fd7:	83 c4 10             	add    $0x10,%esp
80105fda:	85 c0                	test   %eax,%eax
80105fdc:	79 0d                	jns    80105feb <create+0x195>
      panic("create dots");
80105fde:	83 ec 0c             	sub    $0xc,%esp
80105fe1:	68 3f af 10 80       	push   $0x8010af3f
80105fe6:	e8 be a5 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105feb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fee:	8b 40 04             	mov    0x4(%eax),%eax
80105ff1:	83 ec 04             	sub    $0x4,%esp
80105ff4:	50                   	push   %eax
80105ff5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ff8:	50                   	push   %eax
80105ff9:	ff 75 f4             	push   -0xc(%ebp)
80105ffc:	e8 85 c2 ff ff       	call   80102286 <dirlink>
80106001:	83 c4 10             	add    $0x10,%esp
80106004:	85 c0                	test   %eax,%eax
80106006:	79 0d                	jns    80106015 <create+0x1bf>
    panic("create: dirlink");
80106008:	83 ec 0c             	sub    $0xc,%esp
8010600b:	68 4b af 10 80       	push   $0x8010af4b
80106010:	e8 94 a5 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80106015:	83 ec 0c             	sub    $0xc,%esp
80106018:	ff 75 f4             	push   -0xc(%ebp)
8010601b:	e8 fb bb ff ff       	call   80101c1b <iunlockput>
80106020:	83 c4 10             	add    $0x10,%esp

  return ip;
80106023:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106026:	c9                   	leave  
80106027:	c3                   	ret    

80106028 <sys_open>:

int
sys_open(void)
{
80106028:	55                   	push   %ebp
80106029:	89 e5                	mov    %esp,%ebp
8010602b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010602e:	83 ec 08             	sub    $0x8,%esp
80106031:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106034:	50                   	push   %eax
80106035:	6a 00                	push   $0x0
80106037:	e8 ea f6 ff ff       	call   80105726 <argstr>
8010603c:	83 c4 10             	add    $0x10,%esp
8010603f:	85 c0                	test   %eax,%eax
80106041:	78 15                	js     80106058 <sys_open+0x30>
80106043:	83 ec 08             	sub    $0x8,%esp
80106046:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106049:	50                   	push   %eax
8010604a:	6a 01                	push   $0x1
8010604c:	e8 40 f6 ff ff       	call   80105691 <argint>
80106051:	83 c4 10             	add    $0x10,%esp
80106054:	85 c0                	test   %eax,%eax
80106056:	79 0a                	jns    80106062 <sys_open+0x3a>
    return -1;
80106058:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010605d:	e9 61 01 00 00       	jmp    801061c3 <sys_open+0x19b>

  begin_op();
80106062:	e8 b9 d4 ff ff       	call   80103520 <begin_op>

  if(omode & O_CREATE){
80106067:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010606a:	25 00 02 00 00       	and    $0x200,%eax
8010606f:	85 c0                	test   %eax,%eax
80106071:	74 2a                	je     8010609d <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106073:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106076:	6a 00                	push   $0x0
80106078:	6a 00                	push   $0x0
8010607a:	6a 02                	push   $0x2
8010607c:	50                   	push   %eax
8010607d:	e8 d4 fd ff ff       	call   80105e56 <create>
80106082:	83 c4 10             	add    $0x10,%esp
80106085:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106088:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010608c:	75 75                	jne    80106103 <sys_open+0xdb>
      end_op();
8010608e:	e8 19 d5 ff ff       	call   801035ac <end_op>
      return -1;
80106093:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106098:	e9 26 01 00 00       	jmp    801061c3 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010609d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060a0:	83 ec 0c             	sub    $0xc,%esp
801060a3:	50                   	push   %eax
801060a4:	e8 74 c4 ff ff       	call   8010251d <namei>
801060a9:	83 c4 10             	add    $0x10,%esp
801060ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060b3:	75 0f                	jne    801060c4 <sys_open+0x9c>
      end_op();
801060b5:	e8 f2 d4 ff ff       	call   801035ac <end_op>
      return -1;
801060ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060bf:	e9 ff 00 00 00       	jmp    801061c3 <sys_open+0x19b>
    }
    ilock(ip);
801060c4:	83 ec 0c             	sub    $0xc,%esp
801060c7:	ff 75 f4             	push   -0xc(%ebp)
801060ca:	e8 1b b9 ff ff       	call   801019ea <ilock>
801060cf:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801060d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801060d9:	66 83 f8 01          	cmp    $0x1,%ax
801060dd:	75 24                	jne    80106103 <sys_open+0xdb>
801060df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e2:	85 c0                	test   %eax,%eax
801060e4:	74 1d                	je     80106103 <sys_open+0xdb>
      iunlockput(ip);
801060e6:	83 ec 0c             	sub    $0xc,%esp
801060e9:	ff 75 f4             	push   -0xc(%ebp)
801060ec:	e8 2a bb ff ff       	call   80101c1b <iunlockput>
801060f1:	83 c4 10             	add    $0x10,%esp
      end_op();
801060f4:	e8 b3 d4 ff ff       	call   801035ac <end_op>
      return -1;
801060f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060fe:	e9 c0 00 00 00       	jmp    801061c3 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106103:	e8 d5 ae ff ff       	call   80100fdd <filealloc>
80106108:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010610b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010610f:	74 17                	je     80106128 <sys_open+0x100>
80106111:	83 ec 0c             	sub    $0xc,%esp
80106114:	ff 75 f0             	push   -0x10(%ebp)
80106117:	e8 33 f7 ff ff       	call   8010584f <fdalloc>
8010611c:	83 c4 10             	add    $0x10,%esp
8010611f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106122:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106126:	79 2e                	jns    80106156 <sys_open+0x12e>
    if(f)
80106128:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010612c:	74 0e                	je     8010613c <sys_open+0x114>
      fileclose(f);
8010612e:	83 ec 0c             	sub    $0xc,%esp
80106131:	ff 75 f0             	push   -0x10(%ebp)
80106134:	e8 62 af ff ff       	call   8010109b <fileclose>
80106139:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010613c:	83 ec 0c             	sub    $0xc,%esp
8010613f:	ff 75 f4             	push   -0xc(%ebp)
80106142:	e8 d4 ba ff ff       	call   80101c1b <iunlockput>
80106147:	83 c4 10             	add    $0x10,%esp
    end_op();
8010614a:	e8 5d d4 ff ff       	call   801035ac <end_op>
    return -1;
8010614f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106154:	eb 6d                	jmp    801061c3 <sys_open+0x19b>
  }
  iunlock(ip);
80106156:	83 ec 0c             	sub    $0xc,%esp
80106159:	ff 75 f4             	push   -0xc(%ebp)
8010615c:	e8 9c b9 ff ff       	call   80101afd <iunlock>
80106161:	83 c4 10             	add    $0x10,%esp
  end_op();
80106164:	e8 43 d4 ff ff       	call   801035ac <end_op>

  f->type = FD_INODE;
80106169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106175:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106178:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010617b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106185:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106188:	83 e0 01             	and    $0x1,%eax
8010618b:	85 c0                	test   %eax,%eax
8010618d:	0f 94 c0             	sete   %al
80106190:	89 c2                	mov    %eax,%edx
80106192:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106195:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106198:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010619b:	83 e0 01             	and    $0x1,%eax
8010619e:	85 c0                	test   %eax,%eax
801061a0:	75 0a                	jne    801061ac <sys_open+0x184>
801061a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061a5:	83 e0 02             	and    $0x2,%eax
801061a8:	85 c0                	test   %eax,%eax
801061aa:	74 07                	je     801061b3 <sys_open+0x18b>
801061ac:	b8 01 00 00 00       	mov    $0x1,%eax
801061b1:	eb 05                	jmp    801061b8 <sys_open+0x190>
801061b3:	b8 00 00 00 00       	mov    $0x0,%eax
801061b8:	89 c2                	mov    %eax,%edx
801061ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061bd:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801061c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061c3:	c9                   	leave  
801061c4:	c3                   	ret    

801061c5 <sys_mkdir>:

int
sys_mkdir(void)
{
801061c5:	55                   	push   %ebp
801061c6:	89 e5                	mov    %esp,%ebp
801061c8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801061cb:	e8 50 d3 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801061d0:	83 ec 08             	sub    $0x8,%esp
801061d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061d6:	50                   	push   %eax
801061d7:	6a 00                	push   $0x0
801061d9:	e8 48 f5 ff ff       	call   80105726 <argstr>
801061de:	83 c4 10             	add    $0x10,%esp
801061e1:	85 c0                	test   %eax,%eax
801061e3:	78 1b                	js     80106200 <sys_mkdir+0x3b>
801061e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e8:	6a 00                	push   $0x0
801061ea:	6a 00                	push   $0x0
801061ec:	6a 01                	push   $0x1
801061ee:	50                   	push   %eax
801061ef:	e8 62 fc ff ff       	call   80105e56 <create>
801061f4:	83 c4 10             	add    $0x10,%esp
801061f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061fe:	75 0c                	jne    8010620c <sys_mkdir+0x47>
    end_op();
80106200:	e8 a7 d3 ff ff       	call   801035ac <end_op>
    return -1;
80106205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620a:	eb 18                	jmp    80106224 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010620c:	83 ec 0c             	sub    $0xc,%esp
8010620f:	ff 75 f4             	push   -0xc(%ebp)
80106212:	e8 04 ba ff ff       	call   80101c1b <iunlockput>
80106217:	83 c4 10             	add    $0x10,%esp
  end_op();
8010621a:	e8 8d d3 ff ff       	call   801035ac <end_op>
  return 0;
8010621f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106224:	c9                   	leave  
80106225:	c3                   	ret    

80106226 <sys_mknod>:

int
sys_mknod(void)
{
80106226:	55                   	push   %ebp
80106227:	89 e5                	mov    %esp,%ebp
80106229:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010622c:	e8 ef d2 ff ff       	call   80103520 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106231:	83 ec 08             	sub    $0x8,%esp
80106234:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106237:	50                   	push   %eax
80106238:	6a 00                	push   $0x0
8010623a:	e8 e7 f4 ff ff       	call   80105726 <argstr>
8010623f:	83 c4 10             	add    $0x10,%esp
80106242:	85 c0                	test   %eax,%eax
80106244:	78 4f                	js     80106295 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106246:	83 ec 08             	sub    $0x8,%esp
80106249:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010624c:	50                   	push   %eax
8010624d:	6a 01                	push   $0x1
8010624f:	e8 3d f4 ff ff       	call   80105691 <argint>
80106254:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106257:	85 c0                	test   %eax,%eax
80106259:	78 3a                	js     80106295 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
8010625b:	83 ec 08             	sub    $0x8,%esp
8010625e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106261:	50                   	push   %eax
80106262:	6a 02                	push   $0x2
80106264:	e8 28 f4 ff ff       	call   80105691 <argint>
80106269:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010626c:	85 c0                	test   %eax,%eax
8010626e:	78 25                	js     80106295 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106270:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106273:	0f bf c8             	movswl %ax,%ecx
80106276:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106279:	0f bf d0             	movswl %ax,%edx
8010627c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010627f:	51                   	push   %ecx
80106280:	52                   	push   %edx
80106281:	6a 03                	push   $0x3
80106283:	50                   	push   %eax
80106284:	e8 cd fb ff ff       	call   80105e56 <create>
80106289:	83 c4 10             	add    $0x10,%esp
8010628c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010628f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106293:	75 0c                	jne    801062a1 <sys_mknod+0x7b>
    end_op();
80106295:	e8 12 d3 ff ff       	call   801035ac <end_op>
    return -1;
8010629a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629f:	eb 18                	jmp    801062b9 <sys_mknod+0x93>
  }
  iunlockput(ip);
801062a1:	83 ec 0c             	sub    $0xc,%esp
801062a4:	ff 75 f4             	push   -0xc(%ebp)
801062a7:	e8 6f b9 ff ff       	call   80101c1b <iunlockput>
801062ac:	83 c4 10             	add    $0x10,%esp
  end_op();
801062af:	e8 f8 d2 ff ff       	call   801035ac <end_op>
  return 0;
801062b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062b9:	c9                   	leave  
801062ba:	c3                   	ret    

801062bb <sys_chdir>:

int
sys_chdir(void)
{
801062bb:	55                   	push   %ebp
801062bc:	89 e5                	mov    %esp,%ebp
801062be:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801062c1:	e8 7c dc ff ff       	call   80103f42 <myproc>
801062c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801062c9:	e8 52 d2 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062ce:	83 ec 08             	sub    $0x8,%esp
801062d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062d4:	50                   	push   %eax
801062d5:	6a 00                	push   $0x0
801062d7:	e8 4a f4 ff ff       	call   80105726 <argstr>
801062dc:	83 c4 10             	add    $0x10,%esp
801062df:	85 c0                	test   %eax,%eax
801062e1:	78 18                	js     801062fb <sys_chdir+0x40>
801062e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062e6:	83 ec 0c             	sub    $0xc,%esp
801062e9:	50                   	push   %eax
801062ea:	e8 2e c2 ff ff       	call   8010251d <namei>
801062ef:	83 c4 10             	add    $0x10,%esp
801062f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062f9:	75 0c                	jne    80106307 <sys_chdir+0x4c>
    end_op();
801062fb:	e8 ac d2 ff ff       	call   801035ac <end_op>
    return -1;
80106300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106305:	eb 68                	jmp    8010636f <sys_chdir+0xb4>
  }
  ilock(ip);
80106307:	83 ec 0c             	sub    $0xc,%esp
8010630a:	ff 75 f0             	push   -0x10(%ebp)
8010630d:	e8 d8 b6 ff ff       	call   801019ea <ilock>
80106312:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106315:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106318:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010631c:	66 83 f8 01          	cmp    $0x1,%ax
80106320:	74 1a                	je     8010633c <sys_chdir+0x81>
    iunlockput(ip);
80106322:	83 ec 0c             	sub    $0xc,%esp
80106325:	ff 75 f0             	push   -0x10(%ebp)
80106328:	e8 ee b8 ff ff       	call   80101c1b <iunlockput>
8010632d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106330:	e8 77 d2 ff ff       	call   801035ac <end_op>
    return -1;
80106335:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633a:	eb 33                	jmp    8010636f <sys_chdir+0xb4>
  }
  iunlock(ip);
8010633c:	83 ec 0c             	sub    $0xc,%esp
8010633f:	ff 75 f0             	push   -0x10(%ebp)
80106342:	e8 b6 b7 ff ff       	call   80101afd <iunlock>
80106347:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010634a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634d:	8b 40 68             	mov    0x68(%eax),%eax
80106350:	83 ec 0c             	sub    $0xc,%esp
80106353:	50                   	push   %eax
80106354:	e8 f2 b7 ff ff       	call   80101b4b <iput>
80106359:	83 c4 10             	add    $0x10,%esp
  end_op();
8010635c:	e8 4b d2 ff ff       	call   801035ac <end_op>
  curproc->cwd = ip;
80106361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106364:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106367:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010636a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010636f:	c9                   	leave  
80106370:	c3                   	ret    

80106371 <sys_exec>:

int
sys_exec(void)
{
80106371:	55                   	push   %ebp
80106372:	89 e5                	mov    %esp,%ebp
80106374:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010637a:	83 ec 08             	sub    $0x8,%esp
8010637d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106380:	50                   	push   %eax
80106381:	6a 00                	push   $0x0
80106383:	e8 9e f3 ff ff       	call   80105726 <argstr>
80106388:	83 c4 10             	add    $0x10,%esp
8010638b:	85 c0                	test   %eax,%eax
8010638d:	78 18                	js     801063a7 <sys_exec+0x36>
8010638f:	83 ec 08             	sub    $0x8,%esp
80106392:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106398:	50                   	push   %eax
80106399:	6a 01                	push   $0x1
8010639b:	e8 f1 f2 ff ff       	call   80105691 <argint>
801063a0:	83 c4 10             	add    $0x10,%esp
801063a3:	85 c0                	test   %eax,%eax
801063a5:	79 0a                	jns    801063b1 <sys_exec+0x40>
    return -1;
801063a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ac:	e9 c6 00 00 00       	jmp    80106477 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801063b1:	83 ec 04             	sub    $0x4,%esp
801063b4:	68 80 00 00 00       	push   $0x80
801063b9:	6a 00                	push   $0x0
801063bb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063c1:	50                   	push   %eax
801063c2:	e8 9f ef ff ff       	call   80105366 <memset>
801063c7:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801063ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d4:	83 f8 1f             	cmp    $0x1f,%eax
801063d7:	76 0a                	jbe    801063e3 <sys_exec+0x72>
      return -1;
801063d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063de:	e9 94 00 00 00       	jmp    80106477 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801063e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e6:	c1 e0 02             	shl    $0x2,%eax
801063e9:	89 c2                	mov    %eax,%edx
801063eb:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063f1:	01 c2                	add    %eax,%edx
801063f3:	83 ec 08             	sub    $0x8,%esp
801063f6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801063fc:	50                   	push   %eax
801063fd:	52                   	push   %edx
801063fe:	e8 ed f1 ff ff       	call   801055f0 <fetchint>
80106403:	83 c4 10             	add    $0x10,%esp
80106406:	85 c0                	test   %eax,%eax
80106408:	79 07                	jns    80106411 <sys_exec+0xa0>
      return -1;
8010640a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640f:	eb 66                	jmp    80106477 <sys_exec+0x106>
    if(uarg == 0){
80106411:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106417:	85 c0                	test   %eax,%eax
80106419:	75 27                	jne    80106442 <sys_exec+0xd1>
      argv[i] = 0;
8010641b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010641e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106425:	00 00 00 00 
      break;
80106429:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010642a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642d:	83 ec 08             	sub    $0x8,%esp
80106430:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106436:	52                   	push   %edx
80106437:	50                   	push   %eax
80106438:	e8 43 a7 ff ff       	call   80100b80 <exec>
8010643d:	83 c4 10             	add    $0x10,%esp
80106440:	eb 35                	jmp    80106477 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80106442:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644b:	c1 e0 02             	shl    $0x2,%eax
8010644e:	01 c2                	add    %eax,%edx
80106450:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106456:	83 ec 08             	sub    $0x8,%esp
80106459:	52                   	push   %edx
8010645a:	50                   	push   %eax
8010645b:	e8 cf f1 ff ff       	call   8010562f <fetchstr>
80106460:	83 c4 10             	add    $0x10,%esp
80106463:	85 c0                	test   %eax,%eax
80106465:	79 07                	jns    8010646e <sys_exec+0xfd>
      return -1;
80106467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010646c:	eb 09                	jmp    80106477 <sys_exec+0x106>
  for(i=0;; i++){
8010646e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106472:	e9 5a ff ff ff       	jmp    801063d1 <sys_exec+0x60>
}
80106477:	c9                   	leave  
80106478:	c3                   	ret    

80106479 <sys_pipe>:

int
sys_pipe(void)
{
80106479:	55                   	push   %ebp
8010647a:	89 e5                	mov    %esp,%ebp
8010647c:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010647f:	83 ec 04             	sub    $0x4,%esp
80106482:	6a 08                	push   $0x8
80106484:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106487:	50                   	push   %eax
80106488:	6a 00                	push   $0x0
8010648a:	e8 2f f2 ff ff       	call   801056be <argptr>
8010648f:	83 c4 10             	add    $0x10,%esp
80106492:	85 c0                	test   %eax,%eax
80106494:	79 0a                	jns    801064a0 <sys_pipe+0x27>
    return -1;
80106496:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649b:	e9 ae 00 00 00       	jmp    8010654e <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
801064a0:	83 ec 08             	sub    $0x8,%esp
801064a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064a6:	50                   	push   %eax
801064a7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064aa:	50                   	push   %eax
801064ab:	e8 a1 d5 ff ff       	call   80103a51 <pipealloc>
801064b0:	83 c4 10             	add    $0x10,%esp
801064b3:	85 c0                	test   %eax,%eax
801064b5:	79 0a                	jns    801064c1 <sys_pipe+0x48>
    return -1;
801064b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064bc:	e9 8d 00 00 00       	jmp    8010654e <sys_pipe+0xd5>
  fd0 = -1;
801064c1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064cb:	83 ec 0c             	sub    $0xc,%esp
801064ce:	50                   	push   %eax
801064cf:	e8 7b f3 ff ff       	call   8010584f <fdalloc>
801064d4:	83 c4 10             	add    $0x10,%esp
801064d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064de:	78 18                	js     801064f8 <sys_pipe+0x7f>
801064e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064e3:	83 ec 0c             	sub    $0xc,%esp
801064e6:	50                   	push   %eax
801064e7:	e8 63 f3 ff ff       	call   8010584f <fdalloc>
801064ec:	83 c4 10             	add    $0x10,%esp
801064ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064f6:	79 3e                	jns    80106536 <sys_pipe+0xbd>
    if(fd0 >= 0)
801064f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064fc:	78 13                	js     80106511 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
801064fe:	e8 3f da ff ff       	call   80103f42 <myproc>
80106503:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106506:	83 c2 08             	add    $0x8,%edx
80106509:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106510:	00 
    fileclose(rf);
80106511:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106514:	83 ec 0c             	sub    $0xc,%esp
80106517:	50                   	push   %eax
80106518:	e8 7e ab ff ff       	call   8010109b <fileclose>
8010651d:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106520:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106523:	83 ec 0c             	sub    $0xc,%esp
80106526:	50                   	push   %eax
80106527:	e8 6f ab ff ff       	call   8010109b <fileclose>
8010652c:	83 c4 10             	add    $0x10,%esp
    return -1;
8010652f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106534:	eb 18                	jmp    8010654e <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106536:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106539:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010653c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010653e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106541:	8d 50 04             	lea    0x4(%eax),%edx
80106544:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106547:	89 02                	mov    %eax,(%edx)
  return 0;
80106549:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010654e:	c9                   	leave  
8010654f:	c3                   	ret    

80106550 <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
80106550:	55                   	push   %ebp
80106551:	89 e5                	mov    %esp,%ebp
80106553:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106556:	e8 39 dd ff ff       	call   80104294 <fork>
}
8010655b:	c9                   	leave  
8010655c:	c3                   	ret    

8010655d <sys_exit>:

int
sys_exit(void)
{
8010655d:	55                   	push   %ebp
8010655e:	89 e5                	mov    %esp,%ebp
80106560:	83 ec 08             	sub    $0x8,%esp
  exit();
80106563:	e8 f5 de ff ff       	call   8010445d <exit>
  return 0;  // not reached
80106568:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010656d:	c9                   	leave  
8010656e:	c3                   	ret    

8010656f <sys_wait>:

int
sys_wait(void)
{
8010656f:	55                   	push   %ebp
80106570:	89 e5                	mov    %esp,%ebp
80106572:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106575:	e8 06 e0 ff ff       	call   80104580 <wait>
}
8010657a:	c9                   	leave  
8010657b:	c3                   	ret    

8010657c <sys_kill>:

int
sys_kill(void)
{
8010657c:	55                   	push   %ebp
8010657d:	89 e5                	mov    %esp,%ebp
8010657f:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106582:	83 ec 08             	sub    $0x8,%esp
80106585:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106588:	50                   	push   %eax
80106589:	6a 00                	push   $0x0
8010658b:	e8 01 f1 ff ff       	call   80105691 <argint>
80106590:	83 c4 10             	add    $0x10,%esp
80106593:	85 c0                	test   %eax,%eax
80106595:	79 07                	jns    8010659e <sys_kill+0x22>
    return -1;
80106597:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010659c:	eb 0f                	jmp    801065ad <sys_kill+0x31>
  return kill(pid);
8010659e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a1:	83 ec 0c             	sub    $0xc,%esp
801065a4:	50                   	push   %eax
801065a5:	e8 e4 e5 ff ff       	call   80104b8e <kill>
801065aa:	83 c4 10             	add    $0x10,%esp
}
801065ad:	c9                   	leave  
801065ae:	c3                   	ret    

801065af <sys_getpid>:

int
sys_getpid(void)
{
801065af:	55                   	push   %ebp
801065b0:	89 e5                	mov    %esp,%ebp
801065b2:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801065b5:	e8 88 d9 ff ff       	call   80103f42 <myproc>
801065ba:	8b 40 10             	mov    0x10(%eax),%eax
}
801065bd:	c9                   	leave  
801065be:	c3                   	ret    

801065bf <sys_sbrk>:

int
sys_sbrk(void)
{
801065bf:	55                   	push   %ebp
801065c0:	89 e5                	mov    %esp,%ebp
801065c2:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801065c5:	83 ec 08             	sub    $0x8,%esp
801065c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065cb:	50                   	push   %eax
801065cc:	6a 00                	push   $0x0
801065ce:	e8 be f0 ff ff       	call   80105691 <argint>
801065d3:	83 c4 10             	add    $0x10,%esp
801065d6:	85 c0                	test   %eax,%eax
801065d8:	79 07                	jns    801065e1 <sys_sbrk+0x22>
    return -1;
801065da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065df:	eb 27                	jmp    80106608 <sys_sbrk+0x49>
  addr = myproc()->sz;
801065e1:	e8 5c d9 ff ff       	call   80103f42 <myproc>
801065e6:	8b 00                	mov    (%eax),%eax
801065e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ee:	83 ec 0c             	sub    $0xc,%esp
801065f1:	50                   	push   %eax
801065f2:	e8 02 dc ff ff       	call   801041f9 <growproc>
801065f7:	83 c4 10             	add    $0x10,%esp
801065fa:	85 c0                	test   %eax,%eax
801065fc:	79 07                	jns    80106605 <sys_sbrk+0x46>
    return -1;
801065fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106603:	eb 03                	jmp    80106608 <sys_sbrk+0x49>
  return addr;
80106605:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106608:	c9                   	leave  
80106609:	c3                   	ret    

8010660a <sys_sleep>:

int
sys_sleep(void)
{
8010660a:	55                   	push   %ebp
8010660b:	89 e5                	mov    %esp,%ebp
8010660d:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106610:	83 ec 08             	sub    $0x8,%esp
80106613:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106616:	50                   	push   %eax
80106617:	6a 00                	push   $0x0
80106619:	e8 73 f0 ff ff       	call   80105691 <argint>
8010661e:	83 c4 10             	add    $0x10,%esp
80106621:	85 c0                	test   %eax,%eax
80106623:	79 07                	jns    8010662c <sys_sleep+0x22>
    return -1;
80106625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662a:	eb 76                	jmp    801066a2 <sys_sleep+0x98>
  acquire(&tickslock);
8010662c:	83 ec 0c             	sub    $0xc,%esp
8010662f:	68 c0 a6 11 80       	push   $0x8011a6c0
80106634:	e8 b7 ea ff ff       	call   801050f0 <acquire>
80106639:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010663c:	a1 f4 a6 11 80       	mov    0x8011a6f4,%eax
80106641:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106644:	eb 38                	jmp    8010667e <sys_sleep+0x74>
    if(myproc()->killed){
80106646:	e8 f7 d8 ff ff       	call   80103f42 <myproc>
8010664b:	8b 40 24             	mov    0x24(%eax),%eax
8010664e:	85 c0                	test   %eax,%eax
80106650:	74 17                	je     80106669 <sys_sleep+0x5f>
      release(&tickslock);
80106652:	83 ec 0c             	sub    $0xc,%esp
80106655:	68 c0 a6 11 80       	push   $0x8011a6c0
8010665a:	e8 ff ea ff ff       	call   8010515e <release>
8010665f:	83 c4 10             	add    $0x10,%esp
      return -1;
80106662:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106667:	eb 39                	jmp    801066a2 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106669:	83 ec 08             	sub    $0x8,%esp
8010666c:	68 c0 a6 11 80       	push   $0x8011a6c0
80106671:	68 f4 a6 11 80       	push   $0x8011a6f4
80106676:	e8 f2 e3 ff ff       	call   80104a6d <sleep>
8010667b:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010667e:	a1 f4 a6 11 80       	mov    0x8011a6f4,%eax
80106683:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106686:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106689:	39 d0                	cmp    %edx,%eax
8010668b:	72 b9                	jb     80106646 <sys_sleep+0x3c>
  }
  release(&tickslock);
8010668d:	83 ec 0c             	sub    $0xc,%esp
80106690:	68 c0 a6 11 80       	push   $0x8011a6c0
80106695:	e8 c4 ea ff ff       	call   8010515e <release>
8010669a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010669d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066a2:	c9                   	leave  
801066a3:	c3                   	ret    

801066a4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801066a4:	55                   	push   %ebp
801066a5:	89 e5                	mov    %esp,%ebp
801066a7:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801066aa:	83 ec 0c             	sub    $0xc,%esp
801066ad:	68 c0 a6 11 80       	push   $0x8011a6c0
801066b2:	e8 39 ea ff ff       	call   801050f0 <acquire>
801066b7:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801066ba:	a1 f4 a6 11 80       	mov    0x8011a6f4,%eax
801066bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066c2:	83 ec 0c             	sub    $0xc,%esp
801066c5:	68 c0 a6 11 80       	push   $0x8011a6c0
801066ca:	e8 8f ea ff ff       	call   8010515e <release>
801066cf:	83 c4 10             	add    $0x10,%esp
  return xticks;
801066d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066d5:	c9                   	leave  
801066d6:	c3                   	ret    

801066d7 <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
801066d7:	55                   	push   %ebp
801066d8:	89 e5                	mov    %esp,%ebp
801066da:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
801066dd:	83 ec 08             	sub    $0x8,%esp
801066e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066e3:	50                   	push   %eax
801066e4:	6a 00                	push   $0x0
801066e6:	e8 a6 ef ff ff       	call   80105691 <argint>
801066eb:	83 c4 10             	add    $0x10,%esp
801066ee:	85 c0                	test   %eax,%eax
801066f0:	79 07                	jns    801066f9 <sys_setSchedPolicy+0x22>
    return -1;
801066f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f7:	eb 0f                	jmp    80106708 <sys_setSchedPolicy+0x31>
  return setSchedPolicy(policy);
801066f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fc:	83 ec 0c             	sub    $0xc,%esp
801066ff:	50                   	push   %eax
80106700:	e8 1b e7 ff ff       	call   80104e20 <setSchedPolicy>
80106705:	83 c4 10             	add    $0x10,%esp
}
80106708:	c9                   	leave  
80106709:	c3                   	ret    

8010670a <sys_getpinfo>:



int
sys_getpinfo(void)
{
8010670a:	55                   	push   %ebp
8010670b:	89 e5                	mov    %esp,%ebp
8010670d:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (void*)&ps, sizeof(*ps)) < 0)
80106710:	83 ec 04             	sub    $0x4,%esp
80106713:	68 00 0c 00 00       	push   $0xc00
80106718:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010671b:	50                   	push   %eax
8010671c:	6a 00                	push   $0x0
8010671e:	e8 9b ef ff ff       	call   801056be <argptr>
80106723:	83 c4 10             	add    $0x10,%esp
80106726:	85 c0                	test   %eax,%eax
80106728:	79 07                	jns    80106731 <sys_getpinfo+0x27>
    return -1;
8010672a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010672f:	eb 0f                	jmp    80106740 <sys_getpinfo+0x36>
  return getpinfo(ps);
80106731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106734:	83 ec 0c             	sub    $0xc,%esp
80106737:	50                   	push   %eax
80106738:	e8 1b e7 ff ff       	call   80104e58 <getpinfo>
8010673d:	83 c4 10             	add    $0x10,%esp
}
80106740:	c9                   	leave  
80106741:	c3                   	ret    

80106742 <sys_yield>:

int
sys_yield(void)
{
80106742:	55                   	push   %ebp
80106743:	89 e5                	mov    %esp,%ebp
80106745:	83 ec 08             	sub    $0x8,%esp
  yield();
80106748:	e8 6a e2 ff ff       	call   801049b7 <yield>
  return 0;
8010674d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106752:	c9                   	leave  
80106753:	c3                   	ret    

80106754 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106754:	1e                   	push   %ds
  pushl %es
80106755:	06                   	push   %es
  pushl %fs
80106756:	0f a0                	push   %fs
  pushl %gs
80106758:	0f a8                	push   %gs
  pushal
8010675a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010675b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010675f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106761:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106763:	54                   	push   %esp
  call trap
80106764:	e8 d7 01 00 00       	call   80106940 <trap>
  addl $4, %esp
80106769:	83 c4 04             	add    $0x4,%esp

8010676c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010676c:	61                   	popa   
  popl %gs
8010676d:	0f a9                	pop    %gs
  popl %fs
8010676f:	0f a1                	pop    %fs
  popl %es
80106771:	07                   	pop    %es
  popl %ds
80106772:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106773:	83 c4 08             	add    $0x8,%esp
  iret
80106776:	cf                   	iret   

80106777 <lidt>:
{
80106777:	55                   	push   %ebp
80106778:	89 e5                	mov    %esp,%ebp
8010677a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010677d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106780:	83 e8 01             	sub    $0x1,%eax
80106783:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106787:	8b 45 08             	mov    0x8(%ebp),%eax
8010678a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010678e:	8b 45 08             	mov    0x8(%ebp),%eax
80106791:	c1 e8 10             	shr    $0x10,%eax
80106794:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106798:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010679b:	0f 01 18             	lidtl  (%eax)
}
8010679e:	90                   	nop
8010679f:	c9                   	leave  
801067a0:	c3                   	ret    

801067a1 <rcr2>:

static inline uint
rcr2(void)
{
801067a1:	55                   	push   %ebp
801067a2:	89 e5                	mov    %esp,%ebp
801067a4:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067a7:	0f 20 d0             	mov    %cr2,%eax
801067aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801067ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801067b0:	c9                   	leave  
801067b1:	c3                   	ret    

801067b2 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067b2:	55                   	push   %ebp
801067b3:	89 e5                	mov    %esp,%ebp
801067b5:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801067b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067bf:	e9 c3 00 00 00       	jmp    80106887 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c7:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
801067ce:	89 c2                	mov    %eax,%edx
801067d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d3:	66 89 14 c5 c0 9e 11 	mov    %dx,-0x7fee6140(,%eax,8)
801067da:	80 
801067db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067de:	66 c7 04 c5 c2 9e 11 	movw   $0x8,-0x7fee613e(,%eax,8)
801067e5:	80 08 00 
801067e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067eb:	0f b6 14 c5 c4 9e 11 	movzbl -0x7fee613c(,%eax,8),%edx
801067f2:	80 
801067f3:	83 e2 e0             	and    $0xffffffe0,%edx
801067f6:	88 14 c5 c4 9e 11 80 	mov    %dl,-0x7fee613c(,%eax,8)
801067fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106800:	0f b6 14 c5 c4 9e 11 	movzbl -0x7fee613c(,%eax,8),%edx
80106807:	80 
80106808:	83 e2 1f             	and    $0x1f,%edx
8010680b:	88 14 c5 c4 9e 11 80 	mov    %dl,-0x7fee613c(,%eax,8)
80106812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106815:	0f b6 14 c5 c5 9e 11 	movzbl -0x7fee613b(,%eax,8),%edx
8010681c:	80 
8010681d:	83 e2 f0             	and    $0xfffffff0,%edx
80106820:	83 ca 0e             	or     $0xe,%edx
80106823:	88 14 c5 c5 9e 11 80 	mov    %dl,-0x7fee613b(,%eax,8)
8010682a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682d:	0f b6 14 c5 c5 9e 11 	movzbl -0x7fee613b(,%eax,8),%edx
80106834:	80 
80106835:	83 e2 ef             	and    $0xffffffef,%edx
80106838:	88 14 c5 c5 9e 11 80 	mov    %dl,-0x7fee613b(,%eax,8)
8010683f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106842:	0f b6 14 c5 c5 9e 11 	movzbl -0x7fee613b(,%eax,8),%edx
80106849:	80 
8010684a:	83 e2 9f             	and    $0xffffff9f,%edx
8010684d:	88 14 c5 c5 9e 11 80 	mov    %dl,-0x7fee613b(,%eax,8)
80106854:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106857:	0f b6 14 c5 c5 9e 11 	movzbl -0x7fee613b(,%eax,8),%edx
8010685e:	80 
8010685f:	83 ca 80             	or     $0xffffff80,%edx
80106862:	88 14 c5 c5 9e 11 80 	mov    %dl,-0x7fee613b(,%eax,8)
80106869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010686c:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80106873:	c1 e8 10             	shr    $0x10,%eax
80106876:	89 c2                	mov    %eax,%edx
80106878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010687b:	66 89 14 c5 c6 9e 11 	mov    %dx,-0x7fee613a(,%eax,8)
80106882:	80 
  for(i = 0; i < 256; i++)
80106883:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106887:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010688e:	0f 8e 30 ff ff ff    	jle    801067c4 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106894:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80106899:	66 a3 c0 a0 11 80    	mov    %ax,0x8011a0c0
8010689f:	66 c7 05 c2 a0 11 80 	movw   $0x8,0x8011a0c2
801068a6:	08 00 
801068a8:	0f b6 05 c4 a0 11 80 	movzbl 0x8011a0c4,%eax
801068af:	83 e0 e0             	and    $0xffffffe0,%eax
801068b2:	a2 c4 a0 11 80       	mov    %al,0x8011a0c4
801068b7:	0f b6 05 c4 a0 11 80 	movzbl 0x8011a0c4,%eax
801068be:	83 e0 1f             	and    $0x1f,%eax
801068c1:	a2 c4 a0 11 80       	mov    %al,0x8011a0c4
801068c6:	0f b6 05 c5 a0 11 80 	movzbl 0x8011a0c5,%eax
801068cd:	83 c8 0f             	or     $0xf,%eax
801068d0:	a2 c5 a0 11 80       	mov    %al,0x8011a0c5
801068d5:	0f b6 05 c5 a0 11 80 	movzbl 0x8011a0c5,%eax
801068dc:	83 e0 ef             	and    $0xffffffef,%eax
801068df:	a2 c5 a0 11 80       	mov    %al,0x8011a0c5
801068e4:	0f b6 05 c5 a0 11 80 	movzbl 0x8011a0c5,%eax
801068eb:	83 c8 60             	or     $0x60,%eax
801068ee:	a2 c5 a0 11 80       	mov    %al,0x8011a0c5
801068f3:	0f b6 05 c5 a0 11 80 	movzbl 0x8011a0c5,%eax
801068fa:	83 c8 80             	or     $0xffffff80,%eax
801068fd:	a2 c5 a0 11 80       	mov    %al,0x8011a0c5
80106902:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80106907:	c1 e8 10             	shr    $0x10,%eax
8010690a:	66 a3 c6 a0 11 80    	mov    %ax,0x8011a0c6

  initlock(&tickslock, "time");
80106910:	83 ec 08             	sub    $0x8,%esp
80106913:	68 5c af 10 80       	push   $0x8010af5c
80106918:	68 c0 a6 11 80       	push   $0x8011a6c0
8010691d:	e8 ac e7 ff ff       	call   801050ce <initlock>
80106922:	83 c4 10             	add    $0x10,%esp
}
80106925:	90                   	nop
80106926:	c9                   	leave  
80106927:	c3                   	ret    

80106928 <idtinit>:

void
idtinit(void)
{
80106928:	55                   	push   %ebp
80106929:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010692b:	68 00 08 00 00       	push   $0x800
80106930:	68 c0 9e 11 80       	push   $0x80119ec0
80106935:	e8 3d fe ff ff       	call   80106777 <lidt>
8010693a:	83 c4 08             	add    $0x8,%esp
}
8010693d:	90                   	nop
8010693e:	c9                   	leave  
8010693f:	c3                   	ret    

80106940 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106940:	55                   	push   %ebp
80106941:	89 e5                	mov    %esp,%ebp
80106943:	57                   	push   %edi
80106944:	56                   	push   %esi
80106945:	53                   	push   %ebx
80106946:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106949:	8b 45 08             	mov    0x8(%ebp),%eax
8010694c:	8b 40 30             	mov    0x30(%eax),%eax
8010694f:	83 f8 40             	cmp    $0x40,%eax
80106952:	75 3b                	jne    8010698f <trap+0x4f>
    if(myproc()->killed)
80106954:	e8 e9 d5 ff ff       	call   80103f42 <myproc>
80106959:	8b 40 24             	mov    0x24(%eax),%eax
8010695c:	85 c0                	test   %eax,%eax
8010695e:	74 05                	je     80106965 <trap+0x25>
      exit();
80106960:	e8 f8 da ff ff       	call   8010445d <exit>
    myproc()->tf = tf;
80106965:	e8 d8 d5 ff ff       	call   80103f42 <myproc>
8010696a:	8b 55 08             	mov    0x8(%ebp),%edx
8010696d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106970:	e8 e8 ed ff ff       	call   8010575d <syscall>
    if(myproc()->killed)
80106975:	e8 c8 d5 ff ff       	call   80103f42 <myproc>
8010697a:	8b 40 24             	mov    0x24(%eax),%eax
8010697d:	85 c0                	test   %eax,%eax
8010697f:	0f 84 dd 03 00 00    	je     80106d62 <trap+0x422>
      exit();
80106985:	e8 d3 da ff ff       	call   8010445d <exit>
    return;
8010698a:	e9 d3 03 00 00       	jmp    80106d62 <trap+0x422>
  }

  switch(tf->trapno){
8010698f:	8b 45 08             	mov    0x8(%ebp),%eax
80106992:	8b 40 30             	mov    0x30(%eax),%eax
80106995:	83 e8 20             	sub    $0x20,%eax
80106998:	83 f8 1f             	cmp    $0x1f,%eax
8010699b:	0f 87 8c 02 00 00    	ja     80106c2d <trap+0x2ed>
801069a1:	8b 04 85 04 b0 10 80 	mov    -0x7fef4ffc(,%eax,4),%eax
801069a8:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801069aa:	e8 00 d5 ff ff       	call   80103eaf <cpuid>
801069af:	85 c0                	test   %eax,%eax
801069b1:	75 3d                	jne    801069f0 <trap+0xb0>
      acquire(&tickslock);
801069b3:	83 ec 0c             	sub    $0xc,%esp
801069b6:	68 c0 a6 11 80       	push   $0x8011a6c0
801069bb:	e8 30 e7 ff ff       	call   801050f0 <acquire>
801069c0:	83 c4 10             	add    $0x10,%esp
      ticks++;
801069c3:	a1 f4 a6 11 80       	mov    0x8011a6f4,%eax
801069c8:	83 c0 01             	add    $0x1,%eax
801069cb:	a3 f4 a6 11 80       	mov    %eax,0x8011a6f4
      wakeup(&ticks);
801069d0:	83 ec 0c             	sub    $0xc,%esp
801069d3:	68 f4 a6 11 80       	push   $0x8011a6f4
801069d8:	e8 7a e1 ff ff       	call   80104b57 <wakeup>
801069dd:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801069e0:	83 ec 0c             	sub    $0xc,%esp
801069e3:	68 c0 a6 11 80       	push   $0x8011a6c0
801069e8:	e8 71 e7 ff ff       	call   8010515e <release>
801069ed:	83 c4 10             	add    $0x10,%esp
    }
    // 현재 실행 중인 프로세스의 tick 증가
    struct proc *curproc = myproc();
801069f0:	e8 4d d5 ff ff       	call   80103f42 <myproc>
801069f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (curproc && curproc->state == RUNNING) {
801069f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801069fc:	74 2f                	je     80106a2d <trap+0xed>
801069fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a01:	8b 40 0c             	mov    0xc(%eax),%eax
80106a04:	83 f8 04             	cmp    $0x4,%eax
80106a07:	75 24                	jne    80106a2d <trap+0xed>
      int q = curproc->priority;
80106a09:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a0c:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a0f:	89 45 d8             	mov    %eax,-0x28(%ebp)
      curproc->ticks[q]++;
80106a12:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a15:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106a18:	83 c2 20             	add    $0x20,%edx
80106a1b:	8b 04 90             	mov    (%eax,%edx,4),%eax
80106a1e:	8d 48 01             	lea    0x1(%eax),%ecx
80106a21:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a24:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106a27:	83 c2 20             	add    $0x20,%edx
80106a2a:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    }
    
    acquire(&ptable.lock);
80106a2d:	83 ec 0c             	sub    $0xc,%esp
80106a30:	68 40 72 11 80       	push   $0x80117240
80106a35:	e8 b6 e6 ff ff       	call   801050f0 <acquire>
80106a3a:	83 c4 10             	add    $0x10,%esp
    //// RUNNABLE 상태인 다른 프로세스들의 wait_ticks 증가
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106a3d:	c7 45 e4 74 72 11 80 	movl   $0x80117274,-0x1c(%ebp)
80106a44:	eb 4a                	jmp    80106a90 <trap+0x150>
      if (p->state == RUNNABLE && p != curproc) {
80106a46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a49:	8b 40 0c             	mov    0xc(%eax),%eax
80106a4c:	83 f8 03             	cmp    $0x3,%eax
80106a4f:	75 38                	jne    80106a89 <trap+0x149>
80106a51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a54:	3b 45 dc             	cmp    -0x24(%ebp),%eax
80106a57:	74 30                	je     80106a89 <trap+0x149>
        int q = p->priority;
80106a59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a5c:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a5f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if ( q >=0 && q< MLFQ_LEVELS){
80106a62:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80106a66:	78 21                	js     80106a89 <trap+0x149>
80106a68:	83 7d d0 03          	cmpl   $0x3,-0x30(%ebp)
80106a6c:	7f 1b                	jg     80106a89 <trap+0x149>
          p->wait_ticks[q]++;
80106a6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a71:	8b 55 d0             	mov    -0x30(%ebp),%edx
80106a74:	83 c2 24             	add    $0x24,%edx
80106a77:	8b 04 90             	mov    (%eax,%edx,4),%eax
80106a7a:	8d 48 01             	lea    0x1(%eax),%ecx
80106a7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a80:	8b 55 d0             	mov    -0x30(%ebp),%edx
80106a83:	83 c2 24             	add    $0x24,%edx
80106a86:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106a89:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
80106a90:	81 7d e4 74 9a 11 80 	cmpl   $0x80119a74,-0x1c(%ebp)
80106a97:	72 ad                	jb     80106a46 <trap+0x106>
        }
        
      }
    }
    //priority boost 조건 확인 (policy == 1일 때만)
    if (mycpu()->sched_policy == 1) {
80106a99:	e8 2c d4 ff ff       	call   80103eca <mycpu>
80106a9e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106aa4:	83 f8 01             	cmp    $0x1,%eax
80106aa7:	0f 85 fb 00 00 00    	jne    80106ba8 <trap+0x268>
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106aad:	c7 45 e0 74 72 11 80 	movl   $0x80117274,-0x20(%ebp)
80106ab4:	e9 e2 00 00 00       	jmp    80106b9b <trap+0x25b>
        if (p -> state != RUNNABLE) continue;
80106ab9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106abc:	8b 40 0c             	mov    0xc(%eax),%eax
80106abf:	83 f8 03             	cmp    $0x3,%eax
80106ac2:	0f 85 cb 00 00 00    	jne    80106b93 <trap+0x253>
        int q = p->priority;
80106ac8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106acb:	8b 40 7c             	mov    0x7c(%eax),%eax
80106ace:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        //Q0 -> Q1
        if (q == 0 && p->wait_ticks[0] >= 500) {
80106ad1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80106ad5:	75 3a                	jne    80106b11 <trap+0x1d1>
80106ad7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106ada:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106ae0:	3d f3 01 00 00       	cmp    $0x1f3,%eax
80106ae5:	7e 2a                	jle    80106b11 <trap+0x1d1>
          p->priority = 1;
80106ae7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106aea:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
          p->wait_ticks[0] = 0;
80106af1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106af4:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80106afb:	00 00 00 
          enqueue(&mlfq[1], p);
80106afe:	83 ec 08             	sub    $0x8,%esp
80106b01:	ff 75 e0             	push   -0x20(%ebp)
80106b04:	68 88 9b 11 80       	push   $0x80119b88
80106b09:	e8 46 e1 ff ff       	call   80104c54 <enqueue>
80106b0e:	83 c4 10             	add    $0x10,%esp
        }
  
        // Q1 -> Q2
        if (q == 1 && p->wait_ticks[1] >= 160){
80106b11:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
80106b15:	75 3c                	jne    80106b53 <trap+0x213>
80106b17:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b1a:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106b20:	3d 9f 00 00 00       	cmp    $0x9f,%eax
80106b25:	7e 2c                	jle    80106b53 <trap+0x213>
          p->priority = 2;  
80106b27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b2a:	c7 40 7c 02 00 00 00 	movl   $0x2,0x7c(%eax)
          p->wait_ticks[1] = 0;
80106b31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b34:	c7 80 94 00 00 00 00 	movl   $0x0,0x94(%eax)
80106b3b:	00 00 00 
          enqueue(&mlfq[2], p);
80106b3e:	83 ec 08             	sub    $0x8,%esp
80106b41:	ff 75 e0             	push   -0x20(%ebp)
80106b44:	68 90 9c 11 80       	push   $0x80119c90
80106b49:	e8 06 e1 ff ff       	call   80104c54 <enqueue>
80106b4e:	83 c4 10             	add    $0x10,%esp
80106b51:	eb 41                	jmp    80106b94 <trap+0x254>
        }
        //Q2 ->Q3
        else if (q == 2 && p->wait_ticks[2] >= 80){
80106b53:	83 7d d4 02          	cmpl   $0x2,-0x2c(%ebp)
80106b57:	75 3b                	jne    80106b94 <trap+0x254>
80106b59:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b5c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106b62:	83 f8 4f             	cmp    $0x4f,%eax
80106b65:	7e 2d                	jle    80106b94 <trap+0x254>
          p->priority = 3;
80106b67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b6a:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
          p->wait_ticks[2] = 0;
80106b71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b74:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
80106b7b:	00 00 00 
          enqueue(&mlfq[3], p);
80106b7e:	83 ec 08             	sub    $0x8,%esp
80106b81:	ff 75 e0             	push   -0x20(%ebp)
80106b84:	68 98 9d 11 80       	push   $0x80119d98
80106b89:	e8 c6 e0 ff ff       	call   80104c54 <enqueue>
80106b8e:	83 c4 10             	add    $0x10,%esp
80106b91:	eb 01                	jmp    80106b94 <trap+0x254>
        if (p -> state != RUNNABLE) continue;
80106b93:	90                   	nop
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106b94:	81 45 e0 a0 00 00 00 	addl   $0xa0,-0x20(%ebp)
80106b9b:	81 7d e0 74 9a 11 80 	cmpl   $0x80119a74,-0x20(%ebp)
80106ba2:	0f 82 11 ff ff ff    	jb     80106ab9 <trap+0x179>
        }
        
      }
    }
    release(&ptable.lock);
80106ba8:	83 ec 0c             	sub    $0xc,%esp
80106bab:	68 40 72 11 80       	push   $0x80117240
80106bb0:	e8 a9 e5 ff ff       	call   8010515e <release>
80106bb5:	83 c4 10             	add    $0x10,%esp

 
  
    lapiceoi();
80106bb8:	e8 43 c4 ff ff       	call   80103000 <lapiceoi>
    break;
80106bbd:	e9 20 01 00 00       	jmp    80106ce2 <trap+0x3a2>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106bc2:	e8 8f bc ff ff       	call   80102856 <ideintr>
    lapiceoi();
80106bc7:	e8 34 c4 ff ff       	call   80103000 <lapiceoi>
    break;
80106bcc:	e9 11 01 00 00       	jmp    80106ce2 <trap+0x3a2>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106bd1:	e8 6f c2 ff ff       	call   80102e45 <kbdintr>
    lapiceoi();
80106bd6:	e8 25 c4 ff ff       	call   80103000 <lapiceoi>
    break;
80106bdb:	e9 02 01 00 00       	jmp    80106ce2 <trap+0x3a2>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106be0:	e8 53 03 00 00       	call   80106f38 <uartintr>
    lapiceoi();
80106be5:	e8 16 c4 ff ff       	call   80103000 <lapiceoi>
    break;
80106bea:	e9 f3 00 00 00       	jmp    80106ce2 <trap+0x3a2>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106bef:	e8 7b 2b 00 00       	call   8010976f <i8254_intr>
    lapiceoi();
80106bf4:	e8 07 c4 ff ff       	call   80103000 <lapiceoi>
    break;
80106bf9:	e9 e4 00 00 00       	jmp    80106ce2 <trap+0x3a2>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80106c01:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106c04:	8b 45 08             	mov    0x8(%ebp),%eax
80106c07:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c0b:	0f b7 d8             	movzwl %ax,%ebx
80106c0e:	e8 9c d2 ff ff       	call   80103eaf <cpuid>
80106c13:	56                   	push   %esi
80106c14:	53                   	push   %ebx
80106c15:	50                   	push   %eax
80106c16:	68 64 af 10 80       	push   $0x8010af64
80106c1b:	e8 d4 97 ff ff       	call   801003f4 <cprintf>
80106c20:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106c23:	e8 d8 c3 ff ff       	call   80103000 <lapiceoi>
    break;
80106c28:	e9 b5 00 00 00       	jmp    80106ce2 <trap+0x3a2>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106c2d:	e8 10 d3 ff ff       	call   80103f42 <myproc>
80106c32:	85 c0                	test   %eax,%eax
80106c34:	74 11                	je     80106c47 <trap+0x307>
80106c36:	8b 45 08             	mov    0x8(%ebp),%eax
80106c39:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c3d:	0f b7 c0             	movzwl %ax,%eax
80106c40:	83 e0 03             	and    $0x3,%eax
80106c43:	85 c0                	test   %eax,%eax
80106c45:	75 39                	jne    80106c80 <trap+0x340>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c47:	e8 55 fb ff ff       	call   801067a1 <rcr2>
80106c4c:	89 c3                	mov    %eax,%ebx
80106c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c51:	8b 70 38             	mov    0x38(%eax),%esi
80106c54:	e8 56 d2 ff ff       	call   80103eaf <cpuid>
80106c59:	8b 55 08             	mov    0x8(%ebp),%edx
80106c5c:	8b 52 30             	mov    0x30(%edx),%edx
80106c5f:	83 ec 0c             	sub    $0xc,%esp
80106c62:	53                   	push   %ebx
80106c63:	56                   	push   %esi
80106c64:	50                   	push   %eax
80106c65:	52                   	push   %edx
80106c66:	68 88 af 10 80       	push   $0x8010af88
80106c6b:	e8 84 97 ff ff       	call   801003f4 <cprintf>
80106c70:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106c73:	83 ec 0c             	sub    $0xc,%esp
80106c76:	68 ba af 10 80       	push   $0x8010afba
80106c7b:	e8 29 99 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c80:	e8 1c fb ff ff       	call   801067a1 <rcr2>
80106c85:	89 c6                	mov    %eax,%esi
80106c87:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8a:	8b 40 38             	mov    0x38(%eax),%eax
80106c8d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80106c90:	e8 1a d2 ff ff       	call   80103eaf <cpuid>
80106c95:	89 c3                	mov    %eax,%ebx
80106c97:	8b 45 08             	mov    0x8(%ebp),%eax
80106c9a:	8b 78 34             	mov    0x34(%eax),%edi
80106c9d:	89 7d c0             	mov    %edi,-0x40(%ebp)
80106ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca3:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106ca6:	e8 97 d2 ff ff       	call   80103f42 <myproc>
80106cab:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106cae:	89 4d bc             	mov    %ecx,-0x44(%ebp)
80106cb1:	e8 8c d2 ff ff       	call   80103f42 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cb6:	8b 40 10             	mov    0x10(%eax),%eax
80106cb9:	56                   	push   %esi
80106cba:	ff 75 c4             	push   -0x3c(%ebp)
80106cbd:	53                   	push   %ebx
80106cbe:	ff 75 c0             	push   -0x40(%ebp)
80106cc1:	57                   	push   %edi
80106cc2:	ff 75 bc             	push   -0x44(%ebp)
80106cc5:	50                   	push   %eax
80106cc6:	68 c0 af 10 80       	push   $0x8010afc0
80106ccb:	e8 24 97 ff ff       	call   801003f4 <cprintf>
80106cd0:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106cd3:	e8 6a d2 ff ff       	call   80103f42 <myproc>
80106cd8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cdf:	eb 01                	jmp    80106ce2 <trap+0x3a2>
    break;
80106ce1:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ce2:	e8 5b d2 ff ff       	call   80103f42 <myproc>
80106ce7:	85 c0                	test   %eax,%eax
80106ce9:	74 23                	je     80106d0e <trap+0x3ce>
80106ceb:	e8 52 d2 ff ff       	call   80103f42 <myproc>
80106cf0:	8b 40 24             	mov    0x24(%eax),%eax
80106cf3:	85 c0                	test   %eax,%eax
80106cf5:	74 17                	je     80106d0e <trap+0x3ce>
80106cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80106cfa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cfe:	0f b7 c0             	movzwl %ax,%eax
80106d01:	83 e0 03             	and    $0x3,%eax
80106d04:	83 f8 03             	cmp    $0x3,%eax
80106d07:	75 05                	jne    80106d0e <trap+0x3ce>
    exit();
80106d09:	e8 4f d7 ff ff       	call   8010445d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106d0e:	e8 2f d2 ff ff       	call   80103f42 <myproc>
80106d13:	85 c0                	test   %eax,%eax
80106d15:	74 1d                	je     80106d34 <trap+0x3f4>
80106d17:	e8 26 d2 ff ff       	call   80103f42 <myproc>
80106d1c:	8b 40 0c             	mov    0xc(%eax),%eax
80106d1f:	83 f8 04             	cmp    $0x4,%eax
80106d22:	75 10                	jne    80106d34 <trap+0x3f4>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106d24:	8b 45 08             	mov    0x8(%ebp),%eax
80106d27:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106d2a:	83 f8 20             	cmp    $0x20,%eax
80106d2d:	75 05                	jne    80106d34 <trap+0x3f4>
    yield();
80106d2f:	e8 83 dc ff ff       	call   801049b7 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106d34:	e8 09 d2 ff ff       	call   80103f42 <myproc>
80106d39:	85 c0                	test   %eax,%eax
80106d3b:	74 26                	je     80106d63 <trap+0x423>
80106d3d:	e8 00 d2 ff ff       	call   80103f42 <myproc>
80106d42:	8b 40 24             	mov    0x24(%eax),%eax
80106d45:	85 c0                	test   %eax,%eax
80106d47:	74 1a                	je     80106d63 <trap+0x423>
80106d49:	8b 45 08             	mov    0x8(%ebp),%eax
80106d4c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d50:	0f b7 c0             	movzwl %ax,%eax
80106d53:	83 e0 03             	and    $0x3,%eax
80106d56:	83 f8 03             	cmp    $0x3,%eax
80106d59:	75 08                	jne    80106d63 <trap+0x423>
    exit();
80106d5b:	e8 fd d6 ff ff       	call   8010445d <exit>
80106d60:	eb 01                	jmp    80106d63 <trap+0x423>
    return;
80106d62:	90                   	nop
80106d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d66:	5b                   	pop    %ebx
80106d67:	5e                   	pop    %esi
80106d68:	5f                   	pop    %edi
80106d69:	5d                   	pop    %ebp
80106d6a:	c3                   	ret    

80106d6b <inb>:
{
80106d6b:	55                   	push   %ebp
80106d6c:	89 e5                	mov    %esp,%ebp
80106d6e:	83 ec 14             	sub    $0x14,%esp
80106d71:	8b 45 08             	mov    0x8(%ebp),%eax
80106d74:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d78:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106d7c:	89 c2                	mov    %eax,%edx
80106d7e:	ec                   	in     (%dx),%al
80106d7f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106d82:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106d86:	c9                   	leave  
80106d87:	c3                   	ret    

80106d88 <outb>:
{
80106d88:	55                   	push   %ebp
80106d89:	89 e5                	mov    %esp,%ebp
80106d8b:	83 ec 08             	sub    $0x8,%esp
80106d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d91:	8b 55 0c             	mov    0xc(%ebp),%edx
80106d94:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106d98:	89 d0                	mov    %edx,%eax
80106d9a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d9d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106da1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106da5:	ee                   	out    %al,(%dx)
}
80106da6:	90                   	nop
80106da7:	c9                   	leave  
80106da8:	c3                   	ret    

80106da9 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106da9:	55                   	push   %ebp
80106daa:	89 e5                	mov    %esp,%ebp
80106dac:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106daf:	6a 00                	push   $0x0
80106db1:	68 fa 03 00 00       	push   $0x3fa
80106db6:	e8 cd ff ff ff       	call   80106d88 <outb>
80106dbb:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106dbe:	68 80 00 00 00       	push   $0x80
80106dc3:	68 fb 03 00 00       	push   $0x3fb
80106dc8:	e8 bb ff ff ff       	call   80106d88 <outb>
80106dcd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106dd0:	6a 0c                	push   $0xc
80106dd2:	68 f8 03 00 00       	push   $0x3f8
80106dd7:	e8 ac ff ff ff       	call   80106d88 <outb>
80106ddc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106ddf:	6a 00                	push   $0x0
80106de1:	68 f9 03 00 00       	push   $0x3f9
80106de6:	e8 9d ff ff ff       	call   80106d88 <outb>
80106deb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106dee:	6a 03                	push   $0x3
80106df0:	68 fb 03 00 00       	push   $0x3fb
80106df5:	e8 8e ff ff ff       	call   80106d88 <outb>
80106dfa:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106dfd:	6a 00                	push   $0x0
80106dff:	68 fc 03 00 00       	push   $0x3fc
80106e04:	e8 7f ff ff ff       	call   80106d88 <outb>
80106e09:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e0c:	6a 01                	push   $0x1
80106e0e:	68 f9 03 00 00       	push   $0x3f9
80106e13:	e8 70 ff ff ff       	call   80106d88 <outb>
80106e18:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e1b:	68 fd 03 00 00       	push   $0x3fd
80106e20:	e8 46 ff ff ff       	call   80106d6b <inb>
80106e25:	83 c4 04             	add    $0x4,%esp
80106e28:	3c ff                	cmp    $0xff,%al
80106e2a:	74 61                	je     80106e8d <uartinit+0xe4>
    return;
  uart = 1;
80106e2c:	c7 05 f8 a6 11 80 01 	movl   $0x1,0x8011a6f8
80106e33:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e36:	68 fa 03 00 00       	push   $0x3fa
80106e3b:	e8 2b ff ff ff       	call   80106d6b <inb>
80106e40:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106e43:	68 f8 03 00 00       	push   $0x3f8
80106e48:	e8 1e ff ff ff       	call   80106d6b <inb>
80106e4d:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106e50:	83 ec 08             	sub    $0x8,%esp
80106e53:	6a 00                	push   $0x0
80106e55:	6a 04                	push   $0x4
80106e57:	e8 b6 bc ff ff       	call   80102b12 <ioapicenable>
80106e5c:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e5f:	c7 45 f4 84 b0 10 80 	movl   $0x8010b084,-0xc(%ebp)
80106e66:	eb 19                	jmp    80106e81 <uartinit+0xd8>
    uartputc(*p);
80106e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e6b:	0f b6 00             	movzbl (%eax),%eax
80106e6e:	0f be c0             	movsbl %al,%eax
80106e71:	83 ec 0c             	sub    $0xc,%esp
80106e74:	50                   	push   %eax
80106e75:	e8 16 00 00 00       	call   80106e90 <uartputc>
80106e7a:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106e7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e84:	0f b6 00             	movzbl (%eax),%eax
80106e87:	84 c0                	test   %al,%al
80106e89:	75 dd                	jne    80106e68 <uartinit+0xbf>
80106e8b:	eb 01                	jmp    80106e8e <uartinit+0xe5>
    return;
80106e8d:	90                   	nop
}
80106e8e:	c9                   	leave  
80106e8f:	c3                   	ret    

80106e90 <uartputc>:

void
uartputc(int c)
{
80106e90:	55                   	push   %ebp
80106e91:	89 e5                	mov    %esp,%ebp
80106e93:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106e96:	a1 f8 a6 11 80       	mov    0x8011a6f8,%eax
80106e9b:	85 c0                	test   %eax,%eax
80106e9d:	74 53                	je     80106ef2 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ea6:	eb 11                	jmp    80106eb9 <uartputc+0x29>
    microdelay(10);
80106ea8:	83 ec 0c             	sub    $0xc,%esp
80106eab:	6a 0a                	push   $0xa
80106ead:	e8 69 c1 ff ff       	call   8010301b <microdelay>
80106eb2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106eb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106eb9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ebd:	7f 1a                	jg     80106ed9 <uartputc+0x49>
80106ebf:	83 ec 0c             	sub    $0xc,%esp
80106ec2:	68 fd 03 00 00       	push   $0x3fd
80106ec7:	e8 9f fe ff ff       	call   80106d6b <inb>
80106ecc:	83 c4 10             	add    $0x10,%esp
80106ecf:	0f b6 c0             	movzbl %al,%eax
80106ed2:	83 e0 20             	and    $0x20,%eax
80106ed5:	85 c0                	test   %eax,%eax
80106ed7:	74 cf                	je     80106ea8 <uartputc+0x18>
  outb(COM1+0, c);
80106ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80106edc:	0f b6 c0             	movzbl %al,%eax
80106edf:	83 ec 08             	sub    $0x8,%esp
80106ee2:	50                   	push   %eax
80106ee3:	68 f8 03 00 00       	push   $0x3f8
80106ee8:	e8 9b fe ff ff       	call   80106d88 <outb>
80106eed:	83 c4 10             	add    $0x10,%esp
80106ef0:	eb 01                	jmp    80106ef3 <uartputc+0x63>
    return;
80106ef2:	90                   	nop
}
80106ef3:	c9                   	leave  
80106ef4:	c3                   	ret    

80106ef5 <uartgetc>:

static int
uartgetc(void)
{
80106ef5:	55                   	push   %ebp
80106ef6:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106ef8:	a1 f8 a6 11 80       	mov    0x8011a6f8,%eax
80106efd:	85 c0                	test   %eax,%eax
80106eff:	75 07                	jne    80106f08 <uartgetc+0x13>
    return -1;
80106f01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f06:	eb 2e                	jmp    80106f36 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106f08:	68 fd 03 00 00       	push   $0x3fd
80106f0d:	e8 59 fe ff ff       	call   80106d6b <inb>
80106f12:	83 c4 04             	add    $0x4,%esp
80106f15:	0f b6 c0             	movzbl %al,%eax
80106f18:	83 e0 01             	and    $0x1,%eax
80106f1b:	85 c0                	test   %eax,%eax
80106f1d:	75 07                	jne    80106f26 <uartgetc+0x31>
    return -1;
80106f1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f24:	eb 10                	jmp    80106f36 <uartgetc+0x41>
  return inb(COM1+0);
80106f26:	68 f8 03 00 00       	push   $0x3f8
80106f2b:	e8 3b fe ff ff       	call   80106d6b <inb>
80106f30:	83 c4 04             	add    $0x4,%esp
80106f33:	0f b6 c0             	movzbl %al,%eax
}
80106f36:	c9                   	leave  
80106f37:	c3                   	ret    

80106f38 <uartintr>:

void
uartintr(void)
{
80106f38:	55                   	push   %ebp
80106f39:	89 e5                	mov    %esp,%ebp
80106f3b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106f3e:	83 ec 0c             	sub    $0xc,%esp
80106f41:	68 f5 6e 10 80       	push   $0x80106ef5
80106f46:	e8 8b 98 ff ff       	call   801007d6 <consoleintr>
80106f4b:	83 c4 10             	add    $0x10,%esp
}
80106f4e:	90                   	nop
80106f4f:	c9                   	leave  
80106f50:	c3                   	ret    

80106f51 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $0
80106f53:	6a 00                	push   $0x0
  jmp alltraps
80106f55:	e9 fa f7 ff ff       	jmp    80106754 <alltraps>

80106f5a <vector1>:
.globl vector1
vector1:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $1
80106f5c:	6a 01                	push   $0x1
  jmp alltraps
80106f5e:	e9 f1 f7 ff ff       	jmp    80106754 <alltraps>

80106f63 <vector2>:
.globl vector2
vector2:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $2
80106f65:	6a 02                	push   $0x2
  jmp alltraps
80106f67:	e9 e8 f7 ff ff       	jmp    80106754 <alltraps>

80106f6c <vector3>:
.globl vector3
vector3:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $3
80106f6e:	6a 03                	push   $0x3
  jmp alltraps
80106f70:	e9 df f7 ff ff       	jmp    80106754 <alltraps>

80106f75 <vector4>:
.globl vector4
vector4:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $4
80106f77:	6a 04                	push   $0x4
  jmp alltraps
80106f79:	e9 d6 f7 ff ff       	jmp    80106754 <alltraps>

80106f7e <vector5>:
.globl vector5
vector5:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $5
80106f80:	6a 05                	push   $0x5
  jmp alltraps
80106f82:	e9 cd f7 ff ff       	jmp    80106754 <alltraps>

80106f87 <vector6>:
.globl vector6
vector6:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $6
80106f89:	6a 06                	push   $0x6
  jmp alltraps
80106f8b:	e9 c4 f7 ff ff       	jmp    80106754 <alltraps>

80106f90 <vector7>:
.globl vector7
vector7:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $7
80106f92:	6a 07                	push   $0x7
  jmp alltraps
80106f94:	e9 bb f7 ff ff       	jmp    80106754 <alltraps>

80106f99 <vector8>:
.globl vector8
vector8:
  pushl $8
80106f99:	6a 08                	push   $0x8
  jmp alltraps
80106f9b:	e9 b4 f7 ff ff       	jmp    80106754 <alltraps>

80106fa0 <vector9>:
.globl vector9
vector9:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $9
80106fa2:	6a 09                	push   $0x9
  jmp alltraps
80106fa4:	e9 ab f7 ff ff       	jmp    80106754 <alltraps>

80106fa9 <vector10>:
.globl vector10
vector10:
  pushl $10
80106fa9:	6a 0a                	push   $0xa
  jmp alltraps
80106fab:	e9 a4 f7 ff ff       	jmp    80106754 <alltraps>

80106fb0 <vector11>:
.globl vector11
vector11:
  pushl $11
80106fb0:	6a 0b                	push   $0xb
  jmp alltraps
80106fb2:	e9 9d f7 ff ff       	jmp    80106754 <alltraps>

80106fb7 <vector12>:
.globl vector12
vector12:
  pushl $12
80106fb7:	6a 0c                	push   $0xc
  jmp alltraps
80106fb9:	e9 96 f7 ff ff       	jmp    80106754 <alltraps>

80106fbe <vector13>:
.globl vector13
vector13:
  pushl $13
80106fbe:	6a 0d                	push   $0xd
  jmp alltraps
80106fc0:	e9 8f f7 ff ff       	jmp    80106754 <alltraps>

80106fc5 <vector14>:
.globl vector14
vector14:
  pushl $14
80106fc5:	6a 0e                	push   $0xe
  jmp alltraps
80106fc7:	e9 88 f7 ff ff       	jmp    80106754 <alltraps>

80106fcc <vector15>:
.globl vector15
vector15:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $15
80106fce:	6a 0f                	push   $0xf
  jmp alltraps
80106fd0:	e9 7f f7 ff ff       	jmp    80106754 <alltraps>

80106fd5 <vector16>:
.globl vector16
vector16:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $16
80106fd7:	6a 10                	push   $0x10
  jmp alltraps
80106fd9:	e9 76 f7 ff ff       	jmp    80106754 <alltraps>

80106fde <vector17>:
.globl vector17
vector17:
  pushl $17
80106fde:	6a 11                	push   $0x11
  jmp alltraps
80106fe0:	e9 6f f7 ff ff       	jmp    80106754 <alltraps>

80106fe5 <vector18>:
.globl vector18
vector18:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $18
80106fe7:	6a 12                	push   $0x12
  jmp alltraps
80106fe9:	e9 66 f7 ff ff       	jmp    80106754 <alltraps>

80106fee <vector19>:
.globl vector19
vector19:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $19
80106ff0:	6a 13                	push   $0x13
  jmp alltraps
80106ff2:	e9 5d f7 ff ff       	jmp    80106754 <alltraps>

80106ff7 <vector20>:
.globl vector20
vector20:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $20
80106ff9:	6a 14                	push   $0x14
  jmp alltraps
80106ffb:	e9 54 f7 ff ff       	jmp    80106754 <alltraps>

80107000 <vector21>:
.globl vector21
vector21:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $21
80107002:	6a 15                	push   $0x15
  jmp alltraps
80107004:	e9 4b f7 ff ff       	jmp    80106754 <alltraps>

80107009 <vector22>:
.globl vector22
vector22:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $22
8010700b:	6a 16                	push   $0x16
  jmp alltraps
8010700d:	e9 42 f7 ff ff       	jmp    80106754 <alltraps>

80107012 <vector23>:
.globl vector23
vector23:
  pushl $0
80107012:	6a 00                	push   $0x0
  pushl $23
80107014:	6a 17                	push   $0x17
  jmp alltraps
80107016:	e9 39 f7 ff ff       	jmp    80106754 <alltraps>

8010701b <vector24>:
.globl vector24
vector24:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $24
8010701d:	6a 18                	push   $0x18
  jmp alltraps
8010701f:	e9 30 f7 ff ff       	jmp    80106754 <alltraps>

80107024 <vector25>:
.globl vector25
vector25:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $25
80107026:	6a 19                	push   $0x19
  jmp alltraps
80107028:	e9 27 f7 ff ff       	jmp    80106754 <alltraps>

8010702d <vector26>:
.globl vector26
vector26:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $26
8010702f:	6a 1a                	push   $0x1a
  jmp alltraps
80107031:	e9 1e f7 ff ff       	jmp    80106754 <alltraps>

80107036 <vector27>:
.globl vector27
vector27:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $27
80107038:	6a 1b                	push   $0x1b
  jmp alltraps
8010703a:	e9 15 f7 ff ff       	jmp    80106754 <alltraps>

8010703f <vector28>:
.globl vector28
vector28:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $28
80107041:	6a 1c                	push   $0x1c
  jmp alltraps
80107043:	e9 0c f7 ff ff       	jmp    80106754 <alltraps>

80107048 <vector29>:
.globl vector29
vector29:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $29
8010704a:	6a 1d                	push   $0x1d
  jmp alltraps
8010704c:	e9 03 f7 ff ff       	jmp    80106754 <alltraps>

80107051 <vector30>:
.globl vector30
vector30:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $30
80107053:	6a 1e                	push   $0x1e
  jmp alltraps
80107055:	e9 fa f6 ff ff       	jmp    80106754 <alltraps>

8010705a <vector31>:
.globl vector31
vector31:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $31
8010705c:	6a 1f                	push   $0x1f
  jmp alltraps
8010705e:	e9 f1 f6 ff ff       	jmp    80106754 <alltraps>

80107063 <vector32>:
.globl vector32
vector32:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $32
80107065:	6a 20                	push   $0x20
  jmp alltraps
80107067:	e9 e8 f6 ff ff       	jmp    80106754 <alltraps>

8010706c <vector33>:
.globl vector33
vector33:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $33
8010706e:	6a 21                	push   $0x21
  jmp alltraps
80107070:	e9 df f6 ff ff       	jmp    80106754 <alltraps>

80107075 <vector34>:
.globl vector34
vector34:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $34
80107077:	6a 22                	push   $0x22
  jmp alltraps
80107079:	e9 d6 f6 ff ff       	jmp    80106754 <alltraps>

8010707e <vector35>:
.globl vector35
vector35:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $35
80107080:	6a 23                	push   $0x23
  jmp alltraps
80107082:	e9 cd f6 ff ff       	jmp    80106754 <alltraps>

80107087 <vector36>:
.globl vector36
vector36:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $36
80107089:	6a 24                	push   $0x24
  jmp alltraps
8010708b:	e9 c4 f6 ff ff       	jmp    80106754 <alltraps>

80107090 <vector37>:
.globl vector37
vector37:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $37
80107092:	6a 25                	push   $0x25
  jmp alltraps
80107094:	e9 bb f6 ff ff       	jmp    80106754 <alltraps>

80107099 <vector38>:
.globl vector38
vector38:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $38
8010709b:	6a 26                	push   $0x26
  jmp alltraps
8010709d:	e9 b2 f6 ff ff       	jmp    80106754 <alltraps>

801070a2 <vector39>:
.globl vector39
vector39:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $39
801070a4:	6a 27                	push   $0x27
  jmp alltraps
801070a6:	e9 a9 f6 ff ff       	jmp    80106754 <alltraps>

801070ab <vector40>:
.globl vector40
vector40:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $40
801070ad:	6a 28                	push   $0x28
  jmp alltraps
801070af:	e9 a0 f6 ff ff       	jmp    80106754 <alltraps>

801070b4 <vector41>:
.globl vector41
vector41:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $41
801070b6:	6a 29                	push   $0x29
  jmp alltraps
801070b8:	e9 97 f6 ff ff       	jmp    80106754 <alltraps>

801070bd <vector42>:
.globl vector42
vector42:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $42
801070bf:	6a 2a                	push   $0x2a
  jmp alltraps
801070c1:	e9 8e f6 ff ff       	jmp    80106754 <alltraps>

801070c6 <vector43>:
.globl vector43
vector43:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $43
801070c8:	6a 2b                	push   $0x2b
  jmp alltraps
801070ca:	e9 85 f6 ff ff       	jmp    80106754 <alltraps>

801070cf <vector44>:
.globl vector44
vector44:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $44
801070d1:	6a 2c                	push   $0x2c
  jmp alltraps
801070d3:	e9 7c f6 ff ff       	jmp    80106754 <alltraps>

801070d8 <vector45>:
.globl vector45
vector45:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $45
801070da:	6a 2d                	push   $0x2d
  jmp alltraps
801070dc:	e9 73 f6 ff ff       	jmp    80106754 <alltraps>

801070e1 <vector46>:
.globl vector46
vector46:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $46
801070e3:	6a 2e                	push   $0x2e
  jmp alltraps
801070e5:	e9 6a f6 ff ff       	jmp    80106754 <alltraps>

801070ea <vector47>:
.globl vector47
vector47:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $47
801070ec:	6a 2f                	push   $0x2f
  jmp alltraps
801070ee:	e9 61 f6 ff ff       	jmp    80106754 <alltraps>

801070f3 <vector48>:
.globl vector48
vector48:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $48
801070f5:	6a 30                	push   $0x30
  jmp alltraps
801070f7:	e9 58 f6 ff ff       	jmp    80106754 <alltraps>

801070fc <vector49>:
.globl vector49
vector49:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $49
801070fe:	6a 31                	push   $0x31
  jmp alltraps
80107100:	e9 4f f6 ff ff       	jmp    80106754 <alltraps>

80107105 <vector50>:
.globl vector50
vector50:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $50
80107107:	6a 32                	push   $0x32
  jmp alltraps
80107109:	e9 46 f6 ff ff       	jmp    80106754 <alltraps>

8010710e <vector51>:
.globl vector51
vector51:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $51
80107110:	6a 33                	push   $0x33
  jmp alltraps
80107112:	e9 3d f6 ff ff       	jmp    80106754 <alltraps>

80107117 <vector52>:
.globl vector52
vector52:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $52
80107119:	6a 34                	push   $0x34
  jmp alltraps
8010711b:	e9 34 f6 ff ff       	jmp    80106754 <alltraps>

80107120 <vector53>:
.globl vector53
vector53:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $53
80107122:	6a 35                	push   $0x35
  jmp alltraps
80107124:	e9 2b f6 ff ff       	jmp    80106754 <alltraps>

80107129 <vector54>:
.globl vector54
vector54:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $54
8010712b:	6a 36                	push   $0x36
  jmp alltraps
8010712d:	e9 22 f6 ff ff       	jmp    80106754 <alltraps>

80107132 <vector55>:
.globl vector55
vector55:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $55
80107134:	6a 37                	push   $0x37
  jmp alltraps
80107136:	e9 19 f6 ff ff       	jmp    80106754 <alltraps>

8010713b <vector56>:
.globl vector56
vector56:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $56
8010713d:	6a 38                	push   $0x38
  jmp alltraps
8010713f:	e9 10 f6 ff ff       	jmp    80106754 <alltraps>

80107144 <vector57>:
.globl vector57
vector57:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $57
80107146:	6a 39                	push   $0x39
  jmp alltraps
80107148:	e9 07 f6 ff ff       	jmp    80106754 <alltraps>

8010714d <vector58>:
.globl vector58
vector58:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $58
8010714f:	6a 3a                	push   $0x3a
  jmp alltraps
80107151:	e9 fe f5 ff ff       	jmp    80106754 <alltraps>

80107156 <vector59>:
.globl vector59
vector59:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $59
80107158:	6a 3b                	push   $0x3b
  jmp alltraps
8010715a:	e9 f5 f5 ff ff       	jmp    80106754 <alltraps>

8010715f <vector60>:
.globl vector60
vector60:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $60
80107161:	6a 3c                	push   $0x3c
  jmp alltraps
80107163:	e9 ec f5 ff ff       	jmp    80106754 <alltraps>

80107168 <vector61>:
.globl vector61
vector61:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $61
8010716a:	6a 3d                	push   $0x3d
  jmp alltraps
8010716c:	e9 e3 f5 ff ff       	jmp    80106754 <alltraps>

80107171 <vector62>:
.globl vector62
vector62:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $62
80107173:	6a 3e                	push   $0x3e
  jmp alltraps
80107175:	e9 da f5 ff ff       	jmp    80106754 <alltraps>

8010717a <vector63>:
.globl vector63
vector63:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $63
8010717c:	6a 3f                	push   $0x3f
  jmp alltraps
8010717e:	e9 d1 f5 ff ff       	jmp    80106754 <alltraps>

80107183 <vector64>:
.globl vector64
vector64:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $64
80107185:	6a 40                	push   $0x40
  jmp alltraps
80107187:	e9 c8 f5 ff ff       	jmp    80106754 <alltraps>

8010718c <vector65>:
.globl vector65
vector65:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $65
8010718e:	6a 41                	push   $0x41
  jmp alltraps
80107190:	e9 bf f5 ff ff       	jmp    80106754 <alltraps>

80107195 <vector66>:
.globl vector66
vector66:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $66
80107197:	6a 42                	push   $0x42
  jmp alltraps
80107199:	e9 b6 f5 ff ff       	jmp    80106754 <alltraps>

8010719e <vector67>:
.globl vector67
vector67:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $67
801071a0:	6a 43                	push   $0x43
  jmp alltraps
801071a2:	e9 ad f5 ff ff       	jmp    80106754 <alltraps>

801071a7 <vector68>:
.globl vector68
vector68:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $68
801071a9:	6a 44                	push   $0x44
  jmp alltraps
801071ab:	e9 a4 f5 ff ff       	jmp    80106754 <alltraps>

801071b0 <vector69>:
.globl vector69
vector69:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $69
801071b2:	6a 45                	push   $0x45
  jmp alltraps
801071b4:	e9 9b f5 ff ff       	jmp    80106754 <alltraps>

801071b9 <vector70>:
.globl vector70
vector70:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $70
801071bb:	6a 46                	push   $0x46
  jmp alltraps
801071bd:	e9 92 f5 ff ff       	jmp    80106754 <alltraps>

801071c2 <vector71>:
.globl vector71
vector71:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $71
801071c4:	6a 47                	push   $0x47
  jmp alltraps
801071c6:	e9 89 f5 ff ff       	jmp    80106754 <alltraps>

801071cb <vector72>:
.globl vector72
vector72:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $72
801071cd:	6a 48                	push   $0x48
  jmp alltraps
801071cf:	e9 80 f5 ff ff       	jmp    80106754 <alltraps>

801071d4 <vector73>:
.globl vector73
vector73:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $73
801071d6:	6a 49                	push   $0x49
  jmp alltraps
801071d8:	e9 77 f5 ff ff       	jmp    80106754 <alltraps>

801071dd <vector74>:
.globl vector74
vector74:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $74
801071df:	6a 4a                	push   $0x4a
  jmp alltraps
801071e1:	e9 6e f5 ff ff       	jmp    80106754 <alltraps>

801071e6 <vector75>:
.globl vector75
vector75:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $75
801071e8:	6a 4b                	push   $0x4b
  jmp alltraps
801071ea:	e9 65 f5 ff ff       	jmp    80106754 <alltraps>

801071ef <vector76>:
.globl vector76
vector76:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $76
801071f1:	6a 4c                	push   $0x4c
  jmp alltraps
801071f3:	e9 5c f5 ff ff       	jmp    80106754 <alltraps>

801071f8 <vector77>:
.globl vector77
vector77:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $77
801071fa:	6a 4d                	push   $0x4d
  jmp alltraps
801071fc:	e9 53 f5 ff ff       	jmp    80106754 <alltraps>

80107201 <vector78>:
.globl vector78
vector78:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $78
80107203:	6a 4e                	push   $0x4e
  jmp alltraps
80107205:	e9 4a f5 ff ff       	jmp    80106754 <alltraps>

8010720a <vector79>:
.globl vector79
vector79:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $79
8010720c:	6a 4f                	push   $0x4f
  jmp alltraps
8010720e:	e9 41 f5 ff ff       	jmp    80106754 <alltraps>

80107213 <vector80>:
.globl vector80
vector80:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $80
80107215:	6a 50                	push   $0x50
  jmp alltraps
80107217:	e9 38 f5 ff ff       	jmp    80106754 <alltraps>

8010721c <vector81>:
.globl vector81
vector81:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $81
8010721e:	6a 51                	push   $0x51
  jmp alltraps
80107220:	e9 2f f5 ff ff       	jmp    80106754 <alltraps>

80107225 <vector82>:
.globl vector82
vector82:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $82
80107227:	6a 52                	push   $0x52
  jmp alltraps
80107229:	e9 26 f5 ff ff       	jmp    80106754 <alltraps>

8010722e <vector83>:
.globl vector83
vector83:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $83
80107230:	6a 53                	push   $0x53
  jmp alltraps
80107232:	e9 1d f5 ff ff       	jmp    80106754 <alltraps>

80107237 <vector84>:
.globl vector84
vector84:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $84
80107239:	6a 54                	push   $0x54
  jmp alltraps
8010723b:	e9 14 f5 ff ff       	jmp    80106754 <alltraps>

80107240 <vector85>:
.globl vector85
vector85:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $85
80107242:	6a 55                	push   $0x55
  jmp alltraps
80107244:	e9 0b f5 ff ff       	jmp    80106754 <alltraps>

80107249 <vector86>:
.globl vector86
vector86:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $86
8010724b:	6a 56                	push   $0x56
  jmp alltraps
8010724d:	e9 02 f5 ff ff       	jmp    80106754 <alltraps>

80107252 <vector87>:
.globl vector87
vector87:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $87
80107254:	6a 57                	push   $0x57
  jmp alltraps
80107256:	e9 f9 f4 ff ff       	jmp    80106754 <alltraps>

8010725b <vector88>:
.globl vector88
vector88:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $88
8010725d:	6a 58                	push   $0x58
  jmp alltraps
8010725f:	e9 f0 f4 ff ff       	jmp    80106754 <alltraps>

80107264 <vector89>:
.globl vector89
vector89:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $89
80107266:	6a 59                	push   $0x59
  jmp alltraps
80107268:	e9 e7 f4 ff ff       	jmp    80106754 <alltraps>

8010726d <vector90>:
.globl vector90
vector90:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $90
8010726f:	6a 5a                	push   $0x5a
  jmp alltraps
80107271:	e9 de f4 ff ff       	jmp    80106754 <alltraps>

80107276 <vector91>:
.globl vector91
vector91:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $91
80107278:	6a 5b                	push   $0x5b
  jmp alltraps
8010727a:	e9 d5 f4 ff ff       	jmp    80106754 <alltraps>

8010727f <vector92>:
.globl vector92
vector92:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $92
80107281:	6a 5c                	push   $0x5c
  jmp alltraps
80107283:	e9 cc f4 ff ff       	jmp    80106754 <alltraps>

80107288 <vector93>:
.globl vector93
vector93:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $93
8010728a:	6a 5d                	push   $0x5d
  jmp alltraps
8010728c:	e9 c3 f4 ff ff       	jmp    80106754 <alltraps>

80107291 <vector94>:
.globl vector94
vector94:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $94
80107293:	6a 5e                	push   $0x5e
  jmp alltraps
80107295:	e9 ba f4 ff ff       	jmp    80106754 <alltraps>

8010729a <vector95>:
.globl vector95
vector95:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $95
8010729c:	6a 5f                	push   $0x5f
  jmp alltraps
8010729e:	e9 b1 f4 ff ff       	jmp    80106754 <alltraps>

801072a3 <vector96>:
.globl vector96
vector96:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $96
801072a5:	6a 60                	push   $0x60
  jmp alltraps
801072a7:	e9 a8 f4 ff ff       	jmp    80106754 <alltraps>

801072ac <vector97>:
.globl vector97
vector97:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $97
801072ae:	6a 61                	push   $0x61
  jmp alltraps
801072b0:	e9 9f f4 ff ff       	jmp    80106754 <alltraps>

801072b5 <vector98>:
.globl vector98
vector98:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $98
801072b7:	6a 62                	push   $0x62
  jmp alltraps
801072b9:	e9 96 f4 ff ff       	jmp    80106754 <alltraps>

801072be <vector99>:
.globl vector99
vector99:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $99
801072c0:	6a 63                	push   $0x63
  jmp alltraps
801072c2:	e9 8d f4 ff ff       	jmp    80106754 <alltraps>

801072c7 <vector100>:
.globl vector100
vector100:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $100
801072c9:	6a 64                	push   $0x64
  jmp alltraps
801072cb:	e9 84 f4 ff ff       	jmp    80106754 <alltraps>

801072d0 <vector101>:
.globl vector101
vector101:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $101
801072d2:	6a 65                	push   $0x65
  jmp alltraps
801072d4:	e9 7b f4 ff ff       	jmp    80106754 <alltraps>

801072d9 <vector102>:
.globl vector102
vector102:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $102
801072db:	6a 66                	push   $0x66
  jmp alltraps
801072dd:	e9 72 f4 ff ff       	jmp    80106754 <alltraps>

801072e2 <vector103>:
.globl vector103
vector103:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $103
801072e4:	6a 67                	push   $0x67
  jmp alltraps
801072e6:	e9 69 f4 ff ff       	jmp    80106754 <alltraps>

801072eb <vector104>:
.globl vector104
vector104:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $104
801072ed:	6a 68                	push   $0x68
  jmp alltraps
801072ef:	e9 60 f4 ff ff       	jmp    80106754 <alltraps>

801072f4 <vector105>:
.globl vector105
vector105:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $105
801072f6:	6a 69                	push   $0x69
  jmp alltraps
801072f8:	e9 57 f4 ff ff       	jmp    80106754 <alltraps>

801072fd <vector106>:
.globl vector106
vector106:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $106
801072ff:	6a 6a                	push   $0x6a
  jmp alltraps
80107301:	e9 4e f4 ff ff       	jmp    80106754 <alltraps>

80107306 <vector107>:
.globl vector107
vector107:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $107
80107308:	6a 6b                	push   $0x6b
  jmp alltraps
8010730a:	e9 45 f4 ff ff       	jmp    80106754 <alltraps>

8010730f <vector108>:
.globl vector108
vector108:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $108
80107311:	6a 6c                	push   $0x6c
  jmp alltraps
80107313:	e9 3c f4 ff ff       	jmp    80106754 <alltraps>

80107318 <vector109>:
.globl vector109
vector109:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $109
8010731a:	6a 6d                	push   $0x6d
  jmp alltraps
8010731c:	e9 33 f4 ff ff       	jmp    80106754 <alltraps>

80107321 <vector110>:
.globl vector110
vector110:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $110
80107323:	6a 6e                	push   $0x6e
  jmp alltraps
80107325:	e9 2a f4 ff ff       	jmp    80106754 <alltraps>

8010732a <vector111>:
.globl vector111
vector111:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $111
8010732c:	6a 6f                	push   $0x6f
  jmp alltraps
8010732e:	e9 21 f4 ff ff       	jmp    80106754 <alltraps>

80107333 <vector112>:
.globl vector112
vector112:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $112
80107335:	6a 70                	push   $0x70
  jmp alltraps
80107337:	e9 18 f4 ff ff       	jmp    80106754 <alltraps>

8010733c <vector113>:
.globl vector113
vector113:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $113
8010733e:	6a 71                	push   $0x71
  jmp alltraps
80107340:	e9 0f f4 ff ff       	jmp    80106754 <alltraps>

80107345 <vector114>:
.globl vector114
vector114:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $114
80107347:	6a 72                	push   $0x72
  jmp alltraps
80107349:	e9 06 f4 ff ff       	jmp    80106754 <alltraps>

8010734e <vector115>:
.globl vector115
vector115:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $115
80107350:	6a 73                	push   $0x73
  jmp alltraps
80107352:	e9 fd f3 ff ff       	jmp    80106754 <alltraps>

80107357 <vector116>:
.globl vector116
vector116:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $116
80107359:	6a 74                	push   $0x74
  jmp alltraps
8010735b:	e9 f4 f3 ff ff       	jmp    80106754 <alltraps>

80107360 <vector117>:
.globl vector117
vector117:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $117
80107362:	6a 75                	push   $0x75
  jmp alltraps
80107364:	e9 eb f3 ff ff       	jmp    80106754 <alltraps>

80107369 <vector118>:
.globl vector118
vector118:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $118
8010736b:	6a 76                	push   $0x76
  jmp alltraps
8010736d:	e9 e2 f3 ff ff       	jmp    80106754 <alltraps>

80107372 <vector119>:
.globl vector119
vector119:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $119
80107374:	6a 77                	push   $0x77
  jmp alltraps
80107376:	e9 d9 f3 ff ff       	jmp    80106754 <alltraps>

8010737b <vector120>:
.globl vector120
vector120:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $120
8010737d:	6a 78                	push   $0x78
  jmp alltraps
8010737f:	e9 d0 f3 ff ff       	jmp    80106754 <alltraps>

80107384 <vector121>:
.globl vector121
vector121:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $121
80107386:	6a 79                	push   $0x79
  jmp alltraps
80107388:	e9 c7 f3 ff ff       	jmp    80106754 <alltraps>

8010738d <vector122>:
.globl vector122
vector122:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $122
8010738f:	6a 7a                	push   $0x7a
  jmp alltraps
80107391:	e9 be f3 ff ff       	jmp    80106754 <alltraps>

80107396 <vector123>:
.globl vector123
vector123:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $123
80107398:	6a 7b                	push   $0x7b
  jmp alltraps
8010739a:	e9 b5 f3 ff ff       	jmp    80106754 <alltraps>

8010739f <vector124>:
.globl vector124
vector124:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $124
801073a1:	6a 7c                	push   $0x7c
  jmp alltraps
801073a3:	e9 ac f3 ff ff       	jmp    80106754 <alltraps>

801073a8 <vector125>:
.globl vector125
vector125:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $125
801073aa:	6a 7d                	push   $0x7d
  jmp alltraps
801073ac:	e9 a3 f3 ff ff       	jmp    80106754 <alltraps>

801073b1 <vector126>:
.globl vector126
vector126:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $126
801073b3:	6a 7e                	push   $0x7e
  jmp alltraps
801073b5:	e9 9a f3 ff ff       	jmp    80106754 <alltraps>

801073ba <vector127>:
.globl vector127
vector127:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $127
801073bc:	6a 7f                	push   $0x7f
  jmp alltraps
801073be:	e9 91 f3 ff ff       	jmp    80106754 <alltraps>

801073c3 <vector128>:
.globl vector128
vector128:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $128
801073c5:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073ca:	e9 85 f3 ff ff       	jmp    80106754 <alltraps>

801073cf <vector129>:
.globl vector129
vector129:
  pushl $0
801073cf:	6a 00                	push   $0x0
  pushl $129
801073d1:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073d6:	e9 79 f3 ff ff       	jmp    80106754 <alltraps>

801073db <vector130>:
.globl vector130
vector130:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $130
801073dd:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073e2:	e9 6d f3 ff ff       	jmp    80106754 <alltraps>

801073e7 <vector131>:
.globl vector131
vector131:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $131
801073e9:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801073ee:	e9 61 f3 ff ff       	jmp    80106754 <alltraps>

801073f3 <vector132>:
.globl vector132
vector132:
  pushl $0
801073f3:	6a 00                	push   $0x0
  pushl $132
801073f5:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801073fa:	e9 55 f3 ff ff       	jmp    80106754 <alltraps>

801073ff <vector133>:
.globl vector133
vector133:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $133
80107401:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107406:	e9 49 f3 ff ff       	jmp    80106754 <alltraps>

8010740b <vector134>:
.globl vector134
vector134:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $134
8010740d:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107412:	e9 3d f3 ff ff       	jmp    80106754 <alltraps>

80107417 <vector135>:
.globl vector135
vector135:
  pushl $0
80107417:	6a 00                	push   $0x0
  pushl $135
80107419:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010741e:	e9 31 f3 ff ff       	jmp    80106754 <alltraps>

80107423 <vector136>:
.globl vector136
vector136:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $136
80107425:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010742a:	e9 25 f3 ff ff       	jmp    80106754 <alltraps>

8010742f <vector137>:
.globl vector137
vector137:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $137
80107431:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107436:	e9 19 f3 ff ff       	jmp    80106754 <alltraps>

8010743b <vector138>:
.globl vector138
vector138:
  pushl $0
8010743b:	6a 00                	push   $0x0
  pushl $138
8010743d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107442:	e9 0d f3 ff ff       	jmp    80106754 <alltraps>

80107447 <vector139>:
.globl vector139
vector139:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $139
80107449:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010744e:	e9 01 f3 ff ff       	jmp    80106754 <alltraps>

80107453 <vector140>:
.globl vector140
vector140:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $140
80107455:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010745a:	e9 f5 f2 ff ff       	jmp    80106754 <alltraps>

8010745f <vector141>:
.globl vector141
vector141:
  pushl $0
8010745f:	6a 00                	push   $0x0
  pushl $141
80107461:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107466:	e9 e9 f2 ff ff       	jmp    80106754 <alltraps>

8010746b <vector142>:
.globl vector142
vector142:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $142
8010746d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107472:	e9 dd f2 ff ff       	jmp    80106754 <alltraps>

80107477 <vector143>:
.globl vector143
vector143:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $143
80107479:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010747e:	e9 d1 f2 ff ff       	jmp    80106754 <alltraps>

80107483 <vector144>:
.globl vector144
vector144:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $144
80107485:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010748a:	e9 c5 f2 ff ff       	jmp    80106754 <alltraps>

8010748f <vector145>:
.globl vector145
vector145:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $145
80107491:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107496:	e9 b9 f2 ff ff       	jmp    80106754 <alltraps>

8010749b <vector146>:
.globl vector146
vector146:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $146
8010749d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074a2:	e9 ad f2 ff ff       	jmp    80106754 <alltraps>

801074a7 <vector147>:
.globl vector147
vector147:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $147
801074a9:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074ae:	e9 a1 f2 ff ff       	jmp    80106754 <alltraps>

801074b3 <vector148>:
.globl vector148
vector148:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $148
801074b5:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074ba:	e9 95 f2 ff ff       	jmp    80106754 <alltraps>

801074bf <vector149>:
.globl vector149
vector149:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $149
801074c1:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074c6:	e9 89 f2 ff ff       	jmp    80106754 <alltraps>

801074cb <vector150>:
.globl vector150
vector150:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $150
801074cd:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074d2:	e9 7d f2 ff ff       	jmp    80106754 <alltraps>

801074d7 <vector151>:
.globl vector151
vector151:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $151
801074d9:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074de:	e9 71 f2 ff ff       	jmp    80106754 <alltraps>

801074e3 <vector152>:
.globl vector152
vector152:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $152
801074e5:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801074ea:	e9 65 f2 ff ff       	jmp    80106754 <alltraps>

801074ef <vector153>:
.globl vector153
vector153:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $153
801074f1:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801074f6:	e9 59 f2 ff ff       	jmp    80106754 <alltraps>

801074fb <vector154>:
.globl vector154
vector154:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $154
801074fd:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107502:	e9 4d f2 ff ff       	jmp    80106754 <alltraps>

80107507 <vector155>:
.globl vector155
vector155:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $155
80107509:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010750e:	e9 41 f2 ff ff       	jmp    80106754 <alltraps>

80107513 <vector156>:
.globl vector156
vector156:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $156
80107515:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010751a:	e9 35 f2 ff ff       	jmp    80106754 <alltraps>

8010751f <vector157>:
.globl vector157
vector157:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $157
80107521:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107526:	e9 29 f2 ff ff       	jmp    80106754 <alltraps>

8010752b <vector158>:
.globl vector158
vector158:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $158
8010752d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107532:	e9 1d f2 ff ff       	jmp    80106754 <alltraps>

80107537 <vector159>:
.globl vector159
vector159:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $159
80107539:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010753e:	e9 11 f2 ff ff       	jmp    80106754 <alltraps>

80107543 <vector160>:
.globl vector160
vector160:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $160
80107545:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010754a:	e9 05 f2 ff ff       	jmp    80106754 <alltraps>

8010754f <vector161>:
.globl vector161
vector161:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $161
80107551:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107556:	e9 f9 f1 ff ff       	jmp    80106754 <alltraps>

8010755b <vector162>:
.globl vector162
vector162:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $162
8010755d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107562:	e9 ed f1 ff ff       	jmp    80106754 <alltraps>

80107567 <vector163>:
.globl vector163
vector163:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $163
80107569:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010756e:	e9 e1 f1 ff ff       	jmp    80106754 <alltraps>

80107573 <vector164>:
.globl vector164
vector164:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $164
80107575:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010757a:	e9 d5 f1 ff ff       	jmp    80106754 <alltraps>

8010757f <vector165>:
.globl vector165
vector165:
  pushl $0
8010757f:	6a 00                	push   $0x0
  pushl $165
80107581:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107586:	e9 c9 f1 ff ff       	jmp    80106754 <alltraps>

8010758b <vector166>:
.globl vector166
vector166:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $166
8010758d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107592:	e9 bd f1 ff ff       	jmp    80106754 <alltraps>

80107597 <vector167>:
.globl vector167
vector167:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $167
80107599:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010759e:	e9 b1 f1 ff ff       	jmp    80106754 <alltraps>

801075a3 <vector168>:
.globl vector168
vector168:
  pushl $0
801075a3:	6a 00                	push   $0x0
  pushl $168
801075a5:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075aa:	e9 a5 f1 ff ff       	jmp    80106754 <alltraps>

801075af <vector169>:
.globl vector169
vector169:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $169
801075b1:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075b6:	e9 99 f1 ff ff       	jmp    80106754 <alltraps>

801075bb <vector170>:
.globl vector170
vector170:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $170
801075bd:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075c2:	e9 8d f1 ff ff       	jmp    80106754 <alltraps>

801075c7 <vector171>:
.globl vector171
vector171:
  pushl $0
801075c7:	6a 00                	push   $0x0
  pushl $171
801075c9:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075ce:	e9 81 f1 ff ff       	jmp    80106754 <alltraps>

801075d3 <vector172>:
.globl vector172
vector172:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $172
801075d5:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075da:	e9 75 f1 ff ff       	jmp    80106754 <alltraps>

801075df <vector173>:
.globl vector173
vector173:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $173
801075e1:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075e6:	e9 69 f1 ff ff       	jmp    80106754 <alltraps>

801075eb <vector174>:
.globl vector174
vector174:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $174
801075ed:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801075f2:	e9 5d f1 ff ff       	jmp    80106754 <alltraps>

801075f7 <vector175>:
.globl vector175
vector175:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $175
801075f9:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801075fe:	e9 51 f1 ff ff       	jmp    80106754 <alltraps>

80107603 <vector176>:
.globl vector176
vector176:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $176
80107605:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010760a:	e9 45 f1 ff ff       	jmp    80106754 <alltraps>

8010760f <vector177>:
.globl vector177
vector177:
  pushl $0
8010760f:	6a 00                	push   $0x0
  pushl $177
80107611:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107616:	e9 39 f1 ff ff       	jmp    80106754 <alltraps>

8010761b <vector178>:
.globl vector178
vector178:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $178
8010761d:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107622:	e9 2d f1 ff ff       	jmp    80106754 <alltraps>

80107627 <vector179>:
.globl vector179
vector179:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $179
80107629:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010762e:	e9 21 f1 ff ff       	jmp    80106754 <alltraps>

80107633 <vector180>:
.globl vector180
vector180:
  pushl $0
80107633:	6a 00                	push   $0x0
  pushl $180
80107635:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010763a:	e9 15 f1 ff ff       	jmp    80106754 <alltraps>

8010763f <vector181>:
.globl vector181
vector181:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $181
80107641:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107646:	e9 09 f1 ff ff       	jmp    80106754 <alltraps>

8010764b <vector182>:
.globl vector182
vector182:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $182
8010764d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107652:	e9 fd f0 ff ff       	jmp    80106754 <alltraps>

80107657 <vector183>:
.globl vector183
vector183:
  pushl $0
80107657:	6a 00                	push   $0x0
  pushl $183
80107659:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010765e:	e9 f1 f0 ff ff       	jmp    80106754 <alltraps>

80107663 <vector184>:
.globl vector184
vector184:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $184
80107665:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010766a:	e9 e5 f0 ff ff       	jmp    80106754 <alltraps>

8010766f <vector185>:
.globl vector185
vector185:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $185
80107671:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107676:	e9 d9 f0 ff ff       	jmp    80106754 <alltraps>

8010767b <vector186>:
.globl vector186
vector186:
  pushl $0
8010767b:	6a 00                	push   $0x0
  pushl $186
8010767d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107682:	e9 cd f0 ff ff       	jmp    80106754 <alltraps>

80107687 <vector187>:
.globl vector187
vector187:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $187
80107689:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010768e:	e9 c1 f0 ff ff       	jmp    80106754 <alltraps>

80107693 <vector188>:
.globl vector188
vector188:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $188
80107695:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010769a:	e9 b5 f0 ff ff       	jmp    80106754 <alltraps>

8010769f <vector189>:
.globl vector189
vector189:
  pushl $0
8010769f:	6a 00                	push   $0x0
  pushl $189
801076a1:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076a6:	e9 a9 f0 ff ff       	jmp    80106754 <alltraps>

801076ab <vector190>:
.globl vector190
vector190:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $190
801076ad:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076b2:	e9 9d f0 ff ff       	jmp    80106754 <alltraps>

801076b7 <vector191>:
.globl vector191
vector191:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $191
801076b9:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076be:	e9 91 f0 ff ff       	jmp    80106754 <alltraps>

801076c3 <vector192>:
.globl vector192
vector192:
  pushl $0
801076c3:	6a 00                	push   $0x0
  pushl $192
801076c5:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076ca:	e9 85 f0 ff ff       	jmp    80106754 <alltraps>

801076cf <vector193>:
.globl vector193
vector193:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $193
801076d1:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076d6:	e9 79 f0 ff ff       	jmp    80106754 <alltraps>

801076db <vector194>:
.globl vector194
vector194:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $194
801076dd:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076e2:	e9 6d f0 ff ff       	jmp    80106754 <alltraps>

801076e7 <vector195>:
.globl vector195
vector195:
  pushl $0
801076e7:	6a 00                	push   $0x0
  pushl $195
801076e9:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801076ee:	e9 61 f0 ff ff       	jmp    80106754 <alltraps>

801076f3 <vector196>:
.globl vector196
vector196:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $196
801076f5:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801076fa:	e9 55 f0 ff ff       	jmp    80106754 <alltraps>

801076ff <vector197>:
.globl vector197
vector197:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $197
80107701:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107706:	e9 49 f0 ff ff       	jmp    80106754 <alltraps>

8010770b <vector198>:
.globl vector198
vector198:
  pushl $0
8010770b:	6a 00                	push   $0x0
  pushl $198
8010770d:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107712:	e9 3d f0 ff ff       	jmp    80106754 <alltraps>

80107717 <vector199>:
.globl vector199
vector199:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $199
80107719:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010771e:	e9 31 f0 ff ff       	jmp    80106754 <alltraps>

80107723 <vector200>:
.globl vector200
vector200:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $200
80107725:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010772a:	e9 25 f0 ff ff       	jmp    80106754 <alltraps>

8010772f <vector201>:
.globl vector201
vector201:
  pushl $0
8010772f:	6a 00                	push   $0x0
  pushl $201
80107731:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107736:	e9 19 f0 ff ff       	jmp    80106754 <alltraps>

8010773b <vector202>:
.globl vector202
vector202:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $202
8010773d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107742:	e9 0d f0 ff ff       	jmp    80106754 <alltraps>

80107747 <vector203>:
.globl vector203
vector203:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $203
80107749:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010774e:	e9 01 f0 ff ff       	jmp    80106754 <alltraps>

80107753 <vector204>:
.globl vector204
vector204:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $204
80107755:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010775a:	e9 f5 ef ff ff       	jmp    80106754 <alltraps>

8010775f <vector205>:
.globl vector205
vector205:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $205
80107761:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107766:	e9 e9 ef ff ff       	jmp    80106754 <alltraps>

8010776b <vector206>:
.globl vector206
vector206:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $206
8010776d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107772:	e9 dd ef ff ff       	jmp    80106754 <alltraps>

80107777 <vector207>:
.globl vector207
vector207:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $207
80107779:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010777e:	e9 d1 ef ff ff       	jmp    80106754 <alltraps>

80107783 <vector208>:
.globl vector208
vector208:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $208
80107785:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010778a:	e9 c5 ef ff ff       	jmp    80106754 <alltraps>

8010778f <vector209>:
.globl vector209
vector209:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $209
80107791:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107796:	e9 b9 ef ff ff       	jmp    80106754 <alltraps>

8010779b <vector210>:
.globl vector210
vector210:
  pushl $0
8010779b:	6a 00                	push   $0x0
  pushl $210
8010779d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077a2:	e9 ad ef ff ff       	jmp    80106754 <alltraps>

801077a7 <vector211>:
.globl vector211
vector211:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $211
801077a9:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077ae:	e9 a1 ef ff ff       	jmp    80106754 <alltraps>

801077b3 <vector212>:
.globl vector212
vector212:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $212
801077b5:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077ba:	e9 95 ef ff ff       	jmp    80106754 <alltraps>

801077bf <vector213>:
.globl vector213
vector213:
  pushl $0
801077bf:	6a 00                	push   $0x0
  pushl $213
801077c1:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077c6:	e9 89 ef ff ff       	jmp    80106754 <alltraps>

801077cb <vector214>:
.globl vector214
vector214:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $214
801077cd:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077d2:	e9 7d ef ff ff       	jmp    80106754 <alltraps>

801077d7 <vector215>:
.globl vector215
vector215:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $215
801077d9:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077de:	e9 71 ef ff ff       	jmp    80106754 <alltraps>

801077e3 <vector216>:
.globl vector216
vector216:
  pushl $0
801077e3:	6a 00                	push   $0x0
  pushl $216
801077e5:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801077ea:	e9 65 ef ff ff       	jmp    80106754 <alltraps>

801077ef <vector217>:
.globl vector217
vector217:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $217
801077f1:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801077f6:	e9 59 ef ff ff       	jmp    80106754 <alltraps>

801077fb <vector218>:
.globl vector218
vector218:
  pushl $0
801077fb:	6a 00                	push   $0x0
  pushl $218
801077fd:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107802:	e9 4d ef ff ff       	jmp    80106754 <alltraps>

80107807 <vector219>:
.globl vector219
vector219:
  pushl $0
80107807:	6a 00                	push   $0x0
  pushl $219
80107809:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010780e:	e9 41 ef ff ff       	jmp    80106754 <alltraps>

80107813 <vector220>:
.globl vector220
vector220:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $220
80107815:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010781a:	e9 35 ef ff ff       	jmp    80106754 <alltraps>

8010781f <vector221>:
.globl vector221
vector221:
  pushl $0
8010781f:	6a 00                	push   $0x0
  pushl $221
80107821:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107826:	e9 29 ef ff ff       	jmp    80106754 <alltraps>

8010782b <vector222>:
.globl vector222
vector222:
  pushl $0
8010782b:	6a 00                	push   $0x0
  pushl $222
8010782d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107832:	e9 1d ef ff ff       	jmp    80106754 <alltraps>

80107837 <vector223>:
.globl vector223
vector223:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $223
80107839:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010783e:	e9 11 ef ff ff       	jmp    80106754 <alltraps>

80107843 <vector224>:
.globl vector224
vector224:
  pushl $0
80107843:	6a 00                	push   $0x0
  pushl $224
80107845:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010784a:	e9 05 ef ff ff       	jmp    80106754 <alltraps>

8010784f <vector225>:
.globl vector225
vector225:
  pushl $0
8010784f:	6a 00                	push   $0x0
  pushl $225
80107851:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107856:	e9 f9 ee ff ff       	jmp    80106754 <alltraps>

8010785b <vector226>:
.globl vector226
vector226:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $226
8010785d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107862:	e9 ed ee ff ff       	jmp    80106754 <alltraps>

80107867 <vector227>:
.globl vector227
vector227:
  pushl $0
80107867:	6a 00                	push   $0x0
  pushl $227
80107869:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010786e:	e9 e1 ee ff ff       	jmp    80106754 <alltraps>

80107873 <vector228>:
.globl vector228
vector228:
  pushl $0
80107873:	6a 00                	push   $0x0
  pushl $228
80107875:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010787a:	e9 d5 ee ff ff       	jmp    80106754 <alltraps>

8010787f <vector229>:
.globl vector229
vector229:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $229
80107881:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107886:	e9 c9 ee ff ff       	jmp    80106754 <alltraps>

8010788b <vector230>:
.globl vector230
vector230:
  pushl $0
8010788b:	6a 00                	push   $0x0
  pushl $230
8010788d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107892:	e9 bd ee ff ff       	jmp    80106754 <alltraps>

80107897 <vector231>:
.globl vector231
vector231:
  pushl $0
80107897:	6a 00                	push   $0x0
  pushl $231
80107899:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010789e:	e9 b1 ee ff ff       	jmp    80106754 <alltraps>

801078a3 <vector232>:
.globl vector232
vector232:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $232
801078a5:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078aa:	e9 a5 ee ff ff       	jmp    80106754 <alltraps>

801078af <vector233>:
.globl vector233
vector233:
  pushl $0
801078af:	6a 00                	push   $0x0
  pushl $233
801078b1:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078b6:	e9 99 ee ff ff       	jmp    80106754 <alltraps>

801078bb <vector234>:
.globl vector234
vector234:
  pushl $0
801078bb:	6a 00                	push   $0x0
  pushl $234
801078bd:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078c2:	e9 8d ee ff ff       	jmp    80106754 <alltraps>

801078c7 <vector235>:
.globl vector235
vector235:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $235
801078c9:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078ce:	e9 81 ee ff ff       	jmp    80106754 <alltraps>

801078d3 <vector236>:
.globl vector236
vector236:
  pushl $0
801078d3:	6a 00                	push   $0x0
  pushl $236
801078d5:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078da:	e9 75 ee ff ff       	jmp    80106754 <alltraps>

801078df <vector237>:
.globl vector237
vector237:
  pushl $0
801078df:	6a 00                	push   $0x0
  pushl $237
801078e1:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078e6:	e9 69 ee ff ff       	jmp    80106754 <alltraps>

801078eb <vector238>:
.globl vector238
vector238:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $238
801078ed:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801078f2:	e9 5d ee ff ff       	jmp    80106754 <alltraps>

801078f7 <vector239>:
.globl vector239
vector239:
  pushl $0
801078f7:	6a 00                	push   $0x0
  pushl $239
801078f9:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801078fe:	e9 51 ee ff ff       	jmp    80106754 <alltraps>

80107903 <vector240>:
.globl vector240
vector240:
  pushl $0
80107903:	6a 00                	push   $0x0
  pushl $240
80107905:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010790a:	e9 45 ee ff ff       	jmp    80106754 <alltraps>

8010790f <vector241>:
.globl vector241
vector241:
  pushl $0
8010790f:	6a 00                	push   $0x0
  pushl $241
80107911:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107916:	e9 39 ee ff ff       	jmp    80106754 <alltraps>

8010791b <vector242>:
.globl vector242
vector242:
  pushl $0
8010791b:	6a 00                	push   $0x0
  pushl $242
8010791d:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107922:	e9 2d ee ff ff       	jmp    80106754 <alltraps>

80107927 <vector243>:
.globl vector243
vector243:
  pushl $0
80107927:	6a 00                	push   $0x0
  pushl $243
80107929:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010792e:	e9 21 ee ff ff       	jmp    80106754 <alltraps>

80107933 <vector244>:
.globl vector244
vector244:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $244
80107935:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010793a:	e9 15 ee ff ff       	jmp    80106754 <alltraps>

8010793f <vector245>:
.globl vector245
vector245:
  pushl $0
8010793f:	6a 00                	push   $0x0
  pushl $245
80107941:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107946:	e9 09 ee ff ff       	jmp    80106754 <alltraps>

8010794b <vector246>:
.globl vector246
vector246:
  pushl $0
8010794b:	6a 00                	push   $0x0
  pushl $246
8010794d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107952:	e9 fd ed ff ff       	jmp    80106754 <alltraps>

80107957 <vector247>:
.globl vector247
vector247:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $247
80107959:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010795e:	e9 f1 ed ff ff       	jmp    80106754 <alltraps>

80107963 <vector248>:
.globl vector248
vector248:
  pushl $0
80107963:	6a 00                	push   $0x0
  pushl $248
80107965:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010796a:	e9 e5 ed ff ff       	jmp    80106754 <alltraps>

8010796f <vector249>:
.globl vector249
vector249:
  pushl $0
8010796f:	6a 00                	push   $0x0
  pushl $249
80107971:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107976:	e9 d9 ed ff ff       	jmp    80106754 <alltraps>

8010797b <vector250>:
.globl vector250
vector250:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $250
8010797d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107982:	e9 cd ed ff ff       	jmp    80106754 <alltraps>

80107987 <vector251>:
.globl vector251
vector251:
  pushl $0
80107987:	6a 00                	push   $0x0
  pushl $251
80107989:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010798e:	e9 c1 ed ff ff       	jmp    80106754 <alltraps>

80107993 <vector252>:
.globl vector252
vector252:
  pushl $0
80107993:	6a 00                	push   $0x0
  pushl $252
80107995:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010799a:	e9 b5 ed ff ff       	jmp    80106754 <alltraps>

8010799f <vector253>:
.globl vector253
vector253:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $253
801079a1:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079a6:	e9 a9 ed ff ff       	jmp    80106754 <alltraps>

801079ab <vector254>:
.globl vector254
vector254:
  pushl $0
801079ab:	6a 00                	push   $0x0
  pushl $254
801079ad:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079b2:	e9 9d ed ff ff       	jmp    80106754 <alltraps>

801079b7 <vector255>:
.globl vector255
vector255:
  pushl $0
801079b7:	6a 00                	push   $0x0
  pushl $255
801079b9:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079be:	e9 91 ed ff ff       	jmp    80106754 <alltraps>

801079c3 <lgdt>:
{
801079c3:	55                   	push   %ebp
801079c4:	89 e5                	mov    %esp,%ebp
801079c6:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801079c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801079cc:	83 e8 01             	sub    $0x1,%eax
801079cf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079d3:	8b 45 08             	mov    0x8(%ebp),%eax
801079d6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079da:	8b 45 08             	mov    0x8(%ebp),%eax
801079dd:	c1 e8 10             	shr    $0x10,%eax
801079e0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801079e4:	8d 45 fa             	lea    -0x6(%ebp),%eax
801079e7:	0f 01 10             	lgdtl  (%eax)
}
801079ea:	90                   	nop
801079eb:	c9                   	leave  
801079ec:	c3                   	ret    

801079ed <ltr>:
{
801079ed:	55                   	push   %ebp
801079ee:	89 e5                	mov    %esp,%ebp
801079f0:	83 ec 04             	sub    $0x4,%esp
801079f3:	8b 45 08             	mov    0x8(%ebp),%eax
801079f6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801079fa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801079fe:	0f 00 d8             	ltr    %ax
}
80107a01:	90                   	nop
80107a02:	c9                   	leave  
80107a03:	c3                   	ret    

80107a04 <lcr3>:

static inline void
lcr3(uint val)
{
80107a04:	55                   	push   %ebp
80107a05:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a07:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0a:	0f 22 d8             	mov    %eax,%cr3
}
80107a0d:	90                   	nop
80107a0e:	5d                   	pop    %ebp
80107a0f:	c3                   	ret    

80107a10 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a10:	55                   	push   %ebp
80107a11:	89 e5                	mov    %esp,%ebp
80107a13:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107a16:	e8 94 c4 ff ff       	call   80103eaf <cpuid>
80107a1b:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107a21:	05 00 a7 11 80       	add    $0x8011a700,%eax
80107a26:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2c:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a35:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3e:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a45:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a49:	83 e2 f0             	and    $0xfffffff0,%edx
80107a4c:	83 ca 0a             	or     $0xa,%edx
80107a4f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a55:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a59:	83 ca 10             	or     $0x10,%edx
80107a5c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a62:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a66:	83 e2 9f             	and    $0xffffff9f,%edx
80107a69:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a73:	83 ca 80             	or     $0xffffff80,%edx
80107a76:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a80:	83 ca 0f             	or     $0xf,%edx
80107a83:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a89:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a8d:	83 e2 ef             	and    $0xffffffef,%edx
80107a90:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a96:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a9a:	83 e2 df             	and    $0xffffffdf,%edx
80107a9d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107aa7:	83 ca 40             	or     $0x40,%edx
80107aaa:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ab4:	83 ca 80             	or     $0xffffff80,%edx
80107ab7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac4:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107acb:	ff ff 
80107acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad0:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107ad7:	00 00 
80107ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adc:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107aed:	83 e2 f0             	and    $0xfffffff0,%edx
80107af0:	83 ca 02             	or     $0x2,%edx
80107af3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b03:	83 ca 10             	or     $0x10,%edx
80107b06:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b16:	83 e2 9f             	and    $0xffffff9f,%edx
80107b19:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b22:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b29:	83 ca 80             	or     $0xffffff80,%edx
80107b2c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b35:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b3c:	83 ca 0f             	or     $0xf,%edx
80107b3f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b4f:	83 e2 ef             	and    $0xffffffef,%edx
80107b52:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b62:	83 e2 df             	and    $0xffffffdf,%edx
80107b65:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b75:	83 ca 40             	or     $0x40,%edx
80107b78:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b81:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b88:	83 ca 80             	or     $0xffffff80,%edx
80107b8b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b94:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9e:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107ba5:	ff ff 
80107ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baa:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107bb1:	00 00 
80107bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb6:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bc7:	83 e2 f0             	and    $0xfffffff0,%edx
80107bca:	83 ca 0a             	or     $0xa,%edx
80107bcd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bdd:	83 ca 10             	or     $0x10,%edx
80107be0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bf0:	83 ca 60             	or     $0x60,%edx
80107bf3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c03:	83 ca 80             	or     $0xffffff80,%edx
80107c06:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c16:	83 ca 0f             	or     $0xf,%edx
80107c19:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c22:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c29:	83 e2 ef             	and    $0xffffffef,%edx
80107c2c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c35:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c3c:	83 e2 df             	and    $0xffffffdf,%edx
80107c3f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c4f:	83 ca 40             	or     $0x40,%edx
80107c52:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c62:	83 ca 80             	or     $0xffffff80,%edx
80107c65:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6e:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c78:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c7f:	ff ff 
80107c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c84:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c8b:	00 00 
80107c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c90:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ca1:	83 e2 f0             	and    $0xfffffff0,%edx
80107ca4:	83 ca 02             	or     $0x2,%edx
80107ca7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cb7:	83 ca 10             	or     $0x10,%edx
80107cba:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cca:	83 ca 60             	or     $0x60,%edx
80107ccd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cdd:	83 ca 80             	or     $0xffffff80,%edx
80107ce0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cf0:	83 ca 0f             	or     $0xf,%edx
80107cf3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d03:	83 e2 ef             	and    $0xffffffef,%edx
80107d06:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d16:	83 e2 df             	and    $0xffffffdf,%edx
80107d19:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d22:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d29:	83 ca 40             	or     $0x40,%edx
80107d2c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d35:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d3c:	83 ca 80             	or     $0xffffff80,%edx
80107d3f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d48:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d52:	83 c0 70             	add    $0x70,%eax
80107d55:	83 ec 08             	sub    $0x8,%esp
80107d58:	6a 30                	push   $0x30
80107d5a:	50                   	push   %eax
80107d5b:	e8 63 fc ff ff       	call   801079c3 <lgdt>
80107d60:	83 c4 10             	add    $0x10,%esp
}
80107d63:	90                   	nop
80107d64:	c9                   	leave  
80107d65:	c3                   	ret    

80107d66 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107d66:	55                   	push   %ebp
80107d67:	89 e5                	mov    %esp,%ebp
80107d69:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d6f:	c1 e8 16             	shr    $0x16,%eax
80107d72:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d79:	8b 45 08             	mov    0x8(%ebp),%eax
80107d7c:	01 d0                	add    %edx,%eax
80107d7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d84:	8b 00                	mov    (%eax),%eax
80107d86:	83 e0 01             	and    $0x1,%eax
80107d89:	85 c0                	test   %eax,%eax
80107d8b:	74 14                	je     80107da1 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d90:	8b 00                	mov    (%eax),%eax
80107d92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d97:	05 00 00 00 80       	add    $0x80000000,%eax
80107d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d9f:	eb 42                	jmp    80107de3 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107da1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107da5:	74 0e                	je     80107db5 <walkpgdir+0x4f>
80107da7:	e8 d8 ae ff ff       	call   80102c84 <kalloc>
80107dac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107daf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107db3:	75 07                	jne    80107dbc <walkpgdir+0x56>
      return 0;
80107db5:	b8 00 00 00 00       	mov    $0x0,%eax
80107dba:	eb 3e                	jmp    80107dfa <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107dbc:	83 ec 04             	sub    $0x4,%esp
80107dbf:	68 00 10 00 00       	push   $0x1000
80107dc4:	6a 00                	push   $0x0
80107dc6:	ff 75 f4             	push   -0xc(%ebp)
80107dc9:	e8 98 d5 ff ff       	call   80105366 <memset>
80107dce:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd4:	05 00 00 00 80       	add    $0x80000000,%eax
80107dd9:	83 c8 07             	or     $0x7,%eax
80107ddc:	89 c2                	mov    %eax,%edx
80107dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107de1:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107de3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de6:	c1 e8 0c             	shr    $0xc,%eax
80107de9:	25 ff 03 00 00       	and    $0x3ff,%eax
80107dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df8:	01 d0                	add    %edx,%eax
}
80107dfa:	c9                   	leave  
80107dfb:	c3                   	ret    

80107dfc <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107dfc:	55                   	push   %ebp
80107dfd:	89 e5                	mov    %esp,%ebp
80107dff:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107e02:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e10:	8b 45 10             	mov    0x10(%ebp),%eax
80107e13:	01 d0                	add    %edx,%eax
80107e15:	83 e8 01             	sub    $0x1,%eax
80107e18:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e20:	83 ec 04             	sub    $0x4,%esp
80107e23:	6a 01                	push   $0x1
80107e25:	ff 75 f4             	push   -0xc(%ebp)
80107e28:	ff 75 08             	push   0x8(%ebp)
80107e2b:	e8 36 ff ff ff       	call   80107d66 <walkpgdir>
80107e30:	83 c4 10             	add    $0x10,%esp
80107e33:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e36:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e3a:	75 07                	jne    80107e43 <mappages+0x47>
      return -1;
80107e3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e41:	eb 47                	jmp    80107e8a <mappages+0x8e>
    if(*pte & PTE_P)
80107e43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e46:	8b 00                	mov    (%eax),%eax
80107e48:	83 e0 01             	and    $0x1,%eax
80107e4b:	85 c0                	test   %eax,%eax
80107e4d:	74 0d                	je     80107e5c <mappages+0x60>
      panic("remap");
80107e4f:	83 ec 0c             	sub    $0xc,%esp
80107e52:	68 8c b0 10 80       	push   $0x8010b08c
80107e57:	e8 4d 87 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107e5c:	8b 45 18             	mov    0x18(%ebp),%eax
80107e5f:	0b 45 14             	or     0x14(%ebp),%eax
80107e62:	83 c8 01             	or     $0x1,%eax
80107e65:	89 c2                	mov    %eax,%edx
80107e67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e6a:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107e72:	74 10                	je     80107e84 <mappages+0x88>
      break;
    a += PGSIZE;
80107e74:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107e7b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e82:	eb 9c                	jmp    80107e20 <mappages+0x24>
      break;
80107e84:	90                   	nop
  }
  return 0;
80107e85:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e8a:	c9                   	leave  
80107e8b:	c3                   	ret    

80107e8c <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107e8c:	55                   	push   %ebp
80107e8d:	89 e5                	mov    %esp,%ebp
80107e8f:	53                   	push   %ebx
80107e90:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107e93:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107e9a:	8b 15 e0 a9 11 80    	mov    0x8011a9e0,%edx
80107ea0:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107ea5:	29 d0                	sub    %edx,%eax
80107ea7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107eaa:	a1 d8 a9 11 80       	mov    0x8011a9d8,%eax
80107eaf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107eb2:	8b 15 d8 a9 11 80    	mov    0x8011a9d8,%edx
80107eb8:	a1 e0 a9 11 80       	mov    0x8011a9e0,%eax
80107ebd:	01 d0                	add    %edx,%eax
80107ebf:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107ec2:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecc:	83 c0 30             	add    $0x30,%eax
80107ecf:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107ed2:	89 10                	mov    %edx,(%eax)
80107ed4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107ed7:	89 50 04             	mov    %edx,0x4(%eax)
80107eda:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107edd:	89 50 08             	mov    %edx,0x8(%eax)
80107ee0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107ee3:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107ee6:	e8 99 ad ff ff       	call   80102c84 <kalloc>
80107eeb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107eee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ef2:	75 07                	jne    80107efb <setupkvm+0x6f>
    return 0;
80107ef4:	b8 00 00 00 00       	mov    $0x0,%eax
80107ef9:	eb 78                	jmp    80107f73 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107efb:	83 ec 04             	sub    $0x4,%esp
80107efe:	68 00 10 00 00       	push   $0x1000
80107f03:	6a 00                	push   $0x0
80107f05:	ff 75 f0             	push   -0x10(%ebp)
80107f08:	e8 59 d4 ff ff       	call   80105366 <memset>
80107f0d:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f10:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107f17:	eb 4e                	jmp    80107f67 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1c:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f22:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f28:	8b 58 08             	mov    0x8(%eax),%ebx
80107f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2e:	8b 40 04             	mov    0x4(%eax),%eax
80107f31:	29 c3                	sub    %eax,%ebx
80107f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f36:	8b 00                	mov    (%eax),%eax
80107f38:	83 ec 0c             	sub    $0xc,%esp
80107f3b:	51                   	push   %ecx
80107f3c:	52                   	push   %edx
80107f3d:	53                   	push   %ebx
80107f3e:	50                   	push   %eax
80107f3f:	ff 75 f0             	push   -0x10(%ebp)
80107f42:	e8 b5 fe ff ff       	call   80107dfc <mappages>
80107f47:	83 c4 20             	add    $0x20,%esp
80107f4a:	85 c0                	test   %eax,%eax
80107f4c:	79 15                	jns    80107f63 <setupkvm+0xd7>
      freevm(pgdir);
80107f4e:	83 ec 0c             	sub    $0xc,%esp
80107f51:	ff 75 f0             	push   -0x10(%ebp)
80107f54:	e8 f5 04 00 00       	call   8010844e <freevm>
80107f59:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f5c:	b8 00 00 00 00       	mov    $0x0,%eax
80107f61:	eb 10                	jmp    80107f73 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f63:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f67:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107f6e:	72 a9                	jb     80107f19 <setupkvm+0x8d>
    }
  return pgdir;
80107f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107f76:	c9                   	leave  
80107f77:	c3                   	ret    

80107f78 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f78:	55                   	push   %ebp
80107f79:	89 e5                	mov    %esp,%ebp
80107f7b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107f7e:	e8 09 ff ff ff       	call   80107e8c <setupkvm>
80107f83:	a3 fc a6 11 80       	mov    %eax,0x8011a6fc
  switchkvm();
80107f88:	e8 03 00 00 00       	call   80107f90 <switchkvm>
}
80107f8d:	90                   	nop
80107f8e:	c9                   	leave  
80107f8f:	c3                   	ret    

80107f90 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107f90:	55                   	push   %ebp
80107f91:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107f93:	a1 fc a6 11 80       	mov    0x8011a6fc,%eax
80107f98:	05 00 00 00 80       	add    $0x80000000,%eax
80107f9d:	50                   	push   %eax
80107f9e:	e8 61 fa ff ff       	call   80107a04 <lcr3>
80107fa3:	83 c4 04             	add    $0x4,%esp
}
80107fa6:	90                   	nop
80107fa7:	c9                   	leave  
80107fa8:	c3                   	ret    

80107fa9 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107fa9:	55                   	push   %ebp
80107faa:	89 e5                	mov    %esp,%ebp
80107fac:	56                   	push   %esi
80107fad:	53                   	push   %ebx
80107fae:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107fb1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107fb5:	75 0d                	jne    80107fc4 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107fb7:	83 ec 0c             	sub    $0xc,%esp
80107fba:	68 92 b0 10 80       	push   $0x8010b092
80107fbf:	e8 e5 85 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc7:	8b 40 08             	mov    0x8(%eax),%eax
80107fca:	85 c0                	test   %eax,%eax
80107fcc:	75 0d                	jne    80107fdb <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107fce:	83 ec 0c             	sub    $0xc,%esp
80107fd1:	68 a8 b0 10 80       	push   $0x8010b0a8
80107fd6:	e8 ce 85 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80107fde:	8b 40 04             	mov    0x4(%eax),%eax
80107fe1:	85 c0                	test   %eax,%eax
80107fe3:	75 0d                	jne    80107ff2 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107fe5:	83 ec 0c             	sub    $0xc,%esp
80107fe8:	68 bd b0 10 80       	push   $0x8010b0bd
80107fed:	e8 b7 85 ff ff       	call   801005a9 <panic>

  pushcli();
80107ff2:	e8 64 d2 ff ff       	call   8010525b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107ff7:	e8 ce be ff ff       	call   80103eca <mycpu>
80107ffc:	89 c3                	mov    %eax,%ebx
80107ffe:	e8 c7 be ff ff       	call   80103eca <mycpu>
80108003:	83 c0 08             	add    $0x8,%eax
80108006:	89 c6                	mov    %eax,%esi
80108008:	e8 bd be ff ff       	call   80103eca <mycpu>
8010800d:	83 c0 08             	add    $0x8,%eax
80108010:	c1 e8 10             	shr    $0x10,%eax
80108013:	88 45 f7             	mov    %al,-0x9(%ebp)
80108016:	e8 af be ff ff       	call   80103eca <mycpu>
8010801b:	83 c0 08             	add    $0x8,%eax
8010801e:	c1 e8 18             	shr    $0x18,%eax
80108021:	89 c2                	mov    %eax,%edx
80108023:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010802a:	67 00 
8010802c:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108033:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108037:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010803d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108044:	83 e0 f0             	and    $0xfffffff0,%eax
80108047:	83 c8 09             	or     $0x9,%eax
8010804a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108050:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108057:	83 c8 10             	or     $0x10,%eax
8010805a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108060:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108067:	83 e0 9f             	and    $0xffffff9f,%eax
8010806a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108070:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108077:	83 c8 80             	or     $0xffffff80,%eax
8010807a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108080:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108087:	83 e0 f0             	and    $0xfffffff0,%eax
8010808a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108090:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108097:	83 e0 ef             	and    $0xffffffef,%eax
8010809a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080a0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080a7:	83 e0 df             	and    $0xffffffdf,%eax
801080aa:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080b0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080b7:	83 c8 40             	or     $0x40,%eax
801080ba:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080c0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080c7:	83 e0 7f             	and    $0x7f,%eax
801080ca:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080d0:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801080d6:	e8 ef bd ff ff       	call   80103eca <mycpu>
801080db:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080e2:	83 e2 ef             	and    $0xffffffef,%edx
801080e5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801080eb:	e8 da bd ff ff       	call   80103eca <mycpu>
801080f0:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801080f6:	8b 45 08             	mov    0x8(%ebp),%eax
801080f9:	8b 40 08             	mov    0x8(%eax),%eax
801080fc:	89 c3                	mov    %eax,%ebx
801080fe:	e8 c7 bd ff ff       	call   80103eca <mycpu>
80108103:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108109:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010810c:	e8 b9 bd ff ff       	call   80103eca <mycpu>
80108111:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108117:	83 ec 0c             	sub    $0xc,%esp
8010811a:	6a 28                	push   $0x28
8010811c:	e8 cc f8 ff ff       	call   801079ed <ltr>
80108121:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108124:	8b 45 08             	mov    0x8(%ebp),%eax
80108127:	8b 40 04             	mov    0x4(%eax),%eax
8010812a:	05 00 00 00 80       	add    $0x80000000,%eax
8010812f:	83 ec 0c             	sub    $0xc,%esp
80108132:	50                   	push   %eax
80108133:	e8 cc f8 ff ff       	call   80107a04 <lcr3>
80108138:	83 c4 10             	add    $0x10,%esp
  popcli();
8010813b:	e8 68 d1 ff ff       	call   801052a8 <popcli>
}
80108140:	90                   	nop
80108141:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108144:	5b                   	pop    %ebx
80108145:	5e                   	pop    %esi
80108146:	5d                   	pop    %ebp
80108147:	c3                   	ret    

80108148 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108148:	55                   	push   %ebp
80108149:	89 e5                	mov    %esp,%ebp
8010814b:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010814e:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108155:	76 0d                	jbe    80108164 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108157:	83 ec 0c             	sub    $0xc,%esp
8010815a:	68 d1 b0 10 80       	push   $0x8010b0d1
8010815f:	e8 45 84 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80108164:	e8 1b ab ff ff       	call   80102c84 <kalloc>
80108169:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010816c:	83 ec 04             	sub    $0x4,%esp
8010816f:	68 00 10 00 00       	push   $0x1000
80108174:	6a 00                	push   $0x0
80108176:	ff 75 f4             	push   -0xc(%ebp)
80108179:	e8 e8 d1 ff ff       	call   80105366 <memset>
8010817e:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108184:	05 00 00 00 80       	add    $0x80000000,%eax
80108189:	83 ec 0c             	sub    $0xc,%esp
8010818c:	6a 06                	push   $0x6
8010818e:	50                   	push   %eax
8010818f:	68 00 10 00 00       	push   $0x1000
80108194:	6a 00                	push   $0x0
80108196:	ff 75 08             	push   0x8(%ebp)
80108199:	e8 5e fc ff ff       	call   80107dfc <mappages>
8010819e:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801081a1:	83 ec 04             	sub    $0x4,%esp
801081a4:	ff 75 10             	push   0x10(%ebp)
801081a7:	ff 75 0c             	push   0xc(%ebp)
801081aa:	ff 75 f4             	push   -0xc(%ebp)
801081ad:	e8 73 d2 ff ff       	call   80105425 <memmove>
801081b2:	83 c4 10             	add    $0x10,%esp
}
801081b5:	90                   	nop
801081b6:	c9                   	leave  
801081b7:	c3                   	ret    

801081b8 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801081b8:	55                   	push   %ebp
801081b9:	89 e5                	mov    %esp,%ebp
801081bb:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801081be:	8b 45 0c             	mov    0xc(%ebp),%eax
801081c1:	25 ff 0f 00 00       	and    $0xfff,%eax
801081c6:	85 c0                	test   %eax,%eax
801081c8:	74 0d                	je     801081d7 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801081ca:	83 ec 0c             	sub    $0xc,%esp
801081cd:	68 ec b0 10 80       	push   $0x8010b0ec
801081d2:	e8 d2 83 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801081d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081de:	e9 8f 00 00 00       	jmp    80108272 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801081e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801081e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e9:	01 d0                	add    %edx,%eax
801081eb:	83 ec 04             	sub    $0x4,%esp
801081ee:	6a 00                	push   $0x0
801081f0:	50                   	push   %eax
801081f1:	ff 75 08             	push   0x8(%ebp)
801081f4:	e8 6d fb ff ff       	call   80107d66 <walkpgdir>
801081f9:	83 c4 10             	add    $0x10,%esp
801081fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108203:	75 0d                	jne    80108212 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80108205:	83 ec 0c             	sub    $0xc,%esp
80108208:	68 0f b1 10 80       	push   $0x8010b10f
8010820d:	e8 97 83 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80108212:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108215:	8b 00                	mov    (%eax),%eax
80108217:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010821c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010821f:	8b 45 18             	mov    0x18(%ebp),%eax
80108222:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108225:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010822a:	77 0b                	ja     80108237 <loaduvm+0x7f>
      n = sz - i;
8010822c:	8b 45 18             	mov    0x18(%ebp),%eax
8010822f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108232:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108235:	eb 07                	jmp    8010823e <loaduvm+0x86>
    else
      n = PGSIZE;
80108237:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010823e:	8b 55 14             	mov    0x14(%ebp),%edx
80108241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108244:	01 d0                	add    %edx,%eax
80108246:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108249:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010824f:	ff 75 f0             	push   -0x10(%ebp)
80108252:	50                   	push   %eax
80108253:	52                   	push   %edx
80108254:	ff 75 10             	push   0x10(%ebp)
80108257:	e8 7a 9c ff ff       	call   80101ed6 <readi>
8010825c:	83 c4 10             	add    $0x10,%esp
8010825f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108262:	74 07                	je     8010826b <loaduvm+0xb3>
      return -1;
80108264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108269:	eb 18                	jmp    80108283 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
8010826b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108275:	3b 45 18             	cmp    0x18(%ebp),%eax
80108278:	0f 82 65 ff ff ff    	jb     801081e3 <loaduvm+0x2b>
  }
  return 0;
8010827e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108283:	c9                   	leave  
80108284:	c3                   	ret    

80108285 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108285:	55                   	push   %ebp
80108286:	89 e5                	mov    %esp,%ebp
80108288:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010828b:	8b 45 10             	mov    0x10(%ebp),%eax
8010828e:	85 c0                	test   %eax,%eax
80108290:	79 0a                	jns    8010829c <allocuvm+0x17>
    return 0;
80108292:	b8 00 00 00 00       	mov    $0x0,%eax
80108297:	e9 ec 00 00 00       	jmp    80108388 <allocuvm+0x103>
  if(newsz < oldsz)
8010829c:	8b 45 10             	mov    0x10(%ebp),%eax
8010829f:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082a2:	73 08                	jae    801082ac <allocuvm+0x27>
    return oldsz;
801082a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801082a7:	e9 dc 00 00 00       	jmp    80108388 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801082ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801082af:	05 ff 0f 00 00       	add    $0xfff,%eax
801082b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801082bc:	e9 b8 00 00 00       	jmp    80108379 <allocuvm+0xf4>
    mem = kalloc();
801082c1:	e8 be a9 ff ff       	call   80102c84 <kalloc>
801082c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082cd:	75 2e                	jne    801082fd <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
801082cf:	83 ec 0c             	sub    $0xc,%esp
801082d2:	68 2d b1 10 80       	push   $0x8010b12d
801082d7:	e8 18 81 ff ff       	call   801003f4 <cprintf>
801082dc:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801082df:	83 ec 04             	sub    $0x4,%esp
801082e2:	ff 75 0c             	push   0xc(%ebp)
801082e5:	ff 75 10             	push   0x10(%ebp)
801082e8:	ff 75 08             	push   0x8(%ebp)
801082eb:	e8 9a 00 00 00       	call   8010838a <deallocuvm>
801082f0:	83 c4 10             	add    $0x10,%esp
      return 0;
801082f3:	b8 00 00 00 00       	mov    $0x0,%eax
801082f8:	e9 8b 00 00 00       	jmp    80108388 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
801082fd:	83 ec 04             	sub    $0x4,%esp
80108300:	68 00 10 00 00       	push   $0x1000
80108305:	6a 00                	push   $0x0
80108307:	ff 75 f0             	push   -0x10(%ebp)
8010830a:	e8 57 d0 ff ff       	call   80105366 <memset>
8010830f:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108312:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108315:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010831b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831e:	83 ec 0c             	sub    $0xc,%esp
80108321:	6a 06                	push   $0x6
80108323:	52                   	push   %edx
80108324:	68 00 10 00 00       	push   $0x1000
80108329:	50                   	push   %eax
8010832a:	ff 75 08             	push   0x8(%ebp)
8010832d:	e8 ca fa ff ff       	call   80107dfc <mappages>
80108332:	83 c4 20             	add    $0x20,%esp
80108335:	85 c0                	test   %eax,%eax
80108337:	79 39                	jns    80108372 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80108339:	83 ec 0c             	sub    $0xc,%esp
8010833c:	68 45 b1 10 80       	push   $0x8010b145
80108341:	e8 ae 80 ff ff       	call   801003f4 <cprintf>
80108346:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108349:	83 ec 04             	sub    $0x4,%esp
8010834c:	ff 75 0c             	push   0xc(%ebp)
8010834f:	ff 75 10             	push   0x10(%ebp)
80108352:	ff 75 08             	push   0x8(%ebp)
80108355:	e8 30 00 00 00       	call   8010838a <deallocuvm>
8010835a:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010835d:	83 ec 0c             	sub    $0xc,%esp
80108360:	ff 75 f0             	push   -0x10(%ebp)
80108363:	e8 82 a8 ff ff       	call   80102bea <kfree>
80108368:	83 c4 10             	add    $0x10,%esp
      return 0;
8010836b:	b8 00 00 00 00       	mov    $0x0,%eax
80108370:	eb 16                	jmp    80108388 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80108372:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010837f:	0f 82 3c ff ff ff    	jb     801082c1 <allocuvm+0x3c>
    }
  }
  return newsz;
80108385:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108388:	c9                   	leave  
80108389:	c3                   	ret    

8010838a <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010838a:	55                   	push   %ebp
8010838b:	89 e5                	mov    %esp,%ebp
8010838d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108390:	8b 45 10             	mov    0x10(%ebp),%eax
80108393:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108396:	72 08                	jb     801083a0 <deallocuvm+0x16>
    return oldsz;
80108398:	8b 45 0c             	mov    0xc(%ebp),%eax
8010839b:	e9 ac 00 00 00       	jmp    8010844c <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801083a0:	8b 45 10             	mov    0x10(%ebp),%eax
801083a3:	05 ff 0f 00 00       	add    $0xfff,%eax
801083a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801083b0:	e9 88 00 00 00       	jmp    8010843d <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801083b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b8:	83 ec 04             	sub    $0x4,%esp
801083bb:	6a 00                	push   $0x0
801083bd:	50                   	push   %eax
801083be:	ff 75 08             	push   0x8(%ebp)
801083c1:	e8 a0 f9 ff ff       	call   80107d66 <walkpgdir>
801083c6:	83 c4 10             	add    $0x10,%esp
801083c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801083cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083d0:	75 16                	jne    801083e8 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801083d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d5:	c1 e8 16             	shr    $0x16,%eax
801083d8:	83 c0 01             	add    $0x1,%eax
801083db:	c1 e0 16             	shl    $0x16,%eax
801083de:	2d 00 10 00 00       	sub    $0x1000,%eax
801083e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801083e6:	eb 4e                	jmp    80108436 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801083e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083eb:	8b 00                	mov    (%eax),%eax
801083ed:	83 e0 01             	and    $0x1,%eax
801083f0:	85 c0                	test   %eax,%eax
801083f2:	74 42                	je     80108436 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801083f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f7:	8b 00                	mov    (%eax),%eax
801083f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108401:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108405:	75 0d                	jne    80108414 <deallocuvm+0x8a>
        panic("kfree");
80108407:	83 ec 0c             	sub    $0xc,%esp
8010840a:	68 61 b1 10 80       	push   $0x8010b161
8010840f:	e8 95 81 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80108414:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108417:	05 00 00 00 80       	add    $0x80000000,%eax
8010841c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010841f:	83 ec 0c             	sub    $0xc,%esp
80108422:	ff 75 e8             	push   -0x18(%ebp)
80108425:	e8 c0 a7 ff ff       	call   80102bea <kfree>
8010842a:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010842d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108430:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108436:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010843d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108440:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108443:	0f 82 6c ff ff ff    	jb     801083b5 <deallocuvm+0x2b>
    }
  }
  return newsz;
80108449:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010844c:	c9                   	leave  
8010844d:	c3                   	ret    

8010844e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010844e:	55                   	push   %ebp
8010844f:	89 e5                	mov    %esp,%ebp
80108451:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108454:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108458:	75 0d                	jne    80108467 <freevm+0x19>
    panic("freevm: no pgdir");
8010845a:	83 ec 0c             	sub    $0xc,%esp
8010845d:	68 67 b1 10 80       	push   $0x8010b167
80108462:	e8 42 81 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108467:	83 ec 04             	sub    $0x4,%esp
8010846a:	6a 00                	push   $0x0
8010846c:	68 00 00 00 80       	push   $0x80000000
80108471:	ff 75 08             	push   0x8(%ebp)
80108474:	e8 11 ff ff ff       	call   8010838a <deallocuvm>
80108479:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010847c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108483:	eb 48                	jmp    801084cd <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108488:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010848f:	8b 45 08             	mov    0x8(%ebp),%eax
80108492:	01 d0                	add    %edx,%eax
80108494:	8b 00                	mov    (%eax),%eax
80108496:	83 e0 01             	and    $0x1,%eax
80108499:	85 c0                	test   %eax,%eax
8010849b:	74 2c                	je     801084c9 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010849d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084a7:	8b 45 08             	mov    0x8(%ebp),%eax
801084aa:	01 d0                	add    %edx,%eax
801084ac:	8b 00                	mov    (%eax),%eax
801084ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084b3:	05 00 00 00 80       	add    $0x80000000,%eax
801084b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801084bb:	83 ec 0c             	sub    $0xc,%esp
801084be:	ff 75 f0             	push   -0x10(%ebp)
801084c1:	e8 24 a7 ff ff       	call   80102bea <kfree>
801084c6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801084c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084cd:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801084d4:	76 af                	jbe    80108485 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801084d6:	83 ec 0c             	sub    $0xc,%esp
801084d9:	ff 75 08             	push   0x8(%ebp)
801084dc:	e8 09 a7 ff ff       	call   80102bea <kfree>
801084e1:	83 c4 10             	add    $0x10,%esp
}
801084e4:	90                   	nop
801084e5:	c9                   	leave  
801084e6:	c3                   	ret    

801084e7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801084e7:	55                   	push   %ebp
801084e8:	89 e5                	mov    %esp,%ebp
801084ea:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084ed:	83 ec 04             	sub    $0x4,%esp
801084f0:	6a 00                	push   $0x0
801084f2:	ff 75 0c             	push   0xc(%ebp)
801084f5:	ff 75 08             	push   0x8(%ebp)
801084f8:	e8 69 f8 ff ff       	call   80107d66 <walkpgdir>
801084fd:	83 c4 10             	add    $0x10,%esp
80108500:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108503:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108507:	75 0d                	jne    80108516 <clearpteu+0x2f>
    panic("clearpteu");
80108509:	83 ec 0c             	sub    $0xc,%esp
8010850c:	68 78 b1 10 80       	push   $0x8010b178
80108511:	e8 93 80 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80108516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108519:	8b 00                	mov    (%eax),%eax
8010851b:	83 e0 fb             	and    $0xfffffffb,%eax
8010851e:	89 c2                	mov    %eax,%edx
80108520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108523:	89 10                	mov    %edx,(%eax)
}
80108525:	90                   	nop
80108526:	c9                   	leave  
80108527:	c3                   	ret    

80108528 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108528:	55                   	push   %ebp
80108529:	89 e5                	mov    %esp,%ebp
8010852b:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010852e:	e8 59 f9 ff ff       	call   80107e8c <setupkvm>
80108533:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108536:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010853a:	75 0a                	jne    80108546 <copyuvm+0x1e>
    return 0;
8010853c:	b8 00 00 00 00       	mov    $0x0,%eax
80108541:	e9 eb 00 00 00       	jmp    80108631 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108546:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010854d:	e9 b7 00 00 00       	jmp    80108609 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108555:	83 ec 04             	sub    $0x4,%esp
80108558:	6a 00                	push   $0x0
8010855a:	50                   	push   %eax
8010855b:	ff 75 08             	push   0x8(%ebp)
8010855e:	e8 03 f8 ff ff       	call   80107d66 <walkpgdir>
80108563:	83 c4 10             	add    $0x10,%esp
80108566:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108569:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010856d:	75 0d                	jne    8010857c <copyuvm+0x54>
      panic("copyuvm: pte should exist");
8010856f:	83 ec 0c             	sub    $0xc,%esp
80108572:	68 82 b1 10 80       	push   $0x8010b182
80108577:	e8 2d 80 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
8010857c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010857f:	8b 00                	mov    (%eax),%eax
80108581:	83 e0 01             	and    $0x1,%eax
80108584:	85 c0                	test   %eax,%eax
80108586:	75 0d                	jne    80108595 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80108588:	83 ec 0c             	sub    $0xc,%esp
8010858b:	68 9c b1 10 80       	push   $0x8010b19c
80108590:	e8 14 80 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80108595:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108598:	8b 00                	mov    (%eax),%eax
8010859a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010859f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801085a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085a5:	8b 00                	mov    (%eax),%eax
801085a7:	25 ff 0f 00 00       	and    $0xfff,%eax
801085ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801085af:	e8 d0 a6 ff ff       	call   80102c84 <kalloc>
801085b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801085b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801085bb:	74 5d                	je     8010861a <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801085bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085c0:	05 00 00 00 80       	add    $0x80000000,%eax
801085c5:	83 ec 04             	sub    $0x4,%esp
801085c8:	68 00 10 00 00       	push   $0x1000
801085cd:	50                   	push   %eax
801085ce:	ff 75 e0             	push   -0x20(%ebp)
801085d1:	e8 4f ce ff ff       	call   80105425 <memmove>
801085d6:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801085d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801085dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801085df:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801085e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e8:	83 ec 0c             	sub    $0xc,%esp
801085eb:	52                   	push   %edx
801085ec:	51                   	push   %ecx
801085ed:	68 00 10 00 00       	push   $0x1000
801085f2:	50                   	push   %eax
801085f3:	ff 75 f0             	push   -0x10(%ebp)
801085f6:	e8 01 f8 ff ff       	call   80107dfc <mappages>
801085fb:	83 c4 20             	add    $0x20,%esp
801085fe:	85 c0                	test   %eax,%eax
80108600:	78 1b                	js     8010861d <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80108602:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010860f:	0f 82 3d ff ff ff    	jb     80108552 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80108615:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108618:	eb 17                	jmp    80108631 <copyuvm+0x109>
      goto bad;
8010861a:	90                   	nop
8010861b:	eb 01                	jmp    8010861e <copyuvm+0xf6>
      goto bad;
8010861d:	90                   	nop

bad:
  freevm(d);
8010861e:	83 ec 0c             	sub    $0xc,%esp
80108621:	ff 75 f0             	push   -0x10(%ebp)
80108624:	e8 25 fe ff ff       	call   8010844e <freevm>
80108629:	83 c4 10             	add    $0x10,%esp
  return 0;
8010862c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108631:	c9                   	leave  
80108632:	c3                   	ret    

80108633 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108633:	55                   	push   %ebp
80108634:	89 e5                	mov    %esp,%ebp
80108636:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108639:	83 ec 04             	sub    $0x4,%esp
8010863c:	6a 00                	push   $0x0
8010863e:	ff 75 0c             	push   0xc(%ebp)
80108641:	ff 75 08             	push   0x8(%ebp)
80108644:	e8 1d f7 ff ff       	call   80107d66 <walkpgdir>
80108649:	83 c4 10             	add    $0x10,%esp
8010864c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010864f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108652:	8b 00                	mov    (%eax),%eax
80108654:	83 e0 01             	and    $0x1,%eax
80108657:	85 c0                	test   %eax,%eax
80108659:	75 07                	jne    80108662 <uva2ka+0x2f>
    return 0;
8010865b:	b8 00 00 00 00       	mov    $0x0,%eax
80108660:	eb 22                	jmp    80108684 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108665:	8b 00                	mov    (%eax),%eax
80108667:	83 e0 04             	and    $0x4,%eax
8010866a:	85 c0                	test   %eax,%eax
8010866c:	75 07                	jne    80108675 <uva2ka+0x42>
    return 0;
8010866e:	b8 00 00 00 00       	mov    $0x0,%eax
80108673:	eb 0f                	jmp    80108684 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108678:	8b 00                	mov    (%eax),%eax
8010867a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010867f:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108684:	c9                   	leave  
80108685:	c3                   	ret    

80108686 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108686:	55                   	push   %ebp
80108687:	89 e5                	mov    %esp,%ebp
80108689:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010868c:	8b 45 10             	mov    0x10(%ebp),%eax
8010868f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108692:	eb 7f                	jmp    80108713 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108694:	8b 45 0c             	mov    0xc(%ebp),%eax
80108697:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010869c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010869f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086a2:	83 ec 08             	sub    $0x8,%esp
801086a5:	50                   	push   %eax
801086a6:	ff 75 08             	push   0x8(%ebp)
801086a9:	e8 85 ff ff ff       	call   80108633 <uva2ka>
801086ae:	83 c4 10             	add    $0x10,%esp
801086b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801086b4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801086b8:	75 07                	jne    801086c1 <copyout+0x3b>
      return -1;
801086ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801086bf:	eb 61                	jmp    80108722 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801086c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086c4:	2b 45 0c             	sub    0xc(%ebp),%eax
801086c7:	05 00 10 00 00       	add    $0x1000,%eax
801086cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801086cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d2:	3b 45 14             	cmp    0x14(%ebp),%eax
801086d5:	76 06                	jbe    801086dd <copyout+0x57>
      n = len;
801086d7:	8b 45 14             	mov    0x14(%ebp),%eax
801086da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801086dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801086e0:	2b 45 ec             	sub    -0x14(%ebp),%eax
801086e3:	89 c2                	mov    %eax,%edx
801086e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086e8:	01 d0                	add    %edx,%eax
801086ea:	83 ec 04             	sub    $0x4,%esp
801086ed:	ff 75 f0             	push   -0x10(%ebp)
801086f0:	ff 75 f4             	push   -0xc(%ebp)
801086f3:	50                   	push   %eax
801086f4:	e8 2c cd ff ff       	call   80105425 <memmove>
801086f9:	83 c4 10             	add    $0x10,%esp
    len -= n;
801086fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086ff:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108702:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108705:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108708:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010870b:	05 00 10 00 00       	add    $0x1000,%eax
80108710:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108713:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108717:	0f 85 77 ff ff ff    	jne    80108694 <copyout+0xe>
  }
  return 0;
8010871d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108722:	c9                   	leave  
80108723:	c3                   	ret    

80108724 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108724:	55                   	push   %ebp
80108725:	89 e5                	mov    %esp,%ebp
80108727:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010872a:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108731:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108734:	8b 40 08             	mov    0x8(%eax),%eax
80108737:	05 00 00 00 80       	add    $0x80000000,%eax
8010873c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010873f:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108749:	8b 40 24             	mov    0x24(%eax),%eax
8010874c:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
80108751:	c7 05 d0 a9 11 80 00 	movl   $0x0,0x8011a9d0
80108758:	00 00 00 

  while(i<madt->len){
8010875b:	90                   	nop
8010875c:	e9 bd 00 00 00       	jmp    8010881e <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108761:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108764:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108767:	01 d0                	add    %edx,%eax
80108769:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010876c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010876f:	0f b6 00             	movzbl (%eax),%eax
80108772:	0f b6 c0             	movzbl %al,%eax
80108775:	83 f8 05             	cmp    $0x5,%eax
80108778:	0f 87 a0 00 00 00    	ja     8010881e <mpinit_uefi+0xfa>
8010877e:	8b 04 85 b8 b1 10 80 	mov    -0x7fef4e48(,%eax,4),%eax
80108785:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108787:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010878a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
8010878d:	a1 d0 a9 11 80       	mov    0x8011a9d0,%eax
80108792:	83 f8 03             	cmp    $0x3,%eax
80108795:	7f 28                	jg     801087bf <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108797:	8b 15 d0 a9 11 80    	mov    0x8011a9d0,%edx
8010879d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087a0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801087a4:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801087aa:	81 c2 00 a7 11 80    	add    $0x8011a700,%edx
801087b0:	88 02                	mov    %al,(%edx)
          ncpu++;
801087b2:	a1 d0 a9 11 80       	mov    0x8011a9d0,%eax
801087b7:	83 c0 01             	add    $0x1,%eax
801087ba:	a3 d0 a9 11 80       	mov    %eax,0x8011a9d0
        }
        i += lapic_entry->record_len;
801087bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087c2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087c6:	0f b6 c0             	movzbl %al,%eax
801087c9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801087cc:	eb 50                	jmp    8010881e <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801087ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801087d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801087d7:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801087db:	a2 d4 a9 11 80       	mov    %al,0x8011a9d4
        i += ioapic->record_len;
801087e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801087e3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087e7:	0f b6 c0             	movzbl %al,%eax
801087ea:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801087ed:	eb 2f                	jmp    8010881e <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801087ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801087f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087f8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087fc:	0f b6 c0             	movzbl %al,%eax
801087ff:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108802:	eb 1a                	jmp    8010881e <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108807:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010880a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010880d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108811:	0f b6 c0             	movzbl %al,%eax
80108814:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108817:	eb 05                	jmp    8010881e <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80108819:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010881d:	90                   	nop
  while(i<madt->len){
8010881e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108821:	8b 40 04             	mov    0x4(%eax),%eax
80108824:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108827:	0f 82 34 ff ff ff    	jb     80108761 <mpinit_uefi+0x3d>
    }
  }

}
8010882d:	90                   	nop
8010882e:	90                   	nop
8010882f:	c9                   	leave  
80108830:	c3                   	ret    

80108831 <inb>:
{
80108831:	55                   	push   %ebp
80108832:	89 e5                	mov    %esp,%ebp
80108834:	83 ec 14             	sub    $0x14,%esp
80108837:	8b 45 08             	mov    0x8(%ebp),%eax
8010883a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010883e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108842:	89 c2                	mov    %eax,%edx
80108844:	ec                   	in     (%dx),%al
80108845:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108848:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010884c:	c9                   	leave  
8010884d:	c3                   	ret    

8010884e <outb>:
{
8010884e:	55                   	push   %ebp
8010884f:	89 e5                	mov    %esp,%ebp
80108851:	83 ec 08             	sub    $0x8,%esp
80108854:	8b 45 08             	mov    0x8(%ebp),%eax
80108857:	8b 55 0c             	mov    0xc(%ebp),%edx
8010885a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010885e:	89 d0                	mov    %edx,%eax
80108860:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108863:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108867:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010886b:	ee                   	out    %al,(%dx)
}
8010886c:	90                   	nop
8010886d:	c9                   	leave  
8010886e:	c3                   	ret    

8010886f <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010886f:	55                   	push   %ebp
80108870:	89 e5                	mov    %esp,%ebp
80108872:	83 ec 28             	sub    $0x28,%esp
80108875:	8b 45 08             	mov    0x8(%ebp),%eax
80108878:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010887b:	6a 00                	push   $0x0
8010887d:	68 fa 03 00 00       	push   $0x3fa
80108882:	e8 c7 ff ff ff       	call   8010884e <outb>
80108887:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010888a:	68 80 00 00 00       	push   $0x80
8010888f:	68 fb 03 00 00       	push   $0x3fb
80108894:	e8 b5 ff ff ff       	call   8010884e <outb>
80108899:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010889c:	6a 0c                	push   $0xc
8010889e:	68 f8 03 00 00       	push   $0x3f8
801088a3:	e8 a6 ff ff ff       	call   8010884e <outb>
801088a8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801088ab:	6a 00                	push   $0x0
801088ad:	68 f9 03 00 00       	push   $0x3f9
801088b2:	e8 97 ff ff ff       	call   8010884e <outb>
801088b7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801088ba:	6a 03                	push   $0x3
801088bc:	68 fb 03 00 00       	push   $0x3fb
801088c1:	e8 88 ff ff ff       	call   8010884e <outb>
801088c6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801088c9:	6a 00                	push   $0x0
801088cb:	68 fc 03 00 00       	push   $0x3fc
801088d0:	e8 79 ff ff ff       	call   8010884e <outb>
801088d5:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801088d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088df:	eb 11                	jmp    801088f2 <uart_debug+0x83>
801088e1:	83 ec 0c             	sub    $0xc,%esp
801088e4:	6a 0a                	push   $0xa
801088e6:	e8 30 a7 ff ff       	call   8010301b <microdelay>
801088eb:	83 c4 10             	add    $0x10,%esp
801088ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088f2:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801088f6:	7f 1a                	jg     80108912 <uart_debug+0xa3>
801088f8:	83 ec 0c             	sub    $0xc,%esp
801088fb:	68 fd 03 00 00       	push   $0x3fd
80108900:	e8 2c ff ff ff       	call   80108831 <inb>
80108905:	83 c4 10             	add    $0x10,%esp
80108908:	0f b6 c0             	movzbl %al,%eax
8010890b:	83 e0 20             	and    $0x20,%eax
8010890e:	85 c0                	test   %eax,%eax
80108910:	74 cf                	je     801088e1 <uart_debug+0x72>
  outb(COM1+0, p);
80108912:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108916:	0f b6 c0             	movzbl %al,%eax
80108919:	83 ec 08             	sub    $0x8,%esp
8010891c:	50                   	push   %eax
8010891d:	68 f8 03 00 00       	push   $0x3f8
80108922:	e8 27 ff ff ff       	call   8010884e <outb>
80108927:	83 c4 10             	add    $0x10,%esp
}
8010892a:	90                   	nop
8010892b:	c9                   	leave  
8010892c:	c3                   	ret    

8010892d <uart_debugs>:

void uart_debugs(char *p){
8010892d:	55                   	push   %ebp
8010892e:	89 e5                	mov    %esp,%ebp
80108930:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108933:	eb 1b                	jmp    80108950 <uart_debugs+0x23>
    uart_debug(*p++);
80108935:	8b 45 08             	mov    0x8(%ebp),%eax
80108938:	8d 50 01             	lea    0x1(%eax),%edx
8010893b:	89 55 08             	mov    %edx,0x8(%ebp)
8010893e:	0f b6 00             	movzbl (%eax),%eax
80108941:	0f be c0             	movsbl %al,%eax
80108944:	83 ec 0c             	sub    $0xc,%esp
80108947:	50                   	push   %eax
80108948:	e8 22 ff ff ff       	call   8010886f <uart_debug>
8010894d:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108950:	8b 45 08             	mov    0x8(%ebp),%eax
80108953:	0f b6 00             	movzbl (%eax),%eax
80108956:	84 c0                	test   %al,%al
80108958:	75 db                	jne    80108935 <uart_debugs+0x8>
  }
}
8010895a:	90                   	nop
8010895b:	90                   	nop
8010895c:	c9                   	leave  
8010895d:	c3                   	ret    

8010895e <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010895e:	55                   	push   %ebp
8010895f:	89 e5                	mov    %esp,%ebp
80108961:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108964:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010896b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010896e:	8b 50 14             	mov    0x14(%eax),%edx
80108971:	8b 40 10             	mov    0x10(%eax),%eax
80108974:	a3 d8 a9 11 80       	mov    %eax,0x8011a9d8
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108979:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010897c:	8b 50 1c             	mov    0x1c(%eax),%edx
8010897f:	8b 40 18             	mov    0x18(%eax),%eax
80108982:	a3 e0 a9 11 80       	mov    %eax,0x8011a9e0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108987:	8b 15 e0 a9 11 80    	mov    0x8011a9e0,%edx
8010898d:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108992:	29 d0                	sub    %edx,%eax
80108994:	a3 dc a9 11 80       	mov    %eax,0x8011a9dc
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108999:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010899c:	8b 50 24             	mov    0x24(%eax),%edx
8010899f:	8b 40 20             	mov    0x20(%eax),%eax
801089a2:	a3 e4 a9 11 80       	mov    %eax,0x8011a9e4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801089a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089aa:	8b 50 2c             	mov    0x2c(%eax),%edx
801089ad:	8b 40 28             	mov    0x28(%eax),%eax
801089b0:	a3 e8 a9 11 80       	mov    %eax,0x8011a9e8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801089b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089b8:	8b 50 34             	mov    0x34(%eax),%edx
801089bb:	8b 40 30             	mov    0x30(%eax),%eax
801089be:	a3 ec a9 11 80       	mov    %eax,0x8011a9ec
}
801089c3:	90                   	nop
801089c4:	c9                   	leave  
801089c5:	c3                   	ret    

801089c6 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801089c6:	55                   	push   %ebp
801089c7:	89 e5                	mov    %esp,%ebp
801089c9:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801089cc:	8b 15 ec a9 11 80    	mov    0x8011a9ec,%edx
801089d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801089d5:	0f af d0             	imul   %eax,%edx
801089d8:	8b 45 08             	mov    0x8(%ebp),%eax
801089db:	01 d0                	add    %edx,%eax
801089dd:	c1 e0 02             	shl    $0x2,%eax
801089e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801089e3:	8b 15 dc a9 11 80    	mov    0x8011a9dc,%edx
801089e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089ec:	01 d0                	add    %edx,%eax
801089ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801089f1:	8b 45 10             	mov    0x10(%ebp),%eax
801089f4:	0f b6 10             	movzbl (%eax),%edx
801089f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801089fa:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801089fc:	8b 45 10             	mov    0x10(%ebp),%eax
801089ff:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108a03:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a06:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108a09:	8b 45 10             	mov    0x10(%ebp),%eax
80108a0c:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108a10:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a13:	88 50 02             	mov    %dl,0x2(%eax)
}
80108a16:	90                   	nop
80108a17:	c9                   	leave  
80108a18:	c3                   	ret    

80108a19 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108a19:	55                   	push   %ebp
80108a1a:	89 e5                	mov    %esp,%ebp
80108a1c:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108a1f:	8b 15 ec a9 11 80    	mov    0x8011a9ec,%edx
80108a25:	8b 45 08             	mov    0x8(%ebp),%eax
80108a28:	0f af c2             	imul   %edx,%eax
80108a2b:	c1 e0 02             	shl    $0x2,%eax
80108a2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108a31:	a1 e0 a9 11 80       	mov    0x8011a9e0,%eax
80108a36:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a39:	29 d0                	sub    %edx,%eax
80108a3b:	8b 0d dc a9 11 80    	mov    0x8011a9dc,%ecx
80108a41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a44:	01 ca                	add    %ecx,%edx
80108a46:	89 d1                	mov    %edx,%ecx
80108a48:	8b 15 dc a9 11 80    	mov    0x8011a9dc,%edx
80108a4e:	83 ec 04             	sub    $0x4,%esp
80108a51:	50                   	push   %eax
80108a52:	51                   	push   %ecx
80108a53:	52                   	push   %edx
80108a54:	e8 cc c9 ff ff       	call   80105425 <memmove>
80108a59:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5f:	8b 0d dc a9 11 80    	mov    0x8011a9dc,%ecx
80108a65:	8b 15 e0 a9 11 80    	mov    0x8011a9e0,%edx
80108a6b:	01 ca                	add    %ecx,%edx
80108a6d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108a70:	29 ca                	sub    %ecx,%edx
80108a72:	83 ec 04             	sub    $0x4,%esp
80108a75:	50                   	push   %eax
80108a76:	6a 00                	push   $0x0
80108a78:	52                   	push   %edx
80108a79:	e8 e8 c8 ff ff       	call   80105366 <memset>
80108a7e:	83 c4 10             	add    $0x10,%esp
}
80108a81:	90                   	nop
80108a82:	c9                   	leave  
80108a83:	c3                   	ret    

80108a84 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108a84:	55                   	push   %ebp
80108a85:	89 e5                	mov    %esp,%ebp
80108a87:	53                   	push   %ebx
80108a88:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108a8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a92:	e9 b1 00 00 00       	jmp    80108b48 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108a97:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108a9e:	e9 97 00 00 00       	jmp    80108b3a <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108aa3:	8b 45 10             	mov    0x10(%ebp),%eax
80108aa6:	83 e8 20             	sub    $0x20,%eax
80108aa9:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aaf:	01 d0                	add    %edx,%eax
80108ab1:	0f b7 84 00 e0 b1 10 	movzwl -0x7fef4e20(%eax,%eax,1),%eax
80108ab8:	80 
80108ab9:	0f b7 d0             	movzwl %ax,%edx
80108abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108abf:	bb 01 00 00 00       	mov    $0x1,%ebx
80108ac4:	89 c1                	mov    %eax,%ecx
80108ac6:	d3 e3                	shl    %cl,%ebx
80108ac8:	89 d8                	mov    %ebx,%eax
80108aca:	21 d0                	and    %edx,%eax
80108acc:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad2:	ba 01 00 00 00       	mov    $0x1,%edx
80108ad7:	89 c1                	mov    %eax,%ecx
80108ad9:	d3 e2                	shl    %cl,%edx
80108adb:	89 d0                	mov    %edx,%eax
80108add:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108ae0:	75 2b                	jne    80108b0d <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108ae2:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae8:	01 c2                	add    %eax,%edx
80108aea:	b8 0e 00 00 00       	mov    $0xe,%eax
80108aef:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108af2:	89 c1                	mov    %eax,%ecx
80108af4:	8b 45 08             	mov    0x8(%ebp),%eax
80108af7:	01 c8                	add    %ecx,%eax
80108af9:	83 ec 04             	sub    $0x4,%esp
80108afc:	68 00 f5 10 80       	push   $0x8010f500
80108b01:	52                   	push   %edx
80108b02:	50                   	push   %eax
80108b03:	e8 be fe ff ff       	call   801089c6 <graphic_draw_pixel>
80108b08:	83 c4 10             	add    $0x10,%esp
80108b0b:	eb 29                	jmp    80108b36 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b13:	01 c2                	add    %eax,%edx
80108b15:	b8 0e 00 00 00       	mov    $0xe,%eax
80108b1a:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108b1d:	89 c1                	mov    %eax,%ecx
80108b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80108b22:	01 c8                	add    %ecx,%eax
80108b24:	83 ec 04             	sub    $0x4,%esp
80108b27:	68 f0 a9 11 80       	push   $0x8011a9f0
80108b2c:	52                   	push   %edx
80108b2d:	50                   	push   %eax
80108b2e:	e8 93 fe ff ff       	call   801089c6 <graphic_draw_pixel>
80108b33:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108b36:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108b3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b3e:	0f 89 5f ff ff ff    	jns    80108aa3 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108b44:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b48:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108b4c:	0f 8e 45 ff ff ff    	jle    80108a97 <font_render+0x13>
      }
    }
  }
}
80108b52:	90                   	nop
80108b53:	90                   	nop
80108b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b57:	c9                   	leave  
80108b58:	c3                   	ret    

80108b59 <font_render_string>:

void font_render_string(char *string,int row){
80108b59:	55                   	push   %ebp
80108b5a:	89 e5                	mov    %esp,%ebp
80108b5c:	53                   	push   %ebx
80108b5d:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108b60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108b67:	eb 33                	jmp    80108b9c <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108b69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80108b6f:	01 d0                	add    %edx,%eax
80108b71:	0f b6 00             	movzbl (%eax),%eax
80108b74:	0f be c8             	movsbl %al,%ecx
80108b77:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b7a:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108b7d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108b80:	89 d8                	mov    %ebx,%eax
80108b82:	c1 e0 04             	shl    $0x4,%eax
80108b85:	29 d8                	sub    %ebx,%eax
80108b87:	83 c0 02             	add    $0x2,%eax
80108b8a:	83 ec 04             	sub    $0x4,%esp
80108b8d:	51                   	push   %ecx
80108b8e:	52                   	push   %edx
80108b8f:	50                   	push   %eax
80108b90:	e8 ef fe ff ff       	call   80108a84 <font_render>
80108b95:	83 c4 10             	add    $0x10,%esp
    i++;
80108b98:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80108ba2:	01 d0                	add    %edx,%eax
80108ba4:	0f b6 00             	movzbl (%eax),%eax
80108ba7:	84 c0                	test   %al,%al
80108ba9:	74 06                	je     80108bb1 <font_render_string+0x58>
80108bab:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108baf:	7e b8                	jle    80108b69 <font_render_string+0x10>
  }
}
80108bb1:	90                   	nop
80108bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108bb5:	c9                   	leave  
80108bb6:	c3                   	ret    

80108bb7 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108bb7:	55                   	push   %ebp
80108bb8:	89 e5                	mov    %esp,%ebp
80108bba:	53                   	push   %ebx
80108bbb:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108bbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bc5:	eb 6b                	jmp    80108c32 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108bc7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108bce:	eb 58                	jmp    80108c28 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108bd0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108bd7:	eb 45                	jmp    80108c1e <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108bd9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108bdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be2:	83 ec 0c             	sub    $0xc,%esp
80108be5:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108be8:	53                   	push   %ebx
80108be9:	6a 00                	push   $0x0
80108beb:	51                   	push   %ecx
80108bec:	52                   	push   %edx
80108bed:	50                   	push   %eax
80108bee:	e8 b0 00 00 00       	call   80108ca3 <pci_access_config>
80108bf3:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108bf6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bf9:	0f b7 c0             	movzwl %ax,%eax
80108bfc:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108c01:	74 17                	je     80108c1a <pci_init+0x63>
        pci_init_device(i,j,k);
80108c03:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108c06:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c0c:	83 ec 04             	sub    $0x4,%esp
80108c0f:	51                   	push   %ecx
80108c10:	52                   	push   %edx
80108c11:	50                   	push   %eax
80108c12:	e8 37 01 00 00       	call   80108d4e <pci_init_device>
80108c17:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108c1a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108c1e:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108c22:	7e b5                	jle    80108bd9 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108c24:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108c28:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108c2c:	7e a2                	jle    80108bd0 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108c2e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c32:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108c39:	7e 8c                	jle    80108bc7 <pci_init+0x10>
      }
      }
    }
  }
}
80108c3b:	90                   	nop
80108c3c:	90                   	nop
80108c3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c40:	c9                   	leave  
80108c41:	c3                   	ret    

80108c42 <pci_write_config>:

void pci_write_config(uint config){
80108c42:	55                   	push   %ebp
80108c43:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108c45:	8b 45 08             	mov    0x8(%ebp),%eax
80108c48:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108c4d:	89 c0                	mov    %eax,%eax
80108c4f:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108c50:	90                   	nop
80108c51:	5d                   	pop    %ebp
80108c52:	c3                   	ret    

80108c53 <pci_write_data>:

void pci_write_data(uint config){
80108c53:	55                   	push   %ebp
80108c54:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108c56:	8b 45 08             	mov    0x8(%ebp),%eax
80108c59:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108c5e:	89 c0                	mov    %eax,%eax
80108c60:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108c61:	90                   	nop
80108c62:	5d                   	pop    %ebp
80108c63:	c3                   	ret    

80108c64 <pci_read_config>:
uint pci_read_config(){
80108c64:	55                   	push   %ebp
80108c65:	89 e5                	mov    %esp,%ebp
80108c67:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108c6a:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108c6f:	ed                   	in     (%dx),%eax
80108c70:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108c73:	83 ec 0c             	sub    $0xc,%esp
80108c76:	68 c8 00 00 00       	push   $0xc8
80108c7b:	e8 9b a3 ff ff       	call   8010301b <microdelay>
80108c80:	83 c4 10             	add    $0x10,%esp
  return data;
80108c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108c86:	c9                   	leave  
80108c87:	c3                   	ret    

80108c88 <pci_test>:


void pci_test(){
80108c88:	55                   	push   %ebp
80108c89:	89 e5                	mov    %esp,%ebp
80108c8b:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108c8e:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108c95:	ff 75 fc             	push   -0x4(%ebp)
80108c98:	e8 a5 ff ff ff       	call   80108c42 <pci_write_config>
80108c9d:	83 c4 04             	add    $0x4,%esp
}
80108ca0:	90                   	nop
80108ca1:	c9                   	leave  
80108ca2:	c3                   	ret    

80108ca3 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108ca3:	55                   	push   %ebp
80108ca4:	89 e5                	mov    %esp,%ebp
80108ca6:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80108cac:	c1 e0 10             	shl    $0x10,%eax
80108caf:	25 00 00 ff 00       	and    $0xff0000,%eax
80108cb4:	89 c2                	mov    %eax,%edx
80108cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cb9:	c1 e0 0b             	shl    $0xb,%eax
80108cbc:	0f b7 c0             	movzwl %ax,%eax
80108cbf:	09 c2                	or     %eax,%edx
80108cc1:	8b 45 10             	mov    0x10(%ebp),%eax
80108cc4:	c1 e0 08             	shl    $0x8,%eax
80108cc7:	25 00 07 00 00       	and    $0x700,%eax
80108ccc:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108cce:	8b 45 14             	mov    0x14(%ebp),%eax
80108cd1:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108cd6:	09 d0                	or     %edx,%eax
80108cd8:	0d 00 00 00 80       	or     $0x80000000,%eax
80108cdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108ce0:	ff 75 f4             	push   -0xc(%ebp)
80108ce3:	e8 5a ff ff ff       	call   80108c42 <pci_write_config>
80108ce8:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108ceb:	e8 74 ff ff ff       	call   80108c64 <pci_read_config>
80108cf0:	8b 55 18             	mov    0x18(%ebp),%edx
80108cf3:	89 02                	mov    %eax,(%edx)
}
80108cf5:	90                   	nop
80108cf6:	c9                   	leave  
80108cf7:	c3                   	ret    

80108cf8 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108cf8:	55                   	push   %ebp
80108cf9:	89 e5                	mov    %esp,%ebp
80108cfb:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80108d01:	c1 e0 10             	shl    $0x10,%eax
80108d04:	25 00 00 ff 00       	and    $0xff0000,%eax
80108d09:	89 c2                	mov    %eax,%edx
80108d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d0e:	c1 e0 0b             	shl    $0xb,%eax
80108d11:	0f b7 c0             	movzwl %ax,%eax
80108d14:	09 c2                	or     %eax,%edx
80108d16:	8b 45 10             	mov    0x10(%ebp),%eax
80108d19:	c1 e0 08             	shl    $0x8,%eax
80108d1c:	25 00 07 00 00       	and    $0x700,%eax
80108d21:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108d23:	8b 45 14             	mov    0x14(%ebp),%eax
80108d26:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108d2b:	09 d0                	or     %edx,%eax
80108d2d:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d32:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108d35:	ff 75 fc             	push   -0x4(%ebp)
80108d38:	e8 05 ff ff ff       	call   80108c42 <pci_write_config>
80108d3d:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108d40:	ff 75 18             	push   0x18(%ebp)
80108d43:	e8 0b ff ff ff       	call   80108c53 <pci_write_data>
80108d48:	83 c4 04             	add    $0x4,%esp
}
80108d4b:	90                   	nop
80108d4c:	c9                   	leave  
80108d4d:	c3                   	ret    

80108d4e <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108d4e:	55                   	push   %ebp
80108d4f:	89 e5                	mov    %esp,%ebp
80108d51:	53                   	push   %ebx
80108d52:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108d55:	8b 45 08             	mov    0x8(%ebp),%eax
80108d58:	a2 f4 a9 11 80       	mov    %al,0x8011a9f4
  dev.device_num = device_num;
80108d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d60:	a2 f5 a9 11 80       	mov    %al,0x8011a9f5
  dev.function_num = function_num;
80108d65:	8b 45 10             	mov    0x10(%ebp),%eax
80108d68:	a2 f6 a9 11 80       	mov    %al,0x8011a9f6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108d6d:	ff 75 10             	push   0x10(%ebp)
80108d70:	ff 75 0c             	push   0xc(%ebp)
80108d73:	ff 75 08             	push   0x8(%ebp)
80108d76:	68 24 c8 10 80       	push   $0x8010c824
80108d7b:	e8 74 76 ff ff       	call   801003f4 <cprintf>
80108d80:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108d83:	83 ec 0c             	sub    $0xc,%esp
80108d86:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d89:	50                   	push   %eax
80108d8a:	6a 00                	push   $0x0
80108d8c:	ff 75 10             	push   0x10(%ebp)
80108d8f:	ff 75 0c             	push   0xc(%ebp)
80108d92:	ff 75 08             	push   0x8(%ebp)
80108d95:	e8 09 ff ff ff       	call   80108ca3 <pci_access_config>
80108d9a:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108d9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108da0:	c1 e8 10             	shr    $0x10,%eax
80108da3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108da6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108da9:	25 ff ff 00 00       	and    $0xffff,%eax
80108dae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db4:	a3 f8 a9 11 80       	mov    %eax,0x8011a9f8
  dev.vendor_id = vendor_id;
80108db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dbc:	a3 fc a9 11 80       	mov    %eax,0x8011a9fc
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108dc1:	83 ec 04             	sub    $0x4,%esp
80108dc4:	ff 75 f0             	push   -0x10(%ebp)
80108dc7:	ff 75 f4             	push   -0xc(%ebp)
80108dca:	68 58 c8 10 80       	push   $0x8010c858
80108dcf:	e8 20 76 ff ff       	call   801003f4 <cprintf>
80108dd4:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108dd7:	83 ec 0c             	sub    $0xc,%esp
80108dda:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ddd:	50                   	push   %eax
80108dde:	6a 08                	push   $0x8
80108de0:	ff 75 10             	push   0x10(%ebp)
80108de3:	ff 75 0c             	push   0xc(%ebp)
80108de6:	ff 75 08             	push   0x8(%ebp)
80108de9:	e8 b5 fe ff ff       	call   80108ca3 <pci_access_config>
80108dee:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108df4:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108df7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dfa:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108dfd:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108e00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e03:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108e06:	0f b6 c0             	movzbl %al,%eax
80108e09:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108e0c:	c1 eb 18             	shr    $0x18,%ebx
80108e0f:	83 ec 0c             	sub    $0xc,%esp
80108e12:	51                   	push   %ecx
80108e13:	52                   	push   %edx
80108e14:	50                   	push   %eax
80108e15:	53                   	push   %ebx
80108e16:	68 7c c8 10 80       	push   $0x8010c87c
80108e1b:	e8 d4 75 ff ff       	call   801003f4 <cprintf>
80108e20:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108e23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e26:	c1 e8 18             	shr    $0x18,%eax
80108e29:	a2 00 aa 11 80       	mov    %al,0x8011aa00
  dev.sub_class = (data>>16)&0xFF;
80108e2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e31:	c1 e8 10             	shr    $0x10,%eax
80108e34:	a2 01 aa 11 80       	mov    %al,0x8011aa01
  dev.interface = (data>>8)&0xFF;
80108e39:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e3c:	c1 e8 08             	shr    $0x8,%eax
80108e3f:	a2 02 aa 11 80       	mov    %al,0x8011aa02
  dev.revision_id = data&0xFF;
80108e44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e47:	a2 03 aa 11 80       	mov    %al,0x8011aa03
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108e4c:	83 ec 0c             	sub    $0xc,%esp
80108e4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e52:	50                   	push   %eax
80108e53:	6a 10                	push   $0x10
80108e55:	ff 75 10             	push   0x10(%ebp)
80108e58:	ff 75 0c             	push   0xc(%ebp)
80108e5b:	ff 75 08             	push   0x8(%ebp)
80108e5e:	e8 40 fe ff ff       	call   80108ca3 <pci_access_config>
80108e63:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108e66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e69:	a3 04 aa 11 80       	mov    %eax,0x8011aa04
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108e6e:	83 ec 0c             	sub    $0xc,%esp
80108e71:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e74:	50                   	push   %eax
80108e75:	6a 14                	push   $0x14
80108e77:	ff 75 10             	push   0x10(%ebp)
80108e7a:	ff 75 0c             	push   0xc(%ebp)
80108e7d:	ff 75 08             	push   0x8(%ebp)
80108e80:	e8 1e fe ff ff       	call   80108ca3 <pci_access_config>
80108e85:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108e88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e8b:	a3 08 aa 11 80       	mov    %eax,0x8011aa08
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108e90:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108e97:	75 5a                	jne    80108ef3 <pci_init_device+0x1a5>
80108e99:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108ea0:	75 51                	jne    80108ef3 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108ea2:	83 ec 0c             	sub    $0xc,%esp
80108ea5:	68 c1 c8 10 80       	push   $0x8010c8c1
80108eaa:	e8 45 75 ff ff       	call   801003f4 <cprintf>
80108eaf:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108eb2:	83 ec 0c             	sub    $0xc,%esp
80108eb5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108eb8:	50                   	push   %eax
80108eb9:	68 f0 00 00 00       	push   $0xf0
80108ebe:	ff 75 10             	push   0x10(%ebp)
80108ec1:	ff 75 0c             	push   0xc(%ebp)
80108ec4:	ff 75 08             	push   0x8(%ebp)
80108ec7:	e8 d7 fd ff ff       	call   80108ca3 <pci_access_config>
80108ecc:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108ecf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ed2:	83 ec 08             	sub    $0x8,%esp
80108ed5:	50                   	push   %eax
80108ed6:	68 db c8 10 80       	push   $0x8010c8db
80108edb:	e8 14 75 ff ff       	call   801003f4 <cprintf>
80108ee0:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108ee3:	83 ec 0c             	sub    $0xc,%esp
80108ee6:	68 f4 a9 11 80       	push   $0x8011a9f4
80108eeb:	e8 09 00 00 00       	call   80108ef9 <i8254_init>
80108ef0:	83 c4 10             	add    $0x10,%esp
  }
}
80108ef3:	90                   	nop
80108ef4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ef7:	c9                   	leave  
80108ef8:	c3                   	ret    

80108ef9 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108ef9:	55                   	push   %ebp
80108efa:	89 e5                	mov    %esp,%ebp
80108efc:	53                   	push   %ebx
80108efd:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108f00:	8b 45 08             	mov    0x8(%ebp),%eax
80108f03:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108f07:	0f b6 c8             	movzbl %al,%ecx
80108f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f0d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108f11:	0f b6 d0             	movzbl %al,%edx
80108f14:	8b 45 08             	mov    0x8(%ebp),%eax
80108f17:	0f b6 00             	movzbl (%eax),%eax
80108f1a:	0f b6 c0             	movzbl %al,%eax
80108f1d:	83 ec 0c             	sub    $0xc,%esp
80108f20:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108f23:	53                   	push   %ebx
80108f24:	6a 04                	push   $0x4
80108f26:	51                   	push   %ecx
80108f27:	52                   	push   %edx
80108f28:	50                   	push   %eax
80108f29:	e8 75 fd ff ff       	call   80108ca3 <pci_access_config>
80108f2e:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f34:	83 c8 04             	or     $0x4,%eax
80108f37:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108f3a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80108f40:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108f44:	0f b6 c8             	movzbl %al,%ecx
80108f47:	8b 45 08             	mov    0x8(%ebp),%eax
80108f4a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108f4e:	0f b6 d0             	movzbl %al,%edx
80108f51:	8b 45 08             	mov    0x8(%ebp),%eax
80108f54:	0f b6 00             	movzbl (%eax),%eax
80108f57:	0f b6 c0             	movzbl %al,%eax
80108f5a:	83 ec 0c             	sub    $0xc,%esp
80108f5d:	53                   	push   %ebx
80108f5e:	6a 04                	push   $0x4
80108f60:	51                   	push   %ecx
80108f61:	52                   	push   %edx
80108f62:	50                   	push   %eax
80108f63:	e8 90 fd ff ff       	call   80108cf8 <pci_write_config_register>
80108f68:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80108f6e:	8b 40 10             	mov    0x10(%eax),%eax
80108f71:	05 00 00 00 40       	add    $0x40000000,%eax
80108f76:	a3 0c aa 11 80       	mov    %eax,0x8011aa0c
  uint *ctrl = (uint *)base_addr;
80108f7b:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80108f80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108f83:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80108f88:	05 d8 00 00 00       	add    $0xd8,%eax
80108f8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f93:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9c:	8b 00                	mov    (%eax),%eax
80108f9e:	0d 00 00 00 04       	or     $0x4000000,%eax
80108fa3:	89 c2                	mov    %eax,%edx
80108fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa8:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fad:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb6:	8b 00                	mov    (%eax),%eax
80108fb8:	83 c8 40             	or     $0x40,%eax
80108fbb:	89 c2                	mov    %eax,%edx
80108fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc0:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc5:	8b 10                	mov    (%eax),%edx
80108fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fca:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108fcc:	83 ec 0c             	sub    $0xc,%esp
80108fcf:	68 f0 c8 10 80       	push   $0x8010c8f0
80108fd4:	e8 1b 74 ff ff       	call   801003f4 <cprintf>
80108fd9:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108fdc:	e8 a3 9c ff ff       	call   80102c84 <kalloc>
80108fe1:	a3 18 aa 11 80       	mov    %eax,0x8011aa18
  *intr_addr = 0;
80108fe6:	a1 18 aa 11 80       	mov    0x8011aa18,%eax
80108feb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108ff1:	a1 18 aa 11 80       	mov    0x8011aa18,%eax
80108ff6:	83 ec 08             	sub    $0x8,%esp
80108ff9:	50                   	push   %eax
80108ffa:	68 12 c9 10 80       	push   $0x8010c912
80108fff:	e8 f0 73 ff ff       	call   801003f4 <cprintf>
80109004:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80109007:	e8 50 00 00 00       	call   8010905c <i8254_init_recv>
  i8254_init_send();
8010900c:	e8 69 03 00 00       	call   8010937a <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80109011:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109018:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010901b:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109022:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80109025:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010902c:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010902f:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109036:	0f b6 c0             	movzbl %al,%eax
80109039:	83 ec 0c             	sub    $0xc,%esp
8010903c:	53                   	push   %ebx
8010903d:	51                   	push   %ecx
8010903e:	52                   	push   %edx
8010903f:	50                   	push   %eax
80109040:	68 20 c9 10 80       	push   $0x8010c920
80109045:	e8 aa 73 ff ff       	call   801003f4 <cprintf>
8010904a:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010904d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109050:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80109056:	90                   	nop
80109057:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010905a:	c9                   	leave  
8010905b:	c3                   	ret    

8010905c <i8254_init_recv>:

void i8254_init_recv(){
8010905c:	55                   	push   %ebp
8010905d:	89 e5                	mov    %esp,%ebp
8010905f:	57                   	push   %edi
80109060:	56                   	push   %esi
80109061:	53                   	push   %ebx
80109062:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80109065:	83 ec 0c             	sub    $0xc,%esp
80109068:	6a 00                	push   $0x0
8010906a:	e8 e8 04 00 00       	call   80109557 <i8254_read_eeprom>
8010906f:	83 c4 10             	add    $0x10,%esp
80109072:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80109075:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109078:	a2 10 aa 11 80       	mov    %al,0x8011aa10
  mac_addr[1] = data_l>>8;
8010907d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109080:	c1 e8 08             	shr    $0x8,%eax
80109083:	a2 11 aa 11 80       	mov    %al,0x8011aa11
  uint data_m = i8254_read_eeprom(0x1);
80109088:	83 ec 0c             	sub    $0xc,%esp
8010908b:	6a 01                	push   $0x1
8010908d:	e8 c5 04 00 00       	call   80109557 <i8254_read_eeprom>
80109092:	83 c4 10             	add    $0x10,%esp
80109095:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80109098:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010909b:	a2 12 aa 11 80       	mov    %al,0x8011aa12
  mac_addr[3] = data_m>>8;
801090a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801090a3:	c1 e8 08             	shr    $0x8,%eax
801090a6:	a2 13 aa 11 80       	mov    %al,0x8011aa13
  uint data_h = i8254_read_eeprom(0x2);
801090ab:	83 ec 0c             	sub    $0xc,%esp
801090ae:	6a 02                	push   $0x2
801090b0:	e8 a2 04 00 00       	call   80109557 <i8254_read_eeprom>
801090b5:	83 c4 10             	add    $0x10,%esp
801090b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801090bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090be:	a2 14 aa 11 80       	mov    %al,0x8011aa14
  mac_addr[5] = data_h>>8;
801090c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090c6:	c1 e8 08             	shr    $0x8,%eax
801090c9:	a2 15 aa 11 80       	mov    %al,0x8011aa15
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801090ce:	0f b6 05 15 aa 11 80 	movzbl 0x8011aa15,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090d5:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801090d8:	0f b6 05 14 aa 11 80 	movzbl 0x8011aa14,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090df:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801090e2:	0f b6 05 13 aa 11 80 	movzbl 0x8011aa13,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090e9:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801090ec:	0f b6 05 12 aa 11 80 	movzbl 0x8011aa12,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090f3:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801090f6:	0f b6 05 11 aa 11 80 	movzbl 0x8011aa11,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090fd:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80109100:	0f b6 05 10 aa 11 80 	movzbl 0x8011aa10,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109107:	0f b6 c0             	movzbl %al,%eax
8010910a:	83 ec 04             	sub    $0x4,%esp
8010910d:	57                   	push   %edi
8010910e:	56                   	push   %esi
8010910f:	53                   	push   %ebx
80109110:	51                   	push   %ecx
80109111:	52                   	push   %edx
80109112:	50                   	push   %eax
80109113:	68 38 c9 10 80       	push   $0x8010c938
80109118:	e8 d7 72 ff ff       	call   801003f4 <cprintf>
8010911d:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80109120:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109125:	05 00 54 00 00       	add    $0x5400,%eax
8010912a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010912d:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109132:	05 04 54 00 00       	add    $0x5404,%eax
80109137:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
8010913a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010913d:	c1 e0 10             	shl    $0x10,%eax
80109140:	0b 45 d8             	or     -0x28(%ebp),%eax
80109143:	89 c2                	mov    %eax,%edx
80109145:	8b 45 cc             	mov    -0x34(%ebp),%eax
80109148:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
8010914a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010914d:	0d 00 00 00 80       	or     $0x80000000,%eax
80109152:	89 c2                	mov    %eax,%edx
80109154:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109157:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80109159:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010915e:	05 00 52 00 00       	add    $0x5200,%eax
80109163:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80109166:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010916d:	eb 19                	jmp    80109188 <i8254_init_recv+0x12c>
    mta[i] = 0;
8010916f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109172:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109179:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010917c:	01 d0                	add    %edx,%eax
8010917e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80109184:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80109188:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
8010918c:	7e e1                	jle    8010916f <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
8010918e:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109193:	05 d0 00 00 00       	add    $0xd0,%eax
80109198:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010919b:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010919e:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801091a4:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801091a9:	05 c8 00 00 00       	add    $0xc8,%eax
801091ae:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801091b1:	8b 45 bc             	mov    -0x44(%ebp),%eax
801091b4:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801091ba:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801091bf:	05 28 28 00 00       	add    $0x2828,%eax
801091c4:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801091c7:	8b 45 b8             	mov    -0x48(%ebp),%eax
801091ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801091d0:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801091d5:	05 00 01 00 00       	add    $0x100,%eax
801091da:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801091dd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801091e0:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801091e6:	e8 99 9a ff ff       	call   80102c84 <kalloc>
801091eb:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801091ee:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801091f3:	05 00 28 00 00       	add    $0x2800,%eax
801091f8:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801091fb:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109200:	05 04 28 00 00       	add    $0x2804,%eax
80109205:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80109208:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010920d:	05 08 28 00 00       	add    $0x2808,%eax
80109212:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80109215:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010921a:	05 10 28 00 00       	add    $0x2810,%eax
8010921f:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109222:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109227:	05 18 28 00 00       	add    $0x2818,%eax
8010922c:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
8010922f:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109232:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109238:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010923b:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
8010923d:	8b 45 a8             	mov    -0x58(%ebp),%eax
80109240:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80109246:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80109249:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
8010924f:	8b 45 a0             	mov    -0x60(%ebp),%eax
80109252:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80109258:	8b 45 9c             	mov    -0x64(%ebp),%eax
8010925b:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80109261:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109264:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109267:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010926e:	eb 73                	jmp    801092e3 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80109270:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109273:	c1 e0 04             	shl    $0x4,%eax
80109276:	89 c2                	mov    %eax,%edx
80109278:	8b 45 98             	mov    -0x68(%ebp),%eax
8010927b:	01 d0                	add    %edx,%eax
8010927d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80109284:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109287:	c1 e0 04             	shl    $0x4,%eax
8010928a:	89 c2                	mov    %eax,%edx
8010928c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010928f:	01 d0                	add    %edx,%eax
80109291:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80109297:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010929a:	c1 e0 04             	shl    $0x4,%eax
8010929d:	89 c2                	mov    %eax,%edx
8010929f:	8b 45 98             	mov    -0x68(%ebp),%eax
801092a2:	01 d0                	add    %edx,%eax
801092a4:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801092aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092ad:	c1 e0 04             	shl    $0x4,%eax
801092b0:	89 c2                	mov    %eax,%edx
801092b2:	8b 45 98             	mov    -0x68(%ebp),%eax
801092b5:	01 d0                	add    %edx,%eax
801092b7:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801092bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092be:	c1 e0 04             	shl    $0x4,%eax
801092c1:	89 c2                	mov    %eax,%edx
801092c3:	8b 45 98             	mov    -0x68(%ebp),%eax
801092c6:	01 d0                	add    %edx,%eax
801092c8:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801092cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092cf:	c1 e0 04             	shl    $0x4,%eax
801092d2:	89 c2                	mov    %eax,%edx
801092d4:	8b 45 98             	mov    -0x68(%ebp),%eax
801092d7:	01 d0                	add    %edx,%eax
801092d9:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801092df:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801092e3:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
801092ea:	7e 84                	jle    80109270 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801092ec:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801092f3:	eb 57                	jmp    8010934c <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
801092f5:	e8 8a 99 ff ff       	call   80102c84 <kalloc>
801092fa:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801092fd:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109301:	75 12                	jne    80109315 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80109303:	83 ec 0c             	sub    $0xc,%esp
80109306:	68 58 c9 10 80       	push   $0x8010c958
8010930b:	e8 e4 70 ff ff       	call   801003f4 <cprintf>
80109310:	83 c4 10             	add    $0x10,%esp
      break;
80109313:	eb 3d                	jmp    80109352 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109315:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109318:	c1 e0 04             	shl    $0x4,%eax
8010931b:	89 c2                	mov    %eax,%edx
8010931d:	8b 45 98             	mov    -0x68(%ebp),%eax
80109320:	01 d0                	add    %edx,%eax
80109322:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109325:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010932b:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010932d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109330:	83 c0 01             	add    $0x1,%eax
80109333:	c1 e0 04             	shl    $0x4,%eax
80109336:	89 c2                	mov    %eax,%edx
80109338:	8b 45 98             	mov    -0x68(%ebp),%eax
8010933b:	01 d0                	add    %edx,%eax
8010933d:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109340:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109346:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109348:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
8010934c:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80109350:	7e a3                	jle    801092f5 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80109352:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109355:	8b 00                	mov    (%eax),%eax
80109357:	83 c8 02             	or     $0x2,%eax
8010935a:	89 c2                	mov    %eax,%edx
8010935c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010935f:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80109361:	83 ec 0c             	sub    $0xc,%esp
80109364:	68 78 c9 10 80       	push   $0x8010c978
80109369:	e8 86 70 ff ff       	call   801003f4 <cprintf>
8010936e:	83 c4 10             	add    $0x10,%esp
}
80109371:	90                   	nop
80109372:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109375:	5b                   	pop    %ebx
80109376:	5e                   	pop    %esi
80109377:	5f                   	pop    %edi
80109378:	5d                   	pop    %ebp
80109379:	c3                   	ret    

8010937a <i8254_init_send>:

void i8254_init_send(){
8010937a:	55                   	push   %ebp
8010937b:	89 e5                	mov    %esp,%ebp
8010937d:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80109380:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109385:	05 28 38 00 00       	add    $0x3828,%eax
8010938a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010938d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109390:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80109396:	e8 e9 98 ff ff       	call   80102c84 <kalloc>
8010939b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010939e:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801093a3:	05 00 38 00 00       	add    $0x3800,%eax
801093a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801093ab:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801093b0:	05 04 38 00 00       	add    $0x3804,%eax
801093b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801093b8:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801093bd:	05 08 38 00 00       	add    $0x3808,%eax
801093c2:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801093c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093c8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801093ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801093d1:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
801093d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801093d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
801093dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801093df:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
801093e5:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801093ea:	05 10 38 00 00       	add    $0x3810,%eax
801093ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801093f2:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801093f7:	05 18 38 00 00       	add    $0x3818,%eax
801093fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
801093ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109402:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010940b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109411:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109414:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010941e:	e9 82 00 00 00       	jmp    801094a5 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80109423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109426:	c1 e0 04             	shl    $0x4,%eax
80109429:	89 c2                	mov    %eax,%edx
8010942b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010942e:	01 d0                	add    %edx,%eax
80109430:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80109437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010943a:	c1 e0 04             	shl    $0x4,%eax
8010943d:	89 c2                	mov    %eax,%edx
8010943f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109442:	01 d0                	add    %edx,%eax
80109444:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
8010944a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010944d:	c1 e0 04             	shl    $0x4,%eax
80109450:	89 c2                	mov    %eax,%edx
80109452:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109455:	01 d0                	add    %edx,%eax
80109457:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
8010945b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010945e:	c1 e0 04             	shl    $0x4,%eax
80109461:	89 c2                	mov    %eax,%edx
80109463:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109466:	01 d0                	add    %edx,%eax
80109468:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
8010946c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010946f:	c1 e0 04             	shl    $0x4,%eax
80109472:	89 c2                	mov    %eax,%edx
80109474:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109477:	01 d0                	add    %edx,%eax
80109479:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
8010947d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109480:	c1 e0 04             	shl    $0x4,%eax
80109483:	89 c2                	mov    %eax,%edx
80109485:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109488:	01 d0                	add    %edx,%eax
8010948a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
8010948e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109491:	c1 e0 04             	shl    $0x4,%eax
80109494:	89 c2                	mov    %eax,%edx
80109496:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109499:	01 d0                	add    %edx,%eax
8010949b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801094a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094a5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801094ac:	0f 8e 71 ff ff ff    	jle    80109423 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801094b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801094b9:	eb 57                	jmp    80109512 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
801094bb:	e8 c4 97 ff ff       	call   80102c84 <kalloc>
801094c0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801094c3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801094c7:	75 12                	jne    801094db <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
801094c9:	83 ec 0c             	sub    $0xc,%esp
801094cc:	68 58 c9 10 80       	push   $0x8010c958
801094d1:	e8 1e 6f ff ff       	call   801003f4 <cprintf>
801094d6:	83 c4 10             	add    $0x10,%esp
      break;
801094d9:	eb 3d                	jmp    80109518 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
801094db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094de:	c1 e0 04             	shl    $0x4,%eax
801094e1:	89 c2                	mov    %eax,%edx
801094e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094e6:	01 d0                	add    %edx,%eax
801094e8:	8b 55 cc             	mov    -0x34(%ebp),%edx
801094eb:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801094f1:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801094f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094f6:	83 c0 01             	add    $0x1,%eax
801094f9:	c1 e0 04             	shl    $0x4,%eax
801094fc:	89 c2                	mov    %eax,%edx
801094fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109501:	01 d0                	add    %edx,%eax
80109503:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109506:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010950c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010950e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109512:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109516:	7e a3                	jle    801094bb <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109518:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010951d:	05 00 04 00 00       	add    $0x400,%eax
80109522:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109525:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109528:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010952e:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109533:	05 10 04 00 00       	add    $0x410,%eax
80109538:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010953b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010953e:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109544:	83 ec 0c             	sub    $0xc,%esp
80109547:	68 98 c9 10 80       	push   $0x8010c998
8010954c:	e8 a3 6e ff ff       	call   801003f4 <cprintf>
80109551:	83 c4 10             	add    $0x10,%esp

}
80109554:	90                   	nop
80109555:	c9                   	leave  
80109556:	c3                   	ret    

80109557 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109557:	55                   	push   %ebp
80109558:	89 e5                	mov    %esp,%ebp
8010955a:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
8010955d:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109562:	83 c0 14             	add    $0x14,%eax
80109565:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80109568:	8b 45 08             	mov    0x8(%ebp),%eax
8010956b:	c1 e0 08             	shl    $0x8,%eax
8010956e:	0f b7 c0             	movzwl %ax,%eax
80109571:	83 c8 01             	or     $0x1,%eax
80109574:	89 c2                	mov    %eax,%edx
80109576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109579:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010957b:	83 ec 0c             	sub    $0xc,%esp
8010957e:	68 b8 c9 10 80       	push   $0x8010c9b8
80109583:	e8 6c 6e ff ff       	call   801003f4 <cprintf>
80109588:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010958b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958e:	8b 00                	mov    (%eax),%eax
80109590:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109596:	83 e0 10             	and    $0x10,%eax
80109599:	85 c0                	test   %eax,%eax
8010959b:	75 02                	jne    8010959f <i8254_read_eeprom+0x48>
  while(1){
8010959d:	eb dc                	jmp    8010957b <i8254_read_eeprom+0x24>
      break;
8010959f:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801095a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a3:	8b 00                	mov    (%eax),%eax
801095a5:	c1 e8 10             	shr    $0x10,%eax
}
801095a8:	c9                   	leave  
801095a9:	c3                   	ret    

801095aa <i8254_recv>:
void i8254_recv(){
801095aa:	55                   	push   %ebp
801095ab:	89 e5                	mov    %esp,%ebp
801095ad:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801095b0:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801095b5:	05 10 28 00 00       	add    $0x2810,%eax
801095ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801095bd:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801095c2:	05 18 28 00 00       	add    $0x2818,%eax
801095c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801095ca:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801095cf:	05 00 28 00 00       	add    $0x2800,%eax
801095d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801095d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095da:	8b 00                	mov    (%eax),%eax
801095dc:	05 00 00 00 80       	add    $0x80000000,%eax
801095e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801095e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e7:	8b 10                	mov    (%eax),%edx
801095e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ec:	8b 08                	mov    (%eax),%ecx
801095ee:	89 d0                	mov    %edx,%eax
801095f0:	29 c8                	sub    %ecx,%eax
801095f2:	25 ff 00 00 00       	and    $0xff,%eax
801095f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801095fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801095fe:	7e 37                	jle    80109637 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109600:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109603:	8b 00                	mov    (%eax),%eax
80109605:	c1 e0 04             	shl    $0x4,%eax
80109608:	89 c2                	mov    %eax,%edx
8010960a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010960d:	01 d0                	add    %edx,%eax
8010960f:	8b 00                	mov    (%eax),%eax
80109611:	05 00 00 00 80       	add    $0x80000000,%eax
80109616:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010961c:	8b 00                	mov    (%eax),%eax
8010961e:	83 c0 01             	add    $0x1,%eax
80109621:	0f b6 d0             	movzbl %al,%edx
80109624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109627:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109629:	83 ec 0c             	sub    $0xc,%esp
8010962c:	ff 75 e0             	push   -0x20(%ebp)
8010962f:	e8 15 09 00 00       	call   80109f49 <eth_proc>
80109634:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109637:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010963a:	8b 10                	mov    (%eax),%edx
8010963c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010963f:	8b 00                	mov    (%eax),%eax
80109641:	39 c2                	cmp    %eax,%edx
80109643:	75 9f                	jne    801095e4 <i8254_recv+0x3a>
      (*rdt)--;
80109645:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109648:	8b 00                	mov    (%eax),%eax
8010964a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010964d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109650:	89 10                	mov    %edx,(%eax)
  while(1){
80109652:	eb 90                	jmp    801095e4 <i8254_recv+0x3a>

80109654 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109654:	55                   	push   %ebp
80109655:	89 e5                	mov    %esp,%ebp
80109657:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
8010965a:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010965f:	05 10 38 00 00       	add    $0x3810,%eax
80109664:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109667:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010966c:	05 18 38 00 00       	add    $0x3818,%eax
80109671:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109674:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109679:	05 00 38 00 00       	add    $0x3800,%eax
8010967e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109681:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109684:	8b 00                	mov    (%eax),%eax
80109686:	05 00 00 00 80       	add    $0x80000000,%eax
8010968b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
8010968e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109691:	8b 10                	mov    (%eax),%edx
80109693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109696:	8b 08                	mov    (%eax),%ecx
80109698:	89 d0                	mov    %edx,%eax
8010969a:	29 c8                	sub    %ecx,%eax
8010969c:	0f b6 d0             	movzbl %al,%edx
8010969f:	b8 00 01 00 00       	mov    $0x100,%eax
801096a4:	29 d0                	sub    %edx,%eax
801096a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801096a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096ac:	8b 00                	mov    (%eax),%eax
801096ae:	25 ff 00 00 00       	and    $0xff,%eax
801096b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801096b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801096ba:	0f 8e a8 00 00 00    	jle    80109768 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801096c0:	8b 45 08             	mov    0x8(%ebp),%eax
801096c3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801096c6:	89 d1                	mov    %edx,%ecx
801096c8:	c1 e1 04             	shl    $0x4,%ecx
801096cb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801096ce:	01 ca                	add    %ecx,%edx
801096d0:	8b 12                	mov    (%edx),%edx
801096d2:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801096d8:	83 ec 04             	sub    $0x4,%esp
801096db:	ff 75 0c             	push   0xc(%ebp)
801096de:	50                   	push   %eax
801096df:	52                   	push   %edx
801096e0:	e8 40 bd ff ff       	call   80105425 <memmove>
801096e5:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801096e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096eb:	c1 e0 04             	shl    $0x4,%eax
801096ee:	89 c2                	mov    %eax,%edx
801096f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096f3:	01 d0                	add    %edx,%eax
801096f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801096f8:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801096fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096ff:	c1 e0 04             	shl    $0x4,%eax
80109702:	89 c2                	mov    %eax,%edx
80109704:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109707:	01 d0                	add    %edx,%eax
80109709:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010970d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109710:	c1 e0 04             	shl    $0x4,%eax
80109713:	89 c2                	mov    %eax,%edx
80109715:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109718:	01 d0                	add    %edx,%eax
8010971a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010971e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109721:	c1 e0 04             	shl    $0x4,%eax
80109724:	89 c2                	mov    %eax,%edx
80109726:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109729:	01 d0                	add    %edx,%eax
8010972b:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010972f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109732:	c1 e0 04             	shl    $0x4,%eax
80109735:	89 c2                	mov    %eax,%edx
80109737:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010973a:	01 d0                	add    %edx,%eax
8010973c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109742:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109745:	c1 e0 04             	shl    $0x4,%eax
80109748:	89 c2                	mov    %eax,%edx
8010974a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010974d:	01 d0                	add    %edx,%eax
8010974f:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109753:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109756:	8b 00                	mov    (%eax),%eax
80109758:	83 c0 01             	add    $0x1,%eax
8010975b:	0f b6 d0             	movzbl %al,%edx
8010975e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109761:	89 10                	mov    %edx,(%eax)
    return len;
80109763:	8b 45 0c             	mov    0xc(%ebp),%eax
80109766:	eb 05                	jmp    8010976d <i8254_send+0x119>
  }else{
    return -1;
80109768:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010976d:	c9                   	leave  
8010976e:	c3                   	ret    

8010976f <i8254_intr>:

void i8254_intr(){
8010976f:	55                   	push   %ebp
80109770:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109772:	a1 18 aa 11 80       	mov    0x8011aa18,%eax
80109777:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010977d:	90                   	nop
8010977e:	5d                   	pop    %ebp
8010977f:	c3                   	ret    

80109780 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109780:	55                   	push   %ebp
80109781:	89 e5                	mov    %esp,%ebp
80109783:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109786:	8b 45 08             	mov    0x8(%ebp),%eax
80109789:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
8010978c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010978f:	0f b7 00             	movzwl (%eax),%eax
80109792:	66 3d 00 01          	cmp    $0x100,%ax
80109796:	74 0a                	je     801097a2 <arp_proc+0x22>
80109798:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010979d:	e9 4f 01 00 00       	jmp    801098f1 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801097a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a5:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801097a9:	66 83 f8 08          	cmp    $0x8,%ax
801097ad:	74 0a                	je     801097b9 <arp_proc+0x39>
801097af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097b4:	e9 38 01 00 00       	jmp    801098f1 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
801097b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097bc:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801097c0:	3c 06                	cmp    $0x6,%al
801097c2:	74 0a                	je     801097ce <arp_proc+0x4e>
801097c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097c9:	e9 23 01 00 00       	jmp    801098f1 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801097ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d1:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801097d5:	3c 04                	cmp    $0x4,%al
801097d7:	74 0a                	je     801097e3 <arp_proc+0x63>
801097d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097de:	e9 0e 01 00 00       	jmp    801098f1 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801097e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e6:	83 c0 18             	add    $0x18,%eax
801097e9:	83 ec 04             	sub    $0x4,%esp
801097ec:	6a 04                	push   $0x4
801097ee:	50                   	push   %eax
801097ef:	68 04 f5 10 80       	push   $0x8010f504
801097f4:	e8 d4 bb ff ff       	call   801053cd <memcmp>
801097f9:	83 c4 10             	add    $0x10,%esp
801097fc:	85 c0                	test   %eax,%eax
801097fe:	74 27                	je     80109827 <arp_proc+0xa7>
80109800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109803:	83 c0 0e             	add    $0xe,%eax
80109806:	83 ec 04             	sub    $0x4,%esp
80109809:	6a 04                	push   $0x4
8010980b:	50                   	push   %eax
8010980c:	68 04 f5 10 80       	push   $0x8010f504
80109811:	e8 b7 bb ff ff       	call   801053cd <memcmp>
80109816:	83 c4 10             	add    $0x10,%esp
80109819:	85 c0                	test   %eax,%eax
8010981b:	74 0a                	je     80109827 <arp_proc+0xa7>
8010981d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109822:	e9 ca 00 00 00       	jmp    801098f1 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010982a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010982e:	66 3d 00 01          	cmp    $0x100,%ax
80109832:	75 69                	jne    8010989d <arp_proc+0x11d>
80109834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109837:	83 c0 18             	add    $0x18,%eax
8010983a:	83 ec 04             	sub    $0x4,%esp
8010983d:	6a 04                	push   $0x4
8010983f:	50                   	push   %eax
80109840:	68 04 f5 10 80       	push   $0x8010f504
80109845:	e8 83 bb ff ff       	call   801053cd <memcmp>
8010984a:	83 c4 10             	add    $0x10,%esp
8010984d:	85 c0                	test   %eax,%eax
8010984f:	75 4c                	jne    8010989d <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109851:	e8 2e 94 ff ff       	call   80102c84 <kalloc>
80109856:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109859:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109860:	83 ec 04             	sub    $0x4,%esp
80109863:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109866:	50                   	push   %eax
80109867:	ff 75 f0             	push   -0x10(%ebp)
8010986a:	ff 75 f4             	push   -0xc(%ebp)
8010986d:	e8 1f 04 00 00       	call   80109c91 <arp_reply_pkt_create>
80109872:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109875:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109878:	83 ec 08             	sub    $0x8,%esp
8010987b:	50                   	push   %eax
8010987c:	ff 75 f0             	push   -0x10(%ebp)
8010987f:	e8 d0 fd ff ff       	call   80109654 <i8254_send>
80109884:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010988a:	83 ec 0c             	sub    $0xc,%esp
8010988d:	50                   	push   %eax
8010988e:	e8 57 93 ff ff       	call   80102bea <kfree>
80109893:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109896:	b8 02 00 00 00       	mov    $0x2,%eax
8010989b:	eb 54                	jmp    801098f1 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010989d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098a0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098a4:	66 3d 00 02          	cmp    $0x200,%ax
801098a8:	75 42                	jne    801098ec <arp_proc+0x16c>
801098aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ad:	83 c0 18             	add    $0x18,%eax
801098b0:	83 ec 04             	sub    $0x4,%esp
801098b3:	6a 04                	push   $0x4
801098b5:	50                   	push   %eax
801098b6:	68 04 f5 10 80       	push   $0x8010f504
801098bb:	e8 0d bb ff ff       	call   801053cd <memcmp>
801098c0:	83 c4 10             	add    $0x10,%esp
801098c3:	85 c0                	test   %eax,%eax
801098c5:	75 25                	jne    801098ec <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801098c7:	83 ec 0c             	sub    $0xc,%esp
801098ca:	68 bc c9 10 80       	push   $0x8010c9bc
801098cf:	e8 20 6b ff ff       	call   801003f4 <cprintf>
801098d4:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801098d7:	83 ec 0c             	sub    $0xc,%esp
801098da:	ff 75 f4             	push   -0xc(%ebp)
801098dd:	e8 af 01 00 00       	call   80109a91 <arp_table_update>
801098e2:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801098e5:	b8 01 00 00 00       	mov    $0x1,%eax
801098ea:	eb 05                	jmp    801098f1 <arp_proc+0x171>
  }else{
    return -1;
801098ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801098f1:	c9                   	leave  
801098f2:	c3                   	ret    

801098f3 <arp_scan>:

void arp_scan(){
801098f3:	55                   	push   %ebp
801098f4:	89 e5                	mov    %esp,%ebp
801098f6:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801098f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109900:	eb 6f                	jmp    80109971 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109902:	e8 7d 93 ff ff       	call   80102c84 <kalloc>
80109907:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010990a:	83 ec 04             	sub    $0x4,%esp
8010990d:	ff 75 f4             	push   -0xc(%ebp)
80109910:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109913:	50                   	push   %eax
80109914:	ff 75 ec             	push   -0x14(%ebp)
80109917:	e8 62 00 00 00       	call   8010997e <arp_broadcast>
8010991c:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010991f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109922:	83 ec 08             	sub    $0x8,%esp
80109925:	50                   	push   %eax
80109926:	ff 75 ec             	push   -0x14(%ebp)
80109929:	e8 26 fd ff ff       	call   80109654 <i8254_send>
8010992e:	83 c4 10             	add    $0x10,%esp
80109931:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109934:	eb 22                	jmp    80109958 <arp_scan+0x65>
      microdelay(1);
80109936:	83 ec 0c             	sub    $0xc,%esp
80109939:	6a 01                	push   $0x1
8010993b:	e8 db 96 ff ff       	call   8010301b <microdelay>
80109940:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109943:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109946:	83 ec 08             	sub    $0x8,%esp
80109949:	50                   	push   %eax
8010994a:	ff 75 ec             	push   -0x14(%ebp)
8010994d:	e8 02 fd ff ff       	call   80109654 <i8254_send>
80109952:	83 c4 10             	add    $0x10,%esp
80109955:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109958:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010995c:	74 d8                	je     80109936 <arp_scan+0x43>
    }
    kfree((char *)send);
8010995e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109961:	83 ec 0c             	sub    $0xc,%esp
80109964:	50                   	push   %eax
80109965:	e8 80 92 ff ff       	call   80102bea <kfree>
8010996a:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010996d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109971:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109978:	7e 88                	jle    80109902 <arp_scan+0xf>
  }
}
8010997a:	90                   	nop
8010997b:	90                   	nop
8010997c:	c9                   	leave  
8010997d:	c3                   	ret    

8010997e <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010997e:	55                   	push   %ebp
8010997f:	89 e5                	mov    %esp,%ebp
80109981:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109984:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109988:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
8010998c:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109990:	8b 45 10             	mov    0x10(%ebp),%eax
80109993:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109996:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010999d:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801099a3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801099aa:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801099b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801099b3:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801099b9:	8b 45 08             	mov    0x8(%ebp),%eax
801099bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801099bf:	8b 45 08             	mov    0x8(%ebp),%eax
801099c2:	83 c0 0e             	add    $0xe,%eax
801099c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801099c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099cb:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801099cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d2:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801099d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d9:	83 ec 04             	sub    $0x4,%esp
801099dc:	6a 06                	push   $0x6
801099de:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801099e1:	52                   	push   %edx
801099e2:	50                   	push   %eax
801099e3:	e8 3d ba ff ff       	call   80105425 <memmove>
801099e8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801099eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ee:	83 c0 06             	add    $0x6,%eax
801099f1:	83 ec 04             	sub    $0x4,%esp
801099f4:	6a 06                	push   $0x6
801099f6:	68 10 aa 11 80       	push   $0x8011aa10
801099fb:	50                   	push   %eax
801099fc:	e8 24 ba ff ff       	call   80105425 <memmove>
80109a01:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a07:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a0f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a18:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a1f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a26:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a2f:	8d 50 12             	lea    0x12(%eax),%edx
80109a32:	83 ec 04             	sub    $0x4,%esp
80109a35:	6a 06                	push   $0x6
80109a37:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109a3a:	50                   	push   %eax
80109a3b:	52                   	push   %edx
80109a3c:	e8 e4 b9 ff ff       	call   80105425 <memmove>
80109a41:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a47:	8d 50 18             	lea    0x18(%eax),%edx
80109a4a:	83 ec 04             	sub    $0x4,%esp
80109a4d:	6a 04                	push   $0x4
80109a4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109a52:	50                   	push   %eax
80109a53:	52                   	push   %edx
80109a54:	e8 cc b9 ff ff       	call   80105425 <memmove>
80109a59:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a5f:	83 c0 08             	add    $0x8,%eax
80109a62:	83 ec 04             	sub    $0x4,%esp
80109a65:	6a 06                	push   $0x6
80109a67:	68 10 aa 11 80       	push   $0x8011aa10
80109a6c:	50                   	push   %eax
80109a6d:	e8 b3 b9 ff ff       	call   80105425 <memmove>
80109a72:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a78:	83 c0 0e             	add    $0xe,%eax
80109a7b:	83 ec 04             	sub    $0x4,%esp
80109a7e:	6a 04                	push   $0x4
80109a80:	68 04 f5 10 80       	push   $0x8010f504
80109a85:	50                   	push   %eax
80109a86:	e8 9a b9 ff ff       	call   80105425 <memmove>
80109a8b:	83 c4 10             	add    $0x10,%esp
}
80109a8e:	90                   	nop
80109a8f:	c9                   	leave  
80109a90:	c3                   	ret    

80109a91 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109a91:	55                   	push   %ebp
80109a92:	89 e5                	mov    %esp,%ebp
80109a94:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109a97:	8b 45 08             	mov    0x8(%ebp),%eax
80109a9a:	83 c0 0e             	add    $0xe,%eax
80109a9d:	83 ec 0c             	sub    $0xc,%esp
80109aa0:	50                   	push   %eax
80109aa1:	e8 bc 00 00 00       	call   80109b62 <arp_table_search>
80109aa6:	83 c4 10             	add    $0x10,%esp
80109aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109aac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109ab0:	78 2d                	js     80109adf <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab5:	8d 48 08             	lea    0x8(%eax),%ecx
80109ab8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109abb:	89 d0                	mov    %edx,%eax
80109abd:	c1 e0 02             	shl    $0x2,%eax
80109ac0:	01 d0                	add    %edx,%eax
80109ac2:	01 c0                	add    %eax,%eax
80109ac4:	01 d0                	add    %edx,%eax
80109ac6:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109acb:	83 c0 04             	add    $0x4,%eax
80109ace:	83 ec 04             	sub    $0x4,%esp
80109ad1:	6a 06                	push   $0x6
80109ad3:	51                   	push   %ecx
80109ad4:	50                   	push   %eax
80109ad5:	e8 4b b9 ff ff       	call   80105425 <memmove>
80109ada:	83 c4 10             	add    $0x10,%esp
80109add:	eb 70                	jmp    80109b4f <arp_table_update+0xbe>
  }else{
    index += 1;
80109adf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109ae3:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae9:	8d 48 08             	lea    0x8(%eax),%ecx
80109aec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109aef:	89 d0                	mov    %edx,%eax
80109af1:	c1 e0 02             	shl    $0x2,%eax
80109af4:	01 d0                	add    %edx,%eax
80109af6:	01 c0                	add    %eax,%eax
80109af8:	01 d0                	add    %edx,%eax
80109afa:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109aff:	83 c0 04             	add    $0x4,%eax
80109b02:	83 ec 04             	sub    $0x4,%esp
80109b05:	6a 06                	push   $0x6
80109b07:	51                   	push   %ecx
80109b08:	50                   	push   %eax
80109b09:	e8 17 b9 ff ff       	call   80105425 <memmove>
80109b0e:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109b11:	8b 45 08             	mov    0x8(%ebp),%eax
80109b14:	8d 48 0e             	lea    0xe(%eax),%ecx
80109b17:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b1a:	89 d0                	mov    %edx,%eax
80109b1c:	c1 e0 02             	shl    $0x2,%eax
80109b1f:	01 d0                	add    %edx,%eax
80109b21:	01 c0                	add    %eax,%eax
80109b23:	01 d0                	add    %edx,%eax
80109b25:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109b2a:	83 ec 04             	sub    $0x4,%esp
80109b2d:	6a 04                	push   $0x4
80109b2f:	51                   	push   %ecx
80109b30:	50                   	push   %eax
80109b31:	e8 ef b8 ff ff       	call   80105425 <memmove>
80109b36:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b3c:	89 d0                	mov    %edx,%eax
80109b3e:	c1 e0 02             	shl    $0x2,%eax
80109b41:	01 d0                	add    %edx,%eax
80109b43:	01 c0                	add    %eax,%eax
80109b45:	01 d0                	add    %edx,%eax
80109b47:	05 2a aa 11 80       	add    $0x8011aa2a,%eax
80109b4c:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109b4f:	83 ec 0c             	sub    $0xc,%esp
80109b52:	68 20 aa 11 80       	push   $0x8011aa20
80109b57:	e8 83 00 00 00       	call   80109bdf <print_arp_table>
80109b5c:	83 c4 10             	add    $0x10,%esp
}
80109b5f:	90                   	nop
80109b60:	c9                   	leave  
80109b61:	c3                   	ret    

80109b62 <arp_table_search>:

int arp_table_search(uchar *ip){
80109b62:	55                   	push   %ebp
80109b63:	89 e5                	mov    %esp,%ebp
80109b65:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109b68:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109b6f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109b76:	eb 59                	jmp    80109bd1 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109b78:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109b7b:	89 d0                	mov    %edx,%eax
80109b7d:	c1 e0 02             	shl    $0x2,%eax
80109b80:	01 d0                	add    %edx,%eax
80109b82:	01 c0                	add    %eax,%eax
80109b84:	01 d0                	add    %edx,%eax
80109b86:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109b8b:	83 ec 04             	sub    $0x4,%esp
80109b8e:	6a 04                	push   $0x4
80109b90:	ff 75 08             	push   0x8(%ebp)
80109b93:	50                   	push   %eax
80109b94:	e8 34 b8 ff ff       	call   801053cd <memcmp>
80109b99:	83 c4 10             	add    $0x10,%esp
80109b9c:	85 c0                	test   %eax,%eax
80109b9e:	75 05                	jne    80109ba5 <arp_table_search+0x43>
      return i;
80109ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ba3:	eb 38                	jmp    80109bdd <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109ba5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ba8:	89 d0                	mov    %edx,%eax
80109baa:	c1 e0 02             	shl    $0x2,%eax
80109bad:	01 d0                	add    %edx,%eax
80109baf:	01 c0                	add    %eax,%eax
80109bb1:	01 d0                	add    %edx,%eax
80109bb3:	05 2a aa 11 80       	add    $0x8011aa2a,%eax
80109bb8:	0f b6 00             	movzbl (%eax),%eax
80109bbb:	84 c0                	test   %al,%al
80109bbd:	75 0e                	jne    80109bcd <arp_table_search+0x6b>
80109bbf:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109bc3:	75 08                	jne    80109bcd <arp_table_search+0x6b>
      empty = -i;
80109bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bc8:	f7 d8                	neg    %eax
80109bca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109bcd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109bd1:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109bd5:	7e a1                	jle    80109b78 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bda:	83 e8 01             	sub    $0x1,%eax
}
80109bdd:	c9                   	leave  
80109bde:	c3                   	ret    

80109bdf <print_arp_table>:

void print_arp_table(){
80109bdf:	55                   	push   %ebp
80109be0:	89 e5                	mov    %esp,%ebp
80109be2:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109be5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109bec:	e9 92 00 00 00       	jmp    80109c83 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109bf1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109bf4:	89 d0                	mov    %edx,%eax
80109bf6:	c1 e0 02             	shl    $0x2,%eax
80109bf9:	01 d0                	add    %edx,%eax
80109bfb:	01 c0                	add    %eax,%eax
80109bfd:	01 d0                	add    %edx,%eax
80109bff:	05 2a aa 11 80       	add    $0x8011aa2a,%eax
80109c04:	0f b6 00             	movzbl (%eax),%eax
80109c07:	84 c0                	test   %al,%al
80109c09:	74 74                	je     80109c7f <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109c0b:	83 ec 08             	sub    $0x8,%esp
80109c0e:	ff 75 f4             	push   -0xc(%ebp)
80109c11:	68 cf c9 10 80       	push   $0x8010c9cf
80109c16:	e8 d9 67 ff ff       	call   801003f4 <cprintf>
80109c1b:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109c1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c21:	89 d0                	mov    %edx,%eax
80109c23:	c1 e0 02             	shl    $0x2,%eax
80109c26:	01 d0                	add    %edx,%eax
80109c28:	01 c0                	add    %eax,%eax
80109c2a:	01 d0                	add    %edx,%eax
80109c2c:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109c31:	83 ec 0c             	sub    $0xc,%esp
80109c34:	50                   	push   %eax
80109c35:	e8 54 02 00 00       	call   80109e8e <print_ipv4>
80109c3a:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109c3d:	83 ec 0c             	sub    $0xc,%esp
80109c40:	68 de c9 10 80       	push   $0x8010c9de
80109c45:	e8 aa 67 ff ff       	call   801003f4 <cprintf>
80109c4a:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c50:	89 d0                	mov    %edx,%eax
80109c52:	c1 e0 02             	shl    $0x2,%eax
80109c55:	01 d0                	add    %edx,%eax
80109c57:	01 c0                	add    %eax,%eax
80109c59:	01 d0                	add    %edx,%eax
80109c5b:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109c60:	83 c0 04             	add    $0x4,%eax
80109c63:	83 ec 0c             	sub    $0xc,%esp
80109c66:	50                   	push   %eax
80109c67:	e8 70 02 00 00       	call   80109edc <print_mac>
80109c6c:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109c6f:	83 ec 0c             	sub    $0xc,%esp
80109c72:	68 e0 c9 10 80       	push   $0x8010c9e0
80109c77:	e8 78 67 ff ff       	call   801003f4 <cprintf>
80109c7c:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109c7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109c83:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109c87:	0f 8e 64 ff ff ff    	jle    80109bf1 <print_arp_table+0x12>
    }
  }
}
80109c8d:	90                   	nop
80109c8e:	90                   	nop
80109c8f:	c9                   	leave  
80109c90:	c3                   	ret    

80109c91 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109c91:	55                   	push   %ebp
80109c92:	89 e5                	mov    %esp,%ebp
80109c94:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109c97:	8b 45 10             	mov    0x10(%ebp),%eax
80109c9a:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ca3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109ca6:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ca9:	83 c0 0e             	add    $0xe,%eax
80109cac:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cb2:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cb9:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80109cc0:	8d 50 08             	lea    0x8(%eax),%edx
80109cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cc6:	83 ec 04             	sub    $0x4,%esp
80109cc9:	6a 06                	push   $0x6
80109ccb:	52                   	push   %edx
80109ccc:	50                   	push   %eax
80109ccd:	e8 53 b7 ff ff       	call   80105425 <memmove>
80109cd2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cd8:	83 c0 06             	add    $0x6,%eax
80109cdb:	83 ec 04             	sub    $0x4,%esp
80109cde:	6a 06                	push   $0x6
80109ce0:	68 10 aa 11 80       	push   $0x8011aa10
80109ce5:	50                   	push   %eax
80109ce6:	e8 3a b7 ff ff       	call   80105425 <memmove>
80109ceb:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf1:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf9:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d02:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d09:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d10:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109d16:	8b 45 08             	mov    0x8(%ebp),%eax
80109d19:	8d 50 08             	lea    0x8(%eax),%edx
80109d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d1f:	83 c0 12             	add    $0x12,%eax
80109d22:	83 ec 04             	sub    $0x4,%esp
80109d25:	6a 06                	push   $0x6
80109d27:	52                   	push   %edx
80109d28:	50                   	push   %eax
80109d29:	e8 f7 b6 ff ff       	call   80105425 <memmove>
80109d2e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109d31:	8b 45 08             	mov    0x8(%ebp),%eax
80109d34:	8d 50 0e             	lea    0xe(%eax),%edx
80109d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d3a:	83 c0 18             	add    $0x18,%eax
80109d3d:	83 ec 04             	sub    $0x4,%esp
80109d40:	6a 04                	push   $0x4
80109d42:	52                   	push   %edx
80109d43:	50                   	push   %eax
80109d44:	e8 dc b6 ff ff       	call   80105425 <memmove>
80109d49:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d4f:	83 c0 08             	add    $0x8,%eax
80109d52:	83 ec 04             	sub    $0x4,%esp
80109d55:	6a 06                	push   $0x6
80109d57:	68 10 aa 11 80       	push   $0x8011aa10
80109d5c:	50                   	push   %eax
80109d5d:	e8 c3 b6 ff ff       	call   80105425 <memmove>
80109d62:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d68:	83 c0 0e             	add    $0xe,%eax
80109d6b:	83 ec 04             	sub    $0x4,%esp
80109d6e:	6a 04                	push   $0x4
80109d70:	68 04 f5 10 80       	push   $0x8010f504
80109d75:	50                   	push   %eax
80109d76:	e8 aa b6 ff ff       	call   80105425 <memmove>
80109d7b:	83 c4 10             	add    $0x10,%esp
}
80109d7e:	90                   	nop
80109d7f:	c9                   	leave  
80109d80:	c3                   	ret    

80109d81 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109d81:	55                   	push   %ebp
80109d82:	89 e5                	mov    %esp,%ebp
80109d84:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109d87:	83 ec 0c             	sub    $0xc,%esp
80109d8a:	68 e2 c9 10 80       	push   $0x8010c9e2
80109d8f:	e8 60 66 ff ff       	call   801003f4 <cprintf>
80109d94:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109d97:	8b 45 08             	mov    0x8(%ebp),%eax
80109d9a:	83 c0 0e             	add    $0xe,%eax
80109d9d:	83 ec 0c             	sub    $0xc,%esp
80109da0:	50                   	push   %eax
80109da1:	e8 e8 00 00 00       	call   80109e8e <print_ipv4>
80109da6:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109da9:	83 ec 0c             	sub    $0xc,%esp
80109dac:	68 e0 c9 10 80       	push   $0x8010c9e0
80109db1:	e8 3e 66 ff ff       	call   801003f4 <cprintf>
80109db6:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109db9:	8b 45 08             	mov    0x8(%ebp),%eax
80109dbc:	83 c0 08             	add    $0x8,%eax
80109dbf:	83 ec 0c             	sub    $0xc,%esp
80109dc2:	50                   	push   %eax
80109dc3:	e8 14 01 00 00       	call   80109edc <print_mac>
80109dc8:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109dcb:	83 ec 0c             	sub    $0xc,%esp
80109dce:	68 e0 c9 10 80       	push   $0x8010c9e0
80109dd3:	e8 1c 66 ff ff       	call   801003f4 <cprintf>
80109dd8:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109ddb:	83 ec 0c             	sub    $0xc,%esp
80109dde:	68 f9 c9 10 80       	push   $0x8010c9f9
80109de3:	e8 0c 66 ff ff       	call   801003f4 <cprintf>
80109de8:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109deb:	8b 45 08             	mov    0x8(%ebp),%eax
80109dee:	83 c0 18             	add    $0x18,%eax
80109df1:	83 ec 0c             	sub    $0xc,%esp
80109df4:	50                   	push   %eax
80109df5:	e8 94 00 00 00       	call   80109e8e <print_ipv4>
80109dfa:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109dfd:	83 ec 0c             	sub    $0xc,%esp
80109e00:	68 e0 c9 10 80       	push   $0x8010c9e0
80109e05:	e8 ea 65 ff ff       	call   801003f4 <cprintf>
80109e0a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80109e10:	83 c0 12             	add    $0x12,%eax
80109e13:	83 ec 0c             	sub    $0xc,%esp
80109e16:	50                   	push   %eax
80109e17:	e8 c0 00 00 00       	call   80109edc <print_mac>
80109e1c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109e1f:	83 ec 0c             	sub    $0xc,%esp
80109e22:	68 e0 c9 10 80       	push   $0x8010c9e0
80109e27:	e8 c8 65 ff ff       	call   801003f4 <cprintf>
80109e2c:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109e2f:	83 ec 0c             	sub    $0xc,%esp
80109e32:	68 10 ca 10 80       	push   $0x8010ca10
80109e37:	e8 b8 65 ff ff       	call   801003f4 <cprintf>
80109e3c:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80109e42:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e46:	66 3d 00 01          	cmp    $0x100,%ax
80109e4a:	75 12                	jne    80109e5e <print_arp_info+0xdd>
80109e4c:	83 ec 0c             	sub    $0xc,%esp
80109e4f:	68 1c ca 10 80       	push   $0x8010ca1c
80109e54:	e8 9b 65 ff ff       	call   801003f4 <cprintf>
80109e59:	83 c4 10             	add    $0x10,%esp
80109e5c:	eb 1d                	jmp    80109e7b <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109e61:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e65:	66 3d 00 02          	cmp    $0x200,%ax
80109e69:	75 10                	jne    80109e7b <print_arp_info+0xfa>
    cprintf("Reply\n");
80109e6b:	83 ec 0c             	sub    $0xc,%esp
80109e6e:	68 25 ca 10 80       	push   $0x8010ca25
80109e73:	e8 7c 65 ff ff       	call   801003f4 <cprintf>
80109e78:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109e7b:	83 ec 0c             	sub    $0xc,%esp
80109e7e:	68 e0 c9 10 80       	push   $0x8010c9e0
80109e83:	e8 6c 65 ff ff       	call   801003f4 <cprintf>
80109e88:	83 c4 10             	add    $0x10,%esp
}
80109e8b:	90                   	nop
80109e8c:	c9                   	leave  
80109e8d:	c3                   	ret    

80109e8e <print_ipv4>:

void print_ipv4(uchar *ip){
80109e8e:	55                   	push   %ebp
80109e8f:	89 e5                	mov    %esp,%ebp
80109e91:	53                   	push   %ebx
80109e92:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109e95:	8b 45 08             	mov    0x8(%ebp),%eax
80109e98:	83 c0 03             	add    $0x3,%eax
80109e9b:	0f b6 00             	movzbl (%eax),%eax
80109e9e:	0f b6 d8             	movzbl %al,%ebx
80109ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ea4:	83 c0 02             	add    $0x2,%eax
80109ea7:	0f b6 00             	movzbl (%eax),%eax
80109eaa:	0f b6 c8             	movzbl %al,%ecx
80109ead:	8b 45 08             	mov    0x8(%ebp),%eax
80109eb0:	83 c0 01             	add    $0x1,%eax
80109eb3:	0f b6 00             	movzbl (%eax),%eax
80109eb6:	0f b6 d0             	movzbl %al,%edx
80109eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80109ebc:	0f b6 00             	movzbl (%eax),%eax
80109ebf:	0f b6 c0             	movzbl %al,%eax
80109ec2:	83 ec 0c             	sub    $0xc,%esp
80109ec5:	53                   	push   %ebx
80109ec6:	51                   	push   %ecx
80109ec7:	52                   	push   %edx
80109ec8:	50                   	push   %eax
80109ec9:	68 2c ca 10 80       	push   $0x8010ca2c
80109ece:	e8 21 65 ff ff       	call   801003f4 <cprintf>
80109ed3:	83 c4 20             	add    $0x20,%esp
}
80109ed6:	90                   	nop
80109ed7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109eda:	c9                   	leave  
80109edb:	c3                   	ret    

80109edc <print_mac>:

void print_mac(uchar *mac){
80109edc:	55                   	push   %ebp
80109edd:	89 e5                	mov    %esp,%ebp
80109edf:	57                   	push   %edi
80109ee0:	56                   	push   %esi
80109ee1:	53                   	push   %ebx
80109ee2:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee8:	83 c0 05             	add    $0x5,%eax
80109eeb:	0f b6 00             	movzbl (%eax),%eax
80109eee:	0f b6 f8             	movzbl %al,%edi
80109ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ef4:	83 c0 04             	add    $0x4,%eax
80109ef7:	0f b6 00             	movzbl (%eax),%eax
80109efa:	0f b6 f0             	movzbl %al,%esi
80109efd:	8b 45 08             	mov    0x8(%ebp),%eax
80109f00:	83 c0 03             	add    $0x3,%eax
80109f03:	0f b6 00             	movzbl (%eax),%eax
80109f06:	0f b6 d8             	movzbl %al,%ebx
80109f09:	8b 45 08             	mov    0x8(%ebp),%eax
80109f0c:	83 c0 02             	add    $0x2,%eax
80109f0f:	0f b6 00             	movzbl (%eax),%eax
80109f12:	0f b6 c8             	movzbl %al,%ecx
80109f15:	8b 45 08             	mov    0x8(%ebp),%eax
80109f18:	83 c0 01             	add    $0x1,%eax
80109f1b:	0f b6 00             	movzbl (%eax),%eax
80109f1e:	0f b6 d0             	movzbl %al,%edx
80109f21:	8b 45 08             	mov    0x8(%ebp),%eax
80109f24:	0f b6 00             	movzbl (%eax),%eax
80109f27:	0f b6 c0             	movzbl %al,%eax
80109f2a:	83 ec 04             	sub    $0x4,%esp
80109f2d:	57                   	push   %edi
80109f2e:	56                   	push   %esi
80109f2f:	53                   	push   %ebx
80109f30:	51                   	push   %ecx
80109f31:	52                   	push   %edx
80109f32:	50                   	push   %eax
80109f33:	68 44 ca 10 80       	push   $0x8010ca44
80109f38:	e8 b7 64 ff ff       	call   801003f4 <cprintf>
80109f3d:	83 c4 20             	add    $0x20,%esp
}
80109f40:	90                   	nop
80109f41:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109f44:	5b                   	pop    %ebx
80109f45:	5e                   	pop    %esi
80109f46:	5f                   	pop    %edi
80109f47:	5d                   	pop    %ebp
80109f48:	c3                   	ret    

80109f49 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109f49:	55                   	push   %ebp
80109f4a:	89 e5                	mov    %esp,%ebp
80109f4c:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80109f52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109f55:	8b 45 08             	mov    0x8(%ebp),%eax
80109f58:	83 c0 0e             	add    $0xe,%eax
80109f5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f61:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109f65:	3c 08                	cmp    $0x8,%al
80109f67:	75 1b                	jne    80109f84 <eth_proc+0x3b>
80109f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f6c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f70:	3c 06                	cmp    $0x6,%al
80109f72:	75 10                	jne    80109f84 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109f74:	83 ec 0c             	sub    $0xc,%esp
80109f77:	ff 75 f0             	push   -0x10(%ebp)
80109f7a:	e8 01 f8 ff ff       	call   80109780 <arp_proc>
80109f7f:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109f82:	eb 24                	jmp    80109fa8 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f87:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109f8b:	3c 08                	cmp    $0x8,%al
80109f8d:	75 19                	jne    80109fa8 <eth_proc+0x5f>
80109f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f92:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f96:	84 c0                	test   %al,%al
80109f98:	75 0e                	jne    80109fa8 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109f9a:	83 ec 0c             	sub    $0xc,%esp
80109f9d:	ff 75 08             	push   0x8(%ebp)
80109fa0:	e8 a3 00 00 00       	call   8010a048 <ipv4_proc>
80109fa5:	83 c4 10             	add    $0x10,%esp
}
80109fa8:	90                   	nop
80109fa9:	c9                   	leave  
80109faa:	c3                   	ret    

80109fab <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109fab:	55                   	push   %ebp
80109fac:	89 e5                	mov    %esp,%ebp
80109fae:	83 ec 04             	sub    $0x4,%esp
80109fb1:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109fb8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109fbc:	c1 e0 08             	shl    $0x8,%eax
80109fbf:	89 c2                	mov    %eax,%edx
80109fc1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109fc5:	66 c1 e8 08          	shr    $0x8,%ax
80109fc9:	01 d0                	add    %edx,%eax
}
80109fcb:	c9                   	leave  
80109fcc:	c3                   	ret    

80109fcd <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109fcd:	55                   	push   %ebp
80109fce:	89 e5                	mov    %esp,%ebp
80109fd0:	83 ec 04             	sub    $0x4,%esp
80109fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109fda:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109fde:	c1 e0 08             	shl    $0x8,%eax
80109fe1:	89 c2                	mov    %eax,%edx
80109fe3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109fe7:	66 c1 e8 08          	shr    $0x8,%ax
80109feb:	01 d0                	add    %edx,%eax
}
80109fed:	c9                   	leave  
80109fee:	c3                   	ret    

80109fef <H2N_uint>:

uint H2N_uint(uint value){
80109fef:	55                   	push   %ebp
80109ff0:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80109ff5:	c1 e0 18             	shl    $0x18,%eax
80109ff8:	25 00 00 00 0f       	and    $0xf000000,%eax
80109ffd:	89 c2                	mov    %eax,%edx
80109fff:	8b 45 08             	mov    0x8(%ebp),%eax
8010a002:	c1 e0 08             	shl    $0x8,%eax
8010a005:	25 00 f0 00 00       	and    $0xf000,%eax
8010a00a:	09 c2                	or     %eax,%edx
8010a00c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a00f:	c1 e8 08             	shr    $0x8,%eax
8010a012:	83 e0 0f             	and    $0xf,%eax
8010a015:	01 d0                	add    %edx,%eax
}
8010a017:	5d                   	pop    %ebp
8010a018:	c3                   	ret    

8010a019 <N2H_uint>:

uint N2H_uint(uint value){
8010a019:	55                   	push   %ebp
8010a01a:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a01c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a01f:	c1 e0 18             	shl    $0x18,%eax
8010a022:	89 c2                	mov    %eax,%edx
8010a024:	8b 45 08             	mov    0x8(%ebp),%eax
8010a027:	c1 e0 08             	shl    $0x8,%eax
8010a02a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a02f:	01 c2                	add    %eax,%edx
8010a031:	8b 45 08             	mov    0x8(%ebp),%eax
8010a034:	c1 e8 08             	shr    $0x8,%eax
8010a037:	25 00 ff 00 00       	and    $0xff00,%eax
8010a03c:	01 c2                	add    %eax,%edx
8010a03e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a041:	c1 e8 18             	shr    $0x18,%eax
8010a044:	01 d0                	add    %edx,%eax
}
8010a046:	5d                   	pop    %ebp
8010a047:	c3                   	ret    

8010a048 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a048:	55                   	push   %ebp
8010a049:	89 e5                	mov    %esp,%ebp
8010a04b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a04e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a051:	83 c0 0e             	add    $0xe,%eax
8010a054:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a05a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a05e:	0f b7 d0             	movzwl %ax,%edx
8010a061:	a1 08 f5 10 80       	mov    0x8010f508,%eax
8010a066:	39 c2                	cmp    %eax,%edx
8010a068:	74 60                	je     8010a0ca <ipv4_proc+0x82>
8010a06a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a06d:	83 c0 0c             	add    $0xc,%eax
8010a070:	83 ec 04             	sub    $0x4,%esp
8010a073:	6a 04                	push   $0x4
8010a075:	50                   	push   %eax
8010a076:	68 04 f5 10 80       	push   $0x8010f504
8010a07b:	e8 4d b3 ff ff       	call   801053cd <memcmp>
8010a080:	83 c4 10             	add    $0x10,%esp
8010a083:	85 c0                	test   %eax,%eax
8010a085:	74 43                	je     8010a0ca <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
8010a087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a08a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a08e:	0f b7 c0             	movzwl %ax,%eax
8010a091:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a096:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a099:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a09d:	3c 01                	cmp    $0x1,%al
8010a09f:	75 10                	jne    8010a0b1 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
8010a0a1:	83 ec 0c             	sub    $0xc,%esp
8010a0a4:	ff 75 08             	push   0x8(%ebp)
8010a0a7:	e8 a3 00 00 00       	call   8010a14f <icmp_proc>
8010a0ac:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a0af:	eb 19                	jmp    8010a0ca <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a0b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0b4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a0b8:	3c 06                	cmp    $0x6,%al
8010a0ba:	75 0e                	jne    8010a0ca <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010a0bc:	83 ec 0c             	sub    $0xc,%esp
8010a0bf:	ff 75 08             	push   0x8(%ebp)
8010a0c2:	e8 b3 03 00 00       	call   8010a47a <tcp_proc>
8010a0c7:	83 c4 10             	add    $0x10,%esp
}
8010a0ca:	90                   	nop
8010a0cb:	c9                   	leave  
8010a0cc:	c3                   	ret    

8010a0cd <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a0cd:	55                   	push   %ebp
8010a0ce:	89 e5                	mov    %esp,%ebp
8010a0d0:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a0d3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a0d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0dc:	0f b6 00             	movzbl (%eax),%eax
8010a0df:	83 e0 0f             	and    $0xf,%eax
8010a0e2:	01 c0                	add    %eax,%eax
8010a0e4:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a0e7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a0ee:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a0f5:	eb 48                	jmp    8010a13f <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a0f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a0fa:	01 c0                	add    %eax,%eax
8010a0fc:	89 c2                	mov    %eax,%edx
8010a0fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a101:	01 d0                	add    %edx,%eax
8010a103:	0f b6 00             	movzbl (%eax),%eax
8010a106:	0f b6 c0             	movzbl %al,%eax
8010a109:	c1 e0 08             	shl    $0x8,%eax
8010a10c:	89 c2                	mov    %eax,%edx
8010a10e:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a111:	01 c0                	add    %eax,%eax
8010a113:	8d 48 01             	lea    0x1(%eax),%ecx
8010a116:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a119:	01 c8                	add    %ecx,%eax
8010a11b:	0f b6 00             	movzbl (%eax),%eax
8010a11e:	0f b6 c0             	movzbl %al,%eax
8010a121:	01 d0                	add    %edx,%eax
8010a123:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a126:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a12d:	76 0c                	jbe    8010a13b <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a12f:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a132:	0f b7 c0             	movzwl %ax,%eax
8010a135:	83 c0 01             	add    $0x1,%eax
8010a138:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a13b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a13f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a143:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a146:	7c af                	jl     8010a0f7 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
8010a148:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a14b:	f7 d0                	not    %eax
}
8010a14d:	c9                   	leave  
8010a14e:	c3                   	ret    

8010a14f <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a14f:	55                   	push   %ebp
8010a150:	89 e5                	mov    %esp,%ebp
8010a152:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a155:	8b 45 08             	mov    0x8(%ebp),%eax
8010a158:	83 c0 0e             	add    $0xe,%eax
8010a15b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a15e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a161:	0f b6 00             	movzbl (%eax),%eax
8010a164:	0f b6 c0             	movzbl %al,%eax
8010a167:	83 e0 0f             	and    $0xf,%eax
8010a16a:	c1 e0 02             	shl    $0x2,%eax
8010a16d:	89 c2                	mov    %eax,%edx
8010a16f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a172:	01 d0                	add    %edx,%eax
8010a174:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a17a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a17e:	84 c0                	test   %al,%al
8010a180:	75 4f                	jne    8010a1d1 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a182:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a185:	0f b6 00             	movzbl (%eax),%eax
8010a188:	3c 08                	cmp    $0x8,%al
8010a18a:	75 45                	jne    8010a1d1 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
8010a18c:	e8 f3 8a ff ff       	call   80102c84 <kalloc>
8010a191:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a194:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a19b:	83 ec 04             	sub    $0x4,%esp
8010a19e:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a1a1:	50                   	push   %eax
8010a1a2:	ff 75 ec             	push   -0x14(%ebp)
8010a1a5:	ff 75 08             	push   0x8(%ebp)
8010a1a8:	e8 78 00 00 00       	call   8010a225 <icmp_reply_pkt_create>
8010a1ad:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a1b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1b3:	83 ec 08             	sub    $0x8,%esp
8010a1b6:	50                   	push   %eax
8010a1b7:	ff 75 ec             	push   -0x14(%ebp)
8010a1ba:	e8 95 f4 ff ff       	call   80109654 <i8254_send>
8010a1bf:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a1c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1c5:	83 ec 0c             	sub    $0xc,%esp
8010a1c8:	50                   	push   %eax
8010a1c9:	e8 1c 8a ff ff       	call   80102bea <kfree>
8010a1ce:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a1d1:	90                   	nop
8010a1d2:	c9                   	leave  
8010a1d3:	c3                   	ret    

8010a1d4 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a1d4:	55                   	push   %ebp
8010a1d5:	89 e5                	mov    %esp,%ebp
8010a1d7:	53                   	push   %ebx
8010a1d8:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a1db:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1de:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a1e2:	0f b7 c0             	movzwl %ax,%eax
8010a1e5:	83 ec 0c             	sub    $0xc,%esp
8010a1e8:	50                   	push   %eax
8010a1e9:	e8 bd fd ff ff       	call   80109fab <N2H_ushort>
8010a1ee:	83 c4 10             	add    $0x10,%esp
8010a1f1:	0f b7 d8             	movzwl %ax,%ebx
8010a1f4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a1fb:	0f b7 c0             	movzwl %ax,%eax
8010a1fe:	83 ec 0c             	sub    $0xc,%esp
8010a201:	50                   	push   %eax
8010a202:	e8 a4 fd ff ff       	call   80109fab <N2H_ushort>
8010a207:	83 c4 10             	add    $0x10,%esp
8010a20a:	0f b7 c0             	movzwl %ax,%eax
8010a20d:	83 ec 04             	sub    $0x4,%esp
8010a210:	53                   	push   %ebx
8010a211:	50                   	push   %eax
8010a212:	68 63 ca 10 80       	push   $0x8010ca63
8010a217:	e8 d8 61 ff ff       	call   801003f4 <cprintf>
8010a21c:	83 c4 10             	add    $0x10,%esp
}
8010a21f:	90                   	nop
8010a220:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a223:	c9                   	leave  
8010a224:	c3                   	ret    

8010a225 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a225:	55                   	push   %ebp
8010a226:	89 e5                	mov    %esp,%ebp
8010a228:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a22b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a231:	8b 45 08             	mov    0x8(%ebp),%eax
8010a234:	83 c0 0e             	add    $0xe,%eax
8010a237:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a23a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a23d:	0f b6 00             	movzbl (%eax),%eax
8010a240:	0f b6 c0             	movzbl %al,%eax
8010a243:	83 e0 0f             	and    $0xf,%eax
8010a246:	c1 e0 02             	shl    $0x2,%eax
8010a249:	89 c2                	mov    %eax,%edx
8010a24b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a24e:	01 d0                	add    %edx,%eax
8010a250:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a253:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a256:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a259:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a25c:	83 c0 0e             	add    $0xe,%eax
8010a25f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a265:	83 c0 14             	add    $0x14,%eax
8010a268:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a26b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a26e:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a274:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a277:	8d 50 06             	lea    0x6(%eax),%edx
8010a27a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a27d:	83 ec 04             	sub    $0x4,%esp
8010a280:	6a 06                	push   $0x6
8010a282:	52                   	push   %edx
8010a283:	50                   	push   %eax
8010a284:	e8 9c b1 ff ff       	call   80105425 <memmove>
8010a289:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a28c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a28f:	83 c0 06             	add    $0x6,%eax
8010a292:	83 ec 04             	sub    $0x4,%esp
8010a295:	6a 06                	push   $0x6
8010a297:	68 10 aa 11 80       	push   $0x8011aa10
8010a29c:	50                   	push   %eax
8010a29d:	e8 83 b1 ff ff       	call   80105425 <memmove>
8010a2a2:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a2a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2a8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a2ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2af:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2b6:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2bc:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a2c0:	83 ec 0c             	sub    $0xc,%esp
8010a2c3:	6a 54                	push   $0x54
8010a2c5:	e8 03 fd ff ff       	call   80109fcd <H2N_ushort>
8010a2ca:	83 c4 10             	add    $0x10,%esp
8010a2cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2d0:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a2d4:	0f b7 15 e0 ac 11 80 	movzwl 0x8011ace0,%edx
8010a2db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2de:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a2e2:	0f b7 05 e0 ac 11 80 	movzwl 0x8011ace0,%eax
8010a2e9:	83 c0 01             	add    $0x1,%eax
8010a2ec:	66 a3 e0 ac 11 80    	mov    %ax,0x8011ace0
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a2f2:	83 ec 0c             	sub    $0xc,%esp
8010a2f5:	68 00 40 00 00       	push   $0x4000
8010a2fa:	e8 ce fc ff ff       	call   80109fcd <H2N_ushort>
8010a2ff:	83 c4 10             	add    $0x10,%esp
8010a302:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a305:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a30c:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a310:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a313:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a31a:	83 c0 0c             	add    $0xc,%eax
8010a31d:	83 ec 04             	sub    $0x4,%esp
8010a320:	6a 04                	push   $0x4
8010a322:	68 04 f5 10 80       	push   $0x8010f504
8010a327:	50                   	push   %eax
8010a328:	e8 f8 b0 ff ff       	call   80105425 <memmove>
8010a32d:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a330:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a333:	8d 50 0c             	lea    0xc(%eax),%edx
8010a336:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a339:	83 c0 10             	add    $0x10,%eax
8010a33c:	83 ec 04             	sub    $0x4,%esp
8010a33f:	6a 04                	push   $0x4
8010a341:	52                   	push   %edx
8010a342:	50                   	push   %eax
8010a343:	e8 dd b0 ff ff       	call   80105425 <memmove>
8010a348:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a34b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a34e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a354:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a357:	83 ec 0c             	sub    $0xc,%esp
8010a35a:	50                   	push   %eax
8010a35b:	e8 6d fd ff ff       	call   8010a0cd <ipv4_chksum>
8010a360:	83 c4 10             	add    $0x10,%esp
8010a363:	0f b7 c0             	movzwl %ax,%eax
8010a366:	83 ec 0c             	sub    $0xc,%esp
8010a369:	50                   	push   %eax
8010a36a:	e8 5e fc ff ff       	call   80109fcd <H2N_ushort>
8010a36f:	83 c4 10             	add    $0x10,%esp
8010a372:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a375:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a379:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a37c:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a37f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a382:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a386:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a389:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a38d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a390:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a394:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a397:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a39b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a39e:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a3a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3a5:	8d 50 08             	lea    0x8(%eax),%edx
8010a3a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ab:	83 c0 08             	add    $0x8,%eax
8010a3ae:	83 ec 04             	sub    $0x4,%esp
8010a3b1:	6a 08                	push   $0x8
8010a3b3:	52                   	push   %edx
8010a3b4:	50                   	push   %eax
8010a3b5:	e8 6b b0 ff ff       	call   80105425 <memmove>
8010a3ba:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a3bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3c0:	8d 50 10             	lea    0x10(%eax),%edx
8010a3c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3c6:	83 c0 10             	add    $0x10,%eax
8010a3c9:	83 ec 04             	sub    $0x4,%esp
8010a3cc:	6a 30                	push   $0x30
8010a3ce:	52                   	push   %edx
8010a3cf:	50                   	push   %eax
8010a3d0:	e8 50 b0 ff ff       	call   80105425 <memmove>
8010a3d5:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a3d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3db:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a3e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3e4:	83 ec 0c             	sub    $0xc,%esp
8010a3e7:	50                   	push   %eax
8010a3e8:	e8 1c 00 00 00       	call   8010a409 <icmp_chksum>
8010a3ed:	83 c4 10             	add    $0x10,%esp
8010a3f0:	0f b7 c0             	movzwl %ax,%eax
8010a3f3:	83 ec 0c             	sub    $0xc,%esp
8010a3f6:	50                   	push   %eax
8010a3f7:	e8 d1 fb ff ff       	call   80109fcd <H2N_ushort>
8010a3fc:	83 c4 10             	add    $0x10,%esp
8010a3ff:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a402:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a406:	90                   	nop
8010a407:	c9                   	leave  
8010a408:	c3                   	ret    

8010a409 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a409:	55                   	push   %ebp
8010a40a:	89 e5                	mov    %esp,%ebp
8010a40c:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a40f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a412:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a415:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a41c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a423:	eb 48                	jmp    8010a46d <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a425:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a428:	01 c0                	add    %eax,%eax
8010a42a:	89 c2                	mov    %eax,%edx
8010a42c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a42f:	01 d0                	add    %edx,%eax
8010a431:	0f b6 00             	movzbl (%eax),%eax
8010a434:	0f b6 c0             	movzbl %al,%eax
8010a437:	c1 e0 08             	shl    $0x8,%eax
8010a43a:	89 c2                	mov    %eax,%edx
8010a43c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a43f:	01 c0                	add    %eax,%eax
8010a441:	8d 48 01             	lea    0x1(%eax),%ecx
8010a444:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a447:	01 c8                	add    %ecx,%eax
8010a449:	0f b6 00             	movzbl (%eax),%eax
8010a44c:	0f b6 c0             	movzbl %al,%eax
8010a44f:	01 d0                	add    %edx,%eax
8010a451:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a454:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a45b:	76 0c                	jbe    8010a469 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a45d:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a460:	0f b7 c0             	movzwl %ax,%eax
8010a463:	83 c0 01             	add    $0x1,%eax
8010a466:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a469:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a46d:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a471:	7e b2                	jle    8010a425 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a473:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a476:	f7 d0                	not    %eax
}
8010a478:	c9                   	leave  
8010a479:	c3                   	ret    

8010a47a <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a47a:	55                   	push   %ebp
8010a47b:	89 e5                	mov    %esp,%ebp
8010a47d:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a480:	8b 45 08             	mov    0x8(%ebp),%eax
8010a483:	83 c0 0e             	add    $0xe,%eax
8010a486:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a48c:	0f b6 00             	movzbl (%eax),%eax
8010a48f:	0f b6 c0             	movzbl %al,%eax
8010a492:	83 e0 0f             	and    $0xf,%eax
8010a495:	c1 e0 02             	shl    $0x2,%eax
8010a498:	89 c2                	mov    %eax,%edx
8010a49a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a49d:	01 d0                	add    %edx,%eax
8010a49f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a4a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4a5:	83 c0 14             	add    $0x14,%eax
8010a4a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a4ab:	e8 d4 87 ff ff       	call   80102c84 <kalloc>
8010a4b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a4b3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a4ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4bd:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a4c1:	0f b6 c0             	movzbl %al,%eax
8010a4c4:	83 e0 02             	and    $0x2,%eax
8010a4c7:	85 c0                	test   %eax,%eax
8010a4c9:	74 3d                	je     8010a508 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a4cb:	83 ec 0c             	sub    $0xc,%esp
8010a4ce:	6a 00                	push   $0x0
8010a4d0:	6a 12                	push   $0x12
8010a4d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a4d5:	50                   	push   %eax
8010a4d6:	ff 75 e8             	push   -0x18(%ebp)
8010a4d9:	ff 75 08             	push   0x8(%ebp)
8010a4dc:	e8 a2 01 00 00       	call   8010a683 <tcp_pkt_create>
8010a4e1:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a4e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a4e7:	83 ec 08             	sub    $0x8,%esp
8010a4ea:	50                   	push   %eax
8010a4eb:	ff 75 e8             	push   -0x18(%ebp)
8010a4ee:	e8 61 f1 ff ff       	call   80109654 <i8254_send>
8010a4f3:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a4f6:	a1 e4 ac 11 80       	mov    0x8011ace4,%eax
8010a4fb:	83 c0 01             	add    $0x1,%eax
8010a4fe:	a3 e4 ac 11 80       	mov    %eax,0x8011ace4
8010a503:	e9 69 01 00 00       	jmp    8010a671 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a50b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a50f:	3c 18                	cmp    $0x18,%al
8010a511:	0f 85 10 01 00 00    	jne    8010a627 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a517:	83 ec 04             	sub    $0x4,%esp
8010a51a:	6a 03                	push   $0x3
8010a51c:	68 7e ca 10 80       	push   $0x8010ca7e
8010a521:	ff 75 ec             	push   -0x14(%ebp)
8010a524:	e8 a4 ae ff ff       	call   801053cd <memcmp>
8010a529:	83 c4 10             	add    $0x10,%esp
8010a52c:	85 c0                	test   %eax,%eax
8010a52e:	74 74                	je     8010a5a4 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a530:	83 ec 0c             	sub    $0xc,%esp
8010a533:	68 82 ca 10 80       	push   $0x8010ca82
8010a538:	e8 b7 5e ff ff       	call   801003f4 <cprintf>
8010a53d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a540:	83 ec 0c             	sub    $0xc,%esp
8010a543:	6a 00                	push   $0x0
8010a545:	6a 10                	push   $0x10
8010a547:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a54a:	50                   	push   %eax
8010a54b:	ff 75 e8             	push   -0x18(%ebp)
8010a54e:	ff 75 08             	push   0x8(%ebp)
8010a551:	e8 2d 01 00 00       	call   8010a683 <tcp_pkt_create>
8010a556:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a559:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a55c:	83 ec 08             	sub    $0x8,%esp
8010a55f:	50                   	push   %eax
8010a560:	ff 75 e8             	push   -0x18(%ebp)
8010a563:	e8 ec f0 ff ff       	call   80109654 <i8254_send>
8010a568:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a56b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a56e:	83 c0 36             	add    $0x36,%eax
8010a571:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a574:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a577:	50                   	push   %eax
8010a578:	ff 75 e0             	push   -0x20(%ebp)
8010a57b:	6a 00                	push   $0x0
8010a57d:	6a 00                	push   $0x0
8010a57f:	e8 5a 04 00 00       	call   8010a9de <http_proc>
8010a584:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a587:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a58a:	83 ec 0c             	sub    $0xc,%esp
8010a58d:	50                   	push   %eax
8010a58e:	6a 18                	push   $0x18
8010a590:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a593:	50                   	push   %eax
8010a594:	ff 75 e8             	push   -0x18(%ebp)
8010a597:	ff 75 08             	push   0x8(%ebp)
8010a59a:	e8 e4 00 00 00       	call   8010a683 <tcp_pkt_create>
8010a59f:	83 c4 20             	add    $0x20,%esp
8010a5a2:	eb 62                	jmp    8010a606 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a5a4:	83 ec 0c             	sub    $0xc,%esp
8010a5a7:	6a 00                	push   $0x0
8010a5a9:	6a 10                	push   $0x10
8010a5ab:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a5ae:	50                   	push   %eax
8010a5af:	ff 75 e8             	push   -0x18(%ebp)
8010a5b2:	ff 75 08             	push   0x8(%ebp)
8010a5b5:	e8 c9 00 00 00       	call   8010a683 <tcp_pkt_create>
8010a5ba:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a5bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a5c0:	83 ec 08             	sub    $0x8,%esp
8010a5c3:	50                   	push   %eax
8010a5c4:	ff 75 e8             	push   -0x18(%ebp)
8010a5c7:	e8 88 f0 ff ff       	call   80109654 <i8254_send>
8010a5cc:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a5cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5d2:	83 c0 36             	add    $0x36,%eax
8010a5d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a5d8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a5db:	50                   	push   %eax
8010a5dc:	ff 75 e4             	push   -0x1c(%ebp)
8010a5df:	6a 00                	push   $0x0
8010a5e1:	6a 00                	push   $0x0
8010a5e3:	e8 f6 03 00 00       	call   8010a9de <http_proc>
8010a5e8:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a5eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a5ee:	83 ec 0c             	sub    $0xc,%esp
8010a5f1:	50                   	push   %eax
8010a5f2:	6a 18                	push   $0x18
8010a5f4:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a5f7:	50                   	push   %eax
8010a5f8:	ff 75 e8             	push   -0x18(%ebp)
8010a5fb:	ff 75 08             	push   0x8(%ebp)
8010a5fe:	e8 80 00 00 00       	call   8010a683 <tcp_pkt_create>
8010a603:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a606:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a609:	83 ec 08             	sub    $0x8,%esp
8010a60c:	50                   	push   %eax
8010a60d:	ff 75 e8             	push   -0x18(%ebp)
8010a610:	e8 3f f0 ff ff       	call   80109654 <i8254_send>
8010a615:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a618:	a1 e4 ac 11 80       	mov    0x8011ace4,%eax
8010a61d:	83 c0 01             	add    $0x1,%eax
8010a620:	a3 e4 ac 11 80       	mov    %eax,0x8011ace4
8010a625:	eb 4a                	jmp    8010a671 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a62a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a62e:	3c 10                	cmp    $0x10,%al
8010a630:	75 3f                	jne    8010a671 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a632:	a1 e8 ac 11 80       	mov    0x8011ace8,%eax
8010a637:	83 f8 01             	cmp    $0x1,%eax
8010a63a:	75 35                	jne    8010a671 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a63c:	83 ec 0c             	sub    $0xc,%esp
8010a63f:	6a 00                	push   $0x0
8010a641:	6a 01                	push   $0x1
8010a643:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a646:	50                   	push   %eax
8010a647:	ff 75 e8             	push   -0x18(%ebp)
8010a64a:	ff 75 08             	push   0x8(%ebp)
8010a64d:	e8 31 00 00 00       	call   8010a683 <tcp_pkt_create>
8010a652:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a655:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a658:	83 ec 08             	sub    $0x8,%esp
8010a65b:	50                   	push   %eax
8010a65c:	ff 75 e8             	push   -0x18(%ebp)
8010a65f:	e8 f0 ef ff ff       	call   80109654 <i8254_send>
8010a664:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a667:	c7 05 e8 ac 11 80 00 	movl   $0x0,0x8011ace8
8010a66e:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a671:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a674:	83 ec 0c             	sub    $0xc,%esp
8010a677:	50                   	push   %eax
8010a678:	e8 6d 85 ff ff       	call   80102bea <kfree>
8010a67d:	83 c4 10             	add    $0x10,%esp
}
8010a680:	90                   	nop
8010a681:	c9                   	leave  
8010a682:	c3                   	ret    

8010a683 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a683:	55                   	push   %ebp
8010a684:	89 e5                	mov    %esp,%ebp
8010a686:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a689:	8b 45 08             	mov    0x8(%ebp),%eax
8010a68c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a68f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a692:	83 c0 0e             	add    $0xe,%eax
8010a695:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a698:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a69b:	0f b6 00             	movzbl (%eax),%eax
8010a69e:	0f b6 c0             	movzbl %al,%eax
8010a6a1:	83 e0 0f             	and    $0xf,%eax
8010a6a4:	c1 e0 02             	shl    $0x2,%eax
8010a6a7:	89 c2                	mov    %eax,%edx
8010a6a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6ac:	01 d0                	add    %edx,%eax
8010a6ae:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a6b1:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a6b7:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6ba:	83 c0 0e             	add    $0xe,%eax
8010a6bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a6c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6c3:	83 c0 14             	add    $0x14,%eax
8010a6c6:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a6c9:	8b 45 18             	mov    0x18(%ebp),%eax
8010a6cc:	8d 50 36             	lea    0x36(%eax),%edx
8010a6cf:	8b 45 10             	mov    0x10(%ebp),%eax
8010a6d2:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a6d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a6d7:	8d 50 06             	lea    0x6(%eax),%edx
8010a6da:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6dd:	83 ec 04             	sub    $0x4,%esp
8010a6e0:	6a 06                	push   $0x6
8010a6e2:	52                   	push   %edx
8010a6e3:	50                   	push   %eax
8010a6e4:	e8 3c ad ff ff       	call   80105425 <memmove>
8010a6e9:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a6ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6ef:	83 c0 06             	add    $0x6,%eax
8010a6f2:	83 ec 04             	sub    $0x4,%esp
8010a6f5:	6a 06                	push   $0x6
8010a6f7:	68 10 aa 11 80       	push   $0x8011aa10
8010a6fc:	50                   	push   %eax
8010a6fd:	e8 23 ad ff ff       	call   80105425 <memmove>
8010a702:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a705:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a708:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a70c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a70f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a716:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a719:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a71c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a720:	8b 45 18             	mov    0x18(%ebp),%eax
8010a723:	83 c0 28             	add    $0x28,%eax
8010a726:	0f b7 c0             	movzwl %ax,%eax
8010a729:	83 ec 0c             	sub    $0xc,%esp
8010a72c:	50                   	push   %eax
8010a72d:	e8 9b f8 ff ff       	call   80109fcd <H2N_ushort>
8010a732:	83 c4 10             	add    $0x10,%esp
8010a735:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a738:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a73c:	0f b7 15 e0 ac 11 80 	movzwl 0x8011ace0,%edx
8010a743:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a746:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a74a:	0f b7 05 e0 ac 11 80 	movzwl 0x8011ace0,%eax
8010a751:	83 c0 01             	add    $0x1,%eax
8010a754:	66 a3 e0 ac 11 80    	mov    %ax,0x8011ace0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a75a:	83 ec 0c             	sub    $0xc,%esp
8010a75d:	6a 00                	push   $0x0
8010a75f:	e8 69 f8 ff ff       	call   80109fcd <H2N_ushort>
8010a764:	83 c4 10             	add    $0x10,%esp
8010a767:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a76a:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a76e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a771:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a775:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a778:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a77c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a77f:	83 c0 0c             	add    $0xc,%eax
8010a782:	83 ec 04             	sub    $0x4,%esp
8010a785:	6a 04                	push   $0x4
8010a787:	68 04 f5 10 80       	push   $0x8010f504
8010a78c:	50                   	push   %eax
8010a78d:	e8 93 ac ff ff       	call   80105425 <memmove>
8010a792:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a795:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a798:	8d 50 0c             	lea    0xc(%eax),%edx
8010a79b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a79e:	83 c0 10             	add    $0x10,%eax
8010a7a1:	83 ec 04             	sub    $0x4,%esp
8010a7a4:	6a 04                	push   $0x4
8010a7a6:	52                   	push   %edx
8010a7a7:	50                   	push   %eax
8010a7a8:	e8 78 ac ff ff       	call   80105425 <memmove>
8010a7ad:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a7b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7b3:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a7b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7bc:	83 ec 0c             	sub    $0xc,%esp
8010a7bf:	50                   	push   %eax
8010a7c0:	e8 08 f9 ff ff       	call   8010a0cd <ipv4_chksum>
8010a7c5:	83 c4 10             	add    $0x10,%esp
8010a7c8:	0f b7 c0             	movzwl %ax,%eax
8010a7cb:	83 ec 0c             	sub    $0xc,%esp
8010a7ce:	50                   	push   %eax
8010a7cf:	e8 f9 f7 ff ff       	call   80109fcd <H2N_ushort>
8010a7d4:	83 c4 10             	add    $0x10,%esp
8010a7d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a7da:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a7de:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a7e1:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a7e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7e8:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a7eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a7ee:	0f b7 10             	movzwl (%eax),%edx
8010a7f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7f4:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a7f8:	a1 e4 ac 11 80       	mov    0x8011ace4,%eax
8010a7fd:	83 ec 0c             	sub    $0xc,%esp
8010a800:	50                   	push   %eax
8010a801:	e8 e9 f7 ff ff       	call   80109fef <H2N_uint>
8010a806:	83 c4 10             	add    $0x10,%esp
8010a809:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a80c:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a80f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a812:	8b 40 04             	mov    0x4(%eax),%eax
8010a815:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a81b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a81e:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a821:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a824:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a828:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a82b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a82f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a832:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a836:	8b 45 14             	mov    0x14(%ebp),%eax
8010a839:	89 c2                	mov    %eax,%edx
8010a83b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a83e:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a841:	83 ec 0c             	sub    $0xc,%esp
8010a844:	68 90 38 00 00       	push   $0x3890
8010a849:	e8 7f f7 ff ff       	call   80109fcd <H2N_ushort>
8010a84e:	83 c4 10             	add    $0x10,%esp
8010a851:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a854:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a858:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a85b:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a861:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a864:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a86a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a86d:	83 ec 0c             	sub    $0xc,%esp
8010a870:	50                   	push   %eax
8010a871:	e8 1f 00 00 00       	call   8010a895 <tcp_chksum>
8010a876:	83 c4 10             	add    $0x10,%esp
8010a879:	83 c0 08             	add    $0x8,%eax
8010a87c:	0f b7 c0             	movzwl %ax,%eax
8010a87f:	83 ec 0c             	sub    $0xc,%esp
8010a882:	50                   	push   %eax
8010a883:	e8 45 f7 ff ff       	call   80109fcd <H2N_ushort>
8010a888:	83 c4 10             	add    $0x10,%esp
8010a88b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a88e:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a892:	90                   	nop
8010a893:	c9                   	leave  
8010a894:	c3                   	ret    

8010a895 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a895:	55                   	push   %ebp
8010a896:	89 e5                	mov    %esp,%ebp
8010a898:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a89b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a89e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a8a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8a4:	83 c0 14             	add    $0x14,%eax
8010a8a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a8aa:	83 ec 04             	sub    $0x4,%esp
8010a8ad:	6a 04                	push   $0x4
8010a8af:	68 04 f5 10 80       	push   $0x8010f504
8010a8b4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a8b7:	50                   	push   %eax
8010a8b8:	e8 68 ab ff ff       	call   80105425 <memmove>
8010a8bd:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a8c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8c3:	83 c0 0c             	add    $0xc,%eax
8010a8c6:	83 ec 04             	sub    $0x4,%esp
8010a8c9:	6a 04                	push   $0x4
8010a8cb:	50                   	push   %eax
8010a8cc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a8cf:	83 c0 04             	add    $0x4,%eax
8010a8d2:	50                   	push   %eax
8010a8d3:	e8 4d ab ff ff       	call   80105425 <memmove>
8010a8d8:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a8db:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a8df:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a8e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8e6:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a8ea:	0f b7 c0             	movzwl %ax,%eax
8010a8ed:	83 ec 0c             	sub    $0xc,%esp
8010a8f0:	50                   	push   %eax
8010a8f1:	e8 b5 f6 ff ff       	call   80109fab <N2H_ushort>
8010a8f6:	83 c4 10             	add    $0x10,%esp
8010a8f9:	83 e8 14             	sub    $0x14,%eax
8010a8fc:	0f b7 c0             	movzwl %ax,%eax
8010a8ff:	83 ec 0c             	sub    $0xc,%esp
8010a902:	50                   	push   %eax
8010a903:	e8 c5 f6 ff ff       	call   80109fcd <H2N_ushort>
8010a908:	83 c4 10             	add    $0x10,%esp
8010a90b:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a90f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a916:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a919:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a91c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a923:	eb 33                	jmp    8010a958 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a925:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a928:	01 c0                	add    %eax,%eax
8010a92a:	89 c2                	mov    %eax,%edx
8010a92c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a92f:	01 d0                	add    %edx,%eax
8010a931:	0f b6 00             	movzbl (%eax),%eax
8010a934:	0f b6 c0             	movzbl %al,%eax
8010a937:	c1 e0 08             	shl    $0x8,%eax
8010a93a:	89 c2                	mov    %eax,%edx
8010a93c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a93f:	01 c0                	add    %eax,%eax
8010a941:	8d 48 01             	lea    0x1(%eax),%ecx
8010a944:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a947:	01 c8                	add    %ecx,%eax
8010a949:	0f b6 00             	movzbl (%eax),%eax
8010a94c:	0f b6 c0             	movzbl %al,%eax
8010a94f:	01 d0                	add    %edx,%eax
8010a951:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a954:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a958:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a95c:	7e c7                	jle    8010a925 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a95e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a961:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a964:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a96b:	eb 33                	jmp    8010a9a0 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a96d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a970:	01 c0                	add    %eax,%eax
8010a972:	89 c2                	mov    %eax,%edx
8010a974:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a977:	01 d0                	add    %edx,%eax
8010a979:	0f b6 00             	movzbl (%eax),%eax
8010a97c:	0f b6 c0             	movzbl %al,%eax
8010a97f:	c1 e0 08             	shl    $0x8,%eax
8010a982:	89 c2                	mov    %eax,%edx
8010a984:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a987:	01 c0                	add    %eax,%eax
8010a989:	8d 48 01             	lea    0x1(%eax),%ecx
8010a98c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a98f:	01 c8                	add    %ecx,%eax
8010a991:	0f b6 00             	movzbl (%eax),%eax
8010a994:	0f b6 c0             	movzbl %al,%eax
8010a997:	01 d0                	add    %edx,%eax
8010a999:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a99c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a9a0:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a9a4:	0f b7 c0             	movzwl %ax,%eax
8010a9a7:	83 ec 0c             	sub    $0xc,%esp
8010a9aa:	50                   	push   %eax
8010a9ab:	e8 fb f5 ff ff       	call   80109fab <N2H_ushort>
8010a9b0:	83 c4 10             	add    $0x10,%esp
8010a9b3:	66 d1 e8             	shr    %ax
8010a9b6:	0f b7 c0             	movzwl %ax,%eax
8010a9b9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a9bc:	7c af                	jl     8010a96d <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a9c1:	c1 e8 10             	shr    $0x10,%eax
8010a9c4:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a9c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a9ca:	f7 d0                	not    %eax
}
8010a9cc:	c9                   	leave  
8010a9cd:	c3                   	ret    

8010a9ce <tcp_fin>:

void tcp_fin(){
8010a9ce:	55                   	push   %ebp
8010a9cf:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a9d1:	c7 05 e8 ac 11 80 01 	movl   $0x1,0x8011ace8
8010a9d8:	00 00 00 
}
8010a9db:	90                   	nop
8010a9dc:	5d                   	pop    %ebp
8010a9dd:	c3                   	ret    

8010a9de <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a9de:	55                   	push   %ebp
8010a9df:	89 e5                	mov    %esp,%ebp
8010a9e1:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a9e4:	8b 45 10             	mov    0x10(%ebp),%eax
8010a9e7:	83 ec 04             	sub    $0x4,%esp
8010a9ea:	6a 00                	push   $0x0
8010a9ec:	68 8b ca 10 80       	push   $0x8010ca8b
8010a9f1:	50                   	push   %eax
8010a9f2:	e8 65 00 00 00       	call   8010aa5c <http_strcpy>
8010a9f7:	83 c4 10             	add    $0x10,%esp
8010a9fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a9fd:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa00:	83 ec 04             	sub    $0x4,%esp
8010aa03:	ff 75 f4             	push   -0xc(%ebp)
8010aa06:	68 9e ca 10 80       	push   $0x8010ca9e
8010aa0b:	50                   	push   %eax
8010aa0c:	e8 4b 00 00 00       	call   8010aa5c <http_strcpy>
8010aa11:	83 c4 10             	add    $0x10,%esp
8010aa14:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010aa17:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa1a:	83 ec 04             	sub    $0x4,%esp
8010aa1d:	ff 75 f4             	push   -0xc(%ebp)
8010aa20:	68 b9 ca 10 80       	push   $0x8010cab9
8010aa25:	50                   	push   %eax
8010aa26:	e8 31 00 00 00       	call   8010aa5c <http_strcpy>
8010aa2b:	83 c4 10             	add    $0x10,%esp
8010aa2e:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010aa31:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010aa34:	83 e0 01             	and    $0x1,%eax
8010aa37:	85 c0                	test   %eax,%eax
8010aa39:	74 11                	je     8010aa4c <http_proc+0x6e>
    char *payload = (char *)send;
8010aa3b:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010aa41:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa44:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa47:	01 d0                	add    %edx,%eax
8010aa49:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010aa4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa4f:	8b 45 14             	mov    0x14(%ebp),%eax
8010aa52:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010aa54:	e8 75 ff ff ff       	call   8010a9ce <tcp_fin>
}
8010aa59:	90                   	nop
8010aa5a:	c9                   	leave  
8010aa5b:	c3                   	ret    

8010aa5c <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010aa5c:	55                   	push   %ebp
8010aa5d:	89 e5                	mov    %esp,%ebp
8010aa5f:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010aa62:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010aa69:	eb 20                	jmp    8010aa8b <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010aa6b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aa6e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aa71:	01 d0                	add    %edx,%eax
8010aa73:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010aa76:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aa79:	01 ca                	add    %ecx,%edx
8010aa7b:	89 d1                	mov    %edx,%ecx
8010aa7d:	8b 55 08             	mov    0x8(%ebp),%edx
8010aa80:	01 ca                	add    %ecx,%edx
8010aa82:	0f b6 00             	movzbl (%eax),%eax
8010aa85:	88 02                	mov    %al,(%edx)
    i++;
8010aa87:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010aa8b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aa8e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aa91:	01 d0                	add    %edx,%eax
8010aa93:	0f b6 00             	movzbl (%eax),%eax
8010aa96:	84 c0                	test   %al,%al
8010aa98:	75 d1                	jne    8010aa6b <http_strcpy+0xf>
  }
  return i;
8010aa9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010aa9d:	c9                   	leave  
8010aa9e:	c3                   	ret    
