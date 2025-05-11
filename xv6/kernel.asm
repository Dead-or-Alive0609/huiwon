
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
8010006f:	68 e0 aa 10 80       	push   $0x8010aae0
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 2a 50 00 00       	call   801050a8 <initlock>
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
801000bd:	68 e7 aa 10 80       	push   $0x8010aae7
801000c2:	50                   	push   %eax
801000c3:	e8 83 4e 00 00       	call   80104f4b <initsleeplock>
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
80100101:	e8 c4 4f 00 00       	call   801050ca <acquire>
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
80100140:	e8 f3 4f 00 00       	call   80105138 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 30 4e 00 00       	call   80104f87 <acquiresleep>
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
801001c1:	e8 72 4f 00 00       	call   80105138 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 af 4d 00 00       	call   80104f87 <acquiresleep>
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
801001f5:	68 ee aa 10 80       	push   $0x8010aaee
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
8010024a:	e8 ea 4d 00 00       	call   80105039 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 ff aa 10 80       	push   $0x8010aaff
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
80100293:	e8 a1 4d 00 00       	call   80105039 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 06 ab 10 80       	push   $0x8010ab06
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 30 4d 00 00       	call   80104feb <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 ff 4d 00 00       	call   801050ca <acquire>
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
80100336:	e8 fd 4d 00 00       	call   80105138 <release>
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
80100410:	e8 b5 4c 00 00       	call   801050ca <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 0d ab 10 80       	push   $0x8010ab0d
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
80100510:	c7 45 ec 16 ab 10 80 	movl   $0x8010ab16,-0x14(%ebp)
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
8010059e:	e8 95 4b 00 00       	call   80105138 <release>
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
801005c7:	68 1d ab 10 80       	push   $0x8010ab1d
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
801005e6:	68 31 ab 10 80       	push   $0x8010ab31
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 87 4b 00 00       	call   8010518a <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 33 ab 10 80       	push   $0x8010ab33
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
801006a0:	e8 aa 83 00 00       	call   80108a4f <graphic_scroll_up>
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
801006f3:	e8 57 83 00 00       	call   80108a4f <graphic_scroll_up>
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
80100757:	e8 5e 83 00 00       	call   80108aba <font_render>
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
80100793:	e8 2e 67 00 00       	call   80106ec6 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 21 67 00 00       	call   80106ec6 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 14 67 00 00       	call   80106ec6 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 04 67 00 00       	call   80106ec6 <uartputc>
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
801007eb:	e8 da 48 00 00       	call   801050ca <acquire>
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
8010093f:	e8 eb 41 00 00       	call   80104b2f <wakeup>
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
80100962:	e8 d1 47 00 00       	call   80105138 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 79 43 00 00       	call   80104cee <procdump>
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
8010099a:	e8 2b 47 00 00       	call   801050ca <acquire>
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
801009bb:	e8 78 47 00 00       	call   80105138 <release>
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
801009e8:	e8 58 40 00 00       	call   80104a45 <sleep>
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
80100a66:	e8 cd 46 00 00       	call   80105138 <release>
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
80100aa2:	e8 23 46 00 00       	call   801050ca <acquire>
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
80100ae4:	e8 4f 46 00 00       	call   80105138 <release>
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
80100b12:	68 37 ab 10 80       	push   $0x8010ab37
80100b17:	68 00 4a 11 80       	push   $0x80114a00
80100b1c:	e8 87 45 00 00       	call   801050a8 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 4a 11 80 86 	movl   $0x80100a86,0x80114a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 4a 11 80 78 	movl   $0x80100978,0x80114a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 3f ab 10 80 	movl   $0x8010ab3f,-0xc(%ebp)
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
80100bb5:	68 55 ab 10 80       	push   $0x8010ab55
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
80100c11:	e8 ac 72 00 00       	call   80107ec2 <setupkvm>
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
80100cb7:	e8 ff 75 00 00       	call   801082bb <allocuvm>
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
80100cfd:	e8 ec 74 00 00       	call   801081ee <loaduvm>
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
80100d6c:	e8 4a 75 00 00       	call   801082bb <allocuvm>
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
80100d90:	e8 88 77 00 00       	call   8010851d <clearpteu>
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
80100dc9:	e8 c0 47 00 00       	call   8010558e <strlen>
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
80100df6:	e8 93 47 00 00       	call   8010558e <strlen>
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
80100e1c:	e8 9b 78 00 00       	call   801086bc <copyout>
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
80100eb8:	e8 ff 77 00 00       	call   801086bc <copyout>
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
80100f06:	e8 38 46 00 00       	call   80105543 <safestrcpy>
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
80100f49:	e8 91 70 00 00       	call   80107fdf <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 28 75 00 00       	call   80108484 <freevm>
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
80100f97:	e8 e8 74 00 00       	call   80108484 <freevm>
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
80100fc8:	68 61 ab 10 80       	push   $0x8010ab61
80100fcd:	68 a0 4a 11 80       	push   $0x80114aa0
80100fd2:	e8 d1 40 00 00       	call   801050a8 <initlock>
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
80100feb:	e8 da 40 00 00       	call   801050ca <acquire>
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
80101018:	e8 1b 41 00 00       	call   80105138 <release>
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
8010103b:	e8 f8 40 00 00       	call   80105138 <release>
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
80101058:	e8 6d 40 00 00       	call   801050ca <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 68 ab 10 80       	push   $0x8010ab68
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
8010108e:	e8 a5 40 00 00       	call   80105138 <release>
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
801010a9:	e8 1c 40 00 00       	call   801050ca <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 70 ab 10 80       	push   $0x8010ab70
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
801010e9:	e8 4a 40 00 00       	call   80105138 <release>
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
80101137:	e8 fc 3f 00 00       	call   80105138 <release>
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
80101286:	68 7a ab 10 80       	push   $0x8010ab7a
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
80101389:	68 83 ab 10 80       	push   $0x8010ab83
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
801013bf:	68 93 ab 10 80       	push   $0x8010ab93
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
801013f7:	e8 03 40 00 00       	call   801053ff <memmove>
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
8010143d:	e8 fe 3e 00 00       	call   80105340 <memset>
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
8010159c:	68 a0 ab 10 80       	push   $0x8010aba0
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
80101627:	68 b6 ab 10 80       	push   $0x8010abb6
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
8010168b:	68 c9 ab 10 80       	push   $0x8010abc9
80101690:	68 60 54 11 80       	push   $0x80115460
80101695:	e8 0e 3a 00 00       	call   801050a8 <initlock>
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
801016c1:	68 d0 ab 10 80       	push   $0x8010abd0
801016c6:	50                   	push   %eax
801016c7:	e8 7f 38 00 00       	call   80104f4b <initsleeplock>
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
80101720:	68 d8 ab 10 80       	push   $0x8010abd8
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
80101799:	e8 a2 3b 00 00       	call   80105340 <memset>
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
80101801:	68 2b ac 10 80       	push   $0x8010ac2b
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
801018a7:	e8 53 3b 00 00       	call   801053ff <memmove>
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
801018dc:	e8 e9 37 00 00       	call   801050ca <acquire>
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
8010192a:	e8 09 38 00 00       	call   80105138 <release>
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
80101966:	68 3d ac 10 80       	push   $0x8010ac3d
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
801019a3:	e8 90 37 00 00       	call   80105138 <release>
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
801019be:	e8 07 37 00 00       	call   801050ca <acquire>
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
801019dd:	e8 56 37 00 00       	call   80105138 <release>
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
80101a03:	68 4d ac 10 80       	push   $0x8010ac4d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 6b 35 00 00       	call   80104f87 <acquiresleep>
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
80101ac1:	e8 39 39 00 00       	call   801053ff <memmove>
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
80101af0:	68 53 ac 10 80       	push   $0x8010ac53
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
80101b13:	e8 21 35 00 00       	call   80105039 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 62 ac 10 80       	push   $0x8010ac62
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 a6 34 00 00       	call   80104feb <releasesleep>
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
80101b5b:	e8 27 34 00 00       	call   80104f87 <acquiresleep>
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
80101b81:	e8 44 35 00 00       	call   801050ca <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 54 11 80       	push   $0x80115460
80101b9a:	e8 99 35 00 00       	call   80105138 <release>
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
80101be1:	e8 05 34 00 00       	call   80104feb <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 54 11 80       	push   $0x80115460
80101bf1:	e8 d4 34 00 00       	call   801050ca <acquire>
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
80101c10:	e8 23 35 00 00       	call   80105138 <release>
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
80101d54:	68 6a ac 10 80       	push   $0x8010ac6a
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
80101ff2:	e8 08 34 00 00       	call   801053ff <memmove>
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
80102142:	e8 b8 32 00 00       	call   801053ff <memmove>
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
801021c2:	e8 ce 32 00 00       	call   80105495 <strncmp>
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
801021e2:	68 7d ac 10 80       	push   $0x8010ac7d
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
80102211:	68 8f ac 10 80       	push   $0x8010ac8f
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
801022e6:	68 9e ac 10 80       	push   $0x8010ac9e
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
80102321:	e8 c5 31 00 00       	call   801054eb <strncpy>
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
8010234d:	68 ab ac 10 80       	push   $0x8010acab
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
801023bf:	e8 3b 30 00 00       	call   801053ff <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 24 30 00 00       	call   801053ff <memmove>
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
8010262c:	68 b3 ac 10 80       	push   $0x8010acb3
80102631:	68 c0 70 11 80       	push   $0x801170c0
80102636:	e8 6d 2a 00 00       	call   801050a8 <initlock>
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
801026d3:	68 b7 ac 10 80       	push   $0x8010acb7
801026d8:	e8 cc de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026dd:	8b 45 08             	mov    0x8(%ebp),%eax
801026e0:	8b 40 08             	mov    0x8(%eax),%eax
801026e3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e8:	76 0d                	jbe    801026f7 <idestart+0x33>
    panic("incorrect blockno");
801026ea:	83 ec 0c             	sub    $0xc,%esp
801026ed:	68 c0 ac 10 80       	push   $0x8010acc0
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
80102740:	68 b7 ac 10 80       	push   $0x8010acb7
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
80102864:	e8 61 28 00 00       	call   801050ca <acquire>
80102869:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010286c:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102871:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102874:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102878:	75 15                	jne    8010288f <ideintr+0x39>
    release(&idelock);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 c0 70 11 80       	push   $0x801170c0
80102882:	e8 b1 28 00 00       	call   80105138 <release>
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
801028f7:	e8 33 22 00 00       	call   80104b2f <wakeup>
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
80102921:	e8 12 28 00 00       	call   80105138 <release>
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
80102942:	68 d2 ac 10 80       	push   $0x8010acd2
80102947:	e8 a8 da ff ff       	call   801003f4 <cprintf>
8010294c:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	83 c0 0c             	add    $0xc,%eax
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	50                   	push   %eax
80102959:	e8 db 26 00 00       	call   80105039 <holdingsleep>
8010295e:	83 c4 10             	add    $0x10,%esp
80102961:	85 c0                	test   %eax,%eax
80102963:	75 0d                	jne    80102972 <iderw+0x47>
    panic("iderw: buf not locked");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 ec ac 10 80       	push   $0x8010acec
8010296d:	e8 37 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	8b 00                	mov    (%eax),%eax
80102977:	83 e0 06             	and    $0x6,%eax
8010297a:	83 f8 02             	cmp    $0x2,%eax
8010297d:	75 0d                	jne    8010298c <iderw+0x61>
    panic("iderw: nothing to do");
8010297f:	83 ec 0c             	sub    $0xc,%esp
80102982:	68 02 ad 10 80       	push   $0x8010ad02
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
801029a2:	68 17 ad 10 80       	push   $0x8010ad17
801029a7:	e8 fd db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ac:	83 ec 0c             	sub    $0xc,%esp
801029af:	68 c0 70 11 80       	push   $0x801170c0
801029b4:	e8 11 27 00 00       	call   801050ca <acquire>
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
80102a10:	e8 30 20 00 00       	call   80104a45 <sleep>
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
80102a2d:	e8 06 27 00 00       	call   80105138 <release>
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
80102ab1:	68 38 ad 10 80       	push   $0x8010ad38
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
80102b58:	68 6a ad 10 80       	push   $0x8010ad6a
80102b5d:	68 00 71 11 80       	push   $0x80117100
80102b62:	e8 41 25 00 00       	call   801050a8 <initlock>
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
80102c17:	68 6f ad 10 80       	push   $0x8010ad6f
80102c1c:	e8 88 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c21:	83 ec 04             	sub    $0x4,%esp
80102c24:	68 00 10 00 00       	push   $0x1000
80102c29:	6a 01                	push   $0x1
80102c2b:	ff 75 08             	push   0x8(%ebp)
80102c2e:	e8 0d 27 00 00       	call   80105340 <memset>
80102c33:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c36:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c3b:	85 c0                	test   %eax,%eax
80102c3d:	74 10                	je     80102c4f <kfree+0x65>
    acquire(&kmem.lock);
80102c3f:	83 ec 0c             	sub    $0xc,%esp
80102c42:	68 00 71 11 80       	push   $0x80117100
80102c47:	e8 7e 24 00 00       	call   801050ca <acquire>
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
80102c79:	e8 ba 24 00 00       	call   80105138 <release>
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
80102c9b:	e8 2a 24 00 00       	call   801050ca <acquire>
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
80102ccc:	e8 67 24 00 00       	call   80105138 <release>
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
801031f6:	e8 ac 21 00 00       	call   801053a7 <memcmp>
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
8010330a:	68 75 ad 10 80       	push   $0x8010ad75
8010330f:	68 60 71 11 80       	push   $0x80117160
80103314:	e8 8f 1d 00 00       	call   801050a8 <initlock>
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
801033bf:	e8 3b 20 00 00       	call   801053ff <memmove>
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
8010352e:	e8 97 1b 00 00       	call   801050ca <acquire>
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
8010354c:	e8 f4 14 00 00       	call   80104a45 <sleep>
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
80103581:	e8 bf 14 00 00       	call   80104a45 <sleep>
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
801035a0:	e8 93 1b 00 00       	call   80105138 <release>
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
801035c1:	e8 04 1b 00 00       	call   801050ca <acquire>
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
801035e2:	68 79 ad 10 80       	push   $0x8010ad79
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
80103610:	e8 1a 15 00 00       	call   80104b2f <wakeup>
80103615:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103618:	83 ec 0c             	sub    $0xc,%esp
8010361b:	68 60 71 11 80       	push   $0x80117160
80103620:	e8 13 1b 00 00       	call   80105138 <release>
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
8010363b:	e8 8a 1a 00 00       	call   801050ca <acquire>
80103640:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103643:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364a:	00 00 00 
    wakeup(&log);
8010364d:	83 ec 0c             	sub    $0xc,%esp
80103650:	68 60 71 11 80       	push   $0x80117160
80103655:	e8 d5 14 00 00       	call   80104b2f <wakeup>
8010365a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	68 60 71 11 80       	push   $0x80117160
80103665:	e8 ce 1a 00 00       	call   80105138 <release>
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
801036e1:	e8 19 1d 00 00       	call   801053ff <memmove>
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
8010377e:	68 88 ad 10 80       	push   $0x8010ad88
80103783:	e8 21 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103788:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378d:	85 c0                	test   %eax,%eax
8010378f:	7f 0d                	jg     8010379e <log_write+0x45>
    panic("log_write outside of trans");
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 9e ad 10 80       	push   $0x8010ad9e
80103799:	e8 0b ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 71 11 80       	push   $0x80117160
801037a6:	e8 1f 19 00 00       	call   801050ca <acquire>
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
80103824:	e8 0f 19 00 00       	call   80105138 <release>
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
8010385a:	e8 35 51 00 00       	call   80108994 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010385f:	83 ec 08             	sub    $0x8,%esp
80103862:	68 00 00 40 80       	push   $0x80400000
80103867:	68 00 c0 11 80       	push   $0x8011c000
8010386c:	e8 de f2 ff ff       	call   80102b4f <kinit1>
80103871:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103874:	e8 35 47 00 00       	call   80107fae <kvmalloc>
  mpinit_uefi();
80103879:	e8 dc 4e 00 00       	call   8010875a <mpinit_uefi>
  lapicinit();     // interrupt controller
8010387e:	e8 3c f6 ff ff       	call   80102ebf <lapicinit>
  seginit();       // segment descriptors
80103883:	e8 be 41 00 00       	call   80107a46 <seginit>
  picinit();    // disable pic
80103888:	e8 9d 01 00 00       	call   80103a2a <picinit>
  ioapicinit();    // another interrupt controller
8010388d:	e8 d8 f1 ff ff       	call   80102a6a <ioapicinit>
  consoleinit();   // console hardware
80103892:	e8 68 d2 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
80103897:	e8 43 35 00 00       	call   80106ddf <uartinit>
  pinit();         // process table
8010389c:	e8 c2 05 00 00       	call   80103e63 <pinit>
  tvinit();        // trap vectors
801038a1:	e8 ed 2e 00 00       	call   80106793 <tvinit>
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
801038cf:	e8 19 53 00 00       	call   80108bed <pci_init>
  arp_scan();
801038d4:	e8 50 60 00 00       	call   80109929 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038d9:	e8 e1 07 00 00       	call   801040bf <userinit>

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
801038e9:	e8 d8 46 00 00       	call   80107fc6 <switchkvm>
  seginit();
801038ee:	e8 53 41 00 00       	call   80107a46 <seginit>
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
80103915:	68 b9 ad 10 80       	push   $0x8010adb9
8010391a:	e8 d5 ca ff ff       	call   801003f4 <cprintf>
8010391f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103922:	e8 e2 2f 00 00       	call   80106909 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103927:	e8 9e 05 00 00       	call   80103eca <mycpu>
8010392c:	05 a0 00 00 00       	add    $0xa0,%eax
80103931:	83 ec 08             	sub    $0x8,%esp
80103934:	6a 01                	push   $0x1
80103936:	50                   	push   %eax
80103937:	e8 f3 fe ff ff       	call   8010382f <xchg>
8010393c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010393f:	e8 3c 0d 00 00       	call   80104680 <scheduler>

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
8010395a:	68 58 f5 10 80       	push   $0x8010f558
8010395f:	ff 75 f0             	push   -0x10(%ebp)
80103962:	e8 98 1a 00 00       	call   801053ff <memmove>
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
80103aeb:	68 cd ad 10 80       	push   $0x8010adcd
80103af0:	50                   	push   %eax
80103af1:	e8 b2 15 00 00       	call   801050a8 <initlock>
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
80103bb0:	e8 15 15 00 00       	call   801050ca <acquire>
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
80103bd7:	e8 53 0f 00 00       	call   80104b2f <wakeup>
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
80103bfa:	e8 30 0f 00 00       	call   80104b2f <wakeup>
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
80103c23:	e8 10 15 00 00       	call   80105138 <release>
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
80103c42:	e8 f1 14 00 00       	call   80105138 <release>
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
80103c5c:	e8 69 14 00 00       	call   801050ca <acquire>
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
80103c90:	e8 a3 14 00 00       	call   80105138 <release>
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
80103cae:	e8 7c 0e 00 00       	call   80104b2f <wakeup>
80103cb3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103cbc:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc2:	83 ec 08             	sub    $0x8,%esp
80103cc5:	50                   	push   %eax
80103cc6:	52                   	push   %edx
80103cc7:	e8 79 0d 00 00       	call   80104a45 <sleep>
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
80103d31:	e8 f9 0d 00 00       	call   80104b2f <wakeup>
80103d36:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d39:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3c:	83 ec 0c             	sub    $0xc,%esp
80103d3f:	50                   	push   %eax
80103d40:	e8 f3 13 00 00       	call   80105138 <release>
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
80103d5d:	e8 68 13 00 00       	call   801050ca <acquire>
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
80103d7a:	e8 b9 13 00 00       	call   80105138 <release>
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
80103d9d:	e8 a3 0c 00 00       	call   80104a45 <sleep>
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
80103e30:	e8 fa 0c 00 00       	call   80104b2f <wakeup>
80103e35:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	50                   	push   %eax
80103e3f:	e8 f4 12 00 00       	call   80105138 <release>
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

int max_tick[4] = {0, 32, 16, 8};  // Q0은 FIFO라서 0

void
pinit(void)
{
80103e63:	55                   	push   %ebp
80103e64:	89 e5                	mov    %esp,%ebp
80103e66:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103e69:	83 ec 08             	sub    $0x8,%esp
80103e6c:	68 d4 ad 10 80       	push   $0x8010add4
80103e71:	68 40 72 11 80       	push   $0x80117240
80103e76:	e8 2d 12 00 00       	call   801050a8 <initlock>
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
80103e99:	e8 4f 0d 00 00       	call   80104bed <initqueue>
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
80103ee1:	68 dc ad 10 80       	push   $0x8010addc
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
80103f36:	68 02 ae 10 80       	push   $0x8010ae02
80103f3b:	e8 69 c6 ff ff       	call   801005a9 <panic>
}
80103f40:	c9                   	leave  
80103f41:	c3                   	ret    

80103f42 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc* //수정
myproc(void) {
80103f42:	55                   	push   %ebp
80103f43:	89 e5                	mov    %esp,%ebp
80103f45:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  
  pushcli();
80103f48:	e8 e8 12 00 00       	call   80105235 <pushcli>
  c= mycpu();
80103f4d:	e8 78 ff ff ff       	call   80103eca <mycpu>
80103f52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p=c->proc;
80103f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f58:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f61:	e8 1c 13 00 00       	call   80105282 <popcli>
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
80103f79:	e8 4c 11 00 00       	call   801050ca <acquire>
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
80103fac:	e8 87 11 00 00       	call   80105138 <release>
80103fb1:	83 c4 10             	add    $0x10,%esp
  return 0;
80103fb4:	b8 00 00 00 00       	mov    $0x0,%eax
80103fb9:	e9 ff 00 00 00       	jmp    801040bd <allocproc+0x152>
      goto found;
80103fbe:	90                   	nop

found:
  memset(p, 0, sizeof(*p));  // ← 이거 꼭 필요함!
80103fbf:	83 ec 04             	sub    $0x4,%esp
80103fc2:	68 a0 00 00 00       	push   $0xa0
80103fc7:	6a 00                	push   $0x0
80103fc9:	ff 75 f4             	push   -0xc(%ebp)
80103fcc:	e8 6f 13 00 00       	call   80105340 <memset>
80103fd1:	83 c4 10             	add    $0x10,%esp
  p->state = EMBRYO;
80103fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd7:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103fde:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103fe3:	8d 50 01             	lea    0x1(%eax),%edx
80103fe6:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fef:	89 42 10             	mov    %eax,0x10(%edx)

  //추가
  p->priority = 3;  // Q3에서 시작
80103ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff5:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  memset(p->ticks, 0, sizeof(p->ticks));
80103ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fff:	83 e8 80             	sub    $0xffffff80,%eax
80104002:	83 ec 04             	sub    $0x4,%esp
80104005:	6a 10                	push   $0x10
80104007:	6a 00                	push   $0x0
80104009:	50                   	push   %eax
8010400a:	e8 31 13 00 00       	call   80105340 <memset>
8010400f:	83 c4 10             	add    $0x10,%esp
  memset(p->wait_ticks, 0, sizeof(p->wait_ticks)); //
80104012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104015:	05 90 00 00 00       	add    $0x90,%eax
8010401a:	83 ec 04             	sub    $0x4,%esp
8010401d:	6a 10                	push   $0x10
8010401f:	6a 00                	push   $0x0
80104021:	50                   	push   %eax
80104022:	e8 19 13 00 00       	call   80105340 <memset>
80104027:	83 c4 10             	add    $0x10,%esp

  
  release(&ptable.lock);
8010402a:	83 ec 0c             	sub    $0xc,%esp
8010402d:	68 40 72 11 80       	push   $0x80117240
80104032:	e8 01 11 00 00       	call   80105138 <release>
80104037:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010403a:	e8 45 ec ff ff       	call   80102c84 <kalloc>
8010403f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104042:	89 42 08             	mov    %eax,0x8(%edx)
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	8b 40 08             	mov    0x8(%eax),%eax
8010404b:	85 c0                	test   %eax,%eax
8010404d:	75 11                	jne    80104060 <allocproc+0xf5>
    p->state = UNUSED;
8010404f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104052:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104059:	b8 00 00 00 00       	mov    $0x0,%eax
8010405e:	eb 5d                	jmp    801040bd <allocproc+0x152>
  }
  sp = p->kstack + KSTACKSIZE;
80104060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104063:	8b 40 08             	mov    0x8(%eax),%eax
80104066:	05 00 10 00 00       	add    $0x1000,%eax
8010406b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010406e:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104075:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104078:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010407b:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010407f:	ba 4d 67 10 80       	mov    $0x8010674d,%edx
80104084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104087:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104089:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010408d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104090:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104093:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104099:	8b 40 1c             	mov    0x1c(%eax),%eax
8010409c:	83 ec 04             	sub    $0x4,%esp
8010409f:	6a 14                	push   $0x14
801040a1:	6a 00                	push   $0x0
801040a3:	50                   	push   %eax
801040a4:	e8 97 12 00 00       	call   80105340 <memset>
801040a9:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801040ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040af:	8b 40 1c             	mov    0x1c(%eax),%eax
801040b2:	ba ff 49 10 80       	mov    $0x801049ff,%edx
801040b7:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801040ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801040bd:	c9                   	leave  
801040be:	c3                   	ret    

801040bf <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801040bf:	55                   	push   %ebp
801040c0:	89 e5                	mov    %esp,%ebp
801040c2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801040c5:	e8 a1 fe ff ff       	call   80103f6b <allocproc>
801040ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	a3 a0 9e 11 80       	mov    %eax,0x80119ea0
  if((p->pgdir = setupkvm()) == 0){
801040d5:	e8 e8 3d 00 00       	call   80107ec2 <setupkvm>
801040da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040dd:	89 42 04             	mov    %eax,0x4(%edx)
801040e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e3:	8b 40 04             	mov    0x4(%eax),%eax
801040e6:	85 c0                	test   %eax,%eax
801040e8:	75 0d                	jne    801040f7 <userinit+0x38>
    panic("userinit: out of memory?");
801040ea:	83 ec 0c             	sub    $0xc,%esp
801040ed:	68 12 ae 10 80       	push   $0x8010ae12
801040f2:	e8 b2 c4 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801040f7:	ba 2c 00 00 00       	mov    $0x2c,%edx
801040fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ff:	8b 40 04             	mov    0x4(%eax),%eax
80104102:	83 ec 04             	sub    $0x4,%esp
80104105:	52                   	push   %edx
80104106:	68 2c f5 10 80       	push   $0x8010f52c
8010410b:	50                   	push   %eax
8010410c:	e8 6d 40 00 00       	call   8010817e <inituvm>
80104111:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104117:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010411d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104120:	8b 40 18             	mov    0x18(%eax),%eax
80104123:	83 ec 04             	sub    $0x4,%esp
80104126:	6a 4c                	push   $0x4c
80104128:	6a 00                	push   $0x0
8010412a:	50                   	push   %eax
8010412b:	e8 10 12 00 00       	call   80105340 <memset>
80104130:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104136:	8b 40 18             	mov    0x18(%eax),%eax
80104139:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010413f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104142:	8b 40 18             	mov    0x18(%eax),%eax
80104145:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010414b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414e:	8b 50 18             	mov    0x18(%eax),%edx
80104151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104154:	8b 40 18             	mov    0x18(%eax),%eax
80104157:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010415b:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010415f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104162:	8b 50 18             	mov    0x18(%eax),%edx
80104165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104168:	8b 40 18             	mov    0x18(%eax),%eax
8010416b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010416f:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104176:	8b 40 18             	mov    0x18(%eax),%eax
80104179:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104183:	8b 40 18             	mov    0x18(%eax),%eax
80104186:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010418d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104190:	8b 40 18             	mov    0x18(%eax),%eax
80104193:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010419a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419d:	83 c0 6c             	add    $0x6c,%eax
801041a0:	83 ec 04             	sub    $0x4,%esp
801041a3:	6a 10                	push   $0x10
801041a5:	68 2b ae 10 80       	push   $0x8010ae2b
801041aa:	50                   	push   %eax
801041ab:	e8 93 13 00 00       	call   80105543 <safestrcpy>
801041b0:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801041b3:	83 ec 0c             	sub    $0xc,%esp
801041b6:	68 34 ae 10 80       	push   $0x8010ae34
801041bb:	e8 5d e3 ff ff       	call   8010251d <namei>
801041c0:	83 c4 10             	add    $0x10,%esp
801041c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041c6:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801041c9:	83 ec 0c             	sub    $0xc,%esp
801041cc:	68 40 72 11 80       	push   $0x80117240
801041d1:	e8 f4 0e 00 00       	call   801050ca <acquire>
801041d6:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801041d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041dc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  enqueue(&mlfq[3], p);  // ← 필수!
801041e3:	83 ec 08             	sub    $0x8,%esp
801041e6:	ff 75 f4             	push   -0xc(%ebp)
801041e9:	68 98 9d 11 80       	push   $0x80119d98
801041ee:	e8 39 0a 00 00       	call   80104c2c <enqueue>
801041f3:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801041f6:	83 ec 0c             	sub    $0xc,%esp
801041f9:	68 40 72 11 80       	push   $0x80117240
801041fe:	e8 35 0f 00 00       	call   80105138 <release>
80104203:	83 c4 10             	add    $0x10,%esp
}
80104206:	90                   	nop
80104207:	c9                   	leave  
80104208:	c3                   	ret    

80104209 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104209:	55                   	push   %ebp
8010420a:	89 e5                	mov    %esp,%ebp
8010420c:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010420f:	e8 2e fd ff ff       	call   80103f42 <myproc>
80104214:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104217:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010421a:	8b 00                	mov    (%eax),%eax
8010421c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010421f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104223:	7e 2e                	jle    80104253 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104225:	8b 55 08             	mov    0x8(%ebp),%edx
80104228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422b:	01 c2                	add    %eax,%edx
8010422d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104230:	8b 40 04             	mov    0x4(%eax),%eax
80104233:	83 ec 04             	sub    $0x4,%esp
80104236:	52                   	push   %edx
80104237:	ff 75 f4             	push   -0xc(%ebp)
8010423a:	50                   	push   %eax
8010423b:	e8 7b 40 00 00       	call   801082bb <allocuvm>
80104240:	83 c4 10             	add    $0x10,%esp
80104243:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104246:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010424a:	75 3b                	jne    80104287 <growproc+0x7e>
      return -1;
8010424c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104251:	eb 4f                	jmp    801042a2 <growproc+0x99>
  } else if(n < 0){
80104253:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104257:	79 2e                	jns    80104287 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104259:	8b 55 08             	mov    0x8(%ebp),%edx
8010425c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425f:	01 c2                	add    %eax,%edx
80104261:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104264:	8b 40 04             	mov    0x4(%eax),%eax
80104267:	83 ec 04             	sub    $0x4,%esp
8010426a:	52                   	push   %edx
8010426b:	ff 75 f4             	push   -0xc(%ebp)
8010426e:	50                   	push   %eax
8010426f:	e8 4c 41 00 00       	call   801083c0 <deallocuvm>
80104274:	83 c4 10             	add    $0x10,%esp
80104277:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010427a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010427e:	75 07                	jne    80104287 <growproc+0x7e>
      return -1;
80104280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104285:	eb 1b                	jmp    801042a2 <growproc+0x99>
  }
  curproc->sz = sz;
80104287:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010428a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010428d:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010428f:	83 ec 0c             	sub    $0xc,%esp
80104292:	ff 75 f0             	push   -0x10(%ebp)
80104295:	e8 45 3d 00 00       	call   80107fdf <switchuvm>
8010429a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010429d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042a2:	c9                   	leave  
801042a3:	c3                   	ret    

801042a4 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801042a4:	55                   	push   %ebp
801042a5:	89 e5                	mov    %esp,%ebp
801042a7:	57                   	push   %edi
801042a8:	56                   	push   %esi
801042a9:	53                   	push   %ebx
801042aa:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801042ad:	e8 90 fc ff ff       	call   80103f42 <myproc>
801042b2:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801042b5:	e8 b1 fc ff ff       	call   80103f6b <allocproc>
801042ba:	89 45 dc             	mov    %eax,-0x24(%ebp)
801042bd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801042c1:	75 0a                	jne    801042cd <fork+0x29>
    return -1;
801042c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042c8:	e9 65 01 00 00       	jmp    80104432 <fork+0x18e>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801042cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042d0:	8b 10                	mov    (%eax),%edx
801042d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042d5:	8b 40 04             	mov    0x4(%eax),%eax
801042d8:	83 ec 08             	sub    $0x8,%esp
801042db:	52                   	push   %edx
801042dc:	50                   	push   %eax
801042dd:	e8 7c 42 00 00       	call   8010855e <copyuvm>
801042e2:	83 c4 10             	add    $0x10,%esp
801042e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801042e8:	89 42 04             	mov    %eax,0x4(%edx)
801042eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042ee:	8b 40 04             	mov    0x4(%eax),%eax
801042f1:	85 c0                	test   %eax,%eax
801042f3:	75 30                	jne    80104325 <fork+0x81>
    kfree(np->kstack);
801042f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042f8:	8b 40 08             	mov    0x8(%eax),%eax
801042fb:	83 ec 0c             	sub    $0xc,%esp
801042fe:	50                   	push   %eax
801042ff:	e8 e6 e8 ff ff       	call   80102bea <kfree>
80104304:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104307:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010430a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104311:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104314:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010431b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104320:	e9 0d 01 00 00       	jmp    80104432 <fork+0x18e>
  }
  np->sz = curproc->sz;
80104325:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104328:	8b 10                	mov    (%eax),%edx
8010432a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010432d:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010432f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104332:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104335:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104338:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010433b:	8b 48 18             	mov    0x18(%eax),%ecx
8010433e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104341:	8b 40 18             	mov    0x18(%eax),%eax
80104344:	89 c2                	mov    %eax,%edx
80104346:	89 cb                	mov    %ecx,%ebx
80104348:	b8 13 00 00 00       	mov    $0x13,%eax
8010434d:	89 d7                	mov    %edx,%edi
8010434f:	89 de                	mov    %ebx,%esi
80104351:	89 c1                	mov    %eax,%ecx
80104353:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104355:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104358:	8b 40 18             	mov    0x18(%eax),%eax
8010435b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104362:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104369:	eb 3b                	jmp    801043a6 <fork+0x102>
    if(curproc->ofile[i])
8010436b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010436e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104371:	83 c2 08             	add    $0x8,%edx
80104374:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104378:	85 c0                	test   %eax,%eax
8010437a:	74 26                	je     801043a2 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010437c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010437f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104382:	83 c2 08             	add    $0x8,%edx
80104385:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104389:	83 ec 0c             	sub    $0xc,%esp
8010438c:	50                   	push   %eax
8010438d:	e8 b8 cc ff ff       	call   8010104a <filedup>
80104392:	83 c4 10             	add    $0x10,%esp
80104395:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104398:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010439b:	83 c1 08             	add    $0x8,%ecx
8010439e:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801043a2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801043a6:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801043aa:	7e bf                	jle    8010436b <fork+0xc7>
  np->cwd = idup(curproc->cwd);
801043ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043af:	8b 40 68             	mov    0x68(%eax),%eax
801043b2:	83 ec 0c             	sub    $0xc,%esp
801043b5:	50                   	push   %eax
801043b6:	e8 f5 d5 ff ff       	call   801019b0 <idup>
801043bb:	83 c4 10             	add    $0x10,%esp
801043be:	8b 55 dc             	mov    -0x24(%ebp),%edx
801043c1:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801043c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043c7:	8d 50 6c             	lea    0x6c(%eax),%edx
801043ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043cd:	83 c0 6c             	add    $0x6c,%eax
801043d0:	83 ec 04             	sub    $0x4,%esp
801043d3:	6a 10                	push   $0x10
801043d5:	52                   	push   %edx
801043d6:	50                   	push   %eax
801043d7:	e8 67 11 00 00       	call   80105543 <safestrcpy>
801043dc:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801043df:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043e2:	8b 40 10             	mov    0x10(%eax),%eax
801043e5:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801043e8:	83 ec 0c             	sub    $0xc,%esp
801043eb:	68 40 72 11 80       	push   $0x80117240
801043f0:	e8 d5 0c 00 00       	call   801050ca <acquire>
801043f5:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801043f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043fb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  np->priority = 3;
80104402:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104405:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  enqueue(&mlfq[3], np);  // ← 필수!
8010440c:	83 ec 08             	sub    $0x8,%esp
8010440f:	ff 75 dc             	push   -0x24(%ebp)
80104412:	68 98 9d 11 80       	push   $0x80119d98
80104417:	e8 10 08 00 00       	call   80104c2c <enqueue>
8010441c:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010441f:	83 ec 0c             	sub    $0xc,%esp
80104422:	68 40 72 11 80       	push   $0x80117240
80104427:	e8 0c 0d 00 00       	call   80105138 <release>
8010442c:	83 c4 10             	add    $0x10,%esp

  return pid;
8010442f:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104432:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104435:	5b                   	pop    %ebx
80104436:	5e                   	pop    %esi
80104437:	5f                   	pop    %edi
80104438:	5d                   	pop    %ebp
80104439:	c3                   	ret    

8010443a <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010443a:	55                   	push   %ebp
8010443b:	89 e5                	mov    %esp,%ebp
8010443d:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104440:	e8 fd fa ff ff       	call   80103f42 <myproc>
80104445:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104448:	a1 a0 9e 11 80       	mov    0x80119ea0,%eax
8010444d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104450:	75 0d                	jne    8010445f <exit+0x25>
    panic("init exiting");
80104452:	83 ec 0c             	sub    $0xc,%esp
80104455:	68 36 ae 10 80       	push   $0x8010ae36
8010445a:	e8 4a c1 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010445f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104466:	eb 3f                	jmp    801044a7 <exit+0x6d>
    if(curproc->ofile[fd]){
80104468:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010446b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010446e:	83 c2 08             	add    $0x8,%edx
80104471:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104475:	85 c0                	test   %eax,%eax
80104477:	74 2a                	je     801044a3 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80104479:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010447c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010447f:	83 c2 08             	add    $0x8,%edx
80104482:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104486:	83 ec 0c             	sub    $0xc,%esp
80104489:	50                   	push   %eax
8010448a:	e8 0c cc ff ff       	call   8010109b <fileclose>
8010448f:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104492:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104495:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104498:	83 c2 08             	add    $0x8,%edx
8010449b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801044a2:	00 
  for(fd = 0; fd < NOFILE; fd++){
801044a3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801044a7:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801044ab:	7e bb                	jle    80104468 <exit+0x2e>
    }
  }

  begin_op();
801044ad:	e8 6e f0 ff ff       	call   80103520 <begin_op>
  iput(curproc->cwd);
801044b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044b5:	8b 40 68             	mov    0x68(%eax),%eax
801044b8:	83 ec 0c             	sub    $0xc,%esp
801044bb:	50                   	push   %eax
801044bc:	e8 8a d6 ff ff       	call   80101b4b <iput>
801044c1:	83 c4 10             	add    $0x10,%esp
  end_op();
801044c4:	e8 e3 f0 ff ff       	call   801035ac <end_op>
  curproc->cwd = 0;
801044c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044cc:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801044d3:	83 ec 0c             	sub    $0xc,%esp
801044d6:	68 40 72 11 80       	push   $0x80117240
801044db:	e8 ea 0b 00 00       	call   801050ca <acquire>
801044e0:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801044e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044e6:	8b 40 14             	mov    0x14(%eax),%eax
801044e9:	83 ec 0c             	sub    $0xc,%esp
801044ec:	50                   	push   %eax
801044ed:	e8 fa 05 00 00       	call   80104aec <wakeup1>
801044f2:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044f5:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801044fc:	eb 3a                	jmp    80104538 <exit+0xfe>
    if(p->parent == curproc){
801044fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104501:	8b 40 14             	mov    0x14(%eax),%eax
80104504:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104507:	75 28                	jne    80104531 <exit+0xf7>
      p->parent = initproc;
80104509:	8b 15 a0 9e 11 80    	mov    0x80119ea0,%edx
8010450f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104512:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	8b 40 0c             	mov    0xc(%eax),%eax
8010451b:	83 f8 05             	cmp    $0x5,%eax
8010451e:	75 11                	jne    80104531 <exit+0xf7>
        wakeup1(initproc);
80104520:	a1 a0 9e 11 80       	mov    0x80119ea0,%eax
80104525:	83 ec 0c             	sub    $0xc,%esp
80104528:	50                   	push   %eax
80104529:	e8 be 05 00 00       	call   80104aec <wakeup1>
8010452e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104531:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104538:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
8010453f:	72 bd                	jb     801044fe <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104541:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104544:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010454b:	e8 b6 03 00 00       	call   80104906 <sched>
  panic("zombie exit");
80104550:	83 ec 0c             	sub    $0xc,%esp
80104553:	68 43 ae 10 80       	push   $0x8010ae43
80104558:	e8 4c c0 ff ff       	call   801005a9 <panic>

8010455d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010455d:	55                   	push   %ebp
8010455e:	89 e5                	mov    %esp,%ebp
80104560:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104563:	e8 da f9 ff ff       	call   80103f42 <myproc>
80104568:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010456b:	83 ec 0c             	sub    $0xc,%esp
8010456e:	68 40 72 11 80       	push   $0x80117240
80104573:	e8 52 0b 00 00       	call   801050ca <acquire>
80104578:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010457b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104582:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104589:	e9 a4 00 00 00       	jmp    80104632 <wait+0xd5>
      if(p->parent != curproc)
8010458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104591:	8b 40 14             	mov    0x14(%eax),%eax
80104594:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104597:	0f 85 8d 00 00 00    	jne    8010462a <wait+0xcd>
        continue;
      havekids = 1;
8010459d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801045a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a7:	8b 40 0c             	mov    0xc(%eax),%eax
801045aa:	83 f8 05             	cmp    $0x5,%eax
801045ad:	75 7c                	jne    8010462b <wait+0xce>
        // Found one.
        pid = p->pid;
801045af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b2:	8b 40 10             	mov    0x10(%eax),%eax
801045b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801045b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bb:	8b 40 08             	mov    0x8(%eax),%eax
801045be:	83 ec 0c             	sub    $0xc,%esp
801045c1:	50                   	push   %eax
801045c2:	e8 23 e6 ff ff       	call   80102bea <kfree>
801045c7:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801045ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801045d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d7:	8b 40 04             	mov    0x4(%eax),%eax
801045da:	83 ec 0c             	sub    $0xc,%esp
801045dd:	50                   	push   %eax
801045de:	e8 a1 3e 00 00       	call   80108484 <freevm>
801045e3:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801045e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e9:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801045f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801045fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fd:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104604:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010460b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104615:	83 ec 0c             	sub    $0xc,%esp
80104618:	68 40 72 11 80       	push   $0x80117240
8010461d:	e8 16 0b 00 00       	call   80105138 <release>
80104622:	83 c4 10             	add    $0x10,%esp
        return pid;
80104625:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104628:	eb 54                	jmp    8010467e <wait+0x121>
        continue;
8010462a:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010462b:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104632:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80104639:	0f 82 4f ff ff ff    	jb     8010458e <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010463f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104643:	74 0a                	je     8010464f <wait+0xf2>
80104645:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104648:	8b 40 24             	mov    0x24(%eax),%eax
8010464b:	85 c0                	test   %eax,%eax
8010464d:	74 17                	je     80104666 <wait+0x109>
      release(&ptable.lock);
8010464f:	83 ec 0c             	sub    $0xc,%esp
80104652:	68 40 72 11 80       	push   $0x80117240
80104657:	e8 dc 0a 00 00       	call   80105138 <release>
8010465c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010465f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104664:	eb 18                	jmp    8010467e <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104666:	83 ec 08             	sub    $0x8,%esp
80104669:	68 40 72 11 80       	push   $0x80117240
8010466e:	ff 75 ec             	push   -0x14(%ebp)
80104671:	e8 cf 03 00 00       	call   80104a45 <sleep>
80104676:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104679:	e9 fd fe ff ff       	jmp    8010457b <wait+0x1e>
  }
}
8010467e:	c9                   	leave  
8010467f:	c3                   	ret    

80104680 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104680:	55                   	push   %ebp
80104681:	89 e5                	mov    %esp,%ebp
80104683:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104686:	e8 3f f8 ff ff       	call   80103eca <mycpu>
8010468b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
8010468e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104691:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104698:	00 00 00 

  for (;;) {
    sti();
8010469b:	e8 bc f7 ff ff       	call   80103e5c <sti>
    acquire(&ptable.lock);
801046a0:	83 ec 0c             	sub    $0xc,%esp
801046a3:	68 40 72 11 80       	push   $0x80117240
801046a8:	e8 1d 0a 00 00       	call   801050ca <acquire>
801046ad:	83 c4 10             	add    $0x10,%esp

    int scheduled = 0;
801046b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    // MLFQ 
    if (c->sched_policy == 1) {
801046b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801046ba:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801046c0:	83 f8 01             	cmp    $0x1,%eax
801046c3:	0f 85 ac 01 00 00    	jne    80104875 <scheduler+0x1f5>
      for(int level =3; level >= 0; level--)  {
801046c9:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
801046d0:	e9 97 01 00 00       	jmp    8010486c <scheduler+0x1ec>
        while (!isempty(&mlfq[level])) {
          p = dequeue(&mlfq[level]);
801046d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046d8:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
801046de:	05 80 9a 11 80       	add    $0x80119a80,%eax
801046e3:	83 ec 0c             	sub    $0xc,%esp
801046e6:	50                   	push   %eax
801046e7:	e8 ad 05 00 00       	call   80104c99 <dequeue>
801046ec:	83 c4 10             	add    $0x10,%esp
801046ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
          if ( !p || p->state != RUNNABLE)
801046f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046f6:	0f 84 44 01 00 00    	je     80104840 <scheduler+0x1c0>
801046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104702:	83 f8 03             	cmp    $0x3,%eax
80104705:	74 05                	je     8010470c <scheduler+0x8c>
            continue;
80104707:	e9 34 01 00 00       	jmp    80104840 <scheduler+0x1c0>

          scheduled = 1;
8010470c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

          c->proc = p;
80104713:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104716:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104719:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
8010471f:	83 ec 0c             	sub    $0xc,%esp
80104722:	ff 75 f4             	push   -0xc(%ebp)
80104725:	e8 b5 38 00 00       	call   80107fdf <switchuvm>
8010472a:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
8010472d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104730:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

          swtch(&c->scheduler, p->context);
80104737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010473d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104740:	83 c2 04             	add    $0x4,%edx
80104743:	83 ec 08             	sub    $0x8,%esp
80104746:	50                   	push   %eax
80104747:	52                   	push   %edx
80104748:	e8 68 0e 00 00       	call   801055b5 <swtch>
8010474d:	83 c4 10             	add    $0x10,%esp
          switchkvm();
80104750:	e8 71 38 00 00       	call   80107fc6 <switchkvm>

          c->proc = 0;
80104755:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104758:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010475f:	00 00 00 

          int cur_lvl = p->priority;
80104762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104765:	8b 40 7c             	mov    0x7c(%eax),%eax
80104768:	89 45 e4             	mov    %eax,-0x1c(%ebp)

          // ✳️ demote 기준은 trap.c에서 tick 누적값을 기반으로
          // trap.c에서 tick 누적하고 여기서 demote 판단
          if (p->state == RUNNABLE && p->ticks[cur_lvl] >= max_tick[cur_lvl]) {
8010476b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476e:	8b 40 0c             	mov    0xc(%eax),%eax
80104771:	83 f8 03             	cmp    $0x3,%eax
80104774:	75 7d                	jne    801047f3 <scheduler+0x173>
80104776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104779:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010477c:	83 c2 20             	add    $0x20,%edx
8010477f:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104785:	8b 04 85 04 f0 10 80 	mov    -0x7fef0ffc(,%eax,4),%eax
8010478c:	39 c2                	cmp    %eax,%edx
8010478e:	7c 63                	jl     801047f3 <scheduler+0x173>
            if (cur_lvl > 0){
80104790:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104794:	7e 3d                	jle    801047d3 <scheduler+0x153>
              p->priority--;
80104796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104799:	8b 40 7c             	mov    0x7c(%eax),%eax
8010479c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010479f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a2:	89 50 7c             	mov    %edx,0x7c(%eax)
              cprintf("[demote] pid %d: Q%d → Q%d (tick=%d)\n",
801047a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801047ab:	83 c2 20             	add    $0x20,%edx
801047ae:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
801047b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b4:	8b 50 7c             	mov    0x7c(%eax),%edx
801047b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ba:	8b 40 10             	mov    0x10(%eax),%eax
801047bd:	83 ec 0c             	sub    $0xc,%esp
801047c0:	51                   	push   %ecx
801047c1:	52                   	push   %edx
801047c2:	ff 75 e4             	push   -0x1c(%ebp)
801047c5:	50                   	push   %eax
801047c6:	68 50 ae 10 80       	push   $0x8010ae50
801047cb:	e8 24 bc ff ff       	call   801003f4 <cprintf>
801047d0:	83 c4 20             	add    $0x20,%esp
                      p->pid, cur_lvl, p->priority, p->ticks[cur_lvl]);
            }
            p->ticks[cur_lvl] = 0;
801047d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801047d9:	83 c2 20             	add    $0x20,%edx
801047dc:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
            p->wait_ticks[cur_lvl] = 0;
801047e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801047e9:	83 c2 24             	add    $0x24,%edx
801047ec:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
          }
          //  enqueue는 priority에 따라 다시 큐로
          enqueue(&mlfq[p->priority], p);  // 아래 큐에 넣기
801047f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f6:	8b 40 7c             	mov    0x7c(%eax),%eax
801047f9:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
801047ff:	05 80 9a 11 80       	add    $0x80119a80,%eax
80104804:	83 ec 08             	sub    $0x8,%esp
80104807:	ff 75 f4             	push   -0xc(%ebp)
8010480a:	50                   	push   %eax
8010480b:	e8 1c 04 00 00       	call   80104c2c <enqueue>
80104810:	83 c4 10             	add    $0x10,%esp
          cprintf("[requeue] pid %d: stay Q%d (tick=%d)\n",
                  p->pid, p->priority, p->ticks[p->priority]);
80104813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104816:	8b 50 7c             	mov    0x7c(%eax),%edx
          cprintf("[requeue] pid %d: stay Q%d (tick=%d)\n",
80104819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481c:	83 c2 20             	add    $0x20,%edx
8010481f:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
80104822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104825:	8b 50 7c             	mov    0x7c(%eax),%edx
80104828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482b:	8b 40 10             	mov    0x10(%eax),%eax
8010482e:	51                   	push   %ecx
8010482f:	52                   	push   %edx
80104830:	50                   	push   %eax
80104831:	68 78 ae 10 80       	push   $0x8010ae78
80104836:	e8 b9 bb ff ff       	call   801003f4 <cprintf>
8010483b:	83 c4 10             	add    $0x10,%esp
          break;
8010483e:	eb 22                	jmp    80104862 <scheduler+0x1e2>
        while (!isempty(&mlfq[level])) {
80104840:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104843:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
80104849:	05 80 9a 11 80       	add    $0x80119a80,%eax
8010484e:	83 ec 0c             	sub    $0xc,%esp
80104851:	50                   	push   %eax
80104852:	e8 b6 03 00 00       	call   80104c0d <isempty>
80104857:	83 c4 10             	add    $0x10,%esp
8010485a:	85 c0                	test   %eax,%eax
8010485c:	0f 84 73 fe ff ff    	je     801046d5 <scheduler+0x55>
        }
        if (scheduled) break;
80104862:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104866:	75 0c                	jne    80104874 <scheduler+0x1f4>
      for(int level =3; level >= 0; level--)  {
80104868:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
8010486c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104870:	79 ce                	jns    80104840 <scheduler+0x1c0>
80104872:	eb 01                	jmp    80104875 <scheduler+0x1f5>
        if (scheduled) break;
80104874:	90                   	nop
      }
    }
          
    //RR
    if (!scheduled) {
80104875:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104879:	75 76                	jne    801048f1 <scheduler+0x271>
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010487b:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104882:	eb 64                	jmp    801048e8 <scheduler+0x268>
        if (p->state != RUNNABLE)
80104884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104887:	8b 40 0c             	mov    0xc(%eax),%eax
8010488a:	83 f8 03             	cmp    $0x3,%eax
8010488d:	75 51                	jne    801048e0 <scheduler+0x260>
          continue;
        c->proc = p;
8010488f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104892:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104895:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
8010489b:	83 ec 0c             	sub    $0xc,%esp
8010489e:	ff 75 f4             	push   -0xc(%ebp)
801048a1:	e8 39 37 00 00       	call   80107fdf <switchuvm>
801048a6:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ac:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&c->scheduler, p->context);
801048b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b6:	8b 40 1c             	mov    0x1c(%eax),%eax
801048b9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801048bc:	83 c2 04             	add    $0x4,%edx
801048bf:	83 ec 08             	sub    $0x8,%esp
801048c2:	50                   	push   %eax
801048c3:	52                   	push   %edx
801048c4:	e8 ec 0c 00 00       	call   801055b5 <swtch>
801048c9:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801048cc:	e8 f5 36 00 00       	call   80107fc6 <switchkvm>

        c->proc = 0;
801048d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048d4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801048db:	00 00 00 
801048de:	eb 01                	jmp    801048e1 <scheduler+0x261>
          continue;
801048e0:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801048e1:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801048e8:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
801048ef:	72 93                	jb     80104884 <scheduler+0x204>
      }
    }
    release(&ptable.lock);
801048f1:	83 ec 0c             	sub    $0xc,%esp
801048f4:	68 40 72 11 80       	push   $0x80117240
801048f9:	e8 3a 08 00 00       	call   80105138 <release>
801048fe:	83 c4 10             	add    $0x10,%esp
  for (;;) {
80104901:	e9 95 fd ff ff       	jmp    8010469b <scheduler+0x1b>

80104906 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104906:	55                   	push   %ebp
80104907:	89 e5                	mov    %esp,%ebp
80104909:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010490c:	e8 31 f6 ff ff       	call   80103f42 <myproc>
80104911:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104914:	83 ec 0c             	sub    $0xc,%esp
80104917:	68 40 72 11 80       	push   $0x80117240
8010491c:	e8 e4 08 00 00       	call   80105205 <holding>
80104921:	83 c4 10             	add    $0x10,%esp
80104924:	85 c0                	test   %eax,%eax
80104926:	75 0d                	jne    80104935 <sched+0x2f>
    panic("sched ptable.lock");
80104928:	83 ec 0c             	sub    $0xc,%esp
8010492b:	68 9e ae 10 80       	push   $0x8010ae9e
80104930:	e8 74 bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104935:	e8 90 f5 ff ff       	call   80103eca <mycpu>
8010493a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104940:	83 f8 01             	cmp    $0x1,%eax
80104943:	74 0d                	je     80104952 <sched+0x4c>
    panic("sched locks");
80104945:	83 ec 0c             	sub    $0xc,%esp
80104948:	68 b0 ae 10 80       	push   $0x8010aeb0
8010494d:	e8 57 bc ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	8b 40 0c             	mov    0xc(%eax),%eax
80104958:	83 f8 04             	cmp    $0x4,%eax
8010495b:	75 0d                	jne    8010496a <sched+0x64>
    panic("sched running");
8010495d:	83 ec 0c             	sub    $0xc,%esp
80104960:	68 bc ae 10 80       	push   $0x8010aebc
80104965:	e8 3f bc ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
8010496a:	e8 dd f4 ff ff       	call   80103e4c <readeflags>
8010496f:	25 00 02 00 00       	and    $0x200,%eax
80104974:	85 c0                	test   %eax,%eax
80104976:	74 0d                	je     80104985 <sched+0x7f>
    panic("sched interruptible");
80104978:	83 ec 0c             	sub    $0xc,%esp
8010497b:	68 ca ae 10 80       	push   $0x8010aeca
80104980:	e8 24 bc ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104985:	e8 40 f5 ff ff       	call   80103eca <mycpu>
8010498a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104990:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104993:	e8 32 f5 ff ff       	call   80103eca <mycpu>
80104998:	8b 40 04             	mov    0x4(%eax),%eax
8010499b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010499e:	83 c2 1c             	add    $0x1c,%edx
801049a1:	83 ec 08             	sub    $0x8,%esp
801049a4:	50                   	push   %eax
801049a5:	52                   	push   %edx
801049a6:	e8 0a 0c 00 00       	call   801055b5 <swtch>
801049ab:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801049ae:	e8 17 f5 ff ff       	call   80103eca <mycpu>
801049b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049b6:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801049bc:	90                   	nop
801049bd:	c9                   	leave  
801049be:	c3                   	ret    

801049bf <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{ 
801049bf:	55                   	push   %ebp
801049c0:	89 e5                	mov    %esp,%ebp
801049c2:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801049c5:	e8 78 f5 ff ff       	call   80103f42 <myproc>
801049ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&ptable.lock);  
801049cd:	83 ec 0c             	sub    $0xc,%esp
801049d0:	68 40 72 11 80       	push   $0x80117240
801049d5:	e8 f0 06 00 00       	call   801050ca <acquire>
801049da:	83 c4 10             	add    $0x10,%esp

  curproc->state = RUNNABLE;
801049dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();  // enqueue는 scheduler가 책임진다!
801049e7:	e8 1a ff ff ff       	call   80104906 <sched>

  release(&ptable.lock);
801049ec:	83 ec 0c             	sub    $0xc,%esp
801049ef:	68 40 72 11 80       	push   $0x80117240
801049f4:	e8 3f 07 00 00       	call   80105138 <release>
801049f9:	83 c4 10             	add    $0x10,%esp
}
801049fc:	90                   	nop
801049fd:	c9                   	leave  
801049fe:	c3                   	ret    

801049ff <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801049ff:	55                   	push   %ebp
80104a00:	89 e5                	mov    %esp,%ebp
80104a02:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104a05:	83 ec 0c             	sub    $0xc,%esp
80104a08:	68 40 72 11 80       	push   $0x80117240
80104a0d:	e8 26 07 00 00       	call   80105138 <release>
80104a12:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104a15:	a1 14 f0 10 80       	mov    0x8010f014,%eax
80104a1a:	85 c0                	test   %eax,%eax
80104a1c:	74 24                	je     80104a42 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104a1e:	c7 05 14 f0 10 80 00 	movl   $0x0,0x8010f014
80104a25:	00 00 00 
    iinit(ROOTDEV);
80104a28:	83 ec 0c             	sub    $0xc,%esp
80104a2b:	6a 01                	push   $0x1
80104a2d:	e8 46 cc ff ff       	call   80101678 <iinit>
80104a32:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104a35:	83 ec 0c             	sub    $0xc,%esp
80104a38:	6a 01                	push   $0x1
80104a3a:	e8 c2 e8 ff ff       	call   80103301 <initlog>
80104a3f:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104a42:	90                   	nop
80104a43:	c9                   	leave  
80104a44:	c3                   	ret    

80104a45 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104a45:	55                   	push   %ebp
80104a46:	89 e5                	mov    %esp,%ebp
80104a48:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104a4b:	e8 f2 f4 ff ff       	call   80103f42 <myproc>
80104a50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104a53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a57:	75 0d                	jne    80104a66 <sleep+0x21>
    panic("sleep");
80104a59:	83 ec 0c             	sub    $0xc,%esp
80104a5c:	68 de ae 10 80       	push   $0x8010aede
80104a61:	e8 43 bb ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104a6a:	75 0d                	jne    80104a79 <sleep+0x34>
    panic("sleep without lk");
80104a6c:	83 ec 0c             	sub    $0xc,%esp
80104a6f:	68 e4 ae 10 80       	push   $0x8010aee4
80104a74:	e8 30 bb ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104a79:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104a80:	74 1e                	je     80104aa0 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104a82:	83 ec 0c             	sub    $0xc,%esp
80104a85:	68 40 72 11 80       	push   $0x80117240
80104a8a:	e8 3b 06 00 00       	call   801050ca <acquire>
80104a8f:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104a92:	83 ec 0c             	sub    $0xc,%esp
80104a95:	ff 75 0c             	push   0xc(%ebp)
80104a98:	e8 9b 06 00 00       	call   80105138 <release>
80104a9d:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa3:	8b 55 08             	mov    0x8(%ebp),%edx
80104aa6:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aac:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ab3:	e8 4e fe ff ff       	call   80104906 <sched>

  // Tidy up.
  p->chan = 0;
80104ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abb:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ac2:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104ac9:	74 1e                	je     80104ae9 <sleep+0xa4>
    release(&ptable.lock);
80104acb:	83 ec 0c             	sub    $0xc,%esp
80104ace:	68 40 72 11 80       	push   $0x80117240
80104ad3:	e8 60 06 00 00       	call   80105138 <release>
80104ad8:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104adb:	83 ec 0c             	sub    $0xc,%esp
80104ade:	ff 75 0c             	push   0xc(%ebp)
80104ae1:	e8 e4 05 00 00       	call   801050ca <acquire>
80104ae6:	83 c4 10             	add    $0x10,%esp
  }
}
80104ae9:	90                   	nop
80104aea:	c9                   	leave  
80104aeb:	c3                   	ret    

80104aec <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104aec:	55                   	push   %ebp
80104aed:	89 e5                	mov    %esp,%ebp
80104aef:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104af2:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
80104af9:	eb 27                	jmp    80104b22 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104afb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104afe:	8b 40 0c             	mov    0xc(%eax),%eax
80104b01:	83 f8 02             	cmp    $0x2,%eax
80104b04:	75 15                	jne    80104b1b <wakeup1+0x2f>
80104b06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b09:	8b 40 20             	mov    0x20(%eax),%eax
80104b0c:	39 45 08             	cmp    %eax,0x8(%ebp)
80104b0f:	75 0a                	jne    80104b1b <wakeup1+0x2f>
      p->state = RUNNABLE;
80104b11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b14:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b1b:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
80104b22:	81 7d fc 74 9a 11 80 	cmpl   $0x80119a74,-0x4(%ebp)
80104b29:	72 d0                	jb     80104afb <wakeup1+0xf>
}
80104b2b:	90                   	nop
80104b2c:	90                   	nop
80104b2d:	c9                   	leave  
80104b2e:	c3                   	ret    

80104b2f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104b2f:	55                   	push   %ebp
80104b30:	89 e5                	mov    %esp,%ebp
80104b32:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104b35:	83 ec 0c             	sub    $0xc,%esp
80104b38:	68 40 72 11 80       	push   $0x80117240
80104b3d:	e8 88 05 00 00       	call   801050ca <acquire>
80104b42:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104b45:	83 ec 0c             	sub    $0xc,%esp
80104b48:	ff 75 08             	push   0x8(%ebp)
80104b4b:	e8 9c ff ff ff       	call   80104aec <wakeup1>
80104b50:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104b53:	83 ec 0c             	sub    $0xc,%esp
80104b56:	68 40 72 11 80       	push   $0x80117240
80104b5b:	e8 d8 05 00 00       	call   80105138 <release>
80104b60:	83 c4 10             	add    $0x10,%esp
}
80104b63:	90                   	nop
80104b64:	c9                   	leave  
80104b65:	c3                   	ret    

80104b66 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104b66:	55                   	push   %ebp
80104b67:	89 e5                	mov    %esp,%ebp
80104b69:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104b6c:	83 ec 0c             	sub    $0xc,%esp
80104b6f:	68 40 72 11 80       	push   $0x80117240
80104b74:	e8 51 05 00 00       	call   801050ca <acquire>
80104b79:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b7c:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104b83:	eb 48                	jmp    80104bcd <kill+0x67>
    if(p->pid == pid){
80104b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b88:	8b 40 10             	mov    0x10(%eax),%eax
80104b8b:	39 45 08             	cmp    %eax,0x8(%ebp)
80104b8e:	75 36                	jne    80104bc6 <kill+0x60>
      p->killed = 1;
80104b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b93:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9d:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba0:	83 f8 02             	cmp    $0x2,%eax
80104ba3:	75 0a                	jne    80104baf <kill+0x49>
        p->state = RUNNABLE;
80104ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104baf:	83 ec 0c             	sub    $0xc,%esp
80104bb2:	68 40 72 11 80       	push   $0x80117240
80104bb7:	e8 7c 05 00 00       	call   80105138 <release>
80104bbc:	83 c4 10             	add    $0x10,%esp
      return 0;
80104bbf:	b8 00 00 00 00       	mov    $0x0,%eax
80104bc4:	eb 25                	jmp    80104beb <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bc6:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104bcd:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80104bd4:	72 af                	jb     80104b85 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104bd6:	83 ec 0c             	sub    $0xc,%esp
80104bd9:	68 40 72 11 80       	push   $0x80117240
80104bde:	e8 55 05 00 00       	call   80105138 <release>
80104be3:	83 c4 10             	add    $0x10,%esp
  return -1;
80104be6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104beb:	c9                   	leave  
80104bec:	c3                   	ret    

80104bed <initqueue>:
//큐 초기화
void initqueue(struct queue *q) {
80104bed:	55                   	push   %ebp
80104bee:	89 e5                	mov    %esp,%ebp
  q->front = 0;
80104bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf3:	c7 80 00 01 00 00 00 	movl   $0x0,0x100(%eax)
80104bfa:	00 00 00 
  q->rear = 0;
80104bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80104c00:	c7 80 04 01 00 00 00 	movl   $0x0,0x104(%eax)
80104c07:	00 00 00 
}
80104c0a:	90                   	nop
80104c0b:	5d                   	pop    %ebp
80104c0c:	c3                   	ret    

80104c0d <isempty>:

// 큐가 비었는지 확인
int isempty(struct queue *q) {
80104c0d:	55                   	push   %ebp
80104c0e:	89 e5                	mov    %esp,%ebp
  return q->front == q->rear;
80104c10:	8b 45 08             	mov    0x8(%ebp),%eax
80104c13:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
80104c19:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1c:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104c22:	39 c2                	cmp    %eax,%edx
80104c24:	0f 94 c0             	sete   %al
80104c27:	0f b6 c0             	movzbl %al,%eax
}
80104c2a:	5d                   	pop    %ebp
80104c2b:	c3                   	ret    

80104c2c <enqueue>:

// 큐에 중복없이 프로세스 추가
void enqueue(struct queue *q, struct proc *p) {
80104c2c:	55                   	push   %ebp
80104c2d:	89 e5                	mov    %esp,%ebp
80104c2f:	83 ec 10             	sub    $0x10,%esp
  //이미 들어있는지 검사
  for (int i = q->front; i < q->rear; i++) {
80104c32:	8b 45 08             	mov    0x8(%ebp),%eax
80104c35:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
80104c3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104c3e:	eb 12                	jmp    80104c52 <enqueue+0x26>
    if (q->q[i] == p)
80104c40:	8b 45 08             	mov    0x8(%ebp),%eax
80104c43:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c46:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104c49:	39 45 0c             	cmp    %eax,0xc(%ebp)
80104c4c:	74 48                	je     80104c96 <enqueue+0x6a>
  for (int i = q->front; i < q->rear; i++) {
80104c4e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104c52:	8b 45 08             	mov    0x8(%ebp),%eax
80104c55:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104c5b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80104c5e:	7c e0                	jl     80104c40 <enqueue+0x14>
      return; //중복 방지
  }
  q->q[q->rear % QUEUE_SIZE] = p;
80104c60:	8b 45 08             	mov    0x8(%ebp),%eax
80104c63:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104c69:	99                   	cltd   
80104c6a:	c1 ea 1a             	shr    $0x1a,%edx
80104c6d:	01 d0                	add    %edx,%eax
80104c6f:	83 e0 3f             	and    $0x3f,%eax
80104c72:	29 d0                	sub    %edx,%eax
80104c74:	89 c1                	mov    %eax,%ecx
80104c76:	8b 45 08             	mov    0x8(%ebp),%eax
80104c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c7c:	89 14 88             	mov    %edx,(%eax,%ecx,4)
  q->rear++;
80104c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c82:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104c88:	8d 50 01             	lea    0x1(%eax),%edx
80104c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8e:	89 90 04 01 00 00    	mov    %edx,0x104(%eax)
80104c94:	eb 01                	jmp    80104c97 <enqueue+0x6b>
      return; //중복 방지
80104c96:	90                   	nop
}
80104c97:	c9                   	leave  
80104c98:	c3                   	ret    

80104c99 <dequeue>:

// 큐에서 프로세스 꺼내기
struct proc* dequeue(struct queue *q) {
80104c99:	55                   	push   %ebp
80104c9a:	89 e5                	mov    %esp,%ebp
80104c9c:	83 ec 10             	sub    $0x10,%esp
  if (isempty(q))
80104c9f:	ff 75 08             	push   0x8(%ebp)
80104ca2:	e8 66 ff ff ff       	call   80104c0d <isempty>
80104ca7:	83 c4 04             	add    $0x4,%esp
80104caa:	85 c0                	test   %eax,%eax
80104cac:	74 07                	je     80104cb5 <dequeue+0x1c>
    return 0;
80104cae:	b8 00 00 00 00       	mov    $0x0,%eax
80104cb3:	eb 37                	jmp    80104cec <dequeue+0x53>
  struct proc *p = q->q[q->front % QUEUE_SIZE];
80104cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb8:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
80104cbe:	99                   	cltd   
80104cbf:	c1 ea 1a             	shr    $0x1a,%edx
80104cc2:	01 d0                	add    %edx,%eax
80104cc4:	83 e0 3f             	and    $0x3f,%eax
80104cc7:	29 d0                	sub    %edx,%eax
80104cc9:	89 c2                	mov    %eax,%edx
80104ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cce:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104cd1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  q->front++;
80104cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd7:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
80104cdd:	8d 50 01             	lea    0x1(%eax),%edx
80104ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce3:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
  return p;
80104ce9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cec:	c9                   	leave  
80104ced:	c3                   	ret    

80104cee <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104cee:	55                   	push   %ebp
80104cef:	89 e5                	mov    %esp,%ebp
80104cf1:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cf4:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
80104cfb:	e9 da 00 00 00       	jmp    80104dda <procdump+0xec>
    if(p->state == UNUSED)
80104d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d03:	8b 40 0c             	mov    0xc(%eax),%eax
80104d06:	85 c0                	test   %eax,%eax
80104d08:	0f 84 c4 00 00 00    	je     80104dd2 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d11:	8b 40 0c             	mov    0xc(%eax),%eax
80104d14:	83 f8 05             	cmp    $0x5,%eax
80104d17:	77 23                	ja     80104d3c <procdump+0x4e>
80104d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d1c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d1f:	8b 04 85 18 f0 10 80 	mov    -0x7fef0fe8(,%eax,4),%eax
80104d26:	85 c0                	test   %eax,%eax
80104d28:	74 12                	je     80104d3c <procdump+0x4e>
      state = states[p->state];
80104d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d2d:	8b 40 0c             	mov    0xc(%eax),%eax
80104d30:	8b 04 85 18 f0 10 80 	mov    -0x7fef0fe8(,%eax,4),%eax
80104d37:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d3a:	eb 07                	jmp    80104d43 <procdump+0x55>
    else
      state = "???";
80104d3c:	c7 45 ec f5 ae 10 80 	movl   $0x8010aef5,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d46:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d4c:	8b 40 10             	mov    0x10(%eax),%eax
80104d4f:	52                   	push   %edx
80104d50:	ff 75 ec             	push   -0x14(%ebp)
80104d53:	50                   	push   %eax
80104d54:	68 f9 ae 10 80       	push   $0x8010aef9
80104d59:	e8 96 b6 ff ff       	call   801003f4 <cprintf>
80104d5e:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d64:	8b 40 0c             	mov    0xc(%eax),%eax
80104d67:	83 f8 02             	cmp    $0x2,%eax
80104d6a:	75 54                	jne    80104dc0 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d6f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d72:	8b 40 0c             	mov    0xc(%eax),%eax
80104d75:	83 c0 08             	add    $0x8,%eax
80104d78:	89 c2                	mov    %eax,%edx
80104d7a:	83 ec 08             	sub    $0x8,%esp
80104d7d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104d80:	50                   	push   %eax
80104d81:	52                   	push   %edx
80104d82:	e8 03 04 00 00       	call   8010518a <getcallerpcs>
80104d87:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104d8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d91:	eb 1c                	jmp    80104daf <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d96:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d9a:	83 ec 08             	sub    $0x8,%esp
80104d9d:	50                   	push   %eax
80104d9e:	68 02 af 10 80       	push   $0x8010af02
80104da3:	e8 4c b6 ff ff       	call   801003f4 <cprintf>
80104da8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104dab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104daf:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104db3:	7f 0b                	jg     80104dc0 <procdump+0xd2>
80104db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104dbc:	85 c0                	test   %eax,%eax
80104dbe:	75 d3                	jne    80104d93 <procdump+0xa5>
    }
    cprintf("\n");
80104dc0:	83 ec 0c             	sub    $0xc,%esp
80104dc3:	68 06 af 10 80       	push   $0x8010af06
80104dc8:	e8 27 b6 ff ff       	call   801003f4 <cprintf>
80104dcd:	83 c4 10             	add    $0x10,%esp
80104dd0:	eb 01                	jmp    80104dd3 <procdump+0xe5>
      continue;
80104dd2:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dd3:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
80104dda:	81 7d f0 74 9a 11 80 	cmpl   $0x80119a74,-0x10(%ebp)
80104de1:	0f 82 19 ff ff ff    	jb     80104d00 <procdump+0x12>
  }
}
80104de7:	90                   	nop
80104de8:	90                   	nop
80104de9:	c9                   	leave  
80104dea:	c3                   	ret    

80104deb <setSchedPolicy>:
//추가
int
setSchedPolicy(int policy)
{
80104deb:	55                   	push   %ebp
80104dec:	89 e5                	mov    %esp,%ebp
80104dee:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)  // 정책 번호 범위 확인
80104df1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104df5:	78 06                	js     80104dfd <setSchedPolicy+0x12>
80104df7:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104dfb:	7e 07                	jle    80104e04 <setSchedPolicy+0x19>
    return -1;
80104dfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e02:	eb 1d                	jmp    80104e21 <setSchedPolicy+0x36>
  
  pushcli(); //인터럽트 끄기
80104e04:	e8 2c 04 00 00       	call   80105235 <pushcli>
  mycpu()->sched_policy = policy;
80104e09:	e8 bc f0 ff ff       	call   80103eca <mycpu>
80104e0e:	8b 55 08             	mov    0x8(%ebp),%edx
80104e11:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli(); //인터럽트 켜기
80104e17:	e8 66 04 00 00       	call   80105282 <popcli>
  return 0;
80104e1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e21:	c9                   	leave  
80104e22:	c3                   	ret    

80104e23 <getpinfo>:


int
getpinfo(struct pstat *ps)
{
80104e23:	55                   	push   %ebp
80104e24:	89 e5                	mov    %esp,%ebp
80104e26:	53                   	push   %ebx
80104e27:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e2a:	83 ec 0c             	sub    $0xc,%esp
80104e2d:	68 40 72 11 80       	push   $0x80117240
80104e32:	e8 93 02 00 00       	call   801050ca <acquire>
80104e37:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROC; i++) {
80104e3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e41:	e9 e1 00 00 00       	jmp    80104f27 <getpinfo+0x104>
    p = &ptable.proc[i];
80104e46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e49:	89 d0                	mov    %edx,%eax
80104e4b:	c1 e0 02             	shl    $0x2,%eax
80104e4e:	01 d0                	add    %edx,%eax
80104e50:	c1 e0 05             	shl    $0x5,%eax
80104e53:	83 c0 30             	add    $0x30,%eax
80104e56:	05 40 72 11 80       	add    $0x80117240,%eax
80104e5b:	83 c0 04             	add    $0x4,%eax
80104e5e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    if (p->state != UNUSED)
80104e61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e64:	8b 40 0c             	mov    0xc(%eax),%eax
80104e67:	85 c0                	test   %eax,%eax
80104e69:	74 0f                	je     80104e7a <getpinfo+0x57>
    ps->inuse[i] = 1;
80104e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e71:	c7 04 90 01 00 00 00 	movl   $0x1,(%eax,%edx,4)
80104e78:	eb 0d                	jmp    80104e87 <getpinfo+0x64>
    else
    ps->inuse[i] = 0;
80104e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e80:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)

    ps->pid[i] = p->pid;
80104e87:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e8a:	8b 50 10             	mov    0x10(%eax),%edx
80104e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e90:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104e93:	83 c1 40             	add    $0x40,%ecx
80104e96:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = p->priority;
80104e99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e9c:	8b 50 7c             	mov    0x7c(%eax),%edx
80104e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104ea5:	83 e9 80             	sub    $0xffffff80,%ecx
80104ea8:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
80104eab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104eae:	8b 40 0c             	mov    0xc(%eax),%eax
80104eb1:	89 c1                	mov    %eax,%ecx
80104eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eb9:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80104ebf:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
80104ec2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ec9:	eb 52                	jmp    80104f1d <getpinfo+0xfa>
      ps->ticks[i][j] = p->ticks[j];
80104ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ece:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ed1:	83 c2 20             	add    $0x20,%edx
80104ed4:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eda:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104edd:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104ee4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104ee7:	01 d9                	add    %ebx,%ecx
80104ee9:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104eef:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
80104ef2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ef5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ef8:	83 c2 24             	add    $0x24,%edx
80104efb:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104efe:	8b 45 08             	mov    0x8(%ebp),%eax
80104f01:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104f04:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104f0b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f0e:	01 d9                	add    %ebx,%ecx
80104f10:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104f16:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104f19:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104f1d:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104f21:	7e a8                	jle    80104ecb <getpinfo+0xa8>
  for (int i = 0; i < NPROC; i++) {
80104f23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f27:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104f2b:	0f 8e 15 ff ff ff    	jle    80104e46 <getpinfo+0x23>
    }
  }

  release(&ptable.lock);
80104f31:	83 ec 0c             	sub    $0xc,%esp
80104f34:	68 40 72 11 80       	push   $0x80117240
80104f39:	e8 fa 01 00 00       	call   80105138 <release>
80104f3e:	83 c4 10             	add    $0x10,%esp
  return 0;
80104f41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f49:	c9                   	leave  
80104f4a:	c3                   	ret    

80104f4b <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104f4b:	55                   	push   %ebp
80104f4c:	89 e5                	mov    %esp,%ebp
80104f4e:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104f51:	8b 45 08             	mov    0x8(%ebp),%eax
80104f54:	83 c0 04             	add    $0x4,%eax
80104f57:	83 ec 08             	sub    $0x8,%esp
80104f5a:	68 32 af 10 80       	push   $0x8010af32
80104f5f:	50                   	push   %eax
80104f60:	e8 43 01 00 00       	call   801050a8 <initlock>
80104f65:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104f68:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6b:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f6e:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104f71:	8b 45 08             	mov    0x8(%ebp),%eax
80104f74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104f84:	90                   	nop
80104f85:	c9                   	leave  
80104f86:	c3                   	ret    

80104f87 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104f87:	55                   	push   %ebp
80104f88:	89 e5                	mov    %esp,%ebp
80104f8a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f90:	83 c0 04             	add    $0x4,%eax
80104f93:	83 ec 0c             	sub    $0xc,%esp
80104f96:	50                   	push   %eax
80104f97:	e8 2e 01 00 00       	call   801050ca <acquire>
80104f9c:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f9f:	eb 15                	jmp    80104fb6 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa4:	83 c0 04             	add    $0x4,%eax
80104fa7:	83 ec 08             	sub    $0x8,%esp
80104faa:	50                   	push   %eax
80104fab:	ff 75 08             	push   0x8(%ebp)
80104fae:	e8 92 fa ff ff       	call   80104a45 <sleep>
80104fb3:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb9:	8b 00                	mov    (%eax),%eax
80104fbb:	85 c0                	test   %eax,%eax
80104fbd:	75 e2                	jne    80104fa1 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104fc8:	e8 75 ef ff ff       	call   80103f42 <myproc>
80104fcd:	8b 50 10             	mov    0x10(%eax),%edx
80104fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd3:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd9:	83 c0 04             	add    $0x4,%eax
80104fdc:	83 ec 0c             	sub    $0xc,%esp
80104fdf:	50                   	push   %eax
80104fe0:	e8 53 01 00 00       	call   80105138 <release>
80104fe5:	83 c4 10             	add    $0x10,%esp
}
80104fe8:	90                   	nop
80104fe9:	c9                   	leave  
80104fea:	c3                   	ret    

80104feb <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104feb:	55                   	push   %ebp
80104fec:	89 e5                	mov    %esp,%ebp
80104fee:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff4:	83 c0 04             	add    $0x4,%eax
80104ff7:	83 ec 0c             	sub    $0xc,%esp
80104ffa:	50                   	push   %eax
80104ffb:	e8 ca 00 00 00       	call   801050ca <acquire>
80105000:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105003:	8b 45 08             	mov    0x8(%ebp),%eax
80105006:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010500c:	8b 45 08             	mov    0x8(%ebp),%eax
8010500f:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105016:	83 ec 0c             	sub    $0xc,%esp
80105019:	ff 75 08             	push   0x8(%ebp)
8010501c:	e8 0e fb ff ff       	call   80104b2f <wakeup>
80105021:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105024:	8b 45 08             	mov    0x8(%ebp),%eax
80105027:	83 c0 04             	add    $0x4,%eax
8010502a:	83 ec 0c             	sub    $0xc,%esp
8010502d:	50                   	push   %eax
8010502e:	e8 05 01 00 00       	call   80105138 <release>
80105033:	83 c4 10             	add    $0x10,%esp
}
80105036:	90                   	nop
80105037:	c9                   	leave  
80105038:	c3                   	ret    

80105039 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105039:	55                   	push   %ebp
8010503a:	89 e5                	mov    %esp,%ebp
8010503c:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
8010503f:	8b 45 08             	mov    0x8(%ebp),%eax
80105042:	83 c0 04             	add    $0x4,%eax
80105045:	83 ec 0c             	sub    $0xc,%esp
80105048:	50                   	push   %eax
80105049:	e8 7c 00 00 00       	call   801050ca <acquire>
8010504e:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80105051:	8b 45 08             	mov    0x8(%ebp),%eax
80105054:	8b 00                	mov    (%eax),%eax
80105056:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105059:	8b 45 08             	mov    0x8(%ebp),%eax
8010505c:	83 c0 04             	add    $0x4,%eax
8010505f:	83 ec 0c             	sub    $0xc,%esp
80105062:	50                   	push   %eax
80105063:	e8 d0 00 00 00       	call   80105138 <release>
80105068:	83 c4 10             	add    $0x10,%esp
  return r;
8010506b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010506e:	c9                   	leave  
8010506f:	c3                   	ret    

80105070 <readeflags>:
{
80105070:	55                   	push   %ebp
80105071:	89 e5                	mov    %esp,%ebp
80105073:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105076:	9c                   	pushf  
80105077:	58                   	pop    %eax
80105078:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010507b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010507e:	c9                   	leave  
8010507f:	c3                   	ret    

80105080 <cli>:
{
80105080:	55                   	push   %ebp
80105081:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105083:	fa                   	cli    
}
80105084:	90                   	nop
80105085:	5d                   	pop    %ebp
80105086:	c3                   	ret    

80105087 <sti>:
{
80105087:	55                   	push   %ebp
80105088:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010508a:	fb                   	sti    
}
8010508b:	90                   	nop
8010508c:	5d                   	pop    %ebp
8010508d:	c3                   	ret    

8010508e <xchg>:
{
8010508e:	55                   	push   %ebp
8010508f:	89 e5                	mov    %esp,%ebp
80105091:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105094:	8b 55 08             	mov    0x8(%ebp),%edx
80105097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010509a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010509d:	f0 87 02             	lock xchg %eax,(%edx)
801050a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801050a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050a6:	c9                   	leave  
801050a7:	c3                   	ret    

801050a8 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801050a8:	55                   	push   %ebp
801050a9:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801050ab:	8b 45 08             	mov    0x8(%ebp),%eax
801050ae:	8b 55 0c             	mov    0xc(%ebp),%edx
801050b1:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801050b4:	8b 45 08             	mov    0x8(%ebp),%eax
801050b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050bd:	8b 45 08             	mov    0x8(%ebp),%eax
801050c0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050c7:	90                   	nop
801050c8:	5d                   	pop    %ebp
801050c9:	c3                   	ret    

801050ca <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050ca:	55                   	push   %ebp
801050cb:	89 e5                	mov    %esp,%ebp
801050cd:	53                   	push   %ebx
801050ce:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050d1:	e8 5f 01 00 00       	call   80105235 <pushcli>
  if(holding(lk)){
801050d6:	8b 45 08             	mov    0x8(%ebp),%eax
801050d9:	83 ec 0c             	sub    $0xc,%esp
801050dc:	50                   	push   %eax
801050dd:	e8 23 01 00 00       	call   80105205 <holding>
801050e2:	83 c4 10             	add    $0x10,%esp
801050e5:	85 c0                	test   %eax,%eax
801050e7:	74 0d                	je     801050f6 <acquire+0x2c>
    panic("acquire");
801050e9:	83 ec 0c             	sub    $0xc,%esp
801050ec:	68 3d af 10 80       	push   $0x8010af3d
801050f1:	e8 b3 b4 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801050f6:	90                   	nop
801050f7:	8b 45 08             	mov    0x8(%ebp),%eax
801050fa:	83 ec 08             	sub    $0x8,%esp
801050fd:	6a 01                	push   $0x1
801050ff:	50                   	push   %eax
80105100:	e8 89 ff ff ff       	call   8010508e <xchg>
80105105:	83 c4 10             	add    $0x10,%esp
80105108:	85 c0                	test   %eax,%eax
8010510a:	75 eb                	jne    801050f7 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010510c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105111:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105114:	e8 b1 ed ff ff       	call   80103eca <mycpu>
80105119:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010511c:	8b 45 08             	mov    0x8(%ebp),%eax
8010511f:	83 c0 0c             	add    $0xc,%eax
80105122:	83 ec 08             	sub    $0x8,%esp
80105125:	50                   	push   %eax
80105126:	8d 45 08             	lea    0x8(%ebp),%eax
80105129:	50                   	push   %eax
8010512a:	e8 5b 00 00 00       	call   8010518a <getcallerpcs>
8010512f:	83 c4 10             	add    $0x10,%esp
}
80105132:	90                   	nop
80105133:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105136:	c9                   	leave  
80105137:	c3                   	ret    

80105138 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105138:	55                   	push   %ebp
80105139:	89 e5                	mov    %esp,%ebp
8010513b:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010513e:	83 ec 0c             	sub    $0xc,%esp
80105141:	ff 75 08             	push   0x8(%ebp)
80105144:	e8 bc 00 00 00       	call   80105205 <holding>
80105149:	83 c4 10             	add    $0x10,%esp
8010514c:	85 c0                	test   %eax,%eax
8010514e:	75 0d                	jne    8010515d <release+0x25>
    panic("release");
80105150:	83 ec 0c             	sub    $0xc,%esp
80105153:	68 45 af 10 80       	push   $0x8010af45
80105158:	e8 4c b4 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
8010515d:	8b 45 08             	mov    0x8(%ebp),%eax
80105160:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105167:	8b 45 08             	mov    0x8(%ebp),%eax
8010516a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105171:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105176:	8b 45 08             	mov    0x8(%ebp),%eax
80105179:	8b 55 08             	mov    0x8(%ebp),%edx
8010517c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105182:	e8 fb 00 00 00       	call   80105282 <popcli>
}
80105187:	90                   	nop
80105188:	c9                   	leave  
80105189:	c3                   	ret    

8010518a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010518a:	55                   	push   %ebp
8010518b:	89 e5                	mov    %esp,%ebp
8010518d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105190:	8b 45 08             	mov    0x8(%ebp),%eax
80105193:	83 e8 08             	sub    $0x8,%eax
80105196:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105199:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801051a0:	eb 38                	jmp    801051da <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801051a2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801051a6:	74 53                	je     801051fb <getcallerpcs+0x71>
801051a8:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801051af:	76 4a                	jbe    801051fb <getcallerpcs+0x71>
801051b1:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801051b5:	74 44                	je     801051fb <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801051b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051ba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c4:	01 c2                	add    %eax,%edx
801051c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051c9:	8b 40 04             	mov    0x4(%eax),%eax
801051cc:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801051ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051d1:	8b 00                	mov    (%eax),%eax
801051d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801051d6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051da:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051de:	7e c2                	jle    801051a2 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
801051e0:	eb 19                	jmp    801051fb <getcallerpcs+0x71>
    pcs[i] = 0;
801051e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ef:	01 d0                	add    %edx,%eax
801051f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801051f7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051fb:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051ff:	7e e1                	jle    801051e2 <getcallerpcs+0x58>
}
80105201:	90                   	nop
80105202:	90                   	nop
80105203:	c9                   	leave  
80105204:	c3                   	ret    

80105205 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105205:	55                   	push   %ebp
80105206:	89 e5                	mov    %esp,%ebp
80105208:	53                   	push   %ebx
80105209:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010520c:	8b 45 08             	mov    0x8(%ebp),%eax
8010520f:	8b 00                	mov    (%eax),%eax
80105211:	85 c0                	test   %eax,%eax
80105213:	74 16                	je     8010522b <holding+0x26>
80105215:	8b 45 08             	mov    0x8(%ebp),%eax
80105218:	8b 58 08             	mov    0x8(%eax),%ebx
8010521b:	e8 aa ec ff ff       	call   80103eca <mycpu>
80105220:	39 c3                	cmp    %eax,%ebx
80105222:	75 07                	jne    8010522b <holding+0x26>
80105224:	b8 01 00 00 00       	mov    $0x1,%eax
80105229:	eb 05                	jmp    80105230 <holding+0x2b>
8010522b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105230:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105233:	c9                   	leave  
80105234:	c3                   	ret    

80105235 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105235:	55                   	push   %ebp
80105236:	89 e5                	mov    %esp,%ebp
80105238:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010523b:	e8 30 fe ff ff       	call   80105070 <readeflags>
80105240:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105243:	e8 38 fe ff ff       	call   80105080 <cli>
  if(mycpu()->ncli == 0)
80105248:	e8 7d ec ff ff       	call   80103eca <mycpu>
8010524d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105253:	85 c0                	test   %eax,%eax
80105255:	75 14                	jne    8010526b <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105257:	e8 6e ec ff ff       	call   80103eca <mycpu>
8010525c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010525f:	81 e2 00 02 00 00    	and    $0x200,%edx
80105265:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010526b:	e8 5a ec ff ff       	call   80103eca <mycpu>
80105270:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105276:	83 c2 01             	add    $0x1,%edx
80105279:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010527f:	90                   	nop
80105280:	c9                   	leave  
80105281:	c3                   	ret    

80105282 <popcli>:

void
popcli(void)
{
80105282:	55                   	push   %ebp
80105283:	89 e5                	mov    %esp,%ebp
80105285:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105288:	e8 e3 fd ff ff       	call   80105070 <readeflags>
8010528d:	25 00 02 00 00       	and    $0x200,%eax
80105292:	85 c0                	test   %eax,%eax
80105294:	74 0d                	je     801052a3 <popcli+0x21>
    panic("popcli - interruptible");
80105296:	83 ec 0c             	sub    $0xc,%esp
80105299:	68 4d af 10 80       	push   $0x8010af4d
8010529e:	e8 06 b3 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801052a3:	e8 22 ec ff ff       	call   80103eca <mycpu>
801052a8:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801052ae:	83 ea 01             	sub    $0x1,%edx
801052b1:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801052b7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052bd:	85 c0                	test   %eax,%eax
801052bf:	79 0d                	jns    801052ce <popcli+0x4c>
    panic("popcli");
801052c1:	83 ec 0c             	sub    $0xc,%esp
801052c4:	68 64 af 10 80       	push   $0x8010af64
801052c9:	e8 db b2 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801052ce:	e8 f7 eb ff ff       	call   80103eca <mycpu>
801052d3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052d9:	85 c0                	test   %eax,%eax
801052db:	75 14                	jne    801052f1 <popcli+0x6f>
801052dd:	e8 e8 eb ff ff       	call   80103eca <mycpu>
801052e2:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801052e8:	85 c0                	test   %eax,%eax
801052ea:	74 05                	je     801052f1 <popcli+0x6f>
    sti();
801052ec:	e8 96 fd ff ff       	call   80105087 <sti>
}
801052f1:	90                   	nop
801052f2:	c9                   	leave  
801052f3:	c3                   	ret    

801052f4 <stosb>:
{
801052f4:	55                   	push   %ebp
801052f5:	89 e5                	mov    %esp,%ebp
801052f7:	57                   	push   %edi
801052f8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052fc:	8b 55 10             	mov    0x10(%ebp),%edx
801052ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105302:	89 cb                	mov    %ecx,%ebx
80105304:	89 df                	mov    %ebx,%edi
80105306:	89 d1                	mov    %edx,%ecx
80105308:	fc                   	cld    
80105309:	f3 aa                	rep stos %al,%es:(%edi)
8010530b:	89 ca                	mov    %ecx,%edx
8010530d:	89 fb                	mov    %edi,%ebx
8010530f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105312:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105315:	90                   	nop
80105316:	5b                   	pop    %ebx
80105317:	5f                   	pop    %edi
80105318:	5d                   	pop    %ebp
80105319:	c3                   	ret    

8010531a <stosl>:
{
8010531a:	55                   	push   %ebp
8010531b:	89 e5                	mov    %esp,%ebp
8010531d:	57                   	push   %edi
8010531e:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010531f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105322:	8b 55 10             	mov    0x10(%ebp),%edx
80105325:	8b 45 0c             	mov    0xc(%ebp),%eax
80105328:	89 cb                	mov    %ecx,%ebx
8010532a:	89 df                	mov    %ebx,%edi
8010532c:	89 d1                	mov    %edx,%ecx
8010532e:	fc                   	cld    
8010532f:	f3 ab                	rep stos %eax,%es:(%edi)
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

80105340 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105343:	8b 45 08             	mov    0x8(%ebp),%eax
80105346:	83 e0 03             	and    $0x3,%eax
80105349:	85 c0                	test   %eax,%eax
8010534b:	75 43                	jne    80105390 <memset+0x50>
8010534d:	8b 45 10             	mov    0x10(%ebp),%eax
80105350:	83 e0 03             	and    $0x3,%eax
80105353:	85 c0                	test   %eax,%eax
80105355:	75 39                	jne    80105390 <memset+0x50>
    c &= 0xFF;
80105357:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010535e:	8b 45 10             	mov    0x10(%ebp),%eax
80105361:	c1 e8 02             	shr    $0x2,%eax
80105364:	89 c2                	mov    %eax,%edx
80105366:	8b 45 0c             	mov    0xc(%ebp),%eax
80105369:	c1 e0 18             	shl    $0x18,%eax
8010536c:	89 c1                	mov    %eax,%ecx
8010536e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105371:	c1 e0 10             	shl    $0x10,%eax
80105374:	09 c1                	or     %eax,%ecx
80105376:	8b 45 0c             	mov    0xc(%ebp),%eax
80105379:	c1 e0 08             	shl    $0x8,%eax
8010537c:	09 c8                	or     %ecx,%eax
8010537e:	0b 45 0c             	or     0xc(%ebp),%eax
80105381:	52                   	push   %edx
80105382:	50                   	push   %eax
80105383:	ff 75 08             	push   0x8(%ebp)
80105386:	e8 8f ff ff ff       	call   8010531a <stosl>
8010538b:	83 c4 0c             	add    $0xc,%esp
8010538e:	eb 12                	jmp    801053a2 <memset+0x62>
  } else
    stosb(dst, c, n);
80105390:	8b 45 10             	mov    0x10(%ebp),%eax
80105393:	50                   	push   %eax
80105394:	ff 75 0c             	push   0xc(%ebp)
80105397:	ff 75 08             	push   0x8(%ebp)
8010539a:	e8 55 ff ff ff       	call   801052f4 <stosb>
8010539f:	83 c4 0c             	add    $0xc,%esp
  return dst;
801053a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053a5:	c9                   	leave  
801053a6:	c3                   	ret    

801053a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801053a7:	55                   	push   %ebp
801053a8:	89 e5                	mov    %esp,%ebp
801053aa:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801053ad:	8b 45 08             	mov    0x8(%ebp),%eax
801053b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801053b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801053b9:	eb 30                	jmp    801053eb <memcmp+0x44>
    if(*s1 != *s2)
801053bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053be:	0f b6 10             	movzbl (%eax),%edx
801053c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053c4:	0f b6 00             	movzbl (%eax),%eax
801053c7:	38 c2                	cmp    %al,%dl
801053c9:	74 18                	je     801053e3 <memcmp+0x3c>
      return *s1 - *s2;
801053cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ce:	0f b6 00             	movzbl (%eax),%eax
801053d1:	0f b6 d0             	movzbl %al,%edx
801053d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d7:	0f b6 00             	movzbl (%eax),%eax
801053da:	0f b6 c8             	movzbl %al,%ecx
801053dd:	89 d0                	mov    %edx,%eax
801053df:	29 c8                	sub    %ecx,%eax
801053e1:	eb 1a                	jmp    801053fd <memcmp+0x56>
    s1++, s2++;
801053e3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053e7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801053eb:	8b 45 10             	mov    0x10(%ebp),%eax
801053ee:	8d 50 ff             	lea    -0x1(%eax),%edx
801053f1:	89 55 10             	mov    %edx,0x10(%ebp)
801053f4:	85 c0                	test   %eax,%eax
801053f6:	75 c3                	jne    801053bb <memcmp+0x14>
  }

  return 0;
801053f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053fd:	c9                   	leave  
801053fe:	c3                   	ret    

801053ff <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053ff:	55                   	push   %ebp
80105400:	89 e5                	mov    %esp,%ebp
80105402:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105405:	8b 45 0c             	mov    0xc(%ebp),%eax
80105408:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010540b:	8b 45 08             	mov    0x8(%ebp),%eax
8010540e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105411:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105414:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105417:	73 54                	jae    8010546d <memmove+0x6e>
80105419:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010541c:	8b 45 10             	mov    0x10(%ebp),%eax
8010541f:	01 d0                	add    %edx,%eax
80105421:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105424:	73 47                	jae    8010546d <memmove+0x6e>
    s += n;
80105426:	8b 45 10             	mov    0x10(%ebp),%eax
80105429:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010542c:	8b 45 10             	mov    0x10(%ebp),%eax
8010542f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105432:	eb 13                	jmp    80105447 <memmove+0x48>
      *--d = *--s;
80105434:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105438:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010543c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010543f:	0f b6 10             	movzbl (%eax),%edx
80105442:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105445:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105447:	8b 45 10             	mov    0x10(%ebp),%eax
8010544a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010544d:	89 55 10             	mov    %edx,0x10(%ebp)
80105450:	85 c0                	test   %eax,%eax
80105452:	75 e0                	jne    80105434 <memmove+0x35>
  if(s < d && s + n > d){
80105454:	eb 24                	jmp    8010547a <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105456:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105459:	8d 42 01             	lea    0x1(%edx),%eax
8010545c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010545f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105462:	8d 48 01             	lea    0x1(%eax),%ecx
80105465:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105468:	0f b6 12             	movzbl (%edx),%edx
8010546b:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010546d:	8b 45 10             	mov    0x10(%ebp),%eax
80105470:	8d 50 ff             	lea    -0x1(%eax),%edx
80105473:	89 55 10             	mov    %edx,0x10(%ebp)
80105476:	85 c0                	test   %eax,%eax
80105478:	75 dc                	jne    80105456 <memmove+0x57>

  return dst;
8010547a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010547d:	c9                   	leave  
8010547e:	c3                   	ret    

8010547f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010547f:	55                   	push   %ebp
80105480:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105482:	ff 75 10             	push   0x10(%ebp)
80105485:	ff 75 0c             	push   0xc(%ebp)
80105488:	ff 75 08             	push   0x8(%ebp)
8010548b:	e8 6f ff ff ff       	call   801053ff <memmove>
80105490:	83 c4 0c             	add    $0xc,%esp
}
80105493:	c9                   	leave  
80105494:	c3                   	ret    

80105495 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105495:	55                   	push   %ebp
80105496:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105498:	eb 0c                	jmp    801054a6 <strncmp+0x11>
    n--, p++, q++;
8010549a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010549e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801054a2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801054a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054aa:	74 1a                	je     801054c6 <strncmp+0x31>
801054ac:	8b 45 08             	mov    0x8(%ebp),%eax
801054af:	0f b6 00             	movzbl (%eax),%eax
801054b2:	84 c0                	test   %al,%al
801054b4:	74 10                	je     801054c6 <strncmp+0x31>
801054b6:	8b 45 08             	mov    0x8(%ebp),%eax
801054b9:	0f b6 10             	movzbl (%eax),%edx
801054bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801054bf:	0f b6 00             	movzbl (%eax),%eax
801054c2:	38 c2                	cmp    %al,%dl
801054c4:	74 d4                	je     8010549a <strncmp+0x5>
  if(n == 0)
801054c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054ca:	75 07                	jne    801054d3 <strncmp+0x3e>
    return 0;
801054cc:	b8 00 00 00 00       	mov    $0x0,%eax
801054d1:	eb 16                	jmp    801054e9 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801054d3:	8b 45 08             	mov    0x8(%ebp),%eax
801054d6:	0f b6 00             	movzbl (%eax),%eax
801054d9:	0f b6 d0             	movzbl %al,%edx
801054dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801054df:	0f b6 00             	movzbl (%eax),%eax
801054e2:	0f b6 c8             	movzbl %al,%ecx
801054e5:	89 d0                	mov    %edx,%eax
801054e7:	29 c8                	sub    %ecx,%eax
}
801054e9:	5d                   	pop    %ebp
801054ea:	c3                   	ret    

801054eb <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054eb:	55                   	push   %ebp
801054ec:	89 e5                	mov    %esp,%ebp
801054ee:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801054f1:	8b 45 08             	mov    0x8(%ebp),%eax
801054f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054f7:	90                   	nop
801054f8:	8b 45 10             	mov    0x10(%ebp),%eax
801054fb:	8d 50 ff             	lea    -0x1(%eax),%edx
801054fe:	89 55 10             	mov    %edx,0x10(%ebp)
80105501:	85 c0                	test   %eax,%eax
80105503:	7e 2c                	jle    80105531 <strncpy+0x46>
80105505:	8b 55 0c             	mov    0xc(%ebp),%edx
80105508:	8d 42 01             	lea    0x1(%edx),%eax
8010550b:	89 45 0c             	mov    %eax,0xc(%ebp)
8010550e:	8b 45 08             	mov    0x8(%ebp),%eax
80105511:	8d 48 01             	lea    0x1(%eax),%ecx
80105514:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105517:	0f b6 12             	movzbl (%edx),%edx
8010551a:	88 10                	mov    %dl,(%eax)
8010551c:	0f b6 00             	movzbl (%eax),%eax
8010551f:	84 c0                	test   %al,%al
80105521:	75 d5                	jne    801054f8 <strncpy+0xd>
    ;
  while(n-- > 0)
80105523:	eb 0c                	jmp    80105531 <strncpy+0x46>
    *s++ = 0;
80105525:	8b 45 08             	mov    0x8(%ebp),%eax
80105528:	8d 50 01             	lea    0x1(%eax),%edx
8010552b:	89 55 08             	mov    %edx,0x8(%ebp)
8010552e:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105531:	8b 45 10             	mov    0x10(%ebp),%eax
80105534:	8d 50 ff             	lea    -0x1(%eax),%edx
80105537:	89 55 10             	mov    %edx,0x10(%ebp)
8010553a:	85 c0                	test   %eax,%eax
8010553c:	7f e7                	jg     80105525 <strncpy+0x3a>
  return os;
8010553e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105541:	c9                   	leave  
80105542:	c3                   	ret    

80105543 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105543:	55                   	push   %ebp
80105544:	89 e5                	mov    %esp,%ebp
80105546:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105549:	8b 45 08             	mov    0x8(%ebp),%eax
8010554c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010554f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105553:	7f 05                	jg     8010555a <safestrcpy+0x17>
    return os;
80105555:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105558:	eb 32                	jmp    8010558c <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
8010555a:	90                   	nop
8010555b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010555f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105563:	7e 1e                	jle    80105583 <safestrcpy+0x40>
80105565:	8b 55 0c             	mov    0xc(%ebp),%edx
80105568:	8d 42 01             	lea    0x1(%edx),%eax
8010556b:	89 45 0c             	mov    %eax,0xc(%ebp)
8010556e:	8b 45 08             	mov    0x8(%ebp),%eax
80105571:	8d 48 01             	lea    0x1(%eax),%ecx
80105574:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105577:	0f b6 12             	movzbl (%edx),%edx
8010557a:	88 10                	mov    %dl,(%eax)
8010557c:	0f b6 00             	movzbl (%eax),%eax
8010557f:	84 c0                	test   %al,%al
80105581:	75 d8                	jne    8010555b <safestrcpy+0x18>
    ;
  *s = 0;
80105583:	8b 45 08             	mov    0x8(%ebp),%eax
80105586:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105589:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010558c:	c9                   	leave  
8010558d:	c3                   	ret    

8010558e <strlen>:

int
strlen(const char *s)
{
8010558e:	55                   	push   %ebp
8010558f:	89 e5                	mov    %esp,%ebp
80105591:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105594:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010559b:	eb 04                	jmp    801055a1 <strlen+0x13>
8010559d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055a1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055a4:	8b 45 08             	mov    0x8(%ebp),%eax
801055a7:	01 d0                	add    %edx,%eax
801055a9:	0f b6 00             	movzbl (%eax),%eax
801055ac:	84 c0                	test   %al,%al
801055ae:	75 ed                	jne    8010559d <strlen+0xf>
    ;
  return n;
801055b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055b3:	c9                   	leave  
801055b4:	c3                   	ret    

801055b5 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801055b5:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055b9:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055bd:	55                   	push   %ebp
  pushl %ebx
801055be:	53                   	push   %ebx
  pushl %esi
801055bf:	56                   	push   %esi
  pushl %edi
801055c0:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055c1:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055c3:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055c5:	5f                   	pop    %edi
  popl %esi
801055c6:	5e                   	pop    %esi
  popl %ebx
801055c7:	5b                   	pop    %ebx
  popl %ebp
801055c8:	5d                   	pop    %ebp
  ret
801055c9:	c3                   	ret    

801055ca <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055ca:	55                   	push   %ebp
801055cb:	89 e5                	mov    %esp,%ebp
801055cd:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801055d0:	e8 6d e9 ff ff       	call   80103f42 <myproc>
801055d5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801055d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055db:	8b 00                	mov    (%eax),%eax
801055dd:	39 45 08             	cmp    %eax,0x8(%ebp)
801055e0:	73 0f                	jae    801055f1 <fetchint+0x27>
801055e2:	8b 45 08             	mov    0x8(%ebp),%eax
801055e5:	8d 50 04             	lea    0x4(%eax),%edx
801055e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055eb:	8b 00                	mov    (%eax),%eax
801055ed:	39 c2                	cmp    %eax,%edx
801055ef:	76 07                	jbe    801055f8 <fetchint+0x2e>
    return -1;
801055f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f6:	eb 0f                	jmp    80105607 <fetchint+0x3d>
  *ip = *(int*)(addr);
801055f8:	8b 45 08             	mov    0x8(%ebp),%eax
801055fb:	8b 10                	mov    (%eax),%edx
801055fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105600:	89 10                	mov    %edx,(%eax)
  return 0;
80105602:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105607:	c9                   	leave  
80105608:	c3                   	ret    

80105609 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105609:	55                   	push   %ebp
8010560a:	89 e5                	mov    %esp,%ebp
8010560c:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010560f:	e8 2e e9 ff ff       	call   80103f42 <myproc>
80105614:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105617:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561a:	8b 00                	mov    (%eax),%eax
8010561c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010561f:	72 07                	jb     80105628 <fetchstr+0x1f>
    return -1;
80105621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105626:	eb 41                	jmp    80105669 <fetchstr+0x60>
  *pp = (char*)addr;
80105628:	8b 55 08             	mov    0x8(%ebp),%edx
8010562b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562e:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105630:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105633:	8b 00                	mov    (%eax),%eax
80105635:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105638:	8b 45 0c             	mov    0xc(%ebp),%eax
8010563b:	8b 00                	mov    (%eax),%eax
8010563d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105640:	eb 1a                	jmp    8010565c <fetchstr+0x53>
    if(*s == 0)
80105642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105645:	0f b6 00             	movzbl (%eax),%eax
80105648:	84 c0                	test   %al,%al
8010564a:	75 0c                	jne    80105658 <fetchstr+0x4f>
      return s - *pp;
8010564c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010564f:	8b 10                	mov    (%eax),%edx
80105651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105654:	29 d0                	sub    %edx,%eax
80105656:	eb 11                	jmp    80105669 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105658:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010565c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105662:	72 de                	jb     80105642 <fetchstr+0x39>
  }
  return -1;
80105664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105669:	c9                   	leave  
8010566a:	c3                   	ret    

8010566b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010566b:	55                   	push   %ebp
8010566c:	89 e5                	mov    %esp,%ebp
8010566e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105671:	e8 cc e8 ff ff       	call   80103f42 <myproc>
80105676:	8b 40 18             	mov    0x18(%eax),%eax
80105679:	8b 50 44             	mov    0x44(%eax),%edx
8010567c:	8b 45 08             	mov    0x8(%ebp),%eax
8010567f:	c1 e0 02             	shl    $0x2,%eax
80105682:	01 d0                	add    %edx,%eax
80105684:	83 c0 04             	add    $0x4,%eax
80105687:	83 ec 08             	sub    $0x8,%esp
8010568a:	ff 75 0c             	push   0xc(%ebp)
8010568d:	50                   	push   %eax
8010568e:	e8 37 ff ff ff       	call   801055ca <fetchint>
80105693:	83 c4 10             	add    $0x10,%esp
}
80105696:	c9                   	leave  
80105697:	c3                   	ret    

80105698 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105698:	55                   	push   %ebp
80105699:	89 e5                	mov    %esp,%ebp
8010569b:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010569e:	e8 9f e8 ff ff       	call   80103f42 <myproc>
801056a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801056a6:	83 ec 08             	sub    $0x8,%esp
801056a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056ac:	50                   	push   %eax
801056ad:	ff 75 08             	push   0x8(%ebp)
801056b0:	e8 b6 ff ff ff       	call   8010566b <argint>
801056b5:	83 c4 10             	add    $0x10,%esp
801056b8:	85 c0                	test   %eax,%eax
801056ba:	79 07                	jns    801056c3 <argptr+0x2b>
    return -1;
801056bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c1:	eb 3b                	jmp    801056fe <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801056c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056c7:	78 1f                	js     801056e8 <argptr+0x50>
801056c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056cc:	8b 00                	mov    (%eax),%eax
801056ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056d1:	39 d0                	cmp    %edx,%eax
801056d3:	76 13                	jbe    801056e8 <argptr+0x50>
801056d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d8:	89 c2                	mov    %eax,%edx
801056da:	8b 45 10             	mov    0x10(%ebp),%eax
801056dd:	01 c2                	add    %eax,%edx
801056df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e2:	8b 00                	mov    (%eax),%eax
801056e4:	39 c2                	cmp    %eax,%edx
801056e6:	76 07                	jbe    801056ef <argptr+0x57>
    return -1;
801056e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ed:	eb 0f                	jmp    801056fe <argptr+0x66>
  *pp = (char*)i;
801056ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f2:	89 c2                	mov    %eax,%edx
801056f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f7:	89 10                	mov    %edx,(%eax)
  return 0;
801056f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056fe:	c9                   	leave  
801056ff:	c3                   	ret    

80105700 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105700:	55                   	push   %ebp
80105701:	89 e5                	mov    %esp,%ebp
80105703:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105706:	83 ec 08             	sub    $0x8,%esp
80105709:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010570c:	50                   	push   %eax
8010570d:	ff 75 08             	push   0x8(%ebp)
80105710:	e8 56 ff ff ff       	call   8010566b <argint>
80105715:	83 c4 10             	add    $0x10,%esp
80105718:	85 c0                	test   %eax,%eax
8010571a:	79 07                	jns    80105723 <argstr+0x23>
    return -1;
8010571c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105721:	eb 12                	jmp    80105735 <argstr+0x35>
  return fetchstr(addr, pp);
80105723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105726:	83 ec 08             	sub    $0x8,%esp
80105729:	ff 75 0c             	push   0xc(%ebp)
8010572c:	50                   	push   %eax
8010572d:	e8 d7 fe ff ff       	call   80105609 <fetchstr>
80105732:	83 c4 10             	add    $0x10,%esp
}
80105735:	c9                   	leave  
80105736:	c3                   	ret    

80105737 <syscall>:
[SYS_yield] = sys_yield,
};

void
syscall(void)
{
80105737:	55                   	push   %ebp
80105738:	89 e5                	mov    %esp,%ebp
8010573a:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010573d:	e8 00 e8 ff ff       	call   80103f42 <myproc>
80105742:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105748:	8b 40 18             	mov    0x18(%eax),%eax
8010574b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010574e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105751:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105755:	7e 2f                	jle    80105786 <syscall+0x4f>
80105757:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575a:	83 f8 18             	cmp    $0x18,%eax
8010575d:	77 27                	ja     80105786 <syscall+0x4f>
8010575f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105762:	8b 04 85 40 f0 10 80 	mov    -0x7fef0fc0(,%eax,4),%eax
80105769:	85 c0                	test   %eax,%eax
8010576b:	74 19                	je     80105786 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
8010576d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105770:	8b 04 85 40 f0 10 80 	mov    -0x7fef0fc0(,%eax,4),%eax
80105777:	ff d0                	call   *%eax
80105779:	89 c2                	mov    %eax,%edx
8010577b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577e:	8b 40 18             	mov    0x18(%eax),%eax
80105781:	89 50 1c             	mov    %edx,0x1c(%eax)
80105784:	eb 2c                	jmp    801057b2 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105789:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010578c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578f:	8b 40 10             	mov    0x10(%eax),%eax
80105792:	ff 75 f0             	push   -0x10(%ebp)
80105795:	52                   	push   %edx
80105796:	50                   	push   %eax
80105797:	68 6b af 10 80       	push   $0x8010af6b
8010579c:	e8 53 ac ff ff       	call   801003f4 <cprintf>
801057a1:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801057a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a7:	8b 40 18             	mov    0x18(%eax),%eax
801057aa:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057b1:	90                   	nop
801057b2:	90                   	nop
801057b3:	c9                   	leave  
801057b4:	c3                   	ret    

801057b5 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057b5:	55                   	push   %ebp
801057b6:	89 e5                	mov    %esp,%ebp
801057b8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057bb:	83 ec 08             	sub    $0x8,%esp
801057be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057c1:	50                   	push   %eax
801057c2:	ff 75 08             	push   0x8(%ebp)
801057c5:	e8 a1 fe ff ff       	call   8010566b <argint>
801057ca:	83 c4 10             	add    $0x10,%esp
801057cd:	85 c0                	test   %eax,%eax
801057cf:	79 07                	jns    801057d8 <argfd+0x23>
    return -1;
801057d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d6:	eb 4f                	jmp    80105827 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801057d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057db:	85 c0                	test   %eax,%eax
801057dd:	78 20                	js     801057ff <argfd+0x4a>
801057df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e2:	83 f8 0f             	cmp    $0xf,%eax
801057e5:	7f 18                	jg     801057ff <argfd+0x4a>
801057e7:	e8 56 e7 ff ff       	call   80103f42 <myproc>
801057ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057ef:	83 c2 08             	add    $0x8,%edx
801057f2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057fd:	75 07                	jne    80105806 <argfd+0x51>
    return -1;
801057ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105804:	eb 21                	jmp    80105827 <argfd+0x72>
  if(pfd)
80105806:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010580a:	74 08                	je     80105814 <argfd+0x5f>
    *pfd = fd;
8010580c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010580f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105812:	89 10                	mov    %edx,(%eax)
  if(pf)
80105814:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105818:	74 08                	je     80105822 <argfd+0x6d>
    *pf = f;
8010581a:	8b 45 10             	mov    0x10(%ebp),%eax
8010581d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105820:	89 10                	mov    %edx,(%eax)
  return 0;
80105822:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105827:	c9                   	leave  
80105828:	c3                   	ret    

80105829 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105829:	55                   	push   %ebp
8010582a:	89 e5                	mov    %esp,%ebp
8010582c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010582f:	e8 0e e7 ff ff       	call   80103f42 <myproc>
80105834:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105837:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010583e:	eb 2a                	jmp    8010586a <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105840:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105843:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105846:	83 c2 08             	add    $0x8,%edx
80105849:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010584d:	85 c0                	test   %eax,%eax
8010584f:	75 15                	jne    80105866 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105854:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105857:	8d 4a 08             	lea    0x8(%edx),%ecx
8010585a:	8b 55 08             	mov    0x8(%ebp),%edx
8010585d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105864:	eb 0f                	jmp    80105875 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105866:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010586a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010586e:	7e d0                	jle    80105840 <fdalloc+0x17>
    }
  }
  return -1;
80105870:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105875:	c9                   	leave  
80105876:	c3                   	ret    

80105877 <sys_dup>:

int
sys_dup(void)
{
80105877:	55                   	push   %ebp
80105878:	89 e5                	mov    %esp,%ebp
8010587a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010587d:	83 ec 04             	sub    $0x4,%esp
80105880:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105883:	50                   	push   %eax
80105884:	6a 00                	push   $0x0
80105886:	6a 00                	push   $0x0
80105888:	e8 28 ff ff ff       	call   801057b5 <argfd>
8010588d:	83 c4 10             	add    $0x10,%esp
80105890:	85 c0                	test   %eax,%eax
80105892:	79 07                	jns    8010589b <sys_dup+0x24>
    return -1;
80105894:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105899:	eb 31                	jmp    801058cc <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010589b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589e:	83 ec 0c             	sub    $0xc,%esp
801058a1:	50                   	push   %eax
801058a2:	e8 82 ff ff ff       	call   80105829 <fdalloc>
801058a7:	83 c4 10             	add    $0x10,%esp
801058aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058b1:	79 07                	jns    801058ba <sys_dup+0x43>
    return -1;
801058b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b8:	eb 12                	jmp    801058cc <sys_dup+0x55>
  filedup(f);
801058ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bd:	83 ec 0c             	sub    $0xc,%esp
801058c0:	50                   	push   %eax
801058c1:	e8 84 b7 ff ff       	call   8010104a <filedup>
801058c6:	83 c4 10             	add    $0x10,%esp
  return fd;
801058c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058cc:	c9                   	leave  
801058cd:	c3                   	ret    

801058ce <sys_read>:

int
sys_read(void)
{
801058ce:	55                   	push   %ebp
801058cf:	89 e5                	mov    %esp,%ebp
801058d1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058d4:	83 ec 04             	sub    $0x4,%esp
801058d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058da:	50                   	push   %eax
801058db:	6a 00                	push   $0x0
801058dd:	6a 00                	push   $0x0
801058df:	e8 d1 fe ff ff       	call   801057b5 <argfd>
801058e4:	83 c4 10             	add    $0x10,%esp
801058e7:	85 c0                	test   %eax,%eax
801058e9:	78 2e                	js     80105919 <sys_read+0x4b>
801058eb:	83 ec 08             	sub    $0x8,%esp
801058ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058f1:	50                   	push   %eax
801058f2:	6a 02                	push   $0x2
801058f4:	e8 72 fd ff ff       	call   8010566b <argint>
801058f9:	83 c4 10             	add    $0x10,%esp
801058fc:	85 c0                	test   %eax,%eax
801058fe:	78 19                	js     80105919 <sys_read+0x4b>
80105900:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105903:	83 ec 04             	sub    $0x4,%esp
80105906:	50                   	push   %eax
80105907:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010590a:	50                   	push   %eax
8010590b:	6a 01                	push   $0x1
8010590d:	e8 86 fd ff ff       	call   80105698 <argptr>
80105912:	83 c4 10             	add    $0x10,%esp
80105915:	85 c0                	test   %eax,%eax
80105917:	79 07                	jns    80105920 <sys_read+0x52>
    return -1;
80105919:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591e:	eb 17                	jmp    80105937 <sys_read+0x69>
  return fileread(f, p, n);
80105920:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105923:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105929:	83 ec 04             	sub    $0x4,%esp
8010592c:	51                   	push   %ecx
8010592d:	52                   	push   %edx
8010592e:	50                   	push   %eax
8010592f:	e8 a6 b8 ff ff       	call   801011da <fileread>
80105934:	83 c4 10             	add    $0x10,%esp
}
80105937:	c9                   	leave  
80105938:	c3                   	ret    

80105939 <sys_write>:

int
sys_write(void)
{
80105939:	55                   	push   %ebp
8010593a:	89 e5                	mov    %esp,%ebp
8010593c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010593f:	83 ec 04             	sub    $0x4,%esp
80105942:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105945:	50                   	push   %eax
80105946:	6a 00                	push   $0x0
80105948:	6a 00                	push   $0x0
8010594a:	e8 66 fe ff ff       	call   801057b5 <argfd>
8010594f:	83 c4 10             	add    $0x10,%esp
80105952:	85 c0                	test   %eax,%eax
80105954:	78 2e                	js     80105984 <sys_write+0x4b>
80105956:	83 ec 08             	sub    $0x8,%esp
80105959:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010595c:	50                   	push   %eax
8010595d:	6a 02                	push   $0x2
8010595f:	e8 07 fd ff ff       	call   8010566b <argint>
80105964:	83 c4 10             	add    $0x10,%esp
80105967:	85 c0                	test   %eax,%eax
80105969:	78 19                	js     80105984 <sys_write+0x4b>
8010596b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596e:	83 ec 04             	sub    $0x4,%esp
80105971:	50                   	push   %eax
80105972:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105975:	50                   	push   %eax
80105976:	6a 01                	push   $0x1
80105978:	e8 1b fd ff ff       	call   80105698 <argptr>
8010597d:	83 c4 10             	add    $0x10,%esp
80105980:	85 c0                	test   %eax,%eax
80105982:	79 07                	jns    8010598b <sys_write+0x52>
    return -1;
80105984:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105989:	eb 17                	jmp    801059a2 <sys_write+0x69>
  return filewrite(f, p, n);
8010598b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010598e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105994:	83 ec 04             	sub    $0x4,%esp
80105997:	51                   	push   %ecx
80105998:	52                   	push   %edx
80105999:	50                   	push   %eax
8010599a:	e8 f3 b8 ff ff       	call   80101292 <filewrite>
8010599f:	83 c4 10             	add    $0x10,%esp
}
801059a2:	c9                   	leave  
801059a3:	c3                   	ret    

801059a4 <sys_close>:

int
sys_close(void)
{
801059a4:	55                   	push   %ebp
801059a5:	89 e5                	mov    %esp,%ebp
801059a7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801059aa:	83 ec 04             	sub    $0x4,%esp
801059ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059b0:	50                   	push   %eax
801059b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059b4:	50                   	push   %eax
801059b5:	6a 00                	push   $0x0
801059b7:	e8 f9 fd ff ff       	call   801057b5 <argfd>
801059bc:	83 c4 10             	add    $0x10,%esp
801059bf:	85 c0                	test   %eax,%eax
801059c1:	79 07                	jns    801059ca <sys_close+0x26>
    return -1;
801059c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c8:	eb 27                	jmp    801059f1 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801059ca:	e8 73 e5 ff ff       	call   80103f42 <myproc>
801059cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059d2:	83 c2 08             	add    $0x8,%edx
801059d5:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801059dc:	00 
  fileclose(f);
801059dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e0:	83 ec 0c             	sub    $0xc,%esp
801059e3:	50                   	push   %eax
801059e4:	e8 b2 b6 ff ff       	call   8010109b <fileclose>
801059e9:	83 c4 10             	add    $0x10,%esp
  return 0;
801059ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059f1:	c9                   	leave  
801059f2:	c3                   	ret    

801059f3 <sys_fstat>:

int
sys_fstat(void)
{
801059f3:	55                   	push   %ebp
801059f4:	89 e5                	mov    %esp,%ebp
801059f6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801059f9:	83 ec 04             	sub    $0x4,%esp
801059fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059ff:	50                   	push   %eax
80105a00:	6a 00                	push   $0x0
80105a02:	6a 00                	push   $0x0
80105a04:	e8 ac fd ff ff       	call   801057b5 <argfd>
80105a09:	83 c4 10             	add    $0x10,%esp
80105a0c:	85 c0                	test   %eax,%eax
80105a0e:	78 17                	js     80105a27 <sys_fstat+0x34>
80105a10:	83 ec 04             	sub    $0x4,%esp
80105a13:	6a 14                	push   $0x14
80105a15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a18:	50                   	push   %eax
80105a19:	6a 01                	push   $0x1
80105a1b:	e8 78 fc ff ff       	call   80105698 <argptr>
80105a20:	83 c4 10             	add    $0x10,%esp
80105a23:	85 c0                	test   %eax,%eax
80105a25:	79 07                	jns    80105a2e <sys_fstat+0x3b>
    return -1;
80105a27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2c:	eb 13                	jmp    80105a41 <sys_fstat+0x4e>
  return filestat(f, st);
80105a2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a34:	83 ec 08             	sub    $0x8,%esp
80105a37:	52                   	push   %edx
80105a38:	50                   	push   %eax
80105a39:	e8 45 b7 ff ff       	call   80101183 <filestat>
80105a3e:	83 c4 10             	add    $0x10,%esp
}
80105a41:	c9                   	leave  
80105a42:	c3                   	ret    

80105a43 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105a43:	55                   	push   %ebp
80105a44:	89 e5                	mov    %esp,%ebp
80105a46:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a49:	83 ec 08             	sub    $0x8,%esp
80105a4c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a4f:	50                   	push   %eax
80105a50:	6a 00                	push   $0x0
80105a52:	e8 a9 fc ff ff       	call   80105700 <argstr>
80105a57:	83 c4 10             	add    $0x10,%esp
80105a5a:	85 c0                	test   %eax,%eax
80105a5c:	78 15                	js     80105a73 <sys_link+0x30>
80105a5e:	83 ec 08             	sub    $0x8,%esp
80105a61:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a64:	50                   	push   %eax
80105a65:	6a 01                	push   $0x1
80105a67:	e8 94 fc ff ff       	call   80105700 <argstr>
80105a6c:	83 c4 10             	add    $0x10,%esp
80105a6f:	85 c0                	test   %eax,%eax
80105a71:	79 0a                	jns    80105a7d <sys_link+0x3a>
    return -1;
80105a73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a78:	e9 68 01 00 00       	jmp    80105be5 <sys_link+0x1a2>

  begin_op();
80105a7d:	e8 9e da ff ff       	call   80103520 <begin_op>
  if((ip = namei(old)) == 0){
80105a82:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a85:	83 ec 0c             	sub    $0xc,%esp
80105a88:	50                   	push   %eax
80105a89:	e8 8f ca ff ff       	call   8010251d <namei>
80105a8e:	83 c4 10             	add    $0x10,%esp
80105a91:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a98:	75 0f                	jne    80105aa9 <sys_link+0x66>
    end_op();
80105a9a:	e8 0d db ff ff       	call   801035ac <end_op>
    return -1;
80105a9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa4:	e9 3c 01 00 00       	jmp    80105be5 <sys_link+0x1a2>
  }

  ilock(ip);
80105aa9:	83 ec 0c             	sub    $0xc,%esp
80105aac:	ff 75 f4             	push   -0xc(%ebp)
80105aaf:	e8 36 bf ff ff       	call   801019ea <ilock>
80105ab4:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aba:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105abe:	66 83 f8 01          	cmp    $0x1,%ax
80105ac2:	75 1d                	jne    80105ae1 <sys_link+0x9e>
    iunlockput(ip);
80105ac4:	83 ec 0c             	sub    $0xc,%esp
80105ac7:	ff 75 f4             	push   -0xc(%ebp)
80105aca:	e8 4c c1 ff ff       	call   80101c1b <iunlockput>
80105acf:	83 c4 10             	add    $0x10,%esp
    end_op();
80105ad2:	e8 d5 da ff ff       	call   801035ac <end_op>
    return -1;
80105ad7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adc:	e9 04 01 00 00       	jmp    80105be5 <sys_link+0x1a2>
  }

  ip->nlink++;
80105ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ae8:	83 c0 01             	add    $0x1,%eax
80105aeb:	89 c2                	mov    %eax,%edx
80105aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af0:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105af4:	83 ec 0c             	sub    $0xc,%esp
80105af7:	ff 75 f4             	push   -0xc(%ebp)
80105afa:	e8 0e bd ff ff       	call   8010180d <iupdate>
80105aff:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105b02:	83 ec 0c             	sub    $0xc,%esp
80105b05:	ff 75 f4             	push   -0xc(%ebp)
80105b08:	e8 f0 bf ff ff       	call   80101afd <iunlock>
80105b0d:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105b10:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b13:	83 ec 08             	sub    $0x8,%esp
80105b16:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b19:	52                   	push   %edx
80105b1a:	50                   	push   %eax
80105b1b:	e8 19 ca ff ff       	call   80102539 <nameiparent>
80105b20:	83 c4 10             	add    $0x10,%esp
80105b23:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b2a:	74 71                	je     80105b9d <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105b2c:	83 ec 0c             	sub    $0xc,%esp
80105b2f:	ff 75 f0             	push   -0x10(%ebp)
80105b32:	e8 b3 be ff ff       	call   801019ea <ilock>
80105b37:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3d:	8b 10                	mov    (%eax),%edx
80105b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b42:	8b 00                	mov    (%eax),%eax
80105b44:	39 c2                	cmp    %eax,%edx
80105b46:	75 1d                	jne    80105b65 <sys_link+0x122>
80105b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b4b:	8b 40 04             	mov    0x4(%eax),%eax
80105b4e:	83 ec 04             	sub    $0x4,%esp
80105b51:	50                   	push   %eax
80105b52:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b55:	50                   	push   %eax
80105b56:	ff 75 f0             	push   -0x10(%ebp)
80105b59:	e8 28 c7 ff ff       	call   80102286 <dirlink>
80105b5e:	83 c4 10             	add    $0x10,%esp
80105b61:	85 c0                	test   %eax,%eax
80105b63:	79 10                	jns    80105b75 <sys_link+0x132>
    iunlockput(dp);
80105b65:	83 ec 0c             	sub    $0xc,%esp
80105b68:	ff 75 f0             	push   -0x10(%ebp)
80105b6b:	e8 ab c0 ff ff       	call   80101c1b <iunlockput>
80105b70:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b73:	eb 29                	jmp    80105b9e <sys_link+0x15b>
  }
  iunlockput(dp);
80105b75:	83 ec 0c             	sub    $0xc,%esp
80105b78:	ff 75 f0             	push   -0x10(%ebp)
80105b7b:	e8 9b c0 ff ff       	call   80101c1b <iunlockput>
80105b80:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b83:	83 ec 0c             	sub    $0xc,%esp
80105b86:	ff 75 f4             	push   -0xc(%ebp)
80105b89:	e8 bd bf ff ff       	call   80101b4b <iput>
80105b8e:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b91:	e8 16 da ff ff       	call   801035ac <end_op>

  return 0;
80105b96:	b8 00 00 00 00       	mov    $0x0,%eax
80105b9b:	eb 48                	jmp    80105be5 <sys_link+0x1a2>
    goto bad;
80105b9d:	90                   	nop

bad:
  ilock(ip);
80105b9e:	83 ec 0c             	sub    $0xc,%esp
80105ba1:	ff 75 f4             	push   -0xc(%ebp)
80105ba4:	e8 41 be ff ff       	call   801019ea <ilock>
80105ba9:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105baf:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105bb3:	83 e8 01             	sub    $0x1,%eax
80105bb6:	89 c2                	mov    %eax,%edx
80105bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbb:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105bbf:	83 ec 0c             	sub    $0xc,%esp
80105bc2:	ff 75 f4             	push   -0xc(%ebp)
80105bc5:	e8 43 bc ff ff       	call   8010180d <iupdate>
80105bca:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105bcd:	83 ec 0c             	sub    $0xc,%esp
80105bd0:	ff 75 f4             	push   -0xc(%ebp)
80105bd3:	e8 43 c0 ff ff       	call   80101c1b <iunlockput>
80105bd8:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bdb:	e8 cc d9 ff ff       	call   801035ac <end_op>
  return -1;
80105be0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105be5:	c9                   	leave  
80105be6:	c3                   	ret    

80105be7 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105be7:	55                   	push   %ebp
80105be8:	89 e5                	mov    %esp,%ebp
80105bea:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bed:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105bf4:	eb 40                	jmp    80105c36 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf9:	6a 10                	push   $0x10
80105bfb:	50                   	push   %eax
80105bfc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105bff:	50                   	push   %eax
80105c00:	ff 75 08             	push   0x8(%ebp)
80105c03:	e8 ce c2 ff ff       	call   80101ed6 <readi>
80105c08:	83 c4 10             	add    $0x10,%esp
80105c0b:	83 f8 10             	cmp    $0x10,%eax
80105c0e:	74 0d                	je     80105c1d <isdirempty+0x36>
      panic("isdirempty: readi");
80105c10:	83 ec 0c             	sub    $0xc,%esp
80105c13:	68 87 af 10 80       	push   $0x8010af87
80105c18:	e8 8c a9 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105c1d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c21:	66 85 c0             	test   %ax,%ax
80105c24:	74 07                	je     80105c2d <isdirempty+0x46>
      return 0;
80105c26:	b8 00 00 00 00       	mov    $0x0,%eax
80105c2b:	eb 1b                	jmp    80105c48 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c30:	83 c0 10             	add    $0x10,%eax
80105c33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c36:	8b 45 08             	mov    0x8(%ebp),%eax
80105c39:	8b 50 58             	mov    0x58(%eax),%edx
80105c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3f:	39 c2                	cmp    %eax,%edx
80105c41:	77 b3                	ja     80105bf6 <isdirempty+0xf>
  }
  return 1;
80105c43:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c48:	c9                   	leave  
80105c49:	c3                   	ret    

80105c4a <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c4a:	55                   	push   %ebp
80105c4b:	89 e5                	mov    %esp,%ebp
80105c4d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c50:	83 ec 08             	sub    $0x8,%esp
80105c53:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c56:	50                   	push   %eax
80105c57:	6a 00                	push   $0x0
80105c59:	e8 a2 fa ff ff       	call   80105700 <argstr>
80105c5e:	83 c4 10             	add    $0x10,%esp
80105c61:	85 c0                	test   %eax,%eax
80105c63:	79 0a                	jns    80105c6f <sys_unlink+0x25>
    return -1;
80105c65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c6a:	e9 bf 01 00 00       	jmp    80105e2e <sys_unlink+0x1e4>

  begin_op();
80105c6f:	e8 ac d8 ff ff       	call   80103520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c74:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c77:	83 ec 08             	sub    $0x8,%esp
80105c7a:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c7d:	52                   	push   %edx
80105c7e:	50                   	push   %eax
80105c7f:	e8 b5 c8 ff ff       	call   80102539 <nameiparent>
80105c84:	83 c4 10             	add    $0x10,%esp
80105c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c8e:	75 0f                	jne    80105c9f <sys_unlink+0x55>
    end_op();
80105c90:	e8 17 d9 ff ff       	call   801035ac <end_op>
    return -1;
80105c95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9a:	e9 8f 01 00 00       	jmp    80105e2e <sys_unlink+0x1e4>
  }

  ilock(dp);
80105c9f:	83 ec 0c             	sub    $0xc,%esp
80105ca2:	ff 75 f4             	push   -0xc(%ebp)
80105ca5:	e8 40 bd ff ff       	call   801019ea <ilock>
80105caa:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105cad:	83 ec 08             	sub    $0x8,%esp
80105cb0:	68 99 af 10 80       	push   $0x8010af99
80105cb5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cb8:	50                   	push   %eax
80105cb9:	e8 f3 c4 ff ff       	call   801021b1 <namecmp>
80105cbe:	83 c4 10             	add    $0x10,%esp
80105cc1:	85 c0                	test   %eax,%eax
80105cc3:	0f 84 49 01 00 00    	je     80105e12 <sys_unlink+0x1c8>
80105cc9:	83 ec 08             	sub    $0x8,%esp
80105ccc:	68 9b af 10 80       	push   $0x8010af9b
80105cd1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cd4:	50                   	push   %eax
80105cd5:	e8 d7 c4 ff ff       	call   801021b1 <namecmp>
80105cda:	83 c4 10             	add    $0x10,%esp
80105cdd:	85 c0                	test   %eax,%eax
80105cdf:	0f 84 2d 01 00 00    	je     80105e12 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ce5:	83 ec 04             	sub    $0x4,%esp
80105ce8:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ceb:	50                   	push   %eax
80105cec:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cef:	50                   	push   %eax
80105cf0:	ff 75 f4             	push   -0xc(%ebp)
80105cf3:	e8 d4 c4 ff ff       	call   801021cc <dirlookup>
80105cf8:	83 c4 10             	add    $0x10,%esp
80105cfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cfe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d02:	0f 84 0d 01 00 00    	je     80105e15 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105d08:	83 ec 0c             	sub    $0xc,%esp
80105d0b:	ff 75 f0             	push   -0x10(%ebp)
80105d0e:	e8 d7 bc ff ff       	call   801019ea <ilock>
80105d13:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d19:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d1d:	66 85 c0             	test   %ax,%ax
80105d20:	7f 0d                	jg     80105d2f <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105d22:	83 ec 0c             	sub    $0xc,%esp
80105d25:	68 9e af 10 80       	push   $0x8010af9e
80105d2a:	e8 7a a8 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d32:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d36:	66 83 f8 01          	cmp    $0x1,%ax
80105d3a:	75 25                	jne    80105d61 <sys_unlink+0x117>
80105d3c:	83 ec 0c             	sub    $0xc,%esp
80105d3f:	ff 75 f0             	push   -0x10(%ebp)
80105d42:	e8 a0 fe ff ff       	call   80105be7 <isdirempty>
80105d47:	83 c4 10             	add    $0x10,%esp
80105d4a:	85 c0                	test   %eax,%eax
80105d4c:	75 13                	jne    80105d61 <sys_unlink+0x117>
    iunlockput(ip);
80105d4e:	83 ec 0c             	sub    $0xc,%esp
80105d51:	ff 75 f0             	push   -0x10(%ebp)
80105d54:	e8 c2 be ff ff       	call   80101c1b <iunlockput>
80105d59:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d5c:	e9 b5 00 00 00       	jmp    80105e16 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105d61:	83 ec 04             	sub    $0x4,%esp
80105d64:	6a 10                	push   $0x10
80105d66:	6a 00                	push   $0x0
80105d68:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d6b:	50                   	push   %eax
80105d6c:	e8 cf f5 ff ff       	call   80105340 <memset>
80105d71:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d74:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d77:	6a 10                	push   $0x10
80105d79:	50                   	push   %eax
80105d7a:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d7d:	50                   	push   %eax
80105d7e:	ff 75 f4             	push   -0xc(%ebp)
80105d81:	e8 a5 c2 ff ff       	call   8010202b <writei>
80105d86:	83 c4 10             	add    $0x10,%esp
80105d89:	83 f8 10             	cmp    $0x10,%eax
80105d8c:	74 0d                	je     80105d9b <sys_unlink+0x151>
    panic("unlink: writei");
80105d8e:	83 ec 0c             	sub    $0xc,%esp
80105d91:	68 b0 af 10 80       	push   $0x8010afb0
80105d96:	e8 0e a8 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105da2:	66 83 f8 01          	cmp    $0x1,%ax
80105da6:	75 21                	jne    80105dc9 <sys_unlink+0x17f>
    dp->nlink--;
80105da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dab:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105daf:	83 e8 01             	sub    $0x1,%eax
80105db2:	89 c2                	mov    %eax,%edx
80105db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db7:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105dbb:	83 ec 0c             	sub    $0xc,%esp
80105dbe:	ff 75 f4             	push   -0xc(%ebp)
80105dc1:	e8 47 ba ff ff       	call   8010180d <iupdate>
80105dc6:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105dc9:	83 ec 0c             	sub    $0xc,%esp
80105dcc:	ff 75 f4             	push   -0xc(%ebp)
80105dcf:	e8 47 be ff ff       	call   80101c1b <iunlockput>
80105dd4:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dda:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105dde:	83 e8 01             	sub    $0x1,%eax
80105de1:	89 c2                	mov    %eax,%edx
80105de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de6:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105dea:	83 ec 0c             	sub    $0xc,%esp
80105ded:	ff 75 f0             	push   -0x10(%ebp)
80105df0:	e8 18 ba ff ff       	call   8010180d <iupdate>
80105df5:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105df8:	83 ec 0c             	sub    $0xc,%esp
80105dfb:	ff 75 f0             	push   -0x10(%ebp)
80105dfe:	e8 18 be ff ff       	call   80101c1b <iunlockput>
80105e03:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e06:	e8 a1 d7 ff ff       	call   801035ac <end_op>

  return 0;
80105e0b:	b8 00 00 00 00       	mov    $0x0,%eax
80105e10:	eb 1c                	jmp    80105e2e <sys_unlink+0x1e4>
    goto bad;
80105e12:	90                   	nop
80105e13:	eb 01                	jmp    80105e16 <sys_unlink+0x1cc>
    goto bad;
80105e15:	90                   	nop

bad:
  iunlockput(dp);
80105e16:	83 ec 0c             	sub    $0xc,%esp
80105e19:	ff 75 f4             	push   -0xc(%ebp)
80105e1c:	e8 fa bd ff ff       	call   80101c1b <iunlockput>
80105e21:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e24:	e8 83 d7 ff ff       	call   801035ac <end_op>
  return -1;
80105e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e2e:	c9                   	leave  
80105e2f:	c3                   	ret    

80105e30 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e30:	55                   	push   %ebp
80105e31:	89 e5                	mov    %esp,%ebp
80105e33:	83 ec 38             	sub    $0x38,%esp
80105e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e39:	8b 55 10             	mov    0x10(%ebp),%edx
80105e3c:	8b 45 14             	mov    0x14(%ebp),%eax
80105e3f:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e43:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e47:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e4b:	83 ec 08             	sub    $0x8,%esp
80105e4e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e51:	50                   	push   %eax
80105e52:	ff 75 08             	push   0x8(%ebp)
80105e55:	e8 df c6 ff ff       	call   80102539 <nameiparent>
80105e5a:	83 c4 10             	add    $0x10,%esp
80105e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e64:	75 0a                	jne    80105e70 <create+0x40>
    return 0;
80105e66:	b8 00 00 00 00       	mov    $0x0,%eax
80105e6b:	e9 90 01 00 00       	jmp    80106000 <create+0x1d0>
  ilock(dp);
80105e70:	83 ec 0c             	sub    $0xc,%esp
80105e73:	ff 75 f4             	push   -0xc(%ebp)
80105e76:	e8 6f bb ff ff       	call   801019ea <ilock>
80105e7b:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e7e:	83 ec 04             	sub    $0x4,%esp
80105e81:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e84:	50                   	push   %eax
80105e85:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e88:	50                   	push   %eax
80105e89:	ff 75 f4             	push   -0xc(%ebp)
80105e8c:	e8 3b c3 ff ff       	call   801021cc <dirlookup>
80105e91:	83 c4 10             	add    $0x10,%esp
80105e94:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e9b:	74 50                	je     80105eed <create+0xbd>
    iunlockput(dp);
80105e9d:	83 ec 0c             	sub    $0xc,%esp
80105ea0:	ff 75 f4             	push   -0xc(%ebp)
80105ea3:	e8 73 bd ff ff       	call   80101c1b <iunlockput>
80105ea8:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105eab:	83 ec 0c             	sub    $0xc,%esp
80105eae:	ff 75 f0             	push   -0x10(%ebp)
80105eb1:	e8 34 bb ff ff       	call   801019ea <ilock>
80105eb6:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105eb9:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ebe:	75 15                	jne    80105ed5 <create+0xa5>
80105ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ec7:	66 83 f8 02          	cmp    $0x2,%ax
80105ecb:	75 08                	jne    80105ed5 <create+0xa5>
      return ip;
80105ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed0:	e9 2b 01 00 00       	jmp    80106000 <create+0x1d0>
    iunlockput(ip);
80105ed5:	83 ec 0c             	sub    $0xc,%esp
80105ed8:	ff 75 f0             	push   -0x10(%ebp)
80105edb:	e8 3b bd ff ff       	call   80101c1b <iunlockput>
80105ee0:	83 c4 10             	add    $0x10,%esp
    return 0;
80105ee3:	b8 00 00 00 00       	mov    $0x0,%eax
80105ee8:	e9 13 01 00 00       	jmp    80106000 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105eed:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef4:	8b 00                	mov    (%eax),%eax
80105ef6:	83 ec 08             	sub    $0x8,%esp
80105ef9:	52                   	push   %edx
80105efa:	50                   	push   %eax
80105efb:	e8 36 b8 ff ff       	call   80101736 <ialloc>
80105f00:	83 c4 10             	add    $0x10,%esp
80105f03:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f06:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f0a:	75 0d                	jne    80105f19 <create+0xe9>
    panic("create: ialloc");
80105f0c:	83 ec 0c             	sub    $0xc,%esp
80105f0f:	68 bf af 10 80       	push   $0x8010afbf
80105f14:	e8 90 a6 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105f19:	83 ec 0c             	sub    $0xc,%esp
80105f1c:	ff 75 f0             	push   -0x10(%ebp)
80105f1f:	e8 c6 ba ff ff       	call   801019ea <ilock>
80105f24:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f2e:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f35:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f39:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f40:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105f46:	83 ec 0c             	sub    $0xc,%esp
80105f49:	ff 75 f0             	push   -0x10(%ebp)
80105f4c:	e8 bc b8 ff ff       	call   8010180d <iupdate>
80105f51:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105f54:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f59:	75 6a                	jne    80105fc5 <create+0x195>
    dp->nlink++;  // for ".."
80105f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f62:	83 c0 01             	add    $0x1,%eax
80105f65:	89 c2                	mov    %eax,%edx
80105f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f6a:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105f6e:	83 ec 0c             	sub    $0xc,%esp
80105f71:	ff 75 f4             	push   -0xc(%ebp)
80105f74:	e8 94 b8 ff ff       	call   8010180d <iupdate>
80105f79:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7f:	8b 40 04             	mov    0x4(%eax),%eax
80105f82:	83 ec 04             	sub    $0x4,%esp
80105f85:	50                   	push   %eax
80105f86:	68 99 af 10 80       	push   $0x8010af99
80105f8b:	ff 75 f0             	push   -0x10(%ebp)
80105f8e:	e8 f3 c2 ff ff       	call   80102286 <dirlink>
80105f93:	83 c4 10             	add    $0x10,%esp
80105f96:	85 c0                	test   %eax,%eax
80105f98:	78 1e                	js     80105fb8 <create+0x188>
80105f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9d:	8b 40 04             	mov    0x4(%eax),%eax
80105fa0:	83 ec 04             	sub    $0x4,%esp
80105fa3:	50                   	push   %eax
80105fa4:	68 9b af 10 80       	push   $0x8010af9b
80105fa9:	ff 75 f0             	push   -0x10(%ebp)
80105fac:	e8 d5 c2 ff ff       	call   80102286 <dirlink>
80105fb1:	83 c4 10             	add    $0x10,%esp
80105fb4:	85 c0                	test   %eax,%eax
80105fb6:	79 0d                	jns    80105fc5 <create+0x195>
      panic("create dots");
80105fb8:	83 ec 0c             	sub    $0xc,%esp
80105fbb:	68 ce af 10 80       	push   $0x8010afce
80105fc0:	e8 e4 a5 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc8:	8b 40 04             	mov    0x4(%eax),%eax
80105fcb:	83 ec 04             	sub    $0x4,%esp
80105fce:	50                   	push   %eax
80105fcf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fd2:	50                   	push   %eax
80105fd3:	ff 75 f4             	push   -0xc(%ebp)
80105fd6:	e8 ab c2 ff ff       	call   80102286 <dirlink>
80105fdb:	83 c4 10             	add    $0x10,%esp
80105fde:	85 c0                	test   %eax,%eax
80105fe0:	79 0d                	jns    80105fef <create+0x1bf>
    panic("create: dirlink");
80105fe2:	83 ec 0c             	sub    $0xc,%esp
80105fe5:	68 da af 10 80       	push   $0x8010afda
80105fea:	e8 ba a5 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105fef:	83 ec 0c             	sub    $0xc,%esp
80105ff2:	ff 75 f4             	push   -0xc(%ebp)
80105ff5:	e8 21 bc ff ff       	call   80101c1b <iunlockput>
80105ffa:	83 c4 10             	add    $0x10,%esp

  return ip;
80105ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106000:	c9                   	leave  
80106001:	c3                   	ret    

80106002 <sys_open>:

int
sys_open(void)
{
80106002:	55                   	push   %ebp
80106003:	89 e5                	mov    %esp,%ebp
80106005:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106008:	83 ec 08             	sub    $0x8,%esp
8010600b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010600e:	50                   	push   %eax
8010600f:	6a 00                	push   $0x0
80106011:	e8 ea f6 ff ff       	call   80105700 <argstr>
80106016:	83 c4 10             	add    $0x10,%esp
80106019:	85 c0                	test   %eax,%eax
8010601b:	78 15                	js     80106032 <sys_open+0x30>
8010601d:	83 ec 08             	sub    $0x8,%esp
80106020:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106023:	50                   	push   %eax
80106024:	6a 01                	push   $0x1
80106026:	e8 40 f6 ff ff       	call   8010566b <argint>
8010602b:	83 c4 10             	add    $0x10,%esp
8010602e:	85 c0                	test   %eax,%eax
80106030:	79 0a                	jns    8010603c <sys_open+0x3a>
    return -1;
80106032:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106037:	e9 61 01 00 00       	jmp    8010619d <sys_open+0x19b>

  begin_op();
8010603c:	e8 df d4 ff ff       	call   80103520 <begin_op>

  if(omode & O_CREATE){
80106041:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106044:	25 00 02 00 00       	and    $0x200,%eax
80106049:	85 c0                	test   %eax,%eax
8010604b:	74 2a                	je     80106077 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
8010604d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106050:	6a 00                	push   $0x0
80106052:	6a 00                	push   $0x0
80106054:	6a 02                	push   $0x2
80106056:	50                   	push   %eax
80106057:	e8 d4 fd ff ff       	call   80105e30 <create>
8010605c:	83 c4 10             	add    $0x10,%esp
8010605f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106062:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106066:	75 75                	jne    801060dd <sys_open+0xdb>
      end_op();
80106068:	e8 3f d5 ff ff       	call   801035ac <end_op>
      return -1;
8010606d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106072:	e9 26 01 00 00       	jmp    8010619d <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106077:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010607a:	83 ec 0c             	sub    $0xc,%esp
8010607d:	50                   	push   %eax
8010607e:	e8 9a c4 ff ff       	call   8010251d <namei>
80106083:	83 c4 10             	add    $0x10,%esp
80106086:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106089:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010608d:	75 0f                	jne    8010609e <sys_open+0x9c>
      end_op();
8010608f:	e8 18 d5 ff ff       	call   801035ac <end_op>
      return -1;
80106094:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106099:	e9 ff 00 00 00       	jmp    8010619d <sys_open+0x19b>
    }
    ilock(ip);
8010609e:	83 ec 0c             	sub    $0xc,%esp
801060a1:	ff 75 f4             	push   -0xc(%ebp)
801060a4:	e8 41 b9 ff ff       	call   801019ea <ilock>
801060a9:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801060ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060af:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801060b3:	66 83 f8 01          	cmp    $0x1,%ax
801060b7:	75 24                	jne    801060dd <sys_open+0xdb>
801060b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060bc:	85 c0                	test   %eax,%eax
801060be:	74 1d                	je     801060dd <sys_open+0xdb>
      iunlockput(ip);
801060c0:	83 ec 0c             	sub    $0xc,%esp
801060c3:	ff 75 f4             	push   -0xc(%ebp)
801060c6:	e8 50 bb ff ff       	call   80101c1b <iunlockput>
801060cb:	83 c4 10             	add    $0x10,%esp
      end_op();
801060ce:	e8 d9 d4 ff ff       	call   801035ac <end_op>
      return -1;
801060d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d8:	e9 c0 00 00 00       	jmp    8010619d <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801060dd:	e8 fb ae ff ff       	call   80100fdd <filealloc>
801060e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060e9:	74 17                	je     80106102 <sys_open+0x100>
801060eb:	83 ec 0c             	sub    $0xc,%esp
801060ee:	ff 75 f0             	push   -0x10(%ebp)
801060f1:	e8 33 f7 ff ff       	call   80105829 <fdalloc>
801060f6:	83 c4 10             	add    $0x10,%esp
801060f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801060fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106100:	79 2e                	jns    80106130 <sys_open+0x12e>
    if(f)
80106102:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106106:	74 0e                	je     80106116 <sys_open+0x114>
      fileclose(f);
80106108:	83 ec 0c             	sub    $0xc,%esp
8010610b:	ff 75 f0             	push   -0x10(%ebp)
8010610e:	e8 88 af ff ff       	call   8010109b <fileclose>
80106113:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106116:	83 ec 0c             	sub    $0xc,%esp
80106119:	ff 75 f4             	push   -0xc(%ebp)
8010611c:	e8 fa ba ff ff       	call   80101c1b <iunlockput>
80106121:	83 c4 10             	add    $0x10,%esp
    end_op();
80106124:	e8 83 d4 ff ff       	call   801035ac <end_op>
    return -1;
80106129:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612e:	eb 6d                	jmp    8010619d <sys_open+0x19b>
  }
  iunlock(ip);
80106130:	83 ec 0c             	sub    $0xc,%esp
80106133:	ff 75 f4             	push   -0xc(%ebp)
80106136:	e8 c2 b9 ff ff       	call   80101afd <iunlock>
8010613b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010613e:	e8 69 d4 ff ff       	call   801035ac <end_op>

  f->type = FD_INODE;
80106143:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106146:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010614c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010614f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106152:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106155:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106158:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010615f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106162:	83 e0 01             	and    $0x1,%eax
80106165:	85 c0                	test   %eax,%eax
80106167:	0f 94 c0             	sete   %al
8010616a:	89 c2                	mov    %eax,%edx
8010616c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106172:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106175:	83 e0 01             	and    $0x1,%eax
80106178:	85 c0                	test   %eax,%eax
8010617a:	75 0a                	jne    80106186 <sys_open+0x184>
8010617c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010617f:	83 e0 02             	and    $0x2,%eax
80106182:	85 c0                	test   %eax,%eax
80106184:	74 07                	je     8010618d <sys_open+0x18b>
80106186:	b8 01 00 00 00       	mov    $0x1,%eax
8010618b:	eb 05                	jmp    80106192 <sys_open+0x190>
8010618d:	b8 00 00 00 00       	mov    $0x0,%eax
80106192:	89 c2                	mov    %eax,%edx
80106194:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106197:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010619a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010619d:	c9                   	leave  
8010619e:	c3                   	ret    

8010619f <sys_mkdir>:

int
sys_mkdir(void)
{
8010619f:	55                   	push   %ebp
801061a0:	89 e5                	mov    %esp,%ebp
801061a2:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801061a5:	e8 76 d3 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801061aa:	83 ec 08             	sub    $0x8,%esp
801061ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061b0:	50                   	push   %eax
801061b1:	6a 00                	push   $0x0
801061b3:	e8 48 f5 ff ff       	call   80105700 <argstr>
801061b8:	83 c4 10             	add    $0x10,%esp
801061bb:	85 c0                	test   %eax,%eax
801061bd:	78 1b                	js     801061da <sys_mkdir+0x3b>
801061bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c2:	6a 00                	push   $0x0
801061c4:	6a 00                	push   $0x0
801061c6:	6a 01                	push   $0x1
801061c8:	50                   	push   %eax
801061c9:	e8 62 fc ff ff       	call   80105e30 <create>
801061ce:	83 c4 10             	add    $0x10,%esp
801061d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061d8:	75 0c                	jne    801061e6 <sys_mkdir+0x47>
    end_op();
801061da:	e8 cd d3 ff ff       	call   801035ac <end_op>
    return -1;
801061df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e4:	eb 18                	jmp    801061fe <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801061e6:	83 ec 0c             	sub    $0xc,%esp
801061e9:	ff 75 f4             	push   -0xc(%ebp)
801061ec:	e8 2a ba ff ff       	call   80101c1b <iunlockput>
801061f1:	83 c4 10             	add    $0x10,%esp
  end_op();
801061f4:	e8 b3 d3 ff ff       	call   801035ac <end_op>
  return 0;
801061f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061fe:	c9                   	leave  
801061ff:	c3                   	ret    

80106200 <sys_mknod>:

int
sys_mknod(void)
{
80106200:	55                   	push   %ebp
80106201:	89 e5                	mov    %esp,%ebp
80106203:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106206:	e8 15 d3 ff ff       	call   80103520 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010620b:	83 ec 08             	sub    $0x8,%esp
8010620e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106211:	50                   	push   %eax
80106212:	6a 00                	push   $0x0
80106214:	e8 e7 f4 ff ff       	call   80105700 <argstr>
80106219:	83 c4 10             	add    $0x10,%esp
8010621c:	85 c0                	test   %eax,%eax
8010621e:	78 4f                	js     8010626f <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106220:	83 ec 08             	sub    $0x8,%esp
80106223:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106226:	50                   	push   %eax
80106227:	6a 01                	push   $0x1
80106229:	e8 3d f4 ff ff       	call   8010566b <argint>
8010622e:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106231:	85 c0                	test   %eax,%eax
80106233:	78 3a                	js     8010626f <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80106235:	83 ec 08             	sub    $0x8,%esp
80106238:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010623b:	50                   	push   %eax
8010623c:	6a 02                	push   $0x2
8010623e:	e8 28 f4 ff ff       	call   8010566b <argint>
80106243:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106246:	85 c0                	test   %eax,%eax
80106248:	78 25                	js     8010626f <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010624a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010624d:	0f bf c8             	movswl %ax,%ecx
80106250:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106253:	0f bf d0             	movswl %ax,%edx
80106256:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106259:	51                   	push   %ecx
8010625a:	52                   	push   %edx
8010625b:	6a 03                	push   $0x3
8010625d:	50                   	push   %eax
8010625e:	e8 cd fb ff ff       	call   80105e30 <create>
80106263:	83 c4 10             	add    $0x10,%esp
80106266:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106269:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010626d:	75 0c                	jne    8010627b <sys_mknod+0x7b>
    end_op();
8010626f:	e8 38 d3 ff ff       	call   801035ac <end_op>
    return -1;
80106274:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106279:	eb 18                	jmp    80106293 <sys_mknod+0x93>
  }
  iunlockput(ip);
8010627b:	83 ec 0c             	sub    $0xc,%esp
8010627e:	ff 75 f4             	push   -0xc(%ebp)
80106281:	e8 95 b9 ff ff       	call   80101c1b <iunlockput>
80106286:	83 c4 10             	add    $0x10,%esp
  end_op();
80106289:	e8 1e d3 ff ff       	call   801035ac <end_op>
  return 0;
8010628e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106293:	c9                   	leave  
80106294:	c3                   	ret    

80106295 <sys_chdir>:

int
sys_chdir(void)
{
80106295:	55                   	push   %ebp
80106296:	89 e5                	mov    %esp,%ebp
80106298:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010629b:	e8 a2 dc ff ff       	call   80103f42 <myproc>
801062a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801062a3:	e8 78 d2 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062a8:	83 ec 08             	sub    $0x8,%esp
801062ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062ae:	50                   	push   %eax
801062af:	6a 00                	push   $0x0
801062b1:	e8 4a f4 ff ff       	call   80105700 <argstr>
801062b6:	83 c4 10             	add    $0x10,%esp
801062b9:	85 c0                	test   %eax,%eax
801062bb:	78 18                	js     801062d5 <sys_chdir+0x40>
801062bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062c0:	83 ec 0c             	sub    $0xc,%esp
801062c3:	50                   	push   %eax
801062c4:	e8 54 c2 ff ff       	call   8010251d <namei>
801062c9:	83 c4 10             	add    $0x10,%esp
801062cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062d3:	75 0c                	jne    801062e1 <sys_chdir+0x4c>
    end_op();
801062d5:	e8 d2 d2 ff ff       	call   801035ac <end_op>
    return -1;
801062da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062df:	eb 68                	jmp    80106349 <sys_chdir+0xb4>
  }
  ilock(ip);
801062e1:	83 ec 0c             	sub    $0xc,%esp
801062e4:	ff 75 f0             	push   -0x10(%ebp)
801062e7:	e8 fe b6 ff ff       	call   801019ea <ilock>
801062ec:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801062ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801062f6:	66 83 f8 01          	cmp    $0x1,%ax
801062fa:	74 1a                	je     80106316 <sys_chdir+0x81>
    iunlockput(ip);
801062fc:	83 ec 0c             	sub    $0xc,%esp
801062ff:	ff 75 f0             	push   -0x10(%ebp)
80106302:	e8 14 b9 ff ff       	call   80101c1b <iunlockput>
80106307:	83 c4 10             	add    $0x10,%esp
    end_op();
8010630a:	e8 9d d2 ff ff       	call   801035ac <end_op>
    return -1;
8010630f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106314:	eb 33                	jmp    80106349 <sys_chdir+0xb4>
  }
  iunlock(ip);
80106316:	83 ec 0c             	sub    $0xc,%esp
80106319:	ff 75 f0             	push   -0x10(%ebp)
8010631c:	e8 dc b7 ff ff       	call   80101afd <iunlock>
80106321:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106327:	8b 40 68             	mov    0x68(%eax),%eax
8010632a:	83 ec 0c             	sub    $0xc,%esp
8010632d:	50                   	push   %eax
8010632e:	e8 18 b8 ff ff       	call   80101b4b <iput>
80106333:	83 c4 10             	add    $0x10,%esp
  end_op();
80106336:	e8 71 d2 ff ff       	call   801035ac <end_op>
  curproc->cwd = ip;
8010633b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106341:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106344:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106349:	c9                   	leave  
8010634a:	c3                   	ret    

8010634b <sys_exec>:

int
sys_exec(void)
{
8010634b:	55                   	push   %ebp
8010634c:	89 e5                	mov    %esp,%ebp
8010634e:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106354:	83 ec 08             	sub    $0x8,%esp
80106357:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010635a:	50                   	push   %eax
8010635b:	6a 00                	push   $0x0
8010635d:	e8 9e f3 ff ff       	call   80105700 <argstr>
80106362:	83 c4 10             	add    $0x10,%esp
80106365:	85 c0                	test   %eax,%eax
80106367:	78 18                	js     80106381 <sys_exec+0x36>
80106369:	83 ec 08             	sub    $0x8,%esp
8010636c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106372:	50                   	push   %eax
80106373:	6a 01                	push   $0x1
80106375:	e8 f1 f2 ff ff       	call   8010566b <argint>
8010637a:	83 c4 10             	add    $0x10,%esp
8010637d:	85 c0                	test   %eax,%eax
8010637f:	79 0a                	jns    8010638b <sys_exec+0x40>
    return -1;
80106381:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106386:	e9 c6 00 00 00       	jmp    80106451 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010638b:	83 ec 04             	sub    $0x4,%esp
8010638e:	68 80 00 00 00       	push   $0x80
80106393:	6a 00                	push   $0x0
80106395:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010639b:	50                   	push   %eax
8010639c:	e8 9f ef ff ff       	call   80105340 <memset>
801063a1:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801063a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ae:	83 f8 1f             	cmp    $0x1f,%eax
801063b1:	76 0a                	jbe    801063bd <sys_exec+0x72>
      return -1;
801063b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b8:	e9 94 00 00 00       	jmp    80106451 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801063bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c0:	c1 e0 02             	shl    $0x2,%eax
801063c3:	89 c2                	mov    %eax,%edx
801063c5:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063cb:	01 c2                	add    %eax,%edx
801063cd:	83 ec 08             	sub    $0x8,%esp
801063d0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801063d6:	50                   	push   %eax
801063d7:	52                   	push   %edx
801063d8:	e8 ed f1 ff ff       	call   801055ca <fetchint>
801063dd:	83 c4 10             	add    $0x10,%esp
801063e0:	85 c0                	test   %eax,%eax
801063e2:	79 07                	jns    801063eb <sys_exec+0xa0>
      return -1;
801063e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e9:	eb 66                	jmp    80106451 <sys_exec+0x106>
    if(uarg == 0){
801063eb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063f1:	85 c0                	test   %eax,%eax
801063f3:	75 27                	jne    8010641c <sys_exec+0xd1>
      argv[i] = 0;
801063f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801063ff:	00 00 00 00 
      break;
80106403:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106404:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106407:	83 ec 08             	sub    $0x8,%esp
8010640a:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106410:	52                   	push   %edx
80106411:	50                   	push   %eax
80106412:	e8 69 a7 ff ff       	call   80100b80 <exec>
80106417:	83 c4 10             	add    $0x10,%esp
8010641a:	eb 35                	jmp    80106451 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
8010641c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106425:	c1 e0 02             	shl    $0x2,%eax
80106428:	01 c2                	add    %eax,%edx
8010642a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106430:	83 ec 08             	sub    $0x8,%esp
80106433:	52                   	push   %edx
80106434:	50                   	push   %eax
80106435:	e8 cf f1 ff ff       	call   80105609 <fetchstr>
8010643a:	83 c4 10             	add    $0x10,%esp
8010643d:	85 c0                	test   %eax,%eax
8010643f:	79 07                	jns    80106448 <sys_exec+0xfd>
      return -1;
80106441:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106446:	eb 09                	jmp    80106451 <sys_exec+0x106>
  for(i=0;; i++){
80106448:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
8010644c:	e9 5a ff ff ff       	jmp    801063ab <sys_exec+0x60>
}
80106451:	c9                   	leave  
80106452:	c3                   	ret    

80106453 <sys_pipe>:

int
sys_pipe(void)
{
80106453:	55                   	push   %ebp
80106454:	89 e5                	mov    %esp,%ebp
80106456:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106459:	83 ec 04             	sub    $0x4,%esp
8010645c:	6a 08                	push   $0x8
8010645e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106461:	50                   	push   %eax
80106462:	6a 00                	push   $0x0
80106464:	e8 2f f2 ff ff       	call   80105698 <argptr>
80106469:	83 c4 10             	add    $0x10,%esp
8010646c:	85 c0                	test   %eax,%eax
8010646e:	79 0a                	jns    8010647a <sys_pipe+0x27>
    return -1;
80106470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106475:	e9 ae 00 00 00       	jmp    80106528 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
8010647a:	83 ec 08             	sub    $0x8,%esp
8010647d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106480:	50                   	push   %eax
80106481:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106484:	50                   	push   %eax
80106485:	e8 c7 d5 ff ff       	call   80103a51 <pipealloc>
8010648a:	83 c4 10             	add    $0x10,%esp
8010648d:	85 c0                	test   %eax,%eax
8010648f:	79 0a                	jns    8010649b <sys_pipe+0x48>
    return -1;
80106491:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106496:	e9 8d 00 00 00       	jmp    80106528 <sys_pipe+0xd5>
  fd0 = -1;
8010649b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064a5:	83 ec 0c             	sub    $0xc,%esp
801064a8:	50                   	push   %eax
801064a9:	e8 7b f3 ff ff       	call   80105829 <fdalloc>
801064ae:	83 c4 10             	add    $0x10,%esp
801064b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064b8:	78 18                	js     801064d2 <sys_pipe+0x7f>
801064ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064bd:	83 ec 0c             	sub    $0xc,%esp
801064c0:	50                   	push   %eax
801064c1:	e8 63 f3 ff ff       	call   80105829 <fdalloc>
801064c6:	83 c4 10             	add    $0x10,%esp
801064c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064d0:	79 3e                	jns    80106510 <sys_pipe+0xbd>
    if(fd0 >= 0)
801064d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064d6:	78 13                	js     801064eb <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
801064d8:	e8 65 da ff ff       	call   80103f42 <myproc>
801064dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064e0:	83 c2 08             	add    $0x8,%edx
801064e3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064ea:	00 
    fileclose(rf);
801064eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ee:	83 ec 0c             	sub    $0xc,%esp
801064f1:	50                   	push   %eax
801064f2:	e8 a4 ab ff ff       	call   8010109b <fileclose>
801064f7:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801064fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064fd:	83 ec 0c             	sub    $0xc,%esp
80106500:	50                   	push   %eax
80106501:	e8 95 ab ff ff       	call   8010109b <fileclose>
80106506:	83 c4 10             	add    $0x10,%esp
    return -1;
80106509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650e:	eb 18                	jmp    80106528 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106510:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106513:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106516:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106518:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010651b:	8d 50 04             	lea    0x4(%eax),%edx
8010651e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106521:	89 02                	mov    %eax,(%edx)
  return 0;
80106523:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106528:	c9                   	leave  
80106529:	c3                   	ret    

8010652a <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
8010652a:	55                   	push   %ebp
8010652b:	89 e5                	mov    %esp,%ebp
8010652d:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106530:	e8 6f dd ff ff       	call   801042a4 <fork>
}
80106535:	c9                   	leave  
80106536:	c3                   	ret    

80106537 <sys_exit>:

int
sys_exit(void)
{
80106537:	55                   	push   %ebp
80106538:	89 e5                	mov    %esp,%ebp
8010653a:	83 ec 08             	sub    $0x8,%esp
  exit();
8010653d:	e8 f8 de ff ff       	call   8010443a <exit>
  return 0;  // not reached
80106542:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106547:	c9                   	leave  
80106548:	c3                   	ret    

80106549 <sys_wait>:

int
sys_wait(void)
{
80106549:	55                   	push   %ebp
8010654a:	89 e5                	mov    %esp,%ebp
8010654c:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010654f:	e8 09 e0 ff ff       	call   8010455d <wait>
}
80106554:	c9                   	leave  
80106555:	c3                   	ret    

80106556 <sys_kill>:

int
sys_kill(void)
{
80106556:	55                   	push   %ebp
80106557:	89 e5                	mov    %esp,%ebp
80106559:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010655c:	83 ec 08             	sub    $0x8,%esp
8010655f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106562:	50                   	push   %eax
80106563:	6a 00                	push   $0x0
80106565:	e8 01 f1 ff ff       	call   8010566b <argint>
8010656a:	83 c4 10             	add    $0x10,%esp
8010656d:	85 c0                	test   %eax,%eax
8010656f:	79 07                	jns    80106578 <sys_kill+0x22>
    return -1;
80106571:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106576:	eb 0f                	jmp    80106587 <sys_kill+0x31>
  return kill(pid);
80106578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657b:	83 ec 0c             	sub    $0xc,%esp
8010657e:	50                   	push   %eax
8010657f:	e8 e2 e5 ff ff       	call   80104b66 <kill>
80106584:	83 c4 10             	add    $0x10,%esp
}
80106587:	c9                   	leave  
80106588:	c3                   	ret    

80106589 <sys_getpid>:

int
sys_getpid(void)
{
80106589:	55                   	push   %ebp
8010658a:	89 e5                	mov    %esp,%ebp
8010658c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010658f:	e8 ae d9 ff ff       	call   80103f42 <myproc>
80106594:	8b 40 10             	mov    0x10(%eax),%eax
}
80106597:	c9                   	leave  
80106598:	c3                   	ret    

80106599 <sys_sbrk>:

int
sys_sbrk(void)
{
80106599:	55                   	push   %ebp
8010659a:	89 e5                	mov    %esp,%ebp
8010659c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010659f:	83 ec 08             	sub    $0x8,%esp
801065a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065a5:	50                   	push   %eax
801065a6:	6a 00                	push   $0x0
801065a8:	e8 be f0 ff ff       	call   8010566b <argint>
801065ad:	83 c4 10             	add    $0x10,%esp
801065b0:	85 c0                	test   %eax,%eax
801065b2:	79 07                	jns    801065bb <sys_sbrk+0x22>
    return -1;
801065b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b9:	eb 27                	jmp    801065e2 <sys_sbrk+0x49>
  addr = myproc()->sz;
801065bb:	e8 82 d9 ff ff       	call   80103f42 <myproc>
801065c0:	8b 00                	mov    (%eax),%eax
801065c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c8:	83 ec 0c             	sub    $0xc,%esp
801065cb:	50                   	push   %eax
801065cc:	e8 38 dc ff ff       	call   80104209 <growproc>
801065d1:	83 c4 10             	add    $0x10,%esp
801065d4:	85 c0                	test   %eax,%eax
801065d6:	79 07                	jns    801065df <sys_sbrk+0x46>
    return -1;
801065d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065dd:	eb 03                	jmp    801065e2 <sys_sbrk+0x49>
  return addr;
801065df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065e2:	c9                   	leave  
801065e3:	c3                   	ret    

801065e4 <sys_sleep>:

int
sys_sleep(void)
{
801065e4:	55                   	push   %ebp
801065e5:	89 e5                	mov    %esp,%ebp
801065e7:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801065ea:	83 ec 08             	sub    $0x8,%esp
801065ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065f0:	50                   	push   %eax
801065f1:	6a 00                	push   $0x0
801065f3:	e8 73 f0 ff ff       	call   8010566b <argint>
801065f8:	83 c4 10             	add    $0x10,%esp
801065fb:	85 c0                	test   %eax,%eax
801065fd:	79 07                	jns    80106606 <sys_sleep+0x22>
    return -1;
801065ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106604:	eb 76                	jmp    8010667c <sys_sleep+0x98>
  acquire(&tickslock);
80106606:	83 ec 0c             	sub    $0xc,%esp
80106609:	68 c0 a6 11 80       	push   $0x8011a6c0
8010660e:	e8 b7 ea ff ff       	call   801050ca <acquire>
80106613:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106616:	a1 f4 a6 11 80       	mov    0x8011a6f4,%eax
8010661b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010661e:	eb 38                	jmp    80106658 <sys_sleep+0x74>
    if(myproc()->killed){
80106620:	e8 1d d9 ff ff       	call   80103f42 <myproc>
80106625:	8b 40 24             	mov    0x24(%eax),%eax
80106628:	85 c0                	test   %eax,%eax
8010662a:	74 17                	je     80106643 <sys_sleep+0x5f>
      release(&tickslock);
8010662c:	83 ec 0c             	sub    $0xc,%esp
8010662f:	68 c0 a6 11 80       	push   $0x8011a6c0
80106634:	e8 ff ea ff ff       	call   80105138 <release>
80106639:	83 c4 10             	add    $0x10,%esp
      return -1;
8010663c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106641:	eb 39                	jmp    8010667c <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106643:	83 ec 08             	sub    $0x8,%esp
80106646:	68 c0 a6 11 80       	push   $0x8011a6c0
8010664b:	68 f4 a6 11 80       	push   $0x8011a6f4
80106650:	e8 f0 e3 ff ff       	call   80104a45 <sleep>
80106655:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106658:	a1 f4 a6 11 80       	mov    0x8011a6f4,%eax
8010665d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106660:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106663:	39 d0                	cmp    %edx,%eax
80106665:	72 b9                	jb     80106620 <sys_sleep+0x3c>
  }
  release(&tickslock);
80106667:	83 ec 0c             	sub    $0xc,%esp
8010666a:	68 c0 a6 11 80       	push   $0x8011a6c0
8010666f:	e8 c4 ea ff ff       	call   80105138 <release>
80106674:	83 c4 10             	add    $0x10,%esp
  return 0;
80106677:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010667c:	c9                   	leave  
8010667d:	c3                   	ret    

8010667e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010667e:	55                   	push   %ebp
8010667f:	89 e5                	mov    %esp,%ebp
80106681:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106684:	83 ec 0c             	sub    $0xc,%esp
80106687:	68 c0 a6 11 80       	push   $0x8011a6c0
8010668c:	e8 39 ea ff ff       	call   801050ca <acquire>
80106691:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106694:	a1 f4 a6 11 80       	mov    0x8011a6f4,%eax
80106699:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010669c:	83 ec 0c             	sub    $0xc,%esp
8010669f:	68 c0 a6 11 80       	push   $0x8011a6c0
801066a4:	e8 8f ea ff ff       	call   80105138 <release>
801066a9:	83 c4 10             	add    $0x10,%esp
  return xticks;
801066ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066af:	c9                   	leave  
801066b0:	c3                   	ret    

801066b1 <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
801066b1:	55                   	push   %ebp
801066b2:	89 e5                	mov    %esp,%ebp
801066b4:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
801066b7:	83 ec 08             	sub    $0x8,%esp
801066ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066bd:	50                   	push   %eax
801066be:	6a 00                	push   $0x0
801066c0:	e8 a6 ef ff ff       	call   8010566b <argint>
801066c5:	83 c4 10             	add    $0x10,%esp
801066c8:	85 c0                	test   %eax,%eax
801066ca:	79 07                	jns    801066d3 <sys_setSchedPolicy+0x22>
    return -1;
801066cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066d1:	eb 0f                	jmp    801066e2 <sys_setSchedPolicy+0x31>
  return setSchedPolicy(policy);
801066d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d6:	83 ec 0c             	sub    $0xc,%esp
801066d9:	50                   	push   %eax
801066da:	e8 0c e7 ff ff       	call   80104deb <setSchedPolicy>
801066df:	83 c4 10             	add    $0x10,%esp
}
801066e2:	c9                   	leave  
801066e3:	c3                   	ret    

801066e4 <sys_getpinfo>:



int
sys_getpinfo(void)
{
801066e4:	55                   	push   %ebp
801066e5:	89 e5                	mov    %esp,%ebp
801066e7:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (void*)&ps, sizeof(*ps)) < 0 || ps ==0)
801066ea:	83 ec 04             	sub    $0x4,%esp
801066ed:	68 00 0c 00 00       	push   $0xc00
801066f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066f5:	50                   	push   %eax
801066f6:	6a 00                	push   $0x0
801066f8:	e8 9b ef ff ff       	call   80105698 <argptr>
801066fd:	83 c4 10             	add    $0x10,%esp
80106700:	85 c0                	test   %eax,%eax
80106702:	78 07                	js     8010670b <sys_getpinfo+0x27>
80106704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106707:	85 c0                	test   %eax,%eax
80106709:	75 07                	jne    80106712 <sys_getpinfo+0x2e>
    return -1;
8010670b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106710:	eb 0f                	jmp    80106721 <sys_getpinfo+0x3d>
  return getpinfo(ps);
80106712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106715:	83 ec 0c             	sub    $0xc,%esp
80106718:	50                   	push   %eax
80106719:	e8 05 e7 ff ff       	call   80104e23 <getpinfo>
8010671e:	83 c4 10             	add    $0x10,%esp
}
80106721:	c9                   	leave  
80106722:	c3                   	ret    

80106723 <sys_yield>:

int
sys_yield(void)
{
80106723:	55                   	push   %ebp
80106724:	89 e5                	mov    %esp,%ebp
80106726:	83 ec 08             	sub    $0x8,%esp
  yield();
80106729:	e8 91 e2 ff ff       	call   801049bf <yield>
  return 0;
8010672e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106733:	c9                   	leave  
80106734:	c3                   	ret    

80106735 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106735:	1e                   	push   %ds
  pushl %es
80106736:	06                   	push   %es
  pushl %fs
80106737:	0f a0                	push   %fs
  pushl %gs
80106739:	0f a8                	push   %gs
  pushal
8010673b:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010673c:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106740:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106742:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106744:	54                   	push   %esp
  call trap
80106745:	e8 d7 01 00 00       	call   80106921 <trap>
  addl $4, %esp
8010674a:	83 c4 04             	add    $0x4,%esp

8010674d <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010674d:	61                   	popa   
  popl %gs
8010674e:	0f a9                	pop    %gs
  popl %fs
80106750:	0f a1                	pop    %fs
  popl %es
80106752:	07                   	pop    %es
  popl %ds
80106753:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106754:	83 c4 08             	add    $0x8,%esp
  iret
80106757:	cf                   	iret   

80106758 <lidt>:
{
80106758:	55                   	push   %ebp
80106759:	89 e5                	mov    %esp,%ebp
8010675b:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010675e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106761:	83 e8 01             	sub    $0x1,%eax
80106764:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106768:	8b 45 08             	mov    0x8(%ebp),%eax
8010676b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010676f:	8b 45 08             	mov    0x8(%ebp),%eax
80106772:	c1 e8 10             	shr    $0x10,%eax
80106775:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106779:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010677c:	0f 01 18             	lidtl  (%eax)
}
8010677f:	90                   	nop
80106780:	c9                   	leave  
80106781:	c3                   	ret    

80106782 <rcr2>:

static inline uint
rcr2(void)
{
80106782:	55                   	push   %ebp
80106783:	89 e5                	mov    %esp,%ebp
80106785:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106788:	0f 20 d0             	mov    %cr2,%eax
8010678b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010678e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106791:	c9                   	leave  
80106792:	c3                   	ret    

80106793 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106793:	55                   	push   %ebp
80106794:	89 e5                	mov    %esp,%ebp
80106796:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106799:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067a0:	e9 c3 00 00 00       	jmp    80106868 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a8:	8b 04 85 a4 f0 10 80 	mov    -0x7fef0f5c(,%eax,4),%eax
801067af:	89 c2                	mov    %eax,%edx
801067b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b4:	66 89 14 c5 c0 9e 11 	mov    %dx,-0x7fee6140(,%eax,8)
801067bb:	80 
801067bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bf:	66 c7 04 c5 c2 9e 11 	movw   $0x8,-0x7fee613e(,%eax,8)
801067c6:	80 08 00 
801067c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067cc:	0f b6 14 c5 c4 9e 11 	movzbl -0x7fee613c(,%eax,8),%edx
801067d3:	80 
801067d4:	83 e2 e0             	and    $0xffffffe0,%edx
801067d7:	88 14 c5 c4 9e 11 80 	mov    %dl,-0x7fee613c(,%eax,8)
801067de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e1:	0f b6 14 c5 c4 9e 11 	movzbl -0x7fee613c(,%eax,8),%edx
801067e8:	80 
801067e9:	83 e2 1f             	and    $0x1f,%edx
801067ec:	88 14 c5 c4 9e 11 80 	mov    %dl,-0x7fee613c(,%eax,8)
801067f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f6:	0f b6 14 c5 c5 9e 11 	movzbl -0x7fee613b(,%eax,8),%edx
801067fd:	80 
801067fe:	83 e2 f0             	and    $0xfffffff0,%edx
80106801:	83 ca 0e             	or     $0xe,%edx
80106804:	88 14 c5 c5 9e 11 80 	mov    %dl,-0x7fee613b(,%eax,8)
8010680b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680e:	0f b6 14 c5 c5 9e 11 	movzbl -0x7fee613b(,%eax,8),%edx
80106815:	80 
80106816:	83 e2 ef             	and    $0xffffffef,%edx
80106819:	88 14 c5 c5 9e 11 80 	mov    %dl,-0x7fee613b(,%eax,8)
80106820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106823:	0f b6 14 c5 c5 9e 11 	movzbl -0x7fee613b(,%eax,8),%edx
8010682a:	80 
8010682b:	83 e2 9f             	and    $0xffffff9f,%edx
8010682e:	88 14 c5 c5 9e 11 80 	mov    %dl,-0x7fee613b(,%eax,8)
80106835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106838:	0f b6 14 c5 c5 9e 11 	movzbl -0x7fee613b(,%eax,8),%edx
8010683f:	80 
80106840:	83 ca 80             	or     $0xffffff80,%edx
80106843:	88 14 c5 c5 9e 11 80 	mov    %dl,-0x7fee613b(,%eax,8)
8010684a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684d:	8b 04 85 a4 f0 10 80 	mov    -0x7fef0f5c(,%eax,4),%eax
80106854:	c1 e8 10             	shr    $0x10,%eax
80106857:	89 c2                	mov    %eax,%edx
80106859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685c:	66 89 14 c5 c6 9e 11 	mov    %dx,-0x7fee613a(,%eax,8)
80106863:	80 
  for(i = 0; i < 256; i++)
80106864:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106868:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010686f:	0f 8e 30 ff ff ff    	jle    801067a5 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106875:	a1 a4 f1 10 80       	mov    0x8010f1a4,%eax
8010687a:	66 a3 c0 a0 11 80    	mov    %ax,0x8011a0c0
80106880:	66 c7 05 c2 a0 11 80 	movw   $0x8,0x8011a0c2
80106887:	08 00 
80106889:	0f b6 05 c4 a0 11 80 	movzbl 0x8011a0c4,%eax
80106890:	83 e0 e0             	and    $0xffffffe0,%eax
80106893:	a2 c4 a0 11 80       	mov    %al,0x8011a0c4
80106898:	0f b6 05 c4 a0 11 80 	movzbl 0x8011a0c4,%eax
8010689f:	83 e0 1f             	and    $0x1f,%eax
801068a2:	a2 c4 a0 11 80       	mov    %al,0x8011a0c4
801068a7:	0f b6 05 c5 a0 11 80 	movzbl 0x8011a0c5,%eax
801068ae:	83 c8 0f             	or     $0xf,%eax
801068b1:	a2 c5 a0 11 80       	mov    %al,0x8011a0c5
801068b6:	0f b6 05 c5 a0 11 80 	movzbl 0x8011a0c5,%eax
801068bd:	83 e0 ef             	and    $0xffffffef,%eax
801068c0:	a2 c5 a0 11 80       	mov    %al,0x8011a0c5
801068c5:	0f b6 05 c5 a0 11 80 	movzbl 0x8011a0c5,%eax
801068cc:	83 c8 60             	or     $0x60,%eax
801068cf:	a2 c5 a0 11 80       	mov    %al,0x8011a0c5
801068d4:	0f b6 05 c5 a0 11 80 	movzbl 0x8011a0c5,%eax
801068db:	83 c8 80             	or     $0xffffff80,%eax
801068de:	a2 c5 a0 11 80       	mov    %al,0x8011a0c5
801068e3:	a1 a4 f1 10 80       	mov    0x8010f1a4,%eax
801068e8:	c1 e8 10             	shr    $0x10,%eax
801068eb:	66 a3 c6 a0 11 80    	mov    %ax,0x8011a0c6

  initlock(&tickslock, "time");
801068f1:	83 ec 08             	sub    $0x8,%esp
801068f4:	68 ec af 10 80       	push   $0x8010afec
801068f9:	68 c0 a6 11 80       	push   $0x8011a6c0
801068fe:	e8 a5 e7 ff ff       	call   801050a8 <initlock>
80106903:	83 c4 10             	add    $0x10,%esp
}
80106906:	90                   	nop
80106907:	c9                   	leave  
80106908:	c3                   	ret    

80106909 <idtinit>:

void
idtinit(void)
{
80106909:	55                   	push   %ebp
8010690a:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010690c:	68 00 08 00 00       	push   $0x800
80106911:	68 c0 9e 11 80       	push   $0x80119ec0
80106916:	e8 3d fe ff ff       	call   80106758 <lidt>
8010691b:	83 c4 08             	add    $0x8,%esp
}
8010691e:	90                   	nop
8010691f:	c9                   	leave  
80106920:	c3                   	ret    

80106921 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106921:	55                   	push   %ebp
80106922:	89 e5                	mov    %esp,%ebp
80106924:	57                   	push   %edi
80106925:	56                   	push   %esi
80106926:	53                   	push   %ebx
80106927:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010692a:	8b 45 08             	mov    0x8(%ebp),%eax
8010692d:	8b 40 30             	mov    0x30(%eax),%eax
80106930:	83 f8 40             	cmp    $0x40,%eax
80106933:	75 3b                	jne    80106970 <trap+0x4f>
    if(myproc()->killed)
80106935:	e8 08 d6 ff ff       	call   80103f42 <myproc>
8010693a:	8b 40 24             	mov    0x24(%eax),%eax
8010693d:	85 c0                	test   %eax,%eax
8010693f:	74 05                	je     80106946 <trap+0x25>
      exit();
80106941:	e8 f4 da ff ff       	call   8010443a <exit>
    myproc()->tf = tf;
80106946:	e8 f7 d5 ff ff       	call   80103f42 <myproc>
8010694b:	8b 55 08             	mov    0x8(%ebp),%edx
8010694e:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106951:	e8 e1 ed ff ff       	call   80105737 <syscall>
    if(myproc()->killed)
80106956:	e8 e7 d5 ff ff       	call   80103f42 <myproc>
8010695b:	8b 40 24             	mov    0x24(%eax),%eax
8010695e:	85 c0                	test   %eax,%eax
80106960:	0f 84 32 04 00 00    	je     80106d98 <trap+0x477>
      exit();
80106966:	e8 cf da ff ff       	call   8010443a <exit>
    return;
8010696b:	e9 28 04 00 00       	jmp    80106d98 <trap+0x477>
  }

  switch(tf->trapno){
80106970:	8b 45 08             	mov    0x8(%ebp),%eax
80106973:	8b 40 30             	mov    0x30(%eax),%eax
80106976:	83 e8 20             	sub    $0x20,%eax
80106979:	83 f8 1f             	cmp    $0x1f,%eax
8010697c:	0f 87 33 03 00 00    	ja     80106cb5 <trap+0x394>
80106982:	8b 04 85 fc b0 10 80 	mov    -0x7fef4f04(,%eax,4),%eax
80106989:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010698b:	e8 1f d5 ff ff       	call   80103eaf <cpuid>
80106990:	85 c0                	test   %eax,%eax
80106992:	75 3d                	jne    801069d1 <trap+0xb0>
      acquire(&tickslock);
80106994:	83 ec 0c             	sub    $0xc,%esp
80106997:	68 c0 a6 11 80       	push   $0x8011a6c0
8010699c:	e8 29 e7 ff ff       	call   801050ca <acquire>
801069a1:	83 c4 10             	add    $0x10,%esp
      ticks++;
801069a4:	a1 f4 a6 11 80       	mov    0x8011a6f4,%eax
801069a9:	83 c0 01             	add    $0x1,%eax
801069ac:	a3 f4 a6 11 80       	mov    %eax,0x8011a6f4
      wakeup(&ticks);
801069b1:	83 ec 0c             	sub    $0xc,%esp
801069b4:	68 f4 a6 11 80       	push   $0x8011a6f4
801069b9:	e8 71 e1 ff ff       	call   80104b2f <wakeup>
801069be:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801069c1:	83 ec 0c             	sub    $0xc,%esp
801069c4:	68 c0 a6 11 80       	push   $0x8011a6c0
801069c9:	e8 6a e7 ff ff       	call   80105138 <release>
801069ce:	83 c4 10             	add    $0x10,%esp
    }
    // 현재 실행 중인 프로세스의 tick 증가
    struct proc *curproc = myproc();
801069d1:	e8 6c d5 ff ff       	call   80103f42 <myproc>
801069d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    int sched = mycpu()->sched_policy;
801069d9:	e8 ec d4 ff ff       	call   80103eca <mycpu>
801069de:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801069e4:	89 45 d8             	mov    %eax,-0x28(%ebp)

    acquire(&ptable.lock);
801069e7:	83 ec 0c             	sub    $0xc,%esp
801069ea:	68 40 72 11 80       	push   $0x80117240
801069ef:	e8 d6 e6 ff ff       	call   801050ca <acquire>
801069f4:	83 c4 10             	add    $0x10,%esp

    if (sched == 1 && curproc && curproc->state == RUNNING) {
801069f7:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
801069fb:	0f 85 13 02 00 00    	jne    80106c14 <trap+0x2f3>
80106a01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106a05:	0f 84 09 02 00 00    	je     80106c14 <trap+0x2f3>
80106a0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a0e:	8b 40 0c             	mov    0xc(%eax),%eax
80106a11:	83 f8 04             	cmp    $0x4,%eax
80106a14:	0f 85 fa 01 00 00    	jne    80106c14 <trap+0x2f3>
      int level = curproc->priority;
80106a1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a1d:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      if (level >= 0 && level <= 3) {
80106a23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80106a27:	78 45                	js     80106a6e <trap+0x14d>
80106a29:	83 7d d4 03          	cmpl   $0x3,-0x2c(%ebp)
80106a2d:	7f 3f                	jg     80106a6e <trap+0x14d>
        curproc->ticks[level]++;
80106a2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a32:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106a35:	83 c2 20             	add    $0x20,%edx
80106a38:	8b 04 90             	mov    (%eax,%edx,4),%eax
80106a3b:	8d 48 01             	lea    0x1(%eax),%ecx
80106a3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a41:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106a44:	83 c2 20             	add    $0x20,%edx
80106a47:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
        cprintf("[tick] pid %d Q%d ticks: %d\n", curproc->pid, level, curproc->ticks[level]);
80106a4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a4d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106a50:	83 c2 20             	add    $0x20,%edx
80106a53:	8b 14 90             	mov    (%eax,%edx,4),%edx
80106a56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a59:	8b 40 10             	mov    0x10(%eax),%eax
80106a5c:	52                   	push   %edx
80106a5d:	ff 75 d4             	push   -0x2c(%ebp)
80106a60:	50                   	push   %eax
80106a61:	68 f1 af 10 80       	push   $0x8010aff1
80106a66:	e8 89 99 ff ff       	call   801003f4 <cprintf>
80106a6b:	83 c4 10             	add    $0x10,%esp

      }
      //wait_ticks 증가
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106a6e:	c7 45 e4 74 72 11 80 	movl   $0x80117274,-0x1c(%ebp)
80106a75:	eb 4d                	jmp    80106ac4 <trap+0x1a3>
        if ( p == curproc || p -> state == RUNNABLE){
80106a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a7a:	3b 45 dc             	cmp    -0x24(%ebp),%eax
80106a7d:	74 3d                	je     80106abc <trap+0x19b>
80106a7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a82:	8b 40 0c             	mov    0xc(%eax),%eax
80106a85:	83 f8 03             	cmp    $0x3,%eax
80106a88:	74 32                	je     80106abc <trap+0x19b>
          continue;
        }
        int plevel = p->priority;
80106a8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a8d:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a90:	89 45 cc             	mov    %eax,-0x34(%ebp)
        if (plevel >=0 && plevel <=3){
80106a93:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80106a97:	78 24                	js     80106abd <trap+0x19c>
80106a99:	83 7d cc 03          	cmpl   $0x3,-0x34(%ebp)
80106a9d:	7f 1e                	jg     80106abd <trap+0x19c>
            p->wait_ticks[level]++;
80106a9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106aa2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106aa5:	83 c2 24             	add    $0x24,%edx
80106aa8:	8b 04 90             	mov    (%eax,%edx,4),%eax
80106aab:	8d 48 01             	lea    0x1(%eax),%ecx
80106aae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ab1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106ab4:	83 c2 24             	add    $0x24,%edx
80106ab7:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
80106aba:	eb 01                	jmp    80106abd <trap+0x19c>
          continue;
80106abc:	90                   	nop
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106abd:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
80106ac4:	81 7d e4 74 9a 11 80 	cmpl   $0x80119a74,-0x1c(%ebp)
80106acb:	72 aa                	jb     80106a77 <trap+0x156>
        }
      }
      //boost check
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106acd:	c7 45 e0 74 72 11 80 	movl   $0x80117274,-0x20(%ebp)
80106ad4:	e9 2e 01 00 00       	jmp    80106c07 <trap+0x2e6>
        if (p->state != RUNNABLE)
80106ad9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106adc:	8b 40 0c             	mov    0xc(%eax),%eax
80106adf:	83 f8 03             	cmp    $0x3,%eax
80106ae2:	0f 85 17 01 00 00    	jne    80106bff <trap+0x2de>
          continue;
        int plevel = p->priority;
80106ae8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106aeb:	8b 40 7c             	mov    0x7c(%eax),%eax
80106aee:	89 45 d0             	mov    %eax,-0x30(%ebp)

        if (plevel == 0 && p->wait_ticks[0] >= 500) {
80106af1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80106af5:	75 56                	jne    80106b4d <trap+0x22c>
80106af7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106afa:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106b00:	3d f3 01 00 00       	cmp    $0x1f3,%eax
80106b05:	7e 46                	jle    80106b4d <trap+0x22c>
          p->priority = 1;
80106b07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b0a:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
          p->wait_ticks[0] = 0;
80106b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b14:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80106b1b:	00 00 00 
          enqueue(&mlfq[1], p);
80106b1e:	83 ec 08             	sub    $0x8,%esp
80106b21:	ff 75 e0             	push   -0x20(%ebp)
80106b24:	68 88 9b 11 80       	push   $0x80119b88
80106b29:	e8 fe e0 ff ff       	call   80104c2c <enqueue>
80106b2e:	83 c4 10             	add    $0x10,%esp
          cprintf("[boost] pid %d: Q0→Q1\n", p->pid);
80106b31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b34:	8b 40 10             	mov    0x10(%eax),%eax
80106b37:	83 ec 08             	sub    $0x8,%esp
80106b3a:	50                   	push   %eax
80106b3b:	68 0e b0 10 80       	push   $0x8010b00e
80106b40:	e8 af 98 ff ff       	call   801003f4 <cprintf>
80106b45:	83 c4 10             	add    $0x10,%esp
80106b48:	e9 b3 00 00 00       	jmp    80106c00 <trap+0x2df>
        } 
        else if (plevel == 1 && p->wait_ticks[1] >= 320) {
80106b4d:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
80106b51:	75 53                	jne    80106ba6 <trap+0x285>
80106b53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b56:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106b5c:	3d 3f 01 00 00       	cmp    $0x13f,%eax
80106b61:	7e 43                	jle    80106ba6 <trap+0x285>
          p->priority = 2;
80106b63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b66:	c7 40 7c 02 00 00 00 	movl   $0x2,0x7c(%eax)
          p->wait_ticks[1] = 0;
80106b6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b70:	c7 80 94 00 00 00 00 	movl   $0x0,0x94(%eax)
80106b77:	00 00 00 
          enqueue(&mlfq[2], p);
80106b7a:	83 ec 08             	sub    $0x8,%esp
80106b7d:	ff 75 e0             	push   -0x20(%ebp)
80106b80:	68 90 9c 11 80       	push   $0x80119c90
80106b85:	e8 a2 e0 ff ff       	call   80104c2c <enqueue>
80106b8a:	83 c4 10             	add    $0x10,%esp
          cprintf("[boost] pid %d: Q1→Q2\n", p->pid);
80106b8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b90:	8b 40 10             	mov    0x10(%eax),%eax
80106b93:	83 ec 08             	sub    $0x8,%esp
80106b96:	50                   	push   %eax
80106b97:	68 27 b0 10 80       	push   $0x8010b027
80106b9c:	e8 53 98 ff ff       	call   801003f4 <cprintf>
80106ba1:	83 c4 10             	add    $0x10,%esp
80106ba4:	eb 5a                	jmp    80106c00 <trap+0x2df>
        } 
        else if (plevel == 2 && p->wait_ticks[2] >= 160) {
80106ba6:	83 7d d0 02          	cmpl   $0x2,-0x30(%ebp)
80106baa:	75 54                	jne    80106c00 <trap+0x2df>
80106bac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106baf:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106bb5:	3d 9f 00 00 00       	cmp    $0x9f,%eax
80106bba:	7e 44                	jle    80106c00 <trap+0x2df>
          p->priority = 3;
80106bbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106bbf:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
          p->wait_ticks[2] = 0;
80106bc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106bc9:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
80106bd0:	00 00 00 
          enqueue(&mlfq[3], p);
80106bd3:	83 ec 08             	sub    $0x8,%esp
80106bd6:	ff 75 e0             	push   -0x20(%ebp)
80106bd9:	68 98 9d 11 80       	push   $0x80119d98
80106bde:	e8 49 e0 ff ff       	call   80104c2c <enqueue>
80106be3:	83 c4 10             	add    $0x10,%esp
          cprintf("[boost] pid %d: Q2→Q3\n", p->pid);
80106be6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106be9:	8b 40 10             	mov    0x10(%eax),%eax
80106bec:	83 ec 08             	sub    $0x8,%esp
80106bef:	50                   	push   %eax
80106bf0:	68 40 b0 10 80       	push   $0x8010b040
80106bf5:	e8 fa 97 ff ff       	call   801003f4 <cprintf>
80106bfa:	83 c4 10             	add    $0x10,%esp
80106bfd:	eb 01                	jmp    80106c00 <trap+0x2df>
          continue;
80106bff:	90                   	nop
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106c00:	81 45 e0 a0 00 00 00 	addl   $0xa0,-0x20(%ebp)
80106c07:	81 7d e0 74 9a 11 80 	cmpl   $0x80119a74,-0x20(%ebp)
80106c0e:	0f 82 c5 fe ff ff    	jb     80106ad9 <trap+0x1b8>

        }
      }
    }
        
    release(&ptable.lock);
80106c14:	83 ec 0c             	sub    $0xc,%esp
80106c17:	68 40 72 11 80       	push   $0x80117240
80106c1c:	e8 17 e5 ff ff       	call   80105138 <release>
80106c21:	83 c4 10             	add    $0x10,%esp
  
    if (sched == 1 && curproc && curproc->state == RUNNING)
80106c24:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
80106c28:	75 16                	jne    80106c40 <trap+0x31f>
80106c2a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106c2e:	74 10                	je     80106c40 <trap+0x31f>
80106c30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106c33:	8b 40 0c             	mov    0xc(%eax),%eax
80106c36:	83 f8 04             	cmp    $0x4,%eax
80106c39:	75 05                	jne    80106c40 <trap+0x31f>
      yield();  // ✅ MLFQ일 때만 yield
80106c3b:	e8 7f dd ff ff       	call   801049bf <yield>
    
    lapiceoi();
80106c40:	e8 bb c3 ff ff       	call   80103000 <lapiceoi>
    break;
80106c45:	e9 20 01 00 00       	jmp    80106d6a <trap+0x449>

  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106c4a:	e8 07 bc ff ff       	call   80102856 <ideintr>
    lapiceoi();
80106c4f:	e8 ac c3 ff ff       	call   80103000 <lapiceoi>
    break;
80106c54:	e9 11 01 00 00       	jmp    80106d6a <trap+0x449>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106c59:	e8 e7 c1 ff ff       	call   80102e45 <kbdintr>
    lapiceoi();
80106c5e:	e8 9d c3 ff ff       	call   80103000 <lapiceoi>
    break;
80106c63:	e9 02 01 00 00       	jmp    80106d6a <trap+0x449>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106c68:	e8 01 03 00 00       	call   80106f6e <uartintr>
    lapiceoi();
80106c6d:	e8 8e c3 ff ff       	call   80103000 <lapiceoi>
    break;
80106c72:	e9 f3 00 00 00       	jmp    80106d6a <trap+0x449>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106c77:	e8 29 2b 00 00       	call   801097a5 <i8254_intr>
    lapiceoi();
80106c7c:	e8 7f c3 ff ff       	call   80103000 <lapiceoi>
    break;
80106c81:	e9 e4 00 00 00       	jmp    80106d6a <trap+0x449>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c86:	8b 45 08             	mov    0x8(%ebp),%eax
80106c89:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c93:	0f b7 d8             	movzwl %ax,%ebx
80106c96:	e8 14 d2 ff ff       	call   80103eaf <cpuid>
80106c9b:	56                   	push   %esi
80106c9c:	53                   	push   %ebx
80106c9d:	50                   	push   %eax
80106c9e:	68 5c b0 10 80       	push   $0x8010b05c
80106ca3:	e8 4c 97 ff ff       	call   801003f4 <cprintf>
80106ca8:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106cab:	e8 50 c3 ff ff       	call   80103000 <lapiceoi>
    break;
80106cb0:	e9 b5 00 00 00       	jmp    80106d6a <trap+0x449>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106cb5:	e8 88 d2 ff ff       	call   80103f42 <myproc>
80106cba:	85 c0                	test   %eax,%eax
80106cbc:	74 11                	je     80106ccf <trap+0x3ae>
80106cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cc5:	0f b7 c0             	movzwl %ax,%eax
80106cc8:	83 e0 03             	and    $0x3,%eax
80106ccb:	85 c0                	test   %eax,%eax
80106ccd:	75 39                	jne    80106d08 <trap+0x3e7>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ccf:	e8 ae fa ff ff       	call   80106782 <rcr2>
80106cd4:	89 c3                	mov    %eax,%ebx
80106cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd9:	8b 70 38             	mov    0x38(%eax),%esi
80106cdc:	e8 ce d1 ff ff       	call   80103eaf <cpuid>
80106ce1:	8b 55 08             	mov    0x8(%ebp),%edx
80106ce4:	8b 52 30             	mov    0x30(%edx),%edx
80106ce7:	83 ec 0c             	sub    $0xc,%esp
80106cea:	53                   	push   %ebx
80106ceb:	56                   	push   %esi
80106cec:	50                   	push   %eax
80106ced:	52                   	push   %edx
80106cee:	68 80 b0 10 80       	push   $0x8010b080
80106cf3:	e8 fc 96 ff ff       	call   801003f4 <cprintf>
80106cf8:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106cfb:	83 ec 0c             	sub    $0xc,%esp
80106cfe:	68 b2 b0 10 80       	push   $0x8010b0b2
80106d03:	e8 a1 98 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d08:	e8 75 fa ff ff       	call   80106782 <rcr2>
80106d0d:	89 c6                	mov    %eax,%esi
80106d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d12:	8b 40 38             	mov    0x38(%eax),%eax
80106d15:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80106d18:	e8 92 d1 ff ff       	call   80103eaf <cpuid>
80106d1d:	89 c3                	mov    %eax,%ebx
80106d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d22:	8b 78 34             	mov    0x34(%eax),%edi
80106d25:	89 7d c0             	mov    %edi,-0x40(%ebp)
80106d28:	8b 45 08             	mov    0x8(%ebp),%eax
80106d2b:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106d2e:	e8 0f d2 ff ff       	call   80103f42 <myproc>
80106d33:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106d36:	89 4d bc             	mov    %ecx,-0x44(%ebp)
80106d39:	e8 04 d2 ff ff       	call   80103f42 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d3e:	8b 40 10             	mov    0x10(%eax),%eax
80106d41:	56                   	push   %esi
80106d42:	ff 75 c4             	push   -0x3c(%ebp)
80106d45:	53                   	push   %ebx
80106d46:	ff 75 c0             	push   -0x40(%ebp)
80106d49:	57                   	push   %edi
80106d4a:	ff 75 bc             	push   -0x44(%ebp)
80106d4d:	50                   	push   %eax
80106d4e:	68 b8 b0 10 80       	push   $0x8010b0b8
80106d53:	e8 9c 96 ff ff       	call   801003f4 <cprintf>
80106d58:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106d5b:	e8 e2 d1 ff ff       	call   80103f42 <myproc>
80106d60:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106d67:	eb 01                	jmp    80106d6a <trap+0x449>
    break;
80106d69:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106d6a:	e8 d3 d1 ff ff       	call   80103f42 <myproc>
80106d6f:	85 c0                	test   %eax,%eax
80106d71:	74 26                	je     80106d99 <trap+0x478>
80106d73:	e8 ca d1 ff ff       	call   80103f42 <myproc>
80106d78:	8b 40 24             	mov    0x24(%eax),%eax
80106d7b:	85 c0                	test   %eax,%eax
80106d7d:	74 1a                	je     80106d99 <trap+0x478>
80106d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d82:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d86:	0f b7 c0             	movzwl %ax,%eax
80106d89:	83 e0 03             	and    $0x3,%eax
80106d8c:	83 f8 03             	cmp    $0x3,%eax
80106d8f:	75 08                	jne    80106d99 <trap+0x478>
    exit();
80106d91:	e8 a4 d6 ff ff       	call   8010443a <exit>
80106d96:	eb 01                	jmp    80106d99 <trap+0x478>
    return;
80106d98:	90                   	nop
     yield();*/

  // Check if the process has been killed since we yielded
  /*if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();*/
}
80106d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d9c:	5b                   	pop    %ebx
80106d9d:	5e                   	pop    %esi
80106d9e:	5f                   	pop    %edi
80106d9f:	5d                   	pop    %ebp
80106da0:	c3                   	ret    

80106da1 <inb>:
{
80106da1:	55                   	push   %ebp
80106da2:	89 e5                	mov    %esp,%ebp
80106da4:	83 ec 14             	sub    $0x14,%esp
80106da7:	8b 45 08             	mov    0x8(%ebp),%eax
80106daa:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106dae:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106db2:	89 c2                	mov    %eax,%edx
80106db4:	ec                   	in     (%dx),%al
80106db5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106db8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106dbc:	c9                   	leave  
80106dbd:	c3                   	ret    

80106dbe <outb>:
{
80106dbe:	55                   	push   %ebp
80106dbf:	89 e5                	mov    %esp,%ebp
80106dc1:	83 ec 08             	sub    $0x8,%esp
80106dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80106dca:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106dce:	89 d0                	mov    %edx,%eax
80106dd0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106dd3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106dd7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ddb:	ee                   	out    %al,(%dx)
}
80106ddc:	90                   	nop
80106ddd:	c9                   	leave  
80106dde:	c3                   	ret    

80106ddf <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ddf:	55                   	push   %ebp
80106de0:	89 e5                	mov    %esp,%ebp
80106de2:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106de5:	6a 00                	push   $0x0
80106de7:	68 fa 03 00 00       	push   $0x3fa
80106dec:	e8 cd ff ff ff       	call   80106dbe <outb>
80106df1:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106df4:	68 80 00 00 00       	push   $0x80
80106df9:	68 fb 03 00 00       	push   $0x3fb
80106dfe:	e8 bb ff ff ff       	call   80106dbe <outb>
80106e03:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106e06:	6a 0c                	push   $0xc
80106e08:	68 f8 03 00 00       	push   $0x3f8
80106e0d:	e8 ac ff ff ff       	call   80106dbe <outb>
80106e12:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106e15:	6a 00                	push   $0x0
80106e17:	68 f9 03 00 00       	push   $0x3f9
80106e1c:	e8 9d ff ff ff       	call   80106dbe <outb>
80106e21:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e24:	6a 03                	push   $0x3
80106e26:	68 fb 03 00 00       	push   $0x3fb
80106e2b:	e8 8e ff ff ff       	call   80106dbe <outb>
80106e30:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106e33:	6a 00                	push   $0x0
80106e35:	68 fc 03 00 00       	push   $0x3fc
80106e3a:	e8 7f ff ff ff       	call   80106dbe <outb>
80106e3f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e42:	6a 01                	push   $0x1
80106e44:	68 f9 03 00 00       	push   $0x3f9
80106e49:	e8 70 ff ff ff       	call   80106dbe <outb>
80106e4e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e51:	68 fd 03 00 00       	push   $0x3fd
80106e56:	e8 46 ff ff ff       	call   80106da1 <inb>
80106e5b:	83 c4 04             	add    $0x4,%esp
80106e5e:	3c ff                	cmp    $0xff,%al
80106e60:	74 61                	je     80106ec3 <uartinit+0xe4>
    return;
  uart = 1;
80106e62:	c7 05 f8 a6 11 80 01 	movl   $0x1,0x8011a6f8
80106e69:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e6c:	68 fa 03 00 00       	push   $0x3fa
80106e71:	e8 2b ff ff ff       	call   80106da1 <inb>
80106e76:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106e79:	68 f8 03 00 00       	push   $0x3f8
80106e7e:	e8 1e ff ff ff       	call   80106da1 <inb>
80106e83:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106e86:	83 ec 08             	sub    $0x8,%esp
80106e89:	6a 00                	push   $0x0
80106e8b:	6a 04                	push   $0x4
80106e8d:	e8 80 bc ff ff       	call   80102b12 <ioapicenable>
80106e92:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e95:	c7 45 f4 7c b1 10 80 	movl   $0x8010b17c,-0xc(%ebp)
80106e9c:	eb 19                	jmp    80106eb7 <uartinit+0xd8>
    uartputc(*p);
80106e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea1:	0f b6 00             	movzbl (%eax),%eax
80106ea4:	0f be c0             	movsbl %al,%eax
80106ea7:	83 ec 0c             	sub    $0xc,%esp
80106eaa:	50                   	push   %eax
80106eab:	e8 16 00 00 00       	call   80106ec6 <uartputc>
80106eb0:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106eb3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eba:	0f b6 00             	movzbl (%eax),%eax
80106ebd:	84 c0                	test   %al,%al
80106ebf:	75 dd                	jne    80106e9e <uartinit+0xbf>
80106ec1:	eb 01                	jmp    80106ec4 <uartinit+0xe5>
    return;
80106ec3:	90                   	nop
}
80106ec4:	c9                   	leave  
80106ec5:	c3                   	ret    

80106ec6 <uartputc>:

void
uartputc(int c)
{
80106ec6:	55                   	push   %ebp
80106ec7:	89 e5                	mov    %esp,%ebp
80106ec9:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106ecc:	a1 f8 a6 11 80       	mov    0x8011a6f8,%eax
80106ed1:	85 c0                	test   %eax,%eax
80106ed3:	74 53                	je     80106f28 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ed5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106edc:	eb 11                	jmp    80106eef <uartputc+0x29>
    microdelay(10);
80106ede:	83 ec 0c             	sub    $0xc,%esp
80106ee1:	6a 0a                	push   $0xa
80106ee3:	e8 33 c1 ff ff       	call   8010301b <microdelay>
80106ee8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106eeb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106eef:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ef3:	7f 1a                	jg     80106f0f <uartputc+0x49>
80106ef5:	83 ec 0c             	sub    $0xc,%esp
80106ef8:	68 fd 03 00 00       	push   $0x3fd
80106efd:	e8 9f fe ff ff       	call   80106da1 <inb>
80106f02:	83 c4 10             	add    $0x10,%esp
80106f05:	0f b6 c0             	movzbl %al,%eax
80106f08:	83 e0 20             	and    $0x20,%eax
80106f0b:	85 c0                	test   %eax,%eax
80106f0d:	74 cf                	je     80106ede <uartputc+0x18>
  outb(COM1+0, c);
80106f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80106f12:	0f b6 c0             	movzbl %al,%eax
80106f15:	83 ec 08             	sub    $0x8,%esp
80106f18:	50                   	push   %eax
80106f19:	68 f8 03 00 00       	push   $0x3f8
80106f1e:	e8 9b fe ff ff       	call   80106dbe <outb>
80106f23:	83 c4 10             	add    $0x10,%esp
80106f26:	eb 01                	jmp    80106f29 <uartputc+0x63>
    return;
80106f28:	90                   	nop
}
80106f29:	c9                   	leave  
80106f2a:	c3                   	ret    

80106f2b <uartgetc>:

static int
uartgetc(void)
{
80106f2b:	55                   	push   %ebp
80106f2c:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106f2e:	a1 f8 a6 11 80       	mov    0x8011a6f8,%eax
80106f33:	85 c0                	test   %eax,%eax
80106f35:	75 07                	jne    80106f3e <uartgetc+0x13>
    return -1;
80106f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f3c:	eb 2e                	jmp    80106f6c <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106f3e:	68 fd 03 00 00       	push   $0x3fd
80106f43:	e8 59 fe ff ff       	call   80106da1 <inb>
80106f48:	83 c4 04             	add    $0x4,%esp
80106f4b:	0f b6 c0             	movzbl %al,%eax
80106f4e:	83 e0 01             	and    $0x1,%eax
80106f51:	85 c0                	test   %eax,%eax
80106f53:	75 07                	jne    80106f5c <uartgetc+0x31>
    return -1;
80106f55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f5a:	eb 10                	jmp    80106f6c <uartgetc+0x41>
  return inb(COM1+0);
80106f5c:	68 f8 03 00 00       	push   $0x3f8
80106f61:	e8 3b fe ff ff       	call   80106da1 <inb>
80106f66:	83 c4 04             	add    $0x4,%esp
80106f69:	0f b6 c0             	movzbl %al,%eax
}
80106f6c:	c9                   	leave  
80106f6d:	c3                   	ret    

80106f6e <uartintr>:

void
uartintr(void)
{
80106f6e:	55                   	push   %ebp
80106f6f:	89 e5                	mov    %esp,%ebp
80106f71:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106f74:	83 ec 0c             	sub    $0xc,%esp
80106f77:	68 2b 6f 10 80       	push   $0x80106f2b
80106f7c:	e8 55 98 ff ff       	call   801007d6 <consoleintr>
80106f81:	83 c4 10             	add    $0x10,%esp
}
80106f84:	90                   	nop
80106f85:	c9                   	leave  
80106f86:	c3                   	ret    

80106f87 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $0
80106f89:	6a 00                	push   $0x0
  jmp alltraps
80106f8b:	e9 a5 f7 ff ff       	jmp    80106735 <alltraps>

80106f90 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $1
80106f92:	6a 01                	push   $0x1
  jmp alltraps
80106f94:	e9 9c f7 ff ff       	jmp    80106735 <alltraps>

80106f99 <vector2>:
.globl vector2
vector2:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $2
80106f9b:	6a 02                	push   $0x2
  jmp alltraps
80106f9d:	e9 93 f7 ff ff       	jmp    80106735 <alltraps>

80106fa2 <vector3>:
.globl vector3
vector3:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $3
80106fa4:	6a 03                	push   $0x3
  jmp alltraps
80106fa6:	e9 8a f7 ff ff       	jmp    80106735 <alltraps>

80106fab <vector4>:
.globl vector4
vector4:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $4
80106fad:	6a 04                	push   $0x4
  jmp alltraps
80106faf:	e9 81 f7 ff ff       	jmp    80106735 <alltraps>

80106fb4 <vector5>:
.globl vector5
vector5:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $5
80106fb6:	6a 05                	push   $0x5
  jmp alltraps
80106fb8:	e9 78 f7 ff ff       	jmp    80106735 <alltraps>

80106fbd <vector6>:
.globl vector6
vector6:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $6
80106fbf:	6a 06                	push   $0x6
  jmp alltraps
80106fc1:	e9 6f f7 ff ff       	jmp    80106735 <alltraps>

80106fc6 <vector7>:
.globl vector7
vector7:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $7
80106fc8:	6a 07                	push   $0x7
  jmp alltraps
80106fca:	e9 66 f7 ff ff       	jmp    80106735 <alltraps>

80106fcf <vector8>:
.globl vector8
vector8:
  pushl $8
80106fcf:	6a 08                	push   $0x8
  jmp alltraps
80106fd1:	e9 5f f7 ff ff       	jmp    80106735 <alltraps>

80106fd6 <vector9>:
.globl vector9
vector9:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $9
80106fd8:	6a 09                	push   $0x9
  jmp alltraps
80106fda:	e9 56 f7 ff ff       	jmp    80106735 <alltraps>

80106fdf <vector10>:
.globl vector10
vector10:
  pushl $10
80106fdf:	6a 0a                	push   $0xa
  jmp alltraps
80106fe1:	e9 4f f7 ff ff       	jmp    80106735 <alltraps>

80106fe6 <vector11>:
.globl vector11
vector11:
  pushl $11
80106fe6:	6a 0b                	push   $0xb
  jmp alltraps
80106fe8:	e9 48 f7 ff ff       	jmp    80106735 <alltraps>

80106fed <vector12>:
.globl vector12
vector12:
  pushl $12
80106fed:	6a 0c                	push   $0xc
  jmp alltraps
80106fef:	e9 41 f7 ff ff       	jmp    80106735 <alltraps>

80106ff4 <vector13>:
.globl vector13
vector13:
  pushl $13
80106ff4:	6a 0d                	push   $0xd
  jmp alltraps
80106ff6:	e9 3a f7 ff ff       	jmp    80106735 <alltraps>

80106ffb <vector14>:
.globl vector14
vector14:
  pushl $14
80106ffb:	6a 0e                	push   $0xe
  jmp alltraps
80106ffd:	e9 33 f7 ff ff       	jmp    80106735 <alltraps>

80107002 <vector15>:
.globl vector15
vector15:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $15
80107004:	6a 0f                	push   $0xf
  jmp alltraps
80107006:	e9 2a f7 ff ff       	jmp    80106735 <alltraps>

8010700b <vector16>:
.globl vector16
vector16:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $16
8010700d:	6a 10                	push   $0x10
  jmp alltraps
8010700f:	e9 21 f7 ff ff       	jmp    80106735 <alltraps>

80107014 <vector17>:
.globl vector17
vector17:
  pushl $17
80107014:	6a 11                	push   $0x11
  jmp alltraps
80107016:	e9 1a f7 ff ff       	jmp    80106735 <alltraps>

8010701b <vector18>:
.globl vector18
vector18:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $18
8010701d:	6a 12                	push   $0x12
  jmp alltraps
8010701f:	e9 11 f7 ff ff       	jmp    80106735 <alltraps>

80107024 <vector19>:
.globl vector19
vector19:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $19
80107026:	6a 13                	push   $0x13
  jmp alltraps
80107028:	e9 08 f7 ff ff       	jmp    80106735 <alltraps>

8010702d <vector20>:
.globl vector20
vector20:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $20
8010702f:	6a 14                	push   $0x14
  jmp alltraps
80107031:	e9 ff f6 ff ff       	jmp    80106735 <alltraps>

80107036 <vector21>:
.globl vector21
vector21:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $21
80107038:	6a 15                	push   $0x15
  jmp alltraps
8010703a:	e9 f6 f6 ff ff       	jmp    80106735 <alltraps>

8010703f <vector22>:
.globl vector22
vector22:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $22
80107041:	6a 16                	push   $0x16
  jmp alltraps
80107043:	e9 ed f6 ff ff       	jmp    80106735 <alltraps>

80107048 <vector23>:
.globl vector23
vector23:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $23
8010704a:	6a 17                	push   $0x17
  jmp alltraps
8010704c:	e9 e4 f6 ff ff       	jmp    80106735 <alltraps>

80107051 <vector24>:
.globl vector24
vector24:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $24
80107053:	6a 18                	push   $0x18
  jmp alltraps
80107055:	e9 db f6 ff ff       	jmp    80106735 <alltraps>

8010705a <vector25>:
.globl vector25
vector25:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $25
8010705c:	6a 19                	push   $0x19
  jmp alltraps
8010705e:	e9 d2 f6 ff ff       	jmp    80106735 <alltraps>

80107063 <vector26>:
.globl vector26
vector26:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $26
80107065:	6a 1a                	push   $0x1a
  jmp alltraps
80107067:	e9 c9 f6 ff ff       	jmp    80106735 <alltraps>

8010706c <vector27>:
.globl vector27
vector27:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $27
8010706e:	6a 1b                	push   $0x1b
  jmp alltraps
80107070:	e9 c0 f6 ff ff       	jmp    80106735 <alltraps>

80107075 <vector28>:
.globl vector28
vector28:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $28
80107077:	6a 1c                	push   $0x1c
  jmp alltraps
80107079:	e9 b7 f6 ff ff       	jmp    80106735 <alltraps>

8010707e <vector29>:
.globl vector29
vector29:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $29
80107080:	6a 1d                	push   $0x1d
  jmp alltraps
80107082:	e9 ae f6 ff ff       	jmp    80106735 <alltraps>

80107087 <vector30>:
.globl vector30
vector30:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $30
80107089:	6a 1e                	push   $0x1e
  jmp alltraps
8010708b:	e9 a5 f6 ff ff       	jmp    80106735 <alltraps>

80107090 <vector31>:
.globl vector31
vector31:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $31
80107092:	6a 1f                	push   $0x1f
  jmp alltraps
80107094:	e9 9c f6 ff ff       	jmp    80106735 <alltraps>

80107099 <vector32>:
.globl vector32
vector32:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $32
8010709b:	6a 20                	push   $0x20
  jmp alltraps
8010709d:	e9 93 f6 ff ff       	jmp    80106735 <alltraps>

801070a2 <vector33>:
.globl vector33
vector33:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $33
801070a4:	6a 21                	push   $0x21
  jmp alltraps
801070a6:	e9 8a f6 ff ff       	jmp    80106735 <alltraps>

801070ab <vector34>:
.globl vector34
vector34:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $34
801070ad:	6a 22                	push   $0x22
  jmp alltraps
801070af:	e9 81 f6 ff ff       	jmp    80106735 <alltraps>

801070b4 <vector35>:
.globl vector35
vector35:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $35
801070b6:	6a 23                	push   $0x23
  jmp alltraps
801070b8:	e9 78 f6 ff ff       	jmp    80106735 <alltraps>

801070bd <vector36>:
.globl vector36
vector36:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $36
801070bf:	6a 24                	push   $0x24
  jmp alltraps
801070c1:	e9 6f f6 ff ff       	jmp    80106735 <alltraps>

801070c6 <vector37>:
.globl vector37
vector37:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $37
801070c8:	6a 25                	push   $0x25
  jmp alltraps
801070ca:	e9 66 f6 ff ff       	jmp    80106735 <alltraps>

801070cf <vector38>:
.globl vector38
vector38:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $38
801070d1:	6a 26                	push   $0x26
  jmp alltraps
801070d3:	e9 5d f6 ff ff       	jmp    80106735 <alltraps>

801070d8 <vector39>:
.globl vector39
vector39:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $39
801070da:	6a 27                	push   $0x27
  jmp alltraps
801070dc:	e9 54 f6 ff ff       	jmp    80106735 <alltraps>

801070e1 <vector40>:
.globl vector40
vector40:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $40
801070e3:	6a 28                	push   $0x28
  jmp alltraps
801070e5:	e9 4b f6 ff ff       	jmp    80106735 <alltraps>

801070ea <vector41>:
.globl vector41
vector41:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $41
801070ec:	6a 29                	push   $0x29
  jmp alltraps
801070ee:	e9 42 f6 ff ff       	jmp    80106735 <alltraps>

801070f3 <vector42>:
.globl vector42
vector42:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $42
801070f5:	6a 2a                	push   $0x2a
  jmp alltraps
801070f7:	e9 39 f6 ff ff       	jmp    80106735 <alltraps>

801070fc <vector43>:
.globl vector43
vector43:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $43
801070fe:	6a 2b                	push   $0x2b
  jmp alltraps
80107100:	e9 30 f6 ff ff       	jmp    80106735 <alltraps>

80107105 <vector44>:
.globl vector44
vector44:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $44
80107107:	6a 2c                	push   $0x2c
  jmp alltraps
80107109:	e9 27 f6 ff ff       	jmp    80106735 <alltraps>

8010710e <vector45>:
.globl vector45
vector45:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $45
80107110:	6a 2d                	push   $0x2d
  jmp alltraps
80107112:	e9 1e f6 ff ff       	jmp    80106735 <alltraps>

80107117 <vector46>:
.globl vector46
vector46:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $46
80107119:	6a 2e                	push   $0x2e
  jmp alltraps
8010711b:	e9 15 f6 ff ff       	jmp    80106735 <alltraps>

80107120 <vector47>:
.globl vector47
vector47:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $47
80107122:	6a 2f                	push   $0x2f
  jmp alltraps
80107124:	e9 0c f6 ff ff       	jmp    80106735 <alltraps>

80107129 <vector48>:
.globl vector48
vector48:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $48
8010712b:	6a 30                	push   $0x30
  jmp alltraps
8010712d:	e9 03 f6 ff ff       	jmp    80106735 <alltraps>

80107132 <vector49>:
.globl vector49
vector49:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $49
80107134:	6a 31                	push   $0x31
  jmp alltraps
80107136:	e9 fa f5 ff ff       	jmp    80106735 <alltraps>

8010713b <vector50>:
.globl vector50
vector50:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $50
8010713d:	6a 32                	push   $0x32
  jmp alltraps
8010713f:	e9 f1 f5 ff ff       	jmp    80106735 <alltraps>

80107144 <vector51>:
.globl vector51
vector51:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $51
80107146:	6a 33                	push   $0x33
  jmp alltraps
80107148:	e9 e8 f5 ff ff       	jmp    80106735 <alltraps>

8010714d <vector52>:
.globl vector52
vector52:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $52
8010714f:	6a 34                	push   $0x34
  jmp alltraps
80107151:	e9 df f5 ff ff       	jmp    80106735 <alltraps>

80107156 <vector53>:
.globl vector53
vector53:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $53
80107158:	6a 35                	push   $0x35
  jmp alltraps
8010715a:	e9 d6 f5 ff ff       	jmp    80106735 <alltraps>

8010715f <vector54>:
.globl vector54
vector54:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $54
80107161:	6a 36                	push   $0x36
  jmp alltraps
80107163:	e9 cd f5 ff ff       	jmp    80106735 <alltraps>

80107168 <vector55>:
.globl vector55
vector55:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $55
8010716a:	6a 37                	push   $0x37
  jmp alltraps
8010716c:	e9 c4 f5 ff ff       	jmp    80106735 <alltraps>

80107171 <vector56>:
.globl vector56
vector56:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $56
80107173:	6a 38                	push   $0x38
  jmp alltraps
80107175:	e9 bb f5 ff ff       	jmp    80106735 <alltraps>

8010717a <vector57>:
.globl vector57
vector57:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $57
8010717c:	6a 39                	push   $0x39
  jmp alltraps
8010717e:	e9 b2 f5 ff ff       	jmp    80106735 <alltraps>

80107183 <vector58>:
.globl vector58
vector58:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $58
80107185:	6a 3a                	push   $0x3a
  jmp alltraps
80107187:	e9 a9 f5 ff ff       	jmp    80106735 <alltraps>

8010718c <vector59>:
.globl vector59
vector59:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $59
8010718e:	6a 3b                	push   $0x3b
  jmp alltraps
80107190:	e9 a0 f5 ff ff       	jmp    80106735 <alltraps>

80107195 <vector60>:
.globl vector60
vector60:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $60
80107197:	6a 3c                	push   $0x3c
  jmp alltraps
80107199:	e9 97 f5 ff ff       	jmp    80106735 <alltraps>

8010719e <vector61>:
.globl vector61
vector61:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $61
801071a0:	6a 3d                	push   $0x3d
  jmp alltraps
801071a2:	e9 8e f5 ff ff       	jmp    80106735 <alltraps>

801071a7 <vector62>:
.globl vector62
vector62:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $62
801071a9:	6a 3e                	push   $0x3e
  jmp alltraps
801071ab:	e9 85 f5 ff ff       	jmp    80106735 <alltraps>

801071b0 <vector63>:
.globl vector63
vector63:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $63
801071b2:	6a 3f                	push   $0x3f
  jmp alltraps
801071b4:	e9 7c f5 ff ff       	jmp    80106735 <alltraps>

801071b9 <vector64>:
.globl vector64
vector64:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $64
801071bb:	6a 40                	push   $0x40
  jmp alltraps
801071bd:	e9 73 f5 ff ff       	jmp    80106735 <alltraps>

801071c2 <vector65>:
.globl vector65
vector65:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $65
801071c4:	6a 41                	push   $0x41
  jmp alltraps
801071c6:	e9 6a f5 ff ff       	jmp    80106735 <alltraps>

801071cb <vector66>:
.globl vector66
vector66:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $66
801071cd:	6a 42                	push   $0x42
  jmp alltraps
801071cf:	e9 61 f5 ff ff       	jmp    80106735 <alltraps>

801071d4 <vector67>:
.globl vector67
vector67:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $67
801071d6:	6a 43                	push   $0x43
  jmp alltraps
801071d8:	e9 58 f5 ff ff       	jmp    80106735 <alltraps>

801071dd <vector68>:
.globl vector68
vector68:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $68
801071df:	6a 44                	push   $0x44
  jmp alltraps
801071e1:	e9 4f f5 ff ff       	jmp    80106735 <alltraps>

801071e6 <vector69>:
.globl vector69
vector69:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $69
801071e8:	6a 45                	push   $0x45
  jmp alltraps
801071ea:	e9 46 f5 ff ff       	jmp    80106735 <alltraps>

801071ef <vector70>:
.globl vector70
vector70:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $70
801071f1:	6a 46                	push   $0x46
  jmp alltraps
801071f3:	e9 3d f5 ff ff       	jmp    80106735 <alltraps>

801071f8 <vector71>:
.globl vector71
vector71:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $71
801071fa:	6a 47                	push   $0x47
  jmp alltraps
801071fc:	e9 34 f5 ff ff       	jmp    80106735 <alltraps>

80107201 <vector72>:
.globl vector72
vector72:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $72
80107203:	6a 48                	push   $0x48
  jmp alltraps
80107205:	e9 2b f5 ff ff       	jmp    80106735 <alltraps>

8010720a <vector73>:
.globl vector73
vector73:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $73
8010720c:	6a 49                	push   $0x49
  jmp alltraps
8010720e:	e9 22 f5 ff ff       	jmp    80106735 <alltraps>

80107213 <vector74>:
.globl vector74
vector74:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $74
80107215:	6a 4a                	push   $0x4a
  jmp alltraps
80107217:	e9 19 f5 ff ff       	jmp    80106735 <alltraps>

8010721c <vector75>:
.globl vector75
vector75:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $75
8010721e:	6a 4b                	push   $0x4b
  jmp alltraps
80107220:	e9 10 f5 ff ff       	jmp    80106735 <alltraps>

80107225 <vector76>:
.globl vector76
vector76:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $76
80107227:	6a 4c                	push   $0x4c
  jmp alltraps
80107229:	e9 07 f5 ff ff       	jmp    80106735 <alltraps>

8010722e <vector77>:
.globl vector77
vector77:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $77
80107230:	6a 4d                	push   $0x4d
  jmp alltraps
80107232:	e9 fe f4 ff ff       	jmp    80106735 <alltraps>

80107237 <vector78>:
.globl vector78
vector78:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $78
80107239:	6a 4e                	push   $0x4e
  jmp alltraps
8010723b:	e9 f5 f4 ff ff       	jmp    80106735 <alltraps>

80107240 <vector79>:
.globl vector79
vector79:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $79
80107242:	6a 4f                	push   $0x4f
  jmp alltraps
80107244:	e9 ec f4 ff ff       	jmp    80106735 <alltraps>

80107249 <vector80>:
.globl vector80
vector80:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $80
8010724b:	6a 50                	push   $0x50
  jmp alltraps
8010724d:	e9 e3 f4 ff ff       	jmp    80106735 <alltraps>

80107252 <vector81>:
.globl vector81
vector81:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $81
80107254:	6a 51                	push   $0x51
  jmp alltraps
80107256:	e9 da f4 ff ff       	jmp    80106735 <alltraps>

8010725b <vector82>:
.globl vector82
vector82:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $82
8010725d:	6a 52                	push   $0x52
  jmp alltraps
8010725f:	e9 d1 f4 ff ff       	jmp    80106735 <alltraps>

80107264 <vector83>:
.globl vector83
vector83:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $83
80107266:	6a 53                	push   $0x53
  jmp alltraps
80107268:	e9 c8 f4 ff ff       	jmp    80106735 <alltraps>

8010726d <vector84>:
.globl vector84
vector84:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $84
8010726f:	6a 54                	push   $0x54
  jmp alltraps
80107271:	e9 bf f4 ff ff       	jmp    80106735 <alltraps>

80107276 <vector85>:
.globl vector85
vector85:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $85
80107278:	6a 55                	push   $0x55
  jmp alltraps
8010727a:	e9 b6 f4 ff ff       	jmp    80106735 <alltraps>

8010727f <vector86>:
.globl vector86
vector86:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $86
80107281:	6a 56                	push   $0x56
  jmp alltraps
80107283:	e9 ad f4 ff ff       	jmp    80106735 <alltraps>

80107288 <vector87>:
.globl vector87
vector87:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $87
8010728a:	6a 57                	push   $0x57
  jmp alltraps
8010728c:	e9 a4 f4 ff ff       	jmp    80106735 <alltraps>

80107291 <vector88>:
.globl vector88
vector88:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $88
80107293:	6a 58                	push   $0x58
  jmp alltraps
80107295:	e9 9b f4 ff ff       	jmp    80106735 <alltraps>

8010729a <vector89>:
.globl vector89
vector89:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $89
8010729c:	6a 59                	push   $0x59
  jmp alltraps
8010729e:	e9 92 f4 ff ff       	jmp    80106735 <alltraps>

801072a3 <vector90>:
.globl vector90
vector90:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $90
801072a5:	6a 5a                	push   $0x5a
  jmp alltraps
801072a7:	e9 89 f4 ff ff       	jmp    80106735 <alltraps>

801072ac <vector91>:
.globl vector91
vector91:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $91
801072ae:	6a 5b                	push   $0x5b
  jmp alltraps
801072b0:	e9 80 f4 ff ff       	jmp    80106735 <alltraps>

801072b5 <vector92>:
.globl vector92
vector92:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $92
801072b7:	6a 5c                	push   $0x5c
  jmp alltraps
801072b9:	e9 77 f4 ff ff       	jmp    80106735 <alltraps>

801072be <vector93>:
.globl vector93
vector93:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $93
801072c0:	6a 5d                	push   $0x5d
  jmp alltraps
801072c2:	e9 6e f4 ff ff       	jmp    80106735 <alltraps>

801072c7 <vector94>:
.globl vector94
vector94:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $94
801072c9:	6a 5e                	push   $0x5e
  jmp alltraps
801072cb:	e9 65 f4 ff ff       	jmp    80106735 <alltraps>

801072d0 <vector95>:
.globl vector95
vector95:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $95
801072d2:	6a 5f                	push   $0x5f
  jmp alltraps
801072d4:	e9 5c f4 ff ff       	jmp    80106735 <alltraps>

801072d9 <vector96>:
.globl vector96
vector96:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $96
801072db:	6a 60                	push   $0x60
  jmp alltraps
801072dd:	e9 53 f4 ff ff       	jmp    80106735 <alltraps>

801072e2 <vector97>:
.globl vector97
vector97:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $97
801072e4:	6a 61                	push   $0x61
  jmp alltraps
801072e6:	e9 4a f4 ff ff       	jmp    80106735 <alltraps>

801072eb <vector98>:
.globl vector98
vector98:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $98
801072ed:	6a 62                	push   $0x62
  jmp alltraps
801072ef:	e9 41 f4 ff ff       	jmp    80106735 <alltraps>

801072f4 <vector99>:
.globl vector99
vector99:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $99
801072f6:	6a 63                	push   $0x63
  jmp alltraps
801072f8:	e9 38 f4 ff ff       	jmp    80106735 <alltraps>

801072fd <vector100>:
.globl vector100
vector100:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $100
801072ff:	6a 64                	push   $0x64
  jmp alltraps
80107301:	e9 2f f4 ff ff       	jmp    80106735 <alltraps>

80107306 <vector101>:
.globl vector101
vector101:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $101
80107308:	6a 65                	push   $0x65
  jmp alltraps
8010730a:	e9 26 f4 ff ff       	jmp    80106735 <alltraps>

8010730f <vector102>:
.globl vector102
vector102:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $102
80107311:	6a 66                	push   $0x66
  jmp alltraps
80107313:	e9 1d f4 ff ff       	jmp    80106735 <alltraps>

80107318 <vector103>:
.globl vector103
vector103:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $103
8010731a:	6a 67                	push   $0x67
  jmp alltraps
8010731c:	e9 14 f4 ff ff       	jmp    80106735 <alltraps>

80107321 <vector104>:
.globl vector104
vector104:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $104
80107323:	6a 68                	push   $0x68
  jmp alltraps
80107325:	e9 0b f4 ff ff       	jmp    80106735 <alltraps>

8010732a <vector105>:
.globl vector105
vector105:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $105
8010732c:	6a 69                	push   $0x69
  jmp alltraps
8010732e:	e9 02 f4 ff ff       	jmp    80106735 <alltraps>

80107333 <vector106>:
.globl vector106
vector106:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $106
80107335:	6a 6a                	push   $0x6a
  jmp alltraps
80107337:	e9 f9 f3 ff ff       	jmp    80106735 <alltraps>

8010733c <vector107>:
.globl vector107
vector107:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $107
8010733e:	6a 6b                	push   $0x6b
  jmp alltraps
80107340:	e9 f0 f3 ff ff       	jmp    80106735 <alltraps>

80107345 <vector108>:
.globl vector108
vector108:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $108
80107347:	6a 6c                	push   $0x6c
  jmp alltraps
80107349:	e9 e7 f3 ff ff       	jmp    80106735 <alltraps>

8010734e <vector109>:
.globl vector109
vector109:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $109
80107350:	6a 6d                	push   $0x6d
  jmp alltraps
80107352:	e9 de f3 ff ff       	jmp    80106735 <alltraps>

80107357 <vector110>:
.globl vector110
vector110:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $110
80107359:	6a 6e                	push   $0x6e
  jmp alltraps
8010735b:	e9 d5 f3 ff ff       	jmp    80106735 <alltraps>

80107360 <vector111>:
.globl vector111
vector111:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $111
80107362:	6a 6f                	push   $0x6f
  jmp alltraps
80107364:	e9 cc f3 ff ff       	jmp    80106735 <alltraps>

80107369 <vector112>:
.globl vector112
vector112:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $112
8010736b:	6a 70                	push   $0x70
  jmp alltraps
8010736d:	e9 c3 f3 ff ff       	jmp    80106735 <alltraps>

80107372 <vector113>:
.globl vector113
vector113:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $113
80107374:	6a 71                	push   $0x71
  jmp alltraps
80107376:	e9 ba f3 ff ff       	jmp    80106735 <alltraps>

8010737b <vector114>:
.globl vector114
vector114:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $114
8010737d:	6a 72                	push   $0x72
  jmp alltraps
8010737f:	e9 b1 f3 ff ff       	jmp    80106735 <alltraps>

80107384 <vector115>:
.globl vector115
vector115:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $115
80107386:	6a 73                	push   $0x73
  jmp alltraps
80107388:	e9 a8 f3 ff ff       	jmp    80106735 <alltraps>

8010738d <vector116>:
.globl vector116
vector116:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $116
8010738f:	6a 74                	push   $0x74
  jmp alltraps
80107391:	e9 9f f3 ff ff       	jmp    80106735 <alltraps>

80107396 <vector117>:
.globl vector117
vector117:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $117
80107398:	6a 75                	push   $0x75
  jmp alltraps
8010739a:	e9 96 f3 ff ff       	jmp    80106735 <alltraps>

8010739f <vector118>:
.globl vector118
vector118:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $118
801073a1:	6a 76                	push   $0x76
  jmp alltraps
801073a3:	e9 8d f3 ff ff       	jmp    80106735 <alltraps>

801073a8 <vector119>:
.globl vector119
vector119:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $119
801073aa:	6a 77                	push   $0x77
  jmp alltraps
801073ac:	e9 84 f3 ff ff       	jmp    80106735 <alltraps>

801073b1 <vector120>:
.globl vector120
vector120:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $120
801073b3:	6a 78                	push   $0x78
  jmp alltraps
801073b5:	e9 7b f3 ff ff       	jmp    80106735 <alltraps>

801073ba <vector121>:
.globl vector121
vector121:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $121
801073bc:	6a 79                	push   $0x79
  jmp alltraps
801073be:	e9 72 f3 ff ff       	jmp    80106735 <alltraps>

801073c3 <vector122>:
.globl vector122
vector122:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $122
801073c5:	6a 7a                	push   $0x7a
  jmp alltraps
801073c7:	e9 69 f3 ff ff       	jmp    80106735 <alltraps>

801073cc <vector123>:
.globl vector123
vector123:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $123
801073ce:	6a 7b                	push   $0x7b
  jmp alltraps
801073d0:	e9 60 f3 ff ff       	jmp    80106735 <alltraps>

801073d5 <vector124>:
.globl vector124
vector124:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $124
801073d7:	6a 7c                	push   $0x7c
  jmp alltraps
801073d9:	e9 57 f3 ff ff       	jmp    80106735 <alltraps>

801073de <vector125>:
.globl vector125
vector125:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $125
801073e0:	6a 7d                	push   $0x7d
  jmp alltraps
801073e2:	e9 4e f3 ff ff       	jmp    80106735 <alltraps>

801073e7 <vector126>:
.globl vector126
vector126:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $126
801073e9:	6a 7e                	push   $0x7e
  jmp alltraps
801073eb:	e9 45 f3 ff ff       	jmp    80106735 <alltraps>

801073f0 <vector127>:
.globl vector127
vector127:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $127
801073f2:	6a 7f                	push   $0x7f
  jmp alltraps
801073f4:	e9 3c f3 ff ff       	jmp    80106735 <alltraps>

801073f9 <vector128>:
.globl vector128
vector128:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $128
801073fb:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107400:	e9 30 f3 ff ff       	jmp    80106735 <alltraps>

80107405 <vector129>:
.globl vector129
vector129:
  pushl $0
80107405:	6a 00                	push   $0x0
  pushl $129
80107407:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010740c:	e9 24 f3 ff ff       	jmp    80106735 <alltraps>

80107411 <vector130>:
.globl vector130
vector130:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $130
80107413:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107418:	e9 18 f3 ff ff       	jmp    80106735 <alltraps>

8010741d <vector131>:
.globl vector131
vector131:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $131
8010741f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107424:	e9 0c f3 ff ff       	jmp    80106735 <alltraps>

80107429 <vector132>:
.globl vector132
vector132:
  pushl $0
80107429:	6a 00                	push   $0x0
  pushl $132
8010742b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107430:	e9 00 f3 ff ff       	jmp    80106735 <alltraps>

80107435 <vector133>:
.globl vector133
vector133:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $133
80107437:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010743c:	e9 f4 f2 ff ff       	jmp    80106735 <alltraps>

80107441 <vector134>:
.globl vector134
vector134:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $134
80107443:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107448:	e9 e8 f2 ff ff       	jmp    80106735 <alltraps>

8010744d <vector135>:
.globl vector135
vector135:
  pushl $0
8010744d:	6a 00                	push   $0x0
  pushl $135
8010744f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107454:	e9 dc f2 ff ff       	jmp    80106735 <alltraps>

80107459 <vector136>:
.globl vector136
vector136:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $136
8010745b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107460:	e9 d0 f2 ff ff       	jmp    80106735 <alltraps>

80107465 <vector137>:
.globl vector137
vector137:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $137
80107467:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010746c:	e9 c4 f2 ff ff       	jmp    80106735 <alltraps>

80107471 <vector138>:
.globl vector138
vector138:
  pushl $0
80107471:	6a 00                	push   $0x0
  pushl $138
80107473:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107478:	e9 b8 f2 ff ff       	jmp    80106735 <alltraps>

8010747d <vector139>:
.globl vector139
vector139:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $139
8010747f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107484:	e9 ac f2 ff ff       	jmp    80106735 <alltraps>

80107489 <vector140>:
.globl vector140
vector140:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $140
8010748b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107490:	e9 a0 f2 ff ff       	jmp    80106735 <alltraps>

80107495 <vector141>:
.globl vector141
vector141:
  pushl $0
80107495:	6a 00                	push   $0x0
  pushl $141
80107497:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010749c:	e9 94 f2 ff ff       	jmp    80106735 <alltraps>

801074a1 <vector142>:
.globl vector142
vector142:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $142
801074a3:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801074a8:	e9 88 f2 ff ff       	jmp    80106735 <alltraps>

801074ad <vector143>:
.globl vector143
vector143:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $143
801074af:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801074b4:	e9 7c f2 ff ff       	jmp    80106735 <alltraps>

801074b9 <vector144>:
.globl vector144
vector144:
  pushl $0
801074b9:	6a 00                	push   $0x0
  pushl $144
801074bb:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801074c0:	e9 70 f2 ff ff       	jmp    80106735 <alltraps>

801074c5 <vector145>:
.globl vector145
vector145:
  pushl $0
801074c5:	6a 00                	push   $0x0
  pushl $145
801074c7:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074cc:	e9 64 f2 ff ff       	jmp    80106735 <alltraps>

801074d1 <vector146>:
.globl vector146
vector146:
  pushl $0
801074d1:	6a 00                	push   $0x0
  pushl $146
801074d3:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074d8:	e9 58 f2 ff ff       	jmp    80106735 <alltraps>

801074dd <vector147>:
.globl vector147
vector147:
  pushl $0
801074dd:	6a 00                	push   $0x0
  pushl $147
801074df:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074e4:	e9 4c f2 ff ff       	jmp    80106735 <alltraps>

801074e9 <vector148>:
.globl vector148
vector148:
  pushl $0
801074e9:	6a 00                	push   $0x0
  pushl $148
801074eb:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074f0:	e9 40 f2 ff ff       	jmp    80106735 <alltraps>

801074f5 <vector149>:
.globl vector149
vector149:
  pushl $0
801074f5:	6a 00                	push   $0x0
  pushl $149
801074f7:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074fc:	e9 34 f2 ff ff       	jmp    80106735 <alltraps>

80107501 <vector150>:
.globl vector150
vector150:
  pushl $0
80107501:	6a 00                	push   $0x0
  pushl $150
80107503:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107508:	e9 28 f2 ff ff       	jmp    80106735 <alltraps>

8010750d <vector151>:
.globl vector151
vector151:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $151
8010750f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107514:	e9 1c f2 ff ff       	jmp    80106735 <alltraps>

80107519 <vector152>:
.globl vector152
vector152:
  pushl $0
80107519:	6a 00                	push   $0x0
  pushl $152
8010751b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107520:	e9 10 f2 ff ff       	jmp    80106735 <alltraps>

80107525 <vector153>:
.globl vector153
vector153:
  pushl $0
80107525:	6a 00                	push   $0x0
  pushl $153
80107527:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010752c:	e9 04 f2 ff ff       	jmp    80106735 <alltraps>

80107531 <vector154>:
.globl vector154
vector154:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $154
80107533:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107538:	e9 f8 f1 ff ff       	jmp    80106735 <alltraps>

8010753d <vector155>:
.globl vector155
vector155:
  pushl $0
8010753d:	6a 00                	push   $0x0
  pushl $155
8010753f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107544:	e9 ec f1 ff ff       	jmp    80106735 <alltraps>

80107549 <vector156>:
.globl vector156
vector156:
  pushl $0
80107549:	6a 00                	push   $0x0
  pushl $156
8010754b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107550:	e9 e0 f1 ff ff       	jmp    80106735 <alltraps>

80107555 <vector157>:
.globl vector157
vector157:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $157
80107557:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010755c:	e9 d4 f1 ff ff       	jmp    80106735 <alltraps>

80107561 <vector158>:
.globl vector158
vector158:
  pushl $0
80107561:	6a 00                	push   $0x0
  pushl $158
80107563:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107568:	e9 c8 f1 ff ff       	jmp    80106735 <alltraps>

8010756d <vector159>:
.globl vector159
vector159:
  pushl $0
8010756d:	6a 00                	push   $0x0
  pushl $159
8010756f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107574:	e9 bc f1 ff ff       	jmp    80106735 <alltraps>

80107579 <vector160>:
.globl vector160
vector160:
  pushl $0
80107579:	6a 00                	push   $0x0
  pushl $160
8010757b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107580:	e9 b0 f1 ff ff       	jmp    80106735 <alltraps>

80107585 <vector161>:
.globl vector161
vector161:
  pushl $0
80107585:	6a 00                	push   $0x0
  pushl $161
80107587:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010758c:	e9 a4 f1 ff ff       	jmp    80106735 <alltraps>

80107591 <vector162>:
.globl vector162
vector162:
  pushl $0
80107591:	6a 00                	push   $0x0
  pushl $162
80107593:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107598:	e9 98 f1 ff ff       	jmp    80106735 <alltraps>

8010759d <vector163>:
.globl vector163
vector163:
  pushl $0
8010759d:	6a 00                	push   $0x0
  pushl $163
8010759f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801075a4:	e9 8c f1 ff ff       	jmp    80106735 <alltraps>

801075a9 <vector164>:
.globl vector164
vector164:
  pushl $0
801075a9:	6a 00                	push   $0x0
  pushl $164
801075ab:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801075b0:	e9 80 f1 ff ff       	jmp    80106735 <alltraps>

801075b5 <vector165>:
.globl vector165
vector165:
  pushl $0
801075b5:	6a 00                	push   $0x0
  pushl $165
801075b7:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801075bc:	e9 74 f1 ff ff       	jmp    80106735 <alltraps>

801075c1 <vector166>:
.globl vector166
vector166:
  pushl $0
801075c1:	6a 00                	push   $0x0
  pushl $166
801075c3:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801075c8:	e9 68 f1 ff ff       	jmp    80106735 <alltraps>

801075cd <vector167>:
.globl vector167
vector167:
  pushl $0
801075cd:	6a 00                	push   $0x0
  pushl $167
801075cf:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801075d4:	e9 5c f1 ff ff       	jmp    80106735 <alltraps>

801075d9 <vector168>:
.globl vector168
vector168:
  pushl $0
801075d9:	6a 00                	push   $0x0
  pushl $168
801075db:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075e0:	e9 50 f1 ff ff       	jmp    80106735 <alltraps>

801075e5 <vector169>:
.globl vector169
vector169:
  pushl $0
801075e5:	6a 00                	push   $0x0
  pushl $169
801075e7:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075ec:	e9 44 f1 ff ff       	jmp    80106735 <alltraps>

801075f1 <vector170>:
.globl vector170
vector170:
  pushl $0
801075f1:	6a 00                	push   $0x0
  pushl $170
801075f3:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075f8:	e9 38 f1 ff ff       	jmp    80106735 <alltraps>

801075fd <vector171>:
.globl vector171
vector171:
  pushl $0
801075fd:	6a 00                	push   $0x0
  pushl $171
801075ff:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107604:	e9 2c f1 ff ff       	jmp    80106735 <alltraps>

80107609 <vector172>:
.globl vector172
vector172:
  pushl $0
80107609:	6a 00                	push   $0x0
  pushl $172
8010760b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107610:	e9 20 f1 ff ff       	jmp    80106735 <alltraps>

80107615 <vector173>:
.globl vector173
vector173:
  pushl $0
80107615:	6a 00                	push   $0x0
  pushl $173
80107617:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010761c:	e9 14 f1 ff ff       	jmp    80106735 <alltraps>

80107621 <vector174>:
.globl vector174
vector174:
  pushl $0
80107621:	6a 00                	push   $0x0
  pushl $174
80107623:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107628:	e9 08 f1 ff ff       	jmp    80106735 <alltraps>

8010762d <vector175>:
.globl vector175
vector175:
  pushl $0
8010762d:	6a 00                	push   $0x0
  pushl $175
8010762f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107634:	e9 fc f0 ff ff       	jmp    80106735 <alltraps>

80107639 <vector176>:
.globl vector176
vector176:
  pushl $0
80107639:	6a 00                	push   $0x0
  pushl $176
8010763b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107640:	e9 f0 f0 ff ff       	jmp    80106735 <alltraps>

80107645 <vector177>:
.globl vector177
vector177:
  pushl $0
80107645:	6a 00                	push   $0x0
  pushl $177
80107647:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010764c:	e9 e4 f0 ff ff       	jmp    80106735 <alltraps>

80107651 <vector178>:
.globl vector178
vector178:
  pushl $0
80107651:	6a 00                	push   $0x0
  pushl $178
80107653:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107658:	e9 d8 f0 ff ff       	jmp    80106735 <alltraps>

8010765d <vector179>:
.globl vector179
vector179:
  pushl $0
8010765d:	6a 00                	push   $0x0
  pushl $179
8010765f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107664:	e9 cc f0 ff ff       	jmp    80106735 <alltraps>

80107669 <vector180>:
.globl vector180
vector180:
  pushl $0
80107669:	6a 00                	push   $0x0
  pushl $180
8010766b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107670:	e9 c0 f0 ff ff       	jmp    80106735 <alltraps>

80107675 <vector181>:
.globl vector181
vector181:
  pushl $0
80107675:	6a 00                	push   $0x0
  pushl $181
80107677:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010767c:	e9 b4 f0 ff ff       	jmp    80106735 <alltraps>

80107681 <vector182>:
.globl vector182
vector182:
  pushl $0
80107681:	6a 00                	push   $0x0
  pushl $182
80107683:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107688:	e9 a8 f0 ff ff       	jmp    80106735 <alltraps>

8010768d <vector183>:
.globl vector183
vector183:
  pushl $0
8010768d:	6a 00                	push   $0x0
  pushl $183
8010768f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107694:	e9 9c f0 ff ff       	jmp    80106735 <alltraps>

80107699 <vector184>:
.globl vector184
vector184:
  pushl $0
80107699:	6a 00                	push   $0x0
  pushl $184
8010769b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801076a0:	e9 90 f0 ff ff       	jmp    80106735 <alltraps>

801076a5 <vector185>:
.globl vector185
vector185:
  pushl $0
801076a5:	6a 00                	push   $0x0
  pushl $185
801076a7:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801076ac:	e9 84 f0 ff ff       	jmp    80106735 <alltraps>

801076b1 <vector186>:
.globl vector186
vector186:
  pushl $0
801076b1:	6a 00                	push   $0x0
  pushl $186
801076b3:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801076b8:	e9 78 f0 ff ff       	jmp    80106735 <alltraps>

801076bd <vector187>:
.globl vector187
vector187:
  pushl $0
801076bd:	6a 00                	push   $0x0
  pushl $187
801076bf:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801076c4:	e9 6c f0 ff ff       	jmp    80106735 <alltraps>

801076c9 <vector188>:
.globl vector188
vector188:
  pushl $0
801076c9:	6a 00                	push   $0x0
  pushl $188
801076cb:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801076d0:	e9 60 f0 ff ff       	jmp    80106735 <alltraps>

801076d5 <vector189>:
.globl vector189
vector189:
  pushl $0
801076d5:	6a 00                	push   $0x0
  pushl $189
801076d7:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076dc:	e9 54 f0 ff ff       	jmp    80106735 <alltraps>

801076e1 <vector190>:
.globl vector190
vector190:
  pushl $0
801076e1:	6a 00                	push   $0x0
  pushl $190
801076e3:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076e8:	e9 48 f0 ff ff       	jmp    80106735 <alltraps>

801076ed <vector191>:
.globl vector191
vector191:
  pushl $0
801076ed:	6a 00                	push   $0x0
  pushl $191
801076ef:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076f4:	e9 3c f0 ff ff       	jmp    80106735 <alltraps>

801076f9 <vector192>:
.globl vector192
vector192:
  pushl $0
801076f9:	6a 00                	push   $0x0
  pushl $192
801076fb:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107700:	e9 30 f0 ff ff       	jmp    80106735 <alltraps>

80107705 <vector193>:
.globl vector193
vector193:
  pushl $0
80107705:	6a 00                	push   $0x0
  pushl $193
80107707:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010770c:	e9 24 f0 ff ff       	jmp    80106735 <alltraps>

80107711 <vector194>:
.globl vector194
vector194:
  pushl $0
80107711:	6a 00                	push   $0x0
  pushl $194
80107713:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107718:	e9 18 f0 ff ff       	jmp    80106735 <alltraps>

8010771d <vector195>:
.globl vector195
vector195:
  pushl $0
8010771d:	6a 00                	push   $0x0
  pushl $195
8010771f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107724:	e9 0c f0 ff ff       	jmp    80106735 <alltraps>

80107729 <vector196>:
.globl vector196
vector196:
  pushl $0
80107729:	6a 00                	push   $0x0
  pushl $196
8010772b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107730:	e9 00 f0 ff ff       	jmp    80106735 <alltraps>

80107735 <vector197>:
.globl vector197
vector197:
  pushl $0
80107735:	6a 00                	push   $0x0
  pushl $197
80107737:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010773c:	e9 f4 ef ff ff       	jmp    80106735 <alltraps>

80107741 <vector198>:
.globl vector198
vector198:
  pushl $0
80107741:	6a 00                	push   $0x0
  pushl $198
80107743:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107748:	e9 e8 ef ff ff       	jmp    80106735 <alltraps>

8010774d <vector199>:
.globl vector199
vector199:
  pushl $0
8010774d:	6a 00                	push   $0x0
  pushl $199
8010774f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107754:	e9 dc ef ff ff       	jmp    80106735 <alltraps>

80107759 <vector200>:
.globl vector200
vector200:
  pushl $0
80107759:	6a 00                	push   $0x0
  pushl $200
8010775b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107760:	e9 d0 ef ff ff       	jmp    80106735 <alltraps>

80107765 <vector201>:
.globl vector201
vector201:
  pushl $0
80107765:	6a 00                	push   $0x0
  pushl $201
80107767:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010776c:	e9 c4 ef ff ff       	jmp    80106735 <alltraps>

80107771 <vector202>:
.globl vector202
vector202:
  pushl $0
80107771:	6a 00                	push   $0x0
  pushl $202
80107773:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107778:	e9 b8 ef ff ff       	jmp    80106735 <alltraps>

8010777d <vector203>:
.globl vector203
vector203:
  pushl $0
8010777d:	6a 00                	push   $0x0
  pushl $203
8010777f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107784:	e9 ac ef ff ff       	jmp    80106735 <alltraps>

80107789 <vector204>:
.globl vector204
vector204:
  pushl $0
80107789:	6a 00                	push   $0x0
  pushl $204
8010778b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107790:	e9 a0 ef ff ff       	jmp    80106735 <alltraps>

80107795 <vector205>:
.globl vector205
vector205:
  pushl $0
80107795:	6a 00                	push   $0x0
  pushl $205
80107797:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010779c:	e9 94 ef ff ff       	jmp    80106735 <alltraps>

801077a1 <vector206>:
.globl vector206
vector206:
  pushl $0
801077a1:	6a 00                	push   $0x0
  pushl $206
801077a3:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801077a8:	e9 88 ef ff ff       	jmp    80106735 <alltraps>

801077ad <vector207>:
.globl vector207
vector207:
  pushl $0
801077ad:	6a 00                	push   $0x0
  pushl $207
801077af:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801077b4:	e9 7c ef ff ff       	jmp    80106735 <alltraps>

801077b9 <vector208>:
.globl vector208
vector208:
  pushl $0
801077b9:	6a 00                	push   $0x0
  pushl $208
801077bb:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801077c0:	e9 70 ef ff ff       	jmp    80106735 <alltraps>

801077c5 <vector209>:
.globl vector209
vector209:
  pushl $0
801077c5:	6a 00                	push   $0x0
  pushl $209
801077c7:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077cc:	e9 64 ef ff ff       	jmp    80106735 <alltraps>

801077d1 <vector210>:
.globl vector210
vector210:
  pushl $0
801077d1:	6a 00                	push   $0x0
  pushl $210
801077d3:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077d8:	e9 58 ef ff ff       	jmp    80106735 <alltraps>

801077dd <vector211>:
.globl vector211
vector211:
  pushl $0
801077dd:	6a 00                	push   $0x0
  pushl $211
801077df:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077e4:	e9 4c ef ff ff       	jmp    80106735 <alltraps>

801077e9 <vector212>:
.globl vector212
vector212:
  pushl $0
801077e9:	6a 00                	push   $0x0
  pushl $212
801077eb:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077f0:	e9 40 ef ff ff       	jmp    80106735 <alltraps>

801077f5 <vector213>:
.globl vector213
vector213:
  pushl $0
801077f5:	6a 00                	push   $0x0
  pushl $213
801077f7:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077fc:	e9 34 ef ff ff       	jmp    80106735 <alltraps>

80107801 <vector214>:
.globl vector214
vector214:
  pushl $0
80107801:	6a 00                	push   $0x0
  pushl $214
80107803:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107808:	e9 28 ef ff ff       	jmp    80106735 <alltraps>

8010780d <vector215>:
.globl vector215
vector215:
  pushl $0
8010780d:	6a 00                	push   $0x0
  pushl $215
8010780f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107814:	e9 1c ef ff ff       	jmp    80106735 <alltraps>

80107819 <vector216>:
.globl vector216
vector216:
  pushl $0
80107819:	6a 00                	push   $0x0
  pushl $216
8010781b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107820:	e9 10 ef ff ff       	jmp    80106735 <alltraps>

80107825 <vector217>:
.globl vector217
vector217:
  pushl $0
80107825:	6a 00                	push   $0x0
  pushl $217
80107827:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010782c:	e9 04 ef ff ff       	jmp    80106735 <alltraps>

80107831 <vector218>:
.globl vector218
vector218:
  pushl $0
80107831:	6a 00                	push   $0x0
  pushl $218
80107833:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107838:	e9 f8 ee ff ff       	jmp    80106735 <alltraps>

8010783d <vector219>:
.globl vector219
vector219:
  pushl $0
8010783d:	6a 00                	push   $0x0
  pushl $219
8010783f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107844:	e9 ec ee ff ff       	jmp    80106735 <alltraps>

80107849 <vector220>:
.globl vector220
vector220:
  pushl $0
80107849:	6a 00                	push   $0x0
  pushl $220
8010784b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107850:	e9 e0 ee ff ff       	jmp    80106735 <alltraps>

80107855 <vector221>:
.globl vector221
vector221:
  pushl $0
80107855:	6a 00                	push   $0x0
  pushl $221
80107857:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010785c:	e9 d4 ee ff ff       	jmp    80106735 <alltraps>

80107861 <vector222>:
.globl vector222
vector222:
  pushl $0
80107861:	6a 00                	push   $0x0
  pushl $222
80107863:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107868:	e9 c8 ee ff ff       	jmp    80106735 <alltraps>

8010786d <vector223>:
.globl vector223
vector223:
  pushl $0
8010786d:	6a 00                	push   $0x0
  pushl $223
8010786f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107874:	e9 bc ee ff ff       	jmp    80106735 <alltraps>

80107879 <vector224>:
.globl vector224
vector224:
  pushl $0
80107879:	6a 00                	push   $0x0
  pushl $224
8010787b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107880:	e9 b0 ee ff ff       	jmp    80106735 <alltraps>

80107885 <vector225>:
.globl vector225
vector225:
  pushl $0
80107885:	6a 00                	push   $0x0
  pushl $225
80107887:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010788c:	e9 a4 ee ff ff       	jmp    80106735 <alltraps>

80107891 <vector226>:
.globl vector226
vector226:
  pushl $0
80107891:	6a 00                	push   $0x0
  pushl $226
80107893:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107898:	e9 98 ee ff ff       	jmp    80106735 <alltraps>

8010789d <vector227>:
.globl vector227
vector227:
  pushl $0
8010789d:	6a 00                	push   $0x0
  pushl $227
8010789f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801078a4:	e9 8c ee ff ff       	jmp    80106735 <alltraps>

801078a9 <vector228>:
.globl vector228
vector228:
  pushl $0
801078a9:	6a 00                	push   $0x0
  pushl $228
801078ab:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801078b0:	e9 80 ee ff ff       	jmp    80106735 <alltraps>

801078b5 <vector229>:
.globl vector229
vector229:
  pushl $0
801078b5:	6a 00                	push   $0x0
  pushl $229
801078b7:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801078bc:	e9 74 ee ff ff       	jmp    80106735 <alltraps>

801078c1 <vector230>:
.globl vector230
vector230:
  pushl $0
801078c1:	6a 00                	push   $0x0
  pushl $230
801078c3:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801078c8:	e9 68 ee ff ff       	jmp    80106735 <alltraps>

801078cd <vector231>:
.globl vector231
vector231:
  pushl $0
801078cd:	6a 00                	push   $0x0
  pushl $231
801078cf:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801078d4:	e9 5c ee ff ff       	jmp    80106735 <alltraps>

801078d9 <vector232>:
.globl vector232
vector232:
  pushl $0
801078d9:	6a 00                	push   $0x0
  pushl $232
801078db:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078e0:	e9 50 ee ff ff       	jmp    80106735 <alltraps>

801078e5 <vector233>:
.globl vector233
vector233:
  pushl $0
801078e5:	6a 00                	push   $0x0
  pushl $233
801078e7:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078ec:	e9 44 ee ff ff       	jmp    80106735 <alltraps>

801078f1 <vector234>:
.globl vector234
vector234:
  pushl $0
801078f1:	6a 00                	push   $0x0
  pushl $234
801078f3:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078f8:	e9 38 ee ff ff       	jmp    80106735 <alltraps>

801078fd <vector235>:
.globl vector235
vector235:
  pushl $0
801078fd:	6a 00                	push   $0x0
  pushl $235
801078ff:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107904:	e9 2c ee ff ff       	jmp    80106735 <alltraps>

80107909 <vector236>:
.globl vector236
vector236:
  pushl $0
80107909:	6a 00                	push   $0x0
  pushl $236
8010790b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107910:	e9 20 ee ff ff       	jmp    80106735 <alltraps>

80107915 <vector237>:
.globl vector237
vector237:
  pushl $0
80107915:	6a 00                	push   $0x0
  pushl $237
80107917:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010791c:	e9 14 ee ff ff       	jmp    80106735 <alltraps>

80107921 <vector238>:
.globl vector238
vector238:
  pushl $0
80107921:	6a 00                	push   $0x0
  pushl $238
80107923:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107928:	e9 08 ee ff ff       	jmp    80106735 <alltraps>

8010792d <vector239>:
.globl vector239
vector239:
  pushl $0
8010792d:	6a 00                	push   $0x0
  pushl $239
8010792f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107934:	e9 fc ed ff ff       	jmp    80106735 <alltraps>

80107939 <vector240>:
.globl vector240
vector240:
  pushl $0
80107939:	6a 00                	push   $0x0
  pushl $240
8010793b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107940:	e9 f0 ed ff ff       	jmp    80106735 <alltraps>

80107945 <vector241>:
.globl vector241
vector241:
  pushl $0
80107945:	6a 00                	push   $0x0
  pushl $241
80107947:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010794c:	e9 e4 ed ff ff       	jmp    80106735 <alltraps>

80107951 <vector242>:
.globl vector242
vector242:
  pushl $0
80107951:	6a 00                	push   $0x0
  pushl $242
80107953:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107958:	e9 d8 ed ff ff       	jmp    80106735 <alltraps>

8010795d <vector243>:
.globl vector243
vector243:
  pushl $0
8010795d:	6a 00                	push   $0x0
  pushl $243
8010795f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107964:	e9 cc ed ff ff       	jmp    80106735 <alltraps>

80107969 <vector244>:
.globl vector244
vector244:
  pushl $0
80107969:	6a 00                	push   $0x0
  pushl $244
8010796b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107970:	e9 c0 ed ff ff       	jmp    80106735 <alltraps>

80107975 <vector245>:
.globl vector245
vector245:
  pushl $0
80107975:	6a 00                	push   $0x0
  pushl $245
80107977:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010797c:	e9 b4 ed ff ff       	jmp    80106735 <alltraps>

80107981 <vector246>:
.globl vector246
vector246:
  pushl $0
80107981:	6a 00                	push   $0x0
  pushl $246
80107983:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107988:	e9 a8 ed ff ff       	jmp    80106735 <alltraps>

8010798d <vector247>:
.globl vector247
vector247:
  pushl $0
8010798d:	6a 00                	push   $0x0
  pushl $247
8010798f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107994:	e9 9c ed ff ff       	jmp    80106735 <alltraps>

80107999 <vector248>:
.globl vector248
vector248:
  pushl $0
80107999:	6a 00                	push   $0x0
  pushl $248
8010799b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801079a0:	e9 90 ed ff ff       	jmp    80106735 <alltraps>

801079a5 <vector249>:
.globl vector249
vector249:
  pushl $0
801079a5:	6a 00                	push   $0x0
  pushl $249
801079a7:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801079ac:	e9 84 ed ff ff       	jmp    80106735 <alltraps>

801079b1 <vector250>:
.globl vector250
vector250:
  pushl $0
801079b1:	6a 00                	push   $0x0
  pushl $250
801079b3:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801079b8:	e9 78 ed ff ff       	jmp    80106735 <alltraps>

801079bd <vector251>:
.globl vector251
vector251:
  pushl $0
801079bd:	6a 00                	push   $0x0
  pushl $251
801079bf:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801079c4:	e9 6c ed ff ff       	jmp    80106735 <alltraps>

801079c9 <vector252>:
.globl vector252
vector252:
  pushl $0
801079c9:	6a 00                	push   $0x0
  pushl $252
801079cb:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801079d0:	e9 60 ed ff ff       	jmp    80106735 <alltraps>

801079d5 <vector253>:
.globl vector253
vector253:
  pushl $0
801079d5:	6a 00                	push   $0x0
  pushl $253
801079d7:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079dc:	e9 54 ed ff ff       	jmp    80106735 <alltraps>

801079e1 <vector254>:
.globl vector254
vector254:
  pushl $0
801079e1:	6a 00                	push   $0x0
  pushl $254
801079e3:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079e8:	e9 48 ed ff ff       	jmp    80106735 <alltraps>

801079ed <vector255>:
.globl vector255
vector255:
  pushl $0
801079ed:	6a 00                	push   $0x0
  pushl $255
801079ef:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079f4:	e9 3c ed ff ff       	jmp    80106735 <alltraps>

801079f9 <lgdt>:
{
801079f9:	55                   	push   %ebp
801079fa:	89 e5                	mov    %esp,%ebp
801079fc:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801079ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a02:	83 e8 01             	sub    $0x1,%eax
80107a05:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a09:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a10:	8b 45 08             	mov    0x8(%ebp),%eax
80107a13:	c1 e8 10             	shr    $0x10,%eax
80107a16:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107a1a:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a1d:	0f 01 10             	lgdtl  (%eax)
}
80107a20:	90                   	nop
80107a21:	c9                   	leave  
80107a22:	c3                   	ret    

80107a23 <ltr>:
{
80107a23:	55                   	push   %ebp
80107a24:	89 e5                	mov    %esp,%ebp
80107a26:	83 ec 04             	sub    $0x4,%esp
80107a29:	8b 45 08             	mov    0x8(%ebp),%eax
80107a2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a30:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a34:	0f 00 d8             	ltr    %ax
}
80107a37:	90                   	nop
80107a38:	c9                   	leave  
80107a39:	c3                   	ret    

80107a3a <lcr3>:

static inline void
lcr3(uint val)
{
80107a3a:	55                   	push   %ebp
80107a3b:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a40:	0f 22 d8             	mov    %eax,%cr3
}
80107a43:	90                   	nop
80107a44:	5d                   	pop    %ebp
80107a45:	c3                   	ret    

80107a46 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a46:	55                   	push   %ebp
80107a47:	89 e5                	mov    %esp,%ebp
80107a49:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107a4c:	e8 5e c4 ff ff       	call   80103eaf <cpuid>
80107a51:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107a57:	05 00 a7 11 80       	add    $0x8011a700,%eax
80107a5c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a62:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a74:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a7f:	83 e2 f0             	and    $0xfffffff0,%edx
80107a82:	83 ca 0a             	or     $0xa,%edx
80107a85:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a8f:	83 ca 10             	or     $0x10,%edx
80107a92:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a98:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a9c:	83 e2 9f             	and    $0xffffff9f,%edx
80107a9f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aa9:	83 ca 80             	or     $0xffffff80,%edx
80107aac:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ab6:	83 ca 0f             	or     $0xf,%edx
80107ab9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ac3:	83 e2 ef             	and    $0xffffffef,%edx
80107ac6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ad0:	83 e2 df             	and    $0xffffffdf,%edx
80107ad3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107add:	83 ca 40             	or     $0x40,%edx
80107ae0:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107aea:	83 ca 80             	or     $0xffffff80,%edx
80107aed:	88 50 7e             	mov    %dl,0x7e(%eax)
80107af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af3:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afa:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b01:	ff ff 
80107b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b06:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b0d:	00 00 
80107b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b12:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b23:	83 e2 f0             	and    $0xfffffff0,%edx
80107b26:	83 ca 02             	or     $0x2,%edx
80107b29:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b32:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b39:	83 ca 10             	or     $0x10,%edx
80107b3c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b45:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b4c:	83 e2 9f             	and    $0xffffff9f,%edx
80107b4f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b58:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b5f:	83 ca 80             	or     $0xffffff80,%edx
80107b62:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b72:	83 ca 0f             	or     $0xf,%edx
80107b75:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b85:	83 e2 ef             	and    $0xffffffef,%edx
80107b88:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b91:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b98:	83 e2 df             	and    $0xffffffdf,%edx
80107b9b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bab:	83 ca 40             	or     $0x40,%edx
80107bae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bbe:	83 ca 80             	or     $0xffffff80,%edx
80107bc1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bca:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd4:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107bdb:	ff ff 
80107bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be0:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107be7:	00 00 
80107be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bec:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bfd:	83 e2 f0             	and    $0xfffffff0,%edx
80107c00:	83 ca 0a             	or     $0xa,%edx
80107c03:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c13:	83 ca 10             	or     $0x10,%edx
80107c16:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c26:	83 ca 60             	or     $0x60,%edx
80107c29:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c32:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c39:	83 ca 80             	or     $0xffffff80,%edx
80107c3c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c45:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c4c:	83 ca 0f             	or     $0xf,%edx
80107c4f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c58:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c5f:	83 e2 ef             	and    $0xffffffef,%edx
80107c62:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c72:	83 e2 df             	and    $0xffffffdf,%edx
80107c75:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c85:	83 ca 40             	or     $0x40,%edx
80107c88:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c91:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c98:	83 ca 80             	or     $0xffffff80,%edx
80107c9b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca4:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cae:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107cb5:	ff ff 
80107cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cba:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107cc1:	00 00 
80107cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc6:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cd7:	83 e2 f0             	and    $0xfffffff0,%edx
80107cda:	83 ca 02             	or     $0x2,%edx
80107cdd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ced:	83 ca 10             	or     $0x10,%edx
80107cf0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d00:	83 ca 60             	or     $0x60,%edx
80107d03:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d13:	83 ca 80             	or     $0xffffff80,%edx
80107d16:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d26:	83 ca 0f             	or     $0xf,%edx
80107d29:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d32:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d39:	83 e2 ef             	and    $0xffffffef,%edx
80107d3c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d45:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d4c:	83 e2 df             	and    $0xffffffdf,%edx
80107d4f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d58:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d5f:	83 ca 40             	or     $0x40,%edx
80107d62:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d72:	83 ca 80             	or     $0xffffff80,%edx
80107d75:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d88:	83 c0 70             	add    $0x70,%eax
80107d8b:	83 ec 08             	sub    $0x8,%esp
80107d8e:	6a 30                	push   $0x30
80107d90:	50                   	push   %eax
80107d91:	e8 63 fc ff ff       	call   801079f9 <lgdt>
80107d96:	83 c4 10             	add    $0x10,%esp
}
80107d99:	90                   	nop
80107d9a:	c9                   	leave  
80107d9b:	c3                   	ret    

80107d9c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107d9c:	55                   	push   %ebp
80107d9d:	89 e5                	mov    %esp,%ebp
80107d9f:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107da5:	c1 e8 16             	shr    $0x16,%eax
80107da8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107daf:	8b 45 08             	mov    0x8(%ebp),%eax
80107db2:	01 d0                	add    %edx,%eax
80107db4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dba:	8b 00                	mov    (%eax),%eax
80107dbc:	83 e0 01             	and    $0x1,%eax
80107dbf:	85 c0                	test   %eax,%eax
80107dc1:	74 14                	je     80107dd7 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dc6:	8b 00                	mov    (%eax),%eax
80107dc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dcd:	05 00 00 00 80       	add    $0x80000000,%eax
80107dd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107dd5:	eb 42                	jmp    80107e19 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107dd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ddb:	74 0e                	je     80107deb <walkpgdir+0x4f>
80107ddd:	e8 a2 ae ff ff       	call   80102c84 <kalloc>
80107de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107de5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107de9:	75 07                	jne    80107df2 <walkpgdir+0x56>
      return 0;
80107deb:	b8 00 00 00 00       	mov    $0x0,%eax
80107df0:	eb 3e                	jmp    80107e30 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107df2:	83 ec 04             	sub    $0x4,%esp
80107df5:	68 00 10 00 00       	push   $0x1000
80107dfa:	6a 00                	push   $0x0
80107dfc:	ff 75 f4             	push   -0xc(%ebp)
80107dff:	e8 3c d5 ff ff       	call   80105340 <memset>
80107e04:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0a:	05 00 00 00 80       	add    $0x80000000,%eax
80107e0f:	83 c8 07             	or     $0x7,%eax
80107e12:	89 c2                	mov    %eax,%edx
80107e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e17:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107e19:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e1c:	c1 e8 0c             	shr    $0xc,%eax
80107e1f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107e24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2e:	01 d0                	add    %edx,%eax
}
80107e30:	c9                   	leave  
80107e31:	c3                   	ret    

80107e32 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107e32:	55                   	push   %ebp
80107e33:	89 e5                	mov    %esp,%ebp
80107e35:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107e38:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e43:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e46:	8b 45 10             	mov    0x10(%ebp),%eax
80107e49:	01 d0                	add    %edx,%eax
80107e4b:	83 e8 01             	sub    $0x1,%eax
80107e4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e56:	83 ec 04             	sub    $0x4,%esp
80107e59:	6a 01                	push   $0x1
80107e5b:	ff 75 f4             	push   -0xc(%ebp)
80107e5e:	ff 75 08             	push   0x8(%ebp)
80107e61:	e8 36 ff ff ff       	call   80107d9c <walkpgdir>
80107e66:	83 c4 10             	add    $0x10,%esp
80107e69:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e70:	75 07                	jne    80107e79 <mappages+0x47>
      return -1;
80107e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e77:	eb 47                	jmp    80107ec0 <mappages+0x8e>
    if(*pte & PTE_P)
80107e79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e7c:	8b 00                	mov    (%eax),%eax
80107e7e:	83 e0 01             	and    $0x1,%eax
80107e81:	85 c0                	test   %eax,%eax
80107e83:	74 0d                	je     80107e92 <mappages+0x60>
      panic("remap");
80107e85:	83 ec 0c             	sub    $0xc,%esp
80107e88:	68 84 b1 10 80       	push   $0x8010b184
80107e8d:	e8 17 87 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107e92:	8b 45 18             	mov    0x18(%ebp),%eax
80107e95:	0b 45 14             	or     0x14(%ebp),%eax
80107e98:	83 c8 01             	or     $0x1,%eax
80107e9b:	89 c2                	mov    %eax,%edx
80107e9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ea0:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ea8:	74 10                	je     80107eba <mappages+0x88>
      break;
    a += PGSIZE;
80107eaa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107eb1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107eb8:	eb 9c                	jmp    80107e56 <mappages+0x24>
      break;
80107eba:	90                   	nop
  }
  return 0;
80107ebb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ec0:	c9                   	leave  
80107ec1:	c3                   	ret    

80107ec2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ec2:	55                   	push   %ebp
80107ec3:	89 e5                	mov    %esp,%ebp
80107ec5:	53                   	push   %ebx
80107ec6:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107ec9:	c7 45 f4 c0 f4 10 80 	movl   $0x8010f4c0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107ed0:	8b 15 e0 a9 11 80    	mov    0x8011a9e0,%edx
80107ed6:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107edb:	29 d0                	sub    %edx,%eax
80107edd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ee0:	a1 d8 a9 11 80       	mov    0x8011a9d8,%eax
80107ee5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107ee8:	8b 15 d8 a9 11 80    	mov    0x8011a9d8,%edx
80107eee:	a1 e0 a9 11 80       	mov    0x8011a9e0,%eax
80107ef3:	01 d0                	add    %edx,%eax
80107ef5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107ef8:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f02:	83 c0 30             	add    $0x30,%eax
80107f05:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107f08:	89 10                	mov    %edx,(%eax)
80107f0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f0d:	89 50 04             	mov    %edx,0x4(%eax)
80107f10:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107f13:	89 50 08             	mov    %edx,0x8(%eax)
80107f16:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107f19:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107f1c:	e8 63 ad ff ff       	call   80102c84 <kalloc>
80107f21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f28:	75 07                	jne    80107f31 <setupkvm+0x6f>
    return 0;
80107f2a:	b8 00 00 00 00       	mov    $0x0,%eax
80107f2f:	eb 78                	jmp    80107fa9 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107f31:	83 ec 04             	sub    $0x4,%esp
80107f34:	68 00 10 00 00       	push   $0x1000
80107f39:	6a 00                	push   $0x0
80107f3b:	ff 75 f0             	push   -0x10(%ebp)
80107f3e:	e8 fd d3 ff ff       	call   80105340 <memset>
80107f43:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f46:	c7 45 f4 c0 f4 10 80 	movl   $0x8010f4c0,-0xc(%ebp)
80107f4d:	eb 4e                	jmp    80107f9d <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f52:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5e:	8b 58 08             	mov    0x8(%eax),%ebx
80107f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f64:	8b 40 04             	mov    0x4(%eax),%eax
80107f67:	29 c3                	sub    %eax,%ebx
80107f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6c:	8b 00                	mov    (%eax),%eax
80107f6e:	83 ec 0c             	sub    $0xc,%esp
80107f71:	51                   	push   %ecx
80107f72:	52                   	push   %edx
80107f73:	53                   	push   %ebx
80107f74:	50                   	push   %eax
80107f75:	ff 75 f0             	push   -0x10(%ebp)
80107f78:	e8 b5 fe ff ff       	call   80107e32 <mappages>
80107f7d:	83 c4 20             	add    $0x20,%esp
80107f80:	85 c0                	test   %eax,%eax
80107f82:	79 15                	jns    80107f99 <setupkvm+0xd7>
      freevm(pgdir);
80107f84:	83 ec 0c             	sub    $0xc,%esp
80107f87:	ff 75 f0             	push   -0x10(%ebp)
80107f8a:	e8 f5 04 00 00       	call   80108484 <freevm>
80107f8f:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f92:	b8 00 00 00 00       	mov    $0x0,%eax
80107f97:	eb 10                	jmp    80107fa9 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f99:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f9d:	81 7d f4 20 f5 10 80 	cmpl   $0x8010f520,-0xc(%ebp)
80107fa4:	72 a9                	jb     80107f4f <setupkvm+0x8d>
    }
  return pgdir;
80107fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107fa9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107fac:	c9                   	leave  
80107fad:	c3                   	ret    

80107fae <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107fae:	55                   	push   %ebp
80107faf:	89 e5                	mov    %esp,%ebp
80107fb1:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107fb4:	e8 09 ff ff ff       	call   80107ec2 <setupkvm>
80107fb9:	a3 fc a6 11 80       	mov    %eax,0x8011a6fc
  switchkvm();
80107fbe:	e8 03 00 00 00       	call   80107fc6 <switchkvm>
}
80107fc3:	90                   	nop
80107fc4:	c9                   	leave  
80107fc5:	c3                   	ret    

80107fc6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107fc6:	55                   	push   %ebp
80107fc7:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107fc9:	a1 fc a6 11 80       	mov    0x8011a6fc,%eax
80107fce:	05 00 00 00 80       	add    $0x80000000,%eax
80107fd3:	50                   	push   %eax
80107fd4:	e8 61 fa ff ff       	call   80107a3a <lcr3>
80107fd9:	83 c4 04             	add    $0x4,%esp
}
80107fdc:	90                   	nop
80107fdd:	c9                   	leave  
80107fde:	c3                   	ret    

80107fdf <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107fdf:	55                   	push   %ebp
80107fe0:	89 e5                	mov    %esp,%ebp
80107fe2:	56                   	push   %esi
80107fe3:	53                   	push   %ebx
80107fe4:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107fe7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107feb:	75 0d                	jne    80107ffa <switchuvm+0x1b>
    panic("switchuvm: no process");
80107fed:	83 ec 0c             	sub    $0xc,%esp
80107ff0:	68 8a b1 10 80       	push   $0x8010b18a
80107ff5:	e8 af 85 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80107ffd:	8b 40 08             	mov    0x8(%eax),%eax
80108000:	85 c0                	test   %eax,%eax
80108002:	75 0d                	jne    80108011 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80108004:	83 ec 0c             	sub    $0xc,%esp
80108007:	68 a0 b1 10 80       	push   $0x8010b1a0
8010800c:	e8 98 85 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80108011:	8b 45 08             	mov    0x8(%ebp),%eax
80108014:	8b 40 04             	mov    0x4(%eax),%eax
80108017:	85 c0                	test   %eax,%eax
80108019:	75 0d                	jne    80108028 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010801b:	83 ec 0c             	sub    $0xc,%esp
8010801e:	68 b5 b1 10 80       	push   $0x8010b1b5
80108023:	e8 81 85 ff ff       	call   801005a9 <panic>

  pushcli();
80108028:	e8 08 d2 ff ff       	call   80105235 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010802d:	e8 98 be ff ff       	call   80103eca <mycpu>
80108032:	89 c3                	mov    %eax,%ebx
80108034:	e8 91 be ff ff       	call   80103eca <mycpu>
80108039:	83 c0 08             	add    $0x8,%eax
8010803c:	89 c6                	mov    %eax,%esi
8010803e:	e8 87 be ff ff       	call   80103eca <mycpu>
80108043:	83 c0 08             	add    $0x8,%eax
80108046:	c1 e8 10             	shr    $0x10,%eax
80108049:	88 45 f7             	mov    %al,-0x9(%ebp)
8010804c:	e8 79 be ff ff       	call   80103eca <mycpu>
80108051:	83 c0 08             	add    $0x8,%eax
80108054:	c1 e8 18             	shr    $0x18,%eax
80108057:	89 c2                	mov    %eax,%edx
80108059:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108060:	67 00 
80108062:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108069:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010806d:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108073:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010807a:	83 e0 f0             	and    $0xfffffff0,%eax
8010807d:	83 c8 09             	or     $0x9,%eax
80108080:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108086:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010808d:	83 c8 10             	or     $0x10,%eax
80108090:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108096:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010809d:	83 e0 9f             	and    $0xffffff9f,%eax
801080a0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801080a6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801080ad:	83 c8 80             	or     $0xffffff80,%eax
801080b0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801080b6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080bd:	83 e0 f0             	and    $0xfffffff0,%eax
801080c0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080c6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080cd:	83 e0 ef             	and    $0xffffffef,%eax
801080d0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080d6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080dd:	83 e0 df             	and    $0xffffffdf,%eax
801080e0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080e6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080ed:	83 c8 40             	or     $0x40,%eax
801080f0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080f6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080fd:	83 e0 7f             	and    $0x7f,%eax
80108100:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108106:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010810c:	e8 b9 bd ff ff       	call   80103eca <mycpu>
80108111:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108118:	83 e2 ef             	and    $0xffffffef,%edx
8010811b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108121:	e8 a4 bd ff ff       	call   80103eca <mycpu>
80108126:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010812c:	8b 45 08             	mov    0x8(%ebp),%eax
8010812f:	8b 40 08             	mov    0x8(%eax),%eax
80108132:	89 c3                	mov    %eax,%ebx
80108134:	e8 91 bd ff ff       	call   80103eca <mycpu>
80108139:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
8010813f:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108142:	e8 83 bd ff ff       	call   80103eca <mycpu>
80108147:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010814d:	83 ec 0c             	sub    $0xc,%esp
80108150:	6a 28                	push   $0x28
80108152:	e8 cc f8 ff ff       	call   80107a23 <ltr>
80108157:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010815a:	8b 45 08             	mov    0x8(%ebp),%eax
8010815d:	8b 40 04             	mov    0x4(%eax),%eax
80108160:	05 00 00 00 80       	add    $0x80000000,%eax
80108165:	83 ec 0c             	sub    $0xc,%esp
80108168:	50                   	push   %eax
80108169:	e8 cc f8 ff ff       	call   80107a3a <lcr3>
8010816e:	83 c4 10             	add    $0x10,%esp
  popcli();
80108171:	e8 0c d1 ff ff       	call   80105282 <popcli>
}
80108176:	90                   	nop
80108177:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010817a:	5b                   	pop    %ebx
8010817b:	5e                   	pop    %esi
8010817c:	5d                   	pop    %ebp
8010817d:	c3                   	ret    

8010817e <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010817e:	55                   	push   %ebp
8010817f:	89 e5                	mov    %esp,%ebp
80108181:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108184:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010818b:	76 0d                	jbe    8010819a <inituvm+0x1c>
    panic("inituvm: more than a page");
8010818d:	83 ec 0c             	sub    $0xc,%esp
80108190:	68 c9 b1 10 80       	push   $0x8010b1c9
80108195:	e8 0f 84 ff ff       	call   801005a9 <panic>
  mem = kalloc();
8010819a:	e8 e5 aa ff ff       	call   80102c84 <kalloc>
8010819f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801081a2:	83 ec 04             	sub    $0x4,%esp
801081a5:	68 00 10 00 00       	push   $0x1000
801081aa:	6a 00                	push   $0x0
801081ac:	ff 75 f4             	push   -0xc(%ebp)
801081af:	e8 8c d1 ff ff       	call   80105340 <memset>
801081b4:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801081b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ba:	05 00 00 00 80       	add    $0x80000000,%eax
801081bf:	83 ec 0c             	sub    $0xc,%esp
801081c2:	6a 06                	push   $0x6
801081c4:	50                   	push   %eax
801081c5:	68 00 10 00 00       	push   $0x1000
801081ca:	6a 00                	push   $0x0
801081cc:	ff 75 08             	push   0x8(%ebp)
801081cf:	e8 5e fc ff ff       	call   80107e32 <mappages>
801081d4:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801081d7:	83 ec 04             	sub    $0x4,%esp
801081da:	ff 75 10             	push   0x10(%ebp)
801081dd:	ff 75 0c             	push   0xc(%ebp)
801081e0:	ff 75 f4             	push   -0xc(%ebp)
801081e3:	e8 17 d2 ff ff       	call   801053ff <memmove>
801081e8:	83 c4 10             	add    $0x10,%esp
}
801081eb:	90                   	nop
801081ec:	c9                   	leave  
801081ed:	c3                   	ret    

801081ee <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801081ee:	55                   	push   %ebp
801081ef:	89 e5                	mov    %esp,%ebp
801081f1:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801081f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801081f7:	25 ff 0f 00 00       	and    $0xfff,%eax
801081fc:	85 c0                	test   %eax,%eax
801081fe:	74 0d                	je     8010820d <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108200:	83 ec 0c             	sub    $0xc,%esp
80108203:	68 e4 b1 10 80       	push   $0x8010b1e4
80108208:	e8 9c 83 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010820d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108214:	e9 8f 00 00 00       	jmp    801082a8 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108219:	8b 55 0c             	mov    0xc(%ebp),%edx
8010821c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821f:	01 d0                	add    %edx,%eax
80108221:	83 ec 04             	sub    $0x4,%esp
80108224:	6a 00                	push   $0x0
80108226:	50                   	push   %eax
80108227:	ff 75 08             	push   0x8(%ebp)
8010822a:	e8 6d fb ff ff       	call   80107d9c <walkpgdir>
8010822f:	83 c4 10             	add    $0x10,%esp
80108232:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108235:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108239:	75 0d                	jne    80108248 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010823b:	83 ec 0c             	sub    $0xc,%esp
8010823e:	68 07 b2 10 80       	push   $0x8010b207
80108243:	e8 61 83 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80108248:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010824b:	8b 00                	mov    (%eax),%eax
8010824d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108252:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108255:	8b 45 18             	mov    0x18(%ebp),%eax
80108258:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010825b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108260:	77 0b                	ja     8010826d <loaduvm+0x7f>
      n = sz - i;
80108262:	8b 45 18             	mov    0x18(%ebp),%eax
80108265:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108268:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010826b:	eb 07                	jmp    80108274 <loaduvm+0x86>
    else
      n = PGSIZE;
8010826d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108274:	8b 55 14             	mov    0x14(%ebp),%edx
80108277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827a:	01 d0                	add    %edx,%eax
8010827c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010827f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108285:	ff 75 f0             	push   -0x10(%ebp)
80108288:	50                   	push   %eax
80108289:	52                   	push   %edx
8010828a:	ff 75 10             	push   0x10(%ebp)
8010828d:	e8 44 9c ff ff       	call   80101ed6 <readi>
80108292:	83 c4 10             	add    $0x10,%esp
80108295:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108298:	74 07                	je     801082a1 <loaduvm+0xb3>
      return -1;
8010829a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010829f:	eb 18                	jmp    801082b9 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801082a1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ab:	3b 45 18             	cmp    0x18(%ebp),%eax
801082ae:	0f 82 65 ff ff ff    	jb     80108219 <loaduvm+0x2b>
  }
  return 0;
801082b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082b9:	c9                   	leave  
801082ba:	c3                   	ret    

801082bb <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082bb:	55                   	push   %ebp
801082bc:	89 e5                	mov    %esp,%ebp
801082be:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801082c1:	8b 45 10             	mov    0x10(%ebp),%eax
801082c4:	85 c0                	test   %eax,%eax
801082c6:	79 0a                	jns    801082d2 <allocuvm+0x17>
    return 0;
801082c8:	b8 00 00 00 00       	mov    $0x0,%eax
801082cd:	e9 ec 00 00 00       	jmp    801083be <allocuvm+0x103>
  if(newsz < oldsz)
801082d2:	8b 45 10             	mov    0x10(%ebp),%eax
801082d5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082d8:	73 08                	jae    801082e2 <allocuvm+0x27>
    return oldsz;
801082da:	8b 45 0c             	mov    0xc(%ebp),%eax
801082dd:	e9 dc 00 00 00       	jmp    801083be <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801082e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801082e5:	05 ff 0f 00 00       	add    $0xfff,%eax
801082ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801082f2:	e9 b8 00 00 00       	jmp    801083af <allocuvm+0xf4>
    mem = kalloc();
801082f7:	e8 88 a9 ff ff       	call   80102c84 <kalloc>
801082fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108303:	75 2e                	jne    80108333 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80108305:	83 ec 0c             	sub    $0xc,%esp
80108308:	68 25 b2 10 80       	push   $0x8010b225
8010830d:	e8 e2 80 ff ff       	call   801003f4 <cprintf>
80108312:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108315:	83 ec 04             	sub    $0x4,%esp
80108318:	ff 75 0c             	push   0xc(%ebp)
8010831b:	ff 75 10             	push   0x10(%ebp)
8010831e:	ff 75 08             	push   0x8(%ebp)
80108321:	e8 9a 00 00 00       	call   801083c0 <deallocuvm>
80108326:	83 c4 10             	add    $0x10,%esp
      return 0;
80108329:	b8 00 00 00 00       	mov    $0x0,%eax
8010832e:	e9 8b 00 00 00       	jmp    801083be <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80108333:	83 ec 04             	sub    $0x4,%esp
80108336:	68 00 10 00 00       	push   $0x1000
8010833b:	6a 00                	push   $0x0
8010833d:	ff 75 f0             	push   -0x10(%ebp)
80108340:	e8 fb cf ff ff       	call   80105340 <memset>
80108345:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010834b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108354:	83 ec 0c             	sub    $0xc,%esp
80108357:	6a 06                	push   $0x6
80108359:	52                   	push   %edx
8010835a:	68 00 10 00 00       	push   $0x1000
8010835f:	50                   	push   %eax
80108360:	ff 75 08             	push   0x8(%ebp)
80108363:	e8 ca fa ff ff       	call   80107e32 <mappages>
80108368:	83 c4 20             	add    $0x20,%esp
8010836b:	85 c0                	test   %eax,%eax
8010836d:	79 39                	jns    801083a8 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010836f:	83 ec 0c             	sub    $0xc,%esp
80108372:	68 3d b2 10 80       	push   $0x8010b23d
80108377:	e8 78 80 ff ff       	call   801003f4 <cprintf>
8010837c:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010837f:	83 ec 04             	sub    $0x4,%esp
80108382:	ff 75 0c             	push   0xc(%ebp)
80108385:	ff 75 10             	push   0x10(%ebp)
80108388:	ff 75 08             	push   0x8(%ebp)
8010838b:	e8 30 00 00 00       	call   801083c0 <deallocuvm>
80108390:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108393:	83 ec 0c             	sub    $0xc,%esp
80108396:	ff 75 f0             	push   -0x10(%ebp)
80108399:	e8 4c a8 ff ff       	call   80102bea <kfree>
8010839e:	83 c4 10             	add    $0x10,%esp
      return 0;
801083a1:	b8 00 00 00 00       	mov    $0x0,%eax
801083a6:	eb 16                	jmp    801083be <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801083a8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b2:	3b 45 10             	cmp    0x10(%ebp),%eax
801083b5:	0f 82 3c ff ff ff    	jb     801082f7 <allocuvm+0x3c>
    }
  }
  return newsz;
801083bb:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083be:	c9                   	leave  
801083bf:	c3                   	ret    

801083c0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083c0:	55                   	push   %ebp
801083c1:	89 e5                	mov    %esp,%ebp
801083c3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801083c6:	8b 45 10             	mov    0x10(%ebp),%eax
801083c9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083cc:	72 08                	jb     801083d6 <deallocuvm+0x16>
    return oldsz;
801083ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d1:	e9 ac 00 00 00       	jmp    80108482 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801083d6:	8b 45 10             	mov    0x10(%ebp),%eax
801083d9:	05 ff 0f 00 00       	add    $0xfff,%eax
801083de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801083e6:	e9 88 00 00 00       	jmp    80108473 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801083eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ee:	83 ec 04             	sub    $0x4,%esp
801083f1:	6a 00                	push   $0x0
801083f3:	50                   	push   %eax
801083f4:	ff 75 08             	push   0x8(%ebp)
801083f7:	e8 a0 f9 ff ff       	call   80107d9c <walkpgdir>
801083fc:	83 c4 10             	add    $0x10,%esp
801083ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108402:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108406:	75 16                	jne    8010841e <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840b:	c1 e8 16             	shr    $0x16,%eax
8010840e:	83 c0 01             	add    $0x1,%eax
80108411:	c1 e0 16             	shl    $0x16,%eax
80108414:	2d 00 10 00 00       	sub    $0x1000,%eax
80108419:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010841c:	eb 4e                	jmp    8010846c <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010841e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108421:	8b 00                	mov    (%eax),%eax
80108423:	83 e0 01             	and    $0x1,%eax
80108426:	85 c0                	test   %eax,%eax
80108428:	74 42                	je     8010846c <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010842a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842d:	8b 00                	mov    (%eax),%eax
8010842f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108434:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108437:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010843b:	75 0d                	jne    8010844a <deallocuvm+0x8a>
        panic("kfree");
8010843d:	83 ec 0c             	sub    $0xc,%esp
80108440:	68 59 b2 10 80       	push   $0x8010b259
80108445:	e8 5f 81 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
8010844a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010844d:	05 00 00 00 80       	add    $0x80000000,%eax
80108452:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108455:	83 ec 0c             	sub    $0xc,%esp
80108458:	ff 75 e8             	push   -0x18(%ebp)
8010845b:	e8 8a a7 ff ff       	call   80102bea <kfree>
80108460:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108463:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010846c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108476:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108479:	0f 82 6c ff ff ff    	jb     801083eb <deallocuvm+0x2b>
    }
  }
  return newsz;
8010847f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108482:	c9                   	leave  
80108483:	c3                   	ret    

80108484 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108484:	55                   	push   %ebp
80108485:	89 e5                	mov    %esp,%ebp
80108487:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010848a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010848e:	75 0d                	jne    8010849d <freevm+0x19>
    panic("freevm: no pgdir");
80108490:	83 ec 0c             	sub    $0xc,%esp
80108493:	68 5f b2 10 80       	push   $0x8010b25f
80108498:	e8 0c 81 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010849d:	83 ec 04             	sub    $0x4,%esp
801084a0:	6a 00                	push   $0x0
801084a2:	68 00 00 00 80       	push   $0x80000000
801084a7:	ff 75 08             	push   0x8(%ebp)
801084aa:	e8 11 ff ff ff       	call   801083c0 <deallocuvm>
801084af:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801084b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084b9:	eb 48                	jmp    80108503 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801084bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084be:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084c5:	8b 45 08             	mov    0x8(%ebp),%eax
801084c8:	01 d0                	add    %edx,%eax
801084ca:	8b 00                	mov    (%eax),%eax
801084cc:	83 e0 01             	and    $0x1,%eax
801084cf:	85 c0                	test   %eax,%eax
801084d1:	74 2c                	je     801084ff <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801084d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084dd:	8b 45 08             	mov    0x8(%ebp),%eax
801084e0:	01 d0                	add    %edx,%eax
801084e2:	8b 00                	mov    (%eax),%eax
801084e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084e9:	05 00 00 00 80       	add    $0x80000000,%eax
801084ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801084f1:	83 ec 0c             	sub    $0xc,%esp
801084f4:	ff 75 f0             	push   -0x10(%ebp)
801084f7:	e8 ee a6 ff ff       	call   80102bea <kfree>
801084fc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801084ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108503:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010850a:	76 af                	jbe    801084bb <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010850c:	83 ec 0c             	sub    $0xc,%esp
8010850f:	ff 75 08             	push   0x8(%ebp)
80108512:	e8 d3 a6 ff ff       	call   80102bea <kfree>
80108517:	83 c4 10             	add    $0x10,%esp
}
8010851a:	90                   	nop
8010851b:	c9                   	leave  
8010851c:	c3                   	ret    

8010851d <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010851d:	55                   	push   %ebp
8010851e:	89 e5                	mov    %esp,%ebp
80108520:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108523:	83 ec 04             	sub    $0x4,%esp
80108526:	6a 00                	push   $0x0
80108528:	ff 75 0c             	push   0xc(%ebp)
8010852b:	ff 75 08             	push   0x8(%ebp)
8010852e:	e8 69 f8 ff ff       	call   80107d9c <walkpgdir>
80108533:	83 c4 10             	add    $0x10,%esp
80108536:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108539:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010853d:	75 0d                	jne    8010854c <clearpteu+0x2f>
    panic("clearpteu");
8010853f:	83 ec 0c             	sub    $0xc,%esp
80108542:	68 70 b2 10 80       	push   $0x8010b270
80108547:	e8 5d 80 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
8010854c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854f:	8b 00                	mov    (%eax),%eax
80108551:	83 e0 fb             	and    $0xfffffffb,%eax
80108554:	89 c2                	mov    %eax,%edx
80108556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108559:	89 10                	mov    %edx,(%eax)
}
8010855b:	90                   	nop
8010855c:	c9                   	leave  
8010855d:	c3                   	ret    

8010855e <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010855e:	55                   	push   %ebp
8010855f:	89 e5                	mov    %esp,%ebp
80108561:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108564:	e8 59 f9 ff ff       	call   80107ec2 <setupkvm>
80108569:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010856c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108570:	75 0a                	jne    8010857c <copyuvm+0x1e>
    return 0;
80108572:	b8 00 00 00 00       	mov    $0x0,%eax
80108577:	e9 eb 00 00 00       	jmp    80108667 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
8010857c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108583:	e9 b7 00 00 00       	jmp    8010863f <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858b:	83 ec 04             	sub    $0x4,%esp
8010858e:	6a 00                	push   $0x0
80108590:	50                   	push   %eax
80108591:	ff 75 08             	push   0x8(%ebp)
80108594:	e8 03 f8 ff ff       	call   80107d9c <walkpgdir>
80108599:	83 c4 10             	add    $0x10,%esp
8010859c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010859f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085a3:	75 0d                	jne    801085b2 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801085a5:	83 ec 0c             	sub    $0xc,%esp
801085a8:	68 7a b2 10 80       	push   $0x8010b27a
801085ad:	e8 f7 7f ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801085b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085b5:	8b 00                	mov    (%eax),%eax
801085b7:	83 e0 01             	and    $0x1,%eax
801085ba:	85 c0                	test   %eax,%eax
801085bc:	75 0d                	jne    801085cb <copyuvm+0x6d>
      panic("copyuvm: page not present");
801085be:	83 ec 0c             	sub    $0xc,%esp
801085c1:	68 94 b2 10 80       	push   $0x8010b294
801085c6:	e8 de 7f ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801085cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ce:	8b 00                	mov    (%eax),%eax
801085d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801085d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085db:	8b 00                	mov    (%eax),%eax
801085dd:	25 ff 0f 00 00       	and    $0xfff,%eax
801085e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801085e5:	e8 9a a6 ff ff       	call   80102c84 <kalloc>
801085ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
801085ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801085f1:	74 5d                	je     80108650 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801085f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085f6:	05 00 00 00 80       	add    $0x80000000,%eax
801085fb:	83 ec 04             	sub    $0x4,%esp
801085fe:	68 00 10 00 00       	push   $0x1000
80108603:	50                   	push   %eax
80108604:	ff 75 e0             	push   -0x20(%ebp)
80108607:	e8 f3 cd ff ff       	call   801053ff <memmove>
8010860c:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010860f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108612:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108615:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010861b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861e:	83 ec 0c             	sub    $0xc,%esp
80108621:	52                   	push   %edx
80108622:	51                   	push   %ecx
80108623:	68 00 10 00 00       	push   $0x1000
80108628:	50                   	push   %eax
80108629:	ff 75 f0             	push   -0x10(%ebp)
8010862c:	e8 01 f8 ff ff       	call   80107e32 <mappages>
80108631:	83 c4 20             	add    $0x20,%esp
80108634:	85 c0                	test   %eax,%eax
80108636:	78 1b                	js     80108653 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80108638:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010863f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108642:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108645:	0f 82 3d ff ff ff    	jb     80108588 <copyuvm+0x2a>
      goto bad;
  }
  return d;
8010864b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010864e:	eb 17                	jmp    80108667 <copyuvm+0x109>
      goto bad;
80108650:	90                   	nop
80108651:	eb 01                	jmp    80108654 <copyuvm+0xf6>
      goto bad;
80108653:	90                   	nop

bad:
  freevm(d);
80108654:	83 ec 0c             	sub    $0xc,%esp
80108657:	ff 75 f0             	push   -0x10(%ebp)
8010865a:	e8 25 fe ff ff       	call   80108484 <freevm>
8010865f:	83 c4 10             	add    $0x10,%esp
  return 0;
80108662:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108667:	c9                   	leave  
80108668:	c3                   	ret    

80108669 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108669:	55                   	push   %ebp
8010866a:	89 e5                	mov    %esp,%ebp
8010866c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010866f:	83 ec 04             	sub    $0x4,%esp
80108672:	6a 00                	push   $0x0
80108674:	ff 75 0c             	push   0xc(%ebp)
80108677:	ff 75 08             	push   0x8(%ebp)
8010867a:	e8 1d f7 ff ff       	call   80107d9c <walkpgdir>
8010867f:	83 c4 10             	add    $0x10,%esp
80108682:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108688:	8b 00                	mov    (%eax),%eax
8010868a:	83 e0 01             	and    $0x1,%eax
8010868d:	85 c0                	test   %eax,%eax
8010868f:	75 07                	jne    80108698 <uva2ka+0x2f>
    return 0;
80108691:	b8 00 00 00 00       	mov    $0x0,%eax
80108696:	eb 22                	jmp    801086ba <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869b:	8b 00                	mov    (%eax),%eax
8010869d:	83 e0 04             	and    $0x4,%eax
801086a0:	85 c0                	test   %eax,%eax
801086a2:	75 07                	jne    801086ab <uva2ka+0x42>
    return 0;
801086a4:	b8 00 00 00 00       	mov    $0x0,%eax
801086a9:	eb 0f                	jmp    801086ba <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801086ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ae:	8b 00                	mov    (%eax),%eax
801086b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086b5:	05 00 00 00 80       	add    $0x80000000,%eax
}
801086ba:	c9                   	leave  
801086bb:	c3                   	ret    

801086bc <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801086bc:	55                   	push   %ebp
801086bd:	89 e5                	mov    %esp,%ebp
801086bf:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801086c2:	8b 45 10             	mov    0x10(%ebp),%eax
801086c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801086c8:	eb 7f                	jmp    80108749 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801086ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801086cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801086d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d8:	83 ec 08             	sub    $0x8,%esp
801086db:	50                   	push   %eax
801086dc:	ff 75 08             	push   0x8(%ebp)
801086df:	e8 85 ff ff ff       	call   80108669 <uva2ka>
801086e4:	83 c4 10             	add    $0x10,%esp
801086e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801086ea:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801086ee:	75 07                	jne    801086f7 <copyout+0x3b>
      return -1;
801086f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801086f5:	eb 61                	jmp    80108758 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801086f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086fa:	2b 45 0c             	sub    0xc(%ebp),%eax
801086fd:	05 00 10 00 00       	add    $0x1000,%eax
80108702:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108705:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108708:	3b 45 14             	cmp    0x14(%ebp),%eax
8010870b:	76 06                	jbe    80108713 <copyout+0x57>
      n = len;
8010870d:	8b 45 14             	mov    0x14(%ebp),%eax
80108710:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108713:	8b 45 0c             	mov    0xc(%ebp),%eax
80108716:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108719:	89 c2                	mov    %eax,%edx
8010871b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010871e:	01 d0                	add    %edx,%eax
80108720:	83 ec 04             	sub    $0x4,%esp
80108723:	ff 75 f0             	push   -0x10(%ebp)
80108726:	ff 75 f4             	push   -0xc(%ebp)
80108729:	50                   	push   %eax
8010872a:	e8 d0 cc ff ff       	call   801053ff <memmove>
8010872f:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108735:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010873b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010873e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108741:	05 00 10 00 00       	add    $0x1000,%eax
80108746:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108749:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010874d:	0f 85 77 ff ff ff    	jne    801086ca <copyout+0xe>
  }
  return 0;
80108753:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108758:	c9                   	leave  
80108759:	c3                   	ret    

8010875a <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010875a:	55                   	push   %ebp
8010875b:	89 e5                	mov    %esp,%ebp
8010875d:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108760:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108767:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010876a:	8b 40 08             	mov    0x8(%eax),%eax
8010876d:	05 00 00 00 80       	add    $0x80000000,%eax
80108772:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108775:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010877c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877f:	8b 40 24             	mov    0x24(%eax),%eax
80108782:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
80108787:	c7 05 d0 a9 11 80 00 	movl   $0x0,0x8011a9d0
8010878e:	00 00 00 

  while(i<madt->len){
80108791:	90                   	nop
80108792:	e9 bd 00 00 00       	jmp    80108854 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108797:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010879a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010879d:	01 d0                	add    %edx,%eax
8010879f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801087a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087a5:	0f b6 00             	movzbl (%eax),%eax
801087a8:	0f b6 c0             	movzbl %al,%eax
801087ab:	83 f8 05             	cmp    $0x5,%eax
801087ae:	0f 87 a0 00 00 00    	ja     80108854 <mpinit_uefi+0xfa>
801087b4:	8b 04 85 b0 b2 10 80 	mov    -0x7fef4d50(,%eax,4),%eax
801087bb:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801087bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801087c3:	a1 d0 a9 11 80       	mov    0x8011a9d0,%eax
801087c8:	83 f8 03             	cmp    $0x3,%eax
801087cb:	7f 28                	jg     801087f5 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801087cd:	8b 15 d0 a9 11 80    	mov    0x8011a9d0,%edx
801087d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087d6:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801087da:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801087e0:	81 c2 00 a7 11 80    	add    $0x8011a700,%edx
801087e6:	88 02                	mov    %al,(%edx)
          ncpu++;
801087e8:	a1 d0 a9 11 80       	mov    0x8011a9d0,%eax
801087ed:	83 c0 01             	add    $0x1,%eax
801087f0:	a3 d0 a9 11 80       	mov    %eax,0x8011a9d0
        }
        i += lapic_entry->record_len;
801087f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087f8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087fc:	0f b6 c0             	movzbl %al,%eax
801087ff:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108802:	eb 50                	jmp    80108854 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108807:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010880a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010880d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108811:	a2 d4 a9 11 80       	mov    %al,0x8011a9d4
        i += ioapic->record_len;
80108816:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108819:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010881d:	0f b6 c0             	movzbl %al,%eax
80108820:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108823:	eb 2f                	jmp    80108854 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108825:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108828:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010882b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010882e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108832:	0f b6 c0             	movzbl %al,%eax
80108835:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108838:	eb 1a                	jmp    80108854 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010883a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010883d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108840:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108843:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108847:	0f b6 c0             	movzbl %al,%eax
8010884a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010884d:	eb 05                	jmp    80108854 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
8010884f:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108853:	90                   	nop
  while(i<madt->len){
80108854:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108857:	8b 40 04             	mov    0x4(%eax),%eax
8010885a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010885d:	0f 82 34 ff ff ff    	jb     80108797 <mpinit_uefi+0x3d>
    }
  }

}
80108863:	90                   	nop
80108864:	90                   	nop
80108865:	c9                   	leave  
80108866:	c3                   	ret    

80108867 <inb>:
{
80108867:	55                   	push   %ebp
80108868:	89 e5                	mov    %esp,%ebp
8010886a:	83 ec 14             	sub    $0x14,%esp
8010886d:	8b 45 08             	mov    0x8(%ebp),%eax
80108870:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108874:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108878:	89 c2                	mov    %eax,%edx
8010887a:	ec                   	in     (%dx),%al
8010887b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010887e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108882:	c9                   	leave  
80108883:	c3                   	ret    

80108884 <outb>:
{
80108884:	55                   	push   %ebp
80108885:	89 e5                	mov    %esp,%ebp
80108887:	83 ec 08             	sub    $0x8,%esp
8010888a:	8b 45 08             	mov    0x8(%ebp),%eax
8010888d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108890:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108894:	89 d0                	mov    %edx,%eax
80108896:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108899:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010889d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801088a1:	ee                   	out    %al,(%dx)
}
801088a2:	90                   	nop
801088a3:	c9                   	leave  
801088a4:	c3                   	ret    

801088a5 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801088a5:	55                   	push   %ebp
801088a6:	89 e5                	mov    %esp,%ebp
801088a8:	83 ec 28             	sub    $0x28,%esp
801088ab:	8b 45 08             	mov    0x8(%ebp),%eax
801088ae:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801088b1:	6a 00                	push   $0x0
801088b3:	68 fa 03 00 00       	push   $0x3fa
801088b8:	e8 c7 ff ff ff       	call   80108884 <outb>
801088bd:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801088c0:	68 80 00 00 00       	push   $0x80
801088c5:	68 fb 03 00 00       	push   $0x3fb
801088ca:	e8 b5 ff ff ff       	call   80108884 <outb>
801088cf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801088d2:	6a 0c                	push   $0xc
801088d4:	68 f8 03 00 00       	push   $0x3f8
801088d9:	e8 a6 ff ff ff       	call   80108884 <outb>
801088de:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801088e1:	6a 00                	push   $0x0
801088e3:	68 f9 03 00 00       	push   $0x3f9
801088e8:	e8 97 ff ff ff       	call   80108884 <outb>
801088ed:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801088f0:	6a 03                	push   $0x3
801088f2:	68 fb 03 00 00       	push   $0x3fb
801088f7:	e8 88 ff ff ff       	call   80108884 <outb>
801088fc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801088ff:	6a 00                	push   $0x0
80108901:	68 fc 03 00 00       	push   $0x3fc
80108906:	e8 79 ff ff ff       	call   80108884 <outb>
8010890b:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010890e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108915:	eb 11                	jmp    80108928 <uart_debug+0x83>
80108917:	83 ec 0c             	sub    $0xc,%esp
8010891a:	6a 0a                	push   $0xa
8010891c:	e8 fa a6 ff ff       	call   8010301b <microdelay>
80108921:	83 c4 10             	add    $0x10,%esp
80108924:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108928:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010892c:	7f 1a                	jg     80108948 <uart_debug+0xa3>
8010892e:	83 ec 0c             	sub    $0xc,%esp
80108931:	68 fd 03 00 00       	push   $0x3fd
80108936:	e8 2c ff ff ff       	call   80108867 <inb>
8010893b:	83 c4 10             	add    $0x10,%esp
8010893e:	0f b6 c0             	movzbl %al,%eax
80108941:	83 e0 20             	and    $0x20,%eax
80108944:	85 c0                	test   %eax,%eax
80108946:	74 cf                	je     80108917 <uart_debug+0x72>
  outb(COM1+0, p);
80108948:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010894c:	0f b6 c0             	movzbl %al,%eax
8010894f:	83 ec 08             	sub    $0x8,%esp
80108952:	50                   	push   %eax
80108953:	68 f8 03 00 00       	push   $0x3f8
80108958:	e8 27 ff ff ff       	call   80108884 <outb>
8010895d:	83 c4 10             	add    $0x10,%esp
}
80108960:	90                   	nop
80108961:	c9                   	leave  
80108962:	c3                   	ret    

80108963 <uart_debugs>:

void uart_debugs(char *p){
80108963:	55                   	push   %ebp
80108964:	89 e5                	mov    %esp,%ebp
80108966:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108969:	eb 1b                	jmp    80108986 <uart_debugs+0x23>
    uart_debug(*p++);
8010896b:	8b 45 08             	mov    0x8(%ebp),%eax
8010896e:	8d 50 01             	lea    0x1(%eax),%edx
80108971:	89 55 08             	mov    %edx,0x8(%ebp)
80108974:	0f b6 00             	movzbl (%eax),%eax
80108977:	0f be c0             	movsbl %al,%eax
8010897a:	83 ec 0c             	sub    $0xc,%esp
8010897d:	50                   	push   %eax
8010897e:	e8 22 ff ff ff       	call   801088a5 <uart_debug>
80108983:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108986:	8b 45 08             	mov    0x8(%ebp),%eax
80108989:	0f b6 00             	movzbl (%eax),%eax
8010898c:	84 c0                	test   %al,%al
8010898e:	75 db                	jne    8010896b <uart_debugs+0x8>
  }
}
80108990:	90                   	nop
80108991:	90                   	nop
80108992:	c9                   	leave  
80108993:	c3                   	ret    

80108994 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108994:	55                   	push   %ebp
80108995:	89 e5                	mov    %esp,%ebp
80108997:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010899a:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801089a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089a4:	8b 50 14             	mov    0x14(%eax),%edx
801089a7:	8b 40 10             	mov    0x10(%eax),%eax
801089aa:	a3 d8 a9 11 80       	mov    %eax,0x8011a9d8
  gpu.vram_size = boot_param->graphic_config.frame_size;
801089af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089b2:	8b 50 1c             	mov    0x1c(%eax),%edx
801089b5:	8b 40 18             	mov    0x18(%eax),%eax
801089b8:	a3 e0 a9 11 80       	mov    %eax,0x8011a9e0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801089bd:	8b 15 e0 a9 11 80    	mov    0x8011a9e0,%edx
801089c3:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801089c8:	29 d0                	sub    %edx,%eax
801089ca:	a3 dc a9 11 80       	mov    %eax,0x8011a9dc
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801089cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089d2:	8b 50 24             	mov    0x24(%eax),%edx
801089d5:	8b 40 20             	mov    0x20(%eax),%eax
801089d8:	a3 e4 a9 11 80       	mov    %eax,0x8011a9e4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801089dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089e0:	8b 50 2c             	mov    0x2c(%eax),%edx
801089e3:	8b 40 28             	mov    0x28(%eax),%eax
801089e6:	a3 e8 a9 11 80       	mov    %eax,0x8011a9e8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801089eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089ee:	8b 50 34             	mov    0x34(%eax),%edx
801089f1:	8b 40 30             	mov    0x30(%eax),%eax
801089f4:	a3 ec a9 11 80       	mov    %eax,0x8011a9ec
}
801089f9:	90                   	nop
801089fa:	c9                   	leave  
801089fb:	c3                   	ret    

801089fc <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801089fc:	55                   	push   %ebp
801089fd:	89 e5                	mov    %esp,%ebp
801089ff:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108a02:	8b 15 ec a9 11 80    	mov    0x8011a9ec,%edx
80108a08:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a0b:	0f af d0             	imul   %eax,%edx
80108a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a11:	01 d0                	add    %edx,%eax
80108a13:	c1 e0 02             	shl    $0x2,%eax
80108a16:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108a19:	8b 15 dc a9 11 80    	mov    0x8011a9dc,%edx
80108a1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108a22:	01 d0                	add    %edx,%eax
80108a24:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108a27:	8b 45 10             	mov    0x10(%ebp),%eax
80108a2a:	0f b6 10             	movzbl (%eax),%edx
80108a2d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a30:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108a32:	8b 45 10             	mov    0x10(%ebp),%eax
80108a35:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108a39:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a3c:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108a3f:	8b 45 10             	mov    0x10(%ebp),%eax
80108a42:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108a46:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a49:	88 50 02             	mov    %dl,0x2(%eax)
}
80108a4c:	90                   	nop
80108a4d:	c9                   	leave  
80108a4e:	c3                   	ret    

80108a4f <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108a4f:	55                   	push   %ebp
80108a50:	89 e5                	mov    %esp,%ebp
80108a52:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108a55:	8b 15 ec a9 11 80    	mov    0x8011a9ec,%edx
80108a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80108a5e:	0f af c2             	imul   %edx,%eax
80108a61:	c1 e0 02             	shl    $0x2,%eax
80108a64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108a67:	a1 e0 a9 11 80       	mov    0x8011a9e0,%eax
80108a6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a6f:	29 d0                	sub    %edx,%eax
80108a71:	8b 0d dc a9 11 80    	mov    0x8011a9dc,%ecx
80108a77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a7a:	01 ca                	add    %ecx,%edx
80108a7c:	89 d1                	mov    %edx,%ecx
80108a7e:	8b 15 dc a9 11 80    	mov    0x8011a9dc,%edx
80108a84:	83 ec 04             	sub    $0x4,%esp
80108a87:	50                   	push   %eax
80108a88:	51                   	push   %ecx
80108a89:	52                   	push   %edx
80108a8a:	e8 70 c9 ff ff       	call   801053ff <memmove>
80108a8f:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a95:	8b 0d dc a9 11 80    	mov    0x8011a9dc,%ecx
80108a9b:	8b 15 e0 a9 11 80    	mov    0x8011a9e0,%edx
80108aa1:	01 ca                	add    %ecx,%edx
80108aa3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108aa6:	29 ca                	sub    %ecx,%edx
80108aa8:	83 ec 04             	sub    $0x4,%esp
80108aab:	50                   	push   %eax
80108aac:	6a 00                	push   $0x0
80108aae:	52                   	push   %edx
80108aaf:	e8 8c c8 ff ff       	call   80105340 <memset>
80108ab4:	83 c4 10             	add    $0x10,%esp
}
80108ab7:	90                   	nop
80108ab8:	c9                   	leave  
80108ab9:	c3                   	ret    

80108aba <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108aba:	55                   	push   %ebp
80108abb:	89 e5                	mov    %esp,%ebp
80108abd:	53                   	push   %ebx
80108abe:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108ac1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ac8:	e9 b1 00 00 00       	jmp    80108b7e <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108acd:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108ad4:	e9 97 00 00 00       	jmp    80108b70 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108ad9:	8b 45 10             	mov    0x10(%ebp),%eax
80108adc:	83 e8 20             	sub    $0x20,%eax
80108adf:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae5:	01 d0                	add    %edx,%eax
80108ae7:	0f b7 84 00 e0 b2 10 	movzwl -0x7fef4d20(%eax,%eax,1),%eax
80108aee:	80 
80108aef:	0f b7 d0             	movzwl %ax,%edx
80108af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af5:	bb 01 00 00 00       	mov    $0x1,%ebx
80108afa:	89 c1                	mov    %eax,%ecx
80108afc:	d3 e3                	shl    %cl,%ebx
80108afe:	89 d8                	mov    %ebx,%eax
80108b00:	21 d0                	and    %edx,%eax
80108b02:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b08:	ba 01 00 00 00       	mov    $0x1,%edx
80108b0d:	89 c1                	mov    %eax,%ecx
80108b0f:	d3 e2                	shl    %cl,%edx
80108b11:	89 d0                	mov    %edx,%eax
80108b13:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108b16:	75 2b                	jne    80108b43 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108b18:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1e:	01 c2                	add    %eax,%edx
80108b20:	b8 0e 00 00 00       	mov    $0xe,%eax
80108b25:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108b28:	89 c1                	mov    %eax,%ecx
80108b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80108b2d:	01 c8                	add    %ecx,%eax
80108b2f:	83 ec 04             	sub    $0x4,%esp
80108b32:	68 20 f5 10 80       	push   $0x8010f520
80108b37:	52                   	push   %edx
80108b38:	50                   	push   %eax
80108b39:	e8 be fe ff ff       	call   801089fc <graphic_draw_pixel>
80108b3e:	83 c4 10             	add    $0x10,%esp
80108b41:	eb 29                	jmp    80108b6c <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108b43:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b49:	01 c2                	add    %eax,%edx
80108b4b:	b8 0e 00 00 00       	mov    $0xe,%eax
80108b50:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108b53:	89 c1                	mov    %eax,%ecx
80108b55:	8b 45 08             	mov    0x8(%ebp),%eax
80108b58:	01 c8                	add    %ecx,%eax
80108b5a:	83 ec 04             	sub    $0x4,%esp
80108b5d:	68 f0 a9 11 80       	push   $0x8011a9f0
80108b62:	52                   	push   %edx
80108b63:	50                   	push   %eax
80108b64:	e8 93 fe ff ff       	call   801089fc <graphic_draw_pixel>
80108b69:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108b6c:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108b70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b74:	0f 89 5f ff ff ff    	jns    80108ad9 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108b7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b7e:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108b82:	0f 8e 45 ff ff ff    	jle    80108acd <font_render+0x13>
      }
    }
  }
}
80108b88:	90                   	nop
80108b89:	90                   	nop
80108b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b8d:	c9                   	leave  
80108b8e:	c3                   	ret    

80108b8f <font_render_string>:

void font_render_string(char *string,int row){
80108b8f:	55                   	push   %ebp
80108b90:	89 e5                	mov    %esp,%ebp
80108b92:	53                   	push   %ebx
80108b93:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108b96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108b9d:	eb 33                	jmp    80108bd2 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108b9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ba5:	01 d0                	add    %edx,%eax
80108ba7:	0f b6 00             	movzbl (%eax),%eax
80108baa:	0f be c8             	movsbl %al,%ecx
80108bad:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bb0:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108bb3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108bb6:	89 d8                	mov    %ebx,%eax
80108bb8:	c1 e0 04             	shl    $0x4,%eax
80108bbb:	29 d8                	sub    %ebx,%eax
80108bbd:	83 c0 02             	add    $0x2,%eax
80108bc0:	83 ec 04             	sub    $0x4,%esp
80108bc3:	51                   	push   %ecx
80108bc4:	52                   	push   %edx
80108bc5:	50                   	push   %eax
80108bc6:	e8 ef fe ff ff       	call   80108aba <font_render>
80108bcb:	83 c4 10             	add    $0x10,%esp
    i++;
80108bce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108bd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd8:	01 d0                	add    %edx,%eax
80108bda:	0f b6 00             	movzbl (%eax),%eax
80108bdd:	84 c0                	test   %al,%al
80108bdf:	74 06                	je     80108be7 <font_render_string+0x58>
80108be1:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108be5:	7e b8                	jle    80108b9f <font_render_string+0x10>
  }
}
80108be7:	90                   	nop
80108be8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108beb:	c9                   	leave  
80108bec:	c3                   	ret    

80108bed <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108bed:	55                   	push   %ebp
80108bee:	89 e5                	mov    %esp,%ebp
80108bf0:	53                   	push   %ebx
80108bf1:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108bf4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bfb:	eb 6b                	jmp    80108c68 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108bfd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108c04:	eb 58                	jmp    80108c5e <pci_init+0x71>
      for(int k=0;k<8;k++){
80108c06:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108c0d:	eb 45                	jmp    80108c54 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108c0f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108c12:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c18:	83 ec 0c             	sub    $0xc,%esp
80108c1b:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108c1e:	53                   	push   %ebx
80108c1f:	6a 00                	push   $0x0
80108c21:	51                   	push   %ecx
80108c22:	52                   	push   %edx
80108c23:	50                   	push   %eax
80108c24:	e8 b0 00 00 00       	call   80108cd9 <pci_access_config>
80108c29:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108c2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c2f:	0f b7 c0             	movzwl %ax,%eax
80108c32:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108c37:	74 17                	je     80108c50 <pci_init+0x63>
        pci_init_device(i,j,k);
80108c39:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108c3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c42:	83 ec 04             	sub    $0x4,%esp
80108c45:	51                   	push   %ecx
80108c46:	52                   	push   %edx
80108c47:	50                   	push   %eax
80108c48:	e8 37 01 00 00       	call   80108d84 <pci_init_device>
80108c4d:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108c50:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108c54:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108c58:	7e b5                	jle    80108c0f <pci_init+0x22>
    for(int j=0;j<32;j++){
80108c5a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108c5e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108c62:	7e a2                	jle    80108c06 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108c64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c68:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108c6f:	7e 8c                	jle    80108bfd <pci_init+0x10>
      }
      }
    }
  }
}
80108c71:	90                   	nop
80108c72:	90                   	nop
80108c73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c76:	c9                   	leave  
80108c77:	c3                   	ret    

80108c78 <pci_write_config>:

void pci_write_config(uint config){
80108c78:	55                   	push   %ebp
80108c79:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c7e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108c83:	89 c0                	mov    %eax,%eax
80108c85:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108c86:	90                   	nop
80108c87:	5d                   	pop    %ebp
80108c88:	c3                   	ret    

80108c89 <pci_write_data>:

void pci_write_data(uint config){
80108c89:	55                   	push   %ebp
80108c8a:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c8f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108c94:	89 c0                	mov    %eax,%eax
80108c96:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108c97:	90                   	nop
80108c98:	5d                   	pop    %ebp
80108c99:	c3                   	ret    

80108c9a <pci_read_config>:
uint pci_read_config(){
80108c9a:	55                   	push   %ebp
80108c9b:	89 e5                	mov    %esp,%ebp
80108c9d:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108ca0:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108ca5:	ed                   	in     (%dx),%eax
80108ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108ca9:	83 ec 0c             	sub    $0xc,%esp
80108cac:	68 c8 00 00 00       	push   $0xc8
80108cb1:	e8 65 a3 ff ff       	call   8010301b <microdelay>
80108cb6:	83 c4 10             	add    $0x10,%esp
  return data;
80108cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108cbc:	c9                   	leave  
80108cbd:	c3                   	ret    

80108cbe <pci_test>:


void pci_test(){
80108cbe:	55                   	push   %ebp
80108cbf:	89 e5                	mov    %esp,%ebp
80108cc1:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108cc4:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108ccb:	ff 75 fc             	push   -0x4(%ebp)
80108cce:	e8 a5 ff ff ff       	call   80108c78 <pci_write_config>
80108cd3:	83 c4 04             	add    $0x4,%esp
}
80108cd6:	90                   	nop
80108cd7:	c9                   	leave  
80108cd8:	c3                   	ret    

80108cd9 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108cd9:	55                   	push   %ebp
80108cda:	89 e5                	mov    %esp,%ebp
80108cdc:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80108ce2:	c1 e0 10             	shl    $0x10,%eax
80108ce5:	25 00 00 ff 00       	and    $0xff0000,%eax
80108cea:	89 c2                	mov    %eax,%edx
80108cec:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cef:	c1 e0 0b             	shl    $0xb,%eax
80108cf2:	0f b7 c0             	movzwl %ax,%eax
80108cf5:	09 c2                	or     %eax,%edx
80108cf7:	8b 45 10             	mov    0x10(%ebp),%eax
80108cfa:	c1 e0 08             	shl    $0x8,%eax
80108cfd:	25 00 07 00 00       	and    $0x700,%eax
80108d02:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108d04:	8b 45 14             	mov    0x14(%ebp),%eax
80108d07:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108d0c:	09 d0                	or     %edx,%eax
80108d0e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108d16:	ff 75 f4             	push   -0xc(%ebp)
80108d19:	e8 5a ff ff ff       	call   80108c78 <pci_write_config>
80108d1e:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108d21:	e8 74 ff ff ff       	call   80108c9a <pci_read_config>
80108d26:	8b 55 18             	mov    0x18(%ebp),%edx
80108d29:	89 02                	mov    %eax,(%edx)
}
80108d2b:	90                   	nop
80108d2c:	c9                   	leave  
80108d2d:	c3                   	ret    

80108d2e <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108d2e:	55                   	push   %ebp
80108d2f:	89 e5                	mov    %esp,%ebp
80108d31:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108d34:	8b 45 08             	mov    0x8(%ebp),%eax
80108d37:	c1 e0 10             	shl    $0x10,%eax
80108d3a:	25 00 00 ff 00       	and    $0xff0000,%eax
80108d3f:	89 c2                	mov    %eax,%edx
80108d41:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d44:	c1 e0 0b             	shl    $0xb,%eax
80108d47:	0f b7 c0             	movzwl %ax,%eax
80108d4a:	09 c2                	or     %eax,%edx
80108d4c:	8b 45 10             	mov    0x10(%ebp),%eax
80108d4f:	c1 e0 08             	shl    $0x8,%eax
80108d52:	25 00 07 00 00       	and    $0x700,%eax
80108d57:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108d59:	8b 45 14             	mov    0x14(%ebp),%eax
80108d5c:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108d61:	09 d0                	or     %edx,%eax
80108d63:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d68:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108d6b:	ff 75 fc             	push   -0x4(%ebp)
80108d6e:	e8 05 ff ff ff       	call   80108c78 <pci_write_config>
80108d73:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108d76:	ff 75 18             	push   0x18(%ebp)
80108d79:	e8 0b ff ff ff       	call   80108c89 <pci_write_data>
80108d7e:	83 c4 04             	add    $0x4,%esp
}
80108d81:	90                   	nop
80108d82:	c9                   	leave  
80108d83:	c3                   	ret    

80108d84 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108d84:	55                   	push   %ebp
80108d85:	89 e5                	mov    %esp,%ebp
80108d87:	53                   	push   %ebx
80108d88:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d8e:	a2 f4 a9 11 80       	mov    %al,0x8011a9f4
  dev.device_num = device_num;
80108d93:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d96:	a2 f5 a9 11 80       	mov    %al,0x8011a9f5
  dev.function_num = function_num;
80108d9b:	8b 45 10             	mov    0x10(%ebp),%eax
80108d9e:	a2 f6 a9 11 80       	mov    %al,0x8011a9f6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108da3:	ff 75 10             	push   0x10(%ebp)
80108da6:	ff 75 0c             	push   0xc(%ebp)
80108da9:	ff 75 08             	push   0x8(%ebp)
80108dac:	68 24 c9 10 80       	push   $0x8010c924
80108db1:	e8 3e 76 ff ff       	call   801003f4 <cprintf>
80108db6:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108db9:	83 ec 0c             	sub    $0xc,%esp
80108dbc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108dbf:	50                   	push   %eax
80108dc0:	6a 00                	push   $0x0
80108dc2:	ff 75 10             	push   0x10(%ebp)
80108dc5:	ff 75 0c             	push   0xc(%ebp)
80108dc8:	ff 75 08             	push   0x8(%ebp)
80108dcb:	e8 09 ff ff ff       	call   80108cd9 <pci_access_config>
80108dd0:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108dd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dd6:	c1 e8 10             	shr    $0x10,%eax
80108dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108ddc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ddf:	25 ff ff 00 00       	and    $0xffff,%eax
80108de4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dea:	a3 f8 a9 11 80       	mov    %eax,0x8011a9f8
  dev.vendor_id = vendor_id;
80108def:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df2:	a3 fc a9 11 80       	mov    %eax,0x8011a9fc
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108df7:	83 ec 04             	sub    $0x4,%esp
80108dfa:	ff 75 f0             	push   -0x10(%ebp)
80108dfd:	ff 75 f4             	push   -0xc(%ebp)
80108e00:	68 58 c9 10 80       	push   $0x8010c958
80108e05:	e8 ea 75 ff ff       	call   801003f4 <cprintf>
80108e0a:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108e0d:	83 ec 0c             	sub    $0xc,%esp
80108e10:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e13:	50                   	push   %eax
80108e14:	6a 08                	push   $0x8
80108e16:	ff 75 10             	push   0x10(%ebp)
80108e19:	ff 75 0c             	push   0xc(%ebp)
80108e1c:	ff 75 08             	push   0x8(%ebp)
80108e1f:	e8 b5 fe ff ff       	call   80108cd9 <pci_access_config>
80108e24:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108e27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e2a:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108e2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e30:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108e33:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108e36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e39:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108e3c:	0f b6 c0             	movzbl %al,%eax
80108e3f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108e42:	c1 eb 18             	shr    $0x18,%ebx
80108e45:	83 ec 0c             	sub    $0xc,%esp
80108e48:	51                   	push   %ecx
80108e49:	52                   	push   %edx
80108e4a:	50                   	push   %eax
80108e4b:	53                   	push   %ebx
80108e4c:	68 7c c9 10 80       	push   $0x8010c97c
80108e51:	e8 9e 75 ff ff       	call   801003f4 <cprintf>
80108e56:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108e59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e5c:	c1 e8 18             	shr    $0x18,%eax
80108e5f:	a2 00 aa 11 80       	mov    %al,0x8011aa00
  dev.sub_class = (data>>16)&0xFF;
80108e64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e67:	c1 e8 10             	shr    $0x10,%eax
80108e6a:	a2 01 aa 11 80       	mov    %al,0x8011aa01
  dev.interface = (data>>8)&0xFF;
80108e6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e72:	c1 e8 08             	shr    $0x8,%eax
80108e75:	a2 02 aa 11 80       	mov    %al,0x8011aa02
  dev.revision_id = data&0xFF;
80108e7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e7d:	a2 03 aa 11 80       	mov    %al,0x8011aa03
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108e82:	83 ec 0c             	sub    $0xc,%esp
80108e85:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e88:	50                   	push   %eax
80108e89:	6a 10                	push   $0x10
80108e8b:	ff 75 10             	push   0x10(%ebp)
80108e8e:	ff 75 0c             	push   0xc(%ebp)
80108e91:	ff 75 08             	push   0x8(%ebp)
80108e94:	e8 40 fe ff ff       	call   80108cd9 <pci_access_config>
80108e99:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108e9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e9f:	a3 04 aa 11 80       	mov    %eax,0x8011aa04
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108ea4:	83 ec 0c             	sub    $0xc,%esp
80108ea7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108eaa:	50                   	push   %eax
80108eab:	6a 14                	push   $0x14
80108ead:	ff 75 10             	push   0x10(%ebp)
80108eb0:	ff 75 0c             	push   0xc(%ebp)
80108eb3:	ff 75 08             	push   0x8(%ebp)
80108eb6:	e8 1e fe ff ff       	call   80108cd9 <pci_access_config>
80108ebb:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ec1:	a3 08 aa 11 80       	mov    %eax,0x8011aa08
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108ec6:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108ecd:	75 5a                	jne    80108f29 <pci_init_device+0x1a5>
80108ecf:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108ed6:	75 51                	jne    80108f29 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108ed8:	83 ec 0c             	sub    $0xc,%esp
80108edb:	68 c1 c9 10 80       	push   $0x8010c9c1
80108ee0:	e8 0f 75 ff ff       	call   801003f4 <cprintf>
80108ee5:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108ee8:	83 ec 0c             	sub    $0xc,%esp
80108eeb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108eee:	50                   	push   %eax
80108eef:	68 f0 00 00 00       	push   $0xf0
80108ef4:	ff 75 10             	push   0x10(%ebp)
80108ef7:	ff 75 0c             	push   0xc(%ebp)
80108efa:	ff 75 08             	push   0x8(%ebp)
80108efd:	e8 d7 fd ff ff       	call   80108cd9 <pci_access_config>
80108f02:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108f05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f08:	83 ec 08             	sub    $0x8,%esp
80108f0b:	50                   	push   %eax
80108f0c:	68 db c9 10 80       	push   $0x8010c9db
80108f11:	e8 de 74 ff ff       	call   801003f4 <cprintf>
80108f16:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108f19:	83 ec 0c             	sub    $0xc,%esp
80108f1c:	68 f4 a9 11 80       	push   $0x8011a9f4
80108f21:	e8 09 00 00 00       	call   80108f2f <i8254_init>
80108f26:	83 c4 10             	add    $0x10,%esp
  }
}
80108f29:	90                   	nop
80108f2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f2d:	c9                   	leave  
80108f2e:	c3                   	ret    

80108f2f <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108f2f:	55                   	push   %ebp
80108f30:	89 e5                	mov    %esp,%ebp
80108f32:	53                   	push   %ebx
80108f33:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108f36:	8b 45 08             	mov    0x8(%ebp),%eax
80108f39:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108f3d:	0f b6 c8             	movzbl %al,%ecx
80108f40:	8b 45 08             	mov    0x8(%ebp),%eax
80108f43:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108f47:	0f b6 d0             	movzbl %al,%edx
80108f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f4d:	0f b6 00             	movzbl (%eax),%eax
80108f50:	0f b6 c0             	movzbl %al,%eax
80108f53:	83 ec 0c             	sub    $0xc,%esp
80108f56:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108f59:	53                   	push   %ebx
80108f5a:	6a 04                	push   $0x4
80108f5c:	51                   	push   %ecx
80108f5d:	52                   	push   %edx
80108f5e:	50                   	push   %eax
80108f5f:	e8 75 fd ff ff       	call   80108cd9 <pci_access_config>
80108f64:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108f67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f6a:	83 c8 04             	or     $0x4,%eax
80108f6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108f70:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108f73:	8b 45 08             	mov    0x8(%ebp),%eax
80108f76:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108f7a:	0f b6 c8             	movzbl %al,%ecx
80108f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80108f80:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108f84:	0f b6 d0             	movzbl %al,%edx
80108f87:	8b 45 08             	mov    0x8(%ebp),%eax
80108f8a:	0f b6 00             	movzbl (%eax),%eax
80108f8d:	0f b6 c0             	movzbl %al,%eax
80108f90:	83 ec 0c             	sub    $0xc,%esp
80108f93:	53                   	push   %ebx
80108f94:	6a 04                	push   $0x4
80108f96:	51                   	push   %ecx
80108f97:	52                   	push   %edx
80108f98:	50                   	push   %eax
80108f99:	e8 90 fd ff ff       	call   80108d2e <pci_write_config_register>
80108f9e:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80108fa4:	8b 40 10             	mov    0x10(%eax),%eax
80108fa7:	05 00 00 00 40       	add    $0x40000000,%eax
80108fac:	a3 0c aa 11 80       	mov    %eax,0x8011aa0c
  uint *ctrl = (uint *)base_addr;
80108fb1:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80108fb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108fb9:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80108fbe:	05 d8 00 00 00       	add    $0xd8,%eax
80108fc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc9:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd2:	8b 00                	mov    (%eax),%eax
80108fd4:	0d 00 00 00 04       	or     $0x4000000,%eax
80108fd9:	89 c2                	mov    %eax,%edx
80108fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fde:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe3:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fec:	8b 00                	mov    (%eax),%eax
80108fee:	83 c8 40             	or     $0x40,%eax
80108ff1:	89 c2                	mov    %eax,%edx
80108ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff6:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ffb:	8b 10                	mov    (%eax),%edx
80108ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109000:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80109002:	83 ec 0c             	sub    $0xc,%esp
80109005:	68 f0 c9 10 80       	push   $0x8010c9f0
8010900a:	e8 e5 73 ff ff       	call   801003f4 <cprintf>
8010900f:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80109012:	e8 6d 9c ff ff       	call   80102c84 <kalloc>
80109017:	a3 18 aa 11 80       	mov    %eax,0x8011aa18
  *intr_addr = 0;
8010901c:	a1 18 aa 11 80       	mov    0x8011aa18,%eax
80109021:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80109027:	a1 18 aa 11 80       	mov    0x8011aa18,%eax
8010902c:	83 ec 08             	sub    $0x8,%esp
8010902f:	50                   	push   %eax
80109030:	68 12 ca 10 80       	push   $0x8010ca12
80109035:	e8 ba 73 ff ff       	call   801003f4 <cprintf>
8010903a:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010903d:	e8 50 00 00 00       	call   80109092 <i8254_init_recv>
  i8254_init_send();
80109042:	e8 69 03 00 00       	call   801093b0 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80109047:	0f b6 05 27 f5 10 80 	movzbl 0x8010f527,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010904e:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80109051:	0f b6 05 26 f5 10 80 	movzbl 0x8010f526,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109058:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010905b:	0f b6 05 25 f5 10 80 	movzbl 0x8010f525,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109062:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80109065:	0f b6 05 24 f5 10 80 	movzbl 0x8010f524,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010906c:	0f b6 c0             	movzbl %al,%eax
8010906f:	83 ec 0c             	sub    $0xc,%esp
80109072:	53                   	push   %ebx
80109073:	51                   	push   %ecx
80109074:	52                   	push   %edx
80109075:	50                   	push   %eax
80109076:	68 20 ca 10 80       	push   $0x8010ca20
8010907b:	e8 74 73 ff ff       	call   801003f4 <cprintf>
80109080:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80109083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109086:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
8010908c:	90                   	nop
8010908d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109090:	c9                   	leave  
80109091:	c3                   	ret    

80109092 <i8254_init_recv>:

void i8254_init_recv(){
80109092:	55                   	push   %ebp
80109093:	89 e5                	mov    %esp,%ebp
80109095:	57                   	push   %edi
80109096:	56                   	push   %esi
80109097:	53                   	push   %ebx
80109098:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
8010909b:	83 ec 0c             	sub    $0xc,%esp
8010909e:	6a 00                	push   $0x0
801090a0:	e8 e8 04 00 00       	call   8010958d <i8254_read_eeprom>
801090a5:	83 c4 10             	add    $0x10,%esp
801090a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801090ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
801090ae:	a2 10 aa 11 80       	mov    %al,0x8011aa10
  mac_addr[1] = data_l>>8;
801090b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801090b6:	c1 e8 08             	shr    $0x8,%eax
801090b9:	a2 11 aa 11 80       	mov    %al,0x8011aa11
  uint data_m = i8254_read_eeprom(0x1);
801090be:	83 ec 0c             	sub    $0xc,%esp
801090c1:	6a 01                	push   $0x1
801090c3:	e8 c5 04 00 00       	call   8010958d <i8254_read_eeprom>
801090c8:	83 c4 10             	add    $0x10,%esp
801090cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801090ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801090d1:	a2 12 aa 11 80       	mov    %al,0x8011aa12
  mac_addr[3] = data_m>>8;
801090d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801090d9:	c1 e8 08             	shr    $0x8,%eax
801090dc:	a2 13 aa 11 80       	mov    %al,0x8011aa13
  uint data_h = i8254_read_eeprom(0x2);
801090e1:	83 ec 0c             	sub    $0xc,%esp
801090e4:	6a 02                	push   $0x2
801090e6:	e8 a2 04 00 00       	call   8010958d <i8254_read_eeprom>
801090eb:	83 c4 10             	add    $0x10,%esp
801090ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801090f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090f4:	a2 14 aa 11 80       	mov    %al,0x8011aa14
  mac_addr[5] = data_h>>8;
801090f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090fc:	c1 e8 08             	shr    $0x8,%eax
801090ff:	a2 15 aa 11 80       	mov    %al,0x8011aa15
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80109104:	0f b6 05 15 aa 11 80 	movzbl 0x8011aa15,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010910b:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010910e:	0f b6 05 14 aa 11 80 	movzbl 0x8011aa14,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109115:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80109118:	0f b6 05 13 aa 11 80 	movzbl 0x8011aa13,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010911f:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80109122:	0f b6 05 12 aa 11 80 	movzbl 0x8011aa12,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109129:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010912c:	0f b6 05 11 aa 11 80 	movzbl 0x8011aa11,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109133:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80109136:	0f b6 05 10 aa 11 80 	movzbl 0x8011aa10,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010913d:	0f b6 c0             	movzbl %al,%eax
80109140:	83 ec 04             	sub    $0x4,%esp
80109143:	57                   	push   %edi
80109144:	56                   	push   %esi
80109145:	53                   	push   %ebx
80109146:	51                   	push   %ecx
80109147:	52                   	push   %edx
80109148:	50                   	push   %eax
80109149:	68 38 ca 10 80       	push   $0x8010ca38
8010914e:	e8 a1 72 ff ff       	call   801003f4 <cprintf>
80109153:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80109156:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010915b:	05 00 54 00 00       	add    $0x5400,%eax
80109160:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80109163:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109168:	05 04 54 00 00       	add    $0x5404,%eax
8010916d:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80109170:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109173:	c1 e0 10             	shl    $0x10,%eax
80109176:	0b 45 d8             	or     -0x28(%ebp),%eax
80109179:	89 c2                	mov    %eax,%edx
8010917b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010917e:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80109180:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109183:	0d 00 00 00 80       	or     $0x80000000,%eax
80109188:	89 c2                	mov    %eax,%edx
8010918a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010918d:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
8010918f:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109194:	05 00 52 00 00       	add    $0x5200,%eax
80109199:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
8010919c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801091a3:	eb 19                	jmp    801091be <i8254_init_recv+0x12c>
    mta[i] = 0;
801091a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801091a8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801091b2:	01 d0                	add    %edx,%eax
801091b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801091ba:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801091be:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801091c2:	7e e1                	jle    801091a5 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801091c4:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801091c9:	05 d0 00 00 00       	add    $0xd0,%eax
801091ce:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801091d1:	8b 45 c0             	mov    -0x40(%ebp),%eax
801091d4:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801091da:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801091df:	05 c8 00 00 00       	add    $0xc8,%eax
801091e4:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801091e7:	8b 45 bc             	mov    -0x44(%ebp),%eax
801091ea:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801091f0:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801091f5:	05 28 28 00 00       	add    $0x2828,%eax
801091fa:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801091fd:	8b 45 b8             	mov    -0x48(%ebp),%eax
80109200:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80109206:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010920b:	05 00 01 00 00       	add    $0x100,%eax
80109210:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80109213:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109216:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010921c:	e8 63 9a ff ff       	call   80102c84 <kalloc>
80109221:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109224:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109229:	05 00 28 00 00       	add    $0x2800,%eax
8010922e:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80109231:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109236:	05 04 28 00 00       	add    $0x2804,%eax
8010923b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010923e:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109243:	05 08 28 00 00       	add    $0x2808,%eax
80109248:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
8010924b:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109250:	05 10 28 00 00       	add    $0x2810,%eax
80109255:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109258:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010925d:	05 18 28 00 00       	add    $0x2818,%eax
80109262:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80109265:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109268:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010926e:	8b 45 ac             	mov    -0x54(%ebp),%eax
80109271:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80109273:	8b 45 a8             	mov    -0x58(%ebp),%eax
80109276:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
8010927c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010927f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80109285:	8b 45 a0             	mov    -0x60(%ebp),%eax
80109288:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
8010928e:	8b 45 9c             	mov    -0x64(%ebp),%eax
80109291:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80109297:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010929a:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010929d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801092a4:	eb 73                	jmp    80109319 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801092a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092a9:	c1 e0 04             	shl    $0x4,%eax
801092ac:	89 c2                	mov    %eax,%edx
801092ae:	8b 45 98             	mov    -0x68(%ebp),%eax
801092b1:	01 d0                	add    %edx,%eax
801092b3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801092ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092bd:	c1 e0 04             	shl    $0x4,%eax
801092c0:	89 c2                	mov    %eax,%edx
801092c2:	8b 45 98             	mov    -0x68(%ebp),%eax
801092c5:	01 d0                	add    %edx,%eax
801092c7:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801092cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092d0:	c1 e0 04             	shl    $0x4,%eax
801092d3:	89 c2                	mov    %eax,%edx
801092d5:	8b 45 98             	mov    -0x68(%ebp),%eax
801092d8:	01 d0                	add    %edx,%eax
801092da:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801092e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092e3:	c1 e0 04             	shl    $0x4,%eax
801092e6:	89 c2                	mov    %eax,%edx
801092e8:	8b 45 98             	mov    -0x68(%ebp),%eax
801092eb:	01 d0                	add    %edx,%eax
801092ed:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801092f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092f4:	c1 e0 04             	shl    $0x4,%eax
801092f7:	89 c2                	mov    %eax,%edx
801092f9:	8b 45 98             	mov    -0x68(%ebp),%eax
801092fc:	01 d0                	add    %edx,%eax
801092fe:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109302:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109305:	c1 e0 04             	shl    $0x4,%eax
80109308:	89 c2                	mov    %eax,%edx
8010930a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010930d:	01 d0                	add    %edx,%eax
8010930f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109315:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109319:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109320:	7e 84                	jle    801092a6 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109322:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109329:	eb 57                	jmp    80109382 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
8010932b:	e8 54 99 ff ff       	call   80102c84 <kalloc>
80109330:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109333:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109337:	75 12                	jne    8010934b <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80109339:	83 ec 0c             	sub    $0xc,%esp
8010933c:	68 58 ca 10 80       	push   $0x8010ca58
80109341:	e8 ae 70 ff ff       	call   801003f4 <cprintf>
80109346:	83 c4 10             	add    $0x10,%esp
      break;
80109349:	eb 3d                	jmp    80109388 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
8010934b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010934e:	c1 e0 04             	shl    $0x4,%eax
80109351:	89 c2                	mov    %eax,%edx
80109353:	8b 45 98             	mov    -0x68(%ebp),%eax
80109356:	01 d0                	add    %edx,%eax
80109358:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010935b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109361:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109363:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109366:	83 c0 01             	add    $0x1,%eax
80109369:	c1 e0 04             	shl    $0x4,%eax
8010936c:	89 c2                	mov    %eax,%edx
8010936e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109371:	01 d0                	add    %edx,%eax
80109373:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109376:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010937c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010937e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80109382:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80109386:	7e a3                	jle    8010932b <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80109388:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010938b:	8b 00                	mov    (%eax),%eax
8010938d:	83 c8 02             	or     $0x2,%eax
80109390:	89 c2                	mov    %eax,%edx
80109392:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109395:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80109397:	83 ec 0c             	sub    $0xc,%esp
8010939a:	68 78 ca 10 80       	push   $0x8010ca78
8010939f:	e8 50 70 ff ff       	call   801003f4 <cprintf>
801093a4:	83 c4 10             	add    $0x10,%esp
}
801093a7:	90                   	nop
801093a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801093ab:	5b                   	pop    %ebx
801093ac:	5e                   	pop    %esi
801093ad:	5f                   	pop    %edi
801093ae:	5d                   	pop    %ebp
801093af:	c3                   	ret    

801093b0 <i8254_init_send>:

void i8254_init_send(){
801093b0:	55                   	push   %ebp
801093b1:	89 e5                	mov    %esp,%ebp
801093b3:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801093b6:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801093bb:	05 28 38 00 00       	add    $0x3828,%eax
801093c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801093c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093c6:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801093cc:	e8 b3 98 ff ff       	call   80102c84 <kalloc>
801093d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801093d4:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801093d9:	05 00 38 00 00       	add    $0x3800,%eax
801093de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801093e1:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801093e6:	05 04 38 00 00       	add    $0x3804,%eax
801093eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801093ee:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801093f3:	05 08 38 00 00       	add    $0x3808,%eax
801093f8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801093fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093fe:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109407:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109409:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010940c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109412:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109415:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010941b:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109420:	05 10 38 00 00       	add    $0x3810,%eax
80109425:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109428:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
8010942d:	05 18 38 00 00       	add    $0x3818,%eax
80109432:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109435:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109438:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010943e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109441:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109447:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010944a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010944d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109454:	e9 82 00 00 00       	jmp    801094db <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80109459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010945c:	c1 e0 04             	shl    $0x4,%eax
8010945f:	89 c2                	mov    %eax,%edx
80109461:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109464:	01 d0                	add    %edx,%eax
80109466:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010946d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109470:	c1 e0 04             	shl    $0x4,%eax
80109473:	89 c2                	mov    %eax,%edx
80109475:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109478:	01 d0                	add    %edx,%eax
8010947a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109483:	c1 e0 04             	shl    $0x4,%eax
80109486:	89 c2                	mov    %eax,%edx
80109488:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010948b:	01 d0                	add    %edx,%eax
8010948d:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80109491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109494:	c1 e0 04             	shl    $0x4,%eax
80109497:	89 c2                	mov    %eax,%edx
80109499:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010949c:	01 d0                	add    %edx,%eax
8010949e:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801094a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a5:	c1 e0 04             	shl    $0x4,%eax
801094a8:	89 c2                	mov    %eax,%edx
801094aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094ad:	01 d0                	add    %edx,%eax
801094af:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801094b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b6:	c1 e0 04             	shl    $0x4,%eax
801094b9:	89 c2                	mov    %eax,%edx
801094bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094be:	01 d0                	add    %edx,%eax
801094c0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801094c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c7:	c1 e0 04             	shl    $0x4,%eax
801094ca:	89 c2                	mov    %eax,%edx
801094cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094cf:	01 d0                	add    %edx,%eax
801094d1:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801094d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094db:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801094e2:	0f 8e 71 ff ff ff    	jle    80109459 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801094e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801094ef:	eb 57                	jmp    80109548 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
801094f1:	e8 8e 97 ff ff       	call   80102c84 <kalloc>
801094f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801094f9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801094fd:	75 12                	jne    80109511 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
801094ff:	83 ec 0c             	sub    $0xc,%esp
80109502:	68 58 ca 10 80       	push   $0x8010ca58
80109507:	e8 e8 6e ff ff       	call   801003f4 <cprintf>
8010950c:	83 c4 10             	add    $0x10,%esp
      break;
8010950f:	eb 3d                	jmp    8010954e <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109511:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109514:	c1 e0 04             	shl    $0x4,%eax
80109517:	89 c2                	mov    %eax,%edx
80109519:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010951c:	01 d0                	add    %edx,%eax
8010951e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109521:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109527:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109529:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010952c:	83 c0 01             	add    $0x1,%eax
8010952f:	c1 e0 04             	shl    $0x4,%eax
80109532:	89 c2                	mov    %eax,%edx
80109534:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109537:	01 d0                	add    %edx,%eax
80109539:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010953c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109542:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109544:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109548:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010954c:	7e a3                	jle    801094f1 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010954e:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109553:	05 00 04 00 00       	add    $0x400,%eax
80109558:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010955b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010955e:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109564:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109569:	05 10 04 00 00       	add    $0x410,%eax
8010956e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109571:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109574:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
8010957a:	83 ec 0c             	sub    $0xc,%esp
8010957d:	68 98 ca 10 80       	push   $0x8010ca98
80109582:	e8 6d 6e ff ff       	call   801003f4 <cprintf>
80109587:	83 c4 10             	add    $0x10,%esp

}
8010958a:	90                   	nop
8010958b:	c9                   	leave  
8010958c:	c3                   	ret    

8010958d <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
8010958d:	55                   	push   %ebp
8010958e:	89 e5                	mov    %esp,%ebp
80109590:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109593:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109598:	83 c0 14             	add    $0x14,%eax
8010959b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010959e:	8b 45 08             	mov    0x8(%ebp),%eax
801095a1:	c1 e0 08             	shl    $0x8,%eax
801095a4:	0f b7 c0             	movzwl %ax,%eax
801095a7:	83 c8 01             	or     $0x1,%eax
801095aa:	89 c2                	mov    %eax,%edx
801095ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095af:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801095b1:	83 ec 0c             	sub    $0xc,%esp
801095b4:	68 b8 ca 10 80       	push   $0x8010cab8
801095b9:	e8 36 6e ff ff       	call   801003f4 <cprintf>
801095be:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801095c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c4:	8b 00                	mov    (%eax),%eax
801095c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801095c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095cc:	83 e0 10             	and    $0x10,%eax
801095cf:	85 c0                	test   %eax,%eax
801095d1:	75 02                	jne    801095d5 <i8254_read_eeprom+0x48>
  while(1){
801095d3:	eb dc                	jmp    801095b1 <i8254_read_eeprom+0x24>
      break;
801095d5:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801095d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d9:	8b 00                	mov    (%eax),%eax
801095db:	c1 e8 10             	shr    $0x10,%eax
}
801095de:	c9                   	leave  
801095df:	c3                   	ret    

801095e0 <i8254_recv>:
void i8254_recv(){
801095e0:	55                   	push   %ebp
801095e1:	89 e5                	mov    %esp,%ebp
801095e3:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801095e6:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801095eb:	05 10 28 00 00       	add    $0x2810,%eax
801095f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801095f3:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801095f8:	05 18 28 00 00       	add    $0x2818,%eax
801095fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109600:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109605:	05 00 28 00 00       	add    $0x2800,%eax
8010960a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010960d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109610:	8b 00                	mov    (%eax),%eax
80109612:	05 00 00 00 80       	add    $0x80000000,%eax
80109617:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010961a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010961d:	8b 10                	mov    (%eax),%edx
8010961f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109622:	8b 08                	mov    (%eax),%ecx
80109624:	89 d0                	mov    %edx,%eax
80109626:	29 c8                	sub    %ecx,%eax
80109628:	25 ff 00 00 00       	and    $0xff,%eax
8010962d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109630:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109634:	7e 37                	jle    8010966d <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109639:	8b 00                	mov    (%eax),%eax
8010963b:	c1 e0 04             	shl    $0x4,%eax
8010963e:	89 c2                	mov    %eax,%edx
80109640:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109643:	01 d0                	add    %edx,%eax
80109645:	8b 00                	mov    (%eax),%eax
80109647:	05 00 00 00 80       	add    $0x80000000,%eax
8010964c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
8010964f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109652:	8b 00                	mov    (%eax),%eax
80109654:	83 c0 01             	add    $0x1,%eax
80109657:	0f b6 d0             	movzbl %al,%edx
8010965a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010965d:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
8010965f:	83 ec 0c             	sub    $0xc,%esp
80109662:	ff 75 e0             	push   -0x20(%ebp)
80109665:	e8 15 09 00 00       	call   80109f7f <eth_proc>
8010966a:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
8010966d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109670:	8b 10                	mov    (%eax),%edx
80109672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109675:	8b 00                	mov    (%eax),%eax
80109677:	39 c2                	cmp    %eax,%edx
80109679:	75 9f                	jne    8010961a <i8254_recv+0x3a>
      (*rdt)--;
8010967b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010967e:	8b 00                	mov    (%eax),%eax
80109680:	8d 50 ff             	lea    -0x1(%eax),%edx
80109683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109686:	89 10                	mov    %edx,(%eax)
  while(1){
80109688:	eb 90                	jmp    8010961a <i8254_recv+0x3a>

8010968a <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010968a:	55                   	push   %ebp
8010968b:	89 e5                	mov    %esp,%ebp
8010968d:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109690:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
80109695:	05 10 38 00 00       	add    $0x3810,%eax
8010969a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010969d:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801096a2:	05 18 38 00 00       	add    $0x3818,%eax
801096a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801096aa:	a1 0c aa 11 80       	mov    0x8011aa0c,%eax
801096af:	05 00 38 00 00       	add    $0x3800,%eax
801096b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801096b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096ba:	8b 00                	mov    (%eax),%eax
801096bc:	05 00 00 00 80       	add    $0x80000000,%eax
801096c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801096c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096c7:	8b 10                	mov    (%eax),%edx
801096c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096cc:	8b 08                	mov    (%eax),%ecx
801096ce:	89 d0                	mov    %edx,%eax
801096d0:	29 c8                	sub    %ecx,%eax
801096d2:	0f b6 d0             	movzbl %al,%edx
801096d5:	b8 00 01 00 00       	mov    $0x100,%eax
801096da:	29 d0                	sub    %edx,%eax
801096dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801096df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096e2:	8b 00                	mov    (%eax),%eax
801096e4:	25 ff 00 00 00       	and    $0xff,%eax
801096e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801096ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801096f0:	0f 8e a8 00 00 00    	jle    8010979e <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801096f6:	8b 45 08             	mov    0x8(%ebp),%eax
801096f9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801096fc:	89 d1                	mov    %edx,%ecx
801096fe:	c1 e1 04             	shl    $0x4,%ecx
80109701:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109704:	01 ca                	add    %ecx,%edx
80109706:	8b 12                	mov    (%edx),%edx
80109708:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010970e:	83 ec 04             	sub    $0x4,%esp
80109711:	ff 75 0c             	push   0xc(%ebp)
80109714:	50                   	push   %eax
80109715:	52                   	push   %edx
80109716:	e8 e4 bc ff ff       	call   801053ff <memmove>
8010971b:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010971e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109721:	c1 e0 04             	shl    $0x4,%eax
80109724:	89 c2                	mov    %eax,%edx
80109726:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109729:	01 d0                	add    %edx,%eax
8010972b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010972e:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109732:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109735:	c1 e0 04             	shl    $0x4,%eax
80109738:	89 c2                	mov    %eax,%edx
8010973a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010973d:	01 d0                	add    %edx,%eax
8010973f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109743:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109746:	c1 e0 04             	shl    $0x4,%eax
80109749:	89 c2                	mov    %eax,%edx
8010974b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010974e:	01 d0                	add    %edx,%eax
80109750:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109754:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109757:	c1 e0 04             	shl    $0x4,%eax
8010975a:	89 c2                	mov    %eax,%edx
8010975c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010975f:	01 d0                	add    %edx,%eax
80109761:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109765:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109768:	c1 e0 04             	shl    $0x4,%eax
8010976b:	89 c2                	mov    %eax,%edx
8010976d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109770:	01 d0                	add    %edx,%eax
80109772:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109778:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010977b:	c1 e0 04             	shl    $0x4,%eax
8010977e:	89 c2                	mov    %eax,%edx
80109780:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109783:	01 d0                	add    %edx,%eax
80109785:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109789:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010978c:	8b 00                	mov    (%eax),%eax
8010978e:	83 c0 01             	add    $0x1,%eax
80109791:	0f b6 d0             	movzbl %al,%edx
80109794:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109797:	89 10                	mov    %edx,(%eax)
    return len;
80109799:	8b 45 0c             	mov    0xc(%ebp),%eax
8010979c:	eb 05                	jmp    801097a3 <i8254_send+0x119>
  }else{
    return -1;
8010979e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801097a3:	c9                   	leave  
801097a4:	c3                   	ret    

801097a5 <i8254_intr>:

void i8254_intr(){
801097a5:	55                   	push   %ebp
801097a6:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801097a8:	a1 18 aa 11 80       	mov    0x8011aa18,%eax
801097ad:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801097b3:	90                   	nop
801097b4:	5d                   	pop    %ebp
801097b5:	c3                   	ret    

801097b6 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801097b6:	55                   	push   %ebp
801097b7:	89 e5                	mov    %esp,%ebp
801097b9:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801097bc:	8b 45 08             	mov    0x8(%ebp),%eax
801097bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801097c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097c5:	0f b7 00             	movzwl (%eax),%eax
801097c8:	66 3d 00 01          	cmp    $0x100,%ax
801097cc:	74 0a                	je     801097d8 <arp_proc+0x22>
801097ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097d3:	e9 4f 01 00 00       	jmp    80109927 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801097d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097db:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801097df:	66 83 f8 08          	cmp    $0x8,%ax
801097e3:	74 0a                	je     801097ef <arp_proc+0x39>
801097e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097ea:	e9 38 01 00 00       	jmp    80109927 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
801097ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801097f6:	3c 06                	cmp    $0x6,%al
801097f8:	74 0a                	je     80109804 <arp_proc+0x4e>
801097fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097ff:	e9 23 01 00 00       	jmp    80109927 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109807:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010980b:	3c 04                	cmp    $0x4,%al
8010980d:	74 0a                	je     80109819 <arp_proc+0x63>
8010980f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109814:	e9 0e 01 00 00       	jmp    80109927 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010981c:	83 c0 18             	add    $0x18,%eax
8010981f:	83 ec 04             	sub    $0x4,%esp
80109822:	6a 04                	push   $0x4
80109824:	50                   	push   %eax
80109825:	68 24 f5 10 80       	push   $0x8010f524
8010982a:	e8 78 bb ff ff       	call   801053a7 <memcmp>
8010982f:	83 c4 10             	add    $0x10,%esp
80109832:	85 c0                	test   %eax,%eax
80109834:	74 27                	je     8010985d <arp_proc+0xa7>
80109836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109839:	83 c0 0e             	add    $0xe,%eax
8010983c:	83 ec 04             	sub    $0x4,%esp
8010983f:	6a 04                	push   $0x4
80109841:	50                   	push   %eax
80109842:	68 24 f5 10 80       	push   $0x8010f524
80109847:	e8 5b bb ff ff       	call   801053a7 <memcmp>
8010984c:	83 c4 10             	add    $0x10,%esp
8010984f:	85 c0                	test   %eax,%eax
80109851:	74 0a                	je     8010985d <arp_proc+0xa7>
80109853:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109858:	e9 ca 00 00 00       	jmp    80109927 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010985d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109860:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109864:	66 3d 00 01          	cmp    $0x100,%ax
80109868:	75 69                	jne    801098d3 <arp_proc+0x11d>
8010986a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010986d:	83 c0 18             	add    $0x18,%eax
80109870:	83 ec 04             	sub    $0x4,%esp
80109873:	6a 04                	push   $0x4
80109875:	50                   	push   %eax
80109876:	68 24 f5 10 80       	push   $0x8010f524
8010987b:	e8 27 bb ff ff       	call   801053a7 <memcmp>
80109880:	83 c4 10             	add    $0x10,%esp
80109883:	85 c0                	test   %eax,%eax
80109885:	75 4c                	jne    801098d3 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109887:	e8 f8 93 ff ff       	call   80102c84 <kalloc>
8010988c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010988f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109896:	83 ec 04             	sub    $0x4,%esp
80109899:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010989c:	50                   	push   %eax
8010989d:	ff 75 f0             	push   -0x10(%ebp)
801098a0:	ff 75 f4             	push   -0xc(%ebp)
801098a3:	e8 1f 04 00 00       	call   80109cc7 <arp_reply_pkt_create>
801098a8:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801098ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098ae:	83 ec 08             	sub    $0x8,%esp
801098b1:	50                   	push   %eax
801098b2:	ff 75 f0             	push   -0x10(%ebp)
801098b5:	e8 d0 fd ff ff       	call   8010968a <i8254_send>
801098ba:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801098bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c0:	83 ec 0c             	sub    $0xc,%esp
801098c3:	50                   	push   %eax
801098c4:	e8 21 93 ff ff       	call   80102bea <kfree>
801098c9:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801098cc:	b8 02 00 00 00       	mov    $0x2,%eax
801098d1:	eb 54                	jmp    80109927 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801098d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098da:	66 3d 00 02          	cmp    $0x200,%ax
801098de:	75 42                	jne    80109922 <arp_proc+0x16c>
801098e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098e3:	83 c0 18             	add    $0x18,%eax
801098e6:	83 ec 04             	sub    $0x4,%esp
801098e9:	6a 04                	push   $0x4
801098eb:	50                   	push   %eax
801098ec:	68 24 f5 10 80       	push   $0x8010f524
801098f1:	e8 b1 ba ff ff       	call   801053a7 <memcmp>
801098f6:	83 c4 10             	add    $0x10,%esp
801098f9:	85 c0                	test   %eax,%eax
801098fb:	75 25                	jne    80109922 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801098fd:	83 ec 0c             	sub    $0xc,%esp
80109900:	68 bc ca 10 80       	push   $0x8010cabc
80109905:	e8 ea 6a ff ff       	call   801003f4 <cprintf>
8010990a:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010990d:	83 ec 0c             	sub    $0xc,%esp
80109910:	ff 75 f4             	push   -0xc(%ebp)
80109913:	e8 af 01 00 00       	call   80109ac7 <arp_table_update>
80109918:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010991b:	b8 01 00 00 00       	mov    $0x1,%eax
80109920:	eb 05                	jmp    80109927 <arp_proc+0x171>
  }else{
    return -1;
80109922:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109927:	c9                   	leave  
80109928:	c3                   	ret    

80109929 <arp_scan>:

void arp_scan(){
80109929:	55                   	push   %ebp
8010992a:	89 e5                	mov    %esp,%ebp
8010992c:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010992f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109936:	eb 6f                	jmp    801099a7 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109938:	e8 47 93 ff ff       	call   80102c84 <kalloc>
8010993d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109940:	83 ec 04             	sub    $0x4,%esp
80109943:	ff 75 f4             	push   -0xc(%ebp)
80109946:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109949:	50                   	push   %eax
8010994a:	ff 75 ec             	push   -0x14(%ebp)
8010994d:	e8 62 00 00 00       	call   801099b4 <arp_broadcast>
80109952:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109955:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109958:	83 ec 08             	sub    $0x8,%esp
8010995b:	50                   	push   %eax
8010995c:	ff 75 ec             	push   -0x14(%ebp)
8010995f:	e8 26 fd ff ff       	call   8010968a <i8254_send>
80109964:	83 c4 10             	add    $0x10,%esp
80109967:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010996a:	eb 22                	jmp    8010998e <arp_scan+0x65>
      microdelay(1);
8010996c:	83 ec 0c             	sub    $0xc,%esp
8010996f:	6a 01                	push   $0x1
80109971:	e8 a5 96 ff ff       	call   8010301b <microdelay>
80109976:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109979:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010997c:	83 ec 08             	sub    $0x8,%esp
8010997f:	50                   	push   %eax
80109980:	ff 75 ec             	push   -0x14(%ebp)
80109983:	e8 02 fd ff ff       	call   8010968a <i8254_send>
80109988:	83 c4 10             	add    $0x10,%esp
8010998b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010998e:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109992:	74 d8                	je     8010996c <arp_scan+0x43>
    }
    kfree((char *)send);
80109994:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109997:	83 ec 0c             	sub    $0xc,%esp
8010999a:	50                   	push   %eax
8010999b:	e8 4a 92 ff ff       	call   80102bea <kfree>
801099a0:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801099a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801099a7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801099ae:	7e 88                	jle    80109938 <arp_scan+0xf>
  }
}
801099b0:	90                   	nop
801099b1:	90                   	nop
801099b2:	c9                   	leave  
801099b3:	c3                   	ret    

801099b4 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801099b4:	55                   	push   %ebp
801099b5:	89 e5                	mov    %esp,%ebp
801099b7:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801099ba:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801099be:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801099c2:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801099c6:	8b 45 10             	mov    0x10(%ebp),%eax
801099c9:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801099cc:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801099d3:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801099d9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801099e0:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801099e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801099e9:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801099ef:	8b 45 08             	mov    0x8(%ebp),%eax
801099f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801099f5:	8b 45 08             	mov    0x8(%ebp),%eax
801099f8:	83 c0 0e             	add    $0xe,%eax
801099fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801099fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a01:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a08:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a0f:	83 ec 04             	sub    $0x4,%esp
80109a12:	6a 06                	push   $0x6
80109a14:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109a17:	52                   	push   %edx
80109a18:	50                   	push   %eax
80109a19:	e8 e1 b9 ff ff       	call   801053ff <memmove>
80109a1e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a24:	83 c0 06             	add    $0x6,%eax
80109a27:	83 ec 04             	sub    $0x4,%esp
80109a2a:	6a 06                	push   $0x6
80109a2c:	68 10 aa 11 80       	push   $0x8011aa10
80109a31:	50                   	push   %eax
80109a32:	e8 c8 b9 ff ff       	call   801053ff <memmove>
80109a37:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a3d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a45:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a4e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a55:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a5c:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a65:	8d 50 12             	lea    0x12(%eax),%edx
80109a68:	83 ec 04             	sub    $0x4,%esp
80109a6b:	6a 06                	push   $0x6
80109a6d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109a70:	50                   	push   %eax
80109a71:	52                   	push   %edx
80109a72:	e8 88 b9 ff ff       	call   801053ff <memmove>
80109a77:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a7d:	8d 50 18             	lea    0x18(%eax),%edx
80109a80:	83 ec 04             	sub    $0x4,%esp
80109a83:	6a 04                	push   $0x4
80109a85:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109a88:	50                   	push   %eax
80109a89:	52                   	push   %edx
80109a8a:	e8 70 b9 ff ff       	call   801053ff <memmove>
80109a8f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a95:	83 c0 08             	add    $0x8,%eax
80109a98:	83 ec 04             	sub    $0x4,%esp
80109a9b:	6a 06                	push   $0x6
80109a9d:	68 10 aa 11 80       	push   $0x8011aa10
80109aa2:	50                   	push   %eax
80109aa3:	e8 57 b9 ff ff       	call   801053ff <memmove>
80109aa8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aae:	83 c0 0e             	add    $0xe,%eax
80109ab1:	83 ec 04             	sub    $0x4,%esp
80109ab4:	6a 04                	push   $0x4
80109ab6:	68 24 f5 10 80       	push   $0x8010f524
80109abb:	50                   	push   %eax
80109abc:	e8 3e b9 ff ff       	call   801053ff <memmove>
80109ac1:	83 c4 10             	add    $0x10,%esp
}
80109ac4:	90                   	nop
80109ac5:	c9                   	leave  
80109ac6:	c3                   	ret    

80109ac7 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109ac7:	55                   	push   %ebp
80109ac8:	89 e5                	mov    %esp,%ebp
80109aca:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109acd:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad0:	83 c0 0e             	add    $0xe,%eax
80109ad3:	83 ec 0c             	sub    $0xc,%esp
80109ad6:	50                   	push   %eax
80109ad7:	e8 bc 00 00 00       	call   80109b98 <arp_table_search>
80109adc:	83 c4 10             	add    $0x10,%esp
80109adf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109ae2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109ae6:	78 2d                	js     80109b15 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80109aeb:	8d 48 08             	lea    0x8(%eax),%ecx
80109aee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109af1:	89 d0                	mov    %edx,%eax
80109af3:	c1 e0 02             	shl    $0x2,%eax
80109af6:	01 d0                	add    %edx,%eax
80109af8:	01 c0                	add    %eax,%eax
80109afa:	01 d0                	add    %edx,%eax
80109afc:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109b01:	83 c0 04             	add    $0x4,%eax
80109b04:	83 ec 04             	sub    $0x4,%esp
80109b07:	6a 06                	push   $0x6
80109b09:	51                   	push   %ecx
80109b0a:	50                   	push   %eax
80109b0b:	e8 ef b8 ff ff       	call   801053ff <memmove>
80109b10:	83 c4 10             	add    $0x10,%esp
80109b13:	eb 70                	jmp    80109b85 <arp_table_update+0xbe>
  }else{
    index += 1;
80109b15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109b19:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1f:	8d 48 08             	lea    0x8(%eax),%ecx
80109b22:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b25:	89 d0                	mov    %edx,%eax
80109b27:	c1 e0 02             	shl    $0x2,%eax
80109b2a:	01 d0                	add    %edx,%eax
80109b2c:	01 c0                	add    %eax,%eax
80109b2e:	01 d0                	add    %edx,%eax
80109b30:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109b35:	83 c0 04             	add    $0x4,%eax
80109b38:	83 ec 04             	sub    $0x4,%esp
80109b3b:	6a 06                	push   $0x6
80109b3d:	51                   	push   %ecx
80109b3e:	50                   	push   %eax
80109b3f:	e8 bb b8 ff ff       	call   801053ff <memmove>
80109b44:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109b47:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4a:	8d 48 0e             	lea    0xe(%eax),%ecx
80109b4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b50:	89 d0                	mov    %edx,%eax
80109b52:	c1 e0 02             	shl    $0x2,%eax
80109b55:	01 d0                	add    %edx,%eax
80109b57:	01 c0                	add    %eax,%eax
80109b59:	01 d0                	add    %edx,%eax
80109b5b:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109b60:	83 ec 04             	sub    $0x4,%esp
80109b63:	6a 04                	push   $0x4
80109b65:	51                   	push   %ecx
80109b66:	50                   	push   %eax
80109b67:	e8 93 b8 ff ff       	call   801053ff <memmove>
80109b6c:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b72:	89 d0                	mov    %edx,%eax
80109b74:	c1 e0 02             	shl    $0x2,%eax
80109b77:	01 d0                	add    %edx,%eax
80109b79:	01 c0                	add    %eax,%eax
80109b7b:	01 d0                	add    %edx,%eax
80109b7d:	05 2a aa 11 80       	add    $0x8011aa2a,%eax
80109b82:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109b85:	83 ec 0c             	sub    $0xc,%esp
80109b88:	68 20 aa 11 80       	push   $0x8011aa20
80109b8d:	e8 83 00 00 00       	call   80109c15 <print_arp_table>
80109b92:	83 c4 10             	add    $0x10,%esp
}
80109b95:	90                   	nop
80109b96:	c9                   	leave  
80109b97:	c3                   	ret    

80109b98 <arp_table_search>:

int arp_table_search(uchar *ip){
80109b98:	55                   	push   %ebp
80109b99:	89 e5                	mov    %esp,%ebp
80109b9b:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109b9e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109ba5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109bac:	eb 59                	jmp    80109c07 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109bae:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109bb1:	89 d0                	mov    %edx,%eax
80109bb3:	c1 e0 02             	shl    $0x2,%eax
80109bb6:	01 d0                	add    %edx,%eax
80109bb8:	01 c0                	add    %eax,%eax
80109bba:	01 d0                	add    %edx,%eax
80109bbc:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109bc1:	83 ec 04             	sub    $0x4,%esp
80109bc4:	6a 04                	push   $0x4
80109bc6:	ff 75 08             	push   0x8(%ebp)
80109bc9:	50                   	push   %eax
80109bca:	e8 d8 b7 ff ff       	call   801053a7 <memcmp>
80109bcf:	83 c4 10             	add    $0x10,%esp
80109bd2:	85 c0                	test   %eax,%eax
80109bd4:	75 05                	jne    80109bdb <arp_table_search+0x43>
      return i;
80109bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd9:	eb 38                	jmp    80109c13 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109bdb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109bde:	89 d0                	mov    %edx,%eax
80109be0:	c1 e0 02             	shl    $0x2,%eax
80109be3:	01 d0                	add    %edx,%eax
80109be5:	01 c0                	add    %eax,%eax
80109be7:	01 d0                	add    %edx,%eax
80109be9:	05 2a aa 11 80       	add    $0x8011aa2a,%eax
80109bee:	0f b6 00             	movzbl (%eax),%eax
80109bf1:	84 c0                	test   %al,%al
80109bf3:	75 0e                	jne    80109c03 <arp_table_search+0x6b>
80109bf5:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109bf9:	75 08                	jne    80109c03 <arp_table_search+0x6b>
      empty = -i;
80109bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bfe:	f7 d8                	neg    %eax
80109c00:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109c03:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109c07:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109c0b:	7e a1                	jle    80109bae <arp_table_search+0x16>
    }
  }
  return empty-1;
80109c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c10:	83 e8 01             	sub    $0x1,%eax
}
80109c13:	c9                   	leave  
80109c14:	c3                   	ret    

80109c15 <print_arp_table>:

void print_arp_table(){
80109c15:	55                   	push   %ebp
80109c16:	89 e5                	mov    %esp,%ebp
80109c18:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109c1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109c22:	e9 92 00 00 00       	jmp    80109cb9 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109c27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c2a:	89 d0                	mov    %edx,%eax
80109c2c:	c1 e0 02             	shl    $0x2,%eax
80109c2f:	01 d0                	add    %edx,%eax
80109c31:	01 c0                	add    %eax,%eax
80109c33:	01 d0                	add    %edx,%eax
80109c35:	05 2a aa 11 80       	add    $0x8011aa2a,%eax
80109c3a:	0f b6 00             	movzbl (%eax),%eax
80109c3d:	84 c0                	test   %al,%al
80109c3f:	74 74                	je     80109cb5 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109c41:	83 ec 08             	sub    $0x8,%esp
80109c44:	ff 75 f4             	push   -0xc(%ebp)
80109c47:	68 cf ca 10 80       	push   $0x8010cacf
80109c4c:	e8 a3 67 ff ff       	call   801003f4 <cprintf>
80109c51:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109c54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c57:	89 d0                	mov    %edx,%eax
80109c59:	c1 e0 02             	shl    $0x2,%eax
80109c5c:	01 d0                	add    %edx,%eax
80109c5e:	01 c0                	add    %eax,%eax
80109c60:	01 d0                	add    %edx,%eax
80109c62:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109c67:	83 ec 0c             	sub    $0xc,%esp
80109c6a:	50                   	push   %eax
80109c6b:	e8 54 02 00 00       	call   80109ec4 <print_ipv4>
80109c70:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109c73:	83 ec 0c             	sub    $0xc,%esp
80109c76:	68 de ca 10 80       	push   $0x8010cade
80109c7b:	e8 74 67 ff ff       	call   801003f4 <cprintf>
80109c80:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109c83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c86:	89 d0                	mov    %edx,%eax
80109c88:	c1 e0 02             	shl    $0x2,%eax
80109c8b:	01 d0                	add    %edx,%eax
80109c8d:	01 c0                	add    %eax,%eax
80109c8f:	01 d0                	add    %edx,%eax
80109c91:	05 20 aa 11 80       	add    $0x8011aa20,%eax
80109c96:	83 c0 04             	add    $0x4,%eax
80109c99:	83 ec 0c             	sub    $0xc,%esp
80109c9c:	50                   	push   %eax
80109c9d:	e8 70 02 00 00       	call   80109f12 <print_mac>
80109ca2:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109ca5:	83 ec 0c             	sub    $0xc,%esp
80109ca8:	68 e0 ca 10 80       	push   $0x8010cae0
80109cad:	e8 42 67 ff ff       	call   801003f4 <cprintf>
80109cb2:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109cb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109cb9:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109cbd:	0f 8e 64 ff ff ff    	jle    80109c27 <print_arp_table+0x12>
    }
  }
}
80109cc3:	90                   	nop
80109cc4:	90                   	nop
80109cc5:	c9                   	leave  
80109cc6:	c3                   	ret    

80109cc7 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109cc7:	55                   	push   %ebp
80109cc8:	89 e5                	mov    %esp,%ebp
80109cca:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109ccd:	8b 45 10             	mov    0x10(%ebp),%eax
80109cd0:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cdf:	83 c0 0e             	add    $0xe,%eax
80109ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ce8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cef:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80109cf6:	8d 50 08             	lea    0x8(%eax),%edx
80109cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cfc:	83 ec 04             	sub    $0x4,%esp
80109cff:	6a 06                	push   $0x6
80109d01:	52                   	push   %edx
80109d02:	50                   	push   %eax
80109d03:	e8 f7 b6 ff ff       	call   801053ff <memmove>
80109d08:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d0e:	83 c0 06             	add    $0x6,%eax
80109d11:	83 ec 04             	sub    $0x4,%esp
80109d14:	6a 06                	push   $0x6
80109d16:	68 10 aa 11 80       	push   $0x8011aa10
80109d1b:	50                   	push   %eax
80109d1c:	e8 de b6 ff ff       	call   801053ff <memmove>
80109d21:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109d24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d27:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d2f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d38:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d3f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d46:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d4f:	8d 50 08             	lea    0x8(%eax),%edx
80109d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d55:	83 c0 12             	add    $0x12,%eax
80109d58:	83 ec 04             	sub    $0x4,%esp
80109d5b:	6a 06                	push   $0x6
80109d5d:	52                   	push   %edx
80109d5e:	50                   	push   %eax
80109d5f:	e8 9b b6 ff ff       	call   801053ff <memmove>
80109d64:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109d67:	8b 45 08             	mov    0x8(%ebp),%eax
80109d6a:	8d 50 0e             	lea    0xe(%eax),%edx
80109d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d70:	83 c0 18             	add    $0x18,%eax
80109d73:	83 ec 04             	sub    $0x4,%esp
80109d76:	6a 04                	push   $0x4
80109d78:	52                   	push   %edx
80109d79:	50                   	push   %eax
80109d7a:	e8 80 b6 ff ff       	call   801053ff <memmove>
80109d7f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d85:	83 c0 08             	add    $0x8,%eax
80109d88:	83 ec 04             	sub    $0x4,%esp
80109d8b:	6a 06                	push   $0x6
80109d8d:	68 10 aa 11 80       	push   $0x8011aa10
80109d92:	50                   	push   %eax
80109d93:	e8 67 b6 ff ff       	call   801053ff <memmove>
80109d98:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d9e:	83 c0 0e             	add    $0xe,%eax
80109da1:	83 ec 04             	sub    $0x4,%esp
80109da4:	6a 04                	push   $0x4
80109da6:	68 24 f5 10 80       	push   $0x8010f524
80109dab:	50                   	push   %eax
80109dac:	e8 4e b6 ff ff       	call   801053ff <memmove>
80109db1:	83 c4 10             	add    $0x10,%esp
}
80109db4:	90                   	nop
80109db5:	c9                   	leave  
80109db6:	c3                   	ret    

80109db7 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109db7:	55                   	push   %ebp
80109db8:	89 e5                	mov    %esp,%ebp
80109dba:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109dbd:	83 ec 0c             	sub    $0xc,%esp
80109dc0:	68 e2 ca 10 80       	push   $0x8010cae2
80109dc5:	e8 2a 66 ff ff       	call   801003f4 <cprintf>
80109dca:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80109dd0:	83 c0 0e             	add    $0xe,%eax
80109dd3:	83 ec 0c             	sub    $0xc,%esp
80109dd6:	50                   	push   %eax
80109dd7:	e8 e8 00 00 00       	call   80109ec4 <print_ipv4>
80109ddc:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109ddf:	83 ec 0c             	sub    $0xc,%esp
80109de2:	68 e0 ca 10 80       	push   $0x8010cae0
80109de7:	e8 08 66 ff ff       	call   801003f4 <cprintf>
80109dec:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109def:	8b 45 08             	mov    0x8(%ebp),%eax
80109df2:	83 c0 08             	add    $0x8,%eax
80109df5:	83 ec 0c             	sub    $0xc,%esp
80109df8:	50                   	push   %eax
80109df9:	e8 14 01 00 00       	call   80109f12 <print_mac>
80109dfe:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109e01:	83 ec 0c             	sub    $0xc,%esp
80109e04:	68 e0 ca 10 80       	push   $0x8010cae0
80109e09:	e8 e6 65 ff ff       	call   801003f4 <cprintf>
80109e0e:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109e11:	83 ec 0c             	sub    $0xc,%esp
80109e14:	68 f9 ca 10 80       	push   $0x8010caf9
80109e19:	e8 d6 65 ff ff       	call   801003f4 <cprintf>
80109e1e:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109e21:	8b 45 08             	mov    0x8(%ebp),%eax
80109e24:	83 c0 18             	add    $0x18,%eax
80109e27:	83 ec 0c             	sub    $0xc,%esp
80109e2a:	50                   	push   %eax
80109e2b:	e8 94 00 00 00       	call   80109ec4 <print_ipv4>
80109e30:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109e33:	83 ec 0c             	sub    $0xc,%esp
80109e36:	68 e0 ca 10 80       	push   $0x8010cae0
80109e3b:	e8 b4 65 ff ff       	call   801003f4 <cprintf>
80109e40:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109e43:	8b 45 08             	mov    0x8(%ebp),%eax
80109e46:	83 c0 12             	add    $0x12,%eax
80109e49:	83 ec 0c             	sub    $0xc,%esp
80109e4c:	50                   	push   %eax
80109e4d:	e8 c0 00 00 00       	call   80109f12 <print_mac>
80109e52:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109e55:	83 ec 0c             	sub    $0xc,%esp
80109e58:	68 e0 ca 10 80       	push   $0x8010cae0
80109e5d:	e8 92 65 ff ff       	call   801003f4 <cprintf>
80109e62:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109e65:	83 ec 0c             	sub    $0xc,%esp
80109e68:	68 10 cb 10 80       	push   $0x8010cb10
80109e6d:	e8 82 65 ff ff       	call   801003f4 <cprintf>
80109e72:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109e75:	8b 45 08             	mov    0x8(%ebp),%eax
80109e78:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e7c:	66 3d 00 01          	cmp    $0x100,%ax
80109e80:	75 12                	jne    80109e94 <print_arp_info+0xdd>
80109e82:	83 ec 0c             	sub    $0xc,%esp
80109e85:	68 1c cb 10 80       	push   $0x8010cb1c
80109e8a:	e8 65 65 ff ff       	call   801003f4 <cprintf>
80109e8f:	83 c4 10             	add    $0x10,%esp
80109e92:	eb 1d                	jmp    80109eb1 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109e94:	8b 45 08             	mov    0x8(%ebp),%eax
80109e97:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e9b:	66 3d 00 02          	cmp    $0x200,%ax
80109e9f:	75 10                	jne    80109eb1 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109ea1:	83 ec 0c             	sub    $0xc,%esp
80109ea4:	68 25 cb 10 80       	push   $0x8010cb25
80109ea9:	e8 46 65 ff ff       	call   801003f4 <cprintf>
80109eae:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109eb1:	83 ec 0c             	sub    $0xc,%esp
80109eb4:	68 e0 ca 10 80       	push   $0x8010cae0
80109eb9:	e8 36 65 ff ff       	call   801003f4 <cprintf>
80109ebe:	83 c4 10             	add    $0x10,%esp
}
80109ec1:	90                   	nop
80109ec2:	c9                   	leave  
80109ec3:	c3                   	ret    

80109ec4 <print_ipv4>:

void print_ipv4(uchar *ip){
80109ec4:	55                   	push   %ebp
80109ec5:	89 e5                	mov    %esp,%ebp
80109ec7:	53                   	push   %ebx
80109ec8:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80109ece:	83 c0 03             	add    $0x3,%eax
80109ed1:	0f b6 00             	movzbl (%eax),%eax
80109ed4:	0f b6 d8             	movzbl %al,%ebx
80109ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80109eda:	83 c0 02             	add    $0x2,%eax
80109edd:	0f b6 00             	movzbl (%eax),%eax
80109ee0:	0f b6 c8             	movzbl %al,%ecx
80109ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee6:	83 c0 01             	add    $0x1,%eax
80109ee9:	0f b6 00             	movzbl (%eax),%eax
80109eec:	0f b6 d0             	movzbl %al,%edx
80109eef:	8b 45 08             	mov    0x8(%ebp),%eax
80109ef2:	0f b6 00             	movzbl (%eax),%eax
80109ef5:	0f b6 c0             	movzbl %al,%eax
80109ef8:	83 ec 0c             	sub    $0xc,%esp
80109efb:	53                   	push   %ebx
80109efc:	51                   	push   %ecx
80109efd:	52                   	push   %edx
80109efe:	50                   	push   %eax
80109eff:	68 2c cb 10 80       	push   $0x8010cb2c
80109f04:	e8 eb 64 ff ff       	call   801003f4 <cprintf>
80109f09:	83 c4 20             	add    $0x20,%esp
}
80109f0c:	90                   	nop
80109f0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109f10:	c9                   	leave  
80109f11:	c3                   	ret    

80109f12 <print_mac>:

void print_mac(uchar *mac){
80109f12:	55                   	push   %ebp
80109f13:	89 e5                	mov    %esp,%ebp
80109f15:	57                   	push   %edi
80109f16:	56                   	push   %esi
80109f17:	53                   	push   %ebx
80109f18:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f1e:	83 c0 05             	add    $0x5,%eax
80109f21:	0f b6 00             	movzbl (%eax),%eax
80109f24:	0f b6 f8             	movzbl %al,%edi
80109f27:	8b 45 08             	mov    0x8(%ebp),%eax
80109f2a:	83 c0 04             	add    $0x4,%eax
80109f2d:	0f b6 00             	movzbl (%eax),%eax
80109f30:	0f b6 f0             	movzbl %al,%esi
80109f33:	8b 45 08             	mov    0x8(%ebp),%eax
80109f36:	83 c0 03             	add    $0x3,%eax
80109f39:	0f b6 00             	movzbl (%eax),%eax
80109f3c:	0f b6 d8             	movzbl %al,%ebx
80109f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80109f42:	83 c0 02             	add    $0x2,%eax
80109f45:	0f b6 00             	movzbl (%eax),%eax
80109f48:	0f b6 c8             	movzbl %al,%ecx
80109f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f4e:	83 c0 01             	add    $0x1,%eax
80109f51:	0f b6 00             	movzbl (%eax),%eax
80109f54:	0f b6 d0             	movzbl %al,%edx
80109f57:	8b 45 08             	mov    0x8(%ebp),%eax
80109f5a:	0f b6 00             	movzbl (%eax),%eax
80109f5d:	0f b6 c0             	movzbl %al,%eax
80109f60:	83 ec 04             	sub    $0x4,%esp
80109f63:	57                   	push   %edi
80109f64:	56                   	push   %esi
80109f65:	53                   	push   %ebx
80109f66:	51                   	push   %ecx
80109f67:	52                   	push   %edx
80109f68:	50                   	push   %eax
80109f69:	68 44 cb 10 80       	push   $0x8010cb44
80109f6e:	e8 81 64 ff ff       	call   801003f4 <cprintf>
80109f73:	83 c4 20             	add    $0x20,%esp
}
80109f76:	90                   	nop
80109f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109f7a:	5b                   	pop    %ebx
80109f7b:	5e                   	pop    %esi
80109f7c:	5f                   	pop    %edi
80109f7d:	5d                   	pop    %ebp
80109f7e:	c3                   	ret    

80109f7f <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109f7f:	55                   	push   %ebp
80109f80:	89 e5                	mov    %esp,%ebp
80109f82:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109f85:	8b 45 08             	mov    0x8(%ebp),%eax
80109f88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f8e:	83 c0 0e             	add    $0xe,%eax
80109f91:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f97:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109f9b:	3c 08                	cmp    $0x8,%al
80109f9d:	75 1b                	jne    80109fba <eth_proc+0x3b>
80109f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fa2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109fa6:	3c 06                	cmp    $0x6,%al
80109fa8:	75 10                	jne    80109fba <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109faa:	83 ec 0c             	sub    $0xc,%esp
80109fad:	ff 75 f0             	push   -0x10(%ebp)
80109fb0:	e8 01 f8 ff ff       	call   801097b6 <arp_proc>
80109fb5:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109fb8:	eb 24                	jmp    80109fde <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fbd:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109fc1:	3c 08                	cmp    $0x8,%al
80109fc3:	75 19                	jne    80109fde <eth_proc+0x5f>
80109fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fc8:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109fcc:	84 c0                	test   %al,%al
80109fce:	75 0e                	jne    80109fde <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109fd0:	83 ec 0c             	sub    $0xc,%esp
80109fd3:	ff 75 08             	push   0x8(%ebp)
80109fd6:	e8 a3 00 00 00       	call   8010a07e <ipv4_proc>
80109fdb:	83 c4 10             	add    $0x10,%esp
}
80109fde:	90                   	nop
80109fdf:	c9                   	leave  
80109fe0:	c3                   	ret    

80109fe1 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109fe1:	55                   	push   %ebp
80109fe2:	89 e5                	mov    %esp,%ebp
80109fe4:	83 ec 04             	sub    $0x4,%esp
80109fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80109fea:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109fee:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ff2:	c1 e0 08             	shl    $0x8,%eax
80109ff5:	89 c2                	mov    %eax,%edx
80109ff7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ffb:	66 c1 e8 08          	shr    $0x8,%ax
80109fff:	01 d0                	add    %edx,%eax
}
8010a001:	c9                   	leave  
8010a002:	c3                   	ret    

8010a003 <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010a003:	55                   	push   %ebp
8010a004:	89 e5                	mov    %esp,%ebp
8010a006:	83 ec 04             	sub    $0x4,%esp
8010a009:	8b 45 08             	mov    0x8(%ebp),%eax
8010a00c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a010:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a014:	c1 e0 08             	shl    $0x8,%eax
8010a017:	89 c2                	mov    %eax,%edx
8010a019:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a01d:	66 c1 e8 08          	shr    $0x8,%ax
8010a021:	01 d0                	add    %edx,%eax
}
8010a023:	c9                   	leave  
8010a024:	c3                   	ret    

8010a025 <H2N_uint>:

uint H2N_uint(uint value){
8010a025:	55                   	push   %ebp
8010a026:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010a028:	8b 45 08             	mov    0x8(%ebp),%eax
8010a02b:	c1 e0 18             	shl    $0x18,%eax
8010a02e:	25 00 00 00 0f       	and    $0xf000000,%eax
8010a033:	89 c2                	mov    %eax,%edx
8010a035:	8b 45 08             	mov    0x8(%ebp),%eax
8010a038:	c1 e0 08             	shl    $0x8,%eax
8010a03b:	25 00 f0 00 00       	and    $0xf000,%eax
8010a040:	09 c2                	or     %eax,%edx
8010a042:	8b 45 08             	mov    0x8(%ebp),%eax
8010a045:	c1 e8 08             	shr    $0x8,%eax
8010a048:	83 e0 0f             	and    $0xf,%eax
8010a04b:	01 d0                	add    %edx,%eax
}
8010a04d:	5d                   	pop    %ebp
8010a04e:	c3                   	ret    

8010a04f <N2H_uint>:

uint N2H_uint(uint value){
8010a04f:	55                   	push   %ebp
8010a050:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a052:	8b 45 08             	mov    0x8(%ebp),%eax
8010a055:	c1 e0 18             	shl    $0x18,%eax
8010a058:	89 c2                	mov    %eax,%edx
8010a05a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a05d:	c1 e0 08             	shl    $0x8,%eax
8010a060:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a065:	01 c2                	add    %eax,%edx
8010a067:	8b 45 08             	mov    0x8(%ebp),%eax
8010a06a:	c1 e8 08             	shr    $0x8,%eax
8010a06d:	25 00 ff 00 00       	and    $0xff00,%eax
8010a072:	01 c2                	add    %eax,%edx
8010a074:	8b 45 08             	mov    0x8(%ebp),%eax
8010a077:	c1 e8 18             	shr    $0x18,%eax
8010a07a:	01 d0                	add    %edx,%eax
}
8010a07c:	5d                   	pop    %ebp
8010a07d:	c3                   	ret    

8010a07e <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a07e:	55                   	push   %ebp
8010a07f:	89 e5                	mov    %esp,%ebp
8010a081:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a084:	8b 45 08             	mov    0x8(%ebp),%eax
8010a087:	83 c0 0e             	add    $0xe,%eax
8010a08a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a08d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a090:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a094:	0f b7 d0             	movzwl %ax,%edx
8010a097:	a1 28 f5 10 80       	mov    0x8010f528,%eax
8010a09c:	39 c2                	cmp    %eax,%edx
8010a09e:	74 60                	je     8010a100 <ipv4_proc+0x82>
8010a0a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0a3:	83 c0 0c             	add    $0xc,%eax
8010a0a6:	83 ec 04             	sub    $0x4,%esp
8010a0a9:	6a 04                	push   $0x4
8010a0ab:	50                   	push   %eax
8010a0ac:	68 24 f5 10 80       	push   $0x8010f524
8010a0b1:	e8 f1 b2 ff ff       	call   801053a7 <memcmp>
8010a0b6:	83 c4 10             	add    $0x10,%esp
8010a0b9:	85 c0                	test   %eax,%eax
8010a0bb:	74 43                	je     8010a100 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
8010a0bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0c0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a0c4:	0f b7 c0             	movzwl %ax,%eax
8010a0c7:	a3 28 f5 10 80       	mov    %eax,0x8010f528
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a0cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0cf:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a0d3:	3c 01                	cmp    $0x1,%al
8010a0d5:	75 10                	jne    8010a0e7 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
8010a0d7:	83 ec 0c             	sub    $0xc,%esp
8010a0da:	ff 75 08             	push   0x8(%ebp)
8010a0dd:	e8 a3 00 00 00       	call   8010a185 <icmp_proc>
8010a0e2:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a0e5:	eb 19                	jmp    8010a100 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a0e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0ea:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a0ee:	3c 06                	cmp    $0x6,%al
8010a0f0:	75 0e                	jne    8010a100 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010a0f2:	83 ec 0c             	sub    $0xc,%esp
8010a0f5:	ff 75 08             	push   0x8(%ebp)
8010a0f8:	e8 b3 03 00 00       	call   8010a4b0 <tcp_proc>
8010a0fd:	83 c4 10             	add    $0x10,%esp
}
8010a100:	90                   	nop
8010a101:	c9                   	leave  
8010a102:	c3                   	ret    

8010a103 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a103:	55                   	push   %ebp
8010a104:	89 e5                	mov    %esp,%ebp
8010a106:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a109:	8b 45 08             	mov    0x8(%ebp),%eax
8010a10c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a10f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a112:	0f b6 00             	movzbl (%eax),%eax
8010a115:	83 e0 0f             	and    $0xf,%eax
8010a118:	01 c0                	add    %eax,%eax
8010a11a:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a11d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a124:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a12b:	eb 48                	jmp    8010a175 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a12d:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a130:	01 c0                	add    %eax,%eax
8010a132:	89 c2                	mov    %eax,%edx
8010a134:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a137:	01 d0                	add    %edx,%eax
8010a139:	0f b6 00             	movzbl (%eax),%eax
8010a13c:	0f b6 c0             	movzbl %al,%eax
8010a13f:	c1 e0 08             	shl    $0x8,%eax
8010a142:	89 c2                	mov    %eax,%edx
8010a144:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a147:	01 c0                	add    %eax,%eax
8010a149:	8d 48 01             	lea    0x1(%eax),%ecx
8010a14c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a14f:	01 c8                	add    %ecx,%eax
8010a151:	0f b6 00             	movzbl (%eax),%eax
8010a154:	0f b6 c0             	movzbl %al,%eax
8010a157:	01 d0                	add    %edx,%eax
8010a159:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a15c:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a163:	76 0c                	jbe    8010a171 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a165:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a168:	0f b7 c0             	movzwl %ax,%eax
8010a16b:	83 c0 01             	add    $0x1,%eax
8010a16e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a171:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a175:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a179:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a17c:	7c af                	jl     8010a12d <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
8010a17e:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a181:	f7 d0                	not    %eax
}
8010a183:	c9                   	leave  
8010a184:	c3                   	ret    

8010a185 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a185:	55                   	push   %ebp
8010a186:	89 e5                	mov    %esp,%ebp
8010a188:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a18b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a18e:	83 c0 0e             	add    $0xe,%eax
8010a191:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a194:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a197:	0f b6 00             	movzbl (%eax),%eax
8010a19a:	0f b6 c0             	movzbl %al,%eax
8010a19d:	83 e0 0f             	and    $0xf,%eax
8010a1a0:	c1 e0 02             	shl    $0x2,%eax
8010a1a3:	89 c2                	mov    %eax,%edx
8010a1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1a8:	01 d0                	add    %edx,%eax
8010a1aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a1ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1b0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a1b4:	84 c0                	test   %al,%al
8010a1b6:	75 4f                	jne    8010a207 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a1b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1bb:	0f b6 00             	movzbl (%eax),%eax
8010a1be:	3c 08                	cmp    $0x8,%al
8010a1c0:	75 45                	jne    8010a207 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
8010a1c2:	e8 bd 8a ff ff       	call   80102c84 <kalloc>
8010a1c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a1ca:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a1d1:	83 ec 04             	sub    $0x4,%esp
8010a1d4:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a1d7:	50                   	push   %eax
8010a1d8:	ff 75 ec             	push   -0x14(%ebp)
8010a1db:	ff 75 08             	push   0x8(%ebp)
8010a1de:	e8 78 00 00 00       	call   8010a25b <icmp_reply_pkt_create>
8010a1e3:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a1e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1e9:	83 ec 08             	sub    $0x8,%esp
8010a1ec:	50                   	push   %eax
8010a1ed:	ff 75 ec             	push   -0x14(%ebp)
8010a1f0:	e8 95 f4 ff ff       	call   8010968a <i8254_send>
8010a1f5:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a1f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1fb:	83 ec 0c             	sub    $0xc,%esp
8010a1fe:	50                   	push   %eax
8010a1ff:	e8 e6 89 ff ff       	call   80102bea <kfree>
8010a204:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a207:	90                   	nop
8010a208:	c9                   	leave  
8010a209:	c3                   	ret    

8010a20a <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a20a:	55                   	push   %ebp
8010a20b:	89 e5                	mov    %esp,%ebp
8010a20d:	53                   	push   %ebx
8010a20e:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a211:	8b 45 08             	mov    0x8(%ebp),%eax
8010a214:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a218:	0f b7 c0             	movzwl %ax,%eax
8010a21b:	83 ec 0c             	sub    $0xc,%esp
8010a21e:	50                   	push   %eax
8010a21f:	e8 bd fd ff ff       	call   80109fe1 <N2H_ushort>
8010a224:	83 c4 10             	add    $0x10,%esp
8010a227:	0f b7 d8             	movzwl %ax,%ebx
8010a22a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a231:	0f b7 c0             	movzwl %ax,%eax
8010a234:	83 ec 0c             	sub    $0xc,%esp
8010a237:	50                   	push   %eax
8010a238:	e8 a4 fd ff ff       	call   80109fe1 <N2H_ushort>
8010a23d:	83 c4 10             	add    $0x10,%esp
8010a240:	0f b7 c0             	movzwl %ax,%eax
8010a243:	83 ec 04             	sub    $0x4,%esp
8010a246:	53                   	push   %ebx
8010a247:	50                   	push   %eax
8010a248:	68 63 cb 10 80       	push   $0x8010cb63
8010a24d:	e8 a2 61 ff ff       	call   801003f4 <cprintf>
8010a252:	83 c4 10             	add    $0x10,%esp
}
8010a255:	90                   	nop
8010a256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a259:	c9                   	leave  
8010a25a:	c3                   	ret    

8010a25b <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a25b:	55                   	push   %ebp
8010a25c:	89 e5                	mov    %esp,%ebp
8010a25e:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a261:	8b 45 08             	mov    0x8(%ebp),%eax
8010a264:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a267:	8b 45 08             	mov    0x8(%ebp),%eax
8010a26a:	83 c0 0e             	add    $0xe,%eax
8010a26d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a270:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a273:	0f b6 00             	movzbl (%eax),%eax
8010a276:	0f b6 c0             	movzbl %al,%eax
8010a279:	83 e0 0f             	and    $0xf,%eax
8010a27c:	c1 e0 02             	shl    $0x2,%eax
8010a27f:	89 c2                	mov    %eax,%edx
8010a281:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a284:	01 d0                	add    %edx,%eax
8010a286:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a289:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a28c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a28f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a292:	83 c0 0e             	add    $0xe,%eax
8010a295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a298:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a29b:	83 c0 14             	add    $0x14,%eax
8010a29e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a2a1:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2a4:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a2aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2ad:	8d 50 06             	lea    0x6(%eax),%edx
8010a2b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2b3:	83 ec 04             	sub    $0x4,%esp
8010a2b6:	6a 06                	push   $0x6
8010a2b8:	52                   	push   %edx
8010a2b9:	50                   	push   %eax
8010a2ba:	e8 40 b1 ff ff       	call   801053ff <memmove>
8010a2bf:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a2c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2c5:	83 c0 06             	add    $0x6,%eax
8010a2c8:	83 ec 04             	sub    $0x4,%esp
8010a2cb:	6a 06                	push   $0x6
8010a2cd:	68 10 aa 11 80       	push   $0x8011aa10
8010a2d2:	50                   	push   %eax
8010a2d3:	e8 27 b1 ff ff       	call   801053ff <memmove>
8010a2d8:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a2db:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2de:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a2e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2e5:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ec:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2f2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a2f6:	83 ec 0c             	sub    $0xc,%esp
8010a2f9:	6a 54                	push   $0x54
8010a2fb:	e8 03 fd ff ff       	call   8010a003 <H2N_ushort>
8010a300:	83 c4 10             	add    $0x10,%esp
8010a303:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a306:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a30a:	0f b7 15 e0 ac 11 80 	movzwl 0x8011ace0,%edx
8010a311:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a314:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a318:	0f b7 05 e0 ac 11 80 	movzwl 0x8011ace0,%eax
8010a31f:	83 c0 01             	add    $0x1,%eax
8010a322:	66 a3 e0 ac 11 80    	mov    %ax,0x8011ace0
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a328:	83 ec 0c             	sub    $0xc,%esp
8010a32b:	68 00 40 00 00       	push   $0x4000
8010a330:	e8 ce fc ff ff       	call   8010a003 <H2N_ushort>
8010a335:	83 c4 10             	add    $0x10,%esp
8010a338:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a33b:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a33f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a342:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a346:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a349:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a34d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a350:	83 c0 0c             	add    $0xc,%eax
8010a353:	83 ec 04             	sub    $0x4,%esp
8010a356:	6a 04                	push   $0x4
8010a358:	68 24 f5 10 80       	push   $0x8010f524
8010a35d:	50                   	push   %eax
8010a35e:	e8 9c b0 ff ff       	call   801053ff <memmove>
8010a363:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a366:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a369:	8d 50 0c             	lea    0xc(%eax),%edx
8010a36c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a36f:	83 c0 10             	add    $0x10,%eax
8010a372:	83 ec 04             	sub    $0x4,%esp
8010a375:	6a 04                	push   $0x4
8010a377:	52                   	push   %edx
8010a378:	50                   	push   %eax
8010a379:	e8 81 b0 ff ff       	call   801053ff <memmove>
8010a37e:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a381:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a384:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a38a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a38d:	83 ec 0c             	sub    $0xc,%esp
8010a390:	50                   	push   %eax
8010a391:	e8 6d fd ff ff       	call   8010a103 <ipv4_chksum>
8010a396:	83 c4 10             	add    $0x10,%esp
8010a399:	0f b7 c0             	movzwl %ax,%eax
8010a39c:	83 ec 0c             	sub    $0xc,%esp
8010a39f:	50                   	push   %eax
8010a3a0:	e8 5e fc ff ff       	call   8010a003 <H2N_ushort>
8010a3a5:	83 c4 10             	add    $0x10,%esp
8010a3a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a3ab:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a3af:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b2:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a3b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b8:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a3bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3bf:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a3c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3c6:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a3ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3cd:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a3d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3d4:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a3d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3db:	8d 50 08             	lea    0x8(%eax),%edx
8010a3de:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3e1:	83 c0 08             	add    $0x8,%eax
8010a3e4:	83 ec 04             	sub    $0x4,%esp
8010a3e7:	6a 08                	push   $0x8
8010a3e9:	52                   	push   %edx
8010a3ea:	50                   	push   %eax
8010a3eb:	e8 0f b0 ff ff       	call   801053ff <memmove>
8010a3f0:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a3f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3f6:	8d 50 10             	lea    0x10(%eax),%edx
8010a3f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3fc:	83 c0 10             	add    $0x10,%eax
8010a3ff:	83 ec 04             	sub    $0x4,%esp
8010a402:	6a 30                	push   $0x30
8010a404:	52                   	push   %edx
8010a405:	50                   	push   %eax
8010a406:	e8 f4 af ff ff       	call   801053ff <memmove>
8010a40b:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a40e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a411:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a417:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a41a:	83 ec 0c             	sub    $0xc,%esp
8010a41d:	50                   	push   %eax
8010a41e:	e8 1c 00 00 00       	call   8010a43f <icmp_chksum>
8010a423:	83 c4 10             	add    $0x10,%esp
8010a426:	0f b7 c0             	movzwl %ax,%eax
8010a429:	83 ec 0c             	sub    $0xc,%esp
8010a42c:	50                   	push   %eax
8010a42d:	e8 d1 fb ff ff       	call   8010a003 <H2N_ushort>
8010a432:	83 c4 10             	add    $0x10,%esp
8010a435:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a438:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a43c:	90                   	nop
8010a43d:	c9                   	leave  
8010a43e:	c3                   	ret    

8010a43f <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a43f:	55                   	push   %ebp
8010a440:	89 e5                	mov    %esp,%ebp
8010a442:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a445:	8b 45 08             	mov    0x8(%ebp),%eax
8010a448:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a44b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a452:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a459:	eb 48                	jmp    8010a4a3 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a45b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a45e:	01 c0                	add    %eax,%eax
8010a460:	89 c2                	mov    %eax,%edx
8010a462:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a465:	01 d0                	add    %edx,%eax
8010a467:	0f b6 00             	movzbl (%eax),%eax
8010a46a:	0f b6 c0             	movzbl %al,%eax
8010a46d:	c1 e0 08             	shl    $0x8,%eax
8010a470:	89 c2                	mov    %eax,%edx
8010a472:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a475:	01 c0                	add    %eax,%eax
8010a477:	8d 48 01             	lea    0x1(%eax),%ecx
8010a47a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a47d:	01 c8                	add    %ecx,%eax
8010a47f:	0f b6 00             	movzbl (%eax),%eax
8010a482:	0f b6 c0             	movzbl %al,%eax
8010a485:	01 d0                	add    %edx,%eax
8010a487:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a48a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a491:	76 0c                	jbe    8010a49f <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a493:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a496:	0f b7 c0             	movzwl %ax,%eax
8010a499:	83 c0 01             	add    $0x1,%eax
8010a49c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a49f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a4a3:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a4a7:	7e b2                	jle    8010a45b <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a4a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a4ac:	f7 d0                	not    %eax
}
8010a4ae:	c9                   	leave  
8010a4af:	c3                   	ret    

8010a4b0 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a4b0:	55                   	push   %ebp
8010a4b1:	89 e5                	mov    %esp,%ebp
8010a4b3:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a4b6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4b9:	83 c0 0e             	add    $0xe,%eax
8010a4bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a4bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4c2:	0f b6 00             	movzbl (%eax),%eax
8010a4c5:	0f b6 c0             	movzbl %al,%eax
8010a4c8:	83 e0 0f             	and    $0xf,%eax
8010a4cb:	c1 e0 02             	shl    $0x2,%eax
8010a4ce:	89 c2                	mov    %eax,%edx
8010a4d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4d3:	01 d0                	add    %edx,%eax
8010a4d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a4d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4db:	83 c0 14             	add    $0x14,%eax
8010a4de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a4e1:	e8 9e 87 ff ff       	call   80102c84 <kalloc>
8010a4e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a4e9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a4f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4f3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a4f7:	0f b6 c0             	movzbl %al,%eax
8010a4fa:	83 e0 02             	and    $0x2,%eax
8010a4fd:	85 c0                	test   %eax,%eax
8010a4ff:	74 3d                	je     8010a53e <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a501:	83 ec 0c             	sub    $0xc,%esp
8010a504:	6a 00                	push   $0x0
8010a506:	6a 12                	push   $0x12
8010a508:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a50b:	50                   	push   %eax
8010a50c:	ff 75 e8             	push   -0x18(%ebp)
8010a50f:	ff 75 08             	push   0x8(%ebp)
8010a512:	e8 a2 01 00 00       	call   8010a6b9 <tcp_pkt_create>
8010a517:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a51a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a51d:	83 ec 08             	sub    $0x8,%esp
8010a520:	50                   	push   %eax
8010a521:	ff 75 e8             	push   -0x18(%ebp)
8010a524:	e8 61 f1 ff ff       	call   8010968a <i8254_send>
8010a529:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a52c:	a1 e4 ac 11 80       	mov    0x8011ace4,%eax
8010a531:	83 c0 01             	add    $0x1,%eax
8010a534:	a3 e4 ac 11 80       	mov    %eax,0x8011ace4
8010a539:	e9 69 01 00 00       	jmp    8010a6a7 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a53e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a541:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a545:	3c 18                	cmp    $0x18,%al
8010a547:	0f 85 10 01 00 00    	jne    8010a65d <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a54d:	83 ec 04             	sub    $0x4,%esp
8010a550:	6a 03                	push   $0x3
8010a552:	68 7e cb 10 80       	push   $0x8010cb7e
8010a557:	ff 75 ec             	push   -0x14(%ebp)
8010a55a:	e8 48 ae ff ff       	call   801053a7 <memcmp>
8010a55f:	83 c4 10             	add    $0x10,%esp
8010a562:	85 c0                	test   %eax,%eax
8010a564:	74 74                	je     8010a5da <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a566:	83 ec 0c             	sub    $0xc,%esp
8010a569:	68 82 cb 10 80       	push   $0x8010cb82
8010a56e:	e8 81 5e ff ff       	call   801003f4 <cprintf>
8010a573:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a576:	83 ec 0c             	sub    $0xc,%esp
8010a579:	6a 00                	push   $0x0
8010a57b:	6a 10                	push   $0x10
8010a57d:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a580:	50                   	push   %eax
8010a581:	ff 75 e8             	push   -0x18(%ebp)
8010a584:	ff 75 08             	push   0x8(%ebp)
8010a587:	e8 2d 01 00 00       	call   8010a6b9 <tcp_pkt_create>
8010a58c:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a58f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a592:	83 ec 08             	sub    $0x8,%esp
8010a595:	50                   	push   %eax
8010a596:	ff 75 e8             	push   -0x18(%ebp)
8010a599:	e8 ec f0 ff ff       	call   8010968a <i8254_send>
8010a59e:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a5a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5a4:	83 c0 36             	add    $0x36,%eax
8010a5a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a5aa:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a5ad:	50                   	push   %eax
8010a5ae:	ff 75 e0             	push   -0x20(%ebp)
8010a5b1:	6a 00                	push   $0x0
8010a5b3:	6a 00                	push   $0x0
8010a5b5:	e8 5a 04 00 00       	call   8010aa14 <http_proc>
8010a5ba:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a5bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a5c0:	83 ec 0c             	sub    $0xc,%esp
8010a5c3:	50                   	push   %eax
8010a5c4:	6a 18                	push   $0x18
8010a5c6:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a5c9:	50                   	push   %eax
8010a5ca:	ff 75 e8             	push   -0x18(%ebp)
8010a5cd:	ff 75 08             	push   0x8(%ebp)
8010a5d0:	e8 e4 00 00 00       	call   8010a6b9 <tcp_pkt_create>
8010a5d5:	83 c4 20             	add    $0x20,%esp
8010a5d8:	eb 62                	jmp    8010a63c <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a5da:	83 ec 0c             	sub    $0xc,%esp
8010a5dd:	6a 00                	push   $0x0
8010a5df:	6a 10                	push   $0x10
8010a5e1:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a5e4:	50                   	push   %eax
8010a5e5:	ff 75 e8             	push   -0x18(%ebp)
8010a5e8:	ff 75 08             	push   0x8(%ebp)
8010a5eb:	e8 c9 00 00 00       	call   8010a6b9 <tcp_pkt_create>
8010a5f0:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a5f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a5f6:	83 ec 08             	sub    $0x8,%esp
8010a5f9:	50                   	push   %eax
8010a5fa:	ff 75 e8             	push   -0x18(%ebp)
8010a5fd:	e8 88 f0 ff ff       	call   8010968a <i8254_send>
8010a602:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a605:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a608:	83 c0 36             	add    $0x36,%eax
8010a60b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a60e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a611:	50                   	push   %eax
8010a612:	ff 75 e4             	push   -0x1c(%ebp)
8010a615:	6a 00                	push   $0x0
8010a617:	6a 00                	push   $0x0
8010a619:	e8 f6 03 00 00       	call   8010aa14 <http_proc>
8010a61e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a621:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a624:	83 ec 0c             	sub    $0xc,%esp
8010a627:	50                   	push   %eax
8010a628:	6a 18                	push   $0x18
8010a62a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a62d:	50                   	push   %eax
8010a62e:	ff 75 e8             	push   -0x18(%ebp)
8010a631:	ff 75 08             	push   0x8(%ebp)
8010a634:	e8 80 00 00 00       	call   8010a6b9 <tcp_pkt_create>
8010a639:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a63c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a63f:	83 ec 08             	sub    $0x8,%esp
8010a642:	50                   	push   %eax
8010a643:	ff 75 e8             	push   -0x18(%ebp)
8010a646:	e8 3f f0 ff ff       	call   8010968a <i8254_send>
8010a64b:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a64e:	a1 e4 ac 11 80       	mov    0x8011ace4,%eax
8010a653:	83 c0 01             	add    $0x1,%eax
8010a656:	a3 e4 ac 11 80       	mov    %eax,0x8011ace4
8010a65b:	eb 4a                	jmp    8010a6a7 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a65d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a660:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a664:	3c 10                	cmp    $0x10,%al
8010a666:	75 3f                	jne    8010a6a7 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a668:	a1 e8 ac 11 80       	mov    0x8011ace8,%eax
8010a66d:	83 f8 01             	cmp    $0x1,%eax
8010a670:	75 35                	jne    8010a6a7 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a672:	83 ec 0c             	sub    $0xc,%esp
8010a675:	6a 00                	push   $0x0
8010a677:	6a 01                	push   $0x1
8010a679:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a67c:	50                   	push   %eax
8010a67d:	ff 75 e8             	push   -0x18(%ebp)
8010a680:	ff 75 08             	push   0x8(%ebp)
8010a683:	e8 31 00 00 00       	call   8010a6b9 <tcp_pkt_create>
8010a688:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a68b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a68e:	83 ec 08             	sub    $0x8,%esp
8010a691:	50                   	push   %eax
8010a692:	ff 75 e8             	push   -0x18(%ebp)
8010a695:	e8 f0 ef ff ff       	call   8010968a <i8254_send>
8010a69a:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a69d:	c7 05 e8 ac 11 80 00 	movl   $0x0,0x8011ace8
8010a6a4:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a6a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6aa:	83 ec 0c             	sub    $0xc,%esp
8010a6ad:	50                   	push   %eax
8010a6ae:	e8 37 85 ff ff       	call   80102bea <kfree>
8010a6b3:	83 c4 10             	add    $0x10,%esp
}
8010a6b6:	90                   	nop
8010a6b7:	c9                   	leave  
8010a6b8:	c3                   	ret    

8010a6b9 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a6b9:	55                   	push   %ebp
8010a6ba:	89 e5                	mov    %esp,%ebp
8010a6bc:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a6bf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a6c5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6c8:	83 c0 0e             	add    $0xe,%eax
8010a6cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a6ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6d1:	0f b6 00             	movzbl (%eax),%eax
8010a6d4:	0f b6 c0             	movzbl %al,%eax
8010a6d7:	83 e0 0f             	and    $0xf,%eax
8010a6da:	c1 e0 02             	shl    $0x2,%eax
8010a6dd:	89 c2                	mov    %eax,%edx
8010a6df:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6e2:	01 d0                	add    %edx,%eax
8010a6e4:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a6e7:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a6ed:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6f0:	83 c0 0e             	add    $0xe,%eax
8010a6f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a6f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6f9:	83 c0 14             	add    $0x14,%eax
8010a6fc:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a6ff:	8b 45 18             	mov    0x18(%ebp),%eax
8010a702:	8d 50 36             	lea    0x36(%eax),%edx
8010a705:	8b 45 10             	mov    0x10(%ebp),%eax
8010a708:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a70a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a70d:	8d 50 06             	lea    0x6(%eax),%edx
8010a710:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a713:	83 ec 04             	sub    $0x4,%esp
8010a716:	6a 06                	push   $0x6
8010a718:	52                   	push   %edx
8010a719:	50                   	push   %eax
8010a71a:	e8 e0 ac ff ff       	call   801053ff <memmove>
8010a71f:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a722:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a725:	83 c0 06             	add    $0x6,%eax
8010a728:	83 ec 04             	sub    $0x4,%esp
8010a72b:	6a 06                	push   $0x6
8010a72d:	68 10 aa 11 80       	push   $0x8011aa10
8010a732:	50                   	push   %eax
8010a733:	e8 c7 ac ff ff       	call   801053ff <memmove>
8010a738:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a73b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a73e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a742:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a745:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a749:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a74c:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a74f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a752:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a756:	8b 45 18             	mov    0x18(%ebp),%eax
8010a759:	83 c0 28             	add    $0x28,%eax
8010a75c:	0f b7 c0             	movzwl %ax,%eax
8010a75f:	83 ec 0c             	sub    $0xc,%esp
8010a762:	50                   	push   %eax
8010a763:	e8 9b f8 ff ff       	call   8010a003 <H2N_ushort>
8010a768:	83 c4 10             	add    $0x10,%esp
8010a76b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a76e:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a772:	0f b7 15 e0 ac 11 80 	movzwl 0x8011ace0,%edx
8010a779:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a77c:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a780:	0f b7 05 e0 ac 11 80 	movzwl 0x8011ace0,%eax
8010a787:	83 c0 01             	add    $0x1,%eax
8010a78a:	66 a3 e0 ac 11 80    	mov    %ax,0x8011ace0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a790:	83 ec 0c             	sub    $0xc,%esp
8010a793:	6a 00                	push   $0x0
8010a795:	e8 69 f8 ff ff       	call   8010a003 <H2N_ushort>
8010a79a:	83 c4 10             	add    $0x10,%esp
8010a79d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a7a0:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a7a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7a7:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a7ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7ae:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a7b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7b5:	83 c0 0c             	add    $0xc,%eax
8010a7b8:	83 ec 04             	sub    $0x4,%esp
8010a7bb:	6a 04                	push   $0x4
8010a7bd:	68 24 f5 10 80       	push   $0x8010f524
8010a7c2:	50                   	push   %eax
8010a7c3:	e8 37 ac ff ff       	call   801053ff <memmove>
8010a7c8:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a7cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7ce:	8d 50 0c             	lea    0xc(%eax),%edx
8010a7d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7d4:	83 c0 10             	add    $0x10,%eax
8010a7d7:	83 ec 04             	sub    $0x4,%esp
8010a7da:	6a 04                	push   $0x4
8010a7dc:	52                   	push   %edx
8010a7dd:	50                   	push   %eax
8010a7de:	e8 1c ac ff ff       	call   801053ff <memmove>
8010a7e3:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a7e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7e9:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a7ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7f2:	83 ec 0c             	sub    $0xc,%esp
8010a7f5:	50                   	push   %eax
8010a7f6:	e8 08 f9 ff ff       	call   8010a103 <ipv4_chksum>
8010a7fb:	83 c4 10             	add    $0x10,%esp
8010a7fe:	0f b7 c0             	movzwl %ax,%eax
8010a801:	83 ec 0c             	sub    $0xc,%esp
8010a804:	50                   	push   %eax
8010a805:	e8 f9 f7 ff ff       	call   8010a003 <H2N_ushort>
8010a80a:	83 c4 10             	add    $0x10,%esp
8010a80d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a810:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a814:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a817:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a81b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a81e:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a821:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a824:	0f b7 10             	movzwl (%eax),%edx
8010a827:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a82a:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a82e:	a1 e4 ac 11 80       	mov    0x8011ace4,%eax
8010a833:	83 ec 0c             	sub    $0xc,%esp
8010a836:	50                   	push   %eax
8010a837:	e8 e9 f7 ff ff       	call   8010a025 <H2N_uint>
8010a83c:	83 c4 10             	add    $0x10,%esp
8010a83f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a842:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a845:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a848:	8b 40 04             	mov    0x4(%eax),%eax
8010a84b:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a851:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a854:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a857:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a85a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a85e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a861:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a865:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a868:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a86c:	8b 45 14             	mov    0x14(%ebp),%eax
8010a86f:	89 c2                	mov    %eax,%edx
8010a871:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a874:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a877:	83 ec 0c             	sub    $0xc,%esp
8010a87a:	68 90 38 00 00       	push   $0x3890
8010a87f:	e8 7f f7 ff ff       	call   8010a003 <H2N_ushort>
8010a884:	83 c4 10             	add    $0x10,%esp
8010a887:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a88a:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a88e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a891:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a897:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a89a:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a8a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a8a3:	83 ec 0c             	sub    $0xc,%esp
8010a8a6:	50                   	push   %eax
8010a8a7:	e8 1f 00 00 00       	call   8010a8cb <tcp_chksum>
8010a8ac:	83 c4 10             	add    $0x10,%esp
8010a8af:	83 c0 08             	add    $0x8,%eax
8010a8b2:	0f b7 c0             	movzwl %ax,%eax
8010a8b5:	83 ec 0c             	sub    $0xc,%esp
8010a8b8:	50                   	push   %eax
8010a8b9:	e8 45 f7 ff ff       	call   8010a003 <H2N_ushort>
8010a8be:	83 c4 10             	add    $0x10,%esp
8010a8c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a8c4:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a8c8:	90                   	nop
8010a8c9:	c9                   	leave  
8010a8ca:	c3                   	ret    

8010a8cb <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a8cb:	55                   	push   %ebp
8010a8cc:	89 e5                	mov    %esp,%ebp
8010a8ce:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a8d1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a8d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8da:	83 c0 14             	add    $0x14,%eax
8010a8dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a8e0:	83 ec 04             	sub    $0x4,%esp
8010a8e3:	6a 04                	push   $0x4
8010a8e5:	68 24 f5 10 80       	push   $0x8010f524
8010a8ea:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a8ed:	50                   	push   %eax
8010a8ee:	e8 0c ab ff ff       	call   801053ff <memmove>
8010a8f3:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a8f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8f9:	83 c0 0c             	add    $0xc,%eax
8010a8fc:	83 ec 04             	sub    $0x4,%esp
8010a8ff:	6a 04                	push   $0x4
8010a901:	50                   	push   %eax
8010a902:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a905:	83 c0 04             	add    $0x4,%eax
8010a908:	50                   	push   %eax
8010a909:	e8 f1 aa ff ff       	call   801053ff <memmove>
8010a90e:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a911:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a915:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a919:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a91c:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a920:	0f b7 c0             	movzwl %ax,%eax
8010a923:	83 ec 0c             	sub    $0xc,%esp
8010a926:	50                   	push   %eax
8010a927:	e8 b5 f6 ff ff       	call   80109fe1 <N2H_ushort>
8010a92c:	83 c4 10             	add    $0x10,%esp
8010a92f:	83 e8 14             	sub    $0x14,%eax
8010a932:	0f b7 c0             	movzwl %ax,%eax
8010a935:	83 ec 0c             	sub    $0xc,%esp
8010a938:	50                   	push   %eax
8010a939:	e8 c5 f6 ff ff       	call   8010a003 <H2N_ushort>
8010a93e:	83 c4 10             	add    $0x10,%esp
8010a941:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a945:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a94c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a94f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a952:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a959:	eb 33                	jmp    8010a98e <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a95b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a95e:	01 c0                	add    %eax,%eax
8010a960:	89 c2                	mov    %eax,%edx
8010a962:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a965:	01 d0                	add    %edx,%eax
8010a967:	0f b6 00             	movzbl (%eax),%eax
8010a96a:	0f b6 c0             	movzbl %al,%eax
8010a96d:	c1 e0 08             	shl    $0x8,%eax
8010a970:	89 c2                	mov    %eax,%edx
8010a972:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a975:	01 c0                	add    %eax,%eax
8010a977:	8d 48 01             	lea    0x1(%eax),%ecx
8010a97a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a97d:	01 c8                	add    %ecx,%eax
8010a97f:	0f b6 00             	movzbl (%eax),%eax
8010a982:	0f b6 c0             	movzbl %al,%eax
8010a985:	01 d0                	add    %edx,%eax
8010a987:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a98a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a98e:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a992:	7e c7                	jle    8010a95b <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a994:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a997:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a99a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a9a1:	eb 33                	jmp    8010a9d6 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a9a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a9a6:	01 c0                	add    %eax,%eax
8010a9a8:	89 c2                	mov    %eax,%edx
8010a9aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a9ad:	01 d0                	add    %edx,%eax
8010a9af:	0f b6 00             	movzbl (%eax),%eax
8010a9b2:	0f b6 c0             	movzbl %al,%eax
8010a9b5:	c1 e0 08             	shl    $0x8,%eax
8010a9b8:	89 c2                	mov    %eax,%edx
8010a9ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a9bd:	01 c0                	add    %eax,%eax
8010a9bf:	8d 48 01             	lea    0x1(%eax),%ecx
8010a9c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a9c5:	01 c8                	add    %ecx,%eax
8010a9c7:	0f b6 00             	movzbl (%eax),%eax
8010a9ca:	0f b6 c0             	movzbl %al,%eax
8010a9cd:	01 d0                	add    %edx,%eax
8010a9cf:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a9d2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a9d6:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a9da:	0f b7 c0             	movzwl %ax,%eax
8010a9dd:	83 ec 0c             	sub    $0xc,%esp
8010a9e0:	50                   	push   %eax
8010a9e1:	e8 fb f5 ff ff       	call   80109fe1 <N2H_ushort>
8010a9e6:	83 c4 10             	add    $0x10,%esp
8010a9e9:	66 d1 e8             	shr    %ax
8010a9ec:	0f b7 c0             	movzwl %ax,%eax
8010a9ef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a9f2:	7c af                	jl     8010a9a3 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a9f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a9f7:	c1 e8 10             	shr    $0x10,%eax
8010a9fa:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a9fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010aa00:	f7 d0                	not    %eax
}
8010aa02:	c9                   	leave  
8010aa03:	c3                   	ret    

8010aa04 <tcp_fin>:

void tcp_fin(){
8010aa04:	55                   	push   %ebp
8010aa05:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010aa07:	c7 05 e8 ac 11 80 01 	movl   $0x1,0x8011ace8
8010aa0e:	00 00 00 
}
8010aa11:	90                   	nop
8010aa12:	5d                   	pop    %ebp
8010aa13:	c3                   	ret    

8010aa14 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010aa14:	55                   	push   %ebp
8010aa15:	89 e5                	mov    %esp,%ebp
8010aa17:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010aa1a:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa1d:	83 ec 04             	sub    $0x4,%esp
8010aa20:	6a 00                	push   $0x0
8010aa22:	68 8b cb 10 80       	push   $0x8010cb8b
8010aa27:	50                   	push   %eax
8010aa28:	e8 65 00 00 00       	call   8010aa92 <http_strcpy>
8010aa2d:	83 c4 10             	add    $0x10,%esp
8010aa30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010aa33:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa36:	83 ec 04             	sub    $0x4,%esp
8010aa39:	ff 75 f4             	push   -0xc(%ebp)
8010aa3c:	68 9e cb 10 80       	push   $0x8010cb9e
8010aa41:	50                   	push   %eax
8010aa42:	e8 4b 00 00 00       	call   8010aa92 <http_strcpy>
8010aa47:	83 c4 10             	add    $0x10,%esp
8010aa4a:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010aa4d:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa50:	83 ec 04             	sub    $0x4,%esp
8010aa53:	ff 75 f4             	push   -0xc(%ebp)
8010aa56:	68 b9 cb 10 80       	push   $0x8010cbb9
8010aa5b:	50                   	push   %eax
8010aa5c:	e8 31 00 00 00       	call   8010aa92 <http_strcpy>
8010aa61:	83 c4 10             	add    $0x10,%esp
8010aa64:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010aa67:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010aa6a:	83 e0 01             	and    $0x1,%eax
8010aa6d:	85 c0                	test   %eax,%eax
8010aa6f:	74 11                	je     8010aa82 <http_proc+0x6e>
    char *payload = (char *)send;
8010aa71:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa74:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010aa77:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa7d:	01 d0                	add    %edx,%eax
8010aa7f:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010aa82:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa85:	8b 45 14             	mov    0x14(%ebp),%eax
8010aa88:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010aa8a:	e8 75 ff ff ff       	call   8010aa04 <tcp_fin>
}
8010aa8f:	90                   	nop
8010aa90:	c9                   	leave  
8010aa91:	c3                   	ret    

8010aa92 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010aa92:	55                   	push   %ebp
8010aa93:	89 e5                	mov    %esp,%ebp
8010aa95:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010aa98:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010aa9f:	eb 20                	jmp    8010aac1 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010aaa1:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aaa4:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aaa7:	01 d0                	add    %edx,%eax
8010aaa9:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010aaac:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aaaf:	01 ca                	add    %ecx,%edx
8010aab1:	89 d1                	mov    %edx,%ecx
8010aab3:	8b 55 08             	mov    0x8(%ebp),%edx
8010aab6:	01 ca                	add    %ecx,%edx
8010aab8:	0f b6 00             	movzbl (%eax),%eax
8010aabb:	88 02                	mov    %al,(%edx)
    i++;
8010aabd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010aac1:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aac4:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aac7:	01 d0                	add    %edx,%eax
8010aac9:	0f b6 00             	movzbl (%eax),%eax
8010aacc:	84 c0                	test   %al,%al
8010aace:	75 d1                	jne    8010aaa1 <http_strcpy+0xf>
  }
  return i;
8010aad0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010aad3:	c9                   	leave  
8010aad4:	c3                   	ret    
