
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
8010006f:	68 80 a5 10 80       	push   $0x8010a580
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 00 4b 00 00       	call   80104b7e <initlock>
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
801000bd:	68 87 a5 10 80       	push   $0x8010a587
801000c2:	50                   	push   %eax
801000c3:	e8 59 49 00 00       	call   80104a21 <initsleeplock>
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
80100101:	e8 9a 4a 00 00       	call   80104ba0 <acquire>
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
80100140:	e8 c9 4a 00 00       	call   80104c0e <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 06 49 00 00       	call   80104a5d <acquiresleep>
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
801001c1:	e8 48 4a 00 00       	call   80104c0e <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 85 48 00 00       	call   80104a5d <acquiresleep>
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
801001f5:	68 8e a5 10 80       	push   $0x8010a58e
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
8010022d:	e8 59 a2 00 00       	call   8010a48b <iderw>
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
8010024a:	e8 c0 48 00 00       	call   80104b0f <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 9f a5 10 80       	push   $0x8010a59f
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
80100278:	e8 0e a2 00 00       	call   8010a48b <iderw>
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
80100293:	e8 77 48 00 00       	call   80104b0f <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 a6 a5 10 80       	push   $0x8010a5a6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 06 48 00 00       	call   80104ac1 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 d5 48 00 00       	call   80104ba0 <acquire>
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
80100336:	e8 d3 48 00 00       	call   80104c0e <release>
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
80100410:	e8 8b 47 00 00       	call   80104ba0 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ad a5 10 80       	push   $0x8010a5ad
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
80100510:	c7 45 ec b6 a5 10 80 	movl   $0x8010a5b6,-0x14(%ebp)
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
8010059e:	e8 6b 46 00 00       	call   80104c0e <release>
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
801005c7:	68 bd a5 10 80       	push   $0x8010a5bd
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
801005e6:	68 d1 a5 10 80       	push   $0x8010a5d1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 5d 46 00 00       	call   80104c60 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 d3 a5 10 80       	push   $0x8010a5d3
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
801006a0:	e8 3d 7d 00 00       	call   801083e2 <graphic_scroll_up>
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
801006f3:	e8 ea 7c 00 00       	call   801083e2 <graphic_scroll_up>
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
80100757:	e8 f1 7c 00 00       	call   8010844d <font_render>
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
80100793:	e8 c1 60 00 00       	call   80106859 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 b4 60 00 00       	call   80106859 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 a7 60 00 00       	call   80106859 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 97 60 00 00       	call   80106859 <uartputc>
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
801007eb:	e8 b0 43 00 00       	call   80104ba0 <acquire>
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
8010093f:	e8 d5 3d 00 00       	call   80104719 <wakeup>
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
80100962:	e8 a7 42 00 00       	call   80104c0e <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 62 3e 00 00       	call   801047d7 <procdump>
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
8010099a:	e8 01 42 00 00       	call   80104ba0 <acquire>
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
801009bb:	e8 4e 42 00 00       	call   80104c0e <release>
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
801009e8:	e8 42 3c 00 00       	call   8010462f <sleep>
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
80100a66:	e8 a3 41 00 00       	call   80104c0e <release>
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
80100aa2:	e8 f9 40 00 00       	call   80104ba0 <acquire>
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
80100ae4:	e8 25 41 00 00       	call   80104c0e <release>
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
80100b12:	68 d7 a5 10 80       	push   $0x8010a5d7
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 5d 40 00 00       	call   80104b7e <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 df a5 10 80 	movl   $0x8010a5df,-0xc(%ebp)
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
80100bb5:	68 f5 a5 10 80       	push   $0x8010a5f5
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
80100c11:	e8 3f 6c 00 00       	call   80107855 <setupkvm>
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
80100cb7:	e8 92 6f 00 00       	call   80107c4e <allocuvm>
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
80100cfd:	e8 7f 6e 00 00       	call   80107b81 <loaduvm>
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
80100d6c:	e8 dd 6e 00 00       	call   80107c4e <allocuvm>
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
80100d90:	e8 1b 71 00 00       	call   80107eb0 <clearpteu>
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
80100dc9:	e8 96 42 00 00       	call   80105064 <strlen>
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
80100df6:	e8 69 42 00 00       	call   80105064 <strlen>
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
80100e1c:	e8 2e 72 00 00       	call   8010804f <copyout>
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
80100eb8:	e8 92 71 00 00       	call   8010804f <copyout>
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
80100f06:	e8 0e 41 00 00       	call   80105019 <safestrcpy>
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
80100f49:	e8 24 6a 00 00       	call   80107972 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 bb 6e 00 00       	call   80107e17 <freevm>
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
80100f97:	e8 7b 6e 00 00       	call   80107e17 <freevm>
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
80100fc8:	68 01 a6 10 80       	push   $0x8010a601
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 a7 3b 00 00       	call   80104b7e <initlock>
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
80100feb:	e8 b0 3b 00 00       	call   80104ba0 <acquire>
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
80101018:	e8 f1 3b 00 00       	call   80104c0e <release>
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
8010103b:	e8 ce 3b 00 00       	call   80104c0e <release>
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
80101058:	e8 43 3b 00 00       	call   80104ba0 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 08 a6 10 80       	push   $0x8010a608
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
8010108e:	e8 7b 3b 00 00       	call   80104c0e <release>
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
801010a9:	e8 f2 3a 00 00       	call   80104ba0 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 10 a6 10 80       	push   $0x8010a610
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
801010e9:	e8 20 3b 00 00       	call   80104c0e <release>
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
80101137:	e8 d2 3a 00 00       	call   80104c0e <release>
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
80101286:	68 1a a6 10 80       	push   $0x8010a61a
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
80101389:	68 23 a6 10 80       	push   $0x8010a623
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
801013bf:	68 33 a6 10 80       	push   $0x8010a633
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
801013f7:	e8 d9 3a 00 00       	call   80104ed5 <memmove>
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
8010143d:	e8 d4 39 00 00       	call   80104e16 <memset>
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
8010159c:	68 40 a6 10 80       	push   $0x8010a640
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
80101627:	68 56 a6 10 80       	push   $0x8010a656
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
8010168b:	68 69 a6 10 80       	push   $0x8010a669
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 e4 34 00 00       	call   80104b7e <initlock>
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
801016c1:	68 70 a6 10 80       	push   $0x8010a670
801016c6:	50                   	push   %eax
801016c7:	e8 55 33 00 00       	call   80104a21 <initsleeplock>
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
80101720:	68 78 a6 10 80       	push   $0x8010a678
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
80101799:	e8 78 36 00 00       	call   80104e16 <memset>
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
80101801:	68 cb a6 10 80       	push   $0x8010a6cb
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
801018a7:	e8 29 36 00 00       	call   80104ed5 <memmove>
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
801018dc:	e8 bf 32 00 00       	call   80104ba0 <acquire>
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
8010192a:	e8 df 32 00 00       	call   80104c0e <release>
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
80101966:	68 dd a6 10 80       	push   $0x8010a6dd
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
801019a3:	e8 66 32 00 00       	call   80104c0e <release>
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
801019be:	e8 dd 31 00 00       	call   80104ba0 <acquire>
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
801019dd:	e8 2c 32 00 00       	call   80104c0e <release>
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
80101a03:	68 ed a6 10 80       	push   $0x8010a6ed
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 41 30 00 00       	call   80104a5d <acquiresleep>
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
80101ac1:	e8 0f 34 00 00       	call   80104ed5 <memmove>
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
80101af0:	68 f3 a6 10 80       	push   $0x8010a6f3
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
80101b13:	e8 f7 2f 00 00       	call   80104b0f <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 02 a7 10 80       	push   $0x8010a702
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 7c 2f 00 00       	call   80104ac1 <releasesleep>
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
80101b5b:	e8 fd 2e 00 00       	call   80104a5d <acquiresleep>
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
80101b81:	e8 1a 30 00 00       	call   80104ba0 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 6f 30 00 00       	call   80104c0e <release>
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
80101be1:	e8 db 2e 00 00       	call   80104ac1 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 aa 2f 00 00       	call   80104ba0 <acquire>
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
80101c10:	e8 f9 2f 00 00       	call   80104c0e <release>
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
80101d54:	68 0a a7 10 80       	push   $0x8010a70a
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
80101ff2:	e8 de 2e 00 00       	call   80104ed5 <memmove>
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
80102142:	e8 8e 2d 00 00       	call   80104ed5 <memmove>
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
801021c2:	e8 a4 2d 00 00       	call   80104f6b <strncmp>
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
801021e2:	68 1d a7 10 80       	push   $0x8010a71d
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
80102211:	68 2f a7 10 80       	push   $0x8010a72f
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
801022e6:	68 3e a7 10 80       	push   $0x8010a73e
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
80102321:	e8 9b 2c 00 00       	call   80104fc1 <strncpy>
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
8010234d:	68 4b a7 10 80       	push   $0x8010a74b
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
801023bf:	e8 11 2b 00 00       	call   80104ed5 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 fa 2a 00 00       	call   80104ed5 <memmove>
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
801025cd:	68 54 a7 10 80       	push   $0x8010a754
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
80102674:	68 86 a7 10 80       	push   $0x8010a786
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 fb 24 00 00       	call   80104b7e <initlock>
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
80102733:	68 8b a7 10 80       	push   $0x8010a78b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 c7 26 00 00       	call   80104e16 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 38 24 00 00       	call   80104ba0 <acquire>
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
80102795:	e8 74 24 00 00       	call   80104c0e <release>
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
801027b7:	e8 e4 23 00 00       	call   80104ba0 <acquire>
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
801027e8:	e8 21 24 00 00       	call   80104c0e <release>
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
80102d12:	e8 66 21 00 00       	call   80104e7d <memcmp>
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
80102e26:	68 91 a7 10 80       	push   $0x8010a791
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 49 1d 00 00       	call   80104b7e <initlock>
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
80102edb:	e8 f5 1f 00 00       	call   80104ed5 <memmove>
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
8010304a:	e8 51 1b 00 00       	call   80104ba0 <acquire>
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
80103068:	e8 c2 15 00 00       	call   8010462f <sleep>
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
8010309d:	e8 8d 15 00 00       	call   8010462f <sleep>
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
801030bc:	e8 4d 1b 00 00       	call   80104c0e <release>
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
801030dd:	e8 be 1a 00 00       	call   80104ba0 <acquire>
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
801030fe:	68 95 a7 10 80       	push   $0x8010a795
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
8010312c:	e8 e8 15 00 00       	call   80104719 <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 cd 1a 00 00       	call   80104c0e <release>
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
80103157:	e8 44 1a 00 00       	call   80104ba0 <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 a3 15 00 00       	call   80104719 <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 88 1a 00 00       	call   80104c0e <release>
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
801031fd:	e8 d3 1c 00 00       	call   80104ed5 <memmove>
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
8010329a:	68 a4 a7 10 80       	push   $0x8010a7a4
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 ba a7 10 80       	push   $0x8010a7ba
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 d9 18 00 00       	call   80104ba0 <acquire>
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
80103340:	e8 c9 18 00 00       	call   80104c0e <release>
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
80103376:	e8 ac 4f 00 00       	call   80108327 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 ac 45 00 00       	call   80107941 <kvmalloc>
  mpinit_uefi();
80103395:	e8 53 4d 00 00       	call   801080ed <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 35 40 00 00       	call   801073d9 <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 ba 33 00 00       	call   80106772 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 a0 2e 00 00       	call   80106262 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 97 70 00 00       	call   8010a468 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 90 51 00 00       	call   80108580 <pci_init>
  arp_scan();
801033f0:	e8 c7 5e 00 00       	call   801092bc <arp_scan>
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
80103405:	e8 4f 45 00 00       	call   80107959 <switchkvm>
  seginit();
8010340a:	e8 ca 3f 00 00       	call   801073d9 <seginit>
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
80103431:	68 d5 a7 10 80       	push   $0x8010a7d5
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 95 2f 00 00       	call   801063d8 <idtinit>
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
8010347e:	e8 52 1a 00 00       	call   80104ed5 <memmove>
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
80103607:	68 e9 a7 10 80       	push   $0x8010a7e9
8010360c:	50                   	push   %eax
8010360d:	e8 6c 15 00 00       	call   80104b7e <initlock>
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
801036cc:	e8 cf 14 00 00       	call   80104ba0 <acquire>
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
801036f3:	e8 21 10 00 00       	call   80104719 <wakeup>
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
80103716:	e8 fe 0f 00 00       	call   80104719 <wakeup>
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
8010373f:	e8 ca 14 00 00       	call   80104c0e <release>
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
8010375e:	e8 ab 14 00 00       	call   80104c0e <release>
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
80103778:	e8 23 14 00 00       	call   80104ba0 <acquire>
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
801037ac:	e8 5d 14 00 00       	call   80104c0e <release>
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
801037ca:	e8 4a 0f 00 00       	call   80104719 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 47 0e 00 00       	call   8010462f <sleep>
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
8010384d:	e8 c7 0e 00 00       	call   80104719 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 ad 13 00 00       	call   80104c0e <release>
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
80103879:	e8 22 13 00 00       	call   80104ba0 <acquire>
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
80103896:	e8 73 13 00 00       	call   80104c0e <release>
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
801038b9:	e8 71 0d 00 00       	call   8010462f <sleep>
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
8010394c:	e8 c8 0d 00 00       	call   80104719 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 ae 12 00 00       	call   80104c0e <release>
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
80103988:	68 f0 a7 10 80       	push   $0x8010a7f0
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 e7 11 00 00       	call   80104b7e <initlock>
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
801039cf:	68 f8 a7 10 80       	push   $0x8010a7f8
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
80103a24:	68 1e a8 10 80       	push   $0x8010a81e
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
80103a36:	e8 d0 12 00 00       	call   80104d0b <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 04 13 00 00       	call   80104d58 <popcli>
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
80103a67:	e8 34 11 00 00       	call   80104ba0 <acquire>
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
80103a9a:	e8 6f 11 00 00       	call   80104c0e <release>
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
80103ad3:	e8 36 11 00 00       	call   80104c0e <release>
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
80103af3:	e8 1e 13 00 00       	call   80104e16 <memset>
80103af8:	83 c4 10             	add    $0x10,%esp
  memset(p->wait_ticks, 0, sizeof(p->wait_ticks)); // 초기화
80103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afe:	05 90 00 00 00       	add    $0x90,%eax
80103b03:	83 ec 04             	sub    $0x4,%esp
80103b06:	6a 10                	push   $0x10
80103b08:	6a 00                	push   $0x0
80103b0a:	50                   	push   %eax
80103b0b:	e8 06 13 00 00       	call   80104e16 <memset>
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
80103b58:	ba 1c 62 10 80       	mov    $0x8010621c,%edx
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
80103b7d:	e8 94 12 00 00       	call   80104e16 <memset>
80103b82:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b88:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b8b:	ba e9 45 10 80       	mov    $0x801045e9,%edx
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
80103bae:	e8 a2 3c 00 00       	call   80107855 <setupkvm>
80103bb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bb6:	89 42 04             	mov    %eax,0x4(%edx)
80103bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbc:	8b 40 04             	mov    0x4(%eax),%eax
80103bbf:	85 c0                	test   %eax,%eax
80103bc1:	75 0d                	jne    80103bd0 <userinit+0x38>
    panic("userinit: out of memory?");
80103bc3:	83 ec 0c             	sub    $0xc,%esp
80103bc6:	68 2e a8 10 80       	push   $0x8010a82e
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
80103be5:	e8 27 3f 00 00       	call   80107b11 <inituvm>
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
80103c04:	e8 0d 12 00 00       	call   80104e16 <memset>
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
80103c7e:	68 47 a8 10 80       	push   $0x8010a847
80103c83:	50                   	push   %eax
80103c84:	e8 90 13 00 00       	call   80105019 <safestrcpy>
80103c89:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	68 50 a8 10 80       	push   $0x8010a850
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
80103caa:	e8 f1 0e 00 00       	call   80104ba0 <acquire>
80103caf:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103cbc:	83 ec 0c             	sub    $0xc,%esp
80103cbf:	68 00 42 19 80       	push   $0x80194200
80103cc4:	e8 45 0f 00 00       	call   80104c0e <release>
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
80103d01:	e8 48 3f 00 00       	call   80107c4e <allocuvm>
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
80103d35:	e8 19 40 00 00       	call   80107d53 <deallocuvm>
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
80103d5b:	e8 12 3c 00 00       	call   80107972 <switchuvm>
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
80103da3:	e8 49 41 00 00       	call   80107ef1 <copyuvm>
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
80103e9d:	e8 77 11 00 00       	call   80105019 <safestrcpy>
80103ea2:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ea5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ea8:	8b 40 10             	mov    0x10(%eax),%eax
80103eab:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103eae:	83 ec 0c             	sub    $0xc,%esp
80103eb1:	68 00 42 19 80       	push   $0x80194200
80103eb6:	e8 e5 0c 00 00       	call   80104ba0 <acquire>
80103ebb:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103ebe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ec1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ec8:	83 ec 0c             	sub    $0xc,%esp
80103ecb:	68 00 42 19 80       	push   $0x80194200
80103ed0:	e8 39 0d 00 00       	call   80104c0e <release>
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
80103efe:	68 52 a8 10 80       	push   $0x8010a852
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
80103f84:	e8 17 0c 00 00       	call   80104ba0 <acquire>
80103f89:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f8f:	8b 40 14             	mov    0x14(%eax),%eax
80103f92:	83 ec 0c             	sub    $0xc,%esp
80103f95:	50                   	push   %eax
80103f96:	e8 3b 07 00 00       	call   801046d6 <wakeup1>
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
80103fd2:	e8 ff 06 00 00       	call   801046d6 <wakeup1>
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
80103ff4:	e8 fd 04 00 00       	call   801044f6 <sched>
  panic("zombie exit");
80103ff9:	83 ec 0c             	sub    $0xc,%esp
80103ffc:	68 5f a8 10 80       	push   $0x8010a85f
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
8010401c:	e8 7f 0b 00 00       	call   80104ba0 <acquire>
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
80104087:	e8 8b 3d 00 00       	call   80107e17 <freevm>
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
801040c6:	e8 43 0b 00 00       	call   80104c0e <release>
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
80104100:	e8 09 0b 00 00       	call   80104c0e <release>
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
8010411a:	e8 10 05 00 00       	call   8010462f <sleep>
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
80104134:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
80104137:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010413a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104141:	00 00 00 

  for (;;) {
    sti();  // 인터럽트 허용
80104144:	e8 2f f8 ff ff       	call   80103978 <sti>

    acquire(&ptable.lock);
80104149:	83 ec 0c             	sub    $0xc,%esp
8010414c:	68 00 42 19 80       	push   $0x80194200
80104151:	e8 4a 0a 00 00       	call   80104ba0 <acquire>
80104156:	83 c4 10             	add    $0x10,%esp

    int policy = c->sched_policy;  // 현재 설정된 스케줄링 정책
80104159:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010415c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104162:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    
    //RR
    if (policy == 0) {
80104165:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
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
8010417f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104182:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104185:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
8010418b:	83 ec 0c             	sub    $0xc,%esp
8010418e:	ff 75 f4             	push   -0xc(%ebp)
80104191:	e8 dc 37 00 00       	call   80107972 <switchuvm>
80104196:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
801041a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a6:	8b 40 1c             	mov    0x1c(%eax),%eax
801041a9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801041ac:	83 c2 04             	add    $0x4,%edx
801041af:	83 ec 08             	sub    $0x8,%esp
801041b2:	50                   	push   %eax
801041b3:	52                   	push   %edx
801041b4:	e8 d2 0e 00 00       	call   8010508b <swtch>
801041b9:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801041bc:	e8 98 37 00 00       	call   80107959 <switchkvm>
        c->proc = 0;
801041c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041c4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041cb:	00 00 00 
801041ce:	eb 01                	jmp    801041d1 <scheduler+0xa8>
          continue;
801041d0:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801041d1:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801041d8:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
801041df:	72 93                	jb     80104174 <scheduler+0x4b>
801041e1:	e9 fb 02 00 00       	jmp    801044e1 <scheduler+0x3b8>
      }
    } else {
      // MLFQ

      // Boosting
      if (policy != 3) {
801041e6:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
801041ea:	0f 84 c1 00 00 00    	je     801042b1 <scheduler+0x188>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801041f0:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801041f7:	e9 a8 00 00 00       	jmp    801042a4 <scheduler+0x17b>
          if (p->state != RUNNABLE)
801041fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104202:	83 f8 03             	cmp    $0x3,%eax
80104205:	0f 85 91 00 00 00    	jne    8010429c <scheduler+0x173>
            continue;

          int curq = p->priority;
8010420b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420e:	8b 40 7c             	mov    0x7c(%eax),%eax
80104211:	89 45 e0             	mov    %eax,-0x20(%ebp)
          int boost_limit[] = {500, 320, 160};
80104214:	c7 45 c0 f4 01 00 00 	movl   $0x1f4,-0x40(%ebp)
8010421b:	c7 45 c4 40 01 00 00 	movl   $0x140,-0x3c(%ebp)
80104222:	c7 45 c8 a0 00 00 00 	movl   $0xa0,-0x38(%ebp)

          if (curq < 3 && p->wait_ticks[curq] >= boost_limit[3 - curq]){
80104229:	83 7d e0 02          	cmpl   $0x2,-0x20(%ebp)
8010422d:	7f 6e                	jg     8010429d <scheduler+0x174>
8010422f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104232:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104235:	83 c2 24             	add    $0x24,%edx
80104238:	8b 14 90             	mov    (%eax,%edx,4),%edx
8010423b:	b8 03 00 00 00       	mov    $0x3,%eax
80104240:	2b 45 e0             	sub    -0x20(%ebp),%eax
80104243:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80104247:	39 c2                	cmp    %eax,%edx
80104249:	7c 52                	jl     8010429d <scheduler+0x174>
            p->priority++;
8010424b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424e:	8b 40 7c             	mov    0x7c(%eax),%eax
80104251:	8d 50 01             	lea    0x1(%eax),%edx
80104254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104257:	89 50 7c             	mov    %edx,0x7c(%eax)
            memset(p->wait_ticks, 0, sizeof(p->wait_ticks));
8010425a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425d:	05 90 00 00 00       	add    $0x90,%eax
80104262:	83 ec 04             	sub    $0x4,%esp
80104265:	6a 10                	push   $0x10
80104267:	6a 00                	push   $0x0
80104269:	50                   	push   %eax
8010426a:	e8 a7 0b 00 00       	call   80104e16 <memset>
8010426f:	83 c4 10             	add    $0x10,%esp
            cprintf("[BOOST] pid %d: wait_ticks = %d → Q%d\n", p->pid, p->wait_ticks[curq], p->priority);
80104272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104275:	8b 48 7c             	mov    0x7c(%eax),%ecx
80104278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010427e:	83 c2 24             	add    $0x24,%edx
80104281:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104287:	8b 40 10             	mov    0x10(%eax),%eax
8010428a:	51                   	push   %ecx
8010428b:	52                   	push   %edx
8010428c:	50                   	push   %eax
8010428d:	68 6c a8 10 80       	push   $0x8010a86c
80104292:	e8 5d c1 ff ff       	call   801003f4 <cprintf>
80104297:	83 c4 10             	add    $0x10,%esp
8010429a:	eb 01                	jmp    8010429d <scheduler+0x174>
            continue;
8010429c:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010429d:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801042a4:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
801042ab:	0f 82 4b ff ff ff    	jb     801041fc <scheduler+0xd3>
          }
        }
      }

      // Time slice 
      int slice[4] = { -1, 32, 16, 8 };
801042b1:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
801042b8:	c7 45 d0 20 00 00 00 	movl   $0x20,-0x30(%ebp)
801042bf:	c7 45 d4 10 00 00 00 	movl   $0x10,-0x2c(%ebp)
801042c6:	c7 45 d8 08 00 00 00 	movl   $0x8,-0x28(%ebp)

      int done = 0;
801042cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

      // Q3부터 순차적으로 찾기
      for (int q = 3; q >= 0 && !done; q--) {
801042d4:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
801042db:	e9 f1 01 00 00       	jmp    801044d1 <scheduler+0x3a8>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801042e0:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801042e7:	e9 d4 01 00 00       	jmp    801044c0 <scheduler+0x397>
          if (p->state != RUNNABLE || p->priority != q)
801042ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ef:	8b 40 0c             	mov    0xc(%eax),%eax
801042f2:	83 f8 03             	cmp    $0x3,%eax
801042f5:	0f 85 bd 01 00 00    	jne    801044b8 <scheduler+0x38f>
801042fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fe:	8b 40 7c             	mov    0x7c(%eax),%eax
80104301:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104304:	0f 85 ae 01 00 00    	jne    801044b8 <scheduler+0x38f>
            continue;

          c->proc = p;
8010430a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010430d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104310:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
80104316:	83 ec 0c             	sub    $0xc,%esp
80104319:	ff 75 f4             	push   -0xc(%ebp)
8010431c:	e8 51 36 00 00       	call   80107972 <switchuvm>
80104321:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
80104324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104327:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
          cprintf("[SCHED] 선택된 pid: %d (Q%d)\n", p->pid, p->priority);  // 🔥 여기
8010432e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104331:	8b 50 7c             	mov    0x7c(%eax),%edx
80104334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104337:	8b 40 10             	mov    0x10(%eax),%eax
8010433a:	83 ec 04             	sub    $0x4,%esp
8010433d:	52                   	push   %edx
8010433e:	50                   	push   %eax
8010433f:	68 98 a8 10 80       	push   $0x8010a898
80104344:	e8 ab c0 ff ff       	call   801003f4 <cprintf>
80104349:	83 c4 10             	add    $0x10,%esp


          int pr = p -> priority;
8010434c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434f:	8b 40 7c             	mov    0x7c(%eax),%eax
80104352:	89 45 dc             	mov    %eax,-0x24(%ebp)

          swtch(&(c->scheduler), p->context);
80104355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104358:	8b 40 1c             	mov    0x1c(%eax),%eax
8010435b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010435e:	83 c2 04             	add    $0x4,%edx
80104361:	83 ec 08             	sub    $0x8,%esp
80104364:	50                   	push   %eax
80104365:	52                   	push   %edx
80104366:	e8 20 0d 00 00       	call   8010508b <swtch>
8010436b:	83 c4 10             	add    $0x10,%esp
          switchkvm();
8010436e:	e8 e6 35 00 00       	call   80107959 <switchkvm>
          c->proc = 0;
80104373:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104376:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010437d:	00 00 00 

          // 정책 2번: tick에 따라 강등
          if (policy == 2) {
80104380:	83 7d e4 02          	cmpl   $0x2,-0x1c(%ebp)
80104384:	0f 85 96 00 00 00    	jne    80104420 <scheduler+0x2f7>
            if ((pr == 3 && p->ticks[3] >= 8) ||
8010438a:	83 7d dc 03          	cmpl   $0x3,-0x24(%ebp)
8010438e:	75 0e                	jne    8010439e <scheduler+0x275>
80104390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104393:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104399:	83 f8 07             	cmp    $0x7,%eax
8010439c:	7f 30                	jg     801043ce <scheduler+0x2a5>
8010439e:	83 7d dc 02          	cmpl   $0x2,-0x24(%ebp)
801043a2:	75 0e                	jne    801043b2 <scheduler+0x289>
                (pr == 2 && p->ticks[2] >= 16) ||
801043a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a7:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801043ad:	83 f8 0f             	cmp    $0xf,%eax
801043b0:	7f 1c                	jg     801043ce <scheduler+0x2a5>
801043b2:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
801043b6:	0f 85 f3 00 00 00    	jne    801044af <scheduler+0x386>
                (pr == 1 && p->ticks[1] >= 32)) {
801043bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bf:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801043c5:	83 f8 1f             	cmp    $0x1f,%eax
801043c8:	0f 8e e1 00 00 00    	jle    801044af <scheduler+0x386>

              if (p->priority > 0){
801043ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d1:	8b 40 7c             	mov    0x7c(%eax),%eax
801043d4:	85 c0                	test   %eax,%eax
801043d6:	7e 2d                	jle    80104405 <scheduler+0x2dc>
                cprintf("[DEMOTE] pid %d: Q%d → Q%d\n", p->pid, pr, pr - 1);
801043d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043db:	8d 50 ff             	lea    -0x1(%eax),%edx
801043de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e1:	8b 40 10             	mov    0x10(%eax),%eax
801043e4:	52                   	push   %edx
801043e5:	ff 75 dc             	push   -0x24(%ebp)
801043e8:	50                   	push   %eax
801043e9:	68 b9 a8 10 80       	push   $0x8010a8b9
801043ee:	e8 01 c0 ff ff       	call   801003f4 <cprintf>
801043f3:	83 c4 10             	add    $0x10,%esp
                p->priority--;
801043f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f9:	8b 40 7c             	mov    0x7c(%eax),%eax
801043fc:	8d 50 ff             	lea    -0x1(%eax),%edx
801043ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104402:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
80104405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104408:	83 e8 80             	sub    $0xffffff80,%eax
8010440b:	83 ec 04             	sub    $0x4,%esp
8010440e:	6a 10                	push   $0x10
80104410:	6a 00                	push   $0x0
80104412:	50                   	push   %eax
80104413:	e8 fe 09 00 00       	call   80104e16 <memset>
80104418:	83 c4 10             	add    $0x10,%esp
8010441b:	e9 8f 00 00 00       	jmp    801044af <scheduler+0x386>
            }
          }

          // 정책 1 & 3: slice 기반 강등
          else {
            if ((pr == 3 && p->ticks[3] >= slice[3]) ||
80104420:	83 7d dc 03          	cmpl   $0x3,-0x24(%ebp)
80104424:	75 10                	jne    80104436 <scheduler+0x30d>
80104426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104429:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
8010442f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104432:	39 c2                	cmp    %eax,%edx
80104434:	7d 2c                	jge    80104462 <scheduler+0x339>
80104436:	83 7d dc 02          	cmpl   $0x2,-0x24(%ebp)
8010443a:	75 10                	jne    8010444c <scheduler+0x323>
                (pr == 2 && p->ticks[2] >= slice[2]) ||
8010443c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443f:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80104445:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104448:	39 c2                	cmp    %eax,%edx
8010444a:	7d 16                	jge    80104462 <scheduler+0x339>
8010444c:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
80104450:	75 5d                	jne    801044af <scheduler+0x386>
                (pr == 1 && p->ticks[1] >= slice[1])) {
80104452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104455:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
8010445b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010445e:	39 c2                	cmp    %eax,%edx
80104460:	7c 4d                	jl     801044af <scheduler+0x386>
              if (p->priority > 0){
80104462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104465:	8b 40 7c             	mov    0x7c(%eax),%eax
80104468:	85 c0                	test   %eax,%eax
8010446a:	7e 2d                	jle    80104499 <scheduler+0x370>
                cprintf("[DEMOTE] pid %d: Q%d → Q%d\n", p->pid, pr, pr - 1);
8010446c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010446f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104475:	8b 40 10             	mov    0x10(%eax),%eax
80104478:	52                   	push   %edx
80104479:	ff 75 dc             	push   -0x24(%ebp)
8010447c:	50                   	push   %eax
8010447d:	68 b9 a8 10 80       	push   $0x8010a8b9
80104482:	e8 6d bf ff ff       	call   801003f4 <cprintf>
80104487:	83 c4 10             	add    $0x10,%esp

                p->priority--;
8010448a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448d:	8b 40 7c             	mov    0x7c(%eax),%eax
80104490:	8d 50 ff             	lea    -0x1(%eax),%edx
80104493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104496:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	83 e8 80             	sub    $0xffffff80,%eax
8010449f:	83 ec 04             	sub    $0x4,%esp
801044a2:	6a 10                	push   $0x10
801044a4:	6a 00                	push   $0x0
801044a6:	50                   	push   %eax
801044a7:	e8 6a 09 00 00       	call   80104e16 <memset>
801044ac:	83 c4 10             	add    $0x10,%esp

            }
          }

          done = 1;
801044af:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
          break;
801044b6:	eb 15                	jmp    801044cd <scheduler+0x3a4>
            continue;
801044b8:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801044b9:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801044c0:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
801044c7:	0f 82 1f fe ff ff    	jb     801042ec <scheduler+0x1c3>
      for (int q = 3; q >= 0 && !done; q--) {
801044cd:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
801044d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801044d5:	78 0a                	js     801044e1 <scheduler+0x3b8>
801044d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801044db:	0f 84 ff fd ff ff    	je     801042e0 <scheduler+0x1b7>
        }
      }
    }

    release(&ptable.lock);
801044e1:	83 ec 0c             	sub    $0xc,%esp
801044e4:	68 00 42 19 80       	push   $0x80194200
801044e9:	e8 20 07 00 00       	call   80104c0e <release>
801044ee:	83 c4 10             	add    $0x10,%esp
  for (;;) {
801044f1:	e9 4e fc ff ff       	jmp    80104144 <scheduler+0x1b>

801044f6 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801044f6:	55                   	push   %ebp
801044f7:	89 e5                	mov    %esp,%ebp
801044f9:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801044fc:	e8 2f f5 ff ff       	call   80103a30 <myproc>
80104501:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104504:	83 ec 0c             	sub    $0xc,%esp
80104507:	68 00 42 19 80       	push   $0x80194200
8010450c:	e8 ca 07 00 00       	call   80104cdb <holding>
80104511:	83 c4 10             	add    $0x10,%esp
80104514:	85 c0                	test   %eax,%eax
80104516:	75 0d                	jne    80104525 <sched+0x2f>
    panic("sched ptable.lock");
80104518:	83 ec 0c             	sub    $0xc,%esp
8010451b:	68 d7 a8 10 80       	push   $0x8010a8d7
80104520:	e8 84 c0 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104525:	e8 8e f4 ff ff       	call   801039b8 <mycpu>
8010452a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104530:	83 f8 01             	cmp    $0x1,%eax
80104533:	74 0d                	je     80104542 <sched+0x4c>
    panic("sched locks");
80104535:	83 ec 0c             	sub    $0xc,%esp
80104538:	68 e9 a8 10 80       	push   $0x8010a8e9
8010453d:	e8 67 c0 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104545:	8b 40 0c             	mov    0xc(%eax),%eax
80104548:	83 f8 04             	cmp    $0x4,%eax
8010454b:	75 0d                	jne    8010455a <sched+0x64>
    panic("sched running");
8010454d:	83 ec 0c             	sub    $0xc,%esp
80104550:	68 f5 a8 10 80       	push   $0x8010a8f5
80104555:	e8 4f c0 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
8010455a:	e8 09 f4 ff ff       	call   80103968 <readeflags>
8010455f:	25 00 02 00 00       	and    $0x200,%eax
80104564:	85 c0                	test   %eax,%eax
80104566:	74 0d                	je     80104575 <sched+0x7f>
    panic("sched interruptible");
80104568:	83 ec 0c             	sub    $0xc,%esp
8010456b:	68 03 a9 10 80       	push   $0x8010a903
80104570:	e8 34 c0 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104575:	e8 3e f4 ff ff       	call   801039b8 <mycpu>
8010457a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104580:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104583:	e8 30 f4 ff ff       	call   801039b8 <mycpu>
80104588:	8b 40 04             	mov    0x4(%eax),%eax
8010458b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010458e:	83 c2 1c             	add    $0x1c,%edx
80104591:	83 ec 08             	sub    $0x8,%esp
80104594:	50                   	push   %eax
80104595:	52                   	push   %edx
80104596:	e8 f0 0a 00 00       	call   8010508b <swtch>
8010459b:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010459e:	e8 15 f4 ff ff       	call   801039b8 <mycpu>
801045a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045a6:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801045ac:	90                   	nop
801045ad:	c9                   	leave  
801045ae:	c3                   	ret    

801045af <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801045af:	55                   	push   %ebp
801045b0:	89 e5                	mov    %esp,%ebp
801045b2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801045b5:	83 ec 0c             	sub    $0xc,%esp
801045b8:	68 00 42 19 80       	push   $0x80194200
801045bd:	e8 de 05 00 00       	call   80104ba0 <acquire>
801045c2:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801045c5:	e8 66 f4 ff ff       	call   80103a30 <myproc>
801045ca:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801045d1:	e8 20 ff ff ff       	call   801044f6 <sched>
  release(&ptable.lock);
801045d6:	83 ec 0c             	sub    $0xc,%esp
801045d9:	68 00 42 19 80       	push   $0x80194200
801045de:	e8 2b 06 00 00       	call   80104c0e <release>
801045e3:	83 c4 10             	add    $0x10,%esp
}
801045e6:	90                   	nop
801045e7:	c9                   	leave  
801045e8:	c3                   	ret    

801045e9 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801045e9:	55                   	push   %ebp
801045ea:	89 e5                	mov    %esp,%ebp
801045ec:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801045ef:	83 ec 0c             	sub    $0xc,%esp
801045f2:	68 00 42 19 80       	push   $0x80194200
801045f7:	e8 12 06 00 00       	call   80104c0e <release>
801045fc:	83 c4 10             	add    $0x10,%esp

  if (first) {
801045ff:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104604:	85 c0                	test   %eax,%eax
80104606:	74 24                	je     8010462c <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104608:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010460f:	00 00 00 
    iinit(ROOTDEV);
80104612:	83 ec 0c             	sub    $0xc,%esp
80104615:	6a 01                	push   $0x1
80104617:	e8 5c d0 ff ff       	call   80101678 <iinit>
8010461c:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010461f:	83 ec 0c             	sub    $0xc,%esp
80104622:	6a 01                	push   $0x1
80104624:	e8 f4 e7 ff ff       	call   80102e1d <initlog>
80104629:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010462c:	90                   	nop
8010462d:	c9                   	leave  
8010462e:	c3                   	ret    

8010462f <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010462f:	55                   	push   %ebp
80104630:	89 e5                	mov    %esp,%ebp
80104632:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104635:	e8 f6 f3 ff ff       	call   80103a30 <myproc>
8010463a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010463d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104641:	75 0d                	jne    80104650 <sleep+0x21>
    panic("sleep");
80104643:	83 ec 0c             	sub    $0xc,%esp
80104646:	68 17 a9 10 80       	push   $0x8010a917
8010464b:	e8 59 bf ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104650:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104654:	75 0d                	jne    80104663 <sleep+0x34>
    panic("sleep without lk");
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	68 1d a9 10 80       	push   $0x8010a91d
8010465e:	e8 46 bf ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104663:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010466a:	74 1e                	je     8010468a <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010466c:	83 ec 0c             	sub    $0xc,%esp
8010466f:	68 00 42 19 80       	push   $0x80194200
80104674:	e8 27 05 00 00       	call   80104ba0 <acquire>
80104679:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010467c:	83 ec 0c             	sub    $0xc,%esp
8010467f:	ff 75 0c             	push   0xc(%ebp)
80104682:	e8 87 05 00 00       	call   80104c0e <release>
80104687:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010468a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468d:	8b 55 08             	mov    0x8(%ebp),%edx
80104690:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104696:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010469d:	e8 54 fe ff ff       	call   801044f6 <sched>

  // Tidy up.
  p->chan = 0;
801046a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a5:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801046ac:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801046b3:	74 1e                	je     801046d3 <sleep+0xa4>
    release(&ptable.lock);
801046b5:	83 ec 0c             	sub    $0xc,%esp
801046b8:	68 00 42 19 80       	push   $0x80194200
801046bd:	e8 4c 05 00 00       	call   80104c0e <release>
801046c2:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801046c5:	83 ec 0c             	sub    $0xc,%esp
801046c8:	ff 75 0c             	push   0xc(%ebp)
801046cb:	e8 d0 04 00 00       	call   80104ba0 <acquire>
801046d0:	83 c4 10             	add    $0x10,%esp
  }
}
801046d3:	90                   	nop
801046d4:	c9                   	leave  
801046d5:	c3                   	ret    

801046d6 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801046d6:	55                   	push   %ebp
801046d7:	89 e5                	mov    %esp,%ebp
801046d9:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801046dc:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
801046e3:	eb 27                	jmp    8010470c <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801046e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801046e8:	8b 40 0c             	mov    0xc(%eax),%eax
801046eb:	83 f8 02             	cmp    $0x2,%eax
801046ee:	75 15                	jne    80104705 <wakeup1+0x2f>
801046f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801046f3:	8b 40 20             	mov    0x20(%eax),%eax
801046f6:	39 45 08             	cmp    %eax,0x8(%ebp)
801046f9:	75 0a                	jne    80104705 <wakeup1+0x2f>
      p->state = RUNNABLE;
801046fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801046fe:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104705:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
8010470c:	81 7d fc 34 6a 19 80 	cmpl   $0x80196a34,-0x4(%ebp)
80104713:	72 d0                	jb     801046e5 <wakeup1+0xf>
}
80104715:	90                   	nop
80104716:	90                   	nop
80104717:	c9                   	leave  
80104718:	c3                   	ret    

80104719 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104719:	55                   	push   %ebp
8010471a:	89 e5                	mov    %esp,%ebp
8010471c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010471f:	83 ec 0c             	sub    $0xc,%esp
80104722:	68 00 42 19 80       	push   $0x80194200
80104727:	e8 74 04 00 00       	call   80104ba0 <acquire>
8010472c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010472f:	83 ec 0c             	sub    $0xc,%esp
80104732:	ff 75 08             	push   0x8(%ebp)
80104735:	e8 9c ff ff ff       	call   801046d6 <wakeup1>
8010473a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010473d:	83 ec 0c             	sub    $0xc,%esp
80104740:	68 00 42 19 80       	push   $0x80194200
80104745:	e8 c4 04 00 00       	call   80104c0e <release>
8010474a:	83 c4 10             	add    $0x10,%esp
}
8010474d:	90                   	nop
8010474e:	c9                   	leave  
8010474f:	c3                   	ret    

80104750 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104750:	55                   	push   %ebp
80104751:	89 e5                	mov    %esp,%ebp
80104753:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104756:	83 ec 0c             	sub    $0xc,%esp
80104759:	68 00 42 19 80       	push   $0x80194200
8010475e:	e8 3d 04 00 00       	call   80104ba0 <acquire>
80104763:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104766:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010476d:	eb 48                	jmp    801047b7 <kill+0x67>
    if(p->pid == pid){
8010476f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104772:	8b 40 10             	mov    0x10(%eax),%eax
80104775:	39 45 08             	cmp    %eax,0x8(%ebp)
80104778:	75 36                	jne    801047b0 <kill+0x60>
      p->killed = 1;
8010477a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104787:	8b 40 0c             	mov    0xc(%eax),%eax
8010478a:	83 f8 02             	cmp    $0x2,%eax
8010478d:	75 0a                	jne    80104799 <kill+0x49>
        p->state = RUNNABLE;
8010478f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104792:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104799:	83 ec 0c             	sub    $0xc,%esp
8010479c:	68 00 42 19 80       	push   $0x80194200
801047a1:	e8 68 04 00 00       	call   80104c0e <release>
801047a6:	83 c4 10             	add    $0x10,%esp
      return 0;
801047a9:	b8 00 00 00 00       	mov    $0x0,%eax
801047ae:	eb 25                	jmp    801047d5 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047b0:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801047b7:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
801047be:	72 af                	jb     8010476f <kill+0x1f>
    }
  }
  release(&ptable.lock);
801047c0:	83 ec 0c             	sub    $0xc,%esp
801047c3:	68 00 42 19 80       	push   $0x80194200
801047c8:	e8 41 04 00 00       	call   80104c0e <release>
801047cd:	83 c4 10             	add    $0x10,%esp
  return -1;
801047d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801047d5:	c9                   	leave  
801047d6:	c3                   	ret    

801047d7 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801047d7:	55                   	push   %ebp
801047d8:	89 e5                	mov    %esp,%ebp
801047da:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047dd:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
801047e4:	e9 da 00 00 00       	jmp    801048c3 <procdump+0xec>
    if(p->state == UNUSED)
801047e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047ec:	8b 40 0c             	mov    0xc(%eax),%eax
801047ef:	85 c0                	test   %eax,%eax
801047f1:	0f 84 c4 00 00 00    	je     801048bb <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801047f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047fa:	8b 40 0c             	mov    0xc(%eax),%eax
801047fd:	83 f8 05             	cmp    $0x5,%eax
80104800:	77 23                	ja     80104825 <procdump+0x4e>
80104802:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104805:	8b 40 0c             	mov    0xc(%eax),%eax
80104808:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010480f:	85 c0                	test   %eax,%eax
80104811:	74 12                	je     80104825 <procdump+0x4e>
      state = states[p->state];
80104813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104816:	8b 40 0c             	mov    0xc(%eax),%eax
80104819:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104820:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104823:	eb 07                	jmp    8010482c <procdump+0x55>
    else
      state = "???";
80104825:	c7 45 ec 2e a9 10 80 	movl   $0x8010a92e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010482c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010482f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104835:	8b 40 10             	mov    0x10(%eax),%eax
80104838:	52                   	push   %edx
80104839:	ff 75 ec             	push   -0x14(%ebp)
8010483c:	50                   	push   %eax
8010483d:	68 32 a9 10 80       	push   $0x8010a932
80104842:	e8 ad bb ff ff       	call   801003f4 <cprintf>
80104847:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010484a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010484d:	8b 40 0c             	mov    0xc(%eax),%eax
80104850:	83 f8 02             	cmp    $0x2,%eax
80104853:	75 54                	jne    801048a9 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104855:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104858:	8b 40 1c             	mov    0x1c(%eax),%eax
8010485b:	8b 40 0c             	mov    0xc(%eax),%eax
8010485e:	83 c0 08             	add    $0x8,%eax
80104861:	89 c2                	mov    %eax,%edx
80104863:	83 ec 08             	sub    $0x8,%esp
80104866:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104869:	50                   	push   %eax
8010486a:	52                   	push   %edx
8010486b:	e8 f0 03 00 00       	call   80104c60 <getcallerpcs>
80104870:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104873:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010487a:	eb 1c                	jmp    80104898 <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010487c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104883:	83 ec 08             	sub    $0x8,%esp
80104886:	50                   	push   %eax
80104887:	68 3b a9 10 80       	push   $0x8010a93b
8010488c:	e8 63 bb ff ff       	call   801003f4 <cprintf>
80104891:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104894:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104898:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010489c:	7f 0b                	jg     801048a9 <procdump+0xd2>
8010489e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801048a5:	85 c0                	test   %eax,%eax
801048a7:	75 d3                	jne    8010487c <procdump+0xa5>
    }
    cprintf("\n");
801048a9:	83 ec 0c             	sub    $0xc,%esp
801048ac:	68 3f a9 10 80       	push   $0x8010a93f
801048b1:	e8 3e bb ff ff       	call   801003f4 <cprintf>
801048b6:	83 c4 10             	add    $0x10,%esp
801048b9:	eb 01                	jmp    801048bc <procdump+0xe5>
      continue;
801048bb:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048bc:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
801048c3:	81 7d f0 34 6a 19 80 	cmpl   $0x80196a34,-0x10(%ebp)
801048ca:	0f 82 19 ff ff ff    	jb     801047e9 <procdump+0x12>
  }
}
801048d0:	90                   	nop
801048d1:	90                   	nop
801048d2:	c9                   	leave  
801048d3:	c3                   	ret    

801048d4 <setSchedPolicy>:

//  0 (RR), 1 (MLFQ), 2 (MLFQ-no-tracking), 3 (MLFQ-no-boosting)

int
setSchedPolicy(int policy)
{
801048d4:	55                   	push   %ebp
801048d5:	89 e5                	mov    %esp,%ebp
801048d7:	83 ec 18             	sub    $0x18,%esp

  if (policy < 0 || policy > 3)
801048da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801048de:	78 06                	js     801048e6 <setSchedPolicy+0x12>
801048e0:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
801048e4:	7e 07                	jle    801048ed <setSchedPolicy+0x19>
    return -1;
801048e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048eb:	eb 23                	jmp    80104910 <setSchedPolicy+0x3c>

  pushcli();
801048ed:	e8 19 04 00 00       	call   80104d0b <pushcli>
  struct cpu *c = mycpu();
801048f2:	e8 c1 f0 ff ff       	call   801039b8 <mycpu>
801048f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->sched_policy = policy;
801048fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fd:	8b 55 08             	mov    0x8(%ebp),%edx
80104900:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104906:	e8 4d 04 00 00       	call   80104d58 <popcli>

  return 0;
8010490b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104910:	c9                   	leave  
80104911:	c3                   	ret    

80104912 <getpinfo>:


int
getpinfo(struct pstat *ps)
{
80104912:	55                   	push   %ebp
80104913:	89 e5                	mov    %esp,%ebp
80104915:	53                   	push   %ebx
80104916:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  int i = 0;
80104919:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);  
80104920:	83 ec 0c             	sub    $0xc,%esp
80104923:	68 00 42 19 80       	push   $0x80194200
80104928:	e8 73 02 00 00       	call   80104ba0 <acquire>
8010492d:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
80104930:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104937:	e9 be 00 00 00       	jmp    801049fa <getpinfo+0xe8>
    // 프로세스가 사용 중이면 1, 아니면 0
    ps->inuse[i] = (p->state != UNUSED);
8010493c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493f:	8b 40 0c             	mov    0xc(%eax),%eax
80104942:	85 c0                	test   %eax,%eax
80104944:	0f 95 c0             	setne  %al
80104947:	0f b6 c8             	movzbl %al,%ecx
8010494a:	8b 45 08             	mov    0x8(%ebp),%eax
8010494d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104950:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // pid 저장
    ps->pid[i] = p->pid;
80104953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104956:	8b 50 10             	mov    0x10(%eax),%edx
80104959:	8b 45 08             	mov    0x8(%ebp),%eax
8010495c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010495f:	83 c1 40             	add    $0x40,%ecx
80104962:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 우선순위 저장 
    ps->priority[i] = p->priority;
80104965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104968:	8b 50 7c             	mov    0x7c(%eax),%edx
8010496b:	8b 45 08             	mov    0x8(%ebp),%eax
8010496e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104971:	83 e9 80             	sub    $0xffffff80,%ecx
80104974:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 상태 저장 
    ps->state[i] = p->state;
80104977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497a:	8b 40 0c             	mov    0xc(%eax),%eax
8010497d:	89 c1                	mov    %eax,%ecx
8010497f:	8b 45 08             	mov    0x8(%ebp),%eax
80104982:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104985:	81 c2 c0 00 00 00    	add    $0xc0,%edx
8010498b:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // 각 큐에서 실행된 tick 수 저장
    for (int j = 0; j < 4; j++) {
8010498e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104995:	eb 52                	jmp    801049e9 <getpinfo+0xd7>
      ps->ticks[i][j] = p->ticks[j];
80104997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010499d:	83 c2 20             	add    $0x20,%edx
801049a0:	8b 14 90             	mov    (%eax,%edx,4),%edx
801049a3:	8b 45 08             	mov    0x8(%ebp),%eax
801049a6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801049a9:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801049b0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801049b3:	01 d9                	add    %ebx,%ecx
801049b5:	81 c1 00 01 00 00    	add    $0x100,%ecx
801049bb:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
801049be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801049c4:	83 c2 24             	add    $0x24,%edx
801049c7:	8b 14 90             	mov    (%eax,%edx,4),%edx
801049ca:	8b 45 08             	mov    0x8(%ebp),%eax
801049cd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801049d0:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801049d7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801049da:	01 d9                	add    %ebx,%ecx
801049dc:	81 c1 00 02 00 00    	add    $0x200,%ecx
801049e2:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
801049e5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801049e9:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
801049ed:	7e a8                	jle    80104997 <getpinfo+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
801049ef:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801049f6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801049fa:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80104a01:	0f 82 35 ff ff ff    	jb     8010493c <getpinfo+0x2a>
    }
  }

  release(&ptable.lock);  
80104a07:	83 ec 0c             	sub    $0xc,%esp
80104a0a:	68 00 42 19 80       	push   $0x80194200
80104a0f:	e8 fa 01 00 00       	call   80104c0e <release>
80104a14:	83 c4 10             	add    $0x10,%esp

  return 0; 
80104a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a1f:	c9                   	leave  
80104a20:	c3                   	ret    

80104a21 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a21:	55                   	push   %ebp
80104a22:	89 e5                	mov    %esp,%ebp
80104a24:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a27:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2a:	83 c0 04             	add    $0x4,%eax
80104a2d:	83 ec 08             	sub    $0x8,%esp
80104a30:	68 6b a9 10 80       	push   $0x8010a96b
80104a35:	50                   	push   %eax
80104a36:	e8 43 01 00 00       	call   80104b7e <initlock>
80104a3b:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a41:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a44:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104a47:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a50:	8b 45 08             	mov    0x8(%ebp),%eax
80104a53:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104a5a:	90                   	nop
80104a5b:	c9                   	leave  
80104a5c:	c3                   	ret    

80104a5d <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104a5d:	55                   	push   %ebp
80104a5e:	89 e5                	mov    %esp,%ebp
80104a60:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a63:	8b 45 08             	mov    0x8(%ebp),%eax
80104a66:	83 c0 04             	add    $0x4,%eax
80104a69:	83 ec 0c             	sub    $0xc,%esp
80104a6c:	50                   	push   %eax
80104a6d:	e8 2e 01 00 00       	call   80104ba0 <acquire>
80104a72:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a75:	eb 15                	jmp    80104a8c <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104a77:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7a:	83 c0 04             	add    $0x4,%eax
80104a7d:	83 ec 08             	sub    $0x8,%esp
80104a80:	50                   	push   %eax
80104a81:	ff 75 08             	push   0x8(%ebp)
80104a84:	e8 a6 fb ff ff       	call   8010462f <sleep>
80104a89:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8f:	8b 00                	mov    (%eax),%eax
80104a91:	85 c0                	test   %eax,%eax
80104a93:	75 e2                	jne    80104a77 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104a95:	8b 45 08             	mov    0x8(%ebp),%eax
80104a98:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104a9e:	e8 8d ef ff ff       	call   80103a30 <myproc>
80104aa3:	8b 50 10             	mov    0x10(%eax),%edx
80104aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa9:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104aac:	8b 45 08             	mov    0x8(%ebp),%eax
80104aaf:	83 c0 04             	add    $0x4,%eax
80104ab2:	83 ec 0c             	sub    $0xc,%esp
80104ab5:	50                   	push   %eax
80104ab6:	e8 53 01 00 00       	call   80104c0e <release>
80104abb:	83 c4 10             	add    $0x10,%esp
}
80104abe:	90                   	nop
80104abf:	c9                   	leave  
80104ac0:	c3                   	ret    

80104ac1 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104ac1:	55                   	push   %ebp
80104ac2:	89 e5                	mov    %esp,%ebp
80104ac4:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80104aca:	83 c0 04             	add    $0x4,%eax
80104acd:	83 ec 0c             	sub    $0xc,%esp
80104ad0:	50                   	push   %eax
80104ad1:	e8 ca 00 00 00       	call   80104ba0 <acquire>
80104ad6:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80104adc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104aec:	83 ec 0c             	sub    $0xc,%esp
80104aef:	ff 75 08             	push   0x8(%ebp)
80104af2:	e8 22 fc ff ff       	call   80104719 <wakeup>
80104af7:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104afa:	8b 45 08             	mov    0x8(%ebp),%eax
80104afd:	83 c0 04             	add    $0x4,%eax
80104b00:	83 ec 0c             	sub    $0xc,%esp
80104b03:	50                   	push   %eax
80104b04:	e8 05 01 00 00       	call   80104c0e <release>
80104b09:	83 c4 10             	add    $0x10,%esp
}
80104b0c:	90                   	nop
80104b0d:	c9                   	leave  
80104b0e:	c3                   	ret    

80104b0f <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104b0f:	55                   	push   %ebp
80104b10:	89 e5                	mov    %esp,%ebp
80104b12:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104b15:	8b 45 08             	mov    0x8(%ebp),%eax
80104b18:	83 c0 04             	add    $0x4,%eax
80104b1b:	83 ec 0c             	sub    $0xc,%esp
80104b1e:	50                   	push   %eax
80104b1f:	e8 7c 00 00 00       	call   80104ba0 <acquire>
80104b24:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b27:	8b 45 08             	mov    0x8(%ebp),%eax
80104b2a:	8b 00                	mov    (%eax),%eax
80104b2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b32:	83 c0 04             	add    $0x4,%eax
80104b35:	83 ec 0c             	sub    $0xc,%esp
80104b38:	50                   	push   %eax
80104b39:	e8 d0 00 00 00       	call   80104c0e <release>
80104b3e:	83 c4 10             	add    $0x10,%esp
  return r;
80104b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b44:	c9                   	leave  
80104b45:	c3                   	ret    

80104b46 <readeflags>:
{
80104b46:	55                   	push   %ebp
80104b47:	89 e5                	mov    %esp,%ebp
80104b49:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b4c:	9c                   	pushf  
80104b4d:	58                   	pop    %eax
80104b4e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b51:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b54:	c9                   	leave  
80104b55:	c3                   	ret    

80104b56 <cli>:
{
80104b56:	55                   	push   %ebp
80104b57:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b59:	fa                   	cli    
}
80104b5a:	90                   	nop
80104b5b:	5d                   	pop    %ebp
80104b5c:	c3                   	ret    

80104b5d <sti>:
{
80104b5d:	55                   	push   %ebp
80104b5e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b60:	fb                   	sti    
}
80104b61:	90                   	nop
80104b62:	5d                   	pop    %ebp
80104b63:	c3                   	ret    

80104b64 <xchg>:
{
80104b64:	55                   	push   %ebp
80104b65:	89 e5                	mov    %esp,%ebp
80104b67:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104b6a:	8b 55 08             	mov    0x8(%ebp),%edx
80104b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b70:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b73:	f0 87 02             	lock xchg %eax,(%edx)
80104b76:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104b79:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b7c:	c9                   	leave  
80104b7d:	c3                   	ret    

80104b7e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b7e:	55                   	push   %ebp
80104b7f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b81:	8b 45 08             	mov    0x8(%ebp),%eax
80104b84:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b87:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b93:	8b 45 08             	mov    0x8(%ebp),%eax
80104b96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b9d:	90                   	nop
80104b9e:	5d                   	pop    %ebp
80104b9f:	c3                   	ret    

80104ba0 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104ba0:	55                   	push   %ebp
80104ba1:	89 e5                	mov    %esp,%ebp
80104ba3:	53                   	push   %ebx
80104ba4:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ba7:	e8 5f 01 00 00       	call   80104d0b <pushcli>
  if(holding(lk)){
80104bac:	8b 45 08             	mov    0x8(%ebp),%eax
80104baf:	83 ec 0c             	sub    $0xc,%esp
80104bb2:	50                   	push   %eax
80104bb3:	e8 23 01 00 00       	call   80104cdb <holding>
80104bb8:	83 c4 10             	add    $0x10,%esp
80104bbb:	85 c0                	test   %eax,%eax
80104bbd:	74 0d                	je     80104bcc <acquire+0x2c>
    panic("acquire");
80104bbf:	83 ec 0c             	sub    $0xc,%esp
80104bc2:	68 76 a9 10 80       	push   $0x8010a976
80104bc7:	e8 dd b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104bcc:	90                   	nop
80104bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd0:	83 ec 08             	sub    $0x8,%esp
80104bd3:	6a 01                	push   $0x1
80104bd5:	50                   	push   %eax
80104bd6:	e8 89 ff ff ff       	call   80104b64 <xchg>
80104bdb:	83 c4 10             	add    $0x10,%esp
80104bde:	85 c0                	test   %eax,%eax
80104be0:	75 eb                	jne    80104bcd <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104be2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104be7:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104bea:	e8 c9 ed ff ff       	call   801039b8 <mycpu>
80104bef:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf5:	83 c0 0c             	add    $0xc,%eax
80104bf8:	83 ec 08             	sub    $0x8,%esp
80104bfb:	50                   	push   %eax
80104bfc:	8d 45 08             	lea    0x8(%ebp),%eax
80104bff:	50                   	push   %eax
80104c00:	e8 5b 00 00 00       	call   80104c60 <getcallerpcs>
80104c05:	83 c4 10             	add    $0x10,%esp
}
80104c08:	90                   	nop
80104c09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c0c:	c9                   	leave  
80104c0d:	c3                   	ret    

80104c0e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c0e:	55                   	push   %ebp
80104c0f:	89 e5                	mov    %esp,%ebp
80104c11:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c14:	83 ec 0c             	sub    $0xc,%esp
80104c17:	ff 75 08             	push   0x8(%ebp)
80104c1a:	e8 bc 00 00 00       	call   80104cdb <holding>
80104c1f:	83 c4 10             	add    $0x10,%esp
80104c22:	85 c0                	test   %eax,%eax
80104c24:	75 0d                	jne    80104c33 <release+0x25>
    panic("release");
80104c26:	83 ec 0c             	sub    $0xc,%esp
80104c29:	68 7e a9 10 80       	push   $0x8010a97e
80104c2e:	e8 76 b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c33:	8b 45 08             	mov    0x8(%ebp),%eax
80104c36:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c40:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104c47:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4f:	8b 55 08             	mov    0x8(%ebp),%edx
80104c52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104c58:	e8 fb 00 00 00       	call   80104d58 <popcli>
}
80104c5d:	90                   	nop
80104c5e:	c9                   	leave  
80104c5f:	c3                   	ret    

80104c60 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104c60:	55                   	push   %ebp
80104c61:	89 e5                	mov    %esp,%ebp
80104c63:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104c66:	8b 45 08             	mov    0x8(%ebp),%eax
80104c69:	83 e8 08             	sub    $0x8,%eax
80104c6c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c6f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c76:	eb 38                	jmp    80104cb0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c78:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c7c:	74 53                	je     80104cd1 <getcallerpcs+0x71>
80104c7e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c85:	76 4a                	jbe    80104cd1 <getcallerpcs+0x71>
80104c87:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c8b:	74 44                	je     80104cd1 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c97:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c9a:	01 c2                	add    %eax,%edx
80104c9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c9f:	8b 40 04             	mov    0x4(%eax),%eax
80104ca2:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104ca4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ca7:	8b 00                	mov    (%eax),%eax
80104ca9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104cac:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cb0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cb4:	7e c2                	jle    80104c78 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104cb6:	eb 19                	jmp    80104cd1 <getcallerpcs+0x71>
    pcs[i] = 0;
80104cb8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cc5:	01 d0                	add    %edx,%eax
80104cc7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104ccd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cd1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cd5:	7e e1                	jle    80104cb8 <getcallerpcs+0x58>
}
80104cd7:	90                   	nop
80104cd8:	90                   	nop
80104cd9:	c9                   	leave  
80104cda:	c3                   	ret    

80104cdb <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104cdb:	55                   	push   %ebp
80104cdc:	89 e5                	mov    %esp,%ebp
80104cde:	53                   	push   %ebx
80104cdf:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce5:	8b 00                	mov    (%eax),%eax
80104ce7:	85 c0                	test   %eax,%eax
80104ce9:	74 16                	je     80104d01 <holding+0x26>
80104ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cee:	8b 58 08             	mov    0x8(%eax),%ebx
80104cf1:	e8 c2 ec ff ff       	call   801039b8 <mycpu>
80104cf6:	39 c3                	cmp    %eax,%ebx
80104cf8:	75 07                	jne    80104d01 <holding+0x26>
80104cfa:	b8 01 00 00 00       	mov    $0x1,%eax
80104cff:	eb 05                	jmp    80104d06 <holding+0x2b>
80104d01:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d09:	c9                   	leave  
80104d0a:	c3                   	ret    

80104d0b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d0b:	55                   	push   %ebp
80104d0c:	89 e5                	mov    %esp,%ebp
80104d0e:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104d11:	e8 30 fe ff ff       	call   80104b46 <readeflags>
80104d16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d19:	e8 38 fe ff ff       	call   80104b56 <cli>
  if(mycpu()->ncli == 0)
80104d1e:	e8 95 ec ff ff       	call   801039b8 <mycpu>
80104d23:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d29:	85 c0                	test   %eax,%eax
80104d2b:	75 14                	jne    80104d41 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d2d:	e8 86 ec ff ff       	call   801039b8 <mycpu>
80104d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d35:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d3b:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d41:	e8 72 ec ff ff       	call   801039b8 <mycpu>
80104d46:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d4c:	83 c2 01             	add    $0x1,%edx
80104d4f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104d55:	90                   	nop
80104d56:	c9                   	leave  
80104d57:	c3                   	ret    

80104d58 <popcli>:

void
popcli(void)
{
80104d58:	55                   	push   %ebp
80104d59:	89 e5                	mov    %esp,%ebp
80104d5b:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104d5e:	e8 e3 fd ff ff       	call   80104b46 <readeflags>
80104d63:	25 00 02 00 00       	and    $0x200,%eax
80104d68:	85 c0                	test   %eax,%eax
80104d6a:	74 0d                	je     80104d79 <popcli+0x21>
    panic("popcli - interruptible");
80104d6c:	83 ec 0c             	sub    $0xc,%esp
80104d6f:	68 86 a9 10 80       	push   $0x8010a986
80104d74:	e8 30 b8 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104d79:	e8 3a ec ff ff       	call   801039b8 <mycpu>
80104d7e:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d84:	83 ea 01             	sub    $0x1,%edx
80104d87:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104d8d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d93:	85 c0                	test   %eax,%eax
80104d95:	79 0d                	jns    80104da4 <popcli+0x4c>
    panic("popcli");
80104d97:	83 ec 0c             	sub    $0xc,%esp
80104d9a:	68 9d a9 10 80       	push   $0x8010a99d
80104d9f:	e8 05 b8 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104da4:	e8 0f ec ff ff       	call   801039b8 <mycpu>
80104da9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104daf:	85 c0                	test   %eax,%eax
80104db1:	75 14                	jne    80104dc7 <popcli+0x6f>
80104db3:	e8 00 ec ff ff       	call   801039b8 <mycpu>
80104db8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104dbe:	85 c0                	test   %eax,%eax
80104dc0:	74 05                	je     80104dc7 <popcli+0x6f>
    sti();
80104dc2:	e8 96 fd ff ff       	call   80104b5d <sti>
}
80104dc7:	90                   	nop
80104dc8:	c9                   	leave  
80104dc9:	c3                   	ret    

80104dca <stosb>:
{
80104dca:	55                   	push   %ebp
80104dcb:	89 e5                	mov    %esp,%ebp
80104dcd:	57                   	push   %edi
80104dce:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104dd2:	8b 55 10             	mov    0x10(%ebp),%edx
80104dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd8:	89 cb                	mov    %ecx,%ebx
80104dda:	89 df                	mov    %ebx,%edi
80104ddc:	89 d1                	mov    %edx,%ecx
80104dde:	fc                   	cld    
80104ddf:	f3 aa                	rep stos %al,%es:(%edi)
80104de1:	89 ca                	mov    %ecx,%edx
80104de3:	89 fb                	mov    %edi,%ebx
80104de5:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104de8:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104deb:	90                   	nop
80104dec:	5b                   	pop    %ebx
80104ded:	5f                   	pop    %edi
80104dee:	5d                   	pop    %ebp
80104def:	c3                   	ret    

80104df0 <stosl>:
{
80104df0:	55                   	push   %ebp
80104df1:	89 e5                	mov    %esp,%ebp
80104df3:	57                   	push   %edi
80104df4:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104df5:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104df8:	8b 55 10             	mov    0x10(%ebp),%edx
80104dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dfe:	89 cb                	mov    %ecx,%ebx
80104e00:	89 df                	mov    %ebx,%edi
80104e02:	89 d1                	mov    %edx,%ecx
80104e04:	fc                   	cld    
80104e05:	f3 ab                	rep stos %eax,%es:(%edi)
80104e07:	89 ca                	mov    %ecx,%edx
80104e09:	89 fb                	mov    %edi,%ebx
80104e0b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e0e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e11:	90                   	nop
80104e12:	5b                   	pop    %ebx
80104e13:	5f                   	pop    %edi
80104e14:	5d                   	pop    %ebp
80104e15:	c3                   	ret    

80104e16 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e16:	55                   	push   %ebp
80104e17:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e19:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1c:	83 e0 03             	and    $0x3,%eax
80104e1f:	85 c0                	test   %eax,%eax
80104e21:	75 43                	jne    80104e66 <memset+0x50>
80104e23:	8b 45 10             	mov    0x10(%ebp),%eax
80104e26:	83 e0 03             	and    $0x3,%eax
80104e29:	85 c0                	test   %eax,%eax
80104e2b:	75 39                	jne    80104e66 <memset+0x50>
    c &= 0xFF;
80104e2d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e34:	8b 45 10             	mov    0x10(%ebp),%eax
80104e37:	c1 e8 02             	shr    $0x2,%eax
80104e3a:	89 c2                	mov    %eax,%edx
80104e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e3f:	c1 e0 18             	shl    $0x18,%eax
80104e42:	89 c1                	mov    %eax,%ecx
80104e44:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e47:	c1 e0 10             	shl    $0x10,%eax
80104e4a:	09 c1                	or     %eax,%ecx
80104e4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e4f:	c1 e0 08             	shl    $0x8,%eax
80104e52:	09 c8                	or     %ecx,%eax
80104e54:	0b 45 0c             	or     0xc(%ebp),%eax
80104e57:	52                   	push   %edx
80104e58:	50                   	push   %eax
80104e59:	ff 75 08             	push   0x8(%ebp)
80104e5c:	e8 8f ff ff ff       	call   80104df0 <stosl>
80104e61:	83 c4 0c             	add    $0xc,%esp
80104e64:	eb 12                	jmp    80104e78 <memset+0x62>
  } else
    stosb(dst, c, n);
80104e66:	8b 45 10             	mov    0x10(%ebp),%eax
80104e69:	50                   	push   %eax
80104e6a:	ff 75 0c             	push   0xc(%ebp)
80104e6d:	ff 75 08             	push   0x8(%ebp)
80104e70:	e8 55 ff ff ff       	call   80104dca <stosb>
80104e75:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104e78:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e7b:	c9                   	leave  
80104e7c:	c3                   	ret    

80104e7d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e7d:	55                   	push   %ebp
80104e7e:	89 e5                	mov    %esp,%ebp
80104e80:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104e83:	8b 45 08             	mov    0x8(%ebp),%eax
80104e86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e8f:	eb 30                	jmp    80104ec1 <memcmp+0x44>
    if(*s1 != *s2)
80104e91:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e94:	0f b6 10             	movzbl (%eax),%edx
80104e97:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e9a:	0f b6 00             	movzbl (%eax),%eax
80104e9d:	38 c2                	cmp    %al,%dl
80104e9f:	74 18                	je     80104eb9 <memcmp+0x3c>
      return *s1 - *s2;
80104ea1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ea4:	0f b6 00             	movzbl (%eax),%eax
80104ea7:	0f b6 d0             	movzbl %al,%edx
80104eaa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ead:	0f b6 00             	movzbl (%eax),%eax
80104eb0:	0f b6 c8             	movzbl %al,%ecx
80104eb3:	89 d0                	mov    %edx,%eax
80104eb5:	29 c8                	sub    %ecx,%eax
80104eb7:	eb 1a                	jmp    80104ed3 <memcmp+0x56>
    s1++, s2++;
80104eb9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ebd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104ec1:	8b 45 10             	mov    0x10(%ebp),%eax
80104ec4:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ec7:	89 55 10             	mov    %edx,0x10(%ebp)
80104eca:	85 c0                	test   %eax,%eax
80104ecc:	75 c3                	jne    80104e91 <memcmp+0x14>
  }

  return 0;
80104ece:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ed3:	c9                   	leave  
80104ed4:	c3                   	ret    

80104ed5 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ed5:	55                   	push   %ebp
80104ed6:	89 e5                	mov    %esp,%ebp
80104ed8:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104edb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ede:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104ee7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104eed:	73 54                	jae    80104f43 <memmove+0x6e>
80104eef:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ef2:	8b 45 10             	mov    0x10(%ebp),%eax
80104ef5:	01 d0                	add    %edx,%eax
80104ef7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104efa:	73 47                	jae    80104f43 <memmove+0x6e>
    s += n;
80104efc:	8b 45 10             	mov    0x10(%ebp),%eax
80104eff:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104f02:	8b 45 10             	mov    0x10(%ebp),%eax
80104f05:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f08:	eb 13                	jmp    80104f1d <memmove+0x48>
      *--d = *--s;
80104f0a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f0e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f12:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f15:	0f b6 10             	movzbl (%eax),%edx
80104f18:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f1b:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f1d:	8b 45 10             	mov    0x10(%ebp),%eax
80104f20:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f23:	89 55 10             	mov    %edx,0x10(%ebp)
80104f26:	85 c0                	test   %eax,%eax
80104f28:	75 e0                	jne    80104f0a <memmove+0x35>
  if(s < d && s + n > d){
80104f2a:	eb 24                	jmp    80104f50 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f2c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f2f:	8d 42 01             	lea    0x1(%edx),%eax
80104f32:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f35:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f38:	8d 48 01             	lea    0x1(%eax),%ecx
80104f3b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104f3e:	0f b6 12             	movzbl (%edx),%edx
80104f41:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f43:	8b 45 10             	mov    0x10(%ebp),%eax
80104f46:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f49:	89 55 10             	mov    %edx,0x10(%ebp)
80104f4c:	85 c0                	test   %eax,%eax
80104f4e:	75 dc                	jne    80104f2c <memmove+0x57>

  return dst;
80104f50:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f53:	c9                   	leave  
80104f54:	c3                   	ret    

80104f55 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f55:	55                   	push   %ebp
80104f56:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f58:	ff 75 10             	push   0x10(%ebp)
80104f5b:	ff 75 0c             	push   0xc(%ebp)
80104f5e:	ff 75 08             	push   0x8(%ebp)
80104f61:	e8 6f ff ff ff       	call   80104ed5 <memmove>
80104f66:	83 c4 0c             	add    $0xc,%esp
}
80104f69:	c9                   	leave  
80104f6a:	c3                   	ret    

80104f6b <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f6b:	55                   	push   %ebp
80104f6c:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104f6e:	eb 0c                	jmp    80104f7c <strncmp+0x11>
    n--, p++, q++;
80104f70:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f74:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f78:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104f7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f80:	74 1a                	je     80104f9c <strncmp+0x31>
80104f82:	8b 45 08             	mov    0x8(%ebp),%eax
80104f85:	0f b6 00             	movzbl (%eax),%eax
80104f88:	84 c0                	test   %al,%al
80104f8a:	74 10                	je     80104f9c <strncmp+0x31>
80104f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8f:	0f b6 10             	movzbl (%eax),%edx
80104f92:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f95:	0f b6 00             	movzbl (%eax),%eax
80104f98:	38 c2                	cmp    %al,%dl
80104f9a:	74 d4                	je     80104f70 <strncmp+0x5>
  if(n == 0)
80104f9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fa0:	75 07                	jne    80104fa9 <strncmp+0x3e>
    return 0;
80104fa2:	b8 00 00 00 00       	mov    $0x0,%eax
80104fa7:	eb 16                	jmp    80104fbf <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fac:	0f b6 00             	movzbl (%eax),%eax
80104faf:	0f b6 d0             	movzbl %al,%edx
80104fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fb5:	0f b6 00             	movzbl (%eax),%eax
80104fb8:	0f b6 c8             	movzbl %al,%ecx
80104fbb:	89 d0                	mov    %edx,%eax
80104fbd:	29 c8                	sub    %ecx,%eax
}
80104fbf:	5d                   	pop    %ebp
80104fc0:	c3                   	ret    

80104fc1 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104fc1:	55                   	push   %ebp
80104fc2:	89 e5                	mov    %esp,%ebp
80104fc4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104fca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104fcd:	90                   	nop
80104fce:	8b 45 10             	mov    0x10(%ebp),%eax
80104fd1:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fd4:	89 55 10             	mov    %edx,0x10(%ebp)
80104fd7:	85 c0                	test   %eax,%eax
80104fd9:	7e 2c                	jle    80105007 <strncpy+0x46>
80104fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fde:	8d 42 01             	lea    0x1(%edx),%eax
80104fe1:	89 45 0c             	mov    %eax,0xc(%ebp)
80104fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe7:	8d 48 01             	lea    0x1(%eax),%ecx
80104fea:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fed:	0f b6 12             	movzbl (%edx),%edx
80104ff0:	88 10                	mov    %dl,(%eax)
80104ff2:	0f b6 00             	movzbl (%eax),%eax
80104ff5:	84 c0                	test   %al,%al
80104ff7:	75 d5                	jne    80104fce <strncpy+0xd>
    ;
  while(n-- > 0)
80104ff9:	eb 0c                	jmp    80105007 <strncpy+0x46>
    *s++ = 0;
80104ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ffe:	8d 50 01             	lea    0x1(%eax),%edx
80105001:	89 55 08             	mov    %edx,0x8(%ebp)
80105004:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105007:	8b 45 10             	mov    0x10(%ebp),%eax
8010500a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010500d:	89 55 10             	mov    %edx,0x10(%ebp)
80105010:	85 c0                	test   %eax,%eax
80105012:	7f e7                	jg     80104ffb <strncpy+0x3a>
  return os;
80105014:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105017:	c9                   	leave  
80105018:	c3                   	ret    

80105019 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105019:	55                   	push   %ebp
8010501a:	89 e5                	mov    %esp,%ebp
8010501c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010501f:	8b 45 08             	mov    0x8(%ebp),%eax
80105022:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105025:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105029:	7f 05                	jg     80105030 <safestrcpy+0x17>
    return os;
8010502b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010502e:	eb 32                	jmp    80105062 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105030:	90                   	nop
80105031:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105035:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105039:	7e 1e                	jle    80105059 <safestrcpy+0x40>
8010503b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010503e:	8d 42 01             	lea    0x1(%edx),%eax
80105041:	89 45 0c             	mov    %eax,0xc(%ebp)
80105044:	8b 45 08             	mov    0x8(%ebp),%eax
80105047:	8d 48 01             	lea    0x1(%eax),%ecx
8010504a:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010504d:	0f b6 12             	movzbl (%edx),%edx
80105050:	88 10                	mov    %dl,(%eax)
80105052:	0f b6 00             	movzbl (%eax),%eax
80105055:	84 c0                	test   %al,%al
80105057:	75 d8                	jne    80105031 <safestrcpy+0x18>
    ;
  *s = 0;
80105059:	8b 45 08             	mov    0x8(%ebp),%eax
8010505c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010505f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105062:	c9                   	leave  
80105063:	c3                   	ret    

80105064 <strlen>:

int
strlen(const char *s)
{
80105064:	55                   	push   %ebp
80105065:	89 e5                	mov    %esp,%ebp
80105067:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010506a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105071:	eb 04                	jmp    80105077 <strlen+0x13>
80105073:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105077:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010507a:	8b 45 08             	mov    0x8(%ebp),%eax
8010507d:	01 d0                	add    %edx,%eax
8010507f:	0f b6 00             	movzbl (%eax),%eax
80105082:	84 c0                	test   %al,%al
80105084:	75 ed                	jne    80105073 <strlen+0xf>
    ;
  return n;
80105086:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105089:	c9                   	leave  
8010508a:	c3                   	ret    

8010508b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010508b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010508f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105093:	55                   	push   %ebp
  pushl %ebx
80105094:	53                   	push   %ebx
  pushl %esi
80105095:	56                   	push   %esi
  pushl %edi
80105096:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105097:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105099:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010509b:	5f                   	pop    %edi
  popl %esi
8010509c:	5e                   	pop    %esi
  popl %ebx
8010509d:	5b                   	pop    %ebx
  popl %ebp
8010509e:	5d                   	pop    %ebp
  ret
8010509f:	c3                   	ret    

801050a0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801050a0:	55                   	push   %ebp
801050a1:	89 e5                	mov    %esp,%ebp
801050a3:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801050a6:	e8 85 e9 ff ff       	call   80103a30 <myproc>
801050ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801050ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b1:	8b 00                	mov    (%eax),%eax
801050b3:	39 45 08             	cmp    %eax,0x8(%ebp)
801050b6:	73 0f                	jae    801050c7 <fetchint+0x27>
801050b8:	8b 45 08             	mov    0x8(%ebp),%eax
801050bb:	8d 50 04             	lea    0x4(%eax),%edx
801050be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c1:	8b 00                	mov    (%eax),%eax
801050c3:	39 c2                	cmp    %eax,%edx
801050c5:	76 07                	jbe    801050ce <fetchint+0x2e>
    return -1;
801050c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050cc:	eb 0f                	jmp    801050dd <fetchint+0x3d>
  *ip = *(int*)(addr);
801050ce:	8b 45 08             	mov    0x8(%ebp),%eax
801050d1:	8b 10                	mov    (%eax),%edx
801050d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d6:	89 10                	mov    %edx,(%eax)
  return 0;
801050d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050dd:	c9                   	leave  
801050de:	c3                   	ret    

801050df <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801050df:	55                   	push   %ebp
801050e0:	89 e5                	mov    %esp,%ebp
801050e2:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801050e5:	e8 46 e9 ff ff       	call   80103a30 <myproc>
801050ea:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801050ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f0:	8b 00                	mov    (%eax),%eax
801050f2:	39 45 08             	cmp    %eax,0x8(%ebp)
801050f5:	72 07                	jb     801050fe <fetchstr+0x1f>
    return -1;
801050f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050fc:	eb 41                	jmp    8010513f <fetchstr+0x60>
  *pp = (char*)addr;
801050fe:	8b 55 08             	mov    0x8(%ebp),%edx
80105101:	8b 45 0c             	mov    0xc(%ebp),%eax
80105104:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105106:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105109:	8b 00                	mov    (%eax),%eax
8010510b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010510e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105111:	8b 00                	mov    (%eax),%eax
80105113:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105116:	eb 1a                	jmp    80105132 <fetchstr+0x53>
    if(*s == 0)
80105118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511b:	0f b6 00             	movzbl (%eax),%eax
8010511e:	84 c0                	test   %al,%al
80105120:	75 0c                	jne    8010512e <fetchstr+0x4f>
      return s - *pp;
80105122:	8b 45 0c             	mov    0xc(%ebp),%eax
80105125:	8b 10                	mov    (%eax),%edx
80105127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512a:	29 d0                	sub    %edx,%eax
8010512c:	eb 11                	jmp    8010513f <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
8010512e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105135:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105138:	72 de                	jb     80105118 <fetchstr+0x39>
  }
  return -1;
8010513a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010513f:	c9                   	leave  
80105140:	c3                   	ret    

80105141 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105141:	55                   	push   %ebp
80105142:	89 e5                	mov    %esp,%ebp
80105144:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105147:	e8 e4 e8 ff ff       	call   80103a30 <myproc>
8010514c:	8b 40 18             	mov    0x18(%eax),%eax
8010514f:	8b 50 44             	mov    0x44(%eax),%edx
80105152:	8b 45 08             	mov    0x8(%ebp),%eax
80105155:	c1 e0 02             	shl    $0x2,%eax
80105158:	01 d0                	add    %edx,%eax
8010515a:	83 c0 04             	add    $0x4,%eax
8010515d:	83 ec 08             	sub    $0x8,%esp
80105160:	ff 75 0c             	push   0xc(%ebp)
80105163:	50                   	push   %eax
80105164:	e8 37 ff ff ff       	call   801050a0 <fetchint>
80105169:	83 c4 10             	add    $0x10,%esp
}
8010516c:	c9                   	leave  
8010516d:	c3                   	ret    

8010516e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010516e:	55                   	push   %ebp
8010516f:	89 e5                	mov    %esp,%ebp
80105171:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105174:	e8 b7 e8 ff ff       	call   80103a30 <myproc>
80105179:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010517c:	83 ec 08             	sub    $0x8,%esp
8010517f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105182:	50                   	push   %eax
80105183:	ff 75 08             	push   0x8(%ebp)
80105186:	e8 b6 ff ff ff       	call   80105141 <argint>
8010518b:	83 c4 10             	add    $0x10,%esp
8010518e:	85 c0                	test   %eax,%eax
80105190:	79 07                	jns    80105199 <argptr+0x2b>
    return -1;
80105192:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105197:	eb 3b                	jmp    801051d4 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105199:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010519d:	78 1f                	js     801051be <argptr+0x50>
8010519f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a2:	8b 00                	mov    (%eax),%eax
801051a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051a7:	39 d0                	cmp    %edx,%eax
801051a9:	76 13                	jbe    801051be <argptr+0x50>
801051ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ae:	89 c2                	mov    %eax,%edx
801051b0:	8b 45 10             	mov    0x10(%ebp),%eax
801051b3:	01 c2                	add    %eax,%edx
801051b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b8:	8b 00                	mov    (%eax),%eax
801051ba:	39 c2                	cmp    %eax,%edx
801051bc:	76 07                	jbe    801051c5 <argptr+0x57>
    return -1;
801051be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051c3:	eb 0f                	jmp    801051d4 <argptr+0x66>
  *pp = (char*)i;
801051c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051c8:	89 c2                	mov    %eax,%edx
801051ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801051cd:	89 10                	mov    %edx,(%eax)
  return 0;
801051cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051d4:	c9                   	leave  
801051d5:	c3                   	ret    

801051d6 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801051d6:	55                   	push   %ebp
801051d7:	89 e5                	mov    %esp,%ebp
801051d9:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801051dc:	83 ec 08             	sub    $0x8,%esp
801051df:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051e2:	50                   	push   %eax
801051e3:	ff 75 08             	push   0x8(%ebp)
801051e6:	e8 56 ff ff ff       	call   80105141 <argint>
801051eb:	83 c4 10             	add    $0x10,%esp
801051ee:	85 c0                	test   %eax,%eax
801051f0:	79 07                	jns    801051f9 <argstr+0x23>
    return -1;
801051f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f7:	eb 12                	jmp    8010520b <argstr+0x35>
  return fetchstr(addr, pp);
801051f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fc:	83 ec 08             	sub    $0x8,%esp
801051ff:	ff 75 0c             	push   0xc(%ebp)
80105202:	50                   	push   %eax
80105203:	e8 d7 fe ff ff       	call   801050df <fetchstr>
80105208:	83 c4 10             	add    $0x10,%esp
}
8010520b:	c9                   	leave  
8010520c:	c3                   	ret    

8010520d <syscall>:
[SYS_getpinfo] sys_getpinfo,
};

void
syscall(void)
{
8010520d:	55                   	push   %ebp
8010520e:	89 e5                	mov    %esp,%ebp
80105210:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105213:	e8 18 e8 ff ff       	call   80103a30 <myproc>
80105218:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010521b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521e:	8b 40 18             	mov    0x18(%eax),%eax
80105221:	8b 40 1c             	mov    0x1c(%eax),%eax
80105224:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105227:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010522b:	7e 2f                	jle    8010525c <syscall+0x4f>
8010522d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105230:	83 f8 17             	cmp    $0x17,%eax
80105233:	77 27                	ja     8010525c <syscall+0x4f>
80105235:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105238:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010523f:	85 c0                	test   %eax,%eax
80105241:	74 19                	je     8010525c <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105243:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105246:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010524d:	ff d0                	call   *%eax
8010524f:	89 c2                	mov    %eax,%edx
80105251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105254:	8b 40 18             	mov    0x18(%eax),%eax
80105257:	89 50 1c             	mov    %edx,0x1c(%eax)
8010525a:	eb 2c                	jmp    80105288 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010525c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525f:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105265:	8b 40 10             	mov    0x10(%eax),%eax
80105268:	ff 75 f0             	push   -0x10(%ebp)
8010526b:	52                   	push   %edx
8010526c:	50                   	push   %eax
8010526d:	68 a4 a9 10 80       	push   $0x8010a9a4
80105272:	e8 7d b1 ff ff       	call   801003f4 <cprintf>
80105277:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
8010527a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527d:	8b 40 18             	mov    0x18(%eax),%eax
80105280:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105287:	90                   	nop
80105288:	90                   	nop
80105289:	c9                   	leave  
8010528a:	c3                   	ret    

8010528b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010528b:	55                   	push   %ebp
8010528c:	89 e5                	mov    %esp,%ebp
8010528e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105291:	83 ec 08             	sub    $0x8,%esp
80105294:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105297:	50                   	push   %eax
80105298:	ff 75 08             	push   0x8(%ebp)
8010529b:	e8 a1 fe ff ff       	call   80105141 <argint>
801052a0:	83 c4 10             	add    $0x10,%esp
801052a3:	85 c0                	test   %eax,%eax
801052a5:	79 07                	jns    801052ae <argfd+0x23>
    return -1;
801052a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ac:	eb 4f                	jmp    801052fd <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801052ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b1:	85 c0                	test   %eax,%eax
801052b3:	78 20                	js     801052d5 <argfd+0x4a>
801052b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b8:	83 f8 0f             	cmp    $0xf,%eax
801052bb:	7f 18                	jg     801052d5 <argfd+0x4a>
801052bd:	e8 6e e7 ff ff       	call   80103a30 <myproc>
801052c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052c5:	83 c2 08             	add    $0x8,%edx
801052c8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052d3:	75 07                	jne    801052dc <argfd+0x51>
    return -1;
801052d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052da:	eb 21                	jmp    801052fd <argfd+0x72>
  if(pfd)
801052dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052e0:	74 08                	je     801052ea <argfd+0x5f>
    *pfd = fd;
801052e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e8:	89 10                	mov    %edx,(%eax)
  if(pf)
801052ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052ee:	74 08                	je     801052f8 <argfd+0x6d>
    *pf = f;
801052f0:	8b 45 10             	mov    0x10(%ebp),%eax
801052f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052f6:	89 10                	mov    %edx,(%eax)
  return 0;
801052f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052fd:	c9                   	leave  
801052fe:	c3                   	ret    

801052ff <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801052ff:	55                   	push   %ebp
80105300:	89 e5                	mov    %esp,%ebp
80105302:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105305:	e8 26 e7 ff ff       	call   80103a30 <myproc>
8010530a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010530d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105314:	eb 2a                	jmp    80105340 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105316:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105319:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010531c:	83 c2 08             	add    $0x8,%edx
8010531f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105323:	85 c0                	test   %eax,%eax
80105325:	75 15                	jne    8010533c <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105327:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010532a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010532d:	8d 4a 08             	lea    0x8(%edx),%ecx
80105330:	8b 55 08             	mov    0x8(%ebp),%edx
80105333:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533a:	eb 0f                	jmp    8010534b <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010533c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105340:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105344:	7e d0                	jle    80105316 <fdalloc+0x17>
    }
  }
  return -1;
80105346:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010534b:	c9                   	leave  
8010534c:	c3                   	ret    

8010534d <sys_dup>:

int
sys_dup(void)
{
8010534d:	55                   	push   %ebp
8010534e:	89 e5                	mov    %esp,%ebp
80105350:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105353:	83 ec 04             	sub    $0x4,%esp
80105356:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105359:	50                   	push   %eax
8010535a:	6a 00                	push   $0x0
8010535c:	6a 00                	push   $0x0
8010535e:	e8 28 ff ff ff       	call   8010528b <argfd>
80105363:	83 c4 10             	add    $0x10,%esp
80105366:	85 c0                	test   %eax,%eax
80105368:	79 07                	jns    80105371 <sys_dup+0x24>
    return -1;
8010536a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010536f:	eb 31                	jmp    801053a2 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105374:	83 ec 0c             	sub    $0xc,%esp
80105377:	50                   	push   %eax
80105378:	e8 82 ff ff ff       	call   801052ff <fdalloc>
8010537d:	83 c4 10             	add    $0x10,%esp
80105380:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105383:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105387:	79 07                	jns    80105390 <sys_dup+0x43>
    return -1;
80105389:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010538e:	eb 12                	jmp    801053a2 <sys_dup+0x55>
  filedup(f);
80105390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105393:	83 ec 0c             	sub    $0xc,%esp
80105396:	50                   	push   %eax
80105397:	e8 ae bc ff ff       	call   8010104a <filedup>
8010539c:	83 c4 10             	add    $0x10,%esp
  return fd;
8010539f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053a2:	c9                   	leave  
801053a3:	c3                   	ret    

801053a4 <sys_read>:

int
sys_read(void)
{
801053a4:	55                   	push   %ebp
801053a5:	89 e5                	mov    %esp,%ebp
801053a7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053aa:	83 ec 04             	sub    $0x4,%esp
801053ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053b0:	50                   	push   %eax
801053b1:	6a 00                	push   $0x0
801053b3:	6a 00                	push   $0x0
801053b5:	e8 d1 fe ff ff       	call   8010528b <argfd>
801053ba:	83 c4 10             	add    $0x10,%esp
801053bd:	85 c0                	test   %eax,%eax
801053bf:	78 2e                	js     801053ef <sys_read+0x4b>
801053c1:	83 ec 08             	sub    $0x8,%esp
801053c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053c7:	50                   	push   %eax
801053c8:	6a 02                	push   $0x2
801053ca:	e8 72 fd ff ff       	call   80105141 <argint>
801053cf:	83 c4 10             	add    $0x10,%esp
801053d2:	85 c0                	test   %eax,%eax
801053d4:	78 19                	js     801053ef <sys_read+0x4b>
801053d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d9:	83 ec 04             	sub    $0x4,%esp
801053dc:	50                   	push   %eax
801053dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053e0:	50                   	push   %eax
801053e1:	6a 01                	push   $0x1
801053e3:	e8 86 fd ff ff       	call   8010516e <argptr>
801053e8:	83 c4 10             	add    $0x10,%esp
801053eb:	85 c0                	test   %eax,%eax
801053ed:	79 07                	jns    801053f6 <sys_read+0x52>
    return -1;
801053ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053f4:	eb 17                	jmp    8010540d <sys_read+0x69>
  return fileread(f, p, n);
801053f6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ff:	83 ec 04             	sub    $0x4,%esp
80105402:	51                   	push   %ecx
80105403:	52                   	push   %edx
80105404:	50                   	push   %eax
80105405:	e8 d0 bd ff ff       	call   801011da <fileread>
8010540a:	83 c4 10             	add    $0x10,%esp
}
8010540d:	c9                   	leave  
8010540e:	c3                   	ret    

8010540f <sys_write>:

int
sys_write(void)
{
8010540f:	55                   	push   %ebp
80105410:	89 e5                	mov    %esp,%ebp
80105412:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105415:	83 ec 04             	sub    $0x4,%esp
80105418:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010541b:	50                   	push   %eax
8010541c:	6a 00                	push   $0x0
8010541e:	6a 00                	push   $0x0
80105420:	e8 66 fe ff ff       	call   8010528b <argfd>
80105425:	83 c4 10             	add    $0x10,%esp
80105428:	85 c0                	test   %eax,%eax
8010542a:	78 2e                	js     8010545a <sys_write+0x4b>
8010542c:	83 ec 08             	sub    $0x8,%esp
8010542f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105432:	50                   	push   %eax
80105433:	6a 02                	push   $0x2
80105435:	e8 07 fd ff ff       	call   80105141 <argint>
8010543a:	83 c4 10             	add    $0x10,%esp
8010543d:	85 c0                	test   %eax,%eax
8010543f:	78 19                	js     8010545a <sys_write+0x4b>
80105441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105444:	83 ec 04             	sub    $0x4,%esp
80105447:	50                   	push   %eax
80105448:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010544b:	50                   	push   %eax
8010544c:	6a 01                	push   $0x1
8010544e:	e8 1b fd ff ff       	call   8010516e <argptr>
80105453:	83 c4 10             	add    $0x10,%esp
80105456:	85 c0                	test   %eax,%eax
80105458:	79 07                	jns    80105461 <sys_write+0x52>
    return -1;
8010545a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545f:	eb 17                	jmp    80105478 <sys_write+0x69>
  return filewrite(f, p, n);
80105461:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105464:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010546a:	83 ec 04             	sub    $0x4,%esp
8010546d:	51                   	push   %ecx
8010546e:	52                   	push   %edx
8010546f:	50                   	push   %eax
80105470:	e8 1d be ff ff       	call   80101292 <filewrite>
80105475:	83 c4 10             	add    $0x10,%esp
}
80105478:	c9                   	leave  
80105479:	c3                   	ret    

8010547a <sys_close>:

int
sys_close(void)
{
8010547a:	55                   	push   %ebp
8010547b:	89 e5                	mov    %esp,%ebp
8010547d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105480:	83 ec 04             	sub    $0x4,%esp
80105483:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105486:	50                   	push   %eax
80105487:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010548a:	50                   	push   %eax
8010548b:	6a 00                	push   $0x0
8010548d:	e8 f9 fd ff ff       	call   8010528b <argfd>
80105492:	83 c4 10             	add    $0x10,%esp
80105495:	85 c0                	test   %eax,%eax
80105497:	79 07                	jns    801054a0 <sys_close+0x26>
    return -1;
80105499:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010549e:	eb 27                	jmp    801054c7 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801054a0:	e8 8b e5 ff ff       	call   80103a30 <myproc>
801054a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054a8:	83 c2 08             	add    $0x8,%edx
801054ab:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054b2:	00 
  fileclose(f);
801054b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b6:	83 ec 0c             	sub    $0xc,%esp
801054b9:	50                   	push   %eax
801054ba:	e8 dc bb ff ff       	call   8010109b <fileclose>
801054bf:	83 c4 10             	add    $0x10,%esp
  return 0;
801054c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054c7:	c9                   	leave  
801054c8:	c3                   	ret    

801054c9 <sys_fstat>:

int
sys_fstat(void)
{
801054c9:	55                   	push   %ebp
801054ca:	89 e5                	mov    %esp,%ebp
801054cc:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054cf:	83 ec 04             	sub    $0x4,%esp
801054d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054d5:	50                   	push   %eax
801054d6:	6a 00                	push   $0x0
801054d8:	6a 00                	push   $0x0
801054da:	e8 ac fd ff ff       	call   8010528b <argfd>
801054df:	83 c4 10             	add    $0x10,%esp
801054e2:	85 c0                	test   %eax,%eax
801054e4:	78 17                	js     801054fd <sys_fstat+0x34>
801054e6:	83 ec 04             	sub    $0x4,%esp
801054e9:	6a 14                	push   $0x14
801054eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054ee:	50                   	push   %eax
801054ef:	6a 01                	push   $0x1
801054f1:	e8 78 fc ff ff       	call   8010516e <argptr>
801054f6:	83 c4 10             	add    $0x10,%esp
801054f9:	85 c0                	test   %eax,%eax
801054fb:	79 07                	jns    80105504 <sys_fstat+0x3b>
    return -1;
801054fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105502:	eb 13                	jmp    80105517 <sys_fstat+0x4e>
  return filestat(f, st);
80105504:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550a:	83 ec 08             	sub    $0x8,%esp
8010550d:	52                   	push   %edx
8010550e:	50                   	push   %eax
8010550f:	e8 6f bc ff ff       	call   80101183 <filestat>
80105514:	83 c4 10             	add    $0x10,%esp
}
80105517:	c9                   	leave  
80105518:	c3                   	ret    

80105519 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105519:	55                   	push   %ebp
8010551a:	89 e5                	mov    %esp,%ebp
8010551c:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010551f:	83 ec 08             	sub    $0x8,%esp
80105522:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105525:	50                   	push   %eax
80105526:	6a 00                	push   $0x0
80105528:	e8 a9 fc ff ff       	call   801051d6 <argstr>
8010552d:	83 c4 10             	add    $0x10,%esp
80105530:	85 c0                	test   %eax,%eax
80105532:	78 15                	js     80105549 <sys_link+0x30>
80105534:	83 ec 08             	sub    $0x8,%esp
80105537:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010553a:	50                   	push   %eax
8010553b:	6a 01                	push   $0x1
8010553d:	e8 94 fc ff ff       	call   801051d6 <argstr>
80105542:	83 c4 10             	add    $0x10,%esp
80105545:	85 c0                	test   %eax,%eax
80105547:	79 0a                	jns    80105553 <sys_link+0x3a>
    return -1;
80105549:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554e:	e9 68 01 00 00       	jmp    801056bb <sys_link+0x1a2>

  begin_op();
80105553:	e8 e4 da ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
80105558:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010555b:	83 ec 0c             	sub    $0xc,%esp
8010555e:	50                   	push   %eax
8010555f:	e8 b9 cf ff ff       	call   8010251d <namei>
80105564:	83 c4 10             	add    $0x10,%esp
80105567:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010556a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010556e:	75 0f                	jne    8010557f <sys_link+0x66>
    end_op();
80105570:	e8 53 db ff ff       	call   801030c8 <end_op>
    return -1;
80105575:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010557a:	e9 3c 01 00 00       	jmp    801056bb <sys_link+0x1a2>
  }

  ilock(ip);
8010557f:	83 ec 0c             	sub    $0xc,%esp
80105582:	ff 75 f4             	push   -0xc(%ebp)
80105585:	e8 60 c4 ff ff       	call   801019ea <ilock>
8010558a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010558d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105590:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105594:	66 83 f8 01          	cmp    $0x1,%ax
80105598:	75 1d                	jne    801055b7 <sys_link+0x9e>
    iunlockput(ip);
8010559a:	83 ec 0c             	sub    $0xc,%esp
8010559d:	ff 75 f4             	push   -0xc(%ebp)
801055a0:	e8 76 c6 ff ff       	call   80101c1b <iunlockput>
801055a5:	83 c4 10             	add    $0x10,%esp
    end_op();
801055a8:	e8 1b db ff ff       	call   801030c8 <end_op>
    return -1;
801055ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055b2:	e9 04 01 00 00       	jmp    801056bb <sys_link+0x1a2>
  }

  ip->nlink++;
801055b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ba:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055be:	83 c0 01             	add    $0x1,%eax
801055c1:	89 c2                	mov    %eax,%edx
801055c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c6:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055ca:	83 ec 0c             	sub    $0xc,%esp
801055cd:	ff 75 f4             	push   -0xc(%ebp)
801055d0:	e8 38 c2 ff ff       	call   8010180d <iupdate>
801055d5:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801055d8:	83 ec 0c             	sub    $0xc,%esp
801055db:	ff 75 f4             	push   -0xc(%ebp)
801055de:	e8 1a c5 ff ff       	call   80101afd <iunlock>
801055e3:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801055e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055e9:	83 ec 08             	sub    $0x8,%esp
801055ec:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055ef:	52                   	push   %edx
801055f0:	50                   	push   %eax
801055f1:	e8 43 cf ff ff       	call   80102539 <nameiparent>
801055f6:	83 c4 10             	add    $0x10,%esp
801055f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105600:	74 71                	je     80105673 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105602:	83 ec 0c             	sub    $0xc,%esp
80105605:	ff 75 f0             	push   -0x10(%ebp)
80105608:	e8 dd c3 ff ff       	call   801019ea <ilock>
8010560d:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105613:	8b 10                	mov    (%eax),%edx
80105615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105618:	8b 00                	mov    (%eax),%eax
8010561a:	39 c2                	cmp    %eax,%edx
8010561c:	75 1d                	jne    8010563b <sys_link+0x122>
8010561e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105621:	8b 40 04             	mov    0x4(%eax),%eax
80105624:	83 ec 04             	sub    $0x4,%esp
80105627:	50                   	push   %eax
80105628:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010562b:	50                   	push   %eax
8010562c:	ff 75 f0             	push   -0x10(%ebp)
8010562f:	e8 52 cc ff ff       	call   80102286 <dirlink>
80105634:	83 c4 10             	add    $0x10,%esp
80105637:	85 c0                	test   %eax,%eax
80105639:	79 10                	jns    8010564b <sys_link+0x132>
    iunlockput(dp);
8010563b:	83 ec 0c             	sub    $0xc,%esp
8010563e:	ff 75 f0             	push   -0x10(%ebp)
80105641:	e8 d5 c5 ff ff       	call   80101c1b <iunlockput>
80105646:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105649:	eb 29                	jmp    80105674 <sys_link+0x15b>
  }
  iunlockput(dp);
8010564b:	83 ec 0c             	sub    $0xc,%esp
8010564e:	ff 75 f0             	push   -0x10(%ebp)
80105651:	e8 c5 c5 ff ff       	call   80101c1b <iunlockput>
80105656:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105659:	83 ec 0c             	sub    $0xc,%esp
8010565c:	ff 75 f4             	push   -0xc(%ebp)
8010565f:	e8 e7 c4 ff ff       	call   80101b4b <iput>
80105664:	83 c4 10             	add    $0x10,%esp

  end_op();
80105667:	e8 5c da ff ff       	call   801030c8 <end_op>

  return 0;
8010566c:	b8 00 00 00 00       	mov    $0x0,%eax
80105671:	eb 48                	jmp    801056bb <sys_link+0x1a2>
    goto bad;
80105673:	90                   	nop

bad:
  ilock(ip);
80105674:	83 ec 0c             	sub    $0xc,%esp
80105677:	ff 75 f4             	push   -0xc(%ebp)
8010567a:	e8 6b c3 ff ff       	call   801019ea <ilock>
8010567f:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105685:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105689:	83 e8 01             	sub    $0x1,%eax
8010568c:	89 c2                	mov    %eax,%edx
8010568e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105691:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105695:	83 ec 0c             	sub    $0xc,%esp
80105698:	ff 75 f4             	push   -0xc(%ebp)
8010569b:	e8 6d c1 ff ff       	call   8010180d <iupdate>
801056a0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801056a3:	83 ec 0c             	sub    $0xc,%esp
801056a6:	ff 75 f4             	push   -0xc(%ebp)
801056a9:	e8 6d c5 ff ff       	call   80101c1b <iunlockput>
801056ae:	83 c4 10             	add    $0x10,%esp
  end_op();
801056b1:	e8 12 da ff ff       	call   801030c8 <end_op>
  return -1;
801056b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056bb:	c9                   	leave  
801056bc:	c3                   	ret    

801056bd <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801056bd:	55                   	push   %ebp
801056be:	89 e5                	mov    %esp,%ebp
801056c0:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056c3:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801056ca:	eb 40                	jmp    8010570c <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056cf:	6a 10                	push   $0x10
801056d1:	50                   	push   %eax
801056d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801056d5:	50                   	push   %eax
801056d6:	ff 75 08             	push   0x8(%ebp)
801056d9:	e8 f8 c7 ff ff       	call   80101ed6 <readi>
801056de:	83 c4 10             	add    $0x10,%esp
801056e1:	83 f8 10             	cmp    $0x10,%eax
801056e4:	74 0d                	je     801056f3 <isdirempty+0x36>
      panic("isdirempty: readi");
801056e6:	83 ec 0c             	sub    $0xc,%esp
801056e9:	68 c0 a9 10 80       	push   $0x8010a9c0
801056ee:	e8 b6 ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801056f3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801056f7:	66 85 c0             	test   %ax,%ax
801056fa:	74 07                	je     80105703 <isdirempty+0x46>
      return 0;
801056fc:	b8 00 00 00 00       	mov    $0x0,%eax
80105701:	eb 1b                	jmp    8010571e <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105706:	83 c0 10             	add    $0x10,%eax
80105709:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010570c:	8b 45 08             	mov    0x8(%ebp),%eax
8010570f:	8b 50 58             	mov    0x58(%eax),%edx
80105712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105715:	39 c2                	cmp    %eax,%edx
80105717:	77 b3                	ja     801056cc <isdirempty+0xf>
  }
  return 1;
80105719:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010571e:	c9                   	leave  
8010571f:	c3                   	ret    

80105720 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105720:	55                   	push   %ebp
80105721:	89 e5                	mov    %esp,%ebp
80105723:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105726:	83 ec 08             	sub    $0x8,%esp
80105729:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010572c:	50                   	push   %eax
8010572d:	6a 00                	push   $0x0
8010572f:	e8 a2 fa ff ff       	call   801051d6 <argstr>
80105734:	83 c4 10             	add    $0x10,%esp
80105737:	85 c0                	test   %eax,%eax
80105739:	79 0a                	jns    80105745 <sys_unlink+0x25>
    return -1;
8010573b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105740:	e9 bf 01 00 00       	jmp    80105904 <sys_unlink+0x1e4>

  begin_op();
80105745:	e8 f2 d8 ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010574a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010574d:	83 ec 08             	sub    $0x8,%esp
80105750:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105753:	52                   	push   %edx
80105754:	50                   	push   %eax
80105755:	e8 df cd ff ff       	call   80102539 <nameiparent>
8010575a:	83 c4 10             	add    $0x10,%esp
8010575d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105760:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105764:	75 0f                	jne    80105775 <sys_unlink+0x55>
    end_op();
80105766:	e8 5d d9 ff ff       	call   801030c8 <end_op>
    return -1;
8010576b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105770:	e9 8f 01 00 00       	jmp    80105904 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105775:	83 ec 0c             	sub    $0xc,%esp
80105778:	ff 75 f4             	push   -0xc(%ebp)
8010577b:	e8 6a c2 ff ff       	call   801019ea <ilock>
80105780:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105783:	83 ec 08             	sub    $0x8,%esp
80105786:	68 d2 a9 10 80       	push   $0x8010a9d2
8010578b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010578e:	50                   	push   %eax
8010578f:	e8 1d ca ff ff       	call   801021b1 <namecmp>
80105794:	83 c4 10             	add    $0x10,%esp
80105797:	85 c0                	test   %eax,%eax
80105799:	0f 84 49 01 00 00    	je     801058e8 <sys_unlink+0x1c8>
8010579f:	83 ec 08             	sub    $0x8,%esp
801057a2:	68 d4 a9 10 80       	push   $0x8010a9d4
801057a7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057aa:	50                   	push   %eax
801057ab:	e8 01 ca ff ff       	call   801021b1 <namecmp>
801057b0:	83 c4 10             	add    $0x10,%esp
801057b3:	85 c0                	test   %eax,%eax
801057b5:	0f 84 2d 01 00 00    	je     801058e8 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801057bb:	83 ec 04             	sub    $0x4,%esp
801057be:	8d 45 c8             	lea    -0x38(%ebp),%eax
801057c1:	50                   	push   %eax
801057c2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057c5:	50                   	push   %eax
801057c6:	ff 75 f4             	push   -0xc(%ebp)
801057c9:	e8 fe c9 ff ff       	call   801021cc <dirlookup>
801057ce:	83 c4 10             	add    $0x10,%esp
801057d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057d8:	0f 84 0d 01 00 00    	je     801058eb <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
801057de:	83 ec 0c             	sub    $0xc,%esp
801057e1:	ff 75 f0             	push   -0x10(%ebp)
801057e4:	e8 01 c2 ff ff       	call   801019ea <ilock>
801057e9:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801057ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ef:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057f3:	66 85 c0             	test   %ax,%ax
801057f6:	7f 0d                	jg     80105805 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801057f8:	83 ec 0c             	sub    $0xc,%esp
801057fb:	68 d7 a9 10 80       	push   $0x8010a9d7
80105800:	e8 a4 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105808:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010580c:	66 83 f8 01          	cmp    $0x1,%ax
80105810:	75 25                	jne    80105837 <sys_unlink+0x117>
80105812:	83 ec 0c             	sub    $0xc,%esp
80105815:	ff 75 f0             	push   -0x10(%ebp)
80105818:	e8 a0 fe ff ff       	call   801056bd <isdirempty>
8010581d:	83 c4 10             	add    $0x10,%esp
80105820:	85 c0                	test   %eax,%eax
80105822:	75 13                	jne    80105837 <sys_unlink+0x117>
    iunlockput(ip);
80105824:	83 ec 0c             	sub    $0xc,%esp
80105827:	ff 75 f0             	push   -0x10(%ebp)
8010582a:	e8 ec c3 ff ff       	call   80101c1b <iunlockput>
8010582f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105832:	e9 b5 00 00 00       	jmp    801058ec <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105837:	83 ec 04             	sub    $0x4,%esp
8010583a:	6a 10                	push   $0x10
8010583c:	6a 00                	push   $0x0
8010583e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105841:	50                   	push   %eax
80105842:	e8 cf f5 ff ff       	call   80104e16 <memset>
80105847:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010584a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010584d:	6a 10                	push   $0x10
8010584f:	50                   	push   %eax
80105850:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105853:	50                   	push   %eax
80105854:	ff 75 f4             	push   -0xc(%ebp)
80105857:	e8 cf c7 ff ff       	call   8010202b <writei>
8010585c:	83 c4 10             	add    $0x10,%esp
8010585f:	83 f8 10             	cmp    $0x10,%eax
80105862:	74 0d                	je     80105871 <sys_unlink+0x151>
    panic("unlink: writei");
80105864:	83 ec 0c             	sub    $0xc,%esp
80105867:	68 e9 a9 10 80       	push   $0x8010a9e9
8010586c:	e8 38 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105874:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105878:	66 83 f8 01          	cmp    $0x1,%ax
8010587c:	75 21                	jne    8010589f <sys_unlink+0x17f>
    dp->nlink--;
8010587e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105881:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105885:	83 e8 01             	sub    $0x1,%eax
80105888:	89 c2                	mov    %eax,%edx
8010588a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105891:	83 ec 0c             	sub    $0xc,%esp
80105894:	ff 75 f4             	push   -0xc(%ebp)
80105897:	e8 71 bf ff ff       	call   8010180d <iupdate>
8010589c:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010589f:	83 ec 0c             	sub    $0xc,%esp
801058a2:	ff 75 f4             	push   -0xc(%ebp)
801058a5:	e8 71 c3 ff ff       	call   80101c1b <iunlockput>
801058aa:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801058ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058b4:	83 e8 01             	sub    $0x1,%eax
801058b7:	89 c2                	mov    %eax,%edx
801058b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bc:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801058c0:	83 ec 0c             	sub    $0xc,%esp
801058c3:	ff 75 f0             	push   -0x10(%ebp)
801058c6:	e8 42 bf ff ff       	call   8010180d <iupdate>
801058cb:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801058ce:	83 ec 0c             	sub    $0xc,%esp
801058d1:	ff 75 f0             	push   -0x10(%ebp)
801058d4:	e8 42 c3 ff ff       	call   80101c1b <iunlockput>
801058d9:	83 c4 10             	add    $0x10,%esp

  end_op();
801058dc:	e8 e7 d7 ff ff       	call   801030c8 <end_op>

  return 0;
801058e1:	b8 00 00 00 00       	mov    $0x0,%eax
801058e6:	eb 1c                	jmp    80105904 <sys_unlink+0x1e4>
    goto bad;
801058e8:	90                   	nop
801058e9:	eb 01                	jmp    801058ec <sys_unlink+0x1cc>
    goto bad;
801058eb:	90                   	nop

bad:
  iunlockput(dp);
801058ec:	83 ec 0c             	sub    $0xc,%esp
801058ef:	ff 75 f4             	push   -0xc(%ebp)
801058f2:	e8 24 c3 ff ff       	call   80101c1b <iunlockput>
801058f7:	83 c4 10             	add    $0x10,%esp
  end_op();
801058fa:	e8 c9 d7 ff ff       	call   801030c8 <end_op>
  return -1;
801058ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105904:	c9                   	leave  
80105905:	c3                   	ret    

80105906 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105906:	55                   	push   %ebp
80105907:	89 e5                	mov    %esp,%ebp
80105909:	83 ec 38             	sub    $0x38,%esp
8010590c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010590f:	8b 55 10             	mov    0x10(%ebp),%edx
80105912:	8b 45 14             	mov    0x14(%ebp),%eax
80105915:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105919:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010591d:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105921:	83 ec 08             	sub    $0x8,%esp
80105924:	8d 45 de             	lea    -0x22(%ebp),%eax
80105927:	50                   	push   %eax
80105928:	ff 75 08             	push   0x8(%ebp)
8010592b:	e8 09 cc ff ff       	call   80102539 <nameiparent>
80105930:	83 c4 10             	add    $0x10,%esp
80105933:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105936:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010593a:	75 0a                	jne    80105946 <create+0x40>
    return 0;
8010593c:	b8 00 00 00 00       	mov    $0x0,%eax
80105941:	e9 90 01 00 00       	jmp    80105ad6 <create+0x1d0>
  ilock(dp);
80105946:	83 ec 0c             	sub    $0xc,%esp
80105949:	ff 75 f4             	push   -0xc(%ebp)
8010594c:	e8 99 c0 ff ff       	call   801019ea <ilock>
80105951:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105954:	83 ec 04             	sub    $0x4,%esp
80105957:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010595a:	50                   	push   %eax
8010595b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010595e:	50                   	push   %eax
8010595f:	ff 75 f4             	push   -0xc(%ebp)
80105962:	e8 65 c8 ff ff       	call   801021cc <dirlookup>
80105967:	83 c4 10             	add    $0x10,%esp
8010596a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010596d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105971:	74 50                	je     801059c3 <create+0xbd>
    iunlockput(dp);
80105973:	83 ec 0c             	sub    $0xc,%esp
80105976:	ff 75 f4             	push   -0xc(%ebp)
80105979:	e8 9d c2 ff ff       	call   80101c1b <iunlockput>
8010597e:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105981:	83 ec 0c             	sub    $0xc,%esp
80105984:	ff 75 f0             	push   -0x10(%ebp)
80105987:	e8 5e c0 ff ff       	call   801019ea <ilock>
8010598c:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010598f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105994:	75 15                	jne    801059ab <create+0xa5>
80105996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105999:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010599d:	66 83 f8 02          	cmp    $0x2,%ax
801059a1:	75 08                	jne    801059ab <create+0xa5>
      return ip;
801059a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a6:	e9 2b 01 00 00       	jmp    80105ad6 <create+0x1d0>
    iunlockput(ip);
801059ab:	83 ec 0c             	sub    $0xc,%esp
801059ae:	ff 75 f0             	push   -0x10(%ebp)
801059b1:	e8 65 c2 ff ff       	call   80101c1b <iunlockput>
801059b6:	83 c4 10             	add    $0x10,%esp
    return 0;
801059b9:	b8 00 00 00 00       	mov    $0x0,%eax
801059be:	e9 13 01 00 00       	jmp    80105ad6 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801059c3:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801059c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ca:	8b 00                	mov    (%eax),%eax
801059cc:	83 ec 08             	sub    $0x8,%esp
801059cf:	52                   	push   %edx
801059d0:	50                   	push   %eax
801059d1:	e8 60 bd ff ff       	call   80101736 <ialloc>
801059d6:	83 c4 10             	add    $0x10,%esp
801059d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059e0:	75 0d                	jne    801059ef <create+0xe9>
    panic("create: ialloc");
801059e2:	83 ec 0c             	sub    $0xc,%esp
801059e5:	68 f8 a9 10 80       	push   $0x8010a9f8
801059ea:	e8 ba ab ff ff       	call   801005a9 <panic>

  ilock(ip);
801059ef:	83 ec 0c             	sub    $0xc,%esp
801059f2:	ff 75 f0             	push   -0x10(%ebp)
801059f5:	e8 f0 bf ff ff       	call   801019ea <ilock>
801059fa:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801059fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a00:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a04:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0b:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a0f:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a16:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a1c:	83 ec 0c             	sub    $0xc,%esp
80105a1f:	ff 75 f0             	push   -0x10(%ebp)
80105a22:	e8 e6 bd ff ff       	call   8010180d <iupdate>
80105a27:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a2a:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a2f:	75 6a                	jne    80105a9b <create+0x195>
    dp->nlink++;  // for ".."
80105a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a34:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a38:	83 c0 01             	add    $0x1,%eax
80105a3b:	89 c2                	mov    %eax,%edx
80105a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a40:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a44:	83 ec 0c             	sub    $0xc,%esp
80105a47:	ff 75 f4             	push   -0xc(%ebp)
80105a4a:	e8 be bd ff ff       	call   8010180d <iupdate>
80105a4f:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a55:	8b 40 04             	mov    0x4(%eax),%eax
80105a58:	83 ec 04             	sub    $0x4,%esp
80105a5b:	50                   	push   %eax
80105a5c:	68 d2 a9 10 80       	push   $0x8010a9d2
80105a61:	ff 75 f0             	push   -0x10(%ebp)
80105a64:	e8 1d c8 ff ff       	call   80102286 <dirlink>
80105a69:	83 c4 10             	add    $0x10,%esp
80105a6c:	85 c0                	test   %eax,%eax
80105a6e:	78 1e                	js     80105a8e <create+0x188>
80105a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a73:	8b 40 04             	mov    0x4(%eax),%eax
80105a76:	83 ec 04             	sub    $0x4,%esp
80105a79:	50                   	push   %eax
80105a7a:	68 d4 a9 10 80       	push   $0x8010a9d4
80105a7f:	ff 75 f0             	push   -0x10(%ebp)
80105a82:	e8 ff c7 ff ff       	call   80102286 <dirlink>
80105a87:	83 c4 10             	add    $0x10,%esp
80105a8a:	85 c0                	test   %eax,%eax
80105a8c:	79 0d                	jns    80105a9b <create+0x195>
      panic("create dots");
80105a8e:	83 ec 0c             	sub    $0xc,%esp
80105a91:	68 07 aa 10 80       	push   $0x8010aa07
80105a96:	e8 0e ab ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9e:	8b 40 04             	mov    0x4(%eax),%eax
80105aa1:	83 ec 04             	sub    $0x4,%esp
80105aa4:	50                   	push   %eax
80105aa5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105aa8:	50                   	push   %eax
80105aa9:	ff 75 f4             	push   -0xc(%ebp)
80105aac:	e8 d5 c7 ff ff       	call   80102286 <dirlink>
80105ab1:	83 c4 10             	add    $0x10,%esp
80105ab4:	85 c0                	test   %eax,%eax
80105ab6:	79 0d                	jns    80105ac5 <create+0x1bf>
    panic("create: dirlink");
80105ab8:	83 ec 0c             	sub    $0xc,%esp
80105abb:	68 13 aa 10 80       	push   $0x8010aa13
80105ac0:	e8 e4 aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105ac5:	83 ec 0c             	sub    $0xc,%esp
80105ac8:	ff 75 f4             	push   -0xc(%ebp)
80105acb:	e8 4b c1 ff ff       	call   80101c1b <iunlockput>
80105ad0:	83 c4 10             	add    $0x10,%esp

  return ip;
80105ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ad6:	c9                   	leave  
80105ad7:	c3                   	ret    

80105ad8 <sys_open>:

int
sys_open(void)
{
80105ad8:	55                   	push   %ebp
80105ad9:	89 e5                	mov    %esp,%ebp
80105adb:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ade:	83 ec 08             	sub    $0x8,%esp
80105ae1:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ae4:	50                   	push   %eax
80105ae5:	6a 00                	push   $0x0
80105ae7:	e8 ea f6 ff ff       	call   801051d6 <argstr>
80105aec:	83 c4 10             	add    $0x10,%esp
80105aef:	85 c0                	test   %eax,%eax
80105af1:	78 15                	js     80105b08 <sys_open+0x30>
80105af3:	83 ec 08             	sub    $0x8,%esp
80105af6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105af9:	50                   	push   %eax
80105afa:	6a 01                	push   $0x1
80105afc:	e8 40 f6 ff ff       	call   80105141 <argint>
80105b01:	83 c4 10             	add    $0x10,%esp
80105b04:	85 c0                	test   %eax,%eax
80105b06:	79 0a                	jns    80105b12 <sys_open+0x3a>
    return -1;
80105b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0d:	e9 61 01 00 00       	jmp    80105c73 <sys_open+0x19b>

  begin_op();
80105b12:	e8 25 d5 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
80105b17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b1a:	25 00 02 00 00       	and    $0x200,%eax
80105b1f:	85 c0                	test   %eax,%eax
80105b21:	74 2a                	je     80105b4d <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b26:	6a 00                	push   $0x0
80105b28:	6a 00                	push   $0x0
80105b2a:	6a 02                	push   $0x2
80105b2c:	50                   	push   %eax
80105b2d:	e8 d4 fd ff ff       	call   80105906 <create>
80105b32:	83 c4 10             	add    $0x10,%esp
80105b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b3c:	75 75                	jne    80105bb3 <sys_open+0xdb>
      end_op();
80105b3e:	e8 85 d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105b43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b48:	e9 26 01 00 00       	jmp    80105c73 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b50:	83 ec 0c             	sub    $0xc,%esp
80105b53:	50                   	push   %eax
80105b54:	e8 c4 c9 ff ff       	call   8010251d <namei>
80105b59:	83 c4 10             	add    $0x10,%esp
80105b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b63:	75 0f                	jne    80105b74 <sys_open+0x9c>
      end_op();
80105b65:	e8 5e d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6f:	e9 ff 00 00 00       	jmp    80105c73 <sys_open+0x19b>
    }
    ilock(ip);
80105b74:	83 ec 0c             	sub    $0xc,%esp
80105b77:	ff 75 f4             	push   -0xc(%ebp)
80105b7a:	e8 6b be ff ff       	call   801019ea <ilock>
80105b7f:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b85:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b89:	66 83 f8 01          	cmp    $0x1,%ax
80105b8d:	75 24                	jne    80105bb3 <sys_open+0xdb>
80105b8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b92:	85 c0                	test   %eax,%eax
80105b94:	74 1d                	je     80105bb3 <sys_open+0xdb>
      iunlockput(ip);
80105b96:	83 ec 0c             	sub    $0xc,%esp
80105b99:	ff 75 f4             	push   -0xc(%ebp)
80105b9c:	e8 7a c0 ff ff       	call   80101c1b <iunlockput>
80105ba1:	83 c4 10             	add    $0x10,%esp
      end_op();
80105ba4:	e8 1f d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105ba9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bae:	e9 c0 00 00 00       	jmp    80105c73 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105bb3:	e8 25 b4 ff ff       	call   80100fdd <filealloc>
80105bb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bbb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bbf:	74 17                	je     80105bd8 <sys_open+0x100>
80105bc1:	83 ec 0c             	sub    $0xc,%esp
80105bc4:	ff 75 f0             	push   -0x10(%ebp)
80105bc7:	e8 33 f7 ff ff       	call   801052ff <fdalloc>
80105bcc:	83 c4 10             	add    $0x10,%esp
80105bcf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105bd2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105bd6:	79 2e                	jns    80105c06 <sys_open+0x12e>
    if(f)
80105bd8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bdc:	74 0e                	je     80105bec <sys_open+0x114>
      fileclose(f);
80105bde:	83 ec 0c             	sub    $0xc,%esp
80105be1:	ff 75 f0             	push   -0x10(%ebp)
80105be4:	e8 b2 b4 ff ff       	call   8010109b <fileclose>
80105be9:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105bec:	83 ec 0c             	sub    $0xc,%esp
80105bef:	ff 75 f4             	push   -0xc(%ebp)
80105bf2:	e8 24 c0 ff ff       	call   80101c1b <iunlockput>
80105bf7:	83 c4 10             	add    $0x10,%esp
    end_op();
80105bfa:	e8 c9 d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105bff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c04:	eb 6d                	jmp    80105c73 <sys_open+0x19b>
  }
  iunlock(ip);
80105c06:	83 ec 0c             	sub    $0xc,%esp
80105c09:	ff 75 f4             	push   -0xc(%ebp)
80105c0c:	e8 ec be ff ff       	call   80101afd <iunlock>
80105c11:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c14:	e8 af d4 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c28:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c38:	83 e0 01             	and    $0x1,%eax
80105c3b:	85 c0                	test   %eax,%eax
80105c3d:	0f 94 c0             	sete   %al
80105c40:	89 c2                	mov    %eax,%edx
80105c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c45:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c4b:	83 e0 01             	and    $0x1,%eax
80105c4e:	85 c0                	test   %eax,%eax
80105c50:	75 0a                	jne    80105c5c <sys_open+0x184>
80105c52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c55:	83 e0 02             	and    $0x2,%eax
80105c58:	85 c0                	test   %eax,%eax
80105c5a:	74 07                	je     80105c63 <sys_open+0x18b>
80105c5c:	b8 01 00 00 00       	mov    $0x1,%eax
80105c61:	eb 05                	jmp    80105c68 <sys_open+0x190>
80105c63:	b8 00 00 00 00       	mov    $0x0,%eax
80105c68:	89 c2                	mov    %eax,%edx
80105c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6d:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c70:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c73:	c9                   	leave  
80105c74:	c3                   	ret    

80105c75 <sys_mkdir>:

int
sys_mkdir(void)
{
80105c75:	55                   	push   %ebp
80105c76:	89 e5                	mov    %esp,%ebp
80105c78:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105c7b:	e8 bc d3 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c80:	83 ec 08             	sub    $0x8,%esp
80105c83:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c86:	50                   	push   %eax
80105c87:	6a 00                	push   $0x0
80105c89:	e8 48 f5 ff ff       	call   801051d6 <argstr>
80105c8e:	83 c4 10             	add    $0x10,%esp
80105c91:	85 c0                	test   %eax,%eax
80105c93:	78 1b                	js     80105cb0 <sys_mkdir+0x3b>
80105c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c98:	6a 00                	push   $0x0
80105c9a:	6a 00                	push   $0x0
80105c9c:	6a 01                	push   $0x1
80105c9e:	50                   	push   %eax
80105c9f:	e8 62 fc ff ff       	call   80105906 <create>
80105ca4:	83 c4 10             	add    $0x10,%esp
80105ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105caa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cae:	75 0c                	jne    80105cbc <sys_mkdir+0x47>
    end_op();
80105cb0:	e8 13 d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105cb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cba:	eb 18                	jmp    80105cd4 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105cbc:	83 ec 0c             	sub    $0xc,%esp
80105cbf:	ff 75 f4             	push   -0xc(%ebp)
80105cc2:	e8 54 bf ff ff       	call   80101c1b <iunlockput>
80105cc7:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cca:	e8 f9 d3 ff ff       	call   801030c8 <end_op>
  return 0;
80105ccf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cd4:	c9                   	leave  
80105cd5:	c3                   	ret    

80105cd6 <sys_mknod>:

int
sys_mknod(void)
{
80105cd6:	55                   	push   %ebp
80105cd7:	89 e5                	mov    %esp,%ebp
80105cd9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105cdc:	e8 5b d3 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105ce1:	83 ec 08             	sub    $0x8,%esp
80105ce4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ce7:	50                   	push   %eax
80105ce8:	6a 00                	push   $0x0
80105cea:	e8 e7 f4 ff ff       	call   801051d6 <argstr>
80105cef:	83 c4 10             	add    $0x10,%esp
80105cf2:	85 c0                	test   %eax,%eax
80105cf4:	78 4f                	js     80105d45 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105cf6:	83 ec 08             	sub    $0x8,%esp
80105cf9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cfc:	50                   	push   %eax
80105cfd:	6a 01                	push   $0x1
80105cff:	e8 3d f4 ff ff       	call   80105141 <argint>
80105d04:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d07:	85 c0                	test   %eax,%eax
80105d09:	78 3a                	js     80105d45 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105d0b:	83 ec 08             	sub    $0x8,%esp
80105d0e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d11:	50                   	push   %eax
80105d12:	6a 02                	push   $0x2
80105d14:	e8 28 f4 ff ff       	call   80105141 <argint>
80105d19:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d1c:	85 c0                	test   %eax,%eax
80105d1e:	78 25                	js     80105d45 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d23:	0f bf c8             	movswl %ax,%ecx
80105d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d29:	0f bf d0             	movswl %ax,%edx
80105d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2f:	51                   	push   %ecx
80105d30:	52                   	push   %edx
80105d31:	6a 03                	push   $0x3
80105d33:	50                   	push   %eax
80105d34:	e8 cd fb ff ff       	call   80105906 <create>
80105d39:	83 c4 10             	add    $0x10,%esp
80105d3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105d3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d43:	75 0c                	jne    80105d51 <sys_mknod+0x7b>
    end_op();
80105d45:	e8 7e d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4f:	eb 18                	jmp    80105d69 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105d51:	83 ec 0c             	sub    $0xc,%esp
80105d54:	ff 75 f4             	push   -0xc(%ebp)
80105d57:	e8 bf be ff ff       	call   80101c1b <iunlockput>
80105d5c:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d5f:	e8 64 d3 ff ff       	call   801030c8 <end_op>
  return 0;
80105d64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d69:	c9                   	leave  
80105d6a:	c3                   	ret    

80105d6b <sys_chdir>:

int
sys_chdir(void)
{
80105d6b:	55                   	push   %ebp
80105d6c:	89 e5                	mov    %esp,%ebp
80105d6e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105d71:	e8 ba dc ff ff       	call   80103a30 <myproc>
80105d76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105d79:	e8 be d2 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d7e:	83 ec 08             	sub    $0x8,%esp
80105d81:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d84:	50                   	push   %eax
80105d85:	6a 00                	push   $0x0
80105d87:	e8 4a f4 ff ff       	call   801051d6 <argstr>
80105d8c:	83 c4 10             	add    $0x10,%esp
80105d8f:	85 c0                	test   %eax,%eax
80105d91:	78 18                	js     80105dab <sys_chdir+0x40>
80105d93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d96:	83 ec 0c             	sub    $0xc,%esp
80105d99:	50                   	push   %eax
80105d9a:	e8 7e c7 ff ff       	call   8010251d <namei>
80105d9f:	83 c4 10             	add    $0x10,%esp
80105da2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105da5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105da9:	75 0c                	jne    80105db7 <sys_chdir+0x4c>
    end_op();
80105dab:	e8 18 d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105db0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db5:	eb 68                	jmp    80105e1f <sys_chdir+0xb4>
  }
  ilock(ip);
80105db7:	83 ec 0c             	sub    $0xc,%esp
80105dba:	ff 75 f0             	push   -0x10(%ebp)
80105dbd:	e8 28 bc ff ff       	call   801019ea <ilock>
80105dc2:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105dcc:	66 83 f8 01          	cmp    $0x1,%ax
80105dd0:	74 1a                	je     80105dec <sys_chdir+0x81>
    iunlockput(ip);
80105dd2:	83 ec 0c             	sub    $0xc,%esp
80105dd5:	ff 75 f0             	push   -0x10(%ebp)
80105dd8:	e8 3e be ff ff       	call   80101c1b <iunlockput>
80105ddd:	83 c4 10             	add    $0x10,%esp
    end_op();
80105de0:	e8 e3 d2 ff ff       	call   801030c8 <end_op>
    return -1;
80105de5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dea:	eb 33                	jmp    80105e1f <sys_chdir+0xb4>
  }
  iunlock(ip);
80105dec:	83 ec 0c             	sub    $0xc,%esp
80105def:	ff 75 f0             	push   -0x10(%ebp)
80105df2:	e8 06 bd ff ff       	call   80101afd <iunlock>
80105df7:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfd:	8b 40 68             	mov    0x68(%eax),%eax
80105e00:	83 ec 0c             	sub    $0xc,%esp
80105e03:	50                   	push   %eax
80105e04:	e8 42 bd ff ff       	call   80101b4b <iput>
80105e09:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e0c:	e8 b7 d2 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e14:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e17:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e1f:	c9                   	leave  
80105e20:	c3                   	ret    

80105e21 <sys_exec>:

int
sys_exec(void)
{
80105e21:	55                   	push   %ebp
80105e22:	89 e5                	mov    %esp,%ebp
80105e24:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e2a:	83 ec 08             	sub    $0x8,%esp
80105e2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e30:	50                   	push   %eax
80105e31:	6a 00                	push   $0x0
80105e33:	e8 9e f3 ff ff       	call   801051d6 <argstr>
80105e38:	83 c4 10             	add    $0x10,%esp
80105e3b:	85 c0                	test   %eax,%eax
80105e3d:	78 18                	js     80105e57 <sys_exec+0x36>
80105e3f:	83 ec 08             	sub    $0x8,%esp
80105e42:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e48:	50                   	push   %eax
80105e49:	6a 01                	push   $0x1
80105e4b:	e8 f1 f2 ff ff       	call   80105141 <argint>
80105e50:	83 c4 10             	add    $0x10,%esp
80105e53:	85 c0                	test   %eax,%eax
80105e55:	79 0a                	jns    80105e61 <sys_exec+0x40>
    return -1;
80105e57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e5c:	e9 c6 00 00 00       	jmp    80105f27 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105e61:	83 ec 04             	sub    $0x4,%esp
80105e64:	68 80 00 00 00       	push   $0x80
80105e69:	6a 00                	push   $0x0
80105e6b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e71:	50                   	push   %eax
80105e72:	e8 9f ef ff ff       	call   80104e16 <memset>
80105e77:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e84:	83 f8 1f             	cmp    $0x1f,%eax
80105e87:	76 0a                	jbe    80105e93 <sys_exec+0x72>
      return -1;
80105e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e8e:	e9 94 00 00 00       	jmp    80105f27 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e96:	c1 e0 02             	shl    $0x2,%eax
80105e99:	89 c2                	mov    %eax,%edx
80105e9b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105ea1:	01 c2                	add    %eax,%edx
80105ea3:	83 ec 08             	sub    $0x8,%esp
80105ea6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105eac:	50                   	push   %eax
80105ead:	52                   	push   %edx
80105eae:	e8 ed f1 ff ff       	call   801050a0 <fetchint>
80105eb3:	83 c4 10             	add    $0x10,%esp
80105eb6:	85 c0                	test   %eax,%eax
80105eb8:	79 07                	jns    80105ec1 <sys_exec+0xa0>
      return -1;
80105eba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebf:	eb 66                	jmp    80105f27 <sys_exec+0x106>
    if(uarg == 0){
80105ec1:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ec7:	85 c0                	test   %eax,%eax
80105ec9:	75 27                	jne    80105ef2 <sys_exec+0xd1>
      argv[i] = 0;
80105ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ece:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105ed5:	00 00 00 00 
      break;
80105ed9:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105edd:	83 ec 08             	sub    $0x8,%esp
80105ee0:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ee6:	52                   	push   %edx
80105ee7:	50                   	push   %eax
80105ee8:	e8 93 ac ff ff       	call   80100b80 <exec>
80105eed:	83 c4 10             	add    $0x10,%esp
80105ef0:	eb 35                	jmp    80105f27 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105ef2:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efb:	c1 e0 02             	shl    $0x2,%eax
80105efe:	01 c2                	add    %eax,%edx
80105f00:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f06:	83 ec 08             	sub    $0x8,%esp
80105f09:	52                   	push   %edx
80105f0a:	50                   	push   %eax
80105f0b:	e8 cf f1 ff ff       	call   801050df <fetchstr>
80105f10:	83 c4 10             	add    $0x10,%esp
80105f13:	85 c0                	test   %eax,%eax
80105f15:	79 07                	jns    80105f1e <sys_exec+0xfd>
      return -1;
80105f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1c:	eb 09                	jmp    80105f27 <sys_exec+0x106>
  for(i=0;; i++){
80105f1e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f22:	e9 5a ff ff ff       	jmp    80105e81 <sys_exec+0x60>
}
80105f27:	c9                   	leave  
80105f28:	c3                   	ret    

80105f29 <sys_pipe>:

int
sys_pipe(void)
{
80105f29:	55                   	push   %ebp
80105f2a:	89 e5                	mov    %esp,%ebp
80105f2c:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f2f:	83 ec 04             	sub    $0x4,%esp
80105f32:	6a 08                	push   $0x8
80105f34:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f37:	50                   	push   %eax
80105f38:	6a 00                	push   $0x0
80105f3a:	e8 2f f2 ff ff       	call   8010516e <argptr>
80105f3f:	83 c4 10             	add    $0x10,%esp
80105f42:	85 c0                	test   %eax,%eax
80105f44:	79 0a                	jns    80105f50 <sys_pipe+0x27>
    return -1;
80105f46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f4b:	e9 ae 00 00 00       	jmp    80105ffe <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105f50:	83 ec 08             	sub    $0x8,%esp
80105f53:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f56:	50                   	push   %eax
80105f57:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f5a:	50                   	push   %eax
80105f5b:	e8 0d d6 ff ff       	call   8010356d <pipealloc>
80105f60:	83 c4 10             	add    $0x10,%esp
80105f63:	85 c0                	test   %eax,%eax
80105f65:	79 0a                	jns    80105f71 <sys_pipe+0x48>
    return -1;
80105f67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f6c:	e9 8d 00 00 00       	jmp    80105ffe <sys_pipe+0xd5>
  fd0 = -1;
80105f71:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f7b:	83 ec 0c             	sub    $0xc,%esp
80105f7e:	50                   	push   %eax
80105f7f:	e8 7b f3 ff ff       	call   801052ff <fdalloc>
80105f84:	83 c4 10             	add    $0x10,%esp
80105f87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f8e:	78 18                	js     80105fa8 <sys_pipe+0x7f>
80105f90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f93:	83 ec 0c             	sub    $0xc,%esp
80105f96:	50                   	push   %eax
80105f97:	e8 63 f3 ff ff       	call   801052ff <fdalloc>
80105f9c:	83 c4 10             	add    $0x10,%esp
80105f9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fa2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fa6:	79 3e                	jns    80105fe6 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105fa8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fac:	78 13                	js     80105fc1 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105fae:	e8 7d da ff ff       	call   80103a30 <myproc>
80105fb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fb6:	83 c2 08             	add    $0x8,%edx
80105fb9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105fc0:	00 
    fileclose(rf);
80105fc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fc4:	83 ec 0c             	sub    $0xc,%esp
80105fc7:	50                   	push   %eax
80105fc8:	e8 ce b0 ff ff       	call   8010109b <fileclose>
80105fcd:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105fd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fd3:	83 ec 0c             	sub    $0xc,%esp
80105fd6:	50                   	push   %eax
80105fd7:	e8 bf b0 ff ff       	call   8010109b <fileclose>
80105fdc:	83 c4 10             	add    $0x10,%esp
    return -1;
80105fdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe4:	eb 18                	jmp    80105ffe <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105fe6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fe9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fec:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ff1:	8d 50 04             	lea    0x4(%eax),%edx
80105ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff7:	89 02                	mov    %eax,(%edx)
  return 0;
80105ff9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ffe:	c9                   	leave  
80105fff:	c3                   	ret    

80106000 <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
80106000:	55                   	push   %ebp
80106001:	89 e5                	mov    %esp,%ebp
80106003:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106006:	e8 5f dd ff ff       	call   80103d6a <fork>
}
8010600b:	c9                   	leave  
8010600c:	c3                   	ret    

8010600d <sys_exit>:

int
sys_exit(void)
{
8010600d:	55                   	push   %ebp
8010600e:	89 e5                	mov    %esp,%ebp
80106010:	83 ec 08             	sub    $0x8,%esp
  exit();
80106013:	e8 cb de ff ff       	call   80103ee3 <exit>
  return 0;  // not reached
80106018:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010601d:	c9                   	leave  
8010601e:	c3                   	ret    

8010601f <sys_wait>:

int
sys_wait(void)
{
8010601f:	55                   	push   %ebp
80106020:	89 e5                	mov    %esp,%ebp
80106022:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106025:	e8 dc df ff ff       	call   80104006 <wait>
}
8010602a:	c9                   	leave  
8010602b:	c3                   	ret    

8010602c <sys_kill>:

int
sys_kill(void)
{
8010602c:	55                   	push   %ebp
8010602d:	89 e5                	mov    %esp,%ebp
8010602f:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106032:	83 ec 08             	sub    $0x8,%esp
80106035:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106038:	50                   	push   %eax
80106039:	6a 00                	push   $0x0
8010603b:	e8 01 f1 ff ff       	call   80105141 <argint>
80106040:	83 c4 10             	add    $0x10,%esp
80106043:	85 c0                	test   %eax,%eax
80106045:	79 07                	jns    8010604e <sys_kill+0x22>
    return -1;
80106047:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010604c:	eb 0f                	jmp    8010605d <sys_kill+0x31>
  return kill(pid);
8010604e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106051:	83 ec 0c             	sub    $0xc,%esp
80106054:	50                   	push   %eax
80106055:	e8 f6 e6 ff ff       	call   80104750 <kill>
8010605a:	83 c4 10             	add    $0x10,%esp
}
8010605d:	c9                   	leave  
8010605e:	c3                   	ret    

8010605f <sys_getpid>:

int
sys_getpid(void)
{
8010605f:	55                   	push   %ebp
80106060:	89 e5                	mov    %esp,%ebp
80106062:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106065:	e8 c6 d9 ff ff       	call   80103a30 <myproc>
8010606a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010606d:	c9                   	leave  
8010606e:	c3                   	ret    

8010606f <sys_sbrk>:

int
sys_sbrk(void)
{
8010606f:	55                   	push   %ebp
80106070:	89 e5                	mov    %esp,%ebp
80106072:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106075:	83 ec 08             	sub    $0x8,%esp
80106078:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010607b:	50                   	push   %eax
8010607c:	6a 00                	push   $0x0
8010607e:	e8 be f0 ff ff       	call   80105141 <argint>
80106083:	83 c4 10             	add    $0x10,%esp
80106086:	85 c0                	test   %eax,%eax
80106088:	79 07                	jns    80106091 <sys_sbrk+0x22>
    return -1;
8010608a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010608f:	eb 27                	jmp    801060b8 <sys_sbrk+0x49>
  addr = myproc()->sz;
80106091:	e8 9a d9 ff ff       	call   80103a30 <myproc>
80106096:	8b 00                	mov    (%eax),%eax
80106098:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010609b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609e:	83 ec 0c             	sub    $0xc,%esp
801060a1:	50                   	push   %eax
801060a2:	e8 28 dc ff ff       	call   80103ccf <growproc>
801060a7:	83 c4 10             	add    $0x10,%esp
801060aa:	85 c0                	test   %eax,%eax
801060ac:	79 07                	jns    801060b5 <sys_sbrk+0x46>
    return -1;
801060ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b3:	eb 03                	jmp    801060b8 <sys_sbrk+0x49>
  return addr;
801060b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060b8:	c9                   	leave  
801060b9:	c3                   	ret    

801060ba <sys_sleep>:

int
sys_sleep(void)
{
801060ba:	55                   	push   %ebp
801060bb:	89 e5                	mov    %esp,%ebp
801060bd:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801060c0:	83 ec 08             	sub    $0x8,%esp
801060c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060c6:	50                   	push   %eax
801060c7:	6a 00                	push   $0x0
801060c9:	e8 73 f0 ff ff       	call   80105141 <argint>
801060ce:	83 c4 10             	add    $0x10,%esp
801060d1:	85 c0                	test   %eax,%eax
801060d3:	79 07                	jns    801060dc <sys_sleep+0x22>
    return -1;
801060d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060da:	eb 76                	jmp    80106152 <sys_sleep+0x98>
  acquire(&tickslock);
801060dc:	83 ec 0c             	sub    $0xc,%esp
801060df:	68 40 72 19 80       	push   $0x80197240
801060e4:	e8 b7 ea ff ff       	call   80104ba0 <acquire>
801060e9:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801060ec:	a1 74 72 19 80       	mov    0x80197274,%eax
801060f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801060f4:	eb 38                	jmp    8010612e <sys_sleep+0x74>
    if(myproc()->killed){
801060f6:	e8 35 d9 ff ff       	call   80103a30 <myproc>
801060fb:	8b 40 24             	mov    0x24(%eax),%eax
801060fe:	85 c0                	test   %eax,%eax
80106100:	74 17                	je     80106119 <sys_sleep+0x5f>
      release(&tickslock);
80106102:	83 ec 0c             	sub    $0xc,%esp
80106105:	68 40 72 19 80       	push   $0x80197240
8010610a:	e8 ff ea ff ff       	call   80104c0e <release>
8010610f:	83 c4 10             	add    $0x10,%esp
      return -1;
80106112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106117:	eb 39                	jmp    80106152 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106119:	83 ec 08             	sub    $0x8,%esp
8010611c:	68 40 72 19 80       	push   $0x80197240
80106121:	68 74 72 19 80       	push   $0x80197274
80106126:	e8 04 e5 ff ff       	call   8010462f <sleep>
8010612b:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010612e:	a1 74 72 19 80       	mov    0x80197274,%eax
80106133:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106136:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106139:	39 d0                	cmp    %edx,%eax
8010613b:	72 b9                	jb     801060f6 <sys_sleep+0x3c>
  }
  release(&tickslock);
8010613d:	83 ec 0c             	sub    $0xc,%esp
80106140:	68 40 72 19 80       	push   $0x80197240
80106145:	e8 c4 ea ff ff       	call   80104c0e <release>
8010614a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010614d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106152:	c9                   	leave  
80106153:	c3                   	ret    

80106154 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106154:	55                   	push   %ebp
80106155:	89 e5                	mov    %esp,%ebp
80106157:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010615a:	83 ec 0c             	sub    $0xc,%esp
8010615d:	68 40 72 19 80       	push   $0x80197240
80106162:	e8 39 ea ff ff       	call   80104ba0 <acquire>
80106167:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010616a:	a1 74 72 19 80       	mov    0x80197274,%eax
8010616f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106172:	83 ec 0c             	sub    $0xc,%esp
80106175:	68 40 72 19 80       	push   $0x80197240
8010617a:	e8 8f ea ff ff       	call   80104c0e <release>
8010617f:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106182:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106185:	c9                   	leave  
80106186:	c3                   	ret    

80106187 <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
80106187:	55                   	push   %ebp
80106188:	89 e5                	mov    %esp,%ebp
8010618a:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
8010618d:	83 ec 08             	sub    $0x8,%esp
80106190:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106193:	50                   	push   %eax
80106194:	6a 00                	push   $0x0
80106196:	e8 a6 ef ff ff       	call   80105141 <argint>
8010619b:	83 c4 10             	add    $0x10,%esp
8010619e:	85 c0                	test   %eax,%eax
801061a0:	79 07                	jns    801061a9 <sys_setSchedPolicy+0x22>
    return -1;
801061a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a7:	eb 0f                	jmp    801061b8 <sys_setSchedPolicy+0x31>
  return setSchedPolicy(policy);
801061a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ac:	83 ec 0c             	sub    $0xc,%esp
801061af:	50                   	push   %eax
801061b0:	e8 1f e7 ff ff       	call   801048d4 <setSchedPolicy>
801061b5:	83 c4 10             	add    $0x10,%esp
}
801061b8:	c9                   	leave  
801061b9:	c3                   	ret    

801061ba <sys_getpinfo>:



int
sys_getpinfo(void)
{
801061ba:	55                   	push   %ebp
801061bb:	89 e5                	mov    %esp,%ebp
801061bd:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(*ps)) < 0 )
801061c0:	83 ec 04             	sub    $0x4,%esp
801061c3:	68 00 0c 00 00       	push   $0xc00
801061c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061cb:	50                   	push   %eax
801061cc:	6a 00                	push   $0x0
801061ce:	e8 9b ef ff ff       	call   8010516e <argptr>
801061d3:	83 c4 10             	add    $0x10,%esp
801061d6:	85 c0                	test   %eax,%eax
801061d8:	79 07                	jns    801061e1 <sys_getpinfo+0x27>
    return -1;
801061da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061df:	eb 0f                	jmp    801061f0 <sys_getpinfo+0x36>
  return getpinfo(ps);
801061e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e4:	83 ec 0c             	sub    $0xc,%esp
801061e7:	50                   	push   %eax
801061e8:	e8 25 e7 ff ff       	call   80104912 <getpinfo>
801061ed:	83 c4 10             	add    $0x10,%esp
}
801061f0:	c9                   	leave  
801061f1:	c3                   	ret    

801061f2 <sys_yield>:

int
sys_yield(void)
{
801061f2:	55                   	push   %ebp
801061f3:	89 e5                	mov    %esp,%ebp
801061f5:	83 ec 08             	sub    $0x8,%esp
  yield();
801061f8:	e8 b2 e3 ff ff       	call   801045af <yield>
  return 0;
801061fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106202:	c9                   	leave  
80106203:	c3                   	ret    

80106204 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106204:	1e                   	push   %ds
  pushl %es
80106205:	06                   	push   %es
  pushl %fs
80106206:	0f a0                	push   %fs
  pushl %gs
80106208:	0f a8                	push   %gs
  pushal
8010620a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010620b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010620f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106211:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106213:	54                   	push   %esp
  call trap
80106214:	e8 d7 01 00 00       	call   801063f0 <trap>
  addl $4, %esp
80106219:	83 c4 04             	add    $0x4,%esp

8010621c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010621c:	61                   	popa   
  popl %gs
8010621d:	0f a9                	pop    %gs
  popl %fs
8010621f:	0f a1                	pop    %fs
  popl %es
80106221:	07                   	pop    %es
  popl %ds
80106222:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106223:	83 c4 08             	add    $0x8,%esp
  iret
80106226:	cf                   	iret   

80106227 <lidt>:
{
80106227:	55                   	push   %ebp
80106228:	89 e5                	mov    %esp,%ebp
8010622a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010622d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106230:	83 e8 01             	sub    $0x1,%eax
80106233:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106237:	8b 45 08             	mov    0x8(%ebp),%eax
8010623a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010623e:	8b 45 08             	mov    0x8(%ebp),%eax
80106241:	c1 e8 10             	shr    $0x10,%eax
80106244:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106248:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010624b:	0f 01 18             	lidtl  (%eax)
}
8010624e:	90                   	nop
8010624f:	c9                   	leave  
80106250:	c3                   	ret    

80106251 <rcr2>:

static inline uint
rcr2(void)
{
80106251:	55                   	push   %ebp
80106252:	89 e5                	mov    %esp,%ebp
80106254:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106257:	0f 20 d0             	mov    %cr2,%eax
8010625a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010625d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106260:	c9                   	leave  
80106261:	c3                   	ret    

80106262 <tvinit>:
  struct proc proc[NPROC];
} ptable;

void
tvinit(void)
{
80106262:	55                   	push   %ebp
80106263:	89 e5                	mov    %esp,%ebp
80106265:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106268:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010626f:	e9 c3 00 00 00       	jmp    80106337 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106277:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
8010627e:	89 c2                	mov    %eax,%edx
80106280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106283:	66 89 14 c5 40 6a 19 	mov    %dx,-0x7fe695c0(,%eax,8)
8010628a:	80 
8010628b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010628e:	66 c7 04 c5 42 6a 19 	movw   $0x8,-0x7fe695be(,%eax,8)
80106295:	80 08 00 
80106298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629b:	0f b6 14 c5 44 6a 19 	movzbl -0x7fe695bc(,%eax,8),%edx
801062a2:	80 
801062a3:	83 e2 e0             	and    $0xffffffe0,%edx
801062a6:	88 14 c5 44 6a 19 80 	mov    %dl,-0x7fe695bc(,%eax,8)
801062ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b0:	0f b6 14 c5 44 6a 19 	movzbl -0x7fe695bc(,%eax,8),%edx
801062b7:	80 
801062b8:	83 e2 1f             	and    $0x1f,%edx
801062bb:	88 14 c5 44 6a 19 80 	mov    %dl,-0x7fe695bc(,%eax,8)
801062c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c5:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
801062cc:	80 
801062cd:	83 e2 f0             	and    $0xfffffff0,%edx
801062d0:	83 ca 0e             	or     $0xe,%edx
801062d3:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
801062da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062dd:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
801062e4:	80 
801062e5:	83 e2 ef             	and    $0xffffffef,%edx
801062e8:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
801062ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f2:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
801062f9:	80 
801062fa:	83 e2 9f             	and    $0xffffff9f,%edx
801062fd:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
80106304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106307:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
8010630e:	80 
8010630f:	83 ca 80             	or     $0xffffff80,%edx
80106312:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
80106319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631c:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106323:	c1 e8 10             	shr    $0x10,%eax
80106326:	89 c2                	mov    %eax,%edx
80106328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632b:	66 89 14 c5 46 6a 19 	mov    %dx,-0x7fe695ba(,%eax,8)
80106332:	80 
  for(i = 0; i < 256; i++)
80106333:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106337:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010633e:	0f 8e 30 ff ff ff    	jle    80106274 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106344:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106349:	66 a3 40 6c 19 80    	mov    %ax,0x80196c40
8010634f:	66 c7 05 42 6c 19 80 	movw   $0x8,0x80196c42
80106356:	08 00 
80106358:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
8010635f:	83 e0 e0             	and    $0xffffffe0,%eax
80106362:	a2 44 6c 19 80       	mov    %al,0x80196c44
80106367:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
8010636e:	83 e0 1f             	and    $0x1f,%eax
80106371:	a2 44 6c 19 80       	mov    %al,0x80196c44
80106376:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
8010637d:	83 c8 0f             	or     $0xf,%eax
80106380:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106385:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
8010638c:	83 e0 ef             	and    $0xffffffef,%eax
8010638f:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106394:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
8010639b:	83 c8 60             	or     $0x60,%eax
8010639e:	a2 45 6c 19 80       	mov    %al,0x80196c45
801063a3:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
801063aa:	83 c8 80             	or     $0xffffff80,%eax
801063ad:	a2 45 6c 19 80       	mov    %al,0x80196c45
801063b2:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801063b7:	c1 e8 10             	shr    $0x10,%eax
801063ba:	66 a3 46 6c 19 80    	mov    %ax,0x80196c46

  initlock(&tickslock, "time");
801063c0:	83 ec 08             	sub    $0x8,%esp
801063c3:	68 24 aa 10 80       	push   $0x8010aa24
801063c8:	68 40 72 19 80       	push   $0x80197240
801063cd:	e8 ac e7 ff ff       	call   80104b7e <initlock>
801063d2:	83 c4 10             	add    $0x10,%esp
}
801063d5:	90                   	nop
801063d6:	c9                   	leave  
801063d7:	c3                   	ret    

801063d8 <idtinit>:

void
idtinit(void)
{
801063d8:	55                   	push   %ebp
801063d9:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801063db:	68 00 08 00 00       	push   $0x800
801063e0:	68 40 6a 19 80       	push   $0x80196a40
801063e5:	e8 3d fe ff ff       	call   80106227 <lidt>
801063ea:	83 c4 08             	add    $0x8,%esp
}
801063ed:	90                   	nop
801063ee:	c9                   	leave  
801063ef:	c3                   	ret    

801063f0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801063f0:	55                   	push   %ebp
801063f1:	89 e5                	mov    %esp,%ebp
801063f3:	57                   	push   %edi
801063f4:	56                   	push   %esi
801063f5:	53                   	push   %ebx
801063f6:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801063f9:	8b 45 08             	mov    0x8(%ebp),%eax
801063fc:	8b 40 30             	mov    0x30(%eax),%eax
801063ff:	83 f8 40             	cmp    $0x40,%eax
80106402:	75 3b                	jne    8010643f <trap+0x4f>
    if(myproc()->killed)
80106404:	e8 27 d6 ff ff       	call   80103a30 <myproc>
80106409:	8b 40 24             	mov    0x24(%eax),%eax
8010640c:	85 c0                	test   %eax,%eax
8010640e:	74 05                	je     80106415 <trap+0x25>
      exit();
80106410:	e8 ce da ff ff       	call   80103ee3 <exit>
    myproc()->tf = tf;
80106415:	e8 16 d6 ff ff       	call   80103a30 <myproc>
8010641a:	8b 55 08             	mov    0x8(%ebp),%edx
8010641d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106420:	e8 e8 ed ff ff       	call   8010520d <syscall>
    if(myproc()->killed)
80106425:	e8 06 d6 ff ff       	call   80103a30 <myproc>
8010642a:	8b 40 24             	mov    0x24(%eax),%eax
8010642d:	85 c0                	test   %eax,%eax
8010642f:	0f 84 f6 02 00 00    	je     8010672b <trap+0x33b>
      exit();
80106435:	e8 a9 da ff ff       	call   80103ee3 <exit>
    return;
8010643a:	e9 ec 02 00 00       	jmp    8010672b <trap+0x33b>
  }

  switch(tf->trapno){
8010643f:	8b 45 08             	mov    0x8(%ebp),%eax
80106442:	8b 40 30             	mov    0x30(%eax),%eax
80106445:	83 e8 20             	sub    $0x20,%eax
80106448:	83 f8 1f             	cmp    $0x1f,%eax
8010644b:	0f 87 8c 01 00 00    	ja     801065dd <trap+0x1ed>
80106451:	8b 04 85 00 ab 10 80 	mov    -0x7fef5500(,%eax,4),%eax
80106458:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010645a:	e8 3e d5 ff ff       	call   8010399d <cpuid>
8010645f:	85 c0                	test   %eax,%eax
80106461:	75 3d                	jne    801064a0 <trap+0xb0>
      acquire(&tickslock);
80106463:	83 ec 0c             	sub    $0xc,%esp
80106466:	68 40 72 19 80       	push   $0x80197240
8010646b:	e8 30 e7 ff ff       	call   80104ba0 <acquire>
80106470:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106473:	a1 74 72 19 80       	mov    0x80197274,%eax
80106478:	83 c0 01             	add    $0x1,%eax
8010647b:	a3 74 72 19 80       	mov    %eax,0x80197274
      wakeup(&ticks);
80106480:	83 ec 0c             	sub    $0xc,%esp
80106483:	68 74 72 19 80       	push   $0x80197274
80106488:	e8 8c e2 ff ff       	call   80104719 <wakeup>
8010648d:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106490:	83 ec 0c             	sub    $0xc,%esp
80106493:	68 40 72 19 80       	push   $0x80197240
80106498:	e8 71 e7 ff ff       	call   80104c0e <release>
8010649d:	83 c4 10             	add    $0x10,%esp
    }
    //추가
    struct proc *curproc = myproc();
801064a0:	e8 8b d5 ff ff       	call   80103a30 <myproc>
801064a5:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (curproc && curproc->state == RUNNING) {
801064a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801064ac:	74 53                	je     80106501 <trap+0x111>
801064ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064b1:	8b 40 0c             	mov    0xc(%eax),%eax
801064b4:	83 f8 04             	cmp    $0x4,%eax
801064b7:	75 48                	jne    80106501 <trap+0x111>
      int q = curproc->priority;
801064b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064bc:	8b 40 7c             	mov    0x7c(%eax),%eax
801064bf:	89 45 dc             	mov    %eax,-0x24(%ebp)

      curproc->ticks[q]++;
801064c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801064c8:	83 c2 20             	add    $0x20,%edx
801064cb:	8b 04 90             	mov    (%eax,%edx,4),%eax
801064ce:	8d 48 01             	lea    0x1(%eax),%ecx
801064d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801064d7:	83 c2 20             	add    $0x20,%edx
801064da:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
      cprintf("[TRAP] pid %d | Q%d | tick=%d\n", curproc->pid, q, curproc->ticks[q]);
801064dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801064e3:	83 c2 20             	add    $0x20,%edx
801064e6:	8b 14 90             	mov    (%eax,%edx,4),%edx
801064e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064ec:	8b 40 10             	mov    0x10(%eax),%eax
801064ef:	52                   	push   %edx
801064f0:	ff 75 dc             	push   -0x24(%ebp)
801064f3:	50                   	push   %eax
801064f4:	68 2c aa 10 80       	push   $0x8010aa2c
801064f9:	e8 f6 9e ff ff       	call   801003f4 <cprintf>
801064fe:	83 c4 10             	add    $0x10,%esp

    }
    // RUNNABLE 상태이면서 현재 실행 중이 아닌 애들: wait_ticks 증가
    acquire(&ptable.lock);
80106501:	83 ec 0c             	sub    $0xc,%esp
80106504:	68 00 42 19 80       	push   $0x80194200
80106509:	e8 92 e6 ff ff       	call   80104ba0 <acquire>
8010650e:	83 c4 10             	add    $0x10,%esp
    struct proc *p;
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106511:	c7 45 e4 34 42 19 80 	movl   $0x80194234,-0x1c(%ebp)
80106518:	eb 35                	jmp    8010654f <trap+0x15f>
      if (p != curproc && p->state == RUNNABLE) {
8010651a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010651d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
80106520:	74 26                	je     80106548 <trap+0x158>
80106522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106525:	8b 40 0c             	mov    0xc(%eax),%eax
80106528:	83 f8 03             	cmp    $0x3,%eax
8010652b:	75 1b                	jne    80106548 <trap+0x158>
        p->wait_ticks[p->priority]++;
8010652d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106530:	8b 40 7c             	mov    0x7c(%eax),%eax
80106533:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106536:	8d 48 24             	lea    0x24(%eax),%ecx
80106539:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
8010653c:	8d 4a 01             	lea    0x1(%edx),%ecx
8010653f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106542:	83 c0 24             	add    $0x24,%eax
80106545:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106548:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
8010654f:	81 7d e4 34 6a 19 80 	cmpl   $0x80196a34,-0x1c(%ebp)
80106556:	72 c2                	jb     8010651a <trap+0x12a>
      }
    }
    release(&ptable.lock);
80106558:	83 ec 0c             	sub    $0xc,%esp
8010655b:	68 00 42 19 80       	push   $0x80194200
80106560:	e8 a9 e6 ff ff       	call   80104c0e <release>
80106565:	83 c4 10             	add    $0x10,%esp

    lapiceoi();
80106568:	e8 af c5 ff ff       	call   80102b1c <lapiceoi>
    break;
8010656d:	e9 20 01 00 00       	jmp    80106692 <trap+0x2a2>

  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106572:	e8 0e 3f 00 00       	call   8010a485 <ideintr>
    lapiceoi();
80106577:	e8 a0 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
8010657c:	e9 11 01 00 00       	jmp    80106692 <trap+0x2a2>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106581:	e8 db c3 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
80106586:	e8 91 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
8010658b:	e9 02 01 00 00       	jmp    80106692 <trap+0x2a2>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106590:	e8 6c 03 00 00       	call   80106901 <uartintr>
    lapiceoi();
80106595:	e8 82 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
8010659a:	e9 f3 00 00 00       	jmp    80106692 <trap+0x2a2>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010659f:	e8 94 2b 00 00       	call   80109138 <i8254_intr>
    lapiceoi();
801065a4:	e8 73 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
801065a9:	e9 e4 00 00 00       	jmp    80106692 <trap+0x2a2>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065ae:	8b 45 08             	mov    0x8(%ebp),%eax
801065b1:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801065b4:	8b 45 08             	mov    0x8(%ebp),%eax
801065b7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065bb:	0f b7 d8             	movzwl %ax,%ebx
801065be:	e8 da d3 ff ff       	call   8010399d <cpuid>
801065c3:	56                   	push   %esi
801065c4:	53                   	push   %ebx
801065c5:	50                   	push   %eax
801065c6:	68 4c aa 10 80       	push   $0x8010aa4c
801065cb:	e8 24 9e ff ff       	call   801003f4 <cprintf>
801065d0:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801065d3:	e8 44 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
801065d8:	e9 b5 00 00 00       	jmp    80106692 <trap+0x2a2>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801065dd:	e8 4e d4 ff ff       	call   80103a30 <myproc>
801065e2:	85 c0                	test   %eax,%eax
801065e4:	74 11                	je     801065f7 <trap+0x207>
801065e6:	8b 45 08             	mov    0x8(%ebp),%eax
801065e9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801065ed:	0f b7 c0             	movzwl %ax,%eax
801065f0:	83 e0 03             	and    $0x3,%eax
801065f3:	85 c0                	test   %eax,%eax
801065f5:	75 39                	jne    80106630 <trap+0x240>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065f7:	e8 55 fc ff ff       	call   80106251 <rcr2>
801065fc:	89 c3                	mov    %eax,%ebx
801065fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106601:	8b 70 38             	mov    0x38(%eax),%esi
80106604:	e8 94 d3 ff ff       	call   8010399d <cpuid>
80106609:	8b 55 08             	mov    0x8(%ebp),%edx
8010660c:	8b 52 30             	mov    0x30(%edx),%edx
8010660f:	83 ec 0c             	sub    $0xc,%esp
80106612:	53                   	push   %ebx
80106613:	56                   	push   %esi
80106614:	50                   	push   %eax
80106615:	52                   	push   %edx
80106616:	68 70 aa 10 80       	push   $0x8010aa70
8010661b:	e8 d4 9d ff ff       	call   801003f4 <cprintf>
80106620:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106623:	83 ec 0c             	sub    $0xc,%esp
80106626:	68 a2 aa 10 80       	push   $0x8010aaa2
8010662b:	e8 79 9f ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106630:	e8 1c fc ff ff       	call   80106251 <rcr2>
80106635:	89 c6                	mov    %eax,%esi
80106637:	8b 45 08             	mov    0x8(%ebp),%eax
8010663a:	8b 40 38             	mov    0x38(%eax),%eax
8010663d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106640:	e8 58 d3 ff ff       	call   8010399d <cpuid>
80106645:	89 c3                	mov    %eax,%ebx
80106647:	8b 45 08             	mov    0x8(%ebp),%eax
8010664a:	8b 78 34             	mov    0x34(%eax),%edi
8010664d:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106650:	8b 45 08             	mov    0x8(%ebp),%eax
80106653:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106656:	e8 d5 d3 ff ff       	call   80103a30 <myproc>
8010665b:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010665e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
80106661:	e8 ca d3 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106666:	8b 40 10             	mov    0x10(%eax),%eax
80106669:	56                   	push   %esi
8010666a:	ff 75 d4             	push   -0x2c(%ebp)
8010666d:	53                   	push   %ebx
8010666e:	ff 75 d0             	push   -0x30(%ebp)
80106671:	57                   	push   %edi
80106672:	ff 75 cc             	push   -0x34(%ebp)
80106675:	50                   	push   %eax
80106676:	68 a8 aa 10 80       	push   $0x8010aaa8
8010667b:	e8 74 9d ff ff       	call   801003f4 <cprintf>
80106680:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106683:	e8 a8 d3 ff ff       	call   80103a30 <myproc>
80106688:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010668f:	eb 01                	jmp    80106692 <trap+0x2a2>
    break;
80106691:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106692:	e8 99 d3 ff ff       	call   80103a30 <myproc>
80106697:	85 c0                	test   %eax,%eax
80106699:	74 23                	je     801066be <trap+0x2ce>
8010669b:	e8 90 d3 ff ff       	call   80103a30 <myproc>
801066a0:	8b 40 24             	mov    0x24(%eax),%eax
801066a3:	85 c0                	test   %eax,%eax
801066a5:	74 17                	je     801066be <trap+0x2ce>
801066a7:	8b 45 08             	mov    0x8(%ebp),%eax
801066aa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066ae:	0f b7 c0             	movzwl %ax,%eax
801066b1:	83 e0 03             	and    $0x3,%eax
801066b4:	83 f8 03             	cmp    $0x3,%eax
801066b7:	75 05                	jne    801066be <trap+0x2ce>
    exit();
801066b9:	e8 25 d8 ff ff       	call   80103ee3 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
801066be:	e8 6d d3 ff ff       	call   80103a30 <myproc>
801066c3:	85 c0                	test   %eax,%eax
801066c5:	74 36                	je     801066fd <trap+0x30d>
801066c7:	e8 64 d3 ff ff       	call   80103a30 <myproc>
801066cc:	8b 40 0c             	mov    0xc(%eax),%eax
801066cf:	83 f8 04             	cmp    $0x4,%eax
801066d2:	75 29                	jne    801066fd <trap+0x30d>
801066d4:	8b 45 08             	mov    0x8(%ebp),%eax
801066d7:	8b 40 30             	mov    0x30(%eax),%eax
801066da:	83 f8 20             	cmp    $0x20,%eax
801066dd:	75 1e                	jne    801066fd <trap+0x30d>
      cprintf("[YIELD] from pid %d\n", myproc()->pid);
801066df:	e8 4c d3 ff ff       	call   80103a30 <myproc>
801066e4:	8b 40 10             	mov    0x10(%eax),%eax
801066e7:	83 ec 08             	sub    $0x8,%esp
801066ea:	50                   	push   %eax
801066eb:	68 eb aa 10 80       	push   $0x8010aaeb
801066f0:	e8 ff 9c ff ff       	call   801003f4 <cprintf>
801066f5:	83 c4 10             	add    $0x10,%esp
      yield();
801066f8:	e8 b2 de ff ff       	call   801045af <yield>
  }

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801066fd:	e8 2e d3 ff ff       	call   80103a30 <myproc>
80106702:	85 c0                	test   %eax,%eax
80106704:	74 26                	je     8010672c <trap+0x33c>
80106706:	e8 25 d3 ff ff       	call   80103a30 <myproc>
8010670b:	8b 40 24             	mov    0x24(%eax),%eax
8010670e:	85 c0                	test   %eax,%eax
80106710:	74 1a                	je     8010672c <trap+0x33c>
80106712:	8b 45 08             	mov    0x8(%ebp),%eax
80106715:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106719:	0f b7 c0             	movzwl %ax,%eax
8010671c:	83 e0 03             	and    $0x3,%eax
8010671f:	83 f8 03             	cmp    $0x3,%eax
80106722:	75 08                	jne    8010672c <trap+0x33c>
    exit();
80106724:	e8 ba d7 ff ff       	call   80103ee3 <exit>
80106729:	eb 01                	jmp    8010672c <trap+0x33c>
    return;
8010672b:	90                   	nop
8010672c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010672f:	5b                   	pop    %ebx
80106730:	5e                   	pop    %esi
80106731:	5f                   	pop    %edi
80106732:	5d                   	pop    %ebp
80106733:	c3                   	ret    

80106734 <inb>:
{
80106734:	55                   	push   %ebp
80106735:	89 e5                	mov    %esp,%ebp
80106737:	83 ec 14             	sub    $0x14,%esp
8010673a:	8b 45 08             	mov    0x8(%ebp),%eax
8010673d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106741:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106745:	89 c2                	mov    %eax,%edx
80106747:	ec                   	in     (%dx),%al
80106748:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010674b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010674f:	c9                   	leave  
80106750:	c3                   	ret    

80106751 <outb>:
{
80106751:	55                   	push   %ebp
80106752:	89 e5                	mov    %esp,%ebp
80106754:	83 ec 08             	sub    $0x8,%esp
80106757:	8b 45 08             	mov    0x8(%ebp),%eax
8010675a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010675d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106761:	89 d0                	mov    %edx,%eax
80106763:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106766:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010676a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010676e:	ee                   	out    %al,(%dx)
}
8010676f:	90                   	nop
80106770:	c9                   	leave  
80106771:	c3                   	ret    

80106772 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106772:	55                   	push   %ebp
80106773:	89 e5                	mov    %esp,%ebp
80106775:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106778:	6a 00                	push   $0x0
8010677a:	68 fa 03 00 00       	push   $0x3fa
8010677f:	e8 cd ff ff ff       	call   80106751 <outb>
80106784:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106787:	68 80 00 00 00       	push   $0x80
8010678c:	68 fb 03 00 00       	push   $0x3fb
80106791:	e8 bb ff ff ff       	call   80106751 <outb>
80106796:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106799:	6a 0c                	push   $0xc
8010679b:	68 f8 03 00 00       	push   $0x3f8
801067a0:	e8 ac ff ff ff       	call   80106751 <outb>
801067a5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801067a8:	6a 00                	push   $0x0
801067aa:	68 f9 03 00 00       	push   $0x3f9
801067af:	e8 9d ff ff ff       	call   80106751 <outb>
801067b4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801067b7:	6a 03                	push   $0x3
801067b9:	68 fb 03 00 00       	push   $0x3fb
801067be:	e8 8e ff ff ff       	call   80106751 <outb>
801067c3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801067c6:	6a 00                	push   $0x0
801067c8:	68 fc 03 00 00       	push   $0x3fc
801067cd:	e8 7f ff ff ff       	call   80106751 <outb>
801067d2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801067d5:	6a 01                	push   $0x1
801067d7:	68 f9 03 00 00       	push   $0x3f9
801067dc:	e8 70 ff ff ff       	call   80106751 <outb>
801067e1:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801067e4:	68 fd 03 00 00       	push   $0x3fd
801067e9:	e8 46 ff ff ff       	call   80106734 <inb>
801067ee:	83 c4 04             	add    $0x4,%esp
801067f1:	3c ff                	cmp    $0xff,%al
801067f3:	74 61                	je     80106856 <uartinit+0xe4>
    return;
  uart = 1;
801067f5:	c7 05 78 72 19 80 01 	movl   $0x1,0x80197278
801067fc:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801067ff:	68 fa 03 00 00       	push   $0x3fa
80106804:	e8 2b ff ff ff       	call   80106734 <inb>
80106809:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010680c:	68 f8 03 00 00       	push   $0x3f8
80106811:	e8 1e ff ff ff       	call   80106734 <inb>
80106816:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106819:	83 ec 08             	sub    $0x8,%esp
8010681c:	6a 00                	push   $0x0
8010681e:	6a 04                	push   $0x4
80106820:	e8 09 be ff ff       	call   8010262e <ioapicenable>
80106825:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106828:	c7 45 f4 80 ab 10 80 	movl   $0x8010ab80,-0xc(%ebp)
8010682f:	eb 19                	jmp    8010684a <uartinit+0xd8>
    uartputc(*p);
80106831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106834:	0f b6 00             	movzbl (%eax),%eax
80106837:	0f be c0             	movsbl %al,%eax
8010683a:	83 ec 0c             	sub    $0xc,%esp
8010683d:	50                   	push   %eax
8010683e:	e8 16 00 00 00       	call   80106859 <uartputc>
80106843:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106846:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010684a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684d:	0f b6 00             	movzbl (%eax),%eax
80106850:	84 c0                	test   %al,%al
80106852:	75 dd                	jne    80106831 <uartinit+0xbf>
80106854:	eb 01                	jmp    80106857 <uartinit+0xe5>
    return;
80106856:	90                   	nop
}
80106857:	c9                   	leave  
80106858:	c3                   	ret    

80106859 <uartputc>:

void
uartputc(int c)
{
80106859:	55                   	push   %ebp
8010685a:	89 e5                	mov    %esp,%ebp
8010685c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010685f:	a1 78 72 19 80       	mov    0x80197278,%eax
80106864:	85 c0                	test   %eax,%eax
80106866:	74 53                	je     801068bb <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106868:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010686f:	eb 11                	jmp    80106882 <uartputc+0x29>
    microdelay(10);
80106871:	83 ec 0c             	sub    $0xc,%esp
80106874:	6a 0a                	push   $0xa
80106876:	e8 bc c2 ff ff       	call   80102b37 <microdelay>
8010687b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010687e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106882:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106886:	7f 1a                	jg     801068a2 <uartputc+0x49>
80106888:	83 ec 0c             	sub    $0xc,%esp
8010688b:	68 fd 03 00 00       	push   $0x3fd
80106890:	e8 9f fe ff ff       	call   80106734 <inb>
80106895:	83 c4 10             	add    $0x10,%esp
80106898:	0f b6 c0             	movzbl %al,%eax
8010689b:	83 e0 20             	and    $0x20,%eax
8010689e:	85 c0                	test   %eax,%eax
801068a0:	74 cf                	je     80106871 <uartputc+0x18>
  outb(COM1+0, c);
801068a2:	8b 45 08             	mov    0x8(%ebp),%eax
801068a5:	0f b6 c0             	movzbl %al,%eax
801068a8:	83 ec 08             	sub    $0x8,%esp
801068ab:	50                   	push   %eax
801068ac:	68 f8 03 00 00       	push   $0x3f8
801068b1:	e8 9b fe ff ff       	call   80106751 <outb>
801068b6:	83 c4 10             	add    $0x10,%esp
801068b9:	eb 01                	jmp    801068bc <uartputc+0x63>
    return;
801068bb:	90                   	nop
}
801068bc:	c9                   	leave  
801068bd:	c3                   	ret    

801068be <uartgetc>:

static int
uartgetc(void)
{
801068be:	55                   	push   %ebp
801068bf:	89 e5                	mov    %esp,%ebp
  if(!uart)
801068c1:	a1 78 72 19 80       	mov    0x80197278,%eax
801068c6:	85 c0                	test   %eax,%eax
801068c8:	75 07                	jne    801068d1 <uartgetc+0x13>
    return -1;
801068ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cf:	eb 2e                	jmp    801068ff <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801068d1:	68 fd 03 00 00       	push   $0x3fd
801068d6:	e8 59 fe ff ff       	call   80106734 <inb>
801068db:	83 c4 04             	add    $0x4,%esp
801068de:	0f b6 c0             	movzbl %al,%eax
801068e1:	83 e0 01             	and    $0x1,%eax
801068e4:	85 c0                	test   %eax,%eax
801068e6:	75 07                	jne    801068ef <uartgetc+0x31>
    return -1;
801068e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ed:	eb 10                	jmp    801068ff <uartgetc+0x41>
  return inb(COM1+0);
801068ef:	68 f8 03 00 00       	push   $0x3f8
801068f4:	e8 3b fe ff ff       	call   80106734 <inb>
801068f9:	83 c4 04             	add    $0x4,%esp
801068fc:	0f b6 c0             	movzbl %al,%eax
}
801068ff:	c9                   	leave  
80106900:	c3                   	ret    

80106901 <uartintr>:

void
uartintr(void)
{
80106901:	55                   	push   %ebp
80106902:	89 e5                	mov    %esp,%ebp
80106904:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106907:	83 ec 0c             	sub    $0xc,%esp
8010690a:	68 be 68 10 80       	push   $0x801068be
8010690f:	e8 c2 9e ff ff       	call   801007d6 <consoleintr>
80106914:	83 c4 10             	add    $0x10,%esp
}
80106917:	90                   	nop
80106918:	c9                   	leave  
80106919:	c3                   	ret    

8010691a <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010691a:	6a 00                	push   $0x0
  pushl $0
8010691c:	6a 00                	push   $0x0
  jmp alltraps
8010691e:	e9 e1 f8 ff ff       	jmp    80106204 <alltraps>

80106923 <vector1>:
.globl vector1
vector1:
  pushl $0
80106923:	6a 00                	push   $0x0
  pushl $1
80106925:	6a 01                	push   $0x1
  jmp alltraps
80106927:	e9 d8 f8 ff ff       	jmp    80106204 <alltraps>

8010692c <vector2>:
.globl vector2
vector2:
  pushl $0
8010692c:	6a 00                	push   $0x0
  pushl $2
8010692e:	6a 02                	push   $0x2
  jmp alltraps
80106930:	e9 cf f8 ff ff       	jmp    80106204 <alltraps>

80106935 <vector3>:
.globl vector3
vector3:
  pushl $0
80106935:	6a 00                	push   $0x0
  pushl $3
80106937:	6a 03                	push   $0x3
  jmp alltraps
80106939:	e9 c6 f8 ff ff       	jmp    80106204 <alltraps>

8010693e <vector4>:
.globl vector4
vector4:
  pushl $0
8010693e:	6a 00                	push   $0x0
  pushl $4
80106940:	6a 04                	push   $0x4
  jmp alltraps
80106942:	e9 bd f8 ff ff       	jmp    80106204 <alltraps>

80106947 <vector5>:
.globl vector5
vector5:
  pushl $0
80106947:	6a 00                	push   $0x0
  pushl $5
80106949:	6a 05                	push   $0x5
  jmp alltraps
8010694b:	e9 b4 f8 ff ff       	jmp    80106204 <alltraps>

80106950 <vector6>:
.globl vector6
vector6:
  pushl $0
80106950:	6a 00                	push   $0x0
  pushl $6
80106952:	6a 06                	push   $0x6
  jmp alltraps
80106954:	e9 ab f8 ff ff       	jmp    80106204 <alltraps>

80106959 <vector7>:
.globl vector7
vector7:
  pushl $0
80106959:	6a 00                	push   $0x0
  pushl $7
8010695b:	6a 07                	push   $0x7
  jmp alltraps
8010695d:	e9 a2 f8 ff ff       	jmp    80106204 <alltraps>

80106962 <vector8>:
.globl vector8
vector8:
  pushl $8
80106962:	6a 08                	push   $0x8
  jmp alltraps
80106964:	e9 9b f8 ff ff       	jmp    80106204 <alltraps>

80106969 <vector9>:
.globl vector9
vector9:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $9
8010696b:	6a 09                	push   $0x9
  jmp alltraps
8010696d:	e9 92 f8 ff ff       	jmp    80106204 <alltraps>

80106972 <vector10>:
.globl vector10
vector10:
  pushl $10
80106972:	6a 0a                	push   $0xa
  jmp alltraps
80106974:	e9 8b f8 ff ff       	jmp    80106204 <alltraps>

80106979 <vector11>:
.globl vector11
vector11:
  pushl $11
80106979:	6a 0b                	push   $0xb
  jmp alltraps
8010697b:	e9 84 f8 ff ff       	jmp    80106204 <alltraps>

80106980 <vector12>:
.globl vector12
vector12:
  pushl $12
80106980:	6a 0c                	push   $0xc
  jmp alltraps
80106982:	e9 7d f8 ff ff       	jmp    80106204 <alltraps>

80106987 <vector13>:
.globl vector13
vector13:
  pushl $13
80106987:	6a 0d                	push   $0xd
  jmp alltraps
80106989:	e9 76 f8 ff ff       	jmp    80106204 <alltraps>

8010698e <vector14>:
.globl vector14
vector14:
  pushl $14
8010698e:	6a 0e                	push   $0xe
  jmp alltraps
80106990:	e9 6f f8 ff ff       	jmp    80106204 <alltraps>

80106995 <vector15>:
.globl vector15
vector15:
  pushl $0
80106995:	6a 00                	push   $0x0
  pushl $15
80106997:	6a 0f                	push   $0xf
  jmp alltraps
80106999:	e9 66 f8 ff ff       	jmp    80106204 <alltraps>

8010699e <vector16>:
.globl vector16
vector16:
  pushl $0
8010699e:	6a 00                	push   $0x0
  pushl $16
801069a0:	6a 10                	push   $0x10
  jmp alltraps
801069a2:	e9 5d f8 ff ff       	jmp    80106204 <alltraps>

801069a7 <vector17>:
.globl vector17
vector17:
  pushl $17
801069a7:	6a 11                	push   $0x11
  jmp alltraps
801069a9:	e9 56 f8 ff ff       	jmp    80106204 <alltraps>

801069ae <vector18>:
.globl vector18
vector18:
  pushl $0
801069ae:	6a 00                	push   $0x0
  pushl $18
801069b0:	6a 12                	push   $0x12
  jmp alltraps
801069b2:	e9 4d f8 ff ff       	jmp    80106204 <alltraps>

801069b7 <vector19>:
.globl vector19
vector19:
  pushl $0
801069b7:	6a 00                	push   $0x0
  pushl $19
801069b9:	6a 13                	push   $0x13
  jmp alltraps
801069bb:	e9 44 f8 ff ff       	jmp    80106204 <alltraps>

801069c0 <vector20>:
.globl vector20
vector20:
  pushl $0
801069c0:	6a 00                	push   $0x0
  pushl $20
801069c2:	6a 14                	push   $0x14
  jmp alltraps
801069c4:	e9 3b f8 ff ff       	jmp    80106204 <alltraps>

801069c9 <vector21>:
.globl vector21
vector21:
  pushl $0
801069c9:	6a 00                	push   $0x0
  pushl $21
801069cb:	6a 15                	push   $0x15
  jmp alltraps
801069cd:	e9 32 f8 ff ff       	jmp    80106204 <alltraps>

801069d2 <vector22>:
.globl vector22
vector22:
  pushl $0
801069d2:	6a 00                	push   $0x0
  pushl $22
801069d4:	6a 16                	push   $0x16
  jmp alltraps
801069d6:	e9 29 f8 ff ff       	jmp    80106204 <alltraps>

801069db <vector23>:
.globl vector23
vector23:
  pushl $0
801069db:	6a 00                	push   $0x0
  pushl $23
801069dd:	6a 17                	push   $0x17
  jmp alltraps
801069df:	e9 20 f8 ff ff       	jmp    80106204 <alltraps>

801069e4 <vector24>:
.globl vector24
vector24:
  pushl $0
801069e4:	6a 00                	push   $0x0
  pushl $24
801069e6:	6a 18                	push   $0x18
  jmp alltraps
801069e8:	e9 17 f8 ff ff       	jmp    80106204 <alltraps>

801069ed <vector25>:
.globl vector25
vector25:
  pushl $0
801069ed:	6a 00                	push   $0x0
  pushl $25
801069ef:	6a 19                	push   $0x19
  jmp alltraps
801069f1:	e9 0e f8 ff ff       	jmp    80106204 <alltraps>

801069f6 <vector26>:
.globl vector26
vector26:
  pushl $0
801069f6:	6a 00                	push   $0x0
  pushl $26
801069f8:	6a 1a                	push   $0x1a
  jmp alltraps
801069fa:	e9 05 f8 ff ff       	jmp    80106204 <alltraps>

801069ff <vector27>:
.globl vector27
vector27:
  pushl $0
801069ff:	6a 00                	push   $0x0
  pushl $27
80106a01:	6a 1b                	push   $0x1b
  jmp alltraps
80106a03:	e9 fc f7 ff ff       	jmp    80106204 <alltraps>

80106a08 <vector28>:
.globl vector28
vector28:
  pushl $0
80106a08:	6a 00                	push   $0x0
  pushl $28
80106a0a:	6a 1c                	push   $0x1c
  jmp alltraps
80106a0c:	e9 f3 f7 ff ff       	jmp    80106204 <alltraps>

80106a11 <vector29>:
.globl vector29
vector29:
  pushl $0
80106a11:	6a 00                	push   $0x0
  pushl $29
80106a13:	6a 1d                	push   $0x1d
  jmp alltraps
80106a15:	e9 ea f7 ff ff       	jmp    80106204 <alltraps>

80106a1a <vector30>:
.globl vector30
vector30:
  pushl $0
80106a1a:	6a 00                	push   $0x0
  pushl $30
80106a1c:	6a 1e                	push   $0x1e
  jmp alltraps
80106a1e:	e9 e1 f7 ff ff       	jmp    80106204 <alltraps>

80106a23 <vector31>:
.globl vector31
vector31:
  pushl $0
80106a23:	6a 00                	push   $0x0
  pushl $31
80106a25:	6a 1f                	push   $0x1f
  jmp alltraps
80106a27:	e9 d8 f7 ff ff       	jmp    80106204 <alltraps>

80106a2c <vector32>:
.globl vector32
vector32:
  pushl $0
80106a2c:	6a 00                	push   $0x0
  pushl $32
80106a2e:	6a 20                	push   $0x20
  jmp alltraps
80106a30:	e9 cf f7 ff ff       	jmp    80106204 <alltraps>

80106a35 <vector33>:
.globl vector33
vector33:
  pushl $0
80106a35:	6a 00                	push   $0x0
  pushl $33
80106a37:	6a 21                	push   $0x21
  jmp alltraps
80106a39:	e9 c6 f7 ff ff       	jmp    80106204 <alltraps>

80106a3e <vector34>:
.globl vector34
vector34:
  pushl $0
80106a3e:	6a 00                	push   $0x0
  pushl $34
80106a40:	6a 22                	push   $0x22
  jmp alltraps
80106a42:	e9 bd f7 ff ff       	jmp    80106204 <alltraps>

80106a47 <vector35>:
.globl vector35
vector35:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $35
80106a49:	6a 23                	push   $0x23
  jmp alltraps
80106a4b:	e9 b4 f7 ff ff       	jmp    80106204 <alltraps>

80106a50 <vector36>:
.globl vector36
vector36:
  pushl $0
80106a50:	6a 00                	push   $0x0
  pushl $36
80106a52:	6a 24                	push   $0x24
  jmp alltraps
80106a54:	e9 ab f7 ff ff       	jmp    80106204 <alltraps>

80106a59 <vector37>:
.globl vector37
vector37:
  pushl $0
80106a59:	6a 00                	push   $0x0
  pushl $37
80106a5b:	6a 25                	push   $0x25
  jmp alltraps
80106a5d:	e9 a2 f7 ff ff       	jmp    80106204 <alltraps>

80106a62 <vector38>:
.globl vector38
vector38:
  pushl $0
80106a62:	6a 00                	push   $0x0
  pushl $38
80106a64:	6a 26                	push   $0x26
  jmp alltraps
80106a66:	e9 99 f7 ff ff       	jmp    80106204 <alltraps>

80106a6b <vector39>:
.globl vector39
vector39:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $39
80106a6d:	6a 27                	push   $0x27
  jmp alltraps
80106a6f:	e9 90 f7 ff ff       	jmp    80106204 <alltraps>

80106a74 <vector40>:
.globl vector40
vector40:
  pushl $0
80106a74:	6a 00                	push   $0x0
  pushl $40
80106a76:	6a 28                	push   $0x28
  jmp alltraps
80106a78:	e9 87 f7 ff ff       	jmp    80106204 <alltraps>

80106a7d <vector41>:
.globl vector41
vector41:
  pushl $0
80106a7d:	6a 00                	push   $0x0
  pushl $41
80106a7f:	6a 29                	push   $0x29
  jmp alltraps
80106a81:	e9 7e f7 ff ff       	jmp    80106204 <alltraps>

80106a86 <vector42>:
.globl vector42
vector42:
  pushl $0
80106a86:	6a 00                	push   $0x0
  pushl $42
80106a88:	6a 2a                	push   $0x2a
  jmp alltraps
80106a8a:	e9 75 f7 ff ff       	jmp    80106204 <alltraps>

80106a8f <vector43>:
.globl vector43
vector43:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $43
80106a91:	6a 2b                	push   $0x2b
  jmp alltraps
80106a93:	e9 6c f7 ff ff       	jmp    80106204 <alltraps>

80106a98 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a98:	6a 00                	push   $0x0
  pushl $44
80106a9a:	6a 2c                	push   $0x2c
  jmp alltraps
80106a9c:	e9 63 f7 ff ff       	jmp    80106204 <alltraps>

80106aa1 <vector45>:
.globl vector45
vector45:
  pushl $0
80106aa1:	6a 00                	push   $0x0
  pushl $45
80106aa3:	6a 2d                	push   $0x2d
  jmp alltraps
80106aa5:	e9 5a f7 ff ff       	jmp    80106204 <alltraps>

80106aaa <vector46>:
.globl vector46
vector46:
  pushl $0
80106aaa:	6a 00                	push   $0x0
  pushl $46
80106aac:	6a 2e                	push   $0x2e
  jmp alltraps
80106aae:	e9 51 f7 ff ff       	jmp    80106204 <alltraps>

80106ab3 <vector47>:
.globl vector47
vector47:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $47
80106ab5:	6a 2f                	push   $0x2f
  jmp alltraps
80106ab7:	e9 48 f7 ff ff       	jmp    80106204 <alltraps>

80106abc <vector48>:
.globl vector48
vector48:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $48
80106abe:	6a 30                	push   $0x30
  jmp alltraps
80106ac0:	e9 3f f7 ff ff       	jmp    80106204 <alltraps>

80106ac5 <vector49>:
.globl vector49
vector49:
  pushl $0
80106ac5:	6a 00                	push   $0x0
  pushl $49
80106ac7:	6a 31                	push   $0x31
  jmp alltraps
80106ac9:	e9 36 f7 ff ff       	jmp    80106204 <alltraps>

80106ace <vector50>:
.globl vector50
vector50:
  pushl $0
80106ace:	6a 00                	push   $0x0
  pushl $50
80106ad0:	6a 32                	push   $0x32
  jmp alltraps
80106ad2:	e9 2d f7 ff ff       	jmp    80106204 <alltraps>

80106ad7 <vector51>:
.globl vector51
vector51:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $51
80106ad9:	6a 33                	push   $0x33
  jmp alltraps
80106adb:	e9 24 f7 ff ff       	jmp    80106204 <alltraps>

80106ae0 <vector52>:
.globl vector52
vector52:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $52
80106ae2:	6a 34                	push   $0x34
  jmp alltraps
80106ae4:	e9 1b f7 ff ff       	jmp    80106204 <alltraps>

80106ae9 <vector53>:
.globl vector53
vector53:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $53
80106aeb:	6a 35                	push   $0x35
  jmp alltraps
80106aed:	e9 12 f7 ff ff       	jmp    80106204 <alltraps>

80106af2 <vector54>:
.globl vector54
vector54:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $54
80106af4:	6a 36                	push   $0x36
  jmp alltraps
80106af6:	e9 09 f7 ff ff       	jmp    80106204 <alltraps>

80106afb <vector55>:
.globl vector55
vector55:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $55
80106afd:	6a 37                	push   $0x37
  jmp alltraps
80106aff:	e9 00 f7 ff ff       	jmp    80106204 <alltraps>

80106b04 <vector56>:
.globl vector56
vector56:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $56
80106b06:	6a 38                	push   $0x38
  jmp alltraps
80106b08:	e9 f7 f6 ff ff       	jmp    80106204 <alltraps>

80106b0d <vector57>:
.globl vector57
vector57:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $57
80106b0f:	6a 39                	push   $0x39
  jmp alltraps
80106b11:	e9 ee f6 ff ff       	jmp    80106204 <alltraps>

80106b16 <vector58>:
.globl vector58
vector58:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $58
80106b18:	6a 3a                	push   $0x3a
  jmp alltraps
80106b1a:	e9 e5 f6 ff ff       	jmp    80106204 <alltraps>

80106b1f <vector59>:
.globl vector59
vector59:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $59
80106b21:	6a 3b                	push   $0x3b
  jmp alltraps
80106b23:	e9 dc f6 ff ff       	jmp    80106204 <alltraps>

80106b28 <vector60>:
.globl vector60
vector60:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $60
80106b2a:	6a 3c                	push   $0x3c
  jmp alltraps
80106b2c:	e9 d3 f6 ff ff       	jmp    80106204 <alltraps>

80106b31 <vector61>:
.globl vector61
vector61:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $61
80106b33:	6a 3d                	push   $0x3d
  jmp alltraps
80106b35:	e9 ca f6 ff ff       	jmp    80106204 <alltraps>

80106b3a <vector62>:
.globl vector62
vector62:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $62
80106b3c:	6a 3e                	push   $0x3e
  jmp alltraps
80106b3e:	e9 c1 f6 ff ff       	jmp    80106204 <alltraps>

80106b43 <vector63>:
.globl vector63
vector63:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $63
80106b45:	6a 3f                	push   $0x3f
  jmp alltraps
80106b47:	e9 b8 f6 ff ff       	jmp    80106204 <alltraps>

80106b4c <vector64>:
.globl vector64
vector64:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $64
80106b4e:	6a 40                	push   $0x40
  jmp alltraps
80106b50:	e9 af f6 ff ff       	jmp    80106204 <alltraps>

80106b55 <vector65>:
.globl vector65
vector65:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $65
80106b57:	6a 41                	push   $0x41
  jmp alltraps
80106b59:	e9 a6 f6 ff ff       	jmp    80106204 <alltraps>

80106b5e <vector66>:
.globl vector66
vector66:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $66
80106b60:	6a 42                	push   $0x42
  jmp alltraps
80106b62:	e9 9d f6 ff ff       	jmp    80106204 <alltraps>

80106b67 <vector67>:
.globl vector67
vector67:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $67
80106b69:	6a 43                	push   $0x43
  jmp alltraps
80106b6b:	e9 94 f6 ff ff       	jmp    80106204 <alltraps>

80106b70 <vector68>:
.globl vector68
vector68:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $68
80106b72:	6a 44                	push   $0x44
  jmp alltraps
80106b74:	e9 8b f6 ff ff       	jmp    80106204 <alltraps>

80106b79 <vector69>:
.globl vector69
vector69:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $69
80106b7b:	6a 45                	push   $0x45
  jmp alltraps
80106b7d:	e9 82 f6 ff ff       	jmp    80106204 <alltraps>

80106b82 <vector70>:
.globl vector70
vector70:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $70
80106b84:	6a 46                	push   $0x46
  jmp alltraps
80106b86:	e9 79 f6 ff ff       	jmp    80106204 <alltraps>

80106b8b <vector71>:
.globl vector71
vector71:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $71
80106b8d:	6a 47                	push   $0x47
  jmp alltraps
80106b8f:	e9 70 f6 ff ff       	jmp    80106204 <alltraps>

80106b94 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $72
80106b96:	6a 48                	push   $0x48
  jmp alltraps
80106b98:	e9 67 f6 ff ff       	jmp    80106204 <alltraps>

80106b9d <vector73>:
.globl vector73
vector73:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $73
80106b9f:	6a 49                	push   $0x49
  jmp alltraps
80106ba1:	e9 5e f6 ff ff       	jmp    80106204 <alltraps>

80106ba6 <vector74>:
.globl vector74
vector74:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $74
80106ba8:	6a 4a                	push   $0x4a
  jmp alltraps
80106baa:	e9 55 f6 ff ff       	jmp    80106204 <alltraps>

80106baf <vector75>:
.globl vector75
vector75:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $75
80106bb1:	6a 4b                	push   $0x4b
  jmp alltraps
80106bb3:	e9 4c f6 ff ff       	jmp    80106204 <alltraps>

80106bb8 <vector76>:
.globl vector76
vector76:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $76
80106bba:	6a 4c                	push   $0x4c
  jmp alltraps
80106bbc:	e9 43 f6 ff ff       	jmp    80106204 <alltraps>

80106bc1 <vector77>:
.globl vector77
vector77:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $77
80106bc3:	6a 4d                	push   $0x4d
  jmp alltraps
80106bc5:	e9 3a f6 ff ff       	jmp    80106204 <alltraps>

80106bca <vector78>:
.globl vector78
vector78:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $78
80106bcc:	6a 4e                	push   $0x4e
  jmp alltraps
80106bce:	e9 31 f6 ff ff       	jmp    80106204 <alltraps>

80106bd3 <vector79>:
.globl vector79
vector79:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $79
80106bd5:	6a 4f                	push   $0x4f
  jmp alltraps
80106bd7:	e9 28 f6 ff ff       	jmp    80106204 <alltraps>

80106bdc <vector80>:
.globl vector80
vector80:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $80
80106bde:	6a 50                	push   $0x50
  jmp alltraps
80106be0:	e9 1f f6 ff ff       	jmp    80106204 <alltraps>

80106be5 <vector81>:
.globl vector81
vector81:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $81
80106be7:	6a 51                	push   $0x51
  jmp alltraps
80106be9:	e9 16 f6 ff ff       	jmp    80106204 <alltraps>

80106bee <vector82>:
.globl vector82
vector82:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $82
80106bf0:	6a 52                	push   $0x52
  jmp alltraps
80106bf2:	e9 0d f6 ff ff       	jmp    80106204 <alltraps>

80106bf7 <vector83>:
.globl vector83
vector83:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $83
80106bf9:	6a 53                	push   $0x53
  jmp alltraps
80106bfb:	e9 04 f6 ff ff       	jmp    80106204 <alltraps>

80106c00 <vector84>:
.globl vector84
vector84:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $84
80106c02:	6a 54                	push   $0x54
  jmp alltraps
80106c04:	e9 fb f5 ff ff       	jmp    80106204 <alltraps>

80106c09 <vector85>:
.globl vector85
vector85:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $85
80106c0b:	6a 55                	push   $0x55
  jmp alltraps
80106c0d:	e9 f2 f5 ff ff       	jmp    80106204 <alltraps>

80106c12 <vector86>:
.globl vector86
vector86:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $86
80106c14:	6a 56                	push   $0x56
  jmp alltraps
80106c16:	e9 e9 f5 ff ff       	jmp    80106204 <alltraps>

80106c1b <vector87>:
.globl vector87
vector87:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $87
80106c1d:	6a 57                	push   $0x57
  jmp alltraps
80106c1f:	e9 e0 f5 ff ff       	jmp    80106204 <alltraps>

80106c24 <vector88>:
.globl vector88
vector88:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $88
80106c26:	6a 58                	push   $0x58
  jmp alltraps
80106c28:	e9 d7 f5 ff ff       	jmp    80106204 <alltraps>

80106c2d <vector89>:
.globl vector89
vector89:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $89
80106c2f:	6a 59                	push   $0x59
  jmp alltraps
80106c31:	e9 ce f5 ff ff       	jmp    80106204 <alltraps>

80106c36 <vector90>:
.globl vector90
vector90:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $90
80106c38:	6a 5a                	push   $0x5a
  jmp alltraps
80106c3a:	e9 c5 f5 ff ff       	jmp    80106204 <alltraps>

80106c3f <vector91>:
.globl vector91
vector91:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $91
80106c41:	6a 5b                	push   $0x5b
  jmp alltraps
80106c43:	e9 bc f5 ff ff       	jmp    80106204 <alltraps>

80106c48 <vector92>:
.globl vector92
vector92:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $92
80106c4a:	6a 5c                	push   $0x5c
  jmp alltraps
80106c4c:	e9 b3 f5 ff ff       	jmp    80106204 <alltraps>

80106c51 <vector93>:
.globl vector93
vector93:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $93
80106c53:	6a 5d                	push   $0x5d
  jmp alltraps
80106c55:	e9 aa f5 ff ff       	jmp    80106204 <alltraps>

80106c5a <vector94>:
.globl vector94
vector94:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $94
80106c5c:	6a 5e                	push   $0x5e
  jmp alltraps
80106c5e:	e9 a1 f5 ff ff       	jmp    80106204 <alltraps>

80106c63 <vector95>:
.globl vector95
vector95:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $95
80106c65:	6a 5f                	push   $0x5f
  jmp alltraps
80106c67:	e9 98 f5 ff ff       	jmp    80106204 <alltraps>

80106c6c <vector96>:
.globl vector96
vector96:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $96
80106c6e:	6a 60                	push   $0x60
  jmp alltraps
80106c70:	e9 8f f5 ff ff       	jmp    80106204 <alltraps>

80106c75 <vector97>:
.globl vector97
vector97:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $97
80106c77:	6a 61                	push   $0x61
  jmp alltraps
80106c79:	e9 86 f5 ff ff       	jmp    80106204 <alltraps>

80106c7e <vector98>:
.globl vector98
vector98:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $98
80106c80:	6a 62                	push   $0x62
  jmp alltraps
80106c82:	e9 7d f5 ff ff       	jmp    80106204 <alltraps>

80106c87 <vector99>:
.globl vector99
vector99:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $99
80106c89:	6a 63                	push   $0x63
  jmp alltraps
80106c8b:	e9 74 f5 ff ff       	jmp    80106204 <alltraps>

80106c90 <vector100>:
.globl vector100
vector100:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $100
80106c92:	6a 64                	push   $0x64
  jmp alltraps
80106c94:	e9 6b f5 ff ff       	jmp    80106204 <alltraps>

80106c99 <vector101>:
.globl vector101
vector101:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $101
80106c9b:	6a 65                	push   $0x65
  jmp alltraps
80106c9d:	e9 62 f5 ff ff       	jmp    80106204 <alltraps>

80106ca2 <vector102>:
.globl vector102
vector102:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $102
80106ca4:	6a 66                	push   $0x66
  jmp alltraps
80106ca6:	e9 59 f5 ff ff       	jmp    80106204 <alltraps>

80106cab <vector103>:
.globl vector103
vector103:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $103
80106cad:	6a 67                	push   $0x67
  jmp alltraps
80106caf:	e9 50 f5 ff ff       	jmp    80106204 <alltraps>

80106cb4 <vector104>:
.globl vector104
vector104:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $104
80106cb6:	6a 68                	push   $0x68
  jmp alltraps
80106cb8:	e9 47 f5 ff ff       	jmp    80106204 <alltraps>

80106cbd <vector105>:
.globl vector105
vector105:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $105
80106cbf:	6a 69                	push   $0x69
  jmp alltraps
80106cc1:	e9 3e f5 ff ff       	jmp    80106204 <alltraps>

80106cc6 <vector106>:
.globl vector106
vector106:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $106
80106cc8:	6a 6a                	push   $0x6a
  jmp alltraps
80106cca:	e9 35 f5 ff ff       	jmp    80106204 <alltraps>

80106ccf <vector107>:
.globl vector107
vector107:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $107
80106cd1:	6a 6b                	push   $0x6b
  jmp alltraps
80106cd3:	e9 2c f5 ff ff       	jmp    80106204 <alltraps>

80106cd8 <vector108>:
.globl vector108
vector108:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $108
80106cda:	6a 6c                	push   $0x6c
  jmp alltraps
80106cdc:	e9 23 f5 ff ff       	jmp    80106204 <alltraps>

80106ce1 <vector109>:
.globl vector109
vector109:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $109
80106ce3:	6a 6d                	push   $0x6d
  jmp alltraps
80106ce5:	e9 1a f5 ff ff       	jmp    80106204 <alltraps>

80106cea <vector110>:
.globl vector110
vector110:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $110
80106cec:	6a 6e                	push   $0x6e
  jmp alltraps
80106cee:	e9 11 f5 ff ff       	jmp    80106204 <alltraps>

80106cf3 <vector111>:
.globl vector111
vector111:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $111
80106cf5:	6a 6f                	push   $0x6f
  jmp alltraps
80106cf7:	e9 08 f5 ff ff       	jmp    80106204 <alltraps>

80106cfc <vector112>:
.globl vector112
vector112:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $112
80106cfe:	6a 70                	push   $0x70
  jmp alltraps
80106d00:	e9 ff f4 ff ff       	jmp    80106204 <alltraps>

80106d05 <vector113>:
.globl vector113
vector113:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $113
80106d07:	6a 71                	push   $0x71
  jmp alltraps
80106d09:	e9 f6 f4 ff ff       	jmp    80106204 <alltraps>

80106d0e <vector114>:
.globl vector114
vector114:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $114
80106d10:	6a 72                	push   $0x72
  jmp alltraps
80106d12:	e9 ed f4 ff ff       	jmp    80106204 <alltraps>

80106d17 <vector115>:
.globl vector115
vector115:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $115
80106d19:	6a 73                	push   $0x73
  jmp alltraps
80106d1b:	e9 e4 f4 ff ff       	jmp    80106204 <alltraps>

80106d20 <vector116>:
.globl vector116
vector116:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $116
80106d22:	6a 74                	push   $0x74
  jmp alltraps
80106d24:	e9 db f4 ff ff       	jmp    80106204 <alltraps>

80106d29 <vector117>:
.globl vector117
vector117:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $117
80106d2b:	6a 75                	push   $0x75
  jmp alltraps
80106d2d:	e9 d2 f4 ff ff       	jmp    80106204 <alltraps>

80106d32 <vector118>:
.globl vector118
vector118:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $118
80106d34:	6a 76                	push   $0x76
  jmp alltraps
80106d36:	e9 c9 f4 ff ff       	jmp    80106204 <alltraps>

80106d3b <vector119>:
.globl vector119
vector119:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $119
80106d3d:	6a 77                	push   $0x77
  jmp alltraps
80106d3f:	e9 c0 f4 ff ff       	jmp    80106204 <alltraps>

80106d44 <vector120>:
.globl vector120
vector120:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $120
80106d46:	6a 78                	push   $0x78
  jmp alltraps
80106d48:	e9 b7 f4 ff ff       	jmp    80106204 <alltraps>

80106d4d <vector121>:
.globl vector121
vector121:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $121
80106d4f:	6a 79                	push   $0x79
  jmp alltraps
80106d51:	e9 ae f4 ff ff       	jmp    80106204 <alltraps>

80106d56 <vector122>:
.globl vector122
vector122:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $122
80106d58:	6a 7a                	push   $0x7a
  jmp alltraps
80106d5a:	e9 a5 f4 ff ff       	jmp    80106204 <alltraps>

80106d5f <vector123>:
.globl vector123
vector123:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $123
80106d61:	6a 7b                	push   $0x7b
  jmp alltraps
80106d63:	e9 9c f4 ff ff       	jmp    80106204 <alltraps>

80106d68 <vector124>:
.globl vector124
vector124:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $124
80106d6a:	6a 7c                	push   $0x7c
  jmp alltraps
80106d6c:	e9 93 f4 ff ff       	jmp    80106204 <alltraps>

80106d71 <vector125>:
.globl vector125
vector125:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $125
80106d73:	6a 7d                	push   $0x7d
  jmp alltraps
80106d75:	e9 8a f4 ff ff       	jmp    80106204 <alltraps>

80106d7a <vector126>:
.globl vector126
vector126:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $126
80106d7c:	6a 7e                	push   $0x7e
  jmp alltraps
80106d7e:	e9 81 f4 ff ff       	jmp    80106204 <alltraps>

80106d83 <vector127>:
.globl vector127
vector127:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $127
80106d85:	6a 7f                	push   $0x7f
  jmp alltraps
80106d87:	e9 78 f4 ff ff       	jmp    80106204 <alltraps>

80106d8c <vector128>:
.globl vector128
vector128:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $128
80106d8e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d93:	e9 6c f4 ff ff       	jmp    80106204 <alltraps>

80106d98 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $129
80106d9a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d9f:	e9 60 f4 ff ff       	jmp    80106204 <alltraps>

80106da4 <vector130>:
.globl vector130
vector130:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $130
80106da6:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106dab:	e9 54 f4 ff ff       	jmp    80106204 <alltraps>

80106db0 <vector131>:
.globl vector131
vector131:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $131
80106db2:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106db7:	e9 48 f4 ff ff       	jmp    80106204 <alltraps>

80106dbc <vector132>:
.globl vector132
vector132:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $132
80106dbe:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106dc3:	e9 3c f4 ff ff       	jmp    80106204 <alltraps>

80106dc8 <vector133>:
.globl vector133
vector133:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $133
80106dca:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106dcf:	e9 30 f4 ff ff       	jmp    80106204 <alltraps>

80106dd4 <vector134>:
.globl vector134
vector134:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $134
80106dd6:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106ddb:	e9 24 f4 ff ff       	jmp    80106204 <alltraps>

80106de0 <vector135>:
.globl vector135
vector135:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $135
80106de2:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106de7:	e9 18 f4 ff ff       	jmp    80106204 <alltraps>

80106dec <vector136>:
.globl vector136
vector136:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $136
80106dee:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106df3:	e9 0c f4 ff ff       	jmp    80106204 <alltraps>

80106df8 <vector137>:
.globl vector137
vector137:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $137
80106dfa:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106dff:	e9 00 f4 ff ff       	jmp    80106204 <alltraps>

80106e04 <vector138>:
.globl vector138
vector138:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $138
80106e06:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106e0b:	e9 f4 f3 ff ff       	jmp    80106204 <alltraps>

80106e10 <vector139>:
.globl vector139
vector139:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $139
80106e12:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106e17:	e9 e8 f3 ff ff       	jmp    80106204 <alltraps>

80106e1c <vector140>:
.globl vector140
vector140:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $140
80106e1e:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106e23:	e9 dc f3 ff ff       	jmp    80106204 <alltraps>

80106e28 <vector141>:
.globl vector141
vector141:
  pushl $0
80106e28:	6a 00                	push   $0x0
  pushl $141
80106e2a:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106e2f:	e9 d0 f3 ff ff       	jmp    80106204 <alltraps>

80106e34 <vector142>:
.globl vector142
vector142:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $142
80106e36:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106e3b:	e9 c4 f3 ff ff       	jmp    80106204 <alltraps>

80106e40 <vector143>:
.globl vector143
vector143:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $143
80106e42:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106e47:	e9 b8 f3 ff ff       	jmp    80106204 <alltraps>

80106e4c <vector144>:
.globl vector144
vector144:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $144
80106e4e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106e53:	e9 ac f3 ff ff       	jmp    80106204 <alltraps>

80106e58 <vector145>:
.globl vector145
vector145:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $145
80106e5a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106e5f:	e9 a0 f3 ff ff       	jmp    80106204 <alltraps>

80106e64 <vector146>:
.globl vector146
vector146:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $146
80106e66:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106e6b:	e9 94 f3 ff ff       	jmp    80106204 <alltraps>

80106e70 <vector147>:
.globl vector147
vector147:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $147
80106e72:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e77:	e9 88 f3 ff ff       	jmp    80106204 <alltraps>

80106e7c <vector148>:
.globl vector148
vector148:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $148
80106e7e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e83:	e9 7c f3 ff ff       	jmp    80106204 <alltraps>

80106e88 <vector149>:
.globl vector149
vector149:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $149
80106e8a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e8f:	e9 70 f3 ff ff       	jmp    80106204 <alltraps>

80106e94 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $150
80106e96:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e9b:	e9 64 f3 ff ff       	jmp    80106204 <alltraps>

80106ea0 <vector151>:
.globl vector151
vector151:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $151
80106ea2:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106ea7:	e9 58 f3 ff ff       	jmp    80106204 <alltraps>

80106eac <vector152>:
.globl vector152
vector152:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $152
80106eae:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106eb3:	e9 4c f3 ff ff       	jmp    80106204 <alltraps>

80106eb8 <vector153>:
.globl vector153
vector153:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $153
80106eba:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106ebf:	e9 40 f3 ff ff       	jmp    80106204 <alltraps>

80106ec4 <vector154>:
.globl vector154
vector154:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $154
80106ec6:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106ecb:	e9 34 f3 ff ff       	jmp    80106204 <alltraps>

80106ed0 <vector155>:
.globl vector155
vector155:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $155
80106ed2:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106ed7:	e9 28 f3 ff ff       	jmp    80106204 <alltraps>

80106edc <vector156>:
.globl vector156
vector156:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $156
80106ede:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106ee3:	e9 1c f3 ff ff       	jmp    80106204 <alltraps>

80106ee8 <vector157>:
.globl vector157
vector157:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $157
80106eea:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106eef:	e9 10 f3 ff ff       	jmp    80106204 <alltraps>

80106ef4 <vector158>:
.globl vector158
vector158:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $158
80106ef6:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106efb:	e9 04 f3 ff ff       	jmp    80106204 <alltraps>

80106f00 <vector159>:
.globl vector159
vector159:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $159
80106f02:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106f07:	e9 f8 f2 ff ff       	jmp    80106204 <alltraps>

80106f0c <vector160>:
.globl vector160
vector160:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $160
80106f0e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106f13:	e9 ec f2 ff ff       	jmp    80106204 <alltraps>

80106f18 <vector161>:
.globl vector161
vector161:
  pushl $0
80106f18:	6a 00                	push   $0x0
  pushl $161
80106f1a:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106f1f:	e9 e0 f2 ff ff       	jmp    80106204 <alltraps>

80106f24 <vector162>:
.globl vector162
vector162:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $162
80106f26:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106f2b:	e9 d4 f2 ff ff       	jmp    80106204 <alltraps>

80106f30 <vector163>:
.globl vector163
vector163:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $163
80106f32:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106f37:	e9 c8 f2 ff ff       	jmp    80106204 <alltraps>

80106f3c <vector164>:
.globl vector164
vector164:
  pushl $0
80106f3c:	6a 00                	push   $0x0
  pushl $164
80106f3e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106f43:	e9 bc f2 ff ff       	jmp    80106204 <alltraps>

80106f48 <vector165>:
.globl vector165
vector165:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $165
80106f4a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106f4f:	e9 b0 f2 ff ff       	jmp    80106204 <alltraps>

80106f54 <vector166>:
.globl vector166
vector166:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $166
80106f56:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106f5b:	e9 a4 f2 ff ff       	jmp    80106204 <alltraps>

80106f60 <vector167>:
.globl vector167
vector167:
  pushl $0
80106f60:	6a 00                	push   $0x0
  pushl $167
80106f62:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106f67:	e9 98 f2 ff ff       	jmp    80106204 <alltraps>

80106f6c <vector168>:
.globl vector168
vector168:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $168
80106f6e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f73:	e9 8c f2 ff ff       	jmp    80106204 <alltraps>

80106f78 <vector169>:
.globl vector169
vector169:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $169
80106f7a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f7f:	e9 80 f2 ff ff       	jmp    80106204 <alltraps>

80106f84 <vector170>:
.globl vector170
vector170:
  pushl $0
80106f84:	6a 00                	push   $0x0
  pushl $170
80106f86:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f8b:	e9 74 f2 ff ff       	jmp    80106204 <alltraps>

80106f90 <vector171>:
.globl vector171
vector171:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $171
80106f92:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f97:	e9 68 f2 ff ff       	jmp    80106204 <alltraps>

80106f9c <vector172>:
.globl vector172
vector172:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $172
80106f9e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106fa3:	e9 5c f2 ff ff       	jmp    80106204 <alltraps>

80106fa8 <vector173>:
.globl vector173
vector173:
  pushl $0
80106fa8:	6a 00                	push   $0x0
  pushl $173
80106faa:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106faf:	e9 50 f2 ff ff       	jmp    80106204 <alltraps>

80106fb4 <vector174>:
.globl vector174
vector174:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $174
80106fb6:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106fbb:	e9 44 f2 ff ff       	jmp    80106204 <alltraps>

80106fc0 <vector175>:
.globl vector175
vector175:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $175
80106fc2:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106fc7:	e9 38 f2 ff ff       	jmp    80106204 <alltraps>

80106fcc <vector176>:
.globl vector176
vector176:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $176
80106fce:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106fd3:	e9 2c f2 ff ff       	jmp    80106204 <alltraps>

80106fd8 <vector177>:
.globl vector177
vector177:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $177
80106fda:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106fdf:	e9 20 f2 ff ff       	jmp    80106204 <alltraps>

80106fe4 <vector178>:
.globl vector178
vector178:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $178
80106fe6:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106feb:	e9 14 f2 ff ff       	jmp    80106204 <alltraps>

80106ff0 <vector179>:
.globl vector179
vector179:
  pushl $0
80106ff0:	6a 00                	push   $0x0
  pushl $179
80106ff2:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106ff7:	e9 08 f2 ff ff       	jmp    80106204 <alltraps>

80106ffc <vector180>:
.globl vector180
vector180:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $180
80106ffe:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107003:	e9 fc f1 ff ff       	jmp    80106204 <alltraps>

80107008 <vector181>:
.globl vector181
vector181:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $181
8010700a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010700f:	e9 f0 f1 ff ff       	jmp    80106204 <alltraps>

80107014 <vector182>:
.globl vector182
vector182:
  pushl $0
80107014:	6a 00                	push   $0x0
  pushl $182
80107016:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010701b:	e9 e4 f1 ff ff       	jmp    80106204 <alltraps>

80107020 <vector183>:
.globl vector183
vector183:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $183
80107022:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107027:	e9 d8 f1 ff ff       	jmp    80106204 <alltraps>

8010702c <vector184>:
.globl vector184
vector184:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $184
8010702e:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107033:	e9 cc f1 ff ff       	jmp    80106204 <alltraps>

80107038 <vector185>:
.globl vector185
vector185:
  pushl $0
80107038:	6a 00                	push   $0x0
  pushl $185
8010703a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010703f:	e9 c0 f1 ff ff       	jmp    80106204 <alltraps>

80107044 <vector186>:
.globl vector186
vector186:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $186
80107046:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010704b:	e9 b4 f1 ff ff       	jmp    80106204 <alltraps>

80107050 <vector187>:
.globl vector187
vector187:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $187
80107052:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107057:	e9 a8 f1 ff ff       	jmp    80106204 <alltraps>

8010705c <vector188>:
.globl vector188
vector188:
  pushl $0
8010705c:	6a 00                	push   $0x0
  pushl $188
8010705e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107063:	e9 9c f1 ff ff       	jmp    80106204 <alltraps>

80107068 <vector189>:
.globl vector189
vector189:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $189
8010706a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010706f:	e9 90 f1 ff ff       	jmp    80106204 <alltraps>

80107074 <vector190>:
.globl vector190
vector190:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $190
80107076:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010707b:	e9 84 f1 ff ff       	jmp    80106204 <alltraps>

80107080 <vector191>:
.globl vector191
vector191:
  pushl $0
80107080:	6a 00                	push   $0x0
  pushl $191
80107082:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107087:	e9 78 f1 ff ff       	jmp    80106204 <alltraps>

8010708c <vector192>:
.globl vector192
vector192:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $192
8010708e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107093:	e9 6c f1 ff ff       	jmp    80106204 <alltraps>

80107098 <vector193>:
.globl vector193
vector193:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $193
8010709a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010709f:	e9 60 f1 ff ff       	jmp    80106204 <alltraps>

801070a4 <vector194>:
.globl vector194
vector194:
  pushl $0
801070a4:	6a 00                	push   $0x0
  pushl $194
801070a6:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801070ab:	e9 54 f1 ff ff       	jmp    80106204 <alltraps>

801070b0 <vector195>:
.globl vector195
vector195:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $195
801070b2:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801070b7:	e9 48 f1 ff ff       	jmp    80106204 <alltraps>

801070bc <vector196>:
.globl vector196
vector196:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $196
801070be:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801070c3:	e9 3c f1 ff ff       	jmp    80106204 <alltraps>

801070c8 <vector197>:
.globl vector197
vector197:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $197
801070ca:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801070cf:	e9 30 f1 ff ff       	jmp    80106204 <alltraps>

801070d4 <vector198>:
.globl vector198
vector198:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $198
801070d6:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801070db:	e9 24 f1 ff ff       	jmp    80106204 <alltraps>

801070e0 <vector199>:
.globl vector199
vector199:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $199
801070e2:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801070e7:	e9 18 f1 ff ff       	jmp    80106204 <alltraps>

801070ec <vector200>:
.globl vector200
vector200:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $200
801070ee:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801070f3:	e9 0c f1 ff ff       	jmp    80106204 <alltraps>

801070f8 <vector201>:
.globl vector201
vector201:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $201
801070fa:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801070ff:	e9 00 f1 ff ff       	jmp    80106204 <alltraps>

80107104 <vector202>:
.globl vector202
vector202:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $202
80107106:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010710b:	e9 f4 f0 ff ff       	jmp    80106204 <alltraps>

80107110 <vector203>:
.globl vector203
vector203:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $203
80107112:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107117:	e9 e8 f0 ff ff       	jmp    80106204 <alltraps>

8010711c <vector204>:
.globl vector204
vector204:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $204
8010711e:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107123:	e9 dc f0 ff ff       	jmp    80106204 <alltraps>

80107128 <vector205>:
.globl vector205
vector205:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $205
8010712a:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010712f:	e9 d0 f0 ff ff       	jmp    80106204 <alltraps>

80107134 <vector206>:
.globl vector206
vector206:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $206
80107136:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010713b:	e9 c4 f0 ff ff       	jmp    80106204 <alltraps>

80107140 <vector207>:
.globl vector207
vector207:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $207
80107142:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107147:	e9 b8 f0 ff ff       	jmp    80106204 <alltraps>

8010714c <vector208>:
.globl vector208
vector208:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $208
8010714e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107153:	e9 ac f0 ff ff       	jmp    80106204 <alltraps>

80107158 <vector209>:
.globl vector209
vector209:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $209
8010715a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010715f:	e9 a0 f0 ff ff       	jmp    80106204 <alltraps>

80107164 <vector210>:
.globl vector210
vector210:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $210
80107166:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010716b:	e9 94 f0 ff ff       	jmp    80106204 <alltraps>

80107170 <vector211>:
.globl vector211
vector211:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $211
80107172:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107177:	e9 88 f0 ff ff       	jmp    80106204 <alltraps>

8010717c <vector212>:
.globl vector212
vector212:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $212
8010717e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107183:	e9 7c f0 ff ff       	jmp    80106204 <alltraps>

80107188 <vector213>:
.globl vector213
vector213:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $213
8010718a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010718f:	e9 70 f0 ff ff       	jmp    80106204 <alltraps>

80107194 <vector214>:
.globl vector214
vector214:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $214
80107196:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010719b:	e9 64 f0 ff ff       	jmp    80106204 <alltraps>

801071a0 <vector215>:
.globl vector215
vector215:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $215
801071a2:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801071a7:	e9 58 f0 ff ff       	jmp    80106204 <alltraps>

801071ac <vector216>:
.globl vector216
vector216:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $216
801071ae:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801071b3:	e9 4c f0 ff ff       	jmp    80106204 <alltraps>

801071b8 <vector217>:
.globl vector217
vector217:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $217
801071ba:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801071bf:	e9 40 f0 ff ff       	jmp    80106204 <alltraps>

801071c4 <vector218>:
.globl vector218
vector218:
  pushl $0
801071c4:	6a 00                	push   $0x0
  pushl $218
801071c6:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801071cb:	e9 34 f0 ff ff       	jmp    80106204 <alltraps>

801071d0 <vector219>:
.globl vector219
vector219:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $219
801071d2:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801071d7:	e9 28 f0 ff ff       	jmp    80106204 <alltraps>

801071dc <vector220>:
.globl vector220
vector220:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $220
801071de:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801071e3:	e9 1c f0 ff ff       	jmp    80106204 <alltraps>

801071e8 <vector221>:
.globl vector221
vector221:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $221
801071ea:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801071ef:	e9 10 f0 ff ff       	jmp    80106204 <alltraps>

801071f4 <vector222>:
.globl vector222
vector222:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $222
801071f6:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801071fb:	e9 04 f0 ff ff       	jmp    80106204 <alltraps>

80107200 <vector223>:
.globl vector223
vector223:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $223
80107202:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107207:	e9 f8 ef ff ff       	jmp    80106204 <alltraps>

8010720c <vector224>:
.globl vector224
vector224:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $224
8010720e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107213:	e9 ec ef ff ff       	jmp    80106204 <alltraps>

80107218 <vector225>:
.globl vector225
vector225:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $225
8010721a:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010721f:	e9 e0 ef ff ff       	jmp    80106204 <alltraps>

80107224 <vector226>:
.globl vector226
vector226:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $226
80107226:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010722b:	e9 d4 ef ff ff       	jmp    80106204 <alltraps>

80107230 <vector227>:
.globl vector227
vector227:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $227
80107232:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107237:	e9 c8 ef ff ff       	jmp    80106204 <alltraps>

8010723c <vector228>:
.globl vector228
vector228:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $228
8010723e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107243:	e9 bc ef ff ff       	jmp    80106204 <alltraps>

80107248 <vector229>:
.globl vector229
vector229:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $229
8010724a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010724f:	e9 b0 ef ff ff       	jmp    80106204 <alltraps>

80107254 <vector230>:
.globl vector230
vector230:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $230
80107256:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010725b:	e9 a4 ef ff ff       	jmp    80106204 <alltraps>

80107260 <vector231>:
.globl vector231
vector231:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $231
80107262:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107267:	e9 98 ef ff ff       	jmp    80106204 <alltraps>

8010726c <vector232>:
.globl vector232
vector232:
  pushl $0
8010726c:	6a 00                	push   $0x0
  pushl $232
8010726e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107273:	e9 8c ef ff ff       	jmp    80106204 <alltraps>

80107278 <vector233>:
.globl vector233
vector233:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $233
8010727a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010727f:	e9 80 ef ff ff       	jmp    80106204 <alltraps>

80107284 <vector234>:
.globl vector234
vector234:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $234
80107286:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010728b:	e9 74 ef ff ff       	jmp    80106204 <alltraps>

80107290 <vector235>:
.globl vector235
vector235:
  pushl $0
80107290:	6a 00                	push   $0x0
  pushl $235
80107292:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107297:	e9 68 ef ff ff       	jmp    80106204 <alltraps>

8010729c <vector236>:
.globl vector236
vector236:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $236
8010729e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801072a3:	e9 5c ef ff ff       	jmp    80106204 <alltraps>

801072a8 <vector237>:
.globl vector237
vector237:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $237
801072aa:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801072af:	e9 50 ef ff ff       	jmp    80106204 <alltraps>

801072b4 <vector238>:
.globl vector238
vector238:
  pushl $0
801072b4:	6a 00                	push   $0x0
  pushl $238
801072b6:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801072bb:	e9 44 ef ff ff       	jmp    80106204 <alltraps>

801072c0 <vector239>:
.globl vector239
vector239:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $239
801072c2:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801072c7:	e9 38 ef ff ff       	jmp    80106204 <alltraps>

801072cc <vector240>:
.globl vector240
vector240:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $240
801072ce:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801072d3:	e9 2c ef ff ff       	jmp    80106204 <alltraps>

801072d8 <vector241>:
.globl vector241
vector241:
  pushl $0
801072d8:	6a 00                	push   $0x0
  pushl $241
801072da:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801072df:	e9 20 ef ff ff       	jmp    80106204 <alltraps>

801072e4 <vector242>:
.globl vector242
vector242:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $242
801072e6:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801072eb:	e9 14 ef ff ff       	jmp    80106204 <alltraps>

801072f0 <vector243>:
.globl vector243
vector243:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $243
801072f2:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801072f7:	e9 08 ef ff ff       	jmp    80106204 <alltraps>

801072fc <vector244>:
.globl vector244
vector244:
  pushl $0
801072fc:	6a 00                	push   $0x0
  pushl $244
801072fe:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107303:	e9 fc ee ff ff       	jmp    80106204 <alltraps>

80107308 <vector245>:
.globl vector245
vector245:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $245
8010730a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010730f:	e9 f0 ee ff ff       	jmp    80106204 <alltraps>

80107314 <vector246>:
.globl vector246
vector246:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $246
80107316:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010731b:	e9 e4 ee ff ff       	jmp    80106204 <alltraps>

80107320 <vector247>:
.globl vector247
vector247:
  pushl $0
80107320:	6a 00                	push   $0x0
  pushl $247
80107322:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107327:	e9 d8 ee ff ff       	jmp    80106204 <alltraps>

8010732c <vector248>:
.globl vector248
vector248:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $248
8010732e:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107333:	e9 cc ee ff ff       	jmp    80106204 <alltraps>

80107338 <vector249>:
.globl vector249
vector249:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $249
8010733a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010733f:	e9 c0 ee ff ff       	jmp    80106204 <alltraps>

80107344 <vector250>:
.globl vector250
vector250:
  pushl $0
80107344:	6a 00                	push   $0x0
  pushl $250
80107346:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010734b:	e9 b4 ee ff ff       	jmp    80106204 <alltraps>

80107350 <vector251>:
.globl vector251
vector251:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $251
80107352:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107357:	e9 a8 ee ff ff       	jmp    80106204 <alltraps>

8010735c <vector252>:
.globl vector252
vector252:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $252
8010735e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107363:	e9 9c ee ff ff       	jmp    80106204 <alltraps>

80107368 <vector253>:
.globl vector253
vector253:
  pushl $0
80107368:	6a 00                	push   $0x0
  pushl $253
8010736a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010736f:	e9 90 ee ff ff       	jmp    80106204 <alltraps>

80107374 <vector254>:
.globl vector254
vector254:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $254
80107376:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010737b:	e9 84 ee ff ff       	jmp    80106204 <alltraps>

80107380 <vector255>:
.globl vector255
vector255:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $255
80107382:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107387:	e9 78 ee ff ff       	jmp    80106204 <alltraps>

8010738c <lgdt>:
{
8010738c:	55                   	push   %ebp
8010738d:	89 e5                	mov    %esp,%ebp
8010738f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107392:	8b 45 0c             	mov    0xc(%ebp),%eax
80107395:	83 e8 01             	sub    $0x1,%eax
80107398:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010739c:	8b 45 08             	mov    0x8(%ebp),%eax
8010739f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801073a3:	8b 45 08             	mov    0x8(%ebp),%eax
801073a6:	c1 e8 10             	shr    $0x10,%eax
801073a9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801073ad:	8d 45 fa             	lea    -0x6(%ebp),%eax
801073b0:	0f 01 10             	lgdtl  (%eax)
}
801073b3:	90                   	nop
801073b4:	c9                   	leave  
801073b5:	c3                   	ret    

801073b6 <ltr>:
{
801073b6:	55                   	push   %ebp
801073b7:	89 e5                	mov    %esp,%ebp
801073b9:	83 ec 04             	sub    $0x4,%esp
801073bc:	8b 45 08             	mov    0x8(%ebp),%eax
801073bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801073c3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801073c7:	0f 00 d8             	ltr    %ax
}
801073ca:	90                   	nop
801073cb:	c9                   	leave  
801073cc:	c3                   	ret    

801073cd <lcr3>:

static inline void
lcr3(uint val)
{
801073cd:	55                   	push   %ebp
801073ce:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801073d0:	8b 45 08             	mov    0x8(%ebp),%eax
801073d3:	0f 22 d8             	mov    %eax,%cr3
}
801073d6:	90                   	nop
801073d7:	5d                   	pop    %ebp
801073d8:	c3                   	ret    

801073d9 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801073d9:	55                   	push   %ebp
801073da:	89 e5                	mov    %esp,%ebp
801073dc:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801073df:	e8 b9 c5 ff ff       	call   8010399d <cpuid>
801073e4:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801073ea:	05 80 72 19 80       	add    $0x80197280,%eax
801073ef:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801073f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f5:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801073fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fe:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107407:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010740b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107412:	83 e2 f0             	and    $0xfffffff0,%edx
80107415:	83 ca 0a             	or     $0xa,%edx
80107418:	88 50 7d             	mov    %dl,0x7d(%eax)
8010741b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107422:	83 ca 10             	or     $0x10,%edx
80107425:	88 50 7d             	mov    %dl,0x7d(%eax)
80107428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010742f:	83 e2 9f             	and    $0xffffff9f,%edx
80107432:	88 50 7d             	mov    %dl,0x7d(%eax)
80107435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107438:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010743c:	83 ca 80             	or     $0xffffff80,%edx
8010743f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107445:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107449:	83 ca 0f             	or     $0xf,%edx
8010744c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010744f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107452:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107456:	83 e2 ef             	and    $0xffffffef,%edx
80107459:	88 50 7e             	mov    %dl,0x7e(%eax)
8010745c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107463:	83 e2 df             	and    $0xffffffdf,%edx
80107466:	88 50 7e             	mov    %dl,0x7e(%eax)
80107469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107470:	83 ca 40             	or     $0x40,%edx
80107473:	88 50 7e             	mov    %dl,0x7e(%eax)
80107476:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107479:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010747d:	83 ca 80             	or     $0xffffff80,%edx
80107480:	88 50 7e             	mov    %dl,0x7e(%eax)
80107483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107486:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010748a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107494:	ff ff 
80107496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107499:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801074a0:	00 00 
801074a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a5:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801074ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074af:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074b6:	83 e2 f0             	and    $0xfffffff0,%edx
801074b9:	83 ca 02             	or     $0x2,%edx
801074bc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074cc:	83 ca 10             	or     $0x10,%edx
801074cf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074df:	83 e2 9f             	and    $0xffffff9f,%edx
801074e2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074eb:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074f2:	83 ca 80             	or     $0xffffff80,%edx
801074f5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fe:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107505:	83 ca 0f             	or     $0xf,%edx
80107508:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010750e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107511:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107518:	83 e2 ef             	and    $0xffffffef,%edx
8010751b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107524:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010752b:	83 e2 df             	and    $0xffffffdf,%edx
8010752e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107537:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010753e:	83 ca 40             	or     $0x40,%edx
80107541:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107551:	83 ca 80             	or     $0xffffff80,%edx
80107554:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010755a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755d:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107567:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010756e:	ff ff 
80107570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107573:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010757a:	00 00 
8010757c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757f:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107589:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107590:	83 e2 f0             	and    $0xfffffff0,%edx
80107593:	83 ca 0a             	or     $0xa,%edx
80107596:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010759c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801075a6:	83 ca 10             	or     $0x10,%edx
801075a9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801075af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801075b9:	83 ca 60             	or     $0x60,%edx
801075bc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801075c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801075cc:	83 ca 80             	or     $0xffffff80,%edx
801075cf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801075d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075df:	83 ca 0f             	or     $0xf,%edx
801075e2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075eb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075f2:	83 e2 ef             	and    $0xffffffef,%edx
801075f5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fe:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107605:	83 e2 df             	and    $0xffffffdf,%edx
80107608:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010760e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107611:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107618:	83 ca 40             	or     $0x40,%edx
8010761b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107624:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010762b:	83 ca 80             	or     $0xffffff80,%edx
8010762e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107637:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010763e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107641:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107648:	ff ff 
8010764a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764d:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107654:	00 00 
80107656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107659:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107663:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010766a:	83 e2 f0             	and    $0xfffffff0,%edx
8010766d:	83 ca 02             	or     $0x2,%edx
80107670:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107679:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107680:	83 ca 10             	or     $0x10,%edx
80107683:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107693:	83 ca 60             	or     $0x60,%edx
80107696:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010769c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801076a6:	83 ca 80             	or     $0xffffff80,%edx
801076a9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801076af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076b9:	83 ca 0f             	or     $0xf,%edx
801076bc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076cc:	83 e2 ef             	and    $0xffffffef,%edx
801076cf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076df:	83 e2 df             	and    $0xffffffdf,%edx
801076e2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076eb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076f2:	83 ca 40             	or     $0x40,%edx
801076f5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fe:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107705:	83 ca 80             	or     $0xffffff80,%edx
80107708:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010770e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107711:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771b:	83 c0 70             	add    $0x70,%eax
8010771e:	83 ec 08             	sub    $0x8,%esp
80107721:	6a 30                	push   $0x30
80107723:	50                   	push   %eax
80107724:	e8 63 fc ff ff       	call   8010738c <lgdt>
80107729:	83 c4 10             	add    $0x10,%esp
}
8010772c:	90                   	nop
8010772d:	c9                   	leave  
8010772e:	c3                   	ret    

8010772f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010772f:	55                   	push   %ebp
80107730:	89 e5                	mov    %esp,%ebp
80107732:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107735:	8b 45 0c             	mov    0xc(%ebp),%eax
80107738:	c1 e8 16             	shr    $0x16,%eax
8010773b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107742:	8b 45 08             	mov    0x8(%ebp),%eax
80107745:	01 d0                	add    %edx,%eax
80107747:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010774a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010774d:	8b 00                	mov    (%eax),%eax
8010774f:	83 e0 01             	and    $0x1,%eax
80107752:	85 c0                	test   %eax,%eax
80107754:	74 14                	je     8010776a <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107756:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107759:	8b 00                	mov    (%eax),%eax
8010775b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107760:	05 00 00 00 80       	add    $0x80000000,%eax
80107765:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107768:	eb 42                	jmp    801077ac <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010776a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010776e:	74 0e                	je     8010777e <walkpgdir+0x4f>
80107770:	e8 2b b0 ff ff       	call   801027a0 <kalloc>
80107775:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107778:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010777c:	75 07                	jne    80107785 <walkpgdir+0x56>
      return 0;
8010777e:	b8 00 00 00 00       	mov    $0x0,%eax
80107783:	eb 3e                	jmp    801077c3 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107785:	83 ec 04             	sub    $0x4,%esp
80107788:	68 00 10 00 00       	push   $0x1000
8010778d:	6a 00                	push   $0x0
8010778f:	ff 75 f4             	push   -0xc(%ebp)
80107792:	e8 7f d6 ff ff       	call   80104e16 <memset>
80107797:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010779a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779d:	05 00 00 00 80       	add    $0x80000000,%eax
801077a2:	83 c8 07             	or     $0x7,%eax
801077a5:	89 c2                	mov    %eax,%edx
801077a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077aa:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801077ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801077af:	c1 e8 0c             	shr    $0xc,%eax
801077b2:	25 ff 03 00 00       	and    $0x3ff,%eax
801077b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801077be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c1:	01 d0                	add    %edx,%eax
}
801077c3:	c9                   	leave  
801077c4:	c3                   	ret    

801077c5 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801077c5:	55                   	push   %ebp
801077c6:	89 e5                	mov    %esp,%ebp
801077c8:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801077cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801077ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801077d6:	8b 55 0c             	mov    0xc(%ebp),%edx
801077d9:	8b 45 10             	mov    0x10(%ebp),%eax
801077dc:	01 d0                	add    %edx,%eax
801077de:	83 e8 01             	sub    $0x1,%eax
801077e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077e9:	83 ec 04             	sub    $0x4,%esp
801077ec:	6a 01                	push   $0x1
801077ee:	ff 75 f4             	push   -0xc(%ebp)
801077f1:	ff 75 08             	push   0x8(%ebp)
801077f4:	e8 36 ff ff ff       	call   8010772f <walkpgdir>
801077f9:	83 c4 10             	add    $0x10,%esp
801077fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801077ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107803:	75 07                	jne    8010780c <mappages+0x47>
      return -1;
80107805:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010780a:	eb 47                	jmp    80107853 <mappages+0x8e>
    if(*pte & PTE_P)
8010780c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010780f:	8b 00                	mov    (%eax),%eax
80107811:	83 e0 01             	and    $0x1,%eax
80107814:	85 c0                	test   %eax,%eax
80107816:	74 0d                	je     80107825 <mappages+0x60>
      panic("remap");
80107818:	83 ec 0c             	sub    $0xc,%esp
8010781b:	68 88 ab 10 80       	push   $0x8010ab88
80107820:	e8 84 8d ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107825:	8b 45 18             	mov    0x18(%ebp),%eax
80107828:	0b 45 14             	or     0x14(%ebp),%eax
8010782b:	83 c8 01             	or     $0x1,%eax
8010782e:	89 c2                	mov    %eax,%edx
80107830:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107833:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107838:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010783b:	74 10                	je     8010784d <mappages+0x88>
      break;
    a += PGSIZE;
8010783d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107844:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010784b:	eb 9c                	jmp    801077e9 <mappages+0x24>
      break;
8010784d:	90                   	nop
  }
  return 0;
8010784e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107853:	c9                   	leave  
80107854:	c3                   	ret    

80107855 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107855:	55                   	push   %ebp
80107856:	89 e5                	mov    %esp,%ebp
80107858:	53                   	push   %ebx
80107859:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010785c:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107863:	8b 15 60 75 19 80    	mov    0x80197560,%edx
80107869:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010786e:	29 d0                	sub    %edx,%eax
80107870:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107873:	a1 58 75 19 80       	mov    0x80197558,%eax
80107878:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010787b:	8b 15 58 75 19 80    	mov    0x80197558,%edx
80107881:	a1 60 75 19 80       	mov    0x80197560,%eax
80107886:	01 d0                	add    %edx,%eax
80107888:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010788b:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107895:	83 c0 30             	add    $0x30,%eax
80107898:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010789b:	89 10                	mov    %edx,(%eax)
8010789d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801078a0:	89 50 04             	mov    %edx,0x4(%eax)
801078a3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801078a6:	89 50 08             	mov    %edx,0x8(%eax)
801078a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801078ac:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801078af:	e8 ec ae ff ff       	call   801027a0 <kalloc>
801078b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078bb:	75 07                	jne    801078c4 <setupkvm+0x6f>
    return 0;
801078bd:	b8 00 00 00 00       	mov    $0x0,%eax
801078c2:	eb 78                	jmp    8010793c <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
801078c4:	83 ec 04             	sub    $0x4,%esp
801078c7:	68 00 10 00 00       	push   $0x1000
801078cc:	6a 00                	push   $0x0
801078ce:	ff 75 f0             	push   -0x10(%ebp)
801078d1:	e8 40 d5 ff ff       	call   80104e16 <memset>
801078d6:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078d9:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801078e0:	eb 4e                	jmp    80107930 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801078e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e5:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801078e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078eb:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801078ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f1:	8b 58 08             	mov    0x8(%eax),%ebx
801078f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f7:	8b 40 04             	mov    0x4(%eax),%eax
801078fa:	29 c3                	sub    %eax,%ebx
801078fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ff:	8b 00                	mov    (%eax),%eax
80107901:	83 ec 0c             	sub    $0xc,%esp
80107904:	51                   	push   %ecx
80107905:	52                   	push   %edx
80107906:	53                   	push   %ebx
80107907:	50                   	push   %eax
80107908:	ff 75 f0             	push   -0x10(%ebp)
8010790b:	e8 b5 fe ff ff       	call   801077c5 <mappages>
80107910:	83 c4 20             	add    $0x20,%esp
80107913:	85 c0                	test   %eax,%eax
80107915:	79 15                	jns    8010792c <setupkvm+0xd7>
      freevm(pgdir);
80107917:	83 ec 0c             	sub    $0xc,%esp
8010791a:	ff 75 f0             	push   -0x10(%ebp)
8010791d:	e8 f5 04 00 00       	call   80107e17 <freevm>
80107922:	83 c4 10             	add    $0x10,%esp
      return 0;
80107925:	b8 00 00 00 00       	mov    $0x0,%eax
8010792a:	eb 10                	jmp    8010793c <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010792c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107930:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107937:	72 a9                	jb     801078e2 <setupkvm+0x8d>
    }
  return pgdir;
80107939:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010793c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010793f:	c9                   	leave  
80107940:	c3                   	ret    

80107941 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107941:	55                   	push   %ebp
80107942:	89 e5                	mov    %esp,%ebp
80107944:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107947:	e8 09 ff ff ff       	call   80107855 <setupkvm>
8010794c:	a3 7c 72 19 80       	mov    %eax,0x8019727c
  switchkvm();
80107951:	e8 03 00 00 00       	call   80107959 <switchkvm>
}
80107956:	90                   	nop
80107957:	c9                   	leave  
80107958:	c3                   	ret    

80107959 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107959:	55                   	push   %ebp
8010795a:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010795c:	a1 7c 72 19 80       	mov    0x8019727c,%eax
80107961:	05 00 00 00 80       	add    $0x80000000,%eax
80107966:	50                   	push   %eax
80107967:	e8 61 fa ff ff       	call   801073cd <lcr3>
8010796c:	83 c4 04             	add    $0x4,%esp
}
8010796f:	90                   	nop
80107970:	c9                   	leave  
80107971:	c3                   	ret    

80107972 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107972:	55                   	push   %ebp
80107973:	89 e5                	mov    %esp,%ebp
80107975:	56                   	push   %esi
80107976:	53                   	push   %ebx
80107977:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010797a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010797e:	75 0d                	jne    8010798d <switchuvm+0x1b>
    panic("switchuvm: no process");
80107980:	83 ec 0c             	sub    $0xc,%esp
80107983:	68 8e ab 10 80       	push   $0x8010ab8e
80107988:	e8 1c 8c ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010798d:	8b 45 08             	mov    0x8(%ebp),%eax
80107990:	8b 40 08             	mov    0x8(%eax),%eax
80107993:	85 c0                	test   %eax,%eax
80107995:	75 0d                	jne    801079a4 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107997:	83 ec 0c             	sub    $0xc,%esp
8010799a:	68 a4 ab 10 80       	push   $0x8010aba4
8010799f:	e8 05 8c ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
801079a4:	8b 45 08             	mov    0x8(%ebp),%eax
801079a7:	8b 40 04             	mov    0x4(%eax),%eax
801079aa:	85 c0                	test   %eax,%eax
801079ac:	75 0d                	jne    801079bb <switchuvm+0x49>
    panic("switchuvm: no pgdir");
801079ae:	83 ec 0c             	sub    $0xc,%esp
801079b1:	68 b9 ab 10 80       	push   $0x8010abb9
801079b6:	e8 ee 8b ff ff       	call   801005a9 <panic>

  pushcli();
801079bb:	e8 4b d3 ff ff       	call   80104d0b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801079c0:	e8 f3 bf ff ff       	call   801039b8 <mycpu>
801079c5:	89 c3                	mov    %eax,%ebx
801079c7:	e8 ec bf ff ff       	call   801039b8 <mycpu>
801079cc:	83 c0 08             	add    $0x8,%eax
801079cf:	89 c6                	mov    %eax,%esi
801079d1:	e8 e2 bf ff ff       	call   801039b8 <mycpu>
801079d6:	83 c0 08             	add    $0x8,%eax
801079d9:	c1 e8 10             	shr    $0x10,%eax
801079dc:	88 45 f7             	mov    %al,-0x9(%ebp)
801079df:	e8 d4 bf ff ff       	call   801039b8 <mycpu>
801079e4:	83 c0 08             	add    $0x8,%eax
801079e7:	c1 e8 18             	shr    $0x18,%eax
801079ea:	89 c2                	mov    %eax,%edx
801079ec:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801079f3:	67 00 
801079f5:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801079fc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107a00:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107a06:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a0d:	83 e0 f0             	and    $0xfffffff0,%eax
80107a10:	83 c8 09             	or     $0x9,%eax
80107a13:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a19:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a20:	83 c8 10             	or     $0x10,%eax
80107a23:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a29:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a30:	83 e0 9f             	and    $0xffffff9f,%eax
80107a33:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a39:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a40:	83 c8 80             	or     $0xffffff80,%eax
80107a43:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a49:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a50:	83 e0 f0             	and    $0xfffffff0,%eax
80107a53:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a59:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a60:	83 e0 ef             	and    $0xffffffef,%eax
80107a63:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a69:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a70:	83 e0 df             	and    $0xffffffdf,%eax
80107a73:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a79:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a80:	83 c8 40             	or     $0x40,%eax
80107a83:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a89:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a90:	83 e0 7f             	and    $0x7f,%eax
80107a93:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a99:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a9f:	e8 14 bf ff ff       	call   801039b8 <mycpu>
80107aa4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107aab:	83 e2 ef             	and    $0xffffffef,%edx
80107aae:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107ab4:	e8 ff be ff ff       	call   801039b8 <mycpu>
80107ab9:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107abf:	8b 45 08             	mov    0x8(%ebp),%eax
80107ac2:	8b 40 08             	mov    0x8(%eax),%eax
80107ac5:	89 c3                	mov    %eax,%ebx
80107ac7:	e8 ec be ff ff       	call   801039b8 <mycpu>
80107acc:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107ad2:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107ad5:	e8 de be ff ff       	call   801039b8 <mycpu>
80107ada:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107ae0:	83 ec 0c             	sub    $0xc,%esp
80107ae3:	6a 28                	push   $0x28
80107ae5:	e8 cc f8 ff ff       	call   801073b6 <ltr>
80107aea:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107aed:	8b 45 08             	mov    0x8(%ebp),%eax
80107af0:	8b 40 04             	mov    0x4(%eax),%eax
80107af3:	05 00 00 00 80       	add    $0x80000000,%eax
80107af8:	83 ec 0c             	sub    $0xc,%esp
80107afb:	50                   	push   %eax
80107afc:	e8 cc f8 ff ff       	call   801073cd <lcr3>
80107b01:	83 c4 10             	add    $0x10,%esp
  popcli();
80107b04:	e8 4f d2 ff ff       	call   80104d58 <popcli>
}
80107b09:	90                   	nop
80107b0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107b0d:	5b                   	pop    %ebx
80107b0e:	5e                   	pop    %esi
80107b0f:	5d                   	pop    %ebp
80107b10:	c3                   	ret    

80107b11 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107b11:	55                   	push   %ebp
80107b12:	89 e5                	mov    %esp,%ebp
80107b14:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107b17:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107b1e:	76 0d                	jbe    80107b2d <inituvm+0x1c>
    panic("inituvm: more than a page");
80107b20:	83 ec 0c             	sub    $0xc,%esp
80107b23:	68 cd ab 10 80       	push   $0x8010abcd
80107b28:	e8 7c 8a ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107b2d:	e8 6e ac ff ff       	call   801027a0 <kalloc>
80107b32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107b35:	83 ec 04             	sub    $0x4,%esp
80107b38:	68 00 10 00 00       	push   $0x1000
80107b3d:	6a 00                	push   $0x0
80107b3f:	ff 75 f4             	push   -0xc(%ebp)
80107b42:	e8 cf d2 ff ff       	call   80104e16 <memset>
80107b47:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4d:	05 00 00 00 80       	add    $0x80000000,%eax
80107b52:	83 ec 0c             	sub    $0xc,%esp
80107b55:	6a 06                	push   $0x6
80107b57:	50                   	push   %eax
80107b58:	68 00 10 00 00       	push   $0x1000
80107b5d:	6a 00                	push   $0x0
80107b5f:	ff 75 08             	push   0x8(%ebp)
80107b62:	e8 5e fc ff ff       	call   801077c5 <mappages>
80107b67:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107b6a:	83 ec 04             	sub    $0x4,%esp
80107b6d:	ff 75 10             	push   0x10(%ebp)
80107b70:	ff 75 0c             	push   0xc(%ebp)
80107b73:	ff 75 f4             	push   -0xc(%ebp)
80107b76:	e8 5a d3 ff ff       	call   80104ed5 <memmove>
80107b7b:	83 c4 10             	add    $0x10,%esp
}
80107b7e:	90                   	nop
80107b7f:	c9                   	leave  
80107b80:	c3                   	ret    

80107b81 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b81:	55                   	push   %ebp
80107b82:	89 e5                	mov    %esp,%ebp
80107b84:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b87:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b8a:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b8f:	85 c0                	test   %eax,%eax
80107b91:	74 0d                	je     80107ba0 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107b93:	83 ec 0c             	sub    $0xc,%esp
80107b96:	68 e8 ab 10 80       	push   $0x8010abe8
80107b9b:	e8 09 8a ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107ba0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ba7:	e9 8f 00 00 00       	jmp    80107c3b <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107bac:	8b 55 0c             	mov    0xc(%ebp),%edx
80107baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb2:	01 d0                	add    %edx,%eax
80107bb4:	83 ec 04             	sub    $0x4,%esp
80107bb7:	6a 00                	push   $0x0
80107bb9:	50                   	push   %eax
80107bba:	ff 75 08             	push   0x8(%ebp)
80107bbd:	e8 6d fb ff ff       	call   8010772f <walkpgdir>
80107bc2:	83 c4 10             	add    $0x10,%esp
80107bc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107bc8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bcc:	75 0d                	jne    80107bdb <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107bce:	83 ec 0c             	sub    $0xc,%esp
80107bd1:	68 0b ac 10 80       	push   $0x8010ac0b
80107bd6:	e8 ce 89 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107bdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bde:	8b 00                	mov    (%eax),%eax
80107be0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107be5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107be8:	8b 45 18             	mov    0x18(%ebp),%eax
80107beb:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107bee:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107bf3:	77 0b                	ja     80107c00 <loaduvm+0x7f>
      n = sz - i;
80107bf5:	8b 45 18             	mov    0x18(%ebp),%eax
80107bf8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bfe:	eb 07                	jmp    80107c07 <loaduvm+0x86>
    else
      n = PGSIZE;
80107c00:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107c07:	8b 55 14             	mov    0x14(%ebp),%edx
80107c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0d:	01 d0                	add    %edx,%eax
80107c0f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107c12:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107c18:	ff 75 f0             	push   -0x10(%ebp)
80107c1b:	50                   	push   %eax
80107c1c:	52                   	push   %edx
80107c1d:	ff 75 10             	push   0x10(%ebp)
80107c20:	e8 b1 a2 ff ff       	call   80101ed6 <readi>
80107c25:	83 c4 10             	add    $0x10,%esp
80107c28:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107c2b:	74 07                	je     80107c34 <loaduvm+0xb3>
      return -1;
80107c2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c32:	eb 18                	jmp    80107c4c <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107c34:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3e:	3b 45 18             	cmp    0x18(%ebp),%eax
80107c41:	0f 82 65 ff ff ff    	jb     80107bac <loaduvm+0x2b>
  }
  return 0;
80107c47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c4c:	c9                   	leave  
80107c4d:	c3                   	ret    

80107c4e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107c4e:	55                   	push   %ebp
80107c4f:	89 e5                	mov    %esp,%ebp
80107c51:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107c54:	8b 45 10             	mov    0x10(%ebp),%eax
80107c57:	85 c0                	test   %eax,%eax
80107c59:	79 0a                	jns    80107c65 <allocuvm+0x17>
    return 0;
80107c5b:	b8 00 00 00 00       	mov    $0x0,%eax
80107c60:	e9 ec 00 00 00       	jmp    80107d51 <allocuvm+0x103>
  if(newsz < oldsz)
80107c65:	8b 45 10             	mov    0x10(%ebp),%eax
80107c68:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c6b:	73 08                	jae    80107c75 <allocuvm+0x27>
    return oldsz;
80107c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c70:	e9 dc 00 00 00       	jmp    80107d51 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107c75:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c78:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c85:	e9 b8 00 00 00       	jmp    80107d42 <allocuvm+0xf4>
    mem = kalloc();
80107c8a:	e8 11 ab ff ff       	call   801027a0 <kalloc>
80107c8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c92:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c96:	75 2e                	jne    80107cc6 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107c98:	83 ec 0c             	sub    $0xc,%esp
80107c9b:	68 29 ac 10 80       	push   $0x8010ac29
80107ca0:	e8 4f 87 ff ff       	call   801003f4 <cprintf>
80107ca5:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ca8:	83 ec 04             	sub    $0x4,%esp
80107cab:	ff 75 0c             	push   0xc(%ebp)
80107cae:	ff 75 10             	push   0x10(%ebp)
80107cb1:	ff 75 08             	push   0x8(%ebp)
80107cb4:	e8 9a 00 00 00       	call   80107d53 <deallocuvm>
80107cb9:	83 c4 10             	add    $0x10,%esp
      return 0;
80107cbc:	b8 00 00 00 00       	mov    $0x0,%eax
80107cc1:	e9 8b 00 00 00       	jmp    80107d51 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107cc6:	83 ec 04             	sub    $0x4,%esp
80107cc9:	68 00 10 00 00       	push   $0x1000
80107cce:	6a 00                	push   $0x0
80107cd0:	ff 75 f0             	push   -0x10(%ebp)
80107cd3:	e8 3e d1 ff ff       	call   80104e16 <memset>
80107cd8:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cde:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce7:	83 ec 0c             	sub    $0xc,%esp
80107cea:	6a 06                	push   $0x6
80107cec:	52                   	push   %edx
80107ced:	68 00 10 00 00       	push   $0x1000
80107cf2:	50                   	push   %eax
80107cf3:	ff 75 08             	push   0x8(%ebp)
80107cf6:	e8 ca fa ff ff       	call   801077c5 <mappages>
80107cfb:	83 c4 20             	add    $0x20,%esp
80107cfe:	85 c0                	test   %eax,%eax
80107d00:	79 39                	jns    80107d3b <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107d02:	83 ec 0c             	sub    $0xc,%esp
80107d05:	68 41 ac 10 80       	push   $0x8010ac41
80107d0a:	e8 e5 86 ff ff       	call   801003f4 <cprintf>
80107d0f:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107d12:	83 ec 04             	sub    $0x4,%esp
80107d15:	ff 75 0c             	push   0xc(%ebp)
80107d18:	ff 75 10             	push   0x10(%ebp)
80107d1b:	ff 75 08             	push   0x8(%ebp)
80107d1e:	e8 30 00 00 00       	call   80107d53 <deallocuvm>
80107d23:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107d26:	83 ec 0c             	sub    $0xc,%esp
80107d29:	ff 75 f0             	push   -0x10(%ebp)
80107d2c:	e8 d5 a9 ff ff       	call   80102706 <kfree>
80107d31:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d34:	b8 00 00 00 00       	mov    $0x0,%eax
80107d39:	eb 16                	jmp    80107d51 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107d3b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d45:	3b 45 10             	cmp    0x10(%ebp),%eax
80107d48:	0f 82 3c ff ff ff    	jb     80107c8a <allocuvm+0x3c>
    }
  }
  return newsz;
80107d4e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d51:	c9                   	leave  
80107d52:	c3                   	ret    

80107d53 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d53:	55                   	push   %ebp
80107d54:	89 e5                	mov    %esp,%ebp
80107d56:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107d59:	8b 45 10             	mov    0x10(%ebp),%eax
80107d5c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d5f:	72 08                	jb     80107d69 <deallocuvm+0x16>
    return oldsz;
80107d61:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d64:	e9 ac 00 00 00       	jmp    80107e15 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107d69:	8b 45 10             	mov    0x10(%ebp),%eax
80107d6c:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d79:	e9 88 00 00 00       	jmp    80107e06 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d81:	83 ec 04             	sub    $0x4,%esp
80107d84:	6a 00                	push   $0x0
80107d86:	50                   	push   %eax
80107d87:	ff 75 08             	push   0x8(%ebp)
80107d8a:	e8 a0 f9 ff ff       	call   8010772f <walkpgdir>
80107d8f:	83 c4 10             	add    $0x10,%esp
80107d92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d99:	75 16                	jne    80107db1 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9e:	c1 e8 16             	shr    $0x16,%eax
80107da1:	83 c0 01             	add    $0x1,%eax
80107da4:	c1 e0 16             	shl    $0x16,%eax
80107da7:	2d 00 10 00 00       	sub    $0x1000,%eax
80107dac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107daf:	eb 4e                	jmp    80107dff <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107db4:	8b 00                	mov    (%eax),%eax
80107db6:	83 e0 01             	and    $0x1,%eax
80107db9:	85 c0                	test   %eax,%eax
80107dbb:	74 42                	je     80107dff <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dc0:	8b 00                	mov    (%eax),%eax
80107dc2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107dca:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107dce:	75 0d                	jne    80107ddd <deallocuvm+0x8a>
        panic("kfree");
80107dd0:	83 ec 0c             	sub    $0xc,%esp
80107dd3:	68 5d ac 10 80       	push   $0x8010ac5d
80107dd8:	e8 cc 87 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107ddd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107de0:	05 00 00 00 80       	add    $0x80000000,%eax
80107de5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107de8:	83 ec 0c             	sub    $0xc,%esp
80107deb:	ff 75 e8             	push   -0x18(%ebp)
80107dee:	e8 13 a9 ff ff       	call   80102706 <kfree>
80107df3:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107df9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107dff:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e09:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e0c:	0f 82 6c ff ff ff    	jb     80107d7e <deallocuvm+0x2b>
    }
  }
  return newsz;
80107e12:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e15:	c9                   	leave  
80107e16:	c3                   	ret    

80107e17 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107e17:	55                   	push   %ebp
80107e18:	89 e5                	mov    %esp,%ebp
80107e1a:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107e1d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e21:	75 0d                	jne    80107e30 <freevm+0x19>
    panic("freevm: no pgdir");
80107e23:	83 ec 0c             	sub    $0xc,%esp
80107e26:	68 63 ac 10 80       	push   $0x8010ac63
80107e2b:	e8 79 87 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107e30:	83 ec 04             	sub    $0x4,%esp
80107e33:	6a 00                	push   $0x0
80107e35:	68 00 00 00 80       	push   $0x80000000
80107e3a:	ff 75 08             	push   0x8(%ebp)
80107e3d:	e8 11 ff ff ff       	call   80107d53 <deallocuvm>
80107e42:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e4c:	eb 48                	jmp    80107e96 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e51:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e58:	8b 45 08             	mov    0x8(%ebp),%eax
80107e5b:	01 d0                	add    %edx,%eax
80107e5d:	8b 00                	mov    (%eax),%eax
80107e5f:	83 e0 01             	and    $0x1,%eax
80107e62:	85 c0                	test   %eax,%eax
80107e64:	74 2c                	je     80107e92 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e70:	8b 45 08             	mov    0x8(%ebp),%eax
80107e73:	01 d0                	add    %edx,%eax
80107e75:	8b 00                	mov    (%eax),%eax
80107e77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e7c:	05 00 00 00 80       	add    $0x80000000,%eax
80107e81:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e84:	83 ec 0c             	sub    $0xc,%esp
80107e87:	ff 75 f0             	push   -0x10(%ebp)
80107e8a:	e8 77 a8 ff ff       	call   80102706 <kfree>
80107e8f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e92:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e96:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e9d:	76 af                	jbe    80107e4e <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107e9f:	83 ec 0c             	sub    $0xc,%esp
80107ea2:	ff 75 08             	push   0x8(%ebp)
80107ea5:	e8 5c a8 ff ff       	call   80102706 <kfree>
80107eaa:	83 c4 10             	add    $0x10,%esp
}
80107ead:	90                   	nop
80107eae:	c9                   	leave  
80107eaf:	c3                   	ret    

80107eb0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107eb0:	55                   	push   %ebp
80107eb1:	89 e5                	mov    %esp,%ebp
80107eb3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107eb6:	83 ec 04             	sub    $0x4,%esp
80107eb9:	6a 00                	push   $0x0
80107ebb:	ff 75 0c             	push   0xc(%ebp)
80107ebe:	ff 75 08             	push   0x8(%ebp)
80107ec1:	e8 69 f8 ff ff       	call   8010772f <walkpgdir>
80107ec6:	83 c4 10             	add    $0x10,%esp
80107ec9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107ecc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ed0:	75 0d                	jne    80107edf <clearpteu+0x2f>
    panic("clearpteu");
80107ed2:	83 ec 0c             	sub    $0xc,%esp
80107ed5:	68 74 ac 10 80       	push   $0x8010ac74
80107eda:	e8 ca 86 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee2:	8b 00                	mov    (%eax),%eax
80107ee4:	83 e0 fb             	and    $0xfffffffb,%eax
80107ee7:	89 c2                	mov    %eax,%edx
80107ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eec:	89 10                	mov    %edx,(%eax)
}
80107eee:	90                   	nop
80107eef:	c9                   	leave  
80107ef0:	c3                   	ret    

80107ef1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107ef1:	55                   	push   %ebp
80107ef2:	89 e5                	mov    %esp,%ebp
80107ef4:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107ef7:	e8 59 f9 ff ff       	call   80107855 <setupkvm>
80107efc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107eff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f03:	75 0a                	jne    80107f0f <copyuvm+0x1e>
    return 0;
80107f05:	b8 00 00 00 00       	mov    $0x0,%eax
80107f0a:	e9 eb 00 00 00       	jmp    80107ffa <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107f0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f16:	e9 b7 00 00 00       	jmp    80107fd2 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1e:	83 ec 04             	sub    $0x4,%esp
80107f21:	6a 00                	push   $0x0
80107f23:	50                   	push   %eax
80107f24:	ff 75 08             	push   0x8(%ebp)
80107f27:	e8 03 f8 ff ff       	call   8010772f <walkpgdir>
80107f2c:	83 c4 10             	add    $0x10,%esp
80107f2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f32:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f36:	75 0d                	jne    80107f45 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107f38:	83 ec 0c             	sub    $0xc,%esp
80107f3b:	68 7e ac 10 80       	push   $0x8010ac7e
80107f40:	e8 64 86 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107f45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f48:	8b 00                	mov    (%eax),%eax
80107f4a:	83 e0 01             	and    $0x1,%eax
80107f4d:	85 c0                	test   %eax,%eax
80107f4f:	75 0d                	jne    80107f5e <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107f51:	83 ec 0c             	sub    $0xc,%esp
80107f54:	68 98 ac 10 80       	push   $0x8010ac98
80107f59:	e8 4b 86 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107f5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f61:	8b 00                	mov    (%eax),%eax
80107f63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f68:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107f6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f6e:	8b 00                	mov    (%eax),%eax
80107f70:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107f78:	e8 23 a8 ff ff       	call   801027a0 <kalloc>
80107f7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f80:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f84:	74 5d                	je     80107fe3 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107f86:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f89:	05 00 00 00 80       	add    $0x80000000,%eax
80107f8e:	83 ec 04             	sub    $0x4,%esp
80107f91:	68 00 10 00 00       	push   $0x1000
80107f96:	50                   	push   %eax
80107f97:	ff 75 e0             	push   -0x20(%ebp)
80107f9a:	e8 36 cf ff ff       	call   80104ed5 <memmove>
80107f9f:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107fa2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107fa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107fa8:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb1:	83 ec 0c             	sub    $0xc,%esp
80107fb4:	52                   	push   %edx
80107fb5:	51                   	push   %ecx
80107fb6:	68 00 10 00 00       	push   $0x1000
80107fbb:	50                   	push   %eax
80107fbc:	ff 75 f0             	push   -0x10(%ebp)
80107fbf:	e8 01 f8 ff ff       	call   801077c5 <mappages>
80107fc4:	83 c4 20             	add    $0x20,%esp
80107fc7:	85 c0                	test   %eax,%eax
80107fc9:	78 1b                	js     80107fe6 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107fcb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fd8:	0f 82 3d ff ff ff    	jb     80107f1b <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107fde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fe1:	eb 17                	jmp    80107ffa <copyuvm+0x109>
      goto bad;
80107fe3:	90                   	nop
80107fe4:	eb 01                	jmp    80107fe7 <copyuvm+0xf6>
      goto bad;
80107fe6:	90                   	nop

bad:
  freevm(d);
80107fe7:	83 ec 0c             	sub    $0xc,%esp
80107fea:	ff 75 f0             	push   -0x10(%ebp)
80107fed:	e8 25 fe ff ff       	call   80107e17 <freevm>
80107ff2:	83 c4 10             	add    $0x10,%esp
  return 0;
80107ff5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ffa:	c9                   	leave  
80107ffb:	c3                   	ret    

80107ffc <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107ffc:	55                   	push   %ebp
80107ffd:	89 e5                	mov    %esp,%ebp
80107fff:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108002:	83 ec 04             	sub    $0x4,%esp
80108005:	6a 00                	push   $0x0
80108007:	ff 75 0c             	push   0xc(%ebp)
8010800a:	ff 75 08             	push   0x8(%ebp)
8010800d:	e8 1d f7 ff ff       	call   8010772f <walkpgdir>
80108012:	83 c4 10             	add    $0x10,%esp
80108015:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801b:	8b 00                	mov    (%eax),%eax
8010801d:	83 e0 01             	and    $0x1,%eax
80108020:	85 c0                	test   %eax,%eax
80108022:	75 07                	jne    8010802b <uva2ka+0x2f>
    return 0;
80108024:	b8 00 00 00 00       	mov    $0x0,%eax
80108029:	eb 22                	jmp    8010804d <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
8010802b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802e:	8b 00                	mov    (%eax),%eax
80108030:	83 e0 04             	and    $0x4,%eax
80108033:	85 c0                	test   %eax,%eax
80108035:	75 07                	jne    8010803e <uva2ka+0x42>
    return 0;
80108037:	b8 00 00 00 00       	mov    $0x0,%eax
8010803c:	eb 0f                	jmp    8010804d <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010803e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108041:	8b 00                	mov    (%eax),%eax
80108043:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108048:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010804d:	c9                   	leave  
8010804e:	c3                   	ret    

8010804f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010804f:	55                   	push   %ebp
80108050:	89 e5                	mov    %esp,%ebp
80108052:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108055:	8b 45 10             	mov    0x10(%ebp),%eax
80108058:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010805b:	eb 7f                	jmp    801080dc <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010805d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108060:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108065:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108068:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010806b:	83 ec 08             	sub    $0x8,%esp
8010806e:	50                   	push   %eax
8010806f:	ff 75 08             	push   0x8(%ebp)
80108072:	e8 85 ff ff ff       	call   80107ffc <uva2ka>
80108077:	83 c4 10             	add    $0x10,%esp
8010807a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010807d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108081:	75 07                	jne    8010808a <copyout+0x3b>
      return -1;
80108083:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108088:	eb 61                	jmp    801080eb <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010808a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010808d:	2b 45 0c             	sub    0xc(%ebp),%eax
80108090:	05 00 10 00 00       	add    $0x1000,%eax
80108095:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108098:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010809b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010809e:	76 06                	jbe    801080a6 <copyout+0x57>
      n = len;
801080a0:	8b 45 14             	mov    0x14(%ebp),%eax
801080a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801080a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801080a9:	2b 45 ec             	sub    -0x14(%ebp),%eax
801080ac:	89 c2                	mov    %eax,%edx
801080ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080b1:	01 d0                	add    %edx,%eax
801080b3:	83 ec 04             	sub    $0x4,%esp
801080b6:	ff 75 f0             	push   -0x10(%ebp)
801080b9:	ff 75 f4             	push   -0xc(%ebp)
801080bc:	50                   	push   %eax
801080bd:	e8 13 ce ff ff       	call   80104ed5 <memmove>
801080c2:	83 c4 10             	add    $0x10,%esp
    len -= n;
801080c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c8:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801080cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ce:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801080d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080d4:	05 00 10 00 00       	add    $0x1000,%eax
801080d9:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801080dc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801080e0:	0f 85 77 ff ff ff    	jne    8010805d <copyout+0xe>
  }
  return 0;
801080e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080eb:	c9                   	leave  
801080ec:	c3                   	ret    

801080ed <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801080ed:	55                   	push   %ebp
801080ee:	89 e5                	mov    %esp,%ebp
801080f0:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801080f3:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801080fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080fd:	8b 40 08             	mov    0x8(%eax),%eax
80108100:	05 00 00 00 80       	add    $0x80000000,%eax
80108105:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108108:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010810f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108112:	8b 40 24             	mov    0x24(%eax),%eax
80108115:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
8010811a:	c7 05 50 75 19 80 00 	movl   $0x0,0x80197550
80108121:	00 00 00 

  while(i<madt->len){
80108124:	90                   	nop
80108125:	e9 bd 00 00 00       	jmp    801081e7 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
8010812a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010812d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108130:	01 d0                	add    %edx,%eax
80108132:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108138:	0f b6 00             	movzbl (%eax),%eax
8010813b:	0f b6 c0             	movzbl %al,%eax
8010813e:	83 f8 05             	cmp    $0x5,%eax
80108141:	0f 87 a0 00 00 00    	ja     801081e7 <mpinit_uefi+0xfa>
80108147:	8b 04 85 b4 ac 10 80 	mov    -0x7fef534c(,%eax,4),%eax
8010814e:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108150:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108153:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108156:	a1 50 75 19 80       	mov    0x80197550,%eax
8010815b:	83 f8 03             	cmp    $0x3,%eax
8010815e:	7f 28                	jg     80108188 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108160:	8b 15 50 75 19 80    	mov    0x80197550,%edx
80108166:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108169:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010816d:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108173:	81 c2 80 72 19 80    	add    $0x80197280,%edx
80108179:	88 02                	mov    %al,(%edx)
          ncpu++;
8010817b:	a1 50 75 19 80       	mov    0x80197550,%eax
80108180:	83 c0 01             	add    $0x1,%eax
80108183:	a3 50 75 19 80       	mov    %eax,0x80197550
        }
        i += lapic_entry->record_len;
80108188:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010818b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010818f:	0f b6 c0             	movzbl %al,%eax
80108192:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108195:	eb 50                	jmp    801081e7 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108197:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010819a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010819d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801081a0:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801081a4:	a2 54 75 19 80       	mov    %al,0x80197554
        i += ioapic->record_len;
801081a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801081ac:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081b0:	0f b6 c0             	movzbl %al,%eax
801081b3:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081b6:	eb 2f                	jmp    801081e7 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801081b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801081be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081c1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081c5:	0f b6 c0             	movzbl %al,%eax
801081c8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081cb:	eb 1a                	jmp    801081e7 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801081cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801081d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081da:	0f b6 c0             	movzbl %al,%eax
801081dd:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081e0:	eb 05                	jmp    801081e7 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
801081e2:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801081e6:	90                   	nop
  while(i<madt->len){
801081e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ea:	8b 40 04             	mov    0x4(%eax),%eax
801081ed:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801081f0:	0f 82 34 ff ff ff    	jb     8010812a <mpinit_uefi+0x3d>
    }
  }

}
801081f6:	90                   	nop
801081f7:	90                   	nop
801081f8:	c9                   	leave  
801081f9:	c3                   	ret    

801081fa <inb>:
{
801081fa:	55                   	push   %ebp
801081fb:	89 e5                	mov    %esp,%ebp
801081fd:	83 ec 14             	sub    $0x14,%esp
80108200:	8b 45 08             	mov    0x8(%ebp),%eax
80108203:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108207:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010820b:	89 c2                	mov    %eax,%edx
8010820d:	ec                   	in     (%dx),%al
8010820e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108211:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108215:	c9                   	leave  
80108216:	c3                   	ret    

80108217 <outb>:
{
80108217:	55                   	push   %ebp
80108218:	89 e5                	mov    %esp,%ebp
8010821a:	83 ec 08             	sub    $0x8,%esp
8010821d:	8b 45 08             	mov    0x8(%ebp),%eax
80108220:	8b 55 0c             	mov    0xc(%ebp),%edx
80108223:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108227:	89 d0                	mov    %edx,%eax
80108229:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010822c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108230:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108234:	ee                   	out    %al,(%dx)
}
80108235:	90                   	nop
80108236:	c9                   	leave  
80108237:	c3                   	ret    

80108238 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108238:	55                   	push   %ebp
80108239:	89 e5                	mov    %esp,%ebp
8010823b:	83 ec 28             	sub    $0x28,%esp
8010823e:	8b 45 08             	mov    0x8(%ebp),%eax
80108241:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108244:	6a 00                	push   $0x0
80108246:	68 fa 03 00 00       	push   $0x3fa
8010824b:	e8 c7 ff ff ff       	call   80108217 <outb>
80108250:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108253:	68 80 00 00 00       	push   $0x80
80108258:	68 fb 03 00 00       	push   $0x3fb
8010825d:	e8 b5 ff ff ff       	call   80108217 <outb>
80108262:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108265:	6a 0c                	push   $0xc
80108267:	68 f8 03 00 00       	push   $0x3f8
8010826c:	e8 a6 ff ff ff       	call   80108217 <outb>
80108271:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108274:	6a 00                	push   $0x0
80108276:	68 f9 03 00 00       	push   $0x3f9
8010827b:	e8 97 ff ff ff       	call   80108217 <outb>
80108280:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108283:	6a 03                	push   $0x3
80108285:	68 fb 03 00 00       	push   $0x3fb
8010828a:	e8 88 ff ff ff       	call   80108217 <outb>
8010828f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108292:	6a 00                	push   $0x0
80108294:	68 fc 03 00 00       	push   $0x3fc
80108299:	e8 79 ff ff ff       	call   80108217 <outb>
8010829e:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801082a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082a8:	eb 11                	jmp    801082bb <uart_debug+0x83>
801082aa:	83 ec 0c             	sub    $0xc,%esp
801082ad:	6a 0a                	push   $0xa
801082af:	e8 83 a8 ff ff       	call   80102b37 <microdelay>
801082b4:	83 c4 10             	add    $0x10,%esp
801082b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082bb:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801082bf:	7f 1a                	jg     801082db <uart_debug+0xa3>
801082c1:	83 ec 0c             	sub    $0xc,%esp
801082c4:	68 fd 03 00 00       	push   $0x3fd
801082c9:	e8 2c ff ff ff       	call   801081fa <inb>
801082ce:	83 c4 10             	add    $0x10,%esp
801082d1:	0f b6 c0             	movzbl %al,%eax
801082d4:	83 e0 20             	and    $0x20,%eax
801082d7:	85 c0                	test   %eax,%eax
801082d9:	74 cf                	je     801082aa <uart_debug+0x72>
  outb(COM1+0, p);
801082db:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801082df:	0f b6 c0             	movzbl %al,%eax
801082e2:	83 ec 08             	sub    $0x8,%esp
801082e5:	50                   	push   %eax
801082e6:	68 f8 03 00 00       	push   $0x3f8
801082eb:	e8 27 ff ff ff       	call   80108217 <outb>
801082f0:	83 c4 10             	add    $0x10,%esp
}
801082f3:	90                   	nop
801082f4:	c9                   	leave  
801082f5:	c3                   	ret    

801082f6 <uart_debugs>:

void uart_debugs(char *p){
801082f6:	55                   	push   %ebp
801082f7:	89 e5                	mov    %esp,%ebp
801082f9:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801082fc:	eb 1b                	jmp    80108319 <uart_debugs+0x23>
    uart_debug(*p++);
801082fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108301:	8d 50 01             	lea    0x1(%eax),%edx
80108304:	89 55 08             	mov    %edx,0x8(%ebp)
80108307:	0f b6 00             	movzbl (%eax),%eax
8010830a:	0f be c0             	movsbl %al,%eax
8010830d:	83 ec 0c             	sub    $0xc,%esp
80108310:	50                   	push   %eax
80108311:	e8 22 ff ff ff       	call   80108238 <uart_debug>
80108316:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108319:	8b 45 08             	mov    0x8(%ebp),%eax
8010831c:	0f b6 00             	movzbl (%eax),%eax
8010831f:	84 c0                	test   %al,%al
80108321:	75 db                	jne    801082fe <uart_debugs+0x8>
  }
}
80108323:	90                   	nop
80108324:	90                   	nop
80108325:	c9                   	leave  
80108326:	c3                   	ret    

80108327 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108327:	55                   	push   %ebp
80108328:	89 e5                	mov    %esp,%ebp
8010832a:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010832d:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108334:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108337:	8b 50 14             	mov    0x14(%eax),%edx
8010833a:	8b 40 10             	mov    0x10(%eax),%eax
8010833d:	a3 58 75 19 80       	mov    %eax,0x80197558
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108342:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108345:	8b 50 1c             	mov    0x1c(%eax),%edx
80108348:	8b 40 18             	mov    0x18(%eax),%eax
8010834b:	a3 60 75 19 80       	mov    %eax,0x80197560
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108350:	8b 15 60 75 19 80    	mov    0x80197560,%edx
80108356:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010835b:	29 d0                	sub    %edx,%eax
8010835d:	a3 5c 75 19 80       	mov    %eax,0x8019755c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108362:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108365:	8b 50 24             	mov    0x24(%eax),%edx
80108368:	8b 40 20             	mov    0x20(%eax),%eax
8010836b:	a3 64 75 19 80       	mov    %eax,0x80197564
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108370:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108373:	8b 50 2c             	mov    0x2c(%eax),%edx
80108376:	8b 40 28             	mov    0x28(%eax),%eax
80108379:	a3 68 75 19 80       	mov    %eax,0x80197568
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010837e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108381:	8b 50 34             	mov    0x34(%eax),%edx
80108384:	8b 40 30             	mov    0x30(%eax),%eax
80108387:	a3 6c 75 19 80       	mov    %eax,0x8019756c
}
8010838c:	90                   	nop
8010838d:	c9                   	leave  
8010838e:	c3                   	ret    

8010838f <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010838f:	55                   	push   %ebp
80108390:	89 e5                	mov    %esp,%ebp
80108392:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108395:	8b 15 6c 75 19 80    	mov    0x8019756c,%edx
8010839b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010839e:	0f af d0             	imul   %eax,%edx
801083a1:	8b 45 08             	mov    0x8(%ebp),%eax
801083a4:	01 d0                	add    %edx,%eax
801083a6:	c1 e0 02             	shl    $0x2,%eax
801083a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801083ac:	8b 15 5c 75 19 80    	mov    0x8019755c,%edx
801083b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083b5:	01 d0                	add    %edx,%eax
801083b7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801083ba:	8b 45 10             	mov    0x10(%ebp),%eax
801083bd:	0f b6 10             	movzbl (%eax),%edx
801083c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083c3:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801083c5:	8b 45 10             	mov    0x10(%ebp),%eax
801083c8:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801083cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083cf:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801083d2:	8b 45 10             	mov    0x10(%ebp),%eax
801083d5:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801083d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083dc:	88 50 02             	mov    %dl,0x2(%eax)
}
801083df:	90                   	nop
801083e0:	c9                   	leave  
801083e1:	c3                   	ret    

801083e2 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801083e2:	55                   	push   %ebp
801083e3:	89 e5                	mov    %esp,%ebp
801083e5:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801083e8:	8b 15 6c 75 19 80    	mov    0x8019756c,%edx
801083ee:	8b 45 08             	mov    0x8(%ebp),%eax
801083f1:	0f af c2             	imul   %edx,%eax
801083f4:	c1 e0 02             	shl    $0x2,%eax
801083f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801083fa:	a1 60 75 19 80       	mov    0x80197560,%eax
801083ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108402:	29 d0                	sub    %edx,%eax
80108404:	8b 0d 5c 75 19 80    	mov    0x8019755c,%ecx
8010840a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010840d:	01 ca                	add    %ecx,%edx
8010840f:	89 d1                	mov    %edx,%ecx
80108411:	8b 15 5c 75 19 80    	mov    0x8019755c,%edx
80108417:	83 ec 04             	sub    $0x4,%esp
8010841a:	50                   	push   %eax
8010841b:	51                   	push   %ecx
8010841c:	52                   	push   %edx
8010841d:	e8 b3 ca ff ff       	call   80104ed5 <memmove>
80108422:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108428:	8b 0d 5c 75 19 80    	mov    0x8019755c,%ecx
8010842e:	8b 15 60 75 19 80    	mov    0x80197560,%edx
80108434:	01 ca                	add    %ecx,%edx
80108436:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108439:	29 ca                	sub    %ecx,%edx
8010843b:	83 ec 04             	sub    $0x4,%esp
8010843e:	50                   	push   %eax
8010843f:	6a 00                	push   $0x0
80108441:	52                   	push   %edx
80108442:	e8 cf c9 ff ff       	call   80104e16 <memset>
80108447:	83 c4 10             	add    $0x10,%esp
}
8010844a:	90                   	nop
8010844b:	c9                   	leave  
8010844c:	c3                   	ret    

8010844d <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010844d:	55                   	push   %ebp
8010844e:	89 e5                	mov    %esp,%ebp
80108450:	53                   	push   %ebx
80108451:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108454:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010845b:	e9 b1 00 00 00       	jmp    80108511 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108460:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108467:	e9 97 00 00 00       	jmp    80108503 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
8010846c:	8b 45 10             	mov    0x10(%ebp),%eax
8010846f:	83 e8 20             	sub    $0x20,%eax
80108472:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108478:	01 d0                	add    %edx,%eax
8010847a:	0f b7 84 00 e0 ac 10 	movzwl -0x7fef5320(%eax,%eax,1),%eax
80108481:	80 
80108482:	0f b7 d0             	movzwl %ax,%edx
80108485:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108488:	bb 01 00 00 00       	mov    $0x1,%ebx
8010848d:	89 c1                	mov    %eax,%ecx
8010848f:	d3 e3                	shl    %cl,%ebx
80108491:	89 d8                	mov    %ebx,%eax
80108493:	21 d0                	and    %edx,%eax
80108495:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010849b:	ba 01 00 00 00       	mov    $0x1,%edx
801084a0:	89 c1                	mov    %eax,%ecx
801084a2:	d3 e2                	shl    %cl,%edx
801084a4:	89 d0                	mov    %edx,%eax
801084a6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801084a9:	75 2b                	jne    801084d6 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801084ab:	8b 55 0c             	mov    0xc(%ebp),%edx
801084ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b1:	01 c2                	add    %eax,%edx
801084b3:	b8 0e 00 00 00       	mov    $0xe,%eax
801084b8:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084bb:	89 c1                	mov    %eax,%ecx
801084bd:	8b 45 08             	mov    0x8(%ebp),%eax
801084c0:	01 c8                	add    %ecx,%eax
801084c2:	83 ec 04             	sub    $0x4,%esp
801084c5:	68 e0 f4 10 80       	push   $0x8010f4e0
801084ca:	52                   	push   %edx
801084cb:	50                   	push   %eax
801084cc:	e8 be fe ff ff       	call   8010838f <graphic_draw_pixel>
801084d1:	83 c4 10             	add    $0x10,%esp
801084d4:	eb 29                	jmp    801084ff <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801084d6:	8b 55 0c             	mov    0xc(%ebp),%edx
801084d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084dc:	01 c2                	add    %eax,%edx
801084de:	b8 0e 00 00 00       	mov    $0xe,%eax
801084e3:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084e6:	89 c1                	mov    %eax,%ecx
801084e8:	8b 45 08             	mov    0x8(%ebp),%eax
801084eb:	01 c8                	add    %ecx,%eax
801084ed:	83 ec 04             	sub    $0x4,%esp
801084f0:	68 70 75 19 80       	push   $0x80197570
801084f5:	52                   	push   %edx
801084f6:	50                   	push   %eax
801084f7:	e8 93 fe ff ff       	call   8010838f <graphic_draw_pixel>
801084fc:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801084ff:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108503:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108507:	0f 89 5f ff ff ff    	jns    8010846c <font_render+0x1f>
  for(int i=0;i<30;i++){
8010850d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108511:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108515:	0f 8e 45 ff ff ff    	jle    80108460 <font_render+0x13>
      }
    }
  }
}
8010851b:	90                   	nop
8010851c:	90                   	nop
8010851d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108520:	c9                   	leave  
80108521:	c3                   	ret    

80108522 <font_render_string>:

void font_render_string(char *string,int row){
80108522:	55                   	push   %ebp
80108523:	89 e5                	mov    %esp,%ebp
80108525:	53                   	push   %ebx
80108526:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108529:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108530:	eb 33                	jmp    80108565 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108532:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108535:	8b 45 08             	mov    0x8(%ebp),%eax
80108538:	01 d0                	add    %edx,%eax
8010853a:	0f b6 00             	movzbl (%eax),%eax
8010853d:	0f be c8             	movsbl %al,%ecx
80108540:	8b 45 0c             	mov    0xc(%ebp),%eax
80108543:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108546:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108549:	89 d8                	mov    %ebx,%eax
8010854b:	c1 e0 04             	shl    $0x4,%eax
8010854e:	29 d8                	sub    %ebx,%eax
80108550:	83 c0 02             	add    $0x2,%eax
80108553:	83 ec 04             	sub    $0x4,%esp
80108556:	51                   	push   %ecx
80108557:	52                   	push   %edx
80108558:	50                   	push   %eax
80108559:	e8 ef fe ff ff       	call   8010844d <font_render>
8010855e:	83 c4 10             	add    $0x10,%esp
    i++;
80108561:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108565:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108568:	8b 45 08             	mov    0x8(%ebp),%eax
8010856b:	01 d0                	add    %edx,%eax
8010856d:	0f b6 00             	movzbl (%eax),%eax
80108570:	84 c0                	test   %al,%al
80108572:	74 06                	je     8010857a <font_render_string+0x58>
80108574:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108578:	7e b8                	jle    80108532 <font_render_string+0x10>
  }
}
8010857a:	90                   	nop
8010857b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010857e:	c9                   	leave  
8010857f:	c3                   	ret    

80108580 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108580:	55                   	push   %ebp
80108581:	89 e5                	mov    %esp,%ebp
80108583:	53                   	push   %ebx
80108584:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108587:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010858e:	eb 6b                	jmp    801085fb <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108590:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108597:	eb 58                	jmp    801085f1 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108599:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801085a0:	eb 45                	jmp    801085e7 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801085a2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ab:	83 ec 0c             	sub    $0xc,%esp
801085ae:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801085b1:	53                   	push   %ebx
801085b2:	6a 00                	push   $0x0
801085b4:	51                   	push   %ecx
801085b5:	52                   	push   %edx
801085b6:	50                   	push   %eax
801085b7:	e8 b0 00 00 00       	call   8010866c <pci_access_config>
801085bc:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801085bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085c2:	0f b7 c0             	movzwl %ax,%eax
801085c5:	3d ff ff 00 00       	cmp    $0xffff,%eax
801085ca:	74 17                	je     801085e3 <pci_init+0x63>
        pci_init_device(i,j,k);
801085cc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d5:	83 ec 04             	sub    $0x4,%esp
801085d8:	51                   	push   %ecx
801085d9:	52                   	push   %edx
801085da:	50                   	push   %eax
801085db:	e8 37 01 00 00       	call   80108717 <pci_init_device>
801085e0:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801085e3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801085e7:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801085eb:	7e b5                	jle    801085a2 <pci_init+0x22>
    for(int j=0;j<32;j++){
801085ed:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801085f1:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801085f5:	7e a2                	jle    80108599 <pci_init+0x19>
  for(int i=0;i<256;i++){
801085f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085fb:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108602:	7e 8c                	jle    80108590 <pci_init+0x10>
      }
      }
    }
  }
}
80108604:	90                   	nop
80108605:	90                   	nop
80108606:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108609:	c9                   	leave  
8010860a:	c3                   	ret    

8010860b <pci_write_config>:

void pci_write_config(uint config){
8010860b:	55                   	push   %ebp
8010860c:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010860e:	8b 45 08             	mov    0x8(%ebp),%eax
80108611:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108616:	89 c0                	mov    %eax,%eax
80108618:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108619:	90                   	nop
8010861a:	5d                   	pop    %ebp
8010861b:	c3                   	ret    

8010861c <pci_write_data>:

void pci_write_data(uint config){
8010861c:	55                   	push   %ebp
8010861d:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010861f:	8b 45 08             	mov    0x8(%ebp),%eax
80108622:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108627:	89 c0                	mov    %eax,%eax
80108629:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010862a:	90                   	nop
8010862b:	5d                   	pop    %ebp
8010862c:	c3                   	ret    

8010862d <pci_read_config>:
uint pci_read_config(){
8010862d:	55                   	push   %ebp
8010862e:	89 e5                	mov    %esp,%ebp
80108630:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108633:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108638:	ed                   	in     (%dx),%eax
80108639:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
8010863c:	83 ec 0c             	sub    $0xc,%esp
8010863f:	68 c8 00 00 00       	push   $0xc8
80108644:	e8 ee a4 ff ff       	call   80102b37 <microdelay>
80108649:	83 c4 10             	add    $0x10,%esp
  return data;
8010864c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010864f:	c9                   	leave  
80108650:	c3                   	ret    

80108651 <pci_test>:


void pci_test(){
80108651:	55                   	push   %ebp
80108652:	89 e5                	mov    %esp,%ebp
80108654:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108657:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010865e:	ff 75 fc             	push   -0x4(%ebp)
80108661:	e8 a5 ff ff ff       	call   8010860b <pci_write_config>
80108666:	83 c4 04             	add    $0x4,%esp
}
80108669:	90                   	nop
8010866a:	c9                   	leave  
8010866b:	c3                   	ret    

8010866c <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010866c:	55                   	push   %ebp
8010866d:	89 e5                	mov    %esp,%ebp
8010866f:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108672:	8b 45 08             	mov    0x8(%ebp),%eax
80108675:	c1 e0 10             	shl    $0x10,%eax
80108678:	25 00 00 ff 00       	and    $0xff0000,%eax
8010867d:	89 c2                	mov    %eax,%edx
8010867f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108682:	c1 e0 0b             	shl    $0xb,%eax
80108685:	0f b7 c0             	movzwl %ax,%eax
80108688:	09 c2                	or     %eax,%edx
8010868a:	8b 45 10             	mov    0x10(%ebp),%eax
8010868d:	c1 e0 08             	shl    $0x8,%eax
80108690:	25 00 07 00 00       	and    $0x700,%eax
80108695:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108697:	8b 45 14             	mov    0x14(%ebp),%eax
8010869a:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010869f:	09 d0                	or     %edx,%eax
801086a1:	0d 00 00 00 80       	or     $0x80000000,%eax
801086a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801086a9:	ff 75 f4             	push   -0xc(%ebp)
801086ac:	e8 5a ff ff ff       	call   8010860b <pci_write_config>
801086b1:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801086b4:	e8 74 ff ff ff       	call   8010862d <pci_read_config>
801086b9:	8b 55 18             	mov    0x18(%ebp),%edx
801086bc:	89 02                	mov    %eax,(%edx)
}
801086be:	90                   	nop
801086bf:	c9                   	leave  
801086c0:	c3                   	ret    

801086c1 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801086c1:	55                   	push   %ebp
801086c2:	89 e5                	mov    %esp,%ebp
801086c4:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086c7:	8b 45 08             	mov    0x8(%ebp),%eax
801086ca:	c1 e0 10             	shl    $0x10,%eax
801086cd:	25 00 00 ff 00       	and    $0xff0000,%eax
801086d2:	89 c2                	mov    %eax,%edx
801086d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801086d7:	c1 e0 0b             	shl    $0xb,%eax
801086da:	0f b7 c0             	movzwl %ax,%eax
801086dd:	09 c2                	or     %eax,%edx
801086df:	8b 45 10             	mov    0x10(%ebp),%eax
801086e2:	c1 e0 08             	shl    $0x8,%eax
801086e5:	25 00 07 00 00       	and    $0x700,%eax
801086ea:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801086ec:	8b 45 14             	mov    0x14(%ebp),%eax
801086ef:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086f4:	09 d0                	or     %edx,%eax
801086f6:	0d 00 00 00 80       	or     $0x80000000,%eax
801086fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801086fe:	ff 75 fc             	push   -0x4(%ebp)
80108701:	e8 05 ff ff ff       	call   8010860b <pci_write_config>
80108706:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108709:	ff 75 18             	push   0x18(%ebp)
8010870c:	e8 0b ff ff ff       	call   8010861c <pci_write_data>
80108711:	83 c4 04             	add    $0x4,%esp
}
80108714:	90                   	nop
80108715:	c9                   	leave  
80108716:	c3                   	ret    

80108717 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108717:	55                   	push   %ebp
80108718:	89 e5                	mov    %esp,%ebp
8010871a:	53                   	push   %ebx
8010871b:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010871e:	8b 45 08             	mov    0x8(%ebp),%eax
80108721:	a2 74 75 19 80       	mov    %al,0x80197574
  dev.device_num = device_num;
80108726:	8b 45 0c             	mov    0xc(%ebp),%eax
80108729:	a2 75 75 19 80       	mov    %al,0x80197575
  dev.function_num = function_num;
8010872e:	8b 45 10             	mov    0x10(%ebp),%eax
80108731:	a2 76 75 19 80       	mov    %al,0x80197576
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108736:	ff 75 10             	push   0x10(%ebp)
80108739:	ff 75 0c             	push   0xc(%ebp)
8010873c:	ff 75 08             	push   0x8(%ebp)
8010873f:	68 24 c3 10 80       	push   $0x8010c324
80108744:	e8 ab 7c ff ff       	call   801003f4 <cprintf>
80108749:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
8010874c:	83 ec 0c             	sub    $0xc,%esp
8010874f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108752:	50                   	push   %eax
80108753:	6a 00                	push   $0x0
80108755:	ff 75 10             	push   0x10(%ebp)
80108758:	ff 75 0c             	push   0xc(%ebp)
8010875b:	ff 75 08             	push   0x8(%ebp)
8010875e:	e8 09 ff ff ff       	call   8010866c <pci_access_config>
80108763:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108766:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108769:	c1 e8 10             	shr    $0x10,%eax
8010876c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010876f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108772:	25 ff ff 00 00       	and    $0xffff,%eax
80108777:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
8010877a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877d:	a3 78 75 19 80       	mov    %eax,0x80197578
  dev.vendor_id = vendor_id;
80108782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108785:	a3 7c 75 19 80       	mov    %eax,0x8019757c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
8010878a:	83 ec 04             	sub    $0x4,%esp
8010878d:	ff 75 f0             	push   -0x10(%ebp)
80108790:	ff 75 f4             	push   -0xc(%ebp)
80108793:	68 58 c3 10 80       	push   $0x8010c358
80108798:	e8 57 7c ff ff       	call   801003f4 <cprintf>
8010879d:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801087a0:	83 ec 0c             	sub    $0xc,%esp
801087a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087a6:	50                   	push   %eax
801087a7:	6a 08                	push   $0x8
801087a9:	ff 75 10             	push   0x10(%ebp)
801087ac:	ff 75 0c             	push   0xc(%ebp)
801087af:	ff 75 08             	push   0x8(%ebp)
801087b2:	e8 b5 fe ff ff       	call   8010866c <pci_access_config>
801087b7:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087bd:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c3:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087c6:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087cc:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087cf:	0f b6 c0             	movzbl %al,%eax
801087d2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801087d5:	c1 eb 18             	shr    $0x18,%ebx
801087d8:	83 ec 0c             	sub    $0xc,%esp
801087db:	51                   	push   %ecx
801087dc:	52                   	push   %edx
801087dd:	50                   	push   %eax
801087de:	53                   	push   %ebx
801087df:	68 7c c3 10 80       	push   $0x8010c37c
801087e4:	e8 0b 7c ff ff       	call   801003f4 <cprintf>
801087e9:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801087ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ef:	c1 e8 18             	shr    $0x18,%eax
801087f2:	a2 80 75 19 80       	mov    %al,0x80197580
  dev.sub_class = (data>>16)&0xFF;
801087f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fa:	c1 e8 10             	shr    $0x10,%eax
801087fd:	a2 81 75 19 80       	mov    %al,0x80197581
  dev.interface = (data>>8)&0xFF;
80108802:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108805:	c1 e8 08             	shr    $0x8,%eax
80108808:	a2 82 75 19 80       	mov    %al,0x80197582
  dev.revision_id = data&0xFF;
8010880d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108810:	a2 83 75 19 80       	mov    %al,0x80197583
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108815:	83 ec 0c             	sub    $0xc,%esp
80108818:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010881b:	50                   	push   %eax
8010881c:	6a 10                	push   $0x10
8010881e:	ff 75 10             	push   0x10(%ebp)
80108821:	ff 75 0c             	push   0xc(%ebp)
80108824:	ff 75 08             	push   0x8(%ebp)
80108827:	e8 40 fe ff ff       	call   8010866c <pci_access_config>
8010882c:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010882f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108832:	a3 84 75 19 80       	mov    %eax,0x80197584
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108837:	83 ec 0c             	sub    $0xc,%esp
8010883a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010883d:	50                   	push   %eax
8010883e:	6a 14                	push   $0x14
80108840:	ff 75 10             	push   0x10(%ebp)
80108843:	ff 75 0c             	push   0xc(%ebp)
80108846:	ff 75 08             	push   0x8(%ebp)
80108849:	e8 1e fe ff ff       	call   8010866c <pci_access_config>
8010884e:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108851:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108854:	a3 88 75 19 80       	mov    %eax,0x80197588
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108859:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108860:	75 5a                	jne    801088bc <pci_init_device+0x1a5>
80108862:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108869:	75 51                	jne    801088bc <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
8010886b:	83 ec 0c             	sub    $0xc,%esp
8010886e:	68 c1 c3 10 80       	push   $0x8010c3c1
80108873:	e8 7c 7b ff ff       	call   801003f4 <cprintf>
80108878:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010887b:	83 ec 0c             	sub    $0xc,%esp
8010887e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108881:	50                   	push   %eax
80108882:	68 f0 00 00 00       	push   $0xf0
80108887:	ff 75 10             	push   0x10(%ebp)
8010888a:	ff 75 0c             	push   0xc(%ebp)
8010888d:	ff 75 08             	push   0x8(%ebp)
80108890:	e8 d7 fd ff ff       	call   8010866c <pci_access_config>
80108895:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108898:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010889b:	83 ec 08             	sub    $0x8,%esp
8010889e:	50                   	push   %eax
8010889f:	68 db c3 10 80       	push   $0x8010c3db
801088a4:	e8 4b 7b ff ff       	call   801003f4 <cprintf>
801088a9:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801088ac:	83 ec 0c             	sub    $0xc,%esp
801088af:	68 74 75 19 80       	push   $0x80197574
801088b4:	e8 09 00 00 00       	call   801088c2 <i8254_init>
801088b9:	83 c4 10             	add    $0x10,%esp
  }
}
801088bc:	90                   	nop
801088bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088c0:	c9                   	leave  
801088c1:	c3                   	ret    

801088c2 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801088c2:	55                   	push   %ebp
801088c3:	89 e5                	mov    %esp,%ebp
801088c5:	53                   	push   %ebx
801088c6:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801088c9:	8b 45 08             	mov    0x8(%ebp),%eax
801088cc:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801088d0:	0f b6 c8             	movzbl %al,%ecx
801088d3:	8b 45 08             	mov    0x8(%ebp),%eax
801088d6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801088da:	0f b6 d0             	movzbl %al,%edx
801088dd:	8b 45 08             	mov    0x8(%ebp),%eax
801088e0:	0f b6 00             	movzbl (%eax),%eax
801088e3:	0f b6 c0             	movzbl %al,%eax
801088e6:	83 ec 0c             	sub    $0xc,%esp
801088e9:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801088ec:	53                   	push   %ebx
801088ed:	6a 04                	push   $0x4
801088ef:	51                   	push   %ecx
801088f0:	52                   	push   %edx
801088f1:	50                   	push   %eax
801088f2:	e8 75 fd ff ff       	call   8010866c <pci_access_config>
801088f7:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801088fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088fd:	83 c8 04             	or     $0x4,%eax
80108900:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108903:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108906:	8b 45 08             	mov    0x8(%ebp),%eax
80108909:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010890d:	0f b6 c8             	movzbl %al,%ecx
80108910:	8b 45 08             	mov    0x8(%ebp),%eax
80108913:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108917:	0f b6 d0             	movzbl %al,%edx
8010891a:	8b 45 08             	mov    0x8(%ebp),%eax
8010891d:	0f b6 00             	movzbl (%eax),%eax
80108920:	0f b6 c0             	movzbl %al,%eax
80108923:	83 ec 0c             	sub    $0xc,%esp
80108926:	53                   	push   %ebx
80108927:	6a 04                	push   $0x4
80108929:	51                   	push   %ecx
8010892a:	52                   	push   %edx
8010892b:	50                   	push   %eax
8010892c:	e8 90 fd ff ff       	call   801086c1 <pci_write_config_register>
80108931:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108934:	8b 45 08             	mov    0x8(%ebp),%eax
80108937:	8b 40 10             	mov    0x10(%eax),%eax
8010893a:	05 00 00 00 40       	add    $0x40000000,%eax
8010893f:	a3 8c 75 19 80       	mov    %eax,0x8019758c
  uint *ctrl = (uint *)base_addr;
80108944:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108949:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010894c:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108951:	05 d8 00 00 00       	add    $0xd8,%eax
80108956:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108959:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010895c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108965:	8b 00                	mov    (%eax),%eax
80108967:	0d 00 00 00 04       	or     $0x4000000,%eax
8010896c:	89 c2                	mov    %eax,%edx
8010896e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108971:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108973:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108976:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010897c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897f:	8b 00                	mov    (%eax),%eax
80108981:	83 c8 40             	or     $0x40,%eax
80108984:	89 c2                	mov    %eax,%edx
80108986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108989:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010898b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898e:	8b 10                	mov    (%eax),%edx
80108990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108993:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108995:	83 ec 0c             	sub    $0xc,%esp
80108998:	68 f0 c3 10 80       	push   $0x8010c3f0
8010899d:	e8 52 7a ff ff       	call   801003f4 <cprintf>
801089a2:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801089a5:	e8 f6 9d ff ff       	call   801027a0 <kalloc>
801089aa:	a3 98 75 19 80       	mov    %eax,0x80197598
  *intr_addr = 0;
801089af:	a1 98 75 19 80       	mov    0x80197598,%eax
801089b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801089ba:	a1 98 75 19 80       	mov    0x80197598,%eax
801089bf:	83 ec 08             	sub    $0x8,%esp
801089c2:	50                   	push   %eax
801089c3:	68 12 c4 10 80       	push   $0x8010c412
801089c8:	e8 27 7a ff ff       	call   801003f4 <cprintf>
801089cd:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801089d0:	e8 50 00 00 00       	call   80108a25 <i8254_init_recv>
  i8254_init_send();
801089d5:	e8 69 03 00 00       	call   80108d43 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801089da:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089e1:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801089e4:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089eb:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801089ee:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089f5:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801089f8:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089ff:	0f b6 c0             	movzbl %al,%eax
80108a02:	83 ec 0c             	sub    $0xc,%esp
80108a05:	53                   	push   %ebx
80108a06:	51                   	push   %ecx
80108a07:	52                   	push   %edx
80108a08:	50                   	push   %eax
80108a09:	68 20 c4 10 80       	push   $0x8010c420
80108a0e:	e8 e1 79 ff ff       	call   801003f4 <cprintf>
80108a13:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108a1f:	90                   	nop
80108a20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a23:	c9                   	leave  
80108a24:	c3                   	ret    

80108a25 <i8254_init_recv>:

void i8254_init_recv(){
80108a25:	55                   	push   %ebp
80108a26:	89 e5                	mov    %esp,%ebp
80108a28:	57                   	push   %edi
80108a29:	56                   	push   %esi
80108a2a:	53                   	push   %ebx
80108a2b:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108a2e:	83 ec 0c             	sub    $0xc,%esp
80108a31:	6a 00                	push   $0x0
80108a33:	e8 e8 04 00 00       	call   80108f20 <i8254_read_eeprom>
80108a38:	83 c4 10             	add    $0x10,%esp
80108a3b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108a3e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a41:	a2 90 75 19 80       	mov    %al,0x80197590
  mac_addr[1] = data_l>>8;
80108a46:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a49:	c1 e8 08             	shr    $0x8,%eax
80108a4c:	a2 91 75 19 80       	mov    %al,0x80197591
  uint data_m = i8254_read_eeprom(0x1);
80108a51:	83 ec 0c             	sub    $0xc,%esp
80108a54:	6a 01                	push   $0x1
80108a56:	e8 c5 04 00 00       	call   80108f20 <i8254_read_eeprom>
80108a5b:	83 c4 10             	add    $0x10,%esp
80108a5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108a61:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a64:	a2 92 75 19 80       	mov    %al,0x80197592
  mac_addr[3] = data_m>>8;
80108a69:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a6c:	c1 e8 08             	shr    $0x8,%eax
80108a6f:	a2 93 75 19 80       	mov    %al,0x80197593
  uint data_h = i8254_read_eeprom(0x2);
80108a74:	83 ec 0c             	sub    $0xc,%esp
80108a77:	6a 02                	push   $0x2
80108a79:	e8 a2 04 00 00       	call   80108f20 <i8254_read_eeprom>
80108a7e:	83 c4 10             	add    $0x10,%esp
80108a81:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108a84:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a87:	a2 94 75 19 80       	mov    %al,0x80197594
  mac_addr[5] = data_h>>8;
80108a8c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a8f:	c1 e8 08             	shr    $0x8,%eax
80108a92:	a2 95 75 19 80       	mov    %al,0x80197595
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108a97:	0f b6 05 95 75 19 80 	movzbl 0x80197595,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a9e:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108aa1:	0f b6 05 94 75 19 80 	movzbl 0x80197594,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108aa8:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108aab:	0f b6 05 93 75 19 80 	movzbl 0x80197593,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ab2:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108ab5:	0f b6 05 92 75 19 80 	movzbl 0x80197592,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108abc:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108abf:	0f b6 05 91 75 19 80 	movzbl 0x80197591,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ac6:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108ac9:	0f b6 05 90 75 19 80 	movzbl 0x80197590,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ad0:	0f b6 c0             	movzbl %al,%eax
80108ad3:	83 ec 04             	sub    $0x4,%esp
80108ad6:	57                   	push   %edi
80108ad7:	56                   	push   %esi
80108ad8:	53                   	push   %ebx
80108ad9:	51                   	push   %ecx
80108ada:	52                   	push   %edx
80108adb:	50                   	push   %eax
80108adc:	68 38 c4 10 80       	push   $0x8010c438
80108ae1:	e8 0e 79 ff ff       	call   801003f4 <cprintf>
80108ae6:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108ae9:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108aee:	05 00 54 00 00       	add    $0x5400,%eax
80108af3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108af6:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108afb:	05 04 54 00 00       	add    $0x5404,%eax
80108b00:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108b03:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b06:	c1 e0 10             	shl    $0x10,%eax
80108b09:	0b 45 d8             	or     -0x28(%ebp),%eax
80108b0c:	89 c2                	mov    %eax,%edx
80108b0e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108b11:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108b13:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b16:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b1b:	89 c2                	mov    %eax,%edx
80108b1d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108b20:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108b22:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b27:	05 00 52 00 00       	add    $0x5200,%eax
80108b2c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108b2f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108b36:	eb 19                	jmp    80108b51 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108b38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b3b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b42:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108b45:	01 d0                	add    %edx,%eax
80108b47:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108b4d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108b51:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108b55:	7e e1                	jle    80108b38 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108b57:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b5c:	05 d0 00 00 00       	add    $0xd0,%eax
80108b61:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b64:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108b67:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108b6d:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b72:	05 c8 00 00 00       	add    $0xc8,%eax
80108b77:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b7a:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108b7d:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108b83:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b88:	05 28 28 00 00       	add    $0x2828,%eax
80108b8d:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108b90:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108b93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108b99:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b9e:	05 00 01 00 00       	add    $0x100,%eax
80108ba3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108ba6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ba9:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108baf:	e8 ec 9b ff ff       	call   801027a0 <kalloc>
80108bb4:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108bb7:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108bbc:	05 00 28 00 00       	add    $0x2800,%eax
80108bc1:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108bc4:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108bc9:	05 04 28 00 00       	add    $0x2804,%eax
80108bce:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108bd1:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108bd6:	05 08 28 00 00       	add    $0x2808,%eax
80108bdb:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108bde:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108be3:	05 10 28 00 00       	add    $0x2810,%eax
80108be8:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108beb:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108bf0:	05 18 28 00 00       	add    $0x2818,%eax
80108bf5:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108bf8:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108bfb:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c01:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108c04:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108c06:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108c09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108c0f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108c12:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108c18:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108c1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108c21:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108c24:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108c2a:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c2d:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c30:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108c37:	eb 73                	jmp    80108cac <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108c39:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c3c:	c1 e0 04             	shl    $0x4,%eax
80108c3f:	89 c2                	mov    %eax,%edx
80108c41:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c44:	01 d0                	add    %edx,%eax
80108c46:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108c4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c50:	c1 e0 04             	shl    $0x4,%eax
80108c53:	89 c2                	mov    %eax,%edx
80108c55:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c58:	01 d0                	add    %edx,%eax
80108c5a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108c60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c63:	c1 e0 04             	shl    $0x4,%eax
80108c66:	89 c2                	mov    %eax,%edx
80108c68:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c6b:	01 d0                	add    %edx,%eax
80108c6d:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108c73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c76:	c1 e0 04             	shl    $0x4,%eax
80108c79:	89 c2                	mov    %eax,%edx
80108c7b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c7e:	01 d0                	add    %edx,%eax
80108c80:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108c84:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c87:	c1 e0 04             	shl    $0x4,%eax
80108c8a:	89 c2                	mov    %eax,%edx
80108c8c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c8f:	01 d0                	add    %edx,%eax
80108c91:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108c95:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c98:	c1 e0 04             	shl    $0x4,%eax
80108c9b:	89 c2                	mov    %eax,%edx
80108c9d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ca0:	01 d0                	add    %edx,%eax
80108ca2:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ca8:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108cac:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108cb3:	7e 84                	jle    80108c39 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108cb5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108cbc:	eb 57                	jmp    80108d15 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108cbe:	e8 dd 9a ff ff       	call   801027a0 <kalloc>
80108cc3:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108cc6:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108cca:	75 12                	jne    80108cde <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108ccc:	83 ec 0c             	sub    $0xc,%esp
80108ccf:	68 58 c4 10 80       	push   $0x8010c458
80108cd4:	e8 1b 77 ff ff       	call   801003f4 <cprintf>
80108cd9:	83 c4 10             	add    $0x10,%esp
      break;
80108cdc:	eb 3d                	jmp    80108d1b <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108cde:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ce1:	c1 e0 04             	shl    $0x4,%eax
80108ce4:	89 c2                	mov    %eax,%edx
80108ce6:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ce9:	01 d0                	add    %edx,%eax
80108ceb:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108cee:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108cf4:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108cf6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cf9:	83 c0 01             	add    $0x1,%eax
80108cfc:	c1 e0 04             	shl    $0x4,%eax
80108cff:	89 c2                	mov    %eax,%edx
80108d01:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d04:	01 d0                	add    %edx,%eax
80108d06:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d09:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d0f:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d11:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108d15:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108d19:	7e a3                	jle    80108cbe <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108d1b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d1e:	8b 00                	mov    (%eax),%eax
80108d20:	83 c8 02             	or     $0x2,%eax
80108d23:	89 c2                	mov    %eax,%edx
80108d25:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d28:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108d2a:	83 ec 0c             	sub    $0xc,%esp
80108d2d:	68 78 c4 10 80       	push   $0x8010c478
80108d32:	e8 bd 76 ff ff       	call   801003f4 <cprintf>
80108d37:	83 c4 10             	add    $0x10,%esp
}
80108d3a:	90                   	nop
80108d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108d3e:	5b                   	pop    %ebx
80108d3f:	5e                   	pop    %esi
80108d40:	5f                   	pop    %edi
80108d41:	5d                   	pop    %ebp
80108d42:	c3                   	ret    

80108d43 <i8254_init_send>:

void i8254_init_send(){
80108d43:	55                   	push   %ebp
80108d44:	89 e5                	mov    %esp,%ebp
80108d46:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108d49:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d4e:	05 28 38 00 00       	add    $0x3828,%eax
80108d53:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d59:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108d5f:	e8 3c 9a ff ff       	call   801027a0 <kalloc>
80108d64:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108d67:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d6c:	05 00 38 00 00       	add    $0x3800,%eax
80108d71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108d74:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d79:	05 04 38 00 00       	add    $0x3804,%eax
80108d7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108d81:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d86:	05 08 38 00 00       	add    $0x3808,%eax
80108d8b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108d8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d91:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d9a:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108d9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108da5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108da8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108dae:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108db3:	05 10 38 00 00       	add    $0x3810,%eax
80108db8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108dbb:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108dc0:	05 18 38 00 00       	add    $0x3818,%eax
80108dc5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108dc8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108dcb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108dd1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108dd4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108dda:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ddd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108de0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108de7:	e9 82 00 00 00       	jmp    80108e6e <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108def:	c1 e0 04             	shl    $0x4,%eax
80108df2:	89 c2                	mov    %eax,%edx
80108df4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108df7:	01 d0                	add    %edx,%eax
80108df9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e03:	c1 e0 04             	shl    $0x4,%eax
80108e06:	89 c2                	mov    %eax,%edx
80108e08:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e0b:	01 d0                	add    %edx,%eax
80108e0d:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e16:	c1 e0 04             	shl    $0x4,%eax
80108e19:	89 c2                	mov    %eax,%edx
80108e1b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e1e:	01 d0                	add    %edx,%eax
80108e20:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e27:	c1 e0 04             	shl    $0x4,%eax
80108e2a:	89 c2                	mov    %eax,%edx
80108e2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e2f:	01 d0                	add    %edx,%eax
80108e31:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e38:	c1 e0 04             	shl    $0x4,%eax
80108e3b:	89 c2                	mov    %eax,%edx
80108e3d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e40:	01 d0                	add    %edx,%eax
80108e42:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e49:	c1 e0 04             	shl    $0x4,%eax
80108e4c:	89 c2                	mov    %eax,%edx
80108e4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e51:	01 d0                	add    %edx,%eax
80108e53:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e5a:	c1 e0 04             	shl    $0x4,%eax
80108e5d:	89 c2                	mov    %eax,%edx
80108e5f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e62:	01 d0                	add    %edx,%eax
80108e64:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e6e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e75:	0f 8e 71 ff ff ff    	jle    80108dec <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e7b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e82:	eb 57                	jmp    80108edb <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108e84:	e8 17 99 ff ff       	call   801027a0 <kalloc>
80108e89:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108e8c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108e90:	75 12                	jne    80108ea4 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108e92:	83 ec 0c             	sub    $0xc,%esp
80108e95:	68 58 c4 10 80       	push   $0x8010c458
80108e9a:	e8 55 75 ff ff       	call   801003f4 <cprintf>
80108e9f:	83 c4 10             	add    $0x10,%esp
      break;
80108ea2:	eb 3d                	jmp    80108ee1 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ea7:	c1 e0 04             	shl    $0x4,%eax
80108eaa:	89 c2                	mov    %eax,%edx
80108eac:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eaf:	01 d0                	add    %edx,%eax
80108eb1:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108eb4:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108eba:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ebf:	83 c0 01             	add    $0x1,%eax
80108ec2:	c1 e0 04             	shl    $0x4,%eax
80108ec5:	89 c2                	mov    %eax,%edx
80108ec7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eca:	01 d0                	add    %edx,%eax
80108ecc:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108ecf:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108ed5:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108ed7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108edb:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108edf:	7e a3                	jle    80108e84 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108ee1:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108ee6:	05 00 04 00 00       	add    $0x400,%eax
80108eeb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108eee:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108ef1:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108ef7:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108efc:	05 10 04 00 00       	add    $0x410,%eax
80108f01:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108f04:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108f07:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108f0d:	83 ec 0c             	sub    $0xc,%esp
80108f10:	68 98 c4 10 80       	push   $0x8010c498
80108f15:	e8 da 74 ff ff       	call   801003f4 <cprintf>
80108f1a:	83 c4 10             	add    $0x10,%esp

}
80108f1d:	90                   	nop
80108f1e:	c9                   	leave  
80108f1f:	c3                   	ret    

80108f20 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108f20:	55                   	push   %ebp
80108f21:	89 e5                	mov    %esp,%ebp
80108f23:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108f26:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f2b:	83 c0 14             	add    $0x14,%eax
80108f2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108f31:	8b 45 08             	mov    0x8(%ebp),%eax
80108f34:	c1 e0 08             	shl    $0x8,%eax
80108f37:	0f b7 c0             	movzwl %ax,%eax
80108f3a:	83 c8 01             	or     $0x1,%eax
80108f3d:	89 c2                	mov    %eax,%edx
80108f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f42:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108f44:	83 ec 0c             	sub    $0xc,%esp
80108f47:	68 b8 c4 10 80       	push   $0x8010c4b8
80108f4c:	e8 a3 74 ff ff       	call   801003f4 <cprintf>
80108f51:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f57:	8b 00                	mov    (%eax),%eax
80108f59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5f:	83 e0 10             	and    $0x10,%eax
80108f62:	85 c0                	test   %eax,%eax
80108f64:	75 02                	jne    80108f68 <i8254_read_eeprom+0x48>
  while(1){
80108f66:	eb dc                	jmp    80108f44 <i8254_read_eeprom+0x24>
      break;
80108f68:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6c:	8b 00                	mov    (%eax),%eax
80108f6e:	c1 e8 10             	shr    $0x10,%eax
}
80108f71:	c9                   	leave  
80108f72:	c3                   	ret    

80108f73 <i8254_recv>:
void i8254_recv(){
80108f73:	55                   	push   %ebp
80108f74:	89 e5                	mov    %esp,%ebp
80108f76:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f79:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f7e:	05 10 28 00 00       	add    $0x2810,%eax
80108f83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f86:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f8b:	05 18 28 00 00       	add    $0x2818,%eax
80108f90:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f93:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f98:	05 00 28 00 00       	add    $0x2800,%eax
80108f9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108fa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fa3:	8b 00                	mov    (%eax),%eax
80108fa5:	05 00 00 00 80       	add    $0x80000000,%eax
80108faa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb0:	8b 10                	mov    (%eax),%edx
80108fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb5:	8b 08                	mov    (%eax),%ecx
80108fb7:	89 d0                	mov    %edx,%eax
80108fb9:	29 c8                	sub    %ecx,%eax
80108fbb:	25 ff 00 00 00       	and    $0xff,%eax
80108fc0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108fc3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108fc7:	7e 37                	jle    80109000 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fcc:	8b 00                	mov    (%eax),%eax
80108fce:	c1 e0 04             	shl    $0x4,%eax
80108fd1:	89 c2                	mov    %eax,%edx
80108fd3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fd6:	01 d0                	add    %edx,%eax
80108fd8:	8b 00                	mov    (%eax),%eax
80108fda:	05 00 00 00 80       	add    $0x80000000,%eax
80108fdf:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe5:	8b 00                	mov    (%eax),%eax
80108fe7:	83 c0 01             	add    $0x1,%eax
80108fea:	0f b6 d0             	movzbl %al,%edx
80108fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ff0:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108ff2:	83 ec 0c             	sub    $0xc,%esp
80108ff5:	ff 75 e0             	push   -0x20(%ebp)
80108ff8:	e8 15 09 00 00       	call   80109912 <eth_proc>
80108ffd:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109000:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109003:	8b 10                	mov    (%eax),%edx
80109005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109008:	8b 00                	mov    (%eax),%eax
8010900a:	39 c2                	cmp    %eax,%edx
8010900c:	75 9f                	jne    80108fad <i8254_recv+0x3a>
      (*rdt)--;
8010900e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109011:	8b 00                	mov    (%eax),%eax
80109013:	8d 50 ff             	lea    -0x1(%eax),%edx
80109016:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109019:	89 10                	mov    %edx,(%eax)
  while(1){
8010901b:	eb 90                	jmp    80108fad <i8254_recv+0x3a>

8010901d <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010901d:	55                   	push   %ebp
8010901e:	89 e5                	mov    %esp,%ebp
80109020:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109023:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80109028:	05 10 38 00 00       	add    $0x3810,%eax
8010902d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109030:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80109035:	05 18 38 00 00       	add    $0x3818,%eax
8010903a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010903d:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80109042:	05 00 38 00 00       	add    $0x3800,%eax
80109047:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010904a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010904d:	8b 00                	mov    (%eax),%eax
8010904f:	05 00 00 00 80       	add    $0x80000000,%eax
80109054:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109057:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010905a:	8b 10                	mov    (%eax),%edx
8010905c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010905f:	8b 08                	mov    (%eax),%ecx
80109061:	89 d0                	mov    %edx,%eax
80109063:	29 c8                	sub    %ecx,%eax
80109065:	0f b6 d0             	movzbl %al,%edx
80109068:	b8 00 01 00 00       	mov    $0x100,%eax
8010906d:	29 d0                	sub    %edx,%eax
8010906f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109075:	8b 00                	mov    (%eax),%eax
80109077:	25 ff 00 00 00       	and    $0xff,%eax
8010907c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010907f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109083:	0f 8e a8 00 00 00    	jle    80109131 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109089:	8b 45 08             	mov    0x8(%ebp),%eax
8010908c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010908f:	89 d1                	mov    %edx,%ecx
80109091:	c1 e1 04             	shl    $0x4,%ecx
80109094:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109097:	01 ca                	add    %ecx,%edx
80109099:	8b 12                	mov    (%edx),%edx
8010909b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090a1:	83 ec 04             	sub    $0x4,%esp
801090a4:	ff 75 0c             	push   0xc(%ebp)
801090a7:	50                   	push   %eax
801090a8:	52                   	push   %edx
801090a9:	e8 27 be ff ff       	call   80104ed5 <memmove>
801090ae:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801090b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090b4:	c1 e0 04             	shl    $0x4,%eax
801090b7:	89 c2                	mov    %eax,%edx
801090b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090bc:	01 d0                	add    %edx,%eax
801090be:	8b 55 0c             	mov    0xc(%ebp),%edx
801090c1:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801090c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090c8:	c1 e0 04             	shl    $0x4,%eax
801090cb:	89 c2                	mov    %eax,%edx
801090cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090d0:	01 d0                	add    %edx,%eax
801090d2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801090d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090d9:	c1 e0 04             	shl    $0x4,%eax
801090dc:	89 c2                	mov    %eax,%edx
801090de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090e1:	01 d0                	add    %edx,%eax
801090e3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801090e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090ea:	c1 e0 04             	shl    $0x4,%eax
801090ed:	89 c2                	mov    %eax,%edx
801090ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090f2:	01 d0                	add    %edx,%eax
801090f4:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801090f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090fb:	c1 e0 04             	shl    $0x4,%eax
801090fe:	89 c2                	mov    %eax,%edx
80109100:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109103:	01 d0                	add    %edx,%eax
80109105:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
8010910b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010910e:	c1 e0 04             	shl    $0x4,%eax
80109111:	89 c2                	mov    %eax,%edx
80109113:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109116:	01 d0                	add    %edx,%eax
80109118:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
8010911c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010911f:	8b 00                	mov    (%eax),%eax
80109121:	83 c0 01             	add    $0x1,%eax
80109124:	0f b6 d0             	movzbl %al,%edx
80109127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010912a:	89 10                	mov    %edx,(%eax)
    return len;
8010912c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010912f:	eb 05                	jmp    80109136 <i8254_send+0x119>
  }else{
    return -1;
80109131:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109136:	c9                   	leave  
80109137:	c3                   	ret    

80109138 <i8254_intr>:

void i8254_intr(){
80109138:	55                   	push   %ebp
80109139:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
8010913b:	a1 98 75 19 80       	mov    0x80197598,%eax
80109140:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109146:	90                   	nop
80109147:	5d                   	pop    %ebp
80109148:	c3                   	ret    

80109149 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109149:	55                   	push   %ebp
8010914a:	89 e5                	mov    %esp,%ebp
8010914c:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010914f:	8b 45 08             	mov    0x8(%ebp),%eax
80109152:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109158:	0f b7 00             	movzwl (%eax),%eax
8010915b:	66 3d 00 01          	cmp    $0x100,%ax
8010915f:	74 0a                	je     8010916b <arp_proc+0x22>
80109161:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109166:	e9 4f 01 00 00       	jmp    801092ba <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
8010916b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916e:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109172:	66 83 f8 08          	cmp    $0x8,%ax
80109176:	74 0a                	je     80109182 <arp_proc+0x39>
80109178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010917d:	e9 38 01 00 00       	jmp    801092ba <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109185:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109189:	3c 06                	cmp    $0x6,%al
8010918b:	74 0a                	je     80109197 <arp_proc+0x4e>
8010918d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109192:	e9 23 01 00 00       	jmp    801092ba <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010919a:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010919e:	3c 04                	cmp    $0x4,%al
801091a0:	74 0a                	je     801091ac <arp_proc+0x63>
801091a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091a7:	e9 0e 01 00 00       	jmp    801092ba <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801091ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091af:	83 c0 18             	add    $0x18,%eax
801091b2:	83 ec 04             	sub    $0x4,%esp
801091b5:	6a 04                	push   $0x4
801091b7:	50                   	push   %eax
801091b8:	68 e4 f4 10 80       	push   $0x8010f4e4
801091bd:	e8 bb bc ff ff       	call   80104e7d <memcmp>
801091c2:	83 c4 10             	add    $0x10,%esp
801091c5:	85 c0                	test   %eax,%eax
801091c7:	74 27                	je     801091f0 <arp_proc+0xa7>
801091c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cc:	83 c0 0e             	add    $0xe,%eax
801091cf:	83 ec 04             	sub    $0x4,%esp
801091d2:	6a 04                	push   $0x4
801091d4:	50                   	push   %eax
801091d5:	68 e4 f4 10 80       	push   $0x8010f4e4
801091da:	e8 9e bc ff ff       	call   80104e7d <memcmp>
801091df:	83 c4 10             	add    $0x10,%esp
801091e2:	85 c0                	test   %eax,%eax
801091e4:	74 0a                	je     801091f0 <arp_proc+0xa7>
801091e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091eb:	e9 ca 00 00 00       	jmp    801092ba <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801091f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801091f7:	66 3d 00 01          	cmp    $0x100,%ax
801091fb:	75 69                	jne    80109266 <arp_proc+0x11d>
801091fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109200:	83 c0 18             	add    $0x18,%eax
80109203:	83 ec 04             	sub    $0x4,%esp
80109206:	6a 04                	push   $0x4
80109208:	50                   	push   %eax
80109209:	68 e4 f4 10 80       	push   $0x8010f4e4
8010920e:	e8 6a bc ff ff       	call   80104e7d <memcmp>
80109213:	83 c4 10             	add    $0x10,%esp
80109216:	85 c0                	test   %eax,%eax
80109218:	75 4c                	jne    80109266 <arp_proc+0x11d>
    uint send = (uint)kalloc();
8010921a:	e8 81 95 ff ff       	call   801027a0 <kalloc>
8010921f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109222:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109229:	83 ec 04             	sub    $0x4,%esp
8010922c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010922f:	50                   	push   %eax
80109230:	ff 75 f0             	push   -0x10(%ebp)
80109233:	ff 75 f4             	push   -0xc(%ebp)
80109236:	e8 1f 04 00 00       	call   8010965a <arp_reply_pkt_create>
8010923b:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010923e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109241:	83 ec 08             	sub    $0x8,%esp
80109244:	50                   	push   %eax
80109245:	ff 75 f0             	push   -0x10(%ebp)
80109248:	e8 d0 fd ff ff       	call   8010901d <i8254_send>
8010924d:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109250:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109253:	83 ec 0c             	sub    $0xc,%esp
80109256:	50                   	push   %eax
80109257:	e8 aa 94 ff ff       	call   80102706 <kfree>
8010925c:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010925f:	b8 02 00 00 00       	mov    $0x2,%eax
80109264:	eb 54                	jmp    801092ba <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109269:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010926d:	66 3d 00 02          	cmp    $0x200,%ax
80109271:	75 42                	jne    801092b5 <arp_proc+0x16c>
80109273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109276:	83 c0 18             	add    $0x18,%eax
80109279:	83 ec 04             	sub    $0x4,%esp
8010927c:	6a 04                	push   $0x4
8010927e:	50                   	push   %eax
8010927f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109284:	e8 f4 bb ff ff       	call   80104e7d <memcmp>
80109289:	83 c4 10             	add    $0x10,%esp
8010928c:	85 c0                	test   %eax,%eax
8010928e:	75 25                	jne    801092b5 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80109290:	83 ec 0c             	sub    $0xc,%esp
80109293:	68 bc c4 10 80       	push   $0x8010c4bc
80109298:	e8 57 71 ff ff       	call   801003f4 <cprintf>
8010929d:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801092a0:	83 ec 0c             	sub    $0xc,%esp
801092a3:	ff 75 f4             	push   -0xc(%ebp)
801092a6:	e8 af 01 00 00       	call   8010945a <arp_table_update>
801092ab:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801092ae:	b8 01 00 00 00       	mov    $0x1,%eax
801092b3:	eb 05                	jmp    801092ba <arp_proc+0x171>
  }else{
    return -1;
801092b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801092ba:	c9                   	leave  
801092bb:	c3                   	ret    

801092bc <arp_scan>:

void arp_scan(){
801092bc:	55                   	push   %ebp
801092bd:	89 e5                	mov    %esp,%ebp
801092bf:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801092c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801092c9:	eb 6f                	jmp    8010933a <arp_scan+0x7e>
    uint send = (uint)kalloc();
801092cb:	e8 d0 94 ff ff       	call   801027a0 <kalloc>
801092d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801092d3:	83 ec 04             	sub    $0x4,%esp
801092d6:	ff 75 f4             	push   -0xc(%ebp)
801092d9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801092dc:	50                   	push   %eax
801092dd:	ff 75 ec             	push   -0x14(%ebp)
801092e0:	e8 62 00 00 00       	call   80109347 <arp_broadcast>
801092e5:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801092e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092eb:	83 ec 08             	sub    $0x8,%esp
801092ee:	50                   	push   %eax
801092ef:	ff 75 ec             	push   -0x14(%ebp)
801092f2:	e8 26 fd ff ff       	call   8010901d <i8254_send>
801092f7:	83 c4 10             	add    $0x10,%esp
801092fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801092fd:	eb 22                	jmp    80109321 <arp_scan+0x65>
      microdelay(1);
801092ff:	83 ec 0c             	sub    $0xc,%esp
80109302:	6a 01                	push   $0x1
80109304:	e8 2e 98 ff ff       	call   80102b37 <microdelay>
80109309:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010930c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010930f:	83 ec 08             	sub    $0x8,%esp
80109312:	50                   	push   %eax
80109313:	ff 75 ec             	push   -0x14(%ebp)
80109316:	e8 02 fd ff ff       	call   8010901d <i8254_send>
8010931b:	83 c4 10             	add    $0x10,%esp
8010931e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109321:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109325:	74 d8                	je     801092ff <arp_scan+0x43>
    }
    kfree((char *)send);
80109327:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010932a:	83 ec 0c             	sub    $0xc,%esp
8010932d:	50                   	push   %eax
8010932e:	e8 d3 93 ff ff       	call   80102706 <kfree>
80109333:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109336:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010933a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109341:	7e 88                	jle    801092cb <arp_scan+0xf>
  }
}
80109343:	90                   	nop
80109344:	90                   	nop
80109345:	c9                   	leave  
80109346:	c3                   	ret    

80109347 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109347:	55                   	push   %ebp
80109348:	89 e5                	mov    %esp,%ebp
8010934a:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
8010934d:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109351:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109355:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109359:	8b 45 10             	mov    0x10(%ebp),%eax
8010935c:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010935f:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109366:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
8010936c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109373:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109379:	8b 45 0c             	mov    0xc(%ebp),%eax
8010937c:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109382:	8b 45 08             	mov    0x8(%ebp),%eax
80109385:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109388:	8b 45 08             	mov    0x8(%ebp),%eax
8010938b:	83 c0 0e             	add    $0xe,%eax
8010938e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109394:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939b:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010939f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a2:	83 ec 04             	sub    $0x4,%esp
801093a5:	6a 06                	push   $0x6
801093a7:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801093aa:	52                   	push   %edx
801093ab:	50                   	push   %eax
801093ac:	e8 24 bb ff ff       	call   80104ed5 <memmove>
801093b1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801093b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b7:	83 c0 06             	add    $0x6,%eax
801093ba:	83 ec 04             	sub    $0x4,%esp
801093bd:	6a 06                	push   $0x6
801093bf:	68 90 75 19 80       	push   $0x80197590
801093c4:	50                   	push   %eax
801093c5:	e8 0b bb ff ff       	call   80104ed5 <memmove>
801093ca:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801093cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d0:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801093d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d8:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801093de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e1:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801093e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e8:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801093ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ef:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801093f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093f8:	8d 50 12             	lea    0x12(%eax),%edx
801093fb:	83 ec 04             	sub    $0x4,%esp
801093fe:	6a 06                	push   $0x6
80109400:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109403:	50                   	push   %eax
80109404:	52                   	push   %edx
80109405:	e8 cb ba ff ff       	call   80104ed5 <memmove>
8010940a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010940d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109410:	8d 50 18             	lea    0x18(%eax),%edx
80109413:	83 ec 04             	sub    $0x4,%esp
80109416:	6a 04                	push   $0x4
80109418:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010941b:	50                   	push   %eax
8010941c:	52                   	push   %edx
8010941d:	e8 b3 ba ff ff       	call   80104ed5 <memmove>
80109422:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109428:	83 c0 08             	add    $0x8,%eax
8010942b:	83 ec 04             	sub    $0x4,%esp
8010942e:	6a 06                	push   $0x6
80109430:	68 90 75 19 80       	push   $0x80197590
80109435:	50                   	push   %eax
80109436:	e8 9a ba ff ff       	call   80104ed5 <memmove>
8010943b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010943e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109441:	83 c0 0e             	add    $0xe,%eax
80109444:	83 ec 04             	sub    $0x4,%esp
80109447:	6a 04                	push   $0x4
80109449:	68 e4 f4 10 80       	push   $0x8010f4e4
8010944e:	50                   	push   %eax
8010944f:	e8 81 ba ff ff       	call   80104ed5 <memmove>
80109454:	83 c4 10             	add    $0x10,%esp
}
80109457:	90                   	nop
80109458:	c9                   	leave  
80109459:	c3                   	ret    

8010945a <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010945a:	55                   	push   %ebp
8010945b:	89 e5                	mov    %esp,%ebp
8010945d:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109460:	8b 45 08             	mov    0x8(%ebp),%eax
80109463:	83 c0 0e             	add    $0xe,%eax
80109466:	83 ec 0c             	sub    $0xc,%esp
80109469:	50                   	push   %eax
8010946a:	e8 bc 00 00 00       	call   8010952b <arp_table_search>
8010946f:	83 c4 10             	add    $0x10,%esp
80109472:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109475:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109479:	78 2d                	js     801094a8 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010947b:	8b 45 08             	mov    0x8(%ebp),%eax
8010947e:	8d 48 08             	lea    0x8(%eax),%ecx
80109481:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109484:	89 d0                	mov    %edx,%eax
80109486:	c1 e0 02             	shl    $0x2,%eax
80109489:	01 d0                	add    %edx,%eax
8010948b:	01 c0                	add    %eax,%eax
8010948d:	01 d0                	add    %edx,%eax
8010948f:	05 a0 75 19 80       	add    $0x801975a0,%eax
80109494:	83 c0 04             	add    $0x4,%eax
80109497:	83 ec 04             	sub    $0x4,%esp
8010949a:	6a 06                	push   $0x6
8010949c:	51                   	push   %ecx
8010949d:	50                   	push   %eax
8010949e:	e8 32 ba ff ff       	call   80104ed5 <memmove>
801094a3:	83 c4 10             	add    $0x10,%esp
801094a6:	eb 70                	jmp    80109518 <arp_table_update+0xbe>
  }else{
    index += 1;
801094a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801094ac:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801094af:	8b 45 08             	mov    0x8(%ebp),%eax
801094b2:	8d 48 08             	lea    0x8(%eax),%ecx
801094b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094b8:	89 d0                	mov    %edx,%eax
801094ba:	c1 e0 02             	shl    $0x2,%eax
801094bd:	01 d0                	add    %edx,%eax
801094bf:	01 c0                	add    %eax,%eax
801094c1:	01 d0                	add    %edx,%eax
801094c3:	05 a0 75 19 80       	add    $0x801975a0,%eax
801094c8:	83 c0 04             	add    $0x4,%eax
801094cb:	83 ec 04             	sub    $0x4,%esp
801094ce:	6a 06                	push   $0x6
801094d0:	51                   	push   %ecx
801094d1:	50                   	push   %eax
801094d2:	e8 fe b9 ff ff       	call   80104ed5 <memmove>
801094d7:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801094da:	8b 45 08             	mov    0x8(%ebp),%eax
801094dd:	8d 48 0e             	lea    0xe(%eax),%ecx
801094e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094e3:	89 d0                	mov    %edx,%eax
801094e5:	c1 e0 02             	shl    $0x2,%eax
801094e8:	01 d0                	add    %edx,%eax
801094ea:	01 c0                	add    %eax,%eax
801094ec:	01 d0                	add    %edx,%eax
801094ee:	05 a0 75 19 80       	add    $0x801975a0,%eax
801094f3:	83 ec 04             	sub    $0x4,%esp
801094f6:	6a 04                	push   $0x4
801094f8:	51                   	push   %ecx
801094f9:	50                   	push   %eax
801094fa:	e8 d6 b9 ff ff       	call   80104ed5 <memmove>
801094ff:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109502:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109505:	89 d0                	mov    %edx,%eax
80109507:	c1 e0 02             	shl    $0x2,%eax
8010950a:	01 d0                	add    %edx,%eax
8010950c:	01 c0                	add    %eax,%eax
8010950e:	01 d0                	add    %edx,%eax
80109510:	05 aa 75 19 80       	add    $0x801975aa,%eax
80109515:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109518:	83 ec 0c             	sub    $0xc,%esp
8010951b:	68 a0 75 19 80       	push   $0x801975a0
80109520:	e8 83 00 00 00       	call   801095a8 <print_arp_table>
80109525:	83 c4 10             	add    $0x10,%esp
}
80109528:	90                   	nop
80109529:	c9                   	leave  
8010952a:	c3                   	ret    

8010952b <arp_table_search>:

int arp_table_search(uchar *ip){
8010952b:	55                   	push   %ebp
8010952c:	89 e5                	mov    %esp,%ebp
8010952e:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109531:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109538:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010953f:	eb 59                	jmp    8010959a <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109541:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109544:	89 d0                	mov    %edx,%eax
80109546:	c1 e0 02             	shl    $0x2,%eax
80109549:	01 d0                	add    %edx,%eax
8010954b:	01 c0                	add    %eax,%eax
8010954d:	01 d0                	add    %edx,%eax
8010954f:	05 a0 75 19 80       	add    $0x801975a0,%eax
80109554:	83 ec 04             	sub    $0x4,%esp
80109557:	6a 04                	push   $0x4
80109559:	ff 75 08             	push   0x8(%ebp)
8010955c:	50                   	push   %eax
8010955d:	e8 1b b9 ff ff       	call   80104e7d <memcmp>
80109562:	83 c4 10             	add    $0x10,%esp
80109565:	85 c0                	test   %eax,%eax
80109567:	75 05                	jne    8010956e <arp_table_search+0x43>
      return i;
80109569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956c:	eb 38                	jmp    801095a6 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010956e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109571:	89 d0                	mov    %edx,%eax
80109573:	c1 e0 02             	shl    $0x2,%eax
80109576:	01 d0                	add    %edx,%eax
80109578:	01 c0                	add    %eax,%eax
8010957a:	01 d0                	add    %edx,%eax
8010957c:	05 aa 75 19 80       	add    $0x801975aa,%eax
80109581:	0f b6 00             	movzbl (%eax),%eax
80109584:	84 c0                	test   %al,%al
80109586:	75 0e                	jne    80109596 <arp_table_search+0x6b>
80109588:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010958c:	75 08                	jne    80109596 <arp_table_search+0x6b>
      empty = -i;
8010958e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109591:	f7 d8                	neg    %eax
80109593:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109596:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010959a:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010959e:	7e a1                	jle    80109541 <arp_table_search+0x16>
    }
  }
  return empty-1;
801095a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a3:	83 e8 01             	sub    $0x1,%eax
}
801095a6:	c9                   	leave  
801095a7:	c3                   	ret    

801095a8 <print_arp_table>:

void print_arp_table(){
801095a8:	55                   	push   %ebp
801095a9:	89 e5                	mov    %esp,%ebp
801095ab:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801095ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801095b5:	e9 92 00 00 00       	jmp    8010964c <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801095ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095bd:	89 d0                	mov    %edx,%eax
801095bf:	c1 e0 02             	shl    $0x2,%eax
801095c2:	01 d0                	add    %edx,%eax
801095c4:	01 c0                	add    %eax,%eax
801095c6:	01 d0                	add    %edx,%eax
801095c8:	05 aa 75 19 80       	add    $0x801975aa,%eax
801095cd:	0f b6 00             	movzbl (%eax),%eax
801095d0:	84 c0                	test   %al,%al
801095d2:	74 74                	je     80109648 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801095d4:	83 ec 08             	sub    $0x8,%esp
801095d7:	ff 75 f4             	push   -0xc(%ebp)
801095da:	68 cf c4 10 80       	push   $0x8010c4cf
801095df:	e8 10 6e ff ff       	call   801003f4 <cprintf>
801095e4:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801095e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095ea:	89 d0                	mov    %edx,%eax
801095ec:	c1 e0 02             	shl    $0x2,%eax
801095ef:	01 d0                	add    %edx,%eax
801095f1:	01 c0                	add    %eax,%eax
801095f3:	01 d0                	add    %edx,%eax
801095f5:	05 a0 75 19 80       	add    $0x801975a0,%eax
801095fa:	83 ec 0c             	sub    $0xc,%esp
801095fd:	50                   	push   %eax
801095fe:	e8 54 02 00 00       	call   80109857 <print_ipv4>
80109603:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109606:	83 ec 0c             	sub    $0xc,%esp
80109609:	68 de c4 10 80       	push   $0x8010c4de
8010960e:	e8 e1 6d ff ff       	call   801003f4 <cprintf>
80109613:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109616:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109619:	89 d0                	mov    %edx,%eax
8010961b:	c1 e0 02             	shl    $0x2,%eax
8010961e:	01 d0                	add    %edx,%eax
80109620:	01 c0                	add    %eax,%eax
80109622:	01 d0                	add    %edx,%eax
80109624:	05 a0 75 19 80       	add    $0x801975a0,%eax
80109629:	83 c0 04             	add    $0x4,%eax
8010962c:	83 ec 0c             	sub    $0xc,%esp
8010962f:	50                   	push   %eax
80109630:	e8 70 02 00 00       	call   801098a5 <print_mac>
80109635:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109638:	83 ec 0c             	sub    $0xc,%esp
8010963b:	68 e0 c4 10 80       	push   $0x8010c4e0
80109640:	e8 af 6d ff ff       	call   801003f4 <cprintf>
80109645:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109648:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010964c:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109650:	0f 8e 64 ff ff ff    	jle    801095ba <print_arp_table+0x12>
    }
  }
}
80109656:	90                   	nop
80109657:	90                   	nop
80109658:	c9                   	leave  
80109659:	c3                   	ret    

8010965a <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010965a:	55                   	push   %ebp
8010965b:	89 e5                	mov    %esp,%ebp
8010965d:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109660:	8b 45 10             	mov    0x10(%ebp),%eax
80109663:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109669:	8b 45 0c             	mov    0xc(%ebp),%eax
8010966c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010966f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109672:	83 c0 0e             	add    $0xe,%eax
80109675:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010967b:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010967f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109682:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109686:	8b 45 08             	mov    0x8(%ebp),%eax
80109689:	8d 50 08             	lea    0x8(%eax),%edx
8010968c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010968f:	83 ec 04             	sub    $0x4,%esp
80109692:	6a 06                	push   $0x6
80109694:	52                   	push   %edx
80109695:	50                   	push   %eax
80109696:	e8 3a b8 ff ff       	call   80104ed5 <memmove>
8010969b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010969e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096a1:	83 c0 06             	add    $0x6,%eax
801096a4:	83 ec 04             	sub    $0x4,%esp
801096a7:	6a 06                	push   $0x6
801096a9:	68 90 75 19 80       	push   $0x80197590
801096ae:	50                   	push   %eax
801096af:	e8 21 b8 ff ff       	call   80104ed5 <memmove>
801096b4:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801096b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096ba:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801096bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096c2:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801096c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096cb:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801096cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096d2:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801096d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096d9:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801096df:	8b 45 08             	mov    0x8(%ebp),%eax
801096e2:	8d 50 08             	lea    0x8(%eax),%edx
801096e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096e8:	83 c0 12             	add    $0x12,%eax
801096eb:	83 ec 04             	sub    $0x4,%esp
801096ee:	6a 06                	push   $0x6
801096f0:	52                   	push   %edx
801096f1:	50                   	push   %eax
801096f2:	e8 de b7 ff ff       	call   80104ed5 <memmove>
801096f7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801096fa:	8b 45 08             	mov    0x8(%ebp),%eax
801096fd:	8d 50 0e             	lea    0xe(%eax),%edx
80109700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109703:	83 c0 18             	add    $0x18,%eax
80109706:	83 ec 04             	sub    $0x4,%esp
80109709:	6a 04                	push   $0x4
8010970b:	52                   	push   %edx
8010970c:	50                   	push   %eax
8010970d:	e8 c3 b7 ff ff       	call   80104ed5 <memmove>
80109712:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109715:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109718:	83 c0 08             	add    $0x8,%eax
8010971b:	83 ec 04             	sub    $0x4,%esp
8010971e:	6a 06                	push   $0x6
80109720:	68 90 75 19 80       	push   $0x80197590
80109725:	50                   	push   %eax
80109726:	e8 aa b7 ff ff       	call   80104ed5 <memmove>
8010972b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010972e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109731:	83 c0 0e             	add    $0xe,%eax
80109734:	83 ec 04             	sub    $0x4,%esp
80109737:	6a 04                	push   $0x4
80109739:	68 e4 f4 10 80       	push   $0x8010f4e4
8010973e:	50                   	push   %eax
8010973f:	e8 91 b7 ff ff       	call   80104ed5 <memmove>
80109744:	83 c4 10             	add    $0x10,%esp
}
80109747:	90                   	nop
80109748:	c9                   	leave  
80109749:	c3                   	ret    

8010974a <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010974a:	55                   	push   %ebp
8010974b:	89 e5                	mov    %esp,%ebp
8010974d:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109750:	83 ec 0c             	sub    $0xc,%esp
80109753:	68 e2 c4 10 80       	push   $0x8010c4e2
80109758:	e8 97 6c ff ff       	call   801003f4 <cprintf>
8010975d:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109760:	8b 45 08             	mov    0x8(%ebp),%eax
80109763:	83 c0 0e             	add    $0xe,%eax
80109766:	83 ec 0c             	sub    $0xc,%esp
80109769:	50                   	push   %eax
8010976a:	e8 e8 00 00 00       	call   80109857 <print_ipv4>
8010976f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109772:	83 ec 0c             	sub    $0xc,%esp
80109775:	68 e0 c4 10 80       	push   $0x8010c4e0
8010977a:	e8 75 6c ff ff       	call   801003f4 <cprintf>
8010977f:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109782:	8b 45 08             	mov    0x8(%ebp),%eax
80109785:	83 c0 08             	add    $0x8,%eax
80109788:	83 ec 0c             	sub    $0xc,%esp
8010978b:	50                   	push   %eax
8010978c:	e8 14 01 00 00       	call   801098a5 <print_mac>
80109791:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109794:	83 ec 0c             	sub    $0xc,%esp
80109797:	68 e0 c4 10 80       	push   $0x8010c4e0
8010979c:	e8 53 6c ff ff       	call   801003f4 <cprintf>
801097a1:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801097a4:	83 ec 0c             	sub    $0xc,%esp
801097a7:	68 f9 c4 10 80       	push   $0x8010c4f9
801097ac:	e8 43 6c ff ff       	call   801003f4 <cprintf>
801097b1:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801097b4:	8b 45 08             	mov    0x8(%ebp),%eax
801097b7:	83 c0 18             	add    $0x18,%eax
801097ba:	83 ec 0c             	sub    $0xc,%esp
801097bd:	50                   	push   %eax
801097be:	e8 94 00 00 00       	call   80109857 <print_ipv4>
801097c3:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097c6:	83 ec 0c             	sub    $0xc,%esp
801097c9:	68 e0 c4 10 80       	push   $0x8010c4e0
801097ce:	e8 21 6c ff ff       	call   801003f4 <cprintf>
801097d3:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801097d6:	8b 45 08             	mov    0x8(%ebp),%eax
801097d9:	83 c0 12             	add    $0x12,%eax
801097dc:	83 ec 0c             	sub    $0xc,%esp
801097df:	50                   	push   %eax
801097e0:	e8 c0 00 00 00       	call   801098a5 <print_mac>
801097e5:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097e8:	83 ec 0c             	sub    $0xc,%esp
801097eb:	68 e0 c4 10 80       	push   $0x8010c4e0
801097f0:	e8 ff 6b ff ff       	call   801003f4 <cprintf>
801097f5:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801097f8:	83 ec 0c             	sub    $0xc,%esp
801097fb:	68 10 c5 10 80       	push   $0x8010c510
80109800:	e8 ef 6b ff ff       	call   801003f4 <cprintf>
80109805:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109808:	8b 45 08             	mov    0x8(%ebp),%eax
8010980b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010980f:	66 3d 00 01          	cmp    $0x100,%ax
80109813:	75 12                	jne    80109827 <print_arp_info+0xdd>
80109815:	83 ec 0c             	sub    $0xc,%esp
80109818:	68 1c c5 10 80       	push   $0x8010c51c
8010981d:	e8 d2 6b ff ff       	call   801003f4 <cprintf>
80109822:	83 c4 10             	add    $0x10,%esp
80109825:	eb 1d                	jmp    80109844 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109827:	8b 45 08             	mov    0x8(%ebp),%eax
8010982a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010982e:	66 3d 00 02          	cmp    $0x200,%ax
80109832:	75 10                	jne    80109844 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109834:	83 ec 0c             	sub    $0xc,%esp
80109837:	68 25 c5 10 80       	push   $0x8010c525
8010983c:	e8 b3 6b ff ff       	call   801003f4 <cprintf>
80109841:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109844:	83 ec 0c             	sub    $0xc,%esp
80109847:	68 e0 c4 10 80       	push   $0x8010c4e0
8010984c:	e8 a3 6b ff ff       	call   801003f4 <cprintf>
80109851:	83 c4 10             	add    $0x10,%esp
}
80109854:	90                   	nop
80109855:	c9                   	leave  
80109856:	c3                   	ret    

80109857 <print_ipv4>:

void print_ipv4(uchar *ip){
80109857:	55                   	push   %ebp
80109858:	89 e5                	mov    %esp,%ebp
8010985a:	53                   	push   %ebx
8010985b:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010985e:	8b 45 08             	mov    0x8(%ebp),%eax
80109861:	83 c0 03             	add    $0x3,%eax
80109864:	0f b6 00             	movzbl (%eax),%eax
80109867:	0f b6 d8             	movzbl %al,%ebx
8010986a:	8b 45 08             	mov    0x8(%ebp),%eax
8010986d:	83 c0 02             	add    $0x2,%eax
80109870:	0f b6 00             	movzbl (%eax),%eax
80109873:	0f b6 c8             	movzbl %al,%ecx
80109876:	8b 45 08             	mov    0x8(%ebp),%eax
80109879:	83 c0 01             	add    $0x1,%eax
8010987c:	0f b6 00             	movzbl (%eax),%eax
8010987f:	0f b6 d0             	movzbl %al,%edx
80109882:	8b 45 08             	mov    0x8(%ebp),%eax
80109885:	0f b6 00             	movzbl (%eax),%eax
80109888:	0f b6 c0             	movzbl %al,%eax
8010988b:	83 ec 0c             	sub    $0xc,%esp
8010988e:	53                   	push   %ebx
8010988f:	51                   	push   %ecx
80109890:	52                   	push   %edx
80109891:	50                   	push   %eax
80109892:	68 2c c5 10 80       	push   $0x8010c52c
80109897:	e8 58 6b ff ff       	call   801003f4 <cprintf>
8010989c:	83 c4 20             	add    $0x20,%esp
}
8010989f:	90                   	nop
801098a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801098a3:	c9                   	leave  
801098a4:	c3                   	ret    

801098a5 <print_mac>:

void print_mac(uchar *mac){
801098a5:	55                   	push   %ebp
801098a6:	89 e5                	mov    %esp,%ebp
801098a8:	57                   	push   %edi
801098a9:	56                   	push   %esi
801098aa:	53                   	push   %ebx
801098ab:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801098ae:	8b 45 08             	mov    0x8(%ebp),%eax
801098b1:	83 c0 05             	add    $0x5,%eax
801098b4:	0f b6 00             	movzbl (%eax),%eax
801098b7:	0f b6 f8             	movzbl %al,%edi
801098ba:	8b 45 08             	mov    0x8(%ebp),%eax
801098bd:	83 c0 04             	add    $0x4,%eax
801098c0:	0f b6 00             	movzbl (%eax),%eax
801098c3:	0f b6 f0             	movzbl %al,%esi
801098c6:	8b 45 08             	mov    0x8(%ebp),%eax
801098c9:	83 c0 03             	add    $0x3,%eax
801098cc:	0f b6 00             	movzbl (%eax),%eax
801098cf:	0f b6 d8             	movzbl %al,%ebx
801098d2:	8b 45 08             	mov    0x8(%ebp),%eax
801098d5:	83 c0 02             	add    $0x2,%eax
801098d8:	0f b6 00             	movzbl (%eax),%eax
801098db:	0f b6 c8             	movzbl %al,%ecx
801098de:	8b 45 08             	mov    0x8(%ebp),%eax
801098e1:	83 c0 01             	add    $0x1,%eax
801098e4:	0f b6 00             	movzbl (%eax),%eax
801098e7:	0f b6 d0             	movzbl %al,%edx
801098ea:	8b 45 08             	mov    0x8(%ebp),%eax
801098ed:	0f b6 00             	movzbl (%eax),%eax
801098f0:	0f b6 c0             	movzbl %al,%eax
801098f3:	83 ec 04             	sub    $0x4,%esp
801098f6:	57                   	push   %edi
801098f7:	56                   	push   %esi
801098f8:	53                   	push   %ebx
801098f9:	51                   	push   %ecx
801098fa:	52                   	push   %edx
801098fb:	50                   	push   %eax
801098fc:	68 44 c5 10 80       	push   $0x8010c544
80109901:	e8 ee 6a ff ff       	call   801003f4 <cprintf>
80109906:	83 c4 20             	add    $0x20,%esp
}
80109909:	90                   	nop
8010990a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010990d:	5b                   	pop    %ebx
8010990e:	5e                   	pop    %esi
8010990f:	5f                   	pop    %edi
80109910:	5d                   	pop    %ebp
80109911:	c3                   	ret    

80109912 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109912:	55                   	push   %ebp
80109913:	89 e5                	mov    %esp,%ebp
80109915:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109918:	8b 45 08             	mov    0x8(%ebp),%eax
8010991b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010991e:	8b 45 08             	mov    0x8(%ebp),%eax
80109921:	83 c0 0e             	add    $0xe,%eax
80109924:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010992a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010992e:	3c 08                	cmp    $0x8,%al
80109930:	75 1b                	jne    8010994d <eth_proc+0x3b>
80109932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109935:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109939:	3c 06                	cmp    $0x6,%al
8010993b:	75 10                	jne    8010994d <eth_proc+0x3b>
    arp_proc(pkt_addr);
8010993d:	83 ec 0c             	sub    $0xc,%esp
80109940:	ff 75 f0             	push   -0x10(%ebp)
80109943:	e8 01 f8 ff ff       	call   80109149 <arp_proc>
80109948:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010994b:	eb 24                	jmp    80109971 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010994d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109950:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109954:	3c 08                	cmp    $0x8,%al
80109956:	75 19                	jne    80109971 <eth_proc+0x5f>
80109958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010995b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010995f:	84 c0                	test   %al,%al
80109961:	75 0e                	jne    80109971 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109963:	83 ec 0c             	sub    $0xc,%esp
80109966:	ff 75 08             	push   0x8(%ebp)
80109969:	e8 a3 00 00 00       	call   80109a11 <ipv4_proc>
8010996e:	83 c4 10             	add    $0x10,%esp
}
80109971:	90                   	nop
80109972:	c9                   	leave  
80109973:	c3                   	ret    

80109974 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109974:	55                   	push   %ebp
80109975:	89 e5                	mov    %esp,%ebp
80109977:	83 ec 04             	sub    $0x4,%esp
8010997a:	8b 45 08             	mov    0x8(%ebp),%eax
8010997d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109981:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109985:	c1 e0 08             	shl    $0x8,%eax
80109988:	89 c2                	mov    %eax,%edx
8010998a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010998e:	66 c1 e8 08          	shr    $0x8,%ax
80109992:	01 d0                	add    %edx,%eax
}
80109994:	c9                   	leave  
80109995:	c3                   	ret    

80109996 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109996:	55                   	push   %ebp
80109997:	89 e5                	mov    %esp,%ebp
80109999:	83 ec 04             	sub    $0x4,%esp
8010999c:	8b 45 08             	mov    0x8(%ebp),%eax
8010999f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801099a3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099a7:	c1 e0 08             	shl    $0x8,%eax
801099aa:	89 c2                	mov    %eax,%edx
801099ac:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099b0:	66 c1 e8 08          	shr    $0x8,%ax
801099b4:	01 d0                	add    %edx,%eax
}
801099b6:	c9                   	leave  
801099b7:	c3                   	ret    

801099b8 <H2N_uint>:

uint H2N_uint(uint value){
801099b8:	55                   	push   %ebp
801099b9:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801099bb:	8b 45 08             	mov    0x8(%ebp),%eax
801099be:	c1 e0 18             	shl    $0x18,%eax
801099c1:	25 00 00 00 0f       	and    $0xf000000,%eax
801099c6:	89 c2                	mov    %eax,%edx
801099c8:	8b 45 08             	mov    0x8(%ebp),%eax
801099cb:	c1 e0 08             	shl    $0x8,%eax
801099ce:	25 00 f0 00 00       	and    $0xf000,%eax
801099d3:	09 c2                	or     %eax,%edx
801099d5:	8b 45 08             	mov    0x8(%ebp),%eax
801099d8:	c1 e8 08             	shr    $0x8,%eax
801099db:	83 e0 0f             	and    $0xf,%eax
801099de:	01 d0                	add    %edx,%eax
}
801099e0:	5d                   	pop    %ebp
801099e1:	c3                   	ret    

801099e2 <N2H_uint>:

uint N2H_uint(uint value){
801099e2:	55                   	push   %ebp
801099e3:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801099e5:	8b 45 08             	mov    0x8(%ebp),%eax
801099e8:	c1 e0 18             	shl    $0x18,%eax
801099eb:	89 c2                	mov    %eax,%edx
801099ed:	8b 45 08             	mov    0x8(%ebp),%eax
801099f0:	c1 e0 08             	shl    $0x8,%eax
801099f3:	25 00 00 ff 00       	and    $0xff0000,%eax
801099f8:	01 c2                	add    %eax,%edx
801099fa:	8b 45 08             	mov    0x8(%ebp),%eax
801099fd:	c1 e8 08             	shr    $0x8,%eax
80109a00:	25 00 ff 00 00       	and    $0xff00,%eax
80109a05:	01 c2                	add    %eax,%edx
80109a07:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0a:	c1 e8 18             	shr    $0x18,%eax
80109a0d:	01 d0                	add    %edx,%eax
}
80109a0f:	5d                   	pop    %ebp
80109a10:	c3                   	ret    

80109a11 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109a11:	55                   	push   %ebp
80109a12:	89 e5                	mov    %esp,%ebp
80109a14:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109a17:	8b 45 08             	mov    0x8(%ebp),%eax
80109a1a:	83 c0 0e             	add    $0xe,%eax
80109a1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a23:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109a27:	0f b7 d0             	movzwl %ax,%edx
80109a2a:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109a2f:	39 c2                	cmp    %eax,%edx
80109a31:	74 60                	je     80109a93 <ipv4_proc+0x82>
80109a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a36:	83 c0 0c             	add    $0xc,%eax
80109a39:	83 ec 04             	sub    $0x4,%esp
80109a3c:	6a 04                	push   $0x4
80109a3e:	50                   	push   %eax
80109a3f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a44:	e8 34 b4 ff ff       	call   80104e7d <memcmp>
80109a49:	83 c4 10             	add    $0x10,%esp
80109a4c:	85 c0                	test   %eax,%eax
80109a4e:	74 43                	je     80109a93 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a53:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109a57:	0f b7 c0             	movzwl %ax,%eax
80109a5a:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a62:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109a66:	3c 01                	cmp    $0x1,%al
80109a68:	75 10                	jne    80109a7a <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109a6a:	83 ec 0c             	sub    $0xc,%esp
80109a6d:	ff 75 08             	push   0x8(%ebp)
80109a70:	e8 a3 00 00 00       	call   80109b18 <icmp_proc>
80109a75:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109a78:	eb 19                	jmp    80109a93 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a7d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109a81:	3c 06                	cmp    $0x6,%al
80109a83:	75 0e                	jne    80109a93 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109a85:	83 ec 0c             	sub    $0xc,%esp
80109a88:	ff 75 08             	push   0x8(%ebp)
80109a8b:	e8 b3 03 00 00       	call   80109e43 <tcp_proc>
80109a90:	83 c4 10             	add    $0x10,%esp
}
80109a93:	90                   	nop
80109a94:	c9                   	leave  
80109a95:	c3                   	ret    

80109a96 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109a96:	55                   	push   %ebp
80109a97:	89 e5                	mov    %esp,%ebp
80109a99:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aa5:	0f b6 00             	movzbl (%eax),%eax
80109aa8:	83 e0 0f             	and    $0xf,%eax
80109aab:	01 c0                	add    %eax,%eax
80109aad:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109ab0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109ab7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109abe:	eb 48                	jmp    80109b08 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109ac0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ac3:	01 c0                	add    %eax,%eax
80109ac5:	89 c2                	mov    %eax,%edx
80109ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aca:	01 d0                	add    %edx,%eax
80109acc:	0f b6 00             	movzbl (%eax),%eax
80109acf:	0f b6 c0             	movzbl %al,%eax
80109ad2:	c1 e0 08             	shl    $0x8,%eax
80109ad5:	89 c2                	mov    %eax,%edx
80109ad7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ada:	01 c0                	add    %eax,%eax
80109adc:	8d 48 01             	lea    0x1(%eax),%ecx
80109adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ae2:	01 c8                	add    %ecx,%eax
80109ae4:	0f b6 00             	movzbl (%eax),%eax
80109ae7:	0f b6 c0             	movzbl %al,%eax
80109aea:	01 d0                	add    %edx,%eax
80109aec:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109aef:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109af6:	76 0c                	jbe    80109b04 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109af8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109afb:	0f b7 c0             	movzwl %ax,%eax
80109afe:	83 c0 01             	add    $0x1,%eax
80109b01:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b04:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b08:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109b0c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109b0f:	7c af                	jl     80109ac0 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109b11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b14:	f7 d0                	not    %eax
}
80109b16:	c9                   	leave  
80109b17:	c3                   	ret    

80109b18 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109b18:	55                   	push   %ebp
80109b19:	89 e5                	mov    %esp,%ebp
80109b1b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b21:	83 c0 0e             	add    $0xe,%eax
80109b24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b2a:	0f b6 00             	movzbl (%eax),%eax
80109b2d:	0f b6 c0             	movzbl %al,%eax
80109b30:	83 e0 0f             	and    $0xf,%eax
80109b33:	c1 e0 02             	shl    $0x2,%eax
80109b36:	89 c2                	mov    %eax,%edx
80109b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b3b:	01 d0                	add    %edx,%eax
80109b3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b43:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109b47:	84 c0                	test   %al,%al
80109b49:	75 4f                	jne    80109b9a <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b4e:	0f b6 00             	movzbl (%eax),%eax
80109b51:	3c 08                	cmp    $0x8,%al
80109b53:	75 45                	jne    80109b9a <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109b55:	e8 46 8c ff ff       	call   801027a0 <kalloc>
80109b5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109b5d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109b64:	83 ec 04             	sub    $0x4,%esp
80109b67:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109b6a:	50                   	push   %eax
80109b6b:	ff 75 ec             	push   -0x14(%ebp)
80109b6e:	ff 75 08             	push   0x8(%ebp)
80109b71:	e8 78 00 00 00       	call   80109bee <icmp_reply_pkt_create>
80109b76:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109b79:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b7c:	83 ec 08             	sub    $0x8,%esp
80109b7f:	50                   	push   %eax
80109b80:	ff 75 ec             	push   -0x14(%ebp)
80109b83:	e8 95 f4 ff ff       	call   8010901d <i8254_send>
80109b88:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109b8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b8e:	83 ec 0c             	sub    $0xc,%esp
80109b91:	50                   	push   %eax
80109b92:	e8 6f 8b ff ff       	call   80102706 <kfree>
80109b97:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109b9a:	90                   	nop
80109b9b:	c9                   	leave  
80109b9c:	c3                   	ret    

80109b9d <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109b9d:	55                   	push   %ebp
80109b9e:	89 e5                	mov    %esp,%ebp
80109ba0:	53                   	push   %ebx
80109ba1:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bab:	0f b7 c0             	movzwl %ax,%eax
80109bae:	83 ec 0c             	sub    $0xc,%esp
80109bb1:	50                   	push   %eax
80109bb2:	e8 bd fd ff ff       	call   80109974 <N2H_ushort>
80109bb7:	83 c4 10             	add    $0x10,%esp
80109bba:	0f b7 d8             	movzwl %ax,%ebx
80109bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109bc4:	0f b7 c0             	movzwl %ax,%eax
80109bc7:	83 ec 0c             	sub    $0xc,%esp
80109bca:	50                   	push   %eax
80109bcb:	e8 a4 fd ff ff       	call   80109974 <N2H_ushort>
80109bd0:	83 c4 10             	add    $0x10,%esp
80109bd3:	0f b7 c0             	movzwl %ax,%eax
80109bd6:	83 ec 04             	sub    $0x4,%esp
80109bd9:	53                   	push   %ebx
80109bda:	50                   	push   %eax
80109bdb:	68 63 c5 10 80       	push   $0x8010c563
80109be0:	e8 0f 68 ff ff       	call   801003f4 <cprintf>
80109be5:	83 c4 10             	add    $0x10,%esp
}
80109be8:	90                   	nop
80109be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109bec:	c9                   	leave  
80109bed:	c3                   	ret    

80109bee <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109bee:	55                   	push   %ebp
80109bef:	89 e5                	mov    %esp,%ebp
80109bf1:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80109bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80109bfd:	83 c0 0e             	add    $0xe,%eax
80109c00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c06:	0f b6 00             	movzbl (%eax),%eax
80109c09:	0f b6 c0             	movzbl %al,%eax
80109c0c:	83 e0 0f             	and    $0xf,%eax
80109c0f:	c1 e0 02             	shl    $0x2,%eax
80109c12:	89 c2                	mov    %eax,%edx
80109c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c17:	01 d0                	add    %edx,%eax
80109c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109c22:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c25:	83 c0 0e             	add    $0xe,%eax
80109c28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c2e:	83 c0 14             	add    $0x14,%eax
80109c31:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109c34:	8b 45 10             	mov    0x10(%ebp),%eax
80109c37:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c40:	8d 50 06             	lea    0x6(%eax),%edx
80109c43:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c46:	83 ec 04             	sub    $0x4,%esp
80109c49:	6a 06                	push   $0x6
80109c4b:	52                   	push   %edx
80109c4c:	50                   	push   %eax
80109c4d:	e8 83 b2 ff ff       	call   80104ed5 <memmove>
80109c52:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c58:	83 c0 06             	add    $0x6,%eax
80109c5b:	83 ec 04             	sub    $0x4,%esp
80109c5e:	6a 06                	push   $0x6
80109c60:	68 90 75 19 80       	push   $0x80197590
80109c65:	50                   	push   %eax
80109c66:	e8 6a b2 ff ff       	call   80104ed5 <memmove>
80109c6b:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c71:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c78:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c7f:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c85:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109c89:	83 ec 0c             	sub    $0xc,%esp
80109c8c:	6a 54                	push   $0x54
80109c8e:	e8 03 fd ff ff       	call   80109996 <H2N_ushort>
80109c93:	83 c4 10             	add    $0x10,%esp
80109c96:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c99:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109c9d:	0f b7 15 60 78 19 80 	movzwl 0x80197860,%edx
80109ca4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ca7:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109cab:	0f b7 05 60 78 19 80 	movzwl 0x80197860,%eax
80109cb2:	83 c0 01             	add    $0x1,%eax
80109cb5:	66 a3 60 78 19 80    	mov    %ax,0x80197860
  ipv4_send->fragment = H2N_ushort(0x4000);
80109cbb:	83 ec 0c             	sub    $0xc,%esp
80109cbe:	68 00 40 00 00       	push   $0x4000
80109cc3:	e8 ce fc ff ff       	call   80109996 <H2N_ushort>
80109cc8:	83 c4 10             	add    $0x10,%esp
80109ccb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109cce:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cd5:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109cd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cdc:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ce3:	83 c0 0c             	add    $0xc,%eax
80109ce6:	83 ec 04             	sub    $0x4,%esp
80109ce9:	6a 04                	push   $0x4
80109ceb:	68 e4 f4 10 80       	push   $0x8010f4e4
80109cf0:	50                   	push   %eax
80109cf1:	e8 df b1 ff ff       	call   80104ed5 <memmove>
80109cf6:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cfc:	8d 50 0c             	lea    0xc(%eax),%edx
80109cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d02:	83 c0 10             	add    $0x10,%eax
80109d05:	83 ec 04             	sub    $0x4,%esp
80109d08:	6a 04                	push   $0x4
80109d0a:	52                   	push   %edx
80109d0b:	50                   	push   %eax
80109d0c:	e8 c4 b1 ff ff       	call   80104ed5 <memmove>
80109d11:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109d14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d17:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109d1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d20:	83 ec 0c             	sub    $0xc,%esp
80109d23:	50                   	push   %eax
80109d24:	e8 6d fd ff ff       	call   80109a96 <ipv4_chksum>
80109d29:	83 c4 10             	add    $0x10,%esp
80109d2c:	0f b7 c0             	movzwl %ax,%eax
80109d2f:	83 ec 0c             	sub    $0xc,%esp
80109d32:	50                   	push   %eax
80109d33:	e8 5e fc ff ff       	call   80109996 <H2N_ushort>
80109d38:	83 c4 10             	add    $0x10,%esp
80109d3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d3e:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109d42:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d45:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109d48:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d4b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109d4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d52:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109d56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d59:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109d5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d60:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109d64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d67:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109d6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d6e:	8d 50 08             	lea    0x8(%eax),%edx
80109d71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d74:	83 c0 08             	add    $0x8,%eax
80109d77:	83 ec 04             	sub    $0x4,%esp
80109d7a:	6a 08                	push   $0x8
80109d7c:	52                   	push   %edx
80109d7d:	50                   	push   %eax
80109d7e:	e8 52 b1 ff ff       	call   80104ed5 <memmove>
80109d83:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109d86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d89:	8d 50 10             	lea    0x10(%eax),%edx
80109d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d8f:	83 c0 10             	add    $0x10,%eax
80109d92:	83 ec 04             	sub    $0x4,%esp
80109d95:	6a 30                	push   $0x30
80109d97:	52                   	push   %edx
80109d98:	50                   	push   %eax
80109d99:	e8 37 b1 ff ff       	call   80104ed5 <memmove>
80109d9e:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109da1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109da4:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109daa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dad:	83 ec 0c             	sub    $0xc,%esp
80109db0:	50                   	push   %eax
80109db1:	e8 1c 00 00 00       	call   80109dd2 <icmp_chksum>
80109db6:	83 c4 10             	add    $0x10,%esp
80109db9:	0f b7 c0             	movzwl %ax,%eax
80109dbc:	83 ec 0c             	sub    $0xc,%esp
80109dbf:	50                   	push   %eax
80109dc0:	e8 d1 fb ff ff       	call   80109996 <H2N_ushort>
80109dc5:	83 c4 10             	add    $0x10,%esp
80109dc8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109dcb:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109dcf:	90                   	nop
80109dd0:	c9                   	leave  
80109dd1:	c3                   	ret    

80109dd2 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109dd2:	55                   	push   %ebp
80109dd3:	89 e5                	mov    %esp,%ebp
80109dd5:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80109ddb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109dde:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109de5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109dec:	eb 48                	jmp    80109e36 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109dee:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109df1:	01 c0                	add    %eax,%eax
80109df3:	89 c2                	mov    %eax,%edx
80109df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109df8:	01 d0                	add    %edx,%eax
80109dfa:	0f b6 00             	movzbl (%eax),%eax
80109dfd:	0f b6 c0             	movzbl %al,%eax
80109e00:	c1 e0 08             	shl    $0x8,%eax
80109e03:	89 c2                	mov    %eax,%edx
80109e05:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e08:	01 c0                	add    %eax,%eax
80109e0a:	8d 48 01             	lea    0x1(%eax),%ecx
80109e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e10:	01 c8                	add    %ecx,%eax
80109e12:	0f b6 00             	movzbl (%eax),%eax
80109e15:	0f b6 c0             	movzbl %al,%eax
80109e18:	01 d0                	add    %edx,%eax
80109e1a:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109e1d:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109e24:	76 0c                	jbe    80109e32 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109e26:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e29:	0f b7 c0             	movzwl %ax,%eax
80109e2c:	83 c0 01             	add    $0x1,%eax
80109e2f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109e32:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109e36:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109e3a:	7e b2                	jle    80109dee <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109e3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e3f:	f7 d0                	not    %eax
}
80109e41:	c9                   	leave  
80109e42:	c3                   	ret    

80109e43 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109e43:	55                   	push   %ebp
80109e44:	89 e5                	mov    %esp,%ebp
80109e46:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109e49:	8b 45 08             	mov    0x8(%ebp),%eax
80109e4c:	83 c0 0e             	add    $0xe,%eax
80109e4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e55:	0f b6 00             	movzbl (%eax),%eax
80109e58:	0f b6 c0             	movzbl %al,%eax
80109e5b:	83 e0 0f             	and    $0xf,%eax
80109e5e:	c1 e0 02             	shl    $0x2,%eax
80109e61:	89 c2                	mov    %eax,%edx
80109e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e66:	01 d0                	add    %edx,%eax
80109e68:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e6e:	83 c0 14             	add    $0x14,%eax
80109e71:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109e74:	e8 27 89 ff ff       	call   801027a0 <kalloc>
80109e79:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109e7c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e86:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e8a:	0f b6 c0             	movzbl %al,%eax
80109e8d:	83 e0 02             	and    $0x2,%eax
80109e90:	85 c0                	test   %eax,%eax
80109e92:	74 3d                	je     80109ed1 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109e94:	83 ec 0c             	sub    $0xc,%esp
80109e97:	6a 00                	push   $0x0
80109e99:	6a 12                	push   $0x12
80109e9b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e9e:	50                   	push   %eax
80109e9f:	ff 75 e8             	push   -0x18(%ebp)
80109ea2:	ff 75 08             	push   0x8(%ebp)
80109ea5:	e8 a2 01 00 00       	call   8010a04c <tcp_pkt_create>
80109eaa:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109ead:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109eb0:	83 ec 08             	sub    $0x8,%esp
80109eb3:	50                   	push   %eax
80109eb4:	ff 75 e8             	push   -0x18(%ebp)
80109eb7:	e8 61 f1 ff ff       	call   8010901d <i8254_send>
80109ebc:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109ebf:	a1 64 78 19 80       	mov    0x80197864,%eax
80109ec4:	83 c0 01             	add    $0x1,%eax
80109ec7:	a3 64 78 19 80       	mov    %eax,0x80197864
80109ecc:	e9 69 01 00 00       	jmp    8010a03a <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ed4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ed8:	3c 18                	cmp    $0x18,%al
80109eda:	0f 85 10 01 00 00    	jne    80109ff0 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109ee0:	83 ec 04             	sub    $0x4,%esp
80109ee3:	6a 03                	push   $0x3
80109ee5:	68 7e c5 10 80       	push   $0x8010c57e
80109eea:	ff 75 ec             	push   -0x14(%ebp)
80109eed:	e8 8b af ff ff       	call   80104e7d <memcmp>
80109ef2:	83 c4 10             	add    $0x10,%esp
80109ef5:	85 c0                	test   %eax,%eax
80109ef7:	74 74                	je     80109f6d <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109ef9:	83 ec 0c             	sub    $0xc,%esp
80109efc:	68 82 c5 10 80       	push   $0x8010c582
80109f01:	e8 ee 64 ff ff       	call   801003f4 <cprintf>
80109f06:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109f09:	83 ec 0c             	sub    $0xc,%esp
80109f0c:	6a 00                	push   $0x0
80109f0e:	6a 10                	push   $0x10
80109f10:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f13:	50                   	push   %eax
80109f14:	ff 75 e8             	push   -0x18(%ebp)
80109f17:	ff 75 08             	push   0x8(%ebp)
80109f1a:	e8 2d 01 00 00       	call   8010a04c <tcp_pkt_create>
80109f1f:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f22:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f25:	83 ec 08             	sub    $0x8,%esp
80109f28:	50                   	push   %eax
80109f29:	ff 75 e8             	push   -0x18(%ebp)
80109f2c:	e8 ec f0 ff ff       	call   8010901d <i8254_send>
80109f31:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f37:	83 c0 36             	add    $0x36,%eax
80109f3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109f3d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109f40:	50                   	push   %eax
80109f41:	ff 75 e0             	push   -0x20(%ebp)
80109f44:	6a 00                	push   $0x0
80109f46:	6a 00                	push   $0x0
80109f48:	e8 5a 04 00 00       	call   8010a3a7 <http_proc>
80109f4d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109f50:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109f53:	83 ec 0c             	sub    $0xc,%esp
80109f56:	50                   	push   %eax
80109f57:	6a 18                	push   $0x18
80109f59:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f5c:	50                   	push   %eax
80109f5d:	ff 75 e8             	push   -0x18(%ebp)
80109f60:	ff 75 08             	push   0x8(%ebp)
80109f63:	e8 e4 00 00 00       	call   8010a04c <tcp_pkt_create>
80109f68:	83 c4 20             	add    $0x20,%esp
80109f6b:	eb 62                	jmp    80109fcf <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109f6d:	83 ec 0c             	sub    $0xc,%esp
80109f70:	6a 00                	push   $0x0
80109f72:	6a 10                	push   $0x10
80109f74:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f77:	50                   	push   %eax
80109f78:	ff 75 e8             	push   -0x18(%ebp)
80109f7b:	ff 75 08             	push   0x8(%ebp)
80109f7e:	e8 c9 00 00 00       	call   8010a04c <tcp_pkt_create>
80109f83:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109f86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f89:	83 ec 08             	sub    $0x8,%esp
80109f8c:	50                   	push   %eax
80109f8d:	ff 75 e8             	push   -0x18(%ebp)
80109f90:	e8 88 f0 ff ff       	call   8010901d <i8254_send>
80109f95:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109f98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f9b:	83 c0 36             	add    $0x36,%eax
80109f9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109fa1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109fa4:	50                   	push   %eax
80109fa5:	ff 75 e4             	push   -0x1c(%ebp)
80109fa8:	6a 00                	push   $0x0
80109faa:	6a 00                	push   $0x0
80109fac:	e8 f6 03 00 00       	call   8010a3a7 <http_proc>
80109fb1:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109fb4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109fb7:	83 ec 0c             	sub    $0xc,%esp
80109fba:	50                   	push   %eax
80109fbb:	6a 18                	push   $0x18
80109fbd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fc0:	50                   	push   %eax
80109fc1:	ff 75 e8             	push   -0x18(%ebp)
80109fc4:	ff 75 08             	push   0x8(%ebp)
80109fc7:	e8 80 00 00 00       	call   8010a04c <tcp_pkt_create>
80109fcc:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109fcf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fd2:	83 ec 08             	sub    $0x8,%esp
80109fd5:	50                   	push   %eax
80109fd6:	ff 75 e8             	push   -0x18(%ebp)
80109fd9:	e8 3f f0 ff ff       	call   8010901d <i8254_send>
80109fde:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109fe1:	a1 64 78 19 80       	mov    0x80197864,%eax
80109fe6:	83 c0 01             	add    $0x1,%eax
80109fe9:	a3 64 78 19 80       	mov    %eax,0x80197864
80109fee:	eb 4a                	jmp    8010a03a <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ff3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ff7:	3c 10                	cmp    $0x10,%al
80109ff9:	75 3f                	jne    8010a03a <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109ffb:	a1 68 78 19 80       	mov    0x80197868,%eax
8010a000:	83 f8 01             	cmp    $0x1,%eax
8010a003:	75 35                	jne    8010a03a <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a005:	83 ec 0c             	sub    $0xc,%esp
8010a008:	6a 00                	push   $0x0
8010a00a:	6a 01                	push   $0x1
8010a00c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a00f:	50                   	push   %eax
8010a010:	ff 75 e8             	push   -0x18(%ebp)
8010a013:	ff 75 08             	push   0x8(%ebp)
8010a016:	e8 31 00 00 00       	call   8010a04c <tcp_pkt_create>
8010a01b:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a01e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a021:	83 ec 08             	sub    $0x8,%esp
8010a024:	50                   	push   %eax
8010a025:	ff 75 e8             	push   -0x18(%ebp)
8010a028:	e8 f0 ef ff ff       	call   8010901d <i8254_send>
8010a02d:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a030:	c7 05 68 78 19 80 00 	movl   $0x0,0x80197868
8010a037:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a03a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a03d:	83 ec 0c             	sub    $0xc,%esp
8010a040:	50                   	push   %eax
8010a041:	e8 c0 86 ff ff       	call   80102706 <kfree>
8010a046:	83 c4 10             	add    $0x10,%esp
}
8010a049:	90                   	nop
8010a04a:	c9                   	leave  
8010a04b:	c3                   	ret    

8010a04c <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a04c:	55                   	push   %ebp
8010a04d:	89 e5                	mov    %esp,%ebp
8010a04f:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a052:	8b 45 08             	mov    0x8(%ebp),%eax
8010a055:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a058:	8b 45 08             	mov    0x8(%ebp),%eax
8010a05b:	83 c0 0e             	add    $0xe,%eax
8010a05e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a061:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a064:	0f b6 00             	movzbl (%eax),%eax
8010a067:	0f b6 c0             	movzbl %al,%eax
8010a06a:	83 e0 0f             	and    $0xf,%eax
8010a06d:	c1 e0 02             	shl    $0x2,%eax
8010a070:	89 c2                	mov    %eax,%edx
8010a072:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a075:	01 d0                	add    %edx,%eax
8010a077:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a07a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a07d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a080:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a083:	83 c0 0e             	add    $0xe,%eax
8010a086:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a089:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a08c:	83 c0 14             	add    $0x14,%eax
8010a08f:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a092:	8b 45 18             	mov    0x18(%ebp),%eax
8010a095:	8d 50 36             	lea    0x36(%eax),%edx
8010a098:	8b 45 10             	mov    0x10(%ebp),%eax
8010a09b:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a09d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0a0:	8d 50 06             	lea    0x6(%eax),%edx
8010a0a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0a6:	83 ec 04             	sub    $0x4,%esp
8010a0a9:	6a 06                	push   $0x6
8010a0ab:	52                   	push   %edx
8010a0ac:	50                   	push   %eax
8010a0ad:	e8 23 ae ff ff       	call   80104ed5 <memmove>
8010a0b2:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a0b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0b8:	83 c0 06             	add    $0x6,%eax
8010a0bb:	83 ec 04             	sub    $0x4,%esp
8010a0be:	6a 06                	push   $0x6
8010a0c0:	68 90 75 19 80       	push   $0x80197590
8010a0c5:	50                   	push   %eax
8010a0c6:	e8 0a ae ff ff       	call   80104ed5 <memmove>
8010a0cb:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a0ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0d1:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a0d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0d8:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a0dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0df:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a0e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0e5:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a0e9:	8b 45 18             	mov    0x18(%ebp),%eax
8010a0ec:	83 c0 28             	add    $0x28,%eax
8010a0ef:	0f b7 c0             	movzwl %ax,%eax
8010a0f2:	83 ec 0c             	sub    $0xc,%esp
8010a0f5:	50                   	push   %eax
8010a0f6:	e8 9b f8 ff ff       	call   80109996 <H2N_ushort>
8010a0fb:	83 c4 10             	add    $0x10,%esp
8010a0fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a101:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a105:	0f b7 15 60 78 19 80 	movzwl 0x80197860,%edx
8010a10c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a10f:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a113:	0f b7 05 60 78 19 80 	movzwl 0x80197860,%eax
8010a11a:	83 c0 01             	add    $0x1,%eax
8010a11d:	66 a3 60 78 19 80    	mov    %ax,0x80197860
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a123:	83 ec 0c             	sub    $0xc,%esp
8010a126:	6a 00                	push   $0x0
8010a128:	e8 69 f8 ff ff       	call   80109996 <H2N_ushort>
8010a12d:	83 c4 10             	add    $0x10,%esp
8010a130:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a133:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a13a:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a13e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a141:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a145:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a148:	83 c0 0c             	add    $0xc,%eax
8010a14b:	83 ec 04             	sub    $0x4,%esp
8010a14e:	6a 04                	push   $0x4
8010a150:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a155:	50                   	push   %eax
8010a156:	e8 7a ad ff ff       	call   80104ed5 <memmove>
8010a15b:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a15e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a161:	8d 50 0c             	lea    0xc(%eax),%edx
8010a164:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a167:	83 c0 10             	add    $0x10,%eax
8010a16a:	83 ec 04             	sub    $0x4,%esp
8010a16d:	6a 04                	push   $0x4
8010a16f:	52                   	push   %edx
8010a170:	50                   	push   %eax
8010a171:	e8 5f ad ff ff       	call   80104ed5 <memmove>
8010a176:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a179:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a17c:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a182:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a185:	83 ec 0c             	sub    $0xc,%esp
8010a188:	50                   	push   %eax
8010a189:	e8 08 f9 ff ff       	call   80109a96 <ipv4_chksum>
8010a18e:	83 c4 10             	add    $0x10,%esp
8010a191:	0f b7 c0             	movzwl %ax,%eax
8010a194:	83 ec 0c             	sub    $0xc,%esp
8010a197:	50                   	push   %eax
8010a198:	e8 f9 f7 ff ff       	call   80109996 <H2N_ushort>
8010a19d:	83 c4 10             	add    $0x10,%esp
8010a1a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1a3:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a1a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1aa:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a1ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1b1:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a1b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1b7:	0f b7 10             	movzwl (%eax),%edx
8010a1ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1bd:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a1c1:	a1 64 78 19 80       	mov    0x80197864,%eax
8010a1c6:	83 ec 0c             	sub    $0xc,%esp
8010a1c9:	50                   	push   %eax
8010a1ca:	e8 e9 f7 ff ff       	call   801099b8 <H2N_uint>
8010a1cf:	83 c4 10             	add    $0x10,%esp
8010a1d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1d5:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a1d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1db:	8b 40 04             	mov    0x4(%eax),%eax
8010a1de:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a1e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1e7:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a1ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1ed:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a1f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1f4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a1f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1fb:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a1ff:	8b 45 14             	mov    0x14(%ebp),%eax
8010a202:	89 c2                	mov    %eax,%edx
8010a204:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a207:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a20a:	83 ec 0c             	sub    $0xc,%esp
8010a20d:	68 90 38 00 00       	push   $0x3890
8010a212:	e8 7f f7 ff ff       	call   80109996 <H2N_ushort>
8010a217:	83 c4 10             	add    $0x10,%esp
8010a21a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a21d:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a221:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a224:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a22a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a22d:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a233:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a236:	83 ec 0c             	sub    $0xc,%esp
8010a239:	50                   	push   %eax
8010a23a:	e8 1f 00 00 00       	call   8010a25e <tcp_chksum>
8010a23f:	83 c4 10             	add    $0x10,%esp
8010a242:	83 c0 08             	add    $0x8,%eax
8010a245:	0f b7 c0             	movzwl %ax,%eax
8010a248:	83 ec 0c             	sub    $0xc,%esp
8010a24b:	50                   	push   %eax
8010a24c:	e8 45 f7 ff ff       	call   80109996 <H2N_ushort>
8010a251:	83 c4 10             	add    $0x10,%esp
8010a254:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a257:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a25b:	90                   	nop
8010a25c:	c9                   	leave  
8010a25d:	c3                   	ret    

8010a25e <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a25e:	55                   	push   %ebp
8010a25f:	89 e5                	mov    %esp,%ebp
8010a261:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a264:	8b 45 08             	mov    0x8(%ebp),%eax
8010a267:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a26a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a26d:	83 c0 14             	add    $0x14,%eax
8010a270:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a273:	83 ec 04             	sub    $0x4,%esp
8010a276:	6a 04                	push   $0x4
8010a278:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a27d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a280:	50                   	push   %eax
8010a281:	e8 4f ac ff ff       	call   80104ed5 <memmove>
8010a286:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a289:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a28c:	83 c0 0c             	add    $0xc,%eax
8010a28f:	83 ec 04             	sub    $0x4,%esp
8010a292:	6a 04                	push   $0x4
8010a294:	50                   	push   %eax
8010a295:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a298:	83 c0 04             	add    $0x4,%eax
8010a29b:	50                   	push   %eax
8010a29c:	e8 34 ac ff ff       	call   80104ed5 <memmove>
8010a2a1:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a2a4:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a2a8:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a2ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2af:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a2b3:	0f b7 c0             	movzwl %ax,%eax
8010a2b6:	83 ec 0c             	sub    $0xc,%esp
8010a2b9:	50                   	push   %eax
8010a2ba:	e8 b5 f6 ff ff       	call   80109974 <N2H_ushort>
8010a2bf:	83 c4 10             	add    $0x10,%esp
8010a2c2:	83 e8 14             	sub    $0x14,%eax
8010a2c5:	0f b7 c0             	movzwl %ax,%eax
8010a2c8:	83 ec 0c             	sub    $0xc,%esp
8010a2cb:	50                   	push   %eax
8010a2cc:	e8 c5 f6 ff ff       	call   80109996 <H2N_ushort>
8010a2d1:	83 c4 10             	add    $0x10,%esp
8010a2d4:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a2d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a2df:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a2e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a2e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a2ec:	eb 33                	jmp    8010a321 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a2ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2f1:	01 c0                	add    %eax,%eax
8010a2f3:	89 c2                	mov    %eax,%edx
8010a2f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2f8:	01 d0                	add    %edx,%eax
8010a2fa:	0f b6 00             	movzbl (%eax),%eax
8010a2fd:	0f b6 c0             	movzbl %al,%eax
8010a300:	c1 e0 08             	shl    $0x8,%eax
8010a303:	89 c2                	mov    %eax,%edx
8010a305:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a308:	01 c0                	add    %eax,%eax
8010a30a:	8d 48 01             	lea    0x1(%eax),%ecx
8010a30d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a310:	01 c8                	add    %ecx,%eax
8010a312:	0f b6 00             	movzbl (%eax),%eax
8010a315:	0f b6 c0             	movzbl %al,%eax
8010a318:	01 d0                	add    %edx,%eax
8010a31a:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a31d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a321:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a325:	7e c7                	jle    8010a2ee <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a327:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a32a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a32d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a334:	eb 33                	jmp    8010a369 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a336:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a339:	01 c0                	add    %eax,%eax
8010a33b:	89 c2                	mov    %eax,%edx
8010a33d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a340:	01 d0                	add    %edx,%eax
8010a342:	0f b6 00             	movzbl (%eax),%eax
8010a345:	0f b6 c0             	movzbl %al,%eax
8010a348:	c1 e0 08             	shl    $0x8,%eax
8010a34b:	89 c2                	mov    %eax,%edx
8010a34d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a350:	01 c0                	add    %eax,%eax
8010a352:	8d 48 01             	lea    0x1(%eax),%ecx
8010a355:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a358:	01 c8                	add    %ecx,%eax
8010a35a:	0f b6 00             	movzbl (%eax),%eax
8010a35d:	0f b6 c0             	movzbl %al,%eax
8010a360:	01 d0                	add    %edx,%eax
8010a362:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a365:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a369:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a36d:	0f b7 c0             	movzwl %ax,%eax
8010a370:	83 ec 0c             	sub    $0xc,%esp
8010a373:	50                   	push   %eax
8010a374:	e8 fb f5 ff ff       	call   80109974 <N2H_ushort>
8010a379:	83 c4 10             	add    $0x10,%esp
8010a37c:	66 d1 e8             	shr    %ax
8010a37f:	0f b7 c0             	movzwl %ax,%eax
8010a382:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a385:	7c af                	jl     8010a336 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a38a:	c1 e8 10             	shr    $0x10,%eax
8010a38d:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a390:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a393:	f7 d0                	not    %eax
}
8010a395:	c9                   	leave  
8010a396:	c3                   	ret    

8010a397 <tcp_fin>:

void tcp_fin(){
8010a397:	55                   	push   %ebp
8010a398:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a39a:	c7 05 68 78 19 80 01 	movl   $0x1,0x80197868
8010a3a1:	00 00 00 
}
8010a3a4:	90                   	nop
8010a3a5:	5d                   	pop    %ebp
8010a3a6:	c3                   	ret    

8010a3a7 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a3a7:	55                   	push   %ebp
8010a3a8:	89 e5                	mov    %esp,%ebp
8010a3aa:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a3ad:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3b0:	83 ec 04             	sub    $0x4,%esp
8010a3b3:	6a 00                	push   $0x0
8010a3b5:	68 8b c5 10 80       	push   $0x8010c58b
8010a3ba:	50                   	push   %eax
8010a3bb:	e8 65 00 00 00       	call   8010a425 <http_strcpy>
8010a3c0:	83 c4 10             	add    $0x10,%esp
8010a3c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a3c6:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3c9:	83 ec 04             	sub    $0x4,%esp
8010a3cc:	ff 75 f4             	push   -0xc(%ebp)
8010a3cf:	68 9e c5 10 80       	push   $0x8010c59e
8010a3d4:	50                   	push   %eax
8010a3d5:	e8 4b 00 00 00       	call   8010a425 <http_strcpy>
8010a3da:	83 c4 10             	add    $0x10,%esp
8010a3dd:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a3e0:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3e3:	83 ec 04             	sub    $0x4,%esp
8010a3e6:	ff 75 f4             	push   -0xc(%ebp)
8010a3e9:	68 b9 c5 10 80       	push   $0x8010c5b9
8010a3ee:	50                   	push   %eax
8010a3ef:	e8 31 00 00 00       	call   8010a425 <http_strcpy>
8010a3f4:	83 c4 10             	add    $0x10,%esp
8010a3f7:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a3fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3fd:	83 e0 01             	and    $0x1,%eax
8010a400:	85 c0                	test   %eax,%eax
8010a402:	74 11                	je     8010a415 <http_proc+0x6e>
    char *payload = (char *)send;
8010a404:	8b 45 10             	mov    0x10(%ebp),%eax
8010a407:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a40a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a40d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a410:	01 d0                	add    %edx,%eax
8010a412:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a415:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a418:	8b 45 14             	mov    0x14(%ebp),%eax
8010a41b:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a41d:	e8 75 ff ff ff       	call   8010a397 <tcp_fin>
}
8010a422:	90                   	nop
8010a423:	c9                   	leave  
8010a424:	c3                   	ret    

8010a425 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a425:	55                   	push   %ebp
8010a426:	89 e5                	mov    %esp,%ebp
8010a428:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a42b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a432:	eb 20                	jmp    8010a454 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a434:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a437:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a43a:	01 d0                	add    %edx,%eax
8010a43c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a43f:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a442:	01 ca                	add    %ecx,%edx
8010a444:	89 d1                	mov    %edx,%ecx
8010a446:	8b 55 08             	mov    0x8(%ebp),%edx
8010a449:	01 ca                	add    %ecx,%edx
8010a44b:	0f b6 00             	movzbl (%eax),%eax
8010a44e:	88 02                	mov    %al,(%edx)
    i++;
8010a450:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a454:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a457:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a45a:	01 d0                	add    %edx,%eax
8010a45c:	0f b6 00             	movzbl (%eax),%eax
8010a45f:	84 c0                	test   %al,%al
8010a461:	75 d1                	jne    8010a434 <http_strcpy+0xf>
  }
  return i;
8010a463:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a466:	c9                   	leave  
8010a467:	c3                   	ret    

8010a468 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a468:	55                   	push   %ebp
8010a469:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a46b:	c7 05 70 78 19 80 a2 	movl   $0x8010f5a2,0x80197870
8010a472:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a475:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a47a:	c1 e8 09             	shr    $0x9,%eax
8010a47d:	a3 6c 78 19 80       	mov    %eax,0x8019786c
}
8010a482:	90                   	nop
8010a483:	5d                   	pop    %ebp
8010a484:	c3                   	ret    

8010a485 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a485:	55                   	push   %ebp
8010a486:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a488:	90                   	nop
8010a489:	5d                   	pop    %ebp
8010a48a:	c3                   	ret    

8010a48b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a48b:	55                   	push   %ebp
8010a48c:	89 e5                	mov    %esp,%ebp
8010a48e:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a491:	8b 45 08             	mov    0x8(%ebp),%eax
8010a494:	83 c0 0c             	add    $0xc,%eax
8010a497:	83 ec 0c             	sub    $0xc,%esp
8010a49a:	50                   	push   %eax
8010a49b:	e8 6f a6 ff ff       	call   80104b0f <holdingsleep>
8010a4a0:	83 c4 10             	add    $0x10,%esp
8010a4a3:	85 c0                	test   %eax,%eax
8010a4a5:	75 0d                	jne    8010a4b4 <iderw+0x29>
    panic("iderw: buf not locked");
8010a4a7:	83 ec 0c             	sub    $0xc,%esp
8010a4aa:	68 ca c5 10 80       	push   $0x8010c5ca
8010a4af:	e8 f5 60 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a4b4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4b7:	8b 00                	mov    (%eax),%eax
8010a4b9:	83 e0 06             	and    $0x6,%eax
8010a4bc:	83 f8 02             	cmp    $0x2,%eax
8010a4bf:	75 0d                	jne    8010a4ce <iderw+0x43>
    panic("iderw: nothing to do");
8010a4c1:	83 ec 0c             	sub    $0xc,%esp
8010a4c4:	68 e0 c5 10 80       	push   $0x8010c5e0
8010a4c9:	e8 db 60 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a4ce:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4d1:	8b 40 04             	mov    0x4(%eax),%eax
8010a4d4:	83 f8 01             	cmp    $0x1,%eax
8010a4d7:	74 0d                	je     8010a4e6 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a4d9:	83 ec 0c             	sub    $0xc,%esp
8010a4dc:	68 f5 c5 10 80       	push   $0x8010c5f5
8010a4e1:	e8 c3 60 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a4e6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4e9:	8b 40 08             	mov    0x8(%eax),%eax
8010a4ec:	8b 15 6c 78 19 80    	mov    0x8019786c,%edx
8010a4f2:	39 d0                	cmp    %edx,%eax
8010a4f4:	72 0d                	jb     8010a503 <iderw+0x78>
    panic("iderw: block out of range");
8010a4f6:	83 ec 0c             	sub    $0xc,%esp
8010a4f9:	68 13 c6 10 80       	push   $0x8010c613
8010a4fe:	e8 a6 60 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a503:	8b 15 70 78 19 80    	mov    0x80197870,%edx
8010a509:	8b 45 08             	mov    0x8(%ebp),%eax
8010a50c:	8b 40 08             	mov    0x8(%eax),%eax
8010a50f:	c1 e0 09             	shl    $0x9,%eax
8010a512:	01 d0                	add    %edx,%eax
8010a514:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a517:	8b 45 08             	mov    0x8(%ebp),%eax
8010a51a:	8b 00                	mov    (%eax),%eax
8010a51c:	83 e0 04             	and    $0x4,%eax
8010a51f:	85 c0                	test   %eax,%eax
8010a521:	74 2b                	je     8010a54e <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a523:	8b 45 08             	mov    0x8(%ebp),%eax
8010a526:	8b 00                	mov    (%eax),%eax
8010a528:	83 e0 fb             	and    $0xfffffffb,%eax
8010a52b:	89 c2                	mov    %eax,%edx
8010a52d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a530:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a532:	8b 45 08             	mov    0x8(%ebp),%eax
8010a535:	83 c0 5c             	add    $0x5c,%eax
8010a538:	83 ec 04             	sub    $0x4,%esp
8010a53b:	68 00 02 00 00       	push   $0x200
8010a540:	50                   	push   %eax
8010a541:	ff 75 f4             	push   -0xc(%ebp)
8010a544:	e8 8c a9 ff ff       	call   80104ed5 <memmove>
8010a549:	83 c4 10             	add    $0x10,%esp
8010a54c:	eb 1a                	jmp    8010a568 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a54e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a551:	83 c0 5c             	add    $0x5c,%eax
8010a554:	83 ec 04             	sub    $0x4,%esp
8010a557:	68 00 02 00 00       	push   $0x200
8010a55c:	ff 75 f4             	push   -0xc(%ebp)
8010a55f:	50                   	push   %eax
8010a560:	e8 70 a9 ff ff       	call   80104ed5 <memmove>
8010a565:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a568:	8b 45 08             	mov    0x8(%ebp),%eax
8010a56b:	8b 00                	mov    (%eax),%eax
8010a56d:	83 c8 02             	or     $0x2,%eax
8010a570:	89 c2                	mov    %eax,%edx
8010a572:	8b 45 08             	mov    0x8(%ebp),%eax
8010a575:	89 10                	mov    %edx,(%eax)
}
8010a577:	90                   	nop
8010a578:	c9                   	leave  
8010a579:	c3                   	ret    
