
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
8010006f:	68 60 a9 10 80       	push   $0x8010a960
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 e4 4f 00 00       	call   80105062 <initlock>
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
801000bd:	68 67 a9 10 80       	push   $0x8010a967
801000c2:	50                   	push   %eax
801000c3:	e8 3d 4e 00 00       	call   80104f05 <initsleeplock>
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
80100101:	e8 7e 4f 00 00       	call   80105084 <acquire>
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
80100140:	e8 ad 4f 00 00       	call   801050f2 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 ea 4d 00 00       	call   80104f41 <acquiresleep>
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
801001c1:	e8 2c 4f 00 00       	call   801050f2 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 69 4d 00 00       	call   80104f41 <acquiresleep>
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
801001f5:	68 6e a9 10 80       	push   $0x8010a96e
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
8010024a:	e8 a4 4d 00 00       	call   80104ff3 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 7f a9 10 80       	push   $0x8010a97f
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
80100293:	e8 5b 4d 00 00       	call   80104ff3 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 86 a9 10 80       	push   $0x8010a986
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 ea 4c 00 00       	call   80104fa5 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 b9 4d 00 00       	call   80105084 <acquire>
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
80100336:	e8 b7 4d 00 00       	call   801050f2 <release>
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
80100410:	e8 6f 4c 00 00       	call   80105084 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 8d a9 10 80       	push   $0x8010a98d
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
80100510:	c7 45 ec 96 a9 10 80 	movl   $0x8010a996,-0x14(%ebp)
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
8010059e:	e8 4f 4b 00 00       	call   801050f2 <release>
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
801005c7:	68 9d a9 10 80       	push   $0x8010a99d
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
801005e6:	68 b1 a9 10 80       	push   $0x8010a9b1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 41 4b 00 00       	call   80105144 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 b3 a9 10 80       	push   $0x8010a9b3
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
801006a0:	e8 21 82 00 00       	call   801088c6 <graphic_scroll_up>
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
801006f3:	e8 ce 81 00 00       	call   801088c6 <graphic_scroll_up>
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
80100757:	e8 d5 81 00 00       	call   80108931 <font_render>
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
80100793:	e8 a5 65 00 00       	call   80106d3d <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 98 65 00 00       	call   80106d3d <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 8b 65 00 00       	call   80106d3d <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 7b 65 00 00       	call   80106d3d <uartputc>
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
801007eb:	e8 94 48 00 00       	call   80105084 <acquire>
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
8010093f:	e8 b9 42 00 00       	call   80104bfd <wakeup>
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
80100962:	e8 8b 47 00 00       	call   801050f2 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 46 43 00 00       	call   80104cbb <procdump>
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
8010099a:	e8 e5 46 00 00       	call   80105084 <acquire>
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
801009bb:	e8 32 47 00 00       	call   801050f2 <release>
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
801009e8:	e8 26 41 00 00       	call   80104b13 <sleep>
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
80100a66:	e8 87 46 00 00       	call   801050f2 <release>
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
80100aa2:	e8 dd 45 00 00       	call   80105084 <acquire>
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
80100ae4:	e8 09 46 00 00       	call   801050f2 <release>
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
80100b12:	68 b7 a9 10 80       	push   $0x8010a9b7
80100b17:	68 00 4a 11 80       	push   $0x80114a00
80100b1c:	e8 41 45 00 00       	call   80105062 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 4a 11 80 86 	movl   $0x80100a86,0x80114a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 4a 11 80 78 	movl   $0x80100978,0x80114a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 bf a9 10 80 	movl   $0x8010a9bf,-0xc(%ebp)
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
80100bb5:	68 d5 a9 10 80       	push   $0x8010a9d5
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
80100c11:	e8 23 71 00 00       	call   80107d39 <setupkvm>
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
80100cb7:	e8 76 74 00 00       	call   80108132 <allocuvm>
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
80100cfd:	e8 63 73 00 00       	call   80108065 <loaduvm>
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
80100d6c:	e8 c1 73 00 00       	call   80108132 <allocuvm>
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
80100d90:	e8 ff 75 00 00       	call   80108394 <clearpteu>
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
80100dc9:	e8 7a 47 00 00       	call   80105548 <strlen>
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
80100df6:	e8 4d 47 00 00       	call   80105548 <strlen>
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
80100e1c:	e8 12 77 00 00       	call   80108533 <copyout>
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
80100eb8:	e8 76 76 00 00       	call   80108533 <copyout>
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
80100f06:	e8 f2 45 00 00       	call   801054fd <safestrcpy>
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
80100f49:	e8 08 6f 00 00       	call   80107e56 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 9f 73 00 00       	call   801082fb <freevm>
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
80100f97:	e8 5f 73 00 00       	call   801082fb <freevm>
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
80100fc8:	68 e1 a9 10 80       	push   $0x8010a9e1
80100fcd:	68 a0 4a 11 80       	push   $0x80114aa0
80100fd2:	e8 8b 40 00 00       	call   80105062 <initlock>
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
80100feb:	e8 94 40 00 00       	call   80105084 <acquire>
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
80101018:	e8 d5 40 00 00       	call   801050f2 <release>
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
8010103b:	e8 b2 40 00 00       	call   801050f2 <release>
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
80101058:	e8 27 40 00 00       	call   80105084 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 e8 a9 10 80       	push   $0x8010a9e8
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
8010108e:	e8 5f 40 00 00       	call   801050f2 <release>
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
801010a9:	e8 d6 3f 00 00       	call   80105084 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 f0 a9 10 80       	push   $0x8010a9f0
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
801010e9:	e8 04 40 00 00       	call   801050f2 <release>
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
80101137:	e8 b6 3f 00 00       	call   801050f2 <release>
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
80101286:	68 fa a9 10 80       	push   $0x8010a9fa
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
80101389:	68 03 aa 10 80       	push   $0x8010aa03
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
801013bf:	68 13 aa 10 80       	push   $0x8010aa13
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
801013f7:	e8 bd 3f 00 00       	call   801053b9 <memmove>
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
8010143d:	e8 b8 3e 00 00       	call   801052fa <memset>
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
8010159c:	68 20 aa 10 80       	push   $0x8010aa20
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
80101627:	68 36 aa 10 80       	push   $0x8010aa36
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
8010168b:	68 49 aa 10 80       	push   $0x8010aa49
80101690:	68 60 54 11 80       	push   $0x80115460
80101695:	e8 c8 39 00 00       	call   80105062 <initlock>
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
801016c1:	68 50 aa 10 80       	push   $0x8010aa50
801016c6:	50                   	push   %eax
801016c7:	e8 39 38 00 00       	call   80104f05 <initsleeplock>
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
80101720:	68 58 aa 10 80       	push   $0x8010aa58
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
80101799:	e8 5c 3b 00 00       	call   801052fa <memset>
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
80101801:	68 ab aa 10 80       	push   $0x8010aaab
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
801018a7:	e8 0d 3b 00 00       	call   801053b9 <memmove>
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
801018dc:	e8 a3 37 00 00       	call   80105084 <acquire>
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
8010192a:	e8 c3 37 00 00       	call   801050f2 <release>
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
80101966:	68 bd aa 10 80       	push   $0x8010aabd
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
801019a3:	e8 4a 37 00 00       	call   801050f2 <release>
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
801019be:	e8 c1 36 00 00       	call   80105084 <acquire>
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
801019dd:	e8 10 37 00 00       	call   801050f2 <release>
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
80101a03:	68 cd aa 10 80       	push   $0x8010aacd
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 25 35 00 00       	call   80104f41 <acquiresleep>
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
80101ac1:	e8 f3 38 00 00       	call   801053b9 <memmove>
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
80101af0:	68 d3 aa 10 80       	push   $0x8010aad3
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
80101b13:	e8 db 34 00 00       	call   80104ff3 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 e2 aa 10 80       	push   $0x8010aae2
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 60 34 00 00       	call   80104fa5 <releasesleep>
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
80101b5b:	e8 e1 33 00 00       	call   80104f41 <acquiresleep>
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
80101b81:	e8 fe 34 00 00       	call   80105084 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 54 11 80       	push   $0x80115460
80101b9a:	e8 53 35 00 00       	call   801050f2 <release>
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
80101be1:	e8 bf 33 00 00       	call   80104fa5 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 54 11 80       	push   $0x80115460
80101bf1:	e8 8e 34 00 00       	call   80105084 <acquire>
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
80101c10:	e8 dd 34 00 00       	call   801050f2 <release>
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
80101d54:	68 ea aa 10 80       	push   $0x8010aaea
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
80101ff2:	e8 c2 33 00 00       	call   801053b9 <memmove>
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
80102142:	e8 72 32 00 00       	call   801053b9 <memmove>
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
801021c2:	e8 88 32 00 00       	call   8010544f <strncmp>
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
801021e2:	68 fd aa 10 80       	push   $0x8010aafd
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
80102211:	68 0f ab 10 80       	push   $0x8010ab0f
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
801022e6:	68 1e ab 10 80       	push   $0x8010ab1e
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
80102321:	e8 7f 31 00 00       	call   801054a5 <strncpy>
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
8010234d:	68 2b ab 10 80       	push   $0x8010ab2b
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
801023bf:	e8 f5 2f 00 00       	call   801053b9 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 de 2f 00 00       	call   801053b9 <memmove>
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
8010262c:	68 33 ab 10 80       	push   $0x8010ab33
80102631:	68 c0 70 11 80       	push   $0x801170c0
80102636:	e8 27 2a 00 00       	call   80105062 <initlock>
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
801026d3:	68 37 ab 10 80       	push   $0x8010ab37
801026d8:	e8 cc de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026dd:	8b 45 08             	mov    0x8(%ebp),%eax
801026e0:	8b 40 08             	mov    0x8(%eax),%eax
801026e3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e8:	76 0d                	jbe    801026f7 <idestart+0x33>
    panic("incorrect blockno");
801026ea:	83 ec 0c             	sub    $0xc,%esp
801026ed:	68 40 ab 10 80       	push   $0x8010ab40
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
80102740:	68 37 ab 10 80       	push   $0x8010ab37
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
80102864:	e8 1b 28 00 00       	call   80105084 <acquire>
80102869:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010286c:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102871:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102874:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102878:	75 15                	jne    8010288f <ideintr+0x39>
    release(&idelock);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 c0 70 11 80       	push   $0x801170c0
80102882:	e8 6b 28 00 00       	call   801050f2 <release>
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
801028f7:	e8 01 23 00 00       	call   80104bfd <wakeup>
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
80102921:	e8 cc 27 00 00       	call   801050f2 <release>
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
80102942:	68 52 ab 10 80       	push   $0x8010ab52
80102947:	e8 a8 da ff ff       	call   801003f4 <cprintf>
8010294c:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	83 c0 0c             	add    $0xc,%eax
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	50                   	push   %eax
80102959:	e8 95 26 00 00       	call   80104ff3 <holdingsleep>
8010295e:	83 c4 10             	add    $0x10,%esp
80102961:	85 c0                	test   %eax,%eax
80102963:	75 0d                	jne    80102972 <iderw+0x47>
    panic("iderw: buf not locked");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 6c ab 10 80       	push   $0x8010ab6c
8010296d:	e8 37 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	8b 00                	mov    (%eax),%eax
80102977:	83 e0 06             	and    $0x6,%eax
8010297a:	83 f8 02             	cmp    $0x2,%eax
8010297d:	75 0d                	jne    8010298c <iderw+0x61>
    panic("iderw: nothing to do");
8010297f:	83 ec 0c             	sub    $0xc,%esp
80102982:	68 82 ab 10 80       	push   $0x8010ab82
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
801029a2:	68 97 ab 10 80       	push   $0x8010ab97
801029a7:	e8 fd db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ac:	83 ec 0c             	sub    $0xc,%esp
801029af:	68 c0 70 11 80       	push   $0x801170c0
801029b4:	e8 cb 26 00 00       	call   80105084 <acquire>
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
80102a10:	e8 fe 20 00 00       	call   80104b13 <sleep>
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
80102a2d:	e8 c0 26 00 00       	call   801050f2 <release>
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
80102ab1:	68 b8 ab 10 80       	push   $0x8010abb8
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
80102b58:	68 ea ab 10 80       	push   $0x8010abea
80102b5d:	68 00 71 11 80       	push   $0x80117100
80102b62:	e8 fb 24 00 00       	call   80105062 <initlock>
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
80102c17:	68 ef ab 10 80       	push   $0x8010abef
80102c1c:	e8 88 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c21:	83 ec 04             	sub    $0x4,%esp
80102c24:	68 00 10 00 00       	push   $0x1000
80102c29:	6a 01                	push   $0x1
80102c2b:	ff 75 08             	push   0x8(%ebp)
80102c2e:	e8 c7 26 00 00       	call   801052fa <memset>
80102c33:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c36:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c3b:	85 c0                	test   %eax,%eax
80102c3d:	74 10                	je     80102c4f <kfree+0x65>
    acquire(&kmem.lock);
80102c3f:	83 ec 0c             	sub    $0xc,%esp
80102c42:	68 00 71 11 80       	push   $0x80117100
80102c47:	e8 38 24 00 00       	call   80105084 <acquire>
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
80102c79:	e8 74 24 00 00       	call   801050f2 <release>
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
80102c9b:	e8 e4 23 00 00       	call   80105084 <acquire>
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
80102ccc:	e8 21 24 00 00       	call   801050f2 <release>
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
801031f6:	e8 66 21 00 00       	call   80105361 <memcmp>
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
8010330a:	68 f5 ab 10 80       	push   $0x8010abf5
8010330f:	68 60 71 11 80       	push   $0x80117160
80103314:	e8 49 1d 00 00       	call   80105062 <initlock>
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
801033bf:	e8 f5 1f 00 00       	call   801053b9 <memmove>
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
8010352e:	e8 51 1b 00 00       	call   80105084 <acquire>
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
8010354c:	e8 c2 15 00 00       	call   80104b13 <sleep>
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
80103581:	e8 8d 15 00 00       	call   80104b13 <sleep>
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
801035a0:	e8 4d 1b 00 00       	call   801050f2 <release>
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
801035c1:	e8 be 1a 00 00       	call   80105084 <acquire>
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
801035e2:	68 f9 ab 10 80       	push   $0x8010abf9
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
80103610:	e8 e8 15 00 00       	call   80104bfd <wakeup>
80103615:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103618:	83 ec 0c             	sub    $0xc,%esp
8010361b:	68 60 71 11 80       	push   $0x80117160
80103620:	e8 cd 1a 00 00       	call   801050f2 <release>
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
8010363b:	e8 44 1a 00 00       	call   80105084 <acquire>
80103640:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103643:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364a:	00 00 00 
    wakeup(&log);
8010364d:	83 ec 0c             	sub    $0xc,%esp
80103650:	68 60 71 11 80       	push   $0x80117160
80103655:	e8 a3 15 00 00       	call   80104bfd <wakeup>
8010365a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	68 60 71 11 80       	push   $0x80117160
80103665:	e8 88 1a 00 00       	call   801050f2 <release>
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
801036e1:	e8 d3 1c 00 00       	call   801053b9 <memmove>
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
8010377e:	68 08 ac 10 80       	push   $0x8010ac08
80103783:	e8 21 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103788:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378d:	85 c0                	test   %eax,%eax
8010378f:	7f 0d                	jg     8010379e <log_write+0x45>
    panic("log_write outside of trans");
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 1e ac 10 80       	push   $0x8010ac1e
80103799:	e8 0b ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 71 11 80       	push   $0x80117160
801037a6:	e8 d9 18 00 00       	call   80105084 <acquire>
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
80103824:	e8 c9 18 00 00       	call   801050f2 <release>
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
8010385a:	e8 ac 4f 00 00       	call   8010880b <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010385f:	83 ec 08             	sub    $0x8,%esp
80103862:	68 00 00 40 80       	push   $0x80400000
80103867:	68 00 c0 11 80       	push   $0x8011c000
8010386c:	e8 de f2 ff ff       	call   80102b4f <kinit1>
80103871:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103874:	e8 ac 45 00 00       	call   80107e25 <kvmalloc>
  mpinit_uefi();
80103879:	e8 53 4d 00 00       	call   801085d1 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010387e:	e8 3c f6 ff ff       	call   80102ebf <lapicinit>
  seginit();       // segment descriptors
80103883:	e8 35 40 00 00       	call   801078bd <seginit>
  picinit();    // disable pic
80103888:	e8 9d 01 00 00       	call   80103a2a <picinit>
  ioapicinit();    // another interrupt controller
8010388d:	e8 d8 f1 ff ff       	call   80102a6a <ioapicinit>
  consoleinit();   // console hardware
80103892:	e8 68 d2 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
80103897:	e8 ba 33 00 00       	call   80106c56 <uartinit>
  pinit();         // process table
8010389c:	e8 c2 05 00 00       	call   80103e63 <pinit>
  tvinit();        // trap vectors
801038a1:	e8 a0 2e 00 00       	call   80106746 <tvinit>
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
801038cf:	e8 90 51 00 00       	call   80108a64 <pci_init>
  arp_scan();
801038d4:	e8 c7 5e 00 00       	call   801097a0 <arp_scan>
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
801038e9:	e8 4f 45 00 00       	call   80107e3d <switchkvm>
  seginit();
801038ee:	e8 ca 3f 00 00       	call   801078bd <seginit>
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
80103915:	68 39 ac 10 80       	push   $0x8010ac39
8010391a:	e8 d5 ca ff ff       	call   801003f4 <cprintf>
8010391f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103922:	e8 95 2f 00 00       	call   801068bc <idtinit>
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
80103962:	e8 52 1a 00 00       	call   801053b9 <memmove>
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
80103aeb:	68 4d ac 10 80       	push   $0x8010ac4d
80103af0:	50                   	push   %eax
80103af1:	e8 6c 15 00 00       	call   80105062 <initlock>
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
80103bb0:	e8 cf 14 00 00       	call   80105084 <acquire>
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
80103bd7:	e8 21 10 00 00       	call   80104bfd <wakeup>
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
80103bfa:	e8 fe 0f 00 00       	call   80104bfd <wakeup>
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
80103c23:	e8 ca 14 00 00       	call   801050f2 <release>
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
80103c42:	e8 ab 14 00 00       	call   801050f2 <release>
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
80103c5c:	e8 23 14 00 00       	call   80105084 <acquire>
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
80103c90:	e8 5d 14 00 00       	call   801050f2 <release>
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
80103cae:	e8 4a 0f 00 00       	call   80104bfd <wakeup>
80103cb3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103cbc:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc2:	83 ec 08             	sub    $0x8,%esp
80103cc5:	50                   	push   %eax
80103cc6:	52                   	push   %edx
80103cc7:	e8 47 0e 00 00       	call   80104b13 <sleep>
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
80103d31:	e8 c7 0e 00 00       	call   80104bfd <wakeup>
80103d36:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d39:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3c:	83 ec 0c             	sub    $0xc,%esp
80103d3f:	50                   	push   %eax
80103d40:	e8 ad 13 00 00       	call   801050f2 <release>
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
80103d5d:	e8 22 13 00 00       	call   80105084 <acquire>
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
80103d7a:	e8 73 13 00 00       	call   801050f2 <release>
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
80103d9d:	e8 71 0d 00 00       	call   80104b13 <sleep>
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
80103e30:	e8 c8 0d 00 00       	call   80104bfd <wakeup>
80103e35:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	50                   	push   %eax
80103e3f:	e8 ae 12 00 00       	call   801050f2 <release>
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
80103e6c:	68 54 ac 10 80       	push   $0x8010ac54
80103e71:	68 40 72 11 80       	push   $0x80117240
80103e76:	e8 e7 11 00 00       	call   80105062 <initlock>
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
80103eb3:	68 5c ac 10 80       	push   $0x8010ac5c
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
80103f08:	68 82 ac 10 80       	push   $0x8010ac82
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
80103f1a:	e8 d0 12 00 00       	call   801051ef <pushcli>
  c = mycpu();
80103f1f:	e8 78 ff ff ff       	call   80103e9c <mycpu>
80103f24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f33:	e8 04 13 00 00       	call   8010523c <popcli>
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
80103f4b:	e8 34 11 00 00       	call   80105084 <acquire>
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
80103f7e:	e8 6f 11 00 00       	call   801050f2 <release>
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
80103fb7:	e8 36 11 00 00       	call   801050f2 <release>
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
80103fd7:	e8 1e 13 00 00       	call   801052fa <memset>
80103fdc:	83 c4 10             	add    $0x10,%esp
  memset(p->wait_ticks, 0, sizeof(p->wait_ticks)); // 초기화
80103fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe2:	05 90 00 00 00       	add    $0x90,%eax
80103fe7:	83 ec 04             	sub    $0x4,%esp
80103fea:	6a 10                	push   $0x10
80103fec:	6a 00                	push   $0x0
80103fee:	50                   	push   %eax
80103fef:	e8 06 13 00 00       	call   801052fa <memset>
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
8010403c:	ba 00 67 10 80       	mov    $0x80106700,%edx
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
80104061:	e8 94 12 00 00       	call   801052fa <memset>
80104066:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010406f:	ba cd 4a 10 80       	mov    $0x80104acd,%edx
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
80104092:	e8 a2 3c 00 00       	call   80107d39 <setupkvm>
80104097:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010409a:	89 42 04             	mov    %eax,0x4(%edx)
8010409d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a0:	8b 40 04             	mov    0x4(%eax),%eax
801040a3:	85 c0                	test   %eax,%eax
801040a5:	75 0d                	jne    801040b4 <userinit+0x38>
    panic("userinit: out of memory?");
801040a7:	83 ec 0c             	sub    $0xc,%esp
801040aa:	68 92 ac 10 80       	push   $0x8010ac92
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
801040c9:	e8 27 3f 00 00       	call   80107ff5 <inituvm>
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
801040e8:	e8 0d 12 00 00       	call   801052fa <memset>
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
80104162:	68 ab ac 10 80       	push   $0x8010acab
80104167:	50                   	push   %eax
80104168:	e8 90 13 00 00       	call   801054fd <safestrcpy>
8010416d:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104170:	83 ec 0c             	sub    $0xc,%esp
80104173:	68 b4 ac 10 80       	push   $0x8010acb4
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
8010418e:	e8 f1 0e 00 00       	call   80105084 <acquire>
80104193:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104199:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801041a0:	83 ec 0c             	sub    $0xc,%esp
801041a3:	68 40 72 11 80       	push   $0x80117240
801041a8:	e8 45 0f 00 00       	call   801050f2 <release>
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
801041e5:	e8 48 3f 00 00       	call   80108132 <allocuvm>
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
80104219:	e8 19 40 00 00       	call   80108237 <deallocuvm>
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
8010423f:	e8 12 3c 00 00       	call   80107e56 <switchuvm>
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
80104287:	e8 49 41 00 00       	call   801083d5 <copyuvm>
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
80104381:	e8 77 11 00 00       	call   801054fd <safestrcpy>
80104386:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104389:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010438c:	8b 40 10             	mov    0x10(%eax),%eax
8010438f:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104392:	83 ec 0c             	sub    $0xc,%esp
80104395:	68 40 72 11 80       	push   $0x80117240
8010439a:	e8 e5 0c 00 00       	call   80105084 <acquire>
8010439f:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801043a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043a5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801043ac:	83 ec 0c             	sub    $0xc,%esp
801043af:	68 40 72 11 80       	push   $0x80117240
801043b4:	e8 39 0d 00 00       	call   801050f2 <release>
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
801043e2:	68 b6 ac 10 80       	push   $0x8010acb6
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
80104468:	e8 17 0c 00 00       	call   80105084 <acquire>
8010446d:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104470:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104473:	8b 40 14             	mov    0x14(%eax),%eax
80104476:	83 ec 0c             	sub    $0xc,%esp
80104479:	50                   	push   %eax
8010447a:	e8 3b 07 00 00       	call   80104bba <wakeup1>
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
801044b6:	e8 ff 06 00 00       	call   80104bba <wakeup1>
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
801044d8:	e8 fd 04 00 00       	call   801049da <sched>
  panic("zombie exit");
801044dd:	83 ec 0c             	sub    $0xc,%esp
801044e0:	68 c3 ac 10 80       	push   $0x8010acc3
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
80104500:	e8 7f 0b 00 00       	call   80105084 <acquire>
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
8010456b:	e8 8b 3d 00 00       	call   801082fb <freevm>
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
801045aa:	e8 43 0b 00 00       	call   801050f2 <release>
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
801045e4:	e8 09 0b 00 00       	call   801050f2 <release>
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
801045fe:	e8 10 05 00 00       	call   80104b13 <sleep>
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
80104618:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
8010461b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010461e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104625:	00 00 00 

  for (;;) {
    sti();  // 인터럽트 허용
80104628:	e8 2f f8 ff ff       	call   80103e5c <sti>

    acquire(&ptable.lock);
8010462d:	83 ec 0c             	sub    $0xc,%esp
80104630:	68 40 72 11 80       	push   $0x80117240
80104635:	e8 4a 0a 00 00       	call   80105084 <acquire>
8010463a:	83 c4 10             	add    $0x10,%esp

    int policy = c->sched_policy;  // 현재 설정된 스케줄링 정책
8010463d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104640:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104646:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    
    //RR
    if (policy == 0) {
80104649:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
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
80104663:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104666:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104669:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
8010466f:	83 ec 0c             	sub    $0xc,%esp
80104672:	ff 75 f4             	push   -0xc(%ebp)
80104675:	e8 dc 37 00 00       	call   80107e56 <switchuvm>
8010467a:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
8010467d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104680:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
80104687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010468d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104690:	83 c2 04             	add    $0x4,%edx
80104693:	83 ec 08             	sub    $0x8,%esp
80104696:	50                   	push   %eax
80104697:	52                   	push   %edx
80104698:	e8 d2 0e 00 00       	call   8010556f <swtch>
8010469d:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801046a0:	e8 98 37 00 00       	call   80107e3d <switchkvm>
        c->proc = 0;
801046a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801046a8:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801046af:	00 00 00 
801046b2:	eb 01                	jmp    801046b5 <scheduler+0xa8>
          continue;
801046b4:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801046b5:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801046bc:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
801046c3:	72 93                	jb     80104658 <scheduler+0x4b>
801046c5:	e9 fb 02 00 00       	jmp    801049c5 <scheduler+0x3b8>
      }
    } else {
      // MLFQ

      // Boosting
      if (policy != 3) {
801046ca:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
801046ce:	0f 84 c1 00 00 00    	je     80104795 <scheduler+0x188>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801046d4:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801046db:	e9 a8 00 00 00       	jmp    80104788 <scheduler+0x17b>
          if (p->state != RUNNABLE)
801046e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e3:	8b 40 0c             	mov    0xc(%eax),%eax
801046e6:	83 f8 03             	cmp    $0x3,%eax
801046e9:	0f 85 91 00 00 00    	jne    80104780 <scheduler+0x173>
            continue;

          int curq = p->priority;
801046ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f2:	8b 40 7c             	mov    0x7c(%eax),%eax
801046f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
          int boost_limit[] = {500, 320, 160};
801046f8:	c7 45 c0 f4 01 00 00 	movl   $0x1f4,-0x40(%ebp)
801046ff:	c7 45 c4 40 01 00 00 	movl   $0x140,-0x3c(%ebp)
80104706:	c7 45 c8 a0 00 00 00 	movl   $0xa0,-0x38(%ebp)

          if (curq < 3 && p->wait_ticks[curq] >= boost_limit[3 - curq]){
8010470d:	83 7d e0 02          	cmpl   $0x2,-0x20(%ebp)
80104711:	7f 6e                	jg     80104781 <scheduler+0x174>
80104713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104716:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104719:	83 c2 24             	add    $0x24,%edx
8010471c:	8b 14 90             	mov    (%eax,%edx,4),%edx
8010471f:	b8 03 00 00 00       	mov    $0x3,%eax
80104724:	2b 45 e0             	sub    -0x20(%ebp),%eax
80104727:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
8010472b:	39 c2                	cmp    %eax,%edx
8010472d:	7c 52                	jl     80104781 <scheduler+0x174>
            p->priority++;
8010472f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104732:	8b 40 7c             	mov    0x7c(%eax),%eax
80104735:	8d 50 01             	lea    0x1(%eax),%edx
80104738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473b:	89 50 7c             	mov    %edx,0x7c(%eax)
            memset(p->wait_ticks, 0, sizeof(p->wait_ticks));
8010473e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104741:	05 90 00 00 00       	add    $0x90,%eax
80104746:	83 ec 04             	sub    $0x4,%esp
80104749:	6a 10                	push   $0x10
8010474b:	6a 00                	push   $0x0
8010474d:	50                   	push   %eax
8010474e:	e8 a7 0b 00 00       	call   801052fa <memset>
80104753:	83 c4 10             	add    $0x10,%esp
            cprintf("[BOOST] pid %d: wait_ticks = %d → Q%d\n", p->pid, p->wait_ticks[curq], p->priority);
80104756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104759:	8b 48 7c             	mov    0x7c(%eax),%ecx
8010475c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104762:	83 c2 24             	add    $0x24,%edx
80104765:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104768:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476b:	8b 40 10             	mov    0x10(%eax),%eax
8010476e:	51                   	push   %ecx
8010476f:	52                   	push   %edx
80104770:	50                   	push   %eax
80104771:	68 d0 ac 10 80       	push   $0x8010acd0
80104776:	e8 79 bc ff ff       	call   801003f4 <cprintf>
8010477b:	83 c4 10             	add    $0x10,%esp
8010477e:	eb 01                	jmp    80104781 <scheduler+0x174>
            continue;
80104780:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104781:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104788:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
8010478f:	0f 82 4b ff ff ff    	jb     801046e0 <scheduler+0xd3>
          }
        }
      }

      // Time slice 
      int slice[4] = { -1, 32, 16, 8 };
80104795:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
8010479c:	c7 45 d0 20 00 00 00 	movl   $0x20,-0x30(%ebp)
801047a3:	c7 45 d4 10 00 00 00 	movl   $0x10,-0x2c(%ebp)
801047aa:	c7 45 d8 08 00 00 00 	movl   $0x8,-0x28(%ebp)

      int done = 0;
801047b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

      // Q3부터 순차적으로 찾기
      for (int q = 3; q >= 0 && !done; q--) {
801047b8:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
801047bf:	e9 f1 01 00 00       	jmp    801049b5 <scheduler+0x3a8>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801047c4:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801047cb:	e9 d4 01 00 00       	jmp    801049a4 <scheduler+0x397>
          if (p->state != RUNNABLE || p->priority != q)
801047d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d3:	8b 40 0c             	mov    0xc(%eax),%eax
801047d6:	83 f8 03             	cmp    $0x3,%eax
801047d9:	0f 85 bd 01 00 00    	jne    8010499c <scheduler+0x38f>
801047df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e2:	8b 40 7c             	mov    0x7c(%eax),%eax
801047e5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047e8:	0f 85 ae 01 00 00    	jne    8010499c <scheduler+0x38f>
            continue;

          c->proc = p;
801047ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047f4:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
801047fa:	83 ec 0c             	sub    $0xc,%esp
801047fd:	ff 75 f4             	push   -0xc(%ebp)
80104800:	e8 51 36 00 00       	call   80107e56 <switchuvm>
80104805:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
80104808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480b:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
          cprintf("[SCHED] 선택된 pid: %d (Q%d)\n", p->pid, p->priority);  // 🔥 여기
80104812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104815:	8b 50 7c             	mov    0x7c(%eax),%edx
80104818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481b:	8b 40 10             	mov    0x10(%eax),%eax
8010481e:	83 ec 04             	sub    $0x4,%esp
80104821:	52                   	push   %edx
80104822:	50                   	push   %eax
80104823:	68 fc ac 10 80       	push   $0x8010acfc
80104828:	e8 c7 bb ff ff       	call   801003f4 <cprintf>
8010482d:	83 c4 10             	add    $0x10,%esp


          int pr = p -> priority;
80104830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104833:	8b 40 7c             	mov    0x7c(%eax),%eax
80104836:	89 45 dc             	mov    %eax,-0x24(%ebp)

          swtch(&(c->scheduler), p->context);
80104839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010483f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104842:	83 c2 04             	add    $0x4,%edx
80104845:	83 ec 08             	sub    $0x8,%esp
80104848:	50                   	push   %eax
80104849:	52                   	push   %edx
8010484a:	e8 20 0d 00 00       	call   8010556f <swtch>
8010484f:	83 c4 10             	add    $0x10,%esp
          switchkvm();
80104852:	e8 e6 35 00 00       	call   80107e3d <switchkvm>
          c->proc = 0;
80104857:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010485a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104861:	00 00 00 

          // 정책 2번: tick에 따라 강등
          if (policy == 2) {
80104864:	83 7d e4 02          	cmpl   $0x2,-0x1c(%ebp)
80104868:	0f 85 96 00 00 00    	jne    80104904 <scheduler+0x2f7>
            if ((pr == 3 && p->ticks[3] >= 8) ||
8010486e:	83 7d dc 03          	cmpl   $0x3,-0x24(%ebp)
80104872:	75 0e                	jne    80104882 <scheduler+0x275>
80104874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104877:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010487d:	83 f8 07             	cmp    $0x7,%eax
80104880:	7f 30                	jg     801048b2 <scheduler+0x2a5>
80104882:	83 7d dc 02          	cmpl   $0x2,-0x24(%ebp)
80104886:	75 0e                	jne    80104896 <scheduler+0x289>
                (pr == 2 && p->ticks[2] >= 16) ||
80104888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488b:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80104891:	83 f8 0f             	cmp    $0xf,%eax
80104894:	7f 1c                	jg     801048b2 <scheduler+0x2a5>
80104896:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
8010489a:	0f 85 f3 00 00 00    	jne    80104993 <scheduler+0x386>
                (pr == 1 && p->ticks[1] >= 32)) {
801048a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a3:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801048a9:	83 f8 1f             	cmp    $0x1f,%eax
801048ac:	0f 8e e1 00 00 00    	jle    80104993 <scheduler+0x386>

              if (p->priority > 0){
801048b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b5:	8b 40 7c             	mov    0x7c(%eax),%eax
801048b8:	85 c0                	test   %eax,%eax
801048ba:	7e 2d                	jle    801048e9 <scheduler+0x2dc>
                cprintf("[DEMOTE] pid %d: Q%d → Q%d\n", p->pid, pr, pr - 1);
801048bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048bf:	8d 50 ff             	lea    -0x1(%eax),%edx
801048c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c5:	8b 40 10             	mov    0x10(%eax),%eax
801048c8:	52                   	push   %edx
801048c9:	ff 75 dc             	push   -0x24(%ebp)
801048cc:	50                   	push   %eax
801048cd:	68 1d ad 10 80       	push   $0x8010ad1d
801048d2:	e8 1d bb ff ff       	call   801003f4 <cprintf>
801048d7:	83 c4 10             	add    $0x10,%esp
                p->priority--;
801048da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048dd:	8b 40 7c             	mov    0x7c(%eax),%eax
801048e0:	8d 50 ff             	lea    -0x1(%eax),%edx
801048e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e6:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
801048e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ec:	83 e8 80             	sub    $0xffffff80,%eax
801048ef:	83 ec 04             	sub    $0x4,%esp
801048f2:	6a 10                	push   $0x10
801048f4:	6a 00                	push   $0x0
801048f6:	50                   	push   %eax
801048f7:	e8 fe 09 00 00       	call   801052fa <memset>
801048fc:	83 c4 10             	add    $0x10,%esp
801048ff:	e9 8f 00 00 00       	jmp    80104993 <scheduler+0x386>
            }
          }

          // 정책 1 & 3: slice 기반 강등
          else {
            if ((pr == 3 && p->ticks[3] >= slice[3]) ||
80104904:	83 7d dc 03          	cmpl   $0x3,-0x24(%ebp)
80104908:	75 10                	jne    8010491a <scheduler+0x30d>
8010490a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490d:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80104913:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104916:	39 c2                	cmp    %eax,%edx
80104918:	7d 2c                	jge    80104946 <scheduler+0x339>
8010491a:	83 7d dc 02          	cmpl   $0x2,-0x24(%ebp)
8010491e:	75 10                	jne    80104930 <scheduler+0x323>
                (pr == 2 && p->ticks[2] >= slice[2]) ||
80104920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104923:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80104929:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010492c:	39 c2                	cmp    %eax,%edx
8010492e:	7d 16                	jge    80104946 <scheduler+0x339>
80104930:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
80104934:	75 5d                	jne    80104993 <scheduler+0x386>
                (pr == 1 && p->ticks[1] >= slice[1])) {
80104936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104939:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
8010493f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104942:	39 c2                	cmp    %eax,%edx
80104944:	7c 4d                	jl     80104993 <scheduler+0x386>
              if (p->priority > 0){
80104946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104949:	8b 40 7c             	mov    0x7c(%eax),%eax
8010494c:	85 c0                	test   %eax,%eax
8010494e:	7e 2d                	jle    8010497d <scheduler+0x370>
                cprintf("[DEMOTE] pid %d: Q%d → Q%d\n", p->pid, pr, pr - 1);
80104950:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104953:	8d 50 ff             	lea    -0x1(%eax),%edx
80104956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104959:	8b 40 10             	mov    0x10(%eax),%eax
8010495c:	52                   	push   %edx
8010495d:	ff 75 dc             	push   -0x24(%ebp)
80104960:	50                   	push   %eax
80104961:	68 1d ad 10 80       	push   $0x8010ad1d
80104966:	e8 89 ba ff ff       	call   801003f4 <cprintf>
8010496b:	83 c4 10             	add    $0x10,%esp

                p->priority--;
8010496e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104971:	8b 40 7c             	mov    0x7c(%eax),%eax
80104974:	8d 50 ff             	lea    -0x1(%eax),%edx
80104977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497a:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
8010497d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104980:	83 e8 80             	sub    $0xffffff80,%eax
80104983:	83 ec 04             	sub    $0x4,%esp
80104986:	6a 10                	push   $0x10
80104988:	6a 00                	push   $0x0
8010498a:	50                   	push   %eax
8010498b:	e8 6a 09 00 00       	call   801052fa <memset>
80104990:	83 c4 10             	add    $0x10,%esp

            }
          }

          done = 1;
80104993:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
          break;
8010499a:	eb 15                	jmp    801049b1 <scheduler+0x3a4>
            continue;
8010499c:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010499d:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801049a4:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
801049ab:	0f 82 1f fe ff ff    	jb     801047d0 <scheduler+0x1c3>
      for (int q = 3; q >= 0 && !done; q--) {
801049b1:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
801049b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801049b9:	78 0a                	js     801049c5 <scheduler+0x3b8>
801049bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049bf:	0f 84 ff fd ff ff    	je     801047c4 <scheduler+0x1b7>
        }
      }
    }

    release(&ptable.lock);
801049c5:	83 ec 0c             	sub    $0xc,%esp
801049c8:	68 40 72 11 80       	push   $0x80117240
801049cd:	e8 20 07 00 00       	call   801050f2 <release>
801049d2:	83 c4 10             	add    $0x10,%esp
  for (;;) {
801049d5:	e9 4e fc ff ff       	jmp    80104628 <scheduler+0x1b>

801049da <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801049da:	55                   	push   %ebp
801049db:	89 e5                	mov    %esp,%ebp
801049dd:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801049e0:	e8 2f f5 ff ff       	call   80103f14 <myproc>
801049e5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801049e8:	83 ec 0c             	sub    $0xc,%esp
801049eb:	68 40 72 11 80       	push   $0x80117240
801049f0:	e8 ca 07 00 00       	call   801051bf <holding>
801049f5:	83 c4 10             	add    $0x10,%esp
801049f8:	85 c0                	test   %eax,%eax
801049fa:	75 0d                	jne    80104a09 <sched+0x2f>
    panic("sched ptable.lock");
801049fc:	83 ec 0c             	sub    $0xc,%esp
801049ff:	68 3b ad 10 80       	push   $0x8010ad3b
80104a04:	e8 a0 bb ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104a09:	e8 8e f4 ff ff       	call   80103e9c <mycpu>
80104a0e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a14:	83 f8 01             	cmp    $0x1,%eax
80104a17:	74 0d                	je     80104a26 <sched+0x4c>
    panic("sched locks");
80104a19:	83 ec 0c             	sub    $0xc,%esp
80104a1c:	68 4d ad 10 80       	push   $0x8010ad4d
80104a21:	e8 83 bb ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a29:	8b 40 0c             	mov    0xc(%eax),%eax
80104a2c:	83 f8 04             	cmp    $0x4,%eax
80104a2f:	75 0d                	jne    80104a3e <sched+0x64>
    panic("sched running");
80104a31:	83 ec 0c             	sub    $0xc,%esp
80104a34:	68 59 ad 10 80       	push   $0x8010ad59
80104a39:	e8 6b bb ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104a3e:	e8 09 f4 ff ff       	call   80103e4c <readeflags>
80104a43:	25 00 02 00 00       	and    $0x200,%eax
80104a48:	85 c0                	test   %eax,%eax
80104a4a:	74 0d                	je     80104a59 <sched+0x7f>
    panic("sched interruptible");
80104a4c:	83 ec 0c             	sub    $0xc,%esp
80104a4f:	68 67 ad 10 80       	push   $0x8010ad67
80104a54:	e8 50 bb ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104a59:	e8 3e f4 ff ff       	call   80103e9c <mycpu>
80104a5e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104a67:	e8 30 f4 ff ff       	call   80103e9c <mycpu>
80104a6c:	8b 40 04             	mov    0x4(%eax),%eax
80104a6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a72:	83 c2 1c             	add    $0x1c,%edx
80104a75:	83 ec 08             	sub    $0x8,%esp
80104a78:	50                   	push   %eax
80104a79:	52                   	push   %edx
80104a7a:	e8 f0 0a 00 00       	call   8010556f <swtch>
80104a7f:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104a82:	e8 15 f4 ff ff       	call   80103e9c <mycpu>
80104a87:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a8a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104a90:	90                   	nop
80104a91:	c9                   	leave  
80104a92:	c3                   	ret    

80104a93 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104a93:	55                   	push   %ebp
80104a94:	89 e5                	mov    %esp,%ebp
80104a96:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104a99:	83 ec 0c             	sub    $0xc,%esp
80104a9c:	68 40 72 11 80       	push   $0x80117240
80104aa1:	e8 de 05 00 00       	call   80105084 <acquire>
80104aa6:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104aa9:	e8 66 f4 ff ff       	call   80103f14 <myproc>
80104aae:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ab5:	e8 20 ff ff ff       	call   801049da <sched>
  release(&ptable.lock);
80104aba:	83 ec 0c             	sub    $0xc,%esp
80104abd:	68 40 72 11 80       	push   $0x80117240
80104ac2:	e8 2b 06 00 00       	call   801050f2 <release>
80104ac7:	83 c4 10             	add    $0x10,%esp
}
80104aca:	90                   	nop
80104acb:	c9                   	leave  
80104acc:	c3                   	ret    

80104acd <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104acd:	55                   	push   %ebp
80104ace:	89 e5                	mov    %esp,%ebp
80104ad0:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ad3:	83 ec 0c             	sub    $0xc,%esp
80104ad6:	68 40 72 11 80       	push   $0x80117240
80104adb:	e8 12 06 00 00       	call   801050f2 <release>
80104ae0:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104ae3:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104ae8:	85 c0                	test   %eax,%eax
80104aea:	74 24                	je     80104b10 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104aec:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104af3:	00 00 00 
    iinit(ROOTDEV);
80104af6:	83 ec 0c             	sub    $0xc,%esp
80104af9:	6a 01                	push   $0x1
80104afb:	e8 78 cb ff ff       	call   80101678 <iinit>
80104b00:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104b03:	83 ec 0c             	sub    $0xc,%esp
80104b06:	6a 01                	push   $0x1
80104b08:	e8 f4 e7 ff ff       	call   80103301 <initlog>
80104b0d:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104b10:	90                   	nop
80104b11:	c9                   	leave  
80104b12:	c3                   	ret    

80104b13 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104b13:	55                   	push   %ebp
80104b14:	89 e5                	mov    %esp,%ebp
80104b16:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104b19:	e8 f6 f3 ff ff       	call   80103f14 <myproc>
80104b1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104b21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104b25:	75 0d                	jne    80104b34 <sleep+0x21>
    panic("sleep");
80104b27:	83 ec 0c             	sub    $0xc,%esp
80104b2a:	68 7b ad 10 80       	push   $0x8010ad7b
80104b2f:	e8 75 ba ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104b34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b38:	75 0d                	jne    80104b47 <sleep+0x34>
    panic("sleep without lk");
80104b3a:	83 ec 0c             	sub    $0xc,%esp
80104b3d:	68 81 ad 10 80       	push   $0x8010ad81
80104b42:	e8 62 ba ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104b47:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104b4e:	74 1e                	je     80104b6e <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104b50:	83 ec 0c             	sub    $0xc,%esp
80104b53:	68 40 72 11 80       	push   $0x80117240
80104b58:	e8 27 05 00 00       	call   80105084 <acquire>
80104b5d:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104b60:	83 ec 0c             	sub    $0xc,%esp
80104b63:	ff 75 0c             	push   0xc(%ebp)
80104b66:	e8 87 05 00 00       	call   801050f2 <release>
80104b6b:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b71:	8b 55 08             	mov    0x8(%ebp),%edx
80104b74:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104b81:	e8 54 fe ff ff       	call   801049da <sched>

  // Tidy up.
  p->chan = 0;
80104b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b89:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104b90:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104b97:	74 1e                	je     80104bb7 <sleep+0xa4>
    release(&ptable.lock);
80104b99:	83 ec 0c             	sub    $0xc,%esp
80104b9c:	68 40 72 11 80       	push   $0x80117240
80104ba1:	e8 4c 05 00 00       	call   801050f2 <release>
80104ba6:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104ba9:	83 ec 0c             	sub    $0xc,%esp
80104bac:	ff 75 0c             	push   0xc(%ebp)
80104baf:	e8 d0 04 00 00       	call   80105084 <acquire>
80104bb4:	83 c4 10             	add    $0x10,%esp
  }
}
80104bb7:	90                   	nop
80104bb8:	c9                   	leave  
80104bb9:	c3                   	ret    

80104bba <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104bba:	55                   	push   %ebp
80104bbb:	89 e5                	mov    %esp,%ebp
80104bbd:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bc0:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
80104bc7:	eb 27                	jmp    80104bf0 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104bc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bcc:	8b 40 0c             	mov    0xc(%eax),%eax
80104bcf:	83 f8 02             	cmp    $0x2,%eax
80104bd2:	75 15                	jne    80104be9 <wakeup1+0x2f>
80104bd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bd7:	8b 40 20             	mov    0x20(%eax),%eax
80104bda:	39 45 08             	cmp    %eax,0x8(%ebp)
80104bdd:	75 0a                	jne    80104be9 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104bdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104be2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104be9:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
80104bf0:	81 7d fc 74 9a 11 80 	cmpl   $0x80119a74,-0x4(%ebp)
80104bf7:	72 d0                	jb     80104bc9 <wakeup1+0xf>
}
80104bf9:	90                   	nop
80104bfa:	90                   	nop
80104bfb:	c9                   	leave  
80104bfc:	c3                   	ret    

80104bfd <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104bfd:	55                   	push   %ebp
80104bfe:	89 e5                	mov    %esp,%ebp
80104c00:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104c03:	83 ec 0c             	sub    $0xc,%esp
80104c06:	68 40 72 11 80       	push   $0x80117240
80104c0b:	e8 74 04 00 00       	call   80105084 <acquire>
80104c10:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104c13:	83 ec 0c             	sub    $0xc,%esp
80104c16:	ff 75 08             	push   0x8(%ebp)
80104c19:	e8 9c ff ff ff       	call   80104bba <wakeup1>
80104c1e:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104c21:	83 ec 0c             	sub    $0xc,%esp
80104c24:	68 40 72 11 80       	push   $0x80117240
80104c29:	e8 c4 04 00 00       	call   801050f2 <release>
80104c2e:	83 c4 10             	add    $0x10,%esp
}
80104c31:	90                   	nop
80104c32:	c9                   	leave  
80104c33:	c3                   	ret    

80104c34 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104c34:	55                   	push   %ebp
80104c35:	89 e5                	mov    %esp,%ebp
80104c37:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104c3a:	83 ec 0c             	sub    $0xc,%esp
80104c3d:	68 40 72 11 80       	push   $0x80117240
80104c42:	e8 3d 04 00 00       	call   80105084 <acquire>
80104c47:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c4a:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104c51:	eb 48                	jmp    80104c9b <kill+0x67>
    if(p->pid == pid){
80104c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c56:	8b 40 10             	mov    0x10(%eax),%eax
80104c59:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c5c:	75 36                	jne    80104c94 <kill+0x60>
      p->killed = 1;
80104c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c61:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c6e:	83 f8 02             	cmp    $0x2,%eax
80104c71:	75 0a                	jne    80104c7d <kill+0x49>
        p->state = RUNNABLE;
80104c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c76:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104c7d:	83 ec 0c             	sub    $0xc,%esp
80104c80:	68 40 72 11 80       	push   $0x80117240
80104c85:	e8 68 04 00 00       	call   801050f2 <release>
80104c8a:	83 c4 10             	add    $0x10,%esp
      return 0;
80104c8d:	b8 00 00 00 00       	mov    $0x0,%eax
80104c92:	eb 25                	jmp    80104cb9 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c94:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104c9b:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80104ca2:	72 af                	jb     80104c53 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104ca4:	83 ec 0c             	sub    $0xc,%esp
80104ca7:	68 40 72 11 80       	push   $0x80117240
80104cac:	e8 41 04 00 00       	call   801050f2 <release>
80104cb1:	83 c4 10             	add    $0x10,%esp
  return -1;
80104cb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cb9:	c9                   	leave  
80104cba:	c3                   	ret    

80104cbb <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104cbb:	55                   	push   %ebp
80104cbc:	89 e5                	mov    %esp,%ebp
80104cbe:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cc1:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
80104cc8:	e9 da 00 00 00       	jmp    80104da7 <procdump+0xec>
    if(p->state == UNUSED)
80104ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cd0:	8b 40 0c             	mov    0xc(%eax),%eax
80104cd3:	85 c0                	test   %eax,%eax
80104cd5:	0f 84 c4 00 00 00    	je     80104d9f <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cde:	8b 40 0c             	mov    0xc(%eax),%eax
80104ce1:	83 f8 05             	cmp    $0x5,%eax
80104ce4:	77 23                	ja     80104d09 <procdump+0x4e>
80104ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ce9:	8b 40 0c             	mov    0xc(%eax),%eax
80104cec:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104cf3:	85 c0                	test   %eax,%eax
80104cf5:	74 12                	je     80104d09 <procdump+0x4e>
      state = states[p->state];
80104cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cfa:	8b 40 0c             	mov    0xc(%eax),%eax
80104cfd:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104d04:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d07:	eb 07                	jmp    80104d10 <procdump+0x55>
    else
      state = "???";
80104d09:	c7 45 ec 92 ad 10 80 	movl   $0x8010ad92,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d13:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d19:	8b 40 10             	mov    0x10(%eax),%eax
80104d1c:	52                   	push   %edx
80104d1d:	ff 75 ec             	push   -0x14(%ebp)
80104d20:	50                   	push   %eax
80104d21:	68 96 ad 10 80       	push   $0x8010ad96
80104d26:	e8 c9 b6 ff ff       	call   801003f4 <cprintf>
80104d2b:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d31:	8b 40 0c             	mov    0xc(%eax),%eax
80104d34:	83 f8 02             	cmp    $0x2,%eax
80104d37:	75 54                	jne    80104d8d <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d3c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d3f:	8b 40 0c             	mov    0xc(%eax),%eax
80104d42:	83 c0 08             	add    $0x8,%eax
80104d45:	89 c2                	mov    %eax,%edx
80104d47:	83 ec 08             	sub    $0x8,%esp
80104d4a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104d4d:	50                   	push   %eax
80104d4e:	52                   	push   %edx
80104d4f:	e8 f0 03 00 00       	call   80105144 <getcallerpcs>
80104d54:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104d57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d5e:	eb 1c                	jmp    80104d7c <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d63:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d67:	83 ec 08             	sub    $0x8,%esp
80104d6a:	50                   	push   %eax
80104d6b:	68 9f ad 10 80       	push   $0x8010ad9f
80104d70:	e8 7f b6 ff ff       	call   801003f4 <cprintf>
80104d75:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104d78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d7c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104d80:	7f 0b                	jg     80104d8d <procdump+0xd2>
80104d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d85:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d89:	85 c0                	test   %eax,%eax
80104d8b:	75 d3                	jne    80104d60 <procdump+0xa5>
    }
    cprintf("\n");
80104d8d:	83 ec 0c             	sub    $0xc,%esp
80104d90:	68 a3 ad 10 80       	push   $0x8010ada3
80104d95:	e8 5a b6 ff ff       	call   801003f4 <cprintf>
80104d9a:	83 c4 10             	add    $0x10,%esp
80104d9d:	eb 01                	jmp    80104da0 <procdump+0xe5>
      continue;
80104d9f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104da0:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
80104da7:	81 7d f0 74 9a 11 80 	cmpl   $0x80119a74,-0x10(%ebp)
80104dae:	0f 82 19 ff ff ff    	jb     80104ccd <procdump+0x12>
  }
}
80104db4:	90                   	nop
80104db5:	90                   	nop
80104db6:	c9                   	leave  
80104db7:	c3                   	ret    

80104db8 <setSchedPolicy>:

//  0 (RR), 1 (MLFQ), 2 (MLFQ-no-tracking), 3 (MLFQ-no-boosting)

int
setSchedPolicy(int policy)
{
80104db8:	55                   	push   %ebp
80104db9:	89 e5                	mov    %esp,%ebp
80104dbb:	83 ec 18             	sub    $0x18,%esp

  if (policy < 0 || policy > 3)
80104dbe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104dc2:	78 06                	js     80104dca <setSchedPolicy+0x12>
80104dc4:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104dc8:	7e 07                	jle    80104dd1 <setSchedPolicy+0x19>
    return -1;
80104dca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dcf:	eb 23                	jmp    80104df4 <setSchedPolicy+0x3c>

  pushcli();
80104dd1:	e8 19 04 00 00       	call   801051ef <pushcli>
  struct cpu *c = mycpu();
80104dd6:	e8 c1 f0 ff ff       	call   80103e9c <mycpu>
80104ddb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->sched_policy = policy;
80104dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de1:	8b 55 08             	mov    0x8(%ebp),%edx
80104de4:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104dea:	e8 4d 04 00 00       	call   8010523c <popcli>

  return 0;
80104def:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104df4:	c9                   	leave  
80104df5:	c3                   	ret    

80104df6 <getpinfo>:


int
getpinfo(struct pstat *ps)
{
80104df6:	55                   	push   %ebp
80104df7:	89 e5                	mov    %esp,%ebp
80104df9:	53                   	push   %ebx
80104dfa:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  int i = 0;
80104dfd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);  
80104e04:	83 ec 0c             	sub    $0xc,%esp
80104e07:	68 40 72 11 80       	push   $0x80117240
80104e0c:	e8 73 02 00 00       	call   80105084 <acquire>
80104e11:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
80104e14:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104e1b:	e9 be 00 00 00       	jmp    80104ede <getpinfo+0xe8>
    // 프로세스가 사용 중이면 1, 아니면 0
    ps->inuse[i] = (p->state != UNUSED);
80104e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e23:	8b 40 0c             	mov    0xc(%eax),%eax
80104e26:	85 c0                	test   %eax,%eax
80104e28:	0f 95 c0             	setne  %al
80104e2b:	0f b6 c8             	movzbl %al,%ecx
80104e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e34:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // pid 저장
    ps->pid[i] = p->pid;
80104e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3a:	8b 50 10             	mov    0x10(%eax),%edx
80104e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e40:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104e43:	83 c1 40             	add    $0x40,%ecx
80104e46:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 우선순위 저장 
    ps->priority[i] = p->priority;
80104e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4c:	8b 50 7c             	mov    0x7c(%eax),%edx
80104e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e52:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104e55:	83 e9 80             	sub    $0xffffff80,%ecx
80104e58:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 상태 저장 
    ps->state[i] = p->state;
80104e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5e:	8b 40 0c             	mov    0xc(%eax),%eax
80104e61:	89 c1                	mov    %eax,%ecx
80104e63:	8b 45 08             	mov    0x8(%ebp),%eax
80104e66:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e69:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80104e6f:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // 각 큐에서 실행된 tick 수 저장
    for (int j = 0; j < 4; j++) {
80104e72:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104e79:	eb 52                	jmp    80104ecd <getpinfo+0xd7>
      ps->ticks[i][j] = p->ticks[j];
80104e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104e81:	83 c2 20             	add    $0x20,%edx
80104e84:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104e87:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104e8d:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104e94:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104e97:	01 d9                	add    %ebx,%ecx
80104e99:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104e9f:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
80104ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104ea8:	83 c2 24             	add    $0x24,%edx
80104eab:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104eae:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104eb4:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104ebb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104ebe:	01 d9                	add    %ebx,%ecx
80104ec0:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104ec6:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104ec9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104ecd:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
80104ed1:	7e a8                	jle    80104e7b <getpinfo+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
80104ed3:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104eda:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104ede:	81 7d f4 74 9a 11 80 	cmpl   $0x80119a74,-0xc(%ebp)
80104ee5:	0f 82 35 ff ff ff    	jb     80104e20 <getpinfo+0x2a>
    }
  }

  release(&ptable.lock);  
80104eeb:	83 ec 0c             	sub    $0xc,%esp
80104eee:	68 40 72 11 80       	push   $0x80117240
80104ef3:	e8 fa 01 00 00       	call   801050f2 <release>
80104ef8:	83 c4 10             	add    $0x10,%esp

  return 0; 
80104efb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f03:	c9                   	leave  
80104f04:	c3                   	ret    

80104f05 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104f05:	55                   	push   %ebp
80104f06:	89 e5                	mov    %esp,%ebp
80104f08:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0e:	83 c0 04             	add    $0x4,%eax
80104f11:	83 ec 08             	sub    $0x8,%esp
80104f14:	68 cf ad 10 80       	push   $0x8010adcf
80104f19:	50                   	push   %eax
80104f1a:	e8 43 01 00 00       	call   80105062 <initlock>
80104f1f:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104f22:	8b 45 08             	mov    0x8(%ebp),%eax
80104f25:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f28:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f34:	8b 45 08             	mov    0x8(%ebp),%eax
80104f37:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104f3e:	90                   	nop
80104f3f:	c9                   	leave  
80104f40:	c3                   	ret    

80104f41 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104f41:	55                   	push   %ebp
80104f42:	89 e5                	mov    %esp,%ebp
80104f44:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f47:	8b 45 08             	mov    0x8(%ebp),%eax
80104f4a:	83 c0 04             	add    $0x4,%eax
80104f4d:	83 ec 0c             	sub    $0xc,%esp
80104f50:	50                   	push   %eax
80104f51:	e8 2e 01 00 00       	call   80105084 <acquire>
80104f56:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f59:	eb 15                	jmp    80104f70 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5e:	83 c0 04             	add    $0x4,%eax
80104f61:	83 ec 08             	sub    $0x8,%esp
80104f64:	50                   	push   %eax
80104f65:	ff 75 08             	push   0x8(%ebp)
80104f68:	e8 a6 fb ff ff       	call   80104b13 <sleep>
80104f6d:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f70:	8b 45 08             	mov    0x8(%ebp),%eax
80104f73:	8b 00                	mov    (%eax),%eax
80104f75:	85 c0                	test   %eax,%eax
80104f77:	75 e2                	jne    80104f5b <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104f79:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104f82:	e8 8d ef ff ff       	call   80103f14 <myproc>
80104f87:	8b 50 10             	mov    0x10(%eax),%edx
80104f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8d:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104f90:	8b 45 08             	mov    0x8(%ebp),%eax
80104f93:	83 c0 04             	add    $0x4,%eax
80104f96:	83 ec 0c             	sub    $0xc,%esp
80104f99:	50                   	push   %eax
80104f9a:	e8 53 01 00 00       	call   801050f2 <release>
80104f9f:	83 c4 10             	add    $0x10,%esp
}
80104fa2:	90                   	nop
80104fa3:	c9                   	leave  
80104fa4:	c3                   	ret    

80104fa5 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104fa5:	55                   	push   %ebp
80104fa6:	89 e5                	mov    %esp,%ebp
80104fa8:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104fab:	8b 45 08             	mov    0x8(%ebp),%eax
80104fae:	83 c0 04             	add    $0x4,%eax
80104fb1:	83 ec 0c             	sub    $0xc,%esp
80104fb4:	50                   	push   %eax
80104fb5:	e8 ca 00 00 00       	call   80105084 <acquire>
80104fba:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104fd0:	83 ec 0c             	sub    $0xc,%esp
80104fd3:	ff 75 08             	push   0x8(%ebp)
80104fd6:	e8 22 fc ff ff       	call   80104bfd <wakeup>
80104fdb:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104fde:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe1:	83 c0 04             	add    $0x4,%eax
80104fe4:	83 ec 0c             	sub    $0xc,%esp
80104fe7:	50                   	push   %eax
80104fe8:	e8 05 01 00 00       	call   801050f2 <release>
80104fed:	83 c4 10             	add    $0x10,%esp
}
80104ff0:	90                   	nop
80104ff1:	c9                   	leave  
80104ff2:	c3                   	ret    

80104ff3 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104ff3:	55                   	push   %ebp
80104ff4:	89 e5                	mov    %esp,%ebp
80104ff6:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80104ffc:	83 c0 04             	add    $0x4,%eax
80104fff:	83 ec 0c             	sub    $0xc,%esp
80105002:	50                   	push   %eax
80105003:	e8 7c 00 00 00       	call   80105084 <acquire>
80105008:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
8010500b:	8b 45 08             	mov    0x8(%ebp),%eax
8010500e:	8b 00                	mov    (%eax),%eax
80105010:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105013:	8b 45 08             	mov    0x8(%ebp),%eax
80105016:	83 c0 04             	add    $0x4,%eax
80105019:	83 ec 0c             	sub    $0xc,%esp
8010501c:	50                   	push   %eax
8010501d:	e8 d0 00 00 00       	call   801050f2 <release>
80105022:	83 c4 10             	add    $0x10,%esp
  return r;
80105025:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105028:	c9                   	leave  
80105029:	c3                   	ret    

8010502a <readeflags>:
{
8010502a:	55                   	push   %ebp
8010502b:	89 e5                	mov    %esp,%ebp
8010502d:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105030:	9c                   	pushf  
80105031:	58                   	pop    %eax
80105032:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105035:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105038:	c9                   	leave  
80105039:	c3                   	ret    

8010503a <cli>:
{
8010503a:	55                   	push   %ebp
8010503b:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010503d:	fa                   	cli    
}
8010503e:	90                   	nop
8010503f:	5d                   	pop    %ebp
80105040:	c3                   	ret    

80105041 <sti>:
{
80105041:	55                   	push   %ebp
80105042:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105044:	fb                   	sti    
}
80105045:	90                   	nop
80105046:	5d                   	pop    %ebp
80105047:	c3                   	ret    

80105048 <xchg>:
{
80105048:	55                   	push   %ebp
80105049:	89 e5                	mov    %esp,%ebp
8010504b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010504e:	8b 55 08             	mov    0x8(%ebp),%edx
80105051:	8b 45 0c             	mov    0xc(%ebp),%eax
80105054:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105057:	f0 87 02             	lock xchg %eax,(%edx)
8010505a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010505d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105060:	c9                   	leave  
80105061:	c3                   	ret    

80105062 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105062:	55                   	push   %ebp
80105063:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105065:	8b 45 08             	mov    0x8(%ebp),%eax
80105068:	8b 55 0c             	mov    0xc(%ebp),%edx
8010506b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010506e:	8b 45 08             	mov    0x8(%ebp),%eax
80105071:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105077:	8b 45 08             	mov    0x8(%ebp),%eax
8010507a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105081:	90                   	nop
80105082:	5d                   	pop    %ebp
80105083:	c3                   	ret    

80105084 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105084:	55                   	push   %ebp
80105085:	89 e5                	mov    %esp,%ebp
80105087:	53                   	push   %ebx
80105088:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010508b:	e8 5f 01 00 00       	call   801051ef <pushcli>
  if(holding(lk)){
80105090:	8b 45 08             	mov    0x8(%ebp),%eax
80105093:	83 ec 0c             	sub    $0xc,%esp
80105096:	50                   	push   %eax
80105097:	e8 23 01 00 00       	call   801051bf <holding>
8010509c:	83 c4 10             	add    $0x10,%esp
8010509f:	85 c0                	test   %eax,%eax
801050a1:	74 0d                	je     801050b0 <acquire+0x2c>
    panic("acquire");
801050a3:	83 ec 0c             	sub    $0xc,%esp
801050a6:	68 da ad 10 80       	push   $0x8010adda
801050ab:	e8 f9 b4 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801050b0:	90                   	nop
801050b1:	8b 45 08             	mov    0x8(%ebp),%eax
801050b4:	83 ec 08             	sub    $0x8,%esp
801050b7:	6a 01                	push   $0x1
801050b9:	50                   	push   %eax
801050ba:	e8 89 ff ff ff       	call   80105048 <xchg>
801050bf:	83 c4 10             	add    $0x10,%esp
801050c2:	85 c0                	test   %eax,%eax
801050c4:	75 eb                	jne    801050b1 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801050c6:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801050cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
801050ce:	e8 c9 ed ff ff       	call   80103e9c <mycpu>
801050d3:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801050d6:	8b 45 08             	mov    0x8(%ebp),%eax
801050d9:	83 c0 0c             	add    $0xc,%eax
801050dc:	83 ec 08             	sub    $0x8,%esp
801050df:	50                   	push   %eax
801050e0:	8d 45 08             	lea    0x8(%ebp),%eax
801050e3:	50                   	push   %eax
801050e4:	e8 5b 00 00 00       	call   80105144 <getcallerpcs>
801050e9:	83 c4 10             	add    $0x10,%esp
}
801050ec:	90                   	nop
801050ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050f0:	c9                   	leave  
801050f1:	c3                   	ret    

801050f2 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050f2:	55                   	push   %ebp
801050f3:	89 e5                	mov    %esp,%ebp
801050f5:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050f8:	83 ec 0c             	sub    $0xc,%esp
801050fb:	ff 75 08             	push   0x8(%ebp)
801050fe:	e8 bc 00 00 00       	call   801051bf <holding>
80105103:	83 c4 10             	add    $0x10,%esp
80105106:	85 c0                	test   %eax,%eax
80105108:	75 0d                	jne    80105117 <release+0x25>
    panic("release");
8010510a:	83 ec 0c             	sub    $0xc,%esp
8010510d:	68 e2 ad 10 80       	push   $0x8010ade2
80105112:	e8 92 b4 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80105117:	8b 45 08             	mov    0x8(%ebp),%eax
8010511a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105121:	8b 45 08             	mov    0x8(%ebp),%eax
80105124:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010512b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105130:	8b 45 08             	mov    0x8(%ebp),%eax
80105133:	8b 55 08             	mov    0x8(%ebp),%edx
80105136:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010513c:	e8 fb 00 00 00       	call   8010523c <popcli>
}
80105141:	90                   	nop
80105142:	c9                   	leave  
80105143:	c3                   	ret    

80105144 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105144:	55                   	push   %ebp
80105145:	89 e5                	mov    %esp,%ebp
80105147:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010514a:	8b 45 08             	mov    0x8(%ebp),%eax
8010514d:	83 e8 08             	sub    $0x8,%eax
80105150:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105153:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010515a:	eb 38                	jmp    80105194 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010515c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105160:	74 53                	je     801051b5 <getcallerpcs+0x71>
80105162:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105169:	76 4a                	jbe    801051b5 <getcallerpcs+0x71>
8010516b:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010516f:	74 44                	je     801051b5 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105171:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105174:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010517b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010517e:	01 c2                	add    %eax,%edx
80105180:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105183:	8b 40 04             	mov    0x4(%eax),%eax
80105186:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105188:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010518b:	8b 00                	mov    (%eax),%eax
8010518d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105190:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105194:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105198:	7e c2                	jle    8010515c <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010519a:	eb 19                	jmp    801051b5 <getcallerpcs+0x71>
    pcs[i] = 0;
8010519c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010519f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a9:	01 d0                	add    %edx,%eax
801051ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801051b1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051b5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051b9:	7e e1                	jle    8010519c <getcallerpcs+0x58>
}
801051bb:	90                   	nop
801051bc:	90                   	nop
801051bd:	c9                   	leave  
801051be:	c3                   	ret    

801051bf <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051bf:	55                   	push   %ebp
801051c0:	89 e5                	mov    %esp,%ebp
801051c2:	53                   	push   %ebx
801051c3:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801051c6:	8b 45 08             	mov    0x8(%ebp),%eax
801051c9:	8b 00                	mov    (%eax),%eax
801051cb:	85 c0                	test   %eax,%eax
801051cd:	74 16                	je     801051e5 <holding+0x26>
801051cf:	8b 45 08             	mov    0x8(%ebp),%eax
801051d2:	8b 58 08             	mov    0x8(%eax),%ebx
801051d5:	e8 c2 ec ff ff       	call   80103e9c <mycpu>
801051da:	39 c3                	cmp    %eax,%ebx
801051dc:	75 07                	jne    801051e5 <holding+0x26>
801051de:	b8 01 00 00 00       	mov    $0x1,%eax
801051e3:	eb 05                	jmp    801051ea <holding+0x2b>
801051e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051ed:	c9                   	leave  
801051ee:	c3                   	ret    

801051ef <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051ef:	55                   	push   %ebp
801051f0:	89 e5                	mov    %esp,%ebp
801051f2:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801051f5:	e8 30 fe ff ff       	call   8010502a <readeflags>
801051fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801051fd:	e8 38 fe ff ff       	call   8010503a <cli>
  if(mycpu()->ncli == 0)
80105202:	e8 95 ec ff ff       	call   80103e9c <mycpu>
80105207:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010520d:	85 c0                	test   %eax,%eax
8010520f:	75 14                	jne    80105225 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105211:	e8 86 ec ff ff       	call   80103e9c <mycpu>
80105216:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105219:	81 e2 00 02 00 00    	and    $0x200,%edx
8010521f:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105225:	e8 72 ec ff ff       	call   80103e9c <mycpu>
8010522a:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105230:	83 c2 01             	add    $0x1,%edx
80105233:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105239:	90                   	nop
8010523a:	c9                   	leave  
8010523b:	c3                   	ret    

8010523c <popcli>:

void
popcli(void)
{
8010523c:	55                   	push   %ebp
8010523d:	89 e5                	mov    %esp,%ebp
8010523f:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105242:	e8 e3 fd ff ff       	call   8010502a <readeflags>
80105247:	25 00 02 00 00       	and    $0x200,%eax
8010524c:	85 c0                	test   %eax,%eax
8010524e:	74 0d                	je     8010525d <popcli+0x21>
    panic("popcli - interruptible");
80105250:	83 ec 0c             	sub    $0xc,%esp
80105253:	68 ea ad 10 80       	push   $0x8010adea
80105258:	e8 4c b3 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
8010525d:	e8 3a ec ff ff       	call   80103e9c <mycpu>
80105262:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105268:	83 ea 01             	sub    $0x1,%edx
8010526b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105271:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105277:	85 c0                	test   %eax,%eax
80105279:	79 0d                	jns    80105288 <popcli+0x4c>
    panic("popcli");
8010527b:	83 ec 0c             	sub    $0xc,%esp
8010527e:	68 01 ae 10 80       	push   $0x8010ae01
80105283:	e8 21 b3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105288:	e8 0f ec ff ff       	call   80103e9c <mycpu>
8010528d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105293:	85 c0                	test   %eax,%eax
80105295:	75 14                	jne    801052ab <popcli+0x6f>
80105297:	e8 00 ec ff ff       	call   80103e9c <mycpu>
8010529c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801052a2:	85 c0                	test   %eax,%eax
801052a4:	74 05                	je     801052ab <popcli+0x6f>
    sti();
801052a6:	e8 96 fd ff ff       	call   80105041 <sti>
}
801052ab:	90                   	nop
801052ac:	c9                   	leave  
801052ad:	c3                   	ret    

801052ae <stosb>:
{
801052ae:	55                   	push   %ebp
801052af:	89 e5                	mov    %esp,%ebp
801052b1:	57                   	push   %edi
801052b2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052b6:	8b 55 10             	mov    0x10(%ebp),%edx
801052b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052bc:	89 cb                	mov    %ecx,%ebx
801052be:	89 df                	mov    %ebx,%edi
801052c0:	89 d1                	mov    %edx,%ecx
801052c2:	fc                   	cld    
801052c3:	f3 aa                	rep stos %al,%es:(%edi)
801052c5:	89 ca                	mov    %ecx,%edx
801052c7:	89 fb                	mov    %edi,%ebx
801052c9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052cc:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052cf:	90                   	nop
801052d0:	5b                   	pop    %ebx
801052d1:	5f                   	pop    %edi
801052d2:	5d                   	pop    %ebp
801052d3:	c3                   	ret    

801052d4 <stosl>:
{
801052d4:	55                   	push   %ebp
801052d5:	89 e5                	mov    %esp,%ebp
801052d7:	57                   	push   %edi
801052d8:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052dc:	8b 55 10             	mov    0x10(%ebp),%edx
801052df:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e2:	89 cb                	mov    %ecx,%ebx
801052e4:	89 df                	mov    %ebx,%edi
801052e6:	89 d1                	mov    %edx,%ecx
801052e8:	fc                   	cld    
801052e9:	f3 ab                	rep stos %eax,%es:(%edi)
801052eb:	89 ca                	mov    %ecx,%edx
801052ed:	89 fb                	mov    %edi,%ebx
801052ef:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052f2:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052f5:	90                   	nop
801052f6:	5b                   	pop    %ebx
801052f7:	5f                   	pop    %edi
801052f8:	5d                   	pop    %ebp
801052f9:	c3                   	ret    

801052fa <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052fa:	55                   	push   %ebp
801052fb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105300:	83 e0 03             	and    $0x3,%eax
80105303:	85 c0                	test   %eax,%eax
80105305:	75 43                	jne    8010534a <memset+0x50>
80105307:	8b 45 10             	mov    0x10(%ebp),%eax
8010530a:	83 e0 03             	and    $0x3,%eax
8010530d:	85 c0                	test   %eax,%eax
8010530f:	75 39                	jne    8010534a <memset+0x50>
    c &= 0xFF;
80105311:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105318:	8b 45 10             	mov    0x10(%ebp),%eax
8010531b:	c1 e8 02             	shr    $0x2,%eax
8010531e:	89 c2                	mov    %eax,%edx
80105320:	8b 45 0c             	mov    0xc(%ebp),%eax
80105323:	c1 e0 18             	shl    $0x18,%eax
80105326:	89 c1                	mov    %eax,%ecx
80105328:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532b:	c1 e0 10             	shl    $0x10,%eax
8010532e:	09 c1                	or     %eax,%ecx
80105330:	8b 45 0c             	mov    0xc(%ebp),%eax
80105333:	c1 e0 08             	shl    $0x8,%eax
80105336:	09 c8                	or     %ecx,%eax
80105338:	0b 45 0c             	or     0xc(%ebp),%eax
8010533b:	52                   	push   %edx
8010533c:	50                   	push   %eax
8010533d:	ff 75 08             	push   0x8(%ebp)
80105340:	e8 8f ff ff ff       	call   801052d4 <stosl>
80105345:	83 c4 0c             	add    $0xc,%esp
80105348:	eb 12                	jmp    8010535c <memset+0x62>
  } else
    stosb(dst, c, n);
8010534a:	8b 45 10             	mov    0x10(%ebp),%eax
8010534d:	50                   	push   %eax
8010534e:	ff 75 0c             	push   0xc(%ebp)
80105351:	ff 75 08             	push   0x8(%ebp)
80105354:	e8 55 ff ff ff       	call   801052ae <stosb>
80105359:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010535c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010535f:	c9                   	leave  
80105360:	c3                   	ret    

80105361 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105361:	55                   	push   %ebp
80105362:	89 e5                	mov    %esp,%ebp
80105364:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105367:	8b 45 08             	mov    0x8(%ebp),%eax
8010536a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010536d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105370:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105373:	eb 30                	jmp    801053a5 <memcmp+0x44>
    if(*s1 != *s2)
80105375:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105378:	0f b6 10             	movzbl (%eax),%edx
8010537b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010537e:	0f b6 00             	movzbl (%eax),%eax
80105381:	38 c2                	cmp    %al,%dl
80105383:	74 18                	je     8010539d <memcmp+0x3c>
      return *s1 - *s2;
80105385:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105388:	0f b6 00             	movzbl (%eax),%eax
8010538b:	0f b6 d0             	movzbl %al,%edx
8010538e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105391:	0f b6 00             	movzbl (%eax),%eax
80105394:	0f b6 c8             	movzbl %al,%ecx
80105397:	89 d0                	mov    %edx,%eax
80105399:	29 c8                	sub    %ecx,%eax
8010539b:	eb 1a                	jmp    801053b7 <memcmp+0x56>
    s1++, s2++;
8010539d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053a1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801053a5:	8b 45 10             	mov    0x10(%ebp),%eax
801053a8:	8d 50 ff             	lea    -0x1(%eax),%edx
801053ab:	89 55 10             	mov    %edx,0x10(%ebp)
801053ae:	85 c0                	test   %eax,%eax
801053b0:	75 c3                	jne    80105375 <memcmp+0x14>
  }

  return 0;
801053b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053b7:	c9                   	leave  
801053b8:	c3                   	ret    

801053b9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053b9:	55                   	push   %ebp
801053ba:	89 e5                	mov    %esp,%ebp
801053bc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053c5:	8b 45 08             	mov    0x8(%ebp),%eax
801053c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053d1:	73 54                	jae    80105427 <memmove+0x6e>
801053d3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053d6:	8b 45 10             	mov    0x10(%ebp),%eax
801053d9:	01 d0                	add    %edx,%eax
801053db:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801053de:	73 47                	jae    80105427 <memmove+0x6e>
    s += n;
801053e0:	8b 45 10             	mov    0x10(%ebp),%eax
801053e3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053e6:	8b 45 10             	mov    0x10(%ebp),%eax
801053e9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053ec:	eb 13                	jmp    80105401 <memmove+0x48>
      *--d = *--s;
801053ee:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053f2:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f9:	0f b6 10             	movzbl (%eax),%edx
801053fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053ff:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105401:	8b 45 10             	mov    0x10(%ebp),%eax
80105404:	8d 50 ff             	lea    -0x1(%eax),%edx
80105407:	89 55 10             	mov    %edx,0x10(%ebp)
8010540a:	85 c0                	test   %eax,%eax
8010540c:	75 e0                	jne    801053ee <memmove+0x35>
  if(s < d && s + n > d){
8010540e:	eb 24                	jmp    80105434 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105410:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105413:	8d 42 01             	lea    0x1(%edx),%eax
80105416:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105419:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010541c:	8d 48 01             	lea    0x1(%eax),%ecx
8010541f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105422:	0f b6 12             	movzbl (%edx),%edx
80105425:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105427:	8b 45 10             	mov    0x10(%ebp),%eax
8010542a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010542d:	89 55 10             	mov    %edx,0x10(%ebp)
80105430:	85 c0                	test   %eax,%eax
80105432:	75 dc                	jne    80105410 <memmove+0x57>

  return dst;
80105434:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105437:	c9                   	leave  
80105438:	c3                   	ret    

80105439 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105439:	55                   	push   %ebp
8010543a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010543c:	ff 75 10             	push   0x10(%ebp)
8010543f:	ff 75 0c             	push   0xc(%ebp)
80105442:	ff 75 08             	push   0x8(%ebp)
80105445:	e8 6f ff ff ff       	call   801053b9 <memmove>
8010544a:	83 c4 0c             	add    $0xc,%esp
}
8010544d:	c9                   	leave  
8010544e:	c3                   	ret    

8010544f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010544f:	55                   	push   %ebp
80105450:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105452:	eb 0c                	jmp    80105460 <strncmp+0x11>
    n--, p++, q++;
80105454:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105458:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010545c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105460:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105464:	74 1a                	je     80105480 <strncmp+0x31>
80105466:	8b 45 08             	mov    0x8(%ebp),%eax
80105469:	0f b6 00             	movzbl (%eax),%eax
8010546c:	84 c0                	test   %al,%al
8010546e:	74 10                	je     80105480 <strncmp+0x31>
80105470:	8b 45 08             	mov    0x8(%ebp),%eax
80105473:	0f b6 10             	movzbl (%eax),%edx
80105476:	8b 45 0c             	mov    0xc(%ebp),%eax
80105479:	0f b6 00             	movzbl (%eax),%eax
8010547c:	38 c2                	cmp    %al,%dl
8010547e:	74 d4                	je     80105454 <strncmp+0x5>
  if(n == 0)
80105480:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105484:	75 07                	jne    8010548d <strncmp+0x3e>
    return 0;
80105486:	b8 00 00 00 00       	mov    $0x0,%eax
8010548b:	eb 16                	jmp    801054a3 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010548d:	8b 45 08             	mov    0x8(%ebp),%eax
80105490:	0f b6 00             	movzbl (%eax),%eax
80105493:	0f b6 d0             	movzbl %al,%edx
80105496:	8b 45 0c             	mov    0xc(%ebp),%eax
80105499:	0f b6 00             	movzbl (%eax),%eax
8010549c:	0f b6 c8             	movzbl %al,%ecx
8010549f:	89 d0                	mov    %edx,%eax
801054a1:	29 c8                	sub    %ecx,%eax
}
801054a3:	5d                   	pop    %ebp
801054a4:	c3                   	ret    

801054a5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054a5:	55                   	push   %ebp
801054a6:	89 e5                	mov    %esp,%ebp
801054a8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801054ab:	8b 45 08             	mov    0x8(%ebp),%eax
801054ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054b1:	90                   	nop
801054b2:	8b 45 10             	mov    0x10(%ebp),%eax
801054b5:	8d 50 ff             	lea    -0x1(%eax),%edx
801054b8:	89 55 10             	mov    %edx,0x10(%ebp)
801054bb:	85 c0                	test   %eax,%eax
801054bd:	7e 2c                	jle    801054eb <strncpy+0x46>
801054bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801054c2:	8d 42 01             	lea    0x1(%edx),%eax
801054c5:	89 45 0c             	mov    %eax,0xc(%ebp)
801054c8:	8b 45 08             	mov    0x8(%ebp),%eax
801054cb:	8d 48 01             	lea    0x1(%eax),%ecx
801054ce:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054d1:	0f b6 12             	movzbl (%edx),%edx
801054d4:	88 10                	mov    %dl,(%eax)
801054d6:	0f b6 00             	movzbl (%eax),%eax
801054d9:	84 c0                	test   %al,%al
801054db:	75 d5                	jne    801054b2 <strncpy+0xd>
    ;
  while(n-- > 0)
801054dd:	eb 0c                	jmp    801054eb <strncpy+0x46>
    *s++ = 0;
801054df:	8b 45 08             	mov    0x8(%ebp),%eax
801054e2:	8d 50 01             	lea    0x1(%eax),%edx
801054e5:	89 55 08             	mov    %edx,0x8(%ebp)
801054e8:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801054eb:	8b 45 10             	mov    0x10(%ebp),%eax
801054ee:	8d 50 ff             	lea    -0x1(%eax),%edx
801054f1:	89 55 10             	mov    %edx,0x10(%ebp)
801054f4:	85 c0                	test   %eax,%eax
801054f6:	7f e7                	jg     801054df <strncpy+0x3a>
  return os;
801054f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054fb:	c9                   	leave  
801054fc:	c3                   	ret    

801054fd <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054fd:	55                   	push   %ebp
801054fe:	89 e5                	mov    %esp,%ebp
80105500:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105503:	8b 45 08             	mov    0x8(%ebp),%eax
80105506:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105509:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010550d:	7f 05                	jg     80105514 <safestrcpy+0x17>
    return os;
8010550f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105512:	eb 32                	jmp    80105546 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105514:	90                   	nop
80105515:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105519:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010551d:	7e 1e                	jle    8010553d <safestrcpy+0x40>
8010551f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105522:	8d 42 01             	lea    0x1(%edx),%eax
80105525:	89 45 0c             	mov    %eax,0xc(%ebp)
80105528:	8b 45 08             	mov    0x8(%ebp),%eax
8010552b:	8d 48 01             	lea    0x1(%eax),%ecx
8010552e:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105531:	0f b6 12             	movzbl (%edx),%edx
80105534:	88 10                	mov    %dl,(%eax)
80105536:	0f b6 00             	movzbl (%eax),%eax
80105539:	84 c0                	test   %al,%al
8010553b:	75 d8                	jne    80105515 <safestrcpy+0x18>
    ;
  *s = 0;
8010553d:	8b 45 08             	mov    0x8(%ebp),%eax
80105540:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105543:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105546:	c9                   	leave  
80105547:	c3                   	ret    

80105548 <strlen>:

int
strlen(const char *s)
{
80105548:	55                   	push   %ebp
80105549:	89 e5                	mov    %esp,%ebp
8010554b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010554e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105555:	eb 04                	jmp    8010555b <strlen+0x13>
80105557:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010555b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010555e:	8b 45 08             	mov    0x8(%ebp),%eax
80105561:	01 d0                	add    %edx,%eax
80105563:	0f b6 00             	movzbl (%eax),%eax
80105566:	84 c0                	test   %al,%al
80105568:	75 ed                	jne    80105557 <strlen+0xf>
    ;
  return n;
8010556a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010556d:	c9                   	leave  
8010556e:	c3                   	ret    

8010556f <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010556f:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105573:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105577:	55                   	push   %ebp
  pushl %ebx
80105578:	53                   	push   %ebx
  pushl %esi
80105579:	56                   	push   %esi
  pushl %edi
8010557a:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010557b:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010557d:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010557f:	5f                   	pop    %edi
  popl %esi
80105580:	5e                   	pop    %esi
  popl %ebx
80105581:	5b                   	pop    %ebx
  popl %ebp
80105582:	5d                   	pop    %ebp
  ret
80105583:	c3                   	ret    

80105584 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105584:	55                   	push   %ebp
80105585:	89 e5                	mov    %esp,%ebp
80105587:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010558a:	e8 85 e9 ff ff       	call   80103f14 <myproc>
8010558f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105592:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105595:	8b 00                	mov    (%eax),%eax
80105597:	39 45 08             	cmp    %eax,0x8(%ebp)
8010559a:	73 0f                	jae    801055ab <fetchint+0x27>
8010559c:	8b 45 08             	mov    0x8(%ebp),%eax
8010559f:	8d 50 04             	lea    0x4(%eax),%edx
801055a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a5:	8b 00                	mov    (%eax),%eax
801055a7:	39 c2                	cmp    %eax,%edx
801055a9:	76 07                	jbe    801055b2 <fetchint+0x2e>
    return -1;
801055ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055b0:	eb 0f                	jmp    801055c1 <fetchint+0x3d>
  *ip = *(int*)(addr);
801055b2:	8b 45 08             	mov    0x8(%ebp),%eax
801055b5:	8b 10                	mov    (%eax),%edx
801055b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ba:	89 10                	mov    %edx,(%eax)
  return 0;
801055bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055c1:	c9                   	leave  
801055c2:	c3                   	ret    

801055c3 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055c3:	55                   	push   %ebp
801055c4:	89 e5                	mov    %esp,%ebp
801055c6:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801055c9:	e8 46 e9 ff ff       	call   80103f14 <myproc>
801055ce:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801055d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d4:	8b 00                	mov    (%eax),%eax
801055d6:	39 45 08             	cmp    %eax,0x8(%ebp)
801055d9:	72 07                	jb     801055e2 <fetchstr+0x1f>
    return -1;
801055db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055e0:	eb 41                	jmp    80105623 <fetchstr+0x60>
  *pp = (char*)addr;
801055e2:	8b 55 08             	mov    0x8(%ebp),%edx
801055e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e8:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801055ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ed:	8b 00                	mov    (%eax),%eax
801055ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801055f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f5:	8b 00                	mov    (%eax),%eax
801055f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055fa:	eb 1a                	jmp    80105616 <fetchstr+0x53>
    if(*s == 0)
801055fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ff:	0f b6 00             	movzbl (%eax),%eax
80105602:	84 c0                	test   %al,%al
80105604:	75 0c                	jne    80105612 <fetchstr+0x4f>
      return s - *pp;
80105606:	8b 45 0c             	mov    0xc(%ebp),%eax
80105609:	8b 10                	mov    (%eax),%edx
8010560b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560e:	29 d0                	sub    %edx,%eax
80105610:	eb 11                	jmp    80105623 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105612:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105619:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010561c:	72 de                	jb     801055fc <fetchstr+0x39>
  }
  return -1;
8010561e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105623:	c9                   	leave  
80105624:	c3                   	ret    

80105625 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105625:	55                   	push   %ebp
80105626:	89 e5                	mov    %esp,%ebp
80105628:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010562b:	e8 e4 e8 ff ff       	call   80103f14 <myproc>
80105630:	8b 40 18             	mov    0x18(%eax),%eax
80105633:	8b 50 44             	mov    0x44(%eax),%edx
80105636:	8b 45 08             	mov    0x8(%ebp),%eax
80105639:	c1 e0 02             	shl    $0x2,%eax
8010563c:	01 d0                	add    %edx,%eax
8010563e:	83 c0 04             	add    $0x4,%eax
80105641:	83 ec 08             	sub    $0x8,%esp
80105644:	ff 75 0c             	push   0xc(%ebp)
80105647:	50                   	push   %eax
80105648:	e8 37 ff ff ff       	call   80105584 <fetchint>
8010564d:	83 c4 10             	add    $0x10,%esp
}
80105650:	c9                   	leave  
80105651:	c3                   	ret    

80105652 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105652:	55                   	push   %ebp
80105653:	89 e5                	mov    %esp,%ebp
80105655:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105658:	e8 b7 e8 ff ff       	call   80103f14 <myproc>
8010565d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105660:	83 ec 08             	sub    $0x8,%esp
80105663:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105666:	50                   	push   %eax
80105667:	ff 75 08             	push   0x8(%ebp)
8010566a:	e8 b6 ff ff ff       	call   80105625 <argint>
8010566f:	83 c4 10             	add    $0x10,%esp
80105672:	85 c0                	test   %eax,%eax
80105674:	79 07                	jns    8010567d <argptr+0x2b>
    return -1;
80105676:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010567b:	eb 3b                	jmp    801056b8 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010567d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105681:	78 1f                	js     801056a2 <argptr+0x50>
80105683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105686:	8b 00                	mov    (%eax),%eax
80105688:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010568b:	39 d0                	cmp    %edx,%eax
8010568d:	76 13                	jbe    801056a2 <argptr+0x50>
8010568f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105692:	89 c2                	mov    %eax,%edx
80105694:	8b 45 10             	mov    0x10(%ebp),%eax
80105697:	01 c2                	add    %eax,%edx
80105699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569c:	8b 00                	mov    (%eax),%eax
8010569e:	39 c2                	cmp    %eax,%edx
801056a0:	76 07                	jbe    801056a9 <argptr+0x57>
    return -1;
801056a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056a7:	eb 0f                	jmp    801056b8 <argptr+0x66>
  *pp = (char*)i;
801056a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ac:	89 c2                	mov    %eax,%edx
801056ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b1:	89 10                	mov    %edx,(%eax)
  return 0;
801056b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056b8:	c9                   	leave  
801056b9:	c3                   	ret    

801056ba <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801056ba:	55                   	push   %ebp
801056bb:	89 e5                	mov    %esp,%ebp
801056bd:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801056c0:	83 ec 08             	sub    $0x8,%esp
801056c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056c6:	50                   	push   %eax
801056c7:	ff 75 08             	push   0x8(%ebp)
801056ca:	e8 56 ff ff ff       	call   80105625 <argint>
801056cf:	83 c4 10             	add    $0x10,%esp
801056d2:	85 c0                	test   %eax,%eax
801056d4:	79 07                	jns    801056dd <argstr+0x23>
    return -1;
801056d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056db:	eb 12                	jmp    801056ef <argstr+0x35>
  return fetchstr(addr, pp);
801056dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e0:	83 ec 08             	sub    $0x8,%esp
801056e3:	ff 75 0c             	push   0xc(%ebp)
801056e6:	50                   	push   %eax
801056e7:	e8 d7 fe ff ff       	call   801055c3 <fetchstr>
801056ec:	83 c4 10             	add    $0x10,%esp
}
801056ef:	c9                   	leave  
801056f0:	c3                   	ret    

801056f1 <syscall>:
[SYS_getpinfo] sys_getpinfo,
};

void
syscall(void)
{
801056f1:	55                   	push   %ebp
801056f2:	89 e5                	mov    %esp,%ebp
801056f4:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801056f7:	e8 18 e8 ff ff       	call   80103f14 <myproc>
801056fc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801056ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105702:	8b 40 18             	mov    0x18(%eax),%eax
80105705:	8b 40 1c             	mov    0x1c(%eax),%eax
80105708:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010570b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010570f:	7e 2f                	jle    80105740 <syscall+0x4f>
80105711:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105714:	83 f8 17             	cmp    $0x17,%eax
80105717:	77 27                	ja     80105740 <syscall+0x4f>
80105719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010571c:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105723:	85 c0                	test   %eax,%eax
80105725:	74 19                	je     80105740 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105727:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010572a:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105731:	ff d0                	call   *%eax
80105733:	89 c2                	mov    %eax,%edx
80105735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105738:	8b 40 18             	mov    0x18(%eax),%eax
8010573b:	89 50 1c             	mov    %edx,0x1c(%eax)
8010573e:	eb 2c                	jmp    8010576c <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105743:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105749:	8b 40 10             	mov    0x10(%eax),%eax
8010574c:	ff 75 f0             	push   -0x10(%ebp)
8010574f:	52                   	push   %edx
80105750:	50                   	push   %eax
80105751:	68 08 ae 10 80       	push   $0x8010ae08
80105756:	e8 99 ac ff ff       	call   801003f4 <cprintf>
8010575b:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
8010575e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105761:	8b 40 18             	mov    0x18(%eax),%eax
80105764:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010576b:	90                   	nop
8010576c:	90                   	nop
8010576d:	c9                   	leave  
8010576e:	c3                   	ret    

8010576f <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010576f:	55                   	push   %ebp
80105770:	89 e5                	mov    %esp,%ebp
80105772:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105775:	83 ec 08             	sub    $0x8,%esp
80105778:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010577b:	50                   	push   %eax
8010577c:	ff 75 08             	push   0x8(%ebp)
8010577f:	e8 a1 fe ff ff       	call   80105625 <argint>
80105784:	83 c4 10             	add    $0x10,%esp
80105787:	85 c0                	test   %eax,%eax
80105789:	79 07                	jns    80105792 <argfd+0x23>
    return -1;
8010578b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105790:	eb 4f                	jmp    801057e1 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105792:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105795:	85 c0                	test   %eax,%eax
80105797:	78 20                	js     801057b9 <argfd+0x4a>
80105799:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010579c:	83 f8 0f             	cmp    $0xf,%eax
8010579f:	7f 18                	jg     801057b9 <argfd+0x4a>
801057a1:	e8 6e e7 ff ff       	call   80103f14 <myproc>
801057a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057a9:	83 c2 08             	add    $0x8,%edx
801057ac:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057b7:	75 07                	jne    801057c0 <argfd+0x51>
    return -1;
801057b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057be:	eb 21                	jmp    801057e1 <argfd+0x72>
  if(pfd)
801057c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801057c4:	74 08                	je     801057ce <argfd+0x5f>
    *pfd = fd;
801057c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801057cc:	89 10                	mov    %edx,(%eax)
  if(pf)
801057ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057d2:	74 08                	je     801057dc <argfd+0x6d>
    *pf = f;
801057d4:	8b 45 10             	mov    0x10(%ebp),%eax
801057d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057da:	89 10                	mov    %edx,(%eax)
  return 0;
801057dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057e1:	c9                   	leave  
801057e2:	c3                   	ret    

801057e3 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057e3:	55                   	push   %ebp
801057e4:	89 e5                	mov    %esp,%ebp
801057e6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801057e9:	e8 26 e7 ff ff       	call   80103f14 <myproc>
801057ee:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801057f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801057f8:	eb 2a                	jmp    80105824 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801057fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105800:	83 c2 08             	add    $0x8,%edx
80105803:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105807:	85 c0                	test   %eax,%eax
80105809:	75 15                	jne    80105820 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
8010580b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105811:	8d 4a 08             	lea    0x8(%edx),%ecx
80105814:	8b 55 08             	mov    0x8(%ebp),%edx
80105817:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010581b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581e:	eb 0f                	jmp    8010582f <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105820:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105824:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105828:	7e d0                	jle    801057fa <fdalloc+0x17>
    }
  }
  return -1;
8010582a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010582f:	c9                   	leave  
80105830:	c3                   	ret    

80105831 <sys_dup>:

int
sys_dup(void)
{
80105831:	55                   	push   %ebp
80105832:	89 e5                	mov    %esp,%ebp
80105834:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105837:	83 ec 04             	sub    $0x4,%esp
8010583a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010583d:	50                   	push   %eax
8010583e:	6a 00                	push   $0x0
80105840:	6a 00                	push   $0x0
80105842:	e8 28 ff ff ff       	call   8010576f <argfd>
80105847:	83 c4 10             	add    $0x10,%esp
8010584a:	85 c0                	test   %eax,%eax
8010584c:	79 07                	jns    80105855 <sys_dup+0x24>
    return -1;
8010584e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105853:	eb 31                	jmp    80105886 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105855:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105858:	83 ec 0c             	sub    $0xc,%esp
8010585b:	50                   	push   %eax
8010585c:	e8 82 ff ff ff       	call   801057e3 <fdalloc>
80105861:	83 c4 10             	add    $0x10,%esp
80105864:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105867:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010586b:	79 07                	jns    80105874 <sys_dup+0x43>
    return -1;
8010586d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105872:	eb 12                	jmp    80105886 <sys_dup+0x55>
  filedup(f);
80105874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105877:	83 ec 0c             	sub    $0xc,%esp
8010587a:	50                   	push   %eax
8010587b:	e8 ca b7 ff ff       	call   8010104a <filedup>
80105880:	83 c4 10             	add    $0x10,%esp
  return fd;
80105883:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105886:	c9                   	leave  
80105887:	c3                   	ret    

80105888 <sys_read>:

int
sys_read(void)
{
80105888:	55                   	push   %ebp
80105889:	89 e5                	mov    %esp,%ebp
8010588b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010588e:	83 ec 04             	sub    $0x4,%esp
80105891:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105894:	50                   	push   %eax
80105895:	6a 00                	push   $0x0
80105897:	6a 00                	push   $0x0
80105899:	e8 d1 fe ff ff       	call   8010576f <argfd>
8010589e:	83 c4 10             	add    $0x10,%esp
801058a1:	85 c0                	test   %eax,%eax
801058a3:	78 2e                	js     801058d3 <sys_read+0x4b>
801058a5:	83 ec 08             	sub    $0x8,%esp
801058a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058ab:	50                   	push   %eax
801058ac:	6a 02                	push   $0x2
801058ae:	e8 72 fd ff ff       	call   80105625 <argint>
801058b3:	83 c4 10             	add    $0x10,%esp
801058b6:	85 c0                	test   %eax,%eax
801058b8:	78 19                	js     801058d3 <sys_read+0x4b>
801058ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bd:	83 ec 04             	sub    $0x4,%esp
801058c0:	50                   	push   %eax
801058c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058c4:	50                   	push   %eax
801058c5:	6a 01                	push   $0x1
801058c7:	e8 86 fd ff ff       	call   80105652 <argptr>
801058cc:	83 c4 10             	add    $0x10,%esp
801058cf:	85 c0                	test   %eax,%eax
801058d1:	79 07                	jns    801058da <sys_read+0x52>
    return -1;
801058d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d8:	eb 17                	jmp    801058f1 <sys_read+0x69>
  return fileread(f, p, n);
801058da:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e3:	83 ec 04             	sub    $0x4,%esp
801058e6:	51                   	push   %ecx
801058e7:	52                   	push   %edx
801058e8:	50                   	push   %eax
801058e9:	e8 ec b8 ff ff       	call   801011da <fileread>
801058ee:	83 c4 10             	add    $0x10,%esp
}
801058f1:	c9                   	leave  
801058f2:	c3                   	ret    

801058f3 <sys_write>:

int
sys_write(void)
{
801058f3:	55                   	push   %ebp
801058f4:	89 e5                	mov    %esp,%ebp
801058f6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058f9:	83 ec 04             	sub    $0x4,%esp
801058fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058ff:	50                   	push   %eax
80105900:	6a 00                	push   $0x0
80105902:	6a 00                	push   $0x0
80105904:	e8 66 fe ff ff       	call   8010576f <argfd>
80105909:	83 c4 10             	add    $0x10,%esp
8010590c:	85 c0                	test   %eax,%eax
8010590e:	78 2e                	js     8010593e <sys_write+0x4b>
80105910:	83 ec 08             	sub    $0x8,%esp
80105913:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105916:	50                   	push   %eax
80105917:	6a 02                	push   $0x2
80105919:	e8 07 fd ff ff       	call   80105625 <argint>
8010591e:	83 c4 10             	add    $0x10,%esp
80105921:	85 c0                	test   %eax,%eax
80105923:	78 19                	js     8010593e <sys_write+0x4b>
80105925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105928:	83 ec 04             	sub    $0x4,%esp
8010592b:	50                   	push   %eax
8010592c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010592f:	50                   	push   %eax
80105930:	6a 01                	push   $0x1
80105932:	e8 1b fd ff ff       	call   80105652 <argptr>
80105937:	83 c4 10             	add    $0x10,%esp
8010593a:	85 c0                	test   %eax,%eax
8010593c:	79 07                	jns    80105945 <sys_write+0x52>
    return -1;
8010593e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105943:	eb 17                	jmp    8010595c <sys_write+0x69>
  return filewrite(f, p, n);
80105945:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105948:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010594b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594e:	83 ec 04             	sub    $0x4,%esp
80105951:	51                   	push   %ecx
80105952:	52                   	push   %edx
80105953:	50                   	push   %eax
80105954:	e8 39 b9 ff ff       	call   80101292 <filewrite>
80105959:	83 c4 10             	add    $0x10,%esp
}
8010595c:	c9                   	leave  
8010595d:	c3                   	ret    

8010595e <sys_close>:

int
sys_close(void)
{
8010595e:	55                   	push   %ebp
8010595f:	89 e5                	mov    %esp,%ebp
80105961:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105964:	83 ec 04             	sub    $0x4,%esp
80105967:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010596a:	50                   	push   %eax
8010596b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010596e:	50                   	push   %eax
8010596f:	6a 00                	push   $0x0
80105971:	e8 f9 fd ff ff       	call   8010576f <argfd>
80105976:	83 c4 10             	add    $0x10,%esp
80105979:	85 c0                	test   %eax,%eax
8010597b:	79 07                	jns    80105984 <sys_close+0x26>
    return -1;
8010597d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105982:	eb 27                	jmp    801059ab <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105984:	e8 8b e5 ff ff       	call   80103f14 <myproc>
80105989:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010598c:	83 c2 08             	add    $0x8,%edx
8010598f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105996:	00 
  fileclose(f);
80105997:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599a:	83 ec 0c             	sub    $0xc,%esp
8010599d:	50                   	push   %eax
8010599e:	e8 f8 b6 ff ff       	call   8010109b <fileclose>
801059a3:	83 c4 10             	add    $0x10,%esp
  return 0;
801059a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059ab:	c9                   	leave  
801059ac:	c3                   	ret    

801059ad <sys_fstat>:

int
sys_fstat(void)
{
801059ad:	55                   	push   %ebp
801059ae:	89 e5                	mov    %esp,%ebp
801059b0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801059b3:	83 ec 04             	sub    $0x4,%esp
801059b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059b9:	50                   	push   %eax
801059ba:	6a 00                	push   $0x0
801059bc:	6a 00                	push   $0x0
801059be:	e8 ac fd ff ff       	call   8010576f <argfd>
801059c3:	83 c4 10             	add    $0x10,%esp
801059c6:	85 c0                	test   %eax,%eax
801059c8:	78 17                	js     801059e1 <sys_fstat+0x34>
801059ca:	83 ec 04             	sub    $0x4,%esp
801059cd:	6a 14                	push   $0x14
801059cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059d2:	50                   	push   %eax
801059d3:	6a 01                	push   $0x1
801059d5:	e8 78 fc ff ff       	call   80105652 <argptr>
801059da:	83 c4 10             	add    $0x10,%esp
801059dd:	85 c0                	test   %eax,%eax
801059df:	79 07                	jns    801059e8 <sys_fstat+0x3b>
    return -1;
801059e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e6:	eb 13                	jmp    801059fb <sys_fstat+0x4e>
  return filestat(f, st);
801059e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ee:	83 ec 08             	sub    $0x8,%esp
801059f1:	52                   	push   %edx
801059f2:	50                   	push   %eax
801059f3:	e8 8b b7 ff ff       	call   80101183 <filestat>
801059f8:	83 c4 10             	add    $0x10,%esp
}
801059fb:	c9                   	leave  
801059fc:	c3                   	ret    

801059fd <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059fd:	55                   	push   %ebp
801059fe:	89 e5                	mov    %esp,%ebp
80105a00:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a03:	83 ec 08             	sub    $0x8,%esp
80105a06:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a09:	50                   	push   %eax
80105a0a:	6a 00                	push   $0x0
80105a0c:	e8 a9 fc ff ff       	call   801056ba <argstr>
80105a11:	83 c4 10             	add    $0x10,%esp
80105a14:	85 c0                	test   %eax,%eax
80105a16:	78 15                	js     80105a2d <sys_link+0x30>
80105a18:	83 ec 08             	sub    $0x8,%esp
80105a1b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a1e:	50                   	push   %eax
80105a1f:	6a 01                	push   $0x1
80105a21:	e8 94 fc ff ff       	call   801056ba <argstr>
80105a26:	83 c4 10             	add    $0x10,%esp
80105a29:	85 c0                	test   %eax,%eax
80105a2b:	79 0a                	jns    80105a37 <sys_link+0x3a>
    return -1;
80105a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a32:	e9 68 01 00 00       	jmp    80105b9f <sys_link+0x1a2>

  begin_op();
80105a37:	e8 e4 da ff ff       	call   80103520 <begin_op>
  if((ip = namei(old)) == 0){
80105a3c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a3f:	83 ec 0c             	sub    $0xc,%esp
80105a42:	50                   	push   %eax
80105a43:	e8 d5 ca ff ff       	call   8010251d <namei>
80105a48:	83 c4 10             	add    $0x10,%esp
80105a4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a52:	75 0f                	jne    80105a63 <sys_link+0x66>
    end_op();
80105a54:	e8 53 db ff ff       	call   801035ac <end_op>
    return -1;
80105a59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5e:	e9 3c 01 00 00       	jmp    80105b9f <sys_link+0x1a2>
  }

  ilock(ip);
80105a63:	83 ec 0c             	sub    $0xc,%esp
80105a66:	ff 75 f4             	push   -0xc(%ebp)
80105a69:	e8 7c bf ff ff       	call   801019ea <ilock>
80105a6e:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a74:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a78:	66 83 f8 01          	cmp    $0x1,%ax
80105a7c:	75 1d                	jne    80105a9b <sys_link+0x9e>
    iunlockput(ip);
80105a7e:	83 ec 0c             	sub    $0xc,%esp
80105a81:	ff 75 f4             	push   -0xc(%ebp)
80105a84:	e8 92 c1 ff ff       	call   80101c1b <iunlockput>
80105a89:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a8c:	e8 1b db ff ff       	call   801035ac <end_op>
    return -1;
80105a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a96:	e9 04 01 00 00       	jmp    80105b9f <sys_link+0x1a2>
  }

  ip->nlink++;
80105a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105aa2:	83 c0 01             	add    $0x1,%eax
80105aa5:	89 c2                	mov    %eax,%edx
80105aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aaa:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105aae:	83 ec 0c             	sub    $0xc,%esp
80105ab1:	ff 75 f4             	push   -0xc(%ebp)
80105ab4:	e8 54 bd ff ff       	call   8010180d <iupdate>
80105ab9:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105abc:	83 ec 0c             	sub    $0xc,%esp
80105abf:	ff 75 f4             	push   -0xc(%ebp)
80105ac2:	e8 36 c0 ff ff       	call   80101afd <iunlock>
80105ac7:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105aca:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105acd:	83 ec 08             	sub    $0x8,%esp
80105ad0:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105ad3:	52                   	push   %edx
80105ad4:	50                   	push   %eax
80105ad5:	e8 5f ca ff ff       	call   80102539 <nameiparent>
80105ada:	83 c4 10             	add    $0x10,%esp
80105add:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ae0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ae4:	74 71                	je     80105b57 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105ae6:	83 ec 0c             	sub    $0xc,%esp
80105ae9:	ff 75 f0             	push   -0x10(%ebp)
80105aec:	e8 f9 be ff ff       	call   801019ea <ilock>
80105af1:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af7:	8b 10                	mov    (%eax),%edx
80105af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afc:	8b 00                	mov    (%eax),%eax
80105afe:	39 c2                	cmp    %eax,%edx
80105b00:	75 1d                	jne    80105b1f <sys_link+0x122>
80105b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b05:	8b 40 04             	mov    0x4(%eax),%eax
80105b08:	83 ec 04             	sub    $0x4,%esp
80105b0b:	50                   	push   %eax
80105b0c:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b0f:	50                   	push   %eax
80105b10:	ff 75 f0             	push   -0x10(%ebp)
80105b13:	e8 6e c7 ff ff       	call   80102286 <dirlink>
80105b18:	83 c4 10             	add    $0x10,%esp
80105b1b:	85 c0                	test   %eax,%eax
80105b1d:	79 10                	jns    80105b2f <sys_link+0x132>
    iunlockput(dp);
80105b1f:	83 ec 0c             	sub    $0xc,%esp
80105b22:	ff 75 f0             	push   -0x10(%ebp)
80105b25:	e8 f1 c0 ff ff       	call   80101c1b <iunlockput>
80105b2a:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b2d:	eb 29                	jmp    80105b58 <sys_link+0x15b>
  }
  iunlockput(dp);
80105b2f:	83 ec 0c             	sub    $0xc,%esp
80105b32:	ff 75 f0             	push   -0x10(%ebp)
80105b35:	e8 e1 c0 ff ff       	call   80101c1b <iunlockput>
80105b3a:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b3d:	83 ec 0c             	sub    $0xc,%esp
80105b40:	ff 75 f4             	push   -0xc(%ebp)
80105b43:	e8 03 c0 ff ff       	call   80101b4b <iput>
80105b48:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b4b:	e8 5c da ff ff       	call   801035ac <end_op>

  return 0;
80105b50:	b8 00 00 00 00       	mov    $0x0,%eax
80105b55:	eb 48                	jmp    80105b9f <sys_link+0x1a2>
    goto bad;
80105b57:	90                   	nop

bad:
  ilock(ip);
80105b58:	83 ec 0c             	sub    $0xc,%esp
80105b5b:	ff 75 f4             	push   -0xc(%ebp)
80105b5e:	e8 87 be ff ff       	call   801019ea <ilock>
80105b63:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b69:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b6d:	83 e8 01             	sub    $0x1,%eax
80105b70:	89 c2                	mov    %eax,%edx
80105b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b75:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b79:	83 ec 0c             	sub    $0xc,%esp
80105b7c:	ff 75 f4             	push   -0xc(%ebp)
80105b7f:	e8 89 bc ff ff       	call   8010180d <iupdate>
80105b84:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b87:	83 ec 0c             	sub    $0xc,%esp
80105b8a:	ff 75 f4             	push   -0xc(%ebp)
80105b8d:	e8 89 c0 ff ff       	call   80101c1b <iunlockput>
80105b92:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b95:	e8 12 da ff ff       	call   801035ac <end_op>
  return -1;
80105b9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b9f:	c9                   	leave  
80105ba0:	c3                   	ret    

80105ba1 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105ba1:	55                   	push   %ebp
80105ba2:	89 e5                	mov    %esp,%ebp
80105ba4:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ba7:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105bae:	eb 40                	jmp    80105bf0 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb3:	6a 10                	push   $0x10
80105bb5:	50                   	push   %eax
80105bb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105bb9:	50                   	push   %eax
80105bba:	ff 75 08             	push   0x8(%ebp)
80105bbd:	e8 14 c3 ff ff       	call   80101ed6 <readi>
80105bc2:	83 c4 10             	add    $0x10,%esp
80105bc5:	83 f8 10             	cmp    $0x10,%eax
80105bc8:	74 0d                	je     80105bd7 <isdirempty+0x36>
      panic("isdirempty: readi");
80105bca:	83 ec 0c             	sub    $0xc,%esp
80105bcd:	68 24 ae 10 80       	push   $0x8010ae24
80105bd2:	e8 d2 a9 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105bd7:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105bdb:	66 85 c0             	test   %ax,%ax
80105bde:	74 07                	je     80105be7 <isdirempty+0x46>
      return 0;
80105be0:	b8 00 00 00 00       	mov    $0x0,%eax
80105be5:	eb 1b                	jmp    80105c02 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bea:	83 c0 10             	add    $0x10,%eax
80105bed:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf3:	8b 50 58             	mov    0x58(%eax),%edx
80105bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf9:	39 c2                	cmp    %eax,%edx
80105bfb:	77 b3                	ja     80105bb0 <isdirempty+0xf>
  }
  return 1;
80105bfd:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c02:	c9                   	leave  
80105c03:	c3                   	ret    

80105c04 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c04:	55                   	push   %ebp
80105c05:	89 e5                	mov    %esp,%ebp
80105c07:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c0a:	83 ec 08             	sub    $0x8,%esp
80105c0d:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c10:	50                   	push   %eax
80105c11:	6a 00                	push   $0x0
80105c13:	e8 a2 fa ff ff       	call   801056ba <argstr>
80105c18:	83 c4 10             	add    $0x10,%esp
80105c1b:	85 c0                	test   %eax,%eax
80105c1d:	79 0a                	jns    80105c29 <sys_unlink+0x25>
    return -1;
80105c1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c24:	e9 bf 01 00 00       	jmp    80105de8 <sys_unlink+0x1e4>

  begin_op();
80105c29:	e8 f2 d8 ff ff       	call   80103520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c2e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c31:	83 ec 08             	sub    $0x8,%esp
80105c34:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c37:	52                   	push   %edx
80105c38:	50                   	push   %eax
80105c39:	e8 fb c8 ff ff       	call   80102539 <nameiparent>
80105c3e:	83 c4 10             	add    $0x10,%esp
80105c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c48:	75 0f                	jne    80105c59 <sys_unlink+0x55>
    end_op();
80105c4a:	e8 5d d9 ff ff       	call   801035ac <end_op>
    return -1;
80105c4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c54:	e9 8f 01 00 00       	jmp    80105de8 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105c59:	83 ec 0c             	sub    $0xc,%esp
80105c5c:	ff 75 f4             	push   -0xc(%ebp)
80105c5f:	e8 86 bd ff ff       	call   801019ea <ilock>
80105c64:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c67:	83 ec 08             	sub    $0x8,%esp
80105c6a:	68 36 ae 10 80       	push   $0x8010ae36
80105c6f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c72:	50                   	push   %eax
80105c73:	e8 39 c5 ff ff       	call   801021b1 <namecmp>
80105c78:	83 c4 10             	add    $0x10,%esp
80105c7b:	85 c0                	test   %eax,%eax
80105c7d:	0f 84 49 01 00 00    	je     80105dcc <sys_unlink+0x1c8>
80105c83:	83 ec 08             	sub    $0x8,%esp
80105c86:	68 38 ae 10 80       	push   $0x8010ae38
80105c8b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c8e:	50                   	push   %eax
80105c8f:	e8 1d c5 ff ff       	call   801021b1 <namecmp>
80105c94:	83 c4 10             	add    $0x10,%esp
80105c97:	85 c0                	test   %eax,%eax
80105c99:	0f 84 2d 01 00 00    	je     80105dcc <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c9f:	83 ec 04             	sub    $0x4,%esp
80105ca2:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ca5:	50                   	push   %eax
80105ca6:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ca9:	50                   	push   %eax
80105caa:	ff 75 f4             	push   -0xc(%ebp)
80105cad:	e8 1a c5 ff ff       	call   801021cc <dirlookup>
80105cb2:	83 c4 10             	add    $0x10,%esp
80105cb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cb8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cbc:	0f 84 0d 01 00 00    	je     80105dcf <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105cc2:	83 ec 0c             	sub    $0xc,%esp
80105cc5:	ff 75 f0             	push   -0x10(%ebp)
80105cc8:	e8 1d bd ff ff       	call   801019ea <ilock>
80105ccd:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cd7:	66 85 c0             	test   %ax,%ax
80105cda:	7f 0d                	jg     80105ce9 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105cdc:	83 ec 0c             	sub    $0xc,%esp
80105cdf:	68 3b ae 10 80       	push   $0x8010ae3b
80105ce4:	e8 c0 a8 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cf0:	66 83 f8 01          	cmp    $0x1,%ax
80105cf4:	75 25                	jne    80105d1b <sys_unlink+0x117>
80105cf6:	83 ec 0c             	sub    $0xc,%esp
80105cf9:	ff 75 f0             	push   -0x10(%ebp)
80105cfc:	e8 a0 fe ff ff       	call   80105ba1 <isdirempty>
80105d01:	83 c4 10             	add    $0x10,%esp
80105d04:	85 c0                	test   %eax,%eax
80105d06:	75 13                	jne    80105d1b <sys_unlink+0x117>
    iunlockput(ip);
80105d08:	83 ec 0c             	sub    $0xc,%esp
80105d0b:	ff 75 f0             	push   -0x10(%ebp)
80105d0e:	e8 08 bf ff ff       	call   80101c1b <iunlockput>
80105d13:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d16:	e9 b5 00 00 00       	jmp    80105dd0 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105d1b:	83 ec 04             	sub    $0x4,%esp
80105d1e:	6a 10                	push   $0x10
80105d20:	6a 00                	push   $0x0
80105d22:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d25:	50                   	push   %eax
80105d26:	e8 cf f5 ff ff       	call   801052fa <memset>
80105d2b:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d2e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d31:	6a 10                	push   $0x10
80105d33:	50                   	push   %eax
80105d34:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d37:	50                   	push   %eax
80105d38:	ff 75 f4             	push   -0xc(%ebp)
80105d3b:	e8 eb c2 ff ff       	call   8010202b <writei>
80105d40:	83 c4 10             	add    $0x10,%esp
80105d43:	83 f8 10             	cmp    $0x10,%eax
80105d46:	74 0d                	je     80105d55 <sys_unlink+0x151>
    panic("unlink: writei");
80105d48:	83 ec 0c             	sub    $0xc,%esp
80105d4b:	68 4d ae 10 80       	push   $0x8010ae4d
80105d50:	e8 54 a8 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d58:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d5c:	66 83 f8 01          	cmp    $0x1,%ax
80105d60:	75 21                	jne    80105d83 <sys_unlink+0x17f>
    dp->nlink--;
80105d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d65:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d69:	83 e8 01             	sub    $0x1,%eax
80105d6c:	89 c2                	mov    %eax,%edx
80105d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d71:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105d75:	83 ec 0c             	sub    $0xc,%esp
80105d78:	ff 75 f4             	push   -0xc(%ebp)
80105d7b:	e8 8d ba ff ff       	call   8010180d <iupdate>
80105d80:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d83:	83 ec 0c             	sub    $0xc,%esp
80105d86:	ff 75 f4             	push   -0xc(%ebp)
80105d89:	e8 8d be ff ff       	call   80101c1b <iunlockput>
80105d8e:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d94:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d98:	83 e8 01             	sub    $0x1,%eax
80105d9b:	89 c2                	mov    %eax,%edx
80105d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da0:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105da4:	83 ec 0c             	sub    $0xc,%esp
80105da7:	ff 75 f0             	push   -0x10(%ebp)
80105daa:	e8 5e ba ff ff       	call   8010180d <iupdate>
80105daf:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105db2:	83 ec 0c             	sub    $0xc,%esp
80105db5:	ff 75 f0             	push   -0x10(%ebp)
80105db8:	e8 5e be ff ff       	call   80101c1b <iunlockput>
80105dbd:	83 c4 10             	add    $0x10,%esp

  end_op();
80105dc0:	e8 e7 d7 ff ff       	call   801035ac <end_op>

  return 0;
80105dc5:	b8 00 00 00 00       	mov    $0x0,%eax
80105dca:	eb 1c                	jmp    80105de8 <sys_unlink+0x1e4>
    goto bad;
80105dcc:	90                   	nop
80105dcd:	eb 01                	jmp    80105dd0 <sys_unlink+0x1cc>
    goto bad;
80105dcf:	90                   	nop

bad:
  iunlockput(dp);
80105dd0:	83 ec 0c             	sub    $0xc,%esp
80105dd3:	ff 75 f4             	push   -0xc(%ebp)
80105dd6:	e8 40 be ff ff       	call   80101c1b <iunlockput>
80105ddb:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dde:	e8 c9 d7 ff ff       	call   801035ac <end_op>
  return -1;
80105de3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105de8:	c9                   	leave  
80105de9:	c3                   	ret    

80105dea <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105dea:	55                   	push   %ebp
80105deb:	89 e5                	mov    %esp,%ebp
80105ded:	83 ec 38             	sub    $0x38,%esp
80105df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105df3:	8b 55 10             	mov    0x10(%ebp),%edx
80105df6:	8b 45 14             	mov    0x14(%ebp),%eax
80105df9:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dfd:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e01:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e05:	83 ec 08             	sub    $0x8,%esp
80105e08:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e0b:	50                   	push   %eax
80105e0c:	ff 75 08             	push   0x8(%ebp)
80105e0f:	e8 25 c7 ff ff       	call   80102539 <nameiparent>
80105e14:	83 c4 10             	add    $0x10,%esp
80105e17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e1e:	75 0a                	jne    80105e2a <create+0x40>
    return 0;
80105e20:	b8 00 00 00 00       	mov    $0x0,%eax
80105e25:	e9 90 01 00 00       	jmp    80105fba <create+0x1d0>
  ilock(dp);
80105e2a:	83 ec 0c             	sub    $0xc,%esp
80105e2d:	ff 75 f4             	push   -0xc(%ebp)
80105e30:	e8 b5 bb ff ff       	call   801019ea <ilock>
80105e35:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e38:	83 ec 04             	sub    $0x4,%esp
80105e3b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e3e:	50                   	push   %eax
80105e3f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e42:	50                   	push   %eax
80105e43:	ff 75 f4             	push   -0xc(%ebp)
80105e46:	e8 81 c3 ff ff       	call   801021cc <dirlookup>
80105e4b:	83 c4 10             	add    $0x10,%esp
80105e4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e55:	74 50                	je     80105ea7 <create+0xbd>
    iunlockput(dp);
80105e57:	83 ec 0c             	sub    $0xc,%esp
80105e5a:	ff 75 f4             	push   -0xc(%ebp)
80105e5d:	e8 b9 bd ff ff       	call   80101c1b <iunlockput>
80105e62:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e65:	83 ec 0c             	sub    $0xc,%esp
80105e68:	ff 75 f0             	push   -0x10(%ebp)
80105e6b:	e8 7a bb ff ff       	call   801019ea <ilock>
80105e70:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e73:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e78:	75 15                	jne    80105e8f <create+0xa5>
80105e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e81:	66 83 f8 02          	cmp    $0x2,%ax
80105e85:	75 08                	jne    80105e8f <create+0xa5>
      return ip;
80105e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8a:	e9 2b 01 00 00       	jmp    80105fba <create+0x1d0>
    iunlockput(ip);
80105e8f:	83 ec 0c             	sub    $0xc,%esp
80105e92:	ff 75 f0             	push   -0x10(%ebp)
80105e95:	e8 81 bd ff ff       	call   80101c1b <iunlockput>
80105e9a:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e9d:	b8 00 00 00 00       	mov    $0x0,%eax
80105ea2:	e9 13 01 00 00       	jmp    80105fba <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105ea7:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eae:	8b 00                	mov    (%eax),%eax
80105eb0:	83 ec 08             	sub    $0x8,%esp
80105eb3:	52                   	push   %edx
80105eb4:	50                   	push   %eax
80105eb5:	e8 7c b8 ff ff       	call   80101736 <ialloc>
80105eba:	83 c4 10             	add    $0x10,%esp
80105ebd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ec0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ec4:	75 0d                	jne    80105ed3 <create+0xe9>
    panic("create: ialloc");
80105ec6:	83 ec 0c             	sub    $0xc,%esp
80105ec9:	68 5c ae 10 80       	push   $0x8010ae5c
80105ece:	e8 d6 a6 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105ed3:	83 ec 0c             	sub    $0xc,%esp
80105ed6:	ff 75 f0             	push   -0x10(%ebp)
80105ed9:	e8 0c bb ff ff       	call   801019ea <ilock>
80105ede:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee4:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105ee8:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eef:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105ef3:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efa:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105f00:	83 ec 0c             	sub    $0xc,%esp
80105f03:	ff 75 f0             	push   -0x10(%ebp)
80105f06:	e8 02 b9 ff ff       	call   8010180d <iupdate>
80105f0b:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105f0e:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f13:	75 6a                	jne    80105f7f <create+0x195>
    dp->nlink++;  // for ".."
80105f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f18:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f1c:	83 c0 01             	add    $0x1,%eax
80105f1f:	89 c2                	mov    %eax,%edx
80105f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f24:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105f28:	83 ec 0c             	sub    $0xc,%esp
80105f2b:	ff 75 f4             	push   -0xc(%ebp)
80105f2e:	e8 da b8 ff ff       	call   8010180d <iupdate>
80105f33:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f39:	8b 40 04             	mov    0x4(%eax),%eax
80105f3c:	83 ec 04             	sub    $0x4,%esp
80105f3f:	50                   	push   %eax
80105f40:	68 36 ae 10 80       	push   $0x8010ae36
80105f45:	ff 75 f0             	push   -0x10(%ebp)
80105f48:	e8 39 c3 ff ff       	call   80102286 <dirlink>
80105f4d:	83 c4 10             	add    $0x10,%esp
80105f50:	85 c0                	test   %eax,%eax
80105f52:	78 1e                	js     80105f72 <create+0x188>
80105f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f57:	8b 40 04             	mov    0x4(%eax),%eax
80105f5a:	83 ec 04             	sub    $0x4,%esp
80105f5d:	50                   	push   %eax
80105f5e:	68 38 ae 10 80       	push   $0x8010ae38
80105f63:	ff 75 f0             	push   -0x10(%ebp)
80105f66:	e8 1b c3 ff ff       	call   80102286 <dirlink>
80105f6b:	83 c4 10             	add    $0x10,%esp
80105f6e:	85 c0                	test   %eax,%eax
80105f70:	79 0d                	jns    80105f7f <create+0x195>
      panic("create dots");
80105f72:	83 ec 0c             	sub    $0xc,%esp
80105f75:	68 6b ae 10 80       	push   $0x8010ae6b
80105f7a:	e8 2a a6 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f82:	8b 40 04             	mov    0x4(%eax),%eax
80105f85:	83 ec 04             	sub    $0x4,%esp
80105f88:	50                   	push   %eax
80105f89:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f8c:	50                   	push   %eax
80105f8d:	ff 75 f4             	push   -0xc(%ebp)
80105f90:	e8 f1 c2 ff ff       	call   80102286 <dirlink>
80105f95:	83 c4 10             	add    $0x10,%esp
80105f98:	85 c0                	test   %eax,%eax
80105f9a:	79 0d                	jns    80105fa9 <create+0x1bf>
    panic("create: dirlink");
80105f9c:	83 ec 0c             	sub    $0xc,%esp
80105f9f:	68 77 ae 10 80       	push   $0x8010ae77
80105fa4:	e8 00 a6 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105fa9:	83 ec 0c             	sub    $0xc,%esp
80105fac:	ff 75 f4             	push   -0xc(%ebp)
80105faf:	e8 67 bc ff ff       	call   80101c1b <iunlockput>
80105fb4:	83 c4 10             	add    $0x10,%esp

  return ip;
80105fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105fba:	c9                   	leave  
80105fbb:	c3                   	ret    

80105fbc <sys_open>:

int
sys_open(void)
{
80105fbc:	55                   	push   %ebp
80105fbd:	89 e5                	mov    %esp,%ebp
80105fbf:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105fc2:	83 ec 08             	sub    $0x8,%esp
80105fc5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fc8:	50                   	push   %eax
80105fc9:	6a 00                	push   $0x0
80105fcb:	e8 ea f6 ff ff       	call   801056ba <argstr>
80105fd0:	83 c4 10             	add    $0x10,%esp
80105fd3:	85 c0                	test   %eax,%eax
80105fd5:	78 15                	js     80105fec <sys_open+0x30>
80105fd7:	83 ec 08             	sub    $0x8,%esp
80105fda:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fdd:	50                   	push   %eax
80105fde:	6a 01                	push   $0x1
80105fe0:	e8 40 f6 ff ff       	call   80105625 <argint>
80105fe5:	83 c4 10             	add    $0x10,%esp
80105fe8:	85 c0                	test   %eax,%eax
80105fea:	79 0a                	jns    80105ff6 <sys_open+0x3a>
    return -1;
80105fec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff1:	e9 61 01 00 00       	jmp    80106157 <sys_open+0x19b>

  begin_op();
80105ff6:	e8 25 d5 ff ff       	call   80103520 <begin_op>

  if(omode & O_CREATE){
80105ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ffe:	25 00 02 00 00       	and    $0x200,%eax
80106003:	85 c0                	test   %eax,%eax
80106005:	74 2a                	je     80106031 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106007:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010600a:	6a 00                	push   $0x0
8010600c:	6a 00                	push   $0x0
8010600e:	6a 02                	push   $0x2
80106010:	50                   	push   %eax
80106011:	e8 d4 fd ff ff       	call   80105dea <create>
80106016:	83 c4 10             	add    $0x10,%esp
80106019:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010601c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106020:	75 75                	jne    80106097 <sys_open+0xdb>
      end_op();
80106022:	e8 85 d5 ff ff       	call   801035ac <end_op>
      return -1;
80106027:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602c:	e9 26 01 00 00       	jmp    80106157 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106031:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106034:	83 ec 0c             	sub    $0xc,%esp
80106037:	50                   	push   %eax
80106038:	e8 e0 c4 ff ff       	call   8010251d <namei>
8010603d:	83 c4 10             	add    $0x10,%esp
80106040:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106043:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106047:	75 0f                	jne    80106058 <sys_open+0x9c>
      end_op();
80106049:	e8 5e d5 ff ff       	call   801035ac <end_op>
      return -1;
8010604e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106053:	e9 ff 00 00 00       	jmp    80106157 <sys_open+0x19b>
    }
    ilock(ip);
80106058:	83 ec 0c             	sub    $0xc,%esp
8010605b:	ff 75 f4             	push   -0xc(%ebp)
8010605e:	e8 87 b9 ff ff       	call   801019ea <ilock>
80106063:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106069:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010606d:	66 83 f8 01          	cmp    $0x1,%ax
80106071:	75 24                	jne    80106097 <sys_open+0xdb>
80106073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106076:	85 c0                	test   %eax,%eax
80106078:	74 1d                	je     80106097 <sys_open+0xdb>
      iunlockput(ip);
8010607a:	83 ec 0c             	sub    $0xc,%esp
8010607d:	ff 75 f4             	push   -0xc(%ebp)
80106080:	e8 96 bb ff ff       	call   80101c1b <iunlockput>
80106085:	83 c4 10             	add    $0x10,%esp
      end_op();
80106088:	e8 1f d5 ff ff       	call   801035ac <end_op>
      return -1;
8010608d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106092:	e9 c0 00 00 00       	jmp    80106157 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106097:	e8 41 af ff ff       	call   80100fdd <filealloc>
8010609c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010609f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060a3:	74 17                	je     801060bc <sys_open+0x100>
801060a5:	83 ec 0c             	sub    $0xc,%esp
801060a8:	ff 75 f0             	push   -0x10(%ebp)
801060ab:	e8 33 f7 ff ff       	call   801057e3 <fdalloc>
801060b0:	83 c4 10             	add    $0x10,%esp
801060b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801060b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801060ba:	79 2e                	jns    801060ea <sys_open+0x12e>
    if(f)
801060bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060c0:	74 0e                	je     801060d0 <sys_open+0x114>
      fileclose(f);
801060c2:	83 ec 0c             	sub    $0xc,%esp
801060c5:	ff 75 f0             	push   -0x10(%ebp)
801060c8:	e8 ce af ff ff       	call   8010109b <fileclose>
801060cd:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801060d0:	83 ec 0c             	sub    $0xc,%esp
801060d3:	ff 75 f4             	push   -0xc(%ebp)
801060d6:	e8 40 bb ff ff       	call   80101c1b <iunlockput>
801060db:	83 c4 10             	add    $0x10,%esp
    end_op();
801060de:	e8 c9 d4 ff ff       	call   801035ac <end_op>
    return -1;
801060e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e8:	eb 6d                	jmp    80106157 <sys_open+0x19b>
  }
  iunlock(ip);
801060ea:	83 ec 0c             	sub    $0xc,%esp
801060ed:	ff 75 f4             	push   -0xc(%ebp)
801060f0:	e8 08 ba ff ff       	call   80101afd <iunlock>
801060f5:	83 c4 10             	add    $0x10,%esp
  end_op();
801060f8:	e8 af d4 ff ff       	call   801035ac <end_op>

  f->type = FD_INODE;
801060fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106100:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106106:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106109:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010610c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010610f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106112:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106119:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010611c:	83 e0 01             	and    $0x1,%eax
8010611f:	85 c0                	test   %eax,%eax
80106121:	0f 94 c0             	sete   %al
80106124:	89 c2                	mov    %eax,%edx
80106126:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106129:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010612c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010612f:	83 e0 01             	and    $0x1,%eax
80106132:	85 c0                	test   %eax,%eax
80106134:	75 0a                	jne    80106140 <sys_open+0x184>
80106136:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106139:	83 e0 02             	and    $0x2,%eax
8010613c:	85 c0                	test   %eax,%eax
8010613e:	74 07                	je     80106147 <sys_open+0x18b>
80106140:	b8 01 00 00 00       	mov    $0x1,%eax
80106145:	eb 05                	jmp    8010614c <sys_open+0x190>
80106147:	b8 00 00 00 00       	mov    $0x0,%eax
8010614c:	89 c2                	mov    %eax,%edx
8010614e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106151:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106154:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106157:	c9                   	leave  
80106158:	c3                   	ret    

80106159 <sys_mkdir>:

int
sys_mkdir(void)
{
80106159:	55                   	push   %ebp
8010615a:	89 e5                	mov    %esp,%ebp
8010615c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010615f:	e8 bc d3 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106164:	83 ec 08             	sub    $0x8,%esp
80106167:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010616a:	50                   	push   %eax
8010616b:	6a 00                	push   $0x0
8010616d:	e8 48 f5 ff ff       	call   801056ba <argstr>
80106172:	83 c4 10             	add    $0x10,%esp
80106175:	85 c0                	test   %eax,%eax
80106177:	78 1b                	js     80106194 <sys_mkdir+0x3b>
80106179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617c:	6a 00                	push   $0x0
8010617e:	6a 00                	push   $0x0
80106180:	6a 01                	push   $0x1
80106182:	50                   	push   %eax
80106183:	e8 62 fc ff ff       	call   80105dea <create>
80106188:	83 c4 10             	add    $0x10,%esp
8010618b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010618e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106192:	75 0c                	jne    801061a0 <sys_mkdir+0x47>
    end_op();
80106194:	e8 13 d4 ff ff       	call   801035ac <end_op>
    return -1;
80106199:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619e:	eb 18                	jmp    801061b8 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801061a0:	83 ec 0c             	sub    $0xc,%esp
801061a3:	ff 75 f4             	push   -0xc(%ebp)
801061a6:	e8 70 ba ff ff       	call   80101c1b <iunlockput>
801061ab:	83 c4 10             	add    $0x10,%esp
  end_op();
801061ae:	e8 f9 d3 ff ff       	call   801035ac <end_op>
  return 0;
801061b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061b8:	c9                   	leave  
801061b9:	c3                   	ret    

801061ba <sys_mknod>:

int
sys_mknod(void)
{
801061ba:	55                   	push   %ebp
801061bb:	89 e5                	mov    %esp,%ebp
801061bd:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801061c0:	e8 5b d3 ff ff       	call   80103520 <begin_op>
  if((argstr(0, &path)) < 0 ||
801061c5:	83 ec 08             	sub    $0x8,%esp
801061c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061cb:	50                   	push   %eax
801061cc:	6a 00                	push   $0x0
801061ce:	e8 e7 f4 ff ff       	call   801056ba <argstr>
801061d3:	83 c4 10             	add    $0x10,%esp
801061d6:	85 c0                	test   %eax,%eax
801061d8:	78 4f                	js     80106229 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801061da:	83 ec 08             	sub    $0x8,%esp
801061dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061e0:	50                   	push   %eax
801061e1:	6a 01                	push   $0x1
801061e3:	e8 3d f4 ff ff       	call   80105625 <argint>
801061e8:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801061eb:	85 c0                	test   %eax,%eax
801061ed:	78 3a                	js     80106229 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801061ef:	83 ec 08             	sub    $0x8,%esp
801061f2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061f5:	50                   	push   %eax
801061f6:	6a 02                	push   $0x2
801061f8:	e8 28 f4 ff ff       	call   80105625 <argint>
801061fd:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106200:	85 c0                	test   %eax,%eax
80106202:	78 25                	js     80106229 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106204:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106207:	0f bf c8             	movswl %ax,%ecx
8010620a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010620d:	0f bf d0             	movswl %ax,%edx
80106210:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106213:	51                   	push   %ecx
80106214:	52                   	push   %edx
80106215:	6a 03                	push   $0x3
80106217:	50                   	push   %eax
80106218:	e8 cd fb ff ff       	call   80105dea <create>
8010621d:	83 c4 10             	add    $0x10,%esp
80106220:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106223:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106227:	75 0c                	jne    80106235 <sys_mknod+0x7b>
    end_op();
80106229:	e8 7e d3 ff ff       	call   801035ac <end_op>
    return -1;
8010622e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106233:	eb 18                	jmp    8010624d <sys_mknod+0x93>
  }
  iunlockput(ip);
80106235:	83 ec 0c             	sub    $0xc,%esp
80106238:	ff 75 f4             	push   -0xc(%ebp)
8010623b:	e8 db b9 ff ff       	call   80101c1b <iunlockput>
80106240:	83 c4 10             	add    $0x10,%esp
  end_op();
80106243:	e8 64 d3 ff ff       	call   801035ac <end_op>
  return 0;
80106248:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010624d:	c9                   	leave  
8010624e:	c3                   	ret    

8010624f <sys_chdir>:

int
sys_chdir(void)
{
8010624f:	55                   	push   %ebp
80106250:	89 e5                	mov    %esp,%ebp
80106252:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106255:	e8 ba dc ff ff       	call   80103f14 <myproc>
8010625a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010625d:	e8 be d2 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106262:	83 ec 08             	sub    $0x8,%esp
80106265:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106268:	50                   	push   %eax
80106269:	6a 00                	push   $0x0
8010626b:	e8 4a f4 ff ff       	call   801056ba <argstr>
80106270:	83 c4 10             	add    $0x10,%esp
80106273:	85 c0                	test   %eax,%eax
80106275:	78 18                	js     8010628f <sys_chdir+0x40>
80106277:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010627a:	83 ec 0c             	sub    $0xc,%esp
8010627d:	50                   	push   %eax
8010627e:	e8 9a c2 ff ff       	call   8010251d <namei>
80106283:	83 c4 10             	add    $0x10,%esp
80106286:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106289:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010628d:	75 0c                	jne    8010629b <sys_chdir+0x4c>
    end_op();
8010628f:	e8 18 d3 ff ff       	call   801035ac <end_op>
    return -1;
80106294:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106299:	eb 68                	jmp    80106303 <sys_chdir+0xb4>
  }
  ilock(ip);
8010629b:	83 ec 0c             	sub    $0xc,%esp
8010629e:	ff 75 f0             	push   -0x10(%ebp)
801062a1:	e8 44 b7 ff ff       	call   801019ea <ilock>
801062a6:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801062a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ac:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801062b0:	66 83 f8 01          	cmp    $0x1,%ax
801062b4:	74 1a                	je     801062d0 <sys_chdir+0x81>
    iunlockput(ip);
801062b6:	83 ec 0c             	sub    $0xc,%esp
801062b9:	ff 75 f0             	push   -0x10(%ebp)
801062bc:	e8 5a b9 ff ff       	call   80101c1b <iunlockput>
801062c1:	83 c4 10             	add    $0x10,%esp
    end_op();
801062c4:	e8 e3 d2 ff ff       	call   801035ac <end_op>
    return -1;
801062c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ce:	eb 33                	jmp    80106303 <sys_chdir+0xb4>
  }
  iunlock(ip);
801062d0:	83 ec 0c             	sub    $0xc,%esp
801062d3:	ff 75 f0             	push   -0x10(%ebp)
801062d6:	e8 22 b8 ff ff       	call   80101afd <iunlock>
801062db:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801062de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e1:	8b 40 68             	mov    0x68(%eax),%eax
801062e4:	83 ec 0c             	sub    $0xc,%esp
801062e7:	50                   	push   %eax
801062e8:	e8 5e b8 ff ff       	call   80101b4b <iput>
801062ed:	83 c4 10             	add    $0x10,%esp
  end_op();
801062f0:	e8 b7 d2 ff ff       	call   801035ac <end_op>
  curproc->cwd = ip;
801062f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062fb:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106303:	c9                   	leave  
80106304:	c3                   	ret    

80106305 <sys_exec>:

int
sys_exec(void)
{
80106305:	55                   	push   %ebp
80106306:	89 e5                	mov    %esp,%ebp
80106308:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010630e:	83 ec 08             	sub    $0x8,%esp
80106311:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106314:	50                   	push   %eax
80106315:	6a 00                	push   $0x0
80106317:	e8 9e f3 ff ff       	call   801056ba <argstr>
8010631c:	83 c4 10             	add    $0x10,%esp
8010631f:	85 c0                	test   %eax,%eax
80106321:	78 18                	js     8010633b <sys_exec+0x36>
80106323:	83 ec 08             	sub    $0x8,%esp
80106326:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010632c:	50                   	push   %eax
8010632d:	6a 01                	push   $0x1
8010632f:	e8 f1 f2 ff ff       	call   80105625 <argint>
80106334:	83 c4 10             	add    $0x10,%esp
80106337:	85 c0                	test   %eax,%eax
80106339:	79 0a                	jns    80106345 <sys_exec+0x40>
    return -1;
8010633b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106340:	e9 c6 00 00 00       	jmp    8010640b <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106345:	83 ec 04             	sub    $0x4,%esp
80106348:	68 80 00 00 00       	push   $0x80
8010634d:	6a 00                	push   $0x0
8010634f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106355:	50                   	push   %eax
80106356:	e8 9f ef ff ff       	call   801052fa <memset>
8010635b:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010635e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106368:	83 f8 1f             	cmp    $0x1f,%eax
8010636b:	76 0a                	jbe    80106377 <sys_exec+0x72>
      return -1;
8010636d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106372:	e9 94 00 00 00       	jmp    8010640b <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637a:	c1 e0 02             	shl    $0x2,%eax
8010637d:	89 c2                	mov    %eax,%edx
8010637f:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106385:	01 c2                	add    %eax,%edx
80106387:	83 ec 08             	sub    $0x8,%esp
8010638a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106390:	50                   	push   %eax
80106391:	52                   	push   %edx
80106392:	e8 ed f1 ff ff       	call   80105584 <fetchint>
80106397:	83 c4 10             	add    $0x10,%esp
8010639a:	85 c0                	test   %eax,%eax
8010639c:	79 07                	jns    801063a5 <sys_exec+0xa0>
      return -1;
8010639e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a3:	eb 66                	jmp    8010640b <sys_exec+0x106>
    if(uarg == 0){
801063a5:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063ab:	85 c0                	test   %eax,%eax
801063ad:	75 27                	jne    801063d6 <sys_exec+0xd1>
      argv[i] = 0;
801063af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b2:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801063b9:	00 00 00 00 
      break;
801063bd:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801063be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c1:	83 ec 08             	sub    $0x8,%esp
801063c4:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063ca:	52                   	push   %edx
801063cb:	50                   	push   %eax
801063cc:	e8 af a7 ff ff       	call   80100b80 <exec>
801063d1:	83 c4 10             	add    $0x10,%esp
801063d4:	eb 35                	jmp    8010640b <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
801063d6:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063df:	c1 e0 02             	shl    $0x2,%eax
801063e2:	01 c2                	add    %eax,%edx
801063e4:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063ea:	83 ec 08             	sub    $0x8,%esp
801063ed:	52                   	push   %edx
801063ee:	50                   	push   %eax
801063ef:	e8 cf f1 ff ff       	call   801055c3 <fetchstr>
801063f4:	83 c4 10             	add    $0x10,%esp
801063f7:	85 c0                	test   %eax,%eax
801063f9:	79 07                	jns    80106402 <sys_exec+0xfd>
      return -1;
801063fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106400:	eb 09                	jmp    8010640b <sys_exec+0x106>
  for(i=0;; i++){
80106402:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106406:	e9 5a ff ff ff       	jmp    80106365 <sys_exec+0x60>
}
8010640b:	c9                   	leave  
8010640c:	c3                   	ret    

8010640d <sys_pipe>:

int
sys_pipe(void)
{
8010640d:	55                   	push   %ebp
8010640e:	89 e5                	mov    %esp,%ebp
80106410:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106413:	83 ec 04             	sub    $0x4,%esp
80106416:	6a 08                	push   $0x8
80106418:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010641b:	50                   	push   %eax
8010641c:	6a 00                	push   $0x0
8010641e:	e8 2f f2 ff ff       	call   80105652 <argptr>
80106423:	83 c4 10             	add    $0x10,%esp
80106426:	85 c0                	test   %eax,%eax
80106428:	79 0a                	jns    80106434 <sys_pipe+0x27>
    return -1;
8010642a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642f:	e9 ae 00 00 00       	jmp    801064e2 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80106434:	83 ec 08             	sub    $0x8,%esp
80106437:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010643a:	50                   	push   %eax
8010643b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010643e:	50                   	push   %eax
8010643f:	e8 0d d6 ff ff       	call   80103a51 <pipealloc>
80106444:	83 c4 10             	add    $0x10,%esp
80106447:	85 c0                	test   %eax,%eax
80106449:	79 0a                	jns    80106455 <sys_pipe+0x48>
    return -1;
8010644b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106450:	e9 8d 00 00 00       	jmp    801064e2 <sys_pipe+0xd5>
  fd0 = -1;
80106455:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010645c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010645f:	83 ec 0c             	sub    $0xc,%esp
80106462:	50                   	push   %eax
80106463:	e8 7b f3 ff ff       	call   801057e3 <fdalloc>
80106468:	83 c4 10             	add    $0x10,%esp
8010646b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010646e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106472:	78 18                	js     8010648c <sys_pipe+0x7f>
80106474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106477:	83 ec 0c             	sub    $0xc,%esp
8010647a:	50                   	push   %eax
8010647b:	e8 63 f3 ff ff       	call   801057e3 <fdalloc>
80106480:	83 c4 10             	add    $0x10,%esp
80106483:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106486:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010648a:	79 3e                	jns    801064ca <sys_pipe+0xbd>
    if(fd0 >= 0)
8010648c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106490:	78 13                	js     801064a5 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80106492:	e8 7d da ff ff       	call   80103f14 <myproc>
80106497:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010649a:	83 c2 08             	add    $0x8,%edx
8010649d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064a4:	00 
    fileclose(rf);
801064a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064a8:	83 ec 0c             	sub    $0xc,%esp
801064ab:	50                   	push   %eax
801064ac:	e8 ea ab ff ff       	call   8010109b <fileclose>
801064b1:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801064b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064b7:	83 ec 0c             	sub    $0xc,%esp
801064ba:	50                   	push   %eax
801064bb:	e8 db ab ff ff       	call   8010109b <fileclose>
801064c0:	83 c4 10             	add    $0x10,%esp
    return -1;
801064c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c8:	eb 18                	jmp    801064e2 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
801064ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064d0:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801064d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064d5:	8d 50 04             	lea    0x4(%eax),%edx
801064d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064db:	89 02                	mov    %eax,(%edx)
  return 0;
801064dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064e2:	c9                   	leave  
801064e3:	c3                   	ret    

801064e4 <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
801064e4:	55                   	push   %ebp
801064e5:	89 e5                	mov    %esp,%ebp
801064e7:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064ea:	e8 5f dd ff ff       	call   8010424e <fork>
}
801064ef:	c9                   	leave  
801064f0:	c3                   	ret    

801064f1 <sys_exit>:

int
sys_exit(void)
{
801064f1:	55                   	push   %ebp
801064f2:	89 e5                	mov    %esp,%ebp
801064f4:	83 ec 08             	sub    $0x8,%esp
  exit();
801064f7:	e8 cb de ff ff       	call   801043c7 <exit>
  return 0;  // not reached
801064fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106501:	c9                   	leave  
80106502:	c3                   	ret    

80106503 <sys_wait>:

int
sys_wait(void)
{
80106503:	55                   	push   %ebp
80106504:	89 e5                	mov    %esp,%ebp
80106506:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106509:	e8 dc df ff ff       	call   801044ea <wait>
}
8010650e:	c9                   	leave  
8010650f:	c3                   	ret    

80106510 <sys_kill>:

int
sys_kill(void)
{
80106510:	55                   	push   %ebp
80106511:	89 e5                	mov    %esp,%ebp
80106513:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106516:	83 ec 08             	sub    $0x8,%esp
80106519:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010651c:	50                   	push   %eax
8010651d:	6a 00                	push   $0x0
8010651f:	e8 01 f1 ff ff       	call   80105625 <argint>
80106524:	83 c4 10             	add    $0x10,%esp
80106527:	85 c0                	test   %eax,%eax
80106529:	79 07                	jns    80106532 <sys_kill+0x22>
    return -1;
8010652b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106530:	eb 0f                	jmp    80106541 <sys_kill+0x31>
  return kill(pid);
80106532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106535:	83 ec 0c             	sub    $0xc,%esp
80106538:	50                   	push   %eax
80106539:	e8 f6 e6 ff ff       	call   80104c34 <kill>
8010653e:	83 c4 10             	add    $0x10,%esp
}
80106541:	c9                   	leave  
80106542:	c3                   	ret    

80106543 <sys_getpid>:

int
sys_getpid(void)
{
80106543:	55                   	push   %ebp
80106544:	89 e5                	mov    %esp,%ebp
80106546:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106549:	e8 c6 d9 ff ff       	call   80103f14 <myproc>
8010654e:	8b 40 10             	mov    0x10(%eax),%eax
}
80106551:	c9                   	leave  
80106552:	c3                   	ret    

80106553 <sys_sbrk>:

int
sys_sbrk(void)
{
80106553:	55                   	push   %ebp
80106554:	89 e5                	mov    %esp,%ebp
80106556:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106559:	83 ec 08             	sub    $0x8,%esp
8010655c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010655f:	50                   	push   %eax
80106560:	6a 00                	push   $0x0
80106562:	e8 be f0 ff ff       	call   80105625 <argint>
80106567:	83 c4 10             	add    $0x10,%esp
8010656a:	85 c0                	test   %eax,%eax
8010656c:	79 07                	jns    80106575 <sys_sbrk+0x22>
    return -1;
8010656e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106573:	eb 27                	jmp    8010659c <sys_sbrk+0x49>
  addr = myproc()->sz;
80106575:	e8 9a d9 ff ff       	call   80103f14 <myproc>
8010657a:	8b 00                	mov    (%eax),%eax
8010657c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010657f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106582:	83 ec 0c             	sub    $0xc,%esp
80106585:	50                   	push   %eax
80106586:	e8 28 dc ff ff       	call   801041b3 <growproc>
8010658b:	83 c4 10             	add    $0x10,%esp
8010658e:	85 c0                	test   %eax,%eax
80106590:	79 07                	jns    80106599 <sys_sbrk+0x46>
    return -1;
80106592:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106597:	eb 03                	jmp    8010659c <sys_sbrk+0x49>
  return addr;
80106599:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010659c:	c9                   	leave  
8010659d:	c3                   	ret    

8010659e <sys_sleep>:

int
sys_sleep(void)
{
8010659e:	55                   	push   %ebp
8010659f:	89 e5                	mov    %esp,%ebp
801065a1:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801065a4:	83 ec 08             	sub    $0x8,%esp
801065a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065aa:	50                   	push   %eax
801065ab:	6a 00                	push   $0x0
801065ad:	e8 73 f0 ff ff       	call   80105625 <argint>
801065b2:	83 c4 10             	add    $0x10,%esp
801065b5:	85 c0                	test   %eax,%eax
801065b7:	79 07                	jns    801065c0 <sys_sleep+0x22>
    return -1;
801065b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065be:	eb 76                	jmp    80106636 <sys_sleep+0x98>
  acquire(&tickslock);
801065c0:	83 ec 0c             	sub    $0xc,%esp
801065c3:	68 80 a2 11 80       	push   $0x8011a280
801065c8:	e8 b7 ea ff ff       	call   80105084 <acquire>
801065cd:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065d0:	a1 b4 a2 11 80       	mov    0x8011a2b4,%eax
801065d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065d8:	eb 38                	jmp    80106612 <sys_sleep+0x74>
    if(myproc()->killed){
801065da:	e8 35 d9 ff ff       	call   80103f14 <myproc>
801065df:	8b 40 24             	mov    0x24(%eax),%eax
801065e2:	85 c0                	test   %eax,%eax
801065e4:	74 17                	je     801065fd <sys_sleep+0x5f>
      release(&tickslock);
801065e6:	83 ec 0c             	sub    $0xc,%esp
801065e9:	68 80 a2 11 80       	push   $0x8011a280
801065ee:	e8 ff ea ff ff       	call   801050f2 <release>
801065f3:	83 c4 10             	add    $0x10,%esp
      return -1;
801065f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065fb:	eb 39                	jmp    80106636 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801065fd:	83 ec 08             	sub    $0x8,%esp
80106600:	68 80 a2 11 80       	push   $0x8011a280
80106605:	68 b4 a2 11 80       	push   $0x8011a2b4
8010660a:	e8 04 e5 ff ff       	call   80104b13 <sleep>
8010660f:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106612:	a1 b4 a2 11 80       	mov    0x8011a2b4,%eax
80106617:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010661a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010661d:	39 d0                	cmp    %edx,%eax
8010661f:	72 b9                	jb     801065da <sys_sleep+0x3c>
  }
  release(&tickslock);
80106621:	83 ec 0c             	sub    $0xc,%esp
80106624:	68 80 a2 11 80       	push   $0x8011a280
80106629:	e8 c4 ea ff ff       	call   801050f2 <release>
8010662e:	83 c4 10             	add    $0x10,%esp
  return 0;
80106631:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106636:	c9                   	leave  
80106637:	c3                   	ret    

80106638 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106638:	55                   	push   %ebp
80106639:	89 e5                	mov    %esp,%ebp
8010663b:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010663e:	83 ec 0c             	sub    $0xc,%esp
80106641:	68 80 a2 11 80       	push   $0x8011a280
80106646:	e8 39 ea ff ff       	call   80105084 <acquire>
8010664b:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010664e:	a1 b4 a2 11 80       	mov    0x8011a2b4,%eax
80106653:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106656:	83 ec 0c             	sub    $0xc,%esp
80106659:	68 80 a2 11 80       	push   $0x8011a280
8010665e:	e8 8f ea ff ff       	call   801050f2 <release>
80106663:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106666:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106669:	c9                   	leave  
8010666a:	c3                   	ret    

8010666b <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
8010666b:	55                   	push   %ebp
8010666c:	89 e5                	mov    %esp,%ebp
8010666e:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
80106671:	83 ec 08             	sub    $0x8,%esp
80106674:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106677:	50                   	push   %eax
80106678:	6a 00                	push   $0x0
8010667a:	e8 a6 ef ff ff       	call   80105625 <argint>
8010667f:	83 c4 10             	add    $0x10,%esp
80106682:	85 c0                	test   %eax,%eax
80106684:	79 07                	jns    8010668d <sys_setSchedPolicy+0x22>
    return -1;
80106686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010668b:	eb 0f                	jmp    8010669c <sys_setSchedPolicy+0x31>
  return setSchedPolicy(policy);
8010668d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106690:	83 ec 0c             	sub    $0xc,%esp
80106693:	50                   	push   %eax
80106694:	e8 1f e7 ff ff       	call   80104db8 <setSchedPolicy>
80106699:	83 c4 10             	add    $0x10,%esp
}
8010669c:	c9                   	leave  
8010669d:	c3                   	ret    

8010669e <sys_getpinfo>:



int
sys_getpinfo(void)
{
8010669e:	55                   	push   %ebp
8010669f:	89 e5                	mov    %esp,%ebp
801066a1:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(*ps)) < 0 )
801066a4:	83 ec 04             	sub    $0x4,%esp
801066a7:	68 00 0c 00 00       	push   $0xc00
801066ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066af:	50                   	push   %eax
801066b0:	6a 00                	push   $0x0
801066b2:	e8 9b ef ff ff       	call   80105652 <argptr>
801066b7:	83 c4 10             	add    $0x10,%esp
801066ba:	85 c0                	test   %eax,%eax
801066bc:	79 07                	jns    801066c5 <sys_getpinfo+0x27>
    return -1;
801066be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c3:	eb 0f                	jmp    801066d4 <sys_getpinfo+0x36>
  return getpinfo(ps);
801066c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c8:	83 ec 0c             	sub    $0xc,%esp
801066cb:	50                   	push   %eax
801066cc:	e8 25 e7 ff ff       	call   80104df6 <getpinfo>
801066d1:	83 c4 10             	add    $0x10,%esp
}
801066d4:	c9                   	leave  
801066d5:	c3                   	ret    

801066d6 <sys_yield>:

int
sys_yield(void)
{
801066d6:	55                   	push   %ebp
801066d7:	89 e5                	mov    %esp,%ebp
801066d9:	83 ec 08             	sub    $0x8,%esp
  yield();
801066dc:	e8 b2 e3 ff ff       	call   80104a93 <yield>
  return 0;
801066e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066e6:	c9                   	leave  
801066e7:	c3                   	ret    

801066e8 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801066e8:	1e                   	push   %ds
  pushl %es
801066e9:	06                   	push   %es
  pushl %fs
801066ea:	0f a0                	push   %fs
  pushl %gs
801066ec:	0f a8                	push   %gs
  pushal
801066ee:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801066ef:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801066f3:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801066f5:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801066f7:	54                   	push   %esp
  call trap
801066f8:	e8 d7 01 00 00       	call   801068d4 <trap>
  addl $4, %esp
801066fd:	83 c4 04             	add    $0x4,%esp

80106700 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106700:	61                   	popa   
  popl %gs
80106701:	0f a9                	pop    %gs
  popl %fs
80106703:	0f a1                	pop    %fs
  popl %es
80106705:	07                   	pop    %es
  popl %ds
80106706:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106707:	83 c4 08             	add    $0x8,%esp
  iret
8010670a:	cf                   	iret   

8010670b <lidt>:
{
8010670b:	55                   	push   %ebp
8010670c:	89 e5                	mov    %esp,%ebp
8010670e:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106711:	8b 45 0c             	mov    0xc(%ebp),%eax
80106714:	83 e8 01             	sub    $0x1,%eax
80106717:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010671b:	8b 45 08             	mov    0x8(%ebp),%eax
8010671e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106722:	8b 45 08             	mov    0x8(%ebp),%eax
80106725:	c1 e8 10             	shr    $0x10,%eax
80106728:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010672c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010672f:	0f 01 18             	lidtl  (%eax)
}
80106732:	90                   	nop
80106733:	c9                   	leave  
80106734:	c3                   	ret    

80106735 <rcr2>:

static inline uint
rcr2(void)
{
80106735:	55                   	push   %ebp
80106736:	89 e5                	mov    %esp,%ebp
80106738:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010673b:	0f 20 d0             	mov    %cr2,%eax
8010673e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106741:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106744:	c9                   	leave  
80106745:	c3                   	ret    

80106746 <tvinit>:
  struct proc proc[NPROC];
} ptable;

void
tvinit(void)
{
80106746:	55                   	push   %ebp
80106747:	89 e5                	mov    %esp,%ebp
80106749:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010674c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106753:	e9 c3 00 00 00       	jmp    8010681b <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675b:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106762:	89 c2                	mov    %eax,%edx
80106764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106767:	66 89 14 c5 80 9a 11 	mov    %dx,-0x7fee6580(,%eax,8)
8010676e:	80 
8010676f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106772:	66 c7 04 c5 82 9a 11 	movw   $0x8,-0x7fee657e(,%eax,8)
80106779:	80 08 00 
8010677c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677f:	0f b6 14 c5 84 9a 11 	movzbl -0x7fee657c(,%eax,8),%edx
80106786:	80 
80106787:	83 e2 e0             	and    $0xffffffe0,%edx
8010678a:	88 14 c5 84 9a 11 80 	mov    %dl,-0x7fee657c(,%eax,8)
80106791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106794:	0f b6 14 c5 84 9a 11 	movzbl -0x7fee657c(,%eax,8),%edx
8010679b:	80 
8010679c:	83 e2 1f             	and    $0x1f,%edx
8010679f:	88 14 c5 84 9a 11 80 	mov    %dl,-0x7fee657c(,%eax,8)
801067a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a9:	0f b6 14 c5 85 9a 11 	movzbl -0x7fee657b(,%eax,8),%edx
801067b0:	80 
801067b1:	83 e2 f0             	and    $0xfffffff0,%edx
801067b4:	83 ca 0e             	or     $0xe,%edx
801067b7:	88 14 c5 85 9a 11 80 	mov    %dl,-0x7fee657b(,%eax,8)
801067be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c1:	0f b6 14 c5 85 9a 11 	movzbl -0x7fee657b(,%eax,8),%edx
801067c8:	80 
801067c9:	83 e2 ef             	and    $0xffffffef,%edx
801067cc:	88 14 c5 85 9a 11 80 	mov    %dl,-0x7fee657b(,%eax,8)
801067d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d6:	0f b6 14 c5 85 9a 11 	movzbl -0x7fee657b(,%eax,8),%edx
801067dd:	80 
801067de:	83 e2 9f             	and    $0xffffff9f,%edx
801067e1:	88 14 c5 85 9a 11 80 	mov    %dl,-0x7fee657b(,%eax,8)
801067e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067eb:	0f b6 14 c5 85 9a 11 	movzbl -0x7fee657b(,%eax,8),%edx
801067f2:	80 
801067f3:	83 ca 80             	or     $0xffffff80,%edx
801067f6:	88 14 c5 85 9a 11 80 	mov    %dl,-0x7fee657b(,%eax,8)
801067fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106800:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106807:	c1 e8 10             	shr    $0x10,%eax
8010680a:	89 c2                	mov    %eax,%edx
8010680c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680f:	66 89 14 c5 86 9a 11 	mov    %dx,-0x7fee657a(,%eax,8)
80106816:	80 
  for(i = 0; i < 256; i++)
80106817:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010681b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106822:	0f 8e 30 ff ff ff    	jle    80106758 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106828:	a1 80 f1 10 80       	mov    0x8010f180,%eax
8010682d:	66 a3 80 9c 11 80    	mov    %ax,0x80119c80
80106833:	66 c7 05 82 9c 11 80 	movw   $0x8,0x80119c82
8010683a:	08 00 
8010683c:	0f b6 05 84 9c 11 80 	movzbl 0x80119c84,%eax
80106843:	83 e0 e0             	and    $0xffffffe0,%eax
80106846:	a2 84 9c 11 80       	mov    %al,0x80119c84
8010684b:	0f b6 05 84 9c 11 80 	movzbl 0x80119c84,%eax
80106852:	83 e0 1f             	and    $0x1f,%eax
80106855:	a2 84 9c 11 80       	mov    %al,0x80119c84
8010685a:	0f b6 05 85 9c 11 80 	movzbl 0x80119c85,%eax
80106861:	83 c8 0f             	or     $0xf,%eax
80106864:	a2 85 9c 11 80       	mov    %al,0x80119c85
80106869:	0f b6 05 85 9c 11 80 	movzbl 0x80119c85,%eax
80106870:	83 e0 ef             	and    $0xffffffef,%eax
80106873:	a2 85 9c 11 80       	mov    %al,0x80119c85
80106878:	0f b6 05 85 9c 11 80 	movzbl 0x80119c85,%eax
8010687f:	83 c8 60             	or     $0x60,%eax
80106882:	a2 85 9c 11 80       	mov    %al,0x80119c85
80106887:	0f b6 05 85 9c 11 80 	movzbl 0x80119c85,%eax
8010688e:	83 c8 80             	or     $0xffffff80,%eax
80106891:	a2 85 9c 11 80       	mov    %al,0x80119c85
80106896:	a1 80 f1 10 80       	mov    0x8010f180,%eax
8010689b:	c1 e8 10             	shr    $0x10,%eax
8010689e:	66 a3 86 9c 11 80    	mov    %ax,0x80119c86

  initlock(&tickslock, "time");
801068a4:	83 ec 08             	sub    $0x8,%esp
801068a7:	68 88 ae 10 80       	push   $0x8010ae88
801068ac:	68 80 a2 11 80       	push   $0x8011a280
801068b1:	e8 ac e7 ff ff       	call   80105062 <initlock>
801068b6:	83 c4 10             	add    $0x10,%esp
}
801068b9:	90                   	nop
801068ba:	c9                   	leave  
801068bb:	c3                   	ret    

801068bc <idtinit>:

void
idtinit(void)
{
801068bc:	55                   	push   %ebp
801068bd:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801068bf:	68 00 08 00 00       	push   $0x800
801068c4:	68 80 9a 11 80       	push   $0x80119a80
801068c9:	e8 3d fe ff ff       	call   8010670b <lidt>
801068ce:	83 c4 08             	add    $0x8,%esp
}
801068d1:	90                   	nop
801068d2:	c9                   	leave  
801068d3:	c3                   	ret    

801068d4 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801068d4:	55                   	push   %ebp
801068d5:	89 e5                	mov    %esp,%ebp
801068d7:	57                   	push   %edi
801068d8:	56                   	push   %esi
801068d9:	53                   	push   %ebx
801068da:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801068dd:	8b 45 08             	mov    0x8(%ebp),%eax
801068e0:	8b 40 30             	mov    0x30(%eax),%eax
801068e3:	83 f8 40             	cmp    $0x40,%eax
801068e6:	75 3b                	jne    80106923 <trap+0x4f>
    if(myproc()->killed)
801068e8:	e8 27 d6 ff ff       	call   80103f14 <myproc>
801068ed:	8b 40 24             	mov    0x24(%eax),%eax
801068f0:	85 c0                	test   %eax,%eax
801068f2:	74 05                	je     801068f9 <trap+0x25>
      exit();
801068f4:	e8 ce da ff ff       	call   801043c7 <exit>
    myproc()->tf = tf;
801068f9:	e8 16 d6 ff ff       	call   80103f14 <myproc>
801068fe:	8b 55 08             	mov    0x8(%ebp),%edx
80106901:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106904:	e8 e8 ed ff ff       	call   801056f1 <syscall>
    if(myproc()->killed)
80106909:	e8 06 d6 ff ff       	call   80103f14 <myproc>
8010690e:	8b 40 24             	mov    0x24(%eax),%eax
80106911:	85 c0                	test   %eax,%eax
80106913:	0f 84 f6 02 00 00    	je     80106c0f <trap+0x33b>
      exit();
80106919:	e8 a9 da ff ff       	call   801043c7 <exit>
    return;
8010691e:	e9 ec 02 00 00       	jmp    80106c0f <trap+0x33b>
  }

  switch(tf->trapno){
80106923:	8b 45 08             	mov    0x8(%ebp),%eax
80106926:	8b 40 30             	mov    0x30(%eax),%eax
80106929:	83 e8 20             	sub    $0x20,%eax
8010692c:	83 f8 1f             	cmp    $0x1f,%eax
8010692f:	0f 87 8c 01 00 00    	ja     80106ac1 <trap+0x1ed>
80106935:	8b 04 85 64 af 10 80 	mov    -0x7fef509c(,%eax,4),%eax
8010693c:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010693e:	e8 3e d5 ff ff       	call   80103e81 <cpuid>
80106943:	85 c0                	test   %eax,%eax
80106945:	75 3d                	jne    80106984 <trap+0xb0>
      acquire(&tickslock);
80106947:	83 ec 0c             	sub    $0xc,%esp
8010694a:	68 80 a2 11 80       	push   $0x8011a280
8010694f:	e8 30 e7 ff ff       	call   80105084 <acquire>
80106954:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106957:	a1 b4 a2 11 80       	mov    0x8011a2b4,%eax
8010695c:	83 c0 01             	add    $0x1,%eax
8010695f:	a3 b4 a2 11 80       	mov    %eax,0x8011a2b4
      wakeup(&ticks);
80106964:	83 ec 0c             	sub    $0xc,%esp
80106967:	68 b4 a2 11 80       	push   $0x8011a2b4
8010696c:	e8 8c e2 ff ff       	call   80104bfd <wakeup>
80106971:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106974:	83 ec 0c             	sub    $0xc,%esp
80106977:	68 80 a2 11 80       	push   $0x8011a280
8010697c:	e8 71 e7 ff ff       	call   801050f2 <release>
80106981:	83 c4 10             	add    $0x10,%esp
    }
    //추가
    struct proc *curproc = myproc();
80106984:	e8 8b d5 ff ff       	call   80103f14 <myproc>
80106989:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (curproc && curproc->state == RUNNING) {
8010698c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80106990:	74 53                	je     801069e5 <trap+0x111>
80106992:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106995:	8b 40 0c             	mov    0xc(%eax),%eax
80106998:	83 f8 04             	cmp    $0x4,%eax
8010699b:	75 48                	jne    801069e5 <trap+0x111>
      int q = curproc->priority;
8010699d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069a0:	8b 40 7c             	mov    0x7c(%eax),%eax
801069a3:	89 45 dc             	mov    %eax,-0x24(%ebp)

      curproc->ticks[q]++;
801069a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801069ac:	83 c2 20             	add    $0x20,%edx
801069af:	8b 04 90             	mov    (%eax,%edx,4),%eax
801069b2:	8d 48 01             	lea    0x1(%eax),%ecx
801069b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801069bb:	83 c2 20             	add    $0x20,%edx
801069be:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
      cprintf("[TRAP] pid %d | Q%d | tick=%d\n", curproc->pid, q, curproc->ticks[q]);
801069c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801069c7:	83 c2 20             	add    $0x20,%edx
801069ca:	8b 14 90             	mov    (%eax,%edx,4),%edx
801069cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069d0:	8b 40 10             	mov    0x10(%eax),%eax
801069d3:	52                   	push   %edx
801069d4:	ff 75 dc             	push   -0x24(%ebp)
801069d7:	50                   	push   %eax
801069d8:	68 90 ae 10 80       	push   $0x8010ae90
801069dd:	e8 12 9a ff ff       	call   801003f4 <cprintf>
801069e2:	83 c4 10             	add    $0x10,%esp

    }
    // RUNNABLE 상태이면서 현재 실행 중이 아닌 애들: wait_ticks 증가
    acquire(&ptable.lock);
801069e5:	83 ec 0c             	sub    $0xc,%esp
801069e8:	68 40 72 11 80       	push   $0x80117240
801069ed:	e8 92 e6 ff ff       	call   80105084 <acquire>
801069f2:	83 c4 10             	add    $0x10,%esp
    struct proc *p;
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801069f5:	c7 45 e4 74 72 11 80 	movl   $0x80117274,-0x1c(%ebp)
801069fc:	eb 35                	jmp    80106a33 <trap+0x15f>
      if (p != curproc && p->state == RUNNABLE) {
801069fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a01:	3b 45 e0             	cmp    -0x20(%ebp),%eax
80106a04:	74 26                	je     80106a2c <trap+0x158>
80106a06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a09:	8b 40 0c             	mov    0xc(%eax),%eax
80106a0c:	83 f8 03             	cmp    $0x3,%eax
80106a0f:	75 1b                	jne    80106a2c <trap+0x158>
        p->wait_ticks[p->priority]++;
80106a11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a14:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106a1a:	8d 48 24             	lea    0x24(%eax),%ecx
80106a1d:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80106a20:	8d 4a 01             	lea    0x1(%edx),%ecx
80106a23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106a26:	83 c0 24             	add    $0x24,%eax
80106a29:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106a2c:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
80106a33:	81 7d e4 74 9a 11 80 	cmpl   $0x80119a74,-0x1c(%ebp)
80106a3a:	72 c2                	jb     801069fe <trap+0x12a>
      }
    }
    release(&ptable.lock);
80106a3c:	83 ec 0c             	sub    $0xc,%esp
80106a3f:	68 40 72 11 80       	push   $0x80117240
80106a44:	e8 a9 e6 ff ff       	call   801050f2 <release>
80106a49:	83 c4 10             	add    $0x10,%esp

    lapiceoi();
80106a4c:	e8 af c5 ff ff       	call   80103000 <lapiceoi>
    break;
80106a51:	e9 20 01 00 00       	jmp    80106b76 <trap+0x2a2>

  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a56:	e8 fb bd ff ff       	call   80102856 <ideintr>
    lapiceoi();
80106a5b:	e8 a0 c5 ff ff       	call   80103000 <lapiceoi>
    break;
80106a60:	e9 11 01 00 00       	jmp    80106b76 <trap+0x2a2>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a65:	e8 db c3 ff ff       	call   80102e45 <kbdintr>
    lapiceoi();
80106a6a:	e8 91 c5 ff ff       	call   80103000 <lapiceoi>
    break;
80106a6f:	e9 02 01 00 00       	jmp    80106b76 <trap+0x2a2>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a74:	e8 6c 03 00 00       	call   80106de5 <uartintr>
    lapiceoi();
80106a79:	e8 82 c5 ff ff       	call   80103000 <lapiceoi>
    break;
80106a7e:	e9 f3 00 00 00       	jmp    80106b76 <trap+0x2a2>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106a83:	e8 94 2b 00 00       	call   8010961c <i8254_intr>
    lapiceoi();
80106a88:	e8 73 c5 ff ff       	call   80103000 <lapiceoi>
    break;
80106a8d:	e9 e4 00 00 00       	jmp    80106b76 <trap+0x2a2>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a92:	8b 45 08             	mov    0x8(%ebp),%eax
80106a95:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106a98:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a9f:	0f b7 d8             	movzwl %ax,%ebx
80106aa2:	e8 da d3 ff ff       	call   80103e81 <cpuid>
80106aa7:	56                   	push   %esi
80106aa8:	53                   	push   %ebx
80106aa9:	50                   	push   %eax
80106aaa:	68 b0 ae 10 80       	push   $0x8010aeb0
80106aaf:	e8 40 99 ff ff       	call   801003f4 <cprintf>
80106ab4:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106ab7:	e8 44 c5 ff ff       	call   80103000 <lapiceoi>
    break;
80106abc:	e9 b5 00 00 00       	jmp    80106b76 <trap+0x2a2>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106ac1:	e8 4e d4 ff ff       	call   80103f14 <myproc>
80106ac6:	85 c0                	test   %eax,%eax
80106ac8:	74 11                	je     80106adb <trap+0x207>
80106aca:	8b 45 08             	mov    0x8(%ebp),%eax
80106acd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ad1:	0f b7 c0             	movzwl %ax,%eax
80106ad4:	83 e0 03             	and    $0x3,%eax
80106ad7:	85 c0                	test   %eax,%eax
80106ad9:	75 39                	jne    80106b14 <trap+0x240>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106adb:	e8 55 fc ff ff       	call   80106735 <rcr2>
80106ae0:	89 c3                	mov    %eax,%ebx
80106ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae5:	8b 70 38             	mov    0x38(%eax),%esi
80106ae8:	e8 94 d3 ff ff       	call   80103e81 <cpuid>
80106aed:	8b 55 08             	mov    0x8(%ebp),%edx
80106af0:	8b 52 30             	mov    0x30(%edx),%edx
80106af3:	83 ec 0c             	sub    $0xc,%esp
80106af6:	53                   	push   %ebx
80106af7:	56                   	push   %esi
80106af8:	50                   	push   %eax
80106af9:	52                   	push   %edx
80106afa:	68 d4 ae 10 80       	push   $0x8010aed4
80106aff:	e8 f0 98 ff ff       	call   801003f4 <cprintf>
80106b04:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106b07:	83 ec 0c             	sub    $0xc,%esp
80106b0a:	68 06 af 10 80       	push   $0x8010af06
80106b0f:	e8 95 9a ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b14:	e8 1c fc ff ff       	call   80106735 <rcr2>
80106b19:	89 c6                	mov    %eax,%esi
80106b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80106b1e:	8b 40 38             	mov    0x38(%eax),%eax
80106b21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106b24:	e8 58 d3 ff ff       	call   80103e81 <cpuid>
80106b29:	89 c3                	mov    %eax,%ebx
80106b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106b2e:	8b 78 34             	mov    0x34(%eax),%edi
80106b31:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106b34:	8b 45 08             	mov    0x8(%ebp),%eax
80106b37:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106b3a:	e8 d5 d3 ff ff       	call   80103f14 <myproc>
80106b3f:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106b42:	89 4d cc             	mov    %ecx,-0x34(%ebp)
80106b45:	e8 ca d3 ff ff       	call   80103f14 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b4a:	8b 40 10             	mov    0x10(%eax),%eax
80106b4d:	56                   	push   %esi
80106b4e:	ff 75 d4             	push   -0x2c(%ebp)
80106b51:	53                   	push   %ebx
80106b52:	ff 75 d0             	push   -0x30(%ebp)
80106b55:	57                   	push   %edi
80106b56:	ff 75 cc             	push   -0x34(%ebp)
80106b59:	50                   	push   %eax
80106b5a:	68 0c af 10 80       	push   $0x8010af0c
80106b5f:	e8 90 98 ff ff       	call   801003f4 <cprintf>
80106b64:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106b67:	e8 a8 d3 ff ff       	call   80103f14 <myproc>
80106b6c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b73:	eb 01                	jmp    80106b76 <trap+0x2a2>
    break;
80106b75:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b76:	e8 99 d3 ff ff       	call   80103f14 <myproc>
80106b7b:	85 c0                	test   %eax,%eax
80106b7d:	74 23                	je     80106ba2 <trap+0x2ce>
80106b7f:	e8 90 d3 ff ff       	call   80103f14 <myproc>
80106b84:	8b 40 24             	mov    0x24(%eax),%eax
80106b87:	85 c0                	test   %eax,%eax
80106b89:	74 17                	je     80106ba2 <trap+0x2ce>
80106b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b92:	0f b7 c0             	movzwl %ax,%eax
80106b95:	83 e0 03             	and    $0x3,%eax
80106b98:	83 f8 03             	cmp    $0x3,%eax
80106b9b:	75 05                	jne    80106ba2 <trap+0x2ce>
    exit();
80106b9d:	e8 25 d8 ff ff       	call   801043c7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
80106ba2:	e8 6d d3 ff ff       	call   80103f14 <myproc>
80106ba7:	85 c0                	test   %eax,%eax
80106ba9:	74 36                	je     80106be1 <trap+0x30d>
80106bab:	e8 64 d3 ff ff       	call   80103f14 <myproc>
80106bb0:	8b 40 0c             	mov    0xc(%eax),%eax
80106bb3:	83 f8 04             	cmp    $0x4,%eax
80106bb6:	75 29                	jne    80106be1 <trap+0x30d>
80106bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80106bbb:	8b 40 30             	mov    0x30(%eax),%eax
80106bbe:	83 f8 20             	cmp    $0x20,%eax
80106bc1:	75 1e                	jne    80106be1 <trap+0x30d>
      cprintf("[YIELD] from pid %d\n", myproc()->pid);
80106bc3:	e8 4c d3 ff ff       	call   80103f14 <myproc>
80106bc8:	8b 40 10             	mov    0x10(%eax),%eax
80106bcb:	83 ec 08             	sub    $0x8,%esp
80106bce:	50                   	push   %eax
80106bcf:	68 4f af 10 80       	push   $0x8010af4f
80106bd4:	e8 1b 98 ff ff       	call   801003f4 <cprintf>
80106bd9:	83 c4 10             	add    $0x10,%esp
      yield();
80106bdc:	e8 b2 de ff ff       	call   80104a93 <yield>
  }

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106be1:	e8 2e d3 ff ff       	call   80103f14 <myproc>
80106be6:	85 c0                	test   %eax,%eax
80106be8:	74 26                	je     80106c10 <trap+0x33c>
80106bea:	e8 25 d3 ff ff       	call   80103f14 <myproc>
80106bef:	8b 40 24             	mov    0x24(%eax),%eax
80106bf2:	85 c0                	test   %eax,%eax
80106bf4:	74 1a                	je     80106c10 <trap+0x33c>
80106bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bfd:	0f b7 c0             	movzwl %ax,%eax
80106c00:	83 e0 03             	and    $0x3,%eax
80106c03:	83 f8 03             	cmp    $0x3,%eax
80106c06:	75 08                	jne    80106c10 <trap+0x33c>
    exit();
80106c08:	e8 ba d7 ff ff       	call   801043c7 <exit>
80106c0d:	eb 01                	jmp    80106c10 <trap+0x33c>
    return;
80106c0f:	90                   	nop
80106c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106c13:	5b                   	pop    %ebx
80106c14:	5e                   	pop    %esi
80106c15:	5f                   	pop    %edi
80106c16:	5d                   	pop    %ebp
80106c17:	c3                   	ret    

80106c18 <inb>:
{
80106c18:	55                   	push   %ebp
80106c19:	89 e5                	mov    %esp,%ebp
80106c1b:	83 ec 14             	sub    $0x14,%esp
80106c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c21:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c25:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106c29:	89 c2                	mov    %eax,%edx
80106c2b:	ec                   	in     (%dx),%al
80106c2c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106c2f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106c33:	c9                   	leave  
80106c34:	c3                   	ret    

80106c35 <outb>:
{
80106c35:	55                   	push   %ebp
80106c36:	89 e5                	mov    %esp,%ebp
80106c38:	83 ec 08             	sub    $0x8,%esp
80106c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c41:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106c45:	89 d0                	mov    %edx,%eax
80106c47:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c4a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c4e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c52:	ee                   	out    %al,(%dx)
}
80106c53:	90                   	nop
80106c54:	c9                   	leave  
80106c55:	c3                   	ret    

80106c56 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c56:	55                   	push   %ebp
80106c57:	89 e5                	mov    %esp,%ebp
80106c59:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c5c:	6a 00                	push   $0x0
80106c5e:	68 fa 03 00 00       	push   $0x3fa
80106c63:	e8 cd ff ff ff       	call   80106c35 <outb>
80106c68:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c6b:	68 80 00 00 00       	push   $0x80
80106c70:	68 fb 03 00 00       	push   $0x3fb
80106c75:	e8 bb ff ff ff       	call   80106c35 <outb>
80106c7a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106c7d:	6a 0c                	push   $0xc
80106c7f:	68 f8 03 00 00       	push   $0x3f8
80106c84:	e8 ac ff ff ff       	call   80106c35 <outb>
80106c89:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106c8c:	6a 00                	push   $0x0
80106c8e:	68 f9 03 00 00       	push   $0x3f9
80106c93:	e8 9d ff ff ff       	call   80106c35 <outb>
80106c98:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c9b:	6a 03                	push   $0x3
80106c9d:	68 fb 03 00 00       	push   $0x3fb
80106ca2:	e8 8e ff ff ff       	call   80106c35 <outb>
80106ca7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106caa:	6a 00                	push   $0x0
80106cac:	68 fc 03 00 00       	push   $0x3fc
80106cb1:	e8 7f ff ff ff       	call   80106c35 <outb>
80106cb6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106cb9:	6a 01                	push   $0x1
80106cbb:	68 f9 03 00 00       	push   $0x3f9
80106cc0:	e8 70 ff ff ff       	call   80106c35 <outb>
80106cc5:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106cc8:	68 fd 03 00 00       	push   $0x3fd
80106ccd:	e8 46 ff ff ff       	call   80106c18 <inb>
80106cd2:	83 c4 04             	add    $0x4,%esp
80106cd5:	3c ff                	cmp    $0xff,%al
80106cd7:	74 61                	je     80106d3a <uartinit+0xe4>
    return;
  uart = 1;
80106cd9:	c7 05 b8 a2 11 80 01 	movl   $0x1,0x8011a2b8
80106ce0:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106ce3:	68 fa 03 00 00       	push   $0x3fa
80106ce8:	e8 2b ff ff ff       	call   80106c18 <inb>
80106ced:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106cf0:	68 f8 03 00 00       	push   $0x3f8
80106cf5:	e8 1e ff ff ff       	call   80106c18 <inb>
80106cfa:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106cfd:	83 ec 08             	sub    $0x8,%esp
80106d00:	6a 00                	push   $0x0
80106d02:	6a 04                	push   $0x4
80106d04:	e8 09 be ff ff       	call   80102b12 <ioapicenable>
80106d09:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d0c:	c7 45 f4 e4 af 10 80 	movl   $0x8010afe4,-0xc(%ebp)
80106d13:	eb 19                	jmp    80106d2e <uartinit+0xd8>
    uartputc(*p);
80106d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d18:	0f b6 00             	movzbl (%eax),%eax
80106d1b:	0f be c0             	movsbl %al,%eax
80106d1e:	83 ec 0c             	sub    $0xc,%esp
80106d21:	50                   	push   %eax
80106d22:	e8 16 00 00 00       	call   80106d3d <uartputc>
80106d27:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106d2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d31:	0f b6 00             	movzbl (%eax),%eax
80106d34:	84 c0                	test   %al,%al
80106d36:	75 dd                	jne    80106d15 <uartinit+0xbf>
80106d38:	eb 01                	jmp    80106d3b <uartinit+0xe5>
    return;
80106d3a:	90                   	nop
}
80106d3b:	c9                   	leave  
80106d3c:	c3                   	ret    

80106d3d <uartputc>:

void
uartputc(int c)
{
80106d3d:	55                   	push   %ebp
80106d3e:	89 e5                	mov    %esp,%ebp
80106d40:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106d43:	a1 b8 a2 11 80       	mov    0x8011a2b8,%eax
80106d48:	85 c0                	test   %eax,%eax
80106d4a:	74 53                	je     80106d9f <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d53:	eb 11                	jmp    80106d66 <uartputc+0x29>
    microdelay(10);
80106d55:	83 ec 0c             	sub    $0xc,%esp
80106d58:	6a 0a                	push   $0xa
80106d5a:	e8 bc c2 ff ff       	call   8010301b <microdelay>
80106d5f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d62:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d66:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d6a:	7f 1a                	jg     80106d86 <uartputc+0x49>
80106d6c:	83 ec 0c             	sub    $0xc,%esp
80106d6f:	68 fd 03 00 00       	push   $0x3fd
80106d74:	e8 9f fe ff ff       	call   80106c18 <inb>
80106d79:	83 c4 10             	add    $0x10,%esp
80106d7c:	0f b6 c0             	movzbl %al,%eax
80106d7f:	83 e0 20             	and    $0x20,%eax
80106d82:	85 c0                	test   %eax,%eax
80106d84:	74 cf                	je     80106d55 <uartputc+0x18>
  outb(COM1+0, c);
80106d86:	8b 45 08             	mov    0x8(%ebp),%eax
80106d89:	0f b6 c0             	movzbl %al,%eax
80106d8c:	83 ec 08             	sub    $0x8,%esp
80106d8f:	50                   	push   %eax
80106d90:	68 f8 03 00 00       	push   $0x3f8
80106d95:	e8 9b fe ff ff       	call   80106c35 <outb>
80106d9a:	83 c4 10             	add    $0x10,%esp
80106d9d:	eb 01                	jmp    80106da0 <uartputc+0x63>
    return;
80106d9f:	90                   	nop
}
80106da0:	c9                   	leave  
80106da1:	c3                   	ret    

80106da2 <uartgetc>:

static int
uartgetc(void)
{
80106da2:	55                   	push   %ebp
80106da3:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106da5:	a1 b8 a2 11 80       	mov    0x8011a2b8,%eax
80106daa:	85 c0                	test   %eax,%eax
80106dac:	75 07                	jne    80106db5 <uartgetc+0x13>
    return -1;
80106dae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106db3:	eb 2e                	jmp    80106de3 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106db5:	68 fd 03 00 00       	push   $0x3fd
80106dba:	e8 59 fe ff ff       	call   80106c18 <inb>
80106dbf:	83 c4 04             	add    $0x4,%esp
80106dc2:	0f b6 c0             	movzbl %al,%eax
80106dc5:	83 e0 01             	and    $0x1,%eax
80106dc8:	85 c0                	test   %eax,%eax
80106dca:	75 07                	jne    80106dd3 <uartgetc+0x31>
    return -1;
80106dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dd1:	eb 10                	jmp    80106de3 <uartgetc+0x41>
  return inb(COM1+0);
80106dd3:	68 f8 03 00 00       	push   $0x3f8
80106dd8:	e8 3b fe ff ff       	call   80106c18 <inb>
80106ddd:	83 c4 04             	add    $0x4,%esp
80106de0:	0f b6 c0             	movzbl %al,%eax
}
80106de3:	c9                   	leave  
80106de4:	c3                   	ret    

80106de5 <uartintr>:

void
uartintr(void)
{
80106de5:	55                   	push   %ebp
80106de6:	89 e5                	mov    %esp,%ebp
80106de8:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106deb:	83 ec 0c             	sub    $0xc,%esp
80106dee:	68 a2 6d 10 80       	push   $0x80106da2
80106df3:	e8 de 99 ff ff       	call   801007d6 <consoleintr>
80106df8:	83 c4 10             	add    $0x10,%esp
}
80106dfb:	90                   	nop
80106dfc:	c9                   	leave  
80106dfd:	c3                   	ret    

80106dfe <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $0
80106e00:	6a 00                	push   $0x0
  jmp alltraps
80106e02:	e9 e1 f8 ff ff       	jmp    801066e8 <alltraps>

80106e07 <vector1>:
.globl vector1
vector1:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $1
80106e09:	6a 01                	push   $0x1
  jmp alltraps
80106e0b:	e9 d8 f8 ff ff       	jmp    801066e8 <alltraps>

80106e10 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $2
80106e12:	6a 02                	push   $0x2
  jmp alltraps
80106e14:	e9 cf f8 ff ff       	jmp    801066e8 <alltraps>

80106e19 <vector3>:
.globl vector3
vector3:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $3
80106e1b:	6a 03                	push   $0x3
  jmp alltraps
80106e1d:	e9 c6 f8 ff ff       	jmp    801066e8 <alltraps>

80106e22 <vector4>:
.globl vector4
vector4:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $4
80106e24:	6a 04                	push   $0x4
  jmp alltraps
80106e26:	e9 bd f8 ff ff       	jmp    801066e8 <alltraps>

80106e2b <vector5>:
.globl vector5
vector5:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $5
80106e2d:	6a 05                	push   $0x5
  jmp alltraps
80106e2f:	e9 b4 f8 ff ff       	jmp    801066e8 <alltraps>

80106e34 <vector6>:
.globl vector6
vector6:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $6
80106e36:	6a 06                	push   $0x6
  jmp alltraps
80106e38:	e9 ab f8 ff ff       	jmp    801066e8 <alltraps>

80106e3d <vector7>:
.globl vector7
vector7:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $7
80106e3f:	6a 07                	push   $0x7
  jmp alltraps
80106e41:	e9 a2 f8 ff ff       	jmp    801066e8 <alltraps>

80106e46 <vector8>:
.globl vector8
vector8:
  pushl $8
80106e46:	6a 08                	push   $0x8
  jmp alltraps
80106e48:	e9 9b f8 ff ff       	jmp    801066e8 <alltraps>

80106e4d <vector9>:
.globl vector9
vector9:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $9
80106e4f:	6a 09                	push   $0x9
  jmp alltraps
80106e51:	e9 92 f8 ff ff       	jmp    801066e8 <alltraps>

80106e56 <vector10>:
.globl vector10
vector10:
  pushl $10
80106e56:	6a 0a                	push   $0xa
  jmp alltraps
80106e58:	e9 8b f8 ff ff       	jmp    801066e8 <alltraps>

80106e5d <vector11>:
.globl vector11
vector11:
  pushl $11
80106e5d:	6a 0b                	push   $0xb
  jmp alltraps
80106e5f:	e9 84 f8 ff ff       	jmp    801066e8 <alltraps>

80106e64 <vector12>:
.globl vector12
vector12:
  pushl $12
80106e64:	6a 0c                	push   $0xc
  jmp alltraps
80106e66:	e9 7d f8 ff ff       	jmp    801066e8 <alltraps>

80106e6b <vector13>:
.globl vector13
vector13:
  pushl $13
80106e6b:	6a 0d                	push   $0xd
  jmp alltraps
80106e6d:	e9 76 f8 ff ff       	jmp    801066e8 <alltraps>

80106e72 <vector14>:
.globl vector14
vector14:
  pushl $14
80106e72:	6a 0e                	push   $0xe
  jmp alltraps
80106e74:	e9 6f f8 ff ff       	jmp    801066e8 <alltraps>

80106e79 <vector15>:
.globl vector15
vector15:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $15
80106e7b:	6a 0f                	push   $0xf
  jmp alltraps
80106e7d:	e9 66 f8 ff ff       	jmp    801066e8 <alltraps>

80106e82 <vector16>:
.globl vector16
vector16:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $16
80106e84:	6a 10                	push   $0x10
  jmp alltraps
80106e86:	e9 5d f8 ff ff       	jmp    801066e8 <alltraps>

80106e8b <vector17>:
.globl vector17
vector17:
  pushl $17
80106e8b:	6a 11                	push   $0x11
  jmp alltraps
80106e8d:	e9 56 f8 ff ff       	jmp    801066e8 <alltraps>

80106e92 <vector18>:
.globl vector18
vector18:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $18
80106e94:	6a 12                	push   $0x12
  jmp alltraps
80106e96:	e9 4d f8 ff ff       	jmp    801066e8 <alltraps>

80106e9b <vector19>:
.globl vector19
vector19:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $19
80106e9d:	6a 13                	push   $0x13
  jmp alltraps
80106e9f:	e9 44 f8 ff ff       	jmp    801066e8 <alltraps>

80106ea4 <vector20>:
.globl vector20
vector20:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $20
80106ea6:	6a 14                	push   $0x14
  jmp alltraps
80106ea8:	e9 3b f8 ff ff       	jmp    801066e8 <alltraps>

80106ead <vector21>:
.globl vector21
vector21:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $21
80106eaf:	6a 15                	push   $0x15
  jmp alltraps
80106eb1:	e9 32 f8 ff ff       	jmp    801066e8 <alltraps>

80106eb6 <vector22>:
.globl vector22
vector22:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $22
80106eb8:	6a 16                	push   $0x16
  jmp alltraps
80106eba:	e9 29 f8 ff ff       	jmp    801066e8 <alltraps>

80106ebf <vector23>:
.globl vector23
vector23:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $23
80106ec1:	6a 17                	push   $0x17
  jmp alltraps
80106ec3:	e9 20 f8 ff ff       	jmp    801066e8 <alltraps>

80106ec8 <vector24>:
.globl vector24
vector24:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $24
80106eca:	6a 18                	push   $0x18
  jmp alltraps
80106ecc:	e9 17 f8 ff ff       	jmp    801066e8 <alltraps>

80106ed1 <vector25>:
.globl vector25
vector25:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $25
80106ed3:	6a 19                	push   $0x19
  jmp alltraps
80106ed5:	e9 0e f8 ff ff       	jmp    801066e8 <alltraps>

80106eda <vector26>:
.globl vector26
vector26:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $26
80106edc:	6a 1a                	push   $0x1a
  jmp alltraps
80106ede:	e9 05 f8 ff ff       	jmp    801066e8 <alltraps>

80106ee3 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $27
80106ee5:	6a 1b                	push   $0x1b
  jmp alltraps
80106ee7:	e9 fc f7 ff ff       	jmp    801066e8 <alltraps>

80106eec <vector28>:
.globl vector28
vector28:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $28
80106eee:	6a 1c                	push   $0x1c
  jmp alltraps
80106ef0:	e9 f3 f7 ff ff       	jmp    801066e8 <alltraps>

80106ef5 <vector29>:
.globl vector29
vector29:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $29
80106ef7:	6a 1d                	push   $0x1d
  jmp alltraps
80106ef9:	e9 ea f7 ff ff       	jmp    801066e8 <alltraps>

80106efe <vector30>:
.globl vector30
vector30:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $30
80106f00:	6a 1e                	push   $0x1e
  jmp alltraps
80106f02:	e9 e1 f7 ff ff       	jmp    801066e8 <alltraps>

80106f07 <vector31>:
.globl vector31
vector31:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $31
80106f09:	6a 1f                	push   $0x1f
  jmp alltraps
80106f0b:	e9 d8 f7 ff ff       	jmp    801066e8 <alltraps>

80106f10 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $32
80106f12:	6a 20                	push   $0x20
  jmp alltraps
80106f14:	e9 cf f7 ff ff       	jmp    801066e8 <alltraps>

80106f19 <vector33>:
.globl vector33
vector33:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $33
80106f1b:	6a 21                	push   $0x21
  jmp alltraps
80106f1d:	e9 c6 f7 ff ff       	jmp    801066e8 <alltraps>

80106f22 <vector34>:
.globl vector34
vector34:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $34
80106f24:	6a 22                	push   $0x22
  jmp alltraps
80106f26:	e9 bd f7 ff ff       	jmp    801066e8 <alltraps>

80106f2b <vector35>:
.globl vector35
vector35:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $35
80106f2d:	6a 23                	push   $0x23
  jmp alltraps
80106f2f:	e9 b4 f7 ff ff       	jmp    801066e8 <alltraps>

80106f34 <vector36>:
.globl vector36
vector36:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $36
80106f36:	6a 24                	push   $0x24
  jmp alltraps
80106f38:	e9 ab f7 ff ff       	jmp    801066e8 <alltraps>

80106f3d <vector37>:
.globl vector37
vector37:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $37
80106f3f:	6a 25                	push   $0x25
  jmp alltraps
80106f41:	e9 a2 f7 ff ff       	jmp    801066e8 <alltraps>

80106f46 <vector38>:
.globl vector38
vector38:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $38
80106f48:	6a 26                	push   $0x26
  jmp alltraps
80106f4a:	e9 99 f7 ff ff       	jmp    801066e8 <alltraps>

80106f4f <vector39>:
.globl vector39
vector39:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $39
80106f51:	6a 27                	push   $0x27
  jmp alltraps
80106f53:	e9 90 f7 ff ff       	jmp    801066e8 <alltraps>

80106f58 <vector40>:
.globl vector40
vector40:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $40
80106f5a:	6a 28                	push   $0x28
  jmp alltraps
80106f5c:	e9 87 f7 ff ff       	jmp    801066e8 <alltraps>

80106f61 <vector41>:
.globl vector41
vector41:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $41
80106f63:	6a 29                	push   $0x29
  jmp alltraps
80106f65:	e9 7e f7 ff ff       	jmp    801066e8 <alltraps>

80106f6a <vector42>:
.globl vector42
vector42:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $42
80106f6c:	6a 2a                	push   $0x2a
  jmp alltraps
80106f6e:	e9 75 f7 ff ff       	jmp    801066e8 <alltraps>

80106f73 <vector43>:
.globl vector43
vector43:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $43
80106f75:	6a 2b                	push   $0x2b
  jmp alltraps
80106f77:	e9 6c f7 ff ff       	jmp    801066e8 <alltraps>

80106f7c <vector44>:
.globl vector44
vector44:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $44
80106f7e:	6a 2c                	push   $0x2c
  jmp alltraps
80106f80:	e9 63 f7 ff ff       	jmp    801066e8 <alltraps>

80106f85 <vector45>:
.globl vector45
vector45:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $45
80106f87:	6a 2d                	push   $0x2d
  jmp alltraps
80106f89:	e9 5a f7 ff ff       	jmp    801066e8 <alltraps>

80106f8e <vector46>:
.globl vector46
vector46:
  pushl $0
80106f8e:	6a 00                	push   $0x0
  pushl $46
80106f90:	6a 2e                	push   $0x2e
  jmp alltraps
80106f92:	e9 51 f7 ff ff       	jmp    801066e8 <alltraps>

80106f97 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $47
80106f99:	6a 2f                	push   $0x2f
  jmp alltraps
80106f9b:	e9 48 f7 ff ff       	jmp    801066e8 <alltraps>

80106fa0 <vector48>:
.globl vector48
vector48:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $48
80106fa2:	6a 30                	push   $0x30
  jmp alltraps
80106fa4:	e9 3f f7 ff ff       	jmp    801066e8 <alltraps>

80106fa9 <vector49>:
.globl vector49
vector49:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $49
80106fab:	6a 31                	push   $0x31
  jmp alltraps
80106fad:	e9 36 f7 ff ff       	jmp    801066e8 <alltraps>

80106fb2 <vector50>:
.globl vector50
vector50:
  pushl $0
80106fb2:	6a 00                	push   $0x0
  pushl $50
80106fb4:	6a 32                	push   $0x32
  jmp alltraps
80106fb6:	e9 2d f7 ff ff       	jmp    801066e8 <alltraps>

80106fbb <vector51>:
.globl vector51
vector51:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $51
80106fbd:	6a 33                	push   $0x33
  jmp alltraps
80106fbf:	e9 24 f7 ff ff       	jmp    801066e8 <alltraps>

80106fc4 <vector52>:
.globl vector52
vector52:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $52
80106fc6:	6a 34                	push   $0x34
  jmp alltraps
80106fc8:	e9 1b f7 ff ff       	jmp    801066e8 <alltraps>

80106fcd <vector53>:
.globl vector53
vector53:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $53
80106fcf:	6a 35                	push   $0x35
  jmp alltraps
80106fd1:	e9 12 f7 ff ff       	jmp    801066e8 <alltraps>

80106fd6 <vector54>:
.globl vector54
vector54:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $54
80106fd8:	6a 36                	push   $0x36
  jmp alltraps
80106fda:	e9 09 f7 ff ff       	jmp    801066e8 <alltraps>

80106fdf <vector55>:
.globl vector55
vector55:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $55
80106fe1:	6a 37                	push   $0x37
  jmp alltraps
80106fe3:	e9 00 f7 ff ff       	jmp    801066e8 <alltraps>

80106fe8 <vector56>:
.globl vector56
vector56:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $56
80106fea:	6a 38                	push   $0x38
  jmp alltraps
80106fec:	e9 f7 f6 ff ff       	jmp    801066e8 <alltraps>

80106ff1 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $57
80106ff3:	6a 39                	push   $0x39
  jmp alltraps
80106ff5:	e9 ee f6 ff ff       	jmp    801066e8 <alltraps>

80106ffa <vector58>:
.globl vector58
vector58:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $58
80106ffc:	6a 3a                	push   $0x3a
  jmp alltraps
80106ffe:	e9 e5 f6 ff ff       	jmp    801066e8 <alltraps>

80107003 <vector59>:
.globl vector59
vector59:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $59
80107005:	6a 3b                	push   $0x3b
  jmp alltraps
80107007:	e9 dc f6 ff ff       	jmp    801066e8 <alltraps>

8010700c <vector60>:
.globl vector60
vector60:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $60
8010700e:	6a 3c                	push   $0x3c
  jmp alltraps
80107010:	e9 d3 f6 ff ff       	jmp    801066e8 <alltraps>

80107015 <vector61>:
.globl vector61
vector61:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $61
80107017:	6a 3d                	push   $0x3d
  jmp alltraps
80107019:	e9 ca f6 ff ff       	jmp    801066e8 <alltraps>

8010701e <vector62>:
.globl vector62
vector62:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $62
80107020:	6a 3e                	push   $0x3e
  jmp alltraps
80107022:	e9 c1 f6 ff ff       	jmp    801066e8 <alltraps>

80107027 <vector63>:
.globl vector63
vector63:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $63
80107029:	6a 3f                	push   $0x3f
  jmp alltraps
8010702b:	e9 b8 f6 ff ff       	jmp    801066e8 <alltraps>

80107030 <vector64>:
.globl vector64
vector64:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $64
80107032:	6a 40                	push   $0x40
  jmp alltraps
80107034:	e9 af f6 ff ff       	jmp    801066e8 <alltraps>

80107039 <vector65>:
.globl vector65
vector65:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $65
8010703b:	6a 41                	push   $0x41
  jmp alltraps
8010703d:	e9 a6 f6 ff ff       	jmp    801066e8 <alltraps>

80107042 <vector66>:
.globl vector66
vector66:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $66
80107044:	6a 42                	push   $0x42
  jmp alltraps
80107046:	e9 9d f6 ff ff       	jmp    801066e8 <alltraps>

8010704b <vector67>:
.globl vector67
vector67:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $67
8010704d:	6a 43                	push   $0x43
  jmp alltraps
8010704f:	e9 94 f6 ff ff       	jmp    801066e8 <alltraps>

80107054 <vector68>:
.globl vector68
vector68:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $68
80107056:	6a 44                	push   $0x44
  jmp alltraps
80107058:	e9 8b f6 ff ff       	jmp    801066e8 <alltraps>

8010705d <vector69>:
.globl vector69
vector69:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $69
8010705f:	6a 45                	push   $0x45
  jmp alltraps
80107061:	e9 82 f6 ff ff       	jmp    801066e8 <alltraps>

80107066 <vector70>:
.globl vector70
vector70:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $70
80107068:	6a 46                	push   $0x46
  jmp alltraps
8010706a:	e9 79 f6 ff ff       	jmp    801066e8 <alltraps>

8010706f <vector71>:
.globl vector71
vector71:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $71
80107071:	6a 47                	push   $0x47
  jmp alltraps
80107073:	e9 70 f6 ff ff       	jmp    801066e8 <alltraps>

80107078 <vector72>:
.globl vector72
vector72:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $72
8010707a:	6a 48                	push   $0x48
  jmp alltraps
8010707c:	e9 67 f6 ff ff       	jmp    801066e8 <alltraps>

80107081 <vector73>:
.globl vector73
vector73:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $73
80107083:	6a 49                	push   $0x49
  jmp alltraps
80107085:	e9 5e f6 ff ff       	jmp    801066e8 <alltraps>

8010708a <vector74>:
.globl vector74
vector74:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $74
8010708c:	6a 4a                	push   $0x4a
  jmp alltraps
8010708e:	e9 55 f6 ff ff       	jmp    801066e8 <alltraps>

80107093 <vector75>:
.globl vector75
vector75:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $75
80107095:	6a 4b                	push   $0x4b
  jmp alltraps
80107097:	e9 4c f6 ff ff       	jmp    801066e8 <alltraps>

8010709c <vector76>:
.globl vector76
vector76:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $76
8010709e:	6a 4c                	push   $0x4c
  jmp alltraps
801070a0:	e9 43 f6 ff ff       	jmp    801066e8 <alltraps>

801070a5 <vector77>:
.globl vector77
vector77:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $77
801070a7:	6a 4d                	push   $0x4d
  jmp alltraps
801070a9:	e9 3a f6 ff ff       	jmp    801066e8 <alltraps>

801070ae <vector78>:
.globl vector78
vector78:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $78
801070b0:	6a 4e                	push   $0x4e
  jmp alltraps
801070b2:	e9 31 f6 ff ff       	jmp    801066e8 <alltraps>

801070b7 <vector79>:
.globl vector79
vector79:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $79
801070b9:	6a 4f                	push   $0x4f
  jmp alltraps
801070bb:	e9 28 f6 ff ff       	jmp    801066e8 <alltraps>

801070c0 <vector80>:
.globl vector80
vector80:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $80
801070c2:	6a 50                	push   $0x50
  jmp alltraps
801070c4:	e9 1f f6 ff ff       	jmp    801066e8 <alltraps>

801070c9 <vector81>:
.globl vector81
vector81:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $81
801070cb:	6a 51                	push   $0x51
  jmp alltraps
801070cd:	e9 16 f6 ff ff       	jmp    801066e8 <alltraps>

801070d2 <vector82>:
.globl vector82
vector82:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $82
801070d4:	6a 52                	push   $0x52
  jmp alltraps
801070d6:	e9 0d f6 ff ff       	jmp    801066e8 <alltraps>

801070db <vector83>:
.globl vector83
vector83:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $83
801070dd:	6a 53                	push   $0x53
  jmp alltraps
801070df:	e9 04 f6 ff ff       	jmp    801066e8 <alltraps>

801070e4 <vector84>:
.globl vector84
vector84:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $84
801070e6:	6a 54                	push   $0x54
  jmp alltraps
801070e8:	e9 fb f5 ff ff       	jmp    801066e8 <alltraps>

801070ed <vector85>:
.globl vector85
vector85:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $85
801070ef:	6a 55                	push   $0x55
  jmp alltraps
801070f1:	e9 f2 f5 ff ff       	jmp    801066e8 <alltraps>

801070f6 <vector86>:
.globl vector86
vector86:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $86
801070f8:	6a 56                	push   $0x56
  jmp alltraps
801070fa:	e9 e9 f5 ff ff       	jmp    801066e8 <alltraps>

801070ff <vector87>:
.globl vector87
vector87:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $87
80107101:	6a 57                	push   $0x57
  jmp alltraps
80107103:	e9 e0 f5 ff ff       	jmp    801066e8 <alltraps>

80107108 <vector88>:
.globl vector88
vector88:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $88
8010710a:	6a 58                	push   $0x58
  jmp alltraps
8010710c:	e9 d7 f5 ff ff       	jmp    801066e8 <alltraps>

80107111 <vector89>:
.globl vector89
vector89:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $89
80107113:	6a 59                	push   $0x59
  jmp alltraps
80107115:	e9 ce f5 ff ff       	jmp    801066e8 <alltraps>

8010711a <vector90>:
.globl vector90
vector90:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $90
8010711c:	6a 5a                	push   $0x5a
  jmp alltraps
8010711e:	e9 c5 f5 ff ff       	jmp    801066e8 <alltraps>

80107123 <vector91>:
.globl vector91
vector91:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $91
80107125:	6a 5b                	push   $0x5b
  jmp alltraps
80107127:	e9 bc f5 ff ff       	jmp    801066e8 <alltraps>

8010712c <vector92>:
.globl vector92
vector92:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $92
8010712e:	6a 5c                	push   $0x5c
  jmp alltraps
80107130:	e9 b3 f5 ff ff       	jmp    801066e8 <alltraps>

80107135 <vector93>:
.globl vector93
vector93:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $93
80107137:	6a 5d                	push   $0x5d
  jmp alltraps
80107139:	e9 aa f5 ff ff       	jmp    801066e8 <alltraps>

8010713e <vector94>:
.globl vector94
vector94:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $94
80107140:	6a 5e                	push   $0x5e
  jmp alltraps
80107142:	e9 a1 f5 ff ff       	jmp    801066e8 <alltraps>

80107147 <vector95>:
.globl vector95
vector95:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $95
80107149:	6a 5f                	push   $0x5f
  jmp alltraps
8010714b:	e9 98 f5 ff ff       	jmp    801066e8 <alltraps>

80107150 <vector96>:
.globl vector96
vector96:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $96
80107152:	6a 60                	push   $0x60
  jmp alltraps
80107154:	e9 8f f5 ff ff       	jmp    801066e8 <alltraps>

80107159 <vector97>:
.globl vector97
vector97:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $97
8010715b:	6a 61                	push   $0x61
  jmp alltraps
8010715d:	e9 86 f5 ff ff       	jmp    801066e8 <alltraps>

80107162 <vector98>:
.globl vector98
vector98:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $98
80107164:	6a 62                	push   $0x62
  jmp alltraps
80107166:	e9 7d f5 ff ff       	jmp    801066e8 <alltraps>

8010716b <vector99>:
.globl vector99
vector99:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $99
8010716d:	6a 63                	push   $0x63
  jmp alltraps
8010716f:	e9 74 f5 ff ff       	jmp    801066e8 <alltraps>

80107174 <vector100>:
.globl vector100
vector100:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $100
80107176:	6a 64                	push   $0x64
  jmp alltraps
80107178:	e9 6b f5 ff ff       	jmp    801066e8 <alltraps>

8010717d <vector101>:
.globl vector101
vector101:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $101
8010717f:	6a 65                	push   $0x65
  jmp alltraps
80107181:	e9 62 f5 ff ff       	jmp    801066e8 <alltraps>

80107186 <vector102>:
.globl vector102
vector102:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $102
80107188:	6a 66                	push   $0x66
  jmp alltraps
8010718a:	e9 59 f5 ff ff       	jmp    801066e8 <alltraps>

8010718f <vector103>:
.globl vector103
vector103:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $103
80107191:	6a 67                	push   $0x67
  jmp alltraps
80107193:	e9 50 f5 ff ff       	jmp    801066e8 <alltraps>

80107198 <vector104>:
.globl vector104
vector104:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $104
8010719a:	6a 68                	push   $0x68
  jmp alltraps
8010719c:	e9 47 f5 ff ff       	jmp    801066e8 <alltraps>

801071a1 <vector105>:
.globl vector105
vector105:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $105
801071a3:	6a 69                	push   $0x69
  jmp alltraps
801071a5:	e9 3e f5 ff ff       	jmp    801066e8 <alltraps>

801071aa <vector106>:
.globl vector106
vector106:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $106
801071ac:	6a 6a                	push   $0x6a
  jmp alltraps
801071ae:	e9 35 f5 ff ff       	jmp    801066e8 <alltraps>

801071b3 <vector107>:
.globl vector107
vector107:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $107
801071b5:	6a 6b                	push   $0x6b
  jmp alltraps
801071b7:	e9 2c f5 ff ff       	jmp    801066e8 <alltraps>

801071bc <vector108>:
.globl vector108
vector108:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $108
801071be:	6a 6c                	push   $0x6c
  jmp alltraps
801071c0:	e9 23 f5 ff ff       	jmp    801066e8 <alltraps>

801071c5 <vector109>:
.globl vector109
vector109:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $109
801071c7:	6a 6d                	push   $0x6d
  jmp alltraps
801071c9:	e9 1a f5 ff ff       	jmp    801066e8 <alltraps>

801071ce <vector110>:
.globl vector110
vector110:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $110
801071d0:	6a 6e                	push   $0x6e
  jmp alltraps
801071d2:	e9 11 f5 ff ff       	jmp    801066e8 <alltraps>

801071d7 <vector111>:
.globl vector111
vector111:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $111
801071d9:	6a 6f                	push   $0x6f
  jmp alltraps
801071db:	e9 08 f5 ff ff       	jmp    801066e8 <alltraps>

801071e0 <vector112>:
.globl vector112
vector112:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $112
801071e2:	6a 70                	push   $0x70
  jmp alltraps
801071e4:	e9 ff f4 ff ff       	jmp    801066e8 <alltraps>

801071e9 <vector113>:
.globl vector113
vector113:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $113
801071eb:	6a 71                	push   $0x71
  jmp alltraps
801071ed:	e9 f6 f4 ff ff       	jmp    801066e8 <alltraps>

801071f2 <vector114>:
.globl vector114
vector114:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $114
801071f4:	6a 72                	push   $0x72
  jmp alltraps
801071f6:	e9 ed f4 ff ff       	jmp    801066e8 <alltraps>

801071fb <vector115>:
.globl vector115
vector115:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $115
801071fd:	6a 73                	push   $0x73
  jmp alltraps
801071ff:	e9 e4 f4 ff ff       	jmp    801066e8 <alltraps>

80107204 <vector116>:
.globl vector116
vector116:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $116
80107206:	6a 74                	push   $0x74
  jmp alltraps
80107208:	e9 db f4 ff ff       	jmp    801066e8 <alltraps>

8010720d <vector117>:
.globl vector117
vector117:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $117
8010720f:	6a 75                	push   $0x75
  jmp alltraps
80107211:	e9 d2 f4 ff ff       	jmp    801066e8 <alltraps>

80107216 <vector118>:
.globl vector118
vector118:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $118
80107218:	6a 76                	push   $0x76
  jmp alltraps
8010721a:	e9 c9 f4 ff ff       	jmp    801066e8 <alltraps>

8010721f <vector119>:
.globl vector119
vector119:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $119
80107221:	6a 77                	push   $0x77
  jmp alltraps
80107223:	e9 c0 f4 ff ff       	jmp    801066e8 <alltraps>

80107228 <vector120>:
.globl vector120
vector120:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $120
8010722a:	6a 78                	push   $0x78
  jmp alltraps
8010722c:	e9 b7 f4 ff ff       	jmp    801066e8 <alltraps>

80107231 <vector121>:
.globl vector121
vector121:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $121
80107233:	6a 79                	push   $0x79
  jmp alltraps
80107235:	e9 ae f4 ff ff       	jmp    801066e8 <alltraps>

8010723a <vector122>:
.globl vector122
vector122:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $122
8010723c:	6a 7a                	push   $0x7a
  jmp alltraps
8010723e:	e9 a5 f4 ff ff       	jmp    801066e8 <alltraps>

80107243 <vector123>:
.globl vector123
vector123:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $123
80107245:	6a 7b                	push   $0x7b
  jmp alltraps
80107247:	e9 9c f4 ff ff       	jmp    801066e8 <alltraps>

8010724c <vector124>:
.globl vector124
vector124:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $124
8010724e:	6a 7c                	push   $0x7c
  jmp alltraps
80107250:	e9 93 f4 ff ff       	jmp    801066e8 <alltraps>

80107255 <vector125>:
.globl vector125
vector125:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $125
80107257:	6a 7d                	push   $0x7d
  jmp alltraps
80107259:	e9 8a f4 ff ff       	jmp    801066e8 <alltraps>

8010725e <vector126>:
.globl vector126
vector126:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $126
80107260:	6a 7e                	push   $0x7e
  jmp alltraps
80107262:	e9 81 f4 ff ff       	jmp    801066e8 <alltraps>

80107267 <vector127>:
.globl vector127
vector127:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $127
80107269:	6a 7f                	push   $0x7f
  jmp alltraps
8010726b:	e9 78 f4 ff ff       	jmp    801066e8 <alltraps>

80107270 <vector128>:
.globl vector128
vector128:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $128
80107272:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107277:	e9 6c f4 ff ff       	jmp    801066e8 <alltraps>

8010727c <vector129>:
.globl vector129
vector129:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $129
8010727e:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107283:	e9 60 f4 ff ff       	jmp    801066e8 <alltraps>

80107288 <vector130>:
.globl vector130
vector130:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $130
8010728a:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010728f:	e9 54 f4 ff ff       	jmp    801066e8 <alltraps>

80107294 <vector131>:
.globl vector131
vector131:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $131
80107296:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010729b:	e9 48 f4 ff ff       	jmp    801066e8 <alltraps>

801072a0 <vector132>:
.globl vector132
vector132:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $132
801072a2:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801072a7:	e9 3c f4 ff ff       	jmp    801066e8 <alltraps>

801072ac <vector133>:
.globl vector133
vector133:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $133
801072ae:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801072b3:	e9 30 f4 ff ff       	jmp    801066e8 <alltraps>

801072b8 <vector134>:
.globl vector134
vector134:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $134
801072ba:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801072bf:	e9 24 f4 ff ff       	jmp    801066e8 <alltraps>

801072c4 <vector135>:
.globl vector135
vector135:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $135
801072c6:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801072cb:	e9 18 f4 ff ff       	jmp    801066e8 <alltraps>

801072d0 <vector136>:
.globl vector136
vector136:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $136
801072d2:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801072d7:	e9 0c f4 ff ff       	jmp    801066e8 <alltraps>

801072dc <vector137>:
.globl vector137
vector137:
  pushl $0
801072dc:	6a 00                	push   $0x0
  pushl $137
801072de:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072e3:	e9 00 f4 ff ff       	jmp    801066e8 <alltraps>

801072e8 <vector138>:
.globl vector138
vector138:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $138
801072ea:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801072ef:	e9 f4 f3 ff ff       	jmp    801066e8 <alltraps>

801072f4 <vector139>:
.globl vector139
vector139:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $139
801072f6:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072fb:	e9 e8 f3 ff ff       	jmp    801066e8 <alltraps>

80107300 <vector140>:
.globl vector140
vector140:
  pushl $0
80107300:	6a 00                	push   $0x0
  pushl $140
80107302:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107307:	e9 dc f3 ff ff       	jmp    801066e8 <alltraps>

8010730c <vector141>:
.globl vector141
vector141:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $141
8010730e:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107313:	e9 d0 f3 ff ff       	jmp    801066e8 <alltraps>

80107318 <vector142>:
.globl vector142
vector142:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $142
8010731a:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010731f:	e9 c4 f3 ff ff       	jmp    801066e8 <alltraps>

80107324 <vector143>:
.globl vector143
vector143:
  pushl $0
80107324:	6a 00                	push   $0x0
  pushl $143
80107326:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010732b:	e9 b8 f3 ff ff       	jmp    801066e8 <alltraps>

80107330 <vector144>:
.globl vector144
vector144:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $144
80107332:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107337:	e9 ac f3 ff ff       	jmp    801066e8 <alltraps>

8010733c <vector145>:
.globl vector145
vector145:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $145
8010733e:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107343:	e9 a0 f3 ff ff       	jmp    801066e8 <alltraps>

80107348 <vector146>:
.globl vector146
vector146:
  pushl $0
80107348:	6a 00                	push   $0x0
  pushl $146
8010734a:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010734f:	e9 94 f3 ff ff       	jmp    801066e8 <alltraps>

80107354 <vector147>:
.globl vector147
vector147:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $147
80107356:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010735b:	e9 88 f3 ff ff       	jmp    801066e8 <alltraps>

80107360 <vector148>:
.globl vector148
vector148:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $148
80107362:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107367:	e9 7c f3 ff ff       	jmp    801066e8 <alltraps>

8010736c <vector149>:
.globl vector149
vector149:
  pushl $0
8010736c:	6a 00                	push   $0x0
  pushl $149
8010736e:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107373:	e9 70 f3 ff ff       	jmp    801066e8 <alltraps>

80107378 <vector150>:
.globl vector150
vector150:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $150
8010737a:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010737f:	e9 64 f3 ff ff       	jmp    801066e8 <alltraps>

80107384 <vector151>:
.globl vector151
vector151:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $151
80107386:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010738b:	e9 58 f3 ff ff       	jmp    801066e8 <alltraps>

80107390 <vector152>:
.globl vector152
vector152:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $152
80107392:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107397:	e9 4c f3 ff ff       	jmp    801066e8 <alltraps>

8010739c <vector153>:
.globl vector153
vector153:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $153
8010739e:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801073a3:	e9 40 f3 ff ff       	jmp    801066e8 <alltraps>

801073a8 <vector154>:
.globl vector154
vector154:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $154
801073aa:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801073af:	e9 34 f3 ff ff       	jmp    801066e8 <alltraps>

801073b4 <vector155>:
.globl vector155
vector155:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $155
801073b6:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801073bb:	e9 28 f3 ff ff       	jmp    801066e8 <alltraps>

801073c0 <vector156>:
.globl vector156
vector156:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $156
801073c2:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801073c7:	e9 1c f3 ff ff       	jmp    801066e8 <alltraps>

801073cc <vector157>:
.globl vector157
vector157:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $157
801073ce:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801073d3:	e9 10 f3 ff ff       	jmp    801066e8 <alltraps>

801073d8 <vector158>:
.globl vector158
vector158:
  pushl $0
801073d8:	6a 00                	push   $0x0
  pushl $158
801073da:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801073df:	e9 04 f3 ff ff       	jmp    801066e8 <alltraps>

801073e4 <vector159>:
.globl vector159
vector159:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $159
801073e6:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801073eb:	e9 f8 f2 ff ff       	jmp    801066e8 <alltraps>

801073f0 <vector160>:
.globl vector160
vector160:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $160
801073f2:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073f7:	e9 ec f2 ff ff       	jmp    801066e8 <alltraps>

801073fc <vector161>:
.globl vector161
vector161:
  pushl $0
801073fc:	6a 00                	push   $0x0
  pushl $161
801073fe:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107403:	e9 e0 f2 ff ff       	jmp    801066e8 <alltraps>

80107408 <vector162>:
.globl vector162
vector162:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $162
8010740a:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010740f:	e9 d4 f2 ff ff       	jmp    801066e8 <alltraps>

80107414 <vector163>:
.globl vector163
vector163:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $163
80107416:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010741b:	e9 c8 f2 ff ff       	jmp    801066e8 <alltraps>

80107420 <vector164>:
.globl vector164
vector164:
  pushl $0
80107420:	6a 00                	push   $0x0
  pushl $164
80107422:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107427:	e9 bc f2 ff ff       	jmp    801066e8 <alltraps>

8010742c <vector165>:
.globl vector165
vector165:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $165
8010742e:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107433:	e9 b0 f2 ff ff       	jmp    801066e8 <alltraps>

80107438 <vector166>:
.globl vector166
vector166:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $166
8010743a:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010743f:	e9 a4 f2 ff ff       	jmp    801066e8 <alltraps>

80107444 <vector167>:
.globl vector167
vector167:
  pushl $0
80107444:	6a 00                	push   $0x0
  pushl $167
80107446:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010744b:	e9 98 f2 ff ff       	jmp    801066e8 <alltraps>

80107450 <vector168>:
.globl vector168
vector168:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $168
80107452:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107457:	e9 8c f2 ff ff       	jmp    801066e8 <alltraps>

8010745c <vector169>:
.globl vector169
vector169:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $169
8010745e:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107463:	e9 80 f2 ff ff       	jmp    801066e8 <alltraps>

80107468 <vector170>:
.globl vector170
vector170:
  pushl $0
80107468:	6a 00                	push   $0x0
  pushl $170
8010746a:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010746f:	e9 74 f2 ff ff       	jmp    801066e8 <alltraps>

80107474 <vector171>:
.globl vector171
vector171:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $171
80107476:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010747b:	e9 68 f2 ff ff       	jmp    801066e8 <alltraps>

80107480 <vector172>:
.globl vector172
vector172:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $172
80107482:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107487:	e9 5c f2 ff ff       	jmp    801066e8 <alltraps>

8010748c <vector173>:
.globl vector173
vector173:
  pushl $0
8010748c:	6a 00                	push   $0x0
  pushl $173
8010748e:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107493:	e9 50 f2 ff ff       	jmp    801066e8 <alltraps>

80107498 <vector174>:
.globl vector174
vector174:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $174
8010749a:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010749f:	e9 44 f2 ff ff       	jmp    801066e8 <alltraps>

801074a4 <vector175>:
.globl vector175
vector175:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $175
801074a6:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801074ab:	e9 38 f2 ff ff       	jmp    801066e8 <alltraps>

801074b0 <vector176>:
.globl vector176
vector176:
  pushl $0
801074b0:	6a 00                	push   $0x0
  pushl $176
801074b2:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801074b7:	e9 2c f2 ff ff       	jmp    801066e8 <alltraps>

801074bc <vector177>:
.globl vector177
vector177:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $177
801074be:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801074c3:	e9 20 f2 ff ff       	jmp    801066e8 <alltraps>

801074c8 <vector178>:
.globl vector178
vector178:
  pushl $0
801074c8:	6a 00                	push   $0x0
  pushl $178
801074ca:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801074cf:	e9 14 f2 ff ff       	jmp    801066e8 <alltraps>

801074d4 <vector179>:
.globl vector179
vector179:
  pushl $0
801074d4:	6a 00                	push   $0x0
  pushl $179
801074d6:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801074db:	e9 08 f2 ff ff       	jmp    801066e8 <alltraps>

801074e0 <vector180>:
.globl vector180
vector180:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $180
801074e2:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074e7:	e9 fc f1 ff ff       	jmp    801066e8 <alltraps>

801074ec <vector181>:
.globl vector181
vector181:
  pushl $0
801074ec:	6a 00                	push   $0x0
  pushl $181
801074ee:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801074f3:	e9 f0 f1 ff ff       	jmp    801066e8 <alltraps>

801074f8 <vector182>:
.globl vector182
vector182:
  pushl $0
801074f8:	6a 00                	push   $0x0
  pushl $182
801074fa:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801074ff:	e9 e4 f1 ff ff       	jmp    801066e8 <alltraps>

80107504 <vector183>:
.globl vector183
vector183:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $183
80107506:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010750b:	e9 d8 f1 ff ff       	jmp    801066e8 <alltraps>

80107510 <vector184>:
.globl vector184
vector184:
  pushl $0
80107510:	6a 00                	push   $0x0
  pushl $184
80107512:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107517:	e9 cc f1 ff ff       	jmp    801066e8 <alltraps>

8010751c <vector185>:
.globl vector185
vector185:
  pushl $0
8010751c:	6a 00                	push   $0x0
  pushl $185
8010751e:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107523:	e9 c0 f1 ff ff       	jmp    801066e8 <alltraps>

80107528 <vector186>:
.globl vector186
vector186:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $186
8010752a:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010752f:	e9 b4 f1 ff ff       	jmp    801066e8 <alltraps>

80107534 <vector187>:
.globl vector187
vector187:
  pushl $0
80107534:	6a 00                	push   $0x0
  pushl $187
80107536:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010753b:	e9 a8 f1 ff ff       	jmp    801066e8 <alltraps>

80107540 <vector188>:
.globl vector188
vector188:
  pushl $0
80107540:	6a 00                	push   $0x0
  pushl $188
80107542:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107547:	e9 9c f1 ff ff       	jmp    801066e8 <alltraps>

8010754c <vector189>:
.globl vector189
vector189:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $189
8010754e:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107553:	e9 90 f1 ff ff       	jmp    801066e8 <alltraps>

80107558 <vector190>:
.globl vector190
vector190:
  pushl $0
80107558:	6a 00                	push   $0x0
  pushl $190
8010755a:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010755f:	e9 84 f1 ff ff       	jmp    801066e8 <alltraps>

80107564 <vector191>:
.globl vector191
vector191:
  pushl $0
80107564:	6a 00                	push   $0x0
  pushl $191
80107566:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010756b:	e9 78 f1 ff ff       	jmp    801066e8 <alltraps>

80107570 <vector192>:
.globl vector192
vector192:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $192
80107572:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107577:	e9 6c f1 ff ff       	jmp    801066e8 <alltraps>

8010757c <vector193>:
.globl vector193
vector193:
  pushl $0
8010757c:	6a 00                	push   $0x0
  pushl $193
8010757e:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107583:	e9 60 f1 ff ff       	jmp    801066e8 <alltraps>

80107588 <vector194>:
.globl vector194
vector194:
  pushl $0
80107588:	6a 00                	push   $0x0
  pushl $194
8010758a:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010758f:	e9 54 f1 ff ff       	jmp    801066e8 <alltraps>

80107594 <vector195>:
.globl vector195
vector195:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $195
80107596:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010759b:	e9 48 f1 ff ff       	jmp    801066e8 <alltraps>

801075a0 <vector196>:
.globl vector196
vector196:
  pushl $0
801075a0:	6a 00                	push   $0x0
  pushl $196
801075a2:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801075a7:	e9 3c f1 ff ff       	jmp    801066e8 <alltraps>

801075ac <vector197>:
.globl vector197
vector197:
  pushl $0
801075ac:	6a 00                	push   $0x0
  pushl $197
801075ae:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801075b3:	e9 30 f1 ff ff       	jmp    801066e8 <alltraps>

801075b8 <vector198>:
.globl vector198
vector198:
  pushl $0
801075b8:	6a 00                	push   $0x0
  pushl $198
801075ba:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801075bf:	e9 24 f1 ff ff       	jmp    801066e8 <alltraps>

801075c4 <vector199>:
.globl vector199
vector199:
  pushl $0
801075c4:	6a 00                	push   $0x0
  pushl $199
801075c6:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801075cb:	e9 18 f1 ff ff       	jmp    801066e8 <alltraps>

801075d0 <vector200>:
.globl vector200
vector200:
  pushl $0
801075d0:	6a 00                	push   $0x0
  pushl $200
801075d2:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801075d7:	e9 0c f1 ff ff       	jmp    801066e8 <alltraps>

801075dc <vector201>:
.globl vector201
vector201:
  pushl $0
801075dc:	6a 00                	push   $0x0
  pushl $201
801075de:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075e3:	e9 00 f1 ff ff       	jmp    801066e8 <alltraps>

801075e8 <vector202>:
.globl vector202
vector202:
  pushl $0
801075e8:	6a 00                	push   $0x0
  pushl $202
801075ea:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801075ef:	e9 f4 f0 ff ff       	jmp    801066e8 <alltraps>

801075f4 <vector203>:
.globl vector203
vector203:
  pushl $0
801075f4:	6a 00                	push   $0x0
  pushl $203
801075f6:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075fb:	e9 e8 f0 ff ff       	jmp    801066e8 <alltraps>

80107600 <vector204>:
.globl vector204
vector204:
  pushl $0
80107600:	6a 00                	push   $0x0
  pushl $204
80107602:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107607:	e9 dc f0 ff ff       	jmp    801066e8 <alltraps>

8010760c <vector205>:
.globl vector205
vector205:
  pushl $0
8010760c:	6a 00                	push   $0x0
  pushl $205
8010760e:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107613:	e9 d0 f0 ff ff       	jmp    801066e8 <alltraps>

80107618 <vector206>:
.globl vector206
vector206:
  pushl $0
80107618:	6a 00                	push   $0x0
  pushl $206
8010761a:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010761f:	e9 c4 f0 ff ff       	jmp    801066e8 <alltraps>

80107624 <vector207>:
.globl vector207
vector207:
  pushl $0
80107624:	6a 00                	push   $0x0
  pushl $207
80107626:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010762b:	e9 b8 f0 ff ff       	jmp    801066e8 <alltraps>

80107630 <vector208>:
.globl vector208
vector208:
  pushl $0
80107630:	6a 00                	push   $0x0
  pushl $208
80107632:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107637:	e9 ac f0 ff ff       	jmp    801066e8 <alltraps>

8010763c <vector209>:
.globl vector209
vector209:
  pushl $0
8010763c:	6a 00                	push   $0x0
  pushl $209
8010763e:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107643:	e9 a0 f0 ff ff       	jmp    801066e8 <alltraps>

80107648 <vector210>:
.globl vector210
vector210:
  pushl $0
80107648:	6a 00                	push   $0x0
  pushl $210
8010764a:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010764f:	e9 94 f0 ff ff       	jmp    801066e8 <alltraps>

80107654 <vector211>:
.globl vector211
vector211:
  pushl $0
80107654:	6a 00                	push   $0x0
  pushl $211
80107656:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010765b:	e9 88 f0 ff ff       	jmp    801066e8 <alltraps>

80107660 <vector212>:
.globl vector212
vector212:
  pushl $0
80107660:	6a 00                	push   $0x0
  pushl $212
80107662:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107667:	e9 7c f0 ff ff       	jmp    801066e8 <alltraps>

8010766c <vector213>:
.globl vector213
vector213:
  pushl $0
8010766c:	6a 00                	push   $0x0
  pushl $213
8010766e:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107673:	e9 70 f0 ff ff       	jmp    801066e8 <alltraps>

80107678 <vector214>:
.globl vector214
vector214:
  pushl $0
80107678:	6a 00                	push   $0x0
  pushl $214
8010767a:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010767f:	e9 64 f0 ff ff       	jmp    801066e8 <alltraps>

80107684 <vector215>:
.globl vector215
vector215:
  pushl $0
80107684:	6a 00                	push   $0x0
  pushl $215
80107686:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010768b:	e9 58 f0 ff ff       	jmp    801066e8 <alltraps>

80107690 <vector216>:
.globl vector216
vector216:
  pushl $0
80107690:	6a 00                	push   $0x0
  pushl $216
80107692:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107697:	e9 4c f0 ff ff       	jmp    801066e8 <alltraps>

8010769c <vector217>:
.globl vector217
vector217:
  pushl $0
8010769c:	6a 00                	push   $0x0
  pushl $217
8010769e:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801076a3:	e9 40 f0 ff ff       	jmp    801066e8 <alltraps>

801076a8 <vector218>:
.globl vector218
vector218:
  pushl $0
801076a8:	6a 00                	push   $0x0
  pushl $218
801076aa:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801076af:	e9 34 f0 ff ff       	jmp    801066e8 <alltraps>

801076b4 <vector219>:
.globl vector219
vector219:
  pushl $0
801076b4:	6a 00                	push   $0x0
  pushl $219
801076b6:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801076bb:	e9 28 f0 ff ff       	jmp    801066e8 <alltraps>

801076c0 <vector220>:
.globl vector220
vector220:
  pushl $0
801076c0:	6a 00                	push   $0x0
  pushl $220
801076c2:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801076c7:	e9 1c f0 ff ff       	jmp    801066e8 <alltraps>

801076cc <vector221>:
.globl vector221
vector221:
  pushl $0
801076cc:	6a 00                	push   $0x0
  pushl $221
801076ce:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801076d3:	e9 10 f0 ff ff       	jmp    801066e8 <alltraps>

801076d8 <vector222>:
.globl vector222
vector222:
  pushl $0
801076d8:	6a 00                	push   $0x0
  pushl $222
801076da:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801076df:	e9 04 f0 ff ff       	jmp    801066e8 <alltraps>

801076e4 <vector223>:
.globl vector223
vector223:
  pushl $0
801076e4:	6a 00                	push   $0x0
  pushl $223
801076e6:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801076eb:	e9 f8 ef ff ff       	jmp    801066e8 <alltraps>

801076f0 <vector224>:
.globl vector224
vector224:
  pushl $0
801076f0:	6a 00                	push   $0x0
  pushl $224
801076f2:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076f7:	e9 ec ef ff ff       	jmp    801066e8 <alltraps>

801076fc <vector225>:
.globl vector225
vector225:
  pushl $0
801076fc:	6a 00                	push   $0x0
  pushl $225
801076fe:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107703:	e9 e0 ef ff ff       	jmp    801066e8 <alltraps>

80107708 <vector226>:
.globl vector226
vector226:
  pushl $0
80107708:	6a 00                	push   $0x0
  pushl $226
8010770a:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010770f:	e9 d4 ef ff ff       	jmp    801066e8 <alltraps>

80107714 <vector227>:
.globl vector227
vector227:
  pushl $0
80107714:	6a 00                	push   $0x0
  pushl $227
80107716:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010771b:	e9 c8 ef ff ff       	jmp    801066e8 <alltraps>

80107720 <vector228>:
.globl vector228
vector228:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $228
80107722:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107727:	e9 bc ef ff ff       	jmp    801066e8 <alltraps>

8010772c <vector229>:
.globl vector229
vector229:
  pushl $0
8010772c:	6a 00                	push   $0x0
  pushl $229
8010772e:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107733:	e9 b0 ef ff ff       	jmp    801066e8 <alltraps>

80107738 <vector230>:
.globl vector230
vector230:
  pushl $0
80107738:	6a 00                	push   $0x0
  pushl $230
8010773a:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010773f:	e9 a4 ef ff ff       	jmp    801066e8 <alltraps>

80107744 <vector231>:
.globl vector231
vector231:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $231
80107746:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010774b:	e9 98 ef ff ff       	jmp    801066e8 <alltraps>

80107750 <vector232>:
.globl vector232
vector232:
  pushl $0
80107750:	6a 00                	push   $0x0
  pushl $232
80107752:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107757:	e9 8c ef ff ff       	jmp    801066e8 <alltraps>

8010775c <vector233>:
.globl vector233
vector233:
  pushl $0
8010775c:	6a 00                	push   $0x0
  pushl $233
8010775e:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107763:	e9 80 ef ff ff       	jmp    801066e8 <alltraps>

80107768 <vector234>:
.globl vector234
vector234:
  pushl $0
80107768:	6a 00                	push   $0x0
  pushl $234
8010776a:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010776f:	e9 74 ef ff ff       	jmp    801066e8 <alltraps>

80107774 <vector235>:
.globl vector235
vector235:
  pushl $0
80107774:	6a 00                	push   $0x0
  pushl $235
80107776:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010777b:	e9 68 ef ff ff       	jmp    801066e8 <alltraps>

80107780 <vector236>:
.globl vector236
vector236:
  pushl $0
80107780:	6a 00                	push   $0x0
  pushl $236
80107782:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107787:	e9 5c ef ff ff       	jmp    801066e8 <alltraps>

8010778c <vector237>:
.globl vector237
vector237:
  pushl $0
8010778c:	6a 00                	push   $0x0
  pushl $237
8010778e:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107793:	e9 50 ef ff ff       	jmp    801066e8 <alltraps>

80107798 <vector238>:
.globl vector238
vector238:
  pushl $0
80107798:	6a 00                	push   $0x0
  pushl $238
8010779a:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010779f:	e9 44 ef ff ff       	jmp    801066e8 <alltraps>

801077a4 <vector239>:
.globl vector239
vector239:
  pushl $0
801077a4:	6a 00                	push   $0x0
  pushl $239
801077a6:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801077ab:	e9 38 ef ff ff       	jmp    801066e8 <alltraps>

801077b0 <vector240>:
.globl vector240
vector240:
  pushl $0
801077b0:	6a 00                	push   $0x0
  pushl $240
801077b2:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801077b7:	e9 2c ef ff ff       	jmp    801066e8 <alltraps>

801077bc <vector241>:
.globl vector241
vector241:
  pushl $0
801077bc:	6a 00                	push   $0x0
  pushl $241
801077be:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801077c3:	e9 20 ef ff ff       	jmp    801066e8 <alltraps>

801077c8 <vector242>:
.globl vector242
vector242:
  pushl $0
801077c8:	6a 00                	push   $0x0
  pushl $242
801077ca:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801077cf:	e9 14 ef ff ff       	jmp    801066e8 <alltraps>

801077d4 <vector243>:
.globl vector243
vector243:
  pushl $0
801077d4:	6a 00                	push   $0x0
  pushl $243
801077d6:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801077db:	e9 08 ef ff ff       	jmp    801066e8 <alltraps>

801077e0 <vector244>:
.globl vector244
vector244:
  pushl $0
801077e0:	6a 00                	push   $0x0
  pushl $244
801077e2:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077e7:	e9 fc ee ff ff       	jmp    801066e8 <alltraps>

801077ec <vector245>:
.globl vector245
vector245:
  pushl $0
801077ec:	6a 00                	push   $0x0
  pushl $245
801077ee:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801077f3:	e9 f0 ee ff ff       	jmp    801066e8 <alltraps>

801077f8 <vector246>:
.globl vector246
vector246:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $246
801077fa:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801077ff:	e9 e4 ee ff ff       	jmp    801066e8 <alltraps>

80107804 <vector247>:
.globl vector247
vector247:
  pushl $0
80107804:	6a 00                	push   $0x0
  pushl $247
80107806:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010780b:	e9 d8 ee ff ff       	jmp    801066e8 <alltraps>

80107810 <vector248>:
.globl vector248
vector248:
  pushl $0
80107810:	6a 00                	push   $0x0
  pushl $248
80107812:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107817:	e9 cc ee ff ff       	jmp    801066e8 <alltraps>

8010781c <vector249>:
.globl vector249
vector249:
  pushl $0
8010781c:	6a 00                	push   $0x0
  pushl $249
8010781e:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107823:	e9 c0 ee ff ff       	jmp    801066e8 <alltraps>

80107828 <vector250>:
.globl vector250
vector250:
  pushl $0
80107828:	6a 00                	push   $0x0
  pushl $250
8010782a:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010782f:	e9 b4 ee ff ff       	jmp    801066e8 <alltraps>

80107834 <vector251>:
.globl vector251
vector251:
  pushl $0
80107834:	6a 00                	push   $0x0
  pushl $251
80107836:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010783b:	e9 a8 ee ff ff       	jmp    801066e8 <alltraps>

80107840 <vector252>:
.globl vector252
vector252:
  pushl $0
80107840:	6a 00                	push   $0x0
  pushl $252
80107842:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107847:	e9 9c ee ff ff       	jmp    801066e8 <alltraps>

8010784c <vector253>:
.globl vector253
vector253:
  pushl $0
8010784c:	6a 00                	push   $0x0
  pushl $253
8010784e:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107853:	e9 90 ee ff ff       	jmp    801066e8 <alltraps>

80107858 <vector254>:
.globl vector254
vector254:
  pushl $0
80107858:	6a 00                	push   $0x0
  pushl $254
8010785a:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010785f:	e9 84 ee ff ff       	jmp    801066e8 <alltraps>

80107864 <vector255>:
.globl vector255
vector255:
  pushl $0
80107864:	6a 00                	push   $0x0
  pushl $255
80107866:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010786b:	e9 78 ee ff ff       	jmp    801066e8 <alltraps>

80107870 <lgdt>:
{
80107870:	55                   	push   %ebp
80107871:	89 e5                	mov    %esp,%ebp
80107873:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107876:	8b 45 0c             	mov    0xc(%ebp),%eax
80107879:	83 e8 01             	sub    $0x1,%eax
8010787c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107880:	8b 45 08             	mov    0x8(%ebp),%eax
80107883:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107887:	8b 45 08             	mov    0x8(%ebp),%eax
8010788a:	c1 e8 10             	shr    $0x10,%eax
8010788d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107891:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107894:	0f 01 10             	lgdtl  (%eax)
}
80107897:	90                   	nop
80107898:	c9                   	leave  
80107899:	c3                   	ret    

8010789a <ltr>:
{
8010789a:	55                   	push   %ebp
8010789b:	89 e5                	mov    %esp,%ebp
8010789d:	83 ec 04             	sub    $0x4,%esp
801078a0:	8b 45 08             	mov    0x8(%ebp),%eax
801078a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801078a7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078ab:	0f 00 d8             	ltr    %ax
}
801078ae:	90                   	nop
801078af:	c9                   	leave  
801078b0:	c3                   	ret    

801078b1 <lcr3>:

static inline void
lcr3(uint val)
{
801078b1:	55                   	push   %ebp
801078b2:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801078b4:	8b 45 08             	mov    0x8(%ebp),%eax
801078b7:	0f 22 d8             	mov    %eax,%cr3
}
801078ba:	90                   	nop
801078bb:	5d                   	pop    %ebp
801078bc:	c3                   	ret    

801078bd <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801078bd:	55                   	push   %ebp
801078be:	89 e5                	mov    %esp,%ebp
801078c0:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801078c3:	e8 b9 c5 ff ff       	call   80103e81 <cpuid>
801078c8:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801078ce:	05 c0 a2 11 80       	add    $0x8011a2c0,%eax
801078d3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801078d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d9:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801078df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e2:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801078e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078eb:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801078ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f2:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078f6:	83 e2 f0             	and    $0xfffffff0,%edx
801078f9:	83 ca 0a             	or     $0xa,%edx
801078fc:	88 50 7d             	mov    %dl,0x7d(%eax)
801078ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107902:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107906:	83 ca 10             	or     $0x10,%edx
80107909:	88 50 7d             	mov    %dl,0x7d(%eax)
8010790c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107913:	83 e2 9f             	and    $0xffffff9f,%edx
80107916:	88 50 7d             	mov    %dl,0x7d(%eax)
80107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107920:	83 ca 80             	or     $0xffffff80,%edx
80107923:	88 50 7d             	mov    %dl,0x7d(%eax)
80107926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107929:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010792d:	83 ca 0f             	or     $0xf,%edx
80107930:	88 50 7e             	mov    %dl,0x7e(%eax)
80107933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107936:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010793a:	83 e2 ef             	and    $0xffffffef,%edx
8010793d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107943:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107947:	83 e2 df             	and    $0xffffffdf,%edx
8010794a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010794d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107950:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107954:	83 ca 40             	or     $0x40,%edx
80107957:	88 50 7e             	mov    %dl,0x7e(%eax)
8010795a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107961:	83 ca 80             	or     $0xffffff80,%edx
80107964:	88 50 7e             	mov    %dl,0x7e(%eax)
80107967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796a:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010796e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107971:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107978:	ff ff 
8010797a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797d:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107984:	00 00 
80107986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107989:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107993:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010799a:	83 e2 f0             	and    $0xfffffff0,%edx
8010799d:	83 ca 02             	or     $0x2,%edx
801079a0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079b0:	83 ca 10             	or     $0x10,%edx
801079b3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079c3:	83 e2 9f             	and    $0xffffff9f,%edx
801079c6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cf:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079d6:	83 ca 80             	or     $0xffffff80,%edx
801079d9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079e9:	83 ca 0f             	or     $0xf,%edx
801079ec:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079fc:	83 e2 ef             	and    $0xffffffef,%edx
801079ff:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a08:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a0f:	83 e2 df             	and    $0xffffffdf,%edx
80107a12:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a22:	83 ca 40             	or     $0x40,%edx
80107a25:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a35:	83 ca 80             	or     $0xffffff80,%edx
80107a38:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a41:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4b:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107a52:	ff ff 
80107a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a57:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107a5e:	00 00 
80107a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a63:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a74:	83 e2 f0             	and    $0xfffffff0,%edx
80107a77:	83 ca 0a             	or     $0xa,%edx
80107a7a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a83:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a8a:	83 ca 10             	or     $0x10,%edx
80107a8d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a96:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a9d:	83 ca 60             	or     $0x60,%edx
80107aa0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ab0:	83 ca 80             	or     $0xffffff80,%edx
80107ab3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ac3:	83 ca 0f             	or     $0xf,%edx
80107ac6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acf:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ad6:	83 e2 ef             	and    $0xffffffef,%edx
80107ad9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ae9:	83 e2 df             	and    $0xffffffdf,%edx
80107aec:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107afc:	83 ca 40             	or     $0x40,%edx
80107aff:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b08:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b0f:	83 ca 80             	or     $0xffffff80,%edx
80107b12:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1b:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b25:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107b2c:	ff ff 
80107b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b31:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107b38:	00 00 
80107b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3d:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b47:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b4e:	83 e2 f0             	and    $0xfffffff0,%edx
80107b51:	83 ca 02             	or     $0x2,%edx
80107b54:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b64:	83 ca 10             	or     $0x10,%edx
80107b67:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b70:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b77:	83 ca 60             	or     $0x60,%edx
80107b7a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b83:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b8a:	83 ca 80             	or     $0xffffff80,%edx
80107b8d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b96:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b9d:	83 ca 0f             	or     $0xf,%edx
80107ba0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bb0:	83 e2 ef             	and    $0xffffffef,%edx
80107bb3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bc3:	83 e2 df             	and    $0xffffffdf,%edx
80107bc6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bd6:	83 ca 40             	or     $0x40,%edx
80107bd9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107be9:	83 ca 80             	or     $0xffffff80,%edx
80107bec:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf5:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bff:	83 c0 70             	add    $0x70,%eax
80107c02:	83 ec 08             	sub    $0x8,%esp
80107c05:	6a 30                	push   $0x30
80107c07:	50                   	push   %eax
80107c08:	e8 63 fc ff ff       	call   80107870 <lgdt>
80107c0d:	83 c4 10             	add    $0x10,%esp
}
80107c10:	90                   	nop
80107c11:	c9                   	leave  
80107c12:	c3                   	ret    

80107c13 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c13:	55                   	push   %ebp
80107c14:	89 e5                	mov    %esp,%ebp
80107c16:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c19:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c1c:	c1 e8 16             	shr    $0x16,%eax
80107c1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c26:	8b 45 08             	mov    0x8(%ebp),%eax
80107c29:	01 d0                	add    %edx,%eax
80107c2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107c2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c31:	8b 00                	mov    (%eax),%eax
80107c33:	83 e0 01             	and    $0x1,%eax
80107c36:	85 c0                	test   %eax,%eax
80107c38:	74 14                	je     80107c4e <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c3d:	8b 00                	mov    (%eax),%eax
80107c3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c44:	05 00 00 00 80       	add    $0x80000000,%eax
80107c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c4c:	eb 42                	jmp    80107c90 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107c4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107c52:	74 0e                	je     80107c62 <walkpgdir+0x4f>
80107c54:	e8 2b b0 ff ff       	call   80102c84 <kalloc>
80107c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c60:	75 07                	jne    80107c69 <walkpgdir+0x56>
      return 0;
80107c62:	b8 00 00 00 00       	mov    $0x0,%eax
80107c67:	eb 3e                	jmp    80107ca7 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c69:	83 ec 04             	sub    $0x4,%esp
80107c6c:	68 00 10 00 00       	push   $0x1000
80107c71:	6a 00                	push   $0x0
80107c73:	ff 75 f4             	push   -0xc(%ebp)
80107c76:	e8 7f d6 ff ff       	call   801052fa <memset>
80107c7b:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c81:	05 00 00 00 80       	add    $0x80000000,%eax
80107c86:	83 c8 07             	or     $0x7,%eax
80107c89:	89 c2                	mov    %eax,%edx
80107c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c8e:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107c90:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c93:	c1 e8 0c             	shr    $0xc,%eax
80107c96:	25 ff 03 00 00       	and    $0x3ff,%eax
80107c9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca5:	01 d0                	add    %edx,%eax
}
80107ca7:	c9                   	leave  
80107ca8:	c3                   	ret    

80107ca9 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107ca9:	55                   	push   %ebp
80107caa:	89 e5                	mov    %esp,%ebp
80107cac:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107caf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cb2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107cba:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cbd:	8b 45 10             	mov    0x10(%ebp),%eax
80107cc0:	01 d0                	add    %edx,%eax
80107cc2:	83 e8 01             	sub    $0x1,%eax
80107cc5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ccd:	83 ec 04             	sub    $0x4,%esp
80107cd0:	6a 01                	push   $0x1
80107cd2:	ff 75 f4             	push   -0xc(%ebp)
80107cd5:	ff 75 08             	push   0x8(%ebp)
80107cd8:	e8 36 ff ff ff       	call   80107c13 <walkpgdir>
80107cdd:	83 c4 10             	add    $0x10,%esp
80107ce0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ce3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ce7:	75 07                	jne    80107cf0 <mappages+0x47>
      return -1;
80107ce9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cee:	eb 47                	jmp    80107d37 <mappages+0x8e>
    if(*pte & PTE_P)
80107cf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cf3:	8b 00                	mov    (%eax),%eax
80107cf5:	83 e0 01             	and    $0x1,%eax
80107cf8:	85 c0                	test   %eax,%eax
80107cfa:	74 0d                	je     80107d09 <mappages+0x60>
      panic("remap");
80107cfc:	83 ec 0c             	sub    $0xc,%esp
80107cff:	68 ec af 10 80       	push   $0x8010afec
80107d04:	e8 a0 88 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107d09:	8b 45 18             	mov    0x18(%ebp),%eax
80107d0c:	0b 45 14             	or     0x14(%ebp),%eax
80107d0f:	83 c8 01             	or     $0x1,%eax
80107d12:	89 c2                	mov    %eax,%edx
80107d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d17:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d1f:	74 10                	je     80107d31 <mappages+0x88>
      break;
    a += PGSIZE;
80107d21:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107d28:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d2f:	eb 9c                	jmp    80107ccd <mappages+0x24>
      break;
80107d31:	90                   	nop
  }
  return 0;
80107d32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d37:	c9                   	leave  
80107d38:	c3                   	ret    

80107d39 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107d39:	55                   	push   %ebp
80107d3a:	89 e5                	mov    %esp,%ebp
80107d3c:	53                   	push   %ebx
80107d3d:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107d40:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107d47:	8b 15 a0 a5 11 80    	mov    0x8011a5a0,%edx
80107d4d:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107d52:	29 d0                	sub    %edx,%eax
80107d54:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107d57:	a1 98 a5 11 80       	mov    0x8011a598,%eax
80107d5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107d5f:	8b 15 98 a5 11 80    	mov    0x8011a598,%edx
80107d65:	a1 a0 a5 11 80       	mov    0x8011a5a0,%eax
80107d6a:	01 d0                	add    %edx,%eax
80107d6c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107d6f:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d79:	83 c0 30             	add    $0x30,%eax
80107d7c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107d7f:	89 10                	mov    %edx,(%eax)
80107d81:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107d84:	89 50 04             	mov    %edx,0x4(%eax)
80107d87:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107d8a:	89 50 08             	mov    %edx,0x8(%eax)
80107d8d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107d90:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107d93:	e8 ec ae ff ff       	call   80102c84 <kalloc>
80107d98:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d9f:	75 07                	jne    80107da8 <setupkvm+0x6f>
    return 0;
80107da1:	b8 00 00 00 00       	mov    $0x0,%eax
80107da6:	eb 78                	jmp    80107e20 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107da8:	83 ec 04             	sub    $0x4,%esp
80107dab:	68 00 10 00 00       	push   $0x1000
80107db0:	6a 00                	push   $0x0
80107db2:	ff 75 f0             	push   -0x10(%ebp)
80107db5:	e8 40 d5 ff ff       	call   801052fa <memset>
80107dba:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107dbd:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107dc4:	eb 4e                	jmp    80107e14 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc9:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcf:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd5:	8b 58 08             	mov    0x8(%eax),%ebx
80107dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddb:	8b 40 04             	mov    0x4(%eax),%eax
80107dde:	29 c3                	sub    %eax,%ebx
80107de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de3:	8b 00                	mov    (%eax),%eax
80107de5:	83 ec 0c             	sub    $0xc,%esp
80107de8:	51                   	push   %ecx
80107de9:	52                   	push   %edx
80107dea:	53                   	push   %ebx
80107deb:	50                   	push   %eax
80107dec:	ff 75 f0             	push   -0x10(%ebp)
80107def:	e8 b5 fe ff ff       	call   80107ca9 <mappages>
80107df4:	83 c4 20             	add    $0x20,%esp
80107df7:	85 c0                	test   %eax,%eax
80107df9:	79 15                	jns    80107e10 <setupkvm+0xd7>
      freevm(pgdir);
80107dfb:	83 ec 0c             	sub    $0xc,%esp
80107dfe:	ff 75 f0             	push   -0x10(%ebp)
80107e01:	e8 f5 04 00 00       	call   801082fb <freevm>
80107e06:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e09:	b8 00 00 00 00       	mov    $0x0,%eax
80107e0e:	eb 10                	jmp    80107e20 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e10:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e14:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107e1b:	72 a9                	jb     80107dc6 <setupkvm+0x8d>
    }
  return pgdir;
80107e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107e23:	c9                   	leave  
80107e24:	c3                   	ret    

80107e25 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107e25:	55                   	push   %ebp
80107e26:	89 e5                	mov    %esp,%ebp
80107e28:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107e2b:	e8 09 ff ff ff       	call   80107d39 <setupkvm>
80107e30:	a3 bc a2 11 80       	mov    %eax,0x8011a2bc
  switchkvm();
80107e35:	e8 03 00 00 00       	call   80107e3d <switchkvm>
}
80107e3a:	90                   	nop
80107e3b:	c9                   	leave  
80107e3c:	c3                   	ret    

80107e3d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e3d:	55                   	push   %ebp
80107e3e:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107e40:	a1 bc a2 11 80       	mov    0x8011a2bc,%eax
80107e45:	05 00 00 00 80       	add    $0x80000000,%eax
80107e4a:	50                   	push   %eax
80107e4b:	e8 61 fa ff ff       	call   801078b1 <lcr3>
80107e50:	83 c4 04             	add    $0x4,%esp
}
80107e53:	90                   	nop
80107e54:	c9                   	leave  
80107e55:	c3                   	ret    

80107e56 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e56:	55                   	push   %ebp
80107e57:	89 e5                	mov    %esp,%ebp
80107e59:	56                   	push   %esi
80107e5a:	53                   	push   %ebx
80107e5b:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107e5e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e62:	75 0d                	jne    80107e71 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107e64:	83 ec 0c             	sub    $0xc,%esp
80107e67:	68 f2 af 10 80       	push   $0x8010aff2
80107e6c:	e8 38 87 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107e71:	8b 45 08             	mov    0x8(%ebp),%eax
80107e74:	8b 40 08             	mov    0x8(%eax),%eax
80107e77:	85 c0                	test   %eax,%eax
80107e79:	75 0d                	jne    80107e88 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107e7b:	83 ec 0c             	sub    $0xc,%esp
80107e7e:	68 08 b0 10 80       	push   $0x8010b008
80107e83:	e8 21 87 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107e88:	8b 45 08             	mov    0x8(%ebp),%eax
80107e8b:	8b 40 04             	mov    0x4(%eax),%eax
80107e8e:	85 c0                	test   %eax,%eax
80107e90:	75 0d                	jne    80107e9f <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107e92:	83 ec 0c             	sub    $0xc,%esp
80107e95:	68 1d b0 10 80       	push   $0x8010b01d
80107e9a:	e8 0a 87 ff ff       	call   801005a9 <panic>

  pushcli();
80107e9f:	e8 4b d3 ff ff       	call   801051ef <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107ea4:	e8 f3 bf ff ff       	call   80103e9c <mycpu>
80107ea9:	89 c3                	mov    %eax,%ebx
80107eab:	e8 ec bf ff ff       	call   80103e9c <mycpu>
80107eb0:	83 c0 08             	add    $0x8,%eax
80107eb3:	89 c6                	mov    %eax,%esi
80107eb5:	e8 e2 bf ff ff       	call   80103e9c <mycpu>
80107eba:	83 c0 08             	add    $0x8,%eax
80107ebd:	c1 e8 10             	shr    $0x10,%eax
80107ec0:	88 45 f7             	mov    %al,-0x9(%ebp)
80107ec3:	e8 d4 bf ff ff       	call   80103e9c <mycpu>
80107ec8:	83 c0 08             	add    $0x8,%eax
80107ecb:	c1 e8 18             	shr    $0x18,%eax
80107ece:	89 c2                	mov    %eax,%edx
80107ed0:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107ed7:	67 00 
80107ed9:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107ee0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107ee4:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107eea:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ef1:	83 e0 f0             	and    $0xfffffff0,%eax
80107ef4:	83 c8 09             	or     $0x9,%eax
80107ef7:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107efd:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107f04:	83 c8 10             	or     $0x10,%eax
80107f07:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107f0d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107f14:	83 e0 9f             	and    $0xffffff9f,%eax
80107f17:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107f1d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107f24:	83 c8 80             	or     $0xffffff80,%eax
80107f27:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107f2d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f34:	83 e0 f0             	and    $0xfffffff0,%eax
80107f37:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f3d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f44:	83 e0 ef             	and    $0xffffffef,%eax
80107f47:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f4d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f54:	83 e0 df             	and    $0xffffffdf,%eax
80107f57:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f5d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f64:	83 c8 40             	or     $0x40,%eax
80107f67:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f6d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f74:	83 e0 7f             	and    $0x7f,%eax
80107f77:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f7d:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107f83:	e8 14 bf ff ff       	call   80103e9c <mycpu>
80107f88:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f8f:	83 e2 ef             	and    $0xffffffef,%edx
80107f92:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107f98:	e8 ff be ff ff       	call   80103e9c <mycpu>
80107f9d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa6:	8b 40 08             	mov    0x8(%eax),%eax
80107fa9:	89 c3                	mov    %eax,%ebx
80107fab:	e8 ec be ff ff       	call   80103e9c <mycpu>
80107fb0:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107fb6:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107fb9:	e8 de be ff ff       	call   80103e9c <mycpu>
80107fbe:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107fc4:	83 ec 0c             	sub    $0xc,%esp
80107fc7:	6a 28                	push   $0x28
80107fc9:	e8 cc f8 ff ff       	call   8010789a <ltr>
80107fce:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80107fd4:	8b 40 04             	mov    0x4(%eax),%eax
80107fd7:	05 00 00 00 80       	add    $0x80000000,%eax
80107fdc:	83 ec 0c             	sub    $0xc,%esp
80107fdf:	50                   	push   %eax
80107fe0:	e8 cc f8 ff ff       	call   801078b1 <lcr3>
80107fe5:	83 c4 10             	add    $0x10,%esp
  popcli();
80107fe8:	e8 4f d2 ff ff       	call   8010523c <popcli>
}
80107fed:	90                   	nop
80107fee:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107ff1:	5b                   	pop    %ebx
80107ff2:	5e                   	pop    %esi
80107ff3:	5d                   	pop    %ebp
80107ff4:	c3                   	ret    

80107ff5 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107ff5:	55                   	push   %ebp
80107ff6:	89 e5                	mov    %esp,%ebp
80107ff8:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107ffb:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108002:	76 0d                	jbe    80108011 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108004:	83 ec 0c             	sub    $0xc,%esp
80108007:	68 31 b0 10 80       	push   $0x8010b031
8010800c:	e8 98 85 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80108011:	e8 6e ac ff ff       	call   80102c84 <kalloc>
80108016:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108019:	83 ec 04             	sub    $0x4,%esp
8010801c:	68 00 10 00 00       	push   $0x1000
80108021:	6a 00                	push   $0x0
80108023:	ff 75 f4             	push   -0xc(%ebp)
80108026:	e8 cf d2 ff ff       	call   801052fa <memset>
8010802b:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010802e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108031:	05 00 00 00 80       	add    $0x80000000,%eax
80108036:	83 ec 0c             	sub    $0xc,%esp
80108039:	6a 06                	push   $0x6
8010803b:	50                   	push   %eax
8010803c:	68 00 10 00 00       	push   $0x1000
80108041:	6a 00                	push   $0x0
80108043:	ff 75 08             	push   0x8(%ebp)
80108046:	e8 5e fc ff ff       	call   80107ca9 <mappages>
8010804b:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010804e:	83 ec 04             	sub    $0x4,%esp
80108051:	ff 75 10             	push   0x10(%ebp)
80108054:	ff 75 0c             	push   0xc(%ebp)
80108057:	ff 75 f4             	push   -0xc(%ebp)
8010805a:	e8 5a d3 ff ff       	call   801053b9 <memmove>
8010805f:	83 c4 10             	add    $0x10,%esp
}
80108062:	90                   	nop
80108063:	c9                   	leave  
80108064:	c3                   	ret    

80108065 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108065:	55                   	push   %ebp
80108066:	89 e5                	mov    %esp,%ebp
80108068:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010806b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010806e:	25 ff 0f 00 00       	and    $0xfff,%eax
80108073:	85 c0                	test   %eax,%eax
80108075:	74 0d                	je     80108084 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108077:	83 ec 0c             	sub    $0xc,%esp
8010807a:	68 4c b0 10 80       	push   $0x8010b04c
8010807f:	e8 25 85 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108084:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010808b:	e9 8f 00 00 00       	jmp    8010811f <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108090:	8b 55 0c             	mov    0xc(%ebp),%edx
80108093:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108096:	01 d0                	add    %edx,%eax
80108098:	83 ec 04             	sub    $0x4,%esp
8010809b:	6a 00                	push   $0x0
8010809d:	50                   	push   %eax
8010809e:	ff 75 08             	push   0x8(%ebp)
801080a1:	e8 6d fb ff ff       	call   80107c13 <walkpgdir>
801080a6:	83 c4 10             	add    $0x10,%esp
801080a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080b0:	75 0d                	jne    801080bf <loaduvm+0x5a>
      panic("loaduvm: address should exist");
801080b2:	83 ec 0c             	sub    $0xc,%esp
801080b5:	68 6f b0 10 80       	push   $0x8010b06f
801080ba:	e8 ea 84 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801080bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080c2:	8b 00                	mov    (%eax),%eax
801080c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801080cc:	8b 45 18             	mov    0x18(%ebp),%eax
801080cf:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080d2:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801080d7:	77 0b                	ja     801080e4 <loaduvm+0x7f>
      n = sz - i;
801080d9:	8b 45 18             	mov    0x18(%ebp),%eax
801080dc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080df:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080e2:	eb 07                	jmp    801080eb <loaduvm+0x86>
    else
      n = PGSIZE;
801080e4:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801080eb:	8b 55 14             	mov    0x14(%ebp),%edx
801080ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f1:	01 d0                	add    %edx,%eax
801080f3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801080f6:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801080fc:	ff 75 f0             	push   -0x10(%ebp)
801080ff:	50                   	push   %eax
80108100:	52                   	push   %edx
80108101:	ff 75 10             	push   0x10(%ebp)
80108104:	e8 cd 9d ff ff       	call   80101ed6 <readi>
80108109:	83 c4 10             	add    $0x10,%esp
8010810c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010810f:	74 07                	je     80108118 <loaduvm+0xb3>
      return -1;
80108111:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108116:	eb 18                	jmp    80108130 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80108118:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010811f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108122:	3b 45 18             	cmp    0x18(%ebp),%eax
80108125:	0f 82 65 ff ff ff    	jb     80108090 <loaduvm+0x2b>
  }
  return 0;
8010812b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108130:	c9                   	leave  
80108131:	c3                   	ret    

80108132 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108132:	55                   	push   %ebp
80108133:	89 e5                	mov    %esp,%ebp
80108135:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108138:	8b 45 10             	mov    0x10(%ebp),%eax
8010813b:	85 c0                	test   %eax,%eax
8010813d:	79 0a                	jns    80108149 <allocuvm+0x17>
    return 0;
8010813f:	b8 00 00 00 00       	mov    $0x0,%eax
80108144:	e9 ec 00 00 00       	jmp    80108235 <allocuvm+0x103>
  if(newsz < oldsz)
80108149:	8b 45 10             	mov    0x10(%ebp),%eax
8010814c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010814f:	73 08                	jae    80108159 <allocuvm+0x27>
    return oldsz;
80108151:	8b 45 0c             	mov    0xc(%ebp),%eax
80108154:	e9 dc 00 00 00       	jmp    80108235 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80108159:	8b 45 0c             	mov    0xc(%ebp),%eax
8010815c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108161:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108166:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108169:	e9 b8 00 00 00       	jmp    80108226 <allocuvm+0xf4>
    mem = kalloc();
8010816e:	e8 11 ab ff ff       	call   80102c84 <kalloc>
80108173:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108176:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010817a:	75 2e                	jne    801081aa <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
8010817c:	83 ec 0c             	sub    $0xc,%esp
8010817f:	68 8d b0 10 80       	push   $0x8010b08d
80108184:	e8 6b 82 ff ff       	call   801003f4 <cprintf>
80108189:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010818c:	83 ec 04             	sub    $0x4,%esp
8010818f:	ff 75 0c             	push   0xc(%ebp)
80108192:	ff 75 10             	push   0x10(%ebp)
80108195:	ff 75 08             	push   0x8(%ebp)
80108198:	e8 9a 00 00 00       	call   80108237 <deallocuvm>
8010819d:	83 c4 10             	add    $0x10,%esp
      return 0;
801081a0:	b8 00 00 00 00       	mov    $0x0,%eax
801081a5:	e9 8b 00 00 00       	jmp    80108235 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
801081aa:	83 ec 04             	sub    $0x4,%esp
801081ad:	68 00 10 00 00       	push   $0x1000
801081b2:	6a 00                	push   $0x0
801081b4:	ff 75 f0             	push   -0x10(%ebp)
801081b7:	e8 3e d1 ff ff       	call   801052fa <memset>
801081bc:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801081bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801081c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081cb:	83 ec 0c             	sub    $0xc,%esp
801081ce:	6a 06                	push   $0x6
801081d0:	52                   	push   %edx
801081d1:	68 00 10 00 00       	push   $0x1000
801081d6:	50                   	push   %eax
801081d7:	ff 75 08             	push   0x8(%ebp)
801081da:	e8 ca fa ff ff       	call   80107ca9 <mappages>
801081df:	83 c4 20             	add    $0x20,%esp
801081e2:	85 c0                	test   %eax,%eax
801081e4:	79 39                	jns    8010821f <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801081e6:	83 ec 0c             	sub    $0xc,%esp
801081e9:	68 a5 b0 10 80       	push   $0x8010b0a5
801081ee:	e8 01 82 ff ff       	call   801003f4 <cprintf>
801081f3:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801081f6:	83 ec 04             	sub    $0x4,%esp
801081f9:	ff 75 0c             	push   0xc(%ebp)
801081fc:	ff 75 10             	push   0x10(%ebp)
801081ff:	ff 75 08             	push   0x8(%ebp)
80108202:	e8 30 00 00 00       	call   80108237 <deallocuvm>
80108207:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010820a:	83 ec 0c             	sub    $0xc,%esp
8010820d:	ff 75 f0             	push   -0x10(%ebp)
80108210:	e8 d5 a9 ff ff       	call   80102bea <kfree>
80108215:	83 c4 10             	add    $0x10,%esp
      return 0;
80108218:	b8 00 00 00 00       	mov    $0x0,%eax
8010821d:	eb 16                	jmp    80108235 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
8010821f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108229:	3b 45 10             	cmp    0x10(%ebp),%eax
8010822c:	0f 82 3c ff ff ff    	jb     8010816e <allocuvm+0x3c>
    }
  }
  return newsz;
80108232:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108235:	c9                   	leave  
80108236:	c3                   	ret    

80108237 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108237:	55                   	push   %ebp
80108238:	89 e5                	mov    %esp,%ebp
8010823a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010823d:	8b 45 10             	mov    0x10(%ebp),%eax
80108240:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108243:	72 08                	jb     8010824d <deallocuvm+0x16>
    return oldsz;
80108245:	8b 45 0c             	mov    0xc(%ebp),%eax
80108248:	e9 ac 00 00 00       	jmp    801082f9 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
8010824d:	8b 45 10             	mov    0x10(%ebp),%eax
80108250:	05 ff 0f 00 00       	add    $0xfff,%eax
80108255:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010825a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010825d:	e9 88 00 00 00       	jmp    801082ea <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108265:	83 ec 04             	sub    $0x4,%esp
80108268:	6a 00                	push   $0x0
8010826a:	50                   	push   %eax
8010826b:	ff 75 08             	push   0x8(%ebp)
8010826e:	e8 a0 f9 ff ff       	call   80107c13 <walkpgdir>
80108273:	83 c4 10             	add    $0x10,%esp
80108276:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108279:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010827d:	75 16                	jne    80108295 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010827f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108282:	c1 e8 16             	shr    $0x16,%eax
80108285:	83 c0 01             	add    $0x1,%eax
80108288:	c1 e0 16             	shl    $0x16,%eax
8010828b:	2d 00 10 00 00       	sub    $0x1000,%eax
80108290:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108293:	eb 4e                	jmp    801082e3 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108295:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108298:	8b 00                	mov    (%eax),%eax
8010829a:	83 e0 01             	and    $0x1,%eax
8010829d:	85 c0                	test   %eax,%eax
8010829f:	74 42                	je     801082e3 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801082a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a4:	8b 00                	mov    (%eax),%eax
801082a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801082ae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082b2:	75 0d                	jne    801082c1 <deallocuvm+0x8a>
        panic("kfree");
801082b4:	83 ec 0c             	sub    $0xc,%esp
801082b7:	68 c1 b0 10 80       	push   $0x8010b0c1
801082bc:	e8 e8 82 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
801082c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082c4:	05 00 00 00 80       	add    $0x80000000,%eax
801082c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801082cc:	83 ec 0c             	sub    $0xc,%esp
801082cf:	ff 75 e8             	push   -0x18(%ebp)
801082d2:	e8 13 a9 ff ff       	call   80102bea <kfree>
801082d7:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801082da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801082e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ed:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082f0:	0f 82 6c ff ff ff    	jb     80108262 <deallocuvm+0x2b>
    }
  }
  return newsz;
801082f6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801082f9:	c9                   	leave  
801082fa:	c3                   	ret    

801082fb <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801082fb:	55                   	push   %ebp
801082fc:	89 e5                	mov    %esp,%ebp
801082fe:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108301:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108305:	75 0d                	jne    80108314 <freevm+0x19>
    panic("freevm: no pgdir");
80108307:	83 ec 0c             	sub    $0xc,%esp
8010830a:	68 c7 b0 10 80       	push   $0x8010b0c7
8010830f:	e8 95 82 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108314:	83 ec 04             	sub    $0x4,%esp
80108317:	6a 00                	push   $0x0
80108319:	68 00 00 00 80       	push   $0x80000000
8010831e:	ff 75 08             	push   0x8(%ebp)
80108321:	e8 11 ff ff ff       	call   80108237 <deallocuvm>
80108326:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108330:	eb 48                	jmp    8010837a <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108335:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010833c:	8b 45 08             	mov    0x8(%ebp),%eax
8010833f:	01 d0                	add    %edx,%eax
80108341:	8b 00                	mov    (%eax),%eax
80108343:	83 e0 01             	and    $0x1,%eax
80108346:	85 c0                	test   %eax,%eax
80108348:	74 2c                	je     80108376 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010834a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108354:	8b 45 08             	mov    0x8(%ebp),%eax
80108357:	01 d0                	add    %edx,%eax
80108359:	8b 00                	mov    (%eax),%eax
8010835b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108360:	05 00 00 00 80       	add    $0x80000000,%eax
80108365:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108368:	83 ec 0c             	sub    $0xc,%esp
8010836b:	ff 75 f0             	push   -0x10(%ebp)
8010836e:	e8 77 a8 ff ff       	call   80102bea <kfree>
80108373:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108376:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010837a:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108381:	76 af                	jbe    80108332 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108383:	83 ec 0c             	sub    $0xc,%esp
80108386:	ff 75 08             	push   0x8(%ebp)
80108389:	e8 5c a8 ff ff       	call   80102bea <kfree>
8010838e:	83 c4 10             	add    $0x10,%esp
}
80108391:	90                   	nop
80108392:	c9                   	leave  
80108393:	c3                   	ret    

80108394 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108394:	55                   	push   %ebp
80108395:	89 e5                	mov    %esp,%ebp
80108397:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010839a:	83 ec 04             	sub    $0x4,%esp
8010839d:	6a 00                	push   $0x0
8010839f:	ff 75 0c             	push   0xc(%ebp)
801083a2:	ff 75 08             	push   0x8(%ebp)
801083a5:	e8 69 f8 ff ff       	call   80107c13 <walkpgdir>
801083aa:	83 c4 10             	add    $0x10,%esp
801083ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801083b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083b4:	75 0d                	jne    801083c3 <clearpteu+0x2f>
    panic("clearpteu");
801083b6:	83 ec 0c             	sub    $0xc,%esp
801083b9:	68 d8 b0 10 80       	push   $0x8010b0d8
801083be:	e8 e6 81 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
801083c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c6:	8b 00                	mov    (%eax),%eax
801083c8:	83 e0 fb             	and    $0xfffffffb,%eax
801083cb:	89 c2                	mov    %eax,%edx
801083cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d0:	89 10                	mov    %edx,(%eax)
}
801083d2:	90                   	nop
801083d3:	c9                   	leave  
801083d4:	c3                   	ret    

801083d5 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801083d5:	55                   	push   %ebp
801083d6:	89 e5                	mov    %esp,%ebp
801083d8:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801083db:	e8 59 f9 ff ff       	call   80107d39 <setupkvm>
801083e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083e7:	75 0a                	jne    801083f3 <copyuvm+0x1e>
    return 0;
801083e9:	b8 00 00 00 00       	mov    $0x0,%eax
801083ee:	e9 eb 00 00 00       	jmp    801084de <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801083f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083fa:	e9 b7 00 00 00       	jmp    801084b6 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801083ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108402:	83 ec 04             	sub    $0x4,%esp
80108405:	6a 00                	push   $0x0
80108407:	50                   	push   %eax
80108408:	ff 75 08             	push   0x8(%ebp)
8010840b:	e8 03 f8 ff ff       	call   80107c13 <walkpgdir>
80108410:	83 c4 10             	add    $0x10,%esp
80108413:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108416:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010841a:	75 0d                	jne    80108429 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
8010841c:	83 ec 0c             	sub    $0xc,%esp
8010841f:	68 e2 b0 10 80       	push   $0x8010b0e2
80108424:	e8 80 81 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80108429:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010842c:	8b 00                	mov    (%eax),%eax
8010842e:	83 e0 01             	and    $0x1,%eax
80108431:	85 c0                	test   %eax,%eax
80108433:	75 0d                	jne    80108442 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80108435:	83 ec 0c             	sub    $0xc,%esp
80108438:	68 fc b0 10 80       	push   $0x8010b0fc
8010843d:	e8 67 81 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80108442:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108445:	8b 00                	mov    (%eax),%eax
80108447:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010844c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010844f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108452:	8b 00                	mov    (%eax),%eax
80108454:	25 ff 0f 00 00       	and    $0xfff,%eax
80108459:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010845c:	e8 23 a8 ff ff       	call   80102c84 <kalloc>
80108461:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108464:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108468:	74 5d                	je     801084c7 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010846a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010846d:	05 00 00 00 80       	add    $0x80000000,%eax
80108472:	83 ec 04             	sub    $0x4,%esp
80108475:	68 00 10 00 00       	push   $0x1000
8010847a:	50                   	push   %eax
8010847b:	ff 75 e0             	push   -0x20(%ebp)
8010847e:	e8 36 cf ff ff       	call   801053b9 <memmove>
80108483:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108486:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108489:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010848c:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108495:	83 ec 0c             	sub    $0xc,%esp
80108498:	52                   	push   %edx
80108499:	51                   	push   %ecx
8010849a:	68 00 10 00 00       	push   $0x1000
8010849f:	50                   	push   %eax
801084a0:	ff 75 f0             	push   -0x10(%ebp)
801084a3:	e8 01 f8 ff ff       	call   80107ca9 <mappages>
801084a8:	83 c4 20             	add    $0x20,%esp
801084ab:	85 c0                	test   %eax,%eax
801084ad:	78 1b                	js     801084ca <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
801084af:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084bc:	0f 82 3d ff ff ff    	jb     801083ff <copyuvm+0x2a>
      goto bad;
  }
  return d;
801084c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c5:	eb 17                	jmp    801084de <copyuvm+0x109>
      goto bad;
801084c7:	90                   	nop
801084c8:	eb 01                	jmp    801084cb <copyuvm+0xf6>
      goto bad;
801084ca:	90                   	nop

bad:
  freevm(d);
801084cb:	83 ec 0c             	sub    $0xc,%esp
801084ce:	ff 75 f0             	push   -0x10(%ebp)
801084d1:	e8 25 fe ff ff       	call   801082fb <freevm>
801084d6:	83 c4 10             	add    $0x10,%esp
  return 0;
801084d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084de:	c9                   	leave  
801084df:	c3                   	ret    

801084e0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801084e0:	55                   	push   %ebp
801084e1:	89 e5                	mov    %esp,%ebp
801084e3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084e6:	83 ec 04             	sub    $0x4,%esp
801084e9:	6a 00                	push   $0x0
801084eb:	ff 75 0c             	push   0xc(%ebp)
801084ee:	ff 75 08             	push   0x8(%ebp)
801084f1:	e8 1d f7 ff ff       	call   80107c13 <walkpgdir>
801084f6:	83 c4 10             	add    $0x10,%esp
801084f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801084fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ff:	8b 00                	mov    (%eax),%eax
80108501:	83 e0 01             	and    $0x1,%eax
80108504:	85 c0                	test   %eax,%eax
80108506:	75 07                	jne    8010850f <uva2ka+0x2f>
    return 0;
80108508:	b8 00 00 00 00       	mov    $0x0,%eax
8010850d:	eb 22                	jmp    80108531 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
8010850f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108512:	8b 00                	mov    (%eax),%eax
80108514:	83 e0 04             	and    $0x4,%eax
80108517:	85 c0                	test   %eax,%eax
80108519:	75 07                	jne    80108522 <uva2ka+0x42>
    return 0;
8010851b:	b8 00 00 00 00       	mov    $0x0,%eax
80108520:	eb 0f                	jmp    80108531 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108525:	8b 00                	mov    (%eax),%eax
80108527:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010852c:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108531:	c9                   	leave  
80108532:	c3                   	ret    

80108533 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108533:	55                   	push   %ebp
80108534:	89 e5                	mov    %esp,%ebp
80108536:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108539:	8b 45 10             	mov    0x10(%ebp),%eax
8010853c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010853f:	eb 7f                	jmp    801085c0 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108541:	8b 45 0c             	mov    0xc(%ebp),%eax
80108544:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108549:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010854c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010854f:	83 ec 08             	sub    $0x8,%esp
80108552:	50                   	push   %eax
80108553:	ff 75 08             	push   0x8(%ebp)
80108556:	e8 85 ff ff ff       	call   801084e0 <uva2ka>
8010855b:	83 c4 10             	add    $0x10,%esp
8010855e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108561:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108565:	75 07                	jne    8010856e <copyout+0x3b>
      return -1;
80108567:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010856c:	eb 61                	jmp    801085cf <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010856e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108571:	2b 45 0c             	sub    0xc(%ebp),%eax
80108574:	05 00 10 00 00       	add    $0x1000,%eax
80108579:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010857c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010857f:	3b 45 14             	cmp    0x14(%ebp),%eax
80108582:	76 06                	jbe    8010858a <copyout+0x57>
      n = len;
80108584:	8b 45 14             	mov    0x14(%ebp),%eax
80108587:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010858a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010858d:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108590:	89 c2                	mov    %eax,%edx
80108592:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108595:	01 d0                	add    %edx,%eax
80108597:	83 ec 04             	sub    $0x4,%esp
8010859a:	ff 75 f0             	push   -0x10(%ebp)
8010859d:	ff 75 f4             	push   -0xc(%ebp)
801085a0:	50                   	push   %eax
801085a1:	e8 13 ce ff ff       	call   801053b9 <memmove>
801085a6:	83 c4 10             	add    $0x10,%esp
    len -= n;
801085a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ac:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801085af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b2:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801085b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085b8:	05 00 10 00 00       	add    $0x1000,%eax
801085bd:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801085c0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801085c4:	0f 85 77 ff ff ff    	jne    80108541 <copyout+0xe>
  }
  return 0;
801085ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085cf:	c9                   	leave  
801085d0:	c3                   	ret    

801085d1 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801085d1:	55                   	push   %ebp
801085d2:	89 e5                	mov    %esp,%ebp
801085d4:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801085d7:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801085de:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085e1:	8b 40 08             	mov    0x8(%eax),%eax
801085e4:	05 00 00 00 80       	add    $0x80000000,%eax
801085e9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801085ec:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801085f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f6:	8b 40 24             	mov    0x24(%eax),%eax
801085f9:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
801085fe:	c7 05 90 a5 11 80 00 	movl   $0x0,0x8011a590
80108605:	00 00 00 

  while(i<madt->len){
80108608:	90                   	nop
80108609:	e9 bd 00 00 00       	jmp    801086cb <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
8010860e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108611:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108614:	01 d0                	add    %edx,%eax
80108616:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010861c:	0f b6 00             	movzbl (%eax),%eax
8010861f:	0f b6 c0             	movzbl %al,%eax
80108622:	83 f8 05             	cmp    $0x5,%eax
80108625:	0f 87 a0 00 00 00    	ja     801086cb <mpinit_uefi+0xfa>
8010862b:	8b 04 85 18 b1 10 80 	mov    -0x7fef4ee8(,%eax,4),%eax
80108632:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108634:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108637:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
8010863a:	a1 90 a5 11 80       	mov    0x8011a590,%eax
8010863f:	83 f8 03             	cmp    $0x3,%eax
80108642:	7f 28                	jg     8010866c <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108644:	8b 15 90 a5 11 80    	mov    0x8011a590,%edx
8010864a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010864d:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108651:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108657:	81 c2 c0 a2 11 80    	add    $0x8011a2c0,%edx
8010865d:	88 02                	mov    %al,(%edx)
          ncpu++;
8010865f:	a1 90 a5 11 80       	mov    0x8011a590,%eax
80108664:	83 c0 01             	add    $0x1,%eax
80108667:	a3 90 a5 11 80       	mov    %eax,0x8011a590
        }
        i += lapic_entry->record_len;
8010866c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010866f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108673:	0f b6 c0             	movzbl %al,%eax
80108676:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108679:	eb 50                	jmp    801086cb <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
8010867b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010867e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108681:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108684:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108688:	a2 94 a5 11 80       	mov    %al,0x8011a594
        i += ioapic->record_len;
8010868d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108690:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108694:	0f b6 c0             	movzbl %al,%eax
80108697:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010869a:	eb 2f                	jmp    801086cb <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010869c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010869f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801086a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086a5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801086a9:	0f b6 c0             	movzbl %al,%eax
801086ac:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801086af:	eb 1a                	jmp    801086cb <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801086b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801086b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ba:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801086be:	0f b6 c0             	movzbl %al,%eax
801086c1:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801086c4:	eb 05                	jmp    801086cb <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
801086c6:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801086ca:	90                   	nop
  while(i<madt->len){
801086cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ce:	8b 40 04             	mov    0x4(%eax),%eax
801086d1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801086d4:	0f 82 34 ff ff ff    	jb     8010860e <mpinit_uefi+0x3d>
    }
  }

}
801086da:	90                   	nop
801086db:	90                   	nop
801086dc:	c9                   	leave  
801086dd:	c3                   	ret    

801086de <inb>:
{
801086de:	55                   	push   %ebp
801086df:	89 e5                	mov    %esp,%ebp
801086e1:	83 ec 14             	sub    $0x14,%esp
801086e4:	8b 45 08             	mov    0x8(%ebp),%eax
801086e7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801086eb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801086ef:	89 c2                	mov    %eax,%edx
801086f1:	ec                   	in     (%dx),%al
801086f2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801086f5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801086f9:	c9                   	leave  
801086fa:	c3                   	ret    

801086fb <outb>:
{
801086fb:	55                   	push   %ebp
801086fc:	89 e5                	mov    %esp,%ebp
801086fe:	83 ec 08             	sub    $0x8,%esp
80108701:	8b 45 08             	mov    0x8(%ebp),%eax
80108704:	8b 55 0c             	mov    0xc(%ebp),%edx
80108707:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010870b:	89 d0                	mov    %edx,%eax
8010870d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108710:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108714:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108718:	ee                   	out    %al,(%dx)
}
80108719:	90                   	nop
8010871a:	c9                   	leave  
8010871b:	c3                   	ret    

8010871c <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010871c:	55                   	push   %ebp
8010871d:	89 e5                	mov    %esp,%ebp
8010871f:	83 ec 28             	sub    $0x28,%esp
80108722:	8b 45 08             	mov    0x8(%ebp),%eax
80108725:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108728:	6a 00                	push   $0x0
8010872a:	68 fa 03 00 00       	push   $0x3fa
8010872f:	e8 c7 ff ff ff       	call   801086fb <outb>
80108734:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108737:	68 80 00 00 00       	push   $0x80
8010873c:	68 fb 03 00 00       	push   $0x3fb
80108741:	e8 b5 ff ff ff       	call   801086fb <outb>
80108746:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108749:	6a 0c                	push   $0xc
8010874b:	68 f8 03 00 00       	push   $0x3f8
80108750:	e8 a6 ff ff ff       	call   801086fb <outb>
80108755:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108758:	6a 00                	push   $0x0
8010875a:	68 f9 03 00 00       	push   $0x3f9
8010875f:	e8 97 ff ff ff       	call   801086fb <outb>
80108764:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108767:	6a 03                	push   $0x3
80108769:	68 fb 03 00 00       	push   $0x3fb
8010876e:	e8 88 ff ff ff       	call   801086fb <outb>
80108773:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108776:	6a 00                	push   $0x0
80108778:	68 fc 03 00 00       	push   $0x3fc
8010877d:	e8 79 ff ff ff       	call   801086fb <outb>
80108782:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108785:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010878c:	eb 11                	jmp    8010879f <uart_debug+0x83>
8010878e:	83 ec 0c             	sub    $0xc,%esp
80108791:	6a 0a                	push   $0xa
80108793:	e8 83 a8 ff ff       	call   8010301b <microdelay>
80108798:	83 c4 10             	add    $0x10,%esp
8010879b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010879f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801087a3:	7f 1a                	jg     801087bf <uart_debug+0xa3>
801087a5:	83 ec 0c             	sub    $0xc,%esp
801087a8:	68 fd 03 00 00       	push   $0x3fd
801087ad:	e8 2c ff ff ff       	call   801086de <inb>
801087b2:	83 c4 10             	add    $0x10,%esp
801087b5:	0f b6 c0             	movzbl %al,%eax
801087b8:	83 e0 20             	and    $0x20,%eax
801087bb:	85 c0                	test   %eax,%eax
801087bd:	74 cf                	je     8010878e <uart_debug+0x72>
  outb(COM1+0, p);
801087bf:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801087c3:	0f b6 c0             	movzbl %al,%eax
801087c6:	83 ec 08             	sub    $0x8,%esp
801087c9:	50                   	push   %eax
801087ca:	68 f8 03 00 00       	push   $0x3f8
801087cf:	e8 27 ff ff ff       	call   801086fb <outb>
801087d4:	83 c4 10             	add    $0x10,%esp
}
801087d7:	90                   	nop
801087d8:	c9                   	leave  
801087d9:	c3                   	ret    

801087da <uart_debugs>:

void uart_debugs(char *p){
801087da:	55                   	push   %ebp
801087db:	89 e5                	mov    %esp,%ebp
801087dd:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801087e0:	eb 1b                	jmp    801087fd <uart_debugs+0x23>
    uart_debug(*p++);
801087e2:	8b 45 08             	mov    0x8(%ebp),%eax
801087e5:	8d 50 01             	lea    0x1(%eax),%edx
801087e8:	89 55 08             	mov    %edx,0x8(%ebp)
801087eb:	0f b6 00             	movzbl (%eax),%eax
801087ee:	0f be c0             	movsbl %al,%eax
801087f1:	83 ec 0c             	sub    $0xc,%esp
801087f4:	50                   	push   %eax
801087f5:	e8 22 ff ff ff       	call   8010871c <uart_debug>
801087fa:	83 c4 10             	add    $0x10,%esp
  while(*p){
801087fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108800:	0f b6 00             	movzbl (%eax),%eax
80108803:	84 c0                	test   %al,%al
80108805:	75 db                	jne    801087e2 <uart_debugs+0x8>
  }
}
80108807:	90                   	nop
80108808:	90                   	nop
80108809:	c9                   	leave  
8010880a:	c3                   	ret    

8010880b <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010880b:	55                   	push   %ebp
8010880c:	89 e5                	mov    %esp,%ebp
8010880e:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108811:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108818:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010881b:	8b 50 14             	mov    0x14(%eax),%edx
8010881e:	8b 40 10             	mov    0x10(%eax),%eax
80108821:	a3 98 a5 11 80       	mov    %eax,0x8011a598
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108826:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108829:	8b 50 1c             	mov    0x1c(%eax),%edx
8010882c:	8b 40 18             	mov    0x18(%eax),%eax
8010882f:	a3 a0 a5 11 80       	mov    %eax,0x8011a5a0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108834:	8b 15 a0 a5 11 80    	mov    0x8011a5a0,%edx
8010883a:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010883f:	29 d0                	sub    %edx,%eax
80108841:	a3 9c a5 11 80       	mov    %eax,0x8011a59c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108846:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108849:	8b 50 24             	mov    0x24(%eax),%edx
8010884c:	8b 40 20             	mov    0x20(%eax),%eax
8010884f:	a3 a4 a5 11 80       	mov    %eax,0x8011a5a4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108854:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108857:	8b 50 2c             	mov    0x2c(%eax),%edx
8010885a:	8b 40 28             	mov    0x28(%eax),%eax
8010885d:	a3 a8 a5 11 80       	mov    %eax,0x8011a5a8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108862:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108865:	8b 50 34             	mov    0x34(%eax),%edx
80108868:	8b 40 30             	mov    0x30(%eax),%eax
8010886b:	a3 ac a5 11 80       	mov    %eax,0x8011a5ac
}
80108870:	90                   	nop
80108871:	c9                   	leave  
80108872:	c3                   	ret    

80108873 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108873:	55                   	push   %ebp
80108874:	89 e5                	mov    %esp,%ebp
80108876:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108879:	8b 15 ac a5 11 80    	mov    0x8011a5ac,%edx
8010887f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108882:	0f af d0             	imul   %eax,%edx
80108885:	8b 45 08             	mov    0x8(%ebp),%eax
80108888:	01 d0                	add    %edx,%eax
8010888a:	c1 e0 02             	shl    $0x2,%eax
8010888d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108890:	8b 15 9c a5 11 80    	mov    0x8011a59c,%edx
80108896:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108899:	01 d0                	add    %edx,%eax
8010889b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
8010889e:	8b 45 10             	mov    0x10(%ebp),%eax
801088a1:	0f b6 10             	movzbl (%eax),%edx
801088a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801088a7:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801088a9:	8b 45 10             	mov    0x10(%ebp),%eax
801088ac:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801088b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801088b3:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801088b6:	8b 45 10             	mov    0x10(%ebp),%eax
801088b9:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801088bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801088c0:	88 50 02             	mov    %dl,0x2(%eax)
}
801088c3:	90                   	nop
801088c4:	c9                   	leave  
801088c5:	c3                   	ret    

801088c6 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801088c6:	55                   	push   %ebp
801088c7:	89 e5                	mov    %esp,%ebp
801088c9:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801088cc:	8b 15 ac a5 11 80    	mov    0x8011a5ac,%edx
801088d2:	8b 45 08             	mov    0x8(%ebp),%eax
801088d5:	0f af c2             	imul   %edx,%eax
801088d8:	c1 e0 02             	shl    $0x2,%eax
801088db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801088de:	a1 a0 a5 11 80       	mov    0x8011a5a0,%eax
801088e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088e6:	29 d0                	sub    %edx,%eax
801088e8:	8b 0d 9c a5 11 80    	mov    0x8011a59c,%ecx
801088ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088f1:	01 ca                	add    %ecx,%edx
801088f3:	89 d1                	mov    %edx,%ecx
801088f5:	8b 15 9c a5 11 80    	mov    0x8011a59c,%edx
801088fb:	83 ec 04             	sub    $0x4,%esp
801088fe:	50                   	push   %eax
801088ff:	51                   	push   %ecx
80108900:	52                   	push   %edx
80108901:	e8 b3 ca ff ff       	call   801053b9 <memmove>
80108906:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890c:	8b 0d 9c a5 11 80    	mov    0x8011a59c,%ecx
80108912:	8b 15 a0 a5 11 80    	mov    0x8011a5a0,%edx
80108918:	01 ca                	add    %ecx,%edx
8010891a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010891d:	29 ca                	sub    %ecx,%edx
8010891f:	83 ec 04             	sub    $0x4,%esp
80108922:	50                   	push   %eax
80108923:	6a 00                	push   $0x0
80108925:	52                   	push   %edx
80108926:	e8 cf c9 ff ff       	call   801052fa <memset>
8010892b:	83 c4 10             	add    $0x10,%esp
}
8010892e:	90                   	nop
8010892f:	c9                   	leave  
80108930:	c3                   	ret    

80108931 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108931:	55                   	push   %ebp
80108932:	89 e5                	mov    %esp,%ebp
80108934:	53                   	push   %ebx
80108935:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108938:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010893f:	e9 b1 00 00 00       	jmp    801089f5 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108944:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010894b:	e9 97 00 00 00       	jmp    801089e7 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108950:	8b 45 10             	mov    0x10(%ebp),%eax
80108953:	83 e8 20             	sub    $0x20,%eax
80108956:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895c:	01 d0                	add    %edx,%eax
8010895e:	0f b7 84 00 40 b1 10 	movzwl -0x7fef4ec0(%eax,%eax,1),%eax
80108965:	80 
80108966:	0f b7 d0             	movzwl %ax,%edx
80108969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010896c:	bb 01 00 00 00       	mov    $0x1,%ebx
80108971:	89 c1                	mov    %eax,%ecx
80108973:	d3 e3                	shl    %cl,%ebx
80108975:	89 d8                	mov    %ebx,%eax
80108977:	21 d0                	and    %edx,%eax
80108979:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010897c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010897f:	ba 01 00 00 00       	mov    $0x1,%edx
80108984:	89 c1                	mov    %eax,%ecx
80108986:	d3 e2                	shl    %cl,%edx
80108988:	89 d0                	mov    %edx,%eax
8010898a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010898d:	75 2b                	jne    801089ba <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
8010898f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108995:	01 c2                	add    %eax,%edx
80108997:	b8 0e 00 00 00       	mov    $0xe,%eax
8010899c:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010899f:	89 c1                	mov    %eax,%ecx
801089a1:	8b 45 08             	mov    0x8(%ebp),%eax
801089a4:	01 c8                	add    %ecx,%eax
801089a6:	83 ec 04             	sub    $0x4,%esp
801089a9:	68 e0 f4 10 80       	push   $0x8010f4e0
801089ae:	52                   	push   %edx
801089af:	50                   	push   %eax
801089b0:	e8 be fe ff ff       	call   80108873 <graphic_draw_pixel>
801089b5:	83 c4 10             	add    $0x10,%esp
801089b8:	eb 29                	jmp    801089e3 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801089ba:	8b 55 0c             	mov    0xc(%ebp),%edx
801089bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c0:	01 c2                	add    %eax,%edx
801089c2:	b8 0e 00 00 00       	mov    $0xe,%eax
801089c7:	2b 45 f0             	sub    -0x10(%ebp),%eax
801089ca:	89 c1                	mov    %eax,%ecx
801089cc:	8b 45 08             	mov    0x8(%ebp),%eax
801089cf:	01 c8                	add    %ecx,%eax
801089d1:	83 ec 04             	sub    $0x4,%esp
801089d4:	68 b0 a5 11 80       	push   $0x8011a5b0
801089d9:	52                   	push   %edx
801089da:	50                   	push   %eax
801089db:	e8 93 fe ff ff       	call   80108873 <graphic_draw_pixel>
801089e0:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801089e3:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801089e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801089eb:	0f 89 5f ff ff ff    	jns    80108950 <font_render+0x1f>
  for(int i=0;i<30;i++){
801089f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089f5:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801089f9:	0f 8e 45 ff ff ff    	jle    80108944 <font_render+0x13>
      }
    }
  }
}
801089ff:	90                   	nop
80108a00:	90                   	nop
80108a01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a04:	c9                   	leave  
80108a05:	c3                   	ret    

80108a06 <font_render_string>:

void font_render_string(char *string,int row){
80108a06:	55                   	push   %ebp
80108a07:	89 e5                	mov    %esp,%ebp
80108a09:	53                   	push   %ebx
80108a0a:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108a0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108a14:	eb 33                	jmp    80108a49 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108a16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a19:	8b 45 08             	mov    0x8(%ebp),%eax
80108a1c:	01 d0                	add    %edx,%eax
80108a1e:	0f b6 00             	movzbl (%eax),%eax
80108a21:	0f be c8             	movsbl %al,%ecx
80108a24:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a27:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108a2a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108a2d:	89 d8                	mov    %ebx,%eax
80108a2f:	c1 e0 04             	shl    $0x4,%eax
80108a32:	29 d8                	sub    %ebx,%eax
80108a34:	83 c0 02             	add    $0x2,%eax
80108a37:	83 ec 04             	sub    $0x4,%esp
80108a3a:	51                   	push   %ecx
80108a3b:	52                   	push   %edx
80108a3c:	50                   	push   %eax
80108a3d:	e8 ef fe ff ff       	call   80108931 <font_render>
80108a42:	83 c4 10             	add    $0x10,%esp
    i++;
80108a45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108a49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80108a4f:	01 d0                	add    %edx,%eax
80108a51:	0f b6 00             	movzbl (%eax),%eax
80108a54:	84 c0                	test   %al,%al
80108a56:	74 06                	je     80108a5e <font_render_string+0x58>
80108a58:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108a5c:	7e b8                	jle    80108a16 <font_render_string+0x10>
  }
}
80108a5e:	90                   	nop
80108a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a62:	c9                   	leave  
80108a63:	c3                   	ret    

80108a64 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108a64:	55                   	push   %ebp
80108a65:	89 e5                	mov    %esp,%ebp
80108a67:	53                   	push   %ebx
80108a68:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108a6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a72:	eb 6b                	jmp    80108adf <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108a74:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108a7b:	eb 58                	jmp    80108ad5 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108a7d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108a84:	eb 45                	jmp    80108acb <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108a86:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108a89:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8f:	83 ec 0c             	sub    $0xc,%esp
80108a92:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108a95:	53                   	push   %ebx
80108a96:	6a 00                	push   $0x0
80108a98:	51                   	push   %ecx
80108a99:	52                   	push   %edx
80108a9a:	50                   	push   %eax
80108a9b:	e8 b0 00 00 00       	call   80108b50 <pci_access_config>
80108aa0:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108aa3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108aa6:	0f b7 c0             	movzwl %ax,%eax
80108aa9:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108aae:	74 17                	je     80108ac7 <pci_init+0x63>
        pci_init_device(i,j,k);
80108ab0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108ab3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab9:	83 ec 04             	sub    $0x4,%esp
80108abc:	51                   	push   %ecx
80108abd:	52                   	push   %edx
80108abe:	50                   	push   %eax
80108abf:	e8 37 01 00 00       	call   80108bfb <pci_init_device>
80108ac4:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108ac7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108acb:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108acf:	7e b5                	jle    80108a86 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108ad1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108ad5:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108ad9:	7e a2                	jle    80108a7d <pci_init+0x19>
  for(int i=0;i<256;i++){
80108adb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108adf:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108ae6:	7e 8c                	jle    80108a74 <pci_init+0x10>
      }
      }
    }
  }
}
80108ae8:	90                   	nop
80108ae9:	90                   	nop
80108aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108aed:	c9                   	leave  
80108aee:	c3                   	ret    

80108aef <pci_write_config>:

void pci_write_config(uint config){
80108aef:	55                   	push   %ebp
80108af0:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108af2:	8b 45 08             	mov    0x8(%ebp),%eax
80108af5:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108afa:	89 c0                	mov    %eax,%eax
80108afc:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108afd:	90                   	nop
80108afe:	5d                   	pop    %ebp
80108aff:	c3                   	ret    

80108b00 <pci_write_data>:

void pci_write_data(uint config){
80108b00:	55                   	push   %ebp
80108b01:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108b03:	8b 45 08             	mov    0x8(%ebp),%eax
80108b06:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108b0b:	89 c0                	mov    %eax,%eax
80108b0d:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108b0e:	90                   	nop
80108b0f:	5d                   	pop    %ebp
80108b10:	c3                   	ret    

80108b11 <pci_read_config>:
uint pci_read_config(){
80108b11:	55                   	push   %ebp
80108b12:	89 e5                	mov    %esp,%ebp
80108b14:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108b17:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108b1c:	ed                   	in     (%dx),%eax
80108b1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108b20:	83 ec 0c             	sub    $0xc,%esp
80108b23:	68 c8 00 00 00       	push   $0xc8
80108b28:	e8 ee a4 ff ff       	call   8010301b <microdelay>
80108b2d:	83 c4 10             	add    $0x10,%esp
  return data;
80108b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108b33:	c9                   	leave  
80108b34:	c3                   	ret    

80108b35 <pci_test>:


void pci_test(){
80108b35:	55                   	push   %ebp
80108b36:	89 e5                	mov    %esp,%ebp
80108b38:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108b3b:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108b42:	ff 75 fc             	push   -0x4(%ebp)
80108b45:	e8 a5 ff ff ff       	call   80108aef <pci_write_config>
80108b4a:	83 c4 04             	add    $0x4,%esp
}
80108b4d:	90                   	nop
80108b4e:	c9                   	leave  
80108b4f:	c3                   	ret    

80108b50 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108b50:	55                   	push   %ebp
80108b51:	89 e5                	mov    %esp,%ebp
80108b53:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108b56:	8b 45 08             	mov    0x8(%ebp),%eax
80108b59:	c1 e0 10             	shl    $0x10,%eax
80108b5c:	25 00 00 ff 00       	and    $0xff0000,%eax
80108b61:	89 c2                	mov    %eax,%edx
80108b63:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b66:	c1 e0 0b             	shl    $0xb,%eax
80108b69:	0f b7 c0             	movzwl %ax,%eax
80108b6c:	09 c2                	or     %eax,%edx
80108b6e:	8b 45 10             	mov    0x10(%ebp),%eax
80108b71:	c1 e0 08             	shl    $0x8,%eax
80108b74:	25 00 07 00 00       	and    $0x700,%eax
80108b79:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108b7b:	8b 45 14             	mov    0x14(%ebp),%eax
80108b7e:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108b83:	09 d0                	or     %edx,%eax
80108b85:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108b8d:	ff 75 f4             	push   -0xc(%ebp)
80108b90:	e8 5a ff ff ff       	call   80108aef <pci_write_config>
80108b95:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108b98:	e8 74 ff ff ff       	call   80108b11 <pci_read_config>
80108b9d:	8b 55 18             	mov    0x18(%ebp),%edx
80108ba0:	89 02                	mov    %eax,(%edx)
}
80108ba2:	90                   	nop
80108ba3:	c9                   	leave  
80108ba4:	c3                   	ret    

80108ba5 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108ba5:	55                   	push   %ebp
80108ba6:	89 e5                	mov    %esp,%ebp
80108ba8:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108bab:	8b 45 08             	mov    0x8(%ebp),%eax
80108bae:	c1 e0 10             	shl    $0x10,%eax
80108bb1:	25 00 00 ff 00       	and    $0xff0000,%eax
80108bb6:	89 c2                	mov    %eax,%edx
80108bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bbb:	c1 e0 0b             	shl    $0xb,%eax
80108bbe:	0f b7 c0             	movzwl %ax,%eax
80108bc1:	09 c2                	or     %eax,%edx
80108bc3:	8b 45 10             	mov    0x10(%ebp),%eax
80108bc6:	c1 e0 08             	shl    $0x8,%eax
80108bc9:	25 00 07 00 00       	and    $0x700,%eax
80108bce:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108bd0:	8b 45 14             	mov    0x14(%ebp),%eax
80108bd3:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108bd8:	09 d0                	or     %edx,%eax
80108bda:	0d 00 00 00 80       	or     $0x80000000,%eax
80108bdf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108be2:	ff 75 fc             	push   -0x4(%ebp)
80108be5:	e8 05 ff ff ff       	call   80108aef <pci_write_config>
80108bea:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108bed:	ff 75 18             	push   0x18(%ebp)
80108bf0:	e8 0b ff ff ff       	call   80108b00 <pci_write_data>
80108bf5:	83 c4 04             	add    $0x4,%esp
}
80108bf8:	90                   	nop
80108bf9:	c9                   	leave  
80108bfa:	c3                   	ret    

80108bfb <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108bfb:	55                   	push   %ebp
80108bfc:	89 e5                	mov    %esp,%ebp
80108bfe:	53                   	push   %ebx
80108bff:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108c02:	8b 45 08             	mov    0x8(%ebp),%eax
80108c05:	a2 b4 a5 11 80       	mov    %al,0x8011a5b4
  dev.device_num = device_num;
80108c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c0d:	a2 b5 a5 11 80       	mov    %al,0x8011a5b5
  dev.function_num = function_num;
80108c12:	8b 45 10             	mov    0x10(%ebp),%eax
80108c15:	a2 b6 a5 11 80       	mov    %al,0x8011a5b6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108c1a:	ff 75 10             	push   0x10(%ebp)
80108c1d:	ff 75 0c             	push   0xc(%ebp)
80108c20:	ff 75 08             	push   0x8(%ebp)
80108c23:	68 84 c7 10 80       	push   $0x8010c784
80108c28:	e8 c7 77 ff ff       	call   801003f4 <cprintf>
80108c2d:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108c30:	83 ec 0c             	sub    $0xc,%esp
80108c33:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c36:	50                   	push   %eax
80108c37:	6a 00                	push   $0x0
80108c39:	ff 75 10             	push   0x10(%ebp)
80108c3c:	ff 75 0c             	push   0xc(%ebp)
80108c3f:	ff 75 08             	push   0x8(%ebp)
80108c42:	e8 09 ff ff ff       	call   80108b50 <pci_access_config>
80108c47:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108c4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c4d:	c1 e8 10             	shr    $0x10,%eax
80108c50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c56:	25 ff ff 00 00       	and    $0xffff,%eax
80108c5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c61:	a3 b8 a5 11 80       	mov    %eax,0x8011a5b8
  dev.vendor_id = vendor_id;
80108c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c69:	a3 bc a5 11 80       	mov    %eax,0x8011a5bc
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108c6e:	83 ec 04             	sub    $0x4,%esp
80108c71:	ff 75 f0             	push   -0x10(%ebp)
80108c74:	ff 75 f4             	push   -0xc(%ebp)
80108c77:	68 b8 c7 10 80       	push   $0x8010c7b8
80108c7c:	e8 73 77 ff ff       	call   801003f4 <cprintf>
80108c81:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108c84:	83 ec 0c             	sub    $0xc,%esp
80108c87:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c8a:	50                   	push   %eax
80108c8b:	6a 08                	push   $0x8
80108c8d:	ff 75 10             	push   0x10(%ebp)
80108c90:	ff 75 0c             	push   0xc(%ebp)
80108c93:	ff 75 08             	push   0x8(%ebp)
80108c96:	e8 b5 fe ff ff       	call   80108b50 <pci_access_config>
80108c9b:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108c9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ca1:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108ca4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ca7:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108caa:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108cad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cb0:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108cb3:	0f b6 c0             	movzbl %al,%eax
80108cb6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108cb9:	c1 eb 18             	shr    $0x18,%ebx
80108cbc:	83 ec 0c             	sub    $0xc,%esp
80108cbf:	51                   	push   %ecx
80108cc0:	52                   	push   %edx
80108cc1:	50                   	push   %eax
80108cc2:	53                   	push   %ebx
80108cc3:	68 dc c7 10 80       	push   $0x8010c7dc
80108cc8:	e8 27 77 ff ff       	call   801003f4 <cprintf>
80108ccd:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108cd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cd3:	c1 e8 18             	shr    $0x18,%eax
80108cd6:	a2 c0 a5 11 80       	mov    %al,0x8011a5c0
  dev.sub_class = (data>>16)&0xFF;
80108cdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cde:	c1 e8 10             	shr    $0x10,%eax
80108ce1:	a2 c1 a5 11 80       	mov    %al,0x8011a5c1
  dev.interface = (data>>8)&0xFF;
80108ce6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ce9:	c1 e8 08             	shr    $0x8,%eax
80108cec:	a2 c2 a5 11 80       	mov    %al,0x8011a5c2
  dev.revision_id = data&0xFF;
80108cf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cf4:	a2 c3 a5 11 80       	mov    %al,0x8011a5c3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108cf9:	83 ec 0c             	sub    $0xc,%esp
80108cfc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108cff:	50                   	push   %eax
80108d00:	6a 10                	push   $0x10
80108d02:	ff 75 10             	push   0x10(%ebp)
80108d05:	ff 75 0c             	push   0xc(%ebp)
80108d08:	ff 75 08             	push   0x8(%ebp)
80108d0b:	e8 40 fe ff ff       	call   80108b50 <pci_access_config>
80108d10:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108d13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d16:	a3 c4 a5 11 80       	mov    %eax,0x8011a5c4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108d1b:	83 ec 0c             	sub    $0xc,%esp
80108d1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d21:	50                   	push   %eax
80108d22:	6a 14                	push   $0x14
80108d24:	ff 75 10             	push   0x10(%ebp)
80108d27:	ff 75 0c             	push   0xc(%ebp)
80108d2a:	ff 75 08             	push   0x8(%ebp)
80108d2d:	e8 1e fe ff ff       	call   80108b50 <pci_access_config>
80108d32:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108d35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d38:	a3 c8 a5 11 80       	mov    %eax,0x8011a5c8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108d3d:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108d44:	75 5a                	jne    80108da0 <pci_init_device+0x1a5>
80108d46:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108d4d:	75 51                	jne    80108da0 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108d4f:	83 ec 0c             	sub    $0xc,%esp
80108d52:	68 21 c8 10 80       	push   $0x8010c821
80108d57:	e8 98 76 ff ff       	call   801003f4 <cprintf>
80108d5c:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108d5f:	83 ec 0c             	sub    $0xc,%esp
80108d62:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d65:	50                   	push   %eax
80108d66:	68 f0 00 00 00       	push   $0xf0
80108d6b:	ff 75 10             	push   0x10(%ebp)
80108d6e:	ff 75 0c             	push   0xc(%ebp)
80108d71:	ff 75 08             	push   0x8(%ebp)
80108d74:	e8 d7 fd ff ff       	call   80108b50 <pci_access_config>
80108d79:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108d7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d7f:	83 ec 08             	sub    $0x8,%esp
80108d82:	50                   	push   %eax
80108d83:	68 3b c8 10 80       	push   $0x8010c83b
80108d88:	e8 67 76 ff ff       	call   801003f4 <cprintf>
80108d8d:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108d90:	83 ec 0c             	sub    $0xc,%esp
80108d93:	68 b4 a5 11 80       	push   $0x8011a5b4
80108d98:	e8 09 00 00 00       	call   80108da6 <i8254_init>
80108d9d:	83 c4 10             	add    $0x10,%esp
  }
}
80108da0:	90                   	nop
80108da1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108da4:	c9                   	leave  
80108da5:	c3                   	ret    

80108da6 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108da6:	55                   	push   %ebp
80108da7:	89 e5                	mov    %esp,%ebp
80108da9:	53                   	push   %ebx
80108daa:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108dad:	8b 45 08             	mov    0x8(%ebp),%eax
80108db0:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108db4:	0f b6 c8             	movzbl %al,%ecx
80108db7:	8b 45 08             	mov    0x8(%ebp),%eax
80108dba:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108dbe:	0f b6 d0             	movzbl %al,%edx
80108dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80108dc4:	0f b6 00             	movzbl (%eax),%eax
80108dc7:	0f b6 c0             	movzbl %al,%eax
80108dca:	83 ec 0c             	sub    $0xc,%esp
80108dcd:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108dd0:	53                   	push   %ebx
80108dd1:	6a 04                	push   $0x4
80108dd3:	51                   	push   %ecx
80108dd4:	52                   	push   %edx
80108dd5:	50                   	push   %eax
80108dd6:	e8 75 fd ff ff       	call   80108b50 <pci_access_config>
80108ddb:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108dde:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108de1:	83 c8 04             	or     $0x4,%eax
80108de4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108de7:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108dea:	8b 45 08             	mov    0x8(%ebp),%eax
80108ded:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108df1:	0f b6 c8             	movzbl %al,%ecx
80108df4:	8b 45 08             	mov    0x8(%ebp),%eax
80108df7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108dfb:	0f b6 d0             	movzbl %al,%edx
80108dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80108e01:	0f b6 00             	movzbl (%eax),%eax
80108e04:	0f b6 c0             	movzbl %al,%eax
80108e07:	83 ec 0c             	sub    $0xc,%esp
80108e0a:	53                   	push   %ebx
80108e0b:	6a 04                	push   $0x4
80108e0d:	51                   	push   %ecx
80108e0e:	52                   	push   %edx
80108e0f:	50                   	push   %eax
80108e10:	e8 90 fd ff ff       	call   80108ba5 <pci_write_config_register>
80108e15:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108e18:	8b 45 08             	mov    0x8(%ebp),%eax
80108e1b:	8b 40 10             	mov    0x10(%eax),%eax
80108e1e:	05 00 00 00 40       	add    $0x40000000,%eax
80108e23:	a3 cc a5 11 80       	mov    %eax,0x8011a5cc
  uint *ctrl = (uint *)base_addr;
80108e28:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108e2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108e30:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108e35:	05 d8 00 00 00       	add    $0xd8,%eax
80108e3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e40:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e49:	8b 00                	mov    (%eax),%eax
80108e4b:	0d 00 00 00 04       	or     $0x4000000,%eax
80108e50:	89 c2                	mov    %eax,%edx
80108e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e55:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e5a:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e63:	8b 00                	mov    (%eax),%eax
80108e65:	83 c8 40             	or     $0x40,%eax
80108e68:	89 c2                	mov    %eax,%edx
80108e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6d:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e72:	8b 10                	mov    (%eax),%edx
80108e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e77:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108e79:	83 ec 0c             	sub    $0xc,%esp
80108e7c:	68 50 c8 10 80       	push   $0x8010c850
80108e81:	e8 6e 75 ff ff       	call   801003f4 <cprintf>
80108e86:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108e89:	e8 f6 9d ff ff       	call   80102c84 <kalloc>
80108e8e:	a3 d8 a5 11 80       	mov    %eax,0x8011a5d8
  *intr_addr = 0;
80108e93:	a1 d8 a5 11 80       	mov    0x8011a5d8,%eax
80108e98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108e9e:	a1 d8 a5 11 80       	mov    0x8011a5d8,%eax
80108ea3:	83 ec 08             	sub    $0x8,%esp
80108ea6:	50                   	push   %eax
80108ea7:	68 72 c8 10 80       	push   $0x8010c872
80108eac:	e8 43 75 ff ff       	call   801003f4 <cprintf>
80108eb1:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108eb4:	e8 50 00 00 00       	call   80108f09 <i8254_init_recv>
  i8254_init_send();
80108eb9:	e8 69 03 00 00       	call   80109227 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108ebe:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ec5:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108ec8:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ecf:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108ed2:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ed9:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108edc:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ee3:	0f b6 c0             	movzbl %al,%eax
80108ee6:	83 ec 0c             	sub    $0xc,%esp
80108ee9:	53                   	push   %ebx
80108eea:	51                   	push   %ecx
80108eeb:	52                   	push   %edx
80108eec:	50                   	push   %eax
80108eed:	68 80 c8 10 80       	push   $0x8010c880
80108ef2:	e8 fd 74 ff ff       	call   801003f4 <cprintf>
80108ef7:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108efd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108f03:	90                   	nop
80108f04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f07:	c9                   	leave  
80108f08:	c3                   	ret    

80108f09 <i8254_init_recv>:

void i8254_init_recv(){
80108f09:	55                   	push   %ebp
80108f0a:	89 e5                	mov    %esp,%ebp
80108f0c:	57                   	push   %edi
80108f0d:	56                   	push   %esi
80108f0e:	53                   	push   %ebx
80108f0f:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108f12:	83 ec 0c             	sub    $0xc,%esp
80108f15:	6a 00                	push   $0x0
80108f17:	e8 e8 04 00 00       	call   80109404 <i8254_read_eeprom>
80108f1c:	83 c4 10             	add    $0x10,%esp
80108f1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108f22:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108f25:	a2 d0 a5 11 80       	mov    %al,0x8011a5d0
  mac_addr[1] = data_l>>8;
80108f2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108f2d:	c1 e8 08             	shr    $0x8,%eax
80108f30:	a2 d1 a5 11 80       	mov    %al,0x8011a5d1
  uint data_m = i8254_read_eeprom(0x1);
80108f35:	83 ec 0c             	sub    $0xc,%esp
80108f38:	6a 01                	push   $0x1
80108f3a:	e8 c5 04 00 00       	call   80109404 <i8254_read_eeprom>
80108f3f:	83 c4 10             	add    $0x10,%esp
80108f42:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108f45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f48:	a2 d2 a5 11 80       	mov    %al,0x8011a5d2
  mac_addr[3] = data_m>>8;
80108f4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f50:	c1 e8 08             	shr    $0x8,%eax
80108f53:	a2 d3 a5 11 80       	mov    %al,0x8011a5d3
  uint data_h = i8254_read_eeprom(0x2);
80108f58:	83 ec 0c             	sub    $0xc,%esp
80108f5b:	6a 02                	push   $0x2
80108f5d:	e8 a2 04 00 00       	call   80109404 <i8254_read_eeprom>
80108f62:	83 c4 10             	add    $0x10,%esp
80108f65:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108f68:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f6b:	a2 d4 a5 11 80       	mov    %al,0x8011a5d4
  mac_addr[5] = data_h>>8;
80108f70:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f73:	c1 e8 08             	shr    $0x8,%eax
80108f76:	a2 d5 a5 11 80       	mov    %al,0x8011a5d5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108f7b:	0f b6 05 d5 a5 11 80 	movzbl 0x8011a5d5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f82:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108f85:	0f b6 05 d4 a5 11 80 	movzbl 0x8011a5d4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f8c:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108f8f:	0f b6 05 d3 a5 11 80 	movzbl 0x8011a5d3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f96:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108f99:	0f b6 05 d2 a5 11 80 	movzbl 0x8011a5d2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108fa0:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108fa3:	0f b6 05 d1 a5 11 80 	movzbl 0x8011a5d1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108faa:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108fad:	0f b6 05 d0 a5 11 80 	movzbl 0x8011a5d0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108fb4:	0f b6 c0             	movzbl %al,%eax
80108fb7:	83 ec 04             	sub    $0x4,%esp
80108fba:	57                   	push   %edi
80108fbb:	56                   	push   %esi
80108fbc:	53                   	push   %ebx
80108fbd:	51                   	push   %ecx
80108fbe:	52                   	push   %edx
80108fbf:	50                   	push   %eax
80108fc0:	68 98 c8 10 80       	push   $0x8010c898
80108fc5:	e8 2a 74 ff ff       	call   801003f4 <cprintf>
80108fca:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108fcd:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108fd2:	05 00 54 00 00       	add    $0x5400,%eax
80108fd7:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108fda:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80108fdf:	05 04 54 00 00       	add    $0x5404,%eax
80108fe4:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108fe7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108fea:	c1 e0 10             	shl    $0x10,%eax
80108fed:	0b 45 d8             	or     -0x28(%ebp),%eax
80108ff0:	89 c2                	mov    %eax,%edx
80108ff2:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108ff5:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108ff7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ffa:	0d 00 00 00 80       	or     $0x80000000,%eax
80108fff:	89 c2                	mov    %eax,%edx
80109001:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109004:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80109006:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010900b:	05 00 52 00 00       	add    $0x5200,%eax
80109010:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80109013:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010901a:	eb 19                	jmp    80109035 <i8254_init_recv+0x12c>
    mta[i] = 0;
8010901c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010901f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109026:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109029:	01 d0                	add    %edx,%eax
8010902b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80109031:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80109035:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80109039:	7e e1                	jle    8010901c <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
8010903b:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109040:	05 d0 00 00 00       	add    $0xd0,%eax
80109045:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109048:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010904b:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80109051:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109056:	05 c8 00 00 00       	add    $0xc8,%eax
8010905b:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010905e:	8b 45 bc             	mov    -0x44(%ebp),%eax
80109061:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80109067:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010906c:	05 28 28 00 00       	add    $0x2828,%eax
80109071:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80109074:	8b 45 b8             	mov    -0x48(%ebp),%eax
80109077:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
8010907d:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109082:	05 00 01 00 00       	add    $0x100,%eax
80109087:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010908a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010908d:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80109093:	e8 ec 9b ff ff       	call   80102c84 <kalloc>
80109098:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010909b:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801090a0:	05 00 28 00 00       	add    $0x2800,%eax
801090a5:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801090a8:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801090ad:	05 04 28 00 00       	add    $0x2804,%eax
801090b2:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801090b5:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801090ba:	05 08 28 00 00       	add    $0x2808,%eax
801090bf:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801090c2:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801090c7:	05 10 28 00 00       	add    $0x2810,%eax
801090cc:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801090cf:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801090d4:	05 18 28 00 00       	add    $0x2818,%eax
801090d9:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801090dc:	8b 45 b0             	mov    -0x50(%ebp),%eax
801090df:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801090e5:	8b 45 ac             	mov    -0x54(%ebp),%eax
801090e8:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801090ea:	8b 45 a8             	mov    -0x58(%ebp),%eax
801090ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801090f3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801090f6:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801090fc:	8b 45 a0             	mov    -0x60(%ebp),%eax
801090ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80109105:	8b 45 9c             	mov    -0x64(%ebp),%eax
80109108:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
8010910e:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109111:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109114:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010911b:	eb 73                	jmp    80109190 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
8010911d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109120:	c1 e0 04             	shl    $0x4,%eax
80109123:	89 c2                	mov    %eax,%edx
80109125:	8b 45 98             	mov    -0x68(%ebp),%eax
80109128:	01 d0                	add    %edx,%eax
8010912a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80109131:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109134:	c1 e0 04             	shl    $0x4,%eax
80109137:	89 c2                	mov    %eax,%edx
80109139:	8b 45 98             	mov    -0x68(%ebp),%eax
8010913c:	01 d0                	add    %edx,%eax
8010913e:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80109144:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109147:	c1 e0 04             	shl    $0x4,%eax
8010914a:	89 c2                	mov    %eax,%edx
8010914c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010914f:	01 d0                	add    %edx,%eax
80109151:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80109157:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010915a:	c1 e0 04             	shl    $0x4,%eax
8010915d:	89 c2                	mov    %eax,%edx
8010915f:	8b 45 98             	mov    -0x68(%ebp),%eax
80109162:	01 d0                	add    %edx,%eax
80109164:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80109168:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010916b:	c1 e0 04             	shl    $0x4,%eax
8010916e:	89 c2                	mov    %eax,%edx
80109170:	8b 45 98             	mov    -0x68(%ebp),%eax
80109173:	01 d0                	add    %edx,%eax
80109175:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109179:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010917c:	c1 e0 04             	shl    $0x4,%eax
8010917f:	89 c2                	mov    %eax,%edx
80109181:	8b 45 98             	mov    -0x68(%ebp),%eax
80109184:	01 d0                	add    %edx,%eax
80109186:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010918c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109190:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109197:	7e 84                	jle    8010911d <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109199:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801091a0:	eb 57                	jmp    801091f9 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
801091a2:	e8 dd 9a ff ff       	call   80102c84 <kalloc>
801091a7:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801091aa:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801091ae:	75 12                	jne    801091c2 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
801091b0:	83 ec 0c             	sub    $0xc,%esp
801091b3:	68 b8 c8 10 80       	push   $0x8010c8b8
801091b8:	e8 37 72 ff ff       	call   801003f4 <cprintf>
801091bd:	83 c4 10             	add    $0x10,%esp
      break;
801091c0:	eb 3d                	jmp    801091ff <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
801091c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801091c5:	c1 e0 04             	shl    $0x4,%eax
801091c8:	89 c2                	mov    %eax,%edx
801091ca:	8b 45 98             	mov    -0x68(%ebp),%eax
801091cd:	01 d0                	add    %edx,%eax
801091cf:	8b 55 94             	mov    -0x6c(%ebp),%edx
801091d2:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801091d8:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801091da:	8b 45 dc             	mov    -0x24(%ebp),%eax
801091dd:	83 c0 01             	add    $0x1,%eax
801091e0:	c1 e0 04             	shl    $0x4,%eax
801091e3:	89 c2                	mov    %eax,%edx
801091e5:	8b 45 98             	mov    -0x68(%ebp),%eax
801091e8:	01 d0                	add    %edx,%eax
801091ea:	8b 55 94             	mov    -0x6c(%ebp),%edx
801091ed:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801091f3:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801091f5:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801091f9:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801091fd:	7e a3                	jle    801091a2 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801091ff:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109202:	8b 00                	mov    (%eax),%eax
80109204:	83 c8 02             	or     $0x2,%eax
80109207:	89 c2                	mov    %eax,%edx
80109209:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010920c:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
8010920e:	83 ec 0c             	sub    $0xc,%esp
80109211:	68 d8 c8 10 80       	push   $0x8010c8d8
80109216:	e8 d9 71 ff ff       	call   801003f4 <cprintf>
8010921b:	83 c4 10             	add    $0x10,%esp
}
8010921e:	90                   	nop
8010921f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109222:	5b                   	pop    %ebx
80109223:	5e                   	pop    %esi
80109224:	5f                   	pop    %edi
80109225:	5d                   	pop    %ebp
80109226:	c3                   	ret    

80109227 <i8254_init_send>:

void i8254_init_send(){
80109227:	55                   	push   %ebp
80109228:	89 e5                	mov    %esp,%ebp
8010922a:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
8010922d:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109232:	05 28 38 00 00       	add    $0x3828,%eax
80109237:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010923a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010923d:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80109243:	e8 3c 9a ff ff       	call   80102c84 <kalloc>
80109248:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010924b:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109250:	05 00 38 00 00       	add    $0x3800,%eax
80109255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80109258:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010925d:	05 04 38 00 00       	add    $0x3804,%eax
80109262:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80109265:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010926a:	05 08 38 00 00       	add    $0x3808,%eax
8010926f:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80109272:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109275:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010927b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010927e:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109280:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109283:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109289:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010928c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80109292:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109297:	05 10 38 00 00       	add    $0x3810,%eax
8010929c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010929f:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801092a4:	05 18 38 00 00       	add    $0x3818,%eax
801092a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
801092ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
801092af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
801092b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801092b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
801092be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801092c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801092cb:	e9 82 00 00 00       	jmp    80109352 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
801092d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d3:	c1 e0 04             	shl    $0x4,%eax
801092d6:	89 c2                	mov    %eax,%edx
801092d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092db:	01 d0                	add    %edx,%eax
801092dd:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801092e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e7:	c1 e0 04             	shl    $0x4,%eax
801092ea:	89 c2                	mov    %eax,%edx
801092ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092ef:	01 d0                	add    %edx,%eax
801092f1:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801092f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092fa:	c1 e0 04             	shl    $0x4,%eax
801092fd:	89 c2                	mov    %eax,%edx
801092ff:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109302:	01 d0                	add    %edx,%eax
80109304:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80109308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930b:	c1 e0 04             	shl    $0x4,%eax
8010930e:	89 c2                	mov    %eax,%edx
80109310:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109313:	01 d0                	add    %edx,%eax
80109315:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80109319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010931c:	c1 e0 04             	shl    $0x4,%eax
8010931f:	89 c2                	mov    %eax,%edx
80109321:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109324:	01 d0                	add    %edx,%eax
80109326:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
8010932a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932d:	c1 e0 04             	shl    $0x4,%eax
80109330:	89 c2                	mov    %eax,%edx
80109332:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109335:	01 d0                	add    %edx,%eax
80109337:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
8010933b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010933e:	c1 e0 04             	shl    $0x4,%eax
80109341:	89 c2                	mov    %eax,%edx
80109343:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109346:	01 d0                	add    %edx,%eax
80109348:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010934e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109352:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109359:	0f 8e 71 ff ff ff    	jle    801092d0 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010935f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109366:	eb 57                	jmp    801093bf <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80109368:	e8 17 99 ff ff       	call   80102c84 <kalloc>
8010936d:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109370:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109374:	75 12                	jne    80109388 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80109376:	83 ec 0c             	sub    $0xc,%esp
80109379:	68 b8 c8 10 80       	push   $0x8010c8b8
8010937e:	e8 71 70 ff ff       	call   801003f4 <cprintf>
80109383:	83 c4 10             	add    $0x10,%esp
      break;
80109386:	eb 3d                	jmp    801093c5 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010938b:	c1 e0 04             	shl    $0x4,%eax
8010938e:	89 c2                	mov    %eax,%edx
80109390:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109393:	01 d0                	add    %edx,%eax
80109395:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109398:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010939e:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801093a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093a3:	83 c0 01             	add    $0x1,%eax
801093a6:	c1 e0 04             	shl    $0x4,%eax
801093a9:	89 c2                	mov    %eax,%edx
801093ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093ae:	01 d0                	add    %edx,%eax
801093b0:	8b 55 cc             	mov    -0x34(%ebp),%edx
801093b3:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801093b9:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801093bb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801093bf:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801093c3:	7e a3                	jle    80109368 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801093c5:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801093ca:	05 00 04 00 00       	add    $0x400,%eax
801093cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801093d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
801093d5:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801093db:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
801093e0:	05 10 04 00 00       	add    $0x410,%eax
801093e5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801093e8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801093eb:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801093f1:	83 ec 0c             	sub    $0xc,%esp
801093f4:	68 f8 c8 10 80       	push   $0x8010c8f8
801093f9:	e8 f6 6f ff ff       	call   801003f4 <cprintf>
801093fe:	83 c4 10             	add    $0x10,%esp

}
80109401:	90                   	nop
80109402:	c9                   	leave  
80109403:	c3                   	ret    

80109404 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109404:	55                   	push   %ebp
80109405:	89 e5                	mov    %esp,%ebp
80109407:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
8010940a:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010940f:	83 c0 14             	add    $0x14,%eax
80109412:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80109415:	8b 45 08             	mov    0x8(%ebp),%eax
80109418:	c1 e0 08             	shl    $0x8,%eax
8010941b:	0f b7 c0             	movzwl %ax,%eax
8010941e:	83 c8 01             	or     $0x1,%eax
80109421:	89 c2                	mov    %eax,%edx
80109423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109426:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80109428:	83 ec 0c             	sub    $0xc,%esp
8010942b:	68 18 c9 10 80       	push   $0x8010c918
80109430:	e8 bf 6f ff ff       	call   801003f4 <cprintf>
80109435:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80109438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010943b:	8b 00                	mov    (%eax),%eax
8010943d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109443:	83 e0 10             	and    $0x10,%eax
80109446:	85 c0                	test   %eax,%eax
80109448:	75 02                	jne    8010944c <i8254_read_eeprom+0x48>
  while(1){
8010944a:	eb dc                	jmp    80109428 <i8254_read_eeprom+0x24>
      break;
8010944c:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
8010944d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109450:	8b 00                	mov    (%eax),%eax
80109452:	c1 e8 10             	shr    $0x10,%eax
}
80109455:	c9                   	leave  
80109456:	c3                   	ret    

80109457 <i8254_recv>:
void i8254_recv(){
80109457:	55                   	push   %ebp
80109458:	89 e5                	mov    %esp,%ebp
8010945a:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
8010945d:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109462:	05 10 28 00 00       	add    $0x2810,%eax
80109467:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010946a:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010946f:	05 18 28 00 00       	add    $0x2818,%eax
80109474:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109477:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010947c:	05 00 28 00 00       	add    $0x2800,%eax
80109481:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109484:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109487:	8b 00                	mov    (%eax),%eax
80109489:	05 00 00 00 80       	add    $0x80000000,%eax
8010948e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109494:	8b 10                	mov    (%eax),%edx
80109496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109499:	8b 08                	mov    (%eax),%ecx
8010949b:	89 d0                	mov    %edx,%eax
8010949d:	29 c8                	sub    %ecx,%eax
8010949f:	25 ff 00 00 00       	and    $0xff,%eax
801094a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801094a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801094ab:	7e 37                	jle    801094e4 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801094ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094b0:	8b 00                	mov    (%eax),%eax
801094b2:	c1 e0 04             	shl    $0x4,%eax
801094b5:	89 c2                	mov    %eax,%edx
801094b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094ba:	01 d0                	add    %edx,%eax
801094bc:	8b 00                	mov    (%eax),%eax
801094be:	05 00 00 00 80       	add    $0x80000000,%eax
801094c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801094c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094c9:	8b 00                	mov    (%eax),%eax
801094cb:	83 c0 01             	add    $0x1,%eax
801094ce:	0f b6 d0             	movzbl %al,%edx
801094d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094d4:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801094d6:	83 ec 0c             	sub    $0xc,%esp
801094d9:	ff 75 e0             	push   -0x20(%ebp)
801094dc:	e8 15 09 00 00       	call   80109df6 <eth_proc>
801094e1:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801094e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094e7:	8b 10                	mov    (%eax),%edx
801094e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ec:	8b 00                	mov    (%eax),%eax
801094ee:	39 c2                	cmp    %eax,%edx
801094f0:	75 9f                	jne    80109491 <i8254_recv+0x3a>
      (*rdt)--;
801094f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094f5:	8b 00                	mov    (%eax),%eax
801094f7:	8d 50 ff             	lea    -0x1(%eax),%edx
801094fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094fd:	89 10                	mov    %edx,(%eax)
  while(1){
801094ff:	eb 90                	jmp    80109491 <i8254_recv+0x3a>

80109501 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109501:	55                   	push   %ebp
80109502:	89 e5                	mov    %esp,%ebp
80109504:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109507:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
8010950c:	05 10 38 00 00       	add    $0x3810,%eax
80109511:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109514:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109519:	05 18 38 00 00       	add    $0x3818,%eax
8010951e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109521:	a1 cc a5 11 80       	mov    0x8011a5cc,%eax
80109526:	05 00 38 00 00       	add    $0x3800,%eax
8010952b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010952e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109531:	8b 00                	mov    (%eax),%eax
80109533:	05 00 00 00 80       	add    $0x80000000,%eax
80109538:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
8010953b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010953e:	8b 10                	mov    (%eax),%edx
80109540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109543:	8b 08                	mov    (%eax),%ecx
80109545:	89 d0                	mov    %edx,%eax
80109547:	29 c8                	sub    %ecx,%eax
80109549:	0f b6 d0             	movzbl %al,%edx
8010954c:	b8 00 01 00 00       	mov    $0x100,%eax
80109551:	29 d0                	sub    %edx,%eax
80109553:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109559:	8b 00                	mov    (%eax),%eax
8010955b:	25 ff 00 00 00       	and    $0xff,%eax
80109560:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109563:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109567:	0f 8e a8 00 00 00    	jle    80109615 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010956d:	8b 45 08             	mov    0x8(%ebp),%eax
80109570:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109573:	89 d1                	mov    %edx,%ecx
80109575:	c1 e1 04             	shl    $0x4,%ecx
80109578:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010957b:	01 ca                	add    %ecx,%edx
8010957d:	8b 12                	mov    (%edx),%edx
8010957f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109585:	83 ec 04             	sub    $0x4,%esp
80109588:	ff 75 0c             	push   0xc(%ebp)
8010958b:	50                   	push   %eax
8010958c:	52                   	push   %edx
8010958d:	e8 27 be ff ff       	call   801053b9 <memmove>
80109592:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109595:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109598:	c1 e0 04             	shl    $0x4,%eax
8010959b:	89 c2                	mov    %eax,%edx
8010959d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095a0:	01 d0                	add    %edx,%eax
801095a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801095a5:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801095a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095ac:	c1 e0 04             	shl    $0x4,%eax
801095af:	89 c2                	mov    %eax,%edx
801095b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095b4:	01 d0                	add    %edx,%eax
801095b6:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801095ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095bd:	c1 e0 04             	shl    $0x4,%eax
801095c0:	89 c2                	mov    %eax,%edx
801095c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095c5:	01 d0                	add    %edx,%eax
801095c7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801095cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095ce:	c1 e0 04             	shl    $0x4,%eax
801095d1:	89 c2                	mov    %eax,%edx
801095d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095d6:	01 d0                	add    %edx,%eax
801095d8:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801095dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095df:	c1 e0 04             	shl    $0x4,%eax
801095e2:	89 c2                	mov    %eax,%edx
801095e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095e7:	01 d0                	add    %edx,%eax
801095e9:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801095ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095f2:	c1 e0 04             	shl    $0x4,%eax
801095f5:	89 c2                	mov    %eax,%edx
801095f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095fa:	01 d0                	add    %edx,%eax
801095fc:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109600:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109603:	8b 00                	mov    (%eax),%eax
80109605:	83 c0 01             	add    $0x1,%eax
80109608:	0f b6 d0             	movzbl %al,%edx
8010960b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960e:	89 10                	mov    %edx,(%eax)
    return len;
80109610:	8b 45 0c             	mov    0xc(%ebp),%eax
80109613:	eb 05                	jmp    8010961a <i8254_send+0x119>
  }else{
    return -1;
80109615:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010961a:	c9                   	leave  
8010961b:	c3                   	ret    

8010961c <i8254_intr>:

void i8254_intr(){
8010961c:	55                   	push   %ebp
8010961d:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
8010961f:	a1 d8 a5 11 80       	mov    0x8011a5d8,%eax
80109624:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010962a:	90                   	nop
8010962b:	5d                   	pop    %ebp
8010962c:	c3                   	ret    

8010962d <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
8010962d:	55                   	push   %ebp
8010962e:	89 e5                	mov    %esp,%ebp
80109630:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109633:	8b 45 08             	mov    0x8(%ebp),%eax
80109636:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010963c:	0f b7 00             	movzwl (%eax),%eax
8010963f:	66 3d 00 01          	cmp    $0x100,%ax
80109643:	74 0a                	je     8010964f <arp_proc+0x22>
80109645:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010964a:	e9 4f 01 00 00       	jmp    8010979e <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
8010964f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109652:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109656:	66 83 f8 08          	cmp    $0x8,%ax
8010965a:	74 0a                	je     80109666 <arp_proc+0x39>
8010965c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109661:	e9 38 01 00 00       	jmp    8010979e <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109669:	0f b6 40 04          	movzbl 0x4(%eax),%eax
8010966d:	3c 06                	cmp    $0x6,%al
8010966f:	74 0a                	je     8010967b <arp_proc+0x4e>
80109671:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109676:	e9 23 01 00 00       	jmp    8010979e <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
8010967b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010967e:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109682:	3c 04                	cmp    $0x4,%al
80109684:	74 0a                	je     80109690 <arp_proc+0x63>
80109686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010968b:	e9 0e 01 00 00       	jmp    8010979e <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109693:	83 c0 18             	add    $0x18,%eax
80109696:	83 ec 04             	sub    $0x4,%esp
80109699:	6a 04                	push   $0x4
8010969b:	50                   	push   %eax
8010969c:	68 e4 f4 10 80       	push   $0x8010f4e4
801096a1:	e8 bb bc ff ff       	call   80105361 <memcmp>
801096a6:	83 c4 10             	add    $0x10,%esp
801096a9:	85 c0                	test   %eax,%eax
801096ab:	74 27                	je     801096d4 <arp_proc+0xa7>
801096ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b0:	83 c0 0e             	add    $0xe,%eax
801096b3:	83 ec 04             	sub    $0x4,%esp
801096b6:	6a 04                	push   $0x4
801096b8:	50                   	push   %eax
801096b9:	68 e4 f4 10 80       	push   $0x8010f4e4
801096be:	e8 9e bc ff ff       	call   80105361 <memcmp>
801096c3:	83 c4 10             	add    $0x10,%esp
801096c6:	85 c0                	test   %eax,%eax
801096c8:	74 0a                	je     801096d4 <arp_proc+0xa7>
801096ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801096cf:	e9 ca 00 00 00       	jmp    8010979e <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801096d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096d7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801096db:	66 3d 00 01          	cmp    $0x100,%ax
801096df:	75 69                	jne    8010974a <arp_proc+0x11d>
801096e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096e4:	83 c0 18             	add    $0x18,%eax
801096e7:	83 ec 04             	sub    $0x4,%esp
801096ea:	6a 04                	push   $0x4
801096ec:	50                   	push   %eax
801096ed:	68 e4 f4 10 80       	push   $0x8010f4e4
801096f2:	e8 6a bc ff ff       	call   80105361 <memcmp>
801096f7:	83 c4 10             	add    $0x10,%esp
801096fa:	85 c0                	test   %eax,%eax
801096fc:	75 4c                	jne    8010974a <arp_proc+0x11d>
    uint send = (uint)kalloc();
801096fe:	e8 81 95 ff ff       	call   80102c84 <kalloc>
80109703:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109706:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
8010970d:	83 ec 04             	sub    $0x4,%esp
80109710:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109713:	50                   	push   %eax
80109714:	ff 75 f0             	push   -0x10(%ebp)
80109717:	ff 75 f4             	push   -0xc(%ebp)
8010971a:	e8 1f 04 00 00       	call   80109b3e <arp_reply_pkt_create>
8010971f:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109722:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109725:	83 ec 08             	sub    $0x8,%esp
80109728:	50                   	push   %eax
80109729:	ff 75 f0             	push   -0x10(%ebp)
8010972c:	e8 d0 fd ff ff       	call   80109501 <i8254_send>
80109731:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109734:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109737:	83 ec 0c             	sub    $0xc,%esp
8010973a:	50                   	push   %eax
8010973b:	e8 aa 94 ff ff       	call   80102bea <kfree>
80109740:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109743:	b8 02 00 00 00       	mov    $0x2,%eax
80109748:	eb 54                	jmp    8010979e <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010974a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010974d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109751:	66 3d 00 02          	cmp    $0x200,%ax
80109755:	75 42                	jne    80109799 <arp_proc+0x16c>
80109757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010975a:	83 c0 18             	add    $0x18,%eax
8010975d:	83 ec 04             	sub    $0x4,%esp
80109760:	6a 04                	push   $0x4
80109762:	50                   	push   %eax
80109763:	68 e4 f4 10 80       	push   $0x8010f4e4
80109768:	e8 f4 bb ff ff       	call   80105361 <memcmp>
8010976d:	83 c4 10             	add    $0x10,%esp
80109770:	85 c0                	test   %eax,%eax
80109772:	75 25                	jne    80109799 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80109774:	83 ec 0c             	sub    $0xc,%esp
80109777:	68 1c c9 10 80       	push   $0x8010c91c
8010977c:	e8 73 6c ff ff       	call   801003f4 <cprintf>
80109781:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109784:	83 ec 0c             	sub    $0xc,%esp
80109787:	ff 75 f4             	push   -0xc(%ebp)
8010978a:	e8 af 01 00 00       	call   8010993e <arp_table_update>
8010978f:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109792:	b8 01 00 00 00       	mov    $0x1,%eax
80109797:	eb 05                	jmp    8010979e <arp_proc+0x171>
  }else{
    return -1;
80109799:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
8010979e:	c9                   	leave  
8010979f:	c3                   	ret    

801097a0 <arp_scan>:

void arp_scan(){
801097a0:	55                   	push   %ebp
801097a1:	89 e5                	mov    %esp,%ebp
801097a3:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801097a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801097ad:	eb 6f                	jmp    8010981e <arp_scan+0x7e>
    uint send = (uint)kalloc();
801097af:	e8 d0 94 ff ff       	call   80102c84 <kalloc>
801097b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801097b7:	83 ec 04             	sub    $0x4,%esp
801097ba:	ff 75 f4             	push   -0xc(%ebp)
801097bd:	8d 45 e8             	lea    -0x18(%ebp),%eax
801097c0:	50                   	push   %eax
801097c1:	ff 75 ec             	push   -0x14(%ebp)
801097c4:	e8 62 00 00 00       	call   8010982b <arp_broadcast>
801097c9:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801097cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097cf:	83 ec 08             	sub    $0x8,%esp
801097d2:	50                   	push   %eax
801097d3:	ff 75 ec             	push   -0x14(%ebp)
801097d6:	e8 26 fd ff ff       	call   80109501 <i8254_send>
801097db:	83 c4 10             	add    $0x10,%esp
801097de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801097e1:	eb 22                	jmp    80109805 <arp_scan+0x65>
      microdelay(1);
801097e3:	83 ec 0c             	sub    $0xc,%esp
801097e6:	6a 01                	push   $0x1
801097e8:	e8 2e 98 ff ff       	call   8010301b <microdelay>
801097ed:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801097f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097f3:	83 ec 08             	sub    $0x8,%esp
801097f6:	50                   	push   %eax
801097f7:	ff 75 ec             	push   -0x14(%ebp)
801097fa:	e8 02 fd ff ff       	call   80109501 <i8254_send>
801097ff:	83 c4 10             	add    $0x10,%esp
80109802:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109805:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109809:	74 d8                	je     801097e3 <arp_scan+0x43>
    }
    kfree((char *)send);
8010980b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010980e:	83 ec 0c             	sub    $0xc,%esp
80109811:	50                   	push   %eax
80109812:	e8 d3 93 ff ff       	call   80102bea <kfree>
80109817:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010981a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010981e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109825:	7e 88                	jle    801097af <arp_scan+0xf>
  }
}
80109827:	90                   	nop
80109828:	90                   	nop
80109829:	c9                   	leave  
8010982a:	c3                   	ret    

8010982b <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010982b:	55                   	push   %ebp
8010982c:	89 e5                	mov    %esp,%ebp
8010982e:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109831:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109835:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109839:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010983d:	8b 45 10             	mov    0x10(%ebp),%eax
80109840:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109843:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010984a:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109850:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109857:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010985d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109860:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109866:	8b 45 08             	mov    0x8(%ebp),%eax
80109869:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010986c:	8b 45 08             	mov    0x8(%ebp),%eax
8010986f:	83 c0 0e             	add    $0xe,%eax
80109872:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109878:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010987c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010987f:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109886:	83 ec 04             	sub    $0x4,%esp
80109889:	6a 06                	push   $0x6
8010988b:	8d 55 e6             	lea    -0x1a(%ebp),%edx
8010988e:	52                   	push   %edx
8010988f:	50                   	push   %eax
80109890:	e8 24 bb ff ff       	call   801053b9 <memmove>
80109895:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010989b:	83 c0 06             	add    $0x6,%eax
8010989e:	83 ec 04             	sub    $0x4,%esp
801098a1:	6a 06                	push   $0x6
801098a3:	68 d0 a5 11 80       	push   $0x8011a5d0
801098a8:	50                   	push   %eax
801098a9:	e8 0b bb ff ff       	call   801053b9 <memmove>
801098ae:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801098b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098b4:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801098b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098bc:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801098c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c5:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801098c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098cc:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801098d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d3:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801098d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098dc:	8d 50 12             	lea    0x12(%eax),%edx
801098df:	83 ec 04             	sub    $0x4,%esp
801098e2:	6a 06                	push   $0x6
801098e4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801098e7:	50                   	push   %eax
801098e8:	52                   	push   %edx
801098e9:	e8 cb ba ff ff       	call   801053b9 <memmove>
801098ee:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801098f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098f4:	8d 50 18             	lea    0x18(%eax),%edx
801098f7:	83 ec 04             	sub    $0x4,%esp
801098fa:	6a 04                	push   $0x4
801098fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801098ff:	50                   	push   %eax
80109900:	52                   	push   %edx
80109901:	e8 b3 ba ff ff       	call   801053b9 <memmove>
80109906:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109909:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010990c:	83 c0 08             	add    $0x8,%eax
8010990f:	83 ec 04             	sub    $0x4,%esp
80109912:	6a 06                	push   $0x6
80109914:	68 d0 a5 11 80       	push   $0x8011a5d0
80109919:	50                   	push   %eax
8010991a:	e8 9a ba ff ff       	call   801053b9 <memmove>
8010991f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109922:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109925:	83 c0 0e             	add    $0xe,%eax
80109928:	83 ec 04             	sub    $0x4,%esp
8010992b:	6a 04                	push   $0x4
8010992d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109932:	50                   	push   %eax
80109933:	e8 81 ba ff ff       	call   801053b9 <memmove>
80109938:	83 c4 10             	add    $0x10,%esp
}
8010993b:	90                   	nop
8010993c:	c9                   	leave  
8010993d:	c3                   	ret    

8010993e <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010993e:	55                   	push   %ebp
8010993f:	89 e5                	mov    %esp,%ebp
80109941:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109944:	8b 45 08             	mov    0x8(%ebp),%eax
80109947:	83 c0 0e             	add    $0xe,%eax
8010994a:	83 ec 0c             	sub    $0xc,%esp
8010994d:	50                   	push   %eax
8010994e:	e8 bc 00 00 00       	call   80109a0f <arp_table_search>
80109953:	83 c4 10             	add    $0x10,%esp
80109956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109959:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010995d:	78 2d                	js     8010998c <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010995f:	8b 45 08             	mov    0x8(%ebp),%eax
80109962:	8d 48 08             	lea    0x8(%eax),%ecx
80109965:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109968:	89 d0                	mov    %edx,%eax
8010996a:	c1 e0 02             	shl    $0x2,%eax
8010996d:	01 d0                	add    %edx,%eax
8010996f:	01 c0                	add    %eax,%eax
80109971:	01 d0                	add    %edx,%eax
80109973:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
80109978:	83 c0 04             	add    $0x4,%eax
8010997b:	83 ec 04             	sub    $0x4,%esp
8010997e:	6a 06                	push   $0x6
80109980:	51                   	push   %ecx
80109981:	50                   	push   %eax
80109982:	e8 32 ba ff ff       	call   801053b9 <memmove>
80109987:	83 c4 10             	add    $0x10,%esp
8010998a:	eb 70                	jmp    801099fc <arp_table_update+0xbe>
  }else{
    index += 1;
8010998c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109990:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109993:	8b 45 08             	mov    0x8(%ebp),%eax
80109996:	8d 48 08             	lea    0x8(%eax),%ecx
80109999:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010999c:	89 d0                	mov    %edx,%eax
8010999e:	c1 e0 02             	shl    $0x2,%eax
801099a1:	01 d0                	add    %edx,%eax
801099a3:	01 c0                	add    %eax,%eax
801099a5:	01 d0                	add    %edx,%eax
801099a7:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
801099ac:	83 c0 04             	add    $0x4,%eax
801099af:	83 ec 04             	sub    $0x4,%esp
801099b2:	6a 06                	push   $0x6
801099b4:	51                   	push   %ecx
801099b5:	50                   	push   %eax
801099b6:	e8 fe b9 ff ff       	call   801053b9 <memmove>
801099bb:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801099be:	8b 45 08             	mov    0x8(%ebp),%eax
801099c1:	8d 48 0e             	lea    0xe(%eax),%ecx
801099c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099c7:	89 d0                	mov    %edx,%eax
801099c9:	c1 e0 02             	shl    $0x2,%eax
801099cc:	01 d0                	add    %edx,%eax
801099ce:	01 c0                	add    %eax,%eax
801099d0:	01 d0                	add    %edx,%eax
801099d2:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
801099d7:	83 ec 04             	sub    $0x4,%esp
801099da:	6a 04                	push   $0x4
801099dc:	51                   	push   %ecx
801099dd:	50                   	push   %eax
801099de:	e8 d6 b9 ff ff       	call   801053b9 <memmove>
801099e3:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801099e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099e9:	89 d0                	mov    %edx,%eax
801099eb:	c1 e0 02             	shl    $0x2,%eax
801099ee:	01 d0                	add    %edx,%eax
801099f0:	01 c0                	add    %eax,%eax
801099f2:	01 d0                	add    %edx,%eax
801099f4:	05 ea a5 11 80       	add    $0x8011a5ea,%eax
801099f9:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801099fc:	83 ec 0c             	sub    $0xc,%esp
801099ff:	68 e0 a5 11 80       	push   $0x8011a5e0
80109a04:	e8 83 00 00 00       	call   80109a8c <print_arp_table>
80109a09:	83 c4 10             	add    $0x10,%esp
}
80109a0c:	90                   	nop
80109a0d:	c9                   	leave  
80109a0e:	c3                   	ret    

80109a0f <arp_table_search>:

int arp_table_search(uchar *ip){
80109a0f:	55                   	push   %ebp
80109a10:	89 e5                	mov    %esp,%ebp
80109a12:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109a15:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109a1c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109a23:	eb 59                	jmp    80109a7e <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109a25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109a28:	89 d0                	mov    %edx,%eax
80109a2a:	c1 e0 02             	shl    $0x2,%eax
80109a2d:	01 d0                	add    %edx,%eax
80109a2f:	01 c0                	add    %eax,%eax
80109a31:	01 d0                	add    %edx,%eax
80109a33:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
80109a38:	83 ec 04             	sub    $0x4,%esp
80109a3b:	6a 04                	push   $0x4
80109a3d:	ff 75 08             	push   0x8(%ebp)
80109a40:	50                   	push   %eax
80109a41:	e8 1b b9 ff ff       	call   80105361 <memcmp>
80109a46:	83 c4 10             	add    $0x10,%esp
80109a49:	85 c0                	test   %eax,%eax
80109a4b:	75 05                	jne    80109a52 <arp_table_search+0x43>
      return i;
80109a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a50:	eb 38                	jmp    80109a8a <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109a52:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109a55:	89 d0                	mov    %edx,%eax
80109a57:	c1 e0 02             	shl    $0x2,%eax
80109a5a:	01 d0                	add    %edx,%eax
80109a5c:	01 c0                	add    %eax,%eax
80109a5e:	01 d0                	add    %edx,%eax
80109a60:	05 ea a5 11 80       	add    $0x8011a5ea,%eax
80109a65:	0f b6 00             	movzbl (%eax),%eax
80109a68:	84 c0                	test   %al,%al
80109a6a:	75 0e                	jne    80109a7a <arp_table_search+0x6b>
80109a6c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109a70:	75 08                	jne    80109a7a <arp_table_search+0x6b>
      empty = -i;
80109a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a75:	f7 d8                	neg    %eax
80109a77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109a7a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109a7e:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109a82:	7e a1                	jle    80109a25 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a87:	83 e8 01             	sub    $0x1,%eax
}
80109a8a:	c9                   	leave  
80109a8b:	c3                   	ret    

80109a8c <print_arp_table>:

void print_arp_table(){
80109a8c:	55                   	push   %ebp
80109a8d:	89 e5                	mov    %esp,%ebp
80109a8f:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109a92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109a99:	e9 92 00 00 00       	jmp    80109b30 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109a9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109aa1:	89 d0                	mov    %edx,%eax
80109aa3:	c1 e0 02             	shl    $0x2,%eax
80109aa6:	01 d0                	add    %edx,%eax
80109aa8:	01 c0                	add    %eax,%eax
80109aaa:	01 d0                	add    %edx,%eax
80109aac:	05 ea a5 11 80       	add    $0x8011a5ea,%eax
80109ab1:	0f b6 00             	movzbl (%eax),%eax
80109ab4:	84 c0                	test   %al,%al
80109ab6:	74 74                	je     80109b2c <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109ab8:	83 ec 08             	sub    $0x8,%esp
80109abb:	ff 75 f4             	push   -0xc(%ebp)
80109abe:	68 2f c9 10 80       	push   $0x8010c92f
80109ac3:	e8 2c 69 ff ff       	call   801003f4 <cprintf>
80109ac8:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ace:	89 d0                	mov    %edx,%eax
80109ad0:	c1 e0 02             	shl    $0x2,%eax
80109ad3:	01 d0                	add    %edx,%eax
80109ad5:	01 c0                	add    %eax,%eax
80109ad7:	01 d0                	add    %edx,%eax
80109ad9:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
80109ade:	83 ec 0c             	sub    $0xc,%esp
80109ae1:	50                   	push   %eax
80109ae2:	e8 54 02 00 00       	call   80109d3b <print_ipv4>
80109ae7:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109aea:	83 ec 0c             	sub    $0xc,%esp
80109aed:	68 3e c9 10 80       	push   $0x8010c93e
80109af2:	e8 fd 68 ff ff       	call   801003f4 <cprintf>
80109af7:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109afd:	89 d0                	mov    %edx,%eax
80109aff:	c1 e0 02             	shl    $0x2,%eax
80109b02:	01 d0                	add    %edx,%eax
80109b04:	01 c0                	add    %eax,%eax
80109b06:	01 d0                	add    %edx,%eax
80109b08:	05 e0 a5 11 80       	add    $0x8011a5e0,%eax
80109b0d:	83 c0 04             	add    $0x4,%eax
80109b10:	83 ec 0c             	sub    $0xc,%esp
80109b13:	50                   	push   %eax
80109b14:	e8 70 02 00 00       	call   80109d89 <print_mac>
80109b19:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109b1c:	83 ec 0c             	sub    $0xc,%esp
80109b1f:	68 40 c9 10 80       	push   $0x8010c940
80109b24:	e8 cb 68 ff ff       	call   801003f4 <cprintf>
80109b29:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109b2c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109b30:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109b34:	0f 8e 64 ff ff ff    	jle    80109a9e <print_arp_table+0x12>
    }
  }
}
80109b3a:	90                   	nop
80109b3b:	90                   	nop
80109b3c:	c9                   	leave  
80109b3d:	c3                   	ret    

80109b3e <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109b3e:	55                   	push   %ebp
80109b3f:	89 e5                	mov    %esp,%ebp
80109b41:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109b44:	8b 45 10             	mov    0x10(%ebp),%eax
80109b47:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109b53:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b56:	83 c0 0e             	add    $0xe,%eax
80109b59:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b5f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b66:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b6d:	8d 50 08             	lea    0x8(%eax),%edx
80109b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b73:	83 ec 04             	sub    $0x4,%esp
80109b76:	6a 06                	push   $0x6
80109b78:	52                   	push   %edx
80109b79:	50                   	push   %eax
80109b7a:	e8 3a b8 ff ff       	call   801053b9 <memmove>
80109b7f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b85:	83 c0 06             	add    $0x6,%eax
80109b88:	83 ec 04             	sub    $0x4,%esp
80109b8b:	6a 06                	push   $0x6
80109b8d:	68 d0 a5 11 80       	push   $0x8011a5d0
80109b92:	50                   	push   %eax
80109b93:	e8 21 b8 ff ff       	call   801053b9 <memmove>
80109b98:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b9e:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ba6:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109baf:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bb6:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bbd:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc6:	8d 50 08             	lea    0x8(%eax),%edx
80109bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bcc:	83 c0 12             	add    $0x12,%eax
80109bcf:	83 ec 04             	sub    $0x4,%esp
80109bd2:	6a 06                	push   $0x6
80109bd4:	52                   	push   %edx
80109bd5:	50                   	push   %eax
80109bd6:	e8 de b7 ff ff       	call   801053b9 <memmove>
80109bdb:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109bde:	8b 45 08             	mov    0x8(%ebp),%eax
80109be1:	8d 50 0e             	lea    0xe(%eax),%edx
80109be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109be7:	83 c0 18             	add    $0x18,%eax
80109bea:	83 ec 04             	sub    $0x4,%esp
80109bed:	6a 04                	push   $0x4
80109bef:	52                   	push   %edx
80109bf0:	50                   	push   %eax
80109bf1:	e8 c3 b7 ff ff       	call   801053b9 <memmove>
80109bf6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bfc:	83 c0 08             	add    $0x8,%eax
80109bff:	83 ec 04             	sub    $0x4,%esp
80109c02:	6a 06                	push   $0x6
80109c04:	68 d0 a5 11 80       	push   $0x8011a5d0
80109c09:	50                   	push   %eax
80109c0a:	e8 aa b7 ff ff       	call   801053b9 <memmove>
80109c0f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c15:	83 c0 0e             	add    $0xe,%eax
80109c18:	83 ec 04             	sub    $0x4,%esp
80109c1b:	6a 04                	push   $0x4
80109c1d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109c22:	50                   	push   %eax
80109c23:	e8 91 b7 ff ff       	call   801053b9 <memmove>
80109c28:	83 c4 10             	add    $0x10,%esp
}
80109c2b:	90                   	nop
80109c2c:	c9                   	leave  
80109c2d:	c3                   	ret    

80109c2e <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109c2e:	55                   	push   %ebp
80109c2f:	89 e5                	mov    %esp,%ebp
80109c31:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109c34:	83 ec 0c             	sub    $0xc,%esp
80109c37:	68 42 c9 10 80       	push   $0x8010c942
80109c3c:	e8 b3 67 ff ff       	call   801003f4 <cprintf>
80109c41:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109c44:	8b 45 08             	mov    0x8(%ebp),%eax
80109c47:	83 c0 0e             	add    $0xe,%eax
80109c4a:	83 ec 0c             	sub    $0xc,%esp
80109c4d:	50                   	push   %eax
80109c4e:	e8 e8 00 00 00       	call   80109d3b <print_ipv4>
80109c53:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109c56:	83 ec 0c             	sub    $0xc,%esp
80109c59:	68 40 c9 10 80       	push   $0x8010c940
80109c5e:	e8 91 67 ff ff       	call   801003f4 <cprintf>
80109c63:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109c66:	8b 45 08             	mov    0x8(%ebp),%eax
80109c69:	83 c0 08             	add    $0x8,%eax
80109c6c:	83 ec 0c             	sub    $0xc,%esp
80109c6f:	50                   	push   %eax
80109c70:	e8 14 01 00 00       	call   80109d89 <print_mac>
80109c75:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109c78:	83 ec 0c             	sub    $0xc,%esp
80109c7b:	68 40 c9 10 80       	push   $0x8010c940
80109c80:	e8 6f 67 ff ff       	call   801003f4 <cprintf>
80109c85:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109c88:	83 ec 0c             	sub    $0xc,%esp
80109c8b:	68 59 c9 10 80       	push   $0x8010c959
80109c90:	e8 5f 67 ff ff       	call   801003f4 <cprintf>
80109c95:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109c98:	8b 45 08             	mov    0x8(%ebp),%eax
80109c9b:	83 c0 18             	add    $0x18,%eax
80109c9e:	83 ec 0c             	sub    $0xc,%esp
80109ca1:	50                   	push   %eax
80109ca2:	e8 94 00 00 00       	call   80109d3b <print_ipv4>
80109ca7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109caa:	83 ec 0c             	sub    $0xc,%esp
80109cad:	68 40 c9 10 80       	push   $0x8010c940
80109cb2:	e8 3d 67 ff ff       	call   801003f4 <cprintf>
80109cb7:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109cba:	8b 45 08             	mov    0x8(%ebp),%eax
80109cbd:	83 c0 12             	add    $0x12,%eax
80109cc0:	83 ec 0c             	sub    $0xc,%esp
80109cc3:	50                   	push   %eax
80109cc4:	e8 c0 00 00 00       	call   80109d89 <print_mac>
80109cc9:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109ccc:	83 ec 0c             	sub    $0xc,%esp
80109ccf:	68 40 c9 10 80       	push   $0x8010c940
80109cd4:	e8 1b 67 ff ff       	call   801003f4 <cprintf>
80109cd9:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109cdc:	83 ec 0c             	sub    $0xc,%esp
80109cdf:	68 70 c9 10 80       	push   $0x8010c970
80109ce4:	e8 0b 67 ff ff       	call   801003f4 <cprintf>
80109ce9:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109cec:	8b 45 08             	mov    0x8(%ebp),%eax
80109cef:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109cf3:	66 3d 00 01          	cmp    $0x100,%ax
80109cf7:	75 12                	jne    80109d0b <print_arp_info+0xdd>
80109cf9:	83 ec 0c             	sub    $0xc,%esp
80109cfc:	68 7c c9 10 80       	push   $0x8010c97c
80109d01:	e8 ee 66 ff ff       	call   801003f4 <cprintf>
80109d06:	83 c4 10             	add    $0x10,%esp
80109d09:	eb 1d                	jmp    80109d28 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d0e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109d12:	66 3d 00 02          	cmp    $0x200,%ax
80109d16:	75 10                	jne    80109d28 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109d18:	83 ec 0c             	sub    $0xc,%esp
80109d1b:	68 85 c9 10 80       	push   $0x8010c985
80109d20:	e8 cf 66 ff ff       	call   801003f4 <cprintf>
80109d25:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109d28:	83 ec 0c             	sub    $0xc,%esp
80109d2b:	68 40 c9 10 80       	push   $0x8010c940
80109d30:	e8 bf 66 ff ff       	call   801003f4 <cprintf>
80109d35:	83 c4 10             	add    $0x10,%esp
}
80109d38:	90                   	nop
80109d39:	c9                   	leave  
80109d3a:	c3                   	ret    

80109d3b <print_ipv4>:

void print_ipv4(uchar *ip){
80109d3b:	55                   	push   %ebp
80109d3c:	89 e5                	mov    %esp,%ebp
80109d3e:	53                   	push   %ebx
80109d3f:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109d42:	8b 45 08             	mov    0x8(%ebp),%eax
80109d45:	83 c0 03             	add    $0x3,%eax
80109d48:	0f b6 00             	movzbl (%eax),%eax
80109d4b:	0f b6 d8             	movzbl %al,%ebx
80109d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80109d51:	83 c0 02             	add    $0x2,%eax
80109d54:	0f b6 00             	movzbl (%eax),%eax
80109d57:	0f b6 c8             	movzbl %al,%ecx
80109d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80109d5d:	83 c0 01             	add    $0x1,%eax
80109d60:	0f b6 00             	movzbl (%eax),%eax
80109d63:	0f b6 d0             	movzbl %al,%edx
80109d66:	8b 45 08             	mov    0x8(%ebp),%eax
80109d69:	0f b6 00             	movzbl (%eax),%eax
80109d6c:	0f b6 c0             	movzbl %al,%eax
80109d6f:	83 ec 0c             	sub    $0xc,%esp
80109d72:	53                   	push   %ebx
80109d73:	51                   	push   %ecx
80109d74:	52                   	push   %edx
80109d75:	50                   	push   %eax
80109d76:	68 8c c9 10 80       	push   $0x8010c98c
80109d7b:	e8 74 66 ff ff       	call   801003f4 <cprintf>
80109d80:	83 c4 20             	add    $0x20,%esp
}
80109d83:	90                   	nop
80109d84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109d87:	c9                   	leave  
80109d88:	c3                   	ret    

80109d89 <print_mac>:

void print_mac(uchar *mac){
80109d89:	55                   	push   %ebp
80109d8a:	89 e5                	mov    %esp,%ebp
80109d8c:	57                   	push   %edi
80109d8d:	56                   	push   %esi
80109d8e:	53                   	push   %ebx
80109d8f:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109d92:	8b 45 08             	mov    0x8(%ebp),%eax
80109d95:	83 c0 05             	add    $0x5,%eax
80109d98:	0f b6 00             	movzbl (%eax),%eax
80109d9b:	0f b6 f8             	movzbl %al,%edi
80109d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80109da1:	83 c0 04             	add    $0x4,%eax
80109da4:	0f b6 00             	movzbl (%eax),%eax
80109da7:	0f b6 f0             	movzbl %al,%esi
80109daa:	8b 45 08             	mov    0x8(%ebp),%eax
80109dad:	83 c0 03             	add    $0x3,%eax
80109db0:	0f b6 00             	movzbl (%eax),%eax
80109db3:	0f b6 d8             	movzbl %al,%ebx
80109db6:	8b 45 08             	mov    0x8(%ebp),%eax
80109db9:	83 c0 02             	add    $0x2,%eax
80109dbc:	0f b6 00             	movzbl (%eax),%eax
80109dbf:	0f b6 c8             	movzbl %al,%ecx
80109dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc5:	83 c0 01             	add    $0x1,%eax
80109dc8:	0f b6 00             	movzbl (%eax),%eax
80109dcb:	0f b6 d0             	movzbl %al,%edx
80109dce:	8b 45 08             	mov    0x8(%ebp),%eax
80109dd1:	0f b6 00             	movzbl (%eax),%eax
80109dd4:	0f b6 c0             	movzbl %al,%eax
80109dd7:	83 ec 04             	sub    $0x4,%esp
80109dda:	57                   	push   %edi
80109ddb:	56                   	push   %esi
80109ddc:	53                   	push   %ebx
80109ddd:	51                   	push   %ecx
80109dde:	52                   	push   %edx
80109ddf:	50                   	push   %eax
80109de0:	68 a4 c9 10 80       	push   $0x8010c9a4
80109de5:	e8 0a 66 ff ff       	call   801003f4 <cprintf>
80109dea:	83 c4 20             	add    $0x20,%esp
}
80109ded:	90                   	nop
80109dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109df1:	5b                   	pop    %ebx
80109df2:	5e                   	pop    %esi
80109df3:	5f                   	pop    %edi
80109df4:	5d                   	pop    %ebp
80109df5:	c3                   	ret    

80109df6 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109df6:	55                   	push   %ebp
80109df7:	89 e5                	mov    %esp,%ebp
80109df9:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80109dff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109e02:	8b 45 08             	mov    0x8(%ebp),%eax
80109e05:	83 c0 0e             	add    $0xe,%eax
80109e08:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109e12:	3c 08                	cmp    $0x8,%al
80109e14:	75 1b                	jne    80109e31 <eth_proc+0x3b>
80109e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e19:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e1d:	3c 06                	cmp    $0x6,%al
80109e1f:	75 10                	jne    80109e31 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109e21:	83 ec 0c             	sub    $0xc,%esp
80109e24:	ff 75 f0             	push   -0x10(%ebp)
80109e27:	e8 01 f8 ff ff       	call   8010962d <arp_proc>
80109e2c:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109e2f:	eb 24                	jmp    80109e55 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e34:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109e38:	3c 08                	cmp    $0x8,%al
80109e3a:	75 19                	jne    80109e55 <eth_proc+0x5f>
80109e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e3f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e43:	84 c0                	test   %al,%al
80109e45:	75 0e                	jne    80109e55 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109e47:	83 ec 0c             	sub    $0xc,%esp
80109e4a:	ff 75 08             	push   0x8(%ebp)
80109e4d:	e8 a3 00 00 00       	call   80109ef5 <ipv4_proc>
80109e52:	83 c4 10             	add    $0x10,%esp
}
80109e55:	90                   	nop
80109e56:	c9                   	leave  
80109e57:	c3                   	ret    

80109e58 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109e58:	55                   	push   %ebp
80109e59:	89 e5                	mov    %esp,%ebp
80109e5b:	83 ec 04             	sub    $0x4,%esp
80109e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109e61:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109e65:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109e69:	c1 e0 08             	shl    $0x8,%eax
80109e6c:	89 c2                	mov    %eax,%edx
80109e6e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109e72:	66 c1 e8 08          	shr    $0x8,%ax
80109e76:	01 d0                	add    %edx,%eax
}
80109e78:	c9                   	leave  
80109e79:	c3                   	ret    

80109e7a <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109e7a:	55                   	push   %ebp
80109e7b:	89 e5                	mov    %esp,%ebp
80109e7d:	83 ec 04             	sub    $0x4,%esp
80109e80:	8b 45 08             	mov    0x8(%ebp),%eax
80109e83:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109e87:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109e8b:	c1 e0 08             	shl    $0x8,%eax
80109e8e:	89 c2                	mov    %eax,%edx
80109e90:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109e94:	66 c1 e8 08          	shr    $0x8,%ax
80109e98:	01 d0                	add    %edx,%eax
}
80109e9a:	c9                   	leave  
80109e9b:	c3                   	ret    

80109e9c <H2N_uint>:

uint H2N_uint(uint value){
80109e9c:	55                   	push   %ebp
80109e9d:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80109ea2:	c1 e0 18             	shl    $0x18,%eax
80109ea5:	25 00 00 00 0f       	and    $0xf000000,%eax
80109eaa:	89 c2                	mov    %eax,%edx
80109eac:	8b 45 08             	mov    0x8(%ebp),%eax
80109eaf:	c1 e0 08             	shl    $0x8,%eax
80109eb2:	25 00 f0 00 00       	and    $0xf000,%eax
80109eb7:	09 c2                	or     %eax,%edx
80109eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80109ebc:	c1 e8 08             	shr    $0x8,%eax
80109ebf:	83 e0 0f             	and    $0xf,%eax
80109ec2:	01 d0                	add    %edx,%eax
}
80109ec4:	5d                   	pop    %ebp
80109ec5:	c3                   	ret    

80109ec6 <N2H_uint>:

uint N2H_uint(uint value){
80109ec6:	55                   	push   %ebp
80109ec7:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80109ecc:	c1 e0 18             	shl    $0x18,%eax
80109ecf:	89 c2                	mov    %eax,%edx
80109ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ed4:	c1 e0 08             	shl    $0x8,%eax
80109ed7:	25 00 00 ff 00       	and    $0xff0000,%eax
80109edc:	01 c2                	add    %eax,%edx
80109ede:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee1:	c1 e8 08             	shr    $0x8,%eax
80109ee4:	25 00 ff 00 00       	and    $0xff00,%eax
80109ee9:	01 c2                	add    %eax,%edx
80109eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80109eee:	c1 e8 18             	shr    $0x18,%eax
80109ef1:	01 d0                	add    %edx,%eax
}
80109ef3:	5d                   	pop    %ebp
80109ef4:	c3                   	ret    

80109ef5 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109ef5:	55                   	push   %ebp
80109ef6:	89 e5                	mov    %esp,%ebp
80109ef8:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109efb:	8b 45 08             	mov    0x8(%ebp),%eax
80109efe:	83 c0 0e             	add    $0xe,%eax
80109f01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f07:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109f0b:	0f b7 d0             	movzwl %ax,%edx
80109f0e:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109f13:	39 c2                	cmp    %eax,%edx
80109f15:	74 60                	je     80109f77 <ipv4_proc+0x82>
80109f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f1a:	83 c0 0c             	add    $0xc,%eax
80109f1d:	83 ec 04             	sub    $0x4,%esp
80109f20:	6a 04                	push   $0x4
80109f22:	50                   	push   %eax
80109f23:	68 e4 f4 10 80       	push   $0x8010f4e4
80109f28:	e8 34 b4 ff ff       	call   80105361 <memcmp>
80109f2d:	83 c4 10             	add    $0x10,%esp
80109f30:	85 c0                	test   %eax,%eax
80109f32:	74 43                	je     80109f77 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f37:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109f3b:	0f b7 c0             	movzwl %ax,%eax
80109f3e:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f46:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109f4a:	3c 01                	cmp    $0x1,%al
80109f4c:	75 10                	jne    80109f5e <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109f4e:	83 ec 0c             	sub    $0xc,%esp
80109f51:	ff 75 08             	push   0x8(%ebp)
80109f54:	e8 a3 00 00 00       	call   80109ffc <icmp_proc>
80109f59:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109f5c:	eb 19                	jmp    80109f77 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f61:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109f65:	3c 06                	cmp    $0x6,%al
80109f67:	75 0e                	jne    80109f77 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109f69:	83 ec 0c             	sub    $0xc,%esp
80109f6c:	ff 75 08             	push   0x8(%ebp)
80109f6f:	e8 b3 03 00 00       	call   8010a327 <tcp_proc>
80109f74:	83 c4 10             	add    $0x10,%esp
}
80109f77:	90                   	nop
80109f78:	c9                   	leave  
80109f79:	c3                   	ret    

80109f7a <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109f7a:	55                   	push   %ebp
80109f7b:	89 e5                	mov    %esp,%ebp
80109f7d:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109f80:	8b 45 08             	mov    0x8(%ebp),%eax
80109f83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f89:	0f b6 00             	movzbl (%eax),%eax
80109f8c:	83 e0 0f             	and    $0xf,%eax
80109f8f:	01 c0                	add    %eax,%eax
80109f91:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109f94:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109f9b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109fa2:	eb 48                	jmp    80109fec <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109fa4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fa7:	01 c0                	add    %eax,%eax
80109fa9:	89 c2                	mov    %eax,%edx
80109fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fae:	01 d0                	add    %edx,%eax
80109fb0:	0f b6 00             	movzbl (%eax),%eax
80109fb3:	0f b6 c0             	movzbl %al,%eax
80109fb6:	c1 e0 08             	shl    $0x8,%eax
80109fb9:	89 c2                	mov    %eax,%edx
80109fbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fbe:	01 c0                	add    %eax,%eax
80109fc0:	8d 48 01             	lea    0x1(%eax),%ecx
80109fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fc6:	01 c8                	add    %ecx,%eax
80109fc8:	0f b6 00             	movzbl (%eax),%eax
80109fcb:	0f b6 c0             	movzbl %al,%eax
80109fce:	01 d0                	add    %edx,%eax
80109fd0:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109fd3:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109fda:	76 0c                	jbe    80109fe8 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109fdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109fdf:	0f b7 c0             	movzwl %ax,%eax
80109fe2:	83 c0 01             	add    $0x1,%eax
80109fe5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109fe8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109fec:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109ff0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109ff3:	7c af                	jl     80109fa4 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109ff5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ff8:	f7 d0                	not    %eax
}
80109ffa:	c9                   	leave  
80109ffb:	c3                   	ret    

80109ffc <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109ffc:	55                   	push   %ebp
80109ffd:	89 e5                	mov    %esp,%ebp
80109fff:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a002:	8b 45 08             	mov    0x8(%ebp),%eax
8010a005:	83 c0 0e             	add    $0xe,%eax
8010a008:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a00b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a00e:	0f b6 00             	movzbl (%eax),%eax
8010a011:	0f b6 c0             	movzbl %al,%eax
8010a014:	83 e0 0f             	and    $0xf,%eax
8010a017:	c1 e0 02             	shl    $0x2,%eax
8010a01a:	89 c2                	mov    %eax,%edx
8010a01c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a01f:	01 d0                	add    %edx,%eax
8010a021:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a024:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a027:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a02b:	84 c0                	test   %al,%al
8010a02d:	75 4f                	jne    8010a07e <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a02f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a032:	0f b6 00             	movzbl (%eax),%eax
8010a035:	3c 08                	cmp    $0x8,%al
8010a037:	75 45                	jne    8010a07e <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
8010a039:	e8 46 8c ff ff       	call   80102c84 <kalloc>
8010a03e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a041:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a048:	83 ec 04             	sub    $0x4,%esp
8010a04b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a04e:	50                   	push   %eax
8010a04f:	ff 75 ec             	push   -0x14(%ebp)
8010a052:	ff 75 08             	push   0x8(%ebp)
8010a055:	e8 78 00 00 00       	call   8010a0d2 <icmp_reply_pkt_create>
8010a05a:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a05d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a060:	83 ec 08             	sub    $0x8,%esp
8010a063:	50                   	push   %eax
8010a064:	ff 75 ec             	push   -0x14(%ebp)
8010a067:	e8 95 f4 ff ff       	call   80109501 <i8254_send>
8010a06c:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a06f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a072:	83 ec 0c             	sub    $0xc,%esp
8010a075:	50                   	push   %eax
8010a076:	e8 6f 8b ff ff       	call   80102bea <kfree>
8010a07b:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a07e:	90                   	nop
8010a07f:	c9                   	leave  
8010a080:	c3                   	ret    

8010a081 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a081:	55                   	push   %ebp
8010a082:	89 e5                	mov    %esp,%ebp
8010a084:	53                   	push   %ebx
8010a085:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a088:	8b 45 08             	mov    0x8(%ebp),%eax
8010a08b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a08f:	0f b7 c0             	movzwl %ax,%eax
8010a092:	83 ec 0c             	sub    $0xc,%esp
8010a095:	50                   	push   %eax
8010a096:	e8 bd fd ff ff       	call   80109e58 <N2H_ushort>
8010a09b:	83 c4 10             	add    $0x10,%esp
8010a09e:	0f b7 d8             	movzwl %ax,%ebx
8010a0a1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0a4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a0a8:	0f b7 c0             	movzwl %ax,%eax
8010a0ab:	83 ec 0c             	sub    $0xc,%esp
8010a0ae:	50                   	push   %eax
8010a0af:	e8 a4 fd ff ff       	call   80109e58 <N2H_ushort>
8010a0b4:	83 c4 10             	add    $0x10,%esp
8010a0b7:	0f b7 c0             	movzwl %ax,%eax
8010a0ba:	83 ec 04             	sub    $0x4,%esp
8010a0bd:	53                   	push   %ebx
8010a0be:	50                   	push   %eax
8010a0bf:	68 c3 c9 10 80       	push   $0x8010c9c3
8010a0c4:	e8 2b 63 ff ff       	call   801003f4 <cprintf>
8010a0c9:	83 c4 10             	add    $0x10,%esp
}
8010a0cc:	90                   	nop
8010a0cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a0d0:	c9                   	leave  
8010a0d1:	c3                   	ret    

8010a0d2 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a0d2:	55                   	push   %ebp
8010a0d3:	89 e5                	mov    %esp,%ebp
8010a0d5:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a0d8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a0de:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0e1:	83 c0 0e             	add    $0xe,%eax
8010a0e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a0e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0ea:	0f b6 00             	movzbl (%eax),%eax
8010a0ed:	0f b6 c0             	movzbl %al,%eax
8010a0f0:	83 e0 0f             	and    $0xf,%eax
8010a0f3:	c1 e0 02             	shl    $0x2,%eax
8010a0f6:	89 c2                	mov    %eax,%edx
8010a0f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0fb:	01 d0                	add    %edx,%eax
8010a0fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a100:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a103:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a106:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a109:	83 c0 0e             	add    $0xe,%eax
8010a10c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a10f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a112:	83 c0 14             	add    $0x14,%eax
8010a115:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a118:	8b 45 10             	mov    0x10(%ebp),%eax
8010a11b:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a121:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a124:	8d 50 06             	lea    0x6(%eax),%edx
8010a127:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a12a:	83 ec 04             	sub    $0x4,%esp
8010a12d:	6a 06                	push   $0x6
8010a12f:	52                   	push   %edx
8010a130:	50                   	push   %eax
8010a131:	e8 83 b2 ff ff       	call   801053b9 <memmove>
8010a136:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a139:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a13c:	83 c0 06             	add    $0x6,%eax
8010a13f:	83 ec 04             	sub    $0x4,%esp
8010a142:	6a 06                	push   $0x6
8010a144:	68 d0 a5 11 80       	push   $0x8011a5d0
8010a149:	50                   	push   %eax
8010a14a:	e8 6a b2 ff ff       	call   801053b9 <memmove>
8010a14f:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a152:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a155:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a159:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a15c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a160:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a163:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a166:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a169:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a16d:	83 ec 0c             	sub    $0xc,%esp
8010a170:	6a 54                	push   $0x54
8010a172:	e8 03 fd ff ff       	call   80109e7a <H2N_ushort>
8010a177:	83 c4 10             	add    $0x10,%esp
8010a17a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a17d:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a181:	0f b7 15 a0 a8 11 80 	movzwl 0x8011a8a0,%edx
8010a188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a18b:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a18f:	0f b7 05 a0 a8 11 80 	movzwl 0x8011a8a0,%eax
8010a196:	83 c0 01             	add    $0x1,%eax
8010a199:	66 a3 a0 a8 11 80    	mov    %ax,0x8011a8a0
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a19f:	83 ec 0c             	sub    $0xc,%esp
8010a1a2:	68 00 40 00 00       	push   $0x4000
8010a1a7:	e8 ce fc ff ff       	call   80109e7a <H2N_ushort>
8010a1ac:	83 c4 10             	add    $0x10,%esp
8010a1af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1b2:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a1b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1b9:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a1bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1c0:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a1c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1c7:	83 c0 0c             	add    $0xc,%eax
8010a1ca:	83 ec 04             	sub    $0x4,%esp
8010a1cd:	6a 04                	push   $0x4
8010a1cf:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a1d4:	50                   	push   %eax
8010a1d5:	e8 df b1 ff ff       	call   801053b9 <memmove>
8010a1da:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a1dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1e0:	8d 50 0c             	lea    0xc(%eax),%edx
8010a1e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1e6:	83 c0 10             	add    $0x10,%eax
8010a1e9:	83 ec 04             	sub    $0x4,%esp
8010a1ec:	6a 04                	push   $0x4
8010a1ee:	52                   	push   %edx
8010a1ef:	50                   	push   %eax
8010a1f0:	e8 c4 b1 ff ff       	call   801053b9 <memmove>
8010a1f5:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a1f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1fb:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a204:	83 ec 0c             	sub    $0xc,%esp
8010a207:	50                   	push   %eax
8010a208:	e8 6d fd ff ff       	call   80109f7a <ipv4_chksum>
8010a20d:	83 c4 10             	add    $0x10,%esp
8010a210:	0f b7 c0             	movzwl %ax,%eax
8010a213:	83 ec 0c             	sub    $0xc,%esp
8010a216:	50                   	push   %eax
8010a217:	e8 5e fc ff ff       	call   80109e7a <H2N_ushort>
8010a21c:	83 c4 10             	add    $0x10,%esp
8010a21f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a222:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a226:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a229:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a22c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a22f:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a233:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a236:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a23a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a23d:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a241:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a244:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a248:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a24b:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a24f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a252:	8d 50 08             	lea    0x8(%eax),%edx
8010a255:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a258:	83 c0 08             	add    $0x8,%eax
8010a25b:	83 ec 04             	sub    $0x4,%esp
8010a25e:	6a 08                	push   $0x8
8010a260:	52                   	push   %edx
8010a261:	50                   	push   %eax
8010a262:	e8 52 b1 ff ff       	call   801053b9 <memmove>
8010a267:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a26a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a26d:	8d 50 10             	lea    0x10(%eax),%edx
8010a270:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a273:	83 c0 10             	add    $0x10,%eax
8010a276:	83 ec 04             	sub    $0x4,%esp
8010a279:	6a 30                	push   $0x30
8010a27b:	52                   	push   %edx
8010a27c:	50                   	push   %eax
8010a27d:	e8 37 b1 ff ff       	call   801053b9 <memmove>
8010a282:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a285:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a288:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a28e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a291:	83 ec 0c             	sub    $0xc,%esp
8010a294:	50                   	push   %eax
8010a295:	e8 1c 00 00 00       	call   8010a2b6 <icmp_chksum>
8010a29a:	83 c4 10             	add    $0x10,%esp
8010a29d:	0f b7 c0             	movzwl %ax,%eax
8010a2a0:	83 ec 0c             	sub    $0xc,%esp
8010a2a3:	50                   	push   %eax
8010a2a4:	e8 d1 fb ff ff       	call   80109e7a <H2N_ushort>
8010a2a9:	83 c4 10             	add    $0x10,%esp
8010a2ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a2af:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a2b3:	90                   	nop
8010a2b4:	c9                   	leave  
8010a2b5:	c3                   	ret    

8010a2b6 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a2b6:	55                   	push   %ebp
8010a2b7:	89 e5                	mov    %esp,%ebp
8010a2b9:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a2bc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a2c2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a2c9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a2d0:	eb 48                	jmp    8010a31a <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a2d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a2d5:	01 c0                	add    %eax,%eax
8010a2d7:	89 c2                	mov    %eax,%edx
8010a2d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2dc:	01 d0                	add    %edx,%eax
8010a2de:	0f b6 00             	movzbl (%eax),%eax
8010a2e1:	0f b6 c0             	movzbl %al,%eax
8010a2e4:	c1 e0 08             	shl    $0x8,%eax
8010a2e7:	89 c2                	mov    %eax,%edx
8010a2e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a2ec:	01 c0                	add    %eax,%eax
8010a2ee:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2f4:	01 c8                	add    %ecx,%eax
8010a2f6:	0f b6 00             	movzbl (%eax),%eax
8010a2f9:	0f b6 c0             	movzbl %al,%eax
8010a2fc:	01 d0                	add    %edx,%eax
8010a2fe:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a301:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a308:	76 0c                	jbe    8010a316 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a30a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a30d:	0f b7 c0             	movzwl %ax,%eax
8010a310:	83 c0 01             	add    $0x1,%eax
8010a313:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a316:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a31a:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a31e:	7e b2                	jle    8010a2d2 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a320:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a323:	f7 d0                	not    %eax
}
8010a325:	c9                   	leave  
8010a326:	c3                   	ret    

8010a327 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a327:	55                   	push   %ebp
8010a328:	89 e5                	mov    %esp,%ebp
8010a32a:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a32d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a330:	83 c0 0e             	add    $0xe,%eax
8010a333:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a336:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a339:	0f b6 00             	movzbl (%eax),%eax
8010a33c:	0f b6 c0             	movzbl %al,%eax
8010a33f:	83 e0 0f             	and    $0xf,%eax
8010a342:	c1 e0 02             	shl    $0x2,%eax
8010a345:	89 c2                	mov    %eax,%edx
8010a347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a34a:	01 d0                	add    %edx,%eax
8010a34c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a34f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a352:	83 c0 14             	add    $0x14,%eax
8010a355:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a358:	e8 27 89 ff ff       	call   80102c84 <kalloc>
8010a35d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a360:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a367:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a36a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a36e:	0f b6 c0             	movzbl %al,%eax
8010a371:	83 e0 02             	and    $0x2,%eax
8010a374:	85 c0                	test   %eax,%eax
8010a376:	74 3d                	je     8010a3b5 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a378:	83 ec 0c             	sub    $0xc,%esp
8010a37b:	6a 00                	push   $0x0
8010a37d:	6a 12                	push   $0x12
8010a37f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a382:	50                   	push   %eax
8010a383:	ff 75 e8             	push   -0x18(%ebp)
8010a386:	ff 75 08             	push   0x8(%ebp)
8010a389:	e8 a2 01 00 00       	call   8010a530 <tcp_pkt_create>
8010a38e:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a391:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a394:	83 ec 08             	sub    $0x8,%esp
8010a397:	50                   	push   %eax
8010a398:	ff 75 e8             	push   -0x18(%ebp)
8010a39b:	e8 61 f1 ff ff       	call   80109501 <i8254_send>
8010a3a0:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a3a3:	a1 a4 a8 11 80       	mov    0x8011a8a4,%eax
8010a3a8:	83 c0 01             	add    $0x1,%eax
8010a3ab:	a3 a4 a8 11 80       	mov    %eax,0x8011a8a4
8010a3b0:	e9 69 01 00 00       	jmp    8010a51e <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a3b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3b8:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a3bc:	3c 18                	cmp    $0x18,%al
8010a3be:	0f 85 10 01 00 00    	jne    8010a4d4 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a3c4:	83 ec 04             	sub    $0x4,%esp
8010a3c7:	6a 03                	push   $0x3
8010a3c9:	68 de c9 10 80       	push   $0x8010c9de
8010a3ce:	ff 75 ec             	push   -0x14(%ebp)
8010a3d1:	e8 8b af ff ff       	call   80105361 <memcmp>
8010a3d6:	83 c4 10             	add    $0x10,%esp
8010a3d9:	85 c0                	test   %eax,%eax
8010a3db:	74 74                	je     8010a451 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a3dd:	83 ec 0c             	sub    $0xc,%esp
8010a3e0:	68 e2 c9 10 80       	push   $0x8010c9e2
8010a3e5:	e8 0a 60 ff ff       	call   801003f4 <cprintf>
8010a3ea:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a3ed:	83 ec 0c             	sub    $0xc,%esp
8010a3f0:	6a 00                	push   $0x0
8010a3f2:	6a 10                	push   $0x10
8010a3f4:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3f7:	50                   	push   %eax
8010a3f8:	ff 75 e8             	push   -0x18(%ebp)
8010a3fb:	ff 75 08             	push   0x8(%ebp)
8010a3fe:	e8 2d 01 00 00       	call   8010a530 <tcp_pkt_create>
8010a403:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a406:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a409:	83 ec 08             	sub    $0x8,%esp
8010a40c:	50                   	push   %eax
8010a40d:	ff 75 e8             	push   -0x18(%ebp)
8010a410:	e8 ec f0 ff ff       	call   80109501 <i8254_send>
8010a415:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a418:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a41b:	83 c0 36             	add    $0x36,%eax
8010a41e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a421:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a424:	50                   	push   %eax
8010a425:	ff 75 e0             	push   -0x20(%ebp)
8010a428:	6a 00                	push   $0x0
8010a42a:	6a 00                	push   $0x0
8010a42c:	e8 5a 04 00 00       	call   8010a88b <http_proc>
8010a431:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a434:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a437:	83 ec 0c             	sub    $0xc,%esp
8010a43a:	50                   	push   %eax
8010a43b:	6a 18                	push   $0x18
8010a43d:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a440:	50                   	push   %eax
8010a441:	ff 75 e8             	push   -0x18(%ebp)
8010a444:	ff 75 08             	push   0x8(%ebp)
8010a447:	e8 e4 00 00 00       	call   8010a530 <tcp_pkt_create>
8010a44c:	83 c4 20             	add    $0x20,%esp
8010a44f:	eb 62                	jmp    8010a4b3 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a451:	83 ec 0c             	sub    $0xc,%esp
8010a454:	6a 00                	push   $0x0
8010a456:	6a 10                	push   $0x10
8010a458:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a45b:	50                   	push   %eax
8010a45c:	ff 75 e8             	push   -0x18(%ebp)
8010a45f:	ff 75 08             	push   0x8(%ebp)
8010a462:	e8 c9 00 00 00       	call   8010a530 <tcp_pkt_create>
8010a467:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a46a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a46d:	83 ec 08             	sub    $0x8,%esp
8010a470:	50                   	push   %eax
8010a471:	ff 75 e8             	push   -0x18(%ebp)
8010a474:	e8 88 f0 ff ff       	call   80109501 <i8254_send>
8010a479:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a47c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a47f:	83 c0 36             	add    $0x36,%eax
8010a482:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a485:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a488:	50                   	push   %eax
8010a489:	ff 75 e4             	push   -0x1c(%ebp)
8010a48c:	6a 00                	push   $0x0
8010a48e:	6a 00                	push   $0x0
8010a490:	e8 f6 03 00 00       	call   8010a88b <http_proc>
8010a495:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a498:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a49b:	83 ec 0c             	sub    $0xc,%esp
8010a49e:	50                   	push   %eax
8010a49f:	6a 18                	push   $0x18
8010a4a1:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a4a4:	50                   	push   %eax
8010a4a5:	ff 75 e8             	push   -0x18(%ebp)
8010a4a8:	ff 75 08             	push   0x8(%ebp)
8010a4ab:	e8 80 00 00 00       	call   8010a530 <tcp_pkt_create>
8010a4b0:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a4b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a4b6:	83 ec 08             	sub    $0x8,%esp
8010a4b9:	50                   	push   %eax
8010a4ba:	ff 75 e8             	push   -0x18(%ebp)
8010a4bd:	e8 3f f0 ff ff       	call   80109501 <i8254_send>
8010a4c2:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a4c5:	a1 a4 a8 11 80       	mov    0x8011a8a4,%eax
8010a4ca:	83 c0 01             	add    $0x1,%eax
8010a4cd:	a3 a4 a8 11 80       	mov    %eax,0x8011a8a4
8010a4d2:	eb 4a                	jmp    8010a51e <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a4d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4d7:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a4db:	3c 10                	cmp    $0x10,%al
8010a4dd:	75 3f                	jne    8010a51e <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a4df:	a1 a8 a8 11 80       	mov    0x8011a8a8,%eax
8010a4e4:	83 f8 01             	cmp    $0x1,%eax
8010a4e7:	75 35                	jne    8010a51e <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a4e9:	83 ec 0c             	sub    $0xc,%esp
8010a4ec:	6a 00                	push   $0x0
8010a4ee:	6a 01                	push   $0x1
8010a4f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a4f3:	50                   	push   %eax
8010a4f4:	ff 75 e8             	push   -0x18(%ebp)
8010a4f7:	ff 75 08             	push   0x8(%ebp)
8010a4fa:	e8 31 00 00 00       	call   8010a530 <tcp_pkt_create>
8010a4ff:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a502:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a505:	83 ec 08             	sub    $0x8,%esp
8010a508:	50                   	push   %eax
8010a509:	ff 75 e8             	push   -0x18(%ebp)
8010a50c:	e8 f0 ef ff ff       	call   80109501 <i8254_send>
8010a511:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a514:	c7 05 a8 a8 11 80 00 	movl   $0x0,0x8011a8a8
8010a51b:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a51e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a521:	83 ec 0c             	sub    $0xc,%esp
8010a524:	50                   	push   %eax
8010a525:	e8 c0 86 ff ff       	call   80102bea <kfree>
8010a52a:	83 c4 10             	add    $0x10,%esp
}
8010a52d:	90                   	nop
8010a52e:	c9                   	leave  
8010a52f:	c3                   	ret    

8010a530 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a530:	55                   	push   %ebp
8010a531:	89 e5                	mov    %esp,%ebp
8010a533:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a536:	8b 45 08             	mov    0x8(%ebp),%eax
8010a539:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a53c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a53f:	83 c0 0e             	add    $0xe,%eax
8010a542:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a545:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a548:	0f b6 00             	movzbl (%eax),%eax
8010a54b:	0f b6 c0             	movzbl %al,%eax
8010a54e:	83 e0 0f             	and    $0xf,%eax
8010a551:	c1 e0 02             	shl    $0x2,%eax
8010a554:	89 c2                	mov    %eax,%edx
8010a556:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a559:	01 d0                	add    %edx,%eax
8010a55b:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a55e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a561:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a564:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a567:	83 c0 0e             	add    $0xe,%eax
8010a56a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a56d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a570:	83 c0 14             	add    $0x14,%eax
8010a573:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a576:	8b 45 18             	mov    0x18(%ebp),%eax
8010a579:	8d 50 36             	lea    0x36(%eax),%edx
8010a57c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a57f:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a581:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a584:	8d 50 06             	lea    0x6(%eax),%edx
8010a587:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a58a:	83 ec 04             	sub    $0x4,%esp
8010a58d:	6a 06                	push   $0x6
8010a58f:	52                   	push   %edx
8010a590:	50                   	push   %eax
8010a591:	e8 23 ae ff ff       	call   801053b9 <memmove>
8010a596:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a599:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a59c:	83 c0 06             	add    $0x6,%eax
8010a59f:	83 ec 04             	sub    $0x4,%esp
8010a5a2:	6a 06                	push   $0x6
8010a5a4:	68 d0 a5 11 80       	push   $0x8011a5d0
8010a5a9:	50                   	push   %eax
8010a5aa:	e8 0a ae ff ff       	call   801053b9 <memmove>
8010a5af:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a5b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5b5:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a5b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5bc:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a5c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5c3:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a5c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5c9:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a5cd:	8b 45 18             	mov    0x18(%ebp),%eax
8010a5d0:	83 c0 28             	add    $0x28,%eax
8010a5d3:	0f b7 c0             	movzwl %ax,%eax
8010a5d6:	83 ec 0c             	sub    $0xc,%esp
8010a5d9:	50                   	push   %eax
8010a5da:	e8 9b f8 ff ff       	call   80109e7a <H2N_ushort>
8010a5df:	83 c4 10             	add    $0x10,%esp
8010a5e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a5e5:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a5e9:	0f b7 15 a0 a8 11 80 	movzwl 0x8011a8a0,%edx
8010a5f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5f3:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a5f7:	0f b7 05 a0 a8 11 80 	movzwl 0x8011a8a0,%eax
8010a5fe:	83 c0 01             	add    $0x1,%eax
8010a601:	66 a3 a0 a8 11 80    	mov    %ax,0x8011a8a0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a607:	83 ec 0c             	sub    $0xc,%esp
8010a60a:	6a 00                	push   $0x0
8010a60c:	e8 69 f8 ff ff       	call   80109e7a <H2N_ushort>
8010a611:	83 c4 10             	add    $0x10,%esp
8010a614:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a617:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a61b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a61e:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a625:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a62c:	83 c0 0c             	add    $0xc,%eax
8010a62f:	83 ec 04             	sub    $0x4,%esp
8010a632:	6a 04                	push   $0x4
8010a634:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a639:	50                   	push   %eax
8010a63a:	e8 7a ad ff ff       	call   801053b9 <memmove>
8010a63f:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a642:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a645:	8d 50 0c             	lea    0xc(%eax),%edx
8010a648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a64b:	83 c0 10             	add    $0x10,%eax
8010a64e:	83 ec 04             	sub    $0x4,%esp
8010a651:	6a 04                	push   $0x4
8010a653:	52                   	push   %edx
8010a654:	50                   	push   %eax
8010a655:	e8 5f ad ff ff       	call   801053b9 <memmove>
8010a65a:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a65d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a660:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a666:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a669:	83 ec 0c             	sub    $0xc,%esp
8010a66c:	50                   	push   %eax
8010a66d:	e8 08 f9 ff ff       	call   80109f7a <ipv4_chksum>
8010a672:	83 c4 10             	add    $0x10,%esp
8010a675:	0f b7 c0             	movzwl %ax,%eax
8010a678:	83 ec 0c             	sub    $0xc,%esp
8010a67b:	50                   	push   %eax
8010a67c:	e8 f9 f7 ff ff       	call   80109e7a <H2N_ushort>
8010a681:	83 c4 10             	add    $0x10,%esp
8010a684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a687:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a68b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a68e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a692:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a695:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a698:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a69b:	0f b7 10             	movzwl (%eax),%edx
8010a69e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6a1:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a6a5:	a1 a4 a8 11 80       	mov    0x8011a8a4,%eax
8010a6aa:	83 ec 0c             	sub    $0xc,%esp
8010a6ad:	50                   	push   %eax
8010a6ae:	e8 e9 f7 ff ff       	call   80109e9c <H2N_uint>
8010a6b3:	83 c4 10             	add    $0x10,%esp
8010a6b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a6b9:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a6bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6bf:	8b 40 04             	mov    0x4(%eax),%eax
8010a6c2:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a6c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6cb:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a6ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6d1:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a6d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6d8:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a6dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6df:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a6e3:	8b 45 14             	mov    0x14(%ebp),%eax
8010a6e6:	89 c2                	mov    %eax,%edx
8010a6e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6eb:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a6ee:	83 ec 0c             	sub    $0xc,%esp
8010a6f1:	68 90 38 00 00       	push   $0x3890
8010a6f6:	e8 7f f7 ff ff       	call   80109e7a <H2N_ushort>
8010a6fb:	83 c4 10             	add    $0x10,%esp
8010a6fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a701:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a705:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a708:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a70e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a711:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a71a:	83 ec 0c             	sub    $0xc,%esp
8010a71d:	50                   	push   %eax
8010a71e:	e8 1f 00 00 00       	call   8010a742 <tcp_chksum>
8010a723:	83 c4 10             	add    $0x10,%esp
8010a726:	83 c0 08             	add    $0x8,%eax
8010a729:	0f b7 c0             	movzwl %ax,%eax
8010a72c:	83 ec 0c             	sub    $0xc,%esp
8010a72f:	50                   	push   %eax
8010a730:	e8 45 f7 ff ff       	call   80109e7a <H2N_ushort>
8010a735:	83 c4 10             	add    $0x10,%esp
8010a738:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a73b:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a73f:	90                   	nop
8010a740:	c9                   	leave  
8010a741:	c3                   	ret    

8010a742 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a742:	55                   	push   %ebp
8010a743:	89 e5                	mov    %esp,%ebp
8010a745:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a748:	8b 45 08             	mov    0x8(%ebp),%eax
8010a74b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a74e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a751:	83 c0 14             	add    $0x14,%eax
8010a754:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a757:	83 ec 04             	sub    $0x4,%esp
8010a75a:	6a 04                	push   $0x4
8010a75c:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a761:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a764:	50                   	push   %eax
8010a765:	e8 4f ac ff ff       	call   801053b9 <memmove>
8010a76a:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a76d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a770:	83 c0 0c             	add    $0xc,%eax
8010a773:	83 ec 04             	sub    $0x4,%esp
8010a776:	6a 04                	push   $0x4
8010a778:	50                   	push   %eax
8010a779:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a77c:	83 c0 04             	add    $0x4,%eax
8010a77f:	50                   	push   %eax
8010a780:	e8 34 ac ff ff       	call   801053b9 <memmove>
8010a785:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a788:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a78c:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a790:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a793:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a797:	0f b7 c0             	movzwl %ax,%eax
8010a79a:	83 ec 0c             	sub    $0xc,%esp
8010a79d:	50                   	push   %eax
8010a79e:	e8 b5 f6 ff ff       	call   80109e58 <N2H_ushort>
8010a7a3:	83 c4 10             	add    $0x10,%esp
8010a7a6:	83 e8 14             	sub    $0x14,%eax
8010a7a9:	0f b7 c0             	movzwl %ax,%eax
8010a7ac:	83 ec 0c             	sub    $0xc,%esp
8010a7af:	50                   	push   %eax
8010a7b0:	e8 c5 f6 ff ff       	call   80109e7a <H2N_ushort>
8010a7b5:	83 c4 10             	add    $0x10,%esp
8010a7b8:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a7bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a7c3:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a7c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a7c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a7d0:	eb 33                	jmp    8010a805 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a7d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7d5:	01 c0                	add    %eax,%eax
8010a7d7:	89 c2                	mov    %eax,%edx
8010a7d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7dc:	01 d0                	add    %edx,%eax
8010a7de:	0f b6 00             	movzbl (%eax),%eax
8010a7e1:	0f b6 c0             	movzbl %al,%eax
8010a7e4:	c1 e0 08             	shl    $0x8,%eax
8010a7e7:	89 c2                	mov    %eax,%edx
8010a7e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7ec:	01 c0                	add    %eax,%eax
8010a7ee:	8d 48 01             	lea    0x1(%eax),%ecx
8010a7f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7f4:	01 c8                	add    %ecx,%eax
8010a7f6:	0f b6 00             	movzbl (%eax),%eax
8010a7f9:	0f b6 c0             	movzbl %al,%eax
8010a7fc:	01 d0                	add    %edx,%eax
8010a7fe:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a801:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a805:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a809:	7e c7                	jle    8010a7d2 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a80b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a80e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a811:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a818:	eb 33                	jmp    8010a84d <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a81a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a81d:	01 c0                	add    %eax,%eax
8010a81f:	89 c2                	mov    %eax,%edx
8010a821:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a824:	01 d0                	add    %edx,%eax
8010a826:	0f b6 00             	movzbl (%eax),%eax
8010a829:	0f b6 c0             	movzbl %al,%eax
8010a82c:	c1 e0 08             	shl    $0x8,%eax
8010a82f:	89 c2                	mov    %eax,%edx
8010a831:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a834:	01 c0                	add    %eax,%eax
8010a836:	8d 48 01             	lea    0x1(%eax),%ecx
8010a839:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a83c:	01 c8                	add    %ecx,%eax
8010a83e:	0f b6 00             	movzbl (%eax),%eax
8010a841:	0f b6 c0             	movzbl %al,%eax
8010a844:	01 d0                	add    %edx,%eax
8010a846:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a849:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a84d:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a851:	0f b7 c0             	movzwl %ax,%eax
8010a854:	83 ec 0c             	sub    $0xc,%esp
8010a857:	50                   	push   %eax
8010a858:	e8 fb f5 ff ff       	call   80109e58 <N2H_ushort>
8010a85d:	83 c4 10             	add    $0x10,%esp
8010a860:	66 d1 e8             	shr    %ax
8010a863:	0f b7 c0             	movzwl %ax,%eax
8010a866:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a869:	7c af                	jl     8010a81a <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a86e:	c1 e8 10             	shr    $0x10,%eax
8010a871:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a874:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a877:	f7 d0                	not    %eax
}
8010a879:	c9                   	leave  
8010a87a:	c3                   	ret    

8010a87b <tcp_fin>:

void tcp_fin(){
8010a87b:	55                   	push   %ebp
8010a87c:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a87e:	c7 05 a8 a8 11 80 01 	movl   $0x1,0x8011a8a8
8010a885:	00 00 00 
}
8010a888:	90                   	nop
8010a889:	5d                   	pop    %ebp
8010a88a:	c3                   	ret    

8010a88b <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a88b:	55                   	push   %ebp
8010a88c:	89 e5                	mov    %esp,%ebp
8010a88e:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a891:	8b 45 10             	mov    0x10(%ebp),%eax
8010a894:	83 ec 04             	sub    $0x4,%esp
8010a897:	6a 00                	push   $0x0
8010a899:	68 eb c9 10 80       	push   $0x8010c9eb
8010a89e:	50                   	push   %eax
8010a89f:	e8 65 00 00 00       	call   8010a909 <http_strcpy>
8010a8a4:	83 c4 10             	add    $0x10,%esp
8010a8a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a8aa:	8b 45 10             	mov    0x10(%ebp),%eax
8010a8ad:	83 ec 04             	sub    $0x4,%esp
8010a8b0:	ff 75 f4             	push   -0xc(%ebp)
8010a8b3:	68 fe c9 10 80       	push   $0x8010c9fe
8010a8b8:	50                   	push   %eax
8010a8b9:	e8 4b 00 00 00       	call   8010a909 <http_strcpy>
8010a8be:	83 c4 10             	add    $0x10,%esp
8010a8c1:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a8c4:	8b 45 10             	mov    0x10(%ebp),%eax
8010a8c7:	83 ec 04             	sub    $0x4,%esp
8010a8ca:	ff 75 f4             	push   -0xc(%ebp)
8010a8cd:	68 19 ca 10 80       	push   $0x8010ca19
8010a8d2:	50                   	push   %eax
8010a8d3:	e8 31 00 00 00       	call   8010a909 <http_strcpy>
8010a8d8:	83 c4 10             	add    $0x10,%esp
8010a8db:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a8de:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a8e1:	83 e0 01             	and    $0x1,%eax
8010a8e4:	85 c0                	test   %eax,%eax
8010a8e6:	74 11                	je     8010a8f9 <http_proc+0x6e>
    char *payload = (char *)send;
8010a8e8:	8b 45 10             	mov    0x10(%ebp),%eax
8010a8eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a8ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a8f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8f4:	01 d0                	add    %edx,%eax
8010a8f6:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a8f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a8fc:	8b 45 14             	mov    0x14(%ebp),%eax
8010a8ff:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a901:	e8 75 ff ff ff       	call   8010a87b <tcp_fin>
}
8010a906:	90                   	nop
8010a907:	c9                   	leave  
8010a908:	c3                   	ret    

8010a909 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a909:	55                   	push   %ebp
8010a90a:	89 e5                	mov    %esp,%ebp
8010a90c:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a90f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a916:	eb 20                	jmp    8010a938 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a918:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a91b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a91e:	01 d0                	add    %edx,%eax
8010a920:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a923:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a926:	01 ca                	add    %ecx,%edx
8010a928:	89 d1                	mov    %edx,%ecx
8010a92a:	8b 55 08             	mov    0x8(%ebp),%edx
8010a92d:	01 ca                	add    %ecx,%edx
8010a92f:	0f b6 00             	movzbl (%eax),%eax
8010a932:	88 02                	mov    %al,(%edx)
    i++;
8010a934:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a938:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a93b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a93e:	01 d0                	add    %edx,%eax
8010a940:	0f b6 00             	movzbl (%eax),%eax
8010a943:	84 c0                	test   %al,%al
8010a945:	75 d1                	jne    8010a918 <http_strcpy+0xf>
  }
  return i;
8010a947:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a94a:	c9                   	leave  
8010a94b:	c3                   	ret    
