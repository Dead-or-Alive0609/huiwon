
kernelmemfs:     file format elf32-i386


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
8010005a:	bc c0 8c 19 80       	mov    $0x80198cc0,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 65 33 10 80       	mov    $0x80103365,%edx
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
8010006f:	68 e0 a6 10 80       	push   $0x8010a6e0
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 6c 4b 00 00       	call   80104bea <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 e7 a6 10 80       	push   $0x8010a6e7
801000c2:	50                   	push   %eax
801000c3:	e8 c5 49 00 00       	call   80104a8d <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
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
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 06 4b 00 00       	call   80104c0c <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
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
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 35 4b 00 00       	call   80104c7a <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 72 49 00 00       	call   80104ac9 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
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
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 b4 4a 00 00       	call   80104c7a <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 f1 48 00 00       	call   80104ac9 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 ee a6 10 80       	push   $0x8010a6ee
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
8010022d:	e8 ac a3 00 00       	call   8010a5de <iderw>
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
8010024a:	e8 2c 49 00 00       	call   80104b7b <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 ff a6 10 80       	push   $0x8010a6ff
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
80100278:	e8 61 a3 00 00       	call   8010a5de <iderw>
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
80100293:	e8 e3 48 00 00       	call   80104b7b <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 06 a7 10 80       	push   $0x8010a706
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 72 48 00 00       	call   80104b2d <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 41 49 00 00       	call   80104c0c <acquire>
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
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 3f 49 00 00       	call   80104c7a <release>
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
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 f7 47 00 00       	call   80104c0c <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 0d a7 10 80       	push   $0x8010a70d
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
80100510:	c7 45 ec 16 a7 10 80 	movl   $0x8010a716,-0x14(%ebp)
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
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 d7 46 00 00       	call   80104c7a <release>
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
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 37 25 00 00       	call   80102afa <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 1d a7 10 80       	push   $0x8010a71d
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
801005e6:	68 31 a7 10 80       	push   $0x8010a731
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 c9 46 00 00       	call   80104ccc <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 33 a7 10 80       	push   $0x8010a733
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
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
801006a0:	e8 90 7e 00 00       	call   80108535 <graphic_scroll_up>
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
801006f3:	e8 3d 7e 00 00       	call   80108535 <graphic_scroll_up>
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
80100757:	e8 44 7e 00 00       	call   801085a0 <font_render>
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
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
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
80100793:	e8 14 62 00 00       	call   801069ac <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 07 62 00 00       	call   801069ac <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 fa 61 00 00       	call   801069ac <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 ea 61 00 00       	call   801069ac <uartputc>
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
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 1c 44 00 00       	call   80104c0c <acquire>
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
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
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
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
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
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
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
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 2f 3d 00 00       	call   80104673 <wakeup>
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
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 13 43 00 00       	call   80104c7a <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 ca 3e 00 00       	call   8010483f <procdump>
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
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 6d 42 00 00       	call   80104c0c <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 b2 30 00 00       	call   80103a5e <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 ba 42 00 00       	call   80104c7a <release>
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
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 9c 3b 00 00       	call   80104589 <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
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
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
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
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 0f 42 00 00       	call   80104c7a <release>
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
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 65 41 00 00       	call   80104c0c <acquire>
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
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 91 41 00 00       	call   80104c7a <release>
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
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 37 a7 10 80       	push   $0x8010a737
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 c9 40 00 00       	call   80104bea <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 3f a7 10 80 	movl   $0x8010a73f,-0xc(%ebp)
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
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 b4 1a 00 00       	call   8010262e <ioapicenable>
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
80100b89:	e8 d0 2e 00 00       	call   80103a5e <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a6 24 00 00       	call   8010303c <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 16 25 00 00       	call   801030c8 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 55 a7 10 80       	push   $0x8010a755
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
80100c11:	e8 92 6d 00 00       	call   801079a8 <setupkvm>
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
80100cb7:	e8 e5 70 00 00       	call   80107da1 <allocuvm>
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
80100cfd:	e8 d2 6f 00 00       	call   80107cd4 <loaduvm>
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
80100d3e:	e8 85 23 00 00       	call   801030c8 <end_op>
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
80100d6c:	e8 30 70 00 00       	call   80107da1 <allocuvm>
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
80100d90:	e8 6e 72 00 00       	call   80108003 <clearpteu>
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
80100dc9:	e8 02 43 00 00       	call   801050d0 <strlen>
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
80100df6:	e8 d5 42 00 00       	call   801050d0 <strlen>
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
80100e1c:	e8 81 73 00 00       	call   801081a2 <copyout>
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
80100eb8:	e8 e5 72 00 00       	call   801081a2 <copyout>
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
80100f06:	e8 7a 41 00 00       	call   80105085 <safestrcpy>
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
80100f49:	e8 77 6b 00 00       	call   80107ac5 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 0e 70 00 00       	call   80107f6a <freevm>
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
80100f97:	e8 ce 6f 00 00       	call   80107f6a <freevm>
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
80100fb3:	e8 10 21 00 00       	call   801030c8 <end_op>
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
80100fc8:	68 61 a7 10 80       	push   $0x8010a761
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 13 3c 00 00       	call   80104bea <initlock>
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
80100fe6:	68 a0 1a 19 80       	push   $0x80191aa0
80100feb:	e8 1c 3c 00 00       	call   80104c0c <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
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
80101013:	68 a0 1a 19 80       	push   $0x80191aa0
80101018:	e8 5d 3c 00 00       	call   80104c7a <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 1a 19 80       	push   $0x80191aa0
8010103b:	e8 3a 3c 00 00       	call   80104c7a <release>
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
80101053:	68 a0 1a 19 80       	push   $0x80191aa0
80101058:	e8 af 3b 00 00       	call   80104c0c <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 68 a7 10 80       	push   $0x8010a768
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 1a 19 80       	push   $0x80191aa0
8010108e:	e8 e7 3b 00 00       	call   80104c7a <release>
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
801010a4:	68 a0 1a 19 80       	push   $0x80191aa0
801010a9:	e8 5e 3b 00 00       	call   80104c0c <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 70 a7 10 80       	push   $0x8010a770
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
801010e4:	68 a0 1a 19 80       	push   $0x80191aa0
801010e9:	e8 8c 3b 00 00       	call   80104c7a <release>
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
80101132:	68 a0 1a 19 80       	push   $0x80191aa0
80101137:	e8 3e 3b 00 00       	call   80104c7a <release>
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
80101156:	e8 64 25 00 00       	call   801036bf <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 cf 1e 00 00       	call   8010303c <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 47 1f 00 00       	call   801030c8 <end_op>
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
8010120f:	e8 58 26 00 00       	call   8010386c <piperead>
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
80101286:	68 7a a7 10 80       	push   $0x8010a77a
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
801012c8:	e8 9d 24 00 00       	call   8010376a <pipewrite>
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
8010130d:	e8 2a 1d 00 00       	call   8010303c <begin_op>
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
80101373:	e8 50 1d 00 00       	call   801030c8 <end_op>

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
80101389:	68 83 a7 10 80       	push   $0x8010a783
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
801013bf:	68 93 a7 10 80       	push   $0x8010a793
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
801013f7:	e8 45 3b 00 00       	call   80104f41 <memmove>
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
8010143d:	e8 40 3a 00 00       	call   80104e82 <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 25 1e 00 00       	call   80103275 <log_write>
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
80101490:	a1 58 24 19 80       	mov    0x80192458,%eax
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
80101517:	e8 59 1d 00 00       	call   80103275 <log_write>
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
80101566:	a1 40 24 19 80       	mov    0x80192440,%eax
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
80101588:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 a0 a7 10 80       	push   $0x8010a7a0
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
801015b1:	68 40 24 19 80       	push   $0x80192440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 24 19 80       	mov    0x80192458,%eax
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
80101627:	68 b6 a7 10 80       	push   $0x8010a7b6
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
8010165f:	e8 11 1c 00 00       	call   80103275 <log_write>
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
8010168b:	68 c9 a7 10 80       	push   $0x8010a7c9
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 50 35 00 00       	call   80104bea <initlock>
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
801016b6:	05 60 24 19 80       	add    $0x80192460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 d0 a7 10 80       	push   $0x8010a7d0
801016c6:	50                   	push   %eax
801016c7:	e8 c1 33 00 00       	call   80104a8d <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 24 19 80       	push   $0x80192440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fa:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101700:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101706:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170c:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101712:	a1 40 24 19 80       	mov    0x80192440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 d8 a7 10 80       	push   $0x8010a7d8
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
80101757:	a1 54 24 19 80       	mov    0x80192454,%eax
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
80101799:	e8 e4 36 00 00       	call   80104e82 <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 bf 1a 00 00       	call   80103275 <log_write>
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
801017ed:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 2b a8 10 80       	push   $0x8010a82b
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
8010181e:	a1 54 24 19 80       	mov    0x80192454,%eax
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
801018a7:	e8 95 36 00 00       	call   80104f41 <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 bb 19 00 00       	call   80103275 <log_write>
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
801018d7:	68 60 24 19 80       	push   $0x80192460
801018dc:	e8 2b 33 00 00       	call   80104c0c <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
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
80101925:	68 60 24 19 80       	push   $0x80192460
8010192a:	e8 4b 33 00 00       	call   80104c7a <release>
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
80101954:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 3d a8 10 80       	push   $0x8010a83d
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
8010199e:	68 60 24 19 80       	push   $0x80192460
801019a3:	e8 d2 32 00 00       	call   80104c7a <release>
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
801019b9:	68 60 24 19 80       	push   $0x80192460
801019be:	e8 49 32 00 00       	call   80104c0c <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 24 19 80       	push   $0x80192460
801019dd:	e8 98 32 00 00       	call   80104c7a <release>
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
80101a03:	68 4d a8 10 80       	push   $0x8010a84d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 ad 30 00 00       	call   80104ac9 <acquiresleep>
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
80101a38:	a1 54 24 19 80       	mov    0x80192454,%eax
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
80101ac1:	e8 7b 34 00 00       	call   80104f41 <memmove>
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
80101af0:	68 53 a8 10 80       	push   $0x8010a853
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
80101b13:	e8 63 30 00 00       	call   80104b7b <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 62 a8 10 80       	push   $0x8010a862
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 e8 2f 00 00       	call   80104b2d <releasesleep>
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
80101b5b:	e8 69 2f 00 00       	call   80104ac9 <acquiresleep>
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
80101b7c:	68 60 24 19 80       	push   $0x80192460
80101b81:	e8 86 30 00 00       	call   80104c0c <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 db 30 00 00       	call   80104c7a <release>
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
80101be1:	e8 47 2f 00 00       	call   80104b2d <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 16 30 00 00       	call   80104c0c <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 24 19 80       	push   $0x80192460
80101c10:	e8 65 30 00 00       	call   80104c7a <release>
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
80101d36:	e8 3a 15 00 00       	call   80103275 <log_write>
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
80101d54:	68 6a a8 10 80       	push   $0x8010a86a
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
80101f0a:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
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
80101ff2:	e8 4a 2f 00 00       	call   80104f41 <memmove>
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
8010205f:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
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
80102142:	e8 fa 2d 00 00       	call   80104f41 <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 20 11 00 00       	call   80103275 <log_write>
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
801021c2:	e8 10 2e 00 00       	call   80104fd7 <strncmp>
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
801021e2:	68 7d a8 10 80       	push   $0x8010a87d
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
80102211:	68 8f a8 10 80       	push   $0x8010a88f
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
801022e6:	68 9e a8 10 80       	push   $0x8010a89e
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
80102321:	e8 07 2d 00 00       	call   8010502d <strncpy>
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
8010234d:	68 ab a8 10 80       	push   $0x8010a8ab
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
801023bf:	e8 7d 2b 00 00       	call   80104f41 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 66 2b 00 00       	call   80104f41 <memmove>
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
80102425:	e8 34 16 00 00       	call   80103a5e <myproc>
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

80102554 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102557:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255c:	8b 55 08             	mov    0x8(%ebp),%edx
8010255f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102561:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102566:	8b 40 10             	mov    0x10(%eax),%eax
}
80102569:	5d                   	pop    %ebp
8010256a:	c3                   	ret    

8010256b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102573:	8b 55 08             	mov    0x8(%ebp),%edx
80102576:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102578:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102580:	89 50 10             	mov    %edx,0x10(%eax)
}
80102583:	90                   	nop
80102584:	5d                   	pop    %ebp
80102585:	c3                   	ret    

80102586 <ioapicinit>:

void
ioapicinit(void)
{
80102586:	55                   	push   %ebp
80102587:	89 e5                	mov    %esp,%ebp
80102589:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258c:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102593:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102596:	6a 01                	push   $0x1
80102598:	e8 b7 ff ff ff       	call   80102554 <ioapicread>
8010259d:	83 c4 04             	add    $0x4,%esp
801025a0:	c1 e8 10             	shr    $0x10,%eax
801025a3:	25 ff 00 00 00       	and    $0xff,%eax
801025a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ab:	6a 00                	push   $0x0
801025ad:	e8 a2 ff ff ff       	call   80102554 <ioapicread>
801025b2:	83 c4 04             	add    $0x4,%esp
801025b5:	c1 e8 18             	shr    $0x18,%eax
801025b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bb:	0f b6 05 94 79 19 80 	movzbl 0x80197994,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 b4 a8 10 80       	push   $0x8010a8b4
801025d2:	e8 1d de ff ff       	call   801003f4 <cprintf>
801025d7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e1:	eb 3f                	jmp    80102622 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e6:	83 c0 20             	add    $0x20,%eax
801025e9:	0d 00 00 01 00       	or     $0x10000,%eax
801025ee:	89 c2                	mov    %eax,%edx
801025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f3:	83 c0 08             	add    $0x8,%eax
801025f6:	01 c0                	add    %eax,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	52                   	push   %edx
801025fc:	50                   	push   %eax
801025fd:	e8 69 ff ff ff       	call   8010256b <ioapicwrite>
80102602:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102608:	83 c0 08             	add    $0x8,%eax
8010260b:	01 c0                	add    %eax,%eax
8010260d:	83 c0 01             	add    $0x1,%eax
80102610:	83 ec 08             	sub    $0x8,%esp
80102613:	6a 00                	push   $0x0
80102615:	50                   	push   %eax
80102616:	e8 50 ff ff ff       	call   8010256b <ioapicwrite>
8010261b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102625:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102628:	7e b9                	jle    801025e3 <ioapicinit+0x5d>
  }
}
8010262a:	90                   	nop
8010262b:	90                   	nop
8010262c:	c9                   	leave  
8010262d:	c3                   	ret    

8010262e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102631:	8b 45 08             	mov    0x8(%ebp),%eax
80102634:	83 c0 20             	add    $0x20,%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 08             	add    $0x8,%eax
8010263f:	01 c0                	add    %eax,%eax
80102641:	52                   	push   %edx
80102642:	50                   	push   %eax
80102643:	e8 23 ff ff ff       	call   8010256b <ioapicwrite>
80102648:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264e:	c1 e0 18             	shl    $0x18,%eax
80102651:	89 c2                	mov    %eax,%edx
80102653:	8b 45 08             	mov    0x8(%ebp),%eax
80102656:	83 c0 08             	add    $0x8,%eax
80102659:	01 c0                	add    %eax,%eax
8010265b:	83 c0 01             	add    $0x1,%eax
8010265e:	52                   	push   %edx
8010265f:	50                   	push   %eax
80102660:	e8 06 ff ff ff       	call   8010256b <ioapicwrite>
80102665:	83 c4 08             	add    $0x8,%esp
}
80102668:	90                   	nop
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102671:	83 ec 08             	sub    $0x8,%esp
80102674:	68 e6 a8 10 80       	push   $0x8010a8e6
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 67 25 00 00       	call   80104bea <initlock>
80102683:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102686:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268d:	00 00 00 
  freerange(vstart, vend);
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	ff 75 0c             	push   0xc(%ebp)
80102696:	ff 75 08             	push   0x8(%ebp)
80102699:	e8 2a 00 00 00       	call   801026c8 <freerange>
8010269e:	83 c4 10             	add    $0x10,%esp
}
801026a1:	90                   	nop
801026a2:	c9                   	leave  
801026a3:	c3                   	ret    

801026a4 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a4:	55                   	push   %ebp
801026a5:	89 e5                	mov    %esp,%ebp
801026a7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	ff 75 0c             	push   0xc(%ebp)
801026b0:	ff 75 08             	push   0x8(%ebp)
801026b3:	e8 10 00 00 00       	call   801026c8 <freerange>
801026b8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bb:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c2:	00 00 00 
}
801026c5:	90                   	nop
801026c6:	c9                   	leave  
801026c7:	c3                   	ret    

801026c8 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026ce:	8b 45 08             	mov    0x8(%ebp),%eax
801026d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026de:	eb 15                	jmp    801026f5 <freerange+0x2d>
    kfree(p);
801026e0:	83 ec 0c             	sub    $0xc,%esp
801026e3:	ff 75 f4             	push   -0xc(%ebp)
801026e6:	e8 1b 00 00 00       	call   80102706 <kfree>
801026eb:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f8:	05 00 10 00 00       	add    $0x1000,%eax
801026fd:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102700:	73 de                	jae    801026e0 <freerange+0x18>
}
80102702:	90                   	nop
80102703:	90                   	nop
80102704:	c9                   	leave  
80102705:	c3                   	ret    

80102706 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102706:	55                   	push   %ebp
80102707:	89 e5                	mov    %esp,%ebp
80102709:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102714:	85 c0                	test   %eax,%eax
80102716:	75 18                	jne    80102730 <kfree+0x2a>
80102718:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010271f:	72 0f                	jb     80102730 <kfree+0x2a>
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	05 00 00 00 80       	add    $0x80000000,%eax
80102729:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272e:	76 0d                	jbe    8010273d <kfree+0x37>
    panic("kfree");
80102730:	83 ec 0c             	sub    $0xc,%esp
80102733:	68 eb a8 10 80       	push   $0x8010a8eb
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 33 27 00 00       	call   80104e82 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 a4 24 00 00       	call   80104c0c <acquire>
80102768:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276b:	8b 45 08             	mov    0x8(%ebp),%eax
8010276e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102771:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277f:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102784:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102789:	85 c0                	test   %eax,%eax
8010278b:	74 10                	je     8010279d <kfree+0x97>
    release(&kmem.lock);
8010278d:	83 ec 0c             	sub    $0xc,%esp
80102790:	68 c0 40 19 80       	push   $0x801940c0
80102795:	e8 e0 24 00 00       	call   80104c7a <release>
8010279a:	83 c4 10             	add    $0x10,%esp
}
8010279d:	90                   	nop
8010279e:	c9                   	leave  
8010279f:	c3                   	ret    

801027a0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a0:	55                   	push   %ebp
801027a1:	89 e5                	mov    %esp,%ebp
801027a3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a6:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ab:	85 c0                	test   %eax,%eax
801027ad:	74 10                	je     801027bf <kalloc+0x1f>
    acquire(&kmem.lock);
801027af:	83 ec 0c             	sub    $0xc,%esp
801027b2:	68 c0 40 19 80       	push   $0x801940c0
801027b7:	e8 50 24 00 00       	call   80104c0c <acquire>
801027bc:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027bf:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cb:	74 0a                	je     801027d7 <kalloc+0x37>
    kmem.freelist = r->next;
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	8b 00                	mov    (%eax),%eax
801027d2:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dc:	85 c0                	test   %eax,%eax
801027de:	74 10                	je     801027f0 <kalloc+0x50>
    release(&kmem.lock);
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	68 c0 40 19 80       	push   $0x801940c0
801027e8:	e8 8d 24 00 00       	call   80104c7a <release>
801027ed:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f3:	c9                   	leave  
801027f4:	c3                   	ret    

801027f5 <inb>:
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102802:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102806:	89 c2                	mov    %eax,%edx
80102808:	ec                   	in     (%dx),%al
80102809:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102810:	c9                   	leave  
80102811:	c3                   	ret    

80102812 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102812:	55                   	push   %ebp
80102813:	89 e5                	mov    %esp,%ebp
80102815:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102818:	6a 64                	push   $0x64
8010281a:	e8 d6 ff ff ff       	call   801027f5 <inb>
8010281f:	83 c4 04             	add    $0x4,%esp
80102822:	0f b6 c0             	movzbl %al,%eax
80102825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	83 e0 01             	and    $0x1,%eax
8010282e:	85 c0                	test   %eax,%eax
80102830:	75 0a                	jne    8010283c <kbdgetc+0x2a>
    return -1;
80102832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102837:	e9 23 01 00 00       	jmp    8010295f <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283c:	6a 60                	push   $0x60
8010283e:	e8 b2 ff ff ff       	call   801027f5 <inb>
80102843:	83 c4 04             	add    $0x4,%esp
80102846:	0f b6 c0             	movzbl %al,%eax
80102849:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102853:	75 17                	jne    8010286c <kbdgetc+0x5a>
    shift |= E0ESC;
80102855:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285a:	83 c8 40             	or     $0x40,%eax
8010285d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102862:	b8 00 00 00 00       	mov    $0x0,%eax
80102867:	e9 f3 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	25 80 00 00 00       	and    $0x80,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	74 45                	je     801028bd <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102878:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287d:	83 e0 40             	and    $0x40,%eax
80102880:	85 c0                	test   %eax,%eax
80102882:	75 08                	jne    8010288c <kbdgetc+0x7a>
80102884:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102887:	83 e0 7f             	and    $0x7f,%eax
8010288a:	eb 03                	jmp    8010288f <kbdgetc+0x7d>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102895:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289a:	0f b6 00             	movzbl (%eax),%eax
8010289d:	83 c8 40             	or     $0x40,%eax
801028a0:	0f b6 c0             	movzbl %al,%eax
801028a3:	f7 d0                	not    %eax
801028a5:	89 c2                	mov    %eax,%edx
801028a7:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ac:	21 d0                	and    %edx,%eax
801028ae:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b3:	b8 00 00 00 00       	mov    $0x0,%eax
801028b8:	e9 a2 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028bd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c2:	83 e0 40             	and    $0x40,%eax
801028c5:	85 c0                	test   %eax,%eax
801028c7:	74 14                	je     801028dd <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028c9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d0:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d5:	83 e0 bf             	and    $0xffffffbf,%eax
801028d8:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e0:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e5:	0f b6 00             	movzbl (%eax),%eax
801028e8:	0f b6 d0             	movzbl %al,%edx
801028eb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f0:	09 d0                	or     %edx,%eax
801028f2:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fa:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028ff:	0f b6 00             	movzbl (%eax),%eax
80102902:	0f b6 d0             	movzbl %al,%edx
80102905:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290a:	31 d0                	xor    %edx,%eax
8010290c:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102911:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102916:	83 e0 03             	and    $0x3,%eax
80102919:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102923:	01 d0                	add    %edx,%eax
80102925:	0f b6 00             	movzbl (%eax),%eax
80102928:	0f b6 c0             	movzbl %al,%eax
8010292b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292e:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102933:	83 e0 08             	and    $0x8,%eax
80102936:	85 c0                	test   %eax,%eax
80102938:	74 22                	je     8010295c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293e:	76 0c                	jbe    8010294c <kbdgetc+0x13a>
80102940:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102944:	77 06                	ja     8010294c <kbdgetc+0x13a>
      c += 'A' - 'a';
80102946:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294a:	eb 10                	jmp    8010295c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102950:	76 0a                	jbe    8010295c <kbdgetc+0x14a>
80102952:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102956:	77 04                	ja     8010295c <kbdgetc+0x14a>
      c += 'a' - 'A';
80102958:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010295f:	c9                   	leave  
80102960:	c3                   	ret    

80102961 <kbdintr>:

void
kbdintr(void)
{
80102961:	55                   	push   %ebp
80102962:	89 e5                	mov    %esp,%ebp
80102964:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 12 28 10 80       	push   $0x80102812
8010296f:	e8 62 de ff ff       	call   801007d6 <consoleintr>
80102974:	83 c4 10             	add    $0x10,%esp
}
80102977:	90                   	nop
80102978:	c9                   	leave  
80102979:	c3                   	ret    

8010297a <inb>:
{
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 14             	sub    $0x14,%esp
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102987:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298b:	89 c2                	mov    %eax,%edx
8010298d:	ec                   	in     (%dx),%al
8010298e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102991:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102995:	c9                   	leave  
80102996:	c3                   	ret    

80102997 <outb>:
{
80102997:	55                   	push   %ebp
80102998:	89 e5                	mov    %esp,%ebp
8010299a:	83 ec 08             	sub    $0x8,%esp
8010299d:	8b 45 08             	mov    0x8(%ebp),%eax
801029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a7:	89 d0                	mov    %edx,%eax
801029a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b4:	ee                   	out    %al,(%dx)
}
801029b5:	90                   	nop
801029b6:	c9                   	leave  
801029b7:	c3                   	ret    

801029b8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b8:	55                   	push   %ebp
801029b9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bb:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c1 e0 02             	shl    $0x2,%eax
801029c7:	01 c2                	add    %eax,%edx
801029c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029ce:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d3:	83 c0 20             	add    $0x20,%eax
801029d6:	8b 00                	mov    (%eax),%eax
}
801029d8:	90                   	nop
801029d9:	5d                   	pop    %ebp
801029da:	c3                   	ret    

801029db <lapicinit>:

void
lapicinit(void)
{
801029db:	55                   	push   %ebp
801029dc:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029de:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e3:	85 c0                	test   %eax,%eax
801029e5:	0f 84 0c 01 00 00    	je     80102af7 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029eb:	68 3f 01 00 00       	push   $0x13f
801029f0:	6a 3c                	push   $0x3c
801029f2:	e8 c1 ff ff ff       	call   801029b8 <lapicw>
801029f7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fa:	6a 0b                	push   $0xb
801029fc:	68 f8 00 00 00       	push   $0xf8
80102a01:	e8 b2 ff ff ff       	call   801029b8 <lapicw>
80102a06:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a09:	68 20 00 02 00       	push   $0x20020
80102a0e:	68 c8 00 00 00       	push   $0xc8
80102a13:	e8 a0 ff ff ff       	call   801029b8 <lapicw>
80102a18:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1b:	68 80 96 98 00       	push   $0x989680
80102a20:	68 e0 00 00 00       	push   $0xe0
80102a25:	e8 8e ff ff ff       	call   801029b8 <lapicw>
80102a2a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2d:	68 00 00 01 00       	push   $0x10000
80102a32:	68 d4 00 00 00       	push   $0xd4
80102a37:	e8 7c ff ff ff       	call   801029b8 <lapicw>
80102a3c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a3f:	68 00 00 01 00       	push   $0x10000
80102a44:	68 d8 00 00 00       	push   $0xd8
80102a49:	e8 6a ff ff ff       	call   801029b8 <lapicw>
80102a4e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a51:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a56:	83 c0 30             	add    $0x30,%eax
80102a59:	8b 00                	mov    (%eax),%eax
80102a5b:	c1 e8 10             	shr    $0x10,%eax
80102a5e:	25 fc 00 00 00       	and    $0xfc,%eax
80102a63:	85 c0                	test   %eax,%eax
80102a65:	74 12                	je     80102a79 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a67:	68 00 00 01 00       	push   $0x10000
80102a6c:	68 d0 00 00 00       	push   $0xd0
80102a71:	e8 42 ff ff ff       	call   801029b8 <lapicw>
80102a76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a79:	6a 33                	push   $0x33
80102a7b:	68 dc 00 00 00       	push   $0xdc
80102a80:	e8 33 ff ff ff       	call   801029b8 <lapicw>
80102a85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a88:	6a 00                	push   $0x0
80102a8a:	68 a0 00 00 00       	push   $0xa0
80102a8f:	e8 24 ff ff ff       	call   801029b8 <lapicw>
80102a94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a97:	6a 00                	push   $0x0
80102a99:	68 a0 00 00 00       	push   $0xa0
80102a9e:	e8 15 ff ff ff       	call   801029b8 <lapicw>
80102aa3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa6:	6a 00                	push   $0x0
80102aa8:	6a 2c                	push   $0x2c
80102aaa:	e8 09 ff ff ff       	call   801029b8 <lapicw>
80102aaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab2:	6a 00                	push   $0x0
80102ab4:	68 c4 00 00 00       	push   $0xc4
80102ab9:	e8 fa fe ff ff       	call   801029b8 <lapicw>
80102abe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac1:	68 00 85 08 00       	push   $0x88500
80102ac6:	68 c0 00 00 00       	push   $0xc0
80102acb:	e8 e8 fe ff ff       	call   801029b8 <lapicw>
80102ad0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad3:	90                   	nop
80102ad4:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ad9:	05 00 03 00 00       	add    $0x300,%eax
80102ade:	8b 00                	mov    (%eax),%eax
80102ae0:	25 00 10 00 00       	and    $0x1000,%eax
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	75 eb                	jne    80102ad4 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ae9:	6a 00                	push   $0x0
80102aeb:	6a 20                	push   $0x20
80102aed:	e8 c6 fe ff ff       	call   801029b8 <lapicw>
80102af2:	83 c4 08             	add    $0x8,%esp
80102af5:	eb 01                	jmp    80102af8 <lapicinit+0x11d>
    return;
80102af7:	90                   	nop
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <lapicid>:

int
lapicid(void)
{
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afd:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b02:	85 c0                	test   %eax,%eax
80102b04:	75 07                	jne    80102b0d <lapicid+0x13>
    return 0;
80102b06:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0b:	eb 0d                	jmp    80102b1a <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0d:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b12:	83 c0 20             	add    $0x20,%eax
80102b15:	8b 00                	mov    (%eax),%eax
80102b17:	c1 e8 18             	shr    $0x18,%eax
}
80102b1a:	5d                   	pop    %ebp
80102b1b:	c3                   	ret    

80102b1c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b1f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b24:	85 c0                	test   %eax,%eax
80102b26:	74 0c                	je     80102b34 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b28:	6a 00                	push   $0x0
80102b2a:	6a 2c                	push   $0x2c
80102b2c:	e8 87 fe ff ff       	call   801029b8 <lapicw>
80102b31:	83 c4 08             	add    $0x8,%esp
}
80102b34:	90                   	nop
80102b35:	c9                   	leave  
80102b36:	c3                   	ret    

80102b37 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b37:	55                   	push   %ebp
80102b38:	89 e5                	mov    %esp,%ebp
}
80102b3a:	90                   	nop
80102b3b:	5d                   	pop    %ebp
80102b3c:	c3                   	ret    

80102b3d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
80102b40:	83 ec 14             	sub    $0x14,%esp
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b49:	6a 0f                	push   $0xf
80102b4b:	6a 70                	push   $0x70
80102b4d:	e8 45 fe ff ff       	call   80102997 <outb>
80102b52:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b55:	6a 0a                	push   $0xa
80102b57:	6a 71                	push   $0x71
80102b59:	e8 39 fe ff ff       	call   80102997 <outb>
80102b5e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b61:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b73:	c1 e8 04             	shr    $0x4,%eax
80102b76:	89 c2                	mov    %eax,%edx
80102b78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7b:	83 c0 02             	add    $0x2,%eax
80102b7e:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b81:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b85:	c1 e0 18             	shl    $0x18,%eax
80102b88:	50                   	push   %eax
80102b89:	68 c4 00 00 00       	push   $0xc4
80102b8e:	e8 25 fe ff ff       	call   801029b8 <lapicw>
80102b93:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b96:	68 00 c5 00 00       	push   $0xc500
80102b9b:	68 c0 00 00 00       	push   $0xc0
80102ba0:	e8 13 fe ff ff       	call   801029b8 <lapicw>
80102ba5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba8:	68 c8 00 00 00       	push   $0xc8
80102bad:	e8 85 ff ff ff       	call   80102b37 <microdelay>
80102bb2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb5:	68 00 85 00 00       	push   $0x8500
80102bba:	68 c0 00 00 00       	push   $0xc0
80102bbf:	e8 f4 fd ff ff       	call   801029b8 <lapicw>
80102bc4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc7:	6a 64                	push   $0x64
80102bc9:	e8 69 ff ff ff       	call   80102b37 <microdelay>
80102bce:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd8:	eb 3d                	jmp    80102c17 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bda:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bde:	c1 e0 18             	shl    $0x18,%eax
80102be1:	50                   	push   %eax
80102be2:	68 c4 00 00 00       	push   $0xc4
80102be7:	e8 cc fd ff ff       	call   801029b8 <lapicw>
80102bec:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bef:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf2:	c1 e8 0c             	shr    $0xc,%eax
80102bf5:	80 cc 06             	or     $0x6,%ah
80102bf8:	50                   	push   %eax
80102bf9:	68 c0 00 00 00       	push   $0xc0
80102bfe:	e8 b5 fd ff ff       	call   801029b8 <lapicw>
80102c03:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c06:	68 c8 00 00 00       	push   $0xc8
80102c0b:	e8 27 ff ff ff       	call   80102b37 <microdelay>
80102c10:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c17:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1b:	7e bd                	jle    80102bda <lapicstartap+0x9d>
  }
}
80102c1d:	90                   	nop
80102c1e:	90                   	nop
80102c1f:	c9                   	leave  
80102c20:	c3                   	ret    

80102c21 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c21:	55                   	push   %ebp
80102c22:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c24:	8b 45 08             	mov    0x8(%ebp),%eax
80102c27:	0f b6 c0             	movzbl %al,%eax
80102c2a:	50                   	push   %eax
80102c2b:	6a 70                	push   $0x70
80102c2d:	e8 65 fd ff ff       	call   80102997 <outb>
80102c32:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c35:	68 c8 00 00 00       	push   $0xc8
80102c3a:	e8 f8 fe ff ff       	call   80102b37 <microdelay>
80102c3f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c42:	6a 71                	push   $0x71
80102c44:	e8 31 fd ff ff       	call   8010297a <inb>
80102c49:	83 c4 04             	add    $0x4,%esp
80102c4c:	0f b6 c0             	movzbl %al,%eax
}
80102c4f:	c9                   	leave  
80102c50:	c3                   	ret    

80102c51 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c54:	6a 00                	push   $0x0
80102c56:	e8 c6 ff ff ff       	call   80102c21 <cmos_read>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c61:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c63:	6a 02                	push   $0x2
80102c65:	e8 b7 ff ff ff       	call   80102c21 <cmos_read>
80102c6a:	83 c4 04             	add    $0x4,%esp
80102c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c70:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c73:	6a 04                	push   $0x4
80102c75:	e8 a7 ff ff ff       	call   80102c21 <cmos_read>
80102c7a:	83 c4 04             	add    $0x4,%esp
80102c7d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c80:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c83:	6a 07                	push   $0x7
80102c85:	e8 97 ff ff ff       	call   80102c21 <cmos_read>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c90:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c93:	6a 08                	push   $0x8
80102c95:	e8 87 ff ff ff       	call   80102c21 <cmos_read>
80102c9a:	83 c4 04             	add    $0x4,%esp
80102c9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca3:	6a 09                	push   $0x9
80102ca5:	e8 77 ff ff ff       	call   80102c21 <cmos_read>
80102caa:	83 c4 04             	add    $0x4,%esp
80102cad:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb0:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb3:	90                   	nop
80102cb4:	c9                   	leave  
80102cb5:	c3                   	ret    

80102cb6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb6:	55                   	push   %ebp
80102cb7:	89 e5                	mov    %esp,%ebp
80102cb9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbc:	6a 0b                	push   $0xb
80102cbe:	e8 5e ff ff ff       	call   80102c21 <cmos_read>
80102cc3:	83 c4 04             	add    $0x4,%esp
80102cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	83 e0 04             	and    $0x4,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	0f 94 c0             	sete   %al
80102cd4:	0f b6 c0             	movzbl %al,%eax
80102cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cda:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdd:	50                   	push   %eax
80102cde:	e8 6e ff ff ff       	call   80102c51 <fill_rtcdate>
80102ce3:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce6:	6a 0a                	push   $0xa
80102ce8:	e8 34 ff ff ff       	call   80102c21 <cmos_read>
80102ced:	83 c4 04             	add    $0x4,%esp
80102cf0:	25 80 00 00 00       	and    $0x80,%eax
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	75 27                	jne    80102d20 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cf9:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfc:	50                   	push   %eax
80102cfd:	e8 4f ff ff ff       	call   80102c51 <fill_rtcdate>
80102d02:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d05:	83 ec 04             	sub    $0x4,%esp
80102d08:	6a 18                	push   $0x18
80102d0a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0d:	50                   	push   %eax
80102d0e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d11:	50                   	push   %eax
80102d12:	e8 d2 21 00 00       	call   80104ee9 <memcmp>
80102d17:	83 c4 10             	add    $0x10,%esp
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	74 05                	je     80102d23 <cmostime+0x6d>
80102d1e:	eb ba                	jmp    80102cda <cmostime+0x24>
        continue;
80102d20:	90                   	nop
    fill_rtcdate(&t1);
80102d21:	eb b7                	jmp    80102cda <cmostime+0x24>
      break;
80102d23:	90                   	nop
  }

  // convert
  if(bcd) {
80102d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d28:	0f 84 b4 00 00 00    	je     80102de2 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d31:	c1 e8 04             	shr    $0x4,%eax
80102d34:	89 c2                	mov    %eax,%edx
80102d36:	89 d0                	mov    %edx,%eax
80102d38:	c1 e0 02             	shl    $0x2,%eax
80102d3b:	01 d0                	add    %edx,%eax
80102d3d:	01 c0                	add    %eax,%eax
80102d3f:	89 c2                	mov    %eax,%edx
80102d41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d44:	83 e0 0f             	and    $0xf,%eax
80102d47:	01 d0                	add    %edx,%eax
80102d49:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4f:	c1 e8 04             	shr    $0x4,%eax
80102d52:	89 c2                	mov    %eax,%edx
80102d54:	89 d0                	mov    %edx,%eax
80102d56:	c1 e0 02             	shl    $0x2,%eax
80102d59:	01 d0                	add    %edx,%eax
80102d5b:	01 c0                	add    %eax,%eax
80102d5d:	89 c2                	mov    %eax,%edx
80102d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d62:	83 e0 0f             	and    $0xf,%eax
80102d65:	01 d0                	add    %edx,%eax
80102d67:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6d:	c1 e8 04             	shr    $0x4,%eax
80102d70:	89 c2                	mov    %eax,%edx
80102d72:	89 d0                	mov    %edx,%eax
80102d74:	c1 e0 02             	shl    $0x2,%eax
80102d77:	01 d0                	add    %edx,%eax
80102d79:	01 c0                	add    %eax,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d80:	83 e0 0f             	and    $0xf,%eax
80102d83:	01 d0                	add    %edx,%eax
80102d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8b:	c1 e8 04             	shr    $0x4,%eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	89 d0                	mov    %edx,%eax
80102d92:	c1 e0 02             	shl    $0x2,%eax
80102d95:	01 d0                	add    %edx,%eax
80102d97:	01 c0                	add    %eax,%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9e:	83 e0 0f             	and    $0xf,%eax
80102da1:	01 d0                	add    %edx,%eax
80102da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da9:	c1 e8 04             	shr    $0x4,%eax
80102dac:	89 c2                	mov    %eax,%edx
80102dae:	89 d0                	mov    %edx,%eax
80102db0:	c1 e0 02             	shl    $0x2,%eax
80102db3:	01 d0                	add    %edx,%eax
80102db5:	01 c0                	add    %eax,%eax
80102db7:	89 c2                	mov    %eax,%edx
80102db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbc:	83 e0 0f             	and    $0xf,%eax
80102dbf:	01 d0                	add    %edx,%eax
80102dc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc7:	c1 e8 04             	shr    $0x4,%eax
80102dca:	89 c2                	mov    %eax,%edx
80102dcc:	89 d0                	mov    %edx,%eax
80102dce:	c1 e0 02             	shl    $0x2,%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	01 c0                	add    %eax,%eax
80102dd5:	89 c2                	mov    %eax,%edx
80102dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dda:	83 e0 0f             	and    $0xf,%eax
80102ddd:	01 d0                	add    %edx,%eax
80102ddf:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de2:	8b 45 08             	mov    0x8(%ebp),%eax
80102de5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de8:	89 10                	mov    %edx,(%eax)
80102dea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102ded:	89 50 04             	mov    %edx,0x4(%eax)
80102df0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df3:	89 50 08             	mov    %edx,0x8(%eax)
80102df6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102df9:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dff:	89 50 10             	mov    %edx,0x10(%eax)
80102e02:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e05:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	8b 40 14             	mov    0x14(%eax),%eax
80102e0e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1a:	90                   	nop
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
80102e20:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e23:	83 ec 08             	sub    $0x8,%esp
80102e26:	68 f1 a8 10 80       	push   $0x8010a8f1
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 b5 1d 00 00       	call   80104bea <initlock>
80102e35:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e38:	83 ec 08             	sub    $0x8,%esp
80102e3b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3e:	50                   	push   %eax
80102e3f:	ff 75 08             	push   0x8(%ebp)
80102e42:	e8 87 e5 ff ff       	call   801013ce <readsb>
80102e47:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4d:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e55:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5d:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e62:	e8 b3 01 00 00       	call   8010301a <recover_from_log>
}
80102e67:	90                   	nop
80102e68:	c9                   	leave  
80102e69:	c3                   	ret    

80102e6a <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6a:	55                   	push   %ebp
80102e6b:	89 e5                	mov    %esp,%ebp
80102e6d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e77:	e9 95 00 00 00       	jmp    80102f11 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7c:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e85:	01 d0                	add    %edx,%eax
80102e87:	83 c0 01             	add    $0x1,%eax
80102e8a:	89 c2                	mov    %eax,%edx
80102e8c:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e91:	83 ec 08             	sub    $0x8,%esp
80102e94:	52                   	push   %edx
80102e95:	50                   	push   %eax
80102e96:	e8 66 d3 ff ff       	call   80100201 <bread>
80102e9b:	83 c4 10             	add    $0x10,%esp
80102e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea4:	83 c0 10             	add    $0x10,%eax
80102ea7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eae:	89 c2                	mov    %eax,%edx
80102eb0:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	52                   	push   %edx
80102eb9:	50                   	push   %eax
80102eba:	e8 42 d3 ff ff       	call   80100201 <bread>
80102ebf:	83 c4 10             	add    $0x10,%esp
80102ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec8:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ece:	83 c0 5c             	add    $0x5c,%eax
80102ed1:	83 ec 04             	sub    $0x4,%esp
80102ed4:	68 00 02 00 00       	push   $0x200
80102ed9:	52                   	push   %edx
80102eda:	50                   	push   %eax
80102edb:	e8 61 20 00 00       	call   80104f41 <memmove>
80102ee0:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee3:	83 ec 0c             	sub    $0xc,%esp
80102ee6:	ff 75 ec             	push   -0x14(%ebp)
80102ee9:	e8 4c d3 ff ff       	call   8010023a <bwrite>
80102eee:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef1:	83 ec 0c             	sub    $0xc,%esp
80102ef4:	ff 75 f0             	push   -0x10(%ebp)
80102ef7:	e8 87 d3 ff ff       	call   80100283 <brelse>
80102efc:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102eff:	83 ec 0c             	sub    $0xc,%esp
80102f02:	ff 75 ec             	push   -0x14(%ebp)
80102f05:	e8 79 d3 ff ff       	call   80100283 <brelse>
80102f0a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f11:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f16:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f19:	0f 8c 5d ff ff ff    	jl     80102e7c <install_trans+0x12>
  }
}
80102f1f:	90                   	nop
80102f20:	90                   	nop
80102f21:	c9                   	leave  
80102f22:	c3                   	ret    

80102f23 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f23:	55                   	push   %ebp
80102f24:	89 e5                	mov    %esp,%ebp
80102f26:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f29:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2e:	89 c2                	mov    %eax,%edx
80102f30:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f35:	83 ec 08             	sub    $0x8,%esp
80102f38:	52                   	push   %edx
80102f39:	50                   	push   %eax
80102f3a:	e8 c2 d2 ff ff       	call   80100201 <bread>
80102f3f:	83 c4 10             	add    $0x10,%esp
80102f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f48:	83 c0 5c             	add    $0x5c,%eax
80102f4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	8b 00                	mov    (%eax),%eax
80102f53:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f5f:	eb 1b                	jmp    80102f7c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f67:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6e:	83 c2 10             	add    $0x10,%edx
80102f71:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7c:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f84:	7c db                	jl     80102f61 <read_head+0x3e>
  }
  brelse(buf);
80102f86:	83 ec 0c             	sub    $0xc,%esp
80102f89:	ff 75 f0             	push   -0x10(%ebp)
80102f8c:	e8 f2 d2 ff ff       	call   80100283 <brelse>
80102f91:	83 c4 10             	add    $0x10,%esp
}
80102f94:	90                   	nop
80102f95:	c9                   	leave  
80102f96:	c3                   	ret    

80102f97 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9d:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa2:	89 c2                	mov    %eax,%edx
80102fa4:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fa9:	83 ec 08             	sub    $0x8,%esp
80102fac:	52                   	push   %edx
80102fad:	50                   	push   %eax
80102fae:	e8 4e d2 ff ff       	call   80100201 <bread>
80102fb3:	83 c4 10             	add    $0x10,%esp
80102fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbc:	83 c0 5c             	add    $0x5c,%eax
80102fbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc2:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd4:	eb 1b                	jmp    80102ff1 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd9:	83 c0 10             	add    $0x10,%eax
80102fdc:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fe9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff1:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ff9:	7c db                	jl     80102fd6 <write_head+0x3f>
  }
  bwrite(buf);
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	ff 75 f0             	push   -0x10(%ebp)
80103001:	e8 34 d2 ff ff       	call   8010023a <bwrite>
80103006:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	ff 75 f0             	push   -0x10(%ebp)
8010300f:	e8 6f d2 ff ff       	call   80100283 <brelse>
80103014:	83 c4 10             	add    $0x10,%esp
}
80103017:	90                   	nop
80103018:	c9                   	leave  
80103019:	c3                   	ret    

8010301a <recover_from_log>:

static void
recover_from_log(void)
{
8010301a:	55                   	push   %ebp
8010301b:	89 e5                	mov    %esp,%ebp
8010301d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103020:	e8 fe fe ff ff       	call   80102f23 <read_head>
  install_trans(); // if committed, copy from log to disk
80103025:	e8 40 fe ff ff       	call   80102e6a <install_trans>
  log.lh.n = 0;
8010302a:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103031:	00 00 00 
  write_head(); // clear the log
80103034:	e8 5e ff ff ff       	call   80102f97 <write_head>
}
80103039:	90                   	nop
8010303a:	c9                   	leave  
8010303b:	c3                   	ret    

8010303c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
8010303f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103042:	83 ec 0c             	sub    $0xc,%esp
80103045:	68 20 41 19 80       	push   $0x80194120
8010304a:	e8 bd 1b 00 00       	call   80104c0c <acquire>
8010304f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103052:	a1 60 41 19 80       	mov    0x80194160,%eax
80103057:	85 c0                	test   %eax,%eax
80103059:	74 17                	je     80103072 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 20 41 19 80       	push   $0x80194120
80103063:	68 20 41 19 80       	push   $0x80194120
80103068:	e8 1c 15 00 00       	call   80104589 <sleep>
8010306d:	83 c4 10             	add    $0x10,%esp
80103070:	eb e0                	jmp    80103052 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103072:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103078:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307d:	8d 50 01             	lea    0x1(%eax),%edx
80103080:	89 d0                	mov    %edx,%eax
80103082:	c1 e0 02             	shl    $0x2,%eax
80103085:	01 d0                	add    %edx,%eax
80103087:	01 c0                	add    %eax,%eax
80103089:	01 c8                	add    %ecx,%eax
8010308b:	83 f8 1e             	cmp    $0x1e,%eax
8010308e:	7e 17                	jle    801030a7 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103090:	83 ec 08             	sub    $0x8,%esp
80103093:	68 20 41 19 80       	push   $0x80194120
80103098:	68 20 41 19 80       	push   $0x80194120
8010309d:	e8 e7 14 00 00       	call   80104589 <sleep>
801030a2:	83 c4 10             	add    $0x10,%esp
801030a5:	eb ab                	jmp    80103052 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ac:	83 c0 01             	add    $0x1,%eax
801030af:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b4:	83 ec 0c             	sub    $0xc,%esp
801030b7:	68 20 41 19 80       	push   $0x80194120
801030bc:	e8 b9 1b 00 00       	call   80104c7a <release>
801030c1:	83 c4 10             	add    $0x10,%esp
      break;
801030c4:	90                   	nop
    }
  }
}
801030c5:	90                   	nop
801030c6:	c9                   	leave  
801030c7:	c3                   	ret    

801030c8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d5:	83 ec 0c             	sub    $0xc,%esp
801030d8:	68 20 41 19 80       	push   $0x80194120
801030dd:	e8 2a 1b 00 00       	call   80104c0c <acquire>
801030e2:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ea:	83 e8 01             	sub    $0x1,%eax
801030ed:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f2:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 0d                	je     80103108 <end_op+0x40>
    panic("log.committing");
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	68 f5 a8 10 80       	push   $0x8010a8f5
80103103:	e8 a1 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103108:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 13                	jne    80103124 <end_op+0x5c>
    do_commit = 1;
80103111:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103118:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010311f:	00 00 00 
80103122:	eb 10                	jmp    80103134 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 20 41 19 80       	push   $0x80194120
8010312c:	e8 42 15 00 00       	call   80104673 <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 39 1b 00 00       	call   80104c7a <release>
80103141:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103148:	74 3f                	je     80103189 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314a:	e8 f6 00 00 00       	call   80103245 <commit>
    acquire(&log.lock);
8010314f:	83 ec 0c             	sub    $0xc,%esp
80103152:	68 20 41 19 80       	push   $0x80194120
80103157:	e8 b0 1a 00 00       	call   80104c0c <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 fd 14 00 00       	call   80104673 <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 f4 1a 00 00       	call   80104c7a <release>
80103186:	83 c4 10             	add    $0x10,%esp
  }
}
80103189:	90                   	nop
8010318a:	c9                   	leave  
8010318b:	c3                   	ret    

8010318c <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103199:	e9 95 00 00 00       	jmp    80103233 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	01 d0                	add    %edx,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b3:	83 ec 08             	sub    $0x8,%esp
801031b6:	52                   	push   %edx
801031b7:	50                   	push   %eax
801031b8:	e8 44 d0 ff ff       	call   80100201 <bread>
801031bd:	83 c4 10             	add    $0x10,%esp
801031c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c6:	83 c0 10             	add    $0x10,%eax
801031c9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d0:	89 c2                	mov    %eax,%edx
801031d2:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d7:	83 ec 08             	sub    $0x8,%esp
801031da:	52                   	push   %edx
801031db:	50                   	push   %eax
801031dc:	e8 20 d0 ff ff       	call   80100201 <bread>
801031e1:	83 c4 10             	add    $0x10,%esp
801031e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f0:	83 c0 5c             	add    $0x5c,%eax
801031f3:	83 ec 04             	sub    $0x4,%esp
801031f6:	68 00 02 00 00       	push   $0x200
801031fb:	52                   	push   %edx
801031fc:	50                   	push   %eax
801031fd:	e8 3f 1d 00 00       	call   80104f41 <memmove>
80103202:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103205:	83 ec 0c             	sub    $0xc,%esp
80103208:	ff 75 f0             	push   -0x10(%ebp)
8010320b:	e8 2a d0 ff ff       	call   8010023a <bwrite>
80103210:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103213:	83 ec 0c             	sub    $0xc,%esp
80103216:	ff 75 ec             	push   -0x14(%ebp)
80103219:	e8 65 d0 ff ff       	call   80100283 <brelse>
8010321e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103221:	83 ec 0c             	sub    $0xc,%esp
80103224:	ff 75 f0             	push   -0x10(%ebp)
80103227:	e8 57 d0 ff ff       	call   80100283 <brelse>
8010322c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010322f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103233:	a1 68 41 19 80       	mov    0x80194168,%eax
80103238:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323b:	0f 8c 5d ff ff ff    	jl     8010319e <write_log+0x12>
  }
}
80103241:	90                   	nop
80103242:	90                   	nop
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <commit>:

static void
commit()
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103250:	85 c0                	test   %eax,%eax
80103252:	7e 1e                	jle    80103272 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103254:	e8 33 ff ff ff       	call   8010318c <write_log>
    write_head();    // Write header to disk -- the real commit
80103259:	e8 39 fd ff ff       	call   80102f97 <write_head>
    install_trans(); // Now install writes to home locations
8010325e:	e8 07 fc ff ff       	call   80102e6a <install_trans>
    log.lh.n = 0;
80103263:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326d:	e8 25 fd ff ff       	call   80102f97 <write_head>
  }
}
80103272:	90                   	nop
80103273:	c9                   	leave  
80103274:	c3                   	ret    

80103275 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103275:	55                   	push   %ebp
80103276:	89 e5                	mov    %esp,%ebp
80103278:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103280:	83 f8 1d             	cmp    $0x1d,%eax
80103283:	7f 12                	jg     80103297 <log_write+0x22>
80103285:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328a:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103290:	83 ea 01             	sub    $0x1,%edx
80103293:	39 d0                	cmp    %edx,%eax
80103295:	7c 0d                	jl     801032a4 <log_write+0x2f>
    panic("too big a transaction");
80103297:	83 ec 0c             	sub    $0xc,%esp
8010329a:	68 04 a9 10 80       	push   $0x8010a904
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 1a a9 10 80       	push   $0x8010a91a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 45 19 00 00       	call   80104c0c <acquire>
801032c7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d1:	eb 1d                	jmp    801032f0 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d6:	83 c0 10             	add    $0x10,%eax
801032d9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	8b 45 08             	mov    0x8(%ebp),%eax
801032e5:	8b 40 08             	mov    0x8(%eax),%eax
801032e8:	39 c2                	cmp    %eax,%edx
801032ea:	74 10                	je     801032fc <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f0:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f8:	7c d9                	jl     801032d3 <log_write+0x5e>
801032fa:	eb 01                	jmp    801032fd <log_write+0x88>
      break;
801032fc:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103300:	8b 40 08             	mov    0x8(%eax),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103308:	83 c0 10             	add    $0x10,%eax
8010330b:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103312:	a1 68 41 19 80       	mov    0x80194168,%eax
80103317:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331a:	75 0d                	jne    80103329 <log_write+0xb4>
    log.lh.n++;
8010331c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103321:	83 c0 01             	add    $0x1,%eax
80103324:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103329:	8b 45 08             	mov    0x8(%ebp),%eax
8010332c:	8b 00                	mov    (%eax),%eax
8010332e:	83 c8 04             	or     $0x4,%eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	8b 45 08             	mov    0x8(%ebp),%eax
80103336:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	68 20 41 19 80       	push   $0x80194120
80103340:	e8 35 19 00 00       	call   80104c7a <release>
80103345:	83 c4 10             	add    $0x10,%esp
}
80103348:	90                   	nop
80103349:	c9                   	leave  
8010334a:	c3                   	ret    

8010334b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
8010334e:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103351:	8b 55 08             	mov    0x8(%ebp),%edx
80103354:	8b 45 0c             	mov    0xc(%ebp),%eax
80103357:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335a:	f0 87 02             	lock xchg %eax,(%edx)
8010335d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103360:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103363:	c9                   	leave  
80103364:	c3                   	ret    

80103365 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103365:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103369:	83 e4 f0             	and    $0xfffffff0,%esp
8010336c:	ff 71 fc             	push   -0x4(%ecx)
8010336f:	55                   	push   %ebp
80103370:	89 e5                	mov    %esp,%ebp
80103372:	51                   	push   %ecx
80103373:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103376:	e8 ff 50 00 00       	call   8010847a <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 ff 46 00 00       	call   80107a94 <kvmalloc>
  mpinit_uefi();
80103395:	e8 a6 4e 00 00       	call   80108240 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 88 41 00 00       	call   8010752c <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 0d 35 00 00       	call   801068c5 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 0c 2f 00 00       	call   801062ce <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 ea 71 00 00       	call   8010a5bb <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 e3 52 00 00       	call   801086d3 <pci_init>
  arp_scan();
801033f0:	e8 1a 60 00 00       	call   8010940f <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 d1 07 00 00       	call   80103bcb <userinit>

  mpmain();        // finish this processor's setup
801033fa:	e8 1a 00 00 00       	call   80103419 <mpmain>

801033ff <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103405:	e8 a2 46 00 00       	call   80107aac <switchkvm>
  seginit();
8010340a:	e8 1d 41 00 00       	call   8010752c <seginit>
  lapicinit();
8010340f:	e8 c7 f5 ff ff       	call   801029db <lapicinit>
  mpmain();
80103414:	e8 00 00 00 00       	call   80103419 <mpmain>

80103419 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	53                   	push   %ebx
8010341d:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103420:	e8 a6 05 00 00       	call   801039cb <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 9f 05 00 00       	call   801039cb <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 35 a9 10 80       	push   $0x8010a935
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 01 30 00 00       	call   80106444 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 9e 05 00 00       	call   801039e6 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 5f 0d 00 00       	call   801041bf <scheduler>

80103460 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103460:	55                   	push   %ebp
80103461:	89 e5                	mov    %esp,%ebp
80103463:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103466:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103472:	83 ec 04             	sub    $0x4,%esp
80103475:	50                   	push   %eax
80103476:	68 38 f5 10 80       	push   $0x8010f538
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 be 1a 00 00       	call   80104f41 <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 c0 76 19 80 	movl   $0x801976c0,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 52 05 00 00       	call   801039e6 <mycpu>
80103494:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103497:	74 67                	je     80103500 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103499:	e8 02 f3 ff ff       	call   801027a0 <kalloc>
8010349e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a4:	83 e8 04             	sub    $0x4,%eax
801034a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034aa:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b0:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	83 e8 08             	sub    $0x8,%eax
801034b8:	c7 00 ff 33 10 80    	movl   $0x801033ff,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034be:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cc:	83 e8 0c             	sub    $0xc,%eax
801034cf:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dd:	0f b6 00             	movzbl (%eax),%eax
801034e0:	0f b6 c0             	movzbl %al,%eax
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	52                   	push   %edx
801034e7:	50                   	push   %eax
801034e8:	e8 50 f6 ff ff       	call   80102b3d <lapicstartap>
801034ed:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f0:	90                   	nop
801034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fa:	85 c0                	test   %eax,%eax
801034fc:	74 f3                	je     801034f1 <startothers+0x91>
801034fe:	eb 01                	jmp    80103501 <startothers+0xa1>
      continue;
80103500:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103501:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
80103508:	a1 90 79 19 80       	mov    0x80197990,%eax
8010350d:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103513:	05 c0 76 19 80       	add    $0x801976c0,%eax
80103518:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351b:	0f 82 6e ff ff ff    	jb     8010348f <startothers+0x2f>
      ;
  }
}
80103521:	90                   	nop
80103522:	90                   	nop
80103523:	c9                   	leave  
80103524:	c3                   	ret    

80103525 <outb>:
{
80103525:	55                   	push   %ebp
80103526:	89 e5                	mov    %esp,%ebp
80103528:	83 ec 08             	sub    $0x8,%esp
8010352b:	8b 45 08             	mov    0x8(%ebp),%eax
8010352e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103531:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103535:	89 d0                	mov    %edx,%eax
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d0 ff ff ff       	call   80103525 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 be ff ff ff       	call   80103525 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave  
8010356c:	c3                   	ret    

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 4b da ff ff       	call   80100fdd <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 34 da ff ff       	call   80100fdd <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e0 f1 ff ff       	call   801027a0 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 49 a9 10 80       	push   $0x8010a949
8010360c:	50                   	push   %eax
8010360d:	e8 d8 15 00 00       	call   80104bea <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 85 f0 ff ff       	call   80102706 <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 00 da ff ff       	call   8010109b <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 e6 d9 ff ff       	call   8010109b <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave  
801036be:	c3                   	ret    

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 3b 15 00 00       	call   80104c0c <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 7b 0f 00 00       	call   80104673 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 58 0f 00 00       	call   80104673 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 36 15 00 00       	call   80104c7a <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 b4 ef ff ff       	call   80102706 <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 17 15 00 00       	call   80104c7a <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 8f 14 00 00       	call   80104c0c <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 c0 02 00 00       	call   80103a5e <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 c9 14 00 00       	call   80104c7a <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 a4 0e 00 00       	call   80104673 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 a1 0d 00 00       	call   80104589 <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 21 0e 00 00       	call   80104673 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 19 14 00 00       	call   80104c7a <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 8e 13 00 00       	call   80104c0c <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 d6 01 00 00       	call   80103a5e <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 df 13 00 00       	call   80104c7a <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 cb 0c 00 00       	call   80104589 <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 22 0d 00 00       	call   80104673 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 1a 13 00 00       	call   80104c7a <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave  
80103967:	c3                   	ret    

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf  
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti    
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret    

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 50 a9 10 80       	push   $0x8010a950
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 53 12 00 00       	call   80104bea <initlock>
80103997:	83 c4 10             	add    $0x10,%esp

  //MLFQ 큐 4개 초기화
  for (int i = 0; i < MLFQ_LEVELS; i++) {
8010399a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039a1:	eb 1e                	jmp    801039c1 <pinit+0x42>
    initqueue(&mlfq[i]);
801039a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a6:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
801039ac:	05 40 6a 19 80       	add    $0x80196a40,%eax
801039b1:	83 ec 0c             	sub    $0xc,%esp
801039b4:	50                   	push   %eax
801039b5:	e8 77 0d 00 00       	call   80104731 <initqueue>
801039ba:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < MLFQ_LEVELS; i++) {
801039bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039c1:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801039c5:	7e dc                	jle    801039a3 <pinit+0x24>
  }
}
801039c7:	90                   	nop
801039c8:	90                   	nop
801039c9:	c9                   	leave  
801039ca:	c3                   	ret    

801039cb <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801039cb:	55                   	push   %ebp
801039cc:	89 e5                	mov    %esp,%ebp
801039ce:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039d1:	e8 10 00 00 00       	call   801039e6 <mycpu>
801039d6:	2d c0 76 19 80       	sub    $0x801976c0,%eax
801039db:	c1 f8 02             	sar    $0x2,%eax
801039de:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
801039e4:	c9                   	leave  
801039e5:	c3                   	ret    

801039e6 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039e6:	55                   	push   %ebp
801039e7:	89 e5                	mov    %esp,%ebp
801039e9:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039ec:	e8 77 ff ff ff       	call   80103968 <readeflags>
801039f1:	25 00 02 00 00       	and    $0x200,%eax
801039f6:	85 c0                	test   %eax,%eax
801039f8:	74 0d                	je     80103a07 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039fa:	83 ec 0c             	sub    $0xc,%esp
801039fd:	68 58 a9 10 80       	push   $0x8010a958
80103a02:	e8 a2 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103a07:	e8 ee f0 ff ff       	call   80102afa <lapicid>
80103a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103a0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a16:	eb 2d                	jmp    80103a45 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1b:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a21:	05 c0 76 19 80       	add    $0x801976c0,%eax
80103a26:	0f b6 00             	movzbl (%eax),%eax
80103a29:	0f b6 c0             	movzbl %al,%eax
80103a2c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a2f:	75 10                	jne    80103a41 <mycpu+0x5b>
      return &cpus[i];
80103a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a34:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a3a:	05 c0 76 19 80       	add    $0x801976c0,%eax
80103a3f:	eb 1b                	jmp    80103a5c <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a45:	a1 90 79 19 80       	mov    0x80197990,%eax
80103a4a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a4d:	7c c9                	jl     80103a18 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a4f:	83 ec 0c             	sub    $0xc,%esp
80103a52:	68 7e a9 10 80       	push   $0x8010a97e
80103a57:	e8 4d cb ff ff       	call   801005a9 <panic>
}
80103a5c:	c9                   	leave  
80103a5d:	c3                   	ret    

80103a5e <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a5e:	55                   	push   %ebp
80103a5f:	89 e5                	mov    %esp,%ebp
80103a61:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a64:	e8 0e 13 00 00       	call   80104d77 <pushcli>
  c = mycpu();
80103a69:	e8 78 ff ff ff       	call   801039e6 <mycpu>
80103a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a74:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a7d:	e8 42 13 00 00       	call   80104dc4 <popcli>
  return p;
80103a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a85:	c9                   	leave  
80103a86:	c3                   	ret    

80103a87 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a87:	55                   	push   %ebp
80103a88:	89 e5                	mov    %esp,%ebp
80103a8a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a8d:	83 ec 0c             	sub    $0xc,%esp
80103a90:	68 00 42 19 80       	push   $0x80194200
80103a95:	e8 72 11 00 00       	call   80104c0c <acquire>
80103a9a:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a9d:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103aa4:	eb 11                	jmp    80103ab7 <allocproc+0x30>
    if(p->state == UNUSED){
80103aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa9:	8b 40 0c             	mov    0xc(%eax),%eax
80103aac:	85 c0                	test   %eax,%eax
80103aae:	74 2a                	je     80103ada <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ab0:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80103ab7:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80103abe:	72 e6                	jb     80103aa6 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103ac0:	83 ec 0c             	sub    $0xc,%esp
80103ac3:	68 00 42 19 80       	push   $0x80194200
80103ac8:	e8 ad 11 00 00       	call   80104c7a <release>
80103acd:	83 c4 10             	add    $0x10,%esp
  return 0;
80103ad0:	b8 00 00 00 00       	mov    $0x0,%eax
80103ad5:	e9 ef 00 00 00       	jmp    80103bc9 <allocproc+0x142>
      goto found;
80103ada:	90                   	nop

found:
  p->state = EMBRYO;
80103adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ade:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ae5:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103aea:	8d 50 01             	lea    0x1(%eax),%edx
80103aed:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103af3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103af6:	89 42 10             	mov    %eax,0x10(%edx)

  //추가
  p->priority = 3;  // Q3에서 시작
80103af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afc:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)

  for (int i = 0; i < MLFQ_LEVELS; i++) {
80103b03:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103b0a:	eb 24                	jmp    80103b30 <allocproc+0xa9>
    p->ticks[i] = 0;
80103b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b12:	83 c2 20             	add    $0x20,%edx
80103b15:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    p->wait_ticks[i] = 0;
80103b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b22:	83 c2 24             	add    $0x24,%edx
80103b25:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  for (int i = 0; i < MLFQ_LEVELS; i++) {
80103b2c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103b30:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80103b34:	7e d6                	jle    80103b0c <allocproc+0x85>
  }
  
  release(&ptable.lock);
80103b36:	83 ec 0c             	sub    $0xc,%esp
80103b39:	68 00 42 19 80       	push   $0x80194200
80103b3e:	e8 37 11 00 00       	call   80104c7a <release>
80103b43:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103b46:	e8 55 ec ff ff       	call   801027a0 <kalloc>
80103b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b4e:	89 42 08             	mov    %eax,0x8(%edx)
80103b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b54:	8b 40 08             	mov    0x8(%eax),%eax
80103b57:	85 c0                	test   %eax,%eax
80103b59:	75 11                	jne    80103b6c <allocproc+0xe5>
    p->state = UNUSED;
80103b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b5e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b65:	b8 00 00 00 00       	mov    $0x0,%eax
80103b6a:	eb 5d                	jmp    80103bc9 <allocproc+0x142>
  }
  sp = p->kstack + KSTACKSIZE;
80103b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6f:	8b 40 08             	mov    0x8(%eax),%eax
80103b72:	05 00 10 00 00       	add    $0x1000,%eax
80103b77:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b7a:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b84:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b87:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80103b8b:	ba 88 62 10 80       	mov    $0x80106288,%edx
80103b90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b93:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b95:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80103b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b9f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba5:	8b 40 1c             	mov    0x1c(%eax),%eax
80103ba8:	83 ec 04             	sub    $0x4,%esp
80103bab:	6a 14                	push   $0x14
80103bad:	6a 00                	push   $0x0
80103baf:	50                   	push   %eax
80103bb0:	e8 cd 12 00 00       	call   80104e82 <memset>
80103bb5:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbb:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bbe:	ba 43 45 10 80       	mov    $0x80104543,%edx
80103bc3:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103bc9:	c9                   	leave  
80103bca:	c3                   	ret    

80103bcb <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103bcb:	55                   	push   %ebp
80103bcc:	89 e5                	mov    %esp,%ebp
80103bce:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103bd1:	e8 b1 fe ff ff       	call   80103a87 <allocproc>
80103bd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdc:	a3 60 6e 19 80       	mov    %eax,0x80196e60
  if((p->pgdir = setupkvm()) == 0){
80103be1:	e8 c2 3d 00 00       	call   801079a8 <setupkvm>
80103be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103be9:	89 42 04             	mov    %eax,0x4(%edx)
80103bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bef:	8b 40 04             	mov    0x4(%eax),%eax
80103bf2:	85 c0                	test   %eax,%eax
80103bf4:	75 0d                	jne    80103c03 <userinit+0x38>
    panic("userinit: out of memory?");
80103bf6:	83 ec 0c             	sub    $0xc,%esp
80103bf9:	68 8e a9 10 80       	push   $0x8010a98e
80103bfe:	e8 a6 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103c03:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0b:	8b 40 04             	mov    0x4(%eax),%eax
80103c0e:	83 ec 04             	sub    $0x4,%esp
80103c11:	52                   	push   %edx
80103c12:	68 0c f5 10 80       	push   $0x8010f50c
80103c17:	50                   	push   %eax
80103c18:	e8 47 40 00 00       	call   80107c64 <inituvm>
80103c1d:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c23:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2c:	8b 40 18             	mov    0x18(%eax),%eax
80103c2f:	83 ec 04             	sub    $0x4,%esp
80103c32:	6a 4c                	push   $0x4c
80103c34:	6a 00                	push   $0x0
80103c36:	50                   	push   %eax
80103c37:	e8 46 12 00 00       	call   80104e82 <memset>
80103c3c:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c42:	8b 40 18             	mov    0x18(%eax),%eax
80103c45:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4e:	8b 40 18             	mov    0x18(%eax),%eax
80103c51:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5a:	8b 50 18             	mov    0x18(%eax),%edx
80103c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c60:	8b 40 18             	mov    0x18(%eax),%eax
80103c63:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c67:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6e:	8b 50 18             	mov    0x18(%eax),%edx
80103c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c74:	8b 40 18             	mov    0x18(%eax),%eax
80103c77:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c7b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	8b 40 18             	mov    0x18(%eax),%eax
80103c85:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8f:	8b 40 18             	mov    0x18(%eax),%eax
80103c92:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9c:	8b 40 18             	mov    0x18(%eax),%eax
80103c9f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca9:	83 c0 6c             	add    $0x6c,%eax
80103cac:	83 ec 04             	sub    $0x4,%esp
80103caf:	6a 10                	push   $0x10
80103cb1:	68 a7 a9 10 80       	push   $0x8010a9a7
80103cb6:	50                   	push   %eax
80103cb7:	e8 c9 13 00 00       	call   80105085 <safestrcpy>
80103cbc:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cbf:	83 ec 0c             	sub    $0xc,%esp
80103cc2:	68 b0 a9 10 80       	push   $0x8010a9b0
80103cc7:	e8 51 e8 ff ff       	call   8010251d <namei>
80103ccc:	83 c4 10             	add    $0x10,%esp
80103ccf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cd2:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103cd5:	83 ec 0c             	sub    $0xc,%esp
80103cd8:	68 00 42 19 80       	push   $0x80194200
80103cdd:	e8 2a 0f 00 00       	call   80104c0c <acquire>
80103ce2:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  enqueue(&mlfq[3], p);  // 
80103cef:	83 ec 08             	sub    $0x8,%esp
80103cf2:	ff 75 f4             	push   -0xc(%ebp)
80103cf5:	68 58 6d 19 80       	push   $0x80196d58
80103cfa:	e8 71 0a 00 00       	call   80104770 <enqueue>
80103cff:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80103d02:	83 ec 0c             	sub    $0xc,%esp
80103d05:	68 00 42 19 80       	push   $0x80194200
80103d0a:	e8 6b 0f 00 00       	call   80104c7a <release>
80103d0f:	83 c4 10             	add    $0x10,%esp
}
80103d12:	90                   	nop
80103d13:	c9                   	leave  
80103d14:	c3                   	ret    

80103d15 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103d15:	55                   	push   %ebp
80103d16:	89 e5                	mov    %esp,%ebp
80103d18:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103d1b:	e8 3e fd ff ff       	call   80103a5e <myproc>
80103d20:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103d23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d26:	8b 00                	mov    (%eax),%eax
80103d28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103d2b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d2f:	7e 2e                	jle    80103d5f <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d31:	8b 55 08             	mov    0x8(%ebp),%edx
80103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d37:	01 c2                	add    %eax,%edx
80103d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3c:	8b 40 04             	mov    0x4(%eax),%eax
80103d3f:	83 ec 04             	sub    $0x4,%esp
80103d42:	52                   	push   %edx
80103d43:	ff 75 f4             	push   -0xc(%ebp)
80103d46:	50                   	push   %eax
80103d47:	e8 55 40 00 00       	call   80107da1 <allocuvm>
80103d4c:	83 c4 10             	add    $0x10,%esp
80103d4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d56:	75 3b                	jne    80103d93 <growproc+0x7e>
      return -1;
80103d58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d5d:	eb 4f                	jmp    80103dae <growproc+0x99>
  } else if(n < 0){
80103d5f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d63:	79 2e                	jns    80103d93 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d65:	8b 55 08             	mov    0x8(%ebp),%edx
80103d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6b:	01 c2                	add    %eax,%edx
80103d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d70:	8b 40 04             	mov    0x4(%eax),%eax
80103d73:	83 ec 04             	sub    $0x4,%esp
80103d76:	52                   	push   %edx
80103d77:	ff 75 f4             	push   -0xc(%ebp)
80103d7a:	50                   	push   %eax
80103d7b:	e8 26 41 00 00       	call   80107ea6 <deallocuvm>
80103d80:	83 c4 10             	add    $0x10,%esp
80103d83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d8a:	75 07                	jne    80103d93 <growproc+0x7e>
      return -1;
80103d8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d91:	eb 1b                	jmp    80103dae <growproc+0x99>
  }
  curproc->sz = sz;
80103d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d99:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d9b:	83 ec 0c             	sub    $0xc,%esp
80103d9e:	ff 75 f0             	push   -0x10(%ebp)
80103da1:	e8 1f 3d 00 00       	call   80107ac5 <switchuvm>
80103da6:	83 c4 10             	add    $0x10,%esp
  return 0;
80103da9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103dae:	c9                   	leave  
80103daf:	c3                   	ret    

80103db0 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103db0:	55                   	push   %ebp
80103db1:	89 e5                	mov    %esp,%ebp
80103db3:	57                   	push   %edi
80103db4:	56                   	push   %esi
80103db5:	53                   	push   %ebx
80103db6:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103db9:	e8 a0 fc ff ff       	call   80103a5e <myproc>
80103dbe:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103dc1:	e8 c1 fc ff ff       	call   80103a87 <allocproc>
80103dc6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80103dc9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80103dcd:	75 0a                	jne    80103dd9 <fork+0x29>
    return -1;
80103dcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dd4:	e9 98 01 00 00       	jmp    80103f71 <fork+0x1c1>
  }

  for (int i = 0; i < MLFQ_LEVELS; i++) {
80103dd9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80103de0:	eb 24                	jmp    80103e06 <fork+0x56>
    np->ticks[i] = 0;
80103de2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103de5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103de8:	83 c2 20             	add    $0x20,%edx
80103deb:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    np->wait_ticks[i] = 0;
80103df2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103df5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103df8:	83 c2 24             	add    $0x24,%edx
80103dfb:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  for (int i = 0; i < MLFQ_LEVELS; i++) {
80103e02:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80103e06:	83 7d e0 03          	cmpl   $0x3,-0x20(%ebp)
80103e0a:	7e d6                	jle    80103de2 <fork+0x32>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103e0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e0f:	8b 10                	mov    (%eax),%edx
80103e11:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e14:	8b 40 04             	mov    0x4(%eax),%eax
80103e17:	83 ec 08             	sub    $0x8,%esp
80103e1a:	52                   	push   %edx
80103e1b:	50                   	push   %eax
80103e1c:	e8 23 42 00 00       	call   80108044 <copyuvm>
80103e21:	83 c4 10             	add    $0x10,%esp
80103e24:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103e27:	89 42 04             	mov    %eax,0x4(%edx)
80103e2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103e2d:	8b 40 04             	mov    0x4(%eax),%eax
80103e30:	85 c0                	test   %eax,%eax
80103e32:	75 30                	jne    80103e64 <fork+0xb4>
    kfree(np->kstack);
80103e34:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103e37:	8b 40 08             	mov    0x8(%eax),%eax
80103e3a:	83 ec 0c             	sub    $0xc,%esp
80103e3d:	50                   	push   %eax
80103e3e:	e8 c3 e8 ff ff       	call   80102706 <kfree>
80103e43:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103e46:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103e49:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103e50:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103e53:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103e5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e5f:	e9 0d 01 00 00       	jmp    80103f71 <fork+0x1c1>
  }
  np->sz = curproc->sz;
80103e64:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e67:	8b 10                	mov    (%eax),%edx
80103e69:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103e6c:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103e71:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e74:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e7a:	8b 48 18             	mov    0x18(%eax),%ecx
80103e7d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103e80:	8b 40 18             	mov    0x18(%eax),%eax
80103e83:	89 c2                	mov    %eax,%edx
80103e85:	89 cb                	mov    %ecx,%ebx
80103e87:	b8 13 00 00 00       	mov    $0x13,%eax
80103e8c:	89 d7                	mov    %edx,%edi
80103e8e:	89 de                	mov    %ebx,%esi
80103e90:	89 c1                	mov    %eax,%ecx
80103e92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e94:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103e97:	8b 40 18             	mov    0x18(%eax),%eax
80103e9a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103ea1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103ea8:	eb 3b                	jmp    80103ee5 <fork+0x135>
    if(curproc->ofile[i])
80103eaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ead:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103eb0:	83 c2 08             	add    $0x8,%edx
80103eb3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103eb7:	85 c0                	test   %eax,%eax
80103eb9:	74 26                	je     80103ee1 <fork+0x131>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103ebb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ebe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103ec1:	83 c2 08             	add    $0x8,%edx
80103ec4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ec8:	83 ec 0c             	sub    $0xc,%esp
80103ecb:	50                   	push   %eax
80103ecc:	e8 79 d1 ff ff       	call   8010104a <filedup>
80103ed1:	83 c4 10             	add    $0x10,%esp
80103ed4:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103ed7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103eda:	83 c1 08             	add    $0x8,%ecx
80103edd:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103ee1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103ee5:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103ee9:	7e bf                	jle    80103eaa <fork+0xfa>
  np->cwd = idup(curproc->cwd);
80103eeb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103eee:	8b 40 68             	mov    0x68(%eax),%eax
80103ef1:	83 ec 0c             	sub    $0xc,%esp
80103ef4:	50                   	push   %eax
80103ef5:	e8 b6 da ff ff       	call   801019b0 <idup>
80103efa:	83 c4 10             	add    $0x10,%esp
80103efd:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103f00:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103f03:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f06:	8d 50 6c             	lea    0x6c(%eax),%edx
80103f09:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103f0c:	83 c0 6c             	add    $0x6c,%eax
80103f0f:	83 ec 04             	sub    $0x4,%esp
80103f12:	6a 10                	push   $0x10
80103f14:	52                   	push   %edx
80103f15:	50                   	push   %eax
80103f16:	e8 6a 11 00 00       	call   80105085 <safestrcpy>
80103f1b:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103f1e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103f21:	8b 40 10             	mov    0x10(%eax),%eax
80103f24:	89 45 d4             	mov    %eax,-0x2c(%ebp)

  acquire(&ptable.lock);
80103f27:	83 ec 0c             	sub    $0xc,%esp
80103f2a:	68 00 42 19 80       	push   $0x80194200
80103f2f:	e8 d8 0c 00 00       	call   80104c0c <acquire>
80103f34:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103f37:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103f3a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  np->priority = 3;                // 기본 priority 지정
80103f41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103f44:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  enqueue(&mlfq[3], np);
80103f4b:	83 ec 08             	sub    $0x8,%esp
80103f4e:	ff 75 d8             	push   -0x28(%ebp)
80103f51:	68 58 6d 19 80       	push   $0x80196d58
80103f56:	e8 15 08 00 00       	call   80104770 <enqueue>
80103f5b:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103f5e:	83 ec 0c             	sub    $0xc,%esp
80103f61:	68 00 42 19 80       	push   $0x80194200
80103f66:	e8 0f 0d 00 00       	call   80104c7a <release>
80103f6b:	83 c4 10             	add    $0x10,%esp

  return pid;
80103f6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
80103f71:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f74:	5b                   	pop    %ebx
80103f75:	5e                   	pop    %esi
80103f76:	5f                   	pop    %edi
80103f77:	5d                   	pop    %ebp
80103f78:	c3                   	ret    

80103f79 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103f79:	55                   	push   %ebp
80103f7a:	89 e5                	mov    %esp,%ebp
80103f7c:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103f7f:	e8 da fa ff ff       	call   80103a5e <myproc>
80103f84:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103f87:	a1 60 6e 19 80       	mov    0x80196e60,%eax
80103f8c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f8f:	75 0d                	jne    80103f9e <exit+0x25>
    panic("init exiting");
80103f91:	83 ec 0c             	sub    $0xc,%esp
80103f94:	68 b2 a9 10 80       	push   $0x8010a9b2
80103f99:	e8 0b c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103f9e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103fa5:	eb 3f                	jmp    80103fe6 <exit+0x6d>
    if(curproc->ofile[fd]){
80103fa7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103faa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fad:	83 c2 08             	add    $0x8,%edx
80103fb0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fb4:	85 c0                	test   %eax,%eax
80103fb6:	74 2a                	je     80103fe2 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103fb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fbe:	83 c2 08             	add    $0x8,%edx
80103fc1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fc5:	83 ec 0c             	sub    $0xc,%esp
80103fc8:	50                   	push   %eax
80103fc9:	e8 cd d0 ff ff       	call   8010109b <fileclose>
80103fce:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103fd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fd7:	83 c2 08             	add    $0x8,%edx
80103fda:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103fe1:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103fe2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103fe6:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103fea:	7e bb                	jle    80103fa7 <exit+0x2e>
    }
  }

  begin_op();
80103fec:	e8 4b f0 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ff4:	8b 40 68             	mov    0x68(%eax),%eax
80103ff7:	83 ec 0c             	sub    $0xc,%esp
80103ffa:	50                   	push   %eax
80103ffb:	e8 4b db ff ff       	call   80101b4b <iput>
80104000:	83 c4 10             	add    $0x10,%esp
  end_op();
80104003:	e8 c0 f0 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80104008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010400b:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104012:	83 ec 0c             	sub    $0xc,%esp
80104015:	68 00 42 19 80       	push   $0x80194200
8010401a:	e8 ed 0b 00 00       	call   80104c0c <acquire>
8010401f:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104022:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104025:	8b 40 14             	mov    0x14(%eax),%eax
80104028:	83 ec 0c             	sub    $0xc,%esp
8010402b:	50                   	push   %eax
8010402c:	e8 ff 05 00 00       	call   80104630 <wakeup1>
80104031:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104034:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010403b:	eb 3a                	jmp    80104077 <exit+0xfe>
    if(p->parent == curproc){
8010403d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104040:	8b 40 14             	mov    0x14(%eax),%eax
80104043:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104046:	75 28                	jne    80104070 <exit+0xf7>
      p->parent = initproc;
80104048:	8b 15 60 6e 19 80    	mov    0x80196e60,%edx
8010404e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104051:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104057:	8b 40 0c             	mov    0xc(%eax),%eax
8010405a:	83 f8 05             	cmp    $0x5,%eax
8010405d:	75 11                	jne    80104070 <exit+0xf7>
        wakeup1(initproc);
8010405f:	a1 60 6e 19 80       	mov    0x80196e60,%eax
80104064:	83 ec 0c             	sub    $0xc,%esp
80104067:	50                   	push   %eax
80104068:	e8 c3 05 00 00       	call   80104630 <wakeup1>
8010406d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104070:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104077:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
8010407e:	72 bd                	jb     8010403d <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104080:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104083:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010408a:	e8 8b 03 00 00       	call   8010441a <sched>
  panic("zombie exit");
8010408f:	83 ec 0c             	sub    $0xc,%esp
80104092:	68 bf a9 10 80       	push   $0x8010a9bf
80104097:	e8 0d c5 ff ff       	call   801005a9 <panic>

8010409c <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010409c:	55                   	push   %ebp
8010409d:	89 e5                	mov    %esp,%ebp
8010409f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801040a2:	e8 b7 f9 ff ff       	call   80103a5e <myproc>
801040a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801040aa:	83 ec 0c             	sub    $0xc,%esp
801040ad:	68 00 42 19 80       	push   $0x80194200
801040b2:	e8 55 0b 00 00       	call   80104c0c <acquire>
801040b7:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801040ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040c1:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801040c8:	e9 a4 00 00 00       	jmp    80104171 <wait+0xd5>
      if(p->parent != curproc)
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	8b 40 14             	mov    0x14(%eax),%eax
801040d3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040d6:	0f 85 8d 00 00 00    	jne    80104169 <wait+0xcd>
        continue;
      havekids = 1;
801040dc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801040e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e6:	8b 40 0c             	mov    0xc(%eax),%eax
801040e9:	83 f8 05             	cmp    $0x5,%eax
801040ec:	75 7c                	jne    8010416a <wait+0xce>
        // Found one.
        pid = p->pid;
801040ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f1:	8b 40 10             	mov    0x10(%eax),%eax
801040f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801040f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fa:	8b 40 08             	mov    0x8(%eax),%eax
801040fd:	83 ec 0c             	sub    $0xc,%esp
80104100:	50                   	push   %eax
80104101:	e8 00 e6 ff ff       	call   80102706 <kfree>
80104106:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104116:	8b 40 04             	mov    0x4(%eax),%eax
80104119:	83 ec 0c             	sub    $0xc,%esp
8010411c:	50                   	push   %eax
8010411d:	e8 48 3e 00 00       	call   80107f6a <freevm>
80104122:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104128:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010412f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104132:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413c:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104143:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010414a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104154:	83 ec 0c             	sub    $0xc,%esp
80104157:	68 00 42 19 80       	push   $0x80194200
8010415c:	e8 19 0b 00 00       	call   80104c7a <release>
80104161:	83 c4 10             	add    $0x10,%esp
        return pid;
80104164:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104167:	eb 54                	jmp    801041bd <wait+0x121>
        continue;
80104169:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010416a:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104171:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80104178:	0f 82 4f ff ff ff    	jb     801040cd <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010417e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104182:	74 0a                	je     8010418e <wait+0xf2>
80104184:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104187:	8b 40 24             	mov    0x24(%eax),%eax
8010418a:	85 c0                	test   %eax,%eax
8010418c:	74 17                	je     801041a5 <wait+0x109>
      release(&ptable.lock);
8010418e:	83 ec 0c             	sub    $0xc,%esp
80104191:	68 00 42 19 80       	push   $0x80194200
80104196:	e8 df 0a 00 00       	call   80104c7a <release>
8010419b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010419e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041a3:	eb 18                	jmp    801041bd <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801041a5:	83 ec 08             	sub    $0x8,%esp
801041a8:	68 00 42 19 80       	push   $0x80194200
801041ad:	ff 75 ec             	push   -0x14(%ebp)
801041b0:	e8 d4 03 00 00       	call   80104589 <sleep>
801041b5:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801041b8:	e9 fd fe ff ff       	jmp    801040ba <wait+0x1e>
  }
}
801041bd:	c9                   	leave  
801041be:	c3                   	ret    

801041bf <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801041bf:	55                   	push   %ebp
801041c0:	89 e5                	mov    %esp,%ebp
801041c2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801041c5:	e8 1c f8 ff ff       	call   801039e6 <mycpu>
801041ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
801041cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041d0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041d7:	00 00 00 

  for (;;) {
    sti();
801041da:	e8 99 f7 ff ff       	call   80103978 <sti>
    acquire(&ptable.lock);
801041df:	83 ec 0c             	sub    $0xc,%esp
801041e2:	68 00 42 19 80       	push   $0x80194200
801041e7:	e8 20 0a 00 00       	call   80104c0c <acquire>
801041ec:	83 c4 10             	add    $0x10,%esp

    int found = 0;
801041ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    // MLFQ 정책인 경우
    if (mycpu()->sched_policy == 1) {
801041f6:	e8 eb f7 ff ff       	call   801039e6 <mycpu>
801041fb:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104201:	83 f8 01             	cmp    $0x1,%eax
80104204:	0f 85 64 01 00 00    	jne    8010436e <scheduler+0x1af>
      for(int level =3; level >= 0; level--)  {
8010420a:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
80104211:	e9 4f 01 00 00       	jmp    80104365 <scheduler+0x1a6>
        while (!isempty(&mlfq[level])) {
          p = dequeue(&mlfq[level]);
80104216:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104219:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
8010421f:	05 40 6a 19 80       	add    $0x80196a40,%eax
80104224:	83 ec 0c             	sub    $0xc,%esp
80104227:	50                   	push   %eax
80104228:	e8 bd 05 00 00       	call   801047ea <dequeue>
8010422d:	83 c4 10             	add    $0x10,%esp
80104230:	89 45 f4             	mov    %eax,-0xc(%ebp)
          if ( !p || p->state != RUNNABLE)
80104233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104237:	0f 84 fc 00 00 00    	je     80104339 <scheduler+0x17a>
8010423d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104240:	8b 40 0c             	mov    0xc(%eax),%eax
80104243:	83 f8 03             	cmp    $0x3,%eax
80104246:	74 05                	je     8010424d <scheduler+0x8e>
80104248:	e9 ec 00 00 00       	jmp    80104339 <scheduler+0x17a>
          continue;

          found = 1;
8010424d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

          c->proc = p;
80104254:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104257:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010425a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
80104260:	83 ec 0c             	sub    $0xc,%esp
80104263:	ff 75 f4             	push   -0xc(%ebp)
80104266:	e8 5a 38 00 00       	call   80107ac5 <switchuvm>
8010426b:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
8010426e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104271:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

          swtch(&c->scheduler, p->context);
80104278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010427e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104281:	83 c2 04             	add    $0x4,%edx
80104284:	83 ec 08             	sub    $0x8,%esp
80104287:	50                   	push   %eax
80104288:	52                   	push   %edx
80104289:	e8 69 0e 00 00       	call   801050f7 <swtch>
8010428e:	83 c4 10             	add    $0x10,%esp
          switchkvm();
80104291:	e8 16 38 00 00       	call   80107aac <switchkvm>

          c->proc = 0;
80104296:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104299:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042a0:	00 00 00 

          // time slice 기반으로 demotion 판단
          int time_slice[4] = {0,32,16,8};  // Q0는 FIFO
801042a3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
801042aa:	c7 45 dc 20 00 00 00 	movl   $0x20,-0x24(%ebp)
801042b1:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
801042b8:	c7 45 e4 08 00 00 00 	movl   $0x8,-0x1c(%ebp)
          if (level > 0 && p->ticks[level] >= time_slice[level]) {
801042bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801042c3:	7e 55                	jle    8010431a <scheduler+0x15b>
801042c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801042cb:	83 c2 20             	add    $0x20,%edx
801042ce:	8b 14 90             	mov    (%eax,%edx,4),%edx
801042d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042d4:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
801042d8:	39 c2                	cmp    %eax,%edx
801042da:	7c 3e                	jl     8010431a <scheduler+0x15b>
            p->ticks[level] = 0;        // 현재 큐 실행 시간 초기화
801042dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042df:	8b 55 ec             	mov    -0x14(%ebp),%edx
801042e2:	83 c2 20             	add    $0x20,%edx
801042e5:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
            p->priority = level - 1;    // 우선순위 강등
801042ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042ef:	8d 50 ff             	lea    -0x1(%eax),%edx
801042f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f5:	89 50 7c             	mov    %edx,0x7c(%eax)
            enqueue(&mlfq[p->priority], p);  // 아래 큐에 넣기
801042f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fb:	8b 40 7c             	mov    0x7c(%eax),%eax
801042fe:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
80104304:	05 40 6a 19 80       	add    $0x80196a40,%eax
80104309:	83 ec 08             	sub    $0x8,%esp
8010430c:	ff 75 f4             	push   -0xc(%ebp)
8010430f:	50                   	push   %eax
80104310:	e8 5b 04 00 00       	call   80104770 <enqueue>
80104315:	83 c4 10             	add    $0x10,%esp
80104318:	eb 41                	jmp    8010435b <scheduler+0x19c>
          } else {
            enqueue(&mlfq[level], p);   // 다시 현재 큐로
8010431a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010431d:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
80104323:	05 40 6a 19 80       	add    $0x80196a40,%eax
80104328:	83 ec 08             	sub    $0x8,%esp
8010432b:	ff 75 f4             	push   -0xc(%ebp)
8010432e:	50                   	push   %eax
8010432f:	e8 3c 04 00 00       	call   80104770 <enqueue>
80104334:	83 c4 10             	add    $0x10,%esp
          }
          break;
80104337:	eb 22                	jmp    8010435b <scheduler+0x19c>
        while (!isempty(&mlfq[level])) {
80104339:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010433c:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
80104342:	05 40 6a 19 80       	add    $0x80196a40,%eax
80104347:	83 ec 0c             	sub    $0xc,%esp
8010434a:	50                   	push   %eax
8010434b:	e8 01 04 00 00       	call   80104751 <isempty>
80104350:	83 c4 10             	add    $0x10,%esp
80104353:	85 c0                	test   %eax,%eax
80104355:	0f 84 bb fe ff ff    	je     80104216 <scheduler+0x57>
        }
        if (found) break;
8010435b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010435f:	75 0c                	jne    8010436d <scheduler+0x1ae>
      for(int level =3; level >= 0; level--)  {
80104361:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
80104365:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104369:	79 ce                	jns    80104339 <scheduler+0x17a>
8010436b:	eb 01                	jmp    8010436e <scheduler+0x1af>
        if (found) break;
8010436d:	90                   	nop
      }
    }
    if (!found && mycpu()->sched_policy != 1) {
8010436e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104372:	0f 85 8d 00 00 00    	jne    80104405 <scheduler+0x246>
80104378:	e8 69 f6 ff ff       	call   801039e6 <mycpu>
8010437d:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104383:	83 f8 01             	cmp    $0x1,%eax
80104386:	74 7d                	je     80104405 <scheduler+0x246>
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104388:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010438f:	eb 6b                	jmp    801043fc <scheduler+0x23d>
        if (p->state != RUNNABLE)
80104391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104394:	8b 40 0c             	mov    0xc(%eax),%eax
80104397:	83 f8 03             	cmp    $0x3,%eax
8010439a:	75 58                	jne    801043f4 <scheduler+0x235>
          continue;
        found = 1;
8010439c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        c->proc = p;
801043a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043a9:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
801043af:	83 ec 0c             	sub    $0xc,%esp
801043b2:	ff 75 f4             	push   -0xc(%ebp)
801043b5:	e8 0b 37 00 00       	call   80107ac5 <switchuvm>
801043ba:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
801043bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c0:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&c->scheduler, p->context);
801043c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ca:	8b 40 1c             	mov    0x1c(%eax),%eax
801043cd:	8b 55 e8             	mov    -0x18(%ebp),%edx
801043d0:	83 c2 04             	add    $0x4,%edx
801043d3:	83 ec 08             	sub    $0x8,%esp
801043d6:	50                   	push   %eax
801043d7:	52                   	push   %edx
801043d8:	e8 1a 0d 00 00       	call   801050f7 <swtch>
801043dd:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801043e0:	e8 c7 36 00 00       	call   80107aac <switchkvm>

        c->proc = 0;
801043e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043e8:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043ef:	00 00 00 
801043f2:	eb 01                	jmp    801043f5 <scheduler+0x236>
          continue;
801043f4:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801043f5:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801043fc:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80104403:	72 8c                	jb     80104391 <scheduler+0x1d2>
      }
    }
    release(&ptable.lock);
80104405:	83 ec 0c             	sub    $0xc,%esp
80104408:	68 00 42 19 80       	push   $0x80194200
8010440d:	e8 68 08 00 00       	call   80104c7a <release>
80104412:	83 c4 10             	add    $0x10,%esp
  for (;;) {
80104415:	e9 c0 fd ff ff       	jmp    801041da <scheduler+0x1b>

8010441a <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010441a:	55                   	push   %ebp
8010441b:	89 e5                	mov    %esp,%ebp
8010441d:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104420:	e8 39 f6 ff ff       	call   80103a5e <myproc>
80104425:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104428:	83 ec 0c             	sub    $0xc,%esp
8010442b:	68 00 42 19 80       	push   $0x80194200
80104430:	e8 12 09 00 00       	call   80104d47 <holding>
80104435:	83 c4 10             	add    $0x10,%esp
80104438:	85 c0                	test   %eax,%eax
8010443a:	75 0d                	jne    80104449 <sched+0x2f>
    panic("sched ptable.lock");
8010443c:	83 ec 0c             	sub    $0xc,%esp
8010443f:	68 cb a9 10 80       	push   $0x8010a9cb
80104444:	e8 60 c1 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104449:	e8 98 f5 ff ff       	call   801039e6 <mycpu>
8010444e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104454:	83 f8 01             	cmp    $0x1,%eax
80104457:	74 0d                	je     80104466 <sched+0x4c>
    panic("sched locks");
80104459:	83 ec 0c             	sub    $0xc,%esp
8010445c:	68 dd a9 10 80       	push   $0x8010a9dd
80104461:	e8 43 c1 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104469:	8b 40 0c             	mov    0xc(%eax),%eax
8010446c:	83 f8 04             	cmp    $0x4,%eax
8010446f:	75 0d                	jne    8010447e <sched+0x64>
    panic("sched running");
80104471:	83 ec 0c             	sub    $0xc,%esp
80104474:	68 e9 a9 10 80       	push   $0x8010a9e9
80104479:	e8 2b c1 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
8010447e:	e8 e5 f4 ff ff       	call   80103968 <readeflags>
80104483:	25 00 02 00 00       	and    $0x200,%eax
80104488:	85 c0                	test   %eax,%eax
8010448a:	74 0d                	je     80104499 <sched+0x7f>
    panic("sched interruptible");
8010448c:	83 ec 0c             	sub    $0xc,%esp
8010448f:	68 f7 a9 10 80       	push   $0x8010a9f7
80104494:	e8 10 c1 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104499:	e8 48 f5 ff ff       	call   801039e6 <mycpu>
8010449e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801044a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801044a7:	e8 3a f5 ff ff       	call   801039e6 <mycpu>
801044ac:	8b 40 04             	mov    0x4(%eax),%eax
801044af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044b2:	83 c2 1c             	add    $0x1c,%edx
801044b5:	83 ec 08             	sub    $0x8,%esp
801044b8:	50                   	push   %eax
801044b9:	52                   	push   %edx
801044ba:	e8 38 0c 00 00       	call   801050f7 <swtch>
801044bf:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801044c2:	e8 1f f5 ff ff       	call   801039e6 <mycpu>
801044c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044ca:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801044d0:	90                   	nop
801044d1:	c9                   	leave  
801044d2:	c3                   	ret    

801044d3 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801044d3:	55                   	push   %ebp
801044d4:	89 e5                	mov    %esp,%ebp
801044d6:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801044d9:	83 ec 0c             	sub    $0xc,%esp
801044dc:	68 00 42 19 80       	push   $0x80194200
801044e1:	e8 26 07 00 00       	call   80104c0c <acquire>
801044e6:	83 c4 10             	add    $0x10,%esp
  struct proc *curproc = myproc();
801044e9:	e8 70 f5 ff ff       	call   80103a5e <myproc>
801044ee:	89 45 f4             	mov    %eax,-0xc(%ebp)

  // MLFQ 정책일 경우 RUNNABLE 상태일 때 큐에 다시 넣기
  if (mycpu()->sched_policy == 1) {
801044f1:	e8 f0 f4 ff ff       	call   801039e6 <mycpu>
801044f6:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801044fc:	83 f8 01             	cmp    $0x1,%eax
801044ff:	75 20                	jne    80104521 <yield+0x4e>
    enqueue(&mlfq[curproc->priority], curproc);
80104501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104504:	8b 40 7c             	mov    0x7c(%eax),%eax
80104507:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
8010450d:	05 40 6a 19 80       	add    $0x80196a40,%eax
80104512:	83 ec 08             	sub    $0x8,%esp
80104515:	ff 75 f4             	push   -0xc(%ebp)
80104518:	50                   	push   %eax
80104519:	e8 52 02 00 00       	call   80104770 <enqueue>
8010451e:	83 c4 10             	add    $0x10,%esp
  }
  curproc->state = RUNNABLE;
80104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104524:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010452b:	e8 ea fe ff ff       	call   8010441a <sched>
  release(&ptable.lock);
80104530:	83 ec 0c             	sub    $0xc,%esp
80104533:	68 00 42 19 80       	push   $0x80194200
80104538:	e8 3d 07 00 00       	call   80104c7a <release>
8010453d:	83 c4 10             	add    $0x10,%esp
}
80104540:	90                   	nop
80104541:	c9                   	leave  
80104542:	c3                   	ret    

80104543 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104543:	55                   	push   %ebp
80104544:	89 e5                	mov    %esp,%ebp
80104546:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104549:	83 ec 0c             	sub    $0xc,%esp
8010454c:	68 00 42 19 80       	push   $0x80194200
80104551:	e8 24 07 00 00       	call   80104c7a <release>
80104556:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104559:	a1 04 f0 10 80       	mov    0x8010f004,%eax
8010455e:	85 c0                	test   %eax,%eax
80104560:	74 24                	je     80104586 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104562:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104569:	00 00 00 
    iinit(ROOTDEV);
8010456c:	83 ec 0c             	sub    $0xc,%esp
8010456f:	6a 01                	push   $0x1
80104571:	e8 02 d1 ff ff       	call   80101678 <iinit>
80104576:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104579:	83 ec 0c             	sub    $0xc,%esp
8010457c:	6a 01                	push   $0x1
8010457e:	e8 9a e8 ff ff       	call   80102e1d <initlog>
80104583:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104586:	90                   	nop
80104587:	c9                   	leave  
80104588:	c3                   	ret    

80104589 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104589:	55                   	push   %ebp
8010458a:	89 e5                	mov    %esp,%ebp
8010458c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010458f:	e8 ca f4 ff ff       	call   80103a5e <myproc>
80104594:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104597:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010459b:	75 0d                	jne    801045aa <sleep+0x21>
    panic("sleep");
8010459d:	83 ec 0c             	sub    $0xc,%esp
801045a0:	68 0b aa 10 80       	push   $0x8010aa0b
801045a5:	e8 ff bf ff ff       	call   801005a9 <panic>

  if(lk == 0)
801045aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801045ae:	75 0d                	jne    801045bd <sleep+0x34>
    panic("sleep without lk");
801045b0:	83 ec 0c             	sub    $0xc,%esp
801045b3:	68 11 aa 10 80       	push   $0x8010aa11
801045b8:	e8 ec bf ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801045bd:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801045c4:	74 1e                	je     801045e4 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801045c6:	83 ec 0c             	sub    $0xc,%esp
801045c9:	68 00 42 19 80       	push   $0x80194200
801045ce:	e8 39 06 00 00       	call   80104c0c <acquire>
801045d3:	83 c4 10             	add    $0x10,%esp
    release(lk);
801045d6:	83 ec 0c             	sub    $0xc,%esp
801045d9:	ff 75 0c             	push   0xc(%ebp)
801045dc:	e8 99 06 00 00       	call   80104c7a <release>
801045e1:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801045e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e7:	8b 55 08             	mov    0x8(%ebp),%edx
801045ea:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801045ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f0:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801045f7:	e8 1e fe ff ff       	call   8010441a <sched>

  // Tidy up.
  p->chan = 0;
801045fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ff:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104606:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010460d:	74 1e                	je     8010462d <sleep+0xa4>
    release(&ptable.lock);
8010460f:	83 ec 0c             	sub    $0xc,%esp
80104612:	68 00 42 19 80       	push   $0x80194200
80104617:	e8 5e 06 00 00       	call   80104c7a <release>
8010461c:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010461f:	83 ec 0c             	sub    $0xc,%esp
80104622:	ff 75 0c             	push   0xc(%ebp)
80104625:	e8 e2 05 00 00       	call   80104c0c <acquire>
8010462a:	83 c4 10             	add    $0x10,%esp
  }
}
8010462d:	90                   	nop
8010462e:	c9                   	leave  
8010462f:	c3                   	ret    

80104630 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104630:	55                   	push   %ebp
80104631:	89 e5                	mov    %esp,%ebp
80104633:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104636:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
8010463d:	eb 27                	jmp    80104666 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010463f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104642:	8b 40 0c             	mov    0xc(%eax),%eax
80104645:	83 f8 02             	cmp    $0x2,%eax
80104648:	75 15                	jne    8010465f <wakeup1+0x2f>
8010464a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010464d:	8b 40 20             	mov    0x20(%eax),%eax
80104650:	39 45 08             	cmp    %eax,0x8(%ebp)
80104653:	75 0a                	jne    8010465f <wakeup1+0x2f>
      p->state = RUNNABLE;
80104655:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104658:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010465f:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
80104666:	81 7d fc 34 6a 19 80 	cmpl   $0x80196a34,-0x4(%ebp)
8010466d:	72 d0                	jb     8010463f <wakeup1+0xf>
}
8010466f:	90                   	nop
80104670:	90                   	nop
80104671:	c9                   	leave  
80104672:	c3                   	ret    

80104673 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104673:	55                   	push   %ebp
80104674:	89 e5                	mov    %esp,%ebp
80104676:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104679:	83 ec 0c             	sub    $0xc,%esp
8010467c:	68 00 42 19 80       	push   $0x80194200
80104681:	e8 86 05 00 00       	call   80104c0c <acquire>
80104686:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104689:	83 ec 0c             	sub    $0xc,%esp
8010468c:	ff 75 08             	push   0x8(%ebp)
8010468f:	e8 9c ff ff ff       	call   80104630 <wakeup1>
80104694:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104697:	83 ec 0c             	sub    $0xc,%esp
8010469a:	68 00 42 19 80       	push   $0x80194200
8010469f:	e8 d6 05 00 00       	call   80104c7a <release>
801046a4:	83 c4 10             	add    $0x10,%esp
}
801046a7:	90                   	nop
801046a8:	c9                   	leave  
801046a9:	c3                   	ret    

801046aa <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801046aa:	55                   	push   %ebp
801046ab:	89 e5                	mov    %esp,%ebp
801046ad:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801046b0:	83 ec 0c             	sub    $0xc,%esp
801046b3:	68 00 42 19 80       	push   $0x80194200
801046b8:	e8 4f 05 00 00       	call   80104c0c <acquire>
801046bd:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046c0:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801046c7:	eb 48                	jmp    80104711 <kill+0x67>
    if(p->pid == pid){
801046c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cc:	8b 40 10             	mov    0x10(%eax),%eax
801046cf:	39 45 08             	cmp    %eax,0x8(%ebp)
801046d2:	75 36                	jne    8010470a <kill+0x60>
      p->killed = 1;
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801046de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e1:	8b 40 0c             	mov    0xc(%eax),%eax
801046e4:	83 f8 02             	cmp    $0x2,%eax
801046e7:	75 0a                	jne    801046f3 <kill+0x49>
        p->state = RUNNABLE;
801046e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ec:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801046f3:	83 ec 0c             	sub    $0xc,%esp
801046f6:	68 00 42 19 80       	push   $0x80194200
801046fb:	e8 7a 05 00 00       	call   80104c7a <release>
80104700:	83 c4 10             	add    $0x10,%esp
      return 0;
80104703:	b8 00 00 00 00       	mov    $0x0,%eax
80104708:	eb 25                	jmp    8010472f <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010470a:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104711:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80104718:	72 af                	jb     801046c9 <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010471a:	83 ec 0c             	sub    $0xc,%esp
8010471d:	68 00 42 19 80       	push   $0x80194200
80104722:	e8 53 05 00 00       	call   80104c7a <release>
80104727:	83 c4 10             	add    $0x10,%esp
  return -1;
8010472a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010472f:	c9                   	leave  
80104730:	c3                   	ret    

80104731 <initqueue>:
//큐 초기화
void initqueue(struct queue *q) {
80104731:	55                   	push   %ebp
80104732:	89 e5                	mov    %esp,%ebp
  q->front = 0;
80104734:	8b 45 08             	mov    0x8(%ebp),%eax
80104737:	c7 80 00 01 00 00 00 	movl   $0x0,0x100(%eax)
8010473e:	00 00 00 
  q->rear = 0;
80104741:	8b 45 08             	mov    0x8(%ebp),%eax
80104744:	c7 80 04 01 00 00 00 	movl   $0x0,0x104(%eax)
8010474b:	00 00 00 
}
8010474e:	90                   	nop
8010474f:	5d                   	pop    %ebp
80104750:	c3                   	ret    

80104751 <isempty>:

// 큐가 비었는지 확인
int isempty(struct queue *q) {
80104751:	55                   	push   %ebp
80104752:	89 e5                	mov    %esp,%ebp
  return q->front == q->rear;
80104754:	8b 45 08             	mov    0x8(%ebp),%eax
80104757:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
8010475d:	8b 45 08             	mov    0x8(%ebp),%eax
80104760:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104766:	39 c2                	cmp    %eax,%edx
80104768:	0f 94 c0             	sete   %al
8010476b:	0f b6 c0             	movzbl %al,%eax
}
8010476e:	5d                   	pop    %ebp
8010476f:	c3                   	ret    

80104770 <enqueue>:

// 큐에 중복없이 프로세스 추가
void enqueue(struct queue *q, struct proc *p) {
80104770:	55                   	push   %ebp
80104771:	89 e5                	mov    %esp,%ebp
80104773:	83 ec 10             	sub    $0x10,%esp
  //이미 들어있는지 검사
  for (int i = q->front; i < q->rear; i++) {
80104776:	8b 45 08             	mov    0x8(%ebp),%eax
80104779:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
8010477f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104782:	eb 1f                	jmp    801047a3 <enqueue+0x33>
    if (q->q[i % QUEUE_SIZE] == p)
80104784:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104787:	99                   	cltd   
80104788:	c1 ea 1a             	shr    $0x1a,%edx
8010478b:	01 d0                	add    %edx,%eax
8010478d:	83 e0 3f             	and    $0x3f,%eax
80104790:	29 d0                	sub    %edx,%eax
80104792:	89 c2                	mov    %eax,%edx
80104794:	8b 45 08             	mov    0x8(%ebp),%eax
80104797:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010479a:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010479d:	74 48                	je     801047e7 <enqueue+0x77>
  for (int i = q->front; i < q->rear; i++) {
8010479f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801047a3:	8b 45 08             	mov    0x8(%ebp),%eax
801047a6:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
801047ac:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801047af:	7c d3                	jl     80104784 <enqueue+0x14>
      return; //중복 방지
  }
  q->q[q->rear % QUEUE_SIZE] = p;
801047b1:	8b 45 08             	mov    0x8(%ebp),%eax
801047b4:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
801047ba:	99                   	cltd   
801047bb:	c1 ea 1a             	shr    $0x1a,%edx
801047be:	01 d0                	add    %edx,%eax
801047c0:	83 e0 3f             	and    $0x3f,%eax
801047c3:	29 d0                	sub    %edx,%eax
801047c5:	89 c1                	mov    %eax,%ecx
801047c7:	8b 45 08             	mov    0x8(%ebp),%eax
801047ca:	8b 55 0c             	mov    0xc(%ebp),%edx
801047cd:	89 14 88             	mov    %edx,(%eax,%ecx,4)
  q->rear++;
801047d0:	8b 45 08             	mov    0x8(%ebp),%eax
801047d3:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
801047d9:	8d 50 01             	lea    0x1(%eax),%edx
801047dc:	8b 45 08             	mov    0x8(%ebp),%eax
801047df:	89 90 04 01 00 00    	mov    %edx,0x104(%eax)
801047e5:	eb 01                	jmp    801047e8 <enqueue+0x78>
      return; //중복 방지
801047e7:	90                   	nop
}
801047e8:	c9                   	leave  
801047e9:	c3                   	ret    

801047ea <dequeue>:

// 큐에서 프로세스 꺼내기
struct proc* dequeue(struct queue *q) {
801047ea:	55                   	push   %ebp
801047eb:	89 e5                	mov    %esp,%ebp
801047ed:	83 ec 10             	sub    $0x10,%esp
  if (isempty(q))
801047f0:	ff 75 08             	push   0x8(%ebp)
801047f3:	e8 59 ff ff ff       	call   80104751 <isempty>
801047f8:	83 c4 04             	add    $0x4,%esp
801047fb:	85 c0                	test   %eax,%eax
801047fd:	74 07                	je     80104806 <dequeue+0x1c>
    return 0;
801047ff:	b8 00 00 00 00       	mov    $0x0,%eax
80104804:	eb 37                	jmp    8010483d <dequeue+0x53>
  struct proc *p = q->q[q->front % QUEUE_SIZE];
80104806:	8b 45 08             	mov    0x8(%ebp),%eax
80104809:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
8010480f:	99                   	cltd   
80104810:	c1 ea 1a             	shr    $0x1a,%edx
80104813:	01 d0                	add    %edx,%eax
80104815:	83 e0 3f             	and    $0x3f,%eax
80104818:	29 d0                	sub    %edx,%eax
8010481a:	89 c2                	mov    %eax,%edx
8010481c:	8b 45 08             	mov    0x8(%ebp),%eax
8010481f:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104822:	89 45 fc             	mov    %eax,-0x4(%ebp)
  q->front++;
80104825:	8b 45 08             	mov    0x8(%ebp),%eax
80104828:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
8010482e:	8d 50 01             	lea    0x1(%eax),%edx
80104831:	8b 45 08             	mov    0x8(%ebp),%eax
80104834:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
  return p;
8010483a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010483d:	c9                   	leave  
8010483e:	c3                   	ret    

8010483f <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010483f:	55                   	push   %ebp
80104840:	89 e5                	mov    %esp,%ebp
80104842:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104845:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
8010484c:	e9 da 00 00 00       	jmp    8010492b <procdump+0xec>
    if(p->state == UNUSED)
80104851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104854:	8b 40 0c             	mov    0xc(%eax),%eax
80104857:	85 c0                	test   %eax,%eax
80104859:	0f 84 c4 00 00 00    	je     80104923 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010485f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104862:	8b 40 0c             	mov    0xc(%eax),%eax
80104865:	83 f8 05             	cmp    $0x5,%eax
80104868:	77 23                	ja     8010488d <procdump+0x4e>
8010486a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010486d:	8b 40 0c             	mov    0xc(%eax),%eax
80104870:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104877:	85 c0                	test   %eax,%eax
80104879:	74 12                	je     8010488d <procdump+0x4e>
      state = states[p->state];
8010487b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010487e:	8b 40 0c             	mov    0xc(%eax),%eax
80104881:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104888:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010488b:	eb 07                	jmp    80104894 <procdump+0x55>
    else
      state = "???";
8010488d:	c7 45 ec 22 aa 10 80 	movl   $0x8010aa22,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104894:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104897:	8d 50 6c             	lea    0x6c(%eax),%edx
8010489a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010489d:	8b 40 10             	mov    0x10(%eax),%eax
801048a0:	52                   	push   %edx
801048a1:	ff 75 ec             	push   -0x14(%ebp)
801048a4:	50                   	push   %eax
801048a5:	68 26 aa 10 80       	push   $0x8010aa26
801048aa:	e8 45 bb ff ff       	call   801003f4 <cprintf>
801048af:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801048b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b5:	8b 40 0c             	mov    0xc(%eax),%eax
801048b8:	83 f8 02             	cmp    $0x2,%eax
801048bb:	75 54                	jne    80104911 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801048bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048c0:	8b 40 1c             	mov    0x1c(%eax),%eax
801048c3:	8b 40 0c             	mov    0xc(%eax),%eax
801048c6:	83 c0 08             	add    $0x8,%eax
801048c9:	89 c2                	mov    %eax,%edx
801048cb:	83 ec 08             	sub    $0x8,%esp
801048ce:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801048d1:	50                   	push   %eax
801048d2:	52                   	push   %edx
801048d3:	e8 f4 03 00 00       	call   80104ccc <getcallerpcs>
801048d8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801048e2:	eb 1c                	jmp    80104900 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801048e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801048eb:	83 ec 08             	sub    $0x8,%esp
801048ee:	50                   	push   %eax
801048ef:	68 2f aa 10 80       	push   $0x8010aa2f
801048f4:	e8 fb ba ff ff       	call   801003f4 <cprintf>
801048f9:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104900:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104904:	7f 0b                	jg     80104911 <procdump+0xd2>
80104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104909:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010490d:	85 c0                	test   %eax,%eax
8010490f:	75 d3                	jne    801048e4 <procdump+0xa5>
    }
    cprintf("\n");
80104911:	83 ec 0c             	sub    $0xc,%esp
80104914:	68 33 aa 10 80       	push   $0x8010aa33
80104919:	e8 d6 ba ff ff       	call   801003f4 <cprintf>
8010491e:	83 c4 10             	add    $0x10,%esp
80104921:	eb 01                	jmp    80104924 <procdump+0xe5>
      continue;
80104923:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104924:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
8010492b:	81 7d f0 34 6a 19 80 	cmpl   $0x80196a34,-0x10(%ebp)
80104932:	0f 82 19 ff ff ff    	jb     80104851 <procdump+0x12>
  }
}
80104938:	90                   	nop
80104939:	90                   	nop
8010493a:	c9                   	leave  
8010493b:	c3                   	ret    

8010493c <setSchedPolicy>:
//추가
int
setSchedPolicy(int policy)
{
8010493c:	55                   	push   %ebp
8010493d:	89 e5                	mov    %esp,%ebp
8010493f:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)  // 정책 번호 범위 확인
80104942:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104946:	78 06                	js     8010494e <setSchedPolicy+0x12>
80104948:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
8010494c:	7e 07                	jle    80104955 <setSchedPolicy+0x19>
    return -1;
8010494e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104953:	eb 1d                	jmp    80104972 <setSchedPolicy+0x36>
  
  pushcli(); //인터럽트 끄기
80104955:	e8 1d 04 00 00       	call   80104d77 <pushcli>
  mycpu()->sched_policy = policy;
8010495a:	e8 87 f0 ff ff       	call   801039e6 <mycpu>
8010495f:	8b 55 08             	mov    0x8(%ebp),%edx
80104962:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli(); //인터럽트 켜기
80104968:	e8 57 04 00 00       	call   80104dc4 <popcli>
  return 0;
8010496d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104972:	c9                   	leave  
80104973:	c3                   	ret    

80104974 <getpinfo>:


int
getpinfo(struct pstat *ps)
{
80104974:	55                   	push   %ebp
80104975:	89 e5                	mov    %esp,%ebp
80104977:	53                   	push   %ebx
80104978:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010497b:	83 ec 0c             	sub    $0xc,%esp
8010497e:	68 00 42 19 80       	push   $0x80194200
80104983:	e8 84 02 00 00       	call   80104c0c <acquire>
80104988:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROC; i++) {
8010498b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104992:	e9 d2 00 00 00       	jmp    80104a69 <getpinfo+0xf5>
    p = &ptable.proc[i];
80104997:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010499a:	89 d0                	mov    %edx,%eax
8010499c:	c1 e0 02             	shl    $0x2,%eax
8010499f:	01 d0                	add    %edx,%eax
801049a1:	c1 e0 05             	shl    $0x5,%eax
801049a4:	83 c0 30             	add    $0x30,%eax
801049a7:	05 00 42 19 80       	add    $0x80194200,%eax
801049ac:	83 c0 04             	add    $0x4,%eax
801049af:	89 45 ec             	mov    %eax,-0x14(%ebp)

    ps->inuse[i] = (p->state != UNUSED);
801049b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049b5:	8b 40 0c             	mov    0xc(%eax),%eax
801049b8:	85 c0                	test   %eax,%eax
801049ba:	0f 95 c0             	setne  %al
801049bd:	0f b6 c8             	movzbl %al,%ecx
801049c0:	8b 45 08             	mov    0x8(%ebp),%eax
801049c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049c6:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
801049c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049cc:	8b 50 10             	mov    0x10(%eax),%edx
801049cf:	8b 45 08             	mov    0x8(%ebp),%eax
801049d2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049d5:	83 c1 40             	add    $0x40,%ecx
801049d8:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = p->priority;
801049db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049de:	8b 50 7c             	mov    0x7c(%eax),%edx
801049e1:	8b 45 08             	mov    0x8(%ebp),%eax
801049e4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049e7:	83 e9 80             	sub    $0xffffff80,%ecx
801049ea:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
801049ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f0:	8b 40 0c             	mov    0xc(%eax),%eax
801049f3:	89 c1                	mov    %eax,%ecx
801049f5:	8b 45 08             	mov    0x8(%ebp),%eax
801049f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049fb:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80104a01:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < MLFQ_LEVELS; j++) {
80104a04:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a0b:	eb 52                	jmp    80104a5f <getpinfo+0xeb>
      ps->ticks[i][j] = p->ticks[j];
80104a0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a10:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a13:	83 c2 20             	add    $0x20,%edx
80104a16:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104a19:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a1f:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104a26:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a29:	01 d9                	add    %ebx,%ecx
80104a2b:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104a31:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
80104a34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a37:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a3a:	83 c2 24             	add    $0x24,%edx
80104a3d:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104a40:	8b 45 08             	mov    0x8(%ebp),%eax
80104a43:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a46:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104a4d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a50:	01 d9                	add    %ebx,%ecx
80104a52:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104a58:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < MLFQ_LEVELS; j++) {
80104a5b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a5f:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104a63:	7e a8                	jle    80104a0d <getpinfo+0x99>
  for (int i = 0; i < NPROC; i++) {
80104a65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a69:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104a6d:	0f 8e 24 ff ff ff    	jle    80104997 <getpinfo+0x23>
    }
  }

  release(&ptable.lock);
80104a73:	83 ec 0c             	sub    $0xc,%esp
80104a76:	68 00 42 19 80       	push   $0x80194200
80104a7b:	e8 fa 01 00 00       	call   80104c7a <release>
80104a80:	83 c4 10             	add    $0x10,%esp
  return 0;
80104a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a8b:	c9                   	leave  
80104a8c:	c3                   	ret    

80104a8d <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a8d:	55                   	push   %ebp
80104a8e:	89 e5                	mov    %esp,%ebp
80104a90:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a93:	8b 45 08             	mov    0x8(%ebp),%eax
80104a96:	83 c0 04             	add    $0x4,%eax
80104a99:	83 ec 08             	sub    $0x8,%esp
80104a9c:	68 5f aa 10 80       	push   $0x8010aa5f
80104aa1:	50                   	push   %eax
80104aa2:	e8 43 01 00 00       	call   80104bea <initlock>
80104aa7:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80104aad:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ab0:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104abc:	8b 45 08             	mov    0x8(%ebp),%eax
80104abf:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104ac6:	90                   	nop
80104ac7:	c9                   	leave  
80104ac8:	c3                   	ret    

80104ac9 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104ac9:	55                   	push   %ebp
80104aca:	89 e5                	mov    %esp,%ebp
80104acc:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104acf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad2:	83 c0 04             	add    $0x4,%eax
80104ad5:	83 ec 0c             	sub    $0xc,%esp
80104ad8:	50                   	push   %eax
80104ad9:	e8 2e 01 00 00       	call   80104c0c <acquire>
80104ade:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ae1:	eb 15                	jmp    80104af8 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae6:	83 c0 04             	add    $0x4,%eax
80104ae9:	83 ec 08             	sub    $0x8,%esp
80104aec:	50                   	push   %eax
80104aed:	ff 75 08             	push   0x8(%ebp)
80104af0:	e8 94 fa ff ff       	call   80104589 <sleep>
80104af5:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104af8:	8b 45 08             	mov    0x8(%ebp),%eax
80104afb:	8b 00                	mov    (%eax),%eax
80104afd:	85 c0                	test   %eax,%eax
80104aff:	75 e2                	jne    80104ae3 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104b01:	8b 45 08             	mov    0x8(%ebp),%eax
80104b04:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104b0a:	e8 4f ef ff ff       	call   80103a5e <myproc>
80104b0f:	8b 50 10             	mov    0x10(%eax),%edx
80104b12:	8b 45 08             	mov    0x8(%ebp),%eax
80104b15:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104b18:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1b:	83 c0 04             	add    $0x4,%eax
80104b1e:	83 ec 0c             	sub    $0xc,%esp
80104b21:	50                   	push   %eax
80104b22:	e8 53 01 00 00       	call   80104c7a <release>
80104b27:	83 c4 10             	add    $0x10,%esp
}
80104b2a:	90                   	nop
80104b2b:	c9                   	leave  
80104b2c:	c3                   	ret    

80104b2d <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104b2d:	55                   	push   %ebp
80104b2e:	89 e5                	mov    %esp,%ebp
80104b30:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104b33:	8b 45 08             	mov    0x8(%ebp),%eax
80104b36:	83 c0 04             	add    $0x4,%eax
80104b39:	83 ec 0c             	sub    $0xc,%esp
80104b3c:	50                   	push   %eax
80104b3d:	e8 ca 00 00 00       	call   80104c0c <acquire>
80104b42:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104b45:	8b 45 08             	mov    0x8(%ebp),%eax
80104b48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b51:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104b58:	83 ec 0c             	sub    $0xc,%esp
80104b5b:	ff 75 08             	push   0x8(%ebp)
80104b5e:	e8 10 fb ff ff       	call   80104673 <wakeup>
80104b63:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104b66:	8b 45 08             	mov    0x8(%ebp),%eax
80104b69:	83 c0 04             	add    $0x4,%eax
80104b6c:	83 ec 0c             	sub    $0xc,%esp
80104b6f:	50                   	push   %eax
80104b70:	e8 05 01 00 00       	call   80104c7a <release>
80104b75:	83 c4 10             	add    $0x10,%esp
}
80104b78:	90                   	nop
80104b79:	c9                   	leave  
80104b7a:	c3                   	ret    

80104b7b <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104b7b:	55                   	push   %ebp
80104b7c:	89 e5                	mov    %esp,%ebp
80104b7e:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104b81:	8b 45 08             	mov    0x8(%ebp),%eax
80104b84:	83 c0 04             	add    $0x4,%eax
80104b87:	83 ec 0c             	sub    $0xc,%esp
80104b8a:	50                   	push   %eax
80104b8b:	e8 7c 00 00 00       	call   80104c0c <acquire>
80104b90:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b93:	8b 45 08             	mov    0x8(%ebp),%eax
80104b96:	8b 00                	mov    (%eax),%eax
80104b98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b9e:	83 c0 04             	add    $0x4,%eax
80104ba1:	83 ec 0c             	sub    $0xc,%esp
80104ba4:	50                   	push   %eax
80104ba5:	e8 d0 00 00 00       	call   80104c7a <release>
80104baa:	83 c4 10             	add    $0x10,%esp
  return r;
80104bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104bb0:	c9                   	leave  
80104bb1:	c3                   	ret    

80104bb2 <readeflags>:
{
80104bb2:	55                   	push   %ebp
80104bb3:	89 e5                	mov    %esp,%ebp
80104bb5:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104bb8:	9c                   	pushf  
80104bb9:	58                   	pop    %eax
80104bba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104bbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bc0:	c9                   	leave  
80104bc1:	c3                   	ret    

80104bc2 <cli>:
{
80104bc2:	55                   	push   %ebp
80104bc3:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104bc5:	fa                   	cli    
}
80104bc6:	90                   	nop
80104bc7:	5d                   	pop    %ebp
80104bc8:	c3                   	ret    

80104bc9 <sti>:
{
80104bc9:	55                   	push   %ebp
80104bca:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104bcc:	fb                   	sti    
}
80104bcd:	90                   	nop
80104bce:	5d                   	pop    %ebp
80104bcf:	c3                   	ret    

80104bd0 <xchg>:
{
80104bd0:	55                   	push   %ebp
80104bd1:	89 e5                	mov    %esp,%ebp
80104bd3:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104bd6:	8b 55 08             	mov    0x8(%ebp),%edx
80104bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bdf:	f0 87 02             	lock xchg %eax,(%edx)
80104be2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104be5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104be8:	c9                   	leave  
80104be9:	c3                   	ret    

80104bea <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104bea:	55                   	push   %ebp
80104beb:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104bed:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf0:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bf3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104bff:	8b 45 08             	mov    0x8(%ebp),%eax
80104c02:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104c09:	90                   	nop
80104c0a:	5d                   	pop    %ebp
80104c0b:	c3                   	ret    

80104c0c <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104c0c:	55                   	push   %ebp
80104c0d:	89 e5                	mov    %esp,%ebp
80104c0f:	53                   	push   %ebx
80104c10:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104c13:	e8 5f 01 00 00       	call   80104d77 <pushcli>
  if(holding(lk)){
80104c18:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1b:	83 ec 0c             	sub    $0xc,%esp
80104c1e:	50                   	push   %eax
80104c1f:	e8 23 01 00 00       	call   80104d47 <holding>
80104c24:	83 c4 10             	add    $0x10,%esp
80104c27:	85 c0                	test   %eax,%eax
80104c29:	74 0d                	je     80104c38 <acquire+0x2c>
    panic("acquire");
80104c2b:	83 ec 0c             	sub    $0xc,%esp
80104c2e:	68 6a aa 10 80       	push   $0x8010aa6a
80104c33:	e8 71 b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104c38:	90                   	nop
80104c39:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3c:	83 ec 08             	sub    $0x8,%esp
80104c3f:	6a 01                	push   $0x1
80104c41:	50                   	push   %eax
80104c42:	e8 89 ff ff ff       	call   80104bd0 <xchg>
80104c47:	83 c4 10             	add    $0x10,%esp
80104c4a:	85 c0                	test   %eax,%eax
80104c4c:	75 eb                	jne    80104c39 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104c4e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104c53:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104c56:	e8 8b ed ff ff       	call   801039e6 <mycpu>
80104c5b:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c61:	83 c0 0c             	add    $0xc,%eax
80104c64:	83 ec 08             	sub    $0x8,%esp
80104c67:	50                   	push   %eax
80104c68:	8d 45 08             	lea    0x8(%ebp),%eax
80104c6b:	50                   	push   %eax
80104c6c:	e8 5b 00 00 00       	call   80104ccc <getcallerpcs>
80104c71:	83 c4 10             	add    $0x10,%esp
}
80104c74:	90                   	nop
80104c75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c78:	c9                   	leave  
80104c79:	c3                   	ret    

80104c7a <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c7a:	55                   	push   %ebp
80104c7b:	89 e5                	mov    %esp,%ebp
80104c7d:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c80:	83 ec 0c             	sub    $0xc,%esp
80104c83:	ff 75 08             	push   0x8(%ebp)
80104c86:	e8 bc 00 00 00       	call   80104d47 <holding>
80104c8b:	83 c4 10             	add    $0x10,%esp
80104c8e:	85 c0                	test   %eax,%eax
80104c90:	75 0d                	jne    80104c9f <release+0x25>
    panic("release");
80104c92:	83 ec 0c             	sub    $0xc,%esp
80104c95:	68 72 aa 10 80       	push   $0x8010aa72
80104c9a:	e8 0a b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80104cac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104cb3:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104cb8:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbb:	8b 55 08             	mov    0x8(%ebp),%edx
80104cbe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104cc4:	e8 fb 00 00 00       	call   80104dc4 <popcli>
}
80104cc9:	90                   	nop
80104cca:	c9                   	leave  
80104ccb:	c3                   	ret    

80104ccc <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104ccc:	55                   	push   %ebp
80104ccd:	89 e5                	mov    %esp,%ebp
80104ccf:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd5:	83 e8 08             	sub    $0x8,%eax
80104cd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104cdb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104ce2:	eb 38                	jmp    80104d1c <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104ce4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104ce8:	74 53                	je     80104d3d <getcallerpcs+0x71>
80104cea:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104cf1:	76 4a                	jbe    80104d3d <getcallerpcs+0x71>
80104cf3:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104cf7:	74 44                	je     80104d3d <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104cf9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cfc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d03:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d06:	01 c2                	add    %eax,%edx
80104d08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d0b:	8b 40 04             	mov    0x4(%eax),%eax
80104d0e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104d10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d13:	8b 00                	mov    (%eax),%eax
80104d15:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104d18:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104d1c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d20:	7e c2                	jle    80104ce4 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104d22:	eb 19                	jmp    80104d3d <getcallerpcs+0x71>
    pcs[i] = 0;
80104d24:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d31:	01 d0                	add    %edx,%eax
80104d33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104d39:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104d3d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d41:	7e e1                	jle    80104d24 <getcallerpcs+0x58>
}
80104d43:	90                   	nop
80104d44:	90                   	nop
80104d45:	c9                   	leave  
80104d46:	c3                   	ret    

80104d47 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104d47:	55                   	push   %ebp
80104d48:	89 e5                	mov    %esp,%ebp
80104d4a:	53                   	push   %ebx
80104d4b:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d51:	8b 00                	mov    (%eax),%eax
80104d53:	85 c0                	test   %eax,%eax
80104d55:	74 16                	je     80104d6d <holding+0x26>
80104d57:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5a:	8b 58 08             	mov    0x8(%eax),%ebx
80104d5d:	e8 84 ec ff ff       	call   801039e6 <mycpu>
80104d62:	39 c3                	cmp    %eax,%ebx
80104d64:	75 07                	jne    80104d6d <holding+0x26>
80104d66:	b8 01 00 00 00       	mov    $0x1,%eax
80104d6b:	eb 05                	jmp    80104d72 <holding+0x2b>
80104d6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d75:	c9                   	leave  
80104d76:	c3                   	ret    

80104d77 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d77:	55                   	push   %ebp
80104d78:	89 e5                	mov    %esp,%ebp
80104d7a:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104d7d:	e8 30 fe ff ff       	call   80104bb2 <readeflags>
80104d82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d85:	e8 38 fe ff ff       	call   80104bc2 <cli>
  if(mycpu()->ncli == 0)
80104d8a:	e8 57 ec ff ff       	call   801039e6 <mycpu>
80104d8f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d95:	85 c0                	test   %eax,%eax
80104d97:	75 14                	jne    80104dad <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d99:	e8 48 ec ff ff       	call   801039e6 <mycpu>
80104d9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104da1:	81 e2 00 02 00 00    	and    $0x200,%edx
80104da7:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104dad:	e8 34 ec ff ff       	call   801039e6 <mycpu>
80104db2:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104db8:	83 c2 01             	add    $0x1,%edx
80104dbb:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104dc1:	90                   	nop
80104dc2:	c9                   	leave  
80104dc3:	c3                   	ret    

80104dc4 <popcli>:

void
popcli(void)
{
80104dc4:	55                   	push   %ebp
80104dc5:	89 e5                	mov    %esp,%ebp
80104dc7:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104dca:	e8 e3 fd ff ff       	call   80104bb2 <readeflags>
80104dcf:	25 00 02 00 00       	and    $0x200,%eax
80104dd4:	85 c0                	test   %eax,%eax
80104dd6:	74 0d                	je     80104de5 <popcli+0x21>
    panic("popcli - interruptible");
80104dd8:	83 ec 0c             	sub    $0xc,%esp
80104ddb:	68 7a aa 10 80       	push   $0x8010aa7a
80104de0:	e8 c4 b7 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104de5:	e8 fc eb ff ff       	call   801039e6 <mycpu>
80104dea:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104df0:	83 ea 01             	sub    $0x1,%edx
80104df3:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104df9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104dff:	85 c0                	test   %eax,%eax
80104e01:	79 0d                	jns    80104e10 <popcli+0x4c>
    panic("popcli");
80104e03:	83 ec 0c             	sub    $0xc,%esp
80104e06:	68 91 aa 10 80       	push   $0x8010aa91
80104e0b:	e8 99 b7 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104e10:	e8 d1 eb ff ff       	call   801039e6 <mycpu>
80104e15:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104e1b:	85 c0                	test   %eax,%eax
80104e1d:	75 14                	jne    80104e33 <popcli+0x6f>
80104e1f:	e8 c2 eb ff ff       	call   801039e6 <mycpu>
80104e24:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e2a:	85 c0                	test   %eax,%eax
80104e2c:	74 05                	je     80104e33 <popcli+0x6f>
    sti();
80104e2e:	e8 96 fd ff ff       	call   80104bc9 <sti>
}
80104e33:	90                   	nop
80104e34:	c9                   	leave  
80104e35:	c3                   	ret    

80104e36 <stosb>:
{
80104e36:	55                   	push   %ebp
80104e37:	89 e5                	mov    %esp,%ebp
80104e39:	57                   	push   %edi
80104e3a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e3e:	8b 55 10             	mov    0x10(%ebp),%edx
80104e41:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e44:	89 cb                	mov    %ecx,%ebx
80104e46:	89 df                	mov    %ebx,%edi
80104e48:	89 d1                	mov    %edx,%ecx
80104e4a:	fc                   	cld    
80104e4b:	f3 aa                	rep stos %al,%es:(%edi)
80104e4d:	89 ca                	mov    %ecx,%edx
80104e4f:	89 fb                	mov    %edi,%ebx
80104e51:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e54:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e57:	90                   	nop
80104e58:	5b                   	pop    %ebx
80104e59:	5f                   	pop    %edi
80104e5a:	5d                   	pop    %ebp
80104e5b:	c3                   	ret    

80104e5c <stosl>:
{
80104e5c:	55                   	push   %ebp
80104e5d:	89 e5                	mov    %esp,%ebp
80104e5f:	57                   	push   %edi
80104e60:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104e61:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e64:	8b 55 10             	mov    0x10(%ebp),%edx
80104e67:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e6a:	89 cb                	mov    %ecx,%ebx
80104e6c:	89 df                	mov    %ebx,%edi
80104e6e:	89 d1                	mov    %edx,%ecx
80104e70:	fc                   	cld    
80104e71:	f3 ab                	rep stos %eax,%es:(%edi)
80104e73:	89 ca                	mov    %ecx,%edx
80104e75:	89 fb                	mov    %edi,%ebx
80104e77:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e7a:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e7d:	90                   	nop
80104e7e:	5b                   	pop    %ebx
80104e7f:	5f                   	pop    %edi
80104e80:	5d                   	pop    %ebp
80104e81:	c3                   	ret    

80104e82 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e82:	55                   	push   %ebp
80104e83:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e85:	8b 45 08             	mov    0x8(%ebp),%eax
80104e88:	83 e0 03             	and    $0x3,%eax
80104e8b:	85 c0                	test   %eax,%eax
80104e8d:	75 43                	jne    80104ed2 <memset+0x50>
80104e8f:	8b 45 10             	mov    0x10(%ebp),%eax
80104e92:	83 e0 03             	and    $0x3,%eax
80104e95:	85 c0                	test   %eax,%eax
80104e97:	75 39                	jne    80104ed2 <memset+0x50>
    c &= 0xFF;
80104e99:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104ea0:	8b 45 10             	mov    0x10(%ebp),%eax
80104ea3:	c1 e8 02             	shr    $0x2,%eax
80104ea6:	89 c2                	mov    %eax,%edx
80104ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eab:	c1 e0 18             	shl    $0x18,%eax
80104eae:	89 c1                	mov    %eax,%ecx
80104eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eb3:	c1 e0 10             	shl    $0x10,%eax
80104eb6:	09 c1                	or     %eax,%ecx
80104eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ebb:	c1 e0 08             	shl    $0x8,%eax
80104ebe:	09 c8                	or     %ecx,%eax
80104ec0:	0b 45 0c             	or     0xc(%ebp),%eax
80104ec3:	52                   	push   %edx
80104ec4:	50                   	push   %eax
80104ec5:	ff 75 08             	push   0x8(%ebp)
80104ec8:	e8 8f ff ff ff       	call   80104e5c <stosl>
80104ecd:	83 c4 0c             	add    $0xc,%esp
80104ed0:	eb 12                	jmp    80104ee4 <memset+0x62>
  } else
    stosb(dst, c, n);
80104ed2:	8b 45 10             	mov    0x10(%ebp),%eax
80104ed5:	50                   	push   %eax
80104ed6:	ff 75 0c             	push   0xc(%ebp)
80104ed9:	ff 75 08             	push   0x8(%ebp)
80104edc:	e8 55 ff ff ff       	call   80104e36 <stosb>
80104ee1:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104ee4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ee7:	c9                   	leave  
80104ee8:	c3                   	ret    

80104ee9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104ee9:	55                   	push   %ebp
80104eea:	89 e5                	mov    %esp,%ebp
80104eec:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104eef:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ef8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104efb:	eb 30                	jmp    80104f2d <memcmp+0x44>
    if(*s1 != *s2)
80104efd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f00:	0f b6 10             	movzbl (%eax),%edx
80104f03:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f06:	0f b6 00             	movzbl (%eax),%eax
80104f09:	38 c2                	cmp    %al,%dl
80104f0b:	74 18                	je     80104f25 <memcmp+0x3c>
      return *s1 - *s2;
80104f0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f10:	0f b6 00             	movzbl (%eax),%eax
80104f13:	0f b6 d0             	movzbl %al,%edx
80104f16:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f19:	0f b6 00             	movzbl (%eax),%eax
80104f1c:	0f b6 c8             	movzbl %al,%ecx
80104f1f:	89 d0                	mov    %edx,%eax
80104f21:	29 c8                	sub    %ecx,%eax
80104f23:	eb 1a                	jmp    80104f3f <memcmp+0x56>
    s1++, s2++;
80104f25:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f29:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104f2d:	8b 45 10             	mov    0x10(%ebp),%eax
80104f30:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f33:	89 55 10             	mov    %edx,0x10(%ebp)
80104f36:	85 c0                	test   %eax,%eax
80104f38:	75 c3                	jne    80104efd <memcmp+0x14>
  }

  return 0;
80104f3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f3f:	c9                   	leave  
80104f40:	c3                   	ret    

80104f41 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104f41:	55                   	push   %ebp
80104f42:	89 e5                	mov    %esp,%ebp
80104f44:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104f47:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f4a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f50:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104f53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f56:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104f59:	73 54                	jae    80104faf <memmove+0x6e>
80104f5b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f5e:	8b 45 10             	mov    0x10(%ebp),%eax
80104f61:	01 d0                	add    %edx,%eax
80104f63:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104f66:	73 47                	jae    80104faf <memmove+0x6e>
    s += n;
80104f68:	8b 45 10             	mov    0x10(%ebp),%eax
80104f6b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104f6e:	8b 45 10             	mov    0x10(%ebp),%eax
80104f71:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f74:	eb 13                	jmp    80104f89 <memmove+0x48>
      *--d = *--s;
80104f76:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f7a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f81:	0f b6 10             	movzbl (%eax),%edx
80104f84:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f87:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f89:	8b 45 10             	mov    0x10(%ebp),%eax
80104f8c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f8f:	89 55 10             	mov    %edx,0x10(%ebp)
80104f92:	85 c0                	test   %eax,%eax
80104f94:	75 e0                	jne    80104f76 <memmove+0x35>
  if(s < d && s + n > d){
80104f96:	eb 24                	jmp    80104fbc <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f98:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f9b:	8d 42 01             	lea    0x1(%edx),%eax
80104f9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104fa1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fa4:	8d 48 01             	lea    0x1(%eax),%ecx
80104fa7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104faa:	0f b6 12             	movzbl (%edx),%edx
80104fad:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104faf:	8b 45 10             	mov    0x10(%ebp),%eax
80104fb2:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fb5:	89 55 10             	mov    %edx,0x10(%ebp)
80104fb8:	85 c0                	test   %eax,%eax
80104fba:	75 dc                	jne    80104f98 <memmove+0x57>

  return dst;
80104fbc:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104fbf:	c9                   	leave  
80104fc0:	c3                   	ret    

80104fc1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104fc1:	55                   	push   %ebp
80104fc2:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104fc4:	ff 75 10             	push   0x10(%ebp)
80104fc7:	ff 75 0c             	push   0xc(%ebp)
80104fca:	ff 75 08             	push   0x8(%ebp)
80104fcd:	e8 6f ff ff ff       	call   80104f41 <memmove>
80104fd2:	83 c4 0c             	add    $0xc,%esp
}
80104fd5:	c9                   	leave  
80104fd6:	c3                   	ret    

80104fd7 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104fd7:	55                   	push   %ebp
80104fd8:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104fda:	eb 0c                	jmp    80104fe8 <strncmp+0x11>
    n--, p++, q++;
80104fdc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fe0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104fe4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104fe8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fec:	74 1a                	je     80105008 <strncmp+0x31>
80104fee:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff1:	0f b6 00             	movzbl (%eax),%eax
80104ff4:	84 c0                	test   %al,%al
80104ff6:	74 10                	je     80105008 <strncmp+0x31>
80104ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ffb:	0f b6 10             	movzbl (%eax),%edx
80104ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105001:	0f b6 00             	movzbl (%eax),%eax
80105004:	38 c2                	cmp    %al,%dl
80105006:	74 d4                	je     80104fdc <strncmp+0x5>
  if(n == 0)
80105008:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010500c:	75 07                	jne    80105015 <strncmp+0x3e>
    return 0;
8010500e:	b8 00 00 00 00       	mov    $0x0,%eax
80105013:	eb 16                	jmp    8010502b <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105015:	8b 45 08             	mov    0x8(%ebp),%eax
80105018:	0f b6 00             	movzbl (%eax),%eax
8010501b:	0f b6 d0             	movzbl %al,%edx
8010501e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105021:	0f b6 00             	movzbl (%eax),%eax
80105024:	0f b6 c8             	movzbl %al,%ecx
80105027:	89 d0                	mov    %edx,%eax
80105029:	29 c8                	sub    %ecx,%eax
}
8010502b:	5d                   	pop    %ebp
8010502c:	c3                   	ret    

8010502d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010502d:	55                   	push   %ebp
8010502e:	89 e5                	mov    %esp,%ebp
80105030:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105033:	8b 45 08             	mov    0x8(%ebp),%eax
80105036:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105039:	90                   	nop
8010503a:	8b 45 10             	mov    0x10(%ebp),%eax
8010503d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105040:	89 55 10             	mov    %edx,0x10(%ebp)
80105043:	85 c0                	test   %eax,%eax
80105045:	7e 2c                	jle    80105073 <strncpy+0x46>
80105047:	8b 55 0c             	mov    0xc(%ebp),%edx
8010504a:	8d 42 01             	lea    0x1(%edx),%eax
8010504d:	89 45 0c             	mov    %eax,0xc(%ebp)
80105050:	8b 45 08             	mov    0x8(%ebp),%eax
80105053:	8d 48 01             	lea    0x1(%eax),%ecx
80105056:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105059:	0f b6 12             	movzbl (%edx),%edx
8010505c:	88 10                	mov    %dl,(%eax)
8010505e:	0f b6 00             	movzbl (%eax),%eax
80105061:	84 c0                	test   %al,%al
80105063:	75 d5                	jne    8010503a <strncpy+0xd>
    ;
  while(n-- > 0)
80105065:	eb 0c                	jmp    80105073 <strncpy+0x46>
    *s++ = 0;
80105067:	8b 45 08             	mov    0x8(%ebp),%eax
8010506a:	8d 50 01             	lea    0x1(%eax),%edx
8010506d:	89 55 08             	mov    %edx,0x8(%ebp)
80105070:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105073:	8b 45 10             	mov    0x10(%ebp),%eax
80105076:	8d 50 ff             	lea    -0x1(%eax),%edx
80105079:	89 55 10             	mov    %edx,0x10(%ebp)
8010507c:	85 c0                	test   %eax,%eax
8010507e:	7f e7                	jg     80105067 <strncpy+0x3a>
  return os;
80105080:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105083:	c9                   	leave  
80105084:	c3                   	ret    

80105085 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105085:	55                   	push   %ebp
80105086:	89 e5                	mov    %esp,%ebp
80105088:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010508b:	8b 45 08             	mov    0x8(%ebp),%eax
8010508e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105091:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105095:	7f 05                	jg     8010509c <safestrcpy+0x17>
    return os;
80105097:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010509a:	eb 32                	jmp    801050ce <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
8010509c:	90                   	nop
8010509d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801050a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050a5:	7e 1e                	jle    801050c5 <safestrcpy+0x40>
801050a7:	8b 55 0c             	mov    0xc(%ebp),%edx
801050aa:	8d 42 01             	lea    0x1(%edx),%eax
801050ad:	89 45 0c             	mov    %eax,0xc(%ebp)
801050b0:	8b 45 08             	mov    0x8(%ebp),%eax
801050b3:	8d 48 01             	lea    0x1(%eax),%ecx
801050b6:	89 4d 08             	mov    %ecx,0x8(%ebp)
801050b9:	0f b6 12             	movzbl (%edx),%edx
801050bc:	88 10                	mov    %dl,(%eax)
801050be:	0f b6 00             	movzbl (%eax),%eax
801050c1:	84 c0                	test   %al,%al
801050c3:	75 d8                	jne    8010509d <safestrcpy+0x18>
    ;
  *s = 0;
801050c5:	8b 45 08             	mov    0x8(%ebp),%eax
801050c8:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801050cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050ce:	c9                   	leave  
801050cf:	c3                   	ret    

801050d0 <strlen>:

int
strlen(const char *s)
{
801050d0:	55                   	push   %ebp
801050d1:	89 e5                	mov    %esp,%ebp
801050d3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801050d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801050dd:	eb 04                	jmp    801050e3 <strlen+0x13>
801050df:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050e6:	8b 45 08             	mov    0x8(%ebp),%eax
801050e9:	01 d0                	add    %edx,%eax
801050eb:	0f b6 00             	movzbl (%eax),%eax
801050ee:	84 c0                	test   %al,%al
801050f0:	75 ed                	jne    801050df <strlen+0xf>
    ;
  return n;
801050f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050f5:	c9                   	leave  
801050f6:	c3                   	ret    

801050f7 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801050f7:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801050fb:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801050ff:	55                   	push   %ebp
  pushl %ebx
80105100:	53                   	push   %ebx
  pushl %esi
80105101:	56                   	push   %esi
  pushl %edi
80105102:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105103:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105105:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105107:	5f                   	pop    %edi
  popl %esi
80105108:	5e                   	pop    %esi
  popl %ebx
80105109:	5b                   	pop    %ebx
  popl %ebp
8010510a:	5d                   	pop    %ebp
  ret
8010510b:	c3                   	ret    

8010510c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010510c:	55                   	push   %ebp
8010510d:	89 e5                	mov    %esp,%ebp
8010510f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105112:	e8 47 e9 ff ff       	call   80103a5e <myproc>
80105117:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010511a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511d:	8b 00                	mov    (%eax),%eax
8010511f:	39 45 08             	cmp    %eax,0x8(%ebp)
80105122:	73 0f                	jae    80105133 <fetchint+0x27>
80105124:	8b 45 08             	mov    0x8(%ebp),%eax
80105127:	8d 50 04             	lea    0x4(%eax),%edx
8010512a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512d:	8b 00                	mov    (%eax),%eax
8010512f:	39 c2                	cmp    %eax,%edx
80105131:	76 07                	jbe    8010513a <fetchint+0x2e>
    return -1;
80105133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105138:	eb 0f                	jmp    80105149 <fetchint+0x3d>
  *ip = *(int*)(addr);
8010513a:	8b 45 08             	mov    0x8(%ebp),%eax
8010513d:	8b 10                	mov    (%eax),%edx
8010513f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105142:	89 10                	mov    %edx,(%eax)
  return 0;
80105144:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105149:	c9                   	leave  
8010514a:	c3                   	ret    

8010514b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010514b:	55                   	push   %ebp
8010514c:	89 e5                	mov    %esp,%ebp
8010514e:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105151:	e8 08 e9 ff ff       	call   80103a5e <myproc>
80105156:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105159:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010515c:	8b 00                	mov    (%eax),%eax
8010515e:	39 45 08             	cmp    %eax,0x8(%ebp)
80105161:	72 07                	jb     8010516a <fetchstr+0x1f>
    return -1;
80105163:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105168:	eb 41                	jmp    801051ab <fetchstr+0x60>
  *pp = (char*)addr;
8010516a:	8b 55 08             	mov    0x8(%ebp),%edx
8010516d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105170:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105175:	8b 00                	mov    (%eax),%eax
80105177:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010517a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010517d:	8b 00                	mov    (%eax),%eax
8010517f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105182:	eb 1a                	jmp    8010519e <fetchstr+0x53>
    if(*s == 0)
80105184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105187:	0f b6 00             	movzbl (%eax),%eax
8010518a:	84 c0                	test   %al,%al
8010518c:	75 0c                	jne    8010519a <fetchstr+0x4f>
      return s - *pp;
8010518e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105191:	8b 10                	mov    (%eax),%edx
80105193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105196:	29 d0                	sub    %edx,%eax
80105198:	eb 11                	jmp    801051ab <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
8010519a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010519e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801051a4:	72 de                	jb     80105184 <fetchstr+0x39>
  }
  return -1;
801051a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801051ab:	c9                   	leave  
801051ac:	c3                   	ret    

801051ad <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801051ad:	55                   	push   %ebp
801051ae:	89 e5                	mov    %esp,%ebp
801051b0:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801051b3:	e8 a6 e8 ff ff       	call   80103a5e <myproc>
801051b8:	8b 40 18             	mov    0x18(%eax),%eax
801051bb:	8b 50 44             	mov    0x44(%eax),%edx
801051be:	8b 45 08             	mov    0x8(%ebp),%eax
801051c1:	c1 e0 02             	shl    $0x2,%eax
801051c4:	01 d0                	add    %edx,%eax
801051c6:	83 c0 04             	add    $0x4,%eax
801051c9:	83 ec 08             	sub    $0x8,%esp
801051cc:	ff 75 0c             	push   0xc(%ebp)
801051cf:	50                   	push   %eax
801051d0:	e8 37 ff ff ff       	call   8010510c <fetchint>
801051d5:	83 c4 10             	add    $0x10,%esp
}
801051d8:	c9                   	leave  
801051d9:	c3                   	ret    

801051da <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801051da:	55                   	push   %ebp
801051db:	89 e5                	mov    %esp,%ebp
801051dd:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801051e0:	e8 79 e8 ff ff       	call   80103a5e <myproc>
801051e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801051e8:	83 ec 08             	sub    $0x8,%esp
801051eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051ee:	50                   	push   %eax
801051ef:	ff 75 08             	push   0x8(%ebp)
801051f2:	e8 b6 ff ff ff       	call   801051ad <argint>
801051f7:	83 c4 10             	add    $0x10,%esp
801051fa:	85 c0                	test   %eax,%eax
801051fc:	79 07                	jns    80105205 <argptr+0x2b>
    return -1;
801051fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105203:	eb 3b                	jmp    80105240 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105205:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105209:	78 1f                	js     8010522a <argptr+0x50>
8010520b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010520e:	8b 00                	mov    (%eax),%eax
80105210:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105213:	39 d0                	cmp    %edx,%eax
80105215:	76 13                	jbe    8010522a <argptr+0x50>
80105217:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521a:	89 c2                	mov    %eax,%edx
8010521c:	8b 45 10             	mov    0x10(%ebp),%eax
8010521f:	01 c2                	add    %eax,%edx
80105221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105224:	8b 00                	mov    (%eax),%eax
80105226:	39 c2                	cmp    %eax,%edx
80105228:	76 07                	jbe    80105231 <argptr+0x57>
    return -1;
8010522a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010522f:	eb 0f                	jmp    80105240 <argptr+0x66>
  *pp = (char*)i;
80105231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105234:	89 c2                	mov    %eax,%edx
80105236:	8b 45 0c             	mov    0xc(%ebp),%eax
80105239:	89 10                	mov    %edx,(%eax)
  return 0;
8010523b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105240:	c9                   	leave  
80105241:	c3                   	ret    

80105242 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105242:	55                   	push   %ebp
80105243:	89 e5                	mov    %esp,%ebp
80105245:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105248:	83 ec 08             	sub    $0x8,%esp
8010524b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010524e:	50                   	push   %eax
8010524f:	ff 75 08             	push   0x8(%ebp)
80105252:	e8 56 ff ff ff       	call   801051ad <argint>
80105257:	83 c4 10             	add    $0x10,%esp
8010525a:	85 c0                	test   %eax,%eax
8010525c:	79 07                	jns    80105265 <argstr+0x23>
    return -1;
8010525e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105263:	eb 12                	jmp    80105277 <argstr+0x35>
  return fetchstr(addr, pp);
80105265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105268:	83 ec 08             	sub    $0x8,%esp
8010526b:	ff 75 0c             	push   0xc(%ebp)
8010526e:	50                   	push   %eax
8010526f:	e8 d7 fe ff ff       	call   8010514b <fetchstr>
80105274:	83 c4 10             	add    $0x10,%esp
}
80105277:	c9                   	leave  
80105278:	c3                   	ret    

80105279 <syscall>:
[SYS_yield] = sys_yield,
};

void
syscall(void)
{
80105279:	55                   	push   %ebp
8010527a:	89 e5                	mov    %esp,%ebp
8010527c:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010527f:	e8 da e7 ff ff       	call   80103a5e <myproc>
80105284:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528a:	8b 40 18             	mov    0x18(%eax),%eax
8010528d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105290:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105293:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105297:	7e 2f                	jle    801052c8 <syscall+0x4f>
80105299:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010529c:	83 f8 18             	cmp    $0x18,%eax
8010529f:	77 27                	ja     801052c8 <syscall+0x4f>
801052a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052a4:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801052ab:	85 c0                	test   %eax,%eax
801052ad:	74 19                	je     801052c8 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801052af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b2:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801052b9:	ff d0                	call   *%eax
801052bb:	89 c2                	mov    %eax,%edx
801052bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c0:	8b 40 18             	mov    0x18(%eax),%eax
801052c3:	89 50 1c             	mov    %edx,0x1c(%eax)
801052c6:	eb 2c                	jmp    801052f4 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801052c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052cb:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801052ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d1:	8b 40 10             	mov    0x10(%eax),%eax
801052d4:	ff 75 f0             	push   -0x10(%ebp)
801052d7:	52                   	push   %edx
801052d8:	50                   	push   %eax
801052d9:	68 98 aa 10 80       	push   $0x8010aa98
801052de:	e8 11 b1 ff ff       	call   801003f4 <cprintf>
801052e3:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801052e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e9:	8b 40 18             	mov    0x18(%eax),%eax
801052ec:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801052f3:	90                   	nop
801052f4:	90                   	nop
801052f5:	c9                   	leave  
801052f6:	c3                   	ret    

801052f7 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801052f7:	55                   	push   %ebp
801052f8:	89 e5                	mov    %esp,%ebp
801052fa:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801052fd:	83 ec 08             	sub    $0x8,%esp
80105300:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105303:	50                   	push   %eax
80105304:	ff 75 08             	push   0x8(%ebp)
80105307:	e8 a1 fe ff ff       	call   801051ad <argint>
8010530c:	83 c4 10             	add    $0x10,%esp
8010530f:	85 c0                	test   %eax,%eax
80105311:	79 07                	jns    8010531a <argfd+0x23>
    return -1;
80105313:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105318:	eb 4f                	jmp    80105369 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010531a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010531d:	85 c0                	test   %eax,%eax
8010531f:	78 20                	js     80105341 <argfd+0x4a>
80105321:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105324:	83 f8 0f             	cmp    $0xf,%eax
80105327:	7f 18                	jg     80105341 <argfd+0x4a>
80105329:	e8 30 e7 ff ff       	call   80103a5e <myproc>
8010532e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105331:	83 c2 08             	add    $0x8,%edx
80105334:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105338:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010533b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010533f:	75 07                	jne    80105348 <argfd+0x51>
    return -1;
80105341:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105346:	eb 21                	jmp    80105369 <argfd+0x72>
  if(pfd)
80105348:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010534c:	74 08                	je     80105356 <argfd+0x5f>
    *pfd = fd;
8010534e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105351:	8b 45 0c             	mov    0xc(%ebp),%eax
80105354:	89 10                	mov    %edx,(%eax)
  if(pf)
80105356:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010535a:	74 08                	je     80105364 <argfd+0x6d>
    *pf = f;
8010535c:	8b 45 10             	mov    0x10(%ebp),%eax
8010535f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105362:	89 10                	mov    %edx,(%eax)
  return 0;
80105364:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105369:	c9                   	leave  
8010536a:	c3                   	ret    

8010536b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010536b:	55                   	push   %ebp
8010536c:	89 e5                	mov    %esp,%ebp
8010536e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105371:	e8 e8 e6 ff ff       	call   80103a5e <myproc>
80105376:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105379:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105380:	eb 2a                	jmp    801053ac <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105382:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105385:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105388:	83 c2 08             	add    $0x8,%edx
8010538b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010538f:	85 c0                	test   %eax,%eax
80105391:	75 15                	jne    801053a8 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105396:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105399:	8d 4a 08             	lea    0x8(%edx),%ecx
8010539c:	8b 55 08             	mov    0x8(%ebp),%edx
8010539f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801053a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a6:	eb 0f                	jmp    801053b7 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801053a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801053ac:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801053b0:	7e d0                	jle    80105382 <fdalloc+0x17>
    }
  }
  return -1;
801053b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053b7:	c9                   	leave  
801053b8:	c3                   	ret    

801053b9 <sys_dup>:

int
sys_dup(void)
{
801053b9:	55                   	push   %ebp
801053ba:	89 e5                	mov    %esp,%ebp
801053bc:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801053bf:	83 ec 04             	sub    $0x4,%esp
801053c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053c5:	50                   	push   %eax
801053c6:	6a 00                	push   $0x0
801053c8:	6a 00                	push   $0x0
801053ca:	e8 28 ff ff ff       	call   801052f7 <argfd>
801053cf:	83 c4 10             	add    $0x10,%esp
801053d2:	85 c0                	test   %eax,%eax
801053d4:	79 07                	jns    801053dd <sys_dup+0x24>
    return -1;
801053d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053db:	eb 31                	jmp    8010540e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801053dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e0:	83 ec 0c             	sub    $0xc,%esp
801053e3:	50                   	push   %eax
801053e4:	e8 82 ff ff ff       	call   8010536b <fdalloc>
801053e9:	83 c4 10             	add    $0x10,%esp
801053ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053f3:	79 07                	jns    801053fc <sys_dup+0x43>
    return -1;
801053f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053fa:	eb 12                	jmp    8010540e <sys_dup+0x55>
  filedup(f);
801053fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ff:	83 ec 0c             	sub    $0xc,%esp
80105402:	50                   	push   %eax
80105403:	e8 42 bc ff ff       	call   8010104a <filedup>
80105408:	83 c4 10             	add    $0x10,%esp
  return fd;
8010540b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010540e:	c9                   	leave  
8010540f:	c3                   	ret    

80105410 <sys_read>:

int
sys_read(void)
{
80105410:	55                   	push   %ebp
80105411:	89 e5                	mov    %esp,%ebp
80105413:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105416:	83 ec 04             	sub    $0x4,%esp
80105419:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010541c:	50                   	push   %eax
8010541d:	6a 00                	push   $0x0
8010541f:	6a 00                	push   $0x0
80105421:	e8 d1 fe ff ff       	call   801052f7 <argfd>
80105426:	83 c4 10             	add    $0x10,%esp
80105429:	85 c0                	test   %eax,%eax
8010542b:	78 2e                	js     8010545b <sys_read+0x4b>
8010542d:	83 ec 08             	sub    $0x8,%esp
80105430:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105433:	50                   	push   %eax
80105434:	6a 02                	push   $0x2
80105436:	e8 72 fd ff ff       	call   801051ad <argint>
8010543b:	83 c4 10             	add    $0x10,%esp
8010543e:	85 c0                	test   %eax,%eax
80105440:	78 19                	js     8010545b <sys_read+0x4b>
80105442:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105445:	83 ec 04             	sub    $0x4,%esp
80105448:	50                   	push   %eax
80105449:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010544c:	50                   	push   %eax
8010544d:	6a 01                	push   $0x1
8010544f:	e8 86 fd ff ff       	call   801051da <argptr>
80105454:	83 c4 10             	add    $0x10,%esp
80105457:	85 c0                	test   %eax,%eax
80105459:	79 07                	jns    80105462 <sys_read+0x52>
    return -1;
8010545b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105460:	eb 17                	jmp    80105479 <sys_read+0x69>
  return fileread(f, p, n);
80105462:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105465:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010546b:	83 ec 04             	sub    $0x4,%esp
8010546e:	51                   	push   %ecx
8010546f:	52                   	push   %edx
80105470:	50                   	push   %eax
80105471:	e8 64 bd ff ff       	call   801011da <fileread>
80105476:	83 c4 10             	add    $0x10,%esp
}
80105479:	c9                   	leave  
8010547a:	c3                   	ret    

8010547b <sys_write>:

int
sys_write(void)
{
8010547b:	55                   	push   %ebp
8010547c:	89 e5                	mov    %esp,%ebp
8010547e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105481:	83 ec 04             	sub    $0x4,%esp
80105484:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105487:	50                   	push   %eax
80105488:	6a 00                	push   $0x0
8010548a:	6a 00                	push   $0x0
8010548c:	e8 66 fe ff ff       	call   801052f7 <argfd>
80105491:	83 c4 10             	add    $0x10,%esp
80105494:	85 c0                	test   %eax,%eax
80105496:	78 2e                	js     801054c6 <sys_write+0x4b>
80105498:	83 ec 08             	sub    $0x8,%esp
8010549b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010549e:	50                   	push   %eax
8010549f:	6a 02                	push   $0x2
801054a1:	e8 07 fd ff ff       	call   801051ad <argint>
801054a6:	83 c4 10             	add    $0x10,%esp
801054a9:	85 c0                	test   %eax,%eax
801054ab:	78 19                	js     801054c6 <sys_write+0x4b>
801054ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b0:	83 ec 04             	sub    $0x4,%esp
801054b3:	50                   	push   %eax
801054b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054b7:	50                   	push   %eax
801054b8:	6a 01                	push   $0x1
801054ba:	e8 1b fd ff ff       	call   801051da <argptr>
801054bf:	83 c4 10             	add    $0x10,%esp
801054c2:	85 c0                	test   %eax,%eax
801054c4:	79 07                	jns    801054cd <sys_write+0x52>
    return -1;
801054c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054cb:	eb 17                	jmp    801054e4 <sys_write+0x69>
  return filewrite(f, p, n);
801054cd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801054d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801054d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d6:	83 ec 04             	sub    $0x4,%esp
801054d9:	51                   	push   %ecx
801054da:	52                   	push   %edx
801054db:	50                   	push   %eax
801054dc:	e8 b1 bd ff ff       	call   80101292 <filewrite>
801054e1:	83 c4 10             	add    $0x10,%esp
}
801054e4:	c9                   	leave  
801054e5:	c3                   	ret    

801054e6 <sys_close>:

int
sys_close(void)
{
801054e6:	55                   	push   %ebp
801054e7:	89 e5                	mov    %esp,%ebp
801054e9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801054ec:	83 ec 04             	sub    $0x4,%esp
801054ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054f2:	50                   	push   %eax
801054f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054f6:	50                   	push   %eax
801054f7:	6a 00                	push   $0x0
801054f9:	e8 f9 fd ff ff       	call   801052f7 <argfd>
801054fe:	83 c4 10             	add    $0x10,%esp
80105501:	85 c0                	test   %eax,%eax
80105503:	79 07                	jns    8010550c <sys_close+0x26>
    return -1;
80105505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010550a:	eb 27                	jmp    80105533 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010550c:	e8 4d e5 ff ff       	call   80103a5e <myproc>
80105511:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105514:	83 c2 08             	add    $0x8,%edx
80105517:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010551e:	00 
  fileclose(f);
8010551f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105522:	83 ec 0c             	sub    $0xc,%esp
80105525:	50                   	push   %eax
80105526:	e8 70 bb ff ff       	call   8010109b <fileclose>
8010552b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010552e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105533:	c9                   	leave  
80105534:	c3                   	ret    

80105535 <sys_fstat>:

int
sys_fstat(void)
{
80105535:	55                   	push   %ebp
80105536:	89 e5                	mov    %esp,%ebp
80105538:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010553b:	83 ec 04             	sub    $0x4,%esp
8010553e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105541:	50                   	push   %eax
80105542:	6a 00                	push   $0x0
80105544:	6a 00                	push   $0x0
80105546:	e8 ac fd ff ff       	call   801052f7 <argfd>
8010554b:	83 c4 10             	add    $0x10,%esp
8010554e:	85 c0                	test   %eax,%eax
80105550:	78 17                	js     80105569 <sys_fstat+0x34>
80105552:	83 ec 04             	sub    $0x4,%esp
80105555:	6a 14                	push   $0x14
80105557:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010555a:	50                   	push   %eax
8010555b:	6a 01                	push   $0x1
8010555d:	e8 78 fc ff ff       	call   801051da <argptr>
80105562:	83 c4 10             	add    $0x10,%esp
80105565:	85 c0                	test   %eax,%eax
80105567:	79 07                	jns    80105570 <sys_fstat+0x3b>
    return -1;
80105569:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556e:	eb 13                	jmp    80105583 <sys_fstat+0x4e>
  return filestat(f, st);
80105570:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105576:	83 ec 08             	sub    $0x8,%esp
80105579:	52                   	push   %edx
8010557a:	50                   	push   %eax
8010557b:	e8 03 bc ff ff       	call   80101183 <filestat>
80105580:	83 c4 10             	add    $0x10,%esp
}
80105583:	c9                   	leave  
80105584:	c3                   	ret    

80105585 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105585:	55                   	push   %ebp
80105586:	89 e5                	mov    %esp,%ebp
80105588:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010558b:	83 ec 08             	sub    $0x8,%esp
8010558e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105591:	50                   	push   %eax
80105592:	6a 00                	push   $0x0
80105594:	e8 a9 fc ff ff       	call   80105242 <argstr>
80105599:	83 c4 10             	add    $0x10,%esp
8010559c:	85 c0                	test   %eax,%eax
8010559e:	78 15                	js     801055b5 <sys_link+0x30>
801055a0:	83 ec 08             	sub    $0x8,%esp
801055a3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801055a6:	50                   	push   %eax
801055a7:	6a 01                	push   $0x1
801055a9:	e8 94 fc ff ff       	call   80105242 <argstr>
801055ae:	83 c4 10             	add    $0x10,%esp
801055b1:	85 c0                	test   %eax,%eax
801055b3:	79 0a                	jns    801055bf <sys_link+0x3a>
    return -1;
801055b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ba:	e9 68 01 00 00       	jmp    80105727 <sys_link+0x1a2>

  begin_op();
801055bf:	e8 78 da ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
801055c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801055c7:	83 ec 0c             	sub    $0xc,%esp
801055ca:	50                   	push   %eax
801055cb:	e8 4d cf ff ff       	call   8010251d <namei>
801055d0:	83 c4 10             	add    $0x10,%esp
801055d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055da:	75 0f                	jne    801055eb <sys_link+0x66>
    end_op();
801055dc:	e8 e7 da ff ff       	call   801030c8 <end_op>
    return -1;
801055e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055e6:	e9 3c 01 00 00       	jmp    80105727 <sys_link+0x1a2>
  }

  ilock(ip);
801055eb:	83 ec 0c             	sub    $0xc,%esp
801055ee:	ff 75 f4             	push   -0xc(%ebp)
801055f1:	e8 f4 c3 ff ff       	call   801019ea <ilock>
801055f6:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801055f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105600:	66 83 f8 01          	cmp    $0x1,%ax
80105604:	75 1d                	jne    80105623 <sys_link+0x9e>
    iunlockput(ip);
80105606:	83 ec 0c             	sub    $0xc,%esp
80105609:	ff 75 f4             	push   -0xc(%ebp)
8010560c:	e8 0a c6 ff ff       	call   80101c1b <iunlockput>
80105611:	83 c4 10             	add    $0x10,%esp
    end_op();
80105614:	e8 af da ff ff       	call   801030c8 <end_op>
    return -1;
80105619:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010561e:	e9 04 01 00 00       	jmp    80105727 <sys_link+0x1a2>
  }

  ip->nlink++;
80105623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105626:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010562a:	83 c0 01             	add    $0x1,%eax
8010562d:	89 c2                	mov    %eax,%edx
8010562f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105632:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105636:	83 ec 0c             	sub    $0xc,%esp
80105639:	ff 75 f4             	push   -0xc(%ebp)
8010563c:	e8 cc c1 ff ff       	call   8010180d <iupdate>
80105641:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105644:	83 ec 0c             	sub    $0xc,%esp
80105647:	ff 75 f4             	push   -0xc(%ebp)
8010564a:	e8 ae c4 ff ff       	call   80101afd <iunlock>
8010564f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105652:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105655:	83 ec 08             	sub    $0x8,%esp
80105658:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010565b:	52                   	push   %edx
8010565c:	50                   	push   %eax
8010565d:	e8 d7 ce ff ff       	call   80102539 <nameiparent>
80105662:	83 c4 10             	add    $0x10,%esp
80105665:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105668:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010566c:	74 71                	je     801056df <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010566e:	83 ec 0c             	sub    $0xc,%esp
80105671:	ff 75 f0             	push   -0x10(%ebp)
80105674:	e8 71 c3 ff ff       	call   801019ea <ilock>
80105679:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010567c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010567f:	8b 10                	mov    (%eax),%edx
80105681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105684:	8b 00                	mov    (%eax),%eax
80105686:	39 c2                	cmp    %eax,%edx
80105688:	75 1d                	jne    801056a7 <sys_link+0x122>
8010568a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568d:	8b 40 04             	mov    0x4(%eax),%eax
80105690:	83 ec 04             	sub    $0x4,%esp
80105693:	50                   	push   %eax
80105694:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105697:	50                   	push   %eax
80105698:	ff 75 f0             	push   -0x10(%ebp)
8010569b:	e8 e6 cb ff ff       	call   80102286 <dirlink>
801056a0:	83 c4 10             	add    $0x10,%esp
801056a3:	85 c0                	test   %eax,%eax
801056a5:	79 10                	jns    801056b7 <sys_link+0x132>
    iunlockput(dp);
801056a7:	83 ec 0c             	sub    $0xc,%esp
801056aa:	ff 75 f0             	push   -0x10(%ebp)
801056ad:	e8 69 c5 ff ff       	call   80101c1b <iunlockput>
801056b2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801056b5:	eb 29                	jmp    801056e0 <sys_link+0x15b>
  }
  iunlockput(dp);
801056b7:	83 ec 0c             	sub    $0xc,%esp
801056ba:	ff 75 f0             	push   -0x10(%ebp)
801056bd:	e8 59 c5 ff ff       	call   80101c1b <iunlockput>
801056c2:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801056c5:	83 ec 0c             	sub    $0xc,%esp
801056c8:	ff 75 f4             	push   -0xc(%ebp)
801056cb:	e8 7b c4 ff ff       	call   80101b4b <iput>
801056d0:	83 c4 10             	add    $0x10,%esp

  end_op();
801056d3:	e8 f0 d9 ff ff       	call   801030c8 <end_op>

  return 0;
801056d8:	b8 00 00 00 00       	mov    $0x0,%eax
801056dd:	eb 48                	jmp    80105727 <sys_link+0x1a2>
    goto bad;
801056df:	90                   	nop

bad:
  ilock(ip);
801056e0:	83 ec 0c             	sub    $0xc,%esp
801056e3:	ff 75 f4             	push   -0xc(%ebp)
801056e6:	e8 ff c2 ff ff       	call   801019ea <ilock>
801056eb:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801056ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056f5:	83 e8 01             	sub    $0x1,%eax
801056f8:	89 c2                	mov    %eax,%edx
801056fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fd:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105701:	83 ec 0c             	sub    $0xc,%esp
80105704:	ff 75 f4             	push   -0xc(%ebp)
80105707:	e8 01 c1 ff ff       	call   8010180d <iupdate>
8010570c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010570f:	83 ec 0c             	sub    $0xc,%esp
80105712:	ff 75 f4             	push   -0xc(%ebp)
80105715:	e8 01 c5 ff ff       	call   80101c1b <iunlockput>
8010571a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010571d:	e8 a6 d9 ff ff       	call   801030c8 <end_op>
  return -1;
80105722:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105727:	c9                   	leave  
80105728:	c3                   	ret    

80105729 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105729:	55                   	push   %ebp
8010572a:	89 e5                	mov    %esp,%ebp
8010572c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010572f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105736:	eb 40                	jmp    80105778 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010573b:	6a 10                	push   $0x10
8010573d:	50                   	push   %eax
8010573e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105741:	50                   	push   %eax
80105742:	ff 75 08             	push   0x8(%ebp)
80105745:	e8 8c c7 ff ff       	call   80101ed6 <readi>
8010574a:	83 c4 10             	add    $0x10,%esp
8010574d:	83 f8 10             	cmp    $0x10,%eax
80105750:	74 0d                	je     8010575f <isdirempty+0x36>
      panic("isdirempty: readi");
80105752:	83 ec 0c             	sub    $0xc,%esp
80105755:	68 b4 aa 10 80       	push   $0x8010aab4
8010575a:	e8 4a ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010575f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105763:	66 85 c0             	test   %ax,%ax
80105766:	74 07                	je     8010576f <isdirempty+0x46>
      return 0;
80105768:	b8 00 00 00 00       	mov    $0x0,%eax
8010576d:	eb 1b                	jmp    8010578a <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010576f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105772:	83 c0 10             	add    $0x10,%eax
80105775:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105778:	8b 45 08             	mov    0x8(%ebp),%eax
8010577b:	8b 50 58             	mov    0x58(%eax),%edx
8010577e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105781:	39 c2                	cmp    %eax,%edx
80105783:	77 b3                	ja     80105738 <isdirempty+0xf>
  }
  return 1;
80105785:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010578a:	c9                   	leave  
8010578b:	c3                   	ret    

8010578c <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010578c:	55                   	push   %ebp
8010578d:	89 e5                	mov    %esp,%ebp
8010578f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105792:	83 ec 08             	sub    $0x8,%esp
80105795:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105798:	50                   	push   %eax
80105799:	6a 00                	push   $0x0
8010579b:	e8 a2 fa ff ff       	call   80105242 <argstr>
801057a0:	83 c4 10             	add    $0x10,%esp
801057a3:	85 c0                	test   %eax,%eax
801057a5:	79 0a                	jns    801057b1 <sys_unlink+0x25>
    return -1;
801057a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ac:	e9 bf 01 00 00       	jmp    80105970 <sys_unlink+0x1e4>

  begin_op();
801057b1:	e8 86 d8 ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801057b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801057b9:	83 ec 08             	sub    $0x8,%esp
801057bc:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801057bf:	52                   	push   %edx
801057c0:	50                   	push   %eax
801057c1:	e8 73 cd ff ff       	call   80102539 <nameiparent>
801057c6:	83 c4 10             	add    $0x10,%esp
801057c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057d0:	75 0f                	jne    801057e1 <sys_unlink+0x55>
    end_op();
801057d2:	e8 f1 d8 ff ff       	call   801030c8 <end_op>
    return -1;
801057d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057dc:	e9 8f 01 00 00       	jmp    80105970 <sys_unlink+0x1e4>
  }

  ilock(dp);
801057e1:	83 ec 0c             	sub    $0xc,%esp
801057e4:	ff 75 f4             	push   -0xc(%ebp)
801057e7:	e8 fe c1 ff ff       	call   801019ea <ilock>
801057ec:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801057ef:	83 ec 08             	sub    $0x8,%esp
801057f2:	68 c6 aa 10 80       	push   $0x8010aac6
801057f7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057fa:	50                   	push   %eax
801057fb:	e8 b1 c9 ff ff       	call   801021b1 <namecmp>
80105800:	83 c4 10             	add    $0x10,%esp
80105803:	85 c0                	test   %eax,%eax
80105805:	0f 84 49 01 00 00    	je     80105954 <sys_unlink+0x1c8>
8010580b:	83 ec 08             	sub    $0x8,%esp
8010580e:	68 c8 aa 10 80       	push   $0x8010aac8
80105813:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105816:	50                   	push   %eax
80105817:	e8 95 c9 ff ff       	call   801021b1 <namecmp>
8010581c:	83 c4 10             	add    $0x10,%esp
8010581f:	85 c0                	test   %eax,%eax
80105821:	0f 84 2d 01 00 00    	je     80105954 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105827:	83 ec 04             	sub    $0x4,%esp
8010582a:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010582d:	50                   	push   %eax
8010582e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105831:	50                   	push   %eax
80105832:	ff 75 f4             	push   -0xc(%ebp)
80105835:	e8 92 c9 ff ff       	call   801021cc <dirlookup>
8010583a:	83 c4 10             	add    $0x10,%esp
8010583d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105840:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105844:	0f 84 0d 01 00 00    	je     80105957 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010584a:	83 ec 0c             	sub    $0xc,%esp
8010584d:	ff 75 f0             	push   -0x10(%ebp)
80105850:	e8 95 c1 ff ff       	call   801019ea <ilock>
80105855:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010585b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010585f:	66 85 c0             	test   %ax,%ax
80105862:	7f 0d                	jg     80105871 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105864:	83 ec 0c             	sub    $0xc,%esp
80105867:	68 cb aa 10 80       	push   $0x8010aacb
8010586c:	e8 38 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105874:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105878:	66 83 f8 01          	cmp    $0x1,%ax
8010587c:	75 25                	jne    801058a3 <sys_unlink+0x117>
8010587e:	83 ec 0c             	sub    $0xc,%esp
80105881:	ff 75 f0             	push   -0x10(%ebp)
80105884:	e8 a0 fe ff ff       	call   80105729 <isdirempty>
80105889:	83 c4 10             	add    $0x10,%esp
8010588c:	85 c0                	test   %eax,%eax
8010588e:	75 13                	jne    801058a3 <sys_unlink+0x117>
    iunlockput(ip);
80105890:	83 ec 0c             	sub    $0xc,%esp
80105893:	ff 75 f0             	push   -0x10(%ebp)
80105896:	e8 80 c3 ff ff       	call   80101c1b <iunlockput>
8010589b:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010589e:	e9 b5 00 00 00       	jmp    80105958 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801058a3:	83 ec 04             	sub    $0x4,%esp
801058a6:	6a 10                	push   $0x10
801058a8:	6a 00                	push   $0x0
801058aa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058ad:	50                   	push   %eax
801058ae:	e8 cf f5 ff ff       	call   80104e82 <memset>
801058b3:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058b6:	8b 45 c8             	mov    -0x38(%ebp),%eax
801058b9:	6a 10                	push   $0x10
801058bb:	50                   	push   %eax
801058bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058bf:	50                   	push   %eax
801058c0:	ff 75 f4             	push   -0xc(%ebp)
801058c3:	e8 63 c7 ff ff       	call   8010202b <writei>
801058c8:	83 c4 10             	add    $0x10,%esp
801058cb:	83 f8 10             	cmp    $0x10,%eax
801058ce:	74 0d                	je     801058dd <sys_unlink+0x151>
    panic("unlink: writei");
801058d0:	83 ec 0c             	sub    $0xc,%esp
801058d3:	68 dd aa 10 80       	push   $0x8010aadd
801058d8:	e8 cc ac ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801058dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058e4:	66 83 f8 01          	cmp    $0x1,%ax
801058e8:	75 21                	jne    8010590b <sys_unlink+0x17f>
    dp->nlink--;
801058ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ed:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058f1:	83 e8 01             	sub    $0x1,%eax
801058f4:	89 c2                	mov    %eax,%edx
801058f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f9:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801058fd:	83 ec 0c             	sub    $0xc,%esp
80105900:	ff 75 f4             	push   -0xc(%ebp)
80105903:	e8 05 bf ff ff       	call   8010180d <iupdate>
80105908:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010590b:	83 ec 0c             	sub    $0xc,%esp
8010590e:	ff 75 f4             	push   -0xc(%ebp)
80105911:	e8 05 c3 ff ff       	call   80101c1b <iunlockput>
80105916:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105919:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105920:	83 e8 01             	sub    $0x1,%eax
80105923:	89 c2                	mov    %eax,%edx
80105925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105928:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010592c:	83 ec 0c             	sub    $0xc,%esp
8010592f:	ff 75 f0             	push   -0x10(%ebp)
80105932:	e8 d6 be ff ff       	call   8010180d <iupdate>
80105937:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010593a:	83 ec 0c             	sub    $0xc,%esp
8010593d:	ff 75 f0             	push   -0x10(%ebp)
80105940:	e8 d6 c2 ff ff       	call   80101c1b <iunlockput>
80105945:	83 c4 10             	add    $0x10,%esp

  end_op();
80105948:	e8 7b d7 ff ff       	call   801030c8 <end_op>

  return 0;
8010594d:	b8 00 00 00 00       	mov    $0x0,%eax
80105952:	eb 1c                	jmp    80105970 <sys_unlink+0x1e4>
    goto bad;
80105954:	90                   	nop
80105955:	eb 01                	jmp    80105958 <sys_unlink+0x1cc>
    goto bad;
80105957:	90                   	nop

bad:
  iunlockput(dp);
80105958:	83 ec 0c             	sub    $0xc,%esp
8010595b:	ff 75 f4             	push   -0xc(%ebp)
8010595e:	e8 b8 c2 ff ff       	call   80101c1b <iunlockput>
80105963:	83 c4 10             	add    $0x10,%esp
  end_op();
80105966:	e8 5d d7 ff ff       	call   801030c8 <end_op>
  return -1;
8010596b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105970:	c9                   	leave  
80105971:	c3                   	ret    

80105972 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105972:	55                   	push   %ebp
80105973:	89 e5                	mov    %esp,%ebp
80105975:	83 ec 38             	sub    $0x38,%esp
80105978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010597b:	8b 55 10             	mov    0x10(%ebp),%edx
8010597e:	8b 45 14             	mov    0x14(%ebp),%eax
80105981:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105985:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105989:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010598d:	83 ec 08             	sub    $0x8,%esp
80105990:	8d 45 de             	lea    -0x22(%ebp),%eax
80105993:	50                   	push   %eax
80105994:	ff 75 08             	push   0x8(%ebp)
80105997:	e8 9d cb ff ff       	call   80102539 <nameiparent>
8010599c:	83 c4 10             	add    $0x10,%esp
8010599f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059a6:	75 0a                	jne    801059b2 <create+0x40>
    return 0;
801059a8:	b8 00 00 00 00       	mov    $0x0,%eax
801059ad:	e9 90 01 00 00       	jmp    80105b42 <create+0x1d0>
  ilock(dp);
801059b2:	83 ec 0c             	sub    $0xc,%esp
801059b5:	ff 75 f4             	push   -0xc(%ebp)
801059b8:	e8 2d c0 ff ff       	call   801019ea <ilock>
801059bd:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801059c0:	83 ec 04             	sub    $0x4,%esp
801059c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059c6:	50                   	push   %eax
801059c7:	8d 45 de             	lea    -0x22(%ebp),%eax
801059ca:	50                   	push   %eax
801059cb:	ff 75 f4             	push   -0xc(%ebp)
801059ce:	e8 f9 c7 ff ff       	call   801021cc <dirlookup>
801059d3:	83 c4 10             	add    $0x10,%esp
801059d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059dd:	74 50                	je     80105a2f <create+0xbd>
    iunlockput(dp);
801059df:	83 ec 0c             	sub    $0xc,%esp
801059e2:	ff 75 f4             	push   -0xc(%ebp)
801059e5:	e8 31 c2 ff ff       	call   80101c1b <iunlockput>
801059ea:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801059ed:	83 ec 0c             	sub    $0xc,%esp
801059f0:	ff 75 f0             	push   -0x10(%ebp)
801059f3:	e8 f2 bf ff ff       	call   801019ea <ilock>
801059f8:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801059fb:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105a00:	75 15                	jne    80105a17 <create+0xa5>
80105a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a05:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a09:	66 83 f8 02          	cmp    $0x2,%ax
80105a0d:	75 08                	jne    80105a17 <create+0xa5>
      return ip;
80105a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a12:	e9 2b 01 00 00       	jmp    80105b42 <create+0x1d0>
    iunlockput(ip);
80105a17:	83 ec 0c             	sub    $0xc,%esp
80105a1a:	ff 75 f0             	push   -0x10(%ebp)
80105a1d:	e8 f9 c1 ff ff       	call   80101c1b <iunlockput>
80105a22:	83 c4 10             	add    $0x10,%esp
    return 0;
80105a25:	b8 00 00 00 00       	mov    $0x0,%eax
80105a2a:	e9 13 01 00 00       	jmp    80105b42 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105a2f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a36:	8b 00                	mov    (%eax),%eax
80105a38:	83 ec 08             	sub    $0x8,%esp
80105a3b:	52                   	push   %edx
80105a3c:	50                   	push   %eax
80105a3d:	e8 f4 bc ff ff       	call   80101736 <ialloc>
80105a42:	83 c4 10             	add    $0x10,%esp
80105a45:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a4c:	75 0d                	jne    80105a5b <create+0xe9>
    panic("create: ialloc");
80105a4e:	83 ec 0c             	sub    $0xc,%esp
80105a51:	68 ec aa 10 80       	push   $0x8010aaec
80105a56:	e8 4e ab ff ff       	call   801005a9 <panic>

  ilock(ip);
80105a5b:	83 ec 0c             	sub    $0xc,%esp
80105a5e:	ff 75 f0             	push   -0x10(%ebp)
80105a61:	e8 84 bf ff ff       	call   801019ea <ilock>
80105a66:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6c:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a70:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a77:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a7b:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a82:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a88:	83 ec 0c             	sub    $0xc,%esp
80105a8b:	ff 75 f0             	push   -0x10(%ebp)
80105a8e:	e8 7a bd ff ff       	call   8010180d <iupdate>
80105a93:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a96:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a9b:	75 6a                	jne    80105b07 <create+0x195>
    dp->nlink++;  // for ".."
80105a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105aa4:	83 c0 01             	add    $0x1,%eax
80105aa7:	89 c2                	mov    %eax,%edx
80105aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aac:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105ab0:	83 ec 0c             	sub    $0xc,%esp
80105ab3:	ff 75 f4             	push   -0xc(%ebp)
80105ab6:	e8 52 bd ff ff       	call   8010180d <iupdate>
80105abb:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac1:	8b 40 04             	mov    0x4(%eax),%eax
80105ac4:	83 ec 04             	sub    $0x4,%esp
80105ac7:	50                   	push   %eax
80105ac8:	68 c6 aa 10 80       	push   $0x8010aac6
80105acd:	ff 75 f0             	push   -0x10(%ebp)
80105ad0:	e8 b1 c7 ff ff       	call   80102286 <dirlink>
80105ad5:	83 c4 10             	add    $0x10,%esp
80105ad8:	85 c0                	test   %eax,%eax
80105ada:	78 1e                	js     80105afa <create+0x188>
80105adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105adf:	8b 40 04             	mov    0x4(%eax),%eax
80105ae2:	83 ec 04             	sub    $0x4,%esp
80105ae5:	50                   	push   %eax
80105ae6:	68 c8 aa 10 80       	push   $0x8010aac8
80105aeb:	ff 75 f0             	push   -0x10(%ebp)
80105aee:	e8 93 c7 ff ff       	call   80102286 <dirlink>
80105af3:	83 c4 10             	add    $0x10,%esp
80105af6:	85 c0                	test   %eax,%eax
80105af8:	79 0d                	jns    80105b07 <create+0x195>
      panic("create dots");
80105afa:	83 ec 0c             	sub    $0xc,%esp
80105afd:	68 fb aa 10 80       	push   $0x8010aafb
80105b02:	e8 a2 aa ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0a:	8b 40 04             	mov    0x4(%eax),%eax
80105b0d:	83 ec 04             	sub    $0x4,%esp
80105b10:	50                   	push   %eax
80105b11:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b14:	50                   	push   %eax
80105b15:	ff 75 f4             	push   -0xc(%ebp)
80105b18:	e8 69 c7 ff ff       	call   80102286 <dirlink>
80105b1d:	83 c4 10             	add    $0x10,%esp
80105b20:	85 c0                	test   %eax,%eax
80105b22:	79 0d                	jns    80105b31 <create+0x1bf>
    panic("create: dirlink");
80105b24:	83 ec 0c             	sub    $0xc,%esp
80105b27:	68 07 ab 10 80       	push   $0x8010ab07
80105b2c:	e8 78 aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105b31:	83 ec 0c             	sub    $0xc,%esp
80105b34:	ff 75 f4             	push   -0xc(%ebp)
80105b37:	e8 df c0 ff ff       	call   80101c1b <iunlockput>
80105b3c:	83 c4 10             	add    $0x10,%esp

  return ip;
80105b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105b42:	c9                   	leave  
80105b43:	c3                   	ret    

80105b44 <sys_open>:

int
sys_open(void)
{
80105b44:	55                   	push   %ebp
80105b45:	89 e5                	mov    %esp,%ebp
80105b47:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105b4a:	83 ec 08             	sub    $0x8,%esp
80105b4d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b50:	50                   	push   %eax
80105b51:	6a 00                	push   $0x0
80105b53:	e8 ea f6 ff ff       	call   80105242 <argstr>
80105b58:	83 c4 10             	add    $0x10,%esp
80105b5b:	85 c0                	test   %eax,%eax
80105b5d:	78 15                	js     80105b74 <sys_open+0x30>
80105b5f:	83 ec 08             	sub    $0x8,%esp
80105b62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b65:	50                   	push   %eax
80105b66:	6a 01                	push   $0x1
80105b68:	e8 40 f6 ff ff       	call   801051ad <argint>
80105b6d:	83 c4 10             	add    $0x10,%esp
80105b70:	85 c0                	test   %eax,%eax
80105b72:	79 0a                	jns    80105b7e <sys_open+0x3a>
    return -1;
80105b74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b79:	e9 61 01 00 00       	jmp    80105cdf <sys_open+0x19b>

  begin_op();
80105b7e:	e8 b9 d4 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
80105b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b86:	25 00 02 00 00       	and    $0x200,%eax
80105b8b:	85 c0                	test   %eax,%eax
80105b8d:	74 2a                	je     80105bb9 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b92:	6a 00                	push   $0x0
80105b94:	6a 00                	push   $0x0
80105b96:	6a 02                	push   $0x2
80105b98:	50                   	push   %eax
80105b99:	e8 d4 fd ff ff       	call   80105972 <create>
80105b9e:	83 c4 10             	add    $0x10,%esp
80105ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ba4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ba8:	75 75                	jne    80105c1f <sys_open+0xdb>
      end_op();
80105baa:	e8 19 d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105baf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb4:	e9 26 01 00 00       	jmp    80105cdf <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105bb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bbc:	83 ec 0c             	sub    $0xc,%esp
80105bbf:	50                   	push   %eax
80105bc0:	e8 58 c9 ff ff       	call   8010251d <namei>
80105bc5:	83 c4 10             	add    $0x10,%esp
80105bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bcb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bcf:	75 0f                	jne    80105be0 <sys_open+0x9c>
      end_op();
80105bd1:	e8 f2 d4 ff ff       	call   801030c8 <end_op>
      return -1;
80105bd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdb:	e9 ff 00 00 00       	jmp    80105cdf <sys_open+0x19b>
    }
    ilock(ip);
80105be0:	83 ec 0c             	sub    $0xc,%esp
80105be3:	ff 75 f4             	push   -0xc(%ebp)
80105be6:	e8 ff bd ff ff       	call   801019ea <ilock>
80105beb:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bf5:	66 83 f8 01          	cmp    $0x1,%ax
80105bf9:	75 24                	jne    80105c1f <sys_open+0xdb>
80105bfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bfe:	85 c0                	test   %eax,%eax
80105c00:	74 1d                	je     80105c1f <sys_open+0xdb>
      iunlockput(ip);
80105c02:	83 ec 0c             	sub    $0xc,%esp
80105c05:	ff 75 f4             	push   -0xc(%ebp)
80105c08:	e8 0e c0 ff ff       	call   80101c1b <iunlockput>
80105c0d:	83 c4 10             	add    $0x10,%esp
      end_op();
80105c10:	e8 b3 d4 ff ff       	call   801030c8 <end_op>
      return -1;
80105c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1a:	e9 c0 00 00 00       	jmp    80105cdf <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105c1f:	e8 b9 b3 ff ff       	call   80100fdd <filealloc>
80105c24:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c2b:	74 17                	je     80105c44 <sys_open+0x100>
80105c2d:	83 ec 0c             	sub    $0xc,%esp
80105c30:	ff 75 f0             	push   -0x10(%ebp)
80105c33:	e8 33 f7 ff ff       	call   8010536b <fdalloc>
80105c38:	83 c4 10             	add    $0x10,%esp
80105c3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105c3e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c42:	79 2e                	jns    80105c72 <sys_open+0x12e>
    if(f)
80105c44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c48:	74 0e                	je     80105c58 <sys_open+0x114>
      fileclose(f);
80105c4a:	83 ec 0c             	sub    $0xc,%esp
80105c4d:	ff 75 f0             	push   -0x10(%ebp)
80105c50:	e8 46 b4 ff ff       	call   8010109b <fileclose>
80105c55:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105c58:	83 ec 0c             	sub    $0xc,%esp
80105c5b:	ff 75 f4             	push   -0xc(%ebp)
80105c5e:	e8 b8 bf ff ff       	call   80101c1b <iunlockput>
80105c63:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c66:	e8 5d d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105c6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c70:	eb 6d                	jmp    80105cdf <sys_open+0x19b>
  }
  iunlock(ip);
80105c72:	83 ec 0c             	sub    $0xc,%esp
80105c75:	ff 75 f4             	push   -0xc(%ebp)
80105c78:	e8 80 be ff ff       	call   80101afd <iunlock>
80105c7d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c80:	e8 43 d4 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c88:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c94:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105ca1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ca4:	83 e0 01             	and    $0x1,%eax
80105ca7:	85 c0                	test   %eax,%eax
80105ca9:	0f 94 c0             	sete   %al
80105cac:	89 c2                	mov    %eax,%edx
80105cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb1:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105cb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cb7:	83 e0 01             	and    $0x1,%eax
80105cba:	85 c0                	test   %eax,%eax
80105cbc:	75 0a                	jne    80105cc8 <sys_open+0x184>
80105cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cc1:	83 e0 02             	and    $0x2,%eax
80105cc4:	85 c0                	test   %eax,%eax
80105cc6:	74 07                	je     80105ccf <sys_open+0x18b>
80105cc8:	b8 01 00 00 00       	mov    $0x1,%eax
80105ccd:	eb 05                	jmp    80105cd4 <sys_open+0x190>
80105ccf:	b8 00 00 00 00       	mov    $0x0,%eax
80105cd4:	89 c2                	mov    %eax,%edx
80105cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd9:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105cdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105cdf:	c9                   	leave  
80105ce0:	c3                   	ret    

80105ce1 <sys_mkdir>:

int
sys_mkdir(void)
{
80105ce1:	55                   	push   %ebp
80105ce2:	89 e5                	mov    %esp,%ebp
80105ce4:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105ce7:	e8 50 d3 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105cec:	83 ec 08             	sub    $0x8,%esp
80105cef:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cf2:	50                   	push   %eax
80105cf3:	6a 00                	push   $0x0
80105cf5:	e8 48 f5 ff ff       	call   80105242 <argstr>
80105cfa:	83 c4 10             	add    $0x10,%esp
80105cfd:	85 c0                	test   %eax,%eax
80105cff:	78 1b                	js     80105d1c <sys_mkdir+0x3b>
80105d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d04:	6a 00                	push   $0x0
80105d06:	6a 00                	push   $0x0
80105d08:	6a 01                	push   $0x1
80105d0a:	50                   	push   %eax
80105d0b:	e8 62 fc ff ff       	call   80105972 <create>
80105d10:	83 c4 10             	add    $0x10,%esp
80105d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d1a:	75 0c                	jne    80105d28 <sys_mkdir+0x47>
    end_op();
80105d1c:	e8 a7 d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105d21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d26:	eb 18                	jmp    80105d40 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105d28:	83 ec 0c             	sub    $0xc,%esp
80105d2b:	ff 75 f4             	push   -0xc(%ebp)
80105d2e:	e8 e8 be ff ff       	call   80101c1b <iunlockput>
80105d33:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d36:	e8 8d d3 ff ff       	call   801030c8 <end_op>
  return 0;
80105d3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d40:	c9                   	leave  
80105d41:	c3                   	ret    

80105d42 <sys_mknod>:

int
sys_mknod(void)
{
80105d42:	55                   	push   %ebp
80105d43:	89 e5                	mov    %esp,%ebp
80105d45:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105d48:	e8 ef d2 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105d4d:	83 ec 08             	sub    $0x8,%esp
80105d50:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d53:	50                   	push   %eax
80105d54:	6a 00                	push   $0x0
80105d56:	e8 e7 f4 ff ff       	call   80105242 <argstr>
80105d5b:	83 c4 10             	add    $0x10,%esp
80105d5e:	85 c0                	test   %eax,%eax
80105d60:	78 4f                	js     80105db1 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105d62:	83 ec 08             	sub    $0x8,%esp
80105d65:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d68:	50                   	push   %eax
80105d69:	6a 01                	push   $0x1
80105d6b:	e8 3d f4 ff ff       	call   801051ad <argint>
80105d70:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d73:	85 c0                	test   %eax,%eax
80105d75:	78 3a                	js     80105db1 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105d77:	83 ec 08             	sub    $0x8,%esp
80105d7a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d7d:	50                   	push   %eax
80105d7e:	6a 02                	push   $0x2
80105d80:	e8 28 f4 ff ff       	call   801051ad <argint>
80105d85:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d88:	85 c0                	test   %eax,%eax
80105d8a:	78 25                	js     80105db1 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d8f:	0f bf c8             	movswl %ax,%ecx
80105d92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d95:	0f bf d0             	movswl %ax,%edx
80105d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9b:	51                   	push   %ecx
80105d9c:	52                   	push   %edx
80105d9d:	6a 03                	push   $0x3
80105d9f:	50                   	push   %eax
80105da0:	e8 cd fb ff ff       	call   80105972 <create>
80105da5:	83 c4 10             	add    $0x10,%esp
80105da8:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105dab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105daf:	75 0c                	jne    80105dbd <sys_mknod+0x7b>
    end_op();
80105db1:	e8 12 d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dbb:	eb 18                	jmp    80105dd5 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105dbd:	83 ec 0c             	sub    $0xc,%esp
80105dc0:	ff 75 f4             	push   -0xc(%ebp)
80105dc3:	e8 53 be ff ff       	call   80101c1b <iunlockput>
80105dc8:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dcb:	e8 f8 d2 ff ff       	call   801030c8 <end_op>
  return 0;
80105dd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dd5:	c9                   	leave  
80105dd6:	c3                   	ret    

80105dd7 <sys_chdir>:

int
sys_chdir(void)
{
80105dd7:	55                   	push   %ebp
80105dd8:	89 e5                	mov    %esp,%ebp
80105dda:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105ddd:	e8 7c dc ff ff       	call   80103a5e <myproc>
80105de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105de5:	e8 52 d2 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105dea:	83 ec 08             	sub    $0x8,%esp
80105ded:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105df0:	50                   	push   %eax
80105df1:	6a 00                	push   $0x0
80105df3:	e8 4a f4 ff ff       	call   80105242 <argstr>
80105df8:	83 c4 10             	add    $0x10,%esp
80105dfb:	85 c0                	test   %eax,%eax
80105dfd:	78 18                	js     80105e17 <sys_chdir+0x40>
80105dff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e02:	83 ec 0c             	sub    $0xc,%esp
80105e05:	50                   	push   %eax
80105e06:	e8 12 c7 ff ff       	call   8010251d <namei>
80105e0b:	83 c4 10             	add    $0x10,%esp
80105e0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e15:	75 0c                	jne    80105e23 <sys_chdir+0x4c>
    end_op();
80105e17:	e8 ac d2 ff ff       	call   801030c8 <end_op>
    return -1;
80105e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e21:	eb 68                	jmp    80105e8b <sys_chdir+0xb4>
  }
  ilock(ip);
80105e23:	83 ec 0c             	sub    $0xc,%esp
80105e26:	ff 75 f0             	push   -0x10(%ebp)
80105e29:	e8 bc bb ff ff       	call   801019ea <ilock>
80105e2e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e34:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e38:	66 83 f8 01          	cmp    $0x1,%ax
80105e3c:	74 1a                	je     80105e58 <sys_chdir+0x81>
    iunlockput(ip);
80105e3e:	83 ec 0c             	sub    $0xc,%esp
80105e41:	ff 75 f0             	push   -0x10(%ebp)
80105e44:	e8 d2 bd ff ff       	call   80101c1b <iunlockput>
80105e49:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e4c:	e8 77 d2 ff ff       	call   801030c8 <end_op>
    return -1;
80105e51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e56:	eb 33                	jmp    80105e8b <sys_chdir+0xb4>
  }
  iunlock(ip);
80105e58:	83 ec 0c             	sub    $0xc,%esp
80105e5b:	ff 75 f0             	push   -0x10(%ebp)
80105e5e:	e8 9a bc ff ff       	call   80101afd <iunlock>
80105e63:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e69:	8b 40 68             	mov    0x68(%eax),%eax
80105e6c:	83 ec 0c             	sub    $0xc,%esp
80105e6f:	50                   	push   %eax
80105e70:	e8 d6 bc ff ff       	call   80101b4b <iput>
80105e75:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e78:	e8 4b d2 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e80:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e83:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e86:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e8b:	c9                   	leave  
80105e8c:	c3                   	ret    

80105e8d <sys_exec>:

int
sys_exec(void)
{
80105e8d:	55                   	push   %ebp
80105e8e:	89 e5                	mov    %esp,%ebp
80105e90:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e96:	83 ec 08             	sub    $0x8,%esp
80105e99:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e9c:	50                   	push   %eax
80105e9d:	6a 00                	push   $0x0
80105e9f:	e8 9e f3 ff ff       	call   80105242 <argstr>
80105ea4:	83 c4 10             	add    $0x10,%esp
80105ea7:	85 c0                	test   %eax,%eax
80105ea9:	78 18                	js     80105ec3 <sys_exec+0x36>
80105eab:	83 ec 08             	sub    $0x8,%esp
80105eae:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105eb4:	50                   	push   %eax
80105eb5:	6a 01                	push   $0x1
80105eb7:	e8 f1 f2 ff ff       	call   801051ad <argint>
80105ebc:	83 c4 10             	add    $0x10,%esp
80105ebf:	85 c0                	test   %eax,%eax
80105ec1:	79 0a                	jns    80105ecd <sys_exec+0x40>
    return -1;
80105ec3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec8:	e9 c6 00 00 00       	jmp    80105f93 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105ecd:	83 ec 04             	sub    $0x4,%esp
80105ed0:	68 80 00 00 00       	push   $0x80
80105ed5:	6a 00                	push   $0x0
80105ed7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105edd:	50                   	push   %eax
80105ede:	e8 9f ef ff ff       	call   80104e82 <memset>
80105ee3:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105ee6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef0:	83 f8 1f             	cmp    $0x1f,%eax
80105ef3:	76 0a                	jbe    80105eff <sys_exec+0x72>
      return -1;
80105ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105efa:	e9 94 00 00 00       	jmp    80105f93 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f02:	c1 e0 02             	shl    $0x2,%eax
80105f05:	89 c2                	mov    %eax,%edx
80105f07:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105f0d:	01 c2                	add    %eax,%edx
80105f0f:	83 ec 08             	sub    $0x8,%esp
80105f12:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105f18:	50                   	push   %eax
80105f19:	52                   	push   %edx
80105f1a:	e8 ed f1 ff ff       	call   8010510c <fetchint>
80105f1f:	83 c4 10             	add    $0x10,%esp
80105f22:	85 c0                	test   %eax,%eax
80105f24:	79 07                	jns    80105f2d <sys_exec+0xa0>
      return -1;
80105f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f2b:	eb 66                	jmp    80105f93 <sys_exec+0x106>
    if(uarg == 0){
80105f2d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f33:	85 c0                	test   %eax,%eax
80105f35:	75 27                	jne    80105f5e <sys_exec+0xd1>
      argv[i] = 0;
80105f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3a:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105f41:	00 00 00 00 
      break;
80105f45:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f49:	83 ec 08             	sub    $0x8,%esp
80105f4c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f52:	52                   	push   %edx
80105f53:	50                   	push   %eax
80105f54:	e8 27 ac ff ff       	call   80100b80 <exec>
80105f59:	83 c4 10             	add    $0x10,%esp
80105f5c:	eb 35                	jmp    80105f93 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105f5e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f67:	c1 e0 02             	shl    $0x2,%eax
80105f6a:	01 c2                	add    %eax,%edx
80105f6c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f72:	83 ec 08             	sub    $0x8,%esp
80105f75:	52                   	push   %edx
80105f76:	50                   	push   %eax
80105f77:	e8 cf f1 ff ff       	call   8010514b <fetchstr>
80105f7c:	83 c4 10             	add    $0x10,%esp
80105f7f:	85 c0                	test   %eax,%eax
80105f81:	79 07                	jns    80105f8a <sys_exec+0xfd>
      return -1;
80105f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f88:	eb 09                	jmp    80105f93 <sys_exec+0x106>
  for(i=0;; i++){
80105f8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f8e:	e9 5a ff ff ff       	jmp    80105eed <sys_exec+0x60>
}
80105f93:	c9                   	leave  
80105f94:	c3                   	ret    

80105f95 <sys_pipe>:

int
sys_pipe(void)
{
80105f95:	55                   	push   %ebp
80105f96:	89 e5                	mov    %esp,%ebp
80105f98:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f9b:	83 ec 04             	sub    $0x4,%esp
80105f9e:	6a 08                	push   $0x8
80105fa0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fa3:	50                   	push   %eax
80105fa4:	6a 00                	push   $0x0
80105fa6:	e8 2f f2 ff ff       	call   801051da <argptr>
80105fab:	83 c4 10             	add    $0x10,%esp
80105fae:	85 c0                	test   %eax,%eax
80105fb0:	79 0a                	jns    80105fbc <sys_pipe+0x27>
    return -1;
80105fb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb7:	e9 ae 00 00 00       	jmp    8010606a <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105fbc:	83 ec 08             	sub    $0x8,%esp
80105fbf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fc2:	50                   	push   %eax
80105fc3:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fc6:	50                   	push   %eax
80105fc7:	e8 a1 d5 ff ff       	call   8010356d <pipealloc>
80105fcc:	83 c4 10             	add    $0x10,%esp
80105fcf:	85 c0                	test   %eax,%eax
80105fd1:	79 0a                	jns    80105fdd <sys_pipe+0x48>
    return -1;
80105fd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd8:	e9 8d 00 00 00       	jmp    8010606a <sys_pipe+0xd5>
  fd0 = -1;
80105fdd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105fe4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fe7:	83 ec 0c             	sub    $0xc,%esp
80105fea:	50                   	push   %eax
80105feb:	e8 7b f3 ff ff       	call   8010536b <fdalloc>
80105ff0:	83 c4 10             	add    $0x10,%esp
80105ff3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ff6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ffa:	78 18                	js     80106014 <sys_pipe+0x7f>
80105ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fff:	83 ec 0c             	sub    $0xc,%esp
80106002:	50                   	push   %eax
80106003:	e8 63 f3 ff ff       	call   8010536b <fdalloc>
80106008:	83 c4 10             	add    $0x10,%esp
8010600b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010600e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106012:	79 3e                	jns    80106052 <sys_pipe+0xbd>
    if(fd0 >= 0)
80106014:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106018:	78 13                	js     8010602d <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
8010601a:	e8 3f da ff ff       	call   80103a5e <myproc>
8010601f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106022:	83 c2 08             	add    $0x8,%edx
80106025:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010602c:	00 
    fileclose(rf);
8010602d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106030:	83 ec 0c             	sub    $0xc,%esp
80106033:	50                   	push   %eax
80106034:	e8 62 b0 ff ff       	call   8010109b <fileclose>
80106039:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010603c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010603f:	83 ec 0c             	sub    $0xc,%esp
80106042:	50                   	push   %eax
80106043:	e8 53 b0 ff ff       	call   8010109b <fileclose>
80106048:	83 c4 10             	add    $0x10,%esp
    return -1;
8010604b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106050:	eb 18                	jmp    8010606a <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106052:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106055:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106058:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010605a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010605d:	8d 50 04             	lea    0x4(%eax),%edx
80106060:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106063:	89 02                	mov    %eax,(%edx)
  return 0;
80106065:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010606a:	c9                   	leave  
8010606b:	c3                   	ret    

8010606c <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
8010606c:	55                   	push   %ebp
8010606d:	89 e5                	mov    %esp,%ebp
8010606f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106072:	e8 39 dd ff ff       	call   80103db0 <fork>
}
80106077:	c9                   	leave  
80106078:	c3                   	ret    

80106079 <sys_exit>:

int
sys_exit(void)
{
80106079:	55                   	push   %ebp
8010607a:	89 e5                	mov    %esp,%ebp
8010607c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010607f:	e8 f5 de ff ff       	call   80103f79 <exit>
  return 0;  // not reached
80106084:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106089:	c9                   	leave  
8010608a:	c3                   	ret    

8010608b <sys_wait>:

int
sys_wait(void)
{
8010608b:	55                   	push   %ebp
8010608c:	89 e5                	mov    %esp,%ebp
8010608e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106091:	e8 06 e0 ff ff       	call   8010409c <wait>
}
80106096:	c9                   	leave  
80106097:	c3                   	ret    

80106098 <sys_kill>:

int
sys_kill(void)
{
80106098:	55                   	push   %ebp
80106099:	89 e5                	mov    %esp,%ebp
8010609b:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010609e:	83 ec 08             	sub    $0x8,%esp
801060a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060a4:	50                   	push   %eax
801060a5:	6a 00                	push   $0x0
801060a7:	e8 01 f1 ff ff       	call   801051ad <argint>
801060ac:	83 c4 10             	add    $0x10,%esp
801060af:	85 c0                	test   %eax,%eax
801060b1:	79 07                	jns    801060ba <sys_kill+0x22>
    return -1;
801060b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b8:	eb 0f                	jmp    801060c9 <sys_kill+0x31>
  return kill(pid);
801060ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bd:	83 ec 0c             	sub    $0xc,%esp
801060c0:	50                   	push   %eax
801060c1:	e8 e4 e5 ff ff       	call   801046aa <kill>
801060c6:	83 c4 10             	add    $0x10,%esp
}
801060c9:	c9                   	leave  
801060ca:	c3                   	ret    

801060cb <sys_getpid>:

int
sys_getpid(void)
{
801060cb:	55                   	push   %ebp
801060cc:	89 e5                	mov    %esp,%ebp
801060ce:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801060d1:	e8 88 d9 ff ff       	call   80103a5e <myproc>
801060d6:	8b 40 10             	mov    0x10(%eax),%eax
}
801060d9:	c9                   	leave  
801060da:	c3                   	ret    

801060db <sys_sbrk>:

int
sys_sbrk(void)
{
801060db:	55                   	push   %ebp
801060dc:	89 e5                	mov    %esp,%ebp
801060de:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801060e1:	83 ec 08             	sub    $0x8,%esp
801060e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060e7:	50                   	push   %eax
801060e8:	6a 00                	push   $0x0
801060ea:	e8 be f0 ff ff       	call   801051ad <argint>
801060ef:	83 c4 10             	add    $0x10,%esp
801060f2:	85 c0                	test   %eax,%eax
801060f4:	79 07                	jns    801060fd <sys_sbrk+0x22>
    return -1;
801060f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060fb:	eb 27                	jmp    80106124 <sys_sbrk+0x49>
  addr = myproc()->sz;
801060fd:	e8 5c d9 ff ff       	call   80103a5e <myproc>
80106102:	8b 00                	mov    (%eax),%eax
80106104:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106107:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010610a:	83 ec 0c             	sub    $0xc,%esp
8010610d:	50                   	push   %eax
8010610e:	e8 02 dc ff ff       	call   80103d15 <growproc>
80106113:	83 c4 10             	add    $0x10,%esp
80106116:	85 c0                	test   %eax,%eax
80106118:	79 07                	jns    80106121 <sys_sbrk+0x46>
    return -1;
8010611a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611f:	eb 03                	jmp    80106124 <sys_sbrk+0x49>
  return addr;
80106121:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106124:	c9                   	leave  
80106125:	c3                   	ret    

80106126 <sys_sleep>:

int
sys_sleep(void)
{
80106126:	55                   	push   %ebp
80106127:	89 e5                	mov    %esp,%ebp
80106129:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010612c:	83 ec 08             	sub    $0x8,%esp
8010612f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106132:	50                   	push   %eax
80106133:	6a 00                	push   $0x0
80106135:	e8 73 f0 ff ff       	call   801051ad <argint>
8010613a:	83 c4 10             	add    $0x10,%esp
8010613d:	85 c0                	test   %eax,%eax
8010613f:	79 07                	jns    80106148 <sys_sleep+0x22>
    return -1;
80106141:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106146:	eb 76                	jmp    801061be <sys_sleep+0x98>
  acquire(&tickslock);
80106148:	83 ec 0c             	sub    $0xc,%esp
8010614b:	68 80 76 19 80       	push   $0x80197680
80106150:	e8 b7 ea ff ff       	call   80104c0c <acquire>
80106155:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106158:	a1 b4 76 19 80       	mov    0x801976b4,%eax
8010615d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106160:	eb 38                	jmp    8010619a <sys_sleep+0x74>
    if(myproc()->killed){
80106162:	e8 f7 d8 ff ff       	call   80103a5e <myproc>
80106167:	8b 40 24             	mov    0x24(%eax),%eax
8010616a:	85 c0                	test   %eax,%eax
8010616c:	74 17                	je     80106185 <sys_sleep+0x5f>
      release(&tickslock);
8010616e:	83 ec 0c             	sub    $0xc,%esp
80106171:	68 80 76 19 80       	push   $0x80197680
80106176:	e8 ff ea ff ff       	call   80104c7a <release>
8010617b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010617e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106183:	eb 39                	jmp    801061be <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106185:	83 ec 08             	sub    $0x8,%esp
80106188:	68 80 76 19 80       	push   $0x80197680
8010618d:	68 b4 76 19 80       	push   $0x801976b4
80106192:	e8 f2 e3 ff ff       	call   80104589 <sleep>
80106197:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010619a:	a1 b4 76 19 80       	mov    0x801976b4,%eax
8010619f:	2b 45 f4             	sub    -0xc(%ebp),%eax
801061a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061a5:	39 d0                	cmp    %edx,%eax
801061a7:	72 b9                	jb     80106162 <sys_sleep+0x3c>
  }
  release(&tickslock);
801061a9:	83 ec 0c             	sub    $0xc,%esp
801061ac:	68 80 76 19 80       	push   $0x80197680
801061b1:	e8 c4 ea ff ff       	call   80104c7a <release>
801061b6:	83 c4 10             	add    $0x10,%esp
  return 0;
801061b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061be:	c9                   	leave  
801061bf:	c3                   	ret    

801061c0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801061c0:	55                   	push   %ebp
801061c1:	89 e5                	mov    %esp,%ebp
801061c3:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801061c6:	83 ec 0c             	sub    $0xc,%esp
801061c9:	68 80 76 19 80       	push   $0x80197680
801061ce:	e8 39 ea ff ff       	call   80104c0c <acquire>
801061d3:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061d6:	a1 b4 76 19 80       	mov    0x801976b4,%eax
801061db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061de:	83 ec 0c             	sub    $0xc,%esp
801061e1:	68 80 76 19 80       	push   $0x80197680
801061e6:	e8 8f ea ff ff       	call   80104c7a <release>
801061eb:	83 c4 10             	add    $0x10,%esp
  return xticks;
801061ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061f1:	c9                   	leave  
801061f2:	c3                   	ret    

801061f3 <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
801061f3:	55                   	push   %ebp
801061f4:	89 e5                	mov    %esp,%ebp
801061f6:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
801061f9:	83 ec 08             	sub    $0x8,%esp
801061fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061ff:	50                   	push   %eax
80106200:	6a 00                	push   $0x0
80106202:	e8 a6 ef ff ff       	call   801051ad <argint>
80106207:	83 c4 10             	add    $0x10,%esp
8010620a:	85 c0                	test   %eax,%eax
8010620c:	79 07                	jns    80106215 <sys_setSchedPolicy+0x22>
    return -1;
8010620e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106213:	eb 0f                	jmp    80106224 <sys_setSchedPolicy+0x31>
  return setSchedPolicy(policy);
80106215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106218:	83 ec 0c             	sub    $0xc,%esp
8010621b:	50                   	push   %eax
8010621c:	e8 1b e7 ff ff       	call   8010493c <setSchedPolicy>
80106221:	83 c4 10             	add    $0x10,%esp
}
80106224:	c9                   	leave  
80106225:	c3                   	ret    

80106226 <sys_getpinfo>:



int
sys_getpinfo(void)
{
80106226:	55                   	push   %ebp
80106227:	89 e5                	mov    %esp,%ebp
80106229:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (void*)&ps, sizeof(*ps)) < 0)
8010622c:	83 ec 04             	sub    $0x4,%esp
8010622f:	68 00 0c 00 00       	push   $0xc00
80106234:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106237:	50                   	push   %eax
80106238:	6a 00                	push   $0x0
8010623a:	e8 9b ef ff ff       	call   801051da <argptr>
8010623f:	83 c4 10             	add    $0x10,%esp
80106242:	85 c0                	test   %eax,%eax
80106244:	79 07                	jns    8010624d <sys_getpinfo+0x27>
    return -1;
80106246:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624b:	eb 0f                	jmp    8010625c <sys_getpinfo+0x36>
  return getpinfo(ps);
8010624d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106250:	83 ec 0c             	sub    $0xc,%esp
80106253:	50                   	push   %eax
80106254:	e8 1b e7 ff ff       	call   80104974 <getpinfo>
80106259:	83 c4 10             	add    $0x10,%esp
}
8010625c:	c9                   	leave  
8010625d:	c3                   	ret    

8010625e <sys_yield>:

int
sys_yield(void)
{
8010625e:	55                   	push   %ebp
8010625f:	89 e5                	mov    %esp,%ebp
80106261:	83 ec 08             	sub    $0x8,%esp
  yield();
80106264:	e8 6a e2 ff ff       	call   801044d3 <yield>
  return 0;
80106269:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010626e:	c9                   	leave  
8010626f:	c3                   	ret    

80106270 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106270:	1e                   	push   %ds
  pushl %es
80106271:	06                   	push   %es
  pushl %fs
80106272:	0f a0                	push   %fs
  pushl %gs
80106274:	0f a8                	push   %gs
  pushal
80106276:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106277:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010627b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010627d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010627f:	54                   	push   %esp
  call trap
80106280:	e8 d7 01 00 00       	call   8010645c <trap>
  addl $4, %esp
80106285:	83 c4 04             	add    $0x4,%esp

80106288 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106288:	61                   	popa   
  popl %gs
80106289:	0f a9                	pop    %gs
  popl %fs
8010628b:	0f a1                	pop    %fs
  popl %es
8010628d:	07                   	pop    %es
  popl %ds
8010628e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010628f:	83 c4 08             	add    $0x8,%esp
  iret
80106292:	cf                   	iret   

80106293 <lidt>:
{
80106293:	55                   	push   %ebp
80106294:	89 e5                	mov    %esp,%ebp
80106296:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106299:	8b 45 0c             	mov    0xc(%ebp),%eax
8010629c:	83 e8 01             	sub    $0x1,%eax
8010629f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801062a3:	8b 45 08             	mov    0x8(%ebp),%eax
801062a6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801062aa:	8b 45 08             	mov    0x8(%ebp),%eax
801062ad:	c1 e8 10             	shr    $0x10,%eax
801062b0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801062b4:	8d 45 fa             	lea    -0x6(%ebp),%eax
801062b7:	0f 01 18             	lidtl  (%eax)
}
801062ba:	90                   	nop
801062bb:	c9                   	leave  
801062bc:	c3                   	ret    

801062bd <rcr2>:

static inline uint
rcr2(void)
{
801062bd:	55                   	push   %ebp
801062be:	89 e5                	mov    %esp,%ebp
801062c0:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801062c3:	0f 20 d0             	mov    %cr2,%eax
801062c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801062c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801062cc:	c9                   	leave  
801062cd:	c3                   	ret    

801062ce <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801062ce:	55                   	push   %ebp
801062cf:	89 e5                	mov    %esp,%ebp
801062d1:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801062d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062db:	e9 c3 00 00 00       	jmp    801063a3 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801062e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e3:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
801062ea:	89 c2                	mov    %eax,%edx
801062ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ef:	66 89 14 c5 80 6e 19 	mov    %dx,-0x7fe69180(,%eax,8)
801062f6:	80 
801062f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062fa:	66 c7 04 c5 82 6e 19 	movw   $0x8,-0x7fe6917e(,%eax,8)
80106301:	80 08 00 
80106304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106307:	0f b6 14 c5 84 6e 19 	movzbl -0x7fe6917c(,%eax,8),%edx
8010630e:	80 
8010630f:	83 e2 e0             	and    $0xffffffe0,%edx
80106312:	88 14 c5 84 6e 19 80 	mov    %dl,-0x7fe6917c(,%eax,8)
80106319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631c:	0f b6 14 c5 84 6e 19 	movzbl -0x7fe6917c(,%eax,8),%edx
80106323:	80 
80106324:	83 e2 1f             	and    $0x1f,%edx
80106327:	88 14 c5 84 6e 19 80 	mov    %dl,-0x7fe6917c(,%eax,8)
8010632e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106331:	0f b6 14 c5 85 6e 19 	movzbl -0x7fe6917b(,%eax,8),%edx
80106338:	80 
80106339:	83 e2 f0             	and    $0xfffffff0,%edx
8010633c:	83 ca 0e             	or     $0xe,%edx
8010633f:	88 14 c5 85 6e 19 80 	mov    %dl,-0x7fe6917b(,%eax,8)
80106346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106349:	0f b6 14 c5 85 6e 19 	movzbl -0x7fe6917b(,%eax,8),%edx
80106350:	80 
80106351:	83 e2 ef             	and    $0xffffffef,%edx
80106354:	88 14 c5 85 6e 19 80 	mov    %dl,-0x7fe6917b(,%eax,8)
8010635b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635e:	0f b6 14 c5 85 6e 19 	movzbl -0x7fe6917b(,%eax,8),%edx
80106365:	80 
80106366:	83 e2 9f             	and    $0xffffff9f,%edx
80106369:	88 14 c5 85 6e 19 80 	mov    %dl,-0x7fe6917b(,%eax,8)
80106370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106373:	0f b6 14 c5 85 6e 19 	movzbl -0x7fe6917b(,%eax,8),%edx
8010637a:	80 
8010637b:	83 ca 80             	or     $0xffffff80,%edx
8010637e:	88 14 c5 85 6e 19 80 	mov    %dl,-0x7fe6917b(,%eax,8)
80106385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106388:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
8010638f:	c1 e8 10             	shr    $0x10,%eax
80106392:	89 c2                	mov    %eax,%edx
80106394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106397:	66 89 14 c5 86 6e 19 	mov    %dx,-0x7fe6917a(,%eax,8)
8010639e:	80 
  for(i = 0; i < 256; i++)
8010639f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063a3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801063aa:	0f 8e 30 ff ff ff    	jle    801062e0 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801063b0:	a1 84 f1 10 80       	mov    0x8010f184,%eax
801063b5:	66 a3 80 70 19 80    	mov    %ax,0x80197080
801063bb:	66 c7 05 82 70 19 80 	movw   $0x8,0x80197082
801063c2:	08 00 
801063c4:	0f b6 05 84 70 19 80 	movzbl 0x80197084,%eax
801063cb:	83 e0 e0             	and    $0xffffffe0,%eax
801063ce:	a2 84 70 19 80       	mov    %al,0x80197084
801063d3:	0f b6 05 84 70 19 80 	movzbl 0x80197084,%eax
801063da:	83 e0 1f             	and    $0x1f,%eax
801063dd:	a2 84 70 19 80       	mov    %al,0x80197084
801063e2:	0f b6 05 85 70 19 80 	movzbl 0x80197085,%eax
801063e9:	83 c8 0f             	or     $0xf,%eax
801063ec:	a2 85 70 19 80       	mov    %al,0x80197085
801063f1:	0f b6 05 85 70 19 80 	movzbl 0x80197085,%eax
801063f8:	83 e0 ef             	and    $0xffffffef,%eax
801063fb:	a2 85 70 19 80       	mov    %al,0x80197085
80106400:	0f b6 05 85 70 19 80 	movzbl 0x80197085,%eax
80106407:	83 c8 60             	or     $0x60,%eax
8010640a:	a2 85 70 19 80       	mov    %al,0x80197085
8010640f:	0f b6 05 85 70 19 80 	movzbl 0x80197085,%eax
80106416:	83 c8 80             	or     $0xffffff80,%eax
80106419:	a2 85 70 19 80       	mov    %al,0x80197085
8010641e:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80106423:	c1 e8 10             	shr    $0x10,%eax
80106426:	66 a3 86 70 19 80    	mov    %ax,0x80197086

  initlock(&tickslock, "time");
8010642c:	83 ec 08             	sub    $0x8,%esp
8010642f:	68 18 ab 10 80       	push   $0x8010ab18
80106434:	68 80 76 19 80       	push   $0x80197680
80106439:	e8 ac e7 ff ff       	call   80104bea <initlock>
8010643e:	83 c4 10             	add    $0x10,%esp
}
80106441:	90                   	nop
80106442:	c9                   	leave  
80106443:	c3                   	ret    

80106444 <idtinit>:

void
idtinit(void)
{
80106444:	55                   	push   %ebp
80106445:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106447:	68 00 08 00 00       	push   $0x800
8010644c:	68 80 6e 19 80       	push   $0x80196e80
80106451:	e8 3d fe ff ff       	call   80106293 <lidt>
80106456:	83 c4 08             	add    $0x8,%esp
}
80106459:	90                   	nop
8010645a:	c9                   	leave  
8010645b:	c3                   	ret    

8010645c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010645c:	55                   	push   %ebp
8010645d:	89 e5                	mov    %esp,%ebp
8010645f:	57                   	push   %edi
80106460:	56                   	push   %esi
80106461:	53                   	push   %ebx
80106462:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106465:	8b 45 08             	mov    0x8(%ebp),%eax
80106468:	8b 40 30             	mov    0x30(%eax),%eax
8010646b:	83 f8 40             	cmp    $0x40,%eax
8010646e:	75 3b                	jne    801064ab <trap+0x4f>
    if(myproc()->killed)
80106470:	e8 e9 d5 ff ff       	call   80103a5e <myproc>
80106475:	8b 40 24             	mov    0x24(%eax),%eax
80106478:	85 c0                	test   %eax,%eax
8010647a:	74 05                	je     80106481 <trap+0x25>
      exit();
8010647c:	e8 f8 da ff ff       	call   80103f79 <exit>
    myproc()->tf = tf;
80106481:	e8 d8 d5 ff ff       	call   80103a5e <myproc>
80106486:	8b 55 08             	mov    0x8(%ebp),%edx
80106489:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010648c:	e8 e8 ed ff ff       	call   80105279 <syscall>
    if(myproc()->killed)
80106491:	e8 c8 d5 ff ff       	call   80103a5e <myproc>
80106496:	8b 40 24             	mov    0x24(%eax),%eax
80106499:	85 c0                	test   %eax,%eax
8010649b:	0f 84 dd 03 00 00    	je     8010687e <trap+0x422>
      exit();
801064a1:	e8 d3 da ff ff       	call   80103f79 <exit>
    return;
801064a6:	e9 d3 03 00 00       	jmp    8010687e <trap+0x422>
  }

  switch(tf->trapno){
801064ab:	8b 45 08             	mov    0x8(%ebp),%eax
801064ae:	8b 40 30             	mov    0x30(%eax),%eax
801064b1:	83 e8 20             	sub    $0x20,%eax
801064b4:	83 f8 1f             	cmp    $0x1f,%eax
801064b7:	0f 87 8c 02 00 00    	ja     80106749 <trap+0x2ed>
801064bd:	8b 04 85 c0 ab 10 80 	mov    -0x7fef5440(,%eax,4),%eax
801064c4:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801064c6:	e8 00 d5 ff ff       	call   801039cb <cpuid>
801064cb:	85 c0                	test   %eax,%eax
801064cd:	75 3d                	jne    8010650c <trap+0xb0>
      acquire(&tickslock);
801064cf:	83 ec 0c             	sub    $0xc,%esp
801064d2:	68 80 76 19 80       	push   $0x80197680
801064d7:	e8 30 e7 ff ff       	call   80104c0c <acquire>
801064dc:	83 c4 10             	add    $0x10,%esp
      ticks++;
801064df:	a1 b4 76 19 80       	mov    0x801976b4,%eax
801064e4:	83 c0 01             	add    $0x1,%eax
801064e7:	a3 b4 76 19 80       	mov    %eax,0x801976b4
      wakeup(&ticks);
801064ec:	83 ec 0c             	sub    $0xc,%esp
801064ef:	68 b4 76 19 80       	push   $0x801976b4
801064f4:	e8 7a e1 ff ff       	call   80104673 <wakeup>
801064f9:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801064fc:	83 ec 0c             	sub    $0xc,%esp
801064ff:	68 80 76 19 80       	push   $0x80197680
80106504:	e8 71 e7 ff ff       	call   80104c7a <release>
80106509:	83 c4 10             	add    $0x10,%esp
    }
    // 현재 실행 중인 프로세스의 tick 증가
    struct proc *curproc = myproc();
8010650c:	e8 4d d5 ff ff       	call   80103a5e <myproc>
80106511:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (curproc && curproc->state == RUNNING) {
80106514:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106518:	74 2f                	je     80106549 <trap+0xed>
8010651a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010651d:	8b 40 0c             	mov    0xc(%eax),%eax
80106520:	83 f8 04             	cmp    $0x4,%eax
80106523:	75 24                	jne    80106549 <trap+0xed>
      int q = curproc->priority;
80106525:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106528:	8b 40 7c             	mov    0x7c(%eax),%eax
8010652b:	89 45 d8             	mov    %eax,-0x28(%ebp)
      curproc->ticks[q]++;
8010652e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106531:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106534:	83 c2 20             	add    $0x20,%edx
80106537:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010653a:	8d 48 01             	lea    0x1(%eax),%ecx
8010653d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106540:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106543:	83 c2 20             	add    $0x20,%edx
80106546:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    }
    
    acquire(&ptable.lock);
80106549:	83 ec 0c             	sub    $0xc,%esp
8010654c:	68 00 42 19 80       	push   $0x80194200
80106551:	e8 b6 e6 ff ff       	call   80104c0c <acquire>
80106556:	83 c4 10             	add    $0x10,%esp
    //// RUNNABLE 상태인 다른 프로세스들의 wait_ticks 증가
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106559:	c7 45 e4 34 42 19 80 	movl   $0x80194234,-0x1c(%ebp)
80106560:	eb 4a                	jmp    801065ac <trap+0x150>
      if (p->state == RUNNABLE && p != curproc) {
80106562:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106565:	8b 40 0c             	mov    0xc(%eax),%eax
80106568:	83 f8 03             	cmp    $0x3,%eax
8010656b:	75 38                	jne    801065a5 <trap+0x149>
8010656d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106570:	3b 45 dc             	cmp    -0x24(%ebp),%eax
80106573:	74 30                	je     801065a5 <trap+0x149>
        int q = p->priority;
80106575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106578:	8b 40 7c             	mov    0x7c(%eax),%eax
8010657b:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if ( q >=0 && q< MLFQ_LEVELS){
8010657e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80106582:	78 21                	js     801065a5 <trap+0x149>
80106584:	83 7d d0 03          	cmpl   $0x3,-0x30(%ebp)
80106588:	7f 1b                	jg     801065a5 <trap+0x149>
          p->wait_ticks[q]++;
8010658a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010658d:	8b 55 d0             	mov    -0x30(%ebp),%edx
80106590:	83 c2 24             	add    $0x24,%edx
80106593:	8b 04 90             	mov    (%eax,%edx,4),%eax
80106596:	8d 48 01             	lea    0x1(%eax),%ecx
80106599:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010659c:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010659f:	83 c2 24             	add    $0x24,%edx
801065a2:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801065a5:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
801065ac:	81 7d e4 34 6a 19 80 	cmpl   $0x80196a34,-0x1c(%ebp)
801065b3:	72 ad                	jb     80106562 <trap+0x106>
        }
        
      }
    }
    //priority boost 조건 확인 (policy == 1일 때만)
    if (mycpu()->sched_policy == 1) {
801065b5:	e8 2c d4 ff ff       	call   801039e6 <mycpu>
801065ba:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801065c0:	83 f8 01             	cmp    $0x1,%eax
801065c3:	0f 85 fb 00 00 00    	jne    801066c4 <trap+0x268>
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801065c9:	c7 45 e0 34 42 19 80 	movl   $0x80194234,-0x20(%ebp)
801065d0:	e9 e2 00 00 00       	jmp    801066b7 <trap+0x25b>
        if (p -> state != RUNNABLE) continue;
801065d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801065d8:	8b 40 0c             	mov    0xc(%eax),%eax
801065db:	83 f8 03             	cmp    $0x3,%eax
801065de:	0f 85 cb 00 00 00    	jne    801066af <trap+0x253>
        int q = p->priority;
801065e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801065e7:	8b 40 7c             	mov    0x7c(%eax),%eax
801065ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        //Q0 -> Q1
        if (q == 0 && p->wait_ticks[0] >= 500) {
801065ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801065f1:	75 3a                	jne    8010662d <trap+0x1d1>
801065f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801065f6:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801065fc:	3d f3 01 00 00       	cmp    $0x1f3,%eax
80106601:	7e 2a                	jle    8010662d <trap+0x1d1>
          p->priority = 1;
80106603:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106606:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
          p->wait_ticks[0] = 0;
8010660d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106610:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80106617:	00 00 00 
          enqueue(&mlfq[1], p);
8010661a:	83 ec 08             	sub    $0x8,%esp
8010661d:	ff 75 e0             	push   -0x20(%ebp)
80106620:	68 48 6b 19 80       	push   $0x80196b48
80106625:	e8 46 e1 ff ff       	call   80104770 <enqueue>
8010662a:	83 c4 10             	add    $0x10,%esp
        }
  
        // Q1 -> Q2
        if (q == 1 && p->wait_ticks[1] >= 160){
8010662d:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
80106631:	75 3c                	jne    8010666f <trap+0x213>
80106633:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106636:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010663c:	3d 9f 00 00 00       	cmp    $0x9f,%eax
80106641:	7e 2c                	jle    8010666f <trap+0x213>
          p->priority = 2;  
80106643:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106646:	c7 40 7c 02 00 00 00 	movl   $0x2,0x7c(%eax)
          p->wait_ticks[1] = 0;
8010664d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106650:	c7 80 94 00 00 00 00 	movl   $0x0,0x94(%eax)
80106657:	00 00 00 
          enqueue(&mlfq[2], p);
8010665a:	83 ec 08             	sub    $0x8,%esp
8010665d:	ff 75 e0             	push   -0x20(%ebp)
80106660:	68 50 6c 19 80       	push   $0x80196c50
80106665:	e8 06 e1 ff ff       	call   80104770 <enqueue>
8010666a:	83 c4 10             	add    $0x10,%esp
8010666d:	eb 41                	jmp    801066b0 <trap+0x254>
        }
        //Q2 ->Q3
        else if (q == 2 && p->wait_ticks[2] >= 80){
8010666f:	83 7d d4 02          	cmpl   $0x2,-0x2c(%ebp)
80106673:	75 3b                	jne    801066b0 <trap+0x254>
80106675:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106678:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010667e:	83 f8 4f             	cmp    $0x4f,%eax
80106681:	7e 2d                	jle    801066b0 <trap+0x254>
          p->priority = 3;
80106683:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106686:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
          p->wait_ticks[2] = 0;
8010668d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106690:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
80106697:	00 00 00 
          enqueue(&mlfq[3], p);
8010669a:	83 ec 08             	sub    $0x8,%esp
8010669d:	ff 75 e0             	push   -0x20(%ebp)
801066a0:	68 58 6d 19 80       	push   $0x80196d58
801066a5:	e8 c6 e0 ff ff       	call   80104770 <enqueue>
801066aa:	83 c4 10             	add    $0x10,%esp
801066ad:	eb 01                	jmp    801066b0 <trap+0x254>
        if (p -> state != RUNNABLE) continue;
801066af:	90                   	nop
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801066b0:	81 45 e0 a0 00 00 00 	addl   $0xa0,-0x20(%ebp)
801066b7:	81 7d e0 34 6a 19 80 	cmpl   $0x80196a34,-0x20(%ebp)
801066be:	0f 82 11 ff ff ff    	jb     801065d5 <trap+0x179>
        }
        
      }
    }
    release(&ptable.lock);
801066c4:	83 ec 0c             	sub    $0xc,%esp
801066c7:	68 00 42 19 80       	push   $0x80194200
801066cc:	e8 a9 e5 ff ff       	call   80104c7a <release>
801066d1:	83 c4 10             	add    $0x10,%esp

 
  
    lapiceoi();
801066d4:	e8 43 c4 ff ff       	call   80102b1c <lapiceoi>
    break;
801066d9:	e9 20 01 00 00       	jmp    801067fe <trap+0x3a2>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801066de:	e8 f5 3e 00 00       	call   8010a5d8 <ideintr>
    lapiceoi();
801066e3:	e8 34 c4 ff ff       	call   80102b1c <lapiceoi>
    break;
801066e8:	e9 11 01 00 00       	jmp    801067fe <trap+0x3a2>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801066ed:	e8 6f c2 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
801066f2:	e8 25 c4 ff ff       	call   80102b1c <lapiceoi>
    break;
801066f7:	e9 02 01 00 00       	jmp    801067fe <trap+0x3a2>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801066fc:	e8 53 03 00 00       	call   80106a54 <uartintr>
    lapiceoi();
80106701:	e8 16 c4 ff ff       	call   80102b1c <lapiceoi>
    break;
80106706:	e9 f3 00 00 00       	jmp    801067fe <trap+0x3a2>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010670b:	e8 7b 2b 00 00       	call   8010928b <i8254_intr>
    lapiceoi();
80106710:	e8 07 c4 ff ff       	call   80102b1c <lapiceoi>
    break;
80106715:	e9 e4 00 00 00       	jmp    801067fe <trap+0x3a2>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010671a:	8b 45 08             	mov    0x8(%ebp),%eax
8010671d:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106720:	8b 45 08             	mov    0x8(%ebp),%eax
80106723:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106727:	0f b7 d8             	movzwl %ax,%ebx
8010672a:	e8 9c d2 ff ff       	call   801039cb <cpuid>
8010672f:	56                   	push   %esi
80106730:	53                   	push   %ebx
80106731:	50                   	push   %eax
80106732:	68 20 ab 10 80       	push   $0x8010ab20
80106737:	e8 b8 9c ff ff       	call   801003f4 <cprintf>
8010673c:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010673f:	e8 d8 c3 ff ff       	call   80102b1c <lapiceoi>
    break;
80106744:	e9 b5 00 00 00       	jmp    801067fe <trap+0x3a2>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106749:	e8 10 d3 ff ff       	call   80103a5e <myproc>
8010674e:	85 c0                	test   %eax,%eax
80106750:	74 11                	je     80106763 <trap+0x307>
80106752:	8b 45 08             	mov    0x8(%ebp),%eax
80106755:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106759:	0f b7 c0             	movzwl %ax,%eax
8010675c:	83 e0 03             	and    $0x3,%eax
8010675f:	85 c0                	test   %eax,%eax
80106761:	75 39                	jne    8010679c <trap+0x340>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106763:	e8 55 fb ff ff       	call   801062bd <rcr2>
80106768:	89 c3                	mov    %eax,%ebx
8010676a:	8b 45 08             	mov    0x8(%ebp),%eax
8010676d:	8b 70 38             	mov    0x38(%eax),%esi
80106770:	e8 56 d2 ff ff       	call   801039cb <cpuid>
80106775:	8b 55 08             	mov    0x8(%ebp),%edx
80106778:	8b 52 30             	mov    0x30(%edx),%edx
8010677b:	83 ec 0c             	sub    $0xc,%esp
8010677e:	53                   	push   %ebx
8010677f:	56                   	push   %esi
80106780:	50                   	push   %eax
80106781:	52                   	push   %edx
80106782:	68 44 ab 10 80       	push   $0x8010ab44
80106787:	e8 68 9c ff ff       	call   801003f4 <cprintf>
8010678c:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010678f:	83 ec 0c             	sub    $0xc,%esp
80106792:	68 76 ab 10 80       	push   $0x8010ab76
80106797:	e8 0d 9e ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010679c:	e8 1c fb ff ff       	call   801062bd <rcr2>
801067a1:	89 c6                	mov    %eax,%esi
801067a3:	8b 45 08             	mov    0x8(%ebp),%eax
801067a6:	8b 40 38             	mov    0x38(%eax),%eax
801067a9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
801067ac:	e8 1a d2 ff ff       	call   801039cb <cpuid>
801067b1:	89 c3                	mov    %eax,%ebx
801067b3:	8b 45 08             	mov    0x8(%ebp),%eax
801067b6:	8b 78 34             	mov    0x34(%eax),%edi
801067b9:	89 7d c0             	mov    %edi,-0x40(%ebp)
801067bc:	8b 45 08             	mov    0x8(%ebp),%eax
801067bf:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801067c2:	e8 97 d2 ff ff       	call   80103a5e <myproc>
801067c7:	8d 48 6c             	lea    0x6c(%eax),%ecx
801067ca:	89 4d bc             	mov    %ecx,-0x44(%ebp)
801067cd:	e8 8c d2 ff ff       	call   80103a5e <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067d2:	8b 40 10             	mov    0x10(%eax),%eax
801067d5:	56                   	push   %esi
801067d6:	ff 75 c4             	push   -0x3c(%ebp)
801067d9:	53                   	push   %ebx
801067da:	ff 75 c0             	push   -0x40(%ebp)
801067dd:	57                   	push   %edi
801067de:	ff 75 bc             	push   -0x44(%ebp)
801067e1:	50                   	push   %eax
801067e2:	68 7c ab 10 80       	push   $0x8010ab7c
801067e7:	e8 08 9c ff ff       	call   801003f4 <cprintf>
801067ec:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801067ef:	e8 6a d2 ff ff       	call   80103a5e <myproc>
801067f4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801067fb:	eb 01                	jmp    801067fe <trap+0x3a2>
    break;
801067fd:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801067fe:	e8 5b d2 ff ff       	call   80103a5e <myproc>
80106803:	85 c0                	test   %eax,%eax
80106805:	74 23                	je     8010682a <trap+0x3ce>
80106807:	e8 52 d2 ff ff       	call   80103a5e <myproc>
8010680c:	8b 40 24             	mov    0x24(%eax),%eax
8010680f:	85 c0                	test   %eax,%eax
80106811:	74 17                	je     8010682a <trap+0x3ce>
80106813:	8b 45 08             	mov    0x8(%ebp),%eax
80106816:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010681a:	0f b7 c0             	movzwl %ax,%eax
8010681d:	83 e0 03             	and    $0x3,%eax
80106820:	83 f8 03             	cmp    $0x3,%eax
80106823:	75 05                	jne    8010682a <trap+0x3ce>
    exit();
80106825:	e8 4f d7 ff ff       	call   80103f79 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010682a:	e8 2f d2 ff ff       	call   80103a5e <myproc>
8010682f:	85 c0                	test   %eax,%eax
80106831:	74 1d                	je     80106850 <trap+0x3f4>
80106833:	e8 26 d2 ff ff       	call   80103a5e <myproc>
80106838:	8b 40 0c             	mov    0xc(%eax),%eax
8010683b:	83 f8 04             	cmp    $0x4,%eax
8010683e:	75 10                	jne    80106850 <trap+0x3f4>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106840:	8b 45 08             	mov    0x8(%ebp),%eax
80106843:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106846:	83 f8 20             	cmp    $0x20,%eax
80106849:	75 05                	jne    80106850 <trap+0x3f4>
    yield();
8010684b:	e8 83 dc ff ff       	call   801044d3 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106850:	e8 09 d2 ff ff       	call   80103a5e <myproc>
80106855:	85 c0                	test   %eax,%eax
80106857:	74 26                	je     8010687f <trap+0x423>
80106859:	e8 00 d2 ff ff       	call   80103a5e <myproc>
8010685e:	8b 40 24             	mov    0x24(%eax),%eax
80106861:	85 c0                	test   %eax,%eax
80106863:	74 1a                	je     8010687f <trap+0x423>
80106865:	8b 45 08             	mov    0x8(%ebp),%eax
80106868:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010686c:	0f b7 c0             	movzwl %ax,%eax
8010686f:	83 e0 03             	and    $0x3,%eax
80106872:	83 f8 03             	cmp    $0x3,%eax
80106875:	75 08                	jne    8010687f <trap+0x423>
    exit();
80106877:	e8 fd d6 ff ff       	call   80103f79 <exit>
8010687c:	eb 01                	jmp    8010687f <trap+0x423>
    return;
8010687e:	90                   	nop
8010687f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106882:	5b                   	pop    %ebx
80106883:	5e                   	pop    %esi
80106884:	5f                   	pop    %edi
80106885:	5d                   	pop    %ebp
80106886:	c3                   	ret    

80106887 <inb>:
{
80106887:	55                   	push   %ebp
80106888:	89 e5                	mov    %esp,%ebp
8010688a:	83 ec 14             	sub    $0x14,%esp
8010688d:	8b 45 08             	mov    0x8(%ebp),%eax
80106890:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106894:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106898:	89 c2                	mov    %eax,%edx
8010689a:	ec                   	in     (%dx),%al
8010689b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010689e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801068a2:	c9                   	leave  
801068a3:	c3                   	ret    

801068a4 <outb>:
{
801068a4:	55                   	push   %ebp
801068a5:	89 e5                	mov    %esp,%ebp
801068a7:	83 ec 08             	sub    $0x8,%esp
801068aa:	8b 45 08             	mov    0x8(%ebp),%eax
801068ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801068b0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801068b4:	89 d0                	mov    %edx,%eax
801068b6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068b9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068bd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068c1:	ee                   	out    %al,(%dx)
}
801068c2:	90                   	nop
801068c3:	c9                   	leave  
801068c4:	c3                   	ret    

801068c5 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801068c5:	55                   	push   %ebp
801068c6:	89 e5                	mov    %esp,%ebp
801068c8:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801068cb:	6a 00                	push   $0x0
801068cd:	68 fa 03 00 00       	push   $0x3fa
801068d2:	e8 cd ff ff ff       	call   801068a4 <outb>
801068d7:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801068da:	68 80 00 00 00       	push   $0x80
801068df:	68 fb 03 00 00       	push   $0x3fb
801068e4:	e8 bb ff ff ff       	call   801068a4 <outb>
801068e9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801068ec:	6a 0c                	push   $0xc
801068ee:	68 f8 03 00 00       	push   $0x3f8
801068f3:	e8 ac ff ff ff       	call   801068a4 <outb>
801068f8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801068fb:	6a 00                	push   $0x0
801068fd:	68 f9 03 00 00       	push   $0x3f9
80106902:	e8 9d ff ff ff       	call   801068a4 <outb>
80106907:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010690a:	6a 03                	push   $0x3
8010690c:	68 fb 03 00 00       	push   $0x3fb
80106911:	e8 8e ff ff ff       	call   801068a4 <outb>
80106916:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106919:	6a 00                	push   $0x0
8010691b:	68 fc 03 00 00       	push   $0x3fc
80106920:	e8 7f ff ff ff       	call   801068a4 <outb>
80106925:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106928:	6a 01                	push   $0x1
8010692a:	68 f9 03 00 00       	push   $0x3f9
8010692f:	e8 70 ff ff ff       	call   801068a4 <outb>
80106934:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106937:	68 fd 03 00 00       	push   $0x3fd
8010693c:	e8 46 ff ff ff       	call   80106887 <inb>
80106941:	83 c4 04             	add    $0x4,%esp
80106944:	3c ff                	cmp    $0xff,%al
80106946:	74 61                	je     801069a9 <uartinit+0xe4>
    return;
  uart = 1;
80106948:	c7 05 b8 76 19 80 01 	movl   $0x1,0x801976b8
8010694f:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106952:	68 fa 03 00 00       	push   $0x3fa
80106957:	e8 2b ff ff ff       	call   80106887 <inb>
8010695c:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010695f:	68 f8 03 00 00       	push   $0x3f8
80106964:	e8 1e ff ff ff       	call   80106887 <inb>
80106969:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010696c:	83 ec 08             	sub    $0x8,%esp
8010696f:	6a 00                	push   $0x0
80106971:	6a 04                	push   $0x4
80106973:	e8 b6 bc ff ff       	call   8010262e <ioapicenable>
80106978:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010697b:	c7 45 f4 40 ac 10 80 	movl   $0x8010ac40,-0xc(%ebp)
80106982:	eb 19                	jmp    8010699d <uartinit+0xd8>
    uartputc(*p);
80106984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106987:	0f b6 00             	movzbl (%eax),%eax
8010698a:	0f be c0             	movsbl %al,%eax
8010698d:	83 ec 0c             	sub    $0xc,%esp
80106990:	50                   	push   %eax
80106991:	e8 16 00 00 00       	call   801069ac <uartputc>
80106996:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106999:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010699d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a0:	0f b6 00             	movzbl (%eax),%eax
801069a3:	84 c0                	test   %al,%al
801069a5:	75 dd                	jne    80106984 <uartinit+0xbf>
801069a7:	eb 01                	jmp    801069aa <uartinit+0xe5>
    return;
801069a9:	90                   	nop
}
801069aa:	c9                   	leave  
801069ab:	c3                   	ret    

801069ac <uartputc>:

void
uartputc(int c)
{
801069ac:	55                   	push   %ebp
801069ad:	89 e5                	mov    %esp,%ebp
801069af:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801069b2:	a1 b8 76 19 80       	mov    0x801976b8,%eax
801069b7:	85 c0                	test   %eax,%eax
801069b9:	74 53                	je     80106a0e <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801069c2:	eb 11                	jmp    801069d5 <uartputc+0x29>
    microdelay(10);
801069c4:	83 ec 0c             	sub    $0xc,%esp
801069c7:	6a 0a                	push   $0xa
801069c9:	e8 69 c1 ff ff       	call   80102b37 <microdelay>
801069ce:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069d5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801069d9:	7f 1a                	jg     801069f5 <uartputc+0x49>
801069db:	83 ec 0c             	sub    $0xc,%esp
801069de:	68 fd 03 00 00       	push   $0x3fd
801069e3:	e8 9f fe ff ff       	call   80106887 <inb>
801069e8:	83 c4 10             	add    $0x10,%esp
801069eb:	0f b6 c0             	movzbl %al,%eax
801069ee:	83 e0 20             	and    $0x20,%eax
801069f1:	85 c0                	test   %eax,%eax
801069f3:	74 cf                	je     801069c4 <uartputc+0x18>
  outb(COM1+0, c);
801069f5:	8b 45 08             	mov    0x8(%ebp),%eax
801069f8:	0f b6 c0             	movzbl %al,%eax
801069fb:	83 ec 08             	sub    $0x8,%esp
801069fe:	50                   	push   %eax
801069ff:	68 f8 03 00 00       	push   $0x3f8
80106a04:	e8 9b fe ff ff       	call   801068a4 <outb>
80106a09:	83 c4 10             	add    $0x10,%esp
80106a0c:	eb 01                	jmp    80106a0f <uartputc+0x63>
    return;
80106a0e:	90                   	nop
}
80106a0f:	c9                   	leave  
80106a10:	c3                   	ret    

80106a11 <uartgetc>:

static int
uartgetc(void)
{
80106a11:	55                   	push   %ebp
80106a12:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106a14:	a1 b8 76 19 80       	mov    0x801976b8,%eax
80106a19:	85 c0                	test   %eax,%eax
80106a1b:	75 07                	jne    80106a24 <uartgetc+0x13>
    return -1;
80106a1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a22:	eb 2e                	jmp    80106a52 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106a24:	68 fd 03 00 00       	push   $0x3fd
80106a29:	e8 59 fe ff ff       	call   80106887 <inb>
80106a2e:	83 c4 04             	add    $0x4,%esp
80106a31:	0f b6 c0             	movzbl %al,%eax
80106a34:	83 e0 01             	and    $0x1,%eax
80106a37:	85 c0                	test   %eax,%eax
80106a39:	75 07                	jne    80106a42 <uartgetc+0x31>
    return -1;
80106a3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a40:	eb 10                	jmp    80106a52 <uartgetc+0x41>
  return inb(COM1+0);
80106a42:	68 f8 03 00 00       	push   $0x3f8
80106a47:	e8 3b fe ff ff       	call   80106887 <inb>
80106a4c:	83 c4 04             	add    $0x4,%esp
80106a4f:	0f b6 c0             	movzbl %al,%eax
}
80106a52:	c9                   	leave  
80106a53:	c3                   	ret    

80106a54 <uartintr>:

void
uartintr(void)
{
80106a54:	55                   	push   %ebp
80106a55:	89 e5                	mov    %esp,%ebp
80106a57:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106a5a:	83 ec 0c             	sub    $0xc,%esp
80106a5d:	68 11 6a 10 80       	push   $0x80106a11
80106a62:	e8 6f 9d ff ff       	call   801007d6 <consoleintr>
80106a67:	83 c4 10             	add    $0x10,%esp
}
80106a6a:	90                   	nop
80106a6b:	c9                   	leave  
80106a6c:	c3                   	ret    

80106a6d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106a6d:	6a 00                	push   $0x0
  pushl $0
80106a6f:	6a 00                	push   $0x0
  jmp alltraps
80106a71:	e9 fa f7 ff ff       	jmp    80106270 <alltraps>

80106a76 <vector1>:
.globl vector1
vector1:
  pushl $0
80106a76:	6a 00                	push   $0x0
  pushl $1
80106a78:	6a 01                	push   $0x1
  jmp alltraps
80106a7a:	e9 f1 f7 ff ff       	jmp    80106270 <alltraps>

80106a7f <vector2>:
.globl vector2
vector2:
  pushl $0
80106a7f:	6a 00                	push   $0x0
  pushl $2
80106a81:	6a 02                	push   $0x2
  jmp alltraps
80106a83:	e9 e8 f7 ff ff       	jmp    80106270 <alltraps>

80106a88 <vector3>:
.globl vector3
vector3:
  pushl $0
80106a88:	6a 00                	push   $0x0
  pushl $3
80106a8a:	6a 03                	push   $0x3
  jmp alltraps
80106a8c:	e9 df f7 ff ff       	jmp    80106270 <alltraps>

80106a91 <vector4>:
.globl vector4
vector4:
  pushl $0
80106a91:	6a 00                	push   $0x0
  pushl $4
80106a93:	6a 04                	push   $0x4
  jmp alltraps
80106a95:	e9 d6 f7 ff ff       	jmp    80106270 <alltraps>

80106a9a <vector5>:
.globl vector5
vector5:
  pushl $0
80106a9a:	6a 00                	push   $0x0
  pushl $5
80106a9c:	6a 05                	push   $0x5
  jmp alltraps
80106a9e:	e9 cd f7 ff ff       	jmp    80106270 <alltraps>

80106aa3 <vector6>:
.globl vector6
vector6:
  pushl $0
80106aa3:	6a 00                	push   $0x0
  pushl $6
80106aa5:	6a 06                	push   $0x6
  jmp alltraps
80106aa7:	e9 c4 f7 ff ff       	jmp    80106270 <alltraps>

80106aac <vector7>:
.globl vector7
vector7:
  pushl $0
80106aac:	6a 00                	push   $0x0
  pushl $7
80106aae:	6a 07                	push   $0x7
  jmp alltraps
80106ab0:	e9 bb f7 ff ff       	jmp    80106270 <alltraps>

80106ab5 <vector8>:
.globl vector8
vector8:
  pushl $8
80106ab5:	6a 08                	push   $0x8
  jmp alltraps
80106ab7:	e9 b4 f7 ff ff       	jmp    80106270 <alltraps>

80106abc <vector9>:
.globl vector9
vector9:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $9
80106abe:	6a 09                	push   $0x9
  jmp alltraps
80106ac0:	e9 ab f7 ff ff       	jmp    80106270 <alltraps>

80106ac5 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ac5:	6a 0a                	push   $0xa
  jmp alltraps
80106ac7:	e9 a4 f7 ff ff       	jmp    80106270 <alltraps>

80106acc <vector11>:
.globl vector11
vector11:
  pushl $11
80106acc:	6a 0b                	push   $0xb
  jmp alltraps
80106ace:	e9 9d f7 ff ff       	jmp    80106270 <alltraps>

80106ad3 <vector12>:
.globl vector12
vector12:
  pushl $12
80106ad3:	6a 0c                	push   $0xc
  jmp alltraps
80106ad5:	e9 96 f7 ff ff       	jmp    80106270 <alltraps>

80106ada <vector13>:
.globl vector13
vector13:
  pushl $13
80106ada:	6a 0d                	push   $0xd
  jmp alltraps
80106adc:	e9 8f f7 ff ff       	jmp    80106270 <alltraps>

80106ae1 <vector14>:
.globl vector14
vector14:
  pushl $14
80106ae1:	6a 0e                	push   $0xe
  jmp alltraps
80106ae3:	e9 88 f7 ff ff       	jmp    80106270 <alltraps>

80106ae8 <vector15>:
.globl vector15
vector15:
  pushl $0
80106ae8:	6a 00                	push   $0x0
  pushl $15
80106aea:	6a 0f                	push   $0xf
  jmp alltraps
80106aec:	e9 7f f7 ff ff       	jmp    80106270 <alltraps>

80106af1 <vector16>:
.globl vector16
vector16:
  pushl $0
80106af1:	6a 00                	push   $0x0
  pushl $16
80106af3:	6a 10                	push   $0x10
  jmp alltraps
80106af5:	e9 76 f7 ff ff       	jmp    80106270 <alltraps>

80106afa <vector17>:
.globl vector17
vector17:
  pushl $17
80106afa:	6a 11                	push   $0x11
  jmp alltraps
80106afc:	e9 6f f7 ff ff       	jmp    80106270 <alltraps>

80106b01 <vector18>:
.globl vector18
vector18:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $18
80106b03:	6a 12                	push   $0x12
  jmp alltraps
80106b05:	e9 66 f7 ff ff       	jmp    80106270 <alltraps>

80106b0a <vector19>:
.globl vector19
vector19:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $19
80106b0c:	6a 13                	push   $0x13
  jmp alltraps
80106b0e:	e9 5d f7 ff ff       	jmp    80106270 <alltraps>

80106b13 <vector20>:
.globl vector20
vector20:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $20
80106b15:	6a 14                	push   $0x14
  jmp alltraps
80106b17:	e9 54 f7 ff ff       	jmp    80106270 <alltraps>

80106b1c <vector21>:
.globl vector21
vector21:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $21
80106b1e:	6a 15                	push   $0x15
  jmp alltraps
80106b20:	e9 4b f7 ff ff       	jmp    80106270 <alltraps>

80106b25 <vector22>:
.globl vector22
vector22:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $22
80106b27:	6a 16                	push   $0x16
  jmp alltraps
80106b29:	e9 42 f7 ff ff       	jmp    80106270 <alltraps>

80106b2e <vector23>:
.globl vector23
vector23:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $23
80106b30:	6a 17                	push   $0x17
  jmp alltraps
80106b32:	e9 39 f7 ff ff       	jmp    80106270 <alltraps>

80106b37 <vector24>:
.globl vector24
vector24:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $24
80106b39:	6a 18                	push   $0x18
  jmp alltraps
80106b3b:	e9 30 f7 ff ff       	jmp    80106270 <alltraps>

80106b40 <vector25>:
.globl vector25
vector25:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $25
80106b42:	6a 19                	push   $0x19
  jmp alltraps
80106b44:	e9 27 f7 ff ff       	jmp    80106270 <alltraps>

80106b49 <vector26>:
.globl vector26
vector26:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $26
80106b4b:	6a 1a                	push   $0x1a
  jmp alltraps
80106b4d:	e9 1e f7 ff ff       	jmp    80106270 <alltraps>

80106b52 <vector27>:
.globl vector27
vector27:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $27
80106b54:	6a 1b                	push   $0x1b
  jmp alltraps
80106b56:	e9 15 f7 ff ff       	jmp    80106270 <alltraps>

80106b5b <vector28>:
.globl vector28
vector28:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $28
80106b5d:	6a 1c                	push   $0x1c
  jmp alltraps
80106b5f:	e9 0c f7 ff ff       	jmp    80106270 <alltraps>

80106b64 <vector29>:
.globl vector29
vector29:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $29
80106b66:	6a 1d                	push   $0x1d
  jmp alltraps
80106b68:	e9 03 f7 ff ff       	jmp    80106270 <alltraps>

80106b6d <vector30>:
.globl vector30
vector30:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $30
80106b6f:	6a 1e                	push   $0x1e
  jmp alltraps
80106b71:	e9 fa f6 ff ff       	jmp    80106270 <alltraps>

80106b76 <vector31>:
.globl vector31
vector31:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $31
80106b78:	6a 1f                	push   $0x1f
  jmp alltraps
80106b7a:	e9 f1 f6 ff ff       	jmp    80106270 <alltraps>

80106b7f <vector32>:
.globl vector32
vector32:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $32
80106b81:	6a 20                	push   $0x20
  jmp alltraps
80106b83:	e9 e8 f6 ff ff       	jmp    80106270 <alltraps>

80106b88 <vector33>:
.globl vector33
vector33:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $33
80106b8a:	6a 21                	push   $0x21
  jmp alltraps
80106b8c:	e9 df f6 ff ff       	jmp    80106270 <alltraps>

80106b91 <vector34>:
.globl vector34
vector34:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $34
80106b93:	6a 22                	push   $0x22
  jmp alltraps
80106b95:	e9 d6 f6 ff ff       	jmp    80106270 <alltraps>

80106b9a <vector35>:
.globl vector35
vector35:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $35
80106b9c:	6a 23                	push   $0x23
  jmp alltraps
80106b9e:	e9 cd f6 ff ff       	jmp    80106270 <alltraps>

80106ba3 <vector36>:
.globl vector36
vector36:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $36
80106ba5:	6a 24                	push   $0x24
  jmp alltraps
80106ba7:	e9 c4 f6 ff ff       	jmp    80106270 <alltraps>

80106bac <vector37>:
.globl vector37
vector37:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $37
80106bae:	6a 25                	push   $0x25
  jmp alltraps
80106bb0:	e9 bb f6 ff ff       	jmp    80106270 <alltraps>

80106bb5 <vector38>:
.globl vector38
vector38:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $38
80106bb7:	6a 26                	push   $0x26
  jmp alltraps
80106bb9:	e9 b2 f6 ff ff       	jmp    80106270 <alltraps>

80106bbe <vector39>:
.globl vector39
vector39:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $39
80106bc0:	6a 27                	push   $0x27
  jmp alltraps
80106bc2:	e9 a9 f6 ff ff       	jmp    80106270 <alltraps>

80106bc7 <vector40>:
.globl vector40
vector40:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $40
80106bc9:	6a 28                	push   $0x28
  jmp alltraps
80106bcb:	e9 a0 f6 ff ff       	jmp    80106270 <alltraps>

80106bd0 <vector41>:
.globl vector41
vector41:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $41
80106bd2:	6a 29                	push   $0x29
  jmp alltraps
80106bd4:	e9 97 f6 ff ff       	jmp    80106270 <alltraps>

80106bd9 <vector42>:
.globl vector42
vector42:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $42
80106bdb:	6a 2a                	push   $0x2a
  jmp alltraps
80106bdd:	e9 8e f6 ff ff       	jmp    80106270 <alltraps>

80106be2 <vector43>:
.globl vector43
vector43:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $43
80106be4:	6a 2b                	push   $0x2b
  jmp alltraps
80106be6:	e9 85 f6 ff ff       	jmp    80106270 <alltraps>

80106beb <vector44>:
.globl vector44
vector44:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $44
80106bed:	6a 2c                	push   $0x2c
  jmp alltraps
80106bef:	e9 7c f6 ff ff       	jmp    80106270 <alltraps>

80106bf4 <vector45>:
.globl vector45
vector45:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $45
80106bf6:	6a 2d                	push   $0x2d
  jmp alltraps
80106bf8:	e9 73 f6 ff ff       	jmp    80106270 <alltraps>

80106bfd <vector46>:
.globl vector46
vector46:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $46
80106bff:	6a 2e                	push   $0x2e
  jmp alltraps
80106c01:	e9 6a f6 ff ff       	jmp    80106270 <alltraps>

80106c06 <vector47>:
.globl vector47
vector47:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $47
80106c08:	6a 2f                	push   $0x2f
  jmp alltraps
80106c0a:	e9 61 f6 ff ff       	jmp    80106270 <alltraps>

80106c0f <vector48>:
.globl vector48
vector48:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $48
80106c11:	6a 30                	push   $0x30
  jmp alltraps
80106c13:	e9 58 f6 ff ff       	jmp    80106270 <alltraps>

80106c18 <vector49>:
.globl vector49
vector49:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $49
80106c1a:	6a 31                	push   $0x31
  jmp alltraps
80106c1c:	e9 4f f6 ff ff       	jmp    80106270 <alltraps>

80106c21 <vector50>:
.globl vector50
vector50:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $50
80106c23:	6a 32                	push   $0x32
  jmp alltraps
80106c25:	e9 46 f6 ff ff       	jmp    80106270 <alltraps>

80106c2a <vector51>:
.globl vector51
vector51:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $51
80106c2c:	6a 33                	push   $0x33
  jmp alltraps
80106c2e:	e9 3d f6 ff ff       	jmp    80106270 <alltraps>

80106c33 <vector52>:
.globl vector52
vector52:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $52
80106c35:	6a 34                	push   $0x34
  jmp alltraps
80106c37:	e9 34 f6 ff ff       	jmp    80106270 <alltraps>

80106c3c <vector53>:
.globl vector53
vector53:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $53
80106c3e:	6a 35                	push   $0x35
  jmp alltraps
80106c40:	e9 2b f6 ff ff       	jmp    80106270 <alltraps>

80106c45 <vector54>:
.globl vector54
vector54:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $54
80106c47:	6a 36                	push   $0x36
  jmp alltraps
80106c49:	e9 22 f6 ff ff       	jmp    80106270 <alltraps>

80106c4e <vector55>:
.globl vector55
vector55:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $55
80106c50:	6a 37                	push   $0x37
  jmp alltraps
80106c52:	e9 19 f6 ff ff       	jmp    80106270 <alltraps>

80106c57 <vector56>:
.globl vector56
vector56:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $56
80106c59:	6a 38                	push   $0x38
  jmp alltraps
80106c5b:	e9 10 f6 ff ff       	jmp    80106270 <alltraps>

80106c60 <vector57>:
.globl vector57
vector57:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $57
80106c62:	6a 39                	push   $0x39
  jmp alltraps
80106c64:	e9 07 f6 ff ff       	jmp    80106270 <alltraps>

80106c69 <vector58>:
.globl vector58
vector58:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $58
80106c6b:	6a 3a                	push   $0x3a
  jmp alltraps
80106c6d:	e9 fe f5 ff ff       	jmp    80106270 <alltraps>

80106c72 <vector59>:
.globl vector59
vector59:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $59
80106c74:	6a 3b                	push   $0x3b
  jmp alltraps
80106c76:	e9 f5 f5 ff ff       	jmp    80106270 <alltraps>

80106c7b <vector60>:
.globl vector60
vector60:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $60
80106c7d:	6a 3c                	push   $0x3c
  jmp alltraps
80106c7f:	e9 ec f5 ff ff       	jmp    80106270 <alltraps>

80106c84 <vector61>:
.globl vector61
vector61:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $61
80106c86:	6a 3d                	push   $0x3d
  jmp alltraps
80106c88:	e9 e3 f5 ff ff       	jmp    80106270 <alltraps>

80106c8d <vector62>:
.globl vector62
vector62:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $62
80106c8f:	6a 3e                	push   $0x3e
  jmp alltraps
80106c91:	e9 da f5 ff ff       	jmp    80106270 <alltraps>

80106c96 <vector63>:
.globl vector63
vector63:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $63
80106c98:	6a 3f                	push   $0x3f
  jmp alltraps
80106c9a:	e9 d1 f5 ff ff       	jmp    80106270 <alltraps>

80106c9f <vector64>:
.globl vector64
vector64:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $64
80106ca1:	6a 40                	push   $0x40
  jmp alltraps
80106ca3:	e9 c8 f5 ff ff       	jmp    80106270 <alltraps>

80106ca8 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $65
80106caa:	6a 41                	push   $0x41
  jmp alltraps
80106cac:	e9 bf f5 ff ff       	jmp    80106270 <alltraps>

80106cb1 <vector66>:
.globl vector66
vector66:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $66
80106cb3:	6a 42                	push   $0x42
  jmp alltraps
80106cb5:	e9 b6 f5 ff ff       	jmp    80106270 <alltraps>

80106cba <vector67>:
.globl vector67
vector67:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $67
80106cbc:	6a 43                	push   $0x43
  jmp alltraps
80106cbe:	e9 ad f5 ff ff       	jmp    80106270 <alltraps>

80106cc3 <vector68>:
.globl vector68
vector68:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $68
80106cc5:	6a 44                	push   $0x44
  jmp alltraps
80106cc7:	e9 a4 f5 ff ff       	jmp    80106270 <alltraps>

80106ccc <vector69>:
.globl vector69
vector69:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $69
80106cce:	6a 45                	push   $0x45
  jmp alltraps
80106cd0:	e9 9b f5 ff ff       	jmp    80106270 <alltraps>

80106cd5 <vector70>:
.globl vector70
vector70:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $70
80106cd7:	6a 46                	push   $0x46
  jmp alltraps
80106cd9:	e9 92 f5 ff ff       	jmp    80106270 <alltraps>

80106cde <vector71>:
.globl vector71
vector71:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $71
80106ce0:	6a 47                	push   $0x47
  jmp alltraps
80106ce2:	e9 89 f5 ff ff       	jmp    80106270 <alltraps>

80106ce7 <vector72>:
.globl vector72
vector72:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $72
80106ce9:	6a 48                	push   $0x48
  jmp alltraps
80106ceb:	e9 80 f5 ff ff       	jmp    80106270 <alltraps>

80106cf0 <vector73>:
.globl vector73
vector73:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $73
80106cf2:	6a 49                	push   $0x49
  jmp alltraps
80106cf4:	e9 77 f5 ff ff       	jmp    80106270 <alltraps>

80106cf9 <vector74>:
.globl vector74
vector74:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $74
80106cfb:	6a 4a                	push   $0x4a
  jmp alltraps
80106cfd:	e9 6e f5 ff ff       	jmp    80106270 <alltraps>

80106d02 <vector75>:
.globl vector75
vector75:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $75
80106d04:	6a 4b                	push   $0x4b
  jmp alltraps
80106d06:	e9 65 f5 ff ff       	jmp    80106270 <alltraps>

80106d0b <vector76>:
.globl vector76
vector76:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $76
80106d0d:	6a 4c                	push   $0x4c
  jmp alltraps
80106d0f:	e9 5c f5 ff ff       	jmp    80106270 <alltraps>

80106d14 <vector77>:
.globl vector77
vector77:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $77
80106d16:	6a 4d                	push   $0x4d
  jmp alltraps
80106d18:	e9 53 f5 ff ff       	jmp    80106270 <alltraps>

80106d1d <vector78>:
.globl vector78
vector78:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $78
80106d1f:	6a 4e                	push   $0x4e
  jmp alltraps
80106d21:	e9 4a f5 ff ff       	jmp    80106270 <alltraps>

80106d26 <vector79>:
.globl vector79
vector79:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $79
80106d28:	6a 4f                	push   $0x4f
  jmp alltraps
80106d2a:	e9 41 f5 ff ff       	jmp    80106270 <alltraps>

80106d2f <vector80>:
.globl vector80
vector80:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $80
80106d31:	6a 50                	push   $0x50
  jmp alltraps
80106d33:	e9 38 f5 ff ff       	jmp    80106270 <alltraps>

80106d38 <vector81>:
.globl vector81
vector81:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $81
80106d3a:	6a 51                	push   $0x51
  jmp alltraps
80106d3c:	e9 2f f5 ff ff       	jmp    80106270 <alltraps>

80106d41 <vector82>:
.globl vector82
vector82:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $82
80106d43:	6a 52                	push   $0x52
  jmp alltraps
80106d45:	e9 26 f5 ff ff       	jmp    80106270 <alltraps>

80106d4a <vector83>:
.globl vector83
vector83:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $83
80106d4c:	6a 53                	push   $0x53
  jmp alltraps
80106d4e:	e9 1d f5 ff ff       	jmp    80106270 <alltraps>

80106d53 <vector84>:
.globl vector84
vector84:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $84
80106d55:	6a 54                	push   $0x54
  jmp alltraps
80106d57:	e9 14 f5 ff ff       	jmp    80106270 <alltraps>

80106d5c <vector85>:
.globl vector85
vector85:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $85
80106d5e:	6a 55                	push   $0x55
  jmp alltraps
80106d60:	e9 0b f5 ff ff       	jmp    80106270 <alltraps>

80106d65 <vector86>:
.globl vector86
vector86:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $86
80106d67:	6a 56                	push   $0x56
  jmp alltraps
80106d69:	e9 02 f5 ff ff       	jmp    80106270 <alltraps>

80106d6e <vector87>:
.globl vector87
vector87:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $87
80106d70:	6a 57                	push   $0x57
  jmp alltraps
80106d72:	e9 f9 f4 ff ff       	jmp    80106270 <alltraps>

80106d77 <vector88>:
.globl vector88
vector88:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $88
80106d79:	6a 58                	push   $0x58
  jmp alltraps
80106d7b:	e9 f0 f4 ff ff       	jmp    80106270 <alltraps>

80106d80 <vector89>:
.globl vector89
vector89:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $89
80106d82:	6a 59                	push   $0x59
  jmp alltraps
80106d84:	e9 e7 f4 ff ff       	jmp    80106270 <alltraps>

80106d89 <vector90>:
.globl vector90
vector90:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $90
80106d8b:	6a 5a                	push   $0x5a
  jmp alltraps
80106d8d:	e9 de f4 ff ff       	jmp    80106270 <alltraps>

80106d92 <vector91>:
.globl vector91
vector91:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $91
80106d94:	6a 5b                	push   $0x5b
  jmp alltraps
80106d96:	e9 d5 f4 ff ff       	jmp    80106270 <alltraps>

80106d9b <vector92>:
.globl vector92
vector92:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $92
80106d9d:	6a 5c                	push   $0x5c
  jmp alltraps
80106d9f:	e9 cc f4 ff ff       	jmp    80106270 <alltraps>

80106da4 <vector93>:
.globl vector93
vector93:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $93
80106da6:	6a 5d                	push   $0x5d
  jmp alltraps
80106da8:	e9 c3 f4 ff ff       	jmp    80106270 <alltraps>

80106dad <vector94>:
.globl vector94
vector94:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $94
80106daf:	6a 5e                	push   $0x5e
  jmp alltraps
80106db1:	e9 ba f4 ff ff       	jmp    80106270 <alltraps>

80106db6 <vector95>:
.globl vector95
vector95:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $95
80106db8:	6a 5f                	push   $0x5f
  jmp alltraps
80106dba:	e9 b1 f4 ff ff       	jmp    80106270 <alltraps>

80106dbf <vector96>:
.globl vector96
vector96:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $96
80106dc1:	6a 60                	push   $0x60
  jmp alltraps
80106dc3:	e9 a8 f4 ff ff       	jmp    80106270 <alltraps>

80106dc8 <vector97>:
.globl vector97
vector97:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $97
80106dca:	6a 61                	push   $0x61
  jmp alltraps
80106dcc:	e9 9f f4 ff ff       	jmp    80106270 <alltraps>

80106dd1 <vector98>:
.globl vector98
vector98:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $98
80106dd3:	6a 62                	push   $0x62
  jmp alltraps
80106dd5:	e9 96 f4 ff ff       	jmp    80106270 <alltraps>

80106dda <vector99>:
.globl vector99
vector99:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $99
80106ddc:	6a 63                	push   $0x63
  jmp alltraps
80106dde:	e9 8d f4 ff ff       	jmp    80106270 <alltraps>

80106de3 <vector100>:
.globl vector100
vector100:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $100
80106de5:	6a 64                	push   $0x64
  jmp alltraps
80106de7:	e9 84 f4 ff ff       	jmp    80106270 <alltraps>

80106dec <vector101>:
.globl vector101
vector101:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $101
80106dee:	6a 65                	push   $0x65
  jmp alltraps
80106df0:	e9 7b f4 ff ff       	jmp    80106270 <alltraps>

80106df5 <vector102>:
.globl vector102
vector102:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $102
80106df7:	6a 66                	push   $0x66
  jmp alltraps
80106df9:	e9 72 f4 ff ff       	jmp    80106270 <alltraps>

80106dfe <vector103>:
.globl vector103
vector103:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $103
80106e00:	6a 67                	push   $0x67
  jmp alltraps
80106e02:	e9 69 f4 ff ff       	jmp    80106270 <alltraps>

80106e07 <vector104>:
.globl vector104
vector104:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $104
80106e09:	6a 68                	push   $0x68
  jmp alltraps
80106e0b:	e9 60 f4 ff ff       	jmp    80106270 <alltraps>

80106e10 <vector105>:
.globl vector105
vector105:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $105
80106e12:	6a 69                	push   $0x69
  jmp alltraps
80106e14:	e9 57 f4 ff ff       	jmp    80106270 <alltraps>

80106e19 <vector106>:
.globl vector106
vector106:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $106
80106e1b:	6a 6a                	push   $0x6a
  jmp alltraps
80106e1d:	e9 4e f4 ff ff       	jmp    80106270 <alltraps>

80106e22 <vector107>:
.globl vector107
vector107:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $107
80106e24:	6a 6b                	push   $0x6b
  jmp alltraps
80106e26:	e9 45 f4 ff ff       	jmp    80106270 <alltraps>

80106e2b <vector108>:
.globl vector108
vector108:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $108
80106e2d:	6a 6c                	push   $0x6c
  jmp alltraps
80106e2f:	e9 3c f4 ff ff       	jmp    80106270 <alltraps>

80106e34 <vector109>:
.globl vector109
vector109:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $109
80106e36:	6a 6d                	push   $0x6d
  jmp alltraps
80106e38:	e9 33 f4 ff ff       	jmp    80106270 <alltraps>

80106e3d <vector110>:
.globl vector110
vector110:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $110
80106e3f:	6a 6e                	push   $0x6e
  jmp alltraps
80106e41:	e9 2a f4 ff ff       	jmp    80106270 <alltraps>

80106e46 <vector111>:
.globl vector111
vector111:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $111
80106e48:	6a 6f                	push   $0x6f
  jmp alltraps
80106e4a:	e9 21 f4 ff ff       	jmp    80106270 <alltraps>

80106e4f <vector112>:
.globl vector112
vector112:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $112
80106e51:	6a 70                	push   $0x70
  jmp alltraps
80106e53:	e9 18 f4 ff ff       	jmp    80106270 <alltraps>

80106e58 <vector113>:
.globl vector113
vector113:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $113
80106e5a:	6a 71                	push   $0x71
  jmp alltraps
80106e5c:	e9 0f f4 ff ff       	jmp    80106270 <alltraps>

80106e61 <vector114>:
.globl vector114
vector114:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $114
80106e63:	6a 72                	push   $0x72
  jmp alltraps
80106e65:	e9 06 f4 ff ff       	jmp    80106270 <alltraps>

80106e6a <vector115>:
.globl vector115
vector115:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $115
80106e6c:	6a 73                	push   $0x73
  jmp alltraps
80106e6e:	e9 fd f3 ff ff       	jmp    80106270 <alltraps>

80106e73 <vector116>:
.globl vector116
vector116:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $116
80106e75:	6a 74                	push   $0x74
  jmp alltraps
80106e77:	e9 f4 f3 ff ff       	jmp    80106270 <alltraps>

80106e7c <vector117>:
.globl vector117
vector117:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $117
80106e7e:	6a 75                	push   $0x75
  jmp alltraps
80106e80:	e9 eb f3 ff ff       	jmp    80106270 <alltraps>

80106e85 <vector118>:
.globl vector118
vector118:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $118
80106e87:	6a 76                	push   $0x76
  jmp alltraps
80106e89:	e9 e2 f3 ff ff       	jmp    80106270 <alltraps>

80106e8e <vector119>:
.globl vector119
vector119:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $119
80106e90:	6a 77                	push   $0x77
  jmp alltraps
80106e92:	e9 d9 f3 ff ff       	jmp    80106270 <alltraps>

80106e97 <vector120>:
.globl vector120
vector120:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $120
80106e99:	6a 78                	push   $0x78
  jmp alltraps
80106e9b:	e9 d0 f3 ff ff       	jmp    80106270 <alltraps>

80106ea0 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $121
80106ea2:	6a 79                	push   $0x79
  jmp alltraps
80106ea4:	e9 c7 f3 ff ff       	jmp    80106270 <alltraps>

80106ea9 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $122
80106eab:	6a 7a                	push   $0x7a
  jmp alltraps
80106ead:	e9 be f3 ff ff       	jmp    80106270 <alltraps>

80106eb2 <vector123>:
.globl vector123
vector123:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $123
80106eb4:	6a 7b                	push   $0x7b
  jmp alltraps
80106eb6:	e9 b5 f3 ff ff       	jmp    80106270 <alltraps>

80106ebb <vector124>:
.globl vector124
vector124:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $124
80106ebd:	6a 7c                	push   $0x7c
  jmp alltraps
80106ebf:	e9 ac f3 ff ff       	jmp    80106270 <alltraps>

80106ec4 <vector125>:
.globl vector125
vector125:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $125
80106ec6:	6a 7d                	push   $0x7d
  jmp alltraps
80106ec8:	e9 a3 f3 ff ff       	jmp    80106270 <alltraps>

80106ecd <vector126>:
.globl vector126
vector126:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $126
80106ecf:	6a 7e                	push   $0x7e
  jmp alltraps
80106ed1:	e9 9a f3 ff ff       	jmp    80106270 <alltraps>

80106ed6 <vector127>:
.globl vector127
vector127:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $127
80106ed8:	6a 7f                	push   $0x7f
  jmp alltraps
80106eda:	e9 91 f3 ff ff       	jmp    80106270 <alltraps>

80106edf <vector128>:
.globl vector128
vector128:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $128
80106ee1:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106ee6:	e9 85 f3 ff ff       	jmp    80106270 <alltraps>

80106eeb <vector129>:
.globl vector129
vector129:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $129
80106eed:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106ef2:	e9 79 f3 ff ff       	jmp    80106270 <alltraps>

80106ef7 <vector130>:
.globl vector130
vector130:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $130
80106ef9:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106efe:	e9 6d f3 ff ff       	jmp    80106270 <alltraps>

80106f03 <vector131>:
.globl vector131
vector131:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $131
80106f05:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f0a:	e9 61 f3 ff ff       	jmp    80106270 <alltraps>

80106f0f <vector132>:
.globl vector132
vector132:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $132
80106f11:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106f16:	e9 55 f3 ff ff       	jmp    80106270 <alltraps>

80106f1b <vector133>:
.globl vector133
vector133:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $133
80106f1d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106f22:	e9 49 f3 ff ff       	jmp    80106270 <alltraps>

80106f27 <vector134>:
.globl vector134
vector134:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $134
80106f29:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f2e:	e9 3d f3 ff ff       	jmp    80106270 <alltraps>

80106f33 <vector135>:
.globl vector135
vector135:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $135
80106f35:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106f3a:	e9 31 f3 ff ff       	jmp    80106270 <alltraps>

80106f3f <vector136>:
.globl vector136
vector136:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $136
80106f41:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106f46:	e9 25 f3 ff ff       	jmp    80106270 <alltraps>

80106f4b <vector137>:
.globl vector137
vector137:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $137
80106f4d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106f52:	e9 19 f3 ff ff       	jmp    80106270 <alltraps>

80106f57 <vector138>:
.globl vector138
vector138:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $138
80106f59:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106f5e:	e9 0d f3 ff ff       	jmp    80106270 <alltraps>

80106f63 <vector139>:
.globl vector139
vector139:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $139
80106f65:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106f6a:	e9 01 f3 ff ff       	jmp    80106270 <alltraps>

80106f6f <vector140>:
.globl vector140
vector140:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $140
80106f71:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106f76:	e9 f5 f2 ff ff       	jmp    80106270 <alltraps>

80106f7b <vector141>:
.globl vector141
vector141:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $141
80106f7d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106f82:	e9 e9 f2 ff ff       	jmp    80106270 <alltraps>

80106f87 <vector142>:
.globl vector142
vector142:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $142
80106f89:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106f8e:	e9 dd f2 ff ff       	jmp    80106270 <alltraps>

80106f93 <vector143>:
.globl vector143
vector143:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $143
80106f95:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106f9a:	e9 d1 f2 ff ff       	jmp    80106270 <alltraps>

80106f9f <vector144>:
.globl vector144
vector144:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $144
80106fa1:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106fa6:	e9 c5 f2 ff ff       	jmp    80106270 <alltraps>

80106fab <vector145>:
.globl vector145
vector145:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $145
80106fad:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106fb2:	e9 b9 f2 ff ff       	jmp    80106270 <alltraps>

80106fb7 <vector146>:
.globl vector146
vector146:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $146
80106fb9:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106fbe:	e9 ad f2 ff ff       	jmp    80106270 <alltraps>

80106fc3 <vector147>:
.globl vector147
vector147:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $147
80106fc5:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106fca:	e9 a1 f2 ff ff       	jmp    80106270 <alltraps>

80106fcf <vector148>:
.globl vector148
vector148:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $148
80106fd1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106fd6:	e9 95 f2 ff ff       	jmp    80106270 <alltraps>

80106fdb <vector149>:
.globl vector149
vector149:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $149
80106fdd:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106fe2:	e9 89 f2 ff ff       	jmp    80106270 <alltraps>

80106fe7 <vector150>:
.globl vector150
vector150:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $150
80106fe9:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106fee:	e9 7d f2 ff ff       	jmp    80106270 <alltraps>

80106ff3 <vector151>:
.globl vector151
vector151:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $151
80106ff5:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106ffa:	e9 71 f2 ff ff       	jmp    80106270 <alltraps>

80106fff <vector152>:
.globl vector152
vector152:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $152
80107001:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107006:	e9 65 f2 ff ff       	jmp    80106270 <alltraps>

8010700b <vector153>:
.globl vector153
vector153:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $153
8010700d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107012:	e9 59 f2 ff ff       	jmp    80106270 <alltraps>

80107017 <vector154>:
.globl vector154
vector154:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $154
80107019:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010701e:	e9 4d f2 ff ff       	jmp    80106270 <alltraps>

80107023 <vector155>:
.globl vector155
vector155:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $155
80107025:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010702a:	e9 41 f2 ff ff       	jmp    80106270 <alltraps>

8010702f <vector156>:
.globl vector156
vector156:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $156
80107031:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107036:	e9 35 f2 ff ff       	jmp    80106270 <alltraps>

8010703b <vector157>:
.globl vector157
vector157:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $157
8010703d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107042:	e9 29 f2 ff ff       	jmp    80106270 <alltraps>

80107047 <vector158>:
.globl vector158
vector158:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $158
80107049:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010704e:	e9 1d f2 ff ff       	jmp    80106270 <alltraps>

80107053 <vector159>:
.globl vector159
vector159:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $159
80107055:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010705a:	e9 11 f2 ff ff       	jmp    80106270 <alltraps>

8010705f <vector160>:
.globl vector160
vector160:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $160
80107061:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107066:	e9 05 f2 ff ff       	jmp    80106270 <alltraps>

8010706b <vector161>:
.globl vector161
vector161:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $161
8010706d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107072:	e9 f9 f1 ff ff       	jmp    80106270 <alltraps>

80107077 <vector162>:
.globl vector162
vector162:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $162
80107079:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010707e:	e9 ed f1 ff ff       	jmp    80106270 <alltraps>

80107083 <vector163>:
.globl vector163
vector163:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $163
80107085:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010708a:	e9 e1 f1 ff ff       	jmp    80106270 <alltraps>

8010708f <vector164>:
.globl vector164
vector164:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $164
80107091:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107096:	e9 d5 f1 ff ff       	jmp    80106270 <alltraps>

8010709b <vector165>:
.globl vector165
vector165:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $165
8010709d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801070a2:	e9 c9 f1 ff ff       	jmp    80106270 <alltraps>

801070a7 <vector166>:
.globl vector166
vector166:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $166
801070a9:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801070ae:	e9 bd f1 ff ff       	jmp    80106270 <alltraps>

801070b3 <vector167>:
.globl vector167
vector167:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $167
801070b5:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801070ba:	e9 b1 f1 ff ff       	jmp    80106270 <alltraps>

801070bf <vector168>:
.globl vector168
vector168:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $168
801070c1:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801070c6:	e9 a5 f1 ff ff       	jmp    80106270 <alltraps>

801070cb <vector169>:
.globl vector169
vector169:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $169
801070cd:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801070d2:	e9 99 f1 ff ff       	jmp    80106270 <alltraps>

801070d7 <vector170>:
.globl vector170
vector170:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $170
801070d9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801070de:	e9 8d f1 ff ff       	jmp    80106270 <alltraps>

801070e3 <vector171>:
.globl vector171
vector171:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $171
801070e5:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801070ea:	e9 81 f1 ff ff       	jmp    80106270 <alltraps>

801070ef <vector172>:
.globl vector172
vector172:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $172
801070f1:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801070f6:	e9 75 f1 ff ff       	jmp    80106270 <alltraps>

801070fb <vector173>:
.globl vector173
vector173:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $173
801070fd:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107102:	e9 69 f1 ff ff       	jmp    80106270 <alltraps>

80107107 <vector174>:
.globl vector174
vector174:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $174
80107109:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010710e:	e9 5d f1 ff ff       	jmp    80106270 <alltraps>

80107113 <vector175>:
.globl vector175
vector175:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $175
80107115:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010711a:	e9 51 f1 ff ff       	jmp    80106270 <alltraps>

8010711f <vector176>:
.globl vector176
vector176:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $176
80107121:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107126:	e9 45 f1 ff ff       	jmp    80106270 <alltraps>

8010712b <vector177>:
.globl vector177
vector177:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $177
8010712d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107132:	e9 39 f1 ff ff       	jmp    80106270 <alltraps>

80107137 <vector178>:
.globl vector178
vector178:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $178
80107139:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010713e:	e9 2d f1 ff ff       	jmp    80106270 <alltraps>

80107143 <vector179>:
.globl vector179
vector179:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $179
80107145:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010714a:	e9 21 f1 ff ff       	jmp    80106270 <alltraps>

8010714f <vector180>:
.globl vector180
vector180:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $180
80107151:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107156:	e9 15 f1 ff ff       	jmp    80106270 <alltraps>

8010715b <vector181>:
.globl vector181
vector181:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $181
8010715d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107162:	e9 09 f1 ff ff       	jmp    80106270 <alltraps>

80107167 <vector182>:
.globl vector182
vector182:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $182
80107169:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010716e:	e9 fd f0 ff ff       	jmp    80106270 <alltraps>

80107173 <vector183>:
.globl vector183
vector183:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $183
80107175:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010717a:	e9 f1 f0 ff ff       	jmp    80106270 <alltraps>

8010717f <vector184>:
.globl vector184
vector184:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $184
80107181:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107186:	e9 e5 f0 ff ff       	jmp    80106270 <alltraps>

8010718b <vector185>:
.globl vector185
vector185:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $185
8010718d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107192:	e9 d9 f0 ff ff       	jmp    80106270 <alltraps>

80107197 <vector186>:
.globl vector186
vector186:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $186
80107199:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010719e:	e9 cd f0 ff ff       	jmp    80106270 <alltraps>

801071a3 <vector187>:
.globl vector187
vector187:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $187
801071a5:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801071aa:	e9 c1 f0 ff ff       	jmp    80106270 <alltraps>

801071af <vector188>:
.globl vector188
vector188:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $188
801071b1:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801071b6:	e9 b5 f0 ff ff       	jmp    80106270 <alltraps>

801071bb <vector189>:
.globl vector189
vector189:
  pushl $0
801071bb:	6a 00                	push   $0x0
  pushl $189
801071bd:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801071c2:	e9 a9 f0 ff ff       	jmp    80106270 <alltraps>

801071c7 <vector190>:
.globl vector190
vector190:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $190
801071c9:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801071ce:	e9 9d f0 ff ff       	jmp    80106270 <alltraps>

801071d3 <vector191>:
.globl vector191
vector191:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $191
801071d5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801071da:	e9 91 f0 ff ff       	jmp    80106270 <alltraps>

801071df <vector192>:
.globl vector192
vector192:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $192
801071e1:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801071e6:	e9 85 f0 ff ff       	jmp    80106270 <alltraps>

801071eb <vector193>:
.globl vector193
vector193:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $193
801071ed:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801071f2:	e9 79 f0 ff ff       	jmp    80106270 <alltraps>

801071f7 <vector194>:
.globl vector194
vector194:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $194
801071f9:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801071fe:	e9 6d f0 ff ff       	jmp    80106270 <alltraps>

80107203 <vector195>:
.globl vector195
vector195:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $195
80107205:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010720a:	e9 61 f0 ff ff       	jmp    80106270 <alltraps>

8010720f <vector196>:
.globl vector196
vector196:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $196
80107211:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107216:	e9 55 f0 ff ff       	jmp    80106270 <alltraps>

8010721b <vector197>:
.globl vector197
vector197:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $197
8010721d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107222:	e9 49 f0 ff ff       	jmp    80106270 <alltraps>

80107227 <vector198>:
.globl vector198
vector198:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $198
80107229:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010722e:	e9 3d f0 ff ff       	jmp    80106270 <alltraps>

80107233 <vector199>:
.globl vector199
vector199:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $199
80107235:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010723a:	e9 31 f0 ff ff       	jmp    80106270 <alltraps>

8010723f <vector200>:
.globl vector200
vector200:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $200
80107241:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107246:	e9 25 f0 ff ff       	jmp    80106270 <alltraps>

8010724b <vector201>:
.globl vector201
vector201:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $201
8010724d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107252:	e9 19 f0 ff ff       	jmp    80106270 <alltraps>

80107257 <vector202>:
.globl vector202
vector202:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $202
80107259:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010725e:	e9 0d f0 ff ff       	jmp    80106270 <alltraps>

80107263 <vector203>:
.globl vector203
vector203:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $203
80107265:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010726a:	e9 01 f0 ff ff       	jmp    80106270 <alltraps>

8010726f <vector204>:
.globl vector204
vector204:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $204
80107271:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107276:	e9 f5 ef ff ff       	jmp    80106270 <alltraps>

8010727b <vector205>:
.globl vector205
vector205:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $205
8010727d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107282:	e9 e9 ef ff ff       	jmp    80106270 <alltraps>

80107287 <vector206>:
.globl vector206
vector206:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $206
80107289:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010728e:	e9 dd ef ff ff       	jmp    80106270 <alltraps>

80107293 <vector207>:
.globl vector207
vector207:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $207
80107295:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010729a:	e9 d1 ef ff ff       	jmp    80106270 <alltraps>

8010729f <vector208>:
.globl vector208
vector208:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $208
801072a1:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801072a6:	e9 c5 ef ff ff       	jmp    80106270 <alltraps>

801072ab <vector209>:
.globl vector209
vector209:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $209
801072ad:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801072b2:	e9 b9 ef ff ff       	jmp    80106270 <alltraps>

801072b7 <vector210>:
.globl vector210
vector210:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $210
801072b9:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801072be:	e9 ad ef ff ff       	jmp    80106270 <alltraps>

801072c3 <vector211>:
.globl vector211
vector211:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $211
801072c5:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801072ca:	e9 a1 ef ff ff       	jmp    80106270 <alltraps>

801072cf <vector212>:
.globl vector212
vector212:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $212
801072d1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801072d6:	e9 95 ef ff ff       	jmp    80106270 <alltraps>

801072db <vector213>:
.globl vector213
vector213:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $213
801072dd:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801072e2:	e9 89 ef ff ff       	jmp    80106270 <alltraps>

801072e7 <vector214>:
.globl vector214
vector214:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $214
801072e9:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801072ee:	e9 7d ef ff ff       	jmp    80106270 <alltraps>

801072f3 <vector215>:
.globl vector215
vector215:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $215
801072f5:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801072fa:	e9 71 ef ff ff       	jmp    80106270 <alltraps>

801072ff <vector216>:
.globl vector216
vector216:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $216
80107301:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107306:	e9 65 ef ff ff       	jmp    80106270 <alltraps>

8010730b <vector217>:
.globl vector217
vector217:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $217
8010730d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107312:	e9 59 ef ff ff       	jmp    80106270 <alltraps>

80107317 <vector218>:
.globl vector218
vector218:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $218
80107319:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010731e:	e9 4d ef ff ff       	jmp    80106270 <alltraps>

80107323 <vector219>:
.globl vector219
vector219:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $219
80107325:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010732a:	e9 41 ef ff ff       	jmp    80106270 <alltraps>

8010732f <vector220>:
.globl vector220
vector220:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $220
80107331:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107336:	e9 35 ef ff ff       	jmp    80106270 <alltraps>

8010733b <vector221>:
.globl vector221
vector221:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $221
8010733d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107342:	e9 29 ef ff ff       	jmp    80106270 <alltraps>

80107347 <vector222>:
.globl vector222
vector222:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $222
80107349:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010734e:	e9 1d ef ff ff       	jmp    80106270 <alltraps>

80107353 <vector223>:
.globl vector223
vector223:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $223
80107355:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010735a:	e9 11 ef ff ff       	jmp    80106270 <alltraps>

8010735f <vector224>:
.globl vector224
vector224:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $224
80107361:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107366:	e9 05 ef ff ff       	jmp    80106270 <alltraps>

8010736b <vector225>:
.globl vector225
vector225:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $225
8010736d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107372:	e9 f9 ee ff ff       	jmp    80106270 <alltraps>

80107377 <vector226>:
.globl vector226
vector226:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $226
80107379:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010737e:	e9 ed ee ff ff       	jmp    80106270 <alltraps>

80107383 <vector227>:
.globl vector227
vector227:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $227
80107385:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010738a:	e9 e1 ee ff ff       	jmp    80106270 <alltraps>

8010738f <vector228>:
.globl vector228
vector228:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $228
80107391:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107396:	e9 d5 ee ff ff       	jmp    80106270 <alltraps>

8010739b <vector229>:
.globl vector229
vector229:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $229
8010739d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801073a2:	e9 c9 ee ff ff       	jmp    80106270 <alltraps>

801073a7 <vector230>:
.globl vector230
vector230:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $230
801073a9:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801073ae:	e9 bd ee ff ff       	jmp    80106270 <alltraps>

801073b3 <vector231>:
.globl vector231
vector231:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $231
801073b5:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801073ba:	e9 b1 ee ff ff       	jmp    80106270 <alltraps>

801073bf <vector232>:
.globl vector232
vector232:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $232
801073c1:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801073c6:	e9 a5 ee ff ff       	jmp    80106270 <alltraps>

801073cb <vector233>:
.globl vector233
vector233:
  pushl $0
801073cb:	6a 00                	push   $0x0
  pushl $233
801073cd:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801073d2:	e9 99 ee ff ff       	jmp    80106270 <alltraps>

801073d7 <vector234>:
.globl vector234
vector234:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $234
801073d9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801073de:	e9 8d ee ff ff       	jmp    80106270 <alltraps>

801073e3 <vector235>:
.globl vector235
vector235:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $235
801073e5:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801073ea:	e9 81 ee ff ff       	jmp    80106270 <alltraps>

801073ef <vector236>:
.globl vector236
vector236:
  pushl $0
801073ef:	6a 00                	push   $0x0
  pushl $236
801073f1:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801073f6:	e9 75 ee ff ff       	jmp    80106270 <alltraps>

801073fb <vector237>:
.globl vector237
vector237:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $237
801073fd:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107402:	e9 69 ee ff ff       	jmp    80106270 <alltraps>

80107407 <vector238>:
.globl vector238
vector238:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $238
80107409:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010740e:	e9 5d ee ff ff       	jmp    80106270 <alltraps>

80107413 <vector239>:
.globl vector239
vector239:
  pushl $0
80107413:	6a 00                	push   $0x0
  pushl $239
80107415:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010741a:	e9 51 ee ff ff       	jmp    80106270 <alltraps>

8010741f <vector240>:
.globl vector240
vector240:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $240
80107421:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107426:	e9 45 ee ff ff       	jmp    80106270 <alltraps>

8010742b <vector241>:
.globl vector241
vector241:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $241
8010742d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107432:	e9 39 ee ff ff       	jmp    80106270 <alltraps>

80107437 <vector242>:
.globl vector242
vector242:
  pushl $0
80107437:	6a 00                	push   $0x0
  pushl $242
80107439:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010743e:	e9 2d ee ff ff       	jmp    80106270 <alltraps>

80107443 <vector243>:
.globl vector243
vector243:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $243
80107445:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010744a:	e9 21 ee ff ff       	jmp    80106270 <alltraps>

8010744f <vector244>:
.globl vector244
vector244:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $244
80107451:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107456:	e9 15 ee ff ff       	jmp    80106270 <alltraps>

8010745b <vector245>:
.globl vector245
vector245:
  pushl $0
8010745b:	6a 00                	push   $0x0
  pushl $245
8010745d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107462:	e9 09 ee ff ff       	jmp    80106270 <alltraps>

80107467 <vector246>:
.globl vector246
vector246:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $246
80107469:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010746e:	e9 fd ed ff ff       	jmp    80106270 <alltraps>

80107473 <vector247>:
.globl vector247
vector247:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $247
80107475:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010747a:	e9 f1 ed ff ff       	jmp    80106270 <alltraps>

8010747f <vector248>:
.globl vector248
vector248:
  pushl $0
8010747f:	6a 00                	push   $0x0
  pushl $248
80107481:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107486:	e9 e5 ed ff ff       	jmp    80106270 <alltraps>

8010748b <vector249>:
.globl vector249
vector249:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $249
8010748d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107492:	e9 d9 ed ff ff       	jmp    80106270 <alltraps>

80107497 <vector250>:
.globl vector250
vector250:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $250
80107499:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010749e:	e9 cd ed ff ff       	jmp    80106270 <alltraps>

801074a3 <vector251>:
.globl vector251
vector251:
  pushl $0
801074a3:	6a 00                	push   $0x0
  pushl $251
801074a5:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801074aa:	e9 c1 ed ff ff       	jmp    80106270 <alltraps>

801074af <vector252>:
.globl vector252
vector252:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $252
801074b1:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801074b6:	e9 b5 ed ff ff       	jmp    80106270 <alltraps>

801074bb <vector253>:
.globl vector253
vector253:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $253
801074bd:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801074c2:	e9 a9 ed ff ff       	jmp    80106270 <alltraps>

801074c7 <vector254>:
.globl vector254
vector254:
  pushl $0
801074c7:	6a 00                	push   $0x0
  pushl $254
801074c9:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801074ce:	e9 9d ed ff ff       	jmp    80106270 <alltraps>

801074d3 <vector255>:
.globl vector255
vector255:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $255
801074d5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801074da:	e9 91 ed ff ff       	jmp    80106270 <alltraps>

801074df <lgdt>:
{
801074df:	55                   	push   %ebp
801074e0:	89 e5                	mov    %esp,%ebp
801074e2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801074e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801074e8:	83 e8 01             	sub    $0x1,%eax
801074eb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801074ef:	8b 45 08             	mov    0x8(%ebp),%eax
801074f2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801074f6:	8b 45 08             	mov    0x8(%ebp),%eax
801074f9:	c1 e8 10             	shr    $0x10,%eax
801074fc:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107500:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107503:	0f 01 10             	lgdtl  (%eax)
}
80107506:	90                   	nop
80107507:	c9                   	leave  
80107508:	c3                   	ret    

80107509 <ltr>:
{
80107509:	55                   	push   %ebp
8010750a:	89 e5                	mov    %esp,%ebp
8010750c:	83 ec 04             	sub    $0x4,%esp
8010750f:	8b 45 08             	mov    0x8(%ebp),%eax
80107512:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107516:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010751a:	0f 00 d8             	ltr    %ax
}
8010751d:	90                   	nop
8010751e:	c9                   	leave  
8010751f:	c3                   	ret    

80107520 <lcr3>:

static inline void
lcr3(uint val)
{
80107520:	55                   	push   %ebp
80107521:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107523:	8b 45 08             	mov    0x8(%ebp),%eax
80107526:	0f 22 d8             	mov    %eax,%cr3
}
80107529:	90                   	nop
8010752a:	5d                   	pop    %ebp
8010752b:	c3                   	ret    

8010752c <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010752c:	55                   	push   %ebp
8010752d:	89 e5                	mov    %esp,%ebp
8010752f:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107532:	e8 94 c4 ff ff       	call   801039cb <cpuid>
80107537:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
8010753d:	05 c0 76 19 80       	add    $0x801976c0,%eax
80107542:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107548:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010754e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107551:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755a:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010755e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107561:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107565:	83 e2 f0             	and    $0xfffffff0,%edx
80107568:	83 ca 0a             	or     $0xa,%edx
8010756b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010756e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107571:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107575:	83 ca 10             	or     $0x10,%edx
80107578:	88 50 7d             	mov    %dl,0x7d(%eax)
8010757b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107582:	83 e2 9f             	and    $0xffffff9f,%edx
80107585:	88 50 7d             	mov    %dl,0x7d(%eax)
80107588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010758f:	83 ca 80             	or     $0xffffff80,%edx
80107592:	88 50 7d             	mov    %dl,0x7d(%eax)
80107595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107598:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010759c:	83 ca 0f             	or     $0xf,%edx
8010759f:	88 50 7e             	mov    %dl,0x7e(%eax)
801075a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075a9:	83 e2 ef             	and    $0xffffffef,%edx
801075ac:	88 50 7e             	mov    %dl,0x7e(%eax)
801075af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075b6:	83 e2 df             	and    $0xffffffdf,%edx
801075b9:	88 50 7e             	mov    %dl,0x7e(%eax)
801075bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075c3:	83 ca 40             	or     $0x40,%edx
801075c6:	88 50 7e             	mov    %dl,0x7e(%eax)
801075c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075d0:	83 ca 80             	or     $0xffffff80,%edx
801075d3:	88 50 7e             	mov    %dl,0x7e(%eax)
801075d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801075dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801075e7:	ff ff 
801075e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ec:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801075f3:	00 00 
801075f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f8:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801075ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107602:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107609:	83 e2 f0             	and    $0xfffffff0,%edx
8010760c:	83 ca 02             	or     $0x2,%edx
8010760f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107618:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010761f:	83 ca 10             	or     $0x10,%edx
80107622:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107632:	83 e2 9f             	and    $0xffffff9f,%edx
80107635:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010763b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107645:	83 ca 80             	or     $0xffffff80,%edx
80107648:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010764e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107651:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107658:	83 ca 0f             	or     $0xf,%edx
8010765b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107664:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010766b:	83 e2 ef             	and    $0xffffffef,%edx
8010766e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107677:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010767e:	83 e2 df             	and    $0xffffffdf,%edx
80107681:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107691:	83 ca 40             	or     $0x40,%edx
80107694:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010769a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076a4:	83 ca 80             	or     $0xffffff80,%edx
801076a7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b0:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801076b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ba:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801076c1:	ff ff 
801076c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c6:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801076cd:	00 00 
801076cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d2:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801076d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076dc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076e3:	83 e2 f0             	and    $0xfffffff0,%edx
801076e6:	83 ca 0a             	or     $0xa,%edx
801076e9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076f9:	83 ca 10             	or     $0x10,%edx
801076fc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107705:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010770c:	83 ca 60             	or     $0x60,%edx
8010770f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107718:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010771f:	83 ca 80             	or     $0xffffff80,%edx
80107722:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107732:	83 ca 0f             	or     $0xf,%edx
80107735:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010773b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107745:	83 e2 ef             	and    $0xffffffef,%edx
80107748:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010774e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107751:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107758:	83 e2 df             	and    $0xffffffdf,%edx
8010775b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107764:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010776b:	83 ca 40             	or     $0x40,%edx
8010776e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107777:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010777e:	83 ca 80             	or     $0xffffff80,%edx
80107781:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778a:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107794:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010779b:	ff ff 
8010779d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a0:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801077a7:	00 00 
801077a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ac:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801077b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077bd:	83 e2 f0             	and    $0xfffffff0,%edx
801077c0:	83 ca 02             	or     $0x2,%edx
801077c3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077d3:	83 ca 10             	or     $0x10,%edx
801077d6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077df:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077e6:	83 ca 60             	or     $0x60,%edx
801077e9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077f9:	83 ca 80             	or     $0xffffff80,%edx
801077fc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107805:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010780c:	83 ca 0f             	or     $0xf,%edx
8010780f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107818:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010781f:	83 e2 ef             	and    $0xffffffef,%edx
80107822:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107832:	83 e2 df             	and    $0xffffffdf,%edx
80107835:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010783b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107845:	83 ca 40             	or     $0x40,%edx
80107848:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010784e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107851:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107858:	83 ca 80             	or     $0xffffff80,%edx
8010785b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107864:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010786b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786e:	83 c0 70             	add    $0x70,%eax
80107871:	83 ec 08             	sub    $0x8,%esp
80107874:	6a 30                	push   $0x30
80107876:	50                   	push   %eax
80107877:	e8 63 fc ff ff       	call   801074df <lgdt>
8010787c:	83 c4 10             	add    $0x10,%esp
}
8010787f:	90                   	nop
80107880:	c9                   	leave  
80107881:	c3                   	ret    

80107882 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107882:	55                   	push   %ebp
80107883:	89 e5                	mov    %esp,%ebp
80107885:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107888:	8b 45 0c             	mov    0xc(%ebp),%eax
8010788b:	c1 e8 16             	shr    $0x16,%eax
8010788e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107895:	8b 45 08             	mov    0x8(%ebp),%eax
80107898:	01 d0                	add    %edx,%eax
8010789a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010789d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078a0:	8b 00                	mov    (%eax),%eax
801078a2:	83 e0 01             	and    $0x1,%eax
801078a5:	85 c0                	test   %eax,%eax
801078a7:	74 14                	je     801078bd <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801078a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078ac:	8b 00                	mov    (%eax),%eax
801078ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078b3:	05 00 00 00 80       	add    $0x80000000,%eax
801078b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078bb:	eb 42                	jmp    801078ff <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801078bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801078c1:	74 0e                	je     801078d1 <walkpgdir+0x4f>
801078c3:	e8 d8 ae ff ff       	call   801027a0 <kalloc>
801078c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801078cf:	75 07                	jne    801078d8 <walkpgdir+0x56>
      return 0;
801078d1:	b8 00 00 00 00       	mov    $0x0,%eax
801078d6:	eb 3e                	jmp    80107916 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801078d8:	83 ec 04             	sub    $0x4,%esp
801078db:	68 00 10 00 00       	push   $0x1000
801078e0:	6a 00                	push   $0x0
801078e2:	ff 75 f4             	push   -0xc(%ebp)
801078e5:	e8 98 d5 ff ff       	call   80104e82 <memset>
801078ea:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801078ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f0:	05 00 00 00 80       	add    $0x80000000,%eax
801078f5:	83 c8 07             	or     $0x7,%eax
801078f8:	89 c2                	mov    %eax,%edx
801078fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078fd:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801078ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80107902:	c1 e8 0c             	shr    $0xc,%eax
80107905:	25 ff 03 00 00       	and    $0x3ff,%eax
8010790a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107914:	01 d0                	add    %edx,%eax
}
80107916:	c9                   	leave  
80107917:	c3                   	ret    

80107918 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107918:	55                   	push   %ebp
80107919:	89 e5                	mov    %esp,%ebp
8010791b:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010791e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107921:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107926:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107929:	8b 55 0c             	mov    0xc(%ebp),%edx
8010792c:	8b 45 10             	mov    0x10(%ebp),%eax
8010792f:	01 d0                	add    %edx,%eax
80107931:	83 e8 01             	sub    $0x1,%eax
80107934:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107939:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010793c:	83 ec 04             	sub    $0x4,%esp
8010793f:	6a 01                	push   $0x1
80107941:	ff 75 f4             	push   -0xc(%ebp)
80107944:	ff 75 08             	push   0x8(%ebp)
80107947:	e8 36 ff ff ff       	call   80107882 <walkpgdir>
8010794c:	83 c4 10             	add    $0x10,%esp
8010794f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107952:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107956:	75 07                	jne    8010795f <mappages+0x47>
      return -1;
80107958:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010795d:	eb 47                	jmp    801079a6 <mappages+0x8e>
    if(*pte & PTE_P)
8010795f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107962:	8b 00                	mov    (%eax),%eax
80107964:	83 e0 01             	and    $0x1,%eax
80107967:	85 c0                	test   %eax,%eax
80107969:	74 0d                	je     80107978 <mappages+0x60>
      panic("remap");
8010796b:	83 ec 0c             	sub    $0xc,%esp
8010796e:	68 48 ac 10 80       	push   $0x8010ac48
80107973:	e8 31 8c ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107978:	8b 45 18             	mov    0x18(%ebp),%eax
8010797b:	0b 45 14             	or     0x14(%ebp),%eax
8010797e:	83 c8 01             	or     $0x1,%eax
80107981:	89 c2                	mov    %eax,%edx
80107983:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107986:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010798e:	74 10                	je     801079a0 <mappages+0x88>
      break;
    a += PGSIZE;
80107990:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107997:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010799e:	eb 9c                	jmp    8010793c <mappages+0x24>
      break;
801079a0:	90                   	nop
  }
  return 0;
801079a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801079a6:	c9                   	leave  
801079a7:	c3                   	ret    

801079a8 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801079a8:	55                   	push   %ebp
801079a9:	89 e5                	mov    %esp,%ebp
801079ab:	53                   	push   %ebx
801079ac:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801079af:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801079b6:	8b 15 a0 79 19 80    	mov    0x801979a0,%edx
801079bc:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801079c1:	29 d0                	sub    %edx,%eax
801079c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801079c6:	a1 98 79 19 80       	mov    0x80197998,%eax
801079cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801079ce:	8b 15 98 79 19 80    	mov    0x80197998,%edx
801079d4:	a1 a0 79 19 80       	mov    0x801979a0,%eax
801079d9:	01 d0                	add    %edx,%eax
801079db:	89 45 e8             	mov    %eax,-0x18(%ebp)
801079de:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801079e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e8:	83 c0 30             	add    $0x30,%eax
801079eb:	8b 55 e0             	mov    -0x20(%ebp),%edx
801079ee:	89 10                	mov    %edx,(%eax)
801079f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801079f3:	89 50 04             	mov    %edx,0x4(%eax)
801079f6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801079f9:	89 50 08             	mov    %edx,0x8(%eax)
801079fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801079ff:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107a02:	e8 99 ad ff ff       	call   801027a0 <kalloc>
80107a07:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a0e:	75 07                	jne    80107a17 <setupkvm+0x6f>
    return 0;
80107a10:	b8 00 00 00 00       	mov    $0x0,%eax
80107a15:	eb 78                	jmp    80107a8f <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107a17:	83 ec 04             	sub    $0x4,%esp
80107a1a:	68 00 10 00 00       	push   $0x1000
80107a1f:	6a 00                	push   $0x0
80107a21:	ff 75 f0             	push   -0x10(%ebp)
80107a24:	e8 59 d4 ff ff       	call   80104e82 <memset>
80107a29:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a2c:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107a33:	eb 4e                	jmp    80107a83 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a38:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3e:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a44:	8b 58 08             	mov    0x8(%eax),%ebx
80107a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4a:	8b 40 04             	mov    0x4(%eax),%eax
80107a4d:	29 c3                	sub    %eax,%ebx
80107a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a52:	8b 00                	mov    (%eax),%eax
80107a54:	83 ec 0c             	sub    $0xc,%esp
80107a57:	51                   	push   %ecx
80107a58:	52                   	push   %edx
80107a59:	53                   	push   %ebx
80107a5a:	50                   	push   %eax
80107a5b:	ff 75 f0             	push   -0x10(%ebp)
80107a5e:	e8 b5 fe ff ff       	call   80107918 <mappages>
80107a63:	83 c4 20             	add    $0x20,%esp
80107a66:	85 c0                	test   %eax,%eax
80107a68:	79 15                	jns    80107a7f <setupkvm+0xd7>
      freevm(pgdir);
80107a6a:	83 ec 0c             	sub    $0xc,%esp
80107a6d:	ff 75 f0             	push   -0x10(%ebp)
80107a70:	e8 f5 04 00 00       	call   80107f6a <freevm>
80107a75:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a78:	b8 00 00 00 00       	mov    $0x0,%eax
80107a7d:	eb 10                	jmp    80107a8f <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a7f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a83:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107a8a:	72 a9                	jb     80107a35 <setupkvm+0x8d>
    }
  return pgdir;
80107a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107a92:	c9                   	leave  
80107a93:	c3                   	ret    

80107a94 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a94:	55                   	push   %ebp
80107a95:	89 e5                	mov    %esp,%ebp
80107a97:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a9a:	e8 09 ff ff ff       	call   801079a8 <setupkvm>
80107a9f:	a3 bc 76 19 80       	mov    %eax,0x801976bc
  switchkvm();
80107aa4:	e8 03 00 00 00       	call   80107aac <switchkvm>
}
80107aa9:	90                   	nop
80107aaa:	c9                   	leave  
80107aab:	c3                   	ret    

80107aac <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107aac:	55                   	push   %ebp
80107aad:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107aaf:	a1 bc 76 19 80       	mov    0x801976bc,%eax
80107ab4:	05 00 00 00 80       	add    $0x80000000,%eax
80107ab9:	50                   	push   %eax
80107aba:	e8 61 fa ff ff       	call   80107520 <lcr3>
80107abf:	83 c4 04             	add    $0x4,%esp
}
80107ac2:	90                   	nop
80107ac3:	c9                   	leave  
80107ac4:	c3                   	ret    

80107ac5 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ac5:	55                   	push   %ebp
80107ac6:	89 e5                	mov    %esp,%ebp
80107ac8:	56                   	push   %esi
80107ac9:	53                   	push   %ebx
80107aca:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107acd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107ad1:	75 0d                	jne    80107ae0 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107ad3:	83 ec 0c             	sub    $0xc,%esp
80107ad6:	68 4e ac 10 80       	push   $0x8010ac4e
80107adb:	e8 c9 8a ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80107ae3:	8b 40 08             	mov    0x8(%eax),%eax
80107ae6:	85 c0                	test   %eax,%eax
80107ae8:	75 0d                	jne    80107af7 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107aea:	83 ec 0c             	sub    $0xc,%esp
80107aed:	68 64 ac 10 80       	push   $0x8010ac64
80107af2:	e8 b2 8a ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107af7:	8b 45 08             	mov    0x8(%ebp),%eax
80107afa:	8b 40 04             	mov    0x4(%eax),%eax
80107afd:	85 c0                	test   %eax,%eax
80107aff:	75 0d                	jne    80107b0e <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107b01:	83 ec 0c             	sub    $0xc,%esp
80107b04:	68 79 ac 10 80       	push   $0x8010ac79
80107b09:	e8 9b 8a ff ff       	call   801005a9 <panic>

  pushcli();
80107b0e:	e8 64 d2 ff ff       	call   80104d77 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107b13:	e8 ce be ff ff       	call   801039e6 <mycpu>
80107b18:	89 c3                	mov    %eax,%ebx
80107b1a:	e8 c7 be ff ff       	call   801039e6 <mycpu>
80107b1f:	83 c0 08             	add    $0x8,%eax
80107b22:	89 c6                	mov    %eax,%esi
80107b24:	e8 bd be ff ff       	call   801039e6 <mycpu>
80107b29:	83 c0 08             	add    $0x8,%eax
80107b2c:	c1 e8 10             	shr    $0x10,%eax
80107b2f:	88 45 f7             	mov    %al,-0x9(%ebp)
80107b32:	e8 af be ff ff       	call   801039e6 <mycpu>
80107b37:	83 c0 08             	add    $0x8,%eax
80107b3a:	c1 e8 18             	shr    $0x18,%eax
80107b3d:	89 c2                	mov    %eax,%edx
80107b3f:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107b46:	67 00 
80107b48:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107b4f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107b53:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107b59:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b60:	83 e0 f0             	and    $0xfffffff0,%eax
80107b63:	83 c8 09             	or     $0x9,%eax
80107b66:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b6c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b73:	83 c8 10             	or     $0x10,%eax
80107b76:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b7c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b83:	83 e0 9f             	and    $0xffffff9f,%eax
80107b86:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b8c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b93:	83 c8 80             	or     $0xffffff80,%eax
80107b96:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b9c:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ba3:	83 e0 f0             	and    $0xfffffff0,%eax
80107ba6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107bac:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107bb3:	83 e0 ef             	and    $0xffffffef,%eax
80107bb6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107bbc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107bc3:	83 e0 df             	and    $0xffffffdf,%eax
80107bc6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107bcc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107bd3:	83 c8 40             	or     $0x40,%eax
80107bd6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107bdc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107be3:	83 e0 7f             	and    $0x7f,%eax
80107be6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107bec:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107bf2:	e8 ef bd ff ff       	call   801039e6 <mycpu>
80107bf7:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bfe:	83 e2 ef             	and    $0xffffffef,%edx
80107c01:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107c07:	e8 da bd ff ff       	call   801039e6 <mycpu>
80107c0c:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107c12:	8b 45 08             	mov    0x8(%ebp),%eax
80107c15:	8b 40 08             	mov    0x8(%eax),%eax
80107c18:	89 c3                	mov    %eax,%ebx
80107c1a:	e8 c7 bd ff ff       	call   801039e6 <mycpu>
80107c1f:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107c25:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107c28:	e8 b9 bd ff ff       	call   801039e6 <mycpu>
80107c2d:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107c33:	83 ec 0c             	sub    $0xc,%esp
80107c36:	6a 28                	push   $0x28
80107c38:	e8 cc f8 ff ff       	call   80107509 <ltr>
80107c3d:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107c40:	8b 45 08             	mov    0x8(%ebp),%eax
80107c43:	8b 40 04             	mov    0x4(%eax),%eax
80107c46:	05 00 00 00 80       	add    $0x80000000,%eax
80107c4b:	83 ec 0c             	sub    $0xc,%esp
80107c4e:	50                   	push   %eax
80107c4f:	e8 cc f8 ff ff       	call   80107520 <lcr3>
80107c54:	83 c4 10             	add    $0x10,%esp
  popcli();
80107c57:	e8 68 d1 ff ff       	call   80104dc4 <popcli>
}
80107c5c:	90                   	nop
80107c5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107c60:	5b                   	pop    %ebx
80107c61:	5e                   	pop    %esi
80107c62:	5d                   	pop    %ebp
80107c63:	c3                   	ret    

80107c64 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c64:	55                   	push   %ebp
80107c65:	89 e5                	mov    %esp,%ebp
80107c67:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107c6a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107c71:	76 0d                	jbe    80107c80 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107c73:	83 ec 0c             	sub    $0xc,%esp
80107c76:	68 8d ac 10 80       	push   $0x8010ac8d
80107c7b:	e8 29 89 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107c80:	e8 1b ab ff ff       	call   801027a0 <kalloc>
80107c85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c88:	83 ec 04             	sub    $0x4,%esp
80107c8b:	68 00 10 00 00       	push   $0x1000
80107c90:	6a 00                	push   $0x0
80107c92:	ff 75 f4             	push   -0xc(%ebp)
80107c95:	e8 e8 d1 ff ff       	call   80104e82 <memset>
80107c9a:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ca5:	83 ec 0c             	sub    $0xc,%esp
80107ca8:	6a 06                	push   $0x6
80107caa:	50                   	push   %eax
80107cab:	68 00 10 00 00       	push   $0x1000
80107cb0:	6a 00                	push   $0x0
80107cb2:	ff 75 08             	push   0x8(%ebp)
80107cb5:	e8 5e fc ff ff       	call   80107918 <mappages>
80107cba:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107cbd:	83 ec 04             	sub    $0x4,%esp
80107cc0:	ff 75 10             	push   0x10(%ebp)
80107cc3:	ff 75 0c             	push   0xc(%ebp)
80107cc6:	ff 75 f4             	push   -0xc(%ebp)
80107cc9:	e8 73 d2 ff ff       	call   80104f41 <memmove>
80107cce:	83 c4 10             	add    $0x10,%esp
}
80107cd1:	90                   	nop
80107cd2:	c9                   	leave  
80107cd3:	c3                   	ret    

80107cd4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107cd4:	55                   	push   %ebp
80107cd5:	89 e5                	mov    %esp,%ebp
80107cd7:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107cda:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cdd:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ce2:	85 c0                	test   %eax,%eax
80107ce4:	74 0d                	je     80107cf3 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107ce6:	83 ec 0c             	sub    $0xc,%esp
80107ce9:	68 a8 ac 10 80       	push   $0x8010aca8
80107cee:	e8 b6 88 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107cf3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107cfa:	e9 8f 00 00 00       	jmp    80107d8e <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107cff:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d05:	01 d0                	add    %edx,%eax
80107d07:	83 ec 04             	sub    $0x4,%esp
80107d0a:	6a 00                	push   $0x0
80107d0c:	50                   	push   %eax
80107d0d:	ff 75 08             	push   0x8(%ebp)
80107d10:	e8 6d fb ff ff       	call   80107882 <walkpgdir>
80107d15:	83 c4 10             	add    $0x10,%esp
80107d18:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d1f:	75 0d                	jne    80107d2e <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107d21:	83 ec 0c             	sub    $0xc,%esp
80107d24:	68 cb ac 10 80       	push   $0x8010accb
80107d29:	e8 7b 88 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d31:	8b 00                	mov    (%eax),%eax
80107d33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d38:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107d3b:	8b 45 18             	mov    0x18(%ebp),%eax
80107d3e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d41:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d46:	77 0b                	ja     80107d53 <loaduvm+0x7f>
      n = sz - i;
80107d48:	8b 45 18             	mov    0x18(%ebp),%eax
80107d4b:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d51:	eb 07                	jmp    80107d5a <loaduvm+0x86>
    else
      n = PGSIZE;
80107d53:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107d5a:	8b 55 14             	mov    0x14(%ebp),%edx
80107d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d60:	01 d0                	add    %edx,%eax
80107d62:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107d65:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107d6b:	ff 75 f0             	push   -0x10(%ebp)
80107d6e:	50                   	push   %eax
80107d6f:	52                   	push   %edx
80107d70:	ff 75 10             	push   0x10(%ebp)
80107d73:	e8 5e a1 ff ff       	call   80101ed6 <readi>
80107d78:	83 c4 10             	add    $0x10,%esp
80107d7b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107d7e:	74 07                	je     80107d87 <loaduvm+0xb3>
      return -1;
80107d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d85:	eb 18                	jmp    80107d9f <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107d87:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d91:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d94:	0f 82 65 ff ff ff    	jb     80107cff <loaduvm+0x2b>
  }
  return 0;
80107d9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d9f:	c9                   	leave  
80107da0:	c3                   	ret    

80107da1 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107da1:	55                   	push   %ebp
80107da2:	89 e5                	mov    %esp,%ebp
80107da4:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107da7:	8b 45 10             	mov    0x10(%ebp),%eax
80107daa:	85 c0                	test   %eax,%eax
80107dac:	79 0a                	jns    80107db8 <allocuvm+0x17>
    return 0;
80107dae:	b8 00 00 00 00       	mov    $0x0,%eax
80107db3:	e9 ec 00 00 00       	jmp    80107ea4 <allocuvm+0x103>
  if(newsz < oldsz)
80107db8:	8b 45 10             	mov    0x10(%ebp),%eax
80107dbb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107dbe:	73 08                	jae    80107dc8 <allocuvm+0x27>
    return oldsz;
80107dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dc3:	e9 dc 00 00 00       	jmp    80107ea4 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dcb:	05 ff 0f 00 00       	add    $0xfff,%eax
80107dd0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107dd8:	e9 b8 00 00 00       	jmp    80107e95 <allocuvm+0xf4>
    mem = kalloc();
80107ddd:	e8 be a9 ff ff       	call   801027a0 <kalloc>
80107de2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107de5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107de9:	75 2e                	jne    80107e19 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107deb:	83 ec 0c             	sub    $0xc,%esp
80107dee:	68 e9 ac 10 80       	push   $0x8010ace9
80107df3:	e8 fc 85 ff ff       	call   801003f4 <cprintf>
80107df8:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107dfb:	83 ec 04             	sub    $0x4,%esp
80107dfe:	ff 75 0c             	push   0xc(%ebp)
80107e01:	ff 75 10             	push   0x10(%ebp)
80107e04:	ff 75 08             	push   0x8(%ebp)
80107e07:	e8 9a 00 00 00       	call   80107ea6 <deallocuvm>
80107e0c:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e0f:	b8 00 00 00 00       	mov    $0x0,%eax
80107e14:	e9 8b 00 00 00       	jmp    80107ea4 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107e19:	83 ec 04             	sub    $0x4,%esp
80107e1c:	68 00 10 00 00       	push   $0x1000
80107e21:	6a 00                	push   $0x0
80107e23:	ff 75 f0             	push   -0x10(%ebp)
80107e26:	e8 57 d0 ff ff       	call   80104e82 <memset>
80107e2b:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e31:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3a:	83 ec 0c             	sub    $0xc,%esp
80107e3d:	6a 06                	push   $0x6
80107e3f:	52                   	push   %edx
80107e40:	68 00 10 00 00       	push   $0x1000
80107e45:	50                   	push   %eax
80107e46:	ff 75 08             	push   0x8(%ebp)
80107e49:	e8 ca fa ff ff       	call   80107918 <mappages>
80107e4e:	83 c4 20             	add    $0x20,%esp
80107e51:	85 c0                	test   %eax,%eax
80107e53:	79 39                	jns    80107e8e <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107e55:	83 ec 0c             	sub    $0xc,%esp
80107e58:	68 01 ad 10 80       	push   $0x8010ad01
80107e5d:	e8 92 85 ff ff       	call   801003f4 <cprintf>
80107e62:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e65:	83 ec 04             	sub    $0x4,%esp
80107e68:	ff 75 0c             	push   0xc(%ebp)
80107e6b:	ff 75 10             	push   0x10(%ebp)
80107e6e:	ff 75 08             	push   0x8(%ebp)
80107e71:	e8 30 00 00 00       	call   80107ea6 <deallocuvm>
80107e76:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107e79:	83 ec 0c             	sub    $0xc,%esp
80107e7c:	ff 75 f0             	push   -0x10(%ebp)
80107e7f:	e8 82 a8 ff ff       	call   80102706 <kfree>
80107e84:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e87:	b8 00 00 00 00       	mov    $0x0,%eax
80107e8c:	eb 16                	jmp    80107ea4 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107e8e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e98:	3b 45 10             	cmp    0x10(%ebp),%eax
80107e9b:	0f 82 3c ff ff ff    	jb     80107ddd <allocuvm+0x3c>
    }
  }
  return newsz;
80107ea1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ea4:	c9                   	leave  
80107ea5:	c3                   	ret    

80107ea6 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ea6:	55                   	push   %ebp
80107ea7:	89 e5                	mov    %esp,%ebp
80107ea9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107eac:	8b 45 10             	mov    0x10(%ebp),%eax
80107eaf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107eb2:	72 08                	jb     80107ebc <deallocuvm+0x16>
    return oldsz;
80107eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eb7:	e9 ac 00 00 00       	jmp    80107f68 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107ebc:	8b 45 10             	mov    0x10(%ebp),%eax
80107ebf:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ec4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ec9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107ecc:	e9 88 00 00 00       	jmp    80107f59 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed4:	83 ec 04             	sub    $0x4,%esp
80107ed7:	6a 00                	push   $0x0
80107ed9:	50                   	push   %eax
80107eda:	ff 75 08             	push   0x8(%ebp)
80107edd:	e8 a0 f9 ff ff       	call   80107882 <walkpgdir>
80107ee2:	83 c4 10             	add    $0x10,%esp
80107ee5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107ee8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107eec:	75 16                	jne    80107f04 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef1:	c1 e8 16             	shr    $0x16,%eax
80107ef4:	83 c0 01             	add    $0x1,%eax
80107ef7:	c1 e0 16             	shl    $0x16,%eax
80107efa:	2d 00 10 00 00       	sub    $0x1000,%eax
80107eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f02:	eb 4e                	jmp    80107f52 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f07:	8b 00                	mov    (%eax),%eax
80107f09:	83 e0 01             	and    $0x1,%eax
80107f0c:	85 c0                	test   %eax,%eax
80107f0e:	74 42                	je     80107f52 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107f10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f13:	8b 00                	mov    (%eax),%eax
80107f15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107f1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f21:	75 0d                	jne    80107f30 <deallocuvm+0x8a>
        panic("kfree");
80107f23:	83 ec 0c             	sub    $0xc,%esp
80107f26:	68 1d ad 10 80       	push   $0x8010ad1d
80107f2b:	e8 79 86 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107f30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f33:	05 00 00 00 80       	add    $0x80000000,%eax
80107f38:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107f3b:	83 ec 0c             	sub    $0xc,%esp
80107f3e:	ff 75 e8             	push   -0x18(%ebp)
80107f41:	e8 c0 a7 ff ff       	call   80102706 <kfree>
80107f46:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107f52:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f5f:	0f 82 6c ff ff ff    	jb     80107ed1 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107f65:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f68:	c9                   	leave  
80107f69:	c3                   	ret    

80107f6a <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107f6a:	55                   	push   %ebp
80107f6b:	89 e5                	mov    %esp,%ebp
80107f6d:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107f70:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f74:	75 0d                	jne    80107f83 <freevm+0x19>
    panic("freevm: no pgdir");
80107f76:	83 ec 0c             	sub    $0xc,%esp
80107f79:	68 23 ad 10 80       	push   $0x8010ad23
80107f7e:	e8 26 86 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107f83:	83 ec 04             	sub    $0x4,%esp
80107f86:	6a 00                	push   $0x0
80107f88:	68 00 00 00 80       	push   $0x80000000
80107f8d:	ff 75 08             	push   0x8(%ebp)
80107f90:	e8 11 ff ff ff       	call   80107ea6 <deallocuvm>
80107f95:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f9f:	eb 48                	jmp    80107fe9 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fab:	8b 45 08             	mov    0x8(%ebp),%eax
80107fae:	01 d0                	add    %edx,%eax
80107fb0:	8b 00                	mov    (%eax),%eax
80107fb2:	83 e0 01             	and    $0x1,%eax
80107fb5:	85 c0                	test   %eax,%eax
80107fb7:	74 2c                	je     80107fe5 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc6:	01 d0                	add    %edx,%eax
80107fc8:	8b 00                	mov    (%eax),%eax
80107fca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fcf:	05 00 00 00 80       	add    $0x80000000,%eax
80107fd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107fd7:	83 ec 0c             	sub    $0xc,%esp
80107fda:	ff 75 f0             	push   -0x10(%ebp)
80107fdd:	e8 24 a7 ff ff       	call   80102706 <kfree>
80107fe2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107fe5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fe9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107ff0:	76 af                	jbe    80107fa1 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107ff2:	83 ec 0c             	sub    $0xc,%esp
80107ff5:	ff 75 08             	push   0x8(%ebp)
80107ff8:	e8 09 a7 ff ff       	call   80102706 <kfree>
80107ffd:	83 c4 10             	add    $0x10,%esp
}
80108000:	90                   	nop
80108001:	c9                   	leave  
80108002:	c3                   	ret    

80108003 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108003:	55                   	push   %ebp
80108004:	89 e5                	mov    %esp,%ebp
80108006:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108009:	83 ec 04             	sub    $0x4,%esp
8010800c:	6a 00                	push   $0x0
8010800e:	ff 75 0c             	push   0xc(%ebp)
80108011:	ff 75 08             	push   0x8(%ebp)
80108014:	e8 69 f8 ff ff       	call   80107882 <walkpgdir>
80108019:	83 c4 10             	add    $0x10,%esp
8010801c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010801f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108023:	75 0d                	jne    80108032 <clearpteu+0x2f>
    panic("clearpteu");
80108025:	83 ec 0c             	sub    $0xc,%esp
80108028:	68 34 ad 10 80       	push   $0x8010ad34
8010802d:	e8 77 85 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80108032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108035:	8b 00                	mov    (%eax),%eax
80108037:	83 e0 fb             	and    $0xfffffffb,%eax
8010803a:	89 c2                	mov    %eax,%edx
8010803c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803f:	89 10                	mov    %edx,(%eax)
}
80108041:	90                   	nop
80108042:	c9                   	leave  
80108043:	c3                   	ret    

80108044 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108044:	55                   	push   %ebp
80108045:	89 e5                	mov    %esp,%ebp
80108047:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010804a:	e8 59 f9 ff ff       	call   801079a8 <setupkvm>
8010804f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108052:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108056:	75 0a                	jne    80108062 <copyuvm+0x1e>
    return 0;
80108058:	b8 00 00 00 00       	mov    $0x0,%eax
8010805d:	e9 eb 00 00 00       	jmp    8010814d <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108062:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108069:	e9 b7 00 00 00       	jmp    80108125 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010806e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108071:	83 ec 04             	sub    $0x4,%esp
80108074:	6a 00                	push   $0x0
80108076:	50                   	push   %eax
80108077:	ff 75 08             	push   0x8(%ebp)
8010807a:	e8 03 f8 ff ff       	call   80107882 <walkpgdir>
8010807f:	83 c4 10             	add    $0x10,%esp
80108082:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108085:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108089:	75 0d                	jne    80108098 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
8010808b:	83 ec 0c             	sub    $0xc,%esp
8010808e:	68 3e ad 10 80       	push   $0x8010ad3e
80108093:	e8 11 85 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80108098:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010809b:	8b 00                	mov    (%eax),%eax
8010809d:	83 e0 01             	and    $0x1,%eax
801080a0:	85 c0                	test   %eax,%eax
801080a2:	75 0d                	jne    801080b1 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801080a4:	83 ec 0c             	sub    $0xc,%esp
801080a7:	68 58 ad 10 80       	push   $0x8010ad58
801080ac:	e8 f8 84 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801080b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080b4:	8b 00                	mov    (%eax),%eax
801080b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801080be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080c1:	8b 00                	mov    (%eax),%eax
801080c3:	25 ff 0f 00 00       	and    $0xfff,%eax
801080c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801080cb:	e8 d0 a6 ff ff       	call   801027a0 <kalloc>
801080d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801080d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801080d7:	74 5d                	je     80108136 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801080d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080dc:	05 00 00 00 80       	add    $0x80000000,%eax
801080e1:	83 ec 04             	sub    $0x4,%esp
801080e4:	68 00 10 00 00       	push   $0x1000
801080e9:	50                   	push   %eax
801080ea:	ff 75 e0             	push   -0x20(%ebp)
801080ed:	e8 4f ce ff ff       	call   80104f41 <memmove>
801080f2:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801080f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801080f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080fb:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108104:	83 ec 0c             	sub    $0xc,%esp
80108107:	52                   	push   %edx
80108108:	51                   	push   %ecx
80108109:	68 00 10 00 00       	push   $0x1000
8010810e:	50                   	push   %eax
8010810f:	ff 75 f0             	push   -0x10(%ebp)
80108112:	e8 01 f8 ff ff       	call   80107918 <mappages>
80108117:	83 c4 20             	add    $0x20,%esp
8010811a:	85 c0                	test   %eax,%eax
8010811c:	78 1b                	js     80108139 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
8010811e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108128:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010812b:	0f 82 3d ff ff ff    	jb     8010806e <copyuvm+0x2a>
      goto bad;
  }
  return d;
80108131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108134:	eb 17                	jmp    8010814d <copyuvm+0x109>
      goto bad;
80108136:	90                   	nop
80108137:	eb 01                	jmp    8010813a <copyuvm+0xf6>
      goto bad;
80108139:	90                   	nop

bad:
  freevm(d);
8010813a:	83 ec 0c             	sub    $0xc,%esp
8010813d:	ff 75 f0             	push   -0x10(%ebp)
80108140:	e8 25 fe ff ff       	call   80107f6a <freevm>
80108145:	83 c4 10             	add    $0x10,%esp
  return 0;
80108148:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010814d:	c9                   	leave  
8010814e:	c3                   	ret    

8010814f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010814f:	55                   	push   %ebp
80108150:	89 e5                	mov    %esp,%ebp
80108152:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108155:	83 ec 04             	sub    $0x4,%esp
80108158:	6a 00                	push   $0x0
8010815a:	ff 75 0c             	push   0xc(%ebp)
8010815d:	ff 75 08             	push   0x8(%ebp)
80108160:	e8 1d f7 ff ff       	call   80107882 <walkpgdir>
80108165:	83 c4 10             	add    $0x10,%esp
80108168:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010816b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816e:	8b 00                	mov    (%eax),%eax
80108170:	83 e0 01             	and    $0x1,%eax
80108173:	85 c0                	test   %eax,%eax
80108175:	75 07                	jne    8010817e <uva2ka+0x2f>
    return 0;
80108177:	b8 00 00 00 00       	mov    $0x0,%eax
8010817c:	eb 22                	jmp    801081a0 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
8010817e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108181:	8b 00                	mov    (%eax),%eax
80108183:	83 e0 04             	and    $0x4,%eax
80108186:	85 c0                	test   %eax,%eax
80108188:	75 07                	jne    80108191 <uva2ka+0x42>
    return 0;
8010818a:	b8 00 00 00 00       	mov    $0x0,%eax
8010818f:	eb 0f                	jmp    801081a0 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108194:	8b 00                	mov    (%eax),%eax
80108196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010819b:	05 00 00 00 80       	add    $0x80000000,%eax
}
801081a0:	c9                   	leave  
801081a1:	c3                   	ret    

801081a2 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801081a2:	55                   	push   %ebp
801081a3:	89 e5                	mov    %esp,%ebp
801081a5:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801081a8:	8b 45 10             	mov    0x10(%ebp),%eax
801081ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801081ae:	eb 7f                	jmp    8010822f <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801081b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801081b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801081bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081be:	83 ec 08             	sub    $0x8,%esp
801081c1:	50                   	push   %eax
801081c2:	ff 75 08             	push   0x8(%ebp)
801081c5:	e8 85 ff ff ff       	call   8010814f <uva2ka>
801081ca:	83 c4 10             	add    $0x10,%esp
801081cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801081d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801081d4:	75 07                	jne    801081dd <copyout+0x3b>
      return -1;
801081d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081db:	eb 61                	jmp    8010823e <copyout+0x9c>
    n = PGSIZE - (va - va0);
801081dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081e0:	2b 45 0c             	sub    0xc(%ebp),%eax
801081e3:	05 00 10 00 00       	add    $0x1000,%eax
801081e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801081eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ee:	3b 45 14             	cmp    0x14(%ebp),%eax
801081f1:	76 06                	jbe    801081f9 <copyout+0x57>
      n = len;
801081f3:	8b 45 14             	mov    0x14(%ebp),%eax
801081f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801081f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801081fc:	2b 45 ec             	sub    -0x14(%ebp),%eax
801081ff:	89 c2                	mov    %eax,%edx
80108201:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108204:	01 d0                	add    %edx,%eax
80108206:	83 ec 04             	sub    $0x4,%esp
80108209:	ff 75 f0             	push   -0x10(%ebp)
8010820c:	ff 75 f4             	push   -0xc(%ebp)
8010820f:	50                   	push   %eax
80108210:	e8 2c cd ff ff       	call   80104f41 <memmove>
80108215:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010821b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010821e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108221:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108224:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108227:	05 00 10 00 00       	add    $0x1000,%eax
8010822c:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010822f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108233:	0f 85 77 ff ff ff    	jne    801081b0 <copyout+0xe>
  }
  return 0;
80108239:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010823e:	c9                   	leave  
8010823f:	c3                   	ret    

80108240 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108240:	55                   	push   %ebp
80108241:	89 e5                	mov    %esp,%ebp
80108243:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108246:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
8010824d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108250:	8b 40 08             	mov    0x8(%eax),%eax
80108253:	05 00 00 00 80       	add    $0x80000000,%eax
80108258:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010825b:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108265:	8b 40 24             	mov    0x24(%eax),%eax
80108268:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
8010826d:	c7 05 90 79 19 80 00 	movl   $0x0,0x80197990
80108274:	00 00 00 

  while(i<madt->len){
80108277:	90                   	nop
80108278:	e9 bd 00 00 00       	jmp    8010833a <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
8010827d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108280:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108283:	01 d0                	add    %edx,%eax
80108285:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010828b:	0f b6 00             	movzbl (%eax),%eax
8010828e:	0f b6 c0             	movzbl %al,%eax
80108291:	83 f8 05             	cmp    $0x5,%eax
80108294:	0f 87 a0 00 00 00    	ja     8010833a <mpinit_uefi+0xfa>
8010829a:	8b 04 85 74 ad 10 80 	mov    -0x7fef528c(,%eax,4),%eax
801082a1:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801082a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801082a9:	a1 90 79 19 80       	mov    0x80197990,%eax
801082ae:	83 f8 03             	cmp    $0x3,%eax
801082b1:	7f 28                	jg     801082db <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801082b3:	8b 15 90 79 19 80    	mov    0x80197990,%edx
801082b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082bc:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801082c0:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801082c6:	81 c2 c0 76 19 80    	add    $0x801976c0,%edx
801082cc:	88 02                	mov    %al,(%edx)
          ncpu++;
801082ce:	a1 90 79 19 80       	mov    0x80197990,%eax
801082d3:	83 c0 01             	add    $0x1,%eax
801082d6:	a3 90 79 19 80       	mov    %eax,0x80197990
        }
        i += lapic_entry->record_len;
801082db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082de:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082e2:	0f b6 c0             	movzbl %al,%eax
801082e5:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082e8:	eb 50                	jmp    8010833a <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801082ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801082f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082f3:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801082f7:	a2 94 79 19 80       	mov    %al,0x80197994
        i += ioapic->record_len;
801082fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082ff:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108303:	0f b6 c0             	movzbl %al,%eax
80108306:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108309:	eb 2f                	jmp    8010833a <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010830b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010830e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108311:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108314:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108318:	0f b6 c0             	movzbl %al,%eax
8010831b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010831e:	eb 1a                	jmp    8010833a <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108320:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108323:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108326:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108329:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010832d:	0f b6 c0             	movzbl %al,%eax
80108330:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108333:	eb 05                	jmp    8010833a <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80108335:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108339:	90                   	nop
  while(i<madt->len){
8010833a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833d:	8b 40 04             	mov    0x4(%eax),%eax
80108340:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108343:	0f 82 34 ff ff ff    	jb     8010827d <mpinit_uefi+0x3d>
    }
  }

}
80108349:	90                   	nop
8010834a:	90                   	nop
8010834b:	c9                   	leave  
8010834c:	c3                   	ret    

8010834d <inb>:
{
8010834d:	55                   	push   %ebp
8010834e:	89 e5                	mov    %esp,%ebp
80108350:	83 ec 14             	sub    $0x14,%esp
80108353:	8b 45 08             	mov    0x8(%ebp),%eax
80108356:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010835a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010835e:	89 c2                	mov    %eax,%edx
80108360:	ec                   	in     (%dx),%al
80108361:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108364:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108368:	c9                   	leave  
80108369:	c3                   	ret    

8010836a <outb>:
{
8010836a:	55                   	push   %ebp
8010836b:	89 e5                	mov    %esp,%ebp
8010836d:	83 ec 08             	sub    $0x8,%esp
80108370:	8b 45 08             	mov    0x8(%ebp),%eax
80108373:	8b 55 0c             	mov    0xc(%ebp),%edx
80108376:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010837a:	89 d0                	mov    %edx,%eax
8010837c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010837f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108383:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108387:	ee                   	out    %al,(%dx)
}
80108388:	90                   	nop
80108389:	c9                   	leave  
8010838a:	c3                   	ret    

8010838b <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010838b:	55                   	push   %ebp
8010838c:	89 e5                	mov    %esp,%ebp
8010838e:	83 ec 28             	sub    $0x28,%esp
80108391:	8b 45 08             	mov    0x8(%ebp),%eax
80108394:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108397:	6a 00                	push   $0x0
80108399:	68 fa 03 00 00       	push   $0x3fa
8010839e:	e8 c7 ff ff ff       	call   8010836a <outb>
801083a3:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801083a6:	68 80 00 00 00       	push   $0x80
801083ab:	68 fb 03 00 00       	push   $0x3fb
801083b0:	e8 b5 ff ff ff       	call   8010836a <outb>
801083b5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801083b8:	6a 0c                	push   $0xc
801083ba:	68 f8 03 00 00       	push   $0x3f8
801083bf:	e8 a6 ff ff ff       	call   8010836a <outb>
801083c4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801083c7:	6a 00                	push   $0x0
801083c9:	68 f9 03 00 00       	push   $0x3f9
801083ce:	e8 97 ff ff ff       	call   8010836a <outb>
801083d3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801083d6:	6a 03                	push   $0x3
801083d8:	68 fb 03 00 00       	push   $0x3fb
801083dd:	e8 88 ff ff ff       	call   8010836a <outb>
801083e2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801083e5:	6a 00                	push   $0x0
801083e7:	68 fc 03 00 00       	push   $0x3fc
801083ec:	e8 79 ff ff ff       	call   8010836a <outb>
801083f1:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801083f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083fb:	eb 11                	jmp    8010840e <uart_debug+0x83>
801083fd:	83 ec 0c             	sub    $0xc,%esp
80108400:	6a 0a                	push   $0xa
80108402:	e8 30 a7 ff ff       	call   80102b37 <microdelay>
80108407:	83 c4 10             	add    $0x10,%esp
8010840a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010840e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108412:	7f 1a                	jg     8010842e <uart_debug+0xa3>
80108414:	83 ec 0c             	sub    $0xc,%esp
80108417:	68 fd 03 00 00       	push   $0x3fd
8010841c:	e8 2c ff ff ff       	call   8010834d <inb>
80108421:	83 c4 10             	add    $0x10,%esp
80108424:	0f b6 c0             	movzbl %al,%eax
80108427:	83 e0 20             	and    $0x20,%eax
8010842a:	85 c0                	test   %eax,%eax
8010842c:	74 cf                	je     801083fd <uart_debug+0x72>
  outb(COM1+0, p);
8010842e:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108432:	0f b6 c0             	movzbl %al,%eax
80108435:	83 ec 08             	sub    $0x8,%esp
80108438:	50                   	push   %eax
80108439:	68 f8 03 00 00       	push   $0x3f8
8010843e:	e8 27 ff ff ff       	call   8010836a <outb>
80108443:	83 c4 10             	add    $0x10,%esp
}
80108446:	90                   	nop
80108447:	c9                   	leave  
80108448:	c3                   	ret    

80108449 <uart_debugs>:

void uart_debugs(char *p){
80108449:	55                   	push   %ebp
8010844a:	89 e5                	mov    %esp,%ebp
8010844c:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010844f:	eb 1b                	jmp    8010846c <uart_debugs+0x23>
    uart_debug(*p++);
80108451:	8b 45 08             	mov    0x8(%ebp),%eax
80108454:	8d 50 01             	lea    0x1(%eax),%edx
80108457:	89 55 08             	mov    %edx,0x8(%ebp)
8010845a:	0f b6 00             	movzbl (%eax),%eax
8010845d:	0f be c0             	movsbl %al,%eax
80108460:	83 ec 0c             	sub    $0xc,%esp
80108463:	50                   	push   %eax
80108464:	e8 22 ff ff ff       	call   8010838b <uart_debug>
80108469:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010846c:	8b 45 08             	mov    0x8(%ebp),%eax
8010846f:	0f b6 00             	movzbl (%eax),%eax
80108472:	84 c0                	test   %al,%al
80108474:	75 db                	jne    80108451 <uart_debugs+0x8>
  }
}
80108476:	90                   	nop
80108477:	90                   	nop
80108478:	c9                   	leave  
80108479:	c3                   	ret    

8010847a <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010847a:	55                   	push   %ebp
8010847b:	89 e5                	mov    %esp,%ebp
8010847d:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108480:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108487:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010848a:	8b 50 14             	mov    0x14(%eax),%edx
8010848d:	8b 40 10             	mov    0x10(%eax),%eax
80108490:	a3 98 79 19 80       	mov    %eax,0x80197998
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108495:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108498:	8b 50 1c             	mov    0x1c(%eax),%edx
8010849b:	8b 40 18             	mov    0x18(%eax),%eax
8010849e:	a3 a0 79 19 80       	mov    %eax,0x801979a0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801084a3:	8b 15 a0 79 19 80    	mov    0x801979a0,%edx
801084a9:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801084ae:	29 d0                	sub    %edx,%eax
801084b0:	a3 9c 79 19 80       	mov    %eax,0x8019799c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801084b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084b8:	8b 50 24             	mov    0x24(%eax),%edx
801084bb:	8b 40 20             	mov    0x20(%eax),%eax
801084be:	a3 a4 79 19 80       	mov    %eax,0x801979a4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801084c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084c6:	8b 50 2c             	mov    0x2c(%eax),%edx
801084c9:	8b 40 28             	mov    0x28(%eax),%eax
801084cc:	a3 a8 79 19 80       	mov    %eax,0x801979a8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801084d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084d4:	8b 50 34             	mov    0x34(%eax),%edx
801084d7:	8b 40 30             	mov    0x30(%eax),%eax
801084da:	a3 ac 79 19 80       	mov    %eax,0x801979ac
}
801084df:	90                   	nop
801084e0:	c9                   	leave  
801084e1:	c3                   	ret    

801084e2 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801084e2:	55                   	push   %ebp
801084e3:	89 e5                	mov    %esp,%ebp
801084e5:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801084e8:	8b 15 ac 79 19 80    	mov    0x801979ac,%edx
801084ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801084f1:	0f af d0             	imul   %eax,%edx
801084f4:	8b 45 08             	mov    0x8(%ebp),%eax
801084f7:	01 d0                	add    %edx,%eax
801084f9:	c1 e0 02             	shl    $0x2,%eax
801084fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801084ff:	8b 15 9c 79 19 80    	mov    0x8019799c,%edx
80108505:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108508:	01 d0                	add    %edx,%eax
8010850a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
8010850d:	8b 45 10             	mov    0x10(%ebp),%eax
80108510:	0f b6 10             	movzbl (%eax),%edx
80108513:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108516:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108518:	8b 45 10             	mov    0x10(%ebp),%eax
8010851b:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010851f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108522:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108525:	8b 45 10             	mov    0x10(%ebp),%eax
80108528:	0f b6 50 02          	movzbl 0x2(%eax),%edx
8010852c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010852f:	88 50 02             	mov    %dl,0x2(%eax)
}
80108532:	90                   	nop
80108533:	c9                   	leave  
80108534:	c3                   	ret    

80108535 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108535:	55                   	push   %ebp
80108536:	89 e5                	mov    %esp,%ebp
80108538:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
8010853b:	8b 15 ac 79 19 80    	mov    0x801979ac,%edx
80108541:	8b 45 08             	mov    0x8(%ebp),%eax
80108544:	0f af c2             	imul   %edx,%eax
80108547:	c1 e0 02             	shl    $0x2,%eax
8010854a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
8010854d:	a1 a0 79 19 80       	mov    0x801979a0,%eax
80108552:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108555:	29 d0                	sub    %edx,%eax
80108557:	8b 0d 9c 79 19 80    	mov    0x8019799c,%ecx
8010855d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108560:	01 ca                	add    %ecx,%edx
80108562:	89 d1                	mov    %edx,%ecx
80108564:	8b 15 9c 79 19 80    	mov    0x8019799c,%edx
8010856a:	83 ec 04             	sub    $0x4,%esp
8010856d:	50                   	push   %eax
8010856e:	51                   	push   %ecx
8010856f:	52                   	push   %edx
80108570:	e8 cc c9 ff ff       	call   80104f41 <memmove>
80108575:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857b:	8b 0d 9c 79 19 80    	mov    0x8019799c,%ecx
80108581:	8b 15 a0 79 19 80    	mov    0x801979a0,%edx
80108587:	01 ca                	add    %ecx,%edx
80108589:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010858c:	29 ca                	sub    %ecx,%edx
8010858e:	83 ec 04             	sub    $0x4,%esp
80108591:	50                   	push   %eax
80108592:	6a 00                	push   $0x0
80108594:	52                   	push   %edx
80108595:	e8 e8 c8 ff ff       	call   80104e82 <memset>
8010859a:	83 c4 10             	add    $0x10,%esp
}
8010859d:	90                   	nop
8010859e:	c9                   	leave  
8010859f:	c3                   	ret    

801085a0 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801085a0:	55                   	push   %ebp
801085a1:	89 e5                	mov    %esp,%ebp
801085a3:	53                   	push   %ebx
801085a4:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801085a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085ae:	e9 b1 00 00 00       	jmp    80108664 <font_render+0xc4>
    for(int j=14;j>-1;j--){
801085b3:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801085ba:	e9 97 00 00 00       	jmp    80108656 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801085bf:	8b 45 10             	mov    0x10(%ebp),%eax
801085c2:	83 e8 20             	sub    $0x20,%eax
801085c5:	6b d0 1e             	imul   $0x1e,%eax,%edx
801085c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085cb:	01 d0                	add    %edx,%eax
801085cd:	0f b7 84 00 a0 ad 10 	movzwl -0x7fef5260(%eax,%eax,1),%eax
801085d4:	80 
801085d5:	0f b7 d0             	movzwl %ax,%edx
801085d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085db:	bb 01 00 00 00       	mov    $0x1,%ebx
801085e0:	89 c1                	mov    %eax,%ecx
801085e2:	d3 e3                	shl    %cl,%ebx
801085e4:	89 d8                	mov    %ebx,%eax
801085e6:	21 d0                	and    %edx,%eax
801085e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801085eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ee:	ba 01 00 00 00       	mov    $0x1,%edx
801085f3:	89 c1                	mov    %eax,%ecx
801085f5:	d3 e2                	shl    %cl,%edx
801085f7:	89 d0                	mov    %edx,%eax
801085f9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801085fc:	75 2b                	jne    80108629 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801085fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80108601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108604:	01 c2                	add    %eax,%edx
80108606:	b8 0e 00 00 00       	mov    $0xe,%eax
8010860b:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010860e:	89 c1                	mov    %eax,%ecx
80108610:	8b 45 08             	mov    0x8(%ebp),%eax
80108613:	01 c8                	add    %ecx,%eax
80108615:	83 ec 04             	sub    $0x4,%esp
80108618:	68 00 f5 10 80       	push   $0x8010f500
8010861d:	52                   	push   %edx
8010861e:	50                   	push   %eax
8010861f:	e8 be fe ff ff       	call   801084e2 <graphic_draw_pixel>
80108624:	83 c4 10             	add    $0x10,%esp
80108627:	eb 29                	jmp    80108652 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108629:	8b 55 0c             	mov    0xc(%ebp),%edx
8010862c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862f:	01 c2                	add    %eax,%edx
80108631:	b8 0e 00 00 00       	mov    $0xe,%eax
80108636:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108639:	89 c1                	mov    %eax,%ecx
8010863b:	8b 45 08             	mov    0x8(%ebp),%eax
8010863e:	01 c8                	add    %ecx,%eax
80108640:	83 ec 04             	sub    $0x4,%esp
80108643:	68 b0 79 19 80       	push   $0x801979b0
80108648:	52                   	push   %edx
80108649:	50                   	push   %eax
8010864a:	e8 93 fe ff ff       	call   801084e2 <graphic_draw_pixel>
8010864f:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108652:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108656:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010865a:	0f 89 5f ff ff ff    	jns    801085bf <font_render+0x1f>
  for(int i=0;i<30;i++){
80108660:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108664:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108668:	0f 8e 45 ff ff ff    	jle    801085b3 <font_render+0x13>
      }
    }
  }
}
8010866e:	90                   	nop
8010866f:	90                   	nop
80108670:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108673:	c9                   	leave  
80108674:	c3                   	ret    

80108675 <font_render_string>:

void font_render_string(char *string,int row){
80108675:	55                   	push   %ebp
80108676:	89 e5                	mov    %esp,%ebp
80108678:	53                   	push   %ebx
80108679:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010867c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108683:	eb 33                	jmp    801086b8 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108685:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108688:	8b 45 08             	mov    0x8(%ebp),%eax
8010868b:	01 d0                	add    %edx,%eax
8010868d:	0f b6 00             	movzbl (%eax),%eax
80108690:	0f be c8             	movsbl %al,%ecx
80108693:	8b 45 0c             	mov    0xc(%ebp),%eax
80108696:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108699:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010869c:	89 d8                	mov    %ebx,%eax
8010869e:	c1 e0 04             	shl    $0x4,%eax
801086a1:	29 d8                	sub    %ebx,%eax
801086a3:	83 c0 02             	add    $0x2,%eax
801086a6:	83 ec 04             	sub    $0x4,%esp
801086a9:	51                   	push   %ecx
801086aa:	52                   	push   %edx
801086ab:	50                   	push   %eax
801086ac:	e8 ef fe ff ff       	call   801085a0 <font_render>
801086b1:	83 c4 10             	add    $0x10,%esp
    i++;
801086b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801086b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086bb:	8b 45 08             	mov    0x8(%ebp),%eax
801086be:	01 d0                	add    %edx,%eax
801086c0:	0f b6 00             	movzbl (%eax),%eax
801086c3:	84 c0                	test   %al,%al
801086c5:	74 06                	je     801086cd <font_render_string+0x58>
801086c7:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801086cb:	7e b8                	jle    80108685 <font_render_string+0x10>
  }
}
801086cd:	90                   	nop
801086ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086d1:	c9                   	leave  
801086d2:	c3                   	ret    

801086d3 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801086d3:	55                   	push   %ebp
801086d4:	89 e5                	mov    %esp,%ebp
801086d6:	53                   	push   %ebx
801086d7:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801086da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086e1:	eb 6b                	jmp    8010874e <pci_init+0x7b>
    for(int j=0;j<32;j++){
801086e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801086ea:	eb 58                	jmp    80108744 <pci_init+0x71>
      for(int k=0;k<8;k++){
801086ec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801086f3:	eb 45                	jmp    8010873a <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801086f5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801086f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fe:	83 ec 0c             	sub    $0xc,%esp
80108701:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108704:	53                   	push   %ebx
80108705:	6a 00                	push   $0x0
80108707:	51                   	push   %ecx
80108708:	52                   	push   %edx
80108709:	50                   	push   %eax
8010870a:	e8 b0 00 00 00       	call   801087bf <pci_access_config>
8010870f:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108712:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108715:	0f b7 c0             	movzwl %ax,%eax
80108718:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010871d:	74 17                	je     80108736 <pci_init+0x63>
        pci_init_device(i,j,k);
8010871f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108722:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108728:	83 ec 04             	sub    $0x4,%esp
8010872b:	51                   	push   %ecx
8010872c:	52                   	push   %edx
8010872d:	50                   	push   %eax
8010872e:	e8 37 01 00 00       	call   8010886a <pci_init_device>
80108733:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108736:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010873a:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010873e:	7e b5                	jle    801086f5 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108740:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108744:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108748:	7e a2                	jle    801086ec <pci_init+0x19>
  for(int i=0;i<256;i++){
8010874a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010874e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108755:	7e 8c                	jle    801086e3 <pci_init+0x10>
      }
      }
    }
  }
}
80108757:	90                   	nop
80108758:	90                   	nop
80108759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010875c:	c9                   	leave  
8010875d:	c3                   	ret    

8010875e <pci_write_config>:

void pci_write_config(uint config){
8010875e:	55                   	push   %ebp
8010875f:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108761:	8b 45 08             	mov    0x8(%ebp),%eax
80108764:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108769:	89 c0                	mov    %eax,%eax
8010876b:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010876c:	90                   	nop
8010876d:	5d                   	pop    %ebp
8010876e:	c3                   	ret    

8010876f <pci_write_data>:

void pci_write_data(uint config){
8010876f:	55                   	push   %ebp
80108770:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108772:	8b 45 08             	mov    0x8(%ebp),%eax
80108775:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010877a:	89 c0                	mov    %eax,%eax
8010877c:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010877d:	90                   	nop
8010877e:	5d                   	pop    %ebp
8010877f:	c3                   	ret    

80108780 <pci_read_config>:
uint pci_read_config(){
80108780:	55                   	push   %ebp
80108781:	89 e5                	mov    %esp,%ebp
80108783:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108786:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010878b:	ed                   	in     (%dx),%eax
8010878c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
8010878f:	83 ec 0c             	sub    $0xc,%esp
80108792:	68 c8 00 00 00       	push   $0xc8
80108797:	e8 9b a3 ff ff       	call   80102b37 <microdelay>
8010879c:	83 c4 10             	add    $0x10,%esp
  return data;
8010879f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801087a2:	c9                   	leave  
801087a3:	c3                   	ret    

801087a4 <pci_test>:


void pci_test(){
801087a4:	55                   	push   %ebp
801087a5:	89 e5                	mov    %esp,%ebp
801087a7:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801087aa:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801087b1:	ff 75 fc             	push   -0x4(%ebp)
801087b4:	e8 a5 ff ff ff       	call   8010875e <pci_write_config>
801087b9:	83 c4 04             	add    $0x4,%esp
}
801087bc:	90                   	nop
801087bd:	c9                   	leave  
801087be:	c3                   	ret    

801087bf <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801087bf:	55                   	push   %ebp
801087c0:	89 e5                	mov    %esp,%ebp
801087c2:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087c5:	8b 45 08             	mov    0x8(%ebp),%eax
801087c8:	c1 e0 10             	shl    $0x10,%eax
801087cb:	25 00 00 ff 00       	and    $0xff0000,%eax
801087d0:	89 c2                	mov    %eax,%edx
801087d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801087d5:	c1 e0 0b             	shl    $0xb,%eax
801087d8:	0f b7 c0             	movzwl %ax,%eax
801087db:	09 c2                	or     %eax,%edx
801087dd:	8b 45 10             	mov    0x10(%ebp),%eax
801087e0:	c1 e0 08             	shl    $0x8,%eax
801087e3:	25 00 07 00 00       	and    $0x700,%eax
801087e8:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801087ea:	8b 45 14             	mov    0x14(%ebp),%eax
801087ed:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087f2:	09 d0                	or     %edx,%eax
801087f4:	0d 00 00 00 80       	or     $0x80000000,%eax
801087f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801087fc:	ff 75 f4             	push   -0xc(%ebp)
801087ff:	e8 5a ff ff ff       	call   8010875e <pci_write_config>
80108804:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108807:	e8 74 ff ff ff       	call   80108780 <pci_read_config>
8010880c:	8b 55 18             	mov    0x18(%ebp),%edx
8010880f:	89 02                	mov    %eax,(%edx)
}
80108811:	90                   	nop
80108812:	c9                   	leave  
80108813:	c3                   	ret    

80108814 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108814:	55                   	push   %ebp
80108815:	89 e5                	mov    %esp,%ebp
80108817:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010881a:	8b 45 08             	mov    0x8(%ebp),%eax
8010881d:	c1 e0 10             	shl    $0x10,%eax
80108820:	25 00 00 ff 00       	and    $0xff0000,%eax
80108825:	89 c2                	mov    %eax,%edx
80108827:	8b 45 0c             	mov    0xc(%ebp),%eax
8010882a:	c1 e0 0b             	shl    $0xb,%eax
8010882d:	0f b7 c0             	movzwl %ax,%eax
80108830:	09 c2                	or     %eax,%edx
80108832:	8b 45 10             	mov    0x10(%ebp),%eax
80108835:	c1 e0 08             	shl    $0x8,%eax
80108838:	25 00 07 00 00       	and    $0x700,%eax
8010883d:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010883f:	8b 45 14             	mov    0x14(%ebp),%eax
80108842:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108847:	09 d0                	or     %edx,%eax
80108849:	0d 00 00 00 80       	or     $0x80000000,%eax
8010884e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108851:	ff 75 fc             	push   -0x4(%ebp)
80108854:	e8 05 ff ff ff       	call   8010875e <pci_write_config>
80108859:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010885c:	ff 75 18             	push   0x18(%ebp)
8010885f:	e8 0b ff ff ff       	call   8010876f <pci_write_data>
80108864:	83 c4 04             	add    $0x4,%esp
}
80108867:	90                   	nop
80108868:	c9                   	leave  
80108869:	c3                   	ret    

8010886a <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010886a:	55                   	push   %ebp
8010886b:	89 e5                	mov    %esp,%ebp
8010886d:	53                   	push   %ebx
8010886e:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108871:	8b 45 08             	mov    0x8(%ebp),%eax
80108874:	a2 b4 79 19 80       	mov    %al,0x801979b4
  dev.device_num = device_num;
80108879:	8b 45 0c             	mov    0xc(%ebp),%eax
8010887c:	a2 b5 79 19 80       	mov    %al,0x801979b5
  dev.function_num = function_num;
80108881:	8b 45 10             	mov    0x10(%ebp),%eax
80108884:	a2 b6 79 19 80       	mov    %al,0x801979b6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108889:	ff 75 10             	push   0x10(%ebp)
8010888c:	ff 75 0c             	push   0xc(%ebp)
8010888f:	ff 75 08             	push   0x8(%ebp)
80108892:	68 e4 c3 10 80       	push   $0x8010c3e4
80108897:	e8 58 7b ff ff       	call   801003f4 <cprintf>
8010889c:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
8010889f:	83 ec 0c             	sub    $0xc,%esp
801088a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088a5:	50                   	push   %eax
801088a6:	6a 00                	push   $0x0
801088a8:	ff 75 10             	push   0x10(%ebp)
801088ab:	ff 75 0c             	push   0xc(%ebp)
801088ae:	ff 75 08             	push   0x8(%ebp)
801088b1:	e8 09 ff ff ff       	call   801087bf <pci_access_config>
801088b6:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801088b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088bc:	c1 e8 10             	shr    $0x10,%eax
801088bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801088c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c5:	25 ff ff 00 00       	and    $0xffff,%eax
801088ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801088cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d0:	a3 b8 79 19 80       	mov    %eax,0x801979b8
  dev.vendor_id = vendor_id;
801088d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d8:	a3 bc 79 19 80       	mov    %eax,0x801979bc
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801088dd:	83 ec 04             	sub    $0x4,%esp
801088e0:	ff 75 f0             	push   -0x10(%ebp)
801088e3:	ff 75 f4             	push   -0xc(%ebp)
801088e6:	68 18 c4 10 80       	push   $0x8010c418
801088eb:	e8 04 7b ff ff       	call   801003f4 <cprintf>
801088f0:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801088f3:	83 ec 0c             	sub    $0xc,%esp
801088f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088f9:	50                   	push   %eax
801088fa:	6a 08                	push   $0x8
801088fc:	ff 75 10             	push   0x10(%ebp)
801088ff:	ff 75 0c             	push   0xc(%ebp)
80108902:	ff 75 08             	push   0x8(%ebp)
80108905:	e8 b5 fe ff ff       	call   801087bf <pci_access_config>
8010890a:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010890d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108910:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108913:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108916:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108919:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010891c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010891f:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108922:	0f b6 c0             	movzbl %al,%eax
80108925:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108928:	c1 eb 18             	shr    $0x18,%ebx
8010892b:	83 ec 0c             	sub    $0xc,%esp
8010892e:	51                   	push   %ecx
8010892f:	52                   	push   %edx
80108930:	50                   	push   %eax
80108931:	53                   	push   %ebx
80108932:	68 3c c4 10 80       	push   $0x8010c43c
80108937:	e8 b8 7a ff ff       	call   801003f4 <cprintf>
8010893c:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010893f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108942:	c1 e8 18             	shr    $0x18,%eax
80108945:	a2 c0 79 19 80       	mov    %al,0x801979c0
  dev.sub_class = (data>>16)&0xFF;
8010894a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010894d:	c1 e8 10             	shr    $0x10,%eax
80108950:	a2 c1 79 19 80       	mov    %al,0x801979c1
  dev.interface = (data>>8)&0xFF;
80108955:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108958:	c1 e8 08             	shr    $0x8,%eax
8010895b:	a2 c2 79 19 80       	mov    %al,0x801979c2
  dev.revision_id = data&0xFF;
80108960:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108963:	a2 c3 79 19 80       	mov    %al,0x801979c3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108968:	83 ec 0c             	sub    $0xc,%esp
8010896b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010896e:	50                   	push   %eax
8010896f:	6a 10                	push   $0x10
80108971:	ff 75 10             	push   0x10(%ebp)
80108974:	ff 75 0c             	push   0xc(%ebp)
80108977:	ff 75 08             	push   0x8(%ebp)
8010897a:	e8 40 fe ff ff       	call   801087bf <pci_access_config>
8010897f:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108982:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108985:	a3 c4 79 19 80       	mov    %eax,0x801979c4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010898a:	83 ec 0c             	sub    $0xc,%esp
8010898d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108990:	50                   	push   %eax
80108991:	6a 14                	push   $0x14
80108993:	ff 75 10             	push   0x10(%ebp)
80108996:	ff 75 0c             	push   0xc(%ebp)
80108999:	ff 75 08             	push   0x8(%ebp)
8010899c:	e8 1e fe ff ff       	call   801087bf <pci_access_config>
801089a1:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801089a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089a7:	a3 c8 79 19 80       	mov    %eax,0x801979c8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801089ac:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801089b3:	75 5a                	jne    80108a0f <pci_init_device+0x1a5>
801089b5:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801089bc:	75 51                	jne    80108a0f <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801089be:	83 ec 0c             	sub    $0xc,%esp
801089c1:	68 81 c4 10 80       	push   $0x8010c481
801089c6:	e8 29 7a ff ff       	call   801003f4 <cprintf>
801089cb:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801089ce:	83 ec 0c             	sub    $0xc,%esp
801089d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089d4:	50                   	push   %eax
801089d5:	68 f0 00 00 00       	push   $0xf0
801089da:	ff 75 10             	push   0x10(%ebp)
801089dd:	ff 75 0c             	push   0xc(%ebp)
801089e0:	ff 75 08             	push   0x8(%ebp)
801089e3:	e8 d7 fd ff ff       	call   801087bf <pci_access_config>
801089e8:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801089eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ee:	83 ec 08             	sub    $0x8,%esp
801089f1:	50                   	push   %eax
801089f2:	68 9b c4 10 80       	push   $0x8010c49b
801089f7:	e8 f8 79 ff ff       	call   801003f4 <cprintf>
801089fc:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801089ff:	83 ec 0c             	sub    $0xc,%esp
80108a02:	68 b4 79 19 80       	push   $0x801979b4
80108a07:	e8 09 00 00 00       	call   80108a15 <i8254_init>
80108a0c:	83 c4 10             	add    $0x10,%esp
  }
}
80108a0f:	90                   	nop
80108a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a13:	c9                   	leave  
80108a14:	c3                   	ret    

80108a15 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108a15:	55                   	push   %ebp
80108a16:	89 e5                	mov    %esp,%ebp
80108a18:	53                   	push   %ebx
80108a19:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80108a1f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a23:	0f b6 c8             	movzbl %al,%ecx
80108a26:	8b 45 08             	mov    0x8(%ebp),%eax
80108a29:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a2d:	0f b6 d0             	movzbl %al,%edx
80108a30:	8b 45 08             	mov    0x8(%ebp),%eax
80108a33:	0f b6 00             	movzbl (%eax),%eax
80108a36:	0f b6 c0             	movzbl %al,%eax
80108a39:	83 ec 0c             	sub    $0xc,%esp
80108a3c:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108a3f:	53                   	push   %ebx
80108a40:	6a 04                	push   $0x4
80108a42:	51                   	push   %ecx
80108a43:	52                   	push   %edx
80108a44:	50                   	push   %eax
80108a45:	e8 75 fd ff ff       	call   801087bf <pci_access_config>
80108a4a:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a50:	83 c8 04             	or     $0x4,%eax
80108a53:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108a56:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108a59:	8b 45 08             	mov    0x8(%ebp),%eax
80108a5c:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a60:	0f b6 c8             	movzbl %al,%ecx
80108a63:	8b 45 08             	mov    0x8(%ebp),%eax
80108a66:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a6a:	0f b6 d0             	movzbl %al,%edx
80108a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80108a70:	0f b6 00             	movzbl (%eax),%eax
80108a73:	0f b6 c0             	movzbl %al,%eax
80108a76:	83 ec 0c             	sub    $0xc,%esp
80108a79:	53                   	push   %ebx
80108a7a:	6a 04                	push   $0x4
80108a7c:	51                   	push   %ecx
80108a7d:	52                   	push   %edx
80108a7e:	50                   	push   %eax
80108a7f:	e8 90 fd ff ff       	call   80108814 <pci_write_config_register>
80108a84:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108a87:	8b 45 08             	mov    0x8(%ebp),%eax
80108a8a:	8b 40 10             	mov    0x10(%eax),%eax
80108a8d:	05 00 00 00 40       	add    $0x40000000,%eax
80108a92:	a3 cc 79 19 80       	mov    %eax,0x801979cc
  uint *ctrl = (uint *)base_addr;
80108a97:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108a9f:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108aa4:	05 d8 00 00 00       	add    $0xd8,%eax
80108aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aaf:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab8:	8b 00                	mov    (%eax),%eax
80108aba:	0d 00 00 00 04       	or     $0x4000000,%eax
80108abf:	89 c2                	mov    %eax,%edx
80108ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac4:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ac9:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad2:	8b 00                	mov    (%eax),%eax
80108ad4:	83 c8 40             	or     $0x40,%eax
80108ad7:	89 c2                	mov    %eax,%edx
80108ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108adc:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae1:	8b 10                	mov    (%eax),%edx
80108ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae6:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108ae8:	83 ec 0c             	sub    $0xc,%esp
80108aeb:	68 b0 c4 10 80       	push   $0x8010c4b0
80108af0:	e8 ff 78 ff ff       	call   801003f4 <cprintf>
80108af5:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108af8:	e8 a3 9c ff ff       	call   801027a0 <kalloc>
80108afd:	a3 d8 79 19 80       	mov    %eax,0x801979d8
  *intr_addr = 0;
80108b02:	a1 d8 79 19 80       	mov    0x801979d8,%eax
80108b07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108b0d:	a1 d8 79 19 80       	mov    0x801979d8,%eax
80108b12:	83 ec 08             	sub    $0x8,%esp
80108b15:	50                   	push   %eax
80108b16:	68 d2 c4 10 80       	push   $0x8010c4d2
80108b1b:	e8 d4 78 ff ff       	call   801003f4 <cprintf>
80108b20:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108b23:	e8 50 00 00 00       	call   80108b78 <i8254_init_recv>
  i8254_init_send();
80108b28:	e8 69 03 00 00       	call   80108e96 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108b2d:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b34:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108b37:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b3e:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108b41:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b48:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108b4b:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b52:	0f b6 c0             	movzbl %al,%eax
80108b55:	83 ec 0c             	sub    $0xc,%esp
80108b58:	53                   	push   %ebx
80108b59:	51                   	push   %ecx
80108b5a:	52                   	push   %edx
80108b5b:	50                   	push   %eax
80108b5c:	68 e0 c4 10 80       	push   $0x8010c4e0
80108b61:	e8 8e 78 ff ff       	call   801003f4 <cprintf>
80108b66:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108b72:	90                   	nop
80108b73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b76:	c9                   	leave  
80108b77:	c3                   	ret    

80108b78 <i8254_init_recv>:

void i8254_init_recv(){
80108b78:	55                   	push   %ebp
80108b79:	89 e5                	mov    %esp,%ebp
80108b7b:	57                   	push   %edi
80108b7c:	56                   	push   %esi
80108b7d:	53                   	push   %ebx
80108b7e:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108b81:	83 ec 0c             	sub    $0xc,%esp
80108b84:	6a 00                	push   $0x0
80108b86:	e8 e8 04 00 00       	call   80109073 <i8254_read_eeprom>
80108b8b:	83 c4 10             	add    $0x10,%esp
80108b8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108b91:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b94:	a2 d0 79 19 80       	mov    %al,0x801979d0
  mac_addr[1] = data_l>>8;
80108b99:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b9c:	c1 e8 08             	shr    $0x8,%eax
80108b9f:	a2 d1 79 19 80       	mov    %al,0x801979d1
  uint data_m = i8254_read_eeprom(0x1);
80108ba4:	83 ec 0c             	sub    $0xc,%esp
80108ba7:	6a 01                	push   $0x1
80108ba9:	e8 c5 04 00 00       	call   80109073 <i8254_read_eeprom>
80108bae:	83 c4 10             	add    $0x10,%esp
80108bb1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108bb4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bb7:	a2 d2 79 19 80       	mov    %al,0x801979d2
  mac_addr[3] = data_m>>8;
80108bbc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bbf:	c1 e8 08             	shr    $0x8,%eax
80108bc2:	a2 d3 79 19 80       	mov    %al,0x801979d3
  uint data_h = i8254_read_eeprom(0x2);
80108bc7:	83 ec 0c             	sub    $0xc,%esp
80108bca:	6a 02                	push   $0x2
80108bcc:	e8 a2 04 00 00       	call   80109073 <i8254_read_eeprom>
80108bd1:	83 c4 10             	add    $0x10,%esp
80108bd4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108bd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bda:	a2 d4 79 19 80       	mov    %al,0x801979d4
  mac_addr[5] = data_h>>8;
80108bdf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108be2:	c1 e8 08             	shr    $0x8,%eax
80108be5:	a2 d5 79 19 80       	mov    %al,0x801979d5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108bea:	0f b6 05 d5 79 19 80 	movzbl 0x801979d5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bf1:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108bf4:	0f b6 05 d4 79 19 80 	movzbl 0x801979d4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bfb:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108bfe:	0f b6 05 d3 79 19 80 	movzbl 0x801979d3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c05:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108c08:	0f b6 05 d2 79 19 80 	movzbl 0x801979d2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c0f:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108c12:	0f b6 05 d1 79 19 80 	movzbl 0x801979d1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c19:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108c1c:	0f b6 05 d0 79 19 80 	movzbl 0x801979d0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c23:	0f b6 c0             	movzbl %al,%eax
80108c26:	83 ec 04             	sub    $0x4,%esp
80108c29:	57                   	push   %edi
80108c2a:	56                   	push   %esi
80108c2b:	53                   	push   %ebx
80108c2c:	51                   	push   %ecx
80108c2d:	52                   	push   %edx
80108c2e:	50                   	push   %eax
80108c2f:	68 f8 c4 10 80       	push   $0x8010c4f8
80108c34:	e8 bb 77 ff ff       	call   801003f4 <cprintf>
80108c39:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108c3c:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108c41:	05 00 54 00 00       	add    $0x5400,%eax
80108c46:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108c49:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108c4e:	05 04 54 00 00       	add    $0x5404,%eax
80108c53:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108c56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c59:	c1 e0 10             	shl    $0x10,%eax
80108c5c:	0b 45 d8             	or     -0x28(%ebp),%eax
80108c5f:	89 c2                	mov    %eax,%edx
80108c61:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108c64:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108c66:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c69:	0d 00 00 00 80       	or     $0x80000000,%eax
80108c6e:	89 c2                	mov    %eax,%edx
80108c70:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c73:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108c75:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108c7a:	05 00 52 00 00       	add    $0x5200,%eax
80108c7f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108c82:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108c89:	eb 19                	jmp    80108ca4 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108c8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c95:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108c98:	01 d0                	add    %edx,%eax
80108c9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108ca0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108ca4:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108ca8:	7e e1                	jle    80108c8b <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108caa:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108caf:	05 d0 00 00 00       	add    $0xd0,%eax
80108cb4:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108cb7:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108cba:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108cc0:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108cc5:	05 c8 00 00 00       	add    $0xc8,%eax
80108cca:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ccd:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108cd0:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108cd6:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108cdb:	05 28 28 00 00       	add    $0x2828,%eax
80108ce0:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108ce3:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108ce6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108cec:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108cf1:	05 00 01 00 00       	add    $0x100,%eax
80108cf6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108cf9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108cfc:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108d02:	e8 99 9a ff ff       	call   801027a0 <kalloc>
80108d07:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108d0a:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d0f:	05 00 28 00 00       	add    $0x2800,%eax
80108d14:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108d17:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d1c:	05 04 28 00 00       	add    $0x2804,%eax
80108d21:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108d24:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d29:	05 08 28 00 00       	add    $0x2808,%eax
80108d2e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108d31:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d36:	05 10 28 00 00       	add    $0x2810,%eax
80108d3b:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d3e:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d43:	05 18 28 00 00       	add    $0x2818,%eax
80108d48:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108d4b:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d4e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d54:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108d57:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108d59:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108d5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108d62:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108d65:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108d6b:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108d6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108d74:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108d77:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108d7d:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d80:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108d83:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108d8a:	eb 73                	jmp    80108dff <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d8f:	c1 e0 04             	shl    $0x4,%eax
80108d92:	89 c2                	mov    %eax,%edx
80108d94:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d97:	01 d0                	add    %edx,%eax
80108d99:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108da0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108da3:	c1 e0 04             	shl    $0x4,%eax
80108da6:	89 c2                	mov    %eax,%edx
80108da8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dab:	01 d0                	add    %edx,%eax
80108dad:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108db6:	c1 e0 04             	shl    $0x4,%eax
80108db9:	89 c2                	mov    %eax,%edx
80108dbb:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dbe:	01 d0                	add    %edx,%eax
80108dc0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dc9:	c1 e0 04             	shl    $0x4,%eax
80108dcc:	89 c2                	mov    %eax,%edx
80108dce:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dd1:	01 d0                	add    %edx,%eax
80108dd3:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108dd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dda:	c1 e0 04             	shl    $0x4,%eax
80108ddd:	89 c2                	mov    %eax,%edx
80108ddf:	8b 45 98             	mov    -0x68(%ebp),%eax
80108de2:	01 d0                	add    %edx,%eax
80108de4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108deb:	c1 e0 04             	shl    $0x4,%eax
80108dee:	89 c2                	mov    %eax,%edx
80108df0:	8b 45 98             	mov    -0x68(%ebp),%eax
80108df3:	01 d0                	add    %edx,%eax
80108df5:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108dfb:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108dff:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108e06:	7e 84                	jle    80108d8c <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e08:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108e0f:	eb 57                	jmp    80108e68 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108e11:	e8 8a 99 ff ff       	call   801027a0 <kalloc>
80108e16:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108e19:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108e1d:	75 12                	jne    80108e31 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108e1f:	83 ec 0c             	sub    $0xc,%esp
80108e22:	68 18 c5 10 80       	push   $0x8010c518
80108e27:	e8 c8 75 ff ff       	call   801003f4 <cprintf>
80108e2c:	83 c4 10             	add    $0x10,%esp
      break;
80108e2f:	eb 3d                	jmp    80108e6e <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108e31:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e34:	c1 e0 04             	shl    $0x4,%eax
80108e37:	89 c2                	mov    %eax,%edx
80108e39:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e3c:	01 d0                	add    %edx,%eax
80108e3e:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e41:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e47:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e49:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e4c:	83 c0 01             	add    $0x1,%eax
80108e4f:	c1 e0 04             	shl    $0x4,%eax
80108e52:	89 c2                	mov    %eax,%edx
80108e54:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e57:	01 d0                	add    %edx,%eax
80108e59:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e5c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e62:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e64:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108e68:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108e6c:	7e a3                	jle    80108e11 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108e6e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e71:	8b 00                	mov    (%eax),%eax
80108e73:	83 c8 02             	or     $0x2,%eax
80108e76:	89 c2                	mov    %eax,%edx
80108e78:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e7b:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108e7d:	83 ec 0c             	sub    $0xc,%esp
80108e80:	68 38 c5 10 80       	push   $0x8010c538
80108e85:	e8 6a 75 ff ff       	call   801003f4 <cprintf>
80108e8a:	83 c4 10             	add    $0x10,%esp
}
80108e8d:	90                   	nop
80108e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108e91:	5b                   	pop    %ebx
80108e92:	5e                   	pop    %esi
80108e93:	5f                   	pop    %edi
80108e94:	5d                   	pop    %ebp
80108e95:	c3                   	ret    

80108e96 <i8254_init_send>:

void i8254_init_send(){
80108e96:	55                   	push   %ebp
80108e97:	89 e5                	mov    %esp,%ebp
80108e99:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108e9c:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108ea1:	05 28 38 00 00       	add    $0x3828,%eax
80108ea6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eac:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108eb2:	e8 e9 98 ff ff       	call   801027a0 <kalloc>
80108eb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108eba:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108ebf:	05 00 38 00 00       	add    $0x3800,%eax
80108ec4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108ec7:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108ecc:	05 04 38 00 00       	add    $0x3804,%eax
80108ed1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108ed4:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108ed9:	05 08 38 00 00       	add    $0x3808,%eax
80108ede:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108ee1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ee4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108eea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108eed:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108eef:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ef2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108ef8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108efb:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f01:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108f06:	05 10 38 00 00       	add    $0x3810,%eax
80108f0b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f0e:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108f13:	05 18 38 00 00       	add    $0x3818,%eax
80108f18:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108f1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108f1e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108f24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f27:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108f2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f30:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108f33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f3a:	e9 82 00 00 00       	jmp    80108fc1 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f42:	c1 e0 04             	shl    $0x4,%eax
80108f45:	89 c2                	mov    %eax,%edx
80108f47:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f4a:	01 d0                	add    %edx,%eax
80108f4c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f56:	c1 e0 04             	shl    $0x4,%eax
80108f59:	89 c2                	mov    %eax,%edx
80108f5b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f5e:	01 d0                	add    %edx,%eax
80108f60:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f69:	c1 e0 04             	shl    $0x4,%eax
80108f6c:	89 c2                	mov    %eax,%edx
80108f6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f71:	01 d0                	add    %edx,%eax
80108f73:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f7a:	c1 e0 04             	shl    $0x4,%eax
80108f7d:	89 c2                	mov    %eax,%edx
80108f7f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f82:	01 d0                	add    %edx,%eax
80108f84:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f8b:	c1 e0 04             	shl    $0x4,%eax
80108f8e:	89 c2                	mov    %eax,%edx
80108f90:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f93:	01 d0                	add    %edx,%eax
80108f95:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9c:	c1 e0 04             	shl    $0x4,%eax
80108f9f:	89 c2                	mov    %eax,%edx
80108fa1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fa4:	01 d0                	add    %edx,%eax
80108fa6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fad:	c1 e0 04             	shl    $0x4,%eax
80108fb0:	89 c2                	mov    %eax,%edx
80108fb2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fb5:	01 d0                	add    %edx,%eax
80108fb7:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108fbd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108fc1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108fc8:	0f 8e 71 ff ff ff    	jle    80108f3f <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108fce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108fd5:	eb 57                	jmp    8010902e <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108fd7:	e8 c4 97 ff ff       	call   801027a0 <kalloc>
80108fdc:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108fdf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108fe3:	75 12                	jne    80108ff7 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108fe5:	83 ec 0c             	sub    $0xc,%esp
80108fe8:	68 18 c5 10 80       	push   $0x8010c518
80108fed:	e8 02 74 ff ff       	call   801003f4 <cprintf>
80108ff2:	83 c4 10             	add    $0x10,%esp
      break;
80108ff5:	eb 3d                	jmp    80109034 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ffa:	c1 e0 04             	shl    $0x4,%eax
80108ffd:	89 c2                	mov    %eax,%edx
80108fff:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109002:	01 d0                	add    %edx,%eax
80109004:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109007:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010900d:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010900f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109012:	83 c0 01             	add    $0x1,%eax
80109015:	c1 e0 04             	shl    $0x4,%eax
80109018:	89 c2                	mov    %eax,%edx
8010901a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010901d:	01 d0                	add    %edx,%eax
8010901f:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109022:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109028:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010902a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010902e:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109032:	7e a3                	jle    80108fd7 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109034:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80109039:	05 00 04 00 00       	add    $0x400,%eax
8010903e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109041:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109044:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010904a:	a1 cc 79 19 80       	mov    0x801979cc,%eax
8010904f:	05 10 04 00 00       	add    $0x410,%eax
80109054:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109057:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010905a:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109060:	83 ec 0c             	sub    $0xc,%esp
80109063:	68 58 c5 10 80       	push   $0x8010c558
80109068:	e8 87 73 ff ff       	call   801003f4 <cprintf>
8010906d:	83 c4 10             	add    $0x10,%esp

}
80109070:	90                   	nop
80109071:	c9                   	leave  
80109072:	c3                   	ret    

80109073 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109073:	55                   	push   %ebp
80109074:	89 e5                	mov    %esp,%ebp
80109076:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109079:	a1 cc 79 19 80       	mov    0x801979cc,%eax
8010907e:	83 c0 14             	add    $0x14,%eax
80109081:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80109084:	8b 45 08             	mov    0x8(%ebp),%eax
80109087:	c1 e0 08             	shl    $0x8,%eax
8010908a:	0f b7 c0             	movzwl %ax,%eax
8010908d:	83 c8 01             	or     $0x1,%eax
80109090:	89 c2                	mov    %eax,%edx
80109092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109095:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80109097:	83 ec 0c             	sub    $0xc,%esp
8010909a:	68 78 c5 10 80       	push   $0x8010c578
8010909f:	e8 50 73 ff ff       	call   801003f4 <cprintf>
801090a4:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801090a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090aa:	8b 00                	mov    (%eax),%eax
801090ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801090af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090b2:	83 e0 10             	and    $0x10,%eax
801090b5:	85 c0                	test   %eax,%eax
801090b7:	75 02                	jne    801090bb <i8254_read_eeprom+0x48>
  while(1){
801090b9:	eb dc                	jmp    80109097 <i8254_read_eeprom+0x24>
      break;
801090bb:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801090bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090bf:	8b 00                	mov    (%eax),%eax
801090c1:	c1 e8 10             	shr    $0x10,%eax
}
801090c4:	c9                   	leave  
801090c5:	c3                   	ret    

801090c6 <i8254_recv>:
void i8254_recv(){
801090c6:	55                   	push   %ebp
801090c7:	89 e5                	mov    %esp,%ebp
801090c9:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801090cc:	a1 cc 79 19 80       	mov    0x801979cc,%eax
801090d1:	05 10 28 00 00       	add    $0x2810,%eax
801090d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801090d9:	a1 cc 79 19 80       	mov    0x801979cc,%eax
801090de:	05 18 28 00 00       	add    $0x2818,%eax
801090e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801090e6:	a1 cc 79 19 80       	mov    0x801979cc,%eax
801090eb:	05 00 28 00 00       	add    $0x2800,%eax
801090f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801090f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090f6:	8b 00                	mov    (%eax),%eax
801090f8:	05 00 00 00 80       	add    $0x80000000,%eax
801090fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109103:	8b 10                	mov    (%eax),%edx
80109105:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109108:	8b 08                	mov    (%eax),%ecx
8010910a:	89 d0                	mov    %edx,%eax
8010910c:	29 c8                	sub    %ecx,%eax
8010910e:	25 ff 00 00 00       	and    $0xff,%eax
80109113:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109116:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010911a:	7e 37                	jle    80109153 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010911c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010911f:	8b 00                	mov    (%eax),%eax
80109121:	c1 e0 04             	shl    $0x4,%eax
80109124:	89 c2                	mov    %eax,%edx
80109126:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109129:	01 d0                	add    %edx,%eax
8010912b:	8b 00                	mov    (%eax),%eax
8010912d:	05 00 00 00 80       	add    $0x80000000,%eax
80109132:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109138:	8b 00                	mov    (%eax),%eax
8010913a:	83 c0 01             	add    $0x1,%eax
8010913d:	0f b6 d0             	movzbl %al,%edx
80109140:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109143:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109145:	83 ec 0c             	sub    $0xc,%esp
80109148:	ff 75 e0             	push   -0x20(%ebp)
8010914b:	e8 15 09 00 00       	call   80109a65 <eth_proc>
80109150:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109153:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109156:	8b 10                	mov    (%eax),%edx
80109158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915b:	8b 00                	mov    (%eax),%eax
8010915d:	39 c2                	cmp    %eax,%edx
8010915f:	75 9f                	jne    80109100 <i8254_recv+0x3a>
      (*rdt)--;
80109161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109164:	8b 00                	mov    (%eax),%eax
80109166:	8d 50 ff             	lea    -0x1(%eax),%edx
80109169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010916c:	89 10                	mov    %edx,(%eax)
  while(1){
8010916e:	eb 90                	jmp    80109100 <i8254_recv+0x3a>

80109170 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109170:	55                   	push   %ebp
80109171:	89 e5                	mov    %esp,%ebp
80109173:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109176:	a1 cc 79 19 80       	mov    0x801979cc,%eax
8010917b:	05 10 38 00 00       	add    $0x3810,%eax
80109180:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109183:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80109188:	05 18 38 00 00       	add    $0x3818,%eax
8010918d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109190:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80109195:	05 00 38 00 00       	add    $0x3800,%eax
8010919a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010919d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091a0:	8b 00                	mov    (%eax),%eax
801091a2:	05 00 00 00 80       	add    $0x80000000,%eax
801091a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801091aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ad:	8b 10                	mov    (%eax),%edx
801091af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b2:	8b 08                	mov    (%eax),%ecx
801091b4:	89 d0                	mov    %edx,%eax
801091b6:	29 c8                	sub    %ecx,%eax
801091b8:	0f b6 d0             	movzbl %al,%edx
801091bb:	b8 00 01 00 00       	mov    $0x100,%eax
801091c0:	29 d0                	sub    %edx,%eax
801091c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801091c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c8:	8b 00                	mov    (%eax),%eax
801091ca:	25 ff 00 00 00       	and    $0xff,%eax
801091cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801091d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801091d6:	0f 8e a8 00 00 00    	jle    80109284 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801091dc:	8b 45 08             	mov    0x8(%ebp),%eax
801091df:	8b 55 e0             	mov    -0x20(%ebp),%edx
801091e2:	89 d1                	mov    %edx,%ecx
801091e4:	c1 e1 04             	shl    $0x4,%ecx
801091e7:	8b 55 e8             	mov    -0x18(%ebp),%edx
801091ea:	01 ca                	add    %ecx,%edx
801091ec:	8b 12                	mov    (%edx),%edx
801091ee:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801091f4:	83 ec 04             	sub    $0x4,%esp
801091f7:	ff 75 0c             	push   0xc(%ebp)
801091fa:	50                   	push   %eax
801091fb:	52                   	push   %edx
801091fc:	e8 40 bd ff ff       	call   80104f41 <memmove>
80109201:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109204:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109207:	c1 e0 04             	shl    $0x4,%eax
8010920a:	89 c2                	mov    %eax,%edx
8010920c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010920f:	01 d0                	add    %edx,%eax
80109211:	8b 55 0c             	mov    0xc(%ebp),%edx
80109214:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109218:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010921b:	c1 e0 04             	shl    $0x4,%eax
8010921e:	89 c2                	mov    %eax,%edx
80109220:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109223:	01 d0                	add    %edx,%eax
80109225:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109229:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010922c:	c1 e0 04             	shl    $0x4,%eax
8010922f:	89 c2                	mov    %eax,%edx
80109231:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109234:	01 d0                	add    %edx,%eax
80109236:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010923a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010923d:	c1 e0 04             	shl    $0x4,%eax
80109240:	89 c2                	mov    %eax,%edx
80109242:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109245:	01 d0                	add    %edx,%eax
80109247:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010924b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010924e:	c1 e0 04             	shl    $0x4,%eax
80109251:	89 c2                	mov    %eax,%edx
80109253:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109256:	01 d0                	add    %edx,%eax
80109258:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
8010925e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109261:	c1 e0 04             	shl    $0x4,%eax
80109264:	89 c2                	mov    %eax,%edx
80109266:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109269:	01 d0                	add    %edx,%eax
8010926b:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
8010926f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109272:	8b 00                	mov    (%eax),%eax
80109274:	83 c0 01             	add    $0x1,%eax
80109277:	0f b6 d0             	movzbl %al,%edx
8010927a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010927d:	89 10                	mov    %edx,(%eax)
    return len;
8010927f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109282:	eb 05                	jmp    80109289 <i8254_send+0x119>
  }else{
    return -1;
80109284:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109289:	c9                   	leave  
8010928a:	c3                   	ret    

8010928b <i8254_intr>:

void i8254_intr(){
8010928b:	55                   	push   %ebp
8010928c:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
8010928e:	a1 d8 79 19 80       	mov    0x801979d8,%eax
80109293:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109299:	90                   	nop
8010929a:	5d                   	pop    %ebp
8010929b:	c3                   	ret    

8010929c <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
8010929c:	55                   	push   %ebp
8010929d:	89 e5                	mov    %esp,%ebp
8010929f:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801092a2:	8b 45 08             	mov    0x8(%ebp),%eax
801092a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801092a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ab:	0f b7 00             	movzwl (%eax),%eax
801092ae:	66 3d 00 01          	cmp    $0x100,%ax
801092b2:	74 0a                	je     801092be <arp_proc+0x22>
801092b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092b9:	e9 4f 01 00 00       	jmp    8010940d <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801092be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c1:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801092c5:	66 83 f8 08          	cmp    $0x8,%ax
801092c9:	74 0a                	je     801092d5 <arp_proc+0x39>
801092cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092d0:	e9 38 01 00 00       	jmp    8010940d <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
801092d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801092dc:	3c 06                	cmp    $0x6,%al
801092de:	74 0a                	je     801092ea <arp_proc+0x4e>
801092e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092e5:	e9 23 01 00 00       	jmp    8010940d <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801092ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ed:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801092f1:	3c 04                	cmp    $0x4,%al
801092f3:	74 0a                	je     801092ff <arp_proc+0x63>
801092f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092fa:	e9 0e 01 00 00       	jmp    8010940d <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801092ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109302:	83 c0 18             	add    $0x18,%eax
80109305:	83 ec 04             	sub    $0x4,%esp
80109308:	6a 04                	push   $0x4
8010930a:	50                   	push   %eax
8010930b:	68 04 f5 10 80       	push   $0x8010f504
80109310:	e8 d4 bb ff ff       	call   80104ee9 <memcmp>
80109315:	83 c4 10             	add    $0x10,%esp
80109318:	85 c0                	test   %eax,%eax
8010931a:	74 27                	je     80109343 <arp_proc+0xa7>
8010931c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010931f:	83 c0 0e             	add    $0xe,%eax
80109322:	83 ec 04             	sub    $0x4,%esp
80109325:	6a 04                	push   $0x4
80109327:	50                   	push   %eax
80109328:	68 04 f5 10 80       	push   $0x8010f504
8010932d:	e8 b7 bb ff ff       	call   80104ee9 <memcmp>
80109332:	83 c4 10             	add    $0x10,%esp
80109335:	85 c0                	test   %eax,%eax
80109337:	74 0a                	je     80109343 <arp_proc+0xa7>
80109339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010933e:	e9 ca 00 00 00       	jmp    8010940d <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109346:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010934a:	66 3d 00 01          	cmp    $0x100,%ax
8010934e:	75 69                	jne    801093b9 <arp_proc+0x11d>
80109350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109353:	83 c0 18             	add    $0x18,%eax
80109356:	83 ec 04             	sub    $0x4,%esp
80109359:	6a 04                	push   $0x4
8010935b:	50                   	push   %eax
8010935c:	68 04 f5 10 80       	push   $0x8010f504
80109361:	e8 83 bb ff ff       	call   80104ee9 <memcmp>
80109366:	83 c4 10             	add    $0x10,%esp
80109369:	85 c0                	test   %eax,%eax
8010936b:	75 4c                	jne    801093b9 <arp_proc+0x11d>
    uint send = (uint)kalloc();
8010936d:	e8 2e 94 ff ff       	call   801027a0 <kalloc>
80109372:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109375:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
8010937c:	83 ec 04             	sub    $0x4,%esp
8010937f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109382:	50                   	push   %eax
80109383:	ff 75 f0             	push   -0x10(%ebp)
80109386:	ff 75 f4             	push   -0xc(%ebp)
80109389:	e8 1f 04 00 00       	call   801097ad <arp_reply_pkt_create>
8010938e:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109391:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109394:	83 ec 08             	sub    $0x8,%esp
80109397:	50                   	push   %eax
80109398:	ff 75 f0             	push   -0x10(%ebp)
8010939b:	e8 d0 fd ff ff       	call   80109170 <i8254_send>
801093a0:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801093a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093a6:	83 ec 0c             	sub    $0xc,%esp
801093a9:	50                   	push   %eax
801093aa:	e8 57 93 ff ff       	call   80102706 <kfree>
801093af:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801093b2:	b8 02 00 00 00       	mov    $0x2,%eax
801093b7:	eb 54                	jmp    8010940d <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801093b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093bc:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093c0:	66 3d 00 02          	cmp    $0x200,%ax
801093c4:	75 42                	jne    80109408 <arp_proc+0x16c>
801093c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c9:	83 c0 18             	add    $0x18,%eax
801093cc:	83 ec 04             	sub    $0x4,%esp
801093cf:	6a 04                	push   $0x4
801093d1:	50                   	push   %eax
801093d2:	68 04 f5 10 80       	push   $0x8010f504
801093d7:	e8 0d bb ff ff       	call   80104ee9 <memcmp>
801093dc:	83 c4 10             	add    $0x10,%esp
801093df:	85 c0                	test   %eax,%eax
801093e1:	75 25                	jne    80109408 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801093e3:	83 ec 0c             	sub    $0xc,%esp
801093e6:	68 7c c5 10 80       	push   $0x8010c57c
801093eb:	e8 04 70 ff ff       	call   801003f4 <cprintf>
801093f0:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801093f3:	83 ec 0c             	sub    $0xc,%esp
801093f6:	ff 75 f4             	push   -0xc(%ebp)
801093f9:	e8 af 01 00 00       	call   801095ad <arp_table_update>
801093fe:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109401:	b8 01 00 00 00       	mov    $0x1,%eax
80109406:	eb 05                	jmp    8010940d <arp_proc+0x171>
  }else{
    return -1;
80109408:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
8010940d:	c9                   	leave  
8010940e:	c3                   	ret    

8010940f <arp_scan>:

void arp_scan(){
8010940f:	55                   	push   %ebp
80109410:	89 e5                	mov    %esp,%ebp
80109412:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109415:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010941c:	eb 6f                	jmp    8010948d <arp_scan+0x7e>
    uint send = (uint)kalloc();
8010941e:	e8 7d 93 ff ff       	call   801027a0 <kalloc>
80109423:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109426:	83 ec 04             	sub    $0x4,%esp
80109429:	ff 75 f4             	push   -0xc(%ebp)
8010942c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010942f:	50                   	push   %eax
80109430:	ff 75 ec             	push   -0x14(%ebp)
80109433:	e8 62 00 00 00       	call   8010949a <arp_broadcast>
80109438:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010943b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010943e:	83 ec 08             	sub    $0x8,%esp
80109441:	50                   	push   %eax
80109442:	ff 75 ec             	push   -0x14(%ebp)
80109445:	e8 26 fd ff ff       	call   80109170 <i8254_send>
8010944a:	83 c4 10             	add    $0x10,%esp
8010944d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109450:	eb 22                	jmp    80109474 <arp_scan+0x65>
      microdelay(1);
80109452:	83 ec 0c             	sub    $0xc,%esp
80109455:	6a 01                	push   $0x1
80109457:	e8 db 96 ff ff       	call   80102b37 <microdelay>
8010945c:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010945f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109462:	83 ec 08             	sub    $0x8,%esp
80109465:	50                   	push   %eax
80109466:	ff 75 ec             	push   -0x14(%ebp)
80109469:	e8 02 fd ff ff       	call   80109170 <i8254_send>
8010946e:	83 c4 10             	add    $0x10,%esp
80109471:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109474:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109478:	74 d8                	je     80109452 <arp_scan+0x43>
    }
    kfree((char *)send);
8010947a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010947d:	83 ec 0c             	sub    $0xc,%esp
80109480:	50                   	push   %eax
80109481:	e8 80 92 ff ff       	call   80102706 <kfree>
80109486:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109489:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010948d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109494:	7e 88                	jle    8010941e <arp_scan+0xf>
  }
}
80109496:	90                   	nop
80109497:	90                   	nop
80109498:	c9                   	leave  
80109499:	c3                   	ret    

8010949a <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010949a:	55                   	push   %ebp
8010949b:	89 e5                	mov    %esp,%ebp
8010949d:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801094a0:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801094a4:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801094a8:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801094ac:	8b 45 10             	mov    0x10(%ebp),%eax
801094af:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801094b2:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801094b9:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801094bf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801094c6:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801094cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801094cf:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801094d5:	8b 45 08             	mov    0x8(%ebp),%eax
801094d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801094db:	8b 45 08             	mov    0x8(%ebp),%eax
801094de:	83 c0 0e             	add    $0xe,%eax
801094e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801094e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801094eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ee:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801094f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f5:	83 ec 04             	sub    $0x4,%esp
801094f8:	6a 06                	push   $0x6
801094fa:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801094fd:	52                   	push   %edx
801094fe:	50                   	push   %eax
801094ff:	e8 3d ba ff ff       	call   80104f41 <memmove>
80109504:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010950a:	83 c0 06             	add    $0x6,%eax
8010950d:	83 ec 04             	sub    $0x4,%esp
80109510:	6a 06                	push   $0x6
80109512:	68 d0 79 19 80       	push   $0x801979d0
80109517:	50                   	push   %eax
80109518:	e8 24 ba ff ff       	call   80104f41 <memmove>
8010951d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109523:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010952b:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109534:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010953b:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010953f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109542:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010954b:	8d 50 12             	lea    0x12(%eax),%edx
8010954e:	83 ec 04             	sub    $0x4,%esp
80109551:	6a 06                	push   $0x6
80109553:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109556:	50                   	push   %eax
80109557:	52                   	push   %edx
80109558:	e8 e4 b9 ff ff       	call   80104f41 <memmove>
8010955d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109560:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109563:	8d 50 18             	lea    0x18(%eax),%edx
80109566:	83 ec 04             	sub    $0x4,%esp
80109569:	6a 04                	push   $0x4
8010956b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010956e:	50                   	push   %eax
8010956f:	52                   	push   %edx
80109570:	e8 cc b9 ff ff       	call   80104f41 <memmove>
80109575:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109578:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010957b:	83 c0 08             	add    $0x8,%eax
8010957e:	83 ec 04             	sub    $0x4,%esp
80109581:	6a 06                	push   $0x6
80109583:	68 d0 79 19 80       	push   $0x801979d0
80109588:	50                   	push   %eax
80109589:	e8 b3 b9 ff ff       	call   80104f41 <memmove>
8010958e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109594:	83 c0 0e             	add    $0xe,%eax
80109597:	83 ec 04             	sub    $0x4,%esp
8010959a:	6a 04                	push   $0x4
8010959c:	68 04 f5 10 80       	push   $0x8010f504
801095a1:	50                   	push   %eax
801095a2:	e8 9a b9 ff ff       	call   80104f41 <memmove>
801095a7:	83 c4 10             	add    $0x10,%esp
}
801095aa:	90                   	nop
801095ab:	c9                   	leave  
801095ac:	c3                   	ret    

801095ad <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801095ad:	55                   	push   %ebp
801095ae:	89 e5                	mov    %esp,%ebp
801095b0:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801095b3:	8b 45 08             	mov    0x8(%ebp),%eax
801095b6:	83 c0 0e             	add    $0xe,%eax
801095b9:	83 ec 0c             	sub    $0xc,%esp
801095bc:	50                   	push   %eax
801095bd:	e8 bc 00 00 00       	call   8010967e <arp_table_search>
801095c2:	83 c4 10             	add    $0x10,%esp
801095c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801095c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801095cc:	78 2d                	js     801095fb <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801095ce:	8b 45 08             	mov    0x8(%ebp),%eax
801095d1:	8d 48 08             	lea    0x8(%eax),%ecx
801095d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095d7:	89 d0                	mov    %edx,%eax
801095d9:	c1 e0 02             	shl    $0x2,%eax
801095dc:	01 d0                	add    %edx,%eax
801095de:	01 c0                	add    %eax,%eax
801095e0:	01 d0                	add    %edx,%eax
801095e2:	05 e0 79 19 80       	add    $0x801979e0,%eax
801095e7:	83 c0 04             	add    $0x4,%eax
801095ea:	83 ec 04             	sub    $0x4,%esp
801095ed:	6a 06                	push   $0x6
801095ef:	51                   	push   %ecx
801095f0:	50                   	push   %eax
801095f1:	e8 4b b9 ff ff       	call   80104f41 <memmove>
801095f6:	83 c4 10             	add    $0x10,%esp
801095f9:	eb 70                	jmp    8010966b <arp_table_update+0xbe>
  }else{
    index += 1;
801095fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801095ff:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109602:	8b 45 08             	mov    0x8(%ebp),%eax
80109605:	8d 48 08             	lea    0x8(%eax),%ecx
80109608:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010960b:	89 d0                	mov    %edx,%eax
8010960d:	c1 e0 02             	shl    $0x2,%eax
80109610:	01 d0                	add    %edx,%eax
80109612:	01 c0                	add    %eax,%eax
80109614:	01 d0                	add    %edx,%eax
80109616:	05 e0 79 19 80       	add    $0x801979e0,%eax
8010961b:	83 c0 04             	add    $0x4,%eax
8010961e:	83 ec 04             	sub    $0x4,%esp
80109621:	6a 06                	push   $0x6
80109623:	51                   	push   %ecx
80109624:	50                   	push   %eax
80109625:	e8 17 b9 ff ff       	call   80104f41 <memmove>
8010962a:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
8010962d:	8b 45 08             	mov    0x8(%ebp),%eax
80109630:	8d 48 0e             	lea    0xe(%eax),%ecx
80109633:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109636:	89 d0                	mov    %edx,%eax
80109638:	c1 e0 02             	shl    $0x2,%eax
8010963b:	01 d0                	add    %edx,%eax
8010963d:	01 c0                	add    %eax,%eax
8010963f:	01 d0                	add    %edx,%eax
80109641:	05 e0 79 19 80       	add    $0x801979e0,%eax
80109646:	83 ec 04             	sub    $0x4,%esp
80109649:	6a 04                	push   $0x4
8010964b:	51                   	push   %ecx
8010964c:	50                   	push   %eax
8010964d:	e8 ef b8 ff ff       	call   80104f41 <memmove>
80109652:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109655:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109658:	89 d0                	mov    %edx,%eax
8010965a:	c1 e0 02             	shl    $0x2,%eax
8010965d:	01 d0                	add    %edx,%eax
8010965f:	01 c0                	add    %eax,%eax
80109661:	01 d0                	add    %edx,%eax
80109663:	05 ea 79 19 80       	add    $0x801979ea,%eax
80109668:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010966b:	83 ec 0c             	sub    $0xc,%esp
8010966e:	68 e0 79 19 80       	push   $0x801979e0
80109673:	e8 83 00 00 00       	call   801096fb <print_arp_table>
80109678:	83 c4 10             	add    $0x10,%esp
}
8010967b:	90                   	nop
8010967c:	c9                   	leave  
8010967d:	c3                   	ret    

8010967e <arp_table_search>:

int arp_table_search(uchar *ip){
8010967e:	55                   	push   %ebp
8010967f:	89 e5                	mov    %esp,%ebp
80109681:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109684:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010968b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109692:	eb 59                	jmp    801096ed <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109694:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109697:	89 d0                	mov    %edx,%eax
80109699:	c1 e0 02             	shl    $0x2,%eax
8010969c:	01 d0                	add    %edx,%eax
8010969e:	01 c0                	add    %eax,%eax
801096a0:	01 d0                	add    %edx,%eax
801096a2:	05 e0 79 19 80       	add    $0x801979e0,%eax
801096a7:	83 ec 04             	sub    $0x4,%esp
801096aa:	6a 04                	push   $0x4
801096ac:	ff 75 08             	push   0x8(%ebp)
801096af:	50                   	push   %eax
801096b0:	e8 34 b8 ff ff       	call   80104ee9 <memcmp>
801096b5:	83 c4 10             	add    $0x10,%esp
801096b8:	85 c0                	test   %eax,%eax
801096ba:	75 05                	jne    801096c1 <arp_table_search+0x43>
      return i;
801096bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096bf:	eb 38                	jmp    801096f9 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801096c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801096c4:	89 d0                	mov    %edx,%eax
801096c6:	c1 e0 02             	shl    $0x2,%eax
801096c9:	01 d0                	add    %edx,%eax
801096cb:	01 c0                	add    %eax,%eax
801096cd:	01 d0                	add    %edx,%eax
801096cf:	05 ea 79 19 80       	add    $0x801979ea,%eax
801096d4:	0f b6 00             	movzbl (%eax),%eax
801096d7:	84 c0                	test   %al,%al
801096d9:	75 0e                	jne    801096e9 <arp_table_search+0x6b>
801096db:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801096df:	75 08                	jne    801096e9 <arp_table_search+0x6b>
      empty = -i;
801096e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096e4:	f7 d8                	neg    %eax
801096e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801096e9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801096ed:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801096f1:	7e a1                	jle    80109694 <arp_table_search+0x16>
    }
  }
  return empty-1;
801096f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f6:	83 e8 01             	sub    $0x1,%eax
}
801096f9:	c9                   	leave  
801096fa:	c3                   	ret    

801096fb <print_arp_table>:

void print_arp_table(){
801096fb:	55                   	push   %ebp
801096fc:	89 e5                	mov    %esp,%ebp
801096fe:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109701:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109708:	e9 92 00 00 00       	jmp    8010979f <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
8010970d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109710:	89 d0                	mov    %edx,%eax
80109712:	c1 e0 02             	shl    $0x2,%eax
80109715:	01 d0                	add    %edx,%eax
80109717:	01 c0                	add    %eax,%eax
80109719:	01 d0                	add    %edx,%eax
8010971b:	05 ea 79 19 80       	add    $0x801979ea,%eax
80109720:	0f b6 00             	movzbl (%eax),%eax
80109723:	84 c0                	test   %al,%al
80109725:	74 74                	je     8010979b <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109727:	83 ec 08             	sub    $0x8,%esp
8010972a:	ff 75 f4             	push   -0xc(%ebp)
8010972d:	68 8f c5 10 80       	push   $0x8010c58f
80109732:	e8 bd 6c ff ff       	call   801003f4 <cprintf>
80109737:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010973a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010973d:	89 d0                	mov    %edx,%eax
8010973f:	c1 e0 02             	shl    $0x2,%eax
80109742:	01 d0                	add    %edx,%eax
80109744:	01 c0                	add    %eax,%eax
80109746:	01 d0                	add    %edx,%eax
80109748:	05 e0 79 19 80       	add    $0x801979e0,%eax
8010974d:	83 ec 0c             	sub    $0xc,%esp
80109750:	50                   	push   %eax
80109751:	e8 54 02 00 00       	call   801099aa <print_ipv4>
80109756:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109759:	83 ec 0c             	sub    $0xc,%esp
8010975c:	68 9e c5 10 80       	push   $0x8010c59e
80109761:	e8 8e 6c ff ff       	call   801003f4 <cprintf>
80109766:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109769:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010976c:	89 d0                	mov    %edx,%eax
8010976e:	c1 e0 02             	shl    $0x2,%eax
80109771:	01 d0                	add    %edx,%eax
80109773:	01 c0                	add    %eax,%eax
80109775:	01 d0                	add    %edx,%eax
80109777:	05 e0 79 19 80       	add    $0x801979e0,%eax
8010977c:	83 c0 04             	add    $0x4,%eax
8010977f:	83 ec 0c             	sub    $0xc,%esp
80109782:	50                   	push   %eax
80109783:	e8 70 02 00 00       	call   801099f8 <print_mac>
80109788:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010978b:	83 ec 0c             	sub    $0xc,%esp
8010978e:	68 a0 c5 10 80       	push   $0x8010c5a0
80109793:	e8 5c 6c ff ff       	call   801003f4 <cprintf>
80109798:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010979b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010979f:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801097a3:	0f 8e 64 ff ff ff    	jle    8010970d <print_arp_table+0x12>
    }
  }
}
801097a9:	90                   	nop
801097aa:	90                   	nop
801097ab:	c9                   	leave  
801097ac:	c3                   	ret    

801097ad <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801097ad:	55                   	push   %ebp
801097ae:	89 e5                	mov    %esp,%ebp
801097b0:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801097b3:	8b 45 10             	mov    0x10(%ebp),%eax
801097b6:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801097bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801097bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801097c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801097c5:	83 c0 0e             	add    $0xe,%eax
801097c8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801097cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ce:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801097d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d5:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801097d9:	8b 45 08             	mov    0x8(%ebp),%eax
801097dc:	8d 50 08             	lea    0x8(%eax),%edx
801097df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e2:	83 ec 04             	sub    $0x4,%esp
801097e5:	6a 06                	push   $0x6
801097e7:	52                   	push   %edx
801097e8:	50                   	push   %eax
801097e9:	e8 53 b7 ff ff       	call   80104f41 <memmove>
801097ee:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801097f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f4:	83 c0 06             	add    $0x6,%eax
801097f7:	83 ec 04             	sub    $0x4,%esp
801097fa:	6a 06                	push   $0x6
801097fc:	68 d0 79 19 80       	push   $0x801979d0
80109801:	50                   	push   %eax
80109802:	e8 3a b7 ff ff       	call   80104f41 <memmove>
80109807:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010980a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010980d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109812:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109815:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010981b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010981e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109822:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109825:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109829:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010982c:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109832:	8b 45 08             	mov    0x8(%ebp),%eax
80109835:	8d 50 08             	lea    0x8(%eax),%edx
80109838:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010983b:	83 c0 12             	add    $0x12,%eax
8010983e:	83 ec 04             	sub    $0x4,%esp
80109841:	6a 06                	push   $0x6
80109843:	52                   	push   %edx
80109844:	50                   	push   %eax
80109845:	e8 f7 b6 ff ff       	call   80104f41 <memmove>
8010984a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010984d:	8b 45 08             	mov    0x8(%ebp),%eax
80109850:	8d 50 0e             	lea    0xe(%eax),%edx
80109853:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109856:	83 c0 18             	add    $0x18,%eax
80109859:	83 ec 04             	sub    $0x4,%esp
8010985c:	6a 04                	push   $0x4
8010985e:	52                   	push   %edx
8010985f:	50                   	push   %eax
80109860:	e8 dc b6 ff ff       	call   80104f41 <memmove>
80109865:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109868:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010986b:	83 c0 08             	add    $0x8,%eax
8010986e:	83 ec 04             	sub    $0x4,%esp
80109871:	6a 06                	push   $0x6
80109873:	68 d0 79 19 80       	push   $0x801979d0
80109878:	50                   	push   %eax
80109879:	e8 c3 b6 ff ff       	call   80104f41 <memmove>
8010987e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109884:	83 c0 0e             	add    $0xe,%eax
80109887:	83 ec 04             	sub    $0x4,%esp
8010988a:	6a 04                	push   $0x4
8010988c:	68 04 f5 10 80       	push   $0x8010f504
80109891:	50                   	push   %eax
80109892:	e8 aa b6 ff ff       	call   80104f41 <memmove>
80109897:	83 c4 10             	add    $0x10,%esp
}
8010989a:	90                   	nop
8010989b:	c9                   	leave  
8010989c:	c3                   	ret    

8010989d <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010989d:	55                   	push   %ebp
8010989e:	89 e5                	mov    %esp,%ebp
801098a0:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801098a3:	83 ec 0c             	sub    $0xc,%esp
801098a6:	68 a2 c5 10 80       	push   $0x8010c5a2
801098ab:	e8 44 6b ff ff       	call   801003f4 <cprintf>
801098b0:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801098b3:	8b 45 08             	mov    0x8(%ebp),%eax
801098b6:	83 c0 0e             	add    $0xe,%eax
801098b9:	83 ec 0c             	sub    $0xc,%esp
801098bc:	50                   	push   %eax
801098bd:	e8 e8 00 00 00       	call   801099aa <print_ipv4>
801098c2:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801098c5:	83 ec 0c             	sub    $0xc,%esp
801098c8:	68 a0 c5 10 80       	push   $0x8010c5a0
801098cd:	e8 22 6b ff ff       	call   801003f4 <cprintf>
801098d2:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801098d5:	8b 45 08             	mov    0x8(%ebp),%eax
801098d8:	83 c0 08             	add    $0x8,%eax
801098db:	83 ec 0c             	sub    $0xc,%esp
801098de:	50                   	push   %eax
801098df:	e8 14 01 00 00       	call   801099f8 <print_mac>
801098e4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801098e7:	83 ec 0c             	sub    $0xc,%esp
801098ea:	68 a0 c5 10 80       	push   $0x8010c5a0
801098ef:	e8 00 6b ff ff       	call   801003f4 <cprintf>
801098f4:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801098f7:	83 ec 0c             	sub    $0xc,%esp
801098fa:	68 b9 c5 10 80       	push   $0x8010c5b9
801098ff:	e8 f0 6a ff ff       	call   801003f4 <cprintf>
80109904:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109907:	8b 45 08             	mov    0x8(%ebp),%eax
8010990a:	83 c0 18             	add    $0x18,%eax
8010990d:	83 ec 0c             	sub    $0xc,%esp
80109910:	50                   	push   %eax
80109911:	e8 94 00 00 00       	call   801099aa <print_ipv4>
80109916:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109919:	83 ec 0c             	sub    $0xc,%esp
8010991c:	68 a0 c5 10 80       	push   $0x8010c5a0
80109921:	e8 ce 6a ff ff       	call   801003f4 <cprintf>
80109926:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109929:	8b 45 08             	mov    0x8(%ebp),%eax
8010992c:	83 c0 12             	add    $0x12,%eax
8010992f:	83 ec 0c             	sub    $0xc,%esp
80109932:	50                   	push   %eax
80109933:	e8 c0 00 00 00       	call   801099f8 <print_mac>
80109938:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010993b:	83 ec 0c             	sub    $0xc,%esp
8010993e:	68 a0 c5 10 80       	push   $0x8010c5a0
80109943:	e8 ac 6a ff ff       	call   801003f4 <cprintf>
80109948:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010994b:	83 ec 0c             	sub    $0xc,%esp
8010994e:	68 d0 c5 10 80       	push   $0x8010c5d0
80109953:	e8 9c 6a ff ff       	call   801003f4 <cprintf>
80109958:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010995b:	8b 45 08             	mov    0x8(%ebp),%eax
8010995e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109962:	66 3d 00 01          	cmp    $0x100,%ax
80109966:	75 12                	jne    8010997a <print_arp_info+0xdd>
80109968:	83 ec 0c             	sub    $0xc,%esp
8010996b:	68 dc c5 10 80       	push   $0x8010c5dc
80109970:	e8 7f 6a ff ff       	call   801003f4 <cprintf>
80109975:	83 c4 10             	add    $0x10,%esp
80109978:	eb 1d                	jmp    80109997 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010997a:	8b 45 08             	mov    0x8(%ebp),%eax
8010997d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109981:	66 3d 00 02          	cmp    $0x200,%ax
80109985:	75 10                	jne    80109997 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109987:	83 ec 0c             	sub    $0xc,%esp
8010998a:	68 e5 c5 10 80       	push   $0x8010c5e5
8010998f:	e8 60 6a ff ff       	call   801003f4 <cprintf>
80109994:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109997:	83 ec 0c             	sub    $0xc,%esp
8010999a:	68 a0 c5 10 80       	push   $0x8010c5a0
8010999f:	e8 50 6a ff ff       	call   801003f4 <cprintf>
801099a4:	83 c4 10             	add    $0x10,%esp
}
801099a7:	90                   	nop
801099a8:	c9                   	leave  
801099a9:	c3                   	ret    

801099aa <print_ipv4>:

void print_ipv4(uchar *ip){
801099aa:	55                   	push   %ebp
801099ab:	89 e5                	mov    %esp,%ebp
801099ad:	53                   	push   %ebx
801099ae:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801099b1:	8b 45 08             	mov    0x8(%ebp),%eax
801099b4:	83 c0 03             	add    $0x3,%eax
801099b7:	0f b6 00             	movzbl (%eax),%eax
801099ba:	0f b6 d8             	movzbl %al,%ebx
801099bd:	8b 45 08             	mov    0x8(%ebp),%eax
801099c0:	83 c0 02             	add    $0x2,%eax
801099c3:	0f b6 00             	movzbl (%eax),%eax
801099c6:	0f b6 c8             	movzbl %al,%ecx
801099c9:	8b 45 08             	mov    0x8(%ebp),%eax
801099cc:	83 c0 01             	add    $0x1,%eax
801099cf:	0f b6 00             	movzbl (%eax),%eax
801099d2:	0f b6 d0             	movzbl %al,%edx
801099d5:	8b 45 08             	mov    0x8(%ebp),%eax
801099d8:	0f b6 00             	movzbl (%eax),%eax
801099db:	0f b6 c0             	movzbl %al,%eax
801099de:	83 ec 0c             	sub    $0xc,%esp
801099e1:	53                   	push   %ebx
801099e2:	51                   	push   %ecx
801099e3:	52                   	push   %edx
801099e4:	50                   	push   %eax
801099e5:	68 ec c5 10 80       	push   $0x8010c5ec
801099ea:	e8 05 6a ff ff       	call   801003f4 <cprintf>
801099ef:	83 c4 20             	add    $0x20,%esp
}
801099f2:	90                   	nop
801099f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801099f6:	c9                   	leave  
801099f7:	c3                   	ret    

801099f8 <print_mac>:

void print_mac(uchar *mac){
801099f8:	55                   	push   %ebp
801099f9:	89 e5                	mov    %esp,%ebp
801099fb:	57                   	push   %edi
801099fc:	56                   	push   %esi
801099fd:	53                   	push   %ebx
801099fe:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109a01:	8b 45 08             	mov    0x8(%ebp),%eax
80109a04:	83 c0 05             	add    $0x5,%eax
80109a07:	0f b6 00             	movzbl (%eax),%eax
80109a0a:	0f b6 f8             	movzbl %al,%edi
80109a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a10:	83 c0 04             	add    $0x4,%eax
80109a13:	0f b6 00             	movzbl (%eax),%eax
80109a16:	0f b6 f0             	movzbl %al,%esi
80109a19:	8b 45 08             	mov    0x8(%ebp),%eax
80109a1c:	83 c0 03             	add    $0x3,%eax
80109a1f:	0f b6 00             	movzbl (%eax),%eax
80109a22:	0f b6 d8             	movzbl %al,%ebx
80109a25:	8b 45 08             	mov    0x8(%ebp),%eax
80109a28:	83 c0 02             	add    $0x2,%eax
80109a2b:	0f b6 00             	movzbl (%eax),%eax
80109a2e:	0f b6 c8             	movzbl %al,%ecx
80109a31:	8b 45 08             	mov    0x8(%ebp),%eax
80109a34:	83 c0 01             	add    $0x1,%eax
80109a37:	0f b6 00             	movzbl (%eax),%eax
80109a3a:	0f b6 d0             	movzbl %al,%edx
80109a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a40:	0f b6 00             	movzbl (%eax),%eax
80109a43:	0f b6 c0             	movzbl %al,%eax
80109a46:	83 ec 04             	sub    $0x4,%esp
80109a49:	57                   	push   %edi
80109a4a:	56                   	push   %esi
80109a4b:	53                   	push   %ebx
80109a4c:	51                   	push   %ecx
80109a4d:	52                   	push   %edx
80109a4e:	50                   	push   %eax
80109a4f:	68 04 c6 10 80       	push   $0x8010c604
80109a54:	e8 9b 69 ff ff       	call   801003f4 <cprintf>
80109a59:	83 c4 20             	add    $0x20,%esp
}
80109a5c:	90                   	nop
80109a5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109a60:	5b                   	pop    %ebx
80109a61:	5e                   	pop    %esi
80109a62:	5f                   	pop    %edi
80109a63:	5d                   	pop    %ebp
80109a64:	c3                   	ret    

80109a65 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109a65:	55                   	push   %ebp
80109a66:	89 e5                	mov    %esp,%ebp
80109a68:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109a71:	8b 45 08             	mov    0x8(%ebp),%eax
80109a74:	83 c0 0e             	add    $0xe,%eax
80109a77:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a7d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109a81:	3c 08                	cmp    $0x8,%al
80109a83:	75 1b                	jne    80109aa0 <eth_proc+0x3b>
80109a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a88:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a8c:	3c 06                	cmp    $0x6,%al
80109a8e:	75 10                	jne    80109aa0 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109a90:	83 ec 0c             	sub    $0xc,%esp
80109a93:	ff 75 f0             	push   -0x10(%ebp)
80109a96:	e8 01 f8 ff ff       	call   8010929c <arp_proc>
80109a9b:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109a9e:	eb 24                	jmp    80109ac4 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aa3:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109aa7:	3c 08                	cmp    $0x8,%al
80109aa9:	75 19                	jne    80109ac4 <eth_proc+0x5f>
80109aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aae:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ab2:	84 c0                	test   %al,%al
80109ab4:	75 0e                	jne    80109ac4 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109ab6:	83 ec 0c             	sub    $0xc,%esp
80109ab9:	ff 75 08             	push   0x8(%ebp)
80109abc:	e8 a3 00 00 00       	call   80109b64 <ipv4_proc>
80109ac1:	83 c4 10             	add    $0x10,%esp
}
80109ac4:	90                   	nop
80109ac5:	c9                   	leave  
80109ac6:	c3                   	ret    

80109ac7 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109ac7:	55                   	push   %ebp
80109ac8:	89 e5                	mov    %esp,%ebp
80109aca:	83 ec 04             	sub    $0x4,%esp
80109acd:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109ad4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ad8:	c1 e0 08             	shl    $0x8,%eax
80109adb:	89 c2                	mov    %eax,%edx
80109add:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ae1:	66 c1 e8 08          	shr    $0x8,%ax
80109ae5:	01 d0                	add    %edx,%eax
}
80109ae7:	c9                   	leave  
80109ae8:	c3                   	ret    

80109ae9 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109ae9:	55                   	push   %ebp
80109aea:	89 e5                	mov    %esp,%ebp
80109aec:	83 ec 04             	sub    $0x4,%esp
80109aef:	8b 45 08             	mov    0x8(%ebp),%eax
80109af2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109af6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109afa:	c1 e0 08             	shl    $0x8,%eax
80109afd:	89 c2                	mov    %eax,%edx
80109aff:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b03:	66 c1 e8 08          	shr    $0x8,%ax
80109b07:	01 d0                	add    %edx,%eax
}
80109b09:	c9                   	leave  
80109b0a:	c3                   	ret    

80109b0b <H2N_uint>:

uint H2N_uint(uint value){
80109b0b:	55                   	push   %ebp
80109b0c:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b11:	c1 e0 18             	shl    $0x18,%eax
80109b14:	25 00 00 00 0f       	and    $0xf000000,%eax
80109b19:	89 c2                	mov    %eax,%edx
80109b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1e:	c1 e0 08             	shl    $0x8,%eax
80109b21:	25 00 f0 00 00       	and    $0xf000,%eax
80109b26:	09 c2                	or     %eax,%edx
80109b28:	8b 45 08             	mov    0x8(%ebp),%eax
80109b2b:	c1 e8 08             	shr    $0x8,%eax
80109b2e:	83 e0 0f             	and    $0xf,%eax
80109b31:	01 d0                	add    %edx,%eax
}
80109b33:	5d                   	pop    %ebp
80109b34:	c3                   	ret    

80109b35 <N2H_uint>:

uint N2H_uint(uint value){
80109b35:	55                   	push   %ebp
80109b36:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109b38:	8b 45 08             	mov    0x8(%ebp),%eax
80109b3b:	c1 e0 18             	shl    $0x18,%eax
80109b3e:	89 c2                	mov    %eax,%edx
80109b40:	8b 45 08             	mov    0x8(%ebp),%eax
80109b43:	c1 e0 08             	shl    $0x8,%eax
80109b46:	25 00 00 ff 00       	and    $0xff0000,%eax
80109b4b:	01 c2                	add    %eax,%edx
80109b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b50:	c1 e8 08             	shr    $0x8,%eax
80109b53:	25 00 ff 00 00       	and    $0xff00,%eax
80109b58:	01 c2                	add    %eax,%edx
80109b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b5d:	c1 e8 18             	shr    $0x18,%eax
80109b60:	01 d0                	add    %edx,%eax
}
80109b62:	5d                   	pop    %ebp
80109b63:	c3                   	ret    

80109b64 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109b64:	55                   	push   %ebp
80109b65:	89 e5                	mov    %esp,%ebp
80109b67:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b6d:	83 c0 0e             	add    $0xe,%eax
80109b70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b76:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b7a:	0f b7 d0             	movzwl %ax,%edx
80109b7d:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109b82:	39 c2                	cmp    %eax,%edx
80109b84:	74 60                	je     80109be6 <ipv4_proc+0x82>
80109b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b89:	83 c0 0c             	add    $0xc,%eax
80109b8c:	83 ec 04             	sub    $0x4,%esp
80109b8f:	6a 04                	push   $0x4
80109b91:	50                   	push   %eax
80109b92:	68 04 f5 10 80       	push   $0x8010f504
80109b97:	e8 4d b3 ff ff       	call   80104ee9 <memcmp>
80109b9c:	83 c4 10             	add    $0x10,%esp
80109b9f:	85 c0                	test   %eax,%eax
80109ba1:	74 43                	je     80109be6 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ba6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109baa:	0f b7 c0             	movzwl %ax,%eax
80109bad:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bb5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109bb9:	3c 01                	cmp    $0x1,%al
80109bbb:	75 10                	jne    80109bcd <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109bbd:	83 ec 0c             	sub    $0xc,%esp
80109bc0:	ff 75 08             	push   0x8(%ebp)
80109bc3:	e8 a3 00 00 00       	call   80109c6b <icmp_proc>
80109bc8:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109bcb:	eb 19                	jmp    80109be6 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bd0:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109bd4:	3c 06                	cmp    $0x6,%al
80109bd6:	75 0e                	jne    80109be6 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109bd8:	83 ec 0c             	sub    $0xc,%esp
80109bdb:	ff 75 08             	push   0x8(%ebp)
80109bde:	e8 b3 03 00 00       	call   80109f96 <tcp_proc>
80109be3:	83 c4 10             	add    $0x10,%esp
}
80109be6:	90                   	nop
80109be7:	c9                   	leave  
80109be8:	c3                   	ret    

80109be9 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109be9:	55                   	push   %ebp
80109bea:	89 e5                	mov    %esp,%ebp
80109bec:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109bef:	8b 45 08             	mov    0x8(%ebp),%eax
80109bf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bf8:	0f b6 00             	movzbl (%eax),%eax
80109bfb:	83 e0 0f             	and    $0xf,%eax
80109bfe:	01 c0                	add    %eax,%eax
80109c00:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109c03:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c0a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109c11:	eb 48                	jmp    80109c5b <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109c13:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c16:	01 c0                	add    %eax,%eax
80109c18:	89 c2                	mov    %eax,%edx
80109c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c1d:	01 d0                	add    %edx,%eax
80109c1f:	0f b6 00             	movzbl (%eax),%eax
80109c22:	0f b6 c0             	movzbl %al,%eax
80109c25:	c1 e0 08             	shl    $0x8,%eax
80109c28:	89 c2                	mov    %eax,%edx
80109c2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c2d:	01 c0                	add    %eax,%eax
80109c2f:	8d 48 01             	lea    0x1(%eax),%ecx
80109c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c35:	01 c8                	add    %ecx,%eax
80109c37:	0f b6 00             	movzbl (%eax),%eax
80109c3a:	0f b6 c0             	movzbl %al,%eax
80109c3d:	01 d0                	add    %edx,%eax
80109c3f:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109c42:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109c49:	76 0c                	jbe    80109c57 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109c4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c4e:	0f b7 c0             	movzwl %ax,%eax
80109c51:	83 c0 01             	add    $0x1,%eax
80109c54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c57:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109c5b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109c5f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109c62:	7c af                	jl     80109c13 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109c64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c67:	f7 d0                	not    %eax
}
80109c69:	c9                   	leave  
80109c6a:	c3                   	ret    

80109c6b <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109c6b:	55                   	push   %ebp
80109c6c:	89 e5                	mov    %esp,%ebp
80109c6e:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109c71:	8b 45 08             	mov    0x8(%ebp),%eax
80109c74:	83 c0 0e             	add    $0xe,%eax
80109c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c7d:	0f b6 00             	movzbl (%eax),%eax
80109c80:	0f b6 c0             	movzbl %al,%eax
80109c83:	83 e0 0f             	and    $0xf,%eax
80109c86:	c1 e0 02             	shl    $0x2,%eax
80109c89:	89 c2                	mov    %eax,%edx
80109c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c8e:	01 d0                	add    %edx,%eax
80109c90:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c96:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109c9a:	84 c0                	test   %al,%al
80109c9c:	75 4f                	jne    80109ced <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ca1:	0f b6 00             	movzbl (%eax),%eax
80109ca4:	3c 08                	cmp    $0x8,%al
80109ca6:	75 45                	jne    80109ced <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109ca8:	e8 f3 8a ff ff       	call   801027a0 <kalloc>
80109cad:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109cb0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109cb7:	83 ec 04             	sub    $0x4,%esp
80109cba:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109cbd:	50                   	push   %eax
80109cbe:	ff 75 ec             	push   -0x14(%ebp)
80109cc1:	ff 75 08             	push   0x8(%ebp)
80109cc4:	e8 78 00 00 00       	call   80109d41 <icmp_reply_pkt_create>
80109cc9:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109ccc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ccf:	83 ec 08             	sub    $0x8,%esp
80109cd2:	50                   	push   %eax
80109cd3:	ff 75 ec             	push   -0x14(%ebp)
80109cd6:	e8 95 f4 ff ff       	call   80109170 <i8254_send>
80109cdb:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109cde:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ce1:	83 ec 0c             	sub    $0xc,%esp
80109ce4:	50                   	push   %eax
80109ce5:	e8 1c 8a ff ff       	call   80102706 <kfree>
80109cea:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109ced:	90                   	nop
80109cee:	c9                   	leave  
80109cef:	c3                   	ret    

80109cf0 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109cf0:	55                   	push   %ebp
80109cf1:	89 e5                	mov    %esp,%ebp
80109cf3:	53                   	push   %ebx
80109cf4:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80109cfa:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109cfe:	0f b7 c0             	movzwl %ax,%eax
80109d01:	83 ec 0c             	sub    $0xc,%esp
80109d04:	50                   	push   %eax
80109d05:	e8 bd fd ff ff       	call   80109ac7 <N2H_ushort>
80109d0a:	83 c4 10             	add    $0x10,%esp
80109d0d:	0f b7 d8             	movzwl %ax,%ebx
80109d10:	8b 45 08             	mov    0x8(%ebp),%eax
80109d13:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d17:	0f b7 c0             	movzwl %ax,%eax
80109d1a:	83 ec 0c             	sub    $0xc,%esp
80109d1d:	50                   	push   %eax
80109d1e:	e8 a4 fd ff ff       	call   80109ac7 <N2H_ushort>
80109d23:	83 c4 10             	add    $0x10,%esp
80109d26:	0f b7 c0             	movzwl %ax,%eax
80109d29:	83 ec 04             	sub    $0x4,%esp
80109d2c:	53                   	push   %ebx
80109d2d:	50                   	push   %eax
80109d2e:	68 23 c6 10 80       	push   $0x8010c623
80109d33:	e8 bc 66 ff ff       	call   801003f4 <cprintf>
80109d38:	83 c4 10             	add    $0x10,%esp
}
80109d3b:	90                   	nop
80109d3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109d3f:	c9                   	leave  
80109d40:	c3                   	ret    

80109d41 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109d41:	55                   	push   %ebp
80109d42:	89 e5                	mov    %esp,%ebp
80109d44:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109d47:	8b 45 08             	mov    0x8(%ebp),%eax
80109d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d50:	83 c0 0e             	add    $0xe,%eax
80109d53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d59:	0f b6 00             	movzbl (%eax),%eax
80109d5c:	0f b6 c0             	movzbl %al,%eax
80109d5f:	83 e0 0f             	and    $0xf,%eax
80109d62:	c1 e0 02             	shl    $0x2,%eax
80109d65:	89 c2                	mov    %eax,%edx
80109d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d6a:	01 d0                	add    %edx,%eax
80109d6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d72:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109d75:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d78:	83 c0 0e             	add    $0xe,%eax
80109d7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d81:	83 c0 14             	add    $0x14,%eax
80109d84:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109d87:	8b 45 10             	mov    0x10(%ebp),%eax
80109d8a:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d93:	8d 50 06             	lea    0x6(%eax),%edx
80109d96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d99:	83 ec 04             	sub    $0x4,%esp
80109d9c:	6a 06                	push   $0x6
80109d9e:	52                   	push   %edx
80109d9f:	50                   	push   %eax
80109da0:	e8 9c b1 ff ff       	call   80104f41 <memmove>
80109da5:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dab:	83 c0 06             	add    $0x6,%eax
80109dae:	83 ec 04             	sub    $0x4,%esp
80109db1:	6a 06                	push   $0x6
80109db3:	68 d0 79 19 80       	push   $0x801979d0
80109db8:	50                   	push   %eax
80109db9:	e8 83 b1 ff ff       	call   80104f41 <memmove>
80109dbe:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109dc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dc4:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dcb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109dcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dd2:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dd8:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109ddc:	83 ec 0c             	sub    $0xc,%esp
80109ddf:	6a 54                	push   $0x54
80109de1:	e8 03 fd ff ff       	call   80109ae9 <H2N_ushort>
80109de6:	83 c4 10             	add    $0x10,%esp
80109de9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109dec:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109df0:	0f b7 15 a0 7c 19 80 	movzwl 0x80197ca0,%edx
80109df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dfa:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109dfe:	0f b7 05 a0 7c 19 80 	movzwl 0x80197ca0,%eax
80109e05:	83 c0 01             	add    $0x1,%eax
80109e08:	66 a3 a0 7c 19 80    	mov    %ax,0x80197ca0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109e0e:	83 ec 0c             	sub    $0xc,%esp
80109e11:	68 00 40 00 00       	push   $0x4000
80109e16:	e8 ce fc ff ff       	call   80109ae9 <H2N_ushort>
80109e1b:	83 c4 10             	add    $0x10,%esp
80109e1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e21:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e28:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e2f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109e33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e36:	83 c0 0c             	add    $0xc,%eax
80109e39:	83 ec 04             	sub    $0x4,%esp
80109e3c:	6a 04                	push   $0x4
80109e3e:	68 04 f5 10 80       	push   $0x8010f504
80109e43:	50                   	push   %eax
80109e44:	e8 f8 b0 ff ff       	call   80104f41 <memmove>
80109e49:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e4f:	8d 50 0c             	lea    0xc(%eax),%edx
80109e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e55:	83 c0 10             	add    $0x10,%eax
80109e58:	83 ec 04             	sub    $0x4,%esp
80109e5b:	6a 04                	push   $0x4
80109e5d:	52                   	push   %edx
80109e5e:	50                   	push   %eax
80109e5f:	e8 dd b0 ff ff       	call   80104f41 <memmove>
80109e64:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e6a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e73:	83 ec 0c             	sub    $0xc,%esp
80109e76:	50                   	push   %eax
80109e77:	e8 6d fd ff ff       	call   80109be9 <ipv4_chksum>
80109e7c:	83 c4 10             	add    $0x10,%esp
80109e7f:	0f b7 c0             	movzwl %ax,%eax
80109e82:	83 ec 0c             	sub    $0xc,%esp
80109e85:	50                   	push   %eax
80109e86:	e8 5e fc ff ff       	call   80109ae9 <H2N_ushort>
80109e8b:	83 c4 10             	add    $0x10,%esp
80109e8e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e91:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109e95:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e98:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109e9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e9e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ea2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ea5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109ea9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eac:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109eb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109eb3:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109eb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eba:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ec1:	8d 50 08             	lea    0x8(%eax),%edx
80109ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ec7:	83 c0 08             	add    $0x8,%eax
80109eca:	83 ec 04             	sub    $0x4,%esp
80109ecd:	6a 08                	push   $0x8
80109ecf:	52                   	push   %edx
80109ed0:	50                   	push   %eax
80109ed1:	e8 6b b0 ff ff       	call   80104f41 <memmove>
80109ed6:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109edc:	8d 50 10             	lea    0x10(%eax),%edx
80109edf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ee2:	83 c0 10             	add    $0x10,%eax
80109ee5:	83 ec 04             	sub    $0x4,%esp
80109ee8:	6a 30                	push   $0x30
80109eea:	52                   	push   %edx
80109eeb:	50                   	push   %eax
80109eec:	e8 50 b0 ff ff       	call   80104f41 <memmove>
80109ef1:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109ef4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ef7:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109efd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f00:	83 ec 0c             	sub    $0xc,%esp
80109f03:	50                   	push   %eax
80109f04:	e8 1c 00 00 00       	call   80109f25 <icmp_chksum>
80109f09:	83 c4 10             	add    $0x10,%esp
80109f0c:	0f b7 c0             	movzwl %ax,%eax
80109f0f:	83 ec 0c             	sub    $0xc,%esp
80109f12:	50                   	push   %eax
80109f13:	e8 d1 fb ff ff       	call   80109ae9 <H2N_ushort>
80109f18:	83 c4 10             	add    $0x10,%esp
80109f1b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f1e:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109f22:	90                   	nop
80109f23:	c9                   	leave  
80109f24:	c3                   	ret    

80109f25 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109f25:	55                   	push   %ebp
80109f26:	89 e5                	mov    %esp,%ebp
80109f28:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109f31:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109f38:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109f3f:	eb 48                	jmp    80109f89 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109f41:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f44:	01 c0                	add    %eax,%eax
80109f46:	89 c2                	mov    %eax,%edx
80109f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f4b:	01 d0                	add    %edx,%eax
80109f4d:	0f b6 00             	movzbl (%eax),%eax
80109f50:	0f b6 c0             	movzbl %al,%eax
80109f53:	c1 e0 08             	shl    $0x8,%eax
80109f56:	89 c2                	mov    %eax,%edx
80109f58:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f5b:	01 c0                	add    %eax,%eax
80109f5d:	8d 48 01             	lea    0x1(%eax),%ecx
80109f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f63:	01 c8                	add    %ecx,%eax
80109f65:	0f b6 00             	movzbl (%eax),%eax
80109f68:	0f b6 c0             	movzbl %al,%eax
80109f6b:	01 d0                	add    %edx,%eax
80109f6d:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109f70:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109f77:	76 0c                	jbe    80109f85 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109f79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f7c:	0f b7 c0             	movzwl %ax,%eax
80109f7f:	83 c0 01             	add    $0x1,%eax
80109f82:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109f85:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109f89:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109f8d:	7e b2                	jle    80109f41 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109f8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f92:	f7 d0                	not    %eax
}
80109f94:	c9                   	leave  
80109f95:	c3                   	ret    

80109f96 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109f96:	55                   	push   %ebp
80109f97:	89 e5                	mov    %esp,%ebp
80109f99:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80109f9f:	83 c0 0e             	add    $0xe,%eax
80109fa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fa8:	0f b6 00             	movzbl (%eax),%eax
80109fab:	0f b6 c0             	movzbl %al,%eax
80109fae:	83 e0 0f             	and    $0xf,%eax
80109fb1:	c1 e0 02             	shl    $0x2,%eax
80109fb4:	89 c2                	mov    %eax,%edx
80109fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fb9:	01 d0                	add    %edx,%eax
80109fbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fc1:	83 c0 14             	add    $0x14,%eax
80109fc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109fc7:	e8 d4 87 ff ff       	call   801027a0 <kalloc>
80109fcc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109fcf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fd9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109fdd:	0f b6 c0             	movzbl %al,%eax
80109fe0:	83 e0 02             	and    $0x2,%eax
80109fe3:	85 c0                	test   %eax,%eax
80109fe5:	74 3d                	je     8010a024 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109fe7:	83 ec 0c             	sub    $0xc,%esp
80109fea:	6a 00                	push   $0x0
80109fec:	6a 12                	push   $0x12
80109fee:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ff1:	50                   	push   %eax
80109ff2:	ff 75 e8             	push   -0x18(%ebp)
80109ff5:	ff 75 08             	push   0x8(%ebp)
80109ff8:	e8 a2 01 00 00       	call   8010a19f <tcp_pkt_create>
80109ffd:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a000:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a003:	83 ec 08             	sub    $0x8,%esp
8010a006:	50                   	push   %eax
8010a007:	ff 75 e8             	push   -0x18(%ebp)
8010a00a:	e8 61 f1 ff ff       	call   80109170 <i8254_send>
8010a00f:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a012:	a1 a4 7c 19 80       	mov    0x80197ca4,%eax
8010a017:	83 c0 01             	add    $0x1,%eax
8010a01a:	a3 a4 7c 19 80       	mov    %eax,0x80197ca4
8010a01f:	e9 69 01 00 00       	jmp    8010a18d <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a024:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a027:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a02b:	3c 18                	cmp    $0x18,%al
8010a02d:	0f 85 10 01 00 00    	jne    8010a143 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a033:	83 ec 04             	sub    $0x4,%esp
8010a036:	6a 03                	push   $0x3
8010a038:	68 3e c6 10 80       	push   $0x8010c63e
8010a03d:	ff 75 ec             	push   -0x14(%ebp)
8010a040:	e8 a4 ae ff ff       	call   80104ee9 <memcmp>
8010a045:	83 c4 10             	add    $0x10,%esp
8010a048:	85 c0                	test   %eax,%eax
8010a04a:	74 74                	je     8010a0c0 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a04c:	83 ec 0c             	sub    $0xc,%esp
8010a04f:	68 42 c6 10 80       	push   $0x8010c642
8010a054:	e8 9b 63 ff ff       	call   801003f4 <cprintf>
8010a059:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a05c:	83 ec 0c             	sub    $0xc,%esp
8010a05f:	6a 00                	push   $0x0
8010a061:	6a 10                	push   $0x10
8010a063:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a066:	50                   	push   %eax
8010a067:	ff 75 e8             	push   -0x18(%ebp)
8010a06a:	ff 75 08             	push   0x8(%ebp)
8010a06d:	e8 2d 01 00 00       	call   8010a19f <tcp_pkt_create>
8010a072:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a075:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a078:	83 ec 08             	sub    $0x8,%esp
8010a07b:	50                   	push   %eax
8010a07c:	ff 75 e8             	push   -0x18(%ebp)
8010a07f:	e8 ec f0 ff ff       	call   80109170 <i8254_send>
8010a084:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a087:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a08a:	83 c0 36             	add    $0x36,%eax
8010a08d:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a090:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a093:	50                   	push   %eax
8010a094:	ff 75 e0             	push   -0x20(%ebp)
8010a097:	6a 00                	push   $0x0
8010a099:	6a 00                	push   $0x0
8010a09b:	e8 5a 04 00 00       	call   8010a4fa <http_proc>
8010a0a0:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a0a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a0a6:	83 ec 0c             	sub    $0xc,%esp
8010a0a9:	50                   	push   %eax
8010a0aa:	6a 18                	push   $0x18
8010a0ac:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0af:	50                   	push   %eax
8010a0b0:	ff 75 e8             	push   -0x18(%ebp)
8010a0b3:	ff 75 08             	push   0x8(%ebp)
8010a0b6:	e8 e4 00 00 00       	call   8010a19f <tcp_pkt_create>
8010a0bb:	83 c4 20             	add    $0x20,%esp
8010a0be:	eb 62                	jmp    8010a122 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a0c0:	83 ec 0c             	sub    $0xc,%esp
8010a0c3:	6a 00                	push   $0x0
8010a0c5:	6a 10                	push   $0x10
8010a0c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0ca:	50                   	push   %eax
8010a0cb:	ff 75 e8             	push   -0x18(%ebp)
8010a0ce:	ff 75 08             	push   0x8(%ebp)
8010a0d1:	e8 c9 00 00 00       	call   8010a19f <tcp_pkt_create>
8010a0d6:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a0d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0dc:	83 ec 08             	sub    $0x8,%esp
8010a0df:	50                   	push   %eax
8010a0e0:	ff 75 e8             	push   -0x18(%ebp)
8010a0e3:	e8 88 f0 ff ff       	call   80109170 <i8254_send>
8010a0e8:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a0eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0ee:	83 c0 36             	add    $0x36,%eax
8010a0f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a0f4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a0f7:	50                   	push   %eax
8010a0f8:	ff 75 e4             	push   -0x1c(%ebp)
8010a0fb:	6a 00                	push   $0x0
8010a0fd:	6a 00                	push   $0x0
8010a0ff:	e8 f6 03 00 00       	call   8010a4fa <http_proc>
8010a104:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a107:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a10a:	83 ec 0c             	sub    $0xc,%esp
8010a10d:	50                   	push   %eax
8010a10e:	6a 18                	push   $0x18
8010a110:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a113:	50                   	push   %eax
8010a114:	ff 75 e8             	push   -0x18(%ebp)
8010a117:	ff 75 08             	push   0x8(%ebp)
8010a11a:	e8 80 00 00 00       	call   8010a19f <tcp_pkt_create>
8010a11f:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a122:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a125:	83 ec 08             	sub    $0x8,%esp
8010a128:	50                   	push   %eax
8010a129:	ff 75 e8             	push   -0x18(%ebp)
8010a12c:	e8 3f f0 ff ff       	call   80109170 <i8254_send>
8010a131:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a134:	a1 a4 7c 19 80       	mov    0x80197ca4,%eax
8010a139:	83 c0 01             	add    $0x1,%eax
8010a13c:	a3 a4 7c 19 80       	mov    %eax,0x80197ca4
8010a141:	eb 4a                	jmp    8010a18d <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a143:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a146:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a14a:	3c 10                	cmp    $0x10,%al
8010a14c:	75 3f                	jne    8010a18d <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a14e:	a1 a8 7c 19 80       	mov    0x80197ca8,%eax
8010a153:	83 f8 01             	cmp    $0x1,%eax
8010a156:	75 35                	jne    8010a18d <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a158:	83 ec 0c             	sub    $0xc,%esp
8010a15b:	6a 00                	push   $0x0
8010a15d:	6a 01                	push   $0x1
8010a15f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a162:	50                   	push   %eax
8010a163:	ff 75 e8             	push   -0x18(%ebp)
8010a166:	ff 75 08             	push   0x8(%ebp)
8010a169:	e8 31 00 00 00       	call   8010a19f <tcp_pkt_create>
8010a16e:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a171:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a174:	83 ec 08             	sub    $0x8,%esp
8010a177:	50                   	push   %eax
8010a178:	ff 75 e8             	push   -0x18(%ebp)
8010a17b:	e8 f0 ef ff ff       	call   80109170 <i8254_send>
8010a180:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a183:	c7 05 a8 7c 19 80 00 	movl   $0x0,0x80197ca8
8010a18a:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a18d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a190:	83 ec 0c             	sub    $0xc,%esp
8010a193:	50                   	push   %eax
8010a194:	e8 6d 85 ff ff       	call   80102706 <kfree>
8010a199:	83 c4 10             	add    $0x10,%esp
}
8010a19c:	90                   	nop
8010a19d:	c9                   	leave  
8010a19e:	c3                   	ret    

8010a19f <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a19f:	55                   	push   %ebp
8010a1a0:	89 e5                	mov    %esp,%ebp
8010a1a2:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a1a5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a1ab:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ae:	83 c0 0e             	add    $0xe,%eax
8010a1b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a1b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1b7:	0f b6 00             	movzbl (%eax),%eax
8010a1ba:	0f b6 c0             	movzbl %al,%eax
8010a1bd:	83 e0 0f             	and    $0xf,%eax
8010a1c0:	c1 e0 02             	shl    $0x2,%eax
8010a1c3:	89 c2                	mov    %eax,%edx
8010a1c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1c8:	01 d0                	add    %edx,%eax
8010a1ca:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a1cd:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a1d3:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1d6:	83 c0 0e             	add    $0xe,%eax
8010a1d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a1dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1df:	83 c0 14             	add    $0x14,%eax
8010a1e2:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a1e5:	8b 45 18             	mov    0x18(%ebp),%eax
8010a1e8:	8d 50 36             	lea    0x36(%eax),%edx
8010a1eb:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1ee:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a1f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1f3:	8d 50 06             	lea    0x6(%eax),%edx
8010a1f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1f9:	83 ec 04             	sub    $0x4,%esp
8010a1fc:	6a 06                	push   $0x6
8010a1fe:	52                   	push   %edx
8010a1ff:	50                   	push   %eax
8010a200:	e8 3c ad ff ff       	call   80104f41 <memmove>
8010a205:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a208:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a20b:	83 c0 06             	add    $0x6,%eax
8010a20e:	83 ec 04             	sub    $0x4,%esp
8010a211:	6a 06                	push   $0x6
8010a213:	68 d0 79 19 80       	push   $0x801979d0
8010a218:	50                   	push   %eax
8010a219:	e8 23 ad ff ff       	call   80104f41 <memmove>
8010a21e:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a221:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a224:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a228:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a22b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a22f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a232:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a235:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a238:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a23c:	8b 45 18             	mov    0x18(%ebp),%eax
8010a23f:	83 c0 28             	add    $0x28,%eax
8010a242:	0f b7 c0             	movzwl %ax,%eax
8010a245:	83 ec 0c             	sub    $0xc,%esp
8010a248:	50                   	push   %eax
8010a249:	e8 9b f8 ff ff       	call   80109ae9 <H2N_ushort>
8010a24e:	83 c4 10             	add    $0x10,%esp
8010a251:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a254:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a258:	0f b7 15 a0 7c 19 80 	movzwl 0x80197ca0,%edx
8010a25f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a262:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a266:	0f b7 05 a0 7c 19 80 	movzwl 0x80197ca0,%eax
8010a26d:	83 c0 01             	add    $0x1,%eax
8010a270:	66 a3 a0 7c 19 80    	mov    %ax,0x80197ca0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a276:	83 ec 0c             	sub    $0xc,%esp
8010a279:	6a 00                	push   $0x0
8010a27b:	e8 69 f8 ff ff       	call   80109ae9 <H2N_ushort>
8010a280:	83 c4 10             	add    $0x10,%esp
8010a283:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a286:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a28a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a28d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a291:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a294:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a298:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a29b:	83 c0 0c             	add    $0xc,%eax
8010a29e:	83 ec 04             	sub    $0x4,%esp
8010a2a1:	6a 04                	push   $0x4
8010a2a3:	68 04 f5 10 80       	push   $0x8010f504
8010a2a8:	50                   	push   %eax
8010a2a9:	e8 93 ac ff ff       	call   80104f41 <memmove>
8010a2ae:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a2b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2b4:	8d 50 0c             	lea    0xc(%eax),%edx
8010a2b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ba:	83 c0 10             	add    $0x10,%eax
8010a2bd:	83 ec 04             	sub    $0x4,%esp
8010a2c0:	6a 04                	push   $0x4
8010a2c2:	52                   	push   %edx
8010a2c3:	50                   	push   %eax
8010a2c4:	e8 78 ac ff ff       	call   80104f41 <memmove>
8010a2c9:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a2cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2cf:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a2d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2d8:	83 ec 0c             	sub    $0xc,%esp
8010a2db:	50                   	push   %eax
8010a2dc:	e8 08 f9 ff ff       	call   80109be9 <ipv4_chksum>
8010a2e1:	83 c4 10             	add    $0x10,%esp
8010a2e4:	0f b7 c0             	movzwl %ax,%eax
8010a2e7:	83 ec 0c             	sub    $0xc,%esp
8010a2ea:	50                   	push   %eax
8010a2eb:	e8 f9 f7 ff ff       	call   80109ae9 <H2N_ushort>
8010a2f0:	83 c4 10             	add    $0x10,%esp
8010a2f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2f6:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a2fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2fd:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a301:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a304:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a30a:	0f b7 10             	movzwl (%eax),%edx
8010a30d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a310:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a314:	a1 a4 7c 19 80       	mov    0x80197ca4,%eax
8010a319:	83 ec 0c             	sub    $0xc,%esp
8010a31c:	50                   	push   %eax
8010a31d:	e8 e9 f7 ff ff       	call   80109b0b <H2N_uint>
8010a322:	83 c4 10             	add    $0x10,%esp
8010a325:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a328:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a32b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a32e:	8b 40 04             	mov    0x4(%eax),%eax
8010a331:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a337:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a33a:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a33d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a340:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a344:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a347:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a34b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a34e:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a352:	8b 45 14             	mov    0x14(%ebp),%eax
8010a355:	89 c2                	mov    %eax,%edx
8010a357:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a35a:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a35d:	83 ec 0c             	sub    $0xc,%esp
8010a360:	68 90 38 00 00       	push   $0x3890
8010a365:	e8 7f f7 ff ff       	call   80109ae9 <H2N_ushort>
8010a36a:	83 c4 10             	add    $0x10,%esp
8010a36d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a370:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a374:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a377:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a37d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a380:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a386:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a389:	83 ec 0c             	sub    $0xc,%esp
8010a38c:	50                   	push   %eax
8010a38d:	e8 1f 00 00 00       	call   8010a3b1 <tcp_chksum>
8010a392:	83 c4 10             	add    $0x10,%esp
8010a395:	83 c0 08             	add    $0x8,%eax
8010a398:	0f b7 c0             	movzwl %ax,%eax
8010a39b:	83 ec 0c             	sub    $0xc,%esp
8010a39e:	50                   	push   %eax
8010a39f:	e8 45 f7 ff ff       	call   80109ae9 <H2N_ushort>
8010a3a4:	83 c4 10             	add    $0x10,%esp
8010a3a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3aa:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a3ae:	90                   	nop
8010a3af:	c9                   	leave  
8010a3b0:	c3                   	ret    

8010a3b1 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a3b1:	55                   	push   %ebp
8010a3b2:	89 e5                	mov    %esp,%ebp
8010a3b4:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a3b7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a3bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3c0:	83 c0 14             	add    $0x14,%eax
8010a3c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a3c6:	83 ec 04             	sub    $0x4,%esp
8010a3c9:	6a 04                	push   $0x4
8010a3cb:	68 04 f5 10 80       	push   $0x8010f504
8010a3d0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a3d3:	50                   	push   %eax
8010a3d4:	e8 68 ab ff ff       	call   80104f41 <memmove>
8010a3d9:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a3dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3df:	83 c0 0c             	add    $0xc,%eax
8010a3e2:	83 ec 04             	sub    $0x4,%esp
8010a3e5:	6a 04                	push   $0x4
8010a3e7:	50                   	push   %eax
8010a3e8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a3eb:	83 c0 04             	add    $0x4,%eax
8010a3ee:	50                   	push   %eax
8010a3ef:	e8 4d ab ff ff       	call   80104f41 <memmove>
8010a3f4:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a3f7:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a3fb:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a3ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a402:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a406:	0f b7 c0             	movzwl %ax,%eax
8010a409:	83 ec 0c             	sub    $0xc,%esp
8010a40c:	50                   	push   %eax
8010a40d:	e8 b5 f6 ff ff       	call   80109ac7 <N2H_ushort>
8010a412:	83 c4 10             	add    $0x10,%esp
8010a415:	83 e8 14             	sub    $0x14,%eax
8010a418:	0f b7 c0             	movzwl %ax,%eax
8010a41b:	83 ec 0c             	sub    $0xc,%esp
8010a41e:	50                   	push   %eax
8010a41f:	e8 c5 f6 ff ff       	call   80109ae9 <H2N_ushort>
8010a424:	83 c4 10             	add    $0x10,%esp
8010a427:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a42b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a432:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a435:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a438:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a43f:	eb 33                	jmp    8010a474 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a441:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a444:	01 c0                	add    %eax,%eax
8010a446:	89 c2                	mov    %eax,%edx
8010a448:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a44b:	01 d0                	add    %edx,%eax
8010a44d:	0f b6 00             	movzbl (%eax),%eax
8010a450:	0f b6 c0             	movzbl %al,%eax
8010a453:	c1 e0 08             	shl    $0x8,%eax
8010a456:	89 c2                	mov    %eax,%edx
8010a458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a45b:	01 c0                	add    %eax,%eax
8010a45d:	8d 48 01             	lea    0x1(%eax),%ecx
8010a460:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a463:	01 c8                	add    %ecx,%eax
8010a465:	0f b6 00             	movzbl (%eax),%eax
8010a468:	0f b6 c0             	movzbl %al,%eax
8010a46b:	01 d0                	add    %edx,%eax
8010a46d:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a470:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a474:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a478:	7e c7                	jle    8010a441 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a47a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a47d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a480:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a487:	eb 33                	jmp    8010a4bc <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a489:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a48c:	01 c0                	add    %eax,%eax
8010a48e:	89 c2                	mov    %eax,%edx
8010a490:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a493:	01 d0                	add    %edx,%eax
8010a495:	0f b6 00             	movzbl (%eax),%eax
8010a498:	0f b6 c0             	movzbl %al,%eax
8010a49b:	c1 e0 08             	shl    $0x8,%eax
8010a49e:	89 c2                	mov    %eax,%edx
8010a4a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4a3:	01 c0                	add    %eax,%eax
8010a4a5:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4ab:	01 c8                	add    %ecx,%eax
8010a4ad:	0f b6 00             	movzbl (%eax),%eax
8010a4b0:	0f b6 c0             	movzbl %al,%eax
8010a4b3:	01 d0                	add    %edx,%eax
8010a4b5:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a4b8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a4bc:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a4c0:	0f b7 c0             	movzwl %ax,%eax
8010a4c3:	83 ec 0c             	sub    $0xc,%esp
8010a4c6:	50                   	push   %eax
8010a4c7:	e8 fb f5 ff ff       	call   80109ac7 <N2H_ushort>
8010a4cc:	83 c4 10             	add    $0x10,%esp
8010a4cf:	66 d1 e8             	shr    %ax
8010a4d2:	0f b7 c0             	movzwl %ax,%eax
8010a4d5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a4d8:	7c af                	jl     8010a489 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a4da:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4dd:	c1 e8 10             	shr    $0x10,%eax
8010a4e0:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a4e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4e6:	f7 d0                	not    %eax
}
8010a4e8:	c9                   	leave  
8010a4e9:	c3                   	ret    

8010a4ea <tcp_fin>:

void tcp_fin(){
8010a4ea:	55                   	push   %ebp
8010a4eb:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a4ed:	c7 05 a8 7c 19 80 01 	movl   $0x1,0x80197ca8
8010a4f4:	00 00 00 
}
8010a4f7:	90                   	nop
8010a4f8:	5d                   	pop    %ebp
8010a4f9:	c3                   	ret    

8010a4fa <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a4fa:	55                   	push   %ebp
8010a4fb:	89 e5                	mov    %esp,%ebp
8010a4fd:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a500:	8b 45 10             	mov    0x10(%ebp),%eax
8010a503:	83 ec 04             	sub    $0x4,%esp
8010a506:	6a 00                	push   $0x0
8010a508:	68 4b c6 10 80       	push   $0x8010c64b
8010a50d:	50                   	push   %eax
8010a50e:	e8 65 00 00 00       	call   8010a578 <http_strcpy>
8010a513:	83 c4 10             	add    $0x10,%esp
8010a516:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a519:	8b 45 10             	mov    0x10(%ebp),%eax
8010a51c:	83 ec 04             	sub    $0x4,%esp
8010a51f:	ff 75 f4             	push   -0xc(%ebp)
8010a522:	68 5e c6 10 80       	push   $0x8010c65e
8010a527:	50                   	push   %eax
8010a528:	e8 4b 00 00 00       	call   8010a578 <http_strcpy>
8010a52d:	83 c4 10             	add    $0x10,%esp
8010a530:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a533:	8b 45 10             	mov    0x10(%ebp),%eax
8010a536:	83 ec 04             	sub    $0x4,%esp
8010a539:	ff 75 f4             	push   -0xc(%ebp)
8010a53c:	68 79 c6 10 80       	push   $0x8010c679
8010a541:	50                   	push   %eax
8010a542:	e8 31 00 00 00       	call   8010a578 <http_strcpy>
8010a547:	83 c4 10             	add    $0x10,%esp
8010a54a:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a54d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a550:	83 e0 01             	and    $0x1,%eax
8010a553:	85 c0                	test   %eax,%eax
8010a555:	74 11                	je     8010a568 <http_proc+0x6e>
    char *payload = (char *)send;
8010a557:	8b 45 10             	mov    0x10(%ebp),%eax
8010a55a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a55d:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a560:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a563:	01 d0                	add    %edx,%eax
8010a565:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a568:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a56b:	8b 45 14             	mov    0x14(%ebp),%eax
8010a56e:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a570:	e8 75 ff ff ff       	call   8010a4ea <tcp_fin>
}
8010a575:	90                   	nop
8010a576:	c9                   	leave  
8010a577:	c3                   	ret    

8010a578 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a578:	55                   	push   %ebp
8010a579:	89 e5                	mov    %esp,%ebp
8010a57b:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a57e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a585:	eb 20                	jmp    8010a5a7 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a587:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a58a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a58d:	01 d0                	add    %edx,%eax
8010a58f:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a592:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a595:	01 ca                	add    %ecx,%edx
8010a597:	89 d1                	mov    %edx,%ecx
8010a599:	8b 55 08             	mov    0x8(%ebp),%edx
8010a59c:	01 ca                	add    %ecx,%edx
8010a59e:	0f b6 00             	movzbl (%eax),%eax
8010a5a1:	88 02                	mov    %al,(%edx)
    i++;
8010a5a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a5a7:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5aa:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5ad:	01 d0                	add    %edx,%eax
8010a5af:	0f b6 00             	movzbl (%eax),%eax
8010a5b2:	84 c0                	test   %al,%al
8010a5b4:	75 d1                	jne    8010a587 <http_strcpy+0xf>
  }
  return i;
8010a5b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a5b9:	c9                   	leave  
8010a5ba:	c3                   	ret    

8010a5bb <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a5bb:	55                   	push   %ebp
8010a5bc:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a5be:	c7 05 b0 7c 19 80 c2 	movl   $0x8010f5c2,0x80197cb0
8010a5c5:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a5c8:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a5cd:	c1 e8 09             	shr    $0x9,%eax
8010a5d0:	a3 ac 7c 19 80       	mov    %eax,0x80197cac
}
8010a5d5:	90                   	nop
8010a5d6:	5d                   	pop    %ebp
8010a5d7:	c3                   	ret    

8010a5d8 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a5d8:	55                   	push   %ebp
8010a5d9:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a5db:	90                   	nop
8010a5dc:	5d                   	pop    %ebp
8010a5dd:	c3                   	ret    

8010a5de <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a5de:	55                   	push   %ebp
8010a5df:	89 e5                	mov    %esp,%ebp
8010a5e1:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a5e4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5e7:	83 c0 0c             	add    $0xc,%eax
8010a5ea:	83 ec 0c             	sub    $0xc,%esp
8010a5ed:	50                   	push   %eax
8010a5ee:	e8 88 a5 ff ff       	call   80104b7b <holdingsleep>
8010a5f3:	83 c4 10             	add    $0x10,%esp
8010a5f6:	85 c0                	test   %eax,%eax
8010a5f8:	75 0d                	jne    8010a607 <iderw+0x29>
    panic("iderw: buf not locked");
8010a5fa:	83 ec 0c             	sub    $0xc,%esp
8010a5fd:	68 8a c6 10 80       	push   $0x8010c68a
8010a602:	e8 a2 5f ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a607:	8b 45 08             	mov    0x8(%ebp),%eax
8010a60a:	8b 00                	mov    (%eax),%eax
8010a60c:	83 e0 06             	and    $0x6,%eax
8010a60f:	83 f8 02             	cmp    $0x2,%eax
8010a612:	75 0d                	jne    8010a621 <iderw+0x43>
    panic("iderw: nothing to do");
8010a614:	83 ec 0c             	sub    $0xc,%esp
8010a617:	68 a0 c6 10 80       	push   $0x8010c6a0
8010a61c:	e8 88 5f ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a621:	8b 45 08             	mov    0x8(%ebp),%eax
8010a624:	8b 40 04             	mov    0x4(%eax),%eax
8010a627:	83 f8 01             	cmp    $0x1,%eax
8010a62a:	74 0d                	je     8010a639 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a62c:	83 ec 0c             	sub    $0xc,%esp
8010a62f:	68 b5 c6 10 80       	push   $0x8010c6b5
8010a634:	e8 70 5f ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a639:	8b 45 08             	mov    0x8(%ebp),%eax
8010a63c:	8b 40 08             	mov    0x8(%eax),%eax
8010a63f:	8b 15 ac 7c 19 80    	mov    0x80197cac,%edx
8010a645:	39 d0                	cmp    %edx,%eax
8010a647:	72 0d                	jb     8010a656 <iderw+0x78>
    panic("iderw: block out of range");
8010a649:	83 ec 0c             	sub    $0xc,%esp
8010a64c:	68 d3 c6 10 80       	push   $0x8010c6d3
8010a651:	e8 53 5f ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a656:	8b 15 b0 7c 19 80    	mov    0x80197cb0,%edx
8010a65c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a65f:	8b 40 08             	mov    0x8(%eax),%eax
8010a662:	c1 e0 09             	shl    $0x9,%eax
8010a665:	01 d0                	add    %edx,%eax
8010a667:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a66a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a66d:	8b 00                	mov    (%eax),%eax
8010a66f:	83 e0 04             	and    $0x4,%eax
8010a672:	85 c0                	test   %eax,%eax
8010a674:	74 2b                	je     8010a6a1 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a676:	8b 45 08             	mov    0x8(%ebp),%eax
8010a679:	8b 00                	mov    (%eax),%eax
8010a67b:	83 e0 fb             	and    $0xfffffffb,%eax
8010a67e:	89 c2                	mov    %eax,%edx
8010a680:	8b 45 08             	mov    0x8(%ebp),%eax
8010a683:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a685:	8b 45 08             	mov    0x8(%ebp),%eax
8010a688:	83 c0 5c             	add    $0x5c,%eax
8010a68b:	83 ec 04             	sub    $0x4,%esp
8010a68e:	68 00 02 00 00       	push   $0x200
8010a693:	50                   	push   %eax
8010a694:	ff 75 f4             	push   -0xc(%ebp)
8010a697:	e8 a5 a8 ff ff       	call   80104f41 <memmove>
8010a69c:	83 c4 10             	add    $0x10,%esp
8010a69f:	eb 1a                	jmp    8010a6bb <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a6a1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6a4:	83 c0 5c             	add    $0x5c,%eax
8010a6a7:	83 ec 04             	sub    $0x4,%esp
8010a6aa:	68 00 02 00 00       	push   $0x200
8010a6af:	ff 75 f4             	push   -0xc(%ebp)
8010a6b2:	50                   	push   %eax
8010a6b3:	e8 89 a8 ff ff       	call   80104f41 <memmove>
8010a6b8:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a6bb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6be:	8b 00                	mov    (%eax),%eax
8010a6c0:	83 c8 02             	or     $0x2,%eax
8010a6c3:	89 c2                	mov    %eax,%edx
8010a6c5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6c8:	89 10                	mov    %edx,(%eax)
}
8010a6ca:	90                   	nop
8010a6cb:	c9                   	leave  
8010a6cc:	c3                   	ret    
