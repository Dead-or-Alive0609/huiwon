
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
8010005a:	bc 80 88 19 80       	mov    $0x80198880,%esp
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
8010006f:	68 e0 a4 10 80       	push   $0x8010a4e0
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 7e 4a 00 00       	call   80104afc <initlock>
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
801000bd:	68 e7 a4 10 80       	push   $0x8010a4e7
801000c2:	50                   	push   %eax
801000c3:	e8 d7 48 00 00       	call   8010499f <initsleeplock>
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
80100101:	e8 18 4a 00 00       	call   80104b1e <acquire>
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
80100140:	e8 47 4a 00 00       	call   80104b8c <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 84 48 00 00       	call   801049db <acquiresleep>
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
801001c1:	e8 c6 49 00 00       	call   80104b8c <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 03 48 00 00       	call   801049db <acquiresleep>
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
801001f5:	68 ee a4 10 80       	push   $0x8010a4ee
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
8010022d:	e8 b0 a1 00 00       	call   8010a3e2 <iderw>
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
8010024a:	e8 3e 48 00 00       	call   80104a8d <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 ff a4 10 80       	push   $0x8010a4ff
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
80100278:	e8 65 a1 00 00       	call   8010a3e2 <iderw>
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
80100293:	e8 f5 47 00 00       	call   80104a8d <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 06 a5 10 80       	push   $0x8010a506
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 84 47 00 00       	call   80104a3f <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 53 48 00 00       	call   80104b1e <acquire>
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
80100336:	e8 51 48 00 00       	call   80104b8c <release>
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
80100410:	e8 09 47 00 00       	call   80104b1e <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 0d a5 10 80       	push   $0x8010a50d
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
80100510:	c7 45 ec 16 a5 10 80 	movl   $0x8010a516,-0x14(%ebp)
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
8010059e:	e8 e9 45 00 00       	call   80104b8c <release>
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
801005c7:	68 1d a5 10 80       	push   $0x8010a51d
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
801005e6:	68 31 a5 10 80       	push   $0x8010a531
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 db 45 00 00       	call   80104bde <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 33 a5 10 80       	push   $0x8010a533
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
801006a0:	e8 94 7c 00 00       	call   80108339 <graphic_scroll_up>
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
801006f3:	e8 41 7c 00 00       	call   80108339 <graphic_scroll_up>
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
80100757:	e8 48 7c 00 00       	call   801083a4 <font_render>
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
80100793:	e8 18 60 00 00       	call   801067b0 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 0b 60 00 00       	call   801067b0 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 fe 5f 00 00       	call   801067b0 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 ee 5f 00 00       	call   801067b0 <uartputc>
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
801007eb:	e8 2e 43 00 00       	call   80104b1e <acquire>
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
8010093f:	e8 53 3d 00 00       	call   80104697 <wakeup>
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
80100962:	e8 25 42 00 00       	call   80104b8c <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 e0 3d 00 00       	call   80104755 <procdump>
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
8010099a:	e8 7f 41 00 00       	call   80104b1e <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 84 30 00 00       	call   80103a30 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 cc 41 00 00       	call   80104b8c <release>
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
801009e8:	e8 c0 3b 00 00       	call   801045ad <sleep>
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
80100a66:	e8 21 41 00 00       	call   80104b8c <release>
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
80100aa2:	e8 77 40 00 00       	call   80104b1e <acquire>
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
80100ae4:	e8 a3 40 00 00       	call   80104b8c <release>
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
80100b12:	68 37 a5 10 80       	push   $0x8010a537
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 db 3f 00 00       	call   80104afc <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 3f a5 10 80 	movl   $0x8010a53f,-0xc(%ebp)
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
80100b89:	e8 a2 2e 00 00       	call   80103a30 <myproc>
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
80100bb5:	68 55 a5 10 80       	push   $0x8010a555
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
80100c11:	e8 96 6b 00 00       	call   801077ac <setupkvm>
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
80100cb7:	e8 e9 6e 00 00       	call   80107ba5 <allocuvm>
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
80100cfd:	e8 d6 6d 00 00       	call   80107ad8 <loaduvm>
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
80100d6c:	e8 34 6e 00 00       	call   80107ba5 <allocuvm>
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
80100d90:	e8 72 70 00 00       	call   80107e07 <clearpteu>
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
80100dc9:	e8 14 42 00 00       	call   80104fe2 <strlen>
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
80100df6:	e8 e7 41 00 00       	call   80104fe2 <strlen>
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
80100e1c:	e8 85 71 00 00       	call   80107fa6 <copyout>
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
80100eb8:	e8 e9 70 00 00       	call   80107fa6 <copyout>
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
80100f06:	e8 8c 40 00 00       	call   80104f97 <safestrcpy>
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
80100f49:	e8 7b 69 00 00       	call   801078c9 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 12 6e 00 00       	call   80107d6e <freevm>
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
80100f97:	e8 d2 6d 00 00       	call   80107d6e <freevm>
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
80100fc8:	68 61 a5 10 80       	push   $0x8010a561
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 25 3b 00 00       	call   80104afc <initlock>
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
80100feb:	e8 2e 3b 00 00       	call   80104b1e <acquire>
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
80101018:	e8 6f 3b 00 00       	call   80104b8c <release>
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
8010103b:	e8 4c 3b 00 00       	call   80104b8c <release>
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
80101058:	e8 c1 3a 00 00       	call   80104b1e <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 68 a5 10 80       	push   $0x8010a568
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
8010108e:	e8 f9 3a 00 00       	call   80104b8c <release>
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
801010a9:	e8 70 3a 00 00       	call   80104b1e <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 70 a5 10 80       	push   $0x8010a570
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
801010e9:	e8 9e 3a 00 00       	call   80104b8c <release>
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
80101137:	e8 50 3a 00 00       	call   80104b8c <release>
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
80101286:	68 7a a5 10 80       	push   $0x8010a57a
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
80101389:	68 83 a5 10 80       	push   $0x8010a583
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
801013bf:	68 93 a5 10 80       	push   $0x8010a593
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
801013f7:	e8 57 3a 00 00       	call   80104e53 <memmove>
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
8010143d:	e8 52 39 00 00       	call   80104d94 <memset>
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
8010159c:	68 a0 a5 10 80       	push   $0x8010a5a0
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
80101627:	68 b6 a5 10 80       	push   $0x8010a5b6
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
8010168b:	68 c9 a5 10 80       	push   $0x8010a5c9
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 62 34 00 00       	call   80104afc <initlock>
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
801016c1:	68 d0 a5 10 80       	push   $0x8010a5d0
801016c6:	50                   	push   %eax
801016c7:	e8 d3 32 00 00       	call   8010499f <initsleeplock>
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
80101720:	68 d8 a5 10 80       	push   $0x8010a5d8
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
80101799:	e8 f6 35 00 00       	call   80104d94 <memset>
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
80101801:	68 2b a6 10 80       	push   $0x8010a62b
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
801018a7:	e8 a7 35 00 00       	call   80104e53 <memmove>
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
801018dc:	e8 3d 32 00 00       	call   80104b1e <acquire>
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
8010192a:	e8 5d 32 00 00       	call   80104b8c <release>
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
80101966:	68 3d a6 10 80       	push   $0x8010a63d
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
801019a3:	e8 e4 31 00 00       	call   80104b8c <release>
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
801019be:	e8 5b 31 00 00       	call   80104b1e <acquire>
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
801019dd:	e8 aa 31 00 00       	call   80104b8c <release>
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
80101a03:	68 4d a6 10 80       	push   $0x8010a64d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 bf 2f 00 00       	call   801049db <acquiresleep>
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
80101ac1:	e8 8d 33 00 00       	call   80104e53 <memmove>
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
80101af0:	68 53 a6 10 80       	push   $0x8010a653
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
80101b13:	e8 75 2f 00 00       	call   80104a8d <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 62 a6 10 80       	push   $0x8010a662
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 fa 2e 00 00       	call   80104a3f <releasesleep>
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
80101b5b:	e8 7b 2e 00 00       	call   801049db <acquiresleep>
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
80101b81:	e8 98 2f 00 00       	call   80104b1e <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 ed 2f 00 00       	call   80104b8c <release>
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
80101be1:	e8 59 2e 00 00       	call   80104a3f <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 28 2f 00 00       	call   80104b1e <acquire>
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
80101c10:	e8 77 2f 00 00       	call   80104b8c <release>
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
80101d54:	68 6a a6 10 80       	push   $0x8010a66a
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
80101ff2:	e8 5c 2e 00 00       	call   80104e53 <memmove>
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
80102142:	e8 0c 2d 00 00       	call   80104e53 <memmove>
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
801021c2:	e8 22 2d 00 00       	call   80104ee9 <strncmp>
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
801021e2:	68 7d a6 10 80       	push   $0x8010a67d
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
80102211:	68 8f a6 10 80       	push   $0x8010a68f
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
801022e6:	68 9e a6 10 80       	push   $0x8010a69e
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
80102321:	e8 19 2c 00 00       	call   80104f3f <strncpy>
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
8010234d:	68 ab a6 10 80       	push   $0x8010a6ab
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
801023bf:	e8 8f 2a 00 00       	call   80104e53 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 78 2a 00 00       	call   80104e53 <memmove>
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
80102425:	e8 06 16 00 00       	call   80103a30 <myproc>
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
801025bb:	0f b6 05 54 75 19 80 	movzbl 0x80197554,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 b4 a6 10 80       	push   $0x8010a6b4
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
80102674:	68 e6 a6 10 80       	push   $0x8010a6e6
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 79 24 00 00       	call   80104afc <initlock>
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
80102733:	68 eb a6 10 80       	push   $0x8010a6eb
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 45 26 00 00       	call   80104d94 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 b6 23 00 00       	call   80104b1e <acquire>
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
80102795:	e8 f2 23 00 00       	call   80104b8c <release>
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
801027b7:	e8 62 23 00 00       	call   80104b1e <acquire>
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
801027e8:	e8 9f 23 00 00       	call   80104b8c <release>
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
80102d12:	e8 e4 20 00 00       	call   80104dfb <memcmp>
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
80102e26:	68 f1 a6 10 80       	push   $0x8010a6f1
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 c7 1c 00 00       	call   80104afc <initlock>
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
80102edb:	e8 73 1f 00 00       	call   80104e53 <memmove>
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
8010304a:	e8 cf 1a 00 00       	call   80104b1e <acquire>
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
80103068:	e8 40 15 00 00       	call   801045ad <sleep>
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
8010309d:	e8 0b 15 00 00       	call   801045ad <sleep>
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
801030bc:	e8 cb 1a 00 00       	call   80104b8c <release>
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
801030dd:	e8 3c 1a 00 00       	call   80104b1e <acquire>
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
801030fe:	68 f5 a6 10 80       	push   $0x8010a6f5
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
8010312c:	e8 66 15 00 00       	call   80104697 <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 4b 1a 00 00       	call   80104b8c <release>
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
80103157:	e8 c2 19 00 00       	call   80104b1e <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 21 15 00 00       	call   80104697 <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 06 1a 00 00       	call   80104b8c <release>
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
801031fd:	e8 51 1c 00 00       	call   80104e53 <memmove>
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
8010329a:	68 04 a7 10 80       	push   $0x8010a704
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 1a a7 10 80       	push   $0x8010a71a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 57 18 00 00       	call   80104b1e <acquire>
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
80103340:	e8 47 18 00 00       	call   80104b8c <release>
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
80103376:	e8 03 4f 00 00       	call   8010827e <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 03 45 00 00       	call   80107898 <kvmalloc>
  mpinit_uefi();
80103395:	e8 aa 4c 00 00       	call   80108044 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 8c 3f 00 00       	call   80107330 <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 11 33 00 00       	call   801066c9 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 1e 2e 00 00       	call   801061e0 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 ee 6f 00 00       	call   8010a3bf <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 e7 50 00 00       	call   801084d7 <pci_init>
  arp_scan();
801033f0:	e8 1e 5e 00 00       	call   80109213 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 9e 07 00 00       	call   80103b98 <userinit>

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
80103405:	e8 a6 44 00 00       	call   801078b0 <switchkvm>
  seginit();
8010340a:	e8 21 3f 00 00       	call   80107330 <seginit>
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
80103420:	e8 78 05 00 00       	call   8010399d <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 71 05 00 00       	call   8010399d <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 35 a7 10 80       	push   $0x8010a735
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 13 2f 00 00       	call   80106356 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 70 05 00 00       	call   801039b8 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 c9 0c 00 00       	call   80104129 <scheduler>

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
80103476:	68 18 f5 10 80       	push   $0x8010f518
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 d0 19 00 00       	call   80104e53 <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 72 19 80 	movl   $0x80197280,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 24 05 00 00       	call   801039b8 <mycpu>
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
80103508:	a1 50 75 19 80       	mov    0x80197550,%eax
8010350d:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103513:	05 80 72 19 80       	add    $0x80197280,%eax
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
80103607:	68 49 a7 10 80       	push   $0x8010a749
8010360c:	50                   	push   %eax
8010360d:	e8 ea 14 00 00       	call   80104afc <initlock>
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
801036cc:	e8 4d 14 00 00       	call   80104b1e <acquire>
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
801036f3:	e8 9f 0f 00 00       	call   80104697 <wakeup>
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
80103716:	e8 7c 0f 00 00       	call   80104697 <wakeup>
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
8010373f:	e8 48 14 00 00       	call   80104b8c <release>
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
8010375e:	e8 29 14 00 00       	call   80104b8c <release>
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
80103778:	e8 a1 13 00 00       	call   80104b1e <acquire>
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
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 db 13 00 00       	call   80104b8c <release>
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
801037ca:	e8 c8 0e 00 00       	call   80104697 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 c5 0d 00 00       	call   801045ad <sleep>
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
8010384d:	e8 45 0e 00 00       	call   80104697 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 2b 13 00 00       	call   80104b8c <release>
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
80103879:	e8 a0 12 00 00       	call   80104b1e <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 f1 12 00 00       	call   80104b8c <release>
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
801038b9:	e8 ef 0c 00 00       	call   801045ad <sleep>
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
8010394c:	e8 46 0d 00 00       	call   80104697 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 2c 12 00 00       	call   80104b8c <release>
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
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 50 a7 10 80       	push   $0x8010a750
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 65 11 00 00       	call   80104afc <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave  
8010399c:	c3                   	ret    

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 72 19 80       	sub    $0x80197280,%eax
801039ad:	c1 f8 02             	sar    $0x2,%eax
801039b0:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
801039b6:	c9                   	leave  
801039b7:	c3                   	ret    

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 58 a7 10 80       	push   $0x8010a758
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1c f1 ff ff       	call   80102afa <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039f3:	05 80 72 19 80       	add    $0x80197280,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a0c:	05 80 72 19 80       	add    $0x80197280,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 50 75 19 80       	mov    0x80197550,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 7e a7 10 80       	push   $0x8010a77e
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave  
80103a2f:	c3                   	ret    

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 4e 12 00 00       	call   80104c89 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 82 12 00 00       	call   80104cd6 <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave  
80103a58:	c3                   	ret    

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 b2 10 00 00       	call   80104b1e <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 11                	jmp    80103a89 <allocproc+0x30>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 2a                	je     80103aac <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80103a89:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80103a90:	72 e6                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a92:	83 ec 0c             	sub    $0xc,%esp
80103a95:	68 00 42 19 80       	push   $0x80194200
80103a9a:	e8 ed 10 00 00       	call   80104b8c <release>
80103a9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa2:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa7:	e9 ea 00 00 00       	jmp    80103b96 <allocproc+0x13d>
      goto found;
80103aac:	90                   	nop

found:
  p->state = EMBRYO;
80103aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab7:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103abc:	8d 50 01             	lea    0x1(%eax),%edx
80103abf:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac8:	89 42 10             	mov    %eax,0x10(%edx)
  
  release(&ptable.lock);
80103acb:	83 ec 0c             	sub    $0xc,%esp
80103ace:	68 00 42 19 80       	push   $0x80194200
80103ad3:	e8 b4 10 00 00       	call   80104b8c <release>
80103ad8:	83 c4 10             	add    $0x10,%esp
  
  p->priority = 3; //Q3에서 시작
80103adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ade:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  memset(p->ticks, 0, sizeof(p->ticks)); //초기화
80103ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae8:	83 e8 80             	sub    $0xffffff80,%eax
80103aeb:	83 ec 04             	sub    $0x4,%esp
80103aee:	6a 10                	push   $0x10
80103af0:	6a 00                	push   $0x0
80103af2:	50                   	push   %eax
80103af3:	e8 9c 12 00 00       	call   80104d94 <memset>
80103af8:	83 c4 10             	add    $0x10,%esp
  memset(p->wait_ticks, 0, sizeof(p->wait_ticks)); // 초기화
80103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afe:	05 90 00 00 00       	add    $0x90,%eax
80103b03:	83 ec 04             	sub    $0x4,%esp
80103b06:	6a 10                	push   $0x10
80103b08:	6a 00                	push   $0x0
80103b0a:	50                   	push   %eax
80103b0b:	e8 84 12 00 00       	call   80104d94 <memset>
80103b10:	83 c4 10             	add    $0x10,%esp

  


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103b13:	e8 88 ec ff ff       	call   801027a0 <kalloc>
80103b18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b1b:	89 42 08             	mov    %eax,0x8(%edx)
80103b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b21:	8b 40 08             	mov    0x8(%eax),%eax
80103b24:	85 c0                	test   %eax,%eax
80103b26:	75 11                	jne    80103b39 <allocproc+0xe0>
    p->state = UNUSED;
80103b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b32:	b8 00 00 00 00       	mov    $0x0,%eax
80103b37:	eb 5d                	jmp    80103b96 <allocproc+0x13d>
  }
  sp = p->kstack + KSTACKSIZE;
80103b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3c:	8b 40 08             	mov    0x8(%eax),%eax
80103b3f:	05 00 10 00 00       	add    $0x1000,%eax
80103b44:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b47:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b51:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b54:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b58:	ba 9a 61 10 80       	mov    $0x8010619a,%edx
80103b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b60:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b62:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b69:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b6c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b72:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b75:	83 ec 04             	sub    $0x4,%esp
80103b78:	6a 14                	push   $0x14
80103b7a:	6a 00                	push   $0x0
80103b7c:	50                   	push   %eax
80103b7d:	e8 12 12 00 00       	call   80104d94 <memset>
80103b82:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b88:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b8b:	ba 67 45 10 80       	mov    $0x80104567,%edx
80103b90:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b96:	c9                   	leave  
80103b97:	c3                   	ret    

80103b98 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b98:	55                   	push   %ebp
80103b99:	89 e5                	mov    %esp,%ebp
80103b9b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b9e:	e8 b6 fe ff ff       	call   80103a59 <allocproc>
80103ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba9:	a3 34 6a 19 80       	mov    %eax,0x80196a34
  if((p->pgdir = setupkvm()) == 0){
80103bae:	e8 f9 3b 00 00       	call   801077ac <setupkvm>
80103bb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bb6:	89 42 04             	mov    %eax,0x4(%edx)
80103bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbc:	8b 40 04             	mov    0x4(%eax),%eax
80103bbf:	85 c0                	test   %eax,%eax
80103bc1:	75 0d                	jne    80103bd0 <userinit+0x38>
    panic("userinit: out of memory?");
80103bc3:	83 ec 0c             	sub    $0xc,%esp
80103bc6:	68 8e a7 10 80       	push   $0x8010a78e
80103bcb:	e8 d9 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103bd0:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd8:	8b 40 04             	mov    0x4(%eax),%eax
80103bdb:	83 ec 04             	sub    $0x4,%esp
80103bde:	52                   	push   %edx
80103bdf:	68 ec f4 10 80       	push   $0x8010f4ec
80103be4:	50                   	push   %eax
80103be5:	e8 7e 3e 00 00       	call   80107a68 <inituvm>
80103bea:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf9:	8b 40 18             	mov    0x18(%eax),%eax
80103bfc:	83 ec 04             	sub    $0x4,%esp
80103bff:	6a 4c                	push   $0x4c
80103c01:	6a 00                	push   $0x0
80103c03:	50                   	push   %eax
80103c04:	e8 8b 11 00 00       	call   80104d94 <memset>
80103c09:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0f:	8b 40 18             	mov    0x18(%eax),%eax
80103c12:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1b:	8b 40 18             	mov    0x18(%eax),%eax
80103c1e:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c27:	8b 50 18             	mov    0x18(%eax),%edx
80103c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2d:	8b 40 18             	mov    0x18(%eax),%eax
80103c30:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c34:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	8b 50 18             	mov    0x18(%eax),%edx
80103c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c41:	8b 40 18             	mov    0x18(%eax),%eax
80103c44:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c48:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4f:	8b 40 18             	mov    0x18(%eax),%eax
80103c52:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5c:	8b 40 18             	mov    0x18(%eax),%eax
80103c5f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c69:	8b 40 18             	mov    0x18(%eax),%eax
80103c6c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c76:	83 c0 6c             	add    $0x6c,%eax
80103c79:	83 ec 04             	sub    $0x4,%esp
80103c7c:	6a 10                	push   $0x10
80103c7e:	68 a7 a7 10 80       	push   $0x8010a7a7
80103c83:	50                   	push   %eax
80103c84:	e8 0e 13 00 00       	call   80104f97 <safestrcpy>
80103c89:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	68 b0 a7 10 80       	push   $0x8010a7b0
80103c94:	e8 84 e8 ff ff       	call   8010251d <namei>
80103c99:	83 c4 10             	add    $0x10,%esp
80103c9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c9f:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103ca2:	83 ec 0c             	sub    $0xc,%esp
80103ca5:	68 00 42 19 80       	push   $0x80194200
80103caa:	e8 6f 0e 00 00       	call   80104b1e <acquire>
80103caf:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103cbc:	83 ec 0c             	sub    $0xc,%esp
80103cbf:	68 00 42 19 80       	push   $0x80194200
80103cc4:	e8 c3 0e 00 00       	call   80104b8c <release>
80103cc9:	83 c4 10             	add    $0x10,%esp
}
80103ccc:	90                   	nop
80103ccd:	c9                   	leave  
80103cce:	c3                   	ret    

80103ccf <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103ccf:	55                   	push   %ebp
80103cd0:	89 e5                	mov    %esp,%ebp
80103cd2:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103cd5:	e8 56 fd ff ff       	call   80103a30 <myproc>
80103cda:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce0:	8b 00                	mov    (%eax),%eax
80103ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ce5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce9:	7e 2e                	jle    80103d19 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ceb:	8b 55 08             	mov    0x8(%ebp),%edx
80103cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf1:	01 c2                	add    %eax,%edx
80103cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf6:	8b 40 04             	mov    0x4(%eax),%eax
80103cf9:	83 ec 04             	sub    $0x4,%esp
80103cfc:	52                   	push   %edx
80103cfd:	ff 75 f4             	push   -0xc(%ebp)
80103d00:	50                   	push   %eax
80103d01:	e8 9f 3e 00 00       	call   80107ba5 <allocuvm>
80103d06:	83 c4 10             	add    $0x10,%esp
80103d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d10:	75 3b                	jne    80103d4d <growproc+0x7e>
      return -1;
80103d12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d17:	eb 4f                	jmp    80103d68 <growproc+0x99>
  } else if(n < 0){
80103d19:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d1d:	79 2e                	jns    80103d4d <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d1f:	8b 55 08             	mov    0x8(%ebp),%edx
80103d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d25:	01 c2                	add    %eax,%edx
80103d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d2a:	8b 40 04             	mov    0x4(%eax),%eax
80103d2d:	83 ec 04             	sub    $0x4,%esp
80103d30:	52                   	push   %edx
80103d31:	ff 75 f4             	push   -0xc(%ebp)
80103d34:	50                   	push   %eax
80103d35:	e8 70 3f 00 00       	call   80107caa <deallocuvm>
80103d3a:	83 c4 10             	add    $0x10,%esp
80103d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d44:	75 07                	jne    80103d4d <growproc+0x7e>
      return -1;
80103d46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d4b:	eb 1b                	jmp    80103d68 <growproc+0x99>
  }
  curproc->sz = sz;
80103d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d53:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d55:	83 ec 0c             	sub    $0xc,%esp
80103d58:	ff 75 f0             	push   -0x10(%ebp)
80103d5b:	e8 69 3b 00 00       	call   801078c9 <switchuvm>
80103d60:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d68:	c9                   	leave  
80103d69:	c3                   	ret    

80103d6a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d6a:	55                   	push   %ebp
80103d6b:	89 e5                	mov    %esp,%ebp
80103d6d:	57                   	push   %edi
80103d6e:	56                   	push   %esi
80103d6f:	53                   	push   %ebx
80103d70:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d73:	e8 b8 fc ff ff       	call   80103a30 <myproc>
80103d78:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d7b:	e8 d9 fc ff ff       	call   80103a59 <allocproc>
80103d80:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d83:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d87:	75 0a                	jne    80103d93 <fork+0x29>
    return -1;
80103d89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d8e:	e9 48 01 00 00       	jmp    80103edb <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d96:	8b 10                	mov    (%eax),%edx
80103d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d9b:	8b 40 04             	mov    0x4(%eax),%eax
80103d9e:	83 ec 08             	sub    $0x8,%esp
80103da1:	52                   	push   %edx
80103da2:	50                   	push   %eax
80103da3:	e8 a0 40 00 00       	call   80107e48 <copyuvm>
80103da8:	83 c4 10             	add    $0x10,%esp
80103dab:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103dae:	89 42 04             	mov    %eax,0x4(%edx)
80103db1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db4:	8b 40 04             	mov    0x4(%eax),%eax
80103db7:	85 c0                	test   %eax,%eax
80103db9:	75 30                	jne    80103deb <fork+0x81>
    kfree(np->kstack);
80103dbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbe:	8b 40 08             	mov    0x8(%eax),%eax
80103dc1:	83 ec 0c             	sub    $0xc,%esp
80103dc4:	50                   	push   %eax
80103dc5:	e8 3c e9 ff ff       	call   80102706 <kfree>
80103dca:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103dcd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103dd7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dda:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103de1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103de6:	e9 f0 00 00 00       	jmp    80103edb <fork+0x171>
  }
  np->sz = curproc->sz;
80103deb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dee:	8b 10                	mov    (%eax),%edx
80103df0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df3:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103df5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dfb:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e01:	8b 48 18             	mov    0x18(%eax),%ecx
80103e04:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e07:	8b 40 18             	mov    0x18(%eax),%eax
80103e0a:	89 c2                	mov    %eax,%edx
80103e0c:	89 cb                	mov    %ecx,%ebx
80103e0e:	b8 13 00 00 00       	mov    $0x13,%eax
80103e13:	89 d7                	mov    %edx,%edi
80103e15:	89 de                	mov    %ebx,%esi
80103e17:	89 c1                	mov    %eax,%ecx
80103e19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e1e:	8b 40 18             	mov    0x18(%eax),%eax
80103e21:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103e28:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e2f:	eb 3b                	jmp    80103e6c <fork+0x102>
    if(curproc->ofile[i])
80103e31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e37:	83 c2 08             	add    $0x8,%edx
80103e3a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e3e:	85 c0                	test   %eax,%eax
80103e40:	74 26                	je     80103e68 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e42:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e45:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e48:	83 c2 08             	add    $0x8,%edx
80103e4b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e4f:	83 ec 0c             	sub    $0xc,%esp
80103e52:	50                   	push   %eax
80103e53:	e8 f2 d1 ff ff       	call   8010104a <filedup>
80103e58:	83 c4 10             	add    $0x10,%esp
80103e5b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e5e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e61:	83 c1 08             	add    $0x8,%ecx
80103e64:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e68:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e6c:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e70:	7e bf                	jle    80103e31 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e75:	8b 40 68             	mov    0x68(%eax),%eax
80103e78:	83 ec 0c             	sub    $0xc,%esp
80103e7b:	50                   	push   %eax
80103e7c:	e8 2f db ff ff       	call   801019b0 <idup>
80103e81:	83 c4 10             	add    $0x10,%esp
80103e84:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e87:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e8d:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e90:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e93:	83 c0 6c             	add    $0x6c,%eax
80103e96:	83 ec 04             	sub    $0x4,%esp
80103e99:	6a 10                	push   $0x10
80103e9b:	52                   	push   %edx
80103e9c:	50                   	push   %eax
80103e9d:	e8 f5 10 00 00       	call   80104f97 <safestrcpy>
80103ea2:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ea5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ea8:	8b 40 10             	mov    0x10(%eax),%eax
80103eab:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103eae:	83 ec 0c             	sub    $0xc,%esp
80103eb1:	68 00 42 19 80       	push   $0x80194200
80103eb6:	e8 63 0c 00 00       	call   80104b1e <acquire>
80103ebb:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103ebe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ec1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ec8:	83 ec 0c             	sub    $0xc,%esp
80103ecb:	68 00 42 19 80       	push   $0x80194200
80103ed0:	e8 b7 0c 00 00       	call   80104b8c <release>
80103ed5:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ed8:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ede:	5b                   	pop    %ebx
80103edf:	5e                   	pop    %esi
80103ee0:	5f                   	pop    %edi
80103ee1:	5d                   	pop    %ebp
80103ee2:	c3                   	ret    

80103ee3 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ee3:	55                   	push   %ebp
80103ee4:	89 e5                	mov    %esp,%ebp
80103ee6:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103ee9:	e8 42 fb ff ff       	call   80103a30 <myproc>
80103eee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103ef1:	a1 34 6a 19 80       	mov    0x80196a34,%eax
80103ef6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ef9:	75 0d                	jne    80103f08 <exit+0x25>
    panic("init exiting");
80103efb:	83 ec 0c             	sub    $0xc,%esp
80103efe:	68 b2 a7 10 80       	push   $0x8010a7b2
80103f03:	e8 a1 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103f08:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103f0f:	eb 3f                	jmp    80103f50 <exit+0x6d>
    if(curproc->ofile[fd]){
80103f11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f14:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f17:	83 c2 08             	add    $0x8,%edx
80103f1a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f1e:	85 c0                	test   %eax,%eax
80103f20:	74 2a                	je     80103f4c <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f28:	83 c2 08             	add    $0x8,%edx
80103f2b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f2f:	83 ec 0c             	sub    $0xc,%esp
80103f32:	50                   	push   %eax
80103f33:	e8 63 d1 ff ff       	call   8010109b <fileclose>
80103f38:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f41:	83 c2 08             	add    $0x8,%edx
80103f44:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f4b:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f4c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f50:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f54:	7e bb                	jle    80103f11 <exit+0x2e>
    }
  }

  begin_op();
80103f56:	e8 e1 f0 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f5e:	8b 40 68             	mov    0x68(%eax),%eax
80103f61:	83 ec 0c             	sub    $0xc,%esp
80103f64:	50                   	push   %eax
80103f65:	e8 e1 db ff ff       	call   80101b4b <iput>
80103f6a:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f6d:	e8 56 f1 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80103f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f75:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f7c:	83 ec 0c             	sub    $0xc,%esp
80103f7f:	68 00 42 19 80       	push   $0x80194200
80103f84:	e8 95 0b 00 00       	call   80104b1e <acquire>
80103f89:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f8f:	8b 40 14             	mov    0x14(%eax),%eax
80103f92:	83 ec 0c             	sub    $0xc,%esp
80103f95:	50                   	push   %eax
80103f96:	e8 b9 06 00 00       	call   80104654 <wakeup1>
80103f9b:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9e:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103fa5:	eb 3a                	jmp    80103fe1 <exit+0xfe>
    if(p->parent == curproc){
80103fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103faa:	8b 40 14             	mov    0x14(%eax),%eax
80103fad:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fb0:	75 28                	jne    80103fda <exit+0xf7>
      p->parent = initproc;
80103fb2:	8b 15 34 6a 19 80    	mov    0x80196a34,%edx
80103fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fbb:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc1:	8b 40 0c             	mov    0xc(%eax),%eax
80103fc4:	83 f8 05             	cmp    $0x5,%eax
80103fc7:	75 11                	jne    80103fda <exit+0xf7>
        wakeup1(initproc);
80103fc9:	a1 34 6a 19 80       	mov    0x80196a34,%eax
80103fce:	83 ec 0c             	sub    $0xc,%esp
80103fd1:	50                   	push   %eax
80103fd2:	e8 7d 06 00 00       	call   80104654 <wakeup1>
80103fd7:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fda:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80103fe1:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80103fe8:	72 bd                	jb     80103fa7 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fed:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103ff4:	e8 7b 04 00 00       	call   80104474 <sched>
  panic("zombie exit");
80103ff9:	83 ec 0c             	sub    $0xc,%esp
80103ffc:	68 bf a7 10 80       	push   $0x8010a7bf
80104001:	e8 a3 c5 ff ff       	call   801005a9 <panic>

80104006 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104006:	55                   	push   %ebp
80104007:	89 e5                	mov    %esp,%ebp
80104009:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010400c:	e8 1f fa ff ff       	call   80103a30 <myproc>
80104011:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104014:	83 ec 0c             	sub    $0xc,%esp
80104017:	68 00 42 19 80       	push   $0x80194200
8010401c:	e8 fd 0a 00 00       	call   80104b1e <acquire>
80104021:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104024:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010402b:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104032:	e9 a4 00 00 00       	jmp    801040db <wait+0xd5>
      if(p->parent != curproc)
80104037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403a:	8b 40 14             	mov    0x14(%eax),%eax
8010403d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104040:	0f 85 8d 00 00 00    	jne    801040d3 <wait+0xcd>
        continue;
      havekids = 1;
80104046:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010404d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104050:	8b 40 0c             	mov    0xc(%eax),%eax
80104053:	83 f8 05             	cmp    $0x5,%eax
80104056:	75 7c                	jne    801040d4 <wait+0xce>
        // Found one.
        pid = p->pid;
80104058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405b:	8b 40 10             	mov    0x10(%eax),%eax
8010405e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104064:	8b 40 08             	mov    0x8(%eax),%eax
80104067:	83 ec 0c             	sub    $0xc,%esp
8010406a:	50                   	push   %eax
8010406b:	e8 96 e6 ff ff       	call   80102706 <kfree>
80104070:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104076:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010407d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104080:	8b 40 04             	mov    0x4(%eax),%eax
80104083:	83 ec 0c             	sub    $0xc,%esp
80104086:	50                   	push   %eax
80104087:	e8 e2 3c 00 00       	call   80107d6e <freevm>
8010408c:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010408f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104092:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801040a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801040aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ad:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801040b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801040be:	83 ec 0c             	sub    $0xc,%esp
801040c1:	68 00 42 19 80       	push   $0x80194200
801040c6:	e8 c1 0a 00 00       	call   80104b8c <release>
801040cb:	83 c4 10             	add    $0x10,%esp
        return pid;
801040ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040d1:	eb 54                	jmp    80104127 <wait+0x121>
        continue;
801040d3:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040d4:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801040db:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
801040e2:	0f 82 4f ff ff ff    	jb     80104037 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040ec:	74 0a                	je     801040f8 <wait+0xf2>
801040ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040f1:	8b 40 24             	mov    0x24(%eax),%eax
801040f4:	85 c0                	test   %eax,%eax
801040f6:	74 17                	je     8010410f <wait+0x109>
      release(&ptable.lock);
801040f8:	83 ec 0c             	sub    $0xc,%esp
801040fb:	68 00 42 19 80       	push   $0x80194200
80104100:	e8 87 0a 00 00       	call   80104b8c <release>
80104105:	83 c4 10             	add    $0x10,%esp
      return -1;
80104108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410d:	eb 18                	jmp    80104127 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010410f:	83 ec 08             	sub    $0x8,%esp
80104112:	68 00 42 19 80       	push   $0x80194200
80104117:	ff 75 ec             	push   -0x14(%ebp)
8010411a:	e8 8e 04 00 00       	call   801045ad <sleep>
8010411f:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104122:	e9 fd fe ff ff       	jmp    80104024 <wait+0x1e>
  }
}
80104127:	c9                   	leave  
80104128:	c3                   	ret    

80104129 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104129:	55                   	push   %ebp
8010412a:	89 e5                	mov    %esp,%ebp
8010412c:	83 ec 48             	sub    $0x48,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010412f:	e8 84 f8 ff ff       	call   801039b8 <mycpu>
80104134:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  c->proc = 0;
80104137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010413a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104141:	00 00 00 

  for (;;) {
    sti();  // 인터럽트 허용
80104144:	e8 2f f8 ff ff       	call   80103978 <sti>

    acquire(&ptable.lock);
80104149:	83 ec 0c             	sub    $0xc,%esp
8010414c:	68 00 42 19 80       	push   $0x80194200
80104151:	e8 c8 09 00 00       	call   80104b1e <acquire>
80104156:	83 c4 10             	add    $0x10,%esp

    int policy = c->sched_policy;  // 현재 설정된 스케줄링 정책
80104159:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010415c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104162:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
    //RR
    if (policy == 0) {
80104165:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104169:	75 7b                	jne    801041e6 <scheduler+0xbd>
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010416b:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104172:	eb 64                	jmp    801041d8 <scheduler+0xaf>
        if (p->state != RUNNABLE)
80104174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104177:	8b 40 0c             	mov    0xc(%eax),%eax
8010417a:	83 f8 03             	cmp    $0x3,%eax
8010417d:	75 51                	jne    801041d0 <scheduler+0xa7>
          continue;

        c->proc = p;
8010417f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104182:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104185:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
8010418b:	83 ec 0c             	sub    $0xc,%esp
8010418e:	ff 75 f4             	push   -0xc(%ebp)
80104191:	e8 33 37 00 00       	call   801078c9 <switchuvm>
80104196:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
801041a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a6:	8b 40 1c             	mov    0x1c(%eax),%eax
801041a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801041ac:	83 c2 04             	add    $0x4,%edx
801041af:	83 ec 08             	sub    $0x8,%esp
801041b2:	50                   	push   %eax
801041b3:	52                   	push   %edx
801041b4:	e8 50 0e 00 00       	call   80105009 <swtch>
801041b9:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801041bc:	e8 ef 36 00 00       	call   801078b0 <switchkvm>
        c->proc = 0;
801041c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801041c4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041cb:	00 00 00 
801041ce:	eb 01                	jmp    801041d1 <scheduler+0xa8>
          continue;
801041d0:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801041d1:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801041d8:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
801041df:	72 93                	jb     80104174 <scheduler+0x4b>
801041e1:	e9 79 02 00 00       	jmp    8010445f <scheduler+0x336>
      }
    } else {
      // MLFQ

      // Boosting
      if (policy != 3) {
801041e6:	83 7d e0 03          	cmpl   $0x3,-0x20(%ebp)
801041ea:	0f 84 a0 00 00 00    	je     80104290 <scheduler+0x167>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801041f0:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801041f7:	e9 87 00 00 00       	jmp    80104283 <scheduler+0x15a>
          if (p->state != RUNNABLE)
801041fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104202:	83 f8 03             	cmp    $0x3,%eax
80104205:	75 74                	jne    8010427b <scheduler+0x152>
            continue;

          int curq = p->priority;
80104207:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420a:	8b 40 7c             	mov    0x7c(%eax),%eax
8010420d:	89 45 dc             	mov    %eax,-0x24(%ebp)
          int boost_limit[] = {500, 320, 160};
80104210:	c7 45 bc f4 01 00 00 	movl   $0x1f4,-0x44(%ebp)
80104217:	c7 45 c0 40 01 00 00 	movl   $0x140,-0x40(%ebp)
8010421e:	c7 45 c4 a0 00 00 00 	movl   $0xa0,-0x3c(%ebp)

          if (curq < 3 && p->wait_ticks[curq] >= boost_limit[3 - curq]){
80104225:	83 7d dc 02          	cmpl   $0x2,-0x24(%ebp)
80104229:	7f 51                	jg     8010427c <scheduler+0x153>
8010422b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104231:	83 c2 24             	add    $0x24,%edx
80104234:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104237:	b8 03 00 00 00       	mov    $0x3,%eax
8010423c:	2b 45 dc             	sub    -0x24(%ebp),%eax
8010423f:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104243:	39 c2                	cmp    %eax,%edx
80104245:	7c 35                	jl     8010427c <scheduler+0x153>
            p->priority++;
80104247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424a:	8b 40 7c             	mov    0x7c(%eax),%eax
8010424d:	8d 50 01             	lea    0x1(%eax),%edx
80104250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104253:	89 50 7c             	mov    %edx,0x7c(%eax)
            for (int i=0; i<4; i++)
80104256:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010425d:	eb 14                	jmp    80104273 <scheduler+0x14a>
              p->wait_ticks[i]=0;
8010425f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104262:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104265:	83 c2 24             	add    $0x24,%edx
80104268:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
            for (int i=0; i<4; i++)
8010426f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104273:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104277:	7e e6                	jle    8010425f <scheduler+0x136>
80104279:	eb 01                	jmp    8010427c <scheduler+0x153>
            continue;
8010427b:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010427c:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104283:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
8010428a:	0f 82 6c ff ff ff    	jb     801041fc <scheduler+0xd3>
          }
        }
      }

      // Time slice 
      int slice[4] = { -1, 32, 16, 8 };
80104290:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
80104297:	c7 45 cc 20 00 00 00 	movl   $0x20,-0x34(%ebp)
8010429e:	c7 45 d0 10 00 00 00 	movl   $0x10,-0x30(%ebp)
801042a5:	c7 45 d4 08 00 00 00 	movl   $0x8,-0x2c(%ebp)

      int done = 0;
801042ac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

      // Q3부터 순차적으로 찾기
      for (int q = 3; q >= 0 && !done; q--) {
801042b3:	c7 45 e8 03 00 00 00 	movl   $0x3,-0x18(%ebp)
801042ba:	e9 90 01 00 00       	jmp    8010444f <scheduler+0x326>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801042bf:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801042c6:	e9 73 01 00 00       	jmp    8010443e <scheduler+0x315>
          if (p->state != RUNNABLE || p->priority != q)
801042cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ce:	8b 40 0c             	mov    0xc(%eax),%eax
801042d1:	83 f8 03             	cmp    $0x3,%eax
801042d4:	0f 85 5c 01 00 00    	jne    80104436 <scheduler+0x30d>
801042da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042dd:	8b 40 7c             	mov    0x7c(%eax),%eax
801042e0:	39 45 e8             	cmp    %eax,-0x18(%ebp)
801042e3:	0f 85 4d 01 00 00    	jne    80104436 <scheduler+0x30d>
            continue;
          
          int pr = p->priority;
801042e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ec:	8b 40 7c             	mov    0x7c(%eax),%eax
801042ef:	89 45 d8             	mov    %eax,-0x28(%ebp)

          c->proc = p;
801042f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801042f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042f8:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
801042fe:	83 ec 0c             	sub    $0xc,%esp
80104301:	ff 75 f4             	push   -0xc(%ebp)
80104304:	e8 c0 35 00 00       	call   801078c9 <switchuvm>
80104309:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
          swtch(&(c->scheduler), p->context);
80104316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104319:	8b 40 1c             	mov    0x1c(%eax),%eax
8010431c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010431f:	83 c2 04             	add    $0x4,%edx
80104322:	83 ec 08             	sub    $0x8,%esp
80104325:	50                   	push   %eax
80104326:	52                   	push   %edx
80104327:	e8 dd 0c 00 00       	call   80105009 <swtch>
8010432c:	83 c4 10             	add    $0x10,%esp
          switchkvm();
8010432f:	e8 7c 35 00 00       	call   801078b0 <switchkvm>
          c->proc = 0;
80104334:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104337:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010433e:	00 00 00 

          // 정책 2번: tick에 따라 강등
          if (policy == 2) {
80104341:	83 7d e0 02          	cmpl   $0x2,-0x20(%ebp)
80104345:	75 75                	jne    801043bc <scheduler+0x293>
            if ((pr == 3 && p->ticks[3] >= 8) ||
80104347:	83 7d d8 03          	cmpl   $0x3,-0x28(%ebp)
8010434b:	75 0e                	jne    8010435b <scheduler+0x232>
8010434d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104350:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104356:	83 f8 07             	cmp    $0x7,%eax
80104359:	7f 30                	jg     8010438b <scheduler+0x262>
8010435b:	83 7d d8 02          	cmpl   $0x2,-0x28(%ebp)
8010435f:	75 0e                	jne    8010436f <scheduler+0x246>
                (pr == 2 && p->ticks[2] >= 16) ||
80104361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104364:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
8010436a:	83 f8 0f             	cmp    $0xf,%eax
8010436d:	7f 1c                	jg     8010438b <scheduler+0x262>
8010436f:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
80104373:	0f 85 b4 00 00 00    	jne    8010442d <scheduler+0x304>
                (pr == 1 && p->ticks[1] >= 32)) {
80104379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437c:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104382:	83 f8 1f             	cmp    $0x1f,%eax
80104385:	0f 8e a2 00 00 00    	jle    8010442d <scheduler+0x304>

              if (p->priority > 0){
8010438b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438e:	8b 40 7c             	mov    0x7c(%eax),%eax
80104391:	85 c0                	test   %eax,%eax
80104393:	7e 0f                	jle    801043a4 <scheduler+0x27b>
                p->priority--;
80104395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104398:	8b 40 7c             	mov    0x7c(%eax),%eax
8010439b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010439e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a1:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
801043a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a7:	83 e8 80             	sub    $0xffffff80,%eax
801043aa:	83 ec 04             	sub    $0x4,%esp
801043ad:	6a 10                	push   $0x10
801043af:	6a 00                	push   $0x0
801043b1:	50                   	push   %eax
801043b2:	e8 dd 09 00 00       	call   80104d94 <memset>
801043b7:	83 c4 10             	add    $0x10,%esp
801043ba:	eb 71                	jmp    8010442d <scheduler+0x304>
            }
          }

          // 정책 1 & 3: slice 기반 강등
          else {
            if ((pr == 3 && p->ticks[3] >= slice[3]) ||
801043bc:	83 7d d8 03          	cmpl   $0x3,-0x28(%ebp)
801043c0:	75 10                	jne    801043d2 <scheduler+0x2a9>
801043c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c5:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801043cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801043ce:	39 c2                	cmp    %eax,%edx
801043d0:	7d 2c                	jge    801043fe <scheduler+0x2d5>
801043d2:	83 7d d8 02          	cmpl   $0x2,-0x28(%ebp)
801043d6:	75 10                	jne    801043e8 <scheduler+0x2bf>
                (pr == 2 && p->ticks[2] >= slice[2]) ||
801043d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043db:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
801043e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801043e4:	39 c2                	cmp    %eax,%edx
801043e6:	7d 16                	jge    801043fe <scheduler+0x2d5>
801043e8:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
801043ec:	75 3f                	jne    8010442d <scheduler+0x304>
                (pr == 1 && p->ticks[1] >= slice[1])) {
801043ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f1:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
801043f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
801043fa:	39 c2                	cmp    %eax,%edx
801043fc:	7c 2f                	jl     8010442d <scheduler+0x304>
              if (p->priority > 0){
801043fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104401:	8b 40 7c             	mov    0x7c(%eax),%eax
80104404:	85 c0                	test   %eax,%eax
80104406:	7e 0f                	jle    80104417 <scheduler+0x2ee>
                p->priority--;
80104408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440b:	8b 40 7c             	mov    0x7c(%eax),%eax
8010440e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104414:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
80104417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441a:	83 e8 80             	sub    $0xffffff80,%eax
8010441d:	83 ec 04             	sub    $0x4,%esp
80104420:	6a 10                	push   $0x10
80104422:	6a 00                	push   $0x0
80104424:	50                   	push   %eax
80104425:	e8 6a 09 00 00       	call   80104d94 <memset>
8010442a:	83 c4 10             	add    $0x10,%esp

            }
          }

          done = 1;
8010442d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
          break;
80104434:	eb 15                	jmp    8010444b <scheduler+0x322>
            continue;
80104436:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104437:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
8010443e:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80104445:	0f 82 80 fe ff ff    	jb     801042cb <scheduler+0x1a2>
      for (int q = 3; q >= 0 && !done; q--) {
8010444b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
8010444f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104453:	78 0a                	js     8010445f <scheduler+0x336>
80104455:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104459:	0f 84 60 fe ff ff    	je     801042bf <scheduler+0x196>
        }
      }
    }

    release(&ptable.lock);
8010445f:	83 ec 0c             	sub    $0xc,%esp
80104462:	68 00 42 19 80       	push   $0x80194200
80104467:	e8 20 07 00 00       	call   80104b8c <release>
8010446c:	83 c4 10             	add    $0x10,%esp
  for (;;) {
8010446f:	e9 d0 fc ff ff       	jmp    80104144 <scheduler+0x1b>

80104474 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104474:	55                   	push   %ebp
80104475:	89 e5                	mov    %esp,%ebp
80104477:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010447a:	e8 b1 f5 ff ff       	call   80103a30 <myproc>
8010447f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104482:	83 ec 0c             	sub    $0xc,%esp
80104485:	68 00 42 19 80       	push   $0x80194200
8010448a:	e8 ca 07 00 00       	call   80104c59 <holding>
8010448f:	83 c4 10             	add    $0x10,%esp
80104492:	85 c0                	test   %eax,%eax
80104494:	75 0d                	jne    801044a3 <sched+0x2f>
    panic("sched ptable.lock");
80104496:	83 ec 0c             	sub    $0xc,%esp
80104499:	68 cb a7 10 80       	push   $0x8010a7cb
8010449e:	e8 06 c1 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801044a3:	e8 10 f5 ff ff       	call   801039b8 <mycpu>
801044a8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801044ae:	83 f8 01             	cmp    $0x1,%eax
801044b1:	74 0d                	je     801044c0 <sched+0x4c>
    panic("sched locks");
801044b3:	83 ec 0c             	sub    $0xc,%esp
801044b6:	68 dd a7 10 80       	push   $0x8010a7dd
801044bb:	e8 e9 c0 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801044c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c3:	8b 40 0c             	mov    0xc(%eax),%eax
801044c6:	83 f8 04             	cmp    $0x4,%eax
801044c9:	75 0d                	jne    801044d8 <sched+0x64>
    panic("sched running");
801044cb:	83 ec 0c             	sub    $0xc,%esp
801044ce:	68 e9 a7 10 80       	push   $0x8010a7e9
801044d3:	e8 d1 c0 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801044d8:	e8 8b f4 ff ff       	call   80103968 <readeflags>
801044dd:	25 00 02 00 00       	and    $0x200,%eax
801044e2:	85 c0                	test   %eax,%eax
801044e4:	74 0d                	je     801044f3 <sched+0x7f>
    panic("sched interruptible");
801044e6:	83 ec 0c             	sub    $0xc,%esp
801044e9:	68 f7 a7 10 80       	push   $0x8010a7f7
801044ee:	e8 b6 c0 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
801044f3:	e8 c0 f4 ff ff       	call   801039b8 <mycpu>
801044f8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801044fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104501:	e8 b2 f4 ff ff       	call   801039b8 <mycpu>
80104506:	8b 40 04             	mov    0x4(%eax),%eax
80104509:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010450c:	83 c2 1c             	add    $0x1c,%edx
8010450f:	83 ec 08             	sub    $0x8,%esp
80104512:	50                   	push   %eax
80104513:	52                   	push   %edx
80104514:	e8 f0 0a 00 00       	call   80105009 <swtch>
80104519:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010451c:	e8 97 f4 ff ff       	call   801039b8 <mycpu>
80104521:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104524:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010452a:	90                   	nop
8010452b:	c9                   	leave  
8010452c:	c3                   	ret    

8010452d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010452d:	55                   	push   %ebp
8010452e:	89 e5                	mov    %esp,%ebp
80104530:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104533:	83 ec 0c             	sub    $0xc,%esp
80104536:	68 00 42 19 80       	push   $0x80194200
8010453b:	e8 de 05 00 00       	call   80104b1e <acquire>
80104540:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104543:	e8 e8 f4 ff ff       	call   80103a30 <myproc>
80104548:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010454f:	e8 20 ff ff ff       	call   80104474 <sched>
  release(&ptable.lock);
80104554:	83 ec 0c             	sub    $0xc,%esp
80104557:	68 00 42 19 80       	push   $0x80194200
8010455c:	e8 2b 06 00 00       	call   80104b8c <release>
80104561:	83 c4 10             	add    $0x10,%esp
}
80104564:	90                   	nop
80104565:	c9                   	leave  
80104566:	c3                   	ret    

80104567 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104567:	55                   	push   %ebp
80104568:	89 e5                	mov    %esp,%ebp
8010456a:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010456d:	83 ec 0c             	sub    $0xc,%esp
80104570:	68 00 42 19 80       	push   $0x80194200
80104575:	e8 12 06 00 00       	call   80104b8c <release>
8010457a:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010457d:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104582:	85 c0                	test   %eax,%eax
80104584:	74 24                	je     801045aa <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104586:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010458d:	00 00 00 
    iinit(ROOTDEV);
80104590:	83 ec 0c             	sub    $0xc,%esp
80104593:	6a 01                	push   $0x1
80104595:	e8 de d0 ff ff       	call   80101678 <iinit>
8010459a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010459d:	83 ec 0c             	sub    $0xc,%esp
801045a0:	6a 01                	push   $0x1
801045a2:	e8 76 e8 ff ff       	call   80102e1d <initlog>
801045a7:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801045aa:	90                   	nop
801045ab:	c9                   	leave  
801045ac:	c3                   	ret    

801045ad <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801045ad:	55                   	push   %ebp
801045ae:	89 e5                	mov    %esp,%ebp
801045b0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801045b3:	e8 78 f4 ff ff       	call   80103a30 <myproc>
801045b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801045bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045bf:	75 0d                	jne    801045ce <sleep+0x21>
    panic("sleep");
801045c1:	83 ec 0c             	sub    $0xc,%esp
801045c4:	68 0b a8 10 80       	push   $0x8010a80b
801045c9:	e8 db bf ff ff       	call   801005a9 <panic>

  if(lk == 0)
801045ce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801045d2:	75 0d                	jne    801045e1 <sleep+0x34>
    panic("sleep without lk");
801045d4:	83 ec 0c             	sub    $0xc,%esp
801045d7:	68 11 a8 10 80       	push   $0x8010a811
801045dc:	e8 c8 bf ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801045e1:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801045e8:	74 1e                	je     80104608 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801045ea:	83 ec 0c             	sub    $0xc,%esp
801045ed:	68 00 42 19 80       	push   $0x80194200
801045f2:	e8 27 05 00 00       	call   80104b1e <acquire>
801045f7:	83 c4 10             	add    $0x10,%esp
    release(lk);
801045fa:	83 ec 0c             	sub    $0xc,%esp
801045fd:	ff 75 0c             	push   0xc(%ebp)
80104600:	e8 87 05 00 00       	call   80104b8c <release>
80104605:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460b:	8b 55 08             	mov    0x8(%ebp),%edx
8010460e:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104614:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010461b:	e8 54 fe ff ff       	call   80104474 <sched>

  // Tidy up.
  p->chan = 0;
80104620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104623:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010462a:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104631:	74 1e                	je     80104651 <sleep+0xa4>
    release(&ptable.lock);
80104633:	83 ec 0c             	sub    $0xc,%esp
80104636:	68 00 42 19 80       	push   $0x80194200
8010463b:	e8 4c 05 00 00       	call   80104b8c <release>
80104640:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104643:	83 ec 0c             	sub    $0xc,%esp
80104646:	ff 75 0c             	push   0xc(%ebp)
80104649:	e8 d0 04 00 00       	call   80104b1e <acquire>
8010464e:	83 c4 10             	add    $0x10,%esp
  }
}
80104651:	90                   	nop
80104652:	c9                   	leave  
80104653:	c3                   	ret    

80104654 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104654:	55                   	push   %ebp
80104655:	89 e5                	mov    %esp,%ebp
80104657:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010465a:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104661:	eb 27                	jmp    8010468a <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104663:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104666:	8b 40 0c             	mov    0xc(%eax),%eax
80104669:	83 f8 02             	cmp    $0x2,%eax
8010466c:	75 15                	jne    80104683 <wakeup1+0x2f>
8010466e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104671:	8b 40 20             	mov    0x20(%eax),%eax
80104674:	39 45 08             	cmp    %eax,0x8(%ebp)
80104677:	75 0a                	jne    80104683 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104679:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010467c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104683:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
8010468a:	81 7d fc 34 6a 19 80 	cmpl   $0x80196a34,-0x4(%ebp)
80104691:	72 d0                	jb     80104663 <wakeup1+0xf>
}
80104693:	90                   	nop
80104694:	90                   	nop
80104695:	c9                   	leave  
80104696:	c3                   	ret    

80104697 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104697:	55                   	push   %ebp
80104698:	89 e5                	mov    %esp,%ebp
8010469a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010469d:	83 ec 0c             	sub    $0xc,%esp
801046a0:	68 00 42 19 80       	push   $0x80194200
801046a5:	e8 74 04 00 00       	call   80104b1e <acquire>
801046aa:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801046ad:	83 ec 0c             	sub    $0xc,%esp
801046b0:	ff 75 08             	push   0x8(%ebp)
801046b3:	e8 9c ff ff ff       	call   80104654 <wakeup1>
801046b8:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801046bb:	83 ec 0c             	sub    $0xc,%esp
801046be:	68 00 42 19 80       	push   $0x80194200
801046c3:	e8 c4 04 00 00       	call   80104b8c <release>
801046c8:	83 c4 10             	add    $0x10,%esp
}
801046cb:	90                   	nop
801046cc:	c9                   	leave  
801046cd:	c3                   	ret    

801046ce <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801046ce:	55                   	push   %ebp
801046cf:	89 e5                	mov    %esp,%ebp
801046d1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801046d4:	83 ec 0c             	sub    $0xc,%esp
801046d7:	68 00 42 19 80       	push   $0x80194200
801046dc:	e8 3d 04 00 00       	call   80104b1e <acquire>
801046e1:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046e4:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801046eb:	eb 48                	jmp    80104735 <kill+0x67>
    if(p->pid == pid){
801046ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f0:	8b 40 10             	mov    0x10(%eax),%eax
801046f3:	39 45 08             	cmp    %eax,0x8(%ebp)
801046f6:	75 36                	jne    8010472e <kill+0x60>
      p->killed = 1;
801046f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104705:	8b 40 0c             	mov    0xc(%eax),%eax
80104708:	83 f8 02             	cmp    $0x2,%eax
8010470b:	75 0a                	jne    80104717 <kill+0x49>
        p->state = RUNNABLE;
8010470d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104710:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104717:	83 ec 0c             	sub    $0xc,%esp
8010471a:	68 00 42 19 80       	push   $0x80194200
8010471f:	e8 68 04 00 00       	call   80104b8c <release>
80104724:	83 c4 10             	add    $0x10,%esp
      return 0;
80104727:	b8 00 00 00 00       	mov    $0x0,%eax
8010472c:	eb 25                	jmp    80104753 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010472e:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104735:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
8010473c:	72 af                	jb     801046ed <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010473e:	83 ec 0c             	sub    $0xc,%esp
80104741:	68 00 42 19 80       	push   $0x80194200
80104746:	e8 41 04 00 00       	call   80104b8c <release>
8010474b:	83 c4 10             	add    $0x10,%esp
  return -1;
8010474e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104753:	c9                   	leave  
80104754:	c3                   	ret    

80104755 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104755:	55                   	push   %ebp
80104756:	89 e5                	mov    %esp,%ebp
80104758:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010475b:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104762:	e9 da 00 00 00       	jmp    80104841 <procdump+0xec>
    if(p->state == UNUSED)
80104767:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010476a:	8b 40 0c             	mov    0xc(%eax),%eax
8010476d:	85 c0                	test   %eax,%eax
8010476f:	0f 84 c4 00 00 00    	je     80104839 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104775:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104778:	8b 40 0c             	mov    0xc(%eax),%eax
8010477b:	83 f8 05             	cmp    $0x5,%eax
8010477e:	77 23                	ja     801047a3 <procdump+0x4e>
80104780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104783:	8b 40 0c             	mov    0xc(%eax),%eax
80104786:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010478d:	85 c0                	test   %eax,%eax
8010478f:	74 12                	je     801047a3 <procdump+0x4e>
      state = states[p->state];
80104791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104794:	8b 40 0c             	mov    0xc(%eax),%eax
80104797:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010479e:	89 45 ec             	mov    %eax,-0x14(%ebp)
801047a1:	eb 07                	jmp    801047aa <procdump+0x55>
    else
      state = "???";
801047a3:	c7 45 ec 22 a8 10 80 	movl   $0x8010a822,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801047aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047ad:	8d 50 6c             	lea    0x6c(%eax),%edx
801047b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047b3:	8b 40 10             	mov    0x10(%eax),%eax
801047b6:	52                   	push   %edx
801047b7:	ff 75 ec             	push   -0x14(%ebp)
801047ba:	50                   	push   %eax
801047bb:	68 26 a8 10 80       	push   $0x8010a826
801047c0:	e8 2f bc ff ff       	call   801003f4 <cprintf>
801047c5:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801047c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047cb:	8b 40 0c             	mov    0xc(%eax),%eax
801047ce:	83 f8 02             	cmp    $0x2,%eax
801047d1:	75 54                	jne    80104827 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801047d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047d6:	8b 40 1c             	mov    0x1c(%eax),%eax
801047d9:	8b 40 0c             	mov    0xc(%eax),%eax
801047dc:	83 c0 08             	add    $0x8,%eax
801047df:	89 c2                	mov    %eax,%edx
801047e1:	83 ec 08             	sub    $0x8,%esp
801047e4:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801047e7:	50                   	push   %eax
801047e8:	52                   	push   %edx
801047e9:	e8 f0 03 00 00       	call   80104bde <getcallerpcs>
801047ee:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801047f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801047f8:	eb 1c                	jmp    80104816 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801047fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fd:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104801:	83 ec 08             	sub    $0x8,%esp
80104804:	50                   	push   %eax
80104805:	68 2f a8 10 80       	push   $0x8010a82f
8010480a:	e8 e5 bb ff ff       	call   801003f4 <cprintf>
8010480f:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104812:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104816:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010481a:	7f 0b                	jg     80104827 <procdump+0xd2>
8010481c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104823:	85 c0                	test   %eax,%eax
80104825:	75 d3                	jne    801047fa <procdump+0xa5>
    }
    cprintf("\n");
80104827:	83 ec 0c             	sub    $0xc,%esp
8010482a:	68 33 a8 10 80       	push   $0x8010a833
8010482f:	e8 c0 bb ff ff       	call   801003f4 <cprintf>
80104834:	83 c4 10             	add    $0x10,%esp
80104837:	eb 01                	jmp    8010483a <procdump+0xe5>
      continue;
80104839:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010483a:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
80104841:	81 7d f0 34 6a 19 80 	cmpl   $0x80196a34,-0x10(%ebp)
80104848:	0f 82 19 ff ff ff    	jb     80104767 <procdump+0x12>
  }
}
8010484e:	90                   	nop
8010484f:	90                   	nop
80104850:	c9                   	leave  
80104851:	c3                   	ret    

80104852 <setSchedPolicy>:

//  0 (RR), 1 (MLFQ), 2 (MLFQ-no-tracking), 3 (MLFQ-no-boosting)

int
setSchedPolicy(int policy)
{
80104852:	55                   	push   %ebp
80104853:	89 e5                	mov    %esp,%ebp
80104855:	83 ec 18             	sub    $0x18,%esp

  if (policy < 0 || policy > 3)
80104858:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010485c:	78 06                	js     80104864 <setSchedPolicy+0x12>
8010485e:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104862:	7e 07                	jle    8010486b <setSchedPolicy+0x19>
    return -1;
80104864:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104869:	eb 23                	jmp    8010488e <setSchedPolicy+0x3c>

  pushcli();
8010486b:	e8 19 04 00 00       	call   80104c89 <pushcli>
  struct cpu *c = mycpu();
80104870:	e8 43 f1 ff ff       	call   801039b8 <mycpu>
80104875:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->sched_policy = policy;
80104878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487b:	8b 55 08             	mov    0x8(%ebp),%edx
8010487e:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104884:	e8 4d 04 00 00       	call   80104cd6 <popcli>

  return 0;
80104889:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010488e:	c9                   	leave  
8010488f:	c3                   	ret    

80104890 <getpinfo>:


int
getpinfo(struct pstat *ps)
{
80104890:	55                   	push   %ebp
80104891:	89 e5                	mov    %esp,%ebp
80104893:	53                   	push   %ebx
80104894:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  int i = 0;
80104897:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);  
8010489e:	83 ec 0c             	sub    $0xc,%esp
801048a1:	68 00 42 19 80       	push   $0x80194200
801048a6:	e8 73 02 00 00       	call   80104b1e <acquire>
801048ab:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
801048ae:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801048b5:	e9 be 00 00 00       	jmp    80104978 <getpinfo+0xe8>
    // 프로세스가 사용 중이면 1, 아니면 0
    ps->inuse[i] = (p->state != UNUSED);
801048ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bd:	8b 40 0c             	mov    0xc(%eax),%eax
801048c0:	85 c0                	test   %eax,%eax
801048c2:	0f 95 c0             	setne  %al
801048c5:	0f b6 c8             	movzbl %al,%ecx
801048c8:	8b 45 08             	mov    0x8(%ebp),%eax
801048cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048ce:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // pid 저장
    ps->pid[i] = p->pid;
801048d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d4:	8b 50 10             	mov    0x10(%eax),%edx
801048d7:	8b 45 08             	mov    0x8(%ebp),%eax
801048da:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801048dd:	83 c1 40             	add    $0x40,%ecx
801048e0:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 우선순위 저장 
    ps->priority[i] = p->priority;
801048e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e6:	8b 50 7c             	mov    0x7c(%eax),%edx
801048e9:	8b 45 08             	mov    0x8(%ebp),%eax
801048ec:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801048ef:	83 e9 80             	sub    $0xffffff80,%ecx
801048f2:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 상태 저장 
    ps->state[i] = p->state;
801048f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f8:	8b 40 0c             	mov    0xc(%eax),%eax
801048fb:	89 c1                	mov    %eax,%ecx
801048fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104900:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104903:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80104909:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // 각 큐에서 실행된 tick 수 저장
    for (int j = 0; j < 4; j++) {
8010490c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104913:	eb 52                	jmp    80104967 <getpinfo+0xd7>
      ps->ticks[i][j] = p->ticks[j];
80104915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104918:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010491b:	83 c2 20             	add    $0x20,%edx
8010491e:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104921:	8b 45 08             	mov    0x8(%ebp),%eax
80104924:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104927:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
8010492e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104931:	01 d9                	add    %ebx,%ecx
80104933:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104939:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
8010493c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104942:	83 c2 24             	add    $0x24,%edx
80104945:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104948:	8b 45 08             	mov    0x8(%ebp),%eax
8010494b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010494e:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104955:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104958:	01 d9                	add    %ebx,%ecx
8010495a:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104960:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104963:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104967:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
8010496b:	7e a8                	jle    80104915 <getpinfo+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
8010496d:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104974:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104978:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
8010497f:	0f 82 35 ff ff ff    	jb     801048ba <getpinfo+0x2a>
    }
  }

  release(&ptable.lock);  
80104985:	83 ec 0c             	sub    $0xc,%esp
80104988:	68 00 42 19 80       	push   $0x80194200
8010498d:	e8 fa 01 00 00       	call   80104b8c <release>
80104992:	83 c4 10             	add    $0x10,%esp

  return 0; 
80104995:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010499a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010499d:	c9                   	leave  
8010499e:	c3                   	ret    

8010499f <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010499f:	55                   	push   %ebp
801049a0:	89 e5                	mov    %esp,%ebp
801049a2:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801049a5:	8b 45 08             	mov    0x8(%ebp),%eax
801049a8:	83 c0 04             	add    $0x4,%eax
801049ab:	83 ec 08             	sub    $0x8,%esp
801049ae:	68 5f a8 10 80       	push   $0x8010a85f
801049b3:	50                   	push   %eax
801049b4:	e8 43 01 00 00       	call   80104afc <initlock>
801049b9:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801049bc:	8b 45 08             	mov    0x8(%ebp),%eax
801049bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801049c2:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801049c5:	8b 45 08             	mov    0x8(%ebp),%eax
801049c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801049ce:	8b 45 08             	mov    0x8(%ebp),%eax
801049d1:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801049d8:	90                   	nop
801049d9:	c9                   	leave  
801049da:	c3                   	ret    

801049db <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801049db:	55                   	push   %ebp
801049dc:	89 e5                	mov    %esp,%ebp
801049de:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049e1:	8b 45 08             	mov    0x8(%ebp),%eax
801049e4:	83 c0 04             	add    $0x4,%eax
801049e7:	83 ec 0c             	sub    $0xc,%esp
801049ea:	50                   	push   %eax
801049eb:	e8 2e 01 00 00       	call   80104b1e <acquire>
801049f0:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801049f3:	eb 15                	jmp    80104a0a <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801049f5:	8b 45 08             	mov    0x8(%ebp),%eax
801049f8:	83 c0 04             	add    $0x4,%eax
801049fb:	83 ec 08             	sub    $0x8,%esp
801049fe:	50                   	push   %eax
801049ff:	ff 75 08             	push   0x8(%ebp)
80104a02:	e8 a6 fb ff ff       	call   801045ad <sleep>
80104a07:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0d:	8b 00                	mov    (%eax),%eax
80104a0f:	85 c0                	test   %eax,%eax
80104a11:	75 e2                	jne    801049f5 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104a13:	8b 45 08             	mov    0x8(%ebp),%eax
80104a16:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104a1c:	e8 0f f0 ff ff       	call   80103a30 <myproc>
80104a21:	8b 50 10             	mov    0x10(%eax),%edx
80104a24:	8b 45 08             	mov    0x8(%ebp),%eax
80104a27:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2d:	83 c0 04             	add    $0x4,%eax
80104a30:	83 ec 0c             	sub    $0xc,%esp
80104a33:	50                   	push   %eax
80104a34:	e8 53 01 00 00       	call   80104b8c <release>
80104a39:	83 c4 10             	add    $0x10,%esp
}
80104a3c:	90                   	nop
80104a3d:	c9                   	leave  
80104a3e:	c3                   	ret    

80104a3f <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104a3f:	55                   	push   %ebp
80104a40:	89 e5                	mov    %esp,%ebp
80104a42:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a45:	8b 45 08             	mov    0x8(%ebp),%eax
80104a48:	83 c0 04             	add    $0x4,%eax
80104a4b:	83 ec 0c             	sub    $0xc,%esp
80104a4e:	50                   	push   %eax
80104a4f:	e8 ca 00 00 00       	call   80104b1e <acquire>
80104a54:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104a57:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a60:	8b 45 08             	mov    0x8(%ebp),%eax
80104a63:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104a6a:	83 ec 0c             	sub    $0xc,%esp
80104a6d:	ff 75 08             	push   0x8(%ebp)
80104a70:	e8 22 fc ff ff       	call   80104697 <wakeup>
80104a75:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104a78:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7b:	83 c0 04             	add    $0x4,%eax
80104a7e:	83 ec 0c             	sub    $0xc,%esp
80104a81:	50                   	push   %eax
80104a82:	e8 05 01 00 00       	call   80104b8c <release>
80104a87:	83 c4 10             	add    $0x10,%esp
}
80104a8a:	90                   	nop
80104a8b:	c9                   	leave  
80104a8c:	c3                   	ret    

80104a8d <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a8d:	55                   	push   %ebp
80104a8e:	89 e5                	mov    %esp,%ebp
80104a90:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a93:	8b 45 08             	mov    0x8(%ebp),%eax
80104a96:	83 c0 04             	add    $0x4,%eax
80104a99:	83 ec 0c             	sub    $0xc,%esp
80104a9c:	50                   	push   %eax
80104a9d:	e8 7c 00 00 00       	call   80104b1e <acquire>
80104aa2:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa8:	8b 00                	mov    (%eax),%eax
80104aaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104aad:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab0:	83 c0 04             	add    $0x4,%eax
80104ab3:	83 ec 0c             	sub    $0xc,%esp
80104ab6:	50                   	push   %eax
80104ab7:	e8 d0 00 00 00       	call   80104b8c <release>
80104abc:	83 c4 10             	add    $0x10,%esp
  return r;
80104abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ac2:	c9                   	leave  
80104ac3:	c3                   	ret    

80104ac4 <readeflags>:
{
80104ac4:	55                   	push   %ebp
80104ac5:	89 e5                	mov    %esp,%ebp
80104ac7:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104aca:	9c                   	pushf  
80104acb:	58                   	pop    %eax
80104acc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104acf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ad2:	c9                   	leave  
80104ad3:	c3                   	ret    

80104ad4 <cli>:
{
80104ad4:	55                   	push   %ebp
80104ad5:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ad7:	fa                   	cli    
}
80104ad8:	90                   	nop
80104ad9:	5d                   	pop    %ebp
80104ada:	c3                   	ret    

80104adb <sti>:
{
80104adb:	55                   	push   %ebp
80104adc:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ade:	fb                   	sti    
}
80104adf:	90                   	nop
80104ae0:	5d                   	pop    %ebp
80104ae1:	c3                   	ret    

80104ae2 <xchg>:
{
80104ae2:	55                   	push   %ebp
80104ae3:	89 e5                	mov    %esp,%ebp
80104ae5:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104ae8:	8b 55 08             	mov    0x8(%ebp),%edx
80104aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104af1:	f0 87 02             	lock xchg %eax,(%edx)
80104af4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104af7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104afa:	c9                   	leave  
80104afb:	c3                   	ret    

80104afc <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104afc:	55                   	push   %ebp
80104afd:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104aff:	8b 45 08             	mov    0x8(%ebp),%eax
80104b02:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b05:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b08:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b11:	8b 45 08             	mov    0x8(%ebp),%eax
80104b14:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b1b:	90                   	nop
80104b1c:	5d                   	pop    %ebp
80104b1d:	c3                   	ret    

80104b1e <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b1e:	55                   	push   %ebp
80104b1f:	89 e5                	mov    %esp,%ebp
80104b21:	53                   	push   %ebx
80104b22:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b25:	e8 5f 01 00 00       	call   80104c89 <pushcli>
  if(holding(lk)){
80104b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b2d:	83 ec 0c             	sub    $0xc,%esp
80104b30:	50                   	push   %eax
80104b31:	e8 23 01 00 00       	call   80104c59 <holding>
80104b36:	83 c4 10             	add    $0x10,%esp
80104b39:	85 c0                	test   %eax,%eax
80104b3b:	74 0d                	je     80104b4a <acquire+0x2c>
    panic("acquire");
80104b3d:	83 ec 0c             	sub    $0xc,%esp
80104b40:	68 6a a8 10 80       	push   $0x8010a86a
80104b45:	e8 5f ba ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104b4a:	90                   	nop
80104b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4e:	83 ec 08             	sub    $0x8,%esp
80104b51:	6a 01                	push   $0x1
80104b53:	50                   	push   %eax
80104b54:	e8 89 ff ff ff       	call   80104ae2 <xchg>
80104b59:	83 c4 10             	add    $0x10,%esp
80104b5c:	85 c0                	test   %eax,%eax
80104b5e:	75 eb                	jne    80104b4b <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104b60:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104b68:	e8 4b ee ff ff       	call   801039b8 <mycpu>
80104b6d:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104b70:	8b 45 08             	mov    0x8(%ebp),%eax
80104b73:	83 c0 0c             	add    $0xc,%eax
80104b76:	83 ec 08             	sub    $0x8,%esp
80104b79:	50                   	push   %eax
80104b7a:	8d 45 08             	lea    0x8(%ebp),%eax
80104b7d:	50                   	push   %eax
80104b7e:	e8 5b 00 00 00       	call   80104bde <getcallerpcs>
80104b83:	83 c4 10             	add    $0x10,%esp
}
80104b86:	90                   	nop
80104b87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b8a:	c9                   	leave  
80104b8b:	c3                   	ret    

80104b8c <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b8c:	55                   	push   %ebp
80104b8d:	89 e5                	mov    %esp,%ebp
80104b8f:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104b92:	83 ec 0c             	sub    $0xc,%esp
80104b95:	ff 75 08             	push   0x8(%ebp)
80104b98:	e8 bc 00 00 00       	call   80104c59 <holding>
80104b9d:	83 c4 10             	add    $0x10,%esp
80104ba0:	85 c0                	test   %eax,%eax
80104ba2:	75 0d                	jne    80104bb1 <release+0x25>
    panic("release");
80104ba4:	83 ec 0c             	sub    $0xc,%esp
80104ba7:	68 72 a8 10 80       	push   $0x8010a872
80104bac:	e8 f8 b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104bc5:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104bca:	8b 45 08             	mov    0x8(%ebp),%eax
80104bcd:	8b 55 08             	mov    0x8(%ebp),%edx
80104bd0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104bd6:	e8 fb 00 00 00       	call   80104cd6 <popcli>
}
80104bdb:	90                   	nop
80104bdc:	c9                   	leave  
80104bdd:	c3                   	ret    

80104bde <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104bde:	55                   	push   %ebp
80104bdf:	89 e5                	mov    %esp,%ebp
80104be1:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104be4:	8b 45 08             	mov    0x8(%ebp),%eax
80104be7:	83 e8 08             	sub    $0x8,%eax
80104bea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bed:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bf4:	eb 38                	jmp    80104c2e <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bf6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104bfa:	74 53                	je     80104c4f <getcallerpcs+0x71>
80104bfc:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c03:	76 4a                	jbe    80104c4f <getcallerpcs+0x71>
80104c05:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c09:	74 44                	je     80104c4f <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c0e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c15:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c18:	01 c2                	add    %eax,%edx
80104c1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c1d:	8b 40 04             	mov    0x4(%eax),%eax
80104c20:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c25:	8b 00                	mov    (%eax),%eax
80104c27:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c2a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c2e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c32:	7e c2                	jle    80104bf6 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104c34:	eb 19                	jmp    80104c4f <getcallerpcs+0x71>
    pcs[i] = 0;
80104c36:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c39:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c40:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c43:	01 d0                	add    %edx,%eax
80104c45:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104c4b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c4f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c53:	7e e1                	jle    80104c36 <getcallerpcs+0x58>
}
80104c55:	90                   	nop
80104c56:	90                   	nop
80104c57:	c9                   	leave  
80104c58:	c3                   	ret    

80104c59 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c59:	55                   	push   %ebp
80104c5a:	89 e5                	mov    %esp,%ebp
80104c5c:	53                   	push   %ebx
80104c5d:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104c60:	8b 45 08             	mov    0x8(%ebp),%eax
80104c63:	8b 00                	mov    (%eax),%eax
80104c65:	85 c0                	test   %eax,%eax
80104c67:	74 16                	je     80104c7f <holding+0x26>
80104c69:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6c:	8b 58 08             	mov    0x8(%eax),%ebx
80104c6f:	e8 44 ed ff ff       	call   801039b8 <mycpu>
80104c74:	39 c3                	cmp    %eax,%ebx
80104c76:	75 07                	jne    80104c7f <holding+0x26>
80104c78:	b8 01 00 00 00       	mov    $0x1,%eax
80104c7d:	eb 05                	jmp    80104c84 <holding+0x2b>
80104c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c87:	c9                   	leave  
80104c88:	c3                   	ret    

80104c89 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c89:	55                   	push   %ebp
80104c8a:	89 e5                	mov    %esp,%ebp
80104c8c:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104c8f:	e8 30 fe ff ff       	call   80104ac4 <readeflags>
80104c94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104c97:	e8 38 fe ff ff       	call   80104ad4 <cli>
  if(mycpu()->ncli == 0)
80104c9c:	e8 17 ed ff ff       	call   801039b8 <mycpu>
80104ca1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ca7:	85 c0                	test   %eax,%eax
80104ca9:	75 14                	jne    80104cbf <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104cab:	e8 08 ed ff ff       	call   801039b8 <mycpu>
80104cb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cb3:	81 e2 00 02 00 00    	and    $0x200,%edx
80104cb9:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104cbf:	e8 f4 ec ff ff       	call   801039b8 <mycpu>
80104cc4:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104cca:	83 c2 01             	add    $0x1,%edx
80104ccd:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104cd3:	90                   	nop
80104cd4:	c9                   	leave  
80104cd5:	c3                   	ret    

80104cd6 <popcli>:

void
popcli(void)
{
80104cd6:	55                   	push   %ebp
80104cd7:	89 e5                	mov    %esp,%ebp
80104cd9:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104cdc:	e8 e3 fd ff ff       	call   80104ac4 <readeflags>
80104ce1:	25 00 02 00 00       	and    $0x200,%eax
80104ce6:	85 c0                	test   %eax,%eax
80104ce8:	74 0d                	je     80104cf7 <popcli+0x21>
    panic("popcli - interruptible");
80104cea:	83 ec 0c             	sub    $0xc,%esp
80104ced:	68 7a a8 10 80       	push   $0x8010a87a
80104cf2:	e8 b2 b8 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104cf7:	e8 bc ec ff ff       	call   801039b8 <mycpu>
80104cfc:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d02:	83 ea 01             	sub    $0x1,%edx
80104d05:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104d0b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d11:	85 c0                	test   %eax,%eax
80104d13:	79 0d                	jns    80104d22 <popcli+0x4c>
    panic("popcli");
80104d15:	83 ec 0c             	sub    $0xc,%esp
80104d18:	68 91 a8 10 80       	push   $0x8010a891
80104d1d:	e8 87 b8 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104d22:	e8 91 ec ff ff       	call   801039b8 <mycpu>
80104d27:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d2d:	85 c0                	test   %eax,%eax
80104d2f:	75 14                	jne    80104d45 <popcli+0x6f>
80104d31:	e8 82 ec ff ff       	call   801039b8 <mycpu>
80104d36:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d3c:	85 c0                	test   %eax,%eax
80104d3e:	74 05                	je     80104d45 <popcli+0x6f>
    sti();
80104d40:	e8 96 fd ff ff       	call   80104adb <sti>
}
80104d45:	90                   	nop
80104d46:	c9                   	leave  
80104d47:	c3                   	ret    

80104d48 <stosb>:
{
80104d48:	55                   	push   %ebp
80104d49:	89 e5                	mov    %esp,%ebp
80104d4b:	57                   	push   %edi
80104d4c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d50:	8b 55 10             	mov    0x10(%ebp),%edx
80104d53:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d56:	89 cb                	mov    %ecx,%ebx
80104d58:	89 df                	mov    %ebx,%edi
80104d5a:	89 d1                	mov    %edx,%ecx
80104d5c:	fc                   	cld    
80104d5d:	f3 aa                	rep stos %al,%es:(%edi)
80104d5f:	89 ca                	mov    %ecx,%edx
80104d61:	89 fb                	mov    %edi,%ebx
80104d63:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d66:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d69:	90                   	nop
80104d6a:	5b                   	pop    %ebx
80104d6b:	5f                   	pop    %edi
80104d6c:	5d                   	pop    %ebp
80104d6d:	c3                   	ret    

80104d6e <stosl>:
{
80104d6e:	55                   	push   %ebp
80104d6f:	89 e5                	mov    %esp,%ebp
80104d71:	57                   	push   %edi
80104d72:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d76:	8b 55 10             	mov    0x10(%ebp),%edx
80104d79:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d7c:	89 cb                	mov    %ecx,%ebx
80104d7e:	89 df                	mov    %ebx,%edi
80104d80:	89 d1                	mov    %edx,%ecx
80104d82:	fc                   	cld    
80104d83:	f3 ab                	rep stos %eax,%es:(%edi)
80104d85:	89 ca                	mov    %ecx,%edx
80104d87:	89 fb                	mov    %edi,%ebx
80104d89:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d8c:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d8f:	90                   	nop
80104d90:	5b                   	pop    %ebx
80104d91:	5f                   	pop    %edi
80104d92:	5d                   	pop    %ebp
80104d93:	c3                   	ret    

80104d94 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d94:	55                   	push   %ebp
80104d95:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d97:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9a:	83 e0 03             	and    $0x3,%eax
80104d9d:	85 c0                	test   %eax,%eax
80104d9f:	75 43                	jne    80104de4 <memset+0x50>
80104da1:	8b 45 10             	mov    0x10(%ebp),%eax
80104da4:	83 e0 03             	and    $0x3,%eax
80104da7:	85 c0                	test   %eax,%eax
80104da9:	75 39                	jne    80104de4 <memset+0x50>
    c &= 0xFF;
80104dab:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104db2:	8b 45 10             	mov    0x10(%ebp),%eax
80104db5:	c1 e8 02             	shr    $0x2,%eax
80104db8:	89 c2                	mov    %eax,%edx
80104dba:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dbd:	c1 e0 18             	shl    $0x18,%eax
80104dc0:	89 c1                	mov    %eax,%ecx
80104dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc5:	c1 e0 10             	shl    $0x10,%eax
80104dc8:	09 c1                	or     %eax,%ecx
80104dca:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dcd:	c1 e0 08             	shl    $0x8,%eax
80104dd0:	09 c8                	or     %ecx,%eax
80104dd2:	0b 45 0c             	or     0xc(%ebp),%eax
80104dd5:	52                   	push   %edx
80104dd6:	50                   	push   %eax
80104dd7:	ff 75 08             	push   0x8(%ebp)
80104dda:	e8 8f ff ff ff       	call   80104d6e <stosl>
80104ddf:	83 c4 0c             	add    $0xc,%esp
80104de2:	eb 12                	jmp    80104df6 <memset+0x62>
  } else
    stosb(dst, c, n);
80104de4:	8b 45 10             	mov    0x10(%ebp),%eax
80104de7:	50                   	push   %eax
80104de8:	ff 75 0c             	push   0xc(%ebp)
80104deb:	ff 75 08             	push   0x8(%ebp)
80104dee:	e8 55 ff ff ff       	call   80104d48 <stosb>
80104df3:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104df6:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104df9:	c9                   	leave  
80104dfa:	c3                   	ret    

80104dfb <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104dfb:	55                   	push   %ebp
80104dfc:	89 e5                	mov    %esp,%ebp
80104dfe:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104e01:	8b 45 08             	mov    0x8(%ebp),%eax
80104e04:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e07:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e0a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e0d:	eb 30                	jmp    80104e3f <memcmp+0x44>
    if(*s1 != *s2)
80104e0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e12:	0f b6 10             	movzbl (%eax),%edx
80104e15:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e18:	0f b6 00             	movzbl (%eax),%eax
80104e1b:	38 c2                	cmp    %al,%dl
80104e1d:	74 18                	je     80104e37 <memcmp+0x3c>
      return *s1 - *s2;
80104e1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e22:	0f b6 00             	movzbl (%eax),%eax
80104e25:	0f b6 d0             	movzbl %al,%edx
80104e28:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e2b:	0f b6 00             	movzbl (%eax),%eax
80104e2e:	0f b6 c8             	movzbl %al,%ecx
80104e31:	89 d0                	mov    %edx,%eax
80104e33:	29 c8                	sub    %ecx,%eax
80104e35:	eb 1a                	jmp    80104e51 <memcmp+0x56>
    s1++, s2++;
80104e37:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e3b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104e3f:	8b 45 10             	mov    0x10(%ebp),%eax
80104e42:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e45:	89 55 10             	mov    %edx,0x10(%ebp)
80104e48:	85 c0                	test   %eax,%eax
80104e4a:	75 c3                	jne    80104e0f <memcmp+0x14>
  }

  return 0;
80104e4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e51:	c9                   	leave  
80104e52:	c3                   	ret    

80104e53 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e53:	55                   	push   %ebp
80104e54:	89 e5                	mov    %esp,%ebp
80104e56:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e59:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e62:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e68:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e6b:	73 54                	jae    80104ec1 <memmove+0x6e>
80104e6d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e70:	8b 45 10             	mov    0x10(%ebp),%eax
80104e73:	01 d0                	add    %edx,%eax
80104e75:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104e78:	73 47                	jae    80104ec1 <memmove+0x6e>
    s += n;
80104e7a:	8b 45 10             	mov    0x10(%ebp),%eax
80104e7d:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e80:	8b 45 10             	mov    0x10(%ebp),%eax
80104e83:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e86:	eb 13                	jmp    80104e9b <memmove+0x48>
      *--d = *--s;
80104e88:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e8c:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e90:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e93:	0f b6 10             	movzbl (%eax),%edx
80104e96:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e99:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e9b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e9e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ea1:	89 55 10             	mov    %edx,0x10(%ebp)
80104ea4:	85 c0                	test   %eax,%eax
80104ea6:	75 e0                	jne    80104e88 <memmove+0x35>
  if(s < d && s + n > d){
80104ea8:	eb 24                	jmp    80104ece <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104eaa:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ead:	8d 42 01             	lea    0x1(%edx),%eax
80104eb0:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104eb3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104eb6:	8d 48 01             	lea    0x1(%eax),%ecx
80104eb9:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ebc:	0f b6 12             	movzbl (%edx),%edx
80104ebf:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ec1:	8b 45 10             	mov    0x10(%ebp),%eax
80104ec4:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ec7:	89 55 10             	mov    %edx,0x10(%ebp)
80104eca:	85 c0                	test   %eax,%eax
80104ecc:	75 dc                	jne    80104eaa <memmove+0x57>

  return dst;
80104ece:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ed1:	c9                   	leave  
80104ed2:	c3                   	ret    

80104ed3 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ed3:	55                   	push   %ebp
80104ed4:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ed6:	ff 75 10             	push   0x10(%ebp)
80104ed9:	ff 75 0c             	push   0xc(%ebp)
80104edc:	ff 75 08             	push   0x8(%ebp)
80104edf:	e8 6f ff ff ff       	call   80104e53 <memmove>
80104ee4:	83 c4 0c             	add    $0xc,%esp
}
80104ee7:	c9                   	leave  
80104ee8:	c3                   	ret    

80104ee9 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ee9:	55                   	push   %ebp
80104eea:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104eec:	eb 0c                	jmp    80104efa <strncmp+0x11>
    n--, p++, q++;
80104eee:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ef2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ef6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104efa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104efe:	74 1a                	je     80104f1a <strncmp+0x31>
80104f00:	8b 45 08             	mov    0x8(%ebp),%eax
80104f03:	0f b6 00             	movzbl (%eax),%eax
80104f06:	84 c0                	test   %al,%al
80104f08:	74 10                	je     80104f1a <strncmp+0x31>
80104f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0d:	0f b6 10             	movzbl (%eax),%edx
80104f10:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f13:	0f b6 00             	movzbl (%eax),%eax
80104f16:	38 c2                	cmp    %al,%dl
80104f18:	74 d4                	je     80104eee <strncmp+0x5>
  if(n == 0)
80104f1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f1e:	75 07                	jne    80104f27 <strncmp+0x3e>
    return 0;
80104f20:	b8 00 00 00 00       	mov    $0x0,%eax
80104f25:	eb 16                	jmp    80104f3d <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104f27:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2a:	0f b6 00             	movzbl (%eax),%eax
80104f2d:	0f b6 d0             	movzbl %al,%edx
80104f30:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f33:	0f b6 00             	movzbl (%eax),%eax
80104f36:	0f b6 c8             	movzbl %al,%ecx
80104f39:	89 d0                	mov    %edx,%eax
80104f3b:	29 c8                	sub    %ecx,%eax
}
80104f3d:	5d                   	pop    %ebp
80104f3e:	c3                   	ret    

80104f3f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f3f:	55                   	push   %ebp
80104f40:	89 e5                	mov    %esp,%ebp
80104f42:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f45:	8b 45 08             	mov    0x8(%ebp),%eax
80104f48:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f4b:	90                   	nop
80104f4c:	8b 45 10             	mov    0x10(%ebp),%eax
80104f4f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f52:	89 55 10             	mov    %edx,0x10(%ebp)
80104f55:	85 c0                	test   %eax,%eax
80104f57:	7e 2c                	jle    80104f85 <strncpy+0x46>
80104f59:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f5c:	8d 42 01             	lea    0x1(%edx),%eax
80104f5f:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f62:	8b 45 08             	mov    0x8(%ebp),%eax
80104f65:	8d 48 01             	lea    0x1(%eax),%ecx
80104f68:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f6b:	0f b6 12             	movzbl (%edx),%edx
80104f6e:	88 10                	mov    %dl,(%eax)
80104f70:	0f b6 00             	movzbl (%eax),%eax
80104f73:	84 c0                	test   %al,%al
80104f75:	75 d5                	jne    80104f4c <strncpy+0xd>
    ;
  while(n-- > 0)
80104f77:	eb 0c                	jmp    80104f85 <strncpy+0x46>
    *s++ = 0;
80104f79:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7c:	8d 50 01             	lea    0x1(%eax),%edx
80104f7f:	89 55 08             	mov    %edx,0x8(%ebp)
80104f82:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104f85:	8b 45 10             	mov    0x10(%ebp),%eax
80104f88:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f8b:	89 55 10             	mov    %edx,0x10(%ebp)
80104f8e:	85 c0                	test   %eax,%eax
80104f90:	7f e7                	jg     80104f79 <strncpy+0x3a>
  return os;
80104f92:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f95:	c9                   	leave  
80104f96:	c3                   	ret    

80104f97 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f97:	55                   	push   %ebp
80104f98:	89 e5                	mov    %esp,%ebp
80104f9a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104fa3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fa7:	7f 05                	jg     80104fae <safestrcpy+0x17>
    return os;
80104fa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fac:	eb 32                	jmp    80104fe0 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104fae:	90                   	nop
80104faf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fb7:	7e 1e                	jle    80104fd7 <safestrcpy+0x40>
80104fb9:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fbc:	8d 42 01             	lea    0x1(%edx),%eax
80104fbf:	89 45 0c             	mov    %eax,0xc(%ebp)
80104fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc5:	8d 48 01             	lea    0x1(%eax),%ecx
80104fc8:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fcb:	0f b6 12             	movzbl (%edx),%edx
80104fce:	88 10                	mov    %dl,(%eax)
80104fd0:	0f b6 00             	movzbl (%eax),%eax
80104fd3:	84 c0                	test   %al,%al
80104fd5:	75 d8                	jne    80104faf <safestrcpy+0x18>
    ;
  *s = 0;
80104fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104fda:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104fdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fe0:	c9                   	leave  
80104fe1:	c3                   	ret    

80104fe2 <strlen>:

int
strlen(const char *s)
{
80104fe2:	55                   	push   %ebp
80104fe3:	89 e5                	mov    %esp,%ebp
80104fe5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104fe8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104fef:	eb 04                	jmp    80104ff5 <strlen+0x13>
80104ff1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ff5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ffb:	01 d0                	add    %edx,%eax
80104ffd:	0f b6 00             	movzbl (%eax),%eax
80105000:	84 c0                	test   %al,%al
80105002:	75 ed                	jne    80104ff1 <strlen+0xf>
    ;
  return n;
80105004:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105007:	c9                   	leave  
80105008:	c3                   	ret    

80105009 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105009:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010500d:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105011:	55                   	push   %ebp
  pushl %ebx
80105012:	53                   	push   %ebx
  pushl %esi
80105013:	56                   	push   %esi
  pushl %edi
80105014:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105015:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105017:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105019:	5f                   	pop    %edi
  popl %esi
8010501a:	5e                   	pop    %esi
  popl %ebx
8010501b:	5b                   	pop    %ebx
  popl %ebp
8010501c:	5d                   	pop    %ebp
  ret
8010501d:	c3                   	ret    

8010501e <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010501e:	55                   	push   %ebp
8010501f:	89 e5                	mov    %esp,%ebp
80105021:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105024:	e8 07 ea ff ff       	call   80103a30 <myproc>
80105029:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010502c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502f:	8b 00                	mov    (%eax),%eax
80105031:	39 45 08             	cmp    %eax,0x8(%ebp)
80105034:	73 0f                	jae    80105045 <fetchint+0x27>
80105036:	8b 45 08             	mov    0x8(%ebp),%eax
80105039:	8d 50 04             	lea    0x4(%eax),%edx
8010503c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503f:	8b 00                	mov    (%eax),%eax
80105041:	39 c2                	cmp    %eax,%edx
80105043:	76 07                	jbe    8010504c <fetchint+0x2e>
    return -1;
80105045:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010504a:	eb 0f                	jmp    8010505b <fetchint+0x3d>
  *ip = *(int*)(addr);
8010504c:	8b 45 08             	mov    0x8(%ebp),%eax
8010504f:	8b 10                	mov    (%eax),%edx
80105051:	8b 45 0c             	mov    0xc(%ebp),%eax
80105054:	89 10                	mov    %edx,(%eax)
  return 0;
80105056:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010505b:	c9                   	leave  
8010505c:	c3                   	ret    

8010505d <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010505d:	55                   	push   %ebp
8010505e:	89 e5                	mov    %esp,%ebp
80105060:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105063:	e8 c8 e9 ff ff       	call   80103a30 <myproc>
80105068:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010506b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506e:	8b 00                	mov    (%eax),%eax
80105070:	39 45 08             	cmp    %eax,0x8(%ebp)
80105073:	72 07                	jb     8010507c <fetchstr+0x1f>
    return -1;
80105075:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010507a:	eb 41                	jmp    801050bd <fetchstr+0x60>
  *pp = (char*)addr;
8010507c:	8b 55 08             	mov    0x8(%ebp),%edx
8010507f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105082:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105087:	8b 00                	mov    (%eax),%eax
80105089:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010508c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010508f:	8b 00                	mov    (%eax),%eax
80105091:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105094:	eb 1a                	jmp    801050b0 <fetchstr+0x53>
    if(*s == 0)
80105096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105099:	0f b6 00             	movzbl (%eax),%eax
8010509c:	84 c0                	test   %al,%al
8010509e:	75 0c                	jne    801050ac <fetchstr+0x4f>
      return s - *pp;
801050a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801050a3:	8b 10                	mov    (%eax),%edx
801050a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a8:	29 d0                	sub    %edx,%eax
801050aa:	eb 11                	jmp    801050bd <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
801050ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801050b6:	72 de                	jb     80105096 <fetchstr+0x39>
  }
  return -1;
801050b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050bd:	c9                   	leave  
801050be:	c3                   	ret    

801050bf <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801050bf:	55                   	push   %ebp
801050c0:	89 e5                	mov    %esp,%ebp
801050c2:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801050c5:	e8 66 e9 ff ff       	call   80103a30 <myproc>
801050ca:	8b 40 18             	mov    0x18(%eax),%eax
801050cd:	8b 50 44             	mov    0x44(%eax),%edx
801050d0:	8b 45 08             	mov    0x8(%ebp),%eax
801050d3:	c1 e0 02             	shl    $0x2,%eax
801050d6:	01 d0                	add    %edx,%eax
801050d8:	83 c0 04             	add    $0x4,%eax
801050db:	83 ec 08             	sub    $0x8,%esp
801050de:	ff 75 0c             	push   0xc(%ebp)
801050e1:	50                   	push   %eax
801050e2:	e8 37 ff ff ff       	call   8010501e <fetchint>
801050e7:	83 c4 10             	add    $0x10,%esp
}
801050ea:	c9                   	leave  
801050eb:	c3                   	ret    

801050ec <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801050ec:	55                   	push   %ebp
801050ed:	89 e5                	mov    %esp,%ebp
801050ef:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801050f2:	e8 39 e9 ff ff       	call   80103a30 <myproc>
801050f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801050fa:	83 ec 08             	sub    $0x8,%esp
801050fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105100:	50                   	push   %eax
80105101:	ff 75 08             	push   0x8(%ebp)
80105104:	e8 b6 ff ff ff       	call   801050bf <argint>
80105109:	83 c4 10             	add    $0x10,%esp
8010510c:	85 c0                	test   %eax,%eax
8010510e:	79 07                	jns    80105117 <argptr+0x2b>
    return -1;
80105110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105115:	eb 3b                	jmp    80105152 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105117:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010511b:	78 1f                	js     8010513c <argptr+0x50>
8010511d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105120:	8b 00                	mov    (%eax),%eax
80105122:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105125:	39 d0                	cmp    %edx,%eax
80105127:	76 13                	jbe    8010513c <argptr+0x50>
80105129:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010512c:	89 c2                	mov    %eax,%edx
8010512e:	8b 45 10             	mov    0x10(%ebp),%eax
80105131:	01 c2                	add    %eax,%edx
80105133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105136:	8b 00                	mov    (%eax),%eax
80105138:	39 c2                	cmp    %eax,%edx
8010513a:	76 07                	jbe    80105143 <argptr+0x57>
    return -1;
8010513c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105141:	eb 0f                	jmp    80105152 <argptr+0x66>
  *pp = (char*)i;
80105143:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105146:	89 c2                	mov    %eax,%edx
80105148:	8b 45 0c             	mov    0xc(%ebp),%eax
8010514b:	89 10                	mov    %edx,(%eax)
  return 0;
8010514d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105152:	c9                   	leave  
80105153:	c3                   	ret    

80105154 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105154:	55                   	push   %ebp
80105155:	89 e5                	mov    %esp,%ebp
80105157:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010515a:	83 ec 08             	sub    $0x8,%esp
8010515d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105160:	50                   	push   %eax
80105161:	ff 75 08             	push   0x8(%ebp)
80105164:	e8 56 ff ff ff       	call   801050bf <argint>
80105169:	83 c4 10             	add    $0x10,%esp
8010516c:	85 c0                	test   %eax,%eax
8010516e:	79 07                	jns    80105177 <argstr+0x23>
    return -1;
80105170:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105175:	eb 12                	jmp    80105189 <argstr+0x35>
  return fetchstr(addr, pp);
80105177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517a:	83 ec 08             	sub    $0x8,%esp
8010517d:	ff 75 0c             	push   0xc(%ebp)
80105180:	50                   	push   %eax
80105181:	e8 d7 fe ff ff       	call   8010505d <fetchstr>
80105186:	83 c4 10             	add    $0x10,%esp
}
80105189:	c9                   	leave  
8010518a:	c3                   	ret    

8010518b <syscall>:
[SYS_getpinfo] sys_getpinfo,
};

void
syscall(void)
{
8010518b:	55                   	push   %ebp
8010518c:	89 e5                	mov    %esp,%ebp
8010518e:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105191:	e8 9a e8 ff ff       	call   80103a30 <myproc>
80105196:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519c:	8b 40 18             	mov    0x18(%eax),%eax
8010519f:	8b 40 1c             	mov    0x1c(%eax),%eax
801051a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801051a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801051a9:	7e 2f                	jle    801051da <syscall+0x4f>
801051ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ae:	83 f8 17             	cmp    $0x17,%eax
801051b1:	77 27                	ja     801051da <syscall+0x4f>
801051b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051b6:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801051bd:	85 c0                	test   %eax,%eax
801051bf:	74 19                	je     801051da <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801051c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051c4:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801051cb:	ff d0                	call   *%eax
801051cd:	89 c2                	mov    %eax,%edx
801051cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d2:	8b 40 18             	mov    0x18(%eax),%eax
801051d5:	89 50 1c             	mov    %edx,0x1c(%eax)
801051d8:	eb 2c                	jmp    80105206 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801051da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051dd:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801051e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e3:	8b 40 10             	mov    0x10(%eax),%eax
801051e6:	ff 75 f0             	push   -0x10(%ebp)
801051e9:	52                   	push   %edx
801051ea:	50                   	push   %eax
801051eb:	68 98 a8 10 80       	push   $0x8010a898
801051f0:	e8 ff b1 ff ff       	call   801003f4 <cprintf>
801051f5:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801051f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fb:	8b 40 18             	mov    0x18(%eax),%eax
801051fe:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105205:	90                   	nop
80105206:	90                   	nop
80105207:	c9                   	leave  
80105208:	c3                   	ret    

80105209 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105209:	55                   	push   %ebp
8010520a:	89 e5                	mov    %esp,%ebp
8010520c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010520f:	83 ec 08             	sub    $0x8,%esp
80105212:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105215:	50                   	push   %eax
80105216:	ff 75 08             	push   0x8(%ebp)
80105219:	e8 a1 fe ff ff       	call   801050bf <argint>
8010521e:	83 c4 10             	add    $0x10,%esp
80105221:	85 c0                	test   %eax,%eax
80105223:	79 07                	jns    8010522c <argfd+0x23>
    return -1;
80105225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010522a:	eb 4f                	jmp    8010527b <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010522c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010522f:	85 c0                	test   %eax,%eax
80105231:	78 20                	js     80105253 <argfd+0x4a>
80105233:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105236:	83 f8 0f             	cmp    $0xf,%eax
80105239:	7f 18                	jg     80105253 <argfd+0x4a>
8010523b:	e8 f0 e7 ff ff       	call   80103a30 <myproc>
80105240:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105243:	83 c2 08             	add    $0x8,%edx
80105246:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010524a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010524d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105251:	75 07                	jne    8010525a <argfd+0x51>
    return -1;
80105253:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105258:	eb 21                	jmp    8010527b <argfd+0x72>
  if(pfd)
8010525a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010525e:	74 08                	je     80105268 <argfd+0x5f>
    *pfd = fd;
80105260:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105263:	8b 45 0c             	mov    0xc(%ebp),%eax
80105266:	89 10                	mov    %edx,(%eax)
  if(pf)
80105268:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010526c:	74 08                	je     80105276 <argfd+0x6d>
    *pf = f;
8010526e:	8b 45 10             	mov    0x10(%ebp),%eax
80105271:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105274:	89 10                	mov    %edx,(%eax)
  return 0;
80105276:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010527b:	c9                   	leave  
8010527c:	c3                   	ret    

8010527d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010527d:	55                   	push   %ebp
8010527e:	89 e5                	mov    %esp,%ebp
80105280:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105283:	e8 a8 e7 ff ff       	call   80103a30 <myproc>
80105288:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010528b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105292:	eb 2a                	jmp    801052be <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105294:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105297:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010529a:	83 c2 08             	add    $0x8,%edx
8010529d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052a1:	85 c0                	test   %eax,%eax
801052a3:	75 15                	jne    801052ba <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801052a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052ab:	8d 4a 08             	lea    0x8(%edx),%ecx
801052ae:	8b 55 08             	mov    0x8(%ebp),%edx
801052b1:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801052b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b8:	eb 0f                	jmp    801052c9 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801052ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052be:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801052c2:	7e d0                	jle    80105294 <fdalloc+0x17>
    }
  }
  return -1;
801052c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052c9:	c9                   	leave  
801052ca:	c3                   	ret    

801052cb <sys_dup>:

int
sys_dup(void)
{
801052cb:	55                   	push   %ebp
801052cc:	89 e5                	mov    %esp,%ebp
801052ce:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801052d1:	83 ec 04             	sub    $0x4,%esp
801052d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052d7:	50                   	push   %eax
801052d8:	6a 00                	push   $0x0
801052da:	6a 00                	push   $0x0
801052dc:	e8 28 ff ff ff       	call   80105209 <argfd>
801052e1:	83 c4 10             	add    $0x10,%esp
801052e4:	85 c0                	test   %eax,%eax
801052e6:	79 07                	jns    801052ef <sys_dup+0x24>
    return -1;
801052e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ed:	eb 31                	jmp    80105320 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801052ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052f2:	83 ec 0c             	sub    $0xc,%esp
801052f5:	50                   	push   %eax
801052f6:	e8 82 ff ff ff       	call   8010527d <fdalloc>
801052fb:	83 c4 10             	add    $0x10,%esp
801052fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105301:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105305:	79 07                	jns    8010530e <sys_dup+0x43>
    return -1;
80105307:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010530c:	eb 12                	jmp    80105320 <sys_dup+0x55>
  filedup(f);
8010530e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105311:	83 ec 0c             	sub    $0xc,%esp
80105314:	50                   	push   %eax
80105315:	e8 30 bd ff ff       	call   8010104a <filedup>
8010531a:	83 c4 10             	add    $0x10,%esp
  return fd;
8010531d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105320:	c9                   	leave  
80105321:	c3                   	ret    

80105322 <sys_read>:

int
sys_read(void)
{
80105322:	55                   	push   %ebp
80105323:	89 e5                	mov    %esp,%ebp
80105325:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105328:	83 ec 04             	sub    $0x4,%esp
8010532b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010532e:	50                   	push   %eax
8010532f:	6a 00                	push   $0x0
80105331:	6a 00                	push   $0x0
80105333:	e8 d1 fe ff ff       	call   80105209 <argfd>
80105338:	83 c4 10             	add    $0x10,%esp
8010533b:	85 c0                	test   %eax,%eax
8010533d:	78 2e                	js     8010536d <sys_read+0x4b>
8010533f:	83 ec 08             	sub    $0x8,%esp
80105342:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105345:	50                   	push   %eax
80105346:	6a 02                	push   $0x2
80105348:	e8 72 fd ff ff       	call   801050bf <argint>
8010534d:	83 c4 10             	add    $0x10,%esp
80105350:	85 c0                	test   %eax,%eax
80105352:	78 19                	js     8010536d <sys_read+0x4b>
80105354:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105357:	83 ec 04             	sub    $0x4,%esp
8010535a:	50                   	push   %eax
8010535b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010535e:	50                   	push   %eax
8010535f:	6a 01                	push   $0x1
80105361:	e8 86 fd ff ff       	call   801050ec <argptr>
80105366:	83 c4 10             	add    $0x10,%esp
80105369:	85 c0                	test   %eax,%eax
8010536b:	79 07                	jns    80105374 <sys_read+0x52>
    return -1;
8010536d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105372:	eb 17                	jmp    8010538b <sys_read+0x69>
  return fileread(f, p, n);
80105374:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105377:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010537a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010537d:	83 ec 04             	sub    $0x4,%esp
80105380:	51                   	push   %ecx
80105381:	52                   	push   %edx
80105382:	50                   	push   %eax
80105383:	e8 52 be ff ff       	call   801011da <fileread>
80105388:	83 c4 10             	add    $0x10,%esp
}
8010538b:	c9                   	leave  
8010538c:	c3                   	ret    

8010538d <sys_write>:

int
sys_write(void)
{
8010538d:	55                   	push   %ebp
8010538e:	89 e5                	mov    %esp,%ebp
80105390:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105393:	83 ec 04             	sub    $0x4,%esp
80105396:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105399:	50                   	push   %eax
8010539a:	6a 00                	push   $0x0
8010539c:	6a 00                	push   $0x0
8010539e:	e8 66 fe ff ff       	call   80105209 <argfd>
801053a3:	83 c4 10             	add    $0x10,%esp
801053a6:	85 c0                	test   %eax,%eax
801053a8:	78 2e                	js     801053d8 <sys_write+0x4b>
801053aa:	83 ec 08             	sub    $0x8,%esp
801053ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053b0:	50                   	push   %eax
801053b1:	6a 02                	push   $0x2
801053b3:	e8 07 fd ff ff       	call   801050bf <argint>
801053b8:	83 c4 10             	add    $0x10,%esp
801053bb:	85 c0                	test   %eax,%eax
801053bd:	78 19                	js     801053d8 <sys_write+0x4b>
801053bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c2:	83 ec 04             	sub    $0x4,%esp
801053c5:	50                   	push   %eax
801053c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053c9:	50                   	push   %eax
801053ca:	6a 01                	push   $0x1
801053cc:	e8 1b fd ff ff       	call   801050ec <argptr>
801053d1:	83 c4 10             	add    $0x10,%esp
801053d4:	85 c0                	test   %eax,%eax
801053d6:	79 07                	jns    801053df <sys_write+0x52>
    return -1;
801053d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053dd:	eb 17                	jmp    801053f6 <sys_write+0x69>
  return filewrite(f, p, n);
801053df:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053e2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e8:	83 ec 04             	sub    $0x4,%esp
801053eb:	51                   	push   %ecx
801053ec:	52                   	push   %edx
801053ed:	50                   	push   %eax
801053ee:	e8 9f be ff ff       	call   80101292 <filewrite>
801053f3:	83 c4 10             	add    $0x10,%esp
}
801053f6:	c9                   	leave  
801053f7:	c3                   	ret    

801053f8 <sys_close>:

int
sys_close(void)
{
801053f8:	55                   	push   %ebp
801053f9:	89 e5                	mov    %esp,%ebp
801053fb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801053fe:	83 ec 04             	sub    $0x4,%esp
80105401:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105404:	50                   	push   %eax
80105405:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105408:	50                   	push   %eax
80105409:	6a 00                	push   $0x0
8010540b:	e8 f9 fd ff ff       	call   80105209 <argfd>
80105410:	83 c4 10             	add    $0x10,%esp
80105413:	85 c0                	test   %eax,%eax
80105415:	79 07                	jns    8010541e <sys_close+0x26>
    return -1;
80105417:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010541c:	eb 27                	jmp    80105445 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010541e:	e8 0d e6 ff ff       	call   80103a30 <myproc>
80105423:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105426:	83 c2 08             	add    $0x8,%edx
80105429:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105430:	00 
  fileclose(f);
80105431:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105434:	83 ec 0c             	sub    $0xc,%esp
80105437:	50                   	push   %eax
80105438:	e8 5e bc ff ff       	call   8010109b <fileclose>
8010543d:	83 c4 10             	add    $0x10,%esp
  return 0;
80105440:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105445:	c9                   	leave  
80105446:	c3                   	ret    

80105447 <sys_fstat>:

int
sys_fstat(void)
{
80105447:	55                   	push   %ebp
80105448:	89 e5                	mov    %esp,%ebp
8010544a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010544d:	83 ec 04             	sub    $0x4,%esp
80105450:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105453:	50                   	push   %eax
80105454:	6a 00                	push   $0x0
80105456:	6a 00                	push   $0x0
80105458:	e8 ac fd ff ff       	call   80105209 <argfd>
8010545d:	83 c4 10             	add    $0x10,%esp
80105460:	85 c0                	test   %eax,%eax
80105462:	78 17                	js     8010547b <sys_fstat+0x34>
80105464:	83 ec 04             	sub    $0x4,%esp
80105467:	6a 14                	push   $0x14
80105469:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010546c:	50                   	push   %eax
8010546d:	6a 01                	push   $0x1
8010546f:	e8 78 fc ff ff       	call   801050ec <argptr>
80105474:	83 c4 10             	add    $0x10,%esp
80105477:	85 c0                	test   %eax,%eax
80105479:	79 07                	jns    80105482 <sys_fstat+0x3b>
    return -1;
8010547b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105480:	eb 13                	jmp    80105495 <sys_fstat+0x4e>
  return filestat(f, st);
80105482:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105488:	83 ec 08             	sub    $0x8,%esp
8010548b:	52                   	push   %edx
8010548c:	50                   	push   %eax
8010548d:	e8 f1 bc ff ff       	call   80101183 <filestat>
80105492:	83 c4 10             	add    $0x10,%esp
}
80105495:	c9                   	leave  
80105496:	c3                   	ret    

80105497 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105497:	55                   	push   %ebp
80105498:	89 e5                	mov    %esp,%ebp
8010549a:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010549d:	83 ec 08             	sub    $0x8,%esp
801054a0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801054a3:	50                   	push   %eax
801054a4:	6a 00                	push   $0x0
801054a6:	e8 a9 fc ff ff       	call   80105154 <argstr>
801054ab:	83 c4 10             	add    $0x10,%esp
801054ae:	85 c0                	test   %eax,%eax
801054b0:	78 15                	js     801054c7 <sys_link+0x30>
801054b2:	83 ec 08             	sub    $0x8,%esp
801054b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
801054b8:	50                   	push   %eax
801054b9:	6a 01                	push   $0x1
801054bb:	e8 94 fc ff ff       	call   80105154 <argstr>
801054c0:	83 c4 10             	add    $0x10,%esp
801054c3:	85 c0                	test   %eax,%eax
801054c5:	79 0a                	jns    801054d1 <sys_link+0x3a>
    return -1;
801054c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054cc:	e9 68 01 00 00       	jmp    80105639 <sys_link+0x1a2>

  begin_op();
801054d1:	e8 66 db ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
801054d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054d9:	83 ec 0c             	sub    $0xc,%esp
801054dc:	50                   	push   %eax
801054dd:	e8 3b d0 ff ff       	call   8010251d <namei>
801054e2:	83 c4 10             	add    $0x10,%esp
801054e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054ec:	75 0f                	jne    801054fd <sys_link+0x66>
    end_op();
801054ee:	e8 d5 db ff ff       	call   801030c8 <end_op>
    return -1;
801054f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f8:	e9 3c 01 00 00       	jmp    80105639 <sys_link+0x1a2>
  }

  ilock(ip);
801054fd:	83 ec 0c             	sub    $0xc,%esp
80105500:	ff 75 f4             	push   -0xc(%ebp)
80105503:	e8 e2 c4 ff ff       	call   801019ea <ilock>
80105508:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010550b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105512:	66 83 f8 01          	cmp    $0x1,%ax
80105516:	75 1d                	jne    80105535 <sys_link+0x9e>
    iunlockput(ip);
80105518:	83 ec 0c             	sub    $0xc,%esp
8010551b:	ff 75 f4             	push   -0xc(%ebp)
8010551e:	e8 f8 c6 ff ff       	call   80101c1b <iunlockput>
80105523:	83 c4 10             	add    $0x10,%esp
    end_op();
80105526:	e8 9d db ff ff       	call   801030c8 <end_op>
    return -1;
8010552b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105530:	e9 04 01 00 00       	jmp    80105639 <sys_link+0x1a2>
  }

  ip->nlink++;
80105535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105538:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010553c:	83 c0 01             	add    $0x1,%eax
8010553f:	89 c2                	mov    %eax,%edx
80105541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105544:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105548:	83 ec 0c             	sub    $0xc,%esp
8010554b:	ff 75 f4             	push   -0xc(%ebp)
8010554e:	e8 ba c2 ff ff       	call   8010180d <iupdate>
80105553:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105556:	83 ec 0c             	sub    $0xc,%esp
80105559:	ff 75 f4             	push   -0xc(%ebp)
8010555c:	e8 9c c5 ff ff       	call   80101afd <iunlock>
80105561:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105564:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105567:	83 ec 08             	sub    $0x8,%esp
8010556a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010556d:	52                   	push   %edx
8010556e:	50                   	push   %eax
8010556f:	e8 c5 cf ff ff       	call   80102539 <nameiparent>
80105574:	83 c4 10             	add    $0x10,%esp
80105577:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010557a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010557e:	74 71                	je     801055f1 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105580:	83 ec 0c             	sub    $0xc,%esp
80105583:	ff 75 f0             	push   -0x10(%ebp)
80105586:	e8 5f c4 ff ff       	call   801019ea <ilock>
8010558b:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010558e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105591:	8b 10                	mov    (%eax),%edx
80105593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105596:	8b 00                	mov    (%eax),%eax
80105598:	39 c2                	cmp    %eax,%edx
8010559a:	75 1d                	jne    801055b9 <sys_link+0x122>
8010559c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559f:	8b 40 04             	mov    0x4(%eax),%eax
801055a2:	83 ec 04             	sub    $0x4,%esp
801055a5:	50                   	push   %eax
801055a6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801055a9:	50                   	push   %eax
801055aa:	ff 75 f0             	push   -0x10(%ebp)
801055ad:	e8 d4 cc ff ff       	call   80102286 <dirlink>
801055b2:	83 c4 10             	add    $0x10,%esp
801055b5:	85 c0                	test   %eax,%eax
801055b7:	79 10                	jns    801055c9 <sys_link+0x132>
    iunlockput(dp);
801055b9:	83 ec 0c             	sub    $0xc,%esp
801055bc:	ff 75 f0             	push   -0x10(%ebp)
801055bf:	e8 57 c6 ff ff       	call   80101c1b <iunlockput>
801055c4:	83 c4 10             	add    $0x10,%esp
    goto bad;
801055c7:	eb 29                	jmp    801055f2 <sys_link+0x15b>
  }
  iunlockput(dp);
801055c9:	83 ec 0c             	sub    $0xc,%esp
801055cc:	ff 75 f0             	push   -0x10(%ebp)
801055cf:	e8 47 c6 ff ff       	call   80101c1b <iunlockput>
801055d4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801055d7:	83 ec 0c             	sub    $0xc,%esp
801055da:	ff 75 f4             	push   -0xc(%ebp)
801055dd:	e8 69 c5 ff ff       	call   80101b4b <iput>
801055e2:	83 c4 10             	add    $0x10,%esp

  end_op();
801055e5:	e8 de da ff ff       	call   801030c8 <end_op>

  return 0;
801055ea:	b8 00 00 00 00       	mov    $0x0,%eax
801055ef:	eb 48                	jmp    80105639 <sys_link+0x1a2>
    goto bad;
801055f1:	90                   	nop

bad:
  ilock(ip);
801055f2:	83 ec 0c             	sub    $0xc,%esp
801055f5:	ff 75 f4             	push   -0xc(%ebp)
801055f8:	e8 ed c3 ff ff       	call   801019ea <ilock>
801055fd:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105603:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105607:	83 e8 01             	sub    $0x1,%eax
8010560a:	89 c2                	mov    %eax,%edx
8010560c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105613:	83 ec 0c             	sub    $0xc,%esp
80105616:	ff 75 f4             	push   -0xc(%ebp)
80105619:	e8 ef c1 ff ff       	call   8010180d <iupdate>
8010561e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105621:	83 ec 0c             	sub    $0xc,%esp
80105624:	ff 75 f4             	push   -0xc(%ebp)
80105627:	e8 ef c5 ff ff       	call   80101c1b <iunlockput>
8010562c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010562f:	e8 94 da ff ff       	call   801030c8 <end_op>
  return -1;
80105634:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105639:	c9                   	leave  
8010563a:	c3                   	ret    

8010563b <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010563b:	55                   	push   %ebp
8010563c:	89 e5                	mov    %esp,%ebp
8010563e:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105641:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105648:	eb 40                	jmp    8010568a <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010564a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564d:	6a 10                	push   $0x10
8010564f:	50                   	push   %eax
80105650:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105653:	50                   	push   %eax
80105654:	ff 75 08             	push   0x8(%ebp)
80105657:	e8 7a c8 ff ff       	call   80101ed6 <readi>
8010565c:	83 c4 10             	add    $0x10,%esp
8010565f:	83 f8 10             	cmp    $0x10,%eax
80105662:	74 0d                	je     80105671 <isdirempty+0x36>
      panic("isdirempty: readi");
80105664:	83 ec 0c             	sub    $0xc,%esp
80105667:	68 b4 a8 10 80       	push   $0x8010a8b4
8010566c:	e8 38 af ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105671:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105675:	66 85 c0             	test   %ax,%ax
80105678:	74 07                	je     80105681 <isdirempty+0x46>
      return 0;
8010567a:	b8 00 00 00 00       	mov    $0x0,%eax
8010567f:	eb 1b                	jmp    8010569c <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105684:	83 c0 10             	add    $0x10,%eax
80105687:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010568a:	8b 45 08             	mov    0x8(%ebp),%eax
8010568d:	8b 50 58             	mov    0x58(%eax),%edx
80105690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105693:	39 c2                	cmp    %eax,%edx
80105695:	77 b3                	ja     8010564a <isdirempty+0xf>
  }
  return 1;
80105697:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010569c:	c9                   	leave  
8010569d:	c3                   	ret    

8010569e <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010569e:	55                   	push   %ebp
8010569f:	89 e5                	mov    %esp,%ebp
801056a1:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801056a4:	83 ec 08             	sub    $0x8,%esp
801056a7:	8d 45 cc             	lea    -0x34(%ebp),%eax
801056aa:	50                   	push   %eax
801056ab:	6a 00                	push   $0x0
801056ad:	e8 a2 fa ff ff       	call   80105154 <argstr>
801056b2:	83 c4 10             	add    $0x10,%esp
801056b5:	85 c0                	test   %eax,%eax
801056b7:	79 0a                	jns    801056c3 <sys_unlink+0x25>
    return -1;
801056b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056be:	e9 bf 01 00 00       	jmp    80105882 <sys_unlink+0x1e4>

  begin_op();
801056c3:	e8 74 d9 ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801056c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801056cb:	83 ec 08             	sub    $0x8,%esp
801056ce:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801056d1:	52                   	push   %edx
801056d2:	50                   	push   %eax
801056d3:	e8 61 ce ff ff       	call   80102539 <nameiparent>
801056d8:	83 c4 10             	add    $0x10,%esp
801056db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056e2:	75 0f                	jne    801056f3 <sys_unlink+0x55>
    end_op();
801056e4:	e8 df d9 ff ff       	call   801030c8 <end_op>
    return -1;
801056e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ee:	e9 8f 01 00 00       	jmp    80105882 <sys_unlink+0x1e4>
  }

  ilock(dp);
801056f3:	83 ec 0c             	sub    $0xc,%esp
801056f6:	ff 75 f4             	push   -0xc(%ebp)
801056f9:	e8 ec c2 ff ff       	call   801019ea <ilock>
801056fe:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105701:	83 ec 08             	sub    $0x8,%esp
80105704:	68 c6 a8 10 80       	push   $0x8010a8c6
80105709:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010570c:	50                   	push   %eax
8010570d:	e8 9f ca ff ff       	call   801021b1 <namecmp>
80105712:	83 c4 10             	add    $0x10,%esp
80105715:	85 c0                	test   %eax,%eax
80105717:	0f 84 49 01 00 00    	je     80105866 <sys_unlink+0x1c8>
8010571d:	83 ec 08             	sub    $0x8,%esp
80105720:	68 c8 a8 10 80       	push   $0x8010a8c8
80105725:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105728:	50                   	push   %eax
80105729:	e8 83 ca ff ff       	call   801021b1 <namecmp>
8010572e:	83 c4 10             	add    $0x10,%esp
80105731:	85 c0                	test   %eax,%eax
80105733:	0f 84 2d 01 00 00    	je     80105866 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105739:	83 ec 04             	sub    $0x4,%esp
8010573c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010573f:	50                   	push   %eax
80105740:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105743:	50                   	push   %eax
80105744:	ff 75 f4             	push   -0xc(%ebp)
80105747:	e8 80 ca ff ff       	call   801021cc <dirlookup>
8010574c:	83 c4 10             	add    $0x10,%esp
8010574f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105752:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105756:	0f 84 0d 01 00 00    	je     80105869 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010575c:	83 ec 0c             	sub    $0xc,%esp
8010575f:	ff 75 f0             	push   -0x10(%ebp)
80105762:	e8 83 c2 ff ff       	call   801019ea <ilock>
80105767:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010576a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105771:	66 85 c0             	test   %ax,%ax
80105774:	7f 0d                	jg     80105783 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105776:	83 ec 0c             	sub    $0xc,%esp
80105779:	68 cb a8 10 80       	push   $0x8010a8cb
8010577e:	e8 26 ae ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105786:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010578a:	66 83 f8 01          	cmp    $0x1,%ax
8010578e:	75 25                	jne    801057b5 <sys_unlink+0x117>
80105790:	83 ec 0c             	sub    $0xc,%esp
80105793:	ff 75 f0             	push   -0x10(%ebp)
80105796:	e8 a0 fe ff ff       	call   8010563b <isdirempty>
8010579b:	83 c4 10             	add    $0x10,%esp
8010579e:	85 c0                	test   %eax,%eax
801057a0:	75 13                	jne    801057b5 <sys_unlink+0x117>
    iunlockput(ip);
801057a2:	83 ec 0c             	sub    $0xc,%esp
801057a5:	ff 75 f0             	push   -0x10(%ebp)
801057a8:	e8 6e c4 ff ff       	call   80101c1b <iunlockput>
801057ad:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057b0:	e9 b5 00 00 00       	jmp    8010586a <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801057b5:	83 ec 04             	sub    $0x4,%esp
801057b8:	6a 10                	push   $0x10
801057ba:	6a 00                	push   $0x0
801057bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057bf:	50                   	push   %eax
801057c0:	e8 cf f5 ff ff       	call   80104d94 <memset>
801057c5:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057c8:	8b 45 c8             	mov    -0x38(%ebp),%eax
801057cb:	6a 10                	push   $0x10
801057cd:	50                   	push   %eax
801057ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057d1:	50                   	push   %eax
801057d2:	ff 75 f4             	push   -0xc(%ebp)
801057d5:	e8 51 c8 ff ff       	call   8010202b <writei>
801057da:	83 c4 10             	add    $0x10,%esp
801057dd:	83 f8 10             	cmp    $0x10,%eax
801057e0:	74 0d                	je     801057ef <sys_unlink+0x151>
    panic("unlink: writei");
801057e2:	83 ec 0c             	sub    $0xc,%esp
801057e5:	68 dd a8 10 80       	push   $0x8010a8dd
801057ea:	e8 ba ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801057ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057f6:	66 83 f8 01          	cmp    $0x1,%ax
801057fa:	75 21                	jne    8010581d <sys_unlink+0x17f>
    dp->nlink--;
801057fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ff:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105803:	83 e8 01             	sub    $0x1,%eax
80105806:	89 c2                	mov    %eax,%edx
80105808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580b:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010580f:	83 ec 0c             	sub    $0xc,%esp
80105812:	ff 75 f4             	push   -0xc(%ebp)
80105815:	e8 f3 bf ff ff       	call   8010180d <iupdate>
8010581a:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010581d:	83 ec 0c             	sub    $0xc,%esp
80105820:	ff 75 f4             	push   -0xc(%ebp)
80105823:	e8 f3 c3 ff ff       	call   80101c1b <iunlockput>
80105828:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010582b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105832:	83 e8 01             	sub    $0x1,%eax
80105835:	89 c2                	mov    %eax,%edx
80105837:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010583a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010583e:	83 ec 0c             	sub    $0xc,%esp
80105841:	ff 75 f0             	push   -0x10(%ebp)
80105844:	e8 c4 bf ff ff       	call   8010180d <iupdate>
80105849:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010584c:	83 ec 0c             	sub    $0xc,%esp
8010584f:	ff 75 f0             	push   -0x10(%ebp)
80105852:	e8 c4 c3 ff ff       	call   80101c1b <iunlockput>
80105857:	83 c4 10             	add    $0x10,%esp

  end_op();
8010585a:	e8 69 d8 ff ff       	call   801030c8 <end_op>

  return 0;
8010585f:	b8 00 00 00 00       	mov    $0x0,%eax
80105864:	eb 1c                	jmp    80105882 <sys_unlink+0x1e4>
    goto bad;
80105866:	90                   	nop
80105867:	eb 01                	jmp    8010586a <sys_unlink+0x1cc>
    goto bad;
80105869:	90                   	nop

bad:
  iunlockput(dp);
8010586a:	83 ec 0c             	sub    $0xc,%esp
8010586d:	ff 75 f4             	push   -0xc(%ebp)
80105870:	e8 a6 c3 ff ff       	call   80101c1b <iunlockput>
80105875:	83 c4 10             	add    $0x10,%esp
  end_op();
80105878:	e8 4b d8 ff ff       	call   801030c8 <end_op>
  return -1;
8010587d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105882:	c9                   	leave  
80105883:	c3                   	ret    

80105884 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105884:	55                   	push   %ebp
80105885:	89 e5                	mov    %esp,%ebp
80105887:	83 ec 38             	sub    $0x38,%esp
8010588a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010588d:	8b 55 10             	mov    0x10(%ebp),%edx
80105890:	8b 45 14             	mov    0x14(%ebp),%eax
80105893:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105897:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010589b:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010589f:	83 ec 08             	sub    $0x8,%esp
801058a2:	8d 45 de             	lea    -0x22(%ebp),%eax
801058a5:	50                   	push   %eax
801058a6:	ff 75 08             	push   0x8(%ebp)
801058a9:	e8 8b cc ff ff       	call   80102539 <nameiparent>
801058ae:	83 c4 10             	add    $0x10,%esp
801058b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058b8:	75 0a                	jne    801058c4 <create+0x40>
    return 0;
801058ba:	b8 00 00 00 00       	mov    $0x0,%eax
801058bf:	e9 90 01 00 00       	jmp    80105a54 <create+0x1d0>
  ilock(dp);
801058c4:	83 ec 0c             	sub    $0xc,%esp
801058c7:	ff 75 f4             	push   -0xc(%ebp)
801058ca:	e8 1b c1 ff ff       	call   801019ea <ilock>
801058cf:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801058d2:	83 ec 04             	sub    $0x4,%esp
801058d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058d8:	50                   	push   %eax
801058d9:	8d 45 de             	lea    -0x22(%ebp),%eax
801058dc:	50                   	push   %eax
801058dd:	ff 75 f4             	push   -0xc(%ebp)
801058e0:	e8 e7 c8 ff ff       	call   801021cc <dirlookup>
801058e5:	83 c4 10             	add    $0x10,%esp
801058e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058ef:	74 50                	je     80105941 <create+0xbd>
    iunlockput(dp);
801058f1:	83 ec 0c             	sub    $0xc,%esp
801058f4:	ff 75 f4             	push   -0xc(%ebp)
801058f7:	e8 1f c3 ff ff       	call   80101c1b <iunlockput>
801058fc:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801058ff:	83 ec 0c             	sub    $0xc,%esp
80105902:	ff 75 f0             	push   -0x10(%ebp)
80105905:	e8 e0 c0 ff ff       	call   801019ea <ilock>
8010590a:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010590d:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105912:	75 15                	jne    80105929 <create+0xa5>
80105914:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105917:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010591b:	66 83 f8 02          	cmp    $0x2,%ax
8010591f:	75 08                	jne    80105929 <create+0xa5>
      return ip;
80105921:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105924:	e9 2b 01 00 00       	jmp    80105a54 <create+0x1d0>
    iunlockput(ip);
80105929:	83 ec 0c             	sub    $0xc,%esp
8010592c:	ff 75 f0             	push   -0x10(%ebp)
8010592f:	e8 e7 c2 ff ff       	call   80101c1b <iunlockput>
80105934:	83 c4 10             	add    $0x10,%esp
    return 0;
80105937:	b8 00 00 00 00       	mov    $0x0,%eax
8010593c:	e9 13 01 00 00       	jmp    80105a54 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105941:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105948:	8b 00                	mov    (%eax),%eax
8010594a:	83 ec 08             	sub    $0x8,%esp
8010594d:	52                   	push   %edx
8010594e:	50                   	push   %eax
8010594f:	e8 e2 bd ff ff       	call   80101736 <ialloc>
80105954:	83 c4 10             	add    $0x10,%esp
80105957:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010595a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010595e:	75 0d                	jne    8010596d <create+0xe9>
    panic("create: ialloc");
80105960:	83 ec 0c             	sub    $0xc,%esp
80105963:	68 ec a8 10 80       	push   $0x8010a8ec
80105968:	e8 3c ac ff ff       	call   801005a9 <panic>

  ilock(ip);
8010596d:	83 ec 0c             	sub    $0xc,%esp
80105970:	ff 75 f0             	push   -0x10(%ebp)
80105973:	e8 72 c0 ff ff       	call   801019ea <ilock>
80105978:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010597b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597e:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105982:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105989:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010598d:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105991:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105994:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010599a:	83 ec 0c             	sub    $0xc,%esp
8010599d:	ff 75 f0             	push   -0x10(%ebp)
801059a0:	e8 68 be ff ff       	call   8010180d <iupdate>
801059a5:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801059a8:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059ad:	75 6a                	jne    80105a19 <create+0x195>
    dp->nlink++;  // for ".."
801059af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059b6:	83 c0 01             	add    $0x1,%eax
801059b9:	89 c2                	mov    %eax,%edx
801059bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059be:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801059c2:	83 ec 0c             	sub    $0xc,%esp
801059c5:	ff 75 f4             	push   -0xc(%ebp)
801059c8:	e8 40 be ff ff       	call   8010180d <iupdate>
801059cd:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801059d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d3:	8b 40 04             	mov    0x4(%eax),%eax
801059d6:	83 ec 04             	sub    $0x4,%esp
801059d9:	50                   	push   %eax
801059da:	68 c6 a8 10 80       	push   $0x8010a8c6
801059df:	ff 75 f0             	push   -0x10(%ebp)
801059e2:	e8 9f c8 ff ff       	call   80102286 <dirlink>
801059e7:	83 c4 10             	add    $0x10,%esp
801059ea:	85 c0                	test   %eax,%eax
801059ec:	78 1e                	js     80105a0c <create+0x188>
801059ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f1:	8b 40 04             	mov    0x4(%eax),%eax
801059f4:	83 ec 04             	sub    $0x4,%esp
801059f7:	50                   	push   %eax
801059f8:	68 c8 a8 10 80       	push   $0x8010a8c8
801059fd:	ff 75 f0             	push   -0x10(%ebp)
80105a00:	e8 81 c8 ff ff       	call   80102286 <dirlink>
80105a05:	83 c4 10             	add    $0x10,%esp
80105a08:	85 c0                	test   %eax,%eax
80105a0a:	79 0d                	jns    80105a19 <create+0x195>
      panic("create dots");
80105a0c:	83 ec 0c             	sub    $0xc,%esp
80105a0f:	68 fb a8 10 80       	push   $0x8010a8fb
80105a14:	e8 90 ab ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1c:	8b 40 04             	mov    0x4(%eax),%eax
80105a1f:	83 ec 04             	sub    $0x4,%esp
80105a22:	50                   	push   %eax
80105a23:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a26:	50                   	push   %eax
80105a27:	ff 75 f4             	push   -0xc(%ebp)
80105a2a:	e8 57 c8 ff ff       	call   80102286 <dirlink>
80105a2f:	83 c4 10             	add    $0x10,%esp
80105a32:	85 c0                	test   %eax,%eax
80105a34:	79 0d                	jns    80105a43 <create+0x1bf>
    panic("create: dirlink");
80105a36:	83 ec 0c             	sub    $0xc,%esp
80105a39:	68 07 a9 10 80       	push   $0x8010a907
80105a3e:	e8 66 ab ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105a43:	83 ec 0c             	sub    $0xc,%esp
80105a46:	ff 75 f4             	push   -0xc(%ebp)
80105a49:	e8 cd c1 ff ff       	call   80101c1b <iunlockput>
80105a4e:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a54:	c9                   	leave  
80105a55:	c3                   	ret    

80105a56 <sys_open>:

int
sys_open(void)
{
80105a56:	55                   	push   %ebp
80105a57:	89 e5                	mov    %esp,%ebp
80105a59:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a5c:	83 ec 08             	sub    $0x8,%esp
80105a5f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a62:	50                   	push   %eax
80105a63:	6a 00                	push   $0x0
80105a65:	e8 ea f6 ff ff       	call   80105154 <argstr>
80105a6a:	83 c4 10             	add    $0x10,%esp
80105a6d:	85 c0                	test   %eax,%eax
80105a6f:	78 15                	js     80105a86 <sys_open+0x30>
80105a71:	83 ec 08             	sub    $0x8,%esp
80105a74:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a77:	50                   	push   %eax
80105a78:	6a 01                	push   $0x1
80105a7a:	e8 40 f6 ff ff       	call   801050bf <argint>
80105a7f:	83 c4 10             	add    $0x10,%esp
80105a82:	85 c0                	test   %eax,%eax
80105a84:	79 0a                	jns    80105a90 <sys_open+0x3a>
    return -1;
80105a86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a8b:	e9 61 01 00 00       	jmp    80105bf1 <sys_open+0x19b>

  begin_op();
80105a90:	e8 a7 d5 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
80105a95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a98:	25 00 02 00 00       	and    $0x200,%eax
80105a9d:	85 c0                	test   %eax,%eax
80105a9f:	74 2a                	je     80105acb <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105aa1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105aa4:	6a 00                	push   $0x0
80105aa6:	6a 00                	push   $0x0
80105aa8:	6a 02                	push   $0x2
80105aaa:	50                   	push   %eax
80105aab:	e8 d4 fd ff ff       	call   80105884 <create>
80105ab0:	83 c4 10             	add    $0x10,%esp
80105ab3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ab6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aba:	75 75                	jne    80105b31 <sys_open+0xdb>
      end_op();
80105abc:	e8 07 d6 ff ff       	call   801030c8 <end_op>
      return -1;
80105ac1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac6:	e9 26 01 00 00       	jmp    80105bf1 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105acb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ace:	83 ec 0c             	sub    $0xc,%esp
80105ad1:	50                   	push   %eax
80105ad2:	e8 46 ca ff ff       	call   8010251d <namei>
80105ad7:	83 c4 10             	add    $0x10,%esp
80105ada:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105add:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ae1:	75 0f                	jne    80105af2 <sys_open+0x9c>
      end_op();
80105ae3:	e8 e0 d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105ae8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aed:	e9 ff 00 00 00       	jmp    80105bf1 <sys_open+0x19b>
    }
    ilock(ip);
80105af2:	83 ec 0c             	sub    $0xc,%esp
80105af5:	ff 75 f4             	push   -0xc(%ebp)
80105af8:	e8 ed be ff ff       	call   801019ea <ilock>
80105afd:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b03:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b07:	66 83 f8 01          	cmp    $0x1,%ax
80105b0b:	75 24                	jne    80105b31 <sys_open+0xdb>
80105b0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b10:	85 c0                	test   %eax,%eax
80105b12:	74 1d                	je     80105b31 <sys_open+0xdb>
      iunlockput(ip);
80105b14:	83 ec 0c             	sub    $0xc,%esp
80105b17:	ff 75 f4             	push   -0xc(%ebp)
80105b1a:	e8 fc c0 ff ff       	call   80101c1b <iunlockput>
80105b1f:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b22:	e8 a1 d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b2c:	e9 c0 00 00 00       	jmp    80105bf1 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b31:	e8 a7 b4 ff ff       	call   80100fdd <filealloc>
80105b36:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b3d:	74 17                	je     80105b56 <sys_open+0x100>
80105b3f:	83 ec 0c             	sub    $0xc,%esp
80105b42:	ff 75 f0             	push   -0x10(%ebp)
80105b45:	e8 33 f7 ff ff       	call   8010527d <fdalloc>
80105b4a:	83 c4 10             	add    $0x10,%esp
80105b4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b50:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b54:	79 2e                	jns    80105b84 <sys_open+0x12e>
    if(f)
80105b56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b5a:	74 0e                	je     80105b6a <sys_open+0x114>
      fileclose(f);
80105b5c:	83 ec 0c             	sub    $0xc,%esp
80105b5f:	ff 75 f0             	push   -0x10(%ebp)
80105b62:	e8 34 b5 ff ff       	call   8010109b <fileclose>
80105b67:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105b6a:	83 ec 0c             	sub    $0xc,%esp
80105b6d:	ff 75 f4             	push   -0xc(%ebp)
80105b70:	e8 a6 c0 ff ff       	call   80101c1b <iunlockput>
80105b75:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b78:	e8 4b d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105b7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b82:	eb 6d                	jmp    80105bf1 <sys_open+0x19b>
  }
  iunlock(ip);
80105b84:	83 ec 0c             	sub    $0xc,%esp
80105b87:	ff 75 f4             	push   -0xc(%ebp)
80105b8a:	e8 6e bf ff ff       	call   80101afd <iunlock>
80105b8f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b92:	e8 31 d5 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ba6:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bac:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105bb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bb6:	83 e0 01             	and    $0x1,%eax
80105bb9:	85 c0                	test   %eax,%eax
80105bbb:	0f 94 c0             	sete   %al
80105bbe:	89 c2                	mov    %eax,%edx
80105bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105bc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bc9:	83 e0 01             	and    $0x1,%eax
80105bcc:	85 c0                	test   %eax,%eax
80105bce:	75 0a                	jne    80105bda <sys_open+0x184>
80105bd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bd3:	83 e0 02             	and    $0x2,%eax
80105bd6:	85 c0                	test   %eax,%eax
80105bd8:	74 07                	je     80105be1 <sys_open+0x18b>
80105bda:	b8 01 00 00 00       	mov    $0x1,%eax
80105bdf:	eb 05                	jmp    80105be6 <sys_open+0x190>
80105be1:	b8 00 00 00 00       	mov    $0x0,%eax
80105be6:	89 c2                	mov    %eax,%edx
80105be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105beb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105bf1:	c9                   	leave  
80105bf2:	c3                   	ret    

80105bf3 <sys_mkdir>:

int
sys_mkdir(void)
{
80105bf3:	55                   	push   %ebp
80105bf4:	89 e5                	mov    %esp,%ebp
80105bf6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105bf9:	e8 3e d4 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105bfe:	83 ec 08             	sub    $0x8,%esp
80105c01:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c04:	50                   	push   %eax
80105c05:	6a 00                	push   $0x0
80105c07:	e8 48 f5 ff ff       	call   80105154 <argstr>
80105c0c:	83 c4 10             	add    $0x10,%esp
80105c0f:	85 c0                	test   %eax,%eax
80105c11:	78 1b                	js     80105c2e <sys_mkdir+0x3b>
80105c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c16:	6a 00                	push   $0x0
80105c18:	6a 00                	push   $0x0
80105c1a:	6a 01                	push   $0x1
80105c1c:	50                   	push   %eax
80105c1d:	e8 62 fc ff ff       	call   80105884 <create>
80105c22:	83 c4 10             	add    $0x10,%esp
80105c25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c2c:	75 0c                	jne    80105c3a <sys_mkdir+0x47>
    end_op();
80105c2e:	e8 95 d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c38:	eb 18                	jmp    80105c52 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105c3a:	83 ec 0c             	sub    $0xc,%esp
80105c3d:	ff 75 f4             	push   -0xc(%ebp)
80105c40:	e8 d6 bf ff ff       	call   80101c1b <iunlockput>
80105c45:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c48:	e8 7b d4 ff ff       	call   801030c8 <end_op>
  return 0;
80105c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c52:	c9                   	leave  
80105c53:	c3                   	ret    

80105c54 <sys_mknod>:

int
sys_mknod(void)
{
80105c54:	55                   	push   %ebp
80105c55:	89 e5                	mov    %esp,%ebp
80105c57:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c5a:	e8 dd d3 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c5f:	83 ec 08             	sub    $0x8,%esp
80105c62:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c65:	50                   	push   %eax
80105c66:	6a 00                	push   $0x0
80105c68:	e8 e7 f4 ff ff       	call   80105154 <argstr>
80105c6d:	83 c4 10             	add    $0x10,%esp
80105c70:	85 c0                	test   %eax,%eax
80105c72:	78 4f                	js     80105cc3 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105c74:	83 ec 08             	sub    $0x8,%esp
80105c77:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c7a:	50                   	push   %eax
80105c7b:	6a 01                	push   $0x1
80105c7d:	e8 3d f4 ff ff       	call   801050bf <argint>
80105c82:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c85:	85 c0                	test   %eax,%eax
80105c87:	78 3a                	js     80105cc3 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105c89:	83 ec 08             	sub    $0x8,%esp
80105c8c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c8f:	50                   	push   %eax
80105c90:	6a 02                	push   $0x2
80105c92:	e8 28 f4 ff ff       	call   801050bf <argint>
80105c97:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105c9a:	85 c0                	test   %eax,%eax
80105c9c:	78 25                	js     80105cc3 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ca1:	0f bf c8             	movswl %ax,%ecx
80105ca4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ca7:	0f bf d0             	movswl %ax,%edx
80105caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cad:	51                   	push   %ecx
80105cae:	52                   	push   %edx
80105caf:	6a 03                	push   $0x3
80105cb1:	50                   	push   %eax
80105cb2:	e8 cd fb ff ff       	call   80105884 <create>
80105cb7:	83 c4 10             	add    $0x10,%esp
80105cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105cbd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc1:	75 0c                	jne    80105ccf <sys_mknod+0x7b>
    end_op();
80105cc3:	e8 00 d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccd:	eb 18                	jmp    80105ce7 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105ccf:	83 ec 0c             	sub    $0xc,%esp
80105cd2:	ff 75 f4             	push   -0xc(%ebp)
80105cd5:	e8 41 bf ff ff       	call   80101c1b <iunlockput>
80105cda:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cdd:	e8 e6 d3 ff ff       	call   801030c8 <end_op>
  return 0;
80105ce2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ce7:	c9                   	leave  
80105ce8:	c3                   	ret    

80105ce9 <sys_chdir>:

int
sys_chdir(void)
{
80105ce9:	55                   	push   %ebp
80105cea:	89 e5                	mov    %esp,%ebp
80105cec:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105cef:	e8 3c dd ff ff       	call   80103a30 <myproc>
80105cf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105cf7:	e8 40 d3 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105cfc:	83 ec 08             	sub    $0x8,%esp
80105cff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d02:	50                   	push   %eax
80105d03:	6a 00                	push   $0x0
80105d05:	e8 4a f4 ff ff       	call   80105154 <argstr>
80105d0a:	83 c4 10             	add    $0x10,%esp
80105d0d:	85 c0                	test   %eax,%eax
80105d0f:	78 18                	js     80105d29 <sys_chdir+0x40>
80105d11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d14:	83 ec 0c             	sub    $0xc,%esp
80105d17:	50                   	push   %eax
80105d18:	e8 00 c8 ff ff       	call   8010251d <namei>
80105d1d:	83 c4 10             	add    $0x10,%esp
80105d20:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d27:	75 0c                	jne    80105d35 <sys_chdir+0x4c>
    end_op();
80105d29:	e8 9a d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105d2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d33:	eb 68                	jmp    80105d9d <sys_chdir+0xb4>
  }
  ilock(ip);
80105d35:	83 ec 0c             	sub    $0xc,%esp
80105d38:	ff 75 f0             	push   -0x10(%ebp)
80105d3b:	e8 aa bc ff ff       	call   801019ea <ilock>
80105d40:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d46:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d4a:	66 83 f8 01          	cmp    $0x1,%ax
80105d4e:	74 1a                	je     80105d6a <sys_chdir+0x81>
    iunlockput(ip);
80105d50:	83 ec 0c             	sub    $0xc,%esp
80105d53:	ff 75 f0             	push   -0x10(%ebp)
80105d56:	e8 c0 be ff ff       	call   80101c1b <iunlockput>
80105d5b:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d5e:	e8 65 d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105d63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d68:	eb 33                	jmp    80105d9d <sys_chdir+0xb4>
  }
  iunlock(ip);
80105d6a:	83 ec 0c             	sub    $0xc,%esp
80105d6d:	ff 75 f0             	push   -0x10(%ebp)
80105d70:	e8 88 bd ff ff       	call   80101afd <iunlock>
80105d75:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7b:	8b 40 68             	mov    0x68(%eax),%eax
80105d7e:	83 ec 0c             	sub    $0xc,%esp
80105d81:	50                   	push   %eax
80105d82:	e8 c4 bd ff ff       	call   80101b4b <iput>
80105d87:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d8a:	e8 39 d3 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d92:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d95:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d98:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d9d:	c9                   	leave  
80105d9e:	c3                   	ret    

80105d9f <sys_exec>:

int
sys_exec(void)
{
80105d9f:	55                   	push   %ebp
80105da0:	89 e5                	mov    %esp,%ebp
80105da2:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105da8:	83 ec 08             	sub    $0x8,%esp
80105dab:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dae:	50                   	push   %eax
80105daf:	6a 00                	push   $0x0
80105db1:	e8 9e f3 ff ff       	call   80105154 <argstr>
80105db6:	83 c4 10             	add    $0x10,%esp
80105db9:	85 c0                	test   %eax,%eax
80105dbb:	78 18                	js     80105dd5 <sys_exec+0x36>
80105dbd:	83 ec 08             	sub    $0x8,%esp
80105dc0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105dc6:	50                   	push   %eax
80105dc7:	6a 01                	push   $0x1
80105dc9:	e8 f1 f2 ff ff       	call   801050bf <argint>
80105dce:	83 c4 10             	add    $0x10,%esp
80105dd1:	85 c0                	test   %eax,%eax
80105dd3:	79 0a                	jns    80105ddf <sys_exec+0x40>
    return -1;
80105dd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dda:	e9 c6 00 00 00       	jmp    80105ea5 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105ddf:	83 ec 04             	sub    $0x4,%esp
80105de2:	68 80 00 00 00       	push   $0x80
80105de7:	6a 00                	push   $0x0
80105de9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105def:	50                   	push   %eax
80105df0:	e8 9f ef ff ff       	call   80104d94 <memset>
80105df5:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105df8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e02:	83 f8 1f             	cmp    $0x1f,%eax
80105e05:	76 0a                	jbe    80105e11 <sys_exec+0x72>
      return -1;
80105e07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e0c:	e9 94 00 00 00       	jmp    80105ea5 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e14:	c1 e0 02             	shl    $0x2,%eax
80105e17:	89 c2                	mov    %eax,%edx
80105e19:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e1f:	01 c2                	add    %eax,%edx
80105e21:	83 ec 08             	sub    $0x8,%esp
80105e24:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e2a:	50                   	push   %eax
80105e2b:	52                   	push   %edx
80105e2c:	e8 ed f1 ff ff       	call   8010501e <fetchint>
80105e31:	83 c4 10             	add    $0x10,%esp
80105e34:	85 c0                	test   %eax,%eax
80105e36:	79 07                	jns    80105e3f <sys_exec+0xa0>
      return -1;
80105e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e3d:	eb 66                	jmp    80105ea5 <sys_exec+0x106>
    if(uarg == 0){
80105e3f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e45:	85 c0                	test   %eax,%eax
80105e47:	75 27                	jne    80105e70 <sys_exec+0xd1>
      argv[i] = 0;
80105e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e53:	00 00 00 00 
      break;
80105e57:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5b:	83 ec 08             	sub    $0x8,%esp
80105e5e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e64:	52                   	push   %edx
80105e65:	50                   	push   %eax
80105e66:	e8 15 ad ff ff       	call   80100b80 <exec>
80105e6b:	83 c4 10             	add    $0x10,%esp
80105e6e:	eb 35                	jmp    80105ea5 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e70:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e79:	c1 e0 02             	shl    $0x2,%eax
80105e7c:	01 c2                	add    %eax,%edx
80105e7e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e84:	83 ec 08             	sub    $0x8,%esp
80105e87:	52                   	push   %edx
80105e88:	50                   	push   %eax
80105e89:	e8 cf f1 ff ff       	call   8010505d <fetchstr>
80105e8e:	83 c4 10             	add    $0x10,%esp
80105e91:	85 c0                	test   %eax,%eax
80105e93:	79 07                	jns    80105e9c <sys_exec+0xfd>
      return -1;
80105e95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e9a:	eb 09                	jmp    80105ea5 <sys_exec+0x106>
  for(i=0;; i++){
80105e9c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ea0:	e9 5a ff ff ff       	jmp    80105dff <sys_exec+0x60>
}
80105ea5:	c9                   	leave  
80105ea6:	c3                   	ret    

80105ea7 <sys_pipe>:

int
sys_pipe(void)
{
80105ea7:	55                   	push   %ebp
80105ea8:	89 e5                	mov    %esp,%ebp
80105eaa:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ead:	83 ec 04             	sub    $0x4,%esp
80105eb0:	6a 08                	push   $0x8
80105eb2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105eb5:	50                   	push   %eax
80105eb6:	6a 00                	push   $0x0
80105eb8:	e8 2f f2 ff ff       	call   801050ec <argptr>
80105ebd:	83 c4 10             	add    $0x10,%esp
80105ec0:	85 c0                	test   %eax,%eax
80105ec2:	79 0a                	jns    80105ece <sys_pipe+0x27>
    return -1;
80105ec4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec9:	e9 ae 00 00 00       	jmp    80105f7c <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105ece:	83 ec 08             	sub    $0x8,%esp
80105ed1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ed4:	50                   	push   %eax
80105ed5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ed8:	50                   	push   %eax
80105ed9:	e8 8f d6 ff ff       	call   8010356d <pipealloc>
80105ede:	83 c4 10             	add    $0x10,%esp
80105ee1:	85 c0                	test   %eax,%eax
80105ee3:	79 0a                	jns    80105eef <sys_pipe+0x48>
    return -1;
80105ee5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eea:	e9 8d 00 00 00       	jmp    80105f7c <sys_pipe+0xd5>
  fd0 = -1;
80105eef:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105ef6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ef9:	83 ec 0c             	sub    $0xc,%esp
80105efc:	50                   	push   %eax
80105efd:	e8 7b f3 ff ff       	call   8010527d <fdalloc>
80105f02:	83 c4 10             	add    $0x10,%esp
80105f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f0c:	78 18                	js     80105f26 <sys_pipe+0x7f>
80105f0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f11:	83 ec 0c             	sub    $0xc,%esp
80105f14:	50                   	push   %eax
80105f15:	e8 63 f3 ff ff       	call   8010527d <fdalloc>
80105f1a:	83 c4 10             	add    $0x10,%esp
80105f1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f24:	79 3e                	jns    80105f64 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105f26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f2a:	78 13                	js     80105f3f <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105f2c:	e8 ff da ff ff       	call   80103a30 <myproc>
80105f31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f34:	83 c2 08             	add    $0x8,%edx
80105f37:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f3e:	00 
    fileclose(rf);
80105f3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f42:	83 ec 0c             	sub    $0xc,%esp
80105f45:	50                   	push   %eax
80105f46:	e8 50 b1 ff ff       	call   8010109b <fileclose>
80105f4b:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f51:	83 ec 0c             	sub    $0xc,%esp
80105f54:	50                   	push   %eax
80105f55:	e8 41 b1 ff ff       	call   8010109b <fileclose>
80105f5a:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f62:	eb 18                	jmp    80105f7c <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105f64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f6a:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f6f:	8d 50 04             	lea    0x4(%eax),%edx
80105f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f75:	89 02                	mov    %eax,(%edx)
  return 0;
80105f77:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f7c:	c9                   	leave  
80105f7d:	c3                   	ret    

80105f7e <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
80105f7e:	55                   	push   %ebp
80105f7f:	89 e5                	mov    %esp,%ebp
80105f81:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105f84:	e8 e1 dd ff ff       	call   80103d6a <fork>
}
80105f89:	c9                   	leave  
80105f8a:	c3                   	ret    

80105f8b <sys_exit>:

int
sys_exit(void)
{
80105f8b:	55                   	push   %ebp
80105f8c:	89 e5                	mov    %esp,%ebp
80105f8e:	83 ec 08             	sub    $0x8,%esp
  exit();
80105f91:	e8 4d df ff ff       	call   80103ee3 <exit>
  return 0;  // not reached
80105f96:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f9b:	c9                   	leave  
80105f9c:	c3                   	ret    

80105f9d <sys_wait>:

int
sys_wait(void)
{
80105f9d:	55                   	push   %ebp
80105f9e:	89 e5                	mov    %esp,%ebp
80105fa0:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105fa3:	e8 5e e0 ff ff       	call   80104006 <wait>
}
80105fa8:	c9                   	leave  
80105fa9:	c3                   	ret    

80105faa <sys_kill>:

int
sys_kill(void)
{
80105faa:	55                   	push   %ebp
80105fab:	89 e5                	mov    %esp,%ebp
80105fad:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105fb0:	83 ec 08             	sub    $0x8,%esp
80105fb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fb6:	50                   	push   %eax
80105fb7:	6a 00                	push   $0x0
80105fb9:	e8 01 f1 ff ff       	call   801050bf <argint>
80105fbe:	83 c4 10             	add    $0x10,%esp
80105fc1:	85 c0                	test   %eax,%eax
80105fc3:	79 07                	jns    80105fcc <sys_kill+0x22>
    return -1;
80105fc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fca:	eb 0f                	jmp    80105fdb <sys_kill+0x31>
  return kill(pid);
80105fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fcf:	83 ec 0c             	sub    $0xc,%esp
80105fd2:	50                   	push   %eax
80105fd3:	e8 f6 e6 ff ff       	call   801046ce <kill>
80105fd8:	83 c4 10             	add    $0x10,%esp
}
80105fdb:	c9                   	leave  
80105fdc:	c3                   	ret    

80105fdd <sys_getpid>:

int
sys_getpid(void)
{
80105fdd:	55                   	push   %ebp
80105fde:	89 e5                	mov    %esp,%ebp
80105fe0:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105fe3:	e8 48 da ff ff       	call   80103a30 <myproc>
80105fe8:	8b 40 10             	mov    0x10(%eax),%eax
}
80105feb:	c9                   	leave  
80105fec:	c3                   	ret    

80105fed <sys_sbrk>:

int
sys_sbrk(void)
{
80105fed:	55                   	push   %ebp
80105fee:	89 e5                	mov    %esp,%ebp
80105ff0:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ff3:	83 ec 08             	sub    $0x8,%esp
80105ff6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ff9:	50                   	push   %eax
80105ffa:	6a 00                	push   $0x0
80105ffc:	e8 be f0 ff ff       	call   801050bf <argint>
80106001:	83 c4 10             	add    $0x10,%esp
80106004:	85 c0                	test   %eax,%eax
80106006:	79 07                	jns    8010600f <sys_sbrk+0x22>
    return -1;
80106008:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010600d:	eb 27                	jmp    80106036 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010600f:	e8 1c da ff ff       	call   80103a30 <myproc>
80106014:	8b 00                	mov    (%eax),%eax
80106016:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106019:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601c:	83 ec 0c             	sub    $0xc,%esp
8010601f:	50                   	push   %eax
80106020:	e8 aa dc ff ff       	call   80103ccf <growproc>
80106025:	83 c4 10             	add    $0x10,%esp
80106028:	85 c0                	test   %eax,%eax
8010602a:	79 07                	jns    80106033 <sys_sbrk+0x46>
    return -1;
8010602c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106031:	eb 03                	jmp    80106036 <sys_sbrk+0x49>
  return addr;
80106033:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106036:	c9                   	leave  
80106037:	c3                   	ret    

80106038 <sys_sleep>:

int
sys_sleep(void)
{
80106038:	55                   	push   %ebp
80106039:	89 e5                	mov    %esp,%ebp
8010603b:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010603e:	83 ec 08             	sub    $0x8,%esp
80106041:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106044:	50                   	push   %eax
80106045:	6a 00                	push   $0x0
80106047:	e8 73 f0 ff ff       	call   801050bf <argint>
8010604c:	83 c4 10             	add    $0x10,%esp
8010604f:	85 c0                	test   %eax,%eax
80106051:	79 07                	jns    8010605a <sys_sleep+0x22>
    return -1;
80106053:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106058:	eb 76                	jmp    801060d0 <sys_sleep+0x98>
  acquire(&tickslock);
8010605a:	83 ec 0c             	sub    $0xc,%esp
8010605d:	68 40 72 19 80       	push   $0x80197240
80106062:	e8 b7 ea ff ff       	call   80104b1e <acquire>
80106067:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010606a:	a1 74 72 19 80       	mov    0x80197274,%eax
8010606f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106072:	eb 38                	jmp    801060ac <sys_sleep+0x74>
    if(myproc()->killed){
80106074:	e8 b7 d9 ff ff       	call   80103a30 <myproc>
80106079:	8b 40 24             	mov    0x24(%eax),%eax
8010607c:	85 c0                	test   %eax,%eax
8010607e:	74 17                	je     80106097 <sys_sleep+0x5f>
      release(&tickslock);
80106080:	83 ec 0c             	sub    $0xc,%esp
80106083:	68 40 72 19 80       	push   $0x80197240
80106088:	e8 ff ea ff ff       	call   80104b8c <release>
8010608d:	83 c4 10             	add    $0x10,%esp
      return -1;
80106090:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106095:	eb 39                	jmp    801060d0 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106097:	83 ec 08             	sub    $0x8,%esp
8010609a:	68 40 72 19 80       	push   $0x80197240
8010609f:	68 74 72 19 80       	push   $0x80197274
801060a4:	e8 04 e5 ff ff       	call   801045ad <sleep>
801060a9:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801060ac:	a1 74 72 19 80       	mov    0x80197274,%eax
801060b1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801060b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060b7:	39 d0                	cmp    %edx,%eax
801060b9:	72 b9                	jb     80106074 <sys_sleep+0x3c>
  }
  release(&tickslock);
801060bb:	83 ec 0c             	sub    $0xc,%esp
801060be:	68 40 72 19 80       	push   $0x80197240
801060c3:	e8 c4 ea ff ff       	call   80104b8c <release>
801060c8:	83 c4 10             	add    $0x10,%esp
  return 0;
801060cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060d0:	c9                   	leave  
801060d1:	c3                   	ret    

801060d2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801060d2:	55                   	push   %ebp
801060d3:	89 e5                	mov    %esp,%ebp
801060d5:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801060d8:	83 ec 0c             	sub    $0xc,%esp
801060db:	68 40 72 19 80       	push   $0x80197240
801060e0:	e8 39 ea ff ff       	call   80104b1e <acquire>
801060e5:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801060e8:	a1 74 72 19 80       	mov    0x80197274,%eax
801060ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801060f0:	83 ec 0c             	sub    $0xc,%esp
801060f3:	68 40 72 19 80       	push   $0x80197240
801060f8:	e8 8f ea ff ff       	call   80104b8c <release>
801060fd:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106100:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106103:	c9                   	leave  
80106104:	c3                   	ret    

80106105 <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
80106105:	55                   	push   %ebp
80106106:	89 e5                	mov    %esp,%ebp
80106108:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
8010610b:	83 ec 08             	sub    $0x8,%esp
8010610e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106111:	50                   	push   %eax
80106112:	6a 00                	push   $0x0
80106114:	e8 a6 ef ff ff       	call   801050bf <argint>
80106119:	83 c4 10             	add    $0x10,%esp
8010611c:	85 c0                	test   %eax,%eax
8010611e:	79 07                	jns    80106127 <sys_setSchedPolicy+0x22>
    return -1;
80106120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106125:	eb 0f                	jmp    80106136 <sys_setSchedPolicy+0x31>
  return setSchedPolicy(policy);
80106127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612a:	83 ec 0c             	sub    $0xc,%esp
8010612d:	50                   	push   %eax
8010612e:	e8 1f e7 ff ff       	call   80104852 <setSchedPolicy>
80106133:	83 c4 10             	add    $0x10,%esp
}
80106136:	c9                   	leave  
80106137:	c3                   	ret    

80106138 <sys_getpinfo>:



int
sys_getpinfo(void)
{
80106138:	55                   	push   %ebp
80106139:	89 e5                	mov    %esp,%ebp
8010613b:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(*ps)) < 0 )
8010613e:	83 ec 04             	sub    $0x4,%esp
80106141:	68 00 0c 00 00       	push   $0xc00
80106146:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106149:	50                   	push   %eax
8010614a:	6a 00                	push   $0x0
8010614c:	e8 9b ef ff ff       	call   801050ec <argptr>
80106151:	83 c4 10             	add    $0x10,%esp
80106154:	85 c0                	test   %eax,%eax
80106156:	79 07                	jns    8010615f <sys_getpinfo+0x27>
    return -1;
80106158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615d:	eb 0f                	jmp    8010616e <sys_getpinfo+0x36>
  return getpinfo(ps);
8010615f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106162:	83 ec 0c             	sub    $0xc,%esp
80106165:	50                   	push   %eax
80106166:	e8 25 e7 ff ff       	call   80104890 <getpinfo>
8010616b:	83 c4 10             	add    $0x10,%esp
}
8010616e:	c9                   	leave  
8010616f:	c3                   	ret    

80106170 <sys_yield>:

int
sys_yield(void)
{
80106170:	55                   	push   %ebp
80106171:	89 e5                	mov    %esp,%ebp
80106173:	83 ec 08             	sub    $0x8,%esp
  yield();
80106176:	e8 b2 e3 ff ff       	call   8010452d <yield>
  return 0;
8010617b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106180:	c9                   	leave  
80106181:	c3                   	ret    

80106182 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106182:	1e                   	push   %ds
  pushl %es
80106183:	06                   	push   %es
  pushl %fs
80106184:	0f a0                	push   %fs
  pushl %gs
80106186:	0f a8                	push   %gs
  pushal
80106188:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106189:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010618d:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010618f:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106191:	54                   	push   %esp
  call trap
80106192:	e8 d7 01 00 00       	call   8010636e <trap>
  addl $4, %esp
80106197:	83 c4 04             	add    $0x4,%esp

8010619a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010619a:	61                   	popa   
  popl %gs
8010619b:	0f a9                	pop    %gs
  popl %fs
8010619d:	0f a1                	pop    %fs
  popl %es
8010619f:	07                   	pop    %es
  popl %ds
801061a0:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801061a1:	83 c4 08             	add    $0x8,%esp
  iret
801061a4:	cf                   	iret   

801061a5 <lidt>:
{
801061a5:	55                   	push   %ebp
801061a6:	89 e5                	mov    %esp,%ebp
801061a8:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801061ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801061ae:	83 e8 01             	sub    $0x1,%eax
801061b1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801061b5:	8b 45 08             	mov    0x8(%ebp),%eax
801061b8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801061bc:	8b 45 08             	mov    0x8(%ebp),%eax
801061bf:	c1 e8 10             	shr    $0x10,%eax
801061c2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801061c6:	8d 45 fa             	lea    -0x6(%ebp),%eax
801061c9:	0f 01 18             	lidtl  (%eax)
}
801061cc:	90                   	nop
801061cd:	c9                   	leave  
801061ce:	c3                   	ret    

801061cf <rcr2>:

static inline uint
rcr2(void)
{
801061cf:	55                   	push   %ebp
801061d0:	89 e5                	mov    %esp,%ebp
801061d2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801061d5:	0f 20 d0             	mov    %cr2,%eax
801061d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801061db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801061de:	c9                   	leave  
801061df:	c3                   	ret    

801061e0 <tvinit>:
  struct proc proc[NPROC];
} ptable;

void
tvinit(void)
{
801061e0:	55                   	push   %ebp
801061e1:	89 e5                	mov    %esp,%ebp
801061e3:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801061e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801061ed:	e9 c3 00 00 00       	jmp    801062b5 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801061f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f5:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801061fc:	89 c2                	mov    %eax,%edx
801061fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106201:	66 89 14 c5 40 6a 19 	mov    %dx,-0x7fe695c0(,%eax,8)
80106208:	80 
80106209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620c:	66 c7 04 c5 42 6a 19 	movw   $0x8,-0x7fe695be(,%eax,8)
80106213:	80 08 00 
80106216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106219:	0f b6 14 c5 44 6a 19 	movzbl -0x7fe695bc(,%eax,8),%edx
80106220:	80 
80106221:	83 e2 e0             	and    $0xffffffe0,%edx
80106224:	88 14 c5 44 6a 19 80 	mov    %dl,-0x7fe695bc(,%eax,8)
8010622b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622e:	0f b6 14 c5 44 6a 19 	movzbl -0x7fe695bc(,%eax,8),%edx
80106235:	80 
80106236:	83 e2 1f             	and    $0x1f,%edx
80106239:	88 14 c5 44 6a 19 80 	mov    %dl,-0x7fe695bc(,%eax,8)
80106240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106243:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
8010624a:	80 
8010624b:	83 e2 f0             	and    $0xfffffff0,%edx
8010624e:	83 ca 0e             	or     $0xe,%edx
80106251:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
80106258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625b:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
80106262:	80 
80106263:	83 e2 ef             	and    $0xffffffef,%edx
80106266:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
8010626d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106270:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
80106277:	80 
80106278:	83 e2 9f             	and    $0xffffff9f,%edx
8010627b:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
80106282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106285:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
8010628c:	80 
8010628d:	83 ca 80             	or     $0xffffff80,%edx
80106290:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
80106297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629a:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801062a1:	c1 e8 10             	shr    $0x10,%eax
801062a4:	89 c2                	mov    %eax,%edx
801062a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a9:	66 89 14 c5 46 6a 19 	mov    %dx,-0x7fe695ba(,%eax,8)
801062b0:	80 
  for(i = 0; i < 256; i++)
801062b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062b5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801062bc:	0f 8e 30 ff ff ff    	jle    801061f2 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801062c2:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801062c7:	66 a3 40 6c 19 80    	mov    %ax,0x80196c40
801062cd:	66 c7 05 42 6c 19 80 	movw   $0x8,0x80196c42
801062d4:	08 00 
801062d6:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801062dd:	83 e0 e0             	and    $0xffffffe0,%eax
801062e0:	a2 44 6c 19 80       	mov    %al,0x80196c44
801062e5:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801062ec:	83 e0 1f             	and    $0x1f,%eax
801062ef:	a2 44 6c 19 80       	mov    %al,0x80196c44
801062f4:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
801062fb:	83 c8 0f             	or     $0xf,%eax
801062fe:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106303:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
8010630a:	83 e0 ef             	and    $0xffffffef,%eax
8010630d:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106312:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
80106319:	83 c8 60             	or     $0x60,%eax
8010631c:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106321:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
80106328:	83 c8 80             	or     $0xffffff80,%eax
8010632b:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106330:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106335:	c1 e8 10             	shr    $0x10,%eax
80106338:	66 a3 46 6c 19 80    	mov    %ax,0x80196c46

  initlock(&tickslock, "time");
8010633e:	83 ec 08             	sub    $0x8,%esp
80106341:	68 18 a9 10 80       	push   $0x8010a918
80106346:	68 40 72 19 80       	push   $0x80197240
8010634b:	e8 ac e7 ff ff       	call   80104afc <initlock>
80106350:	83 c4 10             	add    $0x10,%esp
}
80106353:	90                   	nop
80106354:	c9                   	leave  
80106355:	c3                   	ret    

80106356 <idtinit>:

void
idtinit(void)
{
80106356:	55                   	push   %ebp
80106357:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106359:	68 00 08 00 00       	push   $0x800
8010635e:	68 40 6a 19 80       	push   $0x80196a40
80106363:	e8 3d fe ff ff       	call   801061a5 <lidt>
80106368:	83 c4 08             	add    $0x8,%esp
}
8010636b:	90                   	nop
8010636c:	c9                   	leave  
8010636d:	c3                   	ret    

8010636e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010636e:	55                   	push   %ebp
8010636f:	89 e5                	mov    %esp,%ebp
80106371:	57                   	push   %edi
80106372:	56                   	push   %esi
80106373:	53                   	push   %ebx
80106374:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106377:	8b 45 08             	mov    0x8(%ebp),%eax
8010637a:	8b 40 30             	mov    0x30(%eax),%eax
8010637d:	83 f8 40             	cmp    $0x40,%eax
80106380:	75 3b                	jne    801063bd <trap+0x4f>
    if(myproc()->killed)
80106382:	e8 a9 d6 ff ff       	call   80103a30 <myproc>
80106387:	8b 40 24             	mov    0x24(%eax),%eax
8010638a:	85 c0                	test   %eax,%eax
8010638c:	74 05                	je     80106393 <trap+0x25>
      exit();
8010638e:	e8 50 db ff ff       	call   80103ee3 <exit>
    myproc()->tf = tf;
80106393:	e8 98 d6 ff ff       	call   80103a30 <myproc>
80106398:	8b 55 08             	mov    0x8(%ebp),%edx
8010639b:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010639e:	e8 e8 ed ff ff       	call   8010518b <syscall>
    if(myproc()->killed)
801063a3:	e8 88 d6 ff ff       	call   80103a30 <myproc>
801063a8:	8b 40 24             	mov    0x24(%eax),%eax
801063ab:	85 c0                	test   %eax,%eax
801063ad:	0f 84 cf 02 00 00    	je     80106682 <trap+0x314>
      exit();
801063b3:	e8 2b db ff ff       	call   80103ee3 <exit>
    return;
801063b8:	e9 c5 02 00 00       	jmp    80106682 <trap+0x314>
  }

  switch(tf->trapno){
801063bd:	8b 45 08             	mov    0x8(%ebp),%eax
801063c0:	8b 40 30             	mov    0x30(%eax),%eax
801063c3:	83 e8 20             	sub    $0x20,%eax
801063c6:	83 f8 1f             	cmp    $0x1f,%eax
801063c9:	0f 87 7e 01 00 00    	ja     8010654d <trap+0x1df>
801063cf:	8b 04 85 c0 a9 10 80 	mov    -0x7fef5640(,%eax,4),%eax
801063d6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801063d8:	e8 c0 d5 ff ff       	call   8010399d <cpuid>
801063dd:	85 c0                	test   %eax,%eax
801063df:	75 3d                	jne    8010641e <trap+0xb0>
      acquire(&tickslock);
801063e1:	83 ec 0c             	sub    $0xc,%esp
801063e4:	68 40 72 19 80       	push   $0x80197240
801063e9:	e8 30 e7 ff ff       	call   80104b1e <acquire>
801063ee:	83 c4 10             	add    $0x10,%esp
      ticks++;
801063f1:	a1 74 72 19 80       	mov    0x80197274,%eax
801063f6:	83 c0 01             	add    $0x1,%eax
801063f9:	a3 74 72 19 80       	mov    %eax,0x80197274
      wakeup(&ticks);
801063fe:	83 ec 0c             	sub    $0xc,%esp
80106401:	68 74 72 19 80       	push   $0x80197274
80106406:	e8 8c e2 ff ff       	call   80104697 <wakeup>
8010640b:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010640e:	83 ec 0c             	sub    $0xc,%esp
80106411:	68 40 72 19 80       	push   $0x80197240
80106416:	e8 71 e7 ff ff       	call   80104b8c <release>
8010641b:	83 c4 10             	add    $0x10,%esp
    }
    //추가
    struct proc *curproc = myproc();
8010641e:	e8 0d d6 ff ff       	call   80103a30 <myproc>
80106423:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (curproc && curproc->state == RUNNING) {
80106426:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010642a:	74 2f                	je     8010645b <trap+0xed>
8010642c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010642f:	8b 40 0c             	mov    0xc(%eax),%eax
80106432:	83 f8 04             	cmp    $0x4,%eax
80106435:	75 24                	jne    8010645b <trap+0xed>
      int q = curproc->priority;
80106437:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010643a:	8b 40 7c             	mov    0x7c(%eax),%eax
8010643d:	89 45 dc             	mov    %eax,-0x24(%ebp)
      curproc->ticks[q]++;
80106440:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106443:	8b 55 dc             	mov    -0x24(%ebp),%edx
80106446:	83 c2 20             	add    $0x20,%edx
80106449:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010644c:	8d 48 01             	lea    0x1(%eax),%ecx
8010644f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106452:	8b 55 dc             	mov    -0x24(%ebp),%edx
80106455:	83 c2 20             	add    $0x20,%edx
80106458:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    }
    // RUNNABLE 상태이면서 현재 실행 중이 아닌 애들: wait_ticks 증가
    acquire(&ptable.lock);
8010645b:	83 ec 0c             	sub    $0xc,%esp
8010645e:	68 00 42 19 80       	push   $0x80194200
80106463:	e8 b6 e6 ff ff       	call   80104b1e <acquire>
80106468:	83 c4 10             	add    $0x10,%esp
    struct proc *p;
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010646b:	c7 45 e4 34 42 19 80 	movl   $0x80194234,-0x1c(%ebp)
80106472:	eb 35                	jmp    801064a9 <trap+0x13b>
      if (p != curproc && p->state == RUNNABLE ) {
80106474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106477:	3b 45 e0             	cmp    -0x20(%ebp),%eax
8010647a:	74 26                	je     801064a2 <trap+0x134>
8010647c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010647f:	8b 40 0c             	mov    0xc(%eax),%eax
80106482:	83 f8 03             	cmp    $0x3,%eax
80106485:	75 1b                	jne    801064a2 <trap+0x134>
        p->wait_ticks[p->priority]++;
80106487:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010648a:	8b 40 7c             	mov    0x7c(%eax),%eax
8010648d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106490:	8d 48 24             	lea    0x24(%eax),%ecx
80106493:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80106496:	8d 4a 01             	lea    0x1(%edx),%ecx
80106499:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010649c:	83 c0 24             	add    $0x24,%eax
8010649f:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801064a2:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
801064a9:	81 7d e4 34 6a 19 80 	cmpl   $0x80196a34,-0x1c(%ebp)
801064b0:	72 c2                	jb     80106474 <trap+0x106>
      }
    }
    release(&ptable.lock);
801064b2:	83 ec 0c             	sub    $0xc,%esp
801064b5:	68 00 42 19 80       	push   $0x80194200
801064ba:	e8 cd e6 ff ff       	call   80104b8c <release>
801064bf:	83 c4 10             	add    $0x10,%esp
    if (curproc && curproc->state == RUNNING){
801064c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801064c6:	74 10                	je     801064d8 <trap+0x16a>
801064c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064cb:	8b 40 0c             	mov    0xc(%eax),%eax
801064ce:	83 f8 04             	cmp    $0x4,%eax
801064d1:	75 05                	jne    801064d8 <trap+0x16a>
    yield();  // CPU 양보
801064d3:	e8 55 e0 ff ff       	call   8010452d <yield>
    }

    lapiceoi();
801064d8:	e8 3f c6 ff ff       	call   80102b1c <lapiceoi>
    break;
801064dd:	e9 20 01 00 00       	jmp    80106602 <trap+0x294>

  case T_IRQ0 + IRQ_IDE:
    ideintr();
801064e2:	e8 f5 3e 00 00       	call   8010a3dc <ideintr>
    lapiceoi();
801064e7:	e8 30 c6 ff ff       	call   80102b1c <lapiceoi>
    break;
801064ec:	e9 11 01 00 00       	jmp    80106602 <trap+0x294>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801064f1:	e8 6b c4 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
801064f6:	e8 21 c6 ff ff       	call   80102b1c <lapiceoi>
    break;
801064fb:	e9 02 01 00 00       	jmp    80106602 <trap+0x294>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106500:	e8 53 03 00 00       	call   80106858 <uartintr>
    lapiceoi();
80106505:	e8 12 c6 ff ff       	call   80102b1c <lapiceoi>
    break;
8010650a:	e9 f3 00 00 00       	jmp    80106602 <trap+0x294>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010650f:	e8 7b 2b 00 00       	call   8010908f <i8254_intr>
    lapiceoi();
80106514:	e8 03 c6 ff ff       	call   80102b1c <lapiceoi>
    break;
80106519:	e9 e4 00 00 00       	jmp    80106602 <trap+0x294>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010651e:	8b 45 08             	mov    0x8(%ebp),%eax
80106521:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106524:	8b 45 08             	mov    0x8(%ebp),%eax
80106527:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010652b:	0f b7 d8             	movzwl %ax,%ebx
8010652e:	e8 6a d4 ff ff       	call   8010399d <cpuid>
80106533:	56                   	push   %esi
80106534:	53                   	push   %ebx
80106535:	50                   	push   %eax
80106536:	68 20 a9 10 80       	push   $0x8010a920
8010653b:	e8 b4 9e ff ff       	call   801003f4 <cprintf>
80106540:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106543:	e8 d4 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
80106548:	e9 b5 00 00 00       	jmp    80106602 <trap+0x294>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010654d:	e8 de d4 ff ff       	call   80103a30 <myproc>
80106552:	85 c0                	test   %eax,%eax
80106554:	74 11                	je     80106567 <trap+0x1f9>
80106556:	8b 45 08             	mov    0x8(%ebp),%eax
80106559:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010655d:	0f b7 c0             	movzwl %ax,%eax
80106560:	83 e0 03             	and    $0x3,%eax
80106563:	85 c0                	test   %eax,%eax
80106565:	75 39                	jne    801065a0 <trap+0x232>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106567:	e8 63 fc ff ff       	call   801061cf <rcr2>
8010656c:	89 c3                	mov    %eax,%ebx
8010656e:	8b 45 08             	mov    0x8(%ebp),%eax
80106571:	8b 70 38             	mov    0x38(%eax),%esi
80106574:	e8 24 d4 ff ff       	call   8010399d <cpuid>
80106579:	8b 55 08             	mov    0x8(%ebp),%edx
8010657c:	8b 52 30             	mov    0x30(%edx),%edx
8010657f:	83 ec 0c             	sub    $0xc,%esp
80106582:	53                   	push   %ebx
80106583:	56                   	push   %esi
80106584:	50                   	push   %eax
80106585:	52                   	push   %edx
80106586:	68 44 a9 10 80       	push   $0x8010a944
8010658b:	e8 64 9e ff ff       	call   801003f4 <cprintf>
80106590:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106593:	83 ec 0c             	sub    $0xc,%esp
80106596:	68 76 a9 10 80       	push   $0x8010a976
8010659b:	e8 09 a0 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065a0:	e8 2a fc ff ff       	call   801061cf <rcr2>
801065a5:	89 c6                	mov    %eax,%esi
801065a7:	8b 45 08             	mov    0x8(%ebp),%eax
801065aa:	8b 40 38             	mov    0x38(%eax),%eax
801065ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801065b0:	e8 e8 d3 ff ff       	call   8010399d <cpuid>
801065b5:	89 c3                	mov    %eax,%ebx
801065b7:	8b 45 08             	mov    0x8(%ebp),%eax
801065ba:	8b 78 34             	mov    0x34(%eax),%edi
801065bd:	89 7d d0             	mov    %edi,-0x30(%ebp)
801065c0:	8b 45 08             	mov    0x8(%ebp),%eax
801065c3:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801065c6:	e8 65 d4 ff ff       	call   80103a30 <myproc>
801065cb:	8d 48 6c             	lea    0x6c(%eax),%ecx
801065ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
801065d1:	e8 5a d4 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065d6:	8b 40 10             	mov    0x10(%eax),%eax
801065d9:	56                   	push   %esi
801065da:	ff 75 d4             	push   -0x2c(%ebp)
801065dd:	53                   	push   %ebx
801065de:	ff 75 d0             	push   -0x30(%ebp)
801065e1:	57                   	push   %edi
801065e2:	ff 75 cc             	push   -0x34(%ebp)
801065e5:	50                   	push   %eax
801065e6:	68 7c a9 10 80       	push   $0x8010a97c
801065eb:	e8 04 9e ff ff       	call   801003f4 <cprintf>
801065f0:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801065f3:	e8 38 d4 ff ff       	call   80103a30 <myproc>
801065f8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801065ff:	eb 01                	jmp    80106602 <trap+0x294>
    break;
80106601:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106602:	e8 29 d4 ff ff       	call   80103a30 <myproc>
80106607:	85 c0                	test   %eax,%eax
80106609:	74 23                	je     8010662e <trap+0x2c0>
8010660b:	e8 20 d4 ff ff       	call   80103a30 <myproc>
80106610:	8b 40 24             	mov    0x24(%eax),%eax
80106613:	85 c0                	test   %eax,%eax
80106615:	74 17                	je     8010662e <trap+0x2c0>
80106617:	8b 45 08             	mov    0x8(%ebp),%eax
8010661a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010661e:	0f b7 c0             	movzwl %ax,%eax
80106621:	83 e0 03             	and    $0x3,%eax
80106624:	83 f8 03             	cmp    $0x3,%eax
80106627:	75 05                	jne    8010662e <trap+0x2c0>
    exit();
80106629:	e8 b5 d8 ff ff       	call   80103ee3 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
8010662e:	e8 fd d3 ff ff       	call   80103a30 <myproc>
80106633:	85 c0                	test   %eax,%eax
80106635:	74 1d                	je     80106654 <trap+0x2e6>
80106637:	e8 f4 d3 ff ff       	call   80103a30 <myproc>
8010663c:	8b 40 0c             	mov    0xc(%eax),%eax
8010663f:	83 f8 04             	cmp    $0x4,%eax
80106642:	75 10                	jne    80106654 <trap+0x2e6>
80106644:	8b 45 08             	mov    0x8(%ebp),%eax
80106647:	8b 40 30             	mov    0x30(%eax),%eax
8010664a:	83 f8 20             	cmp    $0x20,%eax
8010664d:	75 05                	jne    80106654 <trap+0x2e6>
      yield();
8010664f:	e8 d9 de ff ff       	call   8010452d <yield>
  }

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106654:	e8 d7 d3 ff ff       	call   80103a30 <myproc>
80106659:	85 c0                	test   %eax,%eax
8010665b:	74 26                	je     80106683 <trap+0x315>
8010665d:	e8 ce d3 ff ff       	call   80103a30 <myproc>
80106662:	8b 40 24             	mov    0x24(%eax),%eax
80106665:	85 c0                	test   %eax,%eax
80106667:	74 1a                	je     80106683 <trap+0x315>
80106669:	8b 45 08             	mov    0x8(%ebp),%eax
8010666c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106670:	0f b7 c0             	movzwl %ax,%eax
80106673:	83 e0 03             	and    $0x3,%eax
80106676:	83 f8 03             	cmp    $0x3,%eax
80106679:	75 08                	jne    80106683 <trap+0x315>
    exit();
8010667b:	e8 63 d8 ff ff       	call   80103ee3 <exit>
80106680:	eb 01                	jmp    80106683 <trap+0x315>
    return;
80106682:	90                   	nop
80106683:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106686:	5b                   	pop    %ebx
80106687:	5e                   	pop    %esi
80106688:	5f                   	pop    %edi
80106689:	5d                   	pop    %ebp
8010668a:	c3                   	ret    

8010668b <inb>:
{
8010668b:	55                   	push   %ebp
8010668c:	89 e5                	mov    %esp,%ebp
8010668e:	83 ec 14             	sub    $0x14,%esp
80106691:	8b 45 08             	mov    0x8(%ebp),%eax
80106694:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106698:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010669c:	89 c2                	mov    %eax,%edx
8010669e:	ec                   	in     (%dx),%al
8010669f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066a2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066a6:	c9                   	leave  
801066a7:	c3                   	ret    

801066a8 <outb>:
{
801066a8:	55                   	push   %ebp
801066a9:	89 e5                	mov    %esp,%ebp
801066ab:	83 ec 08             	sub    $0x8,%esp
801066ae:	8b 45 08             	mov    0x8(%ebp),%eax
801066b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801066b4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801066b8:	89 d0                	mov    %edx,%eax
801066ba:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066bd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066c1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066c5:	ee                   	out    %al,(%dx)
}
801066c6:	90                   	nop
801066c7:	c9                   	leave  
801066c8:	c3                   	ret    

801066c9 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801066c9:	55                   	push   %ebp
801066ca:	89 e5                	mov    %esp,%ebp
801066cc:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801066cf:	6a 00                	push   $0x0
801066d1:	68 fa 03 00 00       	push   $0x3fa
801066d6:	e8 cd ff ff ff       	call   801066a8 <outb>
801066db:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801066de:	68 80 00 00 00       	push   $0x80
801066e3:	68 fb 03 00 00       	push   $0x3fb
801066e8:	e8 bb ff ff ff       	call   801066a8 <outb>
801066ed:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801066f0:	6a 0c                	push   $0xc
801066f2:	68 f8 03 00 00       	push   $0x3f8
801066f7:	e8 ac ff ff ff       	call   801066a8 <outb>
801066fc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801066ff:	6a 00                	push   $0x0
80106701:	68 f9 03 00 00       	push   $0x3f9
80106706:	e8 9d ff ff ff       	call   801066a8 <outb>
8010670b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010670e:	6a 03                	push   $0x3
80106710:	68 fb 03 00 00       	push   $0x3fb
80106715:	e8 8e ff ff ff       	call   801066a8 <outb>
8010671a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010671d:	6a 00                	push   $0x0
8010671f:	68 fc 03 00 00       	push   $0x3fc
80106724:	e8 7f ff ff ff       	call   801066a8 <outb>
80106729:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010672c:	6a 01                	push   $0x1
8010672e:	68 f9 03 00 00       	push   $0x3f9
80106733:	e8 70 ff ff ff       	call   801066a8 <outb>
80106738:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010673b:	68 fd 03 00 00       	push   $0x3fd
80106740:	e8 46 ff ff ff       	call   8010668b <inb>
80106745:	83 c4 04             	add    $0x4,%esp
80106748:	3c ff                	cmp    $0xff,%al
8010674a:	74 61                	je     801067ad <uartinit+0xe4>
    return;
  uart = 1;
8010674c:	c7 05 78 72 19 80 01 	movl   $0x1,0x80197278
80106753:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106756:	68 fa 03 00 00       	push   $0x3fa
8010675b:	e8 2b ff ff ff       	call   8010668b <inb>
80106760:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106763:	68 f8 03 00 00       	push   $0x3f8
80106768:	e8 1e ff ff ff       	call   8010668b <inb>
8010676d:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106770:	83 ec 08             	sub    $0x8,%esp
80106773:	6a 00                	push   $0x0
80106775:	6a 04                	push   $0x4
80106777:	e8 b2 be ff ff       	call   8010262e <ioapicenable>
8010677c:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010677f:	c7 45 f4 40 aa 10 80 	movl   $0x8010aa40,-0xc(%ebp)
80106786:	eb 19                	jmp    801067a1 <uartinit+0xd8>
    uartputc(*p);
80106788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678b:	0f b6 00             	movzbl (%eax),%eax
8010678e:	0f be c0             	movsbl %al,%eax
80106791:	83 ec 0c             	sub    $0xc,%esp
80106794:	50                   	push   %eax
80106795:	e8 16 00 00 00       	call   801067b0 <uartputc>
8010679a:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010679d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a4:	0f b6 00             	movzbl (%eax),%eax
801067a7:	84 c0                	test   %al,%al
801067a9:	75 dd                	jne    80106788 <uartinit+0xbf>
801067ab:	eb 01                	jmp    801067ae <uartinit+0xe5>
    return;
801067ad:	90                   	nop
}
801067ae:	c9                   	leave  
801067af:	c3                   	ret    

801067b0 <uartputc>:

void
uartputc(int c)
{
801067b0:	55                   	push   %ebp
801067b1:	89 e5                	mov    %esp,%ebp
801067b3:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801067b6:	a1 78 72 19 80       	mov    0x80197278,%eax
801067bb:	85 c0                	test   %eax,%eax
801067bd:	74 53                	je     80106812 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067c6:	eb 11                	jmp    801067d9 <uartputc+0x29>
    microdelay(10);
801067c8:	83 ec 0c             	sub    $0xc,%esp
801067cb:	6a 0a                	push   $0xa
801067cd:	e8 65 c3 ff ff       	call   80102b37 <microdelay>
801067d2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067d9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801067dd:	7f 1a                	jg     801067f9 <uartputc+0x49>
801067df:	83 ec 0c             	sub    $0xc,%esp
801067e2:	68 fd 03 00 00       	push   $0x3fd
801067e7:	e8 9f fe ff ff       	call   8010668b <inb>
801067ec:	83 c4 10             	add    $0x10,%esp
801067ef:	0f b6 c0             	movzbl %al,%eax
801067f2:	83 e0 20             	and    $0x20,%eax
801067f5:	85 c0                	test   %eax,%eax
801067f7:	74 cf                	je     801067c8 <uartputc+0x18>
  outb(COM1+0, c);
801067f9:	8b 45 08             	mov    0x8(%ebp),%eax
801067fc:	0f b6 c0             	movzbl %al,%eax
801067ff:	83 ec 08             	sub    $0x8,%esp
80106802:	50                   	push   %eax
80106803:	68 f8 03 00 00       	push   $0x3f8
80106808:	e8 9b fe ff ff       	call   801066a8 <outb>
8010680d:	83 c4 10             	add    $0x10,%esp
80106810:	eb 01                	jmp    80106813 <uartputc+0x63>
    return;
80106812:	90                   	nop
}
80106813:	c9                   	leave  
80106814:	c3                   	ret    

80106815 <uartgetc>:

static int
uartgetc(void)
{
80106815:	55                   	push   %ebp
80106816:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106818:	a1 78 72 19 80       	mov    0x80197278,%eax
8010681d:	85 c0                	test   %eax,%eax
8010681f:	75 07                	jne    80106828 <uartgetc+0x13>
    return -1;
80106821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106826:	eb 2e                	jmp    80106856 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106828:	68 fd 03 00 00       	push   $0x3fd
8010682d:	e8 59 fe ff ff       	call   8010668b <inb>
80106832:	83 c4 04             	add    $0x4,%esp
80106835:	0f b6 c0             	movzbl %al,%eax
80106838:	83 e0 01             	and    $0x1,%eax
8010683b:	85 c0                	test   %eax,%eax
8010683d:	75 07                	jne    80106846 <uartgetc+0x31>
    return -1;
8010683f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106844:	eb 10                	jmp    80106856 <uartgetc+0x41>
  return inb(COM1+0);
80106846:	68 f8 03 00 00       	push   $0x3f8
8010684b:	e8 3b fe ff ff       	call   8010668b <inb>
80106850:	83 c4 04             	add    $0x4,%esp
80106853:	0f b6 c0             	movzbl %al,%eax
}
80106856:	c9                   	leave  
80106857:	c3                   	ret    

80106858 <uartintr>:

void
uartintr(void)
{
80106858:	55                   	push   %ebp
80106859:	89 e5                	mov    %esp,%ebp
8010685b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010685e:	83 ec 0c             	sub    $0xc,%esp
80106861:	68 15 68 10 80       	push   $0x80106815
80106866:	e8 6b 9f ff ff       	call   801007d6 <consoleintr>
8010686b:	83 c4 10             	add    $0x10,%esp
}
8010686e:	90                   	nop
8010686f:	c9                   	leave  
80106870:	c3                   	ret    

80106871 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106871:	6a 00                	push   $0x0
  pushl $0
80106873:	6a 00                	push   $0x0
  jmp alltraps
80106875:	e9 08 f9 ff ff       	jmp    80106182 <alltraps>

8010687a <vector1>:
.globl vector1
vector1:
  pushl $0
8010687a:	6a 00                	push   $0x0
  pushl $1
8010687c:	6a 01                	push   $0x1
  jmp alltraps
8010687e:	e9 ff f8 ff ff       	jmp    80106182 <alltraps>

80106883 <vector2>:
.globl vector2
vector2:
  pushl $0
80106883:	6a 00                	push   $0x0
  pushl $2
80106885:	6a 02                	push   $0x2
  jmp alltraps
80106887:	e9 f6 f8 ff ff       	jmp    80106182 <alltraps>

8010688c <vector3>:
.globl vector3
vector3:
  pushl $0
8010688c:	6a 00                	push   $0x0
  pushl $3
8010688e:	6a 03                	push   $0x3
  jmp alltraps
80106890:	e9 ed f8 ff ff       	jmp    80106182 <alltraps>

80106895 <vector4>:
.globl vector4
vector4:
  pushl $0
80106895:	6a 00                	push   $0x0
  pushl $4
80106897:	6a 04                	push   $0x4
  jmp alltraps
80106899:	e9 e4 f8 ff ff       	jmp    80106182 <alltraps>

8010689e <vector5>:
.globl vector5
vector5:
  pushl $0
8010689e:	6a 00                	push   $0x0
  pushl $5
801068a0:	6a 05                	push   $0x5
  jmp alltraps
801068a2:	e9 db f8 ff ff       	jmp    80106182 <alltraps>

801068a7 <vector6>:
.globl vector6
vector6:
  pushl $0
801068a7:	6a 00                	push   $0x0
  pushl $6
801068a9:	6a 06                	push   $0x6
  jmp alltraps
801068ab:	e9 d2 f8 ff ff       	jmp    80106182 <alltraps>

801068b0 <vector7>:
.globl vector7
vector7:
  pushl $0
801068b0:	6a 00                	push   $0x0
  pushl $7
801068b2:	6a 07                	push   $0x7
  jmp alltraps
801068b4:	e9 c9 f8 ff ff       	jmp    80106182 <alltraps>

801068b9 <vector8>:
.globl vector8
vector8:
  pushl $8
801068b9:	6a 08                	push   $0x8
  jmp alltraps
801068bb:	e9 c2 f8 ff ff       	jmp    80106182 <alltraps>

801068c0 <vector9>:
.globl vector9
vector9:
  pushl $0
801068c0:	6a 00                	push   $0x0
  pushl $9
801068c2:	6a 09                	push   $0x9
  jmp alltraps
801068c4:	e9 b9 f8 ff ff       	jmp    80106182 <alltraps>

801068c9 <vector10>:
.globl vector10
vector10:
  pushl $10
801068c9:	6a 0a                	push   $0xa
  jmp alltraps
801068cb:	e9 b2 f8 ff ff       	jmp    80106182 <alltraps>

801068d0 <vector11>:
.globl vector11
vector11:
  pushl $11
801068d0:	6a 0b                	push   $0xb
  jmp alltraps
801068d2:	e9 ab f8 ff ff       	jmp    80106182 <alltraps>

801068d7 <vector12>:
.globl vector12
vector12:
  pushl $12
801068d7:	6a 0c                	push   $0xc
  jmp alltraps
801068d9:	e9 a4 f8 ff ff       	jmp    80106182 <alltraps>

801068de <vector13>:
.globl vector13
vector13:
  pushl $13
801068de:	6a 0d                	push   $0xd
  jmp alltraps
801068e0:	e9 9d f8 ff ff       	jmp    80106182 <alltraps>

801068e5 <vector14>:
.globl vector14
vector14:
  pushl $14
801068e5:	6a 0e                	push   $0xe
  jmp alltraps
801068e7:	e9 96 f8 ff ff       	jmp    80106182 <alltraps>

801068ec <vector15>:
.globl vector15
vector15:
  pushl $0
801068ec:	6a 00                	push   $0x0
  pushl $15
801068ee:	6a 0f                	push   $0xf
  jmp alltraps
801068f0:	e9 8d f8 ff ff       	jmp    80106182 <alltraps>

801068f5 <vector16>:
.globl vector16
vector16:
  pushl $0
801068f5:	6a 00                	push   $0x0
  pushl $16
801068f7:	6a 10                	push   $0x10
  jmp alltraps
801068f9:	e9 84 f8 ff ff       	jmp    80106182 <alltraps>

801068fe <vector17>:
.globl vector17
vector17:
  pushl $17
801068fe:	6a 11                	push   $0x11
  jmp alltraps
80106900:	e9 7d f8 ff ff       	jmp    80106182 <alltraps>

80106905 <vector18>:
.globl vector18
vector18:
  pushl $0
80106905:	6a 00                	push   $0x0
  pushl $18
80106907:	6a 12                	push   $0x12
  jmp alltraps
80106909:	e9 74 f8 ff ff       	jmp    80106182 <alltraps>

8010690e <vector19>:
.globl vector19
vector19:
  pushl $0
8010690e:	6a 00                	push   $0x0
  pushl $19
80106910:	6a 13                	push   $0x13
  jmp alltraps
80106912:	e9 6b f8 ff ff       	jmp    80106182 <alltraps>

80106917 <vector20>:
.globl vector20
vector20:
  pushl $0
80106917:	6a 00                	push   $0x0
  pushl $20
80106919:	6a 14                	push   $0x14
  jmp alltraps
8010691b:	e9 62 f8 ff ff       	jmp    80106182 <alltraps>

80106920 <vector21>:
.globl vector21
vector21:
  pushl $0
80106920:	6a 00                	push   $0x0
  pushl $21
80106922:	6a 15                	push   $0x15
  jmp alltraps
80106924:	e9 59 f8 ff ff       	jmp    80106182 <alltraps>

80106929 <vector22>:
.globl vector22
vector22:
  pushl $0
80106929:	6a 00                	push   $0x0
  pushl $22
8010692b:	6a 16                	push   $0x16
  jmp alltraps
8010692d:	e9 50 f8 ff ff       	jmp    80106182 <alltraps>

80106932 <vector23>:
.globl vector23
vector23:
  pushl $0
80106932:	6a 00                	push   $0x0
  pushl $23
80106934:	6a 17                	push   $0x17
  jmp alltraps
80106936:	e9 47 f8 ff ff       	jmp    80106182 <alltraps>

8010693b <vector24>:
.globl vector24
vector24:
  pushl $0
8010693b:	6a 00                	push   $0x0
  pushl $24
8010693d:	6a 18                	push   $0x18
  jmp alltraps
8010693f:	e9 3e f8 ff ff       	jmp    80106182 <alltraps>

80106944 <vector25>:
.globl vector25
vector25:
  pushl $0
80106944:	6a 00                	push   $0x0
  pushl $25
80106946:	6a 19                	push   $0x19
  jmp alltraps
80106948:	e9 35 f8 ff ff       	jmp    80106182 <alltraps>

8010694d <vector26>:
.globl vector26
vector26:
  pushl $0
8010694d:	6a 00                	push   $0x0
  pushl $26
8010694f:	6a 1a                	push   $0x1a
  jmp alltraps
80106951:	e9 2c f8 ff ff       	jmp    80106182 <alltraps>

80106956 <vector27>:
.globl vector27
vector27:
  pushl $0
80106956:	6a 00                	push   $0x0
  pushl $27
80106958:	6a 1b                	push   $0x1b
  jmp alltraps
8010695a:	e9 23 f8 ff ff       	jmp    80106182 <alltraps>

8010695f <vector28>:
.globl vector28
vector28:
  pushl $0
8010695f:	6a 00                	push   $0x0
  pushl $28
80106961:	6a 1c                	push   $0x1c
  jmp alltraps
80106963:	e9 1a f8 ff ff       	jmp    80106182 <alltraps>

80106968 <vector29>:
.globl vector29
vector29:
  pushl $0
80106968:	6a 00                	push   $0x0
  pushl $29
8010696a:	6a 1d                	push   $0x1d
  jmp alltraps
8010696c:	e9 11 f8 ff ff       	jmp    80106182 <alltraps>

80106971 <vector30>:
.globl vector30
vector30:
  pushl $0
80106971:	6a 00                	push   $0x0
  pushl $30
80106973:	6a 1e                	push   $0x1e
  jmp alltraps
80106975:	e9 08 f8 ff ff       	jmp    80106182 <alltraps>

8010697a <vector31>:
.globl vector31
vector31:
  pushl $0
8010697a:	6a 00                	push   $0x0
  pushl $31
8010697c:	6a 1f                	push   $0x1f
  jmp alltraps
8010697e:	e9 ff f7 ff ff       	jmp    80106182 <alltraps>

80106983 <vector32>:
.globl vector32
vector32:
  pushl $0
80106983:	6a 00                	push   $0x0
  pushl $32
80106985:	6a 20                	push   $0x20
  jmp alltraps
80106987:	e9 f6 f7 ff ff       	jmp    80106182 <alltraps>

8010698c <vector33>:
.globl vector33
vector33:
  pushl $0
8010698c:	6a 00                	push   $0x0
  pushl $33
8010698e:	6a 21                	push   $0x21
  jmp alltraps
80106990:	e9 ed f7 ff ff       	jmp    80106182 <alltraps>

80106995 <vector34>:
.globl vector34
vector34:
  pushl $0
80106995:	6a 00                	push   $0x0
  pushl $34
80106997:	6a 22                	push   $0x22
  jmp alltraps
80106999:	e9 e4 f7 ff ff       	jmp    80106182 <alltraps>

8010699e <vector35>:
.globl vector35
vector35:
  pushl $0
8010699e:	6a 00                	push   $0x0
  pushl $35
801069a0:	6a 23                	push   $0x23
  jmp alltraps
801069a2:	e9 db f7 ff ff       	jmp    80106182 <alltraps>

801069a7 <vector36>:
.globl vector36
vector36:
  pushl $0
801069a7:	6a 00                	push   $0x0
  pushl $36
801069a9:	6a 24                	push   $0x24
  jmp alltraps
801069ab:	e9 d2 f7 ff ff       	jmp    80106182 <alltraps>

801069b0 <vector37>:
.globl vector37
vector37:
  pushl $0
801069b0:	6a 00                	push   $0x0
  pushl $37
801069b2:	6a 25                	push   $0x25
  jmp alltraps
801069b4:	e9 c9 f7 ff ff       	jmp    80106182 <alltraps>

801069b9 <vector38>:
.globl vector38
vector38:
  pushl $0
801069b9:	6a 00                	push   $0x0
  pushl $38
801069bb:	6a 26                	push   $0x26
  jmp alltraps
801069bd:	e9 c0 f7 ff ff       	jmp    80106182 <alltraps>

801069c2 <vector39>:
.globl vector39
vector39:
  pushl $0
801069c2:	6a 00                	push   $0x0
  pushl $39
801069c4:	6a 27                	push   $0x27
  jmp alltraps
801069c6:	e9 b7 f7 ff ff       	jmp    80106182 <alltraps>

801069cb <vector40>:
.globl vector40
vector40:
  pushl $0
801069cb:	6a 00                	push   $0x0
  pushl $40
801069cd:	6a 28                	push   $0x28
  jmp alltraps
801069cf:	e9 ae f7 ff ff       	jmp    80106182 <alltraps>

801069d4 <vector41>:
.globl vector41
vector41:
  pushl $0
801069d4:	6a 00                	push   $0x0
  pushl $41
801069d6:	6a 29                	push   $0x29
  jmp alltraps
801069d8:	e9 a5 f7 ff ff       	jmp    80106182 <alltraps>

801069dd <vector42>:
.globl vector42
vector42:
  pushl $0
801069dd:	6a 00                	push   $0x0
  pushl $42
801069df:	6a 2a                	push   $0x2a
  jmp alltraps
801069e1:	e9 9c f7 ff ff       	jmp    80106182 <alltraps>

801069e6 <vector43>:
.globl vector43
vector43:
  pushl $0
801069e6:	6a 00                	push   $0x0
  pushl $43
801069e8:	6a 2b                	push   $0x2b
  jmp alltraps
801069ea:	e9 93 f7 ff ff       	jmp    80106182 <alltraps>

801069ef <vector44>:
.globl vector44
vector44:
  pushl $0
801069ef:	6a 00                	push   $0x0
  pushl $44
801069f1:	6a 2c                	push   $0x2c
  jmp alltraps
801069f3:	e9 8a f7 ff ff       	jmp    80106182 <alltraps>

801069f8 <vector45>:
.globl vector45
vector45:
  pushl $0
801069f8:	6a 00                	push   $0x0
  pushl $45
801069fa:	6a 2d                	push   $0x2d
  jmp alltraps
801069fc:	e9 81 f7 ff ff       	jmp    80106182 <alltraps>

80106a01 <vector46>:
.globl vector46
vector46:
  pushl $0
80106a01:	6a 00                	push   $0x0
  pushl $46
80106a03:	6a 2e                	push   $0x2e
  jmp alltraps
80106a05:	e9 78 f7 ff ff       	jmp    80106182 <alltraps>

80106a0a <vector47>:
.globl vector47
vector47:
  pushl $0
80106a0a:	6a 00                	push   $0x0
  pushl $47
80106a0c:	6a 2f                	push   $0x2f
  jmp alltraps
80106a0e:	e9 6f f7 ff ff       	jmp    80106182 <alltraps>

80106a13 <vector48>:
.globl vector48
vector48:
  pushl $0
80106a13:	6a 00                	push   $0x0
  pushl $48
80106a15:	6a 30                	push   $0x30
  jmp alltraps
80106a17:	e9 66 f7 ff ff       	jmp    80106182 <alltraps>

80106a1c <vector49>:
.globl vector49
vector49:
  pushl $0
80106a1c:	6a 00                	push   $0x0
  pushl $49
80106a1e:	6a 31                	push   $0x31
  jmp alltraps
80106a20:	e9 5d f7 ff ff       	jmp    80106182 <alltraps>

80106a25 <vector50>:
.globl vector50
vector50:
  pushl $0
80106a25:	6a 00                	push   $0x0
  pushl $50
80106a27:	6a 32                	push   $0x32
  jmp alltraps
80106a29:	e9 54 f7 ff ff       	jmp    80106182 <alltraps>

80106a2e <vector51>:
.globl vector51
vector51:
  pushl $0
80106a2e:	6a 00                	push   $0x0
  pushl $51
80106a30:	6a 33                	push   $0x33
  jmp alltraps
80106a32:	e9 4b f7 ff ff       	jmp    80106182 <alltraps>

80106a37 <vector52>:
.globl vector52
vector52:
  pushl $0
80106a37:	6a 00                	push   $0x0
  pushl $52
80106a39:	6a 34                	push   $0x34
  jmp alltraps
80106a3b:	e9 42 f7 ff ff       	jmp    80106182 <alltraps>

80106a40 <vector53>:
.globl vector53
vector53:
  pushl $0
80106a40:	6a 00                	push   $0x0
  pushl $53
80106a42:	6a 35                	push   $0x35
  jmp alltraps
80106a44:	e9 39 f7 ff ff       	jmp    80106182 <alltraps>

80106a49 <vector54>:
.globl vector54
vector54:
  pushl $0
80106a49:	6a 00                	push   $0x0
  pushl $54
80106a4b:	6a 36                	push   $0x36
  jmp alltraps
80106a4d:	e9 30 f7 ff ff       	jmp    80106182 <alltraps>

80106a52 <vector55>:
.globl vector55
vector55:
  pushl $0
80106a52:	6a 00                	push   $0x0
  pushl $55
80106a54:	6a 37                	push   $0x37
  jmp alltraps
80106a56:	e9 27 f7 ff ff       	jmp    80106182 <alltraps>

80106a5b <vector56>:
.globl vector56
vector56:
  pushl $0
80106a5b:	6a 00                	push   $0x0
  pushl $56
80106a5d:	6a 38                	push   $0x38
  jmp alltraps
80106a5f:	e9 1e f7 ff ff       	jmp    80106182 <alltraps>

80106a64 <vector57>:
.globl vector57
vector57:
  pushl $0
80106a64:	6a 00                	push   $0x0
  pushl $57
80106a66:	6a 39                	push   $0x39
  jmp alltraps
80106a68:	e9 15 f7 ff ff       	jmp    80106182 <alltraps>

80106a6d <vector58>:
.globl vector58
vector58:
  pushl $0
80106a6d:	6a 00                	push   $0x0
  pushl $58
80106a6f:	6a 3a                	push   $0x3a
  jmp alltraps
80106a71:	e9 0c f7 ff ff       	jmp    80106182 <alltraps>

80106a76 <vector59>:
.globl vector59
vector59:
  pushl $0
80106a76:	6a 00                	push   $0x0
  pushl $59
80106a78:	6a 3b                	push   $0x3b
  jmp alltraps
80106a7a:	e9 03 f7 ff ff       	jmp    80106182 <alltraps>

80106a7f <vector60>:
.globl vector60
vector60:
  pushl $0
80106a7f:	6a 00                	push   $0x0
  pushl $60
80106a81:	6a 3c                	push   $0x3c
  jmp alltraps
80106a83:	e9 fa f6 ff ff       	jmp    80106182 <alltraps>

80106a88 <vector61>:
.globl vector61
vector61:
  pushl $0
80106a88:	6a 00                	push   $0x0
  pushl $61
80106a8a:	6a 3d                	push   $0x3d
  jmp alltraps
80106a8c:	e9 f1 f6 ff ff       	jmp    80106182 <alltraps>

80106a91 <vector62>:
.globl vector62
vector62:
  pushl $0
80106a91:	6a 00                	push   $0x0
  pushl $62
80106a93:	6a 3e                	push   $0x3e
  jmp alltraps
80106a95:	e9 e8 f6 ff ff       	jmp    80106182 <alltraps>

80106a9a <vector63>:
.globl vector63
vector63:
  pushl $0
80106a9a:	6a 00                	push   $0x0
  pushl $63
80106a9c:	6a 3f                	push   $0x3f
  jmp alltraps
80106a9e:	e9 df f6 ff ff       	jmp    80106182 <alltraps>

80106aa3 <vector64>:
.globl vector64
vector64:
  pushl $0
80106aa3:	6a 00                	push   $0x0
  pushl $64
80106aa5:	6a 40                	push   $0x40
  jmp alltraps
80106aa7:	e9 d6 f6 ff ff       	jmp    80106182 <alltraps>

80106aac <vector65>:
.globl vector65
vector65:
  pushl $0
80106aac:	6a 00                	push   $0x0
  pushl $65
80106aae:	6a 41                	push   $0x41
  jmp alltraps
80106ab0:	e9 cd f6 ff ff       	jmp    80106182 <alltraps>

80106ab5 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ab5:	6a 00                	push   $0x0
  pushl $66
80106ab7:	6a 42                	push   $0x42
  jmp alltraps
80106ab9:	e9 c4 f6 ff ff       	jmp    80106182 <alltraps>

80106abe <vector67>:
.globl vector67
vector67:
  pushl $0
80106abe:	6a 00                	push   $0x0
  pushl $67
80106ac0:	6a 43                	push   $0x43
  jmp alltraps
80106ac2:	e9 bb f6 ff ff       	jmp    80106182 <alltraps>

80106ac7 <vector68>:
.globl vector68
vector68:
  pushl $0
80106ac7:	6a 00                	push   $0x0
  pushl $68
80106ac9:	6a 44                	push   $0x44
  jmp alltraps
80106acb:	e9 b2 f6 ff ff       	jmp    80106182 <alltraps>

80106ad0 <vector69>:
.globl vector69
vector69:
  pushl $0
80106ad0:	6a 00                	push   $0x0
  pushl $69
80106ad2:	6a 45                	push   $0x45
  jmp alltraps
80106ad4:	e9 a9 f6 ff ff       	jmp    80106182 <alltraps>

80106ad9 <vector70>:
.globl vector70
vector70:
  pushl $0
80106ad9:	6a 00                	push   $0x0
  pushl $70
80106adb:	6a 46                	push   $0x46
  jmp alltraps
80106add:	e9 a0 f6 ff ff       	jmp    80106182 <alltraps>

80106ae2 <vector71>:
.globl vector71
vector71:
  pushl $0
80106ae2:	6a 00                	push   $0x0
  pushl $71
80106ae4:	6a 47                	push   $0x47
  jmp alltraps
80106ae6:	e9 97 f6 ff ff       	jmp    80106182 <alltraps>

80106aeb <vector72>:
.globl vector72
vector72:
  pushl $0
80106aeb:	6a 00                	push   $0x0
  pushl $72
80106aed:	6a 48                	push   $0x48
  jmp alltraps
80106aef:	e9 8e f6 ff ff       	jmp    80106182 <alltraps>

80106af4 <vector73>:
.globl vector73
vector73:
  pushl $0
80106af4:	6a 00                	push   $0x0
  pushl $73
80106af6:	6a 49                	push   $0x49
  jmp alltraps
80106af8:	e9 85 f6 ff ff       	jmp    80106182 <alltraps>

80106afd <vector74>:
.globl vector74
vector74:
  pushl $0
80106afd:	6a 00                	push   $0x0
  pushl $74
80106aff:	6a 4a                	push   $0x4a
  jmp alltraps
80106b01:	e9 7c f6 ff ff       	jmp    80106182 <alltraps>

80106b06 <vector75>:
.globl vector75
vector75:
  pushl $0
80106b06:	6a 00                	push   $0x0
  pushl $75
80106b08:	6a 4b                	push   $0x4b
  jmp alltraps
80106b0a:	e9 73 f6 ff ff       	jmp    80106182 <alltraps>

80106b0f <vector76>:
.globl vector76
vector76:
  pushl $0
80106b0f:	6a 00                	push   $0x0
  pushl $76
80106b11:	6a 4c                	push   $0x4c
  jmp alltraps
80106b13:	e9 6a f6 ff ff       	jmp    80106182 <alltraps>

80106b18 <vector77>:
.globl vector77
vector77:
  pushl $0
80106b18:	6a 00                	push   $0x0
  pushl $77
80106b1a:	6a 4d                	push   $0x4d
  jmp alltraps
80106b1c:	e9 61 f6 ff ff       	jmp    80106182 <alltraps>

80106b21 <vector78>:
.globl vector78
vector78:
  pushl $0
80106b21:	6a 00                	push   $0x0
  pushl $78
80106b23:	6a 4e                	push   $0x4e
  jmp alltraps
80106b25:	e9 58 f6 ff ff       	jmp    80106182 <alltraps>

80106b2a <vector79>:
.globl vector79
vector79:
  pushl $0
80106b2a:	6a 00                	push   $0x0
  pushl $79
80106b2c:	6a 4f                	push   $0x4f
  jmp alltraps
80106b2e:	e9 4f f6 ff ff       	jmp    80106182 <alltraps>

80106b33 <vector80>:
.globl vector80
vector80:
  pushl $0
80106b33:	6a 00                	push   $0x0
  pushl $80
80106b35:	6a 50                	push   $0x50
  jmp alltraps
80106b37:	e9 46 f6 ff ff       	jmp    80106182 <alltraps>

80106b3c <vector81>:
.globl vector81
vector81:
  pushl $0
80106b3c:	6a 00                	push   $0x0
  pushl $81
80106b3e:	6a 51                	push   $0x51
  jmp alltraps
80106b40:	e9 3d f6 ff ff       	jmp    80106182 <alltraps>

80106b45 <vector82>:
.globl vector82
vector82:
  pushl $0
80106b45:	6a 00                	push   $0x0
  pushl $82
80106b47:	6a 52                	push   $0x52
  jmp alltraps
80106b49:	e9 34 f6 ff ff       	jmp    80106182 <alltraps>

80106b4e <vector83>:
.globl vector83
vector83:
  pushl $0
80106b4e:	6a 00                	push   $0x0
  pushl $83
80106b50:	6a 53                	push   $0x53
  jmp alltraps
80106b52:	e9 2b f6 ff ff       	jmp    80106182 <alltraps>

80106b57 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b57:	6a 00                	push   $0x0
  pushl $84
80106b59:	6a 54                	push   $0x54
  jmp alltraps
80106b5b:	e9 22 f6 ff ff       	jmp    80106182 <alltraps>

80106b60 <vector85>:
.globl vector85
vector85:
  pushl $0
80106b60:	6a 00                	push   $0x0
  pushl $85
80106b62:	6a 55                	push   $0x55
  jmp alltraps
80106b64:	e9 19 f6 ff ff       	jmp    80106182 <alltraps>

80106b69 <vector86>:
.globl vector86
vector86:
  pushl $0
80106b69:	6a 00                	push   $0x0
  pushl $86
80106b6b:	6a 56                	push   $0x56
  jmp alltraps
80106b6d:	e9 10 f6 ff ff       	jmp    80106182 <alltraps>

80106b72 <vector87>:
.globl vector87
vector87:
  pushl $0
80106b72:	6a 00                	push   $0x0
  pushl $87
80106b74:	6a 57                	push   $0x57
  jmp alltraps
80106b76:	e9 07 f6 ff ff       	jmp    80106182 <alltraps>

80106b7b <vector88>:
.globl vector88
vector88:
  pushl $0
80106b7b:	6a 00                	push   $0x0
  pushl $88
80106b7d:	6a 58                	push   $0x58
  jmp alltraps
80106b7f:	e9 fe f5 ff ff       	jmp    80106182 <alltraps>

80106b84 <vector89>:
.globl vector89
vector89:
  pushl $0
80106b84:	6a 00                	push   $0x0
  pushl $89
80106b86:	6a 59                	push   $0x59
  jmp alltraps
80106b88:	e9 f5 f5 ff ff       	jmp    80106182 <alltraps>

80106b8d <vector90>:
.globl vector90
vector90:
  pushl $0
80106b8d:	6a 00                	push   $0x0
  pushl $90
80106b8f:	6a 5a                	push   $0x5a
  jmp alltraps
80106b91:	e9 ec f5 ff ff       	jmp    80106182 <alltraps>

80106b96 <vector91>:
.globl vector91
vector91:
  pushl $0
80106b96:	6a 00                	push   $0x0
  pushl $91
80106b98:	6a 5b                	push   $0x5b
  jmp alltraps
80106b9a:	e9 e3 f5 ff ff       	jmp    80106182 <alltraps>

80106b9f <vector92>:
.globl vector92
vector92:
  pushl $0
80106b9f:	6a 00                	push   $0x0
  pushl $92
80106ba1:	6a 5c                	push   $0x5c
  jmp alltraps
80106ba3:	e9 da f5 ff ff       	jmp    80106182 <alltraps>

80106ba8 <vector93>:
.globl vector93
vector93:
  pushl $0
80106ba8:	6a 00                	push   $0x0
  pushl $93
80106baa:	6a 5d                	push   $0x5d
  jmp alltraps
80106bac:	e9 d1 f5 ff ff       	jmp    80106182 <alltraps>

80106bb1 <vector94>:
.globl vector94
vector94:
  pushl $0
80106bb1:	6a 00                	push   $0x0
  pushl $94
80106bb3:	6a 5e                	push   $0x5e
  jmp alltraps
80106bb5:	e9 c8 f5 ff ff       	jmp    80106182 <alltraps>

80106bba <vector95>:
.globl vector95
vector95:
  pushl $0
80106bba:	6a 00                	push   $0x0
  pushl $95
80106bbc:	6a 5f                	push   $0x5f
  jmp alltraps
80106bbe:	e9 bf f5 ff ff       	jmp    80106182 <alltraps>

80106bc3 <vector96>:
.globl vector96
vector96:
  pushl $0
80106bc3:	6a 00                	push   $0x0
  pushl $96
80106bc5:	6a 60                	push   $0x60
  jmp alltraps
80106bc7:	e9 b6 f5 ff ff       	jmp    80106182 <alltraps>

80106bcc <vector97>:
.globl vector97
vector97:
  pushl $0
80106bcc:	6a 00                	push   $0x0
  pushl $97
80106bce:	6a 61                	push   $0x61
  jmp alltraps
80106bd0:	e9 ad f5 ff ff       	jmp    80106182 <alltraps>

80106bd5 <vector98>:
.globl vector98
vector98:
  pushl $0
80106bd5:	6a 00                	push   $0x0
  pushl $98
80106bd7:	6a 62                	push   $0x62
  jmp alltraps
80106bd9:	e9 a4 f5 ff ff       	jmp    80106182 <alltraps>

80106bde <vector99>:
.globl vector99
vector99:
  pushl $0
80106bde:	6a 00                	push   $0x0
  pushl $99
80106be0:	6a 63                	push   $0x63
  jmp alltraps
80106be2:	e9 9b f5 ff ff       	jmp    80106182 <alltraps>

80106be7 <vector100>:
.globl vector100
vector100:
  pushl $0
80106be7:	6a 00                	push   $0x0
  pushl $100
80106be9:	6a 64                	push   $0x64
  jmp alltraps
80106beb:	e9 92 f5 ff ff       	jmp    80106182 <alltraps>

80106bf0 <vector101>:
.globl vector101
vector101:
  pushl $0
80106bf0:	6a 00                	push   $0x0
  pushl $101
80106bf2:	6a 65                	push   $0x65
  jmp alltraps
80106bf4:	e9 89 f5 ff ff       	jmp    80106182 <alltraps>

80106bf9 <vector102>:
.globl vector102
vector102:
  pushl $0
80106bf9:	6a 00                	push   $0x0
  pushl $102
80106bfb:	6a 66                	push   $0x66
  jmp alltraps
80106bfd:	e9 80 f5 ff ff       	jmp    80106182 <alltraps>

80106c02 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c02:	6a 00                	push   $0x0
  pushl $103
80106c04:	6a 67                	push   $0x67
  jmp alltraps
80106c06:	e9 77 f5 ff ff       	jmp    80106182 <alltraps>

80106c0b <vector104>:
.globl vector104
vector104:
  pushl $0
80106c0b:	6a 00                	push   $0x0
  pushl $104
80106c0d:	6a 68                	push   $0x68
  jmp alltraps
80106c0f:	e9 6e f5 ff ff       	jmp    80106182 <alltraps>

80106c14 <vector105>:
.globl vector105
vector105:
  pushl $0
80106c14:	6a 00                	push   $0x0
  pushl $105
80106c16:	6a 69                	push   $0x69
  jmp alltraps
80106c18:	e9 65 f5 ff ff       	jmp    80106182 <alltraps>

80106c1d <vector106>:
.globl vector106
vector106:
  pushl $0
80106c1d:	6a 00                	push   $0x0
  pushl $106
80106c1f:	6a 6a                	push   $0x6a
  jmp alltraps
80106c21:	e9 5c f5 ff ff       	jmp    80106182 <alltraps>

80106c26 <vector107>:
.globl vector107
vector107:
  pushl $0
80106c26:	6a 00                	push   $0x0
  pushl $107
80106c28:	6a 6b                	push   $0x6b
  jmp alltraps
80106c2a:	e9 53 f5 ff ff       	jmp    80106182 <alltraps>

80106c2f <vector108>:
.globl vector108
vector108:
  pushl $0
80106c2f:	6a 00                	push   $0x0
  pushl $108
80106c31:	6a 6c                	push   $0x6c
  jmp alltraps
80106c33:	e9 4a f5 ff ff       	jmp    80106182 <alltraps>

80106c38 <vector109>:
.globl vector109
vector109:
  pushl $0
80106c38:	6a 00                	push   $0x0
  pushl $109
80106c3a:	6a 6d                	push   $0x6d
  jmp alltraps
80106c3c:	e9 41 f5 ff ff       	jmp    80106182 <alltraps>

80106c41 <vector110>:
.globl vector110
vector110:
  pushl $0
80106c41:	6a 00                	push   $0x0
  pushl $110
80106c43:	6a 6e                	push   $0x6e
  jmp alltraps
80106c45:	e9 38 f5 ff ff       	jmp    80106182 <alltraps>

80106c4a <vector111>:
.globl vector111
vector111:
  pushl $0
80106c4a:	6a 00                	push   $0x0
  pushl $111
80106c4c:	6a 6f                	push   $0x6f
  jmp alltraps
80106c4e:	e9 2f f5 ff ff       	jmp    80106182 <alltraps>

80106c53 <vector112>:
.globl vector112
vector112:
  pushl $0
80106c53:	6a 00                	push   $0x0
  pushl $112
80106c55:	6a 70                	push   $0x70
  jmp alltraps
80106c57:	e9 26 f5 ff ff       	jmp    80106182 <alltraps>

80106c5c <vector113>:
.globl vector113
vector113:
  pushl $0
80106c5c:	6a 00                	push   $0x0
  pushl $113
80106c5e:	6a 71                	push   $0x71
  jmp alltraps
80106c60:	e9 1d f5 ff ff       	jmp    80106182 <alltraps>

80106c65 <vector114>:
.globl vector114
vector114:
  pushl $0
80106c65:	6a 00                	push   $0x0
  pushl $114
80106c67:	6a 72                	push   $0x72
  jmp alltraps
80106c69:	e9 14 f5 ff ff       	jmp    80106182 <alltraps>

80106c6e <vector115>:
.globl vector115
vector115:
  pushl $0
80106c6e:	6a 00                	push   $0x0
  pushl $115
80106c70:	6a 73                	push   $0x73
  jmp alltraps
80106c72:	e9 0b f5 ff ff       	jmp    80106182 <alltraps>

80106c77 <vector116>:
.globl vector116
vector116:
  pushl $0
80106c77:	6a 00                	push   $0x0
  pushl $116
80106c79:	6a 74                	push   $0x74
  jmp alltraps
80106c7b:	e9 02 f5 ff ff       	jmp    80106182 <alltraps>

80106c80 <vector117>:
.globl vector117
vector117:
  pushl $0
80106c80:	6a 00                	push   $0x0
  pushl $117
80106c82:	6a 75                	push   $0x75
  jmp alltraps
80106c84:	e9 f9 f4 ff ff       	jmp    80106182 <alltraps>

80106c89 <vector118>:
.globl vector118
vector118:
  pushl $0
80106c89:	6a 00                	push   $0x0
  pushl $118
80106c8b:	6a 76                	push   $0x76
  jmp alltraps
80106c8d:	e9 f0 f4 ff ff       	jmp    80106182 <alltraps>

80106c92 <vector119>:
.globl vector119
vector119:
  pushl $0
80106c92:	6a 00                	push   $0x0
  pushl $119
80106c94:	6a 77                	push   $0x77
  jmp alltraps
80106c96:	e9 e7 f4 ff ff       	jmp    80106182 <alltraps>

80106c9b <vector120>:
.globl vector120
vector120:
  pushl $0
80106c9b:	6a 00                	push   $0x0
  pushl $120
80106c9d:	6a 78                	push   $0x78
  jmp alltraps
80106c9f:	e9 de f4 ff ff       	jmp    80106182 <alltraps>

80106ca4 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ca4:	6a 00                	push   $0x0
  pushl $121
80106ca6:	6a 79                	push   $0x79
  jmp alltraps
80106ca8:	e9 d5 f4 ff ff       	jmp    80106182 <alltraps>

80106cad <vector122>:
.globl vector122
vector122:
  pushl $0
80106cad:	6a 00                	push   $0x0
  pushl $122
80106caf:	6a 7a                	push   $0x7a
  jmp alltraps
80106cb1:	e9 cc f4 ff ff       	jmp    80106182 <alltraps>

80106cb6 <vector123>:
.globl vector123
vector123:
  pushl $0
80106cb6:	6a 00                	push   $0x0
  pushl $123
80106cb8:	6a 7b                	push   $0x7b
  jmp alltraps
80106cba:	e9 c3 f4 ff ff       	jmp    80106182 <alltraps>

80106cbf <vector124>:
.globl vector124
vector124:
  pushl $0
80106cbf:	6a 00                	push   $0x0
  pushl $124
80106cc1:	6a 7c                	push   $0x7c
  jmp alltraps
80106cc3:	e9 ba f4 ff ff       	jmp    80106182 <alltraps>

80106cc8 <vector125>:
.globl vector125
vector125:
  pushl $0
80106cc8:	6a 00                	push   $0x0
  pushl $125
80106cca:	6a 7d                	push   $0x7d
  jmp alltraps
80106ccc:	e9 b1 f4 ff ff       	jmp    80106182 <alltraps>

80106cd1 <vector126>:
.globl vector126
vector126:
  pushl $0
80106cd1:	6a 00                	push   $0x0
  pushl $126
80106cd3:	6a 7e                	push   $0x7e
  jmp alltraps
80106cd5:	e9 a8 f4 ff ff       	jmp    80106182 <alltraps>

80106cda <vector127>:
.globl vector127
vector127:
  pushl $0
80106cda:	6a 00                	push   $0x0
  pushl $127
80106cdc:	6a 7f                	push   $0x7f
  jmp alltraps
80106cde:	e9 9f f4 ff ff       	jmp    80106182 <alltraps>

80106ce3 <vector128>:
.globl vector128
vector128:
  pushl $0
80106ce3:	6a 00                	push   $0x0
  pushl $128
80106ce5:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106cea:	e9 93 f4 ff ff       	jmp    80106182 <alltraps>

80106cef <vector129>:
.globl vector129
vector129:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $129
80106cf1:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106cf6:	e9 87 f4 ff ff       	jmp    80106182 <alltraps>

80106cfb <vector130>:
.globl vector130
vector130:
  pushl $0
80106cfb:	6a 00                	push   $0x0
  pushl $130
80106cfd:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d02:	e9 7b f4 ff ff       	jmp    80106182 <alltraps>

80106d07 <vector131>:
.globl vector131
vector131:
  pushl $0
80106d07:	6a 00                	push   $0x0
  pushl $131
80106d09:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d0e:	e9 6f f4 ff ff       	jmp    80106182 <alltraps>

80106d13 <vector132>:
.globl vector132
vector132:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $132
80106d15:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d1a:	e9 63 f4 ff ff       	jmp    80106182 <alltraps>

80106d1f <vector133>:
.globl vector133
vector133:
  pushl $0
80106d1f:	6a 00                	push   $0x0
  pushl $133
80106d21:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d26:	e9 57 f4 ff ff       	jmp    80106182 <alltraps>

80106d2b <vector134>:
.globl vector134
vector134:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $134
80106d2d:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d32:	e9 4b f4 ff ff       	jmp    80106182 <alltraps>

80106d37 <vector135>:
.globl vector135
vector135:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $135
80106d39:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d3e:	e9 3f f4 ff ff       	jmp    80106182 <alltraps>

80106d43 <vector136>:
.globl vector136
vector136:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $136
80106d45:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d4a:	e9 33 f4 ff ff       	jmp    80106182 <alltraps>

80106d4f <vector137>:
.globl vector137
vector137:
  pushl $0
80106d4f:	6a 00                	push   $0x0
  pushl $137
80106d51:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d56:	e9 27 f4 ff ff       	jmp    80106182 <alltraps>

80106d5b <vector138>:
.globl vector138
vector138:
  pushl $0
80106d5b:	6a 00                	push   $0x0
  pushl $138
80106d5d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d62:	e9 1b f4 ff ff       	jmp    80106182 <alltraps>

80106d67 <vector139>:
.globl vector139
vector139:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $139
80106d69:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d6e:	e9 0f f4 ff ff       	jmp    80106182 <alltraps>

80106d73 <vector140>:
.globl vector140
vector140:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $140
80106d75:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106d7a:	e9 03 f4 ff ff       	jmp    80106182 <alltraps>

80106d7f <vector141>:
.globl vector141
vector141:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $141
80106d81:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106d86:	e9 f7 f3 ff ff       	jmp    80106182 <alltraps>

80106d8b <vector142>:
.globl vector142
vector142:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $142
80106d8d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106d92:	e9 eb f3 ff ff       	jmp    80106182 <alltraps>

80106d97 <vector143>:
.globl vector143
vector143:
  pushl $0
80106d97:	6a 00                	push   $0x0
  pushl $143
80106d99:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106d9e:	e9 df f3 ff ff       	jmp    80106182 <alltraps>

80106da3 <vector144>:
.globl vector144
vector144:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $144
80106da5:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106daa:	e9 d3 f3 ff ff       	jmp    80106182 <alltraps>

80106daf <vector145>:
.globl vector145
vector145:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $145
80106db1:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106db6:	e9 c7 f3 ff ff       	jmp    80106182 <alltraps>

80106dbb <vector146>:
.globl vector146
vector146:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $146
80106dbd:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106dc2:	e9 bb f3 ff ff       	jmp    80106182 <alltraps>

80106dc7 <vector147>:
.globl vector147
vector147:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $147
80106dc9:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106dce:	e9 af f3 ff ff       	jmp    80106182 <alltraps>

80106dd3 <vector148>:
.globl vector148
vector148:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $148
80106dd5:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106dda:	e9 a3 f3 ff ff       	jmp    80106182 <alltraps>

80106ddf <vector149>:
.globl vector149
vector149:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $149
80106de1:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106de6:	e9 97 f3 ff ff       	jmp    80106182 <alltraps>

80106deb <vector150>:
.globl vector150
vector150:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $150
80106ded:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106df2:	e9 8b f3 ff ff       	jmp    80106182 <alltraps>

80106df7 <vector151>:
.globl vector151
vector151:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $151
80106df9:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106dfe:	e9 7f f3 ff ff       	jmp    80106182 <alltraps>

80106e03 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $152
80106e05:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e0a:	e9 73 f3 ff ff       	jmp    80106182 <alltraps>

80106e0f <vector153>:
.globl vector153
vector153:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $153
80106e11:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e16:	e9 67 f3 ff ff       	jmp    80106182 <alltraps>

80106e1b <vector154>:
.globl vector154
vector154:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $154
80106e1d:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e22:	e9 5b f3 ff ff       	jmp    80106182 <alltraps>

80106e27 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $155
80106e29:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e2e:	e9 4f f3 ff ff       	jmp    80106182 <alltraps>

80106e33 <vector156>:
.globl vector156
vector156:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $156
80106e35:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e3a:	e9 43 f3 ff ff       	jmp    80106182 <alltraps>

80106e3f <vector157>:
.globl vector157
vector157:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $157
80106e41:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e46:	e9 37 f3 ff ff       	jmp    80106182 <alltraps>

80106e4b <vector158>:
.globl vector158
vector158:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $158
80106e4d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e52:	e9 2b f3 ff ff       	jmp    80106182 <alltraps>

80106e57 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $159
80106e59:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e5e:	e9 1f f3 ff ff       	jmp    80106182 <alltraps>

80106e63 <vector160>:
.globl vector160
vector160:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $160
80106e65:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e6a:	e9 13 f3 ff ff       	jmp    80106182 <alltraps>

80106e6f <vector161>:
.globl vector161
vector161:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $161
80106e71:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106e76:	e9 07 f3 ff ff       	jmp    80106182 <alltraps>

80106e7b <vector162>:
.globl vector162
vector162:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $162
80106e7d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106e82:	e9 fb f2 ff ff       	jmp    80106182 <alltraps>

80106e87 <vector163>:
.globl vector163
vector163:
  pushl $0
80106e87:	6a 00                	push   $0x0
  pushl $163
80106e89:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106e8e:	e9 ef f2 ff ff       	jmp    80106182 <alltraps>

80106e93 <vector164>:
.globl vector164
vector164:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $164
80106e95:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106e9a:	e9 e3 f2 ff ff       	jmp    80106182 <alltraps>

80106e9f <vector165>:
.globl vector165
vector165:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $165
80106ea1:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ea6:	e9 d7 f2 ff ff       	jmp    80106182 <alltraps>

80106eab <vector166>:
.globl vector166
vector166:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $166
80106ead:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106eb2:	e9 cb f2 ff ff       	jmp    80106182 <alltraps>

80106eb7 <vector167>:
.globl vector167
vector167:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $167
80106eb9:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106ebe:	e9 bf f2 ff ff       	jmp    80106182 <alltraps>

80106ec3 <vector168>:
.globl vector168
vector168:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $168
80106ec5:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106eca:	e9 b3 f2 ff ff       	jmp    80106182 <alltraps>

80106ecf <vector169>:
.globl vector169
vector169:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $169
80106ed1:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106ed6:	e9 a7 f2 ff ff       	jmp    80106182 <alltraps>

80106edb <vector170>:
.globl vector170
vector170:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $170
80106edd:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106ee2:	e9 9b f2 ff ff       	jmp    80106182 <alltraps>

80106ee7 <vector171>:
.globl vector171
vector171:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $171
80106ee9:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106eee:	e9 8f f2 ff ff       	jmp    80106182 <alltraps>

80106ef3 <vector172>:
.globl vector172
vector172:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $172
80106ef5:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106efa:	e9 83 f2 ff ff       	jmp    80106182 <alltraps>

80106eff <vector173>:
.globl vector173
vector173:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $173
80106f01:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f06:	e9 77 f2 ff ff       	jmp    80106182 <alltraps>

80106f0b <vector174>:
.globl vector174
vector174:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $174
80106f0d:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f12:	e9 6b f2 ff ff       	jmp    80106182 <alltraps>

80106f17 <vector175>:
.globl vector175
vector175:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $175
80106f19:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f1e:	e9 5f f2 ff ff       	jmp    80106182 <alltraps>

80106f23 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $176
80106f25:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f2a:	e9 53 f2 ff ff       	jmp    80106182 <alltraps>

80106f2f <vector177>:
.globl vector177
vector177:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $177
80106f31:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f36:	e9 47 f2 ff ff       	jmp    80106182 <alltraps>

80106f3b <vector178>:
.globl vector178
vector178:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $178
80106f3d:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f42:	e9 3b f2 ff ff       	jmp    80106182 <alltraps>

80106f47 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $179
80106f49:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f4e:	e9 2f f2 ff ff       	jmp    80106182 <alltraps>

80106f53 <vector180>:
.globl vector180
vector180:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $180
80106f55:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f5a:	e9 23 f2 ff ff       	jmp    80106182 <alltraps>

80106f5f <vector181>:
.globl vector181
vector181:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $181
80106f61:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f66:	e9 17 f2 ff ff       	jmp    80106182 <alltraps>

80106f6b <vector182>:
.globl vector182
vector182:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $182
80106f6d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106f72:	e9 0b f2 ff ff       	jmp    80106182 <alltraps>

80106f77 <vector183>:
.globl vector183
vector183:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $183
80106f79:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106f7e:	e9 ff f1 ff ff       	jmp    80106182 <alltraps>

80106f83 <vector184>:
.globl vector184
vector184:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $184
80106f85:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106f8a:	e9 f3 f1 ff ff       	jmp    80106182 <alltraps>

80106f8f <vector185>:
.globl vector185
vector185:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $185
80106f91:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106f96:	e9 e7 f1 ff ff       	jmp    80106182 <alltraps>

80106f9b <vector186>:
.globl vector186
vector186:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $186
80106f9d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106fa2:	e9 db f1 ff ff       	jmp    80106182 <alltraps>

80106fa7 <vector187>:
.globl vector187
vector187:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $187
80106fa9:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106fae:	e9 cf f1 ff ff       	jmp    80106182 <alltraps>

80106fb3 <vector188>:
.globl vector188
vector188:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $188
80106fb5:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106fba:	e9 c3 f1 ff ff       	jmp    80106182 <alltraps>

80106fbf <vector189>:
.globl vector189
vector189:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $189
80106fc1:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106fc6:	e9 b7 f1 ff ff       	jmp    80106182 <alltraps>

80106fcb <vector190>:
.globl vector190
vector190:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $190
80106fcd:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106fd2:	e9 ab f1 ff ff       	jmp    80106182 <alltraps>

80106fd7 <vector191>:
.globl vector191
vector191:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $191
80106fd9:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106fde:	e9 9f f1 ff ff       	jmp    80106182 <alltraps>

80106fe3 <vector192>:
.globl vector192
vector192:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $192
80106fe5:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106fea:	e9 93 f1 ff ff       	jmp    80106182 <alltraps>

80106fef <vector193>:
.globl vector193
vector193:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $193
80106ff1:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106ff6:	e9 87 f1 ff ff       	jmp    80106182 <alltraps>

80106ffb <vector194>:
.globl vector194
vector194:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $194
80106ffd:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107002:	e9 7b f1 ff ff       	jmp    80106182 <alltraps>

80107007 <vector195>:
.globl vector195
vector195:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $195
80107009:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010700e:	e9 6f f1 ff ff       	jmp    80106182 <alltraps>

80107013 <vector196>:
.globl vector196
vector196:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $196
80107015:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010701a:	e9 63 f1 ff ff       	jmp    80106182 <alltraps>

8010701f <vector197>:
.globl vector197
vector197:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $197
80107021:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107026:	e9 57 f1 ff ff       	jmp    80106182 <alltraps>

8010702b <vector198>:
.globl vector198
vector198:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $198
8010702d:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107032:	e9 4b f1 ff ff       	jmp    80106182 <alltraps>

80107037 <vector199>:
.globl vector199
vector199:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $199
80107039:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010703e:	e9 3f f1 ff ff       	jmp    80106182 <alltraps>

80107043 <vector200>:
.globl vector200
vector200:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $200
80107045:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010704a:	e9 33 f1 ff ff       	jmp    80106182 <alltraps>

8010704f <vector201>:
.globl vector201
vector201:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $201
80107051:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107056:	e9 27 f1 ff ff       	jmp    80106182 <alltraps>

8010705b <vector202>:
.globl vector202
vector202:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $202
8010705d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107062:	e9 1b f1 ff ff       	jmp    80106182 <alltraps>

80107067 <vector203>:
.globl vector203
vector203:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $203
80107069:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010706e:	e9 0f f1 ff ff       	jmp    80106182 <alltraps>

80107073 <vector204>:
.globl vector204
vector204:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $204
80107075:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010707a:	e9 03 f1 ff ff       	jmp    80106182 <alltraps>

8010707f <vector205>:
.globl vector205
vector205:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $205
80107081:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107086:	e9 f7 f0 ff ff       	jmp    80106182 <alltraps>

8010708b <vector206>:
.globl vector206
vector206:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $206
8010708d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107092:	e9 eb f0 ff ff       	jmp    80106182 <alltraps>

80107097 <vector207>:
.globl vector207
vector207:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $207
80107099:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010709e:	e9 df f0 ff ff       	jmp    80106182 <alltraps>

801070a3 <vector208>:
.globl vector208
vector208:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $208
801070a5:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070aa:	e9 d3 f0 ff ff       	jmp    80106182 <alltraps>

801070af <vector209>:
.globl vector209
vector209:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $209
801070b1:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801070b6:	e9 c7 f0 ff ff       	jmp    80106182 <alltraps>

801070bb <vector210>:
.globl vector210
vector210:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $210
801070bd:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070c2:	e9 bb f0 ff ff       	jmp    80106182 <alltraps>

801070c7 <vector211>:
.globl vector211
vector211:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $211
801070c9:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801070ce:	e9 af f0 ff ff       	jmp    80106182 <alltraps>

801070d3 <vector212>:
.globl vector212
vector212:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $212
801070d5:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801070da:	e9 a3 f0 ff ff       	jmp    80106182 <alltraps>

801070df <vector213>:
.globl vector213
vector213:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $213
801070e1:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801070e6:	e9 97 f0 ff ff       	jmp    80106182 <alltraps>

801070eb <vector214>:
.globl vector214
vector214:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $214
801070ed:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801070f2:	e9 8b f0 ff ff       	jmp    80106182 <alltraps>

801070f7 <vector215>:
.globl vector215
vector215:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $215
801070f9:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801070fe:	e9 7f f0 ff ff       	jmp    80106182 <alltraps>

80107103 <vector216>:
.globl vector216
vector216:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $216
80107105:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010710a:	e9 73 f0 ff ff       	jmp    80106182 <alltraps>

8010710f <vector217>:
.globl vector217
vector217:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $217
80107111:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107116:	e9 67 f0 ff ff       	jmp    80106182 <alltraps>

8010711b <vector218>:
.globl vector218
vector218:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $218
8010711d:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107122:	e9 5b f0 ff ff       	jmp    80106182 <alltraps>

80107127 <vector219>:
.globl vector219
vector219:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $219
80107129:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010712e:	e9 4f f0 ff ff       	jmp    80106182 <alltraps>

80107133 <vector220>:
.globl vector220
vector220:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $220
80107135:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010713a:	e9 43 f0 ff ff       	jmp    80106182 <alltraps>

8010713f <vector221>:
.globl vector221
vector221:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $221
80107141:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107146:	e9 37 f0 ff ff       	jmp    80106182 <alltraps>

8010714b <vector222>:
.globl vector222
vector222:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $222
8010714d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107152:	e9 2b f0 ff ff       	jmp    80106182 <alltraps>

80107157 <vector223>:
.globl vector223
vector223:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $223
80107159:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010715e:	e9 1f f0 ff ff       	jmp    80106182 <alltraps>

80107163 <vector224>:
.globl vector224
vector224:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $224
80107165:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010716a:	e9 13 f0 ff ff       	jmp    80106182 <alltraps>

8010716f <vector225>:
.globl vector225
vector225:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $225
80107171:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107176:	e9 07 f0 ff ff       	jmp    80106182 <alltraps>

8010717b <vector226>:
.globl vector226
vector226:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $226
8010717d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107182:	e9 fb ef ff ff       	jmp    80106182 <alltraps>

80107187 <vector227>:
.globl vector227
vector227:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $227
80107189:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010718e:	e9 ef ef ff ff       	jmp    80106182 <alltraps>

80107193 <vector228>:
.globl vector228
vector228:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $228
80107195:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010719a:	e9 e3 ef ff ff       	jmp    80106182 <alltraps>

8010719f <vector229>:
.globl vector229
vector229:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $229
801071a1:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071a6:	e9 d7 ef ff ff       	jmp    80106182 <alltraps>

801071ab <vector230>:
.globl vector230
vector230:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $230
801071ad:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801071b2:	e9 cb ef ff ff       	jmp    80106182 <alltraps>

801071b7 <vector231>:
.globl vector231
vector231:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $231
801071b9:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801071be:	e9 bf ef ff ff       	jmp    80106182 <alltraps>

801071c3 <vector232>:
.globl vector232
vector232:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $232
801071c5:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801071ca:	e9 b3 ef ff ff       	jmp    80106182 <alltraps>

801071cf <vector233>:
.globl vector233
vector233:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $233
801071d1:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801071d6:	e9 a7 ef ff ff       	jmp    80106182 <alltraps>

801071db <vector234>:
.globl vector234
vector234:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $234
801071dd:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801071e2:	e9 9b ef ff ff       	jmp    80106182 <alltraps>

801071e7 <vector235>:
.globl vector235
vector235:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $235
801071e9:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801071ee:	e9 8f ef ff ff       	jmp    80106182 <alltraps>

801071f3 <vector236>:
.globl vector236
vector236:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $236
801071f5:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801071fa:	e9 83 ef ff ff       	jmp    80106182 <alltraps>

801071ff <vector237>:
.globl vector237
vector237:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $237
80107201:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107206:	e9 77 ef ff ff       	jmp    80106182 <alltraps>

8010720b <vector238>:
.globl vector238
vector238:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $238
8010720d:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107212:	e9 6b ef ff ff       	jmp    80106182 <alltraps>

80107217 <vector239>:
.globl vector239
vector239:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $239
80107219:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010721e:	e9 5f ef ff ff       	jmp    80106182 <alltraps>

80107223 <vector240>:
.globl vector240
vector240:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $240
80107225:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010722a:	e9 53 ef ff ff       	jmp    80106182 <alltraps>

8010722f <vector241>:
.globl vector241
vector241:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $241
80107231:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107236:	e9 47 ef ff ff       	jmp    80106182 <alltraps>

8010723b <vector242>:
.globl vector242
vector242:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $242
8010723d:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107242:	e9 3b ef ff ff       	jmp    80106182 <alltraps>

80107247 <vector243>:
.globl vector243
vector243:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $243
80107249:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010724e:	e9 2f ef ff ff       	jmp    80106182 <alltraps>

80107253 <vector244>:
.globl vector244
vector244:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $244
80107255:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010725a:	e9 23 ef ff ff       	jmp    80106182 <alltraps>

8010725f <vector245>:
.globl vector245
vector245:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $245
80107261:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107266:	e9 17 ef ff ff       	jmp    80106182 <alltraps>

8010726b <vector246>:
.globl vector246
vector246:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $246
8010726d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107272:	e9 0b ef ff ff       	jmp    80106182 <alltraps>

80107277 <vector247>:
.globl vector247
vector247:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $247
80107279:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010727e:	e9 ff ee ff ff       	jmp    80106182 <alltraps>

80107283 <vector248>:
.globl vector248
vector248:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $248
80107285:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010728a:	e9 f3 ee ff ff       	jmp    80106182 <alltraps>

8010728f <vector249>:
.globl vector249
vector249:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $249
80107291:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107296:	e9 e7 ee ff ff       	jmp    80106182 <alltraps>

8010729b <vector250>:
.globl vector250
vector250:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $250
8010729d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072a2:	e9 db ee ff ff       	jmp    80106182 <alltraps>

801072a7 <vector251>:
.globl vector251
vector251:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $251
801072a9:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801072ae:	e9 cf ee ff ff       	jmp    80106182 <alltraps>

801072b3 <vector252>:
.globl vector252
vector252:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $252
801072b5:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801072ba:	e9 c3 ee ff ff       	jmp    80106182 <alltraps>

801072bf <vector253>:
.globl vector253
vector253:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $253
801072c1:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801072c6:	e9 b7 ee ff ff       	jmp    80106182 <alltraps>

801072cb <vector254>:
.globl vector254
vector254:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $254
801072cd:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801072d2:	e9 ab ee ff ff       	jmp    80106182 <alltraps>

801072d7 <vector255>:
.globl vector255
vector255:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $255
801072d9:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801072de:	e9 9f ee ff ff       	jmp    80106182 <alltraps>

801072e3 <lgdt>:
{
801072e3:	55                   	push   %ebp
801072e4:	89 e5                	mov    %esp,%ebp
801072e6:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801072e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801072ec:	83 e8 01             	sub    $0x1,%eax
801072ef:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801072f3:	8b 45 08             	mov    0x8(%ebp),%eax
801072f6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801072fa:	8b 45 08             	mov    0x8(%ebp),%eax
801072fd:	c1 e8 10             	shr    $0x10,%eax
80107300:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107304:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107307:	0f 01 10             	lgdtl  (%eax)
}
8010730a:	90                   	nop
8010730b:	c9                   	leave  
8010730c:	c3                   	ret    

8010730d <ltr>:
{
8010730d:	55                   	push   %ebp
8010730e:	89 e5                	mov    %esp,%ebp
80107310:	83 ec 04             	sub    $0x4,%esp
80107313:	8b 45 08             	mov    0x8(%ebp),%eax
80107316:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010731a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010731e:	0f 00 d8             	ltr    %ax
}
80107321:	90                   	nop
80107322:	c9                   	leave  
80107323:	c3                   	ret    

80107324 <lcr3>:

static inline void
lcr3(uint val)
{
80107324:	55                   	push   %ebp
80107325:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107327:	8b 45 08             	mov    0x8(%ebp),%eax
8010732a:	0f 22 d8             	mov    %eax,%cr3
}
8010732d:	90                   	nop
8010732e:	5d                   	pop    %ebp
8010732f:	c3                   	ret    

80107330 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107330:	55                   	push   %ebp
80107331:	89 e5                	mov    %esp,%ebp
80107333:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107336:	e8 62 c6 ff ff       	call   8010399d <cpuid>
8010733b:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107341:	05 80 72 19 80       	add    $0x80197280,%eax
80107346:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734c:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107355:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010735b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735e:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107365:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107369:	83 e2 f0             	and    $0xfffffff0,%edx
8010736c:	83 ca 0a             	or     $0xa,%edx
8010736f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107375:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107379:	83 ca 10             	or     $0x10,%edx
8010737c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010737f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107382:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107386:	83 e2 9f             	and    $0xffffff9f,%edx
80107389:	88 50 7d             	mov    %dl,0x7d(%eax)
8010738c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107393:	83 ca 80             	or     $0xffffff80,%edx
80107396:	88 50 7d             	mov    %dl,0x7d(%eax)
80107399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073a0:	83 ca 0f             	or     $0xf,%edx
801073a3:	88 50 7e             	mov    %dl,0x7e(%eax)
801073a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073ad:	83 e2 ef             	and    $0xffffffef,%edx
801073b0:	88 50 7e             	mov    %dl,0x7e(%eax)
801073b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073ba:	83 e2 df             	and    $0xffffffdf,%edx
801073bd:	88 50 7e             	mov    %dl,0x7e(%eax)
801073c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073c7:	83 ca 40             	or     $0x40,%edx
801073ca:	88 50 7e             	mov    %dl,0x7e(%eax)
801073cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073d4:	83 ca 80             	or     $0xffffff80,%edx
801073d7:	88 50 7e             	mov    %dl,0x7e(%eax)
801073da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073dd:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801073e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e4:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801073eb:	ff ff 
801073ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f0:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801073f7:	00 00 
801073f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fc:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107406:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010740d:	83 e2 f0             	and    $0xfffffff0,%edx
80107410:	83 ca 02             	or     $0x2,%edx
80107413:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107423:	83 ca 10             	or     $0x10,%edx
80107426:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010742c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107436:	83 e2 9f             	and    $0xffffff9f,%edx
80107439:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010743f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107442:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107449:	83 ca 80             	or     $0xffffff80,%edx
8010744c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107455:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010745c:	83 ca 0f             	or     $0xf,%edx
8010745f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107468:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010746f:	83 e2 ef             	and    $0xffffffef,%edx
80107472:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107482:	83 e2 df             	and    $0xffffffdf,%edx
80107485:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010748b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107495:	83 ca 40             	or     $0x40,%edx
80107498:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010749e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074a8:	83 ca 80             	or     $0xffffff80,%edx
801074ab:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b4:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801074bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074be:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801074c5:	ff ff 
801074c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ca:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801074d1:	00 00 
801074d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d6:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801074dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074e7:	83 e2 f0             	and    $0xfffffff0,%edx
801074ea:	83 ca 0a             	or     $0xa,%edx
801074ed:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801074f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074fd:	83 ca 10             	or     $0x10,%edx
80107500:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107509:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107510:	83 ca 60             	or     $0x60,%edx
80107513:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107523:	83 ca 80             	or     $0xffffff80,%edx
80107526:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010752c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107536:	83 ca 0f             	or     $0xf,%edx
80107539:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010753f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107542:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107549:	83 e2 ef             	and    $0xffffffef,%edx
8010754c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107555:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010755c:	83 e2 df             	and    $0xffffffdf,%edx
8010755f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107568:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010756f:	83 ca 40             	or     $0x40,%edx
80107572:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107582:	83 ca 80             	or     $0xffffff80,%edx
80107585:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010758b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758e:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107598:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010759f:	ff ff 
801075a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a4:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801075ab:	00 00 
801075ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801075b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ba:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075c1:	83 e2 f0             	and    $0xfffffff0,%edx
801075c4:	83 ca 02             	or     $0x2,%edx
801075c7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075d7:	83 ca 10             	or     $0x10,%edx
801075da:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075ea:	83 ca 60             	or     $0x60,%edx
801075ed:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075fd:	83 ca 80             	or     $0xffffff80,%edx
80107600:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107609:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107610:	83 ca 0f             	or     $0xf,%edx
80107613:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107623:	83 e2 ef             	and    $0xffffffef,%edx
80107626:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010762c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107636:	83 e2 df             	and    $0xffffffdf,%edx
80107639:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010763f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107642:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107649:	83 ca 40             	or     $0x40,%edx
8010764c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107655:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010765c:	83 ca 80             	or     $0xffffff80,%edx
8010765f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107668:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010766f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107672:	83 c0 70             	add    $0x70,%eax
80107675:	83 ec 08             	sub    $0x8,%esp
80107678:	6a 30                	push   $0x30
8010767a:	50                   	push   %eax
8010767b:	e8 63 fc ff ff       	call   801072e3 <lgdt>
80107680:	83 c4 10             	add    $0x10,%esp
}
80107683:	90                   	nop
80107684:	c9                   	leave  
80107685:	c3                   	ret    

80107686 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107686:	55                   	push   %ebp
80107687:	89 e5                	mov    %esp,%ebp
80107689:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010768c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010768f:	c1 e8 16             	shr    $0x16,%eax
80107692:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107699:	8b 45 08             	mov    0x8(%ebp),%eax
8010769c:	01 d0                	add    %edx,%eax
8010769e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801076a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076a4:	8b 00                	mov    (%eax),%eax
801076a6:	83 e0 01             	and    $0x1,%eax
801076a9:	85 c0                	test   %eax,%eax
801076ab:	74 14                	je     801076c1 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801076ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076b0:	8b 00                	mov    (%eax),%eax
801076b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076b7:	05 00 00 00 80       	add    $0x80000000,%eax
801076bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076bf:	eb 42                	jmp    80107703 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801076c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801076c5:	74 0e                	je     801076d5 <walkpgdir+0x4f>
801076c7:	e8 d4 b0 ff ff       	call   801027a0 <kalloc>
801076cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801076d3:	75 07                	jne    801076dc <walkpgdir+0x56>
      return 0;
801076d5:	b8 00 00 00 00       	mov    $0x0,%eax
801076da:	eb 3e                	jmp    8010771a <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801076dc:	83 ec 04             	sub    $0x4,%esp
801076df:	68 00 10 00 00       	push   $0x1000
801076e4:	6a 00                	push   $0x0
801076e6:	ff 75 f4             	push   -0xc(%ebp)
801076e9:	e8 a6 d6 ff ff       	call   80104d94 <memset>
801076ee:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801076f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f4:	05 00 00 00 80       	add    $0x80000000,%eax
801076f9:	83 c8 07             	or     $0x7,%eax
801076fc:	89 c2                	mov    %eax,%edx
801076fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107701:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107703:	8b 45 0c             	mov    0xc(%ebp),%eax
80107706:	c1 e8 0c             	shr    $0xc,%eax
80107709:	25 ff 03 00 00       	and    $0x3ff,%eax
8010770e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107718:	01 d0                	add    %edx,%eax
}
8010771a:	c9                   	leave  
8010771b:	c3                   	ret    

8010771c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010771c:	55                   	push   %ebp
8010771d:	89 e5                	mov    %esp,%ebp
8010771f:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107722:	8b 45 0c             	mov    0xc(%ebp),%eax
80107725:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010772a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010772d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107730:	8b 45 10             	mov    0x10(%ebp),%eax
80107733:	01 d0                	add    %edx,%eax
80107735:	83 e8 01             	sub    $0x1,%eax
80107738:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010773d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107740:	83 ec 04             	sub    $0x4,%esp
80107743:	6a 01                	push   $0x1
80107745:	ff 75 f4             	push   -0xc(%ebp)
80107748:	ff 75 08             	push   0x8(%ebp)
8010774b:	e8 36 ff ff ff       	call   80107686 <walkpgdir>
80107750:	83 c4 10             	add    $0x10,%esp
80107753:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107756:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010775a:	75 07                	jne    80107763 <mappages+0x47>
      return -1;
8010775c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107761:	eb 47                	jmp    801077aa <mappages+0x8e>
    if(*pte & PTE_P)
80107763:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107766:	8b 00                	mov    (%eax),%eax
80107768:	83 e0 01             	and    $0x1,%eax
8010776b:	85 c0                	test   %eax,%eax
8010776d:	74 0d                	je     8010777c <mappages+0x60>
      panic("remap");
8010776f:	83 ec 0c             	sub    $0xc,%esp
80107772:	68 48 aa 10 80       	push   $0x8010aa48
80107777:	e8 2d 8e ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
8010777c:	8b 45 18             	mov    0x18(%ebp),%eax
8010777f:	0b 45 14             	or     0x14(%ebp),%eax
80107782:	83 c8 01             	or     $0x1,%eax
80107785:	89 c2                	mov    %eax,%edx
80107787:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010778a:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010778c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107792:	74 10                	je     801077a4 <mappages+0x88>
      break;
    a += PGSIZE;
80107794:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010779b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077a2:	eb 9c                	jmp    80107740 <mappages+0x24>
      break;
801077a4:	90                   	nop
  }
  return 0;
801077a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077aa:	c9                   	leave  
801077ab:	c3                   	ret    

801077ac <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801077ac:	55                   	push   %ebp
801077ad:	89 e5                	mov    %esp,%ebp
801077af:	53                   	push   %ebx
801077b0:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801077b3:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801077ba:	8b 15 60 75 19 80    	mov    0x80197560,%edx
801077c0:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801077c5:	29 d0                	sub    %edx,%eax
801077c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
801077ca:	a1 58 75 19 80       	mov    0x80197558,%eax
801077cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077d2:	8b 15 58 75 19 80    	mov    0x80197558,%edx
801077d8:	a1 60 75 19 80       	mov    0x80197560,%eax
801077dd:	01 d0                	add    %edx,%eax
801077df:	89 45 e8             	mov    %eax,-0x18(%ebp)
801077e2:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801077e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ec:	83 c0 30             	add    $0x30,%eax
801077ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
801077f2:	89 10                	mov    %edx,(%eax)
801077f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801077f7:	89 50 04             	mov    %edx,0x4(%eax)
801077fa:	8b 55 e8             	mov    -0x18(%ebp),%edx
801077fd:	89 50 08             	mov    %edx,0x8(%eax)
80107800:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107803:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107806:	e8 95 af ff ff       	call   801027a0 <kalloc>
8010780b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010780e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107812:	75 07                	jne    8010781b <setupkvm+0x6f>
    return 0;
80107814:	b8 00 00 00 00       	mov    $0x0,%eax
80107819:	eb 78                	jmp    80107893 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
8010781b:	83 ec 04             	sub    $0x4,%esp
8010781e:	68 00 10 00 00       	push   $0x1000
80107823:	6a 00                	push   $0x0
80107825:	ff 75 f0             	push   -0x10(%ebp)
80107828:	e8 67 d5 ff ff       	call   80104d94 <memset>
8010782d:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107830:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107837:	eb 4e                	jmp    80107887 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783c:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010783f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107842:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107848:	8b 58 08             	mov    0x8(%eax),%ebx
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	8b 40 04             	mov    0x4(%eax),%eax
80107851:	29 c3                	sub    %eax,%ebx
80107853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107856:	8b 00                	mov    (%eax),%eax
80107858:	83 ec 0c             	sub    $0xc,%esp
8010785b:	51                   	push   %ecx
8010785c:	52                   	push   %edx
8010785d:	53                   	push   %ebx
8010785e:	50                   	push   %eax
8010785f:	ff 75 f0             	push   -0x10(%ebp)
80107862:	e8 b5 fe ff ff       	call   8010771c <mappages>
80107867:	83 c4 20             	add    $0x20,%esp
8010786a:	85 c0                	test   %eax,%eax
8010786c:	79 15                	jns    80107883 <setupkvm+0xd7>
      freevm(pgdir);
8010786e:	83 ec 0c             	sub    $0xc,%esp
80107871:	ff 75 f0             	push   -0x10(%ebp)
80107874:	e8 f5 04 00 00       	call   80107d6e <freevm>
80107879:	83 c4 10             	add    $0x10,%esp
      return 0;
8010787c:	b8 00 00 00 00       	mov    $0x0,%eax
80107881:	eb 10                	jmp    80107893 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107883:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107887:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
8010788e:	72 a9                	jb     80107839 <setupkvm+0x8d>
    }
  return pgdir;
80107890:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107896:	c9                   	leave  
80107897:	c3                   	ret    

80107898 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107898:	55                   	push   %ebp
80107899:	89 e5                	mov    %esp,%ebp
8010789b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010789e:	e8 09 ff ff ff       	call   801077ac <setupkvm>
801078a3:	a3 7c 72 19 80       	mov    %eax,0x8019727c
  switchkvm();
801078a8:	e8 03 00 00 00       	call   801078b0 <switchkvm>
}
801078ad:	90                   	nop
801078ae:	c9                   	leave  
801078af:	c3                   	ret    

801078b0 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078b0:	55                   	push   %ebp
801078b1:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078b3:	a1 7c 72 19 80       	mov    0x8019727c,%eax
801078b8:	05 00 00 00 80       	add    $0x80000000,%eax
801078bd:	50                   	push   %eax
801078be:	e8 61 fa ff ff       	call   80107324 <lcr3>
801078c3:	83 c4 04             	add    $0x4,%esp
}
801078c6:	90                   	nop
801078c7:	c9                   	leave  
801078c8:	c3                   	ret    

801078c9 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801078c9:	55                   	push   %ebp
801078ca:	89 e5                	mov    %esp,%ebp
801078cc:	56                   	push   %esi
801078cd:	53                   	push   %ebx
801078ce:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801078d1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801078d5:	75 0d                	jne    801078e4 <switchuvm+0x1b>
    panic("switchuvm: no process");
801078d7:	83 ec 0c             	sub    $0xc,%esp
801078da:	68 4e aa 10 80       	push   $0x8010aa4e
801078df:	e8 c5 8c ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
801078e4:	8b 45 08             	mov    0x8(%ebp),%eax
801078e7:	8b 40 08             	mov    0x8(%eax),%eax
801078ea:	85 c0                	test   %eax,%eax
801078ec:	75 0d                	jne    801078fb <switchuvm+0x32>
    panic("switchuvm: no kstack");
801078ee:	83 ec 0c             	sub    $0xc,%esp
801078f1:	68 64 aa 10 80       	push   $0x8010aa64
801078f6:	e8 ae 8c ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
801078fb:	8b 45 08             	mov    0x8(%ebp),%eax
801078fe:	8b 40 04             	mov    0x4(%eax),%eax
80107901:	85 c0                	test   %eax,%eax
80107903:	75 0d                	jne    80107912 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107905:	83 ec 0c             	sub    $0xc,%esp
80107908:	68 79 aa 10 80       	push   $0x8010aa79
8010790d:	e8 97 8c ff ff       	call   801005a9 <panic>

  pushcli();
80107912:	e8 72 d3 ff ff       	call   80104c89 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107917:	e8 9c c0 ff ff       	call   801039b8 <mycpu>
8010791c:	89 c3                	mov    %eax,%ebx
8010791e:	e8 95 c0 ff ff       	call   801039b8 <mycpu>
80107923:	83 c0 08             	add    $0x8,%eax
80107926:	89 c6                	mov    %eax,%esi
80107928:	e8 8b c0 ff ff       	call   801039b8 <mycpu>
8010792d:	83 c0 08             	add    $0x8,%eax
80107930:	c1 e8 10             	shr    $0x10,%eax
80107933:	88 45 f7             	mov    %al,-0x9(%ebp)
80107936:	e8 7d c0 ff ff       	call   801039b8 <mycpu>
8010793b:	83 c0 08             	add    $0x8,%eax
8010793e:	c1 e8 18             	shr    $0x18,%eax
80107941:	89 c2                	mov    %eax,%edx
80107943:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010794a:	67 00 
8010794c:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107953:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107957:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010795d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107964:	83 e0 f0             	and    $0xfffffff0,%eax
80107967:	83 c8 09             	or     $0x9,%eax
8010796a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107970:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107977:	83 c8 10             	or     $0x10,%eax
8010797a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107980:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107987:	83 e0 9f             	and    $0xffffff9f,%eax
8010798a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107990:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107997:	83 c8 80             	or     $0xffffff80,%eax
8010799a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079a0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079a7:	83 e0 f0             	and    $0xfffffff0,%eax
801079aa:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079b0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079b7:	83 e0 ef             	and    $0xffffffef,%eax
801079ba:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079c0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079c7:	83 e0 df             	and    $0xffffffdf,%eax
801079ca:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079d0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079d7:	83 c8 40             	or     $0x40,%eax
801079da:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079e0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079e7:	83 e0 7f             	and    $0x7f,%eax
801079ea:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079f0:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801079f6:	e8 bd bf ff ff       	call   801039b8 <mycpu>
801079fb:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a02:	83 e2 ef             	and    $0xffffffef,%edx
80107a05:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a0b:	e8 a8 bf ff ff       	call   801039b8 <mycpu>
80107a10:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a16:	8b 45 08             	mov    0x8(%ebp),%eax
80107a19:	8b 40 08             	mov    0x8(%eax),%eax
80107a1c:	89 c3                	mov    %eax,%ebx
80107a1e:	e8 95 bf ff ff       	call   801039b8 <mycpu>
80107a23:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a29:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a2c:	e8 87 bf ff ff       	call   801039b8 <mycpu>
80107a31:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a37:	83 ec 0c             	sub    $0xc,%esp
80107a3a:	6a 28                	push   $0x28
80107a3c:	e8 cc f8 ff ff       	call   8010730d <ltr>
80107a41:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a44:	8b 45 08             	mov    0x8(%ebp),%eax
80107a47:	8b 40 04             	mov    0x4(%eax),%eax
80107a4a:	05 00 00 00 80       	add    $0x80000000,%eax
80107a4f:	83 ec 0c             	sub    $0xc,%esp
80107a52:	50                   	push   %eax
80107a53:	e8 cc f8 ff ff       	call   80107324 <lcr3>
80107a58:	83 c4 10             	add    $0x10,%esp
  popcli();
80107a5b:	e8 76 d2 ff ff       	call   80104cd6 <popcli>
}
80107a60:	90                   	nop
80107a61:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107a64:	5b                   	pop    %ebx
80107a65:	5e                   	pop    %esi
80107a66:	5d                   	pop    %ebp
80107a67:	c3                   	ret    

80107a68 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107a68:	55                   	push   %ebp
80107a69:	89 e5                	mov    %esp,%ebp
80107a6b:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107a6e:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107a75:	76 0d                	jbe    80107a84 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107a77:	83 ec 0c             	sub    $0xc,%esp
80107a7a:	68 8d aa 10 80       	push   $0x8010aa8d
80107a7f:	e8 25 8b ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107a84:	e8 17 ad ff ff       	call   801027a0 <kalloc>
80107a89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107a8c:	83 ec 04             	sub    $0x4,%esp
80107a8f:	68 00 10 00 00       	push   $0x1000
80107a94:	6a 00                	push   $0x0
80107a96:	ff 75 f4             	push   -0xc(%ebp)
80107a99:	e8 f6 d2 ff ff       	call   80104d94 <memset>
80107a9e:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa4:	05 00 00 00 80       	add    $0x80000000,%eax
80107aa9:	83 ec 0c             	sub    $0xc,%esp
80107aac:	6a 06                	push   $0x6
80107aae:	50                   	push   %eax
80107aaf:	68 00 10 00 00       	push   $0x1000
80107ab4:	6a 00                	push   $0x0
80107ab6:	ff 75 08             	push   0x8(%ebp)
80107ab9:	e8 5e fc ff ff       	call   8010771c <mappages>
80107abe:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107ac1:	83 ec 04             	sub    $0x4,%esp
80107ac4:	ff 75 10             	push   0x10(%ebp)
80107ac7:	ff 75 0c             	push   0xc(%ebp)
80107aca:	ff 75 f4             	push   -0xc(%ebp)
80107acd:	e8 81 d3 ff ff       	call   80104e53 <memmove>
80107ad2:	83 c4 10             	add    $0x10,%esp
}
80107ad5:	90                   	nop
80107ad6:	c9                   	leave  
80107ad7:	c3                   	ret    

80107ad8 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107ad8:	55                   	push   %ebp
80107ad9:	89 e5                	mov    %esp,%ebp
80107adb:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107ade:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ae1:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ae6:	85 c0                	test   %eax,%eax
80107ae8:	74 0d                	je     80107af7 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107aea:	83 ec 0c             	sub    $0xc,%esp
80107aed:	68 a8 aa 10 80       	push   $0x8010aaa8
80107af2:	e8 b2 8a ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107af7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107afe:	e9 8f 00 00 00       	jmp    80107b92 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b03:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b09:	01 d0                	add    %edx,%eax
80107b0b:	83 ec 04             	sub    $0x4,%esp
80107b0e:	6a 00                	push   $0x0
80107b10:	50                   	push   %eax
80107b11:	ff 75 08             	push   0x8(%ebp)
80107b14:	e8 6d fb ff ff       	call   80107686 <walkpgdir>
80107b19:	83 c4 10             	add    $0x10,%esp
80107b1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b1f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b23:	75 0d                	jne    80107b32 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107b25:	83 ec 0c             	sub    $0xc,%esp
80107b28:	68 cb aa 10 80       	push   $0x8010aacb
80107b2d:	e8 77 8a ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107b32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b35:	8b 00                	mov    (%eax),%eax
80107b37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b3f:	8b 45 18             	mov    0x18(%ebp),%eax
80107b42:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b45:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b4a:	77 0b                	ja     80107b57 <loaduvm+0x7f>
      n = sz - i;
80107b4c:	8b 45 18             	mov    0x18(%ebp),%eax
80107b4f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b52:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b55:	eb 07                	jmp    80107b5e <loaduvm+0x86>
    else
      n = PGSIZE;
80107b57:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107b5e:	8b 55 14             	mov    0x14(%ebp),%edx
80107b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b64:	01 d0                	add    %edx,%eax
80107b66:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107b69:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107b6f:	ff 75 f0             	push   -0x10(%ebp)
80107b72:	50                   	push   %eax
80107b73:	52                   	push   %edx
80107b74:	ff 75 10             	push   0x10(%ebp)
80107b77:	e8 5a a3 ff ff       	call   80101ed6 <readi>
80107b7c:	83 c4 10             	add    $0x10,%esp
80107b7f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107b82:	74 07                	je     80107b8b <loaduvm+0xb3>
      return -1;
80107b84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b89:	eb 18                	jmp    80107ba3 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107b8b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b95:	3b 45 18             	cmp    0x18(%ebp),%eax
80107b98:	0f 82 65 ff ff ff    	jb     80107b03 <loaduvm+0x2b>
  }
  return 0;
80107b9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ba3:	c9                   	leave  
80107ba4:	c3                   	ret    

80107ba5 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ba5:	55                   	push   %ebp
80107ba6:	89 e5                	mov    %esp,%ebp
80107ba8:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107bab:	8b 45 10             	mov    0x10(%ebp),%eax
80107bae:	85 c0                	test   %eax,%eax
80107bb0:	79 0a                	jns    80107bbc <allocuvm+0x17>
    return 0;
80107bb2:	b8 00 00 00 00       	mov    $0x0,%eax
80107bb7:	e9 ec 00 00 00       	jmp    80107ca8 <allocuvm+0x103>
  if(newsz < oldsz)
80107bbc:	8b 45 10             	mov    0x10(%ebp),%eax
80107bbf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107bc2:	73 08                	jae    80107bcc <allocuvm+0x27>
    return oldsz;
80107bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bc7:	e9 dc 00 00 00       	jmp    80107ca8 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bcf:	05 ff 0f 00 00       	add    $0xfff,%eax
80107bd4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107bdc:	e9 b8 00 00 00       	jmp    80107c99 <allocuvm+0xf4>
    mem = kalloc();
80107be1:	e8 ba ab ff ff       	call   801027a0 <kalloc>
80107be6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107be9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bed:	75 2e                	jne    80107c1d <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107bef:	83 ec 0c             	sub    $0xc,%esp
80107bf2:	68 e9 aa 10 80       	push   $0x8010aae9
80107bf7:	e8 f8 87 ff ff       	call   801003f4 <cprintf>
80107bfc:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107bff:	83 ec 04             	sub    $0x4,%esp
80107c02:	ff 75 0c             	push   0xc(%ebp)
80107c05:	ff 75 10             	push   0x10(%ebp)
80107c08:	ff 75 08             	push   0x8(%ebp)
80107c0b:	e8 9a 00 00 00       	call   80107caa <deallocuvm>
80107c10:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c13:	b8 00 00 00 00       	mov    $0x0,%eax
80107c18:	e9 8b 00 00 00       	jmp    80107ca8 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107c1d:	83 ec 04             	sub    $0x4,%esp
80107c20:	68 00 10 00 00       	push   $0x1000
80107c25:	6a 00                	push   $0x0
80107c27:	ff 75 f0             	push   -0x10(%ebp)
80107c2a:	e8 65 d1 ff ff       	call   80104d94 <memset>
80107c2f:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c35:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3e:	83 ec 0c             	sub    $0xc,%esp
80107c41:	6a 06                	push   $0x6
80107c43:	52                   	push   %edx
80107c44:	68 00 10 00 00       	push   $0x1000
80107c49:	50                   	push   %eax
80107c4a:	ff 75 08             	push   0x8(%ebp)
80107c4d:	e8 ca fa ff ff       	call   8010771c <mappages>
80107c52:	83 c4 20             	add    $0x20,%esp
80107c55:	85 c0                	test   %eax,%eax
80107c57:	79 39                	jns    80107c92 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107c59:	83 ec 0c             	sub    $0xc,%esp
80107c5c:	68 01 ab 10 80       	push   $0x8010ab01
80107c61:	e8 8e 87 ff ff       	call   801003f4 <cprintf>
80107c66:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c69:	83 ec 04             	sub    $0x4,%esp
80107c6c:	ff 75 0c             	push   0xc(%ebp)
80107c6f:	ff 75 10             	push   0x10(%ebp)
80107c72:	ff 75 08             	push   0x8(%ebp)
80107c75:	e8 30 00 00 00       	call   80107caa <deallocuvm>
80107c7a:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107c7d:	83 ec 0c             	sub    $0xc,%esp
80107c80:	ff 75 f0             	push   -0x10(%ebp)
80107c83:	e8 7e aa ff ff       	call   80102706 <kfree>
80107c88:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c8b:	b8 00 00 00 00       	mov    $0x0,%eax
80107c90:	eb 16                	jmp    80107ca8 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107c92:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9c:	3b 45 10             	cmp    0x10(%ebp),%eax
80107c9f:	0f 82 3c ff ff ff    	jb     80107be1 <allocuvm+0x3c>
    }
  }
  return newsz;
80107ca5:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ca8:	c9                   	leave  
80107ca9:	c3                   	ret    

80107caa <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107caa:	55                   	push   %ebp
80107cab:	89 e5                	mov    %esp,%ebp
80107cad:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107cb0:	8b 45 10             	mov    0x10(%ebp),%eax
80107cb3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107cb6:	72 08                	jb     80107cc0 <deallocuvm+0x16>
    return oldsz;
80107cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cbb:	e9 ac 00 00 00       	jmp    80107d6c <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107cc0:	8b 45 10             	mov    0x10(%ebp),%eax
80107cc3:	05 ff 0f 00 00       	add    $0xfff,%eax
80107cc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ccd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107cd0:	e9 88 00 00 00       	jmp    80107d5d <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd8:	83 ec 04             	sub    $0x4,%esp
80107cdb:	6a 00                	push   $0x0
80107cdd:	50                   	push   %eax
80107cde:	ff 75 08             	push   0x8(%ebp)
80107ce1:	e8 a0 f9 ff ff       	call   80107686 <walkpgdir>
80107ce6:	83 c4 10             	add    $0x10,%esp
80107ce9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107cec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cf0:	75 16                	jne    80107d08 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf5:	c1 e8 16             	shr    $0x16,%eax
80107cf8:	83 c0 01             	add    $0x1,%eax
80107cfb:	c1 e0 16             	shl    $0x16,%eax
80107cfe:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d06:	eb 4e                	jmp    80107d56 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107d08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d0b:	8b 00                	mov    (%eax),%eax
80107d0d:	83 e0 01             	and    $0x1,%eax
80107d10:	85 c0                	test   %eax,%eax
80107d12:	74 42                	je     80107d56 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d17:	8b 00                	mov    (%eax),%eax
80107d19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d21:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d25:	75 0d                	jne    80107d34 <deallocuvm+0x8a>
        panic("kfree");
80107d27:	83 ec 0c             	sub    $0xc,%esp
80107d2a:	68 1d ab 10 80       	push   $0x8010ab1d
80107d2f:	e8 75 88 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107d34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d37:	05 00 00 00 80       	add    $0x80000000,%eax
80107d3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107d3f:	83 ec 0c             	sub    $0xc,%esp
80107d42:	ff 75 e8             	push   -0x18(%ebp)
80107d45:	e8 bc a9 ff ff       	call   80102706 <kfree>
80107d4a:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d50:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107d56:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d60:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d63:	0f 82 6c ff ff ff    	jb     80107cd5 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107d69:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d6c:	c9                   	leave  
80107d6d:	c3                   	ret    

80107d6e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107d6e:	55                   	push   %ebp
80107d6f:	89 e5                	mov    %esp,%ebp
80107d71:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107d74:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d78:	75 0d                	jne    80107d87 <freevm+0x19>
    panic("freevm: no pgdir");
80107d7a:	83 ec 0c             	sub    $0xc,%esp
80107d7d:	68 23 ab 10 80       	push   $0x8010ab23
80107d82:	e8 22 88 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107d87:	83 ec 04             	sub    $0x4,%esp
80107d8a:	6a 00                	push   $0x0
80107d8c:	68 00 00 00 80       	push   $0x80000000
80107d91:	ff 75 08             	push   0x8(%ebp)
80107d94:	e8 11 ff ff ff       	call   80107caa <deallocuvm>
80107d99:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107d9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107da3:	eb 48                	jmp    80107ded <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107daf:	8b 45 08             	mov    0x8(%ebp),%eax
80107db2:	01 d0                	add    %edx,%eax
80107db4:	8b 00                	mov    (%eax),%eax
80107db6:	83 e0 01             	and    $0x1,%eax
80107db9:	85 c0                	test   %eax,%eax
80107dbb:	74 2c                	je     80107de9 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80107dca:	01 d0                	add    %edx,%eax
80107dcc:	8b 00                	mov    (%eax),%eax
80107dce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dd3:	05 00 00 00 80       	add    $0x80000000,%eax
80107dd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107ddb:	83 ec 0c             	sub    $0xc,%esp
80107dde:	ff 75 f0             	push   -0x10(%ebp)
80107de1:	e8 20 a9 ff ff       	call   80102706 <kfree>
80107de6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107de9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107ded:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107df4:	76 af                	jbe    80107da5 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107df6:	83 ec 0c             	sub    $0xc,%esp
80107df9:	ff 75 08             	push   0x8(%ebp)
80107dfc:	e8 05 a9 ff ff       	call   80102706 <kfree>
80107e01:	83 c4 10             	add    $0x10,%esp
}
80107e04:	90                   	nop
80107e05:	c9                   	leave  
80107e06:	c3                   	ret    

80107e07 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e07:	55                   	push   %ebp
80107e08:	89 e5                	mov    %esp,%ebp
80107e0a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e0d:	83 ec 04             	sub    $0x4,%esp
80107e10:	6a 00                	push   $0x0
80107e12:	ff 75 0c             	push   0xc(%ebp)
80107e15:	ff 75 08             	push   0x8(%ebp)
80107e18:	e8 69 f8 ff ff       	call   80107686 <walkpgdir>
80107e1d:	83 c4 10             	add    $0x10,%esp
80107e20:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e27:	75 0d                	jne    80107e36 <clearpteu+0x2f>
    panic("clearpteu");
80107e29:	83 ec 0c             	sub    $0xc,%esp
80107e2c:	68 34 ab 10 80       	push   $0x8010ab34
80107e31:	e8 73 87 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e39:	8b 00                	mov    (%eax),%eax
80107e3b:	83 e0 fb             	and    $0xfffffffb,%eax
80107e3e:	89 c2                	mov    %eax,%edx
80107e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e43:	89 10                	mov    %edx,(%eax)
}
80107e45:	90                   	nop
80107e46:	c9                   	leave  
80107e47:	c3                   	ret    

80107e48 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e48:	55                   	push   %ebp
80107e49:	89 e5                	mov    %esp,%ebp
80107e4b:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107e4e:	e8 59 f9 ff ff       	call   801077ac <setupkvm>
80107e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e5a:	75 0a                	jne    80107e66 <copyuvm+0x1e>
    return 0;
80107e5c:	b8 00 00 00 00       	mov    $0x0,%eax
80107e61:	e9 eb 00 00 00       	jmp    80107f51 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107e66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e6d:	e9 b7 00 00 00       	jmp    80107f29 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e75:	83 ec 04             	sub    $0x4,%esp
80107e78:	6a 00                	push   $0x0
80107e7a:	50                   	push   %eax
80107e7b:	ff 75 08             	push   0x8(%ebp)
80107e7e:	e8 03 f8 ff ff       	call   80107686 <walkpgdir>
80107e83:	83 c4 10             	add    $0x10,%esp
80107e86:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e89:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e8d:	75 0d                	jne    80107e9c <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107e8f:	83 ec 0c             	sub    $0xc,%esp
80107e92:	68 3e ab 10 80       	push   $0x8010ab3e
80107e97:	e8 0d 87 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107e9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e9f:	8b 00                	mov    (%eax),%eax
80107ea1:	83 e0 01             	and    $0x1,%eax
80107ea4:	85 c0                	test   %eax,%eax
80107ea6:	75 0d                	jne    80107eb5 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107ea8:	83 ec 0c             	sub    $0xc,%esp
80107eab:	68 58 ab 10 80       	push   $0x8010ab58
80107eb0:	e8 f4 86 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eb8:	8b 00                	mov    (%eax),%eax
80107eba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ebf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec5:	8b 00                	mov    (%eax),%eax
80107ec7:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ecc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107ecf:	e8 cc a8 ff ff       	call   801027a0 <kalloc>
80107ed4:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ed7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107edb:	74 5d                	je     80107f3a <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107edd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ee0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ee5:	83 ec 04             	sub    $0x4,%esp
80107ee8:	68 00 10 00 00       	push   $0x1000
80107eed:	50                   	push   %eax
80107eee:	ff 75 e0             	push   -0x20(%ebp)
80107ef1:	e8 5d cf ff ff       	call   80104e53 <memmove>
80107ef6:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107ef9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107efc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107eff:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	83 ec 0c             	sub    $0xc,%esp
80107f0b:	52                   	push   %edx
80107f0c:	51                   	push   %ecx
80107f0d:	68 00 10 00 00       	push   $0x1000
80107f12:	50                   	push   %eax
80107f13:	ff 75 f0             	push   -0x10(%ebp)
80107f16:	e8 01 f8 ff ff       	call   8010771c <mappages>
80107f1b:	83 c4 20             	add    $0x20,%esp
80107f1e:	85 c0                	test   %eax,%eax
80107f20:	78 1b                	js     80107f3d <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107f22:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f2f:	0f 82 3d ff ff ff    	jb     80107e72 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f38:	eb 17                	jmp    80107f51 <copyuvm+0x109>
      goto bad;
80107f3a:	90                   	nop
80107f3b:	eb 01                	jmp    80107f3e <copyuvm+0xf6>
      goto bad;
80107f3d:	90                   	nop

bad:
  freevm(d);
80107f3e:	83 ec 0c             	sub    $0xc,%esp
80107f41:	ff 75 f0             	push   -0x10(%ebp)
80107f44:	e8 25 fe ff ff       	call   80107d6e <freevm>
80107f49:	83 c4 10             	add    $0x10,%esp
  return 0;
80107f4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f51:	c9                   	leave  
80107f52:	c3                   	ret    

80107f53 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107f53:	55                   	push   %ebp
80107f54:	89 e5                	mov    %esp,%ebp
80107f56:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f59:	83 ec 04             	sub    $0x4,%esp
80107f5c:	6a 00                	push   $0x0
80107f5e:	ff 75 0c             	push   0xc(%ebp)
80107f61:	ff 75 08             	push   0x8(%ebp)
80107f64:	e8 1d f7 ff ff       	call   80107686 <walkpgdir>
80107f69:	83 c4 10             	add    $0x10,%esp
80107f6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f72:	8b 00                	mov    (%eax),%eax
80107f74:	83 e0 01             	and    $0x1,%eax
80107f77:	85 c0                	test   %eax,%eax
80107f79:	75 07                	jne    80107f82 <uva2ka+0x2f>
    return 0;
80107f7b:	b8 00 00 00 00       	mov    $0x0,%eax
80107f80:	eb 22                	jmp    80107fa4 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f85:	8b 00                	mov    (%eax),%eax
80107f87:	83 e0 04             	and    $0x4,%eax
80107f8a:	85 c0                	test   %eax,%eax
80107f8c:	75 07                	jne    80107f95 <uva2ka+0x42>
    return 0;
80107f8e:	b8 00 00 00 00       	mov    $0x0,%eax
80107f93:	eb 0f                	jmp    80107fa4 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f98:	8b 00                	mov    (%eax),%eax
80107f9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f9f:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107fa4:	c9                   	leave  
80107fa5:	c3                   	ret    

80107fa6 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107fa6:	55                   	push   %ebp
80107fa7:	89 e5                	mov    %esp,%ebp
80107fa9:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107fac:	8b 45 10             	mov    0x10(%ebp),%eax
80107faf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107fb2:	eb 7f                	jmp    80108033 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fb7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107fbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fc2:	83 ec 08             	sub    $0x8,%esp
80107fc5:	50                   	push   %eax
80107fc6:	ff 75 08             	push   0x8(%ebp)
80107fc9:	e8 85 ff ff ff       	call   80107f53 <uva2ka>
80107fce:	83 c4 10             	add    $0x10,%esp
80107fd1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107fd4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107fd8:	75 07                	jne    80107fe1 <copyout+0x3b>
      return -1;
80107fda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fdf:	eb 61                	jmp    80108042 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107fe1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fe4:	2b 45 0c             	sub    0xc(%ebp),%eax
80107fe7:	05 00 10 00 00       	add    $0x1000,%eax
80107fec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ff2:	3b 45 14             	cmp    0x14(%ebp),%eax
80107ff5:	76 06                	jbe    80107ffd <copyout+0x57>
      n = len;
80107ff7:	8b 45 14             	mov    0x14(%ebp),%eax
80107ffa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107ffd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108000:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108003:	89 c2                	mov    %eax,%edx
80108005:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108008:	01 d0                	add    %edx,%eax
8010800a:	83 ec 04             	sub    $0x4,%esp
8010800d:	ff 75 f0             	push   -0x10(%ebp)
80108010:	ff 75 f4             	push   -0xc(%ebp)
80108013:	50                   	push   %eax
80108014:	e8 3a ce ff ff       	call   80104e53 <memmove>
80108019:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010801c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010801f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108022:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108025:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010802b:	05 00 10 00 00       	add    $0x1000,%eax
80108030:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108033:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108037:	0f 85 77 ff ff ff    	jne    80107fb4 <copyout+0xe>
  }
  return 0;
8010803d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108042:	c9                   	leave  
80108043:	c3                   	ret    

80108044 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108044:	55                   	push   %ebp
80108045:	89 e5                	mov    %esp,%ebp
80108047:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010804a:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108051:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108054:	8b 40 08             	mov    0x8(%eax),%eax
80108057:	05 00 00 00 80       	add    $0x80000000,%eax
8010805c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010805f:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108069:	8b 40 24             	mov    0x24(%eax),%eax
8010806c:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80108071:	c7 05 50 75 19 80 00 	movl   $0x0,0x80197550
80108078:	00 00 00 

  while(i<madt->len){
8010807b:	90                   	nop
8010807c:	e9 bd 00 00 00       	jmp    8010813e <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108081:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108084:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108087:	01 d0                	add    %edx,%eax
80108089:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010808c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010808f:	0f b6 00             	movzbl (%eax),%eax
80108092:	0f b6 c0             	movzbl %al,%eax
80108095:	83 f8 05             	cmp    $0x5,%eax
80108098:	0f 87 a0 00 00 00    	ja     8010813e <mpinit_uefi+0xfa>
8010809e:	8b 04 85 74 ab 10 80 	mov    -0x7fef548c(,%eax,4),%eax
801080a5:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801080a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801080ad:	a1 50 75 19 80       	mov    0x80197550,%eax
801080b2:	83 f8 03             	cmp    $0x3,%eax
801080b5:	7f 28                	jg     801080df <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801080b7:	8b 15 50 75 19 80    	mov    0x80197550,%edx
801080bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080c0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801080c4:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801080ca:	81 c2 80 72 19 80    	add    $0x80197280,%edx
801080d0:	88 02                	mov    %al,(%edx)
          ncpu++;
801080d2:	a1 50 75 19 80       	mov    0x80197550,%eax
801080d7:	83 c0 01             	add    $0x1,%eax
801080da:	a3 50 75 19 80       	mov    %eax,0x80197550
        }
        i += lapic_entry->record_len;
801080df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080e2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801080e6:	0f b6 c0             	movzbl %al,%eax
801080e9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801080ec:	eb 50                	jmp    8010813e <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801080ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801080f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801080f7:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801080fb:	a2 54 75 19 80       	mov    %al,0x80197554
        i += ioapic->record_len;
80108100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108103:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108107:	0f b6 c0             	movzbl %al,%eax
8010810a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010810d:	eb 2f                	jmp    8010813e <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010810f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108112:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108115:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108118:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010811c:	0f b6 c0             	movzbl %al,%eax
8010811f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108122:	eb 1a                	jmp    8010813e <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108127:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010812a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010812d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108131:	0f b6 c0             	movzbl %al,%eax
80108134:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108137:	eb 05                	jmp    8010813e <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80108139:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010813d:	90                   	nop
  while(i<madt->len){
8010813e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108141:	8b 40 04             	mov    0x4(%eax),%eax
80108144:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108147:	0f 82 34 ff ff ff    	jb     80108081 <mpinit_uefi+0x3d>
    }
  }

}
8010814d:	90                   	nop
8010814e:	90                   	nop
8010814f:	c9                   	leave  
80108150:	c3                   	ret    

80108151 <inb>:
{
80108151:	55                   	push   %ebp
80108152:	89 e5                	mov    %esp,%ebp
80108154:	83 ec 14             	sub    $0x14,%esp
80108157:	8b 45 08             	mov    0x8(%ebp),%eax
8010815a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010815e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108162:	89 c2                	mov    %eax,%edx
80108164:	ec                   	in     (%dx),%al
80108165:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108168:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010816c:	c9                   	leave  
8010816d:	c3                   	ret    

8010816e <outb>:
{
8010816e:	55                   	push   %ebp
8010816f:	89 e5                	mov    %esp,%ebp
80108171:	83 ec 08             	sub    $0x8,%esp
80108174:	8b 45 08             	mov    0x8(%ebp),%eax
80108177:	8b 55 0c             	mov    0xc(%ebp),%edx
8010817a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010817e:	89 d0                	mov    %edx,%eax
80108180:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108183:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108187:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010818b:	ee                   	out    %al,(%dx)
}
8010818c:	90                   	nop
8010818d:	c9                   	leave  
8010818e:	c3                   	ret    

8010818f <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010818f:	55                   	push   %ebp
80108190:	89 e5                	mov    %esp,%ebp
80108192:	83 ec 28             	sub    $0x28,%esp
80108195:	8b 45 08             	mov    0x8(%ebp),%eax
80108198:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010819b:	6a 00                	push   $0x0
8010819d:	68 fa 03 00 00       	push   $0x3fa
801081a2:	e8 c7 ff ff ff       	call   8010816e <outb>
801081a7:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801081aa:	68 80 00 00 00       	push   $0x80
801081af:	68 fb 03 00 00       	push   $0x3fb
801081b4:	e8 b5 ff ff ff       	call   8010816e <outb>
801081b9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801081bc:	6a 0c                	push   $0xc
801081be:	68 f8 03 00 00       	push   $0x3f8
801081c3:	e8 a6 ff ff ff       	call   8010816e <outb>
801081c8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801081cb:	6a 00                	push   $0x0
801081cd:	68 f9 03 00 00       	push   $0x3f9
801081d2:	e8 97 ff ff ff       	call   8010816e <outb>
801081d7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801081da:	6a 03                	push   $0x3
801081dc:	68 fb 03 00 00       	push   $0x3fb
801081e1:	e8 88 ff ff ff       	call   8010816e <outb>
801081e6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801081e9:	6a 00                	push   $0x0
801081eb:	68 fc 03 00 00       	push   $0x3fc
801081f0:	e8 79 ff ff ff       	call   8010816e <outb>
801081f5:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801081f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081ff:	eb 11                	jmp    80108212 <uart_debug+0x83>
80108201:	83 ec 0c             	sub    $0xc,%esp
80108204:	6a 0a                	push   $0xa
80108206:	e8 2c a9 ff ff       	call   80102b37 <microdelay>
8010820b:	83 c4 10             	add    $0x10,%esp
8010820e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108212:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108216:	7f 1a                	jg     80108232 <uart_debug+0xa3>
80108218:	83 ec 0c             	sub    $0xc,%esp
8010821b:	68 fd 03 00 00       	push   $0x3fd
80108220:	e8 2c ff ff ff       	call   80108151 <inb>
80108225:	83 c4 10             	add    $0x10,%esp
80108228:	0f b6 c0             	movzbl %al,%eax
8010822b:	83 e0 20             	and    $0x20,%eax
8010822e:	85 c0                	test   %eax,%eax
80108230:	74 cf                	je     80108201 <uart_debug+0x72>
  outb(COM1+0, p);
80108232:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108236:	0f b6 c0             	movzbl %al,%eax
80108239:	83 ec 08             	sub    $0x8,%esp
8010823c:	50                   	push   %eax
8010823d:	68 f8 03 00 00       	push   $0x3f8
80108242:	e8 27 ff ff ff       	call   8010816e <outb>
80108247:	83 c4 10             	add    $0x10,%esp
}
8010824a:	90                   	nop
8010824b:	c9                   	leave  
8010824c:	c3                   	ret    

8010824d <uart_debugs>:

void uart_debugs(char *p){
8010824d:	55                   	push   %ebp
8010824e:	89 e5                	mov    %esp,%ebp
80108250:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108253:	eb 1b                	jmp    80108270 <uart_debugs+0x23>
    uart_debug(*p++);
80108255:	8b 45 08             	mov    0x8(%ebp),%eax
80108258:	8d 50 01             	lea    0x1(%eax),%edx
8010825b:	89 55 08             	mov    %edx,0x8(%ebp)
8010825e:	0f b6 00             	movzbl (%eax),%eax
80108261:	0f be c0             	movsbl %al,%eax
80108264:	83 ec 0c             	sub    $0xc,%esp
80108267:	50                   	push   %eax
80108268:	e8 22 ff ff ff       	call   8010818f <uart_debug>
8010826d:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108270:	8b 45 08             	mov    0x8(%ebp),%eax
80108273:	0f b6 00             	movzbl (%eax),%eax
80108276:	84 c0                	test   %al,%al
80108278:	75 db                	jne    80108255 <uart_debugs+0x8>
  }
}
8010827a:	90                   	nop
8010827b:	90                   	nop
8010827c:	c9                   	leave  
8010827d:	c3                   	ret    

8010827e <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010827e:	55                   	push   %ebp
8010827f:	89 e5                	mov    %esp,%ebp
80108281:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108284:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010828b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010828e:	8b 50 14             	mov    0x14(%eax),%edx
80108291:	8b 40 10             	mov    0x10(%eax),%eax
80108294:	a3 58 75 19 80       	mov    %eax,0x80197558
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108299:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010829c:	8b 50 1c             	mov    0x1c(%eax),%edx
8010829f:	8b 40 18             	mov    0x18(%eax),%eax
801082a2:	a3 60 75 19 80       	mov    %eax,0x80197560
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801082a7:	8b 15 60 75 19 80    	mov    0x80197560,%edx
801082ad:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801082b2:	29 d0                	sub    %edx,%eax
801082b4:	a3 5c 75 19 80       	mov    %eax,0x8019755c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801082b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082bc:	8b 50 24             	mov    0x24(%eax),%edx
801082bf:	8b 40 20             	mov    0x20(%eax),%eax
801082c2:	a3 64 75 19 80       	mov    %eax,0x80197564
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801082c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082ca:	8b 50 2c             	mov    0x2c(%eax),%edx
801082cd:	8b 40 28             	mov    0x28(%eax),%eax
801082d0:	a3 68 75 19 80       	mov    %eax,0x80197568
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801082d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082d8:	8b 50 34             	mov    0x34(%eax),%edx
801082db:	8b 40 30             	mov    0x30(%eax),%eax
801082de:	a3 6c 75 19 80       	mov    %eax,0x8019756c
}
801082e3:	90                   	nop
801082e4:	c9                   	leave  
801082e5:	c3                   	ret    

801082e6 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801082e6:	55                   	push   %ebp
801082e7:	89 e5                	mov    %esp,%ebp
801082e9:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801082ec:	8b 15 6c 75 19 80    	mov    0x8019756c,%edx
801082f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801082f5:	0f af d0             	imul   %eax,%edx
801082f8:	8b 45 08             	mov    0x8(%ebp),%eax
801082fb:	01 d0                	add    %edx,%eax
801082fd:	c1 e0 02             	shl    $0x2,%eax
80108300:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108303:	8b 15 5c 75 19 80    	mov    0x8019755c,%edx
80108309:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010830c:	01 d0                	add    %edx,%eax
8010830e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108311:	8b 45 10             	mov    0x10(%ebp),%eax
80108314:	0f b6 10             	movzbl (%eax),%edx
80108317:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010831a:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010831c:	8b 45 10             	mov    0x10(%ebp),%eax
8010831f:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108323:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108326:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108329:	8b 45 10             	mov    0x10(%ebp),%eax
8010832c:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108330:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108333:	88 50 02             	mov    %dl,0x2(%eax)
}
80108336:	90                   	nop
80108337:	c9                   	leave  
80108338:	c3                   	ret    

80108339 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108339:	55                   	push   %ebp
8010833a:	89 e5                	mov    %esp,%ebp
8010833c:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
8010833f:	8b 15 6c 75 19 80    	mov    0x8019756c,%edx
80108345:	8b 45 08             	mov    0x8(%ebp),%eax
80108348:	0f af c2             	imul   %edx,%eax
8010834b:	c1 e0 02             	shl    $0x2,%eax
8010834e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108351:	a1 60 75 19 80       	mov    0x80197560,%eax
80108356:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108359:	29 d0                	sub    %edx,%eax
8010835b:	8b 0d 5c 75 19 80    	mov    0x8019755c,%ecx
80108361:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108364:	01 ca                	add    %ecx,%edx
80108366:	89 d1                	mov    %edx,%ecx
80108368:	8b 15 5c 75 19 80    	mov    0x8019755c,%edx
8010836e:	83 ec 04             	sub    $0x4,%esp
80108371:	50                   	push   %eax
80108372:	51                   	push   %ecx
80108373:	52                   	push   %edx
80108374:	e8 da ca ff ff       	call   80104e53 <memmove>
80108379:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
8010837c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837f:	8b 0d 5c 75 19 80    	mov    0x8019755c,%ecx
80108385:	8b 15 60 75 19 80    	mov    0x80197560,%edx
8010838b:	01 ca                	add    %ecx,%edx
8010838d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108390:	29 ca                	sub    %ecx,%edx
80108392:	83 ec 04             	sub    $0x4,%esp
80108395:	50                   	push   %eax
80108396:	6a 00                	push   $0x0
80108398:	52                   	push   %edx
80108399:	e8 f6 c9 ff ff       	call   80104d94 <memset>
8010839e:	83 c4 10             	add    $0x10,%esp
}
801083a1:	90                   	nop
801083a2:	c9                   	leave  
801083a3:	c3                   	ret    

801083a4 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801083a4:	55                   	push   %ebp
801083a5:	89 e5                	mov    %esp,%ebp
801083a7:	53                   	push   %ebx
801083a8:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801083ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083b2:	e9 b1 00 00 00       	jmp    80108468 <font_render+0xc4>
    for(int j=14;j>-1;j--){
801083b7:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801083be:	e9 97 00 00 00       	jmp    8010845a <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801083c3:	8b 45 10             	mov    0x10(%ebp),%eax
801083c6:	83 e8 20             	sub    $0x20,%eax
801083c9:	6b d0 1e             	imul   $0x1e,%eax,%edx
801083cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cf:	01 d0                	add    %edx,%eax
801083d1:	0f b7 84 00 a0 ab 10 	movzwl -0x7fef5460(%eax,%eax,1),%eax
801083d8:	80 
801083d9:	0f b7 d0             	movzwl %ax,%edx
801083dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083df:	bb 01 00 00 00       	mov    $0x1,%ebx
801083e4:	89 c1                	mov    %eax,%ecx
801083e6:	d3 e3                	shl    %cl,%ebx
801083e8:	89 d8                	mov    %ebx,%eax
801083ea:	21 d0                	and    %edx,%eax
801083ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801083ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f2:	ba 01 00 00 00       	mov    $0x1,%edx
801083f7:	89 c1                	mov    %eax,%ecx
801083f9:	d3 e2                	shl    %cl,%edx
801083fb:	89 d0                	mov    %edx,%eax
801083fd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108400:	75 2b                	jne    8010842d <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108402:	8b 55 0c             	mov    0xc(%ebp),%edx
80108405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108408:	01 c2                	add    %eax,%edx
8010840a:	b8 0e 00 00 00       	mov    $0xe,%eax
8010840f:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108412:	89 c1                	mov    %eax,%ecx
80108414:	8b 45 08             	mov    0x8(%ebp),%eax
80108417:	01 c8                	add    %ecx,%eax
80108419:	83 ec 04             	sub    $0x4,%esp
8010841c:	68 e0 f4 10 80       	push   $0x8010f4e0
80108421:	52                   	push   %edx
80108422:	50                   	push   %eax
80108423:	e8 be fe ff ff       	call   801082e6 <graphic_draw_pixel>
80108428:	83 c4 10             	add    $0x10,%esp
8010842b:	eb 29                	jmp    80108456 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010842d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108433:	01 c2                	add    %eax,%edx
80108435:	b8 0e 00 00 00       	mov    $0xe,%eax
8010843a:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010843d:	89 c1                	mov    %eax,%ecx
8010843f:	8b 45 08             	mov    0x8(%ebp),%eax
80108442:	01 c8                	add    %ecx,%eax
80108444:	83 ec 04             	sub    $0x4,%esp
80108447:	68 70 75 19 80       	push   $0x80197570
8010844c:	52                   	push   %edx
8010844d:	50                   	push   %eax
8010844e:	e8 93 fe ff ff       	call   801082e6 <graphic_draw_pixel>
80108453:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108456:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010845a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010845e:	0f 89 5f ff ff ff    	jns    801083c3 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108464:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108468:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010846c:	0f 8e 45 ff ff ff    	jle    801083b7 <font_render+0x13>
      }
    }
  }
}
80108472:	90                   	nop
80108473:	90                   	nop
80108474:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108477:	c9                   	leave  
80108478:	c3                   	ret    

80108479 <font_render_string>:

void font_render_string(char *string,int row){
80108479:	55                   	push   %ebp
8010847a:	89 e5                	mov    %esp,%ebp
8010847c:	53                   	push   %ebx
8010847d:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108480:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108487:	eb 33                	jmp    801084bc <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108489:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010848c:	8b 45 08             	mov    0x8(%ebp),%eax
8010848f:	01 d0                	add    %edx,%eax
80108491:	0f b6 00             	movzbl (%eax),%eax
80108494:	0f be c8             	movsbl %al,%ecx
80108497:	8b 45 0c             	mov    0xc(%ebp),%eax
8010849a:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010849d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801084a0:	89 d8                	mov    %ebx,%eax
801084a2:	c1 e0 04             	shl    $0x4,%eax
801084a5:	29 d8                	sub    %ebx,%eax
801084a7:	83 c0 02             	add    $0x2,%eax
801084aa:	83 ec 04             	sub    $0x4,%esp
801084ad:	51                   	push   %ecx
801084ae:	52                   	push   %edx
801084af:	50                   	push   %eax
801084b0:	e8 ef fe ff ff       	call   801083a4 <font_render>
801084b5:	83 c4 10             	add    $0x10,%esp
    i++;
801084b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801084bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084bf:	8b 45 08             	mov    0x8(%ebp),%eax
801084c2:	01 d0                	add    %edx,%eax
801084c4:	0f b6 00             	movzbl (%eax),%eax
801084c7:	84 c0                	test   %al,%al
801084c9:	74 06                	je     801084d1 <font_render_string+0x58>
801084cb:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801084cf:	7e b8                	jle    80108489 <font_render_string+0x10>
  }
}
801084d1:	90                   	nop
801084d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084d5:	c9                   	leave  
801084d6:	c3                   	ret    

801084d7 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801084d7:	55                   	push   %ebp
801084d8:	89 e5                	mov    %esp,%ebp
801084da:	53                   	push   %ebx
801084db:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801084de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084e5:	eb 6b                	jmp    80108552 <pci_init+0x7b>
    for(int j=0;j<32;j++){
801084e7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801084ee:	eb 58                	jmp    80108548 <pci_init+0x71>
      for(int k=0;k<8;k++){
801084f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801084f7:	eb 45                	jmp    8010853e <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801084f9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801084fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801084ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108502:	83 ec 0c             	sub    $0xc,%esp
80108505:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108508:	53                   	push   %ebx
80108509:	6a 00                	push   $0x0
8010850b:	51                   	push   %ecx
8010850c:	52                   	push   %edx
8010850d:	50                   	push   %eax
8010850e:	e8 b0 00 00 00       	call   801085c3 <pci_access_config>
80108513:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108516:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108519:	0f b7 c0             	movzwl %ax,%eax
8010851c:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108521:	74 17                	je     8010853a <pci_init+0x63>
        pci_init_device(i,j,k);
80108523:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108526:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852c:	83 ec 04             	sub    $0x4,%esp
8010852f:	51                   	push   %ecx
80108530:	52                   	push   %edx
80108531:	50                   	push   %eax
80108532:	e8 37 01 00 00       	call   8010866e <pci_init_device>
80108537:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
8010853a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010853e:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108542:	7e b5                	jle    801084f9 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108544:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108548:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010854c:	7e a2                	jle    801084f0 <pci_init+0x19>
  for(int i=0;i<256;i++){
8010854e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108552:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108559:	7e 8c                	jle    801084e7 <pci_init+0x10>
      }
      }
    }
  }
}
8010855b:	90                   	nop
8010855c:	90                   	nop
8010855d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108560:	c9                   	leave  
80108561:	c3                   	ret    

80108562 <pci_write_config>:

void pci_write_config(uint config){
80108562:	55                   	push   %ebp
80108563:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108565:	8b 45 08             	mov    0x8(%ebp),%eax
80108568:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010856d:	89 c0                	mov    %eax,%eax
8010856f:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108570:	90                   	nop
80108571:	5d                   	pop    %ebp
80108572:	c3                   	ret    

80108573 <pci_write_data>:

void pci_write_data(uint config){
80108573:	55                   	push   %ebp
80108574:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108576:	8b 45 08             	mov    0x8(%ebp),%eax
80108579:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010857e:	89 c0                	mov    %eax,%eax
80108580:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108581:	90                   	nop
80108582:	5d                   	pop    %ebp
80108583:	c3                   	ret    

80108584 <pci_read_config>:
uint pci_read_config(){
80108584:	55                   	push   %ebp
80108585:	89 e5                	mov    %esp,%ebp
80108587:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010858a:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010858f:	ed                   	in     (%dx),%eax
80108590:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108593:	83 ec 0c             	sub    $0xc,%esp
80108596:	68 c8 00 00 00       	push   $0xc8
8010859b:	e8 97 a5 ff ff       	call   80102b37 <microdelay>
801085a0:	83 c4 10             	add    $0x10,%esp
  return data;
801085a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801085a6:	c9                   	leave  
801085a7:	c3                   	ret    

801085a8 <pci_test>:


void pci_test(){
801085a8:	55                   	push   %ebp
801085a9:	89 e5                	mov    %esp,%ebp
801085ab:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801085ae:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801085b5:	ff 75 fc             	push   -0x4(%ebp)
801085b8:	e8 a5 ff ff ff       	call   80108562 <pci_write_config>
801085bd:	83 c4 04             	add    $0x4,%esp
}
801085c0:	90                   	nop
801085c1:	c9                   	leave  
801085c2:	c3                   	ret    

801085c3 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801085c3:	55                   	push   %ebp
801085c4:	89 e5                	mov    %esp,%ebp
801085c6:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801085c9:	8b 45 08             	mov    0x8(%ebp),%eax
801085cc:	c1 e0 10             	shl    $0x10,%eax
801085cf:	25 00 00 ff 00       	and    $0xff0000,%eax
801085d4:	89 c2                	mov    %eax,%edx
801085d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801085d9:	c1 e0 0b             	shl    $0xb,%eax
801085dc:	0f b7 c0             	movzwl %ax,%eax
801085df:	09 c2                	or     %eax,%edx
801085e1:	8b 45 10             	mov    0x10(%ebp),%eax
801085e4:	c1 e0 08             	shl    $0x8,%eax
801085e7:	25 00 07 00 00       	and    $0x700,%eax
801085ec:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801085ee:	8b 45 14             	mov    0x14(%ebp),%eax
801085f1:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801085f6:	09 d0                	or     %edx,%eax
801085f8:	0d 00 00 00 80       	or     $0x80000000,%eax
801085fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108600:	ff 75 f4             	push   -0xc(%ebp)
80108603:	e8 5a ff ff ff       	call   80108562 <pci_write_config>
80108608:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010860b:	e8 74 ff ff ff       	call   80108584 <pci_read_config>
80108610:	8b 55 18             	mov    0x18(%ebp),%edx
80108613:	89 02                	mov    %eax,(%edx)
}
80108615:	90                   	nop
80108616:	c9                   	leave  
80108617:	c3                   	ret    

80108618 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108618:	55                   	push   %ebp
80108619:	89 e5                	mov    %esp,%ebp
8010861b:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010861e:	8b 45 08             	mov    0x8(%ebp),%eax
80108621:	c1 e0 10             	shl    $0x10,%eax
80108624:	25 00 00 ff 00       	and    $0xff0000,%eax
80108629:	89 c2                	mov    %eax,%edx
8010862b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010862e:	c1 e0 0b             	shl    $0xb,%eax
80108631:	0f b7 c0             	movzwl %ax,%eax
80108634:	09 c2                	or     %eax,%edx
80108636:	8b 45 10             	mov    0x10(%ebp),%eax
80108639:	c1 e0 08             	shl    $0x8,%eax
8010863c:	25 00 07 00 00       	and    $0x700,%eax
80108641:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108643:	8b 45 14             	mov    0x14(%ebp),%eax
80108646:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010864b:	09 d0                	or     %edx,%eax
8010864d:	0d 00 00 00 80       	or     $0x80000000,%eax
80108652:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108655:	ff 75 fc             	push   -0x4(%ebp)
80108658:	e8 05 ff ff ff       	call   80108562 <pci_write_config>
8010865d:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108660:	ff 75 18             	push   0x18(%ebp)
80108663:	e8 0b ff ff ff       	call   80108573 <pci_write_data>
80108668:	83 c4 04             	add    $0x4,%esp
}
8010866b:	90                   	nop
8010866c:	c9                   	leave  
8010866d:	c3                   	ret    

8010866e <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010866e:	55                   	push   %ebp
8010866f:	89 e5                	mov    %esp,%ebp
80108671:	53                   	push   %ebx
80108672:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108675:	8b 45 08             	mov    0x8(%ebp),%eax
80108678:	a2 74 75 19 80       	mov    %al,0x80197574
  dev.device_num = device_num;
8010867d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108680:	a2 75 75 19 80       	mov    %al,0x80197575
  dev.function_num = function_num;
80108685:	8b 45 10             	mov    0x10(%ebp),%eax
80108688:	a2 76 75 19 80       	mov    %al,0x80197576
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010868d:	ff 75 10             	push   0x10(%ebp)
80108690:	ff 75 0c             	push   0xc(%ebp)
80108693:	ff 75 08             	push   0x8(%ebp)
80108696:	68 e4 c1 10 80       	push   $0x8010c1e4
8010869b:	e8 54 7d ff ff       	call   801003f4 <cprintf>
801086a0:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801086a3:	83 ec 0c             	sub    $0xc,%esp
801086a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086a9:	50                   	push   %eax
801086aa:	6a 00                	push   $0x0
801086ac:	ff 75 10             	push   0x10(%ebp)
801086af:	ff 75 0c             	push   0xc(%ebp)
801086b2:	ff 75 08             	push   0x8(%ebp)
801086b5:	e8 09 ff ff ff       	call   801085c3 <pci_access_config>
801086ba:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801086bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086c0:	c1 e8 10             	shr    $0x10,%eax
801086c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801086c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086c9:	25 ff ff 00 00       	and    $0xffff,%eax
801086ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801086d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d4:	a3 78 75 19 80       	mov    %eax,0x80197578
  dev.vendor_id = vendor_id;
801086d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086dc:	a3 7c 75 19 80       	mov    %eax,0x8019757c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801086e1:	83 ec 04             	sub    $0x4,%esp
801086e4:	ff 75 f0             	push   -0x10(%ebp)
801086e7:	ff 75 f4             	push   -0xc(%ebp)
801086ea:	68 18 c2 10 80       	push   $0x8010c218
801086ef:	e8 00 7d ff ff       	call   801003f4 <cprintf>
801086f4:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801086f7:	83 ec 0c             	sub    $0xc,%esp
801086fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086fd:	50                   	push   %eax
801086fe:	6a 08                	push   $0x8
80108700:	ff 75 10             	push   0x10(%ebp)
80108703:	ff 75 0c             	push   0xc(%ebp)
80108706:	ff 75 08             	push   0x8(%ebp)
80108709:	e8 b5 fe ff ff       	call   801085c3 <pci_access_config>
8010870e:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108711:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108714:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108717:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010871a:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010871d:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108720:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108723:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108726:	0f b6 c0             	movzbl %al,%eax
80108729:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010872c:	c1 eb 18             	shr    $0x18,%ebx
8010872f:	83 ec 0c             	sub    $0xc,%esp
80108732:	51                   	push   %ecx
80108733:	52                   	push   %edx
80108734:	50                   	push   %eax
80108735:	53                   	push   %ebx
80108736:	68 3c c2 10 80       	push   $0x8010c23c
8010873b:	e8 b4 7c ff ff       	call   801003f4 <cprintf>
80108740:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108743:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108746:	c1 e8 18             	shr    $0x18,%eax
80108749:	a2 80 75 19 80       	mov    %al,0x80197580
  dev.sub_class = (data>>16)&0xFF;
8010874e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108751:	c1 e8 10             	shr    $0x10,%eax
80108754:	a2 81 75 19 80       	mov    %al,0x80197581
  dev.interface = (data>>8)&0xFF;
80108759:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010875c:	c1 e8 08             	shr    $0x8,%eax
8010875f:	a2 82 75 19 80       	mov    %al,0x80197582
  dev.revision_id = data&0xFF;
80108764:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108767:	a2 83 75 19 80       	mov    %al,0x80197583
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010876c:	83 ec 0c             	sub    $0xc,%esp
8010876f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108772:	50                   	push   %eax
80108773:	6a 10                	push   $0x10
80108775:	ff 75 10             	push   0x10(%ebp)
80108778:	ff 75 0c             	push   0xc(%ebp)
8010877b:	ff 75 08             	push   0x8(%ebp)
8010877e:	e8 40 fe ff ff       	call   801085c3 <pci_access_config>
80108783:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108786:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108789:	a3 84 75 19 80       	mov    %eax,0x80197584
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010878e:	83 ec 0c             	sub    $0xc,%esp
80108791:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108794:	50                   	push   %eax
80108795:	6a 14                	push   $0x14
80108797:	ff 75 10             	push   0x10(%ebp)
8010879a:	ff 75 0c             	push   0xc(%ebp)
8010879d:	ff 75 08             	push   0x8(%ebp)
801087a0:	e8 1e fe ff ff       	call   801085c3 <pci_access_config>
801087a5:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801087a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ab:	a3 88 75 19 80       	mov    %eax,0x80197588
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801087b0:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801087b7:	75 5a                	jne    80108813 <pci_init_device+0x1a5>
801087b9:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801087c0:	75 51                	jne    80108813 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801087c2:	83 ec 0c             	sub    $0xc,%esp
801087c5:	68 81 c2 10 80       	push   $0x8010c281
801087ca:	e8 25 7c ff ff       	call   801003f4 <cprintf>
801087cf:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801087d2:	83 ec 0c             	sub    $0xc,%esp
801087d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087d8:	50                   	push   %eax
801087d9:	68 f0 00 00 00       	push   $0xf0
801087de:	ff 75 10             	push   0x10(%ebp)
801087e1:	ff 75 0c             	push   0xc(%ebp)
801087e4:	ff 75 08             	push   0x8(%ebp)
801087e7:	e8 d7 fd ff ff       	call   801085c3 <pci_access_config>
801087ec:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801087ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f2:	83 ec 08             	sub    $0x8,%esp
801087f5:	50                   	push   %eax
801087f6:	68 9b c2 10 80       	push   $0x8010c29b
801087fb:	e8 f4 7b ff ff       	call   801003f4 <cprintf>
80108800:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108803:	83 ec 0c             	sub    $0xc,%esp
80108806:	68 74 75 19 80       	push   $0x80197574
8010880b:	e8 09 00 00 00       	call   80108819 <i8254_init>
80108810:	83 c4 10             	add    $0x10,%esp
  }
}
80108813:	90                   	nop
80108814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108817:	c9                   	leave  
80108818:	c3                   	ret    

80108819 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108819:	55                   	push   %ebp
8010881a:	89 e5                	mov    %esp,%ebp
8010881c:	53                   	push   %ebx
8010881d:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108820:	8b 45 08             	mov    0x8(%ebp),%eax
80108823:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108827:	0f b6 c8             	movzbl %al,%ecx
8010882a:	8b 45 08             	mov    0x8(%ebp),%eax
8010882d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108831:	0f b6 d0             	movzbl %al,%edx
80108834:	8b 45 08             	mov    0x8(%ebp),%eax
80108837:	0f b6 00             	movzbl (%eax),%eax
8010883a:	0f b6 c0             	movzbl %al,%eax
8010883d:	83 ec 0c             	sub    $0xc,%esp
80108840:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108843:	53                   	push   %ebx
80108844:	6a 04                	push   $0x4
80108846:	51                   	push   %ecx
80108847:	52                   	push   %edx
80108848:	50                   	push   %eax
80108849:	e8 75 fd ff ff       	call   801085c3 <pci_access_config>
8010884e:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108851:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108854:	83 c8 04             	or     $0x4,%eax
80108857:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
8010885a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010885d:	8b 45 08             	mov    0x8(%ebp),%eax
80108860:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108864:	0f b6 c8             	movzbl %al,%ecx
80108867:	8b 45 08             	mov    0x8(%ebp),%eax
8010886a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010886e:	0f b6 d0             	movzbl %al,%edx
80108871:	8b 45 08             	mov    0x8(%ebp),%eax
80108874:	0f b6 00             	movzbl (%eax),%eax
80108877:	0f b6 c0             	movzbl %al,%eax
8010887a:	83 ec 0c             	sub    $0xc,%esp
8010887d:	53                   	push   %ebx
8010887e:	6a 04                	push   $0x4
80108880:	51                   	push   %ecx
80108881:	52                   	push   %edx
80108882:	50                   	push   %eax
80108883:	e8 90 fd ff ff       	call   80108618 <pci_write_config_register>
80108888:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
8010888b:	8b 45 08             	mov    0x8(%ebp),%eax
8010888e:	8b 40 10             	mov    0x10(%eax),%eax
80108891:	05 00 00 00 40       	add    $0x40000000,%eax
80108896:	a3 8c 75 19 80       	mov    %eax,0x8019758c
  uint *ctrl = (uint *)base_addr;
8010889b:	a1 8c 75 19 80       	mov    0x8019758c,%eax
801088a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801088a3:	a1 8c 75 19 80       	mov    0x8019758c,%eax
801088a8:	05 d8 00 00 00       	add    $0xd8,%eax
801088ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801088b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088b3:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801088b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088bc:	8b 00                	mov    (%eax),%eax
801088be:	0d 00 00 00 04       	or     $0x4000000,%eax
801088c3:	89 c2                	mov    %eax,%edx
801088c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c8:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801088ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088cd:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801088d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d6:	8b 00                	mov    (%eax),%eax
801088d8:	83 c8 40             	or     $0x40,%eax
801088db:	89 c2                	mov    %eax,%edx
801088dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e0:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801088e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e5:	8b 10                	mov    (%eax),%edx
801088e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ea:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801088ec:	83 ec 0c             	sub    $0xc,%esp
801088ef:	68 b0 c2 10 80       	push   $0x8010c2b0
801088f4:	e8 fb 7a ff ff       	call   801003f4 <cprintf>
801088f9:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801088fc:	e8 9f 9e ff ff       	call   801027a0 <kalloc>
80108901:	a3 98 75 19 80       	mov    %eax,0x80197598
  *intr_addr = 0;
80108906:	a1 98 75 19 80       	mov    0x80197598,%eax
8010890b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108911:	a1 98 75 19 80       	mov    0x80197598,%eax
80108916:	83 ec 08             	sub    $0x8,%esp
80108919:	50                   	push   %eax
8010891a:	68 d2 c2 10 80       	push   $0x8010c2d2
8010891f:	e8 d0 7a ff ff       	call   801003f4 <cprintf>
80108924:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108927:	e8 50 00 00 00       	call   8010897c <i8254_init_recv>
  i8254_init_send();
8010892c:	e8 69 03 00 00       	call   80108c9a <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108931:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108938:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010893b:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108942:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108945:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010894c:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010894f:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108956:	0f b6 c0             	movzbl %al,%eax
80108959:	83 ec 0c             	sub    $0xc,%esp
8010895c:	53                   	push   %ebx
8010895d:	51                   	push   %ecx
8010895e:	52                   	push   %edx
8010895f:	50                   	push   %eax
80108960:	68 e0 c2 10 80       	push   $0x8010c2e0
80108965:	e8 8a 7a ff ff       	call   801003f4 <cprintf>
8010896a:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010896d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108970:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108976:	90                   	nop
80108977:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010897a:	c9                   	leave  
8010897b:	c3                   	ret    

8010897c <i8254_init_recv>:

void i8254_init_recv(){
8010897c:	55                   	push   %ebp
8010897d:	89 e5                	mov    %esp,%ebp
8010897f:	57                   	push   %edi
80108980:	56                   	push   %esi
80108981:	53                   	push   %ebx
80108982:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108985:	83 ec 0c             	sub    $0xc,%esp
80108988:	6a 00                	push   $0x0
8010898a:	e8 e8 04 00 00       	call   80108e77 <i8254_read_eeprom>
8010898f:	83 c4 10             	add    $0x10,%esp
80108992:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108995:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108998:	a2 90 75 19 80       	mov    %al,0x80197590
  mac_addr[1] = data_l>>8;
8010899d:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089a0:	c1 e8 08             	shr    $0x8,%eax
801089a3:	a2 91 75 19 80       	mov    %al,0x80197591
  uint data_m = i8254_read_eeprom(0x1);
801089a8:	83 ec 0c             	sub    $0xc,%esp
801089ab:	6a 01                	push   $0x1
801089ad:	e8 c5 04 00 00       	call   80108e77 <i8254_read_eeprom>
801089b2:	83 c4 10             	add    $0x10,%esp
801089b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801089b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089bb:	a2 92 75 19 80       	mov    %al,0x80197592
  mac_addr[3] = data_m>>8;
801089c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089c3:	c1 e8 08             	shr    $0x8,%eax
801089c6:	a2 93 75 19 80       	mov    %al,0x80197593
  uint data_h = i8254_read_eeprom(0x2);
801089cb:	83 ec 0c             	sub    $0xc,%esp
801089ce:	6a 02                	push   $0x2
801089d0:	e8 a2 04 00 00       	call   80108e77 <i8254_read_eeprom>
801089d5:	83 c4 10             	add    $0x10,%esp
801089d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801089db:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089de:	a2 94 75 19 80       	mov    %al,0x80197594
  mac_addr[5] = data_h>>8;
801089e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089e6:	c1 e8 08             	shr    $0x8,%eax
801089e9:	a2 95 75 19 80       	mov    %al,0x80197595
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801089ee:	0f b6 05 95 75 19 80 	movzbl 0x80197595,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089f5:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801089f8:	0f b6 05 94 75 19 80 	movzbl 0x80197594,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089ff:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108a02:	0f b6 05 93 75 19 80 	movzbl 0x80197593,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a09:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108a0c:	0f b6 05 92 75 19 80 	movzbl 0x80197592,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a13:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108a16:	0f b6 05 91 75 19 80 	movzbl 0x80197591,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a1d:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108a20:	0f b6 05 90 75 19 80 	movzbl 0x80197590,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a27:	0f b6 c0             	movzbl %al,%eax
80108a2a:	83 ec 04             	sub    $0x4,%esp
80108a2d:	57                   	push   %edi
80108a2e:	56                   	push   %esi
80108a2f:	53                   	push   %ebx
80108a30:	51                   	push   %ecx
80108a31:	52                   	push   %edx
80108a32:	50                   	push   %eax
80108a33:	68 f8 c2 10 80       	push   $0x8010c2f8
80108a38:	e8 b7 79 ff ff       	call   801003f4 <cprintf>
80108a3d:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108a40:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108a45:	05 00 54 00 00       	add    $0x5400,%eax
80108a4a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108a4d:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108a52:	05 04 54 00 00       	add    $0x5404,%eax
80108a57:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108a5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a5d:	c1 e0 10             	shl    $0x10,%eax
80108a60:	0b 45 d8             	or     -0x28(%ebp),%eax
80108a63:	89 c2                	mov    %eax,%edx
80108a65:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108a68:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108a6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a6d:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a72:	89 c2                	mov    %eax,%edx
80108a74:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a77:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108a79:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108a7e:	05 00 52 00 00       	add    $0x5200,%eax
80108a83:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108a86:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108a8d:	eb 19                	jmp    80108aa8 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108a8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a92:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a99:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108a9c:	01 d0                	add    %edx,%eax
80108a9e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108aa4:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108aa8:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108aac:	7e e1                	jle    80108a8f <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108aae:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108ab3:	05 d0 00 00 00       	add    $0xd0,%eax
80108ab8:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108abb:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108abe:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108ac4:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108ac9:	05 c8 00 00 00       	add    $0xc8,%eax
80108ace:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ad1:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108ad4:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108ada:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108adf:	05 28 28 00 00       	add    $0x2828,%eax
80108ae4:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108ae7:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108aea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108af0:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108af5:	05 00 01 00 00       	add    $0x100,%eax
80108afa:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108afd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b00:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108b06:	e8 95 9c ff ff       	call   801027a0 <kalloc>
80108b0b:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b0e:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b13:	05 00 28 00 00       	add    $0x2800,%eax
80108b18:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108b1b:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b20:	05 04 28 00 00       	add    $0x2804,%eax
80108b25:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108b28:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b2d:	05 08 28 00 00       	add    $0x2808,%eax
80108b32:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b35:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b3a:	05 10 28 00 00       	add    $0x2810,%eax
80108b3f:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b42:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b47:	05 18 28 00 00       	add    $0x2818,%eax
80108b4c:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108b4f:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b52:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b58:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108b5b:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108b5d:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108b60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108b66:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108b69:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108b6f:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108b72:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108b78:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108b7b:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108b81:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b84:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108b87:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108b8e:	eb 73                	jmp    80108c03 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108b90:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b93:	c1 e0 04             	shl    $0x4,%eax
80108b96:	89 c2                	mov    %eax,%edx
80108b98:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b9b:	01 d0                	add    %edx,%eax
80108b9d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108ba4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ba7:	c1 e0 04             	shl    $0x4,%eax
80108baa:	89 c2                	mov    %eax,%edx
80108bac:	8b 45 98             	mov    -0x68(%ebp),%eax
80108baf:	01 d0                	add    %edx,%eax
80108bb1:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108bb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bba:	c1 e0 04             	shl    $0x4,%eax
80108bbd:	89 c2                	mov    %eax,%edx
80108bbf:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bc2:	01 d0                	add    %edx,%eax
80108bc4:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108bca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bcd:	c1 e0 04             	shl    $0x4,%eax
80108bd0:	89 c2                	mov    %eax,%edx
80108bd2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bd5:	01 d0                	add    %edx,%eax
80108bd7:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108bdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bde:	c1 e0 04             	shl    $0x4,%eax
80108be1:	89 c2                	mov    %eax,%edx
80108be3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108be6:	01 d0                	add    %edx,%eax
80108be8:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108bec:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bef:	c1 e0 04             	shl    $0x4,%eax
80108bf2:	89 c2                	mov    %eax,%edx
80108bf4:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bf7:	01 d0                	add    %edx,%eax
80108bf9:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108bff:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108c03:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108c0a:	7e 84                	jle    80108b90 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c0c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108c13:	eb 57                	jmp    80108c6c <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108c15:	e8 86 9b ff ff       	call   801027a0 <kalloc>
80108c1a:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108c1d:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108c21:	75 12                	jne    80108c35 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108c23:	83 ec 0c             	sub    $0xc,%esp
80108c26:	68 18 c3 10 80       	push   $0x8010c318
80108c2b:	e8 c4 77 ff ff       	call   801003f4 <cprintf>
80108c30:	83 c4 10             	add    $0x10,%esp
      break;
80108c33:	eb 3d                	jmp    80108c72 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108c35:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c38:	c1 e0 04             	shl    $0x4,%eax
80108c3b:	89 c2                	mov    %eax,%edx
80108c3d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c40:	01 d0                	add    %edx,%eax
80108c42:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c45:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c4b:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108c4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c50:	83 c0 01             	add    $0x1,%eax
80108c53:	c1 e0 04             	shl    $0x4,%eax
80108c56:	89 c2                	mov    %eax,%edx
80108c58:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c5b:	01 d0                	add    %edx,%eax
80108c5d:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c60:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108c66:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c68:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108c6c:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108c70:	7e a3                	jle    80108c15 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108c72:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c75:	8b 00                	mov    (%eax),%eax
80108c77:	83 c8 02             	or     $0x2,%eax
80108c7a:	89 c2                	mov    %eax,%edx
80108c7c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c7f:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108c81:	83 ec 0c             	sub    $0xc,%esp
80108c84:	68 38 c3 10 80       	push   $0x8010c338
80108c89:	e8 66 77 ff ff       	call   801003f4 <cprintf>
80108c8e:	83 c4 10             	add    $0x10,%esp
}
80108c91:	90                   	nop
80108c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108c95:	5b                   	pop    %ebx
80108c96:	5e                   	pop    %esi
80108c97:	5f                   	pop    %edi
80108c98:	5d                   	pop    %ebp
80108c99:	c3                   	ret    

80108c9a <i8254_init_send>:

void i8254_init_send(){
80108c9a:	55                   	push   %ebp
80108c9b:	89 e5                	mov    %esp,%ebp
80108c9d:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108ca0:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108ca5:	05 28 38 00 00       	add    $0x3828,%eax
80108caa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108cad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cb0:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108cb6:	e8 e5 9a ff ff       	call   801027a0 <kalloc>
80108cbb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108cbe:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108cc3:	05 00 38 00 00       	add    $0x3800,%eax
80108cc8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108ccb:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108cd0:	05 04 38 00 00       	add    $0x3804,%eax
80108cd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108cd8:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108cdd:	05 08 38 00 00       	add    $0x3808,%eax
80108ce2:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108ce5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ce8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108cee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108cf1:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108cf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cf6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108cfc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cff:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d05:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d0a:	05 10 38 00 00       	add    $0x3810,%eax
80108d0f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d12:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d17:	05 18 38 00 00       	add    $0x3818,%eax
80108d1c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108d1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108d28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d2b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108d31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d34:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108d37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d3e:	e9 82 00 00 00       	jmp    80108dc5 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d46:	c1 e0 04             	shl    $0x4,%eax
80108d49:	89 c2                	mov    %eax,%edx
80108d4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d4e:	01 d0                	add    %edx,%eax
80108d50:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5a:	c1 e0 04             	shl    $0x4,%eax
80108d5d:	89 c2                	mov    %eax,%edx
80108d5f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d62:	01 d0                	add    %edx,%eax
80108d64:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d6d:	c1 e0 04             	shl    $0x4,%eax
80108d70:	89 c2                	mov    %eax,%edx
80108d72:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d75:	01 d0                	add    %edx,%eax
80108d77:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d7e:	c1 e0 04             	shl    $0x4,%eax
80108d81:	89 c2                	mov    %eax,%edx
80108d83:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d86:	01 d0                	add    %edx,%eax
80108d88:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d8f:	c1 e0 04             	shl    $0x4,%eax
80108d92:	89 c2                	mov    %eax,%edx
80108d94:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d97:	01 d0                	add    %edx,%eax
80108d99:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da0:	c1 e0 04             	shl    $0x4,%eax
80108da3:	89 c2                	mov    %eax,%edx
80108da5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108da8:	01 d0                	add    %edx,%eax
80108daa:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db1:	c1 e0 04             	shl    $0x4,%eax
80108db4:	89 c2                	mov    %eax,%edx
80108db6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108db9:	01 d0                	add    %edx,%eax
80108dbb:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108dc1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108dc5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108dcc:	0f 8e 71 ff ff ff    	jle    80108d43 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108dd2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108dd9:	eb 57                	jmp    80108e32 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108ddb:	e8 c0 99 ff ff       	call   801027a0 <kalloc>
80108de0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108de3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108de7:	75 12                	jne    80108dfb <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108de9:	83 ec 0c             	sub    $0xc,%esp
80108dec:	68 18 c3 10 80       	push   $0x8010c318
80108df1:	e8 fe 75 ff ff       	call   801003f4 <cprintf>
80108df6:	83 c4 10             	add    $0x10,%esp
      break;
80108df9:	eb 3d                	jmp    80108e38 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dfe:	c1 e0 04             	shl    $0x4,%eax
80108e01:	89 c2                	mov    %eax,%edx
80108e03:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e06:	01 d0                	add    %edx,%eax
80108e08:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e0b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e11:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e16:	83 c0 01             	add    $0x1,%eax
80108e19:	c1 e0 04             	shl    $0x4,%eax
80108e1c:	89 c2                	mov    %eax,%edx
80108e1e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e21:	01 d0                	add    %edx,%eax
80108e23:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e26:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e2c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e2e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e32:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108e36:	7e a3                	jle    80108ddb <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108e38:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108e3d:	05 00 04 00 00       	add    $0x400,%eax
80108e42:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108e45:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108e48:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108e4e:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108e53:	05 10 04 00 00       	add    $0x410,%eax
80108e58:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108e5b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108e5e:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108e64:	83 ec 0c             	sub    $0xc,%esp
80108e67:	68 58 c3 10 80       	push   $0x8010c358
80108e6c:	e8 83 75 ff ff       	call   801003f4 <cprintf>
80108e71:	83 c4 10             	add    $0x10,%esp

}
80108e74:	90                   	nop
80108e75:	c9                   	leave  
80108e76:	c3                   	ret    

80108e77 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108e77:	55                   	push   %ebp
80108e78:	89 e5                	mov    %esp,%ebp
80108e7a:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108e7d:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108e82:	83 c0 14             	add    $0x14,%eax
80108e85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108e88:	8b 45 08             	mov    0x8(%ebp),%eax
80108e8b:	c1 e0 08             	shl    $0x8,%eax
80108e8e:	0f b7 c0             	movzwl %ax,%eax
80108e91:	83 c8 01             	or     $0x1,%eax
80108e94:	89 c2                	mov    %eax,%edx
80108e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e99:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108e9b:	83 ec 0c             	sub    $0xc,%esp
80108e9e:	68 78 c3 10 80       	push   $0x8010c378
80108ea3:	e8 4c 75 ff ff       	call   801003f4 <cprintf>
80108ea8:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eae:	8b 00                	mov    (%eax),%eax
80108eb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb6:	83 e0 10             	and    $0x10,%eax
80108eb9:	85 c0                	test   %eax,%eax
80108ebb:	75 02                	jne    80108ebf <i8254_read_eeprom+0x48>
  while(1){
80108ebd:	eb dc                	jmp    80108e9b <i8254_read_eeprom+0x24>
      break;
80108ebf:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec3:	8b 00                	mov    (%eax),%eax
80108ec5:	c1 e8 10             	shr    $0x10,%eax
}
80108ec8:	c9                   	leave  
80108ec9:	c3                   	ret    

80108eca <i8254_recv>:
void i8254_recv(){
80108eca:	55                   	push   %ebp
80108ecb:	89 e5                	mov    %esp,%ebp
80108ecd:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108ed0:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108ed5:	05 10 28 00 00       	add    $0x2810,%eax
80108eda:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108edd:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108ee2:	05 18 28 00 00       	add    $0x2818,%eax
80108ee7:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108eea:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108eef:	05 00 28 00 00       	add    $0x2800,%eax
80108ef4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108ef7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108efa:	8b 00                	mov    (%eax),%eax
80108efc:	05 00 00 00 80       	add    $0x80000000,%eax
80108f01:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f07:	8b 10                	mov    (%eax),%edx
80108f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f0c:	8b 08                	mov    (%eax),%ecx
80108f0e:	89 d0                	mov    %edx,%eax
80108f10:	29 c8                	sub    %ecx,%eax
80108f12:	25 ff 00 00 00       	and    $0xff,%eax
80108f17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108f1a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f1e:	7e 37                	jle    80108f57 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f23:	8b 00                	mov    (%eax),%eax
80108f25:	c1 e0 04             	shl    $0x4,%eax
80108f28:	89 c2                	mov    %eax,%edx
80108f2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f2d:	01 d0                	add    %edx,%eax
80108f2f:	8b 00                	mov    (%eax),%eax
80108f31:	05 00 00 00 80       	add    $0x80000000,%eax
80108f36:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f3c:	8b 00                	mov    (%eax),%eax
80108f3e:	83 c0 01             	add    $0x1,%eax
80108f41:	0f b6 d0             	movzbl %al,%edx
80108f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f47:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108f49:	83 ec 0c             	sub    $0xc,%esp
80108f4c:	ff 75 e0             	push   -0x20(%ebp)
80108f4f:	e8 15 09 00 00       	call   80109869 <eth_proc>
80108f54:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5a:	8b 10                	mov    (%eax),%edx
80108f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f5f:	8b 00                	mov    (%eax),%eax
80108f61:	39 c2                	cmp    %eax,%edx
80108f63:	75 9f                	jne    80108f04 <i8254_recv+0x3a>
      (*rdt)--;
80108f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f68:	8b 00                	mov    (%eax),%eax
80108f6a:	8d 50 ff             	lea    -0x1(%eax),%edx
80108f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f70:	89 10                	mov    %edx,(%eax)
  while(1){
80108f72:	eb 90                	jmp    80108f04 <i8254_recv+0x3a>

80108f74 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108f74:	55                   	push   %ebp
80108f75:	89 e5                	mov    %esp,%ebp
80108f77:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f7a:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f7f:	05 10 38 00 00       	add    $0x3810,%eax
80108f84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f87:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f8c:	05 18 38 00 00       	add    $0x3818,%eax
80108f91:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108f94:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f99:	05 00 38 00 00       	add    $0x3800,%eax
80108f9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108fa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fa4:	8b 00                	mov    (%eax),%eax
80108fa6:	05 00 00 00 80       	add    $0x80000000,%eax
80108fab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb1:	8b 10                	mov    (%eax),%edx
80108fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb6:	8b 08                	mov    (%eax),%ecx
80108fb8:	89 d0                	mov    %edx,%eax
80108fba:	29 c8                	sub    %ecx,%eax
80108fbc:	0f b6 d0             	movzbl %al,%edx
80108fbf:	b8 00 01 00 00       	mov    $0x100,%eax
80108fc4:	29 d0                	sub    %edx,%eax
80108fc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fcc:	8b 00                	mov    (%eax),%eax
80108fce:	25 ff 00 00 00       	and    $0xff,%eax
80108fd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108fd6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108fda:	0f 8e a8 00 00 00    	jle    80109088 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80108fe3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108fe6:	89 d1                	mov    %edx,%ecx
80108fe8:	c1 e1 04             	shl    $0x4,%ecx
80108feb:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108fee:	01 ca                	add    %ecx,%edx
80108ff0:	8b 12                	mov    (%edx),%edx
80108ff2:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108ff8:	83 ec 04             	sub    $0x4,%esp
80108ffb:	ff 75 0c             	push   0xc(%ebp)
80108ffe:	50                   	push   %eax
80108fff:	52                   	push   %edx
80109000:	e8 4e be ff ff       	call   80104e53 <memmove>
80109005:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109008:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010900b:	c1 e0 04             	shl    $0x4,%eax
8010900e:	89 c2                	mov    %eax,%edx
80109010:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109013:	01 d0                	add    %edx,%eax
80109015:	8b 55 0c             	mov    0xc(%ebp),%edx
80109018:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010901c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010901f:	c1 e0 04             	shl    $0x4,%eax
80109022:	89 c2                	mov    %eax,%edx
80109024:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109027:	01 d0                	add    %edx,%eax
80109029:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010902d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109030:	c1 e0 04             	shl    $0x4,%eax
80109033:	89 c2                	mov    %eax,%edx
80109035:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109038:	01 d0                	add    %edx,%eax
8010903a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010903e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109041:	c1 e0 04             	shl    $0x4,%eax
80109044:	89 c2                	mov    %eax,%edx
80109046:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109049:	01 d0                	add    %edx,%eax
8010904b:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010904f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109052:	c1 e0 04             	shl    $0x4,%eax
80109055:	89 c2                	mov    %eax,%edx
80109057:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010905a:	01 d0                	add    %edx,%eax
8010905c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109062:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109065:	c1 e0 04             	shl    $0x4,%eax
80109068:	89 c2                	mov    %eax,%edx
8010906a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010906d:	01 d0                	add    %edx,%eax
8010906f:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109073:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109076:	8b 00                	mov    (%eax),%eax
80109078:	83 c0 01             	add    $0x1,%eax
8010907b:	0f b6 d0             	movzbl %al,%edx
8010907e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109081:	89 10                	mov    %edx,(%eax)
    return len;
80109083:	8b 45 0c             	mov    0xc(%ebp),%eax
80109086:	eb 05                	jmp    8010908d <i8254_send+0x119>
  }else{
    return -1;
80109088:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010908d:	c9                   	leave  
8010908e:	c3                   	ret    

8010908f <i8254_intr>:

void i8254_intr(){
8010908f:	55                   	push   %ebp
80109090:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109092:	a1 98 75 19 80       	mov    0x80197598,%eax
80109097:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010909d:	90                   	nop
8010909e:	5d                   	pop    %ebp
8010909f:	c3                   	ret    

801090a0 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801090a0:	55                   	push   %ebp
801090a1:	89 e5                	mov    %esp,%ebp
801090a3:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801090a6:	8b 45 08             	mov    0x8(%ebp),%eax
801090a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801090ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090af:	0f b7 00             	movzwl (%eax),%eax
801090b2:	66 3d 00 01          	cmp    $0x100,%ax
801090b6:	74 0a                	je     801090c2 <arp_proc+0x22>
801090b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090bd:	e9 4f 01 00 00       	jmp    80109211 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801090c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c5:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801090c9:	66 83 f8 08          	cmp    $0x8,%ax
801090cd:	74 0a                	je     801090d9 <arp_proc+0x39>
801090cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090d4:	e9 38 01 00 00       	jmp    80109211 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
801090d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090dc:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801090e0:	3c 06                	cmp    $0x6,%al
801090e2:	74 0a                	je     801090ee <arp_proc+0x4e>
801090e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090e9:	e9 23 01 00 00       	jmp    80109211 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801090ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f1:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801090f5:	3c 04                	cmp    $0x4,%al
801090f7:	74 0a                	je     80109103 <arp_proc+0x63>
801090f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090fe:	e9 0e 01 00 00       	jmp    80109211 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109106:	83 c0 18             	add    $0x18,%eax
80109109:	83 ec 04             	sub    $0x4,%esp
8010910c:	6a 04                	push   $0x4
8010910e:	50                   	push   %eax
8010910f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109114:	e8 e2 bc ff ff       	call   80104dfb <memcmp>
80109119:	83 c4 10             	add    $0x10,%esp
8010911c:	85 c0                	test   %eax,%eax
8010911e:	74 27                	je     80109147 <arp_proc+0xa7>
80109120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109123:	83 c0 0e             	add    $0xe,%eax
80109126:	83 ec 04             	sub    $0x4,%esp
80109129:	6a 04                	push   $0x4
8010912b:	50                   	push   %eax
8010912c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109131:	e8 c5 bc ff ff       	call   80104dfb <memcmp>
80109136:	83 c4 10             	add    $0x10,%esp
80109139:	85 c0                	test   %eax,%eax
8010913b:	74 0a                	je     80109147 <arp_proc+0xa7>
8010913d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109142:	e9 ca 00 00 00       	jmp    80109211 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010914a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010914e:	66 3d 00 01          	cmp    $0x100,%ax
80109152:	75 69                	jne    801091bd <arp_proc+0x11d>
80109154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109157:	83 c0 18             	add    $0x18,%eax
8010915a:	83 ec 04             	sub    $0x4,%esp
8010915d:	6a 04                	push   $0x4
8010915f:	50                   	push   %eax
80109160:	68 e4 f4 10 80       	push   $0x8010f4e4
80109165:	e8 91 bc ff ff       	call   80104dfb <memcmp>
8010916a:	83 c4 10             	add    $0x10,%esp
8010916d:	85 c0                	test   %eax,%eax
8010916f:	75 4c                	jne    801091bd <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109171:	e8 2a 96 ff ff       	call   801027a0 <kalloc>
80109176:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109179:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109180:	83 ec 04             	sub    $0x4,%esp
80109183:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109186:	50                   	push   %eax
80109187:	ff 75 f0             	push   -0x10(%ebp)
8010918a:	ff 75 f4             	push   -0xc(%ebp)
8010918d:	e8 1f 04 00 00       	call   801095b1 <arp_reply_pkt_create>
80109192:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109195:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109198:	83 ec 08             	sub    $0x8,%esp
8010919b:	50                   	push   %eax
8010919c:	ff 75 f0             	push   -0x10(%ebp)
8010919f:	e8 d0 fd ff ff       	call   80108f74 <i8254_send>
801091a4:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801091a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091aa:	83 ec 0c             	sub    $0xc,%esp
801091ad:	50                   	push   %eax
801091ae:	e8 53 95 ff ff       	call   80102706 <kfree>
801091b3:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801091b6:	b8 02 00 00 00       	mov    $0x2,%eax
801091bb:	eb 54                	jmp    80109211 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801091bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801091c4:	66 3d 00 02          	cmp    $0x200,%ax
801091c8:	75 42                	jne    8010920c <arp_proc+0x16c>
801091ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cd:	83 c0 18             	add    $0x18,%eax
801091d0:	83 ec 04             	sub    $0x4,%esp
801091d3:	6a 04                	push   $0x4
801091d5:	50                   	push   %eax
801091d6:	68 e4 f4 10 80       	push   $0x8010f4e4
801091db:	e8 1b bc ff ff       	call   80104dfb <memcmp>
801091e0:	83 c4 10             	add    $0x10,%esp
801091e3:	85 c0                	test   %eax,%eax
801091e5:	75 25                	jne    8010920c <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801091e7:	83 ec 0c             	sub    $0xc,%esp
801091ea:	68 7c c3 10 80       	push   $0x8010c37c
801091ef:	e8 00 72 ff ff       	call   801003f4 <cprintf>
801091f4:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801091f7:	83 ec 0c             	sub    $0xc,%esp
801091fa:	ff 75 f4             	push   -0xc(%ebp)
801091fd:	e8 af 01 00 00       	call   801093b1 <arp_table_update>
80109202:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109205:	b8 01 00 00 00       	mov    $0x1,%eax
8010920a:	eb 05                	jmp    80109211 <arp_proc+0x171>
  }else{
    return -1;
8010920c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109211:	c9                   	leave  
80109212:	c3                   	ret    

80109213 <arp_scan>:

void arp_scan(){
80109213:	55                   	push   %ebp
80109214:	89 e5                	mov    %esp,%ebp
80109216:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109219:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109220:	eb 6f                	jmp    80109291 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109222:	e8 79 95 ff ff       	call   801027a0 <kalloc>
80109227:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010922a:	83 ec 04             	sub    $0x4,%esp
8010922d:	ff 75 f4             	push   -0xc(%ebp)
80109230:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109233:	50                   	push   %eax
80109234:	ff 75 ec             	push   -0x14(%ebp)
80109237:	e8 62 00 00 00       	call   8010929e <arp_broadcast>
8010923c:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010923f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109242:	83 ec 08             	sub    $0x8,%esp
80109245:	50                   	push   %eax
80109246:	ff 75 ec             	push   -0x14(%ebp)
80109249:	e8 26 fd ff ff       	call   80108f74 <i8254_send>
8010924e:	83 c4 10             	add    $0x10,%esp
80109251:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109254:	eb 22                	jmp    80109278 <arp_scan+0x65>
      microdelay(1);
80109256:	83 ec 0c             	sub    $0xc,%esp
80109259:	6a 01                	push   $0x1
8010925b:	e8 d7 98 ff ff       	call   80102b37 <microdelay>
80109260:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109263:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109266:	83 ec 08             	sub    $0x8,%esp
80109269:	50                   	push   %eax
8010926a:	ff 75 ec             	push   -0x14(%ebp)
8010926d:	e8 02 fd ff ff       	call   80108f74 <i8254_send>
80109272:	83 c4 10             	add    $0x10,%esp
80109275:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109278:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010927c:	74 d8                	je     80109256 <arp_scan+0x43>
    }
    kfree((char *)send);
8010927e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109281:	83 ec 0c             	sub    $0xc,%esp
80109284:	50                   	push   %eax
80109285:	e8 7c 94 ff ff       	call   80102706 <kfree>
8010928a:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010928d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109291:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109298:	7e 88                	jle    80109222 <arp_scan+0xf>
  }
}
8010929a:	90                   	nop
8010929b:	90                   	nop
8010929c:	c9                   	leave  
8010929d:	c3                   	ret    

8010929e <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010929e:	55                   	push   %ebp
8010929f:	89 e5                	mov    %esp,%ebp
801092a1:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801092a4:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801092a8:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801092ac:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801092b0:	8b 45 10             	mov    0x10(%ebp),%eax
801092b3:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801092b6:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801092bd:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801092c3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801092ca:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801092d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801092d3:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801092d9:	8b 45 08             	mov    0x8(%ebp),%eax
801092dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801092df:	8b 45 08             	mov    0x8(%ebp),%eax
801092e2:	83 c0 0e             	add    $0xe,%eax
801092e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801092e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092eb:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801092ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f2:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801092f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f9:	83 ec 04             	sub    $0x4,%esp
801092fc:	6a 06                	push   $0x6
801092fe:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109301:	52                   	push   %edx
80109302:	50                   	push   %eax
80109303:	e8 4b bb ff ff       	call   80104e53 <memmove>
80109308:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010930b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930e:	83 c0 06             	add    $0x6,%eax
80109311:	83 ec 04             	sub    $0x4,%esp
80109314:	6a 06                	push   $0x6
80109316:	68 90 75 19 80       	push   $0x80197590
8010931b:	50                   	push   %eax
8010931c:	e8 32 bb ff ff       	call   80104e53 <memmove>
80109321:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109324:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109327:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010932c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010932f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109335:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109338:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010933c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010933f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109343:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109346:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010934c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010934f:	8d 50 12             	lea    0x12(%eax),%edx
80109352:	83 ec 04             	sub    $0x4,%esp
80109355:	6a 06                	push   $0x6
80109357:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010935a:	50                   	push   %eax
8010935b:	52                   	push   %edx
8010935c:	e8 f2 ba ff ff       	call   80104e53 <memmove>
80109361:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109364:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109367:	8d 50 18             	lea    0x18(%eax),%edx
8010936a:	83 ec 04             	sub    $0x4,%esp
8010936d:	6a 04                	push   $0x4
8010936f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109372:	50                   	push   %eax
80109373:	52                   	push   %edx
80109374:	e8 da ba ff ff       	call   80104e53 <memmove>
80109379:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010937c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010937f:	83 c0 08             	add    $0x8,%eax
80109382:	83 ec 04             	sub    $0x4,%esp
80109385:	6a 06                	push   $0x6
80109387:	68 90 75 19 80       	push   $0x80197590
8010938c:	50                   	push   %eax
8010938d:	e8 c1 ba ff ff       	call   80104e53 <memmove>
80109392:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109398:	83 c0 0e             	add    $0xe,%eax
8010939b:	83 ec 04             	sub    $0x4,%esp
8010939e:	6a 04                	push   $0x4
801093a0:	68 e4 f4 10 80       	push   $0x8010f4e4
801093a5:	50                   	push   %eax
801093a6:	e8 a8 ba ff ff       	call   80104e53 <memmove>
801093ab:	83 c4 10             	add    $0x10,%esp
}
801093ae:	90                   	nop
801093af:	c9                   	leave  
801093b0:	c3                   	ret    

801093b1 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801093b1:	55                   	push   %ebp
801093b2:	89 e5                	mov    %esp,%ebp
801093b4:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801093b7:	8b 45 08             	mov    0x8(%ebp),%eax
801093ba:	83 c0 0e             	add    $0xe,%eax
801093bd:	83 ec 0c             	sub    $0xc,%esp
801093c0:	50                   	push   %eax
801093c1:	e8 bc 00 00 00       	call   80109482 <arp_table_search>
801093c6:	83 c4 10             	add    $0x10,%esp
801093c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801093cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801093d0:	78 2d                	js     801093ff <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801093d2:	8b 45 08             	mov    0x8(%ebp),%eax
801093d5:	8d 48 08             	lea    0x8(%eax),%ecx
801093d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093db:	89 d0                	mov    %edx,%eax
801093dd:	c1 e0 02             	shl    $0x2,%eax
801093e0:	01 d0                	add    %edx,%eax
801093e2:	01 c0                	add    %eax,%eax
801093e4:	01 d0                	add    %edx,%eax
801093e6:	05 a0 75 19 80       	add    $0x801975a0,%eax
801093eb:	83 c0 04             	add    $0x4,%eax
801093ee:	83 ec 04             	sub    $0x4,%esp
801093f1:	6a 06                	push   $0x6
801093f3:	51                   	push   %ecx
801093f4:	50                   	push   %eax
801093f5:	e8 59 ba ff ff       	call   80104e53 <memmove>
801093fa:	83 c4 10             	add    $0x10,%esp
801093fd:	eb 70                	jmp    8010946f <arp_table_update+0xbe>
  }else{
    index += 1;
801093ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109403:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109406:	8b 45 08             	mov    0x8(%ebp),%eax
80109409:	8d 48 08             	lea    0x8(%eax),%ecx
8010940c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010940f:	89 d0                	mov    %edx,%eax
80109411:	c1 e0 02             	shl    $0x2,%eax
80109414:	01 d0                	add    %edx,%eax
80109416:	01 c0                	add    %eax,%eax
80109418:	01 d0                	add    %edx,%eax
8010941a:	05 a0 75 19 80       	add    $0x801975a0,%eax
8010941f:	83 c0 04             	add    $0x4,%eax
80109422:	83 ec 04             	sub    $0x4,%esp
80109425:	6a 06                	push   $0x6
80109427:	51                   	push   %ecx
80109428:	50                   	push   %eax
80109429:	e8 25 ba ff ff       	call   80104e53 <memmove>
8010942e:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109431:	8b 45 08             	mov    0x8(%ebp),%eax
80109434:	8d 48 0e             	lea    0xe(%eax),%ecx
80109437:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010943a:	89 d0                	mov    %edx,%eax
8010943c:	c1 e0 02             	shl    $0x2,%eax
8010943f:	01 d0                	add    %edx,%eax
80109441:	01 c0                	add    %eax,%eax
80109443:	01 d0                	add    %edx,%eax
80109445:	05 a0 75 19 80       	add    $0x801975a0,%eax
8010944a:	83 ec 04             	sub    $0x4,%esp
8010944d:	6a 04                	push   $0x4
8010944f:	51                   	push   %ecx
80109450:	50                   	push   %eax
80109451:	e8 fd b9 ff ff       	call   80104e53 <memmove>
80109456:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109459:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010945c:	89 d0                	mov    %edx,%eax
8010945e:	c1 e0 02             	shl    $0x2,%eax
80109461:	01 d0                	add    %edx,%eax
80109463:	01 c0                	add    %eax,%eax
80109465:	01 d0                	add    %edx,%eax
80109467:	05 aa 75 19 80       	add    $0x801975aa,%eax
8010946c:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010946f:	83 ec 0c             	sub    $0xc,%esp
80109472:	68 a0 75 19 80       	push   $0x801975a0
80109477:	e8 83 00 00 00       	call   801094ff <print_arp_table>
8010947c:	83 c4 10             	add    $0x10,%esp
}
8010947f:	90                   	nop
80109480:	c9                   	leave  
80109481:	c3                   	ret    

80109482 <arp_table_search>:

int arp_table_search(uchar *ip){
80109482:	55                   	push   %ebp
80109483:	89 e5                	mov    %esp,%ebp
80109485:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109488:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010948f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109496:	eb 59                	jmp    801094f1 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109498:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010949b:	89 d0                	mov    %edx,%eax
8010949d:	c1 e0 02             	shl    $0x2,%eax
801094a0:	01 d0                	add    %edx,%eax
801094a2:	01 c0                	add    %eax,%eax
801094a4:	01 d0                	add    %edx,%eax
801094a6:	05 a0 75 19 80       	add    $0x801975a0,%eax
801094ab:	83 ec 04             	sub    $0x4,%esp
801094ae:	6a 04                	push   $0x4
801094b0:	ff 75 08             	push   0x8(%ebp)
801094b3:	50                   	push   %eax
801094b4:	e8 42 b9 ff ff       	call   80104dfb <memcmp>
801094b9:	83 c4 10             	add    $0x10,%esp
801094bc:	85 c0                	test   %eax,%eax
801094be:	75 05                	jne    801094c5 <arp_table_search+0x43>
      return i;
801094c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094c3:	eb 38                	jmp    801094fd <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801094c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801094c8:	89 d0                	mov    %edx,%eax
801094ca:	c1 e0 02             	shl    $0x2,%eax
801094cd:	01 d0                	add    %edx,%eax
801094cf:	01 c0                	add    %eax,%eax
801094d1:	01 d0                	add    %edx,%eax
801094d3:	05 aa 75 19 80       	add    $0x801975aa,%eax
801094d8:	0f b6 00             	movzbl (%eax),%eax
801094db:	84 c0                	test   %al,%al
801094dd:	75 0e                	jne    801094ed <arp_table_search+0x6b>
801094df:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801094e3:	75 08                	jne    801094ed <arp_table_search+0x6b>
      empty = -i;
801094e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094e8:	f7 d8                	neg    %eax
801094ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801094ed:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801094f1:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801094f5:	7e a1                	jle    80109498 <arp_table_search+0x16>
    }
  }
  return empty-1;
801094f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094fa:	83 e8 01             	sub    $0x1,%eax
}
801094fd:	c9                   	leave  
801094fe:	c3                   	ret    

801094ff <print_arp_table>:

void print_arp_table(){
801094ff:	55                   	push   %ebp
80109500:	89 e5                	mov    %esp,%ebp
80109502:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109505:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010950c:	e9 92 00 00 00       	jmp    801095a3 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109511:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109514:	89 d0                	mov    %edx,%eax
80109516:	c1 e0 02             	shl    $0x2,%eax
80109519:	01 d0                	add    %edx,%eax
8010951b:	01 c0                	add    %eax,%eax
8010951d:	01 d0                	add    %edx,%eax
8010951f:	05 aa 75 19 80       	add    $0x801975aa,%eax
80109524:	0f b6 00             	movzbl (%eax),%eax
80109527:	84 c0                	test   %al,%al
80109529:	74 74                	je     8010959f <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010952b:	83 ec 08             	sub    $0x8,%esp
8010952e:	ff 75 f4             	push   -0xc(%ebp)
80109531:	68 8f c3 10 80       	push   $0x8010c38f
80109536:	e8 b9 6e ff ff       	call   801003f4 <cprintf>
8010953b:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010953e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109541:	89 d0                	mov    %edx,%eax
80109543:	c1 e0 02             	shl    $0x2,%eax
80109546:	01 d0                	add    %edx,%eax
80109548:	01 c0                	add    %eax,%eax
8010954a:	01 d0                	add    %edx,%eax
8010954c:	05 a0 75 19 80       	add    $0x801975a0,%eax
80109551:	83 ec 0c             	sub    $0xc,%esp
80109554:	50                   	push   %eax
80109555:	e8 54 02 00 00       	call   801097ae <print_ipv4>
8010955a:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010955d:	83 ec 0c             	sub    $0xc,%esp
80109560:	68 9e c3 10 80       	push   $0x8010c39e
80109565:	e8 8a 6e ff ff       	call   801003f4 <cprintf>
8010956a:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010956d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109570:	89 d0                	mov    %edx,%eax
80109572:	c1 e0 02             	shl    $0x2,%eax
80109575:	01 d0                	add    %edx,%eax
80109577:	01 c0                	add    %eax,%eax
80109579:	01 d0                	add    %edx,%eax
8010957b:	05 a0 75 19 80       	add    $0x801975a0,%eax
80109580:	83 c0 04             	add    $0x4,%eax
80109583:	83 ec 0c             	sub    $0xc,%esp
80109586:	50                   	push   %eax
80109587:	e8 70 02 00 00       	call   801097fc <print_mac>
8010958c:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010958f:	83 ec 0c             	sub    $0xc,%esp
80109592:	68 a0 c3 10 80       	push   $0x8010c3a0
80109597:	e8 58 6e ff ff       	call   801003f4 <cprintf>
8010959c:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010959f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801095a3:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801095a7:	0f 8e 64 ff ff ff    	jle    80109511 <print_arp_table+0x12>
    }
  }
}
801095ad:	90                   	nop
801095ae:	90                   	nop
801095af:	c9                   	leave  
801095b0:	c3                   	ret    

801095b1 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801095b1:	55                   	push   %ebp
801095b2:	89 e5                	mov    %esp,%ebp
801095b4:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801095b7:	8b 45 10             	mov    0x10(%ebp),%eax
801095ba:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801095c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801095c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801095c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801095c9:	83 c0 0e             	add    $0xe,%eax
801095cc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801095cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d2:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801095d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d9:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801095dd:	8b 45 08             	mov    0x8(%ebp),%eax
801095e0:	8d 50 08             	lea    0x8(%eax),%edx
801095e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e6:	83 ec 04             	sub    $0x4,%esp
801095e9:	6a 06                	push   $0x6
801095eb:	52                   	push   %edx
801095ec:	50                   	push   %eax
801095ed:	e8 61 b8 ff ff       	call   80104e53 <memmove>
801095f2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801095f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f8:	83 c0 06             	add    $0x6,%eax
801095fb:	83 ec 04             	sub    $0x4,%esp
801095fe:	6a 06                	push   $0x6
80109600:	68 90 75 19 80       	push   $0x80197590
80109605:	50                   	push   %eax
80109606:	e8 48 b8 ff ff       	call   80104e53 <memmove>
8010960b:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010960e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109611:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109619:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010961f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109622:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109629:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010962d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109630:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109636:	8b 45 08             	mov    0x8(%ebp),%eax
80109639:	8d 50 08             	lea    0x8(%eax),%edx
8010963c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010963f:	83 c0 12             	add    $0x12,%eax
80109642:	83 ec 04             	sub    $0x4,%esp
80109645:	6a 06                	push   $0x6
80109647:	52                   	push   %edx
80109648:	50                   	push   %eax
80109649:	e8 05 b8 ff ff       	call   80104e53 <memmove>
8010964e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109651:	8b 45 08             	mov    0x8(%ebp),%eax
80109654:	8d 50 0e             	lea    0xe(%eax),%edx
80109657:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010965a:	83 c0 18             	add    $0x18,%eax
8010965d:	83 ec 04             	sub    $0x4,%esp
80109660:	6a 04                	push   $0x4
80109662:	52                   	push   %edx
80109663:	50                   	push   %eax
80109664:	e8 ea b7 ff ff       	call   80104e53 <memmove>
80109669:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010966c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010966f:	83 c0 08             	add    $0x8,%eax
80109672:	83 ec 04             	sub    $0x4,%esp
80109675:	6a 06                	push   $0x6
80109677:	68 90 75 19 80       	push   $0x80197590
8010967c:	50                   	push   %eax
8010967d:	e8 d1 b7 ff ff       	call   80104e53 <memmove>
80109682:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109688:	83 c0 0e             	add    $0xe,%eax
8010968b:	83 ec 04             	sub    $0x4,%esp
8010968e:	6a 04                	push   $0x4
80109690:	68 e4 f4 10 80       	push   $0x8010f4e4
80109695:	50                   	push   %eax
80109696:	e8 b8 b7 ff ff       	call   80104e53 <memmove>
8010969b:	83 c4 10             	add    $0x10,%esp
}
8010969e:	90                   	nop
8010969f:	c9                   	leave  
801096a0:	c3                   	ret    

801096a1 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801096a1:	55                   	push   %ebp
801096a2:	89 e5                	mov    %esp,%ebp
801096a4:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801096a7:	83 ec 0c             	sub    $0xc,%esp
801096aa:	68 a2 c3 10 80       	push   $0x8010c3a2
801096af:	e8 40 6d ff ff       	call   801003f4 <cprintf>
801096b4:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801096b7:	8b 45 08             	mov    0x8(%ebp),%eax
801096ba:	83 c0 0e             	add    $0xe,%eax
801096bd:	83 ec 0c             	sub    $0xc,%esp
801096c0:	50                   	push   %eax
801096c1:	e8 e8 00 00 00       	call   801097ae <print_ipv4>
801096c6:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096c9:	83 ec 0c             	sub    $0xc,%esp
801096cc:	68 a0 c3 10 80       	push   $0x8010c3a0
801096d1:	e8 1e 6d ff ff       	call   801003f4 <cprintf>
801096d6:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801096d9:	8b 45 08             	mov    0x8(%ebp),%eax
801096dc:	83 c0 08             	add    $0x8,%eax
801096df:	83 ec 0c             	sub    $0xc,%esp
801096e2:	50                   	push   %eax
801096e3:	e8 14 01 00 00       	call   801097fc <print_mac>
801096e8:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096eb:	83 ec 0c             	sub    $0xc,%esp
801096ee:	68 a0 c3 10 80       	push   $0x8010c3a0
801096f3:	e8 fc 6c ff ff       	call   801003f4 <cprintf>
801096f8:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801096fb:	83 ec 0c             	sub    $0xc,%esp
801096fe:	68 b9 c3 10 80       	push   $0x8010c3b9
80109703:	e8 ec 6c ff ff       	call   801003f4 <cprintf>
80109708:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010970b:	8b 45 08             	mov    0x8(%ebp),%eax
8010970e:	83 c0 18             	add    $0x18,%eax
80109711:	83 ec 0c             	sub    $0xc,%esp
80109714:	50                   	push   %eax
80109715:	e8 94 00 00 00       	call   801097ae <print_ipv4>
8010971a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010971d:	83 ec 0c             	sub    $0xc,%esp
80109720:	68 a0 c3 10 80       	push   $0x8010c3a0
80109725:	e8 ca 6c ff ff       	call   801003f4 <cprintf>
8010972a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010972d:	8b 45 08             	mov    0x8(%ebp),%eax
80109730:	83 c0 12             	add    $0x12,%eax
80109733:	83 ec 0c             	sub    $0xc,%esp
80109736:	50                   	push   %eax
80109737:	e8 c0 00 00 00       	call   801097fc <print_mac>
8010973c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010973f:	83 ec 0c             	sub    $0xc,%esp
80109742:	68 a0 c3 10 80       	push   $0x8010c3a0
80109747:	e8 a8 6c ff ff       	call   801003f4 <cprintf>
8010974c:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010974f:	83 ec 0c             	sub    $0xc,%esp
80109752:	68 d0 c3 10 80       	push   $0x8010c3d0
80109757:	e8 98 6c ff ff       	call   801003f4 <cprintf>
8010975c:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010975f:	8b 45 08             	mov    0x8(%ebp),%eax
80109762:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109766:	66 3d 00 01          	cmp    $0x100,%ax
8010976a:	75 12                	jne    8010977e <print_arp_info+0xdd>
8010976c:	83 ec 0c             	sub    $0xc,%esp
8010976f:	68 dc c3 10 80       	push   $0x8010c3dc
80109774:	e8 7b 6c ff ff       	call   801003f4 <cprintf>
80109779:	83 c4 10             	add    $0x10,%esp
8010977c:	eb 1d                	jmp    8010979b <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010977e:	8b 45 08             	mov    0x8(%ebp),%eax
80109781:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109785:	66 3d 00 02          	cmp    $0x200,%ax
80109789:	75 10                	jne    8010979b <print_arp_info+0xfa>
    cprintf("Reply\n");
8010978b:	83 ec 0c             	sub    $0xc,%esp
8010978e:	68 e5 c3 10 80       	push   $0x8010c3e5
80109793:	e8 5c 6c ff ff       	call   801003f4 <cprintf>
80109798:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010979b:	83 ec 0c             	sub    $0xc,%esp
8010979e:	68 a0 c3 10 80       	push   $0x8010c3a0
801097a3:	e8 4c 6c ff ff       	call   801003f4 <cprintf>
801097a8:	83 c4 10             	add    $0x10,%esp
}
801097ab:	90                   	nop
801097ac:	c9                   	leave  
801097ad:	c3                   	ret    

801097ae <print_ipv4>:

void print_ipv4(uchar *ip){
801097ae:	55                   	push   %ebp
801097af:	89 e5                	mov    %esp,%ebp
801097b1:	53                   	push   %ebx
801097b2:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801097b5:	8b 45 08             	mov    0x8(%ebp),%eax
801097b8:	83 c0 03             	add    $0x3,%eax
801097bb:	0f b6 00             	movzbl (%eax),%eax
801097be:	0f b6 d8             	movzbl %al,%ebx
801097c1:	8b 45 08             	mov    0x8(%ebp),%eax
801097c4:	83 c0 02             	add    $0x2,%eax
801097c7:	0f b6 00             	movzbl (%eax),%eax
801097ca:	0f b6 c8             	movzbl %al,%ecx
801097cd:	8b 45 08             	mov    0x8(%ebp),%eax
801097d0:	83 c0 01             	add    $0x1,%eax
801097d3:	0f b6 00             	movzbl (%eax),%eax
801097d6:	0f b6 d0             	movzbl %al,%edx
801097d9:	8b 45 08             	mov    0x8(%ebp),%eax
801097dc:	0f b6 00             	movzbl (%eax),%eax
801097df:	0f b6 c0             	movzbl %al,%eax
801097e2:	83 ec 0c             	sub    $0xc,%esp
801097e5:	53                   	push   %ebx
801097e6:	51                   	push   %ecx
801097e7:	52                   	push   %edx
801097e8:	50                   	push   %eax
801097e9:	68 ec c3 10 80       	push   $0x8010c3ec
801097ee:	e8 01 6c ff ff       	call   801003f4 <cprintf>
801097f3:	83 c4 20             	add    $0x20,%esp
}
801097f6:	90                   	nop
801097f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801097fa:	c9                   	leave  
801097fb:	c3                   	ret    

801097fc <print_mac>:

void print_mac(uchar *mac){
801097fc:	55                   	push   %ebp
801097fd:	89 e5                	mov    %esp,%ebp
801097ff:	57                   	push   %edi
80109800:	56                   	push   %esi
80109801:	53                   	push   %ebx
80109802:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109805:	8b 45 08             	mov    0x8(%ebp),%eax
80109808:	83 c0 05             	add    $0x5,%eax
8010980b:	0f b6 00             	movzbl (%eax),%eax
8010980e:	0f b6 f8             	movzbl %al,%edi
80109811:	8b 45 08             	mov    0x8(%ebp),%eax
80109814:	83 c0 04             	add    $0x4,%eax
80109817:	0f b6 00             	movzbl (%eax),%eax
8010981a:	0f b6 f0             	movzbl %al,%esi
8010981d:	8b 45 08             	mov    0x8(%ebp),%eax
80109820:	83 c0 03             	add    $0x3,%eax
80109823:	0f b6 00             	movzbl (%eax),%eax
80109826:	0f b6 d8             	movzbl %al,%ebx
80109829:	8b 45 08             	mov    0x8(%ebp),%eax
8010982c:	83 c0 02             	add    $0x2,%eax
8010982f:	0f b6 00             	movzbl (%eax),%eax
80109832:	0f b6 c8             	movzbl %al,%ecx
80109835:	8b 45 08             	mov    0x8(%ebp),%eax
80109838:	83 c0 01             	add    $0x1,%eax
8010983b:	0f b6 00             	movzbl (%eax),%eax
8010983e:	0f b6 d0             	movzbl %al,%edx
80109841:	8b 45 08             	mov    0x8(%ebp),%eax
80109844:	0f b6 00             	movzbl (%eax),%eax
80109847:	0f b6 c0             	movzbl %al,%eax
8010984a:	83 ec 04             	sub    $0x4,%esp
8010984d:	57                   	push   %edi
8010984e:	56                   	push   %esi
8010984f:	53                   	push   %ebx
80109850:	51                   	push   %ecx
80109851:	52                   	push   %edx
80109852:	50                   	push   %eax
80109853:	68 04 c4 10 80       	push   $0x8010c404
80109858:	e8 97 6b ff ff       	call   801003f4 <cprintf>
8010985d:	83 c4 20             	add    $0x20,%esp
}
80109860:	90                   	nop
80109861:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109864:	5b                   	pop    %ebx
80109865:	5e                   	pop    %esi
80109866:	5f                   	pop    %edi
80109867:	5d                   	pop    %ebp
80109868:	c3                   	ret    

80109869 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109869:	55                   	push   %ebp
8010986a:	89 e5                	mov    %esp,%ebp
8010986c:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010986f:	8b 45 08             	mov    0x8(%ebp),%eax
80109872:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109875:	8b 45 08             	mov    0x8(%ebp),%eax
80109878:	83 c0 0e             	add    $0xe,%eax
8010987b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010987e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109881:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109885:	3c 08                	cmp    $0x8,%al
80109887:	75 1b                	jne    801098a4 <eth_proc+0x3b>
80109889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010988c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109890:	3c 06                	cmp    $0x6,%al
80109892:	75 10                	jne    801098a4 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109894:	83 ec 0c             	sub    $0xc,%esp
80109897:	ff 75 f0             	push   -0x10(%ebp)
8010989a:	e8 01 f8 ff ff       	call   801090a0 <arp_proc>
8010989f:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801098a2:	eb 24                	jmp    801098c8 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801098a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098a7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801098ab:	3c 08                	cmp    $0x8,%al
801098ad:	75 19                	jne    801098c8 <eth_proc+0x5f>
801098af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098b6:	84 c0                	test   %al,%al
801098b8:	75 0e                	jne    801098c8 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801098ba:	83 ec 0c             	sub    $0xc,%esp
801098bd:	ff 75 08             	push   0x8(%ebp)
801098c0:	e8 a3 00 00 00       	call   80109968 <ipv4_proc>
801098c5:	83 c4 10             	add    $0x10,%esp
}
801098c8:	90                   	nop
801098c9:	c9                   	leave  
801098ca:	c3                   	ret    

801098cb <N2H_ushort>:

ushort N2H_ushort(ushort value){
801098cb:	55                   	push   %ebp
801098cc:	89 e5                	mov    %esp,%ebp
801098ce:	83 ec 04             	sub    $0x4,%esp
801098d1:	8b 45 08             	mov    0x8(%ebp),%eax
801098d4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801098d8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098dc:	c1 e0 08             	shl    $0x8,%eax
801098df:	89 c2                	mov    %eax,%edx
801098e1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098e5:	66 c1 e8 08          	shr    $0x8,%ax
801098e9:	01 d0                	add    %edx,%eax
}
801098eb:	c9                   	leave  
801098ec:	c3                   	ret    

801098ed <H2N_ushort>:

ushort H2N_ushort(ushort value){
801098ed:	55                   	push   %ebp
801098ee:	89 e5                	mov    %esp,%ebp
801098f0:	83 ec 04             	sub    $0x4,%esp
801098f3:	8b 45 08             	mov    0x8(%ebp),%eax
801098f6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801098fa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098fe:	c1 e0 08             	shl    $0x8,%eax
80109901:	89 c2                	mov    %eax,%edx
80109903:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109907:	66 c1 e8 08          	shr    $0x8,%ax
8010990b:	01 d0                	add    %edx,%eax
}
8010990d:	c9                   	leave  
8010990e:	c3                   	ret    

8010990f <H2N_uint>:

uint H2N_uint(uint value){
8010990f:	55                   	push   %ebp
80109910:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109912:	8b 45 08             	mov    0x8(%ebp),%eax
80109915:	c1 e0 18             	shl    $0x18,%eax
80109918:	25 00 00 00 0f       	and    $0xf000000,%eax
8010991d:	89 c2                	mov    %eax,%edx
8010991f:	8b 45 08             	mov    0x8(%ebp),%eax
80109922:	c1 e0 08             	shl    $0x8,%eax
80109925:	25 00 f0 00 00       	and    $0xf000,%eax
8010992a:	09 c2                	or     %eax,%edx
8010992c:	8b 45 08             	mov    0x8(%ebp),%eax
8010992f:	c1 e8 08             	shr    $0x8,%eax
80109932:	83 e0 0f             	and    $0xf,%eax
80109935:	01 d0                	add    %edx,%eax
}
80109937:	5d                   	pop    %ebp
80109938:	c3                   	ret    

80109939 <N2H_uint>:

uint N2H_uint(uint value){
80109939:	55                   	push   %ebp
8010993a:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010993c:	8b 45 08             	mov    0x8(%ebp),%eax
8010993f:	c1 e0 18             	shl    $0x18,%eax
80109942:	89 c2                	mov    %eax,%edx
80109944:	8b 45 08             	mov    0x8(%ebp),%eax
80109947:	c1 e0 08             	shl    $0x8,%eax
8010994a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010994f:	01 c2                	add    %eax,%edx
80109951:	8b 45 08             	mov    0x8(%ebp),%eax
80109954:	c1 e8 08             	shr    $0x8,%eax
80109957:	25 00 ff 00 00       	and    $0xff00,%eax
8010995c:	01 c2                	add    %eax,%edx
8010995e:	8b 45 08             	mov    0x8(%ebp),%eax
80109961:	c1 e8 18             	shr    $0x18,%eax
80109964:	01 d0                	add    %edx,%eax
}
80109966:	5d                   	pop    %ebp
80109967:	c3                   	ret    

80109968 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109968:	55                   	push   %ebp
80109969:	89 e5                	mov    %esp,%ebp
8010996b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010996e:	8b 45 08             	mov    0x8(%ebp),%eax
80109971:	83 c0 0e             	add    $0xe,%eax
80109974:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010997a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010997e:	0f b7 d0             	movzwl %ax,%edx
80109981:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109986:	39 c2                	cmp    %eax,%edx
80109988:	74 60                	je     801099ea <ipv4_proc+0x82>
8010998a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010998d:	83 c0 0c             	add    $0xc,%eax
80109990:	83 ec 04             	sub    $0x4,%esp
80109993:	6a 04                	push   $0x4
80109995:	50                   	push   %eax
80109996:	68 e4 f4 10 80       	push   $0x8010f4e4
8010999b:	e8 5b b4 ff ff       	call   80104dfb <memcmp>
801099a0:	83 c4 10             	add    $0x10,%esp
801099a3:	85 c0                	test   %eax,%eax
801099a5:	74 43                	je     801099ea <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801099a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099aa:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801099ae:	0f b7 c0             	movzwl %ax,%eax
801099b1:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801099b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801099bd:	3c 01                	cmp    $0x1,%al
801099bf:	75 10                	jne    801099d1 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801099c1:	83 ec 0c             	sub    $0xc,%esp
801099c4:	ff 75 08             	push   0x8(%ebp)
801099c7:	e8 a3 00 00 00       	call   80109a6f <icmp_proc>
801099cc:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801099cf:	eb 19                	jmp    801099ea <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801099d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801099d8:	3c 06                	cmp    $0x6,%al
801099da:	75 0e                	jne    801099ea <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801099dc:	83 ec 0c             	sub    $0xc,%esp
801099df:	ff 75 08             	push   0x8(%ebp)
801099e2:	e8 b3 03 00 00       	call   80109d9a <tcp_proc>
801099e7:	83 c4 10             	add    $0x10,%esp
}
801099ea:	90                   	nop
801099eb:	c9                   	leave  
801099ec:	c3                   	ret    

801099ed <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801099ed:	55                   	push   %ebp
801099ee:	89 e5                	mov    %esp,%ebp
801099f0:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801099f3:	8b 45 08             	mov    0x8(%ebp),%eax
801099f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801099f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099fc:	0f b6 00             	movzbl (%eax),%eax
801099ff:	83 e0 0f             	and    $0xf,%eax
80109a02:	01 c0                	add    %eax,%eax
80109a04:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109a07:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a0e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109a15:	eb 48                	jmp    80109a5f <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109a17:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a1a:	01 c0                	add    %eax,%eax
80109a1c:	89 c2                	mov    %eax,%edx
80109a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a21:	01 d0                	add    %edx,%eax
80109a23:	0f b6 00             	movzbl (%eax),%eax
80109a26:	0f b6 c0             	movzbl %al,%eax
80109a29:	c1 e0 08             	shl    $0x8,%eax
80109a2c:	89 c2                	mov    %eax,%edx
80109a2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a31:	01 c0                	add    %eax,%eax
80109a33:	8d 48 01             	lea    0x1(%eax),%ecx
80109a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a39:	01 c8                	add    %ecx,%eax
80109a3b:	0f b6 00             	movzbl (%eax),%eax
80109a3e:	0f b6 c0             	movzbl %al,%eax
80109a41:	01 d0                	add    %edx,%eax
80109a43:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109a46:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109a4d:	76 0c                	jbe    80109a5b <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109a4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a52:	0f b7 c0             	movzwl %ax,%eax
80109a55:	83 c0 01             	add    $0x1,%eax
80109a58:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a5b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109a5f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109a63:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109a66:	7c af                	jl     80109a17 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109a68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a6b:	f7 d0                	not    %eax
}
80109a6d:	c9                   	leave  
80109a6e:	c3                   	ret    

80109a6f <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109a6f:	55                   	push   %ebp
80109a70:	89 e5                	mov    %esp,%ebp
80109a72:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109a75:	8b 45 08             	mov    0x8(%ebp),%eax
80109a78:	83 c0 0e             	add    $0xe,%eax
80109a7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a81:	0f b6 00             	movzbl (%eax),%eax
80109a84:	0f b6 c0             	movzbl %al,%eax
80109a87:	83 e0 0f             	and    $0xf,%eax
80109a8a:	c1 e0 02             	shl    $0x2,%eax
80109a8d:	89 c2                	mov    %eax,%edx
80109a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a92:	01 d0                	add    %edx,%eax
80109a94:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109a97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a9a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109a9e:	84 c0                	test   %al,%al
80109aa0:	75 4f                	jne    80109af1 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa5:	0f b6 00             	movzbl (%eax),%eax
80109aa8:	3c 08                	cmp    $0x8,%al
80109aaa:	75 45                	jne    80109af1 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109aac:	e8 ef 8c ff ff       	call   801027a0 <kalloc>
80109ab1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109ab4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109abb:	83 ec 04             	sub    $0x4,%esp
80109abe:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109ac1:	50                   	push   %eax
80109ac2:	ff 75 ec             	push   -0x14(%ebp)
80109ac5:	ff 75 08             	push   0x8(%ebp)
80109ac8:	e8 78 00 00 00       	call   80109b45 <icmp_reply_pkt_create>
80109acd:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109ad0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ad3:	83 ec 08             	sub    $0x8,%esp
80109ad6:	50                   	push   %eax
80109ad7:	ff 75 ec             	push   -0x14(%ebp)
80109ada:	e8 95 f4 ff ff       	call   80108f74 <i8254_send>
80109adf:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109ae2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ae5:	83 ec 0c             	sub    $0xc,%esp
80109ae8:	50                   	push   %eax
80109ae9:	e8 18 8c ff ff       	call   80102706 <kfree>
80109aee:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109af1:	90                   	nop
80109af2:	c9                   	leave  
80109af3:	c3                   	ret    

80109af4 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109af4:	55                   	push   %ebp
80109af5:	89 e5                	mov    %esp,%ebp
80109af7:	53                   	push   %ebx
80109af8:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109afb:	8b 45 08             	mov    0x8(%ebp),%eax
80109afe:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b02:	0f b7 c0             	movzwl %ax,%eax
80109b05:	83 ec 0c             	sub    $0xc,%esp
80109b08:	50                   	push   %eax
80109b09:	e8 bd fd ff ff       	call   801098cb <N2H_ushort>
80109b0e:	83 c4 10             	add    $0x10,%esp
80109b11:	0f b7 d8             	movzwl %ax,%ebx
80109b14:	8b 45 08             	mov    0x8(%ebp),%eax
80109b17:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b1b:	0f b7 c0             	movzwl %ax,%eax
80109b1e:	83 ec 0c             	sub    $0xc,%esp
80109b21:	50                   	push   %eax
80109b22:	e8 a4 fd ff ff       	call   801098cb <N2H_ushort>
80109b27:	83 c4 10             	add    $0x10,%esp
80109b2a:	0f b7 c0             	movzwl %ax,%eax
80109b2d:	83 ec 04             	sub    $0x4,%esp
80109b30:	53                   	push   %ebx
80109b31:	50                   	push   %eax
80109b32:	68 23 c4 10 80       	push   $0x8010c423
80109b37:	e8 b8 68 ff ff       	call   801003f4 <cprintf>
80109b3c:	83 c4 10             	add    $0x10,%esp
}
80109b3f:	90                   	nop
80109b40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b43:	c9                   	leave  
80109b44:	c3                   	ret    

80109b45 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109b45:	55                   	push   %ebp
80109b46:	89 e5                	mov    %esp,%ebp
80109b48:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109b51:	8b 45 08             	mov    0x8(%ebp),%eax
80109b54:	83 c0 0e             	add    $0xe,%eax
80109b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b5d:	0f b6 00             	movzbl (%eax),%eax
80109b60:	0f b6 c0             	movzbl %al,%eax
80109b63:	83 e0 0f             	and    $0xf,%eax
80109b66:	c1 e0 02             	shl    $0x2,%eax
80109b69:	89 c2                	mov    %eax,%edx
80109b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b6e:	01 d0                	add    %edx,%eax
80109b70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b73:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b76:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109b79:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b7c:	83 c0 0e             	add    $0xe,%eax
80109b7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109b82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b85:	83 c0 14             	add    $0x14,%eax
80109b88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109b8b:	8b 45 10             	mov    0x10(%ebp),%eax
80109b8e:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b97:	8d 50 06             	lea    0x6(%eax),%edx
80109b9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b9d:	83 ec 04             	sub    $0x4,%esp
80109ba0:	6a 06                	push   $0x6
80109ba2:	52                   	push   %edx
80109ba3:	50                   	push   %eax
80109ba4:	e8 aa b2 ff ff       	call   80104e53 <memmove>
80109ba9:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109bac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109baf:	83 c0 06             	add    $0x6,%eax
80109bb2:	83 ec 04             	sub    $0x4,%esp
80109bb5:	6a 06                	push   $0x6
80109bb7:	68 90 75 19 80       	push   $0x80197590
80109bbc:	50                   	push   %eax
80109bbd:	e8 91 b2 ff ff       	call   80104e53 <memmove>
80109bc2:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109bc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bc8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109bcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bcf:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109bd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd6:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bdc:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109be0:	83 ec 0c             	sub    $0xc,%esp
80109be3:	6a 54                	push   $0x54
80109be5:	e8 03 fd ff ff       	call   801098ed <H2N_ushort>
80109bea:	83 c4 10             	add    $0x10,%esp
80109bed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bf0:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109bf4:	0f b7 15 60 78 19 80 	movzwl 0x80197860,%edx
80109bfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bfe:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c02:	0f b7 05 60 78 19 80 	movzwl 0x80197860,%eax
80109c09:	83 c0 01             	add    $0x1,%eax
80109c0c:	66 a3 60 78 19 80    	mov    %ax,0x80197860
  ipv4_send->fragment = H2N_ushort(0x4000);
80109c12:	83 ec 0c             	sub    $0xc,%esp
80109c15:	68 00 40 00 00       	push   $0x4000
80109c1a:	e8 ce fc ff ff       	call   801098ed <H2N_ushort>
80109c1f:	83 c4 10             	add    $0x10,%esp
80109c22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c25:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c2c:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109c30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c33:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109c37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c3a:	83 c0 0c             	add    $0xc,%eax
80109c3d:	83 ec 04             	sub    $0x4,%esp
80109c40:	6a 04                	push   $0x4
80109c42:	68 e4 f4 10 80       	push   $0x8010f4e4
80109c47:	50                   	push   %eax
80109c48:	e8 06 b2 ff ff       	call   80104e53 <memmove>
80109c4d:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c53:	8d 50 0c             	lea    0xc(%eax),%edx
80109c56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c59:	83 c0 10             	add    $0x10,%eax
80109c5c:	83 ec 04             	sub    $0x4,%esp
80109c5f:	6a 04                	push   $0x4
80109c61:	52                   	push   %edx
80109c62:	50                   	push   %eax
80109c63:	e8 eb b1 ff ff       	call   80104e53 <memmove>
80109c68:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c6e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c77:	83 ec 0c             	sub    $0xc,%esp
80109c7a:	50                   	push   %eax
80109c7b:	e8 6d fd ff ff       	call   801099ed <ipv4_chksum>
80109c80:	83 c4 10             	add    $0x10,%esp
80109c83:	0f b7 c0             	movzwl %ax,%eax
80109c86:	83 ec 0c             	sub    $0xc,%esp
80109c89:	50                   	push   %eax
80109c8a:	e8 5e fc ff ff       	call   801098ed <H2N_ushort>
80109c8f:	83 c4 10             	add    $0x10,%esp
80109c92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c95:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109c99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c9c:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109c9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ca2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ca9:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109cad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cb0:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109cb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cb7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109cbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cbe:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109cc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cc5:	8d 50 08             	lea    0x8(%eax),%edx
80109cc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ccb:	83 c0 08             	add    $0x8,%eax
80109cce:	83 ec 04             	sub    $0x4,%esp
80109cd1:	6a 08                	push   $0x8
80109cd3:	52                   	push   %edx
80109cd4:	50                   	push   %eax
80109cd5:	e8 79 b1 ff ff       	call   80104e53 <memmove>
80109cda:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109cdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ce0:	8d 50 10             	lea    0x10(%eax),%edx
80109ce3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ce6:	83 c0 10             	add    $0x10,%eax
80109ce9:	83 ec 04             	sub    $0x4,%esp
80109cec:	6a 30                	push   $0x30
80109cee:	52                   	push   %edx
80109cef:	50                   	push   %eax
80109cf0:	e8 5e b1 ff ff       	call   80104e53 <memmove>
80109cf5:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109cf8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cfb:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d04:	83 ec 0c             	sub    $0xc,%esp
80109d07:	50                   	push   %eax
80109d08:	e8 1c 00 00 00       	call   80109d29 <icmp_chksum>
80109d0d:	83 c4 10             	add    $0x10,%esp
80109d10:	0f b7 c0             	movzwl %ax,%eax
80109d13:	83 ec 0c             	sub    $0xc,%esp
80109d16:	50                   	push   %eax
80109d17:	e8 d1 fb ff ff       	call   801098ed <H2N_ushort>
80109d1c:	83 c4 10             	add    $0x10,%esp
80109d1f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d22:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109d26:	90                   	nop
80109d27:	c9                   	leave  
80109d28:	c3                   	ret    

80109d29 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109d29:	55                   	push   %ebp
80109d2a:	89 e5                	mov    %esp,%ebp
80109d2c:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80109d32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109d35:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d3c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109d43:	eb 48                	jmp    80109d8d <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d45:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d48:	01 c0                	add    %eax,%eax
80109d4a:	89 c2                	mov    %eax,%edx
80109d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d4f:	01 d0                	add    %edx,%eax
80109d51:	0f b6 00             	movzbl (%eax),%eax
80109d54:	0f b6 c0             	movzbl %al,%eax
80109d57:	c1 e0 08             	shl    $0x8,%eax
80109d5a:	89 c2                	mov    %eax,%edx
80109d5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d5f:	01 c0                	add    %eax,%eax
80109d61:	8d 48 01             	lea    0x1(%eax),%ecx
80109d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d67:	01 c8                	add    %ecx,%eax
80109d69:	0f b6 00             	movzbl (%eax),%eax
80109d6c:	0f b6 c0             	movzbl %al,%eax
80109d6f:	01 d0                	add    %edx,%eax
80109d71:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d74:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d7b:	76 0c                	jbe    80109d89 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d80:	0f b7 c0             	movzwl %ax,%eax
80109d83:	83 c0 01             	add    $0x1,%eax
80109d86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d89:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d8d:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109d91:	7e b2                	jle    80109d45 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109d93:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d96:	f7 d0                	not    %eax
}
80109d98:	c9                   	leave  
80109d99:	c3                   	ret    

80109d9a <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109d9a:	55                   	push   %ebp
80109d9b:	89 e5                	mov    %esp,%ebp
80109d9d:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109da0:	8b 45 08             	mov    0x8(%ebp),%eax
80109da3:	83 c0 0e             	add    $0xe,%eax
80109da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dac:	0f b6 00             	movzbl (%eax),%eax
80109daf:	0f b6 c0             	movzbl %al,%eax
80109db2:	83 e0 0f             	and    $0xf,%eax
80109db5:	c1 e0 02             	shl    $0x2,%eax
80109db8:	89 c2                	mov    %eax,%edx
80109dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dbd:	01 d0                	add    %edx,%eax
80109dbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dc5:	83 c0 14             	add    $0x14,%eax
80109dc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109dcb:	e8 d0 89 ff ff       	call   801027a0 <kalloc>
80109dd0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109dd3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ddd:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109de1:	0f b6 c0             	movzbl %al,%eax
80109de4:	83 e0 02             	and    $0x2,%eax
80109de7:	85 c0                	test   %eax,%eax
80109de9:	74 3d                	je     80109e28 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109deb:	83 ec 0c             	sub    $0xc,%esp
80109dee:	6a 00                	push   $0x0
80109df0:	6a 12                	push   $0x12
80109df2:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109df5:	50                   	push   %eax
80109df6:	ff 75 e8             	push   -0x18(%ebp)
80109df9:	ff 75 08             	push   0x8(%ebp)
80109dfc:	e8 a2 01 00 00       	call   80109fa3 <tcp_pkt_create>
80109e01:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109e04:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e07:	83 ec 08             	sub    $0x8,%esp
80109e0a:	50                   	push   %eax
80109e0b:	ff 75 e8             	push   -0x18(%ebp)
80109e0e:	e8 61 f1 ff ff       	call   80108f74 <i8254_send>
80109e13:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109e16:	a1 64 78 19 80       	mov    0x80197864,%eax
80109e1b:	83 c0 01             	add    $0x1,%eax
80109e1e:	a3 64 78 19 80       	mov    %eax,0x80197864
80109e23:	e9 69 01 00 00       	jmp    80109f91 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e2b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e2f:	3c 18                	cmp    $0x18,%al
80109e31:	0f 85 10 01 00 00    	jne    80109f47 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109e37:	83 ec 04             	sub    $0x4,%esp
80109e3a:	6a 03                	push   $0x3
80109e3c:	68 3e c4 10 80       	push   $0x8010c43e
80109e41:	ff 75 ec             	push   -0x14(%ebp)
80109e44:	e8 b2 af ff ff       	call   80104dfb <memcmp>
80109e49:	83 c4 10             	add    $0x10,%esp
80109e4c:	85 c0                	test   %eax,%eax
80109e4e:	74 74                	je     80109ec4 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109e50:	83 ec 0c             	sub    $0xc,%esp
80109e53:	68 42 c4 10 80       	push   $0x8010c442
80109e58:	e8 97 65 ff ff       	call   801003f4 <cprintf>
80109e5d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e60:	83 ec 0c             	sub    $0xc,%esp
80109e63:	6a 00                	push   $0x0
80109e65:	6a 10                	push   $0x10
80109e67:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e6a:	50                   	push   %eax
80109e6b:	ff 75 e8             	push   -0x18(%ebp)
80109e6e:	ff 75 08             	push   0x8(%ebp)
80109e71:	e8 2d 01 00 00       	call   80109fa3 <tcp_pkt_create>
80109e76:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e7c:	83 ec 08             	sub    $0x8,%esp
80109e7f:	50                   	push   %eax
80109e80:	ff 75 e8             	push   -0x18(%ebp)
80109e83:	e8 ec f0 ff ff       	call   80108f74 <i8254_send>
80109e88:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e8e:	83 c0 36             	add    $0x36,%eax
80109e91:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e94:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109e97:	50                   	push   %eax
80109e98:	ff 75 e0             	push   -0x20(%ebp)
80109e9b:	6a 00                	push   $0x0
80109e9d:	6a 00                	push   $0x0
80109e9f:	e8 5a 04 00 00       	call   8010a2fe <http_proc>
80109ea4:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ea7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109eaa:	83 ec 0c             	sub    $0xc,%esp
80109ead:	50                   	push   %eax
80109eae:	6a 18                	push   $0x18
80109eb0:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109eb3:	50                   	push   %eax
80109eb4:	ff 75 e8             	push   -0x18(%ebp)
80109eb7:	ff 75 08             	push   0x8(%ebp)
80109eba:	e8 e4 00 00 00       	call   80109fa3 <tcp_pkt_create>
80109ebf:	83 c4 20             	add    $0x20,%esp
80109ec2:	eb 62                	jmp    80109f26 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ec4:	83 ec 0c             	sub    $0xc,%esp
80109ec7:	6a 00                	push   $0x0
80109ec9:	6a 10                	push   $0x10
80109ecb:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ece:	50                   	push   %eax
80109ecf:	ff 75 e8             	push   -0x18(%ebp)
80109ed2:	ff 75 08             	push   0x8(%ebp)
80109ed5:	e8 c9 00 00 00       	call   80109fa3 <tcp_pkt_create>
80109eda:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109edd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ee0:	83 ec 08             	sub    $0x8,%esp
80109ee3:	50                   	push   %eax
80109ee4:	ff 75 e8             	push   -0x18(%ebp)
80109ee7:	e8 88 f0 ff ff       	call   80108f74 <i8254_send>
80109eec:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109eef:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ef2:	83 c0 36             	add    $0x36,%eax
80109ef5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ef8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109efb:	50                   	push   %eax
80109efc:	ff 75 e4             	push   -0x1c(%ebp)
80109eff:	6a 00                	push   $0x0
80109f01:	6a 00                	push   $0x0
80109f03:	e8 f6 03 00 00       	call   8010a2fe <http_proc>
80109f08:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109f0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109f0e:	83 ec 0c             	sub    $0xc,%esp
80109f11:	50                   	push   %eax
80109f12:	6a 18                	push   $0x18
80109f14:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f17:	50                   	push   %eax
80109f18:	ff 75 e8             	push   -0x18(%ebp)
80109f1b:	ff 75 08             	push   0x8(%ebp)
80109f1e:	e8 80 00 00 00       	call   80109fa3 <tcp_pkt_create>
80109f23:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109f26:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f29:	83 ec 08             	sub    $0x8,%esp
80109f2c:	50                   	push   %eax
80109f2d:	ff 75 e8             	push   -0x18(%ebp)
80109f30:	e8 3f f0 ff ff       	call   80108f74 <i8254_send>
80109f35:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f38:	a1 64 78 19 80       	mov    0x80197864,%eax
80109f3d:	83 c0 01             	add    $0x1,%eax
80109f40:	a3 64 78 19 80       	mov    %eax,0x80197864
80109f45:	eb 4a                	jmp    80109f91 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f4a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f4e:	3c 10                	cmp    $0x10,%al
80109f50:	75 3f                	jne    80109f91 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109f52:	a1 68 78 19 80       	mov    0x80197868,%eax
80109f57:	83 f8 01             	cmp    $0x1,%eax
80109f5a:	75 35                	jne    80109f91 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109f5c:	83 ec 0c             	sub    $0xc,%esp
80109f5f:	6a 00                	push   $0x0
80109f61:	6a 01                	push   $0x1
80109f63:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f66:	50                   	push   %eax
80109f67:	ff 75 e8             	push   -0x18(%ebp)
80109f6a:	ff 75 08             	push   0x8(%ebp)
80109f6d:	e8 31 00 00 00       	call   80109fa3 <tcp_pkt_create>
80109f72:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f75:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f78:	83 ec 08             	sub    $0x8,%esp
80109f7b:	50                   	push   %eax
80109f7c:	ff 75 e8             	push   -0x18(%ebp)
80109f7f:	e8 f0 ef ff ff       	call   80108f74 <i8254_send>
80109f84:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109f87:	c7 05 68 78 19 80 00 	movl   $0x0,0x80197868
80109f8e:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109f91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f94:	83 ec 0c             	sub    $0xc,%esp
80109f97:	50                   	push   %eax
80109f98:	e8 69 87 ff ff       	call   80102706 <kfree>
80109f9d:	83 c4 10             	add    $0x10,%esp
}
80109fa0:	90                   	nop
80109fa1:	c9                   	leave  
80109fa2:	c3                   	ret    

80109fa3 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109fa3:	55                   	push   %ebp
80109fa4:	89 e5                	mov    %esp,%ebp
80109fa6:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80109fac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109faf:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb2:	83 c0 0e             	add    $0xe,%eax
80109fb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fbb:	0f b6 00             	movzbl (%eax),%eax
80109fbe:	0f b6 c0             	movzbl %al,%eax
80109fc1:	83 e0 0f             	and    $0xf,%eax
80109fc4:	c1 e0 02             	shl    $0x2,%eax
80109fc7:	89 c2                	mov    %eax,%edx
80109fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fcc:	01 d0                	add    %edx,%eax
80109fce:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fda:	83 c0 0e             	add    $0xe,%eax
80109fdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109fe0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fe3:	83 c0 14             	add    $0x14,%eax
80109fe6:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109fe9:	8b 45 18             	mov    0x18(%ebp),%eax
80109fec:	8d 50 36             	lea    0x36(%eax),%edx
80109fef:	8b 45 10             	mov    0x10(%ebp),%eax
80109ff2:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ff7:	8d 50 06             	lea    0x6(%eax),%edx
80109ffa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ffd:	83 ec 04             	sub    $0x4,%esp
8010a000:	6a 06                	push   $0x6
8010a002:	52                   	push   %edx
8010a003:	50                   	push   %eax
8010a004:	e8 4a ae ff ff       	call   80104e53 <memmove>
8010a009:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a00c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a00f:	83 c0 06             	add    $0x6,%eax
8010a012:	83 ec 04             	sub    $0x4,%esp
8010a015:	6a 06                	push   $0x6
8010a017:	68 90 75 19 80       	push   $0x80197590
8010a01c:	50                   	push   %eax
8010a01d:	e8 31 ae ff ff       	call   80104e53 <memmove>
8010a022:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a025:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a028:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a02c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a02f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a033:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a036:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a039:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a03c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a040:	8b 45 18             	mov    0x18(%ebp),%eax
8010a043:	83 c0 28             	add    $0x28,%eax
8010a046:	0f b7 c0             	movzwl %ax,%eax
8010a049:	83 ec 0c             	sub    $0xc,%esp
8010a04c:	50                   	push   %eax
8010a04d:	e8 9b f8 ff ff       	call   801098ed <H2N_ushort>
8010a052:	83 c4 10             	add    $0x10,%esp
8010a055:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a058:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a05c:	0f b7 15 60 78 19 80 	movzwl 0x80197860,%edx
8010a063:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a066:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a06a:	0f b7 05 60 78 19 80 	movzwl 0x80197860,%eax
8010a071:	83 c0 01             	add    $0x1,%eax
8010a074:	66 a3 60 78 19 80    	mov    %ax,0x80197860
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a07a:	83 ec 0c             	sub    $0xc,%esp
8010a07d:	6a 00                	push   $0x0
8010a07f:	e8 69 f8 ff ff       	call   801098ed <H2N_ushort>
8010a084:	83 c4 10             	add    $0x10,%esp
8010a087:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a08a:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a08e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a091:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a095:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a098:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a09c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a09f:	83 c0 0c             	add    $0xc,%eax
8010a0a2:	83 ec 04             	sub    $0x4,%esp
8010a0a5:	6a 04                	push   $0x4
8010a0a7:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a0ac:	50                   	push   %eax
8010a0ad:	e8 a1 ad ff ff       	call   80104e53 <memmove>
8010a0b2:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a0b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b8:	8d 50 0c             	lea    0xc(%eax),%edx
8010a0bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0be:	83 c0 10             	add    $0x10,%eax
8010a0c1:	83 ec 04             	sub    $0x4,%esp
8010a0c4:	6a 04                	push   $0x4
8010a0c6:	52                   	push   %edx
8010a0c7:	50                   	push   %eax
8010a0c8:	e8 86 ad ff ff       	call   80104e53 <memmove>
8010a0cd:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a0d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0d3:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a0d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0dc:	83 ec 0c             	sub    $0xc,%esp
8010a0df:	50                   	push   %eax
8010a0e0:	e8 08 f9 ff ff       	call   801099ed <ipv4_chksum>
8010a0e5:	83 c4 10             	add    $0x10,%esp
8010a0e8:	0f b7 c0             	movzwl %ax,%eax
8010a0eb:	83 ec 0c             	sub    $0xc,%esp
8010a0ee:	50                   	push   %eax
8010a0ef:	e8 f9 f7 ff ff       	call   801098ed <H2N_ushort>
8010a0f4:	83 c4 10             	add    $0x10,%esp
8010a0f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0fa:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a0fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a101:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a105:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a108:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a10b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a10e:	0f b7 10             	movzwl (%eax),%edx
8010a111:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a114:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a118:	a1 64 78 19 80       	mov    0x80197864,%eax
8010a11d:	83 ec 0c             	sub    $0xc,%esp
8010a120:	50                   	push   %eax
8010a121:	e8 e9 f7 ff ff       	call   8010990f <H2N_uint>
8010a126:	83 c4 10             	add    $0x10,%esp
8010a129:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a12c:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a12f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a132:	8b 40 04             	mov    0x4(%eax),%eax
8010a135:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a13b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a13e:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a141:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a144:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a148:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a14b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a14f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a152:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a156:	8b 45 14             	mov    0x14(%ebp),%eax
8010a159:	89 c2                	mov    %eax,%edx
8010a15b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a15e:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a161:	83 ec 0c             	sub    $0xc,%esp
8010a164:	68 90 38 00 00       	push   $0x3890
8010a169:	e8 7f f7 ff ff       	call   801098ed <H2N_ushort>
8010a16e:	83 c4 10             	add    $0x10,%esp
8010a171:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a174:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a178:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a17b:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a181:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a184:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a18a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a18d:	83 ec 0c             	sub    $0xc,%esp
8010a190:	50                   	push   %eax
8010a191:	e8 1f 00 00 00       	call   8010a1b5 <tcp_chksum>
8010a196:	83 c4 10             	add    $0x10,%esp
8010a199:	83 c0 08             	add    $0x8,%eax
8010a19c:	0f b7 c0             	movzwl %ax,%eax
8010a19f:	83 ec 0c             	sub    $0xc,%esp
8010a1a2:	50                   	push   %eax
8010a1a3:	e8 45 f7 ff ff       	call   801098ed <H2N_ushort>
8010a1a8:	83 c4 10             	add    $0x10,%esp
8010a1ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1ae:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a1b2:	90                   	nop
8010a1b3:	c9                   	leave  
8010a1b4:	c3                   	ret    

8010a1b5 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a1b5:	55                   	push   %ebp
8010a1b6:	89 e5                	mov    %esp,%ebp
8010a1b8:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a1bb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1be:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a1c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1c4:	83 c0 14             	add    $0x14,%eax
8010a1c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a1ca:	83 ec 04             	sub    $0x4,%esp
8010a1cd:	6a 04                	push   $0x4
8010a1cf:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a1d4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1d7:	50                   	push   %eax
8010a1d8:	e8 76 ac ff ff       	call   80104e53 <memmove>
8010a1dd:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a1e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1e3:	83 c0 0c             	add    $0xc,%eax
8010a1e6:	83 ec 04             	sub    $0x4,%esp
8010a1e9:	6a 04                	push   $0x4
8010a1eb:	50                   	push   %eax
8010a1ec:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1ef:	83 c0 04             	add    $0x4,%eax
8010a1f2:	50                   	push   %eax
8010a1f3:	e8 5b ac ff ff       	call   80104e53 <memmove>
8010a1f8:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a1fb:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a1ff:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a203:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a206:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a20a:	0f b7 c0             	movzwl %ax,%eax
8010a20d:	83 ec 0c             	sub    $0xc,%esp
8010a210:	50                   	push   %eax
8010a211:	e8 b5 f6 ff ff       	call   801098cb <N2H_ushort>
8010a216:	83 c4 10             	add    $0x10,%esp
8010a219:	83 e8 14             	sub    $0x14,%eax
8010a21c:	0f b7 c0             	movzwl %ax,%eax
8010a21f:	83 ec 0c             	sub    $0xc,%esp
8010a222:	50                   	push   %eax
8010a223:	e8 c5 f6 ff ff       	call   801098ed <H2N_ushort>
8010a228:	83 c4 10             	add    $0x10,%esp
8010a22b:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a22f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a236:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a239:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a23c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a243:	eb 33                	jmp    8010a278 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a245:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a248:	01 c0                	add    %eax,%eax
8010a24a:	89 c2                	mov    %eax,%edx
8010a24c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a24f:	01 d0                	add    %edx,%eax
8010a251:	0f b6 00             	movzbl (%eax),%eax
8010a254:	0f b6 c0             	movzbl %al,%eax
8010a257:	c1 e0 08             	shl    $0x8,%eax
8010a25a:	89 c2                	mov    %eax,%edx
8010a25c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a25f:	01 c0                	add    %eax,%eax
8010a261:	8d 48 01             	lea    0x1(%eax),%ecx
8010a264:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a267:	01 c8                	add    %ecx,%eax
8010a269:	0f b6 00             	movzbl (%eax),%eax
8010a26c:	0f b6 c0             	movzbl %al,%eax
8010a26f:	01 d0                	add    %edx,%eax
8010a271:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a274:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a278:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a27c:	7e c7                	jle    8010a245 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a27e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a284:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a28b:	eb 33                	jmp    8010a2c0 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a28d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a290:	01 c0                	add    %eax,%eax
8010a292:	89 c2                	mov    %eax,%edx
8010a294:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a297:	01 d0                	add    %edx,%eax
8010a299:	0f b6 00             	movzbl (%eax),%eax
8010a29c:	0f b6 c0             	movzbl %al,%eax
8010a29f:	c1 e0 08             	shl    $0x8,%eax
8010a2a2:	89 c2                	mov    %eax,%edx
8010a2a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2a7:	01 c0                	add    %eax,%eax
8010a2a9:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2af:	01 c8                	add    %ecx,%eax
8010a2b1:	0f b6 00             	movzbl (%eax),%eax
8010a2b4:	0f b6 c0             	movzbl %al,%eax
8010a2b7:	01 d0                	add    %edx,%eax
8010a2b9:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a2bc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a2c0:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a2c4:	0f b7 c0             	movzwl %ax,%eax
8010a2c7:	83 ec 0c             	sub    $0xc,%esp
8010a2ca:	50                   	push   %eax
8010a2cb:	e8 fb f5 ff ff       	call   801098cb <N2H_ushort>
8010a2d0:	83 c4 10             	add    $0x10,%esp
8010a2d3:	66 d1 e8             	shr    %ax
8010a2d6:	0f b7 c0             	movzwl %ax,%eax
8010a2d9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a2dc:	7c af                	jl     8010a28d <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a2de:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2e1:	c1 e8 10             	shr    $0x10,%eax
8010a2e4:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a2e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2ea:	f7 d0                	not    %eax
}
8010a2ec:	c9                   	leave  
8010a2ed:	c3                   	ret    

8010a2ee <tcp_fin>:

void tcp_fin(){
8010a2ee:	55                   	push   %ebp
8010a2ef:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a2f1:	c7 05 68 78 19 80 01 	movl   $0x1,0x80197868
8010a2f8:	00 00 00 
}
8010a2fb:	90                   	nop
8010a2fc:	5d                   	pop    %ebp
8010a2fd:	c3                   	ret    

8010a2fe <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a2fe:	55                   	push   %ebp
8010a2ff:	89 e5                	mov    %esp,%ebp
8010a301:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a304:	8b 45 10             	mov    0x10(%ebp),%eax
8010a307:	83 ec 04             	sub    $0x4,%esp
8010a30a:	6a 00                	push   $0x0
8010a30c:	68 4b c4 10 80       	push   $0x8010c44b
8010a311:	50                   	push   %eax
8010a312:	e8 65 00 00 00       	call   8010a37c <http_strcpy>
8010a317:	83 c4 10             	add    $0x10,%esp
8010a31a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a31d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a320:	83 ec 04             	sub    $0x4,%esp
8010a323:	ff 75 f4             	push   -0xc(%ebp)
8010a326:	68 5e c4 10 80       	push   $0x8010c45e
8010a32b:	50                   	push   %eax
8010a32c:	e8 4b 00 00 00       	call   8010a37c <http_strcpy>
8010a331:	83 c4 10             	add    $0x10,%esp
8010a334:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a337:	8b 45 10             	mov    0x10(%ebp),%eax
8010a33a:	83 ec 04             	sub    $0x4,%esp
8010a33d:	ff 75 f4             	push   -0xc(%ebp)
8010a340:	68 79 c4 10 80       	push   $0x8010c479
8010a345:	50                   	push   %eax
8010a346:	e8 31 00 00 00       	call   8010a37c <http_strcpy>
8010a34b:	83 c4 10             	add    $0x10,%esp
8010a34e:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a351:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a354:	83 e0 01             	and    $0x1,%eax
8010a357:	85 c0                	test   %eax,%eax
8010a359:	74 11                	je     8010a36c <http_proc+0x6e>
    char *payload = (char *)send;
8010a35b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a35e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a361:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a364:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a367:	01 d0                	add    %edx,%eax
8010a369:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a36c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a36f:	8b 45 14             	mov    0x14(%ebp),%eax
8010a372:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a374:	e8 75 ff ff ff       	call   8010a2ee <tcp_fin>
}
8010a379:	90                   	nop
8010a37a:	c9                   	leave  
8010a37b:	c3                   	ret    

8010a37c <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a37c:	55                   	push   %ebp
8010a37d:	89 e5                	mov    %esp,%ebp
8010a37f:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a382:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a389:	eb 20                	jmp    8010a3ab <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a38b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a38e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a391:	01 d0                	add    %edx,%eax
8010a393:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a396:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a399:	01 ca                	add    %ecx,%edx
8010a39b:	89 d1                	mov    %edx,%ecx
8010a39d:	8b 55 08             	mov    0x8(%ebp),%edx
8010a3a0:	01 ca                	add    %ecx,%edx
8010a3a2:	0f b6 00             	movzbl (%eax),%eax
8010a3a5:	88 02                	mov    %al,(%edx)
    i++;
8010a3a7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a3ab:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3b1:	01 d0                	add    %edx,%eax
8010a3b3:	0f b6 00             	movzbl (%eax),%eax
8010a3b6:	84 c0                	test   %al,%al
8010a3b8:	75 d1                	jne    8010a38b <http_strcpy+0xf>
  }
  return i;
8010a3ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a3bd:	c9                   	leave  
8010a3be:	c3                   	ret    

8010a3bf <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a3bf:	55                   	push   %ebp
8010a3c0:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a3c2:	c7 05 70 78 19 80 a2 	movl   $0x8010f5a2,0x80197870
8010a3c9:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a3cc:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a3d1:	c1 e8 09             	shr    $0x9,%eax
8010a3d4:	a3 6c 78 19 80       	mov    %eax,0x8019786c
}
8010a3d9:	90                   	nop
8010a3da:	5d                   	pop    %ebp
8010a3db:	c3                   	ret    

8010a3dc <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a3dc:	55                   	push   %ebp
8010a3dd:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a3df:	90                   	nop
8010a3e0:	5d                   	pop    %ebp
8010a3e1:	c3                   	ret    

8010a3e2 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a3e2:	55                   	push   %ebp
8010a3e3:	89 e5                	mov    %esp,%ebp
8010a3e5:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a3e8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3eb:	83 c0 0c             	add    $0xc,%eax
8010a3ee:	83 ec 0c             	sub    $0xc,%esp
8010a3f1:	50                   	push   %eax
8010a3f2:	e8 96 a6 ff ff       	call   80104a8d <holdingsleep>
8010a3f7:	83 c4 10             	add    $0x10,%esp
8010a3fa:	85 c0                	test   %eax,%eax
8010a3fc:	75 0d                	jne    8010a40b <iderw+0x29>
    panic("iderw: buf not locked");
8010a3fe:	83 ec 0c             	sub    $0xc,%esp
8010a401:	68 8a c4 10 80       	push   $0x8010c48a
8010a406:	e8 9e 61 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a40b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a40e:	8b 00                	mov    (%eax),%eax
8010a410:	83 e0 06             	and    $0x6,%eax
8010a413:	83 f8 02             	cmp    $0x2,%eax
8010a416:	75 0d                	jne    8010a425 <iderw+0x43>
    panic("iderw: nothing to do");
8010a418:	83 ec 0c             	sub    $0xc,%esp
8010a41b:	68 a0 c4 10 80       	push   $0x8010c4a0
8010a420:	e8 84 61 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a425:	8b 45 08             	mov    0x8(%ebp),%eax
8010a428:	8b 40 04             	mov    0x4(%eax),%eax
8010a42b:	83 f8 01             	cmp    $0x1,%eax
8010a42e:	74 0d                	je     8010a43d <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a430:	83 ec 0c             	sub    $0xc,%esp
8010a433:	68 b5 c4 10 80       	push   $0x8010c4b5
8010a438:	e8 6c 61 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a43d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a440:	8b 40 08             	mov    0x8(%eax),%eax
8010a443:	8b 15 6c 78 19 80    	mov    0x8019786c,%edx
8010a449:	39 d0                	cmp    %edx,%eax
8010a44b:	72 0d                	jb     8010a45a <iderw+0x78>
    panic("iderw: block out of range");
8010a44d:	83 ec 0c             	sub    $0xc,%esp
8010a450:	68 d3 c4 10 80       	push   $0x8010c4d3
8010a455:	e8 4f 61 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a45a:	8b 15 70 78 19 80    	mov    0x80197870,%edx
8010a460:	8b 45 08             	mov    0x8(%ebp),%eax
8010a463:	8b 40 08             	mov    0x8(%eax),%eax
8010a466:	c1 e0 09             	shl    $0x9,%eax
8010a469:	01 d0                	add    %edx,%eax
8010a46b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a46e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a471:	8b 00                	mov    (%eax),%eax
8010a473:	83 e0 04             	and    $0x4,%eax
8010a476:	85 c0                	test   %eax,%eax
8010a478:	74 2b                	je     8010a4a5 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a47a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a47d:	8b 00                	mov    (%eax),%eax
8010a47f:	83 e0 fb             	and    $0xfffffffb,%eax
8010a482:	89 c2                	mov    %eax,%edx
8010a484:	8b 45 08             	mov    0x8(%ebp),%eax
8010a487:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a489:	8b 45 08             	mov    0x8(%ebp),%eax
8010a48c:	83 c0 5c             	add    $0x5c,%eax
8010a48f:	83 ec 04             	sub    $0x4,%esp
8010a492:	68 00 02 00 00       	push   $0x200
8010a497:	50                   	push   %eax
8010a498:	ff 75 f4             	push   -0xc(%ebp)
8010a49b:	e8 b3 a9 ff ff       	call   80104e53 <memmove>
8010a4a0:	83 c4 10             	add    $0x10,%esp
8010a4a3:	eb 1a                	jmp    8010a4bf <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a4a5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4a8:	83 c0 5c             	add    $0x5c,%eax
8010a4ab:	83 ec 04             	sub    $0x4,%esp
8010a4ae:	68 00 02 00 00       	push   $0x200
8010a4b3:	ff 75 f4             	push   -0xc(%ebp)
8010a4b6:	50                   	push   %eax
8010a4b7:	e8 97 a9 ff ff       	call   80104e53 <memmove>
8010a4bc:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a4bf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4c2:	8b 00                	mov    (%eax),%eax
8010a4c4:	83 c8 02             	or     $0x2,%eax
8010a4c7:	89 c2                	mov    %eax,%edx
8010a4c9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4cc:	89 10                	mov    %edx,(%eax)
}
8010a4ce:	90                   	nop
8010a4cf:	c9                   	leave  
8010a4d0:	c3                   	ret    
