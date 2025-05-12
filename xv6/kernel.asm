
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
8010005a:	bc b0 b8 11 80       	mov    $0x8011b8b0,%esp
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
8010006f:	68 c0 a8 10 80       	push   $0x8010a8c0
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 62 4f 00 00       	call   80104fe0 <initlock>
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
801000bd:	68 c7 a8 10 80       	push   $0x8010a8c7
801000c2:	50                   	push   %eax
801000c3:	e8 bb 4d 00 00       	call   80104e83 <initsleeplock>
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
80100101:	e8 fc 4e 00 00       	call   80105002 <acquire>
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
80100140:	e8 2b 4f 00 00       	call   80105070 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 68 4d 00 00       	call   80104ebf <acquiresleep>
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
801001c1:	e8 aa 4e 00 00       	call   80105070 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 e7 4c 00 00       	call   80104ebf <acquiresleep>
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
801001f5:	68 ce a8 10 80       	push   $0x8010a8ce
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
8010024a:	e8 22 4d 00 00       	call   80104f71 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 df a8 10 80       	push   $0x8010a8df
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
80100293:	e8 d9 4c 00 00       	call   80104f71 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 e6 a8 10 80       	push   $0x8010a8e6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 68 4c 00 00       	call   80104f23 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 37 4d 00 00       	call   80105002 <acquire>
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
80100336:	e8 35 4d 00 00       	call   80105070 <release>
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
80100410:	e8 ed 4b 00 00       	call   80105002 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ed a8 10 80       	push   $0x8010a8ed
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
80100510:	c7 45 ec f6 a8 10 80 	movl   $0x8010a8f6,-0x14(%ebp)
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
8010059e:	e8 cd 4a 00 00       	call   80105070 <release>
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
801005c7:	68 fd a8 10 80       	push   $0x8010a8fd
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
801005e6:	68 11 a9 10 80       	push   $0x8010a911
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 bf 4a 00 00       	call   801050c2 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 13 a9 10 80       	push   $0x8010a913
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
801006a0:	e8 78 81 00 00       	call   8010881d <graphic_scroll_up>
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
801006f3:	e8 25 81 00 00       	call   8010881d <graphic_scroll_up>
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
80100757:	e8 2c 81 00 00       	call   80108888 <font_render>
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
80100793:	e8 fc 64 00 00       	call   80106c94 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 ef 64 00 00       	call   80106c94 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 e2 64 00 00       	call   80106c94 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 d2 64 00 00       	call   80106c94 <uartputc>
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
801007eb:	e8 12 48 00 00       	call   80105002 <acquire>
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
8010093f:	e8 37 42 00 00       	call   80104b7b <wakeup>
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
80100962:	e8 09 47 00 00       	call   80105070 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 c4 42 00 00       	call   80104c39 <procdump>
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
8010099a:	e8 63 46 00 00       	call   80105002 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 68 35 00 00       	call   80103f14 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 4a 11 80       	push   $0x80114a00
801009bb:	e8 b0 46 00 00       	call   80105070 <release>
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
801009e8:	e8 a4 40 00 00       	call   80104a91 <sleep>
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
80100a66:	e8 05 46 00 00       	call   80105070 <release>
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
80100aa2:	e8 5b 45 00 00       	call   80105002 <acquire>
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
80100ae4:	e8 87 45 00 00       	call   80105070 <release>
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
80100b12:	68 17 a9 10 80       	push   $0x8010a917
80100b17:	68 00 4a 11 80       	push   $0x80114a00
80100b1c:	e8 bf 44 00 00       	call   80104fe0 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 4a 11 80 86 	movl   $0x80100a86,0x80114a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 4a 11 80 78 	movl   $0x80100978,0x80114a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 1f a9 10 80 	movl   $0x8010a91f,-0xc(%ebp)
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
80100b89:	e8 86 33 00 00       	call   80103f14 <myproc>
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
80100bb5:	68 35 a9 10 80       	push   $0x8010a935
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
80100c11:	e8 7a 70 00 00       	call   80107c90 <setupkvm>
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
80100cb7:	e8 cd 73 00 00       	call   80108089 <allocuvm>
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
80100cfd:	e8 ba 72 00 00       	call   80107fbc <loaduvm>
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
80100d6c:	e8 18 73 00 00       	call   80108089 <allocuvm>
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
80100d90:	e8 56 75 00 00       	call   801082eb <clearpteu>
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
80100dc9:	e8 f8 46 00 00       	call   801054c6 <strlen>
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
80100df6:	e8 cb 46 00 00       	call   801054c6 <strlen>
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
80100e1c:	e8 69 76 00 00       	call   8010848a <copyout>
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
80100eb8:	e8 cd 75 00 00       	call   8010848a <copyout>
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
80100f06:	e8 70 45 00 00       	call   8010547b <safestrcpy>
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
80100f49:	e8 5f 6e 00 00       	call   80107dad <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 f6 72 00 00       	call   80108252 <freevm>
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
80100f97:	e8 b6 72 00 00       	call   80108252 <freevm>
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
80100fc8:	68 41 a9 10 80       	push   $0x8010a941
80100fcd:	68 a0 4a 11 80       	push   $0x80114aa0
80100fd2:	e8 09 40 00 00       	call   80104fe0 <initlock>
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
80100feb:	e8 12 40 00 00       	call   80105002 <acquire>
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
80101018:	e8 53 40 00 00       	call   80105070 <release>
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
8010103b:	e8 30 40 00 00       	call   80105070 <release>
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
80101058:	e8 a5 3f 00 00       	call   80105002 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 48 a9 10 80       	push   $0x8010a948
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
8010108e:	e8 dd 3f 00 00       	call   80105070 <release>
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
801010a9:	e8 54 3f 00 00       	call   80105002 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 50 a9 10 80       	push   $0x8010a950
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
801010e9:	e8 82 3f 00 00       	call   80105070 <release>
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
80101137:	e8 34 3f 00 00       	call   80105070 <release>
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
80101286:	68 5a a9 10 80       	push   $0x8010a95a
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
80101389:	68 63 a9 10 80       	push   $0x8010a963
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
801013bf:	68 73 a9 10 80       	push   $0x8010a973
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
801013f7:	e8 3b 3f 00 00       	call   80105337 <memmove>
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
8010143d:	e8 36 3e 00 00       	call   80105278 <memset>
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
8010159c:	68 80 a9 10 80       	push   $0x8010a980
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
80101627:	68 96 a9 10 80       	push   $0x8010a996
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
8010168b:	68 a9 a9 10 80       	push   $0x8010a9a9
80101690:	68 60 54 11 80       	push   $0x80115460
80101695:	e8 46 39 00 00       	call   80104fe0 <initlock>
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
801016c1:	68 b0 a9 10 80       	push   $0x8010a9b0
801016c6:	50                   	push   %eax
801016c7:	e8 b7 37 00 00       	call   80104e83 <initsleeplock>
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
80101720:	68 b8 a9 10 80       	push   $0x8010a9b8
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
80101799:	e8 da 3a 00 00       	call   80105278 <memset>
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
80101801:	68 0b aa 10 80       	push   $0x8010aa0b
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
801018a7:	e8 8b 3a 00 00       	call   80105337 <memmove>
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
801018dc:	e8 21 37 00 00       	call   80105002 <acquire>
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
8010192a:	e8 41 37 00 00       	call   80105070 <release>
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
80101966:	68 1d aa 10 80       	push   $0x8010aa1d
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
801019a3:	e8 c8 36 00 00       	call   80105070 <release>
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
801019be:	e8 3f 36 00 00       	call   80105002 <acquire>
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
801019dd:	e8 8e 36 00 00       	call   80105070 <release>
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
80101a03:	68 2d aa 10 80       	push   $0x8010aa2d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 a3 34 00 00       	call   80104ebf <acquiresleep>
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
80101ac1:	e8 71 38 00 00       	call   80105337 <memmove>
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
80101af0:	68 33 aa 10 80       	push   $0x8010aa33
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
80101b13:	e8 59 34 00 00       	call   80104f71 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 42 aa 10 80       	push   $0x8010aa42
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 de 33 00 00       	call   80104f23 <releasesleep>
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
80101b5b:	e8 5f 33 00 00       	call   80104ebf <acquiresleep>
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
80101b81:	e8 7c 34 00 00       	call   80105002 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 54 11 80       	push   $0x80115460
80101b9a:	e8 d1 34 00 00       	call   80105070 <release>
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
80101be1:	e8 3d 33 00 00       	call   80104f23 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 54 11 80       	push   $0x80115460
80101bf1:	e8 0c 34 00 00       	call   80105002 <acquire>
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
80101c10:	e8 5b 34 00 00       	call   80105070 <release>
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
80101d54:	68 4a aa 10 80       	push   $0x8010aa4a
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
80101ff2:	e8 40 33 00 00       	call   80105337 <memmove>
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
80102142:	e8 f0 31 00 00       	call   80105337 <memmove>
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
801021c2:	e8 06 32 00 00       	call   801053cd <strncmp>
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
801021e2:	68 5d aa 10 80       	push   $0x8010aa5d
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
80102211:	68 6f aa 10 80       	push   $0x8010aa6f
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
801022e6:	68 7e aa 10 80       	push   $0x8010aa7e
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
80102321:	e8 fd 30 00 00       	call   80105423 <strncpy>
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
8010234d:	68 8b aa 10 80       	push   $0x8010aa8b
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
801023bf:	e8 73 2f 00 00       	call   80105337 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 5c 2f 00 00       	call   80105337 <memmove>
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
80102425:	e8 ea 1a 00 00       	call   80103f14 <myproc>
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
8010262c:	68 93 aa 10 80       	push   $0x8010aa93
80102631:	68 c0 70 11 80       	push   $0x801170c0
80102636:	e8 a5 29 00 00       	call   80104fe0 <initlock>
8010263b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010263e:	a1 90 a5 11 80       	mov    0x8011a590,%eax
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
801026d3:	68 97 aa 10 80       	push   $0x8010aa97
801026d8:	e8 cc de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026dd:	8b 45 08             	mov    0x8(%ebp),%eax
801026e0:	8b 40 08             	mov    0x8(%eax),%eax
801026e3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e8:	76 0d                	jbe    801026f7 <idestart+0x33>
    panic("incorrect blockno");
801026ea:	83 ec 0c             	sub    $0xc,%esp
801026ed:	68 a0 aa 10 80       	push   $0x8010aaa0
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
80102740:	68 97 aa 10 80       	push   $0x8010aa97
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
80102864:	e8 99 27 00 00       	call   80105002 <acquire>
80102869:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010286c:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102871:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102874:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102878:	75 15                	jne    8010288f <ideintr+0x39>
    release(&idelock);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 c0 70 11 80       	push   $0x801170c0
80102882:	e8 e9 27 00 00       	call   80105070 <release>
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
801028f7:	e8 7f 22 00 00       	call   80104b7b <wakeup>
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
80102921:	e8 4a 27 00 00       	call   80105070 <release>
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
80102942:	68 b2 aa 10 80       	push   $0x8010aab2
80102947:	e8 a8 da ff ff       	call   801003f4 <cprintf>
8010294c:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	83 c0 0c             	add    $0xc,%eax
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	50                   	push   %eax
80102959:	e8 13 26 00 00       	call   80104f71 <holdingsleep>
8010295e:	83 c4 10             	add    $0x10,%esp
80102961:	85 c0                	test   %eax,%eax
80102963:	75 0d                	jne    80102972 <iderw+0x47>
    panic("iderw: buf not locked");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 cc aa 10 80       	push   $0x8010aacc
8010296d:	e8 37 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	8b 00                	mov    (%eax),%eax
80102977:	83 e0 06             	and    $0x6,%eax
8010297a:	83 f8 02             	cmp    $0x2,%eax
8010297d:	75 0d                	jne    8010298c <iderw+0x61>
    panic("iderw: nothing to do");
8010297f:	83 ec 0c             	sub    $0xc,%esp
80102982:	68 e2 aa 10 80       	push   $0x8010aae2
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
801029a2:	68 f7 aa 10 80       	push   $0x8010aaf7
801029a7:	e8 fd db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ac:	83 ec 0c             	sub    $0xc,%esp
801029af:	68 c0 70 11 80       	push   $0x801170c0
801029b4:	e8 49 26 00 00       	call   80105002 <acquire>
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
80102a10:	e8 7c 20 00 00       	call   80104a91 <sleep>
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
80102a2d:	e8 3e 26 00 00       	call   80105070 <release>
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
80102a9f:	0f b6 05 94 a5 11 80 	movzbl 0x8011a594,%eax
80102aa6:	0f b6 c0             	movzbl %al,%eax
80102aa9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102aac:	74 10                	je     80102abe <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aae:	83 ec 0c             	sub    $0xc,%esp
80102ab1:	68 18 ab 10 80       	push   $0x8010ab18
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
80102b58:	68 4a ab 10 80       	push   $0x8010ab4a
80102b5d:	68 00 71 11 80       	push   $0x80117100
80102b62:	e8 79 24 00 00       	call   80104fe0 <initlock>
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
80102c17:	68 4f ab 10 80       	push   $0x8010ab4f
80102c1c:	e8 88 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c21:	83 ec 04             	sub    $0x4,%esp
80102c24:	68 00 10 00 00       	push   $0x1000
80102c29:	6a 01                	push   $0x1
80102c2b:	ff 75 08             	push   0x8(%ebp)
80102c2e:	e8 45 26 00 00       	call   80105278 <memset>
80102c33:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c36:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c3b:	85 c0                	test   %eax,%eax
80102c3d:	74 10                	je     80102c4f <kfree+0x65>
    acquire(&kmem.lock);
80102c3f:	83 ec 0c             	sub    $0xc,%esp
80102c42:	68 00 71 11 80       	push   $0x80117100
80102c47:	e8 b6 23 00 00       	call   80105002 <acquire>
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
80102c79:	e8 f2 23 00 00       	call   80105070 <release>
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
80102c9b:	e8 62 23 00 00       	call   80105002 <acquire>
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
80102ccc:	e8 9f 23 00 00       	call   80105070 <release>
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
801031f6:	e8 e4 20 00 00       	call   801052df <memcmp>
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
8010330a:	68 55 ab 10 80       	push   $0x8010ab55
8010330f:	68 60 71 11 80       	push   $0x80117160
80103314:	e8 c7 1c 00 00       	call   80104fe0 <initlock>
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
801033bf:	e8 73 1f 00 00       	call   80105337 <memmove>
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
8010352e:	e8 cf 1a 00 00       	call   80105002 <acquire>
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
8010354c:	e8 40 15 00 00       	call   80104a91 <sleep>
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
80103581:	e8 0b 15 00 00       	call   80104a91 <sleep>
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
801035a0:	e8 cb 1a 00 00       	call   80105070 <release>
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
801035c1:	e8 3c 1a 00 00       	call   80105002 <acquire>
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
801035e2:	68 59 ab 10 80       	push   $0x8010ab59
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
80103610:	e8 66 15 00 00       	call   80104b7b <wakeup>
80103615:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103618:	83 ec 0c             	sub    $0xc,%esp
8010361b:	68 60 71 11 80       	push   $0x80117160
80103620:	e8 4b 1a 00 00       	call   80105070 <release>
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
8010363b:	e8 c2 19 00 00       	call   80105002 <acquire>
80103640:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103643:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364a:	00 00 00 
    wakeup(&log);
8010364d:	83 ec 0c             	sub    $0xc,%esp
80103650:	68 60 71 11 80       	push   $0x80117160
80103655:	e8 21 15 00 00       	call   80104b7b <wakeup>
8010365a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	68 60 71 11 80       	push   $0x80117160
80103665:	e8 06 1a 00 00       	call   80105070 <release>
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
801036e1:	e8 51 1c 00 00       	call   80105337 <memmove>
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
8010377e:	68 68 ab 10 80       	push   $0x8010ab68
80103783:	e8 21 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103788:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378d:	85 c0                	test   %eax,%eax
8010378f:	7f 0d                	jg     8010379e <log_write+0x45>
    panic("log_write outside of trans");
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 7e ab 10 80       	push   $0x8010ab7e
80103799:	e8 0b ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 71 11 80       	push   $0x80117160
801037a6:	e8 57 18 00 00       	call   80105002 <acquire>
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
80103824:	e8 47 18 00 00       	call   80105070 <release>
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
8010385a:	e8 03 4f 00 00       	call   80108762 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010385f:	83 ec 08             	sub    $0x8,%esp
80103862:	68 00 00 40 80       	push   $0x80400000
80103867:	68 00 c0 11 80       	push   $0x8011c000
8010386c:	e8 de f2 ff ff       	call   80102b4f <kinit1>
80103871:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103874:	e8 03 45 00 00       	call   80107d7c <kvmalloc>
  mpinit_uefi();
80103879:	e8 aa 4c 00 00       	call   80108528 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010387e:	e8 3c f6 ff ff       	call   80102ebf <lapicinit>
  seginit();       // segment descriptors
80103883:	e8 8c 3f 00 00       	call   80107814 <seginit>
  picinit();    // disable pic
80103888:	e8 9d 01 00 00       	call   80103a2a <picinit>
  ioapicinit();    // another interrupt controller
8010388d:	e8 d8 f1 ff ff       	call   80102a6a <ioapicinit>
  consoleinit();   // console hardware
80103892:	e8 68 d2 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
80103897:	e8 11 33 00 00       	call   80106bad <uartinit>
  pinit();         // process table
8010389c:	e8 c2 05 00 00       	call   80103e63 <pinit>
  tvinit();        // trap vectors
801038a1:	e8 1e 2e 00 00       	call   801066c4 <tvinit>
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
801038cf:	e8 e7 50 00 00       	call   801089bb <pci_init>
  arp_scan();
801038d4:	e8 1e 5e 00 00       	call   801096f7 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038d9:	e8 9e 07 00 00       	call   8010407c <userinit>

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
801038e9:	e8 a6 44 00 00       	call   80107d94 <switchkvm>
  seginit();
801038ee:	e8 21 3f 00 00       	call   80107814 <seginit>
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
80103904:	e8 78 05 00 00       	call   80103e81 <cpuid>
80103909:	89 c3                	mov    %eax,%ebx
8010390b:	e8 71 05 00 00       	call   80103e81 <cpuid>
80103910:	83 ec 04             	sub    $0x4,%esp
80103913:	53                   	push   %ebx
80103914:	50                   	push   %eax
80103915:	68 99 ab 10 80       	push   $0x8010ab99
8010391a:	e8 d5 ca ff ff       	call   801003f4 <cprintf>
8010391f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103922:	e8 13 2f 00 00       	call   8010683a <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103927:	e8 70 05 00 00       	call   80103e9c <mycpu>
8010392c:	05 a0 00 00 00       	add    $0xa0,%eax
80103931:	83 ec 08             	sub    $0x8,%esp
80103934:	6a 01                	push   $0x1
80103936:	50                   	push   %eax
80103937:	e8 f3 fe ff ff       	call   8010382f <xchg>
8010393c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010393f:	e8 c9 0c 00 00       	call   8010460d <scheduler>

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
8010395a:	68 18 f5 10 80       	push   $0x8010f518
8010395f:	ff 75 f0             	push   -0x10(%ebp)
80103962:	e8 d0 19 00 00       	call   80105337 <memmove>
80103967:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396a:	c7 45 f4 c0 a2 11 80 	movl   $0x8011a2c0,-0xc(%ebp)
80103971:	eb 79                	jmp    801039ec <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103973:	e8 24 05 00 00       	call   80103e9c <mycpu>
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
801039ec:	a1 90 a5 11 80       	mov    0x8011a590,%eax
801039f1:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039f7:	05 c0 a2 11 80       	add    $0x8011a2c0,%eax
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
80103aeb:	68 ad ab 10 80       	push   $0x8010abad
80103af0:	50                   	push   %eax
80103af1:	e8 ea 14 00 00       	call   80104fe0 <initlock>
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
80103bb0:	e8 4d 14 00 00       	call   80105002 <acquire>
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
80103bd7:	e8 9f 0f 00 00       	call   80104b7b <wakeup>
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
80103bfa:	e8 7c 0f 00 00       	call   80104b7b <wakeup>
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
80103c23:	e8 48 14 00 00       	call   80105070 <release>
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
80103c42:	e8 29 14 00 00       	call   80105070 <release>
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
80103c5c:	e8 a1 13 00 00       	call   80105002 <acquire>
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
80103c7d:	e8 92 02 00 00       	call   80103f14 <myproc>
80103c82:	8b 40 24             	mov    0x24(%eax),%eax
80103c85:	85 c0                	test   %eax,%eax
80103c87:	74 19                	je     80103ca2 <pipewrite+0x54>
        release(&p->lock);
80103c89:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	50                   	push   %eax
80103c90:	e8 db 13 00 00       	call   80105070 <release>
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
80103cae:	e8 c8 0e 00 00       	call   80104b7b <wakeup>
80103cb3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103cbc:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc2:	83 ec 08             	sub    $0x8,%esp
80103cc5:	50                   	push   %eax
80103cc6:	52                   	push   %edx
80103cc7:	e8 c5 0d 00 00       	call   80104a91 <sleep>
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
80103d31:	e8 45 0e 00 00       	call   80104b7b <wakeup>
80103d36:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d39:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3c:	83 ec 0c             	sub    $0xc,%esp
80103d3f:	50                   	push   %eax
80103d40:	e8 2b 13 00 00       	call   80105070 <release>
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
80103d5d:	e8 a0 12 00 00       	call   80105002 <acquire>
80103d62:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d65:	eb 3e                	jmp    80103da5 <piperead+0x55>
    if(myproc()->killed){
80103d67:	e8 a8 01 00 00       	call   80103f14 <myproc>
80103d6c:	8b 40 24             	mov    0x24(%eax),%eax
80103d6f:	85 c0                	test   %eax,%eax
80103d71:	74 19                	je     80103d8c <piperead+0x3c>
      release(&p->lock);
80103d73:	8b 45 08             	mov    0x8(%ebp),%eax
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	50                   	push   %eax
80103d7a:	e8 f1 12 00 00       	call   80105070 <release>
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
80103d9d:	e8 ef 0c 00 00       	call   80104a91 <sleep>
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
80103e30:	e8 46 0d 00 00       	call   80104b7b <wakeup>
80103e35:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	50                   	push   %eax
80103e3f:	e8 2c 12 00 00       	call   80105070 <release>
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
80103e66:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103e69:	83 ec 08             	sub    $0x8,%esp
80103e6c:	68 b4 ab 10 80       	push   $0x8010abb4
80103e71:	68 40 72 11 80       	push   $0x80117240
80103e76:	e8 65 11 00 00       	call   80104fe0 <initlock>
80103e7b:	83 c4 10             	add    $0x10,%esp
}
80103e7e:	90                   	nop
80103e7f:	c9                   	leave  
80103e80:	c3                   	ret    

80103e81 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103e81:	55                   	push   %ebp
80103e82:	89 e5                	mov    %esp,%ebp
80103e84:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e87:	e8 10 00 00 00       	call   80103e9c <mycpu>
80103e8c:	2d c0 a2 11 80       	sub    $0x8011a2c0,%eax
80103e91:	c1 f8 02             	sar    $0x2,%eax
80103e94:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
80103e9a:	c9                   	leave  
80103e9b:	c3                   	ret    

80103e9c <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103e9c:	55                   	push   %ebp
80103e9d:	89 e5                	mov    %esp,%ebp
80103e9f:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ea2:	e8 a5 ff ff ff       	call   80103e4c <readeflags>
80103ea7:	25 00 02 00 00       	and    $0x200,%eax
80103eac:	85 c0                	test   %eax,%eax
80103eae:	74 0d                	je     80103ebd <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103eb0:	83 ec 0c             	sub    $0xc,%esp
80103eb3:	68 bc ab 10 80       	push   $0x8010abbc
80103eb8:	e8 ec c6 ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103ebd:	e8 1c f1 ff ff       	call   80102fde <lapicid>
80103ec2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ec5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ecc:	eb 2d                	jmp    80103efb <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed1:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103ed7:	05 c0 a2 11 80       	add    $0x8011a2c0,%eax
80103edc:	0f b6 00             	movzbl (%eax),%eax
80103edf:	0f b6 c0             	movzbl %al,%eax
80103ee2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103ee5:	75 10                	jne    80103ef7 <mycpu+0x5b>
      return &cpus[i];
80103ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eea:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103ef0:	05 c0 a2 11 80       	add    $0x8011a2c0,%eax
80103ef5:	eb 1b                	jmp    80103f12 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103ef7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103efb:	a1 90 a5 11 80       	mov    0x8011a590,%eax
80103f00:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103f03:	7c c9                	jl     80103ece <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103f05:	83 ec 0c             	sub    $0xc,%esp
80103f08:	68 e2 ab 10 80       	push   $0x8010abe2
80103f0d:	e8 97 c6 ff ff       	call   801005a9 <panic>
}
80103f12:	c9                   	leave  
80103f13:	c3                   	ret    

80103f14 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f14:	55                   	push   %ebp
80103f15:	89 e5                	mov    %esp,%ebp
80103f17:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103f1a:	e8 4e 12 00 00       	call   8010516d <pushcli>
  c = mycpu();
80103f1f:	e8 78 ff ff ff       	call   80103e9c <mycpu>
80103f24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f33:	e8 82 12 00 00       	call   801051ba <popcli>
  return p;
80103f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f3b:	c9                   	leave  
80103f3c:	c3                   	ret    

80103f3d <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f3d:	55                   	push   %ebp
80103f3e:	89 e5                	mov    %esp,%ebp
80103f40:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f43:	83 ec 0c             	sub    $0xc,%esp
80103f46:	68 40 72 11 80       	push   $0x80117240
80103f4b:	e8 b2 10 00 00       	call   80105002 <acquire>
80103f50:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f53:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f5a:	eb 11                	jmp    80103f6d <allocproc+0x30>
    if(p->state == UNUSED){
80103f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f5f:	8b 40 0c             	mov    0xc(%eax),%eax
80103f62:	85 c0                	test   %eax,%eax
80103f64:	74 2a                	je     80103f90 <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f66:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80103f6d:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80103f74:	72 e6                	jb     80103f5c <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103f76:	83 ec 0c             	sub    $0xc,%esp
80103f79:	68 40 72 11 80       	push   $0x80117240
80103f7e:	e8 ed 10 00 00       	call   80105070 <release>
80103f83:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f86:	b8 00 00 00 00       	mov    $0x0,%eax
80103f8b:	e9 ea 00 00 00       	jmp    8010407a <allocproc+0x13d>
      goto found;
80103f90:	90                   	nop

found:
  p->state = EMBRYO;
80103f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f94:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103f9b:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103fa0:	8d 50 01             	lea    0x1(%eax),%edx
80103fa3:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fa9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fac:	89 42 10             	mov    %eax,0x10(%edx)
  
  release(&ptable.lock);
80103faf:	83 ec 0c             	sub    $0xc,%esp
80103fb2:	68 40 72 11 80       	push   $0x80117240
80103fb7:	e8 b4 10 00 00       	call   80105070 <release>
80103fbc:	83 c4 10             	add    $0x10,%esp
  
  p->priority = 3; //Q3에서 시작
80103fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc2:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  memset(p->ticks, 0, sizeof(p->ticks)); //초기화
80103fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcc:	83 e8 80             	sub    $0xffffff80,%eax
80103fcf:	83 ec 04             	sub    $0x4,%esp
80103fd2:	6a 10                	push   $0x10
80103fd4:	6a 00                	push   $0x0
80103fd6:	50                   	push   %eax
80103fd7:	e8 9c 12 00 00       	call   80105278 <memset>
80103fdc:	83 c4 10             	add    $0x10,%esp
  memset(p->wait_ticks, 0, sizeof(p->wait_ticks)); // 초기화
80103fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe2:	05 90 00 00 00       	add    $0x90,%eax
80103fe7:	83 ec 04             	sub    $0x4,%esp
80103fea:	6a 10                	push   $0x10
80103fec:	6a 00                	push   $0x0
80103fee:	50                   	push   %eax
80103fef:	e8 84 12 00 00       	call   80105278 <memset>
80103ff4:	83 c4 10             	add    $0x10,%esp

  


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ff7:	e8 88 ec ff ff       	call   80102c84 <kalloc>
80103ffc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fff:	89 42 08             	mov    %eax,0x8(%edx)
80104002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104005:	8b 40 08             	mov    0x8(%eax),%eax
80104008:	85 c0                	test   %eax,%eax
8010400a:	75 11                	jne    8010401d <allocproc+0xe0>
    p->state = UNUSED;
8010400c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104016:	b8 00 00 00 00       	mov    $0x0,%eax
8010401b:	eb 5d                	jmp    8010407a <allocproc+0x13d>
  }
  sp = p->kstack + KSTACKSIZE;
8010401d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104020:	8b 40 08             	mov    0x8(%eax),%eax
80104023:	05 00 10 00 00       	add    $0x1000,%eax
80104028:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010402b:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010402f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104032:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104035:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104038:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010403c:	ba 7e 66 10 80       	mov    $0x8010667e,%edx
80104041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104044:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104046:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010404a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104050:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104056:	8b 40 1c             	mov    0x1c(%eax),%eax
80104059:	83 ec 04             	sub    $0x4,%esp
8010405c:	6a 14                	push   $0x14
8010405e:	6a 00                	push   $0x0
80104060:	50                   	push   %eax
80104061:	e8 12 12 00 00       	call   80105278 <memset>
80104066:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010406f:	ba 4b 4a 10 80       	mov    $0x80104a4b,%edx
80104074:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104077:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010407a:	c9                   	leave  
8010407b:	c3                   	ret    

8010407c <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010407c:	55                   	push   %ebp
8010407d:	89 e5                	mov    %esp,%ebp
8010407f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104082:	e8 b6 fe ff ff       	call   80103f3d <allocproc>
80104087:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010408a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408d:	a3 74 9a 11 80       	mov    %eax,0x80119a74
  if((p->pgdir = setupkvm()) == 0){
80104092:	e8 f9 3b 00 00       	call   80107c90 <setupkvm>
80104097:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010409a:	89 42 04             	mov    %eax,0x4(%edx)
8010409d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a0:	8b 40 04             	mov    0x4(%eax),%eax
801040a3:	85 c0                	test   %eax,%eax
801040a5:	75 0d                	jne    801040b4 <userinit+0x38>
    panic("userinit: out of memory?");
801040a7:	83 ec 0c             	sub    $0xc,%esp
801040aa:	68 f2 ab 10 80       	push   $0x8010abf2
801040af:	e8 f5 c4 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801040b4:	ba 2c 00 00 00       	mov    $0x2c,%edx
801040b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bc:	8b 40 04             	mov    0x4(%eax),%eax
801040bf:	83 ec 04             	sub    $0x4,%esp
801040c2:	52                   	push   %edx
801040c3:	68 ec f4 10 80       	push   $0x8010f4ec
801040c8:	50                   	push   %eax
801040c9:	e8 7e 3e 00 00       	call   80107f4c <inituvm>
801040ce:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801040d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d4:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801040da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040dd:	8b 40 18             	mov    0x18(%eax),%eax
801040e0:	83 ec 04             	sub    $0x4,%esp
801040e3:	6a 4c                	push   $0x4c
801040e5:	6a 00                	push   $0x0
801040e7:	50                   	push   %eax
801040e8:	e8 8b 11 00 00       	call   80105278 <memset>
801040ed:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801040f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f3:	8b 40 18             	mov    0x18(%eax),%eax
801040f6:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801040fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ff:	8b 40 18             	mov    0x18(%eax),%eax
80104102:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410b:	8b 50 18             	mov    0x18(%eax),%edx
8010410e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104111:	8b 40 18             	mov    0x18(%eax),%eax
80104114:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104118:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411f:	8b 50 18             	mov    0x18(%eax),%edx
80104122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104125:	8b 40 18             	mov    0x18(%eax),%eax
80104128:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010412c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104133:	8b 40 18             	mov    0x18(%eax),%eax
80104136:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010413d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104140:	8b 40 18             	mov    0x18(%eax),%eax
80104143:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010414a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414d:	8b 40 18             	mov    0x18(%eax),%eax
80104150:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415a:	83 c0 6c             	add    $0x6c,%eax
8010415d:	83 ec 04             	sub    $0x4,%esp
80104160:	6a 10                	push   $0x10
80104162:	68 0b ac 10 80       	push   $0x8010ac0b
80104167:	50                   	push   %eax
80104168:	e8 0e 13 00 00       	call   8010547b <safestrcpy>
8010416d:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104170:	83 ec 0c             	sub    $0xc,%esp
80104173:	68 14 ac 10 80       	push   $0x8010ac14
80104178:	e8 a0 e3 ff ff       	call   8010251d <namei>
8010417d:	83 c4 10             	add    $0x10,%esp
80104180:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104183:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104186:	83 ec 0c             	sub    $0xc,%esp
80104189:	68 40 72 11 80       	push   $0x80117240
8010418e:	e8 6f 0e 00 00       	call   80105002 <acquire>
80104193:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104199:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801041a0:	83 ec 0c             	sub    $0xc,%esp
801041a3:	68 40 72 11 80       	push   $0x80117240
801041a8:	e8 c3 0e 00 00       	call   80105070 <release>
801041ad:	83 c4 10             	add    $0x10,%esp
}
801041b0:	90                   	nop
801041b1:	c9                   	leave  
801041b2:	c3                   	ret    

801041b3 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801041b3:	55                   	push   %ebp
801041b4:	89 e5                	mov    %esp,%ebp
801041b6:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
801041b9:	e8 56 fd ff ff       	call   80103f14 <myproc>
801041be:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801041c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041c4:	8b 00                	mov    (%eax),%eax
801041c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801041c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041cd:	7e 2e                	jle    801041fd <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041cf:	8b 55 08             	mov    0x8(%ebp),%edx
801041d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d5:	01 c2                	add    %eax,%edx
801041d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041da:	8b 40 04             	mov    0x4(%eax),%eax
801041dd:	83 ec 04             	sub    $0x4,%esp
801041e0:	52                   	push   %edx
801041e1:	ff 75 f4             	push   -0xc(%ebp)
801041e4:	50                   	push   %eax
801041e5:	e8 9f 3e 00 00       	call   80108089 <allocuvm>
801041ea:	83 c4 10             	add    $0x10,%esp
801041ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041f4:	75 3b                	jne    80104231 <growproc+0x7e>
      return -1;
801041f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041fb:	eb 4f                	jmp    8010424c <growproc+0x99>
  } else if(n < 0){
801041fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104201:	79 2e                	jns    80104231 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104203:	8b 55 08             	mov    0x8(%ebp),%edx
80104206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104209:	01 c2                	add    %eax,%edx
8010420b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010420e:	8b 40 04             	mov    0x4(%eax),%eax
80104211:	83 ec 04             	sub    $0x4,%esp
80104214:	52                   	push   %edx
80104215:	ff 75 f4             	push   -0xc(%ebp)
80104218:	50                   	push   %eax
80104219:	e8 70 3f 00 00       	call   8010818e <deallocuvm>
8010421e:	83 c4 10             	add    $0x10,%esp
80104221:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104224:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104228:	75 07                	jne    80104231 <growproc+0x7e>
      return -1;
8010422a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010422f:	eb 1b                	jmp    8010424c <growproc+0x99>
  }
  curproc->sz = sz;
80104231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104234:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104237:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104239:	83 ec 0c             	sub    $0xc,%esp
8010423c:	ff 75 f0             	push   -0x10(%ebp)
8010423f:	e8 69 3b 00 00       	call   80107dad <switchuvm>
80104244:	83 c4 10             	add    $0x10,%esp
  return 0;
80104247:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010424c:	c9                   	leave  
8010424d:	c3                   	ret    

8010424e <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010424e:	55                   	push   %ebp
8010424f:	89 e5                	mov    %esp,%ebp
80104251:	57                   	push   %edi
80104252:	56                   	push   %esi
80104253:	53                   	push   %ebx
80104254:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104257:	e8 b8 fc ff ff       	call   80103f14 <myproc>
8010425c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010425f:	e8 d9 fc ff ff       	call   80103f3d <allocproc>
80104264:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104267:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010426b:	75 0a                	jne    80104277 <fork+0x29>
    return -1;
8010426d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104272:	e9 48 01 00 00       	jmp    801043bf <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104277:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010427a:	8b 10                	mov    (%eax),%edx
8010427c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010427f:	8b 40 04             	mov    0x4(%eax),%eax
80104282:	83 ec 08             	sub    $0x8,%esp
80104285:	52                   	push   %edx
80104286:	50                   	push   %eax
80104287:	e8 a0 40 00 00       	call   8010832c <copyuvm>
8010428c:	83 c4 10             	add    $0x10,%esp
8010428f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104292:	89 42 04             	mov    %eax,0x4(%edx)
80104295:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104298:	8b 40 04             	mov    0x4(%eax),%eax
8010429b:	85 c0                	test   %eax,%eax
8010429d:	75 30                	jne    801042cf <fork+0x81>
    kfree(np->kstack);
8010429f:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042a2:	8b 40 08             	mov    0x8(%eax),%eax
801042a5:	83 ec 0c             	sub    $0xc,%esp
801042a8:	50                   	push   %eax
801042a9:	e8 3c e9 ff ff       	call   80102bea <kfree>
801042ae:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801042b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042b4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801042bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042be:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801042c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042ca:	e9 f0 00 00 00       	jmp    801043bf <fork+0x171>
  }
  np->sz = curproc->sz;
801042cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042d2:	8b 10                	mov    (%eax),%edx
801042d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042d7:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801042d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042df:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801042e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042e5:	8b 48 18             	mov    0x18(%eax),%ecx
801042e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042eb:	8b 40 18             	mov    0x18(%eax),%eax
801042ee:	89 c2                	mov    %eax,%edx
801042f0:	89 cb                	mov    %ecx,%ebx
801042f2:	b8 13 00 00 00       	mov    $0x13,%eax
801042f7:	89 d7                	mov    %edx,%edi
801042f9:	89 de                	mov    %ebx,%esi
801042fb:	89 c1                	mov    %eax,%ecx
801042fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801042ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104302:	8b 40 18             	mov    0x18(%eax),%eax
80104305:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010430c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104313:	eb 3b                	jmp    80104350 <fork+0x102>
    if(curproc->ofile[i])
80104315:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104318:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010431b:	83 c2 08             	add    $0x8,%edx
8010431e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104322:	85 c0                	test   %eax,%eax
80104324:	74 26                	je     8010434c <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104326:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104329:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010432c:	83 c2 08             	add    $0x8,%edx
8010432f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104333:	83 ec 0c             	sub    $0xc,%esp
80104336:	50                   	push   %eax
80104337:	e8 0e cd ff ff       	call   8010104a <filedup>
8010433c:	83 c4 10             	add    $0x10,%esp
8010433f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104342:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104345:	83 c1 08             	add    $0x8,%ecx
80104348:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010434c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104350:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104354:	7e bf                	jle    80104315 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80104356:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104359:	8b 40 68             	mov    0x68(%eax),%eax
8010435c:	83 ec 0c             	sub    $0xc,%esp
8010435f:	50                   	push   %eax
80104360:	e8 4b d6 ff ff       	call   801019b0 <idup>
80104365:	83 c4 10             	add    $0x10,%esp
80104368:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010436b:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010436e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104371:	8d 50 6c             	lea    0x6c(%eax),%edx
80104374:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104377:	83 c0 6c             	add    $0x6c,%eax
8010437a:	83 ec 04             	sub    $0x4,%esp
8010437d:	6a 10                	push   $0x10
8010437f:	52                   	push   %edx
80104380:	50                   	push   %eax
80104381:	e8 f5 10 00 00       	call   8010547b <safestrcpy>
80104386:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104389:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010438c:	8b 40 10             	mov    0x10(%eax),%eax
8010438f:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104392:	83 ec 0c             	sub    $0xc,%esp
80104395:	68 40 72 11 80       	push   $0x80117240
8010439a:	e8 63 0c 00 00       	call   80105002 <acquire>
8010439f:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801043a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043a5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801043ac:	83 ec 0c             	sub    $0xc,%esp
801043af:	68 40 72 11 80       	push   $0x80117240
801043b4:	e8 b7 0c 00 00       	call   80105070 <release>
801043b9:	83 c4 10             	add    $0x10,%esp

  return pid;
801043bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801043bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801043c2:	5b                   	pop    %ebx
801043c3:	5e                   	pop    %esi
801043c4:	5f                   	pop    %edi
801043c5:	5d                   	pop    %ebp
801043c6:	c3                   	ret    

801043c7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801043c7:	55                   	push   %ebp
801043c8:	89 e5                	mov    %esp,%ebp
801043ca:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801043cd:	e8 42 fb ff ff       	call   80103f14 <myproc>
801043d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801043d5:	a1 74 9a 11 80       	mov    0x80119a74,%eax
801043da:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801043dd:	75 0d                	jne    801043ec <exit+0x25>
    panic("init exiting");
801043df:	83 ec 0c             	sub    $0xc,%esp
801043e2:	68 16 ac 10 80       	push   $0x8010ac16
801043e7:	e8 bd c1 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801043ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801043f3:	eb 3f                	jmp    80104434 <exit+0x6d>
    if(curproc->ofile[fd]){
801043f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043fb:	83 c2 08             	add    $0x8,%edx
801043fe:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104402:	85 c0                	test   %eax,%eax
80104404:	74 2a                	je     80104430 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80104406:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104409:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010440c:	83 c2 08             	add    $0x8,%edx
8010440f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104413:	83 ec 0c             	sub    $0xc,%esp
80104416:	50                   	push   %eax
80104417:	e8 7f cc ff ff       	call   8010109b <fileclose>
8010441c:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010441f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104422:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104425:	83 c2 08             	add    $0x8,%edx
80104428:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010442f:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104430:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104434:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104438:	7e bb                	jle    801043f5 <exit+0x2e>
    }
  }

  begin_op();
8010443a:	e8 e1 f0 ff ff       	call   80103520 <begin_op>
  iput(curproc->cwd);
8010443f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104442:	8b 40 68             	mov    0x68(%eax),%eax
80104445:	83 ec 0c             	sub    $0xc,%esp
80104448:	50                   	push   %eax
80104449:	e8 fd d6 ff ff       	call   80101b4b <iput>
8010444e:	83 c4 10             	add    $0x10,%esp
  end_op();
80104451:	e8 56 f1 ff ff       	call   801035ac <end_op>
  curproc->cwd = 0;
80104456:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104459:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104460:	83 ec 0c             	sub    $0xc,%esp
80104463:	68 40 72 11 80       	push   $0x80117240
80104468:	e8 95 0b 00 00       	call   80105002 <acquire>
8010446d:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104470:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104473:	8b 40 14             	mov    0x14(%eax),%eax
80104476:	83 ec 0c             	sub    $0xc,%esp
80104479:	50                   	push   %eax
8010447a:	e8 b9 06 00 00       	call   80104b38 <wakeup1>
8010447f:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104482:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104489:	eb 3a                	jmp    801044c5 <exit+0xfe>
    if(p->parent == curproc){
8010448b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448e:	8b 40 14             	mov    0x14(%eax),%eax
80104491:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104494:	75 28                	jne    801044be <exit+0xf7>
      p->parent = initproc;
80104496:	8b 15 74 9a 11 80    	mov    0x80119a74,%edx
8010449c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449f:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801044a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a5:	8b 40 0c             	mov    0xc(%eax),%eax
801044a8:	83 f8 05             	cmp    $0x5,%eax
801044ab:	75 11                	jne    801044be <exit+0xf7>
        wakeup1(initproc);
801044ad:	a1 74 9a 11 80       	mov    0x80119a74,%eax
801044b2:	83 ec 0c             	sub    $0xc,%esp
801044b5:	50                   	push   %eax
801044b6:	e8 7d 06 00 00       	call   80104b38 <wakeup1>
801044bb:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044be:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801044c5:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
801044cc:	72 bd                	jb     8010448b <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801044ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044d1:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801044d8:	e8 7b 04 00 00       	call   80104958 <sched>
  panic("zombie exit");
801044dd:	83 ec 0c             	sub    $0xc,%esp
801044e0:	68 23 ac 10 80       	push   $0x8010ac23
801044e5:	e8 bf c0 ff ff       	call   801005a9 <panic>

801044ea <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801044ea:	55                   	push   %ebp
801044eb:	89 e5                	mov    %esp,%ebp
801044ed:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801044f0:	e8 1f fa ff ff       	call   80103f14 <myproc>
801044f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801044f8:	83 ec 0c             	sub    $0xc,%esp
801044fb:	68 40 72 11 80       	push   $0x80117240
80104500:	e8 fd 0a 00 00       	call   80105002 <acquire>
80104505:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104508:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010450f:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104516:	e9 a4 00 00 00       	jmp    801045bf <wait+0xd5>
      if(p->parent != curproc)
8010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451e:	8b 40 14             	mov    0x14(%eax),%eax
80104521:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104524:	0f 85 8d 00 00 00    	jne    801045b7 <wait+0xcd>
        continue;
      havekids = 1;
8010452a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104534:	8b 40 0c             	mov    0xc(%eax),%eax
80104537:	83 f8 05             	cmp    $0x5,%eax
8010453a:	75 7c                	jne    801045b8 <wait+0xce>
        // Found one.
        pid = p->pid;
8010453c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453f:	8b 40 10             	mov    0x10(%eax),%eax
80104542:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104548:	8b 40 08             	mov    0x8(%eax),%eax
8010454b:	83 ec 0c             	sub    $0xc,%esp
8010454e:	50                   	push   %eax
8010454f:	e8 96 e6 ff ff       	call   80102bea <kfree>
80104554:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104564:	8b 40 04             	mov    0x4(%eax),%eax
80104567:	83 ec 0c             	sub    $0xc,%esp
8010456a:	50                   	push   %eax
8010456b:	e8 e2 3c 00 00       	call   80108252 <freevm>
80104570:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104576:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010457d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104580:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104591:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801045a2:	83 ec 0c             	sub    $0xc,%esp
801045a5:	68 40 72 11 80       	push   $0x80117240
801045aa:	e8 c1 0a 00 00       	call   80105070 <release>
801045af:	83 c4 10             	add    $0x10,%esp
        return pid;
801045b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801045b5:	eb 54                	jmp    8010460b <wait+0x121>
        continue;
801045b7:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045b8:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801045bf:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
801045c6:	0f 82 4f ff ff ff    	jb     8010451b <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801045cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801045d0:	74 0a                	je     801045dc <wait+0xf2>
801045d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045d5:	8b 40 24             	mov    0x24(%eax),%eax
801045d8:	85 c0                	test   %eax,%eax
801045da:	74 17                	je     801045f3 <wait+0x109>
      release(&ptable.lock);
801045dc:	83 ec 0c             	sub    $0xc,%esp
801045df:	68 40 72 11 80       	push   $0x80117240
801045e4:	e8 87 0a 00 00       	call   80105070 <release>
801045e9:	83 c4 10             	add    $0x10,%esp
      return -1;
801045ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045f1:	eb 18                	jmp    8010460b <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801045f3:	83 ec 08             	sub    $0x8,%esp
801045f6:	68 40 72 11 80       	push   $0x80117240
801045fb:	ff 75 ec             	push   -0x14(%ebp)
801045fe:	e8 8e 04 00 00       	call   80104a91 <sleep>
80104603:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104606:	e9 fd fe ff ff       	jmp    80104508 <wait+0x1e>
  }
}
8010460b:	c9                   	leave  
8010460c:	c3                   	ret    

8010460d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010460d:	55                   	push   %ebp
8010460e:	89 e5                	mov    %esp,%ebp
80104610:	83 ec 48             	sub    $0x48,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104613:	e8 84 f8 ff ff       	call   80103e9c <mycpu>
80104618:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  c->proc = 0;
8010461b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010461e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104625:	00 00 00 

  for (;;) {
    sti();  // 인터럽트 허용
80104628:	e8 2f f8 ff ff       	call   80103e5c <sti>

    acquire(&ptable.lock);
8010462d:	83 ec 0c             	sub    $0xc,%esp
80104630:	68 40 72 11 80       	push   $0x80117240
80104635:	e8 c8 09 00 00       	call   80105002 <acquire>
8010463a:	83 c4 10             	add    $0x10,%esp

    int policy = c->sched_policy;  // 현재 설정된 스케줄링 정책
8010463d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104640:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104646:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
    //RR
    if (policy == 0) {
80104649:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010464d:	75 7b                	jne    801046ca <scheduler+0xbd>
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010464f:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104656:	eb 64                	jmp    801046bc <scheduler+0xaf>
        if (p->state != RUNNABLE)
80104658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465b:	8b 40 0c             	mov    0xc(%eax),%eax
8010465e:	83 f8 03             	cmp    $0x3,%eax
80104661:	75 51                	jne    801046b4 <scheduler+0xa7>
          continue;

        c->proc = p;
80104663:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104666:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104669:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
8010466f:	83 ec 0c             	sub    $0xc,%esp
80104672:	ff 75 f4             	push   -0xc(%ebp)
80104675:	e8 33 37 00 00       	call   80107dad <switchuvm>
8010467a:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
8010467d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104680:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
80104687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010468d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104690:	83 c2 04             	add    $0x4,%edx
80104693:	83 ec 08             	sub    $0x8,%esp
80104696:	50                   	push   %eax
80104697:	52                   	push   %edx
80104698:	e8 50 0e 00 00       	call   801054ed <swtch>
8010469d:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801046a0:	e8 ef 36 00 00       	call   80107d94 <switchkvm>
        c->proc = 0;
801046a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801046a8:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801046af:	00 00 00 
801046b2:	eb 01                	jmp    801046b5 <scheduler+0xa8>
          continue;
801046b4:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801046b5:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801046bc:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
801046c3:	72 93                	jb     80104658 <scheduler+0x4b>
801046c5:	e9 79 02 00 00       	jmp    80104943 <scheduler+0x336>
      }
    } else {
      // MLFQ

      // Boosting
      if (policy != 3) {
801046ca:	83 7d e0 03          	cmpl   $0x3,-0x20(%ebp)
801046ce:	0f 84 a0 00 00 00    	je     80104774 <scheduler+0x167>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801046d4:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801046db:	e9 87 00 00 00       	jmp    80104767 <scheduler+0x15a>
          if (p->state != RUNNABLE)
801046e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e3:	8b 40 0c             	mov    0xc(%eax),%eax
801046e6:	83 f8 03             	cmp    $0x3,%eax
801046e9:	75 74                	jne    8010475f <scheduler+0x152>
            continue;

          int curq = p->priority;
801046eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ee:	8b 40 7c             	mov    0x7c(%eax),%eax
801046f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
          int boost_limit[] = {500, 320, 160};
801046f4:	c7 45 bc f4 01 00 00 	movl   $0x1f4,-0x44(%ebp)
801046fb:	c7 45 c0 40 01 00 00 	movl   $0x140,-0x40(%ebp)
80104702:	c7 45 c4 a0 00 00 00 	movl   $0xa0,-0x3c(%ebp)

          if (curq < 3 && p->wait_ticks[curq] >= boost_limit[3 - curq]){
80104709:	83 7d dc 02          	cmpl   $0x2,-0x24(%ebp)
8010470d:	7f 51                	jg     80104760 <scheduler+0x153>
8010470f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104712:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104715:	83 c2 24             	add    $0x24,%edx
80104718:	8b 14 90             	mov    (%eax,%edx,4),%edx
8010471b:	b8 03 00 00 00       	mov    $0x3,%eax
80104720:	2b 45 dc             	sub    -0x24(%ebp),%eax
80104723:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104727:	39 c2                	cmp    %eax,%edx
80104729:	7c 35                	jl     80104760 <scheduler+0x153>
            p->priority++;
8010472b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472e:	8b 40 7c             	mov    0x7c(%eax),%eax
80104731:	8d 50 01             	lea    0x1(%eax),%edx
80104734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104737:	89 50 7c             	mov    %edx,0x7c(%eax)
            for (int i=0; i<4; i++)
8010473a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104741:	eb 14                	jmp    80104757 <scheduler+0x14a>
              p->wait_ticks[i]=0;
80104743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104746:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104749:	83 c2 24             	add    $0x24,%edx
8010474c:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
            for (int i=0; i<4; i++)
80104753:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104757:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010475b:	7e e6                	jle    80104743 <scheduler+0x136>
8010475d:	eb 01                	jmp    80104760 <scheduler+0x153>
            continue;
8010475f:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104760:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104767:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
8010476e:	0f 82 6c ff ff ff    	jb     801046e0 <scheduler+0xd3>
          }
        }
      }

      // Time slice 
      int slice[4] = { -1, 32, 16, 8 };
80104774:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
8010477b:	c7 45 cc 20 00 00 00 	movl   $0x20,-0x34(%ebp)
80104782:	c7 45 d0 10 00 00 00 	movl   $0x10,-0x30(%ebp)
80104789:	c7 45 d4 08 00 00 00 	movl   $0x8,-0x2c(%ebp)

      int done = 0;
80104790:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

      // Q3부터 순차적으로 찾기
      for (int q = 3; q >= 0 && !done; q--) {
80104797:	c7 45 e8 03 00 00 00 	movl   $0x3,-0x18(%ebp)
8010479e:	e9 90 01 00 00       	jmp    80104933 <scheduler+0x326>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801047a3:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801047aa:	e9 73 01 00 00       	jmp    80104922 <scheduler+0x315>
          if (p->state != RUNNABLE || p->priority != q)
801047af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b2:	8b 40 0c             	mov    0xc(%eax),%eax
801047b5:	83 f8 03             	cmp    $0x3,%eax
801047b8:	0f 85 5c 01 00 00    	jne    8010491a <scheduler+0x30d>
801047be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c1:	8b 40 7c             	mov    0x7c(%eax),%eax
801047c4:	39 45 e8             	cmp    %eax,-0x18(%ebp)
801047c7:	0f 85 4d 01 00 00    	jne    8010491a <scheduler+0x30d>
            continue;
          
          int pr = p->priority;
801047cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d0:	8b 40 7c             	mov    0x7c(%eax),%eax
801047d3:	89 45 d8             	mov    %eax,-0x28(%ebp)

          c->proc = p;
801047d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801047d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047dc:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
801047e2:	83 ec 0c             	sub    $0xc,%esp
801047e5:	ff 75 f4             	push   -0xc(%ebp)
801047e8:	e8 c0 35 00 00       	call   80107dad <switchuvm>
801047ed:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
801047f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f3:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
          swtch(&(c->scheduler), p->context);
801047fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fd:	8b 40 1c             	mov    0x1c(%eax),%eax
80104800:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104803:	83 c2 04             	add    $0x4,%edx
80104806:	83 ec 08             	sub    $0x8,%esp
80104809:	50                   	push   %eax
8010480a:	52                   	push   %edx
8010480b:	e8 dd 0c 00 00       	call   801054ed <swtch>
80104810:	83 c4 10             	add    $0x10,%esp
          switchkvm();
80104813:	e8 7c 35 00 00       	call   80107d94 <switchkvm>
          c->proc = 0;
80104818:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010481b:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104822:	00 00 00 

          // 정책 2번: tick에 따라 강등
          if (policy == 2) {
80104825:	83 7d e0 02          	cmpl   $0x2,-0x20(%ebp)
80104829:	75 75                	jne    801048a0 <scheduler+0x293>
            if ((pr == 3 && p->ticks[3] >= 8) ||
8010482b:	83 7d d8 03          	cmpl   $0x3,-0x28(%ebp)
8010482f:	75 0e                	jne    8010483f <scheduler+0x232>
80104831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104834:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010483a:	83 f8 07             	cmp    $0x7,%eax
8010483d:	7f 30                	jg     8010486f <scheduler+0x262>
8010483f:	83 7d d8 02          	cmpl   $0x2,-0x28(%ebp)
80104843:	75 0e                	jne    80104853 <scheduler+0x246>
                (pr == 2 && p->ticks[2] >= 16) ||
80104845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104848:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
8010484e:	83 f8 0f             	cmp    $0xf,%eax
80104851:	7f 1c                	jg     8010486f <scheduler+0x262>
80104853:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
80104857:	0f 85 b4 00 00 00    	jne    80104911 <scheduler+0x304>
                (pr == 1 && p->ticks[1] >= 32)) {
8010485d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104860:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104866:	83 f8 1f             	cmp    $0x1f,%eax
80104869:	0f 8e a2 00 00 00    	jle    80104911 <scheduler+0x304>

              if (p->priority > 0){
8010486f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104872:	8b 40 7c             	mov    0x7c(%eax),%eax
80104875:	85 c0                	test   %eax,%eax
80104877:	7e 0f                	jle    80104888 <scheduler+0x27b>
                p->priority--;
80104879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487c:	8b 40 7c             	mov    0x7c(%eax),%eax
8010487f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104885:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
80104888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488b:	83 e8 80             	sub    $0xffffff80,%eax
8010488e:	83 ec 04             	sub    $0x4,%esp
80104891:	6a 10                	push   $0x10
80104893:	6a 00                	push   $0x0
80104895:	50                   	push   %eax
80104896:	e8 dd 09 00 00       	call   80105278 <memset>
8010489b:	83 c4 10             	add    $0x10,%esp
8010489e:	eb 71                	jmp    80104911 <scheduler+0x304>
            }
          }

          // 정책 1 & 3: slice 기반 강등
          else {
            if ((pr == 3 && p->ticks[3] >= slice[3]) ||
801048a0:	83 7d d8 03          	cmpl   $0x3,-0x28(%ebp)
801048a4:	75 10                	jne    801048b6 <scheduler+0x2a9>
801048a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a9:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801048af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801048b2:	39 c2                	cmp    %eax,%edx
801048b4:	7d 2c                	jge    801048e2 <scheduler+0x2d5>
801048b6:	83 7d d8 02          	cmpl   $0x2,-0x28(%ebp)
801048ba:	75 10                	jne    801048cc <scheduler+0x2bf>
                (pr == 2 && p->ticks[2] >= slice[2]) ||
801048bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bf:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
801048c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801048c8:	39 c2                	cmp    %eax,%edx
801048ca:	7d 16                	jge    801048e2 <scheduler+0x2d5>
801048cc:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
801048d0:	75 3f                	jne    80104911 <scheduler+0x304>
                (pr == 1 && p->ticks[1] >= slice[1])) {
801048d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d5:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
801048db:	8b 45 cc             	mov    -0x34(%ebp),%eax
801048de:	39 c2                	cmp    %eax,%edx
801048e0:	7c 2f                	jl     80104911 <scheduler+0x304>
              if (p->priority > 0){
801048e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e5:	8b 40 7c             	mov    0x7c(%eax),%eax
801048e8:	85 c0                	test   %eax,%eax
801048ea:	7e 0f                	jle    801048fb <scheduler+0x2ee>
                p->priority--;
801048ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ef:	8b 40 7c             	mov    0x7c(%eax),%eax
801048f2:	8d 50 ff             	lea    -0x1(%eax),%edx
801048f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f8:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
801048fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fe:	83 e8 80             	sub    $0xffffff80,%eax
80104901:	83 ec 04             	sub    $0x4,%esp
80104904:	6a 10                	push   $0x10
80104906:	6a 00                	push   $0x0
80104908:	50                   	push   %eax
80104909:	e8 6a 09 00 00       	call   80105278 <memset>
8010490e:	83 c4 10             	add    $0x10,%esp

            }
          }

          done = 1;
80104911:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
          break;
80104918:	eb 15                	jmp    8010492f <scheduler+0x322>
            continue;
8010491a:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010491b:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104922:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80104929:	0f 82 80 fe ff ff    	jb     801047af <scheduler+0x1a2>
      for (int q = 3; q >= 0 && !done; q--) {
8010492f:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
80104933:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104937:	78 0a                	js     80104943 <scheduler+0x336>
80104939:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010493d:	0f 84 60 fe ff ff    	je     801047a3 <scheduler+0x196>
        }
      }
    }

    release(&ptable.lock);
80104943:	83 ec 0c             	sub    $0xc,%esp
80104946:	68 40 72 11 80       	push   $0x80117240
8010494b:	e8 20 07 00 00       	call   80105070 <release>
80104950:	83 c4 10             	add    $0x10,%esp
  for (;;) {
80104953:	e9 d0 fc ff ff       	jmp    80104628 <scheduler+0x1b>

80104958 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104958:	55                   	push   %ebp
80104959:	89 e5                	mov    %esp,%ebp
8010495b:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010495e:	e8 b1 f5 ff ff       	call   80103f14 <myproc>
80104963:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104966:	83 ec 0c             	sub    $0xc,%esp
80104969:	68 40 72 11 80       	push   $0x80117240
8010496e:	e8 ca 07 00 00       	call   8010513d <holding>
80104973:	83 c4 10             	add    $0x10,%esp
80104976:	85 c0                	test   %eax,%eax
80104978:	75 0d                	jne    80104987 <sched+0x2f>
    panic("sched ptable.lock");
8010497a:	83 ec 0c             	sub    $0xc,%esp
8010497d:	68 2f ac 10 80       	push   $0x8010ac2f
80104982:	e8 22 bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104987:	e8 10 f5 ff ff       	call   80103e9c <mycpu>
8010498c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104992:	83 f8 01             	cmp    $0x1,%eax
80104995:	74 0d                	je     801049a4 <sched+0x4c>
    panic("sched locks");
80104997:	83 ec 0c             	sub    $0xc,%esp
8010499a:	68 41 ac 10 80       	push   $0x8010ac41
8010499f:	e8 05 bc ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801049a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a7:	8b 40 0c             	mov    0xc(%eax),%eax
801049aa:	83 f8 04             	cmp    $0x4,%eax
801049ad:	75 0d                	jne    801049bc <sched+0x64>
    panic("sched running");
801049af:	83 ec 0c             	sub    $0xc,%esp
801049b2:	68 4d ac 10 80       	push   $0x8010ac4d
801049b7:	e8 ed bb ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801049bc:	e8 8b f4 ff ff       	call   80103e4c <readeflags>
801049c1:	25 00 02 00 00       	and    $0x200,%eax
801049c6:	85 c0                	test   %eax,%eax
801049c8:	74 0d                	je     801049d7 <sched+0x7f>
    panic("sched interruptible");
801049ca:	83 ec 0c             	sub    $0xc,%esp
801049cd:	68 5b ac 10 80       	push   $0x8010ac5b
801049d2:	e8 d2 bb ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
801049d7:	e8 c0 f4 ff ff       	call   80103e9c <mycpu>
801049dc:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801049e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801049e5:	e8 b2 f4 ff ff       	call   80103e9c <mycpu>
801049ea:	8b 40 04             	mov    0x4(%eax),%eax
801049ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049f0:	83 c2 1c             	add    $0x1c,%edx
801049f3:	83 ec 08             	sub    $0x8,%esp
801049f6:	50                   	push   %eax
801049f7:	52                   	push   %edx
801049f8:	e8 f0 0a 00 00       	call   801054ed <swtch>
801049fd:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104a00:	e8 97 f4 ff ff       	call   80103e9c <mycpu>
80104a05:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a08:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104a0e:	90                   	nop
80104a0f:	c9                   	leave  
80104a10:	c3                   	ret    

80104a11 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104a11:	55                   	push   %ebp
80104a12:	89 e5                	mov    %esp,%ebp
80104a14:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104a17:	83 ec 0c             	sub    $0xc,%esp
80104a1a:	68 40 72 11 80       	push   $0x80117240
80104a1f:	e8 de 05 00 00       	call   80105002 <acquire>
80104a24:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104a27:	e8 e8 f4 ff ff       	call   80103f14 <myproc>
80104a2c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104a33:	e8 20 ff ff ff       	call   80104958 <sched>
  release(&ptable.lock);
80104a38:	83 ec 0c             	sub    $0xc,%esp
80104a3b:	68 40 72 11 80       	push   $0x80117240
80104a40:	e8 2b 06 00 00       	call   80105070 <release>
80104a45:	83 c4 10             	add    $0x10,%esp
}
80104a48:	90                   	nop
80104a49:	c9                   	leave  
80104a4a:	c3                   	ret    

80104a4b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104a4b:	55                   	push   %ebp
80104a4c:	89 e5                	mov    %esp,%ebp
80104a4e:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104a51:	83 ec 0c             	sub    $0xc,%esp
80104a54:	68 40 72 11 80       	push   $0x80117240
80104a59:	e8 12 06 00 00       	call   80105070 <release>
80104a5e:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104a61:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104a66:	85 c0                	test   %eax,%eax
80104a68:	74 24                	je     80104a8e <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104a6a:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104a71:	00 00 00 
    iinit(ROOTDEV);
80104a74:	83 ec 0c             	sub    $0xc,%esp
80104a77:	6a 01                	push   $0x1
80104a79:	e8 fa cb ff ff       	call   80101678 <iinit>
80104a7e:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104a81:	83 ec 0c             	sub    $0xc,%esp
80104a84:	6a 01                	push   $0x1
80104a86:	e8 76 e8 ff ff       	call   80103301 <initlog>
80104a8b:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104a8e:	90                   	nop
80104a8f:	c9                   	leave  
80104a90:	c3                   	ret    

80104a91 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104a91:	55                   	push   %ebp
80104a92:	89 e5                	mov    %esp,%ebp
80104a94:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104a97:	e8 78 f4 ff ff       	call   80103f14 <myproc>
80104a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104a9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104aa3:	75 0d                	jne    80104ab2 <sleep+0x21>
    panic("sleep");
80104aa5:	83 ec 0c             	sub    $0xc,%esp
80104aa8:	68 6f ac 10 80       	push   $0x8010ac6f
80104aad:	e8 f7 ba ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104ab2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ab6:	75 0d                	jne    80104ac5 <sleep+0x34>
    panic("sleep without lk");
80104ab8:	83 ec 0c             	sub    $0xc,%esp
80104abb:	68 75 ac 10 80       	push   $0x8010ac75
80104ac0:	e8 e4 ba ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104ac5:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104acc:	74 1e                	je     80104aec <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ace:	83 ec 0c             	sub    $0xc,%esp
80104ad1:	68 40 72 11 80       	push   $0x80117240
80104ad6:	e8 27 05 00 00       	call   80105002 <acquire>
80104adb:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104ade:	83 ec 0c             	sub    $0xc,%esp
80104ae1:	ff 75 0c             	push   0xc(%ebp)
80104ae4:	e8 87 05 00 00       	call   80105070 <release>
80104ae9:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aef:	8b 55 08             	mov    0x8(%ebp),%edx
80104af2:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104aff:	e8 54 fe ff ff       	call   80104958 <sched>

  // Tidy up.
  p->chan = 0;
80104b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b07:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104b0e:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104b15:	74 1e                	je     80104b35 <sleep+0xa4>
    release(&ptable.lock);
80104b17:	83 ec 0c             	sub    $0xc,%esp
80104b1a:	68 40 72 11 80       	push   $0x80117240
80104b1f:	e8 4c 05 00 00       	call   80105070 <release>
80104b24:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104b27:	83 ec 0c             	sub    $0xc,%esp
80104b2a:	ff 75 0c             	push   0xc(%ebp)
80104b2d:	e8 d0 04 00 00       	call   80105002 <acquire>
80104b32:	83 c4 10             	add    $0x10,%esp
  }
}
80104b35:	90                   	nop
80104b36:	c9                   	leave  
80104b37:	c3                   	ret    

80104b38 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104b38:	55                   	push   %ebp
80104b39:	89 e5                	mov    %esp,%ebp
80104b3b:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b3e:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
80104b45:	eb 27                	jmp    80104b6e <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104b47:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b4a:	8b 40 0c             	mov    0xc(%eax),%eax
80104b4d:	83 f8 02             	cmp    $0x2,%eax
80104b50:	75 15                	jne    80104b67 <wakeup1+0x2f>
80104b52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b55:	8b 40 20             	mov    0x20(%eax),%eax
80104b58:	39 45 08             	cmp    %eax,0x8(%ebp)
80104b5b:	75 0a                	jne    80104b67 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104b5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b60:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b67:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
80104b6e:	81 7d fc 74 9a 11 80 	cmpl   $0x80119a74,-0x4(%ebp)
80104b75:	72 d0                	jb     80104b47 <wakeup1+0xf>
}
80104b77:	90                   	nop
80104b78:	90                   	nop
80104b79:	c9                   	leave  
80104b7a:	c3                   	ret    

80104b7b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104b7b:	55                   	push   %ebp
80104b7c:	89 e5                	mov    %esp,%ebp
80104b7e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104b81:	83 ec 0c             	sub    $0xc,%esp
80104b84:	68 40 72 11 80       	push   $0x80117240
80104b89:	e8 74 04 00 00       	call   80105002 <acquire>
80104b8e:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104b91:	83 ec 0c             	sub    $0xc,%esp
80104b94:	ff 75 08             	push   0x8(%ebp)
80104b97:	e8 9c ff ff ff       	call   80104b38 <wakeup1>
80104b9c:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104b9f:	83 ec 0c             	sub    $0xc,%esp
80104ba2:	68 40 72 11 80       	push   $0x80117240
80104ba7:	e8 c4 04 00 00       	call   80105070 <release>
80104bac:	83 c4 10             	add    $0x10,%esp
}
80104baf:	90                   	nop
80104bb0:	c9                   	leave  
80104bb1:	c3                   	ret    

80104bb2 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104bb2:	55                   	push   %ebp
80104bb3:	89 e5                	mov    %esp,%ebp
80104bb5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104bb8:	83 ec 0c             	sub    $0xc,%esp
80104bbb:	68 40 72 11 80       	push   $0x80117240
80104bc0:	e8 3d 04 00 00       	call   80105002 <acquire>
80104bc5:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bc8:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104bcf:	eb 48                	jmp    80104c19 <kill+0x67>
    if(p->pid == pid){
80104bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd4:	8b 40 10             	mov    0x10(%eax),%eax
80104bd7:	39 45 08             	cmp    %eax,0x8(%ebp)
80104bda:	75 36                	jne    80104c12 <kill+0x60>
      p->killed = 1;
80104bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be9:	8b 40 0c             	mov    0xc(%eax),%eax
80104bec:	83 f8 02             	cmp    $0x2,%eax
80104bef:	75 0a                	jne    80104bfb <kill+0x49>
        p->state = RUNNABLE;
80104bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104bfb:	83 ec 0c             	sub    $0xc,%esp
80104bfe:	68 40 72 11 80       	push   $0x80117240
80104c03:	e8 68 04 00 00       	call   80105070 <release>
80104c08:	83 c4 10             	add    $0x10,%esp
      return 0;
80104c0b:	b8 00 00 00 00       	mov    $0x0,%eax
80104c10:	eb 25                	jmp    80104c37 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c12:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104c19:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80104c20:	72 af                	jb     80104bd1 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104c22:	83 ec 0c             	sub    $0xc,%esp
80104c25:	68 40 72 11 80       	push   $0x80117240
80104c2a:	e8 41 04 00 00       	call   80105070 <release>
80104c2f:	83 c4 10             	add    $0x10,%esp
  return -1;
80104c32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c37:	c9                   	leave  
80104c38:	c3                   	ret    

80104c39 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104c39:	55                   	push   %ebp
80104c3a:	89 e5                	mov    %esp,%ebp
80104c3c:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c3f:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
80104c46:	e9 da 00 00 00       	jmp    80104d25 <procdump+0xec>
    if(p->state == UNUSED)
80104c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c4e:	8b 40 0c             	mov    0xc(%eax),%eax
80104c51:	85 c0                	test   %eax,%eax
80104c53:	0f 84 c4 00 00 00    	je     80104d1d <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c5c:	8b 40 0c             	mov    0xc(%eax),%eax
80104c5f:	83 f8 05             	cmp    $0x5,%eax
80104c62:	77 23                	ja     80104c87 <procdump+0x4e>
80104c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c67:	8b 40 0c             	mov    0xc(%eax),%eax
80104c6a:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104c71:	85 c0                	test   %eax,%eax
80104c73:	74 12                	je     80104c87 <procdump+0x4e>
      state = states[p->state];
80104c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c78:	8b 40 0c             	mov    0xc(%eax),%eax
80104c7b:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104c82:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c85:	eb 07                	jmp    80104c8e <procdump+0x55>
    else
      state = "???";
80104c87:	c7 45 ec 86 ac 10 80 	movl   $0x8010ac86,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c91:	8d 50 6c             	lea    0x6c(%eax),%edx
80104c94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c97:	8b 40 10             	mov    0x10(%eax),%eax
80104c9a:	52                   	push   %edx
80104c9b:	ff 75 ec             	push   -0x14(%ebp)
80104c9e:	50                   	push   %eax
80104c9f:	68 8a ac 10 80       	push   $0x8010ac8a
80104ca4:	e8 4b b7 ff ff       	call   801003f4 <cprintf>
80104ca9:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104caf:	8b 40 0c             	mov    0xc(%eax),%eax
80104cb2:	83 f8 02             	cmp    $0x2,%eax
80104cb5:	75 54                	jne    80104d0b <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cba:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cbd:	8b 40 0c             	mov    0xc(%eax),%eax
80104cc0:	83 c0 08             	add    $0x8,%eax
80104cc3:	89 c2                	mov    %eax,%edx
80104cc5:	83 ec 08             	sub    $0x8,%esp
80104cc8:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104ccb:	50                   	push   %eax
80104ccc:	52                   	push   %edx
80104ccd:	e8 f0 03 00 00       	call   801050c2 <getcallerpcs>
80104cd2:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104cd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104cdc:	eb 1c                	jmp    80104cfa <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ce5:	83 ec 08             	sub    $0x8,%esp
80104ce8:	50                   	push   %eax
80104ce9:	68 93 ac 10 80       	push   $0x8010ac93
80104cee:	e8 01 b7 ff ff       	call   801003f4 <cprintf>
80104cf3:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104cf6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104cfa:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104cfe:	7f 0b                	jg     80104d0b <procdump+0xd2>
80104d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d03:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d07:	85 c0                	test   %eax,%eax
80104d09:	75 d3                	jne    80104cde <procdump+0xa5>
    }
    cprintf("\n");
80104d0b:	83 ec 0c             	sub    $0xc,%esp
80104d0e:	68 97 ac 10 80       	push   $0x8010ac97
80104d13:	e8 dc b6 ff ff       	call   801003f4 <cprintf>
80104d18:	83 c4 10             	add    $0x10,%esp
80104d1b:	eb 01                	jmp    80104d1e <procdump+0xe5>
      continue;
80104d1d:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d1e:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
80104d25:	81 7d f0 74 9a 11 80 	cmpl   $0x80119a74,-0x10(%ebp)
80104d2c:	0f 82 19 ff ff ff    	jb     80104c4b <procdump+0x12>
  }
}
80104d32:	90                   	nop
80104d33:	90                   	nop
80104d34:	c9                   	leave  
80104d35:	c3                   	ret    

80104d36 <setSchedPolicy>:

//  0 (RR), 1 (MLFQ), 2 (MLFQ-no-tracking), 3 (MLFQ-no-boosting)

int
setSchedPolicy(int policy)
{
80104d36:	55                   	push   %ebp
80104d37:	89 e5                	mov    %esp,%ebp
80104d39:	83 ec 18             	sub    $0x18,%esp

  if (policy < 0 || policy > 3)
80104d3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104d40:	78 06                	js     80104d48 <setSchedPolicy+0x12>
80104d42:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104d46:	7e 07                	jle    80104d4f <setSchedPolicy+0x19>
    return -1;
80104d48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d4d:	eb 23                	jmp    80104d72 <setSchedPolicy+0x3c>

  pushcli();
80104d4f:	e8 19 04 00 00       	call   8010516d <pushcli>
  struct cpu *c = mycpu();
80104d54:	e8 43 f1 ff ff       	call   80103e9c <mycpu>
80104d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->sched_policy = policy;
80104d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5f:	8b 55 08             	mov    0x8(%ebp),%edx
80104d62:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104d68:	e8 4d 04 00 00       	call   801051ba <popcli>

  return 0;
80104d6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d72:	c9                   	leave  
80104d73:	c3                   	ret    

80104d74 <getpinfo>:


int
getpinfo(struct pstat *ps)
{
80104d74:	55                   	push   %ebp
80104d75:	89 e5                	mov    %esp,%ebp
80104d77:	53                   	push   %ebx
80104d78:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  int i = 0;
80104d7b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);  
80104d82:	83 ec 0c             	sub    $0xc,%esp
80104d85:	68 40 72 11 80       	push   $0x80117240
80104d8a:	e8 73 02 00 00       	call   80105002 <acquire>
80104d8f:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
80104d92:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104d99:	e9 be 00 00 00       	jmp    80104e5c <getpinfo+0xe8>
    // 프로세스가 사용 중이면 1, 아니면 0
    ps->inuse[i] = (p->state != UNUSED);
80104d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da1:	8b 40 0c             	mov    0xc(%eax),%eax
80104da4:	85 c0                	test   %eax,%eax
80104da6:	0f 95 c0             	setne  %al
80104da9:	0f b6 c8             	movzbl %al,%ecx
80104dac:	8b 45 08             	mov    0x8(%ebp),%eax
80104daf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104db2:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // pid 저장
    ps->pid[i] = p->pid;
80104db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db8:	8b 50 10             	mov    0x10(%eax),%edx
80104dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104dc1:	83 c1 40             	add    $0x40,%ecx
80104dc4:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 우선순위 저장 
    ps->priority[i] = p->priority;
80104dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dca:	8b 50 7c             	mov    0x7c(%eax),%edx
80104dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104dd3:	83 e9 80             	sub    $0xffffff80,%ecx
80104dd6:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 상태 저장 
    ps->state[i] = p->state;
80104dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ddc:	8b 40 0c             	mov    0xc(%eax),%eax
80104ddf:	89 c1                	mov    %eax,%ecx
80104de1:	8b 45 08             	mov    0x8(%ebp),%eax
80104de4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104de7:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80104ded:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // 각 큐에서 실행된 tick 수 저장
    for (int j = 0; j < 4; j++) {
80104df0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104df7:	eb 52                	jmp    80104e4b <getpinfo+0xd7>
      ps->ticks[i][j] = p->ticks[j];
80104df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfc:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104dff:	83 c2 20             	add    $0x20,%edx
80104e02:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104e05:	8b 45 08             	mov    0x8(%ebp),%eax
80104e08:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104e0b:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104e12:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104e15:	01 d9                	add    %ebx,%ecx
80104e17:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104e1d:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
80104e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e23:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104e26:	83 c2 24             	add    $0x24,%edx
80104e29:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104e32:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104e39:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104e3c:	01 d9                	add    %ebx,%ecx
80104e3e:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104e44:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104e47:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104e4b:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
80104e4f:	7e a8                	jle    80104df9 <getpinfo+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
80104e51:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104e58:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104e5c:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80104e63:	0f 82 35 ff ff ff    	jb     80104d9e <getpinfo+0x2a>
    }
  }

  release(&ptable.lock);  
80104e69:	83 ec 0c             	sub    $0xc,%esp
80104e6c:	68 40 72 11 80       	push   $0x80117240
80104e71:	e8 fa 01 00 00       	call   80105070 <release>
80104e76:	83 c4 10             	add    $0x10,%esp

  return 0; 
80104e79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e81:	c9                   	leave  
80104e82:	c3                   	ret    

80104e83 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104e83:	55                   	push   %ebp
80104e84:	89 e5                	mov    %esp,%ebp
80104e86:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104e89:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8c:	83 c0 04             	add    $0x4,%eax
80104e8f:	83 ec 08             	sub    $0x8,%esp
80104e92:	68 c3 ac 10 80       	push   $0x8010acc3
80104e97:	50                   	push   %eax
80104e98:	e8 43 01 00 00       	call   80104fe0 <initlock>
80104e9d:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ea6:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104ea9:	8b 45 08             	mov    0x8(%ebp),%eax
80104eac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104ebc:	90                   	nop
80104ebd:	c9                   	leave  
80104ebe:	c3                   	ret    

80104ebf <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104ebf:	55                   	push   %ebp
80104ec0:	89 e5                	mov    %esp,%ebp
80104ec2:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec8:	83 c0 04             	add    $0x4,%eax
80104ecb:	83 ec 0c             	sub    $0xc,%esp
80104ece:	50                   	push   %eax
80104ecf:	e8 2e 01 00 00       	call   80105002 <acquire>
80104ed4:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ed7:	eb 15                	jmp    80104eee <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80104edc:	83 c0 04             	add    $0x4,%eax
80104edf:	83 ec 08             	sub    $0x8,%esp
80104ee2:	50                   	push   %eax
80104ee3:	ff 75 08             	push   0x8(%ebp)
80104ee6:	e8 a6 fb ff ff       	call   80104a91 <sleep>
80104eeb:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104eee:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef1:	8b 00                	mov    (%eax),%eax
80104ef3:	85 c0                	test   %eax,%eax
80104ef5:	75 e2                	jne    80104ed9 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80104efa:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104f00:	e8 0f f0 ff ff       	call   80103f14 <myproc>
80104f05:	8b 50 10             	mov    0x10(%eax),%edx
80104f08:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0b:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104f0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f11:	83 c0 04             	add    $0x4,%eax
80104f14:	83 ec 0c             	sub    $0xc,%esp
80104f17:	50                   	push   %eax
80104f18:	e8 53 01 00 00       	call   80105070 <release>
80104f1d:	83 c4 10             	add    $0x10,%esp
}
80104f20:	90                   	nop
80104f21:	c9                   	leave  
80104f22:	c3                   	ret    

80104f23 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104f23:	55                   	push   %ebp
80104f24:	89 e5                	mov    %esp,%ebp
80104f26:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f29:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2c:	83 c0 04             	add    $0x4,%eax
80104f2f:	83 ec 0c             	sub    $0xc,%esp
80104f32:	50                   	push   %eax
80104f33:	e8 ca 00 00 00       	call   80105002 <acquire>
80104f38:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f44:	8b 45 08             	mov    0x8(%ebp),%eax
80104f47:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104f4e:	83 ec 0c             	sub    $0xc,%esp
80104f51:	ff 75 08             	push   0x8(%ebp)
80104f54:	e8 22 fc ff ff       	call   80104b7b <wakeup>
80104f59:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5f:	83 c0 04             	add    $0x4,%eax
80104f62:	83 ec 0c             	sub    $0xc,%esp
80104f65:	50                   	push   %eax
80104f66:	e8 05 01 00 00       	call   80105070 <release>
80104f6b:	83 c4 10             	add    $0x10,%esp
}
80104f6e:	90                   	nop
80104f6f:	c9                   	leave  
80104f70:	c3                   	ret    

80104f71 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104f71:	55                   	push   %ebp
80104f72:	89 e5                	mov    %esp,%ebp
80104f74:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104f77:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7a:	83 c0 04             	add    $0x4,%eax
80104f7d:	83 ec 0c             	sub    $0xc,%esp
80104f80:	50                   	push   %eax
80104f81:	e8 7c 00 00 00       	call   80105002 <acquire>
80104f86:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104f89:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8c:	8b 00                	mov    (%eax),%eax
80104f8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104f91:	8b 45 08             	mov    0x8(%ebp),%eax
80104f94:	83 c0 04             	add    $0x4,%eax
80104f97:	83 ec 0c             	sub    $0xc,%esp
80104f9a:	50                   	push   %eax
80104f9b:	e8 d0 00 00 00       	call   80105070 <release>
80104fa0:	83 c4 10             	add    $0x10,%esp
  return r;
80104fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104fa6:	c9                   	leave  
80104fa7:	c3                   	ret    

80104fa8 <readeflags>:
{
80104fa8:	55                   	push   %ebp
80104fa9:	89 e5                	mov    %esp,%ebp
80104fab:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104fae:	9c                   	pushf  
80104faf:	58                   	pop    %eax
80104fb0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fb6:	c9                   	leave  
80104fb7:	c3                   	ret    

80104fb8 <cli>:
{
80104fb8:	55                   	push   %ebp
80104fb9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104fbb:	fa                   	cli    
}
80104fbc:	90                   	nop
80104fbd:	5d                   	pop    %ebp
80104fbe:	c3                   	ret    

80104fbf <sti>:
{
80104fbf:	55                   	push   %ebp
80104fc0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104fc2:	fb                   	sti    
}
80104fc3:	90                   	nop
80104fc4:	5d                   	pop    %ebp
80104fc5:	c3                   	ret    

80104fc6 <xchg>:
{
80104fc6:	55                   	push   %ebp
80104fc7:	89 e5                	mov    %esp,%ebp
80104fc9:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104fcc:	8b 55 08             	mov    0x8(%ebp),%edx
80104fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fd5:	f0 87 02             	lock xchg %eax,(%edx)
80104fd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104fdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fde:	c9                   	leave  
80104fdf:	c3                   	ret    

80104fe0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104fe0:	55                   	push   %ebp
80104fe1:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fe9:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104fec:	8b 45 08             	mov    0x8(%ebp),%eax
80104fef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104fff:	90                   	nop
80105000:	5d                   	pop    %ebp
80105001:	c3                   	ret    

80105002 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105002:	55                   	push   %ebp
80105003:	89 e5                	mov    %esp,%ebp
80105005:	53                   	push   %ebx
80105006:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105009:	e8 5f 01 00 00       	call   8010516d <pushcli>
  if(holding(lk)){
8010500e:	8b 45 08             	mov    0x8(%ebp),%eax
80105011:	83 ec 0c             	sub    $0xc,%esp
80105014:	50                   	push   %eax
80105015:	e8 23 01 00 00       	call   8010513d <holding>
8010501a:	83 c4 10             	add    $0x10,%esp
8010501d:	85 c0                	test   %eax,%eax
8010501f:	74 0d                	je     8010502e <acquire+0x2c>
    panic("acquire");
80105021:	83 ec 0c             	sub    $0xc,%esp
80105024:	68 ce ac 10 80       	push   $0x8010acce
80105029:	e8 7b b5 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010502e:	90                   	nop
8010502f:	8b 45 08             	mov    0x8(%ebp),%eax
80105032:	83 ec 08             	sub    $0x8,%esp
80105035:	6a 01                	push   $0x1
80105037:	50                   	push   %eax
80105038:	e8 89 ff ff ff       	call   80104fc6 <xchg>
8010503d:	83 c4 10             	add    $0x10,%esp
80105040:	85 c0                	test   %eax,%eax
80105042:	75 eb                	jne    8010502f <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105044:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105049:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010504c:	e8 4b ee ff ff       	call   80103e9c <mycpu>
80105051:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105054:	8b 45 08             	mov    0x8(%ebp),%eax
80105057:	83 c0 0c             	add    $0xc,%eax
8010505a:	83 ec 08             	sub    $0x8,%esp
8010505d:	50                   	push   %eax
8010505e:	8d 45 08             	lea    0x8(%ebp),%eax
80105061:	50                   	push   %eax
80105062:	e8 5b 00 00 00       	call   801050c2 <getcallerpcs>
80105067:	83 c4 10             	add    $0x10,%esp
}
8010506a:	90                   	nop
8010506b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010506e:	c9                   	leave  
8010506f:	c3                   	ret    

80105070 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105070:	55                   	push   %ebp
80105071:	89 e5                	mov    %esp,%ebp
80105073:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105076:	83 ec 0c             	sub    $0xc,%esp
80105079:	ff 75 08             	push   0x8(%ebp)
8010507c:	e8 bc 00 00 00       	call   8010513d <holding>
80105081:	83 c4 10             	add    $0x10,%esp
80105084:	85 c0                	test   %eax,%eax
80105086:	75 0d                	jne    80105095 <release+0x25>
    panic("release");
80105088:	83 ec 0c             	sub    $0xc,%esp
8010508b:	68 d6 ac 10 80       	push   $0x8010acd6
80105090:	e8 14 b5 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80105095:	8b 45 08             	mov    0x8(%ebp),%eax
80105098:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010509f:	8b 45 08             	mov    0x8(%ebp),%eax
801050a2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801050a9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801050ae:	8b 45 08             	mov    0x8(%ebp),%eax
801050b1:	8b 55 08             	mov    0x8(%ebp),%edx
801050b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801050ba:	e8 fb 00 00 00       	call   801051ba <popcli>
}
801050bf:	90                   	nop
801050c0:	c9                   	leave  
801050c1:	c3                   	ret    

801050c2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050c2:	55                   	push   %ebp
801050c3:	89 e5                	mov    %esp,%ebp
801050c5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801050c8:	8b 45 08             	mov    0x8(%ebp),%eax
801050cb:	83 e8 08             	sub    $0x8,%eax
801050ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050d1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050d8:	eb 38                	jmp    80105112 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801050da:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801050de:	74 53                	je     80105133 <getcallerpcs+0x71>
801050e0:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801050e7:	76 4a                	jbe    80105133 <getcallerpcs+0x71>
801050e9:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801050ed:	74 44                	je     80105133 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801050ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050f2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fc:	01 c2                	add    %eax,%edx
801050fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105101:	8b 40 04             	mov    0x4(%eax),%eax
80105104:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105106:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105109:	8b 00                	mov    (%eax),%eax
8010510b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010510e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105112:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105116:	7e c2                	jle    801050da <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105118:	eb 19                	jmp    80105133 <getcallerpcs+0x71>
    pcs[i] = 0;
8010511a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010511d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105124:	8b 45 0c             	mov    0xc(%ebp),%eax
80105127:	01 d0                	add    %edx,%eax
80105129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010512f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105133:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105137:	7e e1                	jle    8010511a <getcallerpcs+0x58>
}
80105139:	90                   	nop
8010513a:	90                   	nop
8010513b:	c9                   	leave  
8010513c:	c3                   	ret    

8010513d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010513d:	55                   	push   %ebp
8010513e:	89 e5                	mov    %esp,%ebp
80105140:	53                   	push   %ebx
80105141:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105144:	8b 45 08             	mov    0x8(%ebp),%eax
80105147:	8b 00                	mov    (%eax),%eax
80105149:	85 c0                	test   %eax,%eax
8010514b:	74 16                	je     80105163 <holding+0x26>
8010514d:	8b 45 08             	mov    0x8(%ebp),%eax
80105150:	8b 58 08             	mov    0x8(%eax),%ebx
80105153:	e8 44 ed ff ff       	call   80103e9c <mycpu>
80105158:	39 c3                	cmp    %eax,%ebx
8010515a:	75 07                	jne    80105163 <holding+0x26>
8010515c:	b8 01 00 00 00       	mov    $0x1,%eax
80105161:	eb 05                	jmp    80105168 <holding+0x2b>
80105163:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105168:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010516b:	c9                   	leave  
8010516c:	c3                   	ret    

8010516d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010516d:	55                   	push   %ebp
8010516e:	89 e5                	mov    %esp,%ebp
80105170:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105173:	e8 30 fe ff ff       	call   80104fa8 <readeflags>
80105178:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010517b:	e8 38 fe ff ff       	call   80104fb8 <cli>
  if(mycpu()->ncli == 0)
80105180:	e8 17 ed ff ff       	call   80103e9c <mycpu>
80105185:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010518b:	85 c0                	test   %eax,%eax
8010518d:	75 14                	jne    801051a3 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
8010518f:	e8 08 ed ff ff       	call   80103e9c <mycpu>
80105194:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105197:	81 e2 00 02 00 00    	and    $0x200,%edx
8010519d:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801051a3:	e8 f4 ec ff ff       	call   80103e9c <mycpu>
801051a8:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801051ae:	83 c2 01             	add    $0x1,%edx
801051b1:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801051b7:	90                   	nop
801051b8:	c9                   	leave  
801051b9:	c3                   	ret    

801051ba <popcli>:

void
popcli(void)
{
801051ba:	55                   	push   %ebp
801051bb:	89 e5                	mov    %esp,%ebp
801051bd:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801051c0:	e8 e3 fd ff ff       	call   80104fa8 <readeflags>
801051c5:	25 00 02 00 00       	and    $0x200,%eax
801051ca:	85 c0                	test   %eax,%eax
801051cc:	74 0d                	je     801051db <popcli+0x21>
    panic("popcli - interruptible");
801051ce:	83 ec 0c             	sub    $0xc,%esp
801051d1:	68 de ac 10 80       	push   $0x8010acde
801051d6:	e8 ce b3 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801051db:	e8 bc ec ff ff       	call   80103e9c <mycpu>
801051e0:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801051e6:	83 ea 01             	sub    $0x1,%edx
801051e9:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801051ef:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051f5:	85 c0                	test   %eax,%eax
801051f7:	79 0d                	jns    80105206 <popcli+0x4c>
    panic("popcli");
801051f9:	83 ec 0c             	sub    $0xc,%esp
801051fc:	68 f5 ac 10 80       	push   $0x8010acf5
80105201:	e8 a3 b3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105206:	e8 91 ec ff ff       	call   80103e9c <mycpu>
8010520b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105211:	85 c0                	test   %eax,%eax
80105213:	75 14                	jne    80105229 <popcli+0x6f>
80105215:	e8 82 ec ff ff       	call   80103e9c <mycpu>
8010521a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105220:	85 c0                	test   %eax,%eax
80105222:	74 05                	je     80105229 <popcli+0x6f>
    sti();
80105224:	e8 96 fd ff ff       	call   80104fbf <sti>
}
80105229:	90                   	nop
8010522a:	c9                   	leave  
8010522b:	c3                   	ret    

8010522c <stosb>:
{
8010522c:	55                   	push   %ebp
8010522d:	89 e5                	mov    %esp,%ebp
8010522f:	57                   	push   %edi
80105230:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105231:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105234:	8b 55 10             	mov    0x10(%ebp),%edx
80105237:	8b 45 0c             	mov    0xc(%ebp),%eax
8010523a:	89 cb                	mov    %ecx,%ebx
8010523c:	89 df                	mov    %ebx,%edi
8010523e:	89 d1                	mov    %edx,%ecx
80105240:	fc                   	cld    
80105241:	f3 aa                	rep stos %al,%es:(%edi)
80105243:	89 ca                	mov    %ecx,%edx
80105245:	89 fb                	mov    %edi,%ebx
80105247:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010524a:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010524d:	90                   	nop
8010524e:	5b                   	pop    %ebx
8010524f:	5f                   	pop    %edi
80105250:	5d                   	pop    %ebp
80105251:	c3                   	ret    

80105252 <stosl>:
{
80105252:	55                   	push   %ebp
80105253:	89 e5                	mov    %esp,%ebp
80105255:	57                   	push   %edi
80105256:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105257:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010525a:	8b 55 10             	mov    0x10(%ebp),%edx
8010525d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105260:	89 cb                	mov    %ecx,%ebx
80105262:	89 df                	mov    %ebx,%edi
80105264:	89 d1                	mov    %edx,%ecx
80105266:	fc                   	cld    
80105267:	f3 ab                	rep stos %eax,%es:(%edi)
80105269:	89 ca                	mov    %ecx,%edx
8010526b:	89 fb                	mov    %edi,%ebx
8010526d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105270:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105273:	90                   	nop
80105274:	5b                   	pop    %ebx
80105275:	5f                   	pop    %edi
80105276:	5d                   	pop    %ebp
80105277:	c3                   	ret    

80105278 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105278:	55                   	push   %ebp
80105279:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010527b:	8b 45 08             	mov    0x8(%ebp),%eax
8010527e:	83 e0 03             	and    $0x3,%eax
80105281:	85 c0                	test   %eax,%eax
80105283:	75 43                	jne    801052c8 <memset+0x50>
80105285:	8b 45 10             	mov    0x10(%ebp),%eax
80105288:	83 e0 03             	and    $0x3,%eax
8010528b:	85 c0                	test   %eax,%eax
8010528d:	75 39                	jne    801052c8 <memset+0x50>
    c &= 0xFF;
8010528f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105296:	8b 45 10             	mov    0x10(%ebp),%eax
80105299:	c1 e8 02             	shr    $0x2,%eax
8010529c:	89 c2                	mov    %eax,%edx
8010529e:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a1:	c1 e0 18             	shl    $0x18,%eax
801052a4:	89 c1                	mov    %eax,%ecx
801052a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a9:	c1 e0 10             	shl    $0x10,%eax
801052ac:	09 c1                	or     %eax,%ecx
801052ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801052b1:	c1 e0 08             	shl    $0x8,%eax
801052b4:	09 c8                	or     %ecx,%eax
801052b6:	0b 45 0c             	or     0xc(%ebp),%eax
801052b9:	52                   	push   %edx
801052ba:	50                   	push   %eax
801052bb:	ff 75 08             	push   0x8(%ebp)
801052be:	e8 8f ff ff ff       	call   80105252 <stosl>
801052c3:	83 c4 0c             	add    $0xc,%esp
801052c6:	eb 12                	jmp    801052da <memset+0x62>
  } else
    stosb(dst, c, n);
801052c8:	8b 45 10             	mov    0x10(%ebp),%eax
801052cb:	50                   	push   %eax
801052cc:	ff 75 0c             	push   0xc(%ebp)
801052cf:	ff 75 08             	push   0x8(%ebp)
801052d2:	e8 55 ff ff ff       	call   8010522c <stosb>
801052d7:	83 c4 0c             	add    $0xc,%esp
  return dst;
801052da:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052dd:	c9                   	leave  
801052de:	c3                   	ret    

801052df <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801052df:	55                   	push   %ebp
801052e0:	89 e5                	mov    %esp,%ebp
801052e2:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801052e5:	8b 45 08             	mov    0x8(%ebp),%eax
801052e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801052f1:	eb 30                	jmp    80105323 <memcmp+0x44>
    if(*s1 != *s2)
801052f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f6:	0f b6 10             	movzbl (%eax),%edx
801052f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052fc:	0f b6 00             	movzbl (%eax),%eax
801052ff:	38 c2                	cmp    %al,%dl
80105301:	74 18                	je     8010531b <memcmp+0x3c>
      return *s1 - *s2;
80105303:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105306:	0f b6 00             	movzbl (%eax),%eax
80105309:	0f b6 d0             	movzbl %al,%edx
8010530c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010530f:	0f b6 00             	movzbl (%eax),%eax
80105312:	0f b6 c8             	movzbl %al,%ecx
80105315:	89 d0                	mov    %edx,%eax
80105317:	29 c8                	sub    %ecx,%eax
80105319:	eb 1a                	jmp    80105335 <memcmp+0x56>
    s1++, s2++;
8010531b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010531f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105323:	8b 45 10             	mov    0x10(%ebp),%eax
80105326:	8d 50 ff             	lea    -0x1(%eax),%edx
80105329:	89 55 10             	mov    %edx,0x10(%ebp)
8010532c:	85 c0                	test   %eax,%eax
8010532e:	75 c3                	jne    801052f3 <memcmp+0x14>
  }

  return 0;
80105330:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105335:	c9                   	leave  
80105336:	c3                   	ret    

80105337 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105337:	55                   	push   %ebp
80105338:	89 e5                	mov    %esp,%ebp
8010533a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010533d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105340:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105343:	8b 45 08             	mov    0x8(%ebp),%eax
80105346:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105349:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010534c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010534f:	73 54                	jae    801053a5 <memmove+0x6e>
80105351:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105354:	8b 45 10             	mov    0x10(%ebp),%eax
80105357:	01 d0                	add    %edx,%eax
80105359:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010535c:	73 47                	jae    801053a5 <memmove+0x6e>
    s += n;
8010535e:	8b 45 10             	mov    0x10(%ebp),%eax
80105361:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105364:	8b 45 10             	mov    0x10(%ebp),%eax
80105367:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010536a:	eb 13                	jmp    8010537f <memmove+0x48>
      *--d = *--s;
8010536c:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105370:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105374:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105377:	0f b6 10             	movzbl (%eax),%edx
8010537a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010537d:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010537f:	8b 45 10             	mov    0x10(%ebp),%eax
80105382:	8d 50 ff             	lea    -0x1(%eax),%edx
80105385:	89 55 10             	mov    %edx,0x10(%ebp)
80105388:	85 c0                	test   %eax,%eax
8010538a:	75 e0                	jne    8010536c <memmove+0x35>
  if(s < d && s + n > d){
8010538c:	eb 24                	jmp    801053b2 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
8010538e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105391:	8d 42 01             	lea    0x1(%edx),%eax
80105394:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105397:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010539a:	8d 48 01             	lea    0x1(%eax),%ecx
8010539d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801053a0:	0f b6 12             	movzbl (%edx),%edx
801053a3:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053a5:	8b 45 10             	mov    0x10(%ebp),%eax
801053a8:	8d 50 ff             	lea    -0x1(%eax),%edx
801053ab:	89 55 10             	mov    %edx,0x10(%ebp)
801053ae:	85 c0                	test   %eax,%eax
801053b0:	75 dc                	jne    8010538e <memmove+0x57>

  return dst;
801053b2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053b5:	c9                   	leave  
801053b6:	c3                   	ret    

801053b7 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053b7:	55                   	push   %ebp
801053b8:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801053ba:	ff 75 10             	push   0x10(%ebp)
801053bd:	ff 75 0c             	push   0xc(%ebp)
801053c0:	ff 75 08             	push   0x8(%ebp)
801053c3:	e8 6f ff ff ff       	call   80105337 <memmove>
801053c8:	83 c4 0c             	add    $0xc,%esp
}
801053cb:	c9                   	leave  
801053cc:	c3                   	ret    

801053cd <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801053cd:	55                   	push   %ebp
801053ce:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801053d0:	eb 0c                	jmp    801053de <strncmp+0x11>
    n--, p++, q++;
801053d2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801053da:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801053de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053e2:	74 1a                	je     801053fe <strncmp+0x31>
801053e4:	8b 45 08             	mov    0x8(%ebp),%eax
801053e7:	0f b6 00             	movzbl (%eax),%eax
801053ea:	84 c0                	test   %al,%al
801053ec:	74 10                	je     801053fe <strncmp+0x31>
801053ee:	8b 45 08             	mov    0x8(%ebp),%eax
801053f1:	0f b6 10             	movzbl (%eax),%edx
801053f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f7:	0f b6 00             	movzbl (%eax),%eax
801053fa:	38 c2                	cmp    %al,%dl
801053fc:	74 d4                	je     801053d2 <strncmp+0x5>
  if(n == 0)
801053fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105402:	75 07                	jne    8010540b <strncmp+0x3e>
    return 0;
80105404:	b8 00 00 00 00       	mov    $0x0,%eax
80105409:	eb 16                	jmp    80105421 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010540b:	8b 45 08             	mov    0x8(%ebp),%eax
8010540e:	0f b6 00             	movzbl (%eax),%eax
80105411:	0f b6 d0             	movzbl %al,%edx
80105414:	8b 45 0c             	mov    0xc(%ebp),%eax
80105417:	0f b6 00             	movzbl (%eax),%eax
8010541a:	0f b6 c8             	movzbl %al,%ecx
8010541d:	89 d0                	mov    %edx,%eax
8010541f:	29 c8                	sub    %ecx,%eax
}
80105421:	5d                   	pop    %ebp
80105422:	c3                   	ret    

80105423 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105423:	55                   	push   %ebp
80105424:	89 e5                	mov    %esp,%ebp
80105426:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105429:	8b 45 08             	mov    0x8(%ebp),%eax
8010542c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010542f:	90                   	nop
80105430:	8b 45 10             	mov    0x10(%ebp),%eax
80105433:	8d 50 ff             	lea    -0x1(%eax),%edx
80105436:	89 55 10             	mov    %edx,0x10(%ebp)
80105439:	85 c0                	test   %eax,%eax
8010543b:	7e 2c                	jle    80105469 <strncpy+0x46>
8010543d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105440:	8d 42 01             	lea    0x1(%edx),%eax
80105443:	89 45 0c             	mov    %eax,0xc(%ebp)
80105446:	8b 45 08             	mov    0x8(%ebp),%eax
80105449:	8d 48 01             	lea    0x1(%eax),%ecx
8010544c:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010544f:	0f b6 12             	movzbl (%edx),%edx
80105452:	88 10                	mov    %dl,(%eax)
80105454:	0f b6 00             	movzbl (%eax),%eax
80105457:	84 c0                	test   %al,%al
80105459:	75 d5                	jne    80105430 <strncpy+0xd>
    ;
  while(n-- > 0)
8010545b:	eb 0c                	jmp    80105469 <strncpy+0x46>
    *s++ = 0;
8010545d:	8b 45 08             	mov    0x8(%ebp),%eax
80105460:	8d 50 01             	lea    0x1(%eax),%edx
80105463:	89 55 08             	mov    %edx,0x8(%ebp)
80105466:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105469:	8b 45 10             	mov    0x10(%ebp),%eax
8010546c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010546f:	89 55 10             	mov    %edx,0x10(%ebp)
80105472:	85 c0                	test   %eax,%eax
80105474:	7f e7                	jg     8010545d <strncpy+0x3a>
  return os;
80105476:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105479:	c9                   	leave  
8010547a:	c3                   	ret    

8010547b <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010547b:	55                   	push   %ebp
8010547c:	89 e5                	mov    %esp,%ebp
8010547e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105481:	8b 45 08             	mov    0x8(%ebp),%eax
80105484:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105487:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010548b:	7f 05                	jg     80105492 <safestrcpy+0x17>
    return os;
8010548d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105490:	eb 32                	jmp    801054c4 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105492:	90                   	nop
80105493:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105497:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010549b:	7e 1e                	jle    801054bb <safestrcpy+0x40>
8010549d:	8b 55 0c             	mov    0xc(%ebp),%edx
801054a0:	8d 42 01             	lea    0x1(%edx),%eax
801054a3:	89 45 0c             	mov    %eax,0xc(%ebp)
801054a6:	8b 45 08             	mov    0x8(%ebp),%eax
801054a9:	8d 48 01             	lea    0x1(%eax),%ecx
801054ac:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054af:	0f b6 12             	movzbl (%edx),%edx
801054b2:	88 10                	mov    %dl,(%eax)
801054b4:	0f b6 00             	movzbl (%eax),%eax
801054b7:	84 c0                	test   %al,%al
801054b9:	75 d8                	jne    80105493 <safestrcpy+0x18>
    ;
  *s = 0;
801054bb:	8b 45 08             	mov    0x8(%ebp),%eax
801054be:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801054c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054c4:	c9                   	leave  
801054c5:	c3                   	ret    

801054c6 <strlen>:

int
strlen(const char *s)
{
801054c6:	55                   	push   %ebp
801054c7:	89 e5                	mov    %esp,%ebp
801054c9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801054cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054d3:	eb 04                	jmp    801054d9 <strlen+0x13>
801054d5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054dc:	8b 45 08             	mov    0x8(%ebp),%eax
801054df:	01 d0                	add    %edx,%eax
801054e1:	0f b6 00             	movzbl (%eax),%eax
801054e4:	84 c0                	test   %al,%al
801054e6:	75 ed                	jne    801054d5 <strlen+0xf>
    ;
  return n;
801054e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054eb:	c9                   	leave  
801054ec:	c3                   	ret    

801054ed <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801054ed:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801054f1:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801054f5:	55                   	push   %ebp
  pushl %ebx
801054f6:	53                   	push   %ebx
  pushl %esi
801054f7:	56                   	push   %esi
  pushl %edi
801054f8:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801054f9:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801054fb:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801054fd:	5f                   	pop    %edi
  popl %esi
801054fe:	5e                   	pop    %esi
  popl %ebx
801054ff:	5b                   	pop    %ebx
  popl %ebp
80105500:	5d                   	pop    %ebp
  ret
80105501:	c3                   	ret    

80105502 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105502:	55                   	push   %ebp
80105503:	89 e5                	mov    %esp,%ebp
80105505:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105508:	e8 07 ea ff ff       	call   80103f14 <myproc>
8010550d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105513:	8b 00                	mov    (%eax),%eax
80105515:	39 45 08             	cmp    %eax,0x8(%ebp)
80105518:	73 0f                	jae    80105529 <fetchint+0x27>
8010551a:	8b 45 08             	mov    0x8(%ebp),%eax
8010551d:	8d 50 04             	lea    0x4(%eax),%edx
80105520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105523:	8b 00                	mov    (%eax),%eax
80105525:	39 c2                	cmp    %eax,%edx
80105527:	76 07                	jbe    80105530 <fetchint+0x2e>
    return -1;
80105529:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010552e:	eb 0f                	jmp    8010553f <fetchint+0x3d>
  *ip = *(int*)(addr);
80105530:	8b 45 08             	mov    0x8(%ebp),%eax
80105533:	8b 10                	mov    (%eax),%edx
80105535:	8b 45 0c             	mov    0xc(%ebp),%eax
80105538:	89 10                	mov    %edx,(%eax)
  return 0;
8010553a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010553f:	c9                   	leave  
80105540:	c3                   	ret    

80105541 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105541:	55                   	push   %ebp
80105542:	89 e5                	mov    %esp,%ebp
80105544:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105547:	e8 c8 e9 ff ff       	call   80103f14 <myproc>
8010554c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010554f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105552:	8b 00                	mov    (%eax),%eax
80105554:	39 45 08             	cmp    %eax,0x8(%ebp)
80105557:	72 07                	jb     80105560 <fetchstr+0x1f>
    return -1;
80105559:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010555e:	eb 41                	jmp    801055a1 <fetchstr+0x60>
  *pp = (char*)addr;
80105560:	8b 55 08             	mov    0x8(%ebp),%edx
80105563:	8b 45 0c             	mov    0xc(%ebp),%eax
80105566:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105568:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010556b:	8b 00                	mov    (%eax),%eax
8010556d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105570:	8b 45 0c             	mov    0xc(%ebp),%eax
80105573:	8b 00                	mov    (%eax),%eax
80105575:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105578:	eb 1a                	jmp    80105594 <fetchstr+0x53>
    if(*s == 0)
8010557a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557d:	0f b6 00             	movzbl (%eax),%eax
80105580:	84 c0                	test   %al,%al
80105582:	75 0c                	jne    80105590 <fetchstr+0x4f>
      return s - *pp;
80105584:	8b 45 0c             	mov    0xc(%ebp),%eax
80105587:	8b 10                	mov    (%eax),%edx
80105589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010558c:	29 d0                	sub    %edx,%eax
8010558e:	eb 11                	jmp    801055a1 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105590:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105597:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010559a:	72 de                	jb     8010557a <fetchstr+0x39>
  }
  return -1;
8010559c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055a1:	c9                   	leave  
801055a2:	c3                   	ret    

801055a3 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055a3:	55                   	push   %ebp
801055a4:	89 e5                	mov    %esp,%ebp
801055a6:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801055a9:	e8 66 e9 ff ff       	call   80103f14 <myproc>
801055ae:	8b 40 18             	mov    0x18(%eax),%eax
801055b1:	8b 50 44             	mov    0x44(%eax),%edx
801055b4:	8b 45 08             	mov    0x8(%ebp),%eax
801055b7:	c1 e0 02             	shl    $0x2,%eax
801055ba:	01 d0                	add    %edx,%eax
801055bc:	83 c0 04             	add    $0x4,%eax
801055bf:	83 ec 08             	sub    $0x8,%esp
801055c2:	ff 75 0c             	push   0xc(%ebp)
801055c5:	50                   	push   %eax
801055c6:	e8 37 ff ff ff       	call   80105502 <fetchint>
801055cb:	83 c4 10             	add    $0x10,%esp
}
801055ce:	c9                   	leave  
801055cf:	c3                   	ret    

801055d0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801055d0:	55                   	push   %ebp
801055d1:	89 e5                	mov    %esp,%ebp
801055d3:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801055d6:	e8 39 e9 ff ff       	call   80103f14 <myproc>
801055db:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801055de:	83 ec 08             	sub    $0x8,%esp
801055e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055e4:	50                   	push   %eax
801055e5:	ff 75 08             	push   0x8(%ebp)
801055e8:	e8 b6 ff ff ff       	call   801055a3 <argint>
801055ed:	83 c4 10             	add    $0x10,%esp
801055f0:	85 c0                	test   %eax,%eax
801055f2:	79 07                	jns    801055fb <argptr+0x2b>
    return -1;
801055f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f9:	eb 3b                	jmp    80105636 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801055fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ff:	78 1f                	js     80105620 <argptr+0x50>
80105601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105604:	8b 00                	mov    (%eax),%eax
80105606:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105609:	39 d0                	cmp    %edx,%eax
8010560b:	76 13                	jbe    80105620 <argptr+0x50>
8010560d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105610:	89 c2                	mov    %eax,%edx
80105612:	8b 45 10             	mov    0x10(%ebp),%eax
80105615:	01 c2                	add    %eax,%edx
80105617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561a:	8b 00                	mov    (%eax),%eax
8010561c:	39 c2                	cmp    %eax,%edx
8010561e:	76 07                	jbe    80105627 <argptr+0x57>
    return -1;
80105620:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105625:	eb 0f                	jmp    80105636 <argptr+0x66>
  *pp = (char*)i;
80105627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010562a:	89 c2                	mov    %eax,%edx
8010562c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562f:	89 10                	mov    %edx,(%eax)
  return 0;
80105631:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105636:	c9                   	leave  
80105637:	c3                   	ret    

80105638 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105638:	55                   	push   %ebp
80105639:	89 e5                	mov    %esp,%ebp
8010563b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010563e:	83 ec 08             	sub    $0x8,%esp
80105641:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105644:	50                   	push   %eax
80105645:	ff 75 08             	push   0x8(%ebp)
80105648:	e8 56 ff ff ff       	call   801055a3 <argint>
8010564d:	83 c4 10             	add    $0x10,%esp
80105650:	85 c0                	test   %eax,%eax
80105652:	79 07                	jns    8010565b <argstr+0x23>
    return -1;
80105654:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105659:	eb 12                	jmp    8010566d <argstr+0x35>
  return fetchstr(addr, pp);
8010565b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565e:	83 ec 08             	sub    $0x8,%esp
80105661:	ff 75 0c             	push   0xc(%ebp)
80105664:	50                   	push   %eax
80105665:	e8 d7 fe ff ff       	call   80105541 <fetchstr>
8010566a:	83 c4 10             	add    $0x10,%esp
}
8010566d:	c9                   	leave  
8010566e:	c3                   	ret    

8010566f <syscall>:
[SYS_getpinfo] sys_getpinfo,
};

void
syscall(void)
{
8010566f:	55                   	push   %ebp
80105670:	89 e5                	mov    %esp,%ebp
80105672:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105675:	e8 9a e8 ff ff       	call   80103f14 <myproc>
8010567a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010567d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105680:	8b 40 18             	mov    0x18(%eax),%eax
80105683:	8b 40 1c             	mov    0x1c(%eax),%eax
80105686:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105689:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010568d:	7e 2f                	jle    801056be <syscall+0x4f>
8010568f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105692:	83 f8 17             	cmp    $0x17,%eax
80105695:	77 27                	ja     801056be <syscall+0x4f>
80105697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010569a:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801056a1:	85 c0                	test   %eax,%eax
801056a3:	74 19                	je     801056be <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801056a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056a8:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801056af:	ff d0                	call   *%eax
801056b1:	89 c2                	mov    %eax,%edx
801056b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b6:	8b 40 18             	mov    0x18(%eax),%eax
801056b9:	89 50 1c             	mov    %edx,0x1c(%eax)
801056bc:	eb 2c                	jmp    801056ea <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801056be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c1:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801056c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c7:	8b 40 10             	mov    0x10(%eax),%eax
801056ca:	ff 75 f0             	push   -0x10(%ebp)
801056cd:	52                   	push   %edx
801056ce:	50                   	push   %eax
801056cf:	68 fc ac 10 80       	push   $0x8010acfc
801056d4:	e8 1b ad ff ff       	call   801003f4 <cprintf>
801056d9:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801056dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056df:	8b 40 18             	mov    0x18(%eax),%eax
801056e2:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801056e9:	90                   	nop
801056ea:	90                   	nop
801056eb:	c9                   	leave  
801056ec:	c3                   	ret    

801056ed <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801056ed:	55                   	push   %ebp
801056ee:	89 e5                	mov    %esp,%ebp
801056f0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801056f3:	83 ec 08             	sub    $0x8,%esp
801056f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056f9:	50                   	push   %eax
801056fa:	ff 75 08             	push   0x8(%ebp)
801056fd:	e8 a1 fe ff ff       	call   801055a3 <argint>
80105702:	83 c4 10             	add    $0x10,%esp
80105705:	85 c0                	test   %eax,%eax
80105707:	79 07                	jns    80105710 <argfd+0x23>
    return -1;
80105709:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010570e:	eb 4f                	jmp    8010575f <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105713:	85 c0                	test   %eax,%eax
80105715:	78 20                	js     80105737 <argfd+0x4a>
80105717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010571a:	83 f8 0f             	cmp    $0xf,%eax
8010571d:	7f 18                	jg     80105737 <argfd+0x4a>
8010571f:	e8 f0 e7 ff ff       	call   80103f14 <myproc>
80105724:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105727:	83 c2 08             	add    $0x8,%edx
8010572a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010572e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105731:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105735:	75 07                	jne    8010573e <argfd+0x51>
    return -1;
80105737:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010573c:	eb 21                	jmp    8010575f <argfd+0x72>
  if(pfd)
8010573e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105742:	74 08                	je     8010574c <argfd+0x5f>
    *pfd = fd;
80105744:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105747:	8b 45 0c             	mov    0xc(%ebp),%eax
8010574a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010574c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105750:	74 08                	je     8010575a <argfd+0x6d>
    *pf = f;
80105752:	8b 45 10             	mov    0x10(%ebp),%eax
80105755:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105758:	89 10                	mov    %edx,(%eax)
  return 0;
8010575a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010575f:	c9                   	leave  
80105760:	c3                   	ret    

80105761 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105761:	55                   	push   %ebp
80105762:	89 e5                	mov    %esp,%ebp
80105764:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105767:	e8 a8 e7 ff ff       	call   80103f14 <myproc>
8010576c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010576f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105776:	eb 2a                	jmp    801057a2 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105778:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010577b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010577e:	83 c2 08             	add    $0x8,%edx
80105781:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105785:	85 c0                	test   %eax,%eax
80105787:	75 15                	jne    8010579e <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105789:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010578f:	8d 4a 08             	lea    0x8(%edx),%ecx
80105792:	8b 55 08             	mov    0x8(%ebp),%edx
80105795:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579c:	eb 0f                	jmp    801057ad <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010579e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801057a2:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801057a6:	7e d0                	jle    80105778 <fdalloc+0x17>
    }
  }
  return -1;
801057a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057ad:	c9                   	leave  
801057ae:	c3                   	ret    

801057af <sys_dup>:

int
sys_dup(void)
{
801057af:	55                   	push   %ebp
801057b0:	89 e5                	mov    %esp,%ebp
801057b2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801057b5:	83 ec 04             	sub    $0x4,%esp
801057b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057bb:	50                   	push   %eax
801057bc:	6a 00                	push   $0x0
801057be:	6a 00                	push   $0x0
801057c0:	e8 28 ff ff ff       	call   801056ed <argfd>
801057c5:	83 c4 10             	add    $0x10,%esp
801057c8:	85 c0                	test   %eax,%eax
801057ca:	79 07                	jns    801057d3 <sys_dup+0x24>
    return -1;
801057cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d1:	eb 31                	jmp    80105804 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801057d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d6:	83 ec 0c             	sub    $0xc,%esp
801057d9:	50                   	push   %eax
801057da:	e8 82 ff ff ff       	call   80105761 <fdalloc>
801057df:	83 c4 10             	add    $0x10,%esp
801057e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057e9:	79 07                	jns    801057f2 <sys_dup+0x43>
    return -1;
801057eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f0:	eb 12                	jmp    80105804 <sys_dup+0x55>
  filedup(f);
801057f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f5:	83 ec 0c             	sub    $0xc,%esp
801057f8:	50                   	push   %eax
801057f9:	e8 4c b8 ff ff       	call   8010104a <filedup>
801057fe:	83 c4 10             	add    $0x10,%esp
  return fd;
80105801:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105804:	c9                   	leave  
80105805:	c3                   	ret    

80105806 <sys_read>:

int
sys_read(void)
{
80105806:	55                   	push   %ebp
80105807:	89 e5                	mov    %esp,%ebp
80105809:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010580c:	83 ec 04             	sub    $0x4,%esp
8010580f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105812:	50                   	push   %eax
80105813:	6a 00                	push   $0x0
80105815:	6a 00                	push   $0x0
80105817:	e8 d1 fe ff ff       	call   801056ed <argfd>
8010581c:	83 c4 10             	add    $0x10,%esp
8010581f:	85 c0                	test   %eax,%eax
80105821:	78 2e                	js     80105851 <sys_read+0x4b>
80105823:	83 ec 08             	sub    $0x8,%esp
80105826:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105829:	50                   	push   %eax
8010582a:	6a 02                	push   $0x2
8010582c:	e8 72 fd ff ff       	call   801055a3 <argint>
80105831:	83 c4 10             	add    $0x10,%esp
80105834:	85 c0                	test   %eax,%eax
80105836:	78 19                	js     80105851 <sys_read+0x4b>
80105838:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010583b:	83 ec 04             	sub    $0x4,%esp
8010583e:	50                   	push   %eax
8010583f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105842:	50                   	push   %eax
80105843:	6a 01                	push   $0x1
80105845:	e8 86 fd ff ff       	call   801055d0 <argptr>
8010584a:	83 c4 10             	add    $0x10,%esp
8010584d:	85 c0                	test   %eax,%eax
8010584f:	79 07                	jns    80105858 <sys_read+0x52>
    return -1;
80105851:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105856:	eb 17                	jmp    8010586f <sys_read+0x69>
  return fileread(f, p, n);
80105858:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010585b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010585e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105861:	83 ec 04             	sub    $0x4,%esp
80105864:	51                   	push   %ecx
80105865:	52                   	push   %edx
80105866:	50                   	push   %eax
80105867:	e8 6e b9 ff ff       	call   801011da <fileread>
8010586c:	83 c4 10             	add    $0x10,%esp
}
8010586f:	c9                   	leave  
80105870:	c3                   	ret    

80105871 <sys_write>:

int
sys_write(void)
{
80105871:	55                   	push   %ebp
80105872:	89 e5                	mov    %esp,%ebp
80105874:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105877:	83 ec 04             	sub    $0x4,%esp
8010587a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010587d:	50                   	push   %eax
8010587e:	6a 00                	push   $0x0
80105880:	6a 00                	push   $0x0
80105882:	e8 66 fe ff ff       	call   801056ed <argfd>
80105887:	83 c4 10             	add    $0x10,%esp
8010588a:	85 c0                	test   %eax,%eax
8010588c:	78 2e                	js     801058bc <sys_write+0x4b>
8010588e:	83 ec 08             	sub    $0x8,%esp
80105891:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105894:	50                   	push   %eax
80105895:	6a 02                	push   $0x2
80105897:	e8 07 fd ff ff       	call   801055a3 <argint>
8010589c:	83 c4 10             	add    $0x10,%esp
8010589f:	85 c0                	test   %eax,%eax
801058a1:	78 19                	js     801058bc <sys_write+0x4b>
801058a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a6:	83 ec 04             	sub    $0x4,%esp
801058a9:	50                   	push   %eax
801058aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058ad:	50                   	push   %eax
801058ae:	6a 01                	push   $0x1
801058b0:	e8 1b fd ff ff       	call   801055d0 <argptr>
801058b5:	83 c4 10             	add    $0x10,%esp
801058b8:	85 c0                	test   %eax,%eax
801058ba:	79 07                	jns    801058c3 <sys_write+0x52>
    return -1;
801058bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c1:	eb 17                	jmp    801058da <sys_write+0x69>
  return filewrite(f, p, n);
801058c3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058c6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058cc:	83 ec 04             	sub    $0x4,%esp
801058cf:	51                   	push   %ecx
801058d0:	52                   	push   %edx
801058d1:	50                   	push   %eax
801058d2:	e8 bb b9 ff ff       	call   80101292 <filewrite>
801058d7:	83 c4 10             	add    $0x10,%esp
}
801058da:	c9                   	leave  
801058db:	c3                   	ret    

801058dc <sys_close>:

int
sys_close(void)
{
801058dc:	55                   	push   %ebp
801058dd:	89 e5                	mov    %esp,%ebp
801058df:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801058e2:	83 ec 04             	sub    $0x4,%esp
801058e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058e8:	50                   	push   %eax
801058e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058ec:	50                   	push   %eax
801058ed:	6a 00                	push   $0x0
801058ef:	e8 f9 fd ff ff       	call   801056ed <argfd>
801058f4:	83 c4 10             	add    $0x10,%esp
801058f7:	85 c0                	test   %eax,%eax
801058f9:	79 07                	jns    80105902 <sys_close+0x26>
    return -1;
801058fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105900:	eb 27                	jmp    80105929 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105902:	e8 0d e6 ff ff       	call   80103f14 <myproc>
80105907:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010590a:	83 c2 08             	add    $0x8,%edx
8010590d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105914:	00 
  fileclose(f);
80105915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105918:	83 ec 0c             	sub    $0xc,%esp
8010591b:	50                   	push   %eax
8010591c:	e8 7a b7 ff ff       	call   8010109b <fileclose>
80105921:	83 c4 10             	add    $0x10,%esp
  return 0;
80105924:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105929:	c9                   	leave  
8010592a:	c3                   	ret    

8010592b <sys_fstat>:

int
sys_fstat(void)
{
8010592b:	55                   	push   %ebp
8010592c:	89 e5                	mov    %esp,%ebp
8010592e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105931:	83 ec 04             	sub    $0x4,%esp
80105934:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105937:	50                   	push   %eax
80105938:	6a 00                	push   $0x0
8010593a:	6a 00                	push   $0x0
8010593c:	e8 ac fd ff ff       	call   801056ed <argfd>
80105941:	83 c4 10             	add    $0x10,%esp
80105944:	85 c0                	test   %eax,%eax
80105946:	78 17                	js     8010595f <sys_fstat+0x34>
80105948:	83 ec 04             	sub    $0x4,%esp
8010594b:	6a 14                	push   $0x14
8010594d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105950:	50                   	push   %eax
80105951:	6a 01                	push   $0x1
80105953:	e8 78 fc ff ff       	call   801055d0 <argptr>
80105958:	83 c4 10             	add    $0x10,%esp
8010595b:	85 c0                	test   %eax,%eax
8010595d:	79 07                	jns    80105966 <sys_fstat+0x3b>
    return -1;
8010595f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105964:	eb 13                	jmp    80105979 <sys_fstat+0x4e>
  return filestat(f, st);
80105966:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596c:	83 ec 08             	sub    $0x8,%esp
8010596f:	52                   	push   %edx
80105970:	50                   	push   %eax
80105971:	e8 0d b8 ff ff       	call   80101183 <filestat>
80105976:	83 c4 10             	add    $0x10,%esp
}
80105979:	c9                   	leave  
8010597a:	c3                   	ret    

8010597b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010597b:	55                   	push   %ebp
8010597c:	89 e5                	mov    %esp,%ebp
8010597e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105981:	83 ec 08             	sub    $0x8,%esp
80105984:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105987:	50                   	push   %eax
80105988:	6a 00                	push   $0x0
8010598a:	e8 a9 fc ff ff       	call   80105638 <argstr>
8010598f:	83 c4 10             	add    $0x10,%esp
80105992:	85 c0                	test   %eax,%eax
80105994:	78 15                	js     801059ab <sys_link+0x30>
80105996:	83 ec 08             	sub    $0x8,%esp
80105999:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010599c:	50                   	push   %eax
8010599d:	6a 01                	push   $0x1
8010599f:	e8 94 fc ff ff       	call   80105638 <argstr>
801059a4:	83 c4 10             	add    $0x10,%esp
801059a7:	85 c0                	test   %eax,%eax
801059a9:	79 0a                	jns    801059b5 <sys_link+0x3a>
    return -1;
801059ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b0:	e9 68 01 00 00       	jmp    80105b1d <sys_link+0x1a2>

  begin_op();
801059b5:	e8 66 db ff ff       	call   80103520 <begin_op>
  if((ip = namei(old)) == 0){
801059ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
801059bd:	83 ec 0c             	sub    $0xc,%esp
801059c0:	50                   	push   %eax
801059c1:	e8 57 cb ff ff       	call   8010251d <namei>
801059c6:	83 c4 10             	add    $0x10,%esp
801059c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059d0:	75 0f                	jne    801059e1 <sys_link+0x66>
    end_op();
801059d2:	e8 d5 db ff ff       	call   801035ac <end_op>
    return -1;
801059d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059dc:	e9 3c 01 00 00       	jmp    80105b1d <sys_link+0x1a2>
  }

  ilock(ip);
801059e1:	83 ec 0c             	sub    $0xc,%esp
801059e4:	ff 75 f4             	push   -0xc(%ebp)
801059e7:	e8 fe bf ff ff       	call   801019ea <ilock>
801059ec:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801059ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059f6:	66 83 f8 01          	cmp    $0x1,%ax
801059fa:	75 1d                	jne    80105a19 <sys_link+0x9e>
    iunlockput(ip);
801059fc:	83 ec 0c             	sub    $0xc,%esp
801059ff:	ff 75 f4             	push   -0xc(%ebp)
80105a02:	e8 14 c2 ff ff       	call   80101c1b <iunlockput>
80105a07:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a0a:	e8 9d db ff ff       	call   801035ac <end_op>
    return -1;
80105a0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a14:	e9 04 01 00 00       	jmp    80105b1d <sys_link+0x1a2>
  }

  ip->nlink++;
80105a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a20:	83 c0 01             	add    $0x1,%eax
80105a23:	89 c2                	mov    %eax,%edx
80105a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a28:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a2c:	83 ec 0c             	sub    $0xc,%esp
80105a2f:	ff 75 f4             	push   -0xc(%ebp)
80105a32:	e8 d6 bd ff ff       	call   8010180d <iupdate>
80105a37:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a3a:	83 ec 0c             	sub    $0xc,%esp
80105a3d:	ff 75 f4             	push   -0xc(%ebp)
80105a40:	e8 b8 c0 ff ff       	call   80101afd <iunlock>
80105a45:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a48:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a4b:	83 ec 08             	sub    $0x8,%esp
80105a4e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a51:	52                   	push   %edx
80105a52:	50                   	push   %eax
80105a53:	e8 e1 ca ff ff       	call   80102539 <nameiparent>
80105a58:	83 c4 10             	add    $0x10,%esp
80105a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a62:	74 71                	je     80105ad5 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a64:	83 ec 0c             	sub    $0xc,%esp
80105a67:	ff 75 f0             	push   -0x10(%ebp)
80105a6a:	e8 7b bf ff ff       	call   801019ea <ilock>
80105a6f:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a75:	8b 10                	mov    (%eax),%edx
80105a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7a:	8b 00                	mov    (%eax),%eax
80105a7c:	39 c2                	cmp    %eax,%edx
80105a7e:	75 1d                	jne    80105a9d <sys_link+0x122>
80105a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a83:	8b 40 04             	mov    0x4(%eax),%eax
80105a86:	83 ec 04             	sub    $0x4,%esp
80105a89:	50                   	push   %eax
80105a8a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105a8d:	50                   	push   %eax
80105a8e:	ff 75 f0             	push   -0x10(%ebp)
80105a91:	e8 f0 c7 ff ff       	call   80102286 <dirlink>
80105a96:	83 c4 10             	add    $0x10,%esp
80105a99:	85 c0                	test   %eax,%eax
80105a9b:	79 10                	jns    80105aad <sys_link+0x132>
    iunlockput(dp);
80105a9d:	83 ec 0c             	sub    $0xc,%esp
80105aa0:	ff 75 f0             	push   -0x10(%ebp)
80105aa3:	e8 73 c1 ff ff       	call   80101c1b <iunlockput>
80105aa8:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105aab:	eb 29                	jmp    80105ad6 <sys_link+0x15b>
  }
  iunlockput(dp);
80105aad:	83 ec 0c             	sub    $0xc,%esp
80105ab0:	ff 75 f0             	push   -0x10(%ebp)
80105ab3:	e8 63 c1 ff ff       	call   80101c1b <iunlockput>
80105ab8:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105abb:	83 ec 0c             	sub    $0xc,%esp
80105abe:	ff 75 f4             	push   -0xc(%ebp)
80105ac1:	e8 85 c0 ff ff       	call   80101b4b <iput>
80105ac6:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ac9:	e8 de da ff ff       	call   801035ac <end_op>

  return 0;
80105ace:	b8 00 00 00 00       	mov    $0x0,%eax
80105ad3:	eb 48                	jmp    80105b1d <sys_link+0x1a2>
    goto bad;
80105ad5:	90                   	nop

bad:
  ilock(ip);
80105ad6:	83 ec 0c             	sub    $0xc,%esp
80105ad9:	ff 75 f4             	push   -0xc(%ebp)
80105adc:	e8 09 bf ff ff       	call   801019ea <ilock>
80105ae1:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105aeb:	83 e8 01             	sub    $0x1,%eax
80105aee:	89 c2                	mov    %eax,%edx
80105af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af3:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105af7:	83 ec 0c             	sub    $0xc,%esp
80105afa:	ff 75 f4             	push   -0xc(%ebp)
80105afd:	e8 0b bd ff ff       	call   8010180d <iupdate>
80105b02:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b05:	83 ec 0c             	sub    $0xc,%esp
80105b08:	ff 75 f4             	push   -0xc(%ebp)
80105b0b:	e8 0b c1 ff ff       	call   80101c1b <iunlockput>
80105b10:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b13:	e8 94 da ff ff       	call   801035ac <end_op>
  return -1;
80105b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b1d:	c9                   	leave  
80105b1e:	c3                   	ret    

80105b1f <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b1f:	55                   	push   %ebp
80105b20:	89 e5                	mov    %esp,%ebp
80105b22:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b25:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b2c:	eb 40                	jmp    80105b6e <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b31:	6a 10                	push   $0x10
80105b33:	50                   	push   %eax
80105b34:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b37:	50                   	push   %eax
80105b38:	ff 75 08             	push   0x8(%ebp)
80105b3b:	e8 96 c3 ff ff       	call   80101ed6 <readi>
80105b40:	83 c4 10             	add    $0x10,%esp
80105b43:	83 f8 10             	cmp    $0x10,%eax
80105b46:	74 0d                	je     80105b55 <isdirempty+0x36>
      panic("isdirempty: readi");
80105b48:	83 ec 0c             	sub    $0xc,%esp
80105b4b:	68 18 ad 10 80       	push   $0x8010ad18
80105b50:	e8 54 aa ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105b55:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b59:	66 85 c0             	test   %ax,%ax
80105b5c:	74 07                	je     80105b65 <isdirempty+0x46>
      return 0;
80105b5e:	b8 00 00 00 00       	mov    $0x0,%eax
80105b63:	eb 1b                	jmp    80105b80 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b68:	83 c0 10             	add    $0x10,%eax
80105b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b71:	8b 50 58             	mov    0x58(%eax),%edx
80105b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b77:	39 c2                	cmp    %eax,%edx
80105b79:	77 b3                	ja     80105b2e <isdirempty+0xf>
  }
  return 1;
80105b7b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105b80:	c9                   	leave  
80105b81:	c3                   	ret    

80105b82 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105b82:	55                   	push   %ebp
80105b83:	89 e5                	mov    %esp,%ebp
80105b85:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105b88:	83 ec 08             	sub    $0x8,%esp
80105b8b:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105b8e:	50                   	push   %eax
80105b8f:	6a 00                	push   $0x0
80105b91:	e8 a2 fa ff ff       	call   80105638 <argstr>
80105b96:	83 c4 10             	add    $0x10,%esp
80105b99:	85 c0                	test   %eax,%eax
80105b9b:	79 0a                	jns    80105ba7 <sys_unlink+0x25>
    return -1;
80105b9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba2:	e9 bf 01 00 00       	jmp    80105d66 <sys_unlink+0x1e4>

  begin_op();
80105ba7:	e8 74 d9 ff ff       	call   80103520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105bac:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105baf:	83 ec 08             	sub    $0x8,%esp
80105bb2:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105bb5:	52                   	push   %edx
80105bb6:	50                   	push   %eax
80105bb7:	e8 7d c9 ff ff       	call   80102539 <nameiparent>
80105bbc:	83 c4 10             	add    $0x10,%esp
80105bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bc6:	75 0f                	jne    80105bd7 <sys_unlink+0x55>
    end_op();
80105bc8:	e8 df d9 ff ff       	call   801035ac <end_op>
    return -1;
80105bcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd2:	e9 8f 01 00 00       	jmp    80105d66 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105bd7:	83 ec 0c             	sub    $0xc,%esp
80105bda:	ff 75 f4             	push   -0xc(%ebp)
80105bdd:	e8 08 be ff ff       	call   801019ea <ilock>
80105be2:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105be5:	83 ec 08             	sub    $0x8,%esp
80105be8:	68 2a ad 10 80       	push   $0x8010ad2a
80105bed:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bf0:	50                   	push   %eax
80105bf1:	e8 bb c5 ff ff       	call   801021b1 <namecmp>
80105bf6:	83 c4 10             	add    $0x10,%esp
80105bf9:	85 c0                	test   %eax,%eax
80105bfb:	0f 84 49 01 00 00    	je     80105d4a <sys_unlink+0x1c8>
80105c01:	83 ec 08             	sub    $0x8,%esp
80105c04:	68 2c ad 10 80       	push   $0x8010ad2c
80105c09:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c0c:	50                   	push   %eax
80105c0d:	e8 9f c5 ff ff       	call   801021b1 <namecmp>
80105c12:	83 c4 10             	add    $0x10,%esp
80105c15:	85 c0                	test   %eax,%eax
80105c17:	0f 84 2d 01 00 00    	je     80105d4a <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c1d:	83 ec 04             	sub    $0x4,%esp
80105c20:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c23:	50                   	push   %eax
80105c24:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c27:	50                   	push   %eax
80105c28:	ff 75 f4             	push   -0xc(%ebp)
80105c2b:	e8 9c c5 ff ff       	call   801021cc <dirlookup>
80105c30:	83 c4 10             	add    $0x10,%esp
80105c33:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c36:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c3a:	0f 84 0d 01 00 00    	je     80105d4d <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105c40:	83 ec 0c             	sub    $0xc,%esp
80105c43:	ff 75 f0             	push   -0x10(%ebp)
80105c46:	e8 9f bd ff ff       	call   801019ea <ilock>
80105c4b:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c51:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c55:	66 85 c0             	test   %ax,%ax
80105c58:	7f 0d                	jg     80105c67 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c5a:	83 ec 0c             	sub    $0xc,%esp
80105c5d:	68 2f ad 10 80       	push   $0x8010ad2f
80105c62:	e8 42 a9 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c6e:	66 83 f8 01          	cmp    $0x1,%ax
80105c72:	75 25                	jne    80105c99 <sys_unlink+0x117>
80105c74:	83 ec 0c             	sub    $0xc,%esp
80105c77:	ff 75 f0             	push   -0x10(%ebp)
80105c7a:	e8 a0 fe ff ff       	call   80105b1f <isdirempty>
80105c7f:	83 c4 10             	add    $0x10,%esp
80105c82:	85 c0                	test   %eax,%eax
80105c84:	75 13                	jne    80105c99 <sys_unlink+0x117>
    iunlockput(ip);
80105c86:	83 ec 0c             	sub    $0xc,%esp
80105c89:	ff 75 f0             	push   -0x10(%ebp)
80105c8c:	e8 8a bf ff ff       	call   80101c1b <iunlockput>
80105c91:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c94:	e9 b5 00 00 00       	jmp    80105d4e <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105c99:	83 ec 04             	sub    $0x4,%esp
80105c9c:	6a 10                	push   $0x10
80105c9e:	6a 00                	push   $0x0
80105ca0:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ca3:	50                   	push   %eax
80105ca4:	e8 cf f5 ff ff       	call   80105278 <memset>
80105ca9:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cac:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105caf:	6a 10                	push   $0x10
80105cb1:	50                   	push   %eax
80105cb2:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cb5:	50                   	push   %eax
80105cb6:	ff 75 f4             	push   -0xc(%ebp)
80105cb9:	e8 6d c3 ff ff       	call   8010202b <writei>
80105cbe:	83 c4 10             	add    $0x10,%esp
80105cc1:	83 f8 10             	cmp    $0x10,%eax
80105cc4:	74 0d                	je     80105cd3 <sys_unlink+0x151>
    panic("unlink: writei");
80105cc6:	83 ec 0c             	sub    $0xc,%esp
80105cc9:	68 41 ad 10 80       	push   $0x8010ad41
80105cce:	e8 d6 a8 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cda:	66 83 f8 01          	cmp    $0x1,%ax
80105cde:	75 21                	jne    80105d01 <sys_unlink+0x17f>
    dp->nlink--;
80105ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ce7:	83 e8 01             	sub    $0x1,%eax
80105cea:	89 c2                	mov    %eax,%edx
80105cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cef:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105cf3:	83 ec 0c             	sub    $0xc,%esp
80105cf6:	ff 75 f4             	push   -0xc(%ebp)
80105cf9:	e8 0f bb ff ff       	call   8010180d <iupdate>
80105cfe:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d01:	83 ec 0c             	sub    $0xc,%esp
80105d04:	ff 75 f4             	push   -0xc(%ebp)
80105d07:	e8 0f bf ff ff       	call   80101c1b <iunlockput>
80105d0c:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d12:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d16:	83 e8 01             	sub    $0x1,%eax
80105d19:	89 c2                	mov    %eax,%edx
80105d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d22:	83 ec 0c             	sub    $0xc,%esp
80105d25:	ff 75 f0             	push   -0x10(%ebp)
80105d28:	e8 e0 ba ff ff       	call   8010180d <iupdate>
80105d2d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d30:	83 ec 0c             	sub    $0xc,%esp
80105d33:	ff 75 f0             	push   -0x10(%ebp)
80105d36:	e8 e0 be ff ff       	call   80101c1b <iunlockput>
80105d3b:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d3e:	e8 69 d8 ff ff       	call   801035ac <end_op>

  return 0;
80105d43:	b8 00 00 00 00       	mov    $0x0,%eax
80105d48:	eb 1c                	jmp    80105d66 <sys_unlink+0x1e4>
    goto bad;
80105d4a:	90                   	nop
80105d4b:	eb 01                	jmp    80105d4e <sys_unlink+0x1cc>
    goto bad;
80105d4d:	90                   	nop

bad:
  iunlockput(dp);
80105d4e:	83 ec 0c             	sub    $0xc,%esp
80105d51:	ff 75 f4             	push   -0xc(%ebp)
80105d54:	e8 c2 be ff ff       	call   80101c1b <iunlockput>
80105d59:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d5c:	e8 4b d8 ff ff       	call   801035ac <end_op>
  return -1;
80105d61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d66:	c9                   	leave  
80105d67:	c3                   	ret    

80105d68 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d68:	55                   	push   %ebp
80105d69:	89 e5                	mov    %esp,%ebp
80105d6b:	83 ec 38             	sub    $0x38,%esp
80105d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d71:	8b 55 10             	mov    0x10(%ebp),%edx
80105d74:	8b 45 14             	mov    0x14(%ebp),%eax
80105d77:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105d7b:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105d7f:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105d83:	83 ec 08             	sub    $0x8,%esp
80105d86:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d89:	50                   	push   %eax
80105d8a:	ff 75 08             	push   0x8(%ebp)
80105d8d:	e8 a7 c7 ff ff       	call   80102539 <nameiparent>
80105d92:	83 c4 10             	add    $0x10,%esp
80105d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d9c:	75 0a                	jne    80105da8 <create+0x40>
    return 0;
80105d9e:	b8 00 00 00 00       	mov    $0x0,%eax
80105da3:	e9 90 01 00 00       	jmp    80105f38 <create+0x1d0>
  ilock(dp);
80105da8:	83 ec 0c             	sub    $0xc,%esp
80105dab:	ff 75 f4             	push   -0xc(%ebp)
80105dae:	e8 37 bc ff ff       	call   801019ea <ilock>
80105db3:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105db6:	83 ec 04             	sub    $0x4,%esp
80105db9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dbc:	50                   	push   %eax
80105dbd:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dc0:	50                   	push   %eax
80105dc1:	ff 75 f4             	push   -0xc(%ebp)
80105dc4:	e8 03 c4 ff ff       	call   801021cc <dirlookup>
80105dc9:	83 c4 10             	add    $0x10,%esp
80105dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dcf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dd3:	74 50                	je     80105e25 <create+0xbd>
    iunlockput(dp);
80105dd5:	83 ec 0c             	sub    $0xc,%esp
80105dd8:	ff 75 f4             	push   -0xc(%ebp)
80105ddb:	e8 3b be ff ff       	call   80101c1b <iunlockput>
80105de0:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105de3:	83 ec 0c             	sub    $0xc,%esp
80105de6:	ff 75 f0             	push   -0x10(%ebp)
80105de9:	e8 fc bb ff ff       	call   801019ea <ilock>
80105dee:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105df1:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105df6:	75 15                	jne    80105e0d <create+0xa5>
80105df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dfb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105dff:	66 83 f8 02          	cmp    $0x2,%ax
80105e03:	75 08                	jne    80105e0d <create+0xa5>
      return ip;
80105e05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e08:	e9 2b 01 00 00       	jmp    80105f38 <create+0x1d0>
    iunlockput(ip);
80105e0d:	83 ec 0c             	sub    $0xc,%esp
80105e10:	ff 75 f0             	push   -0x10(%ebp)
80105e13:	e8 03 be ff ff       	call   80101c1b <iunlockput>
80105e18:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e1b:	b8 00 00 00 00       	mov    $0x0,%eax
80105e20:	e9 13 01 00 00       	jmp    80105f38 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e25:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2c:	8b 00                	mov    (%eax),%eax
80105e2e:	83 ec 08             	sub    $0x8,%esp
80105e31:	52                   	push   %edx
80105e32:	50                   	push   %eax
80105e33:	e8 fe b8 ff ff       	call   80101736 <ialloc>
80105e38:	83 c4 10             	add    $0x10,%esp
80105e3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e42:	75 0d                	jne    80105e51 <create+0xe9>
    panic("create: ialloc");
80105e44:	83 ec 0c             	sub    $0xc,%esp
80105e47:	68 50 ad 10 80       	push   $0x8010ad50
80105e4c:	e8 58 a7 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105e51:	83 ec 0c             	sub    $0xc,%esp
80105e54:	ff 75 f0             	push   -0x10(%ebp)
80105e57:	e8 8e bb ff ff       	call   801019ea <ilock>
80105e5c:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e62:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e66:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6d:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e71:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e78:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105e7e:	83 ec 0c             	sub    $0xc,%esp
80105e81:	ff 75 f0             	push   -0x10(%ebp)
80105e84:	e8 84 b9 ff ff       	call   8010180d <iupdate>
80105e89:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105e8c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105e91:	75 6a                	jne    80105efd <create+0x195>
    dp->nlink++;  // for ".."
80105e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e96:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e9a:	83 c0 01             	add    $0x1,%eax
80105e9d:	89 c2                	mov    %eax,%edx
80105e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea2:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105ea6:	83 ec 0c             	sub    $0xc,%esp
80105ea9:	ff 75 f4             	push   -0xc(%ebp)
80105eac:	e8 5c b9 ff ff       	call   8010180d <iupdate>
80105eb1:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb7:	8b 40 04             	mov    0x4(%eax),%eax
80105eba:	83 ec 04             	sub    $0x4,%esp
80105ebd:	50                   	push   %eax
80105ebe:	68 2a ad 10 80       	push   $0x8010ad2a
80105ec3:	ff 75 f0             	push   -0x10(%ebp)
80105ec6:	e8 bb c3 ff ff       	call   80102286 <dirlink>
80105ecb:	83 c4 10             	add    $0x10,%esp
80105ece:	85 c0                	test   %eax,%eax
80105ed0:	78 1e                	js     80105ef0 <create+0x188>
80105ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed5:	8b 40 04             	mov    0x4(%eax),%eax
80105ed8:	83 ec 04             	sub    $0x4,%esp
80105edb:	50                   	push   %eax
80105edc:	68 2c ad 10 80       	push   $0x8010ad2c
80105ee1:	ff 75 f0             	push   -0x10(%ebp)
80105ee4:	e8 9d c3 ff ff       	call   80102286 <dirlink>
80105ee9:	83 c4 10             	add    $0x10,%esp
80105eec:	85 c0                	test   %eax,%eax
80105eee:	79 0d                	jns    80105efd <create+0x195>
      panic("create dots");
80105ef0:	83 ec 0c             	sub    $0xc,%esp
80105ef3:	68 5f ad 10 80       	push   $0x8010ad5f
80105ef8:	e8 ac a6 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f00:	8b 40 04             	mov    0x4(%eax),%eax
80105f03:	83 ec 04             	sub    $0x4,%esp
80105f06:	50                   	push   %eax
80105f07:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f0a:	50                   	push   %eax
80105f0b:	ff 75 f4             	push   -0xc(%ebp)
80105f0e:	e8 73 c3 ff ff       	call   80102286 <dirlink>
80105f13:	83 c4 10             	add    $0x10,%esp
80105f16:	85 c0                	test   %eax,%eax
80105f18:	79 0d                	jns    80105f27 <create+0x1bf>
    panic("create: dirlink");
80105f1a:	83 ec 0c             	sub    $0xc,%esp
80105f1d:	68 6b ad 10 80       	push   $0x8010ad6b
80105f22:	e8 82 a6 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105f27:	83 ec 0c             	sub    $0xc,%esp
80105f2a:	ff 75 f4             	push   -0xc(%ebp)
80105f2d:	e8 e9 bc ff ff       	call   80101c1b <iunlockput>
80105f32:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f38:	c9                   	leave  
80105f39:	c3                   	ret    

80105f3a <sys_open>:

int
sys_open(void)
{
80105f3a:	55                   	push   %ebp
80105f3b:	89 e5                	mov    %esp,%ebp
80105f3d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f40:	83 ec 08             	sub    $0x8,%esp
80105f43:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f46:	50                   	push   %eax
80105f47:	6a 00                	push   $0x0
80105f49:	e8 ea f6 ff ff       	call   80105638 <argstr>
80105f4e:	83 c4 10             	add    $0x10,%esp
80105f51:	85 c0                	test   %eax,%eax
80105f53:	78 15                	js     80105f6a <sys_open+0x30>
80105f55:	83 ec 08             	sub    $0x8,%esp
80105f58:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f5b:	50                   	push   %eax
80105f5c:	6a 01                	push   $0x1
80105f5e:	e8 40 f6 ff ff       	call   801055a3 <argint>
80105f63:	83 c4 10             	add    $0x10,%esp
80105f66:	85 c0                	test   %eax,%eax
80105f68:	79 0a                	jns    80105f74 <sys_open+0x3a>
    return -1;
80105f6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f6f:	e9 61 01 00 00       	jmp    801060d5 <sys_open+0x19b>

  begin_op();
80105f74:	e8 a7 d5 ff ff       	call   80103520 <begin_op>

  if(omode & O_CREATE){
80105f79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f7c:	25 00 02 00 00       	and    $0x200,%eax
80105f81:	85 c0                	test   %eax,%eax
80105f83:	74 2a                	je     80105faf <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105f85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f88:	6a 00                	push   $0x0
80105f8a:	6a 00                	push   $0x0
80105f8c:	6a 02                	push   $0x2
80105f8e:	50                   	push   %eax
80105f8f:	e8 d4 fd ff ff       	call   80105d68 <create>
80105f94:	83 c4 10             	add    $0x10,%esp
80105f97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105f9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f9e:	75 75                	jne    80106015 <sys_open+0xdb>
      end_op();
80105fa0:	e8 07 d6 ff ff       	call   801035ac <end_op>
      return -1;
80105fa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105faa:	e9 26 01 00 00       	jmp    801060d5 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105faf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fb2:	83 ec 0c             	sub    $0xc,%esp
80105fb5:	50                   	push   %eax
80105fb6:	e8 62 c5 ff ff       	call   8010251d <namei>
80105fbb:	83 c4 10             	add    $0x10,%esp
80105fbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fc5:	75 0f                	jne    80105fd6 <sys_open+0x9c>
      end_op();
80105fc7:	e8 e0 d5 ff ff       	call   801035ac <end_op>
      return -1;
80105fcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd1:	e9 ff 00 00 00       	jmp    801060d5 <sys_open+0x19b>
    }
    ilock(ip);
80105fd6:	83 ec 0c             	sub    $0xc,%esp
80105fd9:	ff 75 f4             	push   -0xc(%ebp)
80105fdc:	e8 09 ba ff ff       	call   801019ea <ilock>
80105fe1:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105feb:	66 83 f8 01          	cmp    $0x1,%ax
80105fef:	75 24                	jne    80106015 <sys_open+0xdb>
80105ff1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ff4:	85 c0                	test   %eax,%eax
80105ff6:	74 1d                	je     80106015 <sys_open+0xdb>
      iunlockput(ip);
80105ff8:	83 ec 0c             	sub    $0xc,%esp
80105ffb:	ff 75 f4             	push   -0xc(%ebp)
80105ffe:	e8 18 bc ff ff       	call   80101c1b <iunlockput>
80106003:	83 c4 10             	add    $0x10,%esp
      end_op();
80106006:	e8 a1 d5 ff ff       	call   801035ac <end_op>
      return -1;
8010600b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106010:	e9 c0 00 00 00       	jmp    801060d5 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106015:	e8 c3 af ff ff       	call   80100fdd <filealloc>
8010601a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010601d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106021:	74 17                	je     8010603a <sys_open+0x100>
80106023:	83 ec 0c             	sub    $0xc,%esp
80106026:	ff 75 f0             	push   -0x10(%ebp)
80106029:	e8 33 f7 ff ff       	call   80105761 <fdalloc>
8010602e:	83 c4 10             	add    $0x10,%esp
80106031:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106034:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106038:	79 2e                	jns    80106068 <sys_open+0x12e>
    if(f)
8010603a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010603e:	74 0e                	je     8010604e <sys_open+0x114>
      fileclose(f);
80106040:	83 ec 0c             	sub    $0xc,%esp
80106043:	ff 75 f0             	push   -0x10(%ebp)
80106046:	e8 50 b0 ff ff       	call   8010109b <fileclose>
8010604b:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010604e:	83 ec 0c             	sub    $0xc,%esp
80106051:	ff 75 f4             	push   -0xc(%ebp)
80106054:	e8 c2 bb ff ff       	call   80101c1b <iunlockput>
80106059:	83 c4 10             	add    $0x10,%esp
    end_op();
8010605c:	e8 4b d5 ff ff       	call   801035ac <end_op>
    return -1;
80106061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106066:	eb 6d                	jmp    801060d5 <sys_open+0x19b>
  }
  iunlock(ip);
80106068:	83 ec 0c             	sub    $0xc,%esp
8010606b:	ff 75 f4             	push   -0xc(%ebp)
8010606e:	e8 8a ba ff ff       	call   80101afd <iunlock>
80106073:	83 c4 10             	add    $0x10,%esp
  end_op();
80106076:	e8 31 d5 ff ff       	call   801035ac <end_op>

  f->type = FD_INODE;
8010607b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106087:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010608a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010608d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106090:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106097:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010609a:	83 e0 01             	and    $0x1,%eax
8010609d:	85 c0                	test   %eax,%eax
8010609f:	0f 94 c0             	sete   %al
801060a2:	89 c2                	mov    %eax,%edx
801060a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a7:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060ad:	83 e0 01             	and    $0x1,%eax
801060b0:	85 c0                	test   %eax,%eax
801060b2:	75 0a                	jne    801060be <sys_open+0x184>
801060b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060b7:	83 e0 02             	and    $0x2,%eax
801060ba:	85 c0                	test   %eax,%eax
801060bc:	74 07                	je     801060c5 <sys_open+0x18b>
801060be:	b8 01 00 00 00       	mov    $0x1,%eax
801060c3:	eb 05                	jmp    801060ca <sys_open+0x190>
801060c5:	b8 00 00 00 00       	mov    $0x0,%eax
801060ca:	89 c2                	mov    %eax,%edx
801060cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cf:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801060d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801060d5:	c9                   	leave  
801060d6:	c3                   	ret    

801060d7 <sys_mkdir>:

int
sys_mkdir(void)
{
801060d7:	55                   	push   %ebp
801060d8:	89 e5                	mov    %esp,%ebp
801060da:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060dd:	e8 3e d4 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801060e2:	83 ec 08             	sub    $0x8,%esp
801060e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060e8:	50                   	push   %eax
801060e9:	6a 00                	push   $0x0
801060eb:	e8 48 f5 ff ff       	call   80105638 <argstr>
801060f0:	83 c4 10             	add    $0x10,%esp
801060f3:	85 c0                	test   %eax,%eax
801060f5:	78 1b                	js     80106112 <sys_mkdir+0x3b>
801060f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fa:	6a 00                	push   $0x0
801060fc:	6a 00                	push   $0x0
801060fe:	6a 01                	push   $0x1
80106100:	50                   	push   %eax
80106101:	e8 62 fc ff ff       	call   80105d68 <create>
80106106:	83 c4 10             	add    $0x10,%esp
80106109:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010610c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106110:	75 0c                	jne    8010611e <sys_mkdir+0x47>
    end_op();
80106112:	e8 95 d4 ff ff       	call   801035ac <end_op>
    return -1;
80106117:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611c:	eb 18                	jmp    80106136 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010611e:	83 ec 0c             	sub    $0xc,%esp
80106121:	ff 75 f4             	push   -0xc(%ebp)
80106124:	e8 f2 ba ff ff       	call   80101c1b <iunlockput>
80106129:	83 c4 10             	add    $0x10,%esp
  end_op();
8010612c:	e8 7b d4 ff ff       	call   801035ac <end_op>
  return 0;
80106131:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106136:	c9                   	leave  
80106137:	c3                   	ret    

80106138 <sys_mknod>:

int
sys_mknod(void)
{
80106138:	55                   	push   %ebp
80106139:	89 e5                	mov    %esp,%ebp
8010613b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010613e:	e8 dd d3 ff ff       	call   80103520 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106143:	83 ec 08             	sub    $0x8,%esp
80106146:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106149:	50                   	push   %eax
8010614a:	6a 00                	push   $0x0
8010614c:	e8 e7 f4 ff ff       	call   80105638 <argstr>
80106151:	83 c4 10             	add    $0x10,%esp
80106154:	85 c0                	test   %eax,%eax
80106156:	78 4f                	js     801061a7 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106158:	83 ec 08             	sub    $0x8,%esp
8010615b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010615e:	50                   	push   %eax
8010615f:	6a 01                	push   $0x1
80106161:	e8 3d f4 ff ff       	call   801055a3 <argint>
80106166:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106169:	85 c0                	test   %eax,%eax
8010616b:	78 3a                	js     801061a7 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
8010616d:	83 ec 08             	sub    $0x8,%esp
80106170:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106173:	50                   	push   %eax
80106174:	6a 02                	push   $0x2
80106176:	e8 28 f4 ff ff       	call   801055a3 <argint>
8010617b:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010617e:	85 c0                	test   %eax,%eax
80106180:	78 25                	js     801061a7 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106182:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106185:	0f bf c8             	movswl %ax,%ecx
80106188:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010618b:	0f bf d0             	movswl %ax,%edx
8010618e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106191:	51                   	push   %ecx
80106192:	52                   	push   %edx
80106193:	6a 03                	push   $0x3
80106195:	50                   	push   %eax
80106196:	e8 cd fb ff ff       	call   80105d68 <create>
8010619b:	83 c4 10             	add    $0x10,%esp
8010619e:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801061a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061a5:	75 0c                	jne    801061b3 <sys_mknod+0x7b>
    end_op();
801061a7:	e8 00 d4 ff ff       	call   801035ac <end_op>
    return -1;
801061ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b1:	eb 18                	jmp    801061cb <sys_mknod+0x93>
  }
  iunlockput(ip);
801061b3:	83 ec 0c             	sub    $0xc,%esp
801061b6:	ff 75 f4             	push   -0xc(%ebp)
801061b9:	e8 5d ba ff ff       	call   80101c1b <iunlockput>
801061be:	83 c4 10             	add    $0x10,%esp
  end_op();
801061c1:	e8 e6 d3 ff ff       	call   801035ac <end_op>
  return 0;
801061c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061cb:	c9                   	leave  
801061cc:	c3                   	ret    

801061cd <sys_chdir>:

int
sys_chdir(void)
{
801061cd:	55                   	push   %ebp
801061ce:	89 e5                	mov    %esp,%ebp
801061d0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801061d3:	e8 3c dd ff ff       	call   80103f14 <myproc>
801061d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801061db:	e8 40 d3 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801061e0:	83 ec 08             	sub    $0x8,%esp
801061e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061e6:	50                   	push   %eax
801061e7:	6a 00                	push   $0x0
801061e9:	e8 4a f4 ff ff       	call   80105638 <argstr>
801061ee:	83 c4 10             	add    $0x10,%esp
801061f1:	85 c0                	test   %eax,%eax
801061f3:	78 18                	js     8010620d <sys_chdir+0x40>
801061f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061f8:	83 ec 0c             	sub    $0xc,%esp
801061fb:	50                   	push   %eax
801061fc:	e8 1c c3 ff ff       	call   8010251d <namei>
80106201:	83 c4 10             	add    $0x10,%esp
80106204:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106207:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010620b:	75 0c                	jne    80106219 <sys_chdir+0x4c>
    end_op();
8010620d:	e8 9a d3 ff ff       	call   801035ac <end_op>
    return -1;
80106212:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106217:	eb 68                	jmp    80106281 <sys_chdir+0xb4>
  }
  ilock(ip);
80106219:	83 ec 0c             	sub    $0xc,%esp
8010621c:	ff 75 f0             	push   -0x10(%ebp)
8010621f:	e8 c6 b7 ff ff       	call   801019ea <ilock>
80106224:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010622e:	66 83 f8 01          	cmp    $0x1,%ax
80106232:	74 1a                	je     8010624e <sys_chdir+0x81>
    iunlockput(ip);
80106234:	83 ec 0c             	sub    $0xc,%esp
80106237:	ff 75 f0             	push   -0x10(%ebp)
8010623a:	e8 dc b9 ff ff       	call   80101c1b <iunlockput>
8010623f:	83 c4 10             	add    $0x10,%esp
    end_op();
80106242:	e8 65 d3 ff ff       	call   801035ac <end_op>
    return -1;
80106247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624c:	eb 33                	jmp    80106281 <sys_chdir+0xb4>
  }
  iunlock(ip);
8010624e:	83 ec 0c             	sub    $0xc,%esp
80106251:	ff 75 f0             	push   -0x10(%ebp)
80106254:	e8 a4 b8 ff ff       	call   80101afd <iunlock>
80106259:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010625c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625f:	8b 40 68             	mov    0x68(%eax),%eax
80106262:	83 ec 0c             	sub    $0xc,%esp
80106265:	50                   	push   %eax
80106266:	e8 e0 b8 ff ff       	call   80101b4b <iput>
8010626b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010626e:	e8 39 d3 ff ff       	call   801035ac <end_op>
  curproc->cwd = ip;
80106273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106276:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106279:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010627c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106281:	c9                   	leave  
80106282:	c3                   	ret    

80106283 <sys_exec>:

int
sys_exec(void)
{
80106283:	55                   	push   %ebp
80106284:	89 e5                	mov    %esp,%ebp
80106286:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010628c:	83 ec 08             	sub    $0x8,%esp
8010628f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106292:	50                   	push   %eax
80106293:	6a 00                	push   $0x0
80106295:	e8 9e f3 ff ff       	call   80105638 <argstr>
8010629a:	83 c4 10             	add    $0x10,%esp
8010629d:	85 c0                	test   %eax,%eax
8010629f:	78 18                	js     801062b9 <sys_exec+0x36>
801062a1:	83 ec 08             	sub    $0x8,%esp
801062a4:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062aa:	50                   	push   %eax
801062ab:	6a 01                	push   $0x1
801062ad:	e8 f1 f2 ff ff       	call   801055a3 <argint>
801062b2:	83 c4 10             	add    $0x10,%esp
801062b5:	85 c0                	test   %eax,%eax
801062b7:	79 0a                	jns    801062c3 <sys_exec+0x40>
    return -1;
801062b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062be:	e9 c6 00 00 00       	jmp    80106389 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801062c3:	83 ec 04             	sub    $0x4,%esp
801062c6:	68 80 00 00 00       	push   $0x80
801062cb:	6a 00                	push   $0x0
801062cd:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801062d3:	50                   	push   %eax
801062d4:	e8 9f ef ff ff       	call   80105278 <memset>
801062d9:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801062dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801062e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e6:	83 f8 1f             	cmp    $0x1f,%eax
801062e9:	76 0a                	jbe    801062f5 <sys_exec+0x72>
      return -1;
801062eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f0:	e9 94 00 00 00       	jmp    80106389 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801062f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f8:	c1 e0 02             	shl    $0x2,%eax
801062fb:	89 c2                	mov    %eax,%edx
801062fd:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106303:	01 c2                	add    %eax,%edx
80106305:	83 ec 08             	sub    $0x8,%esp
80106308:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010630e:	50                   	push   %eax
8010630f:	52                   	push   %edx
80106310:	e8 ed f1 ff ff       	call   80105502 <fetchint>
80106315:	83 c4 10             	add    $0x10,%esp
80106318:	85 c0                	test   %eax,%eax
8010631a:	79 07                	jns    80106323 <sys_exec+0xa0>
      return -1;
8010631c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106321:	eb 66                	jmp    80106389 <sys_exec+0x106>
    if(uarg == 0){
80106323:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106329:	85 c0                	test   %eax,%eax
8010632b:	75 27                	jne    80106354 <sys_exec+0xd1>
      argv[i] = 0;
8010632d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106330:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106337:	00 00 00 00 
      break;
8010633b:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010633c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010633f:	83 ec 08             	sub    $0x8,%esp
80106342:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106348:	52                   	push   %edx
80106349:	50                   	push   %eax
8010634a:	e8 31 a8 ff ff       	call   80100b80 <exec>
8010634f:	83 c4 10             	add    $0x10,%esp
80106352:	eb 35                	jmp    80106389 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80106354:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010635a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635d:	c1 e0 02             	shl    $0x2,%eax
80106360:	01 c2                	add    %eax,%edx
80106362:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106368:	83 ec 08             	sub    $0x8,%esp
8010636b:	52                   	push   %edx
8010636c:	50                   	push   %eax
8010636d:	e8 cf f1 ff ff       	call   80105541 <fetchstr>
80106372:	83 c4 10             	add    $0x10,%esp
80106375:	85 c0                	test   %eax,%eax
80106377:	79 07                	jns    80106380 <sys_exec+0xfd>
      return -1;
80106379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637e:	eb 09                	jmp    80106389 <sys_exec+0x106>
  for(i=0;; i++){
80106380:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106384:	e9 5a ff ff ff       	jmp    801062e3 <sys_exec+0x60>
}
80106389:	c9                   	leave  
8010638a:	c3                   	ret    

8010638b <sys_pipe>:

int
sys_pipe(void)
{
8010638b:	55                   	push   %ebp
8010638c:	89 e5                	mov    %esp,%ebp
8010638e:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106391:	83 ec 04             	sub    $0x4,%esp
80106394:	6a 08                	push   $0x8
80106396:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106399:	50                   	push   %eax
8010639a:	6a 00                	push   $0x0
8010639c:	e8 2f f2 ff ff       	call   801055d0 <argptr>
801063a1:	83 c4 10             	add    $0x10,%esp
801063a4:	85 c0                	test   %eax,%eax
801063a6:	79 0a                	jns    801063b2 <sys_pipe+0x27>
    return -1;
801063a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ad:	e9 ae 00 00 00       	jmp    80106460 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
801063b2:	83 ec 08             	sub    $0x8,%esp
801063b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063b8:	50                   	push   %eax
801063b9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063bc:	50                   	push   %eax
801063bd:	e8 8f d6 ff ff       	call   80103a51 <pipealloc>
801063c2:	83 c4 10             	add    $0x10,%esp
801063c5:	85 c0                	test   %eax,%eax
801063c7:	79 0a                	jns    801063d3 <sys_pipe+0x48>
    return -1;
801063c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ce:	e9 8d 00 00 00       	jmp    80106460 <sys_pipe+0xd5>
  fd0 = -1;
801063d3:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801063da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063dd:	83 ec 0c             	sub    $0xc,%esp
801063e0:	50                   	push   %eax
801063e1:	e8 7b f3 ff ff       	call   80105761 <fdalloc>
801063e6:	83 c4 10             	add    $0x10,%esp
801063e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063f0:	78 18                	js     8010640a <sys_pipe+0x7f>
801063f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063f5:	83 ec 0c             	sub    $0xc,%esp
801063f8:	50                   	push   %eax
801063f9:	e8 63 f3 ff ff       	call   80105761 <fdalloc>
801063fe:	83 c4 10             	add    $0x10,%esp
80106401:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106404:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106408:	79 3e                	jns    80106448 <sys_pipe+0xbd>
    if(fd0 >= 0)
8010640a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010640e:	78 13                	js     80106423 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80106410:	e8 ff da ff ff       	call   80103f14 <myproc>
80106415:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106418:	83 c2 08             	add    $0x8,%edx
8010641b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106422:	00 
    fileclose(rf);
80106423:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106426:	83 ec 0c             	sub    $0xc,%esp
80106429:	50                   	push   %eax
8010642a:	e8 6c ac ff ff       	call   8010109b <fileclose>
8010642f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106432:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106435:	83 ec 0c             	sub    $0xc,%esp
80106438:	50                   	push   %eax
80106439:	e8 5d ac ff ff       	call   8010109b <fileclose>
8010643e:	83 c4 10             	add    $0x10,%esp
    return -1;
80106441:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106446:	eb 18                	jmp    80106460 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106448:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010644b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010644e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106450:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106453:	8d 50 04             	lea    0x4(%eax),%edx
80106456:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106459:	89 02                	mov    %eax,(%edx)
  return 0;
8010645b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106460:	c9                   	leave  
80106461:	c3                   	ret    

80106462 <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
80106462:	55                   	push   %ebp
80106463:	89 e5                	mov    %esp,%ebp
80106465:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106468:	e8 e1 dd ff ff       	call   8010424e <fork>
}
8010646d:	c9                   	leave  
8010646e:	c3                   	ret    

8010646f <sys_exit>:

int
sys_exit(void)
{
8010646f:	55                   	push   %ebp
80106470:	89 e5                	mov    %esp,%ebp
80106472:	83 ec 08             	sub    $0x8,%esp
  exit();
80106475:	e8 4d df ff ff       	call   801043c7 <exit>
  return 0;  // not reached
8010647a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010647f:	c9                   	leave  
80106480:	c3                   	ret    

80106481 <sys_wait>:

int
sys_wait(void)
{
80106481:	55                   	push   %ebp
80106482:	89 e5                	mov    %esp,%ebp
80106484:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106487:	e8 5e e0 ff ff       	call   801044ea <wait>
}
8010648c:	c9                   	leave  
8010648d:	c3                   	ret    

8010648e <sys_kill>:

int
sys_kill(void)
{
8010648e:	55                   	push   %ebp
8010648f:	89 e5                	mov    %esp,%ebp
80106491:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106494:	83 ec 08             	sub    $0x8,%esp
80106497:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010649a:	50                   	push   %eax
8010649b:	6a 00                	push   $0x0
8010649d:	e8 01 f1 ff ff       	call   801055a3 <argint>
801064a2:	83 c4 10             	add    $0x10,%esp
801064a5:	85 c0                	test   %eax,%eax
801064a7:	79 07                	jns    801064b0 <sys_kill+0x22>
    return -1;
801064a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ae:	eb 0f                	jmp    801064bf <sys_kill+0x31>
  return kill(pid);
801064b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b3:	83 ec 0c             	sub    $0xc,%esp
801064b6:	50                   	push   %eax
801064b7:	e8 f6 e6 ff ff       	call   80104bb2 <kill>
801064bc:	83 c4 10             	add    $0x10,%esp
}
801064bf:	c9                   	leave  
801064c0:	c3                   	ret    

801064c1 <sys_getpid>:

int
sys_getpid(void)
{
801064c1:	55                   	push   %ebp
801064c2:	89 e5                	mov    %esp,%ebp
801064c4:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801064c7:	e8 48 da ff ff       	call   80103f14 <myproc>
801064cc:	8b 40 10             	mov    0x10(%eax),%eax
}
801064cf:	c9                   	leave  
801064d0:	c3                   	ret    

801064d1 <sys_sbrk>:

int
sys_sbrk(void)
{
801064d1:	55                   	push   %ebp
801064d2:	89 e5                	mov    %esp,%ebp
801064d4:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801064d7:	83 ec 08             	sub    $0x8,%esp
801064da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064dd:	50                   	push   %eax
801064de:	6a 00                	push   $0x0
801064e0:	e8 be f0 ff ff       	call   801055a3 <argint>
801064e5:	83 c4 10             	add    $0x10,%esp
801064e8:	85 c0                	test   %eax,%eax
801064ea:	79 07                	jns    801064f3 <sys_sbrk+0x22>
    return -1;
801064ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f1:	eb 27                	jmp    8010651a <sys_sbrk+0x49>
  addr = myproc()->sz;
801064f3:	e8 1c da ff ff       	call   80103f14 <myproc>
801064f8:	8b 00                	mov    (%eax),%eax
801064fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801064fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106500:	83 ec 0c             	sub    $0xc,%esp
80106503:	50                   	push   %eax
80106504:	e8 aa dc ff ff       	call   801041b3 <growproc>
80106509:	83 c4 10             	add    $0x10,%esp
8010650c:	85 c0                	test   %eax,%eax
8010650e:	79 07                	jns    80106517 <sys_sbrk+0x46>
    return -1;
80106510:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106515:	eb 03                	jmp    8010651a <sys_sbrk+0x49>
  return addr;
80106517:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010651a:	c9                   	leave  
8010651b:	c3                   	ret    

8010651c <sys_sleep>:

int
sys_sleep(void)
{
8010651c:	55                   	push   %ebp
8010651d:	89 e5                	mov    %esp,%ebp
8010651f:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106522:	83 ec 08             	sub    $0x8,%esp
80106525:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106528:	50                   	push   %eax
80106529:	6a 00                	push   $0x0
8010652b:	e8 73 f0 ff ff       	call   801055a3 <argint>
80106530:	83 c4 10             	add    $0x10,%esp
80106533:	85 c0                	test   %eax,%eax
80106535:	79 07                	jns    8010653e <sys_sleep+0x22>
    return -1;
80106537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653c:	eb 76                	jmp    801065b4 <sys_sleep+0x98>
  acquire(&tickslock);
8010653e:	83 ec 0c             	sub    $0xc,%esp
80106541:	68 80 a2 11 80       	push   $0x8011a280
80106546:	e8 b7 ea ff ff       	call   80105002 <acquire>
8010654b:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010654e:	a1 b4 a2 11 80       	mov    0x8011a2b4,%eax
80106553:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106556:	eb 38                	jmp    80106590 <sys_sleep+0x74>
    if(myproc()->killed){
80106558:	e8 b7 d9 ff ff       	call   80103f14 <myproc>
8010655d:	8b 40 24             	mov    0x24(%eax),%eax
80106560:	85 c0                	test   %eax,%eax
80106562:	74 17                	je     8010657b <sys_sleep+0x5f>
      release(&tickslock);
80106564:	83 ec 0c             	sub    $0xc,%esp
80106567:	68 80 a2 11 80       	push   $0x8011a280
8010656c:	e8 ff ea ff ff       	call   80105070 <release>
80106571:	83 c4 10             	add    $0x10,%esp
      return -1;
80106574:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106579:	eb 39                	jmp    801065b4 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010657b:	83 ec 08             	sub    $0x8,%esp
8010657e:	68 80 a2 11 80       	push   $0x8011a280
80106583:	68 b4 a2 11 80       	push   $0x8011a2b4
80106588:	e8 04 e5 ff ff       	call   80104a91 <sleep>
8010658d:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106590:	a1 b4 a2 11 80       	mov    0x8011a2b4,%eax
80106595:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106598:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010659b:	39 d0                	cmp    %edx,%eax
8010659d:	72 b9                	jb     80106558 <sys_sleep+0x3c>
  }
  release(&tickslock);
8010659f:	83 ec 0c             	sub    $0xc,%esp
801065a2:	68 80 a2 11 80       	push   $0x8011a280
801065a7:	e8 c4 ea ff ff       	call   80105070 <release>
801065ac:	83 c4 10             	add    $0x10,%esp
  return 0;
801065af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065b4:	c9                   	leave  
801065b5:	c3                   	ret    

801065b6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801065b6:	55                   	push   %ebp
801065b7:	89 e5                	mov    %esp,%ebp
801065b9:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801065bc:	83 ec 0c             	sub    $0xc,%esp
801065bf:	68 80 a2 11 80       	push   $0x8011a280
801065c4:	e8 39 ea ff ff       	call   80105002 <acquire>
801065c9:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801065cc:	a1 b4 a2 11 80       	mov    0x8011a2b4,%eax
801065d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801065d4:	83 ec 0c             	sub    $0xc,%esp
801065d7:	68 80 a2 11 80       	push   $0x8011a280
801065dc:	e8 8f ea ff ff       	call   80105070 <release>
801065e1:	83 c4 10             	add    $0x10,%esp
  return xticks;
801065e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065e7:	c9                   	leave  
801065e8:	c3                   	ret    

801065e9 <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
801065e9:	55                   	push   %ebp
801065ea:	89 e5                	mov    %esp,%ebp
801065ec:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
801065ef:	83 ec 08             	sub    $0x8,%esp
801065f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065f5:	50                   	push   %eax
801065f6:	6a 00                	push   $0x0
801065f8:	e8 a6 ef ff ff       	call   801055a3 <argint>
801065fd:	83 c4 10             	add    $0x10,%esp
80106600:	85 c0                	test   %eax,%eax
80106602:	79 07                	jns    8010660b <sys_setSchedPolicy+0x22>
    return -1;
80106604:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106609:	eb 0f                	jmp    8010661a <sys_setSchedPolicy+0x31>
  return setSchedPolicy(policy);
8010660b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010660e:	83 ec 0c             	sub    $0xc,%esp
80106611:	50                   	push   %eax
80106612:	e8 1f e7 ff ff       	call   80104d36 <setSchedPolicy>
80106617:	83 c4 10             	add    $0x10,%esp
}
8010661a:	c9                   	leave  
8010661b:	c3                   	ret    

8010661c <sys_getpinfo>:



int
sys_getpinfo(void)
{
8010661c:	55                   	push   %ebp
8010661d:	89 e5                	mov    %esp,%ebp
8010661f:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(*ps)) < 0 )
80106622:	83 ec 04             	sub    $0x4,%esp
80106625:	68 00 0c 00 00       	push   $0xc00
8010662a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010662d:	50                   	push   %eax
8010662e:	6a 00                	push   $0x0
80106630:	e8 9b ef ff ff       	call   801055d0 <argptr>
80106635:	83 c4 10             	add    $0x10,%esp
80106638:	85 c0                	test   %eax,%eax
8010663a:	79 07                	jns    80106643 <sys_getpinfo+0x27>
    return -1;
8010663c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106641:	eb 0f                	jmp    80106652 <sys_getpinfo+0x36>
  return getpinfo(ps);
80106643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106646:	83 ec 0c             	sub    $0xc,%esp
80106649:	50                   	push   %eax
8010664a:	e8 25 e7 ff ff       	call   80104d74 <getpinfo>
8010664f:	83 c4 10             	add    $0x10,%esp
}
80106652:	c9                   	leave  
80106653:	c3                   	ret    

80106654 <sys_yield>:

int
sys_yield(void)
{
80106654:	55                   	push   %ebp
80106655:	89 e5                	mov    %esp,%ebp
80106657:	83 ec 08             	sub    $0x8,%esp
  yield();
8010665a:	e8 b2 e3 ff ff       	call   80104a11 <yield>
  return 0;
8010665f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106664:	c9                   	leave  
80106665:	c3                   	ret    

80106666 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106666:	1e                   	push   %ds
  pushl %es
80106667:	06                   	push   %es
  pushl %fs
80106668:	0f a0                	push   %fs
  pushl %gs
8010666a:	0f a8                	push   %gs
  pushal
8010666c:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010666d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106671:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106673:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106675:	54                   	push   %esp
  call trap
80106676:	e8 d7 01 00 00       	call   80106852 <trap>
  addl $4, %esp
8010667b:	83 c4 04             	add    $0x4,%esp

8010667e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010667e:	61                   	popa   
  popl %gs
8010667f:	0f a9                	pop    %gs
  popl %fs
80106681:	0f a1                	pop    %fs
  popl %es
80106683:	07                   	pop    %es
  popl %ds
80106684:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106685:	83 c4 08             	add    $0x8,%esp
  iret
80106688:	cf                   	iret   

80106689 <lidt>:
{
80106689:	55                   	push   %ebp
8010668a:	89 e5                	mov    %esp,%ebp
8010668c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010668f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106692:	83 e8 01             	sub    $0x1,%eax
80106695:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106699:	8b 45 08             	mov    0x8(%ebp),%eax
8010669c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801066a0:	8b 45 08             	mov    0x8(%ebp),%eax
801066a3:	c1 e8 10             	shr    $0x10,%eax
801066a6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801066aa:	8d 45 fa             	lea    -0x6(%ebp),%eax
801066ad:	0f 01 18             	lidtl  (%eax)
}
801066b0:	90                   	nop
801066b1:	c9                   	leave  
801066b2:	c3                   	ret    

801066b3 <rcr2>:

static inline uint
rcr2(void)
{
801066b3:	55                   	push   %ebp
801066b4:	89 e5                	mov    %esp,%ebp
801066b6:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066b9:	0f 20 d0             	mov    %cr2,%eax
801066bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066c2:	c9                   	leave  
801066c3:	c3                   	ret    

801066c4 <tvinit>:
  struct proc proc[NPROC];
} ptable;

void
tvinit(void)
{
801066c4:	55                   	push   %ebp
801066c5:	89 e5                	mov    %esp,%ebp
801066c7:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801066ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066d1:	e9 c3 00 00 00       	jmp    80106799 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d9:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801066e0:	89 c2                	mov    %eax,%edx
801066e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e5:	66 89 14 c5 80 9a 11 	mov    %dx,-0x7fee6580(,%eax,8)
801066ec:	80 
801066ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f0:	66 c7 04 c5 82 9a 11 	movw   $0x8,-0x7fee657e(,%eax,8)
801066f7:	80 08 00 
801066fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fd:	0f b6 14 c5 84 9a 11 	movzbl -0x7fee657c(,%eax,8),%edx
80106704:	80 
80106705:	83 e2 e0             	and    $0xffffffe0,%edx
80106708:	88 14 c5 84 9a 11 80 	mov    %dl,-0x7fee657c(,%eax,8)
8010670f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106712:	0f b6 14 c5 84 9a 11 	movzbl -0x7fee657c(,%eax,8),%edx
80106719:	80 
8010671a:	83 e2 1f             	and    $0x1f,%edx
8010671d:	88 14 c5 84 9a 11 80 	mov    %dl,-0x7fee657c(,%eax,8)
80106724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106727:	0f b6 14 c5 85 9a 11 	movzbl -0x7fee657b(,%eax,8),%edx
8010672e:	80 
8010672f:	83 e2 f0             	and    $0xfffffff0,%edx
80106732:	83 ca 0e             	or     $0xe,%edx
80106735:	88 14 c5 85 9a 11 80 	mov    %dl,-0x7fee657b(,%eax,8)
8010673c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673f:	0f b6 14 c5 85 9a 11 	movzbl -0x7fee657b(,%eax,8),%edx
80106746:	80 
80106747:	83 e2 ef             	and    $0xffffffef,%edx
8010674a:	88 14 c5 85 9a 11 80 	mov    %dl,-0x7fee657b(,%eax,8)
80106751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106754:	0f b6 14 c5 85 9a 11 	movzbl -0x7fee657b(,%eax,8),%edx
8010675b:	80 
8010675c:	83 e2 9f             	and    $0xffffff9f,%edx
8010675f:	88 14 c5 85 9a 11 80 	mov    %dl,-0x7fee657b(,%eax,8)
80106766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106769:	0f b6 14 c5 85 9a 11 	movzbl -0x7fee657b(,%eax,8),%edx
80106770:	80 
80106771:	83 ca 80             	or     $0xffffff80,%edx
80106774:	88 14 c5 85 9a 11 80 	mov    %dl,-0x7fee657b(,%eax,8)
8010677b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677e:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106785:	c1 e8 10             	shr    $0x10,%eax
80106788:	89 c2                	mov    %eax,%edx
8010678a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678d:	66 89 14 c5 86 9a 11 	mov    %dx,-0x7fee657a(,%eax,8)
80106794:	80 
  for(i = 0; i < 256; i++)
80106795:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106799:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801067a0:	0f 8e 30 ff ff ff    	jle    801066d6 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067a6:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801067ab:	66 a3 80 9c 11 80    	mov    %ax,0x80119c80
801067b1:	66 c7 05 82 9c 11 80 	movw   $0x8,0x80119c82
801067b8:	08 00 
801067ba:	0f b6 05 84 9c 11 80 	movzbl 0x80119c84,%eax
801067c1:	83 e0 e0             	and    $0xffffffe0,%eax
801067c4:	a2 84 9c 11 80       	mov    %al,0x80119c84
801067c9:	0f b6 05 84 9c 11 80 	movzbl 0x80119c84,%eax
801067d0:	83 e0 1f             	and    $0x1f,%eax
801067d3:	a2 84 9c 11 80       	mov    %al,0x80119c84
801067d8:	0f b6 05 85 9c 11 80 	movzbl 0x80119c85,%eax
801067df:	83 c8 0f             	or     $0xf,%eax
801067e2:	a2 85 9c 11 80       	mov    %al,0x80119c85
801067e7:	0f b6 05 85 9c 11 80 	movzbl 0x80119c85,%eax
801067ee:	83 e0 ef             	and    $0xffffffef,%eax
801067f1:	a2 85 9c 11 80       	mov    %al,0x80119c85
801067f6:	0f b6 05 85 9c 11 80 	movzbl 0x80119c85,%eax
801067fd:	83 c8 60             	or     $0x60,%eax
80106800:	a2 85 9c 11 80       	mov    %al,0x80119c85
80106805:	0f b6 05 85 9c 11 80 	movzbl 0x80119c85,%eax
8010680c:	83 c8 80             	or     $0xffffff80,%eax
8010680f:	a2 85 9c 11 80       	mov    %al,0x80119c85
80106814:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106819:	c1 e8 10             	shr    $0x10,%eax
8010681c:	66 a3 86 9c 11 80    	mov    %ax,0x80119c86

  initlock(&tickslock, "time");
80106822:	83 ec 08             	sub    $0x8,%esp
80106825:	68 7c ad 10 80       	push   $0x8010ad7c
8010682a:	68 80 a2 11 80       	push   $0x8011a280
8010682f:	e8 ac e7 ff ff       	call   80104fe0 <initlock>
80106834:	83 c4 10             	add    $0x10,%esp
}
80106837:	90                   	nop
80106838:	c9                   	leave  
80106839:	c3                   	ret    

8010683a <idtinit>:

void
idtinit(void)
{
8010683a:	55                   	push   %ebp
8010683b:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010683d:	68 00 08 00 00       	push   $0x800
80106842:	68 80 9a 11 80       	push   $0x80119a80
80106847:	e8 3d fe ff ff       	call   80106689 <lidt>
8010684c:	83 c4 08             	add    $0x8,%esp
}
8010684f:	90                   	nop
80106850:	c9                   	leave  
80106851:	c3                   	ret    

80106852 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106852:	55                   	push   %ebp
80106853:	89 e5                	mov    %esp,%ebp
80106855:	57                   	push   %edi
80106856:	56                   	push   %esi
80106857:	53                   	push   %ebx
80106858:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
8010685b:	8b 45 08             	mov    0x8(%ebp),%eax
8010685e:	8b 40 30             	mov    0x30(%eax),%eax
80106861:	83 f8 40             	cmp    $0x40,%eax
80106864:	75 3b                	jne    801068a1 <trap+0x4f>
    if(myproc()->killed)
80106866:	e8 a9 d6 ff ff       	call   80103f14 <myproc>
8010686b:	8b 40 24             	mov    0x24(%eax),%eax
8010686e:	85 c0                	test   %eax,%eax
80106870:	74 05                	je     80106877 <trap+0x25>
      exit();
80106872:	e8 50 db ff ff       	call   801043c7 <exit>
    myproc()->tf = tf;
80106877:	e8 98 d6 ff ff       	call   80103f14 <myproc>
8010687c:	8b 55 08             	mov    0x8(%ebp),%edx
8010687f:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106882:	e8 e8 ed ff ff       	call   8010566f <syscall>
    if(myproc()->killed)
80106887:	e8 88 d6 ff ff       	call   80103f14 <myproc>
8010688c:	8b 40 24             	mov    0x24(%eax),%eax
8010688f:	85 c0                	test   %eax,%eax
80106891:	0f 84 cf 02 00 00    	je     80106b66 <trap+0x314>
      exit();
80106897:	e8 2b db ff ff       	call   801043c7 <exit>
    return;
8010689c:	e9 c5 02 00 00       	jmp    80106b66 <trap+0x314>
  }

  switch(tf->trapno){
801068a1:	8b 45 08             	mov    0x8(%ebp),%eax
801068a4:	8b 40 30             	mov    0x30(%eax),%eax
801068a7:	83 e8 20             	sub    $0x20,%eax
801068aa:	83 f8 1f             	cmp    $0x1f,%eax
801068ad:	0f 87 7e 01 00 00    	ja     80106a31 <trap+0x1df>
801068b3:	8b 04 85 24 ae 10 80 	mov    -0x7fef51dc(,%eax,4),%eax
801068ba:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801068bc:	e8 c0 d5 ff ff       	call   80103e81 <cpuid>
801068c1:	85 c0                	test   %eax,%eax
801068c3:	75 3d                	jne    80106902 <trap+0xb0>
      acquire(&tickslock);
801068c5:	83 ec 0c             	sub    $0xc,%esp
801068c8:	68 80 a2 11 80       	push   $0x8011a280
801068cd:	e8 30 e7 ff ff       	call   80105002 <acquire>
801068d2:	83 c4 10             	add    $0x10,%esp
      ticks++;
801068d5:	a1 b4 a2 11 80       	mov    0x8011a2b4,%eax
801068da:	83 c0 01             	add    $0x1,%eax
801068dd:	a3 b4 a2 11 80       	mov    %eax,0x8011a2b4
      wakeup(&ticks);
801068e2:	83 ec 0c             	sub    $0xc,%esp
801068e5:	68 b4 a2 11 80       	push   $0x8011a2b4
801068ea:	e8 8c e2 ff ff       	call   80104b7b <wakeup>
801068ef:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801068f2:	83 ec 0c             	sub    $0xc,%esp
801068f5:	68 80 a2 11 80       	push   $0x8011a280
801068fa:	e8 71 e7 ff ff       	call   80105070 <release>
801068ff:	83 c4 10             	add    $0x10,%esp
    }
    //추가
    struct proc *curproc = myproc();
80106902:	e8 0d d6 ff ff       	call   80103f14 <myproc>
80106907:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (curproc && curproc->state == RUNNING) {
8010690a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010690e:	74 2f                	je     8010693f <trap+0xed>
80106910:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106913:	8b 40 0c             	mov    0xc(%eax),%eax
80106916:	83 f8 04             	cmp    $0x4,%eax
80106919:	75 24                	jne    8010693f <trap+0xed>
      int q = curproc->priority;
8010691b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010691e:	8b 40 7c             	mov    0x7c(%eax),%eax
80106921:	89 45 dc             	mov    %eax,-0x24(%ebp)
      curproc->ticks[q]++;
80106924:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106927:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010692a:	83 c2 20             	add    $0x20,%edx
8010692d:	8b 04 90             	mov    (%eax,%edx,4),%eax
80106930:	8d 48 01             	lea    0x1(%eax),%ecx
80106933:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106936:	8b 55 dc             	mov    -0x24(%ebp),%edx
80106939:	83 c2 20             	add    $0x20,%edx
8010693c:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    }
    // RUNNABLE 상태이면서 현재 실행 중이 아닌 애들: wait_ticks 증가
    acquire(&ptable.lock);
8010693f:	83 ec 0c             	sub    $0xc,%esp
80106942:	68 40 72 11 80       	push   $0x80117240
80106947:	e8 b6 e6 ff ff       	call   80105002 <acquire>
8010694c:	83 c4 10             	add    $0x10,%esp
    struct proc *p;
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010694f:	c7 45 e4 74 72 11 80 	movl   $0x80117274,-0x1c(%ebp)
80106956:	eb 35                	jmp    8010698d <trap+0x13b>
      if (p != curproc && p->state == RUNNABLE ) {
80106958:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010695b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
8010695e:	74 26                	je     80106986 <trap+0x134>
80106960:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106963:	8b 40 0c             	mov    0xc(%eax),%eax
80106966:	83 f8 03             	cmp    $0x3,%eax
80106969:	75 1b                	jne    80106986 <trap+0x134>
        p->wait_ticks[p->priority]++;
8010696b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010696e:	8b 40 7c             	mov    0x7c(%eax),%eax
80106971:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106974:	8d 48 24             	lea    0x24(%eax),%ecx
80106977:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
8010697a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010697d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106980:	83 c0 24             	add    $0x24,%eax
80106983:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106986:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
8010698d:	81 7d e4 74 9a 11 80 	cmpl   $0x80119a74,-0x1c(%ebp)
80106994:	72 c2                	jb     80106958 <trap+0x106>
      }
    }
    release(&ptable.lock);
80106996:	83 ec 0c             	sub    $0xc,%esp
80106999:	68 40 72 11 80       	push   $0x80117240
8010699e:	e8 cd e6 ff ff       	call   80105070 <release>
801069a3:	83 c4 10             	add    $0x10,%esp
    if (curproc && curproc->state == RUNNING){
801069a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801069aa:	74 10                	je     801069bc <trap+0x16a>
801069ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069af:	8b 40 0c             	mov    0xc(%eax),%eax
801069b2:	83 f8 04             	cmp    $0x4,%eax
801069b5:	75 05                	jne    801069bc <trap+0x16a>
    yield();  // CPU 양보
801069b7:	e8 55 e0 ff ff       	call   80104a11 <yield>
    }

    lapiceoi();
801069bc:	e8 3f c6 ff ff       	call   80103000 <lapiceoi>
    break;
801069c1:	e9 20 01 00 00       	jmp    80106ae6 <trap+0x294>

  case T_IRQ0 + IRQ_IDE:
    ideintr();
801069c6:	e8 8b be ff ff       	call   80102856 <ideintr>
    lapiceoi();
801069cb:	e8 30 c6 ff ff       	call   80103000 <lapiceoi>
    break;
801069d0:	e9 11 01 00 00       	jmp    80106ae6 <trap+0x294>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801069d5:	e8 6b c4 ff ff       	call   80102e45 <kbdintr>
    lapiceoi();
801069da:	e8 21 c6 ff ff       	call   80103000 <lapiceoi>
    break;
801069df:	e9 02 01 00 00       	jmp    80106ae6 <trap+0x294>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801069e4:	e8 53 03 00 00       	call   80106d3c <uartintr>
    lapiceoi();
801069e9:	e8 12 c6 ff ff       	call   80103000 <lapiceoi>
    break;
801069ee:	e9 f3 00 00 00       	jmp    80106ae6 <trap+0x294>
  case T_IRQ0 + 0xB:
    i8254_intr();
801069f3:	e8 7b 2b 00 00       	call   80109573 <i8254_intr>
    lapiceoi();
801069f8:	e8 03 c6 ff ff       	call   80103000 <lapiceoi>
    break;
801069fd:	e9 e4 00 00 00       	jmp    80106ae6 <trap+0x294>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a02:	8b 45 08             	mov    0x8(%ebp),%eax
80106a05:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106a08:	8b 45 08             	mov    0x8(%ebp),%eax
80106a0b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a0f:	0f b7 d8             	movzwl %ax,%ebx
80106a12:	e8 6a d4 ff ff       	call   80103e81 <cpuid>
80106a17:	56                   	push   %esi
80106a18:	53                   	push   %ebx
80106a19:	50                   	push   %eax
80106a1a:	68 84 ad 10 80       	push   $0x8010ad84
80106a1f:	e8 d0 99 ff ff       	call   801003f4 <cprintf>
80106a24:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106a27:	e8 d4 c5 ff ff       	call   80103000 <lapiceoi>
    break;
80106a2c:	e9 b5 00 00 00       	jmp    80106ae6 <trap+0x294>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106a31:	e8 de d4 ff ff       	call   80103f14 <myproc>
80106a36:	85 c0                	test   %eax,%eax
80106a38:	74 11                	je     80106a4b <trap+0x1f9>
80106a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80106a3d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a41:	0f b7 c0             	movzwl %ax,%eax
80106a44:	83 e0 03             	and    $0x3,%eax
80106a47:	85 c0                	test   %eax,%eax
80106a49:	75 39                	jne    80106a84 <trap+0x232>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a4b:	e8 63 fc ff ff       	call   801066b3 <rcr2>
80106a50:	89 c3                	mov    %eax,%ebx
80106a52:	8b 45 08             	mov    0x8(%ebp),%eax
80106a55:	8b 70 38             	mov    0x38(%eax),%esi
80106a58:	e8 24 d4 ff ff       	call   80103e81 <cpuid>
80106a5d:	8b 55 08             	mov    0x8(%ebp),%edx
80106a60:	8b 52 30             	mov    0x30(%edx),%edx
80106a63:	83 ec 0c             	sub    $0xc,%esp
80106a66:	53                   	push   %ebx
80106a67:	56                   	push   %esi
80106a68:	50                   	push   %eax
80106a69:	52                   	push   %edx
80106a6a:	68 a8 ad 10 80       	push   $0x8010ada8
80106a6f:	e8 80 99 ff ff       	call   801003f4 <cprintf>
80106a74:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106a77:	83 ec 0c             	sub    $0xc,%esp
80106a7a:	68 da ad 10 80       	push   $0x8010adda
80106a7f:	e8 25 9b ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a84:	e8 2a fc ff ff       	call   801066b3 <rcr2>
80106a89:	89 c6                	mov    %eax,%esi
80106a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a8e:	8b 40 38             	mov    0x38(%eax),%eax
80106a91:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106a94:	e8 e8 d3 ff ff       	call   80103e81 <cpuid>
80106a99:	89 c3                	mov    %eax,%ebx
80106a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9e:	8b 78 34             	mov    0x34(%eax),%edi
80106aa1:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa7:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106aaa:	e8 65 d4 ff ff       	call   80103f14 <myproc>
80106aaf:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106ab2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
80106ab5:	e8 5a d4 ff ff       	call   80103f14 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106aba:	8b 40 10             	mov    0x10(%eax),%eax
80106abd:	56                   	push   %esi
80106abe:	ff 75 d4             	push   -0x2c(%ebp)
80106ac1:	53                   	push   %ebx
80106ac2:	ff 75 d0             	push   -0x30(%ebp)
80106ac5:	57                   	push   %edi
80106ac6:	ff 75 cc             	push   -0x34(%ebp)
80106ac9:	50                   	push   %eax
80106aca:	68 e0 ad 10 80       	push   $0x8010ade0
80106acf:	e8 20 99 ff ff       	call   801003f4 <cprintf>
80106ad4:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ad7:	e8 38 d4 ff ff       	call   80103f14 <myproc>
80106adc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ae3:	eb 01                	jmp    80106ae6 <trap+0x294>
    break;
80106ae5:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ae6:	e8 29 d4 ff ff       	call   80103f14 <myproc>
80106aeb:	85 c0                	test   %eax,%eax
80106aed:	74 23                	je     80106b12 <trap+0x2c0>
80106aef:	e8 20 d4 ff ff       	call   80103f14 <myproc>
80106af4:	8b 40 24             	mov    0x24(%eax),%eax
80106af7:	85 c0                	test   %eax,%eax
80106af9:	74 17                	je     80106b12 <trap+0x2c0>
80106afb:	8b 45 08             	mov    0x8(%ebp),%eax
80106afe:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b02:	0f b7 c0             	movzwl %ax,%eax
80106b05:	83 e0 03             	and    $0x3,%eax
80106b08:	83 f8 03             	cmp    $0x3,%eax
80106b0b:	75 05                	jne    80106b12 <trap+0x2c0>
    exit();
80106b0d:	e8 b5 d8 ff ff       	call   801043c7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
80106b12:	e8 fd d3 ff ff       	call   80103f14 <myproc>
80106b17:	85 c0                	test   %eax,%eax
80106b19:	74 1d                	je     80106b38 <trap+0x2e6>
80106b1b:	e8 f4 d3 ff ff       	call   80103f14 <myproc>
80106b20:	8b 40 0c             	mov    0xc(%eax),%eax
80106b23:	83 f8 04             	cmp    $0x4,%eax
80106b26:	75 10                	jne    80106b38 <trap+0x2e6>
80106b28:	8b 45 08             	mov    0x8(%ebp),%eax
80106b2b:	8b 40 30             	mov    0x30(%eax),%eax
80106b2e:	83 f8 20             	cmp    $0x20,%eax
80106b31:	75 05                	jne    80106b38 <trap+0x2e6>
      yield();
80106b33:	e8 d9 de ff ff       	call   80104a11 <yield>
  }

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b38:	e8 d7 d3 ff ff       	call   80103f14 <myproc>
80106b3d:	85 c0                	test   %eax,%eax
80106b3f:	74 26                	je     80106b67 <trap+0x315>
80106b41:	e8 ce d3 ff ff       	call   80103f14 <myproc>
80106b46:	8b 40 24             	mov    0x24(%eax),%eax
80106b49:	85 c0                	test   %eax,%eax
80106b4b:	74 1a                	je     80106b67 <trap+0x315>
80106b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b50:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b54:	0f b7 c0             	movzwl %ax,%eax
80106b57:	83 e0 03             	and    $0x3,%eax
80106b5a:	83 f8 03             	cmp    $0x3,%eax
80106b5d:	75 08                	jne    80106b67 <trap+0x315>
    exit();
80106b5f:	e8 63 d8 ff ff       	call   801043c7 <exit>
80106b64:	eb 01                	jmp    80106b67 <trap+0x315>
    return;
80106b66:	90                   	nop
80106b67:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b6a:	5b                   	pop    %ebx
80106b6b:	5e                   	pop    %esi
80106b6c:	5f                   	pop    %edi
80106b6d:	5d                   	pop    %ebp
80106b6e:	c3                   	ret    

80106b6f <inb>:
{
80106b6f:	55                   	push   %ebp
80106b70:	89 e5                	mov    %esp,%ebp
80106b72:	83 ec 14             	sub    $0x14,%esp
80106b75:	8b 45 08             	mov    0x8(%ebp),%eax
80106b78:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b7c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b80:	89 c2                	mov    %eax,%edx
80106b82:	ec                   	in     (%dx),%al
80106b83:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b86:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b8a:	c9                   	leave  
80106b8b:	c3                   	ret    

80106b8c <outb>:
{
80106b8c:	55                   	push   %ebp
80106b8d:	89 e5                	mov    %esp,%ebp
80106b8f:	83 ec 08             	sub    $0x8,%esp
80106b92:	8b 45 08             	mov    0x8(%ebp),%eax
80106b95:	8b 55 0c             	mov    0xc(%ebp),%edx
80106b98:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106b9c:	89 d0                	mov    %edx,%eax
80106b9e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ba1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ba5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ba9:	ee                   	out    %al,(%dx)
}
80106baa:	90                   	nop
80106bab:	c9                   	leave  
80106bac:	c3                   	ret    

80106bad <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106bad:	55                   	push   %ebp
80106bae:	89 e5                	mov    %esp,%ebp
80106bb0:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106bb3:	6a 00                	push   $0x0
80106bb5:	68 fa 03 00 00       	push   $0x3fa
80106bba:	e8 cd ff ff ff       	call   80106b8c <outb>
80106bbf:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106bc2:	68 80 00 00 00       	push   $0x80
80106bc7:	68 fb 03 00 00       	push   $0x3fb
80106bcc:	e8 bb ff ff ff       	call   80106b8c <outb>
80106bd1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106bd4:	6a 0c                	push   $0xc
80106bd6:	68 f8 03 00 00       	push   $0x3f8
80106bdb:	e8 ac ff ff ff       	call   80106b8c <outb>
80106be0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106be3:	6a 00                	push   $0x0
80106be5:	68 f9 03 00 00       	push   $0x3f9
80106bea:	e8 9d ff ff ff       	call   80106b8c <outb>
80106bef:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106bf2:	6a 03                	push   $0x3
80106bf4:	68 fb 03 00 00       	push   $0x3fb
80106bf9:	e8 8e ff ff ff       	call   80106b8c <outb>
80106bfe:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106c01:	6a 00                	push   $0x0
80106c03:	68 fc 03 00 00       	push   $0x3fc
80106c08:	e8 7f ff ff ff       	call   80106b8c <outb>
80106c0d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c10:	6a 01                	push   $0x1
80106c12:	68 f9 03 00 00       	push   $0x3f9
80106c17:	e8 70 ff ff ff       	call   80106b8c <outb>
80106c1c:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c1f:	68 fd 03 00 00       	push   $0x3fd
80106c24:	e8 46 ff ff ff       	call   80106b6f <inb>
80106c29:	83 c4 04             	add    $0x4,%esp
80106c2c:	3c ff                	cmp    $0xff,%al
80106c2e:	74 61                	je     80106c91 <uartinit+0xe4>
    return;
  uart = 1;
80106c30:	c7 05 b8 a2 11 80 01 	movl   $0x1,0x8011a2b8
80106c37:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c3a:	68 fa 03 00 00       	push   $0x3fa
80106c3f:	e8 2b ff ff ff       	call   80106b6f <inb>
80106c44:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106c47:	68 f8 03 00 00       	push   $0x3f8
80106c4c:	e8 1e ff ff ff       	call   80106b6f <inb>
80106c51:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106c54:	83 ec 08             	sub    $0x8,%esp
80106c57:	6a 00                	push   $0x0
80106c59:	6a 04                	push   $0x4
80106c5b:	e8 b2 be ff ff       	call   80102b12 <ioapicenable>
80106c60:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c63:	c7 45 f4 a4 ae 10 80 	movl   $0x8010aea4,-0xc(%ebp)
80106c6a:	eb 19                	jmp    80106c85 <uartinit+0xd8>
    uartputc(*p);
80106c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c6f:	0f b6 00             	movzbl (%eax),%eax
80106c72:	0f be c0             	movsbl %al,%eax
80106c75:	83 ec 0c             	sub    $0xc,%esp
80106c78:	50                   	push   %eax
80106c79:	e8 16 00 00 00       	call   80106c94 <uartputc>
80106c7e:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106c81:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c88:	0f b6 00             	movzbl (%eax),%eax
80106c8b:	84 c0                	test   %al,%al
80106c8d:	75 dd                	jne    80106c6c <uartinit+0xbf>
80106c8f:	eb 01                	jmp    80106c92 <uartinit+0xe5>
    return;
80106c91:	90                   	nop
}
80106c92:	c9                   	leave  
80106c93:	c3                   	ret    

80106c94 <uartputc>:

void
uartputc(int c)
{
80106c94:	55                   	push   %ebp
80106c95:	89 e5                	mov    %esp,%ebp
80106c97:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c9a:	a1 b8 a2 11 80       	mov    0x8011a2b8,%eax
80106c9f:	85 c0                	test   %eax,%eax
80106ca1:	74 53                	je     80106cf6 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ca3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106caa:	eb 11                	jmp    80106cbd <uartputc+0x29>
    microdelay(10);
80106cac:	83 ec 0c             	sub    $0xc,%esp
80106caf:	6a 0a                	push   $0xa
80106cb1:	e8 65 c3 ff ff       	call   8010301b <microdelay>
80106cb6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cb9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cbd:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106cc1:	7f 1a                	jg     80106cdd <uartputc+0x49>
80106cc3:	83 ec 0c             	sub    $0xc,%esp
80106cc6:	68 fd 03 00 00       	push   $0x3fd
80106ccb:	e8 9f fe ff ff       	call   80106b6f <inb>
80106cd0:	83 c4 10             	add    $0x10,%esp
80106cd3:	0f b6 c0             	movzbl %al,%eax
80106cd6:	83 e0 20             	and    $0x20,%eax
80106cd9:	85 c0                	test   %eax,%eax
80106cdb:	74 cf                	je     80106cac <uartputc+0x18>
  outb(COM1+0, c);
80106cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce0:	0f b6 c0             	movzbl %al,%eax
80106ce3:	83 ec 08             	sub    $0x8,%esp
80106ce6:	50                   	push   %eax
80106ce7:	68 f8 03 00 00       	push   $0x3f8
80106cec:	e8 9b fe ff ff       	call   80106b8c <outb>
80106cf1:	83 c4 10             	add    $0x10,%esp
80106cf4:	eb 01                	jmp    80106cf7 <uartputc+0x63>
    return;
80106cf6:	90                   	nop
}
80106cf7:	c9                   	leave  
80106cf8:	c3                   	ret    

80106cf9 <uartgetc>:

static int
uartgetc(void)
{
80106cf9:	55                   	push   %ebp
80106cfa:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106cfc:	a1 b8 a2 11 80       	mov    0x8011a2b8,%eax
80106d01:	85 c0                	test   %eax,%eax
80106d03:	75 07                	jne    80106d0c <uartgetc+0x13>
    return -1;
80106d05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d0a:	eb 2e                	jmp    80106d3a <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106d0c:	68 fd 03 00 00       	push   $0x3fd
80106d11:	e8 59 fe ff ff       	call   80106b6f <inb>
80106d16:	83 c4 04             	add    $0x4,%esp
80106d19:	0f b6 c0             	movzbl %al,%eax
80106d1c:	83 e0 01             	and    $0x1,%eax
80106d1f:	85 c0                	test   %eax,%eax
80106d21:	75 07                	jne    80106d2a <uartgetc+0x31>
    return -1;
80106d23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d28:	eb 10                	jmp    80106d3a <uartgetc+0x41>
  return inb(COM1+0);
80106d2a:	68 f8 03 00 00       	push   $0x3f8
80106d2f:	e8 3b fe ff ff       	call   80106b6f <inb>
80106d34:	83 c4 04             	add    $0x4,%esp
80106d37:	0f b6 c0             	movzbl %al,%eax
}
80106d3a:	c9                   	leave  
80106d3b:	c3                   	ret    

80106d3c <uartintr>:

void
uartintr(void)
{
80106d3c:	55                   	push   %ebp
80106d3d:	89 e5                	mov    %esp,%ebp
80106d3f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106d42:	83 ec 0c             	sub    $0xc,%esp
80106d45:	68 f9 6c 10 80       	push   $0x80106cf9
80106d4a:	e8 87 9a ff ff       	call   801007d6 <consoleintr>
80106d4f:	83 c4 10             	add    $0x10,%esp
}
80106d52:	90                   	nop
80106d53:	c9                   	leave  
80106d54:	c3                   	ret    

80106d55 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d55:	6a 00                	push   $0x0
  pushl $0
80106d57:	6a 00                	push   $0x0
  jmp alltraps
80106d59:	e9 08 f9 ff ff       	jmp    80106666 <alltraps>

80106d5e <vector1>:
.globl vector1
vector1:
  pushl $0
80106d5e:	6a 00                	push   $0x0
  pushl $1
80106d60:	6a 01                	push   $0x1
  jmp alltraps
80106d62:	e9 ff f8 ff ff       	jmp    80106666 <alltraps>

80106d67 <vector2>:
.globl vector2
vector2:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $2
80106d69:	6a 02                	push   $0x2
  jmp alltraps
80106d6b:	e9 f6 f8 ff ff       	jmp    80106666 <alltraps>

80106d70 <vector3>:
.globl vector3
vector3:
  pushl $0
80106d70:	6a 00                	push   $0x0
  pushl $3
80106d72:	6a 03                	push   $0x3
  jmp alltraps
80106d74:	e9 ed f8 ff ff       	jmp    80106666 <alltraps>

80106d79 <vector4>:
.globl vector4
vector4:
  pushl $0
80106d79:	6a 00                	push   $0x0
  pushl $4
80106d7b:	6a 04                	push   $0x4
  jmp alltraps
80106d7d:	e9 e4 f8 ff ff       	jmp    80106666 <alltraps>

80106d82 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $5
80106d84:	6a 05                	push   $0x5
  jmp alltraps
80106d86:	e9 db f8 ff ff       	jmp    80106666 <alltraps>

80106d8b <vector6>:
.globl vector6
vector6:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $6
80106d8d:	6a 06                	push   $0x6
  jmp alltraps
80106d8f:	e9 d2 f8 ff ff       	jmp    80106666 <alltraps>

80106d94 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d94:	6a 00                	push   $0x0
  pushl $7
80106d96:	6a 07                	push   $0x7
  jmp alltraps
80106d98:	e9 c9 f8 ff ff       	jmp    80106666 <alltraps>

80106d9d <vector8>:
.globl vector8
vector8:
  pushl $8
80106d9d:	6a 08                	push   $0x8
  jmp alltraps
80106d9f:	e9 c2 f8 ff ff       	jmp    80106666 <alltraps>

80106da4 <vector9>:
.globl vector9
vector9:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $9
80106da6:	6a 09                	push   $0x9
  jmp alltraps
80106da8:	e9 b9 f8 ff ff       	jmp    80106666 <alltraps>

80106dad <vector10>:
.globl vector10
vector10:
  pushl $10
80106dad:	6a 0a                	push   $0xa
  jmp alltraps
80106daf:	e9 b2 f8 ff ff       	jmp    80106666 <alltraps>

80106db4 <vector11>:
.globl vector11
vector11:
  pushl $11
80106db4:	6a 0b                	push   $0xb
  jmp alltraps
80106db6:	e9 ab f8 ff ff       	jmp    80106666 <alltraps>

80106dbb <vector12>:
.globl vector12
vector12:
  pushl $12
80106dbb:	6a 0c                	push   $0xc
  jmp alltraps
80106dbd:	e9 a4 f8 ff ff       	jmp    80106666 <alltraps>

80106dc2 <vector13>:
.globl vector13
vector13:
  pushl $13
80106dc2:	6a 0d                	push   $0xd
  jmp alltraps
80106dc4:	e9 9d f8 ff ff       	jmp    80106666 <alltraps>

80106dc9 <vector14>:
.globl vector14
vector14:
  pushl $14
80106dc9:	6a 0e                	push   $0xe
  jmp alltraps
80106dcb:	e9 96 f8 ff ff       	jmp    80106666 <alltraps>

80106dd0 <vector15>:
.globl vector15
vector15:
  pushl $0
80106dd0:	6a 00                	push   $0x0
  pushl $15
80106dd2:	6a 0f                	push   $0xf
  jmp alltraps
80106dd4:	e9 8d f8 ff ff       	jmp    80106666 <alltraps>

80106dd9 <vector16>:
.globl vector16
vector16:
  pushl $0
80106dd9:	6a 00                	push   $0x0
  pushl $16
80106ddb:	6a 10                	push   $0x10
  jmp alltraps
80106ddd:	e9 84 f8 ff ff       	jmp    80106666 <alltraps>

80106de2 <vector17>:
.globl vector17
vector17:
  pushl $17
80106de2:	6a 11                	push   $0x11
  jmp alltraps
80106de4:	e9 7d f8 ff ff       	jmp    80106666 <alltraps>

80106de9 <vector18>:
.globl vector18
vector18:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $18
80106deb:	6a 12                	push   $0x12
  jmp alltraps
80106ded:	e9 74 f8 ff ff       	jmp    80106666 <alltraps>

80106df2 <vector19>:
.globl vector19
vector19:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $19
80106df4:	6a 13                	push   $0x13
  jmp alltraps
80106df6:	e9 6b f8 ff ff       	jmp    80106666 <alltraps>

80106dfb <vector20>:
.globl vector20
vector20:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $20
80106dfd:	6a 14                	push   $0x14
  jmp alltraps
80106dff:	e9 62 f8 ff ff       	jmp    80106666 <alltraps>

80106e04 <vector21>:
.globl vector21
vector21:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $21
80106e06:	6a 15                	push   $0x15
  jmp alltraps
80106e08:	e9 59 f8 ff ff       	jmp    80106666 <alltraps>

80106e0d <vector22>:
.globl vector22
vector22:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $22
80106e0f:	6a 16                	push   $0x16
  jmp alltraps
80106e11:	e9 50 f8 ff ff       	jmp    80106666 <alltraps>

80106e16 <vector23>:
.globl vector23
vector23:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $23
80106e18:	6a 17                	push   $0x17
  jmp alltraps
80106e1a:	e9 47 f8 ff ff       	jmp    80106666 <alltraps>

80106e1f <vector24>:
.globl vector24
vector24:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $24
80106e21:	6a 18                	push   $0x18
  jmp alltraps
80106e23:	e9 3e f8 ff ff       	jmp    80106666 <alltraps>

80106e28 <vector25>:
.globl vector25
vector25:
  pushl $0
80106e28:	6a 00                	push   $0x0
  pushl $25
80106e2a:	6a 19                	push   $0x19
  jmp alltraps
80106e2c:	e9 35 f8 ff ff       	jmp    80106666 <alltraps>

80106e31 <vector26>:
.globl vector26
vector26:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $26
80106e33:	6a 1a                	push   $0x1a
  jmp alltraps
80106e35:	e9 2c f8 ff ff       	jmp    80106666 <alltraps>

80106e3a <vector27>:
.globl vector27
vector27:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $27
80106e3c:	6a 1b                	push   $0x1b
  jmp alltraps
80106e3e:	e9 23 f8 ff ff       	jmp    80106666 <alltraps>

80106e43 <vector28>:
.globl vector28
vector28:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $28
80106e45:	6a 1c                	push   $0x1c
  jmp alltraps
80106e47:	e9 1a f8 ff ff       	jmp    80106666 <alltraps>

80106e4c <vector29>:
.globl vector29
vector29:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $29
80106e4e:	6a 1d                	push   $0x1d
  jmp alltraps
80106e50:	e9 11 f8 ff ff       	jmp    80106666 <alltraps>

80106e55 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $30
80106e57:	6a 1e                	push   $0x1e
  jmp alltraps
80106e59:	e9 08 f8 ff ff       	jmp    80106666 <alltraps>

80106e5e <vector31>:
.globl vector31
vector31:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $31
80106e60:	6a 1f                	push   $0x1f
  jmp alltraps
80106e62:	e9 ff f7 ff ff       	jmp    80106666 <alltraps>

80106e67 <vector32>:
.globl vector32
vector32:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $32
80106e69:	6a 20                	push   $0x20
  jmp alltraps
80106e6b:	e9 f6 f7 ff ff       	jmp    80106666 <alltraps>

80106e70 <vector33>:
.globl vector33
vector33:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $33
80106e72:	6a 21                	push   $0x21
  jmp alltraps
80106e74:	e9 ed f7 ff ff       	jmp    80106666 <alltraps>

80106e79 <vector34>:
.globl vector34
vector34:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $34
80106e7b:	6a 22                	push   $0x22
  jmp alltraps
80106e7d:	e9 e4 f7 ff ff       	jmp    80106666 <alltraps>

80106e82 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $35
80106e84:	6a 23                	push   $0x23
  jmp alltraps
80106e86:	e9 db f7 ff ff       	jmp    80106666 <alltraps>

80106e8b <vector36>:
.globl vector36
vector36:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $36
80106e8d:	6a 24                	push   $0x24
  jmp alltraps
80106e8f:	e9 d2 f7 ff ff       	jmp    80106666 <alltraps>

80106e94 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $37
80106e96:	6a 25                	push   $0x25
  jmp alltraps
80106e98:	e9 c9 f7 ff ff       	jmp    80106666 <alltraps>

80106e9d <vector38>:
.globl vector38
vector38:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $38
80106e9f:	6a 26                	push   $0x26
  jmp alltraps
80106ea1:	e9 c0 f7 ff ff       	jmp    80106666 <alltraps>

80106ea6 <vector39>:
.globl vector39
vector39:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $39
80106ea8:	6a 27                	push   $0x27
  jmp alltraps
80106eaa:	e9 b7 f7 ff ff       	jmp    80106666 <alltraps>

80106eaf <vector40>:
.globl vector40
vector40:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $40
80106eb1:	6a 28                	push   $0x28
  jmp alltraps
80106eb3:	e9 ae f7 ff ff       	jmp    80106666 <alltraps>

80106eb8 <vector41>:
.globl vector41
vector41:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $41
80106eba:	6a 29                	push   $0x29
  jmp alltraps
80106ebc:	e9 a5 f7 ff ff       	jmp    80106666 <alltraps>

80106ec1 <vector42>:
.globl vector42
vector42:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $42
80106ec3:	6a 2a                	push   $0x2a
  jmp alltraps
80106ec5:	e9 9c f7 ff ff       	jmp    80106666 <alltraps>

80106eca <vector43>:
.globl vector43
vector43:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $43
80106ecc:	6a 2b                	push   $0x2b
  jmp alltraps
80106ece:	e9 93 f7 ff ff       	jmp    80106666 <alltraps>

80106ed3 <vector44>:
.globl vector44
vector44:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $44
80106ed5:	6a 2c                	push   $0x2c
  jmp alltraps
80106ed7:	e9 8a f7 ff ff       	jmp    80106666 <alltraps>

80106edc <vector45>:
.globl vector45
vector45:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $45
80106ede:	6a 2d                	push   $0x2d
  jmp alltraps
80106ee0:	e9 81 f7 ff ff       	jmp    80106666 <alltraps>

80106ee5 <vector46>:
.globl vector46
vector46:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $46
80106ee7:	6a 2e                	push   $0x2e
  jmp alltraps
80106ee9:	e9 78 f7 ff ff       	jmp    80106666 <alltraps>

80106eee <vector47>:
.globl vector47
vector47:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $47
80106ef0:	6a 2f                	push   $0x2f
  jmp alltraps
80106ef2:	e9 6f f7 ff ff       	jmp    80106666 <alltraps>

80106ef7 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $48
80106ef9:	6a 30                	push   $0x30
  jmp alltraps
80106efb:	e9 66 f7 ff ff       	jmp    80106666 <alltraps>

80106f00 <vector49>:
.globl vector49
vector49:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $49
80106f02:	6a 31                	push   $0x31
  jmp alltraps
80106f04:	e9 5d f7 ff ff       	jmp    80106666 <alltraps>

80106f09 <vector50>:
.globl vector50
vector50:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $50
80106f0b:	6a 32                	push   $0x32
  jmp alltraps
80106f0d:	e9 54 f7 ff ff       	jmp    80106666 <alltraps>

80106f12 <vector51>:
.globl vector51
vector51:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $51
80106f14:	6a 33                	push   $0x33
  jmp alltraps
80106f16:	e9 4b f7 ff ff       	jmp    80106666 <alltraps>

80106f1b <vector52>:
.globl vector52
vector52:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $52
80106f1d:	6a 34                	push   $0x34
  jmp alltraps
80106f1f:	e9 42 f7 ff ff       	jmp    80106666 <alltraps>

80106f24 <vector53>:
.globl vector53
vector53:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $53
80106f26:	6a 35                	push   $0x35
  jmp alltraps
80106f28:	e9 39 f7 ff ff       	jmp    80106666 <alltraps>

80106f2d <vector54>:
.globl vector54
vector54:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $54
80106f2f:	6a 36                	push   $0x36
  jmp alltraps
80106f31:	e9 30 f7 ff ff       	jmp    80106666 <alltraps>

80106f36 <vector55>:
.globl vector55
vector55:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $55
80106f38:	6a 37                	push   $0x37
  jmp alltraps
80106f3a:	e9 27 f7 ff ff       	jmp    80106666 <alltraps>

80106f3f <vector56>:
.globl vector56
vector56:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $56
80106f41:	6a 38                	push   $0x38
  jmp alltraps
80106f43:	e9 1e f7 ff ff       	jmp    80106666 <alltraps>

80106f48 <vector57>:
.globl vector57
vector57:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $57
80106f4a:	6a 39                	push   $0x39
  jmp alltraps
80106f4c:	e9 15 f7 ff ff       	jmp    80106666 <alltraps>

80106f51 <vector58>:
.globl vector58
vector58:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $58
80106f53:	6a 3a                	push   $0x3a
  jmp alltraps
80106f55:	e9 0c f7 ff ff       	jmp    80106666 <alltraps>

80106f5a <vector59>:
.globl vector59
vector59:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $59
80106f5c:	6a 3b                	push   $0x3b
  jmp alltraps
80106f5e:	e9 03 f7 ff ff       	jmp    80106666 <alltraps>

80106f63 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $60
80106f65:	6a 3c                	push   $0x3c
  jmp alltraps
80106f67:	e9 fa f6 ff ff       	jmp    80106666 <alltraps>

80106f6c <vector61>:
.globl vector61
vector61:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $61
80106f6e:	6a 3d                	push   $0x3d
  jmp alltraps
80106f70:	e9 f1 f6 ff ff       	jmp    80106666 <alltraps>

80106f75 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $62
80106f77:	6a 3e                	push   $0x3e
  jmp alltraps
80106f79:	e9 e8 f6 ff ff       	jmp    80106666 <alltraps>

80106f7e <vector63>:
.globl vector63
vector63:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $63
80106f80:	6a 3f                	push   $0x3f
  jmp alltraps
80106f82:	e9 df f6 ff ff       	jmp    80106666 <alltraps>

80106f87 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $64
80106f89:	6a 40                	push   $0x40
  jmp alltraps
80106f8b:	e9 d6 f6 ff ff       	jmp    80106666 <alltraps>

80106f90 <vector65>:
.globl vector65
vector65:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $65
80106f92:	6a 41                	push   $0x41
  jmp alltraps
80106f94:	e9 cd f6 ff ff       	jmp    80106666 <alltraps>

80106f99 <vector66>:
.globl vector66
vector66:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $66
80106f9b:	6a 42                	push   $0x42
  jmp alltraps
80106f9d:	e9 c4 f6 ff ff       	jmp    80106666 <alltraps>

80106fa2 <vector67>:
.globl vector67
vector67:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $67
80106fa4:	6a 43                	push   $0x43
  jmp alltraps
80106fa6:	e9 bb f6 ff ff       	jmp    80106666 <alltraps>

80106fab <vector68>:
.globl vector68
vector68:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $68
80106fad:	6a 44                	push   $0x44
  jmp alltraps
80106faf:	e9 b2 f6 ff ff       	jmp    80106666 <alltraps>

80106fb4 <vector69>:
.globl vector69
vector69:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $69
80106fb6:	6a 45                	push   $0x45
  jmp alltraps
80106fb8:	e9 a9 f6 ff ff       	jmp    80106666 <alltraps>

80106fbd <vector70>:
.globl vector70
vector70:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $70
80106fbf:	6a 46                	push   $0x46
  jmp alltraps
80106fc1:	e9 a0 f6 ff ff       	jmp    80106666 <alltraps>

80106fc6 <vector71>:
.globl vector71
vector71:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $71
80106fc8:	6a 47                	push   $0x47
  jmp alltraps
80106fca:	e9 97 f6 ff ff       	jmp    80106666 <alltraps>

80106fcf <vector72>:
.globl vector72
vector72:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $72
80106fd1:	6a 48                	push   $0x48
  jmp alltraps
80106fd3:	e9 8e f6 ff ff       	jmp    80106666 <alltraps>

80106fd8 <vector73>:
.globl vector73
vector73:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $73
80106fda:	6a 49                	push   $0x49
  jmp alltraps
80106fdc:	e9 85 f6 ff ff       	jmp    80106666 <alltraps>

80106fe1 <vector74>:
.globl vector74
vector74:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $74
80106fe3:	6a 4a                	push   $0x4a
  jmp alltraps
80106fe5:	e9 7c f6 ff ff       	jmp    80106666 <alltraps>

80106fea <vector75>:
.globl vector75
vector75:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $75
80106fec:	6a 4b                	push   $0x4b
  jmp alltraps
80106fee:	e9 73 f6 ff ff       	jmp    80106666 <alltraps>

80106ff3 <vector76>:
.globl vector76
vector76:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $76
80106ff5:	6a 4c                	push   $0x4c
  jmp alltraps
80106ff7:	e9 6a f6 ff ff       	jmp    80106666 <alltraps>

80106ffc <vector77>:
.globl vector77
vector77:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $77
80106ffe:	6a 4d                	push   $0x4d
  jmp alltraps
80107000:	e9 61 f6 ff ff       	jmp    80106666 <alltraps>

80107005 <vector78>:
.globl vector78
vector78:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $78
80107007:	6a 4e                	push   $0x4e
  jmp alltraps
80107009:	e9 58 f6 ff ff       	jmp    80106666 <alltraps>

8010700e <vector79>:
.globl vector79
vector79:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $79
80107010:	6a 4f                	push   $0x4f
  jmp alltraps
80107012:	e9 4f f6 ff ff       	jmp    80106666 <alltraps>

80107017 <vector80>:
.globl vector80
vector80:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $80
80107019:	6a 50                	push   $0x50
  jmp alltraps
8010701b:	e9 46 f6 ff ff       	jmp    80106666 <alltraps>

80107020 <vector81>:
.globl vector81
vector81:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $81
80107022:	6a 51                	push   $0x51
  jmp alltraps
80107024:	e9 3d f6 ff ff       	jmp    80106666 <alltraps>

80107029 <vector82>:
.globl vector82
vector82:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $82
8010702b:	6a 52                	push   $0x52
  jmp alltraps
8010702d:	e9 34 f6 ff ff       	jmp    80106666 <alltraps>

80107032 <vector83>:
.globl vector83
vector83:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $83
80107034:	6a 53                	push   $0x53
  jmp alltraps
80107036:	e9 2b f6 ff ff       	jmp    80106666 <alltraps>

8010703b <vector84>:
.globl vector84
vector84:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $84
8010703d:	6a 54                	push   $0x54
  jmp alltraps
8010703f:	e9 22 f6 ff ff       	jmp    80106666 <alltraps>

80107044 <vector85>:
.globl vector85
vector85:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $85
80107046:	6a 55                	push   $0x55
  jmp alltraps
80107048:	e9 19 f6 ff ff       	jmp    80106666 <alltraps>

8010704d <vector86>:
.globl vector86
vector86:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $86
8010704f:	6a 56                	push   $0x56
  jmp alltraps
80107051:	e9 10 f6 ff ff       	jmp    80106666 <alltraps>

80107056 <vector87>:
.globl vector87
vector87:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $87
80107058:	6a 57                	push   $0x57
  jmp alltraps
8010705a:	e9 07 f6 ff ff       	jmp    80106666 <alltraps>

8010705f <vector88>:
.globl vector88
vector88:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $88
80107061:	6a 58                	push   $0x58
  jmp alltraps
80107063:	e9 fe f5 ff ff       	jmp    80106666 <alltraps>

80107068 <vector89>:
.globl vector89
vector89:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $89
8010706a:	6a 59                	push   $0x59
  jmp alltraps
8010706c:	e9 f5 f5 ff ff       	jmp    80106666 <alltraps>

80107071 <vector90>:
.globl vector90
vector90:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $90
80107073:	6a 5a                	push   $0x5a
  jmp alltraps
80107075:	e9 ec f5 ff ff       	jmp    80106666 <alltraps>

8010707a <vector91>:
.globl vector91
vector91:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $91
8010707c:	6a 5b                	push   $0x5b
  jmp alltraps
8010707e:	e9 e3 f5 ff ff       	jmp    80106666 <alltraps>

80107083 <vector92>:
.globl vector92
vector92:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $92
80107085:	6a 5c                	push   $0x5c
  jmp alltraps
80107087:	e9 da f5 ff ff       	jmp    80106666 <alltraps>

8010708c <vector93>:
.globl vector93
vector93:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $93
8010708e:	6a 5d                	push   $0x5d
  jmp alltraps
80107090:	e9 d1 f5 ff ff       	jmp    80106666 <alltraps>

80107095 <vector94>:
.globl vector94
vector94:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $94
80107097:	6a 5e                	push   $0x5e
  jmp alltraps
80107099:	e9 c8 f5 ff ff       	jmp    80106666 <alltraps>

8010709e <vector95>:
.globl vector95
vector95:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $95
801070a0:	6a 5f                	push   $0x5f
  jmp alltraps
801070a2:	e9 bf f5 ff ff       	jmp    80106666 <alltraps>

801070a7 <vector96>:
.globl vector96
vector96:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $96
801070a9:	6a 60                	push   $0x60
  jmp alltraps
801070ab:	e9 b6 f5 ff ff       	jmp    80106666 <alltraps>

801070b0 <vector97>:
.globl vector97
vector97:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $97
801070b2:	6a 61                	push   $0x61
  jmp alltraps
801070b4:	e9 ad f5 ff ff       	jmp    80106666 <alltraps>

801070b9 <vector98>:
.globl vector98
vector98:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $98
801070bb:	6a 62                	push   $0x62
  jmp alltraps
801070bd:	e9 a4 f5 ff ff       	jmp    80106666 <alltraps>

801070c2 <vector99>:
.globl vector99
vector99:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $99
801070c4:	6a 63                	push   $0x63
  jmp alltraps
801070c6:	e9 9b f5 ff ff       	jmp    80106666 <alltraps>

801070cb <vector100>:
.globl vector100
vector100:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $100
801070cd:	6a 64                	push   $0x64
  jmp alltraps
801070cf:	e9 92 f5 ff ff       	jmp    80106666 <alltraps>

801070d4 <vector101>:
.globl vector101
vector101:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $101
801070d6:	6a 65                	push   $0x65
  jmp alltraps
801070d8:	e9 89 f5 ff ff       	jmp    80106666 <alltraps>

801070dd <vector102>:
.globl vector102
vector102:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $102
801070df:	6a 66                	push   $0x66
  jmp alltraps
801070e1:	e9 80 f5 ff ff       	jmp    80106666 <alltraps>

801070e6 <vector103>:
.globl vector103
vector103:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $103
801070e8:	6a 67                	push   $0x67
  jmp alltraps
801070ea:	e9 77 f5 ff ff       	jmp    80106666 <alltraps>

801070ef <vector104>:
.globl vector104
vector104:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $104
801070f1:	6a 68                	push   $0x68
  jmp alltraps
801070f3:	e9 6e f5 ff ff       	jmp    80106666 <alltraps>

801070f8 <vector105>:
.globl vector105
vector105:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $105
801070fa:	6a 69                	push   $0x69
  jmp alltraps
801070fc:	e9 65 f5 ff ff       	jmp    80106666 <alltraps>

80107101 <vector106>:
.globl vector106
vector106:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $106
80107103:	6a 6a                	push   $0x6a
  jmp alltraps
80107105:	e9 5c f5 ff ff       	jmp    80106666 <alltraps>

8010710a <vector107>:
.globl vector107
vector107:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $107
8010710c:	6a 6b                	push   $0x6b
  jmp alltraps
8010710e:	e9 53 f5 ff ff       	jmp    80106666 <alltraps>

80107113 <vector108>:
.globl vector108
vector108:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $108
80107115:	6a 6c                	push   $0x6c
  jmp alltraps
80107117:	e9 4a f5 ff ff       	jmp    80106666 <alltraps>

8010711c <vector109>:
.globl vector109
vector109:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $109
8010711e:	6a 6d                	push   $0x6d
  jmp alltraps
80107120:	e9 41 f5 ff ff       	jmp    80106666 <alltraps>

80107125 <vector110>:
.globl vector110
vector110:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $110
80107127:	6a 6e                	push   $0x6e
  jmp alltraps
80107129:	e9 38 f5 ff ff       	jmp    80106666 <alltraps>

8010712e <vector111>:
.globl vector111
vector111:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $111
80107130:	6a 6f                	push   $0x6f
  jmp alltraps
80107132:	e9 2f f5 ff ff       	jmp    80106666 <alltraps>

80107137 <vector112>:
.globl vector112
vector112:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $112
80107139:	6a 70                	push   $0x70
  jmp alltraps
8010713b:	e9 26 f5 ff ff       	jmp    80106666 <alltraps>

80107140 <vector113>:
.globl vector113
vector113:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $113
80107142:	6a 71                	push   $0x71
  jmp alltraps
80107144:	e9 1d f5 ff ff       	jmp    80106666 <alltraps>

80107149 <vector114>:
.globl vector114
vector114:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $114
8010714b:	6a 72                	push   $0x72
  jmp alltraps
8010714d:	e9 14 f5 ff ff       	jmp    80106666 <alltraps>

80107152 <vector115>:
.globl vector115
vector115:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $115
80107154:	6a 73                	push   $0x73
  jmp alltraps
80107156:	e9 0b f5 ff ff       	jmp    80106666 <alltraps>

8010715b <vector116>:
.globl vector116
vector116:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $116
8010715d:	6a 74                	push   $0x74
  jmp alltraps
8010715f:	e9 02 f5 ff ff       	jmp    80106666 <alltraps>

80107164 <vector117>:
.globl vector117
vector117:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $117
80107166:	6a 75                	push   $0x75
  jmp alltraps
80107168:	e9 f9 f4 ff ff       	jmp    80106666 <alltraps>

8010716d <vector118>:
.globl vector118
vector118:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $118
8010716f:	6a 76                	push   $0x76
  jmp alltraps
80107171:	e9 f0 f4 ff ff       	jmp    80106666 <alltraps>

80107176 <vector119>:
.globl vector119
vector119:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $119
80107178:	6a 77                	push   $0x77
  jmp alltraps
8010717a:	e9 e7 f4 ff ff       	jmp    80106666 <alltraps>

8010717f <vector120>:
.globl vector120
vector120:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $120
80107181:	6a 78                	push   $0x78
  jmp alltraps
80107183:	e9 de f4 ff ff       	jmp    80106666 <alltraps>

80107188 <vector121>:
.globl vector121
vector121:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $121
8010718a:	6a 79                	push   $0x79
  jmp alltraps
8010718c:	e9 d5 f4 ff ff       	jmp    80106666 <alltraps>

80107191 <vector122>:
.globl vector122
vector122:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $122
80107193:	6a 7a                	push   $0x7a
  jmp alltraps
80107195:	e9 cc f4 ff ff       	jmp    80106666 <alltraps>

8010719a <vector123>:
.globl vector123
vector123:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $123
8010719c:	6a 7b                	push   $0x7b
  jmp alltraps
8010719e:	e9 c3 f4 ff ff       	jmp    80106666 <alltraps>

801071a3 <vector124>:
.globl vector124
vector124:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $124
801071a5:	6a 7c                	push   $0x7c
  jmp alltraps
801071a7:	e9 ba f4 ff ff       	jmp    80106666 <alltraps>

801071ac <vector125>:
.globl vector125
vector125:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $125
801071ae:	6a 7d                	push   $0x7d
  jmp alltraps
801071b0:	e9 b1 f4 ff ff       	jmp    80106666 <alltraps>

801071b5 <vector126>:
.globl vector126
vector126:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $126
801071b7:	6a 7e                	push   $0x7e
  jmp alltraps
801071b9:	e9 a8 f4 ff ff       	jmp    80106666 <alltraps>

801071be <vector127>:
.globl vector127
vector127:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $127
801071c0:	6a 7f                	push   $0x7f
  jmp alltraps
801071c2:	e9 9f f4 ff ff       	jmp    80106666 <alltraps>

801071c7 <vector128>:
.globl vector128
vector128:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $128
801071c9:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801071ce:	e9 93 f4 ff ff       	jmp    80106666 <alltraps>

801071d3 <vector129>:
.globl vector129
vector129:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $129
801071d5:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801071da:	e9 87 f4 ff ff       	jmp    80106666 <alltraps>

801071df <vector130>:
.globl vector130
vector130:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $130
801071e1:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801071e6:	e9 7b f4 ff ff       	jmp    80106666 <alltraps>

801071eb <vector131>:
.globl vector131
vector131:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $131
801071ed:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801071f2:	e9 6f f4 ff ff       	jmp    80106666 <alltraps>

801071f7 <vector132>:
.globl vector132
vector132:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $132
801071f9:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801071fe:	e9 63 f4 ff ff       	jmp    80106666 <alltraps>

80107203 <vector133>:
.globl vector133
vector133:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $133
80107205:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010720a:	e9 57 f4 ff ff       	jmp    80106666 <alltraps>

8010720f <vector134>:
.globl vector134
vector134:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $134
80107211:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107216:	e9 4b f4 ff ff       	jmp    80106666 <alltraps>

8010721b <vector135>:
.globl vector135
vector135:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $135
8010721d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107222:	e9 3f f4 ff ff       	jmp    80106666 <alltraps>

80107227 <vector136>:
.globl vector136
vector136:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $136
80107229:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010722e:	e9 33 f4 ff ff       	jmp    80106666 <alltraps>

80107233 <vector137>:
.globl vector137
vector137:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $137
80107235:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010723a:	e9 27 f4 ff ff       	jmp    80106666 <alltraps>

8010723f <vector138>:
.globl vector138
vector138:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $138
80107241:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107246:	e9 1b f4 ff ff       	jmp    80106666 <alltraps>

8010724b <vector139>:
.globl vector139
vector139:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $139
8010724d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107252:	e9 0f f4 ff ff       	jmp    80106666 <alltraps>

80107257 <vector140>:
.globl vector140
vector140:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $140
80107259:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010725e:	e9 03 f4 ff ff       	jmp    80106666 <alltraps>

80107263 <vector141>:
.globl vector141
vector141:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $141
80107265:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010726a:	e9 f7 f3 ff ff       	jmp    80106666 <alltraps>

8010726f <vector142>:
.globl vector142
vector142:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $142
80107271:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107276:	e9 eb f3 ff ff       	jmp    80106666 <alltraps>

8010727b <vector143>:
.globl vector143
vector143:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $143
8010727d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107282:	e9 df f3 ff ff       	jmp    80106666 <alltraps>

80107287 <vector144>:
.globl vector144
vector144:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $144
80107289:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010728e:	e9 d3 f3 ff ff       	jmp    80106666 <alltraps>

80107293 <vector145>:
.globl vector145
vector145:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $145
80107295:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010729a:	e9 c7 f3 ff ff       	jmp    80106666 <alltraps>

8010729f <vector146>:
.globl vector146
vector146:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $146
801072a1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801072a6:	e9 bb f3 ff ff       	jmp    80106666 <alltraps>

801072ab <vector147>:
.globl vector147
vector147:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $147
801072ad:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801072b2:	e9 af f3 ff ff       	jmp    80106666 <alltraps>

801072b7 <vector148>:
.globl vector148
vector148:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $148
801072b9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801072be:	e9 a3 f3 ff ff       	jmp    80106666 <alltraps>

801072c3 <vector149>:
.globl vector149
vector149:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $149
801072c5:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801072ca:	e9 97 f3 ff ff       	jmp    80106666 <alltraps>

801072cf <vector150>:
.globl vector150
vector150:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $150
801072d1:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801072d6:	e9 8b f3 ff ff       	jmp    80106666 <alltraps>

801072db <vector151>:
.globl vector151
vector151:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $151
801072dd:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801072e2:	e9 7f f3 ff ff       	jmp    80106666 <alltraps>

801072e7 <vector152>:
.globl vector152
vector152:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $152
801072e9:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801072ee:	e9 73 f3 ff ff       	jmp    80106666 <alltraps>

801072f3 <vector153>:
.globl vector153
vector153:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $153
801072f5:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801072fa:	e9 67 f3 ff ff       	jmp    80106666 <alltraps>

801072ff <vector154>:
.globl vector154
vector154:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $154
80107301:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107306:	e9 5b f3 ff ff       	jmp    80106666 <alltraps>

8010730b <vector155>:
.globl vector155
vector155:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $155
8010730d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107312:	e9 4f f3 ff ff       	jmp    80106666 <alltraps>

80107317 <vector156>:
.globl vector156
vector156:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $156
80107319:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010731e:	e9 43 f3 ff ff       	jmp    80106666 <alltraps>

80107323 <vector157>:
.globl vector157
vector157:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $157
80107325:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010732a:	e9 37 f3 ff ff       	jmp    80106666 <alltraps>

8010732f <vector158>:
.globl vector158
vector158:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $158
80107331:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107336:	e9 2b f3 ff ff       	jmp    80106666 <alltraps>

8010733b <vector159>:
.globl vector159
vector159:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $159
8010733d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107342:	e9 1f f3 ff ff       	jmp    80106666 <alltraps>

80107347 <vector160>:
.globl vector160
vector160:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $160
80107349:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010734e:	e9 13 f3 ff ff       	jmp    80106666 <alltraps>

80107353 <vector161>:
.globl vector161
vector161:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $161
80107355:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010735a:	e9 07 f3 ff ff       	jmp    80106666 <alltraps>

8010735f <vector162>:
.globl vector162
vector162:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $162
80107361:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107366:	e9 fb f2 ff ff       	jmp    80106666 <alltraps>

8010736b <vector163>:
.globl vector163
vector163:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $163
8010736d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107372:	e9 ef f2 ff ff       	jmp    80106666 <alltraps>

80107377 <vector164>:
.globl vector164
vector164:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $164
80107379:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010737e:	e9 e3 f2 ff ff       	jmp    80106666 <alltraps>

80107383 <vector165>:
.globl vector165
vector165:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $165
80107385:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010738a:	e9 d7 f2 ff ff       	jmp    80106666 <alltraps>

8010738f <vector166>:
.globl vector166
vector166:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $166
80107391:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107396:	e9 cb f2 ff ff       	jmp    80106666 <alltraps>

8010739b <vector167>:
.globl vector167
vector167:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $167
8010739d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801073a2:	e9 bf f2 ff ff       	jmp    80106666 <alltraps>

801073a7 <vector168>:
.globl vector168
vector168:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $168
801073a9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801073ae:	e9 b3 f2 ff ff       	jmp    80106666 <alltraps>

801073b3 <vector169>:
.globl vector169
vector169:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $169
801073b5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801073ba:	e9 a7 f2 ff ff       	jmp    80106666 <alltraps>

801073bf <vector170>:
.globl vector170
vector170:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $170
801073c1:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801073c6:	e9 9b f2 ff ff       	jmp    80106666 <alltraps>

801073cb <vector171>:
.globl vector171
vector171:
  pushl $0
801073cb:	6a 00                	push   $0x0
  pushl $171
801073cd:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801073d2:	e9 8f f2 ff ff       	jmp    80106666 <alltraps>

801073d7 <vector172>:
.globl vector172
vector172:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $172
801073d9:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801073de:	e9 83 f2 ff ff       	jmp    80106666 <alltraps>

801073e3 <vector173>:
.globl vector173
vector173:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $173
801073e5:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801073ea:	e9 77 f2 ff ff       	jmp    80106666 <alltraps>

801073ef <vector174>:
.globl vector174
vector174:
  pushl $0
801073ef:	6a 00                	push   $0x0
  pushl $174
801073f1:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801073f6:	e9 6b f2 ff ff       	jmp    80106666 <alltraps>

801073fb <vector175>:
.globl vector175
vector175:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $175
801073fd:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107402:	e9 5f f2 ff ff       	jmp    80106666 <alltraps>

80107407 <vector176>:
.globl vector176
vector176:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $176
80107409:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010740e:	e9 53 f2 ff ff       	jmp    80106666 <alltraps>

80107413 <vector177>:
.globl vector177
vector177:
  pushl $0
80107413:	6a 00                	push   $0x0
  pushl $177
80107415:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010741a:	e9 47 f2 ff ff       	jmp    80106666 <alltraps>

8010741f <vector178>:
.globl vector178
vector178:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $178
80107421:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107426:	e9 3b f2 ff ff       	jmp    80106666 <alltraps>

8010742b <vector179>:
.globl vector179
vector179:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $179
8010742d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107432:	e9 2f f2 ff ff       	jmp    80106666 <alltraps>

80107437 <vector180>:
.globl vector180
vector180:
  pushl $0
80107437:	6a 00                	push   $0x0
  pushl $180
80107439:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010743e:	e9 23 f2 ff ff       	jmp    80106666 <alltraps>

80107443 <vector181>:
.globl vector181
vector181:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $181
80107445:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010744a:	e9 17 f2 ff ff       	jmp    80106666 <alltraps>

8010744f <vector182>:
.globl vector182
vector182:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $182
80107451:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107456:	e9 0b f2 ff ff       	jmp    80106666 <alltraps>

8010745b <vector183>:
.globl vector183
vector183:
  pushl $0
8010745b:	6a 00                	push   $0x0
  pushl $183
8010745d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107462:	e9 ff f1 ff ff       	jmp    80106666 <alltraps>

80107467 <vector184>:
.globl vector184
vector184:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $184
80107469:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010746e:	e9 f3 f1 ff ff       	jmp    80106666 <alltraps>

80107473 <vector185>:
.globl vector185
vector185:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $185
80107475:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010747a:	e9 e7 f1 ff ff       	jmp    80106666 <alltraps>

8010747f <vector186>:
.globl vector186
vector186:
  pushl $0
8010747f:	6a 00                	push   $0x0
  pushl $186
80107481:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107486:	e9 db f1 ff ff       	jmp    80106666 <alltraps>

8010748b <vector187>:
.globl vector187
vector187:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $187
8010748d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107492:	e9 cf f1 ff ff       	jmp    80106666 <alltraps>

80107497 <vector188>:
.globl vector188
vector188:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $188
80107499:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010749e:	e9 c3 f1 ff ff       	jmp    80106666 <alltraps>

801074a3 <vector189>:
.globl vector189
vector189:
  pushl $0
801074a3:	6a 00                	push   $0x0
  pushl $189
801074a5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801074aa:	e9 b7 f1 ff ff       	jmp    80106666 <alltraps>

801074af <vector190>:
.globl vector190
vector190:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $190
801074b1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801074b6:	e9 ab f1 ff ff       	jmp    80106666 <alltraps>

801074bb <vector191>:
.globl vector191
vector191:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $191
801074bd:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801074c2:	e9 9f f1 ff ff       	jmp    80106666 <alltraps>

801074c7 <vector192>:
.globl vector192
vector192:
  pushl $0
801074c7:	6a 00                	push   $0x0
  pushl $192
801074c9:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801074ce:	e9 93 f1 ff ff       	jmp    80106666 <alltraps>

801074d3 <vector193>:
.globl vector193
vector193:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $193
801074d5:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801074da:	e9 87 f1 ff ff       	jmp    80106666 <alltraps>

801074df <vector194>:
.globl vector194
vector194:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $194
801074e1:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801074e6:	e9 7b f1 ff ff       	jmp    80106666 <alltraps>

801074eb <vector195>:
.globl vector195
vector195:
  pushl $0
801074eb:	6a 00                	push   $0x0
  pushl $195
801074ed:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801074f2:	e9 6f f1 ff ff       	jmp    80106666 <alltraps>

801074f7 <vector196>:
.globl vector196
vector196:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $196
801074f9:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801074fe:	e9 63 f1 ff ff       	jmp    80106666 <alltraps>

80107503 <vector197>:
.globl vector197
vector197:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $197
80107505:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010750a:	e9 57 f1 ff ff       	jmp    80106666 <alltraps>

8010750f <vector198>:
.globl vector198
vector198:
  pushl $0
8010750f:	6a 00                	push   $0x0
  pushl $198
80107511:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107516:	e9 4b f1 ff ff       	jmp    80106666 <alltraps>

8010751b <vector199>:
.globl vector199
vector199:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $199
8010751d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107522:	e9 3f f1 ff ff       	jmp    80106666 <alltraps>

80107527 <vector200>:
.globl vector200
vector200:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $200
80107529:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010752e:	e9 33 f1 ff ff       	jmp    80106666 <alltraps>

80107533 <vector201>:
.globl vector201
vector201:
  pushl $0
80107533:	6a 00                	push   $0x0
  pushl $201
80107535:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010753a:	e9 27 f1 ff ff       	jmp    80106666 <alltraps>

8010753f <vector202>:
.globl vector202
vector202:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $202
80107541:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107546:	e9 1b f1 ff ff       	jmp    80106666 <alltraps>

8010754b <vector203>:
.globl vector203
vector203:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $203
8010754d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107552:	e9 0f f1 ff ff       	jmp    80106666 <alltraps>

80107557 <vector204>:
.globl vector204
vector204:
  pushl $0
80107557:	6a 00                	push   $0x0
  pushl $204
80107559:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010755e:	e9 03 f1 ff ff       	jmp    80106666 <alltraps>

80107563 <vector205>:
.globl vector205
vector205:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $205
80107565:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010756a:	e9 f7 f0 ff ff       	jmp    80106666 <alltraps>

8010756f <vector206>:
.globl vector206
vector206:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $206
80107571:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107576:	e9 eb f0 ff ff       	jmp    80106666 <alltraps>

8010757b <vector207>:
.globl vector207
vector207:
  pushl $0
8010757b:	6a 00                	push   $0x0
  pushl $207
8010757d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107582:	e9 df f0 ff ff       	jmp    80106666 <alltraps>

80107587 <vector208>:
.globl vector208
vector208:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $208
80107589:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010758e:	e9 d3 f0 ff ff       	jmp    80106666 <alltraps>

80107593 <vector209>:
.globl vector209
vector209:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $209
80107595:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010759a:	e9 c7 f0 ff ff       	jmp    80106666 <alltraps>

8010759f <vector210>:
.globl vector210
vector210:
  pushl $0
8010759f:	6a 00                	push   $0x0
  pushl $210
801075a1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801075a6:	e9 bb f0 ff ff       	jmp    80106666 <alltraps>

801075ab <vector211>:
.globl vector211
vector211:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $211
801075ad:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801075b2:	e9 af f0 ff ff       	jmp    80106666 <alltraps>

801075b7 <vector212>:
.globl vector212
vector212:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $212
801075b9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801075be:	e9 a3 f0 ff ff       	jmp    80106666 <alltraps>

801075c3 <vector213>:
.globl vector213
vector213:
  pushl $0
801075c3:	6a 00                	push   $0x0
  pushl $213
801075c5:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801075ca:	e9 97 f0 ff ff       	jmp    80106666 <alltraps>

801075cf <vector214>:
.globl vector214
vector214:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $214
801075d1:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801075d6:	e9 8b f0 ff ff       	jmp    80106666 <alltraps>

801075db <vector215>:
.globl vector215
vector215:
  pushl $0
801075db:	6a 00                	push   $0x0
  pushl $215
801075dd:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801075e2:	e9 7f f0 ff ff       	jmp    80106666 <alltraps>

801075e7 <vector216>:
.globl vector216
vector216:
  pushl $0
801075e7:	6a 00                	push   $0x0
  pushl $216
801075e9:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801075ee:	e9 73 f0 ff ff       	jmp    80106666 <alltraps>

801075f3 <vector217>:
.globl vector217
vector217:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $217
801075f5:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801075fa:	e9 67 f0 ff ff       	jmp    80106666 <alltraps>

801075ff <vector218>:
.globl vector218
vector218:
  pushl $0
801075ff:	6a 00                	push   $0x0
  pushl $218
80107601:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107606:	e9 5b f0 ff ff       	jmp    80106666 <alltraps>

8010760b <vector219>:
.globl vector219
vector219:
  pushl $0
8010760b:	6a 00                	push   $0x0
  pushl $219
8010760d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107612:	e9 4f f0 ff ff       	jmp    80106666 <alltraps>

80107617 <vector220>:
.globl vector220
vector220:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $220
80107619:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010761e:	e9 43 f0 ff ff       	jmp    80106666 <alltraps>

80107623 <vector221>:
.globl vector221
vector221:
  pushl $0
80107623:	6a 00                	push   $0x0
  pushl $221
80107625:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010762a:	e9 37 f0 ff ff       	jmp    80106666 <alltraps>

8010762f <vector222>:
.globl vector222
vector222:
  pushl $0
8010762f:	6a 00                	push   $0x0
  pushl $222
80107631:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107636:	e9 2b f0 ff ff       	jmp    80106666 <alltraps>

8010763b <vector223>:
.globl vector223
vector223:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $223
8010763d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107642:	e9 1f f0 ff ff       	jmp    80106666 <alltraps>

80107647 <vector224>:
.globl vector224
vector224:
  pushl $0
80107647:	6a 00                	push   $0x0
  pushl $224
80107649:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010764e:	e9 13 f0 ff ff       	jmp    80106666 <alltraps>

80107653 <vector225>:
.globl vector225
vector225:
  pushl $0
80107653:	6a 00                	push   $0x0
  pushl $225
80107655:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010765a:	e9 07 f0 ff ff       	jmp    80106666 <alltraps>

8010765f <vector226>:
.globl vector226
vector226:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $226
80107661:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107666:	e9 fb ef ff ff       	jmp    80106666 <alltraps>

8010766b <vector227>:
.globl vector227
vector227:
  pushl $0
8010766b:	6a 00                	push   $0x0
  pushl $227
8010766d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107672:	e9 ef ef ff ff       	jmp    80106666 <alltraps>

80107677 <vector228>:
.globl vector228
vector228:
  pushl $0
80107677:	6a 00                	push   $0x0
  pushl $228
80107679:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010767e:	e9 e3 ef ff ff       	jmp    80106666 <alltraps>

80107683 <vector229>:
.globl vector229
vector229:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $229
80107685:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010768a:	e9 d7 ef ff ff       	jmp    80106666 <alltraps>

8010768f <vector230>:
.globl vector230
vector230:
  pushl $0
8010768f:	6a 00                	push   $0x0
  pushl $230
80107691:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107696:	e9 cb ef ff ff       	jmp    80106666 <alltraps>

8010769b <vector231>:
.globl vector231
vector231:
  pushl $0
8010769b:	6a 00                	push   $0x0
  pushl $231
8010769d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801076a2:	e9 bf ef ff ff       	jmp    80106666 <alltraps>

801076a7 <vector232>:
.globl vector232
vector232:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $232
801076a9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801076ae:	e9 b3 ef ff ff       	jmp    80106666 <alltraps>

801076b3 <vector233>:
.globl vector233
vector233:
  pushl $0
801076b3:	6a 00                	push   $0x0
  pushl $233
801076b5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801076ba:	e9 a7 ef ff ff       	jmp    80106666 <alltraps>

801076bf <vector234>:
.globl vector234
vector234:
  pushl $0
801076bf:	6a 00                	push   $0x0
  pushl $234
801076c1:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801076c6:	e9 9b ef ff ff       	jmp    80106666 <alltraps>

801076cb <vector235>:
.globl vector235
vector235:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $235
801076cd:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801076d2:	e9 8f ef ff ff       	jmp    80106666 <alltraps>

801076d7 <vector236>:
.globl vector236
vector236:
  pushl $0
801076d7:	6a 00                	push   $0x0
  pushl $236
801076d9:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801076de:	e9 83 ef ff ff       	jmp    80106666 <alltraps>

801076e3 <vector237>:
.globl vector237
vector237:
  pushl $0
801076e3:	6a 00                	push   $0x0
  pushl $237
801076e5:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801076ea:	e9 77 ef ff ff       	jmp    80106666 <alltraps>

801076ef <vector238>:
.globl vector238
vector238:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $238
801076f1:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801076f6:	e9 6b ef ff ff       	jmp    80106666 <alltraps>

801076fb <vector239>:
.globl vector239
vector239:
  pushl $0
801076fb:	6a 00                	push   $0x0
  pushl $239
801076fd:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107702:	e9 5f ef ff ff       	jmp    80106666 <alltraps>

80107707 <vector240>:
.globl vector240
vector240:
  pushl $0
80107707:	6a 00                	push   $0x0
  pushl $240
80107709:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010770e:	e9 53 ef ff ff       	jmp    80106666 <alltraps>

80107713 <vector241>:
.globl vector241
vector241:
  pushl $0
80107713:	6a 00                	push   $0x0
  pushl $241
80107715:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010771a:	e9 47 ef ff ff       	jmp    80106666 <alltraps>

8010771f <vector242>:
.globl vector242
vector242:
  pushl $0
8010771f:	6a 00                	push   $0x0
  pushl $242
80107721:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107726:	e9 3b ef ff ff       	jmp    80106666 <alltraps>

8010772b <vector243>:
.globl vector243
vector243:
  pushl $0
8010772b:	6a 00                	push   $0x0
  pushl $243
8010772d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107732:	e9 2f ef ff ff       	jmp    80106666 <alltraps>

80107737 <vector244>:
.globl vector244
vector244:
  pushl $0
80107737:	6a 00                	push   $0x0
  pushl $244
80107739:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010773e:	e9 23 ef ff ff       	jmp    80106666 <alltraps>

80107743 <vector245>:
.globl vector245
vector245:
  pushl $0
80107743:	6a 00                	push   $0x0
  pushl $245
80107745:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010774a:	e9 17 ef ff ff       	jmp    80106666 <alltraps>

8010774f <vector246>:
.globl vector246
vector246:
  pushl $0
8010774f:	6a 00                	push   $0x0
  pushl $246
80107751:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107756:	e9 0b ef ff ff       	jmp    80106666 <alltraps>

8010775b <vector247>:
.globl vector247
vector247:
  pushl $0
8010775b:	6a 00                	push   $0x0
  pushl $247
8010775d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107762:	e9 ff ee ff ff       	jmp    80106666 <alltraps>

80107767 <vector248>:
.globl vector248
vector248:
  pushl $0
80107767:	6a 00                	push   $0x0
  pushl $248
80107769:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010776e:	e9 f3 ee ff ff       	jmp    80106666 <alltraps>

80107773 <vector249>:
.globl vector249
vector249:
  pushl $0
80107773:	6a 00                	push   $0x0
  pushl $249
80107775:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010777a:	e9 e7 ee ff ff       	jmp    80106666 <alltraps>

8010777f <vector250>:
.globl vector250
vector250:
  pushl $0
8010777f:	6a 00                	push   $0x0
  pushl $250
80107781:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107786:	e9 db ee ff ff       	jmp    80106666 <alltraps>

8010778b <vector251>:
.globl vector251
vector251:
  pushl $0
8010778b:	6a 00                	push   $0x0
  pushl $251
8010778d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107792:	e9 cf ee ff ff       	jmp    80106666 <alltraps>

80107797 <vector252>:
.globl vector252
vector252:
  pushl $0
80107797:	6a 00                	push   $0x0
  pushl $252
80107799:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010779e:	e9 c3 ee ff ff       	jmp    80106666 <alltraps>

801077a3 <vector253>:
.globl vector253
vector253:
  pushl $0
801077a3:	6a 00                	push   $0x0
  pushl $253
801077a5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801077aa:	e9 b7 ee ff ff       	jmp    80106666 <alltraps>

801077af <vector254>:
.globl vector254
vector254:
  pushl $0
801077af:	6a 00                	push   $0x0
  pushl $254
801077b1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801077b6:	e9 ab ee ff ff       	jmp    80106666 <alltraps>

801077bb <vector255>:
.globl vector255
vector255:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $255
801077bd:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801077c2:	e9 9f ee ff ff       	jmp    80106666 <alltraps>

801077c7 <lgdt>:
{
801077c7:	55                   	push   %ebp
801077c8:	89 e5                	mov    %esp,%ebp
801077ca:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801077cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801077d0:	83 e8 01             	sub    $0x1,%eax
801077d3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801077d7:	8b 45 08             	mov    0x8(%ebp),%eax
801077da:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801077de:	8b 45 08             	mov    0x8(%ebp),%eax
801077e1:	c1 e8 10             	shr    $0x10,%eax
801077e4:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801077e8:	8d 45 fa             	lea    -0x6(%ebp),%eax
801077eb:	0f 01 10             	lgdtl  (%eax)
}
801077ee:	90                   	nop
801077ef:	c9                   	leave  
801077f0:	c3                   	ret    

801077f1 <ltr>:
{
801077f1:	55                   	push   %ebp
801077f2:	89 e5                	mov    %esp,%ebp
801077f4:	83 ec 04             	sub    $0x4,%esp
801077f7:	8b 45 08             	mov    0x8(%ebp),%eax
801077fa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801077fe:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107802:	0f 00 d8             	ltr    %ax
}
80107805:	90                   	nop
80107806:	c9                   	leave  
80107807:	c3                   	ret    

80107808 <lcr3>:

static inline void
lcr3(uint val)
{
80107808:	55                   	push   %ebp
80107809:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010780b:	8b 45 08             	mov    0x8(%ebp),%eax
8010780e:	0f 22 d8             	mov    %eax,%cr3
}
80107811:	90                   	nop
80107812:	5d                   	pop    %ebp
80107813:	c3                   	ret    

80107814 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107814:	55                   	push   %ebp
80107815:	89 e5                	mov    %esp,%ebp
80107817:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010781a:	e8 62 c6 ff ff       	call   80103e81 <cpuid>
8010781f:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107825:	05 c0 a2 11 80       	add    $0x8011a2c0,%eax
8010782a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010782d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107830:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107839:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010783f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107842:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107849:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010784d:	83 e2 f0             	and    $0xfffffff0,%edx
80107850:	83 ca 0a             	or     $0xa,%edx
80107853:	88 50 7d             	mov    %dl,0x7d(%eax)
80107856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107859:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010785d:	83 ca 10             	or     $0x10,%edx
80107860:	88 50 7d             	mov    %dl,0x7d(%eax)
80107863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107866:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010786a:	83 e2 9f             	and    $0xffffff9f,%edx
8010786d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107873:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107877:	83 ca 80             	or     $0xffffff80,%edx
8010787a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010787d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107880:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107884:	83 ca 0f             	or     $0xf,%edx
80107887:	88 50 7e             	mov    %dl,0x7e(%eax)
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107891:	83 e2 ef             	and    $0xffffffef,%edx
80107894:	88 50 7e             	mov    %dl,0x7e(%eax)
80107897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010789e:	83 e2 df             	and    $0xffffffdf,%edx
801078a1:	88 50 7e             	mov    %dl,0x7e(%eax)
801078a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078ab:	83 ca 40             	or     $0x40,%edx
801078ae:	88 50 7e             	mov    %dl,0x7e(%eax)
801078b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078b8:	83 ca 80             	or     $0xffffff80,%edx
801078bb:	88 50 7e             	mov    %dl,0x7e(%eax)
801078be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c1:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c8:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801078cf:	ff ff 
801078d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d4:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801078db:	00 00 
801078dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e0:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801078e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ea:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078f1:	83 e2 f0             	and    $0xfffffff0,%edx
801078f4:	83 ca 02             	or     $0x2,%edx
801078f7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107900:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107907:	83 ca 10             	or     $0x10,%edx
8010790a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107913:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010791a:	83 e2 9f             	and    $0xffffff9f,%edx
8010791d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107926:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010792d:	83 ca 80             	or     $0xffffff80,%edx
80107930:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107939:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107940:	83 ca 0f             	or     $0xf,%edx
80107943:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107953:	83 e2 ef             	and    $0xffffffef,%edx
80107956:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010795c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107966:	83 e2 df             	and    $0xffffffdf,%edx
80107969:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010796f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107972:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107979:	83 ca 40             	or     $0x40,%edx
8010797c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107985:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010798c:	83 ca 80             	or     $0xffffff80,%edx
8010798f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107998:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010799f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a2:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801079a9:	ff ff 
801079ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ae:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801079b5:	00 00 
801079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ba:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801079c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079cb:	83 e2 f0             	and    $0xfffffff0,%edx
801079ce:	83 ca 0a             	or     $0xa,%edx
801079d1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079da:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079e1:	83 ca 10             	or     $0x10,%edx
801079e4:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ed:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079f4:	83 ca 60             	or     $0x60,%edx
801079f7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a00:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a07:	83 ca 80             	or     $0xffffff80,%edx
80107a0a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a13:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a1a:	83 ca 0f             	or     $0xf,%edx
80107a1d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a26:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a2d:	83 e2 ef             	and    $0xffffffef,%edx
80107a30:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a39:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a40:	83 e2 df             	and    $0xffffffdf,%edx
80107a43:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a53:	83 ca 40             	or     $0x40,%edx
80107a56:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a66:	83 ca 80             	or     $0xffffff80,%edx
80107a69:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a83:	ff ff 
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a8f:	00 00 
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107aa5:	83 e2 f0             	and    $0xfffffff0,%edx
80107aa8:	83 ca 02             	or     $0x2,%edx
80107aab:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107abb:	83 ca 10             	or     $0x10,%edx
80107abe:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ace:	83 ca 60             	or     $0x60,%edx
80107ad1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ada:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ae1:	83 ca 80             	or     $0xffffff80,%edx
80107ae4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aed:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107af4:	83 ca 0f             	or     $0xf,%edx
80107af7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b07:	83 e2 ef             	and    $0xffffffef,%edx
80107b0a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b13:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b1a:	83 e2 df             	and    $0xffffffdf,%edx
80107b1d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b26:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b2d:	83 ca 40             	or     $0x40,%edx
80107b30:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b40:	83 ca 80             	or     $0xffffff80,%edx
80107b43:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b56:	83 c0 70             	add    $0x70,%eax
80107b59:	83 ec 08             	sub    $0x8,%esp
80107b5c:	6a 30                	push   $0x30
80107b5e:	50                   	push   %eax
80107b5f:	e8 63 fc ff ff       	call   801077c7 <lgdt>
80107b64:	83 c4 10             	add    $0x10,%esp
}
80107b67:	90                   	nop
80107b68:	c9                   	leave  
80107b69:	c3                   	ret    

80107b6a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107b6a:	55                   	push   %ebp
80107b6b:	89 e5                	mov    %esp,%ebp
80107b6d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b73:	c1 e8 16             	shr    $0x16,%eax
80107b76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80107b80:	01 d0                	add    %edx,%eax
80107b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b88:	8b 00                	mov    (%eax),%eax
80107b8a:	83 e0 01             	and    $0x1,%eax
80107b8d:	85 c0                	test   %eax,%eax
80107b8f:	74 14                	je     80107ba5 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b94:	8b 00                	mov    (%eax),%eax
80107b96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b9b:	05 00 00 00 80       	add    $0x80000000,%eax
80107ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ba3:	eb 42                	jmp    80107be7 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ba5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ba9:	74 0e                	je     80107bb9 <walkpgdir+0x4f>
80107bab:	e8 d4 b0 ff ff       	call   80102c84 <kalloc>
80107bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bb3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107bb7:	75 07                	jne    80107bc0 <walkpgdir+0x56>
      return 0;
80107bb9:	b8 00 00 00 00       	mov    $0x0,%eax
80107bbe:	eb 3e                	jmp    80107bfe <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107bc0:	83 ec 04             	sub    $0x4,%esp
80107bc3:	68 00 10 00 00       	push   $0x1000
80107bc8:	6a 00                	push   $0x0
80107bca:	ff 75 f4             	push   -0xc(%ebp)
80107bcd:	e8 a6 d6 ff ff       	call   80105278 <memset>
80107bd2:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd8:	05 00 00 00 80       	add    $0x80000000,%eax
80107bdd:	83 c8 07             	or     $0x7,%eax
80107be0:	89 c2                	mov    %eax,%edx
80107be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be5:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107be7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bea:	c1 e8 0c             	shr    $0xc,%eax
80107bed:	25 ff 03 00 00       	and    $0x3ff,%eax
80107bf2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfc:	01 d0                	add    %edx,%eax
}
80107bfe:	c9                   	leave  
80107bff:	c3                   	ret    

80107c00 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107c00:	55                   	push   %ebp
80107c01:	89 e5                	mov    %esp,%ebp
80107c03:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107c06:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107c11:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c14:	8b 45 10             	mov    0x10(%ebp),%eax
80107c17:	01 d0                	add    %edx,%eax
80107c19:	83 e8 01             	sub    $0x1,%eax
80107c1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c24:	83 ec 04             	sub    $0x4,%esp
80107c27:	6a 01                	push   $0x1
80107c29:	ff 75 f4             	push   -0xc(%ebp)
80107c2c:	ff 75 08             	push   0x8(%ebp)
80107c2f:	e8 36 ff ff ff       	call   80107b6a <walkpgdir>
80107c34:	83 c4 10             	add    $0x10,%esp
80107c37:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c3a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c3e:	75 07                	jne    80107c47 <mappages+0x47>
      return -1;
80107c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c45:	eb 47                	jmp    80107c8e <mappages+0x8e>
    if(*pte & PTE_P)
80107c47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c4a:	8b 00                	mov    (%eax),%eax
80107c4c:	83 e0 01             	and    $0x1,%eax
80107c4f:	85 c0                	test   %eax,%eax
80107c51:	74 0d                	je     80107c60 <mappages+0x60>
      panic("remap");
80107c53:	83 ec 0c             	sub    $0xc,%esp
80107c56:	68 ac ae 10 80       	push   $0x8010aeac
80107c5b:	e8 49 89 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107c60:	8b 45 18             	mov    0x18(%ebp),%eax
80107c63:	0b 45 14             	or     0x14(%ebp),%eax
80107c66:	83 c8 01             	or     $0x1,%eax
80107c69:	89 c2                	mov    %eax,%edx
80107c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c6e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c73:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c76:	74 10                	je     80107c88 <mappages+0x88>
      break;
    a += PGSIZE;
80107c78:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c7f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c86:	eb 9c                	jmp    80107c24 <mappages+0x24>
      break;
80107c88:	90                   	nop
  }
  return 0;
80107c89:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c8e:	c9                   	leave  
80107c8f:	c3                   	ret    

80107c90 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107c90:	55                   	push   %ebp
80107c91:	89 e5                	mov    %esp,%ebp
80107c93:	53                   	push   %ebx
80107c94:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107c97:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107c9e:	8b 15 a0 a5 11 80    	mov    0x8011a5a0,%edx
80107ca4:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107ca9:	29 d0                	sub    %edx,%eax
80107cab:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107cae:	a1 98 a5 11 80       	mov    0x8011a598,%eax
80107cb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107cb6:	8b 15 98 a5 11 80    	mov    0x8011a598,%edx
80107cbc:	a1 a0 a5 11 80       	mov    0x8011a5a0,%eax
80107cc1:	01 d0                	add    %edx,%eax
80107cc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107cc6:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd0:	83 c0 30             	add    $0x30,%eax
80107cd3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107cd6:	89 10                	mov    %edx,(%eax)
80107cd8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107cdb:	89 50 04             	mov    %edx,0x4(%eax)
80107cde:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107ce1:	89 50 08             	mov    %edx,0x8(%eax)
80107ce4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107ce7:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107cea:	e8 95 af ff ff       	call   80102c84 <kalloc>
80107cef:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cf2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cf6:	75 07                	jne    80107cff <setupkvm+0x6f>
    return 0;
80107cf8:	b8 00 00 00 00       	mov    $0x0,%eax
80107cfd:	eb 78                	jmp    80107d77 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107cff:	83 ec 04             	sub    $0x4,%esp
80107d02:	68 00 10 00 00       	push   $0x1000
80107d07:	6a 00                	push   $0x0
80107d09:	ff 75 f0             	push   -0x10(%ebp)
80107d0c:	e8 67 d5 ff ff       	call   80105278 <memset>
80107d11:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d14:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107d1b:	eb 4e                	jmp    80107d6b <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d20:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d26:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2c:	8b 58 08             	mov    0x8(%eax),%ebx
80107d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d32:	8b 40 04             	mov    0x4(%eax),%eax
80107d35:	29 c3                	sub    %eax,%ebx
80107d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3a:	8b 00                	mov    (%eax),%eax
80107d3c:	83 ec 0c             	sub    $0xc,%esp
80107d3f:	51                   	push   %ecx
80107d40:	52                   	push   %edx
80107d41:	53                   	push   %ebx
80107d42:	50                   	push   %eax
80107d43:	ff 75 f0             	push   -0x10(%ebp)
80107d46:	e8 b5 fe ff ff       	call   80107c00 <mappages>
80107d4b:	83 c4 20             	add    $0x20,%esp
80107d4e:	85 c0                	test   %eax,%eax
80107d50:	79 15                	jns    80107d67 <setupkvm+0xd7>
      freevm(pgdir);
80107d52:	83 ec 0c             	sub    $0xc,%esp
80107d55:	ff 75 f0             	push   -0x10(%ebp)
80107d58:	e8 f5 04 00 00       	call   80108252 <freevm>
80107d5d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d60:	b8 00 00 00 00       	mov    $0x0,%eax
80107d65:	eb 10                	jmp    80107d77 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d67:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d6b:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107d72:	72 a9                	jb     80107d1d <setupkvm+0x8d>
    }
  return pgdir;
80107d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d7a:	c9                   	leave  
80107d7b:	c3                   	ret    

80107d7c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d7c:	55                   	push   %ebp
80107d7d:	89 e5                	mov    %esp,%ebp
80107d7f:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d82:	e8 09 ff ff ff       	call   80107c90 <setupkvm>
80107d87:	a3 bc a2 11 80       	mov    %eax,0x8011a2bc
  switchkvm();
80107d8c:	e8 03 00 00 00       	call   80107d94 <switchkvm>
}
80107d91:	90                   	nop
80107d92:	c9                   	leave  
80107d93:	c3                   	ret    

80107d94 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d94:	55                   	push   %ebp
80107d95:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107d97:	a1 bc a2 11 80       	mov    0x8011a2bc,%eax
80107d9c:	05 00 00 00 80       	add    $0x80000000,%eax
80107da1:	50                   	push   %eax
80107da2:	e8 61 fa ff ff       	call   80107808 <lcr3>
80107da7:	83 c4 04             	add    $0x4,%esp
}
80107daa:	90                   	nop
80107dab:	c9                   	leave  
80107dac:	c3                   	ret    

80107dad <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107dad:	55                   	push   %ebp
80107dae:	89 e5                	mov    %esp,%ebp
80107db0:	56                   	push   %esi
80107db1:	53                   	push   %ebx
80107db2:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107db5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107db9:	75 0d                	jne    80107dc8 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107dbb:	83 ec 0c             	sub    $0xc,%esp
80107dbe:	68 b2 ae 10 80       	push   $0x8010aeb2
80107dc3:	e8 e1 87 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80107dcb:	8b 40 08             	mov    0x8(%eax),%eax
80107dce:	85 c0                	test   %eax,%eax
80107dd0:	75 0d                	jne    80107ddf <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107dd2:	83 ec 0c             	sub    $0xc,%esp
80107dd5:	68 c8 ae 10 80       	push   $0x8010aec8
80107dda:	e8 ca 87 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80107de2:	8b 40 04             	mov    0x4(%eax),%eax
80107de5:	85 c0                	test   %eax,%eax
80107de7:	75 0d                	jne    80107df6 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107de9:	83 ec 0c             	sub    $0xc,%esp
80107dec:	68 dd ae 10 80       	push   $0x8010aedd
80107df1:	e8 b3 87 ff ff       	call   801005a9 <panic>

  pushcli();
80107df6:	e8 72 d3 ff ff       	call   8010516d <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107dfb:	e8 9c c0 ff ff       	call   80103e9c <mycpu>
80107e00:	89 c3                	mov    %eax,%ebx
80107e02:	e8 95 c0 ff ff       	call   80103e9c <mycpu>
80107e07:	83 c0 08             	add    $0x8,%eax
80107e0a:	89 c6                	mov    %eax,%esi
80107e0c:	e8 8b c0 ff ff       	call   80103e9c <mycpu>
80107e11:	83 c0 08             	add    $0x8,%eax
80107e14:	c1 e8 10             	shr    $0x10,%eax
80107e17:	88 45 f7             	mov    %al,-0x9(%ebp)
80107e1a:	e8 7d c0 ff ff       	call   80103e9c <mycpu>
80107e1f:	83 c0 08             	add    $0x8,%eax
80107e22:	c1 e8 18             	shr    $0x18,%eax
80107e25:	89 c2                	mov    %eax,%edx
80107e27:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107e2e:	67 00 
80107e30:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107e37:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107e3b:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107e41:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e48:	83 e0 f0             	and    $0xfffffff0,%eax
80107e4b:	83 c8 09             	or     $0x9,%eax
80107e4e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e54:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e5b:	83 c8 10             	or     $0x10,%eax
80107e5e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e64:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e6b:	83 e0 9f             	and    $0xffffff9f,%eax
80107e6e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e74:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e7b:	83 c8 80             	or     $0xffffff80,%eax
80107e7e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e84:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e8b:	83 e0 f0             	and    $0xfffffff0,%eax
80107e8e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e94:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e9b:	83 e0 ef             	and    $0xffffffef,%eax
80107e9e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ea4:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107eab:	83 e0 df             	and    $0xffffffdf,%eax
80107eae:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107eb4:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ebb:	83 c8 40             	or     $0x40,%eax
80107ebe:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ec4:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ecb:	83 e0 7f             	and    $0x7f,%eax
80107ece:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ed4:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107eda:	e8 bd bf ff ff       	call   80103e9c <mycpu>
80107edf:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ee6:	83 e2 ef             	and    $0xffffffef,%edx
80107ee9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107eef:	e8 a8 bf ff ff       	call   80103e9c <mycpu>
80107ef4:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107efa:	8b 45 08             	mov    0x8(%ebp),%eax
80107efd:	8b 40 08             	mov    0x8(%eax),%eax
80107f00:	89 c3                	mov    %eax,%ebx
80107f02:	e8 95 bf ff ff       	call   80103e9c <mycpu>
80107f07:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107f0d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107f10:	e8 87 bf ff ff       	call   80103e9c <mycpu>
80107f15:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107f1b:	83 ec 0c             	sub    $0xc,%esp
80107f1e:	6a 28                	push   $0x28
80107f20:	e8 cc f8 ff ff       	call   801077f1 <ltr>
80107f25:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107f28:	8b 45 08             	mov    0x8(%ebp),%eax
80107f2b:	8b 40 04             	mov    0x4(%eax),%eax
80107f2e:	05 00 00 00 80       	add    $0x80000000,%eax
80107f33:	83 ec 0c             	sub    $0xc,%esp
80107f36:	50                   	push   %eax
80107f37:	e8 cc f8 ff ff       	call   80107808 <lcr3>
80107f3c:	83 c4 10             	add    $0x10,%esp
  popcli();
80107f3f:	e8 76 d2 ff ff       	call   801051ba <popcli>
}
80107f44:	90                   	nop
80107f45:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107f48:	5b                   	pop    %ebx
80107f49:	5e                   	pop    %esi
80107f4a:	5d                   	pop    %ebp
80107f4b:	c3                   	ret    

80107f4c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107f4c:	55                   	push   %ebp
80107f4d:	89 e5                	mov    %esp,%ebp
80107f4f:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107f52:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107f59:	76 0d                	jbe    80107f68 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107f5b:	83 ec 0c             	sub    $0xc,%esp
80107f5e:	68 f1 ae 10 80       	push   $0x8010aef1
80107f63:	e8 41 86 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107f68:	e8 17 ad ff ff       	call   80102c84 <kalloc>
80107f6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f70:	83 ec 04             	sub    $0x4,%esp
80107f73:	68 00 10 00 00       	push   $0x1000
80107f78:	6a 00                	push   $0x0
80107f7a:	ff 75 f4             	push   -0xc(%ebp)
80107f7d:	e8 f6 d2 ff ff       	call   80105278 <memset>
80107f82:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f88:	05 00 00 00 80       	add    $0x80000000,%eax
80107f8d:	83 ec 0c             	sub    $0xc,%esp
80107f90:	6a 06                	push   $0x6
80107f92:	50                   	push   %eax
80107f93:	68 00 10 00 00       	push   $0x1000
80107f98:	6a 00                	push   $0x0
80107f9a:	ff 75 08             	push   0x8(%ebp)
80107f9d:	e8 5e fc ff ff       	call   80107c00 <mappages>
80107fa2:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107fa5:	83 ec 04             	sub    $0x4,%esp
80107fa8:	ff 75 10             	push   0x10(%ebp)
80107fab:	ff 75 0c             	push   0xc(%ebp)
80107fae:	ff 75 f4             	push   -0xc(%ebp)
80107fb1:	e8 81 d3 ff ff       	call   80105337 <memmove>
80107fb6:	83 c4 10             	add    $0x10,%esp
}
80107fb9:	90                   	nop
80107fba:	c9                   	leave  
80107fbb:	c3                   	ret    

80107fbc <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107fbc:	55                   	push   %ebp
80107fbd:	89 e5                	mov    %esp,%ebp
80107fbf:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc5:	25 ff 0f 00 00       	and    $0xfff,%eax
80107fca:	85 c0                	test   %eax,%eax
80107fcc:	74 0d                	je     80107fdb <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107fce:	83 ec 0c             	sub    $0xc,%esp
80107fd1:	68 0c af 10 80       	push   $0x8010af0c
80107fd6:	e8 ce 85 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107fdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fe2:	e9 8f 00 00 00       	jmp    80108076 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107fe7:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fed:	01 d0                	add    %edx,%eax
80107fef:	83 ec 04             	sub    $0x4,%esp
80107ff2:	6a 00                	push   $0x0
80107ff4:	50                   	push   %eax
80107ff5:	ff 75 08             	push   0x8(%ebp)
80107ff8:	e8 6d fb ff ff       	call   80107b6a <walkpgdir>
80107ffd:	83 c4 10             	add    $0x10,%esp
80108000:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108003:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108007:	75 0d                	jne    80108016 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80108009:	83 ec 0c             	sub    $0xc,%esp
8010800c:	68 2f af 10 80       	push   $0x8010af2f
80108011:	e8 93 85 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80108016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108019:	8b 00                	mov    (%eax),%eax
8010801b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108020:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108023:	8b 45 18             	mov    0x18(%ebp),%eax
80108026:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108029:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010802e:	77 0b                	ja     8010803b <loaduvm+0x7f>
      n = sz - i;
80108030:	8b 45 18             	mov    0x18(%ebp),%eax
80108033:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108036:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108039:	eb 07                	jmp    80108042 <loaduvm+0x86>
    else
      n = PGSIZE;
8010803b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108042:	8b 55 14             	mov    0x14(%ebp),%edx
80108045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108048:	01 d0                	add    %edx,%eax
8010804a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010804d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108053:	ff 75 f0             	push   -0x10(%ebp)
80108056:	50                   	push   %eax
80108057:	52                   	push   %edx
80108058:	ff 75 10             	push   0x10(%ebp)
8010805b:	e8 76 9e ff ff       	call   80101ed6 <readi>
80108060:	83 c4 10             	add    $0x10,%esp
80108063:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108066:	74 07                	je     8010806f <loaduvm+0xb3>
      return -1;
80108068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010806d:	eb 18                	jmp    80108087 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
8010806f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108079:	3b 45 18             	cmp    0x18(%ebp),%eax
8010807c:	0f 82 65 ff ff ff    	jb     80107fe7 <loaduvm+0x2b>
  }
  return 0;
80108082:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108087:	c9                   	leave  
80108088:	c3                   	ret    

80108089 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108089:	55                   	push   %ebp
8010808a:	89 e5                	mov    %esp,%ebp
8010808c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010808f:	8b 45 10             	mov    0x10(%ebp),%eax
80108092:	85 c0                	test   %eax,%eax
80108094:	79 0a                	jns    801080a0 <allocuvm+0x17>
    return 0;
80108096:	b8 00 00 00 00       	mov    $0x0,%eax
8010809b:	e9 ec 00 00 00       	jmp    8010818c <allocuvm+0x103>
  if(newsz < oldsz)
801080a0:	8b 45 10             	mov    0x10(%ebp),%eax
801080a3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080a6:	73 08                	jae    801080b0 <allocuvm+0x27>
    return oldsz;
801080a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801080ab:	e9 dc 00 00 00       	jmp    8010818c <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801080b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b3:	05 ff 0f 00 00       	add    $0xfff,%eax
801080b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801080c0:	e9 b8 00 00 00       	jmp    8010817d <allocuvm+0xf4>
    mem = kalloc();
801080c5:	e8 ba ab ff ff       	call   80102c84 <kalloc>
801080ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801080cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080d1:	75 2e                	jne    80108101 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
801080d3:	83 ec 0c             	sub    $0xc,%esp
801080d6:	68 4d af 10 80       	push   $0x8010af4d
801080db:	e8 14 83 ff ff       	call   801003f4 <cprintf>
801080e0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801080e3:	83 ec 04             	sub    $0x4,%esp
801080e6:	ff 75 0c             	push   0xc(%ebp)
801080e9:	ff 75 10             	push   0x10(%ebp)
801080ec:	ff 75 08             	push   0x8(%ebp)
801080ef:	e8 9a 00 00 00       	call   8010818e <deallocuvm>
801080f4:	83 c4 10             	add    $0x10,%esp
      return 0;
801080f7:	b8 00 00 00 00       	mov    $0x0,%eax
801080fc:	e9 8b 00 00 00       	jmp    8010818c <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80108101:	83 ec 04             	sub    $0x4,%esp
80108104:	68 00 10 00 00       	push   $0x1000
80108109:	6a 00                	push   $0x0
8010810b:	ff 75 f0             	push   -0x10(%ebp)
8010810e:	e8 65 d1 ff ff       	call   80105278 <memset>
80108113:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108119:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010811f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108122:	83 ec 0c             	sub    $0xc,%esp
80108125:	6a 06                	push   $0x6
80108127:	52                   	push   %edx
80108128:	68 00 10 00 00       	push   $0x1000
8010812d:	50                   	push   %eax
8010812e:	ff 75 08             	push   0x8(%ebp)
80108131:	e8 ca fa ff ff       	call   80107c00 <mappages>
80108136:	83 c4 20             	add    $0x20,%esp
80108139:	85 c0                	test   %eax,%eax
8010813b:	79 39                	jns    80108176 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010813d:	83 ec 0c             	sub    $0xc,%esp
80108140:	68 65 af 10 80       	push   $0x8010af65
80108145:	e8 aa 82 ff ff       	call   801003f4 <cprintf>
8010814a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010814d:	83 ec 04             	sub    $0x4,%esp
80108150:	ff 75 0c             	push   0xc(%ebp)
80108153:	ff 75 10             	push   0x10(%ebp)
80108156:	ff 75 08             	push   0x8(%ebp)
80108159:	e8 30 00 00 00       	call   8010818e <deallocuvm>
8010815e:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108161:	83 ec 0c             	sub    $0xc,%esp
80108164:	ff 75 f0             	push   -0x10(%ebp)
80108167:	e8 7e aa ff ff       	call   80102bea <kfree>
8010816c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010816f:	b8 00 00 00 00       	mov    $0x0,%eax
80108174:	eb 16                	jmp    8010818c <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80108176:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010817d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108180:	3b 45 10             	cmp    0x10(%ebp),%eax
80108183:	0f 82 3c ff ff ff    	jb     801080c5 <allocuvm+0x3c>
    }
  }
  return newsz;
80108189:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010818c:	c9                   	leave  
8010818d:	c3                   	ret    

8010818e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010818e:	55                   	push   %ebp
8010818f:	89 e5                	mov    %esp,%ebp
80108191:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108194:	8b 45 10             	mov    0x10(%ebp),%eax
80108197:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010819a:	72 08                	jb     801081a4 <deallocuvm+0x16>
    return oldsz;
8010819c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010819f:	e9 ac 00 00 00       	jmp    80108250 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801081a4:	8b 45 10             	mov    0x10(%ebp),%eax
801081a7:	05 ff 0f 00 00       	add    $0xfff,%eax
801081ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801081b4:	e9 88 00 00 00       	jmp    80108241 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801081b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bc:	83 ec 04             	sub    $0x4,%esp
801081bf:	6a 00                	push   $0x0
801081c1:	50                   	push   %eax
801081c2:	ff 75 08             	push   0x8(%ebp)
801081c5:	e8 a0 f9 ff ff       	call   80107b6a <walkpgdir>
801081ca:	83 c4 10             	add    $0x10,%esp
801081cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801081d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081d4:	75 16                	jne    801081ec <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801081d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d9:	c1 e8 16             	shr    $0x16,%eax
801081dc:	83 c0 01             	add    $0x1,%eax
801081df:	c1 e0 16             	shl    $0x16,%eax
801081e2:	2d 00 10 00 00       	sub    $0x1000,%eax
801081e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801081ea:	eb 4e                	jmp    8010823a <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801081ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ef:	8b 00                	mov    (%eax),%eax
801081f1:	83 e0 01             	and    $0x1,%eax
801081f4:	85 c0                	test   %eax,%eax
801081f6:	74 42                	je     8010823a <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801081f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081fb:	8b 00                	mov    (%eax),%eax
801081fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108202:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108205:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108209:	75 0d                	jne    80108218 <deallocuvm+0x8a>
        panic("kfree");
8010820b:	83 ec 0c             	sub    $0xc,%esp
8010820e:	68 81 af 10 80       	push   $0x8010af81
80108213:	e8 91 83 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80108218:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010821b:	05 00 00 00 80       	add    $0x80000000,%eax
80108220:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108223:	83 ec 0c             	sub    $0xc,%esp
80108226:	ff 75 e8             	push   -0x18(%ebp)
80108229:	e8 bc a9 ff ff       	call   80102bea <kfree>
8010822e:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108234:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010823a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108244:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108247:	0f 82 6c ff ff ff    	jb     801081b9 <deallocuvm+0x2b>
    }
  }
  return newsz;
8010824d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108250:	c9                   	leave  
80108251:	c3                   	ret    

80108252 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108252:	55                   	push   %ebp
80108253:	89 e5                	mov    %esp,%ebp
80108255:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108258:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010825c:	75 0d                	jne    8010826b <freevm+0x19>
    panic("freevm: no pgdir");
8010825e:	83 ec 0c             	sub    $0xc,%esp
80108261:	68 87 af 10 80       	push   $0x8010af87
80108266:	e8 3e 83 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010826b:	83 ec 04             	sub    $0x4,%esp
8010826e:	6a 00                	push   $0x0
80108270:	68 00 00 00 80       	push   $0x80000000
80108275:	ff 75 08             	push   0x8(%ebp)
80108278:	e8 11 ff ff ff       	call   8010818e <deallocuvm>
8010827d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108280:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108287:	eb 48                	jmp    801082d1 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108289:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108293:	8b 45 08             	mov    0x8(%ebp),%eax
80108296:	01 d0                	add    %edx,%eax
80108298:	8b 00                	mov    (%eax),%eax
8010829a:	83 e0 01             	and    $0x1,%eax
8010829d:	85 c0                	test   %eax,%eax
8010829f:	74 2c                	je     801082cd <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801082a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082ab:	8b 45 08             	mov    0x8(%ebp),%eax
801082ae:	01 d0                	add    %edx,%eax
801082b0:	8b 00                	mov    (%eax),%eax
801082b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082b7:	05 00 00 00 80       	add    $0x80000000,%eax
801082bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801082bf:	83 ec 0c             	sub    $0xc,%esp
801082c2:	ff 75 f0             	push   -0x10(%ebp)
801082c5:	e8 20 a9 ff ff       	call   80102bea <kfree>
801082ca:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801082cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082d1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801082d8:	76 af                	jbe    80108289 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801082da:	83 ec 0c             	sub    $0xc,%esp
801082dd:	ff 75 08             	push   0x8(%ebp)
801082e0:	e8 05 a9 ff ff       	call   80102bea <kfree>
801082e5:	83 c4 10             	add    $0x10,%esp
}
801082e8:	90                   	nop
801082e9:	c9                   	leave  
801082ea:	c3                   	ret    

801082eb <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801082eb:	55                   	push   %ebp
801082ec:	89 e5                	mov    %esp,%ebp
801082ee:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801082f1:	83 ec 04             	sub    $0x4,%esp
801082f4:	6a 00                	push   $0x0
801082f6:	ff 75 0c             	push   0xc(%ebp)
801082f9:	ff 75 08             	push   0x8(%ebp)
801082fc:	e8 69 f8 ff ff       	call   80107b6a <walkpgdir>
80108301:	83 c4 10             	add    $0x10,%esp
80108304:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108307:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010830b:	75 0d                	jne    8010831a <clearpteu+0x2f>
    panic("clearpteu");
8010830d:	83 ec 0c             	sub    $0xc,%esp
80108310:	68 98 af 10 80       	push   $0x8010af98
80108315:	e8 8f 82 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
8010831a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831d:	8b 00                	mov    (%eax),%eax
8010831f:	83 e0 fb             	and    $0xfffffffb,%eax
80108322:	89 c2                	mov    %eax,%edx
80108324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108327:	89 10                	mov    %edx,(%eax)
}
80108329:	90                   	nop
8010832a:	c9                   	leave  
8010832b:	c3                   	ret    

8010832c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010832c:	55                   	push   %ebp
8010832d:	89 e5                	mov    %esp,%ebp
8010832f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108332:	e8 59 f9 ff ff       	call   80107c90 <setupkvm>
80108337:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010833a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010833e:	75 0a                	jne    8010834a <copyuvm+0x1e>
    return 0;
80108340:	b8 00 00 00 00       	mov    $0x0,%eax
80108345:	e9 eb 00 00 00       	jmp    80108435 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
8010834a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108351:	e9 b7 00 00 00       	jmp    8010840d <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108359:	83 ec 04             	sub    $0x4,%esp
8010835c:	6a 00                	push   $0x0
8010835e:	50                   	push   %eax
8010835f:	ff 75 08             	push   0x8(%ebp)
80108362:	e8 03 f8 ff ff       	call   80107b6a <walkpgdir>
80108367:	83 c4 10             	add    $0x10,%esp
8010836a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010836d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108371:	75 0d                	jne    80108380 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108373:	83 ec 0c             	sub    $0xc,%esp
80108376:	68 a2 af 10 80       	push   $0x8010afa2
8010837b:	e8 29 82 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80108380:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108383:	8b 00                	mov    (%eax),%eax
80108385:	83 e0 01             	and    $0x1,%eax
80108388:	85 c0                	test   %eax,%eax
8010838a:	75 0d                	jne    80108399 <copyuvm+0x6d>
      panic("copyuvm: page not present");
8010838c:	83 ec 0c             	sub    $0xc,%esp
8010838f:	68 bc af 10 80       	push   $0x8010afbc
80108394:	e8 10 82 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80108399:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010839c:	8b 00                	mov    (%eax),%eax
8010839e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801083a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a9:	8b 00                	mov    (%eax),%eax
801083ab:	25 ff 0f 00 00       	and    $0xfff,%eax
801083b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801083b3:	e8 cc a8 ff ff       	call   80102c84 <kalloc>
801083b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801083bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801083bf:	74 5d                	je     8010841e <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801083c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083c4:	05 00 00 00 80       	add    $0x80000000,%eax
801083c9:	83 ec 04             	sub    $0x4,%esp
801083cc:	68 00 10 00 00       	push   $0x1000
801083d1:	50                   	push   %eax
801083d2:	ff 75 e0             	push   -0x20(%ebp)
801083d5:	e8 5d cf ff ff       	call   80105337 <memmove>
801083da:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801083dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801083e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801083e3:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801083e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ec:	83 ec 0c             	sub    $0xc,%esp
801083ef:	52                   	push   %edx
801083f0:	51                   	push   %ecx
801083f1:	68 00 10 00 00       	push   $0x1000
801083f6:	50                   	push   %eax
801083f7:	ff 75 f0             	push   -0x10(%ebp)
801083fa:	e8 01 f8 ff ff       	call   80107c00 <mappages>
801083ff:	83 c4 20             	add    $0x20,%esp
80108402:	85 c0                	test   %eax,%eax
80108404:	78 1b                	js     80108421 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80108406:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010840d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108410:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108413:	0f 82 3d ff ff ff    	jb     80108356 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80108419:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010841c:	eb 17                	jmp    80108435 <copyuvm+0x109>
      goto bad;
8010841e:	90                   	nop
8010841f:	eb 01                	jmp    80108422 <copyuvm+0xf6>
      goto bad;
80108421:	90                   	nop

bad:
  freevm(d);
80108422:	83 ec 0c             	sub    $0xc,%esp
80108425:	ff 75 f0             	push   -0x10(%ebp)
80108428:	e8 25 fe ff ff       	call   80108252 <freevm>
8010842d:	83 c4 10             	add    $0x10,%esp
  return 0;
80108430:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108435:	c9                   	leave  
80108436:	c3                   	ret    

80108437 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108437:	55                   	push   %ebp
80108438:	89 e5                	mov    %esp,%ebp
8010843a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010843d:	83 ec 04             	sub    $0x4,%esp
80108440:	6a 00                	push   $0x0
80108442:	ff 75 0c             	push   0xc(%ebp)
80108445:	ff 75 08             	push   0x8(%ebp)
80108448:	e8 1d f7 ff ff       	call   80107b6a <walkpgdir>
8010844d:	83 c4 10             	add    $0x10,%esp
80108450:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108456:	8b 00                	mov    (%eax),%eax
80108458:	83 e0 01             	and    $0x1,%eax
8010845b:	85 c0                	test   %eax,%eax
8010845d:	75 07                	jne    80108466 <uva2ka+0x2f>
    return 0;
8010845f:	b8 00 00 00 00       	mov    $0x0,%eax
80108464:	eb 22                	jmp    80108488 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108469:	8b 00                	mov    (%eax),%eax
8010846b:	83 e0 04             	and    $0x4,%eax
8010846e:	85 c0                	test   %eax,%eax
80108470:	75 07                	jne    80108479 <uva2ka+0x42>
    return 0;
80108472:	b8 00 00 00 00       	mov    $0x0,%eax
80108477:	eb 0f                	jmp    80108488 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847c:	8b 00                	mov    (%eax),%eax
8010847e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108483:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108488:	c9                   	leave  
80108489:	c3                   	ret    

8010848a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010848a:	55                   	push   %ebp
8010848b:	89 e5                	mov    %esp,%ebp
8010848d:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108490:	8b 45 10             	mov    0x10(%ebp),%eax
80108493:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108496:	eb 7f                	jmp    80108517 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108498:	8b 45 0c             	mov    0xc(%ebp),%eax
8010849b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801084a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084a6:	83 ec 08             	sub    $0x8,%esp
801084a9:	50                   	push   %eax
801084aa:	ff 75 08             	push   0x8(%ebp)
801084ad:	e8 85 ff ff ff       	call   80108437 <uva2ka>
801084b2:	83 c4 10             	add    $0x10,%esp
801084b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801084b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801084bc:	75 07                	jne    801084c5 <copyout+0x3b>
      return -1;
801084be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801084c3:	eb 61                	jmp    80108526 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801084c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084c8:	2b 45 0c             	sub    0xc(%ebp),%eax
801084cb:	05 00 10 00 00       	add    $0x1000,%eax
801084d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801084d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084d6:	3b 45 14             	cmp    0x14(%ebp),%eax
801084d9:	76 06                	jbe    801084e1 <copyout+0x57>
      n = len;
801084db:	8b 45 14             	mov    0x14(%ebp),%eax
801084de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801084e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801084e4:	2b 45 ec             	sub    -0x14(%ebp),%eax
801084e7:	89 c2                	mov    %eax,%edx
801084e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084ec:	01 d0                	add    %edx,%eax
801084ee:	83 ec 04             	sub    $0x4,%esp
801084f1:	ff 75 f0             	push   -0x10(%ebp)
801084f4:	ff 75 f4             	push   -0xc(%ebp)
801084f7:	50                   	push   %eax
801084f8:	e8 3a ce ff ff       	call   80105337 <memmove>
801084fd:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108503:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108509:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010850c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010850f:	05 00 10 00 00       	add    $0x1000,%eax
80108514:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108517:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010851b:	0f 85 77 ff ff ff    	jne    80108498 <copyout+0xe>
  }
  return 0;
80108521:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108526:	c9                   	leave  
80108527:	c3                   	ret    

80108528 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108528:	55                   	push   %ebp
80108529:	89 e5                	mov    %esp,%ebp
8010852b:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010852e:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108535:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108538:	8b 40 08             	mov    0x8(%eax),%eax
8010853b:	05 00 00 00 80       	add    $0x80000000,%eax
80108540:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108543:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010854a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854d:	8b 40 24             	mov    0x24(%eax),%eax
80108550:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
80108555:	c7 05 90 a5 11 80 00 	movl   $0x0,0x8011a590
8010855c:	00 00 00 

  while(i<madt->len){
8010855f:	90                   	nop
80108560:	e9 bd 00 00 00       	jmp    80108622 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108565:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108568:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010856b:	01 d0                	add    %edx,%eax
8010856d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108573:	0f b6 00             	movzbl (%eax),%eax
80108576:	0f b6 c0             	movzbl %al,%eax
80108579:	83 f8 05             	cmp    $0x5,%eax
8010857c:	0f 87 a0 00 00 00    	ja     80108622 <mpinit_uefi+0xfa>
80108582:	8b 04 85 d8 af 10 80 	mov    -0x7fef5028(,%eax,4),%eax
80108589:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010858b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010858e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108591:	a1 90 a5 11 80       	mov    0x8011a590,%eax
80108596:	83 f8 03             	cmp    $0x3,%eax
80108599:	7f 28                	jg     801085c3 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010859b:	8b 15 90 a5 11 80    	mov    0x8011a590,%edx
801085a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801085a4:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801085a8:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801085ae:	81 c2 c0 a2 11 80    	add    $0x8011a2c0,%edx
801085b4:	88 02                	mov    %al,(%edx)
          ncpu++;
801085b6:	a1 90 a5 11 80       	mov    0x8011a590,%eax
801085bb:	83 c0 01             	add    $0x1,%eax
801085be:	a3 90 a5 11 80       	mov    %eax,0x8011a590
        }
        i += lapic_entry->record_len;
801085c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801085c6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801085ca:	0f b6 c0             	movzbl %al,%eax
801085cd:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801085d0:	eb 50                	jmp    80108622 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801085d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801085d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085db:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801085df:	a2 94 a5 11 80       	mov    %al,0x8011a594
        i += ioapic->record_len;
801085e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085e7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801085eb:	0f b6 c0             	movzbl %al,%eax
801085ee:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801085f1:	eb 2f                	jmp    80108622 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801085f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801085f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085fc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108600:	0f b6 c0             	movzbl %al,%eax
80108603:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108606:	eb 1a                	jmp    80108622 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108608:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010860b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010860e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108611:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108615:	0f b6 c0             	movzbl %al,%eax
80108618:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010861b:	eb 05                	jmp    80108622 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
8010861d:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108621:	90                   	nop
  while(i<madt->len){
80108622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108625:	8b 40 04             	mov    0x4(%eax),%eax
80108628:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010862b:	0f 82 34 ff ff ff    	jb     80108565 <mpinit_uefi+0x3d>
    }
  }

}
80108631:	90                   	nop
80108632:	90                   	nop
80108633:	c9                   	leave  
80108634:	c3                   	ret    

80108635 <inb>:
{
80108635:	55                   	push   %ebp
80108636:	89 e5                	mov    %esp,%ebp
80108638:	83 ec 14             	sub    $0x14,%esp
8010863b:	8b 45 08             	mov    0x8(%ebp),%eax
8010863e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108642:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108646:	89 c2                	mov    %eax,%edx
80108648:	ec                   	in     (%dx),%al
80108649:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010864c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108650:	c9                   	leave  
80108651:	c3                   	ret    

80108652 <outb>:
{
80108652:	55                   	push   %ebp
80108653:	89 e5                	mov    %esp,%ebp
80108655:	83 ec 08             	sub    $0x8,%esp
80108658:	8b 45 08             	mov    0x8(%ebp),%eax
8010865b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010865e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108662:	89 d0                	mov    %edx,%eax
80108664:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108667:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010866b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010866f:	ee                   	out    %al,(%dx)
}
80108670:	90                   	nop
80108671:	c9                   	leave  
80108672:	c3                   	ret    

80108673 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108673:	55                   	push   %ebp
80108674:	89 e5                	mov    %esp,%ebp
80108676:	83 ec 28             	sub    $0x28,%esp
80108679:	8b 45 08             	mov    0x8(%ebp),%eax
8010867c:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010867f:	6a 00                	push   $0x0
80108681:	68 fa 03 00 00       	push   $0x3fa
80108686:	e8 c7 ff ff ff       	call   80108652 <outb>
8010868b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010868e:	68 80 00 00 00       	push   $0x80
80108693:	68 fb 03 00 00       	push   $0x3fb
80108698:	e8 b5 ff ff ff       	call   80108652 <outb>
8010869d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801086a0:	6a 0c                	push   $0xc
801086a2:	68 f8 03 00 00       	push   $0x3f8
801086a7:	e8 a6 ff ff ff       	call   80108652 <outb>
801086ac:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801086af:	6a 00                	push   $0x0
801086b1:	68 f9 03 00 00       	push   $0x3f9
801086b6:	e8 97 ff ff ff       	call   80108652 <outb>
801086bb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801086be:	6a 03                	push   $0x3
801086c0:	68 fb 03 00 00       	push   $0x3fb
801086c5:	e8 88 ff ff ff       	call   80108652 <outb>
801086ca:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801086cd:	6a 00                	push   $0x0
801086cf:	68 fc 03 00 00       	push   $0x3fc
801086d4:	e8 79 ff ff ff       	call   80108652 <outb>
801086d9:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801086dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086e3:	eb 11                	jmp    801086f6 <uart_debug+0x83>
801086e5:	83 ec 0c             	sub    $0xc,%esp
801086e8:	6a 0a                	push   $0xa
801086ea:	e8 2c a9 ff ff       	call   8010301b <microdelay>
801086ef:	83 c4 10             	add    $0x10,%esp
801086f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086f6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801086fa:	7f 1a                	jg     80108716 <uart_debug+0xa3>
801086fc:	83 ec 0c             	sub    $0xc,%esp
801086ff:	68 fd 03 00 00       	push   $0x3fd
80108704:	e8 2c ff ff ff       	call   80108635 <inb>
80108709:	83 c4 10             	add    $0x10,%esp
8010870c:	0f b6 c0             	movzbl %al,%eax
8010870f:	83 e0 20             	and    $0x20,%eax
80108712:	85 c0                	test   %eax,%eax
80108714:	74 cf                	je     801086e5 <uart_debug+0x72>
  outb(COM1+0, p);
80108716:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010871a:	0f b6 c0             	movzbl %al,%eax
8010871d:	83 ec 08             	sub    $0x8,%esp
80108720:	50                   	push   %eax
80108721:	68 f8 03 00 00       	push   $0x3f8
80108726:	e8 27 ff ff ff       	call   80108652 <outb>
8010872b:	83 c4 10             	add    $0x10,%esp
}
8010872e:	90                   	nop
8010872f:	c9                   	leave  
80108730:	c3                   	ret    

80108731 <uart_debugs>:

void uart_debugs(char *p){
80108731:	55                   	push   %ebp
80108732:	89 e5                	mov    %esp,%ebp
80108734:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108737:	eb 1b                	jmp    80108754 <uart_debugs+0x23>
    uart_debug(*p++);
80108739:	8b 45 08             	mov    0x8(%ebp),%eax
8010873c:	8d 50 01             	lea    0x1(%eax),%edx
8010873f:	89 55 08             	mov    %edx,0x8(%ebp)
80108742:	0f b6 00             	movzbl (%eax),%eax
80108745:	0f be c0             	movsbl %al,%eax
80108748:	83 ec 0c             	sub    $0xc,%esp
8010874b:	50                   	push   %eax
8010874c:	e8 22 ff ff ff       	call   80108673 <uart_debug>
80108751:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108754:	8b 45 08             	mov    0x8(%ebp),%eax
80108757:	0f b6 00             	movzbl (%eax),%eax
8010875a:	84 c0                	test   %al,%al
8010875c:	75 db                	jne    80108739 <uart_debugs+0x8>
  }
}
8010875e:	90                   	nop
8010875f:	90                   	nop
80108760:	c9                   	leave  
80108761:	c3                   	ret    

80108762 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108762:	55                   	push   %ebp
80108763:	89 e5                	mov    %esp,%ebp
80108765:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108768:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010876f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108772:	8b 50 14             	mov    0x14(%eax),%edx
80108775:	8b 40 10             	mov    0x10(%eax),%eax
80108778:	a3 98 a5 11 80       	mov    %eax,0x8011a598
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010877d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108780:	8b 50 1c             	mov    0x1c(%eax),%edx
80108783:	8b 40 18             	mov    0x18(%eax),%eax
80108786:	a3 a0 a5 11 80       	mov    %eax,0x8011a5a0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010878b:	8b 15 a0 a5 11 80    	mov    0x8011a5a0,%edx
80108791:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108796:	29 d0                	sub    %edx,%eax
80108798:	a3 9c a5 11 80       	mov    %eax,0x8011a59c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010879d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087a0:	8b 50 24             	mov    0x24(%eax),%edx
801087a3:	8b 40 20             	mov    0x20(%eax),%eax
801087a6:	a3 a4 a5 11 80       	mov    %eax,0x8011a5a4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801087ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087ae:	8b 50 2c             	mov    0x2c(%eax),%edx
801087b1:	8b 40 28             	mov    0x28(%eax),%eax
801087b4:	a3 a8 a5 11 80       	mov    %eax,0x8011a5a8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801087b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087bc:	8b 50 34             	mov    0x34(%eax),%edx
801087bf:	8b 40 30             	mov    0x30(%eax),%eax
801087c2:	a3 ac a5 11 80       	mov    %eax,0x8011a5ac
}
801087c7:	90                   	nop
801087c8:	c9                   	leave  
801087c9:	c3                   	ret    

801087ca <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801087ca:	55                   	push   %ebp
801087cb:	89 e5                	mov    %esp,%ebp
801087cd:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801087d0:	8b 15 ac a5 11 80    	mov    0x8011a5ac,%edx
801087d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801087d9:	0f af d0             	imul   %eax,%edx
801087dc:	8b 45 08             	mov    0x8(%ebp),%eax
801087df:	01 d0                	add    %edx,%eax
801087e1:	c1 e0 02             	shl    $0x2,%eax
801087e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801087e7:	8b 15 9c a5 11 80    	mov    0x8011a59c,%edx
801087ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087f0:	01 d0                	add    %edx,%eax
801087f2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801087f5:	8b 45 10             	mov    0x10(%ebp),%eax
801087f8:	0f b6 10             	movzbl (%eax),%edx
801087fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801087fe:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108800:	8b 45 10             	mov    0x10(%ebp),%eax
80108803:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108807:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010880a:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010880d:	8b 45 10             	mov    0x10(%ebp),%eax
80108810:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108814:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108817:	88 50 02             	mov    %dl,0x2(%eax)
}
8010881a:	90                   	nop
8010881b:	c9                   	leave  
8010881c:	c3                   	ret    

8010881d <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010881d:	55                   	push   %ebp
8010881e:	89 e5                	mov    %esp,%ebp
80108820:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108823:	8b 15 ac a5 11 80    	mov    0x8011a5ac,%edx
80108829:	8b 45 08             	mov    0x8(%ebp),%eax
8010882c:	0f af c2             	imul   %edx,%eax
8010882f:	c1 e0 02             	shl    $0x2,%eax
80108832:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108835:	a1 a0 a5 11 80       	mov    0x8011a5a0,%eax
8010883a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010883d:	29 d0                	sub    %edx,%eax
8010883f:	8b 0d 9c a5 11 80    	mov    0x8011a59c,%ecx
80108845:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108848:	01 ca                	add    %ecx,%edx
8010884a:	89 d1                	mov    %edx,%ecx
8010884c:	8b 15 9c a5 11 80    	mov    0x8011a59c,%edx
80108852:	83 ec 04             	sub    $0x4,%esp
80108855:	50                   	push   %eax
80108856:	51                   	push   %ecx
80108857:	52                   	push   %edx
80108858:	e8 da ca ff ff       	call   80105337 <memmove>
8010885d:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108863:	8b 0d 9c a5 11 80    	mov    0x8011a59c,%ecx
80108869:	8b 15 a0 a5 11 80    	mov    0x8011a5a0,%edx
8010886f:	01 ca                	add    %ecx,%edx
80108871:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108874:	29 ca                	sub    %ecx,%edx
80108876:	83 ec 04             	sub    $0x4,%esp
80108879:	50                   	push   %eax
8010887a:	6a 00                	push   $0x0
8010887c:	52                   	push   %edx
8010887d:	e8 f6 c9 ff ff       	call   80105278 <memset>
80108882:	83 c4 10             	add    $0x10,%esp
}
80108885:	90                   	nop
80108886:	c9                   	leave  
80108887:	c3                   	ret    

80108888 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108888:	55                   	push   %ebp
80108889:	89 e5                	mov    %esp,%ebp
8010888b:	53                   	push   %ebx
8010888c:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010888f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108896:	e9 b1 00 00 00       	jmp    8010894c <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010889b:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801088a2:	e9 97 00 00 00       	jmp    8010893e <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801088a7:	8b 45 10             	mov    0x10(%ebp),%eax
801088aa:	83 e8 20             	sub    $0x20,%eax
801088ad:	6b d0 1e             	imul   $0x1e,%eax,%edx
801088b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b3:	01 d0                	add    %edx,%eax
801088b5:	0f b7 84 00 00 b0 10 	movzwl -0x7fef5000(%eax,%eax,1),%eax
801088bc:	80 
801088bd:	0f b7 d0             	movzwl %ax,%edx
801088c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088c3:	bb 01 00 00 00       	mov    $0x1,%ebx
801088c8:	89 c1                	mov    %eax,%ecx
801088ca:	d3 e3                	shl    %cl,%ebx
801088cc:	89 d8                	mov    %ebx,%eax
801088ce:	21 d0                	and    %edx,%eax
801088d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801088d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d6:	ba 01 00 00 00       	mov    $0x1,%edx
801088db:	89 c1                	mov    %eax,%ecx
801088dd:	d3 e2                	shl    %cl,%edx
801088df:	89 d0                	mov    %edx,%eax
801088e1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801088e4:	75 2b                	jne    80108911 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801088e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801088e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ec:	01 c2                	add    %eax,%edx
801088ee:	b8 0e 00 00 00       	mov    $0xe,%eax
801088f3:	2b 45 f0             	sub    -0x10(%ebp),%eax
801088f6:	89 c1                	mov    %eax,%ecx
801088f8:	8b 45 08             	mov    0x8(%ebp),%eax
801088fb:	01 c8                	add    %ecx,%eax
801088fd:	83 ec 04             	sub    $0x4,%esp
80108900:	68 e0 f4 10 80       	push   $0x8010f4e0
80108905:	52                   	push   %edx
80108906:	50                   	push   %eax
80108907:	e8 be fe ff ff       	call   801087ca <graphic_draw_pixel>
8010890c:	83 c4 10             	add    $0x10,%esp
8010890f:	eb 29                	jmp    8010893a <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108911:	8b 55 0c             	mov    0xc(%ebp),%edx
80108914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108917:	01 c2                	add    %eax,%edx
80108919:	b8 0e 00 00 00       	mov    $0xe,%eax
8010891e:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108921:	89 c1                	mov    %eax,%ecx
80108923:	8b 45 08             	mov    0x8(%ebp),%eax
80108926:	01 c8                	add    %ecx,%eax
80108928:	83 ec 04             	sub    $0x4,%esp
8010892b:	68 b0 a5 11 80       	push   $0x8011a5b0
80108930:	52                   	push   %edx
80108931:	50                   	push   %eax
80108932:	e8 93 fe ff ff       	call   801087ca <graphic_draw_pixel>
80108937:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010893a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010893e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108942:	0f 89 5f ff ff ff    	jns    801088a7 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108948:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010894c:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108950:	0f 8e 45 ff ff ff    	jle    8010889b <font_render+0x13>
      }
    }
  }
}
80108956:	90                   	nop
80108957:	90                   	nop
80108958:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010895b:	c9                   	leave  
8010895c:	c3                   	ret    

8010895d <font_render_string>:

void font_render_string(char *string,int row){
8010895d:	55                   	push   %ebp
8010895e:	89 e5                	mov    %esp,%ebp
80108960:	53                   	push   %ebx
80108961:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108964:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010896b:	eb 33                	jmp    801089a0 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
8010896d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108970:	8b 45 08             	mov    0x8(%ebp),%eax
80108973:	01 d0                	add    %edx,%eax
80108975:	0f b6 00             	movzbl (%eax),%eax
80108978:	0f be c8             	movsbl %al,%ecx
8010897b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010897e:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108981:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108984:	89 d8                	mov    %ebx,%eax
80108986:	c1 e0 04             	shl    $0x4,%eax
80108989:	29 d8                	sub    %ebx,%eax
8010898b:	83 c0 02             	add    $0x2,%eax
8010898e:	83 ec 04             	sub    $0x4,%esp
80108991:	51                   	push   %ecx
80108992:	52                   	push   %edx
80108993:	50                   	push   %eax
80108994:	e8 ef fe ff ff       	call   80108888 <font_render>
80108999:	83 c4 10             	add    $0x10,%esp
    i++;
8010899c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801089a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089a3:	8b 45 08             	mov    0x8(%ebp),%eax
801089a6:	01 d0                	add    %edx,%eax
801089a8:	0f b6 00             	movzbl (%eax),%eax
801089ab:	84 c0                	test   %al,%al
801089ad:	74 06                	je     801089b5 <font_render_string+0x58>
801089af:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801089b3:	7e b8                	jle    8010896d <font_render_string+0x10>
  }
}
801089b5:	90                   	nop
801089b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089b9:	c9                   	leave  
801089ba:	c3                   	ret    

801089bb <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801089bb:	55                   	push   %ebp
801089bc:	89 e5                	mov    %esp,%ebp
801089be:	53                   	push   %ebx
801089bf:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801089c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089c9:	eb 6b                	jmp    80108a36 <pci_init+0x7b>
    for(int j=0;j<32;j++){
801089cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801089d2:	eb 58                	jmp    80108a2c <pci_init+0x71>
      for(int k=0;k<8;k++){
801089d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801089db:	eb 45                	jmp    80108a22 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801089dd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801089e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801089e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e6:	83 ec 0c             	sub    $0xc,%esp
801089e9:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801089ec:	53                   	push   %ebx
801089ed:	6a 00                	push   $0x0
801089ef:	51                   	push   %ecx
801089f0:	52                   	push   %edx
801089f1:	50                   	push   %eax
801089f2:	e8 b0 00 00 00       	call   80108aa7 <pci_access_config>
801089f7:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801089fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089fd:	0f b7 c0             	movzwl %ax,%eax
80108a00:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108a05:	74 17                	je     80108a1e <pci_init+0x63>
        pci_init_device(i,j,k);
80108a07:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108a0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a10:	83 ec 04             	sub    $0x4,%esp
80108a13:	51                   	push   %ecx
80108a14:	52                   	push   %edx
80108a15:	50                   	push   %eax
80108a16:	e8 37 01 00 00       	call   80108b52 <pci_init_device>
80108a1b:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108a1e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108a22:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108a26:	7e b5                	jle    801089dd <pci_init+0x22>
    for(int j=0;j<32;j++){
80108a28:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108a2c:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108a30:	7e a2                	jle    801089d4 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108a32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a36:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108a3d:	7e 8c                	jle    801089cb <pci_init+0x10>
      }
      }
    }
  }
}
80108a3f:	90                   	nop
80108a40:	90                   	nop
80108a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a44:	c9                   	leave  
80108a45:	c3                   	ret    

80108a46 <pci_write_config>:

void pci_write_config(uint config){
80108a46:	55                   	push   %ebp
80108a47:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108a49:	8b 45 08             	mov    0x8(%ebp),%eax
80108a4c:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108a51:	89 c0                	mov    %eax,%eax
80108a53:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108a54:	90                   	nop
80108a55:	5d                   	pop    %ebp
80108a56:	c3                   	ret    

80108a57 <pci_write_data>:

void pci_write_data(uint config){
80108a57:	55                   	push   %ebp
80108a58:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a5d:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108a62:	89 c0                	mov    %eax,%eax
80108a64:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108a65:	90                   	nop
80108a66:	5d                   	pop    %ebp
80108a67:	c3                   	ret    

80108a68 <pci_read_config>:
uint pci_read_config(){
80108a68:	55                   	push   %ebp
80108a69:	89 e5                	mov    %esp,%ebp
80108a6b:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108a6e:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108a73:	ed                   	in     (%dx),%eax
80108a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108a77:	83 ec 0c             	sub    $0xc,%esp
80108a7a:	68 c8 00 00 00       	push   $0xc8
80108a7f:	e8 97 a5 ff ff       	call   8010301b <microdelay>
80108a84:	83 c4 10             	add    $0x10,%esp
  return data;
80108a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108a8a:	c9                   	leave  
80108a8b:	c3                   	ret    

80108a8c <pci_test>:


void pci_test(){
80108a8c:	55                   	push   %ebp
80108a8d:	89 e5                	mov    %esp,%ebp
80108a8f:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108a92:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108a99:	ff 75 fc             	push   -0x4(%ebp)
80108a9c:	e8 a5 ff ff ff       	call   80108a46 <pci_write_config>
80108aa1:	83 c4 04             	add    $0x4,%esp
}
80108aa4:	90                   	nop
80108aa5:	c9                   	leave  
80108aa6:	c3                   	ret    

80108aa7 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108aa7:	55                   	push   %ebp
80108aa8:	89 e5                	mov    %esp,%ebp
80108aaa:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108aad:	8b 45 08             	mov    0x8(%ebp),%eax
80108ab0:	c1 e0 10             	shl    $0x10,%eax
80108ab3:	25 00 00 ff 00       	and    $0xff0000,%eax
80108ab8:	89 c2                	mov    %eax,%edx
80108aba:	8b 45 0c             	mov    0xc(%ebp),%eax
80108abd:	c1 e0 0b             	shl    $0xb,%eax
80108ac0:	0f b7 c0             	movzwl %ax,%eax
80108ac3:	09 c2                	or     %eax,%edx
80108ac5:	8b 45 10             	mov    0x10(%ebp),%eax
80108ac8:	c1 e0 08             	shl    $0x8,%eax
80108acb:	25 00 07 00 00       	and    $0x700,%eax
80108ad0:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108ad2:	8b 45 14             	mov    0x14(%ebp),%eax
80108ad5:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108ada:	09 d0                	or     %edx,%eax
80108adc:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108ae4:	ff 75 f4             	push   -0xc(%ebp)
80108ae7:	e8 5a ff ff ff       	call   80108a46 <pci_write_config>
80108aec:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108aef:	e8 74 ff ff ff       	call   80108a68 <pci_read_config>
80108af4:	8b 55 18             	mov    0x18(%ebp),%edx
80108af7:	89 02                	mov    %eax,(%edx)
}
80108af9:	90                   	nop
80108afa:	c9                   	leave  
80108afb:	c3                   	ret    

80108afc <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108afc:	55                   	push   %ebp
80108afd:	89 e5                	mov    %esp,%ebp
80108aff:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108b02:	8b 45 08             	mov    0x8(%ebp),%eax
80108b05:	c1 e0 10             	shl    $0x10,%eax
80108b08:	25 00 00 ff 00       	and    $0xff0000,%eax
80108b0d:	89 c2                	mov    %eax,%edx
80108b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b12:	c1 e0 0b             	shl    $0xb,%eax
80108b15:	0f b7 c0             	movzwl %ax,%eax
80108b18:	09 c2                	or     %eax,%edx
80108b1a:	8b 45 10             	mov    0x10(%ebp),%eax
80108b1d:	c1 e0 08             	shl    $0x8,%eax
80108b20:	25 00 07 00 00       	and    $0x700,%eax
80108b25:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108b27:	8b 45 14             	mov    0x14(%ebp),%eax
80108b2a:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108b2f:	09 d0                	or     %edx,%eax
80108b31:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b36:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108b39:	ff 75 fc             	push   -0x4(%ebp)
80108b3c:	e8 05 ff ff ff       	call   80108a46 <pci_write_config>
80108b41:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108b44:	ff 75 18             	push   0x18(%ebp)
80108b47:	e8 0b ff ff ff       	call   80108a57 <pci_write_data>
80108b4c:	83 c4 04             	add    $0x4,%esp
}
80108b4f:	90                   	nop
80108b50:	c9                   	leave  
80108b51:	c3                   	ret    

80108b52 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108b52:	55                   	push   %ebp
80108b53:	89 e5                	mov    %esp,%ebp
80108b55:	53                   	push   %ebx
80108b56:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108b59:	8b 45 08             	mov    0x8(%ebp),%eax
80108b5c:	a2 b4 a5 11 80       	mov    %al,0x8011a5b4
  dev.device_num = device_num;
80108b61:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b64:	a2 b5 a5 11 80       	mov    %al,0x8011a5b5
  dev.function_num = function_num;
80108b69:	8b 45 10             	mov    0x10(%ebp),%eax
80108b6c:	a2 b6 a5 11 80       	mov    %al,0x8011a5b6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108b71:	ff 75 10             	push   0x10(%ebp)
80108b74:	ff 75 0c             	push   0xc(%ebp)
80108b77:	ff 75 08             	push   0x8(%ebp)
80108b7a:	68 44 c6 10 80       	push   $0x8010c644
80108b7f:	e8 70 78 ff ff       	call   801003f4 <cprintf>
80108b84:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108b87:	83 ec 0c             	sub    $0xc,%esp
80108b8a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b8d:	50                   	push   %eax
80108b8e:	6a 00                	push   $0x0
80108b90:	ff 75 10             	push   0x10(%ebp)
80108b93:	ff 75 0c             	push   0xc(%ebp)
80108b96:	ff 75 08             	push   0x8(%ebp)
80108b99:	e8 09 ff ff ff       	call   80108aa7 <pci_access_config>
80108b9e:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108ba1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ba4:	c1 e8 10             	shr    $0x10,%eax
80108ba7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108baa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bad:	25 ff ff 00 00       	and    $0xffff,%eax
80108bb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb8:	a3 b8 a5 11 80       	mov    %eax,0x8011a5b8
  dev.vendor_id = vendor_id;
80108bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bc0:	a3 bc a5 11 80       	mov    %eax,0x8011a5bc
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108bc5:	83 ec 04             	sub    $0x4,%esp
80108bc8:	ff 75 f0             	push   -0x10(%ebp)
80108bcb:	ff 75 f4             	push   -0xc(%ebp)
80108bce:	68 78 c6 10 80       	push   $0x8010c678
80108bd3:	e8 1c 78 ff ff       	call   801003f4 <cprintf>
80108bd8:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108bdb:	83 ec 0c             	sub    $0xc,%esp
80108bde:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108be1:	50                   	push   %eax
80108be2:	6a 08                	push   $0x8
80108be4:	ff 75 10             	push   0x10(%ebp)
80108be7:	ff 75 0c             	push   0xc(%ebp)
80108bea:	ff 75 08             	push   0x8(%ebp)
80108bed:	e8 b5 fe ff ff       	call   80108aa7 <pci_access_config>
80108bf2:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108bf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bf8:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108bfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bfe:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108c01:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108c04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c07:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108c0a:	0f b6 c0             	movzbl %al,%eax
80108c0d:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108c10:	c1 eb 18             	shr    $0x18,%ebx
80108c13:	83 ec 0c             	sub    $0xc,%esp
80108c16:	51                   	push   %ecx
80108c17:	52                   	push   %edx
80108c18:	50                   	push   %eax
80108c19:	53                   	push   %ebx
80108c1a:	68 9c c6 10 80       	push   $0x8010c69c
80108c1f:	e8 d0 77 ff ff       	call   801003f4 <cprintf>
80108c24:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108c27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c2a:	c1 e8 18             	shr    $0x18,%eax
80108c2d:	a2 c0 a5 11 80       	mov    %al,0x8011a5c0
  dev.sub_class = (data>>16)&0xFF;
80108c32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c35:	c1 e8 10             	shr    $0x10,%eax
80108c38:	a2 c1 a5 11 80       	mov    %al,0x8011a5c1
  dev.interface = (data>>8)&0xFF;
80108c3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c40:	c1 e8 08             	shr    $0x8,%eax
80108c43:	a2 c2 a5 11 80       	mov    %al,0x8011a5c2
  dev.revision_id = data&0xFF;
80108c48:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c4b:	a2 c3 a5 11 80       	mov    %al,0x8011a5c3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108c50:	83 ec 0c             	sub    $0xc,%esp
80108c53:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c56:	50                   	push   %eax
80108c57:	6a 10                	push   $0x10
80108c59:	ff 75 10             	push   0x10(%ebp)
80108c5c:	ff 75 0c             	push   0xc(%ebp)
80108c5f:	ff 75 08             	push   0x8(%ebp)
80108c62:	e8 40 fe ff ff       	call   80108aa7 <pci_access_config>
80108c67:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c6d:	a3 c4 a5 11 80       	mov    %eax,0x8011a5c4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108c72:	83 ec 0c             	sub    $0xc,%esp
80108c75:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c78:	50                   	push   %eax
80108c79:	6a 14                	push   $0x14
80108c7b:	ff 75 10             	push   0x10(%ebp)
80108c7e:	ff 75 0c             	push   0xc(%ebp)
80108c81:	ff 75 08             	push   0x8(%ebp)
80108c84:	e8 1e fe ff ff       	call   80108aa7 <pci_access_config>
80108c89:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108c8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c8f:	a3 c8 a5 11 80       	mov    %eax,0x8011a5c8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108c94:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108c9b:	75 5a                	jne    80108cf7 <pci_init_device+0x1a5>
80108c9d:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108ca4:	75 51                	jne    80108cf7 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108ca6:	83 ec 0c             	sub    $0xc,%esp
80108ca9:	68 e1 c6 10 80       	push   $0x8010c6e1
80108cae:	e8 41 77 ff ff       	call   801003f4 <cprintf>
80108cb3:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108cb6:	83 ec 0c             	sub    $0xc,%esp
80108cb9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108cbc:	50                   	push   %eax
80108cbd:	68 f0 00 00 00       	push   $0xf0
80108cc2:	ff 75 10             	push   0x10(%ebp)
80108cc5:	ff 75 0c             	push   0xc(%ebp)
80108cc8:	ff 75 08             	push   0x8(%ebp)
80108ccb:	e8 d7 fd ff ff       	call   80108aa7 <pci_access_config>
80108cd0:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108cd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cd6:	83 ec 08             	sub    $0x8,%esp
80108cd9:	50                   	push   %eax
80108cda:	68 fb c6 10 80       	push   $0x8010c6fb
80108cdf:	e8 10 77 ff ff       	call   801003f4 <cprintf>
80108ce4:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108ce7:	83 ec 0c             	sub    $0xc,%esp
80108cea:	68 b4 a5 11 80       	push   $0x8011a5b4
80108cef:	e8 09 00 00 00       	call   80108cfd <i8254_init>
80108cf4:	83 c4 10             	add    $0x10,%esp
  }
}
80108cf7:	90                   	nop
80108cf8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108cfb:	c9                   	leave  
80108cfc:	c3                   	ret    

80108cfd <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108cfd:	55                   	push   %ebp
80108cfe:	89 e5                	mov    %esp,%ebp
80108d00:	53                   	push   %ebx
80108d01:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108d04:	8b 45 08             	mov    0x8(%ebp),%eax
80108d07:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108d0b:	0f b6 c8             	movzbl %al,%ecx
80108d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80108d11:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108d15:	0f b6 d0             	movzbl %al,%edx
80108d18:	8b 45 08             	mov    0x8(%ebp),%eax
80108d1b:	0f b6 00             	movzbl (%eax),%eax
80108d1e:	0f b6 c0             	movzbl %al,%eax
80108d21:	83 ec 0c             	sub    $0xc,%esp
80108d24:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108d27:	53                   	push   %ebx
80108d28:	6a 04                	push   $0x4
80108d2a:	51                   	push   %ecx
80108d2b:	52                   	push   %edx
80108d2c:	50                   	push   %eax
80108d2d:	e8 75 fd ff ff       	call   80108aa7 <pci_access_config>
80108d32:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108d35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d38:	83 c8 04             	or     $0x4,%eax
80108d3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108d3e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108d41:	8b 45 08             	mov    0x8(%ebp),%eax
80108d44:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108d48:	0f b6 c8             	movzbl %al,%ecx
80108d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d4e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108d52:	0f b6 d0             	movzbl %al,%edx
80108d55:	8b 45 08             	mov    0x8(%ebp),%eax
80108d58:	0f b6 00             	movzbl (%eax),%eax
80108d5b:	0f b6 c0             	movzbl %al,%eax
80108d5e:	83 ec 0c             	sub    $0xc,%esp
80108d61:	53                   	push   %ebx
80108d62:	6a 04                	push   $0x4
80108d64:	51                   	push   %ecx
80108d65:	52                   	push   %edx
80108d66:	50                   	push   %eax
80108d67:	e8 90 fd ff ff       	call   80108afc <pci_write_config_register>
80108d6c:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80108d72:	8b 40 10             	mov    0x10(%eax),%eax
80108d75:	05 00 00 00 40       	add    $0x40000000,%eax
80108d7a:	a3 cc a5 11 80       	mov    %eax,0x8011a5cc
  uint *ctrl = (uint *)base_addr;
80108d7f:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108d84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108d87:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108d8c:	05 d8 00 00 00       	add    $0xd8,%eax
80108d91:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d97:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da0:	8b 00                	mov    (%eax),%eax
80108da2:	0d 00 00 00 04       	or     $0x4000000,%eax
80108da7:	89 c2                	mov    %eax,%edx
80108da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dac:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108db1:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dba:	8b 00                	mov    (%eax),%eax
80108dbc:	83 c8 40             	or     $0x40,%eax
80108dbf:	89 c2                	mov    %eax,%edx
80108dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc4:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc9:	8b 10                	mov    (%eax),%edx
80108dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dce:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108dd0:	83 ec 0c             	sub    $0xc,%esp
80108dd3:	68 10 c7 10 80       	push   $0x8010c710
80108dd8:	e8 17 76 ff ff       	call   801003f4 <cprintf>
80108ddd:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108de0:	e8 9f 9e ff ff       	call   80102c84 <kalloc>
80108de5:	a3 d8 a5 11 80       	mov    %eax,0x8011a5d8
  *intr_addr = 0;
80108dea:	a1 d8 a5 11 80       	mov    0x8011a5d8,%eax
80108def:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108df5:	a1 d8 a5 11 80       	mov    0x8011a5d8,%eax
80108dfa:	83 ec 08             	sub    $0x8,%esp
80108dfd:	50                   	push   %eax
80108dfe:	68 32 c7 10 80       	push   $0x8010c732
80108e03:	e8 ec 75 ff ff       	call   801003f4 <cprintf>
80108e08:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108e0b:	e8 50 00 00 00       	call   80108e60 <i8254_init_recv>
  i8254_init_send();
80108e10:	e8 69 03 00 00       	call   8010917e <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108e15:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108e1c:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108e1f:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108e26:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108e29:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108e30:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108e33:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108e3a:	0f b6 c0             	movzbl %al,%eax
80108e3d:	83 ec 0c             	sub    $0xc,%esp
80108e40:	53                   	push   %ebx
80108e41:	51                   	push   %ecx
80108e42:	52                   	push   %edx
80108e43:	50                   	push   %eax
80108e44:	68 40 c7 10 80       	push   $0x8010c740
80108e49:	e8 a6 75 ff ff       	call   801003f4 <cprintf>
80108e4e:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108e5a:	90                   	nop
80108e5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e5e:	c9                   	leave  
80108e5f:	c3                   	ret    

80108e60 <i8254_init_recv>:

void i8254_init_recv(){
80108e60:	55                   	push   %ebp
80108e61:	89 e5                	mov    %esp,%ebp
80108e63:	57                   	push   %edi
80108e64:	56                   	push   %esi
80108e65:	53                   	push   %ebx
80108e66:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108e69:	83 ec 0c             	sub    $0xc,%esp
80108e6c:	6a 00                	push   $0x0
80108e6e:	e8 e8 04 00 00       	call   8010935b <i8254_read_eeprom>
80108e73:	83 c4 10             	add    $0x10,%esp
80108e76:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108e79:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e7c:	a2 d0 a5 11 80       	mov    %al,0x8011a5d0
  mac_addr[1] = data_l>>8;
80108e81:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e84:	c1 e8 08             	shr    $0x8,%eax
80108e87:	a2 d1 a5 11 80       	mov    %al,0x8011a5d1
  uint data_m = i8254_read_eeprom(0x1);
80108e8c:	83 ec 0c             	sub    $0xc,%esp
80108e8f:	6a 01                	push   $0x1
80108e91:	e8 c5 04 00 00       	call   8010935b <i8254_read_eeprom>
80108e96:	83 c4 10             	add    $0x10,%esp
80108e99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108e9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e9f:	a2 d2 a5 11 80       	mov    %al,0x8011a5d2
  mac_addr[3] = data_m>>8;
80108ea4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ea7:	c1 e8 08             	shr    $0x8,%eax
80108eaa:	a2 d3 a5 11 80       	mov    %al,0x8011a5d3
  uint data_h = i8254_read_eeprom(0x2);
80108eaf:	83 ec 0c             	sub    $0xc,%esp
80108eb2:	6a 02                	push   $0x2
80108eb4:	e8 a2 04 00 00       	call   8010935b <i8254_read_eeprom>
80108eb9:	83 c4 10             	add    $0x10,%esp
80108ebc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108ebf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ec2:	a2 d4 a5 11 80       	mov    %al,0x8011a5d4
  mac_addr[5] = data_h>>8;
80108ec7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eca:	c1 e8 08             	shr    $0x8,%eax
80108ecd:	a2 d5 a5 11 80       	mov    %al,0x8011a5d5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108ed2:	0f b6 05 d5 a5 11 80 	movzbl 0x8011a5d5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ed9:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108edc:	0f b6 05 d4 a5 11 80 	movzbl 0x8011a5d4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ee3:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108ee6:	0f b6 05 d3 a5 11 80 	movzbl 0x8011a5d3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108eed:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108ef0:	0f b6 05 d2 a5 11 80 	movzbl 0x8011a5d2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ef7:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108efa:	0f b6 05 d1 a5 11 80 	movzbl 0x8011a5d1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f01:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108f04:	0f b6 05 d0 a5 11 80 	movzbl 0x8011a5d0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f0b:	0f b6 c0             	movzbl %al,%eax
80108f0e:	83 ec 04             	sub    $0x4,%esp
80108f11:	57                   	push   %edi
80108f12:	56                   	push   %esi
80108f13:	53                   	push   %ebx
80108f14:	51                   	push   %ecx
80108f15:	52                   	push   %edx
80108f16:	50                   	push   %eax
80108f17:	68 58 c7 10 80       	push   $0x8010c758
80108f1c:	e8 d3 74 ff ff       	call   801003f4 <cprintf>
80108f21:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108f24:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108f29:	05 00 54 00 00       	add    $0x5400,%eax
80108f2e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108f31:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108f36:	05 04 54 00 00       	add    $0x5404,%eax
80108f3b:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108f3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f41:	c1 e0 10             	shl    $0x10,%eax
80108f44:	0b 45 d8             	or     -0x28(%ebp),%eax
80108f47:	89 c2                	mov    %eax,%edx
80108f49:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108f4c:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108f4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f51:	0d 00 00 00 80       	or     $0x80000000,%eax
80108f56:	89 c2                	mov    %eax,%edx
80108f58:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108f5b:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108f5d:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108f62:	05 00 52 00 00       	add    $0x5200,%eax
80108f67:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108f6a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108f71:	eb 19                	jmp    80108f8c <i8254_init_recv+0x12c>
    mta[i] = 0;
80108f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f7d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108f80:	01 d0                	add    %edx,%eax
80108f82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108f88:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108f8c:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108f90:	7e e1                	jle    80108f73 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108f92:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108f97:	05 d0 00 00 00       	add    $0xd0,%eax
80108f9c:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108f9f:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108fa2:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108fa8:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108fad:	05 c8 00 00 00       	add    $0xc8,%eax
80108fb2:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108fb5:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108fb8:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108fbe:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108fc3:	05 28 28 00 00       	add    $0x2828,%eax
80108fc8:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108fcb:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108fce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108fd4:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108fd9:	05 00 01 00 00       	add    $0x100,%eax
80108fde:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108fe1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108fe4:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108fea:	e8 95 9c ff ff       	call   80102c84 <kalloc>
80108fef:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ff2:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108ff7:	05 00 28 00 00       	add    $0x2800,%eax
80108ffc:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108fff:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109004:	05 04 28 00 00       	add    $0x2804,%eax
80109009:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010900c:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109011:	05 08 28 00 00       	add    $0x2808,%eax
80109016:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80109019:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010901e:	05 10 28 00 00       	add    $0x2810,%eax
80109023:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109026:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010902b:	05 18 28 00 00       	add    $0x2818,%eax
80109030:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80109033:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109036:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010903c:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010903f:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80109041:	8b 45 a8             	mov    -0x58(%ebp),%eax
80109044:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
8010904a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010904d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80109053:	8b 45 a0             	mov    -0x60(%ebp),%eax
80109056:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
8010905c:	8b 45 9c             	mov    -0x64(%ebp),%eax
8010905f:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80109065:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109068:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010906b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109072:	eb 73                	jmp    801090e7 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80109074:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109077:	c1 e0 04             	shl    $0x4,%eax
8010907a:	89 c2                	mov    %eax,%edx
8010907c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010907f:	01 d0                	add    %edx,%eax
80109081:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80109088:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010908b:	c1 e0 04             	shl    $0x4,%eax
8010908e:	89 c2                	mov    %eax,%edx
80109090:	8b 45 98             	mov    -0x68(%ebp),%eax
80109093:	01 d0                	add    %edx,%eax
80109095:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
8010909b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010909e:	c1 e0 04             	shl    $0x4,%eax
801090a1:	89 c2                	mov    %eax,%edx
801090a3:	8b 45 98             	mov    -0x68(%ebp),%eax
801090a6:	01 d0                	add    %edx,%eax
801090a8:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801090ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090b1:	c1 e0 04             	shl    $0x4,%eax
801090b4:	89 c2                	mov    %eax,%edx
801090b6:	8b 45 98             	mov    -0x68(%ebp),%eax
801090b9:	01 d0                	add    %edx,%eax
801090bb:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801090bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090c2:	c1 e0 04             	shl    $0x4,%eax
801090c5:	89 c2                	mov    %eax,%edx
801090c7:	8b 45 98             	mov    -0x68(%ebp),%eax
801090ca:	01 d0                	add    %edx,%eax
801090cc:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801090d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090d3:	c1 e0 04             	shl    $0x4,%eax
801090d6:	89 c2                	mov    %eax,%edx
801090d8:	8b 45 98             	mov    -0x68(%ebp),%eax
801090db:	01 d0                	add    %edx,%eax
801090dd:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801090e3:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801090e7:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
801090ee:	7e 84                	jle    80109074 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801090f0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801090f7:	eb 57                	jmp    80109150 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
801090f9:	e8 86 9b ff ff       	call   80102c84 <kalloc>
801090fe:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109101:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109105:	75 12                	jne    80109119 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80109107:	83 ec 0c             	sub    $0xc,%esp
8010910a:	68 78 c7 10 80       	push   $0x8010c778
8010910f:	e8 e0 72 ff ff       	call   801003f4 <cprintf>
80109114:	83 c4 10             	add    $0x10,%esp
      break;
80109117:	eb 3d                	jmp    80109156 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109119:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010911c:	c1 e0 04             	shl    $0x4,%eax
8010911f:	89 c2                	mov    %eax,%edx
80109121:	8b 45 98             	mov    -0x68(%ebp),%eax
80109124:	01 d0                	add    %edx,%eax
80109126:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109129:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010912f:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109131:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109134:	83 c0 01             	add    $0x1,%eax
80109137:	c1 e0 04             	shl    $0x4,%eax
8010913a:	89 c2                	mov    %eax,%edx
8010913c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010913f:	01 d0                	add    %edx,%eax
80109141:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109144:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010914a:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010914c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80109150:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80109154:	7e a3                	jle    801090f9 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80109156:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109159:	8b 00                	mov    (%eax),%eax
8010915b:	83 c8 02             	or     $0x2,%eax
8010915e:	89 c2                	mov    %eax,%edx
80109160:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109163:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80109165:	83 ec 0c             	sub    $0xc,%esp
80109168:	68 98 c7 10 80       	push   $0x8010c798
8010916d:	e8 82 72 ff ff       	call   801003f4 <cprintf>
80109172:	83 c4 10             	add    $0x10,%esp
}
80109175:	90                   	nop
80109176:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109179:	5b                   	pop    %ebx
8010917a:	5e                   	pop    %esi
8010917b:	5f                   	pop    %edi
8010917c:	5d                   	pop    %ebp
8010917d:	c3                   	ret    

8010917e <i8254_init_send>:

void i8254_init_send(){
8010917e:	55                   	push   %ebp
8010917f:	89 e5                	mov    %esp,%ebp
80109181:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80109184:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109189:	05 28 38 00 00       	add    $0x3828,%eax
8010918e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80109191:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109194:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
8010919a:	e8 e5 9a ff ff       	call   80102c84 <kalloc>
8010919f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801091a2:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801091a7:	05 00 38 00 00       	add    $0x3800,%eax
801091ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801091af:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801091b4:	05 04 38 00 00       	add    $0x3804,%eax
801091b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801091bc:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801091c1:	05 08 38 00 00       	add    $0x3808,%eax
801091c6:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801091c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091cc:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801091d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801091d5:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
801091d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
801091e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801091e3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
801091e9:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801091ee:	05 10 38 00 00       	add    $0x3810,%eax
801091f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801091f6:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801091fb:	05 18 38 00 00       	add    $0x3818,%eax
80109200:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109203:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109206:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010920c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010920f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109215:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109218:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010921b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109222:	e9 82 00 00 00       	jmp    801092a9 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80109227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010922a:	c1 e0 04             	shl    $0x4,%eax
8010922d:	89 c2                	mov    %eax,%edx
8010922f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109232:	01 d0                	add    %edx,%eax
80109234:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010923b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010923e:	c1 e0 04             	shl    $0x4,%eax
80109241:	89 c2                	mov    %eax,%edx
80109243:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109246:	01 d0                	add    %edx,%eax
80109248:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
8010924e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109251:	c1 e0 04             	shl    $0x4,%eax
80109254:	89 c2                	mov    %eax,%edx
80109256:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109259:	01 d0                	add    %edx,%eax
8010925b:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
8010925f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109262:	c1 e0 04             	shl    $0x4,%eax
80109265:	89 c2                	mov    %eax,%edx
80109267:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010926a:	01 d0                	add    %edx,%eax
8010926c:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80109270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109273:	c1 e0 04             	shl    $0x4,%eax
80109276:	89 c2                	mov    %eax,%edx
80109278:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010927b:	01 d0                	add    %edx,%eax
8010927d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80109281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109284:	c1 e0 04             	shl    $0x4,%eax
80109287:	89 c2                	mov    %eax,%edx
80109289:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010928c:	01 d0                	add    %edx,%eax
8010928e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109295:	c1 e0 04             	shl    $0x4,%eax
80109298:	89 c2                	mov    %eax,%edx
8010929a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010929d:	01 d0                	add    %edx,%eax
8010929f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801092a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801092a9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801092b0:	0f 8e 71 ff ff ff    	jle    80109227 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801092b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801092bd:	eb 57                	jmp    80109316 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
801092bf:	e8 c0 99 ff ff       	call   80102c84 <kalloc>
801092c4:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801092c7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801092cb:	75 12                	jne    801092df <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
801092cd:	83 ec 0c             	sub    $0xc,%esp
801092d0:	68 78 c7 10 80       	push   $0x8010c778
801092d5:	e8 1a 71 ff ff       	call   801003f4 <cprintf>
801092da:	83 c4 10             	add    $0x10,%esp
      break;
801092dd:	eb 3d                	jmp    8010931c <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
801092df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e2:	c1 e0 04             	shl    $0x4,%eax
801092e5:	89 c2                	mov    %eax,%edx
801092e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092ea:	01 d0                	add    %edx,%eax
801092ec:	8b 55 cc             	mov    -0x34(%ebp),%edx
801092ef:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801092f5:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801092f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092fa:	83 c0 01             	add    $0x1,%eax
801092fd:	c1 e0 04             	shl    $0x4,%eax
80109300:	89 c2                	mov    %eax,%edx
80109302:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109305:	01 d0                	add    %edx,%eax
80109307:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010930a:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109310:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109312:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109316:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010931a:	7e a3                	jle    801092bf <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010931c:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109321:	05 00 04 00 00       	add    $0x400,%eax
80109326:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109329:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010932c:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109332:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109337:	05 10 04 00 00       	add    $0x410,%eax
8010933c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010933f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109342:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109348:	83 ec 0c             	sub    $0xc,%esp
8010934b:	68 b8 c7 10 80       	push   $0x8010c7b8
80109350:	e8 9f 70 ff ff       	call   801003f4 <cprintf>
80109355:	83 c4 10             	add    $0x10,%esp

}
80109358:	90                   	nop
80109359:	c9                   	leave  
8010935a:	c3                   	ret    

8010935b <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
8010935b:	55                   	push   %ebp
8010935c:	89 e5                	mov    %esp,%ebp
8010935e:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109361:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109366:	83 c0 14             	add    $0x14,%eax
80109369:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010936c:	8b 45 08             	mov    0x8(%ebp),%eax
8010936f:	c1 e0 08             	shl    $0x8,%eax
80109372:	0f b7 c0             	movzwl %ax,%eax
80109375:	83 c8 01             	or     $0x1,%eax
80109378:	89 c2                	mov    %eax,%edx
8010937a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010937d:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010937f:	83 ec 0c             	sub    $0xc,%esp
80109382:	68 d8 c7 10 80       	push   $0x8010c7d8
80109387:	e8 68 70 ff ff       	call   801003f4 <cprintf>
8010938c:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010938f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109392:	8b 00                	mov    (%eax),%eax
80109394:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109397:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010939a:	83 e0 10             	and    $0x10,%eax
8010939d:	85 c0                	test   %eax,%eax
8010939f:	75 02                	jne    801093a3 <i8254_read_eeprom+0x48>
  while(1){
801093a1:	eb dc                	jmp    8010937f <i8254_read_eeprom+0x24>
      break;
801093a3:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801093a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a7:	8b 00                	mov    (%eax),%eax
801093a9:	c1 e8 10             	shr    $0x10,%eax
}
801093ac:	c9                   	leave  
801093ad:	c3                   	ret    

801093ae <i8254_recv>:
void i8254_recv(){
801093ae:	55                   	push   %ebp
801093af:	89 e5                	mov    %esp,%ebp
801093b1:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801093b4:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801093b9:	05 10 28 00 00       	add    $0x2810,%eax
801093be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801093c1:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801093c6:	05 18 28 00 00       	add    $0x2818,%eax
801093cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801093ce:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801093d3:	05 00 28 00 00       	add    $0x2800,%eax
801093d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801093db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093de:	8b 00                	mov    (%eax),%eax
801093e0:	05 00 00 00 80       	add    $0x80000000,%eax
801093e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801093e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093eb:	8b 10                	mov    (%eax),%edx
801093ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093f0:	8b 08                	mov    (%eax),%ecx
801093f2:	89 d0                	mov    %edx,%eax
801093f4:	29 c8                	sub    %ecx,%eax
801093f6:	25 ff 00 00 00       	and    $0xff,%eax
801093fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801093fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109402:	7e 37                	jle    8010943b <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109404:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109407:	8b 00                	mov    (%eax),%eax
80109409:	c1 e0 04             	shl    $0x4,%eax
8010940c:	89 c2                	mov    %eax,%edx
8010940e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109411:	01 d0                	add    %edx,%eax
80109413:	8b 00                	mov    (%eax),%eax
80109415:	05 00 00 00 80       	add    $0x80000000,%eax
8010941a:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
8010941d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109420:	8b 00                	mov    (%eax),%eax
80109422:	83 c0 01             	add    $0x1,%eax
80109425:	0f b6 d0             	movzbl %al,%edx
80109428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010942b:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
8010942d:	83 ec 0c             	sub    $0xc,%esp
80109430:	ff 75 e0             	push   -0x20(%ebp)
80109433:	e8 15 09 00 00       	call   80109d4d <eth_proc>
80109438:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
8010943b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010943e:	8b 10                	mov    (%eax),%edx
80109440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109443:	8b 00                	mov    (%eax),%eax
80109445:	39 c2                	cmp    %eax,%edx
80109447:	75 9f                	jne    801093e8 <i8254_recv+0x3a>
      (*rdt)--;
80109449:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944c:	8b 00                	mov    (%eax),%eax
8010944e:	8d 50 ff             	lea    -0x1(%eax),%edx
80109451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109454:	89 10                	mov    %edx,(%eax)
  while(1){
80109456:	eb 90                	jmp    801093e8 <i8254_recv+0x3a>

80109458 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109458:	55                   	push   %ebp
80109459:	89 e5                	mov    %esp,%ebp
8010945b:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
8010945e:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109463:	05 10 38 00 00       	add    $0x3810,%eax
80109468:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010946b:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109470:	05 18 38 00 00       	add    $0x3818,%eax
80109475:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109478:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010947d:	05 00 38 00 00       	add    $0x3800,%eax
80109482:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109485:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109488:	8b 00                	mov    (%eax),%eax
8010948a:	05 00 00 00 80       	add    $0x80000000,%eax
8010948f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109492:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109495:	8b 10                	mov    (%eax),%edx
80109497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949a:	8b 08                	mov    (%eax),%ecx
8010949c:	89 d0                	mov    %edx,%eax
8010949e:	29 c8                	sub    %ecx,%eax
801094a0:	0f b6 d0             	movzbl %al,%edx
801094a3:	b8 00 01 00 00       	mov    $0x100,%eax
801094a8:	29 d0                	sub    %edx,%eax
801094aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801094ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094b0:	8b 00                	mov    (%eax),%eax
801094b2:	25 ff 00 00 00       	and    $0xff,%eax
801094b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801094ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801094be:	0f 8e a8 00 00 00    	jle    8010956c <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801094c4:	8b 45 08             	mov    0x8(%ebp),%eax
801094c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801094ca:	89 d1                	mov    %edx,%ecx
801094cc:	c1 e1 04             	shl    $0x4,%ecx
801094cf:	8b 55 e8             	mov    -0x18(%ebp),%edx
801094d2:	01 ca                	add    %ecx,%edx
801094d4:	8b 12                	mov    (%edx),%edx
801094d6:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801094dc:	83 ec 04             	sub    $0x4,%esp
801094df:	ff 75 0c             	push   0xc(%ebp)
801094e2:	50                   	push   %eax
801094e3:	52                   	push   %edx
801094e4:	e8 4e be ff ff       	call   80105337 <memmove>
801094e9:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801094ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094ef:	c1 e0 04             	shl    $0x4,%eax
801094f2:	89 c2                	mov    %eax,%edx
801094f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094f7:	01 d0                	add    %edx,%eax
801094f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801094fc:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109500:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109503:	c1 e0 04             	shl    $0x4,%eax
80109506:	89 c2                	mov    %eax,%edx
80109508:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010950b:	01 d0                	add    %edx,%eax
8010950d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109511:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109514:	c1 e0 04             	shl    $0x4,%eax
80109517:	89 c2                	mov    %eax,%edx
80109519:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010951c:	01 d0                	add    %edx,%eax
8010951e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109522:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109525:	c1 e0 04             	shl    $0x4,%eax
80109528:	89 c2                	mov    %eax,%edx
8010952a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010952d:	01 d0                	add    %edx,%eax
8010952f:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109533:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109536:	c1 e0 04             	shl    $0x4,%eax
80109539:	89 c2                	mov    %eax,%edx
8010953b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010953e:	01 d0                	add    %edx,%eax
80109540:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109546:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109549:	c1 e0 04             	shl    $0x4,%eax
8010954c:	89 c2                	mov    %eax,%edx
8010954e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109551:	01 d0                	add    %edx,%eax
80109553:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109557:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010955a:	8b 00                	mov    (%eax),%eax
8010955c:	83 c0 01             	add    $0x1,%eax
8010955f:	0f b6 d0             	movzbl %al,%edx
80109562:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109565:	89 10                	mov    %edx,(%eax)
    return len;
80109567:	8b 45 0c             	mov    0xc(%ebp),%eax
8010956a:	eb 05                	jmp    80109571 <i8254_send+0x119>
  }else{
    return -1;
8010956c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109571:	c9                   	leave  
80109572:	c3                   	ret    

80109573 <i8254_intr>:

void i8254_intr(){
80109573:	55                   	push   %ebp
80109574:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109576:	a1 d8 a5 11 80       	mov    0x8011a5d8,%eax
8010957b:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109581:	90                   	nop
80109582:	5d                   	pop    %ebp
80109583:	c3                   	ret    

80109584 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109584:	55                   	push   %ebp
80109585:	89 e5                	mov    %esp,%ebp
80109587:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010958a:	8b 45 08             	mov    0x8(%ebp),%eax
8010958d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109593:	0f b7 00             	movzwl (%eax),%eax
80109596:	66 3d 00 01          	cmp    $0x100,%ax
8010959a:	74 0a                	je     801095a6 <arp_proc+0x22>
8010959c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095a1:	e9 4f 01 00 00       	jmp    801096f5 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801095a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a9:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801095ad:	66 83 f8 08          	cmp    $0x8,%ax
801095b1:	74 0a                	je     801095bd <arp_proc+0x39>
801095b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095b8:	e9 38 01 00 00       	jmp    801096f5 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
801095bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801095c4:	3c 06                	cmp    $0x6,%al
801095c6:	74 0a                	je     801095d2 <arp_proc+0x4e>
801095c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095cd:	e9 23 01 00 00       	jmp    801096f5 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801095d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d5:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801095d9:	3c 04                	cmp    $0x4,%al
801095db:	74 0a                	je     801095e7 <arp_proc+0x63>
801095dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095e2:	e9 0e 01 00 00       	jmp    801096f5 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801095e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ea:	83 c0 18             	add    $0x18,%eax
801095ed:	83 ec 04             	sub    $0x4,%esp
801095f0:	6a 04                	push   $0x4
801095f2:	50                   	push   %eax
801095f3:	68 e4 f4 10 80       	push   $0x8010f4e4
801095f8:	e8 e2 bc ff ff       	call   801052df <memcmp>
801095fd:	83 c4 10             	add    $0x10,%esp
80109600:	85 c0                	test   %eax,%eax
80109602:	74 27                	je     8010962b <arp_proc+0xa7>
80109604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109607:	83 c0 0e             	add    $0xe,%eax
8010960a:	83 ec 04             	sub    $0x4,%esp
8010960d:	6a 04                	push   $0x4
8010960f:	50                   	push   %eax
80109610:	68 e4 f4 10 80       	push   $0x8010f4e4
80109615:	e8 c5 bc ff ff       	call   801052df <memcmp>
8010961a:	83 c4 10             	add    $0x10,%esp
8010961d:	85 c0                	test   %eax,%eax
8010961f:	74 0a                	je     8010962b <arp_proc+0xa7>
80109621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109626:	e9 ca 00 00 00       	jmp    801096f5 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010962b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010962e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109632:	66 3d 00 01          	cmp    $0x100,%ax
80109636:	75 69                	jne    801096a1 <arp_proc+0x11d>
80109638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010963b:	83 c0 18             	add    $0x18,%eax
8010963e:	83 ec 04             	sub    $0x4,%esp
80109641:	6a 04                	push   $0x4
80109643:	50                   	push   %eax
80109644:	68 e4 f4 10 80       	push   $0x8010f4e4
80109649:	e8 91 bc ff ff       	call   801052df <memcmp>
8010964e:	83 c4 10             	add    $0x10,%esp
80109651:	85 c0                	test   %eax,%eax
80109653:	75 4c                	jne    801096a1 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109655:	e8 2a 96 ff ff       	call   80102c84 <kalloc>
8010965a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010965d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109664:	83 ec 04             	sub    $0x4,%esp
80109667:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010966a:	50                   	push   %eax
8010966b:	ff 75 f0             	push   -0x10(%ebp)
8010966e:	ff 75 f4             	push   -0xc(%ebp)
80109671:	e8 1f 04 00 00       	call   80109a95 <arp_reply_pkt_create>
80109676:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109679:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010967c:	83 ec 08             	sub    $0x8,%esp
8010967f:	50                   	push   %eax
80109680:	ff 75 f0             	push   -0x10(%ebp)
80109683:	e8 d0 fd ff ff       	call   80109458 <i8254_send>
80109688:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010968b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010968e:	83 ec 0c             	sub    $0xc,%esp
80109691:	50                   	push   %eax
80109692:	e8 53 95 ff ff       	call   80102bea <kfree>
80109697:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010969a:	b8 02 00 00 00       	mov    $0x2,%eax
8010969f:	eb 54                	jmp    801096f5 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801096a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096a4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801096a8:	66 3d 00 02          	cmp    $0x200,%ax
801096ac:	75 42                	jne    801096f0 <arp_proc+0x16c>
801096ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b1:	83 c0 18             	add    $0x18,%eax
801096b4:	83 ec 04             	sub    $0x4,%esp
801096b7:	6a 04                	push   $0x4
801096b9:	50                   	push   %eax
801096ba:	68 e4 f4 10 80       	push   $0x8010f4e4
801096bf:	e8 1b bc ff ff       	call   801052df <memcmp>
801096c4:	83 c4 10             	add    $0x10,%esp
801096c7:	85 c0                	test   %eax,%eax
801096c9:	75 25                	jne    801096f0 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801096cb:	83 ec 0c             	sub    $0xc,%esp
801096ce:	68 dc c7 10 80       	push   $0x8010c7dc
801096d3:	e8 1c 6d ff ff       	call   801003f4 <cprintf>
801096d8:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801096db:	83 ec 0c             	sub    $0xc,%esp
801096de:	ff 75 f4             	push   -0xc(%ebp)
801096e1:	e8 af 01 00 00       	call   80109895 <arp_table_update>
801096e6:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801096e9:	b8 01 00 00 00       	mov    $0x1,%eax
801096ee:	eb 05                	jmp    801096f5 <arp_proc+0x171>
  }else{
    return -1;
801096f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801096f5:	c9                   	leave  
801096f6:	c3                   	ret    

801096f7 <arp_scan>:

void arp_scan(){
801096f7:	55                   	push   %ebp
801096f8:	89 e5                	mov    %esp,%ebp
801096fa:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801096fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109704:	eb 6f                	jmp    80109775 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109706:	e8 79 95 ff ff       	call   80102c84 <kalloc>
8010970b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010970e:	83 ec 04             	sub    $0x4,%esp
80109711:	ff 75 f4             	push   -0xc(%ebp)
80109714:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109717:	50                   	push   %eax
80109718:	ff 75 ec             	push   -0x14(%ebp)
8010971b:	e8 62 00 00 00       	call   80109782 <arp_broadcast>
80109720:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109723:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109726:	83 ec 08             	sub    $0x8,%esp
80109729:	50                   	push   %eax
8010972a:	ff 75 ec             	push   -0x14(%ebp)
8010972d:	e8 26 fd ff ff       	call   80109458 <i8254_send>
80109732:	83 c4 10             	add    $0x10,%esp
80109735:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109738:	eb 22                	jmp    8010975c <arp_scan+0x65>
      microdelay(1);
8010973a:	83 ec 0c             	sub    $0xc,%esp
8010973d:	6a 01                	push   $0x1
8010973f:	e8 d7 98 ff ff       	call   8010301b <microdelay>
80109744:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109747:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010974a:	83 ec 08             	sub    $0x8,%esp
8010974d:	50                   	push   %eax
8010974e:	ff 75 ec             	push   -0x14(%ebp)
80109751:	e8 02 fd ff ff       	call   80109458 <i8254_send>
80109756:	83 c4 10             	add    $0x10,%esp
80109759:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010975c:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109760:	74 d8                	je     8010973a <arp_scan+0x43>
    }
    kfree((char *)send);
80109762:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109765:	83 ec 0c             	sub    $0xc,%esp
80109768:	50                   	push   %eax
80109769:	e8 7c 94 ff ff       	call   80102bea <kfree>
8010976e:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109771:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109775:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010977c:	7e 88                	jle    80109706 <arp_scan+0xf>
  }
}
8010977e:	90                   	nop
8010977f:	90                   	nop
80109780:	c9                   	leave  
80109781:	c3                   	ret    

80109782 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109782:	55                   	push   %ebp
80109783:	89 e5                	mov    %esp,%ebp
80109785:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109788:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010978c:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109790:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109794:	8b 45 10             	mov    0x10(%ebp),%eax
80109797:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010979a:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801097a1:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801097a7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801097ae:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801097b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801097b7:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801097bd:	8b 45 08             	mov    0x8(%ebp),%eax
801097c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801097c3:	8b 45 08             	mov    0x8(%ebp),%eax
801097c6:	83 c0 0e             	add    $0xe,%eax
801097c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801097cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097cf:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801097d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d6:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801097da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097dd:	83 ec 04             	sub    $0x4,%esp
801097e0:	6a 06                	push   $0x6
801097e2:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801097e5:	52                   	push   %edx
801097e6:	50                   	push   %eax
801097e7:	e8 4b bb ff ff       	call   80105337 <memmove>
801097ec:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801097ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f2:	83 c0 06             	add    $0x6,%eax
801097f5:	83 ec 04             	sub    $0x4,%esp
801097f8:	6a 06                	push   $0x6
801097fa:	68 d0 a5 11 80       	push   $0x8011a5d0
801097ff:	50                   	push   %eax
80109800:	e8 32 bb ff ff       	call   80105337 <memmove>
80109805:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109808:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010980b:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109810:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109813:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109819:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010981c:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109820:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109823:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109827:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010982a:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109833:	8d 50 12             	lea    0x12(%eax),%edx
80109836:	83 ec 04             	sub    $0x4,%esp
80109839:	6a 06                	push   $0x6
8010983b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010983e:	50                   	push   %eax
8010983f:	52                   	push   %edx
80109840:	e8 f2 ba ff ff       	call   80105337 <memmove>
80109845:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010984b:	8d 50 18             	lea    0x18(%eax),%edx
8010984e:	83 ec 04             	sub    $0x4,%esp
80109851:	6a 04                	push   $0x4
80109853:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109856:	50                   	push   %eax
80109857:	52                   	push   %edx
80109858:	e8 da ba ff ff       	call   80105337 <memmove>
8010985d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109863:	83 c0 08             	add    $0x8,%eax
80109866:	83 ec 04             	sub    $0x4,%esp
80109869:	6a 06                	push   $0x6
8010986b:	68 d0 a5 11 80       	push   $0x8011a5d0
80109870:	50                   	push   %eax
80109871:	e8 c1 ba ff ff       	call   80105337 <memmove>
80109876:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010987c:	83 c0 0e             	add    $0xe,%eax
8010987f:	83 ec 04             	sub    $0x4,%esp
80109882:	6a 04                	push   $0x4
80109884:	68 e4 f4 10 80       	push   $0x8010f4e4
80109889:	50                   	push   %eax
8010988a:	e8 a8 ba ff ff       	call   80105337 <memmove>
8010988f:	83 c4 10             	add    $0x10,%esp
}
80109892:	90                   	nop
80109893:	c9                   	leave  
80109894:	c3                   	ret    

80109895 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109895:	55                   	push   %ebp
80109896:	89 e5                	mov    %esp,%ebp
80109898:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010989b:	8b 45 08             	mov    0x8(%ebp),%eax
8010989e:	83 c0 0e             	add    $0xe,%eax
801098a1:	83 ec 0c             	sub    $0xc,%esp
801098a4:	50                   	push   %eax
801098a5:	e8 bc 00 00 00       	call   80109966 <arp_table_search>
801098aa:	83 c4 10             	add    $0x10,%esp
801098ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801098b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801098b4:	78 2d                	js     801098e3 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801098b6:	8b 45 08             	mov    0x8(%ebp),%eax
801098b9:	8d 48 08             	lea    0x8(%eax),%ecx
801098bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801098bf:	89 d0                	mov    %edx,%eax
801098c1:	c1 e0 02             	shl    $0x2,%eax
801098c4:	01 d0                	add    %edx,%eax
801098c6:	01 c0                	add    %eax,%eax
801098c8:	01 d0                	add    %edx,%eax
801098ca:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
801098cf:	83 c0 04             	add    $0x4,%eax
801098d2:	83 ec 04             	sub    $0x4,%esp
801098d5:	6a 06                	push   $0x6
801098d7:	51                   	push   %ecx
801098d8:	50                   	push   %eax
801098d9:	e8 59 ba ff ff       	call   80105337 <memmove>
801098de:	83 c4 10             	add    $0x10,%esp
801098e1:	eb 70                	jmp    80109953 <arp_table_update+0xbe>
  }else{
    index += 1;
801098e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801098e7:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801098ea:	8b 45 08             	mov    0x8(%ebp),%eax
801098ed:	8d 48 08             	lea    0x8(%eax),%ecx
801098f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801098f3:	89 d0                	mov    %edx,%eax
801098f5:	c1 e0 02             	shl    $0x2,%eax
801098f8:	01 d0                	add    %edx,%eax
801098fa:	01 c0                	add    %eax,%eax
801098fc:	01 d0                	add    %edx,%eax
801098fe:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
80109903:	83 c0 04             	add    $0x4,%eax
80109906:	83 ec 04             	sub    $0x4,%esp
80109909:	6a 06                	push   $0x6
8010990b:	51                   	push   %ecx
8010990c:	50                   	push   %eax
8010990d:	e8 25 ba ff ff       	call   80105337 <memmove>
80109912:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109915:	8b 45 08             	mov    0x8(%ebp),%eax
80109918:	8d 48 0e             	lea    0xe(%eax),%ecx
8010991b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010991e:	89 d0                	mov    %edx,%eax
80109920:	c1 e0 02             	shl    $0x2,%eax
80109923:	01 d0                	add    %edx,%eax
80109925:	01 c0                	add    %eax,%eax
80109927:	01 d0                	add    %edx,%eax
80109929:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
8010992e:	83 ec 04             	sub    $0x4,%esp
80109931:	6a 04                	push   $0x4
80109933:	51                   	push   %ecx
80109934:	50                   	push   %eax
80109935:	e8 fd b9 ff ff       	call   80105337 <memmove>
8010993a:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010993d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109940:	89 d0                	mov    %edx,%eax
80109942:	c1 e0 02             	shl    $0x2,%eax
80109945:	01 d0                	add    %edx,%eax
80109947:	01 c0                	add    %eax,%eax
80109949:	01 d0                	add    %edx,%eax
8010994b:	05 ea a5 11 80       	add    $0x8011a5ea,%eax
80109950:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109953:	83 ec 0c             	sub    $0xc,%esp
80109956:	68 e0 a5 11 80       	push   $0x8011a5e0
8010995b:	e8 83 00 00 00       	call   801099e3 <print_arp_table>
80109960:	83 c4 10             	add    $0x10,%esp
}
80109963:	90                   	nop
80109964:	c9                   	leave  
80109965:	c3                   	ret    

80109966 <arp_table_search>:

int arp_table_search(uchar *ip){
80109966:	55                   	push   %ebp
80109967:	89 e5                	mov    %esp,%ebp
80109969:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010996c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109973:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010997a:	eb 59                	jmp    801099d5 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010997c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010997f:	89 d0                	mov    %edx,%eax
80109981:	c1 e0 02             	shl    $0x2,%eax
80109984:	01 d0                	add    %edx,%eax
80109986:	01 c0                	add    %eax,%eax
80109988:	01 d0                	add    %edx,%eax
8010998a:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
8010998f:	83 ec 04             	sub    $0x4,%esp
80109992:	6a 04                	push   $0x4
80109994:	ff 75 08             	push   0x8(%ebp)
80109997:	50                   	push   %eax
80109998:	e8 42 b9 ff ff       	call   801052df <memcmp>
8010999d:	83 c4 10             	add    $0x10,%esp
801099a0:	85 c0                	test   %eax,%eax
801099a2:	75 05                	jne    801099a9 <arp_table_search+0x43>
      return i;
801099a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099a7:	eb 38                	jmp    801099e1 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801099a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801099ac:	89 d0                	mov    %edx,%eax
801099ae:	c1 e0 02             	shl    $0x2,%eax
801099b1:	01 d0                	add    %edx,%eax
801099b3:	01 c0                	add    %eax,%eax
801099b5:	01 d0                	add    %edx,%eax
801099b7:	05 ea a5 11 80       	add    $0x8011a5ea,%eax
801099bc:	0f b6 00             	movzbl (%eax),%eax
801099bf:	84 c0                	test   %al,%al
801099c1:	75 0e                	jne    801099d1 <arp_table_search+0x6b>
801099c3:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801099c7:	75 08                	jne    801099d1 <arp_table_search+0x6b>
      empty = -i;
801099c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099cc:	f7 d8                	neg    %eax
801099ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801099d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801099d5:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801099d9:	7e a1                	jle    8010997c <arp_table_search+0x16>
    }
  }
  return empty-1;
801099db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099de:	83 e8 01             	sub    $0x1,%eax
}
801099e1:	c9                   	leave  
801099e2:	c3                   	ret    

801099e3 <print_arp_table>:

void print_arp_table(){
801099e3:	55                   	push   %ebp
801099e4:	89 e5                	mov    %esp,%ebp
801099e6:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801099e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801099f0:	e9 92 00 00 00       	jmp    80109a87 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801099f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099f8:	89 d0                	mov    %edx,%eax
801099fa:	c1 e0 02             	shl    $0x2,%eax
801099fd:	01 d0                	add    %edx,%eax
801099ff:	01 c0                	add    %eax,%eax
80109a01:	01 d0                	add    %edx,%eax
80109a03:	05 ea a5 11 80       	add    $0x8011a5ea,%eax
80109a08:	0f b6 00             	movzbl (%eax),%eax
80109a0b:	84 c0                	test   %al,%al
80109a0d:	74 74                	je     80109a83 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109a0f:	83 ec 08             	sub    $0x8,%esp
80109a12:	ff 75 f4             	push   -0xc(%ebp)
80109a15:	68 ef c7 10 80       	push   $0x8010c7ef
80109a1a:	e8 d5 69 ff ff       	call   801003f4 <cprintf>
80109a1f:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109a22:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a25:	89 d0                	mov    %edx,%eax
80109a27:	c1 e0 02             	shl    $0x2,%eax
80109a2a:	01 d0                	add    %edx,%eax
80109a2c:	01 c0                	add    %eax,%eax
80109a2e:	01 d0                	add    %edx,%eax
80109a30:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
80109a35:	83 ec 0c             	sub    $0xc,%esp
80109a38:	50                   	push   %eax
80109a39:	e8 54 02 00 00       	call   80109c92 <print_ipv4>
80109a3e:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109a41:	83 ec 0c             	sub    $0xc,%esp
80109a44:	68 fe c7 10 80       	push   $0x8010c7fe
80109a49:	e8 a6 69 ff ff       	call   801003f4 <cprintf>
80109a4e:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109a51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a54:	89 d0                	mov    %edx,%eax
80109a56:	c1 e0 02             	shl    $0x2,%eax
80109a59:	01 d0                	add    %edx,%eax
80109a5b:	01 c0                	add    %eax,%eax
80109a5d:	01 d0                	add    %edx,%eax
80109a5f:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
80109a64:	83 c0 04             	add    $0x4,%eax
80109a67:	83 ec 0c             	sub    $0xc,%esp
80109a6a:	50                   	push   %eax
80109a6b:	e8 70 02 00 00       	call   80109ce0 <print_mac>
80109a70:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109a73:	83 ec 0c             	sub    $0xc,%esp
80109a76:	68 00 c8 10 80       	push   $0x8010c800
80109a7b:	e8 74 69 ff ff       	call   801003f4 <cprintf>
80109a80:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109a83:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109a87:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109a8b:	0f 8e 64 ff ff ff    	jle    801099f5 <print_arp_table+0x12>
    }
  }
}
80109a91:	90                   	nop
80109a92:	90                   	nop
80109a93:	c9                   	leave  
80109a94:	c3                   	ret    

80109a95 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109a95:	55                   	push   %ebp
80109a96:	89 e5                	mov    %esp,%ebp
80109a98:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109a9b:	8b 45 10             	mov    0x10(%ebp),%eax
80109a9e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
80109aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
80109aad:	83 c0 0e             	add    $0xe,%eax
80109ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ab6:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109abd:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac4:	8d 50 08             	lea    0x8(%eax),%edx
80109ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aca:	83 ec 04             	sub    $0x4,%esp
80109acd:	6a 06                	push   $0x6
80109acf:	52                   	push   %edx
80109ad0:	50                   	push   %eax
80109ad1:	e8 61 b8 ff ff       	call   80105337 <memmove>
80109ad6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109adc:	83 c0 06             	add    $0x6,%eax
80109adf:	83 ec 04             	sub    $0x4,%esp
80109ae2:	6a 06                	push   $0x6
80109ae4:	68 d0 a5 11 80       	push   $0x8011a5d0
80109ae9:	50                   	push   %eax
80109aea:	e8 48 b8 ff ff       	call   80105337 <memmove>
80109aef:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109af5:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109afd:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b06:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b0d:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b14:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1d:	8d 50 08             	lea    0x8(%eax),%edx
80109b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b23:	83 c0 12             	add    $0x12,%eax
80109b26:	83 ec 04             	sub    $0x4,%esp
80109b29:	6a 06                	push   $0x6
80109b2b:	52                   	push   %edx
80109b2c:	50                   	push   %eax
80109b2d:	e8 05 b8 ff ff       	call   80105337 <memmove>
80109b32:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109b35:	8b 45 08             	mov    0x8(%ebp),%eax
80109b38:	8d 50 0e             	lea    0xe(%eax),%edx
80109b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b3e:	83 c0 18             	add    $0x18,%eax
80109b41:	83 ec 04             	sub    $0x4,%esp
80109b44:	6a 04                	push   $0x4
80109b46:	52                   	push   %edx
80109b47:	50                   	push   %eax
80109b48:	e8 ea b7 ff ff       	call   80105337 <memmove>
80109b4d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b53:	83 c0 08             	add    $0x8,%eax
80109b56:	83 ec 04             	sub    $0x4,%esp
80109b59:	6a 06                	push   $0x6
80109b5b:	68 d0 a5 11 80       	push   $0x8011a5d0
80109b60:	50                   	push   %eax
80109b61:	e8 d1 b7 ff ff       	call   80105337 <memmove>
80109b66:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b6c:	83 c0 0e             	add    $0xe,%eax
80109b6f:	83 ec 04             	sub    $0x4,%esp
80109b72:	6a 04                	push   $0x4
80109b74:	68 e4 f4 10 80       	push   $0x8010f4e4
80109b79:	50                   	push   %eax
80109b7a:	e8 b8 b7 ff ff       	call   80105337 <memmove>
80109b7f:	83 c4 10             	add    $0x10,%esp
}
80109b82:	90                   	nop
80109b83:	c9                   	leave  
80109b84:	c3                   	ret    

80109b85 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109b85:	55                   	push   %ebp
80109b86:	89 e5                	mov    %esp,%ebp
80109b88:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109b8b:	83 ec 0c             	sub    $0xc,%esp
80109b8e:	68 02 c8 10 80       	push   $0x8010c802
80109b93:	e8 5c 68 ff ff       	call   801003f4 <cprintf>
80109b98:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b9e:	83 c0 0e             	add    $0xe,%eax
80109ba1:	83 ec 0c             	sub    $0xc,%esp
80109ba4:	50                   	push   %eax
80109ba5:	e8 e8 00 00 00       	call   80109c92 <print_ipv4>
80109baa:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109bad:	83 ec 0c             	sub    $0xc,%esp
80109bb0:	68 00 c8 10 80       	push   $0x8010c800
80109bb5:	e8 3a 68 ff ff       	call   801003f4 <cprintf>
80109bba:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc0:	83 c0 08             	add    $0x8,%eax
80109bc3:	83 ec 0c             	sub    $0xc,%esp
80109bc6:	50                   	push   %eax
80109bc7:	e8 14 01 00 00       	call   80109ce0 <print_mac>
80109bcc:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109bcf:	83 ec 0c             	sub    $0xc,%esp
80109bd2:	68 00 c8 10 80       	push   $0x8010c800
80109bd7:	e8 18 68 ff ff       	call   801003f4 <cprintf>
80109bdc:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109bdf:	83 ec 0c             	sub    $0xc,%esp
80109be2:	68 19 c8 10 80       	push   $0x8010c819
80109be7:	e8 08 68 ff ff       	call   801003f4 <cprintf>
80109bec:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109bef:	8b 45 08             	mov    0x8(%ebp),%eax
80109bf2:	83 c0 18             	add    $0x18,%eax
80109bf5:	83 ec 0c             	sub    $0xc,%esp
80109bf8:	50                   	push   %eax
80109bf9:	e8 94 00 00 00       	call   80109c92 <print_ipv4>
80109bfe:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109c01:	83 ec 0c             	sub    $0xc,%esp
80109c04:	68 00 c8 10 80       	push   $0x8010c800
80109c09:	e8 e6 67 ff ff       	call   801003f4 <cprintf>
80109c0e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109c11:	8b 45 08             	mov    0x8(%ebp),%eax
80109c14:	83 c0 12             	add    $0x12,%eax
80109c17:	83 ec 0c             	sub    $0xc,%esp
80109c1a:	50                   	push   %eax
80109c1b:	e8 c0 00 00 00       	call   80109ce0 <print_mac>
80109c20:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109c23:	83 ec 0c             	sub    $0xc,%esp
80109c26:	68 00 c8 10 80       	push   $0x8010c800
80109c2b:	e8 c4 67 ff ff       	call   801003f4 <cprintf>
80109c30:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109c33:	83 ec 0c             	sub    $0xc,%esp
80109c36:	68 30 c8 10 80       	push   $0x8010c830
80109c3b:	e8 b4 67 ff ff       	call   801003f4 <cprintf>
80109c40:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109c43:	8b 45 08             	mov    0x8(%ebp),%eax
80109c46:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c4a:	66 3d 00 01          	cmp    $0x100,%ax
80109c4e:	75 12                	jne    80109c62 <print_arp_info+0xdd>
80109c50:	83 ec 0c             	sub    $0xc,%esp
80109c53:	68 3c c8 10 80       	push   $0x8010c83c
80109c58:	e8 97 67 ff ff       	call   801003f4 <cprintf>
80109c5d:	83 c4 10             	add    $0x10,%esp
80109c60:	eb 1d                	jmp    80109c7f <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109c62:	8b 45 08             	mov    0x8(%ebp),%eax
80109c65:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c69:	66 3d 00 02          	cmp    $0x200,%ax
80109c6d:	75 10                	jne    80109c7f <print_arp_info+0xfa>
    cprintf("Reply\n");
80109c6f:	83 ec 0c             	sub    $0xc,%esp
80109c72:	68 45 c8 10 80       	push   $0x8010c845
80109c77:	e8 78 67 ff ff       	call   801003f4 <cprintf>
80109c7c:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109c7f:	83 ec 0c             	sub    $0xc,%esp
80109c82:	68 00 c8 10 80       	push   $0x8010c800
80109c87:	e8 68 67 ff ff       	call   801003f4 <cprintf>
80109c8c:	83 c4 10             	add    $0x10,%esp
}
80109c8f:	90                   	nop
80109c90:	c9                   	leave  
80109c91:	c3                   	ret    

80109c92 <print_ipv4>:

void print_ipv4(uchar *ip){
80109c92:	55                   	push   %ebp
80109c93:	89 e5                	mov    %esp,%ebp
80109c95:	53                   	push   %ebx
80109c96:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109c99:	8b 45 08             	mov    0x8(%ebp),%eax
80109c9c:	83 c0 03             	add    $0x3,%eax
80109c9f:	0f b6 00             	movzbl (%eax),%eax
80109ca2:	0f b6 d8             	movzbl %al,%ebx
80109ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca8:	83 c0 02             	add    $0x2,%eax
80109cab:	0f b6 00             	movzbl (%eax),%eax
80109cae:	0f b6 c8             	movzbl %al,%ecx
80109cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80109cb4:	83 c0 01             	add    $0x1,%eax
80109cb7:	0f b6 00             	movzbl (%eax),%eax
80109cba:	0f b6 d0             	movzbl %al,%edx
80109cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80109cc0:	0f b6 00             	movzbl (%eax),%eax
80109cc3:	0f b6 c0             	movzbl %al,%eax
80109cc6:	83 ec 0c             	sub    $0xc,%esp
80109cc9:	53                   	push   %ebx
80109cca:	51                   	push   %ecx
80109ccb:	52                   	push   %edx
80109ccc:	50                   	push   %eax
80109ccd:	68 4c c8 10 80       	push   $0x8010c84c
80109cd2:	e8 1d 67 ff ff       	call   801003f4 <cprintf>
80109cd7:	83 c4 20             	add    $0x20,%esp
}
80109cda:	90                   	nop
80109cdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109cde:	c9                   	leave  
80109cdf:	c3                   	ret    

80109ce0 <print_mac>:

void print_mac(uchar *mac){
80109ce0:	55                   	push   %ebp
80109ce1:	89 e5                	mov    %esp,%ebp
80109ce3:	57                   	push   %edi
80109ce4:	56                   	push   %esi
80109ce5:	53                   	push   %ebx
80109ce6:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109ce9:	8b 45 08             	mov    0x8(%ebp),%eax
80109cec:	83 c0 05             	add    $0x5,%eax
80109cef:	0f b6 00             	movzbl (%eax),%eax
80109cf2:	0f b6 f8             	movzbl %al,%edi
80109cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80109cf8:	83 c0 04             	add    $0x4,%eax
80109cfb:	0f b6 00             	movzbl (%eax),%eax
80109cfe:	0f b6 f0             	movzbl %al,%esi
80109d01:	8b 45 08             	mov    0x8(%ebp),%eax
80109d04:	83 c0 03             	add    $0x3,%eax
80109d07:	0f b6 00             	movzbl (%eax),%eax
80109d0a:	0f b6 d8             	movzbl %al,%ebx
80109d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d10:	83 c0 02             	add    $0x2,%eax
80109d13:	0f b6 00             	movzbl (%eax),%eax
80109d16:	0f b6 c8             	movzbl %al,%ecx
80109d19:	8b 45 08             	mov    0x8(%ebp),%eax
80109d1c:	83 c0 01             	add    $0x1,%eax
80109d1f:	0f b6 00             	movzbl (%eax),%eax
80109d22:	0f b6 d0             	movzbl %al,%edx
80109d25:	8b 45 08             	mov    0x8(%ebp),%eax
80109d28:	0f b6 00             	movzbl (%eax),%eax
80109d2b:	0f b6 c0             	movzbl %al,%eax
80109d2e:	83 ec 04             	sub    $0x4,%esp
80109d31:	57                   	push   %edi
80109d32:	56                   	push   %esi
80109d33:	53                   	push   %ebx
80109d34:	51                   	push   %ecx
80109d35:	52                   	push   %edx
80109d36:	50                   	push   %eax
80109d37:	68 64 c8 10 80       	push   $0x8010c864
80109d3c:	e8 b3 66 ff ff       	call   801003f4 <cprintf>
80109d41:	83 c4 20             	add    $0x20,%esp
}
80109d44:	90                   	nop
80109d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109d48:	5b                   	pop    %ebx
80109d49:	5e                   	pop    %esi
80109d4a:	5f                   	pop    %edi
80109d4b:	5d                   	pop    %ebp
80109d4c:	c3                   	ret    

80109d4d <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109d4d:	55                   	push   %ebp
80109d4e:	89 e5                	mov    %esp,%ebp
80109d50:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109d53:	8b 45 08             	mov    0x8(%ebp),%eax
80109d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109d59:	8b 45 08             	mov    0x8(%ebp),%eax
80109d5c:	83 c0 0e             	add    $0xe,%eax
80109d5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d65:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109d69:	3c 08                	cmp    $0x8,%al
80109d6b:	75 1b                	jne    80109d88 <eth_proc+0x3b>
80109d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d70:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d74:	3c 06                	cmp    $0x6,%al
80109d76:	75 10                	jne    80109d88 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109d78:	83 ec 0c             	sub    $0xc,%esp
80109d7b:	ff 75 f0             	push   -0x10(%ebp)
80109d7e:	e8 01 f8 ff ff       	call   80109584 <arp_proc>
80109d83:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109d86:	eb 24                	jmp    80109dac <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d8b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109d8f:	3c 08                	cmp    $0x8,%al
80109d91:	75 19                	jne    80109dac <eth_proc+0x5f>
80109d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d96:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d9a:	84 c0                	test   %al,%al
80109d9c:	75 0e                	jne    80109dac <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109d9e:	83 ec 0c             	sub    $0xc,%esp
80109da1:	ff 75 08             	push   0x8(%ebp)
80109da4:	e8 a3 00 00 00       	call   80109e4c <ipv4_proc>
80109da9:	83 c4 10             	add    $0x10,%esp
}
80109dac:	90                   	nop
80109dad:	c9                   	leave  
80109dae:	c3                   	ret    

80109daf <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109daf:	55                   	push   %ebp
80109db0:	89 e5                	mov    %esp,%ebp
80109db2:	83 ec 04             	sub    $0x4,%esp
80109db5:	8b 45 08             	mov    0x8(%ebp),%eax
80109db8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109dbc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109dc0:	c1 e0 08             	shl    $0x8,%eax
80109dc3:	89 c2                	mov    %eax,%edx
80109dc5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109dc9:	66 c1 e8 08          	shr    $0x8,%ax
80109dcd:	01 d0                	add    %edx,%eax
}
80109dcf:	c9                   	leave  
80109dd0:	c3                   	ret    

80109dd1 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109dd1:	55                   	push   %ebp
80109dd2:	89 e5                	mov    %esp,%ebp
80109dd4:	83 ec 04             	sub    $0x4,%esp
80109dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80109dda:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109dde:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109de2:	c1 e0 08             	shl    $0x8,%eax
80109de5:	89 c2                	mov    %eax,%edx
80109de7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109deb:	66 c1 e8 08          	shr    $0x8,%ax
80109def:	01 d0                	add    %edx,%eax
}
80109df1:	c9                   	leave  
80109df2:	c3                   	ret    

80109df3 <H2N_uint>:

uint H2N_uint(uint value){
80109df3:	55                   	push   %ebp
80109df4:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109df6:	8b 45 08             	mov    0x8(%ebp),%eax
80109df9:	c1 e0 18             	shl    $0x18,%eax
80109dfc:	25 00 00 00 0f       	and    $0xf000000,%eax
80109e01:	89 c2                	mov    %eax,%edx
80109e03:	8b 45 08             	mov    0x8(%ebp),%eax
80109e06:	c1 e0 08             	shl    $0x8,%eax
80109e09:	25 00 f0 00 00       	and    $0xf000,%eax
80109e0e:	09 c2                	or     %eax,%edx
80109e10:	8b 45 08             	mov    0x8(%ebp),%eax
80109e13:	c1 e8 08             	shr    $0x8,%eax
80109e16:	83 e0 0f             	and    $0xf,%eax
80109e19:	01 d0                	add    %edx,%eax
}
80109e1b:	5d                   	pop    %ebp
80109e1c:	c3                   	ret    

80109e1d <N2H_uint>:

uint N2H_uint(uint value){
80109e1d:	55                   	push   %ebp
80109e1e:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109e20:	8b 45 08             	mov    0x8(%ebp),%eax
80109e23:	c1 e0 18             	shl    $0x18,%eax
80109e26:	89 c2                	mov    %eax,%edx
80109e28:	8b 45 08             	mov    0x8(%ebp),%eax
80109e2b:	c1 e0 08             	shl    $0x8,%eax
80109e2e:	25 00 00 ff 00       	and    $0xff0000,%eax
80109e33:	01 c2                	add    %eax,%edx
80109e35:	8b 45 08             	mov    0x8(%ebp),%eax
80109e38:	c1 e8 08             	shr    $0x8,%eax
80109e3b:	25 00 ff 00 00       	and    $0xff00,%eax
80109e40:	01 c2                	add    %eax,%edx
80109e42:	8b 45 08             	mov    0x8(%ebp),%eax
80109e45:	c1 e8 18             	shr    $0x18,%eax
80109e48:	01 d0                	add    %edx,%eax
}
80109e4a:	5d                   	pop    %ebp
80109e4b:	c3                   	ret    

80109e4c <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109e4c:	55                   	push   %ebp
80109e4d:	89 e5                	mov    %esp,%ebp
80109e4f:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109e52:	8b 45 08             	mov    0x8(%ebp),%eax
80109e55:	83 c0 0e             	add    $0xe,%eax
80109e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e5e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109e62:	0f b7 d0             	movzwl %ax,%edx
80109e65:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109e6a:	39 c2                	cmp    %eax,%edx
80109e6c:	74 60                	je     80109ece <ipv4_proc+0x82>
80109e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e71:	83 c0 0c             	add    $0xc,%eax
80109e74:	83 ec 04             	sub    $0x4,%esp
80109e77:	6a 04                	push   $0x4
80109e79:	50                   	push   %eax
80109e7a:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e7f:	e8 5b b4 ff ff       	call   801052df <memcmp>
80109e84:	83 c4 10             	add    $0x10,%esp
80109e87:	85 c0                	test   %eax,%eax
80109e89:	74 43                	je     80109ece <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e8e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109e92:	0f b7 c0             	movzwl %ax,%eax
80109e95:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e9d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109ea1:	3c 01                	cmp    $0x1,%al
80109ea3:	75 10                	jne    80109eb5 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109ea5:	83 ec 0c             	sub    $0xc,%esp
80109ea8:	ff 75 08             	push   0x8(%ebp)
80109eab:	e8 a3 00 00 00       	call   80109f53 <icmp_proc>
80109eb0:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109eb3:	eb 19                	jmp    80109ece <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb8:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109ebc:	3c 06                	cmp    $0x6,%al
80109ebe:	75 0e                	jne    80109ece <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109ec0:	83 ec 0c             	sub    $0xc,%esp
80109ec3:	ff 75 08             	push   0x8(%ebp)
80109ec6:	e8 b3 03 00 00       	call   8010a27e <tcp_proc>
80109ecb:	83 c4 10             	add    $0x10,%esp
}
80109ece:	90                   	nop
80109ecf:	c9                   	leave  
80109ed0:	c3                   	ret    

80109ed1 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109ed1:	55                   	push   %ebp
80109ed2:	89 e5                	mov    %esp,%ebp
80109ed4:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80109eda:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ee0:	0f b6 00             	movzbl (%eax),%eax
80109ee3:	83 e0 0f             	and    $0xf,%eax
80109ee6:	01 c0                	add    %eax,%eax
80109ee8:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109eeb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109ef2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109ef9:	eb 48                	jmp    80109f43 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109efb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109efe:	01 c0                	add    %eax,%eax
80109f00:	89 c2                	mov    %eax,%edx
80109f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f05:	01 d0                	add    %edx,%eax
80109f07:	0f b6 00             	movzbl (%eax),%eax
80109f0a:	0f b6 c0             	movzbl %al,%eax
80109f0d:	c1 e0 08             	shl    $0x8,%eax
80109f10:	89 c2                	mov    %eax,%edx
80109f12:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f15:	01 c0                	add    %eax,%eax
80109f17:	8d 48 01             	lea    0x1(%eax),%ecx
80109f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f1d:	01 c8                	add    %ecx,%eax
80109f1f:	0f b6 00             	movzbl (%eax),%eax
80109f22:	0f b6 c0             	movzbl %al,%eax
80109f25:	01 d0                	add    %edx,%eax
80109f27:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109f2a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109f31:	76 0c                	jbe    80109f3f <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109f33:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f36:	0f b7 c0             	movzwl %ax,%eax
80109f39:	83 c0 01             	add    $0x1,%eax
80109f3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109f3f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109f43:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109f47:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109f4a:	7c af                	jl     80109efb <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109f4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f4f:	f7 d0                	not    %eax
}
80109f51:	c9                   	leave  
80109f52:	c3                   	ret    

80109f53 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109f53:	55                   	push   %ebp
80109f54:	89 e5                	mov    %esp,%ebp
80109f56:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109f59:	8b 45 08             	mov    0x8(%ebp),%eax
80109f5c:	83 c0 0e             	add    $0xe,%eax
80109f5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f65:	0f b6 00             	movzbl (%eax),%eax
80109f68:	0f b6 c0             	movzbl %al,%eax
80109f6b:	83 e0 0f             	and    $0xf,%eax
80109f6e:	c1 e0 02             	shl    $0x2,%eax
80109f71:	89 c2                	mov    %eax,%edx
80109f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f76:	01 d0                	add    %edx,%eax
80109f78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f7e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109f82:	84 c0                	test   %al,%al
80109f84:	75 4f                	jne    80109fd5 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f89:	0f b6 00             	movzbl (%eax),%eax
80109f8c:	3c 08                	cmp    $0x8,%al
80109f8e:	75 45                	jne    80109fd5 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109f90:	e8 ef 8c ff ff       	call   80102c84 <kalloc>
80109f95:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109f98:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109f9f:	83 ec 04             	sub    $0x4,%esp
80109fa2:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109fa5:	50                   	push   %eax
80109fa6:	ff 75 ec             	push   -0x14(%ebp)
80109fa9:	ff 75 08             	push   0x8(%ebp)
80109fac:	e8 78 00 00 00       	call   8010a029 <icmp_reply_pkt_create>
80109fb1:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109fb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fb7:	83 ec 08             	sub    $0x8,%esp
80109fba:	50                   	push   %eax
80109fbb:	ff 75 ec             	push   -0x14(%ebp)
80109fbe:	e8 95 f4 ff ff       	call   80109458 <i8254_send>
80109fc3:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109fc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fc9:	83 ec 0c             	sub    $0xc,%esp
80109fcc:	50                   	push   %eax
80109fcd:	e8 18 8c ff ff       	call   80102bea <kfree>
80109fd2:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109fd5:	90                   	nop
80109fd6:	c9                   	leave  
80109fd7:	c3                   	ret    

80109fd8 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109fd8:	55                   	push   %ebp
80109fd9:	89 e5                	mov    %esp,%ebp
80109fdb:	53                   	push   %ebx
80109fdc:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80109fe2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109fe6:	0f b7 c0             	movzwl %ax,%eax
80109fe9:	83 ec 0c             	sub    $0xc,%esp
80109fec:	50                   	push   %eax
80109fed:	e8 bd fd ff ff       	call   80109daf <N2H_ushort>
80109ff2:	83 c4 10             	add    $0x10,%esp
80109ff5:	0f b7 d8             	movzwl %ax,%ebx
80109ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80109ffb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109fff:	0f b7 c0             	movzwl %ax,%eax
8010a002:	83 ec 0c             	sub    $0xc,%esp
8010a005:	50                   	push   %eax
8010a006:	e8 a4 fd ff ff       	call   80109daf <N2H_ushort>
8010a00b:	83 c4 10             	add    $0x10,%esp
8010a00e:	0f b7 c0             	movzwl %ax,%eax
8010a011:	83 ec 04             	sub    $0x4,%esp
8010a014:	53                   	push   %ebx
8010a015:	50                   	push   %eax
8010a016:	68 83 c8 10 80       	push   $0x8010c883
8010a01b:	e8 d4 63 ff ff       	call   801003f4 <cprintf>
8010a020:	83 c4 10             	add    $0x10,%esp
}
8010a023:	90                   	nop
8010a024:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a027:	c9                   	leave  
8010a028:	c3                   	ret    

8010a029 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a029:	55                   	push   %ebp
8010a02a:	89 e5                	mov    %esp,%ebp
8010a02c:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a02f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a032:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a035:	8b 45 08             	mov    0x8(%ebp),%eax
8010a038:	83 c0 0e             	add    $0xe,%eax
8010a03b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a03e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a041:	0f b6 00             	movzbl (%eax),%eax
8010a044:	0f b6 c0             	movzbl %al,%eax
8010a047:	83 e0 0f             	and    $0xf,%eax
8010a04a:	c1 e0 02             	shl    $0x2,%eax
8010a04d:	89 c2                	mov    %eax,%edx
8010a04f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a052:	01 d0                	add    %edx,%eax
8010a054:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a057:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a05a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a05d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a060:	83 c0 0e             	add    $0xe,%eax
8010a063:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a069:	83 c0 14             	add    $0x14,%eax
8010a06c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a06f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a072:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a07b:	8d 50 06             	lea    0x6(%eax),%edx
8010a07e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a081:	83 ec 04             	sub    $0x4,%esp
8010a084:	6a 06                	push   $0x6
8010a086:	52                   	push   %edx
8010a087:	50                   	push   %eax
8010a088:	e8 aa b2 ff ff       	call   80105337 <memmove>
8010a08d:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a090:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a093:	83 c0 06             	add    $0x6,%eax
8010a096:	83 ec 04             	sub    $0x4,%esp
8010a099:	6a 06                	push   $0x6
8010a09b:	68 d0 a5 11 80       	push   $0x8011a5d0
8010a0a0:	50                   	push   %eax
8010a0a1:	e8 91 b2 ff ff       	call   80105337 <memmove>
8010a0a6:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a0a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0ac:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a0b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0b3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a0b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0ba:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a0bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0c0:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a0c4:	83 ec 0c             	sub    $0xc,%esp
8010a0c7:	6a 54                	push   $0x54
8010a0c9:	e8 03 fd ff ff       	call   80109dd1 <H2N_ushort>
8010a0ce:	83 c4 10             	add    $0x10,%esp
8010a0d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0d4:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a0d8:	0f b7 15 a0 a8 11 80 	movzwl 0x8011a8a0,%edx
8010a0df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0e2:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a0e6:	0f b7 05 a0 a8 11 80 	movzwl 0x8011a8a0,%eax
8010a0ed:	83 c0 01             	add    $0x1,%eax
8010a0f0:	66 a3 a0 a8 11 80    	mov    %ax,0x8011a8a0
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a0f6:	83 ec 0c             	sub    $0xc,%esp
8010a0f9:	68 00 40 00 00       	push   $0x4000
8010a0fe:	e8 ce fc ff ff       	call   80109dd1 <H2N_ushort>
8010a103:	83 c4 10             	add    $0x10,%esp
8010a106:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a109:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a10d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a110:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a114:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a117:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a11b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a11e:	83 c0 0c             	add    $0xc,%eax
8010a121:	83 ec 04             	sub    $0x4,%esp
8010a124:	6a 04                	push   $0x4
8010a126:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a12b:	50                   	push   %eax
8010a12c:	e8 06 b2 ff ff       	call   80105337 <memmove>
8010a131:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a134:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a137:	8d 50 0c             	lea    0xc(%eax),%edx
8010a13a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a13d:	83 c0 10             	add    $0x10,%eax
8010a140:	83 ec 04             	sub    $0x4,%esp
8010a143:	6a 04                	push   $0x4
8010a145:	52                   	push   %edx
8010a146:	50                   	push   %eax
8010a147:	e8 eb b1 ff ff       	call   80105337 <memmove>
8010a14c:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a14f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a152:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a158:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a15b:	83 ec 0c             	sub    $0xc,%esp
8010a15e:	50                   	push   %eax
8010a15f:	e8 6d fd ff ff       	call   80109ed1 <ipv4_chksum>
8010a164:	83 c4 10             	add    $0x10,%esp
8010a167:	0f b7 c0             	movzwl %ax,%eax
8010a16a:	83 ec 0c             	sub    $0xc,%esp
8010a16d:	50                   	push   %eax
8010a16e:	e8 5e fc ff ff       	call   80109dd1 <H2N_ushort>
8010a173:	83 c4 10             	add    $0x10,%esp
8010a176:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a179:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a17d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a180:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a183:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a186:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a18a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a18d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a191:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a194:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a198:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a19b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a19f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1a2:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a1a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1a9:	8d 50 08             	lea    0x8(%eax),%edx
8010a1ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1af:	83 c0 08             	add    $0x8,%eax
8010a1b2:	83 ec 04             	sub    $0x4,%esp
8010a1b5:	6a 08                	push   $0x8
8010a1b7:	52                   	push   %edx
8010a1b8:	50                   	push   %eax
8010a1b9:	e8 79 b1 ff ff       	call   80105337 <memmove>
8010a1be:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a1c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1c4:	8d 50 10             	lea    0x10(%eax),%edx
8010a1c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1ca:	83 c0 10             	add    $0x10,%eax
8010a1cd:	83 ec 04             	sub    $0x4,%esp
8010a1d0:	6a 30                	push   $0x30
8010a1d2:	52                   	push   %edx
8010a1d3:	50                   	push   %eax
8010a1d4:	e8 5e b1 ff ff       	call   80105337 <memmove>
8010a1d9:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a1dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1df:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a1e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1e8:	83 ec 0c             	sub    $0xc,%esp
8010a1eb:	50                   	push   %eax
8010a1ec:	e8 1c 00 00 00       	call   8010a20d <icmp_chksum>
8010a1f1:	83 c4 10             	add    $0x10,%esp
8010a1f4:	0f b7 c0             	movzwl %ax,%eax
8010a1f7:	83 ec 0c             	sub    $0xc,%esp
8010a1fa:	50                   	push   %eax
8010a1fb:	e8 d1 fb ff ff       	call   80109dd1 <H2N_ushort>
8010a200:	83 c4 10             	add    $0x10,%esp
8010a203:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a206:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a20a:	90                   	nop
8010a20b:	c9                   	leave  
8010a20c:	c3                   	ret    

8010a20d <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a20d:	55                   	push   %ebp
8010a20e:	89 e5                	mov    %esp,%ebp
8010a210:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a213:	8b 45 08             	mov    0x8(%ebp),%eax
8010a216:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a219:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a220:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a227:	eb 48                	jmp    8010a271 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a229:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a22c:	01 c0                	add    %eax,%eax
8010a22e:	89 c2                	mov    %eax,%edx
8010a230:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a233:	01 d0                	add    %edx,%eax
8010a235:	0f b6 00             	movzbl (%eax),%eax
8010a238:	0f b6 c0             	movzbl %al,%eax
8010a23b:	c1 e0 08             	shl    $0x8,%eax
8010a23e:	89 c2                	mov    %eax,%edx
8010a240:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a243:	01 c0                	add    %eax,%eax
8010a245:	8d 48 01             	lea    0x1(%eax),%ecx
8010a248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a24b:	01 c8                	add    %ecx,%eax
8010a24d:	0f b6 00             	movzbl (%eax),%eax
8010a250:	0f b6 c0             	movzbl %al,%eax
8010a253:	01 d0                	add    %edx,%eax
8010a255:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a258:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a25f:	76 0c                	jbe    8010a26d <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a261:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a264:	0f b7 c0             	movzwl %ax,%eax
8010a267:	83 c0 01             	add    $0x1,%eax
8010a26a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a26d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a271:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a275:	7e b2                	jle    8010a229 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a277:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a27a:	f7 d0                	not    %eax
}
8010a27c:	c9                   	leave  
8010a27d:	c3                   	ret    

8010a27e <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a27e:	55                   	push   %ebp
8010a27f:	89 e5                	mov    %esp,%ebp
8010a281:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a284:	8b 45 08             	mov    0x8(%ebp),%eax
8010a287:	83 c0 0e             	add    $0xe,%eax
8010a28a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a290:	0f b6 00             	movzbl (%eax),%eax
8010a293:	0f b6 c0             	movzbl %al,%eax
8010a296:	83 e0 0f             	and    $0xf,%eax
8010a299:	c1 e0 02             	shl    $0x2,%eax
8010a29c:	89 c2                	mov    %eax,%edx
8010a29e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2a1:	01 d0                	add    %edx,%eax
8010a2a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a2a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2a9:	83 c0 14             	add    $0x14,%eax
8010a2ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a2af:	e8 d0 89 ff ff       	call   80102c84 <kalloc>
8010a2b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a2b7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a2be:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2c1:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a2c5:	0f b6 c0             	movzbl %al,%eax
8010a2c8:	83 e0 02             	and    $0x2,%eax
8010a2cb:	85 c0                	test   %eax,%eax
8010a2cd:	74 3d                	je     8010a30c <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a2cf:	83 ec 0c             	sub    $0xc,%esp
8010a2d2:	6a 00                	push   $0x0
8010a2d4:	6a 12                	push   $0x12
8010a2d6:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2d9:	50                   	push   %eax
8010a2da:	ff 75 e8             	push   -0x18(%ebp)
8010a2dd:	ff 75 08             	push   0x8(%ebp)
8010a2e0:	e8 a2 01 00 00       	call   8010a487 <tcp_pkt_create>
8010a2e5:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a2e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a2eb:	83 ec 08             	sub    $0x8,%esp
8010a2ee:	50                   	push   %eax
8010a2ef:	ff 75 e8             	push   -0x18(%ebp)
8010a2f2:	e8 61 f1 ff ff       	call   80109458 <i8254_send>
8010a2f7:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a2fa:	a1 a4 a8 11 80       	mov    0x8011a8a4,%eax
8010a2ff:	83 c0 01             	add    $0x1,%eax
8010a302:	a3 a4 a8 11 80       	mov    %eax,0x8011a8a4
8010a307:	e9 69 01 00 00       	jmp    8010a475 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a30c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a30f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a313:	3c 18                	cmp    $0x18,%al
8010a315:	0f 85 10 01 00 00    	jne    8010a42b <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a31b:	83 ec 04             	sub    $0x4,%esp
8010a31e:	6a 03                	push   $0x3
8010a320:	68 9e c8 10 80       	push   $0x8010c89e
8010a325:	ff 75 ec             	push   -0x14(%ebp)
8010a328:	e8 b2 af ff ff       	call   801052df <memcmp>
8010a32d:	83 c4 10             	add    $0x10,%esp
8010a330:	85 c0                	test   %eax,%eax
8010a332:	74 74                	je     8010a3a8 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a334:	83 ec 0c             	sub    $0xc,%esp
8010a337:	68 a2 c8 10 80       	push   $0x8010c8a2
8010a33c:	e8 b3 60 ff ff       	call   801003f4 <cprintf>
8010a341:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a344:	83 ec 0c             	sub    $0xc,%esp
8010a347:	6a 00                	push   $0x0
8010a349:	6a 10                	push   $0x10
8010a34b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a34e:	50                   	push   %eax
8010a34f:	ff 75 e8             	push   -0x18(%ebp)
8010a352:	ff 75 08             	push   0x8(%ebp)
8010a355:	e8 2d 01 00 00       	call   8010a487 <tcp_pkt_create>
8010a35a:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a35d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a360:	83 ec 08             	sub    $0x8,%esp
8010a363:	50                   	push   %eax
8010a364:	ff 75 e8             	push   -0x18(%ebp)
8010a367:	e8 ec f0 ff ff       	call   80109458 <i8254_send>
8010a36c:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a36f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a372:	83 c0 36             	add    $0x36,%eax
8010a375:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a378:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a37b:	50                   	push   %eax
8010a37c:	ff 75 e0             	push   -0x20(%ebp)
8010a37f:	6a 00                	push   $0x0
8010a381:	6a 00                	push   $0x0
8010a383:	e8 5a 04 00 00       	call   8010a7e2 <http_proc>
8010a388:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a38b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a38e:	83 ec 0c             	sub    $0xc,%esp
8010a391:	50                   	push   %eax
8010a392:	6a 18                	push   $0x18
8010a394:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a397:	50                   	push   %eax
8010a398:	ff 75 e8             	push   -0x18(%ebp)
8010a39b:	ff 75 08             	push   0x8(%ebp)
8010a39e:	e8 e4 00 00 00       	call   8010a487 <tcp_pkt_create>
8010a3a3:	83 c4 20             	add    $0x20,%esp
8010a3a6:	eb 62                	jmp    8010a40a <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a3a8:	83 ec 0c             	sub    $0xc,%esp
8010a3ab:	6a 00                	push   $0x0
8010a3ad:	6a 10                	push   $0x10
8010a3af:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3b2:	50                   	push   %eax
8010a3b3:	ff 75 e8             	push   -0x18(%ebp)
8010a3b6:	ff 75 08             	push   0x8(%ebp)
8010a3b9:	e8 c9 00 00 00       	call   8010a487 <tcp_pkt_create>
8010a3be:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a3c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a3c4:	83 ec 08             	sub    $0x8,%esp
8010a3c7:	50                   	push   %eax
8010a3c8:	ff 75 e8             	push   -0x18(%ebp)
8010a3cb:	e8 88 f0 ff ff       	call   80109458 <i8254_send>
8010a3d0:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a3d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3d6:	83 c0 36             	add    $0x36,%eax
8010a3d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a3dc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a3df:	50                   	push   %eax
8010a3e0:	ff 75 e4             	push   -0x1c(%ebp)
8010a3e3:	6a 00                	push   $0x0
8010a3e5:	6a 00                	push   $0x0
8010a3e7:	e8 f6 03 00 00       	call   8010a7e2 <http_proc>
8010a3ec:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a3ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a3f2:	83 ec 0c             	sub    $0xc,%esp
8010a3f5:	50                   	push   %eax
8010a3f6:	6a 18                	push   $0x18
8010a3f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3fb:	50                   	push   %eax
8010a3fc:	ff 75 e8             	push   -0x18(%ebp)
8010a3ff:	ff 75 08             	push   0x8(%ebp)
8010a402:	e8 80 00 00 00       	call   8010a487 <tcp_pkt_create>
8010a407:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a40a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a40d:	83 ec 08             	sub    $0x8,%esp
8010a410:	50                   	push   %eax
8010a411:	ff 75 e8             	push   -0x18(%ebp)
8010a414:	e8 3f f0 ff ff       	call   80109458 <i8254_send>
8010a419:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a41c:	a1 a4 a8 11 80       	mov    0x8011a8a4,%eax
8010a421:	83 c0 01             	add    $0x1,%eax
8010a424:	a3 a4 a8 11 80       	mov    %eax,0x8011a8a4
8010a429:	eb 4a                	jmp    8010a475 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a42b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a42e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a432:	3c 10                	cmp    $0x10,%al
8010a434:	75 3f                	jne    8010a475 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a436:	a1 a8 a8 11 80       	mov    0x8011a8a8,%eax
8010a43b:	83 f8 01             	cmp    $0x1,%eax
8010a43e:	75 35                	jne    8010a475 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a440:	83 ec 0c             	sub    $0xc,%esp
8010a443:	6a 00                	push   $0x0
8010a445:	6a 01                	push   $0x1
8010a447:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a44a:	50                   	push   %eax
8010a44b:	ff 75 e8             	push   -0x18(%ebp)
8010a44e:	ff 75 08             	push   0x8(%ebp)
8010a451:	e8 31 00 00 00       	call   8010a487 <tcp_pkt_create>
8010a456:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a459:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a45c:	83 ec 08             	sub    $0x8,%esp
8010a45f:	50                   	push   %eax
8010a460:	ff 75 e8             	push   -0x18(%ebp)
8010a463:	e8 f0 ef ff ff       	call   80109458 <i8254_send>
8010a468:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a46b:	c7 05 a8 a8 11 80 00 	movl   $0x0,0x8011a8a8
8010a472:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a475:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a478:	83 ec 0c             	sub    $0xc,%esp
8010a47b:	50                   	push   %eax
8010a47c:	e8 69 87 ff ff       	call   80102bea <kfree>
8010a481:	83 c4 10             	add    $0x10,%esp
}
8010a484:	90                   	nop
8010a485:	c9                   	leave  
8010a486:	c3                   	ret    

8010a487 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a487:	55                   	push   %ebp
8010a488:	89 e5                	mov    %esp,%ebp
8010a48a:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a48d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a490:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a493:	8b 45 08             	mov    0x8(%ebp),%eax
8010a496:	83 c0 0e             	add    $0xe,%eax
8010a499:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a49c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a49f:	0f b6 00             	movzbl (%eax),%eax
8010a4a2:	0f b6 c0             	movzbl %al,%eax
8010a4a5:	83 e0 0f             	and    $0xf,%eax
8010a4a8:	c1 e0 02             	shl    $0x2,%eax
8010a4ab:	89 c2                	mov    %eax,%edx
8010a4ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4b0:	01 d0                	add    %edx,%eax
8010a4b2:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a4b5:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a4bb:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4be:	83 c0 0e             	add    $0xe,%eax
8010a4c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a4c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4c7:	83 c0 14             	add    $0x14,%eax
8010a4ca:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a4cd:	8b 45 18             	mov    0x18(%ebp),%eax
8010a4d0:	8d 50 36             	lea    0x36(%eax),%edx
8010a4d3:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4d6:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a4d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4db:	8d 50 06             	lea    0x6(%eax),%edx
8010a4de:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4e1:	83 ec 04             	sub    $0x4,%esp
8010a4e4:	6a 06                	push   $0x6
8010a4e6:	52                   	push   %edx
8010a4e7:	50                   	push   %eax
8010a4e8:	e8 4a ae ff ff       	call   80105337 <memmove>
8010a4ed:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a4f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4f3:	83 c0 06             	add    $0x6,%eax
8010a4f6:	83 ec 04             	sub    $0x4,%esp
8010a4f9:	6a 06                	push   $0x6
8010a4fb:	68 d0 a5 11 80       	push   $0x8011a5d0
8010a500:	50                   	push   %eax
8010a501:	e8 31 ae ff ff       	call   80105337 <memmove>
8010a506:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a509:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a50c:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a510:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a513:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a51a:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a51d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a520:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a524:	8b 45 18             	mov    0x18(%ebp),%eax
8010a527:	83 c0 28             	add    $0x28,%eax
8010a52a:	0f b7 c0             	movzwl %ax,%eax
8010a52d:	83 ec 0c             	sub    $0xc,%esp
8010a530:	50                   	push   %eax
8010a531:	e8 9b f8 ff ff       	call   80109dd1 <H2N_ushort>
8010a536:	83 c4 10             	add    $0x10,%esp
8010a539:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a53c:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a540:	0f b7 15 a0 a8 11 80 	movzwl 0x8011a8a0,%edx
8010a547:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a54a:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a54e:	0f b7 05 a0 a8 11 80 	movzwl 0x8011a8a0,%eax
8010a555:	83 c0 01             	add    $0x1,%eax
8010a558:	66 a3 a0 a8 11 80    	mov    %ax,0x8011a8a0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a55e:	83 ec 0c             	sub    $0xc,%esp
8010a561:	6a 00                	push   $0x0
8010a563:	e8 69 f8 ff ff       	call   80109dd1 <H2N_ushort>
8010a568:	83 c4 10             	add    $0x10,%esp
8010a56b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a56e:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a575:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a579:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a57c:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a583:	83 c0 0c             	add    $0xc,%eax
8010a586:	83 ec 04             	sub    $0x4,%esp
8010a589:	6a 04                	push   $0x4
8010a58b:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a590:	50                   	push   %eax
8010a591:	e8 a1 ad ff ff       	call   80105337 <memmove>
8010a596:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a599:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a59c:	8d 50 0c             	lea    0xc(%eax),%edx
8010a59f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5a2:	83 c0 10             	add    $0x10,%eax
8010a5a5:	83 ec 04             	sub    $0x4,%esp
8010a5a8:	6a 04                	push   $0x4
8010a5aa:	52                   	push   %edx
8010a5ab:	50                   	push   %eax
8010a5ac:	e8 86 ad ff ff       	call   80105337 <memmove>
8010a5b1:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a5b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5b7:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a5bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5c0:	83 ec 0c             	sub    $0xc,%esp
8010a5c3:	50                   	push   %eax
8010a5c4:	e8 08 f9 ff ff       	call   80109ed1 <ipv4_chksum>
8010a5c9:	83 c4 10             	add    $0x10,%esp
8010a5cc:	0f b7 c0             	movzwl %ax,%eax
8010a5cf:	83 ec 0c             	sub    $0xc,%esp
8010a5d2:	50                   	push   %eax
8010a5d3:	e8 f9 f7 ff ff       	call   80109dd1 <H2N_ushort>
8010a5d8:	83 c4 10             	add    $0x10,%esp
8010a5db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a5de:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a5e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5e5:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a5e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5ec:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a5ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5f2:	0f b7 10             	movzwl (%eax),%edx
8010a5f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5f8:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a5fc:	a1 a4 a8 11 80       	mov    0x8011a8a4,%eax
8010a601:	83 ec 0c             	sub    $0xc,%esp
8010a604:	50                   	push   %eax
8010a605:	e8 e9 f7 ff ff       	call   80109df3 <H2N_uint>
8010a60a:	83 c4 10             	add    $0x10,%esp
8010a60d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a610:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a613:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a616:	8b 40 04             	mov    0x4(%eax),%eax
8010a619:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a61f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a622:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a625:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a628:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a62c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a62f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a633:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a636:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a63a:	8b 45 14             	mov    0x14(%ebp),%eax
8010a63d:	89 c2                	mov    %eax,%edx
8010a63f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a642:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a645:	83 ec 0c             	sub    $0xc,%esp
8010a648:	68 90 38 00 00       	push   $0x3890
8010a64d:	e8 7f f7 ff ff       	call   80109dd1 <H2N_ushort>
8010a652:	83 c4 10             	add    $0x10,%esp
8010a655:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a658:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a65c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a65f:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a665:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a668:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a66e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a671:	83 ec 0c             	sub    $0xc,%esp
8010a674:	50                   	push   %eax
8010a675:	e8 1f 00 00 00       	call   8010a699 <tcp_chksum>
8010a67a:	83 c4 10             	add    $0x10,%esp
8010a67d:	83 c0 08             	add    $0x8,%eax
8010a680:	0f b7 c0             	movzwl %ax,%eax
8010a683:	83 ec 0c             	sub    $0xc,%esp
8010a686:	50                   	push   %eax
8010a687:	e8 45 f7 ff ff       	call   80109dd1 <H2N_ushort>
8010a68c:	83 c4 10             	add    $0x10,%esp
8010a68f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a692:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a696:	90                   	nop
8010a697:	c9                   	leave  
8010a698:	c3                   	ret    

8010a699 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a699:	55                   	push   %ebp
8010a69a:	89 e5                	mov    %esp,%ebp
8010a69c:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a69f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a6a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6a8:	83 c0 14             	add    $0x14,%eax
8010a6ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a6ae:	83 ec 04             	sub    $0x4,%esp
8010a6b1:	6a 04                	push   $0x4
8010a6b3:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a6b8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a6bb:	50                   	push   %eax
8010a6bc:	e8 76 ac ff ff       	call   80105337 <memmove>
8010a6c1:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a6c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6c7:	83 c0 0c             	add    $0xc,%eax
8010a6ca:	83 ec 04             	sub    $0x4,%esp
8010a6cd:	6a 04                	push   $0x4
8010a6cf:	50                   	push   %eax
8010a6d0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a6d3:	83 c0 04             	add    $0x4,%eax
8010a6d6:	50                   	push   %eax
8010a6d7:	e8 5b ac ff ff       	call   80105337 <memmove>
8010a6dc:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a6df:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a6e3:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a6e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6ea:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a6ee:	0f b7 c0             	movzwl %ax,%eax
8010a6f1:	83 ec 0c             	sub    $0xc,%esp
8010a6f4:	50                   	push   %eax
8010a6f5:	e8 b5 f6 ff ff       	call   80109daf <N2H_ushort>
8010a6fa:	83 c4 10             	add    $0x10,%esp
8010a6fd:	83 e8 14             	sub    $0x14,%eax
8010a700:	0f b7 c0             	movzwl %ax,%eax
8010a703:	83 ec 0c             	sub    $0xc,%esp
8010a706:	50                   	push   %eax
8010a707:	e8 c5 f6 ff ff       	call   80109dd1 <H2N_ushort>
8010a70c:	83 c4 10             	add    $0x10,%esp
8010a70f:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a713:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a71a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a71d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a720:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a727:	eb 33                	jmp    8010a75c <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a729:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a72c:	01 c0                	add    %eax,%eax
8010a72e:	89 c2                	mov    %eax,%edx
8010a730:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a733:	01 d0                	add    %edx,%eax
8010a735:	0f b6 00             	movzbl (%eax),%eax
8010a738:	0f b6 c0             	movzbl %al,%eax
8010a73b:	c1 e0 08             	shl    $0x8,%eax
8010a73e:	89 c2                	mov    %eax,%edx
8010a740:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a743:	01 c0                	add    %eax,%eax
8010a745:	8d 48 01             	lea    0x1(%eax),%ecx
8010a748:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a74b:	01 c8                	add    %ecx,%eax
8010a74d:	0f b6 00             	movzbl (%eax),%eax
8010a750:	0f b6 c0             	movzbl %al,%eax
8010a753:	01 d0                	add    %edx,%eax
8010a755:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a758:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a75c:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a760:	7e c7                	jle    8010a729 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a765:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a768:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a76f:	eb 33                	jmp    8010a7a4 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a771:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a774:	01 c0                	add    %eax,%eax
8010a776:	89 c2                	mov    %eax,%edx
8010a778:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a77b:	01 d0                	add    %edx,%eax
8010a77d:	0f b6 00             	movzbl (%eax),%eax
8010a780:	0f b6 c0             	movzbl %al,%eax
8010a783:	c1 e0 08             	shl    $0x8,%eax
8010a786:	89 c2                	mov    %eax,%edx
8010a788:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a78b:	01 c0                	add    %eax,%eax
8010a78d:	8d 48 01             	lea    0x1(%eax),%ecx
8010a790:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a793:	01 c8                	add    %ecx,%eax
8010a795:	0f b6 00             	movzbl (%eax),%eax
8010a798:	0f b6 c0             	movzbl %al,%eax
8010a79b:	01 d0                	add    %edx,%eax
8010a79d:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a7a0:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a7a4:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a7a8:	0f b7 c0             	movzwl %ax,%eax
8010a7ab:	83 ec 0c             	sub    $0xc,%esp
8010a7ae:	50                   	push   %eax
8010a7af:	e8 fb f5 ff ff       	call   80109daf <N2H_ushort>
8010a7b4:	83 c4 10             	add    $0x10,%esp
8010a7b7:	66 d1 e8             	shr    %ax
8010a7ba:	0f b7 c0             	movzwl %ax,%eax
8010a7bd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a7c0:	7c af                	jl     8010a771 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a7c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7c5:	c1 e8 10             	shr    $0x10,%eax
8010a7c8:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a7cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7ce:	f7 d0                	not    %eax
}
8010a7d0:	c9                   	leave  
8010a7d1:	c3                   	ret    

8010a7d2 <tcp_fin>:

void tcp_fin(){
8010a7d2:	55                   	push   %ebp
8010a7d3:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a7d5:	c7 05 a8 a8 11 80 01 	movl   $0x1,0x8011a8a8
8010a7dc:	00 00 00 
}
8010a7df:	90                   	nop
8010a7e0:	5d                   	pop    %ebp
8010a7e1:	c3                   	ret    

8010a7e2 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a7e2:	55                   	push   %ebp
8010a7e3:	89 e5                	mov    %esp,%ebp
8010a7e5:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a7e8:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7eb:	83 ec 04             	sub    $0x4,%esp
8010a7ee:	6a 00                	push   $0x0
8010a7f0:	68 ab c8 10 80       	push   $0x8010c8ab
8010a7f5:	50                   	push   %eax
8010a7f6:	e8 65 00 00 00       	call   8010a860 <http_strcpy>
8010a7fb:	83 c4 10             	add    $0x10,%esp
8010a7fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a801:	8b 45 10             	mov    0x10(%ebp),%eax
8010a804:	83 ec 04             	sub    $0x4,%esp
8010a807:	ff 75 f4             	push   -0xc(%ebp)
8010a80a:	68 be c8 10 80       	push   $0x8010c8be
8010a80f:	50                   	push   %eax
8010a810:	e8 4b 00 00 00       	call   8010a860 <http_strcpy>
8010a815:	83 c4 10             	add    $0x10,%esp
8010a818:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a81b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a81e:	83 ec 04             	sub    $0x4,%esp
8010a821:	ff 75 f4             	push   -0xc(%ebp)
8010a824:	68 d9 c8 10 80       	push   $0x8010c8d9
8010a829:	50                   	push   %eax
8010a82a:	e8 31 00 00 00       	call   8010a860 <http_strcpy>
8010a82f:	83 c4 10             	add    $0x10,%esp
8010a832:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a835:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a838:	83 e0 01             	and    $0x1,%eax
8010a83b:	85 c0                	test   %eax,%eax
8010a83d:	74 11                	je     8010a850 <http_proc+0x6e>
    char *payload = (char *)send;
8010a83f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a842:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a845:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a84b:	01 d0                	add    %edx,%eax
8010a84d:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a850:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a853:	8b 45 14             	mov    0x14(%ebp),%eax
8010a856:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a858:	e8 75 ff ff ff       	call   8010a7d2 <tcp_fin>
}
8010a85d:	90                   	nop
8010a85e:	c9                   	leave  
8010a85f:	c3                   	ret    

8010a860 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a860:	55                   	push   %ebp
8010a861:	89 e5                	mov    %esp,%ebp
8010a863:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a866:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a86d:	eb 20                	jmp    8010a88f <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a86f:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a872:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a875:	01 d0                	add    %edx,%eax
8010a877:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a87a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a87d:	01 ca                	add    %ecx,%edx
8010a87f:	89 d1                	mov    %edx,%ecx
8010a881:	8b 55 08             	mov    0x8(%ebp),%edx
8010a884:	01 ca                	add    %ecx,%edx
8010a886:	0f b6 00             	movzbl (%eax),%eax
8010a889:	88 02                	mov    %al,(%edx)
    i++;
8010a88b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a88f:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a892:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a895:	01 d0                	add    %edx,%eax
8010a897:	0f b6 00             	movzbl (%eax),%eax
8010a89a:	84 c0                	test   %al,%al
8010a89c:	75 d1                	jne    8010a86f <http_strcpy+0xf>
  }
  return i;
8010a89e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a8a1:	c9                   	leave  
8010a8a2:	c3                   	ret    
