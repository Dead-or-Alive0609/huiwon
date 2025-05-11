
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
8010006f:	68 20 a7 10 80       	push   $0x8010a720
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 46 4b 00 00       	call   80104bc4 <initlock>
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
801000bd:	68 27 a7 10 80       	push   $0x8010a727
801000c2:	50                   	push   %eax
801000c3:	e8 9f 49 00 00       	call   80104a67 <initsleeplock>
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
80100101:	e8 e0 4a 00 00       	call   80104be6 <acquire>
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
80100140:	e8 0f 4b 00 00       	call   80104c54 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 4c 49 00 00       	call   80104aa3 <acquiresleep>
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
801001c1:	e8 8e 4a 00 00       	call   80104c54 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 cb 48 00 00       	call   80104aa3 <acquiresleep>
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
801001f5:	68 2e a7 10 80       	push   $0x8010a72e
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
8010022d:	e8 e2 a3 00 00       	call   8010a614 <iderw>
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
8010024a:	e8 06 49 00 00       	call   80104b55 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 3f a7 10 80       	push   $0x8010a73f
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
80100278:	e8 97 a3 00 00       	call   8010a614 <iderw>
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
80100293:	e8 bd 48 00 00       	call   80104b55 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 46 a7 10 80       	push   $0x8010a746
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 4c 48 00 00       	call   80104b07 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 1b 49 00 00       	call   80104be6 <acquire>
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
80100336:	e8 19 49 00 00       	call   80104c54 <release>
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
80100410:	e8 d1 47 00 00       	call   80104be6 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 4d a7 10 80       	push   $0x8010a74d
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
80100510:	c7 45 ec 56 a7 10 80 	movl   $0x8010a756,-0x14(%ebp)
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
8010059e:	e8 b1 46 00 00       	call   80104c54 <release>
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
801005c7:	68 5d a7 10 80       	push   $0x8010a75d
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
801005e6:	68 71 a7 10 80       	push   $0x8010a771
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 a3 46 00 00       	call   80104ca6 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 73 a7 10 80       	push   $0x8010a773
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
801006a0:	e8 c6 7e 00 00       	call   8010856b <graphic_scroll_up>
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
801006f3:	e8 73 7e 00 00       	call   8010856b <graphic_scroll_up>
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
80100757:	e8 7a 7e 00 00       	call   801085d6 <font_render>
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
80100793:	e8 4a 62 00 00       	call   801069e2 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 3d 62 00 00       	call   801069e2 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 30 62 00 00       	call   801069e2 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 20 62 00 00       	call   801069e2 <uartputc>
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
801007eb:	e8 f6 43 00 00       	call   80104be6 <acquire>
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
8010093f:	e8 07 3d 00 00       	call   8010464b <wakeup>
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
80100962:	e8 ed 42 00 00       	call   80104c54 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 95 3e 00 00       	call   8010480a <procdump>
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
8010099a:	e8 47 42 00 00       	call   80104be6 <acquire>
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
801009bb:	e8 94 42 00 00       	call   80104c54 <release>
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
801009e8:	e8 74 3b 00 00       	call   80104561 <sleep>
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
80100a66:	e8 e9 41 00 00       	call   80104c54 <release>
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
80100aa2:	e8 3f 41 00 00       	call   80104be6 <acquire>
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
80100ae4:	e8 6b 41 00 00       	call   80104c54 <release>
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
80100b12:	68 77 a7 10 80       	push   $0x8010a777
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 a3 40 00 00       	call   80104bc4 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 7f a7 10 80 	movl   $0x8010a77f,-0xc(%ebp)
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
80100bb5:	68 95 a7 10 80       	push   $0x8010a795
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
80100c11:	e8 c8 6d 00 00       	call   801079de <setupkvm>
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
80100cb7:	e8 1b 71 00 00       	call   80107dd7 <allocuvm>
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
80100cfd:	e8 08 70 00 00       	call   80107d0a <loaduvm>
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
80100d6c:	e8 66 70 00 00       	call   80107dd7 <allocuvm>
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
80100d90:	e8 a4 72 00 00       	call   80108039 <clearpteu>
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
80100dc9:	e8 dc 42 00 00       	call   801050aa <strlen>
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
80100df6:	e8 af 42 00 00       	call   801050aa <strlen>
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
80100e1c:	e8 b7 73 00 00       	call   801081d8 <copyout>
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
80100eb8:	e8 1b 73 00 00       	call   801081d8 <copyout>
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
80100f06:	e8 54 41 00 00       	call   8010505f <safestrcpy>
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
80100f49:	e8 ad 6b 00 00       	call   80107afb <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 44 70 00 00       	call   80107fa0 <freevm>
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
80100f97:	e8 04 70 00 00       	call   80107fa0 <freevm>
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
80100fc8:	68 a1 a7 10 80       	push   $0x8010a7a1
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 ed 3b 00 00       	call   80104bc4 <initlock>
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
80100feb:	e8 f6 3b 00 00       	call   80104be6 <acquire>
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
80101018:	e8 37 3c 00 00       	call   80104c54 <release>
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
8010103b:	e8 14 3c 00 00       	call   80104c54 <release>
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
80101058:	e8 89 3b 00 00       	call   80104be6 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 a8 a7 10 80       	push   $0x8010a7a8
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
8010108e:	e8 c1 3b 00 00       	call   80104c54 <release>
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
801010a9:	e8 38 3b 00 00       	call   80104be6 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 b0 a7 10 80       	push   $0x8010a7b0
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
801010e9:	e8 66 3b 00 00       	call   80104c54 <release>
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
80101137:	e8 18 3b 00 00       	call   80104c54 <release>
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
80101286:	68 ba a7 10 80       	push   $0x8010a7ba
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
80101389:	68 c3 a7 10 80       	push   $0x8010a7c3
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
801013bf:	68 d3 a7 10 80       	push   $0x8010a7d3
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
801013f7:	e8 1f 3b 00 00       	call   80104f1b <memmove>
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
8010143d:	e8 1a 3a 00 00       	call   80104e5c <memset>
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
8010159c:	68 e0 a7 10 80       	push   $0x8010a7e0
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
80101627:	68 f6 a7 10 80       	push   $0x8010a7f6
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
8010168b:	68 09 a8 10 80       	push   $0x8010a809
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 2a 35 00 00       	call   80104bc4 <initlock>
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
801016c1:	68 10 a8 10 80       	push   $0x8010a810
801016c6:	50                   	push   %eax
801016c7:	e8 9b 33 00 00       	call   80104a67 <initsleeplock>
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
80101720:	68 18 a8 10 80       	push   $0x8010a818
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
80101799:	e8 be 36 00 00       	call   80104e5c <memset>
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
80101801:	68 6b a8 10 80       	push   $0x8010a86b
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
801018a7:	e8 6f 36 00 00       	call   80104f1b <memmove>
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
801018dc:	e8 05 33 00 00       	call   80104be6 <acquire>
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
8010192a:	e8 25 33 00 00       	call   80104c54 <release>
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
80101966:	68 7d a8 10 80       	push   $0x8010a87d
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
801019a3:	e8 ac 32 00 00       	call   80104c54 <release>
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
801019be:	e8 23 32 00 00       	call   80104be6 <acquire>
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
801019dd:	e8 72 32 00 00       	call   80104c54 <release>
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
80101a03:	68 8d a8 10 80       	push   $0x8010a88d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 87 30 00 00       	call   80104aa3 <acquiresleep>
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
80101ac1:	e8 55 34 00 00       	call   80104f1b <memmove>
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
80101af0:	68 93 a8 10 80       	push   $0x8010a893
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
80101b13:	e8 3d 30 00 00       	call   80104b55 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 a2 a8 10 80       	push   $0x8010a8a2
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 c2 2f 00 00       	call   80104b07 <releasesleep>
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
80101b5b:	e8 43 2f 00 00       	call   80104aa3 <acquiresleep>
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
80101b81:	e8 60 30 00 00       	call   80104be6 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 b5 30 00 00       	call   80104c54 <release>
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
80101be1:	e8 21 2f 00 00       	call   80104b07 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 f0 2f 00 00       	call   80104be6 <acquire>
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
80101c10:	e8 3f 30 00 00       	call   80104c54 <release>
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
80101d54:	68 aa a8 10 80       	push   $0x8010a8aa
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
80101ff2:	e8 24 2f 00 00       	call   80104f1b <memmove>
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
80102142:	e8 d4 2d 00 00       	call   80104f1b <memmove>
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
801021c2:	e8 ea 2d 00 00       	call   80104fb1 <strncmp>
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
801021e2:	68 bd a8 10 80       	push   $0x8010a8bd
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
80102211:	68 cf a8 10 80       	push   $0x8010a8cf
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
801022e6:	68 de a8 10 80       	push   $0x8010a8de
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
80102321:	e8 e1 2c 00 00       	call   80105007 <strncpy>
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
8010234d:	68 eb a8 10 80       	push   $0x8010a8eb
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
801023bf:	e8 57 2b 00 00       	call   80104f1b <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 40 2b 00 00       	call   80104f1b <memmove>
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
801025cd:	68 f4 a8 10 80       	push   $0x8010a8f4
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
80102674:	68 26 a9 10 80       	push   $0x8010a926
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 41 25 00 00       	call   80104bc4 <initlock>
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
80102733:	68 2b a9 10 80       	push   $0x8010a92b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 0d 27 00 00       	call   80104e5c <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 7e 24 00 00       	call   80104be6 <acquire>
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
80102795:	e8 ba 24 00 00       	call   80104c54 <release>
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
801027b7:	e8 2a 24 00 00       	call   80104be6 <acquire>
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
801027e8:	e8 67 24 00 00       	call   80104c54 <release>
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
80102d12:	e8 ac 21 00 00       	call   80104ec3 <memcmp>
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
80102e26:	68 31 a9 10 80       	push   $0x8010a931
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 8f 1d 00 00       	call   80104bc4 <initlock>
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
80102edb:	e8 3b 20 00 00       	call   80104f1b <memmove>
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
8010304a:	e8 97 1b 00 00       	call   80104be6 <acquire>
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
80103068:	e8 f4 14 00 00       	call   80104561 <sleep>
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
8010309d:	e8 bf 14 00 00       	call   80104561 <sleep>
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
801030bc:	e8 93 1b 00 00       	call   80104c54 <release>
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
801030dd:	e8 04 1b 00 00       	call   80104be6 <acquire>
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
801030fe:	68 35 a9 10 80       	push   $0x8010a935
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
8010312c:	e8 1a 15 00 00       	call   8010464b <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 13 1b 00 00       	call   80104c54 <release>
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
80103157:	e8 8a 1a 00 00       	call   80104be6 <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 d5 14 00 00       	call   8010464b <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 ce 1a 00 00       	call   80104c54 <release>
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
801031fd:	e8 19 1d 00 00       	call   80104f1b <memmove>
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
8010329a:	68 44 a9 10 80       	push   $0x8010a944
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 5a a9 10 80       	push   $0x8010a95a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 1f 19 00 00       	call   80104be6 <acquire>
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
80103340:	e8 0f 19 00 00       	call   80104c54 <release>
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
80103376:	e8 35 51 00 00       	call   801084b0 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 35 47 00 00       	call   80107aca <kvmalloc>
  mpinit_uefi();
80103395:	e8 dc 4e 00 00       	call   80108276 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 be 41 00 00       	call   80107562 <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 43 35 00 00       	call   801068fb <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 ed 2e 00 00       	call   801062af <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 20 72 00 00       	call   8010a5f1 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 19 53 00 00       	call   80108709 <pci_init>
  arp_scan();
801033f0:	e8 50 60 00 00       	call   80109445 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 e1 07 00 00       	call   80103bdb <userinit>

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
80103405:	e8 d8 46 00 00       	call   80107ae2 <switchkvm>
  seginit();
8010340a:	e8 53 41 00 00       	call   80107562 <seginit>
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
80103431:	68 75 a9 10 80       	push   $0x8010a975
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 e2 2f 00 00       	call   80106425 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 9e 05 00 00       	call   801039e6 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 3c 0d 00 00       	call   8010419c <scheduler>

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
80103476:	68 58 f5 10 80       	push   $0x8010f558
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 98 1a 00 00       	call   80104f1b <memmove>
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
80103607:	68 89 a9 10 80       	push   $0x8010a989
8010360c:	50                   	push   %eax
8010360d:	e8 b2 15 00 00       	call   80104bc4 <initlock>
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
801036cc:	e8 15 15 00 00       	call   80104be6 <acquire>
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
801036f3:	e8 53 0f 00 00       	call   8010464b <wakeup>
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
80103716:	e8 30 0f 00 00       	call   8010464b <wakeup>
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
8010373f:	e8 10 15 00 00       	call   80104c54 <release>
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
8010375e:	e8 f1 14 00 00       	call   80104c54 <release>
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
80103778:	e8 69 14 00 00       	call   80104be6 <acquire>
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
801037ac:	e8 a3 14 00 00       	call   80104c54 <release>
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
801037ca:	e8 7c 0e 00 00       	call   8010464b <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 79 0d 00 00       	call   80104561 <sleep>
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
8010384d:	e8 f9 0d 00 00       	call   8010464b <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 f3 13 00 00       	call   80104c54 <release>
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
80103879:	e8 68 13 00 00       	call   80104be6 <acquire>
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
80103896:	e8 b9 13 00 00       	call   80104c54 <release>
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
801038b9:	e8 a3 0c 00 00       	call   80104561 <sleep>
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
8010394c:	e8 fa 0c 00 00       	call   8010464b <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 f4 12 00 00       	call   80104c54 <release>
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

int max_tick[4] = {0, 32, 16, 8};  // Q0은 FIFO라서 0

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 90 a9 10 80       	push   $0x8010a990
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 2d 12 00 00       	call   80104bc4 <initlock>
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
801039b5:	e8 4f 0d 00 00       	call   80104709 <initqueue>
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
801039fd:	68 98 a9 10 80       	push   $0x8010a998
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
80103a52:	68 be a9 10 80       	push   $0x8010a9be
80103a57:	e8 4d cb ff ff       	call   801005a9 <panic>
}
80103a5c:	c9                   	leave  
80103a5d:	c3                   	ret    

80103a5e <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc* //수정
myproc(void) {
80103a5e:	55                   	push   %ebp
80103a5f:	89 e5                	mov    %esp,%ebp
80103a61:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  
  pushcli();
80103a64:	e8 e8 12 00 00       	call   80104d51 <pushcli>
  c= mycpu();
80103a69:	e8 78 ff ff ff       	call   801039e6 <mycpu>
80103a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p=c->proc;
80103a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a74:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a7d:	e8 1c 13 00 00       	call   80104d9e <popcli>
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
80103a95:	e8 4c 11 00 00       	call   80104be6 <acquire>
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
80103ac8:	e8 87 11 00 00       	call   80104c54 <release>
80103acd:	83 c4 10             	add    $0x10,%esp
  return 0;
80103ad0:	b8 00 00 00 00       	mov    $0x0,%eax
80103ad5:	e9 ff 00 00 00       	jmp    80103bd9 <allocproc+0x152>
      goto found;
80103ada:	90                   	nop

found:
  memset(p, 0, sizeof(*p));  // ← 이거 꼭 필요함!
80103adb:	83 ec 04             	sub    $0x4,%esp
80103ade:	68 a0 00 00 00       	push   $0xa0
80103ae3:	6a 00                	push   $0x0
80103ae5:	ff 75 f4             	push   -0xc(%ebp)
80103ae8:	e8 6f 13 00 00       	call   80104e5c <memset>
80103aed:	83 c4 10             	add    $0x10,%esp
  p->state = EMBRYO;
80103af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af3:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103afa:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103aff:	8d 50 01             	lea    0x1(%eax),%edx
80103b02:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103b08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b0b:	89 42 10             	mov    %eax,0x10(%edx)

  //추가
  p->priority = 3;  // Q3에서 시작
80103b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b11:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  memset(p->ticks, 0, sizeof(p->ticks));
80103b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1b:	83 e8 80             	sub    $0xffffff80,%eax
80103b1e:	83 ec 04             	sub    $0x4,%esp
80103b21:	6a 10                	push   $0x10
80103b23:	6a 00                	push   $0x0
80103b25:	50                   	push   %eax
80103b26:	e8 31 13 00 00       	call   80104e5c <memset>
80103b2b:	83 c4 10             	add    $0x10,%esp
  memset(p->wait_ticks, 0, sizeof(p->wait_ticks)); //
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b31:	05 90 00 00 00       	add    $0x90,%eax
80103b36:	83 ec 04             	sub    $0x4,%esp
80103b39:	6a 10                	push   $0x10
80103b3b:	6a 00                	push   $0x0
80103b3d:	50                   	push   %eax
80103b3e:	e8 19 13 00 00       	call   80104e5c <memset>
80103b43:	83 c4 10             	add    $0x10,%esp

  
  release(&ptable.lock);
80103b46:	83 ec 0c             	sub    $0xc,%esp
80103b49:	68 00 42 19 80       	push   $0x80194200
80103b4e:	e8 01 11 00 00       	call   80104c54 <release>
80103b53:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103b56:	e8 45 ec ff ff       	call   801027a0 <kalloc>
80103b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b5e:	89 42 08             	mov    %eax,0x8(%edx)
80103b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b64:	8b 40 08             	mov    0x8(%eax),%eax
80103b67:	85 c0                	test   %eax,%eax
80103b69:	75 11                	jne    80103b7c <allocproc+0xf5>
    p->state = UNUSED;
80103b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b75:	b8 00 00 00 00       	mov    $0x0,%eax
80103b7a:	eb 5d                	jmp    80103bd9 <allocproc+0x152>
  }
  sp = p->kstack + KSTACKSIZE;
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	8b 40 08             	mov    0x8(%eax),%eax
80103b82:	05 00 10 00 00       	add    $0x1000,%eax
80103b87:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b8a:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b91:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b94:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b97:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b9b:	ba 69 62 10 80       	mov    $0x80106269,%edx
80103ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba3:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103ba5:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bac:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103baf:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bb8:	83 ec 04             	sub    $0x4,%esp
80103bbb:	6a 14                	push   $0x14
80103bbd:	6a 00                	push   $0x0
80103bbf:	50                   	push   %eax
80103bc0:	e8 97 12 00 00       	call   80104e5c <memset>
80103bc5:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcb:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bce:	ba 1b 45 10 80       	mov    $0x8010451b,%edx
80103bd3:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103bd9:	c9                   	leave  
80103bda:	c3                   	ret    

80103bdb <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103bdb:	55                   	push   %ebp
80103bdc:	89 e5                	mov    %esp,%ebp
80103bde:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103be1:	e8 a1 fe ff ff       	call   80103a87 <allocproc>
80103be6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bec:	a3 60 6e 19 80       	mov    %eax,0x80196e60
  if((p->pgdir = setupkvm()) == 0){
80103bf1:	e8 e8 3d 00 00       	call   801079de <setupkvm>
80103bf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bf9:	89 42 04             	mov    %eax,0x4(%edx)
80103bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bff:	8b 40 04             	mov    0x4(%eax),%eax
80103c02:	85 c0                	test   %eax,%eax
80103c04:	75 0d                	jne    80103c13 <userinit+0x38>
    panic("userinit: out of memory?");
80103c06:	83 ec 0c             	sub    $0xc,%esp
80103c09:	68 ce a9 10 80       	push   $0x8010a9ce
80103c0e:	e8 96 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103c13:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1b:	8b 40 04             	mov    0x4(%eax),%eax
80103c1e:	83 ec 04             	sub    $0x4,%esp
80103c21:	52                   	push   %edx
80103c22:	68 2c f5 10 80       	push   $0x8010f52c
80103c27:	50                   	push   %eax
80103c28:	e8 6d 40 00 00       	call   80107c9a <inituvm>
80103c2d:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c33:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3c:	8b 40 18             	mov    0x18(%eax),%eax
80103c3f:	83 ec 04             	sub    $0x4,%esp
80103c42:	6a 4c                	push   $0x4c
80103c44:	6a 00                	push   $0x0
80103c46:	50                   	push   %eax
80103c47:	e8 10 12 00 00       	call   80104e5c <memset>
80103c4c:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c52:	8b 40 18             	mov    0x18(%eax),%eax
80103c55:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5e:	8b 40 18             	mov    0x18(%eax),%eax
80103c61:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6a:	8b 50 18             	mov    0x18(%eax),%edx
80103c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c70:	8b 40 18             	mov    0x18(%eax),%eax
80103c73:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c77:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7e:	8b 50 18             	mov    0x18(%eax),%edx
80103c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c84:	8b 40 18             	mov    0x18(%eax),%eax
80103c87:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c8b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c92:	8b 40 18             	mov    0x18(%eax),%eax
80103c95:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9f:	8b 40 18             	mov    0x18(%eax),%eax
80103ca2:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cac:	8b 40 18             	mov    0x18(%eax),%eax
80103caf:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb9:	83 c0 6c             	add    $0x6c,%eax
80103cbc:	83 ec 04             	sub    $0x4,%esp
80103cbf:	6a 10                	push   $0x10
80103cc1:	68 e7 a9 10 80       	push   $0x8010a9e7
80103cc6:	50                   	push   %eax
80103cc7:	e8 93 13 00 00       	call   8010505f <safestrcpy>
80103ccc:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103ccf:	83 ec 0c             	sub    $0xc,%esp
80103cd2:	68 f0 a9 10 80       	push   $0x8010a9f0
80103cd7:	e8 41 e8 ff ff       	call   8010251d <namei>
80103cdc:	83 c4 10             	add    $0x10,%esp
80103cdf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ce2:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103ce5:	83 ec 0c             	sub    $0xc,%esp
80103ce8:	68 00 42 19 80       	push   $0x80194200
80103ced:	e8 f4 0e 00 00       	call   80104be6 <acquire>
80103cf2:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  enqueue(&mlfq[3], p);  // ← 필수!
80103cff:	83 ec 08             	sub    $0x8,%esp
80103d02:	ff 75 f4             	push   -0xc(%ebp)
80103d05:	68 58 6d 19 80       	push   $0x80196d58
80103d0a:	e8 39 0a 00 00       	call   80104748 <enqueue>
80103d0f:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80103d12:	83 ec 0c             	sub    $0xc,%esp
80103d15:	68 00 42 19 80       	push   $0x80194200
80103d1a:	e8 35 0f 00 00       	call   80104c54 <release>
80103d1f:	83 c4 10             	add    $0x10,%esp
}
80103d22:	90                   	nop
80103d23:	c9                   	leave  
80103d24:	c3                   	ret    

80103d25 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103d25:	55                   	push   %ebp
80103d26:	89 e5                	mov    %esp,%ebp
80103d28:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103d2b:	e8 2e fd ff ff       	call   80103a5e <myproc>
80103d30:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d36:	8b 00                	mov    (%eax),%eax
80103d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103d3b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d3f:	7e 2e                	jle    80103d6f <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d41:	8b 55 08             	mov    0x8(%ebp),%edx
80103d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d47:	01 c2                	add    %eax,%edx
80103d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4c:	8b 40 04             	mov    0x4(%eax),%eax
80103d4f:	83 ec 04             	sub    $0x4,%esp
80103d52:	52                   	push   %edx
80103d53:	ff 75 f4             	push   -0xc(%ebp)
80103d56:	50                   	push   %eax
80103d57:	e8 7b 40 00 00       	call   80107dd7 <allocuvm>
80103d5c:	83 c4 10             	add    $0x10,%esp
80103d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d66:	75 3b                	jne    80103da3 <growproc+0x7e>
      return -1;
80103d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d6d:	eb 4f                	jmp    80103dbe <growproc+0x99>
  } else if(n < 0){
80103d6f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d73:	79 2e                	jns    80103da3 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d75:	8b 55 08             	mov    0x8(%ebp),%edx
80103d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7b:	01 c2                	add    %eax,%edx
80103d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d80:	8b 40 04             	mov    0x4(%eax),%eax
80103d83:	83 ec 04             	sub    $0x4,%esp
80103d86:	52                   	push   %edx
80103d87:	ff 75 f4             	push   -0xc(%ebp)
80103d8a:	50                   	push   %eax
80103d8b:	e8 4c 41 00 00       	call   80107edc <deallocuvm>
80103d90:	83 c4 10             	add    $0x10,%esp
80103d93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d9a:	75 07                	jne    80103da3 <growproc+0x7e>
      return -1;
80103d9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103da1:	eb 1b                	jmp    80103dbe <growproc+0x99>
  }
  curproc->sz = sz;
80103da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103da6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103da9:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103dab:	83 ec 0c             	sub    $0xc,%esp
80103dae:	ff 75 f0             	push   -0x10(%ebp)
80103db1:	e8 45 3d 00 00       	call   80107afb <switchuvm>
80103db6:	83 c4 10             	add    $0x10,%esp
  return 0;
80103db9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103dbe:	c9                   	leave  
80103dbf:	c3                   	ret    

80103dc0 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103dc0:	55                   	push   %ebp
80103dc1:	89 e5                	mov    %esp,%ebp
80103dc3:	57                   	push   %edi
80103dc4:	56                   	push   %esi
80103dc5:	53                   	push   %ebx
80103dc6:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103dc9:	e8 90 fc ff ff       	call   80103a5e <myproc>
80103dce:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103dd1:	e8 b1 fc ff ff       	call   80103a87 <allocproc>
80103dd6:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103dd9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103ddd:	75 0a                	jne    80103de9 <fork+0x29>
    return -1;
80103ddf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103de4:	e9 65 01 00 00       	jmp    80103f4e <fork+0x18e>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dec:	8b 10                	mov    (%eax),%edx
80103dee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103df1:	8b 40 04             	mov    0x4(%eax),%eax
80103df4:	83 ec 08             	sub    $0x8,%esp
80103df7:	52                   	push   %edx
80103df8:	50                   	push   %eax
80103df9:	e8 7c 42 00 00       	call   8010807a <copyuvm>
80103dfe:	83 c4 10             	add    $0x10,%esp
80103e01:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e04:	89 42 04             	mov    %eax,0x4(%edx)
80103e07:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e0a:	8b 40 04             	mov    0x4(%eax),%eax
80103e0d:	85 c0                	test   %eax,%eax
80103e0f:	75 30                	jne    80103e41 <fork+0x81>
    kfree(np->kstack);
80103e11:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e14:	8b 40 08             	mov    0x8(%eax),%eax
80103e17:	83 ec 0c             	sub    $0xc,%esp
80103e1a:	50                   	push   %eax
80103e1b:	e8 e6 e8 ff ff       	call   80102706 <kfree>
80103e20:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103e23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103e2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e30:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103e37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e3c:	e9 0d 01 00 00       	jmp    80103f4e <fork+0x18e>
  }
  np->sz = curproc->sz;
80103e41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e44:	8b 10                	mov    (%eax),%edx
80103e46:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e49:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103e51:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e57:	8b 48 18             	mov    0x18(%eax),%ecx
80103e5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5d:	8b 40 18             	mov    0x18(%eax),%eax
80103e60:	89 c2                	mov    %eax,%edx
80103e62:	89 cb                	mov    %ecx,%ebx
80103e64:	b8 13 00 00 00       	mov    $0x13,%eax
80103e69:	89 d7                	mov    %edx,%edi
80103e6b:	89 de                	mov    %ebx,%esi
80103e6d:	89 c1                	mov    %eax,%ecx
80103e6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e71:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e74:	8b 40 18             	mov    0x18(%eax),%eax
80103e77:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103e7e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e85:	eb 3b                	jmp    80103ec2 <fork+0x102>
    if(curproc->ofile[i])
80103e87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e8d:	83 c2 08             	add    $0x8,%edx
80103e90:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e94:	85 c0                	test   %eax,%eax
80103e96:	74 26                	je     80103ebe <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e9e:	83 c2 08             	add    $0x8,%edx
80103ea1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ea5:	83 ec 0c             	sub    $0xc,%esp
80103ea8:	50                   	push   %eax
80103ea9:	e8 9c d1 ff ff       	call   8010104a <filedup>
80103eae:	83 c4 10             	add    $0x10,%esp
80103eb1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103eb4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103eb7:	83 c1 08             	add    $0x8,%ecx
80103eba:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103ebe:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103ec2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103ec6:	7e bf                	jle    80103e87 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103ec8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ecb:	8b 40 68             	mov    0x68(%eax),%eax
80103ece:	83 ec 0c             	sub    $0xc,%esp
80103ed1:	50                   	push   %eax
80103ed2:	e8 d9 da ff ff       	call   801019b0 <idup>
80103ed7:	83 c4 10             	add    $0x10,%esp
80103eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103edd:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103ee0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ee3:	8d 50 6c             	lea    0x6c(%eax),%edx
80103ee6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ee9:	83 c0 6c             	add    $0x6c,%eax
80103eec:	83 ec 04             	sub    $0x4,%esp
80103eef:	6a 10                	push   $0x10
80103ef1:	52                   	push   %edx
80103ef2:	50                   	push   %eax
80103ef3:	e8 67 11 00 00       	call   8010505f <safestrcpy>
80103ef8:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103efb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103efe:	8b 40 10             	mov    0x10(%eax),%eax
80103f01:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103f04:	83 ec 0c             	sub    $0xc,%esp
80103f07:	68 00 42 19 80       	push   $0x80194200
80103f0c:	e8 d5 0c 00 00       	call   80104be6 <acquire>
80103f11:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103f14:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f17:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  np->priority = 3;
80103f1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f21:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  enqueue(&mlfq[3], np);  // ← 필수!
80103f28:	83 ec 08             	sub    $0x8,%esp
80103f2b:	ff 75 dc             	push   -0x24(%ebp)
80103f2e:	68 58 6d 19 80       	push   $0x80196d58
80103f33:	e8 10 08 00 00       	call   80104748 <enqueue>
80103f38:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80103f3b:	83 ec 0c             	sub    $0xc,%esp
80103f3e:	68 00 42 19 80       	push   $0x80194200
80103f43:	e8 0c 0d 00 00       	call   80104c54 <release>
80103f48:	83 c4 10             	add    $0x10,%esp

  return pid;
80103f4b:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f51:	5b                   	pop    %ebx
80103f52:	5e                   	pop    %esi
80103f53:	5f                   	pop    %edi
80103f54:	5d                   	pop    %ebp
80103f55:	c3                   	ret    

80103f56 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103f56:	55                   	push   %ebp
80103f57:	89 e5                	mov    %esp,%ebp
80103f59:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103f5c:	e8 fd fa ff ff       	call   80103a5e <myproc>
80103f61:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103f64:	a1 60 6e 19 80       	mov    0x80196e60,%eax
80103f69:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f6c:	75 0d                	jne    80103f7b <exit+0x25>
    panic("init exiting");
80103f6e:	83 ec 0c             	sub    $0xc,%esp
80103f71:	68 f2 a9 10 80       	push   $0x8010a9f2
80103f76:	e8 2e c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103f7b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103f82:	eb 3f                	jmp    80103fc3 <exit+0x6d>
    if(curproc->ofile[fd]){
80103f84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f87:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f8a:	83 c2 08             	add    $0x8,%edx
80103f8d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f91:	85 c0                	test   %eax,%eax
80103f93:	74 2a                	je     80103fbf <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103f95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f98:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f9b:	83 c2 08             	add    $0x8,%edx
80103f9e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fa2:	83 ec 0c             	sub    $0xc,%esp
80103fa5:	50                   	push   %eax
80103fa6:	e8 f0 d0 ff ff       	call   8010109b <fileclose>
80103fab:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103fae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fb1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fb4:	83 c2 08             	add    $0x8,%edx
80103fb7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103fbe:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103fbf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103fc3:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103fc7:	7e bb                	jle    80103f84 <exit+0x2e>
    }
  }

  begin_op();
80103fc9:	e8 6e f0 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103fce:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fd1:	8b 40 68             	mov    0x68(%eax),%eax
80103fd4:	83 ec 0c             	sub    $0xc,%esp
80103fd7:	50                   	push   %eax
80103fd8:	e8 6e db ff ff       	call   80101b4b <iput>
80103fdd:	83 c4 10             	add    $0x10,%esp
  end_op();
80103fe0:	e8 e3 f0 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80103fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fe8:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103fef:	83 ec 0c             	sub    $0xc,%esp
80103ff2:	68 00 42 19 80       	push   $0x80194200
80103ff7:	e8 ea 0b 00 00       	call   80104be6 <acquire>
80103ffc:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103fff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104002:	8b 40 14             	mov    0x14(%eax),%eax
80104005:	83 ec 0c             	sub    $0xc,%esp
80104008:	50                   	push   %eax
80104009:	e8 fa 05 00 00       	call   80104608 <wakeup1>
8010400e:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104011:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104018:	eb 3a                	jmp    80104054 <exit+0xfe>
    if(p->parent == curproc){
8010401a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401d:	8b 40 14             	mov    0x14(%eax),%eax
80104020:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104023:	75 28                	jne    8010404d <exit+0xf7>
      p->parent = initproc;
80104025:	8b 15 60 6e 19 80    	mov    0x80196e60,%edx
8010402b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402e:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104034:	8b 40 0c             	mov    0xc(%eax),%eax
80104037:	83 f8 05             	cmp    $0x5,%eax
8010403a:	75 11                	jne    8010404d <exit+0xf7>
        wakeup1(initproc);
8010403c:	a1 60 6e 19 80       	mov    0x80196e60,%eax
80104041:	83 ec 0c             	sub    $0xc,%esp
80104044:	50                   	push   %eax
80104045:	e8 be 05 00 00       	call   80104608 <wakeup1>
8010404a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010404d:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104054:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
8010405b:	72 bd                	jb     8010401a <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010405d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104060:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104067:	e8 b6 03 00 00       	call   80104422 <sched>
  panic("zombie exit");
8010406c:	83 ec 0c             	sub    $0xc,%esp
8010406f:	68 ff a9 10 80       	push   $0x8010a9ff
80104074:	e8 30 c5 ff ff       	call   801005a9 <panic>

80104079 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104079:	55                   	push   %ebp
8010407a:	89 e5                	mov    %esp,%ebp
8010407c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010407f:	e8 da f9 ff ff       	call   80103a5e <myproc>
80104084:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104087:	83 ec 0c             	sub    $0xc,%esp
8010408a:	68 00 42 19 80       	push   $0x80194200
8010408f:	e8 52 0b 00 00       	call   80104be6 <acquire>
80104094:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104097:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010409e:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801040a5:	e9 a4 00 00 00       	jmp    8010414e <wait+0xd5>
      if(p->parent != curproc)
801040aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ad:	8b 40 14             	mov    0x14(%eax),%eax
801040b0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040b3:	0f 85 8d 00 00 00    	jne    80104146 <wait+0xcd>
        continue;
      havekids = 1;
801040b9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801040c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c3:	8b 40 0c             	mov    0xc(%eax),%eax
801040c6:	83 f8 05             	cmp    $0x5,%eax
801040c9:	75 7c                	jne    80104147 <wait+0xce>
        // Found one.
        pid = p->pid;
801040cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ce:	8b 40 10             	mov    0x10(%eax),%eax
801040d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801040d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d7:	8b 40 08             	mov    0x8(%eax),%eax
801040da:	83 ec 0c             	sub    $0xc,%esp
801040dd:	50                   	push   %eax
801040de:	e8 23 e6 ff ff       	call   80102706 <kfree>
801040e3:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801040e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801040f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f3:	8b 40 04             	mov    0x4(%eax),%eax
801040f6:	83 ec 0c             	sub    $0xc,%esp
801040f9:	50                   	push   %eax
801040fa:	e8 a1 3e 00 00       	call   80107fa0 <freevm>
801040ff:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104105:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010410c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104119:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010411d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104120:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104131:	83 ec 0c             	sub    $0xc,%esp
80104134:	68 00 42 19 80       	push   $0x80194200
80104139:	e8 16 0b 00 00       	call   80104c54 <release>
8010413e:	83 c4 10             	add    $0x10,%esp
        return pid;
80104141:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104144:	eb 54                	jmp    8010419a <wait+0x121>
        continue;
80104146:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104147:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
8010414e:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80104155:	0f 82 4f ff ff ff    	jb     801040aa <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010415b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010415f:	74 0a                	je     8010416b <wait+0xf2>
80104161:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104164:	8b 40 24             	mov    0x24(%eax),%eax
80104167:	85 c0                	test   %eax,%eax
80104169:	74 17                	je     80104182 <wait+0x109>
      release(&ptable.lock);
8010416b:	83 ec 0c             	sub    $0xc,%esp
8010416e:	68 00 42 19 80       	push   $0x80194200
80104173:	e8 dc 0a 00 00       	call   80104c54 <release>
80104178:	83 c4 10             	add    $0x10,%esp
      return -1;
8010417b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104180:	eb 18                	jmp    8010419a <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104182:	83 ec 08             	sub    $0x8,%esp
80104185:	68 00 42 19 80       	push   $0x80194200
8010418a:	ff 75 ec             	push   -0x14(%ebp)
8010418d:	e8 cf 03 00 00       	call   80104561 <sleep>
80104192:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104195:	e9 fd fe ff ff       	jmp    80104097 <wait+0x1e>
  }
}
8010419a:	c9                   	leave  
8010419b:	c3                   	ret    

8010419c <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010419c:	55                   	push   %ebp
8010419d:	89 e5                	mov    %esp,%ebp
8010419f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801041a2:	e8 3f f8 ff ff       	call   801039e6 <mycpu>
801041a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
801041aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041ad:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041b4:	00 00 00 

  for (;;) {
    sti();
801041b7:	e8 bc f7 ff ff       	call   80103978 <sti>
    acquire(&ptable.lock);
801041bc:	83 ec 0c             	sub    $0xc,%esp
801041bf:	68 00 42 19 80       	push   $0x80194200
801041c4:	e8 1d 0a 00 00       	call   80104be6 <acquire>
801041c9:	83 c4 10             	add    $0x10,%esp

    int scheduled = 0;
801041cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    // MLFQ 
    if (c->sched_policy == 1) {
801041d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041d6:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801041dc:	83 f8 01             	cmp    $0x1,%eax
801041df:	0f 85 ac 01 00 00    	jne    80104391 <scheduler+0x1f5>
      for(int level =3; level >= 0; level--)  {
801041e5:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
801041ec:	e9 97 01 00 00       	jmp    80104388 <scheduler+0x1ec>
        while (!isempty(&mlfq[level])) {
          p = dequeue(&mlfq[level]);
801041f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041f4:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
801041fa:	05 40 6a 19 80       	add    $0x80196a40,%eax
801041ff:	83 ec 0c             	sub    $0xc,%esp
80104202:	50                   	push   %eax
80104203:	e8 ad 05 00 00       	call   801047b5 <dequeue>
80104208:	83 c4 10             	add    $0x10,%esp
8010420b:	89 45 f4             	mov    %eax,-0xc(%ebp)
          if ( !p || p->state != RUNNABLE)
8010420e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104212:	0f 84 44 01 00 00    	je     8010435c <scheduler+0x1c0>
80104218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421b:	8b 40 0c             	mov    0xc(%eax),%eax
8010421e:	83 f8 03             	cmp    $0x3,%eax
80104221:	74 05                	je     80104228 <scheduler+0x8c>
            continue;
80104223:	e9 34 01 00 00       	jmp    8010435c <scheduler+0x1c0>

          scheduled = 1;
80104228:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

          c->proc = p;
8010422f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104232:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104235:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
8010423b:	83 ec 0c             	sub    $0xc,%esp
8010423e:	ff 75 f4             	push   -0xc(%ebp)
80104241:	e8 b5 38 00 00       	call   80107afb <switchuvm>
80104246:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
80104249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

          swtch(&c->scheduler, p->context);
80104253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104256:	8b 40 1c             	mov    0x1c(%eax),%eax
80104259:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010425c:	83 c2 04             	add    $0x4,%edx
8010425f:	83 ec 08             	sub    $0x8,%esp
80104262:	50                   	push   %eax
80104263:	52                   	push   %edx
80104264:	e8 68 0e 00 00       	call   801050d1 <swtch>
80104269:	83 c4 10             	add    $0x10,%esp
          switchkvm();
8010426c:	e8 71 38 00 00       	call   80107ae2 <switchkvm>

          c->proc = 0;
80104271:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104274:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010427b:	00 00 00 

          int cur_lvl = p->priority;
8010427e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104281:	8b 40 7c             	mov    0x7c(%eax),%eax
80104284:	89 45 e4             	mov    %eax,-0x1c(%ebp)

          // ✳️ demote 기준은 trap.c에서 tick 누적값을 기반으로
          // trap.c에서 tick 누적하고 여기서 demote 판단
          if (p->state == RUNNABLE && p->ticks[cur_lvl] >= max_tick[cur_lvl]) {
80104287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010428a:	8b 40 0c             	mov    0xc(%eax),%eax
8010428d:	83 f8 03             	cmp    $0x3,%eax
80104290:	75 7d                	jne    8010430f <scheduler+0x173>
80104292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104295:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104298:	83 c2 20             	add    $0x20,%edx
8010429b:	8b 14 90             	mov    (%eax,%edx,4),%edx
8010429e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801042a1:	8b 04 85 04 f0 10 80 	mov    -0x7fef0ffc(,%eax,4),%eax
801042a8:	39 c2                	cmp    %eax,%edx
801042aa:	7c 63                	jl     8010430f <scheduler+0x173>
            if (cur_lvl > 0){
801042ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801042b0:	7e 3d                	jle    801042ef <scheduler+0x153>
              p->priority--;
801042b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b5:	8b 40 7c             	mov    0x7c(%eax),%eax
801042b8:	8d 50 ff             	lea    -0x1(%eax),%edx
801042bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042be:	89 50 7c             	mov    %edx,0x7c(%eax)
              cprintf("[demote] pid %d: Q%d → Q%d (tick=%d)\n",
801042c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042c7:	83 c2 20             	add    $0x20,%edx
801042ca:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
801042cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d0:	8b 50 7c             	mov    0x7c(%eax),%edx
801042d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d6:	8b 40 10             	mov    0x10(%eax),%eax
801042d9:	83 ec 0c             	sub    $0xc,%esp
801042dc:	51                   	push   %ecx
801042dd:	52                   	push   %edx
801042de:	ff 75 e4             	push   -0x1c(%ebp)
801042e1:	50                   	push   %eax
801042e2:	68 0c aa 10 80       	push   $0x8010aa0c
801042e7:	e8 08 c1 ff ff       	call   801003f4 <cprintf>
801042ec:	83 c4 20             	add    $0x20,%esp
                      p->pid, cur_lvl, p->priority, p->ticks[cur_lvl]);
            }
            p->ticks[cur_lvl] = 0;
801042ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042f5:	83 c2 20             	add    $0x20,%edx
801042f8:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
            p->wait_ticks[cur_lvl] = 0;
801042ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104302:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104305:	83 c2 24             	add    $0x24,%edx
80104308:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
          }
          //  enqueue는 priority에 따라 다시 큐로
          enqueue(&mlfq[p->priority], p);  // 아래 큐에 넣기
8010430f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104312:	8b 40 7c             	mov    0x7c(%eax),%eax
80104315:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
8010431b:	05 40 6a 19 80       	add    $0x80196a40,%eax
80104320:	83 ec 08             	sub    $0x8,%esp
80104323:	ff 75 f4             	push   -0xc(%ebp)
80104326:	50                   	push   %eax
80104327:	e8 1c 04 00 00       	call   80104748 <enqueue>
8010432c:	83 c4 10             	add    $0x10,%esp
          cprintf("[requeue] pid %d: stay Q%d (tick=%d)\n",
                  p->pid, p->priority, p->ticks[p->priority]);
8010432f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104332:	8b 50 7c             	mov    0x7c(%eax),%edx
          cprintf("[requeue] pid %d: stay Q%d (tick=%d)\n",
80104335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104338:	83 c2 20             	add    $0x20,%edx
8010433b:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
8010433e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104341:	8b 50 7c             	mov    0x7c(%eax),%edx
80104344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104347:	8b 40 10             	mov    0x10(%eax),%eax
8010434a:	51                   	push   %ecx
8010434b:	52                   	push   %edx
8010434c:	50                   	push   %eax
8010434d:	68 34 aa 10 80       	push   $0x8010aa34
80104352:	e8 9d c0 ff ff       	call   801003f4 <cprintf>
80104357:	83 c4 10             	add    $0x10,%esp
          break;
8010435a:	eb 22                	jmp    8010437e <scheduler+0x1e2>
        while (!isempty(&mlfq[level])) {
8010435c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010435f:	69 c0 08 01 00 00    	imul   $0x108,%eax,%eax
80104365:	05 40 6a 19 80       	add    $0x80196a40,%eax
8010436a:	83 ec 0c             	sub    $0xc,%esp
8010436d:	50                   	push   %eax
8010436e:	e8 b6 03 00 00       	call   80104729 <isempty>
80104373:	83 c4 10             	add    $0x10,%esp
80104376:	85 c0                	test   %eax,%eax
80104378:	0f 84 73 fe ff ff    	je     801041f1 <scheduler+0x55>
        }
        if (scheduled) break;
8010437e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104382:	75 0c                	jne    80104390 <scheduler+0x1f4>
      for(int level =3; level >= 0; level--)  {
80104384:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
80104388:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010438c:	79 ce                	jns    8010435c <scheduler+0x1c0>
8010438e:	eb 01                	jmp    80104391 <scheduler+0x1f5>
        if (scheduled) break;
80104390:	90                   	nop
      }
    }
          
    //RR
    if (!scheduled) {
80104391:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104395:	75 76                	jne    8010440d <scheduler+0x271>
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104397:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010439e:	eb 64                	jmp    80104404 <scheduler+0x268>
        if (p->state != RUNNABLE)
801043a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a3:	8b 40 0c             	mov    0xc(%eax),%eax
801043a6:	83 f8 03             	cmp    $0x3,%eax
801043a9:	75 51                	jne    801043fc <scheduler+0x260>
          continue;
        c->proc = p;
801043ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b1:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
801043b7:	83 ec 0c             	sub    $0xc,%esp
801043ba:	ff 75 f4             	push   -0xc(%ebp)
801043bd:	e8 39 37 00 00       	call   80107afb <switchuvm>
801043c2:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
801043c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c8:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&c->scheduler, p->context);
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d2:	8b 40 1c             	mov    0x1c(%eax),%eax
801043d5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801043d8:	83 c2 04             	add    $0x4,%edx
801043db:	83 ec 08             	sub    $0x8,%esp
801043de:	50                   	push   %eax
801043df:	52                   	push   %edx
801043e0:	e8 ec 0c 00 00       	call   801050d1 <swtch>
801043e5:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801043e8:	e8 f5 36 00 00       	call   80107ae2 <switchkvm>

        c->proc = 0;
801043ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043f0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043f7:	00 00 00 
801043fa:	eb 01                	jmp    801043fd <scheduler+0x261>
          continue;
801043fc:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801043fd:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104404:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
8010440b:	72 93                	jb     801043a0 <scheduler+0x204>
      }
    }
    release(&ptable.lock);
8010440d:	83 ec 0c             	sub    $0xc,%esp
80104410:	68 00 42 19 80       	push   $0x80194200
80104415:	e8 3a 08 00 00       	call   80104c54 <release>
8010441a:	83 c4 10             	add    $0x10,%esp
  for (;;) {
8010441d:	e9 95 fd ff ff       	jmp    801041b7 <scheduler+0x1b>

80104422 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104422:	55                   	push   %ebp
80104423:	89 e5                	mov    %esp,%ebp
80104425:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104428:	e8 31 f6 ff ff       	call   80103a5e <myproc>
8010442d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104430:	83 ec 0c             	sub    $0xc,%esp
80104433:	68 00 42 19 80       	push   $0x80194200
80104438:	e8 e4 08 00 00       	call   80104d21 <holding>
8010443d:	83 c4 10             	add    $0x10,%esp
80104440:	85 c0                	test   %eax,%eax
80104442:	75 0d                	jne    80104451 <sched+0x2f>
    panic("sched ptable.lock");
80104444:	83 ec 0c             	sub    $0xc,%esp
80104447:	68 5a aa 10 80       	push   $0x8010aa5a
8010444c:	e8 58 c1 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104451:	e8 90 f5 ff ff       	call   801039e6 <mycpu>
80104456:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010445c:	83 f8 01             	cmp    $0x1,%eax
8010445f:	74 0d                	je     8010446e <sched+0x4c>
    panic("sched locks");
80104461:	83 ec 0c             	sub    $0xc,%esp
80104464:	68 6c aa 10 80       	push   $0x8010aa6c
80104469:	e8 3b c1 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
8010446e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104471:	8b 40 0c             	mov    0xc(%eax),%eax
80104474:	83 f8 04             	cmp    $0x4,%eax
80104477:	75 0d                	jne    80104486 <sched+0x64>
    panic("sched running");
80104479:	83 ec 0c             	sub    $0xc,%esp
8010447c:	68 78 aa 10 80       	push   $0x8010aa78
80104481:	e8 23 c1 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104486:	e8 dd f4 ff ff       	call   80103968 <readeflags>
8010448b:	25 00 02 00 00       	and    $0x200,%eax
80104490:	85 c0                	test   %eax,%eax
80104492:	74 0d                	je     801044a1 <sched+0x7f>
    panic("sched interruptible");
80104494:	83 ec 0c             	sub    $0xc,%esp
80104497:	68 86 aa 10 80       	push   $0x8010aa86
8010449c:	e8 08 c1 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
801044a1:	e8 40 f5 ff ff       	call   801039e6 <mycpu>
801044a6:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801044ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801044af:	e8 32 f5 ff ff       	call   801039e6 <mycpu>
801044b4:	8b 40 04             	mov    0x4(%eax),%eax
801044b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044ba:	83 c2 1c             	add    $0x1c,%edx
801044bd:	83 ec 08             	sub    $0x8,%esp
801044c0:	50                   	push   %eax
801044c1:	52                   	push   %edx
801044c2:	e8 0a 0c 00 00       	call   801050d1 <swtch>
801044c7:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801044ca:	e8 17 f5 ff ff       	call   801039e6 <mycpu>
801044cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044d2:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801044d8:	90                   	nop
801044d9:	c9                   	leave  
801044da:	c3                   	ret    

801044db <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{ 
801044db:	55                   	push   %ebp
801044dc:	89 e5                	mov    %esp,%ebp
801044de:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801044e1:	e8 78 f5 ff ff       	call   80103a5e <myproc>
801044e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&ptable.lock);  
801044e9:	83 ec 0c             	sub    $0xc,%esp
801044ec:	68 00 42 19 80       	push   $0x80194200
801044f1:	e8 f0 06 00 00       	call   80104be6 <acquire>
801044f6:	83 c4 10             	add    $0x10,%esp

  curproc->state = RUNNABLE;
801044f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();  // enqueue는 scheduler가 책임진다!
80104503:	e8 1a ff ff ff       	call   80104422 <sched>

  release(&ptable.lock);
80104508:	83 ec 0c             	sub    $0xc,%esp
8010450b:	68 00 42 19 80       	push   $0x80194200
80104510:	e8 3f 07 00 00       	call   80104c54 <release>
80104515:	83 c4 10             	add    $0x10,%esp
}
80104518:	90                   	nop
80104519:	c9                   	leave  
8010451a:	c3                   	ret    

8010451b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010451b:	55                   	push   %ebp
8010451c:	89 e5                	mov    %esp,%ebp
8010451e:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104521:	83 ec 0c             	sub    $0xc,%esp
80104524:	68 00 42 19 80       	push   $0x80194200
80104529:	e8 26 07 00 00       	call   80104c54 <release>
8010452e:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104531:	a1 14 f0 10 80       	mov    0x8010f014,%eax
80104536:	85 c0                	test   %eax,%eax
80104538:	74 24                	je     8010455e <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010453a:	c7 05 14 f0 10 80 00 	movl   $0x0,0x8010f014
80104541:	00 00 00 
    iinit(ROOTDEV);
80104544:	83 ec 0c             	sub    $0xc,%esp
80104547:	6a 01                	push   $0x1
80104549:	e8 2a d1 ff ff       	call   80101678 <iinit>
8010454e:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104551:	83 ec 0c             	sub    $0xc,%esp
80104554:	6a 01                	push   $0x1
80104556:	e8 c2 e8 ff ff       	call   80102e1d <initlog>
8010455b:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010455e:	90                   	nop
8010455f:	c9                   	leave  
80104560:	c3                   	ret    

80104561 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104561:	55                   	push   %ebp
80104562:	89 e5                	mov    %esp,%ebp
80104564:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104567:	e8 f2 f4 ff ff       	call   80103a5e <myproc>
8010456c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010456f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104573:	75 0d                	jne    80104582 <sleep+0x21>
    panic("sleep");
80104575:	83 ec 0c             	sub    $0xc,%esp
80104578:	68 9a aa 10 80       	push   $0x8010aa9a
8010457d:	e8 27 c0 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104582:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104586:	75 0d                	jne    80104595 <sleep+0x34>
    panic("sleep without lk");
80104588:	83 ec 0c             	sub    $0xc,%esp
8010458b:	68 a0 aa 10 80       	push   $0x8010aaa0
80104590:	e8 14 c0 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104595:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010459c:	74 1e                	je     801045bc <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010459e:	83 ec 0c             	sub    $0xc,%esp
801045a1:	68 00 42 19 80       	push   $0x80194200
801045a6:	e8 3b 06 00 00       	call   80104be6 <acquire>
801045ab:	83 c4 10             	add    $0x10,%esp
    release(lk);
801045ae:	83 ec 0c             	sub    $0xc,%esp
801045b1:	ff 75 0c             	push   0xc(%ebp)
801045b4:	e8 9b 06 00 00       	call   80104c54 <release>
801045b9:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801045bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bf:	8b 55 08             	mov    0x8(%ebp),%edx
801045c2:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801045c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801045cf:	e8 4e fe ff ff       	call   80104422 <sched>

  // Tidy up.
  p->chan = 0;
801045d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d7:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801045de:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801045e5:	74 1e                	je     80104605 <sleep+0xa4>
    release(&ptable.lock);
801045e7:	83 ec 0c             	sub    $0xc,%esp
801045ea:	68 00 42 19 80       	push   $0x80194200
801045ef:	e8 60 06 00 00       	call   80104c54 <release>
801045f4:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801045f7:	83 ec 0c             	sub    $0xc,%esp
801045fa:	ff 75 0c             	push   0xc(%ebp)
801045fd:	e8 e4 05 00 00       	call   80104be6 <acquire>
80104602:	83 c4 10             	add    $0x10,%esp
  }
}
80104605:	90                   	nop
80104606:	c9                   	leave  
80104607:	c3                   	ret    

80104608 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104608:	55                   	push   %ebp
80104609:	89 e5                	mov    %esp,%ebp
8010460b:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010460e:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104615:	eb 27                	jmp    8010463e <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104617:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010461a:	8b 40 0c             	mov    0xc(%eax),%eax
8010461d:	83 f8 02             	cmp    $0x2,%eax
80104620:	75 15                	jne    80104637 <wakeup1+0x2f>
80104622:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104625:	8b 40 20             	mov    0x20(%eax),%eax
80104628:	39 45 08             	cmp    %eax,0x8(%ebp)
8010462b:	75 0a                	jne    80104637 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010462d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104630:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104637:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
8010463e:	81 7d fc 34 6a 19 80 	cmpl   $0x80196a34,-0x4(%ebp)
80104645:	72 d0                	jb     80104617 <wakeup1+0xf>
}
80104647:	90                   	nop
80104648:	90                   	nop
80104649:	c9                   	leave  
8010464a:	c3                   	ret    

8010464b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010464b:	55                   	push   %ebp
8010464c:	89 e5                	mov    %esp,%ebp
8010464e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104651:	83 ec 0c             	sub    $0xc,%esp
80104654:	68 00 42 19 80       	push   $0x80194200
80104659:	e8 88 05 00 00       	call   80104be6 <acquire>
8010465e:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104661:	83 ec 0c             	sub    $0xc,%esp
80104664:	ff 75 08             	push   0x8(%ebp)
80104667:	e8 9c ff ff ff       	call   80104608 <wakeup1>
8010466c:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010466f:	83 ec 0c             	sub    $0xc,%esp
80104672:	68 00 42 19 80       	push   $0x80194200
80104677:	e8 d8 05 00 00       	call   80104c54 <release>
8010467c:	83 c4 10             	add    $0x10,%esp
}
8010467f:	90                   	nop
80104680:	c9                   	leave  
80104681:	c3                   	ret    

80104682 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104682:	55                   	push   %ebp
80104683:	89 e5                	mov    %esp,%ebp
80104685:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104688:	83 ec 0c             	sub    $0xc,%esp
8010468b:	68 00 42 19 80       	push   $0x80194200
80104690:	e8 51 05 00 00       	call   80104be6 <acquire>
80104695:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104698:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010469f:	eb 48                	jmp    801046e9 <kill+0x67>
    if(p->pid == pid){
801046a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a4:	8b 40 10             	mov    0x10(%eax),%eax
801046a7:	39 45 08             	cmp    %eax,0x8(%ebp)
801046aa:	75 36                	jne    801046e2 <kill+0x60>
      p->killed = 1;
801046ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046af:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801046b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b9:	8b 40 0c             	mov    0xc(%eax),%eax
801046bc:	83 f8 02             	cmp    $0x2,%eax
801046bf:	75 0a                	jne    801046cb <kill+0x49>
        p->state = RUNNABLE;
801046c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801046cb:	83 ec 0c             	sub    $0xc,%esp
801046ce:	68 00 42 19 80       	push   $0x80194200
801046d3:	e8 7c 05 00 00       	call   80104c54 <release>
801046d8:	83 c4 10             	add    $0x10,%esp
      return 0;
801046db:	b8 00 00 00 00       	mov    $0x0,%eax
801046e0:	eb 25                	jmp    80104707 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046e2:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801046e9:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
801046f0:	72 af                	jb     801046a1 <kill+0x1f>
    }
  }
  release(&ptable.lock);
801046f2:	83 ec 0c             	sub    $0xc,%esp
801046f5:	68 00 42 19 80       	push   $0x80194200
801046fa:	e8 55 05 00 00       	call   80104c54 <release>
801046ff:	83 c4 10             	add    $0x10,%esp
  return -1;
80104702:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104707:	c9                   	leave  
80104708:	c3                   	ret    

80104709 <initqueue>:
//큐 초기화
void initqueue(struct queue *q) {
80104709:	55                   	push   %ebp
8010470a:	89 e5                	mov    %esp,%ebp
  q->front = 0;
8010470c:	8b 45 08             	mov    0x8(%ebp),%eax
8010470f:	c7 80 00 01 00 00 00 	movl   $0x0,0x100(%eax)
80104716:	00 00 00 
  q->rear = 0;
80104719:	8b 45 08             	mov    0x8(%ebp),%eax
8010471c:	c7 80 04 01 00 00 00 	movl   $0x0,0x104(%eax)
80104723:	00 00 00 
}
80104726:	90                   	nop
80104727:	5d                   	pop    %ebp
80104728:	c3                   	ret    

80104729 <isempty>:

// 큐가 비었는지 확인
int isempty(struct queue *q) {
80104729:	55                   	push   %ebp
8010472a:	89 e5                	mov    %esp,%ebp
  return q->front == q->rear;
8010472c:	8b 45 08             	mov    0x8(%ebp),%eax
8010472f:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
80104735:	8b 45 08             	mov    0x8(%ebp),%eax
80104738:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
8010473e:	39 c2                	cmp    %eax,%edx
80104740:	0f 94 c0             	sete   %al
80104743:	0f b6 c0             	movzbl %al,%eax
}
80104746:	5d                   	pop    %ebp
80104747:	c3                   	ret    

80104748 <enqueue>:

// 큐에 중복없이 프로세스 추가
void enqueue(struct queue *q, struct proc *p) {
80104748:	55                   	push   %ebp
80104749:	89 e5                	mov    %esp,%ebp
8010474b:	83 ec 10             	sub    $0x10,%esp
  //이미 들어있는지 검사
  for (int i = q->front; i < q->rear; i++) {
8010474e:	8b 45 08             	mov    0x8(%ebp),%eax
80104751:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
80104757:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010475a:	eb 12                	jmp    8010476e <enqueue+0x26>
    if (q->q[i] == p)
8010475c:	8b 45 08             	mov    0x8(%ebp),%eax
8010475f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104762:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104765:	39 45 0c             	cmp    %eax,0xc(%ebp)
80104768:	74 48                	je     801047b2 <enqueue+0x6a>
  for (int i = q->front; i < q->rear; i++) {
8010476a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010476e:	8b 45 08             	mov    0x8(%ebp),%eax
80104771:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104777:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010477a:	7c e0                	jl     8010475c <enqueue+0x14>
      return; //중복 방지
  }
  q->q[q->rear % QUEUE_SIZE] = p;
8010477c:	8b 45 08             	mov    0x8(%ebp),%eax
8010477f:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
80104785:	99                   	cltd   
80104786:	c1 ea 1a             	shr    $0x1a,%edx
80104789:	01 d0                	add    %edx,%eax
8010478b:	83 e0 3f             	and    $0x3f,%eax
8010478e:	29 d0                	sub    %edx,%eax
80104790:	89 c1                	mov    %eax,%ecx
80104792:	8b 45 08             	mov    0x8(%ebp),%eax
80104795:	8b 55 0c             	mov    0xc(%ebp),%edx
80104798:	89 14 88             	mov    %edx,(%eax,%ecx,4)
  q->rear++;
8010479b:	8b 45 08             	mov    0x8(%ebp),%eax
8010479e:	8b 80 04 01 00 00    	mov    0x104(%eax),%eax
801047a4:	8d 50 01             	lea    0x1(%eax),%edx
801047a7:	8b 45 08             	mov    0x8(%ebp),%eax
801047aa:	89 90 04 01 00 00    	mov    %edx,0x104(%eax)
801047b0:	eb 01                	jmp    801047b3 <enqueue+0x6b>
      return; //중복 방지
801047b2:	90                   	nop
}
801047b3:	c9                   	leave  
801047b4:	c3                   	ret    

801047b5 <dequeue>:

// 큐에서 프로세스 꺼내기
struct proc* dequeue(struct queue *q) {
801047b5:	55                   	push   %ebp
801047b6:	89 e5                	mov    %esp,%ebp
801047b8:	83 ec 10             	sub    $0x10,%esp
  if (isempty(q))
801047bb:	ff 75 08             	push   0x8(%ebp)
801047be:	e8 66 ff ff ff       	call   80104729 <isempty>
801047c3:	83 c4 04             	add    $0x4,%esp
801047c6:	85 c0                	test   %eax,%eax
801047c8:	74 07                	je     801047d1 <dequeue+0x1c>
    return 0;
801047ca:	b8 00 00 00 00       	mov    $0x0,%eax
801047cf:	eb 37                	jmp    80104808 <dequeue+0x53>
  struct proc *p = q->q[q->front % QUEUE_SIZE];
801047d1:	8b 45 08             	mov    0x8(%ebp),%eax
801047d4:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
801047da:	99                   	cltd   
801047db:	c1 ea 1a             	shr    $0x1a,%edx
801047de:	01 d0                	add    %edx,%eax
801047e0:	83 e0 3f             	and    $0x3f,%eax
801047e3:	29 d0                	sub    %edx,%eax
801047e5:	89 c2                	mov    %eax,%edx
801047e7:	8b 45 08             	mov    0x8(%ebp),%eax
801047ea:	8b 04 90             	mov    (%eax,%edx,4),%eax
801047ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  q->front++;
801047f0:	8b 45 08             	mov    0x8(%ebp),%eax
801047f3:	8b 80 00 01 00 00    	mov    0x100(%eax),%eax
801047f9:	8d 50 01             	lea    0x1(%eax),%edx
801047fc:	8b 45 08             	mov    0x8(%ebp),%eax
801047ff:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
  return p;
80104805:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104808:	c9                   	leave  
80104809:	c3                   	ret    

8010480a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010480a:	55                   	push   %ebp
8010480b:	89 e5                	mov    %esp,%ebp
8010480d:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104810:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104817:	e9 da 00 00 00       	jmp    801048f6 <procdump+0xec>
    if(p->state == UNUSED)
8010481c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010481f:	8b 40 0c             	mov    0xc(%eax),%eax
80104822:	85 c0                	test   %eax,%eax
80104824:	0f 84 c4 00 00 00    	je     801048ee <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010482a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010482d:	8b 40 0c             	mov    0xc(%eax),%eax
80104830:	83 f8 05             	cmp    $0x5,%eax
80104833:	77 23                	ja     80104858 <procdump+0x4e>
80104835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104838:	8b 40 0c             	mov    0xc(%eax),%eax
8010483b:	8b 04 85 18 f0 10 80 	mov    -0x7fef0fe8(,%eax,4),%eax
80104842:	85 c0                	test   %eax,%eax
80104844:	74 12                	je     80104858 <procdump+0x4e>
      state = states[p->state];
80104846:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104849:	8b 40 0c             	mov    0xc(%eax),%eax
8010484c:	8b 04 85 18 f0 10 80 	mov    -0x7fef0fe8(,%eax,4),%eax
80104853:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104856:	eb 07                	jmp    8010485f <procdump+0x55>
    else
      state = "???";
80104858:	c7 45 ec b1 aa 10 80 	movl   $0x8010aab1,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010485f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104862:	8d 50 6c             	lea    0x6c(%eax),%edx
80104865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104868:	8b 40 10             	mov    0x10(%eax),%eax
8010486b:	52                   	push   %edx
8010486c:	ff 75 ec             	push   -0x14(%ebp)
8010486f:	50                   	push   %eax
80104870:	68 b5 aa 10 80       	push   $0x8010aab5
80104875:	e8 7a bb ff ff       	call   801003f4 <cprintf>
8010487a:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010487d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104880:	8b 40 0c             	mov    0xc(%eax),%eax
80104883:	83 f8 02             	cmp    $0x2,%eax
80104886:	75 54                	jne    801048dc <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104888:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010488b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010488e:	8b 40 0c             	mov    0xc(%eax),%eax
80104891:	83 c0 08             	add    $0x8,%eax
80104894:	89 c2                	mov    %eax,%edx
80104896:	83 ec 08             	sub    $0x8,%esp
80104899:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010489c:	50                   	push   %eax
8010489d:	52                   	push   %edx
8010489e:	e8 03 04 00 00       	call   80104ca6 <getcallerpcs>
801048a3:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801048ad:	eb 1c                	jmp    801048cb <procdump+0xc1>
        cprintf(" %p", pc[i]);
801048af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801048b6:	83 ec 08             	sub    $0x8,%esp
801048b9:	50                   	push   %eax
801048ba:	68 be aa 10 80       	push   $0x8010aabe
801048bf:	e8 30 bb ff ff       	call   801003f4 <cprintf>
801048c4:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801048cb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801048cf:	7f 0b                	jg     801048dc <procdump+0xd2>
801048d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d4:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801048d8:	85 c0                	test   %eax,%eax
801048da:	75 d3                	jne    801048af <procdump+0xa5>
    }
    cprintf("\n");
801048dc:	83 ec 0c             	sub    $0xc,%esp
801048df:	68 c2 aa 10 80       	push   $0x8010aac2
801048e4:	e8 0b bb ff ff       	call   801003f4 <cprintf>
801048e9:	83 c4 10             	add    $0x10,%esp
801048ec:	eb 01                	jmp    801048ef <procdump+0xe5>
      continue;
801048ee:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048ef:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
801048f6:	81 7d f0 34 6a 19 80 	cmpl   $0x80196a34,-0x10(%ebp)
801048fd:	0f 82 19 ff ff ff    	jb     8010481c <procdump+0x12>
  }
}
80104903:	90                   	nop
80104904:	90                   	nop
80104905:	c9                   	leave  
80104906:	c3                   	ret    

80104907 <setSchedPolicy>:
//추가
int
setSchedPolicy(int policy)
{
80104907:	55                   	push   %ebp
80104908:	89 e5                	mov    %esp,%ebp
8010490a:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)  // 정책 번호 범위 확인
8010490d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104911:	78 06                	js     80104919 <setSchedPolicy+0x12>
80104913:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104917:	7e 07                	jle    80104920 <setSchedPolicy+0x19>
    return -1;
80104919:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010491e:	eb 1d                	jmp    8010493d <setSchedPolicy+0x36>
  
  pushcli(); //인터럽트 끄기
80104920:	e8 2c 04 00 00       	call   80104d51 <pushcli>
  mycpu()->sched_policy = policy;
80104925:	e8 bc f0 ff ff       	call   801039e6 <mycpu>
8010492a:	8b 55 08             	mov    0x8(%ebp),%edx
8010492d:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli(); //인터럽트 켜기
80104933:	e8 66 04 00 00       	call   80104d9e <popcli>
  return 0;
80104938:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010493d:	c9                   	leave  
8010493e:	c3                   	ret    

8010493f <getpinfo>:


int
getpinfo(struct pstat *ps)
{
8010493f:	55                   	push   %ebp
80104940:	89 e5                	mov    %esp,%ebp
80104942:	53                   	push   %ebx
80104943:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104946:	83 ec 0c             	sub    $0xc,%esp
80104949:	68 00 42 19 80       	push   $0x80194200
8010494e:	e8 93 02 00 00       	call   80104be6 <acquire>
80104953:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROC; i++) {
80104956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010495d:	e9 e1 00 00 00       	jmp    80104a43 <getpinfo+0x104>
    p = &ptable.proc[i];
80104962:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104965:	89 d0                	mov    %edx,%eax
80104967:	c1 e0 02             	shl    $0x2,%eax
8010496a:	01 d0                	add    %edx,%eax
8010496c:	c1 e0 05             	shl    $0x5,%eax
8010496f:	83 c0 30             	add    $0x30,%eax
80104972:	05 00 42 19 80       	add    $0x80194200,%eax
80104977:	83 c0 04             	add    $0x4,%eax
8010497a:	89 45 ec             	mov    %eax,-0x14(%ebp)

    if (p->state != UNUSED)
8010497d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104980:	8b 40 0c             	mov    0xc(%eax),%eax
80104983:	85 c0                	test   %eax,%eax
80104985:	74 0f                	je     80104996 <getpinfo+0x57>
    ps->inuse[i] = 1;
80104987:	8b 45 08             	mov    0x8(%ebp),%eax
8010498a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010498d:	c7 04 90 01 00 00 00 	movl   $0x1,(%eax,%edx,4)
80104994:	eb 0d                	jmp    801049a3 <getpinfo+0x64>
    else
    ps->inuse[i] = 0;
80104996:	8b 45 08             	mov    0x8(%ebp),%eax
80104999:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010499c:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)

    ps->pid[i] = p->pid;
801049a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049a6:	8b 50 10             	mov    0x10(%eax),%edx
801049a9:	8b 45 08             	mov    0x8(%ebp),%eax
801049ac:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049af:	83 c1 40             	add    $0x40,%ecx
801049b2:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = p->priority;
801049b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049b8:	8b 50 7c             	mov    0x7c(%eax),%edx
801049bb:	8b 45 08             	mov    0x8(%ebp),%eax
801049be:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049c1:	83 e9 80             	sub    $0xffffff80,%ecx
801049c4:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
801049c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049ca:	8b 40 0c             	mov    0xc(%eax),%eax
801049cd:	89 c1                	mov    %eax,%ecx
801049cf:	8b 45 08             	mov    0x8(%ebp),%eax
801049d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049d5:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801049db:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
801049de:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049e5:	eb 52                	jmp    80104a39 <getpinfo+0xfa>
      ps->ticks[i][j] = p->ticks[j];
801049e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049ed:	83 c2 20             	add    $0x20,%edx
801049f0:	8b 14 90             	mov    (%eax,%edx,4),%edx
801049f3:	8b 45 08             	mov    0x8(%ebp),%eax
801049f6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049f9:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104a00:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a03:	01 d9                	add    %ebx,%ecx
80104a05:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104a0b:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
80104a0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a11:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a14:	83 c2 24             	add    $0x24,%edx
80104a17:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a20:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104a27:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a2a:	01 d9                	add    %ebx,%ecx
80104a2c:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104a32:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104a35:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a39:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104a3d:	7e a8                	jle    801049e7 <getpinfo+0xa8>
  for (int i = 0; i < NPROC; i++) {
80104a3f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a43:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104a47:	0f 8e 15 ff ff ff    	jle    80104962 <getpinfo+0x23>
    }
  }

  release(&ptable.lock);
80104a4d:	83 ec 0c             	sub    $0xc,%esp
80104a50:	68 00 42 19 80       	push   $0x80194200
80104a55:	e8 fa 01 00 00       	call   80104c54 <release>
80104a5a:	83 c4 10             	add    $0x10,%esp
  return 0;
80104a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a65:	c9                   	leave  
80104a66:	c3                   	ret    

80104a67 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a67:	55                   	push   %ebp
80104a68:	89 e5                	mov    %esp,%ebp
80104a6a:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a70:	83 c0 04             	add    $0x4,%eax
80104a73:	83 ec 08             	sub    $0x8,%esp
80104a76:	68 ee aa 10 80       	push   $0x8010aaee
80104a7b:	50                   	push   %eax
80104a7c:	e8 43 01 00 00       	call   80104bc4 <initlock>
80104a81:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104a84:	8b 45 08             	mov    0x8(%ebp),%eax
80104a87:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a8a:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a96:	8b 45 08             	mov    0x8(%ebp),%eax
80104a99:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104aa0:	90                   	nop
80104aa1:	c9                   	leave  
80104aa2:	c3                   	ret    

80104aa3 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104aa3:	55                   	push   %ebp
80104aa4:	89 e5                	mov    %esp,%ebp
80104aa6:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80104aac:	83 c0 04             	add    $0x4,%eax
80104aaf:	83 ec 0c             	sub    $0xc,%esp
80104ab2:	50                   	push   %eax
80104ab3:	e8 2e 01 00 00       	call   80104be6 <acquire>
80104ab8:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104abb:	eb 15                	jmp    80104ad2 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104abd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac0:	83 c0 04             	add    $0x4,%eax
80104ac3:	83 ec 08             	sub    $0x8,%esp
80104ac6:	50                   	push   %eax
80104ac7:	ff 75 08             	push   0x8(%ebp)
80104aca:	e8 92 fa ff ff       	call   80104561 <sleep>
80104acf:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad5:	8b 00                	mov    (%eax),%eax
80104ad7:	85 c0                	test   %eax,%eax
80104ad9:	75 e2                	jne    80104abd <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104adb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ade:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104ae4:	e8 75 ef ff ff       	call   80103a5e <myproc>
80104ae9:	8b 50 10             	mov    0x10(%eax),%edx
80104aec:	8b 45 08             	mov    0x8(%ebp),%eax
80104aef:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104af2:	8b 45 08             	mov    0x8(%ebp),%eax
80104af5:	83 c0 04             	add    $0x4,%eax
80104af8:	83 ec 0c             	sub    $0xc,%esp
80104afb:	50                   	push   %eax
80104afc:	e8 53 01 00 00       	call   80104c54 <release>
80104b01:	83 c4 10             	add    $0x10,%esp
}
80104b04:	90                   	nop
80104b05:	c9                   	leave  
80104b06:	c3                   	ret    

80104b07 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104b07:	55                   	push   %ebp
80104b08:	89 e5                	mov    %esp,%ebp
80104b0a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b10:	83 c0 04             	add    $0x4,%eax
80104b13:	83 ec 0c             	sub    $0xc,%esp
80104b16:	50                   	push   %eax
80104b17:	e8 ca 00 00 00       	call   80104be6 <acquire>
80104b1c:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104b28:	8b 45 08             	mov    0x8(%ebp),%eax
80104b2b:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104b32:	83 ec 0c             	sub    $0xc,%esp
80104b35:	ff 75 08             	push   0x8(%ebp)
80104b38:	e8 0e fb ff ff       	call   8010464b <wakeup>
80104b3d:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104b40:	8b 45 08             	mov    0x8(%ebp),%eax
80104b43:	83 c0 04             	add    $0x4,%eax
80104b46:	83 ec 0c             	sub    $0xc,%esp
80104b49:	50                   	push   %eax
80104b4a:	e8 05 01 00 00       	call   80104c54 <release>
80104b4f:	83 c4 10             	add    $0x10,%esp
}
80104b52:	90                   	nop
80104b53:	c9                   	leave  
80104b54:	c3                   	ret    

80104b55 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104b55:	55                   	push   %ebp
80104b56:	89 e5                	mov    %esp,%ebp
80104b58:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5e:	83 c0 04             	add    $0x4,%eax
80104b61:	83 ec 0c             	sub    $0xc,%esp
80104b64:	50                   	push   %eax
80104b65:	e8 7c 00 00 00       	call   80104be6 <acquire>
80104b6a:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b70:	8b 00                	mov    (%eax),%eax
80104b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b75:	8b 45 08             	mov    0x8(%ebp),%eax
80104b78:	83 c0 04             	add    $0x4,%eax
80104b7b:	83 ec 0c             	sub    $0xc,%esp
80104b7e:	50                   	push   %eax
80104b7f:	e8 d0 00 00 00       	call   80104c54 <release>
80104b84:	83 c4 10             	add    $0x10,%esp
  return r;
80104b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b8a:	c9                   	leave  
80104b8b:	c3                   	ret    

80104b8c <readeflags>:
{
80104b8c:	55                   	push   %ebp
80104b8d:	89 e5                	mov    %esp,%ebp
80104b8f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b92:	9c                   	pushf  
80104b93:	58                   	pop    %eax
80104b94:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b9a:	c9                   	leave  
80104b9b:	c3                   	ret    

80104b9c <cli>:
{
80104b9c:	55                   	push   %ebp
80104b9d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b9f:	fa                   	cli    
}
80104ba0:	90                   	nop
80104ba1:	5d                   	pop    %ebp
80104ba2:	c3                   	ret    

80104ba3 <sti>:
{
80104ba3:	55                   	push   %ebp
80104ba4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ba6:	fb                   	sti    
}
80104ba7:	90                   	nop
80104ba8:	5d                   	pop    %ebp
80104ba9:	c3                   	ret    

80104baa <xchg>:
{
80104baa:	55                   	push   %ebp
80104bab:	89 e5                	mov    %esp,%ebp
80104bad:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104bb0:	8b 55 08             	mov    0x8(%ebp),%edx
80104bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bb9:	f0 87 02             	lock xchg %eax,(%edx)
80104bbc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104bbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bc2:	c9                   	leave  
80104bc3:	c3                   	ret    

80104bc4 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104bc4:	55                   	push   %ebp
80104bc5:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bca:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bcd:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bdc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104be3:	90                   	nop
80104be4:	5d                   	pop    %ebp
80104be5:	c3                   	ret    

80104be6 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104be6:	55                   	push   %ebp
80104be7:	89 e5                	mov    %esp,%ebp
80104be9:	53                   	push   %ebx
80104bea:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104bed:	e8 5f 01 00 00       	call   80104d51 <pushcli>
  if(holding(lk)){
80104bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf5:	83 ec 0c             	sub    $0xc,%esp
80104bf8:	50                   	push   %eax
80104bf9:	e8 23 01 00 00       	call   80104d21 <holding>
80104bfe:	83 c4 10             	add    $0x10,%esp
80104c01:	85 c0                	test   %eax,%eax
80104c03:	74 0d                	je     80104c12 <acquire+0x2c>
    panic("acquire");
80104c05:	83 ec 0c             	sub    $0xc,%esp
80104c08:	68 f9 aa 10 80       	push   $0x8010aaf9
80104c0d:	e8 97 b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104c12:	90                   	nop
80104c13:	8b 45 08             	mov    0x8(%ebp),%eax
80104c16:	83 ec 08             	sub    $0x8,%esp
80104c19:	6a 01                	push   $0x1
80104c1b:	50                   	push   %eax
80104c1c:	e8 89 ff ff ff       	call   80104baa <xchg>
80104c21:	83 c4 10             	add    $0x10,%esp
80104c24:	85 c0                	test   %eax,%eax
80104c26:	75 eb                	jne    80104c13 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104c28:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104c2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104c30:	e8 b1 ed ff ff       	call   801039e6 <mycpu>
80104c35:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104c38:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3b:	83 c0 0c             	add    $0xc,%eax
80104c3e:	83 ec 08             	sub    $0x8,%esp
80104c41:	50                   	push   %eax
80104c42:	8d 45 08             	lea    0x8(%ebp),%eax
80104c45:	50                   	push   %eax
80104c46:	e8 5b 00 00 00       	call   80104ca6 <getcallerpcs>
80104c4b:	83 c4 10             	add    $0x10,%esp
}
80104c4e:	90                   	nop
80104c4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c52:	c9                   	leave  
80104c53:	c3                   	ret    

80104c54 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c54:	55                   	push   %ebp
80104c55:	89 e5                	mov    %esp,%ebp
80104c57:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c5a:	83 ec 0c             	sub    $0xc,%esp
80104c5d:	ff 75 08             	push   0x8(%ebp)
80104c60:	e8 bc 00 00 00       	call   80104d21 <holding>
80104c65:	83 c4 10             	add    $0x10,%esp
80104c68:	85 c0                	test   %eax,%eax
80104c6a:	75 0d                	jne    80104c79 <release+0x25>
    panic("release");
80104c6c:	83 ec 0c             	sub    $0xc,%esp
80104c6f:	68 01 ab 10 80       	push   $0x8010ab01
80104c74:	e8 30 b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c79:	8b 45 08             	mov    0x8(%ebp),%eax
80104c7c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c83:	8b 45 08             	mov    0x8(%ebp),%eax
80104c86:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104c8d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c92:	8b 45 08             	mov    0x8(%ebp),%eax
80104c95:	8b 55 08             	mov    0x8(%ebp),%edx
80104c98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104c9e:	e8 fb 00 00 00       	call   80104d9e <popcli>
}
80104ca3:	90                   	nop
80104ca4:	c9                   	leave  
80104ca5:	c3                   	ret    

80104ca6 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104ca6:	55                   	push   %ebp
80104ca7:	89 e5                	mov    %esp,%ebp
80104ca9:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104cac:	8b 45 08             	mov    0x8(%ebp),%eax
80104caf:	83 e8 08             	sub    $0x8,%eax
80104cb2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104cb5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104cbc:	eb 38                	jmp    80104cf6 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104cbe:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104cc2:	74 53                	je     80104d17 <getcallerpcs+0x71>
80104cc4:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104ccb:	76 4a                	jbe    80104d17 <getcallerpcs+0x71>
80104ccd:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104cd1:	74 44                	je     80104d17 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104cd3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cd6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ce0:	01 c2                	add    %eax,%edx
80104ce2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ce5:	8b 40 04             	mov    0x4(%eax),%eax
80104ce8:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104cea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ced:	8b 00                	mov    (%eax),%eax
80104cef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104cf2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cf6:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cfa:	7e c2                	jle    80104cbe <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104cfc:	eb 19                	jmp    80104d17 <getcallerpcs+0x71>
    pcs[i] = 0;
80104cfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d01:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d08:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d0b:	01 d0                	add    %edx,%eax
80104d0d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104d13:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104d17:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d1b:	7e e1                	jle    80104cfe <getcallerpcs+0x58>
}
80104d1d:	90                   	nop
80104d1e:	90                   	nop
80104d1f:	c9                   	leave  
80104d20:	c3                   	ret    

80104d21 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104d21:	55                   	push   %ebp
80104d22:	89 e5                	mov    %esp,%ebp
80104d24:	53                   	push   %ebx
80104d25:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104d28:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2b:	8b 00                	mov    (%eax),%eax
80104d2d:	85 c0                	test   %eax,%eax
80104d2f:	74 16                	je     80104d47 <holding+0x26>
80104d31:	8b 45 08             	mov    0x8(%ebp),%eax
80104d34:	8b 58 08             	mov    0x8(%eax),%ebx
80104d37:	e8 aa ec ff ff       	call   801039e6 <mycpu>
80104d3c:	39 c3                	cmp    %eax,%ebx
80104d3e:	75 07                	jne    80104d47 <holding+0x26>
80104d40:	b8 01 00 00 00       	mov    $0x1,%eax
80104d45:	eb 05                	jmp    80104d4c <holding+0x2b>
80104d47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d4f:	c9                   	leave  
80104d50:	c3                   	ret    

80104d51 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d51:	55                   	push   %ebp
80104d52:	89 e5                	mov    %esp,%ebp
80104d54:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104d57:	e8 30 fe ff ff       	call   80104b8c <readeflags>
80104d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d5f:	e8 38 fe ff ff       	call   80104b9c <cli>
  if(mycpu()->ncli == 0)
80104d64:	e8 7d ec ff ff       	call   801039e6 <mycpu>
80104d69:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d6f:	85 c0                	test   %eax,%eax
80104d71:	75 14                	jne    80104d87 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d73:	e8 6e ec ff ff       	call   801039e6 <mycpu>
80104d78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d7b:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d81:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d87:	e8 5a ec ff ff       	call   801039e6 <mycpu>
80104d8c:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d92:	83 c2 01             	add    $0x1,%edx
80104d95:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104d9b:	90                   	nop
80104d9c:	c9                   	leave  
80104d9d:	c3                   	ret    

80104d9e <popcli>:

void
popcli(void)
{
80104d9e:	55                   	push   %ebp
80104d9f:	89 e5                	mov    %esp,%ebp
80104da1:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104da4:	e8 e3 fd ff ff       	call   80104b8c <readeflags>
80104da9:	25 00 02 00 00       	and    $0x200,%eax
80104dae:	85 c0                	test   %eax,%eax
80104db0:	74 0d                	je     80104dbf <popcli+0x21>
    panic("popcli - interruptible");
80104db2:	83 ec 0c             	sub    $0xc,%esp
80104db5:	68 09 ab 10 80       	push   $0x8010ab09
80104dba:	e8 ea b7 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104dbf:	e8 22 ec ff ff       	call   801039e6 <mycpu>
80104dc4:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104dca:	83 ea 01             	sub    $0x1,%edx
80104dcd:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104dd3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104dd9:	85 c0                	test   %eax,%eax
80104ddb:	79 0d                	jns    80104dea <popcli+0x4c>
    panic("popcli");
80104ddd:	83 ec 0c             	sub    $0xc,%esp
80104de0:	68 20 ab 10 80       	push   $0x8010ab20
80104de5:	e8 bf b7 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104dea:	e8 f7 eb ff ff       	call   801039e6 <mycpu>
80104def:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104df5:	85 c0                	test   %eax,%eax
80104df7:	75 14                	jne    80104e0d <popcli+0x6f>
80104df9:	e8 e8 eb ff ff       	call   801039e6 <mycpu>
80104dfe:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e04:	85 c0                	test   %eax,%eax
80104e06:	74 05                	je     80104e0d <popcli+0x6f>
    sti();
80104e08:	e8 96 fd ff ff       	call   80104ba3 <sti>
}
80104e0d:	90                   	nop
80104e0e:	c9                   	leave  
80104e0f:	c3                   	ret    

80104e10 <stosb>:
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
80104e13:	57                   	push   %edi
80104e14:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104e15:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e18:	8b 55 10             	mov    0x10(%ebp),%edx
80104e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e1e:	89 cb                	mov    %ecx,%ebx
80104e20:	89 df                	mov    %ebx,%edi
80104e22:	89 d1                	mov    %edx,%ecx
80104e24:	fc                   	cld    
80104e25:	f3 aa                	rep stos %al,%es:(%edi)
80104e27:	89 ca                	mov    %ecx,%edx
80104e29:	89 fb                	mov    %edi,%ebx
80104e2b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e2e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e31:	90                   	nop
80104e32:	5b                   	pop    %ebx
80104e33:	5f                   	pop    %edi
80104e34:	5d                   	pop    %ebp
80104e35:	c3                   	ret    

80104e36 <stosl>:
{
80104e36:	55                   	push   %ebp
80104e37:	89 e5                	mov    %esp,%ebp
80104e39:	57                   	push   %edi
80104e3a:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e3e:	8b 55 10             	mov    0x10(%ebp),%edx
80104e41:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e44:	89 cb                	mov    %ecx,%ebx
80104e46:	89 df                	mov    %ebx,%edi
80104e48:	89 d1                	mov    %edx,%ecx
80104e4a:	fc                   	cld    
80104e4b:	f3 ab                	rep stos %eax,%es:(%edi)
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

80104e5c <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e5c:	55                   	push   %ebp
80104e5d:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e62:	83 e0 03             	and    $0x3,%eax
80104e65:	85 c0                	test   %eax,%eax
80104e67:	75 43                	jne    80104eac <memset+0x50>
80104e69:	8b 45 10             	mov    0x10(%ebp),%eax
80104e6c:	83 e0 03             	and    $0x3,%eax
80104e6f:	85 c0                	test   %eax,%eax
80104e71:	75 39                	jne    80104eac <memset+0x50>
    c &= 0xFF;
80104e73:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e7a:	8b 45 10             	mov    0x10(%ebp),%eax
80104e7d:	c1 e8 02             	shr    $0x2,%eax
80104e80:	89 c2                	mov    %eax,%edx
80104e82:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e85:	c1 e0 18             	shl    $0x18,%eax
80104e88:	89 c1                	mov    %eax,%ecx
80104e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8d:	c1 e0 10             	shl    $0x10,%eax
80104e90:	09 c1                	or     %eax,%ecx
80104e92:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e95:	c1 e0 08             	shl    $0x8,%eax
80104e98:	09 c8                	or     %ecx,%eax
80104e9a:	0b 45 0c             	or     0xc(%ebp),%eax
80104e9d:	52                   	push   %edx
80104e9e:	50                   	push   %eax
80104e9f:	ff 75 08             	push   0x8(%ebp)
80104ea2:	e8 8f ff ff ff       	call   80104e36 <stosl>
80104ea7:	83 c4 0c             	add    $0xc,%esp
80104eaa:	eb 12                	jmp    80104ebe <memset+0x62>
  } else
    stosb(dst, c, n);
80104eac:	8b 45 10             	mov    0x10(%ebp),%eax
80104eaf:	50                   	push   %eax
80104eb0:	ff 75 0c             	push   0xc(%ebp)
80104eb3:	ff 75 08             	push   0x8(%ebp)
80104eb6:	e8 55 ff ff ff       	call   80104e10 <stosb>
80104ebb:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104ebe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ec1:	c9                   	leave  
80104ec2:	c3                   	ret    

80104ec3 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104ec3:	55                   	push   %ebp
80104ec4:	89 e5                	mov    %esp,%ebp
80104ec6:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104ed5:	eb 30                	jmp    80104f07 <memcmp+0x44>
    if(*s1 != *s2)
80104ed7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eda:	0f b6 10             	movzbl (%eax),%edx
80104edd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ee0:	0f b6 00             	movzbl (%eax),%eax
80104ee3:	38 c2                	cmp    %al,%dl
80104ee5:	74 18                	je     80104eff <memcmp+0x3c>
      return *s1 - *s2;
80104ee7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eea:	0f b6 00             	movzbl (%eax),%eax
80104eed:	0f b6 d0             	movzbl %al,%edx
80104ef0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ef3:	0f b6 00             	movzbl (%eax),%eax
80104ef6:	0f b6 c8             	movzbl %al,%ecx
80104ef9:	89 d0                	mov    %edx,%eax
80104efb:	29 c8                	sub    %ecx,%eax
80104efd:	eb 1a                	jmp    80104f19 <memcmp+0x56>
    s1++, s2++;
80104eff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f03:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104f07:	8b 45 10             	mov    0x10(%ebp),%eax
80104f0a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f0d:	89 55 10             	mov    %edx,0x10(%ebp)
80104f10:	85 c0                	test   %eax,%eax
80104f12:	75 c3                	jne    80104ed7 <memcmp+0x14>
  }

  return 0;
80104f14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f19:	c9                   	leave  
80104f1a:	c3                   	ret    

80104f1b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104f1b:	55                   	push   %ebp
80104f1c:	89 e5                	mov    %esp,%ebp
80104f1e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104f21:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f24:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104f27:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104f2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f30:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104f33:	73 54                	jae    80104f89 <memmove+0x6e>
80104f35:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f38:	8b 45 10             	mov    0x10(%ebp),%eax
80104f3b:	01 d0                	add    %edx,%eax
80104f3d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104f40:	73 47                	jae    80104f89 <memmove+0x6e>
    s += n;
80104f42:	8b 45 10             	mov    0x10(%ebp),%eax
80104f45:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104f48:	8b 45 10             	mov    0x10(%ebp),%eax
80104f4b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f4e:	eb 13                	jmp    80104f63 <memmove+0x48>
      *--d = *--s;
80104f50:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f54:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f5b:	0f b6 10             	movzbl (%eax),%edx
80104f5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f61:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f63:	8b 45 10             	mov    0x10(%ebp),%eax
80104f66:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f69:	89 55 10             	mov    %edx,0x10(%ebp)
80104f6c:	85 c0                	test   %eax,%eax
80104f6e:	75 e0                	jne    80104f50 <memmove+0x35>
  if(s < d && s + n > d){
80104f70:	eb 24                	jmp    80104f96 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f72:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f75:	8d 42 01             	lea    0x1(%edx),%eax
80104f78:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f7e:	8d 48 01             	lea    0x1(%eax),%ecx
80104f81:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104f84:	0f b6 12             	movzbl (%edx),%edx
80104f87:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f89:	8b 45 10             	mov    0x10(%ebp),%eax
80104f8c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f8f:	89 55 10             	mov    %edx,0x10(%ebp)
80104f92:	85 c0                	test   %eax,%eax
80104f94:	75 dc                	jne    80104f72 <memmove+0x57>

  return dst;
80104f96:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f99:	c9                   	leave  
80104f9a:	c3                   	ret    

80104f9b <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f9b:	55                   	push   %ebp
80104f9c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f9e:	ff 75 10             	push   0x10(%ebp)
80104fa1:	ff 75 0c             	push   0xc(%ebp)
80104fa4:	ff 75 08             	push   0x8(%ebp)
80104fa7:	e8 6f ff ff ff       	call   80104f1b <memmove>
80104fac:	83 c4 0c             	add    $0xc,%esp
}
80104faf:	c9                   	leave  
80104fb0:	c3                   	ret    

80104fb1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104fb1:	55                   	push   %ebp
80104fb2:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104fb4:	eb 0c                	jmp    80104fc2 <strncmp+0x11>
    n--, p++, q++;
80104fb6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104fbe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104fc2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fc6:	74 1a                	je     80104fe2 <strncmp+0x31>
80104fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcb:	0f b6 00             	movzbl (%eax),%eax
80104fce:	84 c0                	test   %al,%al
80104fd0:	74 10                	je     80104fe2 <strncmp+0x31>
80104fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd5:	0f b6 10             	movzbl (%eax),%edx
80104fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fdb:	0f b6 00             	movzbl (%eax),%eax
80104fde:	38 c2                	cmp    %al,%dl
80104fe0:	74 d4                	je     80104fb6 <strncmp+0x5>
  if(n == 0)
80104fe2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fe6:	75 07                	jne    80104fef <strncmp+0x3e>
    return 0;
80104fe8:	b8 00 00 00 00       	mov    $0x0,%eax
80104fed:	eb 16                	jmp    80105005 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104fef:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff2:	0f b6 00             	movzbl (%eax),%eax
80104ff5:	0f b6 d0             	movzbl %al,%edx
80104ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ffb:	0f b6 00             	movzbl (%eax),%eax
80104ffe:	0f b6 c8             	movzbl %al,%ecx
80105001:	89 d0                	mov    %edx,%eax
80105003:	29 c8                	sub    %ecx,%eax
}
80105005:	5d                   	pop    %ebp
80105006:	c3                   	ret    

80105007 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105007:	55                   	push   %ebp
80105008:	89 e5                	mov    %esp,%ebp
8010500a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010500d:	8b 45 08             	mov    0x8(%ebp),%eax
80105010:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105013:	90                   	nop
80105014:	8b 45 10             	mov    0x10(%ebp),%eax
80105017:	8d 50 ff             	lea    -0x1(%eax),%edx
8010501a:	89 55 10             	mov    %edx,0x10(%ebp)
8010501d:	85 c0                	test   %eax,%eax
8010501f:	7e 2c                	jle    8010504d <strncpy+0x46>
80105021:	8b 55 0c             	mov    0xc(%ebp),%edx
80105024:	8d 42 01             	lea    0x1(%edx),%eax
80105027:	89 45 0c             	mov    %eax,0xc(%ebp)
8010502a:	8b 45 08             	mov    0x8(%ebp),%eax
8010502d:	8d 48 01             	lea    0x1(%eax),%ecx
80105030:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105033:	0f b6 12             	movzbl (%edx),%edx
80105036:	88 10                	mov    %dl,(%eax)
80105038:	0f b6 00             	movzbl (%eax),%eax
8010503b:	84 c0                	test   %al,%al
8010503d:	75 d5                	jne    80105014 <strncpy+0xd>
    ;
  while(n-- > 0)
8010503f:	eb 0c                	jmp    8010504d <strncpy+0x46>
    *s++ = 0;
80105041:	8b 45 08             	mov    0x8(%ebp),%eax
80105044:	8d 50 01             	lea    0x1(%eax),%edx
80105047:	89 55 08             	mov    %edx,0x8(%ebp)
8010504a:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010504d:	8b 45 10             	mov    0x10(%ebp),%eax
80105050:	8d 50 ff             	lea    -0x1(%eax),%edx
80105053:	89 55 10             	mov    %edx,0x10(%ebp)
80105056:	85 c0                	test   %eax,%eax
80105058:	7f e7                	jg     80105041 <strncpy+0x3a>
  return os;
8010505a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010505d:	c9                   	leave  
8010505e:	c3                   	ret    

8010505f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010505f:	55                   	push   %ebp
80105060:	89 e5                	mov    %esp,%ebp
80105062:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105065:	8b 45 08             	mov    0x8(%ebp),%eax
80105068:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010506b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010506f:	7f 05                	jg     80105076 <safestrcpy+0x17>
    return os;
80105071:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105074:	eb 32                	jmp    801050a8 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105076:	90                   	nop
80105077:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010507b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010507f:	7e 1e                	jle    8010509f <safestrcpy+0x40>
80105081:	8b 55 0c             	mov    0xc(%ebp),%edx
80105084:	8d 42 01             	lea    0x1(%edx),%eax
80105087:	89 45 0c             	mov    %eax,0xc(%ebp)
8010508a:	8b 45 08             	mov    0x8(%ebp),%eax
8010508d:	8d 48 01             	lea    0x1(%eax),%ecx
80105090:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105093:	0f b6 12             	movzbl (%edx),%edx
80105096:	88 10                	mov    %dl,(%eax)
80105098:	0f b6 00             	movzbl (%eax),%eax
8010509b:	84 c0                	test   %al,%al
8010509d:	75 d8                	jne    80105077 <safestrcpy+0x18>
    ;
  *s = 0;
8010509f:	8b 45 08             	mov    0x8(%ebp),%eax
801050a2:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801050a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050a8:	c9                   	leave  
801050a9:	c3                   	ret    

801050aa <strlen>:

int
strlen(const char *s)
{
801050aa:	55                   	push   %ebp
801050ab:	89 e5                	mov    %esp,%ebp
801050ad:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801050b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801050b7:	eb 04                	jmp    801050bd <strlen+0x13>
801050b9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050c0:	8b 45 08             	mov    0x8(%ebp),%eax
801050c3:	01 d0                	add    %edx,%eax
801050c5:	0f b6 00             	movzbl (%eax),%eax
801050c8:	84 c0                	test   %al,%al
801050ca:	75 ed                	jne    801050b9 <strlen+0xf>
    ;
  return n;
801050cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050cf:	c9                   	leave  
801050d0:	c3                   	ret    

801050d1 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801050d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801050d5:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801050d9:	55                   	push   %ebp
  pushl %ebx
801050da:	53                   	push   %ebx
  pushl %esi
801050db:	56                   	push   %esi
  pushl %edi
801050dc:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801050dd:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801050df:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801050e1:	5f                   	pop    %edi
  popl %esi
801050e2:	5e                   	pop    %esi
  popl %ebx
801050e3:	5b                   	pop    %ebx
  popl %ebp
801050e4:	5d                   	pop    %ebp
  ret
801050e5:	c3                   	ret    

801050e6 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801050e6:	55                   	push   %ebp
801050e7:	89 e5                	mov    %esp,%ebp
801050e9:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801050ec:	e8 6d e9 ff ff       	call   80103a5e <myproc>
801050f1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801050f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f7:	8b 00                	mov    (%eax),%eax
801050f9:	39 45 08             	cmp    %eax,0x8(%ebp)
801050fc:	73 0f                	jae    8010510d <fetchint+0x27>
801050fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105101:	8d 50 04             	lea    0x4(%eax),%edx
80105104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105107:	8b 00                	mov    (%eax),%eax
80105109:	39 c2                	cmp    %eax,%edx
8010510b:	76 07                	jbe    80105114 <fetchint+0x2e>
    return -1;
8010510d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105112:	eb 0f                	jmp    80105123 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105114:	8b 45 08             	mov    0x8(%ebp),%eax
80105117:	8b 10                	mov    (%eax),%edx
80105119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511c:	89 10                	mov    %edx,(%eax)
  return 0;
8010511e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105123:	c9                   	leave  
80105124:	c3                   	ret    

80105125 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105125:	55                   	push   %ebp
80105126:	89 e5                	mov    %esp,%ebp
80105128:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010512b:	e8 2e e9 ff ff       	call   80103a5e <myproc>
80105130:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105133:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105136:	8b 00                	mov    (%eax),%eax
80105138:	39 45 08             	cmp    %eax,0x8(%ebp)
8010513b:	72 07                	jb     80105144 <fetchstr+0x1f>
    return -1;
8010513d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105142:	eb 41                	jmp    80105185 <fetchstr+0x60>
  *pp = (char*)addr;
80105144:	8b 55 08             	mov    0x8(%ebp),%edx
80105147:	8b 45 0c             	mov    0xc(%ebp),%eax
8010514a:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010514c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010514f:	8b 00                	mov    (%eax),%eax
80105151:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105154:	8b 45 0c             	mov    0xc(%ebp),%eax
80105157:	8b 00                	mov    (%eax),%eax
80105159:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010515c:	eb 1a                	jmp    80105178 <fetchstr+0x53>
    if(*s == 0)
8010515e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105161:	0f b6 00             	movzbl (%eax),%eax
80105164:	84 c0                	test   %al,%al
80105166:	75 0c                	jne    80105174 <fetchstr+0x4f>
      return s - *pp;
80105168:	8b 45 0c             	mov    0xc(%ebp),%eax
8010516b:	8b 10                	mov    (%eax),%edx
8010516d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105170:	29 d0                	sub    %edx,%eax
80105172:	eb 11                	jmp    80105185 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105174:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010517e:	72 de                	jb     8010515e <fetchstr+0x39>
  }
  return -1;
80105180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105185:	c9                   	leave  
80105186:	c3                   	ret    

80105187 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105187:	55                   	push   %ebp
80105188:	89 e5                	mov    %esp,%ebp
8010518a:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010518d:	e8 cc e8 ff ff       	call   80103a5e <myproc>
80105192:	8b 40 18             	mov    0x18(%eax),%eax
80105195:	8b 50 44             	mov    0x44(%eax),%edx
80105198:	8b 45 08             	mov    0x8(%ebp),%eax
8010519b:	c1 e0 02             	shl    $0x2,%eax
8010519e:	01 d0                	add    %edx,%eax
801051a0:	83 c0 04             	add    $0x4,%eax
801051a3:	83 ec 08             	sub    $0x8,%esp
801051a6:	ff 75 0c             	push   0xc(%ebp)
801051a9:	50                   	push   %eax
801051aa:	e8 37 ff ff ff       	call   801050e6 <fetchint>
801051af:	83 c4 10             	add    $0x10,%esp
}
801051b2:	c9                   	leave  
801051b3:	c3                   	ret    

801051b4 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801051b4:	55                   	push   %ebp
801051b5:	89 e5                	mov    %esp,%ebp
801051b7:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801051ba:	e8 9f e8 ff ff       	call   80103a5e <myproc>
801051bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801051c2:	83 ec 08             	sub    $0x8,%esp
801051c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051c8:	50                   	push   %eax
801051c9:	ff 75 08             	push   0x8(%ebp)
801051cc:	e8 b6 ff ff ff       	call   80105187 <argint>
801051d1:	83 c4 10             	add    $0x10,%esp
801051d4:	85 c0                	test   %eax,%eax
801051d6:	79 07                	jns    801051df <argptr+0x2b>
    return -1;
801051d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051dd:	eb 3b                	jmp    8010521a <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801051df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051e3:	78 1f                	js     80105204 <argptr+0x50>
801051e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e8:	8b 00                	mov    (%eax),%eax
801051ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051ed:	39 d0                	cmp    %edx,%eax
801051ef:	76 13                	jbe    80105204 <argptr+0x50>
801051f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f4:	89 c2                	mov    %eax,%edx
801051f6:	8b 45 10             	mov    0x10(%ebp),%eax
801051f9:	01 c2                	add    %eax,%edx
801051fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fe:	8b 00                	mov    (%eax),%eax
80105200:	39 c2                	cmp    %eax,%edx
80105202:	76 07                	jbe    8010520b <argptr+0x57>
    return -1;
80105204:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105209:	eb 0f                	jmp    8010521a <argptr+0x66>
  *pp = (char*)i;
8010520b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010520e:	89 c2                	mov    %eax,%edx
80105210:	8b 45 0c             	mov    0xc(%ebp),%eax
80105213:	89 10                	mov    %edx,(%eax)
  return 0;
80105215:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010521a:	c9                   	leave  
8010521b:	c3                   	ret    

8010521c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010521c:	55                   	push   %ebp
8010521d:	89 e5                	mov    %esp,%ebp
8010521f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105222:	83 ec 08             	sub    $0x8,%esp
80105225:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105228:	50                   	push   %eax
80105229:	ff 75 08             	push   0x8(%ebp)
8010522c:	e8 56 ff ff ff       	call   80105187 <argint>
80105231:	83 c4 10             	add    $0x10,%esp
80105234:	85 c0                	test   %eax,%eax
80105236:	79 07                	jns    8010523f <argstr+0x23>
    return -1;
80105238:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010523d:	eb 12                	jmp    80105251 <argstr+0x35>
  return fetchstr(addr, pp);
8010523f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105242:	83 ec 08             	sub    $0x8,%esp
80105245:	ff 75 0c             	push   0xc(%ebp)
80105248:	50                   	push   %eax
80105249:	e8 d7 fe ff ff       	call   80105125 <fetchstr>
8010524e:	83 c4 10             	add    $0x10,%esp
}
80105251:	c9                   	leave  
80105252:	c3                   	ret    

80105253 <syscall>:
[SYS_yield] = sys_yield,
};

void
syscall(void)
{
80105253:	55                   	push   %ebp
80105254:	89 e5                	mov    %esp,%ebp
80105256:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105259:	e8 00 e8 ff ff       	call   80103a5e <myproc>
8010525e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105264:	8b 40 18             	mov    0x18(%eax),%eax
80105267:	8b 40 1c             	mov    0x1c(%eax),%eax
8010526a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010526d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105271:	7e 2f                	jle    801052a2 <syscall+0x4f>
80105273:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105276:	83 f8 18             	cmp    $0x18,%eax
80105279:	77 27                	ja     801052a2 <syscall+0x4f>
8010527b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010527e:	8b 04 85 40 f0 10 80 	mov    -0x7fef0fc0(,%eax,4),%eax
80105285:	85 c0                	test   %eax,%eax
80105287:	74 19                	je     801052a2 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105289:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010528c:	8b 04 85 40 f0 10 80 	mov    -0x7fef0fc0(,%eax,4),%eax
80105293:	ff d0                	call   *%eax
80105295:	89 c2                	mov    %eax,%edx
80105297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529a:	8b 40 18             	mov    0x18(%eax),%eax
8010529d:	89 50 1c             	mov    %edx,0x1c(%eax)
801052a0:	eb 2c                	jmp    801052ce <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801052a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a5:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801052a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ab:	8b 40 10             	mov    0x10(%eax),%eax
801052ae:	ff 75 f0             	push   -0x10(%ebp)
801052b1:	52                   	push   %edx
801052b2:	50                   	push   %eax
801052b3:	68 27 ab 10 80       	push   $0x8010ab27
801052b8:	e8 37 b1 ff ff       	call   801003f4 <cprintf>
801052bd:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801052c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c3:	8b 40 18             	mov    0x18(%eax),%eax
801052c6:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801052cd:	90                   	nop
801052ce:	90                   	nop
801052cf:	c9                   	leave  
801052d0:	c3                   	ret    

801052d1 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801052d1:	55                   	push   %ebp
801052d2:	89 e5                	mov    %esp,%ebp
801052d4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801052d7:	83 ec 08             	sub    $0x8,%esp
801052da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052dd:	50                   	push   %eax
801052de:	ff 75 08             	push   0x8(%ebp)
801052e1:	e8 a1 fe ff ff       	call   80105187 <argint>
801052e6:	83 c4 10             	add    $0x10,%esp
801052e9:	85 c0                	test   %eax,%eax
801052eb:	79 07                	jns    801052f4 <argfd+0x23>
    return -1;
801052ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f2:	eb 4f                	jmp    80105343 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801052f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052f7:	85 c0                	test   %eax,%eax
801052f9:	78 20                	js     8010531b <argfd+0x4a>
801052fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052fe:	83 f8 0f             	cmp    $0xf,%eax
80105301:	7f 18                	jg     8010531b <argfd+0x4a>
80105303:	e8 56 e7 ff ff       	call   80103a5e <myproc>
80105308:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010530b:	83 c2 08             	add    $0x8,%edx
8010530e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105312:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105315:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105319:	75 07                	jne    80105322 <argfd+0x51>
    return -1;
8010531b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105320:	eb 21                	jmp    80105343 <argfd+0x72>
  if(pfd)
80105322:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105326:	74 08                	je     80105330 <argfd+0x5f>
    *pfd = fd;
80105328:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010532b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105334:	74 08                	je     8010533e <argfd+0x6d>
    *pf = f;
80105336:	8b 45 10             	mov    0x10(%ebp),%eax
80105339:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010533c:	89 10                	mov    %edx,(%eax)
  return 0;
8010533e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105343:	c9                   	leave  
80105344:	c3                   	ret    

80105345 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105345:	55                   	push   %ebp
80105346:	89 e5                	mov    %esp,%ebp
80105348:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010534b:	e8 0e e7 ff ff       	call   80103a5e <myproc>
80105350:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010535a:	eb 2a                	jmp    80105386 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
8010535c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105362:	83 c2 08             	add    $0x8,%edx
80105365:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105369:	85 c0                	test   %eax,%eax
8010536b:	75 15                	jne    80105382 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
8010536d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105370:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105373:	8d 4a 08             	lea    0x8(%edx),%ecx
80105376:	8b 55 08             	mov    0x8(%ebp),%edx
80105379:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010537d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105380:	eb 0f                	jmp    80105391 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105382:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105386:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010538a:	7e d0                	jle    8010535c <fdalloc+0x17>
    }
  }
  return -1;
8010538c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105391:	c9                   	leave  
80105392:	c3                   	ret    

80105393 <sys_dup>:

int
sys_dup(void)
{
80105393:	55                   	push   %ebp
80105394:	89 e5                	mov    %esp,%ebp
80105396:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105399:	83 ec 04             	sub    $0x4,%esp
8010539c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010539f:	50                   	push   %eax
801053a0:	6a 00                	push   $0x0
801053a2:	6a 00                	push   $0x0
801053a4:	e8 28 ff ff ff       	call   801052d1 <argfd>
801053a9:	83 c4 10             	add    $0x10,%esp
801053ac:	85 c0                	test   %eax,%eax
801053ae:	79 07                	jns    801053b7 <sys_dup+0x24>
    return -1;
801053b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b5:	eb 31                	jmp    801053e8 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801053b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ba:	83 ec 0c             	sub    $0xc,%esp
801053bd:	50                   	push   %eax
801053be:	e8 82 ff ff ff       	call   80105345 <fdalloc>
801053c3:	83 c4 10             	add    $0x10,%esp
801053c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053cd:	79 07                	jns    801053d6 <sys_dup+0x43>
    return -1;
801053cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d4:	eb 12                	jmp    801053e8 <sys_dup+0x55>
  filedup(f);
801053d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d9:	83 ec 0c             	sub    $0xc,%esp
801053dc:	50                   	push   %eax
801053dd:	e8 68 bc ff ff       	call   8010104a <filedup>
801053e2:	83 c4 10             	add    $0x10,%esp
  return fd;
801053e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053e8:	c9                   	leave  
801053e9:	c3                   	ret    

801053ea <sys_read>:

int
sys_read(void)
{
801053ea:	55                   	push   %ebp
801053eb:	89 e5                	mov    %esp,%ebp
801053ed:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053f0:	83 ec 04             	sub    $0x4,%esp
801053f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053f6:	50                   	push   %eax
801053f7:	6a 00                	push   $0x0
801053f9:	6a 00                	push   $0x0
801053fb:	e8 d1 fe ff ff       	call   801052d1 <argfd>
80105400:	83 c4 10             	add    $0x10,%esp
80105403:	85 c0                	test   %eax,%eax
80105405:	78 2e                	js     80105435 <sys_read+0x4b>
80105407:	83 ec 08             	sub    $0x8,%esp
8010540a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010540d:	50                   	push   %eax
8010540e:	6a 02                	push   $0x2
80105410:	e8 72 fd ff ff       	call   80105187 <argint>
80105415:	83 c4 10             	add    $0x10,%esp
80105418:	85 c0                	test   %eax,%eax
8010541a:	78 19                	js     80105435 <sys_read+0x4b>
8010541c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010541f:	83 ec 04             	sub    $0x4,%esp
80105422:	50                   	push   %eax
80105423:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105426:	50                   	push   %eax
80105427:	6a 01                	push   $0x1
80105429:	e8 86 fd ff ff       	call   801051b4 <argptr>
8010542e:	83 c4 10             	add    $0x10,%esp
80105431:	85 c0                	test   %eax,%eax
80105433:	79 07                	jns    8010543c <sys_read+0x52>
    return -1;
80105435:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010543a:	eb 17                	jmp    80105453 <sys_read+0x69>
  return fileread(f, p, n);
8010543c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010543f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105445:	83 ec 04             	sub    $0x4,%esp
80105448:	51                   	push   %ecx
80105449:	52                   	push   %edx
8010544a:	50                   	push   %eax
8010544b:	e8 8a bd ff ff       	call   801011da <fileread>
80105450:	83 c4 10             	add    $0x10,%esp
}
80105453:	c9                   	leave  
80105454:	c3                   	ret    

80105455 <sys_write>:

int
sys_write(void)
{
80105455:	55                   	push   %ebp
80105456:	89 e5                	mov    %esp,%ebp
80105458:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010545b:	83 ec 04             	sub    $0x4,%esp
8010545e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105461:	50                   	push   %eax
80105462:	6a 00                	push   $0x0
80105464:	6a 00                	push   $0x0
80105466:	e8 66 fe ff ff       	call   801052d1 <argfd>
8010546b:	83 c4 10             	add    $0x10,%esp
8010546e:	85 c0                	test   %eax,%eax
80105470:	78 2e                	js     801054a0 <sys_write+0x4b>
80105472:	83 ec 08             	sub    $0x8,%esp
80105475:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105478:	50                   	push   %eax
80105479:	6a 02                	push   $0x2
8010547b:	e8 07 fd ff ff       	call   80105187 <argint>
80105480:	83 c4 10             	add    $0x10,%esp
80105483:	85 c0                	test   %eax,%eax
80105485:	78 19                	js     801054a0 <sys_write+0x4b>
80105487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010548a:	83 ec 04             	sub    $0x4,%esp
8010548d:	50                   	push   %eax
8010548e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105491:	50                   	push   %eax
80105492:	6a 01                	push   $0x1
80105494:	e8 1b fd ff ff       	call   801051b4 <argptr>
80105499:	83 c4 10             	add    $0x10,%esp
8010549c:	85 c0                	test   %eax,%eax
8010549e:	79 07                	jns    801054a7 <sys_write+0x52>
    return -1;
801054a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a5:	eb 17                	jmp    801054be <sys_write+0x69>
  return filewrite(f, p, n);
801054a7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801054aa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801054ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b0:	83 ec 04             	sub    $0x4,%esp
801054b3:	51                   	push   %ecx
801054b4:	52                   	push   %edx
801054b5:	50                   	push   %eax
801054b6:	e8 d7 bd ff ff       	call   80101292 <filewrite>
801054bb:	83 c4 10             	add    $0x10,%esp
}
801054be:	c9                   	leave  
801054bf:	c3                   	ret    

801054c0 <sys_close>:

int
sys_close(void)
{
801054c0:	55                   	push   %ebp
801054c1:	89 e5                	mov    %esp,%ebp
801054c3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801054c6:	83 ec 04             	sub    $0x4,%esp
801054c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054cc:	50                   	push   %eax
801054cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054d0:	50                   	push   %eax
801054d1:	6a 00                	push   $0x0
801054d3:	e8 f9 fd ff ff       	call   801052d1 <argfd>
801054d8:	83 c4 10             	add    $0x10,%esp
801054db:	85 c0                	test   %eax,%eax
801054dd:	79 07                	jns    801054e6 <sys_close+0x26>
    return -1;
801054df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e4:	eb 27                	jmp    8010550d <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801054e6:	e8 73 e5 ff ff       	call   80103a5e <myproc>
801054eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054ee:	83 c2 08             	add    $0x8,%edx
801054f1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054f8:	00 
  fileclose(f);
801054f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054fc:	83 ec 0c             	sub    $0xc,%esp
801054ff:	50                   	push   %eax
80105500:	e8 96 bb ff ff       	call   8010109b <fileclose>
80105505:	83 c4 10             	add    $0x10,%esp
  return 0;
80105508:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010550d:	c9                   	leave  
8010550e:	c3                   	ret    

8010550f <sys_fstat>:

int
sys_fstat(void)
{
8010550f:	55                   	push   %ebp
80105510:	89 e5                	mov    %esp,%ebp
80105512:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105515:	83 ec 04             	sub    $0x4,%esp
80105518:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010551b:	50                   	push   %eax
8010551c:	6a 00                	push   $0x0
8010551e:	6a 00                	push   $0x0
80105520:	e8 ac fd ff ff       	call   801052d1 <argfd>
80105525:	83 c4 10             	add    $0x10,%esp
80105528:	85 c0                	test   %eax,%eax
8010552a:	78 17                	js     80105543 <sys_fstat+0x34>
8010552c:	83 ec 04             	sub    $0x4,%esp
8010552f:	6a 14                	push   $0x14
80105531:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105534:	50                   	push   %eax
80105535:	6a 01                	push   $0x1
80105537:	e8 78 fc ff ff       	call   801051b4 <argptr>
8010553c:	83 c4 10             	add    $0x10,%esp
8010553f:	85 c0                	test   %eax,%eax
80105541:	79 07                	jns    8010554a <sys_fstat+0x3b>
    return -1;
80105543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105548:	eb 13                	jmp    8010555d <sys_fstat+0x4e>
  return filestat(f, st);
8010554a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010554d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105550:	83 ec 08             	sub    $0x8,%esp
80105553:	52                   	push   %edx
80105554:	50                   	push   %eax
80105555:	e8 29 bc ff ff       	call   80101183 <filestat>
8010555a:	83 c4 10             	add    $0x10,%esp
}
8010555d:	c9                   	leave  
8010555e:	c3                   	ret    

8010555f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010555f:	55                   	push   %ebp
80105560:	89 e5                	mov    %esp,%ebp
80105562:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105565:	83 ec 08             	sub    $0x8,%esp
80105568:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010556b:	50                   	push   %eax
8010556c:	6a 00                	push   $0x0
8010556e:	e8 a9 fc ff ff       	call   8010521c <argstr>
80105573:	83 c4 10             	add    $0x10,%esp
80105576:	85 c0                	test   %eax,%eax
80105578:	78 15                	js     8010558f <sys_link+0x30>
8010557a:	83 ec 08             	sub    $0x8,%esp
8010557d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105580:	50                   	push   %eax
80105581:	6a 01                	push   $0x1
80105583:	e8 94 fc ff ff       	call   8010521c <argstr>
80105588:	83 c4 10             	add    $0x10,%esp
8010558b:	85 c0                	test   %eax,%eax
8010558d:	79 0a                	jns    80105599 <sys_link+0x3a>
    return -1;
8010558f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105594:	e9 68 01 00 00       	jmp    80105701 <sys_link+0x1a2>

  begin_op();
80105599:	e8 9e da ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
8010559e:	8b 45 d8             	mov    -0x28(%ebp),%eax
801055a1:	83 ec 0c             	sub    $0xc,%esp
801055a4:	50                   	push   %eax
801055a5:	e8 73 cf ff ff       	call   8010251d <namei>
801055aa:	83 c4 10             	add    $0x10,%esp
801055ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055b4:	75 0f                	jne    801055c5 <sys_link+0x66>
    end_op();
801055b6:	e8 0d db ff ff       	call   801030c8 <end_op>
    return -1;
801055bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c0:	e9 3c 01 00 00       	jmp    80105701 <sys_link+0x1a2>
  }

  ilock(ip);
801055c5:	83 ec 0c             	sub    $0xc,%esp
801055c8:	ff 75 f4             	push   -0xc(%ebp)
801055cb:	e8 1a c4 ff ff       	call   801019ea <ilock>
801055d0:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801055d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055da:	66 83 f8 01          	cmp    $0x1,%ax
801055de:	75 1d                	jne    801055fd <sys_link+0x9e>
    iunlockput(ip);
801055e0:	83 ec 0c             	sub    $0xc,%esp
801055e3:	ff 75 f4             	push   -0xc(%ebp)
801055e6:	e8 30 c6 ff ff       	call   80101c1b <iunlockput>
801055eb:	83 c4 10             	add    $0x10,%esp
    end_op();
801055ee:	e8 d5 da ff ff       	call   801030c8 <end_op>
    return -1;
801055f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f8:	e9 04 01 00 00       	jmp    80105701 <sys_link+0x1a2>
  }

  ip->nlink++;
801055fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105600:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105604:	83 c0 01             	add    $0x1,%eax
80105607:	89 c2                	mov    %eax,%edx
80105609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105610:	83 ec 0c             	sub    $0xc,%esp
80105613:	ff 75 f4             	push   -0xc(%ebp)
80105616:	e8 f2 c1 ff ff       	call   8010180d <iupdate>
8010561b:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010561e:	83 ec 0c             	sub    $0xc,%esp
80105621:	ff 75 f4             	push   -0xc(%ebp)
80105624:	e8 d4 c4 ff ff       	call   80101afd <iunlock>
80105629:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010562c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010562f:	83 ec 08             	sub    $0x8,%esp
80105632:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105635:	52                   	push   %edx
80105636:	50                   	push   %eax
80105637:	e8 fd ce ff ff       	call   80102539 <nameiparent>
8010563c:	83 c4 10             	add    $0x10,%esp
8010563f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105642:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105646:	74 71                	je     801056b9 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105648:	83 ec 0c             	sub    $0xc,%esp
8010564b:	ff 75 f0             	push   -0x10(%ebp)
8010564e:	e8 97 c3 ff ff       	call   801019ea <ilock>
80105653:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105659:	8b 10                	mov    (%eax),%edx
8010565b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565e:	8b 00                	mov    (%eax),%eax
80105660:	39 c2                	cmp    %eax,%edx
80105662:	75 1d                	jne    80105681 <sys_link+0x122>
80105664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105667:	8b 40 04             	mov    0x4(%eax),%eax
8010566a:	83 ec 04             	sub    $0x4,%esp
8010566d:	50                   	push   %eax
8010566e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105671:	50                   	push   %eax
80105672:	ff 75 f0             	push   -0x10(%ebp)
80105675:	e8 0c cc ff ff       	call   80102286 <dirlink>
8010567a:	83 c4 10             	add    $0x10,%esp
8010567d:	85 c0                	test   %eax,%eax
8010567f:	79 10                	jns    80105691 <sys_link+0x132>
    iunlockput(dp);
80105681:	83 ec 0c             	sub    $0xc,%esp
80105684:	ff 75 f0             	push   -0x10(%ebp)
80105687:	e8 8f c5 ff ff       	call   80101c1b <iunlockput>
8010568c:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010568f:	eb 29                	jmp    801056ba <sys_link+0x15b>
  }
  iunlockput(dp);
80105691:	83 ec 0c             	sub    $0xc,%esp
80105694:	ff 75 f0             	push   -0x10(%ebp)
80105697:	e8 7f c5 ff ff       	call   80101c1b <iunlockput>
8010569c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010569f:	83 ec 0c             	sub    $0xc,%esp
801056a2:	ff 75 f4             	push   -0xc(%ebp)
801056a5:	e8 a1 c4 ff ff       	call   80101b4b <iput>
801056aa:	83 c4 10             	add    $0x10,%esp

  end_op();
801056ad:	e8 16 da ff ff       	call   801030c8 <end_op>

  return 0;
801056b2:	b8 00 00 00 00       	mov    $0x0,%eax
801056b7:	eb 48                	jmp    80105701 <sys_link+0x1a2>
    goto bad;
801056b9:	90                   	nop

bad:
  ilock(ip);
801056ba:	83 ec 0c             	sub    $0xc,%esp
801056bd:	ff 75 f4             	push   -0xc(%ebp)
801056c0:	e8 25 c3 ff ff       	call   801019ea <ilock>
801056c5:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801056c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056cb:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056cf:	83 e8 01             	sub    $0x1,%eax
801056d2:	89 c2                	mov    %eax,%edx
801056d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d7:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056db:	83 ec 0c             	sub    $0xc,%esp
801056de:	ff 75 f4             	push   -0xc(%ebp)
801056e1:	e8 27 c1 ff ff       	call   8010180d <iupdate>
801056e6:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801056e9:	83 ec 0c             	sub    $0xc,%esp
801056ec:	ff 75 f4             	push   -0xc(%ebp)
801056ef:	e8 27 c5 ff ff       	call   80101c1b <iunlockput>
801056f4:	83 c4 10             	add    $0x10,%esp
  end_op();
801056f7:	e8 cc d9 ff ff       	call   801030c8 <end_op>
  return -1;
801056fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105701:	c9                   	leave  
80105702:	c3                   	ret    

80105703 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105703:	55                   	push   %ebp
80105704:	89 e5                	mov    %esp,%ebp
80105706:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105709:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105710:	eb 40                	jmp    80105752 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105715:	6a 10                	push   $0x10
80105717:	50                   	push   %eax
80105718:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010571b:	50                   	push   %eax
8010571c:	ff 75 08             	push   0x8(%ebp)
8010571f:	e8 b2 c7 ff ff       	call   80101ed6 <readi>
80105724:	83 c4 10             	add    $0x10,%esp
80105727:	83 f8 10             	cmp    $0x10,%eax
8010572a:	74 0d                	je     80105739 <isdirempty+0x36>
      panic("isdirempty: readi");
8010572c:	83 ec 0c             	sub    $0xc,%esp
8010572f:	68 43 ab 10 80       	push   $0x8010ab43
80105734:	e8 70 ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105739:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010573d:	66 85 c0             	test   %ax,%ax
80105740:	74 07                	je     80105749 <isdirempty+0x46>
      return 0;
80105742:	b8 00 00 00 00       	mov    $0x0,%eax
80105747:	eb 1b                	jmp    80105764 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574c:	83 c0 10             	add    $0x10,%eax
8010574f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105752:	8b 45 08             	mov    0x8(%ebp),%eax
80105755:	8b 50 58             	mov    0x58(%eax),%edx
80105758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010575b:	39 c2                	cmp    %eax,%edx
8010575d:	77 b3                	ja     80105712 <isdirempty+0xf>
  }
  return 1;
8010575f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105764:	c9                   	leave  
80105765:	c3                   	ret    

80105766 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105766:	55                   	push   %ebp
80105767:	89 e5                	mov    %esp,%ebp
80105769:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010576c:	83 ec 08             	sub    $0x8,%esp
8010576f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105772:	50                   	push   %eax
80105773:	6a 00                	push   $0x0
80105775:	e8 a2 fa ff ff       	call   8010521c <argstr>
8010577a:	83 c4 10             	add    $0x10,%esp
8010577d:	85 c0                	test   %eax,%eax
8010577f:	79 0a                	jns    8010578b <sys_unlink+0x25>
    return -1;
80105781:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105786:	e9 bf 01 00 00       	jmp    8010594a <sys_unlink+0x1e4>

  begin_op();
8010578b:	e8 ac d8 ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105790:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105793:	83 ec 08             	sub    $0x8,%esp
80105796:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105799:	52                   	push   %edx
8010579a:	50                   	push   %eax
8010579b:	e8 99 cd ff ff       	call   80102539 <nameiparent>
801057a0:	83 c4 10             	add    $0x10,%esp
801057a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057aa:	75 0f                	jne    801057bb <sys_unlink+0x55>
    end_op();
801057ac:	e8 17 d9 ff ff       	call   801030c8 <end_op>
    return -1;
801057b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b6:	e9 8f 01 00 00       	jmp    8010594a <sys_unlink+0x1e4>
  }

  ilock(dp);
801057bb:	83 ec 0c             	sub    $0xc,%esp
801057be:	ff 75 f4             	push   -0xc(%ebp)
801057c1:	e8 24 c2 ff ff       	call   801019ea <ilock>
801057c6:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801057c9:	83 ec 08             	sub    $0x8,%esp
801057cc:	68 55 ab 10 80       	push   $0x8010ab55
801057d1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057d4:	50                   	push   %eax
801057d5:	e8 d7 c9 ff ff       	call   801021b1 <namecmp>
801057da:	83 c4 10             	add    $0x10,%esp
801057dd:	85 c0                	test   %eax,%eax
801057df:	0f 84 49 01 00 00    	je     8010592e <sys_unlink+0x1c8>
801057e5:	83 ec 08             	sub    $0x8,%esp
801057e8:	68 57 ab 10 80       	push   $0x8010ab57
801057ed:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057f0:	50                   	push   %eax
801057f1:	e8 bb c9 ff ff       	call   801021b1 <namecmp>
801057f6:	83 c4 10             	add    $0x10,%esp
801057f9:	85 c0                	test   %eax,%eax
801057fb:	0f 84 2d 01 00 00    	je     8010592e <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105801:	83 ec 04             	sub    $0x4,%esp
80105804:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105807:	50                   	push   %eax
80105808:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010580b:	50                   	push   %eax
8010580c:	ff 75 f4             	push   -0xc(%ebp)
8010580f:	e8 b8 c9 ff ff       	call   801021cc <dirlookup>
80105814:	83 c4 10             	add    $0x10,%esp
80105817:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010581a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010581e:	0f 84 0d 01 00 00    	je     80105931 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105824:	83 ec 0c             	sub    $0xc,%esp
80105827:	ff 75 f0             	push   -0x10(%ebp)
8010582a:	e8 bb c1 ff ff       	call   801019ea <ilock>
8010582f:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105835:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105839:	66 85 c0             	test   %ax,%ax
8010583c:	7f 0d                	jg     8010584b <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010583e:	83 ec 0c             	sub    $0xc,%esp
80105841:	68 5a ab 10 80       	push   $0x8010ab5a
80105846:	e8 5e ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010584b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105852:	66 83 f8 01          	cmp    $0x1,%ax
80105856:	75 25                	jne    8010587d <sys_unlink+0x117>
80105858:	83 ec 0c             	sub    $0xc,%esp
8010585b:	ff 75 f0             	push   -0x10(%ebp)
8010585e:	e8 a0 fe ff ff       	call   80105703 <isdirempty>
80105863:	83 c4 10             	add    $0x10,%esp
80105866:	85 c0                	test   %eax,%eax
80105868:	75 13                	jne    8010587d <sys_unlink+0x117>
    iunlockput(ip);
8010586a:	83 ec 0c             	sub    $0xc,%esp
8010586d:	ff 75 f0             	push   -0x10(%ebp)
80105870:	e8 a6 c3 ff ff       	call   80101c1b <iunlockput>
80105875:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105878:	e9 b5 00 00 00       	jmp    80105932 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
8010587d:	83 ec 04             	sub    $0x4,%esp
80105880:	6a 10                	push   $0x10
80105882:	6a 00                	push   $0x0
80105884:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105887:	50                   	push   %eax
80105888:	e8 cf f5 ff ff       	call   80104e5c <memset>
8010588d:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105890:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105893:	6a 10                	push   $0x10
80105895:	50                   	push   %eax
80105896:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105899:	50                   	push   %eax
8010589a:	ff 75 f4             	push   -0xc(%ebp)
8010589d:	e8 89 c7 ff ff       	call   8010202b <writei>
801058a2:	83 c4 10             	add    $0x10,%esp
801058a5:	83 f8 10             	cmp    $0x10,%eax
801058a8:	74 0d                	je     801058b7 <sys_unlink+0x151>
    panic("unlink: writei");
801058aa:	83 ec 0c             	sub    $0xc,%esp
801058ad:	68 6c ab 10 80       	push   $0x8010ab6c
801058b2:	e8 f2 ac ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801058b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ba:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058be:	66 83 f8 01          	cmp    $0x1,%ax
801058c2:	75 21                	jne    801058e5 <sys_unlink+0x17f>
    dp->nlink--;
801058c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058cb:	83 e8 01             	sub    $0x1,%eax
801058ce:	89 c2                	mov    %eax,%edx
801058d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d3:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801058d7:	83 ec 0c             	sub    $0xc,%esp
801058da:	ff 75 f4             	push   -0xc(%ebp)
801058dd:	e8 2b bf ff ff       	call   8010180d <iupdate>
801058e2:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801058e5:	83 ec 0c             	sub    $0xc,%esp
801058e8:	ff 75 f4             	push   -0xc(%ebp)
801058eb:	e8 2b c3 ff ff       	call   80101c1b <iunlockput>
801058f0:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801058f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f6:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058fa:	83 e8 01             	sub    $0x1,%eax
801058fd:	89 c2                	mov    %eax,%edx
801058ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105902:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105906:	83 ec 0c             	sub    $0xc,%esp
80105909:	ff 75 f0             	push   -0x10(%ebp)
8010590c:	e8 fc be ff ff       	call   8010180d <iupdate>
80105911:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105914:	83 ec 0c             	sub    $0xc,%esp
80105917:	ff 75 f0             	push   -0x10(%ebp)
8010591a:	e8 fc c2 ff ff       	call   80101c1b <iunlockput>
8010591f:	83 c4 10             	add    $0x10,%esp

  end_op();
80105922:	e8 a1 d7 ff ff       	call   801030c8 <end_op>

  return 0;
80105927:	b8 00 00 00 00       	mov    $0x0,%eax
8010592c:	eb 1c                	jmp    8010594a <sys_unlink+0x1e4>
    goto bad;
8010592e:	90                   	nop
8010592f:	eb 01                	jmp    80105932 <sys_unlink+0x1cc>
    goto bad;
80105931:	90                   	nop

bad:
  iunlockput(dp);
80105932:	83 ec 0c             	sub    $0xc,%esp
80105935:	ff 75 f4             	push   -0xc(%ebp)
80105938:	e8 de c2 ff ff       	call   80101c1b <iunlockput>
8010593d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105940:	e8 83 d7 ff ff       	call   801030c8 <end_op>
  return -1;
80105945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010594a:	c9                   	leave  
8010594b:	c3                   	ret    

8010594c <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010594c:	55                   	push   %ebp
8010594d:	89 e5                	mov    %esp,%ebp
8010594f:	83 ec 38             	sub    $0x38,%esp
80105952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105955:	8b 55 10             	mov    0x10(%ebp),%edx
80105958:	8b 45 14             	mov    0x14(%ebp),%eax
8010595b:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010595f:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105963:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105967:	83 ec 08             	sub    $0x8,%esp
8010596a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010596d:	50                   	push   %eax
8010596e:	ff 75 08             	push   0x8(%ebp)
80105971:	e8 c3 cb ff ff       	call   80102539 <nameiparent>
80105976:	83 c4 10             	add    $0x10,%esp
80105979:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010597c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105980:	75 0a                	jne    8010598c <create+0x40>
    return 0;
80105982:	b8 00 00 00 00       	mov    $0x0,%eax
80105987:	e9 90 01 00 00       	jmp    80105b1c <create+0x1d0>
  ilock(dp);
8010598c:	83 ec 0c             	sub    $0xc,%esp
8010598f:	ff 75 f4             	push   -0xc(%ebp)
80105992:	e8 53 c0 ff ff       	call   801019ea <ilock>
80105997:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010599a:	83 ec 04             	sub    $0x4,%esp
8010599d:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059a0:	50                   	push   %eax
801059a1:	8d 45 de             	lea    -0x22(%ebp),%eax
801059a4:	50                   	push   %eax
801059a5:	ff 75 f4             	push   -0xc(%ebp)
801059a8:	e8 1f c8 ff ff       	call   801021cc <dirlookup>
801059ad:	83 c4 10             	add    $0x10,%esp
801059b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059b7:	74 50                	je     80105a09 <create+0xbd>
    iunlockput(dp);
801059b9:	83 ec 0c             	sub    $0xc,%esp
801059bc:	ff 75 f4             	push   -0xc(%ebp)
801059bf:	e8 57 c2 ff ff       	call   80101c1b <iunlockput>
801059c4:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801059c7:	83 ec 0c             	sub    $0xc,%esp
801059ca:	ff 75 f0             	push   -0x10(%ebp)
801059cd:	e8 18 c0 ff ff       	call   801019ea <ilock>
801059d2:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801059d5:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801059da:	75 15                	jne    801059f1 <create+0xa5>
801059dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059df:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059e3:	66 83 f8 02          	cmp    $0x2,%ax
801059e7:	75 08                	jne    801059f1 <create+0xa5>
      return ip;
801059e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ec:	e9 2b 01 00 00       	jmp    80105b1c <create+0x1d0>
    iunlockput(ip);
801059f1:	83 ec 0c             	sub    $0xc,%esp
801059f4:	ff 75 f0             	push   -0x10(%ebp)
801059f7:	e8 1f c2 ff ff       	call   80101c1b <iunlockput>
801059fc:	83 c4 10             	add    $0x10,%esp
    return 0;
801059ff:	b8 00 00 00 00       	mov    $0x0,%eax
80105a04:	e9 13 01 00 00       	jmp    80105b1c <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105a09:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a10:	8b 00                	mov    (%eax),%eax
80105a12:	83 ec 08             	sub    $0x8,%esp
80105a15:	52                   	push   %edx
80105a16:	50                   	push   %eax
80105a17:	e8 1a bd ff ff       	call   80101736 <ialloc>
80105a1c:	83 c4 10             	add    $0x10,%esp
80105a1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a26:	75 0d                	jne    80105a35 <create+0xe9>
    panic("create: ialloc");
80105a28:	83 ec 0c             	sub    $0xc,%esp
80105a2b:	68 7b ab 10 80       	push   $0x8010ab7b
80105a30:	e8 74 ab ff ff       	call   801005a9 <panic>

  ilock(ip);
80105a35:	83 ec 0c             	sub    $0xc,%esp
80105a38:	ff 75 f0             	push   -0x10(%ebp)
80105a3b:	e8 aa bf ff ff       	call   801019ea <ilock>
80105a40:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a46:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a4a:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a51:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a55:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5c:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a62:	83 ec 0c             	sub    $0xc,%esp
80105a65:	ff 75 f0             	push   -0x10(%ebp)
80105a68:	e8 a0 bd ff ff       	call   8010180d <iupdate>
80105a6d:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a70:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a75:	75 6a                	jne    80105ae1 <create+0x195>
    dp->nlink++;  // for ".."
80105a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a7e:	83 c0 01             	add    $0x1,%eax
80105a81:	89 c2                	mov    %eax,%edx
80105a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a86:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a8a:	83 ec 0c             	sub    $0xc,%esp
80105a8d:	ff 75 f4             	push   -0xc(%ebp)
80105a90:	e8 78 bd ff ff       	call   8010180d <iupdate>
80105a95:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9b:	8b 40 04             	mov    0x4(%eax),%eax
80105a9e:	83 ec 04             	sub    $0x4,%esp
80105aa1:	50                   	push   %eax
80105aa2:	68 55 ab 10 80       	push   $0x8010ab55
80105aa7:	ff 75 f0             	push   -0x10(%ebp)
80105aaa:	e8 d7 c7 ff ff       	call   80102286 <dirlink>
80105aaf:	83 c4 10             	add    $0x10,%esp
80105ab2:	85 c0                	test   %eax,%eax
80105ab4:	78 1e                	js     80105ad4 <create+0x188>
80105ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab9:	8b 40 04             	mov    0x4(%eax),%eax
80105abc:	83 ec 04             	sub    $0x4,%esp
80105abf:	50                   	push   %eax
80105ac0:	68 57 ab 10 80       	push   $0x8010ab57
80105ac5:	ff 75 f0             	push   -0x10(%ebp)
80105ac8:	e8 b9 c7 ff ff       	call   80102286 <dirlink>
80105acd:	83 c4 10             	add    $0x10,%esp
80105ad0:	85 c0                	test   %eax,%eax
80105ad2:	79 0d                	jns    80105ae1 <create+0x195>
      panic("create dots");
80105ad4:	83 ec 0c             	sub    $0xc,%esp
80105ad7:	68 8a ab 10 80       	push   $0x8010ab8a
80105adc:	e8 c8 aa ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae4:	8b 40 04             	mov    0x4(%eax),%eax
80105ae7:	83 ec 04             	sub    $0x4,%esp
80105aea:	50                   	push   %eax
80105aeb:	8d 45 de             	lea    -0x22(%ebp),%eax
80105aee:	50                   	push   %eax
80105aef:	ff 75 f4             	push   -0xc(%ebp)
80105af2:	e8 8f c7 ff ff       	call   80102286 <dirlink>
80105af7:	83 c4 10             	add    $0x10,%esp
80105afa:	85 c0                	test   %eax,%eax
80105afc:	79 0d                	jns    80105b0b <create+0x1bf>
    panic("create: dirlink");
80105afe:	83 ec 0c             	sub    $0xc,%esp
80105b01:	68 96 ab 10 80       	push   $0x8010ab96
80105b06:	e8 9e aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105b0b:	83 ec 0c             	sub    $0xc,%esp
80105b0e:	ff 75 f4             	push   -0xc(%ebp)
80105b11:	e8 05 c1 ff ff       	call   80101c1b <iunlockput>
80105b16:	83 c4 10             	add    $0x10,%esp

  return ip;
80105b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105b1c:	c9                   	leave  
80105b1d:	c3                   	ret    

80105b1e <sys_open>:

int
sys_open(void)
{
80105b1e:	55                   	push   %ebp
80105b1f:	89 e5                	mov    %esp,%ebp
80105b21:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105b24:	83 ec 08             	sub    $0x8,%esp
80105b27:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b2a:	50                   	push   %eax
80105b2b:	6a 00                	push   $0x0
80105b2d:	e8 ea f6 ff ff       	call   8010521c <argstr>
80105b32:	83 c4 10             	add    $0x10,%esp
80105b35:	85 c0                	test   %eax,%eax
80105b37:	78 15                	js     80105b4e <sys_open+0x30>
80105b39:	83 ec 08             	sub    $0x8,%esp
80105b3c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b3f:	50                   	push   %eax
80105b40:	6a 01                	push   $0x1
80105b42:	e8 40 f6 ff ff       	call   80105187 <argint>
80105b47:	83 c4 10             	add    $0x10,%esp
80105b4a:	85 c0                	test   %eax,%eax
80105b4c:	79 0a                	jns    80105b58 <sys_open+0x3a>
    return -1;
80105b4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b53:	e9 61 01 00 00       	jmp    80105cb9 <sys_open+0x19b>

  begin_op();
80105b58:	e8 df d4 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
80105b5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b60:	25 00 02 00 00       	and    $0x200,%eax
80105b65:	85 c0                	test   %eax,%eax
80105b67:	74 2a                	je     80105b93 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b6c:	6a 00                	push   $0x0
80105b6e:	6a 00                	push   $0x0
80105b70:	6a 02                	push   $0x2
80105b72:	50                   	push   %eax
80105b73:	e8 d4 fd ff ff       	call   8010594c <create>
80105b78:	83 c4 10             	add    $0x10,%esp
80105b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b82:	75 75                	jne    80105bf9 <sys_open+0xdb>
      end_op();
80105b84:	e8 3f d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105b89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8e:	e9 26 01 00 00       	jmp    80105cb9 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b96:	83 ec 0c             	sub    $0xc,%esp
80105b99:	50                   	push   %eax
80105b9a:	e8 7e c9 ff ff       	call   8010251d <namei>
80105b9f:	83 c4 10             	add    $0x10,%esp
80105ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ba9:	75 0f                	jne    80105bba <sys_open+0x9c>
      end_op();
80105bab:	e8 18 d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb5:	e9 ff 00 00 00       	jmp    80105cb9 <sys_open+0x19b>
    }
    ilock(ip);
80105bba:	83 ec 0c             	sub    $0xc,%esp
80105bbd:	ff 75 f4             	push   -0xc(%ebp)
80105bc0:	e8 25 be ff ff       	call   801019ea <ilock>
80105bc5:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bcf:	66 83 f8 01          	cmp    $0x1,%ax
80105bd3:	75 24                	jne    80105bf9 <sys_open+0xdb>
80105bd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bd8:	85 c0                	test   %eax,%eax
80105bda:	74 1d                	je     80105bf9 <sys_open+0xdb>
      iunlockput(ip);
80105bdc:	83 ec 0c             	sub    $0xc,%esp
80105bdf:	ff 75 f4             	push   -0xc(%ebp)
80105be2:	e8 34 c0 ff ff       	call   80101c1b <iunlockput>
80105be7:	83 c4 10             	add    $0x10,%esp
      end_op();
80105bea:	e8 d9 d4 ff ff       	call   801030c8 <end_op>
      return -1;
80105bef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf4:	e9 c0 00 00 00       	jmp    80105cb9 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105bf9:	e8 df b3 ff ff       	call   80100fdd <filealloc>
80105bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c05:	74 17                	je     80105c1e <sys_open+0x100>
80105c07:	83 ec 0c             	sub    $0xc,%esp
80105c0a:	ff 75 f0             	push   -0x10(%ebp)
80105c0d:	e8 33 f7 ff ff       	call   80105345 <fdalloc>
80105c12:	83 c4 10             	add    $0x10,%esp
80105c15:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105c18:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c1c:	79 2e                	jns    80105c4c <sys_open+0x12e>
    if(f)
80105c1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c22:	74 0e                	je     80105c32 <sys_open+0x114>
      fileclose(f);
80105c24:	83 ec 0c             	sub    $0xc,%esp
80105c27:	ff 75 f0             	push   -0x10(%ebp)
80105c2a:	e8 6c b4 ff ff       	call   8010109b <fileclose>
80105c2f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105c32:	83 ec 0c             	sub    $0xc,%esp
80105c35:	ff 75 f4             	push   -0xc(%ebp)
80105c38:	e8 de bf ff ff       	call   80101c1b <iunlockput>
80105c3d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c40:	e8 83 d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105c45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4a:	eb 6d                	jmp    80105cb9 <sys_open+0x19b>
  }
  iunlock(ip);
80105c4c:	83 ec 0c             	sub    $0xc,%esp
80105c4f:	ff 75 f4             	push   -0xc(%ebp)
80105c52:	e8 a6 be ff ff       	call   80101afd <iunlock>
80105c57:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c5a:	e8 69 d4 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c62:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c6e:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c74:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c7e:	83 e0 01             	and    $0x1,%eax
80105c81:	85 c0                	test   %eax,%eax
80105c83:	0f 94 c0             	sete   %al
80105c86:	89 c2                	mov    %eax,%edx
80105c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8b:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c91:	83 e0 01             	and    $0x1,%eax
80105c94:	85 c0                	test   %eax,%eax
80105c96:	75 0a                	jne    80105ca2 <sys_open+0x184>
80105c98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c9b:	83 e0 02             	and    $0x2,%eax
80105c9e:	85 c0                	test   %eax,%eax
80105ca0:	74 07                	je     80105ca9 <sys_open+0x18b>
80105ca2:	b8 01 00 00 00       	mov    $0x1,%eax
80105ca7:	eb 05                	jmp    80105cae <sys_open+0x190>
80105ca9:	b8 00 00 00 00       	mov    $0x0,%eax
80105cae:	89 c2                	mov    %eax,%edx
80105cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb3:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105cb9:	c9                   	leave  
80105cba:	c3                   	ret    

80105cbb <sys_mkdir>:

int
sys_mkdir(void)
{
80105cbb:	55                   	push   %ebp
80105cbc:	89 e5                	mov    %esp,%ebp
80105cbe:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105cc1:	e8 76 d3 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105cc6:	83 ec 08             	sub    $0x8,%esp
80105cc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ccc:	50                   	push   %eax
80105ccd:	6a 00                	push   $0x0
80105ccf:	e8 48 f5 ff ff       	call   8010521c <argstr>
80105cd4:	83 c4 10             	add    $0x10,%esp
80105cd7:	85 c0                	test   %eax,%eax
80105cd9:	78 1b                	js     80105cf6 <sys_mkdir+0x3b>
80105cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cde:	6a 00                	push   $0x0
80105ce0:	6a 00                	push   $0x0
80105ce2:	6a 01                	push   $0x1
80105ce4:	50                   	push   %eax
80105ce5:	e8 62 fc ff ff       	call   8010594c <create>
80105cea:	83 c4 10             	add    $0x10,%esp
80105ced:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cf0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cf4:	75 0c                	jne    80105d02 <sys_mkdir+0x47>
    end_op();
80105cf6:	e8 cd d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105cfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d00:	eb 18                	jmp    80105d1a <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105d02:	83 ec 0c             	sub    $0xc,%esp
80105d05:	ff 75 f4             	push   -0xc(%ebp)
80105d08:	e8 0e bf ff ff       	call   80101c1b <iunlockput>
80105d0d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d10:	e8 b3 d3 ff ff       	call   801030c8 <end_op>
  return 0;
80105d15:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d1a:	c9                   	leave  
80105d1b:	c3                   	ret    

80105d1c <sys_mknod>:

int
sys_mknod(void)
{
80105d1c:	55                   	push   %ebp
80105d1d:	89 e5                	mov    %esp,%ebp
80105d1f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105d22:	e8 15 d3 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105d27:	83 ec 08             	sub    $0x8,%esp
80105d2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d2d:	50                   	push   %eax
80105d2e:	6a 00                	push   $0x0
80105d30:	e8 e7 f4 ff ff       	call   8010521c <argstr>
80105d35:	83 c4 10             	add    $0x10,%esp
80105d38:	85 c0                	test   %eax,%eax
80105d3a:	78 4f                	js     80105d8b <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105d3c:	83 ec 08             	sub    $0x8,%esp
80105d3f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d42:	50                   	push   %eax
80105d43:	6a 01                	push   $0x1
80105d45:	e8 3d f4 ff ff       	call   80105187 <argint>
80105d4a:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d4d:	85 c0                	test   %eax,%eax
80105d4f:	78 3a                	js     80105d8b <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105d51:	83 ec 08             	sub    $0x8,%esp
80105d54:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d57:	50                   	push   %eax
80105d58:	6a 02                	push   $0x2
80105d5a:	e8 28 f4 ff ff       	call   80105187 <argint>
80105d5f:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d62:	85 c0                	test   %eax,%eax
80105d64:	78 25                	js     80105d8b <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d66:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d69:	0f bf c8             	movswl %ax,%ecx
80105d6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d6f:	0f bf d0             	movswl %ax,%edx
80105d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d75:	51                   	push   %ecx
80105d76:	52                   	push   %edx
80105d77:	6a 03                	push   $0x3
80105d79:	50                   	push   %eax
80105d7a:	e8 cd fb ff ff       	call   8010594c <create>
80105d7f:	83 c4 10             	add    $0x10,%esp
80105d82:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105d85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d89:	75 0c                	jne    80105d97 <sys_mknod+0x7b>
    end_op();
80105d8b:	e8 38 d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105d90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d95:	eb 18                	jmp    80105daf <sys_mknod+0x93>
  }
  iunlockput(ip);
80105d97:	83 ec 0c             	sub    $0xc,%esp
80105d9a:	ff 75 f4             	push   -0xc(%ebp)
80105d9d:	e8 79 be ff ff       	call   80101c1b <iunlockput>
80105da2:	83 c4 10             	add    $0x10,%esp
  end_op();
80105da5:	e8 1e d3 ff ff       	call   801030c8 <end_op>
  return 0;
80105daa:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105daf:	c9                   	leave  
80105db0:	c3                   	ret    

80105db1 <sys_chdir>:

int
sys_chdir(void)
{
80105db1:	55                   	push   %ebp
80105db2:	89 e5                	mov    %esp,%ebp
80105db4:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105db7:	e8 a2 dc ff ff       	call   80103a5e <myproc>
80105dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105dbf:	e8 78 d2 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105dc4:	83 ec 08             	sub    $0x8,%esp
80105dc7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dca:	50                   	push   %eax
80105dcb:	6a 00                	push   $0x0
80105dcd:	e8 4a f4 ff ff       	call   8010521c <argstr>
80105dd2:	83 c4 10             	add    $0x10,%esp
80105dd5:	85 c0                	test   %eax,%eax
80105dd7:	78 18                	js     80105df1 <sys_chdir+0x40>
80105dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ddc:	83 ec 0c             	sub    $0xc,%esp
80105ddf:	50                   	push   %eax
80105de0:	e8 38 c7 ff ff       	call   8010251d <namei>
80105de5:	83 c4 10             	add    $0x10,%esp
80105de8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105deb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105def:	75 0c                	jne    80105dfd <sys_chdir+0x4c>
    end_op();
80105df1:	e8 d2 d2 ff ff       	call   801030c8 <end_op>
    return -1;
80105df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfb:	eb 68                	jmp    80105e65 <sys_chdir+0xb4>
  }
  ilock(ip);
80105dfd:	83 ec 0c             	sub    $0xc,%esp
80105e00:	ff 75 f0             	push   -0x10(%ebp)
80105e03:	e8 e2 bb ff ff       	call   801019ea <ilock>
80105e08:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e12:	66 83 f8 01          	cmp    $0x1,%ax
80105e16:	74 1a                	je     80105e32 <sys_chdir+0x81>
    iunlockput(ip);
80105e18:	83 ec 0c             	sub    $0xc,%esp
80105e1b:	ff 75 f0             	push   -0x10(%ebp)
80105e1e:	e8 f8 bd ff ff       	call   80101c1b <iunlockput>
80105e23:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e26:	e8 9d d2 ff ff       	call   801030c8 <end_op>
    return -1;
80105e2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e30:	eb 33                	jmp    80105e65 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105e32:	83 ec 0c             	sub    $0xc,%esp
80105e35:	ff 75 f0             	push   -0x10(%ebp)
80105e38:	e8 c0 bc ff ff       	call   80101afd <iunlock>
80105e3d:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e43:	8b 40 68             	mov    0x68(%eax),%eax
80105e46:	83 ec 0c             	sub    $0xc,%esp
80105e49:	50                   	push   %eax
80105e4a:	e8 fc bc ff ff       	call   80101b4b <iput>
80105e4f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e52:	e8 71 d2 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e5d:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e60:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e65:	c9                   	leave  
80105e66:	c3                   	ret    

80105e67 <sys_exec>:

int
sys_exec(void)
{
80105e67:	55                   	push   %ebp
80105e68:	89 e5                	mov    %esp,%ebp
80105e6a:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e70:	83 ec 08             	sub    $0x8,%esp
80105e73:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e76:	50                   	push   %eax
80105e77:	6a 00                	push   $0x0
80105e79:	e8 9e f3 ff ff       	call   8010521c <argstr>
80105e7e:	83 c4 10             	add    $0x10,%esp
80105e81:	85 c0                	test   %eax,%eax
80105e83:	78 18                	js     80105e9d <sys_exec+0x36>
80105e85:	83 ec 08             	sub    $0x8,%esp
80105e88:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e8e:	50                   	push   %eax
80105e8f:	6a 01                	push   $0x1
80105e91:	e8 f1 f2 ff ff       	call   80105187 <argint>
80105e96:	83 c4 10             	add    $0x10,%esp
80105e99:	85 c0                	test   %eax,%eax
80105e9b:	79 0a                	jns    80105ea7 <sys_exec+0x40>
    return -1;
80105e9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea2:	e9 c6 00 00 00       	jmp    80105f6d <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105ea7:	83 ec 04             	sub    $0x4,%esp
80105eaa:	68 80 00 00 00       	push   $0x80
80105eaf:	6a 00                	push   $0x0
80105eb1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105eb7:	50                   	push   %eax
80105eb8:	e8 9f ef ff ff       	call   80104e5c <memset>
80105ebd:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105ec0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eca:	83 f8 1f             	cmp    $0x1f,%eax
80105ecd:	76 0a                	jbe    80105ed9 <sys_exec+0x72>
      return -1;
80105ecf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed4:	e9 94 00 00 00       	jmp    80105f6d <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edc:	c1 e0 02             	shl    $0x2,%eax
80105edf:	89 c2                	mov    %eax,%edx
80105ee1:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105ee7:	01 c2                	add    %eax,%edx
80105ee9:	83 ec 08             	sub    $0x8,%esp
80105eec:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105ef2:	50                   	push   %eax
80105ef3:	52                   	push   %edx
80105ef4:	e8 ed f1 ff ff       	call   801050e6 <fetchint>
80105ef9:	83 c4 10             	add    $0x10,%esp
80105efc:	85 c0                	test   %eax,%eax
80105efe:	79 07                	jns    80105f07 <sys_exec+0xa0>
      return -1;
80105f00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f05:	eb 66                	jmp    80105f6d <sys_exec+0x106>
    if(uarg == 0){
80105f07:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f0d:	85 c0                	test   %eax,%eax
80105f0f:	75 27                	jne    80105f38 <sys_exec+0xd1>
      argv[i] = 0;
80105f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f14:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105f1b:	00 00 00 00 
      break;
80105f1f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f23:	83 ec 08             	sub    $0x8,%esp
80105f26:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f2c:	52                   	push   %edx
80105f2d:	50                   	push   %eax
80105f2e:	e8 4d ac ff ff       	call   80100b80 <exec>
80105f33:	83 c4 10             	add    $0x10,%esp
80105f36:	eb 35                	jmp    80105f6d <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105f38:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f41:	c1 e0 02             	shl    $0x2,%eax
80105f44:	01 c2                	add    %eax,%edx
80105f46:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f4c:	83 ec 08             	sub    $0x8,%esp
80105f4f:	52                   	push   %edx
80105f50:	50                   	push   %eax
80105f51:	e8 cf f1 ff ff       	call   80105125 <fetchstr>
80105f56:	83 c4 10             	add    $0x10,%esp
80105f59:	85 c0                	test   %eax,%eax
80105f5b:	79 07                	jns    80105f64 <sys_exec+0xfd>
      return -1;
80105f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f62:	eb 09                	jmp    80105f6d <sys_exec+0x106>
  for(i=0;; i++){
80105f64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f68:	e9 5a ff ff ff       	jmp    80105ec7 <sys_exec+0x60>
}
80105f6d:	c9                   	leave  
80105f6e:	c3                   	ret    

80105f6f <sys_pipe>:

int
sys_pipe(void)
{
80105f6f:	55                   	push   %ebp
80105f70:	89 e5                	mov    %esp,%ebp
80105f72:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f75:	83 ec 04             	sub    $0x4,%esp
80105f78:	6a 08                	push   $0x8
80105f7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f7d:	50                   	push   %eax
80105f7e:	6a 00                	push   $0x0
80105f80:	e8 2f f2 ff ff       	call   801051b4 <argptr>
80105f85:	83 c4 10             	add    $0x10,%esp
80105f88:	85 c0                	test   %eax,%eax
80105f8a:	79 0a                	jns    80105f96 <sys_pipe+0x27>
    return -1;
80105f8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f91:	e9 ae 00 00 00       	jmp    80106044 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105f96:	83 ec 08             	sub    $0x8,%esp
80105f99:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f9c:	50                   	push   %eax
80105f9d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fa0:	50                   	push   %eax
80105fa1:	e8 c7 d5 ff ff       	call   8010356d <pipealloc>
80105fa6:	83 c4 10             	add    $0x10,%esp
80105fa9:	85 c0                	test   %eax,%eax
80105fab:	79 0a                	jns    80105fb7 <sys_pipe+0x48>
    return -1;
80105fad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb2:	e9 8d 00 00 00       	jmp    80106044 <sys_pipe+0xd5>
  fd0 = -1;
80105fb7:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105fbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fc1:	83 ec 0c             	sub    $0xc,%esp
80105fc4:	50                   	push   %eax
80105fc5:	e8 7b f3 ff ff       	call   80105345 <fdalloc>
80105fca:	83 c4 10             	add    $0x10,%esp
80105fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd4:	78 18                	js     80105fee <sys_pipe+0x7f>
80105fd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fd9:	83 ec 0c             	sub    $0xc,%esp
80105fdc:	50                   	push   %eax
80105fdd:	e8 63 f3 ff ff       	call   80105345 <fdalloc>
80105fe2:	83 c4 10             	add    $0x10,%esp
80105fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fe8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fec:	79 3e                	jns    8010602c <sys_pipe+0xbd>
    if(fd0 >= 0)
80105fee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ff2:	78 13                	js     80106007 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105ff4:	e8 65 da ff ff       	call   80103a5e <myproc>
80105ff9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ffc:	83 c2 08             	add    $0x8,%edx
80105fff:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106006:	00 
    fileclose(rf);
80106007:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010600a:	83 ec 0c             	sub    $0xc,%esp
8010600d:	50                   	push   %eax
8010600e:	e8 88 b0 ff ff       	call   8010109b <fileclose>
80106013:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106016:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106019:	83 ec 0c             	sub    $0xc,%esp
8010601c:	50                   	push   %eax
8010601d:	e8 79 b0 ff ff       	call   8010109b <fileclose>
80106022:	83 c4 10             	add    $0x10,%esp
    return -1;
80106025:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602a:	eb 18                	jmp    80106044 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
8010602c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010602f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106032:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106034:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106037:	8d 50 04             	lea    0x4(%eax),%edx
8010603a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603d:	89 02                	mov    %eax,(%edx)
  return 0;
8010603f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106044:	c9                   	leave  
80106045:	c3                   	ret    

80106046 <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
80106046:	55                   	push   %ebp
80106047:	89 e5                	mov    %esp,%ebp
80106049:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010604c:	e8 6f dd ff ff       	call   80103dc0 <fork>
}
80106051:	c9                   	leave  
80106052:	c3                   	ret    

80106053 <sys_exit>:

int
sys_exit(void)
{
80106053:	55                   	push   %ebp
80106054:	89 e5                	mov    %esp,%ebp
80106056:	83 ec 08             	sub    $0x8,%esp
  exit();
80106059:	e8 f8 de ff ff       	call   80103f56 <exit>
  return 0;  // not reached
8010605e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106063:	c9                   	leave  
80106064:	c3                   	ret    

80106065 <sys_wait>:

int
sys_wait(void)
{
80106065:	55                   	push   %ebp
80106066:	89 e5                	mov    %esp,%ebp
80106068:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010606b:	e8 09 e0 ff ff       	call   80104079 <wait>
}
80106070:	c9                   	leave  
80106071:	c3                   	ret    

80106072 <sys_kill>:

int
sys_kill(void)
{
80106072:	55                   	push   %ebp
80106073:	89 e5                	mov    %esp,%ebp
80106075:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106078:	83 ec 08             	sub    $0x8,%esp
8010607b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010607e:	50                   	push   %eax
8010607f:	6a 00                	push   $0x0
80106081:	e8 01 f1 ff ff       	call   80105187 <argint>
80106086:	83 c4 10             	add    $0x10,%esp
80106089:	85 c0                	test   %eax,%eax
8010608b:	79 07                	jns    80106094 <sys_kill+0x22>
    return -1;
8010608d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106092:	eb 0f                	jmp    801060a3 <sys_kill+0x31>
  return kill(pid);
80106094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106097:	83 ec 0c             	sub    $0xc,%esp
8010609a:	50                   	push   %eax
8010609b:	e8 e2 e5 ff ff       	call   80104682 <kill>
801060a0:	83 c4 10             	add    $0x10,%esp
}
801060a3:	c9                   	leave  
801060a4:	c3                   	ret    

801060a5 <sys_getpid>:

int
sys_getpid(void)
{
801060a5:	55                   	push   %ebp
801060a6:	89 e5                	mov    %esp,%ebp
801060a8:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801060ab:	e8 ae d9 ff ff       	call   80103a5e <myproc>
801060b0:	8b 40 10             	mov    0x10(%eax),%eax
}
801060b3:	c9                   	leave  
801060b4:	c3                   	ret    

801060b5 <sys_sbrk>:

int
sys_sbrk(void)
{
801060b5:	55                   	push   %ebp
801060b6:	89 e5                	mov    %esp,%ebp
801060b8:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801060bb:	83 ec 08             	sub    $0x8,%esp
801060be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060c1:	50                   	push   %eax
801060c2:	6a 00                	push   $0x0
801060c4:	e8 be f0 ff ff       	call   80105187 <argint>
801060c9:	83 c4 10             	add    $0x10,%esp
801060cc:	85 c0                	test   %eax,%eax
801060ce:	79 07                	jns    801060d7 <sys_sbrk+0x22>
    return -1;
801060d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d5:	eb 27                	jmp    801060fe <sys_sbrk+0x49>
  addr = myproc()->sz;
801060d7:	e8 82 d9 ff ff       	call   80103a5e <myproc>
801060dc:	8b 00                	mov    (%eax),%eax
801060de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801060e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e4:	83 ec 0c             	sub    $0xc,%esp
801060e7:	50                   	push   %eax
801060e8:	e8 38 dc ff ff       	call   80103d25 <growproc>
801060ed:	83 c4 10             	add    $0x10,%esp
801060f0:	85 c0                	test   %eax,%eax
801060f2:	79 07                	jns    801060fb <sys_sbrk+0x46>
    return -1;
801060f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f9:	eb 03                	jmp    801060fe <sys_sbrk+0x49>
  return addr;
801060fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060fe:	c9                   	leave  
801060ff:	c3                   	ret    

80106100 <sys_sleep>:

int
sys_sleep(void)
{
80106100:	55                   	push   %ebp
80106101:	89 e5                	mov    %esp,%ebp
80106103:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106106:	83 ec 08             	sub    $0x8,%esp
80106109:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010610c:	50                   	push   %eax
8010610d:	6a 00                	push   $0x0
8010610f:	e8 73 f0 ff ff       	call   80105187 <argint>
80106114:	83 c4 10             	add    $0x10,%esp
80106117:	85 c0                	test   %eax,%eax
80106119:	79 07                	jns    80106122 <sys_sleep+0x22>
    return -1;
8010611b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106120:	eb 76                	jmp    80106198 <sys_sleep+0x98>
  acquire(&tickslock);
80106122:	83 ec 0c             	sub    $0xc,%esp
80106125:	68 80 76 19 80       	push   $0x80197680
8010612a:	e8 b7 ea ff ff       	call   80104be6 <acquire>
8010612f:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106132:	a1 b4 76 19 80       	mov    0x801976b4,%eax
80106137:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010613a:	eb 38                	jmp    80106174 <sys_sleep+0x74>
    if(myproc()->killed){
8010613c:	e8 1d d9 ff ff       	call   80103a5e <myproc>
80106141:	8b 40 24             	mov    0x24(%eax),%eax
80106144:	85 c0                	test   %eax,%eax
80106146:	74 17                	je     8010615f <sys_sleep+0x5f>
      release(&tickslock);
80106148:	83 ec 0c             	sub    $0xc,%esp
8010614b:	68 80 76 19 80       	push   $0x80197680
80106150:	e8 ff ea ff ff       	call   80104c54 <release>
80106155:	83 c4 10             	add    $0x10,%esp
      return -1;
80106158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615d:	eb 39                	jmp    80106198 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010615f:	83 ec 08             	sub    $0x8,%esp
80106162:	68 80 76 19 80       	push   $0x80197680
80106167:	68 b4 76 19 80       	push   $0x801976b4
8010616c:	e8 f0 e3 ff ff       	call   80104561 <sleep>
80106171:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106174:	a1 b4 76 19 80       	mov    0x801976b4,%eax
80106179:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010617c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010617f:	39 d0                	cmp    %edx,%eax
80106181:	72 b9                	jb     8010613c <sys_sleep+0x3c>
  }
  release(&tickslock);
80106183:	83 ec 0c             	sub    $0xc,%esp
80106186:	68 80 76 19 80       	push   $0x80197680
8010618b:	e8 c4 ea ff ff       	call   80104c54 <release>
80106190:	83 c4 10             	add    $0x10,%esp
  return 0;
80106193:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106198:	c9                   	leave  
80106199:	c3                   	ret    

8010619a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010619a:	55                   	push   %ebp
8010619b:	89 e5                	mov    %esp,%ebp
8010619d:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801061a0:	83 ec 0c             	sub    $0xc,%esp
801061a3:	68 80 76 19 80       	push   $0x80197680
801061a8:	e8 39 ea ff ff       	call   80104be6 <acquire>
801061ad:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061b0:	a1 b4 76 19 80       	mov    0x801976b4,%eax
801061b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061b8:	83 ec 0c             	sub    $0xc,%esp
801061bb:	68 80 76 19 80       	push   $0x80197680
801061c0:	e8 8f ea ff ff       	call   80104c54 <release>
801061c5:	83 c4 10             	add    $0x10,%esp
  return xticks;
801061c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061cb:	c9                   	leave  
801061cc:	c3                   	ret    

801061cd <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
801061cd:	55                   	push   %ebp
801061ce:	89 e5                	mov    %esp,%ebp
801061d0:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
801061d3:	83 ec 08             	sub    $0x8,%esp
801061d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061d9:	50                   	push   %eax
801061da:	6a 00                	push   $0x0
801061dc:	e8 a6 ef ff ff       	call   80105187 <argint>
801061e1:	83 c4 10             	add    $0x10,%esp
801061e4:	85 c0                	test   %eax,%eax
801061e6:	79 07                	jns    801061ef <sys_setSchedPolicy+0x22>
    return -1;
801061e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ed:	eb 0f                	jmp    801061fe <sys_setSchedPolicy+0x31>
  return setSchedPolicy(policy);
801061ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f2:	83 ec 0c             	sub    $0xc,%esp
801061f5:	50                   	push   %eax
801061f6:	e8 0c e7 ff ff       	call   80104907 <setSchedPolicy>
801061fb:	83 c4 10             	add    $0x10,%esp
}
801061fe:	c9                   	leave  
801061ff:	c3                   	ret    

80106200 <sys_getpinfo>:



int
sys_getpinfo(void)
{
80106200:	55                   	push   %ebp
80106201:	89 e5                	mov    %esp,%ebp
80106203:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (void*)&ps, sizeof(*ps)) < 0 || ps ==0)
80106206:	83 ec 04             	sub    $0x4,%esp
80106209:	68 00 0c 00 00       	push   $0xc00
8010620e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106211:	50                   	push   %eax
80106212:	6a 00                	push   $0x0
80106214:	e8 9b ef ff ff       	call   801051b4 <argptr>
80106219:	83 c4 10             	add    $0x10,%esp
8010621c:	85 c0                	test   %eax,%eax
8010621e:	78 07                	js     80106227 <sys_getpinfo+0x27>
80106220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106223:	85 c0                	test   %eax,%eax
80106225:	75 07                	jne    8010622e <sys_getpinfo+0x2e>
    return -1;
80106227:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622c:	eb 0f                	jmp    8010623d <sys_getpinfo+0x3d>
  return getpinfo(ps);
8010622e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106231:	83 ec 0c             	sub    $0xc,%esp
80106234:	50                   	push   %eax
80106235:	e8 05 e7 ff ff       	call   8010493f <getpinfo>
8010623a:	83 c4 10             	add    $0x10,%esp
}
8010623d:	c9                   	leave  
8010623e:	c3                   	ret    

8010623f <sys_yield>:

int
sys_yield(void)
{
8010623f:	55                   	push   %ebp
80106240:	89 e5                	mov    %esp,%ebp
80106242:	83 ec 08             	sub    $0x8,%esp
  yield();
80106245:	e8 91 e2 ff ff       	call   801044db <yield>
  return 0;
8010624a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010624f:	c9                   	leave  
80106250:	c3                   	ret    

80106251 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106251:	1e                   	push   %ds
  pushl %es
80106252:	06                   	push   %es
  pushl %fs
80106253:	0f a0                	push   %fs
  pushl %gs
80106255:	0f a8                	push   %gs
  pushal
80106257:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106258:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010625c:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010625e:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106260:	54                   	push   %esp
  call trap
80106261:	e8 d7 01 00 00       	call   8010643d <trap>
  addl $4, %esp
80106266:	83 c4 04             	add    $0x4,%esp

80106269 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106269:	61                   	popa   
  popl %gs
8010626a:	0f a9                	pop    %gs
  popl %fs
8010626c:	0f a1                	pop    %fs
  popl %es
8010626e:	07                   	pop    %es
  popl %ds
8010626f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106270:	83 c4 08             	add    $0x8,%esp
  iret
80106273:	cf                   	iret   

80106274 <lidt>:
{
80106274:	55                   	push   %ebp
80106275:	89 e5                	mov    %esp,%ebp
80106277:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010627a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010627d:	83 e8 01             	sub    $0x1,%eax
80106280:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106284:	8b 45 08             	mov    0x8(%ebp),%eax
80106287:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010628b:	8b 45 08             	mov    0x8(%ebp),%eax
8010628e:	c1 e8 10             	shr    $0x10,%eax
80106291:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106295:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106298:	0f 01 18             	lidtl  (%eax)
}
8010629b:	90                   	nop
8010629c:	c9                   	leave  
8010629d:	c3                   	ret    

8010629e <rcr2>:

static inline uint
rcr2(void)
{
8010629e:	55                   	push   %ebp
8010629f:	89 e5                	mov    %esp,%ebp
801062a1:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801062a4:	0f 20 d0             	mov    %cr2,%eax
801062a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801062aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801062ad:	c9                   	leave  
801062ae:	c3                   	ret    

801062af <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801062af:	55                   	push   %ebp
801062b0:	89 e5                	mov    %esp,%ebp
801062b2:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801062b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062bc:	e9 c3 00 00 00       	jmp    80106384 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801062c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c4:	8b 04 85 a4 f0 10 80 	mov    -0x7fef0f5c(,%eax,4),%eax
801062cb:	89 c2                	mov    %eax,%edx
801062cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d0:	66 89 14 c5 80 6e 19 	mov    %dx,-0x7fe69180(,%eax,8)
801062d7:	80 
801062d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062db:	66 c7 04 c5 82 6e 19 	movw   $0x8,-0x7fe6917e(,%eax,8)
801062e2:	80 08 00 
801062e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e8:	0f b6 14 c5 84 6e 19 	movzbl -0x7fe6917c(,%eax,8),%edx
801062ef:	80 
801062f0:	83 e2 e0             	and    $0xffffffe0,%edx
801062f3:	88 14 c5 84 6e 19 80 	mov    %dl,-0x7fe6917c(,%eax,8)
801062fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062fd:	0f b6 14 c5 84 6e 19 	movzbl -0x7fe6917c(,%eax,8),%edx
80106304:	80 
80106305:	83 e2 1f             	and    $0x1f,%edx
80106308:	88 14 c5 84 6e 19 80 	mov    %dl,-0x7fe6917c(,%eax,8)
8010630f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106312:	0f b6 14 c5 85 6e 19 	movzbl -0x7fe6917b(,%eax,8),%edx
80106319:	80 
8010631a:	83 e2 f0             	and    $0xfffffff0,%edx
8010631d:	83 ca 0e             	or     $0xe,%edx
80106320:	88 14 c5 85 6e 19 80 	mov    %dl,-0x7fe6917b(,%eax,8)
80106327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632a:	0f b6 14 c5 85 6e 19 	movzbl -0x7fe6917b(,%eax,8),%edx
80106331:	80 
80106332:	83 e2 ef             	and    $0xffffffef,%edx
80106335:	88 14 c5 85 6e 19 80 	mov    %dl,-0x7fe6917b(,%eax,8)
8010633c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633f:	0f b6 14 c5 85 6e 19 	movzbl -0x7fe6917b(,%eax,8),%edx
80106346:	80 
80106347:	83 e2 9f             	and    $0xffffff9f,%edx
8010634a:	88 14 c5 85 6e 19 80 	mov    %dl,-0x7fe6917b(,%eax,8)
80106351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106354:	0f b6 14 c5 85 6e 19 	movzbl -0x7fe6917b(,%eax,8),%edx
8010635b:	80 
8010635c:	83 ca 80             	or     $0xffffff80,%edx
8010635f:	88 14 c5 85 6e 19 80 	mov    %dl,-0x7fe6917b(,%eax,8)
80106366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106369:	8b 04 85 a4 f0 10 80 	mov    -0x7fef0f5c(,%eax,4),%eax
80106370:	c1 e8 10             	shr    $0x10,%eax
80106373:	89 c2                	mov    %eax,%edx
80106375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106378:	66 89 14 c5 86 6e 19 	mov    %dx,-0x7fe6917a(,%eax,8)
8010637f:	80 
  for(i = 0; i < 256; i++)
80106380:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106384:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010638b:	0f 8e 30 ff ff ff    	jle    801062c1 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106391:	a1 a4 f1 10 80       	mov    0x8010f1a4,%eax
80106396:	66 a3 80 70 19 80    	mov    %ax,0x80197080
8010639c:	66 c7 05 82 70 19 80 	movw   $0x8,0x80197082
801063a3:	08 00 
801063a5:	0f b6 05 84 70 19 80 	movzbl 0x80197084,%eax
801063ac:	83 e0 e0             	and    $0xffffffe0,%eax
801063af:	a2 84 70 19 80       	mov    %al,0x80197084
801063b4:	0f b6 05 84 70 19 80 	movzbl 0x80197084,%eax
801063bb:	83 e0 1f             	and    $0x1f,%eax
801063be:	a2 84 70 19 80       	mov    %al,0x80197084
801063c3:	0f b6 05 85 70 19 80 	movzbl 0x80197085,%eax
801063ca:	83 c8 0f             	or     $0xf,%eax
801063cd:	a2 85 70 19 80       	mov    %al,0x80197085
801063d2:	0f b6 05 85 70 19 80 	movzbl 0x80197085,%eax
801063d9:	83 e0 ef             	and    $0xffffffef,%eax
801063dc:	a2 85 70 19 80       	mov    %al,0x80197085
801063e1:	0f b6 05 85 70 19 80 	movzbl 0x80197085,%eax
801063e8:	83 c8 60             	or     $0x60,%eax
801063eb:	a2 85 70 19 80       	mov    %al,0x80197085
801063f0:	0f b6 05 85 70 19 80 	movzbl 0x80197085,%eax
801063f7:	83 c8 80             	or     $0xffffff80,%eax
801063fa:	a2 85 70 19 80       	mov    %al,0x80197085
801063ff:	a1 a4 f1 10 80       	mov    0x8010f1a4,%eax
80106404:	c1 e8 10             	shr    $0x10,%eax
80106407:	66 a3 86 70 19 80    	mov    %ax,0x80197086

  initlock(&tickslock, "time");
8010640d:	83 ec 08             	sub    $0x8,%esp
80106410:	68 a8 ab 10 80       	push   $0x8010aba8
80106415:	68 80 76 19 80       	push   $0x80197680
8010641a:	e8 a5 e7 ff ff       	call   80104bc4 <initlock>
8010641f:	83 c4 10             	add    $0x10,%esp
}
80106422:	90                   	nop
80106423:	c9                   	leave  
80106424:	c3                   	ret    

80106425 <idtinit>:

void
idtinit(void)
{
80106425:	55                   	push   %ebp
80106426:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106428:	68 00 08 00 00       	push   $0x800
8010642d:	68 80 6e 19 80       	push   $0x80196e80
80106432:	e8 3d fe ff ff       	call   80106274 <lidt>
80106437:	83 c4 08             	add    $0x8,%esp
}
8010643a:	90                   	nop
8010643b:	c9                   	leave  
8010643c:	c3                   	ret    

8010643d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010643d:	55                   	push   %ebp
8010643e:	89 e5                	mov    %esp,%ebp
80106440:	57                   	push   %edi
80106441:	56                   	push   %esi
80106442:	53                   	push   %ebx
80106443:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106446:	8b 45 08             	mov    0x8(%ebp),%eax
80106449:	8b 40 30             	mov    0x30(%eax),%eax
8010644c:	83 f8 40             	cmp    $0x40,%eax
8010644f:	75 3b                	jne    8010648c <trap+0x4f>
    if(myproc()->killed)
80106451:	e8 08 d6 ff ff       	call   80103a5e <myproc>
80106456:	8b 40 24             	mov    0x24(%eax),%eax
80106459:	85 c0                	test   %eax,%eax
8010645b:	74 05                	je     80106462 <trap+0x25>
      exit();
8010645d:	e8 f4 da ff ff       	call   80103f56 <exit>
    myproc()->tf = tf;
80106462:	e8 f7 d5 ff ff       	call   80103a5e <myproc>
80106467:	8b 55 08             	mov    0x8(%ebp),%edx
8010646a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010646d:	e8 e1 ed ff ff       	call   80105253 <syscall>
    if(myproc()->killed)
80106472:	e8 e7 d5 ff ff       	call   80103a5e <myproc>
80106477:	8b 40 24             	mov    0x24(%eax),%eax
8010647a:	85 c0                	test   %eax,%eax
8010647c:	0f 84 32 04 00 00    	je     801068b4 <trap+0x477>
      exit();
80106482:	e8 cf da ff ff       	call   80103f56 <exit>
    return;
80106487:	e9 28 04 00 00       	jmp    801068b4 <trap+0x477>
  }

  switch(tf->trapno){
8010648c:	8b 45 08             	mov    0x8(%ebp),%eax
8010648f:	8b 40 30             	mov    0x30(%eax),%eax
80106492:	83 e8 20             	sub    $0x20,%eax
80106495:	83 f8 1f             	cmp    $0x1f,%eax
80106498:	0f 87 33 03 00 00    	ja     801067d1 <trap+0x394>
8010649e:	8b 04 85 b8 ac 10 80 	mov    -0x7fef5348(,%eax,4),%eax
801064a5:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801064a7:	e8 1f d5 ff ff       	call   801039cb <cpuid>
801064ac:	85 c0                	test   %eax,%eax
801064ae:	75 3d                	jne    801064ed <trap+0xb0>
      acquire(&tickslock);
801064b0:	83 ec 0c             	sub    $0xc,%esp
801064b3:	68 80 76 19 80       	push   $0x80197680
801064b8:	e8 29 e7 ff ff       	call   80104be6 <acquire>
801064bd:	83 c4 10             	add    $0x10,%esp
      ticks++;
801064c0:	a1 b4 76 19 80       	mov    0x801976b4,%eax
801064c5:	83 c0 01             	add    $0x1,%eax
801064c8:	a3 b4 76 19 80       	mov    %eax,0x801976b4
      wakeup(&ticks);
801064cd:	83 ec 0c             	sub    $0xc,%esp
801064d0:	68 b4 76 19 80       	push   $0x801976b4
801064d5:	e8 71 e1 ff ff       	call   8010464b <wakeup>
801064da:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801064dd:	83 ec 0c             	sub    $0xc,%esp
801064e0:	68 80 76 19 80       	push   $0x80197680
801064e5:	e8 6a e7 ff ff       	call   80104c54 <release>
801064ea:	83 c4 10             	add    $0x10,%esp
    }
    // 현재 실행 중인 프로세스의 tick 증가
    struct proc *curproc = myproc();
801064ed:	e8 6c d5 ff ff       	call   80103a5e <myproc>
801064f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    int sched = mycpu()->sched_policy;
801064f5:	e8 ec d4 ff ff       	call   801039e6 <mycpu>
801064fa:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106500:	89 45 d8             	mov    %eax,-0x28(%ebp)

    acquire(&ptable.lock);
80106503:	83 ec 0c             	sub    $0xc,%esp
80106506:	68 00 42 19 80       	push   $0x80194200
8010650b:	e8 d6 e6 ff ff       	call   80104be6 <acquire>
80106510:	83 c4 10             	add    $0x10,%esp

    if (sched == 1 && curproc && curproc->state == RUNNING) {
80106513:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
80106517:	0f 85 13 02 00 00    	jne    80106730 <trap+0x2f3>
8010651d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106521:	0f 84 09 02 00 00    	je     80106730 <trap+0x2f3>
80106527:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010652a:	8b 40 0c             	mov    0xc(%eax),%eax
8010652d:	83 f8 04             	cmp    $0x4,%eax
80106530:	0f 85 fa 01 00 00    	jne    80106730 <trap+0x2f3>
      int level = curproc->priority;
80106536:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106539:	8b 40 7c             	mov    0x7c(%eax),%eax
8010653c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      if (level >= 0 && level <= 3) {
8010653f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80106543:	78 45                	js     8010658a <trap+0x14d>
80106545:	83 7d d4 03          	cmpl   $0x3,-0x2c(%ebp)
80106549:	7f 3f                	jg     8010658a <trap+0x14d>
        curproc->ticks[level]++;
8010654b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010654e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106551:	83 c2 20             	add    $0x20,%edx
80106554:	8b 04 90             	mov    (%eax,%edx,4),%eax
80106557:	8d 48 01             	lea    0x1(%eax),%ecx
8010655a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010655d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106560:	83 c2 20             	add    $0x20,%edx
80106563:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
        cprintf("[tick] pid %d Q%d ticks: %d\n", curproc->pid, level, curproc->ticks[level]);
80106566:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106569:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010656c:	83 c2 20             	add    $0x20,%edx
8010656f:	8b 14 90             	mov    (%eax,%edx,4),%edx
80106572:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106575:	8b 40 10             	mov    0x10(%eax),%eax
80106578:	52                   	push   %edx
80106579:	ff 75 d4             	push   -0x2c(%ebp)
8010657c:	50                   	push   %eax
8010657d:	68 ad ab 10 80       	push   $0x8010abad
80106582:	e8 6d 9e ff ff       	call   801003f4 <cprintf>
80106587:	83 c4 10             	add    $0x10,%esp

      }
      //wait_ticks 증가
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010658a:	c7 45 e4 34 42 19 80 	movl   $0x80194234,-0x1c(%ebp)
80106591:	eb 4d                	jmp    801065e0 <trap+0x1a3>
        if ( p == curproc || p -> state == RUNNABLE){
80106593:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106596:	3b 45 dc             	cmp    -0x24(%ebp),%eax
80106599:	74 3d                	je     801065d8 <trap+0x19b>
8010659b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010659e:	8b 40 0c             	mov    0xc(%eax),%eax
801065a1:	83 f8 03             	cmp    $0x3,%eax
801065a4:	74 32                	je     801065d8 <trap+0x19b>
          continue;
        }
        int plevel = p->priority;
801065a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065a9:	8b 40 7c             	mov    0x7c(%eax),%eax
801065ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
        if (plevel >=0 && plevel <=3){
801065af:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801065b3:	78 24                	js     801065d9 <trap+0x19c>
801065b5:	83 7d cc 03          	cmpl   $0x3,-0x34(%ebp)
801065b9:	7f 1e                	jg     801065d9 <trap+0x19c>
            p->wait_ticks[level]++;
801065bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801065c1:	83 c2 24             	add    $0x24,%edx
801065c4:	8b 04 90             	mov    (%eax,%edx,4),%eax
801065c7:	8d 48 01             	lea    0x1(%eax),%ecx
801065ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801065d0:	83 c2 24             	add    $0x24,%edx
801065d3:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
801065d6:	eb 01                	jmp    801065d9 <trap+0x19c>
          continue;
801065d8:	90                   	nop
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801065d9:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
801065e0:	81 7d e4 34 6a 19 80 	cmpl   $0x80196a34,-0x1c(%ebp)
801065e7:	72 aa                	jb     80106593 <trap+0x156>
        }
      }
      //boost check
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801065e9:	c7 45 e0 34 42 19 80 	movl   $0x80194234,-0x20(%ebp)
801065f0:	e9 2e 01 00 00       	jmp    80106723 <trap+0x2e6>
        if (p->state != RUNNABLE)
801065f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801065f8:	8b 40 0c             	mov    0xc(%eax),%eax
801065fb:	83 f8 03             	cmp    $0x3,%eax
801065fe:	0f 85 17 01 00 00    	jne    8010671b <trap+0x2de>
          continue;
        int plevel = p->priority;
80106604:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106607:	8b 40 7c             	mov    0x7c(%eax),%eax
8010660a:	89 45 d0             	mov    %eax,-0x30(%ebp)

        if (plevel == 0 && p->wait_ticks[0] >= 500) {
8010660d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80106611:	75 56                	jne    80106669 <trap+0x22c>
80106613:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106616:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010661c:	3d f3 01 00 00       	cmp    $0x1f3,%eax
80106621:	7e 46                	jle    80106669 <trap+0x22c>
          p->priority = 1;
80106623:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106626:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
          p->wait_ticks[0] = 0;
8010662d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106630:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80106637:	00 00 00 
          enqueue(&mlfq[1], p);
8010663a:	83 ec 08             	sub    $0x8,%esp
8010663d:	ff 75 e0             	push   -0x20(%ebp)
80106640:	68 48 6b 19 80       	push   $0x80196b48
80106645:	e8 fe e0 ff ff       	call   80104748 <enqueue>
8010664a:	83 c4 10             	add    $0x10,%esp
          cprintf("[boost] pid %d: Q0→Q1\n", p->pid);
8010664d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106650:	8b 40 10             	mov    0x10(%eax),%eax
80106653:	83 ec 08             	sub    $0x8,%esp
80106656:	50                   	push   %eax
80106657:	68 ca ab 10 80       	push   $0x8010abca
8010665c:	e8 93 9d ff ff       	call   801003f4 <cprintf>
80106661:	83 c4 10             	add    $0x10,%esp
80106664:	e9 b3 00 00 00       	jmp    8010671c <trap+0x2df>
        } 
        else if (plevel == 1 && p->wait_ticks[1] >= 320) {
80106669:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
8010666d:	75 53                	jne    801066c2 <trap+0x285>
8010666f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106672:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106678:	3d 3f 01 00 00       	cmp    $0x13f,%eax
8010667d:	7e 43                	jle    801066c2 <trap+0x285>
          p->priority = 2;
8010667f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106682:	c7 40 7c 02 00 00 00 	movl   $0x2,0x7c(%eax)
          p->wait_ticks[1] = 0;
80106689:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010668c:	c7 80 94 00 00 00 00 	movl   $0x0,0x94(%eax)
80106693:	00 00 00 
          enqueue(&mlfq[2], p);
80106696:	83 ec 08             	sub    $0x8,%esp
80106699:	ff 75 e0             	push   -0x20(%ebp)
8010669c:	68 50 6c 19 80       	push   $0x80196c50
801066a1:	e8 a2 e0 ff ff       	call   80104748 <enqueue>
801066a6:	83 c4 10             	add    $0x10,%esp
          cprintf("[boost] pid %d: Q1→Q2\n", p->pid);
801066a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066ac:	8b 40 10             	mov    0x10(%eax),%eax
801066af:	83 ec 08             	sub    $0x8,%esp
801066b2:	50                   	push   %eax
801066b3:	68 e3 ab 10 80       	push   $0x8010abe3
801066b8:	e8 37 9d ff ff       	call   801003f4 <cprintf>
801066bd:	83 c4 10             	add    $0x10,%esp
801066c0:	eb 5a                	jmp    8010671c <trap+0x2df>
        } 
        else if (plevel == 2 && p->wait_ticks[2] >= 160) {
801066c2:	83 7d d0 02          	cmpl   $0x2,-0x30(%ebp)
801066c6:	75 54                	jne    8010671c <trap+0x2df>
801066c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066cb:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801066d1:	3d 9f 00 00 00       	cmp    $0x9f,%eax
801066d6:	7e 44                	jle    8010671c <trap+0x2df>
          p->priority = 3;
801066d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066db:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
          p->wait_ticks[2] = 0;
801066e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066e5:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
801066ec:	00 00 00 
          enqueue(&mlfq[3], p);
801066ef:	83 ec 08             	sub    $0x8,%esp
801066f2:	ff 75 e0             	push   -0x20(%ebp)
801066f5:	68 58 6d 19 80       	push   $0x80196d58
801066fa:	e8 49 e0 ff ff       	call   80104748 <enqueue>
801066ff:	83 c4 10             	add    $0x10,%esp
          cprintf("[boost] pid %d: Q2→Q3\n", p->pid);
80106702:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106705:	8b 40 10             	mov    0x10(%eax),%eax
80106708:	83 ec 08             	sub    $0x8,%esp
8010670b:	50                   	push   %eax
8010670c:	68 fc ab 10 80       	push   $0x8010abfc
80106711:	e8 de 9c ff ff       	call   801003f4 <cprintf>
80106716:	83 c4 10             	add    $0x10,%esp
80106719:	eb 01                	jmp    8010671c <trap+0x2df>
          continue;
8010671b:	90                   	nop
      for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010671c:	81 45 e0 a0 00 00 00 	addl   $0xa0,-0x20(%ebp)
80106723:	81 7d e0 34 6a 19 80 	cmpl   $0x80196a34,-0x20(%ebp)
8010672a:	0f 82 c5 fe ff ff    	jb     801065f5 <trap+0x1b8>

        }
      }
    }
        
    release(&ptable.lock);
80106730:	83 ec 0c             	sub    $0xc,%esp
80106733:	68 00 42 19 80       	push   $0x80194200
80106738:	e8 17 e5 ff ff       	call   80104c54 <release>
8010673d:	83 c4 10             	add    $0x10,%esp
  
    if (sched == 1 && curproc && curproc->state == RUNNING)
80106740:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
80106744:	75 16                	jne    8010675c <trap+0x31f>
80106746:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010674a:	74 10                	je     8010675c <trap+0x31f>
8010674c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010674f:	8b 40 0c             	mov    0xc(%eax),%eax
80106752:	83 f8 04             	cmp    $0x4,%eax
80106755:	75 05                	jne    8010675c <trap+0x31f>
      yield();  // ✅ MLFQ일 때만 yield
80106757:	e8 7f dd ff ff       	call   801044db <yield>
    
    lapiceoi();
8010675c:	e8 bb c3 ff ff       	call   80102b1c <lapiceoi>
    break;
80106761:	e9 20 01 00 00       	jmp    80106886 <trap+0x449>

  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106766:	e8 a3 3e 00 00       	call   8010a60e <ideintr>
    lapiceoi();
8010676b:	e8 ac c3 ff ff       	call   80102b1c <lapiceoi>
    break;
80106770:	e9 11 01 00 00       	jmp    80106886 <trap+0x449>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106775:	e8 e7 c1 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
8010677a:	e8 9d c3 ff ff       	call   80102b1c <lapiceoi>
    break;
8010677f:	e9 02 01 00 00       	jmp    80106886 <trap+0x449>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106784:	e8 01 03 00 00       	call   80106a8a <uartintr>
    lapiceoi();
80106789:	e8 8e c3 ff ff       	call   80102b1c <lapiceoi>
    break;
8010678e:	e9 f3 00 00 00       	jmp    80106886 <trap+0x449>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106793:	e8 29 2b 00 00       	call   801092c1 <i8254_intr>
    lapiceoi();
80106798:	e8 7f c3 ff ff       	call   80102b1c <lapiceoi>
    break;
8010679d:	e9 e4 00 00 00       	jmp    80106886 <trap+0x449>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067a2:	8b 45 08             	mov    0x8(%ebp),%eax
801067a5:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801067a8:	8b 45 08             	mov    0x8(%ebp),%eax
801067ab:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067af:	0f b7 d8             	movzwl %ax,%ebx
801067b2:	e8 14 d2 ff ff       	call   801039cb <cpuid>
801067b7:	56                   	push   %esi
801067b8:	53                   	push   %ebx
801067b9:	50                   	push   %eax
801067ba:	68 18 ac 10 80       	push   $0x8010ac18
801067bf:	e8 30 9c ff ff       	call   801003f4 <cprintf>
801067c4:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801067c7:	e8 50 c3 ff ff       	call   80102b1c <lapiceoi>
    break;
801067cc:	e9 b5 00 00 00       	jmp    80106886 <trap+0x449>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801067d1:	e8 88 d2 ff ff       	call   80103a5e <myproc>
801067d6:	85 c0                	test   %eax,%eax
801067d8:	74 11                	je     801067eb <trap+0x3ae>
801067da:	8b 45 08             	mov    0x8(%ebp),%eax
801067dd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067e1:	0f b7 c0             	movzwl %ax,%eax
801067e4:	83 e0 03             	and    $0x3,%eax
801067e7:	85 c0                	test   %eax,%eax
801067e9:	75 39                	jne    80106824 <trap+0x3e7>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801067eb:	e8 ae fa ff ff       	call   8010629e <rcr2>
801067f0:	89 c3                	mov    %eax,%ebx
801067f2:	8b 45 08             	mov    0x8(%ebp),%eax
801067f5:	8b 70 38             	mov    0x38(%eax),%esi
801067f8:	e8 ce d1 ff ff       	call   801039cb <cpuid>
801067fd:	8b 55 08             	mov    0x8(%ebp),%edx
80106800:	8b 52 30             	mov    0x30(%edx),%edx
80106803:	83 ec 0c             	sub    $0xc,%esp
80106806:	53                   	push   %ebx
80106807:	56                   	push   %esi
80106808:	50                   	push   %eax
80106809:	52                   	push   %edx
8010680a:	68 3c ac 10 80       	push   $0x8010ac3c
8010680f:	e8 e0 9b ff ff       	call   801003f4 <cprintf>
80106814:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106817:	83 ec 0c             	sub    $0xc,%esp
8010681a:	68 6e ac 10 80       	push   $0x8010ac6e
8010681f:	e8 85 9d ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106824:	e8 75 fa ff ff       	call   8010629e <rcr2>
80106829:	89 c6                	mov    %eax,%esi
8010682b:	8b 45 08             	mov    0x8(%ebp),%eax
8010682e:	8b 40 38             	mov    0x38(%eax),%eax
80106831:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80106834:	e8 92 d1 ff ff       	call   801039cb <cpuid>
80106839:	89 c3                	mov    %eax,%ebx
8010683b:	8b 45 08             	mov    0x8(%ebp),%eax
8010683e:	8b 78 34             	mov    0x34(%eax),%edi
80106841:	89 7d c0             	mov    %edi,-0x40(%ebp)
80106844:	8b 45 08             	mov    0x8(%ebp),%eax
80106847:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010684a:	e8 0f d2 ff ff       	call   80103a5e <myproc>
8010684f:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106852:	89 4d bc             	mov    %ecx,-0x44(%ebp)
80106855:	e8 04 d2 ff ff       	call   80103a5e <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010685a:	8b 40 10             	mov    0x10(%eax),%eax
8010685d:	56                   	push   %esi
8010685e:	ff 75 c4             	push   -0x3c(%ebp)
80106861:	53                   	push   %ebx
80106862:	ff 75 c0             	push   -0x40(%ebp)
80106865:	57                   	push   %edi
80106866:	ff 75 bc             	push   -0x44(%ebp)
80106869:	50                   	push   %eax
8010686a:	68 74 ac 10 80       	push   $0x8010ac74
8010686f:	e8 80 9b ff ff       	call   801003f4 <cprintf>
80106874:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106877:	e8 e2 d1 ff ff       	call   80103a5e <myproc>
8010687c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106883:	eb 01                	jmp    80106886 <trap+0x449>
    break;
80106885:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106886:	e8 d3 d1 ff ff       	call   80103a5e <myproc>
8010688b:	85 c0                	test   %eax,%eax
8010688d:	74 26                	je     801068b5 <trap+0x478>
8010688f:	e8 ca d1 ff ff       	call   80103a5e <myproc>
80106894:	8b 40 24             	mov    0x24(%eax),%eax
80106897:	85 c0                	test   %eax,%eax
80106899:	74 1a                	je     801068b5 <trap+0x478>
8010689b:	8b 45 08             	mov    0x8(%ebp),%eax
8010689e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068a2:	0f b7 c0             	movzwl %ax,%eax
801068a5:	83 e0 03             	and    $0x3,%eax
801068a8:	83 f8 03             	cmp    $0x3,%eax
801068ab:	75 08                	jne    801068b5 <trap+0x478>
    exit();
801068ad:	e8 a4 d6 ff ff       	call   80103f56 <exit>
801068b2:	eb 01                	jmp    801068b5 <trap+0x478>
    return;
801068b4:	90                   	nop
     yield();*/

  // Check if the process has been killed since we yielded
  /*if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();*/
}
801068b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068b8:	5b                   	pop    %ebx
801068b9:	5e                   	pop    %esi
801068ba:	5f                   	pop    %edi
801068bb:	5d                   	pop    %ebp
801068bc:	c3                   	ret    

801068bd <inb>:
{
801068bd:	55                   	push   %ebp
801068be:	89 e5                	mov    %esp,%ebp
801068c0:	83 ec 14             	sub    $0x14,%esp
801068c3:	8b 45 08             	mov    0x8(%ebp),%eax
801068c6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801068ca:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801068ce:	89 c2                	mov    %eax,%edx
801068d0:	ec                   	in     (%dx),%al
801068d1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801068d4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801068d8:	c9                   	leave  
801068d9:	c3                   	ret    

801068da <outb>:
{
801068da:	55                   	push   %ebp
801068db:	89 e5                	mov    %esp,%ebp
801068dd:	83 ec 08             	sub    $0x8,%esp
801068e0:	8b 45 08             	mov    0x8(%ebp),%eax
801068e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801068e6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801068ea:	89 d0                	mov    %edx,%eax
801068ec:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068ef:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068f3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068f7:	ee                   	out    %al,(%dx)
}
801068f8:	90                   	nop
801068f9:	c9                   	leave  
801068fa:	c3                   	ret    

801068fb <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801068fb:	55                   	push   %ebp
801068fc:	89 e5                	mov    %esp,%ebp
801068fe:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106901:	6a 00                	push   $0x0
80106903:	68 fa 03 00 00       	push   $0x3fa
80106908:	e8 cd ff ff ff       	call   801068da <outb>
8010690d:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106910:	68 80 00 00 00       	push   $0x80
80106915:	68 fb 03 00 00       	push   $0x3fb
8010691a:	e8 bb ff ff ff       	call   801068da <outb>
8010691f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106922:	6a 0c                	push   $0xc
80106924:	68 f8 03 00 00       	push   $0x3f8
80106929:	e8 ac ff ff ff       	call   801068da <outb>
8010692e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106931:	6a 00                	push   $0x0
80106933:	68 f9 03 00 00       	push   $0x3f9
80106938:	e8 9d ff ff ff       	call   801068da <outb>
8010693d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106940:	6a 03                	push   $0x3
80106942:	68 fb 03 00 00       	push   $0x3fb
80106947:	e8 8e ff ff ff       	call   801068da <outb>
8010694c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010694f:	6a 00                	push   $0x0
80106951:	68 fc 03 00 00       	push   $0x3fc
80106956:	e8 7f ff ff ff       	call   801068da <outb>
8010695b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010695e:	6a 01                	push   $0x1
80106960:	68 f9 03 00 00       	push   $0x3f9
80106965:	e8 70 ff ff ff       	call   801068da <outb>
8010696a:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010696d:	68 fd 03 00 00       	push   $0x3fd
80106972:	e8 46 ff ff ff       	call   801068bd <inb>
80106977:	83 c4 04             	add    $0x4,%esp
8010697a:	3c ff                	cmp    $0xff,%al
8010697c:	74 61                	je     801069df <uartinit+0xe4>
    return;
  uart = 1;
8010697e:	c7 05 b8 76 19 80 01 	movl   $0x1,0x801976b8
80106985:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106988:	68 fa 03 00 00       	push   $0x3fa
8010698d:	e8 2b ff ff ff       	call   801068bd <inb>
80106992:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106995:	68 f8 03 00 00       	push   $0x3f8
8010699a:	e8 1e ff ff ff       	call   801068bd <inb>
8010699f:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801069a2:	83 ec 08             	sub    $0x8,%esp
801069a5:	6a 00                	push   $0x0
801069a7:	6a 04                	push   $0x4
801069a9:	e8 80 bc ff ff       	call   8010262e <ioapicenable>
801069ae:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069b1:	c7 45 f4 38 ad 10 80 	movl   $0x8010ad38,-0xc(%ebp)
801069b8:	eb 19                	jmp    801069d3 <uartinit+0xd8>
    uartputc(*p);
801069ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069bd:	0f b6 00             	movzbl (%eax),%eax
801069c0:	0f be c0             	movsbl %al,%eax
801069c3:	83 ec 0c             	sub    $0xc,%esp
801069c6:	50                   	push   %eax
801069c7:	e8 16 00 00 00       	call   801069e2 <uartputc>
801069cc:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801069cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d6:	0f b6 00             	movzbl (%eax),%eax
801069d9:	84 c0                	test   %al,%al
801069db:	75 dd                	jne    801069ba <uartinit+0xbf>
801069dd:	eb 01                	jmp    801069e0 <uartinit+0xe5>
    return;
801069df:	90                   	nop
}
801069e0:	c9                   	leave  
801069e1:	c3                   	ret    

801069e2 <uartputc>:

void
uartputc(int c)
{
801069e2:	55                   	push   %ebp
801069e3:	89 e5                	mov    %esp,%ebp
801069e5:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801069e8:	a1 b8 76 19 80       	mov    0x801976b8,%eax
801069ed:	85 c0                	test   %eax,%eax
801069ef:	74 53                	je     80106a44 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801069f8:	eb 11                	jmp    80106a0b <uartputc+0x29>
    microdelay(10);
801069fa:	83 ec 0c             	sub    $0xc,%esp
801069fd:	6a 0a                	push   $0xa
801069ff:	e8 33 c1 ff ff       	call   80102b37 <microdelay>
80106a04:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a07:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a0b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a0f:	7f 1a                	jg     80106a2b <uartputc+0x49>
80106a11:	83 ec 0c             	sub    $0xc,%esp
80106a14:	68 fd 03 00 00       	push   $0x3fd
80106a19:	e8 9f fe ff ff       	call   801068bd <inb>
80106a1e:	83 c4 10             	add    $0x10,%esp
80106a21:	0f b6 c0             	movzbl %al,%eax
80106a24:	83 e0 20             	and    $0x20,%eax
80106a27:	85 c0                	test   %eax,%eax
80106a29:	74 cf                	je     801069fa <uartputc+0x18>
  outb(COM1+0, c);
80106a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a2e:	0f b6 c0             	movzbl %al,%eax
80106a31:	83 ec 08             	sub    $0x8,%esp
80106a34:	50                   	push   %eax
80106a35:	68 f8 03 00 00       	push   $0x3f8
80106a3a:	e8 9b fe ff ff       	call   801068da <outb>
80106a3f:	83 c4 10             	add    $0x10,%esp
80106a42:	eb 01                	jmp    80106a45 <uartputc+0x63>
    return;
80106a44:	90                   	nop
}
80106a45:	c9                   	leave  
80106a46:	c3                   	ret    

80106a47 <uartgetc>:

static int
uartgetc(void)
{
80106a47:	55                   	push   %ebp
80106a48:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106a4a:	a1 b8 76 19 80       	mov    0x801976b8,%eax
80106a4f:	85 c0                	test   %eax,%eax
80106a51:	75 07                	jne    80106a5a <uartgetc+0x13>
    return -1;
80106a53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a58:	eb 2e                	jmp    80106a88 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106a5a:	68 fd 03 00 00       	push   $0x3fd
80106a5f:	e8 59 fe ff ff       	call   801068bd <inb>
80106a64:	83 c4 04             	add    $0x4,%esp
80106a67:	0f b6 c0             	movzbl %al,%eax
80106a6a:	83 e0 01             	and    $0x1,%eax
80106a6d:	85 c0                	test   %eax,%eax
80106a6f:	75 07                	jne    80106a78 <uartgetc+0x31>
    return -1;
80106a71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a76:	eb 10                	jmp    80106a88 <uartgetc+0x41>
  return inb(COM1+0);
80106a78:	68 f8 03 00 00       	push   $0x3f8
80106a7d:	e8 3b fe ff ff       	call   801068bd <inb>
80106a82:	83 c4 04             	add    $0x4,%esp
80106a85:	0f b6 c0             	movzbl %al,%eax
}
80106a88:	c9                   	leave  
80106a89:	c3                   	ret    

80106a8a <uartintr>:

void
uartintr(void)
{
80106a8a:	55                   	push   %ebp
80106a8b:	89 e5                	mov    %esp,%ebp
80106a8d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106a90:	83 ec 0c             	sub    $0xc,%esp
80106a93:	68 47 6a 10 80       	push   $0x80106a47
80106a98:	e8 39 9d ff ff       	call   801007d6 <consoleintr>
80106a9d:	83 c4 10             	add    $0x10,%esp
}
80106aa0:	90                   	nop
80106aa1:	c9                   	leave  
80106aa2:	c3                   	ret    

80106aa3 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106aa3:	6a 00                	push   $0x0
  pushl $0
80106aa5:	6a 00                	push   $0x0
  jmp alltraps
80106aa7:	e9 a5 f7 ff ff       	jmp    80106251 <alltraps>

80106aac <vector1>:
.globl vector1
vector1:
  pushl $0
80106aac:	6a 00                	push   $0x0
  pushl $1
80106aae:	6a 01                	push   $0x1
  jmp alltraps
80106ab0:	e9 9c f7 ff ff       	jmp    80106251 <alltraps>

80106ab5 <vector2>:
.globl vector2
vector2:
  pushl $0
80106ab5:	6a 00                	push   $0x0
  pushl $2
80106ab7:	6a 02                	push   $0x2
  jmp alltraps
80106ab9:	e9 93 f7 ff ff       	jmp    80106251 <alltraps>

80106abe <vector3>:
.globl vector3
vector3:
  pushl $0
80106abe:	6a 00                	push   $0x0
  pushl $3
80106ac0:	6a 03                	push   $0x3
  jmp alltraps
80106ac2:	e9 8a f7 ff ff       	jmp    80106251 <alltraps>

80106ac7 <vector4>:
.globl vector4
vector4:
  pushl $0
80106ac7:	6a 00                	push   $0x0
  pushl $4
80106ac9:	6a 04                	push   $0x4
  jmp alltraps
80106acb:	e9 81 f7 ff ff       	jmp    80106251 <alltraps>

80106ad0 <vector5>:
.globl vector5
vector5:
  pushl $0
80106ad0:	6a 00                	push   $0x0
  pushl $5
80106ad2:	6a 05                	push   $0x5
  jmp alltraps
80106ad4:	e9 78 f7 ff ff       	jmp    80106251 <alltraps>

80106ad9 <vector6>:
.globl vector6
vector6:
  pushl $0
80106ad9:	6a 00                	push   $0x0
  pushl $6
80106adb:	6a 06                	push   $0x6
  jmp alltraps
80106add:	e9 6f f7 ff ff       	jmp    80106251 <alltraps>

80106ae2 <vector7>:
.globl vector7
vector7:
  pushl $0
80106ae2:	6a 00                	push   $0x0
  pushl $7
80106ae4:	6a 07                	push   $0x7
  jmp alltraps
80106ae6:	e9 66 f7 ff ff       	jmp    80106251 <alltraps>

80106aeb <vector8>:
.globl vector8
vector8:
  pushl $8
80106aeb:	6a 08                	push   $0x8
  jmp alltraps
80106aed:	e9 5f f7 ff ff       	jmp    80106251 <alltraps>

80106af2 <vector9>:
.globl vector9
vector9:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $9
80106af4:	6a 09                	push   $0x9
  jmp alltraps
80106af6:	e9 56 f7 ff ff       	jmp    80106251 <alltraps>

80106afb <vector10>:
.globl vector10
vector10:
  pushl $10
80106afb:	6a 0a                	push   $0xa
  jmp alltraps
80106afd:	e9 4f f7 ff ff       	jmp    80106251 <alltraps>

80106b02 <vector11>:
.globl vector11
vector11:
  pushl $11
80106b02:	6a 0b                	push   $0xb
  jmp alltraps
80106b04:	e9 48 f7 ff ff       	jmp    80106251 <alltraps>

80106b09 <vector12>:
.globl vector12
vector12:
  pushl $12
80106b09:	6a 0c                	push   $0xc
  jmp alltraps
80106b0b:	e9 41 f7 ff ff       	jmp    80106251 <alltraps>

80106b10 <vector13>:
.globl vector13
vector13:
  pushl $13
80106b10:	6a 0d                	push   $0xd
  jmp alltraps
80106b12:	e9 3a f7 ff ff       	jmp    80106251 <alltraps>

80106b17 <vector14>:
.globl vector14
vector14:
  pushl $14
80106b17:	6a 0e                	push   $0xe
  jmp alltraps
80106b19:	e9 33 f7 ff ff       	jmp    80106251 <alltraps>

80106b1e <vector15>:
.globl vector15
vector15:
  pushl $0
80106b1e:	6a 00                	push   $0x0
  pushl $15
80106b20:	6a 0f                	push   $0xf
  jmp alltraps
80106b22:	e9 2a f7 ff ff       	jmp    80106251 <alltraps>

80106b27 <vector16>:
.globl vector16
vector16:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $16
80106b29:	6a 10                	push   $0x10
  jmp alltraps
80106b2b:	e9 21 f7 ff ff       	jmp    80106251 <alltraps>

80106b30 <vector17>:
.globl vector17
vector17:
  pushl $17
80106b30:	6a 11                	push   $0x11
  jmp alltraps
80106b32:	e9 1a f7 ff ff       	jmp    80106251 <alltraps>

80106b37 <vector18>:
.globl vector18
vector18:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $18
80106b39:	6a 12                	push   $0x12
  jmp alltraps
80106b3b:	e9 11 f7 ff ff       	jmp    80106251 <alltraps>

80106b40 <vector19>:
.globl vector19
vector19:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $19
80106b42:	6a 13                	push   $0x13
  jmp alltraps
80106b44:	e9 08 f7 ff ff       	jmp    80106251 <alltraps>

80106b49 <vector20>:
.globl vector20
vector20:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $20
80106b4b:	6a 14                	push   $0x14
  jmp alltraps
80106b4d:	e9 ff f6 ff ff       	jmp    80106251 <alltraps>

80106b52 <vector21>:
.globl vector21
vector21:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $21
80106b54:	6a 15                	push   $0x15
  jmp alltraps
80106b56:	e9 f6 f6 ff ff       	jmp    80106251 <alltraps>

80106b5b <vector22>:
.globl vector22
vector22:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $22
80106b5d:	6a 16                	push   $0x16
  jmp alltraps
80106b5f:	e9 ed f6 ff ff       	jmp    80106251 <alltraps>

80106b64 <vector23>:
.globl vector23
vector23:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $23
80106b66:	6a 17                	push   $0x17
  jmp alltraps
80106b68:	e9 e4 f6 ff ff       	jmp    80106251 <alltraps>

80106b6d <vector24>:
.globl vector24
vector24:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $24
80106b6f:	6a 18                	push   $0x18
  jmp alltraps
80106b71:	e9 db f6 ff ff       	jmp    80106251 <alltraps>

80106b76 <vector25>:
.globl vector25
vector25:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $25
80106b78:	6a 19                	push   $0x19
  jmp alltraps
80106b7a:	e9 d2 f6 ff ff       	jmp    80106251 <alltraps>

80106b7f <vector26>:
.globl vector26
vector26:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $26
80106b81:	6a 1a                	push   $0x1a
  jmp alltraps
80106b83:	e9 c9 f6 ff ff       	jmp    80106251 <alltraps>

80106b88 <vector27>:
.globl vector27
vector27:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $27
80106b8a:	6a 1b                	push   $0x1b
  jmp alltraps
80106b8c:	e9 c0 f6 ff ff       	jmp    80106251 <alltraps>

80106b91 <vector28>:
.globl vector28
vector28:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $28
80106b93:	6a 1c                	push   $0x1c
  jmp alltraps
80106b95:	e9 b7 f6 ff ff       	jmp    80106251 <alltraps>

80106b9a <vector29>:
.globl vector29
vector29:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $29
80106b9c:	6a 1d                	push   $0x1d
  jmp alltraps
80106b9e:	e9 ae f6 ff ff       	jmp    80106251 <alltraps>

80106ba3 <vector30>:
.globl vector30
vector30:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $30
80106ba5:	6a 1e                	push   $0x1e
  jmp alltraps
80106ba7:	e9 a5 f6 ff ff       	jmp    80106251 <alltraps>

80106bac <vector31>:
.globl vector31
vector31:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $31
80106bae:	6a 1f                	push   $0x1f
  jmp alltraps
80106bb0:	e9 9c f6 ff ff       	jmp    80106251 <alltraps>

80106bb5 <vector32>:
.globl vector32
vector32:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $32
80106bb7:	6a 20                	push   $0x20
  jmp alltraps
80106bb9:	e9 93 f6 ff ff       	jmp    80106251 <alltraps>

80106bbe <vector33>:
.globl vector33
vector33:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $33
80106bc0:	6a 21                	push   $0x21
  jmp alltraps
80106bc2:	e9 8a f6 ff ff       	jmp    80106251 <alltraps>

80106bc7 <vector34>:
.globl vector34
vector34:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $34
80106bc9:	6a 22                	push   $0x22
  jmp alltraps
80106bcb:	e9 81 f6 ff ff       	jmp    80106251 <alltraps>

80106bd0 <vector35>:
.globl vector35
vector35:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $35
80106bd2:	6a 23                	push   $0x23
  jmp alltraps
80106bd4:	e9 78 f6 ff ff       	jmp    80106251 <alltraps>

80106bd9 <vector36>:
.globl vector36
vector36:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $36
80106bdb:	6a 24                	push   $0x24
  jmp alltraps
80106bdd:	e9 6f f6 ff ff       	jmp    80106251 <alltraps>

80106be2 <vector37>:
.globl vector37
vector37:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $37
80106be4:	6a 25                	push   $0x25
  jmp alltraps
80106be6:	e9 66 f6 ff ff       	jmp    80106251 <alltraps>

80106beb <vector38>:
.globl vector38
vector38:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $38
80106bed:	6a 26                	push   $0x26
  jmp alltraps
80106bef:	e9 5d f6 ff ff       	jmp    80106251 <alltraps>

80106bf4 <vector39>:
.globl vector39
vector39:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $39
80106bf6:	6a 27                	push   $0x27
  jmp alltraps
80106bf8:	e9 54 f6 ff ff       	jmp    80106251 <alltraps>

80106bfd <vector40>:
.globl vector40
vector40:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $40
80106bff:	6a 28                	push   $0x28
  jmp alltraps
80106c01:	e9 4b f6 ff ff       	jmp    80106251 <alltraps>

80106c06 <vector41>:
.globl vector41
vector41:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $41
80106c08:	6a 29                	push   $0x29
  jmp alltraps
80106c0a:	e9 42 f6 ff ff       	jmp    80106251 <alltraps>

80106c0f <vector42>:
.globl vector42
vector42:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $42
80106c11:	6a 2a                	push   $0x2a
  jmp alltraps
80106c13:	e9 39 f6 ff ff       	jmp    80106251 <alltraps>

80106c18 <vector43>:
.globl vector43
vector43:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $43
80106c1a:	6a 2b                	push   $0x2b
  jmp alltraps
80106c1c:	e9 30 f6 ff ff       	jmp    80106251 <alltraps>

80106c21 <vector44>:
.globl vector44
vector44:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $44
80106c23:	6a 2c                	push   $0x2c
  jmp alltraps
80106c25:	e9 27 f6 ff ff       	jmp    80106251 <alltraps>

80106c2a <vector45>:
.globl vector45
vector45:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $45
80106c2c:	6a 2d                	push   $0x2d
  jmp alltraps
80106c2e:	e9 1e f6 ff ff       	jmp    80106251 <alltraps>

80106c33 <vector46>:
.globl vector46
vector46:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $46
80106c35:	6a 2e                	push   $0x2e
  jmp alltraps
80106c37:	e9 15 f6 ff ff       	jmp    80106251 <alltraps>

80106c3c <vector47>:
.globl vector47
vector47:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $47
80106c3e:	6a 2f                	push   $0x2f
  jmp alltraps
80106c40:	e9 0c f6 ff ff       	jmp    80106251 <alltraps>

80106c45 <vector48>:
.globl vector48
vector48:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $48
80106c47:	6a 30                	push   $0x30
  jmp alltraps
80106c49:	e9 03 f6 ff ff       	jmp    80106251 <alltraps>

80106c4e <vector49>:
.globl vector49
vector49:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $49
80106c50:	6a 31                	push   $0x31
  jmp alltraps
80106c52:	e9 fa f5 ff ff       	jmp    80106251 <alltraps>

80106c57 <vector50>:
.globl vector50
vector50:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $50
80106c59:	6a 32                	push   $0x32
  jmp alltraps
80106c5b:	e9 f1 f5 ff ff       	jmp    80106251 <alltraps>

80106c60 <vector51>:
.globl vector51
vector51:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $51
80106c62:	6a 33                	push   $0x33
  jmp alltraps
80106c64:	e9 e8 f5 ff ff       	jmp    80106251 <alltraps>

80106c69 <vector52>:
.globl vector52
vector52:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $52
80106c6b:	6a 34                	push   $0x34
  jmp alltraps
80106c6d:	e9 df f5 ff ff       	jmp    80106251 <alltraps>

80106c72 <vector53>:
.globl vector53
vector53:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $53
80106c74:	6a 35                	push   $0x35
  jmp alltraps
80106c76:	e9 d6 f5 ff ff       	jmp    80106251 <alltraps>

80106c7b <vector54>:
.globl vector54
vector54:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $54
80106c7d:	6a 36                	push   $0x36
  jmp alltraps
80106c7f:	e9 cd f5 ff ff       	jmp    80106251 <alltraps>

80106c84 <vector55>:
.globl vector55
vector55:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $55
80106c86:	6a 37                	push   $0x37
  jmp alltraps
80106c88:	e9 c4 f5 ff ff       	jmp    80106251 <alltraps>

80106c8d <vector56>:
.globl vector56
vector56:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $56
80106c8f:	6a 38                	push   $0x38
  jmp alltraps
80106c91:	e9 bb f5 ff ff       	jmp    80106251 <alltraps>

80106c96 <vector57>:
.globl vector57
vector57:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $57
80106c98:	6a 39                	push   $0x39
  jmp alltraps
80106c9a:	e9 b2 f5 ff ff       	jmp    80106251 <alltraps>

80106c9f <vector58>:
.globl vector58
vector58:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $58
80106ca1:	6a 3a                	push   $0x3a
  jmp alltraps
80106ca3:	e9 a9 f5 ff ff       	jmp    80106251 <alltraps>

80106ca8 <vector59>:
.globl vector59
vector59:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $59
80106caa:	6a 3b                	push   $0x3b
  jmp alltraps
80106cac:	e9 a0 f5 ff ff       	jmp    80106251 <alltraps>

80106cb1 <vector60>:
.globl vector60
vector60:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $60
80106cb3:	6a 3c                	push   $0x3c
  jmp alltraps
80106cb5:	e9 97 f5 ff ff       	jmp    80106251 <alltraps>

80106cba <vector61>:
.globl vector61
vector61:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $61
80106cbc:	6a 3d                	push   $0x3d
  jmp alltraps
80106cbe:	e9 8e f5 ff ff       	jmp    80106251 <alltraps>

80106cc3 <vector62>:
.globl vector62
vector62:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $62
80106cc5:	6a 3e                	push   $0x3e
  jmp alltraps
80106cc7:	e9 85 f5 ff ff       	jmp    80106251 <alltraps>

80106ccc <vector63>:
.globl vector63
vector63:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $63
80106cce:	6a 3f                	push   $0x3f
  jmp alltraps
80106cd0:	e9 7c f5 ff ff       	jmp    80106251 <alltraps>

80106cd5 <vector64>:
.globl vector64
vector64:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $64
80106cd7:	6a 40                	push   $0x40
  jmp alltraps
80106cd9:	e9 73 f5 ff ff       	jmp    80106251 <alltraps>

80106cde <vector65>:
.globl vector65
vector65:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $65
80106ce0:	6a 41                	push   $0x41
  jmp alltraps
80106ce2:	e9 6a f5 ff ff       	jmp    80106251 <alltraps>

80106ce7 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $66
80106ce9:	6a 42                	push   $0x42
  jmp alltraps
80106ceb:	e9 61 f5 ff ff       	jmp    80106251 <alltraps>

80106cf0 <vector67>:
.globl vector67
vector67:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $67
80106cf2:	6a 43                	push   $0x43
  jmp alltraps
80106cf4:	e9 58 f5 ff ff       	jmp    80106251 <alltraps>

80106cf9 <vector68>:
.globl vector68
vector68:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $68
80106cfb:	6a 44                	push   $0x44
  jmp alltraps
80106cfd:	e9 4f f5 ff ff       	jmp    80106251 <alltraps>

80106d02 <vector69>:
.globl vector69
vector69:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $69
80106d04:	6a 45                	push   $0x45
  jmp alltraps
80106d06:	e9 46 f5 ff ff       	jmp    80106251 <alltraps>

80106d0b <vector70>:
.globl vector70
vector70:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $70
80106d0d:	6a 46                	push   $0x46
  jmp alltraps
80106d0f:	e9 3d f5 ff ff       	jmp    80106251 <alltraps>

80106d14 <vector71>:
.globl vector71
vector71:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $71
80106d16:	6a 47                	push   $0x47
  jmp alltraps
80106d18:	e9 34 f5 ff ff       	jmp    80106251 <alltraps>

80106d1d <vector72>:
.globl vector72
vector72:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $72
80106d1f:	6a 48                	push   $0x48
  jmp alltraps
80106d21:	e9 2b f5 ff ff       	jmp    80106251 <alltraps>

80106d26 <vector73>:
.globl vector73
vector73:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $73
80106d28:	6a 49                	push   $0x49
  jmp alltraps
80106d2a:	e9 22 f5 ff ff       	jmp    80106251 <alltraps>

80106d2f <vector74>:
.globl vector74
vector74:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $74
80106d31:	6a 4a                	push   $0x4a
  jmp alltraps
80106d33:	e9 19 f5 ff ff       	jmp    80106251 <alltraps>

80106d38 <vector75>:
.globl vector75
vector75:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $75
80106d3a:	6a 4b                	push   $0x4b
  jmp alltraps
80106d3c:	e9 10 f5 ff ff       	jmp    80106251 <alltraps>

80106d41 <vector76>:
.globl vector76
vector76:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $76
80106d43:	6a 4c                	push   $0x4c
  jmp alltraps
80106d45:	e9 07 f5 ff ff       	jmp    80106251 <alltraps>

80106d4a <vector77>:
.globl vector77
vector77:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $77
80106d4c:	6a 4d                	push   $0x4d
  jmp alltraps
80106d4e:	e9 fe f4 ff ff       	jmp    80106251 <alltraps>

80106d53 <vector78>:
.globl vector78
vector78:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $78
80106d55:	6a 4e                	push   $0x4e
  jmp alltraps
80106d57:	e9 f5 f4 ff ff       	jmp    80106251 <alltraps>

80106d5c <vector79>:
.globl vector79
vector79:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $79
80106d5e:	6a 4f                	push   $0x4f
  jmp alltraps
80106d60:	e9 ec f4 ff ff       	jmp    80106251 <alltraps>

80106d65 <vector80>:
.globl vector80
vector80:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $80
80106d67:	6a 50                	push   $0x50
  jmp alltraps
80106d69:	e9 e3 f4 ff ff       	jmp    80106251 <alltraps>

80106d6e <vector81>:
.globl vector81
vector81:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $81
80106d70:	6a 51                	push   $0x51
  jmp alltraps
80106d72:	e9 da f4 ff ff       	jmp    80106251 <alltraps>

80106d77 <vector82>:
.globl vector82
vector82:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $82
80106d79:	6a 52                	push   $0x52
  jmp alltraps
80106d7b:	e9 d1 f4 ff ff       	jmp    80106251 <alltraps>

80106d80 <vector83>:
.globl vector83
vector83:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $83
80106d82:	6a 53                	push   $0x53
  jmp alltraps
80106d84:	e9 c8 f4 ff ff       	jmp    80106251 <alltraps>

80106d89 <vector84>:
.globl vector84
vector84:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $84
80106d8b:	6a 54                	push   $0x54
  jmp alltraps
80106d8d:	e9 bf f4 ff ff       	jmp    80106251 <alltraps>

80106d92 <vector85>:
.globl vector85
vector85:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $85
80106d94:	6a 55                	push   $0x55
  jmp alltraps
80106d96:	e9 b6 f4 ff ff       	jmp    80106251 <alltraps>

80106d9b <vector86>:
.globl vector86
vector86:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $86
80106d9d:	6a 56                	push   $0x56
  jmp alltraps
80106d9f:	e9 ad f4 ff ff       	jmp    80106251 <alltraps>

80106da4 <vector87>:
.globl vector87
vector87:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $87
80106da6:	6a 57                	push   $0x57
  jmp alltraps
80106da8:	e9 a4 f4 ff ff       	jmp    80106251 <alltraps>

80106dad <vector88>:
.globl vector88
vector88:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $88
80106daf:	6a 58                	push   $0x58
  jmp alltraps
80106db1:	e9 9b f4 ff ff       	jmp    80106251 <alltraps>

80106db6 <vector89>:
.globl vector89
vector89:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $89
80106db8:	6a 59                	push   $0x59
  jmp alltraps
80106dba:	e9 92 f4 ff ff       	jmp    80106251 <alltraps>

80106dbf <vector90>:
.globl vector90
vector90:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $90
80106dc1:	6a 5a                	push   $0x5a
  jmp alltraps
80106dc3:	e9 89 f4 ff ff       	jmp    80106251 <alltraps>

80106dc8 <vector91>:
.globl vector91
vector91:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $91
80106dca:	6a 5b                	push   $0x5b
  jmp alltraps
80106dcc:	e9 80 f4 ff ff       	jmp    80106251 <alltraps>

80106dd1 <vector92>:
.globl vector92
vector92:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $92
80106dd3:	6a 5c                	push   $0x5c
  jmp alltraps
80106dd5:	e9 77 f4 ff ff       	jmp    80106251 <alltraps>

80106dda <vector93>:
.globl vector93
vector93:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $93
80106ddc:	6a 5d                	push   $0x5d
  jmp alltraps
80106dde:	e9 6e f4 ff ff       	jmp    80106251 <alltraps>

80106de3 <vector94>:
.globl vector94
vector94:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $94
80106de5:	6a 5e                	push   $0x5e
  jmp alltraps
80106de7:	e9 65 f4 ff ff       	jmp    80106251 <alltraps>

80106dec <vector95>:
.globl vector95
vector95:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $95
80106dee:	6a 5f                	push   $0x5f
  jmp alltraps
80106df0:	e9 5c f4 ff ff       	jmp    80106251 <alltraps>

80106df5 <vector96>:
.globl vector96
vector96:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $96
80106df7:	6a 60                	push   $0x60
  jmp alltraps
80106df9:	e9 53 f4 ff ff       	jmp    80106251 <alltraps>

80106dfe <vector97>:
.globl vector97
vector97:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $97
80106e00:	6a 61                	push   $0x61
  jmp alltraps
80106e02:	e9 4a f4 ff ff       	jmp    80106251 <alltraps>

80106e07 <vector98>:
.globl vector98
vector98:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $98
80106e09:	6a 62                	push   $0x62
  jmp alltraps
80106e0b:	e9 41 f4 ff ff       	jmp    80106251 <alltraps>

80106e10 <vector99>:
.globl vector99
vector99:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $99
80106e12:	6a 63                	push   $0x63
  jmp alltraps
80106e14:	e9 38 f4 ff ff       	jmp    80106251 <alltraps>

80106e19 <vector100>:
.globl vector100
vector100:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $100
80106e1b:	6a 64                	push   $0x64
  jmp alltraps
80106e1d:	e9 2f f4 ff ff       	jmp    80106251 <alltraps>

80106e22 <vector101>:
.globl vector101
vector101:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $101
80106e24:	6a 65                	push   $0x65
  jmp alltraps
80106e26:	e9 26 f4 ff ff       	jmp    80106251 <alltraps>

80106e2b <vector102>:
.globl vector102
vector102:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $102
80106e2d:	6a 66                	push   $0x66
  jmp alltraps
80106e2f:	e9 1d f4 ff ff       	jmp    80106251 <alltraps>

80106e34 <vector103>:
.globl vector103
vector103:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $103
80106e36:	6a 67                	push   $0x67
  jmp alltraps
80106e38:	e9 14 f4 ff ff       	jmp    80106251 <alltraps>

80106e3d <vector104>:
.globl vector104
vector104:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $104
80106e3f:	6a 68                	push   $0x68
  jmp alltraps
80106e41:	e9 0b f4 ff ff       	jmp    80106251 <alltraps>

80106e46 <vector105>:
.globl vector105
vector105:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $105
80106e48:	6a 69                	push   $0x69
  jmp alltraps
80106e4a:	e9 02 f4 ff ff       	jmp    80106251 <alltraps>

80106e4f <vector106>:
.globl vector106
vector106:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $106
80106e51:	6a 6a                	push   $0x6a
  jmp alltraps
80106e53:	e9 f9 f3 ff ff       	jmp    80106251 <alltraps>

80106e58 <vector107>:
.globl vector107
vector107:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $107
80106e5a:	6a 6b                	push   $0x6b
  jmp alltraps
80106e5c:	e9 f0 f3 ff ff       	jmp    80106251 <alltraps>

80106e61 <vector108>:
.globl vector108
vector108:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $108
80106e63:	6a 6c                	push   $0x6c
  jmp alltraps
80106e65:	e9 e7 f3 ff ff       	jmp    80106251 <alltraps>

80106e6a <vector109>:
.globl vector109
vector109:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $109
80106e6c:	6a 6d                	push   $0x6d
  jmp alltraps
80106e6e:	e9 de f3 ff ff       	jmp    80106251 <alltraps>

80106e73 <vector110>:
.globl vector110
vector110:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $110
80106e75:	6a 6e                	push   $0x6e
  jmp alltraps
80106e77:	e9 d5 f3 ff ff       	jmp    80106251 <alltraps>

80106e7c <vector111>:
.globl vector111
vector111:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $111
80106e7e:	6a 6f                	push   $0x6f
  jmp alltraps
80106e80:	e9 cc f3 ff ff       	jmp    80106251 <alltraps>

80106e85 <vector112>:
.globl vector112
vector112:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $112
80106e87:	6a 70                	push   $0x70
  jmp alltraps
80106e89:	e9 c3 f3 ff ff       	jmp    80106251 <alltraps>

80106e8e <vector113>:
.globl vector113
vector113:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $113
80106e90:	6a 71                	push   $0x71
  jmp alltraps
80106e92:	e9 ba f3 ff ff       	jmp    80106251 <alltraps>

80106e97 <vector114>:
.globl vector114
vector114:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $114
80106e99:	6a 72                	push   $0x72
  jmp alltraps
80106e9b:	e9 b1 f3 ff ff       	jmp    80106251 <alltraps>

80106ea0 <vector115>:
.globl vector115
vector115:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $115
80106ea2:	6a 73                	push   $0x73
  jmp alltraps
80106ea4:	e9 a8 f3 ff ff       	jmp    80106251 <alltraps>

80106ea9 <vector116>:
.globl vector116
vector116:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $116
80106eab:	6a 74                	push   $0x74
  jmp alltraps
80106ead:	e9 9f f3 ff ff       	jmp    80106251 <alltraps>

80106eb2 <vector117>:
.globl vector117
vector117:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $117
80106eb4:	6a 75                	push   $0x75
  jmp alltraps
80106eb6:	e9 96 f3 ff ff       	jmp    80106251 <alltraps>

80106ebb <vector118>:
.globl vector118
vector118:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $118
80106ebd:	6a 76                	push   $0x76
  jmp alltraps
80106ebf:	e9 8d f3 ff ff       	jmp    80106251 <alltraps>

80106ec4 <vector119>:
.globl vector119
vector119:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $119
80106ec6:	6a 77                	push   $0x77
  jmp alltraps
80106ec8:	e9 84 f3 ff ff       	jmp    80106251 <alltraps>

80106ecd <vector120>:
.globl vector120
vector120:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $120
80106ecf:	6a 78                	push   $0x78
  jmp alltraps
80106ed1:	e9 7b f3 ff ff       	jmp    80106251 <alltraps>

80106ed6 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $121
80106ed8:	6a 79                	push   $0x79
  jmp alltraps
80106eda:	e9 72 f3 ff ff       	jmp    80106251 <alltraps>

80106edf <vector122>:
.globl vector122
vector122:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $122
80106ee1:	6a 7a                	push   $0x7a
  jmp alltraps
80106ee3:	e9 69 f3 ff ff       	jmp    80106251 <alltraps>

80106ee8 <vector123>:
.globl vector123
vector123:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $123
80106eea:	6a 7b                	push   $0x7b
  jmp alltraps
80106eec:	e9 60 f3 ff ff       	jmp    80106251 <alltraps>

80106ef1 <vector124>:
.globl vector124
vector124:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $124
80106ef3:	6a 7c                	push   $0x7c
  jmp alltraps
80106ef5:	e9 57 f3 ff ff       	jmp    80106251 <alltraps>

80106efa <vector125>:
.globl vector125
vector125:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $125
80106efc:	6a 7d                	push   $0x7d
  jmp alltraps
80106efe:	e9 4e f3 ff ff       	jmp    80106251 <alltraps>

80106f03 <vector126>:
.globl vector126
vector126:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $126
80106f05:	6a 7e                	push   $0x7e
  jmp alltraps
80106f07:	e9 45 f3 ff ff       	jmp    80106251 <alltraps>

80106f0c <vector127>:
.globl vector127
vector127:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $127
80106f0e:	6a 7f                	push   $0x7f
  jmp alltraps
80106f10:	e9 3c f3 ff ff       	jmp    80106251 <alltraps>

80106f15 <vector128>:
.globl vector128
vector128:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $128
80106f17:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f1c:	e9 30 f3 ff ff       	jmp    80106251 <alltraps>

80106f21 <vector129>:
.globl vector129
vector129:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $129
80106f23:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f28:	e9 24 f3 ff ff       	jmp    80106251 <alltraps>

80106f2d <vector130>:
.globl vector130
vector130:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $130
80106f2f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106f34:	e9 18 f3 ff ff       	jmp    80106251 <alltraps>

80106f39 <vector131>:
.globl vector131
vector131:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $131
80106f3b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f40:	e9 0c f3 ff ff       	jmp    80106251 <alltraps>

80106f45 <vector132>:
.globl vector132
vector132:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $132
80106f47:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106f4c:	e9 00 f3 ff ff       	jmp    80106251 <alltraps>

80106f51 <vector133>:
.globl vector133
vector133:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $133
80106f53:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106f58:	e9 f4 f2 ff ff       	jmp    80106251 <alltraps>

80106f5d <vector134>:
.globl vector134
vector134:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $134
80106f5f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f64:	e9 e8 f2 ff ff       	jmp    80106251 <alltraps>

80106f69 <vector135>:
.globl vector135
vector135:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $135
80106f6b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106f70:	e9 dc f2 ff ff       	jmp    80106251 <alltraps>

80106f75 <vector136>:
.globl vector136
vector136:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $136
80106f77:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106f7c:	e9 d0 f2 ff ff       	jmp    80106251 <alltraps>

80106f81 <vector137>:
.globl vector137
vector137:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $137
80106f83:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106f88:	e9 c4 f2 ff ff       	jmp    80106251 <alltraps>

80106f8d <vector138>:
.globl vector138
vector138:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $138
80106f8f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106f94:	e9 b8 f2 ff ff       	jmp    80106251 <alltraps>

80106f99 <vector139>:
.globl vector139
vector139:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $139
80106f9b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106fa0:	e9 ac f2 ff ff       	jmp    80106251 <alltraps>

80106fa5 <vector140>:
.globl vector140
vector140:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $140
80106fa7:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106fac:	e9 a0 f2 ff ff       	jmp    80106251 <alltraps>

80106fb1 <vector141>:
.globl vector141
vector141:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $141
80106fb3:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106fb8:	e9 94 f2 ff ff       	jmp    80106251 <alltraps>

80106fbd <vector142>:
.globl vector142
vector142:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $142
80106fbf:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106fc4:	e9 88 f2 ff ff       	jmp    80106251 <alltraps>

80106fc9 <vector143>:
.globl vector143
vector143:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $143
80106fcb:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106fd0:	e9 7c f2 ff ff       	jmp    80106251 <alltraps>

80106fd5 <vector144>:
.globl vector144
vector144:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $144
80106fd7:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106fdc:	e9 70 f2 ff ff       	jmp    80106251 <alltraps>

80106fe1 <vector145>:
.globl vector145
vector145:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $145
80106fe3:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106fe8:	e9 64 f2 ff ff       	jmp    80106251 <alltraps>

80106fed <vector146>:
.globl vector146
vector146:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $146
80106fef:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106ff4:	e9 58 f2 ff ff       	jmp    80106251 <alltraps>

80106ff9 <vector147>:
.globl vector147
vector147:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $147
80106ffb:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107000:	e9 4c f2 ff ff       	jmp    80106251 <alltraps>

80107005 <vector148>:
.globl vector148
vector148:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $148
80107007:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010700c:	e9 40 f2 ff ff       	jmp    80106251 <alltraps>

80107011 <vector149>:
.globl vector149
vector149:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $149
80107013:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107018:	e9 34 f2 ff ff       	jmp    80106251 <alltraps>

8010701d <vector150>:
.globl vector150
vector150:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $150
8010701f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107024:	e9 28 f2 ff ff       	jmp    80106251 <alltraps>

80107029 <vector151>:
.globl vector151
vector151:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $151
8010702b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107030:	e9 1c f2 ff ff       	jmp    80106251 <alltraps>

80107035 <vector152>:
.globl vector152
vector152:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $152
80107037:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010703c:	e9 10 f2 ff ff       	jmp    80106251 <alltraps>

80107041 <vector153>:
.globl vector153
vector153:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $153
80107043:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107048:	e9 04 f2 ff ff       	jmp    80106251 <alltraps>

8010704d <vector154>:
.globl vector154
vector154:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $154
8010704f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107054:	e9 f8 f1 ff ff       	jmp    80106251 <alltraps>

80107059 <vector155>:
.globl vector155
vector155:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $155
8010705b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107060:	e9 ec f1 ff ff       	jmp    80106251 <alltraps>

80107065 <vector156>:
.globl vector156
vector156:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $156
80107067:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010706c:	e9 e0 f1 ff ff       	jmp    80106251 <alltraps>

80107071 <vector157>:
.globl vector157
vector157:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $157
80107073:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107078:	e9 d4 f1 ff ff       	jmp    80106251 <alltraps>

8010707d <vector158>:
.globl vector158
vector158:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $158
8010707f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107084:	e9 c8 f1 ff ff       	jmp    80106251 <alltraps>

80107089 <vector159>:
.globl vector159
vector159:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $159
8010708b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107090:	e9 bc f1 ff ff       	jmp    80106251 <alltraps>

80107095 <vector160>:
.globl vector160
vector160:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $160
80107097:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010709c:	e9 b0 f1 ff ff       	jmp    80106251 <alltraps>

801070a1 <vector161>:
.globl vector161
vector161:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $161
801070a3:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801070a8:	e9 a4 f1 ff ff       	jmp    80106251 <alltraps>

801070ad <vector162>:
.globl vector162
vector162:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $162
801070af:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801070b4:	e9 98 f1 ff ff       	jmp    80106251 <alltraps>

801070b9 <vector163>:
.globl vector163
vector163:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $163
801070bb:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801070c0:	e9 8c f1 ff ff       	jmp    80106251 <alltraps>

801070c5 <vector164>:
.globl vector164
vector164:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $164
801070c7:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801070cc:	e9 80 f1 ff ff       	jmp    80106251 <alltraps>

801070d1 <vector165>:
.globl vector165
vector165:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $165
801070d3:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801070d8:	e9 74 f1 ff ff       	jmp    80106251 <alltraps>

801070dd <vector166>:
.globl vector166
vector166:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $166
801070df:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801070e4:	e9 68 f1 ff ff       	jmp    80106251 <alltraps>

801070e9 <vector167>:
.globl vector167
vector167:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $167
801070eb:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801070f0:	e9 5c f1 ff ff       	jmp    80106251 <alltraps>

801070f5 <vector168>:
.globl vector168
vector168:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $168
801070f7:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801070fc:	e9 50 f1 ff ff       	jmp    80106251 <alltraps>

80107101 <vector169>:
.globl vector169
vector169:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $169
80107103:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107108:	e9 44 f1 ff ff       	jmp    80106251 <alltraps>

8010710d <vector170>:
.globl vector170
vector170:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $170
8010710f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107114:	e9 38 f1 ff ff       	jmp    80106251 <alltraps>

80107119 <vector171>:
.globl vector171
vector171:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $171
8010711b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107120:	e9 2c f1 ff ff       	jmp    80106251 <alltraps>

80107125 <vector172>:
.globl vector172
vector172:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $172
80107127:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010712c:	e9 20 f1 ff ff       	jmp    80106251 <alltraps>

80107131 <vector173>:
.globl vector173
vector173:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $173
80107133:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107138:	e9 14 f1 ff ff       	jmp    80106251 <alltraps>

8010713d <vector174>:
.globl vector174
vector174:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $174
8010713f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107144:	e9 08 f1 ff ff       	jmp    80106251 <alltraps>

80107149 <vector175>:
.globl vector175
vector175:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $175
8010714b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107150:	e9 fc f0 ff ff       	jmp    80106251 <alltraps>

80107155 <vector176>:
.globl vector176
vector176:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $176
80107157:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010715c:	e9 f0 f0 ff ff       	jmp    80106251 <alltraps>

80107161 <vector177>:
.globl vector177
vector177:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $177
80107163:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107168:	e9 e4 f0 ff ff       	jmp    80106251 <alltraps>

8010716d <vector178>:
.globl vector178
vector178:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $178
8010716f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107174:	e9 d8 f0 ff ff       	jmp    80106251 <alltraps>

80107179 <vector179>:
.globl vector179
vector179:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $179
8010717b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107180:	e9 cc f0 ff ff       	jmp    80106251 <alltraps>

80107185 <vector180>:
.globl vector180
vector180:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $180
80107187:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010718c:	e9 c0 f0 ff ff       	jmp    80106251 <alltraps>

80107191 <vector181>:
.globl vector181
vector181:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $181
80107193:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107198:	e9 b4 f0 ff ff       	jmp    80106251 <alltraps>

8010719d <vector182>:
.globl vector182
vector182:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $182
8010719f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801071a4:	e9 a8 f0 ff ff       	jmp    80106251 <alltraps>

801071a9 <vector183>:
.globl vector183
vector183:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $183
801071ab:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801071b0:	e9 9c f0 ff ff       	jmp    80106251 <alltraps>

801071b5 <vector184>:
.globl vector184
vector184:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $184
801071b7:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801071bc:	e9 90 f0 ff ff       	jmp    80106251 <alltraps>

801071c1 <vector185>:
.globl vector185
vector185:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $185
801071c3:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801071c8:	e9 84 f0 ff ff       	jmp    80106251 <alltraps>

801071cd <vector186>:
.globl vector186
vector186:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $186
801071cf:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801071d4:	e9 78 f0 ff ff       	jmp    80106251 <alltraps>

801071d9 <vector187>:
.globl vector187
vector187:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $187
801071db:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801071e0:	e9 6c f0 ff ff       	jmp    80106251 <alltraps>

801071e5 <vector188>:
.globl vector188
vector188:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $188
801071e7:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801071ec:	e9 60 f0 ff ff       	jmp    80106251 <alltraps>

801071f1 <vector189>:
.globl vector189
vector189:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $189
801071f3:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801071f8:	e9 54 f0 ff ff       	jmp    80106251 <alltraps>

801071fd <vector190>:
.globl vector190
vector190:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $190
801071ff:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107204:	e9 48 f0 ff ff       	jmp    80106251 <alltraps>

80107209 <vector191>:
.globl vector191
vector191:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $191
8010720b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107210:	e9 3c f0 ff ff       	jmp    80106251 <alltraps>

80107215 <vector192>:
.globl vector192
vector192:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $192
80107217:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010721c:	e9 30 f0 ff ff       	jmp    80106251 <alltraps>

80107221 <vector193>:
.globl vector193
vector193:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $193
80107223:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107228:	e9 24 f0 ff ff       	jmp    80106251 <alltraps>

8010722d <vector194>:
.globl vector194
vector194:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $194
8010722f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107234:	e9 18 f0 ff ff       	jmp    80106251 <alltraps>

80107239 <vector195>:
.globl vector195
vector195:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $195
8010723b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107240:	e9 0c f0 ff ff       	jmp    80106251 <alltraps>

80107245 <vector196>:
.globl vector196
vector196:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $196
80107247:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010724c:	e9 00 f0 ff ff       	jmp    80106251 <alltraps>

80107251 <vector197>:
.globl vector197
vector197:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $197
80107253:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107258:	e9 f4 ef ff ff       	jmp    80106251 <alltraps>

8010725d <vector198>:
.globl vector198
vector198:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $198
8010725f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107264:	e9 e8 ef ff ff       	jmp    80106251 <alltraps>

80107269 <vector199>:
.globl vector199
vector199:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $199
8010726b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107270:	e9 dc ef ff ff       	jmp    80106251 <alltraps>

80107275 <vector200>:
.globl vector200
vector200:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $200
80107277:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010727c:	e9 d0 ef ff ff       	jmp    80106251 <alltraps>

80107281 <vector201>:
.globl vector201
vector201:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $201
80107283:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107288:	e9 c4 ef ff ff       	jmp    80106251 <alltraps>

8010728d <vector202>:
.globl vector202
vector202:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $202
8010728f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107294:	e9 b8 ef ff ff       	jmp    80106251 <alltraps>

80107299 <vector203>:
.globl vector203
vector203:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $203
8010729b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801072a0:	e9 ac ef ff ff       	jmp    80106251 <alltraps>

801072a5 <vector204>:
.globl vector204
vector204:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $204
801072a7:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801072ac:	e9 a0 ef ff ff       	jmp    80106251 <alltraps>

801072b1 <vector205>:
.globl vector205
vector205:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $205
801072b3:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801072b8:	e9 94 ef ff ff       	jmp    80106251 <alltraps>

801072bd <vector206>:
.globl vector206
vector206:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $206
801072bf:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801072c4:	e9 88 ef ff ff       	jmp    80106251 <alltraps>

801072c9 <vector207>:
.globl vector207
vector207:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $207
801072cb:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801072d0:	e9 7c ef ff ff       	jmp    80106251 <alltraps>

801072d5 <vector208>:
.globl vector208
vector208:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $208
801072d7:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801072dc:	e9 70 ef ff ff       	jmp    80106251 <alltraps>

801072e1 <vector209>:
.globl vector209
vector209:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $209
801072e3:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801072e8:	e9 64 ef ff ff       	jmp    80106251 <alltraps>

801072ed <vector210>:
.globl vector210
vector210:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $210
801072ef:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801072f4:	e9 58 ef ff ff       	jmp    80106251 <alltraps>

801072f9 <vector211>:
.globl vector211
vector211:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $211
801072fb:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107300:	e9 4c ef ff ff       	jmp    80106251 <alltraps>

80107305 <vector212>:
.globl vector212
vector212:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $212
80107307:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010730c:	e9 40 ef ff ff       	jmp    80106251 <alltraps>

80107311 <vector213>:
.globl vector213
vector213:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $213
80107313:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107318:	e9 34 ef ff ff       	jmp    80106251 <alltraps>

8010731d <vector214>:
.globl vector214
vector214:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $214
8010731f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107324:	e9 28 ef ff ff       	jmp    80106251 <alltraps>

80107329 <vector215>:
.globl vector215
vector215:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $215
8010732b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107330:	e9 1c ef ff ff       	jmp    80106251 <alltraps>

80107335 <vector216>:
.globl vector216
vector216:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $216
80107337:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010733c:	e9 10 ef ff ff       	jmp    80106251 <alltraps>

80107341 <vector217>:
.globl vector217
vector217:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $217
80107343:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107348:	e9 04 ef ff ff       	jmp    80106251 <alltraps>

8010734d <vector218>:
.globl vector218
vector218:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $218
8010734f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107354:	e9 f8 ee ff ff       	jmp    80106251 <alltraps>

80107359 <vector219>:
.globl vector219
vector219:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $219
8010735b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107360:	e9 ec ee ff ff       	jmp    80106251 <alltraps>

80107365 <vector220>:
.globl vector220
vector220:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $220
80107367:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010736c:	e9 e0 ee ff ff       	jmp    80106251 <alltraps>

80107371 <vector221>:
.globl vector221
vector221:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $221
80107373:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107378:	e9 d4 ee ff ff       	jmp    80106251 <alltraps>

8010737d <vector222>:
.globl vector222
vector222:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $222
8010737f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107384:	e9 c8 ee ff ff       	jmp    80106251 <alltraps>

80107389 <vector223>:
.globl vector223
vector223:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $223
8010738b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107390:	e9 bc ee ff ff       	jmp    80106251 <alltraps>

80107395 <vector224>:
.globl vector224
vector224:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $224
80107397:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010739c:	e9 b0 ee ff ff       	jmp    80106251 <alltraps>

801073a1 <vector225>:
.globl vector225
vector225:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $225
801073a3:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801073a8:	e9 a4 ee ff ff       	jmp    80106251 <alltraps>

801073ad <vector226>:
.globl vector226
vector226:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $226
801073af:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801073b4:	e9 98 ee ff ff       	jmp    80106251 <alltraps>

801073b9 <vector227>:
.globl vector227
vector227:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $227
801073bb:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801073c0:	e9 8c ee ff ff       	jmp    80106251 <alltraps>

801073c5 <vector228>:
.globl vector228
vector228:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $228
801073c7:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801073cc:	e9 80 ee ff ff       	jmp    80106251 <alltraps>

801073d1 <vector229>:
.globl vector229
vector229:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $229
801073d3:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801073d8:	e9 74 ee ff ff       	jmp    80106251 <alltraps>

801073dd <vector230>:
.globl vector230
vector230:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $230
801073df:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801073e4:	e9 68 ee ff ff       	jmp    80106251 <alltraps>

801073e9 <vector231>:
.globl vector231
vector231:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $231
801073eb:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801073f0:	e9 5c ee ff ff       	jmp    80106251 <alltraps>

801073f5 <vector232>:
.globl vector232
vector232:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $232
801073f7:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801073fc:	e9 50 ee ff ff       	jmp    80106251 <alltraps>

80107401 <vector233>:
.globl vector233
vector233:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $233
80107403:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107408:	e9 44 ee ff ff       	jmp    80106251 <alltraps>

8010740d <vector234>:
.globl vector234
vector234:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $234
8010740f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107414:	e9 38 ee ff ff       	jmp    80106251 <alltraps>

80107419 <vector235>:
.globl vector235
vector235:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $235
8010741b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107420:	e9 2c ee ff ff       	jmp    80106251 <alltraps>

80107425 <vector236>:
.globl vector236
vector236:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $236
80107427:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010742c:	e9 20 ee ff ff       	jmp    80106251 <alltraps>

80107431 <vector237>:
.globl vector237
vector237:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $237
80107433:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107438:	e9 14 ee ff ff       	jmp    80106251 <alltraps>

8010743d <vector238>:
.globl vector238
vector238:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $238
8010743f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107444:	e9 08 ee ff ff       	jmp    80106251 <alltraps>

80107449 <vector239>:
.globl vector239
vector239:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $239
8010744b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107450:	e9 fc ed ff ff       	jmp    80106251 <alltraps>

80107455 <vector240>:
.globl vector240
vector240:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $240
80107457:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010745c:	e9 f0 ed ff ff       	jmp    80106251 <alltraps>

80107461 <vector241>:
.globl vector241
vector241:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $241
80107463:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107468:	e9 e4 ed ff ff       	jmp    80106251 <alltraps>

8010746d <vector242>:
.globl vector242
vector242:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $242
8010746f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107474:	e9 d8 ed ff ff       	jmp    80106251 <alltraps>

80107479 <vector243>:
.globl vector243
vector243:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $243
8010747b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107480:	e9 cc ed ff ff       	jmp    80106251 <alltraps>

80107485 <vector244>:
.globl vector244
vector244:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $244
80107487:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010748c:	e9 c0 ed ff ff       	jmp    80106251 <alltraps>

80107491 <vector245>:
.globl vector245
vector245:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $245
80107493:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107498:	e9 b4 ed ff ff       	jmp    80106251 <alltraps>

8010749d <vector246>:
.globl vector246
vector246:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $246
8010749f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801074a4:	e9 a8 ed ff ff       	jmp    80106251 <alltraps>

801074a9 <vector247>:
.globl vector247
vector247:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $247
801074ab:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801074b0:	e9 9c ed ff ff       	jmp    80106251 <alltraps>

801074b5 <vector248>:
.globl vector248
vector248:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $248
801074b7:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801074bc:	e9 90 ed ff ff       	jmp    80106251 <alltraps>

801074c1 <vector249>:
.globl vector249
vector249:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $249
801074c3:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801074c8:	e9 84 ed ff ff       	jmp    80106251 <alltraps>

801074cd <vector250>:
.globl vector250
vector250:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $250
801074cf:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801074d4:	e9 78 ed ff ff       	jmp    80106251 <alltraps>

801074d9 <vector251>:
.globl vector251
vector251:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $251
801074db:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801074e0:	e9 6c ed ff ff       	jmp    80106251 <alltraps>

801074e5 <vector252>:
.globl vector252
vector252:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $252
801074e7:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801074ec:	e9 60 ed ff ff       	jmp    80106251 <alltraps>

801074f1 <vector253>:
.globl vector253
vector253:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $253
801074f3:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801074f8:	e9 54 ed ff ff       	jmp    80106251 <alltraps>

801074fd <vector254>:
.globl vector254
vector254:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $254
801074ff:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107504:	e9 48 ed ff ff       	jmp    80106251 <alltraps>

80107509 <vector255>:
.globl vector255
vector255:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $255
8010750b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107510:	e9 3c ed ff ff       	jmp    80106251 <alltraps>

80107515 <lgdt>:
{
80107515:	55                   	push   %ebp
80107516:	89 e5                	mov    %esp,%ebp
80107518:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010751b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010751e:	83 e8 01             	sub    $0x1,%eax
80107521:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107525:	8b 45 08             	mov    0x8(%ebp),%eax
80107528:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010752c:	8b 45 08             	mov    0x8(%ebp),%eax
8010752f:	c1 e8 10             	shr    $0x10,%eax
80107532:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107536:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107539:	0f 01 10             	lgdtl  (%eax)
}
8010753c:	90                   	nop
8010753d:	c9                   	leave  
8010753e:	c3                   	ret    

8010753f <ltr>:
{
8010753f:	55                   	push   %ebp
80107540:	89 e5                	mov    %esp,%ebp
80107542:	83 ec 04             	sub    $0x4,%esp
80107545:	8b 45 08             	mov    0x8(%ebp),%eax
80107548:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010754c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107550:	0f 00 d8             	ltr    %ax
}
80107553:	90                   	nop
80107554:	c9                   	leave  
80107555:	c3                   	ret    

80107556 <lcr3>:

static inline void
lcr3(uint val)
{
80107556:	55                   	push   %ebp
80107557:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107559:	8b 45 08             	mov    0x8(%ebp),%eax
8010755c:	0f 22 d8             	mov    %eax,%cr3
}
8010755f:	90                   	nop
80107560:	5d                   	pop    %ebp
80107561:	c3                   	ret    

80107562 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107562:	55                   	push   %ebp
80107563:	89 e5                	mov    %esp,%ebp
80107565:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107568:	e8 5e c4 ff ff       	call   801039cb <cpuid>
8010756d:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107573:	05 c0 76 19 80       	add    $0x801976c0,%eax
80107578:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010757b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107587:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010758d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107590:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107597:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010759b:	83 e2 f0             	and    $0xfffffff0,%edx
8010759e:	83 ca 0a             	or     $0xa,%edx
801075a1:	88 50 7d             	mov    %dl,0x7d(%eax)
801075a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075ab:	83 ca 10             	or     $0x10,%edx
801075ae:	88 50 7d             	mov    %dl,0x7d(%eax)
801075b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075b8:	83 e2 9f             	and    $0xffffff9f,%edx
801075bb:	88 50 7d             	mov    %dl,0x7d(%eax)
801075be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075c5:	83 ca 80             	or     $0xffffff80,%edx
801075c8:	88 50 7d             	mov    %dl,0x7d(%eax)
801075cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ce:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075d2:	83 ca 0f             	or     $0xf,%edx
801075d5:	88 50 7e             	mov    %dl,0x7e(%eax)
801075d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075db:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075df:	83 e2 ef             	and    $0xffffffef,%edx
801075e2:	88 50 7e             	mov    %dl,0x7e(%eax)
801075e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075ec:	83 e2 df             	and    $0xffffffdf,%edx
801075ef:	88 50 7e             	mov    %dl,0x7e(%eax)
801075f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075f9:	83 ca 40             	or     $0x40,%edx
801075fc:	88 50 7e             	mov    %dl,0x7e(%eax)
801075ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107602:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107606:	83 ca 80             	or     $0xffffff80,%edx
80107609:	88 50 7e             	mov    %dl,0x7e(%eax)
8010760c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107616:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010761d:	ff ff 
8010761f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107622:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107629:	00 00 
8010762b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107638:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010763f:	83 e2 f0             	and    $0xfffffff0,%edx
80107642:	83 ca 02             	or     $0x2,%edx
80107645:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010764b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107655:	83 ca 10             	or     $0x10,%edx
80107658:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010765e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107661:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107668:	83 e2 9f             	and    $0xffffff9f,%edx
8010766b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107674:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010767b:	83 ca 80             	or     $0xffffff80,%edx
8010767e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107687:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010768e:	83 ca 0f             	or     $0xf,%edx
80107691:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076a1:	83 e2 ef             	and    $0xffffffef,%edx
801076a4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ad:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076b4:	83 e2 df             	and    $0xffffffdf,%edx
801076b7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076c7:	83 ca 40             	or     $0x40,%edx
801076ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076da:	83 ca 80             	or     $0xffffff80,%edx
801076dd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801076ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f0:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801076f7:	ff ff 
801076f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fc:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107703:	00 00 
80107705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107708:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010770f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107712:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107719:	83 e2 f0             	and    $0xfffffff0,%edx
8010771c:	83 ca 0a             	or     $0xa,%edx
8010771f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107728:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010772f:	83 ca 10             	or     $0x10,%edx
80107732:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107742:	83 ca 60             	or     $0x60,%edx
80107745:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010774b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107755:	83 ca 80             	or     $0xffffff80,%edx
80107758:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010775e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107761:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107768:	83 ca 0f             	or     $0xf,%edx
8010776b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107774:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010777b:	83 e2 ef             	and    $0xffffffef,%edx
8010777e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107787:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010778e:	83 e2 df             	and    $0xffffffdf,%edx
80107791:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077a1:	83 ca 40             	or     $0x40,%edx
801077a4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ad:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077b4:	83 ca 80             	or     $0xffffff80,%edx
801077b7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c0:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801077c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ca:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801077d1:	ff ff 
801077d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d6:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801077dd:	00 00 
801077df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e2:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801077e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ec:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077f3:	83 e2 f0             	and    $0xfffffff0,%edx
801077f6:	83 ca 02             	or     $0x2,%edx
801077f9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107802:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107809:	83 ca 10             	or     $0x10,%edx
8010780c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107815:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010781c:	83 ca 60             	or     $0x60,%edx
8010781f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107828:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010782f:	83 ca 80             	or     $0xffffff80,%edx
80107832:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107842:	83 ca 0f             	or     $0xf,%edx
80107845:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107855:	83 e2 ef             	and    $0xffffffef,%edx
80107858:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010785e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107861:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107868:	83 e2 df             	and    $0xffffffdf,%edx
8010786b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107874:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010787b:	83 ca 40             	or     $0x40,%edx
8010787e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107887:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010788e:	83 ca 80             	or     $0xffffff80,%edx
80107891:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789a:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801078a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a4:	83 c0 70             	add    $0x70,%eax
801078a7:	83 ec 08             	sub    $0x8,%esp
801078aa:	6a 30                	push   $0x30
801078ac:	50                   	push   %eax
801078ad:	e8 63 fc ff ff       	call   80107515 <lgdt>
801078b2:	83 c4 10             	add    $0x10,%esp
}
801078b5:	90                   	nop
801078b6:	c9                   	leave  
801078b7:	c3                   	ret    

801078b8 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801078b8:	55                   	push   %ebp
801078b9:	89 e5                	mov    %esp,%ebp
801078bb:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801078be:	8b 45 0c             	mov    0xc(%ebp),%eax
801078c1:	c1 e8 16             	shr    $0x16,%eax
801078c4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078cb:	8b 45 08             	mov    0x8(%ebp),%eax
801078ce:	01 d0                	add    %edx,%eax
801078d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801078d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078d6:	8b 00                	mov    (%eax),%eax
801078d8:	83 e0 01             	and    $0x1,%eax
801078db:	85 c0                	test   %eax,%eax
801078dd:	74 14                	je     801078f3 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801078df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078e2:	8b 00                	mov    (%eax),%eax
801078e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078e9:	05 00 00 00 80       	add    $0x80000000,%eax
801078ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078f1:	eb 42                	jmp    80107935 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801078f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801078f7:	74 0e                	je     80107907 <walkpgdir+0x4f>
801078f9:	e8 a2 ae ff ff       	call   801027a0 <kalloc>
801078fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107901:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107905:	75 07                	jne    8010790e <walkpgdir+0x56>
      return 0;
80107907:	b8 00 00 00 00       	mov    $0x0,%eax
8010790c:	eb 3e                	jmp    8010794c <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010790e:	83 ec 04             	sub    $0x4,%esp
80107911:	68 00 10 00 00       	push   $0x1000
80107916:	6a 00                	push   $0x0
80107918:	ff 75 f4             	push   -0xc(%ebp)
8010791b:	e8 3c d5 ff ff       	call   80104e5c <memset>
80107920:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107926:	05 00 00 00 80       	add    $0x80000000,%eax
8010792b:	83 c8 07             	or     $0x7,%eax
8010792e:	89 c2                	mov    %eax,%edx
80107930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107933:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107935:	8b 45 0c             	mov    0xc(%ebp),%eax
80107938:	c1 e8 0c             	shr    $0xc,%eax
8010793b:	25 ff 03 00 00       	and    $0x3ff,%eax
80107940:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794a:	01 d0                	add    %edx,%eax
}
8010794c:	c9                   	leave  
8010794d:	c3                   	ret    

8010794e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010794e:	55                   	push   %ebp
8010794f:	89 e5                	mov    %esp,%ebp
80107951:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107954:	8b 45 0c             	mov    0xc(%ebp),%eax
80107957:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010795c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010795f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107962:	8b 45 10             	mov    0x10(%ebp),%eax
80107965:	01 d0                	add    %edx,%eax
80107967:	83 e8 01             	sub    $0x1,%eax
8010796a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010796f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107972:	83 ec 04             	sub    $0x4,%esp
80107975:	6a 01                	push   $0x1
80107977:	ff 75 f4             	push   -0xc(%ebp)
8010797a:	ff 75 08             	push   0x8(%ebp)
8010797d:	e8 36 ff ff ff       	call   801078b8 <walkpgdir>
80107982:	83 c4 10             	add    $0x10,%esp
80107985:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107988:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010798c:	75 07                	jne    80107995 <mappages+0x47>
      return -1;
8010798e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107993:	eb 47                	jmp    801079dc <mappages+0x8e>
    if(*pte & PTE_P)
80107995:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107998:	8b 00                	mov    (%eax),%eax
8010799a:	83 e0 01             	and    $0x1,%eax
8010799d:	85 c0                	test   %eax,%eax
8010799f:	74 0d                	je     801079ae <mappages+0x60>
      panic("remap");
801079a1:	83 ec 0c             	sub    $0xc,%esp
801079a4:	68 40 ad 10 80       	push   $0x8010ad40
801079a9:	e8 fb 8b ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801079ae:	8b 45 18             	mov    0x18(%ebp),%eax
801079b1:	0b 45 14             	or     0x14(%ebp),%eax
801079b4:	83 c8 01             	or     $0x1,%eax
801079b7:	89 c2                	mov    %eax,%edx
801079b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079bc:	89 10                	mov    %edx,(%eax)
    if(a == last)
801079be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801079c4:	74 10                	je     801079d6 <mappages+0x88>
      break;
    a += PGSIZE;
801079c6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801079cd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801079d4:	eb 9c                	jmp    80107972 <mappages+0x24>
      break;
801079d6:	90                   	nop
  }
  return 0;
801079d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801079dc:	c9                   	leave  
801079dd:	c3                   	ret    

801079de <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801079de:	55                   	push   %ebp
801079df:	89 e5                	mov    %esp,%ebp
801079e1:	53                   	push   %ebx
801079e2:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801079e5:	c7 45 f4 c0 f4 10 80 	movl   $0x8010f4c0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801079ec:	8b 15 a0 79 19 80    	mov    0x801979a0,%edx
801079f2:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801079f7:	29 d0                	sub    %edx,%eax
801079f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801079fc:	a1 98 79 19 80       	mov    0x80197998,%eax
80107a01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a04:	8b 15 98 79 19 80    	mov    0x80197998,%edx
80107a0a:	a1 a0 79 19 80       	mov    0x801979a0,%eax
80107a0f:	01 d0                	add    %edx,%eax
80107a11:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107a14:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1e:	83 c0 30             	add    $0x30,%eax
80107a21:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107a24:	89 10                	mov    %edx,(%eax)
80107a26:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a29:	89 50 04             	mov    %edx,0x4(%eax)
80107a2c:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a2f:	89 50 08             	mov    %edx,0x8(%eax)
80107a32:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107a35:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107a38:	e8 63 ad ff ff       	call   801027a0 <kalloc>
80107a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a44:	75 07                	jne    80107a4d <setupkvm+0x6f>
    return 0;
80107a46:	b8 00 00 00 00       	mov    $0x0,%eax
80107a4b:	eb 78                	jmp    80107ac5 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107a4d:	83 ec 04             	sub    $0x4,%esp
80107a50:	68 00 10 00 00       	push   $0x1000
80107a55:	6a 00                	push   $0x0
80107a57:	ff 75 f0             	push   -0x10(%ebp)
80107a5a:	e8 fd d3 ff ff       	call   80104e5c <memset>
80107a5f:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a62:	c7 45 f4 c0 f4 10 80 	movl   $0x8010f4c0,-0xc(%ebp)
80107a69:	eb 4e                	jmp    80107ab9 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a74:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7a:	8b 58 08             	mov    0x8(%eax),%ebx
80107a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a80:	8b 40 04             	mov    0x4(%eax),%eax
80107a83:	29 c3                	sub    %eax,%ebx
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	8b 00                	mov    (%eax),%eax
80107a8a:	83 ec 0c             	sub    $0xc,%esp
80107a8d:	51                   	push   %ecx
80107a8e:	52                   	push   %edx
80107a8f:	53                   	push   %ebx
80107a90:	50                   	push   %eax
80107a91:	ff 75 f0             	push   -0x10(%ebp)
80107a94:	e8 b5 fe ff ff       	call   8010794e <mappages>
80107a99:	83 c4 20             	add    $0x20,%esp
80107a9c:	85 c0                	test   %eax,%eax
80107a9e:	79 15                	jns    80107ab5 <setupkvm+0xd7>
      freevm(pgdir);
80107aa0:	83 ec 0c             	sub    $0xc,%esp
80107aa3:	ff 75 f0             	push   -0x10(%ebp)
80107aa6:	e8 f5 04 00 00       	call   80107fa0 <freevm>
80107aab:	83 c4 10             	add    $0x10,%esp
      return 0;
80107aae:	b8 00 00 00 00       	mov    $0x0,%eax
80107ab3:	eb 10                	jmp    80107ac5 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ab5:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107ab9:	81 7d f4 20 f5 10 80 	cmpl   $0x8010f520,-0xc(%ebp)
80107ac0:	72 a9                	jb     80107a6b <setupkvm+0x8d>
    }
  return pgdir;
80107ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107ac5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107ac8:	c9                   	leave  
80107ac9:	c3                   	ret    

80107aca <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107aca:	55                   	push   %ebp
80107acb:	89 e5                	mov    %esp,%ebp
80107acd:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107ad0:	e8 09 ff ff ff       	call   801079de <setupkvm>
80107ad5:	a3 bc 76 19 80       	mov    %eax,0x801976bc
  switchkvm();
80107ada:	e8 03 00 00 00       	call   80107ae2 <switchkvm>
}
80107adf:	90                   	nop
80107ae0:	c9                   	leave  
80107ae1:	c3                   	ret    

80107ae2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107ae2:	55                   	push   %ebp
80107ae3:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107ae5:	a1 bc 76 19 80       	mov    0x801976bc,%eax
80107aea:	05 00 00 00 80       	add    $0x80000000,%eax
80107aef:	50                   	push   %eax
80107af0:	e8 61 fa ff ff       	call   80107556 <lcr3>
80107af5:	83 c4 04             	add    $0x4,%esp
}
80107af8:	90                   	nop
80107af9:	c9                   	leave  
80107afa:	c3                   	ret    

80107afb <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107afb:	55                   	push   %ebp
80107afc:	89 e5                	mov    %esp,%ebp
80107afe:	56                   	push   %esi
80107aff:	53                   	push   %ebx
80107b00:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b07:	75 0d                	jne    80107b16 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107b09:	83 ec 0c             	sub    $0xc,%esp
80107b0c:	68 46 ad 10 80       	push   $0x8010ad46
80107b11:	e8 93 8a ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107b16:	8b 45 08             	mov    0x8(%ebp),%eax
80107b19:	8b 40 08             	mov    0x8(%eax),%eax
80107b1c:	85 c0                	test   %eax,%eax
80107b1e:	75 0d                	jne    80107b2d <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107b20:	83 ec 0c             	sub    $0xc,%esp
80107b23:	68 5c ad 10 80       	push   $0x8010ad5c
80107b28:	e8 7c 8a ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80107b30:	8b 40 04             	mov    0x4(%eax),%eax
80107b33:	85 c0                	test   %eax,%eax
80107b35:	75 0d                	jne    80107b44 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107b37:	83 ec 0c             	sub    $0xc,%esp
80107b3a:	68 71 ad 10 80       	push   $0x8010ad71
80107b3f:	e8 65 8a ff ff       	call   801005a9 <panic>

  pushcli();
80107b44:	e8 08 d2 ff ff       	call   80104d51 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107b49:	e8 98 be ff ff       	call   801039e6 <mycpu>
80107b4e:	89 c3                	mov    %eax,%ebx
80107b50:	e8 91 be ff ff       	call   801039e6 <mycpu>
80107b55:	83 c0 08             	add    $0x8,%eax
80107b58:	89 c6                	mov    %eax,%esi
80107b5a:	e8 87 be ff ff       	call   801039e6 <mycpu>
80107b5f:	83 c0 08             	add    $0x8,%eax
80107b62:	c1 e8 10             	shr    $0x10,%eax
80107b65:	88 45 f7             	mov    %al,-0x9(%ebp)
80107b68:	e8 79 be ff ff       	call   801039e6 <mycpu>
80107b6d:	83 c0 08             	add    $0x8,%eax
80107b70:	c1 e8 18             	shr    $0x18,%eax
80107b73:	89 c2                	mov    %eax,%edx
80107b75:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107b7c:	67 00 
80107b7e:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107b85:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107b89:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107b8f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b96:	83 e0 f0             	and    $0xfffffff0,%eax
80107b99:	83 c8 09             	or     $0x9,%eax
80107b9c:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ba2:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ba9:	83 c8 10             	or     $0x10,%eax
80107bac:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bb2:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107bb9:	83 e0 9f             	and    $0xffffff9f,%eax
80107bbc:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bc2:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107bc9:	83 c8 80             	or     $0xffffff80,%eax
80107bcc:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bd2:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107bd9:	83 e0 f0             	and    $0xfffffff0,%eax
80107bdc:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107be2:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107be9:	83 e0 ef             	and    $0xffffffef,%eax
80107bec:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107bf2:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107bf9:	83 e0 df             	and    $0xffffffdf,%eax
80107bfc:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c02:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c09:	83 c8 40             	or     $0x40,%eax
80107c0c:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c12:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c19:	83 e0 7f             	and    $0x7f,%eax
80107c1c:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c22:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107c28:	e8 b9 bd ff ff       	call   801039e6 <mycpu>
80107c2d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c34:	83 e2 ef             	and    $0xffffffef,%edx
80107c37:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107c3d:	e8 a4 bd ff ff       	call   801039e6 <mycpu>
80107c42:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107c48:	8b 45 08             	mov    0x8(%ebp),%eax
80107c4b:	8b 40 08             	mov    0x8(%eax),%eax
80107c4e:	89 c3                	mov    %eax,%ebx
80107c50:	e8 91 bd ff ff       	call   801039e6 <mycpu>
80107c55:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107c5b:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107c5e:	e8 83 bd ff ff       	call   801039e6 <mycpu>
80107c63:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107c69:	83 ec 0c             	sub    $0xc,%esp
80107c6c:	6a 28                	push   $0x28
80107c6e:	e8 cc f8 ff ff       	call   8010753f <ltr>
80107c73:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107c76:	8b 45 08             	mov    0x8(%ebp),%eax
80107c79:	8b 40 04             	mov    0x4(%eax),%eax
80107c7c:	05 00 00 00 80       	add    $0x80000000,%eax
80107c81:	83 ec 0c             	sub    $0xc,%esp
80107c84:	50                   	push   %eax
80107c85:	e8 cc f8 ff ff       	call   80107556 <lcr3>
80107c8a:	83 c4 10             	add    $0x10,%esp
  popcli();
80107c8d:	e8 0c d1 ff ff       	call   80104d9e <popcli>
}
80107c92:	90                   	nop
80107c93:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107c96:	5b                   	pop    %ebx
80107c97:	5e                   	pop    %esi
80107c98:	5d                   	pop    %ebp
80107c99:	c3                   	ret    

80107c9a <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c9a:	55                   	push   %ebp
80107c9b:	89 e5                	mov    %esp,%ebp
80107c9d:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107ca0:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107ca7:	76 0d                	jbe    80107cb6 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107ca9:	83 ec 0c             	sub    $0xc,%esp
80107cac:	68 85 ad 10 80       	push   $0x8010ad85
80107cb1:	e8 f3 88 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107cb6:	e8 e5 aa ff ff       	call   801027a0 <kalloc>
80107cbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107cbe:	83 ec 04             	sub    $0x4,%esp
80107cc1:	68 00 10 00 00       	push   $0x1000
80107cc6:	6a 00                	push   $0x0
80107cc8:	ff 75 f4             	push   -0xc(%ebp)
80107ccb:	e8 8c d1 ff ff       	call   80104e5c <memset>
80107cd0:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	05 00 00 00 80       	add    $0x80000000,%eax
80107cdb:	83 ec 0c             	sub    $0xc,%esp
80107cde:	6a 06                	push   $0x6
80107ce0:	50                   	push   %eax
80107ce1:	68 00 10 00 00       	push   $0x1000
80107ce6:	6a 00                	push   $0x0
80107ce8:	ff 75 08             	push   0x8(%ebp)
80107ceb:	e8 5e fc ff ff       	call   8010794e <mappages>
80107cf0:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107cf3:	83 ec 04             	sub    $0x4,%esp
80107cf6:	ff 75 10             	push   0x10(%ebp)
80107cf9:	ff 75 0c             	push   0xc(%ebp)
80107cfc:	ff 75 f4             	push   -0xc(%ebp)
80107cff:	e8 17 d2 ff ff       	call   80104f1b <memmove>
80107d04:	83 c4 10             	add    $0x10,%esp
}
80107d07:	90                   	nop
80107d08:	c9                   	leave  
80107d09:	c3                   	ret    

80107d0a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107d0a:	55                   	push   %ebp
80107d0b:	89 e5                	mov    %esp,%ebp
80107d0d:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107d10:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d13:	25 ff 0f 00 00       	and    $0xfff,%eax
80107d18:	85 c0                	test   %eax,%eax
80107d1a:	74 0d                	je     80107d29 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107d1c:	83 ec 0c             	sub    $0xc,%esp
80107d1f:	68 a0 ad 10 80       	push   $0x8010ada0
80107d24:	e8 80 88 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107d29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d30:	e9 8f 00 00 00       	jmp    80107dc4 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107d35:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3b:	01 d0                	add    %edx,%eax
80107d3d:	83 ec 04             	sub    $0x4,%esp
80107d40:	6a 00                	push   $0x0
80107d42:	50                   	push   %eax
80107d43:	ff 75 08             	push   0x8(%ebp)
80107d46:	e8 6d fb ff ff       	call   801078b8 <walkpgdir>
80107d4b:	83 c4 10             	add    $0x10,%esp
80107d4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d51:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d55:	75 0d                	jne    80107d64 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107d57:	83 ec 0c             	sub    $0xc,%esp
80107d5a:	68 c3 ad 10 80       	push   $0x8010adc3
80107d5f:	e8 45 88 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107d64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d67:	8b 00                	mov    (%eax),%eax
80107d69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107d71:	8b 45 18             	mov    0x18(%ebp),%eax
80107d74:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d77:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d7c:	77 0b                	ja     80107d89 <loaduvm+0x7f>
      n = sz - i;
80107d7e:	8b 45 18             	mov    0x18(%ebp),%eax
80107d81:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d84:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d87:	eb 07                	jmp    80107d90 <loaduvm+0x86>
    else
      n = PGSIZE;
80107d89:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107d90:	8b 55 14             	mov    0x14(%ebp),%edx
80107d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d96:	01 d0                	add    %edx,%eax
80107d98:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107d9b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107da1:	ff 75 f0             	push   -0x10(%ebp)
80107da4:	50                   	push   %eax
80107da5:	52                   	push   %edx
80107da6:	ff 75 10             	push   0x10(%ebp)
80107da9:	e8 28 a1 ff ff       	call   80101ed6 <readi>
80107dae:	83 c4 10             	add    $0x10,%esp
80107db1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107db4:	74 07                	je     80107dbd <loaduvm+0xb3>
      return -1;
80107db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107dbb:	eb 18                	jmp    80107dd5 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107dbd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc7:	3b 45 18             	cmp    0x18(%ebp),%eax
80107dca:	0f 82 65 ff ff ff    	jb     80107d35 <loaduvm+0x2b>
  }
  return 0;
80107dd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107dd5:	c9                   	leave  
80107dd6:	c3                   	ret    

80107dd7 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107dd7:	55                   	push   %ebp
80107dd8:	89 e5                	mov    %esp,%ebp
80107dda:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107ddd:	8b 45 10             	mov    0x10(%ebp),%eax
80107de0:	85 c0                	test   %eax,%eax
80107de2:	79 0a                	jns    80107dee <allocuvm+0x17>
    return 0;
80107de4:	b8 00 00 00 00       	mov    $0x0,%eax
80107de9:	e9 ec 00 00 00       	jmp    80107eda <allocuvm+0x103>
  if(newsz < oldsz)
80107dee:	8b 45 10             	mov    0x10(%ebp),%eax
80107df1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107df4:	73 08                	jae    80107dfe <allocuvm+0x27>
    return oldsz;
80107df6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107df9:	e9 dc 00 00 00       	jmp    80107eda <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e01:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107e0e:	e9 b8 00 00 00       	jmp    80107ecb <allocuvm+0xf4>
    mem = kalloc();
80107e13:	e8 88 a9 ff ff       	call   801027a0 <kalloc>
80107e18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107e1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e1f:	75 2e                	jne    80107e4f <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107e21:	83 ec 0c             	sub    $0xc,%esp
80107e24:	68 e1 ad 10 80       	push   $0x8010ade1
80107e29:	e8 c6 85 ff ff       	call   801003f4 <cprintf>
80107e2e:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e31:	83 ec 04             	sub    $0x4,%esp
80107e34:	ff 75 0c             	push   0xc(%ebp)
80107e37:	ff 75 10             	push   0x10(%ebp)
80107e3a:	ff 75 08             	push   0x8(%ebp)
80107e3d:	e8 9a 00 00 00       	call   80107edc <deallocuvm>
80107e42:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e45:	b8 00 00 00 00       	mov    $0x0,%eax
80107e4a:	e9 8b 00 00 00       	jmp    80107eda <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107e4f:	83 ec 04             	sub    $0x4,%esp
80107e52:	68 00 10 00 00       	push   $0x1000
80107e57:	6a 00                	push   $0x0
80107e59:	ff 75 f0             	push   -0x10(%ebp)
80107e5c:	e8 fb cf ff ff       	call   80104e5c <memset>
80107e61:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107e64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e67:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	83 ec 0c             	sub    $0xc,%esp
80107e73:	6a 06                	push   $0x6
80107e75:	52                   	push   %edx
80107e76:	68 00 10 00 00       	push   $0x1000
80107e7b:	50                   	push   %eax
80107e7c:	ff 75 08             	push   0x8(%ebp)
80107e7f:	e8 ca fa ff ff       	call   8010794e <mappages>
80107e84:	83 c4 20             	add    $0x20,%esp
80107e87:	85 c0                	test   %eax,%eax
80107e89:	79 39                	jns    80107ec4 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107e8b:	83 ec 0c             	sub    $0xc,%esp
80107e8e:	68 f9 ad 10 80       	push   $0x8010adf9
80107e93:	e8 5c 85 ff ff       	call   801003f4 <cprintf>
80107e98:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e9b:	83 ec 04             	sub    $0x4,%esp
80107e9e:	ff 75 0c             	push   0xc(%ebp)
80107ea1:	ff 75 10             	push   0x10(%ebp)
80107ea4:	ff 75 08             	push   0x8(%ebp)
80107ea7:	e8 30 00 00 00       	call   80107edc <deallocuvm>
80107eac:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107eaf:	83 ec 0c             	sub    $0xc,%esp
80107eb2:	ff 75 f0             	push   -0x10(%ebp)
80107eb5:	e8 4c a8 ff ff       	call   80102706 <kfree>
80107eba:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ebd:	b8 00 00 00 00       	mov    $0x0,%eax
80107ec2:	eb 16                	jmp    80107eda <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107ec4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ece:	3b 45 10             	cmp    0x10(%ebp),%eax
80107ed1:	0f 82 3c ff ff ff    	jb     80107e13 <allocuvm+0x3c>
    }
  }
  return newsz;
80107ed7:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107eda:	c9                   	leave  
80107edb:	c3                   	ret    

80107edc <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107edc:	55                   	push   %ebp
80107edd:	89 e5                	mov    %esp,%ebp
80107edf:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107ee2:	8b 45 10             	mov    0x10(%ebp),%eax
80107ee5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ee8:	72 08                	jb     80107ef2 <deallocuvm+0x16>
    return oldsz;
80107eea:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eed:	e9 ac 00 00 00       	jmp    80107f9e <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107ef2:	8b 45 10             	mov    0x10(%ebp),%eax
80107ef5:	05 ff 0f 00 00       	add    $0xfff,%eax
80107efa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107f02:	e9 88 00 00 00       	jmp    80107f8f <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0a:	83 ec 04             	sub    $0x4,%esp
80107f0d:	6a 00                	push   $0x0
80107f0f:	50                   	push   %eax
80107f10:	ff 75 08             	push   0x8(%ebp)
80107f13:	e8 a0 f9 ff ff       	call   801078b8 <walkpgdir>
80107f18:	83 c4 10             	add    $0x10,%esp
80107f1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107f1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f22:	75 16                	jne    80107f3a <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f27:	c1 e8 16             	shr    $0x16,%eax
80107f2a:	83 c0 01             	add    $0x1,%eax
80107f2d:	c1 e0 16             	shl    $0x16,%eax
80107f30:	2d 00 10 00 00       	sub    $0x1000,%eax
80107f35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f38:	eb 4e                	jmp    80107f88 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107f3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f3d:	8b 00                	mov    (%eax),%eax
80107f3f:	83 e0 01             	and    $0x1,%eax
80107f42:	85 c0                	test   %eax,%eax
80107f44:	74 42                	je     80107f88 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f49:	8b 00                	mov    (%eax),%eax
80107f4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f50:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107f53:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f57:	75 0d                	jne    80107f66 <deallocuvm+0x8a>
        panic("kfree");
80107f59:	83 ec 0c             	sub    $0xc,%esp
80107f5c:	68 15 ae 10 80       	push   $0x8010ae15
80107f61:	e8 43 86 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107f66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f69:	05 00 00 00 80       	add    $0x80000000,%eax
80107f6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107f71:	83 ec 0c             	sub    $0xc,%esp
80107f74:	ff 75 e8             	push   -0x18(%ebp)
80107f77:	e8 8a a7 ff ff       	call   80102706 <kfree>
80107f7c:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107f88:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f92:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f95:	0f 82 6c ff ff ff    	jb     80107f07 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107f9b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f9e:	c9                   	leave  
80107f9f:	c3                   	ret    

80107fa0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107fa0:	55                   	push   %ebp
80107fa1:	89 e5                	mov    %esp,%ebp
80107fa3:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107fa6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107faa:	75 0d                	jne    80107fb9 <freevm+0x19>
    panic("freevm: no pgdir");
80107fac:	83 ec 0c             	sub    $0xc,%esp
80107faf:	68 1b ae 10 80       	push   $0x8010ae1b
80107fb4:	e8 f0 85 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107fb9:	83 ec 04             	sub    $0x4,%esp
80107fbc:	6a 00                	push   $0x0
80107fbe:	68 00 00 00 80       	push   $0x80000000
80107fc3:	ff 75 08             	push   0x8(%ebp)
80107fc6:	e8 11 ff ff ff       	call   80107edc <deallocuvm>
80107fcb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fd5:	eb 48                	jmp    8010801f <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fda:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80107fe4:	01 d0                	add    %edx,%eax
80107fe6:	8b 00                	mov    (%eax),%eax
80107fe8:	83 e0 01             	and    $0x1,%eax
80107feb:	85 c0                	test   %eax,%eax
80107fed:	74 2c                	je     8010801b <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80107ffc:	01 d0                	add    %edx,%eax
80107ffe:	8b 00                	mov    (%eax),%eax
80108000:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108005:	05 00 00 00 80       	add    $0x80000000,%eax
8010800a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010800d:	83 ec 0c             	sub    $0xc,%esp
80108010:	ff 75 f0             	push   -0x10(%ebp)
80108013:	e8 ee a6 ff ff       	call   80102706 <kfree>
80108018:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010801b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010801f:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108026:	76 af                	jbe    80107fd7 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108028:	83 ec 0c             	sub    $0xc,%esp
8010802b:	ff 75 08             	push   0x8(%ebp)
8010802e:	e8 d3 a6 ff ff       	call   80102706 <kfree>
80108033:	83 c4 10             	add    $0x10,%esp
}
80108036:	90                   	nop
80108037:	c9                   	leave  
80108038:	c3                   	ret    

80108039 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108039:	55                   	push   %ebp
8010803a:	89 e5                	mov    %esp,%ebp
8010803c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010803f:	83 ec 04             	sub    $0x4,%esp
80108042:	6a 00                	push   $0x0
80108044:	ff 75 0c             	push   0xc(%ebp)
80108047:	ff 75 08             	push   0x8(%ebp)
8010804a:	e8 69 f8 ff ff       	call   801078b8 <walkpgdir>
8010804f:	83 c4 10             	add    $0x10,%esp
80108052:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108055:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108059:	75 0d                	jne    80108068 <clearpteu+0x2f>
    panic("clearpteu");
8010805b:	83 ec 0c             	sub    $0xc,%esp
8010805e:	68 2c ae 10 80       	push   $0x8010ae2c
80108063:	e8 41 85 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80108068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806b:	8b 00                	mov    (%eax),%eax
8010806d:	83 e0 fb             	and    $0xfffffffb,%eax
80108070:	89 c2                	mov    %eax,%edx
80108072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108075:	89 10                	mov    %edx,(%eax)
}
80108077:	90                   	nop
80108078:	c9                   	leave  
80108079:	c3                   	ret    

8010807a <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010807a:	55                   	push   %ebp
8010807b:	89 e5                	mov    %esp,%ebp
8010807d:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108080:	e8 59 f9 ff ff       	call   801079de <setupkvm>
80108085:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108088:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010808c:	75 0a                	jne    80108098 <copyuvm+0x1e>
    return 0;
8010808e:	b8 00 00 00 00       	mov    $0x0,%eax
80108093:	e9 eb 00 00 00       	jmp    80108183 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108098:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010809f:	e9 b7 00 00 00       	jmp    8010815b <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801080a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a7:	83 ec 04             	sub    $0x4,%esp
801080aa:	6a 00                	push   $0x0
801080ac:	50                   	push   %eax
801080ad:	ff 75 08             	push   0x8(%ebp)
801080b0:	e8 03 f8 ff ff       	call   801078b8 <walkpgdir>
801080b5:	83 c4 10             	add    $0x10,%esp
801080b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080bf:	75 0d                	jne    801080ce <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801080c1:	83 ec 0c             	sub    $0xc,%esp
801080c4:	68 36 ae 10 80       	push   $0x8010ae36
801080c9:	e8 db 84 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801080ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080d1:	8b 00                	mov    (%eax),%eax
801080d3:	83 e0 01             	and    $0x1,%eax
801080d6:	85 c0                	test   %eax,%eax
801080d8:	75 0d                	jne    801080e7 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801080da:	83 ec 0c             	sub    $0xc,%esp
801080dd:	68 50 ae 10 80       	push   $0x8010ae50
801080e2:	e8 c2 84 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801080e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080ea:	8b 00                	mov    (%eax),%eax
801080ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801080f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080f7:	8b 00                	mov    (%eax),%eax
801080f9:	25 ff 0f 00 00       	and    $0xfff,%eax
801080fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108101:	e8 9a a6 ff ff       	call   801027a0 <kalloc>
80108106:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108109:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010810d:	74 5d                	je     8010816c <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010810f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108112:	05 00 00 00 80       	add    $0x80000000,%eax
80108117:	83 ec 04             	sub    $0x4,%esp
8010811a:	68 00 10 00 00       	push   $0x1000
8010811f:	50                   	push   %eax
80108120:	ff 75 e0             	push   -0x20(%ebp)
80108123:	e8 f3 cd ff ff       	call   80104f1b <memmove>
80108128:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010812b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010812e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108131:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813a:	83 ec 0c             	sub    $0xc,%esp
8010813d:	52                   	push   %edx
8010813e:	51                   	push   %ecx
8010813f:	68 00 10 00 00       	push   $0x1000
80108144:	50                   	push   %eax
80108145:	ff 75 f0             	push   -0x10(%ebp)
80108148:	e8 01 f8 ff ff       	call   8010794e <mappages>
8010814d:	83 c4 20             	add    $0x20,%esp
80108150:	85 c0                	test   %eax,%eax
80108152:	78 1b                	js     8010816f <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80108154:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010815b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108161:	0f 82 3d ff ff ff    	jb     801080a4 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80108167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010816a:	eb 17                	jmp    80108183 <copyuvm+0x109>
      goto bad;
8010816c:	90                   	nop
8010816d:	eb 01                	jmp    80108170 <copyuvm+0xf6>
      goto bad;
8010816f:	90                   	nop

bad:
  freevm(d);
80108170:	83 ec 0c             	sub    $0xc,%esp
80108173:	ff 75 f0             	push   -0x10(%ebp)
80108176:	e8 25 fe ff ff       	call   80107fa0 <freevm>
8010817b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010817e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108183:	c9                   	leave  
80108184:	c3                   	ret    

80108185 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108185:	55                   	push   %ebp
80108186:	89 e5                	mov    %esp,%ebp
80108188:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010818b:	83 ec 04             	sub    $0x4,%esp
8010818e:	6a 00                	push   $0x0
80108190:	ff 75 0c             	push   0xc(%ebp)
80108193:	ff 75 08             	push   0x8(%ebp)
80108196:	e8 1d f7 ff ff       	call   801078b8 <walkpgdir>
8010819b:	83 c4 10             	add    $0x10,%esp
8010819e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801081a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a4:	8b 00                	mov    (%eax),%eax
801081a6:	83 e0 01             	and    $0x1,%eax
801081a9:	85 c0                	test   %eax,%eax
801081ab:	75 07                	jne    801081b4 <uva2ka+0x2f>
    return 0;
801081ad:	b8 00 00 00 00       	mov    $0x0,%eax
801081b2:	eb 22                	jmp    801081d6 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801081b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b7:	8b 00                	mov    (%eax),%eax
801081b9:	83 e0 04             	and    $0x4,%eax
801081bc:	85 c0                	test   %eax,%eax
801081be:	75 07                	jne    801081c7 <uva2ka+0x42>
    return 0;
801081c0:	b8 00 00 00 00       	mov    $0x0,%eax
801081c5:	eb 0f                	jmp    801081d6 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801081c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ca:	8b 00                	mov    (%eax),%eax
801081cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081d1:	05 00 00 00 80       	add    $0x80000000,%eax
}
801081d6:	c9                   	leave  
801081d7:	c3                   	ret    

801081d8 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801081d8:	55                   	push   %ebp
801081d9:	89 e5                	mov    %esp,%ebp
801081db:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801081de:	8b 45 10             	mov    0x10(%ebp),%eax
801081e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801081e4:	eb 7f                	jmp    80108265 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801081e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801081e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801081f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081f4:	83 ec 08             	sub    $0x8,%esp
801081f7:	50                   	push   %eax
801081f8:	ff 75 08             	push   0x8(%ebp)
801081fb:	e8 85 ff ff ff       	call   80108185 <uva2ka>
80108200:	83 c4 10             	add    $0x10,%esp
80108203:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108206:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010820a:	75 07                	jne    80108213 <copyout+0x3b>
      return -1;
8010820c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108211:	eb 61                	jmp    80108274 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108213:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108216:	2b 45 0c             	sub    0xc(%ebp),%eax
80108219:	05 00 10 00 00       	add    $0x1000,%eax
8010821e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108221:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108224:	3b 45 14             	cmp    0x14(%ebp),%eax
80108227:	76 06                	jbe    8010822f <copyout+0x57>
      n = len;
80108229:	8b 45 14             	mov    0x14(%ebp),%eax
8010822c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010822f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108232:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108235:	89 c2                	mov    %eax,%edx
80108237:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010823a:	01 d0                	add    %edx,%eax
8010823c:	83 ec 04             	sub    $0x4,%esp
8010823f:	ff 75 f0             	push   -0x10(%ebp)
80108242:	ff 75 f4             	push   -0xc(%ebp)
80108245:	50                   	push   %eax
80108246:	e8 d0 cc ff ff       	call   80104f1b <memmove>
8010824b:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010824e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108251:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108254:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108257:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010825a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010825d:	05 00 10 00 00       	add    $0x1000,%eax
80108262:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108265:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108269:	0f 85 77 ff ff ff    	jne    801081e6 <copyout+0xe>
  }
  return 0;
8010826f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108274:	c9                   	leave  
80108275:	c3                   	ret    

80108276 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108276:	55                   	push   %ebp
80108277:	89 e5                	mov    %esp,%ebp
80108279:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010827c:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108283:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108286:	8b 40 08             	mov    0x8(%eax),%eax
80108289:	05 00 00 00 80       	add    $0x80000000,%eax
8010828e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108291:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829b:	8b 40 24             	mov    0x24(%eax),%eax
8010829e:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
801082a3:	c7 05 90 79 19 80 00 	movl   $0x0,0x80197990
801082aa:	00 00 00 

  while(i<madt->len){
801082ad:	90                   	nop
801082ae:	e9 bd 00 00 00       	jmp    80108370 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
801082b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801082b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082b9:	01 d0                	add    %edx,%eax
801082bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801082be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c1:	0f b6 00             	movzbl (%eax),%eax
801082c4:	0f b6 c0             	movzbl %al,%eax
801082c7:	83 f8 05             	cmp    $0x5,%eax
801082ca:	0f 87 a0 00 00 00    	ja     80108370 <mpinit_uefi+0xfa>
801082d0:	8b 04 85 6c ae 10 80 	mov    -0x7fef5194(,%eax,4),%eax
801082d7:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801082d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801082df:	a1 90 79 19 80       	mov    0x80197990,%eax
801082e4:	83 f8 03             	cmp    $0x3,%eax
801082e7:	7f 28                	jg     80108311 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801082e9:	8b 15 90 79 19 80    	mov    0x80197990,%edx
801082ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082f2:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801082f6:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801082fc:	81 c2 c0 76 19 80    	add    $0x801976c0,%edx
80108302:	88 02                	mov    %al,(%edx)
          ncpu++;
80108304:	a1 90 79 19 80       	mov    0x80197990,%eax
80108309:	83 c0 01             	add    $0x1,%eax
8010830c:	a3 90 79 19 80       	mov    %eax,0x80197990
        }
        i += lapic_entry->record_len;
80108311:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108314:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108318:	0f b6 c0             	movzbl %al,%eax
8010831b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010831e:	eb 50                	jmp    80108370 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108320:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108323:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108326:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108329:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010832d:	a2 94 79 19 80       	mov    %al,0x80197994
        i += ioapic->record_len;
80108332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108335:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108339:	0f b6 c0             	movzbl %al,%eax
8010833c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010833f:	eb 2f                	jmp    80108370 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108341:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108344:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108347:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010834a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010834e:	0f b6 c0             	movzbl %al,%eax
80108351:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108354:	eb 1a                	jmp    80108370 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108356:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108359:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010835c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010835f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108363:	0f b6 c0             	movzbl %al,%eax
80108366:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108369:	eb 05                	jmp    80108370 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
8010836b:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010836f:	90                   	nop
  while(i<madt->len){
80108370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108373:	8b 40 04             	mov    0x4(%eax),%eax
80108376:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108379:	0f 82 34 ff ff ff    	jb     801082b3 <mpinit_uefi+0x3d>
    }
  }

}
8010837f:	90                   	nop
80108380:	90                   	nop
80108381:	c9                   	leave  
80108382:	c3                   	ret    

80108383 <inb>:
{
80108383:	55                   	push   %ebp
80108384:	89 e5                	mov    %esp,%ebp
80108386:	83 ec 14             	sub    $0x14,%esp
80108389:	8b 45 08             	mov    0x8(%ebp),%eax
8010838c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108390:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108394:	89 c2                	mov    %eax,%edx
80108396:	ec                   	in     (%dx),%al
80108397:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010839a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010839e:	c9                   	leave  
8010839f:	c3                   	ret    

801083a0 <outb>:
{
801083a0:	55                   	push   %ebp
801083a1:	89 e5                	mov    %esp,%ebp
801083a3:	83 ec 08             	sub    $0x8,%esp
801083a6:	8b 45 08             	mov    0x8(%ebp),%eax
801083a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801083ac:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801083b0:	89 d0                	mov    %edx,%eax
801083b2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801083b5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801083b9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801083bd:	ee                   	out    %al,(%dx)
}
801083be:	90                   	nop
801083bf:	c9                   	leave  
801083c0:	c3                   	ret    

801083c1 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801083c1:	55                   	push   %ebp
801083c2:	89 e5                	mov    %esp,%ebp
801083c4:	83 ec 28             	sub    $0x28,%esp
801083c7:	8b 45 08             	mov    0x8(%ebp),%eax
801083ca:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801083cd:	6a 00                	push   $0x0
801083cf:	68 fa 03 00 00       	push   $0x3fa
801083d4:	e8 c7 ff ff ff       	call   801083a0 <outb>
801083d9:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801083dc:	68 80 00 00 00       	push   $0x80
801083e1:	68 fb 03 00 00       	push   $0x3fb
801083e6:	e8 b5 ff ff ff       	call   801083a0 <outb>
801083eb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801083ee:	6a 0c                	push   $0xc
801083f0:	68 f8 03 00 00       	push   $0x3f8
801083f5:	e8 a6 ff ff ff       	call   801083a0 <outb>
801083fa:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801083fd:	6a 00                	push   $0x0
801083ff:	68 f9 03 00 00       	push   $0x3f9
80108404:	e8 97 ff ff ff       	call   801083a0 <outb>
80108409:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010840c:	6a 03                	push   $0x3
8010840e:	68 fb 03 00 00       	push   $0x3fb
80108413:	e8 88 ff ff ff       	call   801083a0 <outb>
80108418:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010841b:	6a 00                	push   $0x0
8010841d:	68 fc 03 00 00       	push   $0x3fc
80108422:	e8 79 ff ff ff       	call   801083a0 <outb>
80108427:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010842a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108431:	eb 11                	jmp    80108444 <uart_debug+0x83>
80108433:	83 ec 0c             	sub    $0xc,%esp
80108436:	6a 0a                	push   $0xa
80108438:	e8 fa a6 ff ff       	call   80102b37 <microdelay>
8010843d:	83 c4 10             	add    $0x10,%esp
80108440:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108444:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108448:	7f 1a                	jg     80108464 <uart_debug+0xa3>
8010844a:	83 ec 0c             	sub    $0xc,%esp
8010844d:	68 fd 03 00 00       	push   $0x3fd
80108452:	e8 2c ff ff ff       	call   80108383 <inb>
80108457:	83 c4 10             	add    $0x10,%esp
8010845a:	0f b6 c0             	movzbl %al,%eax
8010845d:	83 e0 20             	and    $0x20,%eax
80108460:	85 c0                	test   %eax,%eax
80108462:	74 cf                	je     80108433 <uart_debug+0x72>
  outb(COM1+0, p);
80108464:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108468:	0f b6 c0             	movzbl %al,%eax
8010846b:	83 ec 08             	sub    $0x8,%esp
8010846e:	50                   	push   %eax
8010846f:	68 f8 03 00 00       	push   $0x3f8
80108474:	e8 27 ff ff ff       	call   801083a0 <outb>
80108479:	83 c4 10             	add    $0x10,%esp
}
8010847c:	90                   	nop
8010847d:	c9                   	leave  
8010847e:	c3                   	ret    

8010847f <uart_debugs>:

void uart_debugs(char *p){
8010847f:	55                   	push   %ebp
80108480:	89 e5                	mov    %esp,%ebp
80108482:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108485:	eb 1b                	jmp    801084a2 <uart_debugs+0x23>
    uart_debug(*p++);
80108487:	8b 45 08             	mov    0x8(%ebp),%eax
8010848a:	8d 50 01             	lea    0x1(%eax),%edx
8010848d:	89 55 08             	mov    %edx,0x8(%ebp)
80108490:	0f b6 00             	movzbl (%eax),%eax
80108493:	0f be c0             	movsbl %al,%eax
80108496:	83 ec 0c             	sub    $0xc,%esp
80108499:	50                   	push   %eax
8010849a:	e8 22 ff ff ff       	call   801083c1 <uart_debug>
8010849f:	83 c4 10             	add    $0x10,%esp
  while(*p){
801084a2:	8b 45 08             	mov    0x8(%ebp),%eax
801084a5:	0f b6 00             	movzbl (%eax),%eax
801084a8:	84 c0                	test   %al,%al
801084aa:	75 db                	jne    80108487 <uart_debugs+0x8>
  }
}
801084ac:	90                   	nop
801084ad:	90                   	nop
801084ae:	c9                   	leave  
801084af:	c3                   	ret    

801084b0 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801084b0:	55                   	push   %ebp
801084b1:	89 e5                	mov    %esp,%ebp
801084b3:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801084b6:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801084bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084c0:	8b 50 14             	mov    0x14(%eax),%edx
801084c3:	8b 40 10             	mov    0x10(%eax),%eax
801084c6:	a3 98 79 19 80       	mov    %eax,0x80197998
  gpu.vram_size = boot_param->graphic_config.frame_size;
801084cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084ce:	8b 50 1c             	mov    0x1c(%eax),%edx
801084d1:	8b 40 18             	mov    0x18(%eax),%eax
801084d4:	a3 a0 79 19 80       	mov    %eax,0x801979a0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801084d9:	8b 15 a0 79 19 80    	mov    0x801979a0,%edx
801084df:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801084e4:	29 d0                	sub    %edx,%eax
801084e6:	a3 9c 79 19 80       	mov    %eax,0x8019799c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801084eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084ee:	8b 50 24             	mov    0x24(%eax),%edx
801084f1:	8b 40 20             	mov    0x20(%eax),%eax
801084f4:	a3 a4 79 19 80       	mov    %eax,0x801979a4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801084f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084fc:	8b 50 2c             	mov    0x2c(%eax),%edx
801084ff:	8b 40 28             	mov    0x28(%eax),%eax
80108502:	a3 a8 79 19 80       	mov    %eax,0x801979a8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108507:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010850a:	8b 50 34             	mov    0x34(%eax),%edx
8010850d:	8b 40 30             	mov    0x30(%eax),%eax
80108510:	a3 ac 79 19 80       	mov    %eax,0x801979ac
}
80108515:	90                   	nop
80108516:	c9                   	leave  
80108517:	c3                   	ret    

80108518 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108518:	55                   	push   %ebp
80108519:	89 e5                	mov    %esp,%ebp
8010851b:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010851e:	8b 15 ac 79 19 80    	mov    0x801979ac,%edx
80108524:	8b 45 0c             	mov    0xc(%ebp),%eax
80108527:	0f af d0             	imul   %eax,%edx
8010852a:	8b 45 08             	mov    0x8(%ebp),%eax
8010852d:	01 d0                	add    %edx,%eax
8010852f:	c1 e0 02             	shl    $0x2,%eax
80108532:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108535:	8b 15 9c 79 19 80    	mov    0x8019799c,%edx
8010853b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010853e:	01 d0                	add    %edx,%eax
80108540:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108543:	8b 45 10             	mov    0x10(%ebp),%eax
80108546:	0f b6 10             	movzbl (%eax),%edx
80108549:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010854c:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010854e:	8b 45 10             	mov    0x10(%ebp),%eax
80108551:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108555:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108558:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010855b:	8b 45 10             	mov    0x10(%ebp),%eax
8010855e:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108562:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108565:	88 50 02             	mov    %dl,0x2(%eax)
}
80108568:	90                   	nop
80108569:	c9                   	leave  
8010856a:	c3                   	ret    

8010856b <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010856b:	55                   	push   %ebp
8010856c:	89 e5                	mov    %esp,%ebp
8010856e:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108571:	8b 15 ac 79 19 80    	mov    0x801979ac,%edx
80108577:	8b 45 08             	mov    0x8(%ebp),%eax
8010857a:	0f af c2             	imul   %edx,%eax
8010857d:	c1 e0 02             	shl    $0x2,%eax
80108580:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108583:	a1 a0 79 19 80       	mov    0x801979a0,%eax
80108588:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010858b:	29 d0                	sub    %edx,%eax
8010858d:	8b 0d 9c 79 19 80    	mov    0x8019799c,%ecx
80108593:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108596:	01 ca                	add    %ecx,%edx
80108598:	89 d1                	mov    %edx,%ecx
8010859a:	8b 15 9c 79 19 80    	mov    0x8019799c,%edx
801085a0:	83 ec 04             	sub    $0x4,%esp
801085a3:	50                   	push   %eax
801085a4:	51                   	push   %ecx
801085a5:	52                   	push   %edx
801085a6:	e8 70 c9 ff ff       	call   80104f1b <memmove>
801085ab:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801085ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b1:	8b 0d 9c 79 19 80    	mov    0x8019799c,%ecx
801085b7:	8b 15 a0 79 19 80    	mov    0x801979a0,%edx
801085bd:	01 ca                	add    %ecx,%edx
801085bf:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801085c2:	29 ca                	sub    %ecx,%edx
801085c4:	83 ec 04             	sub    $0x4,%esp
801085c7:	50                   	push   %eax
801085c8:	6a 00                	push   $0x0
801085ca:	52                   	push   %edx
801085cb:	e8 8c c8 ff ff       	call   80104e5c <memset>
801085d0:	83 c4 10             	add    $0x10,%esp
}
801085d3:	90                   	nop
801085d4:	c9                   	leave  
801085d5:	c3                   	ret    

801085d6 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801085d6:	55                   	push   %ebp
801085d7:	89 e5                	mov    %esp,%ebp
801085d9:	53                   	push   %ebx
801085da:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801085dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085e4:	e9 b1 00 00 00       	jmp    8010869a <font_render+0xc4>
    for(int j=14;j>-1;j--){
801085e9:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801085f0:	e9 97 00 00 00       	jmp    8010868c <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801085f5:	8b 45 10             	mov    0x10(%ebp),%eax
801085f8:	83 e8 20             	sub    $0x20,%eax
801085fb:	6b d0 1e             	imul   $0x1e,%eax,%edx
801085fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108601:	01 d0                	add    %edx,%eax
80108603:	0f b7 84 00 a0 ae 10 	movzwl -0x7fef5160(%eax,%eax,1),%eax
8010860a:	80 
8010860b:	0f b7 d0             	movzwl %ax,%edx
8010860e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108611:	bb 01 00 00 00       	mov    $0x1,%ebx
80108616:	89 c1                	mov    %eax,%ecx
80108618:	d3 e3                	shl    %cl,%ebx
8010861a:	89 d8                	mov    %ebx,%eax
8010861c:	21 d0                	and    %edx,%eax
8010861e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108624:	ba 01 00 00 00       	mov    $0x1,%edx
80108629:	89 c1                	mov    %eax,%ecx
8010862b:	d3 e2                	shl    %cl,%edx
8010862d:	89 d0                	mov    %edx,%eax
8010862f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108632:	75 2b                	jne    8010865f <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108634:	8b 55 0c             	mov    0xc(%ebp),%edx
80108637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863a:	01 c2                	add    %eax,%edx
8010863c:	b8 0e 00 00 00       	mov    $0xe,%eax
80108641:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108644:	89 c1                	mov    %eax,%ecx
80108646:	8b 45 08             	mov    0x8(%ebp),%eax
80108649:	01 c8                	add    %ecx,%eax
8010864b:	83 ec 04             	sub    $0x4,%esp
8010864e:	68 20 f5 10 80       	push   $0x8010f520
80108653:	52                   	push   %edx
80108654:	50                   	push   %eax
80108655:	e8 be fe ff ff       	call   80108518 <graphic_draw_pixel>
8010865a:	83 c4 10             	add    $0x10,%esp
8010865d:	eb 29                	jmp    80108688 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010865f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108665:	01 c2                	add    %eax,%edx
80108667:	b8 0e 00 00 00       	mov    $0xe,%eax
8010866c:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010866f:	89 c1                	mov    %eax,%ecx
80108671:	8b 45 08             	mov    0x8(%ebp),%eax
80108674:	01 c8                	add    %ecx,%eax
80108676:	83 ec 04             	sub    $0x4,%esp
80108679:	68 b0 79 19 80       	push   $0x801979b0
8010867e:	52                   	push   %edx
8010867f:	50                   	push   %eax
80108680:	e8 93 fe ff ff       	call   80108518 <graphic_draw_pixel>
80108685:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108688:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010868c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108690:	0f 89 5f ff ff ff    	jns    801085f5 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108696:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010869a:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010869e:	0f 8e 45 ff ff ff    	jle    801085e9 <font_render+0x13>
      }
    }
  }
}
801086a4:	90                   	nop
801086a5:	90                   	nop
801086a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086a9:	c9                   	leave  
801086aa:	c3                   	ret    

801086ab <font_render_string>:

void font_render_string(char *string,int row){
801086ab:	55                   	push   %ebp
801086ac:	89 e5                	mov    %esp,%ebp
801086ae:	53                   	push   %ebx
801086af:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801086b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801086b9:	eb 33                	jmp    801086ee <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801086bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086be:	8b 45 08             	mov    0x8(%ebp),%eax
801086c1:	01 d0                	add    %edx,%eax
801086c3:	0f b6 00             	movzbl (%eax),%eax
801086c6:	0f be c8             	movsbl %al,%ecx
801086c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801086cc:	6b d0 1e             	imul   $0x1e,%eax,%edx
801086cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801086d2:	89 d8                	mov    %ebx,%eax
801086d4:	c1 e0 04             	shl    $0x4,%eax
801086d7:	29 d8                	sub    %ebx,%eax
801086d9:	83 c0 02             	add    $0x2,%eax
801086dc:	83 ec 04             	sub    $0x4,%esp
801086df:	51                   	push   %ecx
801086e0:	52                   	push   %edx
801086e1:	50                   	push   %eax
801086e2:	e8 ef fe ff ff       	call   801085d6 <font_render>
801086e7:	83 c4 10             	add    $0x10,%esp
    i++;
801086ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801086ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086f1:	8b 45 08             	mov    0x8(%ebp),%eax
801086f4:	01 d0                	add    %edx,%eax
801086f6:	0f b6 00             	movzbl (%eax),%eax
801086f9:	84 c0                	test   %al,%al
801086fb:	74 06                	je     80108703 <font_render_string+0x58>
801086fd:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108701:	7e b8                	jle    801086bb <font_render_string+0x10>
  }
}
80108703:	90                   	nop
80108704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108707:	c9                   	leave  
80108708:	c3                   	ret    

80108709 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108709:	55                   	push   %ebp
8010870a:	89 e5                	mov    %esp,%ebp
8010870c:	53                   	push   %ebx
8010870d:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108710:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108717:	eb 6b                	jmp    80108784 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108719:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108720:	eb 58                	jmp    8010877a <pci_init+0x71>
      for(int k=0;k<8;k++){
80108722:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108729:	eb 45                	jmp    80108770 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010872b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010872e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108734:	83 ec 0c             	sub    $0xc,%esp
80108737:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010873a:	53                   	push   %ebx
8010873b:	6a 00                	push   $0x0
8010873d:	51                   	push   %ecx
8010873e:	52                   	push   %edx
8010873f:	50                   	push   %eax
80108740:	e8 b0 00 00 00       	call   801087f5 <pci_access_config>
80108745:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108748:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010874b:	0f b7 c0             	movzwl %ax,%eax
8010874e:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108753:	74 17                	je     8010876c <pci_init+0x63>
        pci_init_device(i,j,k);
80108755:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108758:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010875b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875e:	83 ec 04             	sub    $0x4,%esp
80108761:	51                   	push   %ecx
80108762:	52                   	push   %edx
80108763:	50                   	push   %eax
80108764:	e8 37 01 00 00       	call   801088a0 <pci_init_device>
80108769:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
8010876c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108770:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108774:	7e b5                	jle    8010872b <pci_init+0x22>
    for(int j=0;j<32;j++){
80108776:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010877a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010877e:	7e a2                	jle    80108722 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108780:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108784:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010878b:	7e 8c                	jle    80108719 <pci_init+0x10>
      }
      }
    }
  }
}
8010878d:	90                   	nop
8010878e:	90                   	nop
8010878f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108792:	c9                   	leave  
80108793:	c3                   	ret    

80108794 <pci_write_config>:

void pci_write_config(uint config){
80108794:	55                   	push   %ebp
80108795:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108797:	8b 45 08             	mov    0x8(%ebp),%eax
8010879a:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010879f:	89 c0                	mov    %eax,%eax
801087a1:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801087a2:	90                   	nop
801087a3:	5d                   	pop    %ebp
801087a4:	c3                   	ret    

801087a5 <pci_write_data>:

void pci_write_data(uint config){
801087a5:	55                   	push   %ebp
801087a6:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801087a8:	8b 45 08             	mov    0x8(%ebp),%eax
801087ab:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801087b0:	89 c0                	mov    %eax,%eax
801087b2:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801087b3:	90                   	nop
801087b4:	5d                   	pop    %ebp
801087b5:	c3                   	ret    

801087b6 <pci_read_config>:
uint pci_read_config(){
801087b6:	55                   	push   %ebp
801087b7:	89 e5                	mov    %esp,%ebp
801087b9:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801087bc:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801087c1:	ed                   	in     (%dx),%eax
801087c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801087c5:	83 ec 0c             	sub    $0xc,%esp
801087c8:	68 c8 00 00 00       	push   $0xc8
801087cd:	e8 65 a3 ff ff       	call   80102b37 <microdelay>
801087d2:	83 c4 10             	add    $0x10,%esp
  return data;
801087d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801087d8:	c9                   	leave  
801087d9:	c3                   	ret    

801087da <pci_test>:


void pci_test(){
801087da:	55                   	push   %ebp
801087db:	89 e5                	mov    %esp,%ebp
801087dd:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801087e0:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801087e7:	ff 75 fc             	push   -0x4(%ebp)
801087ea:	e8 a5 ff ff ff       	call   80108794 <pci_write_config>
801087ef:	83 c4 04             	add    $0x4,%esp
}
801087f2:	90                   	nop
801087f3:	c9                   	leave  
801087f4:	c3                   	ret    

801087f5 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801087f5:	55                   	push   %ebp
801087f6:	89 e5                	mov    %esp,%ebp
801087f8:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087fb:	8b 45 08             	mov    0x8(%ebp),%eax
801087fe:	c1 e0 10             	shl    $0x10,%eax
80108801:	25 00 00 ff 00       	and    $0xff0000,%eax
80108806:	89 c2                	mov    %eax,%edx
80108808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010880b:	c1 e0 0b             	shl    $0xb,%eax
8010880e:	0f b7 c0             	movzwl %ax,%eax
80108811:	09 c2                	or     %eax,%edx
80108813:	8b 45 10             	mov    0x10(%ebp),%eax
80108816:	c1 e0 08             	shl    $0x8,%eax
80108819:	25 00 07 00 00       	and    $0x700,%eax
8010881e:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108820:	8b 45 14             	mov    0x14(%ebp),%eax
80108823:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108828:	09 d0                	or     %edx,%eax
8010882a:	0d 00 00 00 80       	or     $0x80000000,%eax
8010882f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108832:	ff 75 f4             	push   -0xc(%ebp)
80108835:	e8 5a ff ff ff       	call   80108794 <pci_write_config>
8010883a:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010883d:	e8 74 ff ff ff       	call   801087b6 <pci_read_config>
80108842:	8b 55 18             	mov    0x18(%ebp),%edx
80108845:	89 02                	mov    %eax,(%edx)
}
80108847:	90                   	nop
80108848:	c9                   	leave  
80108849:	c3                   	ret    

8010884a <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010884a:	55                   	push   %ebp
8010884b:	89 e5                	mov    %esp,%ebp
8010884d:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108850:	8b 45 08             	mov    0x8(%ebp),%eax
80108853:	c1 e0 10             	shl    $0x10,%eax
80108856:	25 00 00 ff 00       	and    $0xff0000,%eax
8010885b:	89 c2                	mov    %eax,%edx
8010885d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108860:	c1 e0 0b             	shl    $0xb,%eax
80108863:	0f b7 c0             	movzwl %ax,%eax
80108866:	09 c2                	or     %eax,%edx
80108868:	8b 45 10             	mov    0x10(%ebp),%eax
8010886b:	c1 e0 08             	shl    $0x8,%eax
8010886e:	25 00 07 00 00       	and    $0x700,%eax
80108873:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108875:	8b 45 14             	mov    0x14(%ebp),%eax
80108878:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010887d:	09 d0                	or     %edx,%eax
8010887f:	0d 00 00 00 80       	or     $0x80000000,%eax
80108884:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108887:	ff 75 fc             	push   -0x4(%ebp)
8010888a:	e8 05 ff ff ff       	call   80108794 <pci_write_config>
8010888f:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108892:	ff 75 18             	push   0x18(%ebp)
80108895:	e8 0b ff ff ff       	call   801087a5 <pci_write_data>
8010889a:	83 c4 04             	add    $0x4,%esp
}
8010889d:	90                   	nop
8010889e:	c9                   	leave  
8010889f:	c3                   	ret    

801088a0 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801088a0:	55                   	push   %ebp
801088a1:	89 e5                	mov    %esp,%ebp
801088a3:	53                   	push   %ebx
801088a4:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801088a7:	8b 45 08             	mov    0x8(%ebp),%eax
801088aa:	a2 b4 79 19 80       	mov    %al,0x801979b4
  dev.device_num = device_num;
801088af:	8b 45 0c             	mov    0xc(%ebp),%eax
801088b2:	a2 b5 79 19 80       	mov    %al,0x801979b5
  dev.function_num = function_num;
801088b7:	8b 45 10             	mov    0x10(%ebp),%eax
801088ba:	a2 b6 79 19 80       	mov    %al,0x801979b6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801088bf:	ff 75 10             	push   0x10(%ebp)
801088c2:	ff 75 0c             	push   0xc(%ebp)
801088c5:	ff 75 08             	push   0x8(%ebp)
801088c8:	68 e4 c4 10 80       	push   $0x8010c4e4
801088cd:	e8 22 7b ff ff       	call   801003f4 <cprintf>
801088d2:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801088d5:	83 ec 0c             	sub    $0xc,%esp
801088d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088db:	50                   	push   %eax
801088dc:	6a 00                	push   $0x0
801088de:	ff 75 10             	push   0x10(%ebp)
801088e1:	ff 75 0c             	push   0xc(%ebp)
801088e4:	ff 75 08             	push   0x8(%ebp)
801088e7:	e8 09 ff ff ff       	call   801087f5 <pci_access_config>
801088ec:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801088ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088f2:	c1 e8 10             	shr    $0x10,%eax
801088f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801088f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088fb:	25 ff ff 00 00       	and    $0xffff,%eax
80108900:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108906:	a3 b8 79 19 80       	mov    %eax,0x801979b8
  dev.vendor_id = vendor_id;
8010890b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010890e:	a3 bc 79 19 80       	mov    %eax,0x801979bc
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108913:	83 ec 04             	sub    $0x4,%esp
80108916:	ff 75 f0             	push   -0x10(%ebp)
80108919:	ff 75 f4             	push   -0xc(%ebp)
8010891c:	68 18 c5 10 80       	push   $0x8010c518
80108921:	e8 ce 7a ff ff       	call   801003f4 <cprintf>
80108926:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108929:	83 ec 0c             	sub    $0xc,%esp
8010892c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010892f:	50                   	push   %eax
80108930:	6a 08                	push   $0x8
80108932:	ff 75 10             	push   0x10(%ebp)
80108935:	ff 75 0c             	push   0xc(%ebp)
80108938:	ff 75 08             	push   0x8(%ebp)
8010893b:	e8 b5 fe ff ff       	call   801087f5 <pci_access_config>
80108940:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108943:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108946:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108949:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010894c:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010894f:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108952:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108955:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108958:	0f b6 c0             	movzbl %al,%eax
8010895b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010895e:	c1 eb 18             	shr    $0x18,%ebx
80108961:	83 ec 0c             	sub    $0xc,%esp
80108964:	51                   	push   %ecx
80108965:	52                   	push   %edx
80108966:	50                   	push   %eax
80108967:	53                   	push   %ebx
80108968:	68 3c c5 10 80       	push   $0x8010c53c
8010896d:	e8 82 7a ff ff       	call   801003f4 <cprintf>
80108972:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108975:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108978:	c1 e8 18             	shr    $0x18,%eax
8010897b:	a2 c0 79 19 80       	mov    %al,0x801979c0
  dev.sub_class = (data>>16)&0xFF;
80108980:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108983:	c1 e8 10             	shr    $0x10,%eax
80108986:	a2 c1 79 19 80       	mov    %al,0x801979c1
  dev.interface = (data>>8)&0xFF;
8010898b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010898e:	c1 e8 08             	shr    $0x8,%eax
80108991:	a2 c2 79 19 80       	mov    %al,0x801979c2
  dev.revision_id = data&0xFF;
80108996:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108999:	a2 c3 79 19 80       	mov    %al,0x801979c3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010899e:	83 ec 0c             	sub    $0xc,%esp
801089a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089a4:	50                   	push   %eax
801089a5:	6a 10                	push   $0x10
801089a7:	ff 75 10             	push   0x10(%ebp)
801089aa:	ff 75 0c             	push   0xc(%ebp)
801089ad:	ff 75 08             	push   0x8(%ebp)
801089b0:	e8 40 fe ff ff       	call   801087f5 <pci_access_config>
801089b5:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801089b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089bb:	a3 c4 79 19 80       	mov    %eax,0x801979c4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801089c0:	83 ec 0c             	sub    $0xc,%esp
801089c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089c6:	50                   	push   %eax
801089c7:	6a 14                	push   $0x14
801089c9:	ff 75 10             	push   0x10(%ebp)
801089cc:	ff 75 0c             	push   0xc(%ebp)
801089cf:	ff 75 08             	push   0x8(%ebp)
801089d2:	e8 1e fe ff ff       	call   801087f5 <pci_access_config>
801089d7:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801089da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089dd:	a3 c8 79 19 80       	mov    %eax,0x801979c8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801089e2:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801089e9:	75 5a                	jne    80108a45 <pci_init_device+0x1a5>
801089eb:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801089f2:	75 51                	jne    80108a45 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801089f4:	83 ec 0c             	sub    $0xc,%esp
801089f7:	68 81 c5 10 80       	push   $0x8010c581
801089fc:	e8 f3 79 ff ff       	call   801003f4 <cprintf>
80108a01:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108a04:	83 ec 0c             	sub    $0xc,%esp
80108a07:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a0a:	50                   	push   %eax
80108a0b:	68 f0 00 00 00       	push   $0xf0
80108a10:	ff 75 10             	push   0x10(%ebp)
80108a13:	ff 75 0c             	push   0xc(%ebp)
80108a16:	ff 75 08             	push   0x8(%ebp)
80108a19:	e8 d7 fd ff ff       	call   801087f5 <pci_access_config>
80108a1e:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108a21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a24:	83 ec 08             	sub    $0x8,%esp
80108a27:	50                   	push   %eax
80108a28:	68 9b c5 10 80       	push   $0x8010c59b
80108a2d:	e8 c2 79 ff ff       	call   801003f4 <cprintf>
80108a32:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108a35:	83 ec 0c             	sub    $0xc,%esp
80108a38:	68 b4 79 19 80       	push   $0x801979b4
80108a3d:	e8 09 00 00 00       	call   80108a4b <i8254_init>
80108a42:	83 c4 10             	add    $0x10,%esp
  }
}
80108a45:	90                   	nop
80108a46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a49:	c9                   	leave  
80108a4a:	c3                   	ret    

80108a4b <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108a4b:	55                   	push   %ebp
80108a4c:	89 e5                	mov    %esp,%ebp
80108a4e:	53                   	push   %ebx
80108a4f:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108a52:	8b 45 08             	mov    0x8(%ebp),%eax
80108a55:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a59:	0f b6 c8             	movzbl %al,%ecx
80108a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80108a5f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a63:	0f b6 d0             	movzbl %al,%edx
80108a66:	8b 45 08             	mov    0x8(%ebp),%eax
80108a69:	0f b6 00             	movzbl (%eax),%eax
80108a6c:	0f b6 c0             	movzbl %al,%eax
80108a6f:	83 ec 0c             	sub    $0xc,%esp
80108a72:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108a75:	53                   	push   %ebx
80108a76:	6a 04                	push   $0x4
80108a78:	51                   	push   %ecx
80108a79:	52                   	push   %edx
80108a7a:	50                   	push   %eax
80108a7b:	e8 75 fd ff ff       	call   801087f5 <pci_access_config>
80108a80:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108a83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a86:	83 c8 04             	or     $0x4,%eax
80108a89:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108a8c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80108a92:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a96:	0f b6 c8             	movzbl %al,%ecx
80108a99:	8b 45 08             	mov    0x8(%ebp),%eax
80108a9c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108aa0:	0f b6 d0             	movzbl %al,%edx
80108aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80108aa6:	0f b6 00             	movzbl (%eax),%eax
80108aa9:	0f b6 c0             	movzbl %al,%eax
80108aac:	83 ec 0c             	sub    $0xc,%esp
80108aaf:	53                   	push   %ebx
80108ab0:	6a 04                	push   $0x4
80108ab2:	51                   	push   %ecx
80108ab3:	52                   	push   %edx
80108ab4:	50                   	push   %eax
80108ab5:	e8 90 fd ff ff       	call   8010884a <pci_write_config_register>
80108aba:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108abd:	8b 45 08             	mov    0x8(%ebp),%eax
80108ac0:	8b 40 10             	mov    0x10(%eax),%eax
80108ac3:	05 00 00 00 40       	add    $0x40000000,%eax
80108ac8:	a3 cc 79 19 80       	mov    %eax,0x801979cc
  uint *ctrl = (uint *)base_addr;
80108acd:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108ad5:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108ada:	05 d8 00 00 00       	add    $0xd8,%eax
80108adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ae5:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aee:	8b 00                	mov    (%eax),%eax
80108af0:	0d 00 00 00 04       	or     $0x4000000,%eax
80108af5:	89 c2                	mov    %eax,%edx
80108af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108afa:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aff:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b08:	8b 00                	mov    (%eax),%eax
80108b0a:	83 c8 40             	or     $0x40,%eax
80108b0d:	89 c2                	mov    %eax,%edx
80108b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b12:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b17:	8b 10                	mov    (%eax),%edx
80108b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1c:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108b1e:	83 ec 0c             	sub    $0xc,%esp
80108b21:	68 b0 c5 10 80       	push   $0x8010c5b0
80108b26:	e8 c9 78 ff ff       	call   801003f4 <cprintf>
80108b2b:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108b2e:	e8 6d 9c ff ff       	call   801027a0 <kalloc>
80108b33:	a3 d8 79 19 80       	mov    %eax,0x801979d8
  *intr_addr = 0;
80108b38:	a1 d8 79 19 80       	mov    0x801979d8,%eax
80108b3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108b43:	a1 d8 79 19 80       	mov    0x801979d8,%eax
80108b48:	83 ec 08             	sub    $0x8,%esp
80108b4b:	50                   	push   %eax
80108b4c:	68 d2 c5 10 80       	push   $0x8010c5d2
80108b51:	e8 9e 78 ff ff       	call   801003f4 <cprintf>
80108b56:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108b59:	e8 50 00 00 00       	call   80108bae <i8254_init_recv>
  i8254_init_send();
80108b5e:	e8 69 03 00 00       	call   80108ecc <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108b63:	0f b6 05 27 f5 10 80 	movzbl 0x8010f527,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b6a:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108b6d:	0f b6 05 26 f5 10 80 	movzbl 0x8010f526,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b74:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108b77:	0f b6 05 25 f5 10 80 	movzbl 0x8010f525,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b7e:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108b81:	0f b6 05 24 f5 10 80 	movzbl 0x8010f524,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b88:	0f b6 c0             	movzbl %al,%eax
80108b8b:	83 ec 0c             	sub    $0xc,%esp
80108b8e:	53                   	push   %ebx
80108b8f:	51                   	push   %ecx
80108b90:	52                   	push   %edx
80108b91:	50                   	push   %eax
80108b92:	68 e0 c5 10 80       	push   $0x8010c5e0
80108b97:	e8 58 78 ff ff       	call   801003f4 <cprintf>
80108b9c:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ba2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108ba8:	90                   	nop
80108ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108bac:	c9                   	leave  
80108bad:	c3                   	ret    

80108bae <i8254_init_recv>:

void i8254_init_recv(){
80108bae:	55                   	push   %ebp
80108baf:	89 e5                	mov    %esp,%ebp
80108bb1:	57                   	push   %edi
80108bb2:	56                   	push   %esi
80108bb3:	53                   	push   %ebx
80108bb4:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108bb7:	83 ec 0c             	sub    $0xc,%esp
80108bba:	6a 00                	push   $0x0
80108bbc:	e8 e8 04 00 00       	call   801090a9 <i8254_read_eeprom>
80108bc1:	83 c4 10             	add    $0x10,%esp
80108bc4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108bc7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108bca:	a2 d0 79 19 80       	mov    %al,0x801979d0
  mac_addr[1] = data_l>>8;
80108bcf:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108bd2:	c1 e8 08             	shr    $0x8,%eax
80108bd5:	a2 d1 79 19 80       	mov    %al,0x801979d1
  uint data_m = i8254_read_eeprom(0x1);
80108bda:	83 ec 0c             	sub    $0xc,%esp
80108bdd:	6a 01                	push   $0x1
80108bdf:	e8 c5 04 00 00       	call   801090a9 <i8254_read_eeprom>
80108be4:	83 c4 10             	add    $0x10,%esp
80108be7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108bea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bed:	a2 d2 79 19 80       	mov    %al,0x801979d2
  mac_addr[3] = data_m>>8;
80108bf2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bf5:	c1 e8 08             	shr    $0x8,%eax
80108bf8:	a2 d3 79 19 80       	mov    %al,0x801979d3
  uint data_h = i8254_read_eeprom(0x2);
80108bfd:	83 ec 0c             	sub    $0xc,%esp
80108c00:	6a 02                	push   $0x2
80108c02:	e8 a2 04 00 00       	call   801090a9 <i8254_read_eeprom>
80108c07:	83 c4 10             	add    $0x10,%esp
80108c0a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108c0d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c10:	a2 d4 79 19 80       	mov    %al,0x801979d4
  mac_addr[5] = data_h>>8;
80108c15:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c18:	c1 e8 08             	shr    $0x8,%eax
80108c1b:	a2 d5 79 19 80       	mov    %al,0x801979d5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108c20:	0f b6 05 d5 79 19 80 	movzbl 0x801979d5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c27:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108c2a:	0f b6 05 d4 79 19 80 	movzbl 0x801979d4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c31:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108c34:	0f b6 05 d3 79 19 80 	movzbl 0x801979d3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c3b:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108c3e:	0f b6 05 d2 79 19 80 	movzbl 0x801979d2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c45:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108c48:	0f b6 05 d1 79 19 80 	movzbl 0x801979d1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c4f:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108c52:	0f b6 05 d0 79 19 80 	movzbl 0x801979d0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c59:	0f b6 c0             	movzbl %al,%eax
80108c5c:	83 ec 04             	sub    $0x4,%esp
80108c5f:	57                   	push   %edi
80108c60:	56                   	push   %esi
80108c61:	53                   	push   %ebx
80108c62:	51                   	push   %ecx
80108c63:	52                   	push   %edx
80108c64:	50                   	push   %eax
80108c65:	68 f8 c5 10 80       	push   $0x8010c5f8
80108c6a:	e8 85 77 ff ff       	call   801003f4 <cprintf>
80108c6f:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108c72:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108c77:	05 00 54 00 00       	add    $0x5400,%eax
80108c7c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108c7f:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108c84:	05 04 54 00 00       	add    $0x5404,%eax
80108c89:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108c8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c8f:	c1 e0 10             	shl    $0x10,%eax
80108c92:	0b 45 d8             	or     -0x28(%ebp),%eax
80108c95:	89 c2                	mov    %eax,%edx
80108c97:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108c9a:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108c9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c9f:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ca4:	89 c2                	mov    %eax,%edx
80108ca6:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108ca9:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108cab:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108cb0:	05 00 52 00 00       	add    $0x5200,%eax
80108cb5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108cb8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108cbf:	eb 19                	jmp    80108cda <i8254_init_recv+0x12c>
    mta[i] = 0;
80108cc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108cc4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ccb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108cce:	01 d0                	add    %edx,%eax
80108cd0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108cd6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108cda:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108cde:	7e e1                	jle    80108cc1 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108ce0:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108ce5:	05 d0 00 00 00       	add    $0xd0,%eax
80108cea:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ced:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108cf0:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108cf6:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108cfb:	05 c8 00 00 00       	add    $0xc8,%eax
80108d00:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d03:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108d06:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108d0c:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d11:	05 28 28 00 00       	add    $0x2828,%eax
80108d16:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108d19:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108d1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108d22:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d27:	05 00 01 00 00       	add    $0x100,%eax
80108d2c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108d2f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d32:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108d38:	e8 63 9a ff ff       	call   801027a0 <kalloc>
80108d3d:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108d40:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d45:	05 00 28 00 00       	add    $0x2800,%eax
80108d4a:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108d4d:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d52:	05 04 28 00 00       	add    $0x2804,%eax
80108d57:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108d5a:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d5f:	05 08 28 00 00       	add    $0x2808,%eax
80108d64:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108d67:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d6c:	05 10 28 00 00       	add    $0x2810,%eax
80108d71:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d74:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108d79:	05 18 28 00 00       	add    $0x2818,%eax
80108d7e:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108d81:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d84:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d8a:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108d8d:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108d8f:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108d92:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108d98:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108d9b:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108da1:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108da4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108daa:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108dad:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108db3:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108db6:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108db9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108dc0:	eb 73                	jmp    80108e35 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108dc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dc5:	c1 e0 04             	shl    $0x4,%eax
80108dc8:	89 c2                	mov    %eax,%edx
80108dca:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dcd:	01 d0                	add    %edx,%eax
80108dcf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108dd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dd9:	c1 e0 04             	shl    $0x4,%eax
80108ddc:	89 c2                	mov    %eax,%edx
80108dde:	8b 45 98             	mov    -0x68(%ebp),%eax
80108de1:	01 d0                	add    %edx,%eax
80108de3:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dec:	c1 e0 04             	shl    $0x4,%eax
80108def:	89 c2                	mov    %eax,%edx
80108df1:	8b 45 98             	mov    -0x68(%ebp),%eax
80108df4:	01 d0                	add    %edx,%eax
80108df6:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108dfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dff:	c1 e0 04             	shl    $0x4,%eax
80108e02:	89 c2                	mov    %eax,%edx
80108e04:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e07:	01 d0                	add    %edx,%eax
80108e09:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108e0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e10:	c1 e0 04             	shl    $0x4,%eax
80108e13:	89 c2                	mov    %eax,%edx
80108e15:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e18:	01 d0                	add    %edx,%eax
80108e1a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108e1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e21:	c1 e0 04             	shl    $0x4,%eax
80108e24:	89 c2                	mov    %eax,%edx
80108e26:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e29:	01 d0                	add    %edx,%eax
80108e2b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108e31:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108e35:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108e3c:	7e 84                	jle    80108dc2 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e3e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108e45:	eb 57                	jmp    80108e9e <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108e47:	e8 54 99 ff ff       	call   801027a0 <kalloc>
80108e4c:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108e4f:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108e53:	75 12                	jne    80108e67 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108e55:	83 ec 0c             	sub    $0xc,%esp
80108e58:	68 18 c6 10 80       	push   $0x8010c618
80108e5d:	e8 92 75 ff ff       	call   801003f4 <cprintf>
80108e62:	83 c4 10             	add    $0x10,%esp
      break;
80108e65:	eb 3d                	jmp    80108ea4 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108e67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e6a:	c1 e0 04             	shl    $0x4,%eax
80108e6d:	89 c2                	mov    %eax,%edx
80108e6f:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e72:	01 d0                	add    %edx,%eax
80108e74:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e77:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e7d:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e82:	83 c0 01             	add    $0x1,%eax
80108e85:	c1 e0 04             	shl    $0x4,%eax
80108e88:	89 c2                	mov    %eax,%edx
80108e8a:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e8d:	01 d0                	add    %edx,%eax
80108e8f:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e92:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e98:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e9a:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108e9e:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108ea2:	7e a3                	jle    80108e47 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108ea4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ea7:	8b 00                	mov    (%eax),%eax
80108ea9:	83 c8 02             	or     $0x2,%eax
80108eac:	89 c2                	mov    %eax,%edx
80108eae:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108eb1:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108eb3:	83 ec 0c             	sub    $0xc,%esp
80108eb6:	68 38 c6 10 80       	push   $0x8010c638
80108ebb:	e8 34 75 ff ff       	call   801003f4 <cprintf>
80108ec0:	83 c4 10             	add    $0x10,%esp
}
80108ec3:	90                   	nop
80108ec4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108ec7:	5b                   	pop    %ebx
80108ec8:	5e                   	pop    %esi
80108ec9:	5f                   	pop    %edi
80108eca:	5d                   	pop    %ebp
80108ecb:	c3                   	ret    

80108ecc <i8254_init_send>:

void i8254_init_send(){
80108ecc:	55                   	push   %ebp
80108ecd:	89 e5                	mov    %esp,%ebp
80108ecf:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108ed2:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108ed7:	05 28 38 00 00       	add    $0x3828,%eax
80108edc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108edf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ee2:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108ee8:	e8 b3 98 ff ff       	call   801027a0 <kalloc>
80108eed:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108ef0:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108ef5:	05 00 38 00 00       	add    $0x3800,%eax
80108efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108efd:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108f02:	05 04 38 00 00       	add    $0x3804,%eax
80108f07:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108f0a:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108f0f:	05 08 38 00 00       	add    $0x3808,%eax
80108f14:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108f17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f1a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f23:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108f25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108f2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f31:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f37:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108f3c:	05 10 38 00 00       	add    $0x3810,%eax
80108f41:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f44:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80108f49:	05 18 38 00 00       	add    $0x3818,%eax
80108f4e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108f51:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108f54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108f5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108f63:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f66:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108f69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f70:	e9 82 00 00 00       	jmp    80108ff7 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f78:	c1 e0 04             	shl    $0x4,%eax
80108f7b:	89 c2                	mov    %eax,%edx
80108f7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f80:	01 d0                	add    %edx,%eax
80108f82:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f8c:	c1 e0 04             	shl    $0x4,%eax
80108f8f:	89 c2                	mov    %eax,%edx
80108f91:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f94:	01 d0                	add    %edx,%eax
80108f96:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9f:	c1 e0 04             	shl    $0x4,%eax
80108fa2:	89 c2                	mov    %eax,%edx
80108fa4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fa7:	01 d0                	add    %edx,%eax
80108fa9:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb0:	c1 e0 04             	shl    $0x4,%eax
80108fb3:	89 c2                	mov    %eax,%edx
80108fb5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fb8:	01 d0                	add    %edx,%eax
80108fba:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc1:	c1 e0 04             	shl    $0x4,%eax
80108fc4:	89 c2                	mov    %eax,%edx
80108fc6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fc9:	01 d0                	add    %edx,%eax
80108fcb:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd2:	c1 e0 04             	shl    $0x4,%eax
80108fd5:	89 c2                	mov    %eax,%edx
80108fd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fda:	01 d0                	add    %edx,%eax
80108fdc:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe3:	c1 e0 04             	shl    $0x4,%eax
80108fe6:	89 c2                	mov    %eax,%edx
80108fe8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108feb:	01 d0                	add    %edx,%eax
80108fed:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108ff3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ff7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108ffe:	0f 8e 71 ff ff ff    	jle    80108f75 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109004:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010900b:	eb 57                	jmp    80109064 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
8010900d:	e8 8e 97 ff ff       	call   801027a0 <kalloc>
80109012:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109015:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109019:	75 12                	jne    8010902d <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
8010901b:	83 ec 0c             	sub    $0xc,%esp
8010901e:	68 18 c6 10 80       	push   $0x8010c618
80109023:	e8 cc 73 ff ff       	call   801003f4 <cprintf>
80109028:	83 c4 10             	add    $0x10,%esp
      break;
8010902b:	eb 3d                	jmp    8010906a <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010902d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109030:	c1 e0 04             	shl    $0x4,%eax
80109033:	89 c2                	mov    %eax,%edx
80109035:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109038:	01 d0                	add    %edx,%eax
8010903a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010903d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109043:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109045:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109048:	83 c0 01             	add    $0x1,%eax
8010904b:	c1 e0 04             	shl    $0x4,%eax
8010904e:	89 c2                	mov    %eax,%edx
80109050:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109053:	01 d0                	add    %edx,%eax
80109055:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109058:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010905e:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109060:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109064:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109068:	7e a3                	jle    8010900d <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010906a:	a1 cc 79 19 80       	mov    0x801979cc,%eax
8010906f:	05 00 04 00 00       	add    $0x400,%eax
80109074:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109077:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010907a:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109080:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80109085:	05 10 04 00 00       	add    $0x410,%eax
8010908a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010908d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109090:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109096:	83 ec 0c             	sub    $0xc,%esp
80109099:	68 58 c6 10 80       	push   $0x8010c658
8010909e:	e8 51 73 ff ff       	call   801003f4 <cprintf>
801090a3:	83 c4 10             	add    $0x10,%esp

}
801090a6:	90                   	nop
801090a7:	c9                   	leave  
801090a8:	c3                   	ret    

801090a9 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801090a9:	55                   	push   %ebp
801090aa:	89 e5                	mov    %esp,%ebp
801090ac:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801090af:	a1 cc 79 19 80       	mov    0x801979cc,%eax
801090b4:	83 c0 14             	add    $0x14,%eax
801090b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801090ba:	8b 45 08             	mov    0x8(%ebp),%eax
801090bd:	c1 e0 08             	shl    $0x8,%eax
801090c0:	0f b7 c0             	movzwl %ax,%eax
801090c3:	83 c8 01             	or     $0x1,%eax
801090c6:	89 c2                	mov    %eax,%edx
801090c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090cb:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801090cd:	83 ec 0c             	sub    $0xc,%esp
801090d0:	68 78 c6 10 80       	push   $0x8010c678
801090d5:	e8 1a 73 ff ff       	call   801003f4 <cprintf>
801090da:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801090dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e0:	8b 00                	mov    (%eax),%eax
801090e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801090e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e8:	83 e0 10             	and    $0x10,%eax
801090eb:	85 c0                	test   %eax,%eax
801090ed:	75 02                	jne    801090f1 <i8254_read_eeprom+0x48>
  while(1){
801090ef:	eb dc                	jmp    801090cd <i8254_read_eeprom+0x24>
      break;
801090f1:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801090f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f5:	8b 00                	mov    (%eax),%eax
801090f7:	c1 e8 10             	shr    $0x10,%eax
}
801090fa:	c9                   	leave  
801090fb:	c3                   	ret    

801090fc <i8254_recv>:
void i8254_recv(){
801090fc:	55                   	push   %ebp
801090fd:	89 e5                	mov    %esp,%ebp
801090ff:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109102:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80109107:	05 10 28 00 00       	add    $0x2810,%eax
8010910c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010910f:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80109114:	05 18 28 00 00       	add    $0x2818,%eax
80109119:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010911c:	a1 cc 79 19 80       	mov    0x801979cc,%eax
80109121:	05 00 28 00 00       	add    $0x2800,%eax
80109126:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109129:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010912c:	8b 00                	mov    (%eax),%eax
8010912e:	05 00 00 00 80       	add    $0x80000000,%eax
80109133:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109139:	8b 10                	mov    (%eax),%edx
8010913b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010913e:	8b 08                	mov    (%eax),%ecx
80109140:	89 d0                	mov    %edx,%eax
80109142:	29 c8                	sub    %ecx,%eax
80109144:	25 ff 00 00 00       	and    $0xff,%eax
80109149:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
8010914c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109150:	7e 37                	jle    80109189 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109155:	8b 00                	mov    (%eax),%eax
80109157:	c1 e0 04             	shl    $0x4,%eax
8010915a:	89 c2                	mov    %eax,%edx
8010915c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010915f:	01 d0                	add    %edx,%eax
80109161:	8b 00                	mov    (%eax),%eax
80109163:	05 00 00 00 80       	add    $0x80000000,%eax
80109168:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
8010916b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010916e:	8b 00                	mov    (%eax),%eax
80109170:	83 c0 01             	add    $0x1,%eax
80109173:	0f b6 d0             	movzbl %al,%edx
80109176:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109179:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
8010917b:	83 ec 0c             	sub    $0xc,%esp
8010917e:	ff 75 e0             	push   -0x20(%ebp)
80109181:	e8 15 09 00 00       	call   80109a9b <eth_proc>
80109186:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109189:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010918c:	8b 10                	mov    (%eax),%edx
8010918e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109191:	8b 00                	mov    (%eax),%eax
80109193:	39 c2                	cmp    %eax,%edx
80109195:	75 9f                	jne    80109136 <i8254_recv+0x3a>
      (*rdt)--;
80109197:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010919a:	8b 00                	mov    (%eax),%eax
8010919c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010919f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a2:	89 10                	mov    %edx,(%eax)
  while(1){
801091a4:	eb 90                	jmp    80109136 <i8254_recv+0x3a>

801091a6 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801091a6:	55                   	push   %ebp
801091a7:	89 e5                	mov    %esp,%ebp
801091a9:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801091ac:	a1 cc 79 19 80       	mov    0x801979cc,%eax
801091b1:	05 10 38 00 00       	add    $0x3810,%eax
801091b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801091b9:	a1 cc 79 19 80       	mov    0x801979cc,%eax
801091be:	05 18 38 00 00       	add    $0x3818,%eax
801091c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801091c6:	a1 cc 79 19 80       	mov    0x801979cc,%eax
801091cb:	05 00 38 00 00       	add    $0x3800,%eax
801091d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801091d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091d6:	8b 00                	mov    (%eax),%eax
801091d8:	05 00 00 00 80       	add    $0x80000000,%eax
801091dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801091e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e3:	8b 10                	mov    (%eax),%edx
801091e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e8:	8b 08                	mov    (%eax),%ecx
801091ea:	89 d0                	mov    %edx,%eax
801091ec:	29 c8                	sub    %ecx,%eax
801091ee:	0f b6 d0             	movzbl %al,%edx
801091f1:	b8 00 01 00 00       	mov    $0x100,%eax
801091f6:	29 d0                	sub    %edx,%eax
801091f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801091fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091fe:	8b 00                	mov    (%eax),%eax
80109200:	25 ff 00 00 00       	and    $0xff,%eax
80109205:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109208:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010920c:	0f 8e a8 00 00 00    	jle    801092ba <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109212:	8b 45 08             	mov    0x8(%ebp),%eax
80109215:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109218:	89 d1                	mov    %edx,%ecx
8010921a:	c1 e1 04             	shl    $0x4,%ecx
8010921d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109220:	01 ca                	add    %ecx,%edx
80109222:	8b 12                	mov    (%edx),%edx
80109224:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010922a:	83 ec 04             	sub    $0x4,%esp
8010922d:	ff 75 0c             	push   0xc(%ebp)
80109230:	50                   	push   %eax
80109231:	52                   	push   %edx
80109232:	e8 e4 bc ff ff       	call   80104f1b <memmove>
80109237:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010923a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010923d:	c1 e0 04             	shl    $0x4,%eax
80109240:	89 c2                	mov    %eax,%edx
80109242:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109245:	01 d0                	add    %edx,%eax
80109247:	8b 55 0c             	mov    0xc(%ebp),%edx
8010924a:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010924e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109251:	c1 e0 04             	shl    $0x4,%eax
80109254:	89 c2                	mov    %eax,%edx
80109256:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109259:	01 d0                	add    %edx,%eax
8010925b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010925f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109262:	c1 e0 04             	shl    $0x4,%eax
80109265:	89 c2                	mov    %eax,%edx
80109267:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010926a:	01 d0                	add    %edx,%eax
8010926c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109270:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109273:	c1 e0 04             	shl    $0x4,%eax
80109276:	89 c2                	mov    %eax,%edx
80109278:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010927b:	01 d0                	add    %edx,%eax
8010927d:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109281:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109284:	c1 e0 04             	shl    $0x4,%eax
80109287:	89 c2                	mov    %eax,%edx
80109289:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010928c:	01 d0                	add    %edx,%eax
8010928e:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109294:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109297:	c1 e0 04             	shl    $0x4,%eax
8010929a:	89 c2                	mov    %eax,%edx
8010929c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010929f:	01 d0                	add    %edx,%eax
801092a1:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801092a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a8:	8b 00                	mov    (%eax),%eax
801092aa:	83 c0 01             	add    $0x1,%eax
801092ad:	0f b6 d0             	movzbl %al,%edx
801092b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b3:	89 10                	mov    %edx,(%eax)
    return len;
801092b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801092b8:	eb 05                	jmp    801092bf <i8254_send+0x119>
  }else{
    return -1;
801092ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801092bf:	c9                   	leave  
801092c0:	c3                   	ret    

801092c1 <i8254_intr>:

void i8254_intr(){
801092c1:	55                   	push   %ebp
801092c2:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801092c4:	a1 d8 79 19 80       	mov    0x801979d8,%eax
801092c9:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801092cf:	90                   	nop
801092d0:	5d                   	pop    %ebp
801092d1:	c3                   	ret    

801092d2 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801092d2:	55                   	push   %ebp
801092d3:	89 e5                	mov    %esp,%ebp
801092d5:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801092d8:	8b 45 08             	mov    0x8(%ebp),%eax
801092db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801092de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e1:	0f b7 00             	movzwl (%eax),%eax
801092e4:	66 3d 00 01          	cmp    $0x100,%ax
801092e8:	74 0a                	je     801092f4 <arp_proc+0x22>
801092ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092ef:	e9 4f 01 00 00       	jmp    80109443 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801092f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f7:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801092fb:	66 83 f8 08          	cmp    $0x8,%ax
801092ff:	74 0a                	je     8010930b <arp_proc+0x39>
80109301:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109306:	e9 38 01 00 00       	jmp    80109443 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010930b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109312:	3c 06                	cmp    $0x6,%al
80109314:	74 0a                	je     80109320 <arp_proc+0x4e>
80109316:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010931b:	e9 23 01 00 00       	jmp    80109443 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109323:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109327:	3c 04                	cmp    $0x4,%al
80109329:	74 0a                	je     80109335 <arp_proc+0x63>
8010932b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109330:	e9 0e 01 00 00       	jmp    80109443 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109338:	83 c0 18             	add    $0x18,%eax
8010933b:	83 ec 04             	sub    $0x4,%esp
8010933e:	6a 04                	push   $0x4
80109340:	50                   	push   %eax
80109341:	68 24 f5 10 80       	push   $0x8010f524
80109346:	e8 78 bb ff ff       	call   80104ec3 <memcmp>
8010934b:	83 c4 10             	add    $0x10,%esp
8010934e:	85 c0                	test   %eax,%eax
80109350:	74 27                	je     80109379 <arp_proc+0xa7>
80109352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109355:	83 c0 0e             	add    $0xe,%eax
80109358:	83 ec 04             	sub    $0x4,%esp
8010935b:	6a 04                	push   $0x4
8010935d:	50                   	push   %eax
8010935e:	68 24 f5 10 80       	push   $0x8010f524
80109363:	e8 5b bb ff ff       	call   80104ec3 <memcmp>
80109368:	83 c4 10             	add    $0x10,%esp
8010936b:	85 c0                	test   %eax,%eax
8010936d:	74 0a                	je     80109379 <arp_proc+0xa7>
8010936f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109374:	e9 ca 00 00 00       	jmp    80109443 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010937c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109380:	66 3d 00 01          	cmp    $0x100,%ax
80109384:	75 69                	jne    801093ef <arp_proc+0x11d>
80109386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109389:	83 c0 18             	add    $0x18,%eax
8010938c:	83 ec 04             	sub    $0x4,%esp
8010938f:	6a 04                	push   $0x4
80109391:	50                   	push   %eax
80109392:	68 24 f5 10 80       	push   $0x8010f524
80109397:	e8 27 bb ff ff       	call   80104ec3 <memcmp>
8010939c:	83 c4 10             	add    $0x10,%esp
8010939f:	85 c0                	test   %eax,%eax
801093a1:	75 4c                	jne    801093ef <arp_proc+0x11d>
    uint send = (uint)kalloc();
801093a3:	e8 f8 93 ff ff       	call   801027a0 <kalloc>
801093a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801093ab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801093b2:	83 ec 04             	sub    $0x4,%esp
801093b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801093b8:	50                   	push   %eax
801093b9:	ff 75 f0             	push   -0x10(%ebp)
801093bc:	ff 75 f4             	push   -0xc(%ebp)
801093bf:	e8 1f 04 00 00       	call   801097e3 <arp_reply_pkt_create>
801093c4:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801093c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093ca:	83 ec 08             	sub    $0x8,%esp
801093cd:	50                   	push   %eax
801093ce:	ff 75 f0             	push   -0x10(%ebp)
801093d1:	e8 d0 fd ff ff       	call   801091a6 <i8254_send>
801093d6:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801093d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093dc:	83 ec 0c             	sub    $0xc,%esp
801093df:	50                   	push   %eax
801093e0:	e8 21 93 ff ff       	call   80102706 <kfree>
801093e5:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801093e8:	b8 02 00 00 00       	mov    $0x2,%eax
801093ed:	eb 54                	jmp    80109443 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801093ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093f6:	66 3d 00 02          	cmp    $0x200,%ax
801093fa:	75 42                	jne    8010943e <arp_proc+0x16c>
801093fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ff:	83 c0 18             	add    $0x18,%eax
80109402:	83 ec 04             	sub    $0x4,%esp
80109405:	6a 04                	push   $0x4
80109407:	50                   	push   %eax
80109408:	68 24 f5 10 80       	push   $0x8010f524
8010940d:	e8 b1 ba ff ff       	call   80104ec3 <memcmp>
80109412:	83 c4 10             	add    $0x10,%esp
80109415:	85 c0                	test   %eax,%eax
80109417:	75 25                	jne    8010943e <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80109419:	83 ec 0c             	sub    $0xc,%esp
8010941c:	68 7c c6 10 80       	push   $0x8010c67c
80109421:	e8 ce 6f ff ff       	call   801003f4 <cprintf>
80109426:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109429:	83 ec 0c             	sub    $0xc,%esp
8010942c:	ff 75 f4             	push   -0xc(%ebp)
8010942f:	e8 af 01 00 00       	call   801095e3 <arp_table_update>
80109434:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109437:	b8 01 00 00 00       	mov    $0x1,%eax
8010943c:	eb 05                	jmp    80109443 <arp_proc+0x171>
  }else{
    return -1;
8010943e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109443:	c9                   	leave  
80109444:	c3                   	ret    

80109445 <arp_scan>:

void arp_scan(){
80109445:	55                   	push   %ebp
80109446:	89 e5                	mov    %esp,%ebp
80109448:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010944b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109452:	eb 6f                	jmp    801094c3 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109454:	e8 47 93 ff ff       	call   801027a0 <kalloc>
80109459:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010945c:	83 ec 04             	sub    $0x4,%esp
8010945f:	ff 75 f4             	push   -0xc(%ebp)
80109462:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109465:	50                   	push   %eax
80109466:	ff 75 ec             	push   -0x14(%ebp)
80109469:	e8 62 00 00 00       	call   801094d0 <arp_broadcast>
8010946e:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109471:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109474:	83 ec 08             	sub    $0x8,%esp
80109477:	50                   	push   %eax
80109478:	ff 75 ec             	push   -0x14(%ebp)
8010947b:	e8 26 fd ff ff       	call   801091a6 <i8254_send>
80109480:	83 c4 10             	add    $0x10,%esp
80109483:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109486:	eb 22                	jmp    801094aa <arp_scan+0x65>
      microdelay(1);
80109488:	83 ec 0c             	sub    $0xc,%esp
8010948b:	6a 01                	push   $0x1
8010948d:	e8 a5 96 ff ff       	call   80102b37 <microdelay>
80109492:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109495:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109498:	83 ec 08             	sub    $0x8,%esp
8010949b:	50                   	push   %eax
8010949c:	ff 75 ec             	push   -0x14(%ebp)
8010949f:	e8 02 fd ff ff       	call   801091a6 <i8254_send>
801094a4:	83 c4 10             	add    $0x10,%esp
801094a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801094aa:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801094ae:	74 d8                	je     80109488 <arp_scan+0x43>
    }
    kfree((char *)send);
801094b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801094b3:	83 ec 0c             	sub    $0xc,%esp
801094b6:	50                   	push   %eax
801094b7:	e8 4a 92 ff ff       	call   80102706 <kfree>
801094bc:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801094bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094c3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801094ca:	7e 88                	jle    80109454 <arp_scan+0xf>
  }
}
801094cc:	90                   	nop
801094cd:	90                   	nop
801094ce:	c9                   	leave  
801094cf:	c3                   	ret    

801094d0 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801094d0:	55                   	push   %ebp
801094d1:	89 e5                	mov    %esp,%ebp
801094d3:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801094d6:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801094da:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801094de:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801094e2:	8b 45 10             	mov    0x10(%ebp),%eax
801094e5:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801094e8:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801094ef:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801094f5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801094fc:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109502:	8b 45 0c             	mov    0xc(%ebp),%eax
80109505:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010950b:	8b 45 08             	mov    0x8(%ebp),%eax
8010950e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109511:	8b 45 08             	mov    0x8(%ebp),%eax
80109514:	83 c0 0e             	add    $0xe,%eax
80109517:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010951a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010951d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109524:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010952b:	83 ec 04             	sub    $0x4,%esp
8010952e:	6a 06                	push   $0x6
80109530:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109533:	52                   	push   %edx
80109534:	50                   	push   %eax
80109535:	e8 e1 b9 ff ff       	call   80104f1b <memmove>
8010953a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010953d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109540:	83 c0 06             	add    $0x6,%eax
80109543:	83 ec 04             	sub    $0x4,%esp
80109546:	6a 06                	push   $0x6
80109548:	68 d0 79 19 80       	push   $0x801979d0
8010954d:	50                   	push   %eax
8010954e:	e8 c8 b9 ff ff       	call   80104f1b <memmove>
80109553:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109559:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010955e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109561:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109567:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956a:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010956e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109571:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109575:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109578:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010957e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109581:	8d 50 12             	lea    0x12(%eax),%edx
80109584:	83 ec 04             	sub    $0x4,%esp
80109587:	6a 06                	push   $0x6
80109589:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010958c:	50                   	push   %eax
8010958d:	52                   	push   %edx
8010958e:	e8 88 b9 ff ff       	call   80104f1b <memmove>
80109593:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109599:	8d 50 18             	lea    0x18(%eax),%edx
8010959c:	83 ec 04             	sub    $0x4,%esp
8010959f:	6a 04                	push   $0x4
801095a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801095a4:	50                   	push   %eax
801095a5:	52                   	push   %edx
801095a6:	e8 70 b9 ff ff       	call   80104f1b <memmove>
801095ab:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801095ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095b1:	83 c0 08             	add    $0x8,%eax
801095b4:	83 ec 04             	sub    $0x4,%esp
801095b7:	6a 06                	push   $0x6
801095b9:	68 d0 79 19 80       	push   $0x801979d0
801095be:	50                   	push   %eax
801095bf:	e8 57 b9 ff ff       	call   80104f1b <memmove>
801095c4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801095c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ca:	83 c0 0e             	add    $0xe,%eax
801095cd:	83 ec 04             	sub    $0x4,%esp
801095d0:	6a 04                	push   $0x4
801095d2:	68 24 f5 10 80       	push   $0x8010f524
801095d7:	50                   	push   %eax
801095d8:	e8 3e b9 ff ff       	call   80104f1b <memmove>
801095dd:	83 c4 10             	add    $0x10,%esp
}
801095e0:	90                   	nop
801095e1:	c9                   	leave  
801095e2:	c3                   	ret    

801095e3 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801095e3:	55                   	push   %ebp
801095e4:	89 e5                	mov    %esp,%ebp
801095e6:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801095e9:	8b 45 08             	mov    0x8(%ebp),%eax
801095ec:	83 c0 0e             	add    $0xe,%eax
801095ef:	83 ec 0c             	sub    $0xc,%esp
801095f2:	50                   	push   %eax
801095f3:	e8 bc 00 00 00       	call   801096b4 <arp_table_search>
801095f8:	83 c4 10             	add    $0x10,%esp
801095fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801095fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109602:	78 2d                	js     80109631 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109604:	8b 45 08             	mov    0x8(%ebp),%eax
80109607:	8d 48 08             	lea    0x8(%eax),%ecx
8010960a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010960d:	89 d0                	mov    %edx,%eax
8010960f:	c1 e0 02             	shl    $0x2,%eax
80109612:	01 d0                	add    %edx,%eax
80109614:	01 c0                	add    %eax,%eax
80109616:	01 d0                	add    %edx,%eax
80109618:	05 e0 79 19 80       	add    $0x801979e0,%eax
8010961d:	83 c0 04             	add    $0x4,%eax
80109620:	83 ec 04             	sub    $0x4,%esp
80109623:	6a 06                	push   $0x6
80109625:	51                   	push   %ecx
80109626:	50                   	push   %eax
80109627:	e8 ef b8 ff ff       	call   80104f1b <memmove>
8010962c:	83 c4 10             	add    $0x10,%esp
8010962f:	eb 70                	jmp    801096a1 <arp_table_update+0xbe>
  }else{
    index += 1;
80109631:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109635:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109638:	8b 45 08             	mov    0x8(%ebp),%eax
8010963b:	8d 48 08             	lea    0x8(%eax),%ecx
8010963e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109641:	89 d0                	mov    %edx,%eax
80109643:	c1 e0 02             	shl    $0x2,%eax
80109646:	01 d0                	add    %edx,%eax
80109648:	01 c0                	add    %eax,%eax
8010964a:	01 d0                	add    %edx,%eax
8010964c:	05 e0 79 19 80       	add    $0x801979e0,%eax
80109651:	83 c0 04             	add    $0x4,%eax
80109654:	83 ec 04             	sub    $0x4,%esp
80109657:	6a 06                	push   $0x6
80109659:	51                   	push   %ecx
8010965a:	50                   	push   %eax
8010965b:	e8 bb b8 ff ff       	call   80104f1b <memmove>
80109660:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109663:	8b 45 08             	mov    0x8(%ebp),%eax
80109666:	8d 48 0e             	lea    0xe(%eax),%ecx
80109669:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010966c:	89 d0                	mov    %edx,%eax
8010966e:	c1 e0 02             	shl    $0x2,%eax
80109671:	01 d0                	add    %edx,%eax
80109673:	01 c0                	add    %eax,%eax
80109675:	01 d0                	add    %edx,%eax
80109677:	05 e0 79 19 80       	add    $0x801979e0,%eax
8010967c:	83 ec 04             	sub    $0x4,%esp
8010967f:	6a 04                	push   $0x4
80109681:	51                   	push   %ecx
80109682:	50                   	push   %eax
80109683:	e8 93 b8 ff ff       	call   80104f1b <memmove>
80109688:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010968b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010968e:	89 d0                	mov    %edx,%eax
80109690:	c1 e0 02             	shl    $0x2,%eax
80109693:	01 d0                	add    %edx,%eax
80109695:	01 c0                	add    %eax,%eax
80109697:	01 d0                	add    %edx,%eax
80109699:	05 ea 79 19 80       	add    $0x801979ea,%eax
8010969e:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801096a1:	83 ec 0c             	sub    $0xc,%esp
801096a4:	68 e0 79 19 80       	push   $0x801979e0
801096a9:	e8 83 00 00 00       	call   80109731 <print_arp_table>
801096ae:	83 c4 10             	add    $0x10,%esp
}
801096b1:	90                   	nop
801096b2:	c9                   	leave  
801096b3:	c3                   	ret    

801096b4 <arp_table_search>:

int arp_table_search(uchar *ip){
801096b4:	55                   	push   %ebp
801096b5:	89 e5                	mov    %esp,%ebp
801096b7:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801096ba:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801096c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801096c8:	eb 59                	jmp    80109723 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801096ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801096cd:	89 d0                	mov    %edx,%eax
801096cf:	c1 e0 02             	shl    $0x2,%eax
801096d2:	01 d0                	add    %edx,%eax
801096d4:	01 c0                	add    %eax,%eax
801096d6:	01 d0                	add    %edx,%eax
801096d8:	05 e0 79 19 80       	add    $0x801979e0,%eax
801096dd:	83 ec 04             	sub    $0x4,%esp
801096e0:	6a 04                	push   $0x4
801096e2:	ff 75 08             	push   0x8(%ebp)
801096e5:	50                   	push   %eax
801096e6:	e8 d8 b7 ff ff       	call   80104ec3 <memcmp>
801096eb:	83 c4 10             	add    $0x10,%esp
801096ee:	85 c0                	test   %eax,%eax
801096f0:	75 05                	jne    801096f7 <arp_table_search+0x43>
      return i;
801096f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096f5:	eb 38                	jmp    8010972f <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801096f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801096fa:	89 d0                	mov    %edx,%eax
801096fc:	c1 e0 02             	shl    $0x2,%eax
801096ff:	01 d0                	add    %edx,%eax
80109701:	01 c0                	add    %eax,%eax
80109703:	01 d0                	add    %edx,%eax
80109705:	05 ea 79 19 80       	add    $0x801979ea,%eax
8010970a:	0f b6 00             	movzbl (%eax),%eax
8010970d:	84 c0                	test   %al,%al
8010970f:	75 0e                	jne    8010971f <arp_table_search+0x6b>
80109711:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109715:	75 08                	jne    8010971f <arp_table_search+0x6b>
      empty = -i;
80109717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010971a:	f7 d8                	neg    %eax
8010971c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010971f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109723:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109727:	7e a1                	jle    801096ca <arp_table_search+0x16>
    }
  }
  return empty-1;
80109729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010972c:	83 e8 01             	sub    $0x1,%eax
}
8010972f:	c9                   	leave  
80109730:	c3                   	ret    

80109731 <print_arp_table>:

void print_arp_table(){
80109731:	55                   	push   %ebp
80109732:	89 e5                	mov    %esp,%ebp
80109734:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109737:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010973e:	e9 92 00 00 00       	jmp    801097d5 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109743:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109746:	89 d0                	mov    %edx,%eax
80109748:	c1 e0 02             	shl    $0x2,%eax
8010974b:	01 d0                	add    %edx,%eax
8010974d:	01 c0                	add    %eax,%eax
8010974f:	01 d0                	add    %edx,%eax
80109751:	05 ea 79 19 80       	add    $0x801979ea,%eax
80109756:	0f b6 00             	movzbl (%eax),%eax
80109759:	84 c0                	test   %al,%al
8010975b:	74 74                	je     801097d1 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010975d:	83 ec 08             	sub    $0x8,%esp
80109760:	ff 75 f4             	push   -0xc(%ebp)
80109763:	68 8f c6 10 80       	push   $0x8010c68f
80109768:	e8 87 6c ff ff       	call   801003f4 <cprintf>
8010976d:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109770:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109773:	89 d0                	mov    %edx,%eax
80109775:	c1 e0 02             	shl    $0x2,%eax
80109778:	01 d0                	add    %edx,%eax
8010977a:	01 c0                	add    %eax,%eax
8010977c:	01 d0                	add    %edx,%eax
8010977e:	05 e0 79 19 80       	add    $0x801979e0,%eax
80109783:	83 ec 0c             	sub    $0xc,%esp
80109786:	50                   	push   %eax
80109787:	e8 54 02 00 00       	call   801099e0 <print_ipv4>
8010978c:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010978f:	83 ec 0c             	sub    $0xc,%esp
80109792:	68 9e c6 10 80       	push   $0x8010c69e
80109797:	e8 58 6c ff ff       	call   801003f4 <cprintf>
8010979c:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010979f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097a2:	89 d0                	mov    %edx,%eax
801097a4:	c1 e0 02             	shl    $0x2,%eax
801097a7:	01 d0                	add    %edx,%eax
801097a9:	01 c0                	add    %eax,%eax
801097ab:	01 d0                	add    %edx,%eax
801097ad:	05 e0 79 19 80       	add    $0x801979e0,%eax
801097b2:	83 c0 04             	add    $0x4,%eax
801097b5:	83 ec 0c             	sub    $0xc,%esp
801097b8:	50                   	push   %eax
801097b9:	e8 70 02 00 00       	call   80109a2e <print_mac>
801097be:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801097c1:	83 ec 0c             	sub    $0xc,%esp
801097c4:	68 a0 c6 10 80       	push   $0x8010c6a0
801097c9:	e8 26 6c ff ff       	call   801003f4 <cprintf>
801097ce:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801097d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097d5:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801097d9:	0f 8e 64 ff ff ff    	jle    80109743 <print_arp_table+0x12>
    }
  }
}
801097df:	90                   	nop
801097e0:	90                   	nop
801097e1:	c9                   	leave  
801097e2:	c3                   	ret    

801097e3 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801097e3:	55                   	push   %ebp
801097e4:	89 e5                	mov    %esp,%ebp
801097e6:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801097e9:	8b 45 10             	mov    0x10(%ebp),%eax
801097ec:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801097f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801097f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801097f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801097fb:	83 c0 0e             	add    $0xe,%eax
801097fe:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109804:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010980b:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010980f:	8b 45 08             	mov    0x8(%ebp),%eax
80109812:	8d 50 08             	lea    0x8(%eax),%edx
80109815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109818:	83 ec 04             	sub    $0x4,%esp
8010981b:	6a 06                	push   $0x6
8010981d:	52                   	push   %edx
8010981e:	50                   	push   %eax
8010981f:	e8 f7 b6 ff ff       	call   80104f1b <memmove>
80109824:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010982a:	83 c0 06             	add    $0x6,%eax
8010982d:	83 ec 04             	sub    $0x4,%esp
80109830:	6a 06                	push   $0x6
80109832:	68 d0 79 19 80       	push   $0x801979d0
80109837:	50                   	push   %eax
80109838:	e8 de b6 ff ff       	call   80104f1b <memmove>
8010983d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109840:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109843:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010984b:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109854:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010985b:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010985f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109862:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109868:	8b 45 08             	mov    0x8(%ebp),%eax
8010986b:	8d 50 08             	lea    0x8(%eax),%edx
8010986e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109871:	83 c0 12             	add    $0x12,%eax
80109874:	83 ec 04             	sub    $0x4,%esp
80109877:	6a 06                	push   $0x6
80109879:	52                   	push   %edx
8010987a:	50                   	push   %eax
8010987b:	e8 9b b6 ff ff       	call   80104f1b <memmove>
80109880:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109883:	8b 45 08             	mov    0x8(%ebp),%eax
80109886:	8d 50 0e             	lea    0xe(%eax),%edx
80109889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010988c:	83 c0 18             	add    $0x18,%eax
8010988f:	83 ec 04             	sub    $0x4,%esp
80109892:	6a 04                	push   $0x4
80109894:	52                   	push   %edx
80109895:	50                   	push   %eax
80109896:	e8 80 b6 ff ff       	call   80104f1b <memmove>
8010989b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010989e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098a1:	83 c0 08             	add    $0x8,%eax
801098a4:	83 ec 04             	sub    $0x4,%esp
801098a7:	6a 06                	push   $0x6
801098a9:	68 d0 79 19 80       	push   $0x801979d0
801098ae:	50                   	push   %eax
801098af:	e8 67 b6 ff ff       	call   80104f1b <memmove>
801098b4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801098b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098ba:	83 c0 0e             	add    $0xe,%eax
801098bd:	83 ec 04             	sub    $0x4,%esp
801098c0:	6a 04                	push   $0x4
801098c2:	68 24 f5 10 80       	push   $0x8010f524
801098c7:	50                   	push   %eax
801098c8:	e8 4e b6 ff ff       	call   80104f1b <memmove>
801098cd:	83 c4 10             	add    $0x10,%esp
}
801098d0:	90                   	nop
801098d1:	c9                   	leave  
801098d2:	c3                   	ret    

801098d3 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801098d3:	55                   	push   %ebp
801098d4:	89 e5                	mov    %esp,%ebp
801098d6:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801098d9:	83 ec 0c             	sub    $0xc,%esp
801098dc:	68 a2 c6 10 80       	push   $0x8010c6a2
801098e1:	e8 0e 6b ff ff       	call   801003f4 <cprintf>
801098e6:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801098e9:	8b 45 08             	mov    0x8(%ebp),%eax
801098ec:	83 c0 0e             	add    $0xe,%eax
801098ef:	83 ec 0c             	sub    $0xc,%esp
801098f2:	50                   	push   %eax
801098f3:	e8 e8 00 00 00       	call   801099e0 <print_ipv4>
801098f8:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801098fb:	83 ec 0c             	sub    $0xc,%esp
801098fe:	68 a0 c6 10 80       	push   $0x8010c6a0
80109903:	e8 ec 6a ff ff       	call   801003f4 <cprintf>
80109908:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010990b:	8b 45 08             	mov    0x8(%ebp),%eax
8010990e:	83 c0 08             	add    $0x8,%eax
80109911:	83 ec 0c             	sub    $0xc,%esp
80109914:	50                   	push   %eax
80109915:	e8 14 01 00 00       	call   80109a2e <print_mac>
8010991a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010991d:	83 ec 0c             	sub    $0xc,%esp
80109920:	68 a0 c6 10 80       	push   $0x8010c6a0
80109925:	e8 ca 6a ff ff       	call   801003f4 <cprintf>
8010992a:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010992d:	83 ec 0c             	sub    $0xc,%esp
80109930:	68 b9 c6 10 80       	push   $0x8010c6b9
80109935:	e8 ba 6a ff ff       	call   801003f4 <cprintf>
8010993a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010993d:	8b 45 08             	mov    0x8(%ebp),%eax
80109940:	83 c0 18             	add    $0x18,%eax
80109943:	83 ec 0c             	sub    $0xc,%esp
80109946:	50                   	push   %eax
80109947:	e8 94 00 00 00       	call   801099e0 <print_ipv4>
8010994c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010994f:	83 ec 0c             	sub    $0xc,%esp
80109952:	68 a0 c6 10 80       	push   $0x8010c6a0
80109957:	e8 98 6a ff ff       	call   801003f4 <cprintf>
8010995c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010995f:	8b 45 08             	mov    0x8(%ebp),%eax
80109962:	83 c0 12             	add    $0x12,%eax
80109965:	83 ec 0c             	sub    $0xc,%esp
80109968:	50                   	push   %eax
80109969:	e8 c0 00 00 00       	call   80109a2e <print_mac>
8010996e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109971:	83 ec 0c             	sub    $0xc,%esp
80109974:	68 a0 c6 10 80       	push   $0x8010c6a0
80109979:	e8 76 6a ff ff       	call   801003f4 <cprintf>
8010997e:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109981:	83 ec 0c             	sub    $0xc,%esp
80109984:	68 d0 c6 10 80       	push   $0x8010c6d0
80109989:	e8 66 6a ff ff       	call   801003f4 <cprintf>
8010998e:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109991:	8b 45 08             	mov    0x8(%ebp),%eax
80109994:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109998:	66 3d 00 01          	cmp    $0x100,%ax
8010999c:	75 12                	jne    801099b0 <print_arp_info+0xdd>
8010999e:	83 ec 0c             	sub    $0xc,%esp
801099a1:	68 dc c6 10 80       	push   $0x8010c6dc
801099a6:	e8 49 6a ff ff       	call   801003f4 <cprintf>
801099ab:	83 c4 10             	add    $0x10,%esp
801099ae:	eb 1d                	jmp    801099cd <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801099b0:	8b 45 08             	mov    0x8(%ebp),%eax
801099b3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099b7:	66 3d 00 02          	cmp    $0x200,%ax
801099bb:	75 10                	jne    801099cd <print_arp_info+0xfa>
    cprintf("Reply\n");
801099bd:	83 ec 0c             	sub    $0xc,%esp
801099c0:	68 e5 c6 10 80       	push   $0x8010c6e5
801099c5:	e8 2a 6a ff ff       	call   801003f4 <cprintf>
801099ca:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801099cd:	83 ec 0c             	sub    $0xc,%esp
801099d0:	68 a0 c6 10 80       	push   $0x8010c6a0
801099d5:	e8 1a 6a ff ff       	call   801003f4 <cprintf>
801099da:	83 c4 10             	add    $0x10,%esp
}
801099dd:	90                   	nop
801099de:	c9                   	leave  
801099df:	c3                   	ret    

801099e0 <print_ipv4>:

void print_ipv4(uchar *ip){
801099e0:	55                   	push   %ebp
801099e1:	89 e5                	mov    %esp,%ebp
801099e3:	53                   	push   %ebx
801099e4:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801099e7:	8b 45 08             	mov    0x8(%ebp),%eax
801099ea:	83 c0 03             	add    $0x3,%eax
801099ed:	0f b6 00             	movzbl (%eax),%eax
801099f0:	0f b6 d8             	movzbl %al,%ebx
801099f3:	8b 45 08             	mov    0x8(%ebp),%eax
801099f6:	83 c0 02             	add    $0x2,%eax
801099f9:	0f b6 00             	movzbl (%eax),%eax
801099fc:	0f b6 c8             	movzbl %al,%ecx
801099ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109a02:	83 c0 01             	add    $0x1,%eax
80109a05:	0f b6 00             	movzbl (%eax),%eax
80109a08:	0f b6 d0             	movzbl %al,%edx
80109a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0e:	0f b6 00             	movzbl (%eax),%eax
80109a11:	0f b6 c0             	movzbl %al,%eax
80109a14:	83 ec 0c             	sub    $0xc,%esp
80109a17:	53                   	push   %ebx
80109a18:	51                   	push   %ecx
80109a19:	52                   	push   %edx
80109a1a:	50                   	push   %eax
80109a1b:	68 ec c6 10 80       	push   $0x8010c6ec
80109a20:	e8 cf 69 ff ff       	call   801003f4 <cprintf>
80109a25:	83 c4 20             	add    $0x20,%esp
}
80109a28:	90                   	nop
80109a29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a2c:	c9                   	leave  
80109a2d:	c3                   	ret    

80109a2e <print_mac>:

void print_mac(uchar *mac){
80109a2e:	55                   	push   %ebp
80109a2f:	89 e5                	mov    %esp,%ebp
80109a31:	57                   	push   %edi
80109a32:	56                   	push   %esi
80109a33:	53                   	push   %ebx
80109a34:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109a37:	8b 45 08             	mov    0x8(%ebp),%eax
80109a3a:	83 c0 05             	add    $0x5,%eax
80109a3d:	0f b6 00             	movzbl (%eax),%eax
80109a40:	0f b6 f8             	movzbl %al,%edi
80109a43:	8b 45 08             	mov    0x8(%ebp),%eax
80109a46:	83 c0 04             	add    $0x4,%eax
80109a49:	0f b6 00             	movzbl (%eax),%eax
80109a4c:	0f b6 f0             	movzbl %al,%esi
80109a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80109a52:	83 c0 03             	add    $0x3,%eax
80109a55:	0f b6 00             	movzbl (%eax),%eax
80109a58:	0f b6 d8             	movzbl %al,%ebx
80109a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5e:	83 c0 02             	add    $0x2,%eax
80109a61:	0f b6 00             	movzbl (%eax),%eax
80109a64:	0f b6 c8             	movzbl %al,%ecx
80109a67:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6a:	83 c0 01             	add    $0x1,%eax
80109a6d:	0f b6 00             	movzbl (%eax),%eax
80109a70:	0f b6 d0             	movzbl %al,%edx
80109a73:	8b 45 08             	mov    0x8(%ebp),%eax
80109a76:	0f b6 00             	movzbl (%eax),%eax
80109a79:	0f b6 c0             	movzbl %al,%eax
80109a7c:	83 ec 04             	sub    $0x4,%esp
80109a7f:	57                   	push   %edi
80109a80:	56                   	push   %esi
80109a81:	53                   	push   %ebx
80109a82:	51                   	push   %ecx
80109a83:	52                   	push   %edx
80109a84:	50                   	push   %eax
80109a85:	68 04 c7 10 80       	push   $0x8010c704
80109a8a:	e8 65 69 ff ff       	call   801003f4 <cprintf>
80109a8f:	83 c4 20             	add    $0x20,%esp
}
80109a92:	90                   	nop
80109a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109a96:	5b                   	pop    %ebx
80109a97:	5e                   	pop    %esi
80109a98:	5f                   	pop    %edi
80109a99:	5d                   	pop    %ebp
80109a9a:	c3                   	ret    

80109a9b <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109a9b:	55                   	push   %ebp
80109a9c:	89 e5                	mov    %esp,%ebp
80109a9e:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80109aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80109aaa:	83 c0 0e             	add    $0xe,%eax
80109aad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ab3:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109ab7:	3c 08                	cmp    $0x8,%al
80109ab9:	75 1b                	jne    80109ad6 <eth_proc+0x3b>
80109abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109abe:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ac2:	3c 06                	cmp    $0x6,%al
80109ac4:	75 10                	jne    80109ad6 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109ac6:	83 ec 0c             	sub    $0xc,%esp
80109ac9:	ff 75 f0             	push   -0x10(%ebp)
80109acc:	e8 01 f8 ff ff       	call   801092d2 <arp_proc>
80109ad1:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109ad4:	eb 24                	jmp    80109afa <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ad9:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109add:	3c 08                	cmp    $0x8,%al
80109adf:	75 19                	jne    80109afa <eth_proc+0x5f>
80109ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ae4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ae8:	84 c0                	test   %al,%al
80109aea:	75 0e                	jne    80109afa <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109aec:	83 ec 0c             	sub    $0xc,%esp
80109aef:	ff 75 08             	push   0x8(%ebp)
80109af2:	e8 a3 00 00 00       	call   80109b9a <ipv4_proc>
80109af7:	83 c4 10             	add    $0x10,%esp
}
80109afa:	90                   	nop
80109afb:	c9                   	leave  
80109afc:	c3                   	ret    

80109afd <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109afd:	55                   	push   %ebp
80109afe:	89 e5                	mov    %esp,%ebp
80109b00:	83 ec 04             	sub    $0x4,%esp
80109b03:	8b 45 08             	mov    0x8(%ebp),%eax
80109b06:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b0a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b0e:	c1 e0 08             	shl    $0x8,%eax
80109b11:	89 c2                	mov    %eax,%edx
80109b13:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b17:	66 c1 e8 08          	shr    $0x8,%ax
80109b1b:	01 d0                	add    %edx,%eax
}
80109b1d:	c9                   	leave  
80109b1e:	c3                   	ret    

80109b1f <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109b1f:	55                   	push   %ebp
80109b20:	89 e5                	mov    %esp,%ebp
80109b22:	83 ec 04             	sub    $0x4,%esp
80109b25:	8b 45 08             	mov    0x8(%ebp),%eax
80109b28:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b2c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b30:	c1 e0 08             	shl    $0x8,%eax
80109b33:	89 c2                	mov    %eax,%edx
80109b35:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b39:	66 c1 e8 08          	shr    $0x8,%ax
80109b3d:	01 d0                	add    %edx,%eax
}
80109b3f:	c9                   	leave  
80109b40:	c3                   	ret    

80109b41 <H2N_uint>:

uint H2N_uint(uint value){
80109b41:	55                   	push   %ebp
80109b42:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109b44:	8b 45 08             	mov    0x8(%ebp),%eax
80109b47:	c1 e0 18             	shl    $0x18,%eax
80109b4a:	25 00 00 00 0f       	and    $0xf000000,%eax
80109b4f:	89 c2                	mov    %eax,%edx
80109b51:	8b 45 08             	mov    0x8(%ebp),%eax
80109b54:	c1 e0 08             	shl    $0x8,%eax
80109b57:	25 00 f0 00 00       	and    $0xf000,%eax
80109b5c:	09 c2                	or     %eax,%edx
80109b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b61:	c1 e8 08             	shr    $0x8,%eax
80109b64:	83 e0 0f             	and    $0xf,%eax
80109b67:	01 d0                	add    %edx,%eax
}
80109b69:	5d                   	pop    %ebp
80109b6a:	c3                   	ret    

80109b6b <N2H_uint>:

uint N2H_uint(uint value){
80109b6b:	55                   	push   %ebp
80109b6c:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b71:	c1 e0 18             	shl    $0x18,%eax
80109b74:	89 c2                	mov    %eax,%edx
80109b76:	8b 45 08             	mov    0x8(%ebp),%eax
80109b79:	c1 e0 08             	shl    $0x8,%eax
80109b7c:	25 00 00 ff 00       	and    $0xff0000,%eax
80109b81:	01 c2                	add    %eax,%edx
80109b83:	8b 45 08             	mov    0x8(%ebp),%eax
80109b86:	c1 e8 08             	shr    $0x8,%eax
80109b89:	25 00 ff 00 00       	and    $0xff00,%eax
80109b8e:	01 c2                	add    %eax,%edx
80109b90:	8b 45 08             	mov    0x8(%ebp),%eax
80109b93:	c1 e8 18             	shr    $0x18,%eax
80109b96:	01 d0                	add    %edx,%eax
}
80109b98:	5d                   	pop    %ebp
80109b99:	c3                   	ret    

80109b9a <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109b9a:	55                   	push   %ebp
80109b9b:	89 e5                	mov    %esp,%ebp
80109b9d:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba3:	83 c0 0e             	add    $0xe,%eax
80109ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bac:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109bb0:	0f b7 d0             	movzwl %ax,%edx
80109bb3:	a1 28 f5 10 80       	mov    0x8010f528,%eax
80109bb8:	39 c2                	cmp    %eax,%edx
80109bba:	74 60                	je     80109c1c <ipv4_proc+0x82>
80109bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bbf:	83 c0 0c             	add    $0xc,%eax
80109bc2:	83 ec 04             	sub    $0x4,%esp
80109bc5:	6a 04                	push   $0x4
80109bc7:	50                   	push   %eax
80109bc8:	68 24 f5 10 80       	push   $0x8010f524
80109bcd:	e8 f1 b2 ff ff       	call   80104ec3 <memcmp>
80109bd2:	83 c4 10             	add    $0x10,%esp
80109bd5:	85 c0                	test   %eax,%eax
80109bd7:	74 43                	je     80109c1c <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bdc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109be0:	0f b7 c0             	movzwl %ax,%eax
80109be3:	a3 28 f5 10 80       	mov    %eax,0x8010f528
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109beb:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109bef:	3c 01                	cmp    $0x1,%al
80109bf1:	75 10                	jne    80109c03 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109bf3:	83 ec 0c             	sub    $0xc,%esp
80109bf6:	ff 75 08             	push   0x8(%ebp)
80109bf9:	e8 a3 00 00 00       	call   80109ca1 <icmp_proc>
80109bfe:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109c01:	eb 19                	jmp    80109c1c <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c06:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c0a:	3c 06                	cmp    $0x6,%al
80109c0c:	75 0e                	jne    80109c1c <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109c0e:	83 ec 0c             	sub    $0xc,%esp
80109c11:	ff 75 08             	push   0x8(%ebp)
80109c14:	e8 b3 03 00 00       	call   80109fcc <tcp_proc>
80109c19:	83 c4 10             	add    $0x10,%esp
}
80109c1c:	90                   	nop
80109c1d:	c9                   	leave  
80109c1e:	c3                   	ret    

80109c1f <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109c1f:	55                   	push   %ebp
80109c20:	89 e5                	mov    %esp,%ebp
80109c22:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109c25:	8b 45 08             	mov    0x8(%ebp),%eax
80109c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c2e:	0f b6 00             	movzbl (%eax),%eax
80109c31:	83 e0 0f             	and    $0xf,%eax
80109c34:	01 c0                	add    %eax,%eax
80109c36:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109c39:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c40:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109c47:	eb 48                	jmp    80109c91 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109c49:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c4c:	01 c0                	add    %eax,%eax
80109c4e:	89 c2                	mov    %eax,%edx
80109c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c53:	01 d0                	add    %edx,%eax
80109c55:	0f b6 00             	movzbl (%eax),%eax
80109c58:	0f b6 c0             	movzbl %al,%eax
80109c5b:	c1 e0 08             	shl    $0x8,%eax
80109c5e:	89 c2                	mov    %eax,%edx
80109c60:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c63:	01 c0                	add    %eax,%eax
80109c65:	8d 48 01             	lea    0x1(%eax),%ecx
80109c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c6b:	01 c8                	add    %ecx,%eax
80109c6d:	0f b6 00             	movzbl (%eax),%eax
80109c70:	0f b6 c0             	movzbl %al,%eax
80109c73:	01 d0                	add    %edx,%eax
80109c75:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109c78:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109c7f:	76 0c                	jbe    80109c8d <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109c81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c84:	0f b7 c0             	movzwl %ax,%eax
80109c87:	83 c0 01             	add    $0x1,%eax
80109c8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c8d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109c91:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109c95:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109c98:	7c af                	jl     80109c49 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109c9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c9d:	f7 d0                	not    %eax
}
80109c9f:	c9                   	leave  
80109ca0:	c3                   	ret    

80109ca1 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109ca1:	55                   	push   %ebp
80109ca2:	89 e5                	mov    %esp,%ebp
80109ca4:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80109caa:	83 c0 0e             	add    $0xe,%eax
80109cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cb3:	0f b6 00             	movzbl (%eax),%eax
80109cb6:	0f b6 c0             	movzbl %al,%eax
80109cb9:	83 e0 0f             	and    $0xf,%eax
80109cbc:	c1 e0 02             	shl    $0x2,%eax
80109cbf:	89 c2                	mov    %eax,%edx
80109cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cc4:	01 d0                	add    %edx,%eax
80109cc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ccc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109cd0:	84 c0                	test   %al,%al
80109cd2:	75 4f                	jne    80109d23 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cd7:	0f b6 00             	movzbl (%eax),%eax
80109cda:	3c 08                	cmp    $0x8,%al
80109cdc:	75 45                	jne    80109d23 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109cde:	e8 bd 8a ff ff       	call   801027a0 <kalloc>
80109ce3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109ce6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109ced:	83 ec 04             	sub    $0x4,%esp
80109cf0:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109cf3:	50                   	push   %eax
80109cf4:	ff 75 ec             	push   -0x14(%ebp)
80109cf7:	ff 75 08             	push   0x8(%ebp)
80109cfa:	e8 78 00 00 00       	call   80109d77 <icmp_reply_pkt_create>
80109cff:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109d02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d05:	83 ec 08             	sub    $0x8,%esp
80109d08:	50                   	push   %eax
80109d09:	ff 75 ec             	push   -0x14(%ebp)
80109d0c:	e8 95 f4 ff ff       	call   801091a6 <i8254_send>
80109d11:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d17:	83 ec 0c             	sub    $0xc,%esp
80109d1a:	50                   	push   %eax
80109d1b:	e8 e6 89 ff ff       	call   80102706 <kfree>
80109d20:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109d23:	90                   	nop
80109d24:	c9                   	leave  
80109d25:	c3                   	ret    

80109d26 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109d26:	55                   	push   %ebp
80109d27:	89 e5                	mov    %esp,%ebp
80109d29:	53                   	push   %ebx
80109d2a:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d30:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109d34:	0f b7 c0             	movzwl %ax,%eax
80109d37:	83 ec 0c             	sub    $0xc,%esp
80109d3a:	50                   	push   %eax
80109d3b:	e8 bd fd ff ff       	call   80109afd <N2H_ushort>
80109d40:	83 c4 10             	add    $0x10,%esp
80109d43:	0f b7 d8             	movzwl %ax,%ebx
80109d46:	8b 45 08             	mov    0x8(%ebp),%eax
80109d49:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d4d:	0f b7 c0             	movzwl %ax,%eax
80109d50:	83 ec 0c             	sub    $0xc,%esp
80109d53:	50                   	push   %eax
80109d54:	e8 a4 fd ff ff       	call   80109afd <N2H_ushort>
80109d59:	83 c4 10             	add    $0x10,%esp
80109d5c:	0f b7 c0             	movzwl %ax,%eax
80109d5f:	83 ec 04             	sub    $0x4,%esp
80109d62:	53                   	push   %ebx
80109d63:	50                   	push   %eax
80109d64:	68 23 c7 10 80       	push   $0x8010c723
80109d69:	e8 86 66 ff ff       	call   801003f4 <cprintf>
80109d6e:	83 c4 10             	add    $0x10,%esp
}
80109d71:	90                   	nop
80109d72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109d75:	c9                   	leave  
80109d76:	c3                   	ret    

80109d77 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109d77:	55                   	push   %ebp
80109d78:	89 e5                	mov    %esp,%ebp
80109d7a:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109d83:	8b 45 08             	mov    0x8(%ebp),%eax
80109d86:	83 c0 0e             	add    $0xe,%eax
80109d89:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d8f:	0f b6 00             	movzbl (%eax),%eax
80109d92:	0f b6 c0             	movzbl %al,%eax
80109d95:	83 e0 0f             	and    $0xf,%eax
80109d98:	c1 e0 02             	shl    $0x2,%eax
80109d9b:	89 c2                	mov    %eax,%edx
80109d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109da0:	01 d0                	add    %edx,%eax
80109da2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109da5:	8b 45 0c             	mov    0xc(%ebp),%eax
80109da8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109dab:	8b 45 0c             	mov    0xc(%ebp),%eax
80109dae:	83 c0 0e             	add    $0xe,%eax
80109db1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db7:	83 c0 14             	add    $0x14,%eax
80109dba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109dbd:	8b 45 10             	mov    0x10(%ebp),%eax
80109dc0:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dc9:	8d 50 06             	lea    0x6(%eax),%edx
80109dcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dcf:	83 ec 04             	sub    $0x4,%esp
80109dd2:	6a 06                	push   $0x6
80109dd4:	52                   	push   %edx
80109dd5:	50                   	push   %eax
80109dd6:	e8 40 b1 ff ff       	call   80104f1b <memmove>
80109ddb:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109dde:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109de1:	83 c0 06             	add    $0x6,%eax
80109de4:	83 ec 04             	sub    $0x4,%esp
80109de7:	6a 06                	push   $0x6
80109de9:	68 d0 79 19 80       	push   $0x801979d0
80109dee:	50                   	push   %eax
80109def:	e8 27 b1 ff ff       	call   80104f1b <memmove>
80109df4:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109df7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dfa:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109dfe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e01:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e08:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e0e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109e12:	83 ec 0c             	sub    $0xc,%esp
80109e15:	6a 54                	push   $0x54
80109e17:	e8 03 fd ff ff       	call   80109b1f <H2N_ushort>
80109e1c:	83 c4 10             	add    $0x10,%esp
80109e1f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e22:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e26:	0f b7 15 a0 7c 19 80 	movzwl 0x80197ca0,%edx
80109e2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e30:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109e34:	0f b7 05 a0 7c 19 80 	movzwl 0x80197ca0,%eax
80109e3b:	83 c0 01             	add    $0x1,%eax
80109e3e:	66 a3 a0 7c 19 80    	mov    %ax,0x80197ca0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109e44:	83 ec 0c             	sub    $0xc,%esp
80109e47:	68 00 40 00 00       	push   $0x4000
80109e4c:	e8 ce fc ff ff       	call   80109b1f <H2N_ushort>
80109e51:	83 c4 10             	add    $0x10,%esp
80109e54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e57:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e5e:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109e62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e65:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109e69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e6c:	83 c0 0c             	add    $0xc,%eax
80109e6f:	83 ec 04             	sub    $0x4,%esp
80109e72:	6a 04                	push   $0x4
80109e74:	68 24 f5 10 80       	push   $0x8010f524
80109e79:	50                   	push   %eax
80109e7a:	e8 9c b0 ff ff       	call   80104f1b <memmove>
80109e7f:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e85:	8d 50 0c             	lea    0xc(%eax),%edx
80109e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e8b:	83 c0 10             	add    $0x10,%eax
80109e8e:	83 ec 04             	sub    $0x4,%esp
80109e91:	6a 04                	push   $0x4
80109e93:	52                   	push   %edx
80109e94:	50                   	push   %eax
80109e95:	e8 81 b0 ff ff       	call   80104f1b <memmove>
80109e9a:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109e9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109ea6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea9:	83 ec 0c             	sub    $0xc,%esp
80109eac:	50                   	push   %eax
80109ead:	e8 6d fd ff ff       	call   80109c1f <ipv4_chksum>
80109eb2:	83 c4 10             	add    $0x10,%esp
80109eb5:	0f b7 c0             	movzwl %ax,%eax
80109eb8:	83 ec 0c             	sub    $0xc,%esp
80109ebb:	50                   	push   %eax
80109ebc:	e8 5e fc ff ff       	call   80109b1f <H2N_ushort>
80109ec1:	83 c4 10             	add    $0x10,%esp
80109ec4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ec7:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ece:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109ed1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ed4:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109edb:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109edf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ee2:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109ee6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ee9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109eed:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ef0:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109ef4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ef7:	8d 50 08             	lea    0x8(%eax),%edx
80109efa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109efd:	83 c0 08             	add    $0x8,%eax
80109f00:	83 ec 04             	sub    $0x4,%esp
80109f03:	6a 08                	push   $0x8
80109f05:	52                   	push   %edx
80109f06:	50                   	push   %eax
80109f07:	e8 0f b0 ff ff       	call   80104f1b <memmove>
80109f0c:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109f0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f12:	8d 50 10             	lea    0x10(%eax),%edx
80109f15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f18:	83 c0 10             	add    $0x10,%eax
80109f1b:	83 ec 04             	sub    $0x4,%esp
80109f1e:	6a 30                	push   $0x30
80109f20:	52                   	push   %edx
80109f21:	50                   	push   %eax
80109f22:	e8 f4 af ff ff       	call   80104f1b <memmove>
80109f27:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109f2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f2d:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109f33:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f36:	83 ec 0c             	sub    $0xc,%esp
80109f39:	50                   	push   %eax
80109f3a:	e8 1c 00 00 00       	call   80109f5b <icmp_chksum>
80109f3f:	83 c4 10             	add    $0x10,%esp
80109f42:	0f b7 c0             	movzwl %ax,%eax
80109f45:	83 ec 0c             	sub    $0xc,%esp
80109f48:	50                   	push   %eax
80109f49:	e8 d1 fb ff ff       	call   80109b1f <H2N_ushort>
80109f4e:	83 c4 10             	add    $0x10,%esp
80109f51:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f54:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109f58:	90                   	nop
80109f59:	c9                   	leave  
80109f5a:	c3                   	ret    

80109f5b <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109f5b:	55                   	push   %ebp
80109f5c:	89 e5                	mov    %esp,%ebp
80109f5e:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109f61:	8b 45 08             	mov    0x8(%ebp),%eax
80109f64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109f67:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109f6e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109f75:	eb 48                	jmp    80109fbf <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109f77:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f7a:	01 c0                	add    %eax,%eax
80109f7c:	89 c2                	mov    %eax,%edx
80109f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f81:	01 d0                	add    %edx,%eax
80109f83:	0f b6 00             	movzbl (%eax),%eax
80109f86:	0f b6 c0             	movzbl %al,%eax
80109f89:	c1 e0 08             	shl    $0x8,%eax
80109f8c:	89 c2                	mov    %eax,%edx
80109f8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f91:	01 c0                	add    %eax,%eax
80109f93:	8d 48 01             	lea    0x1(%eax),%ecx
80109f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f99:	01 c8                	add    %ecx,%eax
80109f9b:	0f b6 00             	movzbl (%eax),%eax
80109f9e:	0f b6 c0             	movzbl %al,%eax
80109fa1:	01 d0                	add    %edx,%eax
80109fa3:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109fa6:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109fad:	76 0c                	jbe    80109fbb <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109faf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109fb2:	0f b7 c0             	movzwl %ax,%eax
80109fb5:	83 c0 01             	add    $0x1,%eax
80109fb8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109fbb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109fbf:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109fc3:	7e b2                	jle    80109f77 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109fc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109fc8:	f7 d0                	not    %eax
}
80109fca:	c9                   	leave  
80109fcb:	c3                   	ret    

80109fcc <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109fcc:	55                   	push   %ebp
80109fcd:	89 e5                	mov    %esp,%ebp
80109fcf:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd5:	83 c0 0e             	add    $0xe,%eax
80109fd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fde:	0f b6 00             	movzbl (%eax),%eax
80109fe1:	0f b6 c0             	movzbl %al,%eax
80109fe4:	83 e0 0f             	and    $0xf,%eax
80109fe7:	c1 e0 02             	shl    $0x2,%eax
80109fea:	89 c2                	mov    %eax,%edx
80109fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fef:	01 d0                	add    %edx,%eax
80109ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ff7:	83 c0 14             	add    $0x14,%eax
80109ffa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109ffd:	e8 9e 87 ff ff       	call   801027a0 <kalloc>
8010a002:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a005:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a00c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a00f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a013:	0f b6 c0             	movzbl %al,%eax
8010a016:	83 e0 02             	and    $0x2,%eax
8010a019:	85 c0                	test   %eax,%eax
8010a01b:	74 3d                	je     8010a05a <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a01d:	83 ec 0c             	sub    $0xc,%esp
8010a020:	6a 00                	push   $0x0
8010a022:	6a 12                	push   $0x12
8010a024:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a027:	50                   	push   %eax
8010a028:	ff 75 e8             	push   -0x18(%ebp)
8010a02b:	ff 75 08             	push   0x8(%ebp)
8010a02e:	e8 a2 01 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a033:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a036:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a039:	83 ec 08             	sub    $0x8,%esp
8010a03c:	50                   	push   %eax
8010a03d:	ff 75 e8             	push   -0x18(%ebp)
8010a040:	e8 61 f1 ff ff       	call   801091a6 <i8254_send>
8010a045:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a048:	a1 a4 7c 19 80       	mov    0x80197ca4,%eax
8010a04d:	83 c0 01             	add    $0x1,%eax
8010a050:	a3 a4 7c 19 80       	mov    %eax,0x80197ca4
8010a055:	e9 69 01 00 00       	jmp    8010a1c3 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a05a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a05d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a061:	3c 18                	cmp    $0x18,%al
8010a063:	0f 85 10 01 00 00    	jne    8010a179 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a069:	83 ec 04             	sub    $0x4,%esp
8010a06c:	6a 03                	push   $0x3
8010a06e:	68 3e c7 10 80       	push   $0x8010c73e
8010a073:	ff 75 ec             	push   -0x14(%ebp)
8010a076:	e8 48 ae ff ff       	call   80104ec3 <memcmp>
8010a07b:	83 c4 10             	add    $0x10,%esp
8010a07e:	85 c0                	test   %eax,%eax
8010a080:	74 74                	je     8010a0f6 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a082:	83 ec 0c             	sub    $0xc,%esp
8010a085:	68 42 c7 10 80       	push   $0x8010c742
8010a08a:	e8 65 63 ff ff       	call   801003f4 <cprintf>
8010a08f:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a092:	83 ec 0c             	sub    $0xc,%esp
8010a095:	6a 00                	push   $0x0
8010a097:	6a 10                	push   $0x10
8010a099:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a09c:	50                   	push   %eax
8010a09d:	ff 75 e8             	push   -0x18(%ebp)
8010a0a0:	ff 75 08             	push   0x8(%ebp)
8010a0a3:	e8 2d 01 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a0a8:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a0ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0ae:	83 ec 08             	sub    $0x8,%esp
8010a0b1:	50                   	push   %eax
8010a0b2:	ff 75 e8             	push   -0x18(%ebp)
8010a0b5:	e8 ec f0 ff ff       	call   801091a6 <i8254_send>
8010a0ba:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a0bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0c0:	83 c0 36             	add    $0x36,%eax
8010a0c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a0c6:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a0c9:	50                   	push   %eax
8010a0ca:	ff 75 e0             	push   -0x20(%ebp)
8010a0cd:	6a 00                	push   $0x0
8010a0cf:	6a 00                	push   $0x0
8010a0d1:	e8 5a 04 00 00       	call   8010a530 <http_proc>
8010a0d6:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a0d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a0dc:	83 ec 0c             	sub    $0xc,%esp
8010a0df:	50                   	push   %eax
8010a0e0:	6a 18                	push   $0x18
8010a0e2:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0e5:	50                   	push   %eax
8010a0e6:	ff 75 e8             	push   -0x18(%ebp)
8010a0e9:	ff 75 08             	push   0x8(%ebp)
8010a0ec:	e8 e4 00 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a0f1:	83 c4 20             	add    $0x20,%esp
8010a0f4:	eb 62                	jmp    8010a158 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a0f6:	83 ec 0c             	sub    $0xc,%esp
8010a0f9:	6a 00                	push   $0x0
8010a0fb:	6a 10                	push   $0x10
8010a0fd:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a100:	50                   	push   %eax
8010a101:	ff 75 e8             	push   -0x18(%ebp)
8010a104:	ff 75 08             	push   0x8(%ebp)
8010a107:	e8 c9 00 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a10c:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a10f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a112:	83 ec 08             	sub    $0x8,%esp
8010a115:	50                   	push   %eax
8010a116:	ff 75 e8             	push   -0x18(%ebp)
8010a119:	e8 88 f0 ff ff       	call   801091a6 <i8254_send>
8010a11e:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a121:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a124:	83 c0 36             	add    $0x36,%eax
8010a127:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a12a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a12d:	50                   	push   %eax
8010a12e:	ff 75 e4             	push   -0x1c(%ebp)
8010a131:	6a 00                	push   $0x0
8010a133:	6a 00                	push   $0x0
8010a135:	e8 f6 03 00 00       	call   8010a530 <http_proc>
8010a13a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a13d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a140:	83 ec 0c             	sub    $0xc,%esp
8010a143:	50                   	push   %eax
8010a144:	6a 18                	push   $0x18
8010a146:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a149:	50                   	push   %eax
8010a14a:	ff 75 e8             	push   -0x18(%ebp)
8010a14d:	ff 75 08             	push   0x8(%ebp)
8010a150:	e8 80 00 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a155:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a158:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a15b:	83 ec 08             	sub    $0x8,%esp
8010a15e:	50                   	push   %eax
8010a15f:	ff 75 e8             	push   -0x18(%ebp)
8010a162:	e8 3f f0 ff ff       	call   801091a6 <i8254_send>
8010a167:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a16a:	a1 a4 7c 19 80       	mov    0x80197ca4,%eax
8010a16f:	83 c0 01             	add    $0x1,%eax
8010a172:	a3 a4 7c 19 80       	mov    %eax,0x80197ca4
8010a177:	eb 4a                	jmp    8010a1c3 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a17c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a180:	3c 10                	cmp    $0x10,%al
8010a182:	75 3f                	jne    8010a1c3 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a184:	a1 a8 7c 19 80       	mov    0x80197ca8,%eax
8010a189:	83 f8 01             	cmp    $0x1,%eax
8010a18c:	75 35                	jne    8010a1c3 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a18e:	83 ec 0c             	sub    $0xc,%esp
8010a191:	6a 00                	push   $0x0
8010a193:	6a 01                	push   $0x1
8010a195:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a198:	50                   	push   %eax
8010a199:	ff 75 e8             	push   -0x18(%ebp)
8010a19c:	ff 75 08             	push   0x8(%ebp)
8010a19f:	e8 31 00 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a1a4:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a1a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1aa:	83 ec 08             	sub    $0x8,%esp
8010a1ad:	50                   	push   %eax
8010a1ae:	ff 75 e8             	push   -0x18(%ebp)
8010a1b1:	e8 f0 ef ff ff       	call   801091a6 <i8254_send>
8010a1b6:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a1b9:	c7 05 a8 7c 19 80 00 	movl   $0x0,0x80197ca8
8010a1c0:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a1c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1c6:	83 ec 0c             	sub    $0xc,%esp
8010a1c9:	50                   	push   %eax
8010a1ca:	e8 37 85 ff ff       	call   80102706 <kfree>
8010a1cf:	83 c4 10             	add    $0x10,%esp
}
8010a1d2:	90                   	nop
8010a1d3:	c9                   	leave  
8010a1d4:	c3                   	ret    

8010a1d5 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a1d5:	55                   	push   %ebp
8010a1d6:	89 e5                	mov    %esp,%ebp
8010a1d8:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a1db:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a1e1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1e4:	83 c0 0e             	add    $0xe,%eax
8010a1e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a1ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1ed:	0f b6 00             	movzbl (%eax),%eax
8010a1f0:	0f b6 c0             	movzbl %al,%eax
8010a1f3:	83 e0 0f             	and    $0xf,%eax
8010a1f6:	c1 e0 02             	shl    $0x2,%eax
8010a1f9:	89 c2                	mov    %eax,%edx
8010a1fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1fe:	01 d0                	add    %edx,%eax
8010a200:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a203:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a206:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a209:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a20c:	83 c0 0e             	add    $0xe,%eax
8010a20f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a212:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a215:	83 c0 14             	add    $0x14,%eax
8010a218:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a21b:	8b 45 18             	mov    0x18(%ebp),%eax
8010a21e:	8d 50 36             	lea    0x36(%eax),%edx
8010a221:	8b 45 10             	mov    0x10(%ebp),%eax
8010a224:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a226:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a229:	8d 50 06             	lea    0x6(%eax),%edx
8010a22c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a22f:	83 ec 04             	sub    $0x4,%esp
8010a232:	6a 06                	push   $0x6
8010a234:	52                   	push   %edx
8010a235:	50                   	push   %eax
8010a236:	e8 e0 ac ff ff       	call   80104f1b <memmove>
8010a23b:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a23e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a241:	83 c0 06             	add    $0x6,%eax
8010a244:	83 ec 04             	sub    $0x4,%esp
8010a247:	6a 06                	push   $0x6
8010a249:	68 d0 79 19 80       	push   $0x801979d0
8010a24e:	50                   	push   %eax
8010a24f:	e8 c7 ac ff ff       	call   80104f1b <memmove>
8010a254:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a257:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a25a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a25e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a261:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a268:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a26b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a26e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a272:	8b 45 18             	mov    0x18(%ebp),%eax
8010a275:	83 c0 28             	add    $0x28,%eax
8010a278:	0f b7 c0             	movzwl %ax,%eax
8010a27b:	83 ec 0c             	sub    $0xc,%esp
8010a27e:	50                   	push   %eax
8010a27f:	e8 9b f8 ff ff       	call   80109b1f <H2N_ushort>
8010a284:	83 c4 10             	add    $0x10,%esp
8010a287:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a28a:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a28e:	0f b7 15 a0 7c 19 80 	movzwl 0x80197ca0,%edx
8010a295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a298:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a29c:	0f b7 05 a0 7c 19 80 	movzwl 0x80197ca0,%eax
8010a2a3:	83 c0 01             	add    $0x1,%eax
8010a2a6:	66 a3 a0 7c 19 80    	mov    %ax,0x80197ca0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a2ac:	83 ec 0c             	sub    $0xc,%esp
8010a2af:	6a 00                	push   $0x0
8010a2b1:	e8 69 f8 ff ff       	call   80109b1f <H2N_ushort>
8010a2b6:	83 c4 10             	add    $0x10,%esp
8010a2b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2bc:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a2c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2c3:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a2c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ca:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a2ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2d1:	83 c0 0c             	add    $0xc,%eax
8010a2d4:	83 ec 04             	sub    $0x4,%esp
8010a2d7:	6a 04                	push   $0x4
8010a2d9:	68 24 f5 10 80       	push   $0x8010f524
8010a2de:	50                   	push   %eax
8010a2df:	e8 37 ac ff ff       	call   80104f1b <memmove>
8010a2e4:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a2e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2ea:	8d 50 0c             	lea    0xc(%eax),%edx
8010a2ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2f0:	83 c0 10             	add    $0x10,%eax
8010a2f3:	83 ec 04             	sub    $0x4,%esp
8010a2f6:	6a 04                	push   $0x4
8010a2f8:	52                   	push   %edx
8010a2f9:	50                   	push   %eax
8010a2fa:	e8 1c ac ff ff       	call   80104f1b <memmove>
8010a2ff:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a305:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a30b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a30e:	83 ec 0c             	sub    $0xc,%esp
8010a311:	50                   	push   %eax
8010a312:	e8 08 f9 ff ff       	call   80109c1f <ipv4_chksum>
8010a317:	83 c4 10             	add    $0x10,%esp
8010a31a:	0f b7 c0             	movzwl %ax,%eax
8010a31d:	83 ec 0c             	sub    $0xc,%esp
8010a320:	50                   	push   %eax
8010a321:	e8 f9 f7 ff ff       	call   80109b1f <H2N_ushort>
8010a326:	83 c4 10             	add    $0x10,%esp
8010a329:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a32c:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a330:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a333:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a337:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a33a:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a33d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a340:	0f b7 10             	movzwl (%eax),%edx
8010a343:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a346:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a34a:	a1 a4 7c 19 80       	mov    0x80197ca4,%eax
8010a34f:	83 ec 0c             	sub    $0xc,%esp
8010a352:	50                   	push   %eax
8010a353:	e8 e9 f7 ff ff       	call   80109b41 <H2N_uint>
8010a358:	83 c4 10             	add    $0x10,%esp
8010a35b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a35e:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a361:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a364:	8b 40 04             	mov    0x4(%eax),%eax
8010a367:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a36d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a370:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a373:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a376:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a37a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a37d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a381:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a384:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a388:	8b 45 14             	mov    0x14(%ebp),%eax
8010a38b:	89 c2                	mov    %eax,%edx
8010a38d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a390:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a393:	83 ec 0c             	sub    $0xc,%esp
8010a396:	68 90 38 00 00       	push   $0x3890
8010a39b:	e8 7f f7 ff ff       	call   80109b1f <H2N_ushort>
8010a3a0:	83 c4 10             	add    $0x10,%esp
8010a3a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3a6:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a3aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ad:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a3b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b6:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a3bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3bf:	83 ec 0c             	sub    $0xc,%esp
8010a3c2:	50                   	push   %eax
8010a3c3:	e8 1f 00 00 00       	call   8010a3e7 <tcp_chksum>
8010a3c8:	83 c4 10             	add    $0x10,%esp
8010a3cb:	83 c0 08             	add    $0x8,%eax
8010a3ce:	0f b7 c0             	movzwl %ax,%eax
8010a3d1:	83 ec 0c             	sub    $0xc,%esp
8010a3d4:	50                   	push   %eax
8010a3d5:	e8 45 f7 ff ff       	call   80109b1f <H2N_ushort>
8010a3da:	83 c4 10             	add    $0x10,%esp
8010a3dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3e0:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a3e4:	90                   	nop
8010a3e5:	c9                   	leave  
8010a3e6:	c3                   	ret    

8010a3e7 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a3e7:	55                   	push   %ebp
8010a3e8:	89 e5                	mov    %esp,%ebp
8010a3ea:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a3ed:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a3f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3f6:	83 c0 14             	add    $0x14,%eax
8010a3f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a3fc:	83 ec 04             	sub    $0x4,%esp
8010a3ff:	6a 04                	push   $0x4
8010a401:	68 24 f5 10 80       	push   $0x8010f524
8010a406:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a409:	50                   	push   %eax
8010a40a:	e8 0c ab ff ff       	call   80104f1b <memmove>
8010a40f:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a412:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a415:	83 c0 0c             	add    $0xc,%eax
8010a418:	83 ec 04             	sub    $0x4,%esp
8010a41b:	6a 04                	push   $0x4
8010a41d:	50                   	push   %eax
8010a41e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a421:	83 c0 04             	add    $0x4,%eax
8010a424:	50                   	push   %eax
8010a425:	e8 f1 aa ff ff       	call   80104f1b <memmove>
8010a42a:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a42d:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a431:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a435:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a438:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a43c:	0f b7 c0             	movzwl %ax,%eax
8010a43f:	83 ec 0c             	sub    $0xc,%esp
8010a442:	50                   	push   %eax
8010a443:	e8 b5 f6 ff ff       	call   80109afd <N2H_ushort>
8010a448:	83 c4 10             	add    $0x10,%esp
8010a44b:	83 e8 14             	sub    $0x14,%eax
8010a44e:	0f b7 c0             	movzwl %ax,%eax
8010a451:	83 ec 0c             	sub    $0xc,%esp
8010a454:	50                   	push   %eax
8010a455:	e8 c5 f6 ff ff       	call   80109b1f <H2N_ushort>
8010a45a:	83 c4 10             	add    $0x10,%esp
8010a45d:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a461:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a468:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a46b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a46e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a475:	eb 33                	jmp    8010a4aa <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a47a:	01 c0                	add    %eax,%eax
8010a47c:	89 c2                	mov    %eax,%edx
8010a47e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a481:	01 d0                	add    %edx,%eax
8010a483:	0f b6 00             	movzbl (%eax),%eax
8010a486:	0f b6 c0             	movzbl %al,%eax
8010a489:	c1 e0 08             	shl    $0x8,%eax
8010a48c:	89 c2                	mov    %eax,%edx
8010a48e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a491:	01 c0                	add    %eax,%eax
8010a493:	8d 48 01             	lea    0x1(%eax),%ecx
8010a496:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a499:	01 c8                	add    %ecx,%eax
8010a49b:	0f b6 00             	movzbl (%eax),%eax
8010a49e:	0f b6 c0             	movzbl %al,%eax
8010a4a1:	01 d0                	add    %edx,%eax
8010a4a3:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a4a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a4aa:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a4ae:	7e c7                	jle    8010a477 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a4b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a4b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a4bd:	eb 33                	jmp    8010a4f2 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a4bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4c2:	01 c0                	add    %eax,%eax
8010a4c4:	89 c2                	mov    %eax,%edx
8010a4c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4c9:	01 d0                	add    %edx,%eax
8010a4cb:	0f b6 00             	movzbl (%eax),%eax
8010a4ce:	0f b6 c0             	movzbl %al,%eax
8010a4d1:	c1 e0 08             	shl    $0x8,%eax
8010a4d4:	89 c2                	mov    %eax,%edx
8010a4d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4d9:	01 c0                	add    %eax,%eax
8010a4db:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4de:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4e1:	01 c8                	add    %ecx,%eax
8010a4e3:	0f b6 00             	movzbl (%eax),%eax
8010a4e6:	0f b6 c0             	movzbl %al,%eax
8010a4e9:	01 d0                	add    %edx,%eax
8010a4eb:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a4ee:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a4f2:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a4f6:	0f b7 c0             	movzwl %ax,%eax
8010a4f9:	83 ec 0c             	sub    $0xc,%esp
8010a4fc:	50                   	push   %eax
8010a4fd:	e8 fb f5 ff ff       	call   80109afd <N2H_ushort>
8010a502:	83 c4 10             	add    $0x10,%esp
8010a505:	66 d1 e8             	shr    %ax
8010a508:	0f b7 c0             	movzwl %ax,%eax
8010a50b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a50e:	7c af                	jl     8010a4bf <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a510:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a513:	c1 e8 10             	shr    $0x10,%eax
8010a516:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a51c:	f7 d0                	not    %eax
}
8010a51e:	c9                   	leave  
8010a51f:	c3                   	ret    

8010a520 <tcp_fin>:

void tcp_fin(){
8010a520:	55                   	push   %ebp
8010a521:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a523:	c7 05 a8 7c 19 80 01 	movl   $0x1,0x80197ca8
8010a52a:	00 00 00 
}
8010a52d:	90                   	nop
8010a52e:	5d                   	pop    %ebp
8010a52f:	c3                   	ret    

8010a530 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a530:	55                   	push   %ebp
8010a531:	89 e5                	mov    %esp,%ebp
8010a533:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a536:	8b 45 10             	mov    0x10(%ebp),%eax
8010a539:	83 ec 04             	sub    $0x4,%esp
8010a53c:	6a 00                	push   $0x0
8010a53e:	68 4b c7 10 80       	push   $0x8010c74b
8010a543:	50                   	push   %eax
8010a544:	e8 65 00 00 00       	call   8010a5ae <http_strcpy>
8010a549:	83 c4 10             	add    $0x10,%esp
8010a54c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a54f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a552:	83 ec 04             	sub    $0x4,%esp
8010a555:	ff 75 f4             	push   -0xc(%ebp)
8010a558:	68 5e c7 10 80       	push   $0x8010c75e
8010a55d:	50                   	push   %eax
8010a55e:	e8 4b 00 00 00       	call   8010a5ae <http_strcpy>
8010a563:	83 c4 10             	add    $0x10,%esp
8010a566:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a569:	8b 45 10             	mov    0x10(%ebp),%eax
8010a56c:	83 ec 04             	sub    $0x4,%esp
8010a56f:	ff 75 f4             	push   -0xc(%ebp)
8010a572:	68 79 c7 10 80       	push   $0x8010c779
8010a577:	50                   	push   %eax
8010a578:	e8 31 00 00 00       	call   8010a5ae <http_strcpy>
8010a57d:	83 c4 10             	add    $0x10,%esp
8010a580:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a583:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a586:	83 e0 01             	and    $0x1,%eax
8010a589:	85 c0                	test   %eax,%eax
8010a58b:	74 11                	je     8010a59e <http_proc+0x6e>
    char *payload = (char *)send;
8010a58d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a590:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a593:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a596:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a599:	01 d0                	add    %edx,%eax
8010a59b:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a59e:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a5a1:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5a4:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a5a6:	e8 75 ff ff ff       	call   8010a520 <tcp_fin>
}
8010a5ab:	90                   	nop
8010a5ac:	c9                   	leave  
8010a5ad:	c3                   	ret    

8010a5ae <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a5ae:	55                   	push   %ebp
8010a5af:	89 e5                	mov    %esp,%ebp
8010a5b1:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a5b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a5bb:	eb 20                	jmp    8010a5dd <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a5bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5c0:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5c3:	01 d0                	add    %edx,%eax
8010a5c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a5c8:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5cb:	01 ca                	add    %ecx,%edx
8010a5cd:	89 d1                	mov    %edx,%ecx
8010a5cf:	8b 55 08             	mov    0x8(%ebp),%edx
8010a5d2:	01 ca                	add    %ecx,%edx
8010a5d4:	0f b6 00             	movzbl (%eax),%eax
8010a5d7:	88 02                	mov    %al,(%edx)
    i++;
8010a5d9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a5dd:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5e0:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5e3:	01 d0                	add    %edx,%eax
8010a5e5:	0f b6 00             	movzbl (%eax),%eax
8010a5e8:	84 c0                	test   %al,%al
8010a5ea:	75 d1                	jne    8010a5bd <http_strcpy+0xf>
  }
  return i;
8010a5ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a5ef:	c9                   	leave  
8010a5f0:	c3                   	ret    

8010a5f1 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a5f1:	55                   	push   %ebp
8010a5f2:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a5f4:	c7 05 b0 7c 19 80 e2 	movl   $0x8010f5e2,0x80197cb0
8010a5fb:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a5fe:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a603:	c1 e8 09             	shr    $0x9,%eax
8010a606:	a3 ac 7c 19 80       	mov    %eax,0x80197cac
}
8010a60b:	90                   	nop
8010a60c:	5d                   	pop    %ebp
8010a60d:	c3                   	ret    

8010a60e <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a60e:	55                   	push   %ebp
8010a60f:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a611:	90                   	nop
8010a612:	5d                   	pop    %ebp
8010a613:	c3                   	ret    

8010a614 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a614:	55                   	push   %ebp
8010a615:	89 e5                	mov    %esp,%ebp
8010a617:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a61a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a61d:	83 c0 0c             	add    $0xc,%eax
8010a620:	83 ec 0c             	sub    $0xc,%esp
8010a623:	50                   	push   %eax
8010a624:	e8 2c a5 ff ff       	call   80104b55 <holdingsleep>
8010a629:	83 c4 10             	add    $0x10,%esp
8010a62c:	85 c0                	test   %eax,%eax
8010a62e:	75 0d                	jne    8010a63d <iderw+0x29>
    panic("iderw: buf not locked");
8010a630:	83 ec 0c             	sub    $0xc,%esp
8010a633:	68 8a c7 10 80       	push   $0x8010c78a
8010a638:	e8 6c 5f ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a63d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a640:	8b 00                	mov    (%eax),%eax
8010a642:	83 e0 06             	and    $0x6,%eax
8010a645:	83 f8 02             	cmp    $0x2,%eax
8010a648:	75 0d                	jne    8010a657 <iderw+0x43>
    panic("iderw: nothing to do");
8010a64a:	83 ec 0c             	sub    $0xc,%esp
8010a64d:	68 a0 c7 10 80       	push   $0x8010c7a0
8010a652:	e8 52 5f ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a657:	8b 45 08             	mov    0x8(%ebp),%eax
8010a65a:	8b 40 04             	mov    0x4(%eax),%eax
8010a65d:	83 f8 01             	cmp    $0x1,%eax
8010a660:	74 0d                	je     8010a66f <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a662:	83 ec 0c             	sub    $0xc,%esp
8010a665:	68 b5 c7 10 80       	push   $0x8010c7b5
8010a66a:	e8 3a 5f ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a66f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a672:	8b 40 08             	mov    0x8(%eax),%eax
8010a675:	8b 15 ac 7c 19 80    	mov    0x80197cac,%edx
8010a67b:	39 d0                	cmp    %edx,%eax
8010a67d:	72 0d                	jb     8010a68c <iderw+0x78>
    panic("iderw: block out of range");
8010a67f:	83 ec 0c             	sub    $0xc,%esp
8010a682:	68 d3 c7 10 80       	push   $0x8010c7d3
8010a687:	e8 1d 5f ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a68c:	8b 15 b0 7c 19 80    	mov    0x80197cb0,%edx
8010a692:	8b 45 08             	mov    0x8(%ebp),%eax
8010a695:	8b 40 08             	mov    0x8(%eax),%eax
8010a698:	c1 e0 09             	shl    $0x9,%eax
8010a69b:	01 d0                	add    %edx,%eax
8010a69d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a6a0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6a3:	8b 00                	mov    (%eax),%eax
8010a6a5:	83 e0 04             	and    $0x4,%eax
8010a6a8:	85 c0                	test   %eax,%eax
8010a6aa:	74 2b                	je     8010a6d7 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a6ac:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6af:	8b 00                	mov    (%eax),%eax
8010a6b1:	83 e0 fb             	and    $0xfffffffb,%eax
8010a6b4:	89 c2                	mov    %eax,%edx
8010a6b6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6b9:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a6bb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6be:	83 c0 5c             	add    $0x5c,%eax
8010a6c1:	83 ec 04             	sub    $0x4,%esp
8010a6c4:	68 00 02 00 00       	push   $0x200
8010a6c9:	50                   	push   %eax
8010a6ca:	ff 75 f4             	push   -0xc(%ebp)
8010a6cd:	e8 49 a8 ff ff       	call   80104f1b <memmove>
8010a6d2:	83 c4 10             	add    $0x10,%esp
8010a6d5:	eb 1a                	jmp    8010a6f1 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a6d7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6da:	83 c0 5c             	add    $0x5c,%eax
8010a6dd:	83 ec 04             	sub    $0x4,%esp
8010a6e0:	68 00 02 00 00       	push   $0x200
8010a6e5:	ff 75 f4             	push   -0xc(%ebp)
8010a6e8:	50                   	push   %eax
8010a6e9:	e8 2d a8 ff ff       	call   80104f1b <memmove>
8010a6ee:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a6f1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6f4:	8b 00                	mov    (%eax),%eax
8010a6f6:	83 c8 02             	or     $0x2,%eax
8010a6f9:	89 c2                	mov    %eax,%edx
8010a6fb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6fe:	89 10                	mov    %edx,(%eax)
}
8010a700:	90                   	nop
8010a701:	c9                   	leave  
8010a702:	c3                   	ret    
