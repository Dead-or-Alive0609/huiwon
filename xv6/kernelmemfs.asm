
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
8010005a:	bc 60 e3 18 80       	mov    $0x8018e360,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba ae 34 10 80       	mov    $0x801034ae,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	f3 0f 1e fb          	endbr32 
8010006a:	55                   	push   %ebp
8010006b:	89 e5                	mov    %esp,%ebp
8010006d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
80100070:	83 ec 08             	sub    $0x8,%esp
80100073:	68 60 a9 10 80       	push   $0x8010a960
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 fa 4c 00 00       	call   80104d7c <initlock>
80100082:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100085:	c7 05 ac 2a 19 80 5c 	movl   $0x80192a5c,0x80192aac
8010008c:	2a 19 80 
  bcache.head.next = &bcache.head;
8010008f:	c7 05 b0 2a 19 80 5c 	movl   $0x80192a5c,0x80192ab0
80100096:	2a 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100099:	c7 45 f4 94 e3 18 80 	movl   $0x8018e394,-0xc(%ebp)
801000a0:	eb 47                	jmp    801000e9 <binit+0x83>
    b->next = bcache.head.next;
801000a2:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b1:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000bb:	83 c0 0c             	add    $0xc,%eax
801000be:	83 ec 08             	sub    $0x8,%esp
801000c1:	68 67 a9 10 80       	push   $0x8010a967
801000c6:	50                   	push   %eax
801000c7:	e8 43 4b 00 00       	call   80104c0f <initsleeplock>
801000cc:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cf:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
801000d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d7:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000dd:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000e2:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e9:	b8 5c 2a 19 80       	mov    $0x80192a5c,%eax
801000ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000f1:	72 af                	jb     801000a2 <binit+0x3c>
  }
}
801000f3:	90                   	nop
801000f4:	90                   	nop
801000f5:	c9                   	leave  
801000f6:	c3                   	ret    

801000f7 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f7:	f3 0f 1e fb          	endbr32 
801000fb:	55                   	push   %ebp
801000fc:	89 e5                	mov    %esp,%ebp
801000fe:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
80100101:	83 ec 0c             	sub    $0xc,%esp
80100104:	68 60 e3 18 80       	push   $0x8018e360
80100109:	e8 94 4c 00 00       	call   80104da2 <acquire>
8010010e:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100111:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100116:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100119:	eb 58                	jmp    80100173 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
8010011b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011e:	8b 40 04             	mov    0x4(%eax),%eax
80100121:	39 45 08             	cmp    %eax,0x8(%ebp)
80100124:	75 44                	jne    8010016a <bget+0x73>
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 08             	mov    0x8(%eax),%eax
8010012c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010012f:	75 39                	jne    8010016a <bget+0x73>
      b->refcnt++;
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 4c             	mov    0x4c(%eax),%eax
80100137:	8d 50 01             	lea    0x1(%eax),%edx
8010013a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013d:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100140:	83 ec 0c             	sub    $0xc,%esp
80100143:	68 60 e3 18 80       	push   $0x8018e360
80100148:	e8 c7 4c 00 00       	call   80104e14 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 f0 4a 00 00       	call   80104c4f <acquiresleep>
8010015f:	83 c4 10             	add    $0x10,%esp
      return b;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	e9 9d 00 00 00       	jmp    80100207 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 40 54             	mov    0x54(%eax),%eax
80100170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100173:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
8010017a:	75 9f                	jne    8010011b <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010017c:	a1 ac 2a 19 80       	mov    0x80192aac,%eax
80100181:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100184:	eb 6b                	jmp    801001f1 <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 4c             	mov    0x4c(%eax),%eax
8010018c:	85 c0                	test   %eax,%eax
8010018e:	75 58                	jne    801001e8 <bget+0xf1>
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	8b 00                	mov    (%eax),%eax
80100195:	83 e0 04             	and    $0x4,%eax
80100198:	85 c0                	test   %eax,%eax
8010019a:	75 4c                	jne    801001e8 <bget+0xf1>
      b->dev = dev;
8010019c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019f:	8b 55 08             	mov    0x8(%ebp),%edx
801001a2:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
801001a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801001ab:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ba:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001c1:	83 ec 0c             	sub    $0xc,%esp
801001c4:	68 60 e3 18 80       	push   $0x8018e360
801001c9:	e8 46 4c 00 00       	call   80104e14 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 6f 4a 00 00       	call   80104c4f <acquiresleep>
801001e0:	83 c4 10             	add    $0x10,%esp
      return b;
801001e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e6:	eb 1f                	jmp    80100207 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 40 50             	mov    0x50(%eax),%eax
801001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001f1:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
801001f8:	75 8c                	jne    80100186 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001fa:	83 ec 0c             	sub    $0xc,%esp
801001fd:	68 6e a9 10 80       	push   $0x8010a96e
80100202:	e8 be 03 00 00       	call   801005c5 <panic>
}
80100207:	c9                   	leave  
80100208:	c3                   	ret    

80100209 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100209:	f3 0f 1e fb          	endbr32 
8010020d:	55                   	push   %ebp
8010020e:	89 e5                	mov    %esp,%ebp
80100210:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100213:	83 ec 08             	sub    $0x8,%esp
80100216:	ff 75 0c             	pushl  0xc(%ebp)
80100219:	ff 75 08             	pushl  0x8(%ebp)
8010021c:	e8 d6 fe ff ff       	call   801000f7 <bget>
80100221:	83 c4 10             	add    $0x10,%esp
80100224:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
80100227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010022a:	8b 00                	mov    (%eax),%eax
8010022c:	83 e0 02             	and    $0x2,%eax
8010022f:	85 c0                	test   %eax,%eax
80100231:	75 0e                	jne    80100241 <bread+0x38>
    iderw(b);
80100233:	83 ec 0c             	sub    $0xc,%esp
80100236:	ff 75 f4             	pushl  -0xc(%ebp)
80100239:	e8 12 a6 00 00       	call   8010a850 <iderw>
8010023e:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100241:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100244:	c9                   	leave  
80100245:	c3                   	ret    

80100246 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100246:	f3 0f 1e fb          	endbr32 
8010024a:	55                   	push   %ebp
8010024b:	89 e5                	mov    %esp,%ebp
8010024d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	50                   	push   %eax
8010025a:	e8 aa 4a 00 00       	call   80104d09 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 7f a9 10 80       	push   $0x8010a97f
8010026e:	e8 52 03 00 00       	call   801005c5 <panic>
  b->flags |= B_DIRTY;
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	8b 00                	mov    (%eax),%eax
80100278:	83 c8 04             	or     $0x4,%eax
8010027b:	89 c2                	mov    %eax,%edx
8010027d:	8b 45 08             	mov    0x8(%ebp),%eax
80100280:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100282:	83 ec 0c             	sub    $0xc,%esp
80100285:	ff 75 08             	pushl  0x8(%ebp)
80100288:	e8 c3 a5 00 00       	call   8010a850 <iderw>
8010028d:	83 c4 10             	add    $0x10,%esp
}
80100290:	90                   	nop
80100291:	c9                   	leave  
80100292:	c3                   	ret    

80100293 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100293:	f3 0f 1e fb          	endbr32 
80100297:	55                   	push   %ebp
80100298:	89 e5                	mov    %esp,%ebp
8010029a:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	83 c0 0c             	add    $0xc,%eax
801002a3:	83 ec 0c             	sub    $0xc,%esp
801002a6:	50                   	push   %eax
801002a7:	e8 5d 4a 00 00       	call   80104d09 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 86 a9 10 80       	push   $0x8010a986
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 e8 49 00 00       	call   80104cb7 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 c3 4a 00 00       	call   80104da2 <acquire>
801002df:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002e2:	8b 45 08             	mov    0x8(%ebp),%eax
801002e5:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801002eb:	8b 45 08             	mov    0x8(%ebp),%eax
801002ee:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002f1:	8b 45 08             	mov    0x8(%ebp),%eax
801002f4:	8b 40 4c             	mov    0x4c(%eax),%eax
801002f7:	85 c0                	test   %eax,%eax
801002f9:	75 47                	jne    80100342 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002fb:	8b 45 08             	mov    0x8(%ebp),%eax
801002fe:	8b 40 54             	mov    0x54(%eax),%eax
80100301:	8b 55 08             	mov    0x8(%ebp),%edx
80100304:	8b 52 50             	mov    0x50(%edx),%edx
80100307:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	8b 40 50             	mov    0x50(%eax),%eax
80100310:	8b 55 08             	mov    0x8(%ebp),%edx
80100313:	8b 52 54             	mov    0x54(%edx),%edx
80100316:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100319:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
8010031f:	8b 45 08             	mov    0x8(%ebp),%eax
80100322:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    bcache.head.next->prev = b;
8010032f:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100334:	8b 55 08             	mov    0x8(%ebp),%edx
80100337:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  }
  
  release(&bcache.lock);
80100342:	83 ec 0c             	sub    $0xc,%esp
80100345:	68 60 e3 18 80       	push   $0x8018e360
8010034a:	e8 c5 4a 00 00       	call   80104e14 <release>
8010034f:	83 c4 10             	add    $0x10,%esp
}
80100352:	90                   	nop
80100353:	c9                   	leave  
80100354:	c3                   	ret    

80100355 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100355:	55                   	push   %ebp
80100356:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100358:	fa                   	cli    
}
80100359:	90                   	nop
8010035a:	5d                   	pop    %ebp
8010035b:	c3                   	ret    

8010035c <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
8010035c:	f3 0f 1e fb          	endbr32 
80100360:	55                   	push   %ebp
80100361:	89 e5                	mov    %esp,%ebp
80100363:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100366:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010036a:	74 1c                	je     80100388 <printint+0x2c>
8010036c:	8b 45 08             	mov    0x8(%ebp),%eax
8010036f:	c1 e8 1f             	shr    $0x1f,%eax
80100372:	0f b6 c0             	movzbl %al,%eax
80100375:	89 45 10             	mov    %eax,0x10(%ebp)
80100378:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010037c:	74 0a                	je     80100388 <printint+0x2c>
    x = -xx;
8010037e:	8b 45 08             	mov    0x8(%ebp),%eax
80100381:	f7 d8                	neg    %eax
80100383:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100386:	eb 06                	jmp    8010038e <printint+0x32>
  else
    x = xx;
80100388:	8b 45 08             	mov    0x8(%ebp),%eax
8010038b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010038e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100395:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010039b:	ba 00 00 00 00       	mov    $0x0,%edx
801003a0:	f7 f1                	div    %ecx
801003a2:	89 d1                	mov    %edx,%ecx
801003a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a7:	8d 50 01             	lea    0x1(%eax),%edx
801003aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003ad:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
801003b4:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003be:	ba 00 00 00 00       	mov    $0x0,%edx
801003c3:	f7 f1                	div    %ecx
801003c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003cc:	75 c7                	jne    80100395 <printint+0x39>

  if(sign)
801003ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003d2:	74 2a                	je     801003fe <printint+0xa2>
    buf[i++] = '-';
801003d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d7:	8d 50 01             	lea    0x1(%eax),%edx
801003da:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003dd:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003e2:	eb 1a                	jmp    801003fe <printint+0xa2>
    consputc(buf[i]);
801003e4:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003ea:	01 d0                	add    %edx,%eax
801003ec:	0f b6 00             	movzbl (%eax),%eax
801003ef:	0f be c0             	movsbl %al,%eax
801003f2:	83 ec 0c             	sub    $0xc,%esp
801003f5:	50                   	push   %eax
801003f6:	e8 9a 03 00 00       	call   80100795 <consputc>
801003fb:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003fe:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100402:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100406:	79 dc                	jns    801003e4 <printint+0x88>
}
80100408:	90                   	nop
80100409:	90                   	nop
8010040a:	c9                   	leave  
8010040b:	c3                   	ret    

8010040c <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
8010040c:	f3 0f 1e fb          	endbr32 
80100410:	55                   	push   %ebp
80100411:	89 e5                	mov    %esp,%ebp
80100413:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100416:	a1 54 d0 18 80       	mov    0x8018d054,%eax
8010041b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010041e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100422:	74 10                	je     80100434 <cprintf+0x28>
    acquire(&cons.lock);
80100424:	83 ec 0c             	sub    $0xc,%esp
80100427:	68 20 d0 18 80       	push   $0x8018d020
8010042c:	e8 71 49 00 00       	call   80104da2 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 8d a9 10 80       	push   $0x8010a98d
80100443:	e8 7d 01 00 00       	call   801005c5 <panic>


  argp = (uint*)(void*)(&fmt + 1);
80100448:	8d 45 0c             	lea    0xc(%ebp),%eax
8010044b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010044e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100455:	e9 2f 01 00 00       	jmp    80100589 <cprintf+0x17d>
    if(c != '%'){
8010045a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010045e:	74 13                	je     80100473 <cprintf+0x67>
      consputc(c);
80100460:	83 ec 0c             	sub    $0xc,%esp
80100463:	ff 75 e4             	pushl  -0x1c(%ebp)
80100466:	e8 2a 03 00 00       	call   80100795 <consputc>
8010046b:	83 c4 10             	add    $0x10,%esp
      continue;
8010046e:	e9 12 01 00 00       	jmp    80100585 <cprintf+0x179>
    }
    c = fmt[++i] & 0xff;
80100473:	8b 55 08             	mov    0x8(%ebp),%edx
80100476:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010047a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010047d:	01 d0                	add    %edx,%eax
8010047f:	0f b6 00             	movzbl (%eax),%eax
80100482:	0f be c0             	movsbl %al,%eax
80100485:	25 ff 00 00 00       	and    $0xff,%eax
8010048a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010048d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100491:	0f 84 14 01 00 00    	je     801005ab <cprintf+0x19f>
      break;
    switch(c){
80100497:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010049b:	74 5e                	je     801004fb <cprintf+0xef>
8010049d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004a1:	0f 8f c2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004a7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004ab:	74 6b                	je     80100518 <cprintf+0x10c>
801004ad:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004b1:	0f 8f b2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004b7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004bb:	74 3e                	je     801004fb <cprintf+0xef>
801004bd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004c1:	0f 8f a2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004cb:	0f 84 89 00 00 00    	je     8010055a <cprintf+0x14e>
801004d1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004d5:	0f 85 8e 00 00 00    	jne    80100569 <cprintf+0x15d>
    case 'd':
      printint(*argp++, 10, 1);
801004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004de:	8d 50 04             	lea    0x4(%eax),%edx
801004e1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e4:	8b 00                	mov    (%eax),%eax
801004e6:	83 ec 04             	sub    $0x4,%esp
801004e9:	6a 01                	push   $0x1
801004eb:	6a 0a                	push   $0xa
801004ed:	50                   	push   %eax
801004ee:	e8 69 fe ff ff       	call   8010035c <printint>
801004f3:	83 c4 10             	add    $0x10,%esp
      break;
801004f6:	e9 8a 00 00 00       	jmp    80100585 <cprintf+0x179>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fe:	8d 50 04             	lea    0x4(%eax),%edx
80100501:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100504:	8b 00                	mov    (%eax),%eax
80100506:	83 ec 04             	sub    $0x4,%esp
80100509:	6a 00                	push   $0x0
8010050b:	6a 10                	push   $0x10
8010050d:	50                   	push   %eax
8010050e:	e8 49 fe ff ff       	call   8010035c <printint>
80100513:	83 c4 10             	add    $0x10,%esp
      break;
80100516:	eb 6d                	jmp    80100585 <cprintf+0x179>
    case 's':
      if((s = (char*)*argp++) == 0)
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100526:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010052a:	75 22                	jne    8010054e <cprintf+0x142>
        s = "(null)";
8010052c:	c7 45 ec 96 a9 10 80 	movl   $0x8010a996,-0x14(%ebp)
      for(; *s; s++)
80100533:	eb 19                	jmp    8010054e <cprintf+0x142>
        consputc(*s);
80100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100538:	0f b6 00             	movzbl (%eax),%eax
8010053b:	0f be c0             	movsbl %al,%eax
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	50                   	push   %eax
80100542:	e8 4e 02 00 00       	call   80100795 <consputc>
80100547:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010054a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010054e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100551:	0f b6 00             	movzbl (%eax),%eax
80100554:	84 c0                	test   %al,%al
80100556:	75 dd                	jne    80100535 <cprintf+0x129>
      break;
80100558:	eb 2b                	jmp    80100585 <cprintf+0x179>
    case '%':
      consputc('%');
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	6a 25                	push   $0x25
8010055f:	e8 31 02 00 00       	call   80100795 <consputc>
80100564:	83 c4 10             	add    $0x10,%esp
      break;
80100567:	eb 1c                	jmp    80100585 <cprintf+0x179>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100569:	83 ec 0c             	sub    $0xc,%esp
8010056c:	6a 25                	push   $0x25
8010056e:	e8 22 02 00 00       	call   80100795 <consputc>
80100573:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100576:	83 ec 0c             	sub    $0xc,%esp
80100579:	ff 75 e4             	pushl  -0x1c(%ebp)
8010057c:	e8 14 02 00 00       	call   80100795 <consputc>
80100581:	83 c4 10             	add    $0x10,%esp
      break;
80100584:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100585:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100589:	8b 55 08             	mov    0x8(%ebp),%edx
8010058c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010058f:	01 d0                	add    %edx,%eax
80100591:	0f b6 00             	movzbl (%eax),%eax
80100594:	0f be c0             	movsbl %al,%eax
80100597:	25 ff 00 00 00       	and    $0xff,%eax
8010059c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010059f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005a3:	0f 85 b1 fe ff ff    	jne    8010045a <cprintf+0x4e>
801005a9:	eb 01                	jmp    801005ac <cprintf+0x1a0>
      break;
801005ab:	90                   	nop
    }
  }

  if(locking)
801005ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005b0:	74 10                	je     801005c2 <cprintf+0x1b6>
    release(&cons.lock);
801005b2:	83 ec 0c             	sub    $0xc,%esp
801005b5:	68 20 d0 18 80       	push   $0x8018d020
801005ba:	e8 55 48 00 00       	call   80104e14 <release>
801005bf:	83 c4 10             	add    $0x10,%esp
}
801005c2:	90                   	nop
801005c3:	c9                   	leave  
801005c4:	c3                   	ret    

801005c5 <panic>:

void
panic(char *s)
{
801005c5:	f3 0f 1e fb          	endbr32 
801005c9:	55                   	push   %ebp
801005ca:	89 e5                	mov    %esp,%ebp
801005cc:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005cf:	e8 81 fd ff ff       	call   80100355 <cli>
  cons.locking = 0;
801005d4:	c7 05 54 d0 18 80 00 	movl   $0x0,0x8018d054
801005db:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005de:	e8 1c 26 00 00       	call   80102bff <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 9d a9 10 80       	push   $0x8010a99d
801005ec:	e8 1b fe ff ff       	call   8010040c <cprintf>
801005f1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005f4:	8b 45 08             	mov    0x8(%ebp),%eax
801005f7:	83 ec 0c             	sub    $0xc,%esp
801005fa:	50                   	push   %eax
801005fb:	e8 0c fe ff ff       	call   8010040c <cprintf>
80100600:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100603:	83 ec 0c             	sub    $0xc,%esp
80100606:	68 b1 a9 10 80       	push   $0x8010a9b1
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 47 48 00 00       	call   80104e6a <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 b3 a9 10 80       	push   $0x8010a9b3
8010063f:	e8 c8 fd ff ff       	call   8010040c <cprintf>
80100644:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100647:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010064b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010064f:	7e de                	jle    8010062f <panic+0x6a>
  panicked = 1; // freeze other CPU
80100651:	c7 05 00 d0 18 80 01 	movl   $0x1,0x8018d000
80100658:	00 00 00 
  for(;;)
8010065b:	eb fe                	jmp    8010065b <panic+0x96>

8010065d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010065d:	f3 0f 1e fb          	endbr32 
80100661:	55                   	push   %ebp
80100662:	89 e5                	mov    %esp,%ebp
80100664:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100667:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010066b:	75 64                	jne    801006d1 <graphic_putc+0x74>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010066d:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100673:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100678:	89 c8                	mov    %ecx,%eax
8010067a:	f7 ea                	imul   %edx
8010067c:	c1 fa 04             	sar    $0x4,%edx
8010067f:	89 c8                	mov    %ecx,%eax
80100681:	c1 f8 1f             	sar    $0x1f,%eax
80100684:	29 c2                	sub    %eax,%edx
80100686:	89 d0                	mov    %edx,%eax
80100688:	6b c0 35             	imul   $0x35,%eax,%eax
8010068b:	29 c1                	sub    %eax,%ecx
8010068d:	89 c8                	mov    %ecx,%eax
8010068f:	ba 35 00 00 00       	mov    $0x35,%edx
80100694:	29 c2                	sub    %eax,%edx
80100696:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010069b:	01 d0                	add    %edx,%eax
8010069d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006a2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006a7:	3d 23 04 00 00       	cmp    $0x423,%eax
801006ac:	0f 8e e0 00 00 00    	jle    80100792 <graphic_putc+0x135>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006b2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006b7:	83 e8 35             	sub    $0x35,%eax
801006ba:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006bf:	83 ec 0c             	sub    $0xc,%esp
801006c2:	6a 1e                	push   $0x1e
801006c4:	e8 1b 80 00 00       	call   801086e4 <graphic_scroll_up>
801006c9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006cc:	e9 c1 00 00 00       	jmp    80100792 <graphic_putc+0x135>
  }else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 1f                	jne    801006f9 <graphic_putc+0x9c>
    if(console_pos>0) --console_pos;
801006da:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006df:	85 c0                	test   %eax,%eax
801006e1:	0f 8e ab 00 00 00    	jle    80100792 <graphic_putc+0x135>
801006e7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ec:	83 e8 01             	sub    $0x1,%eax
801006ef:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006f4:	e9 99 00 00 00       	jmp    80100792 <graphic_putc+0x135>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006f9:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006fe:	3d 23 04 00 00       	cmp    $0x423,%eax
80100703:	7e 1a                	jle    8010071f <graphic_putc+0xc2>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
80100705:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010070a:	83 e8 35             	sub    $0x35,%eax
8010070d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
80100712:	83 ec 0c             	sub    $0xc,%esp
80100715:	6a 1e                	push   $0x1e
80100717:	e8 c8 7f 00 00       	call   801086e4 <graphic_scroll_up>
8010071c:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
8010071f:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100725:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010072a:	89 c8                	mov    %ecx,%eax
8010072c:	f7 ea                	imul   %edx
8010072e:	c1 fa 04             	sar    $0x4,%edx
80100731:	89 c8                	mov    %ecx,%eax
80100733:	c1 f8 1f             	sar    $0x1f,%eax
80100736:	29 c2                	sub    %eax,%edx
80100738:	89 d0                	mov    %edx,%eax
8010073a:	6b c0 35             	imul   $0x35,%eax,%eax
8010073d:	29 c1                	sub    %eax,%ecx
8010073f:	89 c8                	mov    %ecx,%eax
80100741:	89 c2                	mov    %eax,%edx
80100743:	c1 e2 04             	shl    $0x4,%edx
80100746:	29 c2                	sub    %eax,%edx
80100748:	89 d0                	mov    %edx,%eax
8010074a:	83 c0 02             	add    $0x2,%eax
8010074d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
80100750:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100756:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010075b:	89 c8                	mov    %ecx,%eax
8010075d:	f7 ea                	imul   %edx
8010075f:	c1 fa 04             	sar    $0x4,%edx
80100762:	89 c8                	mov    %ecx,%eax
80100764:	c1 f8 1f             	sar    $0x1f,%eax
80100767:	29 c2                	sub    %eax,%edx
80100769:	89 d0                	mov    %edx,%eax
8010076b:	6b c0 1e             	imul   $0x1e,%eax,%eax
8010076e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
80100771:	83 ec 04             	sub    $0x4,%esp
80100774:	ff 75 08             	pushl  0x8(%ebp)
80100777:	ff 75 f0             	pushl  -0x10(%ebp)
8010077a:	ff 75 f4             	pushl  -0xc(%ebp)
8010077d:	e8 d6 7f 00 00       	call   80108758 <font_render>
80100782:	83 c4 10             	add    $0x10,%esp
    console_pos++;
80100785:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010078a:	83 c0 01             	add    $0x1,%eax
8010078d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
80100792:	90                   	nop
80100793:	c9                   	leave  
80100794:	c3                   	ret    

80100795 <consputc>:


void
consputc(int c)
{
80100795:	f3 0f 1e fb          	endbr32 
80100799:	55                   	push   %ebp
8010079a:	89 e5                	mov    %esp,%ebp
8010079c:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010079f:	a1 00 d0 18 80       	mov    0x8018d000,%eax
801007a4:	85 c0                	test   %eax,%eax
801007a6:	74 07                	je     801007af <consputc+0x1a>
    cli();
801007a8:	e8 a8 fb ff ff       	call   80100355 <cli>
    for(;;)
801007ad:	eb fe                	jmp    801007ad <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
801007af:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007b6:	75 29                	jne    801007e1 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b8:	83 ec 0c             	sub    $0xc,%esp
801007bb:	6a 08                	push   $0x8
801007bd:	e8 36 63 00 00       	call   80106af8 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 29 63 00 00       	call   80106af8 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 1c 63 00 00       	call   80106af8 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 0c 63 00 00       	call   80106af8 <uartputc>
801007ec:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007ef:	83 ec 0c             	sub    $0xc,%esp
801007f2:	ff 75 08             	pushl  0x8(%ebp)
801007f5:	e8 63 fe ff ff       	call   8010065d <graphic_putc>
801007fa:	83 c4 10             	add    $0x10,%esp
}
801007fd:	90                   	nop
801007fe:	c9                   	leave  
801007ff:	c3                   	ret    

80100800 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100800:	f3 0f 1e fb          	endbr32 
80100804:	55                   	push   %ebp
80100805:	89 e5                	mov    %esp,%ebp
80100807:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
8010080a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100811:	83 ec 0c             	sub    $0xc,%esp
80100814:	68 20 d0 18 80       	push   $0x8018d020
80100819:	e8 84 45 00 00       	call   80104da2 <acquire>
8010081e:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100821:	e9 52 01 00 00       	jmp    80100978 <consoleintr+0x178>
    switch(c){
80100826:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010082a:	0f 84 81 00 00 00    	je     801008b1 <consoleintr+0xb1>
80100830:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100834:	0f 8f ac 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010083a:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010083e:	74 43                	je     80100883 <consoleintr+0x83>
80100840:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100844:	0f 8f 9c 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010084a:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
8010084e:	74 61                	je     801008b1 <consoleintr+0xb1>
80100850:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100854:	0f 85 8c 00 00 00    	jne    801008e6 <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010085a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100861:	e9 12 01 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100866:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010086b:	83 e8 01             	sub    $0x1,%eax
8010086e:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
80100873:	83 ec 0c             	sub    $0xc,%esp
80100876:	68 00 01 00 00       	push   $0x100
8010087b:	e8 15 ff ff ff       	call   80100795 <consputc>
80100880:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100883:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
80100889:	a1 44 2d 19 80       	mov    0x80192d44,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 e2 00 00 00    	je     80100978 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100896:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
      while(input.e != input.w &&
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 ba                	jne    80100866 <consoleintr+0x66>
      }
      break;
801008ac:	e9 c7 00 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008b7:	a1 44 2d 19 80       	mov    0x80192d44,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 b4 00 00 00    	je     80100978 <consoleintr+0x178>
        input.e--;
801008c4:	a1 48 2d 19 80       	mov    0x80192d48,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
801008d1:	83 ec 0c             	sub    $0xc,%esp
801008d4:	68 00 01 00 00       	push   $0x100
801008d9:	e8 b7 fe ff ff       	call   80100795 <consputc>
801008de:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008e1:	e9 92 00 00 00       	jmp    80100978 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008ea:	0f 84 87 00 00 00    	je     80100977 <consoleintr+0x177>
801008f0:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008f6:	a1 40 2d 19 80       	mov    0x80192d40,%eax
801008fb:	29 c2                	sub    %eax,%edx
801008fd:	89 d0                	mov    %edx,%eax
801008ff:	83 f8 7f             	cmp    $0x7f,%eax
80100902:	77 73                	ja     80100977 <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
80100904:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100908:	74 05                	je     8010090f <consoleintr+0x10f>
8010090a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010090d:	eb 05                	jmp    80100914 <consoleintr+0x114>
8010090f:	b8 0a 00 00 00       	mov    $0xa,%eax
80100914:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100917:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010091c:	8d 50 01             	lea    0x1(%eax),%edx
8010091f:	89 15 48 2d 19 80    	mov    %edx,0x80192d48
80100925:	83 e0 7f             	and    $0x7f,%eax
80100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010092b:	88 90 c0 2c 19 80    	mov    %dl,-0x7fe6d340(%eax)
        consputc(c);
80100931:	83 ec 0c             	sub    $0xc,%esp
80100934:	ff 75 f0             	pushl  -0x10(%ebp)
80100937:	e8 59 fe ff ff       	call   80100795 <consputc>
8010093c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010093f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100943:	74 18                	je     8010095d <consoleintr+0x15d>
80100945:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100949:	74 12                	je     8010095d <consoleintr+0x15d>
8010094b:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100950:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100956:	83 ea 80             	sub    $0xffffff80,%edx
80100959:	39 d0                	cmp    %edx,%eax
8010095b:	75 1a                	jne    80100977 <consoleintr+0x177>
          input.w = input.e;
8010095d:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100962:	a3 44 2d 19 80       	mov    %eax,0x80192d44
          wakeup(&input.r);
80100967:	83 ec 0c             	sub    $0xc,%esp
8010096a:	68 40 2d 19 80       	push   $0x80192d40
8010096f:	e8 7f 3f 00 00       	call   801048f3 <wakeup>
80100974:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100977:	90                   	nop
  while((c = getc()) >= 0){
80100978:	8b 45 08             	mov    0x8(%ebp),%eax
8010097b:	ff d0                	call   *%eax
8010097d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100984:	0f 89 9c fe ff ff    	jns    80100826 <consoleintr+0x26>
    }
  }
  release(&cons.lock);
8010098a:	83 ec 0c             	sub    $0xc,%esp
8010098d:	68 20 d0 18 80       	push   $0x8018d020
80100992:	e8 7d 44 00 00       	call   80104e14 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 14 40 00 00       	call   801049b9 <procdump>
  }
}
801009a5:	90                   	nop
801009a6:	c9                   	leave  
801009a7:	c3                   	ret    

801009a8 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009a8:	f3 0f 1e fb          	endbr32 
801009ac:	55                   	push   %ebp
801009ad:	89 e5                	mov    %esp,%ebp
801009af:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009b2:	83 ec 0c             	sub    $0xc,%esp
801009b5:	ff 75 08             	pushl  0x8(%ebp)
801009b8:	e8 d6 11 00 00       	call   80101b93 <iunlock>
801009bd:	83 c4 10             	add    $0x10,%esp
  target = n;
801009c0:	8b 45 10             	mov    0x10(%ebp),%eax
801009c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	68 20 d0 18 80       	push   $0x8018d020
801009ce:	e8 cf 43 00 00       	call   80104da2 <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 c9 31 00 00       	call   80103ba9 <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 d0 18 80       	push   $0x8018d020
801009ef:	e8 20 44 00 00       	call   80104e14 <release>
801009f4:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	pushl  0x8(%ebp)
801009fd:	e8 7a 10 00 00       	call   80101a7c <ilock>
80100a02:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a0a:	e9 ab 00 00 00       	jmp    80100aba <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a0f:	83 ec 08             	sub    $0x8,%esp
80100a12:	68 20 d0 18 80       	push   $0x8018d020
80100a17:	68 40 2d 19 80       	push   $0x80192d40
80100a1c:	e8 e0 3d 00 00       	call   80104801 <sleep>
80100a21:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a24:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100a2a:	a1 44 2d 19 80       	mov    0x80192d44,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 a8                	je     801009db <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a33:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a38:	8d 50 01             	lea    0x1(%eax),%edx
80100a3b:	89 15 40 2d 19 80    	mov    %edx,0x80192d40
80100a41:	83 e0 7f             	and    $0x7f,%eax
80100a44:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a51:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a55:	75 17                	jne    80100a6e <consoleread+0xc6>
      if(n < target){
80100a57:	8b 45 10             	mov    0x10(%ebp),%eax
80100a5a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a5d:	76 2f                	jbe    80100a8e <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a5f:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a64:	83 e8 01             	sub    $0x1,%eax
80100a67:	a3 40 2d 19 80       	mov    %eax,0x80192d40
      }
      break;
80100a6c:	eb 20                	jmp    80100a8e <consoleread+0xe6>
    }
    *dst++ = c;
80100a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a71:	8d 50 01             	lea    0x1(%eax),%edx
80100a74:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a7a:	88 10                	mov    %dl,(%eax)
    --n;
80100a7c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a80:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a84:	74 0b                	je     80100a91 <consoleread+0xe9>
  while(n > 0){
80100a86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a8a:	7f 98                	jg     80100a24 <consoleread+0x7c>
80100a8c:	eb 04                	jmp    80100a92 <consoleread+0xea>
      break;
80100a8e:	90                   	nop
80100a8f:	eb 01                	jmp    80100a92 <consoleread+0xea>
      break;
80100a91:	90                   	nop
  }
  release(&cons.lock);
80100a92:	83 ec 0c             	sub    $0xc,%esp
80100a95:	68 20 d0 18 80       	push   $0x8018d020
80100a9a:	e8 75 43 00 00       	call   80104e14 <release>
80100a9f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aa2:	83 ec 0c             	sub    $0xc,%esp
80100aa5:	ff 75 08             	pushl  0x8(%ebp)
80100aa8:	e8 cf 0f 00 00       	call   80101a7c <ilock>
80100aad:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ab0:	8b 45 10             	mov    0x10(%ebp),%eax
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	29 c2                	sub    %eax,%edx
80100ab8:	89 d0                	mov    %edx,%eax
}
80100aba:	c9                   	leave  
80100abb:	c3                   	ret    

80100abc <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100abc:	f3 0f 1e fb          	endbr32 
80100ac0:	55                   	push   %ebp
80100ac1:	89 e5                	mov    %esp,%ebp
80100ac3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	ff 75 08             	pushl  0x8(%ebp)
80100acc:	e8 c2 10 00 00       	call   80101b93 <iunlock>
80100ad1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ad4:	83 ec 0c             	sub    $0xc,%esp
80100ad7:	68 20 d0 18 80       	push   $0x8018d020
80100adc:	e8 c1 42 00 00       	call   80104da2 <acquire>
80100ae1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ae4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100aeb:	eb 21                	jmp    80100b0e <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100aed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af3:	01 d0                	add    %edx,%eax
80100af5:	0f b6 00             	movzbl (%eax),%eax
80100af8:	0f be c0             	movsbl %al,%eax
80100afb:	0f b6 c0             	movzbl %al,%eax
80100afe:	83 ec 0c             	sub    $0xc,%esp
80100b01:	50                   	push   %eax
80100b02:	e8 8e fc ff ff       	call   80100795 <consputc>
80100b07:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b11:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b14:	7c d7                	jl     80100aed <consolewrite+0x31>
  release(&cons.lock);
80100b16:	83 ec 0c             	sub    $0xc,%esp
80100b19:	68 20 d0 18 80       	push   $0x8018d020
80100b1e:	e8 f1 42 00 00       	call   80104e14 <release>
80100b23:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	ff 75 08             	pushl  0x8(%ebp)
80100b2c:	e8 4b 0f 00 00       	call   80101a7c <ilock>
80100b31:	83 c4 10             	add    $0x10,%esp

  return n;
80100b34:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b37:	c9                   	leave  
80100b38:	c3                   	ret    

80100b39 <consoleinit>:

void
consoleinit(void)
{
80100b39:	f3 0f 1e fb          	endbr32 
80100b3d:	55                   	push   %ebp
80100b3e:	89 e5                	mov    %esp,%ebp
80100b40:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b43:	c7 05 00 d0 18 80 00 	movl   $0x0,0x8018d000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 b7 a9 10 80       	push   $0x8010a9b7
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 1d 42 00 00       	call   80104d7c <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 bf a9 10 80 	movl   $0x8010a9bf,-0xc(%ebp)
80100b7d:	eb 19                	jmp    80100b98 <consoleinit+0x5f>
    graphic_putc(*p);
80100b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b82:	0f b6 00             	movzbl (%eax),%eax
80100b85:	0f be c0             	movsbl %al,%eax
80100b88:	83 ec 0c             	sub    $0xc,%esp
80100b8b:	50                   	push   %eax
80100b8c:	e8 cc fa ff ff       	call   8010065d <graphic_putc>
80100b91:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b9b:	0f b6 00             	movzbl (%eax),%eax
80100b9e:	84 c0                	test   %al,%al
80100ba0:	75 dd                	jne    80100b7f <consoleinit+0x46>
  
  cons.locking = 1;
80100ba2:	c7 05 54 d0 18 80 01 	movl   $0x1,0x8018d054
80100ba9:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bac:	83 ec 08             	sub    $0x8,%esp
80100baf:	6a 00                	push   $0x0
80100bb1:	6a 01                	push   $0x1
80100bb3:	e8 54 1b 00 00       	call   8010270c <ioapicenable>
80100bb8:	83 c4 10             	add    $0x10,%esp
}
80100bbb:	90                   	nop
80100bbc:	c9                   	leave  
80100bbd:	c3                   	ret    

80100bbe <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bbe:	f3 0f 1e fb          	endbr32 
80100bc2:	55                   	push   %ebp
80100bc3:	89 e5                	mov    %esp,%ebp
80100bc5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bcb:	e8 d9 2f 00 00       	call   80103ba9 <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd3:	e8 99 25 00 00       	call   80103171 <begin_op>

  if((ip = namei(path)) == 0){
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	pushl  0x8(%ebp)
80100bde:	e8 04 1a 00 00       	call   801025e7 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
    end_op();
80100bef:	e8 0d 26 00 00       	call   80103201 <end_op>
    cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 d5 a9 10 80       	push   $0x8010a9d5
80100bfc:	e8 0b f8 ff ff       	call   8010040c <cprintf>
80100c01:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c09:	e9 f1 03 00 00       	jmp    80100fff <exec+0x441>
  }
  ilock(ip);
80100c0e:	83 ec 0c             	sub    $0xc,%esp
80100c11:	ff 75 d8             	pushl  -0x28(%ebp)
80100c14:	e8 63 0e 00 00       	call   80101a7c <ilock>
80100c19:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c1c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c2d:	50                   	push   %eax
80100c2e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c31:	e8 4e 13 00 00       	call   80101f84 <readi>
80100c36:	83 c4 10             	add    $0x10,%esp
80100c39:	83 f8 34             	cmp    $0x34,%eax
80100c3c:	0f 85 66 03 00 00    	jne    80100fa8 <exec+0x3ea>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c42:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c48:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4d:	0f 85 58 03 00 00    	jne    80100fab <exec+0x3ed>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c53:	e8 b4 6e 00 00       	call   80107b0c <setupkvm>
80100c58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c5f:	0f 84 49 03 00 00    	je     80100fae <exec+0x3f0>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c65:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c6c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c73:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c79:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7c:	e9 de 00 00 00       	jmp    80100d5f <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c84:	6a 20                	push   $0x20
80100c86:	50                   	push   %eax
80100c87:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c8d:	50                   	push   %eax
80100c8e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c91:	e8 ee 12 00 00       	call   80101f84 <readi>
80100c96:	83 c4 10             	add    $0x10,%esp
80100c99:	83 f8 20             	cmp    $0x20,%eax
80100c9c:	0f 85 0f 03 00 00    	jne    80100fb1 <exec+0x3f3>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ca2:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ca8:	83 f8 01             	cmp    $0x1,%eax
80100cab:	0f 85 a0 00 00 00    	jne    80100d51 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100cb1:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb7:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cbd:	39 c2                	cmp    %eax,%edx
80100cbf:	0f 82 ef 02 00 00    	jb     80100fb4 <exec+0x3f6>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cc5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd1:	01 c2                	add    %eax,%edx
80100cd3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd9:	39 c2                	cmp    %eax,%edx
80100cdb:	0f 82 d6 02 00 00    	jb     80100fb7 <exec+0x3f9>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ced:	01 d0                	add    %edx,%eax
80100cef:	83 ec 04             	sub    $0x4,%esp
80100cf2:	50                   	push   %eax
80100cf3:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf9:	e8 20 72 00 00       	call   80107f1e <allocuvm>
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d08:	0f 84 ac 02 00 00    	je     80100fba <exec+0x3fc>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d0e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d14:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d19:	85 c0                	test   %eax,%eax
80100d1b:	0f 85 9c 02 00 00    	jne    80100fbd <exec+0x3ff>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d21:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d27:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2d:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d33:	83 ec 0c             	sub    $0xc,%esp
80100d36:	52                   	push   %edx
80100d37:	50                   	push   %eax
80100d38:	ff 75 d8             	pushl  -0x28(%ebp)
80100d3b:	51                   	push   %ecx
80100d3c:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d3f:	e8 09 71 00 00       	call   80107e4d <loaduvm>
80100d44:	83 c4 20             	add    $0x20,%esp
80100d47:	85 c0                	test   %eax,%eax
80100d49:	0f 88 71 02 00 00    	js     80100fc0 <exec+0x402>
80100d4f:	eb 01                	jmp    80100d52 <exec+0x194>
      continue;
80100d51:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d52:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d59:	83 c0 20             	add    $0x20,%eax
80100d5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d5f:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d66:	0f b7 c0             	movzwl %ax,%eax
80100d69:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d6c:	0f 8c 0f ff ff ff    	jl     80100c81 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100d72:	83 ec 0c             	sub    $0xc,%esp
80100d75:	ff 75 d8             	pushl  -0x28(%ebp)
80100d78:	e8 3c 0f 00 00       	call   80101cb9 <iunlockput>
80100d7d:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d80:	e8 7c 24 00 00       	call   80103201 <end_op>
  ip = 0;
80100d85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8f:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9f:	05 00 20 00 00       	add    $0x2000,%eax
80100da4:	83 ec 04             	sub    $0x4,%esp
80100da7:	50                   	push   %eax
80100da8:	ff 75 e0             	pushl  -0x20(%ebp)
80100dab:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dae:	e8 6b 71 00 00       	call   80107f1e <allocuvm>
80100db3:	83 c4 10             	add    $0x10,%esp
80100db6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100db9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dbd:	0f 84 00 02 00 00    	je     80100fc3 <exec+0x405>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcb:	83 ec 08             	sub    $0x8,%esp
80100dce:	50                   	push   %eax
80100dcf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dd2:	e8 b5 73 00 00       	call   8010818c <clearpteu>
80100dd7:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ddd:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de7:	e9 96 00 00 00       	jmp    80100e82 <exec+0x2c4>
    if(argc >= MAXARG)
80100dec:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df0:	0f 87 d0 01 00 00    	ja     80100fc6 <exec+0x408>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e03:	01 d0                	add    %edx,%eax
80100e05:	8b 00                	mov    (%eax),%eax
80100e07:	83 ec 0c             	sub    $0xc,%esp
80100e0a:	50                   	push   %eax
80100e0b:	e8 8a 44 00 00       	call   8010529a <strlen>
80100e10:	83 c4 10             	add    $0x10,%esp
80100e13:	89 c2                	mov    %eax,%edx
80100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e18:	29 d0                	sub    %edx,%eax
80100e1a:	83 e8 01             	sub    $0x1,%eax
80100e1d:	83 e0 fc             	and    $0xfffffffc,%eax
80100e20:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e30:	01 d0                	add    %edx,%eax
80100e32:	8b 00                	mov    (%eax),%eax
80100e34:	83 ec 0c             	sub    $0xc,%esp
80100e37:	50                   	push   %eax
80100e38:	e8 5d 44 00 00       	call   8010529a <strlen>
80100e3d:	83 c4 10             	add    $0x10,%esp
80100e40:	83 c0 01             	add    $0x1,%eax
80100e43:	89 c1                	mov    %eax,%ecx
80100e45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e52:	01 d0                	add    %edx,%eax
80100e54:	8b 00                	mov    (%eax),%eax
80100e56:	51                   	push   %ecx
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 d4 74 00 00       	call   80108337 <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 5b 01 00 00    	js     80100fc9 <exec+0x40b>
      goto bad;
    ustack[3+argc] = sp;
80100e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e71:	8d 50 03             	lea    0x3(%eax),%edx
80100e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e77:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e7e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e8f:	01 d0                	add    %edx,%eax
80100e91:	8b 00                	mov    (%eax),%eax
80100e93:	85 c0                	test   %eax,%eax
80100e95:	0f 85 51 ff ff ff    	jne    80100dec <exec+0x22e>
  }
  ustack[3+argc] = 0;
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	83 c0 03             	add    $0x3,%eax
80100ea1:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ea8:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eac:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eb3:	ff ff ff 
  ustack[1] = argc;
80100eb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb9:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ebf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec2:	83 c0 01             	add    $0x1,%eax
80100ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ecf:	29 d0                	sub    %edx,%eax
80100ed1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eda:	83 c0 04             	add    $0x4,%eax
80100edd:	c1 e0 02             	shl    $0x2,%eax
80100ee0:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee6:	83 c0 04             	add    $0x4,%eax
80100ee9:	c1 e0 02             	shl    $0x2,%eax
80100eec:	50                   	push   %eax
80100eed:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ef3:	50                   	push   %eax
80100ef4:	ff 75 dc             	pushl  -0x24(%ebp)
80100ef7:	ff 75 d4             	pushl  -0x2c(%ebp)
80100efa:	e8 38 74 00 00       	call   80108337 <copyout>
80100eff:	83 c4 10             	add    $0x10,%esp
80100f02:	85 c0                	test   %eax,%eax
80100f04:	0f 88 c2 00 00 00    	js     80100fcc <exec+0x40e>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f16:	eb 17                	jmp    80100f2f <exec+0x371>
    if(*s == '/')
80100f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1b:	0f b6 00             	movzbl (%eax),%eax
80100f1e:	3c 2f                	cmp    $0x2f,%al
80100f20:	75 09                	jne    80100f2b <exec+0x36d>
      last = s+1;
80100f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f25:	83 c0 01             	add    $0x1,%eax
80100f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f32:	0f b6 00             	movzbl (%eax),%eax
80100f35:	84 c0                	test   %al,%al
80100f37:	75 df                	jne    80100f18 <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f39:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3c:	83 c0 6c             	add    $0x6c,%eax
80100f3f:	83 ec 04             	sub    $0x4,%esp
80100f42:	6a 10                	push   $0x10
80100f44:	ff 75 f0             	pushl  -0x10(%ebp)
80100f47:	50                   	push   %eax
80100f48:	e8 ff 42 00 00       	call   8010524c <safestrcpy>
80100f4d:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f50:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f53:	8b 40 04             	mov    0x4(%eax),%eax
80100f56:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f59:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f5f:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f62:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f65:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f68:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6d:	8b 40 18             	mov    0x18(%eax),%eax
80100f70:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f76:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f79:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7c:	8b 40 18             	mov    0x18(%eax),%eax
80100f7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f82:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f85:	83 ec 0c             	sub    $0xc,%esp
80100f88:	ff 75 d0             	pushl  -0x30(%ebp)
80100f8b:	e8 a6 6c 00 00       	call   80107c36 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 51 71 00 00       	call   801080ef <freevm>
80100f9e:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80100fa6:	eb 57                	jmp    80100fff <exec+0x441>
    goto bad;
80100fa8:	90                   	nop
80100fa9:	eb 22                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fab:	90                   	nop
80100fac:	eb 1f                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fae:	90                   	nop
80100faf:	eb 1c                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb1:	90                   	nop
80100fb2:	eb 19                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb4:	90                   	nop
80100fb5:	eb 16                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb7:	90                   	nop
80100fb8:	eb 13                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fba:	90                   	nop
80100fbb:	eb 10                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fbd:	90                   	nop
80100fbe:	eb 0d                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc0:	90                   	nop
80100fc1:	eb 0a                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fc3:	90                   	nop
80100fc4:	eb 07                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc6:	90                   	nop
80100fc7:	eb 04                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc9:	90                   	nop
80100fca:	eb 01                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fcc:	90                   	nop

 bad:
  if(pgdir)
80100fcd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fd1:	74 0e                	je     80100fe1 <exec+0x423>
    freevm(pgdir);
80100fd3:	83 ec 0c             	sub    $0xc,%esp
80100fd6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fd9:	e8 11 71 00 00       	call   801080ef <freevm>
80100fde:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fe1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fe5:	74 13                	je     80100ffa <exec+0x43c>
    iunlockput(ip);
80100fe7:	83 ec 0c             	sub    $0xc,%esp
80100fea:	ff 75 d8             	pushl  -0x28(%ebp)
80100fed:	e8 c7 0c 00 00       	call   80101cb9 <iunlockput>
80100ff2:	83 c4 10             	add    $0x10,%esp
    end_op();
80100ff5:	e8 07 22 00 00       	call   80103201 <end_op>
  }
  return -1;
80100ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fff:	c9                   	leave  
80101000:	c3                   	ret    

80101001 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101001:	f3 0f 1e fb          	endbr32 
80101005:	55                   	push   %ebp
80101006:	89 e5                	mov    %esp,%ebp
80101008:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010100b:	83 ec 08             	sub    $0x8,%esp
8010100e:	68 e1 a9 10 80       	push   $0x8010a9e1
80101013:	68 60 2d 19 80       	push   $0x80192d60
80101018:	e8 5f 3d 00 00       	call   80104d7c <initlock>
8010101d:	83 c4 10             	add    $0x10,%esp
}
80101020:	90                   	nop
80101021:	c9                   	leave  
80101022:	c3                   	ret    

80101023 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101023:	f3 0f 1e fb          	endbr32 
80101027:	55                   	push   %ebp
80101028:	89 e5                	mov    %esp,%ebp
8010102a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	68 60 2d 19 80       	push   $0x80192d60
80101035:	e8 68 3d 00 00       	call   80104da2 <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
80101044:	eb 2d                	jmp    80101073 <filealloc+0x50>
    if(f->ref == 0){
80101046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101049:	8b 40 04             	mov    0x4(%eax),%eax
8010104c:	85 c0                	test   %eax,%eax
8010104e:	75 1f                	jne    8010106f <filealloc+0x4c>
      f->ref = 1;
80101050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101053:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 60 2d 19 80       	push   $0x80192d60
80101062:	e8 ad 3d 00 00       	call   80104e14 <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 60 2d 19 80       	push   $0x80192d60
80101085:	e8 8a 3d 00 00       	call   80104e14 <release>
8010108a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010108d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101092:	c9                   	leave  
80101093:	c3                   	ret    

80101094 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101094:	f3 0f 1e fb          	endbr32 
80101098:	55                   	push   %ebp
80101099:	89 e5                	mov    %esp,%ebp
8010109b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010109e:	83 ec 0c             	sub    $0xc,%esp
801010a1:	68 60 2d 19 80       	push   $0x80192d60
801010a6:	e8 f7 3c 00 00       	call   80104da2 <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 e8 a9 10 80       	push   $0x8010a9e8
801010c0:	e8 00 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 04             	mov    0x4(%eax),%eax
801010cb:	8d 50 01             	lea    0x1(%eax),%edx
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 60 2d 19 80       	push   $0x80192d60
801010dc:	e8 33 3d 00 00       	call   80104e14 <release>
801010e1:	83 c4 10             	add    $0x10,%esp
  return f;
801010e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010e7:	c9                   	leave  
801010e8:	c3                   	ret    

801010e9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010e9:	f3 0f 1e fb          	endbr32 
801010ed:	55                   	push   %ebp
801010ee:	89 e5                	mov    %esp,%ebp
801010f0:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010f3:	83 ec 0c             	sub    $0xc,%esp
801010f6:	68 60 2d 19 80       	push   $0x80192d60
801010fb:	e8 a2 3c 00 00       	call   80104da2 <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 f0 a9 10 80       	push   $0x8010a9f0
80101115:	e8 ab f4 ff ff       	call   801005c5 <panic>
  if(--f->ref > 0){
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 04             	mov    0x4(%eax),%eax
80101120:	8d 50 ff             	lea    -0x1(%eax),%edx
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	89 50 04             	mov    %edx,0x4(%eax)
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 40 04             	mov    0x4(%eax),%eax
8010112f:	85 c0                	test   %eax,%eax
80101131:	7e 15                	jle    80101148 <fileclose+0x5f>
    release(&ftable.lock);
80101133:	83 ec 0c             	sub    $0xc,%esp
80101136:	68 60 2d 19 80       	push   $0x80192d60
8010113b:	e8 d4 3c 00 00       	call   80104e14 <release>
80101140:	83 c4 10             	add    $0x10,%esp
80101143:	e9 8b 00 00 00       	jmp    801011d3 <fileclose+0xea>
    return;
  }
  ff = *f;
80101148:	8b 45 08             	mov    0x8(%ebp),%eax
8010114b:	8b 10                	mov    (%eax),%edx
8010114d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101150:	8b 50 04             	mov    0x4(%eax),%edx
80101153:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101156:	8b 50 08             	mov    0x8(%eax),%edx
80101159:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010115c:	8b 50 0c             	mov    0xc(%eax),%edx
8010115f:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101162:	8b 50 10             	mov    0x10(%eax),%edx
80101165:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101168:	8b 40 14             	mov    0x14(%eax),%eax
8010116b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010116e:	8b 45 08             	mov    0x8(%ebp),%eax
80101171:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	68 60 2d 19 80       	push   $0x80192d60
80101189:	e8 86 3c 00 00       	call   80104e14 <release>
8010118e:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101191:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101194:	83 f8 01             	cmp    $0x1,%eax
80101197:	75 19                	jne    801011b2 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101199:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010119d:	0f be d0             	movsbl %al,%edx
801011a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011a3:	83 ec 08             	sub    $0x8,%esp
801011a6:	52                   	push   %edx
801011a7:	50                   	push   %eax
801011a8:	e8 73 26 00 00       	call   80103820 <pipeclose>
801011ad:	83 c4 10             	add    $0x10,%esp
801011b0:	eb 21                	jmp    801011d3 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011b5:	83 f8 02             	cmp    $0x2,%eax
801011b8:	75 19                	jne    801011d3 <fileclose+0xea>
    begin_op();
801011ba:	e8 b2 1f 00 00       	call   80103171 <begin_op>
    iput(ff.ip);
801011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011c2:	83 ec 0c             	sub    $0xc,%esp
801011c5:	50                   	push   %eax
801011c6:	e8 1a 0a 00 00       	call   80101be5 <iput>
801011cb:	83 c4 10             	add    $0x10,%esp
    end_op();
801011ce:	e8 2e 20 00 00       	call   80103201 <end_op>
  }
}
801011d3:	c9                   	leave  
801011d4:	c3                   	ret    

801011d5 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011d5:	f3 0f 1e fb          	endbr32 
801011d9:	55                   	push   %ebp
801011da:	89 e5                	mov    %esp,%ebp
801011dc:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011df:	8b 45 08             	mov    0x8(%ebp),%eax
801011e2:	8b 00                	mov    (%eax),%eax
801011e4:	83 f8 02             	cmp    $0x2,%eax
801011e7:	75 40                	jne    80101229 <filestat+0x54>
    ilock(f->ip);
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 40 10             	mov    0x10(%eax),%eax
801011ef:	83 ec 0c             	sub    $0xc,%esp
801011f2:	50                   	push   %eax
801011f3:	e8 84 08 00 00       	call   80101a7c <ilock>
801011f8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011fb:	8b 45 08             	mov    0x8(%ebp),%eax
801011fe:	8b 40 10             	mov    0x10(%eax),%eax
80101201:	83 ec 08             	sub    $0x8,%esp
80101204:	ff 75 0c             	pushl  0xc(%ebp)
80101207:	50                   	push   %eax
80101208:	e8 2d 0d 00 00       	call   80101f3a <stati>
8010120d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101210:	8b 45 08             	mov    0x8(%ebp),%eax
80101213:	8b 40 10             	mov    0x10(%eax),%eax
80101216:	83 ec 0c             	sub    $0xc,%esp
80101219:	50                   	push   %eax
8010121a:	e8 74 09 00 00       	call   80101b93 <iunlock>
8010121f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101222:	b8 00 00 00 00       	mov    $0x0,%eax
80101227:	eb 05                	jmp    8010122e <filestat+0x59>
  }
  return -1;
80101229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010122e:	c9                   	leave  
8010122f:	c3                   	ret    

80101230 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101230:	f3 0f 1e fb          	endbr32 
80101234:	55                   	push   %ebp
80101235:	89 e5                	mov    %esp,%ebp
80101237:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010123a:	8b 45 08             	mov    0x8(%ebp),%eax
8010123d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101241:	84 c0                	test   %al,%al
80101243:	75 0a                	jne    8010124f <fileread+0x1f>
    return -1;
80101245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010124a:	e9 9b 00 00 00       	jmp    801012ea <fileread+0xba>
  if(f->type == FD_PIPE)
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	8b 00                	mov    (%eax),%eax
80101254:	83 f8 01             	cmp    $0x1,%eax
80101257:	75 1a                	jne    80101273 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101259:	8b 45 08             	mov    0x8(%ebp),%eax
8010125c:	8b 40 0c             	mov    0xc(%eax),%eax
8010125f:	83 ec 04             	sub    $0x4,%esp
80101262:	ff 75 10             	pushl  0x10(%ebp)
80101265:	ff 75 0c             	pushl  0xc(%ebp)
80101268:	50                   	push   %eax
80101269:	e8 67 27 00 00       	call   801039d5 <piperead>
8010126e:	83 c4 10             	add    $0x10,%esp
80101271:	eb 77                	jmp    801012ea <fileread+0xba>
  if(f->type == FD_INODE){
80101273:	8b 45 08             	mov    0x8(%ebp),%eax
80101276:	8b 00                	mov    (%eax),%eax
80101278:	83 f8 02             	cmp    $0x2,%eax
8010127b:	75 60                	jne    801012dd <fileread+0xad>
    ilock(f->ip);
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 40 10             	mov    0x10(%eax),%eax
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	50                   	push   %eax
80101287:	e8 f0 07 00 00       	call   80101a7c <ilock>
8010128c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010128f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 50 14             	mov    0x14(%eax),%edx
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	8b 40 10             	mov    0x10(%eax),%eax
8010129e:	51                   	push   %ecx
8010129f:	52                   	push   %edx
801012a0:	ff 75 0c             	pushl  0xc(%ebp)
801012a3:	50                   	push   %eax
801012a4:	e8 db 0c 00 00       	call   80101f84 <readi>
801012a9:	83 c4 10             	add    $0x10,%esp
801012ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012b3:	7e 11                	jle    801012c6 <fileread+0x96>
      f->off += r;
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 50 14             	mov    0x14(%eax),%edx
801012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012be:	01 c2                	add    %eax,%edx
801012c0:	8b 45 08             	mov    0x8(%ebp),%eax
801012c3:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	8b 40 10             	mov    0x10(%eax),%eax
801012cc:	83 ec 0c             	sub    $0xc,%esp
801012cf:	50                   	push   %eax
801012d0:	e8 be 08 00 00       	call   80101b93 <iunlock>
801012d5:	83 c4 10             	add    $0x10,%esp
    return r;
801012d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012db:	eb 0d                	jmp    801012ea <fileread+0xba>
  }
  panic("fileread");
801012dd:	83 ec 0c             	sub    $0xc,%esp
801012e0:	68 fa a9 10 80       	push   $0x8010a9fa
801012e5:	e8 db f2 ff ff       	call   801005c5 <panic>
}
801012ea:	c9                   	leave  
801012eb:	c3                   	ret    

801012ec <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012ec:	f3 0f 1e fb          	endbr32 
801012f0:	55                   	push   %ebp
801012f1:	89 e5                	mov    %esp,%ebp
801012f3:	53                   	push   %ebx
801012f4:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012fe:	84 c0                	test   %al,%al
80101300:	75 0a                	jne    8010130c <filewrite+0x20>
    return -1;
80101302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101307:	e9 1b 01 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010130c:	8b 45 08             	mov    0x8(%ebp),%eax
8010130f:	8b 00                	mov    (%eax),%eax
80101311:	83 f8 01             	cmp    $0x1,%eax
80101314:	75 1d                	jne    80101333 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	8b 40 0c             	mov    0xc(%eax),%eax
8010131c:	83 ec 04             	sub    $0x4,%esp
8010131f:	ff 75 10             	pushl  0x10(%ebp)
80101322:	ff 75 0c             	pushl  0xc(%ebp)
80101325:	50                   	push   %eax
80101326:	e8 a4 25 00 00       	call   801038cf <pipewrite>
8010132b:	83 c4 10             	add    $0x10,%esp
8010132e:	e9 f4 00 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	8b 00                	mov    (%eax),%eax
80101338:	83 f8 02             	cmp    $0x2,%eax
8010133b:	0f 85 d9 00 00 00    	jne    8010141a <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101341:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010134f:	e9 a3 00 00 00       	jmp    801013f7 <filewrite+0x10b>
      int n1 = n - i;
80101354:	8b 45 10             	mov    0x10(%ebp),%eax
80101357:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010135a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101360:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101363:	7e 06                	jle    8010136b <filewrite+0x7f>
        n1 = max;
80101365:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101368:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010136b:	e8 01 1e 00 00       	call   80103171 <begin_op>
      ilock(f->ip);
80101370:	8b 45 08             	mov    0x8(%ebp),%eax
80101373:	8b 40 10             	mov    0x10(%eax),%eax
80101376:	83 ec 0c             	sub    $0xc,%esp
80101379:	50                   	push   %eax
8010137a:	e8 fd 06 00 00       	call   80101a7c <ilock>
8010137f:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101382:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8b 50 14             	mov    0x14(%eax),%edx
8010138b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010138e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101391:	01 c3                	add    %eax,%ebx
80101393:	8b 45 08             	mov    0x8(%ebp),%eax
80101396:	8b 40 10             	mov    0x10(%eax),%eax
80101399:	51                   	push   %ecx
8010139a:	52                   	push   %edx
8010139b:	53                   	push   %ebx
8010139c:	50                   	push   %eax
8010139d:	e8 3b 0d 00 00       	call   801020dd <writei>
801013a2:	83 c4 10             	add    $0x10,%esp
801013a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013ac:	7e 11                	jle    801013bf <filewrite+0xd3>
        f->off += r;
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	8b 50 14             	mov    0x14(%eax),%edx
801013b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013b7:	01 c2                	add    %eax,%edx
801013b9:	8b 45 08             	mov    0x8(%ebp),%eax
801013bc:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	8b 40 10             	mov    0x10(%eax),%eax
801013c5:	83 ec 0c             	sub    $0xc,%esp
801013c8:	50                   	push   %eax
801013c9:	e8 c5 07 00 00       	call   80101b93 <iunlock>
801013ce:	83 c4 10             	add    $0x10,%esp
      end_op();
801013d1:	e8 2b 1e 00 00       	call   80103201 <end_op>

      if(r < 0)
801013d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013da:	78 29                	js     80101405 <filewrite+0x119>
        break;
      if(r != n1)
801013dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013df:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013e2:	74 0d                	je     801013f1 <filewrite+0x105>
        panic("short filewrite");
801013e4:	83 ec 0c             	sub    $0xc,%esp
801013e7:	68 03 aa 10 80       	push   $0x8010aa03
801013ec:	e8 d4 f1 ff ff       	call   801005c5 <panic>
      i += r;
801013f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f4:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013fa:	3b 45 10             	cmp    0x10(%ebp),%eax
801013fd:	0f 8c 51 ff ff ff    	jl     80101354 <filewrite+0x68>
80101403:	eb 01                	jmp    80101406 <filewrite+0x11a>
        break;
80101405:	90                   	nop
    }
    return i == n ? n : -1;
80101406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101409:	3b 45 10             	cmp    0x10(%ebp),%eax
8010140c:	75 05                	jne    80101413 <filewrite+0x127>
8010140e:	8b 45 10             	mov    0x10(%ebp),%eax
80101411:	eb 14                	jmp    80101427 <filewrite+0x13b>
80101413:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101418:	eb 0d                	jmp    80101427 <filewrite+0x13b>
  }
  panic("filewrite");
8010141a:	83 ec 0c             	sub    $0xc,%esp
8010141d:	68 13 aa 10 80       	push   $0x8010aa13
80101422:	e8 9e f1 ff ff       	call   801005c5 <panic>
}
80101427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010142a:	c9                   	leave  
8010142b:	c3                   	ret    

8010142c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010142c:	f3 0f 1e fb          	endbr32 
80101430:	55                   	push   %ebp
80101431:	89 e5                	mov    %esp,%ebp
80101433:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101436:	8b 45 08             	mov    0x8(%ebp),%eax
80101439:	83 ec 08             	sub    $0x8,%esp
8010143c:	6a 01                	push   $0x1
8010143e:	50                   	push   %eax
8010143f:	e8 c5 ed ff ff       	call   80100209 <bread>
80101444:	83 c4 10             	add    $0x10,%esp
80101447:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144d:	83 c0 5c             	add    $0x5c,%eax
80101450:	83 ec 04             	sub    $0x4,%esp
80101453:	6a 1c                	push   $0x1c
80101455:	50                   	push   %eax
80101456:	ff 75 0c             	pushl  0xc(%ebp)
80101459:	e8 9a 3c 00 00       	call   801050f8 <memmove>
8010145e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101461:	83 ec 0c             	sub    $0xc,%esp
80101464:	ff 75 f4             	pushl  -0xc(%ebp)
80101467:	e8 27 ee ff ff       	call   80100293 <brelse>
8010146c:	83 c4 10             	add    $0x10,%esp
}
8010146f:	90                   	nop
80101470:	c9                   	leave  
80101471:	c3                   	ret    

80101472 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101472:	f3 0f 1e fb          	endbr32 
80101476:	55                   	push   %ebp
80101477:	89 e5                	mov    %esp,%ebp
80101479:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010147c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010147f:	8b 45 08             	mov    0x8(%ebp),%eax
80101482:	83 ec 08             	sub    $0x8,%esp
80101485:	52                   	push   %edx
80101486:	50                   	push   %eax
80101487:	e8 7d ed ff ff       	call   80100209 <bread>
8010148c:	83 c4 10             	add    $0x10,%esp
8010148f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101495:	83 c0 5c             	add    $0x5c,%eax
80101498:	83 ec 04             	sub    $0x4,%esp
8010149b:	68 00 02 00 00       	push   $0x200
801014a0:	6a 00                	push   $0x0
801014a2:	50                   	push   %eax
801014a3:	e8 89 3b 00 00       	call   80105031 <memset>
801014a8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ab:	83 ec 0c             	sub    $0xc,%esp
801014ae:	ff 75 f4             	pushl  -0xc(%ebp)
801014b1:	e8 04 1f 00 00       	call   801033ba <log_write>
801014b6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014b9:	83 ec 0c             	sub    $0xc,%esp
801014bc:	ff 75 f4             	pushl  -0xc(%ebp)
801014bf:	e8 cf ed ff ff       	call   80100293 <brelse>
801014c4:	83 c4 10             	add    $0x10,%esp
}
801014c7:	90                   	nop
801014c8:	c9                   	leave  
801014c9:	c3                   	ret    

801014ca <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014ca:	f3 0f 1e fb          	endbr32 
801014ce:	55                   	push   %ebp
801014cf:	89 e5                	mov    %esp,%ebp
801014d1:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014e2:	e9 13 01 00 00       	jmp    801015fa <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ea:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014f0:	85 c0                	test   %eax,%eax
801014f2:	0f 48 c2             	cmovs  %edx,%eax
801014f5:	c1 f8 0c             	sar    $0xc,%eax
801014f8:	89 c2                	mov    %eax,%edx
801014fa:	a1 78 37 19 80       	mov    0x80193778,%eax
801014ff:	01 d0                	add    %edx,%eax
80101501:	83 ec 08             	sub    $0x8,%esp
80101504:	50                   	push   %eax
80101505:	ff 75 08             	pushl  0x8(%ebp)
80101508:	e8 fc ec ff ff       	call   80100209 <bread>
8010150d:	83 c4 10             	add    $0x10,%esp
80101510:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101513:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010151a:	e9 a6 00 00 00       	jmp    801015c5 <balloc+0xfb>
      m = 1 << (bi % 8);
8010151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101522:	99                   	cltd   
80101523:	c1 ea 1d             	shr    $0x1d,%edx
80101526:	01 d0                	add    %edx,%eax
80101528:	83 e0 07             	and    $0x7,%eax
8010152b:	29 d0                	sub    %edx,%eax
8010152d:	ba 01 00 00 00       	mov    $0x1,%edx
80101532:	89 c1                	mov    %eax,%ecx
80101534:	d3 e2                	shl    %cl,%edx
80101536:	89 d0                	mov    %edx,%eax
80101538:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153e:	8d 50 07             	lea    0x7(%eax),%edx
80101541:	85 c0                	test   %eax,%eax
80101543:	0f 48 c2             	cmovs  %edx,%eax
80101546:	c1 f8 03             	sar    $0x3,%eax
80101549:	89 c2                	mov    %eax,%edx
8010154b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010154e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101553:	0f b6 c0             	movzbl %al,%eax
80101556:	23 45 e8             	and    -0x18(%ebp),%eax
80101559:	85 c0                	test   %eax,%eax
8010155b:	75 64                	jne    801015c1 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101560:	8d 50 07             	lea    0x7(%eax),%edx
80101563:	85 c0                	test   %eax,%eax
80101565:	0f 48 c2             	cmovs  %edx,%eax
80101568:	c1 f8 03             	sar    $0x3,%eax
8010156b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010156e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101573:	89 d1                	mov    %edx,%ecx
80101575:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101578:	09 ca                	or     %ecx,%edx
8010157a:	89 d1                	mov    %edx,%ecx
8010157c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010157f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101583:	83 ec 0c             	sub    $0xc,%esp
80101586:	ff 75 ec             	pushl  -0x14(%ebp)
80101589:	e8 2c 1e 00 00       	call   801033ba <log_write>
8010158e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101591:	83 ec 0c             	sub    $0xc,%esp
80101594:	ff 75 ec             	pushl  -0x14(%ebp)
80101597:	e8 f7 ec ff ff       	call   80100293 <brelse>
8010159c:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010159f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a5:	01 c2                	add    %eax,%edx
801015a7:	8b 45 08             	mov    0x8(%ebp),%eax
801015aa:	83 ec 08             	sub    $0x8,%esp
801015ad:	52                   	push   %edx
801015ae:	50                   	push   %eax
801015af:	e8 be fe ff ff       	call   80101472 <bzero>
801015b4:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015bd:	01 d0                	add    %edx,%eax
801015bf:	eb 57                	jmp    80101618 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015c5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015cc:	7f 17                	jg     801015e5 <balloc+0x11b>
801015ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d4:	01 d0                	add    %edx,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	a1 60 37 19 80       	mov    0x80193760,%eax
801015dd:	39 c2                	cmp    %eax,%edx
801015df:	0f 82 3a ff ff ff    	jb     8010151f <balloc+0x55>
      }
    }
    brelse(bp);
801015e5:	83 ec 0c             	sub    $0xc,%esp
801015e8:	ff 75 ec             	pushl  -0x14(%ebp)
801015eb:	e8 a3 ec ff ff       	call   80100293 <brelse>
801015f0:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015fa:	8b 15 60 37 19 80    	mov    0x80193760,%edx
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	39 c2                	cmp    %eax,%edx
80101605:	0f 87 dc fe ff ff    	ja     801014e7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010160b:	83 ec 0c             	sub    $0xc,%esp
8010160e:	68 20 aa 10 80       	push   $0x8010aa20
80101613:	e8 ad ef ff ff       	call   801005c5 <panic>
}
80101618:	c9                   	leave  
80101619:	c3                   	ret    

8010161a <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010161a:	f3 0f 1e fb          	endbr32 
8010161e:	55                   	push   %ebp
8010161f:	89 e5                	mov    %esp,%ebp
80101621:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101624:	83 ec 08             	sub    $0x8,%esp
80101627:	68 60 37 19 80       	push   $0x80193760
8010162c:	ff 75 08             	pushl  0x8(%ebp)
8010162f:	e8 f8 fd ff ff       	call   8010142c <readsb>
80101634:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163a:	c1 e8 0c             	shr    $0xc,%eax
8010163d:	89 c2                	mov    %eax,%edx
8010163f:	a1 78 37 19 80       	mov    0x80193778,%eax
80101644:	01 c2                	add    %eax,%edx
80101646:	8b 45 08             	mov    0x8(%ebp),%eax
80101649:	83 ec 08             	sub    $0x8,%esp
8010164c:	52                   	push   %edx
8010164d:	50                   	push   %eax
8010164e:	e8 b6 eb ff ff       	call   80100209 <bread>
80101653:	83 c4 10             	add    $0x10,%esp
80101656:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101659:	8b 45 0c             	mov    0xc(%ebp),%eax
8010165c:	25 ff 0f 00 00       	and    $0xfff,%eax
80101661:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101667:	99                   	cltd   
80101668:	c1 ea 1d             	shr    $0x1d,%edx
8010166b:	01 d0                	add    %edx,%eax
8010166d:	83 e0 07             	and    $0x7,%eax
80101670:	29 d0                	sub    %edx,%eax
80101672:	ba 01 00 00 00       	mov    $0x1,%edx
80101677:	89 c1                	mov    %eax,%ecx
80101679:	d3 e2                	shl    %cl,%edx
8010167b:	89 d0                	mov    %edx,%eax
8010167d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101683:	8d 50 07             	lea    0x7(%eax),%edx
80101686:	85 c0                	test   %eax,%eax
80101688:	0f 48 c2             	cmovs  %edx,%eax
8010168b:	c1 f8 03             	sar    $0x3,%eax
8010168e:	89 c2                	mov    %eax,%edx
80101690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101693:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101698:	0f b6 c0             	movzbl %al,%eax
8010169b:	23 45 ec             	and    -0x14(%ebp),%eax
8010169e:	85 c0                	test   %eax,%eax
801016a0:	75 0d                	jne    801016af <bfree+0x95>
    panic("freeing free block");
801016a2:	83 ec 0c             	sub    $0xc,%esp
801016a5:	68 36 aa 10 80       	push   $0x8010aa36
801016aa:	e8 16 ef ff ff       	call   801005c5 <panic>
  bp->data[bi/8] &= ~m;
801016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b2:	8d 50 07             	lea    0x7(%eax),%edx
801016b5:	85 c0                	test   %eax,%eax
801016b7:	0f 48 c2             	cmovs  %edx,%eax
801016ba:	c1 f8 03             	sar    $0x3,%eax
801016bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c0:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016c5:	89 d1                	mov    %edx,%ecx
801016c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016ca:	f7 d2                	not    %edx
801016cc:	21 ca                	and    %ecx,%edx
801016ce:	89 d1                	mov    %edx,%ecx
801016d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016d3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016d7:	83 ec 0c             	sub    $0xc,%esp
801016da:	ff 75 f4             	pushl  -0xc(%ebp)
801016dd:	e8 d8 1c 00 00       	call   801033ba <log_write>
801016e2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016e5:	83 ec 0c             	sub    $0xc,%esp
801016e8:	ff 75 f4             	pushl  -0xc(%ebp)
801016eb:	e8 a3 eb ff ff       	call   80100293 <brelse>
801016f0:	83 c4 10             	add    $0x10,%esp
}
801016f3:	90                   	nop
801016f4:	c9                   	leave  
801016f5:	c3                   	ret    

801016f6 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016f6:	f3 0f 1e fb          	endbr32 
801016fa:	55                   	push   %ebp
801016fb:	89 e5                	mov    %esp,%ebp
801016fd:	57                   	push   %edi
801016fe:	56                   	push   %esi
801016ff:	53                   	push   %ebx
80101700:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010170a:	83 ec 08             	sub    $0x8,%esp
8010170d:	68 49 aa 10 80       	push   $0x8010aa49
80101712:	68 80 37 19 80       	push   $0x80193780
80101717:	e8 60 36 00 00       	call   80104d7c <initlock>
8010171c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010171f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101726:	eb 2d                	jmp    80101755 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101728:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010172b:	89 d0                	mov    %edx,%eax
8010172d:	c1 e0 03             	shl    $0x3,%eax
80101730:	01 d0                	add    %edx,%eax
80101732:	c1 e0 04             	shl    $0x4,%eax
80101735:	83 c0 30             	add    $0x30,%eax
80101738:	05 80 37 19 80       	add    $0x80193780,%eax
8010173d:	83 c0 10             	add    $0x10,%eax
80101740:	83 ec 08             	sub    $0x8,%esp
80101743:	68 50 aa 10 80       	push   $0x8010aa50
80101748:	50                   	push   %eax
80101749:	e8 c1 34 00 00       	call   80104c0f <initsleeplock>
8010174e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101751:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101755:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101759:	7e cd                	jle    80101728 <iinit+0x32>
  }

  readsb(dev, &sb);
8010175b:	83 ec 08             	sub    $0x8,%esp
8010175e:	68 60 37 19 80       	push   $0x80193760
80101763:	ff 75 08             	pushl  0x8(%ebp)
80101766:	e8 c1 fc ff ff       	call   8010142c <readsb>
8010176b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010176e:	a1 78 37 19 80       	mov    0x80193778,%eax
80101773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101776:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
8010177c:	8b 35 70 37 19 80    	mov    0x80193770,%esi
80101782:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
80101788:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
8010178e:	8b 15 64 37 19 80    	mov    0x80193764,%edx
80101794:	a1 60 37 19 80       	mov    0x80193760,%eax
80101799:	ff 75 d4             	pushl  -0x2c(%ebp)
8010179c:	57                   	push   %edi
8010179d:	56                   	push   %esi
8010179e:	53                   	push   %ebx
8010179f:	51                   	push   %ecx
801017a0:	52                   	push   %edx
801017a1:	50                   	push   %eax
801017a2:	68 58 aa 10 80       	push   $0x8010aa58
801017a7:	e8 60 ec ff ff       	call   8010040c <cprintf>
801017ac:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017af:	90                   	nop
801017b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017b3:	5b                   	pop    %ebx
801017b4:	5e                   	pop    %esi
801017b5:	5f                   	pop    %edi
801017b6:	5d                   	pop    %ebp
801017b7:	c3                   	ret    

801017b8 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017b8:	f3 0f 1e fb          	endbr32 
801017bc:	55                   	push   %ebp
801017bd:	89 e5                	mov    %esp,%ebp
801017bf:	83 ec 28             	sub    $0x28,%esp
801017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801017c5:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017c9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017d0:	e9 9e 00 00 00       	jmp    80101873 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	c1 e8 03             	shr    $0x3,%eax
801017db:	89 c2                	mov    %eax,%edx
801017dd:	a1 74 37 19 80       	mov    0x80193774,%eax
801017e2:	01 d0                	add    %edx,%eax
801017e4:	83 ec 08             	sub    $0x8,%esp
801017e7:	50                   	push   %eax
801017e8:	ff 75 08             	pushl  0x8(%ebp)
801017eb:	e8 19 ea ff ff       	call   80100209 <bread>
801017f0:	83 c4 10             	add    $0x10,%esp
801017f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	8d 50 5c             	lea    0x5c(%eax),%edx
801017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ff:	83 e0 07             	and    $0x7,%eax
80101802:	c1 e0 06             	shl    $0x6,%eax
80101805:	01 d0                	add    %edx,%eax
80101807:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010180a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010180d:	0f b7 00             	movzwl (%eax),%eax
80101810:	66 85 c0             	test   %ax,%ax
80101813:	75 4c                	jne    80101861 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101815:	83 ec 04             	sub    $0x4,%esp
80101818:	6a 40                	push   $0x40
8010181a:	6a 00                	push   $0x0
8010181c:	ff 75 ec             	pushl  -0x14(%ebp)
8010181f:	e8 0d 38 00 00       	call   80105031 <memset>
80101824:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101827:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010182a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010182e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101831:	83 ec 0c             	sub    $0xc,%esp
80101834:	ff 75 f0             	pushl  -0x10(%ebp)
80101837:	e8 7e 1b 00 00       	call   801033ba <log_write>
8010183c:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010183f:	83 ec 0c             	sub    $0xc,%esp
80101842:	ff 75 f0             	pushl  -0x10(%ebp)
80101845:	e8 49 ea ff ff       	call   80100293 <brelse>
8010184a:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	83 ec 08             	sub    $0x8,%esp
80101853:	50                   	push   %eax
80101854:	ff 75 08             	pushl  0x8(%ebp)
80101857:	e8 fc 00 00 00       	call   80101958 <iget>
8010185c:	83 c4 10             	add    $0x10,%esp
8010185f:	eb 30                	jmp    80101891 <ialloc+0xd9>
    }
    brelse(bp);
80101861:	83 ec 0c             	sub    $0xc,%esp
80101864:	ff 75 f0             	pushl  -0x10(%ebp)
80101867:	e8 27 ea ff ff       	call   80100293 <brelse>
8010186c:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010186f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101873:	8b 15 68 37 19 80    	mov    0x80193768,%edx
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	39 c2                	cmp    %eax,%edx
8010187e:	0f 87 51 ff ff ff    	ja     801017d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 ab aa 10 80       	push   $0x8010aaab
8010188c:	e8 34 ed ff ff       	call   801005c5 <panic>
}
80101891:	c9                   	leave  
80101892:	c3                   	ret    

80101893 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101893:	f3 0f 1e fb          	endbr32 
80101897:	55                   	push   %ebp
80101898:	89 e5                	mov    %esp,%ebp
8010189a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010189d:	8b 45 08             	mov    0x8(%ebp),%eax
801018a0:	8b 40 04             	mov    0x4(%eax),%eax
801018a3:	c1 e8 03             	shr    $0x3,%eax
801018a6:	89 c2                	mov    %eax,%edx
801018a8:	a1 74 37 19 80       	mov    0x80193774,%eax
801018ad:	01 c2                	add    %eax,%edx
801018af:	8b 45 08             	mov    0x8(%ebp),%eax
801018b2:	8b 00                	mov    (%eax),%eax
801018b4:	83 ec 08             	sub    $0x8,%esp
801018b7:	52                   	push   %edx
801018b8:	50                   	push   %eax
801018b9:	e8 4b e9 ff ff       	call   80100209 <bread>
801018be:	83 c4 10             	add    $0x10,%esp
801018c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ca:	8b 45 08             	mov    0x8(%ebp),%eax
801018cd:	8b 40 04             	mov    0x4(%eax),%eax
801018d0:	83 e0 07             	and    $0x7,%eax
801018d3:	c1 e0 06             	shl    $0x6,%eax
801018d6:	01 d0                	add    %edx,%eax
801018d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018db:	8b 45 08             	mov    0x8(%ebp),%eax
801018de:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f2:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018f6:	8b 45 08             	mov    0x8(%ebp),%eax
801018f9:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101900:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101912:	8b 45 08             	mov    0x8(%ebp),%eax
80101915:	8b 50 58             	mov    0x58(%eax),%edx
80101918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	8d 50 5c             	lea    0x5c(%eax),%edx
80101924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101927:	83 c0 0c             	add    $0xc,%eax
8010192a:	83 ec 04             	sub    $0x4,%esp
8010192d:	6a 34                	push   $0x34
8010192f:	52                   	push   %edx
80101930:	50                   	push   %eax
80101931:	e8 c2 37 00 00       	call   801050f8 <memmove>
80101936:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	ff 75 f4             	pushl  -0xc(%ebp)
8010193f:	e8 76 1a 00 00       	call   801033ba <log_write>
80101944:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101947:	83 ec 0c             	sub    $0xc,%esp
8010194a:	ff 75 f4             	pushl  -0xc(%ebp)
8010194d:	e8 41 e9 ff ff       	call   80100293 <brelse>
80101952:	83 c4 10             	add    $0x10,%esp
}
80101955:	90                   	nop
80101956:	c9                   	leave  
80101957:	c3                   	ret    

80101958 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101958:	f3 0f 1e fb          	endbr32 
8010195c:	55                   	push   %ebp
8010195d:	89 e5                	mov    %esp,%ebp
8010195f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101962:	83 ec 0c             	sub    $0xc,%esp
80101965:	68 80 37 19 80       	push   $0x80193780
8010196a:	e8 33 34 00 00       	call   80104da2 <acquire>
8010196f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101972:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101979:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
80101980:	eb 60                	jmp    801019e2 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101985:	8b 40 08             	mov    0x8(%eax),%eax
80101988:	85 c0                	test   %eax,%eax
8010198a:	7e 39                	jle    801019c5 <iget+0x6d>
8010198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198f:	8b 00                	mov    (%eax),%eax
80101991:	39 45 08             	cmp    %eax,0x8(%ebp)
80101994:	75 2f                	jne    801019c5 <iget+0x6d>
80101996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101999:	8b 40 04             	mov    0x4(%eax),%eax
8010199c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010199f:	75 24                	jne    801019c5 <iget+0x6d>
      ip->ref++;
801019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a4:	8b 40 08             	mov    0x8(%eax),%eax
801019a7:	8d 50 01             	lea    0x1(%eax),%edx
801019aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ad:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019b0:	83 ec 0c             	sub    $0xc,%esp
801019b3:	68 80 37 19 80       	push   $0x80193780
801019b8:	e8 57 34 00 00       	call   80104e14 <release>
801019bd:	83 c4 10             	add    $0x10,%esp
      return ip;
801019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c3:	eb 77                	jmp    80101a3c <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019c9:	75 10                	jne    801019db <iget+0x83>
801019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ce:	8b 40 08             	mov    0x8(%eax),%eax
801019d1:	85 c0                	test   %eax,%eax
801019d3:	75 06                	jne    801019db <iget+0x83>
      empty = ip;
801019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019db:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019e2:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
801019e9:	72 97                	jb     80101982 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ef:	75 0d                	jne    801019fe <iget+0xa6>
    panic("iget: no inodes");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 bd aa 10 80       	push   $0x8010aabd
801019f9:	e8 c7 eb ff ff       	call   801005c5 <panic>

  ip = empty;
801019fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a07:	8b 55 08             	mov    0x8(%ebp),%edx
80101a0a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a12:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a22:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a29:	83 ec 0c             	sub    $0xc,%esp
80101a2c:	68 80 37 19 80       	push   $0x80193780
80101a31:	e8 de 33 00 00       	call   80104e14 <release>
80101a36:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a3c:	c9                   	leave  
80101a3d:	c3                   	ret    

80101a3e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a3e:	f3 0f 1e fb          	endbr32 
80101a42:	55                   	push   %ebp
80101a43:	89 e5                	mov    %esp,%ebp
80101a45:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a48:	83 ec 0c             	sub    $0xc,%esp
80101a4b:	68 80 37 19 80       	push   $0x80193780
80101a50:	e8 4d 33 00 00       	call   80104da2 <acquire>
80101a55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	8d 50 01             	lea    0x1(%eax),%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 80 37 19 80       	push   $0x80193780
80101a6f:	e8 a0 33 00 00       	call   80104e14 <release>
80101a74:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a7a:	c9                   	leave  
80101a7b:	c3                   	ret    

80101a7c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a7c:	f3 0f 1e fb          	endbr32 
80101a80:	55                   	push   %ebp
80101a81:	89 e5                	mov    %esp,%ebp
80101a83:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a8a:	74 0a                	je     80101a96 <ilock+0x1a>
80101a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8f:	8b 40 08             	mov    0x8(%eax),%eax
80101a92:	85 c0                	test   %eax,%eax
80101a94:	7f 0d                	jg     80101aa3 <ilock+0x27>
    panic("ilock");
80101a96:	83 ec 0c             	sub    $0xc,%esp
80101a99:	68 cd aa 10 80       	push   $0x8010aacd
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 9d 31 00 00       	call   80104c4f <acquiresleep>
80101ab2:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101abb:	85 c0                	test   %eax,%eax
80101abd:	0f 85 cd 00 00 00    	jne    80101b90 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	8b 40 04             	mov    0x4(%eax),%eax
80101ac9:	c1 e8 03             	shr    $0x3,%eax
80101acc:	89 c2                	mov    %eax,%edx
80101ace:	a1 74 37 19 80       	mov    0x80193774,%eax
80101ad3:	01 c2                	add    %eax,%edx
80101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad8:	8b 00                	mov    (%eax),%eax
80101ada:	83 ec 08             	sub    $0x8,%esp
80101add:	52                   	push   %edx
80101ade:	50                   	push   %eax
80101adf:	e8 25 e7 ff ff       	call   80100209 <bread>
80101ae4:	83 c4 10             	add    $0x10,%esp
80101ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aed:	8d 50 5c             	lea    0x5c(%eax),%edx
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	8b 40 04             	mov    0x4(%eax),%eax
80101af6:	83 e0 07             	and    $0x7,%eax
80101af9:	c1 e0 06             	shl    $0x6,%eax
80101afc:	01 d0                	add    %edx,%eax
80101afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b04:	0f b7 10             	movzwl (%eax),%edx
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b11:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b31:	8b 45 08             	mov    0x8(%ebp),%eax
80101b34:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3b:	8b 50 08             	mov    0x8(%eax),%edx
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b47:	8d 50 0c             	lea    0xc(%eax),%edx
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	83 c0 5c             	add    $0x5c,%eax
80101b50:	83 ec 04             	sub    $0x4,%esp
80101b53:	6a 34                	push   $0x34
80101b55:	52                   	push   %edx
80101b56:	50                   	push   %eax
80101b57:	e8 9c 35 00 00       	call   801050f8 <memmove>
80101b5c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	ff 75 f4             	pushl  -0xc(%ebp)
80101b65:	e8 29 e7 ff ff       	call   80100293 <brelse>
80101b6a:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b7e:	66 85 c0             	test   %ax,%ax
80101b81:	75 0d                	jne    80101b90 <ilock+0x114>
      panic("ilock: no type");
80101b83:	83 ec 0c             	sub    $0xc,%esp
80101b86:	68 d3 aa 10 80       	push   $0x8010aad3
80101b8b:	e8 35 ea ff ff       	call   801005c5 <panic>
  }
}
80101b90:	90                   	nop
80101b91:	c9                   	leave  
80101b92:	c3                   	ret    

80101b93 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b93:	f3 0f 1e fb          	endbr32 
80101b97:	55                   	push   %ebp
80101b98:	89 e5                	mov    %esp,%ebp
80101b9a:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ba1:	74 20                	je     80101bc3 <iunlock+0x30>
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	83 c0 0c             	add    $0xc,%eax
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	50                   	push   %eax
80101bad:	e8 57 31 00 00       	call   80104d09 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 e2 aa 10 80       	push   $0x8010aae2
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 d8 30 00 00       	call   80104cb7 <releasesleep>
80101bdf:	83 c4 10             	add    $0x10,%esp
}
80101be2:	90                   	nop
80101be3:	c9                   	leave  
80101be4:	c3                   	ret    

80101be5 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101be5:	f3 0f 1e fb          	endbr32 
80101be9:	55                   	push   %ebp
80101bea:	89 e5                	mov    %esp,%ebp
80101bec:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	83 c0 0c             	add    $0xc,%eax
80101bf5:	83 ec 0c             	sub    $0xc,%esp
80101bf8:	50                   	push   %eax
80101bf9:	e8 51 30 00 00       	call   80104c4f <acquiresleep>
80101bfe:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c07:	85 c0                	test   %eax,%eax
80101c09:	74 6a                	je     80101c75 <iput+0x90>
80101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c12:	66 85 c0             	test   %ax,%ax
80101c15:	75 5e                	jne    80101c75 <iput+0x90>
    acquire(&icache.lock);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 80 37 19 80       	push   $0x80193780
80101c1f:	e8 7e 31 00 00       	call   80104da2 <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 80 37 19 80       	push   $0x80193780
80101c38:	e8 d7 31 00 00       	call   80104e14 <release>
80101c3d:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c40:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c44:	75 2f                	jne    80101c75 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c46:	83 ec 0c             	sub    $0xc,%esp
80101c49:	ff 75 08             	pushl  0x8(%ebp)
80101c4c:	e8 b5 01 00 00       	call   80101e06 <itrunc>
80101c51:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	pushl  0x8(%ebp)
80101c63:	e8 2b fc ff ff       	call   80101893 <iupdate>
80101c68:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	83 c0 0c             	add    $0xc,%eax
80101c7b:	83 ec 0c             	sub    $0xc,%esp
80101c7e:	50                   	push   %eax
80101c7f:	e8 33 30 00 00       	call   80104cb7 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 80 37 19 80       	push   $0x80193780
80101c8f:	e8 0e 31 00 00       	call   80104da2 <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	68 80 37 19 80       	push   $0x80193780
80101cae:	e8 61 31 00 00       	call   80104e14 <release>
80101cb3:	83 c4 10             	add    $0x10,%esp
}
80101cb6:	90                   	nop
80101cb7:	c9                   	leave  
80101cb8:	c3                   	ret    

80101cb9 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cb9:	f3 0f 1e fb          	endbr32 
80101cbd:	55                   	push   %ebp
80101cbe:	89 e5                	mov    %esp,%ebp
80101cc0:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cc3:	83 ec 0c             	sub    $0xc,%esp
80101cc6:	ff 75 08             	pushl  0x8(%ebp)
80101cc9:	e8 c5 fe ff ff       	call   80101b93 <iunlock>
80101cce:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cd1:	83 ec 0c             	sub    $0xc,%esp
80101cd4:	ff 75 08             	pushl  0x8(%ebp)
80101cd7:	e8 09 ff ff ff       	call   80101be5 <iput>
80101cdc:	83 c4 10             	add    $0x10,%esp
}
80101cdf:	90                   	nop
80101ce0:	c9                   	leave  
80101ce1:	c3                   	ret    

80101ce2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ce2:	f3 0f 1e fb          	endbr32 
80101ce6:	55                   	push   %ebp
80101ce7:	89 e5                	mov    %esp,%ebp
80101ce9:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cec:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cf0:	77 42                	ja     80101d34 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cf8:	83 c2 14             	add    $0x14,%edx
80101cfb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 24                	jne    80101d2c <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 b4 f7 ff ff       	call   801014ca <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d22:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d28:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2f:	e9 d0 00 00 00       	jmp    80101e04 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d34:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d38:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d3c:	0f 87 b5 00 00 00    	ja     80101df7 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d52:	75 20                	jne    80101d74 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	8b 00                	mov    (%eax),%eax
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	50                   	push   %eax
80101d5d:	e8 68 f7 ff ff       	call   801014ca <balloc>
80101d62:	83 c4 10             	add    $0x10,%esp
80101d65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	8b 00                	mov    (%eax),%eax
80101d79:	83 ec 08             	sub    $0x8,%esp
80101d7c:	ff 75 f4             	pushl  -0xc(%ebp)
80101d7f:	50                   	push   %eax
80101d80:	e8 84 e4 ff ff       	call   80100209 <bread>
80101d85:	83 c4 10             	add    $0x10,%esp
80101d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8e:	83 c0 5c             	add    $0x5c,%eax
80101d91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101da1:	01 d0                	add    %edx,%eax
80101da3:	8b 00                	mov    (%eax),%eax
80101da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dac:	75 36                	jne    80101de4 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101dae:	8b 45 08             	mov    0x8(%ebp),%eax
80101db1:	8b 00                	mov    (%eax),%eax
80101db3:	83 ec 0c             	sub    $0xc,%esp
80101db6:	50                   	push   %eax
80101db7:	e8 0e f7 ff ff       	call   801014ca <balloc>
80101dbc:	83 c4 10             	add    $0x10,%esp
80101dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dcf:	01 c2                	add    %eax,%edx
80101dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd4:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	ff 75 f0             	pushl  -0x10(%ebp)
80101ddc:	e8 d9 15 00 00       	call   801033ba <log_write>
80101de1:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101de4:	83 ec 0c             	sub    $0xc,%esp
80101de7:	ff 75 f0             	pushl  -0x10(%ebp)
80101dea:	e8 a4 e4 ff ff       	call   80100293 <brelse>
80101def:	83 c4 10             	add    $0x10,%esp
    return addr;
80101df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df5:	eb 0d                	jmp    80101e04 <bmap+0x122>
  }

  panic("bmap: out of range");
80101df7:	83 ec 0c             	sub    $0xc,%esp
80101dfa:	68 ea aa 10 80       	push   $0x8010aaea
80101dff:	e8 c1 e7 ff ff       	call   801005c5 <panic>
}
80101e04:	c9                   	leave  
80101e05:	c3                   	ret    

80101e06 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e06:	f3 0f 1e fb          	endbr32 
80101e0a:	55                   	push   %ebp
80101e0b:	89 e5                	mov    %esp,%ebp
80101e0d:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e17:	eb 45                	jmp    80101e5e <itrunc+0x58>
    if(ip->addrs[i]){
80101e19:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e1f:	83 c2 14             	add    $0x14,%edx
80101e22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e26:	85 c0                	test   %eax,%eax
80101e28:	74 30                	je     80101e5a <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e30:	83 c2 14             	add    $0x14,%edx
80101e33:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e37:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3a:	8b 12                	mov    (%edx),%edx
80101e3c:	83 ec 08             	sub    $0x8,%esp
80101e3f:	50                   	push   %eax
80101e40:	52                   	push   %edx
80101e41:	e8 d4 f7 ff ff       	call   8010161a <bfree>
80101e46:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e49:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e4f:	83 c2 14             	add    $0x14,%edx
80101e52:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e59:	00 
  for(i = 0; i < NDIRECT; i++){
80101e5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e5e:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e62:	7e b5                	jle    80101e19 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e6d:	85 c0                	test   %eax,%eax
80101e6f:	0f 84 aa 00 00 00    	je     80101f1f <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	8b 00                	mov    (%eax),%eax
80101e83:	83 ec 08             	sub    $0x8,%esp
80101e86:	52                   	push   %edx
80101e87:	50                   	push   %eax
80101e88:	e8 7c e3 ff ff       	call   80100209 <bread>
80101e8d:	83 c4 10             	add    $0x10,%esp
80101e90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e96:	83 c0 5c             	add    $0x5c,%eax
80101e99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ea3:	eb 3c                	jmp    80101ee1 <itrunc+0xdb>
      if(a[j])
80101ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eb2:	01 d0                	add    %edx,%eax
80101eb4:	8b 00                	mov    (%eax),%eax
80101eb6:	85 c0                	test   %eax,%eax
80101eb8:	74 23                	je     80101edd <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec7:	01 d0                	add    %edx,%eax
80101ec9:	8b 00                	mov    (%eax),%eax
80101ecb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ece:	8b 12                	mov    (%edx),%edx
80101ed0:	83 ec 08             	sub    $0x8,%esp
80101ed3:	50                   	push   %eax
80101ed4:	52                   	push   %edx
80101ed5:	e8 40 f7 ff ff       	call   8010161a <bfree>
80101eda:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101edd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee4:	83 f8 7f             	cmp    $0x7f,%eax
80101ee7:	76 bc                	jbe    80101ea5 <itrunc+0x9f>
    }
    brelse(bp);
80101ee9:	83 ec 0c             	sub    $0xc,%esp
80101eec:	ff 75 ec             	pushl  -0x14(%ebp)
80101eef:	e8 9f e3 ff ff       	call   80100293 <brelse>
80101ef4:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f00:	8b 55 08             	mov    0x8(%ebp),%edx
80101f03:	8b 12                	mov    (%edx),%edx
80101f05:	83 ec 08             	sub    $0x8,%esp
80101f08:	50                   	push   %eax
80101f09:	52                   	push   %edx
80101f0a:	e8 0b f7 ff ff       	call   8010161a <bfree>
80101f0f:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f12:	8b 45 08             	mov    0x8(%ebp),%eax
80101f15:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f1c:	00 00 00 
  }

  ip->size = 0;
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f29:	83 ec 0c             	sub    $0xc,%esp
80101f2c:	ff 75 08             	pushl  0x8(%ebp)
80101f2f:	e8 5f f9 ff ff       	call   80101893 <iupdate>
80101f34:	83 c4 10             	add    $0x10,%esp
}
80101f37:	90                   	nop
80101f38:	c9                   	leave  
80101f39:	c3                   	ret    

80101f3a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f3a:	f3 0f 1e fb          	endbr32 
80101f3e:	55                   	push   %ebp
80101f3f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	8b 00                	mov    (%eax),%eax
80101f46:	89 c2                	mov    %eax,%edx
80101f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f4b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	8b 50 04             	mov    0x4(%eax),%edx
80101f54:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f57:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f61:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f64:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f67:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f71:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 50 58             	mov    0x58(%eax),%edx
80101f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f7e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f81:	90                   	nop
80101f82:	5d                   	pop    %ebp
80101f83:	c3                   	ret    

80101f84 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f84:	f3 0f 1e fb          	endbr32 
80101f88:	55                   	push   %ebp
80101f89:	89 e5                	mov    %esp,%ebp
80101f8b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f91:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f95:	66 83 f8 03          	cmp    $0x3,%ax
80101f99:	75 5c                	jne    80101ff7 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fa2:	66 85 c0             	test   %ax,%ax
80101fa5:	78 20                	js     80101fc7 <readi+0x43>
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fae:	66 83 f8 09          	cmp    $0x9,%ax
80101fb2:	7f 13                	jg     80101fc7 <readi+0x43>
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fbb:	98                   	cwtl   
80101fbc:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	75 0a                	jne    80101fd1 <readi+0x4d>
      return -1;
80101fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fcc:	e9 0a 01 00 00       	jmp    801020db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd8:	98                   	cwtl   
80101fd9:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fe0:	8b 55 14             	mov    0x14(%ebp),%edx
80101fe3:	83 ec 04             	sub    $0x4,%esp
80101fe6:	52                   	push   %edx
80101fe7:	ff 75 0c             	pushl  0xc(%ebp)
80101fea:	ff 75 08             	pushl  0x8(%ebp)
80101fed:	ff d0                	call   *%eax
80101fef:	83 c4 10             	add    $0x10,%esp
80101ff2:	e9 e4 00 00 00       	jmp    801020db <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffa:	8b 40 58             	mov    0x58(%eax),%eax
80101ffd:	39 45 10             	cmp    %eax,0x10(%ebp)
80102000:	77 0d                	ja     8010200f <readi+0x8b>
80102002:	8b 55 10             	mov    0x10(%ebp),%edx
80102005:	8b 45 14             	mov    0x14(%ebp),%eax
80102008:	01 d0                	add    %edx,%eax
8010200a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010200d:	76 0a                	jbe    80102019 <readi+0x95>
    return -1;
8010200f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102014:	e9 c2 00 00 00       	jmp    801020db <readi+0x157>
  if(off + n > ip->size)
80102019:	8b 55 10             	mov    0x10(%ebp),%edx
8010201c:	8b 45 14             	mov    0x14(%ebp),%eax
8010201f:	01 c2                	add    %eax,%edx
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	8b 40 58             	mov    0x58(%eax),%eax
80102027:	39 c2                	cmp    %eax,%edx
80102029:	76 0c                	jbe    80102037 <readi+0xb3>
    n = ip->size - off;
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	8b 40 58             	mov    0x58(%eax),%eax
80102031:	2b 45 10             	sub    0x10(%ebp),%eax
80102034:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102037:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010203e:	e9 89 00 00 00       	jmp    801020cc <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102043:	8b 45 10             	mov    0x10(%ebp),%eax
80102046:	c1 e8 09             	shr    $0x9,%eax
80102049:	83 ec 08             	sub    $0x8,%esp
8010204c:	50                   	push   %eax
8010204d:	ff 75 08             	pushl  0x8(%ebp)
80102050:	e8 8d fc ff ff       	call   80101ce2 <bmap>
80102055:	83 c4 10             	add    $0x10,%esp
80102058:	8b 55 08             	mov    0x8(%ebp),%edx
8010205b:	8b 12                	mov    (%edx),%edx
8010205d:	83 ec 08             	sub    $0x8,%esp
80102060:	50                   	push   %eax
80102061:	52                   	push   %edx
80102062:	e8 a2 e1 ff ff       	call   80100209 <bread>
80102067:	83 c4 10             	add    $0x10,%esp
8010206a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010206d:	8b 45 10             	mov    0x10(%ebp),%eax
80102070:	25 ff 01 00 00       	and    $0x1ff,%eax
80102075:	ba 00 02 00 00       	mov    $0x200,%edx
8010207a:	29 c2                	sub    %eax,%edx
8010207c:	8b 45 14             	mov    0x14(%ebp),%eax
8010207f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102082:	39 c2                	cmp    %eax,%edx
80102084:	0f 46 c2             	cmovbe %edx,%eax
80102087:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010208a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102090:	8b 45 10             	mov    0x10(%ebp),%eax
80102093:	25 ff 01 00 00       	and    $0x1ff,%eax
80102098:	01 d0                	add    %edx,%eax
8010209a:	83 ec 04             	sub    $0x4,%esp
8010209d:	ff 75 ec             	pushl  -0x14(%ebp)
801020a0:	50                   	push   %eax
801020a1:	ff 75 0c             	pushl  0xc(%ebp)
801020a4:	e8 4f 30 00 00       	call   801050f8 <memmove>
801020a9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020ac:	83 ec 0c             	sub    $0xc,%esp
801020af:	ff 75 f0             	pushl  -0x10(%ebp)
801020b2:	e8 dc e1 ff ff       	call   80100293 <brelse>
801020b7:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020bd:	01 45 f4             	add    %eax,-0xc(%ebp)
801020c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c3:	01 45 10             	add    %eax,0x10(%ebp)
801020c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c9:	01 45 0c             	add    %eax,0xc(%ebp)
801020cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020cf:	3b 45 14             	cmp    0x14(%ebp),%eax
801020d2:	0f 82 6b ff ff ff    	jb     80102043 <readi+0xbf>
  }
  return n;
801020d8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020db:	c9                   	leave  
801020dc:	c3                   	ret    

801020dd <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020dd:	f3 0f 1e fb          	endbr32 
801020e1:	55                   	push   %ebp
801020e2:	89 e5                	mov    %esp,%ebp
801020e4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020e7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ea:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020ee:	66 83 f8 03          	cmp    $0x3,%ax
801020f2:	75 5c                	jne    80102150 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020f4:	8b 45 08             	mov    0x8(%ebp),%eax
801020f7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020fb:	66 85 c0             	test   %ax,%ax
801020fe:	78 20                	js     80102120 <writei+0x43>
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102107:	66 83 f8 09          	cmp    $0x9,%ax
8010210b:	7f 13                	jg     80102120 <writei+0x43>
8010210d:	8b 45 08             	mov    0x8(%ebp),%eax
80102110:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102114:	98                   	cwtl   
80102115:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x4d>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3b 01 00 00       	jmp    80102265 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102131:	98                   	cwtl   
80102132:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102139:	8b 55 14             	mov    0x14(%ebp),%edx
8010213c:	83 ec 04             	sub    $0x4,%esp
8010213f:	52                   	push   %edx
80102140:	ff 75 0c             	pushl  0xc(%ebp)
80102143:	ff 75 08             	pushl  0x8(%ebp)
80102146:	ff d0                	call   *%eax
80102148:	83 c4 10             	add    $0x10,%esp
8010214b:	e9 15 01 00 00       	jmp    80102265 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 40 58             	mov    0x58(%eax),%eax
80102156:	39 45 10             	cmp    %eax,0x10(%ebp)
80102159:	77 0d                	ja     80102168 <writei+0x8b>
8010215b:	8b 55 10             	mov    0x10(%ebp),%edx
8010215e:	8b 45 14             	mov    0x14(%ebp),%eax
80102161:	01 d0                	add    %edx,%eax
80102163:	39 45 10             	cmp    %eax,0x10(%ebp)
80102166:	76 0a                	jbe    80102172 <writei+0x95>
    return -1;
80102168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216d:	e9 f3 00 00 00       	jmp    80102265 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102172:	8b 55 10             	mov    0x10(%ebp),%edx
80102175:	8b 45 14             	mov    0x14(%ebp),%eax
80102178:	01 d0                	add    %edx,%eax
8010217a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010217f:	76 0a                	jbe    8010218b <writei+0xae>
    return -1;
80102181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102186:	e9 da 00 00 00       	jmp    80102265 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010218b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102192:	e9 97 00 00 00       	jmp    8010222e <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102197:	8b 45 10             	mov    0x10(%ebp),%eax
8010219a:	c1 e8 09             	shr    $0x9,%eax
8010219d:	83 ec 08             	sub    $0x8,%esp
801021a0:	50                   	push   %eax
801021a1:	ff 75 08             	pushl  0x8(%ebp)
801021a4:	e8 39 fb ff ff       	call   80101ce2 <bmap>
801021a9:	83 c4 10             	add    $0x10,%esp
801021ac:	8b 55 08             	mov    0x8(%ebp),%edx
801021af:	8b 12                	mov    (%edx),%edx
801021b1:	83 ec 08             	sub    $0x8,%esp
801021b4:	50                   	push   %eax
801021b5:	52                   	push   %edx
801021b6:	e8 4e e0 ff ff       	call   80100209 <bread>
801021bb:	83 c4 10             	add    $0x10,%esp
801021be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021c1:	8b 45 10             	mov    0x10(%ebp),%eax
801021c4:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c9:	ba 00 02 00 00       	mov    $0x200,%edx
801021ce:	29 c2                	sub    %eax,%edx
801021d0:	8b 45 14             	mov    0x14(%ebp),%eax
801021d3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021d6:	39 c2                	cmp    %eax,%edx
801021d8:	0f 46 c2             	cmovbe %edx,%eax
801021db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e1:	8d 50 5c             	lea    0x5c(%eax),%edx
801021e4:	8b 45 10             	mov    0x10(%ebp),%eax
801021e7:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ec:	01 d0                	add    %edx,%eax
801021ee:	83 ec 04             	sub    $0x4,%esp
801021f1:	ff 75 ec             	pushl  -0x14(%ebp)
801021f4:	ff 75 0c             	pushl  0xc(%ebp)
801021f7:	50                   	push   %eax
801021f8:	e8 fb 2e 00 00       	call   801050f8 <memmove>
801021fd:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 f0             	pushl  -0x10(%ebp)
80102206:	e8 af 11 00 00       	call   801033ba <log_write>
8010220b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	ff 75 f0             	pushl  -0x10(%ebp)
80102214:	e8 7a e0 ff ff       	call   80100293 <brelse>
80102219:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010221c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010221f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102225:	01 45 10             	add    %eax,0x10(%ebp)
80102228:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010222b:	01 45 0c             	add    %eax,0xc(%ebp)
8010222e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102231:	3b 45 14             	cmp    0x14(%ebp),%eax
80102234:	0f 82 5d ff ff ff    	jb     80102197 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010223a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010223e:	74 22                	je     80102262 <writei+0x185>
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	8b 40 58             	mov    0x58(%eax),%eax
80102246:	39 45 10             	cmp    %eax,0x10(%ebp)
80102249:	76 17                	jbe    80102262 <writei+0x185>
    ip->size = off;
8010224b:	8b 45 08             	mov    0x8(%ebp),%eax
8010224e:	8b 55 10             	mov    0x10(%ebp),%edx
80102251:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102254:	83 ec 0c             	sub    $0xc,%esp
80102257:	ff 75 08             	pushl  0x8(%ebp)
8010225a:	e8 34 f6 ff ff       	call   80101893 <iupdate>
8010225f:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102262:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102265:	c9                   	leave  
80102266:	c3                   	ret    

80102267 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102267:	f3 0f 1e fb          	endbr32 
8010226b:	55                   	push   %ebp
8010226c:	89 e5                	mov    %esp,%ebp
8010226e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102271:	83 ec 04             	sub    $0x4,%esp
80102274:	6a 0e                	push   $0xe
80102276:	ff 75 0c             	pushl  0xc(%ebp)
80102279:	ff 75 08             	pushl  0x8(%ebp)
8010227c:	e8 15 2f 00 00       	call   80105196 <strncmp>
80102281:	83 c4 10             	add    $0x10,%esp
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102286:	f3 0f 1e fb          	endbr32 
8010228a:	55                   	push   %ebp
8010228b:	89 e5                	mov    %esp,%ebp
8010228d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102290:	8b 45 08             	mov    0x8(%ebp),%eax
80102293:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102297:	66 83 f8 01          	cmp    $0x1,%ax
8010229b:	74 0d                	je     801022aa <dirlookup+0x24>
    panic("dirlookup not DIR");
8010229d:	83 ec 0c             	sub    $0xc,%esp
801022a0:	68 fd aa 10 80       	push   $0x8010aafd
801022a5:	e8 1b e3 ff ff       	call   801005c5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b1:	eb 7b                	jmp    8010232e <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b3:	6a 10                	push   $0x10
801022b5:	ff 75 f4             	pushl  -0xc(%ebp)
801022b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bb:	50                   	push   %eax
801022bc:	ff 75 08             	pushl  0x8(%ebp)
801022bf:	e8 c0 fc ff ff       	call   80101f84 <readi>
801022c4:	83 c4 10             	add    $0x10,%esp
801022c7:	83 f8 10             	cmp    $0x10,%eax
801022ca:	74 0d                	je     801022d9 <dirlookup+0x53>
      panic("dirlookup read");
801022cc:	83 ec 0c             	sub    $0xc,%esp
801022cf:	68 0f ab 10 80       	push   $0x8010ab0f
801022d4:	e8 ec e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801022d9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022dd:	66 85 c0             	test   %ax,%ax
801022e0:	74 47                	je     80102329 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801022e2:	83 ec 08             	sub    $0x8,%esp
801022e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e8:	83 c0 02             	add    $0x2,%eax
801022eb:	50                   	push   %eax
801022ec:	ff 75 0c             	pushl  0xc(%ebp)
801022ef:	e8 73 ff ff ff       	call   80102267 <namecmp>
801022f4:	83 c4 10             	add    $0x10,%esp
801022f7:	85 c0                	test   %eax,%eax
801022f9:	75 2f                	jne    8010232a <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801022fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022ff:	74 08                	je     80102309 <dirlookup+0x83>
        *poff = off;
80102301:	8b 45 10             	mov    0x10(%ebp),%eax
80102304:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102307:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102309:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010230d:	0f b7 c0             	movzwl %ax,%eax
80102310:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	8b 00                	mov    (%eax),%eax
80102318:	83 ec 08             	sub    $0x8,%esp
8010231b:	ff 75 f0             	pushl  -0x10(%ebp)
8010231e:	50                   	push   %eax
8010231f:	e8 34 f6 ff ff       	call   80101958 <iget>
80102324:	83 c4 10             	add    $0x10,%esp
80102327:	eb 19                	jmp    80102342 <dirlookup+0xbc>
      continue;
80102329:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010232a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010232e:	8b 45 08             	mov    0x8(%ebp),%eax
80102331:	8b 40 58             	mov    0x58(%eax),%eax
80102334:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102337:	0f 82 76 ff ff ff    	jb     801022b3 <dirlookup+0x2d>
    }
  }

  return 0;
8010233d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102342:	c9                   	leave  
80102343:	c3                   	ret    

80102344 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102344:	f3 0f 1e fb          	endbr32 
80102348:	55                   	push   %ebp
80102349:	89 e5                	mov    %esp,%ebp
8010234b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010234e:	83 ec 04             	sub    $0x4,%esp
80102351:	6a 00                	push   $0x0
80102353:	ff 75 0c             	pushl  0xc(%ebp)
80102356:	ff 75 08             	pushl  0x8(%ebp)
80102359:	e8 28 ff ff ff       	call   80102286 <dirlookup>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102364:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102368:	74 18                	je     80102382 <dirlink+0x3e>
    iput(ip);
8010236a:	83 ec 0c             	sub    $0xc,%esp
8010236d:	ff 75 f0             	pushl  -0x10(%ebp)
80102370:	e8 70 f8 ff ff       	call   80101be5 <iput>
80102375:	83 c4 10             	add    $0x10,%esp
    return -1;
80102378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010237d:	e9 9c 00 00 00       	jmp    8010241e <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102389:	eb 39                	jmp    801023c4 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010238b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238e:	6a 10                	push   $0x10
80102390:	50                   	push   %eax
80102391:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102394:	50                   	push   %eax
80102395:	ff 75 08             	pushl  0x8(%ebp)
80102398:	e8 e7 fb ff ff       	call   80101f84 <readi>
8010239d:	83 c4 10             	add    $0x10,%esp
801023a0:	83 f8 10             	cmp    $0x10,%eax
801023a3:	74 0d                	je     801023b2 <dirlink+0x6e>
      panic("dirlink read");
801023a5:	83 ec 0c             	sub    $0xc,%esp
801023a8:	68 1e ab 10 80       	push   $0x8010ab1e
801023ad:	e8 13 e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801023b2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023b6:	66 85 c0             	test   %ax,%ax
801023b9:	74 18                	je     801023d3 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023be:	83 c0 10             	add    $0x10,%eax
801023c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023c4:	8b 45 08             	mov    0x8(%ebp),%eax
801023c7:	8b 50 58             	mov    0x58(%eax),%edx
801023ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cd:	39 c2                	cmp    %eax,%edx
801023cf:	77 ba                	ja     8010238b <dirlink+0x47>
801023d1:	eb 01                	jmp    801023d4 <dirlink+0x90>
      break;
801023d3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	6a 0e                	push   $0xe
801023d9:	ff 75 0c             	pushl  0xc(%ebp)
801023dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023df:	83 c0 02             	add    $0x2,%eax
801023e2:	50                   	push   %eax
801023e3:	e8 08 2e 00 00       	call   801051f0 <strncpy>
801023e8:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023eb:	8b 45 10             	mov    0x10(%ebp),%eax
801023ee:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f5:	6a 10                	push   $0x10
801023f7:	50                   	push   %eax
801023f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023fb:	50                   	push   %eax
801023fc:	ff 75 08             	pushl  0x8(%ebp)
801023ff:	e8 d9 fc ff ff       	call   801020dd <writei>
80102404:	83 c4 10             	add    $0x10,%esp
80102407:	83 f8 10             	cmp    $0x10,%eax
8010240a:	74 0d                	je     80102419 <dirlink+0xd5>
    panic("dirlink");
8010240c:	83 ec 0c             	sub    $0xc,%esp
8010240f:	68 2b ab 10 80       	push   $0x8010ab2b
80102414:	e8 ac e1 ff ff       	call   801005c5 <panic>

  return 0;
80102419:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010241e:	c9                   	leave  
8010241f:	c3                   	ret    

80102420 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102420:	f3 0f 1e fb          	endbr32 
80102424:	55                   	push   %ebp
80102425:	89 e5                	mov    %esp,%ebp
80102427:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010242a:	eb 04                	jmp    80102430 <skipelem+0x10>
    path++;
8010242c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102430:	8b 45 08             	mov    0x8(%ebp),%eax
80102433:	0f b6 00             	movzbl (%eax),%eax
80102436:	3c 2f                	cmp    $0x2f,%al
80102438:	74 f2                	je     8010242c <skipelem+0xc>
  if(*path == 0)
8010243a:	8b 45 08             	mov    0x8(%ebp),%eax
8010243d:	0f b6 00             	movzbl (%eax),%eax
80102440:	84 c0                	test   %al,%al
80102442:	75 07                	jne    8010244b <skipelem+0x2b>
    return 0;
80102444:	b8 00 00 00 00       	mov    $0x0,%eax
80102449:	eb 77                	jmp    801024c2 <skipelem+0xa2>
  s = path;
8010244b:	8b 45 08             	mov    0x8(%ebp),%eax
8010244e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102451:	eb 04                	jmp    80102457 <skipelem+0x37>
    path++;
80102453:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102457:	8b 45 08             	mov    0x8(%ebp),%eax
8010245a:	0f b6 00             	movzbl (%eax),%eax
8010245d:	3c 2f                	cmp    $0x2f,%al
8010245f:	74 0a                	je     8010246b <skipelem+0x4b>
80102461:	8b 45 08             	mov    0x8(%ebp),%eax
80102464:	0f b6 00             	movzbl (%eax),%eax
80102467:	84 c0                	test   %al,%al
80102469:	75 e8                	jne    80102453 <skipelem+0x33>
  len = path - s;
8010246b:	8b 45 08             	mov    0x8(%ebp),%eax
8010246e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102471:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102474:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102478:	7e 15                	jle    8010248f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010247a:	83 ec 04             	sub    $0x4,%esp
8010247d:	6a 0e                	push   $0xe
8010247f:	ff 75 f4             	pushl  -0xc(%ebp)
80102482:	ff 75 0c             	pushl  0xc(%ebp)
80102485:	e8 6e 2c 00 00       	call   801050f8 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 57 2c 00 00       	call   801050f8 <memmove>
801024a1:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024aa:	01 d0                	add    %edx,%eax
801024ac:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024af:	eb 04                	jmp    801024b5 <skipelem+0x95>
    path++;
801024b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024b5:	8b 45 08             	mov    0x8(%ebp),%eax
801024b8:	0f b6 00             	movzbl (%eax),%eax
801024bb:	3c 2f                	cmp    $0x2f,%al
801024bd:	74 f2                	je     801024b1 <skipelem+0x91>
  return path;
801024bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024c2:	c9                   	leave  
801024c3:	c3                   	ret    

801024c4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024c4:	f3 0f 1e fb          	endbr32 
801024c8:	55                   	push   %ebp
801024c9:	89 e5                	mov    %esp,%ebp
801024cb:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	0f b6 00             	movzbl (%eax),%eax
801024d4:	3c 2f                	cmp    $0x2f,%al
801024d6:	75 17                	jne    801024ef <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024d8:	83 ec 08             	sub    $0x8,%esp
801024db:	6a 01                	push   $0x1
801024dd:	6a 01                	push   $0x1
801024df:	e8 74 f4 ff ff       	call   80101958 <iget>
801024e4:	83 c4 10             	add    $0x10,%esp
801024e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024ea:	e9 ba 00 00 00       	jmp    801025a9 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801024ef:	e8 b5 16 00 00       	call   80103ba9 <myproc>
801024f4:	8b 40 68             	mov    0x68(%eax),%eax
801024f7:	83 ec 0c             	sub    $0xc,%esp
801024fa:	50                   	push   %eax
801024fb:	e8 3e f5 ff ff       	call   80101a3e <idup>
80102500:	83 c4 10             	add    $0x10,%esp
80102503:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102506:	e9 9e 00 00 00       	jmp    801025a9 <namex+0xe5>
    ilock(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	pushl  -0xc(%ebp)
80102511:	e8 66 f5 ff ff       	call   80101a7c <ilock>
80102516:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102520:	66 83 f8 01          	cmp    $0x1,%ax
80102524:	74 18                	je     8010253e <namex+0x7a>
      iunlockput(ip);
80102526:	83 ec 0c             	sub    $0xc,%esp
80102529:	ff 75 f4             	pushl  -0xc(%ebp)
8010252c:	e8 88 f7 ff ff       	call   80101cb9 <iunlockput>
80102531:	83 c4 10             	add    $0x10,%esp
      return 0;
80102534:	b8 00 00 00 00       	mov    $0x0,%eax
80102539:	e9 a7 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010253e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102542:	74 20                	je     80102564 <namex+0xa0>
80102544:	8b 45 08             	mov    0x8(%ebp),%eax
80102547:	0f b6 00             	movzbl (%eax),%eax
8010254a:	84 c0                	test   %al,%al
8010254c:	75 16                	jne    80102564 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010254e:	83 ec 0c             	sub    $0xc,%esp
80102551:	ff 75 f4             	pushl  -0xc(%ebp)
80102554:	e8 3a f6 ff ff       	call   80101b93 <iunlock>
80102559:	83 c4 10             	add    $0x10,%esp
      return ip;
8010255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010255f:	e9 81 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102564:	83 ec 04             	sub    $0x4,%esp
80102567:	6a 00                	push   $0x0
80102569:	ff 75 10             	pushl  0x10(%ebp)
8010256c:	ff 75 f4             	pushl  -0xc(%ebp)
8010256f:	e8 12 fd ff ff       	call   80102286 <dirlookup>
80102574:	83 c4 10             	add    $0x10,%esp
80102577:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010257a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010257e:	75 15                	jne    80102595 <namex+0xd1>
      iunlockput(ip);
80102580:	83 ec 0c             	sub    $0xc,%esp
80102583:	ff 75 f4             	pushl  -0xc(%ebp)
80102586:	e8 2e f7 ff ff       	call   80101cb9 <iunlockput>
8010258b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010258e:	b8 00 00 00 00       	mov    $0x0,%eax
80102593:	eb 50                	jmp    801025e5 <namex+0x121>
    }
    iunlockput(ip);
80102595:	83 ec 0c             	sub    $0xc,%esp
80102598:	ff 75 f4             	pushl  -0xc(%ebp)
8010259b:	e8 19 f7 ff ff       	call   80101cb9 <iunlockput>
801025a0:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025a9:	83 ec 08             	sub    $0x8,%esp
801025ac:	ff 75 10             	pushl  0x10(%ebp)
801025af:	ff 75 08             	pushl  0x8(%ebp)
801025b2:	e8 69 fe ff ff       	call   80102420 <skipelem>
801025b7:	83 c4 10             	add    $0x10,%esp
801025ba:	89 45 08             	mov    %eax,0x8(%ebp)
801025bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c1:	0f 85 44 ff ff ff    	jne    8010250b <namex+0x47>
  }
  if(nameiparent){
801025c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025cb:	74 15                	je     801025e2 <namex+0x11e>
    iput(ip);
801025cd:	83 ec 0c             	sub    $0xc,%esp
801025d0:	ff 75 f4             	pushl  -0xc(%ebp)
801025d3:	e8 0d f6 ff ff       	call   80101be5 <iput>
801025d8:	83 c4 10             	add    $0x10,%esp
    return 0;
801025db:	b8 00 00 00 00       	mov    $0x0,%eax
801025e0:	eb 03                	jmp    801025e5 <namex+0x121>
  }
  return ip;
801025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025e5:	c9                   	leave  
801025e6:	c3                   	ret    

801025e7 <namei>:

struct inode*
namei(char *path)
{
801025e7:	f3 0f 1e fb          	endbr32 
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025f1:	83 ec 04             	sub    $0x4,%esp
801025f4:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025f7:	50                   	push   %eax
801025f8:	6a 00                	push   $0x0
801025fa:	ff 75 08             	pushl  0x8(%ebp)
801025fd:	e8 c2 fe ff ff       	call   801024c4 <namex>
80102602:	83 c4 10             	add    $0x10,%esp
}
80102605:	c9                   	leave  
80102606:	c3                   	ret    

80102607 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102607:	f3 0f 1e fb          	endbr32 
8010260b:	55                   	push   %ebp
8010260c:	89 e5                	mov    %esp,%ebp
8010260e:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102611:	83 ec 04             	sub    $0x4,%esp
80102614:	ff 75 0c             	pushl  0xc(%ebp)
80102617:	6a 01                	push   $0x1
80102619:	ff 75 08             	pushl  0x8(%ebp)
8010261c:	e8 a3 fe ff ff       	call   801024c4 <namex>
80102621:	83 c4 10             	add    $0x10,%esp
}
80102624:	c9                   	leave  
80102625:	c3                   	ret    

80102626 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102626:	f3 0f 1e fb          	endbr32 
8010262a:	55                   	push   %ebp
8010262b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010262d:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102632:	8b 55 08             	mov    0x8(%ebp),%edx
80102635:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102637:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010263c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010263f:	5d                   	pop    %ebp
80102640:	c3                   	ret    

80102641 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102641:	f3 0f 1e fb          	endbr32 
80102645:	55                   	push   %ebp
80102646:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102648:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010264d:	8b 55 08             	mov    0x8(%ebp),%edx
80102650:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102652:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102657:	8b 55 0c             	mov    0xc(%ebp),%edx
8010265a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010265d:	90                   	nop
8010265e:	5d                   	pop    %ebp
8010265f:	c3                   	ret    

80102660 <ioapicinit>:

void
ioapicinit(void)
{
80102660:	f3 0f 1e fb          	endbr32 
80102664:	55                   	push   %ebp
80102665:	89 e5                	mov    %esp,%ebp
80102667:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010266a:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
80102671:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102674:	6a 01                	push   $0x1
80102676:	e8 ab ff ff ff       	call   80102626 <ioapicread>
8010267b:	83 c4 04             	add    $0x4,%esp
8010267e:	c1 e8 10             	shr    $0x10,%eax
80102681:	25 ff 00 00 00       	and    $0xff,%eax
80102686:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102689:	6a 00                	push   $0x0
8010268b:	e8 96 ff ff ff       	call   80102626 <ioapicread>
80102690:	83 c4 04             	add    $0x4,%esp
80102693:	c1 e8 18             	shr    $0x18,%eax
80102696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102699:	0f b6 05 a0 85 19 80 	movzbl 0x801985a0,%eax
801026a0:	0f b6 c0             	movzbl %al,%eax
801026a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026a6:	74 10                	je     801026b8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 34 ab 10 80       	push   $0x8010ab34
801026b0:	e8 57 dd ff ff       	call   8010040c <cprintf>
801026b5:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801026b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026bf:	eb 3f                	jmp    80102700 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c4:	83 c0 20             	add    $0x20,%eax
801026c7:	0d 00 00 01 00       	or     $0x10000,%eax
801026cc:	89 c2                	mov    %eax,%edx
801026ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d1:	83 c0 08             	add    $0x8,%eax
801026d4:	01 c0                	add    %eax,%eax
801026d6:	83 ec 08             	sub    $0x8,%esp
801026d9:	52                   	push   %edx
801026da:	50                   	push   %eax
801026db:	e8 61 ff ff ff       	call   80102641 <ioapicwrite>
801026e0:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801026e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e6:	83 c0 08             	add    $0x8,%eax
801026e9:	01 c0                	add    %eax,%eax
801026eb:	83 c0 01             	add    $0x1,%eax
801026ee:	83 ec 08             	sub    $0x8,%esp
801026f1:	6a 00                	push   $0x0
801026f3:	50                   	push   %eax
801026f4:	e8 48 ff ff ff       	call   80102641 <ioapicwrite>
801026f9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
801026fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102703:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102706:	7e b9                	jle    801026c1 <ioapicinit+0x61>
  }
}
80102708:	90                   	nop
80102709:	90                   	nop
8010270a:	c9                   	leave  
8010270b:	c3                   	ret    

8010270c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010270c:	f3 0f 1e fb          	endbr32 
80102710:	55                   	push   %ebp
80102711:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102713:	8b 45 08             	mov    0x8(%ebp),%eax
80102716:	83 c0 20             	add    $0x20,%eax
80102719:	89 c2                	mov    %eax,%edx
8010271b:	8b 45 08             	mov    0x8(%ebp),%eax
8010271e:	83 c0 08             	add    $0x8,%eax
80102721:	01 c0                	add    %eax,%eax
80102723:	52                   	push   %edx
80102724:	50                   	push   %eax
80102725:	e8 17 ff ff ff       	call   80102641 <ioapicwrite>
8010272a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010272d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102730:	c1 e0 18             	shl    $0x18,%eax
80102733:	89 c2                	mov    %eax,%edx
80102735:	8b 45 08             	mov    0x8(%ebp),%eax
80102738:	83 c0 08             	add    $0x8,%eax
8010273b:	01 c0                	add    %eax,%eax
8010273d:	83 c0 01             	add    $0x1,%eax
80102740:	52                   	push   %edx
80102741:	50                   	push   %eax
80102742:	e8 fa fe ff ff       	call   80102641 <ioapicwrite>
80102747:	83 c4 08             	add    $0x8,%esp
}
8010274a:	90                   	nop
8010274b:	c9                   	leave  
8010274c:	c3                   	ret    

8010274d <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010274d:	f3 0f 1e fb          	endbr32 
80102751:	55                   	push   %ebp
80102752:	89 e5                	mov    %esp,%ebp
80102754:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	68 66 ab 10 80       	push   $0x8010ab66
8010275f:	68 e0 53 19 80       	push   $0x801953e0
80102764:	e8 13 26 00 00       	call   80104d7c <initlock>
80102769:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010276c:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
80102773:	00 00 00 
  freerange(vstart, vend);
80102776:	83 ec 08             	sub    $0x8,%esp
80102779:	ff 75 0c             	pushl  0xc(%ebp)
8010277c:	ff 75 08             	pushl  0x8(%ebp)
8010277f:	e8 2e 00 00 00       	call   801027b2 <freerange>
80102784:	83 c4 10             	add    $0x10,%esp
}
80102787:	90                   	nop
80102788:	c9                   	leave  
80102789:	c3                   	ret    

8010278a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010278a:	f3 0f 1e fb          	endbr32 
8010278e:	55                   	push   %ebp
8010278f:	89 e5                	mov    %esp,%ebp
80102791:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102794:	83 ec 08             	sub    $0x8,%esp
80102797:	ff 75 0c             	pushl  0xc(%ebp)
8010279a:	ff 75 08             	pushl  0x8(%ebp)
8010279d:	e8 10 00 00 00       	call   801027b2 <freerange>
801027a2:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801027a5:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
801027ac:	00 00 00 
}
801027af:	90                   	nop
801027b0:	c9                   	leave  
801027b1:	c3                   	ret    

801027b2 <freerange>:

void
freerange(void *vstart, void *vend)
{
801027b2:	f3 0f 1e fb          	endbr32 
801027b6:	55                   	push   %ebp
801027b7:	89 e5                	mov    %esp,%ebp
801027b9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801027bc:	8b 45 08             	mov    0x8(%ebp),%eax
801027bf:	05 ff 0f 00 00       	add    $0xfff,%eax
801027c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801027c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027cc:	eb 15                	jmp    801027e3 <freerange+0x31>
    kfree(p);
801027ce:	83 ec 0c             	sub    $0xc,%esp
801027d1:	ff 75 f4             	pushl  -0xc(%ebp)
801027d4:	e8 1b 00 00 00       	call   801027f4 <kfree>
801027d9:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801027e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e6:	05 00 10 00 00       	add    $0x1000,%eax
801027eb:	39 45 0c             	cmp    %eax,0xc(%ebp)
801027ee:	73 de                	jae    801027ce <freerange+0x1c>
}
801027f0:	90                   	nop
801027f1:	90                   	nop
801027f2:	c9                   	leave  
801027f3:	c3                   	ret    

801027f4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801027f4:	f3 0f 1e fb          	endbr32 
801027f8:	55                   	push   %ebp
801027f9:	89 e5                	mov    %esp,%ebp
801027fb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801027fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102801:	25 ff 0f 00 00       	and    $0xfff,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 18                	jne    80102822 <kfree+0x2e>
8010280a:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102811:	72 0f                	jb     80102822 <kfree+0x2e>
80102813:	8b 45 08             	mov    0x8(%ebp),%eax
80102816:	05 00 00 00 80       	add    $0x80000000,%eax
8010281b:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102820:	76 0d                	jbe    8010282f <kfree+0x3b>
    panic("kfree");
80102822:	83 ec 0c             	sub    $0xc,%esp
80102825:	68 6b ab 10 80       	push   $0x8010ab6b
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	pushl  0x8(%ebp)
8010283c:	e8 f0 27 00 00       	call   80105031 <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 14 54 19 80       	mov    0x80195414,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 e0 53 19 80       	push   $0x801953e0
80102855:	e8 48 25 00 00       	call   80104da2 <acquire>
8010285a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102863:	8b 15 18 54 19 80    	mov    0x80195418,%edx
80102869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010286e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102871:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
80102876:	a1 14 54 19 80       	mov    0x80195414,%eax
8010287b:	85 c0                	test   %eax,%eax
8010287d:	74 10                	je     8010288f <kfree+0x9b>
    release(&kmem.lock);
8010287f:	83 ec 0c             	sub    $0xc,%esp
80102882:	68 e0 53 19 80       	push   $0x801953e0
80102887:	e8 88 25 00 00       	call   80104e14 <release>
8010288c:	83 c4 10             	add    $0x10,%esp
}
8010288f:	90                   	nop
80102890:	c9                   	leave  
80102891:	c3                   	ret    

80102892 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102892:	f3 0f 1e fb          	endbr32 
80102896:	55                   	push   %ebp
80102897:	89 e5                	mov    %esp,%ebp
80102899:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010289c:	a1 14 54 19 80       	mov    0x80195414,%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	74 10                	je     801028b5 <kalloc+0x23>
    acquire(&kmem.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 e0 53 19 80       	push   $0x801953e0
801028ad:	e8 f0 24 00 00       	call   80104da2 <acquire>
801028b2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028b5:	a1 18 54 19 80       	mov    0x80195418,%eax
801028ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028c1:	74 0a                	je     801028cd <kalloc+0x3b>
    kmem.freelist = r->next;
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	8b 00                	mov    (%eax),%eax
801028c8:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028cd:	a1 14 54 19 80       	mov    0x80195414,%eax
801028d2:	85 c0                	test   %eax,%eax
801028d4:	74 10                	je     801028e6 <kalloc+0x54>
    release(&kmem.lock);
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	68 e0 53 19 80       	push   $0x801953e0
801028de:	e8 31 25 00 00       	call   80104e14 <release>
801028e3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801028e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801028e9:	c9                   	leave  
801028ea:	c3                   	ret    

801028eb <inb>:
{
801028eb:	55                   	push   %ebp
801028ec:	89 e5                	mov    %esp,%ebp
801028ee:	83 ec 14             	sub    $0x14,%esp
801028f1:	8b 45 08             	mov    0x8(%ebp),%eax
801028f4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028f8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801028fc:	89 c2                	mov    %eax,%edx
801028fe:	ec                   	in     (%dx),%al
801028ff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102902:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102906:	c9                   	leave  
80102907:	c3                   	ret    

80102908 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102908:	f3 0f 1e fb          	endbr32 
8010290c:	55                   	push   %ebp
8010290d:	89 e5                	mov    %esp,%ebp
8010290f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102912:	6a 64                	push   $0x64
80102914:	e8 d2 ff ff ff       	call   801028eb <inb>
80102919:	83 c4 04             	add    $0x4,%esp
8010291c:	0f b6 c0             	movzbl %al,%eax
8010291f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102925:	83 e0 01             	and    $0x1,%eax
80102928:	85 c0                	test   %eax,%eax
8010292a:	75 0a                	jne    80102936 <kbdgetc+0x2e>
    return -1;
8010292c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102931:	e9 23 01 00 00       	jmp    80102a59 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102936:	6a 60                	push   $0x60
80102938:	e8 ae ff ff ff       	call   801028eb <inb>
8010293d:	83 c4 04             	add    $0x4,%esp
80102940:	0f b6 c0             	movzbl %al,%eax
80102943:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102946:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010294d:	75 17                	jne    80102966 <kbdgetc+0x5e>
    shift |= E0ESC;
8010294f:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102954:	83 c8 40             	or     $0x40,%eax
80102957:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
8010295c:	b8 00 00 00 00       	mov    $0x0,%eax
80102961:	e9 f3 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(data & 0x80){
80102966:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102969:	25 80 00 00 00       	and    $0x80,%eax
8010296e:	85 c0                	test   %eax,%eax
80102970:	74 45                	je     801029b7 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102972:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102977:	83 e0 40             	and    $0x40,%eax
8010297a:	85 c0                	test   %eax,%eax
8010297c:	75 08                	jne    80102986 <kbdgetc+0x7e>
8010297e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102981:	83 e0 7f             	and    $0x7f,%eax
80102984:	eb 03                	jmp    80102989 <kbdgetc+0x81>
80102986:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102989:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010298c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010298f:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102994:	0f b6 00             	movzbl (%eax),%eax
80102997:	83 c8 40             	or     $0x40,%eax
8010299a:	0f b6 c0             	movzbl %al,%eax
8010299d:	f7 d0                	not    %eax
8010299f:	89 c2                	mov    %eax,%edx
801029a1:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029a6:	21 d0                	and    %edx,%eax
801029a8:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029ad:	b8 00 00 00 00       	mov    $0x0,%eax
801029b2:	e9 a2 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(shift & E0ESC){
801029b7:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029bc:	83 e0 40             	and    $0x40,%eax
801029bf:	85 c0                	test   %eax,%eax
801029c1:	74 14                	je     801029d7 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029c3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801029ca:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029cf:	83 e0 bf             	and    $0xffffffbf,%eax
801029d2:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
801029d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029da:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029df:	0f b6 00             	movzbl (%eax),%eax
801029e2:	0f b6 d0             	movzbl %al,%edx
801029e5:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029ea:	09 d0                	or     %edx,%eax
801029ec:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
801029f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029f4:	05 20 d1 10 80       	add    $0x8010d120,%eax
801029f9:	0f b6 00             	movzbl (%eax),%eax
801029fc:	0f b6 d0             	movzbl %al,%edx
801029ff:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a04:	31 d0                	xor    %edx,%eax
80102a06:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a0b:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a10:	83 e0 03             	and    $0x3,%eax
80102a13:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a1d:	01 d0                	add    %edx,%eax
80102a1f:	0f b6 00             	movzbl (%eax),%eax
80102a22:	0f b6 c0             	movzbl %al,%eax
80102a25:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a28:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a2d:	83 e0 08             	and    $0x8,%eax
80102a30:	85 c0                	test   %eax,%eax
80102a32:	74 22                	je     80102a56 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a34:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a38:	76 0c                	jbe    80102a46 <kbdgetc+0x13e>
80102a3a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a3e:	77 06                	ja     80102a46 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a40:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102a44:	eb 10                	jmp    80102a56 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102a46:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102a4a:	76 0a                	jbe    80102a56 <kbdgetc+0x14e>
80102a4c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102a50:	77 04                	ja     80102a56 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102a52:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102a56:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102a59:	c9                   	leave  
80102a5a:	c3                   	ret    

80102a5b <kbdintr>:

void
kbdintr(void)
{
80102a5b:	f3 0f 1e fb          	endbr32 
80102a5f:	55                   	push   %ebp
80102a60:	89 e5                	mov    %esp,%ebp
80102a62:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	68 08 29 10 80       	push   $0x80102908
80102a6d:	e8 8e dd ff ff       	call   80100800 <consoleintr>
80102a72:	83 c4 10             	add    $0x10,%esp
}
80102a75:	90                   	nop
80102a76:	c9                   	leave  
80102a77:	c3                   	ret    

80102a78 <inb>:
{
80102a78:	55                   	push   %ebp
80102a79:	89 e5                	mov    %esp,%ebp
80102a7b:	83 ec 14             	sub    $0x14,%esp
80102a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a81:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a85:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102a89:	89 c2                	mov    %eax,%edx
80102a8b:	ec                   	in     (%dx),%al
80102a8c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102a8f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102a93:	c9                   	leave  
80102a94:	c3                   	ret    

80102a95 <outb>:
{
80102a95:	55                   	push   %ebp
80102a96:	89 e5                	mov    %esp,%ebp
80102a98:	83 ec 08             	sub    $0x8,%esp
80102a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102aa1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102aa5:	89 d0                	mov    %edx,%eax
80102aa7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aaa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102aae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ab2:	ee                   	out    %al,(%dx)
}
80102ab3:	90                   	nop
80102ab4:	c9                   	leave  
80102ab5:	c3                   	ret    

80102ab6 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ab6:	f3 0f 1e fb          	endbr32 
80102aba:	55                   	push   %ebp
80102abb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102abd:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac5:	c1 e2 02             	shl    $0x2,%edx
80102ac8:	01 c2                	add    %eax,%edx
80102aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80102acd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102acf:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ad4:	83 c0 20             	add    $0x20,%eax
80102ad7:	8b 00                	mov    (%eax),%eax
}
80102ad9:	90                   	nop
80102ada:	5d                   	pop    %ebp
80102adb:	c3                   	ret    

80102adc <lapicinit>:

void
lapicinit(void)
{
80102adc:	f3 0f 1e fb          	endbr32 
80102ae0:	55                   	push   %ebp
80102ae1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ae3:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ae8:	85 c0                	test   %eax,%eax
80102aea:	0f 84 0c 01 00 00    	je     80102bfc <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102af0:	68 3f 01 00 00       	push   $0x13f
80102af5:	6a 3c                	push   $0x3c
80102af7:	e8 ba ff ff ff       	call   80102ab6 <lapicw>
80102afc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102aff:	6a 0b                	push   $0xb
80102b01:	68 f8 00 00 00       	push   $0xf8
80102b06:	e8 ab ff ff ff       	call   80102ab6 <lapicw>
80102b0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b0e:	68 20 00 02 00       	push   $0x20020
80102b13:	68 c8 00 00 00       	push   $0xc8
80102b18:	e8 99 ff ff ff       	call   80102ab6 <lapicw>
80102b1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b20:	68 80 96 98 00       	push   $0x989680
80102b25:	68 e0 00 00 00       	push   $0xe0
80102b2a:	e8 87 ff ff ff       	call   80102ab6 <lapicw>
80102b2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b32:	68 00 00 01 00       	push   $0x10000
80102b37:	68 d4 00 00 00       	push   $0xd4
80102b3c:	e8 75 ff ff ff       	call   80102ab6 <lapicw>
80102b41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102b44:	68 00 00 01 00       	push   $0x10000
80102b49:	68 d8 00 00 00       	push   $0xd8
80102b4e:	e8 63 ff ff ff       	call   80102ab6 <lapicw>
80102b53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b56:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b5b:	83 c0 30             	add    $0x30,%eax
80102b5e:	8b 00                	mov    (%eax),%eax
80102b60:	c1 e8 10             	shr    $0x10,%eax
80102b63:	25 fc 00 00 00       	and    $0xfc,%eax
80102b68:	85 c0                	test   %eax,%eax
80102b6a:	74 12                	je     80102b7e <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102b6c:	68 00 00 01 00       	push   $0x10000
80102b71:	68 d0 00 00 00       	push   $0xd0
80102b76:	e8 3b ff ff ff       	call   80102ab6 <lapicw>
80102b7b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102b7e:	6a 33                	push   $0x33
80102b80:	68 dc 00 00 00       	push   $0xdc
80102b85:	e8 2c ff ff ff       	call   80102ab6 <lapicw>
80102b8a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102b8d:	6a 00                	push   $0x0
80102b8f:	68 a0 00 00 00       	push   $0xa0
80102b94:	e8 1d ff ff ff       	call   80102ab6 <lapicw>
80102b99:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102b9c:	6a 00                	push   $0x0
80102b9e:	68 a0 00 00 00       	push   $0xa0
80102ba3:	e8 0e ff ff ff       	call   80102ab6 <lapicw>
80102ba8:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102bab:	6a 00                	push   $0x0
80102bad:	6a 2c                	push   $0x2c
80102baf:	e8 02 ff ff ff       	call   80102ab6 <lapicw>
80102bb4:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102bb7:	6a 00                	push   $0x0
80102bb9:	68 c4 00 00 00       	push   $0xc4
80102bbe:	e8 f3 fe ff ff       	call   80102ab6 <lapicw>
80102bc3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102bc6:	68 00 85 08 00       	push   $0x88500
80102bcb:	68 c0 00 00 00       	push   $0xc0
80102bd0:	e8 e1 fe ff ff       	call   80102ab6 <lapicw>
80102bd5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102bd8:	90                   	nop
80102bd9:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bde:	05 00 03 00 00       	add    $0x300,%eax
80102be3:	8b 00                	mov    (%eax),%eax
80102be5:	25 00 10 00 00       	and    $0x1000,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	75 eb                	jne    80102bd9 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102bee:	6a 00                	push   $0x0
80102bf0:	6a 20                	push   $0x20
80102bf2:	e8 bf fe ff ff       	call   80102ab6 <lapicw>
80102bf7:	83 c4 08             	add    $0x8,%esp
80102bfa:	eb 01                	jmp    80102bfd <lapicinit+0x121>
    return;
80102bfc:	90                   	nop
}
80102bfd:	c9                   	leave  
80102bfe:	c3                   	ret    

80102bff <lapicid>:

int
lapicid(void)
{
80102bff:	f3 0f 1e fb          	endbr32 
80102c03:	55                   	push   %ebp
80102c04:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c06:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c0b:	85 c0                	test   %eax,%eax
80102c0d:	75 07                	jne    80102c16 <lapicid+0x17>
    return 0;
80102c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c14:	eb 0d                	jmp    80102c23 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c16:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c1b:	83 c0 20             	add    $0x20,%eax
80102c1e:	8b 00                	mov    (%eax),%eax
80102c20:	c1 e8 18             	shr    $0x18,%eax
}
80102c23:	5d                   	pop    %ebp
80102c24:	c3                   	ret    

80102c25 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c25:	f3 0f 1e fb          	endbr32 
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c2c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	74 0c                	je     80102c41 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c35:	6a 00                	push   $0x0
80102c37:	6a 2c                	push   $0x2c
80102c39:	e8 78 fe ff ff       	call   80102ab6 <lapicw>
80102c3e:	83 c4 08             	add    $0x8,%esp
}
80102c41:	90                   	nop
80102c42:	c9                   	leave  
80102c43:	c3                   	ret    

80102c44 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c44:	f3 0f 1e fb          	endbr32 
80102c48:	55                   	push   %ebp
80102c49:	89 e5                	mov    %esp,%ebp
}
80102c4b:	90                   	nop
80102c4c:	5d                   	pop    %ebp
80102c4d:	c3                   	ret    

80102c4e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c4e:	f3 0f 1e fb          	endbr32 
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
80102c55:	83 ec 14             	sub    $0x14,%esp
80102c58:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102c5e:	6a 0f                	push   $0xf
80102c60:	6a 70                	push   $0x70
80102c62:	e8 2e fe ff ff       	call   80102a95 <outb>
80102c67:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102c6a:	6a 0a                	push   $0xa
80102c6c:	6a 71                	push   $0x71
80102c6e:	e8 22 fe ff ff       	call   80102a95 <outb>
80102c73:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102c76:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102c7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c80:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102c85:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c88:	c1 e8 04             	shr    $0x4,%eax
80102c8b:	89 c2                	mov    %eax,%edx
80102c8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c90:	83 c0 02             	add    $0x2,%eax
80102c93:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102c96:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102c9a:	c1 e0 18             	shl    $0x18,%eax
80102c9d:	50                   	push   %eax
80102c9e:	68 c4 00 00 00       	push   $0xc4
80102ca3:	e8 0e fe ff ff       	call   80102ab6 <lapicw>
80102ca8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102cab:	68 00 c5 00 00       	push   $0xc500
80102cb0:	68 c0 00 00 00       	push   $0xc0
80102cb5:	e8 fc fd ff ff       	call   80102ab6 <lapicw>
80102cba:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102cbd:	68 c8 00 00 00       	push   $0xc8
80102cc2:	e8 7d ff ff ff       	call   80102c44 <microdelay>
80102cc7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102cca:	68 00 85 00 00       	push   $0x8500
80102ccf:	68 c0 00 00 00       	push   $0xc0
80102cd4:	e8 dd fd ff ff       	call   80102ab6 <lapicw>
80102cd9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102cdc:	6a 64                	push   $0x64
80102cde:	e8 61 ff ff ff       	call   80102c44 <microdelay>
80102ce3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ce6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102ced:	eb 3d                	jmp    80102d2c <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102cef:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102cf3:	c1 e0 18             	shl    $0x18,%eax
80102cf6:	50                   	push   %eax
80102cf7:	68 c4 00 00 00       	push   $0xc4
80102cfc:	e8 b5 fd ff ff       	call   80102ab6 <lapicw>
80102d01:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d07:	c1 e8 0c             	shr    $0xc,%eax
80102d0a:	80 cc 06             	or     $0x6,%ah
80102d0d:	50                   	push   %eax
80102d0e:	68 c0 00 00 00       	push   $0xc0
80102d13:	e8 9e fd ff ff       	call   80102ab6 <lapicw>
80102d18:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d1b:	68 c8 00 00 00       	push   $0xc8
80102d20:	e8 1f ff ff ff       	call   80102c44 <microdelay>
80102d25:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d2c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d30:	7e bd                	jle    80102cef <lapicstartap+0xa1>
  }
}
80102d32:	90                   	nop
80102d33:	90                   	nop
80102d34:	c9                   	leave  
80102d35:	c3                   	ret    

80102d36 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d36:	f3 0f 1e fb          	endbr32 
80102d3a:	55                   	push   %ebp
80102d3b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d40:	0f b6 c0             	movzbl %al,%eax
80102d43:	50                   	push   %eax
80102d44:	6a 70                	push   $0x70
80102d46:	e8 4a fd ff ff       	call   80102a95 <outb>
80102d4b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d4e:	68 c8 00 00 00       	push   $0xc8
80102d53:	e8 ec fe ff ff       	call   80102c44 <microdelay>
80102d58:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102d5b:	6a 71                	push   $0x71
80102d5d:	e8 16 fd ff ff       	call   80102a78 <inb>
80102d62:	83 c4 04             	add    $0x4,%esp
80102d65:	0f b6 c0             	movzbl %al,%eax
}
80102d68:	c9                   	leave  
80102d69:	c3                   	ret    

80102d6a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102d6a:	f3 0f 1e fb          	endbr32 
80102d6e:	55                   	push   %ebp
80102d6f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102d71:	6a 00                	push   $0x0
80102d73:	e8 be ff ff ff       	call   80102d36 <cmos_read>
80102d78:	83 c4 04             	add    $0x4,%esp
80102d7b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d7e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102d80:	6a 02                	push   $0x2
80102d82:	e8 af ff ff ff       	call   80102d36 <cmos_read>
80102d87:	83 c4 04             	add    $0x4,%esp
80102d8a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102d90:	6a 04                	push   $0x4
80102d92:	e8 9f ff ff ff       	call   80102d36 <cmos_read>
80102d97:	83 c4 04             	add    $0x4,%esp
80102d9a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102da0:	6a 07                	push   $0x7
80102da2:	e8 8f ff ff ff       	call   80102d36 <cmos_read>
80102da7:	83 c4 04             	add    $0x4,%esp
80102daa:	8b 55 08             	mov    0x8(%ebp),%edx
80102dad:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102db0:	6a 08                	push   $0x8
80102db2:	e8 7f ff ff ff       	call   80102d36 <cmos_read>
80102db7:	83 c4 04             	add    $0x4,%esp
80102dba:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbd:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102dc0:	6a 09                	push   $0x9
80102dc2:	e8 6f ff ff ff       	call   80102d36 <cmos_read>
80102dc7:	83 c4 04             	add    $0x4,%esp
80102dca:	8b 55 08             	mov    0x8(%ebp),%edx
80102dcd:	89 42 14             	mov    %eax,0x14(%edx)
}
80102dd0:	90                   	nop
80102dd1:	c9                   	leave  
80102dd2:	c3                   	ret    

80102dd3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102dd3:	f3 0f 1e fb          	endbr32 
80102dd7:	55                   	push   %ebp
80102dd8:	89 e5                	mov    %esp,%ebp
80102dda:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102ddd:	6a 0b                	push   $0xb
80102ddf:	e8 52 ff ff ff       	call   80102d36 <cmos_read>
80102de4:	83 c4 04             	add    $0x4,%esp
80102de7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ded:	83 e0 04             	and    $0x4,%eax
80102df0:	85 c0                	test   %eax,%eax
80102df2:	0f 94 c0             	sete   %al
80102df5:	0f b6 c0             	movzbl %al,%eax
80102df8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102dfb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102dfe:	50                   	push   %eax
80102dff:	e8 66 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e04:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e07:	6a 0a                	push   $0xa
80102e09:	e8 28 ff ff ff       	call   80102d36 <cmos_read>
80102e0e:	83 c4 04             	add    $0x4,%esp
80102e11:	25 80 00 00 00       	and    $0x80,%eax
80102e16:	85 c0                	test   %eax,%eax
80102e18:	75 27                	jne    80102e41 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e1a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e1d:	50                   	push   %eax
80102e1e:	e8 47 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e23:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e26:	83 ec 04             	sub    $0x4,%esp
80102e29:	6a 18                	push   $0x18
80102e2b:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e2e:	50                   	push   %eax
80102e2f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e32:	50                   	push   %eax
80102e33:	e8 64 22 00 00       	call   8010509c <memcmp>
80102e38:	83 c4 10             	add    $0x10,%esp
80102e3b:	85 c0                	test   %eax,%eax
80102e3d:	74 05                	je     80102e44 <cmostime+0x71>
80102e3f:	eb ba                	jmp    80102dfb <cmostime+0x28>
        continue;
80102e41:	90                   	nop
    fill_rtcdate(&t1);
80102e42:	eb b7                	jmp    80102dfb <cmostime+0x28>
      break;
80102e44:	90                   	nop
  }

  // convert
  if(bcd) {
80102e45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102e49:	0f 84 b4 00 00 00    	je     80102f03 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102e4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e52:	c1 e8 04             	shr    $0x4,%eax
80102e55:	89 c2                	mov    %eax,%edx
80102e57:	89 d0                	mov    %edx,%eax
80102e59:	c1 e0 02             	shl    $0x2,%eax
80102e5c:	01 d0                	add    %edx,%eax
80102e5e:	01 c0                	add    %eax,%eax
80102e60:	89 c2                	mov    %eax,%edx
80102e62:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e65:	83 e0 0f             	and    $0xf,%eax
80102e68:	01 d0                	add    %edx,%eax
80102e6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102e6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e70:	c1 e8 04             	shr    $0x4,%eax
80102e73:	89 c2                	mov    %eax,%edx
80102e75:	89 d0                	mov    %edx,%eax
80102e77:	c1 e0 02             	shl    $0x2,%eax
80102e7a:	01 d0                	add    %edx,%eax
80102e7c:	01 c0                	add    %eax,%eax
80102e7e:	89 c2                	mov    %eax,%edx
80102e80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e83:	83 e0 0f             	and    $0xf,%eax
80102e86:	01 d0                	add    %edx,%eax
80102e88:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102e8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102e8e:	c1 e8 04             	shr    $0x4,%eax
80102e91:	89 c2                	mov    %eax,%edx
80102e93:	89 d0                	mov    %edx,%eax
80102e95:	c1 e0 02             	shl    $0x2,%eax
80102e98:	01 d0                	add    %edx,%eax
80102e9a:	01 c0                	add    %eax,%eax
80102e9c:	89 c2                	mov    %eax,%edx
80102e9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ea1:	83 e0 0f             	and    $0xf,%eax
80102ea4:	01 d0                	add    %edx,%eax
80102ea6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102eac:	c1 e8 04             	shr    $0x4,%eax
80102eaf:	89 c2                	mov    %eax,%edx
80102eb1:	89 d0                	mov    %edx,%eax
80102eb3:	c1 e0 02             	shl    $0x2,%eax
80102eb6:	01 d0                	add    %edx,%eax
80102eb8:	01 c0                	add    %eax,%eax
80102eba:	89 c2                	mov    %eax,%edx
80102ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ebf:	83 e0 0f             	and    $0xf,%eax
80102ec2:	01 d0                	add    %edx,%eax
80102ec4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102eca:	c1 e8 04             	shr    $0x4,%eax
80102ecd:	89 c2                	mov    %eax,%edx
80102ecf:	89 d0                	mov    %edx,%eax
80102ed1:	c1 e0 02             	shl    $0x2,%eax
80102ed4:	01 d0                	add    %edx,%eax
80102ed6:	01 c0                	add    %eax,%eax
80102ed8:	89 c2                	mov    %eax,%edx
80102eda:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102edd:	83 e0 0f             	and    $0xf,%eax
80102ee0:	01 d0                	add    %edx,%eax
80102ee2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ee8:	c1 e8 04             	shr    $0x4,%eax
80102eeb:	89 c2                	mov    %eax,%edx
80102eed:	89 d0                	mov    %edx,%eax
80102eef:	c1 e0 02             	shl    $0x2,%eax
80102ef2:	01 d0                	add    %edx,%eax
80102ef4:	01 c0                	add    %eax,%eax
80102ef6:	89 c2                	mov    %eax,%edx
80102ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102efb:	83 e0 0f             	and    $0xf,%eax
80102efe:	01 d0                	add    %edx,%eax
80102f00:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f03:	8b 45 08             	mov    0x8(%ebp),%eax
80102f06:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f09:	89 10                	mov    %edx,(%eax)
80102f0b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f0e:	89 50 04             	mov    %edx,0x4(%eax)
80102f11:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f14:	89 50 08             	mov    %edx,0x8(%eax)
80102f17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f1a:	89 50 0c             	mov    %edx,0xc(%eax)
80102f1d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f20:	89 50 10             	mov    %edx,0x10(%eax)
80102f23:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f26:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f29:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2c:	8b 40 14             	mov    0x14(%eax),%eax
80102f2f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f35:	8b 45 08             	mov    0x8(%ebp),%eax
80102f38:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f3b:	90                   	nop
80102f3c:	c9                   	leave  
80102f3d:	c3                   	ret    

80102f3e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f3e:	f3 0f 1e fb          	endbr32 
80102f42:	55                   	push   %ebp
80102f43:	89 e5                	mov    %esp,%ebp
80102f45:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102f48:	83 ec 08             	sub    $0x8,%esp
80102f4b:	68 71 ab 10 80       	push   $0x8010ab71
80102f50:	68 20 54 19 80       	push   $0x80195420
80102f55:	e8 22 1e 00 00       	call   80104d7c <initlock>
80102f5a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102f5d:	83 ec 08             	sub    $0x8,%esp
80102f60:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102f63:	50                   	push   %eax
80102f64:	ff 75 08             	pushl  0x8(%ebp)
80102f67:	e8 c0 e4 ff ff       	call   8010142c <readsb>
80102f6c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f72:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102f77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f7a:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f82:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102f87:	e8 bf 01 00 00       	call   8010314b <recover_from_log>
}
80102f8c:	90                   	nop
80102f8d:	c9                   	leave  
80102f8e:	c3                   	ret    

80102f8f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102f8f:	f3 0f 1e fb          	endbr32 
80102f93:	55                   	push   %ebp
80102f94:	89 e5                	mov    %esp,%ebp
80102f96:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102f99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fa0:	e9 95 00 00 00       	jmp    8010303a <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102fa5:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80102fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fae:	01 d0                	add    %edx,%eax
80102fb0:	83 c0 01             	add    $0x1,%eax
80102fb3:	89 c2                	mov    %eax,%edx
80102fb5:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fba:	83 ec 08             	sub    $0x8,%esp
80102fbd:	52                   	push   %edx
80102fbe:	50                   	push   %eax
80102fbf:	e8 45 d2 ff ff       	call   80100209 <bread>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fcd:	83 c0 10             	add    $0x10,%eax
80102fd0:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80102fd7:	89 c2                	mov    %eax,%edx
80102fd9:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fde:	83 ec 08             	sub    $0x8,%esp
80102fe1:	52                   	push   %edx
80102fe2:	50                   	push   %eax
80102fe3:	e8 21 d2 ff ff       	call   80100209 <bread>
80102fe8:	83 c4 10             	add    $0x10,%esp
80102feb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ff1:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ff7:	83 c0 5c             	add    $0x5c,%eax
80102ffa:	83 ec 04             	sub    $0x4,%esp
80102ffd:	68 00 02 00 00       	push   $0x200
80103002:	52                   	push   %edx
80103003:	50                   	push   %eax
80103004:	e8 ef 20 00 00       	call   801050f8 <memmove>
80103009:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010300c:	83 ec 0c             	sub    $0xc,%esp
8010300f:	ff 75 ec             	pushl  -0x14(%ebp)
80103012:	e8 2f d2 ff ff       	call   80100246 <bwrite>
80103017:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010301a:	83 ec 0c             	sub    $0xc,%esp
8010301d:	ff 75 f0             	pushl  -0x10(%ebp)
80103020:	e8 6e d2 ff ff       	call   80100293 <brelse>
80103025:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103028:	83 ec 0c             	sub    $0xc,%esp
8010302b:	ff 75 ec             	pushl  -0x14(%ebp)
8010302e:	e8 60 d2 ff ff       	call   80100293 <brelse>
80103033:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103036:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010303a:	a1 68 54 19 80       	mov    0x80195468,%eax
8010303f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103042:	0f 8c 5d ff ff ff    	jl     80102fa5 <install_trans+0x16>
  }
}
80103048:	90                   	nop
80103049:	90                   	nop
8010304a:	c9                   	leave  
8010304b:	c3                   	ret    

8010304c <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010304c:	f3 0f 1e fb          	endbr32 
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103056:	a1 54 54 19 80       	mov    0x80195454,%eax
8010305b:	89 c2                	mov    %eax,%edx
8010305d:	a1 64 54 19 80       	mov    0x80195464,%eax
80103062:	83 ec 08             	sub    $0x8,%esp
80103065:	52                   	push   %edx
80103066:	50                   	push   %eax
80103067:	e8 9d d1 ff ff       	call   80100209 <bread>
8010306c:	83 c4 10             	add    $0x10,%esp
8010306f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103075:	83 c0 5c             	add    $0x5c,%eax
80103078:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010307b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010307e:	8b 00                	mov    (%eax),%eax
80103080:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
80103085:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010308c:	eb 1b                	jmp    801030a9 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010308e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103094:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010309b:	83 c2 10             	add    $0x10,%edx
8010309e:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030a9:	a1 68 54 19 80       	mov    0x80195468,%eax
801030ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030b1:	7c db                	jl     8010308e <read_head+0x42>
  }
  brelse(buf);
801030b3:	83 ec 0c             	sub    $0xc,%esp
801030b6:	ff 75 f0             	pushl  -0x10(%ebp)
801030b9:	e8 d5 d1 ff ff       	call   80100293 <brelse>
801030be:	83 c4 10             	add    $0x10,%esp
}
801030c1:	90                   	nop
801030c2:	c9                   	leave  
801030c3:	c3                   	ret    

801030c4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801030c4:	f3 0f 1e fb          	endbr32 
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030ce:	a1 54 54 19 80       	mov    0x80195454,%eax
801030d3:	89 c2                	mov    %eax,%edx
801030d5:	a1 64 54 19 80       	mov    0x80195464,%eax
801030da:	83 ec 08             	sub    $0x8,%esp
801030dd:	52                   	push   %edx
801030de:	50                   	push   %eax
801030df:	e8 25 d1 ff ff       	call   80100209 <bread>
801030e4:	83 c4 10             	add    $0x10,%esp
801030e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801030ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030ed:	83 c0 5c             	add    $0x5c,%eax
801030f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801030f3:	8b 15 68 54 19 80    	mov    0x80195468,%edx
801030f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030fc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801030fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103105:	eb 1b                	jmp    80103122 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310a:	83 c0 10             	add    $0x10,%eax
8010310d:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103114:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010311a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010311e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103122:	a1 68 54 19 80       	mov    0x80195468,%eax
80103127:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010312a:	7c db                	jl     80103107 <write_head+0x43>
  }
  bwrite(buf);
8010312c:	83 ec 0c             	sub    $0xc,%esp
8010312f:	ff 75 f0             	pushl  -0x10(%ebp)
80103132:	e8 0f d1 ff ff       	call   80100246 <bwrite>
80103137:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010313a:	83 ec 0c             	sub    $0xc,%esp
8010313d:	ff 75 f0             	pushl  -0x10(%ebp)
80103140:	e8 4e d1 ff ff       	call   80100293 <brelse>
80103145:	83 c4 10             	add    $0x10,%esp
}
80103148:	90                   	nop
80103149:	c9                   	leave  
8010314a:	c3                   	ret    

8010314b <recover_from_log>:

static void
recover_from_log(void)
{
8010314b:	f3 0f 1e fb          	endbr32 
8010314f:	55                   	push   %ebp
80103150:	89 e5                	mov    %esp,%ebp
80103152:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103155:	e8 f2 fe ff ff       	call   8010304c <read_head>
  install_trans(); // if committed, copy from log to disk
8010315a:	e8 30 fe ff ff       	call   80102f8f <install_trans>
  log.lh.n = 0;
8010315f:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
80103166:	00 00 00 
  write_head(); // clear the log
80103169:	e8 56 ff ff ff       	call   801030c4 <write_head>
}
8010316e:	90                   	nop
8010316f:	c9                   	leave  
80103170:	c3                   	ret    

80103171 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103171:	f3 0f 1e fb          	endbr32 
80103175:	55                   	push   %ebp
80103176:	89 e5                	mov    %esp,%ebp
80103178:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 54 19 80       	push   $0x80195420
80103183:	e8 1a 1c 00 00       	call   80104da2 <acquire>
80103188:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010318b:	a1 60 54 19 80       	mov    0x80195460,%eax
80103190:	85 c0                	test   %eax,%eax
80103192:	74 17                	je     801031ab <begin_op+0x3a>
      sleep(&log, &log.lock);
80103194:	83 ec 08             	sub    $0x8,%esp
80103197:	68 20 54 19 80       	push   $0x80195420
8010319c:	68 20 54 19 80       	push   $0x80195420
801031a1:	e8 5b 16 00 00       	call   80104801 <sleep>
801031a6:	83 c4 10             	add    $0x10,%esp
801031a9:	eb e0                	jmp    8010318b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801031ab:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
801031b1:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031b6:	8d 50 01             	lea    0x1(%eax),%edx
801031b9:	89 d0                	mov    %edx,%eax
801031bb:	c1 e0 02             	shl    $0x2,%eax
801031be:	01 d0                	add    %edx,%eax
801031c0:	01 c0                	add    %eax,%eax
801031c2:	01 c8                	add    %ecx,%eax
801031c4:	83 f8 1e             	cmp    $0x1e,%eax
801031c7:	7e 17                	jle    801031e0 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801031c9:	83 ec 08             	sub    $0x8,%esp
801031cc:	68 20 54 19 80       	push   $0x80195420
801031d1:	68 20 54 19 80       	push   $0x80195420
801031d6:	e8 26 16 00 00       	call   80104801 <sleep>
801031db:	83 c4 10             	add    $0x10,%esp
801031de:	eb ab                	jmp    8010318b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801031e0:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031e5:	83 c0 01             	add    $0x1,%eax
801031e8:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
801031ed:	83 ec 0c             	sub    $0xc,%esp
801031f0:	68 20 54 19 80       	push   $0x80195420
801031f5:	e8 1a 1c 00 00       	call   80104e14 <release>
801031fa:	83 c4 10             	add    $0x10,%esp
      break;
801031fd:	90                   	nop
    }
  }
}
801031fe:	90                   	nop
801031ff:	c9                   	leave  
80103200:	c3                   	ret    

80103201 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103201:	f3 0f 1e fb          	endbr32 
80103205:	55                   	push   %ebp
80103206:	89 e5                	mov    %esp,%ebp
80103208:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010320b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103212:	83 ec 0c             	sub    $0xc,%esp
80103215:	68 20 54 19 80       	push   $0x80195420
8010321a:	e8 83 1b 00 00       	call   80104da2 <acquire>
8010321f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103222:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103227:	83 e8 01             	sub    $0x1,%eax
8010322a:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010322f:	a1 60 54 19 80       	mov    0x80195460,%eax
80103234:	85 c0                	test   %eax,%eax
80103236:	74 0d                	je     80103245 <end_op+0x44>
    panic("log.committing");
80103238:	83 ec 0c             	sub    $0xc,%esp
8010323b:	68 75 ab 10 80       	push   $0x8010ab75
80103240:	e8 80 d3 ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
80103245:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010324a:	85 c0                	test   %eax,%eax
8010324c:	75 13                	jne    80103261 <end_op+0x60>
    do_commit = 1;
8010324e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103255:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
8010325c:	00 00 00 
8010325f:	eb 10                	jmp    80103271 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103261:	83 ec 0c             	sub    $0xc,%esp
80103264:	68 20 54 19 80       	push   $0x80195420
80103269:	e8 85 16 00 00       	call   801048f3 <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 20 54 19 80       	push   $0x80195420
80103279:	e8 96 1b 00 00       	call   80104e14 <release>
8010327e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103281:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103285:	74 3f                	je     801032c6 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103287:	e8 fa 00 00 00       	call   80103386 <commit>
    acquire(&log.lock);
8010328c:	83 ec 0c             	sub    $0xc,%esp
8010328f:	68 20 54 19 80       	push   $0x80195420
80103294:	e8 09 1b 00 00       	call   80104da2 <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 20 54 19 80       	push   $0x80195420
801032ae:	e8 40 16 00 00       	call   801048f3 <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 20 54 19 80       	push   $0x80195420
801032be:	e8 51 1b 00 00       	call   80104e14 <release>
801032c3:	83 c4 10             	add    $0x10,%esp
  }
}
801032c6:	90                   	nop
801032c7:	c9                   	leave  
801032c8:	c3                   	ret    

801032c9 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801032c9:	f3 0f 1e fb          	endbr32 
801032cd:	55                   	push   %ebp
801032ce:	89 e5                	mov    %esp,%ebp
801032d0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032da:	e9 95 00 00 00       	jmp    80103374 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801032df:	8b 15 54 54 19 80    	mov    0x80195454,%edx
801032e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e8:	01 d0                	add    %edx,%eax
801032ea:	83 c0 01             	add    $0x1,%eax
801032ed:	89 c2                	mov    %eax,%edx
801032ef:	a1 64 54 19 80       	mov    0x80195464,%eax
801032f4:	83 ec 08             	sub    $0x8,%esp
801032f7:	52                   	push   %edx
801032f8:	50                   	push   %eax
801032f9:	e8 0b cf ff ff       	call   80100209 <bread>
801032fe:	83 c4 10             	add    $0x10,%esp
80103301:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103307:	83 c0 10             	add    $0x10,%eax
8010330a:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	a1 64 54 19 80       	mov    0x80195464,%eax
80103318:	83 ec 08             	sub    $0x8,%esp
8010331b:	52                   	push   %edx
8010331c:	50                   	push   %eax
8010331d:	e8 e7 ce ff ff       	call   80100209 <bread>
80103322:	83 c4 10             	add    $0x10,%esp
80103325:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103328:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010332b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010332e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103331:	83 c0 5c             	add    $0x5c,%eax
80103334:	83 ec 04             	sub    $0x4,%esp
80103337:	68 00 02 00 00       	push   $0x200
8010333c:	52                   	push   %edx
8010333d:	50                   	push   %eax
8010333e:	e8 b5 1d 00 00       	call   801050f8 <memmove>
80103343:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103346:	83 ec 0c             	sub    $0xc,%esp
80103349:	ff 75 f0             	pushl  -0x10(%ebp)
8010334c:	e8 f5 ce ff ff       	call   80100246 <bwrite>
80103351:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103354:	83 ec 0c             	sub    $0xc,%esp
80103357:	ff 75 ec             	pushl  -0x14(%ebp)
8010335a:	e8 34 cf ff ff       	call   80100293 <brelse>
8010335f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103362:	83 ec 0c             	sub    $0xc,%esp
80103365:	ff 75 f0             	pushl  -0x10(%ebp)
80103368:	e8 26 cf ff ff       	call   80100293 <brelse>
8010336d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103370:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103374:	a1 68 54 19 80       	mov    0x80195468,%eax
80103379:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010337c:	0f 8c 5d ff ff ff    	jl     801032df <write_log+0x16>
  }
}
80103382:	90                   	nop
80103383:	90                   	nop
80103384:	c9                   	leave  
80103385:	c3                   	ret    

80103386 <commit>:

static void
commit()
{
80103386:	f3 0f 1e fb          	endbr32 
8010338a:	55                   	push   %ebp
8010338b:	89 e5                	mov    %esp,%ebp
8010338d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103390:	a1 68 54 19 80       	mov    0x80195468,%eax
80103395:	85 c0                	test   %eax,%eax
80103397:	7e 1e                	jle    801033b7 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103399:	e8 2b ff ff ff       	call   801032c9 <write_log>
    write_head();    // Write header to disk -- the real commit
8010339e:	e8 21 fd ff ff       	call   801030c4 <write_head>
    install_trans(); // Now install writes to home locations
801033a3:	e8 e7 fb ff ff       	call   80102f8f <install_trans>
    log.lh.n = 0;
801033a8:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801033af:	00 00 00 
    write_head();    // Erase the transaction from the log
801033b2:	e8 0d fd ff ff       	call   801030c4 <write_head>
  }
}
801033b7:	90                   	nop
801033b8:	c9                   	leave  
801033b9:	c3                   	ret    

801033ba <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801033ba:	f3 0f 1e fb          	endbr32 
801033be:	55                   	push   %ebp
801033bf:	89 e5                	mov    %esp,%ebp
801033c1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801033c4:	a1 68 54 19 80       	mov    0x80195468,%eax
801033c9:	83 f8 1d             	cmp    $0x1d,%eax
801033cc:	7f 12                	jg     801033e0 <log_write+0x26>
801033ce:	a1 68 54 19 80       	mov    0x80195468,%eax
801033d3:	8b 15 58 54 19 80    	mov    0x80195458,%edx
801033d9:	83 ea 01             	sub    $0x1,%edx
801033dc:	39 d0                	cmp    %edx,%eax
801033de:	7c 0d                	jl     801033ed <log_write+0x33>
    panic("too big a transaction");
801033e0:	83 ec 0c             	sub    $0xc,%esp
801033e3:	68 84 ab 10 80       	push   $0x8010ab84
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 9a ab 10 80       	push   $0x8010ab9a
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 20 54 19 80       	push   $0x80195420
8010340b:	e8 92 19 00 00       	call   80104da2 <acquire>
80103410:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103413:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010341a:	eb 1d                	jmp    80103439 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010341c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341f:	83 c0 10             	add    $0x10,%eax
80103422:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103429:	89 c2                	mov    %eax,%edx
8010342b:	8b 45 08             	mov    0x8(%ebp),%eax
8010342e:	8b 40 08             	mov    0x8(%eax),%eax
80103431:	39 c2                	cmp    %eax,%edx
80103433:	74 10                	je     80103445 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103435:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103439:	a1 68 54 19 80       	mov    0x80195468,%eax
8010343e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103441:	7c d9                	jl     8010341c <log_write+0x62>
80103443:	eb 01                	jmp    80103446 <log_write+0x8c>
      break;
80103445:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103446:	8b 45 08             	mov    0x8(%ebp),%eax
80103449:	8b 40 08             	mov    0x8(%eax),%eax
8010344c:	89 c2                	mov    %eax,%edx
8010344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103451:	83 c0 10             	add    $0x10,%eax
80103454:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
8010345b:	a1 68 54 19 80       	mov    0x80195468,%eax
80103460:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103463:	75 0d                	jne    80103472 <log_write+0xb8>
    log.lh.n++;
80103465:	a1 68 54 19 80       	mov    0x80195468,%eax
8010346a:	83 c0 01             	add    $0x1,%eax
8010346d:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
80103472:	8b 45 08             	mov    0x8(%ebp),%eax
80103475:	8b 00                	mov    (%eax),%eax
80103477:	83 c8 04             	or     $0x4,%eax
8010347a:	89 c2                	mov    %eax,%edx
8010347c:	8b 45 08             	mov    0x8(%ebp),%eax
8010347f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	68 20 54 19 80       	push   $0x80195420
80103489:	e8 86 19 00 00       	call   80104e14 <release>
8010348e:	83 c4 10             	add    $0x10,%esp
}
80103491:	90                   	nop
80103492:	c9                   	leave  
80103493:	c3                   	ret    

80103494 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103494:	55                   	push   %ebp
80103495:	89 e5                	mov    %esp,%ebp
80103497:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010349a:	8b 55 08             	mov    0x8(%ebp),%edx
8010349d:	8b 45 0c             	mov    0xc(%ebp),%eax
801034a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801034a3:	f0 87 02             	lock xchg %eax,(%edx)
801034a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801034a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801034ac:	c9                   	leave  
801034ad:	c3                   	ret    

801034ae <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801034ae:	f3 0f 1e fb          	endbr32 
801034b2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801034b6:	83 e4 f0             	and    $0xfffffff0,%esp
801034b9:	ff 71 fc             	pushl  -0x4(%ecx)
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	51                   	push   %ecx
801034c0:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801034c3:	e8 58 51 00 00       	call   80108620 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 90 19 80       	push   $0x80199000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 1b 47 00 00       	call   80107bfd <kvmalloc>
  mpinit_uefi();
801034e2:	e8 f2 4e 00 00       	call   801083d9 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 93 41 00 00       	call   80107684 <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 08 35 00 00       	call   80106a0d <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 17 30 00 00       	call   80106526 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 07 73 00 00       	call   8010a825 <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 56 53 00 00       	call   80108893 <pci_init>
  arp_scan();
8010353d:	e8 cf 60 00 00       	call   80109611 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103542:	e8 d6 07 00 00       	call   80103d1d <userinit>

  mpmain();        // finish this processor's setup
80103547:	e8 1e 00 00 00       	call   8010356a <mpmain>

8010354c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010354c:	f3 0f 1e fb          	endbr32 
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103556:	e8 be 46 00 00       	call   80107c19 <switchkvm>
  seginit();
8010355b:	e8 24 41 00 00       	call   80107684 <seginit>
  lapicinit();
80103560:	e8 77 f5 ff ff       	call   80102adc <lapicinit>
  mpmain();
80103565:	e8 00 00 00 00       	call   8010356a <mpmain>

8010356a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010356a:	f3 0f 1e fb          	endbr32 
8010356e:	55                   	push   %ebp
8010356f:	89 e5                	mov    %esp,%ebp
80103571:	53                   	push   %ebx
80103572:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103575:	e8 94 05 00 00       	call   80103b0e <cpuid>
8010357a:	89 c3                	mov    %eax,%ebx
8010357c:	e8 8d 05 00 00       	call   80103b0e <cpuid>
80103581:	83 ec 04             	sub    $0x4,%esp
80103584:	53                   	push   %ebx
80103585:	50                   	push   %eax
80103586:	68 b5 ab 10 80       	push   $0x8010abb5
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 08 31 00 00       	call   801066a0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 0d 0d 00 00       	call   801042c2 <scheduler>

801035b5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801035b5:	f3 0f 1e fb          	endbr32 
801035b9:	55                   	push   %ebp
801035ba:	89 e5                	mov    %esp,%ebp
801035bc:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801035bf:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801035c6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801035cb:	83 ec 04             	sub    $0x4,%esp
801035ce:	50                   	push   %eax
801035cf:	68 38 f5 10 80       	push   $0x8010f538
801035d4:	ff 75 f0             	pushl  -0x10(%ebp)
801035d7:	e8 1c 1b 00 00       	call   801050f8 <memmove>
801035dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035df:	c7 45 f4 c0 85 19 80 	movl   $0x801985c0,-0xc(%ebp)
801035e6:	eb 79                	jmp    80103661 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
801035e8:	e8 40 05 00 00       	call   80103b2d <mycpu>
801035ed:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035f0:	74 67                	je     80103659 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801035f2:	e8 9b f2 ff ff       	call   80102892 <kalloc>
801035f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035fd:	83 e8 04             	sub    $0x4,%eax
80103600:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103603:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103609:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010360b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010360e:	83 e8 08             	sub    $0x8,%eax
80103611:	c7 00 4c 35 10 80    	movl   $0x8010354c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103617:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010361c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103625:	83 e8 0c             	sub    $0xc,%eax
80103628:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
8010362a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010362d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103636:	0f b6 00             	movzbl (%eax),%eax
80103639:	0f b6 c0             	movzbl %al,%eax
8010363c:	83 ec 08             	sub    $0x8,%esp
8010363f:	52                   	push   %edx
80103640:	50                   	push   %eax
80103641:	e8 08 f6 ff ff       	call   80102c4e <lapicstartap>
80103646:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103649:	90                   	nop
8010364a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010364d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103653:	85 c0                	test   %eax,%eax
80103655:	74 f3                	je     8010364a <startothers+0x95>
80103657:	eb 01                	jmp    8010365a <startothers+0xa5>
      continue;
80103659:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
8010365a:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
80103661:	a1 90 88 19 80       	mov    0x80198890,%eax
80103666:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
8010366c:	05 c0 85 19 80       	add    $0x801985c0,%eax
80103671:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103674:	0f 82 6e ff ff ff    	jb     801035e8 <startothers+0x33>
      ;
  }
}
8010367a:	90                   	nop
8010367b:	90                   	nop
8010367c:	c9                   	leave  
8010367d:	c3                   	ret    

8010367e <outb>:
{
8010367e:	55                   	push   %ebp
8010367f:	89 e5                	mov    %esp,%ebp
80103681:	83 ec 08             	sub    $0x8,%esp
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 55 0c             	mov    0xc(%ebp),%edx
8010368a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010368e:	89 d0                	mov    %edx,%eax
80103690:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103693:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103697:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010369b:	ee                   	out    %al,(%dx)
}
8010369c:	90                   	nop
8010369d:	c9                   	leave  
8010369e:	c3                   	ret    

8010369f <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010369f:	f3 0f 1e fb          	endbr32 
801036a3:	55                   	push   %ebp
801036a4:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801036a6:	68 ff 00 00 00       	push   $0xff
801036ab:	6a 21                	push   $0x21
801036ad:	e8 cc ff ff ff       	call   8010367e <outb>
801036b2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801036b5:	68 ff 00 00 00       	push   $0xff
801036ba:	68 a1 00 00 00       	push   $0xa1
801036bf:	e8 ba ff ff ff       	call   8010367e <outb>
801036c4:	83 c4 08             	add    $0x8,%esp
}
801036c7:	90                   	nop
801036c8:	c9                   	leave  
801036c9:	c3                   	ret    

801036ca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801036ca:	f3 0f 1e fb          	endbr32 
801036ce:	55                   	push   %ebp
801036cf:	89 e5                	mov    %esp,%ebp
801036d1:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801036d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801036db:	8b 45 0c             	mov    0xc(%ebp),%eax
801036de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801036e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801036e7:	8b 10                	mov    (%eax),%edx
801036e9:	8b 45 08             	mov    0x8(%ebp),%eax
801036ec:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801036ee:	e8 30 d9 ff ff       	call   80101023 <filealloc>
801036f3:	8b 55 08             	mov    0x8(%ebp),%edx
801036f6:	89 02                	mov    %eax,(%edx)
801036f8:	8b 45 08             	mov    0x8(%ebp),%eax
801036fb:	8b 00                	mov    (%eax),%eax
801036fd:	85 c0                	test   %eax,%eax
801036ff:	0f 84 c8 00 00 00    	je     801037cd <pipealloc+0x103>
80103705:	e8 19 d9 ff ff       	call   80101023 <filealloc>
8010370a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010370d:	89 02                	mov    %eax,(%edx)
8010370f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103712:	8b 00                	mov    (%eax),%eax
80103714:	85 c0                	test   %eax,%eax
80103716:	0f 84 b1 00 00 00    	je     801037cd <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010371c:	e8 71 f1 ff ff       	call   80102892 <kalloc>
80103721:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103724:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103728:	0f 84 a2 00 00 00    	je     801037d0 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010372e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103731:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103738:	00 00 00 
  p->writeopen = 1;
8010373b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010373e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103745:	00 00 00 
  p->nwrite = 0;
80103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103752:	00 00 00 
  p->nread = 0;
80103755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103758:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010375f:	00 00 00 
  initlock(&p->lock, "pipe");
80103762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103765:	83 ec 08             	sub    $0x8,%esp
80103768:	68 c9 ab 10 80       	push   $0x8010abc9
8010376d:	50                   	push   %eax
8010376e:	e8 09 16 00 00       	call   80104d7c <initlock>
80103773:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103776:	8b 45 08             	mov    0x8(%ebp),%eax
80103779:	8b 00                	mov    (%eax),%eax
8010377b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103781:	8b 45 08             	mov    0x8(%ebp),%eax
80103784:	8b 00                	mov    (%eax),%eax
80103786:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010378a:	8b 45 08             	mov    0x8(%ebp),%eax
8010378d:	8b 00                	mov    (%eax),%eax
8010378f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103793:	8b 45 08             	mov    0x8(%ebp),%eax
80103796:	8b 00                	mov    (%eax),%eax
80103798:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010379b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010379e:	8b 45 0c             	mov    0xc(%ebp),%eax
801037a1:	8b 00                	mov    (%eax),%eax
801037a3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801037a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801037ac:	8b 00                	mov    (%eax),%eax
801037ae:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801037b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b5:	8b 00                	mov    (%eax),%eax
801037b7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801037bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801037be:	8b 00                	mov    (%eax),%eax
801037c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037c3:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801037c6:	b8 00 00 00 00       	mov    $0x0,%eax
801037cb:	eb 51                	jmp    8010381e <pipealloc+0x154>
    goto bad;
801037cd:	90                   	nop
801037ce:	eb 01                	jmp    801037d1 <pipealloc+0x107>
    goto bad;
801037d0:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801037d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037d5:	74 0e                	je     801037e5 <pipealloc+0x11b>
    kfree((char*)p);
801037d7:	83 ec 0c             	sub    $0xc,%esp
801037da:	ff 75 f4             	pushl  -0xc(%ebp)
801037dd:	e8 12 f0 ff ff       	call   801027f4 <kfree>
801037e2:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801037e5:	8b 45 08             	mov    0x8(%ebp),%eax
801037e8:	8b 00                	mov    (%eax),%eax
801037ea:	85 c0                	test   %eax,%eax
801037ec:	74 11                	je     801037ff <pipealloc+0x135>
    fileclose(*f0);
801037ee:	8b 45 08             	mov    0x8(%ebp),%eax
801037f1:	8b 00                	mov    (%eax),%eax
801037f3:	83 ec 0c             	sub    $0xc,%esp
801037f6:	50                   	push   %eax
801037f7:	e8 ed d8 ff ff       	call   801010e9 <fileclose>
801037fc:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801037ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103802:	8b 00                	mov    (%eax),%eax
80103804:	85 c0                	test   %eax,%eax
80103806:	74 11                	je     80103819 <pipealloc+0x14f>
    fileclose(*f1);
80103808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380b:	8b 00                	mov    (%eax),%eax
8010380d:	83 ec 0c             	sub    $0xc,%esp
80103810:	50                   	push   %eax
80103811:	e8 d3 d8 ff ff       	call   801010e9 <fileclose>
80103816:	83 c4 10             	add    $0x10,%esp
  return -1;
80103819:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010381e:	c9                   	leave  
8010381f:	c3                   	ret    

80103820 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103820:	f3 0f 1e fb          	endbr32 
80103824:	55                   	push   %ebp
80103825:	89 e5                	mov    %esp,%ebp
80103827:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010382a:	8b 45 08             	mov    0x8(%ebp),%eax
8010382d:	83 ec 0c             	sub    $0xc,%esp
80103830:	50                   	push   %eax
80103831:	e8 6c 15 00 00       	call   80104da2 <acquire>
80103836:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103839:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010383d:	74 23                	je     80103862 <pipeclose+0x42>
    p->writeopen = 0;
8010383f:	8b 45 08             	mov    0x8(%ebp),%eax
80103842:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103849:	00 00 00 
    wakeup(&p->nread);
8010384c:	8b 45 08             	mov    0x8(%ebp),%eax
8010384f:	05 34 02 00 00       	add    $0x234,%eax
80103854:	83 ec 0c             	sub    $0xc,%esp
80103857:	50                   	push   %eax
80103858:	e8 96 10 00 00       	call   801048f3 <wakeup>
8010385d:	83 c4 10             	add    $0x10,%esp
80103860:	eb 21                	jmp    80103883 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103862:	8b 45 08             	mov    0x8(%ebp),%eax
80103865:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010386c:	00 00 00 
    wakeup(&p->nwrite);
8010386f:	8b 45 08             	mov    0x8(%ebp),%eax
80103872:	05 38 02 00 00       	add    $0x238,%eax
80103877:	83 ec 0c             	sub    $0xc,%esp
8010387a:	50                   	push   %eax
8010387b:	e8 73 10 00 00       	call   801048f3 <wakeup>
80103880:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103883:	8b 45 08             	mov    0x8(%ebp),%eax
80103886:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010388c:	85 c0                	test   %eax,%eax
8010388e:	75 2c                	jne    801038bc <pipeclose+0x9c>
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103899:	85 c0                	test   %eax,%eax
8010389b:	75 1f                	jne    801038bc <pipeclose+0x9c>
    release(&p->lock);
8010389d:	8b 45 08             	mov    0x8(%ebp),%eax
801038a0:	83 ec 0c             	sub    $0xc,%esp
801038a3:	50                   	push   %eax
801038a4:	e8 6b 15 00 00       	call   80104e14 <release>
801038a9:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801038ac:	83 ec 0c             	sub    $0xc,%esp
801038af:	ff 75 08             	pushl  0x8(%ebp)
801038b2:	e8 3d ef ff ff       	call   801027f4 <kfree>
801038b7:	83 c4 10             	add    $0x10,%esp
801038ba:	eb 10                	jmp    801038cc <pipeclose+0xac>
  } else
    release(&p->lock);
801038bc:	8b 45 08             	mov    0x8(%ebp),%eax
801038bf:	83 ec 0c             	sub    $0xc,%esp
801038c2:	50                   	push   %eax
801038c3:	e8 4c 15 00 00       	call   80104e14 <release>
801038c8:	83 c4 10             	add    $0x10,%esp
}
801038cb:	90                   	nop
801038cc:	90                   	nop
801038cd:	c9                   	leave  
801038ce:	c3                   	ret    

801038cf <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801038cf:	f3 0f 1e fb          	endbr32 
801038d3:	55                   	push   %ebp
801038d4:	89 e5                	mov    %esp,%ebp
801038d6:	53                   	push   %ebx
801038d7:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801038da:	8b 45 08             	mov    0x8(%ebp),%eax
801038dd:	83 ec 0c             	sub    $0xc,%esp
801038e0:	50                   	push   %eax
801038e1:	e8 bc 14 00 00       	call   80104da2 <acquire>
801038e6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801038e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038f0:	e9 ad 00 00 00       	jmp    801039a2 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801038f5:	8b 45 08             	mov    0x8(%ebp),%eax
801038f8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038fe:	85 c0                	test   %eax,%eax
80103900:	74 0c                	je     8010390e <pipewrite+0x3f>
80103902:	e8 a2 02 00 00       	call   80103ba9 <myproc>
80103907:	8b 40 24             	mov    0x24(%eax),%eax
8010390a:	85 c0                	test   %eax,%eax
8010390c:	74 19                	je     80103927 <pipewrite+0x58>
        release(&p->lock);
8010390e:	8b 45 08             	mov    0x8(%ebp),%eax
80103911:	83 ec 0c             	sub    $0xc,%esp
80103914:	50                   	push   %eax
80103915:	e8 fa 14 00 00       	call   80104e14 <release>
8010391a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010391d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103922:	e9 a9 00 00 00       	jmp    801039d0 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	05 34 02 00 00       	add    $0x234,%eax
8010392f:	83 ec 0c             	sub    $0xc,%esp
80103932:	50                   	push   %eax
80103933:	e8 bb 0f 00 00       	call   801048f3 <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 b0 0e 00 00       	call   80104801 <sleep>
80103951:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010395d:	8b 45 08             	mov    0x8(%ebp),%eax
80103960:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103966:	05 00 02 00 00       	add    $0x200,%eax
8010396b:	39 c2                	cmp    %eax,%edx
8010396d:	74 86                	je     801038f5 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010396f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103972:	8b 45 0c             	mov    0xc(%ebp),%eax
80103975:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103978:	8b 45 08             	mov    0x8(%ebp),%eax
8010397b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103981:	8d 48 01             	lea    0x1(%eax),%ecx
80103984:	8b 55 08             	mov    0x8(%ebp),%edx
80103987:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010398d:	25 ff 01 00 00       	and    $0x1ff,%eax
80103992:	89 c1                	mov    %eax,%ecx
80103994:	0f b6 13             	movzbl (%ebx),%edx
80103997:	8b 45 08             	mov    0x8(%ebp),%eax
8010399a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010399e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801039a8:	7c aa                	jl     80103954 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801039aa:	8b 45 08             	mov    0x8(%ebp),%eax
801039ad:	05 34 02 00 00       	add    $0x234,%eax
801039b2:	83 ec 0c             	sub    $0xc,%esp
801039b5:	50                   	push   %eax
801039b6:	e8 38 0f 00 00       	call   801048f3 <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 4a 14 00 00       	call   80104e14 <release>
801039ca:	83 c4 10             	add    $0x10,%esp
  return n;
801039cd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801039d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039d3:	c9                   	leave  
801039d4:	c3                   	ret    

801039d5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801039d5:	f3 0f 1e fb          	endbr32 
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801039df:	8b 45 08             	mov    0x8(%ebp),%eax
801039e2:	83 ec 0c             	sub    $0xc,%esp
801039e5:	50                   	push   %eax
801039e6:	e8 b7 13 00 00       	call   80104da2 <acquire>
801039eb:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039ee:	eb 3e                	jmp    80103a2e <piperead+0x59>
    if(myproc()->killed){
801039f0:	e8 b4 01 00 00       	call   80103ba9 <myproc>
801039f5:	8b 40 24             	mov    0x24(%eax),%eax
801039f8:	85 c0                	test   %eax,%eax
801039fa:	74 19                	je     80103a15 <piperead+0x40>
      release(&p->lock);
801039fc:	8b 45 08             	mov    0x8(%ebp),%eax
801039ff:	83 ec 0c             	sub    $0xc,%esp
80103a02:	50                   	push   %eax
80103a03:	e8 0c 14 00 00       	call   80104e14 <release>
80103a08:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a10:	e9 be 00 00 00       	jmp    80103ad3 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a15:	8b 45 08             	mov    0x8(%ebp),%eax
80103a18:	8b 55 08             	mov    0x8(%ebp),%edx
80103a1b:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a21:	83 ec 08             	sub    $0x8,%esp
80103a24:	50                   	push   %eax
80103a25:	52                   	push   %edx
80103a26:	e8 d6 0d 00 00       	call   80104801 <sleep>
80103a2b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a31:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a37:	8b 45 08             	mov    0x8(%ebp),%eax
80103a3a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a40:	39 c2                	cmp    %eax,%edx
80103a42:	75 0d                	jne    80103a51 <piperead+0x7c>
80103a44:	8b 45 08             	mov    0x8(%ebp),%eax
80103a47:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103a4d:	85 c0                	test   %eax,%eax
80103a4f:	75 9f                	jne    801039f0 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a58:	eb 48                	jmp    80103aa2 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a63:	8b 45 08             	mov    0x8(%ebp),%eax
80103a66:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a6c:	39 c2                	cmp    %eax,%edx
80103a6e:	74 3c                	je     80103aac <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a70:	8b 45 08             	mov    0x8(%ebp),%eax
80103a73:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103a79:	8d 48 01             	lea    0x1(%eax),%ecx
80103a7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a7f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103a85:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a8a:	89 c1                	mov    %eax,%ecx
80103a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a92:	01 c2                	add    %eax,%edx
80103a94:	8b 45 08             	mov    0x8(%ebp),%eax
80103a97:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103a9c:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa5:	3b 45 10             	cmp    0x10(%ebp),%eax
80103aa8:	7c b0                	jl     80103a5a <piperead+0x85>
80103aaa:	eb 01                	jmp    80103aad <piperead+0xd8>
      break;
80103aac:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103aad:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab0:	05 38 02 00 00       	add    $0x238,%eax
80103ab5:	83 ec 0c             	sub    $0xc,%esp
80103ab8:	50                   	push   %eax
80103ab9:	e8 35 0e 00 00       	call   801048f3 <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 47 13 00 00       	call   80104e14 <release>
80103acd:	83 c4 10             	add    $0x10,%esp
  return i;
80103ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ad3:	c9                   	leave  
80103ad4:	c3                   	ret    

80103ad5 <readeflags>:
{
80103ad5:	55                   	push   %ebp
80103ad6:	89 e5                	mov    %esp,%ebp
80103ad8:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103adb:	9c                   	pushf  
80103adc:	58                   	pop    %eax
80103add:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103ae3:	c9                   	leave  
80103ae4:	c3                   	ret    

80103ae5 <sti>:
{
80103ae5:	55                   	push   %ebp
80103ae6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103ae8:	fb                   	sti    
}
80103ae9:	90                   	nop
80103aea:	5d                   	pop    %ebp
80103aeb:	c3                   	ret    

80103aec <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103aec:	f3 0f 1e fb          	endbr32 
80103af0:	55                   	push   %ebp
80103af1:	89 e5                	mov    %esp,%ebp
80103af3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	68 d0 ab 10 80       	push   $0x8010abd0
80103afe:	68 00 55 19 80       	push   $0x80195500
80103b03:	e8 74 12 00 00       	call   80104d7c <initlock>
80103b08:	83 c4 10             	add    $0x10,%esp
}
80103b0b:	90                   	nop
80103b0c:	c9                   	leave  
80103b0d:	c3                   	ret    

80103b0e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b0e:	f3 0f 1e fb          	endbr32 
80103b12:	55                   	push   %ebp
80103b13:	89 e5                	mov    %esp,%ebp
80103b15:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b18:	e8 10 00 00 00       	call   80103b2d <mycpu>
80103b1d:	2d c0 85 19 80       	sub    $0x801985c0,%eax
80103b22:	c1 f8 02             	sar    $0x2,%eax
80103b25:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
80103b2b:	c9                   	leave  
80103b2c:	c3                   	ret    

80103b2d <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b2d:	f3 0f 1e fb          	endbr32 
80103b31:	55                   	push   %ebp
80103b32:	89 e5                	mov    %esp,%ebp
80103b34:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b37:	e8 99 ff ff ff       	call   80103ad5 <readeflags>
80103b3c:	25 00 02 00 00       	and    $0x200,%eax
80103b41:	85 c0                	test   %eax,%eax
80103b43:	74 0d                	je     80103b52 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103b45:	83 ec 0c             	sub    $0xc,%esp
80103b48:	68 d8 ab 10 80       	push   $0x8010abd8
80103b4d:	e8 73 ca ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
80103b52:	e8 a8 f0 ff ff       	call   80102bff <lapicid>
80103b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103b5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b61:	eb 2d                	jmp    80103b90 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b66:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103b6c:	05 c0 85 19 80       	add    $0x801985c0,%eax
80103b71:	0f b6 00             	movzbl (%eax),%eax
80103b74:	0f b6 c0             	movzbl %al,%eax
80103b77:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b7a:	75 10                	jne    80103b8c <mycpu+0x5f>
      return &cpus[i];
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103b85:	05 c0 85 19 80       	add    $0x801985c0,%eax
80103b8a:	eb 1b                	jmp    80103ba7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b90:	a1 90 88 19 80       	mov    0x80198890,%eax
80103b95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b98:	7c c9                	jl     80103b63 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b9a:	83 ec 0c             	sub    $0xc,%esp
80103b9d:	68 fe ab 10 80       	push   $0x8010abfe
80103ba2:	e8 1e ca ff ff       	call   801005c5 <panic>
}
80103ba7:	c9                   	leave  
80103ba8:	c3                   	ret    

80103ba9 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103ba9:	f3 0f 1e fb          	endbr32 
80103bad:	55                   	push   %ebp
80103bae:	89 e5                	mov    %esp,%ebp
80103bb0:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103bb3:	e8 66 13 00 00       	call   80104f1e <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 9e 13 00 00       	call   80104f6f <popcli>
  return p;
80103bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bd4:	c9                   	leave  
80103bd5:	c3                   	ret    

80103bd6 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103bd6:	f3 0f 1e fb          	endbr32 
80103bda:	55                   	push   %ebp
80103bdb:	89 e5                	mov    %esp,%ebp
80103bdd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103be0:	83 ec 0c             	sub    $0xc,%esp
80103be3:	68 00 55 19 80       	push   $0x80195500
80103be8:	e8 b5 11 00 00       	call   80104da2 <acquire>
80103bed:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103bf0:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103bf7:	eb 11                	jmp    80103c0a <allocproc+0x34>
    if(p->state == UNUSED){
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 0c             	mov    0xc(%eax),%eax
80103bff:	85 c0                	test   %eax,%eax
80103c01:	74 2a                	je     80103c2d <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c03:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80103c0a:	81 7d f4 34 7d 19 80 	cmpl   $0x80197d34,-0xc(%ebp)
80103c11:	72 e6                	jb     80103bf9 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c13:	83 ec 0c             	sub    $0xc,%esp
80103c16:	68 00 55 19 80       	push   $0x80195500
80103c1b:	e8 f4 11 00 00       	call   80104e14 <release>
80103c20:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c23:	b8 00 00 00 00       	mov    $0x0,%eax
80103c28:	e9 ee 00 00 00       	jmp    80103d1b <allocproc+0x145>
      goto found;
80103c2d:	90                   	nop
80103c2e:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80103c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c35:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c3c:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c41:	8d 50 01             	lea    0x1(%eax),%edx
80103c44:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103c4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c4d:	89 42 10             	mov    %eax,0x10(%edx)
  
  release(&ptable.lock);
80103c50:	83 ec 0c             	sub    $0xc,%esp
80103c53:	68 00 55 19 80       	push   $0x80195500
80103c58:	e8 b7 11 00 00       	call   80104e14 <release>
80103c5d:	83 c4 10             	add    $0x10,%esp
  
  p->priority = 3; //Q3에서 시작
80103c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c63:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  memset(p->ticks, 0, sizeof(p->ticks)); //초기화
80103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6d:	83 e8 80             	sub    $0xffffff80,%eax
80103c70:	83 ec 04             	sub    $0x4,%esp
80103c73:	6a 10                	push   $0x10
80103c75:	6a 00                	push   $0x0
80103c77:	50                   	push   %eax
80103c78:	e8 b4 13 00 00       	call   80105031 <memset>
80103c7d:	83 c4 10             	add    $0x10,%esp
  memset(p->wait_ticks, 0, sizeof(p->wait_ticks)); // 초기화
80103c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c83:	05 90 00 00 00       	add    $0x90,%eax
80103c88:	83 ec 04             	sub    $0x4,%esp
80103c8b:	6a 10                	push   $0x10
80103c8d:	6a 00                	push   $0x0
80103c8f:	50                   	push   %eax
80103c90:	e8 9c 13 00 00       	call   80105031 <memset>
80103c95:	83 c4 10             	add    $0x10,%esp

  


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103c98:	e8 f5 eb ff ff       	call   80102892 <kalloc>
80103c9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ca0:	89 42 08             	mov    %eax,0x8(%edx)
80103ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca6:	8b 40 08             	mov    0x8(%eax),%eax
80103ca9:	85 c0                	test   %eax,%eax
80103cab:	75 11                	jne    80103cbe <allocproc+0xe8>
    p->state = UNUSED;
80103cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103cb7:	b8 00 00 00 00       	mov    $0x0,%eax
80103cbc:	eb 5d                	jmp    80103d1b <allocproc+0x145>
  }
  sp = p->kstack + KSTACKSIZE;
80103cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc1:	8b 40 08             	mov    0x8(%eax),%eax
80103cc4:	05 00 10 00 00       	add    $0x1000,%eax
80103cc9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103ccc:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cd6:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103cd9:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103cdd:	ba e0 64 10 80       	mov    $0x801064e0,%edx
80103ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce5:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103ce7:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cee:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cf1:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf7:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cfa:	83 ec 04             	sub    $0x4,%esp
80103cfd:	6a 14                	push   $0x14
80103cff:	6a 00                	push   $0x0
80103d01:	50                   	push   %eax
80103d02:	e8 2a 13 00 00       	call   80105031 <memset>
80103d07:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0d:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d10:	ba b7 47 10 80       	mov    $0x801047b7,%edx
80103d15:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103d1b:	c9                   	leave  
80103d1c:	c3                   	ret    

80103d1d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103d1d:	f3 0f 1e fb          	endbr32 
80103d21:	55                   	push   %ebp
80103d22:	89 e5                	mov    %esp,%ebp
80103d24:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103d27:	e8 aa fe ff ff       	call   80103bd6 <allocproc>
80103d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d32:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103d37:	e8 d0 3d 00 00       	call   80107b0c <setupkvm>
80103d3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d3f:	89 42 04             	mov    %eax,0x4(%edx)
80103d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d45:	8b 40 04             	mov    0x4(%eax),%eax
80103d48:	85 c0                	test   %eax,%eax
80103d4a:	75 0d                	jne    80103d59 <userinit+0x3c>
    panic("userinit: out of memory?");
80103d4c:	83 ec 0c             	sub    $0xc,%esp
80103d4f:	68 0e ac 10 80       	push   $0x8010ac0e
80103d54:	e8 6c c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d59:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d61:	8b 40 04             	mov    0x4(%eax),%eax
80103d64:	83 ec 04             	sub    $0x4,%esp
80103d67:	52                   	push   %edx
80103d68:	68 0c f5 10 80       	push   $0x8010f50c
80103d6d:	50                   	push   %eax
80103d6e:	e8 66 40 00 00       	call   80107dd9 <inituvm>
80103d73:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d79:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d82:	8b 40 18             	mov    0x18(%eax),%eax
80103d85:	83 ec 04             	sub    $0x4,%esp
80103d88:	6a 4c                	push   $0x4c
80103d8a:	6a 00                	push   $0x0
80103d8c:	50                   	push   %eax
80103d8d:	e8 9f 12 00 00       	call   80105031 <memset>
80103d92:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d98:	8b 40 18             	mov    0x18(%eax),%eax
80103d9b:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da4:	8b 40 18             	mov    0x18(%eax),%eax
80103da7:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db0:	8b 50 18             	mov    0x18(%eax),%edx
80103db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db6:	8b 40 18             	mov    0x18(%eax),%eax
80103db9:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103dbd:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc4:	8b 50 18             	mov    0x18(%eax),%edx
80103dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dca:	8b 40 18             	mov    0x18(%eax),%eax
80103dcd:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103dd1:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd8:	8b 40 18             	mov    0x18(%eax),%eax
80103ddb:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de5:	8b 40 18             	mov    0x18(%eax),%eax
80103de8:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df2:	8b 40 18             	mov    0x18(%eax),%eax
80103df5:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dff:	83 c0 6c             	add    $0x6c,%eax
80103e02:	83 ec 04             	sub    $0x4,%esp
80103e05:	6a 10                	push   $0x10
80103e07:	68 27 ac 10 80       	push   $0x8010ac27
80103e0c:	50                   	push   %eax
80103e0d:	e8 3a 14 00 00       	call   8010524c <safestrcpy>
80103e12:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e15:	83 ec 0c             	sub    $0xc,%esp
80103e18:	68 30 ac 10 80       	push   $0x8010ac30
80103e1d:	e8 c5 e7 ff ff       	call   801025e7 <namei>
80103e22:	83 c4 10             	add    $0x10,%esp
80103e25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e28:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e2b:	83 ec 0c             	sub    $0xc,%esp
80103e2e:	68 00 55 19 80       	push   $0x80195500
80103e33:	e8 6a 0f 00 00       	call   80104da2 <acquire>
80103e38:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e45:	83 ec 0c             	sub    $0xc,%esp
80103e48:	68 00 55 19 80       	push   $0x80195500
80103e4d:	e8 c2 0f 00 00       	call   80104e14 <release>
80103e52:	83 c4 10             	add    $0x10,%esp
}
80103e55:	90                   	nop
80103e56:	c9                   	leave  
80103e57:	c3                   	ret    

80103e58 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e58:	f3 0f 1e fb          	endbr32 
80103e5c:	55                   	push   %ebp
80103e5d:	89 e5                	mov    %esp,%ebp
80103e5f:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e62:	e8 42 fd ff ff       	call   80103ba9 <myproc>
80103e67:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e6d:	8b 00                	mov    (%eax),%eax
80103e6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103e72:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e76:	7e 2e                	jle    80103ea6 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e78:	8b 55 08             	mov    0x8(%ebp),%edx
80103e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7e:	01 c2                	add    %eax,%edx
80103e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e83:	8b 40 04             	mov    0x4(%eax),%eax
80103e86:	83 ec 04             	sub    $0x4,%esp
80103e89:	52                   	push   %edx
80103e8a:	ff 75 f4             	pushl  -0xc(%ebp)
80103e8d:	50                   	push   %eax
80103e8e:	e8 8b 40 00 00       	call   80107f1e <allocuvm>
80103e93:	83 c4 10             	add    $0x10,%esp
80103e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e9d:	75 3b                	jne    80103eda <growproc+0x82>
      return -1;
80103e9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ea4:	eb 4f                	jmp    80103ef5 <growproc+0x9d>
  } else if(n < 0){
80103ea6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103eaa:	79 2e                	jns    80103eda <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103eac:	8b 55 08             	mov    0x8(%ebp),%edx
80103eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb2:	01 c2                	add    %eax,%edx
80103eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eb7:	8b 40 04             	mov    0x4(%eax),%eax
80103eba:	83 ec 04             	sub    $0x4,%esp
80103ebd:	52                   	push   %edx
80103ebe:	ff 75 f4             	pushl  -0xc(%ebp)
80103ec1:	50                   	push   %eax
80103ec2:	e8 60 41 00 00       	call   80108027 <deallocuvm>
80103ec7:	83 c4 10             	add    $0x10,%esp
80103eca:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ecd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ed1:	75 07                	jne    80103eda <growproc+0x82>
      return -1;
80103ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ed8:	eb 1b                	jmp    80103ef5 <growproc+0x9d>
  }
  curproc->sz = sz;
80103eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103edd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ee0:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103ee2:	83 ec 0c             	sub    $0xc,%esp
80103ee5:	ff 75 f0             	pushl  -0x10(%ebp)
80103ee8:	e8 49 3d 00 00       	call   80107c36 <switchuvm>
80103eed:	83 c4 10             	add    $0x10,%esp
  return 0;
80103ef0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ef5:	c9                   	leave  
80103ef6:	c3                   	ret    

80103ef7 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103ef7:	f3 0f 1e fb          	endbr32 
80103efb:	55                   	push   %ebp
80103efc:	89 e5                	mov    %esp,%ebp
80103efe:	57                   	push   %edi
80103eff:	56                   	push   %esi
80103f00:	53                   	push   %ebx
80103f01:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f04:	e8 a0 fc ff ff       	call   80103ba9 <myproc>
80103f09:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103f0c:	e8 c5 fc ff ff       	call   80103bd6 <allocproc>
80103f11:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103f14:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103f18:	75 0a                	jne    80103f24 <fork+0x2d>
    return -1;
80103f1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f1f:	e9 48 01 00 00       	jmp    8010406c <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103f24:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f27:	8b 10                	mov    (%eax),%edx
80103f29:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f2c:	8b 40 04             	mov    0x4(%eax),%eax
80103f2f:	83 ec 08             	sub    $0x8,%esp
80103f32:	52                   	push   %edx
80103f33:	50                   	push   %eax
80103f34:	e8 98 42 00 00       	call   801081d1 <copyuvm>
80103f39:	83 c4 10             	add    $0x10,%esp
80103f3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f3f:	89 42 04             	mov    %eax,0x4(%edx)
80103f42:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f45:	8b 40 04             	mov    0x4(%eax),%eax
80103f48:	85 c0                	test   %eax,%eax
80103f4a:	75 30                	jne    80103f7c <fork+0x85>
    kfree(np->kstack);
80103f4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f4f:	8b 40 08             	mov    0x8(%eax),%eax
80103f52:	83 ec 0c             	sub    $0xc,%esp
80103f55:	50                   	push   %eax
80103f56:	e8 99 e8 ff ff       	call   801027f4 <kfree>
80103f5b:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103f5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f61:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103f68:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f6b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103f72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f77:	e9 f0 00 00 00       	jmp    8010406c <fork+0x175>
  }
  np->sz = curproc->sz;
80103f7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f7f:	8b 10                	mov    (%eax),%edx
80103f81:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f84:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103f86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f89:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103f8c:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103f8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f92:	8b 48 18             	mov    0x18(%eax),%ecx
80103f95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f98:	8b 40 18             	mov    0x18(%eax),%eax
80103f9b:	89 c2                	mov    %eax,%edx
80103f9d:	89 cb                	mov    %ecx,%ebx
80103f9f:	b8 13 00 00 00       	mov    $0x13,%eax
80103fa4:	89 d7                	mov    %edx,%edi
80103fa6:	89 de                	mov    %ebx,%esi
80103fa8:	89 c1                	mov    %eax,%ecx
80103faa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103fac:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103faf:	8b 40 18             	mov    0x18(%eax),%eax
80103fb2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103fb9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103fc0:	eb 3b                	jmp    80103ffd <fork+0x106>
    if(curproc->ofile[i])
80103fc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fc5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fc8:	83 c2 08             	add    $0x8,%edx
80103fcb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fcf:	85 c0                	test   %eax,%eax
80103fd1:	74 26                	je     80103ff9 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103fd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fd6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fd9:	83 c2 08             	add    $0x8,%edx
80103fdc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fe0:	83 ec 0c             	sub    $0xc,%esp
80103fe3:	50                   	push   %eax
80103fe4:	e8 ab d0 ff ff       	call   80101094 <filedup>
80103fe9:	83 c4 10             	add    $0x10,%esp
80103fec:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103ff2:	83 c1 08             	add    $0x8,%ecx
80103ff5:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103ff9:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103ffd:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104001:	7e bf                	jle    80103fc2 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104003:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104006:	8b 40 68             	mov    0x68(%eax),%eax
80104009:	83 ec 0c             	sub    $0xc,%esp
8010400c:	50                   	push   %eax
8010400d:	e8 2c da ff ff       	call   80101a3e <idup>
80104012:	83 c4 10             	add    $0x10,%esp
80104015:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104018:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010401b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010401e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104021:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104024:	83 c0 6c             	add    $0x6c,%eax
80104027:	83 ec 04             	sub    $0x4,%esp
8010402a:	6a 10                	push   $0x10
8010402c:	52                   	push   %edx
8010402d:	50                   	push   %eax
8010402e:	e8 19 12 00 00       	call   8010524c <safestrcpy>
80104033:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104036:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104039:	8b 40 10             	mov    0x10(%eax),%eax
8010403c:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010403f:	83 ec 0c             	sub    $0xc,%esp
80104042:	68 00 55 19 80       	push   $0x80195500
80104047:	e8 56 0d 00 00       	call   80104da2 <acquire>
8010404c:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010404f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104052:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104059:	83 ec 0c             	sub    $0xc,%esp
8010405c:	68 00 55 19 80       	push   $0x80195500
80104061:	e8 ae 0d 00 00       	call   80104e14 <release>
80104066:	83 c4 10             	add    $0x10,%esp

  return pid;
80104069:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010406c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010406f:	5b                   	pop    %ebx
80104070:	5e                   	pop    %esi
80104071:	5f                   	pop    %edi
80104072:	5d                   	pop    %ebp
80104073:	c3                   	ret    

80104074 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104074:	f3 0f 1e fb          	endbr32 
80104078:	55                   	push   %ebp
80104079:	89 e5                	mov    %esp,%ebp
8010407b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010407e:	e8 26 fb ff ff       	call   80103ba9 <myproc>
80104083:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104086:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
8010408b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010408e:	75 0d                	jne    8010409d <exit+0x29>
    panic("init exiting");
80104090:	83 ec 0c             	sub    $0xc,%esp
80104093:	68 32 ac 10 80       	push   $0x8010ac32
80104098:	e8 28 c5 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010409d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801040a4:	eb 3f                	jmp    801040e5 <exit+0x71>
    if(curproc->ofile[fd]){
801040a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040ac:	83 c2 08             	add    $0x8,%edx
801040af:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801040b3:	85 c0                	test   %eax,%eax
801040b5:	74 2a                	je     801040e1 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
801040b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040bd:	83 c2 08             	add    $0x8,%edx
801040c0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801040c4:	83 ec 0c             	sub    $0xc,%esp
801040c7:	50                   	push   %eax
801040c8:	e8 1c d0 ff ff       	call   801010e9 <fileclose>
801040cd:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801040d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040d6:	83 c2 08             	add    $0x8,%edx
801040d9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801040e0:	00 
  for(fd = 0; fd < NOFILE; fd++){
801040e1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801040e5:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801040e9:	7e bb                	jle    801040a6 <exit+0x32>
    }
  }

  begin_op();
801040eb:	e8 81 f0 ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801040f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040f3:	8b 40 68             	mov    0x68(%eax),%eax
801040f6:	83 ec 0c             	sub    $0xc,%esp
801040f9:	50                   	push   %eax
801040fa:	e8 e6 da ff ff       	call   80101be5 <iput>
801040ff:	83 c4 10             	add    $0x10,%esp
  end_op();
80104102:	e8 fa f0 ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
80104107:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010410a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104111:	83 ec 0c             	sub    $0xc,%esp
80104114:	68 00 55 19 80       	push   $0x80195500
80104119:	e8 84 0c 00 00       	call   80104da2 <acquire>
8010411e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104121:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104124:	8b 40 14             	mov    0x14(%eax),%eax
80104127:	83 ec 0c             	sub    $0xc,%esp
8010412a:	50                   	push   %eax
8010412b:	e8 7c 07 00 00       	call   801048ac <wakeup1>
80104130:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104133:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010413a:	eb 3a                	jmp    80104176 <exit+0x102>
    if(p->parent == curproc){
8010413c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413f:	8b 40 14             	mov    0x14(%eax),%eax
80104142:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104145:	75 28                	jne    8010416f <exit+0xfb>
      p->parent = initproc;
80104147:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
8010414d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104150:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104156:	8b 40 0c             	mov    0xc(%eax),%eax
80104159:	83 f8 05             	cmp    $0x5,%eax
8010415c:	75 11                	jne    8010416f <exit+0xfb>
        wakeup1(initproc);
8010415e:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104163:	83 ec 0c             	sub    $0xc,%esp
80104166:	50                   	push   %eax
80104167:	e8 40 07 00 00       	call   801048ac <wakeup1>
8010416c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010416f:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104176:	81 7d f4 34 7d 19 80 	cmpl   $0x80197d34,-0xc(%ebp)
8010417d:	72 bd                	jb     8010413c <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010417f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104182:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104189:	e8 2e 05 00 00       	call   801046bc <sched>
  panic("zombie exit");
8010418e:	83 ec 0c             	sub    $0xc,%esp
80104191:	68 3f ac 10 80       	push   $0x8010ac3f
80104196:	e8 2a c4 ff ff       	call   801005c5 <panic>

8010419b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010419b:	f3 0f 1e fb          	endbr32 
8010419f:	55                   	push   %ebp
801041a0:	89 e5                	mov    %esp,%ebp
801041a2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801041a5:	e8 ff f9 ff ff       	call   80103ba9 <myproc>
801041aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801041ad:	83 ec 0c             	sub    $0xc,%esp
801041b0:	68 00 55 19 80       	push   $0x80195500
801041b5:	e8 e8 0b 00 00       	call   80104da2 <acquire>
801041ba:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801041bd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041c4:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801041cb:	e9 a4 00 00 00       	jmp    80104274 <wait+0xd9>
      if(p->parent != curproc)
801041d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d3:	8b 40 14             	mov    0x14(%eax),%eax
801041d6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801041d9:	0f 85 8d 00 00 00    	jne    8010426c <wait+0xd1>
        continue;
      havekids = 1;
801041df:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801041e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e9:	8b 40 0c             	mov    0xc(%eax),%eax
801041ec:	83 f8 05             	cmp    $0x5,%eax
801041ef:	75 7c                	jne    8010426d <wait+0xd2>
        // Found one.
        pid = p->pid;
801041f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f4:	8b 40 10             	mov    0x10(%eax),%eax
801041f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801041fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fd:	8b 40 08             	mov    0x8(%eax),%eax
80104200:	83 ec 0c             	sub    $0xc,%esp
80104203:	50                   	push   %eax
80104204:	e8 eb e5 ff ff       	call   801027f4 <kfree>
80104209:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010420c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104219:	8b 40 04             	mov    0x4(%eax),%eax
8010421c:	83 ec 0c             	sub    $0xc,%esp
8010421f:	50                   	push   %eax
80104220:	e8 ca 3e 00 00       	call   801080ef <freevm>
80104225:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422b:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104235:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010423c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423f:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104246:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010424d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104250:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104257:	83 ec 0c             	sub    $0xc,%esp
8010425a:	68 00 55 19 80       	push   $0x80195500
8010425f:	e8 b0 0b 00 00       	call   80104e14 <release>
80104264:	83 c4 10             	add    $0x10,%esp
        return pid;
80104267:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010426a:	eb 54                	jmp    801042c0 <wait+0x125>
        continue;
8010426c:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010426d:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104274:	81 7d f4 34 7d 19 80 	cmpl   $0x80197d34,-0xc(%ebp)
8010427b:	0f 82 4f ff ff ff    	jb     801041d0 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104281:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104285:	74 0a                	je     80104291 <wait+0xf6>
80104287:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010428a:	8b 40 24             	mov    0x24(%eax),%eax
8010428d:	85 c0                	test   %eax,%eax
8010428f:	74 17                	je     801042a8 <wait+0x10d>
      release(&ptable.lock);
80104291:	83 ec 0c             	sub    $0xc,%esp
80104294:	68 00 55 19 80       	push   $0x80195500
80104299:	e8 76 0b 00 00       	call   80104e14 <release>
8010429e:	83 c4 10             	add    $0x10,%esp
      return -1;
801042a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a6:	eb 18                	jmp    801042c0 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801042a8:	83 ec 08             	sub    $0x8,%esp
801042ab:	68 00 55 19 80       	push   $0x80195500
801042b0:	ff 75 ec             	pushl  -0x14(%ebp)
801042b3:	e8 49 05 00 00       	call   80104801 <sleep>
801042b8:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801042bb:	e9 fd fe ff ff       	jmp    801041bd <wait+0x22>
  }
}
801042c0:	c9                   	leave  
801042c1:	c3                   	ret    

801042c2 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801042c2:	f3 0f 1e fb          	endbr32 
801042c6:	55                   	push   %ebp
801042c7:	89 e5                	mov    %esp,%ebp
801042c9:	83 ec 48             	sub    $0x48,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801042cc:	e8 5c f8 ff ff       	call   80103b2d <mycpu>
801042d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  c->proc = 0;
801042d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042d7:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042de:	00 00 00 

  for (;;) {
    sti();  // 인터럽트 허용
801042e1:	e8 ff f7 ff ff       	call   80103ae5 <sti>
    acquire(&ptable.lock);
801042e6:	83 ec 0c             	sub    $0xc,%esp
801042e9:	68 00 55 19 80       	push   $0x80195500
801042ee:	e8 af 0a 00 00       	call   80104da2 <acquire>
801042f3:	83 c4 10             	add    $0x10,%esp

    int policy = c->sched_policy;  // 현재 설정된 스케줄링 정책
801042f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042f9:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801042ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
    
    //RR
    if (policy == 0) {
80104302:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104306:	75 7b                	jne    80104383 <scheduler+0xc1>
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104308:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010430f:	eb 64                	jmp    80104375 <scheduler+0xb3>
        if (p->state != RUNNABLE)
80104311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104314:	8b 40 0c             	mov    0xc(%eax),%eax
80104317:	83 f8 03             	cmp    $0x3,%eax
8010431a:	75 51                	jne    8010436d <scheduler+0xab>
          continue;

        c->proc = p;
8010431c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010431f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104322:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
80104328:	83 ec 0c             	sub    $0xc,%esp
8010432b:	ff 75 f4             	pushl  -0xc(%ebp)
8010432e:	e8 03 39 00 00       	call   80107c36 <switchuvm>
80104333:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104339:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
80104340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104343:	8b 40 1c             	mov    0x1c(%eax),%eax
80104346:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104349:	83 c2 04             	add    $0x4,%edx
8010434c:	83 ec 08             	sub    $0x8,%esp
8010434f:	50                   	push   %eax
80104350:	52                   	push   %edx
80104351:	e8 6f 0f 00 00       	call   801052c5 <swtch>
80104356:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104359:	e8 bb 38 00 00       	call   80107c19 <switchkvm>
        c->proc = 0;
8010435e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104361:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104368:	00 00 00 
8010436b:	eb 01                	jmp    8010436e <scheduler+0xac>
          continue;
8010436d:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010436e:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104375:	81 7d f4 34 7d 19 80 	cmpl   $0x80197d34,-0xc(%ebp)
8010437c:	72 93                	jb     80104311 <scheduler+0x4f>
8010437e:	e9 24 03 00 00       	jmp    801046a7 <scheduler+0x3e5>
      }
    } else {
      // MLFQ
      // RUNNABLE 상태 프로세스들의 wait_ticks 증가
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104383:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010438a:	eb 46                	jmp    801043d2 <scheduler+0x110>
        if ((p->state == RUNNABLE || p->state == SLEEPING) && p!=c->proc) {
8010438c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438f:	8b 40 0c             	mov    0xc(%eax),%eax
80104392:	83 f8 03             	cmp    $0x3,%eax
80104395:	74 0b                	je     801043a2 <scheduler+0xe0>
80104397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439a:	8b 40 0c             	mov    0xc(%eax),%eax
8010439d:	83 f8 02             	cmp    $0x2,%eax
801043a0:	75 29                	jne    801043cb <scheduler+0x109>
801043a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043a5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801043ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801043ae:	74 1b                	je     801043cb <scheduler+0x109>
          p->wait_ticks[p->priority]++;
801043b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b3:	8b 40 7c             	mov    0x7c(%eax),%eax
801043b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b9:	8d 48 24             	lea    0x24(%eax),%ecx
801043bc:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
801043bf:	8d 4a 01             	lea    0x1(%edx),%ecx
801043c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043c5:	83 c0 24             	add    $0x24,%eax
801043c8:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801043cb:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801043d2:	81 7d f4 34 7d 19 80 	cmpl   $0x80197d34,-0xc(%ebp)
801043d9:	72 b1                	jb     8010438c <scheduler+0xca>
        }
      }

      // Boosting
      if (policy != 3) {
801043db:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
801043df:	0f 84 07 01 00 00    	je     801044ec <scheduler+0x22a>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801043e5:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801043ec:	e9 ee 00 00 00       	jmp    801044df <scheduler+0x21d>
          if (p->state != RUNNABLE && p->state != SLEEPING)
801043f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f4:	8b 40 0c             	mov    0xc(%eax),%eax
801043f7:	83 f8 03             	cmp    $0x3,%eax
801043fa:	74 0f                	je     8010440b <scheduler+0x149>
801043fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104402:	83 f8 02             	cmp    $0x2,%eax
80104405:	0f 85 cc 00 00 00    	jne    801044d7 <scheduler+0x215>
            continue;

          int curq = p->priority;
8010440b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440e:	8b 40 7c             	mov    0x7c(%eax),%eax
80104411:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          int boost_limit[] = {500, 320, 160};
80104414:	c7 45 c4 f4 01 00 00 	movl   $0x1f4,-0x3c(%ebp)
8010441b:	c7 45 c8 40 01 00 00 	movl   $0x140,-0x38(%ebp)
80104422:	c7 45 cc a0 00 00 00 	movl   $0xa0,-0x34(%ebp)
          // Boost 조건
          if (curq == 0 && p->wait_ticks[0] >= boost_limit[0]){
80104429:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010442d:	75 34                	jne    80104463 <scheduler+0x1a1>
8010442f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104432:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80104438:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010443b:	39 c2                	cmp    %eax,%edx
8010443d:	7c 24                	jl     80104463 <scheduler+0x1a1>
            p->priority = 1;
8010443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104442:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
            memset(p->wait_ticks, 0, sizeof(p->wait_ticks));
80104449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444c:	05 90 00 00 00       	add    $0x90,%eax
80104451:	83 ec 04             	sub    $0x4,%esp
80104454:	6a 10                	push   $0x10
80104456:	6a 00                	push   $0x0
80104458:	50                   	push   %eax
80104459:	e8 d3 0b 00 00       	call   80105031 <memset>
8010445e:	83 c4 10             	add    $0x10,%esp
80104461:	eb 75                	jmp    801044d8 <scheduler+0x216>
          } else if (curq == 1 && p->wait_ticks[1] >= boost_limit[1]){
80104463:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
80104467:	75 34                	jne    8010449d <scheduler+0x1db>
80104469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446c:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80104472:	8b 45 c8             	mov    -0x38(%ebp),%eax
80104475:	39 c2                	cmp    %eax,%edx
80104477:	7c 24                	jl     8010449d <scheduler+0x1db>
            p->priority = 2;
80104479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447c:	c7 40 7c 02 00 00 00 	movl   $0x2,0x7c(%eax)
            memset(p->wait_ticks, 0, sizeof(p->wait_ticks));
80104483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104486:	05 90 00 00 00       	add    $0x90,%eax
8010448b:	83 ec 04             	sub    $0x4,%esp
8010448e:	6a 10                	push   $0x10
80104490:	6a 00                	push   $0x0
80104492:	50                   	push   %eax
80104493:	e8 99 0b 00 00       	call   80105031 <memset>
80104498:	83 c4 10             	add    $0x10,%esp
8010449b:	eb 3b                	jmp    801044d8 <scheduler+0x216>
          } else if (curq == 2 && p->wait_ticks[2] >= boost_limit[2]){
8010449d:	83 7d e4 02          	cmpl   $0x2,-0x1c(%ebp)
801044a1:	75 35                	jne    801044d8 <scheduler+0x216>
801044a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a6:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
801044ac:	8b 45 cc             	mov    -0x34(%ebp),%eax
801044af:	39 c2                	cmp    %eax,%edx
801044b1:	7c 25                	jl     801044d8 <scheduler+0x216>
            p->priority = 3;
801044b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b6:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
            memset(p->wait_ticks, 0, sizeof(p->wait_ticks));
801044bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c0:	05 90 00 00 00       	add    $0x90,%eax
801044c5:	83 ec 04             	sub    $0x4,%esp
801044c8:	6a 10                	push   $0x10
801044ca:	6a 00                	push   $0x0
801044cc:	50                   	push   %eax
801044cd:	e8 5f 0b 00 00       	call   80105031 <memset>
801044d2:	83 c4 10             	add    $0x10,%esp
801044d5:	eb 01                	jmp    801044d8 <scheduler+0x216>
            continue;
801044d7:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801044d8:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801044df:	81 7d f4 34 7d 19 80 	cmpl   $0x80197d34,-0xc(%ebp)
801044e6:	0f 82 05 ff ff ff    	jb     801043f1 <scheduler+0x12f>
          }
        }
      }

      // Time slice 
      int slice[4] = { -1, 32, 16, 8 };
801044ec:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
801044f3:	c7 45 d4 20 00 00 00 	movl   $0x20,-0x2c(%ebp)
801044fa:	c7 45 d8 10 00 00 00 	movl   $0x10,-0x28(%ebp)
80104501:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)

      //int done = 0;

      // Q3부터 순차적으로 찾기
      for (int q = 3; q >= 0 ; q--) {
80104508:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
8010450f:	e9 89 01 00 00       	jmp    8010469d <scheduler+0x3db>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104514:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010451b:	e9 6c 01 00 00       	jmp    8010468c <scheduler+0x3ca>
          if (p->state != RUNNABLE || p->priority != q)
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	8b 40 0c             	mov    0xc(%eax),%eax
80104526:	83 f8 03             	cmp    $0x3,%eax
80104529:	0f 85 55 01 00 00    	jne    80104684 <scheduler+0x3c2>
8010452f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104532:	8b 40 7c             	mov    0x7c(%eax),%eax
80104535:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104538:	0f 85 46 01 00 00    	jne    80104684 <scheduler+0x3c2>
            continue;
          
          int pr = p->priority;
8010453e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104541:	8b 40 7c             	mov    0x7c(%eax),%eax
80104544:	89 45 e0             	mov    %eax,-0x20(%ebp)

          c->proc = p;
80104547:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010454a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010454d:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
80104553:	83 ec 0c             	sub    $0xc,%esp
80104556:	ff 75 f4             	pushl  -0xc(%ebp)
80104559:	e8 d8 36 00 00       	call   80107c36 <switchuvm>
8010455e:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
80104561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104564:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
          swtch(&(c->scheduler), p->context);
8010456b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104571:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104574:	83 c2 04             	add    $0x4,%edx
80104577:	83 ec 08             	sub    $0x8,%esp
8010457a:	50                   	push   %eax
8010457b:	52                   	push   %edx
8010457c:	e8 44 0d 00 00       	call   801052c5 <swtch>
80104581:	83 c4 10             	add    $0x10,%esp
          switchkvm();
80104584:	e8 90 36 00 00       	call   80107c19 <switchkvm>
          c->proc = 0;
80104589:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010458c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104593:	00 00 00 

          // Demote (정책 2번): tick에 따라 강등
          if (policy == 2) {
80104596:	83 7d e8 02          	cmpl   $0x2,-0x18(%ebp)
8010459a:	75 75                	jne    80104611 <scheduler+0x34f>
            if ((pr == 3 && p->ticks[3] >= 8) || (pr == 2 && p->ticks[2] >= 16) ||(pr == 1 && p->ticks[1] >= 32)) {
8010459c:	83 7d e0 03          	cmpl   $0x3,-0x20(%ebp)
801045a0:	75 0e                	jne    801045b0 <scheduler+0x2ee>
801045a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801045ab:	83 f8 07             	cmp    $0x7,%eax
801045ae:	7f 30                	jg     801045e0 <scheduler+0x31e>
801045b0:	83 7d e0 02          	cmpl   $0x2,-0x20(%ebp)
801045b4:	75 0e                	jne    801045c4 <scheduler+0x302>
801045b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b9:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801045bf:	83 f8 0f             	cmp    $0xf,%eax
801045c2:	7f 1c                	jg     801045e0 <scheduler+0x31e>
801045c4:	83 7d e0 01          	cmpl   $0x1,-0x20(%ebp)
801045c8:	0f 85 b7 00 00 00    	jne    80104685 <scheduler+0x3c3>
801045ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d1:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801045d7:	83 f8 1f             	cmp    $0x1f,%eax
801045da:	0f 8e a5 00 00 00    	jle    80104685 <scheduler+0x3c3>

              if (p->priority > 0){
801045e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e3:	8b 40 7c             	mov    0x7c(%eax),%eax
801045e6:	85 c0                	test   %eax,%eax
801045e8:	7e 0f                	jle    801045f9 <scheduler+0x337>
                p->priority--;
801045ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ed:	8b 40 7c             	mov    0x7c(%eax),%eax
801045f0:	8d 50 ff             	lea    -0x1(%eax),%edx
801045f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f6:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
801045f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fc:	83 e8 80             	sub    $0xffffff80,%eax
801045ff:	83 ec 04             	sub    $0x4,%esp
80104602:	6a 10                	push   $0x10
80104604:	6a 00                	push   $0x0
80104606:	50                   	push   %eax
80104607:	e8 25 0a 00 00       	call   80105031 <memset>
8010460c:	83 c4 10             	add    $0x10,%esp
8010460f:	eb 74                	jmp    80104685 <scheduler+0x3c3>
            }
          }
          // 정책 1 & 3: slice 기반 강등
          else {
            if ((pr == 3 && p->ticks[3] >= slice[3]) ||
80104611:	83 7d e0 03          	cmpl   $0x3,-0x20(%ebp)
80104615:	75 10                	jne    80104627 <scheduler+0x365>
80104617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461a:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80104620:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104623:	39 c2                	cmp    %eax,%edx
80104625:	7d 2c                	jge    80104653 <scheduler+0x391>
80104627:	83 7d e0 02          	cmpl   $0x2,-0x20(%ebp)
8010462b:	75 10                	jne    8010463d <scheduler+0x37b>
                (pr == 2 && p->ticks[2] >= slice[2]) ||
8010462d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104630:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80104636:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104639:	39 c2                	cmp    %eax,%edx
8010463b:	7d 16                	jge    80104653 <scheduler+0x391>
8010463d:	83 7d e0 01          	cmpl   $0x1,-0x20(%ebp)
80104641:	75 42                	jne    80104685 <scheduler+0x3c3>
                (pr == 1 && p->ticks[1] >= slice[1])) {
80104643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104646:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
8010464c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010464f:	39 c2                	cmp    %eax,%edx
80104651:	7c 32                	jl     80104685 <scheduler+0x3c3>
              if (p->priority > 0){
80104653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104656:	8b 40 7c             	mov    0x7c(%eax),%eax
80104659:	85 c0                	test   %eax,%eax
8010465b:	7e 0f                	jle    8010466c <scheduler+0x3aa>
                p->priority--;
8010465d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104660:	8b 40 7c             	mov    0x7c(%eax),%eax
80104663:	8d 50 ff             	lea    -0x1(%eax),%edx
80104666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104669:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));
8010466c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466f:	83 e8 80             	sub    $0xffffff80,%eax
80104672:	83 ec 04             	sub    $0x4,%esp
80104675:	6a 10                	push   $0x10
80104677:	6a 00                	push   $0x0
80104679:	50                   	push   %eax
8010467a:	e8 b2 09 00 00       	call   80105031 <memset>
8010467f:	83 c4 10             	add    $0x10,%esp
80104682:	eb 01                	jmp    80104685 <scheduler+0x3c3>
            continue;
80104684:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104685:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
8010468c:	81 7d f4 34 7d 19 80 	cmpl   $0x80197d34,-0xc(%ebp)
80104693:	0f 82 87 fe ff ff    	jb     80104520 <scheduler+0x25e>
      for (int q = 3; q >= 0 ; q--) {
80104699:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010469d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801046a1:	0f 89 6d fe ff ff    	jns    80104514 <scheduler+0x252>
          }
        }
      }
    }

    release(&ptable.lock);
801046a7:	83 ec 0c             	sub    $0xc,%esp
801046aa:	68 00 55 19 80       	push   $0x80195500
801046af:	e8 60 07 00 00       	call   80104e14 <release>
801046b4:	83 c4 10             	add    $0x10,%esp
  for (;;) {
801046b7:	e9 25 fc ff ff       	jmp    801042e1 <scheduler+0x1f>

801046bc <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801046bc:	f3 0f 1e fb          	endbr32 
801046c0:	55                   	push   %ebp
801046c1:	89 e5                	mov    %esp,%ebp
801046c3:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801046c6:	e8 de f4 ff ff       	call   80103ba9 <myproc>
801046cb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801046ce:	83 ec 0c             	sub    $0xc,%esp
801046d1:	68 00 55 19 80       	push   $0x80195500
801046d6:	e8 0e 08 00 00       	call   80104ee9 <holding>
801046db:	83 c4 10             	add    $0x10,%esp
801046de:	85 c0                	test   %eax,%eax
801046e0:	75 0d                	jne    801046ef <sched+0x33>
    panic("sched ptable.lock");
801046e2:	83 ec 0c             	sub    $0xc,%esp
801046e5:	68 4b ac 10 80       	push   $0x8010ac4b
801046ea:	e8 d6 be ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
801046ef:	e8 39 f4 ff ff       	call   80103b2d <mycpu>
801046f4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801046fa:	83 f8 01             	cmp    $0x1,%eax
801046fd:	74 0d                	je     8010470c <sched+0x50>
    panic("sched locks");
801046ff:	83 ec 0c             	sub    $0xc,%esp
80104702:	68 5d ac 10 80       	push   $0x8010ac5d
80104707:	e8 b9 be ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
8010470c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470f:	8b 40 0c             	mov    0xc(%eax),%eax
80104712:	83 f8 04             	cmp    $0x4,%eax
80104715:	75 0d                	jne    80104724 <sched+0x68>
    panic("sched running");
80104717:	83 ec 0c             	sub    $0xc,%esp
8010471a:	68 69 ac 10 80       	push   $0x8010ac69
8010471f:	e8 a1 be ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104724:	e8 ac f3 ff ff       	call   80103ad5 <readeflags>
80104729:	25 00 02 00 00       	and    $0x200,%eax
8010472e:	85 c0                	test   %eax,%eax
80104730:	74 0d                	je     8010473f <sched+0x83>
    panic("sched interruptible");
80104732:	83 ec 0c             	sub    $0xc,%esp
80104735:	68 77 ac 10 80       	push   $0x8010ac77
8010473a:	e8 86 be ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
8010473f:	e8 e9 f3 ff ff       	call   80103b2d <mycpu>
80104744:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010474a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010474d:	e8 db f3 ff ff       	call   80103b2d <mycpu>
80104752:	8b 40 04             	mov    0x4(%eax),%eax
80104755:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104758:	83 c2 1c             	add    $0x1c,%edx
8010475b:	83 ec 08             	sub    $0x8,%esp
8010475e:	50                   	push   %eax
8010475f:	52                   	push   %edx
80104760:	e8 60 0b 00 00       	call   801052c5 <swtch>
80104765:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104768:	e8 c0 f3 ff ff       	call   80103b2d <mycpu>
8010476d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104770:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104776:	90                   	nop
80104777:	c9                   	leave  
80104778:	c3                   	ret    

80104779 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104779:	f3 0f 1e fb          	endbr32 
8010477d:	55                   	push   %ebp
8010477e:	89 e5                	mov    %esp,%ebp
80104780:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104783:	83 ec 0c             	sub    $0xc,%esp
80104786:	68 00 55 19 80       	push   $0x80195500
8010478b:	e8 12 06 00 00       	call   80104da2 <acquire>
80104790:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104793:	e8 11 f4 ff ff       	call   80103ba9 <myproc>
80104798:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010479f:	e8 18 ff ff ff       	call   801046bc <sched>
  release(&ptable.lock);
801047a4:	83 ec 0c             	sub    $0xc,%esp
801047a7:	68 00 55 19 80       	push   $0x80195500
801047ac:	e8 63 06 00 00       	call   80104e14 <release>
801047b1:	83 c4 10             	add    $0x10,%esp
}
801047b4:	90                   	nop
801047b5:	c9                   	leave  
801047b6:	c3                   	ret    

801047b7 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801047b7:	f3 0f 1e fb          	endbr32 
801047bb:	55                   	push   %ebp
801047bc:	89 e5                	mov    %esp,%ebp
801047be:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801047c1:	83 ec 0c             	sub    $0xc,%esp
801047c4:	68 00 55 19 80       	push   $0x80195500
801047c9:	e8 46 06 00 00       	call   80104e14 <release>
801047ce:	83 c4 10             	add    $0x10,%esp

  if (first) {
801047d1:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801047d6:	85 c0                	test   %eax,%eax
801047d8:	74 24                	je     801047fe <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801047da:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801047e1:	00 00 00 
    iinit(ROOTDEV);
801047e4:	83 ec 0c             	sub    $0xc,%esp
801047e7:	6a 01                	push   $0x1
801047e9:	e8 08 cf ff ff       	call   801016f6 <iinit>
801047ee:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801047f1:	83 ec 0c             	sub    $0xc,%esp
801047f4:	6a 01                	push   $0x1
801047f6:	e8 43 e7 ff ff       	call   80102f3e <initlog>
801047fb:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801047fe:	90                   	nop
801047ff:	c9                   	leave  
80104800:	c3                   	ret    

80104801 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104801:	f3 0f 1e fb          	endbr32 
80104805:	55                   	push   %ebp
80104806:	89 e5                	mov    %esp,%ebp
80104808:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010480b:	e8 99 f3 ff ff       	call   80103ba9 <myproc>
80104810:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104813:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104817:	75 0d                	jne    80104826 <sleep+0x25>
    panic("sleep");
80104819:	83 ec 0c             	sub    $0xc,%esp
8010481c:	68 8b ac 10 80       	push   $0x8010ac8b
80104821:	e8 9f bd ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104826:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010482a:	75 0d                	jne    80104839 <sleep+0x38>
    panic("sleep without lk");
8010482c:	83 ec 0c             	sub    $0xc,%esp
8010482f:	68 91 ac 10 80       	push   $0x8010ac91
80104834:	e8 8c bd ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104839:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104840:	74 1e                	je     80104860 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104842:	83 ec 0c             	sub    $0xc,%esp
80104845:	68 00 55 19 80       	push   $0x80195500
8010484a:	e8 53 05 00 00       	call   80104da2 <acquire>
8010484f:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104852:	83 ec 0c             	sub    $0xc,%esp
80104855:	ff 75 0c             	pushl  0xc(%ebp)
80104858:	e8 b7 05 00 00       	call   80104e14 <release>
8010485d:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104863:	8b 55 08             	mov    0x8(%ebp),%edx
80104866:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486c:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104873:	e8 44 fe ff ff       	call   801046bc <sched>

  // Tidy up.
  p->chan = 0;
80104878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104882:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104889:	74 1e                	je     801048a9 <sleep+0xa8>
    release(&ptable.lock);
8010488b:	83 ec 0c             	sub    $0xc,%esp
8010488e:	68 00 55 19 80       	push   $0x80195500
80104893:	e8 7c 05 00 00       	call   80104e14 <release>
80104898:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010489b:	83 ec 0c             	sub    $0xc,%esp
8010489e:	ff 75 0c             	pushl  0xc(%ebp)
801048a1:	e8 fc 04 00 00       	call   80104da2 <acquire>
801048a6:	83 c4 10             	add    $0x10,%esp
  }
}
801048a9:	90                   	nop
801048aa:	c9                   	leave  
801048ab:	c3                   	ret    

801048ac <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801048ac:	f3 0f 1e fb          	endbr32 
801048b0:	55                   	push   %ebp
801048b1:	89 e5                	mov    %esp,%ebp
801048b3:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048b6:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
801048bd:	eb 27                	jmp    801048e6 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
801048bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048c2:	8b 40 0c             	mov    0xc(%eax),%eax
801048c5:	83 f8 02             	cmp    $0x2,%eax
801048c8:	75 15                	jne    801048df <wakeup1+0x33>
801048ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048cd:	8b 40 20             	mov    0x20(%eax),%eax
801048d0:	39 45 08             	cmp    %eax,0x8(%ebp)
801048d3:	75 0a                	jne    801048df <wakeup1+0x33>
      p->state = RUNNABLE;
801048d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048d8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048df:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
801048e6:	81 7d fc 34 7d 19 80 	cmpl   $0x80197d34,-0x4(%ebp)
801048ed:	72 d0                	jb     801048bf <wakeup1+0x13>
}
801048ef:	90                   	nop
801048f0:	90                   	nop
801048f1:	c9                   	leave  
801048f2:	c3                   	ret    

801048f3 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048f3:	f3 0f 1e fb          	endbr32 
801048f7:	55                   	push   %ebp
801048f8:	89 e5                	mov    %esp,%ebp
801048fa:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801048fd:	83 ec 0c             	sub    $0xc,%esp
80104900:	68 00 55 19 80       	push   $0x80195500
80104905:	e8 98 04 00 00       	call   80104da2 <acquire>
8010490a:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010490d:	83 ec 0c             	sub    $0xc,%esp
80104910:	ff 75 08             	pushl  0x8(%ebp)
80104913:	e8 94 ff ff ff       	call   801048ac <wakeup1>
80104918:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010491b:	83 ec 0c             	sub    $0xc,%esp
8010491e:	68 00 55 19 80       	push   $0x80195500
80104923:	e8 ec 04 00 00       	call   80104e14 <release>
80104928:	83 c4 10             	add    $0x10,%esp
}
8010492b:	90                   	nop
8010492c:	c9                   	leave  
8010492d:	c3                   	ret    

8010492e <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010492e:	f3 0f 1e fb          	endbr32 
80104932:	55                   	push   %ebp
80104933:	89 e5                	mov    %esp,%ebp
80104935:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104938:	83 ec 0c             	sub    $0xc,%esp
8010493b:	68 00 55 19 80       	push   $0x80195500
80104940:	e8 5d 04 00 00       	call   80104da2 <acquire>
80104945:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104948:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010494f:	eb 48                	jmp    80104999 <kill+0x6b>
    if(p->pid == pid){
80104951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104954:	8b 40 10             	mov    0x10(%eax),%eax
80104957:	39 45 08             	cmp    %eax,0x8(%ebp)
8010495a:	75 36                	jne    80104992 <kill+0x64>
      p->killed = 1;
8010495c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104969:	8b 40 0c             	mov    0xc(%eax),%eax
8010496c:	83 f8 02             	cmp    $0x2,%eax
8010496f:	75 0a                	jne    8010497b <kill+0x4d>
        p->state = RUNNABLE;
80104971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104974:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010497b:	83 ec 0c             	sub    $0xc,%esp
8010497e:	68 00 55 19 80       	push   $0x80195500
80104983:	e8 8c 04 00 00       	call   80104e14 <release>
80104988:	83 c4 10             	add    $0x10,%esp
      return 0;
8010498b:	b8 00 00 00 00       	mov    $0x0,%eax
80104990:	eb 25                	jmp    801049b7 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104992:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104999:	81 7d f4 34 7d 19 80 	cmpl   $0x80197d34,-0xc(%ebp)
801049a0:	72 af                	jb     80104951 <kill+0x23>
    }
  }
  release(&ptable.lock);
801049a2:	83 ec 0c             	sub    $0xc,%esp
801049a5:	68 00 55 19 80       	push   $0x80195500
801049aa:	e8 65 04 00 00       	call   80104e14 <release>
801049af:	83 c4 10             	add    $0x10,%esp
  return -1;
801049b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801049b7:	c9                   	leave  
801049b8:	c3                   	ret    

801049b9 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801049b9:	f3 0f 1e fb          	endbr32 
801049bd:	55                   	push   %ebp
801049be:	89 e5                	mov    %esp,%ebp
801049c0:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049c3:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
801049ca:	e9 da 00 00 00       	jmp    80104aa9 <procdump+0xf0>
    if(p->state == UNUSED)
801049cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049d2:	8b 40 0c             	mov    0xc(%eax),%eax
801049d5:	85 c0                	test   %eax,%eax
801049d7:	0f 84 c4 00 00 00    	je     80104aa1 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801049dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049e0:	8b 40 0c             	mov    0xc(%eax),%eax
801049e3:	83 f8 05             	cmp    $0x5,%eax
801049e6:	77 23                	ja     80104a0b <procdump+0x52>
801049e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049eb:	8b 40 0c             	mov    0xc(%eax),%eax
801049ee:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049f5:	85 c0                	test   %eax,%eax
801049f7:	74 12                	je     80104a0b <procdump+0x52>
      state = states[p->state];
801049f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049fc:	8b 40 0c             	mov    0xc(%eax),%eax
801049ff:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104a06:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104a09:	eb 07                	jmp    80104a12 <procdump+0x59>
    else
      state = "???";
80104a0b:	c7 45 ec a2 ac 10 80 	movl   $0x8010aca2,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a15:	8d 50 6c             	lea    0x6c(%eax),%edx
80104a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a1b:	8b 40 10             	mov    0x10(%eax),%eax
80104a1e:	52                   	push   %edx
80104a1f:	ff 75 ec             	pushl  -0x14(%ebp)
80104a22:	50                   	push   %eax
80104a23:	68 a6 ac 10 80       	push   $0x8010aca6
80104a28:	e8 df b9 ff ff       	call   8010040c <cprintf>
80104a2d:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a33:	8b 40 0c             	mov    0xc(%eax),%eax
80104a36:	83 f8 02             	cmp    $0x2,%eax
80104a39:	75 54                	jne    80104a8f <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a3e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a41:	8b 40 0c             	mov    0xc(%eax),%eax
80104a44:	83 c0 08             	add    $0x8,%eax
80104a47:	89 c2                	mov    %eax,%edx
80104a49:	83 ec 08             	sub    $0x8,%esp
80104a4c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104a4f:	50                   	push   %eax
80104a50:	52                   	push   %edx
80104a51:	e8 14 04 00 00       	call   80104e6a <getcallerpcs>
80104a56:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a60:	eb 1c                	jmp    80104a7e <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a65:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a69:	83 ec 08             	sub    $0x8,%esp
80104a6c:	50                   	push   %eax
80104a6d:	68 af ac 10 80       	push   $0x8010acaf
80104a72:	e8 95 b9 ff ff       	call   8010040c <cprintf>
80104a77:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a7e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a82:	7f 0b                	jg     80104a8f <procdump+0xd6>
80104a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a87:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a8b:	85 c0                	test   %eax,%eax
80104a8d:	75 d3                	jne    80104a62 <procdump+0xa9>
    }
    cprintf("\n");
80104a8f:	83 ec 0c             	sub    $0xc,%esp
80104a92:	68 b3 ac 10 80       	push   $0x8010acb3
80104a97:	e8 70 b9 ff ff       	call   8010040c <cprintf>
80104a9c:	83 c4 10             	add    $0x10,%esp
80104a9f:	eb 01                	jmp    80104aa2 <procdump+0xe9>
      continue;
80104aa1:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aa2:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
80104aa9:	81 7d f0 34 7d 19 80 	cmpl   $0x80197d34,-0x10(%ebp)
80104ab0:	0f 82 19 ff ff ff    	jb     801049cf <procdump+0x16>
  }
}
80104ab6:	90                   	nop
80104ab7:	90                   	nop
80104ab8:	c9                   	leave  
80104ab9:	c3                   	ret    

80104aba <setSchedPolicy>:

//  0 (RR), 1 (MLFQ), 2 (MLFQ-no-tracking), 3 (MLFQ-no-boosting)

int
setSchedPolicy(int policy)
{
80104aba:	f3 0f 1e fb          	endbr32 
80104abe:	55                   	push   %ebp
80104abf:	89 e5                	mov    %esp,%ebp
80104ac1:	83 ec 18             	sub    $0x18,%esp

  if (policy < 0 || policy > 3)
80104ac4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104ac8:	78 06                	js     80104ad0 <setSchedPolicy+0x16>
80104aca:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104ace:	7e 07                	jle    80104ad7 <setSchedPolicy+0x1d>
    return -1;
80104ad0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ad5:	eb 23                	jmp    80104afa <setSchedPolicy+0x40>

  pushcli();
80104ad7:	e8 42 04 00 00       	call   80104f1e <pushcli>
  struct cpu *c = mycpu();
80104adc:	e8 4c f0 ff ff       	call   80103b2d <mycpu>
80104ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->sched_policy = policy;
80104ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae7:	8b 55 08             	mov    0x8(%ebp),%edx
80104aea:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104af0:	e8 7a 04 00 00       	call   80104f6f <popcli>

  return 0;
80104af5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104afa:	c9                   	leave  
80104afb:	c3                   	ret    

80104afc <getpinfo>:


int
getpinfo(struct pstat *ps)
{
80104afc:	f3 0f 1e fb          	endbr32 
80104b00:	55                   	push   %ebp
80104b01:	89 e5                	mov    %esp,%ebp
80104b03:	53                   	push   %ebx
80104b04:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  int i = 0;
80104b07:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);  
80104b0e:	83 ec 0c             	sub    $0xc,%esp
80104b11:	68 00 55 19 80       	push   $0x80195500
80104b16:	e8 87 02 00 00       	call   80104da2 <acquire>
80104b1b:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
80104b1e:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104b25:	e9 be 00 00 00       	jmp    80104be8 <getpinfo+0xec>
    // 프로세스가 사용 중이면 1, 아니면 0
    ps->inuse[i] = (p->state != UNUSED);
80104b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2d:	8b 40 0c             	mov    0xc(%eax),%eax
80104b30:	85 c0                	test   %eax,%eax
80104b32:	0f 95 c0             	setne  %al
80104b35:	0f b6 c8             	movzbl %al,%ecx
80104b38:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b3e:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // pid 저장
    ps->pid[i] = p->pid;
80104b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b44:	8b 50 10             	mov    0x10(%eax),%edx
80104b47:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104b4d:	83 c1 40             	add    $0x40,%ecx
80104b50:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 우선순위 저장 
    ps->priority[i] = p->priority;
80104b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b56:	8b 50 7c             	mov    0x7c(%eax),%edx
80104b59:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104b5f:	83 e9 80             	sub    $0xffffff80,%ecx
80104b62:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    // 현재 상태 저장 
    ps->state[i] = p->state;
80104b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b68:	8b 40 0c             	mov    0xc(%eax),%eax
80104b6b:	89 c1                	mov    %eax,%ecx
80104b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b70:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b73:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80104b79:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // 각 큐에서 실행된 tick 수 저장
    for (int j = 0; j < 4; j++) {
80104b7c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104b83:	eb 52                	jmp    80104bd7 <getpinfo+0xdb>
      ps->ticks[i][j] = p->ticks[j];
80104b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b88:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104b8b:	83 c2 20             	add    $0x20,%edx
80104b8e:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104b91:	8b 45 08             	mov    0x8(%ebp),%eax
80104b94:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104b97:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104b9e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104ba1:	01 d9                	add    %ebx,%ecx
80104ba3:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104ba9:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
80104bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104baf:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104bb2:	83 c2 24             	add    $0x24,%edx
80104bb5:	8b 14 90             	mov    (%eax,%edx,4),%edx
80104bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104bbe:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104bc5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104bc8:	01 d9                	add    %ebx,%ecx
80104bca:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104bd0:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104bd3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104bd7:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
80104bdb:	7e a8                	jle    80104b85 <getpinfo+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++, i++) {
80104bdd:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104be4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104be8:	81 7d f4 34 7d 19 80 	cmpl   $0x80197d34,-0xc(%ebp)
80104bef:	0f 82 35 ff ff ff    	jb     80104b2a <getpinfo+0x2e>
    }
  }

  release(&ptable.lock);  
80104bf5:	83 ec 0c             	sub    $0xc,%esp
80104bf8:	68 00 55 19 80       	push   $0x80195500
80104bfd:	e8 12 02 00 00       	call   80104e14 <release>
80104c02:	83 c4 10             	add    $0x10,%esp

  return 0; 
80104c05:	b8 00 00 00 00       	mov    $0x0,%eax
80104c0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c0d:	c9                   	leave  
80104c0e:	c3                   	ret    

80104c0f <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104c0f:	f3 0f 1e fb          	endbr32 
80104c13:	55                   	push   %ebp
80104c14:	89 e5                	mov    %esp,%ebp
80104c16:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104c19:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1c:	83 c0 04             	add    $0x4,%eax
80104c1f:	83 ec 08             	sub    $0x8,%esp
80104c22:	68 df ac 10 80       	push   $0x8010acdf
80104c27:	50                   	push   %eax
80104c28:	e8 4f 01 00 00       	call   80104d7c <initlock>
80104c2d:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104c30:	8b 45 08             	mov    0x8(%ebp),%eax
80104c33:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c36:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104c39:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c42:	8b 45 08             	mov    0x8(%ebp),%eax
80104c45:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104c4c:	90                   	nop
80104c4d:	c9                   	leave  
80104c4e:	c3                   	ret    

80104c4f <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104c4f:	f3 0f 1e fb          	endbr32 
80104c53:	55                   	push   %ebp
80104c54:	89 e5                	mov    %esp,%ebp
80104c56:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104c59:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5c:	83 c0 04             	add    $0x4,%eax
80104c5f:	83 ec 0c             	sub    $0xc,%esp
80104c62:	50                   	push   %eax
80104c63:	e8 3a 01 00 00       	call   80104da2 <acquire>
80104c68:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104c6b:	eb 15                	jmp    80104c82 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c70:	83 c0 04             	add    $0x4,%eax
80104c73:	83 ec 08             	sub    $0x8,%esp
80104c76:	50                   	push   %eax
80104c77:	ff 75 08             	pushl  0x8(%ebp)
80104c7a:	e8 82 fb ff ff       	call   80104801 <sleep>
80104c7f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104c82:	8b 45 08             	mov    0x8(%ebp),%eax
80104c85:	8b 00                	mov    (%eax),%eax
80104c87:	85 c0                	test   %eax,%eax
80104c89:	75 e2                	jne    80104c6d <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104c94:	e8 10 ef ff ff       	call   80103ba9 <myproc>
80104c99:	8b 50 10             	mov    0x10(%eax),%edx
80104c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9f:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca5:	83 c0 04             	add    $0x4,%eax
80104ca8:	83 ec 0c             	sub    $0xc,%esp
80104cab:	50                   	push   %eax
80104cac:	e8 63 01 00 00       	call   80104e14 <release>
80104cb1:	83 c4 10             	add    $0x10,%esp
}
80104cb4:	90                   	nop
80104cb5:	c9                   	leave  
80104cb6:	c3                   	ret    

80104cb7 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104cb7:	f3 0f 1e fb          	endbr32 
80104cbb:	55                   	push   %ebp
80104cbc:	89 e5                	mov    %esp,%ebp
80104cbe:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc4:	83 c0 04             	add    $0x4,%eax
80104cc7:	83 ec 0c             	sub    $0xc,%esp
80104cca:	50                   	push   %eax
80104ccb:	e8 d2 00 00 00       	call   80104da2 <acquire>
80104cd0:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdf:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104ce6:	83 ec 0c             	sub    $0xc,%esp
80104ce9:	ff 75 08             	pushl  0x8(%ebp)
80104cec:	e8 02 fc ff ff       	call   801048f3 <wakeup>
80104cf1:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf7:	83 c0 04             	add    $0x4,%eax
80104cfa:	83 ec 0c             	sub    $0xc,%esp
80104cfd:	50                   	push   %eax
80104cfe:	e8 11 01 00 00       	call   80104e14 <release>
80104d03:	83 c4 10             	add    $0x10,%esp
}
80104d06:	90                   	nop
80104d07:	c9                   	leave  
80104d08:	c3                   	ret    

80104d09 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104d09:	f3 0f 1e fb          	endbr32 
80104d0d:	55                   	push   %ebp
80104d0e:	89 e5                	mov    %esp,%ebp
80104d10:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104d13:	8b 45 08             	mov    0x8(%ebp),%eax
80104d16:	83 c0 04             	add    $0x4,%eax
80104d19:	83 ec 0c             	sub    $0xc,%esp
80104d1c:	50                   	push   %eax
80104d1d:	e8 80 00 00 00       	call   80104da2 <acquire>
80104d22:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104d25:	8b 45 08             	mov    0x8(%ebp),%eax
80104d28:	8b 00                	mov    (%eax),%eax
80104d2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d30:	83 c0 04             	add    $0x4,%eax
80104d33:	83 ec 0c             	sub    $0xc,%esp
80104d36:	50                   	push   %eax
80104d37:	e8 d8 00 00 00       	call   80104e14 <release>
80104d3c:	83 c4 10             	add    $0x10,%esp
  return r;
80104d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d42:	c9                   	leave  
80104d43:	c3                   	ret    

80104d44 <readeflags>:
{
80104d44:	55                   	push   %ebp
80104d45:	89 e5                	mov    %esp,%ebp
80104d47:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d4a:	9c                   	pushf  
80104d4b:	58                   	pop    %eax
80104d4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d52:	c9                   	leave  
80104d53:	c3                   	ret    

80104d54 <cli>:
{
80104d54:	55                   	push   %ebp
80104d55:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104d57:	fa                   	cli    
}
80104d58:	90                   	nop
80104d59:	5d                   	pop    %ebp
80104d5a:	c3                   	ret    

80104d5b <sti>:
{
80104d5b:	55                   	push   %ebp
80104d5c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d5e:	fb                   	sti    
}
80104d5f:	90                   	nop
80104d60:	5d                   	pop    %ebp
80104d61:	c3                   	ret    

80104d62 <xchg>:
{
80104d62:	55                   	push   %ebp
80104d63:	89 e5                	mov    %esp,%ebp
80104d65:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104d68:	8b 55 08             	mov    0x8(%ebp),%edx
80104d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d71:	f0 87 02             	lock xchg %eax,(%edx)
80104d74:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104d77:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d7a:	c9                   	leave  
80104d7b:	c3                   	ret    

80104d7c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104d7c:	f3 0f 1e fb          	endbr32 
80104d80:	55                   	push   %ebp
80104d81:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104d83:	8b 45 08             	mov    0x8(%ebp),%eax
80104d86:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d89:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104d95:	8b 45 08             	mov    0x8(%ebp),%eax
80104d98:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104d9f:	90                   	nop
80104da0:	5d                   	pop    %ebp
80104da1:	c3                   	ret    

80104da2 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104da2:	f3 0f 1e fb          	endbr32 
80104da6:	55                   	push   %ebp
80104da7:	89 e5                	mov    %esp,%ebp
80104da9:	53                   	push   %ebx
80104daa:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104dad:	e8 6c 01 00 00       	call   80104f1e <pushcli>
  if(holding(lk)){
80104db2:	8b 45 08             	mov    0x8(%ebp),%eax
80104db5:	83 ec 0c             	sub    $0xc,%esp
80104db8:	50                   	push   %eax
80104db9:	e8 2b 01 00 00       	call   80104ee9 <holding>
80104dbe:	83 c4 10             	add    $0x10,%esp
80104dc1:	85 c0                	test   %eax,%eax
80104dc3:	74 0d                	je     80104dd2 <acquire+0x30>
    panic("acquire");
80104dc5:	83 ec 0c             	sub    $0xc,%esp
80104dc8:	68 ea ac 10 80       	push   $0x8010acea
80104dcd:	e8 f3 b7 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104dd2:	90                   	nop
80104dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd6:	83 ec 08             	sub    $0x8,%esp
80104dd9:	6a 01                	push   $0x1
80104ddb:	50                   	push   %eax
80104ddc:	e8 81 ff ff ff       	call   80104d62 <xchg>
80104de1:	83 c4 10             	add    $0x10,%esp
80104de4:	85 c0                	test   %eax,%eax
80104de6:	75 eb                	jne    80104dd3 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104de8:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104ded:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104df0:	e8 38 ed ff ff       	call   80103b2d <mycpu>
80104df5:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104df8:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfb:	83 c0 0c             	add    $0xc,%eax
80104dfe:	83 ec 08             	sub    $0x8,%esp
80104e01:	50                   	push   %eax
80104e02:	8d 45 08             	lea    0x8(%ebp),%eax
80104e05:	50                   	push   %eax
80104e06:	e8 5f 00 00 00       	call   80104e6a <getcallerpcs>
80104e0b:	83 c4 10             	add    $0x10,%esp
}
80104e0e:	90                   	nop
80104e0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e12:	c9                   	leave  
80104e13:	c3                   	ret    

80104e14 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104e14:	f3 0f 1e fb          	endbr32 
80104e18:	55                   	push   %ebp
80104e19:	89 e5                	mov    %esp,%ebp
80104e1b:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104e1e:	83 ec 0c             	sub    $0xc,%esp
80104e21:	ff 75 08             	pushl  0x8(%ebp)
80104e24:	e8 c0 00 00 00       	call   80104ee9 <holding>
80104e29:	83 c4 10             	add    $0x10,%esp
80104e2c:	85 c0                	test   %eax,%eax
80104e2e:	75 0d                	jne    80104e3d <release+0x29>
    panic("release");
80104e30:	83 ec 0c             	sub    $0xc,%esp
80104e33:	68 f2 ac 10 80       	push   $0x8010acf2
80104e38:	e8 88 b7 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e40:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104e47:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104e51:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104e56:	8b 45 08             	mov    0x8(%ebp),%eax
80104e59:	8b 55 08             	mov    0x8(%ebp),%edx
80104e5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104e62:	e8 08 01 00 00       	call   80104f6f <popcli>
}
80104e67:	90                   	nop
80104e68:	c9                   	leave  
80104e69:	c3                   	ret    

80104e6a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104e6a:	f3 0f 1e fb          	endbr32 
80104e6e:	55                   	push   %ebp
80104e6f:	89 e5                	mov    %esp,%ebp
80104e71:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104e74:	8b 45 08             	mov    0x8(%ebp),%eax
80104e77:	83 e8 08             	sub    $0x8,%eax
80104e7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e7d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e84:	eb 38                	jmp    80104ebe <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104e86:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e8a:	74 53                	je     80104edf <getcallerpcs+0x75>
80104e8c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104e93:	76 4a                	jbe    80104edf <getcallerpcs+0x75>
80104e95:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104e99:	74 44                	je     80104edf <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104e9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ea8:	01 c2                	add    %eax,%edx
80104eaa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ead:	8b 40 04             	mov    0x4(%eax),%eax
80104eb0:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104eb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb5:	8b 00                	mov    (%eax),%eax
80104eb7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104eba:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ebe:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ec2:	7e c2                	jle    80104e86 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104ec4:	eb 19                	jmp    80104edf <getcallerpcs+0x75>
    pcs[i] = 0;
80104ec6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ec9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed3:	01 d0                	add    %edx,%eax
80104ed5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104edb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104edf:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ee3:	7e e1                	jle    80104ec6 <getcallerpcs+0x5c>
}
80104ee5:	90                   	nop
80104ee6:	90                   	nop
80104ee7:	c9                   	leave  
80104ee8:	c3                   	ret    

80104ee9 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104ee9:	f3 0f 1e fb          	endbr32 
80104eed:	55                   	push   %ebp
80104eee:	89 e5                	mov    %esp,%ebp
80104ef0:	53                   	push   %ebx
80104ef1:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef7:	8b 00                	mov    (%eax),%eax
80104ef9:	85 c0                	test   %eax,%eax
80104efb:	74 16                	je     80104f13 <holding+0x2a>
80104efd:	8b 45 08             	mov    0x8(%ebp),%eax
80104f00:	8b 58 08             	mov    0x8(%eax),%ebx
80104f03:	e8 25 ec ff ff       	call   80103b2d <mycpu>
80104f08:	39 c3                	cmp    %eax,%ebx
80104f0a:	75 07                	jne    80104f13 <holding+0x2a>
80104f0c:	b8 01 00 00 00       	mov    $0x1,%eax
80104f11:	eb 05                	jmp    80104f18 <holding+0x2f>
80104f13:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f18:	83 c4 04             	add    $0x4,%esp
80104f1b:	5b                   	pop    %ebx
80104f1c:	5d                   	pop    %ebp
80104f1d:	c3                   	ret    

80104f1e <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104f1e:	f3 0f 1e fb          	endbr32 
80104f22:	55                   	push   %ebp
80104f23:	89 e5                	mov    %esp,%ebp
80104f25:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104f28:	e8 17 fe ff ff       	call   80104d44 <readeflags>
80104f2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104f30:	e8 1f fe ff ff       	call   80104d54 <cli>
  if(mycpu()->ncli == 0)
80104f35:	e8 f3 eb ff ff       	call   80103b2d <mycpu>
80104f3a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f40:	85 c0                	test   %eax,%eax
80104f42:	75 14                	jne    80104f58 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104f44:	e8 e4 eb ff ff       	call   80103b2d <mycpu>
80104f49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f4c:	81 e2 00 02 00 00    	and    $0x200,%edx
80104f52:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104f58:	e8 d0 eb ff ff       	call   80103b2d <mycpu>
80104f5d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f63:	83 c2 01             	add    $0x1,%edx
80104f66:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104f6c:	90                   	nop
80104f6d:	c9                   	leave  
80104f6e:	c3                   	ret    

80104f6f <popcli>:

void
popcli(void)
{
80104f6f:	f3 0f 1e fb          	endbr32 
80104f73:	55                   	push   %ebp
80104f74:	89 e5                	mov    %esp,%ebp
80104f76:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104f79:	e8 c6 fd ff ff       	call   80104d44 <readeflags>
80104f7e:	25 00 02 00 00       	and    $0x200,%eax
80104f83:	85 c0                	test   %eax,%eax
80104f85:	74 0d                	je     80104f94 <popcli+0x25>
    panic("popcli - interruptible");
80104f87:	83 ec 0c             	sub    $0xc,%esp
80104f8a:	68 fa ac 10 80       	push   $0x8010acfa
80104f8f:	e8 31 b6 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104f94:	e8 94 eb ff ff       	call   80103b2d <mycpu>
80104f99:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f9f:	83 ea 01             	sub    $0x1,%edx
80104fa2:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104fa8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fae:	85 c0                	test   %eax,%eax
80104fb0:	79 0d                	jns    80104fbf <popcli+0x50>
    panic("popcli");
80104fb2:	83 ec 0c             	sub    $0xc,%esp
80104fb5:	68 11 ad 10 80       	push   $0x8010ad11
80104fba:	e8 06 b6 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104fbf:	e8 69 eb ff ff       	call   80103b2d <mycpu>
80104fc4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fca:	85 c0                	test   %eax,%eax
80104fcc:	75 14                	jne    80104fe2 <popcli+0x73>
80104fce:	e8 5a eb ff ff       	call   80103b2d <mycpu>
80104fd3:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104fd9:	85 c0                	test   %eax,%eax
80104fdb:	74 05                	je     80104fe2 <popcli+0x73>
    sti();
80104fdd:	e8 79 fd ff ff       	call   80104d5b <sti>
}
80104fe2:	90                   	nop
80104fe3:	c9                   	leave  
80104fe4:	c3                   	ret    

80104fe5 <stosb>:
{
80104fe5:	55                   	push   %ebp
80104fe6:	89 e5                	mov    %esp,%ebp
80104fe8:	57                   	push   %edi
80104fe9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104fea:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fed:	8b 55 10             	mov    0x10(%ebp),%edx
80104ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff3:	89 cb                	mov    %ecx,%ebx
80104ff5:	89 df                	mov    %ebx,%edi
80104ff7:	89 d1                	mov    %edx,%ecx
80104ff9:	fc                   	cld    
80104ffa:	f3 aa                	rep stos %al,%es:(%edi)
80104ffc:	89 ca                	mov    %ecx,%edx
80104ffe:	89 fb                	mov    %edi,%ebx
80105000:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105003:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105006:	90                   	nop
80105007:	5b                   	pop    %ebx
80105008:	5f                   	pop    %edi
80105009:	5d                   	pop    %ebp
8010500a:	c3                   	ret    

8010500b <stosl>:
{
8010500b:	55                   	push   %ebp
8010500c:	89 e5                	mov    %esp,%ebp
8010500e:	57                   	push   %edi
8010500f:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105010:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105013:	8b 55 10             	mov    0x10(%ebp),%edx
80105016:	8b 45 0c             	mov    0xc(%ebp),%eax
80105019:	89 cb                	mov    %ecx,%ebx
8010501b:	89 df                	mov    %ebx,%edi
8010501d:	89 d1                	mov    %edx,%ecx
8010501f:	fc                   	cld    
80105020:	f3 ab                	rep stos %eax,%es:(%edi)
80105022:	89 ca                	mov    %ecx,%edx
80105024:	89 fb                	mov    %edi,%ebx
80105026:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105029:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010502c:	90                   	nop
8010502d:	5b                   	pop    %ebx
8010502e:	5f                   	pop    %edi
8010502f:	5d                   	pop    %ebp
80105030:	c3                   	ret    

80105031 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105031:	f3 0f 1e fb          	endbr32 
80105035:	55                   	push   %ebp
80105036:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105038:	8b 45 08             	mov    0x8(%ebp),%eax
8010503b:	83 e0 03             	and    $0x3,%eax
8010503e:	85 c0                	test   %eax,%eax
80105040:	75 43                	jne    80105085 <memset+0x54>
80105042:	8b 45 10             	mov    0x10(%ebp),%eax
80105045:	83 e0 03             	and    $0x3,%eax
80105048:	85 c0                	test   %eax,%eax
8010504a:	75 39                	jne    80105085 <memset+0x54>
    c &= 0xFF;
8010504c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105053:	8b 45 10             	mov    0x10(%ebp),%eax
80105056:	c1 e8 02             	shr    $0x2,%eax
80105059:	89 c1                	mov    %eax,%ecx
8010505b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010505e:	c1 e0 18             	shl    $0x18,%eax
80105061:	89 c2                	mov    %eax,%edx
80105063:	8b 45 0c             	mov    0xc(%ebp),%eax
80105066:	c1 e0 10             	shl    $0x10,%eax
80105069:	09 c2                	or     %eax,%edx
8010506b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010506e:	c1 e0 08             	shl    $0x8,%eax
80105071:	09 d0                	or     %edx,%eax
80105073:	0b 45 0c             	or     0xc(%ebp),%eax
80105076:	51                   	push   %ecx
80105077:	50                   	push   %eax
80105078:	ff 75 08             	pushl  0x8(%ebp)
8010507b:	e8 8b ff ff ff       	call   8010500b <stosl>
80105080:	83 c4 0c             	add    $0xc,%esp
80105083:	eb 12                	jmp    80105097 <memset+0x66>
  } else
    stosb(dst, c, n);
80105085:	8b 45 10             	mov    0x10(%ebp),%eax
80105088:	50                   	push   %eax
80105089:	ff 75 0c             	pushl  0xc(%ebp)
8010508c:	ff 75 08             	pushl  0x8(%ebp)
8010508f:	e8 51 ff ff ff       	call   80104fe5 <stosb>
80105094:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105097:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010509a:	c9                   	leave  
8010509b:	c3                   	ret    

8010509c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010509c:	f3 0f 1e fb          	endbr32 
801050a0:	55                   	push   %ebp
801050a1:	89 e5                	mov    %esp,%ebp
801050a3:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801050a6:	8b 45 08             	mov    0x8(%ebp),%eax
801050a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801050ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801050af:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801050b2:	eb 30                	jmp    801050e4 <memcmp+0x48>
    if(*s1 != *s2)
801050b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050b7:	0f b6 10             	movzbl (%eax),%edx
801050ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050bd:	0f b6 00             	movzbl (%eax),%eax
801050c0:	38 c2                	cmp    %al,%dl
801050c2:	74 18                	je     801050dc <memcmp+0x40>
      return *s1 - *s2;
801050c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050c7:	0f b6 00             	movzbl (%eax),%eax
801050ca:	0f b6 d0             	movzbl %al,%edx
801050cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050d0:	0f b6 00             	movzbl (%eax),%eax
801050d3:	0f b6 c0             	movzbl %al,%eax
801050d6:	29 c2                	sub    %eax,%edx
801050d8:	89 d0                	mov    %edx,%eax
801050da:	eb 1a                	jmp    801050f6 <memcmp+0x5a>
    s1++, s2++;
801050dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050e0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801050e4:	8b 45 10             	mov    0x10(%ebp),%eax
801050e7:	8d 50 ff             	lea    -0x1(%eax),%edx
801050ea:	89 55 10             	mov    %edx,0x10(%ebp)
801050ed:	85 c0                	test   %eax,%eax
801050ef:	75 c3                	jne    801050b4 <memcmp+0x18>
  }

  return 0;
801050f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050f6:	c9                   	leave  
801050f7:	c3                   	ret    

801050f8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801050f8:	f3 0f 1e fb          	endbr32 
801050fc:	55                   	push   %ebp
801050fd:	89 e5                	mov    %esp,%ebp
801050ff:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105102:	8b 45 0c             	mov    0xc(%ebp),%eax
80105105:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105108:	8b 45 08             	mov    0x8(%ebp),%eax
8010510b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010510e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105111:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105114:	73 54                	jae    8010516a <memmove+0x72>
80105116:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105119:	8b 45 10             	mov    0x10(%ebp),%eax
8010511c:	01 d0                	add    %edx,%eax
8010511e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105121:	73 47                	jae    8010516a <memmove+0x72>
    s += n;
80105123:	8b 45 10             	mov    0x10(%ebp),%eax
80105126:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105129:	8b 45 10             	mov    0x10(%ebp),%eax
8010512c:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010512f:	eb 13                	jmp    80105144 <memmove+0x4c>
      *--d = *--s;
80105131:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105135:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105139:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010513c:	0f b6 10             	movzbl (%eax),%edx
8010513f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105142:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105144:	8b 45 10             	mov    0x10(%ebp),%eax
80105147:	8d 50 ff             	lea    -0x1(%eax),%edx
8010514a:	89 55 10             	mov    %edx,0x10(%ebp)
8010514d:	85 c0                	test   %eax,%eax
8010514f:	75 e0                	jne    80105131 <memmove+0x39>
  if(s < d && s + n > d){
80105151:	eb 24                	jmp    80105177 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105153:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105156:	8d 42 01             	lea    0x1(%edx),%eax
80105159:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010515c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010515f:	8d 48 01             	lea    0x1(%eax),%ecx
80105162:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105165:	0f b6 12             	movzbl (%edx),%edx
80105168:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010516a:	8b 45 10             	mov    0x10(%ebp),%eax
8010516d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105170:	89 55 10             	mov    %edx,0x10(%ebp)
80105173:	85 c0                	test   %eax,%eax
80105175:	75 dc                	jne    80105153 <memmove+0x5b>

  return dst;
80105177:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010517a:	c9                   	leave  
8010517b:	c3                   	ret    

8010517c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010517c:	f3 0f 1e fb          	endbr32 
80105180:	55                   	push   %ebp
80105181:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105183:	ff 75 10             	pushl  0x10(%ebp)
80105186:	ff 75 0c             	pushl  0xc(%ebp)
80105189:	ff 75 08             	pushl  0x8(%ebp)
8010518c:	e8 67 ff ff ff       	call   801050f8 <memmove>
80105191:	83 c4 0c             	add    $0xc,%esp
}
80105194:	c9                   	leave  
80105195:	c3                   	ret    

80105196 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105196:	f3 0f 1e fb          	endbr32 
8010519a:	55                   	push   %ebp
8010519b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010519d:	eb 0c                	jmp    801051ab <strncmp+0x15>
    n--, p++, q++;
8010519f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801051a7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801051ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051af:	74 1a                	je     801051cb <strncmp+0x35>
801051b1:	8b 45 08             	mov    0x8(%ebp),%eax
801051b4:	0f b6 00             	movzbl (%eax),%eax
801051b7:	84 c0                	test   %al,%al
801051b9:	74 10                	je     801051cb <strncmp+0x35>
801051bb:	8b 45 08             	mov    0x8(%ebp),%eax
801051be:	0f b6 10             	movzbl (%eax),%edx
801051c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c4:	0f b6 00             	movzbl (%eax),%eax
801051c7:	38 c2                	cmp    %al,%dl
801051c9:	74 d4                	je     8010519f <strncmp+0x9>
  if(n == 0)
801051cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051cf:	75 07                	jne    801051d8 <strncmp+0x42>
    return 0;
801051d1:	b8 00 00 00 00       	mov    $0x0,%eax
801051d6:	eb 16                	jmp    801051ee <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801051d8:	8b 45 08             	mov    0x8(%ebp),%eax
801051db:	0f b6 00             	movzbl (%eax),%eax
801051de:	0f b6 d0             	movzbl %al,%edx
801051e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801051e4:	0f b6 00             	movzbl (%eax),%eax
801051e7:	0f b6 c0             	movzbl %al,%eax
801051ea:	29 c2                	sub    %eax,%edx
801051ec:	89 d0                	mov    %edx,%eax
}
801051ee:	5d                   	pop    %ebp
801051ef:	c3                   	ret    

801051f0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801051f0:	f3 0f 1e fb          	endbr32 
801051f4:	55                   	push   %ebp
801051f5:	89 e5                	mov    %esp,%ebp
801051f7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051fa:	8b 45 08             	mov    0x8(%ebp),%eax
801051fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105200:	90                   	nop
80105201:	8b 45 10             	mov    0x10(%ebp),%eax
80105204:	8d 50 ff             	lea    -0x1(%eax),%edx
80105207:	89 55 10             	mov    %edx,0x10(%ebp)
8010520a:	85 c0                	test   %eax,%eax
8010520c:	7e 2c                	jle    8010523a <strncpy+0x4a>
8010520e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105211:	8d 42 01             	lea    0x1(%edx),%eax
80105214:	89 45 0c             	mov    %eax,0xc(%ebp)
80105217:	8b 45 08             	mov    0x8(%ebp),%eax
8010521a:	8d 48 01             	lea    0x1(%eax),%ecx
8010521d:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105220:	0f b6 12             	movzbl (%edx),%edx
80105223:	88 10                	mov    %dl,(%eax)
80105225:	0f b6 00             	movzbl (%eax),%eax
80105228:	84 c0                	test   %al,%al
8010522a:	75 d5                	jne    80105201 <strncpy+0x11>
    ;
  while(n-- > 0)
8010522c:	eb 0c                	jmp    8010523a <strncpy+0x4a>
    *s++ = 0;
8010522e:	8b 45 08             	mov    0x8(%ebp),%eax
80105231:	8d 50 01             	lea    0x1(%eax),%edx
80105234:	89 55 08             	mov    %edx,0x8(%ebp)
80105237:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010523a:	8b 45 10             	mov    0x10(%ebp),%eax
8010523d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105240:	89 55 10             	mov    %edx,0x10(%ebp)
80105243:	85 c0                	test   %eax,%eax
80105245:	7f e7                	jg     8010522e <strncpy+0x3e>
  return os;
80105247:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010524a:	c9                   	leave  
8010524b:	c3                   	ret    

8010524c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010524c:	f3 0f 1e fb          	endbr32 
80105250:	55                   	push   %ebp
80105251:	89 e5                	mov    %esp,%ebp
80105253:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105256:	8b 45 08             	mov    0x8(%ebp),%eax
80105259:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010525c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105260:	7f 05                	jg     80105267 <safestrcpy+0x1b>
    return os;
80105262:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105265:	eb 31                	jmp    80105298 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105267:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010526b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010526f:	7e 1e                	jle    8010528f <safestrcpy+0x43>
80105271:	8b 55 0c             	mov    0xc(%ebp),%edx
80105274:	8d 42 01             	lea    0x1(%edx),%eax
80105277:	89 45 0c             	mov    %eax,0xc(%ebp)
8010527a:	8b 45 08             	mov    0x8(%ebp),%eax
8010527d:	8d 48 01             	lea    0x1(%eax),%ecx
80105280:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105283:	0f b6 12             	movzbl (%edx),%edx
80105286:	88 10                	mov    %dl,(%eax)
80105288:	0f b6 00             	movzbl (%eax),%eax
8010528b:	84 c0                	test   %al,%al
8010528d:	75 d8                	jne    80105267 <safestrcpy+0x1b>
    ;
  *s = 0;
8010528f:	8b 45 08             	mov    0x8(%ebp),%eax
80105292:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105295:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105298:	c9                   	leave  
80105299:	c3                   	ret    

8010529a <strlen>:

int
strlen(const char *s)
{
8010529a:	f3 0f 1e fb          	endbr32 
8010529e:	55                   	push   %ebp
8010529f:	89 e5                	mov    %esp,%ebp
801052a1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801052a4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801052ab:	eb 04                	jmp    801052b1 <strlen+0x17>
801052ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052b4:	8b 45 08             	mov    0x8(%ebp),%eax
801052b7:	01 d0                	add    %edx,%eax
801052b9:	0f b6 00             	movzbl (%eax),%eax
801052bc:	84 c0                	test   %al,%al
801052be:	75 ed                	jne    801052ad <strlen+0x13>
    ;
  return n;
801052c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052c3:	c9                   	leave  
801052c4:	c3                   	ret    

801052c5 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801052c5:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801052c9:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801052cd:	55                   	push   %ebp
  pushl %ebx
801052ce:	53                   	push   %ebx
  pushl %esi
801052cf:	56                   	push   %esi
  pushl %edi
801052d0:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801052d1:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801052d3:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801052d5:	5f                   	pop    %edi
  popl %esi
801052d6:	5e                   	pop    %esi
  popl %ebx
801052d7:	5b                   	pop    %ebx
  popl %ebp
801052d8:	5d                   	pop    %ebp
  ret
801052d9:	c3                   	ret    

801052da <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801052da:	f3 0f 1e fb          	endbr32 
801052de:	55                   	push   %ebp
801052df:	89 e5                	mov    %esp,%ebp
801052e1:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801052e4:	e8 c0 e8 ff ff       	call   80103ba9 <myproc>
801052e9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801052ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ef:	8b 00                	mov    (%eax),%eax
801052f1:	39 45 08             	cmp    %eax,0x8(%ebp)
801052f4:	73 0f                	jae    80105305 <fetchint+0x2b>
801052f6:	8b 45 08             	mov    0x8(%ebp),%eax
801052f9:	8d 50 04             	lea    0x4(%eax),%edx
801052fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ff:	8b 00                	mov    (%eax),%eax
80105301:	39 c2                	cmp    %eax,%edx
80105303:	76 07                	jbe    8010530c <fetchint+0x32>
    return -1;
80105305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010530a:	eb 0f                	jmp    8010531b <fetchint+0x41>
  *ip = *(int*)(addr);
8010530c:	8b 45 08             	mov    0x8(%ebp),%eax
8010530f:	8b 10                	mov    (%eax),%edx
80105311:	8b 45 0c             	mov    0xc(%ebp),%eax
80105314:	89 10                	mov    %edx,(%eax)
  return 0;
80105316:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010531b:	c9                   	leave  
8010531c:	c3                   	ret    

8010531d <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010531d:	f3 0f 1e fb          	endbr32 
80105321:	55                   	push   %ebp
80105322:	89 e5                	mov    %esp,%ebp
80105324:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105327:	e8 7d e8 ff ff       	call   80103ba9 <myproc>
8010532c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010532f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105332:	8b 00                	mov    (%eax),%eax
80105334:	39 45 08             	cmp    %eax,0x8(%ebp)
80105337:	72 07                	jb     80105340 <fetchstr+0x23>
    return -1;
80105339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010533e:	eb 43                	jmp    80105383 <fetchstr+0x66>
  *pp = (char*)addr;
80105340:	8b 55 08             	mov    0x8(%ebp),%edx
80105343:	8b 45 0c             	mov    0xc(%ebp),%eax
80105346:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010534b:	8b 00                	mov    (%eax),%eax
8010534d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105350:	8b 45 0c             	mov    0xc(%ebp),%eax
80105353:	8b 00                	mov    (%eax),%eax
80105355:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105358:	eb 1c                	jmp    80105376 <fetchstr+0x59>
    if(*s == 0)
8010535a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010535d:	0f b6 00             	movzbl (%eax),%eax
80105360:	84 c0                	test   %al,%al
80105362:	75 0e                	jne    80105372 <fetchstr+0x55>
      return s - *pp;
80105364:	8b 45 0c             	mov    0xc(%ebp),%eax
80105367:	8b 00                	mov    (%eax),%eax
80105369:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010536c:	29 c2                	sub    %eax,%edx
8010536e:	89 d0                	mov    %edx,%eax
80105370:	eb 11                	jmp    80105383 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80105372:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105379:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010537c:	72 dc                	jb     8010535a <fetchstr+0x3d>
  }
  return -1;
8010537e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105383:	c9                   	leave  
80105384:	c3                   	ret    

80105385 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105385:	f3 0f 1e fb          	endbr32 
80105389:	55                   	push   %ebp
8010538a:	89 e5                	mov    %esp,%ebp
8010538c:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010538f:	e8 15 e8 ff ff       	call   80103ba9 <myproc>
80105394:	8b 40 18             	mov    0x18(%eax),%eax
80105397:	8b 40 44             	mov    0x44(%eax),%eax
8010539a:	8b 55 08             	mov    0x8(%ebp),%edx
8010539d:	c1 e2 02             	shl    $0x2,%edx
801053a0:	01 d0                	add    %edx,%eax
801053a2:	83 c0 04             	add    $0x4,%eax
801053a5:	83 ec 08             	sub    $0x8,%esp
801053a8:	ff 75 0c             	pushl  0xc(%ebp)
801053ab:	50                   	push   %eax
801053ac:	e8 29 ff ff ff       	call   801052da <fetchint>
801053b1:	83 c4 10             	add    $0x10,%esp
}
801053b4:	c9                   	leave  
801053b5:	c3                   	ret    

801053b6 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801053b6:	f3 0f 1e fb          	endbr32 
801053ba:	55                   	push   %ebp
801053bb:	89 e5                	mov    %esp,%ebp
801053bd:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801053c0:	e8 e4 e7 ff ff       	call   80103ba9 <myproc>
801053c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801053c8:	83 ec 08             	sub    $0x8,%esp
801053cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053ce:	50                   	push   %eax
801053cf:	ff 75 08             	pushl  0x8(%ebp)
801053d2:	e8 ae ff ff ff       	call   80105385 <argint>
801053d7:	83 c4 10             	add    $0x10,%esp
801053da:	85 c0                	test   %eax,%eax
801053dc:	79 07                	jns    801053e5 <argptr+0x2f>
    return -1;
801053de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e3:	eb 3b                	jmp    80105420 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801053e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053e9:	78 1f                	js     8010540a <argptr+0x54>
801053eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ee:	8b 00                	mov    (%eax),%eax
801053f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053f3:	39 d0                	cmp    %edx,%eax
801053f5:	76 13                	jbe    8010540a <argptr+0x54>
801053f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053fa:	89 c2                	mov    %eax,%edx
801053fc:	8b 45 10             	mov    0x10(%ebp),%eax
801053ff:	01 c2                	add    %eax,%edx
80105401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105404:	8b 00                	mov    (%eax),%eax
80105406:	39 c2                	cmp    %eax,%edx
80105408:	76 07                	jbe    80105411 <argptr+0x5b>
    return -1;
8010540a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010540f:	eb 0f                	jmp    80105420 <argptr+0x6a>
  *pp = (char*)i;
80105411:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105414:	89 c2                	mov    %eax,%edx
80105416:	8b 45 0c             	mov    0xc(%ebp),%eax
80105419:	89 10                	mov    %edx,(%eax)
  return 0;
8010541b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105420:	c9                   	leave  
80105421:	c3                   	ret    

80105422 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105422:	f3 0f 1e fb          	endbr32 
80105426:	55                   	push   %ebp
80105427:	89 e5                	mov    %esp,%ebp
80105429:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010542c:	83 ec 08             	sub    $0x8,%esp
8010542f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105432:	50                   	push   %eax
80105433:	ff 75 08             	pushl  0x8(%ebp)
80105436:	e8 4a ff ff ff       	call   80105385 <argint>
8010543b:	83 c4 10             	add    $0x10,%esp
8010543e:	85 c0                	test   %eax,%eax
80105440:	79 07                	jns    80105449 <argstr+0x27>
    return -1;
80105442:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105447:	eb 12                	jmp    8010545b <argstr+0x39>
  return fetchstr(addr, pp);
80105449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544c:	83 ec 08             	sub    $0x8,%esp
8010544f:	ff 75 0c             	pushl  0xc(%ebp)
80105452:	50                   	push   %eax
80105453:	e8 c5 fe ff ff       	call   8010531d <fetchstr>
80105458:	83 c4 10             	add    $0x10,%esp
}
8010545b:	c9                   	leave  
8010545c:	c3                   	ret    

8010545d <syscall>:
[SYS_yield] sys_yield,
};

void
syscall(void)
{
8010545d:	f3 0f 1e fb          	endbr32 
80105461:	55                   	push   %ebp
80105462:	89 e5                	mov    %esp,%ebp
80105464:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105467:	e8 3d e7 ff ff       	call   80103ba9 <myproc>
8010546c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010546f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105472:	8b 40 18             	mov    0x18(%eax),%eax
80105475:	8b 40 1c             	mov    0x1c(%eax),%eax
80105478:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010547b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010547f:	7e 2f                	jle    801054b0 <syscall+0x53>
80105481:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105484:	83 f8 18             	cmp    $0x18,%eax
80105487:	77 27                	ja     801054b0 <syscall+0x53>
80105489:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010548c:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105493:	85 c0                	test   %eax,%eax
80105495:	74 19                	je     801054b0 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105497:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010549a:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801054a1:	ff d0                	call   *%eax
801054a3:	89 c2                	mov    %eax,%edx
801054a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a8:	8b 40 18             	mov    0x18(%eax),%eax
801054ab:	89 50 1c             	mov    %edx,0x1c(%eax)
801054ae:	eb 2c                	jmp    801054dc <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801054b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b3:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801054b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b9:	8b 40 10             	mov    0x10(%eax),%eax
801054bc:	ff 75 f0             	pushl  -0x10(%ebp)
801054bf:	52                   	push   %edx
801054c0:	50                   	push   %eax
801054c1:	68 18 ad 10 80       	push   $0x8010ad18
801054c6:	e8 41 af ff ff       	call   8010040c <cprintf>
801054cb:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801054ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d1:	8b 40 18             	mov    0x18(%eax),%eax
801054d4:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801054db:	90                   	nop
801054dc:	90                   	nop
801054dd:	c9                   	leave  
801054de:	c3                   	ret    

801054df <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801054df:	f3 0f 1e fb          	endbr32 
801054e3:	55                   	push   %ebp
801054e4:	89 e5                	mov    %esp,%ebp
801054e6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801054e9:	83 ec 08             	sub    $0x8,%esp
801054ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054ef:	50                   	push   %eax
801054f0:	ff 75 08             	pushl  0x8(%ebp)
801054f3:	e8 8d fe ff ff       	call   80105385 <argint>
801054f8:	83 c4 10             	add    $0x10,%esp
801054fb:	85 c0                	test   %eax,%eax
801054fd:	79 07                	jns    80105506 <argfd+0x27>
    return -1;
801054ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105504:	eb 4f                	jmp    80105555 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105509:	85 c0                	test   %eax,%eax
8010550b:	78 20                	js     8010552d <argfd+0x4e>
8010550d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105510:	83 f8 0f             	cmp    $0xf,%eax
80105513:	7f 18                	jg     8010552d <argfd+0x4e>
80105515:	e8 8f e6 ff ff       	call   80103ba9 <myproc>
8010551a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010551d:	83 c2 08             	add    $0x8,%edx
80105520:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105524:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105527:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010552b:	75 07                	jne    80105534 <argfd+0x55>
    return -1;
8010552d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105532:	eb 21                	jmp    80105555 <argfd+0x76>
  if(pfd)
80105534:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105538:	74 08                	je     80105542 <argfd+0x63>
    *pfd = fd;
8010553a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010553d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105540:	89 10                	mov    %edx,(%eax)
  if(pf)
80105542:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105546:	74 08                	je     80105550 <argfd+0x71>
    *pf = f;
80105548:	8b 45 10             	mov    0x10(%ebp),%eax
8010554b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010554e:	89 10                	mov    %edx,(%eax)
  return 0;
80105550:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105555:	c9                   	leave  
80105556:	c3                   	ret    

80105557 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105557:	f3 0f 1e fb          	endbr32 
8010555b:	55                   	push   %ebp
8010555c:	89 e5                	mov    %esp,%ebp
8010555e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105561:	e8 43 e6 ff ff       	call   80103ba9 <myproc>
80105566:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105569:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105570:	eb 2a                	jmp    8010559c <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105572:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105575:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105578:	83 c2 08             	add    $0x8,%edx
8010557b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010557f:	85 c0                	test   %eax,%eax
80105581:	75 15                	jne    80105598 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105583:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105586:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105589:	8d 4a 08             	lea    0x8(%edx),%ecx
8010558c:	8b 55 08             	mov    0x8(%ebp),%edx
8010558f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105596:	eb 0f                	jmp    801055a7 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105598:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010559c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801055a0:	7e d0                	jle    80105572 <fdalloc+0x1b>
    }
  }
  return -1;
801055a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055a7:	c9                   	leave  
801055a8:	c3                   	ret    

801055a9 <sys_dup>:

int
sys_dup(void)
{
801055a9:	f3 0f 1e fb          	endbr32 
801055ad:	55                   	push   %ebp
801055ae:	89 e5                	mov    %esp,%ebp
801055b0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801055b3:	83 ec 04             	sub    $0x4,%esp
801055b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055b9:	50                   	push   %eax
801055ba:	6a 00                	push   $0x0
801055bc:	6a 00                	push   $0x0
801055be:	e8 1c ff ff ff       	call   801054df <argfd>
801055c3:	83 c4 10             	add    $0x10,%esp
801055c6:	85 c0                	test   %eax,%eax
801055c8:	79 07                	jns    801055d1 <sys_dup+0x28>
    return -1;
801055ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055cf:	eb 31                	jmp    80105602 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801055d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d4:	83 ec 0c             	sub    $0xc,%esp
801055d7:	50                   	push   %eax
801055d8:	e8 7a ff ff ff       	call   80105557 <fdalloc>
801055dd:	83 c4 10             	add    $0x10,%esp
801055e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055e7:	79 07                	jns    801055f0 <sys_dup+0x47>
    return -1;
801055e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ee:	eb 12                	jmp    80105602 <sys_dup+0x59>
  filedup(f);
801055f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055f3:	83 ec 0c             	sub    $0xc,%esp
801055f6:	50                   	push   %eax
801055f7:	e8 98 ba ff ff       	call   80101094 <filedup>
801055fc:	83 c4 10             	add    $0x10,%esp
  return fd;
801055ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105602:	c9                   	leave  
80105603:	c3                   	ret    

80105604 <sys_read>:

int
sys_read(void)
{
80105604:	f3 0f 1e fb          	endbr32 
80105608:	55                   	push   %ebp
80105609:	89 e5                	mov    %esp,%ebp
8010560b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010560e:	83 ec 04             	sub    $0x4,%esp
80105611:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105614:	50                   	push   %eax
80105615:	6a 00                	push   $0x0
80105617:	6a 00                	push   $0x0
80105619:	e8 c1 fe ff ff       	call   801054df <argfd>
8010561e:	83 c4 10             	add    $0x10,%esp
80105621:	85 c0                	test   %eax,%eax
80105623:	78 2e                	js     80105653 <sys_read+0x4f>
80105625:	83 ec 08             	sub    $0x8,%esp
80105628:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010562b:	50                   	push   %eax
8010562c:	6a 02                	push   $0x2
8010562e:	e8 52 fd ff ff       	call   80105385 <argint>
80105633:	83 c4 10             	add    $0x10,%esp
80105636:	85 c0                	test   %eax,%eax
80105638:	78 19                	js     80105653 <sys_read+0x4f>
8010563a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563d:	83 ec 04             	sub    $0x4,%esp
80105640:	50                   	push   %eax
80105641:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105644:	50                   	push   %eax
80105645:	6a 01                	push   $0x1
80105647:	e8 6a fd ff ff       	call   801053b6 <argptr>
8010564c:	83 c4 10             	add    $0x10,%esp
8010564f:	85 c0                	test   %eax,%eax
80105651:	79 07                	jns    8010565a <sys_read+0x56>
    return -1;
80105653:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105658:	eb 17                	jmp    80105671 <sys_read+0x6d>
  return fileread(f, p, n);
8010565a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010565d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105663:	83 ec 04             	sub    $0x4,%esp
80105666:	51                   	push   %ecx
80105667:	52                   	push   %edx
80105668:	50                   	push   %eax
80105669:	e8 c2 bb ff ff       	call   80101230 <fileread>
8010566e:	83 c4 10             	add    $0x10,%esp
}
80105671:	c9                   	leave  
80105672:	c3                   	ret    

80105673 <sys_write>:

int
sys_write(void)
{
80105673:	f3 0f 1e fb          	endbr32 
80105677:	55                   	push   %ebp
80105678:	89 e5                	mov    %esp,%ebp
8010567a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010567d:	83 ec 04             	sub    $0x4,%esp
80105680:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105683:	50                   	push   %eax
80105684:	6a 00                	push   $0x0
80105686:	6a 00                	push   $0x0
80105688:	e8 52 fe ff ff       	call   801054df <argfd>
8010568d:	83 c4 10             	add    $0x10,%esp
80105690:	85 c0                	test   %eax,%eax
80105692:	78 2e                	js     801056c2 <sys_write+0x4f>
80105694:	83 ec 08             	sub    $0x8,%esp
80105697:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010569a:	50                   	push   %eax
8010569b:	6a 02                	push   $0x2
8010569d:	e8 e3 fc ff ff       	call   80105385 <argint>
801056a2:	83 c4 10             	add    $0x10,%esp
801056a5:	85 c0                	test   %eax,%eax
801056a7:	78 19                	js     801056c2 <sys_write+0x4f>
801056a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ac:	83 ec 04             	sub    $0x4,%esp
801056af:	50                   	push   %eax
801056b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056b3:	50                   	push   %eax
801056b4:	6a 01                	push   $0x1
801056b6:	e8 fb fc ff ff       	call   801053b6 <argptr>
801056bb:	83 c4 10             	add    $0x10,%esp
801056be:	85 c0                	test   %eax,%eax
801056c0:	79 07                	jns    801056c9 <sys_write+0x56>
    return -1;
801056c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c7:	eb 17                	jmp    801056e0 <sys_write+0x6d>
  return filewrite(f, p, n);
801056c9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801056cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801056cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d2:	83 ec 04             	sub    $0x4,%esp
801056d5:	51                   	push   %ecx
801056d6:	52                   	push   %edx
801056d7:	50                   	push   %eax
801056d8:	e8 0f bc ff ff       	call   801012ec <filewrite>
801056dd:	83 c4 10             	add    $0x10,%esp
}
801056e0:	c9                   	leave  
801056e1:	c3                   	ret    

801056e2 <sys_close>:

int
sys_close(void)
{
801056e2:	f3 0f 1e fb          	endbr32 
801056e6:	55                   	push   %ebp
801056e7:	89 e5                	mov    %esp,%ebp
801056e9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801056ec:	83 ec 04             	sub    $0x4,%esp
801056ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056f2:	50                   	push   %eax
801056f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056f6:	50                   	push   %eax
801056f7:	6a 00                	push   $0x0
801056f9:	e8 e1 fd ff ff       	call   801054df <argfd>
801056fe:	83 c4 10             	add    $0x10,%esp
80105701:	85 c0                	test   %eax,%eax
80105703:	79 07                	jns    8010570c <sys_close+0x2a>
    return -1;
80105705:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010570a:	eb 27                	jmp    80105733 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
8010570c:	e8 98 e4 ff ff       	call   80103ba9 <myproc>
80105711:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105714:	83 c2 08             	add    $0x8,%edx
80105717:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010571e:	00 
  fileclose(f);
8010571f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105722:	83 ec 0c             	sub    $0xc,%esp
80105725:	50                   	push   %eax
80105726:	e8 be b9 ff ff       	call   801010e9 <fileclose>
8010572b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010572e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105733:	c9                   	leave  
80105734:	c3                   	ret    

80105735 <sys_fstat>:

int
sys_fstat(void)
{
80105735:	f3 0f 1e fb          	endbr32 
80105739:	55                   	push   %ebp
8010573a:	89 e5                	mov    %esp,%ebp
8010573c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010573f:	83 ec 04             	sub    $0x4,%esp
80105742:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105745:	50                   	push   %eax
80105746:	6a 00                	push   $0x0
80105748:	6a 00                	push   $0x0
8010574a:	e8 90 fd ff ff       	call   801054df <argfd>
8010574f:	83 c4 10             	add    $0x10,%esp
80105752:	85 c0                	test   %eax,%eax
80105754:	78 17                	js     8010576d <sys_fstat+0x38>
80105756:	83 ec 04             	sub    $0x4,%esp
80105759:	6a 14                	push   $0x14
8010575b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010575e:	50                   	push   %eax
8010575f:	6a 01                	push   $0x1
80105761:	e8 50 fc ff ff       	call   801053b6 <argptr>
80105766:	83 c4 10             	add    $0x10,%esp
80105769:	85 c0                	test   %eax,%eax
8010576b:	79 07                	jns    80105774 <sys_fstat+0x3f>
    return -1;
8010576d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105772:	eb 13                	jmp    80105787 <sys_fstat+0x52>
  return filestat(f, st);
80105774:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577a:	83 ec 08             	sub    $0x8,%esp
8010577d:	52                   	push   %edx
8010577e:	50                   	push   %eax
8010577f:	e8 51 ba ff ff       	call   801011d5 <filestat>
80105784:	83 c4 10             	add    $0x10,%esp
}
80105787:	c9                   	leave  
80105788:	c3                   	ret    

80105789 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105789:	f3 0f 1e fb          	endbr32 
8010578d:	55                   	push   %ebp
8010578e:	89 e5                	mov    %esp,%ebp
80105790:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105793:	83 ec 08             	sub    $0x8,%esp
80105796:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105799:	50                   	push   %eax
8010579a:	6a 00                	push   $0x0
8010579c:	e8 81 fc ff ff       	call   80105422 <argstr>
801057a1:	83 c4 10             	add    $0x10,%esp
801057a4:	85 c0                	test   %eax,%eax
801057a6:	78 15                	js     801057bd <sys_link+0x34>
801057a8:	83 ec 08             	sub    $0x8,%esp
801057ab:	8d 45 dc             	lea    -0x24(%ebp),%eax
801057ae:	50                   	push   %eax
801057af:	6a 01                	push   $0x1
801057b1:	e8 6c fc ff ff       	call   80105422 <argstr>
801057b6:	83 c4 10             	add    $0x10,%esp
801057b9:	85 c0                	test   %eax,%eax
801057bb:	79 0a                	jns    801057c7 <sys_link+0x3e>
    return -1;
801057bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c2:	e9 68 01 00 00       	jmp    8010592f <sys_link+0x1a6>

  begin_op();
801057c7:	e8 a5 d9 ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
801057cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801057cf:	83 ec 0c             	sub    $0xc,%esp
801057d2:	50                   	push   %eax
801057d3:	e8 0f ce ff ff       	call   801025e7 <namei>
801057d8:	83 c4 10             	add    $0x10,%esp
801057db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057e2:	75 0f                	jne    801057f3 <sys_link+0x6a>
    end_op();
801057e4:	e8 18 da ff ff       	call   80103201 <end_op>
    return -1;
801057e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ee:	e9 3c 01 00 00       	jmp    8010592f <sys_link+0x1a6>
  }

  ilock(ip);
801057f3:	83 ec 0c             	sub    $0xc,%esp
801057f6:	ff 75 f4             	pushl  -0xc(%ebp)
801057f9:	e8 7e c2 ff ff       	call   80101a7c <ilock>
801057fe:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105804:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105808:	66 83 f8 01          	cmp    $0x1,%ax
8010580c:	75 1d                	jne    8010582b <sys_link+0xa2>
    iunlockput(ip);
8010580e:	83 ec 0c             	sub    $0xc,%esp
80105811:	ff 75 f4             	pushl  -0xc(%ebp)
80105814:	e8 a0 c4 ff ff       	call   80101cb9 <iunlockput>
80105819:	83 c4 10             	add    $0x10,%esp
    end_op();
8010581c:	e8 e0 d9 ff ff       	call   80103201 <end_op>
    return -1;
80105821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105826:	e9 04 01 00 00       	jmp    8010592f <sys_link+0x1a6>
  }

  ip->nlink++;
8010582b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105832:	83 c0 01             	add    $0x1,%eax
80105835:	89 c2                	mov    %eax,%edx
80105837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010583e:	83 ec 0c             	sub    $0xc,%esp
80105841:	ff 75 f4             	pushl  -0xc(%ebp)
80105844:	e8 4a c0 ff ff       	call   80101893 <iupdate>
80105849:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010584c:	83 ec 0c             	sub    $0xc,%esp
8010584f:	ff 75 f4             	pushl  -0xc(%ebp)
80105852:	e8 3c c3 ff ff       	call   80101b93 <iunlock>
80105857:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010585a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010585d:	83 ec 08             	sub    $0x8,%esp
80105860:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105863:	52                   	push   %edx
80105864:	50                   	push   %eax
80105865:	e8 9d cd ff ff       	call   80102607 <nameiparent>
8010586a:	83 c4 10             	add    $0x10,%esp
8010586d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105870:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105874:	74 71                	je     801058e7 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105876:	83 ec 0c             	sub    $0xc,%esp
80105879:	ff 75 f0             	pushl  -0x10(%ebp)
8010587c:	e8 fb c1 ff ff       	call   80101a7c <ilock>
80105881:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105884:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105887:	8b 10                	mov    (%eax),%edx
80105889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588c:	8b 00                	mov    (%eax),%eax
8010588e:	39 c2                	cmp    %eax,%edx
80105890:	75 1d                	jne    801058af <sys_link+0x126>
80105892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105895:	8b 40 04             	mov    0x4(%eax),%eax
80105898:	83 ec 04             	sub    $0x4,%esp
8010589b:	50                   	push   %eax
8010589c:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010589f:	50                   	push   %eax
801058a0:	ff 75 f0             	pushl  -0x10(%ebp)
801058a3:	e8 9c ca ff ff       	call   80102344 <dirlink>
801058a8:	83 c4 10             	add    $0x10,%esp
801058ab:	85 c0                	test   %eax,%eax
801058ad:	79 10                	jns    801058bf <sys_link+0x136>
    iunlockput(dp);
801058af:	83 ec 0c             	sub    $0xc,%esp
801058b2:	ff 75 f0             	pushl  -0x10(%ebp)
801058b5:	e8 ff c3 ff ff       	call   80101cb9 <iunlockput>
801058ba:	83 c4 10             	add    $0x10,%esp
    goto bad;
801058bd:	eb 29                	jmp    801058e8 <sys_link+0x15f>
  }
  iunlockput(dp);
801058bf:	83 ec 0c             	sub    $0xc,%esp
801058c2:	ff 75 f0             	pushl  -0x10(%ebp)
801058c5:	e8 ef c3 ff ff       	call   80101cb9 <iunlockput>
801058ca:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801058cd:	83 ec 0c             	sub    $0xc,%esp
801058d0:	ff 75 f4             	pushl  -0xc(%ebp)
801058d3:	e8 0d c3 ff ff       	call   80101be5 <iput>
801058d8:	83 c4 10             	add    $0x10,%esp

  end_op();
801058db:	e8 21 d9 ff ff       	call   80103201 <end_op>

  return 0;
801058e0:	b8 00 00 00 00       	mov    $0x0,%eax
801058e5:	eb 48                	jmp    8010592f <sys_link+0x1a6>
    goto bad;
801058e7:	90                   	nop

bad:
  ilock(ip);
801058e8:	83 ec 0c             	sub    $0xc,%esp
801058eb:	ff 75 f4             	pushl  -0xc(%ebp)
801058ee:	e8 89 c1 ff ff       	call   80101a7c <ilock>
801058f3:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801058f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058fd:	83 e8 01             	sub    $0x1,%eax
80105900:	89 c2                	mov    %eax,%edx
80105902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105905:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105909:	83 ec 0c             	sub    $0xc,%esp
8010590c:	ff 75 f4             	pushl  -0xc(%ebp)
8010590f:	e8 7f bf ff ff       	call   80101893 <iupdate>
80105914:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105917:	83 ec 0c             	sub    $0xc,%esp
8010591a:	ff 75 f4             	pushl  -0xc(%ebp)
8010591d:	e8 97 c3 ff ff       	call   80101cb9 <iunlockput>
80105922:	83 c4 10             	add    $0x10,%esp
  end_op();
80105925:	e8 d7 d8 ff ff       	call   80103201 <end_op>
  return -1;
8010592a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010592f:	c9                   	leave  
80105930:	c3                   	ret    

80105931 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105931:	f3 0f 1e fb          	endbr32 
80105935:	55                   	push   %ebp
80105936:	89 e5                	mov    %esp,%ebp
80105938:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010593b:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105942:	eb 40                	jmp    80105984 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105947:	6a 10                	push   $0x10
80105949:	50                   	push   %eax
8010594a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010594d:	50                   	push   %eax
8010594e:	ff 75 08             	pushl  0x8(%ebp)
80105951:	e8 2e c6 ff ff       	call   80101f84 <readi>
80105956:	83 c4 10             	add    $0x10,%esp
80105959:	83 f8 10             	cmp    $0x10,%eax
8010595c:	74 0d                	je     8010596b <isdirempty+0x3a>
      panic("isdirempty: readi");
8010595e:	83 ec 0c             	sub    $0xc,%esp
80105961:	68 34 ad 10 80       	push   $0x8010ad34
80105966:	e8 5a ac ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
8010596b:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010596f:	66 85 c0             	test   %ax,%ax
80105972:	74 07                	je     8010597b <isdirempty+0x4a>
      return 0;
80105974:	b8 00 00 00 00       	mov    $0x0,%eax
80105979:	eb 1b                	jmp    80105996 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010597b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597e:	83 c0 10             	add    $0x10,%eax
80105981:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105984:	8b 45 08             	mov    0x8(%ebp),%eax
80105987:	8b 50 58             	mov    0x58(%eax),%edx
8010598a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598d:	39 c2                	cmp    %eax,%edx
8010598f:	77 b3                	ja     80105944 <isdirempty+0x13>
  }
  return 1;
80105991:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105996:	c9                   	leave  
80105997:	c3                   	ret    

80105998 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105998:	f3 0f 1e fb          	endbr32 
8010599c:	55                   	push   %ebp
8010599d:	89 e5                	mov    %esp,%ebp
8010599f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801059a2:	83 ec 08             	sub    $0x8,%esp
801059a5:	8d 45 cc             	lea    -0x34(%ebp),%eax
801059a8:	50                   	push   %eax
801059a9:	6a 00                	push   $0x0
801059ab:	e8 72 fa ff ff       	call   80105422 <argstr>
801059b0:	83 c4 10             	add    $0x10,%esp
801059b3:	85 c0                	test   %eax,%eax
801059b5:	79 0a                	jns    801059c1 <sys_unlink+0x29>
    return -1;
801059b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059bc:	e9 bf 01 00 00       	jmp    80105b80 <sys_unlink+0x1e8>

  begin_op();
801059c1:	e8 ab d7 ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801059c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801059c9:	83 ec 08             	sub    $0x8,%esp
801059cc:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801059cf:	52                   	push   %edx
801059d0:	50                   	push   %eax
801059d1:	e8 31 cc ff ff       	call   80102607 <nameiparent>
801059d6:	83 c4 10             	add    $0x10,%esp
801059d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059e0:	75 0f                	jne    801059f1 <sys_unlink+0x59>
    end_op();
801059e2:	e8 1a d8 ff ff       	call   80103201 <end_op>
    return -1;
801059e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ec:	e9 8f 01 00 00       	jmp    80105b80 <sys_unlink+0x1e8>
  }

  ilock(dp);
801059f1:	83 ec 0c             	sub    $0xc,%esp
801059f4:	ff 75 f4             	pushl  -0xc(%ebp)
801059f7:	e8 80 c0 ff ff       	call   80101a7c <ilock>
801059fc:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801059ff:	83 ec 08             	sub    $0x8,%esp
80105a02:	68 46 ad 10 80       	push   $0x8010ad46
80105a07:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a0a:	50                   	push   %eax
80105a0b:	e8 57 c8 ff ff       	call   80102267 <namecmp>
80105a10:	83 c4 10             	add    $0x10,%esp
80105a13:	85 c0                	test   %eax,%eax
80105a15:	0f 84 49 01 00 00    	je     80105b64 <sys_unlink+0x1cc>
80105a1b:	83 ec 08             	sub    $0x8,%esp
80105a1e:	68 48 ad 10 80       	push   $0x8010ad48
80105a23:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a26:	50                   	push   %eax
80105a27:	e8 3b c8 ff ff       	call   80102267 <namecmp>
80105a2c:	83 c4 10             	add    $0x10,%esp
80105a2f:	85 c0                	test   %eax,%eax
80105a31:	0f 84 2d 01 00 00    	je     80105b64 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105a37:	83 ec 04             	sub    $0x4,%esp
80105a3a:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105a3d:	50                   	push   %eax
80105a3e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a41:	50                   	push   %eax
80105a42:	ff 75 f4             	pushl  -0xc(%ebp)
80105a45:	e8 3c c8 ff ff       	call   80102286 <dirlookup>
80105a4a:	83 c4 10             	add    $0x10,%esp
80105a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a54:	0f 84 0d 01 00 00    	je     80105b67 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105a5a:	83 ec 0c             	sub    $0xc,%esp
80105a5d:	ff 75 f0             	pushl  -0x10(%ebp)
80105a60:	e8 17 c0 ff ff       	call   80101a7c <ilock>
80105a65:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a6f:	66 85 c0             	test   %ax,%ax
80105a72:	7f 0d                	jg     80105a81 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105a74:	83 ec 0c             	sub    $0xc,%esp
80105a77:	68 4b ad 10 80       	push   $0x8010ad4b
80105a7c:	e8 44 ab ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a84:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a88:	66 83 f8 01          	cmp    $0x1,%ax
80105a8c:	75 25                	jne    80105ab3 <sys_unlink+0x11b>
80105a8e:	83 ec 0c             	sub    $0xc,%esp
80105a91:	ff 75 f0             	pushl  -0x10(%ebp)
80105a94:	e8 98 fe ff ff       	call   80105931 <isdirempty>
80105a99:	83 c4 10             	add    $0x10,%esp
80105a9c:	85 c0                	test   %eax,%eax
80105a9e:	75 13                	jne    80105ab3 <sys_unlink+0x11b>
    iunlockput(ip);
80105aa0:	83 ec 0c             	sub    $0xc,%esp
80105aa3:	ff 75 f0             	pushl  -0x10(%ebp)
80105aa6:	e8 0e c2 ff ff       	call   80101cb9 <iunlockput>
80105aab:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105aae:	e9 b5 00 00 00       	jmp    80105b68 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105ab3:	83 ec 04             	sub    $0x4,%esp
80105ab6:	6a 10                	push   $0x10
80105ab8:	6a 00                	push   $0x0
80105aba:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105abd:	50                   	push   %eax
80105abe:	e8 6e f5 ff ff       	call   80105031 <memset>
80105ac3:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ac6:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ac9:	6a 10                	push   $0x10
80105acb:	50                   	push   %eax
80105acc:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105acf:	50                   	push   %eax
80105ad0:	ff 75 f4             	pushl  -0xc(%ebp)
80105ad3:	e8 05 c6 ff ff       	call   801020dd <writei>
80105ad8:	83 c4 10             	add    $0x10,%esp
80105adb:	83 f8 10             	cmp    $0x10,%eax
80105ade:	74 0d                	je     80105aed <sys_unlink+0x155>
    panic("unlink: writei");
80105ae0:	83 ec 0c             	sub    $0xc,%esp
80105ae3:	68 5d ad 10 80       	push   $0x8010ad5d
80105ae8:	e8 d8 aa ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105af4:	66 83 f8 01          	cmp    $0x1,%ax
80105af8:	75 21                	jne    80105b1b <sys_unlink+0x183>
    dp->nlink--;
80105afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b01:	83 e8 01             	sub    $0x1,%eax
80105b04:	89 c2                	mov    %eax,%edx
80105b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b09:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105b0d:	83 ec 0c             	sub    $0xc,%esp
80105b10:	ff 75 f4             	pushl  -0xc(%ebp)
80105b13:	e8 7b bd ff ff       	call   80101893 <iupdate>
80105b18:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105b1b:	83 ec 0c             	sub    $0xc,%esp
80105b1e:	ff 75 f4             	pushl  -0xc(%ebp)
80105b21:	e8 93 c1 ff ff       	call   80101cb9 <iunlockput>
80105b26:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b30:	83 e8 01             	sub    $0x1,%eax
80105b33:	89 c2                	mov    %eax,%edx
80105b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b38:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b3c:	83 ec 0c             	sub    $0xc,%esp
80105b3f:	ff 75 f0             	pushl  -0x10(%ebp)
80105b42:	e8 4c bd ff ff       	call   80101893 <iupdate>
80105b47:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b4a:	83 ec 0c             	sub    $0xc,%esp
80105b4d:	ff 75 f0             	pushl  -0x10(%ebp)
80105b50:	e8 64 c1 ff ff       	call   80101cb9 <iunlockput>
80105b55:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b58:	e8 a4 d6 ff ff       	call   80103201 <end_op>

  return 0;
80105b5d:	b8 00 00 00 00       	mov    $0x0,%eax
80105b62:	eb 1c                	jmp    80105b80 <sys_unlink+0x1e8>
    goto bad;
80105b64:	90                   	nop
80105b65:	eb 01                	jmp    80105b68 <sys_unlink+0x1d0>
    goto bad;
80105b67:	90                   	nop

bad:
  iunlockput(dp);
80105b68:	83 ec 0c             	sub    $0xc,%esp
80105b6b:	ff 75 f4             	pushl  -0xc(%ebp)
80105b6e:	e8 46 c1 ff ff       	call   80101cb9 <iunlockput>
80105b73:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b76:	e8 86 d6 ff ff       	call   80103201 <end_op>
  return -1;
80105b7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b80:	c9                   	leave  
80105b81:	c3                   	ret    

80105b82 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b82:	f3 0f 1e fb          	endbr32 
80105b86:	55                   	push   %ebp
80105b87:	89 e5                	mov    %esp,%ebp
80105b89:	83 ec 38             	sub    $0x38,%esp
80105b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105b8f:	8b 55 10             	mov    0x10(%ebp),%edx
80105b92:	8b 45 14             	mov    0x14(%ebp),%eax
80105b95:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105b99:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105b9d:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105ba1:	83 ec 08             	sub    $0x8,%esp
80105ba4:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ba7:	50                   	push   %eax
80105ba8:	ff 75 08             	pushl  0x8(%ebp)
80105bab:	e8 57 ca ff ff       	call   80102607 <nameiparent>
80105bb0:	83 c4 10             	add    $0x10,%esp
80105bb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bba:	75 0a                	jne    80105bc6 <create+0x44>
    return 0;
80105bbc:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc1:	e9 90 01 00 00       	jmp    80105d56 <create+0x1d4>
  ilock(dp);
80105bc6:	83 ec 0c             	sub    $0xc,%esp
80105bc9:	ff 75 f4             	pushl  -0xc(%ebp)
80105bcc:	e8 ab be ff ff       	call   80101a7c <ilock>
80105bd1:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105bd4:	83 ec 04             	sub    $0x4,%esp
80105bd7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bda:	50                   	push   %eax
80105bdb:	8d 45 de             	lea    -0x22(%ebp),%eax
80105bde:	50                   	push   %eax
80105bdf:	ff 75 f4             	pushl  -0xc(%ebp)
80105be2:	e8 9f c6 ff ff       	call   80102286 <dirlookup>
80105be7:	83 c4 10             	add    $0x10,%esp
80105bea:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bf1:	74 50                	je     80105c43 <create+0xc1>
    iunlockput(dp);
80105bf3:	83 ec 0c             	sub    $0xc,%esp
80105bf6:	ff 75 f4             	pushl  -0xc(%ebp)
80105bf9:	e8 bb c0 ff ff       	call   80101cb9 <iunlockput>
80105bfe:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105c01:	83 ec 0c             	sub    $0xc,%esp
80105c04:	ff 75 f0             	pushl  -0x10(%ebp)
80105c07:	e8 70 be ff ff       	call   80101a7c <ilock>
80105c0c:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105c0f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105c14:	75 15                	jne    80105c2b <create+0xa9>
80105c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c19:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c1d:	66 83 f8 02          	cmp    $0x2,%ax
80105c21:	75 08                	jne    80105c2b <create+0xa9>
      return ip;
80105c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c26:	e9 2b 01 00 00       	jmp    80105d56 <create+0x1d4>
    iunlockput(ip);
80105c2b:	83 ec 0c             	sub    $0xc,%esp
80105c2e:	ff 75 f0             	pushl  -0x10(%ebp)
80105c31:	e8 83 c0 ff ff       	call   80101cb9 <iunlockput>
80105c36:	83 c4 10             	add    $0x10,%esp
    return 0;
80105c39:	b8 00 00 00 00       	mov    $0x0,%eax
80105c3e:	e9 13 01 00 00       	jmp    80105d56 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105c43:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4a:	8b 00                	mov    (%eax),%eax
80105c4c:	83 ec 08             	sub    $0x8,%esp
80105c4f:	52                   	push   %edx
80105c50:	50                   	push   %eax
80105c51:	e8 62 bb ff ff       	call   801017b8 <ialloc>
80105c56:	83 c4 10             	add    $0x10,%esp
80105c59:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c60:	75 0d                	jne    80105c6f <create+0xed>
    panic("create: ialloc");
80105c62:	83 ec 0c             	sub    $0xc,%esp
80105c65:	68 6c ad 10 80       	push   $0x8010ad6c
80105c6a:	e8 56 a9 ff ff       	call   801005c5 <panic>

  ilock(ip);
80105c6f:	83 ec 0c             	sub    $0xc,%esp
80105c72:	ff 75 f0             	pushl  -0x10(%ebp)
80105c75:	e8 02 be ff ff       	call   80101a7c <ilock>
80105c7a:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c80:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105c84:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8b:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105c8f:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c96:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105c9c:	83 ec 0c             	sub    $0xc,%esp
80105c9f:	ff 75 f0             	pushl  -0x10(%ebp)
80105ca2:	e8 ec bb ff ff       	call   80101893 <iupdate>
80105ca7:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105caa:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105caf:	75 6a                	jne    80105d1b <create+0x199>
    dp->nlink++;  // for ".."
80105cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cb8:	83 c0 01             	add    $0x1,%eax
80105cbb:	89 c2                	mov    %eax,%edx
80105cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc0:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105cc4:	83 ec 0c             	sub    $0xc,%esp
80105cc7:	ff 75 f4             	pushl  -0xc(%ebp)
80105cca:	e8 c4 bb ff ff       	call   80101893 <iupdate>
80105ccf:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd5:	8b 40 04             	mov    0x4(%eax),%eax
80105cd8:	83 ec 04             	sub    $0x4,%esp
80105cdb:	50                   	push   %eax
80105cdc:	68 46 ad 10 80       	push   $0x8010ad46
80105ce1:	ff 75 f0             	pushl  -0x10(%ebp)
80105ce4:	e8 5b c6 ff ff       	call   80102344 <dirlink>
80105ce9:	83 c4 10             	add    $0x10,%esp
80105cec:	85 c0                	test   %eax,%eax
80105cee:	78 1e                	js     80105d0e <create+0x18c>
80105cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf3:	8b 40 04             	mov    0x4(%eax),%eax
80105cf6:	83 ec 04             	sub    $0x4,%esp
80105cf9:	50                   	push   %eax
80105cfa:	68 48 ad 10 80       	push   $0x8010ad48
80105cff:	ff 75 f0             	pushl  -0x10(%ebp)
80105d02:	e8 3d c6 ff ff       	call   80102344 <dirlink>
80105d07:	83 c4 10             	add    $0x10,%esp
80105d0a:	85 c0                	test   %eax,%eax
80105d0c:	79 0d                	jns    80105d1b <create+0x199>
      panic("create dots");
80105d0e:	83 ec 0c             	sub    $0xc,%esp
80105d11:	68 7b ad 10 80       	push   $0x8010ad7b
80105d16:	e8 aa a8 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1e:	8b 40 04             	mov    0x4(%eax),%eax
80105d21:	83 ec 04             	sub    $0x4,%esp
80105d24:	50                   	push   %eax
80105d25:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d28:	50                   	push   %eax
80105d29:	ff 75 f4             	pushl  -0xc(%ebp)
80105d2c:	e8 13 c6 ff ff       	call   80102344 <dirlink>
80105d31:	83 c4 10             	add    $0x10,%esp
80105d34:	85 c0                	test   %eax,%eax
80105d36:	79 0d                	jns    80105d45 <create+0x1c3>
    panic("create: dirlink");
80105d38:	83 ec 0c             	sub    $0xc,%esp
80105d3b:	68 87 ad 10 80       	push   $0x8010ad87
80105d40:	e8 80 a8 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105d45:	83 ec 0c             	sub    $0xc,%esp
80105d48:	ff 75 f4             	pushl  -0xc(%ebp)
80105d4b:	e8 69 bf ff ff       	call   80101cb9 <iunlockput>
80105d50:	83 c4 10             	add    $0x10,%esp

  return ip;
80105d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105d56:	c9                   	leave  
80105d57:	c3                   	ret    

80105d58 <sys_open>:

int
sys_open(void)
{
80105d58:	f3 0f 1e fb          	endbr32 
80105d5c:	55                   	push   %ebp
80105d5d:	89 e5                	mov    %esp,%ebp
80105d5f:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105d62:	83 ec 08             	sub    $0x8,%esp
80105d65:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d68:	50                   	push   %eax
80105d69:	6a 00                	push   $0x0
80105d6b:	e8 b2 f6 ff ff       	call   80105422 <argstr>
80105d70:	83 c4 10             	add    $0x10,%esp
80105d73:	85 c0                	test   %eax,%eax
80105d75:	78 15                	js     80105d8c <sys_open+0x34>
80105d77:	83 ec 08             	sub    $0x8,%esp
80105d7a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d7d:	50                   	push   %eax
80105d7e:	6a 01                	push   $0x1
80105d80:	e8 00 f6 ff ff       	call   80105385 <argint>
80105d85:	83 c4 10             	add    $0x10,%esp
80105d88:	85 c0                	test   %eax,%eax
80105d8a:	79 0a                	jns    80105d96 <sys_open+0x3e>
    return -1;
80105d8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d91:	e9 61 01 00 00       	jmp    80105ef7 <sys_open+0x19f>

  begin_op();
80105d96:	e8 d6 d3 ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
80105d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d9e:	25 00 02 00 00       	and    $0x200,%eax
80105da3:	85 c0                	test   %eax,%eax
80105da5:	74 2a                	je     80105dd1 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105da7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105daa:	6a 00                	push   $0x0
80105dac:	6a 00                	push   $0x0
80105dae:	6a 02                	push   $0x2
80105db0:	50                   	push   %eax
80105db1:	e8 cc fd ff ff       	call   80105b82 <create>
80105db6:	83 c4 10             	add    $0x10,%esp
80105db9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105dbc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dc0:	75 75                	jne    80105e37 <sys_open+0xdf>
      end_op();
80105dc2:	e8 3a d4 ff ff       	call   80103201 <end_op>
      return -1;
80105dc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dcc:	e9 26 01 00 00       	jmp    80105ef7 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105dd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105dd4:	83 ec 0c             	sub    $0xc,%esp
80105dd7:	50                   	push   %eax
80105dd8:	e8 0a c8 ff ff       	call   801025e7 <namei>
80105ddd:	83 c4 10             	add    $0x10,%esp
80105de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105de3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105de7:	75 0f                	jne    80105df8 <sys_open+0xa0>
      end_op();
80105de9:	e8 13 d4 ff ff       	call   80103201 <end_op>
      return -1;
80105dee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df3:	e9 ff 00 00 00       	jmp    80105ef7 <sys_open+0x19f>
    }
    ilock(ip);
80105df8:	83 ec 0c             	sub    $0xc,%esp
80105dfb:	ff 75 f4             	pushl  -0xc(%ebp)
80105dfe:	e8 79 bc ff ff       	call   80101a7c <ilock>
80105e03:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e09:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e0d:	66 83 f8 01          	cmp    $0x1,%ax
80105e11:	75 24                	jne    80105e37 <sys_open+0xdf>
80105e13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e16:	85 c0                	test   %eax,%eax
80105e18:	74 1d                	je     80105e37 <sys_open+0xdf>
      iunlockput(ip);
80105e1a:	83 ec 0c             	sub    $0xc,%esp
80105e1d:	ff 75 f4             	pushl  -0xc(%ebp)
80105e20:	e8 94 be ff ff       	call   80101cb9 <iunlockput>
80105e25:	83 c4 10             	add    $0x10,%esp
      end_op();
80105e28:	e8 d4 d3 ff ff       	call   80103201 <end_op>
      return -1;
80105e2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e32:	e9 c0 00 00 00       	jmp    80105ef7 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105e37:	e8 e7 b1 ff ff       	call   80101023 <filealloc>
80105e3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e43:	74 17                	je     80105e5c <sys_open+0x104>
80105e45:	83 ec 0c             	sub    $0xc,%esp
80105e48:	ff 75 f0             	pushl  -0x10(%ebp)
80105e4b:	e8 07 f7 ff ff       	call   80105557 <fdalloc>
80105e50:	83 c4 10             	add    $0x10,%esp
80105e53:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105e56:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105e5a:	79 2e                	jns    80105e8a <sys_open+0x132>
    if(f)
80105e5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e60:	74 0e                	je     80105e70 <sys_open+0x118>
      fileclose(f);
80105e62:	83 ec 0c             	sub    $0xc,%esp
80105e65:	ff 75 f0             	pushl  -0x10(%ebp)
80105e68:	e8 7c b2 ff ff       	call   801010e9 <fileclose>
80105e6d:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105e70:	83 ec 0c             	sub    $0xc,%esp
80105e73:	ff 75 f4             	pushl  -0xc(%ebp)
80105e76:	e8 3e be ff ff       	call   80101cb9 <iunlockput>
80105e7b:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e7e:	e8 7e d3 ff ff       	call   80103201 <end_op>
    return -1;
80105e83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e88:	eb 6d                	jmp    80105ef7 <sys_open+0x19f>
  }
  iunlock(ip);
80105e8a:	83 ec 0c             	sub    $0xc,%esp
80105e8d:	ff 75 f4             	pushl  -0xc(%ebp)
80105e90:	e8 fe bc ff ff       	call   80101b93 <iunlock>
80105e95:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e98:	e8 64 d3 ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
80105e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105eac:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105eb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ebc:	83 e0 01             	and    $0x1,%eax
80105ebf:	85 c0                	test   %eax,%eax
80105ec1:	0f 94 c0             	sete   %al
80105ec4:	89 c2                	mov    %eax,%edx
80105ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec9:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ecf:	83 e0 01             	and    $0x1,%eax
80105ed2:	85 c0                	test   %eax,%eax
80105ed4:	75 0a                	jne    80105ee0 <sys_open+0x188>
80105ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ed9:	83 e0 02             	and    $0x2,%eax
80105edc:	85 c0                	test   %eax,%eax
80105ede:	74 07                	je     80105ee7 <sys_open+0x18f>
80105ee0:	b8 01 00 00 00       	mov    $0x1,%eax
80105ee5:	eb 05                	jmp    80105eec <sys_open+0x194>
80105ee7:	b8 00 00 00 00       	mov    $0x0,%eax
80105eec:	89 c2                	mov    %eax,%edx
80105eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef1:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105ef4:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105ef7:	c9                   	leave  
80105ef8:	c3                   	ret    

80105ef9 <sys_mkdir>:

int
sys_mkdir(void)
{
80105ef9:	f3 0f 1e fb          	endbr32 
80105efd:	55                   	push   %ebp
80105efe:	89 e5                	mov    %esp,%ebp
80105f00:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105f03:	e8 69 d2 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105f08:	83 ec 08             	sub    $0x8,%esp
80105f0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f0e:	50                   	push   %eax
80105f0f:	6a 00                	push   $0x0
80105f11:	e8 0c f5 ff ff       	call   80105422 <argstr>
80105f16:	83 c4 10             	add    $0x10,%esp
80105f19:	85 c0                	test   %eax,%eax
80105f1b:	78 1b                	js     80105f38 <sys_mkdir+0x3f>
80105f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f20:	6a 00                	push   $0x0
80105f22:	6a 00                	push   $0x0
80105f24:	6a 01                	push   $0x1
80105f26:	50                   	push   %eax
80105f27:	e8 56 fc ff ff       	call   80105b82 <create>
80105f2c:	83 c4 10             	add    $0x10,%esp
80105f2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f36:	75 0c                	jne    80105f44 <sys_mkdir+0x4b>
    end_op();
80105f38:	e8 c4 d2 ff ff       	call   80103201 <end_op>
    return -1;
80105f3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f42:	eb 18                	jmp    80105f5c <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105f44:	83 ec 0c             	sub    $0xc,%esp
80105f47:	ff 75 f4             	pushl  -0xc(%ebp)
80105f4a:	e8 6a bd ff ff       	call   80101cb9 <iunlockput>
80105f4f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f52:	e8 aa d2 ff ff       	call   80103201 <end_op>
  return 0;
80105f57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f5c:	c9                   	leave  
80105f5d:	c3                   	ret    

80105f5e <sys_mknod>:

int
sys_mknod(void)
{
80105f5e:	f3 0f 1e fb          	endbr32 
80105f62:	55                   	push   %ebp
80105f63:	89 e5                	mov    %esp,%ebp
80105f65:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105f68:	e8 04 d2 ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105f6d:	83 ec 08             	sub    $0x8,%esp
80105f70:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f73:	50                   	push   %eax
80105f74:	6a 00                	push   $0x0
80105f76:	e8 a7 f4 ff ff       	call   80105422 <argstr>
80105f7b:	83 c4 10             	add    $0x10,%esp
80105f7e:	85 c0                	test   %eax,%eax
80105f80:	78 4f                	js     80105fd1 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105f82:	83 ec 08             	sub    $0x8,%esp
80105f85:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f88:	50                   	push   %eax
80105f89:	6a 01                	push   $0x1
80105f8b:	e8 f5 f3 ff ff       	call   80105385 <argint>
80105f90:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105f93:	85 c0                	test   %eax,%eax
80105f95:	78 3a                	js     80105fd1 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105f97:	83 ec 08             	sub    $0x8,%esp
80105f9a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f9d:	50                   	push   %eax
80105f9e:	6a 02                	push   $0x2
80105fa0:	e8 e0 f3 ff ff       	call   80105385 <argint>
80105fa5:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105fa8:	85 c0                	test   %eax,%eax
80105faa:	78 25                	js     80105fd1 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105fac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105faf:	0f bf c8             	movswl %ax,%ecx
80105fb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fb5:	0f bf d0             	movswl %ax,%edx
80105fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fbb:	51                   	push   %ecx
80105fbc:	52                   	push   %edx
80105fbd:	6a 03                	push   $0x3
80105fbf:	50                   	push   %eax
80105fc0:	e8 bd fb ff ff       	call   80105b82 <create>
80105fc5:	83 c4 10             	add    $0x10,%esp
80105fc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105fcb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fcf:	75 0c                	jne    80105fdd <sys_mknod+0x7f>
    end_op();
80105fd1:	e8 2b d2 ff ff       	call   80103201 <end_op>
    return -1;
80105fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fdb:	eb 18                	jmp    80105ff5 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105fdd:	83 ec 0c             	sub    $0xc,%esp
80105fe0:	ff 75 f4             	pushl  -0xc(%ebp)
80105fe3:	e8 d1 bc ff ff       	call   80101cb9 <iunlockput>
80105fe8:	83 c4 10             	add    $0x10,%esp
  end_op();
80105feb:	e8 11 d2 ff ff       	call   80103201 <end_op>
  return 0;
80105ff0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ff5:	c9                   	leave  
80105ff6:	c3                   	ret    

80105ff7 <sys_chdir>:

int
sys_chdir(void)
{
80105ff7:	f3 0f 1e fb          	endbr32 
80105ffb:	55                   	push   %ebp
80105ffc:	89 e5                	mov    %esp,%ebp
80105ffe:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106001:	e8 a3 db ff ff       	call   80103ba9 <myproc>
80106006:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106009:	e8 63 d1 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010600e:	83 ec 08             	sub    $0x8,%esp
80106011:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106014:	50                   	push   %eax
80106015:	6a 00                	push   $0x0
80106017:	e8 06 f4 ff ff       	call   80105422 <argstr>
8010601c:	83 c4 10             	add    $0x10,%esp
8010601f:	85 c0                	test   %eax,%eax
80106021:	78 18                	js     8010603b <sys_chdir+0x44>
80106023:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106026:	83 ec 0c             	sub    $0xc,%esp
80106029:	50                   	push   %eax
8010602a:	e8 b8 c5 ff ff       	call   801025e7 <namei>
8010602f:	83 c4 10             	add    $0x10,%esp
80106032:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106035:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106039:	75 0c                	jne    80106047 <sys_chdir+0x50>
    end_op();
8010603b:	e8 c1 d1 ff ff       	call   80103201 <end_op>
    return -1;
80106040:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106045:	eb 68                	jmp    801060af <sys_chdir+0xb8>
  }
  ilock(ip);
80106047:	83 ec 0c             	sub    $0xc,%esp
8010604a:	ff 75 f0             	pushl  -0x10(%ebp)
8010604d:	e8 2a ba ff ff       	call   80101a7c <ilock>
80106052:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106055:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106058:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010605c:	66 83 f8 01          	cmp    $0x1,%ax
80106060:	74 1a                	je     8010607c <sys_chdir+0x85>
    iunlockput(ip);
80106062:	83 ec 0c             	sub    $0xc,%esp
80106065:	ff 75 f0             	pushl  -0x10(%ebp)
80106068:	e8 4c bc ff ff       	call   80101cb9 <iunlockput>
8010606d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106070:	e8 8c d1 ff ff       	call   80103201 <end_op>
    return -1;
80106075:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010607a:	eb 33                	jmp    801060af <sys_chdir+0xb8>
  }
  iunlock(ip);
8010607c:	83 ec 0c             	sub    $0xc,%esp
8010607f:	ff 75 f0             	pushl  -0x10(%ebp)
80106082:	e8 0c bb ff ff       	call   80101b93 <iunlock>
80106087:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010608a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608d:	8b 40 68             	mov    0x68(%eax),%eax
80106090:	83 ec 0c             	sub    $0xc,%esp
80106093:	50                   	push   %eax
80106094:	e8 4c bb ff ff       	call   80101be5 <iput>
80106099:	83 c4 10             	add    $0x10,%esp
  end_op();
8010609c:	e8 60 d1 ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
801060a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060a7:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801060aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060af:	c9                   	leave  
801060b0:	c3                   	ret    

801060b1 <sys_exec>:

int
sys_exec(void)
{
801060b1:	f3 0f 1e fb          	endbr32 
801060b5:	55                   	push   %ebp
801060b6:	89 e5                	mov    %esp,%ebp
801060b8:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801060be:	83 ec 08             	sub    $0x8,%esp
801060c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060c4:	50                   	push   %eax
801060c5:	6a 00                	push   $0x0
801060c7:	e8 56 f3 ff ff       	call   80105422 <argstr>
801060cc:	83 c4 10             	add    $0x10,%esp
801060cf:	85 c0                	test   %eax,%eax
801060d1:	78 18                	js     801060eb <sys_exec+0x3a>
801060d3:	83 ec 08             	sub    $0x8,%esp
801060d6:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801060dc:	50                   	push   %eax
801060dd:	6a 01                	push   $0x1
801060df:	e8 a1 f2 ff ff       	call   80105385 <argint>
801060e4:	83 c4 10             	add    $0x10,%esp
801060e7:	85 c0                	test   %eax,%eax
801060e9:	79 0a                	jns    801060f5 <sys_exec+0x44>
    return -1;
801060eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f0:	e9 c6 00 00 00       	jmp    801061bb <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
801060f5:	83 ec 04             	sub    $0x4,%esp
801060f8:	68 80 00 00 00       	push   $0x80
801060fd:	6a 00                	push   $0x0
801060ff:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106105:	50                   	push   %eax
80106106:	e8 26 ef ff ff       	call   80105031 <memset>
8010610b:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010610e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106118:	83 f8 1f             	cmp    $0x1f,%eax
8010611b:	76 0a                	jbe    80106127 <sys_exec+0x76>
      return -1;
8010611d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106122:	e9 94 00 00 00       	jmp    801061bb <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612a:	c1 e0 02             	shl    $0x2,%eax
8010612d:	89 c2                	mov    %eax,%edx
8010612f:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106135:	01 c2                	add    %eax,%edx
80106137:	83 ec 08             	sub    $0x8,%esp
8010613a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106140:	50                   	push   %eax
80106141:	52                   	push   %edx
80106142:	e8 93 f1 ff ff       	call   801052da <fetchint>
80106147:	83 c4 10             	add    $0x10,%esp
8010614a:	85 c0                	test   %eax,%eax
8010614c:	79 07                	jns    80106155 <sys_exec+0xa4>
      return -1;
8010614e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106153:	eb 66                	jmp    801061bb <sys_exec+0x10a>
    if(uarg == 0){
80106155:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010615b:	85 c0                	test   %eax,%eax
8010615d:	75 27                	jne    80106186 <sys_exec+0xd5>
      argv[i] = 0;
8010615f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106162:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106169:	00 00 00 00 
      break;
8010616d:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010616e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106171:	83 ec 08             	sub    $0x8,%esp
80106174:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010617a:	52                   	push   %edx
8010617b:	50                   	push   %eax
8010617c:	e8 3d aa ff ff       	call   80100bbe <exec>
80106181:	83 c4 10             	add    $0x10,%esp
80106184:	eb 35                	jmp    801061bb <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106186:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010618c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010618f:	c1 e2 02             	shl    $0x2,%edx
80106192:	01 c2                	add    %eax,%edx
80106194:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010619a:	83 ec 08             	sub    $0x8,%esp
8010619d:	52                   	push   %edx
8010619e:	50                   	push   %eax
8010619f:	e8 79 f1 ff ff       	call   8010531d <fetchstr>
801061a4:	83 c4 10             	add    $0x10,%esp
801061a7:	85 c0                	test   %eax,%eax
801061a9:	79 07                	jns    801061b2 <sys_exec+0x101>
      return -1;
801061ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b0:	eb 09                	jmp    801061bb <sys_exec+0x10a>
  for(i=0;; i++){
801061b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801061b6:	e9 5a ff ff ff       	jmp    80106115 <sys_exec+0x64>
}
801061bb:	c9                   	leave  
801061bc:	c3                   	ret    

801061bd <sys_pipe>:

int
sys_pipe(void)
{
801061bd:	f3 0f 1e fb          	endbr32 
801061c1:	55                   	push   %ebp
801061c2:	89 e5                	mov    %esp,%ebp
801061c4:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801061c7:	83 ec 04             	sub    $0x4,%esp
801061ca:	6a 08                	push   $0x8
801061cc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061cf:	50                   	push   %eax
801061d0:	6a 00                	push   $0x0
801061d2:	e8 df f1 ff ff       	call   801053b6 <argptr>
801061d7:	83 c4 10             	add    $0x10,%esp
801061da:	85 c0                	test   %eax,%eax
801061dc:	79 0a                	jns    801061e8 <sys_pipe+0x2b>
    return -1;
801061de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e3:	e9 ae 00 00 00       	jmp    80106296 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
801061e8:	83 ec 08             	sub    $0x8,%esp
801061eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061ee:	50                   	push   %eax
801061ef:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061f2:	50                   	push   %eax
801061f3:	e8 d2 d4 ff ff       	call   801036ca <pipealloc>
801061f8:	83 c4 10             	add    $0x10,%esp
801061fb:	85 c0                	test   %eax,%eax
801061fd:	79 0a                	jns    80106209 <sys_pipe+0x4c>
    return -1;
801061ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106204:	e9 8d 00 00 00       	jmp    80106296 <sys_pipe+0xd9>
  fd0 = -1;
80106209:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106210:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106213:	83 ec 0c             	sub    $0xc,%esp
80106216:	50                   	push   %eax
80106217:	e8 3b f3 ff ff       	call   80105557 <fdalloc>
8010621c:	83 c4 10             	add    $0x10,%esp
8010621f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106222:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106226:	78 18                	js     80106240 <sys_pipe+0x83>
80106228:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010622b:	83 ec 0c             	sub    $0xc,%esp
8010622e:	50                   	push   %eax
8010622f:	e8 23 f3 ff ff       	call   80105557 <fdalloc>
80106234:	83 c4 10             	add    $0x10,%esp
80106237:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010623a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010623e:	79 3e                	jns    8010627e <sys_pipe+0xc1>
    if(fd0 >= 0)
80106240:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106244:	78 13                	js     80106259 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106246:	e8 5e d9 ff ff       	call   80103ba9 <myproc>
8010624b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010624e:	83 c2 08             	add    $0x8,%edx
80106251:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106258:	00 
    fileclose(rf);
80106259:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010625c:	83 ec 0c             	sub    $0xc,%esp
8010625f:	50                   	push   %eax
80106260:	e8 84 ae ff ff       	call   801010e9 <fileclose>
80106265:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010626b:	83 ec 0c             	sub    $0xc,%esp
8010626e:	50                   	push   %eax
8010626f:	e8 75 ae ff ff       	call   801010e9 <fileclose>
80106274:	83 c4 10             	add    $0x10,%esp
    return -1;
80106277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627c:	eb 18                	jmp    80106296 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
8010627e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106281:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106284:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106286:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106289:	8d 50 04             	lea    0x4(%eax),%edx
8010628c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010628f:	89 02                	mov    %eax,(%edx)
  return 0;
80106291:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106296:	c9                   	leave  
80106297:	c3                   	ret    

80106298 <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
80106298:	f3 0f 1e fb          	endbr32 
8010629c:	55                   	push   %ebp
8010629d:	89 e5                	mov    %esp,%ebp
8010629f:	83 ec 08             	sub    $0x8,%esp
  return fork();
801062a2:	e8 50 dc ff ff       	call   80103ef7 <fork>
}
801062a7:	c9                   	leave  
801062a8:	c3                   	ret    

801062a9 <sys_exit>:

int
sys_exit(void)
{
801062a9:	f3 0f 1e fb          	endbr32 
801062ad:	55                   	push   %ebp
801062ae:	89 e5                	mov    %esp,%ebp
801062b0:	83 ec 08             	sub    $0x8,%esp
  exit();
801062b3:	e8 bc dd ff ff       	call   80104074 <exit>
  return 0;  // not reached
801062b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062bd:	c9                   	leave  
801062be:	c3                   	ret    

801062bf <sys_wait>:

int
sys_wait(void)
{
801062bf:	f3 0f 1e fb          	endbr32 
801062c3:	55                   	push   %ebp
801062c4:	89 e5                	mov    %esp,%ebp
801062c6:	83 ec 08             	sub    $0x8,%esp
  return wait();
801062c9:	e8 cd de ff ff       	call   8010419b <wait>
}
801062ce:	c9                   	leave  
801062cf:	c3                   	ret    

801062d0 <sys_kill>:

int
sys_kill(void)
{
801062d0:	f3 0f 1e fb          	endbr32 
801062d4:	55                   	push   %ebp
801062d5:	89 e5                	mov    %esp,%ebp
801062d7:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801062da:	83 ec 08             	sub    $0x8,%esp
801062dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062e0:	50                   	push   %eax
801062e1:	6a 00                	push   $0x0
801062e3:	e8 9d f0 ff ff       	call   80105385 <argint>
801062e8:	83 c4 10             	add    $0x10,%esp
801062eb:	85 c0                	test   %eax,%eax
801062ed:	79 07                	jns    801062f6 <sys_kill+0x26>
    return -1;
801062ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f4:	eb 0f                	jmp    80106305 <sys_kill+0x35>
  return kill(pid);
801062f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f9:	83 ec 0c             	sub    $0xc,%esp
801062fc:	50                   	push   %eax
801062fd:	e8 2c e6 ff ff       	call   8010492e <kill>
80106302:	83 c4 10             	add    $0x10,%esp
}
80106305:	c9                   	leave  
80106306:	c3                   	ret    

80106307 <sys_getpid>:

int
sys_getpid(void)
{
80106307:	f3 0f 1e fb          	endbr32 
8010630b:	55                   	push   %ebp
8010630c:	89 e5                	mov    %esp,%ebp
8010630e:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106311:	e8 93 d8 ff ff       	call   80103ba9 <myproc>
80106316:	8b 40 10             	mov    0x10(%eax),%eax
}
80106319:	c9                   	leave  
8010631a:	c3                   	ret    

8010631b <sys_sbrk>:

int
sys_sbrk(void)
{
8010631b:	f3 0f 1e fb          	endbr32 
8010631f:	55                   	push   %ebp
80106320:	89 e5                	mov    %esp,%ebp
80106322:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106325:	83 ec 08             	sub    $0x8,%esp
80106328:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010632b:	50                   	push   %eax
8010632c:	6a 00                	push   $0x0
8010632e:	e8 52 f0 ff ff       	call   80105385 <argint>
80106333:	83 c4 10             	add    $0x10,%esp
80106336:	85 c0                	test   %eax,%eax
80106338:	79 07                	jns    80106341 <sys_sbrk+0x26>
    return -1;
8010633a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633f:	eb 27                	jmp    80106368 <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106341:	e8 63 d8 ff ff       	call   80103ba9 <myproc>
80106346:	8b 00                	mov    (%eax),%eax
80106348:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010634b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634e:	83 ec 0c             	sub    $0xc,%esp
80106351:	50                   	push   %eax
80106352:	e8 01 db ff ff       	call   80103e58 <growproc>
80106357:	83 c4 10             	add    $0x10,%esp
8010635a:	85 c0                	test   %eax,%eax
8010635c:	79 07                	jns    80106365 <sys_sbrk+0x4a>
    return -1;
8010635e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106363:	eb 03                	jmp    80106368 <sys_sbrk+0x4d>
  return addr;
80106365:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106368:	c9                   	leave  
80106369:	c3                   	ret    

8010636a <sys_sleep>:

int
sys_sleep(void)
{
8010636a:	f3 0f 1e fb          	endbr32 
8010636e:	55                   	push   %ebp
8010636f:	89 e5                	mov    %esp,%ebp
80106371:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106374:	83 ec 08             	sub    $0x8,%esp
80106377:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010637a:	50                   	push   %eax
8010637b:	6a 00                	push   $0x0
8010637d:	e8 03 f0 ff ff       	call   80105385 <argint>
80106382:	83 c4 10             	add    $0x10,%esp
80106385:	85 c0                	test   %eax,%eax
80106387:	79 07                	jns    80106390 <sys_sleep+0x26>
    return -1;
80106389:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638e:	eb 76                	jmp    80106406 <sys_sleep+0x9c>
  acquire(&tickslock);
80106390:	83 ec 0c             	sub    $0xc,%esp
80106393:	68 40 7d 19 80       	push   $0x80197d40
80106398:	e8 05 ea ff ff       	call   80104da2 <acquire>
8010639d:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801063a0:	a1 80 85 19 80       	mov    0x80198580,%eax
801063a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801063a8:	eb 38                	jmp    801063e2 <sys_sleep+0x78>
    if(myproc()->killed){
801063aa:	e8 fa d7 ff ff       	call   80103ba9 <myproc>
801063af:	8b 40 24             	mov    0x24(%eax),%eax
801063b2:	85 c0                	test   %eax,%eax
801063b4:	74 17                	je     801063cd <sys_sleep+0x63>
      release(&tickslock);
801063b6:	83 ec 0c             	sub    $0xc,%esp
801063b9:	68 40 7d 19 80       	push   $0x80197d40
801063be:	e8 51 ea ff ff       	call   80104e14 <release>
801063c3:	83 c4 10             	add    $0x10,%esp
      return -1;
801063c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063cb:	eb 39                	jmp    80106406 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801063cd:	83 ec 08             	sub    $0x8,%esp
801063d0:	68 40 7d 19 80       	push   $0x80197d40
801063d5:	68 80 85 19 80       	push   $0x80198580
801063da:	e8 22 e4 ff ff       	call   80104801 <sleep>
801063df:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801063e2:	a1 80 85 19 80       	mov    0x80198580,%eax
801063e7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801063ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063ed:	39 d0                	cmp    %edx,%eax
801063ef:	72 b9                	jb     801063aa <sys_sleep+0x40>
  }
  release(&tickslock);
801063f1:	83 ec 0c             	sub    $0xc,%esp
801063f4:	68 40 7d 19 80       	push   $0x80197d40
801063f9:	e8 16 ea ff ff       	call   80104e14 <release>
801063fe:	83 c4 10             	add    $0x10,%esp
  return 0;
80106401:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106406:	c9                   	leave  
80106407:	c3                   	ret    

80106408 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106408:	f3 0f 1e fb          	endbr32 
8010640c:	55                   	push   %ebp
8010640d:	89 e5                	mov    %esp,%ebp
8010640f:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106412:	83 ec 0c             	sub    $0xc,%esp
80106415:	68 40 7d 19 80       	push   $0x80197d40
8010641a:	e8 83 e9 ff ff       	call   80104da2 <acquire>
8010641f:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106422:	a1 80 85 19 80       	mov    0x80198580,%eax
80106427:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010642a:	83 ec 0c             	sub    $0xc,%esp
8010642d:	68 40 7d 19 80       	push   $0x80197d40
80106432:	e8 dd e9 ff ff       	call   80104e14 <release>
80106437:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010643a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010643d:	c9                   	leave  
8010643e:	c3                   	ret    

8010643f <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
8010643f:	f3 0f 1e fb          	endbr32 
80106443:	55                   	push   %ebp
80106444:	89 e5                	mov    %esp,%ebp
80106446:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
80106449:	83 ec 08             	sub    $0x8,%esp
8010644c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010644f:	50                   	push   %eax
80106450:	6a 00                	push   $0x0
80106452:	e8 2e ef ff ff       	call   80105385 <argint>
80106457:	83 c4 10             	add    $0x10,%esp
8010645a:	85 c0                	test   %eax,%eax
8010645c:	79 07                	jns    80106465 <sys_setSchedPolicy+0x26>
    return -1;
8010645e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106463:	eb 0f                	jmp    80106474 <sys_setSchedPolicy+0x35>
  return setSchedPolicy(policy);
80106465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106468:	83 ec 0c             	sub    $0xc,%esp
8010646b:	50                   	push   %eax
8010646c:	e8 49 e6 ff ff       	call   80104aba <setSchedPolicy>
80106471:	83 c4 10             	add    $0x10,%esp
}
80106474:	c9                   	leave  
80106475:	c3                   	ret    

80106476 <sys_getpinfo>:



int
sys_getpinfo(void)
{
80106476:	f3 0f 1e fb          	endbr32 
8010647a:	55                   	push   %ebp
8010647b:	89 e5                	mov    %esp,%ebp
8010647d:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(*ps)) < 0 )
80106480:	83 ec 04             	sub    $0x4,%esp
80106483:	68 00 0c 00 00       	push   $0xc00
80106488:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010648b:	50                   	push   %eax
8010648c:	6a 00                	push   $0x0
8010648e:	e8 23 ef ff ff       	call   801053b6 <argptr>
80106493:	83 c4 10             	add    $0x10,%esp
80106496:	85 c0                	test   %eax,%eax
80106498:	79 07                	jns    801064a1 <sys_getpinfo+0x2b>
    return -1;
8010649a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649f:	eb 0f                	jmp    801064b0 <sys_getpinfo+0x3a>
  return getpinfo(ps);
801064a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a4:	83 ec 0c             	sub    $0xc,%esp
801064a7:	50                   	push   %eax
801064a8:	e8 4f e6 ff ff       	call   80104afc <getpinfo>
801064ad:	83 c4 10             	add    $0x10,%esp
}
801064b0:	c9                   	leave  
801064b1:	c3                   	ret    

801064b2 <sys_yield>:

int
sys_yield(void)
{
801064b2:	f3 0f 1e fb          	endbr32 
801064b6:	55                   	push   %ebp
801064b7:	89 e5                	mov    %esp,%ebp
801064b9:	83 ec 08             	sub    $0x8,%esp
  yield();
801064bc:	e8 b8 e2 ff ff       	call   80104779 <yield>
  return 0;
801064c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064c6:	c9                   	leave  
801064c7:	c3                   	ret    

801064c8 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801064c8:	1e                   	push   %ds
  pushl %es
801064c9:	06                   	push   %es
  pushl %fs
801064ca:	0f a0                	push   %fs
  pushl %gs
801064cc:	0f a8                	push   %gs
  pushal
801064ce:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801064cf:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801064d3:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801064d5:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801064d7:	54                   	push   %esp
  call trap
801064d8:	e8 df 01 00 00       	call   801066bc <trap>
  addl $4, %esp
801064dd:	83 c4 04             	add    $0x4,%esp

801064e0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801064e0:	61                   	popa   
  popl %gs
801064e1:	0f a9                	pop    %gs
  popl %fs
801064e3:	0f a1                	pop    %fs
  popl %es
801064e5:	07                   	pop    %es
  popl %ds
801064e6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801064e7:	83 c4 08             	add    $0x8,%esp
  iret
801064ea:	cf                   	iret   

801064eb <lidt>:
{
801064eb:	55                   	push   %ebp
801064ec:	89 e5                	mov    %esp,%ebp
801064ee:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801064f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801064f4:	83 e8 01             	sub    $0x1,%eax
801064f7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801064fb:	8b 45 08             	mov    0x8(%ebp),%eax
801064fe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106502:	8b 45 08             	mov    0x8(%ebp),%eax
80106505:	c1 e8 10             	shr    $0x10,%eax
80106508:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010650c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010650f:	0f 01 18             	lidtl  (%eax)
}
80106512:	90                   	nop
80106513:	c9                   	leave  
80106514:	c3                   	ret    

80106515 <rcr2>:

static inline uint
rcr2(void)
{
80106515:	55                   	push   %ebp
80106516:	89 e5                	mov    %esp,%ebp
80106518:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010651b:	0f 20 d0             	mov    %cr2,%eax
8010651e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106521:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106524:	c9                   	leave  
80106525:	c3                   	ret    

80106526 <tvinit>:
  struct proc proc[NPROC];
} ptable;

void
tvinit(void)
{
80106526:	f3 0f 1e fb          	endbr32 
8010652a:	55                   	push   %ebp
8010652b:	89 e5                	mov    %esp,%ebp
8010652d:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106530:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106537:	e9 c3 00 00 00       	jmp    801065ff <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010653c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010653f:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80106546:	89 c2                	mov    %eax,%edx
80106548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654b:	66 89 14 c5 80 7d 19 	mov    %dx,-0x7fe68280(,%eax,8)
80106552:	80 
80106553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106556:	66 c7 04 c5 82 7d 19 	movw   $0x8,-0x7fe6827e(,%eax,8)
8010655d:	80 08 00 
80106560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106563:	0f b6 14 c5 84 7d 19 	movzbl -0x7fe6827c(,%eax,8),%edx
8010656a:	80 
8010656b:	83 e2 e0             	and    $0xffffffe0,%edx
8010656e:	88 14 c5 84 7d 19 80 	mov    %dl,-0x7fe6827c(,%eax,8)
80106575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106578:	0f b6 14 c5 84 7d 19 	movzbl -0x7fe6827c(,%eax,8),%edx
8010657f:	80 
80106580:	83 e2 1f             	and    $0x1f,%edx
80106583:	88 14 c5 84 7d 19 80 	mov    %dl,-0x7fe6827c(,%eax,8)
8010658a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658d:	0f b6 14 c5 85 7d 19 	movzbl -0x7fe6827b(,%eax,8),%edx
80106594:	80 
80106595:	83 e2 f0             	and    $0xfffffff0,%edx
80106598:	83 ca 0e             	or     $0xe,%edx
8010659b:	88 14 c5 85 7d 19 80 	mov    %dl,-0x7fe6827b(,%eax,8)
801065a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a5:	0f b6 14 c5 85 7d 19 	movzbl -0x7fe6827b(,%eax,8),%edx
801065ac:	80 
801065ad:	83 e2 ef             	and    $0xffffffef,%edx
801065b0:	88 14 c5 85 7d 19 80 	mov    %dl,-0x7fe6827b(,%eax,8)
801065b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ba:	0f b6 14 c5 85 7d 19 	movzbl -0x7fe6827b(,%eax,8),%edx
801065c1:	80 
801065c2:	83 e2 9f             	and    $0xffffff9f,%edx
801065c5:	88 14 c5 85 7d 19 80 	mov    %dl,-0x7fe6827b(,%eax,8)
801065cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065cf:	0f b6 14 c5 85 7d 19 	movzbl -0x7fe6827b(,%eax,8),%edx
801065d6:	80 
801065d7:	83 ca 80             	or     $0xffffff80,%edx
801065da:	88 14 c5 85 7d 19 80 	mov    %dl,-0x7fe6827b(,%eax,8)
801065e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e4:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
801065eb:	c1 e8 10             	shr    $0x10,%eax
801065ee:	89 c2                	mov    %eax,%edx
801065f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f3:	66 89 14 c5 86 7d 19 	mov    %dx,-0x7fe6827a(,%eax,8)
801065fa:	80 
  for(i = 0; i < 256; i++)
801065fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065ff:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106606:	0f 8e 30 ff ff ff    	jle    8010653c <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010660c:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80106611:	66 a3 80 7f 19 80    	mov    %ax,0x80197f80
80106617:	66 c7 05 82 7f 19 80 	movw   $0x8,0x80197f82
8010661e:	08 00 
80106620:	0f b6 05 84 7f 19 80 	movzbl 0x80197f84,%eax
80106627:	83 e0 e0             	and    $0xffffffe0,%eax
8010662a:	a2 84 7f 19 80       	mov    %al,0x80197f84
8010662f:	0f b6 05 84 7f 19 80 	movzbl 0x80197f84,%eax
80106636:	83 e0 1f             	and    $0x1f,%eax
80106639:	a2 84 7f 19 80       	mov    %al,0x80197f84
8010663e:	0f b6 05 85 7f 19 80 	movzbl 0x80197f85,%eax
80106645:	83 c8 0f             	or     $0xf,%eax
80106648:	a2 85 7f 19 80       	mov    %al,0x80197f85
8010664d:	0f b6 05 85 7f 19 80 	movzbl 0x80197f85,%eax
80106654:	83 e0 ef             	and    $0xffffffef,%eax
80106657:	a2 85 7f 19 80       	mov    %al,0x80197f85
8010665c:	0f b6 05 85 7f 19 80 	movzbl 0x80197f85,%eax
80106663:	83 c8 60             	or     $0x60,%eax
80106666:	a2 85 7f 19 80       	mov    %al,0x80197f85
8010666b:	0f b6 05 85 7f 19 80 	movzbl 0x80197f85,%eax
80106672:	83 c8 80             	or     $0xffffff80,%eax
80106675:	a2 85 7f 19 80       	mov    %al,0x80197f85
8010667a:	a1 84 f1 10 80       	mov    0x8010f184,%eax
8010667f:	c1 e8 10             	shr    $0x10,%eax
80106682:	66 a3 86 7f 19 80    	mov    %ax,0x80197f86

  initlock(&tickslock, "time");
80106688:	83 ec 08             	sub    $0x8,%esp
8010668b:	68 98 ad 10 80       	push   $0x8010ad98
80106690:	68 40 7d 19 80       	push   $0x80197d40
80106695:	e8 e2 e6 ff ff       	call   80104d7c <initlock>
8010669a:	83 c4 10             	add    $0x10,%esp
}
8010669d:	90                   	nop
8010669e:	c9                   	leave  
8010669f:	c3                   	ret    

801066a0 <idtinit>:

void
idtinit(void)
{
801066a0:	f3 0f 1e fb          	endbr32 
801066a4:	55                   	push   %ebp
801066a5:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801066a7:	68 00 08 00 00       	push   $0x800
801066ac:	68 80 7d 19 80       	push   $0x80197d80
801066b1:	e8 35 fe ff ff       	call   801064eb <lidt>
801066b6:	83 c4 08             	add    $0x8,%esp
}
801066b9:	90                   	nop
801066ba:	c9                   	leave  
801066bb:	c3                   	ret    

801066bc <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801066bc:	f3 0f 1e fb          	endbr32 
801066c0:	55                   	push   %ebp
801066c1:	89 e5                	mov    %esp,%ebp
801066c3:	57                   	push   %edi
801066c4:	56                   	push   %esi
801066c5:	53                   	push   %ebx
801066c6:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801066c9:	8b 45 08             	mov    0x8(%ebp),%eax
801066cc:	8b 40 30             	mov    0x30(%eax),%eax
801066cf:	83 f8 40             	cmp    $0x40,%eax
801066d2:	75 3b                	jne    8010670f <trap+0x53>
    if(myproc()->killed)
801066d4:	e8 d0 d4 ff ff       	call   80103ba9 <myproc>
801066d9:	8b 40 24             	mov    0x24(%eax),%eax
801066dc:	85 c0                	test   %eax,%eax
801066de:	74 05                	je     801066e5 <trap+0x29>
      exit();
801066e0:	e8 8f d9 ff ff       	call   80104074 <exit>
    myproc()->tf = tf;
801066e5:	e8 bf d4 ff ff       	call   80103ba9 <myproc>
801066ea:	8b 55 08             	mov    0x8(%ebp),%edx
801066ed:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801066f0:	e8 68 ed ff ff       	call   8010545d <syscall>
    if(myproc()->killed)
801066f5:	e8 af d4 ff ff       	call   80103ba9 <myproc>
801066fa:	8b 40 24             	mov    0x24(%eax),%eax
801066fd:	85 c0                	test   %eax,%eax
801066ff:	0f 84 c1 02 00 00    	je     801069c6 <trap+0x30a>
      exit();
80106705:	e8 6a d9 ff ff       	call   80104074 <exit>
    return;
8010670a:	e9 b7 02 00 00       	jmp    801069c6 <trap+0x30a>
  }

  switch(tf->trapno){
8010670f:	8b 45 08             	mov    0x8(%ebp),%eax
80106712:	8b 40 30             	mov    0x30(%eax),%eax
80106715:	83 e8 20             	sub    $0x20,%eax
80106718:	83 f8 1f             	cmp    $0x1f,%eax
8010671b:	0f 87 93 01 00 00    	ja     801068b4 <trap+0x1f8>
80106721:	8b 04 85 40 ae 10 80 	mov    -0x7fef51c0(,%eax,4),%eax
80106728:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010672b:	e8 de d3 ff ff       	call   80103b0e <cpuid>
80106730:	85 c0                	test   %eax,%eax
80106732:	75 3d                	jne    80106771 <trap+0xb5>
      acquire(&tickslock);
80106734:	83 ec 0c             	sub    $0xc,%esp
80106737:	68 40 7d 19 80       	push   $0x80197d40
8010673c:	e8 61 e6 ff ff       	call   80104da2 <acquire>
80106741:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106744:	a1 80 85 19 80       	mov    0x80198580,%eax
80106749:	83 c0 01             	add    $0x1,%eax
8010674c:	a3 80 85 19 80       	mov    %eax,0x80198580
      wakeup(&ticks);
80106751:	83 ec 0c             	sub    $0xc,%esp
80106754:	68 80 85 19 80       	push   $0x80198580
80106759:	e8 95 e1 ff ff       	call   801048f3 <wakeup>
8010675e:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106761:	83 ec 0c             	sub    $0xc,%esp
80106764:	68 40 7d 19 80       	push   $0x80197d40
80106769:	e8 a6 e6 ff ff       	call   80104e14 <release>
8010676e:	83 c4 10             	add    $0x10,%esp
    }
    //추가
    struct proc *curproc = myproc();
80106771:	e8 33 d4 ff ff       	call   80103ba9 <myproc>
80106776:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
    // 현재 실행 중인 프로세스의 ticks 증가
    if (curproc && curproc->state == RUNNING) {
80106779:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010677d:	74 3b                	je     801067ba <trap+0xfe>
8010677f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106782:	8b 40 0c             	mov    0xc(%eax),%eax
80106785:	83 f8 04             	cmp    $0x4,%eax
80106788:	75 30                	jne    801067ba <trap+0xfe>
      int q = curproc->priority;
8010678a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010678d:	8b 40 7c             	mov    0x7c(%eax),%eax
80106790:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (q >= 0 && q <= 3)
80106793:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106797:	78 21                	js     801067ba <trap+0xfe>
80106799:	83 7d dc 03          	cmpl   $0x3,-0x24(%ebp)
8010679d:	7f 1b                	jg     801067ba <trap+0xfe>
        curproc->ticks[q]++;
8010679f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801067a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801067a5:	83 c2 20             	add    $0x20,%edx
801067a8:	8b 04 90             	mov    (%eax,%edx,4),%eax
801067ab:	8d 48 01             	lea    0x1(%eax),%ecx
801067ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801067b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801067b4:	83 c2 20             	add    $0x20,%edx
801067b7:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    }
    // 다른 RUNNABLE한 프로세스들 wait_ticks 증가
    acquire(&ptable.lock);
801067ba:	83 ec 0c             	sub    $0xc,%esp
801067bd:	68 00 55 19 80       	push   $0x80195500
801067c2:	e8 db e5 ff ff       	call   80104da2 <acquire>
801067c7:	83 c4 10             	add    $0x10,%esp
    struct proc *p;
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801067ca:	c7 45 e4 34 55 19 80 	movl   $0x80195534,-0x1c(%ebp)
801067d1:	eb 35                	jmp    80106808 <trap+0x14c>
      if (p != curproc && p->state == RUNNABLE ) {
801067d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067d6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
801067d9:	74 26                	je     80106801 <trap+0x145>
801067db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067de:	8b 40 0c             	mov    0xc(%eax),%eax
801067e1:	83 f8 03             	cmp    $0x3,%eax
801067e4:	75 1b                	jne    80106801 <trap+0x145>
        p->wait_ticks[p->priority]++;
801067e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067e9:	8b 40 7c             	mov    0x7c(%eax),%eax
801067ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801067ef:	8d 48 24             	lea    0x24(%eax),%ecx
801067f2:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
801067f5:	8d 4a 01             	lea    0x1(%edx),%ecx
801067f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801067fb:	83 c0 24             	add    $0x24,%eax
801067fe:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106801:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
80106808:	81 7d e4 34 7d 19 80 	cmpl   $0x80197d34,-0x1c(%ebp)
8010680f:	72 c2                	jb     801067d3 <trap+0x117>
      }
    }
    release(&ptable.lock);
80106811:	83 ec 0c             	sub    $0xc,%esp
80106814:	68 00 55 19 80       	push   $0x80195500
80106819:	e8 f6 e5 ff ff       	call   80104e14 <release>
8010681e:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106821:	e8 ff c3 ff ff       	call   80102c25 <lapiceoi>
    if (curproc && curproc->state == RUNNING){
80106826:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010682a:	0f 84 3b 01 00 00    	je     8010696b <trap+0x2af>
80106830:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106833:	8b 40 0c             	mov    0xc(%eax),%eax
80106836:	83 f8 04             	cmp    $0x4,%eax
80106839:	0f 85 2c 01 00 00    	jne    8010696b <trap+0x2af>
      yield();  // CPU 양보
8010683f:	e8 35 df ff ff       	call   80104779 <yield>
    }
    break;
80106844:	e9 22 01 00 00       	jmp    8010696b <trap+0x2af>

  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106849:	e8 f8 3f 00 00       	call   8010a846 <ideintr>
    lapiceoi();
8010684e:	e8 d2 c3 ff ff       	call   80102c25 <lapiceoi>
    break;
80106853:	e9 14 01 00 00       	jmp    8010696c <trap+0x2b0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106858:	e8 fe c1 ff ff       	call   80102a5b <kbdintr>
    lapiceoi();
8010685d:	e8 c3 c3 ff ff       	call   80102c25 <lapiceoi>
    break;
80106862:	e9 05 01 00 00       	jmp    8010696c <trap+0x2b0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106867:	e8 3c 03 00 00       	call   80106ba8 <uartintr>
    lapiceoi();
8010686c:	e8 b4 c3 ff ff       	call   80102c25 <lapiceoi>
    break;
80106871:	e9 f6 00 00 00       	jmp    8010696c <trap+0x2b0>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106876:	e8 0a 2c 00 00       	call   80109485 <i8254_intr>
    lapiceoi();
8010687b:	e8 a5 c3 ff ff       	call   80102c25 <lapiceoi>
    break;
80106880:	e9 e7 00 00 00       	jmp    8010696c <trap+0x2b0>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106885:	8b 45 08             	mov    0x8(%ebp),%eax
80106888:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010688b:	8b 45 08             	mov    0x8(%ebp),%eax
8010688e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106892:	0f b7 d8             	movzwl %ax,%ebx
80106895:	e8 74 d2 ff ff       	call   80103b0e <cpuid>
8010689a:	56                   	push   %esi
8010689b:	53                   	push   %ebx
8010689c:	50                   	push   %eax
8010689d:	68 a0 ad 10 80       	push   $0x8010ada0
801068a2:	e8 65 9b ff ff       	call   8010040c <cprintf>
801068a7:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801068aa:	e8 76 c3 ff ff       	call   80102c25 <lapiceoi>
    break;
801068af:	e9 b8 00 00 00       	jmp    8010696c <trap+0x2b0>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801068b4:	e8 f0 d2 ff ff       	call   80103ba9 <myproc>
801068b9:	85 c0                	test   %eax,%eax
801068bb:	74 11                	je     801068ce <trap+0x212>
801068bd:	8b 45 08             	mov    0x8(%ebp),%eax
801068c0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068c4:	0f b7 c0             	movzwl %ax,%eax
801068c7:	83 e0 03             	and    $0x3,%eax
801068ca:	85 c0                	test   %eax,%eax
801068cc:	75 39                	jne    80106907 <trap+0x24b>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801068ce:	e8 42 fc ff ff       	call   80106515 <rcr2>
801068d3:	89 c3                	mov    %eax,%ebx
801068d5:	8b 45 08             	mov    0x8(%ebp),%eax
801068d8:	8b 70 38             	mov    0x38(%eax),%esi
801068db:	e8 2e d2 ff ff       	call   80103b0e <cpuid>
801068e0:	8b 55 08             	mov    0x8(%ebp),%edx
801068e3:	8b 52 30             	mov    0x30(%edx),%edx
801068e6:	83 ec 0c             	sub    $0xc,%esp
801068e9:	53                   	push   %ebx
801068ea:	56                   	push   %esi
801068eb:	50                   	push   %eax
801068ec:	52                   	push   %edx
801068ed:	68 c4 ad 10 80       	push   $0x8010adc4
801068f2:	e8 15 9b ff ff       	call   8010040c <cprintf>
801068f7:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801068fa:	83 ec 0c             	sub    $0xc,%esp
801068fd:	68 f6 ad 10 80       	push   $0x8010adf6
80106902:	e8 be 9c ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106907:	e8 09 fc ff ff       	call   80106515 <rcr2>
8010690c:	89 c6                	mov    %eax,%esi
8010690e:	8b 45 08             	mov    0x8(%ebp),%eax
80106911:	8b 40 38             	mov    0x38(%eax),%eax
80106914:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106917:	e8 f2 d1 ff ff       	call   80103b0e <cpuid>
8010691c:	89 c3                	mov    %eax,%ebx
8010691e:	8b 45 08             	mov    0x8(%ebp),%eax
80106921:	8b 78 34             	mov    0x34(%eax),%edi
80106924:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106927:	8b 45 08             	mov    0x8(%ebp),%eax
8010692a:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010692d:	e8 77 d2 ff ff       	call   80103ba9 <myproc>
80106932:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106935:	89 4d cc             	mov    %ecx,-0x34(%ebp)
80106938:	e8 6c d2 ff ff       	call   80103ba9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010693d:	8b 40 10             	mov    0x10(%eax),%eax
80106940:	56                   	push   %esi
80106941:	ff 75 d4             	pushl  -0x2c(%ebp)
80106944:	53                   	push   %ebx
80106945:	ff 75 d0             	pushl  -0x30(%ebp)
80106948:	57                   	push   %edi
80106949:	ff 75 cc             	pushl  -0x34(%ebp)
8010694c:	50                   	push   %eax
8010694d:	68 fc ad 10 80       	push   $0x8010adfc
80106952:	e8 b5 9a ff ff       	call   8010040c <cprintf>
80106957:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010695a:	e8 4a d2 ff ff       	call   80103ba9 <myproc>
8010695f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106966:	eb 04                	jmp    8010696c <trap+0x2b0>
    break;
80106968:	90                   	nop
80106969:	eb 01                	jmp    8010696c <trap+0x2b0>
    break;
8010696b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010696c:	e8 38 d2 ff ff       	call   80103ba9 <myproc>
80106971:	85 c0                	test   %eax,%eax
80106973:	74 23                	je     80106998 <trap+0x2dc>
80106975:	e8 2f d2 ff ff       	call   80103ba9 <myproc>
8010697a:	8b 40 24             	mov    0x24(%eax),%eax
8010697d:	85 c0                	test   %eax,%eax
8010697f:	74 17                	je     80106998 <trap+0x2dc>
80106981:	8b 45 08             	mov    0x8(%ebp),%eax
80106984:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106988:	0f b7 c0             	movzwl %ax,%eax
8010698b:	83 e0 03             	and    $0x3,%eax
8010698e:	83 f8 03             	cmp    $0x3,%eax
80106991:	75 05                	jne    80106998 <trap+0x2dc>
    exit();
80106993:	e8 dc d6 ff ff       	call   80104074 <exit>
  /* if(myproc() && myproc()->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
      yield();
  }*/

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106998:	e8 0c d2 ff ff       	call   80103ba9 <myproc>
8010699d:	85 c0                	test   %eax,%eax
8010699f:	74 26                	je     801069c7 <trap+0x30b>
801069a1:	e8 03 d2 ff ff       	call   80103ba9 <myproc>
801069a6:	8b 40 24             	mov    0x24(%eax),%eax
801069a9:	85 c0                	test   %eax,%eax
801069ab:	74 1a                	je     801069c7 <trap+0x30b>
801069ad:	8b 45 08             	mov    0x8(%ebp),%eax
801069b0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069b4:	0f b7 c0             	movzwl %ax,%eax
801069b7:	83 e0 03             	and    $0x3,%eax
801069ba:	83 f8 03             	cmp    $0x3,%eax
801069bd:	75 08                	jne    801069c7 <trap+0x30b>
    exit();
801069bf:	e8 b0 d6 ff ff       	call   80104074 <exit>
801069c4:	eb 01                	jmp    801069c7 <trap+0x30b>
    return;
801069c6:	90                   	nop
801069c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801069ca:	5b                   	pop    %ebx
801069cb:	5e                   	pop    %esi
801069cc:	5f                   	pop    %edi
801069cd:	5d                   	pop    %ebp
801069ce:	c3                   	ret    

801069cf <inb>:
{
801069cf:	55                   	push   %ebp
801069d0:	89 e5                	mov    %esp,%ebp
801069d2:	83 ec 14             	sub    $0x14,%esp
801069d5:	8b 45 08             	mov    0x8(%ebp),%eax
801069d8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801069dc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801069e0:	89 c2                	mov    %eax,%edx
801069e2:	ec                   	in     (%dx),%al
801069e3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801069e6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801069ea:	c9                   	leave  
801069eb:	c3                   	ret    

801069ec <outb>:
{
801069ec:	55                   	push   %ebp
801069ed:	89 e5                	mov    %esp,%ebp
801069ef:	83 ec 08             	sub    $0x8,%esp
801069f2:	8b 45 08             	mov    0x8(%ebp),%eax
801069f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801069f8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801069fc:	89 d0                	mov    %edx,%eax
801069fe:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a01:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106a05:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106a09:	ee                   	out    %al,(%dx)
}
80106a0a:	90                   	nop
80106a0b:	c9                   	leave  
80106a0c:	c3                   	ret    

80106a0d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106a0d:	f3 0f 1e fb          	endbr32 
80106a11:	55                   	push   %ebp
80106a12:	89 e5                	mov    %esp,%ebp
80106a14:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106a17:	6a 00                	push   $0x0
80106a19:	68 fa 03 00 00       	push   $0x3fa
80106a1e:	e8 c9 ff ff ff       	call   801069ec <outb>
80106a23:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106a26:	68 80 00 00 00       	push   $0x80
80106a2b:	68 fb 03 00 00       	push   $0x3fb
80106a30:	e8 b7 ff ff ff       	call   801069ec <outb>
80106a35:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106a38:	6a 0c                	push   $0xc
80106a3a:	68 f8 03 00 00       	push   $0x3f8
80106a3f:	e8 a8 ff ff ff       	call   801069ec <outb>
80106a44:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106a47:	6a 00                	push   $0x0
80106a49:	68 f9 03 00 00       	push   $0x3f9
80106a4e:	e8 99 ff ff ff       	call   801069ec <outb>
80106a53:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106a56:	6a 03                	push   $0x3
80106a58:	68 fb 03 00 00       	push   $0x3fb
80106a5d:	e8 8a ff ff ff       	call   801069ec <outb>
80106a62:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106a65:	6a 00                	push   $0x0
80106a67:	68 fc 03 00 00       	push   $0x3fc
80106a6c:	e8 7b ff ff ff       	call   801069ec <outb>
80106a71:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106a74:	6a 01                	push   $0x1
80106a76:	68 f9 03 00 00       	push   $0x3f9
80106a7b:	e8 6c ff ff ff       	call   801069ec <outb>
80106a80:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106a83:	68 fd 03 00 00       	push   $0x3fd
80106a88:	e8 42 ff ff ff       	call   801069cf <inb>
80106a8d:	83 c4 04             	add    $0x4,%esp
80106a90:	3c ff                	cmp    $0xff,%al
80106a92:	74 61                	je     80106af5 <uartinit+0xe8>
    return;
  uart = 1;
80106a94:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106a9b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106a9e:	68 fa 03 00 00       	push   $0x3fa
80106aa3:	e8 27 ff ff ff       	call   801069cf <inb>
80106aa8:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106aab:	68 f8 03 00 00       	push   $0x3f8
80106ab0:	e8 1a ff ff ff       	call   801069cf <inb>
80106ab5:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106ab8:	83 ec 08             	sub    $0x8,%esp
80106abb:	6a 00                	push   $0x0
80106abd:	6a 04                	push   $0x4
80106abf:	e8 48 bc ff ff       	call   8010270c <ioapicenable>
80106ac4:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ac7:	c7 45 f4 c0 ae 10 80 	movl   $0x8010aec0,-0xc(%ebp)
80106ace:	eb 19                	jmp    80106ae9 <uartinit+0xdc>
    uartputc(*p);
80106ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad3:	0f b6 00             	movzbl (%eax),%eax
80106ad6:	0f be c0             	movsbl %al,%eax
80106ad9:	83 ec 0c             	sub    $0xc,%esp
80106adc:	50                   	push   %eax
80106add:	e8 16 00 00 00       	call   80106af8 <uartputc>
80106ae2:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106ae5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aec:	0f b6 00             	movzbl (%eax),%eax
80106aef:	84 c0                	test   %al,%al
80106af1:	75 dd                	jne    80106ad0 <uartinit+0xc3>
80106af3:	eb 01                	jmp    80106af6 <uartinit+0xe9>
    return;
80106af5:	90                   	nop
}
80106af6:	c9                   	leave  
80106af7:	c3                   	ret    

80106af8 <uartputc>:

void
uartputc(int c)
{
80106af8:	f3 0f 1e fb          	endbr32 
80106afc:	55                   	push   %ebp
80106afd:	89 e5                	mov    %esp,%ebp
80106aff:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106b02:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106b07:	85 c0                	test   %eax,%eax
80106b09:	74 53                	je     80106b5e <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b12:	eb 11                	jmp    80106b25 <uartputc+0x2d>
    microdelay(10);
80106b14:	83 ec 0c             	sub    $0xc,%esp
80106b17:	6a 0a                	push   $0xa
80106b19:	e8 26 c1 ff ff       	call   80102c44 <microdelay>
80106b1e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b25:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106b29:	7f 1a                	jg     80106b45 <uartputc+0x4d>
80106b2b:	83 ec 0c             	sub    $0xc,%esp
80106b2e:	68 fd 03 00 00       	push   $0x3fd
80106b33:	e8 97 fe ff ff       	call   801069cf <inb>
80106b38:	83 c4 10             	add    $0x10,%esp
80106b3b:	0f b6 c0             	movzbl %al,%eax
80106b3e:	83 e0 20             	and    $0x20,%eax
80106b41:	85 c0                	test   %eax,%eax
80106b43:	74 cf                	je     80106b14 <uartputc+0x1c>
  outb(COM1+0, c);
80106b45:	8b 45 08             	mov    0x8(%ebp),%eax
80106b48:	0f b6 c0             	movzbl %al,%eax
80106b4b:	83 ec 08             	sub    $0x8,%esp
80106b4e:	50                   	push   %eax
80106b4f:	68 f8 03 00 00       	push   $0x3f8
80106b54:	e8 93 fe ff ff       	call   801069ec <outb>
80106b59:	83 c4 10             	add    $0x10,%esp
80106b5c:	eb 01                	jmp    80106b5f <uartputc+0x67>
    return;
80106b5e:	90                   	nop
}
80106b5f:	c9                   	leave  
80106b60:	c3                   	ret    

80106b61 <uartgetc>:

static int
uartgetc(void)
{
80106b61:	f3 0f 1e fb          	endbr32 
80106b65:	55                   	push   %ebp
80106b66:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106b68:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106b6d:	85 c0                	test   %eax,%eax
80106b6f:	75 07                	jne    80106b78 <uartgetc+0x17>
    return -1;
80106b71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b76:	eb 2e                	jmp    80106ba6 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106b78:	68 fd 03 00 00       	push   $0x3fd
80106b7d:	e8 4d fe ff ff       	call   801069cf <inb>
80106b82:	83 c4 04             	add    $0x4,%esp
80106b85:	0f b6 c0             	movzbl %al,%eax
80106b88:	83 e0 01             	and    $0x1,%eax
80106b8b:	85 c0                	test   %eax,%eax
80106b8d:	75 07                	jne    80106b96 <uartgetc+0x35>
    return -1;
80106b8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b94:	eb 10                	jmp    80106ba6 <uartgetc+0x45>
  return inb(COM1+0);
80106b96:	68 f8 03 00 00       	push   $0x3f8
80106b9b:	e8 2f fe ff ff       	call   801069cf <inb>
80106ba0:	83 c4 04             	add    $0x4,%esp
80106ba3:	0f b6 c0             	movzbl %al,%eax
}
80106ba6:	c9                   	leave  
80106ba7:	c3                   	ret    

80106ba8 <uartintr>:

void
uartintr(void)
{
80106ba8:	f3 0f 1e fb          	endbr32 
80106bac:	55                   	push   %ebp
80106bad:	89 e5                	mov    %esp,%ebp
80106baf:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106bb2:	83 ec 0c             	sub    $0xc,%esp
80106bb5:	68 61 6b 10 80       	push   $0x80106b61
80106bba:	e8 41 9c ff ff       	call   80100800 <consoleintr>
80106bbf:	83 c4 10             	add    $0x10,%esp
}
80106bc2:	90                   	nop
80106bc3:	c9                   	leave  
80106bc4:	c3                   	ret    

80106bc5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106bc5:	6a 00                	push   $0x0
  pushl $0
80106bc7:	6a 00                	push   $0x0
  jmp alltraps
80106bc9:	e9 fa f8 ff ff       	jmp    801064c8 <alltraps>

80106bce <vector1>:
.globl vector1
vector1:
  pushl $0
80106bce:	6a 00                	push   $0x0
  pushl $1
80106bd0:	6a 01                	push   $0x1
  jmp alltraps
80106bd2:	e9 f1 f8 ff ff       	jmp    801064c8 <alltraps>

80106bd7 <vector2>:
.globl vector2
vector2:
  pushl $0
80106bd7:	6a 00                	push   $0x0
  pushl $2
80106bd9:	6a 02                	push   $0x2
  jmp alltraps
80106bdb:	e9 e8 f8 ff ff       	jmp    801064c8 <alltraps>

80106be0 <vector3>:
.globl vector3
vector3:
  pushl $0
80106be0:	6a 00                	push   $0x0
  pushl $3
80106be2:	6a 03                	push   $0x3
  jmp alltraps
80106be4:	e9 df f8 ff ff       	jmp    801064c8 <alltraps>

80106be9 <vector4>:
.globl vector4
vector4:
  pushl $0
80106be9:	6a 00                	push   $0x0
  pushl $4
80106beb:	6a 04                	push   $0x4
  jmp alltraps
80106bed:	e9 d6 f8 ff ff       	jmp    801064c8 <alltraps>

80106bf2 <vector5>:
.globl vector5
vector5:
  pushl $0
80106bf2:	6a 00                	push   $0x0
  pushl $5
80106bf4:	6a 05                	push   $0x5
  jmp alltraps
80106bf6:	e9 cd f8 ff ff       	jmp    801064c8 <alltraps>

80106bfb <vector6>:
.globl vector6
vector6:
  pushl $0
80106bfb:	6a 00                	push   $0x0
  pushl $6
80106bfd:	6a 06                	push   $0x6
  jmp alltraps
80106bff:	e9 c4 f8 ff ff       	jmp    801064c8 <alltraps>

80106c04 <vector7>:
.globl vector7
vector7:
  pushl $0
80106c04:	6a 00                	push   $0x0
  pushl $7
80106c06:	6a 07                	push   $0x7
  jmp alltraps
80106c08:	e9 bb f8 ff ff       	jmp    801064c8 <alltraps>

80106c0d <vector8>:
.globl vector8
vector8:
  pushl $8
80106c0d:	6a 08                	push   $0x8
  jmp alltraps
80106c0f:	e9 b4 f8 ff ff       	jmp    801064c8 <alltraps>

80106c14 <vector9>:
.globl vector9
vector9:
  pushl $0
80106c14:	6a 00                	push   $0x0
  pushl $9
80106c16:	6a 09                	push   $0x9
  jmp alltraps
80106c18:	e9 ab f8 ff ff       	jmp    801064c8 <alltraps>

80106c1d <vector10>:
.globl vector10
vector10:
  pushl $10
80106c1d:	6a 0a                	push   $0xa
  jmp alltraps
80106c1f:	e9 a4 f8 ff ff       	jmp    801064c8 <alltraps>

80106c24 <vector11>:
.globl vector11
vector11:
  pushl $11
80106c24:	6a 0b                	push   $0xb
  jmp alltraps
80106c26:	e9 9d f8 ff ff       	jmp    801064c8 <alltraps>

80106c2b <vector12>:
.globl vector12
vector12:
  pushl $12
80106c2b:	6a 0c                	push   $0xc
  jmp alltraps
80106c2d:	e9 96 f8 ff ff       	jmp    801064c8 <alltraps>

80106c32 <vector13>:
.globl vector13
vector13:
  pushl $13
80106c32:	6a 0d                	push   $0xd
  jmp alltraps
80106c34:	e9 8f f8 ff ff       	jmp    801064c8 <alltraps>

80106c39 <vector14>:
.globl vector14
vector14:
  pushl $14
80106c39:	6a 0e                	push   $0xe
  jmp alltraps
80106c3b:	e9 88 f8 ff ff       	jmp    801064c8 <alltraps>

80106c40 <vector15>:
.globl vector15
vector15:
  pushl $0
80106c40:	6a 00                	push   $0x0
  pushl $15
80106c42:	6a 0f                	push   $0xf
  jmp alltraps
80106c44:	e9 7f f8 ff ff       	jmp    801064c8 <alltraps>

80106c49 <vector16>:
.globl vector16
vector16:
  pushl $0
80106c49:	6a 00                	push   $0x0
  pushl $16
80106c4b:	6a 10                	push   $0x10
  jmp alltraps
80106c4d:	e9 76 f8 ff ff       	jmp    801064c8 <alltraps>

80106c52 <vector17>:
.globl vector17
vector17:
  pushl $17
80106c52:	6a 11                	push   $0x11
  jmp alltraps
80106c54:	e9 6f f8 ff ff       	jmp    801064c8 <alltraps>

80106c59 <vector18>:
.globl vector18
vector18:
  pushl $0
80106c59:	6a 00                	push   $0x0
  pushl $18
80106c5b:	6a 12                	push   $0x12
  jmp alltraps
80106c5d:	e9 66 f8 ff ff       	jmp    801064c8 <alltraps>

80106c62 <vector19>:
.globl vector19
vector19:
  pushl $0
80106c62:	6a 00                	push   $0x0
  pushl $19
80106c64:	6a 13                	push   $0x13
  jmp alltraps
80106c66:	e9 5d f8 ff ff       	jmp    801064c8 <alltraps>

80106c6b <vector20>:
.globl vector20
vector20:
  pushl $0
80106c6b:	6a 00                	push   $0x0
  pushl $20
80106c6d:	6a 14                	push   $0x14
  jmp alltraps
80106c6f:	e9 54 f8 ff ff       	jmp    801064c8 <alltraps>

80106c74 <vector21>:
.globl vector21
vector21:
  pushl $0
80106c74:	6a 00                	push   $0x0
  pushl $21
80106c76:	6a 15                	push   $0x15
  jmp alltraps
80106c78:	e9 4b f8 ff ff       	jmp    801064c8 <alltraps>

80106c7d <vector22>:
.globl vector22
vector22:
  pushl $0
80106c7d:	6a 00                	push   $0x0
  pushl $22
80106c7f:	6a 16                	push   $0x16
  jmp alltraps
80106c81:	e9 42 f8 ff ff       	jmp    801064c8 <alltraps>

80106c86 <vector23>:
.globl vector23
vector23:
  pushl $0
80106c86:	6a 00                	push   $0x0
  pushl $23
80106c88:	6a 17                	push   $0x17
  jmp alltraps
80106c8a:	e9 39 f8 ff ff       	jmp    801064c8 <alltraps>

80106c8f <vector24>:
.globl vector24
vector24:
  pushl $0
80106c8f:	6a 00                	push   $0x0
  pushl $24
80106c91:	6a 18                	push   $0x18
  jmp alltraps
80106c93:	e9 30 f8 ff ff       	jmp    801064c8 <alltraps>

80106c98 <vector25>:
.globl vector25
vector25:
  pushl $0
80106c98:	6a 00                	push   $0x0
  pushl $25
80106c9a:	6a 19                	push   $0x19
  jmp alltraps
80106c9c:	e9 27 f8 ff ff       	jmp    801064c8 <alltraps>

80106ca1 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ca1:	6a 00                	push   $0x0
  pushl $26
80106ca3:	6a 1a                	push   $0x1a
  jmp alltraps
80106ca5:	e9 1e f8 ff ff       	jmp    801064c8 <alltraps>

80106caa <vector27>:
.globl vector27
vector27:
  pushl $0
80106caa:	6a 00                	push   $0x0
  pushl $27
80106cac:	6a 1b                	push   $0x1b
  jmp alltraps
80106cae:	e9 15 f8 ff ff       	jmp    801064c8 <alltraps>

80106cb3 <vector28>:
.globl vector28
vector28:
  pushl $0
80106cb3:	6a 00                	push   $0x0
  pushl $28
80106cb5:	6a 1c                	push   $0x1c
  jmp alltraps
80106cb7:	e9 0c f8 ff ff       	jmp    801064c8 <alltraps>

80106cbc <vector29>:
.globl vector29
vector29:
  pushl $0
80106cbc:	6a 00                	push   $0x0
  pushl $29
80106cbe:	6a 1d                	push   $0x1d
  jmp alltraps
80106cc0:	e9 03 f8 ff ff       	jmp    801064c8 <alltraps>

80106cc5 <vector30>:
.globl vector30
vector30:
  pushl $0
80106cc5:	6a 00                	push   $0x0
  pushl $30
80106cc7:	6a 1e                	push   $0x1e
  jmp alltraps
80106cc9:	e9 fa f7 ff ff       	jmp    801064c8 <alltraps>

80106cce <vector31>:
.globl vector31
vector31:
  pushl $0
80106cce:	6a 00                	push   $0x0
  pushl $31
80106cd0:	6a 1f                	push   $0x1f
  jmp alltraps
80106cd2:	e9 f1 f7 ff ff       	jmp    801064c8 <alltraps>

80106cd7 <vector32>:
.globl vector32
vector32:
  pushl $0
80106cd7:	6a 00                	push   $0x0
  pushl $32
80106cd9:	6a 20                	push   $0x20
  jmp alltraps
80106cdb:	e9 e8 f7 ff ff       	jmp    801064c8 <alltraps>

80106ce0 <vector33>:
.globl vector33
vector33:
  pushl $0
80106ce0:	6a 00                	push   $0x0
  pushl $33
80106ce2:	6a 21                	push   $0x21
  jmp alltraps
80106ce4:	e9 df f7 ff ff       	jmp    801064c8 <alltraps>

80106ce9 <vector34>:
.globl vector34
vector34:
  pushl $0
80106ce9:	6a 00                	push   $0x0
  pushl $34
80106ceb:	6a 22                	push   $0x22
  jmp alltraps
80106ced:	e9 d6 f7 ff ff       	jmp    801064c8 <alltraps>

80106cf2 <vector35>:
.globl vector35
vector35:
  pushl $0
80106cf2:	6a 00                	push   $0x0
  pushl $35
80106cf4:	6a 23                	push   $0x23
  jmp alltraps
80106cf6:	e9 cd f7 ff ff       	jmp    801064c8 <alltraps>

80106cfb <vector36>:
.globl vector36
vector36:
  pushl $0
80106cfb:	6a 00                	push   $0x0
  pushl $36
80106cfd:	6a 24                	push   $0x24
  jmp alltraps
80106cff:	e9 c4 f7 ff ff       	jmp    801064c8 <alltraps>

80106d04 <vector37>:
.globl vector37
vector37:
  pushl $0
80106d04:	6a 00                	push   $0x0
  pushl $37
80106d06:	6a 25                	push   $0x25
  jmp alltraps
80106d08:	e9 bb f7 ff ff       	jmp    801064c8 <alltraps>

80106d0d <vector38>:
.globl vector38
vector38:
  pushl $0
80106d0d:	6a 00                	push   $0x0
  pushl $38
80106d0f:	6a 26                	push   $0x26
  jmp alltraps
80106d11:	e9 b2 f7 ff ff       	jmp    801064c8 <alltraps>

80106d16 <vector39>:
.globl vector39
vector39:
  pushl $0
80106d16:	6a 00                	push   $0x0
  pushl $39
80106d18:	6a 27                	push   $0x27
  jmp alltraps
80106d1a:	e9 a9 f7 ff ff       	jmp    801064c8 <alltraps>

80106d1f <vector40>:
.globl vector40
vector40:
  pushl $0
80106d1f:	6a 00                	push   $0x0
  pushl $40
80106d21:	6a 28                	push   $0x28
  jmp alltraps
80106d23:	e9 a0 f7 ff ff       	jmp    801064c8 <alltraps>

80106d28 <vector41>:
.globl vector41
vector41:
  pushl $0
80106d28:	6a 00                	push   $0x0
  pushl $41
80106d2a:	6a 29                	push   $0x29
  jmp alltraps
80106d2c:	e9 97 f7 ff ff       	jmp    801064c8 <alltraps>

80106d31 <vector42>:
.globl vector42
vector42:
  pushl $0
80106d31:	6a 00                	push   $0x0
  pushl $42
80106d33:	6a 2a                	push   $0x2a
  jmp alltraps
80106d35:	e9 8e f7 ff ff       	jmp    801064c8 <alltraps>

80106d3a <vector43>:
.globl vector43
vector43:
  pushl $0
80106d3a:	6a 00                	push   $0x0
  pushl $43
80106d3c:	6a 2b                	push   $0x2b
  jmp alltraps
80106d3e:	e9 85 f7 ff ff       	jmp    801064c8 <alltraps>

80106d43 <vector44>:
.globl vector44
vector44:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $44
80106d45:	6a 2c                	push   $0x2c
  jmp alltraps
80106d47:	e9 7c f7 ff ff       	jmp    801064c8 <alltraps>

80106d4c <vector45>:
.globl vector45
vector45:
  pushl $0
80106d4c:	6a 00                	push   $0x0
  pushl $45
80106d4e:	6a 2d                	push   $0x2d
  jmp alltraps
80106d50:	e9 73 f7 ff ff       	jmp    801064c8 <alltraps>

80106d55 <vector46>:
.globl vector46
vector46:
  pushl $0
80106d55:	6a 00                	push   $0x0
  pushl $46
80106d57:	6a 2e                	push   $0x2e
  jmp alltraps
80106d59:	e9 6a f7 ff ff       	jmp    801064c8 <alltraps>

80106d5e <vector47>:
.globl vector47
vector47:
  pushl $0
80106d5e:	6a 00                	push   $0x0
  pushl $47
80106d60:	6a 2f                	push   $0x2f
  jmp alltraps
80106d62:	e9 61 f7 ff ff       	jmp    801064c8 <alltraps>

80106d67 <vector48>:
.globl vector48
vector48:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $48
80106d69:	6a 30                	push   $0x30
  jmp alltraps
80106d6b:	e9 58 f7 ff ff       	jmp    801064c8 <alltraps>

80106d70 <vector49>:
.globl vector49
vector49:
  pushl $0
80106d70:	6a 00                	push   $0x0
  pushl $49
80106d72:	6a 31                	push   $0x31
  jmp alltraps
80106d74:	e9 4f f7 ff ff       	jmp    801064c8 <alltraps>

80106d79 <vector50>:
.globl vector50
vector50:
  pushl $0
80106d79:	6a 00                	push   $0x0
  pushl $50
80106d7b:	6a 32                	push   $0x32
  jmp alltraps
80106d7d:	e9 46 f7 ff ff       	jmp    801064c8 <alltraps>

80106d82 <vector51>:
.globl vector51
vector51:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $51
80106d84:	6a 33                	push   $0x33
  jmp alltraps
80106d86:	e9 3d f7 ff ff       	jmp    801064c8 <alltraps>

80106d8b <vector52>:
.globl vector52
vector52:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $52
80106d8d:	6a 34                	push   $0x34
  jmp alltraps
80106d8f:	e9 34 f7 ff ff       	jmp    801064c8 <alltraps>

80106d94 <vector53>:
.globl vector53
vector53:
  pushl $0
80106d94:	6a 00                	push   $0x0
  pushl $53
80106d96:	6a 35                	push   $0x35
  jmp alltraps
80106d98:	e9 2b f7 ff ff       	jmp    801064c8 <alltraps>

80106d9d <vector54>:
.globl vector54
vector54:
  pushl $0
80106d9d:	6a 00                	push   $0x0
  pushl $54
80106d9f:	6a 36                	push   $0x36
  jmp alltraps
80106da1:	e9 22 f7 ff ff       	jmp    801064c8 <alltraps>

80106da6 <vector55>:
.globl vector55
vector55:
  pushl $0
80106da6:	6a 00                	push   $0x0
  pushl $55
80106da8:	6a 37                	push   $0x37
  jmp alltraps
80106daa:	e9 19 f7 ff ff       	jmp    801064c8 <alltraps>

80106daf <vector56>:
.globl vector56
vector56:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $56
80106db1:	6a 38                	push   $0x38
  jmp alltraps
80106db3:	e9 10 f7 ff ff       	jmp    801064c8 <alltraps>

80106db8 <vector57>:
.globl vector57
vector57:
  pushl $0
80106db8:	6a 00                	push   $0x0
  pushl $57
80106dba:	6a 39                	push   $0x39
  jmp alltraps
80106dbc:	e9 07 f7 ff ff       	jmp    801064c8 <alltraps>

80106dc1 <vector58>:
.globl vector58
vector58:
  pushl $0
80106dc1:	6a 00                	push   $0x0
  pushl $58
80106dc3:	6a 3a                	push   $0x3a
  jmp alltraps
80106dc5:	e9 fe f6 ff ff       	jmp    801064c8 <alltraps>

80106dca <vector59>:
.globl vector59
vector59:
  pushl $0
80106dca:	6a 00                	push   $0x0
  pushl $59
80106dcc:	6a 3b                	push   $0x3b
  jmp alltraps
80106dce:	e9 f5 f6 ff ff       	jmp    801064c8 <alltraps>

80106dd3 <vector60>:
.globl vector60
vector60:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $60
80106dd5:	6a 3c                	push   $0x3c
  jmp alltraps
80106dd7:	e9 ec f6 ff ff       	jmp    801064c8 <alltraps>

80106ddc <vector61>:
.globl vector61
vector61:
  pushl $0
80106ddc:	6a 00                	push   $0x0
  pushl $61
80106dde:	6a 3d                	push   $0x3d
  jmp alltraps
80106de0:	e9 e3 f6 ff ff       	jmp    801064c8 <alltraps>

80106de5 <vector62>:
.globl vector62
vector62:
  pushl $0
80106de5:	6a 00                	push   $0x0
  pushl $62
80106de7:	6a 3e                	push   $0x3e
  jmp alltraps
80106de9:	e9 da f6 ff ff       	jmp    801064c8 <alltraps>

80106dee <vector63>:
.globl vector63
vector63:
  pushl $0
80106dee:	6a 00                	push   $0x0
  pushl $63
80106df0:	6a 3f                	push   $0x3f
  jmp alltraps
80106df2:	e9 d1 f6 ff ff       	jmp    801064c8 <alltraps>

80106df7 <vector64>:
.globl vector64
vector64:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $64
80106df9:	6a 40                	push   $0x40
  jmp alltraps
80106dfb:	e9 c8 f6 ff ff       	jmp    801064c8 <alltraps>

80106e00 <vector65>:
.globl vector65
vector65:
  pushl $0
80106e00:	6a 00                	push   $0x0
  pushl $65
80106e02:	6a 41                	push   $0x41
  jmp alltraps
80106e04:	e9 bf f6 ff ff       	jmp    801064c8 <alltraps>

80106e09 <vector66>:
.globl vector66
vector66:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $66
80106e0b:	6a 42                	push   $0x42
  jmp alltraps
80106e0d:	e9 b6 f6 ff ff       	jmp    801064c8 <alltraps>

80106e12 <vector67>:
.globl vector67
vector67:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $67
80106e14:	6a 43                	push   $0x43
  jmp alltraps
80106e16:	e9 ad f6 ff ff       	jmp    801064c8 <alltraps>

80106e1b <vector68>:
.globl vector68
vector68:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $68
80106e1d:	6a 44                	push   $0x44
  jmp alltraps
80106e1f:	e9 a4 f6 ff ff       	jmp    801064c8 <alltraps>

80106e24 <vector69>:
.globl vector69
vector69:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $69
80106e26:	6a 45                	push   $0x45
  jmp alltraps
80106e28:	e9 9b f6 ff ff       	jmp    801064c8 <alltraps>

80106e2d <vector70>:
.globl vector70
vector70:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $70
80106e2f:	6a 46                	push   $0x46
  jmp alltraps
80106e31:	e9 92 f6 ff ff       	jmp    801064c8 <alltraps>

80106e36 <vector71>:
.globl vector71
vector71:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $71
80106e38:	6a 47                	push   $0x47
  jmp alltraps
80106e3a:	e9 89 f6 ff ff       	jmp    801064c8 <alltraps>

80106e3f <vector72>:
.globl vector72
vector72:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $72
80106e41:	6a 48                	push   $0x48
  jmp alltraps
80106e43:	e9 80 f6 ff ff       	jmp    801064c8 <alltraps>

80106e48 <vector73>:
.globl vector73
vector73:
  pushl $0
80106e48:	6a 00                	push   $0x0
  pushl $73
80106e4a:	6a 49                	push   $0x49
  jmp alltraps
80106e4c:	e9 77 f6 ff ff       	jmp    801064c8 <alltraps>

80106e51 <vector74>:
.globl vector74
vector74:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $74
80106e53:	6a 4a                	push   $0x4a
  jmp alltraps
80106e55:	e9 6e f6 ff ff       	jmp    801064c8 <alltraps>

80106e5a <vector75>:
.globl vector75
vector75:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $75
80106e5c:	6a 4b                	push   $0x4b
  jmp alltraps
80106e5e:	e9 65 f6 ff ff       	jmp    801064c8 <alltraps>

80106e63 <vector76>:
.globl vector76
vector76:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $76
80106e65:	6a 4c                	push   $0x4c
  jmp alltraps
80106e67:	e9 5c f6 ff ff       	jmp    801064c8 <alltraps>

80106e6c <vector77>:
.globl vector77
vector77:
  pushl $0
80106e6c:	6a 00                	push   $0x0
  pushl $77
80106e6e:	6a 4d                	push   $0x4d
  jmp alltraps
80106e70:	e9 53 f6 ff ff       	jmp    801064c8 <alltraps>

80106e75 <vector78>:
.globl vector78
vector78:
  pushl $0
80106e75:	6a 00                	push   $0x0
  pushl $78
80106e77:	6a 4e                	push   $0x4e
  jmp alltraps
80106e79:	e9 4a f6 ff ff       	jmp    801064c8 <alltraps>

80106e7e <vector79>:
.globl vector79
vector79:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $79
80106e80:	6a 4f                	push   $0x4f
  jmp alltraps
80106e82:	e9 41 f6 ff ff       	jmp    801064c8 <alltraps>

80106e87 <vector80>:
.globl vector80
vector80:
  pushl $0
80106e87:	6a 00                	push   $0x0
  pushl $80
80106e89:	6a 50                	push   $0x50
  jmp alltraps
80106e8b:	e9 38 f6 ff ff       	jmp    801064c8 <alltraps>

80106e90 <vector81>:
.globl vector81
vector81:
  pushl $0
80106e90:	6a 00                	push   $0x0
  pushl $81
80106e92:	6a 51                	push   $0x51
  jmp alltraps
80106e94:	e9 2f f6 ff ff       	jmp    801064c8 <alltraps>

80106e99 <vector82>:
.globl vector82
vector82:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $82
80106e9b:	6a 52                	push   $0x52
  jmp alltraps
80106e9d:	e9 26 f6 ff ff       	jmp    801064c8 <alltraps>

80106ea2 <vector83>:
.globl vector83
vector83:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $83
80106ea4:	6a 53                	push   $0x53
  jmp alltraps
80106ea6:	e9 1d f6 ff ff       	jmp    801064c8 <alltraps>

80106eab <vector84>:
.globl vector84
vector84:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $84
80106ead:	6a 54                	push   $0x54
  jmp alltraps
80106eaf:	e9 14 f6 ff ff       	jmp    801064c8 <alltraps>

80106eb4 <vector85>:
.globl vector85
vector85:
  pushl $0
80106eb4:	6a 00                	push   $0x0
  pushl $85
80106eb6:	6a 55                	push   $0x55
  jmp alltraps
80106eb8:	e9 0b f6 ff ff       	jmp    801064c8 <alltraps>

80106ebd <vector86>:
.globl vector86
vector86:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $86
80106ebf:	6a 56                	push   $0x56
  jmp alltraps
80106ec1:	e9 02 f6 ff ff       	jmp    801064c8 <alltraps>

80106ec6 <vector87>:
.globl vector87
vector87:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $87
80106ec8:	6a 57                	push   $0x57
  jmp alltraps
80106eca:	e9 f9 f5 ff ff       	jmp    801064c8 <alltraps>

80106ecf <vector88>:
.globl vector88
vector88:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $88
80106ed1:	6a 58                	push   $0x58
  jmp alltraps
80106ed3:	e9 f0 f5 ff ff       	jmp    801064c8 <alltraps>

80106ed8 <vector89>:
.globl vector89
vector89:
  pushl $0
80106ed8:	6a 00                	push   $0x0
  pushl $89
80106eda:	6a 59                	push   $0x59
  jmp alltraps
80106edc:	e9 e7 f5 ff ff       	jmp    801064c8 <alltraps>

80106ee1 <vector90>:
.globl vector90
vector90:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $90
80106ee3:	6a 5a                	push   $0x5a
  jmp alltraps
80106ee5:	e9 de f5 ff ff       	jmp    801064c8 <alltraps>

80106eea <vector91>:
.globl vector91
vector91:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $91
80106eec:	6a 5b                	push   $0x5b
  jmp alltraps
80106eee:	e9 d5 f5 ff ff       	jmp    801064c8 <alltraps>

80106ef3 <vector92>:
.globl vector92
vector92:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $92
80106ef5:	6a 5c                	push   $0x5c
  jmp alltraps
80106ef7:	e9 cc f5 ff ff       	jmp    801064c8 <alltraps>

80106efc <vector93>:
.globl vector93
vector93:
  pushl $0
80106efc:	6a 00                	push   $0x0
  pushl $93
80106efe:	6a 5d                	push   $0x5d
  jmp alltraps
80106f00:	e9 c3 f5 ff ff       	jmp    801064c8 <alltraps>

80106f05 <vector94>:
.globl vector94
vector94:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $94
80106f07:	6a 5e                	push   $0x5e
  jmp alltraps
80106f09:	e9 ba f5 ff ff       	jmp    801064c8 <alltraps>

80106f0e <vector95>:
.globl vector95
vector95:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $95
80106f10:	6a 5f                	push   $0x5f
  jmp alltraps
80106f12:	e9 b1 f5 ff ff       	jmp    801064c8 <alltraps>

80106f17 <vector96>:
.globl vector96
vector96:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $96
80106f19:	6a 60                	push   $0x60
  jmp alltraps
80106f1b:	e9 a8 f5 ff ff       	jmp    801064c8 <alltraps>

80106f20 <vector97>:
.globl vector97
vector97:
  pushl $0
80106f20:	6a 00                	push   $0x0
  pushl $97
80106f22:	6a 61                	push   $0x61
  jmp alltraps
80106f24:	e9 9f f5 ff ff       	jmp    801064c8 <alltraps>

80106f29 <vector98>:
.globl vector98
vector98:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $98
80106f2b:	6a 62                	push   $0x62
  jmp alltraps
80106f2d:	e9 96 f5 ff ff       	jmp    801064c8 <alltraps>

80106f32 <vector99>:
.globl vector99
vector99:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $99
80106f34:	6a 63                	push   $0x63
  jmp alltraps
80106f36:	e9 8d f5 ff ff       	jmp    801064c8 <alltraps>

80106f3b <vector100>:
.globl vector100
vector100:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $100
80106f3d:	6a 64                	push   $0x64
  jmp alltraps
80106f3f:	e9 84 f5 ff ff       	jmp    801064c8 <alltraps>

80106f44 <vector101>:
.globl vector101
vector101:
  pushl $0
80106f44:	6a 00                	push   $0x0
  pushl $101
80106f46:	6a 65                	push   $0x65
  jmp alltraps
80106f48:	e9 7b f5 ff ff       	jmp    801064c8 <alltraps>

80106f4d <vector102>:
.globl vector102
vector102:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $102
80106f4f:	6a 66                	push   $0x66
  jmp alltraps
80106f51:	e9 72 f5 ff ff       	jmp    801064c8 <alltraps>

80106f56 <vector103>:
.globl vector103
vector103:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $103
80106f58:	6a 67                	push   $0x67
  jmp alltraps
80106f5a:	e9 69 f5 ff ff       	jmp    801064c8 <alltraps>

80106f5f <vector104>:
.globl vector104
vector104:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $104
80106f61:	6a 68                	push   $0x68
  jmp alltraps
80106f63:	e9 60 f5 ff ff       	jmp    801064c8 <alltraps>

80106f68 <vector105>:
.globl vector105
vector105:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $105
80106f6a:	6a 69                	push   $0x69
  jmp alltraps
80106f6c:	e9 57 f5 ff ff       	jmp    801064c8 <alltraps>

80106f71 <vector106>:
.globl vector106
vector106:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $106
80106f73:	6a 6a                	push   $0x6a
  jmp alltraps
80106f75:	e9 4e f5 ff ff       	jmp    801064c8 <alltraps>

80106f7a <vector107>:
.globl vector107
vector107:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $107
80106f7c:	6a 6b                	push   $0x6b
  jmp alltraps
80106f7e:	e9 45 f5 ff ff       	jmp    801064c8 <alltraps>

80106f83 <vector108>:
.globl vector108
vector108:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $108
80106f85:	6a 6c                	push   $0x6c
  jmp alltraps
80106f87:	e9 3c f5 ff ff       	jmp    801064c8 <alltraps>

80106f8c <vector109>:
.globl vector109
vector109:
  pushl $0
80106f8c:	6a 00                	push   $0x0
  pushl $109
80106f8e:	6a 6d                	push   $0x6d
  jmp alltraps
80106f90:	e9 33 f5 ff ff       	jmp    801064c8 <alltraps>

80106f95 <vector110>:
.globl vector110
vector110:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $110
80106f97:	6a 6e                	push   $0x6e
  jmp alltraps
80106f99:	e9 2a f5 ff ff       	jmp    801064c8 <alltraps>

80106f9e <vector111>:
.globl vector111
vector111:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $111
80106fa0:	6a 6f                	push   $0x6f
  jmp alltraps
80106fa2:	e9 21 f5 ff ff       	jmp    801064c8 <alltraps>

80106fa7 <vector112>:
.globl vector112
vector112:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $112
80106fa9:	6a 70                	push   $0x70
  jmp alltraps
80106fab:	e9 18 f5 ff ff       	jmp    801064c8 <alltraps>

80106fb0 <vector113>:
.globl vector113
vector113:
  pushl $0
80106fb0:	6a 00                	push   $0x0
  pushl $113
80106fb2:	6a 71                	push   $0x71
  jmp alltraps
80106fb4:	e9 0f f5 ff ff       	jmp    801064c8 <alltraps>

80106fb9 <vector114>:
.globl vector114
vector114:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $114
80106fbb:	6a 72                	push   $0x72
  jmp alltraps
80106fbd:	e9 06 f5 ff ff       	jmp    801064c8 <alltraps>

80106fc2 <vector115>:
.globl vector115
vector115:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $115
80106fc4:	6a 73                	push   $0x73
  jmp alltraps
80106fc6:	e9 fd f4 ff ff       	jmp    801064c8 <alltraps>

80106fcb <vector116>:
.globl vector116
vector116:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $116
80106fcd:	6a 74                	push   $0x74
  jmp alltraps
80106fcf:	e9 f4 f4 ff ff       	jmp    801064c8 <alltraps>

80106fd4 <vector117>:
.globl vector117
vector117:
  pushl $0
80106fd4:	6a 00                	push   $0x0
  pushl $117
80106fd6:	6a 75                	push   $0x75
  jmp alltraps
80106fd8:	e9 eb f4 ff ff       	jmp    801064c8 <alltraps>

80106fdd <vector118>:
.globl vector118
vector118:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $118
80106fdf:	6a 76                	push   $0x76
  jmp alltraps
80106fe1:	e9 e2 f4 ff ff       	jmp    801064c8 <alltraps>

80106fe6 <vector119>:
.globl vector119
vector119:
  pushl $0
80106fe6:	6a 00                	push   $0x0
  pushl $119
80106fe8:	6a 77                	push   $0x77
  jmp alltraps
80106fea:	e9 d9 f4 ff ff       	jmp    801064c8 <alltraps>

80106fef <vector120>:
.globl vector120
vector120:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $120
80106ff1:	6a 78                	push   $0x78
  jmp alltraps
80106ff3:	e9 d0 f4 ff ff       	jmp    801064c8 <alltraps>

80106ff8 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ff8:	6a 00                	push   $0x0
  pushl $121
80106ffa:	6a 79                	push   $0x79
  jmp alltraps
80106ffc:	e9 c7 f4 ff ff       	jmp    801064c8 <alltraps>

80107001 <vector122>:
.globl vector122
vector122:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $122
80107003:	6a 7a                	push   $0x7a
  jmp alltraps
80107005:	e9 be f4 ff ff       	jmp    801064c8 <alltraps>

8010700a <vector123>:
.globl vector123
vector123:
  pushl $0
8010700a:	6a 00                	push   $0x0
  pushl $123
8010700c:	6a 7b                	push   $0x7b
  jmp alltraps
8010700e:	e9 b5 f4 ff ff       	jmp    801064c8 <alltraps>

80107013 <vector124>:
.globl vector124
vector124:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $124
80107015:	6a 7c                	push   $0x7c
  jmp alltraps
80107017:	e9 ac f4 ff ff       	jmp    801064c8 <alltraps>

8010701c <vector125>:
.globl vector125
vector125:
  pushl $0
8010701c:	6a 00                	push   $0x0
  pushl $125
8010701e:	6a 7d                	push   $0x7d
  jmp alltraps
80107020:	e9 a3 f4 ff ff       	jmp    801064c8 <alltraps>

80107025 <vector126>:
.globl vector126
vector126:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $126
80107027:	6a 7e                	push   $0x7e
  jmp alltraps
80107029:	e9 9a f4 ff ff       	jmp    801064c8 <alltraps>

8010702e <vector127>:
.globl vector127
vector127:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $127
80107030:	6a 7f                	push   $0x7f
  jmp alltraps
80107032:	e9 91 f4 ff ff       	jmp    801064c8 <alltraps>

80107037 <vector128>:
.globl vector128
vector128:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $128
80107039:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010703e:	e9 85 f4 ff ff       	jmp    801064c8 <alltraps>

80107043 <vector129>:
.globl vector129
vector129:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $129
80107045:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010704a:	e9 79 f4 ff ff       	jmp    801064c8 <alltraps>

8010704f <vector130>:
.globl vector130
vector130:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $130
80107051:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107056:	e9 6d f4 ff ff       	jmp    801064c8 <alltraps>

8010705b <vector131>:
.globl vector131
vector131:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $131
8010705d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107062:	e9 61 f4 ff ff       	jmp    801064c8 <alltraps>

80107067 <vector132>:
.globl vector132
vector132:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $132
80107069:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010706e:	e9 55 f4 ff ff       	jmp    801064c8 <alltraps>

80107073 <vector133>:
.globl vector133
vector133:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $133
80107075:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010707a:	e9 49 f4 ff ff       	jmp    801064c8 <alltraps>

8010707f <vector134>:
.globl vector134
vector134:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $134
80107081:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107086:	e9 3d f4 ff ff       	jmp    801064c8 <alltraps>

8010708b <vector135>:
.globl vector135
vector135:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $135
8010708d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107092:	e9 31 f4 ff ff       	jmp    801064c8 <alltraps>

80107097 <vector136>:
.globl vector136
vector136:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $136
80107099:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010709e:	e9 25 f4 ff ff       	jmp    801064c8 <alltraps>

801070a3 <vector137>:
.globl vector137
vector137:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $137
801070a5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801070aa:	e9 19 f4 ff ff       	jmp    801064c8 <alltraps>

801070af <vector138>:
.globl vector138
vector138:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $138
801070b1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801070b6:	e9 0d f4 ff ff       	jmp    801064c8 <alltraps>

801070bb <vector139>:
.globl vector139
vector139:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $139
801070bd:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801070c2:	e9 01 f4 ff ff       	jmp    801064c8 <alltraps>

801070c7 <vector140>:
.globl vector140
vector140:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $140
801070c9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801070ce:	e9 f5 f3 ff ff       	jmp    801064c8 <alltraps>

801070d3 <vector141>:
.globl vector141
vector141:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $141
801070d5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801070da:	e9 e9 f3 ff ff       	jmp    801064c8 <alltraps>

801070df <vector142>:
.globl vector142
vector142:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $142
801070e1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801070e6:	e9 dd f3 ff ff       	jmp    801064c8 <alltraps>

801070eb <vector143>:
.globl vector143
vector143:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $143
801070ed:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801070f2:	e9 d1 f3 ff ff       	jmp    801064c8 <alltraps>

801070f7 <vector144>:
.globl vector144
vector144:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $144
801070f9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801070fe:	e9 c5 f3 ff ff       	jmp    801064c8 <alltraps>

80107103 <vector145>:
.globl vector145
vector145:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $145
80107105:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010710a:	e9 b9 f3 ff ff       	jmp    801064c8 <alltraps>

8010710f <vector146>:
.globl vector146
vector146:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $146
80107111:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107116:	e9 ad f3 ff ff       	jmp    801064c8 <alltraps>

8010711b <vector147>:
.globl vector147
vector147:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $147
8010711d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107122:	e9 a1 f3 ff ff       	jmp    801064c8 <alltraps>

80107127 <vector148>:
.globl vector148
vector148:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $148
80107129:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010712e:	e9 95 f3 ff ff       	jmp    801064c8 <alltraps>

80107133 <vector149>:
.globl vector149
vector149:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $149
80107135:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010713a:	e9 89 f3 ff ff       	jmp    801064c8 <alltraps>

8010713f <vector150>:
.globl vector150
vector150:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $150
80107141:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107146:	e9 7d f3 ff ff       	jmp    801064c8 <alltraps>

8010714b <vector151>:
.globl vector151
vector151:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $151
8010714d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107152:	e9 71 f3 ff ff       	jmp    801064c8 <alltraps>

80107157 <vector152>:
.globl vector152
vector152:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $152
80107159:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010715e:	e9 65 f3 ff ff       	jmp    801064c8 <alltraps>

80107163 <vector153>:
.globl vector153
vector153:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $153
80107165:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010716a:	e9 59 f3 ff ff       	jmp    801064c8 <alltraps>

8010716f <vector154>:
.globl vector154
vector154:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $154
80107171:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107176:	e9 4d f3 ff ff       	jmp    801064c8 <alltraps>

8010717b <vector155>:
.globl vector155
vector155:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $155
8010717d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107182:	e9 41 f3 ff ff       	jmp    801064c8 <alltraps>

80107187 <vector156>:
.globl vector156
vector156:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $156
80107189:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010718e:	e9 35 f3 ff ff       	jmp    801064c8 <alltraps>

80107193 <vector157>:
.globl vector157
vector157:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $157
80107195:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010719a:	e9 29 f3 ff ff       	jmp    801064c8 <alltraps>

8010719f <vector158>:
.globl vector158
vector158:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $158
801071a1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801071a6:	e9 1d f3 ff ff       	jmp    801064c8 <alltraps>

801071ab <vector159>:
.globl vector159
vector159:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $159
801071ad:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801071b2:	e9 11 f3 ff ff       	jmp    801064c8 <alltraps>

801071b7 <vector160>:
.globl vector160
vector160:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $160
801071b9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801071be:	e9 05 f3 ff ff       	jmp    801064c8 <alltraps>

801071c3 <vector161>:
.globl vector161
vector161:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $161
801071c5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801071ca:	e9 f9 f2 ff ff       	jmp    801064c8 <alltraps>

801071cf <vector162>:
.globl vector162
vector162:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $162
801071d1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801071d6:	e9 ed f2 ff ff       	jmp    801064c8 <alltraps>

801071db <vector163>:
.globl vector163
vector163:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $163
801071dd:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801071e2:	e9 e1 f2 ff ff       	jmp    801064c8 <alltraps>

801071e7 <vector164>:
.globl vector164
vector164:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $164
801071e9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801071ee:	e9 d5 f2 ff ff       	jmp    801064c8 <alltraps>

801071f3 <vector165>:
.globl vector165
vector165:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $165
801071f5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801071fa:	e9 c9 f2 ff ff       	jmp    801064c8 <alltraps>

801071ff <vector166>:
.globl vector166
vector166:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $166
80107201:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107206:	e9 bd f2 ff ff       	jmp    801064c8 <alltraps>

8010720b <vector167>:
.globl vector167
vector167:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $167
8010720d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107212:	e9 b1 f2 ff ff       	jmp    801064c8 <alltraps>

80107217 <vector168>:
.globl vector168
vector168:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $168
80107219:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010721e:	e9 a5 f2 ff ff       	jmp    801064c8 <alltraps>

80107223 <vector169>:
.globl vector169
vector169:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $169
80107225:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010722a:	e9 99 f2 ff ff       	jmp    801064c8 <alltraps>

8010722f <vector170>:
.globl vector170
vector170:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $170
80107231:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107236:	e9 8d f2 ff ff       	jmp    801064c8 <alltraps>

8010723b <vector171>:
.globl vector171
vector171:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $171
8010723d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107242:	e9 81 f2 ff ff       	jmp    801064c8 <alltraps>

80107247 <vector172>:
.globl vector172
vector172:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $172
80107249:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010724e:	e9 75 f2 ff ff       	jmp    801064c8 <alltraps>

80107253 <vector173>:
.globl vector173
vector173:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $173
80107255:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010725a:	e9 69 f2 ff ff       	jmp    801064c8 <alltraps>

8010725f <vector174>:
.globl vector174
vector174:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $174
80107261:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107266:	e9 5d f2 ff ff       	jmp    801064c8 <alltraps>

8010726b <vector175>:
.globl vector175
vector175:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $175
8010726d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107272:	e9 51 f2 ff ff       	jmp    801064c8 <alltraps>

80107277 <vector176>:
.globl vector176
vector176:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $176
80107279:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010727e:	e9 45 f2 ff ff       	jmp    801064c8 <alltraps>

80107283 <vector177>:
.globl vector177
vector177:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $177
80107285:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010728a:	e9 39 f2 ff ff       	jmp    801064c8 <alltraps>

8010728f <vector178>:
.globl vector178
vector178:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $178
80107291:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107296:	e9 2d f2 ff ff       	jmp    801064c8 <alltraps>

8010729b <vector179>:
.globl vector179
vector179:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $179
8010729d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801072a2:	e9 21 f2 ff ff       	jmp    801064c8 <alltraps>

801072a7 <vector180>:
.globl vector180
vector180:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $180
801072a9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801072ae:	e9 15 f2 ff ff       	jmp    801064c8 <alltraps>

801072b3 <vector181>:
.globl vector181
vector181:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $181
801072b5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801072ba:	e9 09 f2 ff ff       	jmp    801064c8 <alltraps>

801072bf <vector182>:
.globl vector182
vector182:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $182
801072c1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801072c6:	e9 fd f1 ff ff       	jmp    801064c8 <alltraps>

801072cb <vector183>:
.globl vector183
vector183:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $183
801072cd:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801072d2:	e9 f1 f1 ff ff       	jmp    801064c8 <alltraps>

801072d7 <vector184>:
.globl vector184
vector184:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $184
801072d9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801072de:	e9 e5 f1 ff ff       	jmp    801064c8 <alltraps>

801072e3 <vector185>:
.globl vector185
vector185:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $185
801072e5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801072ea:	e9 d9 f1 ff ff       	jmp    801064c8 <alltraps>

801072ef <vector186>:
.globl vector186
vector186:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $186
801072f1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801072f6:	e9 cd f1 ff ff       	jmp    801064c8 <alltraps>

801072fb <vector187>:
.globl vector187
vector187:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $187
801072fd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107302:	e9 c1 f1 ff ff       	jmp    801064c8 <alltraps>

80107307 <vector188>:
.globl vector188
vector188:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $188
80107309:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010730e:	e9 b5 f1 ff ff       	jmp    801064c8 <alltraps>

80107313 <vector189>:
.globl vector189
vector189:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $189
80107315:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010731a:	e9 a9 f1 ff ff       	jmp    801064c8 <alltraps>

8010731f <vector190>:
.globl vector190
vector190:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $190
80107321:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107326:	e9 9d f1 ff ff       	jmp    801064c8 <alltraps>

8010732b <vector191>:
.globl vector191
vector191:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $191
8010732d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107332:	e9 91 f1 ff ff       	jmp    801064c8 <alltraps>

80107337 <vector192>:
.globl vector192
vector192:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $192
80107339:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010733e:	e9 85 f1 ff ff       	jmp    801064c8 <alltraps>

80107343 <vector193>:
.globl vector193
vector193:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $193
80107345:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010734a:	e9 79 f1 ff ff       	jmp    801064c8 <alltraps>

8010734f <vector194>:
.globl vector194
vector194:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $194
80107351:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107356:	e9 6d f1 ff ff       	jmp    801064c8 <alltraps>

8010735b <vector195>:
.globl vector195
vector195:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $195
8010735d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107362:	e9 61 f1 ff ff       	jmp    801064c8 <alltraps>

80107367 <vector196>:
.globl vector196
vector196:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $196
80107369:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010736e:	e9 55 f1 ff ff       	jmp    801064c8 <alltraps>

80107373 <vector197>:
.globl vector197
vector197:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $197
80107375:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010737a:	e9 49 f1 ff ff       	jmp    801064c8 <alltraps>

8010737f <vector198>:
.globl vector198
vector198:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $198
80107381:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107386:	e9 3d f1 ff ff       	jmp    801064c8 <alltraps>

8010738b <vector199>:
.globl vector199
vector199:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $199
8010738d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107392:	e9 31 f1 ff ff       	jmp    801064c8 <alltraps>

80107397 <vector200>:
.globl vector200
vector200:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $200
80107399:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010739e:	e9 25 f1 ff ff       	jmp    801064c8 <alltraps>

801073a3 <vector201>:
.globl vector201
vector201:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $201
801073a5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801073aa:	e9 19 f1 ff ff       	jmp    801064c8 <alltraps>

801073af <vector202>:
.globl vector202
vector202:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $202
801073b1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801073b6:	e9 0d f1 ff ff       	jmp    801064c8 <alltraps>

801073bb <vector203>:
.globl vector203
vector203:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $203
801073bd:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801073c2:	e9 01 f1 ff ff       	jmp    801064c8 <alltraps>

801073c7 <vector204>:
.globl vector204
vector204:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $204
801073c9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801073ce:	e9 f5 f0 ff ff       	jmp    801064c8 <alltraps>

801073d3 <vector205>:
.globl vector205
vector205:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $205
801073d5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801073da:	e9 e9 f0 ff ff       	jmp    801064c8 <alltraps>

801073df <vector206>:
.globl vector206
vector206:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $206
801073e1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801073e6:	e9 dd f0 ff ff       	jmp    801064c8 <alltraps>

801073eb <vector207>:
.globl vector207
vector207:
  pushl $0
801073eb:	6a 00                	push   $0x0
  pushl $207
801073ed:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801073f2:	e9 d1 f0 ff ff       	jmp    801064c8 <alltraps>

801073f7 <vector208>:
.globl vector208
vector208:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $208
801073f9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801073fe:	e9 c5 f0 ff ff       	jmp    801064c8 <alltraps>

80107403 <vector209>:
.globl vector209
vector209:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $209
80107405:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010740a:	e9 b9 f0 ff ff       	jmp    801064c8 <alltraps>

8010740f <vector210>:
.globl vector210
vector210:
  pushl $0
8010740f:	6a 00                	push   $0x0
  pushl $210
80107411:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107416:	e9 ad f0 ff ff       	jmp    801064c8 <alltraps>

8010741b <vector211>:
.globl vector211
vector211:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $211
8010741d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107422:	e9 a1 f0 ff ff       	jmp    801064c8 <alltraps>

80107427 <vector212>:
.globl vector212
vector212:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $212
80107429:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010742e:	e9 95 f0 ff ff       	jmp    801064c8 <alltraps>

80107433 <vector213>:
.globl vector213
vector213:
  pushl $0
80107433:	6a 00                	push   $0x0
  pushl $213
80107435:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010743a:	e9 89 f0 ff ff       	jmp    801064c8 <alltraps>

8010743f <vector214>:
.globl vector214
vector214:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $214
80107441:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107446:	e9 7d f0 ff ff       	jmp    801064c8 <alltraps>

8010744b <vector215>:
.globl vector215
vector215:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $215
8010744d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107452:	e9 71 f0 ff ff       	jmp    801064c8 <alltraps>

80107457 <vector216>:
.globl vector216
vector216:
  pushl $0
80107457:	6a 00                	push   $0x0
  pushl $216
80107459:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010745e:	e9 65 f0 ff ff       	jmp    801064c8 <alltraps>

80107463 <vector217>:
.globl vector217
vector217:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $217
80107465:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010746a:	e9 59 f0 ff ff       	jmp    801064c8 <alltraps>

8010746f <vector218>:
.globl vector218
vector218:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $218
80107471:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107476:	e9 4d f0 ff ff       	jmp    801064c8 <alltraps>

8010747b <vector219>:
.globl vector219
vector219:
  pushl $0
8010747b:	6a 00                	push   $0x0
  pushl $219
8010747d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107482:	e9 41 f0 ff ff       	jmp    801064c8 <alltraps>

80107487 <vector220>:
.globl vector220
vector220:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $220
80107489:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010748e:	e9 35 f0 ff ff       	jmp    801064c8 <alltraps>

80107493 <vector221>:
.globl vector221
vector221:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $221
80107495:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010749a:	e9 29 f0 ff ff       	jmp    801064c8 <alltraps>

8010749f <vector222>:
.globl vector222
vector222:
  pushl $0
8010749f:	6a 00                	push   $0x0
  pushl $222
801074a1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801074a6:	e9 1d f0 ff ff       	jmp    801064c8 <alltraps>

801074ab <vector223>:
.globl vector223
vector223:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $223
801074ad:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801074b2:	e9 11 f0 ff ff       	jmp    801064c8 <alltraps>

801074b7 <vector224>:
.globl vector224
vector224:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $224
801074b9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801074be:	e9 05 f0 ff ff       	jmp    801064c8 <alltraps>

801074c3 <vector225>:
.globl vector225
vector225:
  pushl $0
801074c3:	6a 00                	push   $0x0
  pushl $225
801074c5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801074ca:	e9 f9 ef ff ff       	jmp    801064c8 <alltraps>

801074cf <vector226>:
.globl vector226
vector226:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $226
801074d1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801074d6:	e9 ed ef ff ff       	jmp    801064c8 <alltraps>

801074db <vector227>:
.globl vector227
vector227:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $227
801074dd:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801074e2:	e9 e1 ef ff ff       	jmp    801064c8 <alltraps>

801074e7 <vector228>:
.globl vector228
vector228:
  pushl $0
801074e7:	6a 00                	push   $0x0
  pushl $228
801074e9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801074ee:	e9 d5 ef ff ff       	jmp    801064c8 <alltraps>

801074f3 <vector229>:
.globl vector229
vector229:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $229
801074f5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801074fa:	e9 c9 ef ff ff       	jmp    801064c8 <alltraps>

801074ff <vector230>:
.globl vector230
vector230:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $230
80107501:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107506:	e9 bd ef ff ff       	jmp    801064c8 <alltraps>

8010750b <vector231>:
.globl vector231
vector231:
  pushl $0
8010750b:	6a 00                	push   $0x0
  pushl $231
8010750d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107512:	e9 b1 ef ff ff       	jmp    801064c8 <alltraps>

80107517 <vector232>:
.globl vector232
vector232:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $232
80107519:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010751e:	e9 a5 ef ff ff       	jmp    801064c8 <alltraps>

80107523 <vector233>:
.globl vector233
vector233:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $233
80107525:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010752a:	e9 99 ef ff ff       	jmp    801064c8 <alltraps>

8010752f <vector234>:
.globl vector234
vector234:
  pushl $0
8010752f:	6a 00                	push   $0x0
  pushl $234
80107531:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107536:	e9 8d ef ff ff       	jmp    801064c8 <alltraps>

8010753b <vector235>:
.globl vector235
vector235:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $235
8010753d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107542:	e9 81 ef ff ff       	jmp    801064c8 <alltraps>

80107547 <vector236>:
.globl vector236
vector236:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $236
80107549:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010754e:	e9 75 ef ff ff       	jmp    801064c8 <alltraps>

80107553 <vector237>:
.globl vector237
vector237:
  pushl $0
80107553:	6a 00                	push   $0x0
  pushl $237
80107555:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010755a:	e9 69 ef ff ff       	jmp    801064c8 <alltraps>

8010755f <vector238>:
.globl vector238
vector238:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $238
80107561:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107566:	e9 5d ef ff ff       	jmp    801064c8 <alltraps>

8010756b <vector239>:
.globl vector239
vector239:
  pushl $0
8010756b:	6a 00                	push   $0x0
  pushl $239
8010756d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107572:	e9 51 ef ff ff       	jmp    801064c8 <alltraps>

80107577 <vector240>:
.globl vector240
vector240:
  pushl $0
80107577:	6a 00                	push   $0x0
  pushl $240
80107579:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010757e:	e9 45 ef ff ff       	jmp    801064c8 <alltraps>

80107583 <vector241>:
.globl vector241
vector241:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $241
80107585:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010758a:	e9 39 ef ff ff       	jmp    801064c8 <alltraps>

8010758f <vector242>:
.globl vector242
vector242:
  pushl $0
8010758f:	6a 00                	push   $0x0
  pushl $242
80107591:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107596:	e9 2d ef ff ff       	jmp    801064c8 <alltraps>

8010759b <vector243>:
.globl vector243
vector243:
  pushl $0
8010759b:	6a 00                	push   $0x0
  pushl $243
8010759d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801075a2:	e9 21 ef ff ff       	jmp    801064c8 <alltraps>

801075a7 <vector244>:
.globl vector244
vector244:
  pushl $0
801075a7:	6a 00                	push   $0x0
  pushl $244
801075a9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801075ae:	e9 15 ef ff ff       	jmp    801064c8 <alltraps>

801075b3 <vector245>:
.globl vector245
vector245:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $245
801075b5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801075ba:	e9 09 ef ff ff       	jmp    801064c8 <alltraps>

801075bf <vector246>:
.globl vector246
vector246:
  pushl $0
801075bf:	6a 00                	push   $0x0
  pushl $246
801075c1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801075c6:	e9 fd ee ff ff       	jmp    801064c8 <alltraps>

801075cb <vector247>:
.globl vector247
vector247:
  pushl $0
801075cb:	6a 00                	push   $0x0
  pushl $247
801075cd:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801075d2:	e9 f1 ee ff ff       	jmp    801064c8 <alltraps>

801075d7 <vector248>:
.globl vector248
vector248:
  pushl $0
801075d7:	6a 00                	push   $0x0
  pushl $248
801075d9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801075de:	e9 e5 ee ff ff       	jmp    801064c8 <alltraps>

801075e3 <vector249>:
.globl vector249
vector249:
  pushl $0
801075e3:	6a 00                	push   $0x0
  pushl $249
801075e5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801075ea:	e9 d9 ee ff ff       	jmp    801064c8 <alltraps>

801075ef <vector250>:
.globl vector250
vector250:
  pushl $0
801075ef:	6a 00                	push   $0x0
  pushl $250
801075f1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801075f6:	e9 cd ee ff ff       	jmp    801064c8 <alltraps>

801075fb <vector251>:
.globl vector251
vector251:
  pushl $0
801075fb:	6a 00                	push   $0x0
  pushl $251
801075fd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107602:	e9 c1 ee ff ff       	jmp    801064c8 <alltraps>

80107607 <vector252>:
.globl vector252
vector252:
  pushl $0
80107607:	6a 00                	push   $0x0
  pushl $252
80107609:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010760e:	e9 b5 ee ff ff       	jmp    801064c8 <alltraps>

80107613 <vector253>:
.globl vector253
vector253:
  pushl $0
80107613:	6a 00                	push   $0x0
  pushl $253
80107615:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010761a:	e9 a9 ee ff ff       	jmp    801064c8 <alltraps>

8010761f <vector254>:
.globl vector254
vector254:
  pushl $0
8010761f:	6a 00                	push   $0x0
  pushl $254
80107621:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107626:	e9 9d ee ff ff       	jmp    801064c8 <alltraps>

8010762b <vector255>:
.globl vector255
vector255:
  pushl $0
8010762b:	6a 00                	push   $0x0
  pushl $255
8010762d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107632:	e9 91 ee ff ff       	jmp    801064c8 <alltraps>

80107637 <lgdt>:
{
80107637:	55                   	push   %ebp
80107638:	89 e5                	mov    %esp,%ebp
8010763a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010763d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107640:	83 e8 01             	sub    $0x1,%eax
80107643:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107647:	8b 45 08             	mov    0x8(%ebp),%eax
8010764a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010764e:	8b 45 08             	mov    0x8(%ebp),%eax
80107651:	c1 e8 10             	shr    $0x10,%eax
80107654:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107658:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010765b:	0f 01 10             	lgdtl  (%eax)
}
8010765e:	90                   	nop
8010765f:	c9                   	leave  
80107660:	c3                   	ret    

80107661 <ltr>:
{
80107661:	55                   	push   %ebp
80107662:	89 e5                	mov    %esp,%ebp
80107664:	83 ec 04             	sub    $0x4,%esp
80107667:	8b 45 08             	mov    0x8(%ebp),%eax
8010766a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010766e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107672:	0f 00 d8             	ltr    %ax
}
80107675:	90                   	nop
80107676:	c9                   	leave  
80107677:	c3                   	ret    

80107678 <lcr3>:

static inline void
lcr3(uint val)
{
80107678:	55                   	push   %ebp
80107679:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010767b:	8b 45 08             	mov    0x8(%ebp),%eax
8010767e:	0f 22 d8             	mov    %eax,%cr3
}
80107681:	90                   	nop
80107682:	5d                   	pop    %ebp
80107683:	c3                   	ret    

80107684 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107684:	f3 0f 1e fb          	endbr32 
80107688:	55                   	push   %ebp
80107689:	89 e5                	mov    %esp,%ebp
8010768b:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010768e:	e8 7b c4 ff ff       	call   80103b0e <cpuid>
80107693:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107699:	05 c0 85 19 80       	add    $0x801985c0,%eax
8010769e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801076a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a4:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801076aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ad:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801076b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b6:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801076ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076bd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076c1:	83 e2 f0             	and    $0xfffffff0,%edx
801076c4:	83 ca 0a             	or     $0xa,%edx
801076c7:	88 50 7d             	mov    %dl,0x7d(%eax)
801076ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076d1:	83 ca 10             	or     $0x10,%edx
801076d4:	88 50 7d             	mov    %dl,0x7d(%eax)
801076d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076da:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076de:	83 e2 9f             	and    $0xffffff9f,%edx
801076e1:	88 50 7d             	mov    %dl,0x7d(%eax)
801076e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076eb:	83 ca 80             	or     $0xffffff80,%edx
801076ee:	88 50 7d             	mov    %dl,0x7d(%eax)
801076f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801076f8:	83 ca 0f             	or     $0xf,%edx
801076fb:	88 50 7e             	mov    %dl,0x7e(%eax)
801076fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107701:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107705:	83 e2 ef             	and    $0xffffffef,%edx
80107708:	88 50 7e             	mov    %dl,0x7e(%eax)
8010770b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107712:	83 e2 df             	and    $0xffffffdf,%edx
80107715:	88 50 7e             	mov    %dl,0x7e(%eax)
80107718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010771f:	83 ca 40             	or     $0x40,%edx
80107722:	88 50 7e             	mov    %dl,0x7e(%eax)
80107725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107728:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010772c:	83 ca 80             	or     $0xffffff80,%edx
8010772f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107735:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107743:	ff ff 
80107745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107748:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010774f:	00 00 
80107751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107754:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010775b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107765:	83 e2 f0             	and    $0xfffffff0,%edx
80107768:	83 ca 02             	or     $0x2,%edx
8010776b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107774:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010777b:	83 ca 10             	or     $0x10,%edx
8010777e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107787:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010778e:	83 e2 9f             	and    $0xffffff9f,%edx
80107791:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801077a1:	83 ca 80             	or     $0xffffff80,%edx
801077a4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801077aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ad:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077b4:	83 ca 0f             	or     $0xf,%edx
801077b7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077c7:	83 e2 ef             	and    $0xffffffef,%edx
801077ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077da:	83 e2 df             	and    $0xffffffdf,%edx
801077dd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077ed:	83 ca 40             	or     $0x40,%edx
801077f0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107800:	83 ca 80             	or     $0xffffff80,%edx
80107803:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780c:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107816:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010781d:	ff ff 
8010781f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107822:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107829:	00 00 
8010782b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782e:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107838:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010783f:	83 e2 f0             	and    $0xfffffff0,%edx
80107842:	83 ca 0a             	or     $0xa,%edx
80107845:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107855:	83 ca 10             	or     $0x10,%edx
80107858:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010785e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107861:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107868:	83 ca 60             	or     $0x60,%edx
8010786b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107874:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010787b:	83 ca 80             	or     $0xffffff80,%edx
8010787e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107887:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010788e:	83 ca 0f             	or     $0xf,%edx
80107891:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801078a1:	83 e2 ef             	and    $0xffffffef,%edx
801078a4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801078aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ad:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801078b4:	83 e2 df             	and    $0xffffffdf,%edx
801078b7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801078bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801078c7:	83 ca 40             	or     $0x40,%edx
801078ca:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801078d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801078da:	83 ca 80             	or     $0xffffff80,%edx
801078dd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801078e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e6:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801078ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801078f7:	ff ff 
801078f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107903:	00 00 
80107905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107908:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010790f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107912:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107919:	83 e2 f0             	and    $0xfffffff0,%edx
8010791c:	83 ca 02             	or     $0x2,%edx
8010791f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107928:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010792f:	83 ca 10             	or     $0x10,%edx
80107932:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107942:	83 ca 60             	or     $0x60,%edx
80107945:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010794b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107955:	83 ca 80             	or     $0xffffff80,%edx
80107958:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010795e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107961:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107968:	83 ca 0f             	or     $0xf,%edx
8010796b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107974:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010797b:	83 e2 ef             	and    $0xffffffef,%edx
8010797e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107987:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010798e:	83 e2 df             	and    $0xffffffdf,%edx
80107991:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079a1:	83 ca 40             	or     $0x40,%edx
801079a4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ad:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079b4:	83 ca 80             	or     $0xffffff80,%edx
801079b7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801079c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ca:	83 c0 70             	add    $0x70,%eax
801079cd:	83 ec 08             	sub    $0x8,%esp
801079d0:	6a 30                	push   $0x30
801079d2:	50                   	push   %eax
801079d3:	e8 5f fc ff ff       	call   80107637 <lgdt>
801079d8:	83 c4 10             	add    $0x10,%esp
}
801079db:	90                   	nop
801079dc:	c9                   	leave  
801079dd:	c3                   	ret    

801079de <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801079de:	f3 0f 1e fb          	endbr32 
801079e2:	55                   	push   %ebp
801079e3:	89 e5                	mov    %esp,%ebp
801079e5:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801079e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801079eb:	c1 e8 16             	shr    $0x16,%eax
801079ee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079f5:	8b 45 08             	mov    0x8(%ebp),%eax
801079f8:	01 d0                	add    %edx,%eax
801079fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801079fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a00:	8b 00                	mov    (%eax),%eax
80107a02:	83 e0 01             	and    $0x1,%eax
80107a05:	85 c0                	test   %eax,%eax
80107a07:	74 14                	je     80107a1d <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a0c:	8b 00                	mov    (%eax),%eax
80107a0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a13:	05 00 00 00 80       	add    $0x80000000,%eax
80107a18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a1b:	eb 42                	jmp    80107a5f <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107a1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107a21:	74 0e                	je     80107a31 <walkpgdir+0x53>
80107a23:	e8 6a ae ff ff       	call   80102892 <kalloc>
80107a28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a2f:	75 07                	jne    80107a38 <walkpgdir+0x5a>
      return 0;
80107a31:	b8 00 00 00 00       	mov    $0x0,%eax
80107a36:	eb 3e                	jmp    80107a76 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107a38:	83 ec 04             	sub    $0x4,%esp
80107a3b:	68 00 10 00 00       	push   $0x1000
80107a40:	6a 00                	push   $0x0
80107a42:	ff 75 f4             	pushl  -0xc(%ebp)
80107a45:	e8 e7 d5 ff ff       	call   80105031 <memset>
80107a4a:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a50:	05 00 00 00 80       	add    $0x80000000,%eax
80107a55:	83 c8 07             	or     $0x7,%eax
80107a58:	89 c2                	mov    %eax,%edx
80107a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a5d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a62:	c1 e8 0c             	shr    $0xc,%eax
80107a65:	25 ff 03 00 00       	and    $0x3ff,%eax
80107a6a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a74:	01 d0                	add    %edx,%eax
}
80107a76:	c9                   	leave  
80107a77:	c3                   	ret    

80107a78 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107a78:	f3 0f 1e fb          	endbr32 
80107a7c:	55                   	push   %ebp
80107a7d:	89 e5                	mov    %esp,%ebp
80107a7f:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107a82:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107a8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107a90:	8b 45 10             	mov    0x10(%ebp),%eax
80107a93:	01 d0                	add    %edx,%eax
80107a95:	83 e8 01             	sub    $0x1,%eax
80107a98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107aa0:	83 ec 04             	sub    $0x4,%esp
80107aa3:	6a 01                	push   $0x1
80107aa5:	ff 75 f4             	pushl  -0xc(%ebp)
80107aa8:	ff 75 08             	pushl  0x8(%ebp)
80107aab:	e8 2e ff ff ff       	call   801079de <walkpgdir>
80107ab0:	83 c4 10             	add    $0x10,%esp
80107ab3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ab6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107aba:	75 07                	jne    80107ac3 <mappages+0x4b>
      return -1;
80107abc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ac1:	eb 47                	jmp    80107b0a <mappages+0x92>
    if(*pte & PTE_P)
80107ac3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ac6:	8b 00                	mov    (%eax),%eax
80107ac8:	83 e0 01             	and    $0x1,%eax
80107acb:	85 c0                	test   %eax,%eax
80107acd:	74 0d                	je     80107adc <mappages+0x64>
      panic("remap");
80107acf:	83 ec 0c             	sub    $0xc,%esp
80107ad2:	68 c8 ae 10 80       	push   $0x8010aec8
80107ad7:	e8 e9 8a ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80107adc:	8b 45 18             	mov    0x18(%ebp),%eax
80107adf:	0b 45 14             	or     0x14(%ebp),%eax
80107ae2:	83 c8 01             	or     $0x1,%eax
80107ae5:	89 c2                	mov    %eax,%edx
80107ae7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107aea:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aef:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107af2:	74 10                	je     80107b04 <mappages+0x8c>
      break;
    a += PGSIZE;
80107af4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107afb:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107b02:	eb 9c                	jmp    80107aa0 <mappages+0x28>
      break;
80107b04:	90                   	nop
  }
  return 0;
80107b05:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b0a:	c9                   	leave  
80107b0b:	c3                   	ret    

80107b0c <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107b0c:	f3 0f 1e fb          	endbr32 
80107b10:	55                   	push   %ebp
80107b11:	89 e5                	mov    %esp,%ebp
80107b13:	53                   	push   %ebx
80107b14:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107b17:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107b1e:	a1 9c 88 19 80       	mov    0x8019889c,%eax
80107b23:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107b28:	29 c2                	sub    %eax,%edx
80107b2a:	89 d0                	mov    %edx,%eax
80107b2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107b2f:	a1 94 88 19 80       	mov    0x80198894,%eax
80107b34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107b37:	8b 15 94 88 19 80    	mov    0x80198894,%edx
80107b3d:	a1 9c 88 19 80       	mov    0x8019889c,%eax
80107b42:	01 d0                	add    %edx,%eax
80107b44:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107b47:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b51:	83 c0 30             	add    $0x30,%eax
80107b54:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107b57:	89 10                	mov    %edx,(%eax)
80107b59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107b5c:	89 50 04             	mov    %edx,0x4(%eax)
80107b5f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107b62:	89 50 08             	mov    %edx,0x8(%eax)
80107b65:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107b68:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107b6b:	e8 22 ad ff ff       	call   80102892 <kalloc>
80107b70:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107b77:	75 07                	jne    80107b80 <setupkvm+0x74>
    return 0;
80107b79:	b8 00 00 00 00       	mov    $0x0,%eax
80107b7e:	eb 78                	jmp    80107bf8 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80107b80:	83 ec 04             	sub    $0x4,%esp
80107b83:	68 00 10 00 00       	push   $0x1000
80107b88:	6a 00                	push   $0x0
80107b8a:	ff 75 f0             	pushl  -0x10(%ebp)
80107b8d:	e8 9f d4 ff ff       	call   80105031 <memset>
80107b92:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b95:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107b9c:	eb 4e                	jmp    80107bec <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba1:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba7:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bad:	8b 58 08             	mov    0x8(%eax),%ebx
80107bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb3:	8b 40 04             	mov    0x4(%eax),%eax
80107bb6:	29 c3                	sub    %eax,%ebx
80107bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbb:	8b 00                	mov    (%eax),%eax
80107bbd:	83 ec 0c             	sub    $0xc,%esp
80107bc0:	51                   	push   %ecx
80107bc1:	52                   	push   %edx
80107bc2:	53                   	push   %ebx
80107bc3:	50                   	push   %eax
80107bc4:	ff 75 f0             	pushl  -0x10(%ebp)
80107bc7:	e8 ac fe ff ff       	call   80107a78 <mappages>
80107bcc:	83 c4 20             	add    $0x20,%esp
80107bcf:	85 c0                	test   %eax,%eax
80107bd1:	79 15                	jns    80107be8 <setupkvm+0xdc>
      freevm(pgdir);
80107bd3:	83 ec 0c             	sub    $0xc,%esp
80107bd6:	ff 75 f0             	pushl  -0x10(%ebp)
80107bd9:	e8 11 05 00 00       	call   801080ef <freevm>
80107bde:	83 c4 10             	add    $0x10,%esp
      return 0;
80107be1:	b8 00 00 00 00       	mov    $0x0,%eax
80107be6:	eb 10                	jmp    80107bf8 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107be8:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107bec:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107bf3:	72 a9                	jb     80107b9e <setupkvm+0x92>
    }
  return pgdir;
80107bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107bf8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107bfb:	c9                   	leave  
80107bfc:	c3                   	ret    

80107bfd <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107bfd:	f3 0f 1e fb          	endbr32 
80107c01:	55                   	push   %ebp
80107c02:	89 e5                	mov    %esp,%ebp
80107c04:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107c07:	e8 00 ff ff ff       	call   80107b0c <setupkvm>
80107c0c:	a3 84 85 19 80       	mov    %eax,0x80198584
  switchkvm();
80107c11:	e8 03 00 00 00       	call   80107c19 <switchkvm>
}
80107c16:	90                   	nop
80107c17:	c9                   	leave  
80107c18:	c3                   	ret    

80107c19 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107c19:	f3 0f 1e fb          	endbr32 
80107c1d:	55                   	push   %ebp
80107c1e:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107c20:	a1 84 85 19 80       	mov    0x80198584,%eax
80107c25:	05 00 00 00 80       	add    $0x80000000,%eax
80107c2a:	50                   	push   %eax
80107c2b:	e8 48 fa ff ff       	call   80107678 <lcr3>
80107c30:	83 c4 04             	add    $0x4,%esp
}
80107c33:	90                   	nop
80107c34:	c9                   	leave  
80107c35:	c3                   	ret    

80107c36 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107c36:	f3 0f 1e fb          	endbr32 
80107c3a:	55                   	push   %ebp
80107c3b:	89 e5                	mov    %esp,%ebp
80107c3d:	56                   	push   %esi
80107c3e:	53                   	push   %ebx
80107c3f:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107c42:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107c46:	75 0d                	jne    80107c55 <switchuvm+0x1f>
    panic("switchuvm: no process");
80107c48:	83 ec 0c             	sub    $0xc,%esp
80107c4b:	68 ce ae 10 80       	push   $0x8010aece
80107c50:	e8 70 89 ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
80107c55:	8b 45 08             	mov    0x8(%ebp),%eax
80107c58:	8b 40 08             	mov    0x8(%eax),%eax
80107c5b:	85 c0                	test   %eax,%eax
80107c5d:	75 0d                	jne    80107c6c <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107c5f:	83 ec 0c             	sub    $0xc,%esp
80107c62:	68 e4 ae 10 80       	push   $0x8010aee4
80107c67:	e8 59 89 ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
80107c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80107c6f:	8b 40 04             	mov    0x4(%eax),%eax
80107c72:	85 c0                	test   %eax,%eax
80107c74:	75 0d                	jne    80107c83 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107c76:	83 ec 0c             	sub    $0xc,%esp
80107c79:	68 f9 ae 10 80       	push   $0x8010aef9
80107c7e:	e8 42 89 ff ff       	call   801005c5 <panic>

  pushcli();
80107c83:	e8 96 d2 ff ff       	call   80104f1e <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107c88:	e8 a0 be ff ff       	call   80103b2d <mycpu>
80107c8d:	89 c3                	mov    %eax,%ebx
80107c8f:	e8 99 be ff ff       	call   80103b2d <mycpu>
80107c94:	83 c0 08             	add    $0x8,%eax
80107c97:	89 c6                	mov    %eax,%esi
80107c99:	e8 8f be ff ff       	call   80103b2d <mycpu>
80107c9e:	83 c0 08             	add    $0x8,%eax
80107ca1:	c1 e8 10             	shr    $0x10,%eax
80107ca4:	88 45 f7             	mov    %al,-0x9(%ebp)
80107ca7:	e8 81 be ff ff       	call   80103b2d <mycpu>
80107cac:	83 c0 08             	add    $0x8,%eax
80107caf:	c1 e8 18             	shr    $0x18,%eax
80107cb2:	89 c2                	mov    %eax,%edx
80107cb4:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107cbb:	67 00 
80107cbd:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107cc4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107cc8:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107cce:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107cd5:	83 e0 f0             	and    $0xfffffff0,%eax
80107cd8:	83 c8 09             	or     $0x9,%eax
80107cdb:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ce1:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ce8:	83 c8 10             	or     $0x10,%eax
80107ceb:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107cf1:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107cf8:	83 e0 9f             	and    $0xffffff9f,%eax
80107cfb:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d01:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d08:	83 c8 80             	or     $0xffffff80,%eax
80107d0b:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d11:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d18:	83 e0 f0             	and    $0xfffffff0,%eax
80107d1b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d21:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d28:	83 e0 ef             	and    $0xffffffef,%eax
80107d2b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d31:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d38:	83 e0 df             	and    $0xffffffdf,%eax
80107d3b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d41:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d48:	83 c8 40             	or     $0x40,%eax
80107d4b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d51:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d58:	83 e0 7f             	and    $0x7f,%eax
80107d5b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d61:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107d67:	e8 c1 bd ff ff       	call   80103b2d <mycpu>
80107d6c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d73:	83 e2 ef             	and    $0xffffffef,%edx
80107d76:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107d7c:	e8 ac bd ff ff       	call   80103b2d <mycpu>
80107d81:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107d87:	8b 45 08             	mov    0x8(%ebp),%eax
80107d8a:	8b 40 08             	mov    0x8(%eax),%eax
80107d8d:	89 c3                	mov    %eax,%ebx
80107d8f:	e8 99 bd ff ff       	call   80103b2d <mycpu>
80107d94:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107d9a:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107d9d:	e8 8b bd ff ff       	call   80103b2d <mycpu>
80107da2:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107da8:	83 ec 0c             	sub    $0xc,%esp
80107dab:	6a 28                	push   $0x28
80107dad:	e8 af f8 ff ff       	call   80107661 <ltr>
80107db2:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107db5:	8b 45 08             	mov    0x8(%ebp),%eax
80107db8:	8b 40 04             	mov    0x4(%eax),%eax
80107dbb:	05 00 00 00 80       	add    $0x80000000,%eax
80107dc0:	83 ec 0c             	sub    $0xc,%esp
80107dc3:	50                   	push   %eax
80107dc4:	e8 af f8 ff ff       	call   80107678 <lcr3>
80107dc9:	83 c4 10             	add    $0x10,%esp
  popcli();
80107dcc:	e8 9e d1 ff ff       	call   80104f6f <popcli>
}
80107dd1:	90                   	nop
80107dd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107dd5:	5b                   	pop    %ebx
80107dd6:	5e                   	pop    %esi
80107dd7:	5d                   	pop    %ebp
80107dd8:	c3                   	ret    

80107dd9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107dd9:	f3 0f 1e fb          	endbr32 
80107ddd:	55                   	push   %ebp
80107dde:	89 e5                	mov    %esp,%ebp
80107de0:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107de3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107dea:	76 0d                	jbe    80107df9 <inituvm+0x20>
    panic("inituvm: more than a page");
80107dec:	83 ec 0c             	sub    $0xc,%esp
80107def:	68 0d af 10 80       	push   $0x8010af0d
80107df4:	e8 cc 87 ff ff       	call   801005c5 <panic>
  mem = kalloc();
80107df9:	e8 94 aa ff ff       	call   80102892 <kalloc>
80107dfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107e01:	83 ec 04             	sub    $0x4,%esp
80107e04:	68 00 10 00 00       	push   $0x1000
80107e09:	6a 00                	push   $0x0
80107e0b:	ff 75 f4             	pushl  -0xc(%ebp)
80107e0e:	e8 1e d2 ff ff       	call   80105031 <memset>
80107e13:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e19:	05 00 00 00 80       	add    $0x80000000,%eax
80107e1e:	83 ec 0c             	sub    $0xc,%esp
80107e21:	6a 06                	push   $0x6
80107e23:	50                   	push   %eax
80107e24:	68 00 10 00 00       	push   $0x1000
80107e29:	6a 00                	push   $0x0
80107e2b:	ff 75 08             	pushl  0x8(%ebp)
80107e2e:	e8 45 fc ff ff       	call   80107a78 <mappages>
80107e33:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107e36:	83 ec 04             	sub    $0x4,%esp
80107e39:	ff 75 10             	pushl  0x10(%ebp)
80107e3c:	ff 75 0c             	pushl  0xc(%ebp)
80107e3f:	ff 75 f4             	pushl  -0xc(%ebp)
80107e42:	e8 b1 d2 ff ff       	call   801050f8 <memmove>
80107e47:	83 c4 10             	add    $0x10,%esp
}
80107e4a:	90                   	nop
80107e4b:	c9                   	leave  
80107e4c:	c3                   	ret    

80107e4d <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107e4d:	f3 0f 1e fb          	endbr32 
80107e51:	55                   	push   %ebp
80107e52:	89 e5                	mov    %esp,%ebp
80107e54:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e5a:	25 ff 0f 00 00       	and    $0xfff,%eax
80107e5f:	85 c0                	test   %eax,%eax
80107e61:	74 0d                	je     80107e70 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107e63:	83 ec 0c             	sub    $0xc,%esp
80107e66:	68 28 af 10 80       	push   $0x8010af28
80107e6b:	e8 55 87 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e77:	e9 8f 00 00 00       	jmp    80107f0b <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107e7c:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e82:	01 d0                	add    %edx,%eax
80107e84:	83 ec 04             	sub    $0x4,%esp
80107e87:	6a 00                	push   $0x0
80107e89:	50                   	push   %eax
80107e8a:	ff 75 08             	pushl  0x8(%ebp)
80107e8d:	e8 4c fb ff ff       	call   801079de <walkpgdir>
80107e92:	83 c4 10             	add    $0x10,%esp
80107e95:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e98:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e9c:	75 0d                	jne    80107eab <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107e9e:	83 ec 0c             	sub    $0xc,%esp
80107ea1:	68 4b af 10 80       	push   $0x8010af4b
80107ea6:	e8 1a 87 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107eab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eae:	8b 00                	mov    (%eax),%eax
80107eb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107eb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107eb8:	8b 45 18             	mov    0x18(%ebp),%eax
80107ebb:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107ebe:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107ec3:	77 0b                	ja     80107ed0 <loaduvm+0x83>
      n = sz - i;
80107ec5:	8b 45 18             	mov    0x18(%ebp),%eax
80107ec8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107ecb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ece:	eb 07                	jmp    80107ed7 <loaduvm+0x8a>
    else
      n = PGSIZE;
80107ed0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107ed7:	8b 55 14             	mov    0x14(%ebp),%edx
80107eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edd:	01 d0                	add    %edx,%eax
80107edf:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107ee2:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107ee8:	ff 75 f0             	pushl  -0x10(%ebp)
80107eeb:	50                   	push   %eax
80107eec:	52                   	push   %edx
80107eed:	ff 75 10             	pushl  0x10(%ebp)
80107ef0:	e8 8f a0 ff ff       	call   80101f84 <readi>
80107ef5:	83 c4 10             	add    $0x10,%esp
80107ef8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107efb:	74 07                	je     80107f04 <loaduvm+0xb7>
      return -1;
80107efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f02:	eb 18                	jmp    80107f1c <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107f04:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	3b 45 18             	cmp    0x18(%ebp),%eax
80107f11:	0f 82 65 ff ff ff    	jb     80107e7c <loaduvm+0x2f>
  }
  return 0;
80107f17:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f1c:	c9                   	leave  
80107f1d:	c3                   	ret    

80107f1e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f1e:	f3 0f 1e fb          	endbr32 
80107f22:	55                   	push   %ebp
80107f23:	89 e5                	mov    %esp,%ebp
80107f25:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107f28:	8b 45 10             	mov    0x10(%ebp),%eax
80107f2b:	85 c0                	test   %eax,%eax
80107f2d:	79 0a                	jns    80107f39 <allocuvm+0x1b>
    return 0;
80107f2f:	b8 00 00 00 00       	mov    $0x0,%eax
80107f34:	e9 ec 00 00 00       	jmp    80108025 <allocuvm+0x107>
  if(newsz < oldsz)
80107f39:	8b 45 10             	mov    0x10(%ebp),%eax
80107f3c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f3f:	73 08                	jae    80107f49 <allocuvm+0x2b>
    return oldsz;
80107f41:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f44:	e9 dc 00 00 00       	jmp    80108025 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107f49:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f4c:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107f59:	e9 b8 00 00 00       	jmp    80108016 <allocuvm+0xf8>
    mem = kalloc();
80107f5e:	e8 2f a9 ff ff       	call   80102892 <kalloc>
80107f63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107f66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f6a:	75 2e                	jne    80107f9a <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107f6c:	83 ec 0c             	sub    $0xc,%esp
80107f6f:	68 69 af 10 80       	push   $0x8010af69
80107f74:	e8 93 84 ff ff       	call   8010040c <cprintf>
80107f79:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107f7c:	83 ec 04             	sub    $0x4,%esp
80107f7f:	ff 75 0c             	pushl  0xc(%ebp)
80107f82:	ff 75 10             	pushl  0x10(%ebp)
80107f85:	ff 75 08             	pushl  0x8(%ebp)
80107f88:	e8 9a 00 00 00       	call   80108027 <deallocuvm>
80107f8d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f90:	b8 00 00 00 00       	mov    $0x0,%eax
80107f95:	e9 8b 00 00 00       	jmp    80108025 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107f9a:	83 ec 04             	sub    $0x4,%esp
80107f9d:	68 00 10 00 00       	push   $0x1000
80107fa2:	6a 00                	push   $0x0
80107fa4:	ff 75 f0             	pushl  -0x10(%ebp)
80107fa7:	e8 85 d0 ff ff       	call   80105031 <memset>
80107fac:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbb:	83 ec 0c             	sub    $0xc,%esp
80107fbe:	6a 06                	push   $0x6
80107fc0:	52                   	push   %edx
80107fc1:	68 00 10 00 00       	push   $0x1000
80107fc6:	50                   	push   %eax
80107fc7:	ff 75 08             	pushl  0x8(%ebp)
80107fca:	e8 a9 fa ff ff       	call   80107a78 <mappages>
80107fcf:	83 c4 20             	add    $0x20,%esp
80107fd2:	85 c0                	test   %eax,%eax
80107fd4:	79 39                	jns    8010800f <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107fd6:	83 ec 0c             	sub    $0xc,%esp
80107fd9:	68 81 af 10 80       	push   $0x8010af81
80107fde:	e8 29 84 ff ff       	call   8010040c <cprintf>
80107fe3:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107fe6:	83 ec 04             	sub    $0x4,%esp
80107fe9:	ff 75 0c             	pushl  0xc(%ebp)
80107fec:	ff 75 10             	pushl  0x10(%ebp)
80107fef:	ff 75 08             	pushl  0x8(%ebp)
80107ff2:	e8 30 00 00 00       	call   80108027 <deallocuvm>
80107ff7:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107ffa:	83 ec 0c             	sub    $0xc,%esp
80107ffd:	ff 75 f0             	pushl  -0x10(%ebp)
80108000:	e8 ef a7 ff ff       	call   801027f4 <kfree>
80108005:	83 c4 10             	add    $0x10,%esp
      return 0;
80108008:	b8 00 00 00 00       	mov    $0x0,%eax
8010800d:	eb 16                	jmp    80108025 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
8010800f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108019:	3b 45 10             	cmp    0x10(%ebp),%eax
8010801c:	0f 82 3c ff ff ff    	jb     80107f5e <allocuvm+0x40>
    }
  }
  return newsz;
80108022:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108025:	c9                   	leave  
80108026:	c3                   	ret    

80108027 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108027:	f3 0f 1e fb          	endbr32 
8010802b:	55                   	push   %ebp
8010802c:	89 e5                	mov    %esp,%ebp
8010802e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108031:	8b 45 10             	mov    0x10(%ebp),%eax
80108034:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108037:	72 08                	jb     80108041 <deallocuvm+0x1a>
    return oldsz;
80108039:	8b 45 0c             	mov    0xc(%ebp),%eax
8010803c:	e9 ac 00 00 00       	jmp    801080ed <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80108041:	8b 45 10             	mov    0x10(%ebp),%eax
80108044:	05 ff 0f 00 00       	add    $0xfff,%eax
80108049:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010804e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108051:	e9 88 00 00 00       	jmp    801080de <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108059:	83 ec 04             	sub    $0x4,%esp
8010805c:	6a 00                	push   $0x0
8010805e:	50                   	push   %eax
8010805f:	ff 75 08             	pushl  0x8(%ebp)
80108062:	e8 77 f9 ff ff       	call   801079de <walkpgdir>
80108067:	83 c4 10             	add    $0x10,%esp
8010806a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010806d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108071:	75 16                	jne    80108089 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108076:	c1 e8 16             	shr    $0x16,%eax
80108079:	83 c0 01             	add    $0x1,%eax
8010807c:	c1 e0 16             	shl    $0x16,%eax
8010807f:	2d 00 10 00 00       	sub    $0x1000,%eax
80108084:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108087:	eb 4e                	jmp    801080d7 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80108089:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010808c:	8b 00                	mov    (%eax),%eax
8010808e:	83 e0 01             	and    $0x1,%eax
80108091:	85 c0                	test   %eax,%eax
80108093:	74 42                	je     801080d7 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80108095:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108098:	8b 00                	mov    (%eax),%eax
8010809a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010809f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801080a2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080a6:	75 0d                	jne    801080b5 <deallocuvm+0x8e>
        panic("kfree");
801080a8:	83 ec 0c             	sub    $0xc,%esp
801080ab:	68 9d af 10 80       	push   $0x8010af9d
801080b0:	e8 10 85 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
801080b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080b8:	05 00 00 00 80       	add    $0x80000000,%eax
801080bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801080c0:	83 ec 0c             	sub    $0xc,%esp
801080c3:	ff 75 e8             	pushl  -0x18(%ebp)
801080c6:	e8 29 a7 ff ff       	call   801027f4 <kfree>
801080cb:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801080ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801080d7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080e4:	0f 82 6c ff ff ff    	jb     80108056 <deallocuvm+0x2f>
    }
  }
  return newsz;
801080ea:	8b 45 10             	mov    0x10(%ebp),%eax
}
801080ed:	c9                   	leave  
801080ee:	c3                   	ret    

801080ef <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801080ef:	f3 0f 1e fb          	endbr32 
801080f3:	55                   	push   %ebp
801080f4:	89 e5                	mov    %esp,%ebp
801080f6:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801080f9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801080fd:	75 0d                	jne    8010810c <freevm+0x1d>
    panic("freevm: no pgdir");
801080ff:	83 ec 0c             	sub    $0xc,%esp
80108102:	68 a3 af 10 80       	push   $0x8010afa3
80108107:	e8 b9 84 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010810c:	83 ec 04             	sub    $0x4,%esp
8010810f:	6a 00                	push   $0x0
80108111:	68 00 00 00 80       	push   $0x80000000
80108116:	ff 75 08             	pushl  0x8(%ebp)
80108119:	e8 09 ff ff ff       	call   80108027 <deallocuvm>
8010811e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108121:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108128:	eb 48                	jmp    80108172 <freevm+0x83>
    if(pgdir[i] & PTE_P){
8010812a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108134:	8b 45 08             	mov    0x8(%ebp),%eax
80108137:	01 d0                	add    %edx,%eax
80108139:	8b 00                	mov    (%eax),%eax
8010813b:	83 e0 01             	and    $0x1,%eax
8010813e:	85 c0                	test   %eax,%eax
80108140:	74 2c                	je     8010816e <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108145:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010814c:	8b 45 08             	mov    0x8(%ebp),%eax
8010814f:	01 d0                	add    %edx,%eax
80108151:	8b 00                	mov    (%eax),%eax
80108153:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108158:	05 00 00 00 80       	add    $0x80000000,%eax
8010815d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108160:	83 ec 0c             	sub    $0xc,%esp
80108163:	ff 75 f0             	pushl  -0x10(%ebp)
80108166:	e8 89 a6 ff ff       	call   801027f4 <kfree>
8010816b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010816e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108172:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108179:	76 af                	jbe    8010812a <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
8010817b:	83 ec 0c             	sub    $0xc,%esp
8010817e:	ff 75 08             	pushl  0x8(%ebp)
80108181:	e8 6e a6 ff ff       	call   801027f4 <kfree>
80108186:	83 c4 10             	add    $0x10,%esp
}
80108189:	90                   	nop
8010818a:	c9                   	leave  
8010818b:	c3                   	ret    

8010818c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010818c:	f3 0f 1e fb          	endbr32 
80108190:	55                   	push   %ebp
80108191:	89 e5                	mov    %esp,%ebp
80108193:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108196:	83 ec 04             	sub    $0x4,%esp
80108199:	6a 00                	push   $0x0
8010819b:	ff 75 0c             	pushl  0xc(%ebp)
8010819e:	ff 75 08             	pushl  0x8(%ebp)
801081a1:	e8 38 f8 ff ff       	call   801079de <walkpgdir>
801081a6:	83 c4 10             	add    $0x10,%esp
801081a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801081ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801081b0:	75 0d                	jne    801081bf <clearpteu+0x33>
    panic("clearpteu");
801081b2:	83 ec 0c             	sub    $0xc,%esp
801081b5:	68 b4 af 10 80       	push   $0x8010afb4
801081ba:	e8 06 84 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
801081bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c2:	8b 00                	mov    (%eax),%eax
801081c4:	83 e0 fb             	and    $0xfffffffb,%eax
801081c7:	89 c2                	mov    %eax,%edx
801081c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081cc:	89 10                	mov    %edx,(%eax)
}
801081ce:	90                   	nop
801081cf:	c9                   	leave  
801081d0:	c3                   	ret    

801081d1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801081d1:	f3 0f 1e fb          	endbr32 
801081d5:	55                   	push   %ebp
801081d6:	89 e5                	mov    %esp,%ebp
801081d8:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801081db:	e8 2c f9 ff ff       	call   80107b0c <setupkvm>
801081e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081e7:	75 0a                	jne    801081f3 <copyuvm+0x22>
    return 0;
801081e9:	b8 00 00 00 00       	mov    $0x0,%eax
801081ee:	e9 eb 00 00 00       	jmp    801082de <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
801081f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081fa:	e9 b7 00 00 00       	jmp    801082b6 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801081ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108202:	83 ec 04             	sub    $0x4,%esp
80108205:	6a 00                	push   $0x0
80108207:	50                   	push   %eax
80108208:	ff 75 08             	pushl  0x8(%ebp)
8010820b:	e8 ce f7 ff ff       	call   801079de <walkpgdir>
80108210:	83 c4 10             	add    $0x10,%esp
80108213:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108216:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010821a:	75 0d                	jne    80108229 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
8010821c:	83 ec 0c             	sub    $0xc,%esp
8010821f:	68 be af 10 80       	push   $0x8010afbe
80108224:	e8 9c 83 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80108229:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010822c:	8b 00                	mov    (%eax),%eax
8010822e:	83 e0 01             	and    $0x1,%eax
80108231:	85 c0                	test   %eax,%eax
80108233:	75 0d                	jne    80108242 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108235:	83 ec 0c             	sub    $0xc,%esp
80108238:	68 d8 af 10 80       	push   $0x8010afd8
8010823d:	e8 83 83 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80108242:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108245:	8b 00                	mov    (%eax),%eax
80108247:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010824c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010824f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108252:	8b 00                	mov    (%eax),%eax
80108254:	25 ff 0f 00 00       	and    $0xfff,%eax
80108259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010825c:	e8 31 a6 ff ff       	call   80102892 <kalloc>
80108261:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108264:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108268:	74 5d                	je     801082c7 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010826a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010826d:	05 00 00 00 80       	add    $0x80000000,%eax
80108272:	83 ec 04             	sub    $0x4,%esp
80108275:	68 00 10 00 00       	push   $0x1000
8010827a:	50                   	push   %eax
8010827b:	ff 75 e0             	pushl  -0x20(%ebp)
8010827e:	e8 75 ce ff ff       	call   801050f8 <memmove>
80108283:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108286:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108289:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010828c:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108295:	83 ec 0c             	sub    $0xc,%esp
80108298:	52                   	push   %edx
80108299:	51                   	push   %ecx
8010829a:	68 00 10 00 00       	push   $0x1000
8010829f:	50                   	push   %eax
801082a0:	ff 75 f0             	pushl  -0x10(%ebp)
801082a3:	e8 d0 f7 ff ff       	call   80107a78 <mappages>
801082a8:	83 c4 20             	add    $0x20,%esp
801082ab:	85 c0                	test   %eax,%eax
801082ad:	78 1b                	js     801082ca <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
801082af:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082bc:	0f 82 3d ff ff ff    	jb     801081ff <copyuvm+0x2e>
      goto bad;
  }
  return d;
801082c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c5:	eb 17                	jmp    801082de <copyuvm+0x10d>
      goto bad;
801082c7:	90                   	nop
801082c8:	eb 01                	jmp    801082cb <copyuvm+0xfa>
      goto bad;
801082ca:	90                   	nop

bad:
  freevm(d);
801082cb:	83 ec 0c             	sub    $0xc,%esp
801082ce:	ff 75 f0             	pushl  -0x10(%ebp)
801082d1:	e8 19 fe ff ff       	call   801080ef <freevm>
801082d6:	83 c4 10             	add    $0x10,%esp
  return 0;
801082d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082de:	c9                   	leave  
801082df:	c3                   	ret    

801082e0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801082e0:	f3 0f 1e fb          	endbr32 
801082e4:	55                   	push   %ebp
801082e5:	89 e5                	mov    %esp,%ebp
801082e7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801082ea:	83 ec 04             	sub    $0x4,%esp
801082ed:	6a 00                	push   $0x0
801082ef:	ff 75 0c             	pushl  0xc(%ebp)
801082f2:	ff 75 08             	pushl  0x8(%ebp)
801082f5:	e8 e4 f6 ff ff       	call   801079de <walkpgdir>
801082fa:	83 c4 10             	add    $0x10,%esp
801082fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108303:	8b 00                	mov    (%eax),%eax
80108305:	83 e0 01             	and    $0x1,%eax
80108308:	85 c0                	test   %eax,%eax
8010830a:	75 07                	jne    80108313 <uva2ka+0x33>
    return 0;
8010830c:	b8 00 00 00 00       	mov    $0x0,%eax
80108311:	eb 22                	jmp    80108335 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80108313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108316:	8b 00                	mov    (%eax),%eax
80108318:	83 e0 04             	and    $0x4,%eax
8010831b:	85 c0                	test   %eax,%eax
8010831d:	75 07                	jne    80108326 <uva2ka+0x46>
    return 0;
8010831f:	b8 00 00 00 00       	mov    $0x0,%eax
80108324:	eb 0f                	jmp    80108335 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80108326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108329:	8b 00                	mov    (%eax),%eax
8010832b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108330:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108335:	c9                   	leave  
80108336:	c3                   	ret    

80108337 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108337:	f3 0f 1e fb          	endbr32 
8010833b:	55                   	push   %ebp
8010833c:	89 e5                	mov    %esp,%ebp
8010833e:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108341:	8b 45 10             	mov    0x10(%ebp),%eax
80108344:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108347:	eb 7f                	jmp    801083c8 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108349:	8b 45 0c             	mov    0xc(%ebp),%eax
8010834c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108351:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108354:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108357:	83 ec 08             	sub    $0x8,%esp
8010835a:	50                   	push   %eax
8010835b:	ff 75 08             	pushl  0x8(%ebp)
8010835e:	e8 7d ff ff ff       	call   801082e0 <uva2ka>
80108363:	83 c4 10             	add    $0x10,%esp
80108366:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108369:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010836d:	75 07                	jne    80108376 <copyout+0x3f>
      return -1;
8010836f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108374:	eb 61                	jmp    801083d7 <copyout+0xa0>
    n = PGSIZE - (va - va0);
80108376:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108379:	2b 45 0c             	sub    0xc(%ebp),%eax
8010837c:	05 00 10 00 00       	add    $0x1000,%eax
80108381:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108384:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108387:	3b 45 14             	cmp    0x14(%ebp),%eax
8010838a:	76 06                	jbe    80108392 <copyout+0x5b>
      n = len;
8010838c:	8b 45 14             	mov    0x14(%ebp),%eax
8010838f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108392:	8b 45 0c             	mov    0xc(%ebp),%eax
80108395:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108398:	89 c2                	mov    %eax,%edx
8010839a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010839d:	01 d0                	add    %edx,%eax
8010839f:	83 ec 04             	sub    $0x4,%esp
801083a2:	ff 75 f0             	pushl  -0x10(%ebp)
801083a5:	ff 75 f4             	pushl  -0xc(%ebp)
801083a8:	50                   	push   %eax
801083a9:	e8 4a cd ff ff       	call   801050f8 <memmove>
801083ae:	83 c4 10             	add    $0x10,%esp
    len -= n;
801083b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b4:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801083b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ba:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801083bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c0:	05 00 10 00 00       	add    $0x1000,%eax
801083c5:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801083c8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801083cc:	0f 85 77 ff ff ff    	jne    80108349 <copyout+0x12>
  }
  return 0;
801083d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083d7:	c9                   	leave  
801083d8:	c3                   	ret    

801083d9 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801083d9:	f3 0f 1e fb          	endbr32 
801083dd:	55                   	push   %ebp
801083de:	89 e5                	mov    %esp,%ebp
801083e0:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801083e3:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801083ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083ed:	8b 40 08             	mov    0x8(%eax),%eax
801083f0:	05 00 00 00 80       	add    $0x80000000,%eax
801083f5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801083f8:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801083ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108402:	8b 40 24             	mov    0x24(%eax),%eax
80108405:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
8010840a:	c7 05 90 88 19 80 00 	movl   $0x0,0x80198890
80108411:	00 00 00 

  while(i<madt->len){
80108414:	90                   	nop
80108415:	e9 be 00 00 00       	jmp    801084d8 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
8010841a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010841d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108420:	01 d0                	add    %edx,%eax
80108422:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108428:	0f b6 00             	movzbl (%eax),%eax
8010842b:	0f b6 c0             	movzbl %al,%eax
8010842e:	83 f8 05             	cmp    $0x5,%eax
80108431:	0f 87 a1 00 00 00    	ja     801084d8 <mpinit_uefi+0xff>
80108437:	8b 04 85 f4 af 10 80 	mov    -0x7fef500c(,%eax,4),%eax
8010843e:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108444:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108447:	a1 90 88 19 80       	mov    0x80198890,%eax
8010844c:	83 f8 03             	cmp    $0x3,%eax
8010844f:	7f 28                	jg     80108479 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108451:	8b 15 90 88 19 80    	mov    0x80198890,%edx
80108457:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010845a:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010845e:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108464:	81 c2 c0 85 19 80    	add    $0x801985c0,%edx
8010846a:	88 02                	mov    %al,(%edx)
          ncpu++;
8010846c:	a1 90 88 19 80       	mov    0x80198890,%eax
80108471:	83 c0 01             	add    $0x1,%eax
80108474:	a3 90 88 19 80       	mov    %eax,0x80198890
        }
        i += lapic_entry->record_len;
80108479:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010847c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108480:	0f b6 c0             	movzbl %al,%eax
80108483:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108486:	eb 50                	jmp    801084d8 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108488:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010848b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010848e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108491:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108495:	a2 a0 85 19 80       	mov    %al,0x801985a0
        i += ioapic->record_len;
8010849a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010849d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084a1:	0f b6 c0             	movzbl %al,%eax
801084a4:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801084a7:	eb 2f                	jmp    801084d8 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801084a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801084af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084b2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084b6:	0f b6 c0             	movzbl %al,%eax
801084b9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801084bc:	eb 1a                	jmp    801084d8 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801084be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801084c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084c7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084cb:	0f b6 c0             	movzbl %al,%eax
801084ce:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801084d1:	eb 05                	jmp    801084d8 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
801084d3:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801084d7:	90                   	nop
  while(i<madt->len){
801084d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084db:	8b 40 04             	mov    0x4(%eax),%eax
801084de:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801084e1:	0f 82 33 ff ff ff    	jb     8010841a <mpinit_uefi+0x41>
    }
  }

}
801084e7:	90                   	nop
801084e8:	90                   	nop
801084e9:	c9                   	leave  
801084ea:	c3                   	ret    

801084eb <inb>:
{
801084eb:	55                   	push   %ebp
801084ec:	89 e5                	mov    %esp,%ebp
801084ee:	83 ec 14             	sub    $0x14,%esp
801084f1:	8b 45 08             	mov    0x8(%ebp),%eax
801084f4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801084f8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801084fc:	89 c2                	mov    %eax,%edx
801084fe:	ec                   	in     (%dx),%al
801084ff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108502:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108506:	c9                   	leave  
80108507:	c3                   	ret    

80108508 <outb>:
{
80108508:	55                   	push   %ebp
80108509:	89 e5                	mov    %esp,%ebp
8010850b:	83 ec 08             	sub    $0x8,%esp
8010850e:	8b 45 08             	mov    0x8(%ebp),%eax
80108511:	8b 55 0c             	mov    0xc(%ebp),%edx
80108514:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108518:	89 d0                	mov    %edx,%eax
8010851a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010851d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108521:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108525:	ee                   	out    %al,(%dx)
}
80108526:	90                   	nop
80108527:	c9                   	leave  
80108528:	c3                   	ret    

80108529 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108529:	f3 0f 1e fb          	endbr32 
8010852d:	55                   	push   %ebp
8010852e:	89 e5                	mov    %esp,%ebp
80108530:	83 ec 28             	sub    $0x28,%esp
80108533:	8b 45 08             	mov    0x8(%ebp),%eax
80108536:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108539:	6a 00                	push   $0x0
8010853b:	68 fa 03 00 00       	push   $0x3fa
80108540:	e8 c3 ff ff ff       	call   80108508 <outb>
80108545:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108548:	68 80 00 00 00       	push   $0x80
8010854d:	68 fb 03 00 00       	push   $0x3fb
80108552:	e8 b1 ff ff ff       	call   80108508 <outb>
80108557:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010855a:	6a 0c                	push   $0xc
8010855c:	68 f8 03 00 00       	push   $0x3f8
80108561:	e8 a2 ff ff ff       	call   80108508 <outb>
80108566:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108569:	6a 00                	push   $0x0
8010856b:	68 f9 03 00 00       	push   $0x3f9
80108570:	e8 93 ff ff ff       	call   80108508 <outb>
80108575:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108578:	6a 03                	push   $0x3
8010857a:	68 fb 03 00 00       	push   $0x3fb
8010857f:	e8 84 ff ff ff       	call   80108508 <outb>
80108584:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108587:	6a 00                	push   $0x0
80108589:	68 fc 03 00 00       	push   $0x3fc
8010858e:	e8 75 ff ff ff       	call   80108508 <outb>
80108593:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108596:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010859d:	eb 11                	jmp    801085b0 <uart_debug+0x87>
8010859f:	83 ec 0c             	sub    $0xc,%esp
801085a2:	6a 0a                	push   $0xa
801085a4:	e8 9b a6 ff ff       	call   80102c44 <microdelay>
801085a9:	83 c4 10             	add    $0x10,%esp
801085ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085b0:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801085b4:	7f 1a                	jg     801085d0 <uart_debug+0xa7>
801085b6:	83 ec 0c             	sub    $0xc,%esp
801085b9:	68 fd 03 00 00       	push   $0x3fd
801085be:	e8 28 ff ff ff       	call   801084eb <inb>
801085c3:	83 c4 10             	add    $0x10,%esp
801085c6:	0f b6 c0             	movzbl %al,%eax
801085c9:	83 e0 20             	and    $0x20,%eax
801085cc:	85 c0                	test   %eax,%eax
801085ce:	74 cf                	je     8010859f <uart_debug+0x76>
  outb(COM1+0, p);
801085d0:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801085d4:	0f b6 c0             	movzbl %al,%eax
801085d7:	83 ec 08             	sub    $0x8,%esp
801085da:	50                   	push   %eax
801085db:	68 f8 03 00 00       	push   $0x3f8
801085e0:	e8 23 ff ff ff       	call   80108508 <outb>
801085e5:	83 c4 10             	add    $0x10,%esp
}
801085e8:	90                   	nop
801085e9:	c9                   	leave  
801085ea:	c3                   	ret    

801085eb <uart_debugs>:

void uart_debugs(char *p){
801085eb:	f3 0f 1e fb          	endbr32 
801085ef:	55                   	push   %ebp
801085f0:	89 e5                	mov    %esp,%ebp
801085f2:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801085f5:	eb 1b                	jmp    80108612 <uart_debugs+0x27>
    uart_debug(*p++);
801085f7:	8b 45 08             	mov    0x8(%ebp),%eax
801085fa:	8d 50 01             	lea    0x1(%eax),%edx
801085fd:	89 55 08             	mov    %edx,0x8(%ebp)
80108600:	0f b6 00             	movzbl (%eax),%eax
80108603:	0f be c0             	movsbl %al,%eax
80108606:	83 ec 0c             	sub    $0xc,%esp
80108609:	50                   	push   %eax
8010860a:	e8 1a ff ff ff       	call   80108529 <uart_debug>
8010860f:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108612:	8b 45 08             	mov    0x8(%ebp),%eax
80108615:	0f b6 00             	movzbl (%eax),%eax
80108618:	84 c0                	test   %al,%al
8010861a:	75 db                	jne    801085f7 <uart_debugs+0xc>
  }
}
8010861c:	90                   	nop
8010861d:	90                   	nop
8010861e:	c9                   	leave  
8010861f:	c3                   	ret    

80108620 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108620:	f3 0f 1e fb          	endbr32 
80108624:	55                   	push   %ebp
80108625:	89 e5                	mov    %esp,%ebp
80108627:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010862a:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108631:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108634:	8b 50 14             	mov    0x14(%eax),%edx
80108637:	8b 40 10             	mov    0x10(%eax),%eax
8010863a:	a3 94 88 19 80       	mov    %eax,0x80198894
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010863f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108642:	8b 50 1c             	mov    0x1c(%eax),%edx
80108645:	8b 40 18             	mov    0x18(%eax),%eax
80108648:	a3 9c 88 19 80       	mov    %eax,0x8019889c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010864d:	a1 9c 88 19 80       	mov    0x8019889c,%eax
80108652:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108657:	29 c2                	sub    %eax,%edx
80108659:	89 d0                	mov    %edx,%eax
8010865b:	a3 98 88 19 80       	mov    %eax,0x80198898
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108660:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108663:	8b 50 24             	mov    0x24(%eax),%edx
80108666:	8b 40 20             	mov    0x20(%eax),%eax
80108669:	a3 a0 88 19 80       	mov    %eax,0x801988a0
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010866e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108671:	8b 50 2c             	mov    0x2c(%eax),%edx
80108674:	8b 40 28             	mov    0x28(%eax),%eax
80108677:	a3 a4 88 19 80       	mov    %eax,0x801988a4
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010867c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010867f:	8b 50 34             	mov    0x34(%eax),%edx
80108682:	8b 40 30             	mov    0x30(%eax),%eax
80108685:	a3 a8 88 19 80       	mov    %eax,0x801988a8
}
8010868a:	90                   	nop
8010868b:	c9                   	leave  
8010868c:	c3                   	ret    

8010868d <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010868d:	f3 0f 1e fb          	endbr32 
80108691:	55                   	push   %ebp
80108692:	89 e5                	mov    %esp,%ebp
80108694:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108697:	8b 15 a8 88 19 80    	mov    0x801988a8,%edx
8010869d:	8b 45 0c             	mov    0xc(%ebp),%eax
801086a0:	0f af d0             	imul   %eax,%edx
801086a3:	8b 45 08             	mov    0x8(%ebp),%eax
801086a6:	01 d0                	add    %edx,%eax
801086a8:	c1 e0 02             	shl    $0x2,%eax
801086ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801086ae:	8b 15 98 88 19 80    	mov    0x80198898,%edx
801086b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086b7:	01 d0                	add    %edx,%eax
801086b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801086bc:	8b 45 10             	mov    0x10(%ebp),%eax
801086bf:	0f b6 10             	movzbl (%eax),%edx
801086c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801086c5:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801086c7:	8b 45 10             	mov    0x10(%ebp),%eax
801086ca:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801086ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
801086d1:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801086d4:	8b 45 10             	mov    0x10(%ebp),%eax
801086d7:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801086db:	8b 45 f8             	mov    -0x8(%ebp),%eax
801086de:	88 50 02             	mov    %dl,0x2(%eax)
}
801086e1:	90                   	nop
801086e2:	c9                   	leave  
801086e3:	c3                   	ret    

801086e4 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801086e4:	f3 0f 1e fb          	endbr32 
801086e8:	55                   	push   %ebp
801086e9:	89 e5                	mov    %esp,%ebp
801086eb:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801086ee:	8b 15 a8 88 19 80    	mov    0x801988a8,%edx
801086f4:	8b 45 08             	mov    0x8(%ebp),%eax
801086f7:	0f af c2             	imul   %edx,%eax
801086fa:	c1 e0 02             	shl    $0x2,%eax
801086fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108700:	8b 15 9c 88 19 80    	mov    0x8019889c,%edx
80108706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108709:	29 c2                	sub    %eax,%edx
8010870b:	89 d0                	mov    %edx,%eax
8010870d:	8b 0d 98 88 19 80    	mov    0x80198898,%ecx
80108713:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108716:	01 ca                	add    %ecx,%edx
80108718:	89 d1                	mov    %edx,%ecx
8010871a:	8b 15 98 88 19 80    	mov    0x80198898,%edx
80108720:	83 ec 04             	sub    $0x4,%esp
80108723:	50                   	push   %eax
80108724:	51                   	push   %ecx
80108725:	52                   	push   %edx
80108726:	e8 cd c9 ff ff       	call   801050f8 <memmove>
8010872b:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
8010872e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108731:	8b 0d 98 88 19 80    	mov    0x80198898,%ecx
80108737:	8b 15 9c 88 19 80    	mov    0x8019889c,%edx
8010873d:	01 d1                	add    %edx,%ecx
8010873f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108742:	29 d1                	sub    %edx,%ecx
80108744:	89 ca                	mov    %ecx,%edx
80108746:	83 ec 04             	sub    $0x4,%esp
80108749:	50                   	push   %eax
8010874a:	6a 00                	push   $0x0
8010874c:	52                   	push   %edx
8010874d:	e8 df c8 ff ff       	call   80105031 <memset>
80108752:	83 c4 10             	add    $0x10,%esp
}
80108755:	90                   	nop
80108756:	c9                   	leave  
80108757:	c3                   	ret    

80108758 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108758:	f3 0f 1e fb          	endbr32 
8010875c:	55                   	push   %ebp
8010875d:	89 e5                	mov    %esp,%ebp
8010875f:	53                   	push   %ebx
80108760:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108763:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010876a:	e9 b1 00 00 00       	jmp    80108820 <font_render+0xc8>
    for(int j=14;j>-1;j--){
8010876f:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108776:	e9 97 00 00 00       	jmp    80108812 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
8010877b:	8b 45 10             	mov    0x10(%ebp),%eax
8010877e:	83 e8 20             	sub    $0x20,%eax
80108781:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108787:	01 d0                	add    %edx,%eax
80108789:	0f b7 84 00 20 b0 10 	movzwl -0x7fef4fe0(%eax,%eax,1),%eax
80108790:	80 
80108791:	0f b7 d0             	movzwl %ax,%edx
80108794:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108797:	bb 01 00 00 00       	mov    $0x1,%ebx
8010879c:	89 c1                	mov    %eax,%ecx
8010879e:	d3 e3                	shl    %cl,%ebx
801087a0:	89 d8                	mov    %ebx,%eax
801087a2:	21 d0                	and    %edx,%eax
801087a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801087a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087aa:	ba 01 00 00 00       	mov    $0x1,%edx
801087af:	89 c1                	mov    %eax,%ecx
801087b1:	d3 e2                	shl    %cl,%edx
801087b3:	89 d0                	mov    %edx,%eax
801087b5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801087b8:	75 2b                	jne    801087e5 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801087ba:	8b 55 0c             	mov    0xc(%ebp),%edx
801087bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c0:	01 c2                	add    %eax,%edx
801087c2:	b8 0e 00 00 00       	mov    $0xe,%eax
801087c7:	2b 45 f0             	sub    -0x10(%ebp),%eax
801087ca:	89 c1                	mov    %eax,%ecx
801087cc:	8b 45 08             	mov    0x8(%ebp),%eax
801087cf:	01 c8                	add    %ecx,%eax
801087d1:	83 ec 04             	sub    $0x4,%esp
801087d4:	68 00 f5 10 80       	push   $0x8010f500
801087d9:	52                   	push   %edx
801087da:	50                   	push   %eax
801087db:	e8 ad fe ff ff       	call   8010868d <graphic_draw_pixel>
801087e0:	83 c4 10             	add    $0x10,%esp
801087e3:	eb 29                	jmp    8010880e <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801087e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801087e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087eb:	01 c2                	add    %eax,%edx
801087ed:	b8 0e 00 00 00       	mov    $0xe,%eax
801087f2:	2b 45 f0             	sub    -0x10(%ebp),%eax
801087f5:	89 c1                	mov    %eax,%ecx
801087f7:	8b 45 08             	mov    0x8(%ebp),%eax
801087fa:	01 c8                	add    %ecx,%eax
801087fc:	83 ec 04             	sub    $0x4,%esp
801087ff:	68 64 d0 18 80       	push   $0x8018d064
80108804:	52                   	push   %edx
80108805:	50                   	push   %eax
80108806:	e8 82 fe ff ff       	call   8010868d <graphic_draw_pixel>
8010880b:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010880e:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108812:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108816:	0f 89 5f ff ff ff    	jns    8010877b <font_render+0x23>
  for(int i=0;i<30;i++){
8010881c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108820:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108824:	0f 8e 45 ff ff ff    	jle    8010876f <font_render+0x17>
      }
    }
  }
}
8010882a:	90                   	nop
8010882b:	90                   	nop
8010882c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010882f:	c9                   	leave  
80108830:	c3                   	ret    

80108831 <font_render_string>:

void font_render_string(char *string,int row){
80108831:	f3 0f 1e fb          	endbr32 
80108835:	55                   	push   %ebp
80108836:	89 e5                	mov    %esp,%ebp
80108838:	53                   	push   %ebx
80108839:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010883c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108843:	eb 33                	jmp    80108878 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108845:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108848:	8b 45 08             	mov    0x8(%ebp),%eax
8010884b:	01 d0                	add    %edx,%eax
8010884d:	0f b6 00             	movzbl (%eax),%eax
80108850:	0f be d8             	movsbl %al,%ebx
80108853:	8b 45 0c             	mov    0xc(%ebp),%eax
80108856:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108859:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010885c:	89 d0                	mov    %edx,%eax
8010885e:	c1 e0 04             	shl    $0x4,%eax
80108861:	29 d0                	sub    %edx,%eax
80108863:	83 c0 02             	add    $0x2,%eax
80108866:	83 ec 04             	sub    $0x4,%esp
80108869:	53                   	push   %ebx
8010886a:	51                   	push   %ecx
8010886b:	50                   	push   %eax
8010886c:	e8 e7 fe ff ff       	call   80108758 <font_render>
80108871:	83 c4 10             	add    $0x10,%esp
    i++;
80108874:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108878:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010887b:	8b 45 08             	mov    0x8(%ebp),%eax
8010887e:	01 d0                	add    %edx,%eax
80108880:	0f b6 00             	movzbl (%eax),%eax
80108883:	84 c0                	test   %al,%al
80108885:	74 06                	je     8010888d <font_render_string+0x5c>
80108887:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
8010888b:	7e b8                	jle    80108845 <font_render_string+0x14>
  }
}
8010888d:	90                   	nop
8010888e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108891:	c9                   	leave  
80108892:	c3                   	ret    

80108893 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108893:	f3 0f 1e fb          	endbr32 
80108897:	55                   	push   %ebp
80108898:	89 e5                	mov    %esp,%ebp
8010889a:	53                   	push   %ebx
8010889b:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
8010889e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088a5:	eb 6b                	jmp    80108912 <pci_init+0x7f>
    for(int j=0;j<32;j++){
801088a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801088ae:	eb 58                	jmp    80108908 <pci_init+0x75>
      for(int k=0;k<8;k++){
801088b0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801088b7:	eb 45                	jmp    801088fe <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801088b9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801088bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801088bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c2:	83 ec 0c             	sub    $0xc,%esp
801088c5:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801088c8:	53                   	push   %ebx
801088c9:	6a 00                	push   $0x0
801088cb:	51                   	push   %ecx
801088cc:	52                   	push   %edx
801088cd:	50                   	push   %eax
801088ce:	e8 c0 00 00 00       	call   80108993 <pci_access_config>
801088d3:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801088d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088d9:	0f b7 c0             	movzwl %ax,%eax
801088dc:	3d ff ff 00 00       	cmp    $0xffff,%eax
801088e1:	74 17                	je     801088fa <pci_init+0x67>
        pci_init_device(i,j,k);
801088e3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801088e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801088e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ec:	83 ec 04             	sub    $0x4,%esp
801088ef:	51                   	push   %ecx
801088f0:	52                   	push   %edx
801088f1:	50                   	push   %eax
801088f2:	e8 4f 01 00 00       	call   80108a46 <pci_init_device>
801088f7:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801088fa:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801088fe:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108902:	7e b5                	jle    801088b9 <pci_init+0x26>
    for(int j=0;j<32;j++){
80108904:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108908:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010890c:	7e a2                	jle    801088b0 <pci_init+0x1d>
  for(int i=0;i<256;i++){
8010890e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108912:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108919:	7e 8c                	jle    801088a7 <pci_init+0x14>
      }
      }
    }
  }
}
8010891b:	90                   	nop
8010891c:	90                   	nop
8010891d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108920:	c9                   	leave  
80108921:	c3                   	ret    

80108922 <pci_write_config>:

void pci_write_config(uint config){
80108922:	f3 0f 1e fb          	endbr32 
80108926:	55                   	push   %ebp
80108927:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108929:	8b 45 08             	mov    0x8(%ebp),%eax
8010892c:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108931:	89 c0                	mov    %eax,%eax
80108933:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108934:	90                   	nop
80108935:	5d                   	pop    %ebp
80108936:	c3                   	ret    

80108937 <pci_write_data>:

void pci_write_data(uint config){
80108937:	f3 0f 1e fb          	endbr32 
8010893b:	55                   	push   %ebp
8010893c:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010893e:	8b 45 08             	mov    0x8(%ebp),%eax
80108941:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108946:	89 c0                	mov    %eax,%eax
80108948:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108949:	90                   	nop
8010894a:	5d                   	pop    %ebp
8010894b:	c3                   	ret    

8010894c <pci_read_config>:
uint pci_read_config(){
8010894c:	f3 0f 1e fb          	endbr32 
80108950:	55                   	push   %ebp
80108951:	89 e5                	mov    %esp,%ebp
80108953:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108956:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010895b:	ed                   	in     (%dx),%eax
8010895c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
8010895f:	83 ec 0c             	sub    $0xc,%esp
80108962:	68 c8 00 00 00       	push   $0xc8
80108967:	e8 d8 a2 ff ff       	call   80102c44 <microdelay>
8010896c:	83 c4 10             	add    $0x10,%esp
  return data;
8010896f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108972:	c9                   	leave  
80108973:	c3                   	ret    

80108974 <pci_test>:


void pci_test(){
80108974:	f3 0f 1e fb          	endbr32 
80108978:	55                   	push   %ebp
80108979:	89 e5                	mov    %esp,%ebp
8010897b:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
8010897e:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108985:	ff 75 fc             	pushl  -0x4(%ebp)
80108988:	e8 95 ff ff ff       	call   80108922 <pci_write_config>
8010898d:	83 c4 04             	add    $0x4,%esp
}
80108990:	90                   	nop
80108991:	c9                   	leave  
80108992:	c3                   	ret    

80108993 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108993:	f3 0f 1e fb          	endbr32 
80108997:	55                   	push   %ebp
80108998:	89 e5                	mov    %esp,%ebp
8010899a:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010899d:	8b 45 08             	mov    0x8(%ebp),%eax
801089a0:	c1 e0 10             	shl    $0x10,%eax
801089a3:	25 00 00 ff 00       	and    $0xff0000,%eax
801089a8:	89 c2                	mov    %eax,%edx
801089aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801089ad:	c1 e0 0b             	shl    $0xb,%eax
801089b0:	0f b7 c0             	movzwl %ax,%eax
801089b3:	09 c2                	or     %eax,%edx
801089b5:	8b 45 10             	mov    0x10(%ebp),%eax
801089b8:	c1 e0 08             	shl    $0x8,%eax
801089bb:	25 00 07 00 00       	and    $0x700,%eax
801089c0:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801089c2:	8b 45 14             	mov    0x14(%ebp),%eax
801089c5:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801089ca:	09 d0                	or     %edx,%eax
801089cc:	0d 00 00 00 80       	or     $0x80000000,%eax
801089d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801089d4:	ff 75 f4             	pushl  -0xc(%ebp)
801089d7:	e8 46 ff ff ff       	call   80108922 <pci_write_config>
801089dc:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801089df:	e8 68 ff ff ff       	call   8010894c <pci_read_config>
801089e4:	8b 55 18             	mov    0x18(%ebp),%edx
801089e7:	89 02                	mov    %eax,(%edx)
}
801089e9:	90                   	nop
801089ea:	c9                   	leave  
801089eb:	c3                   	ret    

801089ec <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801089ec:	f3 0f 1e fb          	endbr32 
801089f0:	55                   	push   %ebp
801089f1:	89 e5                	mov    %esp,%ebp
801089f3:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801089f6:	8b 45 08             	mov    0x8(%ebp),%eax
801089f9:	c1 e0 10             	shl    $0x10,%eax
801089fc:	25 00 00 ff 00       	and    $0xff0000,%eax
80108a01:	89 c2                	mov    %eax,%edx
80108a03:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a06:	c1 e0 0b             	shl    $0xb,%eax
80108a09:	0f b7 c0             	movzwl %ax,%eax
80108a0c:	09 c2                	or     %eax,%edx
80108a0e:	8b 45 10             	mov    0x10(%ebp),%eax
80108a11:	c1 e0 08             	shl    $0x8,%eax
80108a14:	25 00 07 00 00       	and    $0x700,%eax
80108a19:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108a1b:	8b 45 14             	mov    0x14(%ebp),%eax
80108a1e:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a23:	09 d0                	or     %edx,%eax
80108a25:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a2a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108a2d:	ff 75 fc             	pushl  -0x4(%ebp)
80108a30:	e8 ed fe ff ff       	call   80108922 <pci_write_config>
80108a35:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108a38:	ff 75 18             	pushl  0x18(%ebp)
80108a3b:	e8 f7 fe ff ff       	call   80108937 <pci_write_data>
80108a40:	83 c4 04             	add    $0x4,%esp
}
80108a43:	90                   	nop
80108a44:	c9                   	leave  
80108a45:	c3                   	ret    

80108a46 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108a46:	f3 0f 1e fb          	endbr32 
80108a4a:	55                   	push   %ebp
80108a4b:	89 e5                	mov    %esp,%ebp
80108a4d:	53                   	push   %ebx
80108a4e:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108a51:	8b 45 08             	mov    0x8(%ebp),%eax
80108a54:	a2 ac 88 19 80       	mov    %al,0x801988ac
  dev.device_num = device_num;
80108a59:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a5c:	a2 ad 88 19 80       	mov    %al,0x801988ad
  dev.function_num = function_num;
80108a61:	8b 45 10             	mov    0x10(%ebp),%eax
80108a64:	a2 ae 88 19 80       	mov    %al,0x801988ae
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108a69:	ff 75 10             	pushl  0x10(%ebp)
80108a6c:	ff 75 0c             	pushl  0xc(%ebp)
80108a6f:	ff 75 08             	pushl  0x8(%ebp)
80108a72:	68 64 c6 10 80       	push   $0x8010c664
80108a77:	e8 90 79 ff ff       	call   8010040c <cprintf>
80108a7c:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108a7f:	83 ec 0c             	sub    $0xc,%esp
80108a82:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a85:	50                   	push   %eax
80108a86:	6a 00                	push   $0x0
80108a88:	ff 75 10             	pushl  0x10(%ebp)
80108a8b:	ff 75 0c             	pushl  0xc(%ebp)
80108a8e:	ff 75 08             	pushl  0x8(%ebp)
80108a91:	e8 fd fe ff ff       	call   80108993 <pci_access_config>
80108a96:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108a99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a9c:	c1 e8 10             	shr    $0x10,%eax
80108a9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108aa2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aa5:	25 ff ff 00 00       	and    $0xffff,%eax
80108aaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab0:	a3 b0 88 19 80       	mov    %eax,0x801988b0
  dev.vendor_id = vendor_id;
80108ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ab8:	a3 b4 88 19 80       	mov    %eax,0x801988b4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108abd:	83 ec 04             	sub    $0x4,%esp
80108ac0:	ff 75 f0             	pushl  -0x10(%ebp)
80108ac3:	ff 75 f4             	pushl  -0xc(%ebp)
80108ac6:	68 98 c6 10 80       	push   $0x8010c698
80108acb:	e8 3c 79 ff ff       	call   8010040c <cprintf>
80108ad0:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108ad3:	83 ec 0c             	sub    $0xc,%esp
80108ad6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ad9:	50                   	push   %eax
80108ada:	6a 08                	push   $0x8
80108adc:	ff 75 10             	pushl  0x10(%ebp)
80108adf:	ff 75 0c             	pushl  0xc(%ebp)
80108ae2:	ff 75 08             	pushl  0x8(%ebp)
80108ae5:	e8 a9 fe ff ff       	call   80108993 <pci_access_config>
80108aea:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af0:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108af3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af6:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108af9:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108afc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aff:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b02:	0f b6 c0             	movzbl %al,%eax
80108b05:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108b08:	c1 eb 18             	shr    $0x18,%ebx
80108b0b:	83 ec 0c             	sub    $0xc,%esp
80108b0e:	51                   	push   %ecx
80108b0f:	52                   	push   %edx
80108b10:	50                   	push   %eax
80108b11:	53                   	push   %ebx
80108b12:	68 bc c6 10 80       	push   $0x8010c6bc
80108b17:	e8 f0 78 ff ff       	call   8010040c <cprintf>
80108b1c:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108b1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b22:	c1 e8 18             	shr    $0x18,%eax
80108b25:	a2 b8 88 19 80       	mov    %al,0x801988b8
  dev.sub_class = (data>>16)&0xFF;
80108b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b2d:	c1 e8 10             	shr    $0x10,%eax
80108b30:	a2 b9 88 19 80       	mov    %al,0x801988b9
  dev.interface = (data>>8)&0xFF;
80108b35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b38:	c1 e8 08             	shr    $0x8,%eax
80108b3b:	a2 ba 88 19 80       	mov    %al,0x801988ba
  dev.revision_id = data&0xFF;
80108b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b43:	a2 bb 88 19 80       	mov    %al,0x801988bb
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108b48:	83 ec 0c             	sub    $0xc,%esp
80108b4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b4e:	50                   	push   %eax
80108b4f:	6a 10                	push   $0x10
80108b51:	ff 75 10             	pushl  0x10(%ebp)
80108b54:	ff 75 0c             	pushl  0xc(%ebp)
80108b57:	ff 75 08             	pushl  0x8(%ebp)
80108b5a:	e8 34 fe ff ff       	call   80108993 <pci_access_config>
80108b5f:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b65:	a3 bc 88 19 80       	mov    %eax,0x801988bc
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108b6a:	83 ec 0c             	sub    $0xc,%esp
80108b6d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b70:	50                   	push   %eax
80108b71:	6a 14                	push   $0x14
80108b73:	ff 75 10             	pushl  0x10(%ebp)
80108b76:	ff 75 0c             	pushl  0xc(%ebp)
80108b79:	ff 75 08             	pushl  0x8(%ebp)
80108b7c:	e8 12 fe ff ff       	call   80108993 <pci_access_config>
80108b81:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108b84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b87:	a3 c0 88 19 80       	mov    %eax,0x801988c0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108b8c:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108b93:	75 5a                	jne    80108bef <pci_init_device+0x1a9>
80108b95:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108b9c:	75 51                	jne    80108bef <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108b9e:	83 ec 0c             	sub    $0xc,%esp
80108ba1:	68 01 c7 10 80       	push   $0x8010c701
80108ba6:	e8 61 78 ff ff       	call   8010040c <cprintf>
80108bab:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108bae:	83 ec 0c             	sub    $0xc,%esp
80108bb1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108bb4:	50                   	push   %eax
80108bb5:	68 f0 00 00 00       	push   $0xf0
80108bba:	ff 75 10             	pushl  0x10(%ebp)
80108bbd:	ff 75 0c             	pushl  0xc(%ebp)
80108bc0:	ff 75 08             	pushl  0x8(%ebp)
80108bc3:	e8 cb fd ff ff       	call   80108993 <pci_access_config>
80108bc8:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108bcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bce:	83 ec 08             	sub    $0x8,%esp
80108bd1:	50                   	push   %eax
80108bd2:	68 1b c7 10 80       	push   $0x8010c71b
80108bd7:	e8 30 78 ff ff       	call   8010040c <cprintf>
80108bdc:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108bdf:	83 ec 0c             	sub    $0xc,%esp
80108be2:	68 ac 88 19 80       	push   $0x801988ac
80108be7:	e8 09 00 00 00       	call   80108bf5 <i8254_init>
80108bec:	83 c4 10             	add    $0x10,%esp
  }
}
80108bef:	90                   	nop
80108bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108bf3:	c9                   	leave  
80108bf4:	c3                   	ret    

80108bf5 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108bf5:	f3 0f 1e fb          	endbr32 
80108bf9:	55                   	push   %ebp
80108bfa:	89 e5                	mov    %esp,%ebp
80108bfc:	53                   	push   %ebx
80108bfd:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108c00:	8b 45 08             	mov    0x8(%ebp),%eax
80108c03:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108c07:	0f b6 c8             	movzbl %al,%ecx
80108c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80108c0d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108c11:	0f b6 d0             	movzbl %al,%edx
80108c14:	8b 45 08             	mov    0x8(%ebp),%eax
80108c17:	0f b6 00             	movzbl (%eax),%eax
80108c1a:	0f b6 c0             	movzbl %al,%eax
80108c1d:	83 ec 0c             	sub    $0xc,%esp
80108c20:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108c23:	53                   	push   %ebx
80108c24:	6a 04                	push   $0x4
80108c26:	51                   	push   %ecx
80108c27:	52                   	push   %edx
80108c28:	50                   	push   %eax
80108c29:	e8 65 fd ff ff       	call   80108993 <pci_access_config>
80108c2e:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108c31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c34:	83 c8 04             	or     $0x4,%eax
80108c37:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108c3a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80108c40:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108c44:	0f b6 c8             	movzbl %al,%ecx
80108c47:	8b 45 08             	mov    0x8(%ebp),%eax
80108c4a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108c4e:	0f b6 d0             	movzbl %al,%edx
80108c51:	8b 45 08             	mov    0x8(%ebp),%eax
80108c54:	0f b6 00             	movzbl (%eax),%eax
80108c57:	0f b6 c0             	movzbl %al,%eax
80108c5a:	83 ec 0c             	sub    $0xc,%esp
80108c5d:	53                   	push   %ebx
80108c5e:	6a 04                	push   $0x4
80108c60:	51                   	push   %ecx
80108c61:	52                   	push   %edx
80108c62:	50                   	push   %eax
80108c63:	e8 84 fd ff ff       	call   801089ec <pci_write_config_register>
80108c68:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c6e:	8b 40 10             	mov    0x10(%eax),%eax
80108c71:	05 00 00 00 40       	add    $0x40000000,%eax
80108c76:	a3 c4 88 19 80       	mov    %eax,0x801988c4
  uint *ctrl = (uint *)base_addr;
80108c7b:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108c80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108c83:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108c88:	05 d8 00 00 00       	add    $0xd8,%eax
80108c8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c93:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9c:	8b 00                	mov    (%eax),%eax
80108c9e:	0d 00 00 00 04       	or     $0x4000000,%eax
80108ca3:	89 c2                	mov    %eax,%edx
80108ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca8:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cad:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb6:	8b 00                	mov    (%eax),%eax
80108cb8:	83 c8 40             	or     $0x40,%eax
80108cbb:	89 c2                	mov    %eax,%edx
80108cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc0:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc5:	8b 10                	mov    (%eax),%edx
80108cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cca:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108ccc:	83 ec 0c             	sub    $0xc,%esp
80108ccf:	68 30 c7 10 80       	push   $0x8010c730
80108cd4:	e8 33 77 ff ff       	call   8010040c <cprintf>
80108cd9:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108cdc:	e8 b1 9b ff ff       	call   80102892 <kalloc>
80108ce1:	a3 c8 88 19 80       	mov    %eax,0x801988c8
  *intr_addr = 0;
80108ce6:	a1 c8 88 19 80       	mov    0x801988c8,%eax
80108ceb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108cf1:	a1 c8 88 19 80       	mov    0x801988c8,%eax
80108cf6:	83 ec 08             	sub    $0x8,%esp
80108cf9:	50                   	push   %eax
80108cfa:	68 52 c7 10 80       	push   $0x8010c752
80108cff:	e8 08 77 ff ff       	call   8010040c <cprintf>
80108d04:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108d07:	e8 50 00 00 00       	call   80108d5c <i8254_init_recv>
  i8254_init_send();
80108d0c:	e8 6d 03 00 00       	call   8010907e <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108d11:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d18:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108d1b:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d22:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108d25:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d2c:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108d2f:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d36:	0f b6 c0             	movzbl %al,%eax
80108d39:	83 ec 0c             	sub    $0xc,%esp
80108d3c:	53                   	push   %ebx
80108d3d:	51                   	push   %ecx
80108d3e:	52                   	push   %edx
80108d3f:	50                   	push   %eax
80108d40:	68 60 c7 10 80       	push   $0x8010c760
80108d45:	e8 c2 76 ff ff       	call   8010040c <cprintf>
80108d4a:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d50:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108d56:	90                   	nop
80108d57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d5a:	c9                   	leave  
80108d5b:	c3                   	ret    

80108d5c <i8254_init_recv>:

void i8254_init_recv(){
80108d5c:	f3 0f 1e fb          	endbr32 
80108d60:	55                   	push   %ebp
80108d61:	89 e5                	mov    %esp,%ebp
80108d63:	57                   	push   %edi
80108d64:	56                   	push   %esi
80108d65:	53                   	push   %ebx
80108d66:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108d69:	83 ec 0c             	sub    $0xc,%esp
80108d6c:	6a 00                	push   $0x0
80108d6e:	e8 ec 04 00 00       	call   8010925f <i8254_read_eeprom>
80108d73:	83 c4 10             	add    $0x10,%esp
80108d76:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108d79:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d7c:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108d81:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d84:	c1 e8 08             	shr    $0x8,%eax
80108d87:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108d8c:	83 ec 0c             	sub    $0xc,%esp
80108d8f:	6a 01                	push   $0x1
80108d91:	e8 c9 04 00 00       	call   8010925f <i8254_read_eeprom>
80108d96:	83 c4 10             	add    $0x10,%esp
80108d99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108d9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d9f:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108da4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108da7:	c1 e8 08             	shr    $0x8,%eax
80108daa:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108daf:	83 ec 0c             	sub    $0xc,%esp
80108db2:	6a 02                	push   $0x2
80108db4:	e8 a6 04 00 00       	call   8010925f <i8254_read_eeprom>
80108db9:	83 c4 10             	add    $0x10,%esp
80108dbc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108dbf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dc2:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108dc7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dca:	c1 e8 08             	shr    $0x8,%eax
80108dcd:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108dd2:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108dd9:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108ddc:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108de3:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108de6:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ded:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108df0:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108df7:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108dfa:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e01:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108e04:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e0b:	0f b6 c0             	movzbl %al,%eax
80108e0e:	83 ec 04             	sub    $0x4,%esp
80108e11:	57                   	push   %edi
80108e12:	56                   	push   %esi
80108e13:	53                   	push   %ebx
80108e14:	51                   	push   %ecx
80108e15:	52                   	push   %edx
80108e16:	50                   	push   %eax
80108e17:	68 78 c7 10 80       	push   $0x8010c778
80108e1c:	e8 eb 75 ff ff       	call   8010040c <cprintf>
80108e21:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108e24:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108e29:	05 00 54 00 00       	add    $0x5400,%eax
80108e2e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108e31:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108e36:	05 04 54 00 00       	add    $0x5404,%eax
80108e3b:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108e3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e41:	c1 e0 10             	shl    $0x10,%eax
80108e44:	0b 45 d8             	or     -0x28(%ebp),%eax
80108e47:	89 c2                	mov    %eax,%edx
80108e49:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108e4c:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108e4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e51:	0d 00 00 00 80       	or     $0x80000000,%eax
80108e56:	89 c2                	mov    %eax,%edx
80108e58:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108e5b:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108e5d:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108e62:	05 00 52 00 00       	add    $0x5200,%eax
80108e67:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108e6a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108e71:	eb 19                	jmp    80108e8c <i8254_init_recv+0x130>
    mta[i] = 0;
80108e73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e7d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108e80:	01 d0                	add    %edx,%eax
80108e82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108e88:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108e8c:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108e90:	7e e1                	jle    80108e73 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108e92:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108e97:	05 d0 00 00 00       	add    $0xd0,%eax
80108e9c:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108e9f:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108ea2:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108ea8:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108ead:	05 c8 00 00 00       	add    $0xc8,%eax
80108eb2:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108eb5:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108eb8:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108ebe:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108ec3:	05 28 28 00 00       	add    $0x2828,%eax
80108ec8:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108ecb:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108ece:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108ed4:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108ed9:	05 00 01 00 00       	add    $0x100,%eax
80108ede:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108ee1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ee4:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108eea:	e8 a3 99 ff ff       	call   80102892 <kalloc>
80108eef:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ef2:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108ef7:	05 00 28 00 00       	add    $0x2800,%eax
80108efc:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108eff:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108f04:	05 04 28 00 00       	add    $0x2804,%eax
80108f09:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108f0c:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108f11:	05 08 28 00 00       	add    $0x2808,%eax
80108f16:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f19:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108f1e:	05 10 28 00 00       	add    $0x2810,%eax
80108f23:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f26:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80108f2b:	05 18 28 00 00       	add    $0x2818,%eax
80108f30:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108f33:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108f36:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f3c:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108f3f:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108f41:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108f44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108f4a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108f4d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108f53:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108f56:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108f5c:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108f5f:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108f65:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108f68:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108f6b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108f72:	eb 73                	jmp    80108fe7 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108f74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f77:	c1 e0 04             	shl    $0x4,%eax
80108f7a:	89 c2                	mov    %eax,%edx
80108f7c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f7f:	01 d0                	add    %edx,%eax
80108f81:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108f88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f8b:	c1 e0 04             	shl    $0x4,%eax
80108f8e:	89 c2                	mov    %eax,%edx
80108f90:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f93:	01 d0                	add    %edx,%eax
80108f95:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108f9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f9e:	c1 e0 04             	shl    $0x4,%eax
80108fa1:	89 c2                	mov    %eax,%edx
80108fa3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fa6:	01 d0                	add    %edx,%eax
80108fa8:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108fae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fb1:	c1 e0 04             	shl    $0x4,%eax
80108fb4:	89 c2                	mov    %eax,%edx
80108fb6:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fb9:	01 d0                	add    %edx,%eax
80108fbb:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108fbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fc2:	c1 e0 04             	shl    $0x4,%eax
80108fc5:	89 c2                	mov    %eax,%edx
80108fc7:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fca:	01 d0                	add    %edx,%eax
80108fcc:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108fd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fd3:	c1 e0 04             	shl    $0x4,%eax
80108fd6:	89 c2                	mov    %eax,%edx
80108fd8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fdb:	01 d0                	add    %edx,%eax
80108fdd:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108fe3:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108fe7:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108fee:	7e 84                	jle    80108f74 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108ff0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108ff7:	eb 57                	jmp    80109050 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108ff9:	e8 94 98 ff ff       	call   80102892 <kalloc>
80108ffe:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109001:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109005:	75 12                	jne    80109019 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80109007:	83 ec 0c             	sub    $0xc,%esp
8010900a:	68 98 c7 10 80       	push   $0x8010c798
8010900f:	e8 f8 73 ff ff       	call   8010040c <cprintf>
80109014:	83 c4 10             	add    $0x10,%esp
      break;
80109017:	eb 3d                	jmp    80109056 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109019:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010901c:	c1 e0 04             	shl    $0x4,%eax
8010901f:	89 c2                	mov    %eax,%edx
80109021:	8b 45 98             	mov    -0x68(%ebp),%eax
80109024:	01 d0                	add    %edx,%eax
80109026:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109029:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010902f:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109031:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109034:	83 c0 01             	add    $0x1,%eax
80109037:	c1 e0 04             	shl    $0x4,%eax
8010903a:	89 c2                	mov    %eax,%edx
8010903c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010903f:	01 d0                	add    %edx,%eax
80109041:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109044:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010904a:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010904c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80109050:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80109054:	7e a3                	jle    80108ff9 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80109056:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109059:	8b 00                	mov    (%eax),%eax
8010905b:	83 c8 02             	or     $0x2,%eax
8010905e:	89 c2                	mov    %eax,%edx
80109060:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109063:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80109065:	83 ec 0c             	sub    $0xc,%esp
80109068:	68 b8 c7 10 80       	push   $0x8010c7b8
8010906d:	e8 9a 73 ff ff       	call   8010040c <cprintf>
80109072:	83 c4 10             	add    $0x10,%esp
}
80109075:	90                   	nop
80109076:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109079:	5b                   	pop    %ebx
8010907a:	5e                   	pop    %esi
8010907b:	5f                   	pop    %edi
8010907c:	5d                   	pop    %ebp
8010907d:	c3                   	ret    

8010907e <i8254_init_send>:

void i8254_init_send(){
8010907e:	f3 0f 1e fb          	endbr32 
80109082:	55                   	push   %ebp
80109083:	89 e5                	mov    %esp,%ebp
80109085:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80109088:	a1 c4 88 19 80       	mov    0x801988c4,%eax
8010908d:	05 28 38 00 00       	add    $0x3828,%eax
80109092:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80109095:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109098:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
8010909e:	e8 ef 97 ff ff       	call   80102892 <kalloc>
801090a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801090a6:	a1 c4 88 19 80       	mov    0x801988c4,%eax
801090ab:	05 00 38 00 00       	add    $0x3800,%eax
801090b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801090b3:	a1 c4 88 19 80       	mov    0x801988c4,%eax
801090b8:	05 04 38 00 00       	add    $0x3804,%eax
801090bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801090c0:	a1 c4 88 19 80       	mov    0x801988c4,%eax
801090c5:	05 08 38 00 00       	add    $0x3808,%eax
801090ca:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801090cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090d0:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801090d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801090d9:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
801090db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
801090e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801090e7:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
801090ed:	a1 c4 88 19 80       	mov    0x801988c4,%eax
801090f2:	05 10 38 00 00       	add    $0x3810,%eax
801090f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801090fa:	a1 c4 88 19 80       	mov    0x801988c4,%eax
801090ff:	05 18 38 00 00       	add    $0x3818,%eax
80109104:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109107:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010910a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109110:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109113:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109119:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010911c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010911f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109126:	e9 82 00 00 00       	jmp    801091ad <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
8010912b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010912e:	c1 e0 04             	shl    $0x4,%eax
80109131:	89 c2                	mov    %eax,%edx
80109133:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109136:	01 d0                	add    %edx,%eax
80109138:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010913f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109142:	c1 e0 04             	shl    $0x4,%eax
80109145:	89 c2                	mov    %eax,%edx
80109147:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010914a:	01 d0                	add    %edx,%eax
8010914c:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109155:	c1 e0 04             	shl    $0x4,%eax
80109158:	89 c2                	mov    %eax,%edx
8010915a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010915d:	01 d0                	add    %edx,%eax
8010915f:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80109163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109166:	c1 e0 04             	shl    $0x4,%eax
80109169:	89 c2                	mov    %eax,%edx
8010916b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010916e:	01 d0                	add    %edx,%eax
80109170:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80109174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109177:	c1 e0 04             	shl    $0x4,%eax
8010917a:	89 c2                	mov    %eax,%edx
8010917c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010917f:	01 d0                	add    %edx,%eax
80109181:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80109185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109188:	c1 e0 04             	shl    $0x4,%eax
8010918b:	89 c2                	mov    %eax,%edx
8010918d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109190:	01 d0                	add    %edx,%eax
80109192:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109199:	c1 e0 04             	shl    $0x4,%eax
8010919c:	89 c2                	mov    %eax,%edx
8010919e:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091a1:	01 d0                	add    %edx,%eax
801091a3:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801091a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091ad:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801091b4:	0f 8e 71 ff ff ff    	jle    8010912b <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801091ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801091c1:	eb 57                	jmp    8010921a <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
801091c3:	e8 ca 96 ff ff       	call   80102892 <kalloc>
801091c8:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801091cb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801091cf:	75 12                	jne    801091e3 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
801091d1:	83 ec 0c             	sub    $0xc,%esp
801091d4:	68 98 c7 10 80       	push   $0x8010c798
801091d9:	e8 2e 72 ff ff       	call   8010040c <cprintf>
801091de:	83 c4 10             	add    $0x10,%esp
      break;
801091e1:	eb 3d                	jmp    80109220 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
801091e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e6:	c1 e0 04             	shl    $0x4,%eax
801091e9:	89 c2                	mov    %eax,%edx
801091eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091ee:	01 d0                	add    %edx,%eax
801091f0:	8b 55 cc             	mov    -0x34(%ebp),%edx
801091f3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801091f9:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801091fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091fe:	83 c0 01             	add    $0x1,%eax
80109201:	c1 e0 04             	shl    $0x4,%eax
80109204:	89 c2                	mov    %eax,%edx
80109206:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109209:	01 d0                	add    %edx,%eax
8010920b:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010920e:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109214:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109216:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010921a:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010921e:	7e a3                	jle    801091c3 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109220:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80109225:	05 00 04 00 00       	add    $0x400,%eax
8010922a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010922d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109230:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109236:	a1 c4 88 19 80       	mov    0x801988c4,%eax
8010923b:	05 10 04 00 00       	add    $0x410,%eax
80109240:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109243:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109246:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
8010924c:	83 ec 0c             	sub    $0xc,%esp
8010924f:	68 d8 c7 10 80       	push   $0x8010c7d8
80109254:	e8 b3 71 ff ff       	call   8010040c <cprintf>
80109259:	83 c4 10             	add    $0x10,%esp

}
8010925c:	90                   	nop
8010925d:	c9                   	leave  
8010925e:	c3                   	ret    

8010925f <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
8010925f:	f3 0f 1e fb          	endbr32 
80109263:	55                   	push   %ebp
80109264:	89 e5                	mov    %esp,%ebp
80109266:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109269:	a1 c4 88 19 80       	mov    0x801988c4,%eax
8010926e:	83 c0 14             	add    $0x14,%eax
80109271:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80109274:	8b 45 08             	mov    0x8(%ebp),%eax
80109277:	c1 e0 08             	shl    $0x8,%eax
8010927a:	0f b7 c0             	movzwl %ax,%eax
8010927d:	83 c8 01             	or     $0x1,%eax
80109280:	89 c2                	mov    %eax,%edx
80109282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109285:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80109287:	83 ec 0c             	sub    $0xc,%esp
8010928a:	68 f8 c7 10 80       	push   $0x8010c7f8
8010928f:	e8 78 71 ff ff       	call   8010040c <cprintf>
80109294:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80109297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010929a:	8b 00                	mov    (%eax),%eax
8010929c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
8010929f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a2:	83 e0 10             	and    $0x10,%eax
801092a5:	85 c0                	test   %eax,%eax
801092a7:	75 02                	jne    801092ab <i8254_read_eeprom+0x4c>
  while(1){
801092a9:	eb dc                	jmp    80109287 <i8254_read_eeprom+0x28>
      break;
801092ab:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801092ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092af:	8b 00                	mov    (%eax),%eax
801092b1:	c1 e8 10             	shr    $0x10,%eax
}
801092b4:	c9                   	leave  
801092b5:	c3                   	ret    

801092b6 <i8254_recv>:
void i8254_recv(){
801092b6:	f3 0f 1e fb          	endbr32 
801092ba:	55                   	push   %ebp
801092bb:	89 e5                	mov    %esp,%ebp
801092bd:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801092c0:	a1 c4 88 19 80       	mov    0x801988c4,%eax
801092c5:	05 10 28 00 00       	add    $0x2810,%eax
801092ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801092cd:	a1 c4 88 19 80       	mov    0x801988c4,%eax
801092d2:	05 18 28 00 00       	add    $0x2818,%eax
801092d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801092da:	a1 c4 88 19 80       	mov    0x801988c4,%eax
801092df:	05 00 28 00 00       	add    $0x2800,%eax
801092e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801092e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092ea:	8b 00                	mov    (%eax),%eax
801092ec:	05 00 00 00 80       	add    $0x80000000,%eax
801092f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801092f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f7:	8b 10                	mov    (%eax),%edx
801092f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092fc:	8b 00                	mov    (%eax),%eax
801092fe:	29 c2                	sub    %eax,%edx
80109300:	89 d0                	mov    %edx,%eax
80109302:	25 ff 00 00 00       	and    $0xff,%eax
80109307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
8010930a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010930e:	7e 37                	jle    80109347 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109313:	8b 00                	mov    (%eax),%eax
80109315:	c1 e0 04             	shl    $0x4,%eax
80109318:	89 c2                	mov    %eax,%edx
8010931a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010931d:	01 d0                	add    %edx,%eax
8010931f:	8b 00                	mov    (%eax),%eax
80109321:	05 00 00 00 80       	add    $0x80000000,%eax
80109326:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109329:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010932c:	8b 00                	mov    (%eax),%eax
8010932e:	83 c0 01             	add    $0x1,%eax
80109331:	0f b6 d0             	movzbl %al,%edx
80109334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109337:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109339:	83 ec 0c             	sub    $0xc,%esp
8010933c:	ff 75 e0             	pushl  -0x20(%ebp)
8010933f:	e8 47 09 00 00       	call   80109c8b <eth_proc>
80109344:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109347:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010934a:	8b 10                	mov    (%eax),%edx
8010934c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010934f:	8b 00                	mov    (%eax),%eax
80109351:	39 c2                	cmp    %eax,%edx
80109353:	75 9f                	jne    801092f4 <i8254_recv+0x3e>
      (*rdt)--;
80109355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109358:	8b 00                	mov    (%eax),%eax
8010935a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010935d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109360:	89 10                	mov    %edx,(%eax)
  while(1){
80109362:	eb 90                	jmp    801092f4 <i8254_recv+0x3e>

80109364 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109364:	f3 0f 1e fb          	endbr32 
80109368:	55                   	push   %ebp
80109369:	89 e5                	mov    %esp,%ebp
8010936b:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
8010936e:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80109373:	05 10 38 00 00       	add    $0x3810,%eax
80109378:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010937b:	a1 c4 88 19 80       	mov    0x801988c4,%eax
80109380:	05 18 38 00 00       	add    $0x3818,%eax
80109385:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109388:	a1 c4 88 19 80       	mov    0x801988c4,%eax
8010938d:	05 00 38 00 00       	add    $0x3800,%eax
80109392:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109395:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109398:	8b 00                	mov    (%eax),%eax
8010939a:	05 00 00 00 80       	add    $0x80000000,%eax
8010939f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801093a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093a5:	8b 10                	mov    (%eax),%edx
801093a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093aa:	8b 00                	mov    (%eax),%eax
801093ac:	29 c2                	sub    %eax,%edx
801093ae:	89 d0                	mov    %edx,%eax
801093b0:	0f b6 c0             	movzbl %al,%eax
801093b3:	ba 00 01 00 00       	mov    $0x100,%edx
801093b8:	29 c2                	sub    %eax,%edx
801093ba:	89 d0                	mov    %edx,%eax
801093bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801093bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c2:	8b 00                	mov    (%eax),%eax
801093c4:	25 ff 00 00 00       	and    $0xff,%eax
801093c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801093cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801093d0:	0f 8e a8 00 00 00    	jle    8010947e <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801093d6:	8b 45 08             	mov    0x8(%ebp),%eax
801093d9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801093dc:	89 d1                	mov    %edx,%ecx
801093de:	c1 e1 04             	shl    $0x4,%ecx
801093e1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801093e4:	01 ca                	add    %ecx,%edx
801093e6:	8b 12                	mov    (%edx),%edx
801093e8:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801093ee:	83 ec 04             	sub    $0x4,%esp
801093f1:	ff 75 0c             	pushl  0xc(%ebp)
801093f4:	50                   	push   %eax
801093f5:	52                   	push   %edx
801093f6:	e8 fd bc ff ff       	call   801050f8 <memmove>
801093fb:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801093fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109401:	c1 e0 04             	shl    $0x4,%eax
80109404:	89 c2                	mov    %eax,%edx
80109406:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109409:	01 d0                	add    %edx,%eax
8010940b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010940e:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109412:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109415:	c1 e0 04             	shl    $0x4,%eax
80109418:	89 c2                	mov    %eax,%edx
8010941a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010941d:	01 d0                	add    %edx,%eax
8010941f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109423:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109426:	c1 e0 04             	shl    $0x4,%eax
80109429:	89 c2                	mov    %eax,%edx
8010942b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010942e:	01 d0                	add    %edx,%eax
80109430:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109434:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109437:	c1 e0 04             	shl    $0x4,%eax
8010943a:	89 c2                	mov    %eax,%edx
8010943c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010943f:	01 d0                	add    %edx,%eax
80109441:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109445:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109448:	c1 e0 04             	shl    $0x4,%eax
8010944b:	89 c2                	mov    %eax,%edx
8010944d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109450:	01 d0                	add    %edx,%eax
80109452:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109458:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010945b:	c1 e0 04             	shl    $0x4,%eax
8010945e:	89 c2                	mov    %eax,%edx
80109460:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109463:	01 d0                	add    %edx,%eax
80109465:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109469:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010946c:	8b 00                	mov    (%eax),%eax
8010946e:	83 c0 01             	add    $0x1,%eax
80109471:	0f b6 d0             	movzbl %al,%edx
80109474:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109477:	89 10                	mov    %edx,(%eax)
    return len;
80109479:	8b 45 0c             	mov    0xc(%ebp),%eax
8010947c:	eb 05                	jmp    80109483 <i8254_send+0x11f>
  }else{
    return -1;
8010947e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109483:	c9                   	leave  
80109484:	c3                   	ret    

80109485 <i8254_intr>:

void i8254_intr(){
80109485:	f3 0f 1e fb          	endbr32 
80109489:	55                   	push   %ebp
8010948a:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
8010948c:	a1 c8 88 19 80       	mov    0x801988c8,%eax
80109491:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109497:	90                   	nop
80109498:	5d                   	pop    %ebp
80109499:	c3                   	ret    

8010949a <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
8010949a:	f3 0f 1e fb          	endbr32 
8010949e:	55                   	push   %ebp
8010949f:	89 e5                	mov    %esp,%ebp
801094a1:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801094a4:	8b 45 08             	mov    0x8(%ebp),%eax
801094a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801094aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ad:	0f b7 00             	movzwl (%eax),%eax
801094b0:	66 3d 00 01          	cmp    $0x100,%ax
801094b4:	74 0a                	je     801094c0 <arp_proc+0x26>
801094b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094bb:	e9 4f 01 00 00       	jmp    8010960f <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801094c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c3:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801094c7:	66 83 f8 08          	cmp    $0x8,%ax
801094cb:	74 0a                	je     801094d7 <arp_proc+0x3d>
801094cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094d2:	e9 38 01 00 00       	jmp    8010960f <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
801094d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094da:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801094de:	3c 06                	cmp    $0x6,%al
801094e0:	74 0a                	je     801094ec <arp_proc+0x52>
801094e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094e7:	e9 23 01 00 00       	jmp    8010960f <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
801094ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ef:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801094f3:	3c 04                	cmp    $0x4,%al
801094f5:	74 0a                	je     80109501 <arp_proc+0x67>
801094f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094fc:	e9 0e 01 00 00       	jmp    8010960f <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109504:	83 c0 18             	add    $0x18,%eax
80109507:	83 ec 04             	sub    $0x4,%esp
8010950a:	6a 04                	push   $0x4
8010950c:	50                   	push   %eax
8010950d:	68 04 f5 10 80       	push   $0x8010f504
80109512:	e8 85 bb ff ff       	call   8010509c <memcmp>
80109517:	83 c4 10             	add    $0x10,%esp
8010951a:	85 c0                	test   %eax,%eax
8010951c:	74 27                	je     80109545 <arp_proc+0xab>
8010951e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109521:	83 c0 0e             	add    $0xe,%eax
80109524:	83 ec 04             	sub    $0x4,%esp
80109527:	6a 04                	push   $0x4
80109529:	50                   	push   %eax
8010952a:	68 04 f5 10 80       	push   $0x8010f504
8010952f:	e8 68 bb ff ff       	call   8010509c <memcmp>
80109534:	83 c4 10             	add    $0x10,%esp
80109537:	85 c0                	test   %eax,%eax
80109539:	74 0a                	je     80109545 <arp_proc+0xab>
8010953b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109540:	e9 ca 00 00 00       	jmp    8010960f <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109548:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010954c:	66 3d 00 01          	cmp    $0x100,%ax
80109550:	75 69                	jne    801095bb <arp_proc+0x121>
80109552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109555:	83 c0 18             	add    $0x18,%eax
80109558:	83 ec 04             	sub    $0x4,%esp
8010955b:	6a 04                	push   $0x4
8010955d:	50                   	push   %eax
8010955e:	68 04 f5 10 80       	push   $0x8010f504
80109563:	e8 34 bb ff ff       	call   8010509c <memcmp>
80109568:	83 c4 10             	add    $0x10,%esp
8010956b:	85 c0                	test   %eax,%eax
8010956d:	75 4c                	jne    801095bb <arp_proc+0x121>
    uint send = (uint)kalloc();
8010956f:	e8 1e 93 ff ff       	call   80102892 <kalloc>
80109574:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109577:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
8010957e:	83 ec 04             	sub    $0x4,%esp
80109581:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109584:	50                   	push   %eax
80109585:	ff 75 f0             	pushl  -0x10(%ebp)
80109588:	ff 75 f4             	pushl  -0xc(%ebp)
8010958b:	e8 33 04 00 00       	call   801099c3 <arp_reply_pkt_create>
80109590:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109593:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109596:	83 ec 08             	sub    $0x8,%esp
80109599:	50                   	push   %eax
8010959a:	ff 75 f0             	pushl  -0x10(%ebp)
8010959d:	e8 c2 fd ff ff       	call   80109364 <i8254_send>
801095a2:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801095a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095a8:	83 ec 0c             	sub    $0xc,%esp
801095ab:	50                   	push   %eax
801095ac:	e8 43 92 ff ff       	call   801027f4 <kfree>
801095b1:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801095b4:	b8 02 00 00 00       	mov    $0x2,%eax
801095b9:	eb 54                	jmp    8010960f <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801095bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095be:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801095c2:	66 3d 00 02          	cmp    $0x200,%ax
801095c6:	75 42                	jne    8010960a <arp_proc+0x170>
801095c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095cb:	83 c0 18             	add    $0x18,%eax
801095ce:	83 ec 04             	sub    $0x4,%esp
801095d1:	6a 04                	push   $0x4
801095d3:	50                   	push   %eax
801095d4:	68 04 f5 10 80       	push   $0x8010f504
801095d9:	e8 be ba ff ff       	call   8010509c <memcmp>
801095de:	83 c4 10             	add    $0x10,%esp
801095e1:	85 c0                	test   %eax,%eax
801095e3:	75 25                	jne    8010960a <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
801095e5:	83 ec 0c             	sub    $0xc,%esp
801095e8:	68 fc c7 10 80       	push   $0x8010c7fc
801095ed:	e8 1a 6e ff ff       	call   8010040c <cprintf>
801095f2:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801095f5:	83 ec 0c             	sub    $0xc,%esp
801095f8:	ff 75 f4             	pushl  -0xc(%ebp)
801095fb:	e8 b7 01 00 00       	call   801097b7 <arp_table_update>
80109600:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109603:	b8 01 00 00 00       	mov    $0x1,%eax
80109608:	eb 05                	jmp    8010960f <arp_proc+0x175>
  }else{
    return -1;
8010960a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
8010960f:	c9                   	leave  
80109610:	c3                   	ret    

80109611 <arp_scan>:

void arp_scan(){
80109611:	f3 0f 1e fb          	endbr32 
80109615:	55                   	push   %ebp
80109616:	89 e5                	mov    %esp,%ebp
80109618:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010961b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109622:	eb 6f                	jmp    80109693 <arp_scan+0x82>
    uint send = (uint)kalloc();
80109624:	e8 69 92 ff ff       	call   80102892 <kalloc>
80109629:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010962c:	83 ec 04             	sub    $0x4,%esp
8010962f:	ff 75 f4             	pushl  -0xc(%ebp)
80109632:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109635:	50                   	push   %eax
80109636:	ff 75 ec             	pushl  -0x14(%ebp)
80109639:	e8 62 00 00 00       	call   801096a0 <arp_broadcast>
8010963e:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109641:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109644:	83 ec 08             	sub    $0x8,%esp
80109647:	50                   	push   %eax
80109648:	ff 75 ec             	pushl  -0x14(%ebp)
8010964b:	e8 14 fd ff ff       	call   80109364 <i8254_send>
80109650:	83 c4 10             	add    $0x10,%esp
80109653:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109656:	eb 22                	jmp    8010967a <arp_scan+0x69>
      microdelay(1);
80109658:	83 ec 0c             	sub    $0xc,%esp
8010965b:	6a 01                	push   $0x1
8010965d:	e8 e2 95 ff ff       	call   80102c44 <microdelay>
80109662:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109665:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109668:	83 ec 08             	sub    $0x8,%esp
8010966b:	50                   	push   %eax
8010966c:	ff 75 ec             	pushl  -0x14(%ebp)
8010966f:	e8 f0 fc ff ff       	call   80109364 <i8254_send>
80109674:	83 c4 10             	add    $0x10,%esp
80109677:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010967a:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010967e:	74 d8                	je     80109658 <arp_scan+0x47>
    }
    kfree((char *)send);
80109680:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109683:	83 ec 0c             	sub    $0xc,%esp
80109686:	50                   	push   %eax
80109687:	e8 68 91 ff ff       	call   801027f4 <kfree>
8010968c:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010968f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109693:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010969a:	7e 88                	jle    80109624 <arp_scan+0x13>
  }
}
8010969c:	90                   	nop
8010969d:	90                   	nop
8010969e:	c9                   	leave  
8010969f:	c3                   	ret    

801096a0 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801096a0:	f3 0f 1e fb          	endbr32 
801096a4:	55                   	push   %ebp
801096a5:	89 e5                	mov    %esp,%ebp
801096a7:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801096aa:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801096ae:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801096b2:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801096b6:	8b 45 10             	mov    0x10(%ebp),%eax
801096b9:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801096bc:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801096c3:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801096c9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801096d0:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801096d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801096d9:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801096df:	8b 45 08             	mov    0x8(%ebp),%eax
801096e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801096e5:	8b 45 08             	mov    0x8(%ebp),%eax
801096e8:	83 c0 0e             	add    $0xe,%eax
801096eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801096ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f1:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801096f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f8:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801096fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ff:	83 ec 04             	sub    $0x4,%esp
80109702:	6a 06                	push   $0x6
80109704:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109707:	52                   	push   %edx
80109708:	50                   	push   %eax
80109709:	e8 ea b9 ff ff       	call   801050f8 <memmove>
8010970e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109714:	83 c0 06             	add    $0x6,%eax
80109717:	83 ec 04             	sub    $0x4,%esp
8010971a:	6a 06                	push   $0x6
8010971c:	68 68 d0 18 80       	push   $0x8018d068
80109721:	50                   	push   %eax
80109722:	e8 d1 b9 ff ff       	call   801050f8 <memmove>
80109727:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010972a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010972d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109735:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010973b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010973e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109742:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109745:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109749:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010974c:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109752:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109755:	8d 50 12             	lea    0x12(%eax),%edx
80109758:	83 ec 04             	sub    $0x4,%esp
8010975b:	6a 06                	push   $0x6
8010975d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109760:	50                   	push   %eax
80109761:	52                   	push   %edx
80109762:	e8 91 b9 ff ff       	call   801050f8 <memmove>
80109767:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010976a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010976d:	8d 50 18             	lea    0x18(%eax),%edx
80109770:	83 ec 04             	sub    $0x4,%esp
80109773:	6a 04                	push   $0x4
80109775:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109778:	50                   	push   %eax
80109779:	52                   	push   %edx
8010977a:	e8 79 b9 ff ff       	call   801050f8 <memmove>
8010977f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109785:	83 c0 08             	add    $0x8,%eax
80109788:	83 ec 04             	sub    $0x4,%esp
8010978b:	6a 06                	push   $0x6
8010978d:	68 68 d0 18 80       	push   $0x8018d068
80109792:	50                   	push   %eax
80109793:	e8 60 b9 ff ff       	call   801050f8 <memmove>
80109798:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010979b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010979e:	83 c0 0e             	add    $0xe,%eax
801097a1:	83 ec 04             	sub    $0x4,%esp
801097a4:	6a 04                	push   $0x4
801097a6:	68 04 f5 10 80       	push   $0x8010f504
801097ab:	50                   	push   %eax
801097ac:	e8 47 b9 ff ff       	call   801050f8 <memmove>
801097b1:	83 c4 10             	add    $0x10,%esp
}
801097b4:	90                   	nop
801097b5:	c9                   	leave  
801097b6:	c3                   	ret    

801097b7 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801097b7:	f3 0f 1e fb          	endbr32 
801097bb:	55                   	push   %ebp
801097bc:	89 e5                	mov    %esp,%ebp
801097be:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801097c1:	8b 45 08             	mov    0x8(%ebp),%eax
801097c4:	83 c0 0e             	add    $0xe,%eax
801097c7:	83 ec 0c             	sub    $0xc,%esp
801097ca:	50                   	push   %eax
801097cb:	e8 bc 00 00 00       	call   8010988c <arp_table_search>
801097d0:	83 c4 10             	add    $0x10,%esp
801097d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801097d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801097da:	78 2d                	js     80109809 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801097dc:	8b 45 08             	mov    0x8(%ebp),%eax
801097df:	8d 48 08             	lea    0x8(%eax),%ecx
801097e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097e5:	89 d0                	mov    %edx,%eax
801097e7:	c1 e0 02             	shl    $0x2,%eax
801097ea:	01 d0                	add    %edx,%eax
801097ec:	01 c0                	add    %eax,%eax
801097ee:	01 d0                	add    %edx,%eax
801097f0:	05 80 d0 18 80       	add    $0x8018d080,%eax
801097f5:	83 c0 04             	add    $0x4,%eax
801097f8:	83 ec 04             	sub    $0x4,%esp
801097fb:	6a 06                	push   $0x6
801097fd:	51                   	push   %ecx
801097fe:	50                   	push   %eax
801097ff:	e8 f4 b8 ff ff       	call   801050f8 <memmove>
80109804:	83 c4 10             	add    $0x10,%esp
80109807:	eb 70                	jmp    80109879 <arp_table_update+0xc2>
  }else{
    index += 1;
80109809:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
8010980d:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109810:	8b 45 08             	mov    0x8(%ebp),%eax
80109813:	8d 48 08             	lea    0x8(%eax),%ecx
80109816:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109819:	89 d0                	mov    %edx,%eax
8010981b:	c1 e0 02             	shl    $0x2,%eax
8010981e:	01 d0                	add    %edx,%eax
80109820:	01 c0                	add    %eax,%eax
80109822:	01 d0                	add    %edx,%eax
80109824:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109829:	83 c0 04             	add    $0x4,%eax
8010982c:	83 ec 04             	sub    $0x4,%esp
8010982f:	6a 06                	push   $0x6
80109831:	51                   	push   %ecx
80109832:	50                   	push   %eax
80109833:	e8 c0 b8 ff ff       	call   801050f8 <memmove>
80109838:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
8010983b:	8b 45 08             	mov    0x8(%ebp),%eax
8010983e:	8d 48 0e             	lea    0xe(%eax),%ecx
80109841:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109844:	89 d0                	mov    %edx,%eax
80109846:	c1 e0 02             	shl    $0x2,%eax
80109849:	01 d0                	add    %edx,%eax
8010984b:	01 c0                	add    %eax,%eax
8010984d:	01 d0                	add    %edx,%eax
8010984f:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109854:	83 ec 04             	sub    $0x4,%esp
80109857:	6a 04                	push   $0x4
80109859:	51                   	push   %ecx
8010985a:	50                   	push   %eax
8010985b:	e8 98 b8 ff ff       	call   801050f8 <memmove>
80109860:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109863:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109866:	89 d0                	mov    %edx,%eax
80109868:	c1 e0 02             	shl    $0x2,%eax
8010986b:	01 d0                	add    %edx,%eax
8010986d:	01 c0                	add    %eax,%eax
8010986f:	01 d0                	add    %edx,%eax
80109871:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109876:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109879:	83 ec 0c             	sub    $0xc,%esp
8010987c:	68 80 d0 18 80       	push   $0x8018d080
80109881:	e8 87 00 00 00       	call   8010990d <print_arp_table>
80109886:	83 c4 10             	add    $0x10,%esp
}
80109889:	90                   	nop
8010988a:	c9                   	leave  
8010988b:	c3                   	ret    

8010988c <arp_table_search>:

int arp_table_search(uchar *ip){
8010988c:	f3 0f 1e fb          	endbr32 
80109890:	55                   	push   %ebp
80109891:	89 e5                	mov    %esp,%ebp
80109893:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109896:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010989d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801098a4:	eb 59                	jmp    801098ff <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801098a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801098a9:	89 d0                	mov    %edx,%eax
801098ab:	c1 e0 02             	shl    $0x2,%eax
801098ae:	01 d0                	add    %edx,%eax
801098b0:	01 c0                	add    %eax,%eax
801098b2:	01 d0                	add    %edx,%eax
801098b4:	05 80 d0 18 80       	add    $0x8018d080,%eax
801098b9:	83 ec 04             	sub    $0x4,%esp
801098bc:	6a 04                	push   $0x4
801098be:	ff 75 08             	pushl  0x8(%ebp)
801098c1:	50                   	push   %eax
801098c2:	e8 d5 b7 ff ff       	call   8010509c <memcmp>
801098c7:	83 c4 10             	add    $0x10,%esp
801098ca:	85 c0                	test   %eax,%eax
801098cc:	75 05                	jne    801098d3 <arp_table_search+0x47>
      return i;
801098ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d1:	eb 38                	jmp    8010990b <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
801098d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801098d6:	89 d0                	mov    %edx,%eax
801098d8:	c1 e0 02             	shl    $0x2,%eax
801098db:	01 d0                	add    %edx,%eax
801098dd:	01 c0                	add    %eax,%eax
801098df:	01 d0                	add    %edx,%eax
801098e1:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801098e6:	0f b6 00             	movzbl (%eax),%eax
801098e9:	84 c0                	test   %al,%al
801098eb:	75 0e                	jne    801098fb <arp_table_search+0x6f>
801098ed:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801098f1:	75 08                	jne    801098fb <arp_table_search+0x6f>
      empty = -i;
801098f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098f6:	f7 d8                	neg    %eax
801098f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801098fb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801098ff:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109903:	7e a1                	jle    801098a6 <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109908:	83 e8 01             	sub    $0x1,%eax
}
8010990b:	c9                   	leave  
8010990c:	c3                   	ret    

8010990d <print_arp_table>:

void print_arp_table(){
8010990d:	f3 0f 1e fb          	endbr32 
80109911:	55                   	push   %ebp
80109912:	89 e5                	mov    %esp,%ebp
80109914:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109917:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010991e:	e9 92 00 00 00       	jmp    801099b5 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109923:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109926:	89 d0                	mov    %edx,%eax
80109928:	c1 e0 02             	shl    $0x2,%eax
8010992b:	01 d0                	add    %edx,%eax
8010992d:	01 c0                	add    %eax,%eax
8010992f:	01 d0                	add    %edx,%eax
80109931:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109936:	0f b6 00             	movzbl (%eax),%eax
80109939:	84 c0                	test   %al,%al
8010993b:	74 74                	je     801099b1 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
8010993d:	83 ec 08             	sub    $0x8,%esp
80109940:	ff 75 f4             	pushl  -0xc(%ebp)
80109943:	68 0f c8 10 80       	push   $0x8010c80f
80109948:	e8 bf 6a ff ff       	call   8010040c <cprintf>
8010994d:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109950:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109953:	89 d0                	mov    %edx,%eax
80109955:	c1 e0 02             	shl    $0x2,%eax
80109958:	01 d0                	add    %edx,%eax
8010995a:	01 c0                	add    %eax,%eax
8010995c:	01 d0                	add    %edx,%eax
8010995e:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109963:	83 ec 0c             	sub    $0xc,%esp
80109966:	50                   	push   %eax
80109967:	e8 5c 02 00 00       	call   80109bc8 <print_ipv4>
8010996c:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010996f:	83 ec 0c             	sub    $0xc,%esp
80109972:	68 1e c8 10 80       	push   $0x8010c81e
80109977:	e8 90 6a ff ff       	call   8010040c <cprintf>
8010997c:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010997f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109982:	89 d0                	mov    %edx,%eax
80109984:	c1 e0 02             	shl    $0x2,%eax
80109987:	01 d0                	add    %edx,%eax
80109989:	01 c0                	add    %eax,%eax
8010998b:	01 d0                	add    %edx,%eax
8010998d:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109992:	83 c0 04             	add    $0x4,%eax
80109995:	83 ec 0c             	sub    $0xc,%esp
80109998:	50                   	push   %eax
80109999:	e8 7c 02 00 00       	call   80109c1a <print_mac>
8010999e:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801099a1:	83 ec 0c             	sub    $0xc,%esp
801099a4:	68 20 c8 10 80       	push   $0x8010c820
801099a9:	e8 5e 6a ff ff       	call   8010040c <cprintf>
801099ae:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801099b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801099b5:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801099b9:	0f 8e 64 ff ff ff    	jle    80109923 <print_arp_table+0x16>
    }
  }
}
801099bf:	90                   	nop
801099c0:	90                   	nop
801099c1:	c9                   	leave  
801099c2:	c3                   	ret    

801099c3 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801099c3:	f3 0f 1e fb          	endbr32 
801099c7:	55                   	push   %ebp
801099c8:	89 e5                	mov    %esp,%ebp
801099ca:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801099cd:	8b 45 10             	mov    0x10(%ebp),%eax
801099d0:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801099d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801099d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801099dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801099df:	83 c0 0e             	add    $0xe,%eax
801099e2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801099e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099e8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801099ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ef:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801099f3:	8b 45 08             	mov    0x8(%ebp),%eax
801099f6:	8d 50 08             	lea    0x8(%eax),%edx
801099f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099fc:	83 ec 04             	sub    $0x4,%esp
801099ff:	6a 06                	push   $0x6
80109a01:	52                   	push   %edx
80109a02:	50                   	push   %eax
80109a03:	e8 f0 b6 ff ff       	call   801050f8 <memmove>
80109a08:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a0e:	83 c0 06             	add    $0x6,%eax
80109a11:	83 ec 04             	sub    $0x4,%esp
80109a14:	6a 06                	push   $0x6
80109a16:	68 68 d0 18 80       	push   $0x8018d068
80109a1b:	50                   	push   %eax
80109a1c:	e8 d7 b6 ff ff       	call   801050f8 <memmove>
80109a21:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a27:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a2f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a38:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a3f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a46:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a4f:	8d 50 08             	lea    0x8(%eax),%edx
80109a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a55:	83 c0 12             	add    $0x12,%eax
80109a58:	83 ec 04             	sub    $0x4,%esp
80109a5b:	6a 06                	push   $0x6
80109a5d:	52                   	push   %edx
80109a5e:	50                   	push   %eax
80109a5f:	e8 94 b6 ff ff       	call   801050f8 <memmove>
80109a64:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109a67:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6a:	8d 50 0e             	lea    0xe(%eax),%edx
80109a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a70:	83 c0 18             	add    $0x18,%eax
80109a73:	83 ec 04             	sub    $0x4,%esp
80109a76:	6a 04                	push   $0x4
80109a78:	52                   	push   %edx
80109a79:	50                   	push   %eax
80109a7a:	e8 79 b6 ff ff       	call   801050f8 <memmove>
80109a7f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a85:	83 c0 08             	add    $0x8,%eax
80109a88:	83 ec 04             	sub    $0x4,%esp
80109a8b:	6a 06                	push   $0x6
80109a8d:	68 68 d0 18 80       	push   $0x8018d068
80109a92:	50                   	push   %eax
80109a93:	e8 60 b6 ff ff       	call   801050f8 <memmove>
80109a98:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a9e:	83 c0 0e             	add    $0xe,%eax
80109aa1:	83 ec 04             	sub    $0x4,%esp
80109aa4:	6a 04                	push   $0x4
80109aa6:	68 04 f5 10 80       	push   $0x8010f504
80109aab:	50                   	push   %eax
80109aac:	e8 47 b6 ff ff       	call   801050f8 <memmove>
80109ab1:	83 c4 10             	add    $0x10,%esp
}
80109ab4:	90                   	nop
80109ab5:	c9                   	leave  
80109ab6:	c3                   	ret    

80109ab7 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109ab7:	f3 0f 1e fb          	endbr32 
80109abb:	55                   	push   %ebp
80109abc:	89 e5                	mov    %esp,%ebp
80109abe:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109ac1:	83 ec 0c             	sub    $0xc,%esp
80109ac4:	68 22 c8 10 80       	push   $0x8010c822
80109ac9:	e8 3e 69 ff ff       	call   8010040c <cprintf>
80109ace:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad4:	83 c0 0e             	add    $0xe,%eax
80109ad7:	83 ec 0c             	sub    $0xc,%esp
80109ada:	50                   	push   %eax
80109adb:	e8 e8 00 00 00       	call   80109bc8 <print_ipv4>
80109ae0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109ae3:	83 ec 0c             	sub    $0xc,%esp
80109ae6:	68 20 c8 10 80       	push   $0x8010c820
80109aeb:	e8 1c 69 ff ff       	call   8010040c <cprintf>
80109af0:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109af3:	8b 45 08             	mov    0x8(%ebp),%eax
80109af6:	83 c0 08             	add    $0x8,%eax
80109af9:	83 ec 0c             	sub    $0xc,%esp
80109afc:	50                   	push   %eax
80109afd:	e8 18 01 00 00       	call   80109c1a <print_mac>
80109b02:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b05:	83 ec 0c             	sub    $0xc,%esp
80109b08:	68 20 c8 10 80       	push   $0x8010c820
80109b0d:	e8 fa 68 ff ff       	call   8010040c <cprintf>
80109b12:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109b15:	83 ec 0c             	sub    $0xc,%esp
80109b18:	68 39 c8 10 80       	push   $0x8010c839
80109b1d:	e8 ea 68 ff ff       	call   8010040c <cprintf>
80109b22:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109b25:	8b 45 08             	mov    0x8(%ebp),%eax
80109b28:	83 c0 18             	add    $0x18,%eax
80109b2b:	83 ec 0c             	sub    $0xc,%esp
80109b2e:	50                   	push   %eax
80109b2f:	e8 94 00 00 00       	call   80109bc8 <print_ipv4>
80109b34:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b37:	83 ec 0c             	sub    $0xc,%esp
80109b3a:	68 20 c8 10 80       	push   $0x8010c820
80109b3f:	e8 c8 68 ff ff       	call   8010040c <cprintf>
80109b44:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109b47:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4a:	83 c0 12             	add    $0x12,%eax
80109b4d:	83 ec 0c             	sub    $0xc,%esp
80109b50:	50                   	push   %eax
80109b51:	e8 c4 00 00 00       	call   80109c1a <print_mac>
80109b56:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b59:	83 ec 0c             	sub    $0xc,%esp
80109b5c:	68 20 c8 10 80       	push   $0x8010c820
80109b61:	e8 a6 68 ff ff       	call   8010040c <cprintf>
80109b66:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109b69:	83 ec 0c             	sub    $0xc,%esp
80109b6c:	68 50 c8 10 80       	push   $0x8010c850
80109b71:	e8 96 68 ff ff       	call   8010040c <cprintf>
80109b76:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109b79:	8b 45 08             	mov    0x8(%ebp),%eax
80109b7c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b80:	66 3d 00 01          	cmp    $0x100,%ax
80109b84:	75 12                	jne    80109b98 <print_arp_info+0xe1>
80109b86:	83 ec 0c             	sub    $0xc,%esp
80109b89:	68 5c c8 10 80       	push   $0x8010c85c
80109b8e:	e8 79 68 ff ff       	call   8010040c <cprintf>
80109b93:	83 c4 10             	add    $0x10,%esp
80109b96:	eb 1d                	jmp    80109bb5 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109b98:	8b 45 08             	mov    0x8(%ebp),%eax
80109b9b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b9f:	66 3d 00 02          	cmp    $0x200,%ax
80109ba3:	75 10                	jne    80109bb5 <print_arp_info+0xfe>
    cprintf("Reply\n");
80109ba5:	83 ec 0c             	sub    $0xc,%esp
80109ba8:	68 65 c8 10 80       	push   $0x8010c865
80109bad:	e8 5a 68 ff ff       	call   8010040c <cprintf>
80109bb2:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109bb5:	83 ec 0c             	sub    $0xc,%esp
80109bb8:	68 20 c8 10 80       	push   $0x8010c820
80109bbd:	e8 4a 68 ff ff       	call   8010040c <cprintf>
80109bc2:	83 c4 10             	add    $0x10,%esp
}
80109bc5:	90                   	nop
80109bc6:	c9                   	leave  
80109bc7:	c3                   	ret    

80109bc8 <print_ipv4>:

void print_ipv4(uchar *ip){
80109bc8:	f3 0f 1e fb          	endbr32 
80109bcc:	55                   	push   %ebp
80109bcd:	89 e5                	mov    %esp,%ebp
80109bcf:	53                   	push   %ebx
80109bd0:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd6:	83 c0 03             	add    $0x3,%eax
80109bd9:	0f b6 00             	movzbl (%eax),%eax
80109bdc:	0f b6 d8             	movzbl %al,%ebx
80109bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80109be2:	83 c0 02             	add    $0x2,%eax
80109be5:	0f b6 00             	movzbl (%eax),%eax
80109be8:	0f b6 c8             	movzbl %al,%ecx
80109beb:	8b 45 08             	mov    0x8(%ebp),%eax
80109bee:	83 c0 01             	add    $0x1,%eax
80109bf1:	0f b6 00             	movzbl (%eax),%eax
80109bf4:	0f b6 d0             	movzbl %al,%edx
80109bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80109bfa:	0f b6 00             	movzbl (%eax),%eax
80109bfd:	0f b6 c0             	movzbl %al,%eax
80109c00:	83 ec 0c             	sub    $0xc,%esp
80109c03:	53                   	push   %ebx
80109c04:	51                   	push   %ecx
80109c05:	52                   	push   %edx
80109c06:	50                   	push   %eax
80109c07:	68 6c c8 10 80       	push   $0x8010c86c
80109c0c:	e8 fb 67 ff ff       	call   8010040c <cprintf>
80109c11:	83 c4 20             	add    $0x20,%esp
}
80109c14:	90                   	nop
80109c15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c18:	c9                   	leave  
80109c19:	c3                   	ret    

80109c1a <print_mac>:

void print_mac(uchar *mac){
80109c1a:	f3 0f 1e fb          	endbr32 
80109c1e:	55                   	push   %ebp
80109c1f:	89 e5                	mov    %esp,%ebp
80109c21:	57                   	push   %edi
80109c22:	56                   	push   %esi
80109c23:	53                   	push   %ebx
80109c24:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109c27:	8b 45 08             	mov    0x8(%ebp),%eax
80109c2a:	83 c0 05             	add    $0x5,%eax
80109c2d:	0f b6 00             	movzbl (%eax),%eax
80109c30:	0f b6 f8             	movzbl %al,%edi
80109c33:	8b 45 08             	mov    0x8(%ebp),%eax
80109c36:	83 c0 04             	add    $0x4,%eax
80109c39:	0f b6 00             	movzbl (%eax),%eax
80109c3c:	0f b6 f0             	movzbl %al,%esi
80109c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c42:	83 c0 03             	add    $0x3,%eax
80109c45:	0f b6 00             	movzbl (%eax),%eax
80109c48:	0f b6 d8             	movzbl %al,%ebx
80109c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c4e:	83 c0 02             	add    $0x2,%eax
80109c51:	0f b6 00             	movzbl (%eax),%eax
80109c54:	0f b6 c8             	movzbl %al,%ecx
80109c57:	8b 45 08             	mov    0x8(%ebp),%eax
80109c5a:	83 c0 01             	add    $0x1,%eax
80109c5d:	0f b6 00             	movzbl (%eax),%eax
80109c60:	0f b6 d0             	movzbl %al,%edx
80109c63:	8b 45 08             	mov    0x8(%ebp),%eax
80109c66:	0f b6 00             	movzbl (%eax),%eax
80109c69:	0f b6 c0             	movzbl %al,%eax
80109c6c:	83 ec 04             	sub    $0x4,%esp
80109c6f:	57                   	push   %edi
80109c70:	56                   	push   %esi
80109c71:	53                   	push   %ebx
80109c72:	51                   	push   %ecx
80109c73:	52                   	push   %edx
80109c74:	50                   	push   %eax
80109c75:	68 84 c8 10 80       	push   $0x8010c884
80109c7a:	e8 8d 67 ff ff       	call   8010040c <cprintf>
80109c7f:	83 c4 20             	add    $0x20,%esp
}
80109c82:	90                   	nop
80109c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109c86:	5b                   	pop    %ebx
80109c87:	5e                   	pop    %esi
80109c88:	5f                   	pop    %edi
80109c89:	5d                   	pop    %ebp
80109c8a:	c3                   	ret    

80109c8b <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109c8b:	f3 0f 1e fb          	endbr32 
80109c8f:	55                   	push   %ebp
80109c90:	89 e5                	mov    %esp,%ebp
80109c92:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109c95:	8b 45 08             	mov    0x8(%ebp),%eax
80109c98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c9e:	83 c0 0e             	add    $0xe,%eax
80109ca1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ca7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109cab:	3c 08                	cmp    $0x8,%al
80109cad:	75 1b                	jne    80109cca <eth_proc+0x3f>
80109caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cb2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109cb6:	3c 06                	cmp    $0x6,%al
80109cb8:	75 10                	jne    80109cca <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109cba:	83 ec 0c             	sub    $0xc,%esp
80109cbd:	ff 75 f0             	pushl  -0x10(%ebp)
80109cc0:	e8 d5 f7 ff ff       	call   8010949a <arp_proc>
80109cc5:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109cc8:	eb 24                	jmp    80109cee <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ccd:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109cd1:	3c 08                	cmp    $0x8,%al
80109cd3:	75 19                	jne    80109cee <eth_proc+0x63>
80109cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cd8:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109cdc:	84 c0                	test   %al,%al
80109cde:	75 0e                	jne    80109cee <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109ce0:	83 ec 0c             	sub    $0xc,%esp
80109ce3:	ff 75 08             	pushl  0x8(%ebp)
80109ce6:	e8 b3 00 00 00       	call   80109d9e <ipv4_proc>
80109ceb:	83 c4 10             	add    $0x10,%esp
}
80109cee:	90                   	nop
80109cef:	c9                   	leave  
80109cf0:	c3                   	ret    

80109cf1 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109cf1:	f3 0f 1e fb          	endbr32 
80109cf5:	55                   	push   %ebp
80109cf6:	89 e5                	mov    %esp,%ebp
80109cf8:	83 ec 04             	sub    $0x4,%esp
80109cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80109cfe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d02:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d06:	c1 e0 08             	shl    $0x8,%eax
80109d09:	89 c2                	mov    %eax,%edx
80109d0b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d0f:	66 c1 e8 08          	shr    $0x8,%ax
80109d13:	01 d0                	add    %edx,%eax
}
80109d15:	c9                   	leave  
80109d16:	c3                   	ret    

80109d17 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109d17:	f3 0f 1e fb          	endbr32 
80109d1b:	55                   	push   %ebp
80109d1c:	89 e5                	mov    %esp,%ebp
80109d1e:	83 ec 04             	sub    $0x4,%esp
80109d21:	8b 45 08             	mov    0x8(%ebp),%eax
80109d24:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d28:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d2c:	c1 e0 08             	shl    $0x8,%eax
80109d2f:	89 c2                	mov    %eax,%edx
80109d31:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d35:	66 c1 e8 08          	shr    $0x8,%ax
80109d39:	01 d0                	add    %edx,%eax
}
80109d3b:	c9                   	leave  
80109d3c:	c3                   	ret    

80109d3d <H2N_uint>:

uint H2N_uint(uint value){
80109d3d:	f3 0f 1e fb          	endbr32 
80109d41:	55                   	push   %ebp
80109d42:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109d44:	8b 45 08             	mov    0x8(%ebp),%eax
80109d47:	c1 e0 18             	shl    $0x18,%eax
80109d4a:	25 00 00 00 0f       	and    $0xf000000,%eax
80109d4f:	89 c2                	mov    %eax,%edx
80109d51:	8b 45 08             	mov    0x8(%ebp),%eax
80109d54:	c1 e0 08             	shl    $0x8,%eax
80109d57:	25 00 f0 00 00       	and    $0xf000,%eax
80109d5c:	09 c2                	or     %eax,%edx
80109d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109d61:	c1 e8 08             	shr    $0x8,%eax
80109d64:	83 e0 0f             	and    $0xf,%eax
80109d67:	01 d0                	add    %edx,%eax
}
80109d69:	5d                   	pop    %ebp
80109d6a:	c3                   	ret    

80109d6b <N2H_uint>:

uint N2H_uint(uint value){
80109d6b:	f3 0f 1e fb          	endbr32 
80109d6f:	55                   	push   %ebp
80109d70:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109d72:	8b 45 08             	mov    0x8(%ebp),%eax
80109d75:	c1 e0 18             	shl    $0x18,%eax
80109d78:	89 c2                	mov    %eax,%edx
80109d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80109d7d:	c1 e0 08             	shl    $0x8,%eax
80109d80:	25 00 00 ff 00       	and    $0xff0000,%eax
80109d85:	01 c2                	add    %eax,%edx
80109d87:	8b 45 08             	mov    0x8(%ebp),%eax
80109d8a:	c1 e8 08             	shr    $0x8,%eax
80109d8d:	25 00 ff 00 00       	and    $0xff00,%eax
80109d92:	01 c2                	add    %eax,%edx
80109d94:	8b 45 08             	mov    0x8(%ebp),%eax
80109d97:	c1 e8 18             	shr    $0x18,%eax
80109d9a:	01 d0                	add    %edx,%eax
}
80109d9c:	5d                   	pop    %ebp
80109d9d:	c3                   	ret    

80109d9e <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109d9e:	f3 0f 1e fb          	endbr32 
80109da2:	55                   	push   %ebp
80109da3:	89 e5                	mov    %esp,%ebp
80109da5:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109da8:	8b 45 08             	mov    0x8(%ebp),%eax
80109dab:	83 c0 0e             	add    $0xe,%eax
80109dae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109db4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109db8:	0f b7 d0             	movzwl %ax,%edx
80109dbb:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109dc0:	39 c2                	cmp    %eax,%edx
80109dc2:	74 60                	je     80109e24 <ipv4_proc+0x86>
80109dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dc7:	83 c0 0c             	add    $0xc,%eax
80109dca:	83 ec 04             	sub    $0x4,%esp
80109dcd:	6a 04                	push   $0x4
80109dcf:	50                   	push   %eax
80109dd0:	68 04 f5 10 80       	push   $0x8010f504
80109dd5:	e8 c2 b2 ff ff       	call   8010509c <memcmp>
80109dda:	83 c4 10             	add    $0x10,%esp
80109ddd:	85 c0                	test   %eax,%eax
80109ddf:	74 43                	je     80109e24 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109de4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109de8:	0f b7 c0             	movzwl %ax,%eax
80109deb:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109df3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109df7:	3c 01                	cmp    $0x1,%al
80109df9:	75 10                	jne    80109e0b <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109dfb:	83 ec 0c             	sub    $0xc,%esp
80109dfe:	ff 75 08             	pushl  0x8(%ebp)
80109e01:	e8 a7 00 00 00       	call   80109ead <icmp_proc>
80109e06:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109e09:	eb 19                	jmp    80109e24 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0e:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109e12:	3c 06                	cmp    $0x6,%al
80109e14:	75 0e                	jne    80109e24 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109e16:	83 ec 0c             	sub    $0xc,%esp
80109e19:	ff 75 08             	pushl  0x8(%ebp)
80109e1c:	e8 c7 03 00 00       	call   8010a1e8 <tcp_proc>
80109e21:	83 c4 10             	add    $0x10,%esp
}
80109e24:	90                   	nop
80109e25:	c9                   	leave  
80109e26:	c3                   	ret    

80109e27 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109e27:	f3 0f 1e fb          	endbr32 
80109e2b:	55                   	push   %ebp
80109e2c:	89 e5                	mov    %esp,%ebp
80109e2e:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109e31:	8b 45 08             	mov    0x8(%ebp),%eax
80109e34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e3a:	0f b6 00             	movzbl (%eax),%eax
80109e3d:	83 e0 0f             	and    $0xf,%eax
80109e40:	01 c0                	add    %eax,%eax
80109e42:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109e45:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109e4c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e53:	eb 48                	jmp    80109e9d <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e58:	01 c0                	add    %eax,%eax
80109e5a:	89 c2                	mov    %eax,%edx
80109e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e5f:	01 d0                	add    %edx,%eax
80109e61:	0f b6 00             	movzbl (%eax),%eax
80109e64:	0f b6 c0             	movzbl %al,%eax
80109e67:	c1 e0 08             	shl    $0x8,%eax
80109e6a:	89 c2                	mov    %eax,%edx
80109e6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e6f:	01 c0                	add    %eax,%eax
80109e71:	8d 48 01             	lea    0x1(%eax),%ecx
80109e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e77:	01 c8                	add    %ecx,%eax
80109e79:	0f b6 00             	movzbl (%eax),%eax
80109e7c:	0f b6 c0             	movzbl %al,%eax
80109e7f:	01 d0                	add    %edx,%eax
80109e81:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109e84:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109e8b:	76 0c                	jbe    80109e99 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109e8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e90:	0f b7 c0             	movzwl %ax,%eax
80109e93:	83 c0 01             	add    $0x1,%eax
80109e96:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109e99:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109e9d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109ea1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109ea4:	7c af                	jl     80109e55 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ea9:	f7 d0                	not    %eax
}
80109eab:	c9                   	leave  
80109eac:	c3                   	ret    

80109ead <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109ead:	f3 0f 1e fb          	endbr32 
80109eb1:	55                   	push   %ebp
80109eb2:	89 e5                	mov    %esp,%ebp
80109eb4:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80109eba:	83 c0 0e             	add    $0xe,%eax
80109ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ec3:	0f b6 00             	movzbl (%eax),%eax
80109ec6:	0f b6 c0             	movzbl %al,%eax
80109ec9:	83 e0 0f             	and    $0xf,%eax
80109ecc:	c1 e0 02             	shl    $0x2,%eax
80109ecf:	89 c2                	mov    %eax,%edx
80109ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ed4:	01 d0                	add    %edx,%eax
80109ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109edc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109ee0:	84 c0                	test   %al,%al
80109ee2:	75 4f                	jne    80109f33 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ee7:	0f b6 00             	movzbl (%eax),%eax
80109eea:	3c 08                	cmp    $0x8,%al
80109eec:	75 45                	jne    80109f33 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109eee:	e8 9f 89 ff ff       	call   80102892 <kalloc>
80109ef3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109ef6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109efd:	83 ec 04             	sub    $0x4,%esp
80109f00:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109f03:	50                   	push   %eax
80109f04:	ff 75 ec             	pushl  -0x14(%ebp)
80109f07:	ff 75 08             	pushl  0x8(%ebp)
80109f0a:	e8 7c 00 00 00       	call   80109f8b <icmp_reply_pkt_create>
80109f0f:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109f12:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f15:	83 ec 08             	sub    $0x8,%esp
80109f18:	50                   	push   %eax
80109f19:	ff 75 ec             	pushl  -0x14(%ebp)
80109f1c:	e8 43 f4 ff ff       	call   80109364 <i8254_send>
80109f21:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109f24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f27:	83 ec 0c             	sub    $0xc,%esp
80109f2a:	50                   	push   %eax
80109f2b:	e8 c4 88 ff ff       	call   801027f4 <kfree>
80109f30:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109f33:	90                   	nop
80109f34:	c9                   	leave  
80109f35:	c3                   	ret    

80109f36 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109f36:	f3 0f 1e fb          	endbr32 
80109f3a:	55                   	push   %ebp
80109f3b:	89 e5                	mov    %esp,%ebp
80109f3d:	53                   	push   %ebx
80109f3e:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109f41:	8b 45 08             	mov    0x8(%ebp),%eax
80109f44:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109f48:	0f b7 c0             	movzwl %ax,%eax
80109f4b:	83 ec 0c             	sub    $0xc,%esp
80109f4e:	50                   	push   %eax
80109f4f:	e8 9d fd ff ff       	call   80109cf1 <N2H_ushort>
80109f54:	83 c4 10             	add    $0x10,%esp
80109f57:	0f b7 d8             	movzwl %ax,%ebx
80109f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80109f5d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109f61:	0f b7 c0             	movzwl %ax,%eax
80109f64:	83 ec 0c             	sub    $0xc,%esp
80109f67:	50                   	push   %eax
80109f68:	e8 84 fd ff ff       	call   80109cf1 <N2H_ushort>
80109f6d:	83 c4 10             	add    $0x10,%esp
80109f70:	0f b7 c0             	movzwl %ax,%eax
80109f73:	83 ec 04             	sub    $0x4,%esp
80109f76:	53                   	push   %ebx
80109f77:	50                   	push   %eax
80109f78:	68 a3 c8 10 80       	push   $0x8010c8a3
80109f7d:	e8 8a 64 ff ff       	call   8010040c <cprintf>
80109f82:	83 c4 10             	add    $0x10,%esp
}
80109f85:	90                   	nop
80109f86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109f89:	c9                   	leave  
80109f8a:	c3                   	ret    

80109f8b <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109f8b:	f3 0f 1e fb          	endbr32 
80109f8f:	55                   	push   %ebp
80109f90:	89 e5                	mov    %esp,%ebp
80109f92:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109f95:	8b 45 08             	mov    0x8(%ebp),%eax
80109f98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f9e:	83 c0 0e             	add    $0xe,%eax
80109fa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fa7:	0f b6 00             	movzbl (%eax),%eax
80109faa:	0f b6 c0             	movzbl %al,%eax
80109fad:	83 e0 0f             	and    $0xf,%eax
80109fb0:	c1 e0 02             	shl    $0x2,%eax
80109fb3:	89 c2                	mov    %eax,%edx
80109fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fb8:	01 d0                	add    %edx,%eax
80109fba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fc6:	83 c0 0e             	add    $0xe,%eax
80109fc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109fcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fcf:	83 c0 14             	add    $0x14,%eax
80109fd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109fd5:	8b 45 10             	mov    0x10(%ebp),%eax
80109fd8:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fe1:	8d 50 06             	lea    0x6(%eax),%edx
80109fe4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fe7:	83 ec 04             	sub    $0x4,%esp
80109fea:	6a 06                	push   $0x6
80109fec:	52                   	push   %edx
80109fed:	50                   	push   %eax
80109fee:	e8 05 b1 ff ff       	call   801050f8 <memmove>
80109ff3:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109ff6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ff9:	83 c0 06             	add    $0x6,%eax
80109ffc:	83 ec 04             	sub    $0x4,%esp
80109fff:	6a 06                	push   $0x6
8010a001:	68 68 d0 18 80       	push   $0x8018d068
8010a006:	50                   	push   %eax
8010a007:	e8 ec b0 ff ff       	call   801050f8 <memmove>
8010a00c:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a00f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a012:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a016:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a019:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a01d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a020:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a023:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a026:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a02a:	83 ec 0c             	sub    $0xc,%esp
8010a02d:	6a 54                	push   $0x54
8010a02f:	e8 e3 fc ff ff       	call   80109d17 <H2N_ushort>
8010a034:	83 c4 10             	add    $0x10,%esp
8010a037:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a03a:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a03e:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a045:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a048:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a04c:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a053:	83 c0 01             	add    $0x1,%eax
8010a056:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a05c:	83 ec 0c             	sub    $0xc,%esp
8010a05f:	68 00 40 00 00       	push   $0x4000
8010a064:	e8 ae fc ff ff       	call   80109d17 <H2N_ushort>
8010a069:	83 c4 10             	add    $0x10,%esp
8010a06c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a06f:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a076:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a07a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a07d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a081:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a084:	83 c0 0c             	add    $0xc,%eax
8010a087:	83 ec 04             	sub    $0x4,%esp
8010a08a:	6a 04                	push   $0x4
8010a08c:	68 04 f5 10 80       	push   $0x8010f504
8010a091:	50                   	push   %eax
8010a092:	e8 61 b0 ff ff       	call   801050f8 <memmove>
8010a097:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a09a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a09d:	8d 50 0c             	lea    0xc(%eax),%edx
8010a0a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0a3:	83 c0 10             	add    $0x10,%eax
8010a0a6:	83 ec 04             	sub    $0x4,%esp
8010a0a9:	6a 04                	push   $0x4
8010a0ab:	52                   	push   %edx
8010a0ac:	50                   	push   %eax
8010a0ad:	e8 46 b0 ff ff       	call   801050f8 <memmove>
8010a0b2:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a0b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0b8:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a0be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0c1:	83 ec 0c             	sub    $0xc,%esp
8010a0c4:	50                   	push   %eax
8010a0c5:	e8 5d fd ff ff       	call   80109e27 <ipv4_chksum>
8010a0ca:	83 c4 10             	add    $0x10,%esp
8010a0cd:	0f b7 c0             	movzwl %ax,%eax
8010a0d0:	83 ec 0c             	sub    $0xc,%esp
8010a0d3:	50                   	push   %eax
8010a0d4:	e8 3e fc ff ff       	call   80109d17 <H2N_ushort>
8010a0d9:	83 c4 10             	add    $0x10,%esp
8010a0dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0df:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a0e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0e6:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a0e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0ec:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a0f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0f3:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a0f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0fa:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a0fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a101:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a105:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a108:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a10c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a10f:	8d 50 08             	lea    0x8(%eax),%edx
8010a112:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a115:	83 c0 08             	add    $0x8,%eax
8010a118:	83 ec 04             	sub    $0x4,%esp
8010a11b:	6a 08                	push   $0x8
8010a11d:	52                   	push   %edx
8010a11e:	50                   	push   %eax
8010a11f:	e8 d4 af ff ff       	call   801050f8 <memmove>
8010a124:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a127:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a12a:	8d 50 10             	lea    0x10(%eax),%edx
8010a12d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a130:	83 c0 10             	add    $0x10,%eax
8010a133:	83 ec 04             	sub    $0x4,%esp
8010a136:	6a 30                	push   $0x30
8010a138:	52                   	push   %edx
8010a139:	50                   	push   %eax
8010a13a:	e8 b9 af ff ff       	call   801050f8 <memmove>
8010a13f:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a142:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a145:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a14b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a14e:	83 ec 0c             	sub    $0xc,%esp
8010a151:	50                   	push   %eax
8010a152:	e8 1c 00 00 00       	call   8010a173 <icmp_chksum>
8010a157:	83 c4 10             	add    $0x10,%esp
8010a15a:	0f b7 c0             	movzwl %ax,%eax
8010a15d:	83 ec 0c             	sub    $0xc,%esp
8010a160:	50                   	push   %eax
8010a161:	e8 b1 fb ff ff       	call   80109d17 <H2N_ushort>
8010a166:	83 c4 10             	add    $0x10,%esp
8010a169:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a16c:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a170:	90                   	nop
8010a171:	c9                   	leave  
8010a172:	c3                   	ret    

8010a173 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a173:	f3 0f 1e fb          	endbr32 
8010a177:	55                   	push   %ebp
8010a178:	89 e5                	mov    %esp,%ebp
8010a17a:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a17d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a180:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a183:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a18a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a191:	eb 48                	jmp    8010a1db <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a193:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a196:	01 c0                	add    %eax,%eax
8010a198:	89 c2                	mov    %eax,%edx
8010a19a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a19d:	01 d0                	add    %edx,%eax
8010a19f:	0f b6 00             	movzbl (%eax),%eax
8010a1a2:	0f b6 c0             	movzbl %al,%eax
8010a1a5:	c1 e0 08             	shl    $0x8,%eax
8010a1a8:	89 c2                	mov    %eax,%edx
8010a1aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a1ad:	01 c0                	add    %eax,%eax
8010a1af:	8d 48 01             	lea    0x1(%eax),%ecx
8010a1b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1b5:	01 c8                	add    %ecx,%eax
8010a1b7:	0f b6 00             	movzbl (%eax),%eax
8010a1ba:	0f b6 c0             	movzbl %al,%eax
8010a1bd:	01 d0                	add    %edx,%eax
8010a1bf:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a1c2:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a1c9:	76 0c                	jbe    8010a1d7 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a1cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a1ce:	0f b7 c0             	movzwl %ax,%eax
8010a1d1:	83 c0 01             	add    $0x1,%eax
8010a1d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a1d7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a1db:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a1df:	7e b2                	jle    8010a193 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a1e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a1e4:	f7 d0                	not    %eax
}
8010a1e6:	c9                   	leave  
8010a1e7:	c3                   	ret    

8010a1e8 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a1e8:	f3 0f 1e fb          	endbr32 
8010a1ec:	55                   	push   %ebp
8010a1ed:	89 e5                	mov    %esp,%ebp
8010a1ef:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a1f2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f5:	83 c0 0e             	add    $0xe,%eax
8010a1f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a1fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1fe:	0f b6 00             	movzbl (%eax),%eax
8010a201:	0f b6 c0             	movzbl %al,%eax
8010a204:	83 e0 0f             	and    $0xf,%eax
8010a207:	c1 e0 02             	shl    $0x2,%eax
8010a20a:	89 c2                	mov    %eax,%edx
8010a20c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a20f:	01 d0                	add    %edx,%eax
8010a211:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a214:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a217:	83 c0 14             	add    $0x14,%eax
8010a21a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a21d:	e8 70 86 ff ff       	call   80102892 <kalloc>
8010a222:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a225:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a22c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a22f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a233:	0f b6 c0             	movzbl %al,%eax
8010a236:	83 e0 02             	and    $0x2,%eax
8010a239:	85 c0                	test   %eax,%eax
8010a23b:	74 3d                	je     8010a27a <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a23d:	83 ec 0c             	sub    $0xc,%esp
8010a240:	6a 00                	push   $0x0
8010a242:	6a 12                	push   $0x12
8010a244:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a247:	50                   	push   %eax
8010a248:	ff 75 e8             	pushl  -0x18(%ebp)
8010a24b:	ff 75 08             	pushl  0x8(%ebp)
8010a24e:	e8 a2 01 00 00       	call   8010a3f5 <tcp_pkt_create>
8010a253:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a256:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a259:	83 ec 08             	sub    $0x8,%esp
8010a25c:	50                   	push   %eax
8010a25d:	ff 75 e8             	pushl  -0x18(%ebp)
8010a260:	e8 ff f0 ff ff       	call   80109364 <i8254_send>
8010a265:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a268:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a26d:	83 c0 01             	add    $0x1,%eax
8010a270:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a275:	e9 69 01 00 00       	jmp    8010a3e3 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a27a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a27d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a281:	3c 18                	cmp    $0x18,%al
8010a283:	0f 85 10 01 00 00    	jne    8010a399 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a289:	83 ec 04             	sub    $0x4,%esp
8010a28c:	6a 03                	push   $0x3
8010a28e:	68 be c8 10 80       	push   $0x8010c8be
8010a293:	ff 75 ec             	pushl  -0x14(%ebp)
8010a296:	e8 01 ae ff ff       	call   8010509c <memcmp>
8010a29b:	83 c4 10             	add    $0x10,%esp
8010a29e:	85 c0                	test   %eax,%eax
8010a2a0:	74 74                	je     8010a316 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a2a2:	83 ec 0c             	sub    $0xc,%esp
8010a2a5:	68 c2 c8 10 80       	push   $0x8010c8c2
8010a2aa:	e8 5d 61 ff ff       	call   8010040c <cprintf>
8010a2af:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a2b2:	83 ec 0c             	sub    $0xc,%esp
8010a2b5:	6a 00                	push   $0x0
8010a2b7:	6a 10                	push   $0x10
8010a2b9:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2bc:	50                   	push   %eax
8010a2bd:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2c0:	ff 75 08             	pushl  0x8(%ebp)
8010a2c3:	e8 2d 01 00 00       	call   8010a3f5 <tcp_pkt_create>
8010a2c8:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a2cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a2ce:	83 ec 08             	sub    $0x8,%esp
8010a2d1:	50                   	push   %eax
8010a2d2:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2d5:	e8 8a f0 ff ff       	call   80109364 <i8254_send>
8010a2da:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a2dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2e0:	83 c0 36             	add    $0x36,%eax
8010a2e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a2e6:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a2e9:	50                   	push   %eax
8010a2ea:	ff 75 e0             	pushl  -0x20(%ebp)
8010a2ed:	6a 00                	push   $0x0
8010a2ef:	6a 00                	push   $0x0
8010a2f1:	e8 66 04 00 00       	call   8010a75c <http_proc>
8010a2f6:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a2f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a2fc:	83 ec 0c             	sub    $0xc,%esp
8010a2ff:	50                   	push   %eax
8010a300:	6a 18                	push   $0x18
8010a302:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a305:	50                   	push   %eax
8010a306:	ff 75 e8             	pushl  -0x18(%ebp)
8010a309:	ff 75 08             	pushl  0x8(%ebp)
8010a30c:	e8 e4 00 00 00       	call   8010a3f5 <tcp_pkt_create>
8010a311:	83 c4 20             	add    $0x20,%esp
8010a314:	eb 62                	jmp    8010a378 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a316:	83 ec 0c             	sub    $0xc,%esp
8010a319:	6a 00                	push   $0x0
8010a31b:	6a 10                	push   $0x10
8010a31d:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a320:	50                   	push   %eax
8010a321:	ff 75 e8             	pushl  -0x18(%ebp)
8010a324:	ff 75 08             	pushl  0x8(%ebp)
8010a327:	e8 c9 00 00 00       	call   8010a3f5 <tcp_pkt_create>
8010a32c:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a32f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a332:	83 ec 08             	sub    $0x8,%esp
8010a335:	50                   	push   %eax
8010a336:	ff 75 e8             	pushl  -0x18(%ebp)
8010a339:	e8 26 f0 ff ff       	call   80109364 <i8254_send>
8010a33e:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a341:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a344:	83 c0 36             	add    $0x36,%eax
8010a347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a34a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a34d:	50                   	push   %eax
8010a34e:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a351:	6a 00                	push   $0x0
8010a353:	6a 00                	push   $0x0
8010a355:	e8 02 04 00 00       	call   8010a75c <http_proc>
8010a35a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a35d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a360:	83 ec 0c             	sub    $0xc,%esp
8010a363:	50                   	push   %eax
8010a364:	6a 18                	push   $0x18
8010a366:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a369:	50                   	push   %eax
8010a36a:	ff 75 e8             	pushl  -0x18(%ebp)
8010a36d:	ff 75 08             	pushl  0x8(%ebp)
8010a370:	e8 80 00 00 00       	call   8010a3f5 <tcp_pkt_create>
8010a375:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a378:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a37b:	83 ec 08             	sub    $0x8,%esp
8010a37e:	50                   	push   %eax
8010a37f:	ff 75 e8             	pushl  -0x18(%ebp)
8010a382:	e8 dd ef ff ff       	call   80109364 <i8254_send>
8010a387:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a38a:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a38f:	83 c0 01             	add    $0x1,%eax
8010a392:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a397:	eb 4a                	jmp    8010a3e3 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a39c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a3a0:	3c 10                	cmp    $0x10,%al
8010a3a2:	75 3f                	jne    8010a3e3 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a3a4:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a3a9:	83 f8 01             	cmp    $0x1,%eax
8010a3ac:	75 35                	jne    8010a3e3 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a3ae:	83 ec 0c             	sub    $0xc,%esp
8010a3b1:	6a 00                	push   $0x0
8010a3b3:	6a 01                	push   $0x1
8010a3b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3b8:	50                   	push   %eax
8010a3b9:	ff 75 e8             	pushl  -0x18(%ebp)
8010a3bc:	ff 75 08             	pushl  0x8(%ebp)
8010a3bf:	e8 31 00 00 00       	call   8010a3f5 <tcp_pkt_create>
8010a3c4:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a3c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a3ca:	83 ec 08             	sub    $0x8,%esp
8010a3cd:	50                   	push   %eax
8010a3ce:	ff 75 e8             	pushl  -0x18(%ebp)
8010a3d1:	e8 8e ef ff ff       	call   80109364 <i8254_send>
8010a3d6:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a3d9:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a3e0:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a3e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3e6:	83 ec 0c             	sub    $0xc,%esp
8010a3e9:	50                   	push   %eax
8010a3ea:	e8 05 84 ff ff       	call   801027f4 <kfree>
8010a3ef:	83 c4 10             	add    $0x10,%esp
}
8010a3f2:	90                   	nop
8010a3f3:	c9                   	leave  
8010a3f4:	c3                   	ret    

8010a3f5 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a3f5:	f3 0f 1e fb          	endbr32 
8010a3f9:	55                   	push   %ebp
8010a3fa:	89 e5                	mov    %esp,%ebp
8010a3fc:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a3ff:	8b 45 08             	mov    0x8(%ebp),%eax
8010a402:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a405:	8b 45 08             	mov    0x8(%ebp),%eax
8010a408:	83 c0 0e             	add    $0xe,%eax
8010a40b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a40e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a411:	0f b6 00             	movzbl (%eax),%eax
8010a414:	0f b6 c0             	movzbl %al,%eax
8010a417:	83 e0 0f             	and    $0xf,%eax
8010a41a:	c1 e0 02             	shl    $0x2,%eax
8010a41d:	89 c2                	mov    %eax,%edx
8010a41f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a422:	01 d0                	add    %edx,%eax
8010a424:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a427:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a42a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a42d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a430:	83 c0 0e             	add    $0xe,%eax
8010a433:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a436:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a439:	83 c0 14             	add    $0x14,%eax
8010a43c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a43f:	8b 45 18             	mov    0x18(%ebp),%eax
8010a442:	8d 50 36             	lea    0x36(%eax),%edx
8010a445:	8b 45 10             	mov    0x10(%ebp),%eax
8010a448:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a44a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a44d:	8d 50 06             	lea    0x6(%eax),%edx
8010a450:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a453:	83 ec 04             	sub    $0x4,%esp
8010a456:	6a 06                	push   $0x6
8010a458:	52                   	push   %edx
8010a459:	50                   	push   %eax
8010a45a:	e8 99 ac ff ff       	call   801050f8 <memmove>
8010a45f:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a462:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a465:	83 c0 06             	add    $0x6,%eax
8010a468:	83 ec 04             	sub    $0x4,%esp
8010a46b:	6a 06                	push   $0x6
8010a46d:	68 68 d0 18 80       	push   $0x8018d068
8010a472:	50                   	push   %eax
8010a473:	e8 80 ac ff ff       	call   801050f8 <memmove>
8010a478:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a47b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a47e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a482:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a485:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a489:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a48c:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a48f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a492:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a496:	8b 45 18             	mov    0x18(%ebp),%eax
8010a499:	83 c0 28             	add    $0x28,%eax
8010a49c:	0f b7 c0             	movzwl %ax,%eax
8010a49f:	83 ec 0c             	sub    $0xc,%esp
8010a4a2:	50                   	push   %eax
8010a4a3:	e8 6f f8 ff ff       	call   80109d17 <H2N_ushort>
8010a4a8:	83 c4 10             	add    $0x10,%esp
8010a4ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4ae:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a4b2:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a4b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4bc:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a4c0:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a4c7:	83 c0 01             	add    $0x1,%eax
8010a4ca:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a4d0:	83 ec 0c             	sub    $0xc,%esp
8010a4d3:	6a 00                	push   $0x0
8010a4d5:	e8 3d f8 ff ff       	call   80109d17 <H2N_ushort>
8010a4da:	83 c4 10             	add    $0x10,%esp
8010a4dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4e0:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a4e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4e7:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a4eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4ee:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a4f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4f5:	83 c0 0c             	add    $0xc,%eax
8010a4f8:	83 ec 04             	sub    $0x4,%esp
8010a4fb:	6a 04                	push   $0x4
8010a4fd:	68 04 f5 10 80       	push   $0x8010f504
8010a502:	50                   	push   %eax
8010a503:	e8 f0 ab ff ff       	call   801050f8 <memmove>
8010a508:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a50b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a50e:	8d 50 0c             	lea    0xc(%eax),%edx
8010a511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a514:	83 c0 10             	add    $0x10,%eax
8010a517:	83 ec 04             	sub    $0x4,%esp
8010a51a:	6a 04                	push   $0x4
8010a51c:	52                   	push   %edx
8010a51d:	50                   	push   %eax
8010a51e:	e8 d5 ab ff ff       	call   801050f8 <memmove>
8010a523:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a526:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a529:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a52f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a532:	83 ec 0c             	sub    $0xc,%esp
8010a535:	50                   	push   %eax
8010a536:	e8 ec f8 ff ff       	call   80109e27 <ipv4_chksum>
8010a53b:	83 c4 10             	add    $0x10,%esp
8010a53e:	0f b7 c0             	movzwl %ax,%eax
8010a541:	83 ec 0c             	sub    $0xc,%esp
8010a544:	50                   	push   %eax
8010a545:	e8 cd f7 ff ff       	call   80109d17 <H2N_ushort>
8010a54a:	83 c4 10             	add    $0x10,%esp
8010a54d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a550:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a554:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a557:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a55b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a55e:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a561:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a564:	0f b7 10             	movzwl (%eax),%edx
8010a567:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a56a:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a56e:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a573:	83 ec 0c             	sub    $0xc,%esp
8010a576:	50                   	push   %eax
8010a577:	e8 c1 f7 ff ff       	call   80109d3d <H2N_uint>
8010a57c:	83 c4 10             	add    $0x10,%esp
8010a57f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a582:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a585:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a588:	8b 40 04             	mov    0x4(%eax),%eax
8010a58b:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a591:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a594:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a597:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a59a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a59e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5a1:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a5a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5a8:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a5ac:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5af:	89 c2                	mov    %eax,%edx
8010a5b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5b4:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a5b7:	83 ec 0c             	sub    $0xc,%esp
8010a5ba:	68 90 38 00 00       	push   $0x3890
8010a5bf:	e8 53 f7 ff ff       	call   80109d17 <H2N_ushort>
8010a5c4:	83 c4 10             	add    $0x10,%esp
8010a5c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a5ca:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a5ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5d1:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a5d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5da:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a5e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5e3:	83 ec 0c             	sub    $0xc,%esp
8010a5e6:	50                   	push   %eax
8010a5e7:	e8 1f 00 00 00       	call   8010a60b <tcp_chksum>
8010a5ec:	83 c4 10             	add    $0x10,%esp
8010a5ef:	83 c0 08             	add    $0x8,%eax
8010a5f2:	0f b7 c0             	movzwl %ax,%eax
8010a5f5:	83 ec 0c             	sub    $0xc,%esp
8010a5f8:	50                   	push   %eax
8010a5f9:	e8 19 f7 ff ff       	call   80109d17 <H2N_ushort>
8010a5fe:	83 c4 10             	add    $0x10,%esp
8010a601:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a604:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a608:	90                   	nop
8010a609:	c9                   	leave  
8010a60a:	c3                   	ret    

8010a60b <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a60b:	f3 0f 1e fb          	endbr32 
8010a60f:	55                   	push   %ebp
8010a610:	89 e5                	mov    %esp,%ebp
8010a612:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a615:	8b 45 08             	mov    0x8(%ebp),%eax
8010a618:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a61b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a61e:	83 c0 14             	add    $0x14,%eax
8010a621:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a624:	83 ec 04             	sub    $0x4,%esp
8010a627:	6a 04                	push   $0x4
8010a629:	68 04 f5 10 80       	push   $0x8010f504
8010a62e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a631:	50                   	push   %eax
8010a632:	e8 c1 aa ff ff       	call   801050f8 <memmove>
8010a637:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a63a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a63d:	83 c0 0c             	add    $0xc,%eax
8010a640:	83 ec 04             	sub    $0x4,%esp
8010a643:	6a 04                	push   $0x4
8010a645:	50                   	push   %eax
8010a646:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a649:	83 c0 04             	add    $0x4,%eax
8010a64c:	50                   	push   %eax
8010a64d:	e8 a6 aa ff ff       	call   801050f8 <memmove>
8010a652:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a655:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a659:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a65d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a660:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a664:	0f b7 c0             	movzwl %ax,%eax
8010a667:	83 ec 0c             	sub    $0xc,%esp
8010a66a:	50                   	push   %eax
8010a66b:	e8 81 f6 ff ff       	call   80109cf1 <N2H_ushort>
8010a670:	83 c4 10             	add    $0x10,%esp
8010a673:	83 e8 14             	sub    $0x14,%eax
8010a676:	0f b7 c0             	movzwl %ax,%eax
8010a679:	83 ec 0c             	sub    $0xc,%esp
8010a67c:	50                   	push   %eax
8010a67d:	e8 95 f6 ff ff       	call   80109d17 <H2N_ushort>
8010a682:	83 c4 10             	add    $0x10,%esp
8010a685:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a689:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a690:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a693:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a696:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a69d:	eb 33                	jmp    8010a6d2 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a69f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6a2:	01 c0                	add    %eax,%eax
8010a6a4:	89 c2                	mov    %eax,%edx
8010a6a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6a9:	01 d0                	add    %edx,%eax
8010a6ab:	0f b6 00             	movzbl (%eax),%eax
8010a6ae:	0f b6 c0             	movzbl %al,%eax
8010a6b1:	c1 e0 08             	shl    $0x8,%eax
8010a6b4:	89 c2                	mov    %eax,%edx
8010a6b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6b9:	01 c0                	add    %eax,%eax
8010a6bb:	8d 48 01             	lea    0x1(%eax),%ecx
8010a6be:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6c1:	01 c8                	add    %ecx,%eax
8010a6c3:	0f b6 00             	movzbl (%eax),%eax
8010a6c6:	0f b6 c0             	movzbl %al,%eax
8010a6c9:	01 d0                	add    %edx,%eax
8010a6cb:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a6ce:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a6d2:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a6d6:	7e c7                	jle    8010a69f <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a6d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a6de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a6e5:	eb 33                	jmp    8010a71a <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a6e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6ea:	01 c0                	add    %eax,%eax
8010a6ec:	89 c2                	mov    %eax,%edx
8010a6ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6f1:	01 d0                	add    %edx,%eax
8010a6f3:	0f b6 00             	movzbl (%eax),%eax
8010a6f6:	0f b6 c0             	movzbl %al,%eax
8010a6f9:	c1 e0 08             	shl    $0x8,%eax
8010a6fc:	89 c2                	mov    %eax,%edx
8010a6fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a701:	01 c0                	add    %eax,%eax
8010a703:	8d 48 01             	lea    0x1(%eax),%ecx
8010a706:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a709:	01 c8                	add    %ecx,%eax
8010a70b:	0f b6 00             	movzbl (%eax),%eax
8010a70e:	0f b6 c0             	movzbl %al,%eax
8010a711:	01 d0                	add    %edx,%eax
8010a713:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a716:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a71a:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a71e:	0f b7 c0             	movzwl %ax,%eax
8010a721:	83 ec 0c             	sub    $0xc,%esp
8010a724:	50                   	push   %eax
8010a725:	e8 c7 f5 ff ff       	call   80109cf1 <N2H_ushort>
8010a72a:	83 c4 10             	add    $0x10,%esp
8010a72d:	66 d1 e8             	shr    %ax
8010a730:	0f b7 c0             	movzwl %ax,%eax
8010a733:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a736:	7c af                	jl     8010a6e7 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a73b:	c1 e8 10             	shr    $0x10,%eax
8010a73e:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a741:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a744:	f7 d0                	not    %eax
}
8010a746:	c9                   	leave  
8010a747:	c3                   	ret    

8010a748 <tcp_fin>:

void tcp_fin(){
8010a748:	f3 0f 1e fb          	endbr32 
8010a74c:	55                   	push   %ebp
8010a74d:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a74f:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a756:	00 00 00 
}
8010a759:	90                   	nop
8010a75a:	5d                   	pop    %ebp
8010a75b:	c3                   	ret    

8010a75c <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a75c:	f3 0f 1e fb          	endbr32 
8010a760:	55                   	push   %ebp
8010a761:	89 e5                	mov    %esp,%ebp
8010a763:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a766:	8b 45 10             	mov    0x10(%ebp),%eax
8010a769:	83 ec 04             	sub    $0x4,%esp
8010a76c:	6a 00                	push   $0x0
8010a76e:	68 cb c8 10 80       	push   $0x8010c8cb
8010a773:	50                   	push   %eax
8010a774:	e8 65 00 00 00       	call   8010a7de <http_strcpy>
8010a779:	83 c4 10             	add    $0x10,%esp
8010a77c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a77f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a782:	83 ec 04             	sub    $0x4,%esp
8010a785:	ff 75 f4             	pushl  -0xc(%ebp)
8010a788:	68 de c8 10 80       	push   $0x8010c8de
8010a78d:	50                   	push   %eax
8010a78e:	e8 4b 00 00 00       	call   8010a7de <http_strcpy>
8010a793:	83 c4 10             	add    $0x10,%esp
8010a796:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a799:	8b 45 10             	mov    0x10(%ebp),%eax
8010a79c:	83 ec 04             	sub    $0x4,%esp
8010a79f:	ff 75 f4             	pushl  -0xc(%ebp)
8010a7a2:	68 f9 c8 10 80       	push   $0x8010c8f9
8010a7a7:	50                   	push   %eax
8010a7a8:	e8 31 00 00 00       	call   8010a7de <http_strcpy>
8010a7ad:	83 c4 10             	add    $0x10,%esp
8010a7b0:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7b6:	83 e0 01             	and    $0x1,%eax
8010a7b9:	85 c0                	test   %eax,%eax
8010a7bb:	74 11                	je     8010a7ce <http_proc+0x72>
    char *payload = (char *)send;
8010a7bd:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a7c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a7c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7c9:	01 d0                	add    %edx,%eax
8010a7cb:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a7ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a7d1:	8b 45 14             	mov    0x14(%ebp),%eax
8010a7d4:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a7d6:	e8 6d ff ff ff       	call   8010a748 <tcp_fin>
}
8010a7db:	90                   	nop
8010a7dc:	c9                   	leave  
8010a7dd:	c3                   	ret    

8010a7de <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a7de:	f3 0f 1e fb          	endbr32 
8010a7e2:	55                   	push   %ebp
8010a7e3:	89 e5                	mov    %esp,%ebp
8010a7e5:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a7e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a7ef:	eb 20                	jmp    8010a811 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a7f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a7f4:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a7f7:	01 d0                	add    %edx,%eax
8010a7f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a7fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a7ff:	01 ca                	add    %ecx,%edx
8010a801:	89 d1                	mov    %edx,%ecx
8010a803:	8b 55 08             	mov    0x8(%ebp),%edx
8010a806:	01 ca                	add    %ecx,%edx
8010a808:	0f b6 00             	movzbl (%eax),%eax
8010a80b:	88 02                	mov    %al,(%edx)
    i++;
8010a80d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a811:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a814:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a817:	01 d0                	add    %edx,%eax
8010a819:	0f b6 00             	movzbl (%eax),%eax
8010a81c:	84 c0                	test   %al,%al
8010a81e:	75 d1                	jne    8010a7f1 <http_strcpy+0x13>
  }
  return i;
8010a820:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a823:	c9                   	leave  
8010a824:	c3                   	ret    

8010a825 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a825:	f3 0f 1e fb          	endbr32 
8010a829:	55                   	push   %ebp
8010a82a:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a82c:	c7 05 50 d3 18 80 c2 	movl   $0x8010f5c2,0x8018d350
8010a833:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a836:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a83b:	c1 e8 09             	shr    $0x9,%eax
8010a83e:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a843:	90                   	nop
8010a844:	5d                   	pop    %ebp
8010a845:	c3                   	ret    

8010a846 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a846:	f3 0f 1e fb          	endbr32 
8010a84a:	55                   	push   %ebp
8010a84b:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a84d:	90                   	nop
8010a84e:	5d                   	pop    %ebp
8010a84f:	c3                   	ret    

8010a850 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a850:	f3 0f 1e fb          	endbr32 
8010a854:	55                   	push   %ebp
8010a855:	89 e5                	mov    %esp,%ebp
8010a857:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a85a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a85d:	83 c0 0c             	add    $0xc,%eax
8010a860:	83 ec 0c             	sub    $0xc,%esp
8010a863:	50                   	push   %eax
8010a864:	e8 a0 a4 ff ff       	call   80104d09 <holdingsleep>
8010a869:	83 c4 10             	add    $0x10,%esp
8010a86c:	85 c0                	test   %eax,%eax
8010a86e:	75 0d                	jne    8010a87d <iderw+0x2d>
    panic("iderw: buf not locked");
8010a870:	83 ec 0c             	sub    $0xc,%esp
8010a873:	68 0a c9 10 80       	push   $0x8010c90a
8010a878:	e8 48 5d ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a87d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a880:	8b 00                	mov    (%eax),%eax
8010a882:	83 e0 06             	and    $0x6,%eax
8010a885:	83 f8 02             	cmp    $0x2,%eax
8010a888:	75 0d                	jne    8010a897 <iderw+0x47>
    panic("iderw: nothing to do");
8010a88a:	83 ec 0c             	sub    $0xc,%esp
8010a88d:	68 20 c9 10 80       	push   $0x8010c920
8010a892:	e8 2e 5d ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a897:	8b 45 08             	mov    0x8(%ebp),%eax
8010a89a:	8b 40 04             	mov    0x4(%eax),%eax
8010a89d:	83 f8 01             	cmp    $0x1,%eax
8010a8a0:	74 0d                	je     8010a8af <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a8a2:	83 ec 0c             	sub    $0xc,%esp
8010a8a5:	68 35 c9 10 80       	push   $0x8010c935
8010a8aa:	e8 16 5d ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a8af:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8b2:	8b 40 08             	mov    0x8(%eax),%eax
8010a8b5:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a8bb:	39 d0                	cmp    %edx,%eax
8010a8bd:	72 0d                	jb     8010a8cc <iderw+0x7c>
    panic("iderw: block out of range");
8010a8bf:	83 ec 0c             	sub    $0xc,%esp
8010a8c2:	68 53 c9 10 80       	push   $0x8010c953
8010a8c7:	e8 f9 5c ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a8cc:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a8d2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8d5:	8b 40 08             	mov    0x8(%eax),%eax
8010a8d8:	c1 e0 09             	shl    $0x9,%eax
8010a8db:	01 d0                	add    %edx,%eax
8010a8dd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a8e0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8e3:	8b 00                	mov    (%eax),%eax
8010a8e5:	83 e0 04             	and    $0x4,%eax
8010a8e8:	85 c0                	test   %eax,%eax
8010a8ea:	74 2b                	je     8010a917 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a8ec:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8ef:	8b 00                	mov    (%eax),%eax
8010a8f1:	83 e0 fb             	and    $0xfffffffb,%eax
8010a8f4:	89 c2                	mov    %eax,%edx
8010a8f6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8f9:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a8fb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8fe:	83 c0 5c             	add    $0x5c,%eax
8010a901:	83 ec 04             	sub    $0x4,%esp
8010a904:	68 00 02 00 00       	push   $0x200
8010a909:	50                   	push   %eax
8010a90a:	ff 75 f4             	pushl  -0xc(%ebp)
8010a90d:	e8 e6 a7 ff ff       	call   801050f8 <memmove>
8010a912:	83 c4 10             	add    $0x10,%esp
8010a915:	eb 1a                	jmp    8010a931 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a917:	8b 45 08             	mov    0x8(%ebp),%eax
8010a91a:	83 c0 5c             	add    $0x5c,%eax
8010a91d:	83 ec 04             	sub    $0x4,%esp
8010a920:	68 00 02 00 00       	push   $0x200
8010a925:	ff 75 f4             	pushl  -0xc(%ebp)
8010a928:	50                   	push   %eax
8010a929:	e8 ca a7 ff ff       	call   801050f8 <memmove>
8010a92e:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a931:	8b 45 08             	mov    0x8(%ebp),%eax
8010a934:	8b 00                	mov    (%eax),%eax
8010a936:	83 c8 02             	or     $0x2,%eax
8010a939:	89 c2                	mov    %eax,%edx
8010a93b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a93e:	89 10                	mov    %edx,(%eax)
}
8010a940:	90                   	nop
8010a941:	c9                   	leave  
8010a942:	c3                   	ret    
